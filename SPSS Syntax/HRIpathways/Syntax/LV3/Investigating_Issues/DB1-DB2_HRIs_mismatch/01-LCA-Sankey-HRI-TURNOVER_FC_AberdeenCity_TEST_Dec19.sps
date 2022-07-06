
* Encoding: UTF-8.
**********************************************************************************************************************************************************************
*******************************Syntax to produce data for Sankey chart for Dashboard 2 of HRI Pathways workbook***********************************.
*******************************BEWARE - Running time of 1+ days - Please ensure large file space before running**********************************.

***FC Oct. 2018. Updated variables which have been renamed/reformatted to reflect changes in Source Linkage Files
    Renamed variables: 'death_date' back to 'date_death', pc7 to postcode
    Reformatted variables: dob (from date to numeric), gpprac (from date back to numeric)
    Changed codes:  lca codes for 'Fife' and 'Perth & Kinross'.

* File save location.
define !OFilesL()
       '/conf/sourcedev/TableauUpdates/HRIpathways/Outputs/LV3/Checks/AberdeenCity/'
!Enddefine.



******************************************************************
*************************************************************************************************************************************************.
*** Start with last financial year (2017/2018).

Define !year()
'201718'
!Enddefine.

get file = '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.zsav'.
select if gender ne 0.
select if hri_scot ne 9.


*Select only Aberdeen City Data. 
select if lca='01'.
exe.

*Mar 2019 FC. 
*Non-Service Users must be excluded by the calculations (only for health activities from 2015/16 onwards)
 Otherwise, these users will be counted in the 'Low Users' category.
select if NSU ne 1.
exe.


*rename variables health_postcode =pc7. 
alter type postcode (A21).
*exe.
*Create a Scottish flag for the people we know are definitely Scottish as they have a Scottish postcode. 
*Sort cases by postcode.
*match files file =*
/Table = '/conf/linkage/output/alisom18/New_Scot_Post_LKP1.sav'
/by postcode.
*exe. 


*FC Nov 19 - Create Numeric 'date_death' consistently with the rest of the sysntax.
Compute date_death = xdate.mday(death_date) + 100*xdate.month(death_date) + 10000*xdate.year(death_date).
exe.


*delete variables PC_District.
String PCDistrict (A12).
Compute PCDistrict = char.substr(postcode,1,4).
exe. 



sort cases by pcDistrict.
match files file = *
/table = '/conf/sourcedev/TableauUpdates/HRIpathways/ScotLookup.sav'
/by PCDistrict.
exe.

*Reformat 'gpprac' back from numeric to string.
String gpprac_str(A5).
compute gpprac_str = string(gpprac,F5.0).
exe.

*Flag people as Scottish if they have a blank postcode and blank gpprac - we assume that these people are Scottish. 
If postcode = " " and gpprac_str= " " ScotFlag = 1.
exe. 

*Finally, we exclude people who have a blank postcode and an English GPprac. 
*FC Mar. 2019 Update.
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
exe. 

recode scotflag (sysmis=0).

sort cases by postcode.
*match files file =*
/Table = '/conf/linkage/output/alisom18/New_Scot_Post_LKP2.sav'
/by PC7.
*exe. 
*if scot_flag_1 = 1 scotflag = 1.
*exe. 

frequencies variables = scotflag.


frequencies variables = pcDistrict.
*rename variables PC_District = PCDistrict.
*alter type PCDistrict (A18). 
*match files file =*
/Table = !clout + 'Postcode_district_from_standard_ref.sav'
/by PCDistrict.
*exe. 
*if scot_flag_1 = 1 scotflag = 1.
*exe. 

FREQUENCIES VARIABLES=ScotFlag
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


Delete variables Glasgow_Flag Eng_Flag.
 

select if scotflag = 1.
exe. 
Delete variables Scotflag.

String HRI_Group (A30).
* Create HRI grouping.
if (HRI_lcaP lt 50) HRI_Group = 'High'.
if (HRI_lcaP ge 50 and HRI_lcaP lt 65) HRI_Group = 'High to Medium'.
if (HRI_lcaP ge 65 and HRI_lcaP lt 80) HRI_Group = 'Medium'.
if (HRI_lcaP ge 80 and HRI_lcaP lt 95) HRI_Group = 'Medium to Low'.
if (HRI_lcaP ge 95) HRI_Group = 'Low'.
if lca eq '' HRI_Group eq 'Not in LA'.
exe.

frequencies HRI_Group.

*FC Dec 19 - Create Numeric 'date of birth'.
Compute dob_num = xdate.mday(dob) + 100*xdate.month(dob) + 10000*xdate.year(dob).
exe.

*Adjust age (Numeric format) to base year of latest year.
alter type dob_num (F8.0).
compute age_num= trunc((20170930-dob_num)/10000).
alter type age_num (F3.0).
exe.

frequencies age_num.

* Create required agebands.
string AgeBand (a5).
If (Age_num lt 18) AgeBand = '<18'.
If (Age_num ge 18 and Age_num le 44) AgeBand = '18-44'.
If (Age_num ge 45 and Age_num le 64) AgeBand = '45-64'.
If (Age_num ge 65 and Age_num le 74) AgeBand = '65-74'.
If (Age_num ge 75 and Age_num le 84) AgeBand = '75-84'.
If (Age_num ge 85) AgeBand = '85+'.
exe. 

frequencies ageband.

