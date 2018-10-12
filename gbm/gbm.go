// Package gbm provides bindings for the Generic Buffer Manager.
package gbm

// #cgo pkg-config: gbm
// #include <gbm.h>
import "C"
import (
	"errors"
	"unsafe"
)

type Format uint32

const (
	FormatC8          Format = 0x20203843 // [7:0] C
	FormatR8          Format = 0x20203852 // [7:0] R
	FormatGR88        Format = 0x38385247 // [15:0] G:R 8:8 little endian
	FormatRGB332      Format = 0x38424752 // [7:0] R:G:B 3:3:2
	FormatBGR233      Format = 0x38524742 // [7:0] B:G:R 2:3:3
	FormatXRGB4444    Format = 0x32315258 // [15:0] x:R:G:B 4:4:4:4 little endian
	FormatXBGR4444    Format = 0x32314258 // [15:0] x:B:G:R 4:4:4:4 little endian
	FormatRGBX4444    Format = 0x32315852 // [15:0] R:G:B:x 4:4:4:4 little endian
	FormatBGRX4444    Format = 0x32315842 // [15:0] B:G:R:x 4:4:4:4 little endian
	FormatARGB4444    Format = 0x32315241 // [15:0] A:R:G:B 4:4:4:4 little endian
	FormatABGR4444    Format = 0x32314241 // [15:0] A:B:G:R 4:4:4:4 little endian
	FormatRGBA4444    Format = 0x32314152 // [15:0] R:G:B:A 4:4:4:4 little endian
	FormatBGRA4444    Format = 0x32314142 // [15:0] B:G:R:A 4:4:4:4 little endian
	FormatXRGB1555    Format = 0x35315258 // [15:0] x:R:G:B 1:5:5:5 little endian
	FormatXBGR1555    Format = 0x35314258 // [15:0] x:B:G:R 1:5:5:5 little endian
	FormatRGBX5551    Format = 0x35315852 // [15:0] R:G:B:x 5:5:5:1 little endian
	FormatBGRX5551    Format = 0x35315842 // [15:0] B:G:R:x 5:5:5:1 little endian
	FormatARGB1555    Format = 0x35315241 // [15:0] A:R:G:B 1:5:5:5 little endian
	FormatABGR1555    Format = 0x35314241 // [15:0] A:B:G:R 1:5:5:5 little endian
	FormatRGBA5551    Format = 0x35314152 // [15:0] R:G:B:A 5:5:5:1 little endian
	FormatBGRA5551    Format = 0x35314142 // [15:0] B:G:R:A 5:5:5:1 little endian
	FormatRGB565      Format = 0x36314752 // [15:0] R:G:B 5:6:5 little endian
	FormatBGR565      Format = 0x36314742 // [15:0] B:G:R 5:6:5 little endian
	FormatRGB888      Format = 0x34324752 // [23:0] R:G:B little endian
	FormatBGR888      Format = 0x34324742 // [23:0] B:G:R little endian
	FormatXRGB8888    Format = 0x34325258 // [31:0] x:R:G:B 8:8:8:8 little endian
	FormatXBGR8888    Format = 0x34324258 // [31:0] x:B:G:R 8:8:8:8 little endian
	FormatRGBX8888    Format = 0x34325852 // [31:0] R:G:B:x 8:8:8:8 little endian
	FormatBGRX8888    Format = 0x34325842 // [31:0] B:G:R:x 8:8:8:8 little endian
	FormatARGB8888    Format = 0x34325241 // [31:0] A:R:G:B 8:8:8:8 little endian
	FormatABGR8888    Format = 0x34324241 // [31:0] A:B:G:R 8:8:8:8 little endian
	FormatRGBA8888    Format = 0x34324152 // [31:0] R:G:B:A 8:8:8:8 little endian
	FormatBGRA8888    Format = 0x34324142 // [31:0] B:G:R:A 8:8:8:8 little endian
	FormatXRGB2101010 Format = 0x30335258 // [31:0] x:R:G:B 2:10:10:10 little endian
	FormatXBGR2101010 Format = 0x30334258 // [31:0] x:B:G:R 2:10:10:10 little endian
	FormatRGBX1010102 Format = 0x30335852 // [31:0] R:G:B:x 10:10:10:2 little endian
	FormatBGRX1010102 Format = 0x30335842 // [31:0] B:G:R:x 10:10:10:2 little endian
	FormatARGB2101010 Format = 0x30335241 // [31:0] A:R:G:B 2:10:10:10 little endian
	FormatABGR2101010 Format = 0x30334241 // [31:0] A:B:G:R 2:10:10:10 little endian
	FormatRGBA1010102 Format = 0x30334152 // [31:0] R:G:B:A 10:10:10:2 little endian
	FormatBGRA1010102 Format = 0x30334142 // [31:0] B:G:R:A 10:10:10:2 little endian
	FormatYUYV        Format = 0x56595559 // [31:0] Cr0:Y1:Cb0:Y0 8:8:8:8 little endian
	FormatYVYU        Format = 0x55595659 // [31:0] Cb0:Y1:Cr0:Y0 8:8:8:8 little endian
	FormatUYVY        Format = 0x59565955 // [31:0] Y1:Cr0:Y0:Cb0 8:8:8:8 little endian
	FormatVYUY        Format = 0x59555956 // [31:0] Y1:Cb0:Y0:Cr0 8:8:8:8 little endian
	FormatAYUV        Format = 0x56555941 // [31:0] A:Y:Cb:Cr 8:8:8:8 little endian
	FormatNV12        Format = 0x3231564e // 2x2 subsampled Cr:Cb plane
	FormatNV21        Format = 0x3132564e // 2x2 subsampled Cb:Cr plane
	FormatNV16        Format = 0x3631564e // 2x1 subsampled Cr:Cb plane
	FormatNV61        Format = 0x3136564e // 2x1 subsampled Cb:Cr plane
	FormatYUV410      Format = 0x39565559 // 4x4 subsampled Cb (1) and Cr (2) planes
	FormatYVU410      Format = 0x39555659 // 4x4 subsampled Cr (1) and Cb (2) planes
	FormatYUV411      Format = 0x31315559 // 4x1 subsampled Cb (1) and Cr (2) planes
	FormatYVU411      Format = 0x31315659 // 4x1 subsampled Cr (1) and Cb (2) planes
	FormatYUV420      Format = 0x32315559 // 2x2 subsampled Cb (1) and Cr (2) planes
	FormatYVU420      Format = 0x32315659 // 2x2 subsampled Cr (1) and Cb (2) planes
	FormatYUV422      Format = 0x36315559 // 2x1 subsampled Cb (1) and Cr (2) planes
	FormatYVU422      Format = 0x36315659 // 2x1 subsampled Cr (1) and Cb (2) planes
	FormatYUV444      Format = 0x34325559 // non-subsampled Cb (1) and Cr (2) planes
	FormatYVU444      Format = 0x34325659 // non-subsampled Cr (1) and Cb (2) planes
)

