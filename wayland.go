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
	CreateSurface(client *C.struct_wl_client, resource *C.struct_wl_resource, id ObjectID) Surface
	CreateRegion(client *C.struct_wl_client, resource *C.struct_wl_resource, id ObjectID) Region
}

type Shell interface {
	GetShellSurface(client *C.struct_wl_client, resource *C.struct_wl_resource, id ObjectID, surface *C.struct_wl_resource)
}

type Seat interface{}

type XdgWmBase interface {
	Destroy(client *C.struct_wl_client, resource *C.struct_wl_resource)
	CreatePositioner(client *C.struct_wl_client, resource *C.struct_wl_resource, id ObjectID) XDGPositioner
	GetXDGSurface(client *C.struct_wl_client, resource *C.struct_wl_resource, id ObjectID, surface *C.struct_wl_resource) XDGSurface
	Pong(client *C.struct_wl_client, resource *C.struct_wl_resource, serial C.uint32_t)
}

type XDGPositioner interface {
	Destroy(client *C.struct_wl_client, resource *C.struct_wl_resource)
	SetSize(client *C.struct_wl_client, resource *C.struct_wl_resource, width, height C.int32_t)
	SetAnchorRect(client *C.struct_wl_client, resource *C.struct_wl_resource, x, y, width, height C.int32_t)
	SetAnchor(client *C.struct_wl_client, resource *C.struct_wl_resource, anchor C.uint32_t)
	SetGravity(client *C.struct_wl_client, resource *C.struct_wl_resource, gravity C.uint32_t)
	SetConstraintAdjustment(client *C.struct_wl_client, resource *C.struct_wl_resource, constraintAdjustment C.uint32_t)
	SetOffset(client *C.struct_wl_client, resource *C.struct_wl_resource, x, y C.int32_t)
}

type XDGSurface interface {
	Destroy(client *C.struct_wl_client, resource *C.struct_wl_resource)
	GetToplevel(client *C.struct_wl_client, resource *C.struct_wl_resource, id ObjectID) XDGToplevel
	GetPopup(client *C.struct_wl_client, resource *C.struct_wl_resource, id ObjectID, parent *C.struct_wl_resource, positioner *C.struct_wl_resource)
	SetWindowGeometry(client *C.struct_wl_client, resource *C.struct_wl_resource, x, y, width, height C.int32_t)
	AckConfigure(client *C.struct_wl_client, resource *C.struct_wl_resource, serial C.uint32_t)
}

type XDGToplevel interface {
	DestroyGo(client *C.struct_wl_client, resource *C.struct_wl_resource)
	SetParentGo(client *C.struct_wl_client, resource *C.struct_wl_resource, parent *C.struct_wl_resource)
	SetTitleGo(client *C.struct_wl_client, resource *C.struct_wl_resource, title *C.char)
	SetAppIDGo(client *C.struct_wl_client, resource *C.struct_wl_resource, app_id *C.char)
	ShowWindowMenuGo(client *C.struct_wl_client, resource *C.struct_wl_resource, seat *C.struct_wl_resource, serial C.uint32_t, x, y C.int32_t)
	MoveGo(client *C.struct_wl_client, resource *C.struct_wl_resource, seat *C.struct_wl_resource, serial C.uint32_t)
	ResizeGo(client *C.struct_wl_client, resource *C.struct_wl_resource, seat *C.struct_wl_resource, serial C.uint32_t, edges C.uint32_t)
	SetMaxSizeGo(client *C.struct_wl_client, resource *C.struct_wl_resource, width, height C.int32_t)
	SetMinSizeGo(client *C.struct_wl_client, resource *C.struct_wl_resource, width, height C.int32_t)
	SetMaximizedGo(client *C.struct_wl_client, resource *C.struct_wl_resource)
	UnsetMaximizedGo(client *C.struct_wl_client, resource *C.struct_wl_resource)
	SetFullscreenGo(client *C.struct_wl_client, resource *C.struct_wl_resource, output *C.struct_wl_resource)
	UnsetFullscreenGo(client *C.struct_wl_client, resource *C.struct_wl_resource)
	SetMinimizedGo(client *C.struct_wl_client, resource *C.struct_wl_resource)
}

