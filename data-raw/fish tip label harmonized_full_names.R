library(tidyverse)
fish_tiplabel_sample_harmonized <- readr::read_csv("data-raw/fish_tiplabel_sample_harmonized.csv")
fish_tiplabel_sample_harmonized_clean <- fish_tiplabel_sample_harmonized %>%
  filter(!is.na(AphiaID))

# fish_tiplabel_sample_harmonized <- fish_tiplabel_sample_harmonized %>%
#   mutate(harmonization = purrr::map(AphiaID, ~ worrms::wm_record(.))) %>% unnest()

wm_record_safe <- purrr::possibly(.f = worrms::wm_record, otherwise = NA)

fish_tiplabel_harmonized_clean <- fish_tiplabel_sample_harmonized_clean %>%
  mutate(harmonization = purrr::map(AphiaID, ~ worrms::wm_record(.))) %>% unnest()

fish_tiplabel_harmonized_clean %>%
 write.csv("data-raw/fish_tiplabel_sample_harmonized_clean.csv")
