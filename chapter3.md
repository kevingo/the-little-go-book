# Chapter 3 - Maps, Arrays and Slices

到目前為止我們看過了一些簡單了型別和結構。現在該是時候來看看陣列、陣列、slices 和 maps 了。

## 陣列

如果你來自 Python，Ruby，Perl，JavaScript 或 PHP（和更多），你可能在寫程式時習慣使用*動態陣列*。
這些陣列是在數據添加到陣列時自行調整大小的陣列。在 Go 中，像許多其他語言一樣，陣列是固定的。
宣告陣列需要我們指定大小，一旦指定大小，它就不能增加：

```go
var scores [10]int
scores[0] = 339
```

上面這個陣列宣告可以透過 `scores[0]` 到 `scores[9]` 來存取 10 個分數值。
如果嘗試存取超過這個範圍的陣列元素，編譯器會拋出執行時期錯誤。

我們也可以在初始化陣列的時候賦值：

```go
scores := [4]int{9001, 9333, 212, 33}
```

我們可以用 `len` 函式來取得陣列的長度。而 `range` 函式可以用來循序的存取每個元素值：

```go
for index, value := range scores {

}
```

使用陣列是有效率但不夠靈活。通常我們不知道即將要處理元素的數量，讓我們來看看 slices。

## Slices

在 Go 中，你很少會直接使用陣列，通常情況下你會使用 slices。slices 是一個輕量級的結構，
這個結構被封裝後，代表了一個陣列的一部份。這裡我們列出一些建立 slices 的方法，並且指出我們會在
後面什麼時候會用到他們。

第一種方式和我們建立陣列時有點相像：

```go
scores := []int{1,4,293,4,9}
```

不同於陣列的宣告，slice 在宣告時不需要宣告長度。為了理解兩者的差異，我們來看看另外一種使用 `make` 
建立 slice 的方式：

```go
scores := make([]int, 10)
```

我們使用 `make` 而沒有使用 `new` 是因為建立一個 slice 不僅僅是分配一個記憶體區間而已（`new` 的
作用就是分配一段記憶體區間）。明確的來說，我們幫底層的陣列建立了一段記憶體區間，同時也要初始化 slice。
在上面的例子中，我們初始化一個 slice，長度和容量都是 10。長度代表 slice 的大小，
而容量是底層陣列的大小。透過 `make` 函式，我們可以同時宣告長度和容量。

```go
scores := make([]int, 0, 10)
```

這會建立一個長度是 0 ，容量是 10 的 slice。（如果你有留意的話，會發現 `make` 和 `len` 同時實現了
 *重載* 的功能。Go 語言的某些特性會讓你感到有點失望，因為某些部分他並沒有揭露給開發者使用。）

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
  fmt.Println(scores) // prints [5]
}
```

但這改變了我們原本程式碼的意圖，在長度為 0 的 slice 上增加一個元素會被放到 slice 的第一個元素。
不管出自什麼原因，那段不能運作的程式碼會賦值給 slice 的第 8 個元素。為了達成這個目標，我們可以再
切割 slice：

```go
func main() {
  scores := make([]int, 0, 10)
  scores = scores[0:8]
  scores[7] = 9033
  fmt.Println(scores)
}
```

可以調整 slice 長度的上限是多少？這個上限就是根據 slice 的容量來決定，在上面的例子中，就是 10。
你可能會認為這沒有解決 *固定長度陣列* 的問題。其實 `append` 是比較特別的，如果底層的陣列已經滿了，
`append` 會創造一個更大的暫列，並且複製所有的值到新的陣列（這也是動態陣列的工作原理，像是：PHP、Python、
Ruby、Javascript等）。這就是為什麼我們在上面的例子中使用 `append`，我們必須要將 `append` 得返回值
重新指派給 scores 變數，如果原始的 slice 沒有更多容量時，`append` 會建立一個新的。

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

如果初始 `scores` 的容量是 5，為了要容納 20 個元素，slice 的容量必須要擴展 3 次，分別是
10、20 和 40。

最後一個範例：

```go
func main() {
  scores := make([]int, 5)
  scores = append(scores, 9332)
  fmt.Println(scores)
}
```

Here, the output is going to be `[0, 0, 0, 0, 0, 9332]`. Maybe you thought it would be `[9332, 0, 0, 0, 0]`? 
To a human, that might seem logical. To a compiler, you're telling it to append a value to a slice that 
already holds 5 values.
上面的程式碼輸出會是 `[0, 0, 0, 0, 0, 9332]`。從直觀來看，你可能會以為輸出是 `[9332, 0, 0, 0, 0]`？
對編譯器而言，上面的程式碼代表的意思是，附加 9332 到已經有五個值的 slice 。

最後，這裡提供四種常見初始化 slice 的方式：

```go
names := []string{"leto", "jessica", "paul"}
checks := make([]bool, 10)
var names []string
scores := make([]int, 0, 20)
```

你該使用哪一種方式？

第一種方式相當直觀，不需要太多的說明，但缺點是你必須先吃到要往 slice 裡面放的元素是什麼。
第二種方式在你想要往 slice 的特定位置寫入一個值的時候很有用，比如說：

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

最後一種方式讓我們指定 slice 的長度和容量。當我們大概知道需要多少元素時很有用。
即使你知道元素的個數，`append` 也可以被使用。這取決於個人喜好：

```go
func extractPowers(saiyans []*Saiyans) []int {
  powers := make([]int, 0, len(saiyans))
  for _, saiyan := range saiyans {
    powers = append(powers, saiyan.Power)
  }
  return powers
}
```

slice 作為一個陣列的封裝來說是很有用的。許多語言都有類似的概念。Javascript 和 Ruby 中都有一個 `slice` 方法。
在 Ruby 中，你可以透過 `[START..END]` 來得到一個 slice，或是在 Python 中使用 `[START:END]` 來得到一個 slice。
然而，在某些語言中，slice 的確是從原始陣列複製而來。如果我們使用 Ruby，下面的程式碼會輸出什麼？

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

這種行為會如何改變你的程式碼？例如，很多函式會需要位置參數。在 JavaScript 中，如果我們想要在前五個字元後尋找一個空白
（是的，slice 也可以在字串中使用），我們可以這樣寫：

```go
haystack = "the spice must flow";
console.log(haystack.indexOf(" ", 5));
```

在 Go 語言中，我們使用 slice 來做：

```go
strings.Index(haystack[5:], " ")
```

從上面的例子中，我們可以看到 `[X:]` 是代表 *從 X 到結尾* 的縮寫。而 `[:X]` 代表的是 *從開始到 X* 的縮寫。跟其他語言不同的是，
Go 不支援負索引值，如果我們想要除了最後一個以外的所有值，可以這樣寫：

```go
scores := []int{1, 2, 3, 4, 5}
scores = scores[:len(scores)-1]
```

上面的例子是從一個未排序 slice 中去除一個值得有效方法。

```go
func main() {
  scores := []int{1, 2, 3, 4, 5}
  scores = removeAtIndex(scores, 2)
  fmt.Println(scores)
}

