const wlroots = @import("wlroots.zig");

test "Backend" {
    _ = wlroots.Backend;
    _ = wlroots.Backend.Impl;
    _ = wlroots.Backend.autocreate;
    _ = wlroots.Backend.start;
    _ = wlroots.Backend.multiBackendCreate;
    _ = wlroots.Backend.deinit;
    _ = wlroots.Backend.getRenderer;
    _ = wlroots.Backend.getSession;
    _ = wlroots.Backend.getPresentationClock;
    _ = wlroots.Backend.multiBackendAdd;
    _ = wlroots.Backend.multiBackendRemove;
    _ = wlroots.Backend.isMulti;
    _ = wlroots.Backend.multiIsEmpty;
    _ = wlroots.Backend.multiForEachBackend;
}

test "Buffer" {
    _ = wlroots.Buffer;
    _ = wlroots.Buffer.Impl;
    _ = wlroots.Buffer.init;
    _ = wlroots.Buffer.drop;
    _ = wlroots.Buffer.lock;
    _ = wlroots.Buffer.unlock;
    _ = wlroots.Buffer.get_dmabuf;
}

test "ClientBuffer" {
    _ = wlroots.ClientBuffer;
    _ = wlroots.ClientBuffer.applyDamage;
    _ = wlroots.ClientBuffer.import;
}

test "Compositor" {
    _ = wlroots.Compositor;
    _ = wlroots.Compositor.init;
}

test "Cursor" {
    _ = wlroots.Cursor;
    _ = wlroots.Cursor.init;
    _ = wlroots.Cursor.State;
    _ = wlroots.Cursor.deinit;
    _ = wlroots.Cursor.warp;
    _ = wlroots.Cursor.absoluteToLayoutCoords;
    _ = wlroots.Cursor.warpClosest;
    _ = wlroots.Cursor.warpAbsolute;
    _ = wlroots.Cursor.move;
    _ = wlroots.Cursor.setImage;
    _ = wlroots.Cursor.setSurface;
    _ = wlroots.Cursor.attachInputDevice;
    _ = wlroots.Cursor.detachInputDevice;
    _ = wlroots.Cursor.attachOutputLayout;
    _ = wlroots.Cursor.mapToOutput;
    _ = wlroots.Cursor.mapInputToOutput;
    _ = wlroots.Cursor.mapToRegion;
    _ = wlroots.Cursor.mapInputToRegion;
}

test "Drag" {
    _ = wlroots.Drag;
    _ = wlroots.Drag.Type;
    _ = wlroots.Drag.Events;
    _ = wlroots.Drag.Events.Motion;
    _ = wlroots.Drag.Events.Drop;
    _ = wlroots.Drag.Icon;
}

test "EGL" {
    // TODO
}

test "InputDevice" {
    _ = wlroots.InputDevice;
    _ = wlroots.InputDevice.Impl;
    _ = wlroots.InputDevice.Type;
    _ = wlroots.InputDevice.device;
}

test "Keyboard" {
    _ = wlroots.Keyboard;
    _ = wlroots.Keyboard.Events;
    _ = wlroots.Keyboard.Events.Key;
    _ = wlroots.Keyboard.enum_wlr_key_state;
    _ = wlroots.Keyboard.Group;
    _ = wlroots.Keyboard.LED;
    _ = wlroots.Keyboard.Modifier;
    _ = wlroots.Keyboard.Impl;
    _ = wlroots.Keyboard.Modifiers;
    _ = wlroots.Keyboard.setKeymap;
    _ = wlroots.Keyboard.keymapsMatch;
    _ = wlroots.Keyboard.setRepeatInfo;
    _ = wlroots.Keyboard.ledUpdate;
    _ = wlroots.Keyboard.getModifiers;
}

test "List" {
    // TODO
}

test "Matrix" {
    // TODO
}

