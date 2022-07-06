******************************************************************************************************************************************************************************
*******************************Syntax to produce Scotland level data for Sankey chart for Dashboard 2 of HRI Pathways workbook***********************************.
***********************************************BEWARE - Long running time - Please ensure large file space before running**********************************.



*define !CostedFiles()
'/conf/irf/10-PLICS-analysis-files/masterPLICS_Costed_201516.sav'
!enddefine.

*define !CHICostedFiles()
'/conf/irf/10-PLICS-analysis-files/CHImasterPLICS_Costed_201516.sav'
!enddefine.

* File save location.
define !OFilesL()
           '/conf/sourcedev/TableauUpdates/HRIpathways/'
!Enddefine.


*Define !HRIfile255075()
     '/conf/linkage/output/keirro/01-HRI-1516-255075.sav'
!Enddefine.
******************************************************************
*add notes.
*************************************************************************************************************************************************.
*** Start with latest year.

*************************************************************************************************************************************************.
*** Next year.
*Macro 1.
Define !year()
'201617'
!Enddefine.

get file = '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.sav'.
select if gender ne 0.
select if hri_scot ne 9.
EXECUTE.

rename variables health_postcode =pc7. 
alter type pc7 (A21).
*Execute.
*Create a Scottish flag for the people we know are definitely Scottish as they have a Scottish postcode. 
Sort cases by pc7.
*match files file =*
/Table = '/conf/linkage/output/alisom18/New_Scot_Post_LKP1.sav'
/by PC7.
*execute. 


*delete variables PC_District.
String PCDistrict (A12).
Compute PCDistrict = substr(PC7,1,4).
execute. 


sort cases by pcDistrict.
match files file = *
/table = '/conf/linkage/output/jamiem09/ScotLookup.sav'
/by PCDistrict.
exe.

*Flag people as Scottish if they have a blank postcode and blank gpprac - we assume that these people are Scottish. 
If pc7 = "" and gpprac= "" ScotFlag = 1.
*execute. 

*Finally, we exclude people who have a blank postcode and an English GPprac. 
*If a GP practice is English then it will begin with a letter. 
String GP (A1).
Compute GP = substr(gpprac,1,1).
*execute. 

String Eng_Flag (A1).
If any(GP, 'A','Z') Eng_Flag='1'.
If (PC7 = "" and Eng_Flag ne '1') scotflag=1.
If (PC7='null' and Eng_Flag ne '1') scotflag = 1.
*execute. 



*There are some Glasgow postcodes which have not been recognised as Scottish so have to include these. 
String Glasgow_Flag (A2).
Compute Glasgow_Flag = substr(Pc7,1,2).
execute.

If Any(Glasgow_Flag, 'G0', 'G1', 'G2', 'G3', 'G4', 'G5', 'G6', 'G7', 'G8', 'G9' ) Scotflag = 1.
*There are still a lot of Scottish people so use the Glasgow flag to identify the following.
If Any(Glasgow_Flag, 'DD', 'EH', 'IV', 'AB', 'KA', 'FK', 'HS', 'KW', 'KY', 'ML', 'PA', 'PH','ZE') Scotflag = 1.
*execute. 

recode scotflag (sysmis=0).

sort cases by pc7.
*match files file =*
/Table = '/conf/linkage/output/alisom18/New_Scot_Post_LKP2.sav'
/by PC7.
*execute. 
*if scot_flag_1 = 1 scotflag = 1.
*execute. 

frequencies variables = scotflag.


frequencies variables = pc_District.
*rename variables PC_District = PCDistrict.
*alter type PCDistrict (A18). 
*match files file =*
/Table = !clout + 'Postcode_district_from_standard_ref.sav'
/by PCDistrict.
*execute. 
*if scot_flag_1 = 1 scotflag = 1.
*execute. 

FREQUENCIES VARIABLES=ScotFlag
  /ORDER=ANALYSIS.

*2010/11 5095 excluded.
*2011/12 5039 excluded. 
*2012/13 6265 excluded. 
*2013/14 8266 excluded. 

*Way of checking Non-Scottish people you are about to exclude.
String NonScot (A7).
Compute NonScot = ''.
If Scotflag ne 1 NonScot = pc7.
FREQUENCIES VARIABLES=NonScot
  /ORDER=ANALYSIS.


*Select if Scot_Flag = 1.
*execute. 

Delete variables  GP Glasgow_Flag Eng_Flag  count.
 

select if scotflag = 1.
execute. 
Delete variables Scotflag.

String HRI_Group (A30).
* Create HRI grouping.
if (HRI_scotP lt 50) HRI_Group = 'High'.
if (HRI_scotP ge 50 and HRI_scotP lt 65) HRI_Group = 'High to Medium'.
if (HRI_scotP ge 65 and HRI_scotP lt 80) HRI_Group = 'Medium'.
if (HRI_scotP ge 80 and HRI_scotP lt 95) HRI_Group = 'Medium to Low'.
if (HRI_scotP ge 95) HRI_Group = 'Low'.
EXECUTE.

* Adjust age to base of latest year.
alter type dob (F8.0).
compute age= trunc((20160930-dob)/10000).
alter type age (F3.0).
execute.



* Create required agebands.
string AgeBand (a5).
If (Age lt 18) AgeBand = '<18'.
If (Age ge 18 and Age le 44) AgeBand = '18-44'.
If (Age ge 45 and Age le 64) AgeBand = '45-64'.
If (Age ge 65 and Age le 74) AgeBand = '65-74'.
If (Age ge 75 and Age le 84) AgeBand = '75-84'.
If (Age ge 85) AgeBand = '85+'.
Execute. 

* Remove any individuals not within a LA.
*select if lca NE ' '.
EXECUTE.

compute lca = 'Scotland'.
rename variables (lca HRI_Group health_net_cost = lca1617 HRI_Group1617 health_net_cost1617).

