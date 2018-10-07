package drm

import (
	"bytes"
	"fmt"
	"syscall"
	"unsafe"
)

func malloc(size uintptr) unsafe.Pointer {
	const trap = 9
	p, _, errno := syscall.Syscall6(trap, 0, size+8, syscall.PROT_READ|syscall.PROT_WRITE, syscall.MAP_PRIVATE|syscall.MAP_ANONYMOUS, ^uintptr(0), 0)
	if errno != 0 {
		panic(fmt.Sprintln("malloc failed", errno))
	}

	(*[1]uintptr)(unsafe.Pointer(p))[0] = size

	return unsafe.Pointer(p + 8)
}

func free(p unsafe.Pointer) {
	if p == nil {
		return
	}

	const trap = 11
	size := (*[1]uintptr)(unsafe.Pointer(uintptr(p) - 8))[0]
	syscall.Syscall(trap, uintptr(p), size, 0)
}

func str(b []byte) string {
	return string(b[:bytes.IndexByte(b, 0)])
}