test "Output" {
    _ = wlroots.Output;
    _ = wlroots.Output.@"test";
    _ = wlroots.Output.Impl;
    _ = wlroots.Output.Layout;
    _ = wlroots.Output.Layout.Direction;
    _ = wlroots.Output.Layout.LayoutOutput;
    _ = wlroots.Output.Layout.add;
    _ = wlroots.Output.Layout.addAuto;
    _ = wlroots.Output.Layout.adjacentOutput;
    _ = wlroots.Output.Layout.closestPoint;
    _ = wlroots.Output.Layout.containsPoint;
    _ = wlroots.Output.Layout.deinit;
    _ = wlroots.Output.Layout.farthestOutput;
    _ = wlroots.Output.Layout.get;
    _ = wlroots.Output.Layout.getBox;
    _ = wlroots.Output.Layout.getCenterOutput;
    _ = wlroots.Output.Layout.intersects;
    _ = wlroots.Output.Layout.move;
    _ = wlroots.Output.Layout.outputAt;
    _ = wlroots.Output.Layout.outputCoords;
    _ = wlroots.Output.Layout.remove;
    _ = wlroots.Output.Layout.struct_wlr_output_layout_state;
    _ = wlroots.Output.Mode;
    _ = wlroots.Output.OutputCursor;
    _ = wlroots.Output.State;
    _ = wlroots.Output.State.BufferType;
    _ = wlroots.Output.State.ModeType;
    _ = wlroots.Output.StateField;
    _ = wlroots.Output.attachBuffer;
    _ = wlroots.Output.attachRender;
    _ = wlroots.Output.commit;
    _ = wlroots.Output.createGlobal;
    _ = wlroots.Output.cursorDestroy;
    _ = wlroots.Output.cursorMove;
    _ = wlroots.Output.cursorSetImage;
    _ = wlroots.Output.cursorSetSurface;
    _ = wlroots.Output.destroy;
    _ = wlroots.Output.destroyGlobal;
    _ = wlroots.Output.effectiveResolution;
    _ = wlroots.Output.enable;
    _ = wlroots.Output.enableAdaptiveSync;
    _ = wlroots.Output.enum_wl_output_mode;
    _ = wlroots.Output.enum_wlr_output_adaptive_sync_status;
    _ = wlroots.Output.enum_wlr_output_present_flag;
    _ = wlroots.Output.exportDmabuf;
    _ = wlroots.Output.fromResource;
    _ = wlroots.Output.getGammaSize;
    _ = wlroots.Output.lockAttachRender;
    _ = wlroots.Output.lockSoftwareCursors;
    _ = wlroots.Output.preferredMode;
    _ = wlroots.Output.preferredReadFormat;
    _ = wlroots.Output.renderSoftwareCursors;
    _ = wlroots.Output.rollback;
    _ = wlroots.Output.scheduleDone;
    _ = wlroots.Output.scheduleFrame;
    _ = wlroots.Output.setCustomMode;
    _ = wlroots.Output.setDamage;
    _ = wlroots.Output.setDescription;
    _ = wlroots.Output.setGamma;
    _ = wlroots.Output.setMode;
    _ = wlroots.Output.setScale;
    _ = wlroots.Output.setSubpixel;
    _ = wlroots.Output.setTransform;
    _ = wlroots.Output.struct_wlr_output_event_damage;
    _ = wlroots.Output.struct_wlr_output_event_precommit;
    _ = wlroots.Output.struct_wlr_output_event_present;
    _ = wlroots.Output.transformCompose;
    _ = wlroots.Output.transformInvert;
    _ = wlroots.Output.transformedResolution;
    _ = wlroots.Output.cursorCreate;
    _ = wlroots.Output.Layout.init;
}

test "Pointer" {
    _ = wlroots.Pointer;
    _ = wlroots.Pointer.Impl;
    _ = wlroots.Pointer.GrabInterface;
    _ = wlroots.Pointer.AxisSource;
    _ = wlroots.Pointer.AxisOrientation;
    _ = wlroots.Pointer.Events;
    _ = wlroots.Pointer.Events.Motion;
    _ = wlroots.Pointer.Events.MotionAbsolute;
    _ = wlroots.Pointer.Events.Button;
    _ = wlroots.Pointer.Events.Axis;
    _ = wlroots.Pointer.Events.SwipeBegin;
    _ = wlroots.Pointer.Events.SwipeUpdate;
    _ = wlroots.Pointer.Events.SwipeEnd;
    _ = wlroots.Pointer.Events.PinchBegin;
    _ = wlroots.Pointer.Events.PinchUpdate;
    _ = wlroots.Pointer.Events.PinchEnd;
}

