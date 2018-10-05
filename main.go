package main

// #cgo pkg-config: wayland-server
// #include <EGL/egl.h>
// #include <wayland-server.h>
// #include <stdlib.h>
// #include "xdg_shell_server.h"
// #include "wayfarer.h"
// typedef EGLBoolean (EGLAPIENTRYP PFNEGLBINDWAYLANDDISPLAYWL) (EGLDisplay dpy, struct wl_display *display);
// static EGLBoolean eglBindWaylandDisplayWL(PFNEGLBINDWAYLANDDISPLAYWL fnptr, EGLDisplay dpy, struct wl_display *display) {
//   return (*fnptr)(dpy, display);
// }
import "C"
import (
	"errors"
	"fmt"
	"log"
	"time"
	"unsafe"

	"github.com/BurntSushi/xgb"
	"honnef.co/go/egl"
)

type ObjectID uint32

type Server struct {
	Display    *Display
	Compositor Compositor
}

type Display struct {
	dpy *C.struct_wl_display
}

func NewDisplay() (*Display, error) {
	dpy := C.wl_display_create()
	if dpy == nil {
		return nil, errors.New("could not create Wayland display")
	}
	return &Display{
		dpy: dpy,
	}, nil
}

func (dpy *Display) Run() { C.wl_display_run(dpy.dpy) }

func (dpy *Display) Destroy() {
	C.wl_display_destroy(dpy.dpy)
	dpy.dpy = nil
}

func (dpy *Display) Serial() uint32     { return uint32(C.wl_display_get_serial(dpy.dpy)) }
func (dpy *Display) NextSerial() uint32 { return uint32(C.wl_display_next_serial(dpy.dpy)) }
func (dpy *Display) DestroyClients()    { C.wl_display_destroy_clients(dpy.dpy) }

func (dpy *Display) AddSocketFd(fd int) (ok bool) {
	return C.wl_display_add_socket_fd(dpy.dpy, C.int(fd)) == 0
}

func (dpy *Display) AddSocket(path string) (ok bool) {
	var cPath *C.char
	if path != "" {
		cPath = C.CString(path)
		defer C.free(unsafe.Pointer(cPath))
	}
	return C.wl_display_add_socket(dpy.dpy, cPath) == 0
}

func (dpy *Display) AddSocketAuto() (string, bool) {
	c := C.wl_display_add_socket_auto(dpy.dpy)
	if c == nil {
		return "", false
	}
	return C.GoString(c), true
}

func (dpy *Display) AddShmFormat(format uint32) *uint32 {
	return (*uint32)(C.wl_display_add_shm_format(dpy.dpy, C.uint32_t(format)))
}

type EventLoop struct {
	evloop *C.struct_wl_event_loop
}

func NewEventLoop() *EventLoop { return &EventLoop{evloop: C.wl_event_loop_create()} }
func (evloop *EventLoop) Destroy() {
	C.wl_event_loop_destroy(evloop.evloop)
	evloop.evloop = nil
}
func (evloop *EventLoop) DispatchIdle() { C.wl_event_loop_dispatch_idle(evloop.evloop) }
func (evloop *EventLoop) Dispatch(timeout time.Duration) (ok bool) {
	return C.wl_event_loop_dispatch(evloop.evloop, C.int(timeout/time.Millisecond)) == 0
}
func (evloop *EventLoop) Fd() int { return int(C.wl_event_loop_get_fd(evloop.evloop)) }

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

func (dpy *Display) CreateCompositorGlobal(comp Compositor) {
	data := addGlobal(comp)
	C.wl_global_create(dpy.dpy, &C.wl_compositor_interface, 1, unsafe.Pointer(data), (*[0]byte)(C.wayfarerCompositorBind))
}

func (dpy *Display) CreateShellGlobal(shell Shell) {
	data := addGlobal(shell)
	C.wl_global_create(dpy.dpy, &C.wl_shell_interface, 1, unsafe.Pointer(data), (*[0]byte)(C.wayfarerShellBind))
}

func (dpy *Display) CreateXdgWmBaseGlobal(shell XdgWmBase) {
	data := addGlobal(shell)
	C.wl_global_create(dpy.dpy, &C.xdg_wm_base_interface, 2, unsafe.Pointer(data), (*[0]byte)(C.wayfarerXdgWmBaseBind))
}

func (dpy *Display) CreateSeatGlobal(seat Seat) {
	data := addGlobal(seat)
	C.wl_global_create(dpy.dpy, &C.wl_seat_interface, 5, unsafe.Pointer(data), (*[0]byte)(C.wayfarerSeatBind))
}

