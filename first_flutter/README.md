「トキの飛翔」の最初の羽ばたき

SPTKのバイナリのパスはビルドバスをスクリプト内に定義しています。

一部のスクリプトでデータディレクトリをハードコードしています。

* ファイル一覧

analyze.rb  ---  recommender確認スクリプト

center.sh  ---  センターのフレーム切り出しスクリプト(SPTK)

chkzero.sh  ---  最大ゼロクロス確認スクリプト(SPTK)

classifier.json  ---  jubatus classifier設定ファイル

fftdmp.sh  ---  SPTKを使ってfftデータをダンプ(SPTK)

findtw.sh  ---  最大ゼロクロス部分を0.4秒抜き出し

list.csv  ---  学習データ

lpc.py  ---  lpc確認pythonスクリプト

lpc.sh  ---  lpc取得スクリプト(SPTK)

lpcdmp.sh  ---  lpcダンプスクリプト(SPTK)

mfcc.sh  ---  mfcc取得スクリプト(SPTK)

recommender.json  ---  jubatus recommender設定ファイル

test.rb  ---  classifierテストスクリプト

train.rb  ---  classifier教師スクリプト

update.rb  ---  recommender更新スクリプト

jubatusはlpcではなくmfccで特徴データを作っています。

* recommenderの使い方

jubarecommender --configpath recommender.json

ruby update.rb

ruby analyze.rb

* classifierの使い方

jubaclassifier -f classifier.json

ruby train.rb

ruby test.rb

* Todo

ゼロクロスだけだと対象選別の精度が悪いので改善策を考える

一点のmfccだけの特徴量だとご認識が多いので改善策を考える

SPTKをjubatusのpluginにする（意味あるかな？）
