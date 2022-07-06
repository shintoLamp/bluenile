* Encoding: UTF-8.

* File save location.
define !OFilesL()
     '/conf/sourcedev/TableauUpdates/HRIpathways/Outputs/LV1/'
!Enddefine.

******************************************************************
*add notes.
*************************************************************************************************************************************************.
*** Start with latest year - 13/14.

*Macro 1.
Define !year()
'201718'
!Enddefine.

Define !year2()
'2017/18'
!Enddefine.

get file = '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.zsav'.
select if gender ne 0.
select if hri_lca ne 9.
EXE.

*FC July 2019. 
*Non-Service Users must be excluded by the calculations (only for health activities from 2015/16 onwards)
 Otherwise, these users will be counted in the 'Low Users' category.
select if NSU ne 1.
exe.

*Remove HRI cost outlier only found for 2017/18 and 2016/17 financial years.
*Check outliers for next update.
Select if Anon_CHI ne 'MDMwNTM2MTEzOQ=='.
exe.


String HRI_Group (A30).
* Create HRI grouping.
if (HRI_scotP lt 50) HRI_Group = 'High'.
if (HRI_scotP ge 50 and HRI_scotP lt 65) HRI_Group = 'High to Medium'.
if (HRI_scotP ge 65 and HRI_scotP lt 80) HRI_Group = 'Medium'.
if (HRI_scotP ge 80 and HRI_scotP lt 95) HRI_Group = 'Medium to Low'.
if (HRI_scotP ge 95) HRI_Group = 'Low'.
EXE.


* remove any individuals not attached to a LA area.
compute lca = 'Scotland'.
EXE.

string AgeBand (A6).
Compute AgeBand = 'All'.
EXE.

*Create totals by age band for use in Tableau.
SORT CASES BY lca(A) AgeBand(A) HRI_Group(A).

AGGREGATE
  /OUTFILE=!OFilesL +'OVERTABLE_ALL_Ages' + !year +'_SCOT.sav'
  /BREAK=lca AgeBand HRI_Group
  /health_Expenditure_cost_min=MIN(health_net_cost) 
  /health_Expenditure_cost_max=MAX(health_net_cost) 
  /health_Expenditure_cost=SUM(health_net_cost)
  /Individuals=N.

* Add service users totals per LA and age band - DIFFERENT agg required for LA and different AGES, issues with using individual age bands as percentages too small.
SORT CASES BY lca(A) AgeBand(A) HRI_scotP(A).

AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=lca ageband
  /Service_users=N.

* Calculate percentage.
compute ind_per = 1/Service_users * 100.
exe.

*Compute population percentage running total.
string LCA_Age (A30).
compute LCA_Age = CONCAT(lca, ageband).
EXE.

do if LCA_Age = lag(LCA_Age).
compute LCA_RPercent = ind_per + lag(LCA_RPercent).
else if LCA_Age ne lag(LCA_Age).
compute LCA_RPercent = ind_per.
end if.
exe.

compute LCA_RPercent2 = rnd(LCA_RPercent,0.001).
EXE.

* correct rounding for small numbers.

if LCA_RPercent2 < 0.1 LCA_RPercent2 = 0.1.

compute LCA_RPercent3 = rnd(LCA_RPercent2,0.1).
EXE.


* Now need to ensure that the HRI groups are clearly spilt by 0.1%.
string LCA_HRI_Perc (A30).
compute LCA_HRI_Perc = CONCAT(lca, ageband, HRI_Group).
EXE.

compute  LCA_RPercent3_Str =  LCA_RPercent3.
ALTER TYPE LCA_RPercent3_Str (A5).
EXE.

string LCA_HRI_Perc2 (A50).
compute LCA_HRI_Perc2 = CONCAT(lca, ageband, HRI_Group, LCA_RPercent3_Str).
EXE.

* Here we are adjusting any groups that have the same pecentage as the previous HRI group.
do if  LCA_HRI_Perc = lag( LCA_HRI_Perc).
compute LCA_RPercent_Final = LCA_RPercent3.
if LCA_HRI_Perc2 = lag( LCA_HRI_Perc2) LCA_RPercent_Final = lag(LCA_RPercent_Final ).
else if LCA_HRI_Perc ne lag( LCA_HRI_Perc).
compute LCA_RPercent_Final = LCA_RPercent3 + 0.1.
end if.
EXE.

* Correct High 0.1 records.
string LCA_HRI_Perc3 (A60).
compute LCA_HRI_Perc3 = CONCAT(ageband, HRI_Group, LCA_RPercent3_Str).
EXE.

if LCA_HRI_Perc3 = 'AllHigh  .10'  LCA_RPercent_Final = 0.1.
EXE.

* Convert Percent to a string for agg.

compute  Population =  LCA_RPercent_Final.
ALTER TYPE Population (A6).
EXE.

* Now agg file to require level - Each LA area should have 1,000 lines per Age Group.
AGGREGATE
  /OUTFILE=*
  /BREAK=lca ageband HRI_Group Population
  /health_Expenditure_cost=SUM(health_net_cost).


FREQUENCIES VARIABLES=lca
  /ORDER=ANALYSIS.

* create sorting order for HRI groups.

if HRI_Group = 'High' HRI_Sort = 1.
if HRI_Group = 'High to Medium' HRI_Sort = 2.
if HRI_Group = 'Medium' HRI_Sort = 3.
if HRI_Group = 'Medium to Low' HRI_Sort = 4.
if HRI_Group = 'Low' HRI_Sort = 5.
EXE.

SORT CASES BY lca(A) Population(A) HRI_Sort(A).

do if lca = lag(lca).
compute RTotal_Exp = health_Expenditure_cost + lag(RTotal_Exp).
else if  lca ne lag(lca).
compute RTotal_Exp = health_Expenditure_cost.
end if.
EXE.

* Create % Expenditure Running Total.
AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=lca AgeBand
  /health_Expenditure_cost_TOTAL=SUM(health_Expenditure_cost).

compute RTotal_Exp_Percent = RTotal_Exp/health_Expenditure_cost_TOTAL * 100.
exe.

Save outfile=!OFilesL +'OVERCHART_ALL_Ages' + !year +'_SCOT.sav'.


*** Now - 2017/18 - Individual Age groups.

get file = '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.zsav'.
select if gender ne 0.
select if hri_lca ne 9.
EXE.

*FC July 2019. 
*Non-Service Users must be excluded by the calculations (only for health activities from 2015/16 onwards)
 Otherwise, these users will be counted in the 'Low Users' category.
select if NSU ne 1.
exe.

*Remove HRI cost outlier only found for 2017/18 and 2016/17 financial years.
*Check outliers for next update.
Select if Anon_CHI ne 'MDMwNTM2MTEzOQ=='.
exe.


String HRI_Group (A30).
* Create HRI grouping.
if (HRI_scotP lt 50) HRI_Group = 'High'.
if (HRI_scotP ge 50 and HRI_scotP lt 65) HRI_Group = 'High to Medium'.
if (HRI_scotP ge 65 and HRI_scotP lt 80) HRI_Group = 'Medium'.
if (HRI_scotP ge 80 and HRI_scotP lt 95) HRI_Group = 'Medium to Low'.
if (HRI_scotP ge 95) HRI_Group = 'Low'.
EXE.


