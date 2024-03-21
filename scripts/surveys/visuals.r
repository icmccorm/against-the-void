source("./scripts/surveys/base.r")
result_dir <- file.path("./build/figures/")
legend_dir <- file.path(result_dir, "legends")
unlink(result_dir)
if (!dir.exists(result_dir)) {
    dir.create(result_dir, recursive = TRUE)
    dir.create(legend_dir, recursive = TRUE)
}
if (!dir.exists(legend_dir)) {
    dir.create(legend_dir, recursive = TRUE)
}

# ————DEMOGRAPHICS————

demo_age <- compute_category_frequency("DQ1") %>%
    filter(group == "All") %>%
    plot_bars("% of Respondents", "Age", 3, 2, cutoff = 5, label_size = 3, disable_order = TRUE)
demo_education <- compute_category_frequency("DQ2") %>%
    filter(group == "All") %>%
    plot_bars("% of Respondents", "Education", 3, 3, cutoff = 5, label_size = 3, disable_order = TRUE)
demo_gender <- compute_category_frequency("DQ3") %>%
    filter(group == "All") %>%
    plot_bars("% of Respondents", "Gender", 3, 3, cutoff = 5, label_size = 3)
demo_affiliation <- compute_category_frequency("DQ4") %>%
    filter(group == "All") %>%
    plot_bars("% of Respondents", "Affiliation", 3, 3, cutoff = 5, label_size = 3)

demo_grid <- plot_grid(
    demo_education + theme(legend.position = "none"),
    demo_age + theme(legend.position = "none"),
    demo_gender + theme(legend.position = "none"),
    demo_affiliation + theme(legend.position = "none"),
    ncol = 2,
    align = "vh"
)
demo_legend <- get_legend(
    demo_education +
        guides(color = guide_legend(nrow = 1)) +
        theme(
            legend.position = "bottom",
        )
)
demo <- plot_grid(demo_grid, demo_legend, ncol = 1, rel_heights = c(1, .1))
ggsave(plot = demo, file = file.path(result_dir, "demo.pdf"), width = 10, height = 5, dpi = 300)

# ————RQ1————

compute_domain <- function(dmq) {
    domain_all <- questions %>%
        filter(question_id %in% c(dmq)) %>%
        inner_join(frequency, by = c("question_id")) %>%
        select(value, percentage)
    colnames(domain_all) <- c("domain", "percentage")
    return(domain_all)
}
all <- compute_domain("DMQ1")
rust <- compute_domain("DMQ2")

colnames(rust) <- c("domain", "percentage_rust")

domain <- all %>%
    full_join(rust, by = c("domain")) %>%
    mutate_at(vars(matches("percentage.*")), ~ ifelse(is.na(.), 0, .))

domain_rust <- domain %>%
    select(domain, percentage_rust) %>%
    pivot_longer(cols = c("percentage_rust"), names_to = "group", values_to = "percentage") %>%
    mutate(language = "Rust") %>%
    mutate(group = ifelse(grepl("inner", group), "Frequent Users", "All"))

domain_all <- domain %>%
    select(domain, percentage) %>%
    pivot_longer(cols = c("percentage"), names_to = "group", values_to = "value") %>%
    rename(category = domain) %>%
    mutate(group = ifelse(grepl("inner", group), "Frequent Users", "All"))

domain_plot <- domain_all %>%
    mutate_at(vars(category), ~ ifelse(grepl("level primitives", .), "Data structures & language-level primitives", .)) %>%
    ggplot(aes(y = value, x = reorder(category, value)), width = 3, height = 4) +
    geom_bar(position = "dodge", stat = "identity") +
    labs(x = element_blank(), y = "% of Respondents", fill = "Population", title = "Application Domain") +
    coord_flip()
ggsave(plot = domain_plot, file = file.path(result_dir, "rq1_domain.pdf"), width = 8, height = 3, dpi = 300)