* Remove any individuals not within a LA.
*select if lca NE ' '.

rename variables (lca HRI_Group health_net_cost = LCA1718 HRI_Group1718 health_net_cost1718).

rename variables Anon_CHI = chi. 

sort cases by chi.


AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=AgeBand gender HRI_Group1718 LCA1718
  /health_net_cost1718_min=MIN(health_net_cost1718) 
  /health_net_cost1718_max=MAX(health_net_cost1718).

save outfile  = !OFilesL + 'temp_HRI_LA_1718_T1.zsav'
/keep year CHI gender health_net_cost1718 LCA1718  AgeBand LCA1718 HRI_Group1718 health_net_cost1718_min health_net_cost1718_max deceased date_death
/zcompressed.

frequencies ageband gender HRI_Group1718.

*All ages.
get file  = !OFilesL + 'temp_HRI_LA_1718_T1.zsav'
/keep year CHI gender health_net_cost1718 LCA1718  AgeBand LCA1718 HRI_Group1718 deceased date_death.

compute AgeBand = 'All'.
exe.

AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=AgeBand gender HRI_Group1718 LCA1718
  /health_net_cost1718_min=MIN(health_net_cost1718) 
  /health_net_cost1718_max=MAX(health_net_cost1718).

save outfile  = !OFilesL + 'temp_HRI_LA_1718_T2.zsav'
/keep year CHI gender health_net_cost1718 LCA1718  AgeBand LCA1718 HRI_Group1718 health_net_cost1718_min health_net_cost1718_max deceased date_death
/zcompressed.

frequencies ageband gender HRI_Group1718.

* By Gender.
get file  = !OFilesL + 'temp_HRI_LA_1718_T1.zsav'
/keep year CHI gender health_net_cost1718 LCA1718  AgeBand LCA1718 HRI_Group1718 deceased date_death.

compute gender = 0.
exe.

AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=AgeBand gender HRI_Group1718 LCA1718
  /health_net_cost1718_min=MIN(health_net_cost1718) 
  /health_net_cost1718_max=MAX(health_net_cost1718).

save outfile  = !OFilesL + 'temp_HRI_LA_1718_T3.zsav'
/keep year CHI gender health_net_cost1718 LCA1718  AgeBand LCA1718 HRI_Group1718 health_net_cost1718_min health_net_cost1718_max deceased date_death
/zcompressed.

frequencies ageband gender HRI_Group1718.

*Both Age and gender.
get file  = !OFilesL + 'temp_HRI_LA_1718_T1.zsav'
/keep year CHI gender health_net_cost1718 LCA1718  AgeBand LCA1718 HRI_Group1718 deceased date_death.

compute AgeBand = 'All'.
compute gender = 0.
exe.

AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=AgeBand gender HRI_Group1718 LCA1718
  /health_net_cost1718_min=MIN(health_net_cost1718) 
  /health_net_cost1718_max=MAX(health_net_cost1718).

save outfile  = !OFilesL + 'temp_HRI_LA_1718_T4.zsav'
/keep year CHI gender health_net_cost1718 LCA1718  AgeBand LCA1718 HRI_Group1718 health_net_cost1718_min health_net_cost1718_max deceased date_death
/zcompressed.

frequencies ageband gender HRI_Group1718.

add files file = !OFilesL + 'temp_HRI_LA_1718_T1.zsav'
/file = !OFilesL + 'temp_HRI_LA_1718_T2.zsav'
/file = !OFilesL + 'temp_HRI_LA_1718_T3.zsav'
/file = !OFilesL + 'temp_HRI_LA_1718_T4.zsav'.
execute.

sort cases by chi AgeBand gender.

save outfile  = !OFilesL + 'temp_HRI_LA_1718.zsav'
/zcompressed.   

frequencies ageband gender HRI_Group1718.

* Tidy up.
ERASE file  = !OFilesL + 'temp_HRI_LA_1718_T1.sav'.
ERASE file  = !OFilesL + 'temp_HRI_LA_1718_T2.sav'.
ERASE file  = !OFilesL + 'temp_HRI_LA_1718_T3.sav'.
ERASE file  = !OFilesL + 'temp_HRI_LA_1718_T4.sav'.


*Fin. Year  2016/2017
*Macro 1.
Define !year()
'201617'
!Enddefine.

get file = '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.zsav'.
select if gender ne 0.
select if hri_scot ne 9.

frequencies gender.

select if lca='01'.
exe.

*Mar. 2019 FC. 
*Non-Service Users must be excluded by the calculations (only for health activities from 2015/16 onwards)
 Otherwise, these users will be counted in the 'Low Users' category.
select if NSU ne 1.
exe.


alter type postcode (A21).
*exe.
*Create a Scottish flag for the people we know are definitely Scottish as they have a Scottish postcode. 
Sort cases by postcode.
*match files file =*
/Table = '/conf/linkage/output/alisom18/New_Scot_Post_LKP1.sav'
/by postcode.
*exe. 


*FC Nov 19 - Create Numeric 'date_death' consistently with the rest of the sysntax.
Compute date_death = xdate.mday(death_date) + 100*xdate.month(death_date) + 10000*xdate.year(death_date).
exe.


*delete variables PC_District.
String PCDistrict (A12).
Compute PCDistrict = char.substr(postcode,1,4).
exe. 


sort cases by pcDistrict.
match files file = *
/table = '/conf/sourcedev/TableauUpdates/HRIpathways/ScotLookup.sav'
/by PCDistrict.
exe.