* Create required agebands.
string AgeBand (A6).
If (Age lt 18) AgeBand = '<18'.
If (Age ge 18 and Age le 44) AgeBand = '18-44'.
If (Age ge 45 and Age le 64) AgeBand = '45-64'.
If (Age ge 65 and Age le 74) AgeBand = '65-74'.
If (Age ge 75 and Age le 84) AgeBand = '75-84'.
If (Age ge 85) AgeBand = '85+'.
Exe. 

* remove any individuals not attached to a LA area.
compute lca = 'Scotland'.
EXE.

*Create totals by age band for use in Tableau.
SORT CASES BY lca(A) AgeBand(A) HRI_Group(A).

AGGREGATE
  /OUTFILE=!OFilesL +'OVERTABLE_IND_Ages' + !year +'_SCOT.sav'
  /BREAK=lca AgeBand HRI_Group
  /health_net_cost_min=MIN(health_net_cost) 
  /health_net_cost_max=MAX(health_net_cost) 
  /health_net_cost_sum=SUM(health_net_cost)
  /Individuals=N.

* Add service users totals per LA and age band - DIFFERENT agg required for LA and different AGES, issues with using individual age bands as percentages too small.

SORT CASES BY lca(A) AgeBand(A) HRI_scotP(A).

AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=lca AgeBand
  /Service_users=N.

* Calculate percentage.
compute ind_per = 1/Service_users * 100.
exe.

*Compute population percentage running total.
string LCA_Age (A30).
compute LCA_Age = CONCAT(lca, ageband).
EXE.

do if LCA_Age = lag(LCA_Age).
compute LCA_RPercent = ind_per + lag(LCA_RPercent).
else if LCA_Age ne lag(LCA_Age).
compute LCA_RPercent = ind_per.
end if.
exe.

compute LCA_RPercent2 = rnd(LCA_RPercent,0.001).
EXE.

* correct rounding for small numbers.

if LCA_RPercent2 < 0.1 LCA_RPercent2 = 0.1.

compute LCA_RPercent3 = rnd(LCA_RPercent2,0.1).
EXE.


* Now need to ensure that the HRI groups are clearly spilt by 0.1%.
string LCA_HRI_Perc (A30).
compute LCA_HRI_Perc = CONCAT(lca, ageband, HRI_Group).
EXE.

compute  LCA_RPercent3_Str =  LCA_RPercent3.
ALTER TYPE LCA_RPercent3_Str (A6).
EXE.

string LCA_HRI_Perc2 (A50).
compute LCA_HRI_Perc2 = CONCAT(lca, ageband, HRI_Group, LCA_RPercent3_Str).
EXE.

* Here we are adjusting any groups that have the same pecentage as the previous HRI group.
do if  LCA_HRI_Perc = lag( LCA_HRI_Perc).
compute LCA_RPercent_Final = LCA_RPercent3.
if LCA_HRI_Perc2 = lag( LCA_HRI_Perc2) LCA_RPercent_Final = lag(LCA_RPercent_Final ).
else if LCA_HRI_Perc ne lag( LCA_HRI_Perc).
compute LCA_RPercent_Final = LCA_RPercent3 + 0.1.
end if.
EXE.

* Correct High 0.1 records.
string LCA_HRI_Perc3 (A60).
compute LCA_HRI_Perc3 = CONCAT(ageband, HRI_Group, LCA_RPercent3_Str).
EXE.

if LCA_HRI_Perc3 = 'AllHigh  .10'  LCA_RPercent_Final = 0.1.
EXE.

* Convert Percent to a string for agg.

compute  Population =  LCA_RPercent_Final.
ALTER TYPE Population (A6).
EXE.

* Now agg file to require level - Each LA area should have 1,000 lines per Age Group.
AGGREGATE
  /OUTFILE=*
  /BREAK=lca ageband HRI_Group Population
  /health_Expenditure_cost=SUM(health_net_cost).


FREQUENCIES VARIABLES=lca
  /ORDER=ANALYSIS.

* create sorting order for HRI groups.

if HRI_Group = 'High' HRI_Sort = 1.
if HRI_Group = 'High to Medium' HRI_Sort = 2.
if HRI_Group = 'Medium' HRI_Sort = 3.
if HRI_Group = 'Medium to Low' HRI_Sort = 4.
if HRI_Group = 'Low' HRI_Sort = 5.
EXE.

SORT CASES BY lca(A) ageband (A) Population(A) HRI_Sort(A).

string LCA_Age (A30).
compute LCA_Age = CONCAT(lca, ageband).
EXE.

do if LCA_Age = lag(LCA_Age).
compute RTotal_Exp = health_Expenditure_cost + lag(RTotal_Exp).
else if  LCA_Age ne lag(LCA_Age).
compute RTotal_Exp = health_Expenditure_cost.
end if.
exe.

* Create % Expenditure Running Total.
AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=lca AgeBand
  /health_Expenditure_cost_TOTAL=SUM(health_Expenditure_cost).

compute RTotal_Exp_Percent = RTotal_Exp/health_Expenditure_cost_TOTAL * 100.
exe.


SORT CASES BY lca(A) AgeBand(A) Population(A) HRI_Sort(A).

Save outfile=!OFilesL+'OVERCHART_IND_Ages' + !year +'_SCOT.sav'
/drop LCA_Age.


add files file =!OFilesL+'OVERCHART_ALL_Ages' + !year + '_SCOT.sav'
/file =!OFilesL+'OVERCHART_IND_Ages' + !year + '_SCOT.sav'.


* Create year.
String Year (a7).
compute Year = !year2.
exe.

*add LA Name.
string LCAname (a25).
compute LCAname = 'Scotland'.
frequency variables = LCAname.

String LA_CODE (a9).
compute LA_CODE = 'M'.
exe.

String HBname (a40).
compute HBname = 'Scotland'.

frequencies variables =HBname.

String HB_CODE (a9).
compute HB_CODe = 'M'.
exe.

SAVE OUTFILE=!OFilesL+'OVERCHART_' + !year + 'SCOT_Final.sav'
  /DROP=lca health_Expenditure_cost_TOTAL
  /COMPRESSED.
*************************************************************************************************************************************************************************************************.
*** NEXT - 2016/17.

*Macro 1.
Define !year()
'201617'
!Enddefine.

Define !year2()
'2016/17'
!Enddefine.

get file = '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.zsav'.
select if gender ne 0.
select if hri_lca ne 9.
EXE.

*FC July 2019. 
*Non-Service Users must be excluded by the calculations (only for health activities from 2015/16 onwards)
 Otherwise, these users will be counted in the 'Low Users' category.
select if NSU ne 1.
exe.

*Remove HRI cost outlier only found for 2017/18 and 2016/17 financial years.
*Check outliers for next update.
Select if Anon_CHI ne 'MDMwNTM2MTEzOQ=='.
exe.

String HRI_Group (A30).
* Create HRI grouping.
if (HRI_scotP lt 50) HRI_Group = 'High'.
if (HRI_scotP ge 50 and HRI_scotP lt 65) HRI_Group = 'High to Medium'.
if (HRI_scotP ge 65 and HRI_scotP lt 80) HRI_Group = 'Medium'.
if (HRI_scotP ge 80 and HRI_scotP lt 95) HRI_Group = 'Medium to Low'.
if (HRI_scotP ge 95) HRI_Group = 'Low'.
exe.

