# 第六章 - 並行

Go 經常被描述為適合用在並行化處理的程式語言。主要的原因在於，Go 在
並行化上提供了兩種簡單且強大的機制：goroutine 和 channel。

## Goroutines

goroutine 有點類似於執行緒，但它是由 Go 自己來調度安排的，而不是由作業系統。
當你的程式碼在一個 goroutine 中執行時，他可以和其他的程式碼並行執行。讓我們來看個例子：

```go
package main

import (
  "fmt"
  "time"
)

func main() {
  fmt.Println("start")
  go process()
  time.Sleep(time.Millisecond * 10) // this is bad, don't do this!
  fmt.Println("done")
}

func process() {
  fmt.Println("processing")
}
```

上面的程式碼有幾個有趣的點，但最重要的是我們要了解怎麼啟動一個 goroutine。我們只要將
`go` 關鍵字放在我們想要執行的函式前面即可。如果我們想要執行一小段程式碼，那我們可以使用匿名函式。
要注意的是，匿名函式不僅僅在 goroutine 中可以使用，其他地方也是可以的。

```go
go func() {
  fmt.Println("processing")
}()
```

Goroutine 很容易建立而且開銷很小，最終多個 goroutine 會執行在同一個作業系統多個執行緒上。
這也常被稱為 M:N 執行緒模型。因為我們有 M 個應用程式 goroutine，執行在 N 個作業系統的執行緒。
結果就是，一個 goroutine 的開銷比起執行緒來說低很多（也許只有幾 KB），在現代的硬體上，
甚至有可能同時執行幾百萬個 goroutine。

此外，這裡還隱藏了映射和調度的複雜性。我們僅需要說 *這段代碼要並行執行*，然後 Go 就會讓這件事情發生了。

回到我們剛剛的例子，你會發現我們使用 `Sleep` 函式讓程式暫停幾毫秒，原因是因為我們必須要讓
goroutine 在主程式執行完結束前被執行（主程式不會等到所有 goroutine 執行完才結束）。為了解決這個問題，我們必須要讓程式碼互相協調一下。

## 同步

建立一個 goroutine 沒有太困難，而且開銷是很小，所以我們可以很容易地建立很多 goroutine。
但問題是，並行化的程式碼需要互相溝通。為了解決這個需求，Go 提供了 `channels` 的機制。
在我們學習 `channels` 之前，我們必須要先學習並行化程式的基本概念。

撰寫並行化程式碼，你需要特別注意在哪裡，以及如何讀取一個值。某些面向來說，他很像你在撰寫一個沒有垃圾回收機制的程式語言。
它需要你用不同的角度重新思考資料，永遠要考慮可能的危險性。看看以下的程式碼：


```go
package main

import (
  "fmt"
  "time"
)

var counter = 0

func main() {
  for i := 0; i < 20; i++ {
    go incr()
  }
  time.Sleep(time.Millisecond * 10)
}

func incr() {
  counter++
  fmt.Println(counter)
}
```

你覺得輸出會是什麼？
如果你認為輸入會是 `1, 2, ... 20`，那我不能說你對也不能說你錯。當你執行上面的程式碼，
的確你有時候會得到這樣的結果。然而，事實上這個結果是不確定的，為什麼？因為我們有多個（在這個例子是兩個) goroutine
同時存取單一個變數 `counter`。或更糟糕的狀況是其中一個 goroutine 正在讀取這個變數，而另一個正在寫入。

這樣真的危險嗎？的確是的。`counter++` 看起來只是一行簡單的程式碼，但它實際上被拆解成數行的組合語言，
實際的狀況會取決於你執行該程式碼的軟硬體平台。如果你執行這個範例，很有可能的情況是數字印出的順序是不固定的。
或有可能某些數字重複或遺失。最壞的結果也有可能造成程式錯誤或是得到任意的值。

在並行化的程式中，唯一安全的方式是讀取該變數。你可以有很多程式去讀一個變數，但寫入變數必須是同步的。
這有幾中方法可以實現，包括使用依賴於 CPU 架構的原子化操作。然而，大多數的形況是使用一個互斥鎖：

```go
package main

import (
  "fmt"
  "time"
  "sync"
)

var (
  counter = 0
  lock sync.Mutex
)

func main() {
  for i := 0; i < 20; i++ {
    go incr()
  }
  time.Sleep(time.Millisecond * 10)
}

func incr() {
  lock.Lock()
  defer lock.Unlock()
  counter++
  fmt.Println(counter)
}
```

