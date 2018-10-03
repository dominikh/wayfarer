#include "wayfarer.h"
#include "xdg_shell_server.h"
#include <wayland-server.h>
#include <stdio.h>

struct wl_compositor_interface wayfarerCompositorInterface = {
	&wayfarerCompositorCreateSurface,
	&wayfarerCompositorCreateRegion,
};

struct wl_shell_interface wayfarerShellInterface = {
	&wayfarerShellGetShellSurface,
};

struct wl_surface_interface wayfarerSurfaceInterface = {
	&wayfarerSurfaceDestroy,
	&wayfarerSurfaceAttach,
	&wayfarerSurfaceDamage,
	&wayfarerSurfaceFrame,
	&wayfarerSurfaceSetOpaqueRegion,
	&wayfarerSurfaceSetInputRegion,
	&wayfarerSurfaceCommit,
	&wayfarerSurfaceSetBufferTransform,
	&wayfarerSurfaceSetBufferScale,
};

struct wl_region_interface wayfarerRegionInterface = {
	&wayfarerRegionDestroy,
	&wayfarerRegionAdd,
	&wayfarerRegionSubtract,
};

struct xdg_wm_base_interface wayfarerXdgWmBaseInterface = {
	&wayfarerXdgWmBaseDestroy,
	&wayfarerXdgWmBaseCreatePositioner,
	&wayfarerXdgWmBaseGetXDGSurface,
	&wayfarerXdgWmBasePong,
};

struct xdg_positioner_interface wayfarerXDGPositionerInterface = {
	&wayfarerXDGPositionerDestroy,
	&wayfarerXDGPositionerSetSize,
	&wayfarerXDGPositionerSetAnchorRect,
	&wayfarerXDGPositionerSetAnchor,
	&wayfarerXDGPositionerSetGravity,
	&wayfarerXDGPositionerSetConstraintAdjustment,
	&wayfarerXDGPositionerSetOffset,
};

struct xdg_surface_interface wayfarerXDGSurfaceInterface = {
	&wayfarerXDGSurfaceDestroy,
	&wayfarerXDGSurfaceGetToplevel,
	&wayfarerXDGSurfaceGetPopup,
	&wayfarerXDGSurfaceSetWindowGeometry,
	&wayfarerXDGSurfaceAckConfigure,
};

struct xdg_toplevel_interface wayfarerXDGToplevelInterface = {
	&wayfarerXDGToplevelDestroy,
	&wayfarerXDGToplevelSetParent,
	&wayfarerXDGToplevelSetTitle,
	&wayfarerXDGToplevelSetAppID,
	&wayfarerXDGToplevelShowWindowMenu,
	&wayfarerXDGToplevelMove,
	&wayfarerXDGToplevelResize,
	&wayfarerXDGToplevelSetMaxSize,
	&wayfarerXDGToplevelSetMinSize,
	&wayfarerXDGToplevelSetMaximized,
	&wayfarerXDGToplevelUnsetMaximized,
	&wayfarerXDGToplevelSetFullscreen,
	&wayfarerXDGToplevelUnsetFullscreen,
	&wayfarerXDGToplevelSetMinimized,
};

#define wayfarerTrace() printf("C: %s\n", __func__);

// wl_compositor
void wayfarerCompositorCreateSurfaceGo(struct wl_client *client, struct wl_resource *resource, uint32_t id);
void wayfarerCompositorCreateRegionGo(struct wl_client *client, struct wl_resource *resource, uint32_t id);
void wayfarerCompositorBindGo(struct wl_client *client, void *data, uint32_t version, uint32_t id);
void wayfarerCompositorCreateSurface(struct wl_client *client, struct wl_resource *resource, uint32_t id) {
	wayfarerCompositorCreateSurfaceGo(client, resource, id);
}
void wayfarerCompositorCreateRegion(struct wl_client *client, struct wl_resource *resource, uint32_t id) {
	wayfarerCompositorCreateRegionGo(client, resource, id);
}
void wayfarerCompositorBind(struct wl_client *client, void *data, uint32_t version, uint32_t id) {
	wayfarerCompositorBindGo(client, data, version, id);
}

