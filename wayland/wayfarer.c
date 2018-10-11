#include "xdg_shell_server.h"
#include <wayland-server.h>
#include <stdio.h>


// wl_compositor
void wayfarerCompositorCreateSurface(struct wl_client *client, struct wl_resource *resource, uint32_t id);
void wayfarerCompositorCreateRegion(struct wl_client *client, struct wl_resource *resource, uint32_t id);
void wayfarerCompositorBind(struct wl_client *client, void *data, uint32_t version, uint32_t id);

// wl_seat
void wayfarerSeatGetPointer(struct wl_client *client, struct wl_resource *resource, uint32_t id);
void wayfarerSeatGetKeyboard(struct wl_client *client, struct wl_resource *resource, uint32_t id);
void wayfarerSeatGetTouch(struct wl_client *client, struct wl_resource *resource, uint32_t id);
void wayfarerSeatRelease(struct wl_client *client, struct wl_resource *resource);

// wl_data_device_manager
void wayfarerDataDeviceManagerCreateDataSource(struct wl_client *client, struct wl_resource *resource, uint32_t id);
void wayfarerDataDeviceManagerGetDataDevice(struct wl_client *client, struct wl_resource *resource, uint32_t id, struct wl_resource *seat);
void wayfarerDataDeviceManagerBind(struct wl_client *client, void *data, uint32_t version, uint32_t id);

// wl_data_device
void wayfarerDataDeviceStartDrag(struct wl_client *client, struct wl_resource *resource, struct wl_resource *source, struct wl_resource *origin, struct wl_resource *icon, uint32_t serial);
void wayfarerDataDeviceSetSelection(struct wl_client *client, struct wl_resource *resource, struct wl_resource *source, uint32_t serial);
void wayfarerDataDeviceRelease(struct wl_client *client, struct wl_resource *resource);

// wl_data_source
void wayfarerDataSourceOffer(struct wl_client *client, struct wl_resource *resource, const char *mime_type);
void wayfarerDataSourceDestroy(struct wl_client *client, struct wl_resource *resource);
void wayfarerDataSourceSetActions(struct wl_client *client, struct wl_resource *resource, uint32_t dnd_actions);

// wl_output
void wayfarerOutputRelease(struct wl_client *client, struct wl_resource *resource);
void wayfarerOutputBind(struct wl_client *client, void *data, uint32_t version, uint32_t id);

// wl_shell
void wayfarerShellBind(struct wl_client *client, void *data, uint32_t version, uint32_t id);
void wayfarerShellGetShellSurface(struct wl_client *client, struct wl_resource *resource, uint32_t id, struct wl_resource *surface);

// wl_seat
void wayfarerSeatBind(struct wl_client *client, void *data, uint32_t version, uint32_t id);

// wl_surface
void wayfarerSurfaceDestroy(struct wl_client *client, struct wl_resource *resource);
void wayfarerSurfaceAttach(struct wl_client *client, struct wl_resource *resource, struct wl_resource *buffer, int32_t x, int32_t y);
void wayfarerSurfaceDamage(struct wl_client *client, struct wl_resource *resource, int32_t x, int32_t y, int32_t width, int32_t height);
void wayfarerSurfaceFrame(struct wl_client *client, struct wl_resource *resource, uint32_t callback);
void wayfarerSurfaceSetOpaqueRegion(struct wl_client *client, struct wl_resource *resource, struct wl_resource *region);
void wayfarerSurfaceSetInputRegion(struct wl_client *client, struct wl_resource *resource, struct wl_resource *region);
void wayfarerSurfaceCommit(struct wl_client *client, struct wl_resource *resource);
void wayfarerSurfaceSetBufferTransform(struct wl_client *client, struct wl_resource *resource, int32_t transform);
void wayfarerSurfaceSetBufferScale(struct wl_client *client, struct wl_resource *resource, int32_t scale);

// wl_region
void wayfarerRegionDestroy(struct wl_client *client, struct wl_resource *resource);
void wayfarerRegionAdd(struct wl_client *client, struct wl_resource *resource, int32_t x, int32_t y, int32_t width, int32_t height);
void wayfarerRegionSubtract(struct wl_client *client, struct wl_resource *resource, int32_t x, int32_t y, int32_t width, int32_t height);

// xdg_wm_base
void wayfarerXdgWmBaseDestroy(struct wl_client *client, struct wl_resource *resource);
void wayfarerXdgWmBaseCreatePositioner(struct wl_client *client, struct wl_resource *resource, uint32_t id);
void wayfarerXdgWmBaseGetXDGSurface(struct wl_client *client, struct wl_resource *resource, uint32_t id, struct wl_resource *surface);
void wayfarerXdgWmBasePong(struct wl_client *client, struct wl_resource *resource, uint32_t serial);
void wayfarerXdgWmBaseBind(struct wl_client *client, void *data, uint32_t version, uint32_t id);

