// Package drm provides a pure Go interface to Linux's
// Direct Rendering Manager (DRM), including support for Kernel mode setting (KMS).
package drm

import (
	"errors"
	"os"
	"reflect"
	"syscall"
	"unsafe"
)

const (
	CapDumbBuffer                = 0x1
	DRM_CAP_VBLANK_HIGH_CRTC     = 0x2
	DRM_CAP_DUMB_PREFERRED_DEPTH = 0x3
	DRM_CAP_DUMB_PREFER_SHADOW   = 0x4
	DRM_CAP_PRIME                = 0x5
	DRM_PRIME_CAP_IMPORT         = 0x1
	DRM_PRIME_CAP_EXPORT         = 0x2
	DRM_CAP_TIMESTAMP_MONOTONIC  = 0x6
	DRM_CAP_ASYNC_PAGE_FLIP      = 0x7

	DRM_CAP_CURSOR_WIDTH         = 0x8
	DRM_CAP_CURSOR_HEIGHT        = 0x9
	DRM_CAP_ADDFB2_MODIFIERS     = 0x10
	DRM_CAP_PAGE_FLIP_TARGET     = 0x11
	DRM_CAP_CRTC_IN_VBLANK_EVENT = 0x12
	DRM_CAP_SYNCOBJ              = 0x13
)

type (
	drmGetCap struct {
		capability uint64
		value      uint64
	}

	drmModeCardRes struct {
		fb_id_ptr              uint64
		crtc_id_ptr            uint64
		connector_id_ptr       uint64
		encoder_id_ptr         uint64
		count_fbs              uint32
		count_crtcs            uint32
		count_connectors       uint32
		count_encoders         uint32
		min_width, max_width   uint32
		min_height, max_height uint32
	}

	drmModeGetConnector struct {
		encoders_ptr    uint64
		modes_ptr       uint64
		props_ptr       uint64
		prop_values_ptr uint64

		count_modes    uint32
		count_props    uint32
		count_encoders uint32

		encoder_id        uint32
		connector_id      uint32
		connector_type    uint32
		connector_type_id uint32

		connection uint32
		mm_width   uint32
		mm_height  uint32
		subpixel   uint32

		pad uint32
	}

	drmModeModeinfo struct {
		clock       uint32
		hdisplay    uint16
		hsync_start uint16
		hsync_end   uint16
		htotal      uint16
		hskew       uint16
		vdisplay    uint16
		vsync_start uint16
		vsync_end   uint16
		vtotal      uint16
		vscan       uint16

		vrefresh uint32

		flags uint32
		typ   uint32
		name  [DRM_DISPLAY_MODE_LEN]byte
	}

	drmModeGetEncoder struct {
		encoder_id   uint32
		encoder_type uint32

		crtc_id uint32

		possible_crtcs  uint32
		possible_clones uint32
	}

	drmModeCreateDumb struct {
		height uint32
		width  uint32
		bpp    uint32
		flags  uint32

		handle uint32
		pitch  uint32
		size   uint64
	}

	drmModeFbCmd struct {
		fb_id         uint32
		width, height uint32
		pitch         uint32
		bpp           uint32
		depth         uint32
		// driver specific handle
		handle uint32
	}

	drmModeMapDumb struct {
		handle uint32
		pad    uint32
		offset uint64
	}

	drmModeCrtc struct {
		set_connectors_ptr uint64
		count_connectors   uint32

		crtc_id uint32
		fb_id   uint32

		x, y uint32

		gamma_size uint32
		mode_valid uint32
		mode       drmModeModeinfo
	}

	drmSetClientCap struct {
		capability uint64
		value      uint64
	}

	drmModeGetProperty struct {
		values_ptr    uint64
		enum_blob_ptr uint64

		prop_id uint32
		flags   uint32
		name    [DRM_PROP_NAME_LEN]byte

		count_values     uint32
		count_enum_blobs uint32
	}

	drmModePropertyEnum struct {
		value uint64
		name  [DRM_PROP_NAME_LEN]byte
	}

	drmModeObjGetProperties struct {
		props_ptr       uint64
		prop_values_ptr uint64
		count_props     uint32
		obj_id          uint32
		obj_type        uint32
	}

	drmModeFbCmd2 struct {
		fb_id        uint32
		width        uint32
		height       uint32
		pixel_format uint32
		flags        uint32
		handles      [4]uint32
		pitches      [4]uint32
		offsets      [4]uint32
		modifier     [4]uint64
	}
)