互斥鎖可以讓你循序的存取程式碼。因為預設的 `sync.Mutex` 是沒有鎖定的，所以我們簡單的定義了一個 `lock sync.Mutex`。

看起來似乎很簡單？其實上面的例子有一點欺騙的意味。首先，哪一些程式碼需要被保護其實並不是很明顯的。
雖然他可以用一個低等的鎖（這個鎖包含了許多的程式碼），這些潛在容易出錯的部分是我們在撰寫並行化程式碼首先要考慮的。
我們通常想要一個很精確的鎖，不然我們經常會發現本來是開在一個十線道的，突然轉往一個單線道一樣。

另外一個問題是死鎖問題。當我們使用一個鎖的時候，沒有問題。但如果你使用兩個或兩個以上的鎖，
很容易發生一種問題是，當 groutineA 有鎖A，但他想要存取鎖B，而 goroutineB 擁有鎖B，但它想要存取鎖A。

事實上當我們使用一個鎖的時候，如果忘了釋放它，也可能發生死鎖問題。但這和多個鎖引起的死鎖問題相比，
並不嚴重（事實上這也很難發現）。你可以試著執行下面的程式碼：

```go
package main

import (
  "time"
  "sync"
)

var (
  lock sync.Mutex
)

func main() {
  go func() { lock.Lock() }()
  time.Sleep(time.Millisecond * 10)
  lock.Lock()
}
```

我們到目前為止還有很多並行程式沒有看過。首先，有一個常見的鎖叫做讀寫鎖。這個鎖提供兩個功能：一個鎖定讀、另一個鎖定寫。
這個功能讓你可以同時有多個讀寫操作。在 Go 中，`sync.RWMutex` 就是這樣的功用。另外，`sync.Mutex` 除了提供 `Lock` 和 `Unlock` 外，
它也提供了 `RLock` 和 `RUnlock`，這個 `R` 代表了*讀取*。雖然讀寫鎖很常用，但他們也會給開發者帶來額外的負擔：我們不僅要注意我們正在存取的資料，
也要注意是如何存取的。

此外，部分的並行化程式不僅僅是循序的存取變數，也需要安排多個 goroutine。例如，等待 10 毫秒並不是一個優雅的解決方法，如果一個 goroutine 需要超過 10 毫秒呢？如果執行時間少於 10 毫秒，我們只是浪費時間呢？
又或者當一個 goroutine 執行完畢後，我們要告訴另外一個 goroutine 有新的資料要給處理？

所有的這些事在沒有 `channel` 的情況都可以實現， 當然對於更簡單的例子來說，我相信你應該使用 `sync.Mutex` 和 `sync.RWMutex`。
但在下一章節中，我們將會學習到 `channel` 的主要目的是為了讓並行程式碼在撰寫時更簡單且更不容易出錯。

## Channels

撰寫並行化程式最主要的挑戰在於資料共享，如果你的 Go 程式沒有要共享資料，那就不需要擔心同步的問題。
但是，對與所有其他的系統而言，這並不是不需要擔心的。事實上，許多系統反而朝向反方向設計：在多個請求之間分享資料。
所有的記憶體快取或資料庫設計都是最好的例子。這已經變成越來越流行的現實了。

Channel 讓並行化程式設計在共享數據上更有道理。一個 Channel 就是不同的 goroutine 之間用來傳遞數據溝通的管道。
換句話說，一個 goroutine 可以藉由 Channel 來傳遞資料到另外一個 goroutine。其結果就是，在同一時間內，只有一個 goroutine 會存取到資料。

Channel 一樣有型別。它的型別就是我們要在不同 goroutine 之間傳遞資料的型別。例如，我們可以建立一個用來傳遞整數的 Channel：

```go
c := make(chan int)
```

這種型別的 channel 就是 `chan int`。因此，為了要透過函式傳遞這樣的 channel，他的參數會是：

```go
func worker(c chan int) { ... }
```

Channel 支持兩種操作：接收和傳送。我們可以這樣傳送資料到一個 channel：

```
CHANNEL <- DATA
```

或是從 channel 接收資料：

```
VAR := <-CHANNEL
```

箭頭代表了資料傳遞的方向。當傳送資料時，箭頭是指向 channel 的。當接收資料時，箭頭是從 channel 指出去的。

