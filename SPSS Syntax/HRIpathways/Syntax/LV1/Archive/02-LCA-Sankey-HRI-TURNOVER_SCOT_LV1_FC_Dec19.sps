* Encoding: UTF-8.
******************************************************************************************************************************************************************************
*******************************Syntax to produce Scotland level data for Sankey chart for Dashboard 2 of HRI Pathways workbook***********************************.
***********************************************BEWARE - Long running time - Please ensure large file space before running**********************************.



*define !CostedFiles()
'/conf/irf/10-PLICS-analysis-files/masterPLICS_Costed_201617.sav'
!enddefine.

*define !CHICostedFiles()
'/conf/irf/10-PLICS-analysis-files/CHImasterPLICS_Costed_201617.sav'
!enddefine.

* File save location.
define !OFilesL()
           '/conf/sourcedev/TableauUpdates/HRIpathways/Outputs/LV1/'
!Enddefine.


*Define !HRIfile255075()
     '/conf/linkage/output/keirro/01-HRI-1617-255075.sav'
!Enddefine.
******************************************************************
*add notes.
*************************************************************************************************************************************************.
*** Start with latest year.

*************************************************************************************************************************************************.
*** Next year.
*Macro 1.
Define !year()
'201718'
!Enddefine.

get file = '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.zsav'.
select if gender ne 0.
select if hri_scot ne 9.

*Oct 2019 FC. 
*Non-Service Users must be excluded by the calculations (only for health activities from 2015/16 onwards)
 Otherwise, these users will be counted in the 'Low Users' category.
select if NSU ne 1.
execute.

*rename variables health_postcode =pc7. 
alter type postcode (A21).
*Execute.
*Create a Scottish flag for the people we know are definitely Scottish as they have a Scottish postcode. 
*Sort cases by pc7.
*match files file =*
/Table = '/conf/linkage/output/alisom18/New_Scot_Post_LKP1.sav'
/by PC7.
*execute. 


*delete variables PC_District.
String PCDistrict (A12).
Compute PCDistrict = char.substr(postcode,1,4).
exe. 


sort cases by pcDistrict.
match files file = *
/table = '/conf/sourcedev/TableauUpdates/HRIpathways/ScotLookup.sav'
/by PCDistrict.
exe.

*June 2019  FC.
*Reformat 'gpprac' back from numeric to string.
String gpprac_str(A5).
compute gpprac_str = string(gpprac,F5.0).
exe.

*Flag people as Scottish if they have a blank postcode and blank gpprac - we assume that these people are Scottish. 
If postcode = "" and gpprac_str= "" ScotFlag = 1.
exe. 

*FC June 2019 Update.
*Finally, we exclude people who have a blank postcode and an English GPprac. 
*If a GP practice is English will be recorded as '99995' (Oct. 2018 Source Linkage Update). 

String Eng_Flag (A1).
If gpprac_str='99995' Eng_Flag='1'.
If (postcode = "" and Eng_Flag ne '1') scotflag=1.
If (postcode='null' and Eng_Flag ne '1') scotflag = 1.
exe. 


*There are some Glasgow postcodes which have not been recognised as Scottish so have to include these. 
String Glasgow_Flag (A2).
Compute Glasgow_Flag = char.substr(postcode,1,2).
exe.

If Any(Glasgow_Flag, 'G0', 'G1', 'G2', 'G3', 'G4', 'G5', 'G6', 'G7', 'G8', 'G9' ) Scotflag = 1.
*There are still a lot of Scottish people so use the Glasgow flag to identify the following.
If Any(Glasgow_Flag, 'DD', 'EH', 'IV', 'AB', 'KA', 'FK', 'HS', 'KW', 'KY', 'ML', 'PA', 'PH','ZE') Scotflag = 1.
*execute. 

recode scotflag (sysmis=0).

*sort cases by postcode.
*match files file =*
/Table = '/conf/linkage/output/alisom18/New_Scot_Post_LKP2.sav'
/by PC7.
*execute. 
*if scot_flag_1 = 1 scotflag = 1.
*execute. 

*frequencies variables = scotflag.


*frequencies variables = pc_District.
*rename variables PC_District = PCDistrict.
*alter type PCDistrict (A18). 
*match files file =*
/Table = !clout + 'Postcode_district_from_standard_ref.sav'
/by PCDistrict.
*execute. 
*if scot_flag_1 = 1 scotflag = 1.
*execute. 

*FREQUENCIES VARIABLES=ScotFlag
  /ORDER=ANALYSIS.

*2010/11 5095 excluded.
*2011/12 5039 excluded. 
*2012/13 6265 excluded. 
*2013/14 8266 excluded. 

*Way of checking Non-Scottish people you are about to exclude.
String NonScot (A7).
Compute NonScot = ''.
If Scotflag ne 1 NonScot = postcode.
FREQUENCIES VARIABLES=NonScot
  /ORDER=ANALYSIS.


*Select if Scot_Flag = 1.
*execute. 

Delete variables Glasgow_Flag Eng_Flag.
 

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
execute.



*FC Dec 19 - Create Numeric 'date of birth'.
Compute dob_num = xdate.mday(dob) + 100*xdate.month(dob) + 10000*xdate.year(dob).
exe.

*Adjust age (Numeric format) to base year of latest year.
alter type dob_num (F8.0).
compute age_num= trunc((20170930-dob_num)/10000).
alter type age_num (F3.0).
exe.


* Create required agebands.
string AgeBand (a5).
If (Age_num lt 18) AgeBand = '<18'.
If (Age_num ge 18 and Age_num le 44) AgeBand = '18-44'.
If (Age_num ge 45 and Age_num le 64) AgeBand = '45-64'.
If (Age_num ge 65 and Age_num le 74) AgeBand = '65-74'.
If (Age_num ge 75 and Age_num le 84) AgeBand = '75-84'.
If (Age_num ge 85) AgeBand = '85+'.
Execute. 


rename variables Anon_CHI = chi. 

* Remove any individuals not within a LA.
*select if lca NE ' '.
*EXE.

