﻿* Encoding: UTF-8.
* File save location.
define !OFilesL()
     '/conf/sourcedev/TableauUpdates/HRI/Outputs/CS/'
!Enddefine.
******************************************************************
*add notes.
*************************************************************************************************************************************************.
*** Start with latest year - 2018/19.

*Macro 1.
Define !year()
'202021'
!Enddefine.

Define !year2()
!QUOTE(!CONCAT(!UNQUOTE(!SUBSTR(!EVAL(!year), 2, 4)), '/', !UNQUOTE(!SUBSTR(!EVAL(!year), 6, 2))))
!Enddefine.

Define !year3()
!QUOTE(!UNQUOTE(!SUBSTR(!EVAL(!year), 4, 4)))
!Enddefine.

get file = '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.zsav'.
select if LCA = '06' or LCA = '30'.
execute.
 * get file = '/conf/sourcedev/Source Linkage File Updates/' + !year3 + '/source-individual-file-' + !year + '.zsav'.
select if gender ne 0.
select if hri_lca ne 9.

*Oct. 2019 FC. 
*Non-Service Users must be excluded by the calculations.
*Otherwise, these users will be counted in the 'Low Users' category.
*Use the following exclusing criteria only for 2015/16 onwards).
select if NSU ne 1.

********Please check********
***A HRI cost outlier was found for 2016/17, 2017/18.
***If the following individual is associated with an inflated cost, he/she must be excluded from the dataset.
Select if Anon_CHI ne 'MDMwNTM2MTEzOQ=='.

rename variables (HRI_LcaP=lcap)(HRI_hbP=hbp)(HRI_scotP=Scotp).
*(simd2016_sc_quintile=scsimd2016quintile)(simd2016_sc_decile=scsimd2016decile).

String HRI_Group (A30).
* Create HRI grouping.
if (lcaP lt 50) HRI_Group = 'High'.
if (lcaP ge 50 and lcaP lt 65) HRI_Group = 'High to Medium'.
if (lcaP ge 65 and lcaP lt 80) HRI_Group = 'Medium'.
if (lcaP ge 80 and lcaP lt 95) HRI_Group = 'Medium to Low'.
if (lcaP ge 95) HRI_Group = 'Low'.

* remove any individuals not attached to a LA area.
SELECT IF lca NE ' '.

string AgeBand (A6).
Compute AgeBand = 'All'.

*Create totals by age band for use in Tableau.
SORT CASES BY lca(A) AgeBand(A) HRI_Group(A).

compute lca='33'.

AGGREGATE
  /OUTFILE=!OFilesL +'OVERTABLE_ALL_Ages' + !year +'.zsav'
  /BREAK=lca AgeBand HRI_Group
  /health_Expenditure_cost_min=MIN(health_net_cost) 
  /health_Expenditure_cost_max=MAX(health_net_cost) 
  /health_Expenditure_cost=SUM(health_net_cost)
  /Individuals=N.

* Add service users totals per LA and age band - DIFFERENT agg required for LA and different AGES, issues with using individual age bands as percentages too small.
SORT CASES BY lca(A) AgeBand(A) lcaP(A).

AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=lca ageband
  /Service_users=N.

* Calculate percentage.
compute ind_per = 1/Service_users * 100.

*Compute population percentage running total.
string LCA_Age (A30).
compute LCA_Age = CONCAT(lca, ageband).

do if LCA_Age = lag(LCA_Age).
compute LCA_RPercent = ind_per + lag(LCA_RPercent).
else if LCA_Age ne lag(LCA_Age).
compute LCA_RPercent = ind_per.
end if.

compute LCA_RPercent2 = rnd(LCA_RPercent,0.001).

* correct rounding for small numbers.

if LCA_RPercent2 < 0.1 LCA_RPercent2 = 0.1.
compute LCA_RPercent3 = rnd(LCA_RPercent2,0.1).
 
* Now need to ensure that the HRI groups are clearly spilt by 0.1%.
string LCA_HRI_Perc (A30).
compute LCA_HRI_Perc = CONCAT(lca, ageband, HRI_Group).
 
compute  LCA_RPercent3_Str =  LCA_RPercent3.
ALTER TYPE LCA_RPercent3_Str (A5).
 
