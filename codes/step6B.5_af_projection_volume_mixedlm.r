library(lme4)
library(lmerTest)      # 给 lmer 的固定效应提供 p 值（Satterthwaite/KR）
library(emmeans)
library(multcomp)      # cld() 的泛型
library(multcompView)  # 紧凑字母显示
library(ggplot2)
library(dplyr)

WD <- "/Users/yufanwang/Desktop/MarmosetWM_Project/revision_NC/af_projection/result"
ROI <- "A45c"

## read fdata
df <- read.csv(file.path(WD, paste0("af_projection_", ROI, "_volume.csv")), stringsAsFactors = TRUE)

## factorize
df$species    <- factor(df$species,    levels = c("human","chimpanzee","macaque","marmoset"))
df$hemisphere <- factor(df$hemisphere, levels = c("LH","RH"))

# ===== 体积变量预处理 =====
# # 方案 A：全局标准化（简单）
# df <- df %>%
#   mutate(
#     z_wb = scale(volume_wb)[, 1],
#     z_gm = scale(volume_gm)[, 1],
#     z_wm = scale(volume_wm)[, 1]
#   )

# 方案 B：物种内中心化（更稳健地控制物种总体体积差异）
df <- df %>%
  group_by(species) %>%
  mutate(
    volume_wb = scale(volume_wb, center = TRUE, scale = FALSE)[, 1],
    volume_gm = scale(volume_gm, center = TRUE, scale = FALSE)[, 1],
    volume_wm = scale(volume_wm, center = TRUE, scale = FALSE)[, 1]
  ) %>%
  ungroup()

#################
### wb volume ###
#################
## MixedLM
fit <- lmer(connectivity_score ~ species * hemisphere + volume_wb + (1 | subject_id), data = df)
anova_fit <- anova(fit)
print(anova_fit)

## EMMs
emm <- emmeans(fit, ~ species * hemisphere)

# (1) compare between species in LH and RH（simple effects）
pairs_between_species <- pairs(emm, by = "hemisphere", adjust = "bonferroni")
print("---------- compare between species in LH and RH ----------")
print(pairs_between_species)

# (2) compare between hemispheres in every species（simple effects）
pairs_between_hemispheres <- pairs(emm, by = "species", adjust = "bonferroni")
print("---------- compare between hemispheres in every species ----------")
print(pairs_between_hemispheres)

# (3) compare between species * hemispheres (interaction) 
inter_diff <- contrast(emm, interaction = "pairwise", adjust = "bonferroni")
print("---------- compare between species * hemispheres (interaction) ----------")
print(inter_diff)

## EMMs：estimated marginal means +- 95%CI
df_emm          <- as.data.frame(summary(emm, infer=c(TRUE, TRUE)))  # emmean, lower.CL, upper.CL
df_species      <- as.data.frame(pairs_between_species)
df_hemispheres  <- as.data.frame(pairs_between_hemispheres)
df_interaction  <- as.data.frame(inter_diff)

## write to csv
write.csv(df_emm,         file.path(WD, paste0("af_projection_", ROI, "_volume_wb_emm.csv")), row.names = FALSE)
write.csv(df_species,     file.path(WD, paste0("af_projection_", ROI, "_volume_wb_emm_pairs_between_species.csv")), row.names = FALSE)
write.csv(df_hemispheres, file.path(WD, paste0("af_projection_", ROI, "_volume_wb_emm_pairs_between_hemispheres.csv")), row.names = FALSE)
write.csv(df_interaction, file.path(WD, paste0("af_projection_", ROI, "_volume_wb_emm_interaction.csv")), row.names = FALSE)


#################
### gm volume ###
#################
## MixedLM
fit <- lmer(connectivity_score ~ species * hemisphere + volume_gm + (1 | subject_id), data = df)
anova_fit <- anova(fit)
print(anova_fit)

## EMMs
emm <- emmeans(fit, ~ species * hemisphere)

# (1) compare between species in LH and RH（simple effects）
pairs_between_species <- pairs(emm, by = "hemisphere", adjust = "bonferroni")
print("---------- compare between species in LH and RH ----------")
print(pairs_between_species)

# (2) compare between hemispheres in every species（simple effects）
pairs_between_hemispheres <- pairs(emm, by = "species", adjust = "bonferroni")
print("---------- compare between hemispheres in every species ----------")
print(pairs_between_hemispheres)

# (3) compare between species * hemispheres (interaction) 
inter_diff <- contrast(emm, interaction = "pairwise", adjust = "bonferroni")
print("---------- compare between species * hemispheres (interaction) ----------")
print(inter_diff)

## EMMs：estimated marginal means +- 95%CI
df_emm          <- as.data.frame(summary(emm, infer=c(TRUE, TRUE)))  # emmean, lower.CL, upper.CL
df_species      <- as.data.frame(pairs_between_species)
df_hemispheres  <- as.data.frame(pairs_between_hemispheres)
df_interaction  <- as.data.frame(inter_diff)

## write to csv
write.csv(df_emm,         file.path(WD, paste0("af_projection_", ROI, "_volume_gm_emm.csv")), row.names = FALSE)
write.csv(df_species,     file.path(WD, paste0("af_projection_", ROI, "_volume_gm_emm_pairs_between_species.csv")), row.names = FALSE)
write.csv(df_hemispheres, file.path(WD, paste0("af_projection_", ROI, "_volume_gm_emm_pairs_between_hemispheres.csv")), row.names = FALSE)
write.csv(df_interaction, file.path(WD, paste0("af_projection_", ROI, "_volume_gm_emm_interaction.csv")), row.names = FALSE)


#################
### wm volume ###
#################
## MixedLM
fit <- lmer(connectivity_score ~ species * hemisphere + volume_wm + (1 | subject_id), data = df)
anova_fit <- anova(fit)
print(anova_fit)

## EMMs
emm <- emmeans(fit, ~ species * hemisphere)

# (1) compare between species in LH and RH（simple effects）
pairs_between_species <- pairs(emm, by = "hemisphere", adjust = "bonferroni")
print("---------- compare between species in LH and RH ----------")
print(pairs_between_species)

# (2) compare between hemispheres in every species（simple effects）
pairs_between_hemispheres <- pairs(emm, by = "species", adjust = "bonferroni")
print("---------- compare between hemispheres in every species ----------")
print(pairs_between_hemispheres)

# (3) compare between species * hemispheres (interaction) 
inter_diff <- contrast(emm, interaction = "pairwise", adjust = "bonferroni")
print("---------- compare between species * hemispheres (interaction) ----------")
print(inter_diff)

## EMMs：estimated marginal means +- 95%CI
df_emm          <- as.data.frame(summary(emm, infer=c(TRUE, TRUE)))  # emmean, lower.CL, upper.CL
df_species      <- as.data.frame(pairs_between_species)
df_hemispheres  <- as.data.frame(pairs_between_hemispheres)
df_interaction  <- as.data.frame(inter_diff)

## write to csv
write.csv(df_emm,         file.path(WD, paste0("af_projection_", ROI, "_volume_wm_emm.csv")), row.names = FALSE)
write.csv(df_species,     file.path(WD, paste0("af_projection_", ROI, "_volume_wm_emm_pairs_between_species.csv")), row.names = FALSE)
write.csv(df_hemispheres, file.path(WD, paste0("af_projection_", ROI, "_volume_wm_emm_pairs_between_hemispheres.csv")), row.names = FALSE)
write.csv(df_interaction, file.path(WD, paste0("af_projection_", ROI, "_volume_wm_emm_interaction.csv")), row.names = FALSE)