// wl_shell
void wayfarerShellBindGo(struct wl_client *client, void *data, uint32_t version, uint32_t id);
void wayfarerShellGetShellSurfaceGo(struct wl_client *client, struct wl_resource *resource, uint32_t id, struct wl_resource *surface);
void wayfarerShellGetShellSurface(struct wl_client *client, struct wl_resource *resource, uint32_t id, struct wl_resource *surface) {
	wayfarerShellGetShellSurfaceGo(client, resource, id, surface);
}
void wayfarerShellBind(struct wl_client *client, void *data, uint32_t version, uint32_t id) {
	wayfarerShellBindGo(client, data, version, id);
}

// wl_seat
void wayfarerSeatBindGo(struct wl_client *client, void *data, uint32_t version, uint32_t id);
void wayfarerSeatBind(struct wl_client *client, void *data, uint32_t version, uint32_t id) {
	wayfarerSeatBindGo(client, data, version, id);
}

// wl_surface
void wayfarerSurfaceDestroyGo(struct wl_client *client, struct wl_resource *resource);
void wayfarerSurfaceAttachGo(struct wl_client *client, struct wl_resource *resource, struct wl_resource *buffer, int32_t x, int32_t y);
void wayfarerSurfaceDamageGo(struct wl_client *client, struct wl_resource *resource, int32_t x, int32_t y, int32_t width, int32_t height);
void wayfarerSurfaceFrameGo(struct wl_client *client, struct wl_resource *resource, uint32_t callback);
void wayfarerSurfaceSetOpaqueRegionGo(struct wl_client *client, struct wl_resource *resource, struct wl_resource *region);
void wayfarerSurfaceSetInputRegionGo(struct wl_client *client, struct wl_resource *resource, struct wl_resource *region);
void wayfarerSurfaceCommitGo(struct wl_client *client, struct wl_resource *resource);
void wayfarerSurfaceSetBufferTransformGo(struct wl_client *client, struct wl_resource *resource, int32_t transform);
void wayfarerSurfaceSetBufferScaleGo(struct wl_client *client, struct wl_resource *resource, int32_t scale);

void wayfarerSurfaceDestroy(struct wl_client *client, struct wl_resource *resource) {
	wayfarerSurfaceDestroyGo(client, resource);
}
void wayfarerSurfaceAttach(struct wl_client *client, struct wl_resource *resource, struct wl_resource *buffer, int32_t x, int32_t y) {
	wayfarerSurfaceAttachGo(client, resource, buffer, x, y);
}
void wayfarerSurfaceDamage(struct wl_client *client, struct wl_resource *resource, int32_t x, int32_t y, int32_t width, int32_t height) {
	wayfarerSurfaceDamageGo(client, resource, x, y, width, height);
}
void wayfarerSurfaceFrame(struct wl_client *client, struct wl_resource *resource, uint32_t callback) {
	wayfarerSurfaceFrameGo(client, resource, callback);
}
void wayfarerSurfaceSetOpaqueRegion(struct wl_client *client, struct wl_resource *resource, struct wl_resource *region) {
	wayfarerSurfaceSetOpaqueRegionGo(client, resource, region);
}
void wayfarerSurfaceSetInputRegion(struct wl_client *client, struct wl_resource *resource, struct wl_resource *region) {
	wayfarerSurfaceSetInputRegionGo(client, resource, region);
}
void wayfarerSurfaceCommit(struct wl_client *client, struct wl_resource *resource) {
	wayfarerSurfaceCommitGo(client, resource);
}
void wayfarerSurfaceSetBufferTransform(struct wl_client *client, struct wl_resource *resource, int32_t transform) {
	wayfarerSurfaceSetBufferTransformGo(client, resource, transform);
}
void wayfarerSurfaceSetBufferScale(struct wl_client *client, struct wl_resource *resource, int32_t scale) {
	wayfarerSurfaceSetBufferScaleGo(client, resource, scale);
}