func removeAtIndex(source []int, index int) []int {
  lastIndex := len(source) - 1
  //swap the last value and the value we want to remove
  source[index], source[lastIndex] = source[lastIndex], source[index]
  return source[:lastIndex]
}
```

我們已經瞭解了 slice。最後，再來學習一下一個常見的內建函式 `copy`。`copy` 是許多的函式中顯著會改變我們如何撰寫程式碼的函式之一。
一般來說，複製陣列的值到另外一個陣列會需要五個參數：`source`, `sourceStart`, 
`count`, `destination` 和 `destinationStart`。但使用 slice，我們只需要兩個參數：

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

花點時間研究上面的程式碼。試著改變一些部分。如果你使用 `copy(worst[2:4], scores[:5])` 方式去複製，看看會產生什麼結果？
或者試著複製多於或者少於 5 個值到 `worst`。

## Maps

Maps in Go are what other languages call hashtables or dictionaries. They work as you expect: you define a key and value, and can get, set and delete values from it.

Maps, like slices, are created with the `make` function. Let's look at an example:

```go
func main() {
  lookup := make(map[string]int)
  lookup["goku"] = 9001
  power, exists := lookup["vegeta"]

  // prints 0, false
  // 0 is the default value for an integer
  fmt.Println(power, exists)
}
```

To get the number of keys, we use `len`. To remove a value based on its key, we use `delete`:

```go
// returns 1
total := len(lookup)

// has no return, can be called on a non-existing key
delete(lookup, "goku")
```

Maps grow dynamically. However, we can supply a second argument to `make` to set an initial size:

```go
lookup := make(map[string]int, 100)
```

If you have some idea of how many keys your map will have, defining an initial size can help with performance.

When you need a map as a field of a structure, you define it as:

```go
type Saiyan struct {
  Name string
  Friends map[string]*Saiyan
}
```

One way to initialize the above is via:

```go
goku := &Saiyan{
  Name: "Goku",
  Friends: make(map[string]*Saiyan),
}
goku.Friends["krillin"] = ... //todo load or create Krillin
```

There's yet another way to declare and initialize values in Go. Like `make`, this approach is specific to maps and arrays. We can declare as a composite literal:

```go
lookup := map[string]int{
  "goku": 9001,
  "gohan": 2044,
}
```

We can iterate over a map using a `for` loop combined with the `range` keyword:

```go
for key, value := range lookup {
  ...
}
```

Iteration over maps isn't ordered. Each iteration over a lookup will return the key value pair in a random order.

## Pointers versus Values

We finished Chapter 2 by looking at whether you should assign and pass pointers or values. We'll now have this same conversation with respect to array and map values. Which of these should you use?

```go
a := make([]Saiyan, 10)
//or
b := make([]*Saiyan, 10)
```

Many developers think that passing `b` to, or returning it from, a function is going to be more efficient. However, what's being passed/returned is a copy of the slice, which itself is a reference. So with respect to passing/returning the slice itself, there's no difference.

Where you will see a difference is when you modify the values of a slice or map. At this point, the same logic that we saw in Chapter 2 applies. So the decision on whether to define an array of pointers versus an array of values comes down to how you use the individual values, not how you use the array or map itself.

## Before You Continue

Arrays and maps in Go work much like they do in other languages. If you're used to dynamic arrays, there might be a small adjustment, but `append` should solve most of your discomfort. If we peek beyond the superficial syntax of arrays, we find slices. Slices are powerful and they have a surprisingly large impact on the clarity of your code.

There are edge cases that we haven't covered, but you're not likely to run into them. And, if you do, hopefully the foundation we've built here will let you understand what's going on.
