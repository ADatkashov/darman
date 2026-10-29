# CI/CD

Workflows: `.github/workflows/backend.yml` (Gradle tests + `bootJar`), `mobile.yml` (`flutter analyze` + `flutter test`),
`runner-smoke.yml` (checks the self-hosted runner). Both CI workflows run on pushes and pull requests that touch
`backend/**` / `mobile/**`, and by hand (*Actions -> run workflow*).

## Self-hosted runner

GitHub-hosted runners need Actions minutes/billing; a runner on your own machine does not. Both CI workflows pick their
runner from the repo variable `CI_RUNS_ON` (unset = `ubuntu-latest`), so no code change is needed to switch. The setup
is the one already used in `adatkashov/zairo`.

1. On a Linux x64 machine with Docker (the user must be in the `docker` group): GitHub -> repo *Settings -> Actions ->
   Runners -> New self-hosted runner*, copy the registration token (valid 1 hour).
2. `scripts/setup-self-hosted-runner.sh <token>` — downloads the runner, registers it as `<hostname>-darman` and installs it
   as a service. Java 21 and Flutter are installed by the workflows themselves (`setup-java`, `flutter-action`).
3. *Settings -> Secrets and variables -> Actions -> Variables*: add `CI_RUNS_ON` = `["self-hosted","linux"]`.
4. Run *Actions -> Runner smoke test -> Run workflow*, then *Backend* and *Mobile*. To go back to GitHub-hosted, delete the variable.

**On Windows:** run the runner inside WSL2, not as a native Windows runner (the workflows are bash + Linux containers).
1. PowerShell (admin): `wsl --install -d Ubuntu`, reboot, create the Ubuntu user.
2. Docker Desktop -> *Settings -> Resources -> WSL integration*: enable Ubuntu. Check `docker ps` works inside Ubuntu.
3. Optional, so the runner can be a service: in Ubuntu `sudo sh -c 'printf "[boot]\nsystemd=true\n" >> /etc/wsl.conf'`, then
   `wsl --shutdown` from PowerShell. Without systemd the script tells you to start `~/actions-runner/run.sh` by hand
   and keep that terminal open.
4. In Ubuntu: `git clone` the repo (or just copy the script) and continue from step 2 above.
The PC must be on, with WSL and Docker Desktop running, while CI runs.

Notes:
- The runner is persistent, so caches (Gradle, pub, Flutter SDK) stay on its disk. When `CI_RUNS_ON` is set the workflows
  skip the GitHub cloud caches, and failure artifacts are kept 3 days.
- Backend tests use Testcontainers PostgreSQL, so the runner needs a working Docker. Without Docker, point the tests at an
  empty database via `DARMAN_TEST_DB_URL` / `DARMAN_TEST_DB_USER` / `DARMAN_TEST_DB_PASSWORD`.
- If the machine is off, jobs wait in the queue until the runner is back.

### Security: this repository is public

Code from a pull request runs on the runner's machine. The workflows therefore skip pull requests from forks
(`head.repo.full_name == github.repository`). Also set *Settings -> Actions -> General -> Fork pull request workflows*
to **Require approval for all outside collaborators**, and do not add `pull_request_target` triggers or secrets
to jobs that run on the self-hosted runner. Run the runner as a non-root user, ideally on a dedicated machine or VM.