在我們學習第一個例子之前，我們要知道最後一件事，從 channel 接收或傳送出去是互相阻塞的。也就是說，當我們從一個 channel 接收資料時，
goroutine 會等到資料接收完畢後才會繼續執行。同樣的，當我們傳送資料到一個 channel 時，在資料被接收之前，goroutine 也不會繼續執行。

考量到一個系統會需要在不同的 goroutine 來處理接收到的資料，這是一個相當常見的需求。如果我們在 goroutine 針對接收到的資料進行複雜的處理，
那客戶端很有可能會超時。首先，我們撰寫我們的 worker，這是一個簡單的函式，但我們會把它變成結構的一部份，因為我們之前還沒有這樣使用過 goroutine：

```go
type Worker struct {
  id int
}

func (w Worker) process(c chan int) {
  for {
    data := <-c
    fmt.Printf("worker %d got %d\n", w.id, data)
  }
}
```

我們的 worker 很簡單，他等到所有的資料都接收到了之後才處理他們。這個 Worker 盡責的在一個無窮迴圈中不斷的等待更多資料，然後處理他們。

為了要使用它，第一件事就是要啟動一些 workers：

```go
c := make(chan int)
for i := 0; i < 5; i++ {
  worker := &Worker{id: i}
  go worker.process(c)
}
```

接著我們可以指派給他一些工作：

```go
for {
  c <- rand.Int()
  time.Sleep(time.Millisecond * 50)
}
```

下面是完整的範例：

```go
package main

import (
  "fmt"
  "time"
  "math/rand"
)

func main() {
  c := make(chan int)
  for i := 0; i < 5; i++ {
    worker := &Worker{id: i}
    go worker.process(c)
  }

  for {
    c <- rand.Int()
    time.Sleep(time.Millisecond * 50)
  }
}

type Worker struct {
  id int
}

func (w *Worker) process(c chan int) {
  for {
    data := <-c
    fmt.Printf("worker %d got %d\n", w.id, data)
  }
}
```

我們並不知道哪一個 worker 會收到資料。我們知道的是，Go 會確保我們送給 channel 的資料只會有一個接收者接收。

要特別注意的是，channel 是唯一安全用來接收和傳送共享資料的方式。Channel 提供了所有我們在同步程式碼所需的功能。
並且確保在同一時間只會有一個 goroutine 可以存取特定的資料。

### 具有暫存能力的 Channels

在上面的程式中，如果資料超過我們可以處理的容量會怎樣呢？你可以嘗試模擬這種狀況，在 worker 接收到資料後，接收到資料後，讓 worker 執行 sleep 函式：

```go
for {
  data := <-c
  fmt.Printf("worker %d got %d\n", w.id, data)
  time.Sleep(time.Millisecond * 500)
}
```

在 main 程式終會發生什麼事？接收使用者輸入的資料（在這裡是我們你的隨機亂數產生器）會被阻塞，因為往 channel 發送資料時並沒有接收者。

為了確保資料能夠被處理，你可能想要讓客戶端被堵塞住。在一些其他的情況下，你也許不願意確保資料能夠被處理。這裡有一些常見的策略來解決這個問題，
首先是將資料暫存起來，如果沒有 worker 可用，我們可以將資料先存在一個有序的佇列中。Channel 擁有這種內建的暫存能力，
當我們使用 `make` 建立 channel 時，可以給定它的長度：

```go
c := make(chan int, 100)
```

你可以這樣調整，但你會發現這個過程還是蠻不穩定的。作為暫存的 channel 不能增加更多的容量，它只是提供一個佇列來處理這種突然劇增的資料。
在我們的例子中，我們可以不斷地發送資料，而且 worker 也可以處理這些資料。雖然如此，我們可以透過 channel 的 `len` 函式來了解具有暫存功能的 channel 實際的作用：

```go
for {
  c <- rand.Int()
  fmt.Println(len(c))
  time.Sleep(time.Millisecond * 50)
}
```

你會看到具有暫存的 channel 的長度不斷增加，直到資料裝滿為止。此時，往 channel 發送的資料又會被阻塞。

### Select

即使有了暫存機制，我們還是需要開始丟棄掉一些資料。我們不可能使用一個無限大的記憶體，並指望透過人工的方式來釋放。
因此，我們要使用 Go 的 `select`。

語法上，`select` 類似於 switch，透過 `select`，我們可以撰寫一些在 channel 下無法實現的程式碼。首先，讓我們移除我們 channel 的暫存，
讓我們可以更清楚地看到 `select` 是如何運作的：

