package main

// #cgo pkg-config: wayland-server
// #include <wayland-server.h>
// #include <stdlib.h>
// #include "xdg_shell_server.h"
// #include "wayfarer.h"
import "C"
import (
	"fmt"
	"unsafe"
)

type Compositor interface {
	CreateSurface(client *C.struct_wl_client, id ObjectID) Surface
	CreateRegion(client *C.struct_wl_client, id ObjectID) Region
}

type Shell interface {
	GetShellSurface(client *C.struct_wl_client, id ObjectID, surface Surface)
}

type Seat interface{}

type XdgWmBase interface {
	Destroy(client *C.struct_wl_client)
	CreatePositioner(client *C.struct_wl_client, id ObjectID) XDGPositioner
	GetXDGSurface(client *C.struct_wl_client, id ObjectID, surface Surface) XDGSurface
	Pong(client *C.struct_wl_client, serial uint32)
}

type XDGPositioner interface {
	Destroy(client *C.struct_wl_client)
	SetSize(client *C.struct_wl_client, width, height int32)
	SetAnchorRect(client *C.struct_wl_client, x, y, width, height int32)
	SetAnchor(client *C.struct_wl_client, anchor uint32)
	SetGravity(client *C.struct_wl_client, gravity uint32)
	SetConstraintAdjustment(client *C.struct_wl_client, constraintAdjustment uint32)
	SetOffset(client *C.struct_wl_client, x, y int32)
}

type XDGSurface interface {
	Destroy(client *C.struct_wl_client)
	GetToplevel(client *C.struct_wl_client, id ObjectID) XDGToplevel
	GetPopup(client *C.struct_wl_client, id ObjectID, parent *C.struct_wl_resource, positioner XDGPositioner)
	SetWindowGeometry(client *C.struct_wl_client, x, y, width, height int32)
	AckConfigure(client *C.struct_wl_client, serial uint32)
}

type XDGToplevel interface {
	DestroyGo(client *C.struct_wl_client)
	SetParentGo(client *C.struct_wl_client, parent *C.struct_wl_resource)
	SetTitleGo(client *C.struct_wl_client, title string)
	SetAppIDGo(client *C.struct_wl_client, app_id string)
	ShowWindowMenuGo(client *C.struct_wl_client, seat Seat, serial uint32, x, y int32)
	MoveGo(client *C.struct_wl_client, seat Seat, serial C.uint32_t)
	ResizeGo(client *C.struct_wl_client, seat Seat, serial uint32, edges uint32)
	SetMaxSizeGo(client *C.struct_wl_client, width, height int32)
	SetMinSizeGo(client *C.struct_wl_client, width, height int32)
	SetMaximizedGo(client *C.struct_wl_client)
	UnsetMaximizedGo(client *C.struct_wl_client)
	SetFullscreenGo(client *C.struct_wl_client, output *C.struct_wl_resource)
	UnsetFullscreenGo(client *C.struct_wl_client)
	SetMinimizedGo(client *C.struct_wl_client)
}

type Surface interface {
	Destroy(client *C.struct_wl_client)
	Attach(client *C.struct_wl_client, buffer Buffer, x, y int32)
	Damage(client *C.struct_wl_client, x, y, width, height int32)
	Frame(client *C.struct_wl_client, callback uint32)
	SetOpaqueRegion(client *C.struct_wl_client, region Region)
	SetInputRegion(client *C.struct_wl_client, region Region)
	Commit(client *C.struct_wl_client)
	SetBufferTransform(client *C.struct_wl_client, transform int32)
	SetBufferScale(client *C.struct_wl_client, scale int32)
	// DamageBuffer()
}

type Region interface {
	Destroy(client *C.struct_wl_client)
	Add(client *C.struct_wl_client, x, y, width, height int32)
	Subtract(client *C.struct_wl_client, x, y, width, height int32)
}

type Buffer interface {
	Destroy()
}

var objects = map[uintptr]interface{}{}

