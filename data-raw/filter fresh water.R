library(devtools)
library(tidyverse)
Columnas <- readr::read_csv("data-raw/Columnas_utiles.csv")


Columnas_ergasilidae <- Columnas %>%
  filter(Copepod_family == "Ergasilidae") %>%
  select(Host_species, Fresh, Saltwater, Brack) %>%
  filter(Fresh == 1) %>%
  filter(Saltwater == 0 & Brack == 0)

cofid::cofid

View(Columnas_ergasilidae)
cofid_table <- cofid::cofid
View(cofid_table)
cofid_table <-  cofid_table %>%
  filter(!target_taxon_name %in% Columnas_ergasilidae$Host_species) %>%
  select(-longitude, -latitude)

cofid_table_freshwater <- cofid_table %>%
  filter(target_taxon_name %in% Columnas_ergasilidae$Host_species)


cofid_table_no_freshwater <- cofid_table %>%
  filter(!target_taxon_name %in% Columnas_ergasilidae$Host_species)
View(cofid_table_no_freshwater)
write.csv(cofid_table_freshwater, "data-raw/cofid_table_freshwater.csv")
write.csv(cofid_table_no_freshwater, "data-raw/cofid_table_no_freshwater.csv")
Columnas <- Columnas %>%
  dplyr::select(Host_species, Fresh , Brack, Saltwater) %>%
  rename(target_taxon_name = Host_species)
cofid <- cofid_table_no_freshwater

usethis::use_data(cofid, overwrite = TRUE)
