library(phytools)
library(tidyverse)
fish_tree <- phytools::read.newick("data-raw/actinopt_12k_raxml.tre.xz")
Host_rectified <- readr::read_csv("data-raw/host_rectified_simple.csv")

fish_tiplabel <- fish_tree$tip.label %>%
  enframe(value = "tiplabel") %>%
  mutate(species = str_replace(tiplabel, "_", " "))

Host_rectified_valid <- Host_rectified %>%
  select(valid_name) %>%
  mutate(fish = str_replace(valid_name, " ", "_")) %>%
  distinct()

wm_name2id_safe <- purrr::possibly(.f = worrms::wm_name2id, otherwise = NA)

fish_tiplabel_sample <- fish_tiplabel
fish_tiplabel_sample_harmonized <- fish_tiplabel_sample %>%
  mutate(AphiaID = purrr::map(species, ~ wm_name2id_safe(.)))

fish_tiplabel_sample_harmonized <- fish_tiplabel_sample_harmonized %>% unnest()
#
# fish_tiplabel_sample_harmonized <- fish_tiplabel_sample_harmonized %>%
#   mutate(harmonization = purrr::map(AphiaID, ~ worrms::wm_record(.))) %>% unnest()


fish_tiplabel_sample_harmonized %>%
  write.csv("data-raw/fish_tiplabel_sample_harmonized.csv")
