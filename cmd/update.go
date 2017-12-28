// Copyright © 2017 Kaleo Cheng <kaleocheng@gmail.com>
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

package cmd

import (
	"bytes"
	"errors"
	"fmt"
	"github.com/spf13/viper"
	"strconv"
	"strings"

	"github.com/hashicorp/go-version"
	"github.com/spf13/cobra"
)

// updatenCmd represents the update-version command
var updateCmd = &cobra.Command{
	Use:   "update",
	Short: "Increment the version which in the site config file",
}

func init() {
	RootCmd.AddCommand(updateCmd)
}

func getSegments() ([]int64, error) {
	configVersion := viper.GetString("params.version")
	if configVersion == "" {
		return nil, errors.New("Can't get params.version from the config file")
	}
	v, err := version.NewVersion(configVersion)
	if err != nil {
		fmt.Println(err)
		return nil, err
	}
	vs := v.Segments64()[:3]
	return vs, nil
}

func segmentsToStrig(segments []int64) string {
	var buf bytes.Buffer
	fmtParts := make([]string, len(segments))
	for i, s := range segments {
		str := strconv.FormatInt(s, 10)
		fmtParts[i] = str
	}
	fmt.Fprintf(&buf, strings.Join(fmtParts, "."))
	return buf.String()
}

func writeVersion(newVersion string) {
	viper.Set("params.version", newVersion)
	viper.WriteConfig()
}

func updateVersion(versionFunc func([]int64) string) (string, error) {
	s, err := getSegments()
	if err != nil {
		return "", err
	}
	newVersion := versionFunc(s)
	writeVersion(newVersion)
	return newVersion, nil
}
