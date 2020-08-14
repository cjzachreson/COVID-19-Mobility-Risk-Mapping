% filter cases - start with first case date of April 4th (04042020)

input_filename = 'covid-19-cases-by-notification-date-location-and-likely-source-of-infection.csv';

NSW_cases = readtable(input_filename);

% map date-LGA pairs to n cluster-associated cases

map_dateLGA_to_cases = containers.Map('KeyType', 'char', 'ValueType', 'any');

t1 = datetime('2020-06-27');

output_filename = ['NSW_cluster_cases_by_date_and_LGA_' datestr(t1, 'yyyy_mm_dd') '.csv'];

for i = 1:size(NSW_cases, 1)
    
    t_i = NSW_cases.notification_date(i);
    
    if t_i >= t1
        
        if strcmp(NSW_cases.likely_source_of_infection(i),...
                'Locally acquired - contact of a confirmed case and/or in a known cluster')
            
            dateLGA = [datestr(NSW_cases.notification_date(i), 'yyyy-mm-dd'),...
                       '#', NSW_cases.lga_name19{i}];
            
            if ~isKey(map_dateLGA_to_cases, dateLGA)
                map_dateLGA_to_cases(dateLGA) = 1;
            else
                map_dateLGA_to_cases(dateLGA) = map_dateLGA_to_cases(dateLGA) + 1;
            end
        end
        
    end
    
end

% generate output table

dateLGAs = keys(map_dateLGA_to_cases)

date_ = {};
LGA19_ = {};
n_known_cluster_cases_ = zeros(numel(dateLGAs), 1);

for i = 1:numel(dateLGAs)
    
    dateLGA = dateLGAs{i};
    
    sep = strfind(dateLGA, '#');
    
    date_{i, 1} = dateLGA(1:sep-1);
    
    if size(dateLGA, 2) > sep
    LGA19_{i, 1} = dateLGA(sep+1:end);
    else
        LGA19_{i, 1} = 'LGA not listed';
    end
    
    n_known_cluster_cases_(i, 1) = map_dateLGA_to_cases(dateLGA);
    
end

output = table(date_, LGA19_, n_known_cluster_cases_);

writetable(output, output_filename);
    
    
    
    