test "Renderer" {
    _ = wlroots.Renderer;
    _ = wlroots.Renderer.Impl;
    _ = wlroots.Renderer.ReadPixelsFlags;
    _ = wlroots.Renderer.begin;
    _ = wlroots.Renderer.blitDmabuf;
    _ = wlroots.Renderer.destroy;
    _ = wlroots.Renderer.end;
    _ = wlroots.Renderer.formatSupported;
    _ = wlroots.Renderer.getDmabufFormats;
    _ = wlroots.Renderer.initWlDisplay;
    _ = wlroots.Renderer.readPixels;
    _ = wlroots.Renderer.resourceIsWlDrmBuffer;
    _ = wlroots.Renderer.wlDrmBufferGetSize;
    _ = wlroots.Renderer.wlr_renderer_create_func_t;
    _ = wlroots.Renderer.autocreate;
    _ = wlroots.Renderer.clear;
    _ = wlroots.Renderer.getFormats;
    _ = wlroots.Renderer.initDisplay;
    _ = wlroots.Renderer.renderEllipse;
    _ = wlroots.Renderer.renderEllipseWithMatrix;
    _ = wlroots.Renderer.renderQuadWithMatrix;
    _ = wlroots.Renderer.renderRect;
    _ = wlroots.Renderer.renderSubtextureWithMatrix;
    _ = wlroots.Renderer.renderTexture;
    _ = wlroots.Renderer.renderTextureWithMatrix;
    _ = wlroots.Renderer.scissor;
}

test "Seat" {
    _ = wlroots.Seat;
    _ = wlroots.Seat.PointerGrab;
    _ = wlroots.Seat.KeyboardGrab;
    _ = wlroots.Seat.KeyboardGrab.Interface;
    _ = wlroots.Seat.TouchGrab;
    _ = wlroots.Seat.TouchGrab.struct_wlr_touch_grab_interface;
    _ = wlroots.Seat.Client;
    _ = wlroots.Seat.Events;
    _ = wlroots.Seat.Events.RequestSetCursor;
    _ = wlroots.Seat.Events.RequestSetSelection;
    _ = wlroots.Seat.Events.RequestSetPrimarySelection;
    _ = wlroots.Seat.Events.RequestStartDrag;
    _ = wlroots.Seat.Events.PointerFocusChange;
    _ = wlroots.Seat.Events.KeyboardFocusChange;
    _ = wlroots.Seat.struct_wlr_seat_pointer_state;
    _ = wlroots.Seat.struct_wlr_seat_keyboard_state;
    _ = wlroots.Seat.struct_wlr_seat_touch_state;
    _ = wlroots.Seat.struct_wlr_touch_point;
    _ = wlroots.Seat.init;
    _ = wlroots.Seat.keyboardEnter;
    _ = wlroots.Seat.keyboardNotifyEnter;
    _ = wlroots.Seat.deinit;
    _ = wlroots.Seat.getKeyboard;
    _ = wlroots.Seat.setCapabilities;
    _ = wlroots.Seat.setKeyboard;
    _ = wlroots.Seat.setName;
    _ = wlroots.Seat.setSelection;
    _ = wlroots.Seat.keyboardClearFocus;
    _ = wlroots.Seat.keyboardEndGrab;
    _ = wlroots.Seat.keyboardHasGrab;
    _ = wlroots.Seat.keyboardNotifyClearFocus;
    _ = wlroots.Seat.keyboardNotifyKey;
    _ = wlroots.Seat.keyboardNotifyModifiers;
    _ = wlroots.Seat.keyboardSendKey;
    _ = wlroots.Seat.keyboardSendModifiers;
    _ = wlroots.Seat.keyboardStartGrab;
    _ = wlroots.Seat.pointerClearFocus;
    _ = wlroots.Seat.pointerEndGrab;
    _ = wlroots.Seat.pointerEnter;
    _ = wlroots.Seat.pointerHasGrab;
    _ = wlroots.Seat.pointerNotifyAxis;
    _ = wlroots.Seat.pointerNotifyButton;
    _ = wlroots.Seat.pointerNotifyClearFocus;
    _ = wlroots.Seat.pointerNotifyEnter;
    _ = wlroots.Seat.pointerNotifyFrame;
    _ = wlroots.Seat.pointerNotifyMotion;
    _ = wlroots.Seat.pointerSendAxis;
    _ = wlroots.Seat.pointerSendButton;
    _ = wlroots.Seat.pointerSendFrame;
    _ = wlroots.Seat.pointerSendMotion;
    _ = wlroots.Seat.pointerStartGrab;
    _ = wlroots.Seat.pointerSurfaceHasFocus;
    _ = wlroots.Seat.pointerWarp;
    _ = wlroots.Seat.requestSetSelection;
    _ = wlroots.Seat.requestStartDrag;
    _ = wlroots.Seat.startDrag;
    _ = wlroots.Seat.startPointerDrag;
    _ = wlroots.Seat.startTouchDrag;
    _ = wlroots.Seat.touchEndGrab;
    _ = wlroots.Seat.touchGetPoint;
    _ = wlroots.Seat.touchHasGrab;
    _ = wlroots.Seat.touchNotifyDown;
    _ = wlroots.Seat.touchNotifyMotion;
    _ = wlroots.Seat.touchNotifyUp;
    _ = wlroots.Seat.touchNumPoints;
    _ = wlroots.Seat.touchPointClearFocus;
    _ = wlroots.Seat.touchPointFocus;
    _ = wlroots.Seat.touchSendDown;
    _ = wlroots.Seat.touchSendMotion;
    _ = wlroots.Seat.touchSendUp;
    _ = wlroots.Seat.touchStartGrab;
    _ = wlroots.Seat.validateGrabSerial;
    _ = wlroots.Seat.validatePointerGrabSerial;
    _ = wlroots.Seat.validateTouchGrabSerial;
}