const (
	DRM_DISPLAY_MODE_LEN = 32
	DRM_PROP_NAME_LEN    = 32
)

type (
	ModeRes struct {
		Fbs                  []uint32
		Crtcs                []uint32
		Connectors           []uint32
		Encoders             []uint32
		MinWidth, MaxWidth   uint32
		MinHeight, MaxHeight uint32
	}

	ModeInfo struct {
		Clock      uint32
		Hdisplay   uint16
		HsyncStart uint16
		HsyncEnd   uint16
		Htotal     uint16
		Hskew      uint16
		Vdisplay   uint16
		VsyncStart uint16
		VsyncEnd   uint16
		Vtotal     uint16
		Vscan      uint16
		Vrefresh   uint32

		Flags uint32
		Type  uint32
		Name  string
	}

	ModeConnector struct {
		Modes           []ModeInfo
		Encoders        []uint32
		EncoderID       uint32
		ConnectorID     uint32
		ConnectorType   uint32
		ConnectorTypeID uint32
		Connection      ModeConnection
		Width, Height   uint32
		Subpixel        uint32

		Properties []Property
	}

	ModeEncoder struct {
		EncoderID   uint32
		EncoderType uint32

		CrtcID uint32

		PossibleCrtcs  uint32
		PossibleClones uint32

		Properties []Property
	}

	ModeDumb struct {
		Height uint32
		Width  uint32
		Bpp    uint32
		Flags  uint32

		Handle uint32
		Pitch  uint32
		Size   uint64
	}

	ModeCrtc struct {
		CrtcID uint32
		FbID   uint32

		X, Y uint32

		GammaSize uint32
		Mode      *ModeInfo

		Properties []Property
	}
)

type ModeConnection uint32

const (
	ModeConnected         ModeConnection = 1
	ModeDisconnected      ModeConnection = 2
	ModeUnknownConnection ModeConnection = 3
)

const (
	DRM_MODE_TYPE_PREFERRED = 1 << 3
)

func (c ModeConnection) String() string {
	switch c {
	case ModeConnected:
		return "connected"
	case ModeDisconnected:
		return "disconnected"
	default:
		return "unknown"
	}
}

type Handle struct {
	fd int
}

func (hnd *Handle) ioctl(op uintptr, arg unsafe.Pointer) (int, error) {
	for {
		r1, _, errno := syscall.Syscall(syscall.SYS_IOCTL, uintptr(hnd.fd), uintptr(op), uintptr(arg))
		ret := int(r1)
		if ret != -1 || (errno != syscall.EINTR && errno != syscall.EAGAIN) {
			var err error
			if errno != 0 {
				err = errno
			}
			return ret, err
		}
	}
}

func Open(path string) (*Handle, error) {
	f, err := syscall.Open(path, os.O_RDWR|syscall.O_CLOEXEC, 0)
	if err != nil {
		return nil, err
	}
	return &Handle{f}, nil
}

func (hnd *Handle) Fd() int { return hnd.fd }

func (hnd *Handle) Cap(capability uint64) (uint64, error) {
	req := drmGetCap{
		capability: capability,
	}
	ret, err := hnd.ioctl(DRM_IOCTL_GET_CAP.value, unsafe.Pointer(&req))
	if err != nil {
		return 0, err
	}
	if ret != 0 {
		return 0, errors.New("XXX")
	}
	return req.value, nil
}

