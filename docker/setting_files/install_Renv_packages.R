# Script pour installer les packages R dans différents environnements
#
# Ce script gère l'installation des packages R depuis différentes sources :
# - CRAN (Comprehensive R Archive Network)
# - GitHub
# - Bioconductor
#

# Installer renv si nécessaire
if (!requireNamespace("renv", quietly = TRUE)) {
    cat("Installation du package renv...\n")
    install.packages("renv", repos = Sys.getenv("CRAN_MIRROR"))
}

# Initialiser renv
cat("Initialisation de renv...\n")
renv::init(bare = TRUE)

# Environnement de base avec les packages essentiels

#
# Chaque environnement a son propre fichier renv.lock pour la reproductibilité.
#
# Sources des packages et formats d'installation :
#
# 1. CRAN (Comprehensive R Archive Network)
#    - Format : "package@version"
#    - Exemple : "dplyr@1.1.4"
#    - Source par défaut : https://cloud.r-project.org
#
# 2. GitHub
#    - Format : "user/repo@tag" ou "user/repo@branch"
#    - Exemples :
#      * "tidyverse/dplyr@v1.1.4" (version spécifique)
#      * "tidyverse/dplyr@main" (branche principale)
#    - Source : https://github.com
#
# 3. Bioconductor
#    - Format : "bioc::package"
#    - Exemple : "bioc::DESeq2"
#    - Source : https://bioconductor.org
#    - Version : 3.20 (définie dans le Dockerfile)
#
# Note : Les versions spécifiées sont recommandées pour la reproductibilité.
#        Si aucune version n'est spécifiée, la dernière version disponible sera installée.

# Fonction pour extraire le nom et la version d'un package
# Gère les différents formats : CRAN, GitHub, Bioconductor
extract_package_info <- function(pkg) {
    if (grepl("bioc::", pkg)) {
        return(list(
            name = gsub("bioc::", "", pkg),
            version = NA,
            source = "bioc"
        ))
    } else if (grepl("@", pkg)) {
        parts <- strsplit(pkg, "@")[[1]]
        if (grepl("/", parts[1])) {
            return(list(
                name = parts[1],
                version = parts[2],
                source = "github"
            ))
        } else {
            return(list(
                name = parts[1],
                version = parts[2],
                source = "cran"
            ))
        }
    } else {
        return(list(
            name = pkg,
            version = NA,
            source = "unknown"
        ))
    }
}

# Fonction pour vérifier les incompatibilités
# Affiche des messages informatifs sur les versions multiples
# renv gère automatiquement les versions multiples si nécessaire
check_compatibility <- function(pkg, installed_packages) {
    pkg_info <- extract_package_info(pkg)

    # Vérifier les dépendances si c'est un package CRAN
    if (pkg_info$source == "cran" && !is.na(pkg_info$version)) {
        tryCatch(
            {
                # Obtenir les informations du package depuis CRAN
                pkg_desc <- available.packages()[[pkg_info$name, "Depends"]]
                if (!is.null(pkg_desc)) {
                    deps <- strsplit(pkg_desc, ",")[[1]]
                    for (dep in deps) {
                        dep <- trimws(dep)
                        if (grepl("\\(", dep)) {
                            dep_name <- gsub("\\(.*\\)", "", dep)
                            dep_version <- gsub(".*\\((.*)\\)", "\\1", dep)
                            if (dep_name %in% names(installed_packages)) {
                                installed_version <- installed_packages[[dep_name]]
                                if (compareVersion(installed_version, dep_version) < 0) {
                                    cat(paste0(
                                        "ℹ️ INFO : ", pkg_info$name, " nécessite ", dep_name,
                                        " version >= ", dep_version,
                                        " mais ", installed_version, " est installé\n",
                                        "   renv gérera automatiquement les versions multiples si nécessaire\n"
                                    ))
                                }
                            }
                        }
                    }
                }
            },
            error = function(e) {
                cat(paste0("⚠️ Impossible de vérifier les dépendances pour ", pkg_info$name, "\n"))
            }
        )
    }

    # Afficher un message informatif si le package est déjà installé avec une version différente
    if (pkg_info$name %in% names(installed_packages)) {
        installed_version <- installed_packages[[pkg_info$name]]
        if (!is.na(pkg_info$version) && pkg_info$version != installed_version) {
            cat(paste0(
                "ℹ️ INFO : Le package ", pkg_info$name,
                " est déjà installé en version ", installed_version,
                " et vous installez la version ", pkg_info$version, "\n",
                "   renv gérera automatiquement les versions multiples\n"
            ))
        }
    }
}

# Fonction pour vérifier l'accessibilité d'une URL
# Utilisée pour vérifier que les miroirs CRAN et Bioconductor sont accessibles
check_url_accessibility <- function(url) {
    tryCatch(
        {
            response <- httr::HEAD(url)
            if (httr::status_code(response) == 200) {
                return(TRUE)
            } else {
                cat(paste0("✗ Le miroir ", url, " retourne le code ", httr::status_code(response), "\n"))
                return(FALSE)
            }
        },
        error = function(e) {
            cat(paste0("✗ Erreur lors de la vérification de ", url, " : ", e$message, "\n"))
            return(FALSE)
        }
    )
}

# Configurer les miroirs depuis les variables d'environnement
# Ces variables sont définies dans le Dockerfile
options(repos = c(
    CRAN = Sys.getenv("CRAN_MIRROR"),
    BioCsoft = Sys.getenv("BIOCONDUCTOR_SOFTWARE"),
    BioCann = Sys.getenv("BIOCONDUCTOR_ANNOTATION"),
    BioCexp = Sys.getenv("BIOCONDUCTOR_EXPERIMENT")
))