var idStart = uintptr(C.malloc(1e6))
var idEnd = idStart + 1e6 - 1
var idCur = idStart

func getObject(resource *C.struct_wl_resource) interface{} {
	return objects[uintptr(resource.data)]
}

func addObject(obj interface{}) uintptr {
	idCur++
	objects[idCur] = obj
	return idCur
}

//export wayfarerCompositorCreateSurfaceGo
func wayfarerCompositorCreateSurfaceGo(client *C.struct_wl_client, resource *C.struct_wl_resource, id C.uint32_t) {
	surface := getObject(resource).(Compositor).CreateSurface(client, ObjectID(id))
	data := addObject(surface)
	surfaceResource := C.wl_resource_create(client, &C.wl_surface_interface, 3, C.uint(id))
	C.wl_resource_set_implementation(surfaceResource, unsafe.Pointer(&C.wayfarerSurfaceInterface), unsafe.Pointer(data), nil)
}

//export wayfarerCompositorCreateRegionGo
func wayfarerCompositorCreateRegionGo(client *C.struct_wl_client, resource *C.struct_wl_resource, id C.uint32_t) {
	region := getObject(resource).(Compositor).CreateRegion(client, ObjectID(id))
	data := addObject(region)
	regionResource := C.wl_resource_create(client, &C.wl_region_interface, 1, C.uint(id))
	C.wl_resource_set_implementation(regionResource, unsafe.Pointer(&C.wayfarerRegionInterface), unsafe.Pointer(data), nil)
}

//export wayfarerCompositorBindGo
func wayfarerCompositorBindGo(client *C.struct_wl_client, data unsafe.Pointer, version C.uint32_t, id C.uint32_t) {
	fmt.Println("Go: compositor bind")
	resource := C.wl_resource_create(client, &C.wl_compositor_interface, 1, id)
	C.wl_resource_set_implementation(resource, unsafe.Pointer(&C.wayfarerCompositorInterface), data, nil)
}

//export wayfarerShellGetShellSurfaceGo
func wayfarerShellGetShellSurfaceGo(client *C.struct_wl_client, resource *C.struct_wl_resource, id C.uint32_t, surface *C.struct_wl_resource) {
	getObject(resource).(Shell).GetShellSurface(client, ObjectID(id), getObject(surface).(Surface))
}

//export wayfarerShellBindGo
func wayfarerShellBindGo(client *C.struct_wl_client, data unsafe.Pointer, version C.uint32_t, id C.uint32_t) {
	fmt.Println("Go: shell bind")
	resource := C.wl_resource_create(client, &C.wl_shell_interface, 1, id)
	C.wl_resource_set_implementation(resource, unsafe.Pointer(&C.wayfarerShellInterface), data, nil)
}

//export wayfarerXdgWmBaseDestroyGo
func wayfarerXdgWmBaseDestroyGo(client *C.struct_wl_client, resource *C.struct_wl_resource) {
	getObject(resource).(XdgWmBase).Destroy(client)
}

//export wayfarerXdgWmBaseCreatePositionerGo
func wayfarerXdgWmBaseCreatePositionerGo(client *C.struct_wl_client, resource *C.struct_wl_resource, id C.uint32_t) {
	getObject(resource).(XdgWmBase).CreatePositioner(client, ObjectID(id))
}

//export wayfarerXdgWmBaseGetXDGSurfaceGo
func wayfarerXdgWmBaseGetXDGSurfaceGo(client *C.struct_wl_client, resource *C.struct_wl_resource, id C.uint32_t, surface *C.struct_wl_resource) {
	xdgSurface := getObject(resource).(XdgWmBase).GetXDGSurface(client, ObjectID(id), getObject(surface).(Surface))
	data := addObject(xdgSurface)
	xdgSurfaceResource := C.wl_resource_create(client, &C.xdg_surface_interface, 1, id)
	C.wl_resource_set_implementation(xdgSurfaceResource, unsafe.Pointer(&C.wayfarerXDGSurfaceInterface), unsafe.Pointer(data), nil)
}