compute lca = 'Scotland'.
rename variables (lca HRI_Group health_net_cost = lca1718 HRI_Group1718 health_net_cost1718).

sort cases by chi.


AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=AgeBand gender HRI_Group1718 lca1718
  /health_net_cost1718_min=MIN(health_net_cost1718) 
  /health_net_cost1718_max=MAX(health_net_cost1718).

save outfile  = !OFilesL + 'temp_HRI_LA_1718_T1.zsav'
  /keep year CHI gender health_net_cost1718 lca1718 DataZone2011 AgeBand LCA1718 HRI_Group1718 health_net_cost1718_min health_net_cost1718_max deceased death_date
  /zcompressed.

*All ages.
get file  = !OFilesL + 'temp_HRI_LA_1718_T1.zsav'
/keep year CHI gender health_net_cost1718 lca1718 DataZone2011 AgeBand LCA1718 HRI_Group1718 deceased death_date.

compute AgeBand = 'All'.
exe.

AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=AgeBand gender HRI_Group1718 lca1718
  /health_net_cost1718_min=MIN(health_net_cost1718) 
  /health_net_cost1718_max=MAX(health_net_cost1718).

save outfile  = !OFilesL + 'temp_HRI_LA_1718_T2.zsav'
  /keep year CHI gender health_net_cost1718 lca1718 DataZone2011 AgeBand LCA1718 HRI_Group1718 health_net_cost1718_min health_net_cost1718_max deceased death_date
  /zcompressed. 

* By Gender.
get file  = !OFilesL + 'temp_HRI_LA_1718_T1.zsav'
/keep year CHI gender health_net_cost1718 lca1718 DataZone2011 AgeBand LCA1718 HRI_Group1718 deceased death_date.

compute gender = 0.
exe.

AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=AgeBand gender HRI_Group1718 lca1718
  /health_net_cost1718_min=MIN(health_net_cost1718) 
  /health_net_cost1718_max=MAX(health_net_cost1718).

save outfile  = !OFilesL + 'temp_HRI_LA_1718_T3.zsav'
   /keep year CHI gender health_net_cost1718 lca1718 DataZone2011 AgeBand LCA1718 HRI_Group1718 health_net_cost1718_min health_net_cost1718_max deceased death_date
   /zcompressed.

*Both Age and gender.
get file  = !OFilesL + 'temp_HRI_LA_1718_T1.zsav'
  /keep year CHI gender health_net_cost1718 lca1718 DataZone2011 AgeBand LCA1718 HRI_Group1718 deceased death_date.

compute AgeBand = 'All'.
compute gender = 0.
exe.

AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=AgeBand gender HRI_Group1718 lca1718
  /health_net_cost1718_min=MIN(health_net_cost1718) 
  /health_net_cost1718_max=MAX(health_net_cost1718).

save outfile  = !OFilesL + 'temp_HRI_LA_1718_T4.zsav'
  /keep year CHI gender health_net_cost1718 lca1718 DataZone2011 AgeBand LCA1718 HRI_Group1718 health_net_cost1718_min health_net_cost1718_max deceased death_date
  /zcompressed.

add files file = !OFilesL + 'temp_HRI_LA_1718_T1.zsav'
/file = !OFilesL + 'temp_HRI_LA_1718_T2.zsav'
/file = !OFilesL + 'temp_HRI_LA_1718_T3.zsav'
/file = !OFilesL + 'temp_HRI_LA_1718_T4.zsav'.
execute.


*FC Nov 19 - Create Numeric 'date_death' consistently with the rest of the sysntax.
Compute date_death = xdate.mday(death_date) + 100*xdate.month(death_date) + 10000*xdate.year(death_date).
exe.


sort cases by chi AgeBand gender.

save outfile  = !OFilesL + 'temp_HRI_LA_1718.zsav'.

* Tidy up.
*ERASE file  = !OFilesL + 'temp_HRI_LA_1718_T1.sav'.
*ERASE file  = !OFilesL + 'temp_HRI_LA_1718_T2.sav'.
*ERASE file  = !OFilesL + 'temp_HRI_LA_1718_T3.sav'.
*ERASE file  = !OFilesL + 'temp_HRI_LA_1718_T4.sav'.


****************************************************************************************************************


*Macro 1.
Define !year()
'201617'
!Enddefine.


get file = '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.sav'.
select if gender ne 0.
select if hri_scot ne 9.

*June 2019 FC. 
*Non-Service Users must be excluded by the calculations (only for health activities from 2015/16 onwards)
 Otherwise, these users will be counted in the 'Low Users' category.
select if NSU ne 1.
execute.

*rename variables health_postcode =pc7. 
alter type postcode (A21).
*Execute.
*Create a Scottish flag for the people we know are definitely Scottish as they have a Scottish postcode. 
*Sort cases by pc7.
*match files file =*
/Table = '/conf/linkage/output/alisom18/New_Scot_Post_LKP1.sav'
/by PC7.
*execute. 


*delete variables PC_District.
String PCDistrict (A12).
Compute PCDistrict = char.substr(postcode,1,4).
exe. 


sort cases by pcDistrict.
match files file = *
/table = '/conf/sourcedev/TableauUpdates/HRIpathways/ScotLookup.sav'
/by PCDistrict.
exe.

*June 2019  FC
*Reformat 'gpprac' back from numeric to string.
String gpprac_str(A5).
compute gpprac_str = string(gpprac,F5.0).
exe.

*Flag people as Scottish if they have a blank postcode and blank gpprac - we assume that these people are Scottish. 
If postcode = "" and gpprac_str= "" ScotFlag = 1.
exe. 

*June 2019 FC
*Finally, we exclude people who have a blank postcode and an English GPprac.
*If a GP practice is English will be recorded as '99995' (Oct. 2018 Source Linkage Update). 

String Eng_Flag (A1).
If gpprac_str='99995' Eng_Flag='1'.
If (postcode = "" and Eng_Flag ne '1') scotflag=1.
If (postcode='null' and Eng_Flag ne '1') scotflag = 1.
exe. 


