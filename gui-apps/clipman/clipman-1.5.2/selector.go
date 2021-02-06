package main

import (
	"errors"
	"fmt"
	"os"
	"os/exec"
	"strconv"
	"strings"

	"github.com/kballard/go-shellquote"
)

func selector(data []string, max int, tool, prompt, toolArgs string, null bool) (string, error) {
	if len(data) == 0 {
		return "", errors.New("nothing to show: no data available")
	}

	// output to stdout and return
	if tool == "STDOUT" {
		escaped, _ := preprocessData(data, 0, !null)
		sep := "\n"
		if null {
			sep = "\000"
		}
		os.Stdout.WriteString(strings.Join(escaped, sep))
		return "", nil
	}

	var (
		args []string
		err  error
	)

	switch tool {
	case "dmenu":
		args = []string{"dmenu", "-b",
			"-fn",
			"-misc-dejavu sans mono-medium-r-normal--17-120-100-100-m-0-iso8859-16",
			"-l",
			strconv.Itoa(max)}
	case "bemenu":
		args = []string{"bemenu", "--bottom", "--prompt", prompt, "--list", strconv.Itoa(max)}
	case "rofi":
		args = []string{"rofi", "-p", prompt, "-dmenu",
			"-lines",
			strconv.Itoa(max)}
	case "wofi":
		args = []string{"wofi", "-p", prompt, "--cache-file", "/dev/null", "--dmenu"}
	case "CUSTOM":
		if len(toolArgs) == 0 {
			return "", fmt.Errorf("missing tool args for CUSTOM tool")
		}
		args, err = shellquote.Split(toolArgs)
		if err != nil {
			return "", fmt.Errorf("selector: %w", err)
		}
	default:
		return "", fmt.Errorf("unsupported tool: %s", tool)
	}

	if tool == "CUSTOM" {
		tool = args[0]
	} else if len(toolArgs) > 0 {
		targs, err := shellquote.Split(toolArgs)
		if err != nil {
			return "", fmt.Errorf("selector: %w", err)
		}
		args = append(args, targs...)
	}

	bin, err := exec.LookPath(tool)
	if err != nil {
		return "", fmt.Errorf("%s is not installed", tool)
	}

	processed, guide := preprocessData(data, 1000, !null)
	sep := "\n"
	if null {
		sep = "\000"
	}

	cmd := exec.Cmd{Path: bin, Args: args, Stdin: strings.NewReader(strings.Join(processed, sep))}
	cmd.Stderr = os.Stderr // let stderr pass to console
	b, err := cmd.Output()
	if err != nil {
		if err.Error() == "exit status 1" || err.Error() == "exit status 130" {
			// dmenu/rofi exits with 1 when no selection done
			// fzf exits with 1 when no match, 130 when no selection done
			return "", nil
		}
		return "", err
	}

	// we received no selection; wofi doesn't error in this case
	if len(b) == 0 {
		return "", nil
	}

	// drop newline added by proper unix tools
	if b[len(b)-1] == '\n' {
		b = b[:len(b)-1]
	}
	sel, ok := guide[string(b)]
	if !ok {
		return "", errors.New("couldn't recover original string")
	}

	return sel, nil
}

// preprocessData:
// - reverses the data
// - optionally escapes \n and \t (it would break some external selectors)
// - optionally it cuts items longer than maxChars bytes (dmenu doesn't allow more than ~1200)
// A guide is created to allow restoring the selected item.
func preprocessData(data []string, maxChars int, escape bool) ([]string, map[string]string) {
	var escaped []string
	guide := make(map[string]string)

	for i := len(data) - 1; i >= 0; i-- { // reverse slice
		original := data[i]
		repr := original

		// escape newlines
		if escape {
			repr = strings.ReplaceAll(repr, "\\n", "\\\\n") // preserve literal \n
			repr = strings.ReplaceAll(repr, "\n", "\\n")
			repr = strings.ReplaceAll(repr, "\\t", "\\\\t")
			repr = strings.ReplaceAll(repr, "\t", "\\t")
		}
		// optionally cut to maxChars
		if maxChars > 0 && len(repr) > maxChars {
			repr = repr[:maxChars]
		}

		guide[repr] = original
		escaped = append(escaped, repr)
	}

	return escaped, guide
}
