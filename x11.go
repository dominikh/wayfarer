package main

import (
	"errors"
	"fmt"
	"runtime"

	"honnef.co/go/egl"
	"honnef.co/go/newui/x11"
)

var _ Backend = (*X11)(nil)

type X11 struct {
	dpy      *x11.Display
	edpy     egl.EGLDisplay
	econfig  egl.EGLConfig
	econtext egl.EGLContext
	outputs  []Output
}

func (x *X11) Display() egl.EGLDisplay { return x.edpy }
func (x *X11) Context() egl.EGLContext { return x.econtext }
func (x *X11) Destroy() {
	// XXX implement
}
func (x *X11) Outputs() []Output { return x.outputs }

func (x *X11) Initialize() error {
	runtime.LockOSThread()
	defer runtime.UnlockOSThread()

	dpy, err := x11.NewDisplay()
	if err != nil {
		return err
	}
	x.dpy = dpy

	win, err := dpy.CreateSimpleWindow(dpy.DefaultRootWindow(), 0, 0, 1920, 1080, 0, 0, 0)
	if err != nil {
		return err
	}

	edpy := egl.GetDisplay(nil)
	if !egl.Initialize(edpy, nil, nil) {
		return fmt.Errorf("could not initialize EGL display: %d", egl.GetError())
	}
	x.edpy = edpy

	attribs := []int32{
		egl.RED_SIZE, 8,
		egl.GREEN_SIZE, 8,
		egl.BLUE_SIZE, 8,
		egl.ALPHA_SIZE, 8,
		egl.CONFORMANT, egl.OPENGL_BIT,
		egl.SURFACE_TYPE, egl.WINDOW_BIT,
		egl.NONE,
	}

	var config egl.EGLConfig
	var numConfig int32
	egl.ChooseConfig(x.edpy, &attribs[0], &config, 1, &numConfig)
	x.econfig = config
	attribs = []int32{
		egl.CONTEXT_FLAGS_KHR, egl.CONTEXT_OPENGL_DEBUG_BIT_KHR,
		egl.CONTEXT_OPENGL_PROFILE_MASK_KHR, egl.CONTEXT_OPENGL_CORE_PROFILE_BIT_KHR,
		egl.CONTEXT_MAJOR_VERSION_KHR, 4,
		egl.CONTEXT_MINOR_VERSION_KHR, 1,
		egl.NONE,
	}

	context := egl.CreateContext(x.edpy, config, nil, &attribs[0])
	if context == nil {
		errCode := egl.GetError()
		return fmt.Errorf("could not create EGL context, error %#x", errCode)
	}
	x.econtext = context
	x.outputs = []Output{&X11Output{win: win}}
	return nil
}

func (x *X11) SetOutputMode(out_ Output, mode_ Mode) error {
	out := out_.(*X11Output)
	mode := mode_.(*X11Mode)
	_ = mode
	// XXX configure the window

	out.win.Map()

	surface := egl.CreateWindowSurface(x.edpy, x.econfig, egl.EGLNativeWindowType(out.win.ID), nil)
	if surface == nil {
		return errors.New("could not create EGL surface")
	}
	out.eglsurf = surface
	return nil
}

type X11Output struct {
	x11     *X11
	win     x11.Window
	eglsurf egl.EGLSurface
}

func (out *X11Output) Surface() egl.EGLSurface { return out.eglsurf }

func (out *X11Output) RenderFrame() {
	panic("XXX not implemented")
}

func (out *X11Output) Modes() []Mode {
	return []Mode{
		&X11Mode{
			width:  1920,
			height: 1080,
		},
	}
}

type X11Mode struct {
	width  uint32
	height uint32
}

func (mode *X11Mode) Width() uint32  { return mode.width }
func (mode *X11Mode) Height() uint32 { return mode.height }