test "Session" {
    _ = wlroots.Session;
    _ = wlroots.Session.init;
    _ = wlroots.Session.struct_session_impl;
    _ = wlroots.Session.destroy;
    _ = wlroots.Session.open_file;
    _ = wlroots.Session.close_file;
    _ = wlroots.Session.signal_add;
    _ = wlroots.Session.change_vt;
    _ = wlroots.Session.find_gpus;
}

test "Subcompositor" {
    _ = wlroots.Subcompositor;
}

test "Subsurface" {
    _ = wlroots.Subsurface;
    _ = wlroots.Subsurface.init;
    _ = wlroots.Subsurface.State;
    _ = wlroots.Subsurface.fromWlrSurface;
}

test "Surface" {
    _ = wlroots.Surface;
    _ = wlroots.Surface.IteratorFunc;
    _ = wlroots.Surface.Role;
    _ = wlroots.Surface.State;
    _ = wlroots.Surface.StateField;
    _ = wlroots.Surface.acceptsTouch;
    _ = wlroots.Surface.forEachSurface;
    _ = wlroots.Surface.fromResource;
    _ = wlroots.Surface.getBufferSourceBox;
    _ = wlroots.Surface.getEffectiveDamage;
    _ = wlroots.Surface.getExtends;
    _ = wlroots.Surface.getRootSurface;
    _ = wlroots.Surface.getTexture;
    _ = wlroots.Surface.hasBuffer;
    _ = wlroots.Surface.isSubsurface;
    _ = wlroots.Surface.isXdgSurface;
    _ = wlroots.Surface.pointAcceptsInput;
    _ = wlroots.Surface.sendEnter;
    _ = wlroots.Surface.sendFrameDone;
    _ = wlroots.Surface.sendLeave;
    _ = wlroots.Surface.setRole;
    _ = wlroots.Surface.surfaceAt;
    _ = wlroots.Surface.init;
}

test "Switch" {
    _ = wlroots.Switch;
    _ = wlroots.Switch.Type;
    _ = wlroots.Switch.State;
    _ = wlroots.Switch.Events;
    _ = wlroots.Switch.Events.Toggle;
    _ = wlroots.Switch.Impl;
}

test "Tablet" {
    _ = wlroots.Tablet;
    _ = wlroots.Tablet.Tool;
    _ = wlroots.Tablet.Tool.Events;
    _ = wlroots.Tablet.Tool.Events.Axis;
    _ = wlroots.Tablet.Tool.Events.Proximity;
    _ = wlroots.Tablet.Tool.Events.Tip;
    _ = wlroots.Tablet.Tool.Events.Button;
    _ = wlroots.Tablet.Tool.ProximityState;
    _ = wlroots.Tablet.Tool.Axes;
    _ = wlroots.Tablet.Tool.Type;
    _ = wlroots.Tablet.Tool.TipState;
    _ = wlroots.Tablet.Pad;
    _ = wlroots.Tablet.Pad.Events;
    _ = wlroots.Tablet.Pad.Events.Button;
    _ = wlroots.Tablet.Pad.Events.Ring;
    _ = wlroots.Tablet.Pad.Events.Strip;
    _ = wlroots.Tablet.Pad.RingSource;
    _ = wlroots.Tablet.Pad.StripSource;
    _ = wlroots.Tablet.Pad.Group;
    _ = wlroots.Tablet.Pad.PadImpl;
    _ = wlroots.Tablet.Impl;
}

