# Chapter 3 - Map、Array、和 Slice

到目前為止我們看過了一些簡單的型別和結構。現在該是時候來看看 array、slice 和 map 了。

## 陣列

如果你來自 Python、Ruby、Perl、JavaScript 或 PHP（或更多其他語言），你可能在寫程式時習慣使用*動態陣列*。這些陣列是在資料加入到陣列時自行調整大小的陣列。在 Go 中，像許多其他語言一樣，陣列是固定的。宣告陣列需要我們指定大小，一旦指定大小，它就不能增加：

```go
var scores [10]int
scores[0] = 339
```

上面這個陣列宣告可以透過 `scores[0]` 到 `scores[9]` 來存取 10 個分數值。如果嘗試存取超過這個範圍的陣列元素，編譯器會拋出執行時期錯誤。

我們也可以在初始化陣列的時候賦值：

```go
scores := [4]int{9001, 9333, 212, 33}
```

我們可以用 `len` 函式來取得陣列的長度。而 `range` 函式可以用來循序的存取每個元素值：

```go
for index, value := range scores {

}
```

使用陣列是有效率但不夠靈活，原因是因為通常我們不知道即將要處理元素的數量。讓我們來看看 slice。

## Slice

在 Go 中，你很少會直接使用陣列，通常情況下你會使用 slice。slice 是一個輕量級的結構，這個結構被封裝後，代表了一個陣列的一部份。這裡我們列出一些建立 slice 的方法，並且指出我們會在後面什麼時候會用到他們。

第一種方式和我們建立陣列時有點相像：

```go
scores := []int{1,4,293,4,9}
```

不同於陣列的宣告，slice 在宣告時不需要宣告長度。為了理解兩者的差異，我們來看看另外一種使用 `make` 建立 slice 的方式：

```go
scores := make([]int, 10)
```

我們使用 `make` 而沒有使用 `new` 是因為建立一個 slice 不僅僅是分配一個記憶體區間而已（`new` 的作用就是分配一段記憶體區間）。明確的來說，我們幫底層的陣列建立了一段記憶體區間，同時也要初始化 slice。在上面的例子中，我們初始化一個 slice，長度和容量都是 10。長度代表 slice 的大小，而容量是底層陣列的大小。透過 `make` 函式，我們可以同時宣告長度和容量。

```go
scores := make([]int, 0, 10)
```

這會建立一個長度是 0 ，容量是 10 的 slice。（如果你有留意的話，會發現 `make` 和 `len` 同時實現了 *重載* 的功能。Go 語言的某些特性會讓你感到有點失望，因為某些部分他並沒有揭露給開發者使用。）

為了更好理解關於長度和容量之間的交互關係，讓我們來看一些例子：

```go
func main() {
  scores := make([]int, 0, 10)
  scores[7] = 9033
  fmt.Println(scores)
}
```

上面的第一個例子是無法運作的，為什麼？因為我們的 slice 長度是 0。是的，底層的陣列有 10 個元素，
但如果想要存取元素時，我們必須明確的擴展 slice。其中一個擴展 slice 的方式是使用 `append`：

```go
func main() {
  scores := make([]int, 0, 10)
  scores = append(scores, 5)
  fmt.Println(scores) // 列印 [5]
}
```

但這改變了我們原本程式碼的意圖，在長度為 0 的 slice 上增加一個元素會被放到 slice 的第一個元素。不管出自什麼原因，那段不能運作的程式碼會賦值給 slice 的第 8 個元素。為了達成這個目標，我們可以再切割 slice：

```go
func main() {
  scores := make([]int, 0, 10)
  scores = scores[0:8]
  scores[7] = 9033
  fmt.Println(scores)
}
```

可以調整 slice 長度的上限是多少？這個上限就是根據 slice 的容量來決定，在上面的例子中，就是 10。你可能會認為這沒有解決 *固定長度陣列* 的問題。其實 `append` 是比較特別的，如果底層的陣列已經滿了，`append` 會創造一個更大的陣列，並且複製所有的值到新的陣列（這也是動態陣列的工作原理，像是：PHP、Python、Ruby、Javascript等）。這就是為什麼我們在上面的例子中使用 `append`，我們必須要將 `append` 得回傳值重新指派給 scores 變數，如果原始的 slice 沒有更多容量時，`append` 會建立一個新的。

如果我告訴你 Go 在擴展陣列時使用的是 2x 演算法，你可以猜到以下的程式碼的輸出是什麼嗎？

