// +build ignore

package main

import (
	"io/ioutil"
	"log"
	"os"
	"os/signal"
	"syscall"

	"honnef.co/go/spew"
	"honnef.co/go/wayfarer/drm"
	"honnef.co/go/wayfarer/vt"
)

func main() {
	chRelsig := make(chan os.Signal, 1)
	chAcqsig := make(chan os.Signal, 1)
	chExit := make(chan os.Signal, 1)
	signal.Notify(chRelsig, syscall.SIGUSR1)
	signal.Notify(chAcqsig, syscall.SIGUSR2)
	signal.Notify(chExit, os.Interrupt)

	tty := vt.OpenFd(0)
	tty.KDSETMODE(vt.KD_GRAPHICS)
	tty.VT_SETMODE(vt.VtMode{
		Relsig: int16(syscall.SIGUSR1),
		Acqsig: int16(syscall.SIGUSR2),
		Mode:   vt.VT_PROCESS,
	})
	// tty.KDSKBMUTE(1)

	dev, err := drm.Open("/dev/dri/card0")
	if err != nil {
		log.Fatal(err)
	}
	dev.SetMaster()
	res, err := dev.Resources()
	if err != nil {
		log.Fatal(err)
	}

	conn, err := dev.Connector(res.Connectors[0])
	if err != nil {
		log.Fatal(err)
	}
	if conn.Connection != drm.ModeConnected {
		log.Fatal("connector not used")
	}
	mode := conn.Modes[0]
	enc, _ := dev.Encoder(conn.EncoderID)
	dumb := dev.CreateDumb(uint32(mode.Hdisplay), uint32(mode.Vdisplay), 32)
	fb := dev.AddFB(uint32(mode.Hdisplay), uint32(mode.Vdisplay), 24, 32, dumb.Pitch, dumb.Handle)
	buf := dev.Mmap(dumb.Handle, uint32(dumb.Size))
	oldCrtc := dev.Crtc(enc.CrtcID)
	spew.Dump(oldCrtc)
	dev.SetCrtc(enc.CrtcID, fb, 0, 0, []uint32{conn.ConnectorID}, &mode)

	b, err := ioutil.ReadFile("/tmp/gopher.data")
	if err != nil {
		log.Fatal(err)
	}

	copy(buf, b)

	for {
		select {
		case <-chRelsig:
			dev.DropMaster()
			tty.VT_RELDISP(1)
		case <-chAcqsig:
			tty.VT_RELDISP(vt.VT_ACKACQ)
			dev.SetMaster()
			dev.SetCrtc(enc.CrtcID, fb, 0, 0, []uint32{conn.ConnectorID}, &mode)
		case <-chExit:
			dev.RmFB(fb)
			dev.DestroyDumb(dumb.Handle)
			dev.SetCrtc(oldCrtc.CrtcID, oldCrtc.FbID, oldCrtc.X, oldCrtc.Y, []uint32{conn.ConnectorID}, oldCrtc.Mode)
			tty.KDSETMODE(vt.KD_TEXT)
			tty.VT_SETMODE(vt.VtMode{Mode: vt.VT_AUTO})
			os.Exit(0)
		}
	}
}
