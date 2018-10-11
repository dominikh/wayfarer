#include <wayland-server.h>

void wayfarerCompositorBind(struct wl_client *client, void *data, uint32_t version, uint32_t id);
void wayfarerOutputBind(struct wl_client *client, void *data, uint32_t version, uint32_t id);
void wayfarerShellBind(struct wl_client *client, void *data, uint32_t version, uint32_t id);
void wayfarerSeatBind(struct wl_client *client, void *data, uint32_t version, uint32_t id);
void wayfarerXdgWmBaseBind(struct wl_client *client, void *data, uint32_t version, uint32_t id);
void wayfarerDataDeviceManagerBind(struct wl_client *client, void *data, uint32_t version, uint32_t id);

extern struct wl_compositor_interface wayfarerCompositorInterface;
extern struct wl_output_interface wayfarerOutputInterface;
extern struct wl_shell_interface wayfarerShellInterface;
extern struct xdg_wm_base_interface wayfarerXdgWmBaseInterface;
extern struct wl_surface_interface wayfarerSurfaceInterface;
extern struct wl_region_interface wayfarerRegionInterface;
extern struct xdg_positioner_interface wayfarerXDGPositionerInterface;
extern struct xdg_surface_interface wayfarerXDGSurfaceInterface;
extern struct xdg_toplevel_interface wayfarerXDGToplevelInterface;
extern struct wl_seat_interface wayfarerSeatInterface;
extern struct wl_data_device_manager_interface wayfarerDataDeviceManagerInterface;
extern struct wl_data_device_interface wayfarerDataDeviceInterface;
extern struct wl_data_source_interface wayfarerDataSourceInterface;

extern struct wl_keyboard_interface wayfarerKeyboardInterface;
extern struct wl_pointer_interface wayfarerPointerInterface;
extern struct wl_touch_interface wayfarerTouchInterface;
