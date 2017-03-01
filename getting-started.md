# 入門

如果你想要小試身手，可以試試看 [Go Playground](https://play.golang.org/)，它可以讓你在線上撰寫並執行你的 Go 程式碼而不需要安裝任何東西。[Go Playground](https://play.golang.org/) 也是用來分享程式碼到各大論壇，比如 [StackOverflow](http://stackoverflow.com/) 最熱門的方式。

安裝 Go 是直覺的。你可以從來源安裝它，但我建議你安裝預先編譯好的執行檔。當你到 Go 的官方下載頁面，你會看到不同平台的安裝檔，讓我們省略這些步驟，你會發現其實並不困難。

撇除那些簡單的範例，Go 程式在運作時主要會被放置在一個工作目錄中。這個工作目錄包含了 `bin`、`pkg` 和 `src` 等子目錄。你可能會強迫 Go 去滿足你自已的配置風格 - 千萬別這樣做。

一般來說，我會將自己的專案放在 `~/code` 目錄下。例如，我的 blog 放在 `~/code/blog`。對於 Go 而言，我的工作目錄是放在 `~/code/go`，同時，Go 的 blog 專案則是放在 `~/code/go/src/blog`。

總結來說，建立一個 Go 的工作目錄，並且將你的任何專案放置在這個目錄下的 src 子目錄中。

## OSX / Linux

下載 `tar.gz` 壓縮檔。對於 OSX 來說，你可能會下載 `go#.#.#.darwin-amd64-osx10.8.tar.gz` 這樣的檔案，而 `#.#.#` 則是 Go 的最新版。

透過 `tar -C /usr/local -xzf go#.#.#.darwin-amd64-osx10.8.tar.gz` 指令將檔案解壓縮到 `/usr/local`。

設定兩個環境變數：

GOPATH 這個環境變數指定到你的工作目錄，例如對我來說，就會是：`$HOME/code/go`。接著，我們需要附加 Go 的執行檔到 `PATH` 中，試著執行以下指令：

```sh
echo 'export GOPATH=$HOME/code/go' >> $HOME/.profile
echo 'export PATH=$PATH:/usr/local/go/bin' >> $HOME/.profile
```

你會需要啟用這些變數，可以嘗試重新開啟你的 shell，或是用 `source` 指令重新引入你的 profile 檔案。

如果一切順利，試著在 shell 中輸入 `go version`，你應該會看到類似以下的輸出： `o version go1.3.3 darwin/amd64`

## Windows

下載最新的 zip 壓縮檔。如果你是 x64 的系統，下載 `go#.#.#.windows-amd64.zip`，你應該會看到類似以下的輸出：`#.#.#` 是最新的 Go 版本。

解壓縮檔案到你像要的任何地方，`c:\Go` 是個好選擇。

設定兩個環境變數：
1. GOPATH 這個環境變數指定到你的工作目錄，那可能是 `c:\users\goku\work\go`。
2. 增加 `c:\Go\bin` 到你的 PATH 變數中。環境變數的設定可以在系統控制選單中的進階選項中找到。

環境變數可以透過`系統`控制台中的`進階`的`環境變數`按鈕來做設定。有些版本的 Windows 透過系統控制台的`進階系統設定`選項來做設定。

如果一切順利，試著在命令提示字元中輸入 `go version`，你應該會看到類似以下的輸出： `go version go1.3.3 darwin/amd64`
