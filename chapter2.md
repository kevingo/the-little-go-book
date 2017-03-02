# 第二章 - 結構

Go 不像 C++、Java、Ruby 或 C# 一樣是物件導向程式語言。他沒有物件或繼承，也沒有許多物件導向的概念，比如說多形或重載。

Go 語言擁有的是結構，和方法有關。Go 也支持簡潔但有效的組合關係。整體來說，他會讓程式碼更簡潔，但你有時候也會失去一些物件導向所提供的特性。（值得一提的是，*組合優於繼承* 這樣的說法長久以來不斷被討論，而 Go 是我用的第一個可以對這個說法採取堅定立場的語言）

即使 Go 可能不像你在寫物件導向程式語言那樣熟悉，但你會發現結構和類別有很多相像之處，讓我們來看一個簡單的 `Saiyan` 結構：

```go
type Saiyan struct {
  Name string
  Power int
}
```

我們很快將看到如何在這個結構中增加一個方法，就像你將方法作為類別的一部分。在我們這樣做之前，我們必須回顧宣告的用法。

## 宣告及初始化

當我們第一次看到變數和宣告時，我們只學習了內建的型態，比如說整數或字串。現在，我們來談談結構。我們同時必須來學習指針。

建立一個結構的值，最簡單的方法是：
```go
goku := Saiyan{
  Name: "Goku",
  Power: 9000,
}
```

*注意：* 上面的結構中最後的 `,` 是必要的。你會感激需要逗點所代表的一致性，特別是你用過其他不需要強制使用逗號的程式語言。

在初始化結構時，我們不需要設置所有的欄位。下面兩個宣告都是合法的：

```go
goku := Saiyan{}

// 或者

goku := Saiyan{Name: "Goku"}
goku.Power = 9000
```

就像沒有指派的變數一樣，欄位也會被指派為對應的零值。

此外，你還可以省略欄位的名稱，這樣就會按照順序來對應賦值（為了清楚起見，你應該僅僅在少量欄位名稱的時候使用這種操作）：

```go
goku := Saiyan{"Goku", 9000}
```

上面的各種範例都是宣告一個 `goku` 的結構變數，並且指派對應的值。

許多時候，我們不想要一個直接關聯的變數，而是想要一個指向該變數所儲存的值的指標。指標所儲存的內容是記憶體位置，找到這個記憶體位置就可以找到對應的值。這是一種對應的關係，
就像你的房子和前往你房子的方向一樣。

為什麼我們想要值的指標，而不是值本身呢？這就必須要知道 Go 傳遞參數到一個函式：用副本的方式。了解這個之後，來看看底下會印出什麼？

```go
func main() {
  goku := Saiyan{"Goku", 9000}
  Super(goku)
  fmt.Println(goku.Power)
}

func Super(s Saiyan) {
  s.Power += 10000
}
```

答案是 9000，而不是 19000，為什麼？因為 `Super` 改變了 `goku` 副本的值，而並非原本呼叫 `Super` 所傳進去的 `goku`。因此，在 `Super` 中的變更並不會反應到呼叫 `Super` 時所傳入的 `goku` 上。為了讓程式碼的行為如你所預期，我們必須要傳入指標：

```go
func main() {
  goku := &Saiyan{"Goku", 9000}
  Super(goku)
  fmt.Println(goku.Power)
}

func Super(s *Saiyan) {
  s.Power += 10000
}
```

在這裡我們調整兩個部分。第一個是我們使用 `&` 運算子來取得對應值的記憶體位置（這叫做 *取得記憶體位置* 運算子）。接著，我們變更 `Super` 函式的參數。之前我們預期的參數是 `Saiyan` 結構的值，但是現在我們預期的參數是 `*Saiyan` 型態，`*X` 的意思是 *型別 X 的值的指標*。顯而易見的，`Saiyan` 和 `*Saiyan` 勢必有些關聯，但他們是兩種完全不同的型別。

注意我們仍然將 `goku` 的副本值傳給 `Super`，只是 `goku` 的值變成了記憶體位置。

我們可以試著變更這個副本指向的位置來證明他的確是個副本（不過這也許不是你本來會做的事情）：

```go
func main() {
  goku := &Saiyan{"Goku", 9000}
  Super(goku)
  fmt.Println(goku.Power)
}

func Super(s *Saiyan) {
  s = &Saiyan{"Gohan", 1000}
}
```

上面的例子中，還是會印出 9000。這個行為在許多的程式語言都是如此，包含：Ruby, Python, Java 和 C#。在 Go 和 某種程度的 C# 上，只是讓這個事實更顯著。

更顯而易見的，指標的副本會比整個複雜結構的副本來的輕量多了。在 64 位元的機器上，一個指標的大小是 64 bits。如果我們有一個包含許多欄位的結構，建立一個副本會是相當昂貴的。指標的真正價值是讓你共享值，想想看，我們是想要讓 `Super` 變更 `goku` 的副本，還是共享 `goku` 值的本身呢？

這一切不是說你永遠都說我要的是一個指標。在這章節的最後，等到我們看了更多關於結構的內容後，我們會再重新看看指標和值的問題。

## 函式和結構

我們可以將一個方法與結構互相關聯：

```go
type Saiyan struct {
  Name string
  Power int
}

func (s *Saiyan) Super() {
  s.Power += 10000
}
```

在上面的程式中，我們說 `*Saiyan` 型別是 `Super` 方法的**接收者**。我們可以這樣呼叫 `Super`：

```go
goku := &Saiyan{"Goku", 9001}
goku.Super()
fmt.Println(goku.Power) // 將列印出 19001
```

## 建構子

