package main

import (
	"errors"
	"fmt"
	"log"
	"os"
	"runtime"
	"time"
	"unsafe"

	"github.com/go-gl/mathgl/mgl32"
	"honnef.co/go/egl"
	"honnef.co/go/gl"
	"honnef.co/go/newui/ogl"
	"honnef.co/go/newui/x11"
	"honnef.co/go/wayfarer/wayland"
)

type EGL struct {
	Display egl.EGLDisplay
	Surface egl.EGLSurface
	Context egl.EGLContext
	Config  egl.EGLConfig
}

type XSurface struct {
	Surface *mockSurface
	Damaged bool
	Texture ogl.Texture

	oldWidth  int32
	oldHeight int32
}

type XGraphicsBackend struct {
	X       *x11.Display
	Window  x11.Window
	EGL     EGL
	Program ogl.Program

	Surfaces []*XSurface

	WindowBlock *ShaderWindowBlock
}

func NewXGraphicsBackend() (*XGraphicsBackend, error) {
	runtime.LockOSThread()
	defer runtime.UnlockOSThread()

	if err := egl.Init(); err != nil {
		return nil, err
	}
	if err := gl.Init(); err != nil {
		return nil, err
	}
	if !egl.BindAPI(egl.OPENGL_API) {
		return nil, errors.New("couldn't bind OpenGL")
	}

	dpy, err := x11.NewDisplay()
	if err != nil {
		return nil, err
	}
	win, err := dpy.CreateSimpleWindow(dpy.DefaultRootWindow(), 0, 0, 1920, 1080, 0, 0, 0)
	if err != nil {
		return nil, err
	}
	win.Map()

	edpy := egl.GetDisplay(nil)
	if edpy == nil {
		return nil, errors.New("could not create EGL display")
	}
	if !egl.Initialize(edpy, nil, nil) {
		return nil, errors.New("could not initialize EGL display")
	}
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
	egl.ChooseConfig(edpy, &attribs[0], &config, 1, &numConfig)
	attribs = []int32{
		egl.CONTEXT_FLAGS_KHR, egl.CONTEXT_OPENGL_DEBUG_BIT_KHR,
		egl.CONTEXT_OPENGL_PROFILE_MASK_KHR, egl.CONTEXT_OPENGL_CORE_PROFILE_BIT_KHR,
		egl.CONTEXT_MAJOR_VERSION_KHR, 4,
		egl.CONTEXT_MINOR_VERSION_KHR, 1,
		egl.NONE,
	}
	context := egl.CreateContext(edpy, config, nil, &attribs[0])
	if context == nil {
		errCode := egl.GetError()
		return nil, fmt.Errorf("could not create EGL context, error %#x", errCode)
	}

	surface := egl.CreateWindowSurface(edpy, config, egl.EGLNativeWindowType(win.ID), nil)
	if surface == nil {
		return nil, errors.New("could not create EGL surface")
	}

	if !egl.MakeCurrent(edpy, surface, surface, context) {
		log.Fatal("Could not make EGL context current")
	}
	ogl.EnableGLDebugLogging()

	vs, err := os.Open("window.vert")
	if err != nil {
		return nil, err
	}
	fs, err := os.Open("window.frag")
	if err != nil {
		return nil, err
	}
	vert, err := ogl.NewShader(vs, gl.VERTEX_SHADER)
	if err != nil {
		return nil, err
	}
	frag, err := ogl.NewShader(fs, gl.FRAGMENT_SHADER)
	if err != nil {
		return nil, err
	}

	prog := ogl.NewProgram(vert, frag)
	vert.Delete()
	frag.Delete()

	// OpenGL core requires a bound VAO, even though we'll never pass
	// in any vertex data.
	var vao uint32
	gl.CreateVertexArrays(1, &vao)
	gl.BindVertexArray(vao)

	var screen *ShaderScreenBlock
	ubo := ogl.NewBuffer(int(unsafe.Sizeof(ShaderScreenBlock{})))
	ubo.Bind(gl.UNIFORM_BUFFER, 0)
	ubo.Map(&screen)
	screen.Width = 1920
	screen.Height = 1080
	screen.Matrix = mgl32.Ortho(0, screen.Width, screen.Height, 0, 0, 1)

	var block *ShaderWindowBlock
	ubo = ogl.NewBuffer(int(unsafe.Sizeof(ShaderWindowBlock{})))
	ubo.Bind(gl.SHADER_STORAGE_BUFFER, 1)
	ubo.Map(&block)

	return &XGraphicsBackend{
		X:      dpy,
		Window: win,
		EGL: EGL{
			Display: edpy,
			Surface: surface,
			Context: context,
			Config:  config,
		},
		Program:     prog,
		WindowBlock: block,
	}, nil
}

