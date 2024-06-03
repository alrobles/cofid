
library(tidyverse)
copepod <- readxl::read_excel("data-raw/Copepod_All_parasites_2024.xlsx")
copepod <- copepod %>%
  select(AphiaID_parasite, ScientificName_parasite, AphiaID_host, Scientificname_host, Source_fulltext) %>%
  na.exclude() %>%
  distinct()
copepod <- copepod %>%
  filter(str_count(ScientificName_parasite, "\\W+") > 0) %>%
  filter(str_count(Scientificname_host, "\\W+") > 0)

copepodHost <- copepod %>%
  select(AphiaID_host, Scientificname_host) %>%
  distinct()
copepodHost_samp <- copepodHost %>%
  sample_n(10)

copepodHost_samp_rectified <- worrms::wm_record(copepodHost_samp$AphiaID_host)
View(copepodHost_samp_rectified)
copepodHost_samp_rectified <- copepodHost_samp_rectified %>%
  select(AphiaID, scientificname, valid_AphiaID, valid_name, isMarine, isBrackish, isFreshwater, kingdom, phylum, class, order, family, genus) %>%
  mutate(species = valid_name) %>%
  tidyr::unite(col = "taxon_path", 8:14, sep = "|") %>%
  rename(AphiaID_host = AphiaID )

inner_join(copepod, copepodHost_samp_rectified) %>% View()
###

copepodHost_samp <- copepodHost %>%
  sample_n(100)

copepodHost_rectified <- copepodHost %>%
  mutate(harmonization = purrr::map(AphiaID_host, ~ worrms::wm_record(.)))
copepodHost_rectified <- copepodHost_rectified %>% unnest()
write.csv(copepodHost_rectified, "data-raw/host_rectified.csv")

copepodHost_rectified <- copepodHost_rectified %>%
  select(AphiaID, scientificname, valid_AphiaID, valid_name, isMarine, isBrackish, isFreshwater, kingdom, phylum, class, order, family, genus) %>%
  mutate(species = valid_name) %>%
  tidyr::unite(col = "taxon_path", 8:14, sep = "|") %>%
  rename(AphiaID_host = AphiaID )
copepodHost_rectified

copepod_host_rectified <- left_join(copepod, copepodHost_rectified)
View(copepod_host_rectified)
copepod_host_rectified <- copepod_host_rectified %>%
  select(AphiaID_parasite,ScientificName_parasite, valid_AphiaID, valid_name,taxon_path, isFreshwater, isBrackish, isMarine, Source_fulltext ) %>%
  distinct()
copepod_host_rectified <- copepod_host_rectified %>%
  filter(! valid_name %in%  host_only_marine$valid_name) %>%
  distinct()


### parasite

copepod <- copepod %>%
  filter(str_count(ScientificName_parasite, "\\W+") > 0) %>%
  filter(str_count(Scientificname_host, "\\W+") > 0)
Parasite <- copepod %>%
  select(AphiaID_parasite, ScientificName_parasite) %>%
  distinct()
Parasite_samp <- Parasite %>%
  sample_n(100)
Parasite_rectified <- Parasite %>%
  mutate(harmonization = purrr::map(AphiaID_parasite, ~ worrms::wm_record(.)))
Parasite_rectified <- Parasite_rectified %>% unnest()


Parasite_rectified <- Parasite_rectified %>%
  select(AphiaID_parasite, ScientificName_parasite, valid_AphiaID, valid_name, isMarine, isBrackish, isFreshwater, kingdom, phylum, class, order, family, genus) %>%
  mutate(species = valid_name) %>%
  tidyr::unite(col = "source_taxon_path", 8:14, sep = "|")
copepodHost_rectified
write.csv(Parasite_rectified, "data-raw/parasite_rectified_simple.csv")
library(tidyverse)

Parasite_rectified <- readr::read_csv("data-raw/parasite_rectified_simple.csv")
Host_rectified <- readr::read_csv("data-raw/host_rectified_simple.csv")

copepod <- readxl::read_excel("data-raw/Copepod_All_parasites_2024.xlsx")
copepod <- copepod %>%
  select(AphiaID_parasite, ScientificName_parasite, AphiaID_host, Scientificname_host, Source_fulltext) %>%
  na.exclude() %>%
  distinct()
copepod <- copepod %>%
  filter(str_count(ScientificName_parasite, "\\W+") > 0) %>%
  filter(str_count(Scientificname_host, "\\W+") > 0)