```go
func main() {
  scores := make([]int, 0, 5)
  c := cap(scores)
  fmt.Println(c)

  for i := 0; i < 25; i++ {
    scores = append(scores, i)

    // 如果容量改變了，
    // Go 為了容納新的資料，會增加陣列的長度
    if cap(scores) != c {
      c = cap(scores)
      fmt.Println(c)
    }
  }
}
```

如果初始 `scores` 的容量是 5，為了要容納 20 個元素，slice 的容量必須要擴展 3 次，分別是10、20 和 40。

最後一個範例：

```go
func main() {
  scores := make([]int, 5)
  scores = append(scores, 9332)
  fmt.Println(scores)
}
```

上面的程式碼輸出會是 `[0, 0, 0, 0, 0, 9332]`。從直觀來看，你可能會以為輸出是 `[9332, 0, 0, 0, 0]`？對編譯器而言，上面的程式碼代表的意思是，附加 9332 到已經有五個值的 slice 。

最後，這裡提供四種常見初始化 slice 的方式：

```go
names := []string{"leto", "jessica", "paul"}
checks := make([]bool, 10)
var names []string
scores := make([]int, 0, 20)
```

你該使用哪一種方式？

第一種方式相當直觀，不需要太多的說明，但缺點是你必須先知道要往 slice 裡面放的元素是什麼。第二種方式在你想要往 slice 的特定位置寫入一個值的時候很有用，比如說：

```go
func extractPowers(saiyans []*Saiyans) []int {
  powers := make([]int, len(saiyans))
  for index, saiyan := range saiyans {
    powers[index] = saiyan.Power
  }
  return powers
}
```

第三個方式會回傳一個空的 slice，一般會和 `append` 一起使用。此時 slice 的數量是未知的。

最後一種方式讓我們指定 slice 的長度和容量。當我們大概知道需要多少元素時很有用。即使你知道元素的個數，`append` 也可以被使用。這取決於個人喜好：

```go
func extractPowers(saiyans []*Saiyans) []int {
  powers := make([]int, 0, len(saiyans))
  for _, saiyan := range saiyans {
    powers = append(powers, saiyan.Power)
  }
  return powers
}
```

slice 作為一個陣列的封裝來說是很有用的。許多語言都有類似的概念。Javascript 和 Ruby 中都有一個 `slice` 方法。在 Ruby 中，你可以透過 `[START..END]` 來得到一個 slice，或是在 Python 中使用 `[START:END]` 來得到一個 slice。然而，在某些語言中，slice 的確是從原始陣列複製而來。如果我們使用 Ruby，下面的程式碼會輸出什麼？

```go
scores = [1,2,3,4,5]
slice = scores[2..4]
slice[0] = 999
puts scores
```

答案是 `[1, 2, 3, 4, 5]`。因為 `slice` 是把舊的值全部複製過來的一個新陣列。現在，同樣情況下來看看 Go 會怎麼做：

```go
scores := []int{1,2,3,4,5}
slice := scores[2:4]
slice[0] = 999
fmt.Println(scores)
```

輸出會是 `[1, 2, 999, 4, 5]`。

這種行為會如何改變你的程式碼？例如，很多函式會需要位置參數。在 JavaScript 中，如果我們想要在前五個字元後尋找一個空白（是的，slice 也可以在字串中使用），我們可以這樣寫：

```go
haystack = "the spice must flow";
console.log(haystack.indexOf(" ", 5));
```

在 Go 語言中，我們使用 slice 來做：

```go
strings.Index(haystack[5:], " ")
```

從上面的例子中，我們可以看到 `[X:]` 是代表 *從 X 到結尾* 的縮寫。而 `[:X]` 代表的是 *從開始到 X* 的縮寫。跟其他語言不同的是，Go 不支援負索引值，如果我們想要除了最後一個以外的所有值，可以這樣寫：

```go
scores := []int{1, 2, 3, 4, 5}
scores = scores[:len(scores) - 1]
```

下面的例子是從一個未排序 slice 中去除一個值的有效方法。

```go
func main() {
  scores := []int{1, 2, 3, 4, 5}
  scores = removeAtIndex(scores, 2)
  fmt.Println(scores)
}

func removeAtIndex(source []int, index int) []int {
  lastIndex := len(source) - 1
  // 交換最後的值並移除我們想要除的值
  source[index], source[lastIndex] = source[lastIndex], source[index]
  return source[:lastIndex]
}
```

