# NEXUS DELTA UI v1.4.0

The Update Center shows a visible bar like `[========------------] 40%` whenever the user presses UPDATE. The progress reflects updater stages, not exact network byte progress. The update action is not gated by the current version number, so testing with an older version such as 0.0.1 still starts the update process.

The updater attempts to fetch the trusted raw GitHub source, perform basic checks, compile it, and launch it. HTTP and loadstring support depend on the executor. It reports failure if a step fails and never claims that an uncompleted download succeeded.

Set `API_URL` to the hosted API and `GITHUB_LOADER_URL` to the trusted raw Lua file. This package is a UI/catalog updater demo and does not implement gameplay cheats or anti-ban bypasses.
