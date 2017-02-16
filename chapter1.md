# 第一章 - 基本概念

Go 是需要編譯、靜態型別，同時具有類似於 C 的語法與具有 Garbage Collection 的語言。
這是什麼意思？

## 編譯
編譯是將高階程式碼轉換為低階程式碼的過程。
例如：在 Go 來說就會是組合語言，或是其他的中介語言（比如說 Java 和 C#)

你可能覺得編譯語言讓人不愉快，因為編譯速度可能相對慢。如果你需要等待數分鐘
甚至數小時來編譯你的程式碼，那要快速迭代是相當困難的。編譯速度是 Go 語言在設計上的主要考量。
這對於過去使用直譯式語言並且得利於快速開發週期的人來說，是相當好的消息。

編譯語言的執行速度較快，而且執行時不需要額外的相依套件
(至少，這對於 C、C++ 和 Go 這類編譯成組合語言的程式語言來說是這樣的)。

## 靜態型別
靜態型別意味著變數必須是特定類型 (int、string、bool、[]byte等)。 
這可以通過在宣告變數時指定類型來實現，或者在許多情況下，讓編譯器推斷類型
(我們稍後將看看範例)。關於靜態型別有很多可以提的，但我相信它是透過閱讀代碼會有更好的理解。
如果你習慣於動態類型的語言，你可能會發現這很麻煩。沒有錯，但這是有好處的。使用靜態型別系統，編譯器除了能夠檢查語法錯誤外，並能進一步進行優化。


## 類似於 C 的語法
如果一個程式語言的語法類似於 C，並且你曾經使用過其他類似語法的語言，
例如：C、C++、Java、Javascript 和 C#，那你會發現 Go 至少表面上看起來很類似。
比如說，他代表 `&&` 是 boolean 的 AND、`==` 是用來比較是否相等、`{` 和 `}`
是一個宣告的範圍，以及陣列的 index 從 0 開始。

類似於 C 的語法也代表了，分號指的是一行的結束，以及用括號來包住條件。但在 Go 語言中省去了這兩個部分，
儘管大括號還是用在控制範圍。舉例來說，一個 if 條件式會長的像：

```
if name == "Leto" {
  print("the spice must flow")
}
```
一個更複雜一點的例子中，括號依舊是有用的：
```
if (name == "Goku" && power > 9000) || (name == "gohan" && power < 4000)  {
  print("super Saiyan")
}
```
除此之外，Go比C＃或Java更接近C - 不僅在語法上，更在於其目的。
當你去學習 Go 語言後，你會發現他的簡潔和簡單。

## Garbage Collected
一些變數在建立時，有一個容易定義的生命週期。 例如，函式的區域變數在函式結束時消失。在其他情況下，這不是那麼顯著 - 至少對於編譯器來說。例如，由函式返回或由其他變數和物件引用的變數生命週期可能難以確定。沒有garbage collection 機制，開發人員需要在不需要變數的時候釋放與這些變數相關的記憶體。怎麼做？在 C，你可以使用 `free(str)`;。具有 garbage collection（例如：Ruby、Python、Java、JavaScript、C＃、Go）機制的語言能夠追蹤變數，並在不需要使用時釋放它們。垃圾收集增加了負擔，但它也解決了一些毀滅性的 bug。

## 執行 Go 程式碼

讓我們開始我們的旅程，建立一個簡單的程式，學習如何編譯和執行它。 打開您喜歡的編輯器，並撰寫以下程式碼：
```
package main

func main() {
  println("it's over 9000!")
}
```
將檔案另存為 `main.go`。現在，你可以儲存在任何你想要的地方。我們不需要把這個小範例放到工作目錄中。

接下來，打開 shell/command prompt，並將目錄切換到檔案的位置。對我來說，那就是輸入 `cd ~/code`。

最後，執行程式碼：

`go run main.go`

如果一切正確，你會看到 `it's over 9000!`。

但等等，那編譯的步驟呢？ `go run` 是一個同時進行編譯和執行程式碼的指令。它使用一個臨時目錄來建置程式、執行它、最後砍掉自己。 您可以透過以下指令查看臨時檔案的位置：
`go run --work main.go`

To explicitly compile code, use go build:
想要直接編譯程式碼，使用 `go build`：

`go build main.go`

這個指令會產生一個執行檔 `main`。在 Linux/OSX 系統中，你需要用 `./main` 來執行它。

在你開發的過程中，你可能會用 `go run` 或 `go build`，但在你部署程式時，
你會就直接編譯好執行檔，並且將執行檔進行部署了。

Main

Hopefully, the code that we just executed is understandable. We've created a function and printed out a string with the built-in println function. Did go run know what to execute because there was only a single choice? No. In Go, the entry point to a program has to be a function called main within a package main.

We'll talk more about packages in a later chapter. For now, while we focus on understanding the basics of Go, we'll always write our code within the main package.

If you want, you can alter the code and change the package name. Run the code via go run and you should get an error. Then, change the name back to main but use a different function name. You should see a different error message. Try making those same changes but use go build instead. Notice that the code compiles, there's just no entry point to run it. This is perfectly normal when you are, for example, building a library.

Imports

Go has a number of built-in functions, such as println, which can be used without reference. We can't get very far though, without making use of Go's standard library and eventually using third-party libraries. In Go, the import keyword is used to declare the packages that are used by the code in the file.

Let's change our program:

package main

import (
  "fmt"
  "os"
)

func main() {
  if len(os.Args) != 2 {
    os.Exit(1)
  }
  fmt.Println("It's over", os.Args[1])
}
Which you can run via:

