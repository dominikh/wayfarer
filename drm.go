// +build ignore

package main

import (
	"fmt"
	"log"
	"unsafe"

	"honnef.co/go/egl"
	"honnef.co/go/gl"
	"honnef.co/go/newui/ogl"
	"honnef.co/go/wayfarer/drm"
	"honnef.co/go/wayfarer/gbm"
)

func must(err error) {
	if err != nil {
		panic(err)
	}
}

func matchConfigToVisual(dpy egl.EGLDisplay, visualID int, configs []egl.EGLConfig) {
}

func eglChooseConfig(dpy egl.EGLDisplay, attribs []int32, visual gbm.Format) egl.EGLConfig {
	var count int32
	egl.ChooseConfig(dpy, &attribs[0], nil, 0, &count)

	if count == 0 {
		log.Fatal("no available configs")
	}
	configs := make([]egl.EGLConfig, count)
	egl.ChooseConfig(dpy, &attribs[0], &configs[0], count, &count)
	for _, config := range configs[:count] {
		var value int32
		egl.GetConfigAttrib(dpy, config, egl.NATIVE_VISUAL_ID, &value)
		if gbm.Format(value) == visual {
			return config
		}
	}
	log.Fatal("found no config with matching visual")
	return nil
}

const (
	// Use 3.3 while testing in qemu, because of llvmpipe.
	// Switch to 4.5 later.
	glMajor = 3
	glMinor = 3
)

func foo() {
	egl.Init()
	gl.Init()

	drmdev, err := drm.Open("/dev/dri/card0")
	must(err)
	drmdev.SetMaster()
	gbmdev, err := gbm.CreateDevice(drmdev.Fd())
	must(err)
	dpy := egl.GetDisplay(egl.EGLNativeDisplayType(gbmdev.Handle()))
	if !egl.Initialize(dpy, nil, nil) {
		panic("could not initialize EGL display")
	}

	// XXX SET UP KMS HERE XXX
	res, err := drmdev.Resources()
	must(err)
	conn, err := drmdev.Connector(res.Connectors[0])
	must(err)
	mode := conn.Modes[0]

	gbmsurf, err := gbmdev.CreateSurface(uint32(mode.Hdisplay), uint32(mode.Vdisplay), gbm.FormatXRGB8888, gbm.UseScanout|gbm.UseRendering)
	must(err)

	egl.BindAPI(egl.OPENGL_API)
	attribs := []int32{
		egl.RED_SIZE, 1,
		egl.GREEN_SIZE, 1,
		egl.BLUE_SIZE, 1,
		egl.ALPHA_SIZE, 0,
		egl.CONFORMANT, egl.OPENGL_BIT,
		egl.RENDERABLE_TYPE, egl.OPENGL_BIT,
		egl.SURFACE_TYPE, egl.WINDOW_BIT,
		egl.NATIVE_RENDERABLE, egl.TRUE,
		egl.NONE,
	}

	config := eglChooseConfig(dpy, attribs, gbm.FormatXRGB8888)

	attribs = []int32{
		egl.CONTEXT_FLAGS_KHR, egl.CONTEXT_OPENGL_DEBUG_BIT_KHR,
		egl.CONTEXT_OPENGL_PROFILE_MASK_KHR, egl.CONTEXT_OPENGL_CORE_PROFILE_BIT_KHR,
		egl.CONTEXT_MAJOR_VERSION_KHR, glMajor,
		egl.CONTEXT_MINOR_VERSION_KHR, glMinor,
		egl.NONE,
	}

	ctx := egl.CreateContext(dpy, config, nil, &attribs[0])
	if ctx == nil {
		errCode := egl.GetError()
		log.Fatalf("could not create EGL context, error %#x", errCode)
	}

	eglsurf := egl.CreateWindowSurface(dpy, config, egl.EGLNativeWindowType(uintptr(gbmsurf.Handle())), nil)
	if eglsurf == nil {
		errCode := egl.GetError()
		log.Fatalf("could not create EGL surface, error %#x", errCode)
	}

	if !egl.MakeCurrent(dpy, eglsurf, eglsurf, ctx) {
		log.Fatal("could not make EGL context current")
	}
	ogl.EnableGLDebugLogging()

	gl.ClearColor(1.0, 0.0, 0.0, 1.0)
	gl.Clear(gl.COLOR_BUFFER_BIT)
	egl.SwapBuffers(dpy, eglsurf)
	bo, err := gbmsurf.LockFrontBuffer()
	must(err)
	fb, err := drmFbGetFromBo(drmdev, bo)
	must(err)

	enc, err := drmdev.Encoder(conn.EncoderID)
	must(err)
	fmt.Println(enc.CrtcID, fb, conn.ConnectorID)
	err = drmdev.SetCrtc(enc.CrtcID, fb, 0, 0, []uint32{conn.ConnectorID}, &mode)
	must(err)

	for {
	}
}

func drmFbGetFromBo(dev *drm.Handle, bo *gbm.BO) (uint32, error) {
	width := bo.Width()
	height := bo.Height()
	format := bo.Format()

	mod := bo.Modifier()
	if mod == drm.DRM_FORMAT_MOD_INVALID {
		mod = 0
	}
	modifiers := [4]uint64{
		mod,
		mod,
		mod,
		mod,
	}
	var strides [4]uint32
	var handles [4]uint32
	var offsets [4]uint32
	numPlanes := bo.PlaneCount()
	if numPlanes > 4 {
		panic(fmt.Sprintf("unexpected number of planes: %d", numPlanes))
	}
	for i := 0; i < numPlanes; i++ {
		strides[i] = bo.StrideForPlane(i)
		hnd := bo.HandleForPlane(i)
		handles[i] = *(*uint32)(unsafe.Pointer(&hnd))
		offsets[i] = bo.Offset(i)
	}
	var flags uint32
	if modifiers[0] != 0 {
		flags = drm.DRM_MODE_FB_MODIFIERS
	}
	return dev.AddFB2WithModifiers(width, height, uint32(format), handles, strides, offsets, modifiers, flags)
}

func main() {
	foo()
}
