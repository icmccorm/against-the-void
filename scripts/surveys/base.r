suppressPackageStartupMessages({
    library(dplyr)
    library(readr)
    library(xtable)
    library(ggplot2)
    library(cowplot)
    library(extrafont)
    library(extrafontdb)
    library(stringr)
    library(purrr)
    library(tidyr)
    library(reshape2)
    library(ggpubr)
})
if(!interactive()) pdf(NULL)
loadfonts(quiet = TRUE)
options(vsc.plot = FALSE)

is.yes <- function(x) {
    return(x == "Yes")
}

positivity_choices <- c(
    "Extremely negatively",
    "Somewhat negatively",
    "Neither positively nor negatively",
    "Unsure",
    "Somewhat positively",
    "Extremely positively"
)

frequency_choices <- c(
    "Never",
    "Sometimes",
    "About half the time",
    "Most of the time",
    "Always"
)

frequency_choices_unsure <- c(
    "Never",
    "Sometimes",
    "Unsure",
    "About half the time",
    "Most of the time",
    "Always"
)

agreement_choices <- c(
    "Strongly disagree",
    "Somewhat disagree",
    "Neither agree nor disagree",
    "Somewhat agree",
    "Strongly agree"
)

age_choices <- c(
    "18-29",
    "30-39",
    "40-49",
    "50-59",
    "Prefer not to answer"
)
gender_choices <- c(
    "Non-binary",
    "Woman",
    "Man",
    "Prefer to self-describe",
    "Prefer not to disclose"
)

affiliation_choices <- c(
    "Academia",
    "Industry",
    "Open-source contributor",
    "Rust project member",
    "Other"
)

education_choices <- c(
    "Some high school",
    "High school diploma/GED",
    "Some college",
    "Bachelor's degree",
    "Master's degree",
    "PhD",
    "Prefer not to answer"
)

yes_no_binary_choices <- c(
    "Yes",
    "No"
)

difficulty_choices <- c(
    "Extremely difficult",
    "Somewhat difficult",
    "Neither easy nor difficult",
    "Somewhat easy",
    "Extremely easy"
)

yes_no_choices <- c(
    "Definitely not",
    "Probably not",
    "Might or might not",
    "Probably yes",
    "Definitely yes"
)

date_frequency_choices <- c(
    "Daily",
    "Weekly",
    "Monthly",
    "Yearly",
    "Less than once a year",
    "Never"
)

likely_unlikely_choices <- c(
    "Extremely unlikely",
    "Somewhat unlikely",
    "Neither likely nor unlikely",
    "Somewhat likely",
    "Extremely likely"
)

options(dplyr.summarise.inform = FALSE)

survey_raw <- read_csv(file.path("./data/community_survey/data.csv"), show_col_types = FALSE)

# add a respondent ID column
survey_raw <- survey_raw %>%
    mutate(response_id = row_number())
screening_survey_path <- file.path("./data/screening_survey/data.csv")
screening_raw <- read_csv(
    screening_survey_path,
    show_col_types = FALSE
)
sections <- read_csv(file.path("./data/community_survey/sections.csv"), show_col_types = FALSE)
screening_eligible <- screening_raw %>%
    filter(
        is.yes(CQ1),
        is.yes(CQ2),
        is.yes(CQ3),
        is.yes(EQ1),
        is.yes(EQ2),
        Finished == TRUE,
        Progress == 100
    ) %>%
    mutate(EndDate = as.Date(EndDate, format = "%m/%d/%Y")) %>%
    filter(EndDate <= as.Date("2018-05-25"))

screening <- screening_eligible %>%
    filter(!is.na(ID)) %>%
    filter(!is.na(PID))


questions <- read_csv(file.path("./data/community_survey/questions.csv"), show_col_types = FALSE)

survey_complete_and_elligible <- survey_raw %>%
    filter(Finished == TRUE) %>%
    filter(is.yes(CQ1)) %>%
    filter(is.yes(CQ2)) %>%
    filter(is.yes(CQ3)) %>%
    filter(!is.na(ELQ2)) %>%
    filter(is.yes(ELQ2)) %>%
    filter(!is.na(ELQ1)) %>%
    filter(trimws(ELQ1) != "") %>%
    mutate(ELQ1 = as.numeric(ELQ1)) %>%
    filter(ELQ1 >= 1) %>%
    filter(DistributionChannel == "anonymous") 
    
