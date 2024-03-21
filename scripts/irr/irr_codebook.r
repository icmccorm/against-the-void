suppressPackageStartupMessages({
    library(dplyr)
    library(readr)
    library(purrr)
    library(stringr)
})
options(dplyr.summarise.inform = FALSE)
source("./scripts/irr/irr_shared.r")

BUILD_APPENDIX_DIR <- file.path(BUILD_TABLES_DIR, "appendix")
if (!dir.exists(BUILD_APPENDIX_DIR)) {
    dir.create(BUILD_APPENDIX_DIR)
}

theme_mapping <- read_csv(file.path("irr", "theme_mapping.csv"), show_col_types = FALSE)
surveys <- list.files(DATA_DIR, pattern = "^[0-9]+", full.names = TRUE) %>%
    map(~ read_csv(file.path(.x, "survey.csv"), col_types = c("c", "c", "n")) %>%
        mutate(round = as.numeric(basename(.x))) %>% rename(theme_title = question_title)) %>%
    bind_rows() %>%
    full_join(theme_mapping, by = c("theme_title"))

format_table_csv <- function(df, curr_theme, format_response=NA) {
    values <- df %>% filter(theme == curr_theme) %>%
        select(response_text, round) %>%
        unique()
    if(!is.na(format_response)) {
        values <- values %>%
            mutate(response_text = format_response(response_text))
    }
    values %>%
        group_by(response_text) %>%
        arrange(round) %>%
        summarize(rounds = paste0(round, collapse = ", ")) %>%
        arrange(response_text) %>%
        select(rounds, response_text) %>%
        group_by(rounds) %>%
        summarize(response_text = paste0(response_text, collapse = ", ")) %>%
        write_csv(file.path(BUILD_APPENDIX_DIR, paste0(str_to_lower(curr_theme), ".csv")))
}

surveys %>%
    select(theme, theme_title, round) %>%
    unique() %>%
    group_by(theme, theme_title) %>%
    arrange(desc(round)) %>%
    summarize(round = paste0(round, collapse = ", ")) %>%
    rename(`Theme` = theme, `Title` = theme_title, `Rounds` = round) %>%
    write_csv(file.path(BUILD_APPENDIX_DIR, "themes.csv"))



for (theme in unique(surveys$theme)) {
    print(theme)
    format_table_csv(surveys, theme)
}