*Reformat 'gpprac' back from numeric to string.
String gpprac_str(A5).
compute gpprac_str = string(gpprac,F5.0).
exe.

*Flag people as Scottish if they have a blank postcode and blank gpprac - we assume that these people are Scottish. 
If postcode = " " and gpprac_str= " " ScotFlag = 1.
exe. 

*Finally, we exclude people who have a blank postcode and an English GPprac. 
*FC Oct. 2018 Update.
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
exe. 

recode scotflag (sysmis=0).

sort cases by postcode.
*match files file =*
/Table = '/conf/linkage/output/alisom18/New_Scot_Post_LKP2.sav'
/by PC7.
*exe. 
*if scot_flag_1 = 1 scotflag = 1.
*exe. 

frequencies variables = scotflag.


frequencies variables = pcDistrict.
*rename variables PC_District = PCDistrict.
*alter type PCDistrict (A18). 
*match files file =*
/Table = !clout + 'Postcode_district_from_standard_ref.sav'
/by PCDistrict.
*exe. 
*if scot_flag_1 = 1 scotflag = 1.
*exe. 

FREQUENCIES VARIABLES=ScotFlag
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


Delete variables Glasgow_Flag Eng_Flag.
 

select if scotflag = 1.
exe.
 
Delete variables Scotflag.


String HRI_Group (A30).
* Create HRI grouping.
if (HRI_lcaP lt 50) HRI_Group = 'High'.
if (HRI_lcaP ge 50 and HRI_lcaP lt 65) HRI_Group = 'High to Medium'.
if (HRI_lcaP ge 65 and HRI_lcaP lt 80) HRI_Group = 'Medium'.
if (HRI_lcaP ge 80 and HRI_lcaP lt 95) HRI_Group = 'Medium to Low'.
if (HRI_lcaP ge 95) HRI_Group = 'Low'.
if lca eq '' HRI_Group eq 'Not in LA'.
exe.

frequencies HRI_Group.


*FC Dec 19 - Create Numeric 'date of birth'.
Compute dob_num = xdate.mday(dob) + 100*xdate.month(dob) + 10000*xdate.year(dob).
exe.

*Adjust age (Numeric format) to base year of latest year.
alter type dob_num (F8.0).
compute age_num= trunc((20160930-dob_num)/10000).
alter type age_num (F3.0).
compute age_num = age_num + 1.
exe.

frequencies age_num.


* Create required agebands.
string AgeBand (a5).
If (Age_num lt 18) AgeBand = '<18'.
If (Age_num ge 18 and Age_num le 44) AgeBand = '18-44'.
If (Age_num ge 45 and Age_num le 64) AgeBand = '45-64'.
If (Age_num ge 65 and Age_num le 74) AgeBand = '65-74'.
If (Age_num ge 75 and Age_num le 84) AgeBand = '75-84'.
If (Age_num ge 85) AgeBand = '85+'.
exe. 


* Remove any individuals not within a LA.
*select if lca NE ' '.

rename variables (lca HRI_Group health_net_cost = LCA1617 HRI_Group1617 health_net_cost1617).

rename variables Anon_CHI = chi. 

sort cases by chi.


AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=AgeBand gender HRI_Group1617 LCA1617
  /health_net_cost1617_min=MIN(health_net_cost1617) 
  /health_net_cost1617_max=MAX(health_net_cost1617).

save outfile  = !OFilesL + 'temp_HRI_LA_1617_T1.zsav'
/keep year CHI gender health_net_cost1617 LCA1617  AgeBand LCA1617 HRI_Group1617 health_net_cost1617_min health_net_cost1617_max deceased date_death
/zcompressed.

frequencies AgeBand gender HRI_group1617. 

*All ages.
get file  = !OFilesL + 'temp_HRI_LA_1617_T1.zsav'
/keep year CHI gender health_net_cost1617 LCA1617  AgeBand LCA1617 HRI_Group1617 deceased date_death.

compute AgeBand = 'All'.
exe.

AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=AgeBand gender HRI_Group1617 LCA1617
  /health_net_cost1617_min=MIN(health_net_cost1617) 
  /health_net_cost1617_max=MAX(health_net_cost1617).

save outfile  = !OFilesL + 'temp_HRI_LA_1617_T2.zsav'
/keep year CHI gender health_net_cost1617 LCA1617  AgeBand LCA1617 HRI_Group1617 health_net_cost1617_min health_net_cost1617_max deceased date_death
/zcompressed.

frequencies AgeBand gender HRI_group1617. 

* By Gender.
get file  = !OFilesL + 'temp_HRI_LA_1617_T1.zsav'
/keep year CHI gender health_net_cost1617 LCA1617  AgeBand LCA1617 HRI_Group1617 deceased date_death.

compute gender = 0.
exe.

AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=AgeBand gender HRI_Group1617 LCA1617
  /health_net_cost1617_min=MIN(health_net_cost1617) 
  /health_net_cost1617_max=MAX(health_net_cost1617).

save outfile  = !OFilesL + 'temp_HRI_LA_1617_T3.zsav'
/keep year CHI gender health_net_cost1617 LCA1617  AgeBand LCA1617 HRI_Group1617 health_net_cost1617_min health_net_cost1617_max deceased date_death
/zcompressed.

frequencies AgeBand gender HRI_group1617. 

