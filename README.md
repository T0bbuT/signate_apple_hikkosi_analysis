# 引っ越し需要予測のための機械学習モデル
## 概要
[SIGNATEのコンペ「アップル 引越し需要予測」](https://user.competition.signate.jp/ja/competition/detail/?competition=ada98a13ab224468b1c7191d819d7646)を題材としたデータ分析。

引越し業者における時期ごとの最適な価格設定のため、機械学習を利用した受注件数の予測モデルを開発  
最終的なモデルは
- 長期的な件数変動のトレンドを捉えるモデル
- 日々の細かい件数の変動を捉えるモデル

2つの基本モデルを組み合わせて構築

データは現在非公開のため、完全再現はできませんが、コードの流れや環境構築の手順を理解することは可能です。
data/ 以下にはダミーデータを配置しており、処理フローを追うことができます。

## 説明資料
スライドによる説明資料は以下からご覧ください。  
[![スライドのサムネイル](docs/slides_thmb.png)](https://t0bbut.github.io/signate_apple_hikkosi_analysis/成果物資料_引っ越し需要予測.pdf)

## notebookの閲覧について
notebookフォルダ内にEDAやモデル構築に使ったノートブックが配置されています。  
ただし、EDA2.ipynbにはplotlyで作ったインタラクティブなグラフが入っており、これはgithubのプレビューでは表示できません。  
[こちら](https://t0bbut.github.io/signate_apple_hikkosi_analysis/EDA2.html)からご確認下さい。  

## 再現方法

このリポジトリは **Python 3.11.9** で動作確認しています。  
以下の手順で仮想環境を構築し、依存ライブラリをインストールできます。  

```bash
git clone https://github.com/T0bbuT/signate_apple_hikkosi_analysis.git
cd signate_apple_hikkosi_analysis

# 仮想環境の作成
python -m venv .venv

# 仮想環境の有効化
source .venv/bin/activate   # Windows の場合は .venv\Scripts\activate

# 依存ライブラリのインストール
pip install -r requirements.txt
```
### データについて
その後、[コンペサイト](https://user.competition.signate.jp/ja/competition/detail/?competition=ada98a13ab224468b1c7191d819d7646)からデータをダウンロードし、data\input\に配置して実行していました。  
※ 2025/08/30現在、コンペは既に開催終了しておりデータへのアクセスは不可能のため、完全な再現はできません。代わりにダミーデータを配置する予定です。コードの流れを読む用途にご利用ください。
