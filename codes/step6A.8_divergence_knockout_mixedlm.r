library(lme4)
library(lmerTest)      # 给 lmer 的固定效应提供 p 值（Satterthwaite/KR）
library(emmeans)
library(multcomp)      # cld() 的泛型
library(multcompView)  # 紧凑字母显示
library(ggplot2)

WD <- "/Users/yufanwang/Desktop/MarmosetWM_Project/revision_NC/af_projection/result"
ROI <- "A45c"

## read fdata
df <- read.csv(file.path(WD, paste0("deltaKL_indi_", ROI, ".csv")), stringsAsFactors = TRUE)

# 因子化 + 设定水平顺序（可按需调整）
df$species     <- factor(df$species,    levels = c("human-chimpanzee", "human-macaque", "human-marmoset"))
df$hemisphere  <- factor(df$hemisphere, levels = c("LH", "RH"))
df$tract       <- factor(df$tract,      levels = c("AF", "ATR", "SLF3", "UF"))
df$human_id    <- factor(df$human_id)
df$nonhuman_id <- factor(df$nonhuman_id)

## MixedLM
fit <- lmer(deltaKL ~ species * tract * hemisphere + (1 | human_id) + (1 | nonhuman_id), data = df)

## EMMs
# emm <- emmeans(fit, ~ species * tract * hemisphere, pbkrtest.limit = 25000, lmerTest.limit = 25000)
emm <- emmeans(fit, ~ species * tract * hemisphere)

# 2.1 compare between species in LH and RH（simple effects）
pairs_between_species <- pairs(emm, by = c("tract", "hemisphere"), adjust = "bonferroni")
print("---------- compare between species in LH and RH ----------")
print(pairs_between_species)

# 2.2 compare between hemispheres in every species（simple effects）
pairs_between_hemispheres <- pairs(emm, by = c("tract", "species"), adjust = "bonferroni")
print("---------- compare between hemispheres in every species ----------")
print(pairs_between_hemispheres)

# 2.3 compare between tracts in every species（simple effects）
pairs_between_tracts <- pairs(emm, by = c("species", "hemisphere"), adjust = "bonferroni")
print("---------- compare between tracts in every species ----------")
print(pairs_between_tracts)

# 2.4 compare between tract * speceies in LH and RH
# species × tract 交互的 pairwise 对比
emm_st <- emmeans(fit, ~ tract * species | hemisphere)
inter_between_species_tracts <- contrast(emm_st, interaction = "pairwise", adjust = "bonferroni")
print("---------- compare between tract * speceies in LH and RH ----------")
print(inter_between_species_tracts)

## EMMs：得到每个物种×半球的估计均值与95%CI
df_emm          <- as.data.frame(summary(emm, infer=c(TRUE, TRUE)))  # emmean, lower.CL, upper.CL
df_species      <- as.data.frame(pairs_between_species)
df_hemispheres  <- as.data.frame(pairs_between_hemispheres)
df_tracts       <- as.data.frame(pairs_between_tracts)
df_interaction  <- as.data.frame(inter_between_species_tracts)

## 导出到 CSV
write.csv(df_emm,         file.path(WD, paste0("deltaKL_indi_", ROI, "_emm.csv")), row.names = FALSE)
write.csv(df_species,     file.path(WD, paste0("deltaKL_indi_", ROI, "_emm_pairs_between_species.csv")), row.names = FALSE)
write.csv(df_hemispheres, file.path(WD, paste0("deltaKL_indi_", ROI, "_emm_pairs_between_hemispheres.csv")), row.names = FALSE)
write.csv(df_tracts,      file.path(WD, paste0("deltaKL_indi_", ROI, "_emm_pairs_between_tracts.csv")), row.names = FALSE)
write.csv(df_interaction, file.path(WD, paste0("deltaKL_indi_", ROI, "_emm_interaction.csv")), row.names = FALSE)