# Rails Upgrade Report

**Result: fully upgraded.** The app now runs on Rails 8.1.4.1, the latest stable release on RubyGems when this run checked on 2026-11-17. That release requires Ruby >= 3.2.0, and the app now uses Ruby 4.0.9.

## Versions

| Component | Before | After |
|---|---|---|
| Ruby (`.ruby-version`, `Gemfile`, lockfile, Dockerfile) | 3.1.2 | 4.0.9 |
| Rails | 7.0.4 | 8.1.4.1 |
| `config.load_defaults` | 7.0 | 8.1 |
| Bundler (`BUNDLED WITH`) | 2.3.7 | 4.0.20 (ships with Ruby 4.0.9) |
| Docker base image | `ruby:3.1.2-alpine` | `ruby:4.0.9-alpine` |
| Node / JS package manager | none used (importmap-rails, no `package.json`) | unchanged |
| Database | sqlite3 1.5.3 | sqlite3 2.10.2 |

The host machine only has Ruby 2.6. Every Ruby and Bundler command therefore ran inside the official `ruby:<version>` containers through `finch`, with gems stored in a named volume outside the repository.

## Upgrade steps (each step is a separate commit)

1. Rails 7.0.4 → 7.0.10, the latest 7.0 patch (on Ruby 3.1.2, Bundler 2.3.7).
2. Added characterization tests. Upgraded Ruby 3.1.2 → 3.3.13 and Bundler to 2.5.22. sqlite3 1.5.3 → 1.7.3, because 1.7.3 ships prebuilt binaries for Ruby 3.3.
3. Rails 7.0.10 → 7.1.6, then `load_defaults 7.1`.
4. Rails 7.1.6 → 7.2.4, then `load_defaults 7.2`.
5. Ruby 3.3.13 → 3.4.12.
6. Rails 7.2.4 → 8.0.5.2 (requires sqlite3 >= 2.1), then `load_defaults 8.0`.
7. Rails 8.0.5.2 → 8.1.4.1, then `load_defaults 8.1`.
8. Updated the direct dependencies.
9. Ruby 3.4.12 → 4.0.9, Bundler 4.0.20.
10. Fixed the Dockerfile, added lockfile platforms, and updated the README versions.

For every Rails feature line:
- I ran `bin/rails app:update` only in a throwaway copy inside the container, never on the real app.
- I reviewed the generated diff and merged only the applicable parts by hand.

## Dependency changes and decisions

- **Version constraints changed in the Gemfile:**
  - `rails ~> 7.0.4` → `~> 8.1.4`
  - `sqlite3 ~> 1.4` → `>= 2.1` (required by Rails 8.0)
  - `puma ~> 5.0` → `>= 5.0` (now 8.1.2)
  - `redis ~> 4.0` → `>= 4.0.1` (now 6.0.0; Action Cable 8.1 accepts `>= 4, < 7`)
- **Removed `webdrivers`:** it is not compatible with selenium-webdriver >= 4.11, and Selenium Manager now handles browser drivers. selenium-webdriver is at 4.52.0.
- **Bundler platform names:** `mingw`, `mswin` and `x64_mingw` were replaced with `windows` for `tzinfo-data` and `debug`.
- **`debug` (1.6.3 → 1.11.1):** forced by reline 0.7, which crashed `app:update`. I kept the default `require`. The newer generator's `require: "debug/prelude"` broke the Docker build, because that build excludes the development group.
- **`jbuilder` (2.11.5 → 2.15.1):** removes the `ActiveSupport::ProxyObject` deprecation warning that appeared on Rails 7.2.
- **`sprockets` (4.1.1 → 4.4.1) and `sprockets-rails` (3.4.2 → 3.5.2):** with json 3.1, production boot crashed once assets were precompiled (`unknown keyword: create_additions`).
- **`minitest`:** pinned to `~> 5.25` for Rails 7.1 through 8.0, because minitest 6 broke the test runner. The pin was removed on Rails 8.1, which works with minitest 6.1.0.
- **Also updated:** importmap-rails 2.2.3, turbo-rails 2.0.23, stimulus-rails 1.3.4, bootsnap 1.26.1, web-console 4.3.0, capybara 3.40.0. Rack is now 3.2.8.
- **`connection_pool`:** briefly resolved to 2.5.5 on Rails 7.2 because of an activesupport constraint, and is back at 3.0.3. It was not in the original lockfile.
- **Lockfile platforms added:** `aarch64-linux`, `aarch64-linux-musl`, `x86_64-linux-gnu`, `x86_64-linux-musl`, `arm64-darwin`. The original `x86_64-darwin-21` is kept.
- **CVE scan:** all 89 locked gems were checked against the OSV snapshot of 2026-11-16, and none have known vulnerabilities.