# Vérifier que les miroirs sont bien configurés
cat("Configuration des miroirs :\n")
cat("CRAN :", getOption("repos")["CRAN"], "\n")
cat("Bioconductor Software :", getOption("repos")["BioCsoft"], "\n")
cat("Bioconductor Annotation :", getOption("repos")["BioCann"], "\n")
cat("Bioconductor Experiment :", getOption("repos")["BioCexp"], "\n\n")

# Vérifier l'accessibilité des miroirs
cat("Vérification de l'accessibilité des miroirs...\n")

# Installer httr si nécessaire pour les vérifications
if (!requireNamespace("httr", quietly = TRUE)) {
    cat("Installation du package httr pour les vérifications...\n")
    install.packages("httr")
}

# Vérifier chaque miroir
mirrors <- list(
    CRAN = getOption("repos")["CRAN"],
    BioCsoft = getOption("repos")["BioCsoft"],
    BioCann = getOption("repos")["BioCann"],
    BioCexp = getOption("repos")["BioCexp"]
)

all_mirrors_accessible <- TRUE

for (mirror_name in names(mirrors)) {
    mirror_url <- mirrors[[mirror_name]]
    cat(paste0("Vérification de ", mirror_name, " (", mirror_url, ")... "))

    if (check_url_accessibility(mirror_url)) {
        cat("✓ Accessible\n")
    } else {
        cat("✗ Non accessible\n")
        all_mirrors_accessible <- FALSE
    }
}

if (!all_mirrors_accessible) {
    cat("\n⚠️ Certains miroirs ne sont pas accessibles. L'installation pourrait échouer.\n")
    cat("Voulez-vous continuer ? (y/n): ")
    response <- readline()
    if (tolower(response) != "y") {
        stop("Installation annulée par l'utilisateur")
    }
}

cat("\nTous les miroirs sont accessibles. Début de l'installation...\n\n")

# Fonction pour installer un package avec gestion des erreurs
# Vérifie les incompatibilités avant l'installation
# Met à jour la liste des packages installés
install_package <- function(pkg, installed_packages) {
    # Vérifier les incompatibilités avant l'installation
    check_compatibility(pkg, installed_packages)

    tryCatch(
        {
            cat(paste0("Installation de ", pkg, "...\n"))
            renv::install(pkg)
            cat(paste0("✓ ", pkg, " installé avec succès\n"))

            # Mettre à jour les packages installés
            pkg_info <- extract_package_info(pkg)
            if (!is.na(pkg_info$version)) {
                installed_packages[[pkg_info$name]] <- pkg_info$version
            }
            return(installed_packages)
        },
        error = function(e) {
            cat(paste0("✗ Erreur lors de l'installation de ", pkg, " : ", e$message, "\n"))
            return(installed_packages)
        }
    )
}

# Fonction pour installer les packages d'un environnement spécifique
# Gère 1 environnement
# Chaque environnement a ses propres packages
install_environment <- function(env_name) {
    cat(paste0("\n=== Installation de l'environnement ", env_name, " ===\n"))

    # Initialiser la liste des packages installés
    installed_packages <- list()

    if (env_name == "env_test") {
        # Définir les packages par source
        cran_packages <- c(
            # "forcats@1.0.0",
            #"dplyr@1.0.10"
            "ggplot2@3.4.4"
        )

        github_packages <- c(
            #   "tidyverse/forcats@v1.0.0"
        )

        bioc_packages <- c(
            #   "bioc::edgeR",
            #   "bioc::DESeq2"
        )

        # Vérifier si les listes sont vides
        if (length(cran_packages) == 0) {
            cat("Aucun package CRAN à installer pour", env_name, "\n")
        }
        if (length(github_packages) == 0) {
            cat("Aucun package GitHub à installer pour", env_name, "\n")
        }
        if (length(bioc_packages) == 0) {
            cat("Aucun package Bioconductor à installer pour", env_name, "\n")
        }

        # Installation par source
        cat("\nInstallation des packages CRAN...\n")
        for (pkg in cran_packages) {
            installed_packages <- install_package(pkg, installed_packages)
        }

        cat("\nInstallation des packages GitHub...\n")
        for (pkg in github_packages) {
            installed_packages <- install_package(pkg, installed_packages)
        }

        cat("\nInstallation des packages Bioconductor...\n")
        for (pkg in bioc_packages) {
            installed_packages <- install_package(pkg, installed_packages)
        }
    }
    }

    # Créer le snapshot
    cat(paste0("\nCréation du snapshot pour ", env_name, "...\n"))
    tryCatch(
        {
            renv::snapshot(lockfile = paste0("renv_", env_name, ".lock"), prompt = FALSE)
            cat(paste0("✓ Snapshot créé avec succès pour ", env_name, "\n"))
        },
        error = function(e) {
            cat(paste0("✗ Erreur lors de la création du snapshot pour ", env_name, " : ", e$message, "\n"))
        }
    )
}

# Installer les environnements
cat("=== Début de l'installation des environnements ===\n")
install_environment("env_test")
cat("\n=== Installation terminée ===\n")






        # cran_packages <- c(
        #     # Packages de base
        #     "rlang@1.1.3",
        #     "glue@1.7.0",
        #     "magrittr@2.0.3",
        #     "R6@2.5.1",
        #     # Packages de développement
        #     "usethis@2.2.2",
        #     "devtools@2.4.5",
        #     # Packages tidyverse core
        #     "dplyr@1.1.4",
        #     "ggplot2@3.4.4",
        #     # Packages de support VSCode
        #     "languageserver@0.3.16",
        #     "httpgd@2.0.2",
        #     "rmarkdown@2.27",
        #     "jsonlite@1.8.8"