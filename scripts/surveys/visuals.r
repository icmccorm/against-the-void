source("./scripts/surveys/base.r")
result_dir <- file.path("./build/figures/")
legend_dir <- file.path(result_dir, "legends")
figure_tables <- file.path(result_dir, "tables")


unlink(result_dir)
survey %>% select(response_id) %>% unique() %>% nrow()
if (!dir.exists(result_dir)) {
  dir.create(result_dir, recursive = TRUE)
  dir.create(legend_dir, recursive = TRUE)
}

if (!dir.exists(legend_dir)) {
  dir.create(legend_dir, recursive = TRUE)
}

if (!dir.exists(figure_tables)) {
  dir.create(figure_tables, recursive = TRUE)
}

to_table <- function (df) {
    df <- df %>% select(type, rq, question, figure)
    vtype <- unique(df$type)[[1]]
    rq <- unique(df$rq)[[1]]
    out_path <- file.path(figure_tables, paste0(vtype,"_",rq,".tex"))
    xt <- df %>%
        ungroup() %>%
        select(question, figure) %>%
        xtable()
    print(xt,
      file = out_path,
      sanitize.text.function = identity,
      include.rownames = FALSE
    )
}

yn_frequency <- FREQ_ALL %>% 
    inner_join(questions, by = c("question_id")) %>% 
    filter(!is.na(type)) %>%
    filter(type == "yn" | type == "ynu") %>%
    select(rq, question, question_id, value, percentage, total_num_responses) %>%
    # expand value into columns using percentage as values
    pivot_wider(names_from = value, values_from = percentage) %>%
    arrange(rq)

PLOT_CONFIG <- list(
    list(
        type = "freq",
        choices = frequency_choices,
        center = frequency_neutral
    ),
    list(
        type = "freq_unsure",
        choices = frequency_choices_unsure,
        center = frequency_unsure_neutral
    ),
    list(
        type = "yes_no_grad",
        choices = yes_no_choices,
        center = c()
    ),
    list(
        type = "freq_time",
        choices = date_frequency_choices,
        center = c()
    )
)

plots <- PLOT_CONFIG %>% 
    lapply(function(config) {
        questions %>% 
            filter(type == config$type) %>% 
            pmap(function(rq, type, optional, gated_by, question_id, question) {
                plot_id <- paste0(rq, "_", question_id)
                total_num_responses <- 1
                df <- compute_likert_frequency(FREQ_ALL, question_id, config$choices)
                labels <- plot_likert_bar(
                    df = df,
                    total_num_responses = total_num_responses,
                    options = config$choices,
                    path = file.path(result_dir, paste0(plot_id, ".pdf")),
                    center = config$center,
                    extract_legend = file.path(legend_dir, paste0("legend_", type, ".pdf"))
                )
                data.frame(
                    rq = rq,
                    type = type,
                    question = question,
                    figure = paste0("\\plotbar{figures/",
                        plot_id, 
                        "}{", labels[[1]],
                        "}{", labels[[2]],
                        "}{", labels[[3]],
                        "}"
                    )
                )
           }) %>%
        bind_rows()
    }) %>%
    bind_rows() %>%
    group_by(type, rq) %>%
    group_split() %>%
    lapply(to_table)

respondents_who_used_miri <- survey %>%
    filter(question_id == "VQ2" & value == "Miri") %>%
    select(response_id) %>%
    unique()
total_num_responses <- respondents_who_used_miri %>% nrow()
miri_frequency <- compute_frequency(respondents_who_used_miri)
miri_likert_frequency <- compute_likert_frequency(miri_frequency, "VQ6", frequency_choices)
labels <- plot_likert_bar(
    df = miri_likert_frequency,
    total_num_responses = total_num_responses,
    options = frequency_choices,
    path = file.path(result_dir, "miri_VQ6.pdf"),
    center = frequency_neutral
)