*There are some Glasgow postcodes which have not been recognised as Scottish so have to include these. 
String Glasgow_Flag (A2).
Compute Glasgow_Flag = char.substr(postcode,1,2).
exe.

If Any(Glasgow_Flag, 'G0', 'G1', 'G2', 'G3', 'G4', 'G5', 'G6', 'G7', 'G8', 'G9' ) Scotflag = 1.
*There are still a lot of Scottish people so use the Glasgow flag to identify the following.
If Any(Glasgow_Flag, 'DD', 'EH', 'IV', 'AB', 'KA', 'FK', 'HS', 'KW', 'KY', 'ML', 'PA', 'PH','ZE') Scotflag = 1.
*execute. 

recode scotflag (sysmis=0).

*sort cases by pc7.
*match files file =*
/Table = '/conf/linkage/output/alisom18/New_Scot_Post_LKP2.sav'
/by PC7.
*execute. 
*if scot_flag_1 = 1 scotflag = 1.
*execute. 

*frequencies variables = scotflag.


*frequencies variables = pc_District.
*rename variables PC_District = PCDistrict.
*alter type PCDistrict (A18). 
*match files file =*
/Table = !clout + 'Postcode_district_from_standard_ref.sav'
/by PCDistrict.
*execute. 
*if scot_flag_1 = 1 scotflag = 1.
*execute. 

*FREQUENCIES VARIABLES=ScotFlag
  /ORDER=ANALYSIS.

*2010/11 5095 excluded.
*2011/12 5039 excluded. 
*2012/13 6265 excluded. 
*2013/14 8266 excluded. 

*Way of checking Non-Scottish people you are about to exclude.
String NonScot (A7).
Compute NonScot = ''.
If Scotflag ne 1 NonScot = postcode.

*FREQUENCIES VARIABLES=NonScot
  /ORDER=ANALYSIS.


*Select if Scot_Flag = 1.
*execute. 

Delete variables  Glasgow_Flag Eng_Flag .
 

select if scotflag = 1.
exe. 
Delete variables Scotflag.

String HRI_Group (A30).

* Create HRI grouping.
if (HRI_scotP lt 50) HRI_Group = 'High'.
if (HRI_scotP ge 50 and HRI_scotP lt 65) HRI_Group = 'High to Medium'.
if (HRI_scotP ge 65 and HRI_scotP lt 80) HRI_Group = 'Medium'.
if (HRI_scotP ge 80 and HRI_scotP lt 95) HRI_Group = 'Medium to Low'.
if (HRI_scotP ge 95) HRI_Group = 'Low'.
execute.


*FC Dec 19 - Create Numeric 'date of birth'.
Compute dob_num = xdate.mday(dob) + 100*xdate.month(dob) + 10000*xdate.year(dob).
exe.

*Adjust age (Numeric format) to base year of latest year.
alter type dob_num (F8.0).
compute age_num= trunc((20160930-dob_num)/10000).
alter type age_num (F3.0).
compute age_num = age_num + 1.
exe.



* Create required agebands.
string AgeBand (a5).
If (Age_num lt 18) AgeBand = '<18'.
If (Age_num ge 18 and Age_num le 44) AgeBand = '18-44'.
If (Age_num ge 45 and Age_num le 64) AgeBand = '45-64'.
If (Age_num ge 65 and Age_num le 74) AgeBand = '65-74'.
If (Age_num ge 75 and Age_num le 84) AgeBand = '75-84'.
If (Age_num ge 85) AgeBand = '85+'.
Execute. 

rename variables Anon_CHI = chi. 

* Remove any individuals not within a LA.
*select if lca NE ' '.
*EXECUTE.

compute lca = 'Scotland'.
rename variables (lca HRI_Group health_net_cost = lca1617 HRI_Group1617 health_net_cost1617).

sort cases by chi.


AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=AgeBand gender HRI_Group1617 lca1617
  /health_net_cost1617_min=MIN(health_net_cost1617) 
  /health_net_cost1617_max=MAX(health_net_cost1617).

save outfile  = !OFilesL + 'temp_HRI_LA_1617_T1.zsav'
  /keep year CHI gender health_net_cost1617 lca1617 DataZone2011 AgeBand LCA1617 HRI_Group1617 health_net_cost1617_min health_net_cost1617_max deceased death_date
  /zcompressed.

*All ages.
get file  = !OFilesL + 'temp_HRI_LA_1617_T1.zsav'
  /keep year CHI gender health_net_cost1617 lca1617 DataZone2011 AgeBand LCA1617 HRI_Group1617 deceased death_date.

compute AgeBand = 'All'.
exe.

AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=AgeBand gender HRI_Group1617 lca1617
  /health_net_cost1617_min=MIN(health_net_cost1617) 
  /health_net_cost1617_max=MAX(health_net_cost1617).

save outfile  = !OFilesL + 'temp_HRI_LA_1617_T2.zsav'
   /keep year CHI gender health_net_cost1617 lca1617 DataZone2011 AgeBand LCA1617 HRI_Group1617 health_net_cost1617_min health_net_cost1617_max deceased death_date
  /zcompressed.

* By Gender.
get file  = !OFilesL + 'temp_HRI_LA_1617_T1.zsav'
/keep year CHI gender health_net_cost1617 lca1617 DataZone2011 AgeBand LCA1617 HRI_Group1617 deceased death_date.

compute gender = 0.
exe.

AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=AgeBand gender HRI_Group1617 lca1617
  /health_net_cost1617_min=MIN(health_net_cost1617) 
  /health_net_cost1617_max=MAX(health_net_cost1617).

save outfile  = !OFilesL + 'temp_HRI_LA_1617_T3.zsav'
  /keep year CHI gender health_net_cost1617 lca1617 DataZone2011 AgeBand LCA1617 HRI_Group1617 health_net_cost1617_min health_net_cost1617_max deceased death_date
  /zcompressed.

*Both Age and gender.
get file  = !OFilesL + 'temp_HRI_LA_1617_T1.zsav'
/keep year CHI gender health_net_cost1617 lca1617 DataZone2011 AgeBand LCA1617 HRI_Group1617 deceased death_date.