*Both Age and gender.
get file  = !OFilesL + 'temp_HRI_LA_1617_T1.zsav'
/keep year CHI gender health_net_cost1617 LCA1617  AgeBand LCA1617 HRI_Group1617 deceased date_death.

compute AgeBand = 'All'.
compute gender = 0.
exe.

AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=AgeBand gender HRI_Group1617 LCA1617
  /health_net_cost1617_min=MIN(health_net_cost1617) 
  /health_net_cost1617_max=MAX(health_net_cost1617).

save outfile  = !OFilesL + 'temp_HRI_LA_1617_T4.zsav'
/keep year CHI gender health_net_cost1617 LCA1617  AgeBand LCA1617 HRI_Group1617 health_net_cost1617_min health_net_cost1617_max deceased date_death
/zcompressed.

frequencies AgeBand gender HRI_group1617. 

add files file = !OFilesL + 'temp_HRI_LA_1617_T1.zsav'
/file = !OFilesL + 'temp_HRI_LA_1617_T2.zsav'
/file = !OFilesL + 'temp_HRI_LA_1617_T3.zsav'
/file = !OFilesL + 'temp_HRI_LA_1617_T4.zsav'.
execute.

sort cases by chi AgeBand gender.

save outfile  = !OFilesL + 'temp_HRI_LA_1617.zsav'
/zcompressed.

frequencies AgeBand gender HRI_group1617. 

* Tidy up.
ERASE file  = !OFilesL + 'temp_HRI_LA_1617_T1.sav'.
ERASE file  = !OFilesL + 'temp_HRI_LA_1617_T2.sav'.
ERASE file  = !OFilesL + 'temp_HRI_LA_1617_T3.sav'.
ERASE file  = !OFilesL + 'temp_HRI_LA_1617_T4.sav'.


*** Fin. year 2015/2016.

Define !year()
'201516'
!Enddefine.

get file = '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.zsav'.
select if gender ne 0.
select if hri_scot ne 9.


select if lca='01'.
exe.

*Mar. 2019 FC. 
*Non-Service Users must be excluded by the calculations (only for health activities from 2015/16 onwards)
 Otherwise, these users will be counted in the 'Low Users' category.
select if NSU ne 1.
exe.


alter type postcode (A21).
*exe.
*Create a Scottish flag for the people we know are definitely Scottish as they have a Scottish postcode. 
Sort cases by postcode.
*match files file =*
/Table = '/conf/linkage/output/alisom18/New_Scot_Post_LKP1.sav'
/by postcode.
*exe. 

*FC Nov 19 - Create Numeric 'date_death' consistently with the rest of the sysntax.
Compute date_death = xdate.mday(death_date) + 100*xdate.month(death_date) + 10000*xdate.year(death_date).
exe.


*delete variables PC_District.
String PCDistrict (A12).
Compute PCDistrict = char.substr(postcode,1,4).
exe. 


sort cases by pcDistrict.
match files file = *
/table = '/conf/sourcedev/TableauUpdates/HRIpathways/ScotLookup.sav'
/by PCDistrict.
exe.

*Reformat 'gpprac' back from numeric to string.
String gpprac_str(A5).
compute gpprac_str = string(gpprac,F5.0).
exe.

*Flag people as Scottish if they have a blank postcode and blank gpprac - we assume that these people are Scottish. 
If postcode = " " and gpprac_str= " " ScotFlag = 1.
exe. 

*Finally, we exclude people who have a blank postcode and an English GPprac. 
*FC Mar. 2019 Update.
*If a GP practice is English will be recorded as '99995' (Oct. 2018 Source Linkage Update). 

String Eng_Flag (A1).
If gpprac_str='99995' Eng_Flag='1'.
If (postcode = "" and Eng_Flag ne '1') scotflag=1.
If (postcode='null' and Eng_Flag ne '1') scotflag = 1.
exe. 

*14 people with English GPs.
frequencies Eng_Flag.

*There are some Glasgow postcodes which have not been recognised as Scottish so have to include these. 
String Glasgow_Flag (A2).
Compute Glasgow_Flag = char.substr(postcode,1,2).
exe.

If Any(Glasgow_Flag, 'G0', 'G1', 'G2', 'G3', 'G4', 'G5', 'G6', 'G7', 'G8', 'G9' ) Scotflag = 1.
*There are still a lot of Scottish people so use the Glasgow flag to identify the following.
If Any(Glasgow_Flag, 'DD', 'EH', 'IV', 'AB', 'KA', 'FK', 'HS', 'KW', 'KY', 'ML', 'PA', 'PH','ZE') Scotflag = 1.
exe. 

recode scotflag (sysmis=0).

sort cases by postcode.
*match files file =*
/Table = '/conf/linkage/output/alisom18/New_Scot_Post_LKP2.sav'
/by PC7.
*exe. 
*if scot_flag_1 = 1 scotflag = 1.
*exe. 

frequencies variables = scotflag.


frequencies variables = pcDistrict.
*rename variables PC_District = PCDistrict.
*alter type PCDistrict (A18). 
*match files file =*
/Table = !clout + 'Postcode_district_from_standard_ref.sav'
/by PCDistrict.
*exe. 
*if scot_flag_1 = 1 scotflag = 1.
*exe. 

FREQUENCIES VARIABLES=ScotFlag
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

Delete variables  Glasgow_Flag Eng_Flag.
 

select if scotflag = 1.
exe. 
Delete variables Scotflag.