Parasite_rectified_selected <- Parasite_rectified %>%
  select(AphiaID_parasite, valid_AphiaID, valid_name, source_taxon_path) %>%
  rename(source_taxon_name = valid_name) %>%
  rename(valid_AphiaID_parasite = valid_AphiaID)

Host_rectified_selected <- Host_rectified %>%
  select(AphiaID_host, valid_AphiaID, valid_name, taxon_path) %>%
  rename(valid_AphiaID_host = valid_AphiaID) %>%
  rename(target_taxon_path = taxon_path) %>%
  rename(target_taxon_name = valid_name)

cofid::cofid %>% View()
copepod <- readxl::read_excel("data-raw/Copepod_All_parasites_2024.xlsx")

copepod_harmonized <- copepod %>%
  filter(str_count(ScientificName_parasite, "\\W+") > 0) %>%
  filter(str_count(Scientificname_host, "\\W+") > 0) %>%
  select(AphiaID_parasite, AphiaID_host, Source_fulltext, Lifestage_parasite, Trait_value) %>%
  na.exclude() %>%
  distinct() %>%
  left_join(Parasite_rectified_selected) %>%
  left_join(Host_rectified_selected)



copepod_harmonized <- copepod_harmonized %>%
  select(valid_AphiaID_parasite, source_taxon_name, source_taxon_path, Lifestage_parasite, Trait_value, valid_AphiaID_host, target_taxon_name, target_taxon_path, Source_fulltext ) %>%
  distinct()
copepod_harmonized <- copepod_harmonized %>%
  rename(source_taxon_external_id = valid_AphiaID_parasite) %>%
  rename(source_specimen_life_stage = Lifestage_parasite) %>%
  rename(interaction_type = Trait_value) %>%
  rename(target_taxon_external_id = valid_AphiaID_host) %>%
  rename(study_citation = Source_fulltext) %>%
  distinct()
copepod_harmonized <- copepod_harmonized %>%
  mutate(source_taxon_external_id = paste0("AphiaID:", source_taxon_external_id)) %>%
  mutate(source_taxon_path = str_replace_all(source_taxon_path, "\\|", " \\| ")) %>%
  mutate(target_taxon_external_id = paste0("AphiaID:", source_taxon_external_id)) %>%
  mutate(target_taxon_path = str_replace_all(source_taxon_path, "\\|", " \\| "))



copepodHost_rectified <- readr::read_csv("data-raw/host_rectified_simple.csv")

host_fresh_water <- copepodHost_rectified %>%
  filter(isFreshwater == 1) %>%
  filter(isBrackish == 0) %>%
  filter(isMarine == 0)

host_marine <- copepodHost_rectified %>%
  filter(isFreshwater == 0) %>%
  filter(isBrackish == 1) %>%
  filter(isMarine == 1)

copepodHost_rectified_freshwater_marine_brackish <- copepodHost_rectified %>%
  filter(isFreshwater == 1 &  isBrackish != 0 & isMarine != 0)

copepodHost_rectified_freshwater_brackish <- copepodHost_rectified %>%
  filter(isFreshwater == 1 &  isBrackish != 0)

copepodHost_rectified_freshwater_marine <- copepodHost_rectified %>%
  filter(isFreshwater == 1 &  isMarine != 0)

copepodHost_rectified_marine <- copepodHost_rectified %>%
  filter(isBrackish == 1 | isMarine == 1)

copepodHost_rectified_no_fresh_water <- list(copepodHost_rectified_Fresh_water_marine_brackish,
     copepodHost_rectified_freshwater_brackish,
     copepodHost_rectified_freshwater_marine,
     copepodHost_rectified_marine) %>%
  reduce(rbind) %>%
  distinct()

host_only_freshwater <- copepodHost_rectified %>%
  filter(isFreshwater == 1) %>%
  filter(isBrackish == 0 & isMarine == 0)


copepod_harmonized_no_fresh <- copepod_harmonized %>%
  filter(target_taxon_name %in% copepodHost_rectified_no_fresh_water$valid_name)

copepod_harmonized_no_fresh %>%
  filter(target_taxon_name %in% host_only_freshwater$scientificname)

#
#
#
# copepod_harmonized_only_marine <- copepod_harmonized %>%
#   filter(target_taxon_name %in% host_marine$valid_name)



cofid %>%
  filter(target_taxon_name %in% host_only_freshwater$scientificname)

cofid <- copepod_harmonized_no_fresh
write_csv(cofid, "data-raw/cofid.csv")
write_csv(host_only_freshwater, "data-raw/copepod_harmonized_freshwater.csv")

usethis::use_data(cofid, overwrite = TRUE)
