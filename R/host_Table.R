#' Host table
#'
#' A list of copepod curated by Francisco Neptalí Morales-Serna.
#'  This dataset was cleaned and taxonomically rectified.
#' formated by Angel Luis Robles Fernandez following the Worms  database standard. The cleaned dataset is stored in
#' 10.5281/zenodo.11002619
#'
#' @format ## `host_table`
#' A data frame with 3,205 rows and 6 columns:
#' \describe{
#'   \item{valid_AphiaID}{WoRMS id of the fish, i.e. AphiaID}
#'   \item{target_taxon_name}{Scientific name of the fish species}
#'   \item{target_taxon_path}{Taxon path of the fish}
#'   \item{isMarine}{Logical. is the species found in marine habitats? }
#'   \item{isBrackish}{Logical. is the species found in brackish habitats?}
#'   \item{isFreshwater}{Logical. is the species found in fresh water habitats?}
#' }
#' @source Copepod fish interaction database <10.5281/zenodo.11511665>
"host_table"