* remove any individuals not attached to a LA area.
compute lca = 'Scotland'.
exe.

string AgeBand (A6).
Compute AgeBand = 'All'.
exe.

*Create totals by age band for use in Tableau.
SORT CASES BY lca(A) AgeBand(A) HRI_Group(A).

AGGREGATE
  /OUTFILE=!OFilesL +'OVERTABLE_ALL_Ages' + !year +'_SCOT.sav'
  /BREAK=lca AgeBand HRI_Group
  /health_Expenditure_cost_min=MIN(health_net_cost) 
  /health_Expenditure_cost_max=MAX(health_net_cost) 
  /health_Expenditure_cost=SUM(health_net_cost)
  /Individuals=N.

* Add service users totals per LA and age band - DIFFERENT agg required for LA and different AGES, issues with using individual age bands as percentages too small.
SORT CASES BY lca(A) AgeBand(A) HRI_scotP(A).

AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=lca ageband
  /Service_users=N.

* Calculate percentage.
compute ind_per = 1/Service_users * 100.
exe.

*Compute population percentage running total.
string LCA_Age (A30).
compute LCA_Age = CONCAT(lca, ageband).
exe.

do if LCA_Age = lag(LCA_Age).
compute LCA_RPercent = ind_per + lag(LCA_RPercent).
else if LCA_Age ne lag(LCA_Age).
compute LCA_RPercent = ind_per.
end if.
exe.

compute LCA_RPercent2 = rnd(LCA_RPercent,0.001).
exe.

* correct rounding for small numbers.

if LCA_RPercent2 < 0.1 LCA_RPercent2 = 0.1.

compute LCA_RPercent3 = rnd(LCA_RPercent2,0.1).
exe.


* Now need to ensure that the HRI groups are clearly spilt by 0.1%.
string LCA_HRI_Perc (A30).
compute LCA_HRI_Perc = CONCAT(lca, ageband, HRI_Group).
exe.

compute  LCA_RPercent3_Str =  LCA_RPercent3.
ALTER TYPE LCA_RPercent3_Str (A5).
exe.

string LCA_HRI_Perc2 (A50).
compute LCA_HRI_Perc2 = CONCAT(lca, ageband, HRI_Group, LCA_RPercent3_Str).
exe.

* Here we are adjusting any groups that have the same pecentage as the previous HRI group.
do if  LCA_HRI_Perc = lag( LCA_HRI_Perc).
compute LCA_RPercent_Final = LCA_RPercent3.
if LCA_HRI_Perc2 = lag( LCA_HRI_Perc2) LCA_RPercent_Final = lag(LCA_RPercent_Final ).
else if LCA_HRI_Perc ne lag( LCA_HRI_Perc).
compute LCA_RPercent_Final = LCA_RPercent3 + 0.1.

end if.
exe.

* Correct High 0.1 records.
string LCA_HRI_Perc3 (A60).
compute LCA_HRI_Perc3 = CONCAT(ageband, HRI_Group, LCA_RPercent3_Str).
exe.

if LCA_HRI_Perc3 = 'AllHigh  .10'  LCA_RPercent_Final = 0.1.
exe.

* Convert Percent to a string for agg.

compute  Population =  LCA_RPercent_Final.
ALTER TYPE Population (A6).
exe.

* Now agg file to require level - Each LA area should have 1,000 lines per Age Group.
AGGREGATE
  /OUTFILE=*
  /BREAK=lca ageband HRI_Group Population
  /health_Expenditure_cost=SUM(health_net_cost).


FREQUENCIES VARIABLES=lca
  /ORDER=ANALYSIS.

* create sorting order for HRI groups.

if HRI_Group = 'High' HRI_Sort = 1.
if HRI_Group = 'High to Medium' HRI_Sort = 2.
if HRI_Group = 'Medium' HRI_Sort = 3.
if HRI_Group = 'Medium to Low' HRI_Sort = 4.
if HRI_Group = 'Low' HRI_Sort = 5.
exe.

SORT CASES BY lca(A) Population(A) HRI_Sort(A).

do if lca = lag(lca).
compute RTotal_Exp = health_Expenditure_cost + lag(RTotal_Exp).
else if  lca ne lag(lca).
compute RTotal_Exp = health_Expenditure_cost.
end if.
exe.

* Create % Expenditure Running Total.
AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=lca AgeBand
  /health_Expenditure_cost_TOTAL=SUM(health_Expenditure_cost).

compute RTotal_Exp_Percent = RTotal_Exp/health_Expenditure_cost_TOTAL * 100.
exe.

Save outfile=!OFilesL +'OVERCHART_ALL_Ages' + !year +'_SCOT.sav'.


*** Now - 16/17 - Individual Age groups.

get file = '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.zsav'.
select if gender ne 0.
select if hri_lca ne 9.
exe.


*FC July 2019. 
*Non-Service Users must be excluded by the calculations (only for health activities from 2015/16 onwards)
 Otherwise, these users will be counted in the 'Low Users' category.
select if NSU ne 1.
exe.

*Remove HRI cost outlier only found for 2017/18 and 2016/17 financial years.
*Check outliers for next update.
Select if Anon_CHI ne 'MDMwNTM2MTEzOQ=='.
exe.


String HRI_Group (A30).
* Create HRI grouping.
if (HRI_scotP lt 50) HRI_Group = 'High'.
if (HRI_scotP ge 50 and HRI_scotP lt 65) HRI_Group = 'High to Medium'.
if (HRI_scotP ge 65 and HRI_scotP lt 80) HRI_Group = 'Medium'.
if (HRI_scotP ge 80 and HRI_scotP lt 95) HRI_Group = 'Medium to Low'.
if (HRI_scotP ge 95) HRI_Group = 'Low'.
exe.


* Create required agebands.

string AgeBand (A6).
If (Age lt 18) AgeBand = '<18'.
If (Age ge 18 and Age le 44) AgeBand = '18-44'.
If (Age ge 45 and Age le 64) AgeBand = '45-64'.
If (Age ge 65 and Age le 74) AgeBand = '65-74'.
If (Age ge 75 and Age le 84) AgeBand = '75-84'.
If (Age ge 85) AgeBand = '85+'.
exe. 

* remove any individuals not attached to a LA area.
compute lca = 'Scotland'.
exe.

*Create totals by age band for use in Tableau.
SORT CASES BY lca(A) AgeBand(A) HRI_Group(A).

AGGREGATE
  /OUTFILE=!OFilesL +'OVERTABLE_IND_Ages' + !year +'_SCOT.sav'
  /BREAK=lca AgeBand HRI_Group
  /health_net_cost_min=MIN(health_net_cost) 
  /health_net_cost_max=MAX(health_net_cost) 
  /health_net_cost_sum=SUM(health_net_cost)
  /Individuals=N.



* Add service users totals per LA and age band - DIFFERENT agg required for LA and different AGES, issues with using individual age bands as percentages too small.


SORT CASES BY lca(A) AgeBand(A) HRI_scotP(A).

AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=lca AgeBand
  /Service_users=N.

* Calculate percentage.
compute ind_per = 1/Service_users * 100.
exe.

