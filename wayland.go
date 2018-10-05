package main

// #cgo pkg-config: wayland-server
// #include <wayland-server.h>
// #include <stdlib.h>
// #include "xdg_shell_server.h"
// #include "wayfarer.h"
import "C"
import (
	"unsafe"
)

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
	StartDrag(client *Client, source, origin, icon *C.struct_wl_resource, serial uint32)
	SetSelection(client *Client, source *C.struct_wl_resource, serial uint32)
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

type XdgWmBase interface {
	Global

	Destroy(client *Client)
	CreatePositioner(client *Client, id ObjectID) XDGPositioner
	GetXDGSurface(client *Client, id ObjectID, surface Surface) XDGSurface
	Pong(client *Client, serial uint32)
}

type XDGPositioner interface {
	Destroy(client *Client)
	SetSize(client *Client, width, height int32)
	SetAnchorRect(client *Client, x, y, width, height int32)
	SetAnchor(client *Client, anchor uint32)
	SetGravity(client *Client, gravity uint32)
	SetConstraintAdjustment(client *Client, constraintAdjustment uint32)
	SetOffset(client *Client, x, y int32)
}

type XDGSurface interface {
	Destroy(client *Client)
	GetToplevel(client *Client, id ObjectID) XDGToplevel
	GetPopup(client *Client, id ObjectID, parent *C.struct_wl_resource, positioner XDGPositioner)
	SetWindowGeometry(client *Client, x, y, width, height int32)
	AckConfigure(client *Client, serial uint32)
}

type XDGToplevel interface {
	Destroy(client *Client)
	SetParent(client *Client, parent *C.struct_wl_resource)
	SetTitle(client *Client, title string)
	SetAppID(client *Client, app_id string)
	ShowWindowMenu(client *Client, seat Seat, serial uint32, x, y int32)
	Move(client *Client, seat Seat, serial uint32)
	Resize(client *Client, seat Seat, serial uint32, edges uint32)
	SetMaxSize(client *Client, width, height int32)
	SetMinSize(client *Client, width, height int32)
	SetMaximized(client *Client)
	UnsetMaximized(client *Client)
	SetFullscreen(client *Client, output *C.struct_wl_resource)
	UnsetFullscreen(client *Client)
	SetMinimized(client *Client)
}

