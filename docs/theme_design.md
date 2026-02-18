# Theme System Design Document

## 1. Background

This project supports multiple communities on one Rails codebase.
Each community can have:

- Its own visual theme
- Its own layout preset
- Its own color palette
- Its own brand assets (logo, cover, background)
- Optional per-community view overrides

The implementation is Rails-native and does not rely on `themes_on_rails`.

## 2. Goals

1. Keep one deployable app for multiple communities.
2. Allow theme customization without code changes for daily operations.
3. Support strict fallback behavior for theme templates.
4. Keep admin and web rendering paths predictable and secure.
5. Make theme settings importable/exportable as JSON.

## 3. Non-goals

- Dynamic runtime compilation of SCSS per tenant.
- Full CMS-level drag-and-drop page building.
- Theme package marketplace.

## 4. Data Model

Theme data is stored on `Community`.

Key fields:

- `theme_key` (string): logical theme name (example: `valex`)
- `layout_preset` (string): layout selector for web routes
- `theme_settings` (json): palette values
- `host` (string): optional host-to-community mapping
- `sn` (string): community identifier (already used in legacy flow)

Asset attachments (ActiveStorage):

- `theme_logo`
- `theme_cover_image`
- `theme_background_image`

Default palette source:

- `Community::DEFAULT_THEME_SETTINGS`

## 5. Request Resolution and Community Selection

Community resolution is handled by `CommunityResolver`.

Resolution order:

1. `params[:sn]` / session `:sn` context
2. Host mapping (`communities.host`)
3. Subdomain mapping (`name_eng`, non-admin)
4. Current signed-in actor (`current_user.community` / `current_admin.community`)
5. First enabled community as fallback

Admin subdomain requests use admin-safe fallback behavior.

## 6. Theme View Resolution Strategy

`ApplicationController` prepends view paths in this order:

1. `app/themes/communities/<community_sn>/views`
2. `app/themes/<theme_key>/views`
3. default fallback:
   - admin request -> `app/themes/admin/views`
   - web request -> `app/themes/valex/views`

This gives deterministic override precedence:

- community override > theme override > default theme

## 7. Layout Resolution

- Web controllers (`ApplicationWebController`) use `current_layout_preset`
  and fallback to `valex`.
- Admin controllers (`ApplicationAdminController`) use `admin` layout.

## 8. CSS Variables Injection

`ThemeHelper` + shared partial render CSS variables into `<head>`:

- File: `app/views/shared/_community_theme_styles.html.erb`

Variables include:

- `--community-color-primary`
- `--community-color-secondary`
- `--community-color-accent`
- `--community-color-background`
- `--community-color-surface`
- `--community-color-text`
- `--community-color-muted-text`
- `--community-cover-image`
- `--community-background-image`

Base styles are defined in:

- `app/assets/stylesheets/theme.css`

## 9. Admin Theme Operations

Admin theme UI:

- Route: `GET /community_theme/edit`
- View: `app/themes/admin/views/admin/community_themes/edit.html.erb`

Supported operations:

1. Update theme base fields (`theme_key`, `layout_preset`, `host`)
2. Edit palette via color picker + hex input
3. Upload/remove logo/cover/background assets
4. Live preview in page
5. Reset palette to defaults
6. Export current theme JSON
7. Import theme JSON

Permission model:

- `super_admin`: can switch target community
- normal admin: can edit only own community

## 10. JSON Import/Export Contract

Export endpoint:

- `GET /community_theme/export_json`

Import endpoint:

- `PATCH /community_theme/import_json`

Accepted payload shape:

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

Import validation:

- Only known keys are accepted.
- Color values must be valid hex (`#RGB`, `#RRGGBB`, `#RRGGBBAA`).
- Invalid color values are ignored, valid values are merged.

## 11. Security and Hardening

1. Path segment sanitization for `theme_key` and `layout_preset`
   prevents arbitrary path traversal.
2. Color input validation limits CSS injection vectors.
3. Asset rendering uses Rails URL helpers and attachment checks.
4. Community selection for non-super admins is restricted by `community_id`.

## 12. CI and Runtime Notes

- CI runs with MySQL + Redis service containers.
- Test environment avoids on-demand asset compilation.
- Test schema maintenance is tuned for MySQL view compatibility.
- Workflow file is tracked under `.github/workflows/ci.yml`.

## 13. Key Files (Reference Map)

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

## 14. Future Enhancements

1. Theme import dry-run with side-by-side diff preview.
2. Theme versioning and rollback support.
3. Optional per-community asset CDN paths.
4. Theme configuration audit trail in admin logs.
