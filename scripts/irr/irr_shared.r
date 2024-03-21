suppressPackageStartupMessages({
    library(dplyr)
    library(stringr)
    library(purrr)
    library(readr)
    library(tidyr)
})

DATA_DIR <- "./data/irr/"
BUILD_DIR <- "./build"
BUILD_IRR_DIR <- file.path(BUILD_DIR, "irr")
BUILD_TABLES_DIR <- file.path(BUILD_IRR_DIR, "tables")

dir.create(BUILD_TABLES_DIR, recursive = TRUE, showWarnings = FALSE)

theme_mapping <- read_csv(file.path(DATA_DIR, "theme_mapping.csv"), show_col_types = FALSE)
code_mapping <- read_csv(file.path(DATA_DIR, "code_mapping.csv"), show_col_types = FALSE)
merge_column_names <- function(df) {
    colnames(df)[1:3] <- c("timestamp", "rater_id", "item_id")
    colnames(df) <- gsub(",", "", colnames(df))
    for (col in colnames(df)) {
        if (col %in% theme_mapping$theme_title) {
            theme <- theme_mapping %>%
                filter(theme_title == col) %>%
                select(theme) %>%
                unlist()
            #
            colnames(df)[colnames(df) == col] <- theme
        }
    }

    for (curr_theme in colnames(df)) {
        if (curr_theme %in% code_mapping$theme) {
            codes <- code_mapping %>%
                filter(theme == curr_theme) %>%
                select(code, code_title)
            for (i in 1:length(codes)) {
                df[[curr_theme]] <- str_replace_all(df[[curr_theme]], codes$code_title[i], codes$code[i])
            }
        }
    }
    return(df)
}

read_irr_data <- function(rounds) {
    file_list <- list.files(DATA_DIR, full.names = TRUE) %>%
        map(basename) %>%
        map(function(x) {
            data_path <- file.path(DATA_DIR, x, "data.csv")
            if (file.exists(data_path)) {
                if (as.numeric(x) %in% rounds) {
                    data_path
                }
            }
        }) %>%
        unlist()
    file_list[!is.na(file_list)] %>% map(function(x) {
        read_csv(x, show_col_types = FALSE) %>%
            merge_column_names() %>%
            mutate(round_id = as.numeric(basename(dirname(x)))) %>%
            filter(!is.na(item_id)) %>%
            mutate(item_id = paste0(item_id, "-", round_id))
    })
}
