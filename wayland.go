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
	Bind(client *Client, res *C.struct_wl_resource, version uint32)
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
	Attach(client *Client, buffer Buffer, x, y int32)
	Damage(client *Client, x, y, width, height int32)
	Frame(client *Client, callback uint32)
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

type Buffer interface {
	Destroy()
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

var globals = map[uintptr]interface{}{}

var idStart = uintptr(C.malloc(1e6))
var idEnd = idStart + 1e6 - 1
var idCur = idStart

func getGlobal(resource *C.struct_wl_resource) interface{} {
	return getGlobalData(uintptr(resource.data))
}

func getGlobalData(data uintptr) interface{} {
	return globals[data]
}

func addGlobal(obj interface{}) uintptr {
	idCur++
	globals[idCur] = obj
	return idCur
}

func (c *Client) addResource(iface *C.struct_wl_interface, version uint32, id uint32, impl unsafe.Pointer, obj interface{}) {
	c.objects[id] = obj
	res := C.wl_resource_create(c.Client, iface, C.int32_t(version), C.uint32_t(id))
	c.invObjects[obj] = res
	C.wl_resource_set_implementation(res, impl, nil, nil)
}

//export wayfarerCompositorCreateSurfaceGo
func wayfarerCompositorCreateSurfaceGo(client *C.struct_wl_client, resource *C.struct_wl_resource, id C.uint32_t) {
	gclient := getClient(client)
	comp := gclient.getObject(uint32(resource.object.id)).(Compositor)

	surface := comp.CreateSurface(gclient, ObjectID(id))
	gclient.addResource(&C.wl_surface_interface, 3, uint32(id), unsafe.Pointer(&C.wayfarerSurfaceInterface), surface)
}

//export wayfarerCompositorCreateRegionGo
func wayfarerCompositorCreateRegionGo(client *C.struct_wl_client, resource *C.struct_wl_resource, id C.uint32_t) {
	gclient := getClient(client)
	comp := gclient.getObject(uint32(resource.object.id)).(Compositor)

	region := comp.CreateRegion(gclient, ObjectID(id))
	gclient.addResource(&C.wl_region_interface, 1, uint32(id), unsafe.Pointer(&C.wayfarerRegionInterface), region)
}

//export wayfarerCompositorBindGo
func wayfarerCompositorBindGo(client *C.struct_wl_client, data unsafe.Pointer, version C.uint32_t, id C.uint32_t) {
	gclient := getClient(client)
	comp := getGlobalData(uintptr(data))
	gclient.addResource(&C.wl_compositor_interface, 1, uint32(id), unsafe.Pointer(&C.wayfarerCompositorInterface), comp)
}

//export wayfarerOutputBindGo
func wayfarerOutputBindGo(client *C.struct_wl_client, data unsafe.Pointer, version C.uint32_t, id C.uint32_t) {
	gclient := getClient(client)
	output := getGlobalData(uintptr(data)).(Output)
	gclient.addResource(&C.wl_output_interface, 3, uint32(id), unsafe.Pointer(&C.wayfarerOutputInterface), output)
	// output.Bind(client, resource, uint32(version))
}

//export wayfarerOutputReleaseGo
func wayfarerOutputReleaseGo(client *C.struct_wl_client, resource *C.struct_wl_resource) {
	gclient := getClient(client)
	output := gclient.getObject(uint32(resource.object.id)).(Output)
	output.Release(gclient)
}

//export wayfarerShellGetShellSurfaceGo
func wayfarerShellGetShellSurfaceGo(client *C.struct_wl_client, resource *C.struct_wl_resource, id C.uint32_t, surface *C.struct_wl_resource) {
	panic("not implemented")
}

//export wayfarerShellBindGo
func wayfarerShellBindGo(client *C.struct_wl_client, data unsafe.Pointer, version C.uint32_t, id C.uint32_t) {
	gclient := getClient(client)
	shell := getGlobalData(uintptr(data))
	gclient.addResource(&C.wl_shell_interface, 1, uint32(id), unsafe.Pointer(&C.wayfarerShellInterface), shell)
}

//export wayfarerXdgWmBaseDestroyGo
func wayfarerXdgWmBaseDestroyGo(client *C.struct_wl_client, resource *C.struct_wl_resource) {
	gclient := getClient(client)
	gclient.getObject(uint32(resource.object.id)).(XdgWmBase).Destroy(gclient)
}

//export wayfarerXdgWmBaseCreatePositionerGo
func wayfarerXdgWmBaseCreatePositionerGo(client *C.struct_wl_client, resource *C.struct_wl_resource, id C.uint32_t) {
	gclient := getClient(client)
	gclient.getObject(uint32(resource.object.id)).(XdgWmBase).CreatePositioner(gclient, ObjectID(id))
	panic("not implemented")
}

//export wayfarerXdgWmBaseGetXDGSurfaceGo
func wayfarerXdgWmBaseGetXDGSurfaceGo(client *C.struct_wl_client, resource *C.struct_wl_resource, id C.uint32_t, surface *C.struct_wl_resource) {
	gclient := getClient(client)
	gsurface := gclient.getObject(uint32(surface.object.id)).(Surface)
	xdgSurface := gclient.getObject(uint32(resource.object.id)).(XdgWmBase).GetXDGSurface(gclient, ObjectID(id), gsurface)
	gclient.addResource(&C.xdg_surface_interface, 1, uint32(id), unsafe.Pointer(&C.wayfarerXDGSurfaceInterface), xdgSurface)
}

//export wayfarerXdgWmBasePongGo
func wayfarerXdgWmBasePongGo(client *C.struct_wl_client, resource *C.struct_wl_resource, serial C.uint32_t) {
	gclient := getClient(client)
	gclient.getObject(uint32(resource.object.id)).(XdgWmBase).Pong(gclient, uint32(serial))
}

//export wayfarerXdgWmBaseBindGo
func wayfarerXdgWmBaseBindGo(client *C.struct_wl_client, data unsafe.Pointer, version C.uint32_t, id C.uint32_t) {
	gclient := getClient(client)
	base := getGlobalData(uintptr(data))
	gclient.addResource(&C.xdg_wm_base_interface, 2, uint32(id), unsafe.Pointer(&C.wayfarerXdgWmBaseInterface), base)
}

//export wayfarerSeatBindGo
func wayfarerSeatBindGo(client *C.struct_wl_client, data unsafe.Pointer, version C.uint32_t, id C.uint32_t) {
	gclient := getClient(client)
	seat := getGlobalData(uintptr(data))
	gclient.addResource(&C.wl_seat_interface, 1, uint32(id), unsafe.Pointer(&C.wayfarerSeatInterface), seat)
}

//export wayfarerSurfaceDestroyGo
func wayfarerSurfaceDestroyGo(client *C.struct_wl_client, resource *C.struct_wl_resource) {
	gclient := getClient(client)
	gclient.getObject(uint32(resource.object.id)).(Surface).Destroy(gclient)
}

//export wayfarerSurfaceAttachGo
func wayfarerSurfaceAttachGo(client *C.struct_wl_client, resource *C.struct_wl_resource, buffer *C.struct_wl_resource, x C.int32_t, y C.int32_t) {
	gclient := getClient(client)
	gbuffer := gclient.getObject(uint32(buffer.object.id)).(Buffer)
	gclient.getObject(uint32(resource.object.id)).(Surface).Attach(gclient, gbuffer, int32(x), int32(y))
}

//export wayfarerSurfaceDamageGo
func wayfarerSurfaceDamageGo(client *C.struct_wl_client, resource *C.struct_wl_resource, x C.int32_t, y C.int32_t, width C.int32_t, height C.int32_t) {
	gclient := getClient(client)
	gclient.getObject(uint32(resource.object.id)).(Surface).Damage(gclient, int32(x), int32(y), int32(width), int32(height))
}

//export wayfarerSurfaceFrameGo
func wayfarerSurfaceFrameGo(client *C.struct_wl_client, resource *C.struct_wl_resource, callback C.uint32_t) {
	gclient := getClient(client)
	gclient.getObject(uint32(resource.object.id)).(Surface).Frame(gclient, uint32(callback))
}

//export wayfarerSurfaceSetOpaqueRegionGo
func wayfarerSurfaceSetOpaqueRegionGo(client *C.struct_wl_client, resource *C.struct_wl_resource, region *C.struct_wl_resource) {
	gclient := getClient(client)
	gregion := gclient.getObject(uint32(region.object.id)).(Region)
	gclient.getObject(uint32(resource.object.id)).(Surface).SetOpaqueRegion(gclient, gregion)
}

//export wayfarerSurfaceSetInputRegionGo
func wayfarerSurfaceSetInputRegionGo(client *C.struct_wl_client, resource *C.struct_wl_resource, region *C.struct_wl_resource) {
	gclient := getClient(client)
	gregion := gclient.getObject(uint32(region.object.id)).(Region)
	gclient.getObject(uint32(resource.object.id)).(Surface).SetInputRegion(gclient, gregion)
}

//export wayfarerSurfaceCommitGo
func wayfarerSurfaceCommitGo(client *C.struct_wl_client, resource *C.struct_wl_resource) {
	gclient := getClient(client)
	gclient.getObject(uint32(resource.object.id)).(Surface).Commit(gclient)
}

//export wayfarerSurfaceSetBufferTransformGo
func wayfarerSurfaceSetBufferTransformGo(client *C.struct_wl_client, resource *C.struct_wl_resource, transform C.int32_t) {
	gclient := getClient(client)
	gclient.getObject(uint32(resource.object.id)).(Surface).SetBufferTransform(gclient, int32(transform))
}

//export wayfarerSurfaceSetBufferScaleGo
func wayfarerSurfaceSetBufferScaleGo(client *C.struct_wl_client, resource *C.struct_wl_resource, scale C.int32_t) {
	gclient := getClient(client)
	gclient.getObject(uint32(resource.object.id)).(Surface).SetBufferScale(gclient, int32(scale))
}

//export wayfarerRegionDestroyGo
func wayfarerRegionDestroyGo(client *C.struct_wl_client, resource *C.struct_wl_resource) {
	gclient := getClient(client)
	gclient.getObject(uint32(resource.object.id)).(Region).Destroy(gclient)
}

//export wayfarerRegionAddGo
func wayfarerRegionAddGo(client *C.struct_wl_client, resource *C.struct_wl_resource, x C.int32_t, y C.int32_t, width C.int32_t, height C.int32_t) {
	gclient := getClient(client)
	gclient.getObject(uint32(resource.object.id)).(Region).Add(gclient, int32(x), int32(y), int32(width), int32(height))
}

//export wayfarerRegionSubtractGo
func wayfarerRegionSubtractGo(client *C.struct_wl_client, resource *C.struct_wl_resource, x C.int32_t, y C.int32_t, width C.int32_t, height C.int32_t) {
	gclient := getClient(client)
	gclient.getObject(uint32(resource.object.id)).(Region).Subtract(gclient, int32(x), int32(y), int32(width), int32(height))
}

//export wayfarerXDGPositionerDestroyGo
func wayfarerXDGPositionerDestroyGo(client *C.struct_wl_client, resource *C.struct_wl_resource) {
	gclient := getClient(client)
	gclient.getObject(uint32(resource.object.id)).(XDGPositioner).Destroy(gclient)
}

//export wayfarerXDGPositionerSetSizeGo
func wayfarerXDGPositionerSetSizeGo(client *C.struct_wl_client, resource *C.struct_wl_resource, width, height C.int32_t) {
	gclient := getClient(client)
	gclient.getObject(uint32(resource.object.id)).(XDGPositioner).SetSize(gclient, int32(width), int32(height))
}

//export wayfarerXDGPositionerSetAnchorRectGo
func wayfarerXDGPositionerSetAnchorRectGo(client *C.struct_wl_client, resource *C.struct_wl_resource, x, y, width, height C.int32_t) {
	gclient := getClient(client)
	gclient.getObject(uint32(resource.object.id)).(XDGPositioner).SetAnchorRect(gclient, int32(x), int32(y), int32(width), int32(height))
}

//export wayfarerXDGPositionerSetAnchorGo
func wayfarerXDGPositionerSetAnchorGo(client *C.struct_wl_client, resource *C.struct_wl_resource, anchor C.uint32_t) {
	gclient := getClient(client)
	gclient.getObject(uint32(resource.object.id)).(XDGPositioner).SetAnchor(gclient, uint32(anchor))
}

//export wayfarerXDGPositionerSetGravityGo
func wayfarerXDGPositionerSetGravityGo(client *C.struct_wl_client, resource *C.struct_wl_resource, gravity C.uint32_t) {
	gclient := getClient(client)
	gclient.getObject(uint32(resource.object.id)).(XDGPositioner).SetGravity(gclient, uint32(gravity))
}

//export wayfarerXDGPositionerSetConstraintAdjustmentGo
func wayfarerXDGPositionerSetConstraintAdjustmentGo(client *C.struct_wl_client, resource *C.struct_wl_resource, constraintAdjustment C.uint32_t) {
	gclient := getClient(client)
	gclient.getObject(uint32(resource.object.id)).(XDGPositioner).SetConstraintAdjustment(gclient, uint32(constraintAdjustment))
}

//export wayfarerXDGPositionerSetOffsetGo
func wayfarerXDGPositionerSetOffsetGo(client *C.struct_wl_client, resource *C.struct_wl_resource, x, y C.int32_t) {
	gclient := getClient(client)
	gclient.getObject(uint32(resource.object.id)).(XDGPositioner).SetOffset(gclient, int32(x), int32(y))
}

//export wayfarerXDGSurfaceDestroyGo
func wayfarerXDGSurfaceDestroyGo(client *C.struct_wl_client, resource *C.struct_wl_resource) {
	gclient := getClient(client)
	gclient.getObject(uint32(resource.object.id)).(XDGSurface).Destroy(gclient)
}

//export wayfarerXDGSurfaceGetToplevelGo
func wayfarerXDGSurfaceGetToplevelGo(client *C.struct_wl_client, resource *C.struct_wl_resource, id C.uint32_t) {
	gclient := getClient(client)
	toplevel := gclient.getObject(uint32(resource.object.id)).(XDGSurface).GetToplevel(gclient, ObjectID(id))
	gclient.addResource(&C.xdg_toplevel_interface, 1, uint32(id), unsafe.Pointer(&C.wayfarerXDGToplevelInterface), toplevel)
}

//export wayfarerXDGSurfaceGetPopupGo
func wayfarerXDGSurfaceGetPopupGo(client *C.struct_wl_client, resource *C.struct_wl_resource, id C.uint32_t, parent *C.struct_wl_resource, positioner *C.struct_wl_resource) {
	gclient := getClient(client)
	gpositioner := gclient.getObject(uint32(positioner.object.id)).(XDGPositioner)
	gclient.getObject(uint32(resource.object.id)).(XDGSurface).GetPopup(gclient, ObjectID(id), parent, gpositioner)
	panic("not implemented")
}

//export wayfarerXDGSurfaceSetWindowGeometryGo
func wayfarerXDGSurfaceSetWindowGeometryGo(client *C.struct_wl_client, resource *C.struct_wl_resource, x, y, width, height C.int32_t) {
	gclient := getClient(client)
	gclient.getObject(uint32(resource.object.id)).(XDGSurface).SetWindowGeometry(gclient, int32(x), int32(y), int32(width), int32(height))
}

//export wayfarerXDGSurfaceAckConfigureGo
func wayfarerXDGSurfaceAckConfigureGo(client *C.struct_wl_client, resource *C.struct_wl_resource, serial C.uint32_t) {
	gclient := getClient(client)
	gclient.getObject(uint32(resource.object.id)).(XDGSurface).AckConfigure(gclient, uint32(serial))
}

//export wayfarerXDGToplevelDestroyGo
func wayfarerXDGToplevelDestroyGo(client *C.struct_wl_client, resource *C.struct_wl_resource) {
	gclient := getClient(client)
	gclient.getObject(uint32(resource.object.id)).(XDGToplevel).Destroy(gclient)
}

//export wayfarerXDGToplevelSetParentGo
func wayfarerXDGToplevelSetParentGo(client *C.struct_wl_client, resource *C.struct_wl_resource, parent *C.struct_wl_resource) {
	gclient := getClient(client)
	gclient.getObject(uint32(resource.object.id)).(XDGToplevel).SetParent(gclient, parent)
}

//export wayfarerXDGToplevelSetTitleGo
func wayfarerXDGToplevelSetTitleGo(client *C.struct_wl_client, resource *C.struct_wl_resource, title *C.char) {
	// TODO(dh): are we responsible for freeing the *C.char?
	gclient := getClient(client)
	gclient.getObject(uint32(resource.object.id)).(XDGToplevel).SetTitle(gclient, C.GoString(title))
}

//export wayfarerXDGToplevelSetAppIDGo
func wayfarerXDGToplevelSetAppIDGo(client *C.struct_wl_client, resource *C.struct_wl_resource, app_id *C.char) {
	// TODO(dh): are we responsible for freeing the *C.char?
	gclient := getClient(client)
	gclient.getObject(uint32(resource.object.id)).(XDGToplevel).SetAppID(gclient, C.GoString(app_id))
}

//export wayfarerXDGToplevelShowWindowMenuGo
func wayfarerXDGToplevelShowWindowMenuGo(client *C.struct_wl_client, resource *C.struct_wl_resource, seat *C.struct_wl_resource, serial C.uint32_t, x, y C.int32_t) {
	gclient := getClient(client)
	gseat := gclient.getObject(uint32(seat.object.id)).(Seat)
	gclient.getObject(uint32(resource.object.id)).(XDGToplevel).ShowWindowMenu(gclient, gseat, uint32(serial), int32(x), int32(y))
}

//export wayfarerXDGToplevelMoveGo
func wayfarerXDGToplevelMoveGo(client *C.struct_wl_client, resource *C.struct_wl_resource, seat *C.struct_wl_resource, serial C.uint32_t) {
	gclient := getClient(client)
	gseat := gclient.getObject(uint32(seat.object.id)).(Seat)
	gclient.getObject(uint32(resource.object.id)).(XDGToplevel).Move(gclient, gseat, uint32(serial))
}

//export wayfarerXDGToplevelResizeGo
func wayfarerXDGToplevelResizeGo(client *C.struct_wl_client, resource *C.struct_wl_resource, seat *C.struct_wl_resource, serial C.uint32_t, edges C.uint32_t) {
	gclient := getClient(client)
	gseat := gclient.getObject(uint32(seat.object.id)).(Seat)
	gclient.getObject(uint32(resource.object.id)).(XDGToplevel).Resize(gclient, gseat, uint32(serial), uint32(edges))
}

//export wayfarerXDGToplevelSetMaxSizeGo
func wayfarerXDGToplevelSetMaxSizeGo(client *C.struct_wl_client, resource *C.struct_wl_resource, width, height C.int32_t) {
	gclient := getClient(client)
	gclient.getObject(uint32(resource.object.id)).(XDGToplevel).SetMaxSize(gclient, int32(width), int32(height))
}

//export wayfarerXDGToplevelSetMinSizeGo
func wayfarerXDGToplevelSetMinSizeGo(client *C.struct_wl_client, resource *C.struct_wl_resource, width, height C.int32_t) {
	gclient := getClient(client)
	gclient.getObject(uint32(resource.object.id)).(XDGToplevel).SetMinSize(gclient, int32(width), int32(height))
}

//export wayfarerXDGToplevelSetMaximizedGo
func wayfarerXDGToplevelSetMaximizedGo(client *C.struct_wl_client, resource *C.struct_wl_resource) {
	gclient := getClient(client)
	gclient.getObject(uint32(resource.object.id)).(XDGToplevel).SetMaximized(gclient)
}

//export wayfarerXDGToplevelUnsetMaximizedGo
func wayfarerXDGToplevelUnsetMaximizedGo(client *C.struct_wl_client, resource *C.struct_wl_resource) {
	gclient := getClient(client)
	gclient.getObject(uint32(resource.object.id)).(XDGToplevel).UnsetMaximized(gclient)
}

//export wayfarerXDGToplevelSetFullscreenGo
func wayfarerXDGToplevelSetFullscreenGo(client *C.struct_wl_client, resource *C.struct_wl_resource, output *C.struct_wl_resource) {
	gclient := getClient(client)
	gclient.getObject(uint32(resource.object.id)).(XDGToplevel).SetFullscreen(gclient, output)
}

//export wayfarerXDGToplevelUnsetFullscreenGo
func wayfarerXDGToplevelUnsetFullscreenGo(client *C.struct_wl_client, resource *C.struct_wl_resource) {
	gclient := getClient(client)
	gclient.getObject(uint32(resource.object.id)).(XDGToplevel).UnsetFullscreen(gclient)
}

//export wayfarerXDGToplevelSetMinimizedGo
func wayfarerXDGToplevelSetMinimizedGo(client *C.struct_wl_client, resource *C.struct_wl_resource) {
	gclient := getClient(client)
	gclient.getObject(uint32(resource.object.id)).(XDGToplevel).SetMinimized(gclient)
}
