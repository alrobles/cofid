#' Find copepod occurrence data for given copepod species.
#' Given a copepod family, genus or species returns a list of copepod
#' occurrences.
#' @param species Copepod species to filter
#' @param genus Copepod genus to filter
#' @param family Copepod family to filter
#' @param citation boolean. Should the output include the citation information?
#' default is FALSE
#'
#' @return A data.frame with copepod fish interactions
#' @export
#'
#' @examples getCopepods(genus = "Caligus")
getCopepods <- function(species = NULL, genus = NULL, family = NULL, citation = TRUE){

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


  allSp <- unique(cofid::cofid$source_taxon_name)
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
    db <- cofid::cofid[grepl(query, cofid::cofid$source_taxon_path), ]
  } else {
    db <- cofid::cofid[grepl(query, cofid::cofid$source_taxon_name), ]
  }
  if(citation){
    return(unique(db[c("source_taxon_name", "target_taxon_name", "study_citation")]))
  } else {
    return(unique(db[c("source_taxon_name", "target_taxon_name")]))
  }
}