survey <- survey_complete_and_elligible %>%
    filter(Q_RecaptchaScore >= 0.5) %>%
    filter(is.na(Q_RelevantIDDuplicate)) %>%
    filter(Q_RelevantIDDuplicateScore < 75) %>%
    filter(Q_RelevantIDFraudScore < 30)

years <- survey %>%
    select(response_id, ELQ1, BQ2, BQ3) %>%
    pivot_longer(cols = c("ELQ1", "BQ2", "BQ3"), names_to = "language", values_to = "value")

years <- years %>%
    group_by(language) %>%
    summarise(
        mean = mean(value),
        min = min(value),
        max = max(value),
        stdev = sd(value)
    ) %>%
    ungroup()
years$language <- ifelse(years$language == "BQ2", "C", years$language)
years$language <- ifelse(years$language == "BQ3", "C++", years$language)
years$language <- ifelse(years$language == "ELQ1", "Rust", years$language)
# column names to title

colnames(years) <- c("Language", "Mean", "Min", "Max", "Stdev")
survey_pivot <- survey
survey <- survey %>%
    pivot_longer(
        !response_id,
        names_to = "question_id",
        values_to = "value",
        values_transform = as.character
    )

survey <- survey %>%
    separate_rows(value, sep = ",") %>%
    mutate(value = trimws(value)) %>%
    filter(value != "") %>%
    filter(!is.na(question_id)) %>%
    mutate(value = ifelse(is.na(value), "N/A", value))

# - HELPER FUNCTIONS -

compute_num_responses <- function(population) {
    result <- survey %>%
        inner_join(population, by = c("response_id")) %>%
        group_by(question_id) %>%
        summarise(total_num_responses = n()) %>%
        ungroup()
    return(result)
}
all <- survey %>%
    select(response_id) %>%
    unique()
num_responses_per_question <- compute_num_responses(all)

compute_frequency <- function(population) {
    result <- survey %>%
        inner_join(population, by = c("response_id")) %>%
        group_by(question_id, value) %>%
        summarise(num_responses = n())
    return(result)
}
frequency <- compute_frequency(all) %>%
    inner_join(num_responses_per_question, by = c("question_id")) %>%
    mutate(percentage = round(num_responses / total_num_responses * 100, 1)) %>%
    select(question_id, value, percentage, num_responses, total_num_responses)


# — HELPER FUNCTIONS —

ensure_choices <- function(df, choices) {
    response_col <- match("value", names(df))

    cols_to_zero <- (response_col + 1):ncol(df)

    missing_choices <- setdiff(choices, df$value)

    # If there are missing choices, set the corresponding columns to zero
    if (length(missing_choices) > 0) {
        for (choice in missing_choices) {
            df <- df %>%
                add_row(value = choice) %>%
                mutate_at(cols_to_zero, ~ ifelse(is.na(.), 0, .))
        }
    }
    return(df)
}

compute_likert_frequency <- function(selected_questions, choices) {
    computation <- questions %>%
        filter(question_id %in% selected_questions) %>%
        inner_join(frequency, by = c("question_id")) %>%
        mutate(question = paste0(question_id, " - ", question)) %>%
        select(-question_id) %>%
        group_by(question) %>%
        group_modify(~ ensure_choices(., choices)) %>%
        ungroup() %>%
        pivot_wider(id_cols = question, names_from = value, values_from = percentage) %>%
        select(question, all_of(choices))
    return(computation)
}


compute_category_frequency <- function(selected_question) {
    computation <- questions %>%
        filter(question_id %in% c(selected_question)) %>%
        inner_join(frequency, by = c("question_id")) %>%
        select(-question, -question_id, -num_responses, -total_num_responses) %>%
        rename(
            All = percentage
        ) %>%
        melt(id.vars = "value")

    # for each group, order the 'category' column by choices
    colnames(computation) <- c("category", "group", "value")
    computation
}

