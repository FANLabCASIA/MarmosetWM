resultpath = '/n02dat01/users/yfwang/MarmosetWM/result/robustness/';

r_1 = zeros(24,24,45);
r_2 = zeros(110,110,45);
r_3 = zeros(24,110,45);

for i=1:45
    x = load(strcat(resultpath, 'tract-wise/correlation_within_across_cohort_tract', num2str(i), '.mat'));
    r_1(:,:,i) = x.r_1;
    r_2(:,:,i) = x.r_2;
    r_3(:,:,i) = x.r_3;
end

index_1 = [1:24];
index_2 = [1:24];
r_1 = r_1(index_1, index_1, :);
r_2 = r_2(index_2, index_2, :);
r_3 = r_3(index_1, index_2, :);

r_1 = nanmean(r_1,3);
r_2 = nanmean(r_2,3);
r_3 = nanmean(r_3,3);

r_1 = r_1(r_1~=0);
r_2 = r_2(r_2~=0);
r_3 = r_3(r_3~=0);

save(strcat(resultpath, 'within_MBM.txt'), 'r_1', '-ascii');
save(strcat(resultpath, 'within_brain_minds.txt'), 'r_2', '-ascii');
save(strcat(resultpath, 'across_cohort.txt'), 'r_3', '-ascii');

[p,h,stats] = ranksum(r_1, r_2, 'method', 'exact')
[p,h,stats] = ranksum(r_1, r_3, 'method', 'exact')
[p,h,stats] = ranksum(r_2, r_3, 'method', 'exact')


% mean_subjects_1 = zeros(45,1);
% standard_subjects_1 = zeros(45,1);
% for k=1:45
%     r_k = r_1(:,:,k);
%     nonZeroIndices = (r_k~=0);
%     nonZeroValues = r_k(nonZeroIndices);
%     mean_subjects_1(k) = nanmean(nonZeroValues);
%     standard_subjects_1(k) = nanstd(nonZeroValues);
% end
% mean_tracts_1 = nanmean(mean_subjects_1);
% standard_tracts_1 = nanstd(mean_subjects_1);
% disp(strcat('Within cohort (MBM), mean = ', num2str(mean_tracts_1), ', std = ', num2str(standard_tracts_1)));
% 
% mean_subjects_2 = zeros(45,1);
% standard_subjects_2 = zeros(45,1);
% for k=1:45
%     r_k = r_2(:,:,k);
%     nonZeroIndices = (r_k~=0);
%     nonZeroValues = r_k(nonZeroIndices);
%     mean_subjects_2(k) = nanmean(nonZeroValues);
%     standard_subjects_2(k) = nanstd(nonZeroValues);
% end
% mean_tracts_2 = nanmean(mean_subjects_2);
% standard_tracts_2 = nanstd(mean_subjects_2);
% disp(strcat('Within cohort (BrainMINDS), mean = ', num2str(mean_tracts_2), ', std = ', num2str(standard_tracts_2)));
% 
% mean_subjects_3 = zeros(45,1);
% standard_subjects_3 = zeros(45,1);
% for k=1:45
%     r_k = r_3(:,:,k);
%     nonZeroIndices = (r_k~=0);
%     nonZeroValues = r_k(nonZeroIndices);
%     mean_subjects_3(k) = nanmean(nonZeroValues);
%     standard_subjects_3(k) = nanstd(nonZeroValues);
% end
% mean_tracts_3 = nanmean(mean_subjects_3);
% standard_tracts_3 = nanstd(mean_subjects_3);
% disp(strcat('Across cohort, mean = ', num2str(mean_tracts_3), ', std = ', num2str(standard_tracts_3)));