*Compute population percentage running total.
string LCA_Age (A30).
compute LCA_Age = CONCAT(lca, ageband).
exe.

do if LCA_Age = lag(LCA_Age).
compute LCA_RPercent = ind_per + lag(LCA_RPercent).
else if LCA_Age ne lag(LCA_Age).
compute LCA_RPercent = ind_per.
end if.
exe.

compute LCA_RPercent2 = rnd(LCA_RPercent,0.001).
exe.

* correct rounding for small numbers.

if LCA_RPercent2 < 0.1 LCA_RPercent2 = 0.1.

compute LCA_RPercent3 = rnd(LCA_RPercent2,0.1).
exe.


* Now need to ensure that the HRI groups are clearly spilt by 0.1%.
string LCA_HRI_Perc (A30).
compute LCA_HRI_Perc = CONCAT(lca, ageband, HRI_Group).
exe.

compute  LCA_RPercent3_Str =  LCA_RPercent3.
ALTER TYPE LCA_RPercent3_Str (A6).
exe.

string LCA_HRI_Perc2 (A50).
compute LCA_HRI_Perc2 = CONCAT(lca, ageband, HRI_Group, LCA_RPercent3_Str).
exe.

* Here we are adjusting any groups that have the same pecentage as the previous HRI group.
do if  LCA_HRI_Perc = lag( LCA_HRI_Perc).
compute LCA_RPercent_Final = LCA_RPercent3.
if LCA_HRI_Perc2 = lag( LCA_HRI_Perc2) LCA_RPercent_Final = lag(LCA_RPercent_Final ).
else if LCA_HRI_Perc ne lag( LCA_HRI_Perc).
compute LCA_RPercent_Final = LCA_RPercent3 + 0.1.

end if.
exe.

* Correct High 0.1 records.
string LCA_HRI_Perc3 (A60).
compute LCA_HRI_Perc3 = CONCAT(ageband, HRI_Group, LCA_RPercent3_Str).
exe.

if LCA_HRI_Perc3 = 'AllHigh  .10'  LCA_RPercent_Final = 0.1.
exe.

* Convert Percent to a string for agg.

compute  Population =  LCA_RPercent_Final.
ALTER TYPE Population (A6).
exe.

* Now agg file to require level - Each LA area should have 1,000 lines per Age Group.
AGGREGATE
  /OUTFILE=*
  /BREAK=lca ageband HRI_Group Population
  /health_Expenditure_cost=SUM(health_net_cost).


FREQUENCIES VARIABLES=lca
  /ORDER=ANALYSIS.

* create sorting order for HRI groups.

if HRI_Group = 'High' HRI_Sort = 1.
if HRI_Group = 'High to Medium' HRI_Sort = 2.
if HRI_Group = 'Medium' HRI_Sort = 3.
if HRI_Group = 'Medium to Low' HRI_Sort = 4.
if HRI_Group = 'Low' HRI_Sort = 5.
exe.

SORT CASES BY lca(A) ageband (A) Population(A) HRI_Sort(A).

string LCA_Age (A30).
compute LCA_Age = CONCAT(lca, ageband).
exe.

do if LCA_Age = lag(LCA_Age).
compute RTotal_Exp = health_Expenditure_cost + lag(RTotal_Exp).
else if  LCA_Age ne lag(LCA_Age).
compute RTotal_Exp = health_Expenditure_cost.
end if.
exe.

* Create % Expenditure Running Total.
AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=lca AgeBand
  /health_Expenditure_cost_TOTAL=SUM(health_Expenditure_cost).

compute RTotal_Exp_Percent = RTotal_Exp/health_Expenditure_cost_TOTAL * 100.
exe.

SORT CASES BY lca(A) AgeBand(A) Population(A) HRI_Sort(A).

Save outfile=!OFilesL+'OVERCHART_IND_Ages' + !year +'_SCOT.sav'
/drop LCA_Age.


add files file =!OFilesL+'OVERCHART_ALL_Ages' + !year + '_SCOT.sav'
/file =!OFilesL+'OVERCHART_IND_Ages' + !year + '_SCOT.sav'.


* Create year.
String Year (a7).
compute Year = !year2.
exe.

*add LA Name.
string LCAname (a25).
compute LCAname = 'Scotland'.
frequency variables = LCAname.

String LA_CODE (a9).
compute LA_CODE = 'M'.
exe.

String HBname (a40).
compute HBname = 'Scotland'.

frequencies variables =HBname.

String HB_CODE (a9).
compute HB_CODe = 'M'.
exe.

SAVE OUTFILE=!OFilesL+'OVERCHART_' + !year + 'SCOT_Final.sav'
  /DROP=lca health_Expenditure_cost_TOTAL
  /COMPRESSED.
  

*/COMPRESSED.*************************************************************************************************************************************************************************************************.
*** NEXT - 15/16.

*Macro 1.
Define !year()
'201516'
!Enddefine.

Define !year2()
'2015/16'
!Enddefine.

get file = '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.zsav'.
select if gender ne 0.
select if hri_lca ne 9.
exe.

*FC July 2019. 
*Non-Service Users must be excluded by the calculations (only for health activities from 2015/16 onwards)
 Otherwise, these users will be counted in the 'Low Users' category.
select if NSU ne 1.
exe.

*Remove HRI cost outlier only found for 2017/18 and 2016/17 financial years.
*Check outliers for next update.
Select if Anon_CHI ne 'MDMwNTM2MTEzOQ=='.
exe.


String HRI_Group (A30).
* Create HRI grouping.
if (HRI_scotP lt 50) HRI_Group = 'High'.
if (HRI_scotP ge 50 and HRI_scotP lt 65) HRI_Group = 'High to Medium'.
if (HRI_scotP ge 65 and HRI_scotP lt 80) HRI_Group = 'Medium'.
if (HRI_scotP ge 80 and HRI_scotP lt 95) HRI_Group = 'Medium to Low'.
if (HRI_scotP ge 95) HRI_Group = 'Low'.
exe.

* remove any individuals not attached to a LA area.
compute lca = 'Scotland'.
exe.
string AgeBand (A6).
Compute AgeBand = 'All'.
exe.

*Create totals by age band for use in Tableau.
SORT CASES BY lca(A) AgeBand(A) HRI_Group(A).

AGGREGATE
  /OUTFILE=!OFilesL +'OVERTABLE_ALL_Ages' + !year +'_SCOT.sav'
  /BREAK=lca AgeBand HRI_Group
  /health_Expenditure_cost_min=MIN(health_net_cost) 
  /health_Expenditure_cost_max=MAX(health_net_cost) 
  /health_Expenditure_cost=SUM(health_net_cost)
  /Individuals=N.

* Add service users totals per LA and age band - DIFFERENT agg required for LA and different AGES, issues with using individual age bands as percentages too small.
SORT CASES BY lca(A) AgeBand(A) HRI_scotP(A).

AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=lca ageband
  /Service_users=N.

* Calculate percentage.
compute ind_per = 1/Service_users * 100.
exe.

*Compute population percentage running total.
string LCA_Age (A30).
compute LCA_Age = CONCAT(lca, ageband).
exe.

do if LCA_Age = lag(LCA_Age).
compute LCA_RPercent = ind_per + lag(LCA_RPercent).
else if LCA_Age ne lag(LCA_Age).
compute LCA_RPercent = ind_per.
end if.
exe.

