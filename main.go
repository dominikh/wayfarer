package main

// #cgo pkg-config: egl
// #include <EGL/egl.h>
// #include <wayland-server.h>
// #include <stdlib.h>
// typedef EGLBoolean (EGLAPIENTRYP PFNEGLBINDWAYLANDDISPLAYWL) (EGLDisplay dpy, struct wl_display *display);
// static EGLBoolean eglBindWaylandDisplayWL(PFNEGLBINDWAYLANDDISPLAYWL fnptr, EGLDisplay dpy, struct wl_display *display) {
//   return (*fnptr)(dpy, display);
// }
import "C"
import (
	"fmt"
	"log"
	"net/http"
	_ "net/http/pprof"
	"unsafe"

	"github.com/BurntSushi/xgb"
	"honnef.co/go/egl"
	"honnef.co/go/gl"
	"honnef.co/go/newui/ogl"
	"honnef.co/go/wayfarer/wayland"
)

type Server struct {
	Display    *wayland.Display
	Compositor wayland.Compositor
}

func getProcAddr(name string) unsafe.Pointer {
	c := C.CString(name)
	defer C.free(unsafe.Pointer(c))
	return unsafe.Pointer(egl.GetProcAddress((*int8)(unsafe.Pointer(c))))
}

func eglBindWaylandDisplayWL(dpy egl.EGLDisplay, display *C.struct_wl_display) bool {
	return C.eglBindWaylandDisplayWL(gpBindWaylandDisplayWL, C.EGLDisplay(dpy), display) == egl.TRUE
}

var (
	gpBindWaylandDisplayWL C.PFNEGLBINDWAYLANDDISPLAYWL
)

const (
	stateBuffer = 1 << iota
	stateFrameCallback
)

type surfaceState struct {
	changed       uint
	buffer        *wayland.Buffer
	frameCallback *wayland.Callback
}

type mockSurface struct {
	comp     *mockCompositor
	toplevel *mockToplevel

	state   surfaceState
	pending surfaceState
}

func (*mockSurface) Destroy(client *wayland.Client) {}
func (surface *mockSurface) Attach(client *wayland.Client, buffer *wayland.Buffer, x, y int32) {
	// TODO handle x, y
	surface.pending.buffer = buffer
	surface.pending.changed |= stateBuffer
}
func (surface *mockSurface) Damage(client *wayland.Client, x, y, width, height int32) {
	surface.comp.graphicsBackend.DamageSurface(surface)
}
func (surface *mockSurface) Frame(client *wayland.Client, callback *wayland.Callback) {
	surface.pending.frameCallback = callback
	surface.pending.changed |= stateFrameCallback
}
func (*mockSurface) SetOpaqueRegion(client *wayland.Client, region wayland.Region) {}
func (*mockSurface) SetInputRegion(client *wayland.Client, region wayland.Region)  {}
func (surface *mockSurface) Commit(client *wayland.Client) {
	if (surface.pending.changed & stateBuffer) != 0 {
		if surface.state.buffer != nil {
			surface.state.buffer.Release()
		}
		surface.state.buffer = surface.pending.buffer
	}
	if (surface.pending.changed & stateFrameCallback) != 0 {
		if surface.state.frameCallback != nil {
			surface.state.frameCallback.Destroy()
		}
		surface.state.frameCallback = surface.pending.frameCallback
	}
	surface.pending.changed = 0

	var width, height int

	client.XDGSurfaceSendConfigure(surface.toplevel.surface, 0)
	client.XDGToplevelSendConfigure(surface.toplevel, width, height, nil)
}
func (*mockSurface) SetBufferTransform(client *wayland.Client, transform int32) {}
func (*mockSurface) SetBufferScale(client *wayland.Client, scale int32)         {}

type mockCompositor struct {
	X *xgb.Conn

	shell  *mockShell
	wmBase *mockXdgWmBase
	seat   *mockSeat
	ddm    *mockDataDeviceManager

	outputs []*mockOutput

	graphicsBackend *XGraphicsBackend
}

func (*mockCompositor) Bind(client *wayland.Client, version uint32) {}

func (comp *mockCompositor) CreateSurface(client *wayland.Client, id wayland.ObjectID) wayland.Surface {
	surface := &mockSurface{comp: comp}
	comp.graphicsBackend.AddSurface(surface)
	return surface
}

func (comp *mockCompositor) CreateRegion(client *wayland.Client, id wayland.ObjectID) wayland.Region {
	return &mockRegion{comp: comp}
}

