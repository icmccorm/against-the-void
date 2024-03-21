suppressPackageStartupMessages({
    library(dplyr)
    library(readr)
    library(tidyr)
    library(purrr)
    library(xtable)
})
options(dplyr.summarise.inform = FALSE)
source("./scripts/irr/irr_shared.r")
source("./scripts/irr/irr_small.r")
source("./scripts/irr/irr_large.r")

large_alpha <- read_csv(file.path(BUILD_DIR, "alpha_6_7.csv"), show_col_types = FALSE)
small_alpha <- read_csv(file.path(BUILD_DIR, "alpha_1_5.csv"), show_col_types = FALSE)

all_alpha <- small_alpha %>%
    full_join(large_alpha, by = c("Coding Category")) %>%
    arrange_at(vars(-"Coding Category"), ~ is.na(.))
all_alpha <- all_alpha %>%
    mutate_at(vars(-"Coding Category"), ~ ifelse(is.na(.), "-", as.character(.)))

all_alpha <- all_alpha %>%
    mutate(max = apply(.[, -1], 1, function(x) {
        x <- suppressWarnings(as.numeric(x))
        if (all(is.na(x))) {
            NA
        } else {
            max(x, na.rm = TRUE)
        }
    }))

# Agreement is either Strong, Tentative, or Unclear
# Strong: 0.8 <= alpha <= 1
# Tentative: 2/3 <= alpha < 0.8
# Unclear: 0 <= alpha < 2/3 or NA
all_alpha <- all_alpha %>%
    mutate(Agreement = case_when(
        max >= 0.8 ~ "Strong",
        max >= 2 / 3 ~ "Tentative",
        TRUE ~ "Unclear"
    )) %>%
    select(-max) %>%
    mutate(Agreement = factor(Agreement, levels = c("Strong", "Tentative", "Unclear"))) %>%
    arrange(Agreement)

all_alpha <- all_alpha %>%
    mutate_at(vars(-"Coding Category", -"Agreement"), ~ ifelse(Agreement == "Strong" & !is.na(suppressWarnings(as.numeric(.))) & suppressWarnings(as.numeric(.)) >= 0.8, paste0("\\textbf{", ., "}"), .)) %>%
    mutate_at(vars(-"Coding Category", -"Agreement"), ~ ifelse(Agreement == "Tentative" & !is.na(suppressWarnings(as.numeric(.))) & suppressWarnings(as.numeric(.)) >= 2 / 3, paste0("\\textbf{", ., "}"), .))

agreement_changes <- which(all_alpha$Agreement != lag(all_alpha$Agreement)) - 1
baselines <- c(-1, 0, nrow(all_alpha))

colnames(all_alpha)[2:4] <- c("Rounds 1-5", "Round 6", "Round 7")
all_alpha <- all_alpha %>% mutate(`Survey Questions` = "\\ref{}")
all_alpha <- all_alpha %>% select(-Agreement)

print(xtable(all_alpha, type = "latex"), file = file.path(BUILD_TABLES_DIR, "irr.tex"), include.rownames = FALSE, sanitize.text.function = function(x) {
    x
}, hline.after = c(agreement_changes, baselines), floating = FALSE)
