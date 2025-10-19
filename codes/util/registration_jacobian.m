%% ================= Jacobian QC (ANTs registration) =================
%  1) 支持 detJ 或 logJ
%  2) 汇总全脑与 ROI 内指标
%  3) 输出 CSV 表格

clear; clc;

addpath(genpath('/n05dat/yfwang/user/software/MatlabToolbox/NIFTI'));

%% ============ 配置 ============
% 你的被试列表（按需替换）
subjects = textread('/gpfs/userdata/yfwang/MarmosetWM/support_data/marmoset_MBM_list.txt', '%s');
% subjects = { ...
%   'subj01', 'subj02' ...
% };

% 每个被试的文件路径（根据你的命名规则拼接）
datapath = '/gpfs/userdata/yfwang/Data/marmoset_MBM_preprocessed/';
resultpath = '/gpfs/userdata/yfwang/MarmosetWM/result/registration_qc/';

brainMask = load_untouch_nii('/gpfs/userdata/yfwang/MarmosetWM/support_data/MBM_v3.0.1/mask_brain.nii.gz');
brainMask = brainMask.img > 0;

% ROI 列表（名称-路径）
roiList = { ...
  'seed',  strcat(resultpath, 'seed.nii.gz'); ...
  'target1',  strcat(resultpath, 'target1.nii.gz'); ...
  'target2',   strcat(resultpath, 'target2.nii.gz') ...
};

% 你的 Jacobian 类型: true=logJ, false=detJ
isLogJacobian = true;

% 是否绘制每个被试的全脑 logJ 直方图
doPlotHist = false;

% 输出
outCsv = fullfile(resultpath, 'qc_jacobian_roi.csv');

%% ============ 读取 ROI 掩模 ============
nROI = size(roiList,1);
roiNames = roiList(:,1);
roiPaths = roiList(:,2);
roiImgs = cell(nROI,1);
for i=1:nROI
    roi_file = load_untouch_nii(roiPaths{i});
    roiImgs{i} = roi_file.img;
end

%% ============ 主循环 ============
rows = [];
for s = 1:numel(subjects)
    fprintf('>> Processing %s\n', subjects{s});

    % 读入图像
    jac = load_untouch_nii(strcat(datapath, subjects{s}, '/affine/ind2MBMv3/ind2MBMv31InverseWarp_logJ.nii.gz')); % detJ 或 logJ
    jac = jac.img;
    
    % 若是 detJ，转换到 logJ 方便统计；同时保留 detJ<=0 检查
    if isLogJacobian
        logJ = jac;
        detJ = exp(logJ);
    else
        detJ = jac;
        logJ = log(detJ + eps); % 防止 log(0)
    end

    % ------- 全脑指标 -------
    valsBrain = logJ(brainMask);
    % 均值/标准差(logJ), |logJ| 的 p95
    mean_logJ = mean(valsBrain(~isnan(valsBrain)));
    std_logJ  = std(valsBrain(~isnan(valsBrain)));
    p95_abs_logJ = prctile(abs(valsBrain(~isnan(valsBrain))), 95);

    % detJ<=0 百分比
    valsDet = detJ(brainMask);
    pct_detJ_le0 = 100 * mean(valsDet(~isnan(valsDet)) <= 0);

    % ------- ROI 指标 -------
    roiStats = struct();
    for r = 1:nROI
        mask = roiImgs{r} > 0;
        % 若 ROI 与 brainMask 有不一致，交集一下更稳妥
        mask = mask & brainMask;

        roiVals = logJ(mask);
        roiStats.(sprintf('%s_median_abs_logJ', roiNames{r})) = median(abs(roiVals(~isnan(roiVals))));
        roiStats.(sprintf('%s_p95_abs_logJ',    roiNames{r})) = prctile(abs(roiVals(~isnan(roiVals))), 95);
    end

    % ------- 行汇总 -------
    row = struct();
    row.subject = string(subjects{s});
    row.mean_logJ = mean_logJ;
    row.std_logJ  = std_logJ;
    row.p95_abs_logJ = p95_abs_logJ;
    row.pct_detJ_le0 = pct_detJ_le0;

    % 合并 ROI 指标
    fns = fieldnames(roiStats);
    for k = 1:numel(fns)
        row.(fns{k}) = roiStats.(fns{k});
    end

    rows = [rows; row]; %#ok<AGROW>

    % ------- 可选绘图 -------
    if doPlotHist
        figure('Color','w'); 
        histogram(valsBrain(~isnan(valsBrain)), 100);
        xlabel('log(Jacobian)'); ylabel('Voxel count');
        title(sprintf('%s logJ histogram', subjects{s}));
        drawnow;
    end
end

%% ============ 导出 CSV ============
T = struct2table(rows);
writetable(T, outCsv);
fprintf('QC table saved: %s\n', outCsv);

%% ============ 实用解释建议（打印阈值总结） ============
fprintf('\n--- Quick summary (heuristics) ---\n');
fprintf('Recommended good quality (heuristics):\n');
fprintf('  median(|logJ|) in ROIs < ~0.15;  p95(|logJ|) not too large;  detJ<=0 %% = 0\n');
fprintf('Use ROI median(|logJ|) as covariate in LMM if needed.\n');