String HRI_Group (A30).
* Create HRI grouping.
if (HRI_lcaP lt 50) HRI_Group = 'High'.
if (HRI_lcaP ge 50 and HRI_lcaP lt 65) HRI_Group = 'High to Medium'.
if (HRI_lcaP ge 65 and HRI_lcaP lt 80) HRI_Group = 'Medium'.
if (HRI_lcaP ge 80 and HRI_lcaP lt 95) HRI_Group = 'Medium to Low'.
if (HRI_lcaP ge 95) HRI_Group = 'Low'.
if lca eq '' HRI_Group eq 'Not in LA'.
exe.

frequencies HRI_Group.


*FC Dec 19 - Create Numeric 'date of birth'.
Compute dob_num = xdate.mday(dob) + 100*xdate.month(dob) + 10000*xdate.year(dob).
exe.

*Adjust age (Numeric format) to base year of latest year.
alter type dob_num (F8.0).
compute age_num= trunc((20150930-dob_num)/10000).
alter type age_num (F3.0).
compute age_num = age_num + 2.
exe.

frequencies age_num.

* Create required agebands.
string AgeBand (a5).
If (Age_num lt 18) AgeBand = '<18'.
If (Age_num ge 18 and Age_num le 44) AgeBand = '18-44'.
If (Age_num ge 45 and Age_num le 64) AgeBand = '45-64'.
If (Age_num ge 65 and Age_num le 74) AgeBand = '65-74'.
If (Age_num ge 75 and Age_num le 84) AgeBand = '75-84'.
If (Age_num ge 85) AgeBand = '85+'.
exe. 

* Remove any individuals not within a LA.
*select if lca NE ' '.

rename variables (lca HRI_Group health_net_cost = LCA1516 HRI_Group1516 health_net_cost1516).

rename variables Anon_CHI = chi. 

sort cases by chi.


AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=AgeBand gender HRI_Group1516 LCA1516
  /health_net_cost1516_min=MIN(health_net_cost1516) 
  /health_net_cost1516_max=MAX(health_net_cost1516).

save outfile  = !OFilesL + 'temp_HRI_LA_1516_T1.zsav'
/keep year CHI gender health_net_cost1516 LCA1516  AgeBand LCA1516 HRI_Group1516 health_net_cost1516_min health_net_cost1516_max deceased date_death
/zcompressed.

frequencies AgeBand gender HRI_group1516. 

*All ages.
get file  = !OFilesL + 'temp_HRI_LA_1516_T1.zsav'
/keep year CHI gender health_net_cost1516 LCA1516  AgeBand LCA1516 HRI_Group1516 deceased date_death.

compute AgeBand = 'All'.
exe.

AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=AgeBand gender HRI_Group1516 LCA1516
  /health_net_cost1516_min=MIN(health_net_cost1516) 
  /health_net_cost1516_max=MAX(health_net_cost1516).

save outfile  = !OFilesL + 'temp_HRI_LA_1516_T2.zsav'
/keep year CHI gender health_net_cost1516 LCA1516 AgeBand LCA1516 HRI_Group1516 health_net_cost1516_min health_net_cost1516_max deceased date_death
/zcompressed.

frequencies AgeBand gender HRI_group1516. 

* By Gender.
get file  = !OFilesL + 'temp_HRI_LA_1516_T1.zsav'
/keep year CHI gender health_net_cost1516 LCA1516 AgeBand LCA1516 HRI_Group1516 deceased date_death.

compute gender = 0.
exe.

AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=AgeBand gender HRI_Group1516 LCA1516
  /health_net_cost1516_min=MIN(health_net_cost1516) 
  /health_net_cost1516_max=MAX(health_net_cost1516).

save outfile  = !OFilesL + 'temp_HRI_LA_1516_T3.zsav'
/keep year CHI gender health_net_cost1516 LCA1516 AgeBand LCA1516 HRI_Group1516 health_net_cost1516_min health_net_cost1516_max deceased date_death
/zcompressed.

frequencies AgeBand gender HRI_group1516. 

*Both Age and gender.
get file  = !OFilesL + 'temp_HRI_LA_1516_T1.zsav'
/keep year CHI gender health_net_cost1516 LCA1516 AgeBand LCA1516 HRI_Group1516 deceased date_death.

compute AgeBand = 'All'.
compute gender = 0.
exe.

AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=AgeBand gender HRI_Group1516 LCA1516
  /health_net_cost1516_min=MIN(health_net_cost1516) 
  /health_net_cost1516_max=MAX(health_net_cost1516).

save outfile  = !OFilesL + 'temp_HRI_LA_1516_T4.zsav'
/keep year CHI gender health_net_cost1516 LCA1516 AgeBand LCA1516 HRI_Group1516 health_net_cost1516_min health_net_cost1516_max deceased date_death
/zcompressed.

frequencies AgeBand gender HRI_group1516. 

add files file = !OFilesL + 'temp_HRI_LA_1516_T1.zsav'
/file = !OFilesL + 'temp_HRI_LA_1516_T2.zsav'
/file = !OFilesL + 'temp_HRI_LA_1516_T3.zsav'
/file = !OFilesL + 'temp_HRI_LA_1516_T4.zsav'.
exe.

sort cases by chi AgeBand gender.

save outfile  = !OFilesL + 'temp_HRI_LA_1516.zsav'
 /zcompressed.

frequencies AgeBand gender HRI_group1516. 