func (hnd *Handle) Resources() (ModeRes, error) {
retry:
	for {
		// fetch counts
		var res drmModeCardRes
		r, err := hnd.ioctl(DRM_IOCTL_MODE_GETRESOURCES.value, unsafe.Pointer(&res))
		if err != nil {
			return ModeRes{}, err
		}
		if r != 0 {
			// XXX libdrm returns null here. why? when does this happen?
		}

		counts := res

		res.fb_id_ptr = uint64(uintptr(malloc(uintptr(res.count_fbs) * unsafe.Sizeof(uint32(0)))))
		res.crtc_id_ptr = uint64(uintptr(malloc(uintptr(res.count_crtcs) * unsafe.Sizeof(uint32(0)))))
		res.connector_id_ptr = uint64(uintptr(malloc(uintptr(res.count_connectors) * unsafe.Sizeof(uint32(0)))))
		res.encoder_id_ptr = uint64(uintptr(malloc(uintptr(res.count_encoders) * unsafe.Sizeof(uint32(0)))))

		// fetch data
		r, err = hnd.ioctl(DRM_IOCTL_MODE_GETRESOURCES.value, unsafe.Pointer(&res))
		if err != nil {
			return ModeRes{}, err
		}
		if r != 0 {
			// XXX libdrm returns null here. why? when does this happen?
		}

		if res.count_fbs > counts.count_fbs ||
			res.count_crtcs > counts.count_crtcs ||
			res.count_connectors > counts.count_connectors ||
			res.count_encoders > counts.count_encoders {

			// more devices have shown up between the two ioctls,
			// retry to get all devices

			free(unsafe.Pointer(uintptr(res.fb_id_ptr)))
			free(unsafe.Pointer(uintptr(res.crtc_id_ptr)))
			free(unsafe.Pointer(uintptr(res.connector_id_ptr)))
			free(unsafe.Pointer(uintptr(res.encoder_id_ptr)))
			continue retry
		}

		var out ModeRes
		out.Fbs = make([]uint32, res.count_fbs)
		out.Crtcs = make([]uint32, res.count_crtcs)
		out.Connectors = make([]uint32, res.count_connectors)
		out.Encoders = make([]uint32, res.count_encoders)

		copy(out.Fbs, (*[1 << 31]uint32)(unsafe.Pointer(uintptr(res.fb_id_ptr)))[:res.count_fbs])
		copy(out.Crtcs, (*[1 << 31]uint32)(unsafe.Pointer(uintptr(res.crtc_id_ptr)))[:res.count_crtcs])
		copy(out.Connectors, (*[1 << 31]uint32)(unsafe.Pointer(uintptr(res.connector_id_ptr)))[:res.count_connectors])
		copy(out.Encoders, (*[1 << 31]uint32)(unsafe.Pointer(uintptr(res.encoder_id_ptr)))[:res.count_encoders])
		out.MinWidth = res.min_width
		out.MinHeight = res.min_height
		out.MaxWidth = res.max_width
		out.MaxHeight = res.max_height

		free(unsafe.Pointer(uintptr(res.fb_id_ptr)))
		free(unsafe.Pointer(uintptr(res.crtc_id_ptr)))
		free(unsafe.Pointer(uintptr(res.connector_id_ptr)))
		free(unsafe.Pointer(uintptr(res.encoder_id_ptr)))

		return out, nil
	}
}