string LCA_HRI_Perc2 (A50).
compute LCA_HRI_Perc2 = CONCAT(lca, ageband, HRI_Group, LCA_RPercent3_Str).
 
* Here we are adjusting any groups that have the same pecentage as the previous HRI group.
do if  LCA_HRI_Perc = lag( LCA_HRI_Perc).
compute LCA_RPercent_Final = LCA_RPercent3.
if LCA_HRI_Perc2 = lag( LCA_HRI_Perc2) LCA_RPercent_Final = lag(LCA_RPercent_Final ).
else if LCA_HRI_Perc ne lag( LCA_HRI_Perc).
compute LCA_RPercent_Final = LCA_RPercent3 + 0.1.
end if.
 
* Correct High 0.1 records.
string LCA_HRI_Perc3 (A60).
compute LCA_HRI_Perc3 = CONCAT(ageband, HRI_Group, LCA_RPercent3_Str).
if LCA_HRI_Perc3 = 'AllHigh  .10'  LCA_RPercent_Final = 0.1.
 
* Convert Percent to a string for agg.
compute  Population =  LCA_RPercent_Final.
ALTER TYPE Population (A6).
 
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
 
SORT CASES BY lca(A) Population(A) HRI_Sort(A).

do if lca = lag(lca).
compute RTotal_Exp = health_Expenditure_cost + lag(RTotal_Exp).
else if  lca ne lag(lca).
compute RTotal_Exp = health_Expenditure_cost.
end if.
 
* Create % Expenditure Running Total.
AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=lca AgeBand
  /health_Expenditure_cost_TOTAL=SUM(health_Expenditure_cost).
compute RTotal_Exp_Percent = RTotal_Exp/health_Expenditure_cost_TOTAL * 100.
 
Save outfile=!OFilesL +'OVERCHART_ALL_Ages' + !year +'.zsav'
  /zcompressed.

***************************************************************************************************************************.
*** Individual Age groups.
get file = '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.zsav'.
select if LCA = '06' or LCA = '30'.
execute.
select if gender ne 0.
select if hri_lca ne 9.

*Oct. 2019 FC. 
*Non-Service Users must be excluded by the calculations (only for health activities from 2015/16 onwards)
 Otherwise, these users will be counted in the 'Low Users' category.
select if NSU ne 1.
*Remove HRI cost outlier previously found for 2016/17, 2017/18.
Select if Anon_CHI ne 'MDMwNTM2MTEzOQ=='.

rename variables (HRI_lcaP=lcap)(HRI_hbP=hbp)(HRI_Scotp=scotP).

String HRI_Group (A30).
* Create HRI grouping.
if (lcaP lt 50) HRI_Group = 'High'.
if (lcaP ge 50 and lcaP lt 65) HRI_Group = 'High to Medium'.
if (lcaP ge 65 and lcaP lt 80) HRI_Group = 'Medium'.
if (lcaP ge 80 and lcaP lt 95) HRI_Group = 'Medium to Low'.
if (lcaP ge 95) HRI_Group = 'Low'.

* Create required agebands.
string AgeBand (A15).
If (Age lt 18) AgeBand = '<18'.
If (Age ge 18 and Age le 44) AgeBand = '18-44'.
If (Age ge 45 and Age le 64) AgeBand = '45-64'.
If (Age ge 65 and Age le 74) AgeBand = '65-74'.
If (Age ge 75 and Age le 84) AgeBand = '75-84'.
If (Age ge 85) AgeBand = '85+'.

* remove any individuals not attached to a LA area.
SELECT IF lca NE ' '.

*Create totals by age band for use in Tableau.
SORT CASES BY lca(A) AgeBand(A) HRI_Group(A).

compute lca='33'.

AGGREGATE
  /OUTFILE=!OFilesL +'OVERTABLE_IND_Ages' + !year +'.zsav'
  /BREAK=lca AgeBand HRI_Group
  /health_net_cost_min=MIN(health_net_cost) 
  /health_net_cost_max=MAX(health_net_cost) 
  /health_net_cost_sum=SUM(health_net_cost)
  /Individuals=N.

