# 第四章 - 組織程式碼和介面

該是時候來看看怎麼組織我們的程式碼了。

## 套件

為了學習更複雜的函式庫和組織系統，我們需要學習套件。在 Go 中，套件名稱和你的工作目錄結構有關。如果我們想要建構一個購物車系統，也許我們會用 "shopping" 作為套件名稱，並且把我們的程式碼放在 `$GOPATH/src/shopping/` 目錄下。

我們不想要把所有的東西都放在這個目錄。比如說，我們可能會想要把資料庫的邏輯放在專屬他的資料夾。為了達到這樣的目的，我們可以建立一個子資料夾 `$GOPATH/src/shopping/db`。在這個資料夾中的套件名稱可以簡單的稱作 `db`，但是如果其他的套件想要存取他時，就必須要把 `shopping` 套件名稱也寫上。

換句話說，當你需要針對套件命名時，只要使用 `package` 關鍵字，並且提供一個名稱即可，而不需要把整個階層都寫上去（例如：`shopping` 或 `db`）。但是當你要引用套件時，就需要把完整的路徑寫上。

讓我們試試看，在你的工作目錄 `src` 下，建立一個新的資料夾叫做 `shopping`，接著在下面建立一個子資料夾 `db`：

在 `shopping/db` 中，建立一個 `db.go` 的檔案，並撰寫以下程式碼：

```go
package db

type Item struct {
  Price float64
}

func LoadItem(id int) *Item {
  return &Item{
    Price: 9.001,
  }
}
```

注意這個套件的名稱跟資料夾名稱一樣。很明顯的我們並沒有實際存取資料庫，這裡只是要學習如何組織我們的程式碼而已。

接著在 `shopping` 目錄中建立一個 `pricecheck.go` 的檔案，並寫入以下程式碼：

```go
package shopping

import (
  "shopping/db"
)

func PriceCheck(itemId int) (float64, bool) {
  item := db.LoadItem(itemId)
  if item == nil {
    return 0, false
  }
  return item.Price, true
}
```

你可以會認為我們已經在 `shopping` 目錄下了，還要引用 `shopping/db` 會有點奇怪。事實上，我們是引用 `$GOPATH/src/shopping/db`，這意味著你可以很容易引用 `test/db` 這樣的套件，只要你有一個 `db` 的套件在你工作目錄下的 `src/test` 目錄中。

如果你想要建構一個套件，你只需要以上的步驟即可。如果想要建置可執行檔，你需要一個包含 `main` 的檔案。我建議的方式是在 `shopping` 目錄中建立一個子目錄 `main`，並在裡面建立一個 `main.go` 的檔案：

```go
package main

import (
  "shopping"
  "fmt"
)

func main() {
  fmt.Println(shopping.PriceCheck(4343))
}
```

現在你可以執行你的 `shopping` 專案：

```
go run main/main.go
```

### 循環引用

當你開始撰寫更複雜的系統時，你一定會遇到循環引用的問題。當 A 套件要引用 B 套件，但 B 套件又引用 A 套件時就會發生這樣的狀況(不管是直接引用或是透過其他套件間接引用)。這種情況編譯器是不會允許的。

讓我們調整我們的專案結構來模擬這樣的錯誤。

將 `Item` 的定義從 `shopping/db/db.go` 改為 `shopping/pricecheck.go`，所以你的 `pricecheck.go` 會長的像這樣：

```go
package shopping

import (
  "shopping/db"
)

type Item struct {
  Price float64
}

func PriceCheck(itemId int) (float64, bool) {
  item := db.LoadItem(itemId)
  if item == nil {
    return 0, false
  }
  return item.Price, true
}
```

如果你是著執行這段程式碼，你會從 `db/db.go` 得到一個關於 `Item` 未定義的錯誤。這是很合理的，因為 `Item` 不再存在於 `db` 套件了，他已經被移到 `shopping` 的套件中。我們需要調整 `shopping/db/db.go`：

```go
package db

import (
  "shopping"
)

func LoadItem(id int) *shopping.Item {
  return &shopping.Item{
    Price: 9.001,
  }
}
```

現在再執行一下程式碼，你會得到*循環引用*錯誤。要解決這個問題，我們必須要導入另外一個套件，所以我們現在的目錄結構長得像這樣：

```
$GOPATH/src
  - shopping
    pricecheck.go
    - db
      db.go
    - models
      item.go
    - main
      main.go
```

`pricecheck.go` 仍然會引用 `shopping/db`，但是 `db.go` 現在會引用 `shopping/models`，而不是 `shopping`。如此一來就可以解決循環引用的問題。由於我們將共用的結構 `Item` 到 `shopping/models/item.go`，我們需要變更 `shopping/db.db.go`，讓他可以從 `models` 套件中引用 `Item` 結構。

```go
package db

import (
  "shopping/models"
)

func LoadItem(id int) *models.Item {
  return &models.Item{
    Price: 9.001,
  }
}
```

你經常會共享的套件不僅僅是 `models`，可能還會有其他類似 `utilities` 這樣的套件。關於這一類共享套件的重要規則就是，他不應該從 `shopping` 套件或其他任何的子套件中引用任何東西。在一些小節中，我們會看到使用介面將會幫助我們解決這些相依關係。

### 可視性

Go 使用一個簡單的規則來定義每個型態和函式是否可被外部的套件呼叫。如果你宣告的類型或函式時以大寫字母開頭，那這個函式或型態就是可見的。如果是以小寫開頭，那就是不可見的。

這樣的規則也適用於結構，如果一個結構中的欄位是小寫字母開頭，那只有在同一個套件中的程式碼才能夠存取這些欄位。例如，我們在 `items.go` 中有一個函式長這樣：