sort cases by chi.


AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=AgeBand gender HRI_Group1617 lca1617
  /health_net_cost1617_min=MIN(health_net_cost1617) 
  /health_net_cost1617_max=MAX(health_net_cost1617).

save outfile  = !OFilesL + 'temp_HRI_LA_1617_T1.sav'
/keep year CHI gender health_net_cost1617 lca1617 datazone2011 AgeBand LCA1617 HRI_Group1617 health_net_cost1617_min health_net_cost1617_max deceased_flag date_death.

*All ages.
get file  = !OFilesL + 'temp_HRI_LA_1617_T1.sav'
/keep year CHI gender health_net_cost1617 lca1617 datazone2011 AgeBand LCA1617 HRI_Group1617 deceased_flag date_death.

compute AgeBand = 'All'.
EXECUTE.

AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=AgeBand gender HRI_Group1617 lca1617
  /health_net_cost1617_min=MIN(health_net_cost1617) 
  /health_net_cost1617_max=MAX(health_net_cost1617).

save outfile  = !OFilesL + 'temp_HRI_LA_1617_T2.sav'
/keep year CHI gender health_net_cost1617 lca1617 datazone2011 AgeBand LCA1617 HRI_Group1617 health_net_cost1617_min health_net_cost1617_max deceased_flag date_death.

* By Gender.
get file  = !OFilesL + 'temp_HRI_LA_1617_T1.sav'
/keep year CHI gender health_net_cost1617 lca1617 datazone2011 AgeBand LCA1617 HRI_Group1617 deceased_flag date_death.

compute gender = 0.
EXECUTE.

AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=AgeBand gender HRI_Group1617 lca1617
  /health_net_cost1617_min=MIN(health_net_cost1617) 
  /health_net_cost1617_max=MAX(health_net_cost1617).

save outfile  = !OFilesL + 'temp_HRI_LA_1617_T3.sav'
/keep year CHI gender health_net_cost1617 lca1617 datazone2011 AgeBand LCA1617 HRI_Group1617 health_net_cost1617_min health_net_cost1617_max deceased_flag date_death.

*Both Age and gender.
get file  = !OFilesL + 'temp_HRI_LA_1617_T1.sav'
/keep year CHI gender health_net_cost1617 lca1617 datazone2011 AgeBand LCA1617 HRI_Group1617 deceased_flag date_death.

compute AgeBand = 'All'.
compute gender = 0.
EXECUTE.

AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=AgeBand gender HRI_Group1617 lca1617
  /health_net_cost1617_min=MIN(health_net_cost1617) 
  /health_net_cost1617_max=MAX(health_net_cost1617).

save outfile  = !OFilesL + 'temp_HRI_LA_1617_T4.sav'
/keep year CHI gender health_net_cost1617 lca1617 datazone2011 AgeBand LCA1617 HRI_Group1617 health_net_cost1617_min health_net_cost1617_max deceased_flag date_death.

add files file = !OFilesL + 'temp_HRI_LA_1617_T1.sav'
/file = !OFilesL + 'temp_HRI_LA_1617_T2.sav'
/file = !OFilesL + 'temp_HRI_LA_1617_T3.sav'
/file = !OFilesL + 'temp_HRI_LA_1617_T4.sav'.
exe.

sort cases by chi AgeBand gender.

save outfile  = !OFilesL + 'temp_HRI_LA_1617.sav'.
* Tidy up.
ERASE file  = !OFilesL + 'temp_HRI_LA_1617_T1.sav'.
ERASE file  = !OFilesL + 'temp_HRI_LA_1617_T2.sav'.
ERASE file  = !OFilesL + 'temp_HRI_LA_1617_T3.sav'.
ERASE file  = !OFilesL + 'temp_HRI_LA_1617_T4.sav'.


****************************************************************************************************************


*Macro 1.
Define !year()
'201516'
!Enddefine.


get file = '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.sav'.
select if gender ne 0.
select if hri_scot ne 9.
EXECUTE.

rename variables health_postcode =pc7. 
alter type pc7 (A21).
*Execute.
*Create a Scottish flag for the people we know are definitely Scottish as they have a Scottish postcode. 
Sort cases by pc7.
*match files file =*
/Table = '/conf/linkage/output/alisom18/New_Scot_Post_LKP1.sav'
/by PC7.
*execute. 


*delete variables PC_District.
String PCDistrict (A12).
Compute PCDistrict = substr(PC7,1,4).
execute. 


sort cases by pcDistrict.
match files file = *
/table = '/conf/linkage/output/jamiem09/ScotLookup.sav'
/by PCDistrict.
exe.


*Flag people as Scottish if they have a blank postcode and blank gpprac - we assume that these people are Scottish. 
If pc7 = "" and gpprac= "" ScotFlag = 1.
*execute. 

*Finally, we exclude people who have a blank postcode and an English GPprac. 
*If a GP practice is English then it will begin with a letter. 
String GP (A1).
Compute GP = substr(gpprac,1,1).
*execute. 

String Eng_Flag (A1).
If any(GP, 'A','Z') Eng_Flag='1'.
If (PC7 = "" and Eng_Flag ne '1') scotflag=1.
If (PC7='null' and Eng_Flag ne '1') scotflag = 1.
*execute. 



*There are some Glasgow postcodes which have not been recognised as Scottish so have to include these. 
String Glasgow_Flag (A2).
Compute Glasgow_Flag = substr(Pc7,1,2).
execute.

If Any(Glasgow_Flag, 'G0', 'G1', 'G2', 'G3', 'G4', 'G5', 'G6', 'G7', 'G8', 'G9' ) Scotflag = 1.
*There are still a lot of Scottish people so use the Glasgow flag to identify the following.
If Any(Glasgow_Flag, 'DD', 'EH', 'IV', 'AB', 'KA', 'FK', 'HS', 'KW', 'KY', 'ML', 'PA', 'PH','ZE') Scotflag = 1.
*execute. 