type mockRegion struct {
	comp *mockCompositor
}

func (*mockRegion) Destroy(client *wayland.Client)                             {}
func (*mockRegion) Add(client *wayland.Client, x, y, width, height int32)      {}
func (*mockRegion) Subtract(client *wayland.Client, x, y, width, height int32) {}

type mockShell struct {
	comp *mockCompositor
}

func (*mockShell) Bind(client *wayland.Client, version uint32) {}

func (*mockShell) GetShellSurface(client *wayland.Client, id wayland.ObjectID, surface wayland.Surface) {
	fmt.Println("GetShellSurface")
}

type mockXdgWmBase struct {
	comp *mockCompositor
}

func (*mockXdgWmBase) Bind(client *wayland.Client, version uint32) {}
func (*mockXdgWmBase) Destroy(client *wayland.Client)              {}
func (*mockXdgWmBase) CreatePositioner(client *wayland.Client, id wayland.ObjectID) wayland.XDGPositioner {
	return nil
}
func (*mockXdgWmBase) GetXDGSurface(client *wayland.Client, id wayland.ObjectID, surface wayland.Surface) wayland.XDGSurface {
	return &mockXDGSurface{surface.(*mockSurface)}
}
func (*mockXdgWmBase) Pong(client *wayland.Client, serial uint32) {}

type mockXDGSurface struct {
	surface *mockSurface
}

// wl_surface_send_enter(struct wl_resource *resource_, struct wl_resource *output)

func (*mockXDGSurface) Destroy(client *wayland.Client) {}
func (surface *mockXDGSurface) GetToplevel(client *wayland.Client, id wayland.ObjectID) wayland.XDGToplevel {
	obj := &mockToplevel{surface: surface}
	surface.surface.toplevel = obj
	return obj
}
func (*mockXDGSurface) GetPopup(client *wayland.Client, id wayland.ObjectID, parent *wayland.Resource, positioner wayland.XDGPositioner) {
}
func (*mockXDGSurface) SetWindowGeometry(client *wayland.Client, x, y, width, height int32) {}
func (*mockXDGSurface) AckConfigure(client *wayland.Client, serial uint32)                  {}

type mockSeat struct {
	comp *mockCompositor
}

func (seat *mockSeat) Bind(client *wayland.Client, version uint32) {
	// C.wl_seat_send_capabilities(client.getResource(seat), C.WL_SEAT_CAPABILITY_KEYBOARD|C.WL_SEAT_CAPABILITY_POINTER)
	client.SeatSendCapabilities(seat, 0)
	client.SeatSendName(seat, "default")
}

func (seat *mockSeat) GetTouch(client *wayland.Client, id wayland.ObjectID) wayland.Touch { return nil }
func (seat *mockSeat) GetKeyboard(client *wayland.Client, id wayland.ObjectID) wayland.Keyboard {
	return nil
}
func (seat *mockSeat) GetPointer(client *wayland.Client, id wayland.ObjectID) wayland.Pointer {
	return nil
}
func (seat *mockSeat) Release(client *wayland.Client) {}

type mockToplevel struct {
	surface *mockXDGSurface
}

func (*mockToplevel) Destroy(client *wayland.Client)                             {}
func (*mockToplevel) SetParent(client *wayland.Client, parent *wayland.Resource) {}
func (*mockToplevel) SetTitle(client *wayland.Client, title string)              {}
func (*mockToplevel) SetAppID(client *wayland.Client, app_id string)             {}
func (*mockToplevel) ShowWindowMenu(client *wayland.Client, seat wayland.Seat, serial uint32, x, y int32) {
}
func (*mockToplevel) Move(client *wayland.Client, seat wayland.Seat, serial uint32)                 {}
func (*mockToplevel) Resize(client *wayland.Client, seat wayland.Seat, serial uint32, edges uint32) {}
func (*mockToplevel) SetMaxSize(client *wayland.Client, width, height int32)                        {}
func (*mockToplevel) SetMinSize(client *wayland.Client, width, height int32)                        {}
func (*mockToplevel) SetMaximized(client *wayland.Client)                                           {}
func (*mockToplevel) UnsetMaximized(client *wayland.Client)                                         {}
func (*mockToplevel) SetFullscreen(client *wayland.Client, output *wayland.Resource)                {}
func (*mockToplevel) UnsetFullscreen(client *wayland.Client)                                        {}
func (*mockToplevel) SetMinimized(client *wayland.Client)                                           {}

type mockOutput struct{}

