# 「トキの飛翔」の最初の羽ばたき

SPTKのバイナリのパスは/usr/localにインストールせずにビルドバスをスクリプト
内に定義しています。

スクリプトでデータディレクトリをハードコードしているものがあります。

FreeBSD 9.3で試しています。[jubatus](http://jubat.us/ja/)もFreeBSDで
動かしています。パッチはprしてあります。

当初Pythonを使おうと思っていたので、Pythonのスクリプトが入っていますが
SPTKで処理できる事が分かったのでRubyからの処理に変更しました。

jubatusへはlpcではなくmfccで特徴データを作ってつっこんでいます。

サンプルデータはここにあります。
http://yahoo.jp/box/6yLp6j

## ファイル一覧

analyze.rb  ---  recommender確認スクリプト

center.sh  ---  センターのフレーム切り出しスクリプト(SPTK)

chkzero.sh  ---  最大ゼロクロス確認スクリプト(SPTK)

classifier.json  ---  jubatus classifier設定ファイル

fftdmp.sh  ---  SPTKを使ってfftデータをダンプ(SPTK)

findtw.sh  ---  最大ゼロクロス部分を0.4秒抜き出し

list.csv  ---  学習データリスト

lpc.py  ---  lpc確認pythonスクリプト

lpc.sh  ---  lpc取得スクリプト(SPTK)

lpcdmp.sh  ---  lpcダンプスクリプト(SPTK)

mfcc.sh  ---  mfcc取得スクリプト(SPTK)

recommender.json  ---  jubatus recommender設定ファイル

test.rb  ---  classifierテストスクリプト

train.rb  ---  classifier教師スクリプト

update.rb  ---  recommender更新スクリプト

dmpzero.sh --- ゼロクロスダンプスクリプト

mkteach.rb --- データ抜き出しrubyスクリプト

api.rb --- RoRのAPIスクリプト


## recommenderの使い方

```
$ jubarecommender -f recommender.json &

$ ruby update.rb set2

$ ruby analyze.rb set2
```

## classifierの使い方

```
$ jubaclassifier -f classifier.json &

$ ruby train.rb

$ ruby test.rb
snd/T30.aiff tugumi
snd/T40.aiff hiyodori
snd/T8.aiff kamo
snd/T68.aiff karasu
```

## WebAPI

```
$ curl http://localhost:3000/api/v1/upload -F sndfile=@T30.aiff
{"result":"tugumi"}
```

## Todo

ゼロクロスだけだと対象選別の精度が悪いので改善策を考える

一点のmfccだけの特徴量だと誤認識が多いので改善策を考える

SPTKをjubatusのpluginにする（意味あるかな？）