test "Texture" {
    _ = wlroots.Texture.fromPixels;
    _ = wlroots.Texture.fromWlDrm;
    _ = wlroots.Texture.fromDmabuf;
    _ = wlroots.Texture.writePixels;
    _ = wlroots.Texture.toDmabuf;
    _ = wlroots.Texture;
    _ = wlroots.Texture.getSize;
    _ = wlroots.Texture.isOpaque;
    _ = wlroots.Texture.destroy;
    _ = wlroots.Texture.Impl;
}

test "Touch" {
    _ = wlroots.Touch;
    _ = wlroots.Touch.Impl;
    _ = wlroots.Touch.Events;
    _ = wlroots.Touch.Events.Down;
    _ = wlroots.Touch.Events.Up;
    _ = wlroots.Touch.Events.Motion;
    _ = wlroots.Touch.Events.Cancel;
}

test "XCursor" {
    _ = wlroots.XCursor;
    _ = wlroots.XCursor.Image;
    _ = wlroots.XCursor.Manager;
    _ = wlroots.XCursor.Manager.ManagerTheme;
    _ = wlroots.XCursor.Manager.deinit;
    _ = wlroots.XCursor.Manager.getXCursor;
    _ = wlroots.XCursor.Manager.setCursorImage;
    _ = wlroots.XCursor.Theme;
    _ = wlroots.XCursor.frame;
    _ = wlroots.XCursor.getResizeName;
    _ = wlroots.XCursor.Manager.init;
    _ = wlroots.XCursor.Manager.load;
}

test "XDGPopup" {
    _ = wlroots.XDGPopup;
    _ = wlroots.XDGPopup.Grab;
    _ = wlroots.XDGPopup.deinit;
    _ = wlroots.XDGPopup.getAnchorPoint;
    _ = wlroots.XDGPopup.getToplevelCoords;
    _ = wlroots.XDGPopup.unconstrainFromBox;
}

test "XDGPositioner" {
    _ = wlroots.XDGPositioner;
    _ = wlroots.XDGPositioner.invertX;
    _ = wlroots.XDGPositioner.invertY;
    _ = wlroots.XDGPositioner.getGeometry;
}

test "XDGShell" {
    _ = wlroots.XDGShell;
    _ = wlroots.XDGShell.init;
}

test "XDGSurface" {
    _ = wlroots.XDGSurface;
    _ = wlroots.XDGSurface.SurfaceConfigure;
    _ = wlroots.XDGSurface.Role;
    _ = wlroots.XDGSurface.forEachSurface;
    _ = wlroots.XDGSurface.forEachPopup;
    _ = wlroots.XDGSurface.fromPopupResource;
    _ = wlroots.XDGSurface.fromResource;
    _ = wlroots.XDGSurface.fromToplevelResource;
    _ = wlroots.XDGSurface.fromWlrSurface;
    _ = wlroots.XDGSurface.getGeometry;
    _ = wlroots.XDGSurface.ping;
    _ = wlroots.XDGSurface.scheduleConfigure;
    _ = wlroots.XDGSurface.surfaceAt;
}

test "XDGToplevel" {
    _ = wlroots.XDGToplevel;
    _ = wlroots.XDGToplevel.Events;
    _ = wlroots.XDGToplevel.Events.Move;
    _ = wlroots.XDGToplevel.Events.Resize;
    _ = wlroots.XDGToplevel.Events.SetFullscreen;
    _ = wlroots.XDGToplevel.Events.ShowWindowMenu;
    _ = wlroots.XDGToplevel.State;
    _ = wlroots.XDGToplevel.sendClose;
    _ = wlroots.XDGToplevel.setActivated;
    _ = wlroots.XDGToplevel.setFullscreen;
    _ = wlroots.XDGToplevel.setMaximized;
    _ = wlroots.XDGToplevel.setResizing;
    _ = wlroots.XDGToplevel.setSize;
    _ = wlroots.XDGToplevel.setTiled;
}