compute LCA_RPercent2 = rnd(LCA_RPercent,0.001).
exe.

* correct rounding for small numbers.

if LCA_RPercent2 < 0.1 LCA_RPercent2 = 0.1.

compute LCA_RPercent3 = rnd(LCA_RPercent2,0.1).
exe.


* Now need to ensure that the HRI groups are clearly spilt by 0.1%.
string LCA_HRI_Perc (A30).
compute LCA_HRI_Perc = CONCAT(lca, ageband, HRI_Group).
exe.

compute  LCA_RPercent3_Str =  LCA_RPercent3.
ALTER TYPE LCA_RPercent3_Str (A5).
exe.

string LCA_HRI_Perc2 (A50).
compute LCA_HRI_Perc2 = CONCAT(lca, ageband, HRI_Group, LCA_RPercent3_Str).
exe.

* Here we are adjusting any groups that have the same pecentage as the previous HRI group.
do if  LCA_HRI_Perc = lag( LCA_HRI_Perc).
compute LCA_RPercent_Final = LCA_RPercent3.
if LCA_HRI_Perc2 = lag( LCA_HRI_Perc2) LCA_RPercent_Final = lag(LCA_RPercent_Final ).
else if LCA_HRI_Perc ne lag( LCA_HRI_Perc).
compute LCA_RPercent_Final = LCA_RPercent3 + 0.1.

end if.
exe.

* Correct High 0.1 records.
string LCA_HRI_Perc3 (A60).
compute LCA_HRI_Perc3 = CONCAT(ageband, HRI_Group, LCA_RPercent3_Str).
exe.

if LCA_HRI_Perc3 = 'AllHigh  .10'  LCA_RPercent_Final = 0.1.
exe.

* Convert Percent to a string for agg.

compute  Population =  LCA_RPercent_Final.
ALTER TYPE Population (A6).
exe.

* Now agg file to require level - Each LA area should have 1,000 lines per Age Group.
AGGREGATE
  /OUTFILE=*
  /BREAK=lca ageband HRI_Group Population
  /health_Expenditure_cost=SUM(health_net_cost).


FREQUENCIES VARIABLES=lca
  /ORDER=ANALYSIS.

* create sorting order for HRI groups.

if HRI_Group = 'High' HRI_Sort = 1.
if HRI_Group = 'High to Medium' HRI_Sort = 2.
if HRI_Group = 'Medium' HRI_Sort = 3.
if HRI_Group = 'Medium to Low' HRI_Sort = 4.
if HRI_Group = 'Low' HRI_Sort = 5.
exe.

SORT CASES BY lca(A) Population(A) HRI_Sort(A).

do if lca = lag(lca).
compute RTotal_Exp = health_Expenditure_cost + lag(RTotal_Exp).
else if  lca ne lag(lca).
compute RTotal_Exp = health_Expenditure_cost.
end if.
exe.

* Create % Expenditure Running Total.
AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=lca AgeBand
  /health_Expenditure_cost_TOTAL=SUM(health_Expenditure_cost).

compute RTotal_Exp_Percent = RTotal_Exp/health_Expenditure_cost_TOTAL * 100.
exe.

Save outfile=!OFilesL +'OVERCHART_ALL_Ages' + !year +'_SCOT.sav'.


*** Now - 15/16 - Individual Age groups.

get file = '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.zsav'.
select if gender ne 0.
select if hri_lca ne 9.
exe.

*FC July 2019. 
*Non-Service Users must be excluded by the calculations (only for health activities from 2015/16 onwards)
 Otherwise, these users will be counted in the 'Low Users' category.
select if NSU ne 1.
exe.

*Remove HRI cost outlier only found for 2017/18 and 2016/17 financial years.
*Check outliers for next update.
Select if Anon_CHI ne 'MDMwNTM2MTEzOQ=='.
exe.

String HRI_Group (A30).
* Create HRI grouping.
if (HRI_scotP lt 50) HRI_Group = 'High'.
if (HRI_scotP ge 50 and HRI_scotP lt 65) HRI_Group = 'High to Medium'.
if (HRI_scotP ge 65 and HRI_scotP lt 80) HRI_Group = 'Medium'.
if (HRI_scotP ge 80 and HRI_scotP lt 95) HRI_Group = 'Medium to Low'.
if (HRI_scotP ge 95) HRI_Group = 'Low'.
exe.


* Create required agebands.
string AgeBand (A6).
If (Age lt 18) AgeBand = '<18'.
If (Age ge 18 and Age le 44) AgeBand = '18-44'.
If (Age ge 45 and Age le 64) AgeBand = '45-64'.
If (Age ge 65 and Age le 74) AgeBand = '65-74'.
If (Age ge 75 and Age le 84) AgeBand = '75-84'.
If (Age ge 85) AgeBand = '85+'.
exe. 

* remove any individuals not attached to a LA area.
compute lca = 'Scotland'.
exe.

*Create totals by age band for use in Tableau.
SORT CASES BY lca(A) AgeBand(A) HRI_Group(A).

AGGREGATE
  /OUTFILE=!OFilesL +'OVERTABLE_IND_Ages' + !year +'_SCOT.sav'
  /BREAK=lca AgeBand HRI_Group
  /health_net_cost_min=MIN(health_net_cost) 
  /health_net_cost_max=MAX(health_net_cost) 
  /health_net_cost_sum=SUM(health_net_cost)
  /Individuals=N.



* Add service users totals per LA and age band - DIFFERENT agg required for LA and different AGES, issues with using individual age bands as percentages too small.


SORT CASES BY lca(A) AgeBand(A) HRI_scotP(A).

AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=lca AgeBand
  /Service_users=N.

* Calculate percentage.
compute ind_per = 1/Service_users * 100.
exe.

*Compute population percentage running total.
string LCA_Age (A30).
compute LCA_Age = CONCAT(lca, ageband).
exe.

do if LCA_Age = lag(LCA_Age).
compute LCA_RPercent = ind_per + lag(LCA_RPercent).
else if LCA_Age ne lag(LCA_Age).
compute LCA_RPercent = ind_per.
end if.
exe.

compute LCA_RPercent2 = rnd(LCA_RPercent,0.001).
exe.

* correct rounding for small numbers.

if LCA_RPercent2 < 0.1 LCA_RPercent2 = 0.1.

compute LCA_RPercent3 = rnd(LCA_RPercent2,0.1).
exe.


* Now need to ensure that the HRI groups are clearly spilt by 0.1%.
string LCA_HRI_Perc (A30).
compute LCA_HRI_Perc = CONCAT(lca, ageband, HRI_Group).
exe.

compute  LCA_RPercent3_Str =  LCA_RPercent3.
ALTER TYPE LCA_RPercent3_Str (A6).
exe.

string LCA_HRI_Perc2 (A50).
compute LCA_HRI_Perc2 = CONCAT(lca, ageband, HRI_Group, LCA_RPercent3_Str).
exe.

* Here we are adjusting any groups that have the same pecentage as the previous HRI group.
do if  LCA_HRI_Perc = lag( LCA_HRI_Perc).
compute LCA_RPercent_Final = LCA_RPercent3.
if LCA_HRI_Perc2 = lag( LCA_HRI_Perc2) LCA_RPercent_Final = lag(LCA_RPercent_Final ).
else if LCA_HRI_Perc ne lag( LCA_HRI_Perc).
compute LCA_RPercent_Final = LCA_RPercent3 + 0.1.

