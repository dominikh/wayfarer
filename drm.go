package main

import (
	"fmt"
	"log"
	"unsafe"

	"honnef.co/go/egl"
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

var _ Backend = (*KMS)(nil)

type KMS struct {
	DevicePath string

	drmdev   *drm.Handle
	gbmdev   *gbm.Device
	edpy     egl.EGLDisplay
	econfig  egl.EGLConfig
	econtext egl.EGLContext
	outputs  []Output
}

func (kms *KMS) Initialize() error {
	drmdev, err := drm.Open(kms.DevicePath)
	if err != nil {
		return err
	}
	kms.drmdev = drmdev

	kms.drmdev.SetMaster()
	gbmdev, err := gbm.CreateDevice(drmdev.Fd())
	if err != nil {
		return err
	}
	kms.gbmdev = gbmdev

	edpy := egl.GetDisplay(egl.EGLNativeDisplayType(kms.gbmdev.Handle()))
	if !egl.Initialize(edpy, nil, nil) {
		return fmt.Errorf("could not initialize EGL display: %d", egl.GetError())
	}
	kms.edpy = edpy

	res, err := kms.drmdev.Resources()
	if err != nil {
		return err
	}

	var outputs []Output
	for _, connID := range res.Connectors {
		conn, err := kms.drmdev.Connector(connID)
		if err != nil {
			continue
		}
		if conn.Connection != drm.ModeConnected {
			continue
		}
		outputs = append(outputs, &KMSOutput{kms: kms, connID: connID, modes: conn.Modes})
	}
	kms.outputs = outputs

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
	kms.econfig = eglChooseConfig(kms.edpy, attribs, gbm.FormatXRGB8888)

	attribs = []int32{
		egl.CONTEXT_FLAGS_KHR, egl.CONTEXT_OPENGL_DEBUG_BIT_KHR,
		egl.CONTEXT_OPENGL_PROFILE_MASK_KHR, egl.CONTEXT_OPENGL_CORE_PROFILE_BIT_KHR,
		egl.CONTEXT_MAJOR_VERSION_KHR, glMajor,
		egl.CONTEXT_MINOR_VERSION_KHR, glMinor,
		egl.NONE,
	}
	ctx := egl.CreateContext(kms.edpy, kms.econfig, nil, &attribs[0])
	if ctx == nil {
		errCode := egl.GetError()
		return fmt.Errorf("could not create EGL context, error %#x", errCode)
	}
	kms.econtext = ctx

	return nil
}

func (kms *KMS) Display() egl.EGLDisplay { return kms.edpy }
func (kms *KMS) Context() egl.EGLContext { return kms.econtext }

func (kms *KMS) SetOutputMode(out_ Output, mode_ Mode) error {
	out := out_.(*KMSOutput)
	mode := mode_.(*KMSMode)

	// XXX free previously allocated buffers
	gbmsurf, err := kms.gbmdev.CreateSurface(uint32(mode.mode.Hdisplay), uint32(mode.mode.Vdisplay), gbm.FormatXRGB8888, gbm.UseScanout|gbm.UseRendering)
	if err != nil {
		return err
	}
	out.gbmsurf = gbmsurf
	eglsurf := egl.CreateWindowSurface(kms.edpy, kms.econfig, egl.EGLNativeWindowType(uintptr(out.gbmsurf.Handle())), nil)
	if eglsurf == nil {
		errCode := egl.GetError()
		return fmt.Errorf("could not create EGL surface, error %#x", errCode)
	}
	out.eglsurf = eglsurf
	out.mode = mode
	return nil
}

func (kms *KMS) Destroy() {
	// XXX implement
}

func (kms *KMS) Outputs() []Output {
	return kms.outputs
}

type KMSMode struct {
	mode drm.ModeInfo
}

type KMSOutput struct {
	kms     *KMS
	eglsurf egl.EGLSurface
	gbmsurf *gbm.Surface

	connID uint32
	modes  []drm.ModeInfo
	mode   *KMSMode
}

func (mode *KMSMode) Width() uint32  { return uint32(mode.mode.Hdisplay) }
func (mode *KMSMode) Height() uint32 { return uint32(mode.mode.Vdisplay) }

func (out *KMSOutput) RenderFrame() {
	egl.SwapBuffers(out.kms.edpy, out.eglsurf)
	bo, err := out.gbmsurf.LockFrontBuffer()
	must(err)
	fb, err := drmFbGetFromBo(out.kms.drmdev, bo)
	must(err)

	conn, err := out.kms.drmdev.Connector(out.connID)
	must(err)
	enc, err := out.kms.drmdev.Encoder(conn.EncoderID)
	must(err)
	err = out.kms.drmdev.SetCrtc(enc.CrtcID, fb, 0, 0, []uint32{conn.ConnectorID}, &out.mode.mode)
	must(err)
}

func (out *KMSOutput) Modes() []Mode {
	var ret []Mode
	for _, mode := range out.modes {
		ret = append(ret, &KMSMode{mode})
	}
	return ret
}

func (out *KMSOutput) Surface() egl.EGLSurface { return out.eglsurf }

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