// wl_region
void wayfarerRegionDestroyGo(struct wl_client *client, struct wl_resource *resource);
void wayfarerRegionAddGo(struct wl_client *client, struct wl_resource *resource, int32_t x, int32_t y, int32_t width, int32_t height);
void wayfarerRegionSubtractGo(struct wl_client *client, struct wl_resource *resource, int32_t x, int32_t y, int32_t width, int32_t height);
void wayfarerRegionDestroy(struct wl_client *client, struct wl_resource *resource) {
	wayfarerRegionDestroyGo(client, resource);
}
void wayfarerRegionAdd(struct wl_client *client, struct wl_resource *resource, int32_t x, int32_t y, int32_t width, int32_t height) {
	wayfarerRegionAddGo(client, resource, x, y, width, height);
}
void wayfarerRegionSubtract(struct wl_client *client, struct wl_resource *resource, int32_t x, int32_t y, int32_t width, int32_t height) {
	wayfarerRegionSubtractGo(client, resource, x, y, width, height);
}


// xdg_wm_base
void wayfarerXdgWmBaseDestroyGo(struct wl_client *client, struct wl_resource *resource);
void wayfarerXdgWmBaseCreatePositionerGo(struct wl_client *client, struct wl_resource *resource, uint32_t id);
void wayfarerXdgWmBaseGetXDGSurfaceGo(struct wl_client *client, struct wl_resource *resource, uint32_t id, struct wl_resource *surface);
void wayfarerXdgWmBasePongGo(struct wl_client *client, struct wl_resource *resource, uint32_t serial);
void wayfarerXdgWmBaseBindGo(struct wl_client *client, void *data, uint32_t version, uint32_t id);
void wayfarerXdgWmBaseDestroy(struct wl_client *client, struct wl_resource *resource) {
	wayfarerXdgWmBaseDestroyGo(client, resource);
}
void wayfarerXdgWmBaseCreatePositioner(struct wl_client *client, struct wl_resource *resource, uint32_t id) {
	wayfarerXdgWmBaseCreatePositionerGo(client, resource, id);
}
void wayfarerXdgWmBaseGetXDGSurface(struct wl_client *client, struct wl_resource *resource, uint32_t id, struct wl_resource *surface) {
	wayfarerXdgWmBaseGetXDGSurfaceGo(client, resource, id, surface);
}
void wayfarerXdgWmBasePong(struct wl_client *client, struct wl_resource *resource, uint32_t serial) {
	wayfarerXdgWmBasePongGo(client, resource, serial);
}
void wayfarerXdgWmBaseBind(struct wl_client *client, void *data, uint32_t version, uint32_t id) {
	wayfarerXdgWmBaseBindGo(client, data, version, id);
}


// xdg_positioner
void wayfarerXDGPositionerDestroyGo(struct wl_client *client, struct wl_resource *resource);
void wayfarerXDGPositionerSetSizeGo(struct wl_client *client, struct wl_resource *resource, int32_t width, int32_t height);
void wayfarerXDGPositionerSetAnchorRectGo(struct wl_client *client, struct wl_resource *resource, int32_t x, int32_t y, int32_t width, int32_t height);
void wayfarerXDGPositionerSetAnchorGo(struct wl_client *client, struct wl_resource *resource, uint32_t anchor);
void wayfarerXDGPositionerSetGravityGo(struct wl_client *client, struct wl_resource *resource, uint32_t gravity);
void wayfarerXDGPositionerSetConstraintAdjustmentGo(struct wl_client *client, struct wl_resource *resource, uint32_t constraint_adjustment);
void wayfarerXDGPositionerSetOffsetGo(struct wl_client *client, struct wl_resource *resource, int32_t x, int32_t y);
void wayfarerXDGPositionerDestroy(struct wl_client *client, struct wl_resource *resource) {
	wayfarerXDGPositionerDestroyGo(client, resource);
}
void wayfarerXDGPositionerSetSize(struct wl_client *client, struct wl_resource *resource, int32_t width, int32_t height) {
	wayfarerXDGPositionerSetSizeGo(client, resource, width, height);
}
void wayfarerXDGPositionerSetAnchorRect(struct wl_client *client, struct wl_resource *resource, int32_t x, int32_t y, int32_t width, int32_t height) {
	wayfarerXDGPositionerSetAnchorRectGo(client, resource, x, y, width, height);
}
void wayfarerXDGPositionerSetAnchor(struct wl_client *client, struct wl_resource *resource, uint32_t anchor) {
	wayfarerXDGPositionerSetAnchorGo(client, resource, anchor);
}
void wayfarerXDGPositionerSetGravity(struct wl_client *client, struct wl_resource *resource, uint32_t gravity) {
	wayfarerXDGPositionerSetGravityGo(client, resource, gravity);
}
void wayfarerXDGPositionerSetConstraintAdjustment(struct wl_client *client, struct wl_resource *resource, uint32_t constraint_adjustment) {
	wayfarerXDGPositionerSetConstraintAdjustmentGo(client, resource, constraint_adjustment);
}
void wayfarerXDGPositionerSetOffset(struct wl_client *client, struct wl_resource *resource, int32_t x, int32_t y) {
	wayfarerXDGPositionerSetOffsetGo(client, resource, x, y);
}

