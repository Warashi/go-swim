//go:build !darwin

package swim

func Get() (string, error) {
	return "", ErrNotSupported
}

func Set(string) error {
	return ErrNotSupported
}
