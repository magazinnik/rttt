# Replication File for Howell and Magazinnik, "Presidential Prescriptions for State Policy" (JPAM, 2017)

## Structure

- All programs for replicating the tables and figures in the paper are in the [Programs](Programs) folder, labeled by the table/figure number. These programs will reproduce the tables and figures into the [Output](Output) folder, either as pdfs (for figures) or tex files (for tables). You only need to set a working directory once, at the top of each program, to the Replication folder; all other paths are relative. 
- There are tex files in the Output folder to compile the tables ([tables.tex](Output/tables.tex)) and figures ([figures.tex](Output/figures.tex)). 
- Some additional information on our research team's coding decisions and on the RttT application is available in the [Additional Information](Additional_Information) folder. 

## Data

All data used in the paper can be found in the [Data](Data) folder, and is documented in greater detail in the [Codebook](Codebook). This includes: 

- [leghist_nagg.dta](Data/leghist_nagg.dta): states' legislative histories with respect to Race to the Top policies (and some controls), at the policy-state-year level
- [leghist_agg.dta](Data/leghist_agg.dta): states' legislative histories with respect to Race to the Top policies (and some controls), aggregated to the Rttt application section level
- [scores_apps12.dta](Data/scores_apps12.dta): states' official scores on their last submitted RttT application
- [speeches_long.dta](Data/speeches_long.dta): State of the State speeches coded for mentions of RttT and other education policies 
- [survey.dta](Data/survey.dta): results from survey of state legislators about impact of RttT on state policy climate
- [an1.csv](Data/an1.csv), [an2.csv](Data/an2.csv), [an3.csv](Data/an3.csv): subsets of the leghist_agg dataset, merged with RttT application scores, for the matching analysis 