end if.
exe.

* Correct High 0.1 records.
string LCA_HRI_Perc3 (A60).
compute LCA_HRI_Perc3 = CONCAT(ageband, HRI_Group, LCA_RPercent3_Str).
exe.

if LCA_HRI_Perc3 = 'AllHigh  .10'  LCA_RPercent_Final = 0.1.
exe.

* Convert Percent to a string for agg.

compute  Population =  LCA_RPercent_Final.
ALTER TYPE Population (A6).
exe.

* Now agg file to require level - Each LA area should have 1,000 lines per Age Group.
AGGREGATE
  /OUTFILE=*
  /BREAK=lca ageband HRI_Group Population
  /health_Expenditure_cost=SUM(health_net_cost).


FREQUENCIES VARIABLES=lca
  /ORDER=ANALYSIS.

* create sorting order for HRI groups.

if HRI_Group = 'High' HRI_Sort = 1.
if HRI_Group = 'High to Medium' HRI_Sort = 2.
if HRI_Group = 'Medium' HRI_Sort = 3.
if HRI_Group = 'Medium to Low' HRI_Sort = 4.
if HRI_Group = 'Low' HRI_Sort = 5.
exe.

SORT CASES BY lca(A) ageband (A) Population(A) HRI_Sort(A).

string LCA_Age (A30).
compute LCA_Age = CONCAT(lca, ageband).
exe.

do if LCA_Age = lag(LCA_Age).
compute RTotal_Exp = health_Expenditure_cost + lag(RTotal_Exp).
else if  LCA_Age ne lag(LCA_Age).
compute RTotal_Exp = health_Expenditure_cost.
end if.
exe.

* Create % Expenditure Running Total.
AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=lca AgeBand
  /health_Expenditure_cost_TOTAL=SUM(health_Expenditure_cost).

compute RTotal_Exp_Percent = RTotal_Exp/health_Expenditure_cost_TOTAL * 100.
exe.


SORT CASES BY lca(A) AgeBand(A) Population(A) HRI_Sort(A).

Save outfile=!OFilesL+'OVERCHART_IND_Ages' + !year +'_SCOT.sav'
/drop LCA_Age.


add files file =!OFilesL+'OVERCHART_ALL_Ages' + !year + '_SCOT.sav'
/file =!OFilesL+'OVERCHART_IND_Ages' + !year + '_SCOT.sav'.


* Create year.
String Year (a7).
compute Year = !year2.
exe.

*add LA Name.
string LCAname (a25).
compute LCAname = 'Scotland'.
frequency variables = LCAname.

String LA_CODE (a9).
compute LA_CODE = 'M'.
exe.

String HBname (a40).
compute HBname = 'Scotland'.

frequencies variables =HBname.

String HB_CODE (a9).
compute HB_CODe = 'M'.
exe.
SAVE OUTFILE=!OFilesL+'OVERCHART_' + !year + 'SCOT_Final.sav'
  /DROP=lca health_Expenditure_cost_TOTAL
  /COMPRESSED.

*************************************************************************************************************************************************************************************************.
*** NEXT - 14/15.

*Macro 1.
Define !year()
'201415'
!Enddefine.

Define !year2()
'2014/15'
!Enddefine.

get file = '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.zsav'.
select if gender ne 0.
select if hri_lca ne 9.
exe.

String HRI_Group (A30).
* Create HRI grouping.
if (HRI_scotP lt 50) HRI_Group = 'High'.
if (HRI_scotP ge 50 and HRI_scotP lt 65) HRI_Group = 'High to Medium'.
if (HRI_scotP ge 65 and HRI_scotP lt 80) HRI_Group = 'Medium'.
if (HRI_scotP ge 80 and HRI_scotP lt 95) HRI_Group = 'Medium to Low'.
if (HRI_scotP ge 95) HRI_Group = 'Low'.
exe.


* remove any individuals not attached to a LA area.
compute lca = 'Scotland'.
exe.

string AgeBand (A6).
Compute AgeBand = 'All'.
exe.

*Create totals by age band for use in Tableau.
SORT CASES BY lca(A) AgeBand(A) HRI_Group(A).

AGGREGATE
  /OUTFILE=!OFilesL +'OVERTABLE_ALL_Ages' + !year +'_SCOT.sav'
  /BREAK=lca AgeBand HRI_Group
  /health_Expenditure_cost_min=MIN(health_net_cost) 
  /health_Expenditure_cost_max=MAX(health_net_cost) 
  /health_Expenditure_cost=SUM(health_net_cost)
  /Individuals=N.

* Add service users totals per LA and age band - DIFFERENT agg required for LA and different AGES, issues with using individual age bands as percentages too small.
SORT CASES BY lca(A) AgeBand(A) HRI_scotP(A).

AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=lca ageband
  /Service_users=N.

* Calculate percentage.
compute ind_per = 1/Service_users * 100.
exe.

*Compute population percentage running total.
string LCA_Age (A30).
compute LCA_Age = CONCAT(lca, ageband).
exe.

do if LCA_Age = lag(LCA_Age).
compute LCA_RPercent = ind_per + lag(LCA_RPercent).
else if LCA_Age ne lag(LCA_Age).
compute LCA_RPercent = ind_per.
end if.
exe.

compute LCA_RPercent2 = rnd(LCA_RPercent,0.001).
exe.

* correct rounding for small numbers.

if LCA_RPercent2 < 0.1 LCA_RPercent2 = 0.1.

compute LCA_RPercent3 = rnd(LCA_RPercent2,0.1).
exe.


* Now need to ensure that the HRI groups are clearly spilt by 0.1%.
string LCA_HRI_Perc (A30).
compute LCA_HRI_Perc = CONCAT(lca, ageband, HRI_Group).
exe.

compute  LCA_RPercent3_Str =  LCA_RPercent3.
ALTER TYPE LCA_RPercent3_Str (A5).
exe.

string LCA_HRI_Perc2 (A50).
compute LCA_HRI_Perc2 = CONCAT(lca, ageband, HRI_Group, LCA_RPercent3_Str).
exe.

* Here we are adjusting any groups that have the same pecentage as the previous HRI group.
do if  LCA_HRI_Perc = lag( LCA_HRI_Perc).
compute LCA_RPercent_Final = LCA_RPercent3.
if LCA_HRI_Perc2 = lag( LCA_HRI_Perc2) LCA_RPercent_Final = lag(LCA_RPercent_Final ).
else if LCA_HRI_Perc ne lag( LCA_HRI_Perc).
compute LCA_RPercent_Final = LCA_RPercent3 + 0.1.

end if.
exe.

* Correct High 0.1 records.
string LCA_HRI_Perc3 (A60).
compute LCA_HRI_Perc3 = CONCAT(ageband, HRI_Group, LCA_RPercent3_Str).
exe.

if LCA_HRI_Perc3 = 'AllHigh  .10'  LCA_RPercent_Final = 0.1.
exe.

* Convert Percent to a string for agg.

compute  Population =  LCA_RPercent_Final.
ALTER TYPE Population (A6).
exe.

