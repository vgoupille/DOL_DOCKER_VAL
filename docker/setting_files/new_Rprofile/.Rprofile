options(repos = Sys.getenv("CRAN_MIRROR"))

# Source: https://github.com/REditorSupport/vscode-R/wiki/Plot-viewer#svg-in-httpgd-webpage
if (interactive() && Sys.getenv("TERM_PROGRAM") == "vscode") {
    if ("httpgd" %in% .packages(all.available = TRUE)) {
        options(vsc.plot = FALSE)
        options(device = function(...) {
            httpgd::hgd(silent = TRUE)
            .vsc.browser(httpgd::hgd_url(history = FALSE), viewer = "Beside")
        })
    }
}

# Source: https://github.com/REditorSupport/vscode-R/wiki/R-Session-watcher#advanced-usage-for-self-managed-r-sessions
if (interactive()) {
    source("/root/.vscode-R/init.R")
}

# # Load renv environment automatically
# if (interactive()) {
#     # Define which environment to load
#     env_to_load <- "env_test" # Change this to the environment you want to load

#     # Check if renv is already initialized
#     if (!file.exists("renv/activate.R")) {
#         # Load the environment only if renv is not already initialized
#         lockfile <- paste0("/pkgs/renv_", env_to_load, ".lock")
#         if (file.exists(lockfile)) {
#             cat(paste0("Loading renv environment: ", env_to_load, "\n"))
#             renv::restore(lockfile = lockfile, prompt = FALSE)
#         } else {
#             cat(paste0("Warning: renv environment ", env_to_load, " not found\n"))
#         }
#     }
# }
