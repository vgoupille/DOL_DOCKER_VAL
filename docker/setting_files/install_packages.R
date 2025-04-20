# ---- Description
# This file installs the required R packages on the Docker image during the build time.
# The list of packages and their versions is set on the packages.json file
# ---- Dependencies
# To parse the json jq must be installed on the docker image.
# See: https://stedolan.github.io/jq/
# ---- Code starts here

setwd("./pkgs/")

# Get CRAN mirror from environment variable
cran_mirror <- Sys.getenv("CRAN_MIRROR", "https://cran.rstudio.com/")

# Required the remotes package
install.packages("remotes", repos = cran_mirror)

#---- Load list of packages
# Set the jq query
jq_command <- 'jq -r ".packages[] |  [.package, .version] | @tsv" packages.json'

# Parse the json file with the list of package
raw <- system(command = jq_command, intern = TRUE)

package_list <- lapply(raw, function(i) {
  x <- unlist(strsplit(x = i, split = "\t"))
  data.frame(package = x[1], version = x[2], stringsAsFactors = FALSE)
})

# Transform the list into a data.frame
packages_df <- as.data.frame(t(matrix(unlist(package_list), nrow = 2)),
  stringsAsFactors = FALSE
)
names(packages_df) <- c("package", "version")
packages_df$success <- FALSE

# ---- Install the packages
for (i in 1:nrow(packages_df)) {
  if (!packages_df$package[i] %in% rownames(installed.packages()) ||
    (packages_df$package[i] %in% rownames(installed.packages()) &&
      packageVersion(packages_df$package[i]) != packages_df$version[i])) {
    cat("\033[0;92m", paste("Installing", packages_df$package[i]), "\033[0m\n", sep = "")

    remotes::install_version(
      package = packages_df$package[i],
      version = packages_df$version[i],
      dependencies = c("Depends", "Imports"),
      upgrade = FALSE,
      verbose = FALSE,
      quiet = FALSE,
      repos = cran_mirror
    )
  }

  if (!packages_df$package[i] %in% rownames(installed.packages()) ||
    (packages_df$package[i] %in% rownames(installed.packages()) &&
      packageVersion(packages_df$package[i]) != packages_df$version[i])) {
    packages_df$success[i] <- FALSE
  } else {
    packages_df$success[i] <- TRUE
  }
}

for (i in 1:nrow(packages_df)) {
  if (packages_df$success[i]) {
    cat("\033[0;92m", packages_df$package[i], "...OK", "\033[0m\n")
  } else {
    cat("\033[0;91m", packages_df$package[i], "...Fail", "\033[0m\n")
  }
}

if (!all(packages_df$success)) {
  stop("One or more packages failed to install...")
}
