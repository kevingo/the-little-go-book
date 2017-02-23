# 第五章 - 花絮

在這章，我們會介紹一些 Go 語言的花絮，這些特性主要是用在 Go 語言上。

## 錯誤處理

Go 主要是透過返回值來處理錯誤，並沒有一般語言的異常處理。讓我們來看看 `strconv.Atoi` 函式，這個函式會將字串轉整數：

```go
package main

import (
  "fmt"
  "os"
  "strconv"
)

func main() {
  if len(os.Args) != 2 {
    os.Exit(1)
  }

  n, err := strconv.Atoi(os.Args[1])
  if err != nil {
    fmt.Println("not a valid number")
  } else {
    fmt.Println(n)
  }
}
```

你可以建立自己的錯誤型別，唯一的要求就是要滿足內建的 `錯誤` 介面：

```go
type error interface {
  Error() string
}
```

一般情況下，我們可以引用內建的 `error` 套件，並使用 `new` 函式來建立自己的錯誤型別：

```go
import (
  "errors"
)


func process(count int) error {
  if count < 1 {
    return errors.New("Invalid count")
  }
  ...
  return nil
}
```

Go 的標準函式庫就是透過這種模式來來進行錯誤處理。例如，在 `io` 的函式庫中有一個 `EOF` 的變數用來定義錯誤：

```go
var EOF = errors.New("EOF")
```

這是一個屬於套件級別的變數（定義在函式外部），是可以是可以被公開存取的（變數是大寫開頭）。當我們從檔案中或標準輸入中讀取資料時，
許多的函式都可以返回這種錯誤。如果有上下文關係的話，你也應該使用這種錯誤處理。作為使用者，你可以這樣使用：

```go
package main

import (
  "fmt"
  "io"
)

func main() {
  var input int
  _, err := fmt.Scan(&input)
  if err == io.EOF {
    fmt.Println("no more input!")
  }
}
```

最後提醒一點，Go 有 `panic` 和 `recover` 函式。`panic` 類似於拋出異常，`recover` 類似於 `catch`。不過他們很少使用。

## Defer

Even though Go has a garbage collector, some resources require that we explicitly release them. 
For example, we need to `Close()` files after we're done with them. This sort of code 
is always dangerous. For one thing, as we're writing a function, 
it's easy to forget to `Close` something that we declared 10 lines up. For another, 
a function might have multiple return points. Go's solution is the `defer` keyword:

```go
package main

import (
  "fmt"
  "os"
)

func main() {
  file, err := os.Open("a_file_to_read")
  if err != nil {
    fmt.Println(err)
    return
  }
  defer file.Close()
  // read the file
}
```

If you try to run the above code, you'll probably get an error (the file doesn't exist). 
The point is to show how `defer` works. Whatever you `defer` will be executed after the 
enclosing function (in this case `main()`) returns, even if it does so violently. 
This lets you release resources near where it's initialized and takes care of multiple return points.

## go fmt

Most programs written in Go follow the same formatting rules, namely, a tab is used to 
indent and braces go on the same line as their statement.

I know, you have your own style and you want to stick to it. That's what I did for a long time, 
but I'm glad I eventually gave in. A big reason for this is the `go fmt` command. 
It's easy to use and authoritative (so no one argues over meaningless preferences).

When you're inside a project, you can apply the formatting rule to it and all sub-projects via:

```
go fmt ./...
```

Give it a try. It does more than indent your code; it also aligns field declarations and alphabetically 
orders imports.

## Initialized If

Go supports a slightly modified if-statement, one where a value can be initiated 
prior to the condition being evaluated:

```go
if x := 10; count > x {
  ...
}
```

That's a pretty silly example. More realistically, you might do something like:

```go
if err := process(); err != nil {
  return err
}
```

Interestingly, while the values aren't available outside the if-statement, 
they are available inside any `else if` or `else`.

## Empty Interface and Conversions

In most object-oriented languages, a built-in base class, often named `object`, 
is the superclass for all other classes. Go, having no inheritance, 
doesn't have such a superclass. What it does have is an empty interface with no methods: `interface{}`. 
Since every type implements all 0 of the empty interface's methods, 
and since interfaces are implicitly implemented, every type fulfills the contract of the empty interface.

 If we wanted to, we could write an `add` function with the following signature:

```go
func add(a interface{}, b interface{}) interface{} {
  ...
}
```

To convert an interface variable to an explicit type, you use `.(TYPE)`:

```go
return a.(int) + b.(int)
```

Note that if the underlying type is not `int`, the above will result in an error.

You also have access to a powerful type switch:

```go
switch a.(type) {
  case int:
    fmt.Printf("a is now an int and equals %d\n", a)
  case bool, string:
    // ...
  default:
    // ...
}
```

You'll see and probably use the empty interface more than you might first expect. 
Admittedly, it won't result in clean code. Converting values back and forth is ugly and dangerous 
but sometimes, in a static language, it's the only choice.

## Strings and Byte Arrays

Strings and byte arrays are closely related. We can easily convert one to the other:

```go
stra := "the spice must flow"
byts := []byte(stra)
strb := string(byts)
```

In fact, this way of converting is common across various types as well. 
Some functions explicitly expect an `int32` or an `int64` or their unsigned counterparts. 
You might find yourself having to do things like:

```go
int64(count)
```

Still, when it comes to bytes and strings, it's probably something you'll end up doing often. 
Do note that when you use `[]byte(X)` or `string(X)`, you're creating a copy of the data. 
This is necessary because strings are immutable.

Strings are made of `runes` which are unicode code points. If you take the length of a string, 
you might not get what you expect. The following prints 3:

    fmt.Println(len("椒"))

If you iterate over a string using `range`, you'll get runes, not bytes. Of course, 
when you turn a string into a `[]byte` you'll get the correct data.

## Function Type

Functions are first-class types:

```go
type Add func(a int, b int) int
```

which can then be used anywhere -- as a field type, as a parameter, as a return value.

```go
package main

import (
  "fmt"
)

type Add func(a int, b int) int

func main() {
  fmt.Println(process(func(a int, b int) int{
      return a + b
  }))
}

func process(adder Add) int {
  return adder(1, 2)
}
```

Using functions like this can help decouple code from specific implementations much like we achieve 
with interfaces.

## Before You Continue

We looked at various aspects of programming with Go. Most notably, we saw how error handling 
behaves and how to release resources such as connections and open files. Many people dislike 
Go's approach to error handling. It can feel like a step backwards. Sometimes, I agree. Yet, 
I also find that it results in code that's easier to follow. `defer` is an unusual 
but practical approach to resource management. In fact, it isn't tied to resource management only. 
You can use `defer` for any purpose, such as logging when a function exits.

Certainly, we haven't looked at all of the tidbits Go has to offer. But you should be feeling 
comfortable enough to tackle whatever you come across.