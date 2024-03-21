suppressPackageStartupMessages({
    library(dplyr)
    library(readr)
    library(tidyr)
    library(purrr)
    library(irr)
    library(xtable)
})

source("./scripts/irr/irr_shared.r")
data_files <- read_irr_data(c(1, 2, 3, 4, 5))

common_columns <- data_files %>%
    map(colnames) %>%
    reduce(intersect)
data <- data_files %>% bind_rows()

colnames(data)[1:2] <- c("timestamp", "rater_id")

questions <- data %>%
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

data <- data %>%
    pivot_longer(
        cols = -c("timestamp", "rater_id", "item_id", "round_id"),
        names_to = "question_text",
        values_to = "response_text"
    ) %>%
    unique()

data$response_text <- ifelse(is.na(data$response_text), "N/A", data$response_text)

counts_not_na_overall <- data %>%
    inner_join(questions, by = c("question_text", "response_text")) %>%
    group_by(question_text) %>%
    filter(all(response_text == "N/A")) %>%
    ungroup() %>%
    select(question_text) %>%
    unique()

counts_not_na_per_round <- data %>%
    inner_join(questions, by = c("question_text", "response_text")) %>%
    group_by(round_id, question_text) %>%
    filter(all(response_text == "N/A")) %>%
    ungroup() %>%
    select(round_id, question_text) %>%
    unique()

data <- data %>%
    inner_join(questions, by = c("question_text", "response_text")) %>%
    select(-question_text, -timestamp, -response_text) %>%
    unique()

alpha <- data %>%
    split(data$question_id) %>%
    map(function(x) {
        question_id <- unique(x$question_id)
        x <- x %>% select(-question_id, -round_id)
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

# replace the alpha value with a ? for questions appearing in the counts_not_na_overall table
alpha <- alpha %>%
    mutate(alpha = ifelse(question_text %in% counts_not_na_overall$question_text, "?", alpha))

alpha_per_round <- data %>%
    split(data$round_id) %>%
    map(function(x) {
        x %>%
            split(x$question_id) %>%
            map(function(x) {
                round_id <- unique(x$round_id)
                question_id <- unique(x$question_id)
                x <- x %>% select(-round_id, -question_id)
                x <- pivot_wider(x, names_from = "item_id", values_from = "response_id")
                alpha_matrix <- x %>%
                    select(-rater_id) %>%
                    as.matrix()
                alpha <- kripp.alpha(alpha_matrix, method = "nominal")$value
                data.frame(
                    round_id = round_id,
                    question_id = question_id,
                    alpha = alpha
                )
            }) %>%
            bind_rows()
    }) %>%
    bind_rows() %>%
    inner_join(questions, by = "question_id", relationship = "many-to-many") %>%
    arrange(round_id, question_id) %>%
    select(round_id, question_text, alpha) %>%
    unique() %>%
    arrange(-alpha)
# keep rows where the question_text, for any round, had an alpha between 0.8 and 1
alpha_unresolved <- alpha_per_round %>%
    group_by(question_text) %>%
    filter(all(alpha < 0.8 | alpha == 1) & any(alpha < 0.8)) %>%
    ungroup() %>%
    select(question_text) %>%
    unique()

alpha_per_round$alpha <- as.character(round(alpha_per_round$alpha, 2))

valid_alpha <- alpha_per_round %>% anti_join(counts_not_na_per_round, by = join_by(round_id, question_text))
alpha_per_round <- alpha_per_round %>%
    inner_join(counts_not_na_per_round, by = c("round_id", "question_text")) %>%
    mutate(alpha = "?") %>%
    unique() %>%
    bind_rows(valid_alpha) %>%
    arrange(round_id, question_text)

# write the data to a csv file
table <- alpha_per_round %>%
    pivot_wider(names_from = "round_id", values_from = "alpha") %>%
    arrange(question_text) %>%
    inner_join(alpha, by = c("question_text")) %>%
    arrange(desc(alpha))

colnames(table)[1] <- "Coding Category"
colnames(table)[ncol(table)] <- "Cumulative"
print(xtable(table, type = "latex"), file = file.path(BUILD_TABLES_DIR, "irr_small.tex"), include.rownames = FALSE)
min_round_id <- min(alpha_per_round$round_id)
max_round_id <- max(alpha_per_round$round_id)
colnames(alpha)[1] <- "Coding Category"
colnames(alpha)[2] <- paste0(min_round_id, "-", max_round_id)
write_csv(alpha, file.path(BUILD_DIR, "alpha_1_5.csv"))