#' Copepod fish interaction database
#'
#' A list of interactions between copepods and fish based on WoRMS database.
#' And curated by Francisco Neptalí Morales-Serna. This dataset was cleaned and
#' formated by Angel Luis Robles Fernandez following the GloBi
#' (Global interactions) database standard. The cleaned dataset is stored in
#' 10.5281/zenodo.11002619
#'
#' @format ## `cofid`
#' A data frame with 7273 rows and 10 columns:
#' \describe{
#'   \item{source_taxon_external_id}{WoRMS id of the parasite, i.e. AphiaID}
#'   \item{source_taxon_name}{Scientific name of the species}
#'   \item{source_taxon_path}{Taxon path of the parasite}
#'   \item{source_specimen_life_stage}{Life stage of the parasite}
#'   \item{interaction_type}{Type of interactio between parasite and host}
#'   \item{target_taxon_external_id}{WoRMS id of the host, i.e. AphiaID}
#'   \item{target_taxon_name}{Scientific name of the host}
#'   \item{target_taxon_path}{Taxon path of the host}
#'   \item{study_citation}{Source paper of the interaction}
#' }
#' @source Copepod fish interaction database <10.5281/zenodo.11002619>
"cofid"
