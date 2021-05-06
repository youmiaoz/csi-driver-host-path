package hostpath

import (
	utilexec "k8s.io/utils/exec"
	"os/exec"
)

// Only works for gnu-tar
// exit code 0 and 1 means tar succeeded, others mean failed.
func isTarSuccessful(err error) bool {
	if err == nil {
		return true
	}

	err1, ok := err.(*utilexec.ExitErrorWrapper)
	if ok {
		code := err1.ExitCode()
		if code == 0 || code == 1 {
			return true
		}
	}

	err2, ok := err.(*exec.ExitError)
	if ok {
		code := err2.ExitCode()
		if code == 0 || code == 1 {
			return true
		}
	}

	return false
}
