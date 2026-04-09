# 楽天ポイ活マネジメント アプリケーション仕様書

## 1. アプリケーション概要
本アプリケーションは、ユーザーが日常的に行う「楽天ポイント活動（ポイ活）」のタスク管理、獲得ポイントの記録、そしてモチベーション維持のためのゲーミフィケーション（連続達成記録、実績バッジ）を提供するWebサービスです。また、LINEメッセージやWeb Push通知を利用したリマインダー機能を備え、ポイ活の習慣化をサポートします。

---

## 2. 主な機能仕様

### 2.1 ユーザー管理・認証機能
* **Web認証**: Deviseを用いたメールアドレスとパスワードによるログイン・新規登録機能。
* **LINEログイン連携**: OmniAuthを利用し、LINEアカウントでのログインが可能。
* **ユーザープロファイル管理**: LINEのプロフィール情報（名前、画像）の保持。

### 2.2 ポイ活の目標設定と実績管理機能
* **ポイ活マスタ管理 (`point_activities`)**: 「楽天ウェブ検索」や「楽天スーパーポイントスクリーン」など、ポイ活の種類のタイトルと推定所要時間を管理。
* **目標設定 (`point_activity_targets`)**: ユーザーが各ポイ活において、月に獲得したい目標ポイント数を設定可能。
* **実績記録 (`point_activity_gets`)**: 実行したポイ活とその獲得ポイントを記録。
* **ダッシュボード分析**: 過去の獲得実績を日別・週別でグラフ表示し、効率スコア（獲得ポイント÷所要時間）を算出。

### 2.3 タスク管理・スケジュール機能
* **日別タスク管理 (`daily_tasks`)**: ユーザーごとの毎日のポイ活状況（未完了/完了）を記録。
* **スケジュール定義 (`activity_schedules`)**: 各ポイ活の実施可能日時（曜日や時間帯）、参加で得られる見込みポイントなどを定義。

### 2.4 ゲーミフィケーション機能
* **連続達成記録 (`user_streaks`)**: 日々のポイ活（タスク）を連続で完了した日数をトラッキングし、現在の連続日数と過去最長日数を保持。
* **実績・バッジシステム (`achievements` / `user_achievements`)**: 連続日数や総獲得ポイントなどの特定の条件を満たしたユーザーに実績（バッジ）を付与。

### 2.5 通知・リマインダー機能
* **マルチチャネル通知設定 (`notification_settings`)**: ユーザーごとに「朝のリマインダー」「夜のサマリーアラート」「連続記録途切れの警告」などのオン・オフおよび通知時間、通知チャネル（LINE / WebPush）を設定可能。
* **通知ログ管理 (`notification_logs`)**: システムから送信した通知の履歴とステータス（成功/エラー）を記録。
* **Web Push サブスクリプション (`push_subscriptions`)**: ブラウザへのWebプッシュ通知を送信するためのエンドポイント情報をユーザーごとに管理。

---

## 3. テーブル定義書 (スキーマ定義)

データベース: MySQL (Charset: utf8mb4)

### 3.1 ユーザー関連

#### `users` (ユーザー基本情報)
| カラム名 | 型 | 制約 | 備考 |
|---|---|---|---|
| id | bigint | PK | |
| email | string | Unique, NotNull | |
| encrypted_password | string | NotNull | |
| reset_password_token | string | Unique | |
| *_at | datetime | | Devise関連のタイムスタンプ |

#### `line_profiles` (LINE連携プロフィール)
| カラム名 | 型 | 制約 | 備考 |
|---|---|---|---|
| id | bigint | PK | |
| user_id | bigint | FK, NotNull | |
| line_user_id | string | Unique | LINE独自のID |
| display_name | string | | LINE表示名 |
| picture_url | string | | プロフィール画像URL |
| status_message| string | | ステータスメッセージ |

### 3.2 ポイ活・実績トラッキング関連

#### `point_activities` (ポイ活マスタ)
| カラム名 | 型 | 制約 | 備考 |
|---|---|---|---|
| id | bigint | PK | |
| point_activity_title| string | | ポイ活の名称 |
| estimated_minutes | integer | | 推定所要時間（分） |

#### `point_activity_targets` (ユーザーの目標ポイント設定)
| カラム名 | 型 | 制約 | 備考 |
|---|---|---|---|
| id | bigint | PK | |
| user_id | bigint | FK, NotNull | |
| point_activity_id | bigint | FK, NotNull | |
| target_point | integer | | 目標ポイント数 |