difficulty_legend <- compute_likert_frequency("DMQ6", difficulty_choices) %>%
    mutate_at(vars(question), ~ ifelse(grepl("was it easy or difficult", .), "Experience with the Borrow Checker", .)) %>%
    plot_likert_bars(
        3.5,
        0.5,
        file.path(result_dir, "rq1_ease_of_use.pdf"),
        hide_questions = TRUE,
        hide_legend = TRUE,
        cutoff = 0,
        extract_legend = file.path(legend_dir, "legend_difficulty.pdf"),
        legend_height = 0.5,
        legend_width = 9
    )

# ————RQ2————
compute_likert_frequency(c("WUNQ2"), frequency_choices_unsure) %>%
    plot_likert_bars(
        3.5,
        0.5,
        file.path(result_dir, "rq2_certainty.pdf"),
        hide_questions = TRUE,
        hide_legend = TRUE,
        extract_legend = file.path(legend_dir, "legend_frequency_unsure_wrapped.pdf"),
        legend_height = 1,
        legend_width = 3,
        wrap_legend = TRUE,
        center = "Unsure",
        cutoff = 0
    )
compute_likert_frequency(c("WUPQ3"), frequency_choices) %>%
    plot_likert_bars(
        3.5,
        0.5,
        file.path(result_dir, "rq2_profiling.pdf"),
        hide_questions = TRUE,
        hide_legend = TRUE,
        cutoff = 0,
    )

# ————RQ3————
compute_likert_frequency(c("ESAQ1", "EUAIQ2"), frequency_choices) %>%
    mutate_at(vars(question), ~ ifelse(grepl("ESAQ1", .), "Safe API", .)) %>%
    mutate_at(vars(question), ~ ifelse(grepl("EUAIQ2", .), "Unsafe API", .)) %>%
    plot_likert_bars(
        3.5,
        0.75,
        hide_legend = TRUE,
        file.path(result_dir, "rq3_runtime_checks.pdf"),
    )


compute_likert_frequency(c("ESAQ2"), frequency_choices) %>%
    mutate_at(vars(question), ~ ifelse(grepl("ESAQ2", .), "Safe API", .)) %>%
    plot_likert_bars(
        3.5,
        0.5,
        file.path(result_dir, "rq2_safe_preconditions.pdf"),
        hide_questions = TRUE,
        hide_legend = TRUE,
        cutoff = 0,
    )
compute_likert_frequency(c("EUAQ2", "EUAIQ1", "ESAQ2"), frequency_choices) %>%
    mutate_at(vars(question), ~ ifelse(grepl("ESAQ2", .), "Safe API, satisfied reqs.", .)) %>%
    mutate_at(vars(question), ~ ifelse(grepl("EUAQ2", .), "Unsafe API, had reqs.", .)) %>%
    mutate_at(vars(question), ~ ifelse(grepl("EUAIQ1", .), "Unsafe API, documented reqs.", .)) %>%
    plot_likert_bars(
        3.5,
        1,
        file.path(result_dir, "rq3_preconditions.pdf"),
        hide_questions = FALSE,
        hide_legend = TRUE,
        cutoff = 0,
    )

compute_likert_frequency(c("LMUQ3", "LMUQ4"), frequency_choices) %>%
    mutate_at(vars(question), ~ ifelse(grepl("LMUQ3", .), "Refactored", .)) %>%
    mutate_at(vars(question), ~ ifelse(grepl("LMUQ4", .), "Avoided", .)) %>%
    plot_likert_bars(
        3.5,
        0.75,
        file.path(result_dir, "rq3_minimal.pdf"),
        cutoff = 10,
        extract_legend = file.path(legend_dir, "legend_frequency.pdf"),
        legend_width = 8,
        legend_height = 0.5,
    )

difficulty_legend <- compute_likert_frequency(c("LMUQ1"), difficulty_choices) %>%
    plot_likert_bars(
        3.5,
        0.5,
        file.path(result_dir, "rq3_arbitrary.pdf"),
        hide_questions = TRUE,
        wrap_legend = TRUE,
        extract_legend = file.path(legend_dir, "legend_difficulty_wrapped.pdf"),
        legend_height = 1,
        legend_width = 3,
    )