//export wayfarerXdgWmBasePongGo
func wayfarerXdgWmBasePongGo(client *C.struct_wl_client, resource *C.struct_wl_resource, serial C.uint32_t) {
	getObject(resource).(XdgWmBase).Pong(client, uint32(serial))
}

//export wayfarerXdgWmBaseBindGo
func wayfarerXdgWmBaseBindGo(client *C.struct_wl_client, data unsafe.Pointer, version C.uint32_t, id C.uint32_t) {
	fmt.Println("Go: xdg wm base bind")
	resource := C.wl_resource_create(client, &C.xdg_wm_base_interface, 2, id)
	C.wl_resource_set_implementation(resource, unsafe.Pointer(&C.wayfarerXdgWmBaseInterface), data, nil)
}

//export wayfarerSeatBindGo
func wayfarerSeatBindGo(client *C.struct_wl_client, data unsafe.Pointer, version C.uint32_t, id C.uint32_t) {
	fmt.Println("Go: seat bind")
}

//export wayfarerSurfaceDestroyGo
func wayfarerSurfaceDestroyGo(client *C.struct_wl_client, resource *C.struct_wl_resource) {
	getObject(resource).(Surface).Destroy(client)
}

//export wayfarerSurfaceAttachGo
func wayfarerSurfaceAttachGo(client *C.struct_wl_client, resource *C.struct_wl_resource, buffer *C.struct_wl_resource, x C.int32_t, y C.int32_t) {
	getObject(resource).(Surface).Attach(client, getObject(buffer).(Buffer), int32(x), int32(y))
}

//export wayfarerSurfaceDamageGo
func wayfarerSurfaceDamageGo(client *C.struct_wl_client, resource *C.struct_wl_resource, x C.int32_t, y C.int32_t, width C.int32_t, height C.int32_t) {
	getObject(resource).(Surface).Damage(client, int32(x), int32(y), int32(width), int32(height))
}

//export wayfarerSurfaceFrameGo
func wayfarerSurfaceFrameGo(client *C.struct_wl_client, resource *C.struct_wl_resource, callback C.uint32_t) {
	getObject(resource).(Surface).Frame(client, uint32(callback))
}

//export wayfarerSurfaceSetOpaqueRegionGo
func wayfarerSurfaceSetOpaqueRegionGo(client *C.struct_wl_client, resource *C.struct_wl_resource, region *C.struct_wl_resource) {
	getObject(resource).(Surface).SetOpaqueRegion(client, getObject(region).(Region))
}

//export wayfarerSurfaceSetInputRegionGo
func wayfarerSurfaceSetInputRegionGo(client *C.struct_wl_client, resource *C.struct_wl_resource, region *C.struct_wl_resource) {
	getObject(resource).(Surface).SetInputRegion(client, getObject(region).(Region))
}

//export wayfarerSurfaceCommitGo
func wayfarerSurfaceCommitGo(client *C.struct_wl_client, resource *C.struct_wl_resource) {
	getObject(resource).(Surface).Commit(client)
}

//export wayfarerSurfaceSetBufferTransformGo
func wayfarerSurfaceSetBufferTransformGo(client *C.struct_wl_client, resource *C.struct_wl_resource, transform C.int32_t) {
	getObject(resource).(Surface).SetBufferTransform(client, int32(transform))
}

//export wayfarerSurfaceSetBufferScaleGo
func wayfarerSurfaceSetBufferScaleGo(client *C.struct_wl_client, resource *C.struct_wl_resource, scale C.int32_t) {
	getObject(resource).(Surface).SetBufferScale(client, int32(scale))
}

//export wayfarerRegionDestroyGo
func wayfarerRegionDestroyGo(client *C.struct_wl_client, resource *C.struct_wl_resource) {
	getObject(resource).(Region).Destroy(client)
}