func (dpy *Display) CreateDataDeviceManagerGlobal(ddm DataDeviceManager) {
	data := addGlobal(ddm)
	C.wl_global_create(dpy.dpy, &C.wl_data_device_manager_interface, 1, unsafe.Pointer(data), (*[0]byte)(C.wayfarerDataDeviceManagerBind))
}

func (dpy *Display) CreateOutputGlobal(output Output) {
	data := addGlobal(output)
	C.wl_global_create(dpy.dpy, &C.wl_output_interface, 2, unsafe.Pointer(data), (*[0]byte)(C.wayfarerOutputBind))
}

const (
	stateBuffer = 1 << iota
	stateFrameCallback
)

type surfaceState struct {
	changed       uint
	buffer        *C.struct_wl_resource
	frameCallback *C.struct_wl_resource
}

type mockSurface struct {
	comp     *mockCompositor
	toplevel *mockToplevel

	state   surfaceState
	pending surfaceState
}

func (*mockSurface) Destroy(client *Client) {}
func (surface *mockSurface) Attach(client *Client, buffer *C.struct_wl_resource, x, y int32) {
	// TODO handle x, y
	surface.pending.buffer = buffer
	surface.pending.changed |= stateBuffer
}
func (*mockSurface) Damage(client *Client, x, y, width, height int32) {}
func (surface *mockSurface) Frame(client *Client, callback *C.struct_wl_resource) {
	surface.pending.frameCallback = callback
	surface.pending.changed |= stateFrameCallback
}
func (*mockSurface) SetOpaqueRegion(client *Client, region Region) {}
func (*mockSurface) SetInputRegion(client *Client, region Region)  {}
func (surface *mockSurface) Commit(client *Client) {
	if (surface.pending.changed & stateBuffer) != 0 {
		if surface.state.buffer != nil {
			C.wl_buffer_send_release(surface.state.buffer)
		}
		surface.state.buffer = surface.pending.buffer
	}
	if (surface.pending.changed & stateFrameCallback) != 0 {
		if surface.state.frameCallback != nil {
			C.wl_resource_destroy(surface.state.frameCallback)
		}
		surface.state.frameCallback = surface.pending.frameCallback
	}
	surface.pending.changed = 0

	var width, height C.int32_t
	if surface.state.buffer != nil {
		surface.comp.graphicsBackend.Surfaces = []*mockSurface{surface}
	}

	array := (*C.struct_wl_array)(C.malloc(C.ulong(unsafe.Sizeof(C.struct_wl_array{}))))
	C.wl_array_init(array)
	C.xdg_surface_send_configure(client.getResource(surface.toplevel.surface), 0)
	C.xdg_toplevel_send_configure(client.getResource(surface.toplevel), width, height, array)
	C.wl_array_release(array)
	// C.wl_surface_send_enter(client.getResource(surface), client.getResource(surface.comp.outputs[0]))
}
func (*mockSurface) SetBufferTransform(client *Client, transform int32) {}
func (*mockSurface) SetBufferScale(client *Client, scale int32)         {}

type mockCompositor struct {
	X *xgb.Conn

	shell  *mockShell
	wmBase *mockXdgWmBase
	seat   *mockSeat
	ddm    *mockDataDeviceManager

	outputs []*mockOutput

	graphicsBackend *XGraphicsBackend
}

func (*mockCompositor) Bind(client *Client, version uint32) {}

func (comp *mockCompositor) CreateSurface(client *Client, id ObjectID) Surface {
	return &mockSurface{comp: comp}
}

func (comp *mockCompositor) CreateRegion(client *Client, id ObjectID) Region {
	return &mockRegion{comp: comp}
}

type mockRegion struct {
	comp *mockCompositor
}

func (*mockRegion) Destroy(client *Client)                             {}
func (*mockRegion) Add(client *Client, x, y, width, height int32)      {}
func (*mockRegion) Subtract(client *Client, x, y, width, height int32) {}

type mockShell struct {
	comp *mockCompositor
}

func (*mockShell) Bind(client *Client, version uint32) {}

func (*mockShell) GetShellSurface(client *Client, id ObjectID, surface Surface) {
	fmt.Println("GetShellSurface")
}

type mockXdgWmBase struct {
	comp *mockCompositor
}

func (*mockXdgWmBase) Bind(client *Client, version uint32) {}
func (*mockXdgWmBase) Destroy(client *Client)              {}
func (*mockXdgWmBase) CreatePositioner(client *Client, id ObjectID) XDGPositioner {
	return nil
}
func (*mockXdgWmBase) GetXDGSurface(client *Client, id ObjectID, surface Surface) XDGSurface {
	return &mockXDGSurface{surface.(*mockSurface)}
}
func (*mockXdgWmBase) Pong(client *Client, serial uint32) {}