agreement_legend <- compute_likert_frequency(c("CCQ5"), agreement_choices) %>%
    plot_likert_bars(
        3.5,
        0.5,
        file.path(result_dir, "rq3_docs_correctness.pdf"),
        hide_questions = TRUE,
        extract_legend = file.path(legend_dir, "legend_agreement.pdf"),
        legend_width = 8,
        legend_height = 0.5
    )

# ————RQ4————

compute_likert_frequency(c("FFIBQ3", "FFIBQ4"), yes_no_choices) %>%
    mutate_at(vars(question), ~ ifelse(grepl("FFIBQ3", .), "Hand-written", .)) %>%
    mutate_at(vars(question), ~ ifelse(grepl("FFIBQ4", .), "Generated", .)) %>%
    plot_likert_bars(
        3.5,
        0.75,
        hide_legend = TRUE,
        file.path(result_dir, "rq4_foreign_binding_trust.pdf"),
        extract_legend = file.path(legend_dir, "legend_yes_no.pdf"),
        legend_height = 0.5,
        legend_width = 8,
    )

compute_likert_frequency(c("FFIMMQ6", "FFIMMQ7"), frequency_choices_unsure) %>%
    mutate_at(vars(question), ~ ifelse(grepl("abstract data types", .), "ADTs by value", .)) %>%
    mutate_at(vars(question), ~ ifelse(grepl("raw pointers to memory", .), "Pointers to refs.", .)) %>%
    plot_likert_bars(
        3.5,
        0.75,
        center = "Unsure",
        cutoff = 10,
        hide_legend = TRUE,
        file.path(result_dir, "rq4_frequency_unsure.pdf"),
        extract_legend = file.path(legend_dir, "legend_frequency_unsure.pdf"),
        legend_width = 8,
        legend_height = 0.5
    )

# ————RQ5————

compute_likert_frequency(c("VQ7", "VQ6", "VMQ2"), frequency_choices) %>%
    mutate_at(vars(question), ~ ifelse(grepl("VQ6", .), "Write tests", .)) %>%
    mutate_at(vars(question), ~ ifelse(grepl("VQ7", .), "Audit dependencies", .)) %>%
    mutate_at(vars(question), ~ ifelse(grepl("VMQ2", .), "Run in Miri", .)) %>%
    plot_likert_bars(
        3.5,
        0.75,
        file.path(result_dir, "rq5_frequency.pdf"),
        hide_legend = TRUE,
        wrap_legend = TRUE,
        extract_legend = file.path(legend_dir, "legend_frequency_wrapped.pdf"),
    )
compute_likert_frequency(c("VMQ2", "VQ6"), frequency_choices) %>%
    mutate_at(vars(question), ~ ifelse(grepl("write tests", .), "Write tests", .)) %>%
    mutate_at(vars(question), ~ ifelse(grepl("in Miri", .), "Run tests in Miri", .)) %>%
    plot_likert_bars(
        3.5,
        0.75,
        file.path(result_dir, "rq5_frequency_miri.pdf"),
        hide_legend = TRUE,
    )

# ————RQ6————

positivity_legend <- compute_likert_frequency(c("CCQ2", "CCQ3"), positivity_choices) %>%
    mutate_at(vars(question), ~ ifelse(grepl("CCQ2", .), "In general", .)) %>%
    mutate_at(vars(question), ~ ifelse(grepl("CCQ3", .), "That you write", .)) %>%
    mutate(`Neither positively nor negatively` = `Neither positively nor negatively` + `Unsure`) %>%
    select(-`Unsure`) %>%
    rename(`Neutral` = `Neither positively nor negatively`) %>%
    plot_likert_bars(
        3.5,
        0.75,
        file.path(result_dir, "rq6_positivity.pdf"),
        wrap_legend = TRUE,
        extract_legend = file.path(legend_dir, "legend_positivity_wrapped.pdf"),
        legend_height = 1,
        legend_width = 3,
    )

compute_likert_frequency(c("CCQ4"), frequency_choices_unsure) %>%
    plot_likert_bars(
        3.5,
        0.5,
        center = "Unsure",
        hide_questions = TRUE,
        hide_legend = TRUE,
        file.path(result_dir, "rq6_adequacy.pdf"),
        cutoff = 10,
    )