func (output *mockOutput) Bind(client *wayland.Client, version uint32) {
	const make = "A monitor"
	client.OutputSendGeometry(output, 0, 0, 301, 170, 0, make, make, 0)
	client.OutputSendMode(output, 0x1|0x2, 1920, 1080, 60000)
	client.OutputSendDone(output)
}

func (*mockOutput) Release(client *wayland.Client) {}

type mockDataDeviceManager struct {
	comp *mockCompositor
}

func (*mockDataDeviceManager) Bind(client *wayland.Client, version uint32) {}
func (*mockDataDeviceManager) CreateDataSource(client *wayland.Client, id wayland.ObjectID) wayland.DataSource {
	return nil
}
func (*mockDataDeviceManager) GetDataDevice(client *wayland.Client, id wayland.ObjectID, seat wayland.Seat) wayland.DataDevice {
	return nil
}

func main() {
	go http.ListenAndServe("localhost:6060", nil)

	{
		egl.Init()
		gl.Init()
		var kms Backend = &KMS{DevicePath: "/dev/dri/card0"}
		must(kms.Initialize())
		out := kms.Outputs()[0]
		kms.SetOutputMode(out, out.Modes()[0])

		if !egl.MakeCurrent(kms.Display(), out.Surface(), out.Surface(), kms.Context()) {
			log.Fatal("could not make EGL context current")
		}
		ogl.EnableGLDebugLogging()

		gl.ClearColor(1.0, 0.0, 0.0, 1.0)
		gl.Clear(gl.COLOR_BUFFER_BIT)
		out.RenderFrame()
		for {
		}
	}

	// egl.Init()
	// gpBindWaylandDisplayWL = C.PFNEGLBINDWAYLANDDISPLAYWL(getProcAddr("eglBindWaylandDisplayWL"))

	wldpy, err := wayland.NewDisplay()
	if err != nil {
		log.Fatal(err)
	}

	socket, ok := wldpy.AddSocketAuto()
	if !ok {
		log.Fatal("couldn't create socket")
	}
	fmt.Println(socket)

	X, err := xgb.NewConn()
	if err != nil {
		log.Fatal(err)
	}

	backend, err := NewXGraphicsBackend()
	if err != nil {
		log.Fatal(err)
	}
	comp := &mockCompositor{
		X:               X,
		graphicsBackend: backend,
	}

	shell := &mockShell{comp: comp}
	xdgWmBase := &mockXdgWmBase{comp: comp}
	seat := &mockSeat{comp: comp}
	ddm := &mockDataDeviceManager{comp: comp}
	out := &mockOutput{}

	comp.shell = shell
	comp.wmBase = xdgWmBase
	comp.seat = seat
	comp.ddm = ddm
	comp.outputs = append(comp.outputs, out)

	wldpy.CreateCompositorGlobal(comp)
	wldpy.CreateShellGlobal(comp.shell)
	wldpy.CreateXdgWmBaseGlobal(comp.wmBase)
	wldpy.CreateSeatGlobal(comp.seat)
	wldpy.CreateDataDeviceManagerGlobal(comp.ddm)
	wldpy.CreateOutputGlobal(out)
	// eglBindWaylandDisplayWL(edpy, wldpy.dpy)
	wldpy.InitShm()

	evloop := wldpy.EventLoop()
	for {
		evloop.Dispatch(0)
		wldpy.FlushClients()
		backend.Render()
	}

	// EGL_WL_bind_wayland_display

	/* The extension has a setup step where you have to bind the EGL
	display to a Wayland display. Then as the compositor receives generic
	Wayland buffers from the clients (typically when the client calls
	eglSwapBuffers), it will be able to pass the struct wl_buffer pointer
	to eglCreateImageKHR as the EGLClientBuffer argument and with
	EGL_WAYLAND_BUFFER_WL as the target. This will create an EGLImage,
	which can then be used by the compositor as a texture or passed to
	the modesetting code to use as an overlay plane. Again, this is
	implemented by the vendor specific protocol extension, which on the
	server side will receive the driver specific details about the shared
	buffer and turn that into an EGL image when the user calls
	eglCreateImageKHR. */

}

type Backend interface {
	Initialize() error
	Destroy()
	Outputs() []Output
	SetOutputMode(Output, Mode) error
	Context() egl.EGLContext
	Display() egl.EGLDisplay
}

type Mode interface {
	Width() uint32
	Height() uint32
}

type Output interface {
	Modes() []Mode
	Surface() egl.EGLSurface
	RenderFrame()
}