type Surface interface {
	Destroy(client *C.struct_wl_client, resource *C.struct_wl_resource)
	Attach(client *C.struct_wl_client, resource *C.struct_wl_resource, buffer C.struct_wl_resource, x C.int32_t, y C.int32_t)
	Damage(client *C.struct_wl_client, resource *C.struct_wl_resource, x C.int32_t, y C.int32_t, width C.int32_t, height C.int32_t)
	Frame(client *C.struct_wl_client, resource *C.struct_wl_resource, callback C.uint32_t)
	SetOpaqueRegion(client *C.struct_wl_client, resource *C.struct_wl_resource, region *C.struct_wl_resource)
	SetInputRegion(client *C.struct_wl_client, resource *C.struct_wl_resource, region *C.struct_wl_resource)
	Commit(client *C.struct_wl_client, resource *C.struct_wl_resource)
	SetBufferTransform(client *C.struct_wl_client, resource *C.struct_wl_resource, transform C.int32_t)
	SetBufferScale(client *C.struct_wl_client, resource *C.struct_wl_resource, scale C.int32_t)
	// DamageBuffer()
}

type Region interface {
	Destroy(client *C.struct_wl_client, resource *C.struct_wl_resource)
	Add(client *C.struct_wl_client, resource *C.struct_wl_resource, x C.int32_t, y C.int32_t, width C.int32_t, height C.int32_t)
	Subtract(client *C.struct_wl_client, resource *C.struct_wl_resource, x C.int32_t, y C.int32_t, width C.int32_t, height C.int32_t)
}

type Buffer interface {
	Destroy()
}

var compositors = make(map[uintptr]Compositor)
var shells = make(map[uintptr]Shell)
var xdgWmBases = make(map[uintptr]XdgWmBase)
var seats = make(map[uintptr]Seat)
var surfaces = make(map[uintptr]Surface)
var regions = make(map[uintptr]Region)
var xdgPositioners = make(map[uintptr]XDGPositioner)
var xdgSurfaces = make(map[uintptr]XDGSurface)
var xdgToplevels = make(map[uintptr]XDGToplevel)

var idStart = uintptr(C.malloc(1e6))
var idEnd = idStart + 1e6 - 1
var idCur = idStart

//export wayfarerCompositorCreateSurfaceGo
func wayfarerCompositorCreateSurfaceGo(client *C.struct_wl_client, resource *C.struct_wl_resource, id C.uint32_t) {
	surface := compositors[uintptr(resource.data)].CreateSurface(client, resource, ObjectID(id))
	idCur++
	surfaces[idCur] = surface
	surfaceResource := C.wl_resource_create(client, &C.wl_surface_interface, 3, C.uint(id))
	C.wl_resource_set_implementation(surfaceResource, unsafe.Pointer(&C.wayfarerSurfaceInterface), unsafe.Pointer(idCur), nil)
}

//export wayfarerCompositorCreateRegionGo
func wayfarerCompositorCreateRegionGo(client *C.struct_wl_client, resource *C.struct_wl_resource, id C.uint32_t) {
	region := compositors[uintptr(resource.data)].CreateRegion(client, resource, ObjectID(id))
	idCur++
	regions[idCur] = region
	regionResource := C.wl_resource_create(client, &C.wl_region_interface, 1, C.uint(id))
	C.wl_resource_set_implementation(regionResource, unsafe.Pointer(&C.wayfarerRegionInterface), unsafe.Pointer(idCur), nil)
}

//export wayfarerCompositorBindGo
func wayfarerCompositorBindGo(client *C.struct_wl_client, data unsafe.Pointer, version C.uint32_t, id C.uint32_t) {
	fmt.Println("Go: compositor bind")
	resource := C.wl_resource_create(client, &C.wl_compositor_interface, 1, id)
	C.wl_resource_set_implementation(resource, unsafe.Pointer(&C.wayfarerCompositorInterface), data, nil)
}

//export wayfarerShellGetShellSurfaceGo
func wayfarerShellGetShellSurfaceGo(client *C.struct_wl_client, resource *C.struct_wl_resource, id C.uint32_t, surface *C.struct_wl_resource) {
	shells[uintptr(resource.data)].GetShellSurface(client, resource, ObjectID(id), surface)
}

//export wayfarerShellBindGo
func wayfarerShellBindGo(client *C.struct_wl_client, data unsafe.Pointer, version C.uint32_t, id C.uint32_t) {
	fmt.Println("Go: shell bind")
	resource := C.wl_resource_create(client, &C.wl_shell_interface, 1, id)
	C.wl_resource_set_implementation(resource, unsafe.Pointer(&C.wayfarerShellInterface), data, nil)
}

//export wayfarerXdgWmBaseDestroyGo
func wayfarerXdgWmBaseDestroyGo(client *C.struct_wl_client, resource *C.struct_wl_resource) {
	xdgWmBases[uintptr(resource.data)].Destroy(client, resource)
}

