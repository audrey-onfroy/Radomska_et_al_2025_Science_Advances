
rm(list = ls())



library(ComplexHeatmap)
library(dplyr)

###

data_dir = "/home/nf1/Documents/Audrey/Paper/Radomska_et_al/V_2023_02_07/Figure 2_Genomics_Cancer Cell/"

cnv_data = openxlsx::read.xlsx(paste0(data_dir, "WES2023_Aggregated_annotated_Primaries.xlsx"))

dim(cnv_data)

###
cnv_data = cnv_data %>%
  dplyr::select(Line, Chr, Start, End,
                `27187_PrimaryTumor_vs_27187_Spleen`,
                `83935_PrimaryTumor_vs_83935_Spleen`,
                CF153_PrimaryTumor_vs_CF153_Spleen,
                M23349_Tumor_vs_Spleen,
                M23465_Tumor_vs_Spleen,
                M46643_Tumor1_vs_M46643_Spleen,
                M46643_Tumor2_vs_M46643_Spleen,
                M46643_Tumor3_vs_M46643_Spleen,
                M62892_Tumor_vs_Spleen,
                M62908_Tumor_vs_M62908_Spleen,
                M63717_Tumor_vs_Spleen,
                M76339_Tumor_vs_M76339_Spleen,
                M83937_TumorP0_vs_M83937_Spleen,
                FREQ_LOSS, FREQ_GAIN, FREQ_TOTAL, Cyto.Start) %>%
  dplyr::filter(FREQ_GAIN != 0 | FREQ_LOSS != 0) %>%
  dplyr::mutate(region = paste0(Chr, Cyto.Start)) %>%
  dplyr::mutate(region = stringr::str_replace_all(region, pattern = "\\.", replacement = "_"))


sample_col_ids = c(5:17)
sample_names = colnames(cnv_data[sample_col_ids])

dim(cnv_data)
table(cnv_data$region) %>% head()
table(cnv_data$region) %>% dim()

###
cnv_data = na.omit(cnv_data)
dim(cnv_data)


### 
# Oncoprint accepts character content
binarize = function(value) {
  value = dplyr::case_when(is.na(value) ~ "na",
                           # loss of two copies
                           value <= -0.5 ~ "loss_both",
                           # loss of one copy
                           value > -0.5 & value <= -0.12  ~ "loss_half",
                           # no change (background)
                           value > -0.13 & value < 0.25 ~ "",
                           # gain
                           value >= 0.25 & value < 0.5 ~ "gain",
                           # big gain
                           value >= 0.5 ~ "gain_big")
  return(value)
}


vec_colors = c("loss_both" = "#2166AC",
               "loss_half" = "#A6C4E3",
               "background" = "#F7F7F7",
               "gain" = "#ECB8BF",
               "gain_big" = "#B2182B",
               na = "gray60")

alter_fun = list(
  background = alter_graphic("rect", fill = vec_colors[["background"]],
                             width = 0.9, height = 0.9),
  "loss_both" = alter_graphic("rect", fill = vec_colors[["loss_both"]],
                              width = 0.9, height = 0.9),
  "loss_half" = alter_graphic("rect", fill = vec_colors[["loss_half"]],
                              width = 0.9, height = 0.9),
  "gain" = alter_graphic("rect", fill = vec_colors[["gain"]],
                         width = 0.9, height = 0.9),
  "gain_big" = alter_graphic("rect", fill = vec_colors[["gain_big"]],
                             width = 0.9, height = 0.9),
  na = alter_graphic("rect", fill = vec_colors[["na"]],
                     width = 0.9, height = 0.9)
)

heatmap_legend_param = list(title = "Copy Number Variations",
                            at = c("loss_both", "loss_half", "gain", "gain_big", "na"), 
                            labels = c("full loss", "LOH", "gain", "big gain", "na"))




c(unlist(cnv_data[, sample_names])) %>%
  hist(., breaks = 100)

cnv_data[, sample_names] = vapply(as.matrix(cnv_data[, sample_names]),
                                  FUN = binarize,
                                  FUN.VALUE = character(1))

c(unlist(cnv_data[, sample_names])) %>% unique()



###
cnv_data$nb_samples = rowSums(cnv_data[, sample_names] != "", na.rm = TRUE)

cnv_data = cnv_data %>%
  dplyr::filter(nb_samples > 4)

dim(cnv_data)



###
cnv_data$motif = apply(cnv_data[, sample_names], 1, FUN = paste, collapse = "_")

cnv_data = cnv_data %>%
  dplyr::group_by(paste(region, motif))


