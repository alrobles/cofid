library(tidyverse)

Host_rectified <- readr::read_csv("data-raw/host_rectified_simple.csv")

Host_rectified_fish <- Host_rectified %>%
  filter(grepl("Elasmobranchii|Teleostei", taxon_path))

Host_rectified_fish_missing_habitat <- Host_rectified_fish %>%
  filter(is.na(isMarine) & is.na(isBrackish) & is.na(isFreshwater))

#write_csv(Host_rectified_fish_missing_habitat, "data-raw/Host_rectified_fish_missing_habitat.csv")
Host_rectified_fish_missing_habitat <- readr::read_csv("data-raw/Host_rectified_fish_missing_habitat_fill.csv")

Host_rectified_fish <- bind_rows(Host_rectified_fish_missing_habitat, Host_rectified_fish)

Host_rectified_fish <- Host_rectified_fish %>%
  mutate_at(.vars = 6:8, .funs = function(x){replace_na(x, 0)})


host_fish_only_freshwater <- Host_rectified_fish %>%
  filter(isFreshwater == 1 & isMarine == 0 & isBrackish == 0)


host_fish_only_marine_brackish <- Host_rectified_fish %>%
  anti_join(host_fish_only_freshwater)

# copepod_host_harmonized_only_marine_brackish <- readr::read_csv("data-raw/copepod_harmonized_only_marine.csv")

Parasite_rectified <- readr::read_csv("data-raw/parasite_rectified_simple.csv")
Parasite_rectified_selected <- Parasite_rectified %>%
  select(AphiaID_parasite, valid_AphiaID, valid_name, source_taxon_path) %>%
  rename(source_taxon_name = valid_name) %>%
  rename(valid_AphiaID_parasite = valid_AphiaID)

Host_rectified_fish_selected <- host_fish_only_marine_brackish %>%
  select(AphiaID_host, valid_AphiaID, valid_name, taxon_path) %>%
  rename(valid_AphiaID_host = valid_AphiaID) %>%
  rename(target_taxon_path = taxon_path) %>%
  rename(target_taxon_name = valid_name)


copepod <- readxl::read_excel("data-raw/Copepod_All_parasites_2024.xlsx")

copepod <- copepod %>%
  filter(str_count(ScientificName_parasite, "\\W+") > 0) %>%
  filter(str_count(Scientificname_host, "\\W+") > 0) %>%
  select(AphiaID_parasite, AphiaID_host, Source_fulltext, Lifestage_parasite, Trait_value) %>%
  na.exclude() %>%
  distinct()


copepod_harmonized <- copepod %>%
  left_join(Parasite_rectified_selected) %>%
  left_join(Host_rectified_fish_selected) %>%
  na.exclude()

copepod_harmonized %>%
  select(valid_AphiaID_parasite, source_taxon_name, source_taxon_path, Lifestage_parasite,Trait_value, valid_AphiaID_host, target_taxon_name, Source_fulltext  )
globiExample <- rglobi::get_interactions(taxon = "Molva molva")

colnames(globiExample)
globiExample %>% tibble()
copepod_harmonized$AphiaID_parasite

cofid <- copepod_harmonized %>%
  select(valid_AphiaID_parasite, source_taxon_name, source_taxon_path, Lifestage_parasite, Trait_value, valid_AphiaID_host, target_taxon_name, target_taxon_path, Source_fulltext  ) %>%
  rename(source_taxon_external_id = valid_AphiaID_parasite,
         source_expecimen_life_stage = Lifestage_parasite,
         interaction_type = Trait_value,
         target_taxon_external_id = valid_AphiaID_host,
         study_citation = Source_fulltext
  ) %>%
  mutate(source_taxon_external_id = paste0("AphiaID:", source_taxon_external_id)) %>%
  mutate(target_taxon_external_id = paste0("AphiaID:", target_taxon_external_id)) %>%
  distinct()

View(cofid)
usethis::use_data(cofid, overwrite = TRUE)
write_csv(cofid, "data-raw/cofid.csv")