recode scotflag (sysmis=0).

sort cases by pc7.
*match files file =*
/Table = '/conf/linkage/output/alisom18/New_Scot_Post_LKP2.sav'
/by PC7.
*execute. 
*if scot_flag_1 = 1 scotflag = 1.
*execute. 

frequencies variables = scotflag.


frequencies variables = pc_District.
*rename variables PC_District = PCDistrict.
*alter type PCDistrict (A18). 
*match files file =*
/Table = !clout + 'Postcode_district_from_standard_ref.sav'
/by PCDistrict.
*execute. 
*if scot_flag_1 = 1 scotflag = 1.
*execute. 

FREQUENCIES VARIABLES=ScotFlag
  /ORDER=ANALYSIS.

*2010/11 5095 excluded.
*2011/12 5039 excluded. 
*2012/13 6265 excluded. 
*2013/14 8266 excluded. 

*Way of checking Non-Scottish people you are about to exclude.
String NonScot (A7).
Compute NonScot = ''.
If Scotflag ne 1 NonScot = pc7.
FREQUENCIES VARIABLES=NonScot
  /ORDER=ANALYSIS.


*Select if Scot_Flag = 1.
*execute. 

Delete variables  GP Glasgow_Flag Eng_Flag  count.
 

select if scotflag = 1.
execute. 
Delete variables Scotflag.
String HRI_Group (A30).

* Create HRI grouping.
if (HRI_scotP lt 50) HRI_Group = 'High'.
if (HRI_scotP ge 50 and HRI_scotP lt 65) HRI_Group = 'High to Medium'.
if (HRI_scotP ge 65 and HRI_scotP lt 80) HRI_Group = 'Medium'.
if (HRI_scotP ge 80 and HRI_scotP lt 95) HRI_Group = 'Medium to Low'.
if (HRI_scotP ge 95) HRI_Group = 'Low'.
EXECUTE.

*compute age.
alter type dob (F8.0).
compute age= trunc((20150930-dob)/10000).
alter type age (F3.0).
execute.
compute Age = Age + 1.
exe.

* Create required agebands.
string AgeBand (a5).
If (Age lt 18) AgeBand = '<18'.
If (Age ge 18 and Age le 44) AgeBand = '18-44'.
If (Age ge 45 and Age le 64) AgeBand = '45-64'.
If (Age ge 65 and Age le 74) AgeBand = '65-74'.
If (Age ge 75 and Age le 84) AgeBand = '75-84'.
If (Age ge 85) AgeBand = '85+'.
Execute. 

* Remove any individuals not within a LA.
*select if lca NE ' '.
EXECUTE.

compute lca = 'Scotland'.
rename variables (lca HRI_Group health_net_cost = lca1516 HRI_Group1516 health_net_cost1516).

sort cases by chi.


AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=AgeBand gender HRI_Group1516 lca1516
  /health_net_cost1516_min=MIN(health_net_cost1516) 
  /health_net_cost1516_max=MAX(health_net_cost1516).

save outfile  = !OFilesL + 'temp_HRI_LA_1516_T1.sav'
/keep year CHI gender health_net_cost1516 lca1516 datazone2011 AgeBand LCA1516 HRI_Group1516 health_net_cost1516_min health_net_cost1516_max deceased_flag date_death.

*All ages.
get file  = !OFilesL + 'temp_HRI_LA_1516_T1.sav'
/keep year CHI gender health_net_cost1516 lca1516 datazone2011 AgeBand LCA1516 HRI_Group1516 deceased_flag date_death.

compute AgeBand = 'All'.
EXECUTE.

AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=AgeBand gender HRI_Group1516 lca1516
  /health_net_cost1516_min=MIN(health_net_cost1516) 
  /health_net_cost1516_max=MAX(health_net_cost1516).

save outfile  = !OFilesL + 'temp_HRI_LA_1516_T2.sav'
/keep year CHI gender health_net_cost1516 lca1516 datazone2011 AgeBand LCA1516 HRI_Group1516 health_net_cost1516_min health_net_cost1516_max deceased_flag date_death.

* By Gender.
get file  = !OFilesL + 'temp_HRI_LA_1516_T1.sav'
/keep year CHI gender health_net_cost1516 lca1516 datazone2011 AgeBand LCA1516 HRI_Group1516 deceased_flag date_death.

compute gender = 0.
EXECUTE.

AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=AgeBand gender HRI_Group1516 lca1516
  /health_net_cost1516_min=MIN(health_net_cost1516) 
  /health_net_cost1516_max=MAX(health_net_cost1516).

save outfile  = !OFilesL + 'temp_HRI_LA_1516_T3.sav'
/keep year CHI gender health_net_cost1516 lca1516 datazone2011 AgeBand LCA1516 HRI_Group1516 health_net_cost1516_min health_net_cost1516_max deceased_flag date_death.

*Both Age and gender.
get file  = !OFilesL + 'temp_HRI_LA_1516_T1.sav'
/keep year CHI gender health_net_cost1516 lca1516 datazone2011 AgeBand LCA1516 HRI_Group1516 deceased_flag date_death.

compute AgeBand = 'All'.
compute gender = 0.
EXECUTE.

AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=AgeBand gender HRI_Group1516 lca1516
  /health_net_cost1516_min=MIN(health_net_cost1516) 
  /health_net_cost1516_max=MAX(health_net_cost1516).

save outfile  = !OFilesL + 'temp_HRI_LA_1516_T4.sav'
/keep year CHI gender health_net_cost1516 lca1516 datazone2011 AgeBand LCA1516 HRI_Group1516 health_net_cost1516_min health_net_cost1516_max deceased_flag date_death.