type BOUsage uint32

const (
	// Buffer is going to be presented to the screen using an API such as KMS
	UseScanout BOUsage = 1 << 0
	// Buffer is going to be used as cursor
	UseCursor BOUsage = 1 << 1
	// Buffer is to be used for rendering - for example it is going to be used
	// as the storage for a color buffer
	UseRendering BOUsage = 1 << 2
	// Buffer can be used for gbm_bo_write.  This is guaranteed to work
	// with GBM_BO_USE_CURSOR, but may not work for other combinations.
	UseWrite BOUsage = 1 << 3
	// Buffer is linear, i.e. not tiled.
	UseLinear BOUsage = 1 << 4
)

type ImportUsage uint32

const (
	ImportWlBuffer   ImportUsage = 0x5501
	ImportEglImage   ImportUsage = 0x5502
	ImportFd         ImportUsage = 0x5503
	ImportFdModifier ImportUsage = 0x5504
)

type Device struct{ hnd *C.struct_gbm_device }
type BO struct{ hnd *C.struct_gbm_bo }
type Surface struct{ hnd *C.struct_gbm_surface }

func CreateDevice(fd int) (*Device, error) {
	hnd := C.gbm_create_device(C.int(fd))
	if hnd == nil {
		return nil, errors.New("could not create GBM device")
	}
	return &Device{hnd}, nil
}

func (d *Device) Fd() int {
	return int(C.gbm_device_get_fd(d.hnd))
}

func (d *Device) Handle() unsafe.Pointer {
	return unsafe.Pointer(d.hnd)
}

func (d *Device) BackendName() string {
	return C.GoString(C.gbm_device_get_backend_name(d.hnd))
}

func (d *Device) IsFormatSupported(format Format, usage BOUsage) bool {
	ret := C.gbm_device_is_format_supported(d.hnd, C.uint32_t(format), C.uint32_t(usage))
	return ret == 1
}

func (d *Device) FormatModifierPlaneCount(format Format, modifier uint64) int {
	return int(C.gbm_device_get_format_modifier_plane_count(d.hnd, C.uint32_t(format), C.uint64_t(modifier)))
}