func (hnd *Handle) Connector(id uint32) (ModeConnector, error) {
	// drmModeGetConnector
retry:
	for {
		var conn drmModeGetConnector
		conn.connector_id = id
		r, err := hnd.ioctl(DRM_IOCTL_MODE_GETCONNECTOR.value, unsafe.Pointer(&conn))
		if err != nil {
			return ModeConnector{}, err
		}
		if r != 0 {
			// XXX
		}
		counts := conn

		conn.props_ptr = uint64(uintptr(malloc(uintptr(conn.count_props) * unsafe.Sizeof(uint32(0)))))
		conn.prop_values_ptr = uint64(uintptr(malloc(uintptr(conn.count_props) * unsafe.Sizeof(uint64(0)))))
		conn.modes_ptr = uint64(uintptr(malloc(uintptr(conn.count_modes) * unsafe.Sizeof(drmModeModeinfo{}))))
		conn.encoders_ptr = uint64(uintptr(malloc(uintptr(conn.count_encoders) * unsafe.Sizeof(uint32(0)))))

		r, err = hnd.ioctl(DRM_IOCTL_MODE_GETCONNECTOR.value, unsafe.Pointer(&conn))
		if err != nil {
			return ModeConnector{}, err
		}
		if r != 0 {
			// XXX
		}
		if conn.count_props > counts.count_props ||
			conn.count_modes > counts.count_modes ||
			conn.count_encoders > counts.count_encoders {

			free(unsafe.Pointer(uintptr(conn.props_ptr)))
			free(unsafe.Pointer(uintptr(conn.prop_values_ptr)))
			free(unsafe.Pointer(uintptr(conn.modes_ptr)))
			free(unsafe.Pointer(uintptr(conn.encoders_ptr)))
			continue retry
		}

		var out ModeConnector

		out.ConnectorID = conn.connector_id
		out.EncoderID = conn.encoder_id
		out.Connection = ModeConnection(conn.connection)
		out.Width = conn.mm_width
		out.Height = conn.mm_height
		out.Subpixel = conn.subpixel + 1
		out.ConnectorType = conn.connector_type
		out.ConnectorTypeID = conn.connector_type_id

		out.Modes = make([]ModeInfo, conn.count_modes)
		out.Encoders = make([]uint32, conn.count_encoders)

		info := (*[1 << 31]drmModeModeinfo)(unsafe.Pointer(uintptr(conn.modes_ptr)))[:conn.count_modes]
		for i := range info {
			out.Modes[i] = ModeInfo{
				Clock:      info[i].clock,
				Hdisplay:   info[i].hdisplay,
				HsyncStart: info[i].hsync_start,
				HsyncEnd:   info[i].hsync_end,
				Htotal:     info[i].htotal,
				Hskew:      info[i].hskew,
				Vdisplay:   info[i].vdisplay,
				VsyncStart: info[i].vsync_start,
				VsyncEnd:   info[i].vsync_end,
				Vtotal:     info[i].vtotal,
				Vscan:      info[i].vscan,
				Vrefresh:   info[i].vrefresh,
				Flags:      info[i].flags,
				Type:       info[i].typ,
				Name:       str(info[i].name[:]),
			}
		}
		copy(out.Encoders, (*[1 << 31]uint32)(unsafe.Pointer(uintptr(conn.encoders_ptr)))[:conn.count_encoders])

		free(unsafe.Pointer(uintptr(conn.props_ptr)))
		free(unsafe.Pointer(uintptr(conn.prop_values_ptr)))
		free(unsafe.Pointer(uintptr(conn.modes_ptr)))
		free(unsafe.Pointer(uintptr(conn.encoders_ptr)))

		out.Properties = hnd.objectGetProperties(out.ConnectorID, DRM_MODE_OBJECT_CONNECTOR)

		return out, nil
	}
}

func (hnd *Handle) Encoder(id uint32) (ModeEncoder, error) {
	var enc drmModeGetEncoder
	enc.encoder_id = id
	r, err := hnd.ioctl(DRM_IOCTL_MODE_GETENCODER.value, unsafe.Pointer(&enc))
	if err != nil {
		return ModeEncoder{}, err
	}
	if r != 0 {
		// XXX
	}

	return ModeEncoder{
		EncoderID:      enc.encoder_id,
		EncoderType:    enc.encoder_type,
		CrtcID:         enc.crtc_id,
		PossibleCrtcs:  enc.possible_crtcs,
		PossibleClones: enc.possible_clones,
		Properties:     hnd.objectGetProperties(enc.encoder_id, DRM_MODE_OBJECT_ENCODER),
	}, nil
}

func (hnd *Handle) CreateDumb(width, height, bpp uint32) ModeDumb {
	var req drmModeCreateDumb
	req.width = width
	req.height = height
	req.bpp = bpp
	hnd.ioctl(DRM_IOCTL_MODE_CREATE_DUMB.value, unsafe.Pointer(&req))
	// XXX error handling
	return ModeDumb{
		Bpp:    req.bpp,
		Flags:  req.flags,
		Handle: req.handle,
		Height: req.height,
		Pitch:  req.pitch,
		Size:   req.size,
		Width:  req.width,
	}
}

func (hnd *Handle) DestroyDumb(handle uint32) {
	hnd.ioctl(DRM_IOCTL_MODE_DESTROY_DUMB.value, unsafe.Pointer(&handle))
}

func (hnd *Handle) AddFB(width, height uint32, depth, bpp uint8, pitch, bo_handle uint32) uint32 {
	var f drmModeFbCmd

	f.width = width
	f.height = height
	f.pitch = pitch
	f.bpp = uint32(bpp)
	f.depth = uint32(depth)
	f.handle = bo_handle

	hnd.ioctl(DRM_IOCTL_MODE_ADDFB.value, unsafe.Pointer(&f))
	// XXX error handling
	return f.fb_id
}

