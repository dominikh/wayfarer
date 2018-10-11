package wayland

// #cgo pkg-config: wayland-server
// #include <wayland-server.h>
// #include "xdg_shell_server.h"
// #include "wayfarer.h"
import "C"
import "unsafe"

var XdgWmBaseInterface = &C.xdg_wm_base_interface

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
	GetPopup(client *Client, id ObjectID, parent *Resource, positioner XDGPositioner)
	SetWindowGeometry(client *Client, x, y, width, height int32)
	AckConfigure(client *Client, serial uint32)
}

type XDGToplevel interface {
	Destroy(client *Client)
	SetParent(client *Client, parent *Resource)
	SetTitle(client *Client, title string)
	SetAppID(client *Client, app_id string)
	ShowWindowMenu(client *Client, seat Seat, serial uint32, x, y int32)
	Move(client *Client, seat Seat, serial uint32)
	Resize(client *Client, seat Seat, serial uint32, edges uint32)
	SetMaxSize(client *Client, width, height int32)
	SetMinSize(client *Client, width, height int32)
	SetMaximized(client *Client)
	UnsetMaximized(client *Client)
	SetFullscreen(client *Client, output *Resource)
	UnsetFullscreen(client *Client)
	SetMinimized(client *Client)
}

func (dpy *Display) CreateXdgWmBaseGlobal(shell XdgWmBase) {
	dpy.CreateGlobal(shell, XdgWmBaseInterface, 2, C.wayfarerXdgWmBaseBind)
}

func (c *Client) XDGSurfaceSendConfigure(surface XDGSurface, serial uint) {
	C.xdg_surface_send_configure(c.getResource(surface), C.uint(serial))
}

func (c *Client) XDGToplevelSendConfigure(surface XDGToplevel, width, height int, states []uint32) {
	array := (*C.struct_wl_array)(C.malloc(C.ulong(unsafe.Sizeof(C.struct_wl_array{}))))
	C.wl_array_init(array)
	defer C.wl_array_release(array)
	for _, state := range states {
		ptr := (*C.uint32_t)(C.wl_array_add(array, C.ulong(unsafe.Sizeof(C.uint32_t(0)))))
		*ptr = C.uint32_t(state)
	}
	C.xdg_toplevel_send_configure(c.getResource(surface), C.int(width), C.int(height), array)
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
	gclient.getObject(uint32(resource.object.id)).(XDGSurface).GetPopup(gclient, ObjectID(id), &Resource{parent}, gpositioner)
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
	gclient.getObject(uint32(resource.object.id)).(XDGToplevel).SetParent(gclient, &Resource{parent})
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
	gclient.getObject(uint32(resource.object.id)).(XDGToplevel).SetFullscreen(gclient, &Resource{output})
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
