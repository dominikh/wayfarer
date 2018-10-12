// +build ignore

package main

import "fmt"

type FourCC struct {
	Name    string
	Value   [4]byte
	Comment string
}

var ccs = []FourCC{
	{"C8", [4]byte{'C', '8', ' ', ' '}, "[7:0] C"},
	{"R8", [4]byte{'R', '8', ' ', ' '}, "[7:0] R"},
	{"GR88", [4]byte{'G', 'R', '8', '8'}, "[15:0] G:R 8:8 little endian"},
	{"RGB332", [4]byte{'R', 'G', 'B', '8'}, "[7:0] R:G:B 3:3:2"},
	{"BGR233", [4]byte{'B', 'G', 'R', '8'}, "[7:0] B:G:R 2:3:3"},
	{"XRGB4444", [4]byte{'X', 'R', '1', '2'}, "[15:0] x:R:G:B 4:4:4:4 little endian"},
	{"XBGR4444", [4]byte{'X', 'B', '1', '2'}, "[15:0] x:B:G:R 4:4:4:4 little endian"},
	{"RGBX4444", [4]byte{'R', 'X', '1', '2'}, "[15:0] R:G:B:x 4:4:4:4 little endian"},
	{"BGRX4444", [4]byte{'B', 'X', '1', '2'}, "[15:0] B:G:R:x 4:4:4:4 little endian"},
	{"ARGB4444", [4]byte{'A', 'R', '1', '2'}, "[15:0] A:R:G:B 4:4:4:4 little endian"},
	{"ABGR4444", [4]byte{'A', 'B', '1', '2'}, "[15:0] A:B:G:R 4:4:4:4 little endian"},
	{"RGBA4444", [4]byte{'R', 'A', '1', '2'}, "[15:0] R:G:B:A 4:4:4:4 little endian"},
	{"BGRA4444", [4]byte{'B', 'A', '1', '2'}, "[15:0] B:G:R:A 4:4:4:4 little endian"},
	{"XRGB1555", [4]byte{'X', 'R', '1', '5'}, "[15:0] x:R:G:B 1:5:5:5 little endian"},
	{"XBGR1555", [4]byte{'X', 'B', '1', '5'}, "[15:0] x:B:G:R 1:5:5:5 little endian"},
	{"RGBX5551", [4]byte{'R', 'X', '1', '5'}, "[15:0] R:G:B:x 5:5:5:1 little endian"},
	{"BGRX5551", [4]byte{'B', 'X', '1', '5'}, "[15:0] B:G:R:x 5:5:5:1 little endian"},
	{"ARGB1555", [4]byte{'A', 'R', '1', '5'}, "[15:0] A:R:G:B 1:5:5:5 little endian"},
	{"ABGR1555", [4]byte{'A', 'B', '1', '5'}, "[15:0] A:B:G:R 1:5:5:5 little endian"},
	{"RGBA5551", [4]byte{'R', 'A', '1', '5'}, "[15:0] R:G:B:A 5:5:5:1 little endian"},
	{"BGRA5551", [4]byte{'B', 'A', '1', '5'}, "[15:0] B:G:R:A 5:5:5:1 little endian"},
	{"RGB565", [4]byte{'R', 'G', '1', '6'}, "[15:0] R:G:B 5:6:5 little endian"},
	{"BGR565", [4]byte{'B', 'G', '1', '6'}, "[15:0] B:G:R 5:6:5 little endian"},
	{"RGB888", [4]byte{'R', 'G', '2', '4'}, "[23:0] R:G:B little endian"},
	{"BGR888", [4]byte{'B', 'G', '2', '4'}, "[23:0] B:G:R little endian"},
	{"XRGB8888", [4]byte{'X', 'R', '2', '4'}, "[31:0] x:R:G:B 8:8:8:8 little endian"},
	{"XBGR8888", [4]byte{'X', 'B', '2', '4'}, "[31:0] x:B:G:R 8:8:8:8 little endian"},
	{"RGBX8888", [4]byte{'R', 'X', '2', '4'}, "[31:0] R:G:B:x 8:8:8:8 little endian"},
	{"BGRX8888", [4]byte{'B', 'X', '2', '4'}, "[31:0] B:G:R:x 8:8:8:8 little endian"},
	{"ARGB8888", [4]byte{'A', 'R', '2', '4'}, "[31:0] A:R:G:B 8:8:8:8 little endian"},
	{"ABGR8888", [4]byte{'A', 'B', '2', '4'}, "[31:0] A:B:G:R 8:8:8:8 little endian"},
	{"RGBA8888", [4]byte{'R', 'A', '2', '4'}, "[31:0] R:G:B:A 8:8:8:8 little endian"},
	{"BGRA8888", [4]byte{'B', 'A', '2', '4'}, "[31:0] B:G:R:A 8:8:8:8 little endian"},
	{"XRGB2101010", [4]byte{'X', 'R', '3', '0'}, "[31:0] x:R:G:B 2:10:10:10 little endian"},
	{"XBGR2101010", [4]byte{'X', 'B', '3', '0'}, "[31:0] x:B:G:R 2:10:10:10 little endian"},
	{"RGBX1010102", [4]byte{'R', 'X', '3', '0'}, "[31:0] R:G:B:x 10:10:10:2 little endian"},
	{"BGRX1010102", [4]byte{'B', 'X', '3', '0'}, "[31:0] B:G:R:x 10:10:10:2 little endian"},
	{"ARGB2101010", [4]byte{'A', 'R', '3', '0'}, "[31:0] A:R:G:B 2:10:10:10 little endian"},
	{"ABGR2101010", [4]byte{'A', 'B', '3', '0'}, "[31:0] A:B:G:R 2:10:10:10 little endian"},
	{"RGBA1010102", [4]byte{'R', 'A', '3', '0'}, "[31:0] R:G:B:A 10:10:10:2 little endian"},
	{"BGRA1010102", [4]byte{'B', 'A', '3', '0'}, "[31:0] B:G:R:A 10:10:10:2 little endian"},
	{"YUYV", [4]byte{'Y', 'U', 'Y', 'V'}, "[31:0] Cr0:Y1:Cb0:Y0 8:8:8:8 little endian"},
	{"YVYU", [4]byte{'Y', 'V', 'Y', 'U'}, "[31:0] Cb0:Y1:Cr0:Y0 8:8:8:8 little endian"},
	{"UYVY", [4]byte{'U', 'Y', 'V', 'Y'}, "[31:0] Y1:Cr0:Y0:Cb0 8:8:8:8 little endian"},
	{"VYUY", [4]byte{'V', 'Y', 'U', 'Y'}, "[31:0] Y1:Cb0:Y0:Cr0 8:8:8:8 little endian"},
	{"AYUV", [4]byte{'A', 'Y', 'U', 'V'}, "[31:0] A:Y:Cb:Cr 8:8:8:8 little endian"},
	{"NV12", [4]byte{'N', 'V', '1', '2'}, "2x2 subsampled Cr:Cb plane"},
	{"NV21", [4]byte{'N', 'V', '2', '1'}, "2x2 subsampled Cb:Cr plane"},
	{"NV16", [4]byte{'N', 'V', '1', '6'}, "2x1 subsampled Cr:Cb plane"},
	{"NV61", [4]byte{'N', 'V', '6', '1'}, "2x1 subsampled Cb:Cr plane"},
	{"YUV410", [4]byte{'Y', 'U', 'V', '9'}, "4x4 subsampled Cb (1) and Cr (2) planes"},
	{"YVU410", [4]byte{'Y', 'V', 'U', '9'}, "4x4 subsampled Cr (1) and Cb (2) planes"},
	{"YUV411", [4]byte{'Y', 'U', '1', '1'}, "4x1 subsampled Cb (1) and Cr (2) planes"},
	{"YVU411", [4]byte{'Y', 'V', '1', '1'}, "4x1 subsampled Cr (1) and Cb (2) planes"},
	{"YUV420", [4]byte{'Y', 'U', '1', '2'}, "2x2 subsampled Cb (1) and Cr (2) planes"},
	{"YVU420", [4]byte{'Y', 'V', '1', '2'}, "2x2 subsampled Cr (1) and Cb (2) planes"},
	{"YUV422", [4]byte{'Y', 'U', '1', '6'}, "2x1 subsampled Cb (1) and Cr (2) planes"},
	{"YVU422", [4]byte{'Y', 'V', '1', '6'}, "2x1 subsampled Cr (1) and Cb (2) planes"},
	{"YUV444", [4]byte{'Y', 'U', '2', '4'}, "non-subsampled Cb (1) and Cr (2) planes"},
	{"YVU444", [4]byte{'Y', 'V', '2', '4'}, "non-subsampled Cr (1) and Cb (2) planes"},
}

func main() {
	for _, cc := range ccs {
		a, b, c, d := cc.Value[0], cc.Value[1], cc.Value[2], cc.Value[3]
		val := uint32(a) | (uint32(b) << 8) | (uint32(c) << 16) | (uint32(d) << 24)
		fmt.Printf("Format%s Format = %#x // %s\n", cc.Name, val, cc.Comment)
	}
}