//export wayfarerRegionAddGo
func wayfarerRegionAddGo(client *C.struct_wl_client, resource *C.struct_wl_resource, x C.int32_t, y C.int32_t, width C.int32_t, height C.int32_t) {
	getObject(resource).(Region).Add(client, int32(x), int32(y), int32(width), int32(height))
}

//export wayfarerRegionSubtractGo
func wayfarerRegionSubtractGo(client *C.struct_wl_client, resource *C.struct_wl_resource, x C.int32_t, y C.int32_t, width C.int32_t, height C.int32_t) {
	getObject(resource).(Region).Subtract(client, int32(x), int32(y), int32(width), int32(height))
}

//export wayfarerXDGPositionerDestroyGo
func wayfarerXDGPositionerDestroyGo(client *C.struct_wl_client, resource *C.struct_wl_resource) {
	getObject(resource).(XDGPositioner).Destroy(client)
}

//export wayfarerXDGPositionerSetSizeGo
func wayfarerXDGPositionerSetSizeGo(client *C.struct_wl_client, resource *C.struct_wl_resource, width, height C.int32_t) {
	getObject(resource).(XDGPositioner).SetSize(client, int32(width), int32(height))
}

//export wayfarerXDGPositionerSetAnchorRectGo
func wayfarerXDGPositionerSetAnchorRectGo(client *C.struct_wl_client, resource *C.struct_wl_resource, x, y, width, height C.int32_t) {
	getObject(resource).(XDGPositioner).SetAnchorRect(client, int32(x), int32(y), int32(width), int32(height))
}

//export wayfarerXDGPositionerSetAnchorGo
func wayfarerXDGPositionerSetAnchorGo(client *C.struct_wl_client, resource *C.struct_wl_resource, anchor C.uint32_t) {
	getObject(resource).(XDGPositioner).SetAnchor(client, uint32(anchor))
}

//export wayfarerXDGPositionerSetGravityGo
func wayfarerXDGPositionerSetGravityGo(client *C.struct_wl_client, resource *C.struct_wl_resource, gravity C.uint32_t) {
	getObject(resource).(XDGPositioner).SetGravity(client, uint32(gravity))
}

//export wayfarerXDGPositionerSetConstraintAdjustmentGo
func wayfarerXDGPositionerSetConstraintAdjustmentGo(client *C.struct_wl_client, resource *C.struct_wl_resource, constraintAdjustment C.uint32_t) {
	getObject(resource).(XDGPositioner).SetConstraintAdjustment(client, uint32(constraintAdjustment))
}

//export wayfarerXDGPositionerSetOffsetGo
func wayfarerXDGPositionerSetOffsetGo(client *C.struct_wl_client, resource *C.struct_wl_resource, x, y C.int32_t) {
	getObject(resource).(XDGPositioner).SetOffset(client, int32(x), int32(y))
}

//export wayfarerXDGSurfaceDestroyGo
func wayfarerXDGSurfaceDestroyGo(client *C.struct_wl_client, resource *C.struct_wl_resource) {
	getObject(resource).(XDGSurface).Destroy(client)
}

//export wayfarerXDGSurfaceGetToplevelGo
func wayfarerXDGSurfaceGetToplevelGo(client *C.struct_wl_client, resource *C.struct_wl_resource, id C.uint32_t) {
	toplevel := getObject(resource).(XDGSurface).GetToplevel(client, ObjectID(id))
	data := addObject(toplevel)
	toplevelResource := C.wl_resource_create(client, &C.xdg_toplevel_interface, 1, id)
	C.wl_resource_set_implementation(toplevelResource, unsafe.Pointer(&C.wayfarerXDGToplevelInterface), unsafe.Pointer(data), nil)
}

//export wayfarerXDGSurfaceGetPopupGo
func wayfarerXDGSurfaceGetPopupGo(client *C.struct_wl_client, resource *C.struct_wl_resource, id C.uint32_t, parent *C.struct_wl_resource, positioner *C.struct_wl_resource) {
	getObject(resource).(XDGSurface).GetPopup(client, ObjectID(id), parent, getObject(positioner).(XDGPositioner))
}