compute AgeBand = 'All'.
compute gender = 0.
exe.

AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=AgeBand gender HRI_Group1617 lca1617
  /health_net_cost1617_min=MIN(health_net_cost1617) 
  /health_net_cost1617_max=MAX(health_net_cost1617).

save outfile  = !OFilesL + 'temp_HRI_LA_1617_T4.zsav'
  /keep year CHI gender health_net_cost1617 lca1617 DataZone2011 AgeBand LCA1617 HRI_Group1617 health_net_cost1617_min health_net_cost1617_max deceased death_date
  /zcompressed.

add files file = !OFilesL + 'temp_HRI_LA_1617_T1.zsav'
/file = !OFilesL + 'temp_HRI_LA_1617_T2.zsav'
/file = !OFilesL + 'temp_HRI_LA_1617_T3.zsav'
/file = !OFilesL + 'temp_HRI_LA_1617_T4.zsav'.
execute.



*FC Nov 19 - Create Numeric 'date_death' consistently with the rest of the sysntax.
Compute date_death = xdate.mday(death_date) + 100*xdate.month(death_date) + 10000*xdate.year(death_date).
exe.

sort cases by chi AgeBand gender.

save outfile  = !OFilesL + 'temp_HRI_LA_1617.zsav'
  /zcompressed.

* Tidy up.
*ERASE file  = !OFilesL + 'temp_HRI_LA_1617_T1.sav'.
*ERASE file  = !OFilesL + 'temp_HRI_LA_1617_T2.sav'.
*ERASE file  = !OFilesL + 'temp_HRI_LA_1617_T3.sav'.
*ERASE file  = !OFilesL + 'temp_HRI_LA_1617_T4.sav'.


************************************************.


*************************************************************************************************************************************************.
*** Next year.
**Macro 1.
Define !year()
'201516'
!Enddefine.

get file = '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.zsav'.
select if gender ne 0.
select if hri_scot ne 9.

*FC June 2019. 
*Non-Service Users must be excluded by the calculations (only for health activities from 2015/16 onwards)
 Otherwise, these users will be counted in the 'Low Users' category.
select if NSU ne 1.
execute.

*rename variables health_postcode =pc7. 
alter type postcode (A21).
*Execute.
*Create a Scottish flag for the people we know are definitely Scottish as they have a Scottish postcode. 
*Sort cases by pc7.
*match files file =*
/Table = '/conf/linkage/output/alisom18/New_Scot_Post_LKP1.sav'
/by PC7.
*execute. 


*delete variables PC_District.
String PCDistrict (A12).
Compute PCDistrict = char.substr(postcode,1,4).
exe. 


sort cases by pcDistrict.
match files file = *
/table = '/conf/sourcedev/TableauUpdates/HRIpathways/ScotLookup.sav'
/by PCDistrict.
exe.

*FC June 2019.
*Reformat 'gpprac' back from numeric to string.
String gpprac_str(A5).
compute gpprac_str = char.string(gpprac,F5.0).
exe.

*Flag people as Scottish if they have a blank postcode and blank gpprac - we assume that these people are Scottish. 
If postcode = "" and gpprac_str= "" ScotFlag = 1.
*execute. 

*FC June 2019 Update.
*Finally, we exclude people who have a blank postcode and an English GPprac. 
*If a GP practice is English will be recorded as '99995' (Oct. 2018 Source Linkage Update). 

String Eng_Flag (A1).
If gpprac_str='99995' Eng_Flag='1'.
If (postcode = "" and Eng_Flag ne '1') scotflag=1.
If (postcode='null' and Eng_Flag ne '1') scotflag = 1.
exe. 


*There are some Glasgow postcodes which have not been recognised as Scottish so have to include these. 
String Glasgow_Flag (A2).
Compute Glasgow_Flag = char.substr(postcode,1,2).
exe.

If Any(Glasgow_Flag, 'G0', 'G1', 'G2', 'G3', 'G4', 'G5', 'G6', 'G7', 'G8', 'G9' ) Scotflag = 1.
*There are still a lot of Scottish people so use the Glasgow flag to identify the following.
If Any(Glasgow_Flag, 'DD', 'EH', 'IV', 'AB', 'KA', 'FK', 'HS', 'KW', 'KY', 'ML', 'PA', 'PH','ZE') Scotflag = 1.
*execute. 

recode scotflag (sysmis=0).

*sort cases by pc7.
*match files file =*
/Table = '/conf/linkage/output/alisom18/New_Scot_Post_LKP2.sav'
/by PC7.
*execute. 
*if scot_flag_1 = 1 scotflag = 1.
*execute. 

*frequencies variables = scotflag.


*frequencies variables = pc_District.
*rename variables PC_District = PCDistrict.
*alter type PCDistrict (A18). 
*match files file =*
/Table = !clout + 'Postcode_district_from_standard_ref.sav'
/by PCDistrict.
*execute. 
*if scot_flag_1 = 1 scotflag = 1.
*execute. 

*FREQUENCIES VARIABLES=ScotFlag
  /ORDER=ANALYSIS.

*2010/11 5095 excluded.
*2011/12 5039 excluded. 
*2012/13 6265 excluded. 
*2013/14 8266 excluded. 

*Way of checking Non-Scottish people you are about to exclude.
String NonScot (A7).
Compute NonScot = ''.
If Scotflag ne 1 NonScot = postcode.
FREQUENCIES VARIABLES=NonScot
  /ORDER=ANALYSIS.


*Select if Scot_Flag = 1.
*execute. 

Delete variables Glasgow_Flag Eng_Flag.
 

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
execute.


*FC Dec 19 - Create Numeric 'date of birth'.
Compute dob_num = xdate.mday(dob) + 100*xdate.month(dob) + 10000*xdate.year(dob).
exe.

*Adjust age (Numeric format) to base year of latest year.
alter type dob_num (F8.0).
compute age_num= trunc((20150930-dob_num)/10000).
alter type age_num (F3.0).
compute age_num = age_num + 2.
exe.

