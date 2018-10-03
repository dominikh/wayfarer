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
	data := addObject(comp)
	C.wl_global_create(dpy.dpy, &C.wl_compositor_interface, 3, unsafe.Pointer(data), (*[0]byte)(C.wayfarerCompositorBind))
}

func (dpy *Display) CreateShellGlobal(shell Shell) {
	data := addObject(shell)
	C.wl_global_create(dpy.dpy, &C.wl_shell_interface, 1, unsafe.Pointer(data), (*[0]byte)(C.wayfarerShellBind))
}

func (dpy *Display) CreateXdgWmBaseGlobal(shell XdgWmBase) {
	data := addObject(shell)
	C.wl_global_create(dpy.dpy, &C.xdg_wm_base_interface, 2, unsafe.Pointer(data), (*[0]byte)(C.wayfarerXdgWmBaseBind))
}

func (dpy *Display) CreateSeatGlobal(seat Seat) {
	data := addObject(seat)
	C.wl_global_create(dpy.dpy, &C.wl_seat_interface, 1, unsafe.Pointer(data), (*[0]byte)(C.wayfarerSeatBind))
}

type mockSurface struct{}

func (mockSurface) Destroy(client *C.struct_wl_client)                             {}
func (mockSurface) Attach(client *C.struct_wl_client, buffer Buffer, x, y int32)   {}
func (mockSurface) Damage(client *C.struct_wl_client, x, y, width, height int32)   {}
func (mockSurface) Frame(client *C.struct_wl_client, callback uint32)              {}
func (mockSurface) SetOpaqueRegion(client *C.struct_wl_client, region Region)      {}
func (mockSurface) SetInputRegion(client *C.struct_wl_client, region Region)       {}
func (mockSurface) Commit(client *C.struct_wl_client)                              {}
func (mockSurface) SetBufferTransform(client *C.struct_wl_client, transform int32) {}
func (mockSurface) SetBufferScale(client *C.struct_wl_client, scale int32)         {}

type mockCompositor struct{}

func (mockCompositor) CreateSurface(client *C.struct_wl_client, id ObjectID) Surface {
	fmt.Println("CreateSurface")
	return mockSurface{}
}

func (mockCompositor) CreateRegion(client *C.struct_wl_client, id ObjectID) Region {
	fmt.Println("CreateRegion")
	return nil
}

type mockShell struct{}

func (mockShell) GetShellSurface(client *C.struct_wl_client, id ObjectID, surface Surface) {
	fmt.Println("GetShellSurface")
}

type mockXdgWmBase struct{}

func (mockXdgWmBase) Destroy(client *C.struct_wl_client) {}
func (mockXdgWmBase) CreatePositioner(client *C.struct_wl_client, id ObjectID) XDGPositioner {
	return nil
}
func (mockXdgWmBase) GetXDGSurface(client *C.struct_wl_client, id ObjectID, surface Surface) XDGSurface {
	return mockXDGSurface{}
}
func (mockXdgWmBase) Pong(client *C.struct_wl_client, serial uint32) {}

type mockXDGSurface struct{}

func (mockXDGSurface) Destroy(client *C.struct_wl_client) {}
func (mockXDGSurface) GetToplevel(client *C.struct_wl_client, id ObjectID) XDGToplevel {
	return mockToplevel{}
}
func (mockXDGSurface) GetPopup(client *C.struct_wl_client, id ObjectID, parent *C.struct_wl_resource, positioner XDGPositioner) {
}
func (mockXDGSurface) SetWindowGeometry(client *C.struct_wl_client, x, y, width, height int32) {}
func (mockXDGSurface) AckConfigure(client *C.struct_wl_client, serial uint32)                  {}

type mockSeat struct{}

type mockToplevel struct{}

func (mockToplevel) Destroy(client *C.struct_wl_client)                                              {}
func (mockToplevel) SetParent(client *C.struct_wl_client, parent *C.struct_wl_resource)              {}
func (mockToplevel) SetTitle(client *C.struct_wl_client, title string)                               {}
func (mockToplevel) SetAppID(client *C.struct_wl_client, app_id string)                              {}
func (mockToplevel) ShowWindowMenu(client *C.struct_wl_client, seat Seat, serial uint32, x, y int32) {}
func (mockToplevel) Move(client *C.struct_wl_client, seat Seat, serial uint32)                       {}
func (mockToplevel) Resize(client *C.struct_wl_client, seat Seat, serial uint32, edges uint32)       {}
func (mockToplevel) SetMaxSize(client *C.struct_wl_client, width, height int32)                      {}
func (mockToplevel) SetMinSize(client *C.struct_wl_client, width, height int32)                      {}
func (mockToplevel) SetMaximized(client *C.struct_wl_client)                                         {}
func (mockToplevel) UnsetMaximized(client *C.struct_wl_client)                                       {}
func (mockToplevel) SetFullscreen(client *C.struct_wl_client, output *C.struct_wl_resource)          {}
func (mockToplevel) UnsetFullscreen(client *C.struct_wl_client)                                      {}
func (mockToplevel) SetMinimized(client *C.struct_wl_client)                                         {}

func main() {
	// egl.Init()
	// gpBindWaylandDisplayWL = C.PFNEGLBINDWAYLANDDISPLAYWL(getProcAddr("eglBindWaylandDisplayWL"))

	wldpy, err := NewDisplay()
	if err != nil {
		log.Fatal(err)
	}
	// edpy := egl.GetDisplay(nil)
	// egl.Initialize(edpy, nil, nil)

	socket, ok := wldpy.AddSocketAuto()
	if !ok {
		log.Fatal("couldn't create socket")
	}
	fmt.Println(socket)

	wldpy.CreateCompositorGlobal(mockCompositor{})
	wldpy.CreateShellGlobal(mockShell{})
	wldpy.CreateXdgWmBaseGlobal(mockXdgWmBase{})
	wldpy.CreateSeatGlobal(mockSeat{})
	// eglBindWaylandDisplayWL(edpy, wldpy.dpy)
	C.wl_display_init_shm(wldpy.dpy)

	evloop := C.wl_display_get_event_loop(wldpy.dpy)
	for {
		C.wl_event_loop_dispatch(evloop, -1)
		C.wl_display_flush_clients(wldpy.dpy)
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
