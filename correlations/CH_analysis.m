
t1 = datetime('2020-06-27');

t1_str = datestr(t1, 'yyyy_mm_dd');

case_table = readtable(['NSW_cluster_cases_by_date_and_LGA_' t1_str '.csv']);

corr_dirname = 'C:\Users\Cameron\Desktop\COV19_SD_tracking\partition_tables\';

output_filename = ['NSW_outbreak_LGA_case_rank_vs_time_' t1_str '.csv'];

dates = datetime(case_table.date_);

interval = min(dates):max(dates);

LGA_table = readtable([corr_dirname, 'LGA18_code_to_name.csv']);
LGA_name_to_code = containers.Map(LGA_table.LGA18_NAME, LGA_table.LGA18);
LGA_code_to_name = containers.Map(LGA_table.LGA18, LGA_table.LGA18_NAME);

LGA_names = unique(case_table.LGA19_);
LGA_codes = [];
LGA_name_to_index = containers.Map(LGA_names, 1:numel(LGA_names));
timeseries = zeros(numel(interval), numel(LGA_names));

for t = 1:numel(dates)
    
    date_t = dates(t);
    
    LGA_name_t = case_table.LGA19_(t);
    
    j = LGA_name_to_index(LGA_name_t{1});
    i = find(interval == date_t);
    
    timeseries(i, j) = case_table.n_known_cluster_cases_(t);
    

end

% make a rank timeseries

I_cum = cumsum(timeseries);

rank_timeseries = zeros(size(timeseries));

for t = 1:numel(interval)
    
    
    
   [~, rank_timeseries_i] = sort(I_cum(t, :), 'descend');
   
   rank_timeseries(t, rank_timeseries_i) = find(rank_timeseries_i);
   
end

rank_timeseries(I_cum == 0) = 0;

imagesc(rank_timeseries)
   
LGA_rank_vs_time = {};

for t = 1:numel(interval)
    
    rank_list_t = rank_timeseries(t, :);
    
    for rank = 1:numel(LGA_names)
        
        LGA_rank_index = find(rank_list_t == rank);
        
        if isempty(LGA_rank_index)
            LGA_rank_vs_time(rank,t) = {'NaN'};
        else
        
        LGA_in_rank = LGA_names(LGA_rank_index);
            
        LGA_rank_vs_time(rank, t) = {[LGA_in_rank{1},' : ', num2str(I_cum(t, LGA_rank_index))]};%LGA_name_to_code(LGA_in_rank{1});
        
        end
    end
end
   
output = cell2table(LGA_rank_vs_time, 'VariableNames', cellstr(datestr(interval, 'mmm_dd_yyyy'))') ;

writetable(fliplr(output), output_filename)
%LGA_rank_vs_time = LGA_rank_vs_time';