func (hnd *Handle) AddFB2WithModifiers(width, height, format uint32, handles, pitches, offsets [4]uint32, modifiers [4]uint64, flags uint32) (uint32, error) {
	var f drmModeFbCmd2
	f.width = width
	f.height = height
	f.pixel_format = format
	f.flags = flags
	f.handles = handles
	f.pitches = pitches
	f.offsets = offsets
	f.modifier = modifiers

	_, err := hnd.ioctl(DRM_IOCTL_MODE_ADDFB2.value, unsafe.Pointer(&f))
	return f.fb_id, err
}

func (hnd *Handle) RmFB(fb uint32) {
	hnd.ioctl(DRM_IOCTL_MODE_RMFB.value, unsafe.Pointer(&fb))
}

func (hnd *Handle) Mmap(handle uint32, size uint32) []byte {
	var mreq drmModeMapDumb
	mreq.handle = handle
	hnd.ioctl(DRM_IOCTL_MODE_MAP_DUMB.value, unsafe.Pointer(&mreq))
	// XXX error handling
	p, _, errno := syscall.Syscall6(9, 0, uintptr(size), syscall.PROT_READ|syscall.PROT_WRITE, syscall.MAP_SHARED, uintptr(hnd.fd), uintptr(mreq.offset))
	if errno != 0 {
		// XXX
		panic(errno)
	}
	return (*[1 << 31]byte)(unsafe.Pointer(p))[:size]
}

func (hnd *Handle) SetCrtc(crtcID, bufferID uint32, x, y uint32, connectors []uint32, mode *ModeInfo) error {
	var crtc drmModeCrtc
	crtc.x = x
	crtc.y = y
	crtc.crtc_id = crtcID
	crtc.fb_id = bufferID
	crtc.set_connectors_ptr = uint64(uintptr(unsafe.Pointer(&connectors[0])))
	crtc.count_connectors = uint32(len(connectors))
	if mode != nil {
		crtc.mode.clock = mode.Clock
		crtc.mode.flags = mode.Flags
		crtc.mode.hdisplay = mode.Hdisplay
		crtc.mode.hskew = mode.Hskew
		crtc.mode.hsync_end = mode.HsyncEnd
		crtc.mode.hsync_start = mode.HsyncStart
		crtc.mode.htotal = mode.Htotal
		copy(crtc.mode.name[:], mode.Name)
		crtc.mode.typ = mode.Type
		crtc.mode.vdisplay = mode.Vdisplay
		crtc.mode.vrefresh = mode.Vrefresh
		crtc.mode.vscan = mode.Vscan
		crtc.mode.vsync_end = mode.VsyncEnd
		crtc.mode.vsync_start = mode.VsyncStart
		crtc.mode.vtotal = mode.Vtotal
		crtc.mode_valid = 1
	}
	_, err := hnd.ioctl(DRM_IOCTL_MODE_SETCRTC.value, unsafe.Pointer(&crtc))
	if err != nil {
		return err
	}
	return nil
}

func (hnd *Handle) Crtc(crtcID uint32) ModeCrtc {
	var crtc drmModeCrtc
	crtc.crtc_id = crtcID
	hnd.ioctl(DRM_IOCTL_MODE_GETCRTC.value, unsafe.Pointer(&crtc))
	// XXX error handling

	out := ModeCrtc{
		CrtcID:     crtc.crtc_id,
		X:          crtc.x,
		Y:          crtc.y,
		FbID:       crtc.fb_id,
		GammaSize:  crtc.gamma_size,
		Properties: hnd.objectGetProperties(crtc.crtc_id, DRM_MODE_OBJECT_CRTC),
	}
	if crtc.mode_valid != 0 {
		out.Mode = &ModeInfo{
			Clock:      crtc.mode.clock,
			Hdisplay:   crtc.mode.hdisplay,
			HsyncStart: crtc.mode.hsync_start,
			HsyncEnd:   crtc.mode.hsync_end,
			Htotal:     crtc.mode.htotal,
			Hskew:      crtc.mode.hskew,
			Vdisplay:   crtc.mode.vdisplay,
			VsyncStart: crtc.mode.vsync_start,
			VsyncEnd:   crtc.mode.vsync_end,
			Vtotal:     crtc.mode.vtotal,
			Vscan:      crtc.mode.vscan,

			Vrefresh: crtc.mode.vrefresh,

			Flags: crtc.mode.flags,
			Type:  crtc.mode.typ,
			Name:  str(crtc.mode.name[:]),
		}
	}

	return out
}

