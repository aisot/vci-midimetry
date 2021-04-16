# vci-midimetry

バーチャルキャストのVCIでMIDIデータを扱うためのライブラリ及び変換ツールです
ドキュメントはまだありません。
サンプルVCI(sample1.zip)のREADME.txtやluaスクリプトを参考にしてください。

## サンプルVCI
* https://aisot.org/vci-midimetry/sample1.zip

## MIDI入力をluaモジュールに変換するツール
* https://aisot.github.io/vci-midimetry/midi-recode.html

#### 各モジュールについて
##### main.lua
* Audioファイル名やmidiチャンネルの割り当て、3Dモデルのオブジェクト名やマテリアル名、鍵盤の数や開始位置の設定をここで行います

##### midi-metry.lua
* 演奏データのデコード処理とノートオンオフイベントを呼び出す処理を行ってます。

#### gakki-metry.lua
* 楽器を光らせる処理を行っています。midi-metryから呼ばれる事を想定しています。

#### perf_data_offset248.lua
*　演奏データのサンプルです。上記の midi-recode.html で作成します。

## 動作確認
* バーチャルキャスト

## ライセンス
MIT License