* Create required agebands.
string AgeBand (a5).
If (Age_num lt 18) AgeBand = '<18'.
If (Age_num ge 18 and Age_num le 44) AgeBand = '18-44'.
If (Age_num ge 45 and Age_num le 64) AgeBand = '45-64'.
If (Age_num ge 65 and Age_num le 74) AgeBand = '65-74'.
If (Age_num ge 75 and Age_num le 84) AgeBand = '75-84'.
If (Age_num ge 85) AgeBand = '85+'.
Execute. 

rename variables Anon_CHI = chi. 

* Remove any individuals not within a LA.
*select if lca NE ' '.
*EXECUTE.

compute lca = 'Scotland'.
rename variables (lca HRI_Group health_net_cost = lca1516 HRI_Group1516 health_net_cost1516).

sort cases by chi.


AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=AgeBand gender HRI_Group1516 lca1516
  /health_net_cost1516_min=MIN(health_net_cost1516) 
  /health_net_cost1516_max=MAX(health_net_cost1516).

save outfile  = !OFilesL + 'temp_HRI_LA_1516_T1.zsav'
  /keep year CHI gender health_net_cost1516 lca1516 DataZone2011 AgeBand LCA1516 HRI_Group1516 health_net_cost1516_min health_net_cost1516_max deceased death_date
  /zcompressed.

*All ages.
get file  = !OFilesL + 'temp_HRI_LA_1516_T1.zsav'
/keep year CHI gender health_net_cost1516 lca1516 DataZone2011 AgeBand LCA1516 HRI_Group1516 deceased death_date.

compute AgeBand = 'All'.
exe.

AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=AgeBand gender HRI_Group1516 lca1516
  /health_net_cost1516_min=MIN(health_net_cost1516) 
  /health_net_cost1516_max=MAX(health_net_cost1516).

save outfile  = !OFilesL + 'temp_HRI_LA_1516_T2.zsav'
  /keep year CHI gender health_net_cost1516 lca1516 DataZone2011 AgeBand LCA1516 HRI_Group1516 health_net_cost1516_min health_net_cost1516_max deceased death_date
  /zcompressed.

* By Gender.
get file  = !OFilesL + 'temp_HRI_LA_1516_T1.zsav'
/keep year CHI gender health_net_cost1516 lca1516 DataZone2011 AgeBand LCA1516 HRI_Group1516 deceased death_date.

compute gender = 0.
exe.

AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=AgeBand gender HRI_Group1516 lca1516
  /health_net_cost1516_min=MIN(health_net_cost1516) 
  /health_net_cost1516_max=MAX(health_net_cost1516).

save outfile  = !OFilesL + 'temp_HRI_LA_1516_T3.zsav'
  /keep year CHI gender health_net_cost1516 lca1516 DataZone2011 AgeBand LCA1516 HRI_Group1516 health_net_cost1516_min health_net_cost1516_max deceased death_date
  /zcompressed.

*Both Age and gender.
get file  = !OFilesL + 'temp_HRI_LA_1516_T1.zsav'
/keep year CHI gender health_net_cost1516 lca1516 DataZone2011 AgeBand LCA1516 HRI_Group1516 deceased death_date.

compute AgeBand = 'All'.
compute gender = 0.
execute.

AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=AgeBand gender HRI_Group1516 lca1516
  /health_net_cost1516_min=MIN(health_net_cost1516) 
  /health_net_cost1516_max=MAX(health_net_cost1516).

save outfile  = !OFilesL + 'temp_HRI_LA_1516_T4.zsav'
  /keep year CHI gender health_net_cost1516 lca1516 DataZone2011 AgeBand LCA1516 HRI_Group1516 health_net_cost1516_min health_net_cost1516_max deceased death_date
  /zcompressed.

add files file = !OFilesL + 'temp_HRI_LA_1516_T1.zsav'
/file = !OFilesL + 'temp_HRI_LA_1516_T2.zsav'
/file = !OFilesL + 'temp_HRI_LA_1516_T3.zsav'
/file = !OFilesL + 'temp_HRI_LA_1516_T4.zsav'.
execute.


*FC Nov 19 - Create Numeric 'date_death' consistently with the rest of the sysntax.
Compute date_death = xdate.mday(death_date) + 100*xdate.month(death_date) + 10000*xdate.year(death_date).
exe.


sort cases by chi AgeBand gender.

save outfile  = !OFilesL + 'temp_HRI_LA_1516.zsav'
  /zcompressed.

* Tidy up.
*ERASE file  = !OFilesL + 'temp_HRI_LA_1516_T1.sav'.
*ERASE file  = !OFilesL + 'temp_HRI_LA_1516_T2.sav'.
*ERASE file  = !OFilesL + 'temp_HRI_LA_1516_T3.sav'.
*ERASE file  = !OFilesL + 'temp_HRI_LA_1516_T4.sav'.


***********************************************.

*************************************************************************************************************************************************.
*** Next year.
*Macro 1.
Define !year()
'201415'
!Enddefine.


get file = '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.zsav'.
select if gender ne 0.
select if hri_scot ne 9.
execute.

*rename variables health_postcode =pc7. 
alter type Postcode (A21).
*Execute.
*Create a Scottish flag for the people we know are definitely Scottish as they have a Scottish postcode. 
*Sort cases by pc7.
*match files file =*
/Table = '/conf/linkage/output/alisom18/New_Scot_Post_LKP1.sav'
/by PC7.
*execute. . 


*delete variables PC_District.
String PCDistrict (A12).
Compute PCDistrict = char.substr(Postcode,1,4).
exe. 


sort cases by pcDistrict.
match files file = *
/table = '/conf/sourcedev/TableauUpdates/HRIpathways/ScotLookup.sav'
/by PCDistrict.
exe.

*FC June 2019.
*Reformat 'gpprac' back from numeric to string.
String gpprac_str(A5).
compute gpprac_str = string(gpprac,F5.0).
exe.


