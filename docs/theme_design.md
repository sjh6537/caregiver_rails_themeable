# 主題系統架構設計文件

## 1. 背景與需求

本專案以單一 Rails 程式碼庫支援多個社群（Community）。
每個社群可擁有：

- 獨立視覺主題
- 獨立版型預設（layout preset）
- 獨立色盤設定
- 獨立品牌圖檔（Logo、封面圖、背景圖）
- 可選的「社群級」檢視模板（view）覆蓋

整體實作採用 Rails 原生機制，不依賴 `themes_on_rails`。

## 2. 設計目標

1. 維持單一可部署應用程式，同時服務多社群。
2. 讓日常主題調整可由後台完成，降低改程式碼需求。
3. 提供可預期且可追蹤的主題回退規則。
4. 確保前台與後台的渲染路徑一致且安全。
5. 支援主題設定 JSON 匯入與匯出。

## 3. 非目標

- 不在執行期做每個租戶的 SCSS 動態編譯。
- 不提供完整 CMS 等級的拖拉式頁面編排。
- 不建立主題套件市集機制。

## 4. 資料模型

主題資料儲存在 `Community` 模型。

主要欄位：

- `theme_key`（string）：主題鍵值（例：`valex`）
- `layout_preset`（string）：前台 layout 選擇器
- `theme_settings`（json）：色盤設定
- `host`（string）：可選的網域對應
- `sn`（string）：社群識別碼（沿用既有流程）

Active Storage 附件欄位：

- `theme_logo`
- `theme_cover_image`
- `theme_background_image`

預設色盤來源：

- `Community::DEFAULT_THEME_SETTINGS`

## 5. 請求解析與社群判定

社群判定由 `CommunityResolver` 負責，解析順序如下：

1. `params[:sn]` / session `:sn`
2. `communities.host` 網域對應
3. 子網域對應（`name_eng`，且非 admin 子網域）
4. 目前登入者對應社群（`current_user.community` / `current_admin.community`）
5. 第一個啟用中的社群（回退）

admin 子網域請求會採用較保守的後備策略，避免誤判社群。

## 6. 檢視模板解析策略與覆蓋優先序

`ApplicationController` 會透過 `prepend_view_path` 依序加入：

1. `app/themes/communities/<community_sn>/views`
2. `app/themes/<theme_key>/views`
3. 預設回退：
   - 後台請求：`app/themes/admin/views`
   - 前台請求：`app/themes/valex/views`

覆蓋優先序固定為：

- 社群覆蓋 > 主題覆蓋 > 預設主題

## 7. Layout 解析策略

- 前台控制器（`ApplicationWebController`）使用 `current_layout_preset`，找不到時回退到 `valex`。
- 後台控制器（`ApplicationAdminController`）固定使用 `admin` layout。

## 8. CSS 變數注入機制

由 `ThemeHelper` 搭配共用 partial 樣板將 CSS 變數注入 `<head>`：

- 檔案：`app/views/shared/_community_theme_styles.html.erb`

主要變數：

- `--community-color-primary`
- `--community-color-secondary`
- `--community-color-accent`
- `--community-color-background`
- `--community-color-surface`
- `--community-color-text`
- `--community-color-muted-text`
- `--community-cover-image`
- `--community-background-image`

基礎樣式定義於：

- `app/assets/stylesheets/theme.css`

## 9. 後台主題管理功能

後台主題設定頁：

- 路由：`GET /community_theme/edit`
- 檢視：`app/themes/admin/views/admin/community_themes/edit.html.erb`

提供操作：

1. 更新主題基本欄位（`theme_key`、`layout_preset`、`host`）
2. 使用色票與 HEX 輸入調整色盤
3. 上傳 / 移除 Logo、封面圖、背景圖
4. 頁面內即時預覽
5. 重設為預設色盤
6. 匯出目前主題 JSON
7. 匯入主題 JSON

權限模型：