func (hnd *Handle) SetMaster() {
	hnd.ioctl(DRM_IOCTL_SET_MASTER.value, nil)
}

func (hnd *Handle) DropMaster() {
	hnd.ioctl(DRM_IOCTL_DROP_MASTER.value, nil)
}

func (hnd *Handle) SetClientCap(capability uint64, value uint64) {
	req := drmSetClientCap{capability, value}
	hnd.ioctl(DRM_IOCTL_SET_CLIENT_CAP.value, unsafe.Pointer(&req))
}

type Property struct {
	Property PropertyType
	Value    uint64
}

type PropertyType struct {
	Name string
	Type interface{}
}

type RangeProperty struct {
	Min, Max uint64
}

type EnumProperty struct {
	Enums []Enum
}

type BitflagProperty struct {
	Enums []Enum
}

type Enum struct {
	Name  string
	Value uint64
}

func (hnd *Handle) getProperty(id uint32) PropertyType {
	var prop drmModeGetProperty
	prop.prop_id = id
	hnd.ioctl(DRM_IOCTL_MODE_GETPROPERTY.value, unsafe.Pointer(&prop))
	if prop.count_values > 0 {
		prop.values_ptr = uint64(uintptr(malloc(uintptr(prop.count_values) * unsafe.Sizeof(uint64(0)))))
		defer free(unsafe.Pointer(uintptr(prop.values_ptr)))
	}
	if prop.count_enum_blobs > 0 && (prop.flags&(DRM_MODE_PROP_ENUM|DRM_MODE_PROP_BITMASK)) != 0 {
		prop.enum_blob_ptr = uint64(uintptr(malloc(uintptr(prop.count_enum_blobs) * unsafe.Sizeof(drmModePropertyEnum{}))))
		defer free(unsafe.Pointer(uintptr(prop.enum_blob_ptr)))
	}
	if prop.count_enum_blobs > 0 && prop.flags&DRM_MODE_PROP_BLOB != 0 {
		prop.values_ptr = uint64(uintptr(malloc(uintptr(prop.count_enum_blobs) * unsafe.Sizeof(uint32(0)))))
		prop.enum_blob_ptr = uint64(uintptr(malloc(uintptr(prop.count_enum_blobs) * unsafe.Sizeof(uint32(0)))))
		defer free(unsafe.Pointer(uintptr(prop.values_ptr)))
		defer free(unsafe.Pointer(uintptr(prop.enum_blob_ptr)))
	}
	hnd.ioctl(DRM_IOCTL_MODE_GETPROPERTY.value, unsafe.Pointer(&prop))

	var outEnums []Enum
	if prop.count_enum_blobs > 0 && (prop.flags&(DRM_MODE_PROP_ENUM|DRM_MODE_PROP_BITMASK)) != 0 {
		enums := (*[1 << 31]drmModePropertyEnum)(unsafe.Pointer(uintptr(prop.enum_blob_ptr)))[:prop.count_enum_blobs]
		for _, enum := range enums {
			outEnums = append(outEnums, Enum{str(enum.name[:]), enum.value})
		}
	}

	if (prop.flags & DRM_MODE_PROP_RANGE) != 0 {
		if prop.count_values != 2 {
			panic("internal error: wrong assumption about range properties")
		}
		v := (*[2]uint64)(unsafe.Pointer(uintptr(prop.values_ptr)))
		return PropertyType{
			str(prop.name[:]),
			RangeProperty{v[0], v[1]},
		}
	}

	if (prop.flags & DRM_MODE_PROP_ENUM) != 0 {
		enumProp := EnumProperty{}
		enums := (*[1 << 31]drmModePropertyEnum)(unsafe.Pointer(uintptr(prop.enum_blob_ptr)))[:prop.count_enum_blobs]
		for _, enum := range enums {
			enumProp.Enums = append(enumProp.Enums, Enum{str(enum.name[:]), enum.value})
		}
		return PropertyType{
			str(prop.name[:]),
			enumProp,
		}
	}

	if (prop.flags & DRM_MODE_PROP_ENUM) != 0 {
		bitProp := BitflagProperty{}
		enums := (*[1 << 31]drmModePropertyEnum)(unsafe.Pointer(uintptr(prop.enum_blob_ptr)))[:prop.count_enum_blobs]
		for _, enum := range enums {
			bitProp.Enums = append(bitProp.Enums, Enum{str(enum.name[:]), enum.value})
		}
		return PropertyType{
			str(prop.name[:]),
			bitProp,
		}
	}

	if (prop.flags & DRM_MODE_PROP_BLOB) != 0 {
		panic("not implemented")
	}

	panic("unreachable")
}

