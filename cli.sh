#!/bin/bash
set -eu -o pipefail

post="post/$(./test-devops-clia title).md"
hugo new $post && fortune >> content/$post && hugo undraft content/$post
