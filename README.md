# jp-yoho

気象庁のホームページ http://www.jma.go.jp/jp/yoho/ から「府県」天気予報を取得するものです。

```lisp
(require 'jp-yoho)

(let ((jp-yoho-fuken "八重山地方")
      (jp-yoho-area "与那国島地方"))
  (jp-yoho))

;; "20日5時石垣島地方気象台発表の天気予報(今日20日から明後日22日まで) 与那国島地方 今日20日 曇り時々雨 明日21日 曇り"
```

## Installation

`load-path` の通ったディレクトリに `jp-yoho.el` を置いてください。

## Usage

以下のシンボルを適切に設定しておき、関数 `jp-yoho` を評価します。評価結果は文字列ですので、お好きに加工してください。

* `jp-yoho-fuken`

   漢字の文字列を設定します。気象庁のホームページの府県リストボックスで選択肢として表示される文字列から選択して、設定してください。

   `jp-yoho--alist-fuken` の左辺をコピペするのが確実でしょう。

* `jp-yoho-area`

   漢字の文字列を設定します。気象庁のホームページでいずれかの府県を選んで表示されるページに複数の「地方」がある場合の、いずれかの地方を選択して、設定します。

   `jp-yoho--alist-fuken` の右辺から選んでコピペするのが確実でしょう。

## Advices

あからじめふたつの Advice を用意してあります。役立てば良いのですが。

* Emacs を起動した際に天気予報を表示する

   ```
   (advice-add 'fancy-startup-screen :after 'jp-yoho/fancy-screen-ad)
   ```

   [<img src="https://raw.githubusercontent.com/tkita/jp-yoho/master/fancy-startup-screen.jpg" height="200">](https://raw.githubusercontent.com/tkita/jp-yoho/master/fancy-startup-screen.jpg)

* <kbd>M-x calendar</kbd> でカレンダーを起動した際に、エコーエリアに天気予報を表示する

   ```
   (advice-add 'calendar :after 'jp-yoho/calender-ad)
   ```
