library(lme4)
library(lmerTest)      # 给 lmer 的固定效应提供 p 值（Satterthwaite/KR）
library(emmeans)
library(multcomp)      # cld() 的泛型
library(multcompView)  # 紧凑字母显示
library(ggplot2)

WD <- "/Users/yufanwang/Desktop/MarmosetWM_Project/revision_NC/af_projection/result"
ROI <- "A45c"

## read fdata
df <- read.csv(file.path(WD, paste0("minKL_indi_", ROI, "_ucd_minds.csv")), stringsAsFactors = TRUE)

## 因子化 + 设定水平顺序
df$species     <- factor(df$species,    levels = c("human-chimpanzee", "human-macaque", "human-marmoset"))
df$hemisphere  <- factor(df$hemisphere, levels = c("LH", "RH"))
df$human_id    <- factor(df$human_id)
df$nonhuman_id <- factor(df$nonhuman_id)

## MixedLM
fit <- lmer(KL ~ species * hemisphere + (1 | human_id) + (1 | nonhuman_id), data = df)

## EMMs
emm <- emmeans(fit, ~ species * hemisphere) #, pbkrtest.limit = 14000, lmerTest.limit = 14000)

# 2.1 compare between species in LH and RH（simple effects）
pairs_between_species <- pairs(emm, by = "hemisphere", adjust = "bonferroni") # "bonferroni", "holm", "hochberg", "hommel", "BH", "BY", "fdr"
print("---------- compare between species in LH and RH ----------")
print(pairs_between_species)

# 2.2 compare between hemispheres in every species（simple effects）
pairs_between_hemispheres <- pairs(emm, by = "species", adjust = "bonferroni")
print("---------- compare between hemispheres in every species ----------")
print(pairs_between_hemispheres)

# 2.3 compare between species * hemispheres (interaction) 
inter_diff <- contrast(emm, interaction = "pairwise", adjust = "bonferroni")
print("---------- compare between species * hemispheres (interaction) ----------")
print(inter_diff)

# # 2.4 报告“物种主效应”（对 hemisphere 做边际化）
# emm_species <- emmeans(fit, ~ species)                 # 对 hemisphere 边际化
# pairs_species <- pairs(emm_species, adjust = "tukey")  # 经典物种主效应事后比较
# print(emm_species)
# print(pairs_species)

# # 2.5 报告“半球主效应”（对 species 边际化）
# emm_hemisphere <- emmeans(fit, ~ hemisphere)
# pairs_hemisphere <- pairs(emm_hemisphere, adjust = "tukey")
# # print(emm_hemisphere)
# print(pairs_hemisphere)

## EMMs：得到每个物种×半球的估计均值与95%CI
df_emm          <- as.data.frame(summary(emm, infer=c(TRUE, TRUE)))  # emmean, lower.CL, upper.CL
df_species      <- as.data.frame(pairs_between_species)
df_hemispheres  <- as.data.frame(pairs_between_hemispheres)
df_interaction  <- as.data.frame(inter_diff)

## 导出到 CSV
write.csv(df_emm,         file.path(WD, paste0("minKL_indi_", ROI, "_ucd_minds_emm.csv")), row.names = FALSE)
write.csv(df_species,     file.path(WD, paste0("minKL_indi_", ROI, "_ucd_minds_emm_pairs_between_species.csv")), row.names = FALSE)
write.csv(df_hemispheres, file.path(WD, paste0("minKL_indi_", ROI, "_ucd_minds_emm_pairs_between_hemispheres.csv")), row.names = FALSE)
write.csv(df_interaction, file.path(WD, paste0("minKL_indi_", ROI, "_ucd_minds_emm_interaction.csv")), row.names = FALSE)


########################################
########################################
########################################

## read fdata
df <- read.csv(file.path(WD, paste0("minKL_indi_", ROI, "_ucd_minds_macaque.csv")), stringsAsFactors = TRUE)

## 因子化 + 设定水平顺序
df$site        <- factor(df$site,       levels = c("tvb", "ucd"))
df$hemisphere  <- factor(df$hemisphere, levels = c("LH", "RH"))
df$human_id    <- factor(df$human_id)
df$nonhuman_id <- factor(df$nonhuman_id)

## MixedLM
fit <- lmer(KL ~ site * hemisphere + (1 | human_id) + (1 | nonhuman_id), data = df)

## EMMs
emm <- emmeans(fit, ~ site * hemisphere) #, pbkrtest.limit = 4000, lmerTest.limit = 4000)

# 2.1 compare between site in LH and RH（simple effects）
pairs_between_site <- pairs(emm, by = "hemisphere", adjust = "bonferroni") # "bonferroni", "holm", "hochberg", "hommel", "BH", "BY", "fdr"
print("---------- compare between site in LH and RH ----------")
print(pairs_between_site)

# 2.2 compare between hemispheres in every site（simple effects）
pairs_between_hemispheres <- pairs(emm, by = "site", adjust = "bonferroni")
print("---------- compare between hemispheres in every site ----------")
print(pairs_between_hemispheres)

# 2.3 compare between site * hemispheres (interaction) 
inter_diff <- contrast(emm, interaction = "pairwise", adjust = "bonferroni")
print("---------- compare between site * hemispheres (interaction) ----------")
print(inter_diff)

