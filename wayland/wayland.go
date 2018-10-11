package wayland

// #cgo pkg-config: wayland-server
// #include <wayland-server.h>
// #include <stdlib.h>
// #include "wayfarer.h"
import "C"
import (
	"errors"
	"time"
	"unsafe"
)

var (
	CompositorInterface        = &C.wl_compositor_interface
	ShellInterface             = &C.wl_shell_interface
	SeatInterface              = &C.wl_seat_interface
	DataDeviceManagerInterface = &C.wl_data_device_manager_interface
	OutputInterface            = &C.wl_output_interface
)

type ObjectID uint32

type Display struct {
	dpy *C.struct_wl_display
}

func (dpy *Display) CreateGlobal(obj Global, iface *C.struct_wl_interface, version int, fntable unsafe.Pointer) {
	data := addGlobal(obj)
	C.wl_global_create(dpy.dpy, iface, 1, unsafe.Pointer(data), (*[0]byte)(fntable))
}

func (dpy *Display) CreateCompositorGlobal(comp Compositor) {
	dpy.CreateGlobal(comp, CompositorInterface, 1, C.wayfarerCompositorBind)
}

func (dpy *Display) CreateShellGlobal(shell Shell) {
	dpy.CreateGlobal(shell, ShellInterface, 1, C.wayfarerShellBind)
}

func (dpy *Display) CreateSeatGlobal(seat Seat) {
	dpy.CreateGlobal(seat, SeatInterface, 5, C.wayfarerSeatBind)
}

func (dpy *Display) CreateDataDeviceManagerGlobal(ddm DataDeviceManager) {
	dpy.CreateGlobal(ddm, DataDeviceManagerInterface, 1, C.wayfarerDataDeviceManagerBind)
}

func (dpy *Display) CreateOutputGlobal(output Output) {
	dpy.CreateGlobal(output, OutputInterface, 2, C.wayfarerOutputBind)
}

func (dpy *Display) InitShm() {
	C.wl_display_init_shm(dpy.dpy)
}

func (dpy *Display) EventLoop() *EventLoop {
	return &EventLoop{C.wl_display_get_event_loop(dpy.dpy)}
}