//export wayfarerXdgWmBaseCreatePositionerGo
func wayfarerXdgWmBaseCreatePositionerGo(client *C.struct_wl_client, resource *C.struct_wl_resource, id C.uint32_t) {
	xdgWmBases[uintptr(resource.data)].CreatePositioner(client, resource, ObjectID(id))
}

//export wayfarerXdgWmBaseGetXDGSurfaceGo
func wayfarerXdgWmBaseGetXDGSurfaceGo(client *C.struct_wl_client, resource *C.struct_wl_resource, id C.uint32_t, surface *C.struct_wl_resource) {
	xdgSurface := xdgWmBases[uintptr(resource.data)].GetXDGSurface(client, resource, ObjectID(id), surface)
	idCur++
	xdgSurfaces[idCur] = xdgSurface
	xdgSurfaceResource := C.wl_resource_create(client, &C.xdg_surface_interface, 1, id)
	C.wl_resource_set_implementation(xdgSurfaceResource, unsafe.Pointer(&C.wayfarerXDGSurfaceInterface), unsafe.Pointer(idCur), nil)
}

//export wayfarerXdgWmBasePongGo
func wayfarerXdgWmBasePongGo(client *C.struct_wl_client, resource *C.struct_wl_resource, serial C.uint32_t) {
	xdgWmBases[uintptr(resource.data)].Pong(client, resource, serial)
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
	surfaces[uintptr(resource.data)].Destroy(client, resource)
}

//export wayfarerSurfaceAttachGo
func wayfarerSurfaceAttachGo(client *C.struct_wl_client, resource *C.struct_wl_resource, buffer C.struct_wl_resource, x C.int32_t, y C.int32_t) {
	surfaces[uintptr(resource.data)].Attach(client, resource, buffer, x, y)
}

//export wayfarerSurfaceDamageGo
func wayfarerSurfaceDamageGo(client *C.struct_wl_client, resource *C.struct_wl_resource, x C.int32_t, y C.int32_t, width C.int32_t, height C.int32_t) {
	surfaces[uintptr(resource.data)].Damage(client, resource, x, y, width, height)
}

//export wayfarerSurfaceFrameGo
func wayfarerSurfaceFrameGo(client *C.struct_wl_client, resource *C.struct_wl_resource, callback C.uint32_t) {
	surfaces[uintptr(resource.data)].Frame(client, resource, callback)
}

//export wayfarerSurfaceSetOpaqueRegionGo
func wayfarerSurfaceSetOpaqueRegionGo(client *C.struct_wl_client, resource *C.struct_wl_resource, region *C.struct_wl_resource) {
	surfaces[uintptr(resource.data)].SetOpaqueRegion(client, resource, region)
}

//export wayfarerSurfaceSetInputRegionGo
func wayfarerSurfaceSetInputRegionGo(client *C.struct_wl_client, resource *C.struct_wl_resource, region *C.struct_wl_resource) {
	surfaces[uintptr(resource.data)].SetInputRegion(client, resource, region)
}

//export wayfarerSurfaceCommitGo
func wayfarerSurfaceCommitGo(client *C.struct_wl_client, resource *C.struct_wl_resource) {
	surfaces[uintptr(resource.data)].Commit(client, resource)
}

//export wayfarerSurfaceSetBufferTransformGo
func wayfarerSurfaceSetBufferTransformGo(client *C.struct_wl_client, resource *C.struct_wl_resource, transform C.int32_t) {
	surfaces[uintptr(resource.data)].SetBufferTransform(client, resource, transform)
}

//export wayfarerSurfaceSetBufferScaleGo
func wayfarerSurfaceSetBufferScaleGo(client *C.struct_wl_client, resource *C.struct_wl_resource, scale C.int32_t) {
	surfaces[uintptr(resource.data)].SetBufferScale(client, resource, scale)
}

//export wayfarerRegionDestroyGo
func wayfarerRegionDestroyGo(client *C.struct_wl_client, resource *C.struct_wl_resource) {
	regions[uintptr(resource.data)].Destroy(client, resource)
}

//export wayfarerRegionAddGo
func wayfarerRegionAddGo(client *C.struct_wl_client, resource *C.struct_wl_resource, x C.int32_t, y C.int32_t, width C.int32_t, height C.int32_t) {
	regions[uintptr(resource.data)].Add(client, resource, x, y, width, height)
}