## Framework defaults

Each new default was switched on one at a time and followed by a run of the full test suite and a production eager-load boot. All passed. Only then did I change `load_defaults` and delete the transitional initializer. The per-option logs are in the run artifacts (`defaults_7_1.log` through `defaults_8_1.log`).

- **7.1:**
  - New security headers: `X-XSS-Protection: 0`, plus `X-Content-Type-Options`, `X-Permitted-Cross-Domain-Policies` and `Referrer-Policy`.
  - Message serializer `:json_allow_marshal`, which still reads cookies written in the old Marshal format.
  - Cache format 7.1, SHA-256 for Active Record encryption, strict SQLite strings, html5 sanitizers.
  - Autoload paths are no longer added to `$LOAD_PATH`.
  - The other Active Record and Active Job options. The app has no models or jobs, so none of them change any code path.
- **7.2:**
  - YJIT is now on (Ruby 3.3+), which may increase memory use.
  - Jobs are enqueued after the transaction commits.
  - Migration timestamps are validated.
  - WebP is treated as an image content type.
  - PostgreSQL date decoding (not used here).
- **8.0:** `to_time_preserves_timezone = :zone`, `strict_freshness`, `Regexp.timeout = 1`.
- **8.1:**
  - JSON responses no longer escape HTML entities or JS line separators.
  - Finders that depend on ordering now raise when there is no order column.
  - Path-relative redirects now raise (`:raise`).
  - Ruby-based template dependency tracker.
  - Hidden fields no longer get `autocomplete="off"`.

## Application and configuration changes

- **`config/application.rb`:** `load_defaults 8.1`, and `config.autoload_lib(ignore: %w(assets tasks))` (`lib/` contains no Ruby files).
- **Environment files:**
  - `cache_classes` → `enable_reloading`.
  - In test, `show_exceptions false` → `:none`. This is the equivalent value and keeps errors raising in tests.
  - Dev/test diagnostics: `raise_on_missing_callback_actions`, plus `verbose_enqueue_logs` in development.
  - Production: `attributes_for_inspect = [:id]`.
- **`filter_parameter_logging.rb`:** now also filters `:email`, `:cvv` and `:cvc`.
- **`bin/setup`:** uses `system(*args, exception: true)`.
- **`public/400.html`:** added, in the existing error-page style. Rails 8 returns 400 for bad requests.
- **Database:** no migrations and no schema changes. The app has no `db/migrate` and no `db/schema.rb`. The Active Storage upgrade migrations from `app:update` were not added, because the app never created Active Storage tables.
- **Dockerfile:**
  - Removed `COPY Gemfile* package.json yarn.lock`. It failed before this upgrade because those files do not exist.
  - Replaced `bundle install --without ... --path=...`, whose flags no longer exist in Bundler 4, with `bundle config set --local without/path`.
  - Updated both stages to `ruby:4.0.9-alpine`.
- **README:** the Rails and Ruby version references are updated.

**Generator changes I deliberately did not adopt, to keep current behavior:**
- Production: `force_ssl` / `assume_ssl`, and the rewrite of logging to STDOUT / `RAILS_LOG_LEVEL` (the existing `RAILS_LOG_TO_STDOUT` logic stays).
- Keeping `public_file_server.enabled = ENV["RAILS_SERVE_STATIC_FILES"]`.
- Keeping the `NF_HOSTS` host-authorization blocks.
- `config/puma.rb`: the generated version uses 3 threads instead of 5 and drops `worker_timeout`, `environment` and `pidfile`.
- Development: memory cache store, annotated views, mailer URL options.
- Test: `show_exceptions :rescuable`.
- New optional files: `bin/dev`, `bin/ci`, `config/ci.rb`, `406-unsupported-browser.html`, icons, restyled error pages.
- Comment-only changes to initializers.