type Surface interface {
	Destroy(client *Client)
	Attach(client *Client, buffer *C.struct_wl_resource, x, y int32)
	Damage(client *Client, x, y, width, height int32)
	Frame(client *Client, callback *C.struct_wl_resource)
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

//export wayfarerXdgWmBaseDestroy
func wayfarerXdgWmBaseDestroy(client *C.struct_wl_client, resource *C.struct_wl_resource) {
	gclient := getClient(client)
	gclient.getObject(uint32(resource.object.id)).(XdgWmBase).Destroy(gclient)
}

//export wayfarerXdgWmBaseCreatePositioner
func wayfarerXdgWmBaseCreatePositioner(client *C.struct_wl_client, resource *C.struct_wl_resource, id C.uint32_t) {
	gclient := getClient(client)
	gclient.getObject(uint32(resource.object.id)).(XdgWmBase).CreatePositioner(gclient, ObjectID(id))
	panic("not implemented")
}

//export wayfarerXdgWmBaseGetXDGSurface
func wayfarerXdgWmBaseGetXDGSurface(client *C.struct_wl_client, resource *C.struct_wl_resource, id C.uint32_t, surface *C.struct_wl_resource) {
	gclient := getClient(client)
	gsurface := gclient.getObject(uint32(surface.object.id)).(Surface)
	xdgSurface := gclient.getObject(uint32(resource.object.id)).(XdgWmBase).GetXDGSurface(gclient, ObjectID(id), gsurface)
	gclient.addResource(&C.xdg_surface_interface, 1, uint32(id), unsafe.Pointer(&C.wayfarerXDGSurfaceInterface), xdgSurface)
}

//export wayfarerXdgWmBasePong
func wayfarerXdgWmBasePong(client *C.struct_wl_client, resource *C.struct_wl_resource, serial C.uint32_t) {
	gclient := getClient(client)
	gclient.getObject(uint32(resource.object.id)).(XdgWmBase).Pong(gclient, uint32(serial))
}

//export wayfarerXdgWmBaseBind
func wayfarerXdgWmBaseBind(client *C.struct_wl_client, data unsafe.Pointer, version C.uint32_t, id C.uint32_t) {
	gclient := getClient(client)
	base := getGlobalData(uintptr(data))
	gclient.addResource(&C.xdg_wm_base_interface, 2, uint32(id), unsafe.Pointer(&C.wayfarerXdgWmBaseInterface), base)
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
	gclient.getObject(uint32(resource.object.id)).(Surface).Attach(gclient, buffer, int32(x), int32(y))
}

//export wayfarerSurfaceDamage
func wayfarerSurfaceDamage(client *C.struct_wl_client, resource *C.struct_wl_resource, x C.int32_t, y C.int32_t, width C.int32_t, height C.int32_t) {
	gclient := getClient(client)
	gclient.getObject(uint32(resource.object.id)).(Surface).Damage(gclient, int32(x), int32(y), int32(width), int32(height))
}

//export wayfarerSurfaceFrame
func wayfarerSurfaceFrame(client *C.struct_wl_client, resource *C.struct_wl_resource, callback C.uint32_t) {
	gclient := getClient(client)
	gclient.getObject(uint32(resource.object.id)).(Surface).Frame(gclient, C.wl_resource_create(client, &C.wl_callback_interface, 1, callback))
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

//export wayfarerXDGPositionerDestroy
func wayfarerXDGPositionerDestroy(client *C.struct_wl_client, resource *C.struct_wl_resource) {
	gclient := getClient(client)
	gclient.getObject(uint32(resource.object.id)).(XDGPositioner).Destroy(gclient)
}

//export wayfarerXDGPositionerSetSize
func wayfarerXDGPositionerSetSize(client *C.struct_wl_client, resource *C.struct_wl_resource, width, height C.int32_t) {
	gclient := getClient(client)
	gclient.getObject(uint32(resource.object.id)).(XDGPositioner).SetSize(gclient, int32(width), int32(height))
}

//export wayfarerXDGPositionerSetAnchorRect
func wayfarerXDGPositionerSetAnchorRect(client *C.struct_wl_client, resource *C.struct_wl_resource, x, y, width, height C.int32_t) {
	gclient := getClient(client)
	gclient.getObject(uint32(resource.object.id)).(XDGPositioner).SetAnchorRect(gclient, int32(x), int32(y), int32(width), int32(height))
}

//export wayfarerXDGPositionerSetAnchor
func wayfarerXDGPositionerSetAnchor(client *C.struct_wl_client, resource *C.struct_wl_resource, anchor C.uint32_t) {
	gclient := getClient(client)
	gclient.getObject(uint32(resource.object.id)).(XDGPositioner).SetAnchor(gclient, uint32(anchor))
}

//export wayfarerXDGPositionerSetGravity
func wayfarerXDGPositionerSetGravity(client *C.struct_wl_client, resource *C.struct_wl_resource, gravity C.uint32_t) {
	gclient := getClient(client)
	gclient.getObject(uint32(resource.object.id)).(XDGPositioner).SetGravity(gclient, uint32(gravity))
}

//export wayfarerXDGPositionerSetConstraintAdjustment
func wayfarerXDGPositionerSetConstraintAdjustment(client *C.struct_wl_client, resource *C.struct_wl_resource, constraintAdjustment C.uint32_t) {
	gclient := getClient(client)
	gclient.getObject(uint32(resource.object.id)).(XDGPositioner).SetConstraintAdjustment(gclient, uint32(constraintAdjustment))
}

//export wayfarerXDGPositionerSetOffset
func wayfarerXDGPositionerSetOffset(client *C.struct_wl_client, resource *C.struct_wl_resource, x, y C.int32_t) {
	gclient := getClient(client)
	gclient.getObject(uint32(resource.object.id)).(XDGPositioner).SetOffset(gclient, int32(x), int32(y))
}

//export wayfarerXDGSurfaceDestroy
func wayfarerXDGSurfaceDestroy(client *C.struct_wl_client, resource *C.struct_wl_resource) {
	gclient := getClient(client)
	gclient.getObject(uint32(resource.object.id)).(XDGSurface).Destroy(gclient)
}

//export wayfarerXDGSurfaceGetToplevel
func wayfarerXDGSurfaceGetToplevel(client *C.struct_wl_client, resource *C.struct_wl_resource, id C.uint32_t) {
	gclient := getClient(client)
	toplevel := gclient.getObject(uint32(resource.object.id)).(XDGSurface).GetToplevel(gclient, ObjectID(id))
	gclient.addResource(&C.xdg_toplevel_interface, 1, uint32(id), unsafe.Pointer(&C.wayfarerXDGToplevelInterface), toplevel)
}

//export wayfarerXDGSurfaceGetPopup
func wayfarerXDGSurfaceGetPopup(client *C.struct_wl_client, resource *C.struct_wl_resource, id C.uint32_t, parent *C.struct_wl_resource, positioner *C.struct_wl_resource) {
	gclient := getClient(client)
	gpositioner := gclient.getObject(uint32(positioner.object.id)).(XDGPositioner)
	gclient.getObject(uint32(resource.object.id)).(XDGSurface).GetPopup(gclient, ObjectID(id), parent, gpositioner)
	panic("not implemented")
}

//export wayfarerXDGSurfaceSetWindowGeometry
func wayfarerXDGSurfaceSetWindowGeometry(client *C.struct_wl_client, resource *C.struct_wl_resource, x, y, width, height C.int32_t) {
	gclient := getClient(client)
	gclient.getObject(uint32(resource.object.id)).(XDGSurface).SetWindowGeometry(gclient, int32(x), int32(y), int32(width), int32(height))
}

//export wayfarerXDGSurfaceAckConfigure
func wayfarerXDGSurfaceAckConfigure(client *C.struct_wl_client, resource *C.struct_wl_resource, serial C.uint32_t) {
	gclient := getClient(client)
	gclient.getObject(uint32(resource.object.id)).(XDGSurface).AckConfigure(gclient, uint32(serial))
}

//export wayfarerXDGToplevelDestroy
func wayfarerXDGToplevelDestroy(client *C.struct_wl_client, resource *C.struct_wl_resource) {
	gclient := getClient(client)
	gclient.getObject(uint32(resource.object.id)).(XDGToplevel).Destroy(gclient)
}

//export wayfarerXDGToplevelSetParent
func wayfarerXDGToplevelSetParent(client *C.struct_wl_client, resource *C.struct_wl_resource, parent *C.struct_wl_resource) {
	gclient := getClient(client)
	gclient.getObject(uint32(resource.object.id)).(XDGToplevel).SetParent(gclient, parent)
}

//export wayfarerXDGToplevelSetTitle
func wayfarerXDGToplevelSetTitle(client *C.struct_wl_client, resource *C.struct_wl_resource, title *C.char) {
	// TODO(dh): are we responsible for freeing the *C.char?
	gclient := getClient(client)
	gclient.getObject(uint32(resource.object.id)).(XDGToplevel).SetTitle(gclient, C.GoString(title))
}

//export wayfarerXDGToplevelSetAppID
func wayfarerXDGToplevelSetAppID(client *C.struct_wl_client, resource *C.struct_wl_resource, app_id *C.char) {
	// TODO(dh): are we responsible for freeing the *C.char?
	gclient := getClient(client)
	gclient.getObject(uint32(resource.object.id)).(XDGToplevel).SetAppID(gclient, C.GoString(app_id))
}

//export wayfarerXDGToplevelShowWindowMenu
func wayfarerXDGToplevelShowWindowMenu(client *C.struct_wl_client, resource *C.struct_wl_resource, seat *C.struct_wl_resource, serial C.uint32_t, x, y C.int32_t) {
	gclient := getClient(client)
	gseat := gclient.getObject(uint32(seat.object.id)).(Seat)
	gclient.getObject(uint32(resource.object.id)).(XDGToplevel).ShowWindowMenu(gclient, gseat, uint32(serial), int32(x), int32(y))
}

//export wayfarerXDGToplevelMove
func wayfarerXDGToplevelMove(client *C.struct_wl_client, resource *C.struct_wl_resource, seat *C.struct_wl_resource, serial C.uint32_t) {
	gclient := getClient(client)
	gseat := gclient.getObject(uint32(seat.object.id)).(Seat)
	gclient.getObject(uint32(resource.object.id)).(XDGToplevel).Move(gclient, gseat, uint32(serial))
}

//export wayfarerXDGToplevelResize
func wayfarerXDGToplevelResize(client *C.struct_wl_client, resource *C.struct_wl_resource, seat *C.struct_wl_resource, serial C.uint32_t, edges C.uint32_t) {
	gclient := getClient(client)
	gseat := gclient.getObject(uint32(seat.object.id)).(Seat)
	gclient.getObject(uint32(resource.object.id)).(XDGToplevel).Resize(gclient, gseat, uint32(serial), uint32(edges))
}

//export wayfarerXDGToplevelSetMaxSize
func wayfarerXDGToplevelSetMaxSize(client *C.struct_wl_client, resource *C.struct_wl_resource, width, height C.int32_t) {
	gclient := getClient(client)
	gclient.getObject(uint32(resource.object.id)).(XDGToplevel).SetMaxSize(gclient, int32(width), int32(height))
}

//export wayfarerXDGToplevelSetMinSize
func wayfarerXDGToplevelSetMinSize(client *C.struct_wl_client, resource *C.struct_wl_resource, width, height C.int32_t) {
	gclient := getClient(client)
	gclient.getObject(uint32(resource.object.id)).(XDGToplevel).SetMinSize(gclient, int32(width), int32(height))
}

//export wayfarerXDGToplevelSetMaximized
func wayfarerXDGToplevelSetMaximized(client *C.struct_wl_client, resource *C.struct_wl_resource) {
	gclient := getClient(client)
	gclient.getObject(uint32(resource.object.id)).(XDGToplevel).SetMaximized(gclient)
}

//export wayfarerXDGToplevelUnsetMaximized
func wayfarerXDGToplevelUnsetMaximized(client *C.struct_wl_client, resource *C.struct_wl_resource) {
	gclient := getClient(client)
	gclient.getObject(uint32(resource.object.id)).(XDGToplevel).UnsetMaximized(gclient)
}

//export wayfarerXDGToplevelSetFullscreen
func wayfarerXDGToplevelSetFullscreen(client *C.struct_wl_client, resource *C.struct_wl_resource, output *C.struct_wl_resource) {
	gclient := getClient(client)
	gclient.getObject(uint32(resource.object.id)).(XDGToplevel).SetFullscreen(gclient, output)
}

//export wayfarerXDGToplevelUnsetFullscreen
func wayfarerXDGToplevelUnsetFullscreen(client *C.struct_wl_client, resource *C.struct_wl_resource) {
	gclient := getClient(client)
	gclient.getObject(uint32(resource.object.id)).(XDGToplevel).UnsetFullscreen(gclient)
}

//export wayfarerXDGToplevelSetMinimized
func wayfarerXDGToplevelSetMinimized(client *C.struct_wl_client, resource *C.struct_wl_resource) {
	gclient := getClient(client)
	gclient.getObject(uint32(resource.object.id)).(XDGToplevel).SetMinimized(gclient)
}
