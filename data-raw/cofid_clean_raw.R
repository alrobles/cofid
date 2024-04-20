library(tidyverse)

Copepod_All_parasites <- readxl::read_excel("data-raw/Copepod_All_parasites_2024.xlsx")
Copepods_Fish_parasites <- readxl::read_excel("data-raw/Copepods_Fish_parasites.xlsx")


Copepod_All_parasites_rename <- Copepod_All_parasites %>%
  select(AphiaID_parasite, ScientificName_parasite,
         AphiaID_parasite, Scientificname_host, Source_fulltext) %>%
  rename(Copepod_species = ScientificName_parasite,
         Host_species.x = Scientificname_host)
Copepods_Fish_parasites_join <- left_join(Copepods_Fish_parasites, Copepod_All_parasites_rename) %>%
  distinct()
Copepods_Fish_parasites_join_na_exclude <- Copepods_Fish_parasites_join %>%
  na.exclude()


CopepodsOrder <- Copepods_Fish_parasites_join_na_exclude %>%
  select(Copepod_order) %>% distinct()

library(taxize)
CopepodOrderdf <- purrr::map(CopepodsOrder$Copepod_order, function(x){
  Sys.sleep(0.1)
  classification(x, db = 'worms', rows = 1) %>%
    .[[1]] %>%
    select(-id) %>%
    spread(rank, name)
}) %>% reduce(bind_rows)

insecta <- rglobi::get_interactions(taxon = "Insecta", "parasiteOf")
insecta %>% slice(1) %>% pull(source_taxon_path)
CopepodOrderClass <- CopepodOrderdf %>%
  select(Kingdom, Phylum, Class, Order) %>%
  rename(parasite_kingdom = Kingdom, parasite_phylum  = Phylum, Copepod_order = Order, Copepod_class = Class)

#parasite taxon path
Copepods_taxon_path <- Copepods_Fish_parasites_join_na_exclude %>%
  left_join(CopepodOrderClass) %>%
  select(Copepod_species, parasite_kingdom, parasite_phylum, Copepod_class, Copepod_order, Copepod_family) %>%
  mutate(parasite_genus = stringr::word(Copepod_species, 1)) %>%
  rename(parasite_order = Copepod_order) %>%
  mutate(parasite_species = Copepod_species)
Copepods_taxon_path <- Copepods_taxon_path %>%
  unite("source_taxon_path", 2:8, sep = " | ")

Copepods_taxon_path_distinct <- Copepods_taxon_path %>% distinct()
#fish taxon path
insecta %>% slice(1) %>% pull(source_taxon_path)
Fish_order <- Copepods_Fish_parasites_join_na_exclude %>%

  filter(Host_order != "Percopsiformes") %>%
  distinct(Host_order)

Fish_order_df <- classification(Fish_order$Host_order, db = 'worms')

#these are the same but string search doesn't works
Fish_order_df_Percopsiformes <- classification("Percopsiformes", db = 'worms')
Fish_order_df[[48]] %>% select(-id) %>% spread(rank, name)

Fish_order_df_notNa <- Fish_order_df[!is.na(Fish_order_df)] %>%
  purrr::map(function(x){
    x %>% select(-id) %>% spread(rank, name)
  }) %>% reduce(bind_rows)

#know missing fish
#Fish_order_df[is.na(Fish_order_df)]

#Percopsiformes
Fish_order_df_Percopsiformes <- classification('154217', db = 'worms')
#Esociformes
Fish_order_df_Esociformes <- classification('154206', db = 'worms')
#Hiodontiformes
Fish_order_df_Hiodontiformes <- classification('1517444', db = 'worms')

Fish_missing <- c(Fish_order_df_Percopsiformes, Fish_order_df_Esociformes, Fish_order_df_Hiodontiformes) %>%
  purrr::map(function(x){
    x %>% select(-id) %>% spread(rank, name)
  }) %>% reduce(bind_rows)

Fish_order_df_all <- bind_rows(Fish_missing, Fish_order_df_notNa)
Fish_kpco <- Fish_order_df_all %>%
  select(Kingdom, Phylum, Class, Order ) %>%
  rename(Host_order = Order)

fish_taxon_path <- Copepods_Fish_parasites_join_na_exclude %>%
  select(Host_order, Host_family, Host_species.x) %>%
  inner_join(Fish_kpco) %>%
  mutate(genus = stringr::word(Host_species.x, 1)) %>%
  mutate(species = Host_species.x) %>%
  select(Host_species.x, Kingdom, Phylum, Class, Host_order, Host_family, genus, species)

fish_taxon_path <- fish_taxon_path %>%
  unite("target_taxon_path", 2:8, sep = " | ") %>%
  select(target_taxon_path)

Copepods_Fish_parasites_join_na_exclude_fish_path <-
  bind_cols(Copepods_Fish_parasites_join_na_exclude, fish_taxon_path)

View(Copepods_Fish_parasites_join_na_exclude_fish_path)

Copepods_Fish_parasites_taxon_path <- bind_cols(Copepods_Fish_parasites_join_na_exclude_fish_path,
                                                select(Copepods_taxon_path, source_taxon_path))

View(insecta)
insecta %>% colnames()
Copepods_Fish_parasites_taxon_path %>% View()
Copepods_Fish_parasites_taxon_path$Source_fulltext


cofid <- Copepods_Fish_parasites_taxon_path %>%

  rename(source_taxon_external_id = AphiaID_parasite,
         source_taxon_name = Copepod_species,
         source_specimen_life_stage = Feedingtype_Stage,
         interaction_type = Feedingtype,
         target_taxon_external_id = Host_AphiaID,
         target_taxon_name = Host_species.x,
         study_citation = Source_fulltext,

         ) %>%
  mutate(
    target_specimen_life_stage = NA_character_,
    latitude = NA_real_,
    longitude = NA_real_,
    study_source_ciation = NA_character_) %>%
  select(source_taxon_external_id,
         source_taxon_name,
         source_taxon_path,
         source_specimen_life_stage,
         interaction_type,
         target_taxon_external_id,
         target_taxon_name,
         target_taxon_path,
         target_specimen_life_stage,
         latitude,
         longitude,
         study_citation,
         study_source_ciation)


library(devtools)
library(usethis)
cofid <- cofid %>% select( -study_source_ciation)
use_data(cofid, overwrite = TRUE)
write.csv(cofid, "data-raw/cofid.csv")