add files file = !OFilesL + 'temp_HRI_LA_1516_T1.sav'
/file = !OFilesL + 'temp_HRI_LA_1516_T2.sav'
/file = !OFilesL + 'temp_HRI_LA_1516_T3.sav'
/file = !OFilesL + 'temp_HRI_LA_1516_T4.sav'.
exe.

sort cases by chi AgeBand gender.

save outfile  = !OFilesL + 'temp_HRI_LA_1516.sav'.

* Tidy up.
ERASE file  = !OFilesL + 'temp_HRI_LA_1516_T1.sav'.
ERASE file  = !OFilesL + 'temp_HRI_LA_1516_T2.sav'.
ERASE file  = !OFilesL + 'temp_HRI_LA_1516_T3.sav'.
ERASE file  = !OFilesL + 'temp_HRI_LA_1516_T4.sav'.


************************************************.


*************************************************************************************************************************************************.
*** Next year.
**Macro 1.
Define !year()
'201415'
!Enddefine.

get file = '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.sav'.
select if gender ne 0.
select if hri_scot ne 9.
EXECUTE.

rename variables health_postcode =pc7. 
alter type pc7 (A21).
*Execute.
*Create a Scottish flag for the people we know are definitely Scottish as they have a Scottish postcode. 
Sort cases by pc7.
*match files file =*
/Table = '/conf/linkage/output/alisom18/New_Scot_Post_LKP1.sav'
/by PC7.
*execute. 

*delete variables PC_District.
String PCDistrict (A12).
Compute PCDistrict = substr(PC7,1,4).
execute. 


sort cases by pcDistrict.
match files file = *
/table = '/conf/linkage/output/jamiem09/ScotLookup.sav'
/by PCDistrict.
exe.


*Flag people as Scottish if they have a blank postcode and blank gpprac - we assume that these people are Scottish. 
If pc7 = "" and gpprac= "" ScotFlag = 1.
*execute. 

*Finally, we exclude people who have a blank postcode and an English GPprac. 
*If a GP practice is English then it will begin with a letter. 
String GP (A1).
Compute GP = substr(gpprac,1,1).
*execute. 

String Eng_Flag (A1).
If any(GP, 'A','Z') Eng_Flag='1'.
If (PC7 = "" and Eng_Flag ne '1') scotflag=1.
If (PC7='null' and Eng_Flag ne '1') scotflag = 1.
*execute. 



*There are some Glasgow postcodes which have not been recognised as Scottish so have to include these. 
String Glasgow_Flag (A2).
Compute Glasgow_Flag = substr(Pc7,1,2).
execute.

If Any(Glasgow_Flag, 'G0', 'G1', 'G2', 'G3', 'G4', 'G5', 'G6', 'G7', 'G8', 'G9' ) Scotflag = 1.
*There are still a lot of Scottish people so use the Glasgow flag to identify the following.
If Any(Glasgow_Flag, 'DD', 'EH', 'IV', 'AB', 'KA', 'FK', 'HS', 'KW', 'KY', 'ML', 'PA', 'PH','ZE') Scotflag = 1.
*execute. 

recode scotflag (sysmis=0).

sort cases by pc7.
*match files file =*
/Table = '/conf/linkage/output/alisom18/New_Scot_Post_LKP2.sav'
/by PC7.
*execute. 
*if scot_flag_1 = 1 scotflag = 1.
*execute. 

frequencies variables = scotflag.


frequencies variables = pc_District.
*rename variables PC_District = PCDistrict.
*alter type PCDistrict (A18). 
*match files file =*
/Table = !clout + 'Postcode_district_from_standard_ref.sav'
/by PCDistrict.
*execute. 
*if scot_flag_1 = 1 scotflag = 1.
*execute. 

FREQUENCIES VARIABLES=ScotFlag
  /ORDER=ANALYSIS.

*2010/11 5095 excluded.
*2011/12 5039 excluded. 
*2012/13 6265 excluded. 
*2013/14 8266 excluded. 

*Way of checking Non-Scottish people you are about to exclude.
String NonScot (A7).
Compute NonScot = ''.
If Scotflag ne 1 NonScot = pc7.
FREQUENCIES VARIABLES=NonScot
  /ORDER=ANALYSIS.


*Select if Scot_Flag = 1.
*execute. 

Delete variables  GP Glasgow_Flag Eng_Flag  count.
 

select if scotflag = 1.
execute. 
Delete variables Scotflag.

String HRI_Group (A30).
* Create HRI grouping.
if (HRI_scotP lt 50) HRI_Group = 'High'.
if (HRI_scotP ge 50 and HRI_scotP lt 65) HRI_Group = 'High to Medium'.
if (HRI_scotP ge 65 and HRI_scotP lt 80) HRI_Group = 'Medium'.
if (HRI_scotP ge 80 and HRI_scotP lt 95) HRI_Group = 'Medium to Low'.
if (HRI_scotP ge 95) HRI_Group = 'Low'.
EXECUTE.

* Adjust age to base of latest year.
alter type dob (F8.0).
compute age= trunc((20140930-dob)/10000).
alter type age (F3.0).
execute.
compute Age = Age + 2.
exe.

* Create required agebands.
string AgeBand (a5).
If (Age lt 18) AgeBand = '<18'.
If (Age ge 18 and Age le 44) AgeBand = '18-44'.
If (Age ge 45 and Age le 64) AgeBand = '45-64'.
If (Age ge 65 and Age le 74) AgeBand = '65-74'.
If (Age ge 75 and Age le 84) AgeBand = '75-84'.
If (Age ge 85) AgeBand = '85+'.
Execute. 

* Remove any individuals not within a LA.
*select if lca NE ' '.
EXECUTE.
compute lca = 'Scotland'.
rename variables (lca HRI_Group health_net_cost = lca1415 HRI_Group1415 health_net_cost1415).