// xdg_surface
void wayfarerXDGSurfaceDestroyGo(struct wl_client *client, struct wl_resource *resource);
void wayfarerXDGSurfaceGetToplevelGo(struct wl_client *client, struct wl_resource *resource, uint32_t id);
void wayfarerXDGSurfaceGetPopupGo(struct wl_client *client, struct wl_resource *resource, uint32_t id, struct wl_resource *parent, struct wl_resource *positioner);
void wayfarerXDGSurfaceSetWindowGeometryGo(struct wl_client *client, struct wl_resource *resource, int32_t x, int32_t y, int32_t width, int32_t height);
void wayfarerXDGSurfaceAckConfigureGo(struct wl_client *client, struct wl_resource *resource, uint32_t serial);
void wayfarerXDGSurfaceDestroy(struct wl_client *client, struct wl_resource *resource) {
	wayfarerXDGSurfaceDestroyGo(client, resource);
}
void wayfarerXDGSurfaceGetToplevel(struct wl_client *client, struct wl_resource *resource, uint32_t id) {
	wayfarerXDGSurfaceGetToplevelGo(client, resource, id);
}
void wayfarerXDGSurfaceGetPopup(struct wl_client *client, struct wl_resource *resource, uint32_t id, struct wl_resource *parent, struct wl_resource *positioner) {
	wayfarerXDGSurfaceGetPopupGo(client, resource, id, parent, positioner);
}
void wayfarerXDGSurfaceSetWindowGeometry(struct wl_client *client, struct wl_resource *resource, int32_t x, int32_t y, int32_t width, int32_t height) {
	wayfarerXDGSurfaceSetWindowGeometryGo(client, resource, x, y, width, height);
}
void wayfarerXDGSurfaceAckConfigure(struct wl_client *client, struct wl_resource *resource, uint32_t serial) {
	wayfarerXDGSurfaceAckConfigureGo(client, resource, serial);
}