*Flag people as Scottish if they have a blank postcode and blank gpprac - we assume that these people are Scottish. 
If postcode = "" and gpprac_str= "" ScotFlag = 1.
exe. 

*FC June 2019 Update.
*Finally, we exclude people who have a blank postcode and an English GPprac. 
*If a GP practice is English will be recorded as '99995' (Oct. 2018 Source Linkage Update). 

String Eng_Flag (A1).
If gpprac_str='99995' Eng_Flag='1'.
If (postcode = "" and Eng_Flag ne '1') scotflag=1.
If (postcode='null' and Eng_Flag ne '1') scotflag = 1.
*exe. 


*There are some Glasgow postcodes which have not been recognised as Scottish so have to include these. 
String Glasgow_Flag (A2).
Compute Glasgow_Flag = char.substr(postcode,1,2).
exe.

If Any(Glasgow_Flag, 'G0', 'G1', 'G2', 'G3', 'G4', 'G5', 'G6', 'G7', 'G8', 'G9' ) Scotflag = 1.
*There are still a lot of Scottish people so use the Glasgow flag to identify the following.
If Any(Glasgow_Flag, 'DD', 'EH', 'IV', 'AB', 'KA', 'FK', 'HS', 'KW', 'KY', 'ML', 'PA', 'PH','ZE') Scotflag = 1.
*execute. 

recode scotflag (sysmis=0).

*sort cases by pc7.
*match files file =*
/Table = '/conf/linkage/output/alisom18/New_Scot_Post_LKP2.sav'
/by PC7.
*execute. 
*if scot_flag_1 = 1 scotflag = 1.
*execute. 

*frequencies variables = scotflag.


*frequencies variables = pc_District.
*rename variables PC_District = PCDistrict.
*alter type PCDistrict (A18). 
*match files file =*
/Table = !clout + 'Postcode_district_from_standard_ref.sav'
/by PCDistrict.
*execute. 
*if scot_flag_1 = 1 scotflag = 1.
*execute. 

*FREQUENCIES VARIABLES=ScotFlag
  /ORDER=ANALYSIS.

*2010/11 5095 excluded.
*2011/12 5039 excluded. 
*2012/13 6265 excluded. 
*2013/14 8266 excluded. 

*Way of checking Non-Scottish people you are about to exclude.
String NonScot (A7).
Compute NonScot = ''.
If Scotflag ne 1 NonScot = postcode.
*FREQUENCIES VARIABLES=NonScot
  /ORDER=ANALYSIS.


*Select if Scot_Flag = 1.
*execute. 

Delete variables Glasgow_Flag Eng_Flag.
 

select if scotflag = 1.
exe. 
Delete variables Scotflag.

String HRI_Group (A30).
* Create HRI grouping.
if (HRI_scotP lt 50) HRI_Group = 'High'.
if (HRI_scotP ge 50 and HRI_scotP lt 65) HRI_Group = 'High to Medium'.
if (HRI_scotP ge 65 and HRI_scotP lt 80) HRI_Group = 'Medium'.
if (HRI_scotP ge 80 and HRI_scotP lt 95) HRI_Group = 'Medium to Low'.
if (HRI_scotP ge 95) HRI_Group = 'Low'.
execute.

*FC Dec 19 - Create Numeric 'date of birth'.
Compute dob_num = xdate.mday(dob) + 100*xdate.month(dob) + 10000*xdate.year(dob).
exe.

*Adjust age (Numeric format) to base year of latest year.
alter type dob_num (F8.0).
compute age_num= trunc((20140930-dob_num)/10000).
alter type age_num (F3.0).
compute age_num = age_num + 3.
exe.


* Create required agebands.
string AgeBand (a5).
If (Age_num lt 18) AgeBand = '<18'.
If (Age_num ge 18 and Age_num le 44) AgeBand = '18-44'.
If (Age_num ge 45 and Age_num le 64) AgeBand = '45-64'.
If (Age_num ge 65 and Age_num le 74) AgeBand = '65-74'.
If (Age_num ge 75 and Age_num le 84) AgeBand = '75-84'.
If (Age_num ge 85) AgeBand = '85+'.
Execute. 


rename variables Anon_CHI = chi. 

* Remove any individuals not within a LA.
*select if lca NE ' '.

compute lca = 'Scotland'.
rename variables (lca HRI_Group health_net_cost = lca1415 HRI_Group1415 health_net_cost1415).

sort cases by chi.


AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=AgeBand gender HRI_Group1415 lca1415
  /health_net_cost1415_min=MIN(health_net_cost1415) 
  /health_net_cost1415_max=MAX(health_net_cost1415).

save outfile  = !OFilesL + 'temp_HRI_LA_1415_T1.zsav'
  /keep year CHI gender health_net_cost1415 lca1415 DataZone2011 AgeBand LCA1415 HRI_Group1415 health_net_cost1415_min health_net_cost1415_max deceased death_date
  /zcompressed.

*All ages.
get file  = !OFilesL + 'temp_HRI_LA_1415_T1.zsav'
/keep year CHI gender health_net_cost1415 lca1415 DataZone2011 AgeBand LCA1415 HRI_Group1415 deceased death_date.

compute AgeBand = 'All'.
exe.

AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=AgeBand gender HRI_Group1415 lca1415
  /health_net_cost1415_min=MIN(health_net_cost1415) 
  /health_net_cost1415_max=MAX(health_net_cost1415).

save outfile  = !OFilesL + 'temp_HRI_LA_1415_T2.zsav'
  /keep year CHI gender health_net_cost1415 lca1415 DataZone2011 AgeBand LCA1415 HRI_Group1415 health_net_cost1415_min health_net_cost1415_max deceased death_date
/zcompressed.

* By Gender.
get file  = !OFilesL + 'temp_HRI_LA_1415_T1.zsav'
/keep year CHI gender health_net_cost1415 lca1415 DataZone2011 AgeBand LCA1415 HRI_Group1415 deceased death_date.

compute gender = 0.
exe.

AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=AgeBand gender HRI_Group1415 lca1415
  /health_net_cost1415_min=MIN(health_net_cost1415) 
  /health_net_cost1415_max=MAX(health_net_cost1415).