- `super_admin`：可切換目標社群並編輯
- 一般管理員：僅可編輯自己所屬社群

## 10. 後台社群切換介面說明

本節說明後台「切換社群」介面的行為與權限邏輯。

### 10.1 顯示條件

「切換社群」下拉選單僅在以下條件同時成立時顯示：

- `current_admin.super_admin?` 為 `true`
- 可管理社群數量 `@communities.size > 1`

對一般管理員而言，頁面不顯示此區塊。

### 10.2 操作流程

1. 進入 `GET /community_theme/edit`
2. 在「切換社群」下拉選單選取目標社群
3. `onchange` 觸發表單送出，帶入 `community_id`
4. 後端在 `set_target_community` 讀取 `params[:community_id]`（或 `params.dig(:community, :id)`）
5. 載入目標社群資料，重新渲染同一頁編輯表單

### 10.3 權限與安全限制

- 可選社群清單由 `set_available_communities` 產生：
  - `super_admin`：`Community.enabled.sorted`
  - 一般管理員：僅限 `current_admin.community_id`
- 一般管理員即便手動帶入其他 `community_id`，仍會被忽略，最終只會操作自己社群。
- 若 `community_id` 不存在或不在可管理清單中，`super_admin` 會回退到第一個可管理社群。
- 若最終沒有可編輯社群，會導向 `admin_root_path` 並顯示提示訊息。

### 10.4 與主題操作的關聯

以下操作都會攜帶 `community_id`，確保切換後仍維持在同一目標社群：

- 更新主題（`PATCH /community_theme`）
- 重設色盤（`PATCH /community_theme/reset_palette`）
- 匯出 JSON（`GET /community_theme/export_json`）
- 匯入 JSON（`PATCH /community_theme/import_json`）

## 11. JSON 匯入 / 匯出契約

匯出端點：

- `GET /community_theme/export_json`

匯入端點：

- `PATCH /community_theme/import_json`

匯入可接受資料結構（摘要）：

```json
{
  "version": 1,
  "host": "demo.example.com",
  "theme_key": "valex",
  "layout_preset": "valex",
  "theme_settings": {
    "primary": "#4f46e5",
    "secondary": "#7c3aed",
    "accent": "#f59e0b",
    "background": "#f8fafc",
    "surface": "#ffffff",
    "text": "#0f172a",
    "muted_text": "#475569"
  }
}
```

驗證規則：

- 僅接受白名單欄位。
- 色碼必須為合法 HEX（`#RGB`、`#RRGGBB`、`#RRGGBBAA`）。
- 非法色碼會被忽略；合法值採 merge 更新。

## 12. 安全與強化措施

1. `theme_key`、`layout_preset` 會做路徑片段清理，避免路徑穿越。
2. 色碼輸入格式驗證，降低 CSS 注入風險。
3. 圖檔輸出統一透過 Rails URL helper 與附件存在檢查。
4. 非 `super_admin` 的社群選擇被 `community_id` 權限限制。

## 13. CI 與執行環境備註

- CI 使用 MySQL 與 Redis 服務容器。
- 測試環境避免即時資產編譯。
- 測試資料庫 schema 維護設定已配合 MySQL view 相容性調整。
- 工作流程檔案位於 `.github/workflows/ci.yml`。

## 14. 關鍵檔案對照

- `app/models/community.rb`
- `app/models/current.rb`
- `app/services/community_resolver.rb`
- `app/helpers/theme_helper.rb`
- `app/controllers/application_controller.rb`
- `app/controllers/admin/community_themes_controller.rb`
- `app/views/shared/_community_theme_styles.html.erb`
- `app/assets/stylesheets/theme.css`
- `app/themes/admin/views/admin/community_themes/edit.html.erb`
- `config/routes.rb`

## 15. 後續可擴充方向

1. 匯入前演練（dry-run）與差異比對預覽。
2. 主題版本化與回滾。
3. 社群級資產 CDN 路徑支援。
4. 後台主題設定異動稽核軌跡。