* Tidy up.
ERASE file  = !OFilesL + 'temp_HRI_LA_1516_T1.sav'.
ERASE file  = !OFilesL + 'temp_HRI_LA_1516_T2.sav'.
ERASE file  = !OFilesL + 'temp_HRI_LA_1516_T3.sav'.
ERASE file  = !OFilesL + 'temp_HRI_LA_1516_T4.sav'.



Define !year()
'201415'
!Enddefine.

get file = '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.zsav'.
select if gender ne 0.
select if hri_scot ne 9.
exe.


select if lca='01'.
exe.

alter type postcode (A21).
*exe.
*Create a Scottish flag for the people we know are definitely Scottish as they have a Scottish postcode. 
Sort cases by postcode.
*match files file =*
/Table = '/conf/linkage/output/alisom18/New_Scot_Post_LKP1.sav'
/by postcode.
*exe. 

*Create Numeric 'date_death' consistently with the rest of the sysntax.
Compute date_death = xdate.mday(death_date) + 100*xdate.month(death_date) + 10000*xdate.year(death_date).
exe.


*delete variables PC_District.
String PCDistrict (A12).
Compute PCDistrict = char.substr(postcode,1,4).
exe. 


sort cases by pcDistrict.
match files file = *
/table = '/conf/sourcedev/TableauUpdates/HRIpathways/ScotLookup.sav'
/by PCDistrict.
exe.

*Reformat 'gpprac' back from numeric to string.
String gpprac_str(A5).
compute gpprac_str = string(gpprac,F5.0).
exe.

*Flag people as Scottish if they have a blank postcode and blank gpprac - we assume that these people are Scottish. 
If postcode = " " and gpprac_str= " " ScotFlag = 1.
exe. 

*Finally, we exclude people who have a blank postcode and an English GPprac. 
*FC Oct. 2018 Update.
*If a GP practice is English will be recorded as '99995' (Oct. 2018 Source Linkage Update). 

String Eng_Flag (A1).
If gpprac_str='99995' Eng_Flag='1'.
If (postcode = "" and Eng_Flag ne '1') scotflag=1.
If (postcode='null' and Eng_Flag ne '1') scotflag = 1.
exe. 

*974 people with English GPs.
frequencies Eng_Flag.


*There are some Glasgow postcodes which have not been recognised as Scottish so have to include these. 
String Glasgow_Flag (A2).
Compute Glasgow_Flag = char.substr(postcode,1,2).
exe.

If Any(Glasgow_Flag, 'G0', 'G1', 'G2', 'G3', 'G4', 'G5', 'G6', 'G7', 'G8', 'G9' ) Scotflag = 1.
*There are still a lot of Scottish people so use the Glasgow flag to identify the following.
If Any(Glasgow_Flag, 'DD', 'EH', 'IV', 'AB', 'KA', 'FK', 'HS', 'KW', 'KY', 'ML', 'PA', 'PH','ZE') Scotflag = 1.
exe. 

recode scotflag (sysmis=0).

sort cases by postcode.
*match files file =*
/Table = '/conf/linkage/output/alisom18/New_Scot_Post_LKP2.sav'
/by PC7.
*exe. 
*if scot_flag_1 = 1 scotflag = 1.
*exe. 

frequencies variables = scotflag.


frequencies variables = pcDistrict.
*rename variables PC_District = PCDistrict.
*alter type PCDistrict (A18). 
*match files file =*
/Table = !clout + 'Postcode_district_from_standard_ref.sav'
/by PCDistrict.
*exe. 
*if scot_flag_1 = 1 scotflag = 1.
*exe. 

FREQUENCIES VARIABLES=ScotFlag
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
*exe. 

Delete variables Glasgow_Flag Eng_Flag.

*Select only those people with postcode and GPprac info (excluding English GPs).
select if scotflag = 1.
exe. 
Delete variables Scotflag.


String HRI_Group (A30).
* Create HRI grouping.
if (HRI_lcaP lt 50) HRI_Group = 'High'.
if (HRI_lcaP ge 50 and HRI_lcaP lt 65) HRI_Group = 'High to Medium'.
if (HRI_lcaP ge 65 and HRI_lcaP lt 80) HRI_Group = 'Medium'.
if (HRI_lcaP ge 80 and HRI_lcaP lt 95) HRI_Group = 'Medium to Low'.
if (HRI_lcaP ge 95) HRI_Group = 'Low'.
if lca eq '' HRI_Group eq 'Not in LA'.
exe.

frequencies HRI_Group.

*FC Dec 19 - Create Numeric 'date of birth'.
Compute dob_num = xdate.mday(dob) + 100*xdate.month(dob) + 10000*xdate.year(dob).
exe.

*Adjust age (Numeric format) to base year of latest year.
alter type dob_num (F8.0).
compute age_num= trunc((20140930-dob_num)/10000).
alter type age_num (F3.0).
compute age_num = age_num + 3.
exe.

frequencies age_num.


* Create required agebands.
string AgeBand (a5).
If (Age_num lt 18) AgeBand = '<18'.
If (Age_num ge 18 and Age_num le 44) AgeBand = '18-44'.
If (Age_num ge 45 and Age_num le 64) AgeBand = '45-64'.
If (Age_num ge 65 and Age_num le 74) AgeBand = '65-74'.
If (Age_num ge 75 and Age_num le 84) AgeBand = '75-84'.
If (Age_num ge 85) AgeBand = '85+'.
exe. 

