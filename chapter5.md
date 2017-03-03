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

Go 的標準函式庫就是透過這種模式來進行錯誤處理。例如，在 `io` 的函式庫中有一個 `EOF` 的變數用來定義錯誤(譯注：原始碼可參考：[https://github.com/golang/go/blob/master/src/io/io.go#L38](https://github.com/golang/go/blob/master/src/io/io.go#L38))：

```go
var EOF = errors.New("EOF")
```

這是一個屬於套件級別的變數（定義在函式外部），是可以是可以被公開存取的（變數是大寫開頭）。當我們從檔案中或標準輸入中讀取資料時，許多的函式都可以返回這種錯誤。如果有上下文關係的話，你也應該使用這種錯誤處理。作為使用者，你可以這樣使用：

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

最後提醒一點，Go 有 `panic` 和 `recover` 函式。`panic` 類似於拋出異常，`recover` 類似於 `catch`。不過它們很少使用。

## Defer

儘管 Go 語言提供了垃圾回收的機制，還是有一些資源需要開發者明確的去釋放。比如說，在處理文件結束時，我們需要呼叫 `Close()` 來關閉 io。這種類型的程式碼總是比較危險的，首先，當我們寫了一個函式，很容易忘記去呼叫 `Close` 函式來關閉我們在第十行開啟的檔案。此外，一個函式可能會有多個返回點。Go 提供了 `defer` 關鍵字來處理這一類的問題：

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
  // 讀檔
}
```

如果你嘗試執行上面的程式碼，你可能會得到一個錯誤（因為檔案不存在）。這裡主要是想要讓你知道 `defer` 的用法。使用 `defer` 的操作，都會在函式返回前執行。這讓你可以在初始化或宣告某個操作的附近就預先宣告要釋放資源。

## go fmt

大多數用 Go 寫的程式碼都遵循相同的風格，那就是，使用 tab 進行縮排、括號和程式宣告在同一行等。

我知道你有自己的風格，也很想堅持下去。我曾經有一段時間也是這樣的，但很高興最後我還是屈服了。其中最大的原因就是 `go fmt` 命令工具。它很容使用也很具代表性（所以沒有人為了無意義的偏好而爭執）。

當你在專案的目錄下，你可以透過下面的命令行工具將所有子專案進行程式碼格式編排：

```sh
go fmt ./...
```

試試看吧，這個命令行工具會幫你的程式碼縮排，也會自動地幫你對齊，並且將引用的函式庫按照字母順序排列

## 具有初始化功能的 if

Go 支援一種稍微不一樣的 if 敘述，一個變數可以在 if 條件執行前宣告並且初始化：

```go
if x := 10; count > x {
  ...
}
```

這是一個有點愚蠢的例子，比較實際的範例如下：

```go
if err := process(); err != nil {
  return err
}
```

有趣的是，透過 if 初始化的值在 if 的範圍以外是不能被存取的，但是在 `else if` 和 `else` 中可以被使用。

## 空的 Interface 和轉換

在大多數的物件導向程式語言中，都有內建的基礎類別，通常稱做 `物件`。它通常是所有類別的父類別。但在 Go 中不支援繼承，所以沒有類似這種父類別的概念。Go 裡面擁有的是一個沒有任何宣告的空介面 `interface{}`。由於每個型別都實作了空介面的 0 個方法，而且每個介面都是隱性實作，所以每種類型都實現了空介面的契約。

如果我們想要，可以寫一個 `add` 函式：

```go
func add(a interface{}, b interface{}) interface{} {
  ...
}
```

將一個空介面型態的變數做顯性的轉換，可以用 `.(TYPE)`：

```go
return a.(int) + b.(int)
```

要注意的是，如果欲轉換的變數並不是 `int` 型態，上面的程式碼將會出錯。

你也可以強大的 type switch 進行轉換：

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

你會發現空介面的使用超出你的預期。不可否認的，這會讓你的程式碼看起來不夠乾淨。某些時候不斷轉換一個值是醜陋的且危險的，但在靜態語言中，這是唯一的選擇。

## 字串和位元組陣列

字串和位元組陣列有密切的關係，我們可以很容易轉換他們：

```go
stra := "the spice must flow"
byts := []byte(stra)
strb := string(byts)
```

事實上，這也是大多數型態的轉換方式。某些函式會明確指定 `int32` 或 `int64`，或其他無號的部分。你可能會發現自己必須這樣寫：

```go
int64(count)
```

儘管如此，當提到位元組和字串時，這會是你經常接觸到的東西。要記住，當你使用 `[]byte(x)` 或 `string(x)` 時，你是建立資料的拷貝，這是因為字串是不可變的。字串是由 `runes` 組成，`runes` 是一個 unicode 字符。當你用 `len` 函式來取得字串的長度時，往往結果不如你預期。以下的範例將會印出 3：

```go
fmt.Println(len("椒"))
```

如果你嘗試透過 `range` 函式來遍歷一個字串，你是得到一個個的 runes，而不是位元組。當然，當你將一個字串轉成 `[]byte` 時，
你會得到正確的資料。

## 函式型別

函式是一級型別：

```go
type Add func(a int, b int) int
```

它可以用在任何地方 - 當作一個欄位型別、參數、回傳值。

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

透過這種使用函式的方式，我們可以從特定的實作中減少耦合，就像我們使用介面一樣。

## 在你繼續學習之前
我們已經學習了很多 Go 語言的特性，顯而易見的，我們學習了錯誤處理、當開起檔案後如何釋放資源。許多開發者不喜歡 Go 錯誤處理的方式，它讓人覺得是一種退步。某些時候我是同意的，然而，我也會發現這樣的程式碼更容易閱讀。`defer` 在資源管理上是一個不常見但實用的手段。事實上，`defer` 不僅僅可以用在資源管理上，也可以用在其他方面，比如說你可以用在函式退出時的日誌紀錄上。

當然，我們還沒有把所有 Go 的特性都介紹完，但你應該可以在遇到任何困難時都迎刃而解。