go run main.go 9000
We're now using two of Go's standard packages: fmt and os. We've also introduced another built-in function len. len returns the size of a string, or the number of values in a dictionary, or, as we see here, the number of elements in an array. If you're wondering why we expect 2 arguments, it's because the first argument -- at index 0 -- is always the path of the currently running executable. (Change the program to print it out and see for yourself.)

You've probably noticed we prefix the function name with the package, e.g., fmt.Println. This is different from many other languages. We'll learn more about packages in later chapters. For now, knowing how to import and use a package is a good start.

Go is strict about importing packages. It will not compile if you import a package but don't use it. Try to run the following:

package main

import (
  "fmt"
  "os"
)

func main() {
}
You should get two errors about fmt and os being imported and not used. Can this get annoying? Absolutely. Over time, you'll get used to it (it'll still be annoying though). Go is strict about this because unused imports can slow compilation; admittedly a problem most of us don't have to this degree.

Another thing to note is that Go's standard library is well documented. You can head over to https://golang.org/pkg/fmt/#Println to learn more about the Println function that we used. You can click on that section header and see the source code. Also, scroll to the top to learn more about Go's formatting capabilities.

If you're ever stuck without internet access, you can get the documentation running locally via:

godoc -http=:6060
and pointing your browser to http://localhost:6060

Variables and Declarations

It'd be nice to begin and end our look at variables by saying you declare and assign to a variable by doing x = 4. Unfortunately, things are more complicated in Go. We'll begin our conversation by looking at simple examples. Then, in the next chapter, we'll expand this when we look at creating and using structures. Still, it'll probably take some time before you truly feel comfortable with it.

You might be thinking Woah! What can be so complicated about this? Let's start looking at some examples.

The most explicit way to deal with variable declaration and assignment in Go is also the most verbose:

package main

import (
  "fmt"
)

func main() {
  var power int
  power = 9000
  fmt.Printf("It's over %d\n", power)
}
Here, we declare a variable power of type int. By default, Go assigns a zero value to variables. Integers are assigned 0, booleans false, strings "" and so on. Next, we assign 9000 to our power variable. We can merge the first two lines:

var power int = 9000
Still, that's a lot of typing. Go has a handy short variable declaration operator, :=, which can infer the type:

power := 9000
This is handy, and it works just as well with functions:

func main() {
  power := getPower()
}

func getPower() int {
  return 9001
}
It's important that you remember that := is used to declare the variable as well as assign a value to it. Why? Because a variable can't be declared twice (not in the same scope anyway). If you try to run the following, you'll get an error.

func main() {
  power := 9000
  fmt.Printf("It's over %d\n", power)

  // COMPILER ERROR:
  // no new variables on left side of :=
  power := 9001
  fmt.Printf("It's also over %d\n", power)
}
The compiler will complain with no new variables on left side of :=. This means that when we first declare a variable, we use := but on subsequent assignment, we use the assignment operator =. This makes a lot of sense, but it can be tricky for your muscle memory to remember when to switch between the two.

If you read the error message closely, you'll notice that variables is plural. That's because Go lets you assign multiple variables (using either = or :=):

func main() {
  name, power := "Goku", 9000
  fmt.Printf("%s's power is over %d\n", name, power)
}
As long as one of the variables is new, := can be used. Consider:

func main() {
  power := 1000
  fmt.Printf("default power is %d\n", power)

  name, power := "Goku", 9000
  fmt.Printf("%s's power is over %d\n", name, power)
}
Although power is being used twice with :=, the compiler won't complain the second time we use it, it'll see that the other variable, name, is a new variable and allow :=. However, you can't change the type of power. It was declared (implicitly) as an integer and thus, can only be assigned integers.

For now, the last thing to know is that, like imports, Go won't let you have unused variables. For example,

func main() {
  name, power := "Goku", 1000
  fmt.Printf("default power is %d\n", power)
}
won't compile because name is declared but not used. Like unused imports it'll cause some frustration, but overall I think it helps with code cleanliness and readability.

There's more to learn about declaration and assignments. For now, remember that you'll use var NAME TYPE when declaring a variable to its zero value, NAME := VALUE when declaring and assigning a value, and NAME = VALUE when assigning to a previously declared variable.

Function Declarations

This is a good time to point out that functions can return multiple values. Let's look at three functions: one with no return value, one with one return value, and one with two return values.

func log(message string) {
}

func add(a int, b int) int {
}

func power(name string) (int, bool) {
}
We'd use the last one like so:

value, exists := power("goku")
if exists == false {
  // handle this error case
}
Sometimes, you only care about one of the return values. In these cases, you assign the other values to _:

_, exists := power("goku")
if exists == false {
  // handle this error case
}
This is more than a convention. _, the blank identifier, is special in that the return value isn't actually assigned. This lets you use _ over and over again regardless of the returned type.

Finally, there's something else that you're likely to run into with function declarations. If parameters share the same type, we can use a shorter syntax:

func add(a, b int) int {

}
Being able to return multiple values is something you'll use often. You'll also frequently use _ to discard a value. Named return values and the slightly less verbose parameter declaration aren't that common. Still, you'll run into all of these sooner than later so it's important to know about them.

Before You Continue

We looked at a number of small individual pieces and it probably feels disjointed at this point. We'll slowly build larger examples and hopefully, the pieces will start to come together.

If you're coming from a dynamic language, the complexity around types and declarations might seem like a step backwards. I don't disagree with you. For some systems, dynamic languages are categorically more productive.

If you're coming from a statically typed language, you're probably feeling comfortable with Go. Inferred types and multiple return values are nice (though certainly not exclusive to Go). Hopefully as we learn more, you'll appreciate the clean and terse syntax.