我們已經瞭解了 slice。最後，再來學習一下一個常見的內建函式 `copy`。`copy` 是許多的函式中顯著會改變我們如何撰寫程式碼的函式之一。一般來說，複製陣列的值到另外一個陣列會需要五個參數：`source`, `sourceStart`, `count`, `destination` 和 `destinationStart`。但使用 slice，我們只需要兩個參數：

```go
import (
  "fmt"
  "math/rand"
  "sort"
)

func main() {
  scores := make([]int, 100)
  for i := 0; i < 100; i++ {
    scores[i] = int(rand.Int31n(1000))
  }
  sort.Ints(scores)

  worst := make([]int, 5)
  copy(worst, scores[:5])
  fmt.Println(worst)
}
```

花點時間研究上面的程式碼。試著改變一些部分。如果你使用 `copy(worst[2:4], scores[:5])` 方式去複製，看看會產生什麼結果？或者試著複製多於或者少於 5 個值到 `worst`。

## Map

在 Go 語言中的 Map 就如同其他語言的 hashtable 或 dictionary。他們的功用正如同你想像的：定義鍵和值，你可以從 map 中取得、設定或刪除該值。

Map 和 slice 一樣，可以透過 `make` 函式來建立。讓我們來看個例子：

```go
func main() {
  lookup := make(map[string]int)
  lookup["goku"] = 9001
  power, exists := lookup["vegeta"]

  // 列印 0，false
  // Integer 的預設值為 0
  fmt.Println(power, exists)
}
```

使用 `len` 可以取得鍵值的數量。可以透過 `delete` 函式來刪除特定鍵的值。

```go
// 回傳 1
total := len(lookup)

// 沒有任何的回傳，可以呼叫一個不存在的 key
delete(lookup, "goku")
```

Map 是動態增長的。然而，我們可以在 `make` 函式中透過設定第二個參數來給訂初始大小：

```go
lookup := make(map[string]int, 100)
```

如果你對於有多少鍵值有概念的話，預先定義初始化大小有助於提升效能。

當你需要把結構的欄位定義為一個 map 時，可以這樣做：

```go
type Saiyan struct {
  Name string
  Friends map[string]*Saiyan
}
```

初始化上面這個結構的一種方式：

```go
goku := &Saiyan{
  Name: "Goku",
  Friends: make(map[string]*Saiyan),
}
goku.Friends["krillin"] = ... // 待完成的 krillin 或建立 Krillin
```

這裡還有另外一種方式可以宣告和初始化一個 map。類似 `make`，這種方式可以用來初始化 map 和陣列。我們可以這樣宣告：

```go
lookup := map[string]int{
  "goku": 9001,
  "gohan": 2044,
}
```

我們可以使用 `for` 迴圈和 `range` 關鍵字來遍歷 map：

```go
for key, value := range lookup {
  ...
}
```

要特別注意的是，遍歷 map 是沒有順序性的。每一次的遍歷返回的鍵值對都是隨機的。

## 指針和值

我們在第二章時已經討論過什麼時候要傳遞指針、什麼時候要傳遞值。現在我們學習到了陣列和 map，再來看看該使用以下哪一種方式？

```go
a := make([]Saiyan, 10)
// 或
b := make([]*Saiyan, 10)
```

很多開發者會認為傳遞 b 到一個函式，或是回傳一個 b 會比較有效率，但事實上，我們傳遞或返回的都是一個 slice 的拷貝，所以就傳遞或返回這個 slice 而言，是沒有什麼差別的。

你會看見不同的地方是在於如果你要修改 slice 或 map 的值。在這點上，同樣的邏輯我們已經在第二章看過。所以是定義一個陣列指針或陣列值，取決於你怎麼使用單個值，而不是怎麼使用陣列或 map 本身來決定。

## 在你繼續學習之前

陣列和 map 在 Go 中跟其他的語言很類似，如果你曾經使用過動態陣列，可能需要一點時間適應，但是 `append` 應該會解決掉大部分不適應的地方。如果我們拋開陣列表面的語法，你會發現 slice 是很強大的。使用 slice 對於維持程式碼的簡潔有很大幫助。

這邊有一些極端案例我們沒有提到，但你應該很少會遇到這些案例。如果你碰到了，希望我們為你打下的基礎可以讓你了解是怎麼回事。