func (hnd *Handle) objectGetProperties(obj uint32, typ uint32) []Property {
	var properties drmModeObjGetProperties
	properties.obj_id = obj
	properties.obj_type = typ
	hnd.ioctl(DRM_IOCTL_MODE_OBJ_GETPROPERTIES.value, unsafe.Pointer(&properties))
	properties.props_ptr = uint64(uintptr(malloc(uintptr(properties.count_props) * unsafe.Sizeof(uint32(0)))))
	properties.prop_values_ptr = uint64(uintptr(malloc(uintptr(properties.count_props) * unsafe.Sizeof(uint32(0)))))
	defer free(unsafe.Pointer(uintptr(properties.props_ptr)))
	defer free(unsafe.Pointer(uintptr(properties.prop_values_ptr)))
	hnd.ioctl(DRM_IOCTL_MODE_OBJ_GETPROPERTIES.value, unsafe.Pointer(&properties))
	// XXX retry if count changed

	props := (*[1 << 31]uint32)(unsafe.Pointer(uintptr(properties.props_ptr)))[:properties.count_props]
	values := (*[1 << 31]uint32)(unsafe.Pointer(uintptr(properties.prop_values_ptr)))[:properties.count_props]

	var out []Property
	for i, prop := range props {
		out = append(out, Property{
			Property: hnd.getProperty(prop),
			Value:    uint64(values[i]),
		})
	}
	return out
}

const (
	opIn    = 0x80000000
	opOut   = 0x40000000
	opInOut = opIn | opOut
)

type op struct {
	code uintptr
	sig  uintptr
	typ  interface{}
	// This field is filled in at runtime
	value uintptr
}

var (
	DRM_IOCTL_GET_CAP = op{
		code: 0x0c,
		sig:  opInOut,
		typ:  drmGetCap{},
	}
	DRM_IOCTL_MODE_GETRESOURCES = op{
		// DRM_IOWR(0xA0, struct drm_mode_card_res)
		code: 0xA0,
		sig:  opInOut,
		typ:  drmModeCardRes{},
	}
	DRM_IOCTL_MODE_GETCONNECTOR = op{
		// DRM_IOWR(0xA7, struct drm_mode_get_connector)
		code: 0xA7,
		sig:  opInOut,
		typ:  drmModeGetConnector{},
	}
	DRM_IOCTL_MODE_GETENCODER = op{
		// DRM_IOWR(0xA6, struct drm_mode_get_encoder)
		code: 0xA6,
		sig:  opInOut,
		typ:  drmModeGetEncoder{},
	}
	DRM_IOCTL_MODE_CREATE_DUMB = op{
		// DRM_IOCTL_MODE_CREATE_DUMB DRM_IOWR(0xB2, struct drm_mode_create_dumb)
		code: 0xB2,
		sig:  opInOut,
		typ:  drmModeCreateDumb{},
	}
	DRM_IOCTL_MODE_ADDFB = op{
		// DRM_IOCTL_MODE_ADDFB		DRM_IOWR(0xAE, struct drm_mode_fb_cmd)
		code: 0xAE,
		sig:  opInOut,
		typ:  drmModeFbCmd{},
	}
	DRM_IOCTL_MODE_MAP_DUMB = op{
		// DRM_IOCTL_MODE_MAP_DUMB    DRM_IOWR(0xB3, struct drm_mode_map_dumb)
		code: 0xB3,
		sig:  opInOut,
		typ:  drmModeMapDumb{},
	}
	DRM_IOCTL_MODE_SETCRTC = op{
		// DRM_IOCTL_MODE_SETCRTC		DRM_IOWR(0xA2, struct drm_mode_crtc)
		code: 0xA2,
		sig:  opInOut,
		typ:  drmModeCrtc{},
	}
	DRM_IOCTL_SET_MASTER = op{
		code: 0x1E,
	}
	DRM_IOCTL_DROP_MASTER = op{
		code: 0x1F,
	}
	DRM_IOCTL_MODE_RMFB = op{
		// DRM_IOCTL_MODE_RMFB		DRM_IOWR(0xAF, unsigned int)
		code: 0xAF,
		sig:  opInOut,
		typ:  uint32(0),
	}
	DRM_IOCTL_MODE_DESTROY_DUMB = op{
		code: 0xB4,
		sig:  opInOut,
		typ:  uint32(0),
	}
	DRM_IOCTL_MODE_GETCRTC = op{
		code: 0xA0,
		sig:  opInOut,
		typ:  drmModeCrtc{},
	}
	DRM_IOCTL_SET_CLIENT_CAP = op{
		code: 0x0D,
		sig:  opIn,
		typ:  drmSetClientCap{},
	}
	DRM_IOCTL_MODE_GETPROPERTY = op{
		code: 0xAA,
		sig:  opInOut,
		typ:  drmModeGetProperty{},
	}
	DRM_IOCTL_MODE_OBJ_GETPROPERTIES = op{
		code: 0xB9,
		sig:  opInOut,
		typ:  drmModeObjGetProperties{},
	}
	DRM_IOCTL_MODE_ADDFB2 = op{
		code: 0xB8,
		sig:  opInOut,
		typ:  drmModeFbCmd2{},
	}
)

