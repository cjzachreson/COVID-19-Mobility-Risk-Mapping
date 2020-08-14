The scripts and input files in this folder 
are to accomany the manuscript entitled 
"Risk mapping for COVID-19 outbreaks using mobility data" 
by Cameron Zachreson, Lewis Mitchell, Michael Lydeamore, 
Nicolas Rebuli, Martin Tomko, and Nicholas Geard


filter_case_data.m

pulls out a subset of the case data given in the file
 'covid-19-cases-by-notification-date-location-and-likely-source-of-infection.csv'

Which was downloaded from NSW Health, and produces the file
'NSW_cluster_cases_by_date_and_LGA_2020_06_27.csv'

Which is processed by the script 'CH_analysis.m'
to produce 
'NSW_outbreak_LGA_case_rank_vs_time_2020_06_27.csv'

Then the file 'Spearmans_vs_time.m' 

computes Spearman's correlation between the risk values specified in 
'Liverpool_risk_map_OD_only_2020-06-27_to_2020-07-04.csv'

and the case data specified in 
'NSW_outbreak_LGA_case_rank_vs_time_2020_06_27.csv'

to produce 'spearmans_plot.pdf' 
and 'Crossroads_Spearmans_OD_risk_vs_NSW_cluster_cases_LP_2020_06_27.csv'

Which are reproductions of the data reported in the main text. 