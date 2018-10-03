#include <wayland-server.h>

// wl_compositor
void wayfarerCompositorCreateSurface(struct wl_client *client, struct wl_resource *resource, uint32_t id);
void wayfarerCompositorCreateRegion(struct wl_client *client, struct wl_resource *resource, uint32_t id);
void wayfarerCompositorBind(struct wl_client *client, void *data, uint32_t version, uint32_t id);

// wl_shell
void wayfarerShellGetShellSurface(struct wl_client *client, struct wl_resource *resource, uint32_t id, struct wl_resource *surface);
void wayfarerShellBind(struct wl_client *client, void *data, uint32_t version, uint32_t id);

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
// void wayfarerSurfaceDamageBuffer

// wl_region
void wayfarerRegionDestroy();
void wayfarerRegionAdd();
void wayfarerRegionSubtract();

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

extern struct wl_compositor_interface wayfarerCompositorInterface;
extern struct wl_shell_interface wayfarerShellInterface;
extern struct xdg_wm_base_interface wayfarerXdgWmBaseInterface;
extern struct wl_surface_interface wayfarerSurfaceInterface;
extern struct wl_region_interface wayfarerRegionInterface;
extern struct xdg_positioner_interface wayfarerXDGPositionerInterface;
extern struct xdg_surface_interface wayfarerXDGSurfaceInterface;
extern struct xdg_toplevel_interface wayfarerXDGToplevelInterface;