var ops = []*op{
	&DRM_IOCTL_GET_CAP,
	&DRM_IOCTL_MODE_GETRESOURCES,
	&DRM_IOCTL_MODE_GETCONNECTOR,
	&DRM_IOCTL_MODE_GETENCODER,
	&DRM_IOCTL_MODE_CREATE_DUMB,
	&DRM_IOCTL_MODE_ADDFB,
	&DRM_IOCTL_MODE_MAP_DUMB,
	&DRM_IOCTL_MODE_SETCRTC,
	&DRM_IOCTL_SET_MASTER,
	&DRM_IOCTL_DROP_MASTER,
	&DRM_IOCTL_MODE_DESTROY_DUMB,
	&DRM_IOCTL_MODE_GETCRTC,
	&DRM_IOCTL_SET_CLIENT_CAP,
	&DRM_IOCTL_MODE_GETPROPERTY,
	&DRM_IOCTL_MODE_OBJ_GETPROPERTIES,
	&DRM_IOCTL_MODE_ADDFB2,
}

func init() {
	const DRM_IOCTL_BASE = 'd'

	_IOC := func(inout, group, num, len uintptr) uintptr {
		const IOCPARM_MASK = 0x1fff
		return (inout | ((len & IOCPARM_MASK) << 16) | ((group) << 8) | num)
	}

	for _, op := range ops {
		var size uintptr
		if op.typ != nil {
			size = reflect.TypeOf(op.typ).Size()
		}
		op.value = _IOC(op.sig, DRM_IOCTL_BASE, op.code, size)
	}
}

const DRM_CAP_DUMB_BUFFER = 0x1

const DRM_CLIENT_CAP_ATOMIC = 3

const (
	DRM_MODE_PROP_PENDING   = 1 << 0
	DRM_MODE_PROP_RANGE     = 1 << 1
	DRM_MODE_PROP_IMMUTABLE = 1 << 2
	DRM_MODE_PROP_ENUM      = 1 << 3
	DRM_MODE_PROP_BLOB      = 1 << 4
	DRM_MODE_PROP_BITMASK   = 1 << 5
)

const (
	DRM_MODE_OBJECT_CRTC      = 0xcccccccc
	DRM_MODE_OBJECT_CONNECTOR = 0xc0c0c0c0
	DRM_MODE_OBJECT_ENCODER   = 0xe0e0e0e0
	DRM_MODE_OBJECT_MODE      = 0xdededede
	DRM_MODE_OBJECT_PROPERTY  = 0xb0b0b0b0
	DRM_MODE_OBJECT_FB        = 0xfbfbfbfb
	DRM_MODE_OBJECT_BLOB      = 0xbbbbbbbb
	DRM_MODE_OBJECT_PLANE     = 0xeeeeeeee
	DRM_MODE_OBJECT_ANY       = 0
)

const DRM_MODE_FB_MODIFIERS = 2

const DRM_FORMAT_MOD_INVALID = 1<<56 - 1