frequencies AgeBand.

* Remove any individuals not within a LA.
*select if lca NE ' '.
*exe.

rename variables (lca HRI_Group health_net_cost = LCA1415 HRI_Group1415 health_net_cost1415).

rename variables Anon_CHI = chi. 

sort cases by chi.


AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=AgeBand gender HRI_Group1415 LCA1415
  /health_net_cost1415_min=MIN(health_net_cost1415) 
  /health_net_cost1415_max=MAX(health_net_cost1415).

save outfile  = !OFilesL + 'temp_HRI_LA_1415_T1.zsav'
/keep year CHI gender health_net_cost1415 LCA1415  AgeBand LCA1415 HRI_Group1415 health_net_cost1415_min health_net_cost1415_max deceased date_death
/zcompressed.

frequencies AgeBand gender HRI_Group1415.

*All ages.
get file  = !OFilesL + 'temp_HRI_LA_1415_T1.zsav'
/keep year CHI gender health_net_cost1415 LCA1415  AgeBand LCA1415 HRI_Group1415 deceased date_death.

compute AgeBand = 'All'.
exe.

AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=AgeBand gender HRI_Group1415 LCA1415
  /health_net_cost1415_min=MIN(health_net_cost1415) 
  /health_net_cost1415_max=MAX(health_net_cost1415).

save outfile  = !OFilesL + 'temp_HRI_LA_1415_T2.zsav'
/keep year CHI gender health_net_cost1415 LCA1415  AgeBand LCA1415 HRI_Group1415 health_net_cost1415_min health_net_cost1415_max deceased date_death
/zcompressed.

frequencies AgeBand gender HRI_Group1415.

* By Gender.
get file  = !OFilesL + 'temp_HRI_LA_1415_T1.zsav'
/keep year CHI gender health_net_cost1415 LCA1415  AgeBand LCA1415 HRI_Group1415 deceased date_death.

compute gender = 0.
exe.

AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=AgeBand gender HRI_Group1415 LCA1415
  /health_net_cost1415_min=MIN(health_net_cost1415) 
  /health_net_cost1415_max=MAX(health_net_cost1415).

save outfile  = !OFilesL + 'temp_HRI_LA_1415_T3.zsav'
/keep year CHI gender health_net_cost1415 LCA1415  AgeBand LCA1415 HRI_Group1415 health_net_cost1415_min health_net_cost1415_max deceased date_death
/zcompressed.

frequencies AgeBand gender HRI_Group1415.

*Both Age and gender.
get file  = !OFilesL + 'temp_HRI_LA_1415_T1.zsav'
/keep year CHI gender health_net_cost1415 LCA1415  AgeBand LCA1415 HRI_Group1415 deceased date_death.

compute AgeBand = 'All'.
compute gender = 0.
exe.

AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=AgeBand gender HRI_Group1415 LCA1415
  /health_net_cost1415_min=MIN(health_net_cost1415) 
  /health_net_cost1415_max=MAX(health_net_cost1415).

save outfile  = !OFilesL + 'temp_HRI_LA_1415_T4.zsav'
/keep year CHI gender health_net_cost1415 LCA1415  AgeBand LCA1415 HRI_Group1415 health_net_cost1415_min health_net_cost1415_max deceased date_death
/zcompressed.

frequencies AgeBand gender HRI_Group1415.

add files file = !OFilesL + 'temp_HRI_LA_1415_T1.zsav'
/file = !OFilesL + 'temp_HRI_LA_1415_T2.zsav'
/file = !OFilesL + 'temp_HRI_LA_1415_T3.zsav'
/file = !OFilesL + 'temp_HRI_LA_1415_T4.zsav'.
execute.

sort cases by chi AgeBand gender.

save outfile = !OFilesL + 'temp_HRI_LA_1415.zsav'
   /zcompressed.

frequencies AgeBand gender HRI_Group1415.


* Tidy up.
ERASE file  = !OFilesL + 'temp_HRI_LA_1415_T1.sav'.
ERASE file  = !OFilesL + 'temp_HRI_LA_1415_T2.sav'.
ERASE file  = !OFilesL + 'temp_HRI_LA_1415_T3.sav'.
ERASE file  = !OFilesL + 'temp_HRI_LA_1415_T4.sav'.



*************************************************************************************************************************************************.

************************************************************************************.
*Bring all files together (Including saved data for 2014/15, 2015/16).

Get file  = !OFilesL + 'temp_HRI_LA_1718.zsav'.

****Rename deceased_flag to deceased for 1415, 1516 data and update lca codes for 'Fife' and 'Perth & Kinross' ****.
match files file = *
/file =  !OFilesL + 'temp_HRI_LA_1617.zsav'
/file =  !OFilesL + 'temp_HRI_LA_1516.zsav'
/file =  !OFilesL + 'temp_HRI_LA_1415.zsav'
/by chi AgeBand gender.
exe.

* Convert LA variable to a number.
alter type LCA1718 (F2.0).
alter type LCA1516 (F2.0).
alter type LCA1415 (F2.0).
alter type LCA1617 (F2.0).
alter type date_death (F8).

save outfile  = !OFilesL + 'temp_HRI_LA_MASTER_ALLYR.zsav'
  /zcompressed.