func (d *Device) Destroy() {
	C.gbm_device_destroy(d.hnd)
}

func (d *Device) CreateBO(width, height uint32, format Format, flags BOUsage) *BO {
	return &BO{C.gbm_bo_create(d.hnd, C.uint32_t(width), C.uint32_t(height), C.uint32_t(format), C.uint32_t(flags))}
}

func (d *Device) CreateBOWithModifiers(width, height uint32, format Format, modifiers []uint64) *BO {
	hnd := C.gbm_bo_create_with_modifiers(d.hnd, C.uint32_t(width), C.uint32_t(height), C.uint32_t(format), (*C.uint64_t)(unsafe.Pointer(&modifiers[0])), C.uint(len(modifiers)))
	return &BO{hnd}
}

func (d *Device) ImportBO(typ uint32, buf unsafe.Pointer, usage ImportUsage) *BO {
	return &BO{C.gbm_bo_import(d.hnd, C.uint32_t(typ), buf, C.uint32_t(usage))}
}

func (d *Device) CreateSurface(width, height uint32, format Format, flags BOUsage) (*Surface, error) {
	hnd := C.gbm_surface_create(d.hnd, C.uint32_t(width), C.uint32_t(height), C.uint32_t(format), C.uint32_t(flags))
	if hnd == nil {
		return nil, errors.New("could not create GBM surface")
	}
	return &Surface{hnd}, nil
}

func (d *Device) CreateSurfaceWithModifiers(width, height uint32, format Format, modifiers []uint64) (*Surface, error) {
	hnd := C.gbm_surface_create_with_modifiers(d.hnd, C.uint32_t(width), C.uint32_t(height), C.uint32_t(format), (*C.uint64_t)(unsafe.Pointer(&modifiers[0])), C.uint(len(modifiers)))
	if hnd == nil {
		return nil, errors.New("could not create GBM surface")
	}
	return &Surface{hnd}, nil
}

func (bo *BO) Width() uint32  { return uint32(C.gbm_bo_get_width(bo.hnd)) }
func (bo *BO) Height() uint32 { return uint32(C.gbm_bo_get_height(bo.hnd)) }
func (bo *BO) Stride() uint32 { return uint32(C.gbm_bo_get_stride(bo.hnd)) }
func (bo *BO) StrideForPlane(plane int) uint32 {
	return uint32(C.gbm_bo_get_stride_for_plane(bo.hnd, C.int(plane)))
}
func (bo *BO) Format() Format          { return Format(C.gbm_bo_get_format(bo.hnd)) }
func (bo *BO) Bpp() uint32             { return uint32(C.gbm_bo_get_bpp(bo.hnd)) }
func (bo *BO) Offset(plane int) uint32 { return uint32(C.gbm_bo_get_offset(bo.hnd, C.int(plane))) }
func (bo *BO) Handle() [8]byte         { return C.gbm_bo_get_handle(bo.hnd) }
func (bo *BO) Fd() int                 { return int(C.gbm_bo_get_fd(bo.hnd)) }
func (bo *BO) Modifier() uint64        { return uint64(C.gbm_bo_get_modifier(bo.hnd)) }
func (bo *BO) PlaneCount() int         { return int(C.gbm_bo_get_plane_count(bo.hnd)) }
func (bo *BO) HandleForPlane(plane int) [8]byte {
	return C.gbm_bo_get_handle_for_plane(bo.hnd, C.int(plane))
}
func (bo *BO) Destroy() { C.gbm_bo_destroy(bo.hnd) }
func (bo *BO) Write(b []byte) (int, error) {
	ret := C.gbm_bo_write(bo.hnd, unsafe.Pointer(&b[0]), C.ulong(len(b)))
	if ret != 0 {
		return 0, errors.New("error writing to GBM buffer")
	}
	return len(b), nil
}

func (s *Surface) Handle() unsafe.Pointer { return unsafe.Pointer(s.hnd) }
func (s *Surface) Destroy()               { C.gbm_surface_destroy(s.hnd) }
func (s *Surface) ReleaseBuffer(bo *BO)   { C.gbm_surface_release_buffer(s.hnd, bo.hnd) }
func (s *Surface) HasFreeBuffers() bool   { return C.gbm_surface_has_free_buffers(s.hnd) == 1 }
func (s *Surface) LockFrontBuffer() (*BO, error) {
	hnd := C.gbm_surface_lock_front_buffer(s.hnd)
	if hnd == nil {
		return nil, errors.New("could not lock front buffer")
	}
	return &BO{hnd}, nil
}