```go
c := make(chan int)
```

接下來，我們修改 `for` 迴圈：

```go
for {
  select {
  case c <- rand.Int():
    //以下是可選的部分
  default:
    //這裡可以留空，用來丟掉資料
    fmt.Println("dropped")
  }
  time.Sleep(time.Millisecond * 50)
}
```

我們每秒往 channel 送 20 個訊息，但我們的 worker 每秒只能處理 10 個訊息。因此，會有一半的訊息被丟棄。

這僅僅是我們使用 `select` 來完成的第一件事情。使用 `select` 的最主要目的是讓你可以管理多個 channel。
當你有多個 channel 時，`select` 會阻擋資料，直到有一個可用的 channel。如果沒有可用的 channel 時，如果你有提供 `default` 敘述，就會跑到該地方執行。
當有多個 channel 都可用時，`select` 會隨機選擇一個 channel。

這是一個比較高級的特性，很難想出一個簡單的範例來證明這個行為。我們在下一節當中來說明這個部分。

### 逾時

我們已經看過暫存的訊息，同時也學到如何簡單的丟棄他們。另外一個比較常見的做法是使用逾時機制。我們會阻塞一段時間，
但不是永遠阻塞。這在 Go 當中也是很容易做到的。老實說，我認爲這個語法有點難以接受，但他是比較靈活和有用的方法，基本上我不能不使用它。

為了達到阻塞的最大值，我們可以使用 `time.After` 這個函式。讓我們來看看會發生什麼神奇的事情。我們修改一下發送部分的程式碼：
```go
for {
  select {
  case c <- rand.Int():
  case <-time.After(time.Millisecond * 100):
    fmt.Println("timed out")
  }
  time.Sleep(time.Millisecond * 50)
}
```

`time.After` 會回傳一個 channel，所以我們可以對它使用 `select` 語法。
這個 channel 在指定的時間後會被寫入，就這樣。沒有什麼比這個更神奇的了。如果你仍然覺得困惑，這裡實作了一個 `after`：


```go
func after(d time.Duration) chan bool {
  c := make(chan bool)
  go func() {
    time.Sleep(d)
    c <- true
  }()
  return c
}
```

回來看我們的 `select` 語法，這裡有幾個有趣的地方。首先，如果你在 `select` 後面增加 `default` 會發生什麼事情？
你能猜猜看嗎？試試看，如果你不確定會發生什麼事情。記住，如果 channel 無法使用的時候，`default` 的部分會被執行。

此外，`time.After` 的類型是 `chan time.Time`。在上面的例子中，我們只是簡單的把傳給 channel 的值給丟掉。
如果你想要的話，也可以嘗試接收它們：

```go
case t := <-time.After(time.Millisecond * 100):
  fmt.Println("timed out at", t)
```

注意我們的 `select` 語法，注意我們是往 `c` 發送資料，但是是從 `time.After` 拿資料。不管我們是從 channel 中接收資料、發送資料，`select` 的機制都一樣：

* 第一個可用的 channel 會被選擇。
* 如果有多個 channel 可用，會隨機挑選一個。
* 如果沒有 channel 可用，`default` 的部分會被執行。
* 如果沒有 `default`，`select` 會阻塞。

最後，在 `for` 迴圈中使用 `select` 是常見的：

```go
for {
  select {
  case data := <-c:
    fmt.Printf("worker %d got %d\n", w.id, data)
  case <-time.After(time.Millisecond * 10):
    fmt.Println("Break time")
    time.Sleep(time.Second)
  }
}
```

## 在你繼續學習之前

如果你才剛剛進入並行程式語言的世界，你可能會覺得它是銳不可擋的。的確，他需要你更多的關注，畢竟 Go 語言的目標就是為了讓並行程式更容易撰寫。

Goroutine 有效的抽象化了並行的程式碼。Channel 幫助我們在資料需要共享時所會產生的一些嚴重的 bug。其實不僅僅是消除 bug，他還改變了我們如何撰寫我們的並行程式碼。
你可以開始思考怎麼透過訊息的傳遞來撰寫並行程式，而不是透過那些容易出錯的程式碼。

雖然如此，我依舊廣泛地使用 `sync` 和 `sync/atomic` 套件中的同步機制。我認為去熟悉他們是很重要的。
我鼓勵你在學習時，可以先關注 `channel`，但當你需要一些短暫的鎖的範例時，也可以考慮使用 mutex 或讀寫 mutex。