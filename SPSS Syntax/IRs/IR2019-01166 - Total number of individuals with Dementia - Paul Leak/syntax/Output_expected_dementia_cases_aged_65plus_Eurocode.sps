* Encoding: UTF-8.
*Paul Leak - Scottih Government
*Output Dementia prevalence cases by Age Band.
* and by Gender (Male, Female) for each HSCPs using ISD population estimates and Eurocode Prevalence rates.
*Year: 2017.

DEFINE  !output()
'/conf/sourcedev/TableauUpdates/IRs/IR2019-01166 - Total number of individuals with Dementia - Paul Leak/Output/'
!enddefine.

*Read in Population data by agegroups and Gender.
get file =  !output + 'Pop2017_by_HSCP_selected_AgeGroups.sav'.

rename variables gender_type = gender.

*Create expected Dementia prevalence cases variable. 
compute exp_cases = 0.

*Calculate exected number of Dementia cases based on Eurocode prevalence rates (Eurocode: Prevalence of Dementia in Europe). 
*Female.
if gender = 'Female' and agegroup = '60-64 years' exp_cases = pop*0.009.
if gender = 'Female' and agegroup = '65-69 years' exp_cases = pop*0.014.
if gender = 'Female' and agegroup = '70-74 years' exp_cases = pop*0.038.
if gender = 'Female' and agegroup = '75-79 years' exp_cases = pop*0.076.
if gender = 'Female' and agegroup = '80-84 years' exp_cases = pop*0.164.
if gender = 'Female' and agegroup = '85-89 years' exp_cases = pop*0.285.
if gender = 'Female' and agegroup = '90+ years' exp_cases = pop*0.466.
execute.

*Calculate exected number of Dementia cases based on Eurocod prevalence rates (Eurocode: Prevalence of Dementia in Europe). 
*Male.
if gender = 'Male' and agegroup = '60-64 years' exp_cases = pop*0.002.
if gender = 'Male' and agegroup = '65-69 years' exp_cases = pop*0.018.
if gender = 'Male' and agegroup = '70-74 years' exp_cases = pop*0.032.
if gender = 'Male' and agegroup = '75-79 years' exp_cases = pop*0.070.
if gender = 'Male' and agegroup = '80-84 years' exp_cases = pop*0.145.
if gender = 'Male' and agegroup = '85-89 years' exp_cases = pop*0.209.
if gender = 'Male' and agegroup = '90+ years' exp_cases = pop*0.308.
execute.

save outfile = !output + 'Expected_total_Dementia_cases_by_Agegroups-Gender_update.sav'
   /drop pop.

get file =  !output + 'Expected_total_Dementia_cases_by_Agegroups-Gender_update.sav'.

*Select agegroups for comparison of expected prevalence cases .
select if agegroup ne '60-64'.
execute.

*Aggregate total individuals aged 65+ .
aggregate outfile =*
 /break hscp gender 
  /tot_exp_cases = sum(exp_cases).
execute.

sort cases by gender (d).

save outfile = !output + 'Expected_total_Dementia_individuals_aged65plus&Gender_update.sav'. 

save translate outfile = !output + 'Expected_total_Dementia_individuals_aged65plus&Gender_update.xlsx' 
       /type =xlsx/version = 12/map/replace/fieldnames/cells = values.



