package swim

/*
#cgo CFLAGS: -x objective-c
#cgo LDFLAGS: -framework Foundation -framework Carbon
#import <Foundation/Foundation.h>

const char* get();
int set(const char *sourceID);
*/
import "C"
import (
	"errors"
	"unsafe"
)

func Get() (string, error) {
	cstr := C.get()
	return C.GoString(cstr), nil
}

func Set(sourceID string) error {
	cstr := C.CString(sourceID)
	defer C.free(unsafe.Pointer(cstr))
	if ok := C.set(cstr); ok != 0 {
		return errors.New("set failed")
	}
	return nil
}