// xdg_positioner
void wayfarerXDGPositionerDestroy(struct wl_client *client, struct wl_resource *resource);
void wayfarerXDGPositionerSetSize(struct wl_client *client, struct wl_resource *resource, int32_t width, int32_t height);
void wayfarerXDGPositionerSetAnchorRect(struct wl_client *client, struct wl_resource *resource, int32_t x, int32_t y, int32_t width, int32_t height);
void wayfarerXDGPositionerSetAnchor(struct wl_client *client, struct wl_resource *resource, uint32_t anchor);
void wayfarerXDGPositionerSetGravity(struct wl_client *client, struct wl_resource *resource, uint32_t gravity);
void wayfarerXDGPositionerSetConstraintAdjustment(struct wl_client *client, struct wl_resource *resource, uint32_t constraint_adjustment);
void wayfarerXDGPositionerSetOffset(struct wl_client *client, struct wl_resource *resource, int32_t x, int32_t y);

// xdg_surface
void wayfarerXDGSurfaceDestroy(struct wl_client *client, struct wl_resource *resource);
void wayfarerXDGSurfaceGetToplevel(struct wl_client *client, struct wl_resource *resource, uint32_t id);
void wayfarerXDGSurfaceGetPopup(struct wl_client *client, struct wl_resource *resource, uint32_t id, struct wl_resource *parent, struct wl_resource *positioner);
void wayfarerXDGSurfaceSetWindowGeometry(struct wl_client *client, struct wl_resource *resource, int32_t x, int32_t y, int32_t width, int32_t height);
void wayfarerXDGSurfaceAckConfigure(struct wl_client *client, struct wl_resource *resource, uint32_t serial);

// xdg_toplevel
void wayfarerXDGToplevelDestroy(struct wl_client *client, struct wl_resource *resource);
void wayfarerXDGToplevelSetParent(struct wl_client *client, struct wl_resource *resource, struct wl_resource *parent);
void wayfarerXDGToplevelSetTitle(struct wl_client *client, struct wl_resource *resource, const char *title);
void wayfarerXDGToplevelSetAppID(struct wl_client *client, struct wl_resource *resource, const char *app_id);
void wayfarerXDGToplevelShowWindowMenu(struct wl_client *client, struct wl_resource *resource, struct wl_resource *seat, uint32_t serial, int32_t x, int32_t y);
void wayfarerXDGToplevelMove(struct wl_client *client, struct wl_resource *resource, struct wl_resource *seat, uint32_t serial);
void wayfarerXDGToplevelResize(struct wl_client *client, struct wl_resource *resource, struct wl_resource *seat, uint32_t serial, uint32_t edges);
void wayfarerXDGToplevelSetMaxSize(struct wl_client *client, struct wl_resource *resource, int32_t width, int32_t height);
void wayfarerXDGToplevelSetMinSize(struct wl_client *client, struct wl_resource *resource, int32_t width, int32_t height);
void wayfarerXDGToplevelSetMaximized(struct wl_client *client, struct wl_resource *resource);
void wayfarerXDGToplevelUnsetMaximized(struct wl_client *client, struct wl_resource *resource);
void wayfarerXDGToplevelSetFullscreen(struct wl_client *client, struct wl_resource *resource, struct wl_resource *output);
void wayfarerXDGToplevelUnsetFullscreen(struct wl_client *client, struct wl_resource *resource);
void wayfarerXDGToplevelSetMinimized(struct wl_client *client, struct wl_resource *resource);


struct wl_compositor_interface wayfarerCompositorInterface = {
	&wayfarerCompositorCreateSurface,
	&wayfarerCompositorCreateRegion,
};

struct wl_seat_interface wayfarerSeatInterface = {
	&wayfarerSeatGetPointer,
	&wayfarerSeatGetKeyboard,
	&wayfarerSeatGetTouch,
	&wayfarerSeatRelease,
};

struct wl_keyboard_interface wayfarerKeyboardInterface = {
	// XXX
};

struct wl_pointer_interface wayfarerPointerInterface = {
	// XXX
};

struct wl_touch_interface wayfarerTouchInterface = {
	// XXX
};

struct wl_data_device_manager_interface wayfarerDataDeviceManagerInterface = {
	&wayfarerDataDeviceManagerCreateDataSource,
	&wayfarerDataDeviceManagerGetDataDevice,
};

struct wl_data_device_interface wayfarerDataDeviceInterface = {
	&wayfarerDataDeviceStartDrag,
	&wayfarerDataDeviceSetSelection,
	&wayfarerDataDeviceRelease,
};

struct wl_data_source_interface wayfarerDataSourceInterface = {
	&wayfarerDataSourceOffer,
	&wayfarerDataSourceDestroy,
	&wayfarerDataSourceSetActions,
};

struct wl_output_interface wayfarerOutputInterface = {
	&wayfarerOutputRelease,
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