plot_likert_bars <- function(df, width, height, path, ..., center = NA, palette = "RdYlBu", hide_questions = FALSE, width_scale = 0.9, cutoff = 5, extract_legend = NA, legend_width = width, legend_height = 1, hide_legend = FALSE, wrap_legend = FALSE) {
    # get all column names except for the first one
    options <- colnames(df)[2:length(colnames(df))]
    if (is.na(center)) {
        # get the middle option, if the length is noneven
        # otherwise, stop
        if (length(options) %% 2 == 1) {
            center <- options[[ceiling(length(options) / 2)]]
        }
    }
    df <- df %>%
        melt(id.vars = "question") %>%
        mutate(
            variable = factor(variable, levels = options, ordered = TRUE),
            value = if_else(variable == center, value / 2, value)
        )
    df$value <- round(df$value, 1)
    if("Linux Libertine Display" %in% fonts()) {
        default_text <- element_text(size = 8, family = "Linux Libertine Display", color = "#000000")
    } else {
        default_text <- element_text(size = 10, color = "#000000")
    }
    negative_labels <- options[1:ceiling(length(options) / 2)]
    negative_data <- filter(df, variable %in% negative_labels)

    positive_labels <- options[ceiling(length(options) / 2):length(options)]
    positive_data <- filter(df, variable %in% positive_labels)

    likert_plot <- ggplot(data = df, aes(question, value, fill = variable)) +
        geom_col(
            data = positive_data,
            position = position_stack(reverse = T),
            width = width_scale,
        ) +
        geom_col(
            data = negative_data,
            aes(y = -value),
            width = width_scale
        ) +
        labs(
            x = element_blank(),
            y = "% of Respondents",
            fill = element_blank(),
            axis.title = default_text,
            axis.text = default_text,
            axis.ticks = element_line(color = "black"),
        ) +
        coord_flip() +
        theme(text = default_text) +
        scale_y_continuous(labels = abs) +
        scale_fill_brewer(palette = palette, drop = FALSE) +
        theme(
            panel.grid.major = element_blank(),
            panel.grid.minor = element_blank(),
            panel.background = element_blank(),
            legend.key.size = unit(0.75, "line"),
            legend.text = default_text,
            axis.title = default_text,
            axis.text = default_text,
            axis.ticks.y = element_blank()
        ) +
        geom_hline(yintercept = 0, colour = "black")

    if (wrap_legend) {
        likert_plot <- likert_plot + theme(plot.margin = unit(
            c(0, 0, 0, 0),
            "inches"
        ), legend.position = "bottom", legend.margin = margin()) +
            guides(fill = guide_legend(ncol = 2, byrow = FALSE))
    } else {
        likert_plot <- likert_plot + theme(plot.margin = unit(
            c(0, 0, 0, 0),
            "inches"
        ), legend.position = "bottom", legend.direction = "horizontal", legend.margin = margin()) +
            guides(fill = guide_legend(nrow = 1, byrow = TRUE))
    }
    if (hide_questions) {
        likert_plot <- likert_plot + theme(axis.text.y = element_blank(), axis.title.y = element_blank(), axis.ticks.y = element_blank())
    }
    if (!is.na(extract_legend)) {
        legend_plot <- as_ggplot(get_legend(likert_plot))
        ggsave(plot = legend_plot, file = extract_legend, width = legend_width, height = legend_height, dpi = 300)
    }
    if (hide_legend | !is.na(extract_legend)) {
        likert_plot <- likert_plot + theme(legend.position = "none")
    }
    ggsave(plot = likert_plot, file = path, width = width, height = height, dpi = 300)
    return(likert_plot)
}

plot_bars <- function(df, ylab, title, width, height, ..., cutoff = 1, label_size = 4, disable_order = FALSE) {
    if (disable_order) {
        initial_plot <- ggplot(data = df, aes(y = value, x = category), width = width, height = height)
    } else {
        initial_plot <- ggplot(data = df, aes(y = value, x = reorder(category, value)), width = width, height = height)
    }
    initial_plot +
        geom_bar(position = "dodge", stat = "identity", fill = "#674ea7") +
        labs(
            x = element_blank(),
            y = ylab,
            fill = "Population",
            title = title
        ) +
        coord_flip() +
        theme_minimal(base_size = 18) +
        theme(text = element_text(color = "#000000"), axis.text = element_text(size = 8)) +
        geom_text(data = subset(df, value >= cutoff), aes(label = value), vjust = 0.5, hjust = 1.5, colour = "white", size = label_size)
}