save outfile  = !OFilesL + 'temp_HRI_LA_1415_T3.zsav'
  /keep year CHI gender health_net_cost1415 lca1415 DataZone2011 AgeBand LCA1415 HRI_Group1415 health_net_cost1415_min health_net_cost1415_max deceased death_date
  /zcompressed.

*Both Age and gender.
get file  = !OFilesL + 'temp_HRI_LA_1415_T1.zsav'
/keep year CHI gender health_net_cost1415 lca1415 DataZone2011 AgeBand LCA1415 HRI_Group1415 deceased death_date.

compute AgeBand = 'All'.
compute gender = 0.
exe.

AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=AgeBand gender HRI_Group1415 lca1415
  /health_net_cost1415_min=MIN(health_net_cost1415) 
  /health_net_cost1415_max=MAX(health_net_cost1415).

save outfile  = !OFilesL + 'temp_HRI_LA_1415_T4.zsav'
  /keep year CHI gender health_net_cost1415 lca1415 DataZone2011 AgeBand LCA1415 HRI_Group1415 health_net_cost1415_min health_net_cost1415_max deceased death_date
 /zcompressed.

add files file = !OFilesL + 'temp_HRI_LA_1415_T1.zsav'
/file = !OFilesL + 'temp_HRI_LA_1415_T2.zsav'
/file = !OFilesL + 'temp_HRI_LA_1415_T3.zsav'
/file = !OFilesL + 'temp_HRI_LA_1415_T4.zsav'.
execute.


*FC Nov 19 - Create Numeric 'date_death' consistently with the rest of the sysntax.
Compute date_death = xdate.mday(death_date) + 100*xdate.month(death_date) + 10000*xdate.year(death_date).
exe

sort cases by chi AgeBand gender.

save outfile  = !OFilesL + 'temp_HRI_LA_1415.zsav'
  /zcompressed.

* Tidy up.
*ERASE file  = !OFilesL + 'temp_HRI_LA_1415_T1.sav'.
*ERASE file  = !OFilesL + 'temp_HRI_LA_1415_T2.sav'.
*ERASE file  = !OFilesL + 'temp_HRI_LA_1415_T3.sav'.
*ERASE file  = !OFilesL + 'temp_HRI_LA_1415_T4.sav'.
***********************************************.



************************************************************************************.
*Bring all files together.

Get file  = !OFilesL + 'temp_HRI_LA_1718.zsav'.

match files file = *
/file =  !OFilesL + 'temp_HRI_LA_1516.zsav'
/file =  !OFilesL + 'temp_HRI_LA_1415.zsav'
/file =  !OFilesL + 'temp_HRI_LA_1617.zsav'
/by chi AgeBand gender.
exe.

* Convert LA variable to a number.
alter type LCA1718 (F2.0).
alter type LCA1415 (F2.0).
alter type LCA1516 (F2.0).
alter type LCA1617 (F2.0).
alter type death_date (F8).

save outfile  = !OFilesL + 'temp_HRI_LA_MASTER_ALLYR.zsav'
 /zcompressed.

* Tidy up.
*ERASE file  =  !OFilesL + 'temp_HRI_LA_1718.sav'.
*ERASE file  =  !OFilesL + 'temp_HRI_LA_1415.sav'.
*ERASE file  =  !OFilesL + 'temp_HRI_LA_1516.sav'.
*ERASE file  =  !OFilesL + 'temp_HRI_LA_1617.sav'.

** Now need to create individual LA records to track individuals overtime.

get file  = !OFilesL + 'temp_HRI_LA_MASTER_ALLYR.zsav'.


* Add death marker.
if date_death < 20170401 HRI_Group1718 = 'Died'.
if date_death < 20160401 HRI_Group1617 = 'Died'.
if date_death < 20150401 HRI_Group1516 = 'Died'.
if date_death > 20170401 and HRI_Group1718 = ' ' HRI_Group1718 = 'Died'.
exe.

* Assume any blanks are now showing no contact in year.
if HRI_Group1617 = ' ' HRI_Group1617 = 'No Contact'.
if HRI_Group1516 = ' ' HRI_Group1516 = 'No Contact'.
if HRI_Group1415 = ' ' HRI_Group1415 = 'No Contact'.
if HRI_Group1718 = ' ' HRI_Group1718 = 'No Contact'.
exe.


* Remove Costs data for those Died before start of FY.
if HRI_Group1617 = "Died" health_net_cost1617 = 0.
if HRI_Group1516 = "Died" health_net_cost1516 = 0.
if HRI_Group1415 = "Died" health_net_cost1415 = 0.
if HRI_Group1718 = "Died" health_net_cost1718 = 0.
exe.



* Convert gender to a string.
String GenderSTR (A6).
if gender = 1 GenderSTR = "Male".
if gender = 2 GenderSTR = "Female".
if gender = 0 GenderSTR = "Both".
exe.

save outfile  = !OFilesL + 'temp_HRI_LAT1.zsav'
  /zcompressed.

* Need to create a PathwayID for each level within the data.
* Individual - Lowest level.
get file  = !OFilesL + 'temp_HRI_LAT1.zsav'.

select if  GenderSTR NE "Both".
select if AgeBand NE "All".
exe.


string PathwayLKP (A100).
compute PathwayLKP = concat(rtrim(HRI_Group1415), rtrim(HRI_Group1516), rtrim(HRI_Group1617), rtrim(HRI_Group1718)).
exe. 

save outfile  = !OFilesL + 'temp_HRI_LAT2.zsav'
  /zcompressed.

* Agg Age.
get file  = !OFilesL + 'temp_HRI_LAT1.zsav'.

select if AgeBand = "All".
select if  GenderSTR NE "Both".
exe.

string PathwayLKP (A100).

compute PathwayLKP = concat(rtrim(HRI_Group1415), rtrim(HRI_Group1516), rtrim(HRI_Group1617), rtrim(HRI_Group1718)).
exe. 