sort cases by chi.


AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=AgeBand gender HRI_Group1415 lca1415
  /health_net_cost1415_min=MIN(health_net_cost1415) 
  /health_net_cost1415_max=MAX(health_net_cost1415).

save outfile  = !OFilesL + 'temp_HRI_LA_1415_T1.sav'
/keep year CHI gender health_net_cost1415 lca1415 datazone2011 AgeBand LCA1415 HRI_Group1415 health_net_cost1415_min health_net_cost1415_max deceased_flag date_death.

*All ages.
get file  = !OFilesL + 'temp_HRI_LA_1415_T1.sav'
/keep year CHI gender health_net_cost1415 lca1415 datazone2011 AgeBand LCA1415 HRI_Group1415 deceased_flag date_death.

compute AgeBand = 'All'.
EXECUTE.

AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=AgeBand gender HRI_Group1415 lca1415
  /health_net_cost1415_min=MIN(health_net_cost1415) 
  /health_net_cost1415_max=MAX(health_net_cost1415).

save outfile  = !OFilesL + 'temp_HRI_LA_1415_T2.sav'
/keep year CHI gender health_net_cost1415 lca1415 datazone2011 AgeBand LCA1415 HRI_Group1415 health_net_cost1415_min health_net_cost1415_max deceased_flag date_death.

* By Gender.
get file  = !OFilesL + 'temp_HRI_LA_1415_T1.sav'
/keep year CHI gender health_net_cost1415 lca1415 datazone2011 AgeBand LCA1415 HRI_Group1415 deceased_flag date_death.

compute gender = 0.
EXECUTE.

AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=AgeBand gender HRI_Group1415 lca1415
  /health_net_cost1415_min=MIN(health_net_cost1415) 
  /health_net_cost1415_max=MAX(health_net_cost1415).

save outfile  = !OFilesL + 'temp_HRI_LA_1415_T3.sav'
/keep year CHI gender health_net_cost1415 lca1415 datazone2011 AgeBand LCA1415 HRI_Group1415 health_net_cost1415_min health_net_cost1415_max deceased_flag date_death.

*Both Age and gender.
get file  = !OFilesL + 'temp_HRI_LA_1415_T1.sav'
/keep year CHI gender health_net_cost1415 lca1415 datazone2011 AgeBand LCA1415 HRI_Group1415 deceased_flag date_death.

compute AgeBand = 'All'.
compute gender = 0.
EXECUTE.

AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=AgeBand gender HRI_Group1415 lca1415
  /health_net_cost1415_min=MIN(health_net_cost1415) 
  /health_net_cost1415_max=MAX(health_net_cost1415).

save outfile  = !OFilesL + 'temp_HRI_LA_1415_T4.sav'
/keep year CHI gender health_net_cost1415 lca1415 datazone2011 AgeBand LCA1415 HRI_Group1415 health_net_cost1415_min health_net_cost1415_max deceased_flag date_death.

add files file = !OFilesL + 'temp_HRI_LA_1415_T1.sav'
/file = !OFilesL + 'temp_HRI_LA_1415_T2.sav'
/file = !OFilesL + 'temp_HRI_LA_1415_T3.sav'
/file = !OFilesL + 'temp_HRI_LA_1415_T4.sav'.
exe.

sort cases by chi AgeBand gender.

save outfile  = !OFilesL + 'temp_HRI_LA_1415.sav'.

* Tidy up.
ERASE file  = !OFilesL + 'temp_HRI_LA_1415_T1.sav'.
ERASE file  = !OFilesL + 'temp_HRI_LA_1415_T2.sav'.
ERASE file  = !OFilesL + 'temp_HRI_LA_1415_T3.sav'.
ERASE file  = !OFilesL + 'temp_HRI_LA_1415_T4.sav'.


***********************************************.

*************************************************************************************************************************************************.
*** Next year.
*Macro 1.
Define !year()
'201314'
!Enddefine.


get file = '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.sav'.
select if gender ne 0.
select if hri_scot ne 9.
EXECUTE.

rename variables health_postcode =pc7. 
alter type pc7 (A21).
*Execute.
*Create a Scottish flag for the people we know are definitely Scottish as they have a Scottish postcode. 
Sort cases by pc7.
*match files file =*
/Table = '/conf/linkage/output/alisom18/New_Scot_Post_LKP1.sav'
/by PC7.
*execute. . 


*delete variables PC_District.
String PCDistrict (A12).
Compute PCDistrict = substr(PC7,1,4).
execute. 


sort cases by pcDistrict.
match files file = *
/table = '/conf/linkage/output/jamiem09/ScotLookup.sav'
/by PCDistrict.
exe.


*Flag people as Scottish if they have a blank postcode and blank gpprac - we assume that these people are Scottish. 
If pc7 = "" and gpprac= "" ScotFlag = 1.
*execute. 

*Finally, we exclude people who have a blank postcode and an English GPprac. 
*If a GP practice is English then it will begin with a letter. 
String GP (A1).
Compute GP = substr(gpprac,1,1).
*execute. 

String Eng_Flag (A1).
If any(GP, 'A','Z') Eng_Flag='1'.
If (PC7 = "" and Eng_Flag ne '1') scotflag=1.
If (PC7='null' and Eng_Flag ne '1') scotflag = 1.
*execute. 



*There are some Glasgow postcodes which have not been recognised as Scottish so have to include these. 
String Glasgow_Flag (A2).
Compute Glasgow_Flag = substr(Pc7,1,2).
execute.

If Any(Glasgow_Flag, 'G0', 'G1', 'G2', 'G3', 'G4', 'G5', 'G6', 'G7', 'G8', 'G9' ) Scotflag = 1.
*There are still a lot of Scottish people so use the Glasgow flag to identify the following.
If Any(Glasgow_Flag, 'DD', 'EH', 'IV', 'AB', 'KA', 'FK', 'HS', 'KW', 'KY', 'ML', 'PA', 'PH','ZE') Scotflag = 1.
*execute. 