* Tidy up.
*ERASE file  =  !OFilesL + 'temp_HRI_LA_1718.sav'.
*ERASE file  =  !OFilesL + 'temp_HRI_LA_1415.sav'.
*ERASE file  =  !OFilesL + 'temp_HRI_LA_1516.sav'.
*ERASE file  =  !OFilesL + 'temp_HRI_LA_1617.sav'.



** Now need to create individual LA records to track individuals overtime.
get file  = !OFilesL + 'temp_HRI_LA_MASTER_ALLYR.zsav'.

*Set LA.
compute x = 1.
exe.

* Identify selected individuals in selected LA.

compute lcaFlag = 0.
if LCA1718 = x lcaFlag = 1.
if LCA1415 = x lcaFlag = 1.
if LCA1516 = x lcaFlag = 1.
if LCA1617 = x lcaFlag = 1.

select if lcaFlag = 1.
exe.
 
* Identify any individuals that wheren't in selected area.
if LCA1718 ne x HRI_Group1718 = 'Not in LA'.
if LCA1415 ne x HRI_Group1415 = 'Not in LA'.
if LCA1516 ne x HRI_Group1516 = 'Not in LA'.
if LCA1617 ne x HRI_Group1617 = 'Not in LA'.
exe.


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

* Correct some codings where individuals dies after moving LA. If no contact can assume stayed in same LA..
if HRI_Group1516 = "Died" and HRI_Group1415 = "Not in LA" HRI_Group1516 = "Not in LA".
if HRI_Group1617 = "Died" and HRI_Group1516 = "Not in LA" HRI_Group1617 = "Not in LA".
if HRI_Group1718 = "Died" and HRI_Group1617 = "Not in LA" HRI_Group1718 = "Not in LA".
exe.


* Remove Costs data for those not in LA.
if HRI_Group1617 = "Not in LA" health_net_cost1617 = 0.
if HRI_Group1516 = "Not in LA" health_net_cost1516 = 0.
if HRI_Group1415 = "Not in LA" health_net_cost1415 = 0.
if HRI_Group1718 = "Not in LA" health_net_cost1718 = 0.
exe.

* Remove Costs data for those Died before start of FY.
if HRI_Group1617 = "Died" health_net_cost1617 = 0.
if HRI_Group1516 = "Died" health_net_cost1516 = 0.
if HRI_Group1415 = "Died" health_net_cost1415 = 0.
if HRI_Group1718 = "Died" health_net_cost1718 = 0.
exe.


compute lca_Select = x.
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
exe.

* Each individuals pathway should be recorded 6 times, if valid. There are issues with mapping CHI over years therefore mismatches which need to be removed.
string PathwayXCheck (A100).
Compute PathwayXCheck = CONCAT(CHI, PathwayLKP).


sort cases by PathwayXCheck.

compute check = 1.
if (lag(PathwayXCheck)=PathwayXCheck) check=lag(check)+1. 


AGGREGATE 
  /OUTFILE=*  MODE=ADDVARIABLES
  /BREAK=PathwayXCheck 
  /check_max=MAX(check).

compute Remove = 0.
if check_max < 4 Remove = 1.
exe.

* Modify PathwayLKP to include LA details.
compute PathwayLKP = concat(STRING (lca_Select,F8),PathwayLKP).
exe.
*Remove all spaces from PathwayLKP.
COMPUTE PathwayLKP = REPLACE(PathwayLKP, " ", "").
exe.
* Create a Pathway Label for use in Tableau.
string PathwayLabel (A100).
exe.

compute PathwayLabel = concat(HRI_Group1415, ' - ', HRI_Group1516, ' - ', HRI_Group1617, HRI_Group1718, ' - ').
exe. 

* Need to save out Pathway lookup to match on the original CHIMASTER level data.
save outfile  = !OFilesL + 'temp_HRI_LA_ALLYR_CHI1.zsav'
  /keep chi lca_select PathwayLKP PathwayLabel HRI_Group1718 HRI_Group1617 HRI_Group1415 HRI_Group1516 Remove
  /zcompressed.


* Remove mis-match records.
select if Remove NE 1.
exe.

AGGREGATE
  /OUTFILE=*
  /BREAK=lca_Select genderSTR AgeBand HRI_Group1617 HRI_Group1718 HRI_Group1415 HRI_Group1516 PathwayLKP PathwayLabel
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
*get file = !OFilesL + 'temp_HRI_LA_ALLYR1_Sorted.sav'.


*add files file = *
/file='/conf/linkage/output/euanpa01/Sankey_Link_dataset_Dummy.sav'.

*string Link (A4).
*Compute Link = "link".
*exe.
*if AgeBand = "All" AgeBand = "All ages".
*exe.

*string Data (A25).
*compute Data = "Sankey".
*exe.

*Select if PathwayLabel NE "Remove".
*exe.

*SAVE OUTFILE='/conf/irf/01-CPTeam/02-Functional-outputs/09-Tableau-Outputs/01-Development/02-SPSS-Outputs/03-HRI/Sankey_Link_dataset_FINAL.sav'.

*get FILE='/conf/irf/01-CPTeam/02-Functional-outputs/09-Tableau-Outputs/01-Development/02-SPSS-Outputs/03-HRI/Sankey_Link_dataset_FINAL.sav'.

************************************************************************************************************************************************************************************.














************************************Aggregate Non-HRIs for Alternative Chart*****************************************.  
*****************Chart just looks at HRIs/Non-HRIs/Died for demo purposes - Not Part of Main Output**********.