//export wayfarerXDGSurfaceSetWindowGeometryGo
func wayfarerXDGSurfaceSetWindowGeometryGo(client *C.struct_wl_client, resource *C.struct_wl_resource, x, y, width, height C.int32_t) {
	getObject(resource).(XDGSurface).SetWindowGeometry(client, int32(x), int32(y), int32(width), int32(height))
}

//export wayfarerXDGSurfaceAckConfigureGo
func wayfarerXDGSurfaceAckConfigureGo(client *C.struct_wl_client, resource *C.struct_wl_resource, serial C.uint32_t) {
	getObject(resource).(XDGSurface).AckConfigure(client, uint32(serial))
}

//export wayfarerXDGToplevelDestroyGo
func wayfarerXDGToplevelDestroyGo(client *C.struct_wl_client, resource *C.struct_wl_resource) {

}

//export wayfarerXDGToplevelSetParentGo
func wayfarerXDGToplevelSetParentGo(client *C.struct_wl_client, resource *C.struct_wl_resource, parent *C.struct_wl_resource) {

}

//export wayfarerXDGToplevelSetTitleGo
func wayfarerXDGToplevelSetTitleGo(client *C.struct_wl_client, resource *C.struct_wl_resource, title *C.char) {

}

//export wayfarerXDGToplevelSetAppIDGo
func wayfarerXDGToplevelSetAppIDGo(client *C.struct_wl_client, resource *C.struct_wl_resource, app_id *C.char) {

}

//export wayfarerXDGToplevelShowWindowMenuGo
func wayfarerXDGToplevelShowWindowMenuGo(client *C.struct_wl_client, resource *C.struct_wl_resource, seat *C.struct_wl_resource, serial C.uint32_t, x, y C.int32_t) {

}

//export wayfarerXDGToplevelMoveGo
func wayfarerXDGToplevelMoveGo(client *C.struct_wl_client, resource *C.struct_wl_resource, seat *C.struct_wl_resource, serial C.uint32_t) {

}

//export wayfarerXDGToplevelResizeGo
func wayfarerXDGToplevelResizeGo(client *C.struct_wl_client, resource *C.struct_wl_resource, seat *C.struct_wl_resource, serial C.uint32_t, edges C.uint32_t) {

}

//export wayfarerXDGToplevelSetMaxSizeGo
func wayfarerXDGToplevelSetMaxSizeGo(client *C.struct_wl_client, resource *C.struct_wl_resource, width, height C.int32_t) {

}

//export wayfarerXDGToplevelSetMinSizeGo
func wayfarerXDGToplevelSetMinSizeGo(client *C.struct_wl_client, resource *C.struct_wl_resource, width, height C.int32_t) {

}

//export wayfarerXDGToplevelSetMaximizedGo
func wayfarerXDGToplevelSetMaximizedGo(client *C.struct_wl_client, resource *C.struct_wl_resource) {

}

//export wayfarerXDGToplevelUnsetMaximizedGo
func wayfarerXDGToplevelUnsetMaximizedGo(client *C.struct_wl_client, resource *C.struct_wl_resource) {

}

//export wayfarerXDGToplevelSetFullscreenGo
func wayfarerXDGToplevelSetFullscreenGo(client *C.struct_wl_client, resource *C.struct_wl_resource, output *C.struct_wl_resource) {

}

//export wayfarerXDGToplevelUnsetFullscreenGo
func wayfarerXDGToplevelUnsetFullscreenGo(client *C.struct_wl_client, resource *C.struct_wl_resource) {

}

//export wayfarerXDGToplevelSetMinimizedGo
func wayfarerXDGToplevelSetMinimizedGo(client *C.struct_wl_client, resource *C.struct_wl_resource) {

}