#### `point_activity_gets` (獲得実績)
| カラム名 | 型 | 制約 | 備考 |
|---|---|---|---|
| id | bigint | PK | |
| user_id | bigint | NotNull | |
| point_activity_id | bigint | FK, NotNull | |
| get_point | integer | | 実際に獲得したポイント |

### 3.3 タスク・スケジュール関連

#### `daily_tasks` (日々のタスク状況)
| カラム名 | 型 | 制約 | 備考 |
|---|---|---|---|
| id | bigint | PK | |
| user_id | bigint | FK, NotNull | |
| point_activity_id | bigint | FK, NotNull | |
| task_date | date | NotNull | 対象日 |
| completed | boolean | default: false| 完了フラグ |
| completed_at | datetime | | 完了日時 |
* ※ [user_id, task_date, point_activity_id] でユニーク制約

#### `activity_schedules` (アクティビティ毎の実施スケジュール定義)
| カラム名 | 型 | 制約 | 備考 |
|---|---|---|---|
| id | bigint | PK | |
| point_activity_id | bigint | FK, NotNull | |
| frequency | string | | 頻度 (daily, weekly 等) |
| days_of_week | json | | 実施可能な曜日 |
| available_from| time | | 実施可能開始時間 |
| available_until| time | | 実施可能終了時間 |
| estimated_minutes | integer | | (ポイ活マスタ側と重複気味) |
| estimated_points | integer | | 獲得見込ポイント |

### 3.4 連続記録・実績バッジ関連

#### `user_streaks` (連続達成記録)
| カラム名 | 型 | 制約 | 備考 |
|---|---|---|---|
| id | bigint | PK | |
| user_id | bigint | FK, NotNull | |
| current_streak| integer | default: 0 | 現在の連続日数 |
| longest_streak| integer | default: 0 | 過去最長の連続日数 |
| last_completed_date| date | | 最後に完了した日付 |

#### `achievements` (実績バッジマスタ)
| カラム名 | 型 | 制約 | 備考 |
|---|---|---|---|
| id | bigint | PK | |
| name | string | NotNull | 実績の名前 |
| description | string | | 実績の詳細説明 |
| icon | string | | アイコンのパス/名前 |
| condition_type| string | | 半径バッジの付与条件種別 |
| condition_value| integer | | 付与条件の閾値（連続日数30など）|

#### `user_achievements` (ユーザーの実績獲得状態)
| カラム名 | 型 | 制約 | 備考 |
|---|---|---|---|
| id | bigint | PK | |
| user_id | bigint | FK, NotNull | |
| achievement_id| bigint | FK, NotNull | |
| earned_at | datetime | | バッジを獲得した日時 |

### 3.5 通知機能関連

#### `notification_settings` (ユーザー毎の通知設定)
| カラム名 | 型 | 制約 | 備考 |
|---|---|---|---|
| id | bigint | PK | |
| user_id | bigint | FK, NotNull | |
| morning_reminder| boolean| default: true | 朝の通知有無 |
| morning_reminder_time| time | | 朝の通知時間 |
| evening_summary | boolean| default: true | 夜の通知有無 |
| evening_summary_time | time | | 夜の通知時間 |
| campaign_alert | boolean| default: true | キャンペーン通知有無 |
| achievement_alert| boolean| default: true | 実績アンロック通知 |
| streak_warning | boolean| default: true | 連続記録途切れ警告 |
| notification_channel| string | default: "line"| 通知先 (line/webpush) |

#### `push_subscriptions` (Web Push購読情報)
| カラム名 | 型 | 制約 | 備考 |
|---|---|---|---|
| id | bigint | PK | |
| endpoint | string | | Push通知エンドポイントURL|
| p256dh | string | | 暗号化キー |
| auth | string | | 暗号化認証キー |
| user_id | bigint | FK, NotNull | |

#### `notification_logs` (通知の送信履歴)
| カラム名 | 型 | 制約 | 備考 |
|---|---|---|---|
| id | bigint | PK | |
| user_id | bigint | FK, NotNull | |
| notification_type | string | | リマインダー、サマリー等 |
| channel | string | | LINE, WebPush等 |
| status | string | | 成功/エラー |
| content | text | | 送信した本文 |
| error_message | text | | 失敗時のエラー詳細 |
