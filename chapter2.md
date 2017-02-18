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

// or

goku := Saiyan{Name: "Goku"}
goku.Power = 9000
```

就像沒有指派的變數一樣，欄位也會被指派為對應的零值。

此外，你還可以省略欄位的名稱，這樣就會按照順序來對應賦值（為了清楚起見，你應該僅僅在少量欄位名稱的時候使用這種操作）：

```go
goku := Saiyan{"Goku", 9000}
```

上面的各種飯粒都是宣告一個 `goku` 的結構變數，並且指派對應的值。

Many times though, we don't want a variable that is directly associated 
with our value but rather a variable that has a pointer to our value. 
A pointer is a memory address; it's the location of where to find the 
actual value. It's a level of indirection. Loosely, 
it's the difference between being at a house and having directions 
to the house.
許多時候，我們不想要一個直接關聯的變數，而是想要一個指向該變數所儲存的值的指標。
指標所儲存的內容是記憶體位置。

Why do we want a pointer to the value, rather than the actual value? 
It comes down to the way Go passes arguments to a function: as copies. 
Knowing this, what does the following print?

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

The answer is 9000, not 19000. Why? Because `Super` made changes to a copy of our original `goku` value and thus, changes made in `Super` weren't reflected in the caller. To make this work as you probably expect, we need to pass a pointer to our value:

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

We made two changes. The first is the use of the `&` operator to get the address of our value (it's called the *address of* operator). Next, we changed the type of parameter `Super` expects. It used to expect a value of type `Saiyan` but now expects an address of type `*Saiyan`, where `*X` means *pointer to value of type X*. There's obviously some relation between the types `Saiyan` and `*Saiyan`, but they are two distinct types.

Note that we're still passing a copy of `goku's` value to `Super` it just so happens that `goku's` value has become an address. That copy is the same address as the original, which is what that indirection buys us. Think of it as copying the directions to a restaurant. What you have is a copy, but it still points to the same restaurant as the original.

We can prove that it's a copy by trying to change where it points to (not something you'd likely want to actually do):

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

The above, once again, prints 9000. This is how many languages behave, including Ruby, Python, Java and C#. Go, and to some degree C#, simply make the fact visible.

It should also be obvious that copying a pointer is going to be cheaper than copying a complex structure. On a 64-bit machine, a pointer is 64 bits large. If we have a structure with many fields, creating copies can be expensive. The real value of pointers though is that they let you share values. Do we want `Super` to alter a copy of `goku` or alter the shared `goku` value itself?

All this isn't to say that you'll always want a pointer. At the end of this chapter, after we've seen a bit more of what we can do with structures, we'll re-examine the pointer-versus-value question.

## Functions on Structures

We can associate a method with a structure:

```go
type Saiyan struct {
  Name string
  Power int
}

func (s *Saiyan) Super() {
  s.Power += 10000
}
```

In the above code, we say that the type `*Saiyan` is the **receiver** of the `Super` method. We call `Super` like so:

```go
goku := &Saiyan{"Goku", 9001}
goku.Super()
fmt.Println(goku.Power) // will print 19001
```

## Constructors

Structures don't have constructors. Instead, you create a function that returns an instance of the desired type (like a factory):

```go
func NewSaiyan(name string, power int) *Saiyan {
  return &Saiyan{
    Name: name,
    Power: power,
  }
}
```

This pattern rubs a lot of developers the wrong way. On the one hand, it's a pretty slight syntactical change; on the other, it does feel a little less compartmentalized.

Our factory doesn't have to return a pointer; this is absolutely valid:

```go
func NewSaiyan(name string, power int) Saiyan {
  return Saiyan{
    Name: name,
    Power: power,
  }
}
```

## New

Despite the lack of constructors, Go does have a built-in `new` function which is used to allocate the memory required by a type. The result of `new(X)` is the same as `&X{}`:

```go
goku := new(Saiyan)
// same as
goku := &Saiyan{}
```

Which you use is up to you, but you'll find that most people prefer the latter whenever they have fields to initialize, since it tends to be easier to read:

```go
goku := new(Saiyan)
goku.name = "goku"
goku.power = 9001