* Add service users totals per LA and age band - DIFFERENT agg required for LA and different AGES, issues with using individual age bands as percentages too small.

SORT CASES BY lca(A) AgeBand(A) lcaP(A).

AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=lca AgeBand
  /Service_users=N.

* Calculate percentage.
compute ind_per = 1/Service_users * 100.

*Compute population percentage running total.
string LCA_Age (A30).
compute LCA_Age = CONCAT(lca, ageband).
 
do if LCA_Age = lag(LCA_Age).
compute LCA_RPercent = ind_per + lag(LCA_RPercent).
else if LCA_Age ne lag(LCA_Age).
compute LCA_RPercent = ind_per.
end if.
 
compute LCA_RPercent2 = rnd(LCA_RPercent,0.001).
 
* correct rounding for small numbers.

if LCA_RPercent2 < 0.1 LCA_RPercent2 = 0.1.
compute LCA_RPercent3 = rnd(LCA_RPercent2,0.1).
 
* Now need to ensure that the HRI groups are clearly spilt by 0.1%.
string LCA_HRI_Perc (A30).
compute LCA_HRI_Perc = CONCAT(lca, ageband, HRI_Group).
 compute  LCA_RPercent3_Str =  LCA_RPercent3.
ALTER TYPE LCA_RPercent3_Str (A6).
 string LCA_HRI_Perc2 (A50).
compute LCA_HRI_Perc2 = CONCAT(lca, ageband, HRI_Group, LCA_RPercent3_Str).
 
* Here we are adjusting any groups that have the same pecentage as the previous HRI group.
do if  LCA_HRI_Perc = lag( LCA_HRI_Perc).
compute LCA_RPercent_Final = LCA_RPercent3.
if LCA_HRI_Perc2 = lag( LCA_HRI_Perc2) LCA_RPercent_Final = lag(LCA_RPercent_Final ).
else if LCA_HRI_Perc ne lag( LCA_HRI_Perc).
compute LCA_RPercent_Final = LCA_RPercent3 + 0.1.
end if.
 
* Correct High 0.1 records.
string LCA_HRI_Perc3 (A60).
compute LCA_HRI_Perc3 = CONCAT(ageband, HRI_Group, LCA_RPercent3_Str).
 if LCA_HRI_Perc3 = 'AllHigh  .10'  LCA_RPercent_Final = 0.1.
 
* Convert Percent to a string for agg.
compute  Population =  LCA_RPercent_Final.
ALTER TYPE Population (A6).
 

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
 

SORT CASES BY lca(A) ageband (A) Population(A) HRI_Sort(A).

string LCA_Age (A30).
compute LCA_Age = CONCAT(lca, ageband).
 

do if LCA_Age = lag(LCA_Age).
compute RTotal_Exp = health_Expenditure_cost + lag(RTotal_Exp).
else if  LCA_Age ne lag(LCA_Age).
compute RTotal_Exp = health_Expenditure_cost.
end if.
 

* Create % Expenditure Running Total.
AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=lca AgeBand
  /health_Expenditure_cost_TOTAL=SUM(health_Expenditure_cost).

compute RTotal_Exp_Percent = RTotal_Exp/health_Expenditure_cost_TOTAL * 100.
 
SORT CASES BY lca(A) AgeBand(A) Population(A) HRI_Sort(A).

Save outfile=!OFilesL+'OVERCHART_IND_Ages' + !year +'.zsav'
   /drop LCA_Age
   /zcompressed.

get file =!OFilesL+'OVERCHART_ALL_Ages' + !year + '.zsav'.

ALTER TYPE ageband (A15).

add files file=*
/file =!OFilesL+'OVERCHART_IND_Ages' + !year + '.zsav'.

* Create year.
String Year (a7).
compute Year = !year2.
 
*add LA Name.
string LCAname(a30).
compute LCAname = 'Clackmannanshire & Stirling'.
*frequency variables = LCAname.

String LA_CODE (a9).
compute LA_CODE = 'S12000030'.
String HBname (a40).
compute HBname = 'Forth Valley Region'.

String HB_CODE (a9).
if HBname = 'Forth Valley Region'          HB_CODE =         'S08000019'.