cnv_group_fun = function(sub_dataframe) {
  grouped_row = list()
  
  ## Chr
  grouped_row[["Chr"]] = sub_dataframe[["Chr"]] %>%
    unique() %>%
    sort() %>%
    paste(., collapse = "_")
  
  ## Start
  grouped_row[["Start"]] = sub_dataframe[["Start"]] %>%
    min()
  
  ## End
  grouped_row[["End"]] = sub_dataframe[["End"]] %>%
    max()
  
  ## Width
  grouped_row[["Width"]] = grouped_row[["End"]] - grouped_row[["Start"]]
  
  ## Cyto
  grouped_row[["Cyto.Start"]] = sub_dataframe[["Cyto.Start"]] %>%
    unique() %>%
    sort() %>%
    paste(., collapse = "_")
  
  ## Region
  grouped_row[["Region"]] = paste0(grouped_row[["Chr"]],
                                   grouped_row[["Cyto.Start"]],
                                   "_",
                                   grouped_row[["Width"]]) 
  
  grouped_row = unlist(grouped_row)
  
  ## Samples
  sample_summary = sub_dataframe[sample_col_ids] %>%
    apply(., 2, FUN = unique) %>%
    unlist()
  
  ## Output
  grouped_row = c(grouped_row, sample_summary)
  
  return(grouped_row)
}

new_column_names = c("Chr", "Start", "End", "Width", "Cyto.Start", "Region",
                     colnames(cnv_data)[sample_col_ids])

cnv_data = cnv_data %>%
  dplyr::group_map(~ cnv_group_fun(.)) %>%
  do.call(rbind.data.frame, .) %>%
  `colnames<-`(new_column_names)

cnv_data[, c("Start", "End", "Width")] = apply(cnv_data[, c("Start", "End", "Width")], 2,
                                               FUN = function(x) {as.numeric(as.character(x))})

cnv_data = cnv_data %>%
  dplyr::filter(Width > 500)


dim(cnv_data)

## Matrix
cnv_matrix = as.matrix(cnv_data[, sample_names])
rownames(cnv_matrix) = cnv_data$Region


# Sample annotation
sample_annot = openxlsx::read.xlsx(paste0(data_dir, "Table_Genetic.xlsx"),
                                   sheet = 3)

sample_annot = sample_annot %>%
  `rownames<-`(c(.$Exome_ID)) %>%
  dplyr::select(-c(Exome_ID, ID)) %>%
  dplyr::arrange(Genotype)
head(sample_annot)

## Re-order
cnv_matrix = cnv_matrix[, rownames(sample_annot)]

## Colors
list_colors = list()
list_colors[["Genotype"]] = setNames(nm = c("fl/fl", "fl/-"),
                                     c("orange", "darkgreen"))
list_colors[["Histology"]] = setNames(nm = c("HG-MPNST", "LG-MPNST"),
                                      c("darkred", "tomato"))
list_colors[["ScRNA-Seq"]] = setNames(nm = c("Yes", "No"),
                                      c("black", "white"))


# Annotations
fontsize = 10

ha_top = HeatmapAnnotation(
  df = sample_annot,
  cbar = anno_oncoprint_barplot(height = unit(2, "cm")),
  col = list_colors,
  annotation_name_side = "left",
  annotation_name_gp = grid::gpar(fontsize = fontsize),
  na_col = "#F7F7F7")

ha_right = HeatmapAnnotation(
  which = "row",
  rbar = anno_oncoprint_barplot(width = unit(4, "cm")))

# Draw
ht = ComplexHeatmap::oncoPrint(cnv_matrix,
                               # Colors
                               alter_fun = alter_fun,
                               alter_fun_is_vectorized = TRUE,
                               # Barplot and annotation
                               col = vec_colors,
                               top_annotation = ha_top,
                               right_annotation = ha_right,
                               # Legend
                               heatmap_legend_param = heatmap_legend_param,
                               # Sample names
                               show_column_names = TRUE,
                               column_order = colnames(cnv_matrix),
                               column_names_gp = grid::gpar(fontsize = fontsize),
                               # Region names
                               row_names_side = "left",
                               row_names_gp = grid::gpar(fontsize = fontsize),
                               # row_order = rownames(cnv_matrix),
                               # % side
                               pct_side = "right",
                               pct_digits = 0)

# ComplexHeatmap::draw(ht,
#                      merge_legend = TRUE,
#                      heatmap_legend_side = "left",
#                      annotation_legend_side = "left")


# ```{r, fig.width = 12, fig.height = 15}
# ComplexHeatmap::draw(ht,
#                      merge_legend = TRUE,
#                      heatmap_legend_side = "left",
#                      annotation_legend_side = "left")
# ```