//vs

goku := &Saiyan {
  name: "goku",
  power: 9000,
}
```

Whichever approach you choose, if you follow the factory pattern above, you can shield the rest of your code from knowing and worrying about any of the allocation details.

## Fields of a Structure

In the example that we've seen so far, `Saiyan` has two fields `Name` and `Power` of types `string` and `int`, respectively. Fields can be of any type -- including other structures and types that we haven't explored yet such as arrays, maps, interfaces and functions.

For example, we could expand our definition of `Saiyan`:

```go
type Saiyan struct {
  Name string
  Power int
  Father *Saiyan
}
```

which we'd initialize via:

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

## Composition

Go supports composition, which is the act of including one structure into another. In some languages, this is called a trait or a mixin. Languages that don't have an explicit composition mechanism can always do it the long way. In Java:

```java
public class Person {
  private String name;

  public String getName() {
    return this.name;
  }
}

public class Saiyan {
  // Saiyan is said to have a person
  private Person person;

  // we forward the call to person
  public String getName() {
    return this.person.getName();
  }
  ...
}
```

This can get pretty tedious. Every method of `Person` needs to be duplicated in `Saiyan`. Go avoids this tediousness:

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

// and to use it:
goku := &Saiyan{
  Person: &Person{"Goku"},
  Power: 9001,
}
goku.Introduce()
```

The `Saiyan` structure has a field of type `*Person`. Because we didn't give it an explicit field name, we can implicitly access the fields and functions of the composed type. However, the Go compiler *did* give it a field name, consider the perfectly valid:

```go
goku := &Saiyan{
  Person: &Person{"Goku"},
}
fmt.Println(goku.Name)
fmt.Println(goku.Person.Name)
```

Both of the above will print "Goku".

Is composition better than inheritance? Many people think that it's a more robust way to share code. When using inheritance, your class is tightly coupled to your superclass and you end up focusing on hierarchy rather than behavior.

### Overloading

While overloading isn't specific to structures, it's worth addressing. Simply, Go doesn't support overloading. For this reason, you'll see (and write) a lot of functions that look like `Load`, `LoadById`, `LoadByName` and so on.

However, because implicit composition is really just a compiler trick, we can "overwrite" the functions of a composed type. For example, our `Saiyan` structure can have its own `Introduce` function:

```go
func (s *Saiyan) Introduce() {
  fmt.Printf("Hi, I'm %s. Ya!\n", s.Name)
}
```

The composed version is always available via `s.Person.Introduce()`.

## Pointers versus Values

As you write Go code, it's natural to ask yourself *should this be a value, or a pointer to a value?* There are two pieces of good news. First, the answer is the same regardless of which of the following we're talking about:

* A local variable assignment
* Field in a structure
* Return value from a function
* Parameters to a function
* The receiver of a method

Secondly, if you aren't sure, use a pointer.

As we already saw, passing values is a great way to make data immutable (changes that a function makes to it won't be reflected in the calling code). Sometimes, this is the behavior that you'll want but more often, it won't be.

Even if you don't intend to change the data, consider the cost of creating a copy of large structures. Conversely, you might have small structures, say:

```go
type Point struct {
  X int
  Y int
}
```

In such cases, the cost of copying the structure is probably offset by being able to access `X` and `Y` directly, without any indirection.

Again, these are all pretty subtle cases. Unless you're iterating over thousands or possibly tens of thousands of such points, you wouldn't notice a difference.

## Before You Continue

From a practical point of view, this chapter introduced structures, how to make an instance of a structure a receiver of a function, and added pointers to our existing knowledge of Go's type system. The following chapters will build on what we know about structures as well as the inner workings that we've explored.