recode scotflag (sysmis=0).

sort cases by pc7.
*match files file =*
/Table = '/conf/linkage/output/alisom18/New_Scot_Post_LKP2.sav'
/by PC7.
*execute. 
*if scot_flag_1 = 1 scotflag = 1.
*execute. 

frequencies variables = scotflag.


frequencies variables = pc_District.
*rename variables PC_District = PCDistrict.
*alter type PCDistrict (A18). 
*match files file =*
/Table = !clout + 'Postcode_district_from_standard_ref.sav'
/by PCDistrict.
*execute. 
*if scot_flag_1 = 1 scotflag = 1.
*execute. 

FREQUENCIES VARIABLES=ScotFlag
  /ORDER=ANALYSIS.

*2010/11 5095 excluded.
*2011/12 5039 excluded. 
*2012/13 6265 excluded. 
*2013/14 8266 excluded. 

*Way of checking Non-Scottish people you are about to exclude.
String NonScot (A7).
Compute NonScot = ''.
If Scotflag ne 1 NonScot = pc7.
FREQUENCIES VARIABLES=NonScot
  /ORDER=ANALYSIS.


*Select if Scot_Flag = 1.
*execute. 

Delete variables  GP Glasgow_Flag Eng_Flag  count.
 

select if scotflag = 1.
execute. 
Delete variables Scotflag.

String HRI_Group (A30).
* Create HRI grouping.
if (HRI_scotP lt 50) HRI_Group = 'High'.
if (HRI_scotP ge 50 and HRI_scotP lt 65) HRI_Group = 'High to Medium'.
if (HRI_scotP ge 65 and HRI_scotP lt 80) HRI_Group = 'Medium'.
if (HRI_scotP ge 80 and HRI_scotP lt 95) HRI_Group = 'Medium to Low'.
if (HRI_scotP ge 95) HRI_Group = 'Low'.
EXECUTE.

* Adjust age to base of latest year.
alter type dob (F8.0).
compute age= trunc((20130930-dob)/10000).
alter type age (F3.0).
execute.

compute Age = Age + 3.
exe.


* Create required agebands.
string AgeBand (a5).
If (Age lt 18) AgeBand = '<18'.
If (Age ge 18 and Age le 44) AgeBand = '18-44'.
If (Age ge 45 and Age le 64) AgeBand = '45-64'.
If (Age ge 65 and Age le 74) AgeBand = '65-74'.
If (Age ge 75 and Age le 84) AgeBand = '75-84'.
If (Age ge 85) AgeBand = '85+'.
Execute. 

* Remove any individuals not within a LA.
*select if lca NE ' '.
EXECUTE.
compute lca = 'Scotland'.
rename variables (lca HRI_Group health_net_cost = lca1314 HRI_Group1314 health_net_cost1314).

sort cases by chi.


AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=AgeBand gender HRI_Group1314 lca1314
  /health_net_cost1314_min=MIN(health_net_cost1314) 
  /health_net_cost1314_max=MAX(health_net_cost1314).

save outfile  = !OFilesL + 'temp_HRI_LA_1314_T1.sav'
/keep year CHI gender health_net_cost1314 lca1314 datazone2011 AgeBand LCA1314 HRI_Group1314 health_net_cost1314_min health_net_cost1314_max deceased_flag date_death.

*All ages.
get file  = !OFilesL + 'temp_HRI_LA_1314_T1.sav'
/keep year CHI gender health_net_cost1314 lca1314 datazone2011 AgeBand LCA1314 HRI_Group1314 deceased_flag date_death.

compute AgeBand = 'All'.
EXECUTE.

AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=AgeBand gender HRI_Group1314 lca1314
  /health_net_cost1314_min=MIN(health_net_cost1314) 
  /health_net_cost1314_max=MAX(health_net_cost1314).

save outfile  = !OFilesL + 'temp_HRI_LA_1314_T2.sav'
/keep year CHI gender health_net_cost1314 lca1314 datazone2011 AgeBand LCA1314 HRI_Group1314 health_net_cost1314_min health_net_cost1314_max deceased_flag date_death.

* By Gender.
get file  = !OFilesL + 'temp_HRI_LA_1314_T1.sav'
/keep year CHI gender health_net_cost1314 lca1314 datazone2011 AgeBand LCA1314 HRI_Group1314 deceased_flag date_death.

compute gender = 0.
EXECUTE.

AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=AgeBand gender HRI_Group1314 lca1314
  /health_net_cost1314_min=MIN(health_net_cost1314) 
  /health_net_cost1314_max=MAX(health_net_cost1314).

save outfile  = !OFilesL + 'temp_HRI_LA_1314_T3.sav'
/keep year CHI gender health_net_cost1314 lca1314 datazone2011 AgeBand LCA1314 HRI_Group1314 health_net_cost1314_min health_net_cost1314_max deceased_flag date_death.

*Both Age and gender.
get file  = !OFilesL + 'temp_HRI_LA_1314_T1.sav'
/keep year CHI gender health_net_cost1314 lca1314 datazone2011 AgeBand LCA1314 HRI_Group1314 deceased_flag date_death.

compute AgeBand = 'All'.
compute gender = 0.
EXECUTE.

AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=AgeBand gender HRI_Group1314 lca1314
  /health_net_cost1314_min=MIN(health_net_cost1314) 
  /health_net_cost1314_max=MAX(health_net_cost1314).

save outfile  = !OFilesL + 'temp_HRI_LA_1314_T4.sav'
/keep year CHI gender health_net_cost1314 lca1314 datazone2011 AgeBand LCA1314 HRI_Group1314 health_net_cost1314_min health_net_cost1314_max deceased_flag date_death.