# # 2.4 报告“site主效应”（对 hemisphere 做边际化）
# emm_site <- emmeans(fit, ~ site)                 # 对 hemisphere 边际化
# pairs_site <- pairs(emm_site, adjust = "tukey")  # 经典物种主效应事后比较
# print(emm_site)
# print(pairs_site)

# # 2.5 报告“半球主效应”（对 site 边际化）
# emm_hemisphere <- emmeans(fit, ~ hemisphere)
# pairs_hemisphere <- pairs(emm_hemisphere, adjust = "tukey")
# # print(emm_hemisphere)
# print(pairs_hemisphere)

## EMMs：得到每个物种×半球的估计均值与95%CI
df_emm          <- as.data.frame(summary(emm, infer=c(TRUE, TRUE)))  # emmean, lower.CL, upper.CL
df_site         <- as.data.frame(pairs_between_site)
df_hemispheres  <- as.data.frame(pairs_between_hemispheres)
df_interaction  <- as.data.frame(inter_diff)

## 导出到 CSV
write.csv(df_emm,         file.path(WD, paste0("minKL_indi_", ROI, "_ucd_minds_macaque_emm.csv")), row.names = FALSE)
write.csv(df_site,     file.path(WD, paste0("minKL_indi_", ROI, "_ucd_minds_macaque_emm_pairs_between_species.csv")), row.names = FALSE)
write.csv(df_hemispheres, file.path(WD, paste0("minKL_indi_", ROI, "_ucd_minds_macaque_emm_pairs_between_hemispheres.csv")), row.names = FALSE)
write.csv(df_interaction, file.path(WD, paste0("minKL_indi_", ROI, "_ucd_minds_macaque_emm_interaction.csv")), row.names = FALSE)


########################################
########################################
########################################

## read fdata
df <- read.csv(file.path(WD, paste0("minKL_indi_", ROI, "_ucd_minds_marmoset.csv")), stringsAsFactors = TRUE)

## 因子化 + 设定水平顺序
df$site        <- factor(df$site,       levels = c("MBM", "minds"))
df$hemisphere  <- factor(df$hemisphere, levels = c("LH", "RH"))
df$human_id    <- factor(df$human_id)
df$nonhuman_id <- factor(df$nonhuman_id)

## MixedLM
fit <- lmer(KL ~ site * hemisphere + (1 | human_id) + (1 | nonhuman_id), data = df)

## EMMs
emm <- emmeans(fit, ~ site * hemisphere, pbkrtest.limit = 10720, lmerTest.limit = 10720)

# 2.1 compare between site in LH and RH（simple effects）
pairs_between_site <- pairs(emm, by = "hemisphere", adjust = "bonferroni") # "bonferroni", "holm", "hochberg", "hommel", "BH", "BY", "fdr"
print("---------- compare between site in LH and RH ----------")
print(pairs_between_site)

# 2.2 compare between hemispheres in every site（simple effects）
pairs_between_hemispheres <- pairs(emm, by = "site", adjust = "bonferroni")
print("---------- compare between hemispheres in every site ----------")
print(pairs_between_hemispheres)

# 2.3 compare between site * hemispheres (interaction) 
inter_diff <- contrast(emm, interaction = "pairwise", adjust = "bonferroni")
print("---------- compare between site * hemispheres (interaction) ----------")
print(inter_diff)

# # 2.4 报告“site主效应”（对 hemisphere 做边际化）
# emm_site <- emmeans(fit, ~ site)                 # 对 hemisphere 边际化
# pairs_site <- pairs(emm_site, adjust = "tukey")  # 经典物种主效应事后比较
# print(emm_site)
# print(pairs_site)

# # 2.5 报告“半球主效应”（对 site 边际化）
# emm_hemisphere <- emmeans(fit, ~ hemisphere)
# pairs_hemisphere <- pairs(emm_hemisphere, adjust = "tukey")
# # print(emm_hemisphere)
# print(pairs_hemisphere)

## EMMs：得到每个物种×半球的估计均值与95%CI
df_emm          <- as.data.frame(summary(emm, infer=c(TRUE, TRUE)))  # emmean, lower.CL, upper.CL
df_site         <- as.data.frame(pairs_between_site)
df_hemispheres  <- as.data.frame(pairs_between_hemispheres)
df_interaction  <- as.data.frame(inter_diff)

## 导出到 CSV
write.csv(df_emm,         file.path(WD, paste0("minKL_indi_", ROI, "_ucd_minds_marmoset_emm.csv")), row.names = FALSE)
write.csv(df_site,     file.path(WD, paste0("minKL_indi_", ROI, "_ucd_minds_marmoset_emm_pairs_between_species.csv")), row.names = FALSE)
write.csv(df_hemispheres, file.path(WD, paste0("minKL_indi_", ROI, "_ucd_minds_marmoset_emm_pairs_between_hemispheres.csv")), row.names = FALSE)
write.csv(df_interaction, file.path(WD, paste0("minKL_indi_", ROI, "_ucd_minds_marmoset_emm_interaction.csv")), row.names = FALSE)