SAVE OUTFILE= !OFilesL+ 'OVERCHART_' + !year + '_Final.zsav'
  /DROP=lca health_Expenditure_cost_TOTAL
  /zcompressed.

*##################################################################.
*Combining data underlying the dasboard table and charts.
get file=!OFilesL+'OVERTABLE_ALL_Ages' + !year + '.zsav'.
ALTER TYPE ageband (A15).
add files file = *
/file =!OFilesL+'OVERTABLE_IND_Ages' + !year + '.zsav'.

* Create year.
String Year (a7).
compute Year = !year2.
 
SORT CASES BY lca(A) AgeBand(A) HRI_Group(A).

* Calculate number of individuals by Age group and work out Percentage for each HRG group.
AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=lca AgeBand
  /Individuals_sum=SUM(Individuals).
 

compute Percentage_pop = rnd((Individuals/Individuals_sum * 100),0.1).
 
* Correct All ages.
if AgeBand = 'All' AgeBand = 'All ages'.
 

* Correct mis named variables.
recode health_Expenditure_cost_min (sysmis = -99999999).
recode health_Expenditure_cost_max (sysmis = -99999999).
recode health_Expenditure_cost (sysmis = -99999999).
if health_Expenditure_cost_min = -99999999 health_Expenditure_cost_min = health_net_cost_min.
if health_Expenditure_cost_max = -99999999 health_Expenditure_cost_max = health_net_cost_max.
if health_Expenditure_cost = -99999999 health_Expenditure_cost = health_net_cost_sum.
 
*add LA Name.
string LCAname(a30).
compute LCAname = 'Clackmannanshire & Stirling'.
*frequency variables = LCAname.

String LA_CODE (a9).
compute LA_CODE = 'S12000030'.
String HBname (a40).
compute HBname = 'Forth Valley Region'.

***FC Oct. 2018. Updated NHS Fife and Tayside HB codes according to Source Linkage file. 
String HB_CODE (a9).
if HBname = 'Forth Valley Region'          HB_CODE =         'S08000019'.
 
* Add avergae cost per individual by age and GRG group.
compute Average_cost = health_Expenditure_cost/Individuals.
 
* Add data type for TDE.
String Data (A20).
Compute Data = 'Table'.
 
*Save outfile=!file +'OVERTable_' + !year +'_Final.sav'.
save outfile =!OFilesL+'tempOverTable_' + !year + 'data.zsav'
  /DROP=lca health_net_cost_min health_net_cost_max health_net_cost_sum
  /zcompressed.

get file=!OFilesL+'OVERCHART_' + !year + '_Final.zsav'.

*add files file=!OFilesL+'OVERCHART_ALL_Ages' + !year +'.sav'.
*freq vars AgeBand .

* Correct All ages.
if AgeBand = 'All' AgeBand = 'All ages'.

* Add data type for TDE.
String Data (A20).
Compute Data = 'Chart'.

add files file = *
/file= !OFilesL+'tempOverTable_' + !year + 'data.zsav'.

recode RTotal_Exp (sysmis = 0).
recode RTotal_Exp_Percent (sysmis = 0).
recode health_Expenditure_cost_min (sysmis = 0).
recode health_Expenditure_cost_max (sysmis = 0).
recode Individuals (sysmis = 0).
recode Average_cost (sysmis = 0).

save outfile=!OFilesL+'TDE_' + !year + '_Final.zsav'
  /zcompressed.

save outfile=!OFilesL+'TDE_' + !year + '_Final.sav'.

Add files file = !OFilesL+ 'TDE_201920_Final.zsav'  
 /file = !OFilesL+ 'TDE_202021_Final.zsav' 
 /file = !OFilesL+ 'TDE_201718_Final.zsav'
 /file = !OFilesL+ 'TDE_201819_Final.zsav'. 

SAVE OUTFILE = !OFilesL + 'HRI_chart_All_CS.sav'.


*SAVE TRANSLATE OUTFILE= !OFilesL+'TDE_' + !year + '_Final.xlsx' 
/type=xlsx /version=12 /fieldnames/replace
  /COMPRESSED.
* 
*************************************************************************************************************************************************.


