#' Find copepod occurrence data for given host fish.
#' Given a fish family, genus or species returns a list of copepod
#' occurrences on that host
#' @param species Fish species to filter
#' @param genus Fish genus to filter
#' @param family Fish family to filter
#' @param citation boolean. Should the output include the citation information?
#' default is FALSE
#'
#' @return A data.frame with copepod fish interactions
#' @export
#'
#' @examples getFish(genus = "Molva")
getFish <- function(species = NULL, genus = NULL, family = NULL, citation = TRUE){

  if(!(is.null(species) || is.null(genus))){
    stop("Please provide only species, genus or family, not both!")
  }
  if(!(is.null(species) || is.null(family))){
    stop("Please provide only species, genus or family, not both!")
  }
  if(!(is.null(genus) || is.null(family))){
    stop("Please provide only species, genus or family, not both!")
  }


  if(is.null(species) && is.null(family) ){
    query <-  genus
  } else if(is.null(genus) && is.null(family)) {
    query <- species
  } else if(is.null(species) && is.null(genus)){
    query <-  family
  }


  allSp <- unique(cofid::cofid$target_taxon_name)
  allGn <- unique(gsub( " .*$", "", allSp ) )

  matchGenus <- match(genus, allGn)
  matchSp <- match(species, allSp)

  if( any(is.na( matchGenus) ) ){
    stop("Genus not found. Check spell")
  }

  if( any(is.na(matchSp) ) ){
    stop("Species not found. Check spell")
  }

  if(!is.null(family)){
    db <- cofid::cofid[grepl(query, cofid::cofid$target_taxon_path), ]
  } else {
    db <- cofid::cofid[grepl(query, cofid::cofid$target_taxon_name), ]
  }
  if(citation){
   return(unique(db[c("source_taxon_name", "target_taxon_name", "study_citation")]))
  } else {
    return(unique(db[c("source_taxon_name", "target_taxon_name")]))
  }

  return(query)
}