// xdg_toplevel
void wayfarerXDGToplevelDestroyGo(struct wl_client *client, struct wl_resource *resource);
void wayfarerXDGToplevelSetParentGo(struct wl_client *client, struct wl_resource *resource, struct wl_resource *parent);
void wayfarerXDGToplevelSetTitleGo(struct wl_client *client, struct wl_resource *resource, const char *title);
void wayfarerXDGToplevelSetAppIDGo(struct wl_client *client, struct wl_resource *resource, const char *app_id);
void wayfarerXDGToplevelShowWindowMenuGo(struct wl_client *client, struct wl_resource *resource, struct wl_resource *seat, uint32_t serial, int32_t x, int32_t y);
void wayfarerXDGToplevelMoveGo(struct wl_client *client, struct wl_resource *resource, struct wl_resource *seat, uint32_t serial);
void wayfarerXDGToplevelResizeGo(struct wl_client *client, struct wl_resource *resource, struct wl_resource *seat, uint32_t serial, uint32_t edges);
void wayfarerXDGToplevelSetMaxSizeGo(struct wl_client *client, struct wl_resource *resource, int32_t width, int32_t height);
void wayfarerXDGToplevelSetMinSizeGo(struct wl_client *client, struct wl_resource *resource, int32_t width, int32_t height);
void wayfarerXDGToplevelSetMaximizedGo(struct wl_client *client, struct wl_resource *resource);
void wayfarerXDGToplevelUnsetMaximizedGo(struct wl_client *client, struct wl_resource *resource);
void wayfarerXDGToplevelSetFullscreenGo(struct wl_client *client, struct wl_resource *resource, struct wl_resource *output);
void wayfarerXDGToplevelUnsetFullscreenGo(struct wl_client *client, struct wl_resource *resource);
void wayfarerXDGToplevelSetMinimizedGo(struct wl_client *client, struct wl_resource *resource);

void wayfarerXDGToplevelDestroy(struct wl_client *client, struct wl_resource *resource) {
	wayfarerXDGToplevelDestroyGo(client, resource);
}
void wayfarerXDGToplevelSetParent(struct wl_client *client, struct wl_resource *resource, struct wl_resource *parent) {
	wayfarerXDGToplevelSetParentGo(client, resource, parent);
}
void wayfarerXDGToplevelSetTitle(struct wl_client *client, struct wl_resource *resource, const char *title) {
	wayfarerXDGToplevelSetTitleGo(client, resource, title);
}
void wayfarerXDGToplevelSetAppID(struct wl_client *client, struct wl_resource *resource, const char *app_id) {
	wayfarerXDGToplevelSetAppIDGo(client, resource, app_id);
}
void wayfarerXDGToplevelShowWindowMenu(struct wl_client *client, struct wl_resource *resource, struct wl_resource *seat, uint32_t serial, int32_t x, int32_t y) {
	wayfarerXDGToplevelShowWindowMenuGo(client, resource, seat, serial, x, y);
}
void wayfarerXDGToplevelMove(struct wl_client *client, struct wl_resource *resource, struct wl_resource *seat, uint32_t serial) {
	wayfarerXDGToplevelMoveGo(client, resource, seat, serial);
}
void wayfarerXDGToplevelResize(struct wl_client *client, struct wl_resource *resource, struct wl_resource *seat, uint32_t serial, uint32_t edges) {
	wayfarerXDGToplevelResizeGo(client, resource, seat, serial, edges);
}
void wayfarerXDGToplevelSetMaxSize(struct wl_client *client, struct wl_resource *resource, int32_t width, int32_t height) {
	wayfarerXDGToplevelSetMaxSizeGo(client, resource, width, height);
}
void wayfarerXDGToplevelSetMinSize(struct wl_client *client, struct wl_resource *resource, int32_t width, int32_t height) {
	wayfarerXDGToplevelSetMinSizeGo(client, resource, width, height);
}
void wayfarerXDGToplevelSetMaximized(struct wl_client *client, struct wl_resource *resource) {
	wayfarerXDGToplevelSetMaximizedGo(client, resource);
}
void wayfarerXDGToplevelUnsetMaximized(struct wl_client *client, struct wl_resource *resource) {
	wayfarerXDGToplevelUnsetMaximizedGo(client, resource);
}
void wayfarerXDGToplevelSetFullscreen(struct wl_client *client, struct wl_resource *resource, struct wl_resource *output) {
	wayfarerXDGToplevelSetFullscreenGo(client, resource, output);
}
void wayfarerXDGToplevelUnsetFullscreen(struct wl_client *client, struct wl_resource *resource) {
	wayfarerXDGToplevelUnsetFullscreenGo(client, resource);
}
void wayfarerXDGToplevelSetMinimized(struct wl_client *client, struct wl_resource *resource) {
	wayfarerXDGToplevelSetMinimizedGo(client, resource);
}
