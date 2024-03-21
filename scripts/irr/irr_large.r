suppressPackageStartupMessages({
    library(dplyr)
    library(readr)
    library(purrr)
    library(irr)
    library(tidyr)
    library(xtable)
})
options(dplyr.summarise.inform = FALSE)
source("./scripts/irr/irr_shared.r")
data_files <- read_irr_data(c(6, 7))

compute_irr <- function(df) {
    round_id <- df$round_id[1]
    questions <- df %>%
        select(-rater_id, -timestamp, -item_id, -round_id) %>%
        gather(question_text, response_text) %>%
        unique()
    questions$response_text <- ifelse(is.na(questions$response_text), "N/A", questions$response_text)
    questions <- questions %>%
        group_by(question_text, response_text) %>%
        unique() %>%
        ungroup() %>%
        ungroup() %>%
        group_by(question_text) %>%
        mutate(question_id = cur_group_id()) %>%
        ungroup() %>%
        mutate(response_id = row_number())

    df <- df %>% select(-round_id) %>%
        pivot_longer(
            cols = -c("timestamp", "rater_id", "item_id"),
            names_to = "question_text",
            values_to = "response_text"
        ) %>%
        unique()

    df$response_text <- ifelse(is.na(df$response_text), "N/A", df$response_text)

    counts_not_na_overall <- df %>%
        inner_join(questions, by = c("question_text", "response_text")) %>%
        group_by(question_text) %>%
        filter(all(response_text == "N/A")) %>%
        ungroup() %>%
        select(question_text) %>%
        unique()

    df <- df %>%
        inner_join(questions, by = c("question_text", "response_text")) %>%
        select(-question_text, -timestamp, -response_text) %>%
        unique()
    alpha <- df %>%
        split(df$question_id) %>%
        map(function(x) {
            question_id <- unique(x$question_id)
            x <- x %>% select(-question_id)
            x <- pivot_wider(x, names_from = "item_id", values_from = "response_id")
            alpha_matrix <- x %>%
                select(-rater_id) %>%
                as.matrix()
            alpha <- kripp.alpha(alpha_matrix, method = "nominal")$value
            data.frame(question_id = question_id, alpha = alpha)
        }) %>%
        bind_rows() %>%
        inner_join(questions, by = "question_id") %>%
        arrange(question_id) %>%
        select(question_text, alpha) %>%
        unique() %>%
        arrange(-alpha)
    alpha$alpha <- round(alpha$alpha, 2)
    alpha <- alpha %>%
        mutate(alpha = ifelse(question_text %in% counts_not_na_overall$question_text, "?", alpha))
    colnames(alpha)[1] <- "Coding Category"
    colnames(alpha)[2] <- round_id
    alpha
}
data_files %>%
    map(compute_irr) %>%
    reduce(function(x, y) {
        full_join(x, y, by = "Coding Category")
    }) %>%
    arrange_at(vars(-"Coding Category"), ~ is.na(.)) %>%
    write_csv(file.path(BUILD_DIR, "alpha_6_7.csv"))
