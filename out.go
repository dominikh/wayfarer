package main

import (
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
	"honnef.co/go/wayfarer/wayland"
)

type XSurface struct {
	Surface *mockSurface
	Damaged bool
	Texture ogl.Texture

	oldWidth  int32
	oldHeight int32
}

type Renderer struct {
	Backend Backend
	Output  Output

	Program ogl.Program

	Surfaces []*XSurface

	WindowBlock *ShaderWindowBlock
}

func NewRenderer(backend Backend, output Output) (*Renderer, error) {
	if !egl.MakeCurrent(backend.Display(), output.Surface(), output.Surface(), backend.Context()) {
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

	return &Renderer{
		Backend:     backend,
		Output:      output,
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

func (backend *Renderer) AddSurface(surface *mockSurface) {
	xsurface := &XSurface{
		Surface: surface,
		Damaged: true,
	}
	backend.Surfaces = append(backend.Surfaces, xsurface)
}

func (backend *Renderer) DamageSurface(surface *mockSurface) {
	for _, xsurface := range backend.Surfaces {
		if xsurface.Surface == surface {
			xsurface.Damaged = true
			return
		}
	}
}

func (backend *Renderer) Render() {
	runtime.LockOSThread()
	defer runtime.UnlockOSThread()

	if !egl.MakeCurrent(backend.Backend.Display(), backend.Output.Surface(), backend.Output.Surface(), backend.Backend.Context()) {
		fmt.Printf("%#x\n", egl.GetError())
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
	egl.SwapBuffers(backend.Backend.Display(), backend.Output.Surface())

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
