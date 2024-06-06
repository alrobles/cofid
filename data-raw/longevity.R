library(phytools)
library(tidyverse)

fish_tree <- phytools::read.newick("data-raw/actinopt_12k_raxml.tre.xz")
Host_rectified <- readr::read_csv("data-raw/host_rectified_simple.csv")

fish_tiplabel_sample_harmonized <- readr::read_csv("data-raw/fish_tiplabel_sample_harmonized_clean.csv")

fish_tiplabel_sample_harmonized_clean <- fish_tiplabel_sample_harmonized %>%
  filter(!is.na(AphiaID)) %>%
  select(tiplabel, valid_name, valid_AphiaID) %>%
  mutate(valid_tiplabel = str_replace(valid_name, " ", "_"))

Host_valid_name <- Host_rectified %>%
  select(valid_name) %>%
  mutate(valid_tiplabel = str_replace(valid_name, " ", "_"))
host_valid_tiplabel <- fish_tiplabel_sample_harmonized_clean %>%
  filter(valid_tiplabel %in% Host_valid_name$valid_tiplabel)

host_valid_tiplabel %>%
  filter(tiplabel != valid_tiplabel)
host_valid_tiplabel_filtered <- host_valid_tiplabel %>%
  group_by(valid_name) %>%
  slice(1)

fish_tree_harmonized <- keep.tip(fish_tree, host_valid_tiplabel_filtered$tiplabel)
fish_tree_harmonized_tiplabel_ordered <- fish_tree_harmonized$tip.label %>%
  enframe(value = "tiplabel") %>%
  inner_join(host_valid_tiplabel_filtered)
fish_tree_harmonized$tip.label <- fish_tree_harmonized_tiplabel_ordered$valid_tiplabel

phytools::writeNexus(fish_tree_harmonized, "data-raw/fish_tol_harmonized.tre")

valid_families <- fish_tiplabel_sample_harmonized %>%
  filter(valid_AphiaID %in% host_valid_tiplabel_filtered$valid_AphiaID) %>%
  select(family) %>% distinct()

valid_genus <- fish_tiplabel_sample_harmonized %>%
  filter(valid_AphiaID %in% host_valid_tiplabel_filtered$valid_AphiaID) %>%
  select(genus) %>% distinct()

fish_tiplabel_sample_harmonized %>%
  filter(family %in% valid_families$family)

fish_tiplabel_sample_harmonized %>%
  filter(genus %in% valid_genus$genus)

util_columns <- readr::read_csv("data-raw/Columnas_utiles.csv")
View(util_columns)
util_columns %>%
  select(Host_species, LongevityWild) %>%
  distinct() %>%
  na.exclude()
util_columns %>%
  select(Host_species,LongevityWild, DepthRangeShallow,DepthRangeDeep,LTypeMaxM, Length.x, BodyShapeI.y, BodyShapeI.x, DemersPelag, AnaCat, LTypeMaxM, )

modeldata <- util_columns %>%
  select(LongevityWild, DepthRangeShallow, DepthRangeDeep, Length.x) %>% na.exclude()

train_data <- modeldata %>% sample_frac(0.7)
test_data <- anti_join(modeldata, train_data)
fit <- ranger::ranger(LongevityWild~., data = train_data)
### regresion model
library(tidymodels)

rf_defaults <- rand_forest(mode = "regression")

preds <- c("DepthRangeShallow", "DepthRangeDeep", "Length.x")

rf_xy_fit <-
  rf_defaults %>%
  set_engine("ranger") %>%
  fit_xy(
    x = train_data[, preds],
    y = (train_data$LongevityWild)
  )


###
norm_recipe <-
  recipe(
    LongevityWild ~ DepthRangeShallow + DepthRangeDeep + Length.x,
    data = train_data
  ) %>%
  #step_other(Neighborhood) %>%
  #step_dummy(all_nominal()) %>%
  step_center(all_predictors()) %>%
  step_scale(all_predictors()) %>%
  #step_log(LongevityWild, base = 10) %>%
  # estimate the means and standard deviations
  prep(training = test_data, retain = TRUE)

svm_fit <-
  svm_rbf(mode = "regression") %>%
  set_engine("kernlab") %>%
  fit(LongevityWild ~ ., data = bake(norm_recipe, new_data = NULL))

xgboost_fit <-
  boost_tree(mode = "regression") %>%
  set_engine("xgboost") %>%
  fit(LongevityWild ~ ., data = bake(norm_recipe, new_data = NULL))


test_normalized <- bake(norm_recipe, new_data = test_data, all_predictors())