* Now agg file to require level - Each LA area should have 1,000 lines per Age Group.
AGGREGATE
  /OUTFILE=*
  /BREAK=lca ageband HRI_Group Population
  /health_Expenditure_cost=SUM(health_net_cost).


FREQUENCIES VARIABLES=lca
  /ORDER=ANALYSIS.

* create sorting order for HRI groups.

if HRI_Group = 'High' HRI_Sort = 1.
if HRI_Group = 'High to Medium' HRI_Sort = 2.
if HRI_Group = 'Medium' HRI_Sort = 3.
if HRI_Group = 'Medium to Low' HRI_Sort = 4.
if HRI_Group = 'Low' HRI_Sort = 5.
exe.

SORT CASES BY lca(A) Population(A) HRI_Sort(A).

do if lca = lag(lca).
compute RTotal_Exp = health_Expenditure_cost + lag(RTotal_Exp).
else if  lca ne lag(lca).
compute RTotal_Exp = health_Expenditure_cost.
end if.
exe.

* Create % Expenditure Running Total.
AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=lca AgeBand
  /health_Expenditure_cost_TOTAL=SUM(health_Expenditure_cost).

compute RTotal_Exp_Percent = RTotal_Exp/health_Expenditure_cost_TOTAL * 100.
exe.

Save outfile=!OFilesL +'OVERCHART_ALL_Ages' + !year +'_SCOT.sav'.


*** Now - 14/15 - Individual Age groups.

get file = '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.zsav'.
select if gender ne 0.
select if hri_lca ne 9.
exe.

String HRI_Group (A30).
* Create HRI grouping.
if (HRI_scotP lt 50) HRI_Group = 'High'.
if (HRI_scotP ge 50 and HRI_scotP lt 65) HRI_Group = 'High to Medium'.
if (HRI_scotP ge 65 and HRI_scotP lt 80) HRI_Group = 'Medium'.
if (HRI_scotP ge 80 and HRI_scotP lt 95) HRI_Group = 'Medium to Low'.
if (HRI_scotP ge 95) HRI_Group = 'Low'.
exe.


* Create required agebands.
string AgeBand (A6).
If (Age lt 18) AgeBand = '<18'.
If (Age ge 18 and Age le 44) AgeBand = '18-44'.
If (Age ge 45 and Age le 64) AgeBand = '45-64'.
If (Age ge 65 and Age le 74) AgeBand = '65-74'.
If (Age ge 75 and Age le 84) AgeBand = '75-84'.
If (Age ge 85) AgeBand = '85+'.
exe. 

* remove any individuals not attached to a LA area.
compute lca = 'Scotland'.
exe.

*Create totals by age band for use in Tableau.
SORT CASES BY lca(A) AgeBand(A) HRI_Group(A).

AGGREGATE
  /OUTFILE=!OFilesL +'OVERTABLE_IND_Ages' + !year +'_SCOT.sav'
  /BREAK=lca AgeBand HRI_Group
  /health_net_cost_min=MIN(health_net_cost) 
  /health_net_cost_max=MAX(health_net_cost) 
  /health_net_cost_sum=SUM(health_net_cost)
  /Individuals=N.



* Add service users totals per LA and age band - DIFFERENT agg required for LA and different AGES, issues with using individual age bands as percentages too small.


SORT CASES BY lca(A) AgeBand(A) HRI_scotP(A).

AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=lca AgeBand
  /Service_users=N.

* Calculate percentage.
compute ind_per = 1/Service_users * 100.
exe.

*Compute population percentage running total.
string LCA_Age (A30).
compute LCA_Age = CONCAT(lca, ageband).
exe.

do if LCA_Age = lag(LCA_Age).
compute LCA_RPercent = ind_per + lag(LCA_RPercent).
else if LCA_Age ne lag(LCA_Age).
compute LCA_RPercent = ind_per.
end if.
exe.

compute LCA_RPercent2 = rnd(LCA_RPercent,0.001).
exe.

* correct rounding for small numbers.

if LCA_RPercent2 < 0.1 LCA_RPercent2 = 0.1.

compute LCA_RPercent3 = rnd(LCA_RPercent2,0.1).
exe.


* Now need to ensure that the HRI groups are clearly spilt by 0.1%.
string LCA_HRI_Perc (A30).
compute LCA_HRI_Perc = CONCAT(lca, ageband, HRI_Group).
exe.

compute  LCA_RPercent3_Str =  LCA_RPercent3.
ALTER TYPE LCA_RPercent3_Str (A6).
exe.

string LCA_HRI_Perc2 (A50).
compute LCA_HRI_Perc2 = CONCAT(lca, ageband, HRI_Group, LCA_RPercent3_Str).
exe.

* Here we are adjusting any groups that have the same pecentage as the previous HRI group.
do if  LCA_HRI_Perc = lag( LCA_HRI_Perc).
compute LCA_RPercent_Final = LCA_RPercent3.
if LCA_HRI_Perc2 = lag( LCA_HRI_Perc2) LCA_RPercent_Final = lag(LCA_RPercent_Final ).
else if LCA_HRI_Perc ne lag( LCA_HRI_Perc).
compute LCA_RPercent_Final = LCA_RPercent3 + 0.1.

end if.
exe.

* Correct High 0.1 records.
string LCA_HRI_Perc3 (A60).
compute LCA_HRI_Perc3 = CONCAT(ageband, HRI_Group, LCA_RPercent3_Str).
exe.

if LCA_HRI_Perc3 = 'AllHigh  .10'  LCA_RPercent_Final = 0.1.
exe.

* Convert Percent to a string for agg.

compute  Population =  LCA_RPercent_Final.
ALTER TYPE Population (A6).
exe.

* Now agg file to require level - Each LA area should have 1,000 lines per Age Group.
AGGREGATE
  /OUTFILE=*
  /BREAK=lca ageband HRI_Group Population
  /health_Expenditure_cost=SUM(health_net_cost).


FREQUENCIES VARIABLES=lca
  /ORDER=ANALYSIS.

* create sorting order for HRI groups.

if HRI_Group = 'High' HRI_Sort = 1.
if HRI_Group = 'High to Medium' HRI_Sort = 2.
if HRI_Group = 'Medium' HRI_Sort = 3.
if HRI_Group = 'Medium to Low' HRI_Sort = 4.
if HRI_Group = 'Low' HRI_Sort = 5.
exe.

SORT CASES BY lca(A) ageband (A) Population(A) HRI_Sort(A).

string LCA_Age (A30).
compute LCA_Age = CONCAT(lca, ageband).
exe.

do if LCA_Age = lag(LCA_Age).
compute RTotal_Exp = health_Expenditure_cost + lag(RTotal_Exp).
else if  LCA_Age ne lag(LCA_Age).
compute RTotal_Exp = health_Expenditure_cost.
end if.
exe.

* Create % Expenditure Running Total.
AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=lca AgeBand
  /health_Expenditure_cost_TOTAL=SUM(health_Expenditure_cost).

compute RTotal_Exp_Percent = RTotal_Exp/health_Expenditure_cost_TOTAL * 100.
exe.


SORT CASES BY lca(A) AgeBand(A) Population(A) HRI_Sort(A).

Save outfile=!OFilesL+'OVERCHART_IND_Ages' + !year +'_SCOT.sav'
/drop LCA_Age.