add files file = !OFilesL + 'temp_HRI_LA_1314_T1.sav'
/file = !OFilesL + 'temp_HRI_LA_1314_T2.sav'
/file = !OFilesL + 'temp_HRI_LA_1314_T3.sav'
/file = !OFilesL + 'temp_HRI_LA_1314_T4.sav'.
exe.

sort cases by chi AgeBand gender.

save outfile  = !OFilesL + 'temp_HRI_LA_1314.sav'.

* Tidy up.
ERASE file  = !OFilesL + 'temp_HRI_LA_1314_T1.sav'.
ERASE file  = !OFilesL + 'temp_HRI_LA_1314_T2.sav'.
ERASE file  = !OFilesL + 'temp_HRI_LA_1314_T3.sav'.
ERASE file  = !OFilesL + 'temp_HRI_LA_1314_T4.sav'.
***********************************************.



************************************************************************************.
*Bring all files together.

Get file  = !OFilesL + 'temp_HRI_LA_1617.sav'.

match files file = *
/file =  !OFilesL + 'temp_HRI_LA_1415.sav'
/file =  !OFilesL + 'temp_HRI_LA_1314.sav'
/file =  !OFilesL + 'temp_HRI_LA_1516.sav'
/by chi AgeBand gender.
EXECUTE.

* Convert LA variable to a number.
alter type LCA1617 (F2.0).
alter type LCA1314 (F2.0).
alter type LCA1415 (F2.0).
alter type LCA1516 (F2.0).
ALTER TYPE date_death (F8).

save outfile  = !OFilesL + 'temp_HRI_LA_MASTER_ALLYR.sav'.

* Tidy up.
ERASE file  =  !OFilesL + 'temp_HRI_LA_1617.sav'.
ERASE file  =  !OFilesL + 'temp_HRI_LA_1314.sav'.
ERASE file  =  !OFilesL + 'temp_HRI_LA_1415.sav'.
ERASE file  =  !OFilesL + 'temp_HRI_LA_1516.sav'.

** Now need to create individual LA records to track individuals overtime.

get file  = !OFilesL + 'temp_HRI_LA_MASTER_ALLYR.sav'.



* Add death marker.
if date_death < 20160401 HRI_Group1617 = 'Died'.
if date_death < 20150401 HRI_Group1516 = 'Died'.
if date_death < 20140401 HRI_Group1415 = 'Died'.
if date_death > 20160401 and HRI_Group1617 = ' ' HRI_Group1617 = 'Died'.
EXECUTE.

* Assume any blanks are now showing no contact in year.
if HRI_Group1516 = ' ' HRI_Group1516 = 'No Contact'.
if HRI_Group1415 = ' ' HRI_Group1415 = 'No Contact'.
if HRI_Group1314 = ' ' HRI_Group1314 = 'No Contact'.
if HRI_Group1617 = ' ' HRI_Group1617 = 'No Contact'.
EXECUTE.


* Remove Costs data for those Died before start of FY.
if HRI_Group1516 = "Died" health_net_cost1516 = 0.
if HRI_Group1415 = "Died" health_net_cost1415 = 0.
if HRI_Group1314 = "Died" health_net_cost1314 = 0.
if HRI_Group1617 = "Died" health_net_cost1617 = 0.
EXECUTE.



* Convert gender to a string.
String GenderSTR (A6).
if gender = 1 GenderSTR = "Male".
if gender = 2 GenderSTR = "Female".
if gender = 0 GenderSTR = "Both".
exe.

save outfile  = !OFilesL + 'temp_HRI_LAT1.sav'.

* Need to create a PathwayID for each level within the data.
* Individual - Lowest level.
get file  = !OFilesL + 'temp_HRI_LAT1.sav'.

select if  GenderSTR NE "Both".
select if AgeBand NE "All".
EXECUTE.


string PathwayLKP (A100).
compute PathwayLKP = concat(rtrim(HRI_Group1314), rtrim(HRI_Group1415), rtrim(HRI_Group1516), rtrim(HRI_Group1617)).
execute. 

save outfile  = !OFilesL + 'temp_HRI_LAT2.sav'.

* Agg Age.
get file  = !OFilesL + 'temp_HRI_LAT1.sav'.

select if AgeBand = "All".
select if  GenderSTR NE "Both".
EXECUTE.

string PathwayLKP (A100).

compute PathwayLKP = concat(rtrim(HRI_Group1314), rtrim(HRI_Group1415), rtrim(HRI_Group1516), rtrim(HRI_Group1617)).
execute. 

save outfile  = !OFilesL + 'temp_HRI_LAT3.sav'.

* Agg Gender.
get file  = !OFilesL + 'temp_HRI_LAT1.sav'.

select if GenderSTR = "Both".
select if AgeBand NE "All".
EXECUTE.

string PathwayLKP (A100).
compute PathwayLKP = concat(rtrim(HRI_Group1314), rtrim(HRI_Group1415), rtrim(HRI_Group1516), rtrim(HRI_Group1617)).
execute. 

save outfile  = !OFilesL + 'temp_HRI_LAT4.sav'.

* Agg Age & Gender.
get file  = !OFilesL + 'temp_HRI_LAT1.sav'.

select if  GenderSTR = "Both".
select if AgeBand = "All".
EXECUTE.

string PathwayLKP (A100).

compute PathwayLKP = concat(rtrim(HRI_Group1314), rtrim(HRI_Group1415), rtrim(HRI_Group1516), rtrim(HRI_Group1617)).
execute. 

save outfile  = !OFilesL + 'temp_HRI_LAT5.sav'.

*bring files togther.
add files file = !OFilesL + 'temp_HRI_LAT2.sav'
/file = !OFilesL + 'temp_HRI_LAT3.sav'
/file = !OFilesL + 'temp_HRI_LAT4.sav'
/file = !OFilesL + 'temp_HRI_LAT5.sav'.
EXECUTE.