type mockXDGSurface struct {
	surface *mockSurface
}

// wl_surface_send_enter(struct wl_resource *resource_, struct wl_resource *output)

func (*mockXDGSurface) Destroy(client *Client) {}
func (surface *mockXDGSurface) GetToplevel(client *Client, id ObjectID) XDGToplevel {
	obj := &mockToplevel{surface: surface}
	surface.surface.toplevel = obj
	return obj
}
func (*mockXDGSurface) GetPopup(client *Client, id ObjectID, parent *C.struct_wl_resource, positioner XDGPositioner) {
}
func (*mockXDGSurface) SetWindowGeometry(client *Client, x, y, width, height int32) {}
func (*mockXDGSurface) AckConfigure(client *Client, serial uint32)                  {}

type mockSeat struct {
	comp *mockCompositor
}

func (seat *mockSeat) Bind(client *Client, version uint32) {
	name := C.CString("default")
	defer C.free(unsafe.Pointer(name))
	// C.wl_seat_send_capabilities(client.getResource(seat), C.WL_SEAT_CAPABILITY_KEYBOARD|C.WL_SEAT_CAPABILITY_POINTER)
	C.wl_seat_send_capabilities(client.getResource(seat), 0)
	C.wl_seat_send_name(client.getResource(seat), name)
}

func (seat *mockSeat) GetTouch(client *Client, id ObjectID) Touch       { return nil }
func (seat *mockSeat) GetKeyboard(client *Client, id ObjectID) Keyboard { return nil }
func (seat *mockSeat) GetPointer(client *Client, id ObjectID) Pointer   { return nil }
func (seat *mockSeat) Release(client *Client)                           {}

type mockToplevel struct {
	surface *mockXDGSurface
}

func (*mockToplevel) Destroy(client *Client)                                 {}
func (*mockToplevel) SetParent(client *Client, parent *C.struct_wl_resource) {}
func (*mockToplevel) SetTitle(client *Client, title string)                  {}
func (*mockToplevel) SetAppID(client *Client, app_id string)                 {}
func (*mockToplevel) ShowWindowMenu(client *Client, seat Seat, serial uint32, x, y int32) {
}
func (*mockToplevel) Move(client *Client, seat Seat, serial uint32)                 {}
func (*mockToplevel) Resize(client *Client, seat Seat, serial uint32, edges uint32) {}
func (*mockToplevel) SetMaxSize(client *Client, width, height int32)                {}
func (*mockToplevel) SetMinSize(client *Client, width, height int32)                {}
func (*mockToplevel) SetMaximized(client *Client)                                   {}
func (*mockToplevel) UnsetMaximized(client *Client)                                 {}
func (*mockToplevel) SetFullscreen(client *Client, output *C.struct_wl_resource)    {}
func (*mockToplevel) UnsetFullscreen(client *Client)                                {}
func (*mockToplevel) SetMinimized(client *Client)                                   {}

type mockOutput struct {
}

func (output *mockOutput) Bind(client *Client, version uint32) {
	fmt.Println("bind mockOutput")
	make := C.CString("A monitor")
	res := client.getResource(output)
	C.wl_output_send_geometry(res, 0, 0, 301, 170, 0, make, make, 0)
	C.wl_output_send_mode(res, 0x1|0x2, 1920, 1080, 60000)
	C.free(unsafe.Pointer(make))
	C.wl_output_send_done(res)
}

func (*mockOutput) Release(client *Client) {}

type mockDataDeviceManager struct {
	comp *mockCompositor
}

func (*mockDataDeviceManager) Bind(client *Client, version uint32)                     {}
func (*mockDataDeviceManager) CreateDataSource(client *Client, id ObjectID) DataSource { return nil }
func (*mockDataDeviceManager) GetDataDevice(client *Client, id ObjectID, seat Seat) DataDevice {
	return nil
}

func main() {
	// egl.Init()
	// gpBindWaylandDisplayWL = C.PFNEGLBINDWAYLANDDISPLAYWL(getProcAddr("eglBindWaylandDisplayWL"))

	wldpy, err := NewDisplay()
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
	C.wl_display_init_shm(wldpy.dpy)

	evloop := C.wl_display_get_event_loop(wldpy.dpy)
	for {
		C.wl_event_loop_dispatch(evloop, 0)
		C.wl_display_flush_clients(wldpy.dpy)
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
