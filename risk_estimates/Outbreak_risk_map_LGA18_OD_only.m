% author: Cameron Zachreson 
% released to accompany the manuscript
% "Risk Mapping for COVID-19 Outbreaks Using Mobility Data"
% by Cameron Zachreson, Lewis Mitchell, Michael Lydeamore, Nicolas Rebuli,
% Martin Tomko, and Nicholas Geard

infected_LGAs = [14900] % Liverpool (location of Crossroads Hotel)

prevalence = [1]; %for point-outbreaks, we use a value of 1, for multi-centric outbreaks
% we used active case numbers - this vector corresponds to the values for
% each entry in the "infected_LGAs" vector. 

% this is a list of codes corresponding to the regions of interest 
% should be in the same order as the OD matrix indices
LGA_list = dlmread('LGA_CODE18_sorted.csv');

% a time-interval over which the OD data is aggregated
t1 = '2020-07-03';
t2 = '2020-07-10';

interval_tag = [t1, '_to_', t2];

% a region name (or names) used to label the output file
infected_LGA_name = 'Liverpool';

output_filename = [infected_LGA_name '_risk_map_OD_only_' interval_tag '_random.csv'];

% averages over the specified interval (t1 to t2) for each 8-hr time 
% interval in the Facebook Data, 
% the raw data is provided by the Facebook Data For Good program
% and is subject to release conditions. 
% the files listed below are place-holders with random values for all
% entries (they will not reproduce the estimates in the paper)
OD_mat_0000 = dlmread(['LGA2018_OD_mat_0000_rand.csv']); 
OD_mat_0800 = dlmread(['LGA2018_OD_mat_0800_rand.csv']);
OD_mat_1600 = dlmread(['LGA2018_OD_mat_1600_rand.csv']);

OD_mat = [OD_mat_0000 + OD_mat_0800 + OD_mat_1600];

% the code -> name correspondence can come from any sufficiently complete
% file, the .dbf files from ABS are complete and make good references.
LGA_to_name = readtable('LGA18_code_to_name.csv');

code_to_name = containers.Map(LGA_to_name.LGA18, LGA_to_name.LGA18_NAME);
name_to_code = containers.Map(LGA_to_name.LGA18_NAME, LGA_to_name.LGA18);

code_to_index = containers.Map(LGA_list, 1:numel(LGA_list));
index_to_code = containers.Map(1:numel(LGA_list), LGA_list);

%initialise 'incidence' vector
I_LGA = zeros(size(LGA_list));

% 'infect' the selected LGA(s)
% if active case numbers are to be used, this is where they are included 
% the below is for a 'point outbreak' where only one region acts as
% transmission centre. For a multi-centric outbreak, add more infected LGAs
% to the infected_LGAs vector

for i = 1:numel(infected_LGAs)
    infected_LGA = infected_LGAs(i);

I_LGA(code_to_index(infected_LGA)) = prevalence(i);

end

I_UR = OD_mat * I_LGA;

I_UR = I_UR ./ sum(I_UR);

LGA18 = LGA_list;

% write names in order for output tables
LGA18_NAME = {};
for i = 1:numel(LGA18)
    
    name = code_to_name(LGA18(i));
    
    LGA18_NAME{i, 1} = name;
    
end

risk_OD_only = I_UR;
rank = [1:numel(risk_OD_only)]';

OD_risk_table = table(LGA18, LGA18_NAME, risk_OD_only);
OD_risk_table = sortrows(OD_risk_table, 3, 'descend');
OD_risk_table = addvars(OD_risk_table, rank);
writetable(OD_risk_table, output_filename);