//export wayfarerRegionSubtractGo
func wayfarerRegionSubtractGo(client *C.struct_wl_client, resource *C.struct_wl_resource, x C.int32_t, y C.int32_t, width C.int32_t, height C.int32_t) {
	regions[uintptr(resource.data)].Subtract(client, resource, x, y, width, height)
}

//export wayfarerXDGPositionerDestroyGo
func wayfarerXDGPositionerDestroyGo(client *C.struct_wl_client, resource *C.struct_wl_resource) {
	xdgPositioners[uintptr(resource.data)].Destroy(client, resource)
}

//export wayfarerXDGPositionerSetSizeGo
func wayfarerXDGPositionerSetSizeGo(client *C.struct_wl_client, resource *C.struct_wl_resource, width, height C.int32_t) {
	xdgPositioners[uintptr(resource.data)].SetSize(client, resource, width, height)
}

//export wayfarerXDGPositionerSetAnchorRectGo
func wayfarerXDGPositionerSetAnchorRectGo(client *C.struct_wl_client, resource *C.struct_wl_resource, x, y, width, height C.int32_t) {
	xdgPositioners[uintptr(resource.data)].SetAnchorRect(client, resource, x, y, width, height)
}

//export wayfarerXDGPositionerSetAnchorGo
func wayfarerXDGPositionerSetAnchorGo(client *C.struct_wl_client, resource *C.struct_wl_resource, anchor C.uint32_t) {
	xdgPositioners[uintptr(resource.data)].SetAnchor(client, resource, anchor)
}

//export wayfarerXDGPositionerSetGravityGo
func wayfarerXDGPositionerSetGravityGo(client *C.struct_wl_client, resource *C.struct_wl_resource, gravity C.uint32_t) {
	xdgPositioners[uintptr(resource.data)].SetGravity(client, resource, gravity)
}

//export wayfarerXDGPositionerSetConstraintAdjustmentGo
func wayfarerXDGPositionerSetConstraintAdjustmentGo(client *C.struct_wl_client, resource *C.struct_wl_resource, constraintAdjustment C.uint32_t) {
	xdgPositioners[uintptr(resource.data)].SetConstraintAdjustment(client, resource, constraintAdjustment)
}

//export wayfarerXDGPositionerSetOffsetGo
func wayfarerXDGPositionerSetOffsetGo(client *C.struct_wl_client, resource *C.struct_wl_resource, x, y C.int32_t) {
	xdgPositioners[uintptr(resource.data)].SetOffset(client, resource, x, y)
}

//export wayfarerXDGSurfaceDestroyGo
func wayfarerXDGSurfaceDestroyGo(client *C.struct_wl_client, resource *C.struct_wl_resource) {
	xdgSurfaces[uintptr(resource.data)].Destroy(client, resource)
}

//export wayfarerXDGSurfaceGetToplevelGo
func wayfarerXDGSurfaceGetToplevelGo(client *C.struct_wl_client, resource *C.struct_wl_resource, id C.uint32_t) {
	toplevel := xdgSurfaces[uintptr(resource.data)].GetToplevel(client, resource, ObjectID(id))
	idCur++
	xdgToplevels[idCur] = toplevel
	toplevelResource := C.wl_resource_create(client, &C.xdg_toplevel_interface, 1, id)
	C.wl_resource_set_implementation(toplevelResource, unsafe.Pointer(&C.wayfarerXDGToplevelInterface), unsafe.Pointer(idCur), nil)
}

//export wayfarerXDGSurfaceGetPopupGo
func wayfarerXDGSurfaceGetPopupGo(client *C.struct_wl_client, resource *C.struct_wl_resource, id C.uint32_t, parent *C.struct_wl_resource, positioner *C.struct_wl_resource) {
	xdgSurfaces[uintptr(resource.data)].GetPopup(client, resource, ObjectID(id), parent, positioner)
}

//export wayfarerXDGSurfaceSetWindowGeometryGo
func wayfarerXDGSurfaceSetWindowGeometryGo(client *C.struct_wl_client, resource *C.struct_wl_resource, x, y, width, height C.int32_t) {
	xdgSurfaces[uintptr(resource.data)].SetWindowGeometry(client, resource, x, y, width, height)
}

//export wayfarerXDGSurfaceAckConfigureGo
func wayfarerXDGSurfaceAckConfigureGo(client *C.struct_wl_client, resource *C.struct_wl_resource, serial C.uint32_t) {
	xdgSurfaces[uintptr(resource.data)].AckConfigure(client, resource, serial)
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