結構並沒有所謂的建構子。相反的，你可以建立一個函式，回傳值是你所需要型別的實例（就像工廠模式一樣）：

```go
func NewSaiyan(name string, power int) *Saiyan {
  return &Saiyan{
    Name: name,
    Power: power,
  }
}
```

這種模式讓很多開發者走到錯誤的路上。一方面，他是一個很微妙的語法，另一方面，他確實感覺，有點不直覺。

我們的工廠模式不一定要回傳一個指標，下面這段程式碼也是完全合法的：

```go
func NewSaiyan(name string, power int) Saiyan {
  return Saiyan{
    Name: name,
    Power: power,
  }
}
```

## New

儘管 Go 語言中沒有建構子，但 Go 卻有內建的 `new` 函式，用來分配對應型別的記憶體空間。就結果來看，`new(X)` 和 `&X{}` 是一樣的。

```go
goku := new(Saiyan)
// 相同於
goku := &Saiyan{}
```

要用哪一種方法都可以，但你會發現大多數人都喜歡用後者，無論他們是否有對應的欄位需要初始化。原因是他比較容易閱讀。

```go
goku := new(Saiyan)
goku.name = "goku"
goku.power = 9001

// vs

goku := &Saiyan {
  name: "goku",
  power: 9000,
}
```

無論你採用哪種方法，只要遵循工廠模式，你可以放心的不去管後面如何分配記憶體位置的種種細節。

## 結構中的欄位

在我們已經看過的例子中，`Saiyan` 結構有兩個欄位，字串型別的 `Name` 和 整數型別的 `Power`。事實上，結構的欄位可以是任何型別，包括其他的結構，或是任何我們還沒有介紹過的陣列、map、介面和函式。

例如，我們可以擴展 `Saiyan` 的定義：

```go
type Saiyan struct {
  Name string
  Power int
  Father *Saiyan
}
```

可以這樣初始化：

```go
gohan := &Saiyan{
  Name: "Gohan",
  Power: 1000,
  Father: &Saiyan {
    Name: "Goku",
    Power: 9001,
    Father: nil,
  },
}
```

## 組合

Go 語言支持組合，意思就是將一個結構包含到另外一個結構的行為。在某些語言中，這被叫做 `trait` 或 `mixin`。沒有明確組合機智的語言總是會用其他的方式來達成。在 Java 中是這樣做：

```java
public class Person {
  private String name;

  public String getName() {
    return this.name;
  }
}

public class Saiyan {
  // 類別 Saiyan 宣告這裡有一個 person
  private Person person;

  // 我們轉向呼叫到 person 的 getName() 方法
  public String getName() {
    return this.person.getName();
  }
  ...
}
```

這樣撰寫十分乏味。`Person` 中的每個方法都必須要在 `Saiyan` 中重複一次。Go 則避免了這樣的作法：

```go
type Person struct {
  Name string
}

func (p *Person) Introduce() {
  fmt.Printf("Hi, I'm %s\n", p.Name)
}

type Saiyan struct {
  *Person
  Power int
}

// 並使用他：
goku := &Saiyan{
  Person: &Person{"Goku"},
  Power: 9001,
}
goku.Introduce()
```

`Saiyan` 結構中有一個型態是 `*Person` 的欄位。因為我們沒有給他明確的欄位名稱，所以我們可以透過組合隱性的存取這個欄位和函式。然而，Go 的編譯器 *的確* 會給他一個欄位名稱。看看以下的例子：

```go
goku := &Saiyan{
  Person: &Person{"Goku"},
}
fmt.Println(goku.Name)
fmt.Println(goku.Person.Name)
```

兩個都會印出 "Goku"。

組合是否比繼承好呢？許多人認為這是分享程式碼一個比較可靠的方式。當使用繼承時，你的類別會僅耦合到父類別，最終你關注的是階層結構而並非是程式碼本身的行為。

### 多載

雖然多載並不限定於在結構，但值得在這一提。簡單來說，Go 不支援多載，
所以你會看到很多函式用來做 `Load`、`LoadById`、`LoadByName`。

然而，因為隱性組合是一種編譯器的小技巧，我們可以「覆寫」組合型別的函式。例如，`Saiyan` 結構可以有自己的 `Introduce` 函式：

```go
func (s *Saiyan) Introduce() {
  fmt.Printf("Hi, I'm %s. Ya!\n", s.Name)
}
```

而你總是可以透過 `s.Person.Introduce()` 來呼叫他。

## 指標 V.S. 值

當你在寫 Go 的程式碼時，問問自己 *這是一個值，還是一個指標指向該值* 是很正常的。有兩個好消息，第一，下面任何一個問題的答案都是一樣的：

* 區域變數賦值
* 結構中的欄位
* 函式的回傳值
* 函式的參數
* 方法的接收者

第二，如果你不確定的話，用指標。

就像我們看到的，傳遞值是使得資料成為不可變得一個好方法（在被呼叫的方法中變更該值並不會反映到呼叫者上）。有時候，這是你想要的行為，但大多時候你不會想要這樣。

即使你真的不想要改變資料本身，想想看建立一個龐大結構的副本是多大的開銷。相反的，如果你有一個相對小的結構：

```go
type Point struct {
  X int
  Y int
}
```
在這樣的例子中，使用結構副本的開銷可能被抵銷掉，你可以直接訪問 `X` 和 `Y`。再提醒一次，這些都是比較細微的差別，除非你反覆存取幾千或幾萬次，不然可能不會注意到這開銷的差別。

## 在你繼續學習之前

從實際的角度來說，這一章節中我們介紹了結構。學習如何讓結構的實例成為一個函式的接收者。
並且在既有 Go 的型別系統中增加了指標的知識。下一章節會建基在我們學習到的結構。