## Validation

The repository defines no CI, lint, audit or security scanner. The commands it does provide are `bin/rails test` and `bin/setup`.

**Baseline before any change (`ruby:3.1.2`):**
- `bin/rails test`: 0 runs, exit 0.
- Eager load, `zeitwerk:check`, production `assets:precompile`: all OK.
- **`docker build` FAILED** (the missing `package.json`/`yarn.lock` described above). This failure existed before the upgrade.

I added `test/integration/application_smoke_test.rb`, with 6 tests and 19 assertions. It covers:
- static and error pages being served;
- routing errors raising in tests;
- the layout rendering the stylesheet and importmap/turbo tags;
- host authorization accepting the single host string that comes from `NF_HOSTS`;
- the mailer defaults;
- `ApplicationRecord` being the abstract base class.

**Checks run at every step, with the final results on `ruby:4.0.9`:**

| Check | Result |
|---|---|
| `bundle check` | PASS |
| `bin/rails test` | PASS, 6 runs, 0 failures |
| Eager-load boot (`bin/rails runner 'Rails.application.eager_load!'`) | PASS |
| `bin/rails zeitwerk:check` | PASS |
| Development boot; deprecation count in dev/test logs | PASS; 0 deprecations |
| `RAILS_ENV=test bin/rails db:prepare` (isolated test SQLite database) | PASS |
| Production boot with a dummy secret, before and after `assets:precompile` | PASS |
| Production boot with deprecations reported (throwaway copy) | PASS, no deprecations |
| `assets:precompile` / `assets:clobber` | PASS |
| `bin/rails routes` diff against previous step | Unchanged from 7.1 onward. The 7.1 framework removed the Action Mailbox conductor edit/update/destroy routes (a development-only tool). |
| `finch build` of the Dockerfile | PASS |
| Container HTTP check, default env | `/` 200, `/robots.txt` 200, unknown path 404, foreign Host 403 |
| Container HTTP check, `RAILS_ENV=production`, `NF_HOSTS=localhost`, `RAILS_SERVE_STATIC_FILES=1` | `/` 404, digested asset 200, foreign Host 403 |

## Skipped checks, risks and follow-ups

- **System tests (`bin/rails test:system`) were not run.** None exist, and the containers have no Chrome. Follow-up: run `bin/rails test:system` on a machine with Chrome if system tests are added.
- **The app still uses Sprockets with importmap.** Propshaft is the Rails 8 default, but migrating is optional and out of scope.
- **Turbo 8 (turbo-rails 2.x) enables link prefetch on hover by default.** It can be disabled with `<meta name="turbo-prefetch" content="false">` if that is not wanted.
- **YJIT is on, which raises memory use.** Set `config.yjit = false` on memory-constrained Northflank plans.
- **The Docker image does not set `RAILS_ENV`; I kept that unchanged.** The deployment platform must provide `RAILS_ENV=production` and `SECRET_KEY_BASE` (or `RAILS_MASTER_KEY`) at runtime, as before. `assets:precompile` in the image runs in whatever environment the build provides.
- **Puma 8 changed the default production bind to `::` when IPv6 is available.** The Docker `CMD` binds `0.0.0.0` explicitly, so the image is not affected.
- **The new cookie/message serializer and cache format are not readable by Rails 7.0.** Rolling back after production traffic may invalidate sessions and cache entries.
- **No production action was taken:** no deployment, no production database, no real credentials.

## Files

**Pre-existing local changes:** none. `git status --short` was clean at the start.

**Files changed by this transformation:**
- `.ruby-version`
- `Dockerfile`
- `Gemfile`
- `Gemfile.lock`
- `README.md`
- `bin/setup`
- `config/application.rb`
- `config/environments/development.rb`
- `config/environments/production.rb`
- `config/environments/test.rb`
- `config/initializers/filter_parameter_logging.rb`
- `public/400.html` (new)
- `test/integration/application_smoke_test.rb` (new)
- `RAILS_UPGRADE_REPORT.md` (new)