func (dpy *Display) FlushClients() {
	C.wl_display_flush_clients(dpy.dpy)
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

type Buffer struct {
	res *Resource
}

func (buf *Buffer) Release() {
	C.wl_buffer_send_release(buf.res.res)
	buf.res = nil
}

type Callback struct {
	res *Resource
}

func (cb *Callback) SendDone(ts time.Time) {
	C.wl_callback_send_done(cb.res.res, C.uint(ts.UnixNano()/1e6))
}

func (cb *Callback) Destroy() {
	cb.res.Destroy()
}

type Resource struct {
	res *C.struct_wl_resource
}

func (res *Resource) Destroy() {
	C.wl_resource_destroy(res.res)
}

type Global interface {
	Bind(client *Client, version uint32)
}

type Compositor interface {
	Global

	CreateSurface(client *Client, id ObjectID) Surface
	CreateRegion(client *Client, id ObjectID) Region
}

type Shell interface {
	Global

	GetShellSurface(client *Client, id ObjectID, surface Surface)
}

type Seat interface {
	Global

	GetTouch(client *Client, id ObjectID) Touch
	GetKeyboard(client *Client, id ObjectID) Keyboard
	GetPointer(client *Client, id ObjectID) Pointer
	Release(client *Client)
}

type Touch interface{}
type Keyboard interface{}
type Pointer interface{}

type DataDeviceManager interface {
	Global

	CreateDataSource(client *Client, id ObjectID) DataSource
	GetDataDevice(client *Client, id ObjectID, seat Seat) DataDevice
}

type DataDevice interface {
	StartDrag(client *Client, source, origin, icon *Resource, serial uint32)
	SetSelection(client *Client, source *Resource, serial uint32)
	Release(client *Client)
}

type DataSource interface {
	Offer(client *Client, mime_type string)
	Destroy(client *Client)
	SetActions(client *Client, dnd_actions uint32)
}

type Output interface {
	Global

	Release(client *Client)
}

type Surface interface {
	Destroy(client *Client)
	Attach(client *Client, buffer *Buffer, x, y int32)
	Damage(client *Client, x, y, width, height int32)
	Frame(client *Client, callback *Callback)
	SetOpaqueRegion(client *Client, region Region)
	SetInputRegion(client *Client, region Region)
	Commit(client *Client)
	SetBufferTransform(client *Client, transform int32)
	SetBufferScale(client *Client, scale int32)
	// DamageBuffer()
}

type Region interface {
	Destroy(client *Client)
	Add(client *Client, x, y, width, height int32)
	Subtract(client *Client, x, y, width, height int32)
}

type Client struct {
	Client     *C.struct_wl_client
	objects    map[uint32]interface{}
	invObjects map[interface{}]*C.struct_wl_resource
}

var clients = map[*C.struct_wl_client]*Client{}

func getClient(client *C.struct_wl_client) *Client {
	c, ok := clients[client]
	if !ok {
		c = &Client{
			Client:     client,
			objects:    map[uint32]interface{}{},
			invObjects: map[interface{}]*C.struct_wl_resource{},
		}
		clients[client] = c
	}
	return c
}

func (c *Client) SeatSendCapabilities(seat Seat, cap uint) {
	C.wl_seat_send_capabilities(c.getResource(seat), C.uint(cap))
}

func (c *Client) SeatSendName(seat Seat, name string) {
	cName := C.CString(name)
	defer C.free(unsafe.Pointer(cName))
	C.wl_seat_send_name(c.getResource(seat), cName)
}

func (c *Client) OutputSendGeometry(output Output, x, y, physWidth, physHeight, subpixel int32, make, model string, transform int32) {
	cMake := C.CString(make)
	cModel := C.CString(model)
	defer C.free(unsafe.Pointer(cMake))
	defer C.free(unsafe.Pointer(cModel))
	C.wl_output_send_geometry(
		c.getResource(output),
		C.int32_t(x),
		C.int32_t(y),
		C.int32_t(physWidth),
		C.int32_t(physHeight),
		C.int32_t(subpixel),
		cMake,
		cModel,
		C.int32_t(transform))
}

func (c *Client) OutputSendMode(output Output, flags uint32, width, height, refresh int32) {
	C.wl_output_send_mode(c.getResource(output), C.uint32_t(flags), C.int32_t(width), C.int32_t(height), C.int32_t(refresh))
}

func (c *Client) OutputSendDone(output Output) {
	C.wl_output_send_done(c.getResource(output))
}

func (c *Client) getObject(id uint32) interface{} {
	return c.objects[id]
}

func (c *Client) getResource(obj interface{}) *C.struct_wl_resource {
	return c.invObjects[obj]
}

var globals = map[uintptr]Global{}

var idStart = uintptr(C.malloc(1e6))
var idEnd = idStart + 1e6 - 1
var idCur = idStart

func getGlobal(resource *C.struct_wl_resource) interface{} {
	return getGlobalData(uintptr(resource.data))
}

func getGlobalData(data uintptr) Global {
	return globals[data]
}

func addGlobal(obj Global) uintptr {
	idCur++
	globals[idCur] = obj
	return idCur
}

type SHMBuffer struct {
	buf *C.struct_wl_shm_buffer
}

func GetSHMBuffer(buf *Buffer) *SHMBuffer {
	return &SHMBuffer{C.wl_shm_buffer_get(buf.res.res)}
}

const (
	ARGB8888    = C.WL_SHM_FORMAT_ARGB8888
	XRGB8888    = C.WL_SHM_FORMAT_XRGB8888
	C8          = C.WL_SHM_FORMAT_C8
	RGB332      = C.WL_SHM_FORMAT_RGB332
	BGR233      = C.WL_SHM_FORMAT_BGR233
	XRGB4444    = C.WL_SHM_FORMAT_XRGB4444
	XBGR4444    = C.WL_SHM_FORMAT_XBGR4444
	RGBX4444    = C.WL_SHM_FORMAT_RGBX4444
	BGRX4444    = C.WL_SHM_FORMAT_BGRX4444
	ARGB4444    = C.WL_SHM_FORMAT_ARGB4444
	ABGR4444    = C.WL_SHM_FORMAT_ABGR4444
	RGBA4444    = C.WL_SHM_FORMAT_RGBA4444
	BGRA4444    = C.WL_SHM_FORMAT_BGRA4444
	XRGB1555    = C.WL_SHM_FORMAT_XRGB1555
	XBGR1555    = C.WL_SHM_FORMAT_XBGR1555
	RGBX5551    = C.WL_SHM_FORMAT_RGBX5551
	BGRX5551    = C.WL_SHM_FORMAT_BGRX5551
	ARGB1555    = C.WL_SHM_FORMAT_ARGB1555
	ABGR1555    = C.WL_SHM_FORMAT_ABGR1555
	RGBA5551    = C.WL_SHM_FORMAT_RGBA5551
	BGRA5551    = C.WL_SHM_FORMAT_BGRA5551
	RGB565      = C.WL_SHM_FORMAT_RGB565
	BGR565      = C.WL_SHM_FORMAT_BGR565
	RGB888      = C.WL_SHM_FORMAT_RGB888
	BGR888      = C.WL_SHM_FORMAT_BGR888
	XBGR8888    = C.WL_SHM_FORMAT_XBGR8888
	RGBX8888    = C.WL_SHM_FORMAT_RGBX8888
	BGRX8888    = C.WL_SHM_FORMAT_BGRX8888
	ABGR8888    = C.WL_SHM_FORMAT_ABGR8888
	RGBA8888    = C.WL_SHM_FORMAT_RGBA8888
	BGRA8888    = C.WL_SHM_FORMAT_BGRA8888
	XRGB2101010 = C.WL_SHM_FORMAT_XRGB2101010
	XBGR2101010 = C.WL_SHM_FORMAT_XBGR2101010
	RGBX1010102 = C.WL_SHM_FORMAT_RGBX1010102
	BGRX1010102 = C.WL_SHM_FORMAT_BGRX1010102
	ARGB2101010 = C.WL_SHM_FORMAT_ARGB2101010
	ABGR2101010 = C.WL_SHM_FORMAT_ABGR2101010
	RGBA1010102 = C.WL_SHM_FORMAT_RGBA1010102
	BGRA1010102 = C.WL_SHM_FORMAT_BGRA1010102
	YUYV        = C.WL_SHM_FORMAT_YUYV
	YVYU        = C.WL_SHM_FORMAT_YVYU
	UYVY        = C.WL_SHM_FORMAT_UYVY
	VYUY        = C.WL_SHM_FORMAT_VYUY
	AYUV        = C.WL_SHM_FORMAT_AYUV
	NV12        = C.WL_SHM_FORMAT_NV12
	NV21        = C.WL_SHM_FORMAT_NV21
	NV16        = C.WL_SHM_FORMAT_NV16
	NV61        = C.WL_SHM_FORMAT_NV61
	YUV410      = C.WL_SHM_FORMAT_YUV410
	YVU410      = C.WL_SHM_FORMAT_YVU410
	YUV411      = C.WL_SHM_FORMAT_YUV411
	YVU411      = C.WL_SHM_FORMAT_YVU411
	YUV420      = C.WL_SHM_FORMAT_YUV420
	YVU420      = C.WL_SHM_FORMAT_YVU420
	YUV422      = C.WL_SHM_FORMAT_YUV422
	YVU422      = C.WL_SHM_FORMAT_YVU422
	YUV444      = C.WL_SHM_FORMAT_YUV444
	YVU444      = C.WL_SHM_FORMAT_YVU444
)

func (buf *SHMBuffer) Data() unsafe.Pointer { return C.wl_shm_buffer_get_data(buf.buf) }
func (buf *SHMBuffer) Stride() int32        { return int32(C.wl_shm_buffer_get_stride(buf.buf)) }
func (buf *SHMBuffer) Format() uint32       { return uint32(C.wl_shm_buffer_get_format(buf.buf)) }
func (buf *SHMBuffer) Width() int32         { return int32(C.wl_shm_buffer_get_width(buf.buf)) }
func (buf *SHMBuffer) Height() int32        { return int32(C.wl_shm_buffer_get_height(buf.buf)) }

func (c *Client) addResource(iface *C.struct_wl_interface, version uint32, id uint32, impl unsafe.Pointer, obj interface{}) {
	c.objects[id] = obj
	res := C.wl_resource_create(c.Client, iface, C.int32_t(version), C.uint32_t(id))
	c.invObjects[obj] = res
	C.wl_resource_set_implementation(res, impl, nil, nil)
}

//export wayfarerCompositorCreateSurface
func wayfarerCompositorCreateSurface(client *C.struct_wl_client, resource *C.struct_wl_resource, id C.uint32_t) {
	gclient := getClient(client)
	comp := gclient.getObject(uint32(resource.object.id)).(Compositor)

	surface := comp.CreateSurface(gclient, ObjectID(id))
	gclient.addResource(&C.wl_surface_interface, 4, uint32(id), unsafe.Pointer(&C.wayfarerSurfaceInterface), surface)
}

//export wayfarerCompositorCreateRegion
func wayfarerCompositorCreateRegion(client *C.struct_wl_client, resource *C.struct_wl_resource, id C.uint32_t) {
	gclient := getClient(client)
	comp := gclient.getObject(uint32(resource.object.id)).(Compositor)

	region := comp.CreateRegion(gclient, ObjectID(id))
	gclient.addResource(&C.wl_region_interface, 1, uint32(id), unsafe.Pointer(&C.wayfarerRegionInterface), region)
}

//export wayfarerCompositorBind
func wayfarerCompositorBind(client *C.struct_wl_client, data unsafe.Pointer, version C.uint32_t, id C.uint32_t) {
	gclient := getClient(client)
	comp := getGlobalData(uintptr(data))
	gclient.addResource(&C.wl_compositor_interface, 1, uint32(id), unsafe.Pointer(&C.wayfarerCompositorInterface), comp)
}

//export wayfarerSeatGetPointer
func wayfarerSeatGetPointer(client *C.struct_wl_client, resource *C.struct_wl_resource, id C.uint32_t) {
	gclient := getClient(client)
	pointer := gclient.getObject(uint32(resource.object.id)).(Seat).GetPointer(gclient, ObjectID(id))
	gclient.addResource(&C.wl_pointer_interface, 5, uint32(id), unsafe.Pointer(&C.wayfarerPointerInterface), pointer)
}

//export wayfarerSeatGetKeyboard
func wayfarerSeatGetKeyboard(client *C.struct_wl_client, resource *C.struct_wl_resource, id C.uint32_t) {
	gclient := getClient(client)
	keyboard := gclient.getObject(uint32(resource.object.id)).(Seat).GetKeyboard(gclient, ObjectID(id))
	gclient.addResource(&C.wl_keyboard_interface, 5, uint32(id), unsafe.Pointer(&C.wayfarerKeyboardInterface), keyboard)
}

//export wayfarerSeatGetTouch
func wayfarerSeatGetTouch(client *C.struct_wl_client, resource *C.struct_wl_resource, id C.uint32_t) {
	gclient := getClient(client)
	touch := gclient.getObject(uint32(resource.object.id)).(Seat).GetTouch(gclient, ObjectID(id))
	gclient.addResource(&C.wl_touch_interface, 6, uint32(id), unsafe.Pointer(&C.wayfarerTouchInterface), touch)
}

//export wayfarerSeatRelease
func wayfarerSeatRelease(client *C.struct_wl_client, resource *C.struct_wl_resource) {
	gclient := getClient(client)
	gclient.getObject(uint32(resource.object.id)).(Seat).Release(gclient)
}

//export wayfarerDataDeviceManagerCreateDataSource
func wayfarerDataDeviceManagerCreateDataSource(client *C.struct_wl_client, resource *C.struct_wl_resource, id C.uint32_t) {
	gclient := getClient(client)
	ds := gclient.getObject(uint32(resource.object.id)).(DataDeviceManager).CreateDataSource(gclient, ObjectID(id))
	gclient.addResource(&C.wl_data_source_interface, 3, uint32(id), unsafe.Pointer(&C.wayfarerDataSourceInterface), ds)
}

//export wayfarerDataDeviceManagerGetDataDevice
func wayfarerDataDeviceManagerGetDataDevice(client *C.struct_wl_client, resource *C.struct_wl_resource, id C.uint32_t, seat *C.struct_wl_resource) {
	gclient := getClient(client)
	gseat := gclient.getObject(uint32(seat.object.id)).(Seat)
	device := gclient.getObject(uint32(resource.object.id)).(DataDeviceManager).GetDataDevice(gclient, ObjectID(id), gseat)
	gclient.addResource(&C.wl_data_device_interface, 2, uint32(id), unsafe.Pointer(&C.wayfarerDataDeviceInterface), device)
}

//export wayfarerDataDeviceManagerBind
func wayfarerDataDeviceManagerBind(client *C.struct_wl_client, data unsafe.Pointer, version C.uint32_t, id C.uint32_t) {
	gclient := getClient(client)
	ddm := getGlobalData(uintptr(data))
	gclient.addResource(&C.wl_data_device_manager_interface, 1, uint32(id), unsafe.Pointer(&C.wayfarerDataDeviceManagerInterface), ddm)
}

//export wayfarerDataDeviceStartDrag
func wayfarerDataDeviceStartDrag(client *C.struct_wl_client, resource *C.struct_wl_resource, source *C.struct_wl_resource, origin *C.struct_wl_resource, icon *C.struct_wl_resource, serial C.uint32_t) {
	panic("not implemented")
}

//export wayfarerDataDeviceSetSelection
func wayfarerDataDeviceSetSelection(client *C.struct_wl_client, resource *C.struct_wl_resource, source *C.struct_wl_resource, serial C.uint32_t) {
	panic("not implemented")
}

//export wayfarerDataDeviceRelease
func wayfarerDataDeviceRelease(client *C.struct_wl_client, resource *C.struct_wl_resource) {
	panic("not implemented")
}

//export wayfarerDataSourceOffer
func wayfarerDataSourceOffer(client *C.struct_wl_client, resource *C.struct_wl_resource, mime_type *C.char) {
	panic("not implemented")
}

//export wayfarerDataSourceDestroy
func wayfarerDataSourceDestroy(client *C.struct_wl_client, resource *C.struct_wl_resource) {
	panic("not implemented")
}

//export wayfarerDataSourceSetActions
func wayfarerDataSourceSetActions(client *C.struct_wl_client, resource *C.struct_wl_resource, dnd_actions C.uint32_t) {
	panic("not implemented")
}

//export wayfarerOutputBind
func wayfarerOutputBind(client *C.struct_wl_client, data unsafe.Pointer, version C.uint32_t, id C.uint32_t) {
	gclient := getClient(client)
	output := getGlobalData(uintptr(data)).(Output)
	gclient.addResource(&C.wl_output_interface, 2, uint32(id), unsafe.Pointer(&C.wayfarerOutputInterface), output)
	output.Bind(gclient, uint32(version))
}

//export wayfarerOutputRelease
func wayfarerOutputRelease(client *C.struct_wl_client, resource *C.struct_wl_resource) {
	gclient := getClient(client)
	output := gclient.getObject(uint32(resource.object.id)).(Output)
	output.Release(gclient)
}

//export wayfarerShellGetShellSurface
func wayfarerShellGetShellSurface(client *C.struct_wl_client, resource *C.struct_wl_resource, id C.uint32_t, surface *C.struct_wl_resource) {
	panic("not implemented")
}

//export wayfarerShellBind
func wayfarerShellBind(client *C.struct_wl_client, data unsafe.Pointer, version C.uint32_t, id C.uint32_t) {
	gclient := getClient(client)
	shell := getGlobalData(uintptr(data))
	gclient.addResource(&C.wl_shell_interface, 1, uint32(id), unsafe.Pointer(&C.wayfarerShellInterface), shell)
}

//export wayfarerSeatBind
func wayfarerSeatBind(client *C.struct_wl_client, data unsafe.Pointer, version C.uint32_t, id C.uint32_t) {
	gclient := getClient(client)
	seat := getGlobalData(uintptr(data))
	gclient.addResource(&C.wl_seat_interface, 5, uint32(id), unsafe.Pointer(&C.wayfarerSeatInterface), seat)
	seat.Bind(gclient, uint32(version))
}

//export wayfarerSurfaceDestroy
func wayfarerSurfaceDestroy(client *C.struct_wl_client, resource *C.struct_wl_resource) {
	gclient := getClient(client)
	gclient.getObject(uint32(resource.object.id)).(Surface).Destroy(gclient)
}

//export wayfarerSurfaceAttach
func wayfarerSurfaceAttach(client *C.struct_wl_client, resource *C.struct_wl_resource, buffer *C.struct_wl_resource, x C.int32_t, y C.int32_t) {
	gclient := getClient(client)
	gclient.getObject(uint32(resource.object.id)).(Surface).Attach(gclient, &Buffer{&Resource{buffer}}, int32(x), int32(y))
}

//export wayfarerSurfaceDamage
func wayfarerSurfaceDamage(client *C.struct_wl_client, resource *C.struct_wl_resource, x C.int32_t, y C.int32_t, width C.int32_t, height C.int32_t) {
	gclient := getClient(client)
	gclient.getObject(uint32(resource.object.id)).(Surface).Damage(gclient, int32(x), int32(y), int32(width), int32(height))
}

//export wayfarerSurfaceFrame
func wayfarerSurfaceFrame(client *C.struct_wl_client, resource *C.struct_wl_resource, callback C.uint32_t) {
	gclient := getClient(client)
	gclient.getObject(uint32(resource.object.id)).(Surface).Frame(gclient, &Callback{&Resource{C.wl_resource_create(client, &C.wl_callback_interface, 1, callback)}})
}

//export wayfarerSurfaceSetOpaqueRegion
func wayfarerSurfaceSetOpaqueRegion(client *C.struct_wl_client, resource *C.struct_wl_resource, region *C.struct_wl_resource) {
	gclient := getClient(client)
	gregion := gclient.getObject(uint32(region.object.id)).(Region)
	gclient.getObject(uint32(resource.object.id)).(Surface).SetOpaqueRegion(gclient, gregion)
}

//export wayfarerSurfaceSetInputRegion
func wayfarerSurfaceSetInputRegion(client *C.struct_wl_client, resource *C.struct_wl_resource, region *C.struct_wl_resource) {
	gclient := getClient(client)
	gregion := gclient.getObject(uint32(region.object.id)).(Region)
	gclient.getObject(uint32(resource.object.id)).(Surface).SetInputRegion(gclient, gregion)
}

//export wayfarerSurfaceCommit
func wayfarerSurfaceCommit(client *C.struct_wl_client, resource *C.struct_wl_resource) {
	gclient := getClient(client)
	gclient.getObject(uint32(resource.object.id)).(Surface).Commit(gclient)
}

//export wayfarerSurfaceSetBufferTransform
func wayfarerSurfaceSetBufferTransform(client *C.struct_wl_client, resource *C.struct_wl_resource, transform C.int32_t) {
	gclient := getClient(client)
	gclient.getObject(uint32(resource.object.id)).(Surface).SetBufferTransform(gclient, int32(transform))
}

//export wayfarerSurfaceSetBufferScale
func wayfarerSurfaceSetBufferScale(client *C.struct_wl_client, resource *C.struct_wl_resource, scale C.int32_t) {
	gclient := getClient(client)
	gclient.getObject(uint32(resource.object.id)).(Surface).SetBufferScale(gclient, int32(scale))
}

//export wayfarerRegionDestroy
func wayfarerRegionDestroy(client *C.struct_wl_client, resource *C.struct_wl_resource) {
	gclient := getClient(client)
	gclient.getObject(uint32(resource.object.id)).(Region).Destroy(gclient)
}

//export wayfarerRegionAdd
func wayfarerRegionAdd(client *C.struct_wl_client, resource *C.struct_wl_resource, x C.int32_t, y C.int32_t, width C.int32_t, height C.int32_t) {
	gclient := getClient(client)
	gclient.getObject(uint32(resource.object.id)).(Region).Add(gclient, int32(x), int32(y), int32(width), int32(height))
}

//export wayfarerRegionSubtract
func wayfarerRegionSubtract(client *C.struct_wl_client, resource *C.struct_wl_resource, x C.int32_t, y C.int32_t, width C.int32_t, height C.int32_t) {
	gclient := getClient(client)
	gclient.getObject(uint32(resource.object.id)).(Region).Subtract(gclient, int32(x), int32(y), int32(width), int32(height))
}