add files file =!OFilesL+'OVERCHART_ALL_Ages' + !year + '_SCOT.sav'
/file =!OFilesL+'OVERCHART_IND_Ages' + !year + '_SCOT.sav'.


* Create year.
String Year (a7).
compute Year = !year2.
exe.

*add LA Name.
string LCAname (a25).
compute LCAname = 'Scotland'.
frequency variables = LCAname.

String LA_CODE (a9).
compute LA_CODE = 'M'.
exe.

String HBname (a40).
compute HBname = 'Scotland'.

frequencies variables =HBname.

String HB_CODE (a9).
compute HB_CODe = 'M'.
exe.

SAVE OUTFILE=!OFilesL+'OVERCHART_' + !year + 'SCOT_Final.sav'
  /DROP=lca health_Expenditure_cost_TOTAL
  /COMPRESSED.

*************************************************************************************************************************************************.

Define !year()
'201718'
!Enddefine.

Define !year2()
'2017/18'
!Enddefine.

*Main Data.
add files file = !OFilesL +'OVERTABLE_ALL_Ages' + !year +'_SCOT.sav'
/file =  !OFilesL +'OVERTABLE_IND_Ages' + !year +'_SCOT.sav'.
exe.

* Create year.
String Year (a7).
compute Year = !year2.
exe.

SORT CASES BY lca(A) AgeBand(A) HRI_Group(A).

* Calculate number of individuals by Age group and work out Percentage for each HRG group.
AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=lca AgeBand
  /Individuals_sum=SUM(Individuals).

compute Percentage_pop = rnd((Individuals/Individuals_sum),0.1).
exe.

Save outfile= !OFilesL +'OVERTable_' + !year +'SCOT_Final.sav'.


Define !year()
'201617'
!Enddefine.

Define !year2()
'2016/17'
!Enddefine.

*Main Data.
add files file = !OFilesL +'OVERTABLE_ALL_Ages' + !year +'_SCOT.sav'
/file =  !OFilesL +'OVERTABLE_IND_Ages' + !year +'_SCOT.sav'.
exe.

* Create year.
String Year (a7).
compute Year = !year2.
exe.

SORT CASES BY lca(A) AgeBand(A) HRI_Group(A).

* Calculate number of individuals by Age group and work out Percentage for each HRG group.
AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=lca AgeBand
  /Individuals_sum=SUM(Individuals).

compute Percentage_pop = rnd((Individuals/Individuals_sum),0.1).
exe.

Save outfile= !OFilesL +'OVERTable_' + !year +'SCOT_Final.sav'.


Define !year()
'201516'
!Enddefine.

Define !year2()
'2015/16'
!Enddefine.

*Main Data.
add files file = !OFilesL +'OVERTABLE_ALL_Ages' + !year +'_SCOT.sav'
/file =  !OFilesL +'OVERTABLE_IND_Ages' + !year +'_SCOT.sav'.
exe.

* Create year.
String Year (a7).
compute Year = !year2.
exe.

SORT CASES BY lca(A) AgeBand(A) HRI_Group(A).

* Calculate number of individuals by Age group and work out Percentage for each HRG group.
AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=lca AgeBand
  /Individuals_sum=SUM(Individuals).

compute Percentage_pop = rnd((Individuals/Individuals_sum),0.1).
exe.

Save outfile= !OFilesL +'OVERTable_' + !year +'SCOT_Final.sav'.

Define !year()
'201415'
!Enddefine.

Define !year2()
'2014/15'
!Enddefine.

*Main Data.
add files file = !OFilesL +'OVERTABLE_ALL_Ages' + !year +'_SCOT.sav'
/file =  !OFilesL +'OVERTABLE_IND_Ages' + !year +'_SCOT.sav'.
exe.

* Create year.
String Year (a7).
compute Year = !year2.
exe.

SORT CASES BY lca(A) AgeBand(A) HRI_Group(A).

* Calculate number of individuals by Age group and work out Percentage for each HRG group.
AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=lca AgeBand
  /Individuals_sum=SUM(Individuals).

compute Percentage_pop = rnd((Individuals/Individuals_sum),0.1).
exe.

Save outfile= !OFilesL +'OVERTable_' + !year +'SCOT_Final.sav'.


add files file =  !OFilesL +'OVERTable_201718SCOT_Final.sav'
/file =   !OFilesL +'OVERTable_201415SCOT_Final.sav'
/file =  !OFilesL +'OVERTable_201516SCOT_Final.sav'
/file =   !OFilesL +'OVERTable_201617SCOT_Final.sav'.
exe.

* Correct All ages.
if AgeBand = 'All' AgeBand = 'All ages'.
exe.

* Correct mis named variables.

recode health_Expenditure_cost_min (sysmis = -99999999).
recode health_Expenditure_cost_max (sysmis = -99999999).
recode health_Expenditure_cost (sysmis = -99999999).
exe.

if health_Expenditure_cost_min = -99999999 health_Expenditure_cost_min = health_net_cost_min.
if health_Expenditure_cost_max = -99999999 health_Expenditure_cost_max = health_net_cost_max.
if health_Expenditure_cost = -99999999 health_Expenditure_cost = health_net_cost_sum.
exe.


*add LA Name.
string LCAname (a25).
compute LCAname = 'Scotland'.
frequency variables = LCAname.

String LA_CODE (a9).
compute LA_CODE = 'M'.
exe.

String HBname (a40).
compute HBname = 'Scotland'.

frequencies variables =HBname.

String HB_CODE (a9).
compute HB_CODE = 'M'.
exe.

* Add avergae cost per individual by age and GRG group.
compute Average_cost = health_Expenditure_cost/Individuals.
exe.

* Add data type for TDE.
String Data (A20).
Compute Data = 'Table'.
exe.

SAVE OUTFILE= !OFilesL +'tempOverTable_SCOTdata.sav'
  /DROP=lca health_net_cost_min health_net_cost_max health_net_cost_sum
  /COMPRESSED.



add files file = !OFilesL +'OVERCHART_201718SCOT_Final.sav'
/file = !OFilesL +'OVERCHART_201415SCOT_Final.sav'
/file =  !OFilesL +'OVERCHART_201516SCOT_Final.sav'
/file =  !OFilesL +'OVERCHART_201617SCOT_Final.sav'.
exe.

* Correct All ages.
if AgeBand = 'All' AgeBand = 'All ages'.
exe.

* Add data type for TDE.
String Data (A20).
Compute Data = 'Chart'.
exe.


add files file = *
/file=!OFilesL +'tempOverTable_SCOTdata.sav'.
exe.

recode RTotal_Exp (sysmis = 0).
recode RTotal_Exp_Percent (sysmis = 0).
recode health_Expenditure_cost_min (sysmis = 0).
recode health_Expenditure_cost_max (sysmis = 0).
recode Individuals (sysmis = 0).
recode Average_cost (sysmis = 0).
alter type population (f3.2).
exe.

alter type ageband (a8).
if ageband eq 'All ag' ageband eq 'All ages'.
exe.

save outfile = !OFilesL + 'HRI_OVERVIEW_SCOT.zsav'
/zcompressed.

get file = !OFilesL + 'HRI_OVERVIEW_SCOT.zsav'.

save outfile = !OFilesL + 'HRI_OVERVIEW_SCOT.sav'.