save outfile  = !OFilesL + 'temp_HRI_LAT3.zsav'
  /zcompressed.

* Agg Gender.
get file  = !OFilesL + 'temp_HRI_LAT1.zsav'.

select if GenderSTR = "Both".
select if AgeBand NE "All".
exe.

string PathwayLKP (A100).
compute PathwayLKP = concat(rtrim(HRI_Group1415), rtrim(HRI_Group1516), rtrim(HRI_Group1617), rtrim(HRI_Group1718)).
exe. 

save outfile  = !OFilesL + 'temp_HRI_LAT4.zsav'
  /zcompressed.

* Agg Age & Gender.
get file  = !OFilesL + 'temp_HRI_LAT1.zsav'.

select if  GenderSTR = "Both".
select if AgeBand = "All".
exe.

string PathwayLKP (A100).

compute PathwayLKP = concat(rtrim(HRI_Group1415), rtrim(HRI_Group1516), rtrim(HRI_Group1617), rtrim(HRI_Group1718)).
exe. 

save outfile  = !OFilesL + 'temp_HRI_LAT5.zsav'
  /zcompressed.

*bring files togther.
add files file = !OFilesL + 'temp_HRI_LAT2.zsav'
/file = !OFilesL + 'temp_HRI_LAT3.zsav'
/file = !OFilesL + 'temp_HRI_LAT4.zsav'
/file = !OFilesL + 'temp_HRI_LAT5.zsav'.
execute.

*Remove all spaces from PathwayLKP.
COMPUTE PathwayLKP = REPLACE(PathwayLKP, " ", "").
EXE.

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
EXE.
* Create a Pathway Label for use in Tableau.
string PathwayLabel (A100).

compute PathwayLabel = concat(HRI_Group1415, ' - ', HRI_Group1516, ' - ', HRI_Group1617, ' - ', HRI_Group1718).
exe. 

* Need to save out Pathway lookup to match on the original CHIMASTER level data.
save outfile  = !OFilesL + 'temp_HRI_LA_ALLYR_CHI1.zsav'
  /keep chi PathwayLKP PathwayLabel HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 remove
  /zcompressed.

* Remove mis-match records.
select if Remove NE 1.
exe.

AGGREGATE
  /OUTFILE=*
  /BREAK=genderSTR AgeBand HRI_Group1718 HRI_Group1415 HRI_Group1516 HRI_Group1617 PathwayLKP PathwayLabel
  /health_net_cost1617=SUM(health_net_cost1617) 
  /health_net_cost1718=SUM(health_net_cost1718)
  /health_net_cost1415=SUM(health_net_cost1415) 
  /health_net_cost1516=SUM(health_net_cost1516) 
  /health_net_cost1617_min=MIN(health_net_cost1617_min) 
  /health_net_cost1617_max=MAX(health_net_cost1617_max)
  /health_net_cost1718_min=MIN(health_net_cost1718_min) 
  /health_net_cost1718_max=MAX(health_net_cost1718_max)
  /health_net_cost1415_min=MIN(health_net_cost1415_min) 
  /health_net_cost1415_max=MAX(health_net_cost1415_max)
  /health_net_cost1516_min=MIN(health_net_cost1516_min) 
  /health_net_cost1516_max=MAX(health_net_cost1516_max)
  /Size=N.

save outfile  = !OFilesL + 'temp_HRI_LA_ALLYR1.zsav'
  /zcompressed.


***********************************************************************************.
get file = !OFilesL + 'temp_HRI_LA_ALLYR1.sav'.



string Link (A4).
Compute Link = "link".
alter type AgeBand (a8).
if AgeBand = "All" AgeBand = "All ages".
exe.

add files file = *
/file=  '/conf/irf/09-Tableau-Outputs/01-Development/04-Source-Data/03-HRI/Sankey_Link_dataset_Dummy2.sav'.


string Data (A25).
compute Data = "Sankey".
exe.

Select if PathwayLabel NE "Remove".
EXE.

SAVE OUTFILE= !OFilesL + 'Sankey_Link_dataset_FINAL_SCOT.zsav'
  /drop PathwayLabel 
  /zcompressed.

*get FILE= !OFilesL + 'Sankey_Link_dataset_FINAL_SCOT.zsav'.

************************************************************************************************************************************************************************************.


get FILE=  !OFilesL + 'Sankey_Link_dataset_FINAL_SCOT.zsav'.



*add LA Name.
string LCAname (a25).
Compute LCAname = 'Scotland'.

String LA_CODE (a9).
compute LA_CODE = 'M'.


SAVE OUTFILE=  !OFilesL+ 'Sankey_Link_dataset_FINAL_SCOT.zsav'
  /zcompressed.


*get file =  !OFilesL+ 'Sankey_Link_dataset_FINAL_SCOT.zsav'.


**compute Link = link.
*compute Data = 'Sankey'.
*compute LCAname = 'Please Select Partnership'.
*compute LA_CODE = 'DummyPAR0'.

*aggregate outfile = *
/break  Link Data LCAname LA_CODE
/number = n.

*add files file =*
/file = !OFilesL+ 'Sankey_Link_dataset_FINAL_SCOT.sav'.
*exe.

*SAVE OUTFILE='/conf/linkage/output/euanpa01/Sankey_Link_dataset_FINAL.sav'
/drop alzheimers number
/COMPRESSED.

*get file = '/conf/linkage/output/euanpa01/Sankey_Link_dataset_FINAL.sav'.

*save outfile =  !OFilesL+ 'Sankey_Link_dataset_FINAL_SCOT.zsav'
z/zcompressed.

get file =   !OFilesL+ 'Sankey_Link_dataset_FINAL_SCOT.zsav'.

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
save outfile =   !OFilesL+ 'Sankey_Link_dataset_FINAL_SCOT.zsav'
/drop hri_group1213
/zcompressed.

*get file =  !OFilesL+ 'Sankey_Link_dataset_FINAL_SCOT.zsav'.

*save outfile = !OFilesL+ 'Sankey_Link_dataset_FINAL_SCOT.sav'.