func (surface *XSurface) Initialize() {
	if surface.Surface.state.buffer == nil {
		return
	}

	buf := wayland.GetSHMBuffer(surface.Surface.state.buffer)
	width := buf.Width()
	height := buf.Height()

	if surface.oldWidth == width && surface.oldHeight == height {
		return
	}

	if width == 0 || height == 0 {
		return
	}

	// XXX release old texture, if any
	tex := ogl.CreateTexture(gl.TEXTURE_2D)
	gl.TextureParameterf(tex.Object, gl.TEXTURE_MIN_FILTER, gl.NEAREST)
	gl.TextureParameterf(tex.Object, gl.TEXTURE_MAG_FILTER, gl.NEAREST)
	gl.TextureParameteri(tex.Object, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE)
	gl.TextureParameteri(tex.Object, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE)
	gl.TextureStorage2D(tex.Object, 1, gl.RGBA8, width, height)
	gl.MakeTextureHandleResidentARB(tex.Handle())

	surface.Texture = tex
	surface.oldWidth = width
	surface.oldHeight = height
}

func (backend *XGraphicsBackend) AddSurface(surface *mockSurface) {
	xsurface := &XSurface{
		Surface: surface,
		Damaged: true,
	}
	backend.Surfaces = append(backend.Surfaces, xsurface)
}

func (backend *XGraphicsBackend) DamageSurface(surface *mockSurface) {
	for _, xsurface := range backend.Surfaces {
		if xsurface.Surface == surface {
			xsurface.Damaged = true
			return
		}
	}
}

func (backend *XGraphicsBackend) Render() {
	runtime.LockOSThread()
	defer runtime.UnlockOSThread()

	if !egl.MakeCurrent(backend.EGL.Display, backend.EGL.Surface, backend.EGL.Surface, backend.EGL.Context) {
		log.Fatal("Could not make EGL context current")
	}

	gl.ClearColor(0.0, 0.0, 1.0, 1.0)
	gl.Clear(gl.COLOR_BUFFER_BIT)
	gl.Enable(gl.BLEND)
	gl.BlendFunc(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA)
	gl.UseProgram(uint32(backend.Program))

	for i, surface := range backend.Surfaces {
		if surface.Surface.state.buffer == nil {
			continue
		}

		surface.Initialize()
		if surface.Damaged {
			buf := wayland.GetSHMBuffer(surface.Surface.state.buffer)
			width := buf.Width()
			height := buf.Height()

			tex := surface.Texture
			gl.TextureSubImage2D(tex.Object, 0, 0, 0, width, height, gl.BGRA, gl.UNSIGNED_BYTE, buf.Data())
			backend.WindowBlock.Texture[i] = tex.Handle()

			X := float32(20 * (i + 1))
			Y := float32(20 * (i + 1))
			W := float32(width)
			H := float32(height)

			// stack := 1.0 / -float32(i)
			stack := float32(0)
			a := mgl32.Vec4{X, Y, stack, 1}
			b := mgl32.Vec4{X, Y + H, stack, 1}
			c := mgl32.Vec4{X + W, Y + H, stack, 1}
			d := mgl32.Vec4{X + W, Y, stack, 1}
			backend.WindowBlock.Rect[i] = [6]mgl32.Vec4{
				a, b, c,
				a, c, d,
			}
		}
	}

	gl.DrawArraysInstanced(gl.TRIANGLES, 0, 6, int32(len(backend.Surfaces)))
	egl.SwapBuffers(backend.EGL.Display, backend.EGL.Surface)

	for _, surface := range backend.Surfaces {
		if surface.Surface.state.frameCallback != nil {
			surface.Surface.state.frameCallback.SendDone(time.Now())
			surface.Surface.state.frameCallback.Destroy()
			surface.Surface.state.frameCallback = nil
		}
		surface.Damaged = false
	}
}

type Sampler2D = uint64

type ShaderWindowBlock struct {
	Texture [9216]Sampler2D
	Rect    [9216][6]mgl32.Vec4
}

type ShaderScreenBlock struct {
	Width  float32
	Height float32
	// std140 alignment
	_      [2]float32
	Matrix mgl32.Mat4
}
