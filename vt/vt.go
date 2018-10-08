package vt

import (
	"syscall"
	"unsafe"
)

type (
	vtMode struct {
		mode   byte
		waitv  byte
		relsig int16
		acqsig int16
		frsig  int16
	}
)

type (
	VtMode struct {
		Mode   byte
		Waitv  byte
		Relsig int16
		Acqsig int16
		Frsig  int16
	}
)

type Handle struct {
	fd int
}

func Open(path string) (*Handle, error) {
	f, err := syscall.Open(path, syscall.O_WRONLY|syscall.O_CLOEXEC, 0)
	if err != nil {
		return nil, err
	}
	return &Handle{f}, nil
}

func OpenFd(fd int) *Handle {
	return &Handle{fd}
}

func (hnd *Handle) ioctl(op uintptr, arg unsafe.Pointer) (int, error) {
	for {
		r1, _, errno := syscall.Syscall(syscall.SYS_IOCTL, uintptr(hnd.fd), op, uintptr(arg))
		ret := int(r1)
		if ret != -1 || (errno != syscall.EINTR && errno != syscall.EAGAIN) {
			var err error
			if errno != 0 {
				err = errno
			}
			return ret, err
		}
	}
}

func (hnd *Handle) ioctlNoPtr(op uintptr, arg uintptr) (int, error) {
	for {
		r1, _, errno := syscall.Syscall(syscall.SYS_IOCTL, uintptr(hnd.fd), op, arg)
		ret := int(r1)
		if ret != -1 || (errno != syscall.EINTR && errno != syscall.EAGAIN) {
			var err error
			if errno != 0 {
				err = errno
			}
			return ret, err
		}
	}
}

func (hnd *Handle) KDSETMODE(mode uintptr) {
	const op = 0x4B3A
	hnd.ioctlNoPtr(op, mode)
}

func (hnd *Handle) KDSKBMUTE(value uintptr) {
	const op = 0x00
	hnd.ioctlNoPtr(op, value)
}

func (hnd *Handle) VT_SETMODE(mode VtMode) {
	const op = 0x5602
	imode := vtMode{
		mode:   mode.Mode,
		waitv:  mode.Waitv,
		relsig: mode.Relsig,
		acqsig: mode.Acqsig,
		frsig:  mode.Frsig,
	}
	hnd.ioctl(op, unsafe.Pointer(&imode))
}

func (hnd *Handle) VT_RELDISP(value uintptr) {
	const op = 0x5605
	hnd.ioctlNoPtr(op, value)
}

const (
	KD_TEXT     = 0
	KD_GRAPHICS = 1
)

const (
	VT_AUTO    = 0
	VT_PROCESS = 1
	VT_ACKACQ  = 2
)
