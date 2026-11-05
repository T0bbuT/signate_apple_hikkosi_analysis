# 引越し需要予測（SIGNATE「アップル 引越し需要予測」）

![Python](https://img.shields.io/badge/Python-3.14-3776AB?logo=python&logoColor=white)
![uv](https://img.shields.io/badge/env-uv-DE5FE9)
![polars](https://img.shields.io/badge/polars-1.40-CD792C)
![Prophet](https://img.shields.io/badge/Prophet-1.3-0866FF)
![scikit--learn](https://img.shields.io/badge/scikit--learn-1.8-F7931E?logo=scikitlearn&logoColor=white)

引越し業者が時期ごとの人員配置や価格設定を決めるために、**日ごとの引越し受注件数を予測する機械学習モデル**を構築しました。
題材は [SIGNATE のコンペ「アップル 引越し需要予測」](https://user.competition.signate.jp/ja/competition/detail/?competition=ada98a13ab224468b1c7191d819d7646) です。

**分析結果（出力付きノートブック）はこちらから閲覧できます。**

| ノートブック | 内容 | 閲覧（GitHub Pages） |
| --- | --- | --- |
| [`EDA.ipynb`](notebooks/EDA.ipynb) | 探索的データ分析、前処理方針の検討 | [EDA.html](https://t0bbut.github.io/signate_apple_hikkosi_analysis/EDA.html) |
| [`model_年月日_曜日_祝日_価格の和差積.ipynb`](notebooks/model_年月日_曜日_祝日_価格の和差積.ipynb) | 特徴量作成、モデル学習・評価、予測 | [model.html](https://t0bbut.github.io/signate_apple_hikkosi_analysis/model_年月日_曜日_祝日_価格の和差積.html) |

> リポジトリ内のノートブックは出力を消した状態で管理しています。グラフなどの出力は上の HTML でご確認ください。

## 概要

### 課題

- **データ**: 2010-07-01〜2016-03-31 の日次データ（引越し件数、休業日フラグ、法人案件フラグ、午前・午後の料金区分）
- **予測対象**: 2016-04-01〜2017-03-31 の日ごとの引越し件数
- **評価指標**: MAE（平均絶対誤差）

### アプローチ

件数の変動を「長期的なトレンド」と「日々の細かな変動」に分け、それぞれを別のモデルで捉えて組み合わせました。

```mermaid
flowchart LR
    A[日次データ] --> B[前処理<br/>休業日を分離・2010年を除外<br/>件数を対数変換]
    B --> C[Prophet<br/>長期トレンドを推定]
    C --> D[残差 = 実測 − トレンド]
    D --> E[GradientBoostingRegressor<br/>カレンダー・祝日・料金区分の特徴量で<br/>残差を学習]
    C --> F[予測 = exp トレンド + 残差]
    E --> F
    F --> G[休業日は 0 件として結合]
```

1. **前処理**: 休業日（`close = 1`）は件数が必ず 0 なのでルールで処理し、学習から除外。料金区分が欠損している 2010 年も除外。右に裾の長い分布を対数変換で整えた。
2. **トレンドモデル（Prophet）**: 年々増えていく緩やかな需要の伸びを推定。これにより、年ごとに右へずれていた分布の中心が揃う。
3. **変動モデル（勾配ブースティング）**: トレンドとの残差を、年月日・曜日・祝日・GW/SW/お盆・月初月末・料金区分の和差積など 23 個の特徴量で学習。
4. **検証**: 未来のデータが学習に混ざらないよう、年単位で区切った時系列交差検証（前年までで学習し翌年で検証）を使用。ハイパーパラメータは Optuna で探索。

### 結果

- 予測誤差は平均して **±7 件程度** で、引越し需要の予測に有用な精度が得られた。
- 特徴量重要度が高かったのは、年内の時期（`ordinal_day`）、月内の日（`day`）、曜日（`day_of_week`）、料金区分の和・積（`price_sum`, `price_product`）。
- 課題: 繁忙期（3〜4月）のピークへの追従が弱い。実務では「繁忙期にどれだけ需要が来るか」が重要なため、評価指標や繁忙期向けの特徴量の見直しが今後の改善点。

### EDA で分かったこと（抜粋）

- 引越し件数は年々増加傾向にあり、3〜4月の繁忙期に大きなピークがある。
- 件数 0 の日は休業日（年末年始・お盆）とほぼ一致する。
- 2014 年 5 月から法人案件フラグが立ち始め、フラグのある日は件数がやや多い。
- 料金区分は繁忙期に高く設定されており、午後は午前より安い傾向がある。

## ディレクトリ構成

```
.
├── notebooks/            # 分析ノートブック（出力は削除済み）
│   ├── EDA.ipynb
│   └── model_年月日_曜日_祝日_価格の和差積.ipynb
├── docs/                 # 出力付きノートブックの HTML（GitHub Pages で公開）
├── data/
│   ├── input/            # train.csv / test.csv を置く場所（Git 管理外）
│   └── output/           # sample_submit.csv、予測結果の出力先（Git 管理外）
├── pyproject.toml        # 依存ライブラリの定義
├── uv.lock               # 依存バージョンの固定（uv）
└── .python-version       # 使用する Python のバージョン（3.14）
```

## 環境構築と再現手順

依存関係は [uv](https://docs.astral.sh/uv/) で管理しており、`uv.lock` によってライブラリのバージョンを固定しています。
uv が Python 3.14 も自動で用意するため、事前に Python をインストールしておく必要はありません。

### 1. uv のインストール

```bash
# macOS / Linux
curl -LsSf https://astral.sh/uv/install.sh | sh

# Windows (PowerShell)
powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"
```

### 2. リポジトリの取得と依存ライブラリのインストール

```bash
git clone https://github.com/T0bbuT/signate_apple_hikkosi_analysis.git
cd signate_apple_hikkosi_analysis
uv sync --locked
```

### 3. データの配置

コンペのデータは SIGNATE の規約により再配布できないため、リポジトリには含めていません。
[コンペページ](https://user.competition.signate.jp/ja/competition/detail/?competition=ada98a13ab224468b1c7191d819d7646)から入手したファイルを以下のように配置してください（詳細は [data/README.md](data/README.md)）。

```
data/input/train.csv
data/input/test.csv
data/output/sample_submit.csv
```

> 2025 年 8 月時点で、コンペの開催は終了しておりデータはダウンロードできなくなっています。

### 4. ノートブックの実行

```bash
# JupyterLab を起動してノートブックを開く
uv run jupyter lab

# もしくは、コマンドラインから実行して HTML に書き出す（docs/ の HTML はこの方法で生成）
cd notebooks
uv run jupyter nbconvert --to html --execute EDA.ipynb model_年月日_曜日_祝日_価格の和差積.ipynb --output-dir ../docs
```

ノートブックは `EDA.ipynb` → `model_…ipynb` の順に読むと流れが追いやすいです（それぞれ単独でも実行できます）。
Optuna の探索などには乱数シードを固定しているため、同じ環境であれば同じ結果が得られます。

## 使用技術

| 用途 | ライブラリ |
| --- | --- |
| データ処理 | polars, pandas, NumPy |
| 時系列トレンド | Prophet |
| 機械学習・検証 | scikit-learn（GradientBoostingRegressor, TimeSeriesSplit） |
| ハイパーパラメータ探索 | Optuna |
| 可視化 | matplotlib, seaborn, Plotly |
| 祝日判定 | jpholiday |
| 環境管理 | uv |

## 参考

- [SIGNATE「アップル 引越し需要予測」](https://user.competition.signate.jp/ja/competition/detail/?competition=ada98a13ab224468b1c7191d819d7646)
- [Tremendous1192 様「SIGNATE SOTA アップル 引越し需要予測 備忘録」](https://zenn.dev/tremendous1192/articles/ea6e73359ee764)
