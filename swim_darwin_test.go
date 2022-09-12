package swim_test

import (
	"testing"

	"github.com/Warashi/go-swim"
)

func TestPackage(t *testing.T) {
	current := swim.Get()
	t.Log(swim.Get())
	if err := swim.Set(current); err != nil {
		t.Error(err)
	}
}
