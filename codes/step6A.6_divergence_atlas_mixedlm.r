library(lme4)
library(lmerTest)      # 给 lmer 的固定效应提供 p 值（Satterthwaite/KR）
library(emmeans)
library(multcomp)      # cld() 的泛型
library(multcompView)  # 紧凑字母显示
library(ggplot2)

WD <- "/Users/yufanwang/Desktop/MarmosetWM_Project/revision_NC/af_projection/result"
ROI <- "A45c"

## read fdata
df <- read.csv(file.path(WD, paste0("minKL_indi_", ROI, "_vPaxinos.csv")), stringsAsFactors = TRUE)

## 因子化 + 设定水平顺序
df$species     <- factor(df$species,    levels = c("human-chimpanzee", "human-macaque", "human-marmoset"))
df$hemisphere  <- factor(df$hemisphere, levels = c("LH", "RH"))
df$human_id    <- factor(df$human_id)
df$nonhuman_id <- factor(df$nonhuman_id)

## MixedLM
fit <- lmer(KL ~ species * hemisphere + (1 | human_id) + (1 | nonhuman_id), data = df)

## EMMs
emm <- emmeans(fit, ~ species * hemisphere, pbkrtest.limit = 6300, lmerTest.limit = 6300)

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
write.csv(df_emm,         file.path(WD, paste0("minKL_indi_", ROI, "_vPaxinos_emm.csv")), row.names = FALSE)
write.csv(df_species,     file.path(WD, paste0("minKL_indi_", ROI, "_vPaxinos_emm_pairs_between_species.csv")), row.names = FALSE)
write.csv(df_hemispheres, file.path(WD, paste0("minKL_indi_", ROI, "_vPaxinos_emm_pairs_between_hemispheres.csv")), row.names = FALSE)
write.csv(df_interaction, file.path(WD, paste0("minKL_indi_", ROI, "_vPaxinos_emm_interaction.csv")), row.names = FALSE)

########################################
########################################
########################################

## read fdata
df <- read.csv(file.path(WD, paste0("minKL_indi_", ROI, "_vPaxinos_marmoset.csv")), stringsAsFactors = TRUE)

## 因子化 + 设定水平顺序
df$atlas       <- factor(df$atlas,      levels = c("BNA", "Paxinos"))
df$hemisphere  <- factor(df$hemisphere, levels = c("LH", "RH"))
df$human_id    <- factor(df$human_id)
df$nonhuman_id <- factor(df$nonhuman_id)

## MixedLM
fit <- lmer(KL ~ atlas * hemisphere + (1 | human_id) + (1 | nonhuman_id), data = df)

## EMMs
emm <- emmeans(fit, ~ atlas * hemisphere, pbkrtest.limit = 4000, lmerTest.limit = 4000)

# 2.1 compare between atlas in LH and RH（simple effects）
pairs_between_atlas <- pairs(emm, by = "hemisphere", adjust = "bonferroni") # "bonferroni", "holm", "hochberg", "hommel", "BH", "BY", "fdr"
print("---------- compare between atlas in LH and RH ----------")
print(pairs_between_atlas)

# 2.2 compare between hemispheres in every atlas（simple effects）
pairs_between_hemispheres <- pairs(emm, by = "atlas", adjust = "bonferroni")
print("---------- compare between hemispheres in every atlas ----------")
print(pairs_between_hemispheres)

# 2.3 compare between atlas * hemispheres (interaction) 
inter_diff <- contrast(emm, interaction = "pairwise", adjust = "bonferroni")
print("---------- compare between atlas * hemispheres (interaction) ----------")
print(inter_diff)

# # 2.4 报告“atlas主效应”（对 hemisphere 做边际化）
# emm_atlas <- emmeans(fit, ~ atlas)                 # 对 hemisphere 边际化
# pairs_atlas <- pairs(emm_atlas, adjust = "tukey")  # 经典物种主效应事后比较
# print(emm_atlas)
# print(pairs_atlas)

# # 2.5 报告“半球主效应”（对 atlas 边际化）
# emm_hemisphere <- emmeans(fit, ~ hemisphere)
# pairs_hemisphere <- pairs(emm_hemisphere, adjust = "tukey")
# # print(emm_hemisphere)
# print(pairs_hemisphere)

## EMMs：得到每个物种×半球的估计均值与95%CI
df_emm          <- as.data.frame(summary(emm, infer=c(TRUE, TRUE)))  # emmean, lower.CL, upper.CL
df_atlas        <- as.data.frame(pairs_between_atlas)
df_hemispheres  <- as.data.frame(pairs_between_hemispheres)
df_interaction  <- as.data.frame(inter_diff)

## 导出到 CSV
write.csv(df_emm,         file.path(WD, paste0("minKL_indi_", ROI, "_vPaxinos_marmoset_emm.csv")), row.names = FALSE)
write.csv(df_atlas,     file.path(WD, paste0("minKL_indi_", ROI, "_vPaxinos_marmoset_emm_pairs_between_species.csv")), row.names = FALSE)
write.csv(df_hemispheres, file.path(WD, paste0("minKL_indi_", ROI, "_vPaxinos_marmoset_emm_pairs_between_hemispheres.csv")), row.names = FALSE)
write.csv(df_interaction, file.path(WD, paste0("minKL_indi_", ROI, "_vPaxinos_marmoset_emm_interaction.csv")), row.names = FALSE)