```go
func NewItem() *Item {
  // ...
}
```

我們可以透過 `models.NewItem()` 呼叫這個函式，但如果這個函式命名為 `newItem`，那我們從其他的套件就無法呼叫這個函式。
你可以繼續修改 `shopping` 套件中的型態或欄位，例如，如果你將 `Item` 結構中的 `Price` 欄位改成 `price`，會得到錯誤訊息。

### 套件管理

我們已經學習過 go 的命令列工具，例如 `go run` 和 `go build`，還有一個 `get` 的子命令可以用來下載第三方函式庫。`go get` 支援不同的通訊協定，但在我們這個例子中，我們會嘗試透過這個命令從 Github 上下載一個函式庫，這意味著你必須在你的電腦上安裝 `git`。假設你已經安裝 `git` 了，在你的命令列上輸入：

```sh
go get github.com/mattn/go-sqlite3
```

`go get` 會從遠端下載檔案並且儲存到你的工作目錄。查看你的 `$GOPATH/src`。除了我們已經建立的 `shopping` 專案外，你還會看到 `github.com` 資料夾。在這個資料夾中，你還會看見一個 `mattn` 資料夾，裡面包含了 `go-sqlite3` 的資料夾。

我們已經學習過如何引用一個套件在我們的工作目錄中，現在我們有一個全新的 `go-sqlite3` 套件，你可以透過以下方式引用：

```go
import (
  "github.com/mattn/go-sqlite3"
)
```

我知道這看起來很像一個網址，但事實上，他代表引用 `go-sqlite3` 套件，而這個套件就位在你電腦中的 `$GOPATH/src/github.com/mattn/go-sqlite3` 目錄下。

### 相依管理

`go get` 有一些其他有趣的地方。如果你在一個專案中執行 `go get`，他會幫你掃描所有的檔案，尋找 `import` 所引用的第三方套件，並且嘗試下載它。
某方面來說，我們自己的程式碼變成一個 `Gemfile` 或 `package.json` 檔案。（譯注：`Gemfile` 是 Ruby 用來管理第三方套件的檔案、`package.json` 是 Nodejs 用來管理第三方套件的檔案）

如果你使用 `go get -u`，他會更新所有的套件（或是你也可以透過 `go get -u FULL_PACKAGE_NAME` 更新特定的套件）。

最後，你可能會發現 `go get` 的一些不足的地方。首先，他無法指定一個特定版本，他總會指向 `master/head/trunk/default`，這是一個嚴重的問題，尤其是你有兩個專案引用到同一個套件，但又需要該套件的不同版本。

為了解決這個問題，你可以使用一些第三方相依管理的工具。雖然這些工具還不太成熟，但有兩個相依管理的工具比較有未來性，那就是 [goop](https://github.com/nitrous-io/goop) 和 [godep](https://github.com/tools/godep)。

更完整的列表可以參考 [go-wiki](https://github.com/golang/go/wiki/PackageManagementTools)。

## 介面

介面是一種型態，他定義了宣告但沒有實作。底下是一個範例：

```go
type Logger interface {
  Log(message string)
}
```

你可能會覺得這樣有什麼用處？介面可以讓你的程式碼從實作中去耦合。例如，你可能會有很多種不同的 loggers：

```go
type SqlLogger struct { ... }
type ConsoleLogger struct { ... }
type FileLogger struct { ... }
```

如果你在實作的時候使用介面，而不是具體的實作時，你可以很容易的改變和測試我們的程式碼。要怎麼使用？就像其他的類型一樣，你可以把介面作為結構的一個欄位宣告：

```go
type Server struct {
  logger Logger
}
```

或是一個韓式的參數（或是回傳值）：

```go
func process(logger Logger) {
  logger.Log("hello!")
}
```

在 C# 或 Java 中，當一個類別實作一個介面時，並需要明確的定義：

```go
public class ConsoleLogger : Logger {
  public void Logger(message string) {
    Console.WriteLine(message)
  }
}
```

在 Go 中，這樣的行為是隱性的。如果你的結構有一個函式 `Log`，參數是 `string`，並且沒有回傳值，那這就可以當作是一個 `Logger`。這讓介面的使用上少了點冗餘性。

```go
type ConsoleLogger struct {}
func (l ConsoleLogger) Log(message string) {
  fmt.Println(message)
}
```

這也促成了介面具有小巧和集中的特性。Go 語言的標準函式庫中充滿著介面。尤其是在 `io` 的函式庫中有許多熱門的介面，比如說 `io.Reader`、`io.Writer` 和 `io.Closer`。
如果你撰寫一個函式，函式的參數會呼叫 `Close`，你就可以傳遞一個 `io.Closer` 的介面而不用管你使用的具體型別是什麼。

介面也可以組合，也就是說介面可以由其他的介面組成。例如 `io.ReadCloser` 就是由 `io.Reader` 介面和 `io.Closer` 介面組成。

最後，介面經常會避免循環引用。因為介面沒有具體的實作內容，所以他們的相依性是有限的。

## 在你繼續學習之前

當你開始用 Go 來撰寫一些專案時，你會習慣在 Go 工作目錄中組織程式碼的方式。最重要的事你要記住套件名稱和目錄結構有密切的關連（不只在一個專案中如此，在整個工作目錄都是這樣）。Go 語言處理可見性的方式是簡單、高效率且具有一致性的。還有一些內容我們沒有介紹到，比如說常數和全域變數，但別擔心，他們的可見性也是遵守一樣的規則。

最後，如果你不熟悉 Go 的介面，可能會需要花一點時間來學習他。然而，當你第一次看到一個類似 `io.Reader` 的函式時，你會感激作者不會要求超過他所需要的部分的。
