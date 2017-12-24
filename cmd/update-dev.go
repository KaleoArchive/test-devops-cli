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
	"fmt"

	"github.com/spf13/cobra"
)

// update-devCmd represents the update-dev command
var updateDevCmd = &cobra.Command{
	Use:   "dev",
	Short: "Increment the version by 'dev'",
	Run: func(cmd *cobra.Command, args []string) {
		newVersion, err := updateVersion(devVersion)
		if err != nil {
			fmt.Println(err)
		} else {
			fmt.Println(newVersion)
		}
	},
}

func init() {
	updateCmd.AddCommand(updateDevCmd)
}

func devVersion(segments []int64) string{
	segments[2] = segments[2] +1
	return segmentsToStrig(segments)
}
