Babble
=========

Babble is a small utility that generates random words for you. I found this useful because occasionally you need a random word for testing.

![tower of babel](http://image.shutterstock.com/display_pic_with_logo/518173/140700250/stock-photo-tower-of-babel-first-variant-raster-variant-140700250.jpg)

Usage
-----

```go
package your_app

import (
  "github.com/tjarratt/babble"
)

func main() {
  babbler := NewBabbler()
  println(babbler.Babble()) // excessive-yak-shaving (or some other phrase)

  // optionally set your own separator
  babbler.Separator = " "
  println(babbler.Babble()) // "hello from nowhere" (or some other phrase)

  // optionally set the number of words you want
  babbler.Count = 1
  println(babbler.Babble()) // antibiomicrobrial (or some other word)

  return
})
```
