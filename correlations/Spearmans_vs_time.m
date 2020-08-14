% computes Spearman's rank correlation between our predicted risk values
% and the case values in the ground-truth diagnosis dates

t1 = datetime('2020-06-27');

t1_str = datestr(t1, 'yyyy_mm_dd');

CH_input = readtable(['NSW_outbreak_LGA_case_rank_vs_time_' t1_str '.csv']);

risk_input = readtable('Liverpool_risk_map_OD_only_2020-06-27_to_2020-07-04.csv');

output_filename = ['Crossroads_Spearmans_OD_risk_vs_NSW_cluster_cases_LP_' t1_str '.csv'];

% fix up names - make sure they match between the case data input and the
% risk input (in this case it means removing parenthesis (C) etc....) 

for i = 1:numel(risk_input.LGA18_NAME)
    name_i = risk_input.LGA18_NAME{i};
    
    sep_index = strfind(name_i, '('); 
    if ~isempty(sep_index)
        sep_index = sep_index(1);
        
        name_fixed = name_i(1:sep_index - 2);
        risk_input.LGA18_NAME{i} = name_fixed;
    end
    
end

n_risk = nnz(risk_input.CH_risk_OD_only);

LGA_risk_map = containers.Map(risk_input.LGA18_NAME(1:n_risk), risk_input.CH_risk_OD_only(1:n_risk));

dates = CH_input.Properties.VariableNames';

date_0 = datetime(dates{end}, 'InputFormat', 'MM_dd_yyyy');
date_f = datetime(dates{1}, 'InputFormat', 'MM_dd_yyyy');

interval = date_0:date_f;

Spearmans_corr = NaN(numel(interval), 1);
P_val = NaN(numel(interval), 1);
I_cum = NaN(numel(interval), 1);
CI_hi = NaN(numel(interval), 1);
CI_low = NaN(numel(interval), 1);
for t = 1:numel(interval)
    
    dates{(end + 1) - t}
    
    cases_t = [];
    risk_t = [];
    LGAs_t = {};
    
    eval([' CH_t = CH_input.' dates{(end + 1) - t}]);
    
    for i = 1:numel(CH_t)
        
        CH_i = CH_t{i};
        
        cases_i = str2double(CH_i(strfind(CH_i, ':') + 1 : end));
        
        if ~isnan(cases_i)
            
            cases_t(i) = cases_i;
            
            LGA_i = CH_i(1:strfind(CH_i, '(') - 2);
            
            LGAs_t{i} = LGA_i;
            
            if isKey(LGA_risk_map, LGA_i)
            risk_t(i) = LGA_risk_map(LGA_i);
            else
                LGA_i
                risk_t(i) = 0;
            end
            
        end
        
    end
    
    [Spearmans_corr(t), P_val(t)] = corr(cases_t', risk_t', 'type', 'Spearman');
    
    [CI_hi(t), CI_low(t)] = CI_spearmans(Spearmans_corr(t), numel(cases_t));

    
    I_cum(t) = sum(cases_t);
%      interval(t)
%      cases_t'
%      risk_t'
    
  
end

    good_indices = (find(isnan(Spearmans_corr), 1, 'last') + 1):find(~isnan(Spearmans_corr),1, 'last');

    figure(1)
    yyaxis left
    xlabel('Date')
    plot(interval(good_indices)', Spearmans_corr(good_indices), 'k-*')
    hold on
    plot(interval(good_indices)', CI_hi(good_indices), 'k--')
    plot(interval(good_indices)', CI_low(good_indices), 'k--')
    ylabel('Spearmans Rank Correlation +- 95% CI')
    yyaxis right
    ylabel('total cases')
    plot(interval(good_indices), I_cum(good_indices), 'r-o')
    hold off
    
    

saveas(figure(1), 'spearmans_plot.pdf', 'pdf')

dates_ = datestr(interval(good_indices), 'yyyy-mm-dd');

Spearmans_ = Spearmans_corr(good_indices);

Pval_ = P_val(good_indices);

I_cum_ = I_cum(good_indices);

CI_hi_ = CI_hi(good_indices);
CI_low_ = CI_low(good_indices);

output = table(dates_, I_cum_, Spearmans_, Pval_, CI_hi_, CI_low_);

writetable(output, output_filename);





