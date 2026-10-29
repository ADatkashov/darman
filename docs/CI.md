# CI

Workflows: [`backend.yml`](../.github/workflows/backend.yml) — тесты бэкенда на PostgreSQL + `bootJar`;
[`mobile.yml`](../.github/workflows/mobile.yml) — `flutter gen-l10n`, `analyze`, `test`;
[`runner-smoke.yml`](../.github/workflows/runner-smoke.yml) — проверка self-hosted раннера.
Запуск CI: `push` и `pull_request` по путям `backend/**` / `mobile/**` (для PR — только из этого же репозитория,
форки на раннер не пускаются). Кнопки «Run workflow» у CI нет: упавший прогон перезапускается через *Re-run jobs*.

## Self-hosted runner

GitHub-hosted раннеры требуют Actions-минуты/биллинг (если их нет — джобы падают за секунды без шагов, `runner_id = 0`).
Self-hosted раннер на своей машине их не расходует. Раннер выбирается переменной репозитория `CI_RUNS_ON`
(не задана = `ubuntu-latest`), менять код не нужно. Скрипт и схема перенесены из проверенной настройки
`ADatkashov/feya` (ветка `main`), исходная схема — `ADatkashov/zairo` (ветка `develop`).

1. Linux x64 с Docker (пользователь в группе `docker`). GitHub → репозиторий *Settings → Actions → Runners → New
   self-hosted runner* → скопировать registration token (действует 1 час, одноразовый; нигде его не публикуйте).
2. `scripts/setup-self-hosted-runner.sh <token>` — скачивает раннер, регистрирует (метки `self-hosted,linux,x64`) и
   ставит сервисом (`systemd`). Запускать **не от root**, нужен `sudo`.
3. *Settings → Secrets and variables → Actions → Variables*: `CI_RUNS_ON` = `["self-hosted","linux"]`.
4. *Actions → Runner smoke test → Run workflow* — проверка, что раннер берёт джобы. Затем перезапустить CI.
   Вернуться на GitHub-hosted: удалить переменную `CI_RUNS_ON`.

**Windows:** запускайте раннер внутри WSL2 (Ubuntu), не нативно: `wsl --install -d Ubuntu`; в Docker Desktop включить
WSL integration для Ubuntu; опционально включить `systemd=true` в `/etc/wsl.conf` (иначе скрипт попросит запускать
`~/actions-runner-darman/run.sh` вручную и держать терминал открытым). Компьютер должен быть включён на время CI.

### Особенности

- Раннер ставится в `~/actions-runner-darman` (переменная `RUNNER_DIR`), поэтому не конфликтует с раннерами других
  репозиториев на той же машине (`zairo`, `feya`). Раннер привязан к одному репозиторию; общая папка `~/actions-runner`
  не подходит — установка падает с ошибкой «Cannot configure the runner because it is already configured».
  Несколько раннеров на одной машине работают как отдельные сервисы.
- Раннер постоянный: Gradle, pub и Flutter SDK остаются на диске, поэтому CI быстрее. При заданном `CI_RUNS_ON`
  облачные кэши (`setup-java`, `flutter-action`) отключены — они считаются в квоте Actions storage.
- PostgreSQL для тестов бэкенда поднимается service-контейнером `postgres:16` на **случайном** порту хоста, поэтому
  локальный PostgreSQL на 5432 не мешает. Тесты получают его через `DARMAN_TEST_DB_URL` / `_USER` / `_PASSWORD`
  (без этих переменных `IntegrationTest` сам запускает Testcontainers, тогда Docker тоже нужен).
- Артефакты отчёта о тестах хранятся 3 дня.
- Джобы пропускаются для PR из форков (`head.repo.full_name != github.repository`): репозиторий публичный, код чужих
  форков не должен выполняться на вашей машине. Не добавляйте триггеры `pull_request_target`. Дополнительно:
  *Settings → Actions → General → Fork pull request workflows* — «Require approval for all outside collaborators».
- Если машина выключена, джоб ждёт в очереди.