*Remove all spaces from PathwayLKP.
COMPUTE PathwayLKP = REPLACE(PathwayLKP, " ", "").
EXECUTE.

* Each individuals pathway should be recorded 6 times, if valid. There are issues with mapping CHI over years therefore mismatches which need to be removed.
string PathwayXCheck (A100).
Compute PathwayXCheck = CONCAT(CHI, PathwayLKP).
exe.

sort cases by PathwayXCheck.

compute check = 1.
if (lag(PathwayXCheck)=PathwayXCheck) check=lag(check)+1. 
exe.

AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=PathwayXCheck
  /check_max=MAX(check).

compute Remove = 0.
if check_max < 4 Remove = 1.
exe.

* Modify PathwayLKP to include LA details.
*compute PathwayLKP = concat(STRING ('Scotland',F8),PathwayLKP).
*EXECUTE.
*Remove all spaces from PathwayLKP.
COMPUTE PathwayLKP = REPLACE(PathwayLKP, " ", "").
EXECUTE.
* Create a Pathway Label for use in Tableau.
string PathwayLabel (A100).

compute PathwayLabel = concat(HRI_Group1516, ' - ', HRI_Group1314, ' - ', HRI_Group1415, ' - ', HRI_Group1617).
execute. 

* Need to save out Pathway lookup to match on the original CHIMASTER level data.
save outfile  = !OFilesL + 'temp_HRI_LA_ALLYR_CHI1.sav'
/keep chi PathwayLKP PathwayLabel HRI_Group1617 HRI_Group1314 HRI_Group1415 HRI_Group1516 remove.

* Remove mis-match records.
select if Remove NE 1.
exe.

AGGREGATE
  /OUTFILE=*
  /BREAK=genderSTR AgeBand HRI_Group1617 HRI_Group1314 HRI_Group1415 HRI_Group1516 PathwayLKP PathwayLabel
  /health_net_cost1617=SUM(health_net_cost1617) 
  /health_net_cost1314=SUM(health_net_cost1314)
  /health_net_cost1415=SUM(health_net_cost1415) 
  /health_net_cost1516=SUM(health_net_cost1516) 
  /health_net_cost1617_min=MIN(health_net_cost1617_min) 
  /health_net_cost1617_max=MAX(health_net_cost1617_max)
  /health_net_cost1314_min=MIN(health_net_cost1314_min) 
  /health_net_cost1314_max=MAX(health_net_cost1314_max)
  /health_net_cost1415_min=MIN(health_net_cost1415_min) 
  /health_net_cost1415_max=MAX(health_net_cost1415_max)
  /health_net_cost1516_min=MIN(health_net_cost1516_min) 
  /health_net_cost1516_max=MAX(health_net_cost1516_max)
  /Size=N.

save outfile  = !OFilesL + 'temp_HRI_LA_ALLYR1.sav'.


***********************************************************************************.
get file = !OFilesL + 'temp_HRI_LA_ALLYR1.sav'.



string Link (A4).
Compute Link = "link".
alter type AgeBand (a8).
if AgeBand = "All" AgeBand = "All ages".
exe.

add files file = *
/file=  '/conf/irf/09-Tableau-Outputs/01-Development/04-Source-Data/03-HRI/Sankey_Link_dataset_Dummy.sav'.


string Data (A25).
compute Data = "Sankey".
EXECUTE.

Select if PathwayLabel NE "Remove".
EXECUTE.

SAVE OUTFILE= !OFilesL + 'Sankey_Link_dataset_FINAL_SCOT.sav'
/drop PathwayLabel 
  /COMPRESSED.

get FILE= !OFilesL + 'Sankey_Link_dataset_FINAL_SCOT.sav'.

************************************************************************************************************************************************************************************.


get FILE=  !OFilesL + 'Sankey_Link_dataset_FINAL_SCOT.sav'.



*add LA Name.
string LCAname (a25).
Compute LCAname = 'Scotland'.

String LA_CODE (a9).
compute LA_CODE = 'M'.


SAVE OUTFILE=  !OFilesL+ 'Sankey_Link_dataset_FINAL_SCOT.sav'
  /COMPRESSED.


get file =  !OFilesL+ 'Sankey_Link_dataset_FINAL_SCOT.sav'.


**compute Link = link.
*compute Data = 'Sankey'.
*compute LCAname = 'Please Select Partnership'.
*compute LA_CODE = 'DummyPAR0'.

*aggregate outfile = *
/break  Link Data LCAname LA_CODE
/number = n.

*add files file =*
/file = !OFilesL+ 'Sankey_Link_dataset_FINAL_SCOT.sav'.
exe.

*SAVE OUTFILE='/conf/linkage/output/euanpa01/Sankey_Link_dataset_FINAL.sav'
/drop alzheimers number
/COMPRESSED.

*get file = '/conf/linkage/output/euanpa01/Sankey_Link_dataset_FINAL.sav'.

save outfile =  !OFilesL+ 'Sankey_Link_dataset_FINAL_SCOT.sav'
/compressed.

get file =   !OFilesL+ 'Sankey_Link_dataset_FINAL_SCOT.sav'.

*produce blank columns to match with Summary dataset.
compute Acute_Ind = 0.
compute AE_Ind = 0.
compute GLS_Ind = 0.
compute Mat_Ind = 0.
compute MH_Ind = 0.
compute No_LTC = 0.
compute OUT_Ind = 0.
compute PIS_Ind = 0.


****Save final Sankey dataset.
save outfile =   !OFilesL+ 'Sankey_Link_dataset_FINAL_SCOT.sav'
drop hri_group1011 hri_group1112
/compressed.

get file =  !OFilesL+ 'Sankey_Link_dataset_FINAL_SCOT.sav'.