test_results <-
  test_data %>%
  select(LongevityWild) %>%
  bind_cols(
    predict(rf_xy_fit, new_data = test_data[, preds])
  ) %>%
  rename(`random forest` = .pred) %>%
  bind_cols(
    predict(svm_fit, new_data = test_normalized ) %>%
      rename(svm = .pred)
  ) %>%
  bind_cols(
    predict(xgboost_fit, new_data = test_normalized ) %>%
      rename(xgboost = .pred)
  )
plot(test_results)

test_results %>% ggplot() +
  geom_point(aes(LongevityWild, xgboost )) +
  geom_point(aes(LongevityWild, svm), col = "blue" )



DepthRangeShallow + DepthRangeDeep + Length.x
# r phylo pars to fill ancestral reconstruction of characters
library(Rphylopars)


util_columns %>%
  select(Host_species,LongevityWild, DepthRangeShallow, DepthRangeDeep, Length.x )
morphotraits <- util_columns %>%
  select(Host_species,LongevityWild, DepthRangeShallow, DepthRangeDeep, Length.x ) %>%
  distinct()


host_valid_tiplabel_filtered %>%
  filter(valid_tiplabel %in% str_replace(morphotraits$Host_species, " ", "_"))
morphotraits_valid <- morphotraits %>%
  filter(Host_species %in% host_valid_tiplabel_filtered$valid_name)

morphotraits_valid <- morphotraits_valid %>%
  mutate(Host_species = str_replace(Host_species, " ", "_")) %>%
  rename(species = Host_species)

morphotraits_valid_reconstruct <- morphotraits_valid %>%
  select(species, Length.x, DepthRangeDeep, DepthRangeShallow) %>%
  mutate(Length.x = log(Length.x),
         DepthRangeDeep = log(DepthRangeDeep) + 0.01,
         DepthRangeShallow = log(DepthRangeShallow +1))

View(morphotraits_valid_reconstruct)
fish_tree_harmonized
morphotraits_valid
library(Rphylopars)
p_BM <- phylopars(trait_data = morphotraits_valid_reconstruct, tree = fish_tree_harmonized)

morphotraits_reconstructed <- p_BM$anc_recon %>% as_tibble() %>%
  mutate_all(exp) %>%
 mutate(Host_species = rownames(p_BM$anc_recon))

morphotraits_reconstructed <- morphotraits_reconstructed %>%
  filter(Host_species %in% morphotraits_valid_reconstruct$species) %>%
  select(Host_species, everything())


morphotraits_reconstructed %>%
  filter(Host_species == "Scorpaena_plumieri" )

morphotraits_reconstructed <- morphotraits_valid %>% select(species, LongevityWild) %>%
  rename(Host_species = species) %>%
  left_join(morphotraits_reconstructed)

morphotraits_reconstructed_fullData <- morphotraits_reconstructed %>%
  filter(!is.na(LongevityWild))


morphotraits_train <- morphotraits_reconstructed_fullData %>%
  sample_frac(0.5)
morphotraits_test <- anti_join(morphotraits_reconstructed_fullData, morphotraits_train)
library(tidymodels)
library(tidyverse)
norm_recipe <-
  recipe(
    LongevityWild ~ DepthRangeShallow + DepthRangeDeep + Length.x,
    data = morphotraits_train
  ) %>%
  #step_other(Neighborhood) %>%
  #step_dummy(all_nominal()) %>%
  step_center(all_predictors()) %>%
  step_scale(all_predictors()) %>%
  #step_log(LongevityWild, base = 10) %>%
  # estimate the means and standard deviations
  prep(training = morphotraits_test, retain = TRUE)


xgboost_fit <-
  boost_tree(mode = "regression") %>%
  set_engine("xgboost") %>%
  fit(LongevityWild ~ ., data = bake(norm_recipe, new_data = NULL))


test_normalized <- bake(norm_recipe, new_data = morphotraits_test, all_predictors())
all_normalized <- bake(norm_recipe, new_data = morphotraits_reconstructed, all_predictors())

test_normalized

xgboost_fit <-
  boost_tree(mode = "regression") %>%
  set_engine("xgboost") %>%
  fit(LongevityWild ~ ., data = bake(norm_recipe, new_data = NULL))


p2 <- morphotraits_reconstructed %>%
  bind_cols(
  predict(xgboost_fit, new_data = all_normalized ) %>%
    rename(xgboost = .pred)
) %>%
  ggplot() + geom_point(aes(LongevityWild, xgboost))


p1 <- morphotraits_test %>%
  bind_cols(
    predict(xgboost_fit, new_data = test_normalized ) %>%
      rename(xgboost = .pred)
  ) %>%
  ggplot() + geom_point(aes(LongevityWild, xgboost))
cowplot::plot_grid(p1, p2)

View(morphotraits_test)
