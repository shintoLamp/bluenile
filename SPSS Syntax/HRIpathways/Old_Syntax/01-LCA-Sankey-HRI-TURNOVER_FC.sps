* Encoding: ISO-8859-1.
**********************************************************************************************************************************************************************
*******************************Syntax to produce data for Sankey chart for Dashboard 2 of HRI Pathways workbook***********************************.
*******************************BEWARE - Running time of 1+ days - Please ensure large file space before running**********************************.

***FC Oct. 2018. Updated variables which have been renamed/reformatted to reflect changes in Source Linkage Files
    Renamed variables: 'death_date' back to 'date_death', pc7 to postcode
    Reformatted variables: dob (from date to numeric), gpprac (from date back to numeric)
    Changed codes:  LCA codes for 'Fife' and 'Perth & Kinross'.

* File save location.
define !OFilesL()
        '/conf/sourcedev/TableauUpdates/HRIpathways/Outputs/'
!Enddefine.



******************************************************************
*************************************************************************************************************************************************.
*** Start with first financial year (2014/2015).
Define !year()
'201415'
!Enddefine.

get file = '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.zsav'.
select if gender ne 0.
select if hri_scot ne 9.
exe.


alter type postcode (A21).
*Execute.
*Create a Scottish flag for the people we know are definitely Scottish as they have a Scottish postcode. 
Sort cases by postcode.
*match files file =*
/Table = '/conf/linkage/output/alisom18/New_Scot_Post_LKP1.sav'
/by PC7.
*execute. 

*Rename 'death_date' variable to make it consistent with the rest of the sysntax.
Rename variables death_date = date_death.
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
execute.

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
*exe. 

*974 people with English GPs.
frequencies Eng_Flag.


*There are some Glasgow postcodes which have not been recognised as Scottish so have to include these. 
String Glasgow_Flag (A2).
Compute Glasgow_Flag = char.substr(postcode,1,2).
exe.

If Any(Glasgow_Flag, 'G0', 'G1', 'G2', 'G3', 'G4', 'G5', 'G6', 'G7', 'G8', 'G9' ) Scotflag = 1.
*There are still a lot of Scottish people so use the Glasgow flag to identify the following.
If Any(Glasgow_Flag, 'DD', 'EH', 'IV', 'AB', 'KA', 'FK', 'HS', 'KW', 'KY', 'ML', 'PA', 'PH','ZE') Scotflag = 1.
*execute. 

recode scotflag (sysmis=0).

sort cases by postcode.
*match files file =*
/Table = '/conf/linkage/output/alisom18/New_Scot_Post_LKP2.sav'
/by PC7.
*execute. 
*if scot_flag_1 = 1 scotflag = 1.
*execute. 

frequencies variables = scotflag.


frequencies variables = pcDistrict.
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
If Scotflag ne 1 NonScot = postcode.
FREQUENCIES VARIABLES=NonScot
  /ORDER=ANALYSIS.


*Select if Scot_Flag = 1.
*execute. 

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


* Adjust age to base year of latest year.

*alter type dob (F8.0).
*compute age= trunc((20160930-dob)/10000).
*alter type age (F3.0).
*execute.

**FC Mar. 2019**
** 'Age' information is included in the Source Linkage File, no need to calculate it based on dob as previously done.

* Create required agebands.
string AgeBand (a5).
If (Age lt 18) AgeBand = '<18'.
If (Age ge 18 and Age le 44) AgeBand = '18-44'.
If (Age ge 45 and Age le 64) AgeBand = '45-64'.
If (Age ge 65 and Age le 74) AgeBand = '65-74'.
If (Age ge 75 and Age le 84) AgeBand = '75-84'.
If (Age ge 85) AgeBand = '85+'.
exe. 

* Remove any individuals not within a LA.
*select if lca NE ' '.
*EXECUTE.

rename variables (lca HRI_Group health_net_cost = lca1415 HRI_Group1415 health_net_cost1415).

rename variables Anon_CHI = chi. 

sort cases by chi.


AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=AgeBand gender HRI_Group1415 lca1415
  /health_net_cost1415_min=MIN(health_net_cost1415) 
  /health_net_cost1415_max=MAX(health_net_cost1415).

save outfile  = !OFilesL + 'temp_HRI_LA_1415_T1.sav'
/keep year CHI gender health_net_cost1415 lca1415  AgeBand LCA1415 HRI_Group1415 health_net_cost1415_min health_net_cost1415_max deceased date_death.

*All ages.
get file  = !OFilesL + 'temp_HRI_LA_1415_T1.sav'
/keep year CHI gender health_net_cost1415 lca1415  AgeBand LCA1415 HRI_Group1415 deceased date_death.

compute AgeBand = 'All'.
exe.

AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=AgeBand gender HRI_Group1415 lca1415
  /health_net_cost1415_min=MIN(health_net_cost1415) 
  /health_net_cost1415_max=MAX(health_net_cost1415).

save outfile  = !OFilesL + 'temp_HRI_LA_1415_T2.sav'
/keep year CHI gender health_net_cost1415 lca1415  AgeBand LCA1415 HRI_Group1415 health_net_cost1415_min health_net_cost1415_max deceased date_death.

* By Gender.
get file  = !OFilesL + 'temp_HRI_LA_1415_T1.sav'
/keep year CHI gender health_net_cost1415 lca1415  AgeBand LCA1415 HRI_Group1415 deceased date_death.

compute gender = 0.
exe.

AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=AgeBand gender HRI_Group1415 lca1415
  /health_net_cost1415_min=MIN(health_net_cost1415) 
  /health_net_cost1415_max=MAX(health_net_cost1415).

save outfile  = !OFilesL + 'temp_HRI_LA_1415_T3.sav'
/keep year CHI gender health_net_cost1415 lca1415  AgeBand LCA1415 HRI_Group1415 health_net_cost1415_min health_net_cost1415_max deceased date_death.

*Both Age and gender.
get file  = !OFilesL + 'temp_HRI_LA_1415_T1.sav'
/keep year CHI gender health_net_cost1415 lca1415  AgeBand LCA1415 HRI_Group1415 deceased date_death.

compute AgeBand = 'All'.
compute gender = 0.
exe.

AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=AgeBand gender HRI_Group1415 lca1415
  /health_net_cost1415_min=MIN(health_net_cost1415) 
  /health_net_cost1415_max=MAX(health_net_cost1415).

save outfile  = !OFilesL + 'temp_HRI_LA_1415_T4.sav'
/keep year CHI gender health_net_cost1415 lca1415  AgeBand LCA1415 HRI_Group1415 health_net_cost1415_min health_net_cost1415_max deceased date_death.

add files file = !OFilesL + 'temp_HRI_LA_1415_T1.sav'
/file = !OFilesL + 'temp_HRI_LA_1415_T2.sav'
/file = !OFilesL + 'temp_HRI_LA_1415_T3.sav'
/file = !OFilesL + 'temp_HRI_LA_1415_T4.sav'.
exe.

sort cases by chi AgeBand gender.

save outfile = !OFilesL + 'temp_HRI_LA_1415.sav'.


* Tidy up.
ERASE file  = !OFilesL + 'temp_HRI_LA_1415_T1.sav'.
ERASE file  = !OFilesL + 'temp_HRI_LA_1415_T2.sav'.
ERASE file  = !OFilesL + 'temp_HRI_LA_1415_T3.sav'.
ERASE file  = !OFilesL + 'temp_HRI_LA_1415_T4.sav'.


*** Fin. year 2015/2016.

Define !year()
'201516'
!Enddefine.

get file = '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.zsav'.
select if gender ne 0.
select if hri_scot ne 9.

*Mar. 2019 FC. 
*Non-Service Users must be excluded by the calculations (only for health activities from 2015/16 onwards)
 Otherwise, these users will be counted in the 'Low Users' category.
select if NSU ne 1.
exe.


alter type postcode (A21).
*Execute.
*Create a Scottish flag for the people we know are definitely Scottish as they have a Scottish postcode. 
Sort cases by postcode.
*match files file =*
/Table = '/conf/linkage/output/alisom18/New_Scot_Post_LKP1.sav'
/by PC7.
*execute. 

*Rename 'death_date' variable to make it consistent with the rest of the sysntax.
Rename variables death_date = date_death.
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

*664 people with English GPs.
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
*execute. 
*if scot_flag_1 = 1 scotflag = 1.
*execute. 

frequencies variables = scotflag.


frequencies variables = pcDistrict.
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


* Adjust age to base year of latest year.

*alter type dob (F8.0).
*compute age= trunc((20160930-dob)/10000).
*alter type age (F3.0).
*execute.

**FC Mar. 2019**
** 'Age' is already included in the Source Linkage File, no need to calculate it based on 'dob' as previously done.

* Create required agebands.
string AgeBand (a5).
If (Age lt 18) AgeBand = '<18'.
If (Age ge 18 and Age le 44) AgeBand = '18-44'.
If (Age ge 45 and Age le 64) AgeBand = '45-64'.
If (Age ge 65 and Age le 74) AgeBand = '65-74'.
If (Age ge 75 and Age le 84) AgeBand = '75-84'.
If (Age ge 85) AgeBand = '85+'.
exe. 

* Remove any individuals not within a LA.
*select if lca NE ' '.

rename variables (lca HRI_Group health_net_cost = lca1516 HRI_Group1516 health_net_cost1516).

rename variables Anon_CHI = chi. 

sort cases by chi.


AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=AgeBand gender HRI_Group1516 lca1516
  /health_net_cost1516_min=MIN(health_net_cost1516) 
  /health_net_cost1516_max=MAX(health_net_cost1516).

save outfile  = !OFilesL + 'temp_HRI_LA_1516_T1.sav'
/keep year CHI gender health_net_cost1516 lca1516  AgeBand LCA1516 HRI_Group1516 health_net_cost1516_min health_net_cost1516_max deceased date_death.

*All ages.
get file  = !OFilesL + 'temp_HRI_LA_1516_T1.sav'
/keep year CHI gender health_net_cost1516 lca1516  AgeBand LCA1516 HRI_Group1516 deceased date_death.

compute AgeBand = 'All'.
exe.

AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=AgeBand gender HRI_Group1516 lca1516
  /health_net_cost1516_min=MIN(health_net_cost1516) 
  /health_net_cost1516_max=MAX(health_net_cost1516).

save outfile  = !OFilesL + 'temp_HRI_LA_1516_T2.sav'
/keep year CHI gender health_net_cost1516 lca1516 AgeBand LCA1516 HRI_Group1516 health_net_cost1516_min health_net_cost1516_max deceased date_death.

* By Gender.
get file  = !OFilesL + 'temp_HRI_LA_1516_T1.sav'
/keep year CHI gender health_net_cost1516 lca1516 AgeBand LCA1516 HRI_Group1516 deceased date_death.

compute gender = 0.
exe.

AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=AgeBand gender HRI_Group1516 lca1516
  /health_net_cost1516_min=MIN(health_net_cost1516) 
  /health_net_cost1516_max=MAX(health_net_cost1516).

save outfile  = !OFilesL + 'temp_HRI_LA_1516_T3.sav'
/keep year CHI gender health_net_cost1516 lca1516 AgeBand LCA1516 HRI_Group1516 health_net_cost1516_min health_net_cost1516_max deceased date_death.

*Both Age and gender.
get file  = !OFilesL + 'temp_HRI_LA_1516_T1.sav'
/keep year CHI gender health_net_cost1516 lca1516 AgeBand LCA1516 HRI_Group1516 deceased date_death.

compute AgeBand = 'All'.
compute gender = 0.
exe.

AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=AgeBand gender HRI_Group1516 lca1516
  /health_net_cost1516_min=MIN(health_net_cost1516) 
  /health_net_cost1516_max=MAX(health_net_cost1516).

save outfile  = !OFilesL + 'temp_HRI_LA_1516_T4.sav'
/keep year CHI gender health_net_cost1516 lca1516 AgeBand LCA1516 HRI_Group1516 health_net_cost1516_min health_net_cost1516_max deceased date_death.

add files file = !OFilesL + 'temp_HRI_LA_1516_T1.sav'
/file = !OFilesL + 'temp_HRI_LA_1516_T2.sav'
/file = !OFilesL + 'temp_HRI_LA_1516_T3.sav'
/file = !OFilesL + 'temp_HRI_LA_1516_T4.sav'.
exe.

sort cases by chi AgeBand gender.

save outfile  = !OFilesL + 'temp_HRI_LA_1516.zsav'
  /ZCOMPRESSED.

* Tidy up.
ERASE file  = !OFilesL + 'temp_HRI_LA_1516_T1.sav'.
ERASE file  = !OFilesL + 'temp_HRI_LA_1516_T2.sav'.
ERASE file  = !OFilesL + 'temp_HRI_LA_1516_T3.sav'.
ERASE file  = !OFilesL + 'temp_HRI_LA_1516_T4.sav'.



*Fin. Year  2016/2017
*Macro 1.
Define !year()
'201617'
!Enddefine.

get file = '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.zsav'.
select if gender ne 0.
select if hri_scot ne 9.

*Mar. 2019 FC. 
*Non-Service Users must be excluded by the calculations (only for health activities from 2015/16 onwards)
 Otherwise, these users will be counted in the 'Low Users' category.
select if NSU ne 1.
exe.


alter type postcode (A21).
*Execute.
*Create a Scottish flag for the people we know are definitely Scottish as they have a Scottish postcode. 
Sort cases by postcode.
*match files file =*
/Table = '/conf/linkage/output/alisom18/New_Scot_Post_LKP1.sav'
/by PC7.
*execute. 

*Rename 'death_date' variable to make it consistent with the rest of the sysntax.
Rename variables death_date = date_death.
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
execute.

*Flag people as Scottish if they have a blank postcode and blank gpprac - we assume that these people are Scottish. 
If postcode = " " and gpprac_str= " " ScotFlag = 1.
*execute. 

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
*execute. 
*if scot_flag_1 = 1 scotflag = 1.
*execute. 

frequencies variables = scotflag.


frequencies variables = pcDistrict.
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


* Adjust age to base year of latest year.

*alter type dob (F8.0).
*compute age= trunc((20160930-dob)/10000).
*alter type age (F3.0).
*execute.

**FC Mar. 2019**
** 'Age' information is included in the Source Linkage File, no need to calculate it based on dob as previously done.


* Create required agebands.
string AgeBand (a5).
If (Age lt 18) AgeBand = '<18'.
If (Age ge 18 and Age le 44) AgeBand = '18-44'.
If (Age ge 45 and Age le 64) AgeBand = '45-64'.
If (Age ge 65 and Age le 74) AgeBand = '65-74'.
If (Age ge 75 and Age le 84) AgeBand = '75-84'.
If (Age ge 85) AgeBand = '85+'.
exe. 

* Remove any individuals not within a LA.
*select if lca NE ' '.

rename variables (lca HRI_Group health_net_cost = lca1617 HRI_Group1617 health_net_cost1617).

rename variables Anon_CHI = chi. 

sort cases by chi.


AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=AgeBand gender HRI_Group1617 lca1617
  /health_net_cost1617_min=MIN(health_net_cost1617) 
  /health_net_cost1617_max=MAX(health_net_cost1617).

save outfile  = !OFilesL + 'temp_HRI_LA_1617_T1.sav'
/keep year CHI gender health_net_cost1617 lca1617  AgeBand LCA1617 HRI_Group1617 health_net_cost1617_min health_net_cost1617_max deceased date_death.

*All ages.
get file  = !OFilesL + 'temp_HRI_LA_1617_T1.sav'
/keep year CHI gender health_net_cost1617 lca1617  AgeBand LCA1617 HRI_Group1617 deceased date_death.

compute AgeBand = 'All'.
exe.

AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=AgeBand gender HRI_Group1617 lca1617
  /health_net_cost1617_min=MIN(health_net_cost1617) 
  /health_net_cost1617_max=MAX(health_net_cost1617).

save outfile  = !OFilesL + 'temp_HRI_LA_1617_T2.sav'
/keep year CHI gender health_net_cost1617 lca1617  AgeBand LCA1617 HRI_Group1617 health_net_cost1617_min health_net_cost1617_max deceased date_death.

* By Gender.
get file  = !OFilesL + 'temp_HRI_LA_1617_T1.sav'
/keep year CHI gender health_net_cost1617 lca1617  AgeBand LCA1617 HRI_Group1617 deceased date_death.

compute gender = 0.
exe.

AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=AgeBand gender HRI_Group1617 lca1617
  /health_net_cost1617_min=MIN(health_net_cost1617) 
  /health_net_cost1617_max=MAX(health_net_cost1617).

save outfile  = !OFilesL + 'temp_HRI_LA_1617_T3.sav'
/keep year CHI gender health_net_cost1617 lca1617  AgeBand LCA1617 HRI_Group1617 health_net_cost1617_min health_net_cost1617_max deceased date_death.

*Both Age and gender.
get file  = !OFilesL + 'temp_HRI_LA_1617_T1.sav'
/keep year CHI gender health_net_cost1617 lca1617  AgeBand LCA1617 HRI_Group1617 deceased date_death.

compute AgeBand = 'All'.
compute gender = 0.
exe.

AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=AgeBand gender HRI_Group1617 lca1617
  /health_net_cost1617_min=MIN(health_net_cost1617) 
  /health_net_cost1617_max=MAX(health_net_cost1617).

save outfile  = !OFilesL + 'temp_HRI_LA_1617_T4.sav'
/keep year CHI gender health_net_cost1617 lca1617  AgeBand LCA1617 HRI_Group1617 health_net_cost1617_min health_net_cost1617_max deceased date_death.

add files file = !OFilesL + 'temp_HRI_LA_1617_T1.sav'
/file = !OFilesL + 'temp_HRI_LA_1617_T2.sav'
/file = !OFilesL + 'temp_HRI_LA_1617_T3.sav'
/file = !OFilesL + 'temp_HRI_LA_1617_T4.sav'.
exe.

sort cases by chi AgeBand gender.

save outfile  = !OFilesL + 'temp_HRI_LA_1617.zsav'
    /ZCOMPRESSED.

* Tidy up.
ERASE file  = !OFilesL + 'temp_HRI_LA_1617_T1.sav'.
ERASE file  = !OFilesL + 'temp_HRI_LA_1617_T2.sav'.
ERASE file  = !OFilesL + 'temp_HRI_LA_1617_T3.sav'.
ERASE file  = !OFilesL + 'temp_HRI_LA_1617_T4.sav'.



*Last Financial Year.
Define !year()
'201718'
!Enddefine.

get file = '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.zsav'.
select if gender ne 0.
select if hri_scot ne 9.

*Mar 2019 FC. 
*Non-Service Users must be excluded by the calculations (only for health activities from 2015/16 onwards)
 Otherwise, these users will be counted in the 'Low Users' category.
select if NSU ne 1.
exe.


*rename variables health_postcode =pc7. 
alter type postcode (A21).
*Execute.
*Create a Scottish flag for the people we know are definitely Scottish as they have a Scottish postcode. 
Sort cases by postcode.
*match files file =*
/Table = '/conf/linkage/output/alisom18/New_Scot_Post_LKP1.sav'
/by PC7.
*execute. 

*Rename 'death_date' variable to make it consistent with the rest of the sysntax.
Rename variables death_date = date_death.
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
*execute. 
*if scot_flag_1 = 1 scotflag = 1.
*execute. 

frequencies variables = scotflag.


frequencies variables = pcDistrict.
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

* Adjust age to base year of latest year.

*alter type dob (F8.0).
*compute age= trunc((20160930-dob)/10000).
*alter type age (F3.0).
*execute.

**FC Mar. 2019**
** 'Age' is already included in the Source Linkage File, no need to calculate it based on dob as previously done.

*compute Age = Age + 1.
*EXECUTE.

* Create required agebands.
string AgeBand (a5).
If (Age lt 18) AgeBand = '<18'.
If (Age ge 18 and Age le 44) AgeBand = '18-44'.
If (Age ge 45 and Age le 64) AgeBand = '45-64'.
If (Age ge 65 and Age le 74) AgeBand = '65-74'.
If (Age ge 75 and Age le 84) AgeBand = '75-84'.
If (Age ge 85) AgeBand = '85+'.
exe. 

* Remove any individuals not within a LA.
*select if lca NE ' '.

rename variables (lca HRI_Group health_net_cost = lca1718 HRI_Group1718 health_net_cost1718).

rename variables Anon_CHI = chi. 

sort cases by chi.


AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=AgeBand gender HRI_Group1718 lca1718
  /health_net_cost1718_min=MIN(health_net_cost1718) 
  /health_net_cost1718_max=MAX(health_net_cost1718).

save outfile  = !OFilesL + 'temp_HRI_LA_1718_T1.sav'
/keep year CHI gender health_net_cost1718 lca1718  AgeBand LCA1718 HRI_Group1718 health_net_cost1718_min health_net_cost1718_max deceased date_death.

*All ages.
get file  = !OFilesL + 'temp_HRI_LA_1718_T1.sav'
/keep year CHI gender health_net_cost1718 lca1718  AgeBand LCA1718 HRI_Group1718 deceased date_death.

compute AgeBand = 'All'.
exe.

AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=AgeBand gender HRI_Group1718 lca1718
  /health_net_cost1718_min=MIN(health_net_cost1718) 
  /health_net_cost1718_max=MAX(health_net_cost1718).

save outfile  = !OFilesL + 'temp_HRI_LA_1718_T2.sav'
/keep year CHI gender health_net_cost1718 lca1718  AgeBand LCA1718 HRI_Group1718 health_net_cost1718_min health_net_cost1718_max deceased date_death.

* By Gender.
get file  = !OFilesL + 'temp_HRI_LA_1718_T1.sav'
/keep year CHI gender health_net_cost1718 lca1718  AgeBand LCA1718 HRI_Group1718 deceased date_death.

compute gender = 0.
exe.

AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=AgeBand gender HRI_Group1718 lca1718
  /health_net_cost1718_min=MIN(health_net_cost1718) 
  /health_net_cost1718_max=MAX(health_net_cost1718).

save outfile  = !OFilesL + 'temp_HRI_LA_1718_T3.sav'
/keep year CHI gender health_net_cost1718 lca1718  AgeBand LCA1718 HRI_Group1718 health_net_cost1718_min health_net_cost1718_max deceased date_death.

*Both Age and gender.
get file  = !OFilesL + 'temp_HRI_LA_1718_T1.sav'
/keep year CHI gender health_net_cost1718 lca1718  AgeBand LCA1718 HRI_Group1718 deceased date_death.

compute AgeBand = 'All'.
compute gender = 0.
exe.

AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=AgeBand gender HRI_Group1718 lca1718
  /health_net_cost1718_min=MIN(health_net_cost1718) 
  /health_net_cost1718_max=MAX(health_net_cost1718).

save outfile  = !OFilesL + 'temp_HRI_LA_1718_T4.sav'
/keep year CHI gender health_net_cost1718 lca1718  AgeBand LCA1718 HRI_Group1718 health_net_cost1718_min health_net_cost1718_max deceased date_death.

add files file = !OFilesL + 'temp_HRI_LA_1718_T1.sav'
/file = !OFilesL + 'temp_HRI_LA_1718_T2.sav'
/file = !OFilesL + 'temp_HRI_LA_1718_T3.sav'
/file = !OFilesL + 'temp_HRI_LA_1718_T4.sav'.
exe.

sort cases by chi AgeBand gender.

save outfile  = !OFilesL + 'temp_HRI_LA_1718.zsav'
     /ZCOMPRESSED.    

* Tidy up.
ERASE file  = !OFilesL + 'temp_HRI_LA_1718_T1.sav'.
ERASE file  = !OFilesL + 'temp_HRI_LA_1718_T2.sav'.
ERASE file  = !OFilesL + 'temp_HRI_LA_1718_T3.sav'.
ERASE file  = !OFilesL + 'temp_HRI_LA_1718_T4.sav'.


*************************************************************************************************************************************************.

************************************************************************************.
*Bring all files together (Including saved data for 2014/15, 2015/16).

Get file  = !OFilesL + 'temp_HRI_LA_1718.sav'.

****Rename deceased_flag to deceased for 1415, 1516 data and update LCA codes for 'Fife' and 'Perth & Kinross' ****.
match files file = *
/file =  !OFilesL + 'temp_HRI_LA_1617.sav'
/file =  !OFilesL + 'temp_HRI_LA_1516.sav'
/file =  !OFilesL + 'temp_HRI_LA_1415.sav'
/by chi AgeBand gender.
exe.

* Convert LA variable to a number.
alter type LCA1718 (F2.0).
alter type LCA1516 (F2.0).
alter type LCA1415 (F2.0).
alter type LCA1617 (F2.0).
alter type date_death (F8).

save outfile  = !OFilesL + 'temp_HRI_LA_MASTER_ALLYR.sav'.

* Tidy up.
ERASE file  =  !OFilesL + 'temp_HRI_LA_1718.sav'.
ERASE file  =  !OFilesL + 'temp_HRI_LA_1415.sav'.
ERASE file  =  !OFilesL + 'temp_HRI_LA_1516.sav'.
ERASE file  =  !OFilesL + 'temp_HRI_LA_1617.sav'.

** Now need to create individual LA records to track individuals overtime.

get file  = !OFilesL + 'temp_HRI_LA_MASTER_ALLYR.sav'.

* Set LA.
compute x = 1.
exe.

* Identify selected individuals in selected LA.

compute LCAFlag = 0.
if LCA1718 = x LCAFlag = 1.
if LCA1415 = x LCAFlag = 1.
if LCA1516 = x LCAFlag = 1.
if LCA1617 = x LCAFlag = 1.

select if LCAFlag = 1.
exe.
 
* Identify any individuals that wheren't in selected area.
if lca1718 ne x HRI_Group1617 = 'Not in LA'.
if lca1415 ne x HRI_Group1415 = 'Not in LA'.
if lca1516 ne x HRI_Group1516 = 'Not in LA'.
if lca1718 ne x HRI_Group1718 = 'Not in LA'.
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


compute LCA_Select = x.
exe.

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
exe.


string PathwayLKP (A100).

compute PathwayLKP = concat(rtrim(HRI_Group1415), rtrim(HRI_Group1516), rtrim(HRI_Group1617), rtrim(HRI_Group1718)).
exe.

save outfile  = !OFilesL + 'temp_HRI_LAT2.sav'.

* Agg Age.
get file  = !OFilesL + 'temp_HRI_LAT1.sav'.

select if AgeBand = "All".
select if  GenderSTR NE "Both".
exe.

string PathwayLKP (A100).

compute PathwayLKP = concat(rtrim(HRI_Group1415), rtrim(HRI_Group1516), rtrim(HRI_Group1617), rtrim(HRI_Group1718)).
exe. 

save outfile  = !OFilesL + 'temp_HRI_LAT3.sav'.

* Agg Gender.
get file  = !OFilesL + 'temp_HRI_LAT1.sav'.

select if GenderSTR = "Both".
select if AgeBand NE "All".
exe.

string PathwayLKP (A100).

compute PathwayLKP = concat(rtrim(HRI_Group1415), rtrim(HRI_Group1516), rtrim(HRI_Group1617), rtrim(HRI_Group1718)).
exe. 

save outfile  = !OFilesL + 'temp_HRI_LAT4.sav'.

* Agg Age & Gender.
get file  = !OFilesL + 'temp_HRI_LAT1.sav'.

select if  GenderSTR = "Both".
select if AgeBand = "All".
exe.

string PathwayLKP (A100).

compute PathwayLKP = concat(rtrim(HRI_Group1415), rtrim(HRI_Group1516), rtrim(HRI_Group1617), rtrim(HRI_Group1718)).
exe. 

save outfile  = !OFilesL + 'temp_HRI_LAT5.sav'.

*bring files togther.
add files file = !OFilesL + 'temp_HRI_LAT2.sav'
/file = !OFilesL + 'temp_HRI_LAT3.sav'
/file = !OFilesL + 'temp_HRI_LAT4.sav'
/file = !OFilesL + 'temp_HRI_LAT5.sav'.
exe.

*Remove all spaces from PathwayLKP.
COMPUTE PathwayLKP = REPLACE(PathwayLKP, " ", "").
exe.

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
compute PathwayLKP = concat(STRING (LCA_Select,F8),PathwayLKP).
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
save outfile  = !OFilesL + 'temp_HRI_LA_ALLYR_CHI1.sav'
/keep chi LCA_select PathwayLKP PathwayLabel HRI_Group1718 HRI_Group1617 HRI_Group1415 HRI_Group1516 Remove.

* Remove mis-match records.
select if Remove NE 1.
exe.

AGGREGATE
  /OUTFILE=*
  /BREAK=LCA_Select genderSTR AgeBand HRI_Group1617 HRI_Group1718 HRI_Group1415 HRI_Group1516 PathwayLKP PathwayLabel
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

save outfile  = !OFilesL + 'temp_HRI_LA_ALLYR1.sav'.

** LA 2.
get file  = !OFilesL + 'temp_HRI_LA_MASTER_ALLYR.sav'.

* Set LA.
compute x = 2.
exe.

* Identify selected individuals in selected LA.

compute LCAFlag = 0.
if LCA1718 = x LCAFlag = 1.
if LCA1617 = x LCAFlag = 1.
if LCA1415 = x LCAFlag = 1.
if LCA1516 = x LCAFlag = 1.

select if LCAFlag = 1.
exe.
 
* Identify any individuals that wheren't in selected area.
if lca1718 ne x HRI_Group1718 = 'Not in LA'.
if lca1617 ne x HRI_Group1617 = 'Not in LA'.
if lca1415 ne x HRI_Group1415 = 'Not in LA'.
if lca1516 ne x HRI_Group1516 = 'Not in LA'.
exe.

* Add death marker.
if date_death < 20170401 HRI_Group1718 = 'Died'.
if date_death < 20160401 HRI_Group1617 = 'Died'.
if date_death < 20150401 HRI_Group1516 = 'Died'.
if date_death > 20170401 and HRI_Group1718 = ' ' HRI_Group1718 = 'Died'.
exe.


* Assume any blanks are now showing no contact in year.
if HRI_Group1718 = ' ' HRI_Group1718 = 'No Contact'.
if HRI_Group1415 = ' ' HRI_Group1415 = 'No Contact'.
if HRI_Group1516 = ' ' HRI_Group1516 = 'No Contact'.
if HRI_Group1617 = ' ' HRI_Group1617 = 'No Contact'.
exe.


* Correct some codings where individuals dies after moving LA. If no contact can assume stayed in same LA..
if HRI_Group1516 = "Died" and HRI_Group1415 = "Not in LA" HRI_Group1516 = "Not in LA".
if HRI_Group1617 = "Died" and HRI_Group1516 = "Not in LA" HRI_Group1617 = "Not in LA".
if HRI_Group1718 = "Died" and HRI_Group1617 = "Not in LA" HRI_Group1718 = "Not in LA".
exe.


* Remove Costs data for those not in LA.
if HRI_Group1617 = "Not in LA" health_net_cost1617 = 0.
if HRI_Group1415 = "Not in LA" health_net_cost1415 = 0.
if HRI_Group1516 = "Not in LA" health_net_cost1516 = 0.
if HRI_Group1718 = "Not in LA" health_net_cost1718 = 0.
exe.

* Remove Costs data for those Died before start of FY.
if HRI_Group1516 = "Died" health_net_cost1516 = 0.
if HRI_Group1415 = "Died" health_net_cost1415 = 0.
if HRI_Group1617 = "Died" health_net_cost1617 = 0.
if HRI_Group1718 = "Died" health_net_cost1718 = 0.
exe.


compute LCA_Select = x.
exe.

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
exe.


string PathwayLKP (A100).
exe.

compute PathwayLKP = concat(rtrim(HRI_Group1415), rtrim(HRI_Group1516), rtrim(HRI_Group1617), rtrim(HRI_Group1718)).
exe.

save outfile  = !OFilesL + 'temp_HRI_LAT2.sav'.

* Agg Age.
get file  = !OFilesL + 'temp_HRI_LAT1.sav'.

select if AgeBand = "All".
select if  GenderSTR NE "Both".
exe.

string PathwayLKP (A100).

compute PathwayLKP = concat(rtrim(HRI_Group1415), rtrim(HRI_Group1516), rtrim(HRI_Group1617), rtrim(HRI_Group1718)).
exe.

save outfile  = !OFilesL + 'temp_HRI_LAT3.sav'.

* Agg Gender.
get file  = !OFilesL + 'temp_HRI_LAT1.sav'.

select if GenderSTR = "Both".
select if AgeBand NE "All".
exe.

string PathwayLKP (A100).
exe.


compute PathwayLKP = concat(rtrim(HRI_Group1415), rtrim(HRI_Group1516), rtrim(HRI_Group1617), rtrim(HRI_Group1718)).
exe. 

save outfile  = !OFilesL + 'temp_HRI_LAT4.sav'.

* Agg Age & Gender.
get file  = !OFilesL + 'temp_HRI_LAT1.sav'.

select if  GenderSTR = "Both".
select if AgeBand = "All".
exe.

string PathwayLKP (A100).

compute PathwayLKP = concat(rtrim(HRI_Group1415), rtrim(HRI_Group1516), rtrim(HRI_Group1617), rtrim(HRI_Group1718)).
exe. 

save outfile  = !OFilesL + 'temp_HRI_LAT5.sav'.

*bring files togther.
add files file = !OFilesL + 'temp_HRI_LAT2.sav'
/file = !OFilesL + 'temp_HRI_LAT3.sav'
/file = !OFilesL + 'temp_HRI_LAT4.sav'
/file = !OFilesL + 'temp_HRI_LAT5.sav'.
exe.

*Remove all spaces from PathwayLKP.
COMPUTE PathwayLKP = REPLACE(PathwayLKP, " ", "").
exe.

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
compute PathwayLKP = concat(STRING (LCA_Select,F8),PathwayLKP).
exe.
*Remove all spaces from PathwayLKP.
COMPUTE PathwayLKP = REPLACE(PathwayLKP, " ", "").
exe.
* Create a Pathway Label for use in Tableau.
string PathwayLabel (A100).

compute PathwayLabel = concat(HRI_Group1415, ' - ', HRI_Group1516, ' - ', HRI_Group1617, HRI_Group1718, ' - ').
exe.

* Need to save out Pathway lookup to match on the original CHIMASTER level data.
save outfile  = !OFilesL + 'temp_HRI_LA_ALLYR_CHI2.sav'
/keep chi LCA_select PathwayLKP PathwayLabel HRI_Group1617 HRI_Group1718 HRI_Group1415 HRI_Group1516 Remove.

* Remove mis-match records.
select if Remove NE 1.
exe.

AGGREGATE
  /OUTFILE=*
  /BREAK=LCA_Select genderSTR AgeBand HRI_Group1617 HRI_Group1718 HRI_Group1415 HRI_Group1516 PathwayLKP PathwayLabel
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

save outfile  = !OFilesL + 'temp_HRI_LA_ALLYR2.sav'.

** LA 3.
get file  = !OFilesL + 'temp_HRI_LA_MASTER_ALLYR.sav'.

* Set LA.
compute x = 3.
exe.

* Identify selected individuals in selected LA.

compute LCAFlag = 0.
if LCA1617 = x LCAFlag = 1.
if LCA1718 = x LCAFlag = 1.
if LCA1415 = x LCAFlag = 1.
if LCA1516 = x LCAFlag = 1.

select if LCAFlag = 1.
exe.
 
* Identify any individuals that wheren't in selected area.
if lca1617 ne x HRI_Group1617 = 'Not in LA'.
if lca1718 ne x HRI_Group1718 = 'Not in LA'.
if lca1415 ne x HRI_Group1415 = 'Not in LA'.
if lca1516 ne x HRI_Group1516 = 'Not in LA'.
exe.

* Add death marker.
if date_death < 20170401 HRI_Group1718 = 'Died'.
if date_death < 20160401 HRI_Group1617 = 'Died'.
if date_death < 20150401 HRI_Group1516 = 'Died'.
if date_death > 20170401 and HRI_Group1718 = ' ' HRI_Group1718 = 'Died'.
exe.


* Assume any blanks are now showing no contact in year.
if HRI_Group1718 = ' ' HRI_Group1718 = 'No Contact'.
if HRI_Group1415 = ' ' HRI_Group1415 = 'No Contact'.
if HRI_Group1516 = ' ' HRI_Group1516 = 'No Contact'.
if HRI_Group1617 = ' ' HRI_Group1617 = 'No Contact'.
exe.


* Correct some codings where individuals dies after moving LA. If no contact can assume stayed in same LA..
if HRI_Group1516 = "Died" and HRI_Group1415 = "Not in LA" HRI_Group1516 = "Not in LA".
if HRI_Group1617 = "Died" and HRI_Group1516 = "Not in LA" HRI_Group1617 = "Not in LA".
if HRI_Group1718 = "Died" and HRI_Group1617 = "Not in LA" HRI_Group1718 = "Not in LA".
exe.


* Remove Costs data for those not in LA.
if HRI_Group1516 = "Not in LA" health_net_cost1516 = 0.
if HRI_Group1415 = "Not in LA" health_net_cost1415 = 0.
if HRI_Group1617 = "Not in LA" health_net_cost1617 = 0.
if HRI_Group1718 = "Not in LA" health_net_cost1718 = 0.
exe.

* Remove Costs data for those Died before start of FY.
if HRI_Group1516 = "Died" health_net_cost1516 = 0.
if HRI_Group1415 = "Died" health_net_cost1415 = 0.
if HRI_Group1617 = "Died" health_net_cost1617 = 0.
if HRI_Group1718 = "Died" health_net_cost1718 = 0.
exe.

compute LCA_Select = x.
EXE.

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
EXE.


string PathwayLKP (A100).
exe.

compute PathwayLKP = concat(rtrim(HRI_Group1415), rtrim(HRI_Group1516), rtrim(HRI_Group1617), rtrim(HRI_Group1718)).
exe. 

save outfile  = !OFilesL + 'temp_HRI_LAT2.sav'.

* Agg Age.
get file  = !OFilesL + 'temp_HRI_LAT1.sav'.

select if AgeBand = "All".
select if  GenderSTR NE "Both".
exe.

string PathwayLKP (A100).

compute PathwayLKP = concat(rtrim(HRI_Group1415), rtrim(HRI_Group1516), rtrim(HRI_Group1617), rtrim(HRI_Group1718)).
exe. 

save outfile  = !OFilesL + 'temp_HRI_LAT3.sav'.

* Agg Gender.
get file  = !OFilesL + 'temp_HRI_LAT1.sav'.

select if GenderSTR = "Both".
select if AgeBand NE "All".
exe.

string PathwayLKP (A100).
exe.


compute PathwayLKP = concat(rtrim(HRI_Group1415), rtrim(HRI_Group1516), rtrim(HRI_Group1617), rtrim(HRI_Group1718)).
exe. 

save outfile  = !OFilesL + 'temp_HRI_LAT4.sav'.

* Agg Age & Gender.
get file  = !OFilesL + 'temp_HRI_LAT1.sav'.

select if  GenderSTR = "Both".
select if AgeBand = "All".
exe.

string PathwayLKP (A100).

compute PathwayLKP = concat(rtrim(HRI_Group1415), rtrim(HRI_Group1516), rtrim(HRI_Group1617), rtrim(HRI_Group1718)).
exe.

save outfile  = !OFilesL + 'temp_HRI_LAT5.sav'.

*bring files togther.
add files file = !OFilesL + 'temp_HRI_LAT2.sav'
/file = !OFilesL + 'temp_HRI_LAT3.sav'
/file = !OFilesL + 'temp_HRI_LAT4.sav'
/file = !OFilesL + 'temp_HRI_LAT5.sav'.
exe.

*Remove all spaces from PathwayLKP.
COMPUTE PathwayLKP = REPLACE(PathwayLKP, " ", "").
exe.

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
compute PathwayLKP = concat(STRING (LCA_Select,F8),PathwayLKP).
exe.
*Remove all spaces from PathwayLKP.
COMPUTE PathwayLKP = REPLACE(PathwayLKP, " ", "").
exe.
* Create a Pathway Label for use in Tableau.
string PathwayLabel (A100).

compute PathwayLabel = concat(HRI_Group1415, ' - ', HRI_Group1516, ' - ', HRI_Group1617, HRI_Group1718, ' - ').
exe.

* Need to save out Pathway lookup to match on the original CHIMASTER level data.
save outfile  = !OFilesL + 'temp_HRI_LA_ALLYR_CHI3.sav'
/keep chi LCA_select PathwayLKP PathwayLabel HRI_Group1617 HRI_Group1718 HRI_Group1415 HRI_Group1516 Remove.

* Remove mis-match records.
select if Remove NE 1.
exe.

AGGREGATE
  /OUTFILE=*
  /BREAK=LCA_Select genderSTR AgeBand HRI_Group1617 HRI_Group1718 HRI_Group1415 HRI_Group1516 PathwayLKP PathwayLabel
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

save outfile  = !OFilesL + 'temp_HRI_LA_ALLYR3.sav'.

** LA 4.
get file  = !OFilesL + 'temp_HRI_LA_MASTER_ALLYR.sav'.

* Set LA.
compute x = 4.
exe.

* Identify selected individuals in selected LA.

compute LCAFlag = 0.
if LCA1617 = x LCAFlag = 1.
if LCA1718 = x LCAFlag = 1.
if LCA1415 = x LCAFlag = 1.
if LCA1516 = x LCAFlag = 1.

select if LCAFlag = 1.
exe.
 
* Identify any individuals that wheren't in selected area.
if lca1617 ne x HRI_Group1617 = 'Not in LA'.
if lca1718 ne x HRI_Group1718 = 'Not in LA'.
if lca1415 ne x HRI_Group1415 = 'Not in LA'.
if lca1516 ne x HRI_Group1516 = 'Not in LA'.
exe.

* Add death marker.
if date_death < 20170401 HRI_Group1718 = 'Died'.
if date_death < 20160401 HRI_Group1617 = 'Died'.
if date_death < 20150401 HRI_Group1516 = 'Died'.
if date_death > 20170401 and HRI_Group1718 = ' ' HRI_Group1718 = 'Died'.
exe.


* Assume any blanks are now showing no contact in year.
if HRI_Group1718 = ' ' HRI_Group1718 = 'No Contact'.
if HRI_Group1415 = ' ' HRI_Group1415 = 'No Contact'.
if HRI_Group1516 = ' ' HRI_Group1516 = 'No Contact'.
if HRI_Group1617 = ' ' HRI_Group1617 = 'No Contact'.
exe.


* Correct some codings where individuals dies after moving LA. If no contact can assume stayed in same LA..
if HRI_Group1516 = "Died" and HRI_Group1415 = "Not in LA" HRI_Group1516 = "Not in LA".
if HRI_Group1617 = "Died" and HRI_Group1516 = "Not in LA" HRI_Group1617 = "Not in LA".
if HRI_Group1718 = "Died" and HRI_Group1617 = "Not in LA" HRI_Group1718 = "Not in LA".
exe.



* Remove Costs data for those not in LA.
if HRI_Group1516 = "Not in LA" health_net_cost1516 = 0.
if HRI_Group1415 = "Not in LA" health_net_cost1415 = 0.
if HRI_Group1718 = "Not in LA" health_net_cost1718 = 0.
if HRI_Group1617 = "Not in LA" health_net_cost1617 = 0.
exe.

* Remove Costs data for those Died before start of FY.
if HRI_Group1516 = "Died" health_net_cost1516 = 0.
if HRI_Group1415 = "Died" health_net_cost1415 = 0.
if HRI_Group1718 = "Died" health_net_cost1718 = 0.
if HRI_Group1617 = "Died" health_net_cost1617 = 0.
exe.


compute LCA_Select = x.
exe.
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
exe.


string PathwayLKP (A100).
exe.

compute PathwayLKP = concat(rtrim(HRI_Group1415), rtrim(HRI_Group1516), rtrim(HRI_Group1617), rtrim(HRI_Group1718)).
exe. 

save outfile  = !OFilesL + 'temp_HRI_LAT2.sav'.

* Agg Age.
get file  = !OFilesL + 'temp_HRI_LAT1.sav'.

select if AgeBand = "All".
select if  GenderSTR NE "Both".
exe.

string PathwayLKP (A100).

compute PathwayLKP = concat(rtrim(HRI_Group1415), rtrim(HRI_Group1516), rtrim(HRI_Group1617), rtrim(HRI_Group1718)).
exe. 

save outfile  = !OFilesL + 'temp_HRI_LAT3.sav'.

* Agg Gender.
get file  = !OFilesL + 'temp_HRI_LAT1.sav'.

select if GenderSTR = "Both".
select if AgeBand NE "All".
exe.

string PathwayLKP (A100).
exe.


compute PathwayLKP = concat(rtrim(HRI_Group1415), rtrim(HRI_Group1516), rtrim(HRI_Group1617), rtrim(HRI_Group1718)).
exe. 

save outfile  = !OFilesL + 'temp_HRI_LAT4.sav'.

* Agg Age & Gender.
get file  = !OFilesL + 'temp_HRI_LAT1.sav'.

select if  GenderSTR = "Both".
select if AgeBand = "All".
exe.

string PathwayLKP (A100).

compute PathwayLKP = concat(rtrim(HRI_Group1415), rtrim(HRI_Group1516), rtrim(HRI_Group1617), rtrim(HRI_Group1718)).
exe. 

save outfile  = !OFilesL + 'temp_HRI_LAT5.sav'.

*bring files togther.
add files file = !OFilesL + 'temp_HRI_LAT2.sav'
/file = !OFilesL + 'temp_HRI_LAT3.sav'
/file = !OFilesL + 'temp_HRI_LAT4.sav'
/file = !OFilesL + 'temp_HRI_LAT5.sav'.
exe.

*Remove all spaces from PathwayLKP.
COMPUTE PathwayLKP = REPLACE(PathwayLKP, " ", "").
exe.

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
compute PathwayLKP = concat(STRING (LCA_Select,F8),PathwayLKP).
exe.
*Remove all spaces from PathwayLKP.
COMPUTE PathwayLKP = REPLACE(PathwayLKP, " ", "").
exe.
* Create a Pathway Label for use in Tableau.
string PathwayLabel (A100).

compute PathwayLabel = concat(HRI_Group1415, ' - ', HRI_Group1516, ' - ', HRI_Group1617, HRI_Group1718, ' - ').
exe.

* Need to save out Pathway lookup to match on the original CHIMASTER level data.
save outfile  = !OFilesL + 'temp_HRI_LA_ALLYR_CHI4.sav'
/keep chi LCA_select PathwayLKP PathwayLabel HRI_Group1617 HRI_Group1718 HRI_Group1415 HRI_Group1516 Remove.

* Remove mis-match records.
select if Remove NE 1.
exe.

AGGREGATE
  /OUTFILE=*
  /BREAK=LCA_Select genderSTR AgeBand HRI_Group1617 HRI_Group1718 HRI_Group1415 HRI_Group1516 PathwayLKP PathwayLabel
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

save outfile  = !OFilesL + 'temp_HRI_LA_ALLYR4.sav'.

** LA 5.
get file  = !OFilesL + 'temp_HRI_LA_MASTER_ALLYR.sav'.

* Set LA.
compute x = 5.
exe.

* Identify selected individuals in selected LA.

compute LCAFlag = 0.
if LCA1617 = x LCAFlag = 1.
if LCA1718 = x LCAFlag = 1.
if LCA1415 = x LCAFlag = 1.
if LCA1516 = x LCAFlag = 1.

select if LCAFlag = 1.
exe.
 
* Identify any individuals that wheren't in selected area.
if lca1617 ne x HRI_Group1617 = 'Not in LA'.
if lca1718 ne x HRI_Group1718 = 'Not in LA'.
if lca1415 ne x HRI_Group1415 = 'Not in LA'.
if lca1516 ne x HRI_Group1516 = 'Not in LA'.
exe.

* Add death marker.
if date_death < 20170401 HRI_Group1718 = 'Died'.
if date_death < 20160401 HRI_Group1617 = 'Died'.
if date_death < 20150401 HRI_Group1516 = 'Died'.
if date_death > 20170401 and HRI_Group1718 = ' ' HRI_Group1718 = 'Died'.
EXE.


* Assume any blanks are now showing no contact in year.
if HRI_Group1516 = ' ' HRI_Group1516 = 'No Contact'.
if HRI_Group1415 = ' ' HRI_Group1415 = 'No Contact'.
if HRI_Group1718 = ' ' HRI_Group1718 = 'No Contact'.
if HRI_Group1617 = ' ' HRI_Group1617 = 'No Contact'.
EXE.


* Correct some codings where individuals dies after moving LA. If no contact can assume stayed in same LA..
if HRI_Group1516 = "Died" and HRI_Group1415 = "Not in LA" HRI_Group1516 = "Not in LA".
if HRI_Group1617 = "Died" and HRI_Group1516 = "Not in LA" HRI_Group1617 = "Not in LA".
if HRI_Group1718 = "Died" and HRI_Group1617 = "Not in LA" HRI_Group1718 = "Not in LA".
EXE.



* Remove Costs data for those not in LA.
if HRI_Group1516 = "Not in LA" health_net_cost1516 = 0.
if HRI_Group1415 = "Not in LA" health_net_cost1415 = 0.
if HRI_Group1718 = "Not in LA" health_net_cost1718 = 0.
if HRI_Group1617 = "Not in LA" health_net_cost1617 = 0.
EXE.

* Remove Costs data for those Died before start of FY.
if HRI_Group1516 = "Died" health_net_cost1516 = 0.
if HRI_Group1415 = "Died" health_net_cost1415 = 0.
if HRI_Group1718 = "Died" health_net_cost1718 = 0.
if HRI_Group1617 = "Died" health_net_cost1617 = 0.
EXE.


compute LCA_Select = x.
EXE.

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
EXE.


string PathwayLKP (A100).
exe.

compute PathwayLKP = concat(rtrim(HRI_Group1415), rtrim(HRI_Group1516), rtrim(HRI_Group1617), rtrim(HRI_Group1718)).
exe. 

save outfile  = !OFilesL + 'temp_HRI_LAT2.sav'.

* Agg Age.
get file  = !OFilesL + 'temp_HRI_LAT1.sav'.

select if AgeBand = "All".
select if  GenderSTR NE "Both".
EXE.

string PathwayLKP (A100).

compute PathwayLKP = concat(rtrim(HRI_Group1415), rtrim(HRI_Group1516), rtrim(HRI_Group1617), rtrim(HRI_Group1718)).
exe. 

save outfile  = !OFilesL + 'temp_HRI_LAT3.sav'.

* Agg Gender.
get file  = !OFilesL + 'temp_HRI_LAT1.sav'.

select if GenderSTR = "Both".
select if AgeBand NE "All".
EXE.

string PathwayLKP (A100).
exe.


compute PathwayLKP = concat(rtrim(HRI_Group1415), rtrim(HRI_Group1516), rtrim(HRI_Group1617), rtrim(HRI_Group1718)).
exe. 

save outfile  = !OFilesL + 'temp_HRI_LAT4.sav'.

* Agg Age & Gender.
get file  = !OFilesL + 'temp_HRI_LAT1.sav'.

select if  GenderSTR = "Both".
select if AgeBand = "All".
EXE.

string PathwayLKP (A100).

compute PathwayLKP = concat(rtrim(HRI_Group1415), rtrim(HRI_Group1516), rtrim(HRI_Group1617), rtrim(HRI_Group1718)).
exe. 

save outfile  = !OFilesL + 'temp_HRI_LAT5.sav'.

*bring files togther.
add files file = !OFilesL + 'temp_HRI_LAT2.sav'
/file = !OFilesL + 'temp_HRI_LAT3.sav'
/file = !OFilesL + 'temp_HRI_LAT4.sav'
/file = !OFilesL + 'temp_HRI_LAT5.sav'.
EXE.

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
compute PathwayLKP = concat(STRING (LCA_Select,F8),PathwayLKP).
EXE.
*Remove all spaces from PathwayLKP.
COMPUTE PathwayLKP = REPLACE(PathwayLKP, " ", "").
EXE.
* Create a Pathway Label for use in Tableau.
string PathwayLabel (A100).

compute PathwayLabel = concat(HRI_Group1415, ' - ', HRI_Group1516, ' - ', HRI_Group1617, HRI_Group1718, ' - ').
exe. 

* Need to save out Pathway lookup to match on the original CHIMASTER level data.
save outfile  = !OFilesL + 'temp_HRI_LA_ALLYR_CHI5.sav'
/keep chi LCA_select PathwayLKP PathwayLabel HRI_Group1617 HRI_Group1718 HRI_Group1415 HRI_Group1516 Remove.

* Remove mis-match records.
select if Remove NE 1.
exe.

AGGREGATE
  /OUTFILE=*
  /BREAK=LCA_Select genderSTR AgeBand HRI_Group1617 HRI_Group1718 HRI_Group1415 HRI_Group1516 PathwayLKP PathwayLabel
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

save outfile  = !OFilesL + 'temp_HRI_LA_ALLYR5.sav'.

** LA 6.
get file  = !OFilesL + 'temp_HRI_LA_MASTER_ALLYR.sav'.

* Set LA.
compute x = 6.
EXE.

* Identify selected individuals in selected LA.

compute LCAFlag = 0.
if LCA1617 = x LCAFlag = 1.
if LCA1718 = x LCAFlag = 1.
if LCA1415 = x LCAFlag = 1.
if LCA1516 = x LCAFlag = 1.

select if LCAFlag = 1.
EXE.
 
* Identify any individuals that wheren't in selected area.
if lca1617 ne x HRI_Group1617 = 'Not in LA'.
if lca1718 ne x HRI_Group1718 = 'Not in LA'.
if lca1415 ne x HRI_Group1415 = 'Not in LA'.
if lca1516 ne x HRI_Group1516 = 'Not in LA'.
exe.

* Add death marker.
if date_death < 20170401 HRI_Group1718 = 'Died'.
if date_death < 20160401 HRI_Group1617 = 'Died'.
if date_death < 20150401 HRI_Group1516 = 'Died'.
if date_death > 20170401 and HRI_Group1718 = ' ' HRI_Group1718 = 'Died'.
EXE.


* Assume any blanks are now showing no contact in year.
if HRI_Group1516 = ' ' HRI_Group1516 = 'No Contact'.
if HRI_Group1415 = ' ' HRI_Group1415 = 'No Contact'.
if HRI_Group1718 = ' ' HRI_Group1718 = 'No Contact'.
if HRI_Group1617 = ' ' HRI_Group1617 = 'No Contact'.
EXE.


* Correct some codings where individuals dies after moving LA. If no contact can assume stayed in same LA..
if HRI_Group1516 = "Died" and HRI_Group1415 = "Not in LA" HRI_Group1516 = "Not in LA".
if HRI_Group1617 = "Died" and HRI_Group1516 = "Not in LA" HRI_Group1617 = "Not in LA".
if HRI_Group1718 = "Died" and HRI_Group1617 = "Not in LA" HRI_Group1718 = "Not in LA".
EXE.


* Remove Costs data for those not in LA.
if HRI_Group1516 = "Not in LA" health_net_cost1516 = 0.
if HRI_Group1415 = "Not in LA" health_net_cost1415 = 0.
if HRI_Group1718 = "Not in LA" health_net_cost1718 = 0.
if HRI_Group1617 = "Not in LA" health_net_cost1617 = 0.
EXE.

* Remove Costs data for those Died before start of FY.
if HRI_Group1516 = "Died" health_net_cost1516 = 0.
if HRI_Group1415 = "Died" health_net_cost1415 = 0.
if HRI_Group1718 = "Died" health_net_cost1718 = 0.
if HRI_Group1617 = "Died" health_net_cost1617 = 0.
EXE.


compute LCA_Select = x.
EXE.

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
EXE.


string PathwayLKP (A100).
exe.

compute PathwayLKP = concat(rtrim(HRI_Group1415), rtrim(HRI_Group1516), rtrim(HRI_Group1617), rtrim(HRI_Group1718)).
exe. 

save outfile  = !OFilesL + 'temp_HRI_LAT2.sav'.

* Agg Age.
get file  = !OFilesL + 'temp_HRI_LAT1.sav'.

select if AgeBand = "All".
select if  GenderSTR NE "Both".
EXE.

string PathwayLKP (A100).

compute PathwayLKP = concat(rtrim(HRI_Group1415), rtrim(HRI_Group1516), rtrim(HRI_Group1617), rtrim(HRI_Group1718)).
exe. 

save outfile  = !OFilesL + 'temp_HRI_LAT3.sav'.

* Agg Gender.
get file  = !OFilesL + 'temp_HRI_LAT1.sav'.

select if GenderSTR = "Both".
select if AgeBand NE "All".
EXE.

string PathwayLKP (A100).
exe.


compute PathwayLKP = concat(rtrim(HRI_Group1415), rtrim(HRI_Group1516), rtrim(HRI_Group1617), rtrim(HRI_Group1718)).
exe. 

save outfile  = !OFilesL + 'temp_HRI_LAT4.sav'.

* Agg Age & Gender.
get file  = !OFilesL + 'temp_HRI_LAT1.sav'.

select if  GenderSTR = "Both".
select if AgeBand = "All".
EXE.

string PathwayLKP (A100).

compute PathwayLKP = concat(rtrim(HRI_Group1415), rtrim(HRI_Group1516), rtrim(HRI_Group1617), rtrim(HRI_Group1718)).
exe. 

save outfile  = !OFilesL + 'temp_HRI_LAT5.sav'.

*bring files togther.
add files file = !OFilesL + 'temp_HRI_LAT2.sav'
/file = !OFilesL + 'temp_HRI_LAT3.sav'
/file = !OFilesL + 'temp_HRI_LAT4.sav'
/file = !OFilesL + 'temp_HRI_LAT5.sav'.
EXE.

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
compute PathwayLKP = concat(STRING (LCA_Select,F8),PathwayLKP).
EXE.
*Remove all spaces from PathwayLKP.
COMPUTE PathwayLKP = REPLACE(PathwayLKP, " ", "").
EXE.
* Create a Pathway Label for use in Tableau.
string PathwayLabel (A100).

compute PathwayLabel = concat(HRI_Group1415, ' - ', HRI_Group1516, ' - ', HRI_Group1617, HRI_Group1718, ' - ').
exe. 

* Need to save out Pathway lookup to match on the original CHIMASTER level data.
save outfile  = !OFilesL + 'temp_HRI_LA_ALLYR_CHI6.sav'
/keep chi LCA_select PathwayLKP PathwayLabel HRI_Group1617 HRI_Group1718 HRI_Group1415 HRI_Group1516 remove.

* Remove mis-match records.
select if Remove NE 1.
exe.

AGGREGATE
  /OUTFILE=*
  /BREAK=LCA_Select genderSTR AgeBand HRI_Group1617 HRI_Group1718 HRI_Group1415 HRI_Group1516 PathwayLKP PathwayLabel
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

save outfile  = !OFilesL + 'temp_HRI_LA_ALLYR6.sav'.

** LA 7.
get file  = !OFilesL + 'temp_HRI_LA_MASTER_ALLYR.sav'.

* Set LA.
compute x = 7.
EXE.

* Identify selected individuals in selected LA.

compute LCAFlag = 0.
if LCA1617 = x LCAFlag = 1.
if LCA1718 = x LCAFlag = 1.
if LCA1415 = x LCAFlag = 1.
if LCA1516 = x LCAFlag = 1.

select if LCAFlag = 1.
EXE.
 
* Identify any individuals that wheren't in selected area.
if lca1617 ne x HRI_Group1617 = 'Not in LA'.
if lca1718 ne x HRI_Group1718 = 'Not in LA'.
if lca1415 ne x HRI_Group1415 = 'Not in LA'.
if lca1516 ne x HRI_Group1516 = 'Not in LA'.
exe.

* Add death marker.
if date_death < 20170401 HRI_Group1718 = 'Died'.
if date_death < 20160401 HRI_Group1617 = 'Died'.
if date_death < 20150401 HRI_Group1516 = 'Died'.
if date_death > 20170401 and HRI_Group1718 = ' ' HRI_Group1718 = 'Died'.
EXE.


* Assume any blanks are now showing no contact in year.
if HRI_Group1516 = ' ' HRI_Group1516 = 'No Contact'.
if HRI_Group1415 = ' ' HRI_Group1415 = 'No Contact'.
if HRI_Group1718 = ' ' HRI_Group1718 = 'No Contact'.
if HRI_Group1617 = ' ' HRI_Group1617 = 'No Contact'.
EXE.


* Correct some codings where individuals dies after moving LA. If no contact can assume stayed in same LA..
if HRI_Group1516 = "Died" and HRI_Group1415 = "Not in LA" HRI_Group1516 = "Not in LA".
if HRI_Group1617 = "Died" and HRI_Group1516 = "Not in LA" HRI_Group1617 = "Not in LA".
if HRI_Group1718 = "Died" and HRI_Group1617 = "Not in LA" HRI_Group1718 = "Not in LA".
EXE.


* Remove Costs data for those not in LA.
if HRI_Group1516 = "Not in LA" health_net_cost1516 = 0.
if HRI_Group1415 = "Not in LA" health_net_cost1415 = 0.
if HRI_Group1718 = "Not in LA" health_net_cost1718 = 0.
if HRI_Group1617 = "Not in LA" health_net_cost1617 = 0.
EXE.

* Remove Costs data for those Died before start of FY.
if HRI_Group1516 = "Died" health_net_cost1516 = 0.
if HRI_Group1415 = "Died" health_net_cost1415 = 0.
if HRI_Group1718 = "Died" health_net_cost1718 = 0.
if HRI_Group1617 = "Died" health_net_cost1617 = 0.
EXE.


compute LCA_Select = x.
EXE.

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
EXE.


string PathwayLKP (A100).
exe.

compute PathwayLKP = concat(rtrim(HRI_Group1415), rtrim(HRI_Group1516), rtrim(HRI_Group1617), rtrim(HRI_Group1718)).
exe. 

save outfile  = !OFilesL + 'temp_HRI_LAT2.sav'.

* Agg Age.
get file  = !OFilesL + 'temp_HRI_LAT1.sav'.

select if AgeBand = "All".
select if  GenderSTR NE "Both".
EXE.

string PathwayLKP (A100).

compute PathwayLKP = concat(rtrim(HRI_Group1415), rtrim(HRI_Group1516), rtrim(HRI_Group1617), rtrim(HRI_Group1718)).
exe. 

save outfile  = !OFilesL + 'temp_HRI_LAT3.sav'.

* Agg Gender.
get file  = !OFilesL + 'temp_HRI_LAT1.sav'.

select if GenderSTR = "Both".
select if AgeBand NE "All".
EXE.

string PathwayLKP (A100).
exe.


compute PathwayLKP = concat(rtrim(HRI_Group1415), rtrim(HRI_Group1516), rtrim(HRI_Group1617), rtrim(HRI_Group1718)).
exe. 

save outfile  = !OFilesL + 'temp_HRI_LAT4.sav'.

* Agg Age & Gender.
get file  = !OFilesL + 'temp_HRI_LAT1.sav'.

select if  GenderSTR = "Both".
select if AgeBand = "All".
EXE.

string PathwayLKP (A100).

compute PathwayLKP = concat(rtrim(HRI_Group1415), rtrim(HRI_Group1516), rtrim(HRI_Group1617), rtrim(HRI_Group1718)).
exe. 

save outfile  = !OFilesL + 'temp_HRI_LAT5.sav'.

*bring files togther.
add files file = !OFilesL + 'temp_HRI_LAT2.sav'
/file = !OFilesL + 'temp_HRI_LAT3.sav'
/file = !OFilesL + 'temp_HRI_LAT4.sav'
/file = !OFilesL + 'temp_HRI_LAT5.sav'.
EXE.

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
compute PathwayLKP = concat(STRING (LCA_Select,F8),PathwayLKP).
EXE.
*Remove all spaces from PathwayLKP.
COMPUTE PathwayLKP = REPLACE(PathwayLKP, " ", "").
EXE.
* Create a Pathway Label for use in Tableau.
string PathwayLabel (A100).

compute PathwayLabel = concat(HRI_Group1415, ' - ', HRI_Group1516, ' - ', HRI_Group1617, HRI_Group1718, ' - ').
exe. 

* Need to save out Pathway lookup to match on the original CHIMASTER level data.
save outfile  = !OFilesL + 'temp_HRI_LA_ALLYR_CHI7.sav'
/keep chi LCA_select PathwayLKP PathwayLabel HRI_Group1617 HRI_Group1718 HRI_Group1415 HRI_Group1516 remove.

* Remove mis-match records.
select if Remove NE 1.
exe.

AGGREGATE
  /OUTFILE=*
  /BREAK=LCA_Select genderSTR AgeBand HRI_Group1617 HRI_Group1718 HRI_Group1415 HRI_Group1516 PathwayLKP PathwayLabel
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

save outfile  = !OFilesL + 'temp_HRI_LA_ALLYR7.sav'.

** LA 8.
get file  = !OFilesL + 'temp_HRI_LA_MASTER_ALLYR.sav'.



* Set LA.
compute x = 8.
EXE.

* Identify selected individuals in selected LA.

compute LCAFlag = 0.
if LCA1617 = x LCAFlag = 1.
if LCA1718 = x LCAFlag = 1.
if LCA1415 = x LCAFlag = 1.
if LCA1516 = x LCAFlag = 1.

select if LCAFlag = 1.
EXE.
 
* Identify any individuals that wheren't in selected area.
if lca1617 ne x HRI_Group1617 = 'Not in LA'.
if lca1718 ne x HRI_Group1718 = 'Not in LA'.
if lca1415 ne x HRI_Group1415 = 'Not in LA'.
if lca1516 ne x HRI_Group1516 = 'Not in LA'.
exe.

* Add death marker.
if date_death < 20170401 HRI_Group1718 = 'Died'.
if date_death < 20160401 HRI_Group1617 = 'Died'.
if date_death < 20150401 HRI_Group1516 = 'Died'.
if date_death > 20170401 and HRI_Group1718 = ' ' HRI_Group1718 = 'Died'.
EXE.


* Assume any blanks are now showing no contact in year.
if HRI_Group1516 = ' ' HRI_Group1516 = 'No Contact'.
if HRI_Group1415 = ' ' HRI_Group1415 = 'No Contact'.
if HRI_Group1718 = ' ' HRI_Group1718 = 'No Contact'.
if HRI_Group1617 = ' ' HRI_Group1617 = 'No Contact'.
EXE.


* Correct some codings where individuals dies after moving LA. If no contact can assume stayed in same LA..
if HRI_Group1516 = "Died" and HRI_Group1415 = "Not in LA" HRI_Group1516 = "Not in LA".
if HRI_Group1617 = "Died" and HRI_Group1516 = "Not in LA" HRI_Group1617 = "Not in LA".
if HRI_Group1718 = "Died" and HRI_Group1617 = "Not in LA" HRI_Group1718 = "Not in LA".
EXE.


* Remove Costs data for those not in LA.
if HRI_Group1516 = "Not in LA" health_net_cost1516 = 0.
if HRI_Group1415 = "Not in LA" health_net_cost1415 = 0.
if HRI_Group1718 = "Not in LA" health_net_cost1718 = 0.
if HRI_Group1617 = "Not in LA" health_net_cost1617 = 0.
EXE.

* Remove Costs data for those Died before start of FY.
if HRI_Group1516 = "Died" health_net_cost1516 = 0.
if HRI_Group1415 = "Died" health_net_cost1415 = 0.
if HRI_Group1718 = "Died" health_net_cost1718 = 0.
if HRI_Group1617 = "Died" health_net_cost1617 = 0.
EXE.


compute LCA_Select = x.
EXE.

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
EXE.


string PathwayLKP (A100).
exe.

compute PathwayLKP = concat(rtrim(HRI_Group1415), rtrim(HRI_Group1516), rtrim(HRI_Group1617), rtrim(HRI_Group1718)).
exe. 

save outfile  = !OFilesL + 'temp_HRI_LAT2.sav'.

* Agg Age.
get file  = !OFilesL + 'temp_HRI_LAT1.sav'.

select if AgeBand = "All".
select if  GenderSTR NE "Both".
EXE.

string PathwayLKP (A100).

compute PathwayLKP = concat(rtrim(HRI_Group1415), rtrim(HRI_Group1516), rtrim(HRI_Group1617), rtrim(HRI_Group1718)).
exe. 

save outfile  = !OFilesL + 'temp_HRI_LAT3.sav'.

* Agg Gender.
get file  = !OFilesL + 'temp_HRI_LAT1.sav'.

select if GenderSTR = "Both".
select if AgeBand NE "All".
EXE.

string PathwayLKP (A100).
exe.


compute PathwayLKP = concat(rtrim(HRI_Group1415), rtrim(HRI_Group1516), rtrim(HRI_Group1617), rtrim(HRI_Group1718)).
exe. 

save outfile  = !OFilesL + 'temp_HRI_LAT4.sav'.

* Agg Age & Gender.
get file  = !OFilesL + 'temp_HRI_LAT1.sav'.

select if  GenderSTR = "Both".
select if AgeBand = "All".
EXE.

string PathwayLKP (A100).

compute PathwayLKP = concat(rtrim(HRI_Group1415), rtrim(HRI_Group1516), rtrim(HRI_Group1617), rtrim(HRI_Group1718)).
exe. 

save outfile  = !OFilesL + 'temp_HRI_LAT5.sav'.

*bring files togther.
add files file = !OFilesL + 'temp_HRI_LAT2.sav'
/file = !OFilesL + 'temp_HRI_LAT3.sav'
/file = !OFilesL + 'temp_HRI_LAT4.sav'
/file = !OFilesL + 'temp_HRI_LAT5.sav'.
EXE.

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
compute PathwayLKP = concat(STRING (LCA_Select,F8),PathwayLKP).
EXE.
*Remove all spaces from PathwayLKP.
COMPUTE PathwayLKP = REPLACE(PathwayLKP, " ", "").
EXE.
* Create a Pathway Label for use in Tableau.
string PathwayLabel (A100).

compute PathwayLabel = concat(HRI_Group1415, ' - ', HRI_Group1516, ' - ', HRI_Group1617, HRI_Group1718, ' - ').
exe. 

* Need to save out Pathway lookup to match on the original CHIMASTER level data.
save outfile  = !OFilesL + 'temp_HRI_LA_ALLYR_CHI8.sav'
/keep chi LCA_select PathwayLKP PathwayLabel HRI_Group1617 HRI_Group1718 HRI_Group1415 HRI_Group1516 remove.

* Remove mis-match records.
select if Remove NE 1.
exe.

AGGREGATE
  /OUTFILE=*
  /BREAK=LCA_Select genderSTR AgeBand HRI_Group1617 HRI_Group1718 HRI_Group1415 HRI_Group1516 PathwayLKP PathwayLabel
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

save outfile  = !OFilesL + 'temp_HRI_LA_ALLYR8.sav'.

** LA 9.
get file  = !OFilesL + 'temp_HRI_LA_MASTER_ALLYR.sav'.

* Set LA.
compute x = 9.
EXE.
* Identify selected individuals in selected LA.

compute LCAFlag = 0.
if LCA1617 = x LCAFlag = 1.
if LCA1718 = x LCAFlag = 1.
if LCA1415 = x LCAFlag = 1.
if LCA1516 = x LCAFlag = 1.

select if LCAFlag = 1.
EXE.
 
* Identify any individuals that wheren't in selected area.
if lca1617 ne x HRI_Group1617 = 'Not in LA'.
if lca1718 ne x HRI_Group1718 = 'Not in LA'.
if lca1415 ne x HRI_Group1415 = 'Not in LA'.
if lca1516 ne x HRI_Group1516 = 'Not in LA'.
exe.

* Add death marker.
if date_death < 20170401 HRI_Group1718 = 'Died'.
if date_death < 20160401 HRI_Group1617 = 'Died'.
if date_death < 20150401 HRI_Group1516 = 'Died'.
if date_death > 20170401 and HRI_Group1718 = ' ' HRI_Group1718 = 'Died'.
EXE.


* Assume any blanks are now showing no contact in year.
if HRI_Group1516 = ' ' HRI_Group1516 = 'No Contact'.
if HRI_Group1415 = ' ' HRI_Group1415 = 'No Contact'.
if HRI_Group1718 = ' ' HRI_Group1718 = 'No Contact'.
if HRI_Group1617 = ' ' HRI_Group1617 = 'No Contact'.
EXE.


* Correct some codings where individuals dies after moving LA. If no contact can assume stayed in same LA..
if HRI_Group1516 = "Died" and HRI_Group1415 = "Not in LA" HRI_Group1516 = "Not in LA".
if HRI_Group1617 = "Died" and HRI_Group1516 = "Not in LA" HRI_Group1617 = "Not in LA".
if HRI_Group1718 = "Died" and HRI_Group1617 = "Not in LA" HRI_Group1718 = "Not in LA".
EXE.


* Remove Costs data for those not in LA.
if HRI_Group1516 = "Not in LA" health_net_cost1516 = 0.
if HRI_Group1415 = "Not in LA" health_net_cost1415 = 0.
if HRI_Group1718 = "Not in LA" health_net_cost1718 = 0.
if HRI_Group1617 = "Not in LA" health_net_cost1617 = 0.
EXE.

* Remove Costs data for those Died before start of FY.
if HRI_Group1516 = "Died" health_net_cost1516 = 0.
if HRI_Group1415 = "Died" health_net_cost1415 = 0.
if HRI_Group1718 = "Died" health_net_cost1718 = 0.
if HRI_Group1617 = "Died" health_net_cost1617 = 0.
EXE.


compute LCA_Select = x.
EXE.

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
EXE.


string PathwayLKP (A100).
exe.

compute PathwayLKP = concat(rtrim(HRI_Group1415), rtrim(HRI_Group1516), rtrim(HRI_Group1617), rtrim(HRI_Group1718)).
exe. 

save outfile  = !OFilesL + 'temp_HRI_LAT2.sav'.

* Agg Age.
get file  = !OFilesL + 'temp_HRI_LAT1.sav'.

select if AgeBand = "All".
select if  GenderSTR NE "Both".
EXE.

string PathwayLKP (A100).

compute PathwayLKP = concat(rtrim(HRI_Group1415), rtrim(HRI_Group1516), rtrim(HRI_Group1617), rtrim(HRI_Group1718)).
exe. 

save outfile  = !OFilesL + 'temp_HRI_LAT3.sav'.

* Agg Gender.
get file  = !OFilesL + 'temp_HRI_LAT1.sav'.

select if GenderSTR = "Both".
select if AgeBand NE "All".
EXE.

string PathwayLKP (A100).
exe.


compute PathwayLKP = concat(rtrim(HRI_Group1415), rtrim(HRI_Group1516), rtrim(HRI_Group1617), rtrim(HRI_Group1718)).
exe. 

save outfile  = !OFilesL + 'temp_HRI_LAT4.sav'.

* Agg Age & Gender.
get file  = !OFilesL + 'temp_HRI_LAT1.sav'.

select if  GenderSTR = "Both".
select if AgeBand = "All".
EXE.

string PathwayLKP (A100).

compute PathwayLKP = concat(rtrim(HRI_Group1415), rtrim(HRI_Group1516), rtrim(HRI_Group1617), rtrim(HRI_Group1718)).
exe. 

save outfile  = !OFilesL + 'temp_HRI_LAT5.sav'.

*bring files togther.
add files file = !OFilesL + 'temp_HRI_LAT2.sav'
/file = !OFilesL + 'temp_HRI_LAT3.sav'
/file = !OFilesL + 'temp_HRI_LAT4.sav'
/file = !OFilesL + 'temp_HRI_LAT5.sav'.
EXE.

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
compute PathwayLKP = concat(STRING (LCA_Select,F8),PathwayLKP).
EXE.
*Remove all spaces from PathwayLKP.
COMPUTE PathwayLKP = REPLACE(PathwayLKP, " ", "").
EXE.
* Create a Pathway Label for use in Tableau.
string PathwayLabel (A100).

compute PathwayLabel = concat(HRI_Group1415, ' - ', HRI_Group1516, ' - ', HRI_Group1617, HRI_Group1718, ' - ').
exe. 

* Need to save out Pathway lookup to match on the original CHIMASTER level data.
save outfile  = !OFilesL + 'temp_HRI_LA_ALLYR_CHI9.sav'
/keep chi LCA_select PathwayLKP PathwayLabel HRI_Group1617 HRI_Group1718 HRI_Group1415 HRI_Group1516 remove.

* Remove mis-match records.
select if Remove NE 1.
exe.

AGGREGATE
  /OUTFILE=*
  /BREAK=LCA_Select genderSTR AgeBand HRI_Group1617 HRI_Group1718 HRI_Group1415 HRI_Group1516 PathwayLKP PathwayLabel
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

save outfile  = !OFilesL + 'temp_HRI_LA_ALLYR9.sav'.

** LA 10.
get file  = !OFilesL + 'temp_HRI_LA_MASTER_ALLYR.sav'.

* Set LA.
compute x = 10.
EXE.

* Identify selected individuals in selected LA.

compute LCAFlag = 0.
if LCA1617 = x LCAFlag = 1.
if LCA1718 = x LCAFlag = 1.
if LCA1415 = x LCAFlag = 1.
if LCA1516 = x LCAFlag = 1.

select if LCAFlag = 1.
EXE.
 
* Identify any individuals that wheren't in selected area.
if lca1617 ne x HRI_Group1617 = 'Not in LA'.
if lca1718 ne x HRI_Group1718 = 'Not in LA'.
if lca1415 ne x HRI_Group1415 = 'Not in LA'.
if lca1516 ne x HRI_Group1516 = 'Not in LA'.
exe.

* Add death marker.
if date_death < 20170401 HRI_Group1718 = 'Died'.
if date_death < 20160401 HRI_Group1617 = 'Died'.
if date_death < 20150401 HRI_Group1516 = 'Died'.
if date_death > 20170401 and HRI_Group1718 = ' ' HRI_Group1718 = 'Died'.
EXE.


* Assume any blanks are now showing no contact in year.
if HRI_Group1516 = ' ' HRI_Group1516 = 'No Contact'.
if HRI_Group1415 = ' ' HRI_Group1415 = 'No Contact'.
if HRI_Group1718 = ' ' HRI_Group1718 = 'No Contact'.
if HRI_Group1617 = ' ' HRI_Group1617 = 'No Contact'.
EXE.


* Correct some codings where individuals dies after moving LA. If no contact can assume stayed in same LA..
if HRI_Group1516 = "Died" and HRI_Group1415 = "Not in LA" HRI_Group1516 = "Not in LA".
if HRI_Group1617 = "Died" and HRI_Group1516 = "Not in LA" HRI_Group1617 = "Not in LA".
if HRI_Group1718 = "Died" and HRI_Group1617 = "Not in LA" HRI_Group1718 = "Not in LA".
EXE.


* Remove Costs data for those not in LA.
if HRI_Group1516 = "Not in LA" health_net_cost1516 = 0.
if HRI_Group1415 = "Not in LA" health_net_cost1415 = 0.
if HRI_Group1718 = "Not in LA" health_net_cost1718 = 0.
if HRI_Group1617 = "Not in LA" health_net_cost1617 = 0.
EXE.

* Remove Costs data for those Died before start of FY.
if HRI_Group1516 = "Died" health_net_cost1516 = 0.
if HRI_Group1415 = "Died" health_net_cost1415 = 0.
if HRI_Group1718 = "Died" health_net_cost1718 = 0.
if HRI_Group1617 = "Died" health_net_cost1617 = 0.
EXE.


compute LCA_Select = x.
EXE.

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
EXE.


string PathwayLKP (A100).
exe.

compute PathwayLKP = concat(rtrim(HRI_Group1415), rtrim(HRI_Group1516), rtrim(HRI_Group1617), rtrim(HRI_Group1718)).
exe. 

save outfile  = !OFilesL + 'temp_HRI_LAT2.sav'.

* Agg Age.
get file  = !OFilesL + 'temp_HRI_LAT1.sav'.

select if AgeBand = "All".
select if  GenderSTR NE "Both".
EXE.

string PathwayLKP (A100).

compute PathwayLKP = concat(rtrim(HRI_Group1415), rtrim(HRI_Group1516), rtrim(HRI_Group1617), rtrim(HRI_Group1718)).
exe. 

save outfile  = !OFilesL + 'temp_HRI_LAT3.sav'.

* Agg Gender.
get file  = !OFilesL + 'temp_HRI_LAT1.sav'.

select if GenderSTR = "Both".
select if AgeBand NE "All".
EXE.

string PathwayLKP (A100).
exe.


compute PathwayLKP = concat(rtrim(HRI_Group1415), rtrim(HRI_Group1516), rtrim(HRI_Group1617), rtrim(HRI_Group1718)).
exe. 

save outfile  = !OFilesL + 'temp_HRI_LAT4.sav'.

* Agg Age & Gender.
get file  = !OFilesL + 'temp_HRI_LAT1.sav'.

select if  GenderSTR = "Both".
select if AgeBand = "All".
EXE.

string PathwayLKP (A100).

compute PathwayLKP = concat(rtrim(HRI_Group1415), rtrim(HRI_Group1516), rtrim(HRI_Group1617), rtrim(HRI_Group1718)).
exe. 

save outfile  = !OFilesL + 'temp_HRI_LAT5.sav'.

*bring files togther.
add files file = !OFilesL + 'temp_HRI_LAT2.sav'
/file = !OFilesL + 'temp_HRI_LAT3.sav'
/file = !OFilesL + 'temp_HRI_LAT4.sav'
/file = !OFilesL + 'temp_HRI_LAT5.sav'.
EXE.

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
compute PathwayLKP = concat(STRING (LCA_Select,F8),PathwayLKP).
EXE.
*Remove all spaces from PathwayLKP.
COMPUTE PathwayLKP = REPLACE(PathwayLKP, " ", "").
EXE.
* Create a Pathway Label for use in Tableau.
string PathwayLabel (A100).

compute PathwayLabel = concat(HRI_Group1415, ' - ', HRI_Group1516, ' - ', HRI_Group1617, HRI_Group1718, ' - ').
exe. 

* Need to save out Pathway lookup to match on the original CHIMASTER level data.
save outfile  = !OFilesL + 'temp_HRI_LA_ALLYR_CHI10.sav'
/keep chi LCA_select PathwayLKP PathwayLabel HRI_Group1617 HRI_Group1718 HRI_Group1415 HRI_Group1516 remove.

* Remove mis-match records.
select if Remove NE 1.
exe.

AGGREGATE
  /OUTFILE=*
  /BREAK=LCA_Select genderSTR AgeBand HRI_Group1617 HRI_Group1718 HRI_Group1415 HRI_Group1516 PathwayLKP PathwayLabel
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

save outfile  = !OFilesL + 'temp_HRI_LA_ALLYR10.sav'.

** LA 11.
get file  = !OFilesL + 'temp_HRI_LA_MASTER_ALLYR.sav'.
* Set LA.
compute x = 11.
EXE.

* Identify selected individuals in selected LA.

compute LCAFlag = 0.
if LCA1617 = x LCAFlag = 1.
if LCA1718 = x LCAFlag = 1.
if LCA1415 = x LCAFlag = 1.
if LCA1516 = x LCAFlag = 1.

select if LCAFlag = 1.
EXE.
 
* Identify any individuals that wheren't in selected area.
if lca1617 ne x HRI_Group1617 = 'Not in LA'.
if lca1718 ne x HRI_Group1718 = 'Not in LA'.
if lca1415 ne x HRI_Group1415 = 'Not in LA'.
if lca1516 ne x HRI_Group1516 = 'Not in LA'.
exe.

* Add death marker.
if date_death < 20170401 HRI_Group1718 = 'Died'.
if date_death < 20160401 HRI_Group1617 = 'Died'.
if date_death < 20150401 HRI_Group1516 = 'Died'.
if date_death > 20170401 and HRI_Group1718 = ' ' HRI_Group1718 = 'Died'.
EXE.


* Assume any blanks are now showing no contact in year.
if HRI_Group1516 = ' ' HRI_Group1516 = 'No Contact'.
if HRI_Group1415 = ' ' HRI_Group1415 = 'No Contact'.
if HRI_Group1718 = ' ' HRI_Group1718 = 'No Contact'.
if HRI_Group1617 = ' ' HRI_Group1617 = 'No Contact'.
EXE.


* Correct some codings where individuals dies after moving LA. If no contact can assume stayed in same LA..
if HRI_Group1516 = "Died" and HRI_Group1415 = "Not in LA" HRI_Group1516 = "Not in LA".
if HRI_Group1617 = "Died" and HRI_Group1516 = "Not in LA" HRI_Group1617 = "Not in LA".
if HRI_Group1718 = "Died" and HRI_Group1617 = "Not in LA" HRI_Group1718 = "Not in LA".
EXE.


* Remove Costs data for those not in LA.
if HRI_Group1516 = "Not in LA" health_net_cost1516 = 0.
if HRI_Group1415 = "Not in LA" health_net_cost1415 = 0.
if HRI_Group1718 = "Not in LA" health_net_cost1718 = 0.
if HRI_Group1617 = "Not in LA" health_net_cost1617 = 0.
EXE.

* Remove Costs data for those Died before start of FY.
if HRI_Group1516 = "Died" health_net_cost1516 = 0.
if HRI_Group1415 = "Died" health_net_cost1415 = 0.
if HRI_Group1718 = "Died" health_net_cost1718 = 0.
if HRI_Group1617 = "Died" health_net_cost1617 = 0.
EXE.


compute LCA_Select = x.
EXE.

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
EXE.


string PathwayLKP (A100).
exe.

compute PathwayLKP = concat(rtrim(HRI_Group1415), rtrim(HRI_Group1516), rtrim(HRI_Group1617), rtrim(HRI_Group1718)).
exe. 

save outfile  = !OFilesL + 'temp_HRI_LAT2.sav'.

* Agg Age.
get file  = !OFilesL + 'temp_HRI_LAT1.sav'.

select if AgeBand = "All".
select if  GenderSTR NE "Both".
EXE.

string PathwayLKP (A100).

compute PathwayLKP = concat(rtrim(HRI_Group1415), rtrim(HRI_Group1516), rtrim(HRI_Group1617), rtrim(HRI_Group1718)).
exe. 

save outfile  = !OFilesL + 'temp_HRI_LAT3.sav'.

* Agg Gender.
get file  = !OFilesL + 'temp_HRI_LAT1.sav'.

select if GenderSTR = "Both".
select if AgeBand NE "All".
EXE.

string PathwayLKP (A100).
exe.


compute PathwayLKP = concat(rtrim(HRI_Group1415), rtrim(HRI_Group1516), rtrim(HRI_Group1617), rtrim(HRI_Group1718)).
exe. 

save outfile  = !OFilesL + 'temp_HRI_LAT4.sav'.

* Agg Age & Gender.
get file  = !OFilesL + 'temp_HRI_LAT1.sav'.

select if  GenderSTR = "Both".
select if AgeBand = "All".
EXE.

string PathwayLKP (A100).

compute PathwayLKP = concat(rtrim(HRI_Group1415), rtrim(HRI_Group1516), rtrim(HRI_Group1617), rtrim(HRI_Group1718)).
exe. 

save outfile  = !OFilesL + 'temp_HRI_LAT5.sav'.

*bring files togther.
add files file = !OFilesL + 'temp_HRI_LAT2.sav'
/file = !OFilesL + 'temp_HRI_LAT3.sav'
/file = !OFilesL + 'temp_HRI_LAT4.sav'
/file = !OFilesL + 'temp_HRI_LAT5.sav'.
EXE.

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
compute PathwayLKP = concat(STRING (LCA_Select,F8),PathwayLKP).
EXE.
*Remove all spaces from PathwayLKP.
COMPUTE PathwayLKP = REPLACE(PathwayLKP, " ", "").
EXE.
* Create a Pathway Label for use in Tableau.
string PathwayLabel (A100).

compute PathwayLabel = concat(HRI_Group1415, ' - ', HRI_Group1516, ' - ', HRI_Group1617, HRI_Group1718, ' - ').
exe. 

* Need to save out Pathway lookup to match on the original CHIMASTER level data.
save outfile  = !OFilesL + 'temp_HRI_LA_ALLYR_CHI11.sav'
/keep chi LCA_select PathwayLKP PathwayLabel HRI_Group1617 HRI_Group1718 HRI_Group1415 HRI_Group1516 remove.

* Remove mis-match records.
select if Remove NE 1.
exe.

AGGREGATE
  /OUTFILE=*
  /BREAK=LCA_Select genderSTR AgeBand HRI_Group1617 HRI_Group1718 HRI_Group1415 HRI_Group1516 PathwayLKP PathwayLabel
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

save outfile  = !OFilesL + 'temp_HRI_LA_ALLYR11.sav'.

** LA 12.
get file  = !OFilesL + 'temp_HRI_LA_MASTER_ALLYR.sav'.

* Set LA.
compute x = 12.
EXE.

* Identify selected individuals in selected LA.

compute LCAFlag = 0.
if LCA1617 = x LCAFlag = 1.
if LCA1718 = x LCAFlag = 1.
if LCA1415 = x LCAFlag = 1.
if LCA1516 = x LCAFlag = 1.

select if LCAFlag = 1.
EXE.
 
* Identify any individuals that wheren't in selected area.
if lca1617 ne x HRI_Group1617 = 'Not in LA'.
if lca1718 ne x HRI_Group1718 = 'Not in LA'.
if lca1415 ne x HRI_Group1415 = 'Not in LA'.
if lca1516 ne x HRI_Group1516 = 'Not in LA'.
exe.

* Add death marker.
if date_death < 20170401 HRI_Group1718 = 'Died'.
if date_death < 20160401 HRI_Group1617 = 'Died'.
if date_death < 20150401 HRI_Group1516 = 'Died'.
if date_death > 20170401 and HRI_Group1718 = ' ' HRI_Group1718 = 'Died'.
EXE.


* Assume any blanks are now showing no contact in year.
if HRI_Group1516 = ' ' HRI_Group1516 = 'No Contact'.
if HRI_Group1415 = ' ' HRI_Group1415 = 'No Contact'.
if HRI_Group1718 = ' ' HRI_Group1718 = 'No Contact'.
if HRI_Group1617 = ' ' HRI_Group1617 = 'No Contact'.
EXE.


* Correct some codings where individuals dies after moving LA. If no contact can assume stayed in same LA..
if HRI_Group1516 = "Died" and HRI_Group1415 = "Not in LA" HRI_Group1516 = "Not in LA".
if HRI_Group1617 = "Died" and HRI_Group1516 = "Not in LA" HRI_Group1617 = "Not in LA".
if HRI_Group1718 = "Died" and HRI_Group1617 = "Not in LA" HRI_Group1718 = "Not in LA".
EXE.


* Remove Costs data for those not in LA.
if HRI_Group1516 = "Not in LA" health_net_cost1516 = 0.
if HRI_Group1415 = "Not in LA" health_net_cost1415 = 0.
if HRI_Group1718 = "Not in LA" health_net_cost1718 = 0.
if HRI_Group1617 = "Not in LA" health_net_cost1617 = 0.
EXE.

* Remove Costs data for those Died before start of FY.
if HRI_Group1516 = "Died" health_net_cost1516 = 0.
if HRI_Group1415 = "Died" health_net_cost1415 = 0.
if HRI_Group1718 = "Died" health_net_cost1718 = 0.
if HRI_Group1617 = "Died" health_net_cost1617 = 0.
EXE.


compute LCA_Select = x.
EXE.

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
EXE.


string PathwayLKP (A100).
exe.

compute PathwayLKP = concat(rtrim(HRI_Group1415), rtrim(HRI_Group1516), rtrim(HRI_Group1617), rtrim(HRI_Group1718)).
exe. 

save outfile  = !OFilesL + 'temp_HRI_LAT2.sav'.

* Agg Age.
get file  = !OFilesL + 'temp_HRI_LAT1.sav'.

select if AgeBand = "All".
select if  GenderSTR NE "Both".
EXE.

string PathwayLKP (A100).

compute PathwayLKP = concat(rtrim(HRI_Group1415), rtrim(HRI_Group1516), rtrim(HRI_Group1617), rtrim(HRI_Group1718)).
exe. 

save outfile  = !OFilesL + 'temp_HRI_LAT3.sav'.

* Agg Gender.
get file  = !OFilesL + 'temp_HRI_LAT1.sav'.

select if GenderSTR = "Both".
select if AgeBand NE "All".
EXE.

string PathwayLKP (A100).
exe.


compute PathwayLKP = concat(rtrim(HRI_Group1415), rtrim(HRI_Group1516), rtrim(HRI_Group1617), rtrim(HRI_Group1718)).
exe. 

save outfile  = !OFilesL + 'temp_HRI_LAT4.sav'.

* Agg Age & Gender.
get file  = !OFilesL + 'temp_HRI_LAT1.sav'.

select if  GenderSTR = "Both".
select if AgeBand = "All".
EXE.

string PathwayLKP (A100).

compute PathwayLKP = concat(rtrim(HRI_Group1415), rtrim(HRI_Group1516), rtrim(HRI_Group1617), rtrim(HRI_Group1718)).
exe. 

save outfile  = !OFilesL + 'temp_HRI_LAT5.sav'.

*bring files togther.
add files file = !OFilesL + 'temp_HRI_LAT2.sav'
/file = !OFilesL + 'temp_HRI_LAT3.sav'
/file = !OFilesL + 'temp_HRI_LAT4.sav'
/file = !OFilesL + 'temp_HRI_LAT5.sav'.
EXE.

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
compute PathwayLKP = concat(STRING (LCA_Select,F8),PathwayLKP).
EXE.
*Remove all spaces from PathwayLKP.
COMPUTE PathwayLKP = REPLACE(PathwayLKP, " ", "").
EXE.
* Create a Pathway Label for use in Tableau.
string PathwayLabel (A100).

compute PathwayLabel = concat(HRI_Group1415, ' - ', HRI_Group1516, ' - ', HRI_Group1617, HRI_Group1718, ' - ').
exe. 

* Need to save out Pathway lookup to match on the original CHIMASTER level data.
save outfile  = !OFilesL + 'temp_HRI_LA_ALLYR_CHI12.sav'
/keep chi LCA_select PathwayLKP PathwayLabel HRI_Group1617 HRI_Group1718 HRI_Group1415 HRI_Group1516 remove.

* Remove mis-match records.
select if Remove NE 1.
exe.

AGGREGATE
  /OUTFILE=*
  /BREAK=LCA_Select genderSTR AgeBand HRI_Group1617 HRI_Group1718 HRI_Group1415 HRI_Group1516 PathwayLKP PathwayLabel
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

save outfile  = !OFilesL + 'temp_HRI_LA_ALLYR12.sav'.

** LA 13.
get file  = !OFilesL + 'temp_HRI_LA_MASTER_ALLYR.sav'.

* Set LA.
compute x = 13.
EXE.

* Identify selected individuals in selected LA.

compute LCAFlag = 0.
if LCA1617 = x LCAFlag = 1.
if LCA1718 = x LCAFlag = 1.
if LCA1415 = x LCAFlag = 1.
if LCA1516 = x LCAFlag = 1.

select if LCAFlag = 1.
EXE.
 
* Identify any individuals that wheren't in selected area.
if lca1617 ne x HRI_Group1617 = 'Not in LA'.
if lca1718 ne x HRI_Group1718 = 'Not in LA'.
if lca1415 ne x HRI_Group1415 = 'Not in LA'.
if lca1516 ne x HRI_Group1516 = 'Not in LA'.
exe.

* Add death marker.
if date_death < 20170401 HRI_Group1718 = 'Died'.
if date_death < 20160401 HRI_Group1617 = 'Died'.
if date_death < 20150401 HRI_Group1516 = 'Died'.
if date_death > 20170401 and HRI_Group1718 = ' ' HRI_Group1718 = 'Died'.
EXE.


* Assume any blanks are now showing no contact in year.
if HRI_Group1516 = ' ' HRI_Group1516 = 'No Contact'.
if HRI_Group1415 = ' ' HRI_Group1415 = 'No Contact'.
if HRI_Group1718 = ' ' HRI_Group1718 = 'No Contact'.
if HRI_Group1617 = ' ' HRI_Group1617 = 'No Contact'.
EXE.


* Correct some codings where individuals dies after moving LA. If no contact can assume stayed in same LA..
if HRI_Group1516 = "Died" and HRI_Group1415 = "Not in LA" HRI_Group1516 = "Not in LA".
if HRI_Group1617 = "Died" and HRI_Group1516 = "Not in LA" HRI_Group1617 = "Not in LA".
if HRI_Group1718 = "Died" and HRI_Group1617 = "Not in LA" HRI_Group1718 = "Not in LA".
EXE.


* Remove Costs data for those not in LA.
if HRI_Group1516 = "Not in LA" health_net_cost1516 = 0.
if HRI_Group1415 = "Not in LA" health_net_cost1415 = 0.
if HRI_Group1718 = "Not in LA" health_net_cost1718 = 0.
if HRI_Group1617 = "Not in LA" health_net_cost1617 = 0.
EXE.

* Remove Costs data for those Died before start of FY.
if HRI_Group1516 = "Died" health_net_cost1516 = 0.
if HRI_Group1415 = "Died" health_net_cost1415 = 0.
if HRI_Group1718 = "Died" health_net_cost1718 = 0.
if HRI_Group1617 = "Died" health_net_cost1617 = 0.
EXE.


compute LCA_Select = x.
EXE.

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
EXE.


string PathwayLKP (A100).
exe.

compute PathwayLKP = concat(rtrim(HRI_Group1415), rtrim(HRI_Group1516), rtrim(HRI_Group1617), rtrim(HRI_Group1718)).
exe. 

save outfile  = !OFilesL + 'temp_HRI_LAT2.sav'.

* Agg Age.
get file  = !OFilesL + 'temp_HRI_LAT1.sav'.

select if AgeBand = "All".
select if  GenderSTR NE "Both".
EXE.

string PathwayLKP (A100).

compute PathwayLKP = concat(rtrim(HRI_Group1415), rtrim(HRI_Group1516), rtrim(HRI_Group1617), rtrim(HRI_Group1718)).
exe. 

save outfile  = !OFilesL + 'temp_HRI_LAT3.sav'.

* Agg Gender.
get file  = !OFilesL + 'temp_HRI_LAT1.sav'.

select if GenderSTR = "Both".
select if AgeBand NE "All".
EXE.

string PathwayLKP (A100).
exe.


compute PathwayLKP = concat(rtrim(HRI_Group1415), rtrim(HRI_Group1516), rtrim(HRI_Group1617), rtrim(HRI_Group1718)).
exe. 

save outfile  = !OFilesL + 'temp_HRI_LAT4.sav'.

* Agg Age & Gender.
get file  = !OFilesL + 'temp_HRI_LAT1.sav'.

select if  GenderSTR = "Both".
select if AgeBand = "All".
EXE.

string PathwayLKP (A100).

compute PathwayLKP = concat(rtrim(HRI_Group1415), rtrim(HRI_Group1516), rtrim(HRI_Group1617), rtrim(HRI_Group1718)).
exe. 

save outfile  = !OFilesL + 'temp_HRI_LAT5.sav'.

*bring files togther.
add files file = !OFilesL + 'temp_HRI_LAT2.sav'
/file = !OFilesL + 'temp_HRI_LAT3.sav'
/file = !OFilesL + 'temp_HRI_LAT4.sav'
/file = !OFilesL + 'temp_HRI_LAT5.sav'.
EXE.

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
compute PathwayLKP = concat(STRING (LCA_Select,F8),PathwayLKP).
EXE.
*Remove all spaces from PathwayLKP.
COMPUTE PathwayLKP = REPLACE(PathwayLKP, " ", "").
EXE.
* Create a Pathway Label for use in Tableau.
string PathwayLabel (A100).

compute PathwayLabel = concat(HRI_Group1415, ' - ', HRI_Group1516, ' - ', HRI_Group1617, HRI_Group1718, ' - ').
exe. 

* Need to save out Pathway lookup to match on the original CHIMASTER level data.
save outfile  = !OFilesL + 'temp_HRI_LA_ALLYR_CHI13.sav'
/keep chi LCA_select PathwayLKP PathwayLabel HRI_Group1617 HRI_Group1718 HRI_Group1415 HRI_Group1516 remove.

* Remove mis-match records.
select if Remove NE 1.
exe.

AGGREGATE
  /OUTFILE=*
  /BREAK=LCA_Select genderSTR AgeBand HRI_Group1617 HRI_Group1718 HRI_Group1415 HRI_Group1516 PathwayLKP PathwayLabel
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

save outfile  = !OFilesL + 'temp_HRI_LA_ALLYR13.sav'.

** LA 14.
get file  = !OFilesL + 'temp_HRI_LA_MASTER_ALLYR.sav'.

* Set LA.
compute x = 14.
EXE.

* Identify selected individuals in selected LA.

compute LCAFlag = 0.
if LCA1617 = x LCAFlag = 1.
if LCA1718 = x LCAFlag = 1.
if LCA1415 = x LCAFlag = 1.
if LCA1516 = x LCAFlag = 1.

select if LCAFlag = 1.
EXE.
 
* Identify any individuals that wheren't in selected area.
if lca1617 ne x HRI_Group1617 = 'Not in LA'.
if lca1718 ne x HRI_Group1718 = 'Not in LA'.
if lca1415 ne x HRI_Group1415 = 'Not in LA'.
if lca1516 ne x HRI_Group1516 = 'Not in LA'.
exe.

* Add death marker.
if date_death < 20170401 HRI_Group1718 = 'Died'.
if date_death < 20160401 HRI_Group1617 = 'Died'.
if date_death < 20150401 HRI_Group1516 = 'Died'.
if date_death > 20170401 and HRI_Group1718 = ' ' HRI_Group1718 = 'Died'.
EXE.


* Assume any blanks are now showing no contact in year.
if HRI_Group1516 = ' ' HRI_Group1516 = 'No Contact'.
if HRI_Group1415 = ' ' HRI_Group1415 = 'No Contact'.
if HRI_Group1718 = ' ' HRI_Group1718 = 'No Contact'.
if HRI_Group1617 = ' ' HRI_Group1617 = 'No Contact'.
EXE.


* Correct some codings where individuals dies after moving LA. If no contact can assume stayed in same LA..
if HRI_Group1516 = "Died" and HRI_Group1415 = "Not in LA" HRI_Group1516 = "Not in LA".
if HRI_Group1617 = "Died" and HRI_Group1516 = "Not in LA" HRI_Group1617 = "Not in LA".
if HRI_Group1718 = "Died" and HRI_Group1617 = "Not in LA" HRI_Group1718 = "Not in LA".
EXE.


* Remove Costs data for those not in LA.
if HRI_Group1516 = "Not in LA" health_net_cost1516 = 0.
if HRI_Group1415 = "Not in LA" health_net_cost1415 = 0.
if HRI_Group1718 = "Not in LA" health_net_cost1718 = 0.
if HRI_Group1617 = "Not in LA" health_net_cost1617 = 0.
EXE.

* Remove Costs data for those Died before start of FY.
if HRI_Group1516 = "Died" health_net_cost1516 = 0.
if HRI_Group1415 = "Died" health_net_cost1415 = 0.
if HRI_Group1718 = "Died" health_net_cost1718 = 0.
if HRI_Group1617 = "Died" health_net_cost1617 = 0.
EXE.


compute LCA_Select = x.
EXE.

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
EXE.


string PathwayLKP (A100).
exe.

compute PathwayLKP = concat(rtrim(HRI_Group1415), rtrim(HRI_Group1516), rtrim(HRI_Group1617), rtrim(HRI_Group1718)).
exe. 

save outfile  = !OFilesL + 'temp_HRI_LAT2.sav'.

* Agg Age.
get file  = !OFilesL + 'temp_HRI_LAT1.sav'.

select if AgeBand = "All".
select if  GenderSTR NE "Both".
EXE.

string PathwayLKP (A100).

compute PathwayLKP = concat(rtrim(HRI_Group1415), rtrim(HRI_Group1516), rtrim(HRI_Group1617), rtrim(HRI_Group1718)).
exe. 

save outfile  = !OFilesL + 'temp_HRI_LAT3.sav'.

* Agg Gender.
get file  = !OFilesL + 'temp_HRI_LAT1.sav'.

select if GenderSTR = "Both".
select if AgeBand NE "All".
EXE.

string PathwayLKP (A100).
exe.


compute PathwayLKP = concat(rtrim(HRI_Group1415), rtrim(HRI_Group1516), rtrim(HRI_Group1617), rtrim(HRI_Group1718)).
exe. 

save outfile  = !OFilesL + 'temp_HRI_LAT4.sav'.

* Agg Age & Gender.
get file  = !OFilesL + 'temp_HRI_LAT1.sav'.

select if  GenderSTR = "Both".
select if AgeBand = "All".
EXE.

string PathwayLKP (A100).

compute PathwayLKP = concat(rtrim(HRI_Group1415), rtrim(HRI_Group1516), rtrim(HRI_Group1617), rtrim(HRI_Group1718)).
exe. 

save outfile  = !OFilesL + 'temp_HRI_LAT5.sav'.

*bring files togther.
add files file = !OFilesL + 'temp_HRI_LAT2.sav'
/file = !OFilesL + 'temp_HRI_LAT3.sav'
/file = !OFilesL + 'temp_HRI_LAT4.sav'
/file = !OFilesL + 'temp_HRI_LAT5.sav'.
EXE.

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
compute PathwayLKP = concat(STRING (LCA_Select,F8),PathwayLKP).
EXE.
*Remove all spaces from PathwayLKP.
COMPUTE PathwayLKP = REPLACE(PathwayLKP, " ", "").
EXE.
* Create a Pathway Label for use in Tableau.
string PathwayLabel (A100).

compute PathwayLabel = concat(HRI_Group1415, ' - ', HRI_Group1516, ' - ', HRI_Group1617, HRI_Group1718, ' - ').
exe. 

* Need to save out Pathway lookup to match on the original CHIMASTER level data.
save outfile  = !OFilesL + 'temp_HRI_LA_ALLYR_CHI14.sav'
/keep chi LCA_select PathwayLKP PathwayLabel HRI_Group1617 HRI_Group1718 HRI_Group1415 HRI_Group1516 remove.

* Remove mis-match records.
select if Remove NE 1.
exe.

AGGREGATE
  /OUTFILE=*
  /BREAK=LCA_Select genderSTR AgeBand HRI_Group1617 HRI_Group1718 HRI_Group1415 HRI_Group1516 PathwayLKP PathwayLabel
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


save outfile  = !OFilesL + 'temp_HRI_LA_ALLYR14.sav'.

** LA 15.
get file  = !OFilesL + 'temp_HRI_LA_MASTER_ALLYR.sav'.

* Set LA.
compute x = 15.
EXE.

* Identify selected individuals in selected LA.

compute LCAFlag = 0.
if LCA1617 = x LCAFlag = 1.
if LCA1718 = x LCAFlag = 1.
if LCA1415 = x LCAFlag = 1.
if LCA1516 = x LCAFlag = 1.

select if LCAFlag = 1.
EXE.
 
* Identify any individuals that wheren't in selected area.
if lca1617 ne x HRI_Group1617 = 'Not in LA'.
if lca1718 ne x HRI_Group1718 = 'Not in LA'.
if lca1415 ne x HRI_Group1415 = 'Not in LA'.
if lca1516 ne x HRI_Group1516 = 'Not in LA'.
exe.

* Add death marker.
if date_death < 20170401 HRI_Group1718 = 'Died'.
if date_death < 20160401 HRI_Group1617 = 'Died'.
if date_death < 20150401 HRI_Group1516 = 'Died'.
if date_death > 20170401 and HRI_Group1718 = ' ' HRI_Group1718 = 'Died'.
EXE.


* Assume any blanks are now showing no contact in year.
if HRI_Group1516 = ' ' HRI_Group1516 = 'No Contact'.
if HRI_Group1415 = ' ' HRI_Group1415 = 'No Contact'.
if HRI_Group1718 = ' ' HRI_Group1718 = 'No Contact'.
if HRI_Group1617 = ' ' HRI_Group1617 = 'No Contact'.
EXE.


* Correct some codings where individuals dies after moving LA. If no contact can assume stayed in same LA..
if HRI_Group1516 = "Died" and HRI_Group1415 = "Not in LA" HRI_Group1516 = "Not in LA".
if HRI_Group1617 = "Died" and HRI_Group1516 = "Not in LA" HRI_Group1617 = "Not in LA".
if HRI_Group1718 = "Died" and HRI_Group1617 = "Not in LA" HRI_Group1718 = "Not in LA".
EXE.


* Remove Costs data for those not in LA.
if HRI_Group1516 = "Not in LA" health_net_cost1516 = 0.
if HRI_Group1415 = "Not in LA" health_net_cost1415 = 0.
if HRI_Group1718 = "Not in LA" health_net_cost1718 = 0.
if HRI_Group1617 = "Not in LA" health_net_cost1617 = 0.
EXE.

* Remove Costs data for those Died before start of FY.
if HRI_Group1516 = "Died" health_net_cost1516 = 0.
if HRI_Group1415 = "Died" health_net_cost1415 = 0.
if HRI_Group1718 = "Died" health_net_cost1718 = 0.
if HRI_Group1617 = "Died" health_net_cost1617 = 0.
EXE.


compute LCA_Select = x.
EXE.

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
EXE.


string PathwayLKP (A100).
exe.

compute PathwayLKP = concat(rtrim(HRI_Group1415), rtrim(HRI_Group1516), rtrim(HRI_Group1617), rtrim(HRI_Group1718)).
exe. 

save outfile  = !OFilesL + 'temp_HRI_LAT2.sav'.

* Agg Age.
get file  = !OFilesL + 'temp_HRI_LAT1.sav'.

select if AgeBand = "All".
select if  GenderSTR NE "Both".
EXE.

string PathwayLKP (A100).

compute PathwayLKP = concat(rtrim(HRI_Group1415), rtrim(HRI_Group1516), rtrim(HRI_Group1617), rtrim(HRI_Group1718)).
exe. 

save outfile  = !OFilesL + 'temp_HRI_LAT3.sav'.

* Agg Gender.
get file  = !OFilesL + 'temp_HRI_LAT1.sav'.

select if GenderSTR = "Both".
select if AgeBand NE "All".
EXE.

string PathwayLKP (A100).
exe.


compute PathwayLKP = concat(rtrim(HRI_Group1415), rtrim(HRI_Group1516), rtrim(HRI_Group1617), rtrim(HRI_Group1718)).
exe. 

save outfile  = !OFilesL + 'temp_HRI_LAT4.sav'.

* Agg Age & Gender.
get file  = !OFilesL + 'temp_HRI_LAT1.sav'.

select if  GenderSTR = "Both".
select if AgeBand = "All".
EXE.

string PathwayLKP (A100).

compute PathwayLKP = concat(rtrim(HRI_Group1415), rtrim(HRI_Group1516), rtrim(HRI_Group1617), rtrim(HRI_Group1718)).
exe. 

save outfile  = !OFilesL + 'temp_HRI_LAT5.sav'.

*bring files togther.
add files file = !OFilesL + 'temp_HRI_LAT2.sav'
/file = !OFilesL + 'temp_HRI_LAT3.sav'
/file = !OFilesL + 'temp_HRI_LAT4.sav'
/file = !OFilesL + 'temp_HRI_LAT5.sav'.
EXE.

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
compute PathwayLKP = concat(STRING (LCA_Select,F8),PathwayLKP).
EXE.
*Remove all spaces from PathwayLKP.
COMPUTE PathwayLKP = REPLACE(PathwayLKP, " ", "").
EXE.
* Create a Pathway Label for use in Tableau.
string PathwayLabel (A100).

compute PathwayLabel = concat(HRI_Group1415, ' - ', HRI_Group1516, ' - ', HRI_Group1617, HRI_Group1718, ' - ').
exe. 

* Need to save out Pathway lookup to match on the original CHIMASTER level data.
save outfile  = !OFilesL + 'temp_HRI_LA_ALLYR_CHI15.sav'
/keep chi LCA_select PathwayLKP PathwayLabel HRI_Group1617 HRI_Group1718 HRI_Group1415 HRI_Group1516 remove.

* Remove mis-match records.
select if Remove NE 1.
exe.

AGGREGATE
  /OUTFILE=*
  /BREAK=LCA_Select genderSTR AgeBand HRI_Group1617 HRI_Group1718 HRI_Group1415 HRI_Group1516 PathwayLKP PathwayLabel
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
save outfile  = !OFilesL + 'temp_HRI_LA_ALLYR15.sav'.

** LA 16.
get file  = !OFilesL + 'temp_HRI_LA_MASTER_ALLYR.sav'.

* Set LA.
compute x = 16.
EXE.
* Identify selected individuals in selected LA.

compute LCAFlag = 0.
if LCA1617 = x LCAFlag = 1.
if LCA1718 = x LCAFlag = 1.
if LCA1415 = x LCAFlag = 1.
if LCA1516 = x LCAFlag = 1.

select if LCAFlag = 1.
EXE.
 
* Identify any individuals that wheren't in selected area.
if lca1617 ne x HRI_Group1617 = 'Not in LA'.
if lca1718 ne x HRI_Group1718 = 'Not in LA'.
if lca1415 ne x HRI_Group1415 = 'Not in LA'.
if lca1516 ne x HRI_Group1516 = 'Not in LA'.
exe.

* Add death marker.
if date_death < 20170401 HRI_Group1718 = 'Died'.
if date_death < 20160401 HRI_Group1617 = 'Died'.
if date_death < 20150401 HRI_Group1516 = 'Died'.
if date_death > 20170401 and HRI_Group1718 = ' ' HRI_Group1718 = 'Died'.
EXE.


* Assume any blanks are now showing no contact in year.
if HRI_Group1516 = ' ' HRI_Group1516 = 'No Contact'.
if HRI_Group1415 = ' ' HRI_Group1415 = 'No Contact'.
if HRI_Group1718 = ' ' HRI_Group1718 = 'No Contact'.
if HRI_Group1617 = ' ' HRI_Group1617 = 'No Contact'.
EXE.


* Correct some codings where individuals dies after moving LA. If no contact can assume stayed in same LA..
if HRI_Group1516 = "Died" and HRI_Group1415 = "Not in LA" HRI_Group1516 = "Not in LA".
if HRI_Group1617 = "Died" and HRI_Group1516 = "Not in LA" HRI_Group1617 = "Not in LA".
if HRI_Group1718 = "Died" and HRI_Group1617 = "Not in LA" HRI_Group1718 = "Not in LA".
EXE.


* Remove Costs data for those not in LA.
if HRI_Group1516 = "Not in LA" health_net_cost1516 = 0.
if HRI_Group1415 = "Not in LA" health_net_cost1415 = 0.
if HRI_Group1718 = "Not in LA" health_net_cost1718 = 0.
if HRI_Group1617 = "Not in LA" health_net_cost1617 = 0.
EXE.

* Remove Costs data for those Died before start of FY.
if HRI_Group1516 = "Died" health_net_cost1516 = 0.
if HRI_Group1415 = "Died" health_net_cost1415 = 0.
if HRI_Group1718 = "Died" health_net_cost1718 = 0.
if HRI_Group1617 = "Died" health_net_cost1617 = 0.
EXE.


compute LCA_Select = x.
EXE.

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
EXE.


string PathwayLKP (A100).
exe.

compute PathwayLKP = concat(rtrim(HRI_Group1415), rtrim(HRI_Group1516), rtrim(HRI_Group1617), rtrim(HRI_Group1718)).
exe. 

save outfile  = !OFilesL + 'temp_HRI_LAT2.sav'.

* Agg Age.
get file  = !OFilesL + 'temp_HRI_LAT1.sav'.

select if AgeBand = "All".
select if  GenderSTR NE "Both".
EXE.

string PathwayLKP (A100).

compute PathwayLKP = concat(rtrim(HRI_Group1415), rtrim(HRI_Group1516), rtrim(HRI_Group1617), rtrim(HRI_Group1718)).
exe. 

save outfile  = !OFilesL + 'temp_HRI_LAT3.sav'.

* Agg Gender.
get file  = !OFilesL + 'temp_HRI_LAT1.sav'.

select if GenderSTR = "Both".
select if AgeBand NE "All".
EXE.

string PathwayLKP (A100).
exe.


compute PathwayLKP = concat(rtrim(HRI_Group1415), rtrim(HRI_Group1516), rtrim(HRI_Group1617), rtrim(HRI_Group1718)).
exe. 

save outfile  = !OFilesL + 'temp_HRI_LAT4.sav'.

* Agg Age & Gender.
get file  = !OFilesL + 'temp_HRI_LAT1.sav'.

select if  GenderSTR = "Both".
select if AgeBand = "All".
EXE.

string PathwayLKP (A100).

compute PathwayLKP = concat(rtrim(HRI_Group1415), rtrim(HRI_Group1516), rtrim(HRI_Group1617), rtrim(HRI_Group1718)).
exe. 

save outfile  = !OFilesL + 'temp_HRI_LAT5.sav'.

*bring files togther.
add files file = !OFilesL + 'temp_HRI_LAT2.sav'
/file = !OFilesL + 'temp_HRI_LAT3.sav'
/file = !OFilesL + 'temp_HRI_LAT4.sav'
/file = !OFilesL + 'temp_HRI_LAT5.sav'.
EXE.

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
compute PathwayLKP = concat(STRING (LCA_Select,F8),PathwayLKP).
EXE.
*Remove all spaces from PathwayLKP.
COMPUTE PathwayLKP = REPLACE(PathwayLKP, " ", "").
EXE.
* Create a Pathway Label for use in Tableau.
string PathwayLabel (A100).

compute PathwayLabel = concat(HRI_Group1415, ' - ', HRI_Group1516, ' - ', HRI_Group1617, HRI_Group1718, ' - ').
exe. 

* Need to save out Pathway lookup to match on the original CHIMASTER level data.
save outfile  = !OFilesL + 'temp_HRI_LA_ALLYR_CHI16.sav'
/keep chi LCA_select PathwayLKP PathwayLabel HRI_Group1617 HRI_Group1718 HRI_Group1415 HRI_Group1516 remove.

* Remove mis-match records.
select if Remove NE 1.
exe.

AGGREGATE
  /OUTFILE=*
  /BREAK=LCA_Select genderSTR AgeBand HRI_Group1617 HRI_Group1718 HRI_Group1415 HRI_Group1516 PathwayLKP PathwayLabel
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

save outfile  = !OFilesL + 'temp_HRI_LA_ALLYR16.sav'.

** LA 17.
get file  = !OFilesL + 'temp_HRI_LA_MASTER_ALLYR.sav'.

* Set LA.
compute x = 17.
EXE.

* Identify selected individuals in selected LA.

compute LCAFlag = 0.
if LCA1617 = x LCAFlag = 1.
if LCA1718 = x LCAFlag = 1.
if LCA1415 = x LCAFlag = 1.
if LCA1516 = x LCAFlag = 1.

select if LCAFlag = 1.
EXE.
 
* Identify any individuals that wheren't in selected area.
if lca1617 ne x HRI_Group1617 = 'Not in LA'.
if lca1718 ne x HRI_Group1718 = 'Not in LA'.
if lca1415 ne x HRI_Group1415 = 'Not in LA'.
if lca1516 ne x HRI_Group1516 = 'Not in LA'.
exe.

* Add death marker.
if date_death < 20170401 HRI_Group1718 = 'Died'.
if date_death < 20160401 HRI_Group1617 = 'Died'.
if date_death < 20150401 HRI_Group1516 = 'Died'.
if date_death > 20170401 and HRI_Group1718 = ' ' HRI_Group1718 = 'Died'.
EXE.


* Assume any blanks are now showing no contact in year.
if HRI_Group1516 = ' ' HRI_Group1516 = 'No Contact'.
if HRI_Group1415 = ' ' HRI_Group1415 = 'No Contact'.
if HRI_Group1718 = ' ' HRI_Group1718 = 'No Contact'.
if HRI_Group1617 = ' ' HRI_Group1617 = 'No Contact'.
EXE.


* Correct some codings where individuals dies after moving LA. If no contact can assume stayed in same LA..
if HRI_Group1516 = "Died" and HRI_Group1415 = "Not in LA" HRI_Group1516 = "Not in LA".
if HRI_Group1617 = "Died" and HRI_Group1516 = "Not in LA" HRI_Group1617 = "Not in LA".
if HRI_Group1718 = "Died" and HRI_Group1617 = "Not in LA" HRI_Group1718 = "Not in LA".
EXE.


* Remove Costs data for those not in LA.
if HRI_Group1516 = "Not in LA" health_net_cost1516 = 0.
if HRI_Group1415 = "Not in LA" health_net_cost1415 = 0.
if HRI_Group1718 = "Not in LA" health_net_cost1718 = 0.
if HRI_Group1617 = "Not in LA" health_net_cost1617 = 0.
EXE.

* Remove Costs data for those Died before start of FY.
if HRI_Group1516 = "Died" health_net_cost1516 = 0.
if HRI_Group1415 = "Died" health_net_cost1415 = 0.
if HRI_Group1718 = "Died" health_net_cost1718 = 0.
if HRI_Group1617 = "Died" health_net_cost1617 = 0.
EXE.


compute LCA_Select = x.
EXE.

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
EXE.


string PathwayLKP (A100).
exe.

compute PathwayLKP = concat(rtrim(HRI_Group1415), rtrim(HRI_Group1516), rtrim(HRI_Group1617), rtrim(HRI_Group1718)).
exe. 

save outfile  = !OFilesL + 'temp_HRI_LAT2.sav'.

* Agg Age.
get file  = !OFilesL + 'temp_HRI_LAT1.sav'.

select if AgeBand = "All".
select if  GenderSTR NE "Both".
EXE.

string PathwayLKP (A100).

compute PathwayLKP = concat(rtrim(HRI_Group1415), rtrim(HRI_Group1516), rtrim(HRI_Group1617), rtrim(HRI_Group1718)).
exe. 

save outfile  = !OFilesL + 'temp_HRI_LAT3.sav'.

* Agg Gender.
get file  = !OFilesL + 'temp_HRI_LAT1.sav'.

select if GenderSTR = "Both".
select if AgeBand NE "All".
EXE.

string PathwayLKP (A100).
exe.


compute PathwayLKP = concat(rtrim(HRI_Group1415), rtrim(HRI_Group1516), rtrim(HRI_Group1617), rtrim(HRI_Group1718)).
exe. 

save outfile  = !OFilesL + 'temp_HRI_LAT4.sav'.

* Agg Age & Gender.
get file  = !OFilesL + 'temp_HRI_LAT1.sav'.

select if  GenderSTR = "Both".
select if AgeBand = "All".
EXE.

string PathwayLKP (A100).

compute PathwayLKP = concat(rtrim(HRI_Group1415), rtrim(HRI_Group1516), rtrim(HRI_Group1617), rtrim(HRI_Group1718)).
exe. 

save outfile  = !OFilesL + 'temp_HRI_LAT5.sav'.

*bring files togther.
add files file = !OFilesL + 'temp_HRI_LAT2.sav'
/file = !OFilesL + 'temp_HRI_LAT3.sav'
/file = !OFilesL + 'temp_HRI_LAT4.sav'
/file = !OFilesL + 'temp_HRI_LAT5.sav'.
EXE.

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
compute PathwayLKP = concat(STRING (LCA_Select,F8),PathwayLKP).
EXE.
*Remove all spaces from PathwayLKP.
COMPUTE PathwayLKP = REPLACE(PathwayLKP, " ", "").
EXE.
* Create a Pathway Label for use in Tableau.
string PathwayLabel (A100).

compute PathwayLabel = concat(HRI_Group1415, ' - ', HRI_Group1516, ' - ', HRI_Group1617, HRI_Group1718, ' - ').
exe. 

* Need to save out Pathway lookup to match on the original CHIMASTER level data.
save outfile  = !OFilesL + 'temp_HRI_LA_ALLYR_CHI17.sav'
/keep chi LCA_select PathwayLKP PathwayLabel HRI_Group1617 HRI_Group1718 HRI_Group1415 HRI_Group1516 remove.

* Remove mis-match records.
select if Remove NE 1.
exe.

AGGREGATE
  /OUTFILE=*
  /BREAK=LCA_Select genderSTR AgeBand HRI_Group1617 HRI_Group1718 HRI_Group1415 HRI_Group1516 PathwayLKP PathwayLabel
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

save outfile  = !OFilesL + 'temp_HRI_LA_ALLYR17.sav'.

** LA 18.
get file  = !OFilesL + 'temp_HRI_LA_MASTER_ALLYR.sav'.

* Set LA.
compute x = 18.
EXE.

* Identify selected individuals in selected LA.

compute LCAFlag = 0.
if LCA1617 = x LCAFlag = 1.
if LCA1718 = x LCAFlag = 1.
if LCA1415 = x LCAFlag = 1.
if LCA1516 = x LCAFlag = 1.

select if LCAFlag = 1.
EXE.
 
* Identify any individuals that wheren't in selected area.
if lca1617 ne x HRI_Group1617 = 'Not in LA'.
if lca1718 ne x HRI_Group1718 = 'Not in LA'.
if lca1415 ne x HRI_Group1415 = 'Not in LA'.
if lca1516 ne x HRI_Group1516 = 'Not in LA'.
exe.

* Add death marker.
if date_death < 20170401 HRI_Group1718 = 'Died'.
if date_death < 20160401 HRI_Group1617 = 'Died'.
if date_death < 20150401 HRI_Group1516 = 'Died'.
if date_death > 20170401 and HRI_Group1718 = ' ' HRI_Group1718 = 'Died'.
EXE.


* Assume any blanks are now showing no contact in year.
if HRI_Group1516 = ' ' HRI_Group1516 = 'No Contact'.
if HRI_Group1415 = ' ' HRI_Group1415 = 'No Contact'.
if HRI_Group1718 = ' ' HRI_Group1718 = 'No Contact'.
if HRI_Group1617 = ' ' HRI_Group1617 = 'No Contact'.
EXE.


* Correct some codings where individuals dies after moving LA. If no contact can assume stayed in same LA..
if HRI_Group1516 = "Died" and HRI_Group1415 = "Not in LA" HRI_Group1516 = "Not in LA".
if HRI_Group1617 = "Died" and HRI_Group1516 = "Not in LA" HRI_Group1617 = "Not in LA".
if HRI_Group1718 = "Died" and HRI_Group1617 = "Not in LA" HRI_Group1718 = "Not in LA".
EXE.


* Remove Costs data for those not in LA.
if HRI_Group1516 = "Not in LA" health_net_cost1516 = 0.
if HRI_Group1415 = "Not in LA" health_net_cost1415 = 0.
if HRI_Group1718 = "Not in LA" health_net_cost1718 = 0.
if HRI_Group1617 = "Not in LA" health_net_cost1617 = 0.
EXE.

* Remove Costs data for those Died before start of FY.
if HRI_Group1516 = "Died" health_net_cost1516 = 0.
if HRI_Group1415 = "Died" health_net_cost1415 = 0.
if HRI_Group1718 = "Died" health_net_cost1718 = 0.
if HRI_Group1617 = "Died" health_net_cost1617 = 0.
EXE.


compute LCA_Select = x.
EXE.

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
EXE.


string PathwayLKP (A100).
exe.

compute PathwayLKP = concat(rtrim(HRI_Group1415), rtrim(HRI_Group1516), rtrim(HRI_Group1617), rtrim(HRI_Group1718)).
exe. 

save outfile  = !OFilesL + 'temp_HRI_LAT2.sav'.

* Agg Age.
get file  = !OFilesL + 'temp_HRI_LAT1.sav'.

select if AgeBand = "All".
select if  GenderSTR NE "Both".
EXE.

string PathwayLKP (A100).

compute PathwayLKP = concat(rtrim(HRI_Group1415), rtrim(HRI_Group1516), rtrim(HRI_Group1617), rtrim(HRI_Group1718)).
exe. 

save outfile  = !OFilesL + 'temp_HRI_LAT3.sav'.

* Agg Gender.
get file  = !OFilesL + 'temp_HRI_LAT1.sav'.

select if GenderSTR = "Both".
select if AgeBand NE "All".
EXE.

string PathwayLKP (A100).
exe.


compute PathwayLKP = concat(rtrim(HRI_Group1415), rtrim(HRI_Group1516), rtrim(HRI_Group1617), rtrim(HRI_Group1718)).
exe. 

save outfile  = !OFilesL + 'temp_HRI_LAT4.sav'.

* Agg Age & Gender.
get file  = !OFilesL + 'temp_HRI_LAT1.sav'.

select if  GenderSTR = "Both".
select if AgeBand = "All".
EXE.

string PathwayLKP (A100).

compute PathwayLKP = concat(rtrim(HRI_Group1415), rtrim(HRI_Group1516), rtrim(HRI_Group1617), rtrim(HRI_Group1718)).
exe. 

save outfile  = !OFilesL + 'temp_HRI_LAT5.sav'.

*bring files togther.
add files file = !OFilesL + 'temp_HRI_LAT2.sav'
/file = !OFilesL + 'temp_HRI_LAT3.sav'
/file = !OFilesL + 'temp_HRI_LAT4.sav'
/file = !OFilesL + 'temp_HRI_LAT5.sav'.
EXE.

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
compute PathwayLKP = concat(STRING (LCA_Select,F8),PathwayLKP).
EXE.
*Remove all spaces from PathwayLKP.
COMPUTE PathwayLKP = REPLACE(PathwayLKP, " ", "").
EXE.
* Create a Pathway Label for use in Tableau.
string PathwayLabel (A100).

compute PathwayLabel = concat(HRI_Group1415, ' - ', HRI_Group1516, ' - ', HRI_Group1617, HRI_Group1718, ' - ').
exe. 

* Need to save out Pathway lookup to match on the original CHIMASTER level data.
save outfile  = !OFilesL + 'temp_HRI_LA_ALLYR_CHI18.sav'
/keep chi LCA_select PathwayLKP PathwayLabel HRI_Group1617 HRI_Group1718 HRI_Group1415 HRI_Group1516 remove.

* Remove mis-match records.
select if Remove NE 1.
exe.

AGGREGATE
  /OUTFILE=*
  /BREAK=LCA_Select genderSTR AgeBand HRI_Group1617 HRI_Group1718 HRI_Group1415 HRI_Group1516 PathwayLKP PathwayLabel
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

save outfile  = !OFilesL + 'temp_HRI_LA_ALLYR18.sav'.

** LA 19.
get file  = !OFilesL + 'temp_HRI_LA_MASTER_ALLYR.sav'.

* Set LA.
compute x = 19.
EXE.

* Identify selected individuals in selected LA.

compute LCAFlag = 0.
if LCA1617 = x LCAFlag = 1.
if LCA1718 = x LCAFlag = 1.
if LCA1415 = x LCAFlag = 1.
if LCA1516 = x LCAFlag = 1.

select if LCAFlag = 1.
EXE.
 
* Identify any individuals that wheren't in selected area.
if lca1617 ne x HRI_Group1617 = 'Not in LA'.
if lca1718 ne x HRI_Group1718 = 'Not in LA'.
if lca1415 ne x HRI_Group1415 = 'Not in LA'.
if lca1516 ne x HRI_Group1516 = 'Not in LA'.
exe.

* Add death marker.
if date_death < 20170401 HRI_Group1718 = 'Died'.
if date_death < 20160401 HRI_Group1617 = 'Died'.
if date_death < 20150401 HRI_Group1516 = 'Died'.
if date_death > 20170401 and HRI_Group1718 = ' ' HRI_Group1718 = 'Died'.
EXE.


* Assume any blanks are now showing no contact in year.
if HRI_Group1516 = ' ' HRI_Group1516 = 'No Contact'.
if HRI_Group1415 = ' ' HRI_Group1415 = 'No Contact'.
if HRI_Group1718 = ' ' HRI_Group1718 = 'No Contact'.
if HRI_Group1617 = ' ' HRI_Group1617 = 'No Contact'.
EXE.


* Correct some codings where individuals dies after moving LA. If no contact can assume stayed in same LA..
if HRI_Group1516 = "Died" and HRI_Group1415 = "Not in LA" HRI_Group1516 = "Not in LA".
if HRI_Group1617 = "Died" and HRI_Group1516 = "Not in LA" HRI_Group1617 = "Not in LA".
if HRI_Group1718 = "Died" and HRI_Group1617 = "Not in LA" HRI_Group1718 = "Not in LA".
EXE.


* Remove Costs data for those not in LA.
if HRI_Group1516 = "Not in LA" health_net_cost1516 = 0.
if HRI_Group1415 = "Not in LA" health_net_cost1415 = 0.
if HRI_Group1718 = "Not in LA" health_net_cost1718 = 0.
if HRI_Group1617 = "Not in LA" health_net_cost1617 = 0.
EXE.

* Remove Costs data for those Died before start of FY.
if HRI_Group1516 = "Died" health_net_cost1516 = 0.
if HRI_Group1415 = "Died" health_net_cost1415 = 0.
if HRI_Group1718 = "Died" health_net_cost1718 = 0.
if HRI_Group1617 = "Died" health_net_cost1617 = 0.
EXE.


compute LCA_Select = x.
EXE.

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
EXE.


string PathwayLKP (A100).
exe.

compute PathwayLKP = concat(rtrim(HRI_Group1415), rtrim(HRI_Group1516), rtrim(HRI_Group1617), rtrim(HRI_Group1718)).
exe. 

save outfile  = !OFilesL + 'temp_HRI_LAT2.sav'.

* Agg Age.
get file  = !OFilesL + 'temp_HRI_LAT1.sav'.

select if AgeBand = "All".
select if  GenderSTR NE "Both".
EXE.

string PathwayLKP (A100).

compute PathwayLKP = concat(rtrim(HRI_Group1415), rtrim(HRI_Group1516), rtrim(HRI_Group1617), rtrim(HRI_Group1718)).
exe. 

save outfile  = !OFilesL + 'temp_HRI_LAT3.sav'.

* Agg Gender.
get file  = !OFilesL + 'temp_HRI_LAT1.sav'.

select if GenderSTR = "Both".
select if AgeBand NE "All".
EXE.

string PathwayLKP (A100).
exe.


compute PathwayLKP = concat(rtrim(HRI_Group1415), rtrim(HRI_Group1516), rtrim(HRI_Group1617), rtrim(HRI_Group1718)).
exe. 

save outfile  = !OFilesL + 'temp_HRI_LAT4.sav'.

* Agg Age & Gender.
get file  = !OFilesL + 'temp_HRI_LAT1.sav'.

select if  GenderSTR = "Both".
select if AgeBand = "All".
EXE.

string PathwayLKP (A100).

compute PathwayLKP = concat(rtrim(HRI_Group1415), rtrim(HRI_Group1516), rtrim(HRI_Group1617), rtrim(HRI_Group1718)).
exe. 

save outfile  = !OFilesL + 'temp_HRI_LAT5.sav'.

*bring files togther.
add files file = !OFilesL + 'temp_HRI_LAT2.sav'
/file = !OFilesL + 'temp_HRI_LAT3.sav'
/file = !OFilesL + 'temp_HRI_LAT4.sav'
/file = !OFilesL + 'temp_HRI_LAT5.sav'.
EXE.

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
compute PathwayLKP = concat(STRING (LCA_Select,F8),PathwayLKP).
EXE.
*Remove all spaces from PathwayLKP.
COMPUTE PathwayLKP = REPLACE(PathwayLKP, " ", "").
EXE.
* Create a Pathway Label for use in Tableau.
string PathwayLabel (A100).

compute PathwayLabel = concat(HRI_Group1415, ' - ', HRI_Group1516, ' - ', HRI_Group1617, HRI_Group1718, ' - ').
exe. 

* Need to save out Pathway lookup to match on the original CHIMASTER level data.
save outfile  = !OFilesL + 'temp_HRI_LA_ALLYR_CHI19.sav'
/keep chi LCA_select PathwayLKP PathwayLabel HRI_Group1617 HRI_Group1718 HRI_Group1415 HRI_Group1516 remove.

* Remove mis-match records.
select if Remove NE 1.
exe.

AGGREGATE
  /OUTFILE=*
  /BREAK=LCA_Select genderSTR AgeBand HRI_Group1617 HRI_Group1718 HRI_Group1415 HRI_Group1516 PathwayLKP PathwayLabel
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

save outfile  = !OFilesL + 'temp_HRI_LA_ALLYR19.sav'.

** LA 20.
get file  = !OFilesL + 'temp_HRI_LA_MASTER_ALLYR.sav'.

* Set LA.
compute x = 20.
EXE.

* Identify selected individuals in selected LA.

compute LCAFlag = 0.
if LCA1617 = x LCAFlag = 1.
if LCA1718 = x LCAFlag = 1.
if LCA1415 = x LCAFlag = 1.
if LCA1516 = x LCAFlag = 1.

select if LCAFlag = 1.
EXE.
 
* Identify any individuals that wheren't in selected area.
if lca1617 ne x HRI_Group1617 = 'Not in LA'.
if lca1718 ne x HRI_Group1718 = 'Not in LA'.
if lca1415 ne x HRI_Group1415 = 'Not in LA'.
if lca1516 ne x HRI_Group1516 = 'Not in LA'.
exe.

* Add death marker.
if date_death < 20170401 HRI_Group1718 = 'Died'.
if date_death < 20160401 HRI_Group1617 = 'Died'.
if date_death < 20150401 HRI_Group1516 = 'Died'.
if date_death > 20170401 and HRI_Group1718 = ' ' HRI_Group1718 = 'Died'.
EXE.


* Assume any blanks are now showing no contact in year.
if HRI_Group1516 = ' ' HRI_Group1516 = 'No Contact'.
if HRI_Group1415 = ' ' HRI_Group1415 = 'No Contact'.
if HRI_Group1718 = ' ' HRI_Group1718 = 'No Contact'.
if HRI_Group1617 = ' ' HRI_Group1617 = 'No Contact'.
EXE.


* Correct some codings where individuals dies after moving LA. If no contact can assume stayed in same LA..
if HRI_Group1516 = "Died" and HRI_Group1415 = "Not in LA" HRI_Group1516 = "Not in LA".
if HRI_Group1617 = "Died" and HRI_Group1516 = "Not in LA" HRI_Group1617 = "Not in LA".
if HRI_Group1718 = "Died" and HRI_Group1617 = "Not in LA" HRI_Group1718 = "Not in LA".
EXE.


* Remove Costs data for those not in LA.
if HRI_Group1516 = "Not in LA" health_net_cost1516 = 0.
if HRI_Group1415 = "Not in LA" health_net_cost1415 = 0.
if HRI_Group1718 = "Not in LA" health_net_cost1718 = 0.
if HRI_Group1617 = "Not in LA" health_net_cost1617 = 0.
EXE.

* Remove Costs data for those Died before start of FY.
if HRI_Group1516 = "Died" health_net_cost1516 = 0.
if HRI_Group1415 = "Died" health_net_cost1415 = 0.
if HRI_Group1718 = "Died" health_net_cost1718 = 0.
if HRI_Group1617 = "Died" health_net_cost1617 = 0.
EXE.


compute LCA_Select = x.
EXE.

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
EXE.


string PathwayLKP (A100).
exe.

compute PathwayLKP = concat(rtrim(HRI_Group1415), rtrim(HRI_Group1516), rtrim(HRI_Group1617), rtrim(HRI_Group1718)).
exe. 

save outfile  = !OFilesL + 'temp_HRI_LAT2.sav'.

* Agg Age.
get file  = !OFilesL + 'temp_HRI_LAT1.sav'.

select if AgeBand = "All".
select if  GenderSTR NE "Both".
EXE.

string PathwayLKP (A100).

compute PathwayLKP = concat(rtrim(HRI_Group1415), rtrim(HRI_Group1516), rtrim(HRI_Group1617), rtrim(HRI_Group1718)).
exe. 

save outfile  = !OFilesL + 'temp_HRI_LAT3.sav'.

* Agg Gender.
get file  = !OFilesL + 'temp_HRI_LAT1.sav'.

select if GenderSTR = "Both".
select if AgeBand NE "All".
EXE.

string PathwayLKP (A100).
exe.


compute PathwayLKP = concat(rtrim(HRI_Group1415), rtrim(HRI_Group1516), rtrim(HRI_Group1617), rtrim(HRI_Group1718)).
exe. 

save outfile  = !OFilesL + 'temp_HRI_LAT4.sav'.

* Agg Age & Gender.
get file  = !OFilesL + 'temp_HRI_LAT1.sav'.

select if  GenderSTR = "Both".
select if AgeBand = "All".
EXE.

string PathwayLKP (A100).

compute PathwayLKP = concat(rtrim(HRI_Group1415), rtrim(HRI_Group1516), rtrim(HRI_Group1617), rtrim(HRI_Group1718)).
exe. 

save outfile  = !OFilesL + 'temp_HRI_LAT5.sav'.

*bring files togther.
add files file = !OFilesL + 'temp_HRI_LAT2.sav'
/file = !OFilesL + 'temp_HRI_LAT3.sav'
/file = !OFilesL + 'temp_HRI_LAT4.sav'
/file = !OFilesL + 'temp_HRI_LAT5.sav'.
EXE.

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
compute PathwayLKP = concat(STRING (LCA_Select,F8),PathwayLKP).
EXE.
*Remove all spaces from PathwayLKP.
COMPUTE PathwayLKP = REPLACE(PathwayLKP, " ", "").
EXE.
* Create a Pathway Label for use in Tableau.
string PathwayLabel (A100).

compute PathwayLabel = concat(HRI_Group1415, ' - ', HRI_Group1516, ' - ', HRI_Group1617, HRI_Group1718, ' - ').
exe. 

* Need to save out Pathway lookup to match on the original CHIMASTER level data.
save outfile  = !OFilesL + 'temp_HRI_LA_ALLYR_CHI20.sav'
/keep chi LCA_select PathwayLKP PathwayLabel HRI_Group1617 HRI_Group1718 HRI_Group1415 HRI_Group1516 remove.

* Remove mis-match records.
select if Remove NE 1.
exe.

AGGREGATE
  /OUTFILE=*
  /BREAK=LCA_Select genderSTR AgeBand HRI_Group1617 HRI_Group1718 HRI_Group1415 HRI_Group1516 PathwayLKP PathwayLabel
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

save outfile  = !OFilesL + 'temp_HRI_LA_ALLYR20.sav'.

** LA 21.
get file  = !OFilesL + 'temp_HRI_LA_MASTER_ALLYR.sav'.
* Set LA.
compute x = 21.
EXE.

* Identify selected individuals in selected LA.

compute LCAFlag = 0.
if LCA1617 = x LCAFlag = 1.
if LCA1718 = x LCAFlag = 1.
if LCA1415 = x LCAFlag = 1.
if LCA1516 = x LCAFlag = 1.

select if LCAFlag = 1.
EXE.
 
* Identify any individuals that wheren't in selected area.
if lca1617 ne x HRI_Group1617 = 'Not in LA'.
if lca1718 ne x HRI_Group1718 = 'Not in LA'.
if lca1415 ne x HRI_Group1415 = 'Not in LA'.
if lca1516 ne x HRI_Group1516 = 'Not in LA'.
exe.

* Add death marker.
if date_death < 20170401 HRI_Group1718 = 'Died'.
if date_death < 20160401 HRI_Group1617 = 'Died'.
if date_death < 20150401 HRI_Group1516 = 'Died'.
if date_death > 20170401 and HRI_Group1718 = ' ' HRI_Group1718 = 'Died'.
EXE.


* Assume any blanks are now showing no contact in year.
if HRI_Group1516 = ' ' HRI_Group1516 = 'No Contact'.
if HRI_Group1415 = ' ' HRI_Group1415 = 'No Contact'.
if HRI_Group1718 = ' ' HRI_Group1718 = 'No Contact'.
if HRI_Group1617 = ' ' HRI_Group1617 = 'No Contact'.
EXE.


* Correct some codings where individuals dies after moving LA. If no contact can assume stayed in same LA..
if HRI_Group1516 = "Died" and HRI_Group1415 = "Not in LA" HRI_Group1516 = "Not in LA".
if HRI_Group1617 = "Died" and HRI_Group1516 = "Not in LA" HRI_Group1617 = "Not in LA".
if HRI_Group1718 = "Died" and HRI_Group1617 = "Not in LA" HRI_Group1718 = "Not in LA".
EXE.


* Remove Costs data for those not in LA.
if HRI_Group1516 = "Not in LA" health_net_cost1516 = 0.
if HRI_Group1415 = "Not in LA" health_net_cost1415 = 0.
if HRI_Group1718 = "Not in LA" health_net_cost1718 = 0.
if HRI_Group1617 = "Not in LA" health_net_cost1617 = 0.
EXE.

* Remove Costs data for those Died before start of FY.
if HRI_Group1516 = "Died" health_net_cost1516 = 0.
if HRI_Group1415 = "Died" health_net_cost1415 = 0.
if HRI_Group1718 = "Died" health_net_cost1718 = 0.
if HRI_Group1617 = "Died" health_net_cost1617 = 0.
EXE.


compute LCA_Select = x.
EXE.

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
EXE.


string PathwayLKP (A100).
exe.

compute PathwayLKP = concat(rtrim(HRI_Group1415), rtrim(HRI_Group1516), rtrim(HRI_Group1617), rtrim(HRI_Group1718)).
exe. 

save outfile  = !OFilesL + 'temp_HRI_LAT2.sav'.

* Agg Age.
get file  = !OFilesL + 'temp_HRI_LAT1.sav'.

select if AgeBand = "All".
select if  GenderSTR NE "Both".
EXE.

string PathwayLKP (A100).

compute PathwayLKP = concat(rtrim(HRI_Group1415), rtrim(HRI_Group1516), rtrim(HRI_Group1617), rtrim(HRI_Group1718)).
exe. 

save outfile  = !OFilesL + 'temp_HRI_LAT3.sav'.

* Agg Gender.
get file  = !OFilesL + 'temp_HRI_LAT1.sav'.

select if GenderSTR = "Both".
select if AgeBand NE "All".
EXE.

string PathwayLKP (A100).
exe.


compute PathwayLKP = concat(rtrim(HRI_Group1415), rtrim(HRI_Group1516), rtrim(HRI_Group1617), rtrim(HRI_Group1718)).
exe. 

save outfile  = !OFilesL + 'temp_HRI_LAT4.sav'.

* Agg Age & Gender.
get file  = !OFilesL + 'temp_HRI_LAT1.sav'.

select if  GenderSTR = "Both".
select if AgeBand = "All".
EXE.

string PathwayLKP (A100).

compute PathwayLKP = concat(rtrim(HRI_Group1415), rtrim(HRI_Group1516), rtrim(HRI_Group1617), rtrim(HRI_Group1718)).
exe. 

save outfile  = !OFilesL + 'temp_HRI_LAT5.sav'.

*bring files togther.
add files file = !OFilesL + 'temp_HRI_LAT2.sav'
/file = !OFilesL + 'temp_HRI_LAT3.sav'
/file = !OFilesL + 'temp_HRI_LAT4.sav'
/file = !OFilesL + 'temp_HRI_LAT5.sav'.
EXE.

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
compute PathwayLKP = concat(STRING (LCA_Select,F8),PathwayLKP).
EXE.
*Remove all spaces from PathwayLKP.
COMPUTE PathwayLKP = REPLACE(PathwayLKP, " ", "").
EXE.
* Create a Pathway Label for use in Tableau.
string PathwayLabel (A100).

compute PathwayLabel = concat(HRI_Group1415, ' - ', HRI_Group1516, ' - ', HRI_Group1617, HRI_Group1718, ' - ').
exe. 

* Need to save out Pathway lookup to match on the original CHIMASTER level data.
save outfile  = !OFilesL + 'temp_HRI_LA_ALLYR_CHI21.sav'
/keep chi LCA_select PathwayLKP PathwayLabel HRI_Group1617 HRI_Group1718 HRI_Group1415 HRI_Group1516 remove.

* Remove mis-match records.
select if Remove NE 1.
exe.

AGGREGATE
  /OUTFILE=*
  /BREAK=LCA_Select genderSTR AgeBand HRI_Group1617 HRI_Group1718 HRI_Group1415 HRI_Group1516 PathwayLKP PathwayLabel
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

save outfile  = !OFilesL + 'temp_HRI_LA_ALLYR21.sav'.

** LA 22.
get file  = !OFilesL + 'temp_HRI_LA_MASTER_ALLYR.sav'.

* Set LA.
compute x = 22.
EXE.

* Identify selected individuals in selected LA.

compute LCAFlag = 0.
if LCA1617 = x LCAFlag = 1.
if LCA1718 = x LCAFlag = 1.
if LCA1415 = x LCAFlag = 1.
if LCA1516 = x LCAFlag = 1.

select if LCAFlag = 1.
EXE.
 
* Identify any individuals that wheren't in selected area.
if lca1617 ne x HRI_Group1617 = 'Not in LA'.
if lca1718 ne x HRI_Group1718 = 'Not in LA'.
if lca1415 ne x HRI_Group1415 = 'Not in LA'.
if lca1516 ne x HRI_Group1516 = 'Not in LA'.
exe.

* Add death marker.
if date_death < 20170401 HRI_Group1718 = 'Died'.
if date_death < 20160401 HRI_Group1617 = 'Died'.
if date_death < 20150401 HRI_Group1516 = 'Died'.
if date_death > 20170401 and HRI_Group1718 = ' ' HRI_Group1718 = 'Died'.
EXE.


* Assume any blanks are now showing no contact in year.
if HRI_Group1516 = ' ' HRI_Group1516 = 'No Contact'.
if HRI_Group1415 = ' ' HRI_Group1415 = 'No Contact'.
if HRI_Group1718 = ' ' HRI_Group1718 = 'No Contact'.
if HRI_Group1617 = ' ' HRI_Group1617 = 'No Contact'.
EXE.


* Correct some codings where individuals dies after moving LA. If no contact can assume stayed in same LA..
if HRI_Group1516 = "Died" and HRI_Group1415 = "Not in LA" HRI_Group1516 = "Not in LA".
if HRI_Group1617 = "Died" and HRI_Group1516 = "Not in LA" HRI_Group1617 = "Not in LA".
if HRI_Group1718 = "Died" and HRI_Group1617 = "Not in LA" HRI_Group1718 = "Not in LA".
EXE.


* Remove Costs data for those not in LA.
if HRI_Group1516 = "Not in LA" health_net_cost1516 = 0.
if HRI_Group1415 = "Not in LA" health_net_cost1415 = 0.
if HRI_Group1718 = "Not in LA" health_net_cost1718 = 0.
if HRI_Group1617 = "Not in LA" health_net_cost1617 = 0.
EXE.

* Remove Costs data for those Died before start of FY.
if HRI_Group1516 = "Died" health_net_cost1516 = 0.
if HRI_Group1415 = "Died" health_net_cost1415 = 0.
if HRI_Group1718 = "Died" health_net_cost1718 = 0.
if HRI_Group1617 = "Died" health_net_cost1617 = 0.
EXE.


compute LCA_Select = x.
EXE.

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
EXE.


string PathwayLKP (A100).
exe.

compute PathwayLKP = concat(rtrim(HRI_Group1415), rtrim(HRI_Group1516), rtrim(HRI_Group1617), rtrim(HRI_Group1718)).
exe. 

save outfile  = !OFilesL + 'temp_HRI_LAT2.sav'.

* Agg Age.
get file  = !OFilesL + 'temp_HRI_LAT1.sav'.

select if AgeBand = "All".
select if  GenderSTR NE "Both".
EXE.

string PathwayLKP (A100).

compute PathwayLKP = concat(rtrim(HRI_Group1415), rtrim(HRI_Group1516), rtrim(HRI_Group1617), rtrim(HRI_Group1718)).
exe. 

save outfile  = !OFilesL + 'temp_HRI_LAT3.sav'.

* Agg Gender.
get file  = !OFilesL + 'temp_HRI_LAT1.sav'.

select if GenderSTR = "Both".
select if AgeBand NE "All".
EXE.

string PathwayLKP (A100).
exe.


compute PathwayLKP = concat(rtrim(HRI_Group1415), rtrim(HRI_Group1516), rtrim(HRI_Group1617), rtrim(HRI_Group1718)).
exe. 

save outfile  = !OFilesL + 'temp_HRI_LAT4.sav'.

* Agg Age & Gender.
get file  = !OFilesL + 'temp_HRI_LAT1.sav'.

select if  GenderSTR = "Both".
select if AgeBand = "All".
EXE.

string PathwayLKP (A100).

compute PathwayLKP = concat(rtrim(HRI_Group1415), rtrim(HRI_Group1516), rtrim(HRI_Group1617), rtrim(HRI_Group1718)).
exe. 

save outfile  = !OFilesL + 'temp_HRI_LAT5.sav'.

*bring files togther.
add files file = !OFilesL + 'temp_HRI_LAT2.sav'
/file = !OFilesL + 'temp_HRI_LAT3.sav'
/file = !OFilesL + 'temp_HRI_LAT4.sav'
/file = !OFilesL + 'temp_HRI_LAT5.sav'.
EXE.

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
compute PathwayLKP = concat(STRING (LCA_Select,F8),PathwayLKP).
EXE.
*Remove all spaces from PathwayLKP.
COMPUTE PathwayLKP = REPLACE(PathwayLKP, " ", "").
EXE.
* Create a Pathway Label for use in Tableau.
string PathwayLabel (A100).

compute PathwayLabel = concat(HRI_Group1415, ' - ', HRI_Group1516, ' - ', HRI_Group1617, HRI_Group1718, ' - ').
exe. 

* Need to save out Pathway lookup to match on the original CHIMASTER level data.
save outfile  = !OFilesL + 'temp_HRI_LA_ALLYR_CHI22.sav'
/keep chi LCA_select PathwayLKP PathwayLabel HRI_Group1617 HRI_Group1718 HRI_Group1415 HRI_Group1516 remove.

* Remove mis-match records.
select if Remove NE 1.
exe.

AGGREGATE
  /OUTFILE=*
  /BREAK=LCA_Select genderSTR AgeBand HRI_Group1617 HRI_Group1718 HRI_Group1415 HRI_Group1516 PathwayLKP PathwayLabel
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
save outfile  = !OFilesL + 'temp_HRI_LA_ALLYR22.sav'.

** LA 23.
get file  = !OFilesL + 'temp_HRI_LA_MASTER_ALLYR.sav'.

* Set LA.
compute x = 23.
EXE.

* Identify selected individuals in selected LA.

compute LCAFlag = 0.
if LCA1617 = x LCAFlag = 1.
if LCA1718 = x LCAFlag = 1.
if LCA1415 = x LCAFlag = 1.
if LCA1516 = x LCAFlag = 1.

select if LCAFlag = 1.
EXE.
 
* Identify any individuals that wheren't in selected area.
if lca1617 ne x HRI_Group1617 = 'Not in LA'.
if lca1718 ne x HRI_Group1718 = 'Not in LA'.
if lca1415 ne x HRI_Group1415 = 'Not in LA'.
if lca1516 ne x HRI_Group1516 = 'Not in LA'.
exe.

* Add death marker.
if date_death < 20170401 HRI_Group1718 = 'Died'.
if date_death < 20160401 HRI_Group1617 = 'Died'.
if date_death < 20150401 HRI_Group1516 = 'Died'.
if date_death > 20170401 and HRI_Group1718 = ' ' HRI_Group1718 = 'Died'.
EXE.


* Assume any blanks are now showing no contact in year.
if HRI_Group1516 = ' ' HRI_Group1516 = 'No Contact'.
if HRI_Group1415 = ' ' HRI_Group1415 = 'No Contact'.
if HRI_Group1718 = ' ' HRI_Group1718 = 'No Contact'.
if HRI_Group1617 = ' ' HRI_Group1617 = 'No Contact'.
EXE.


* Correct some codings where individuals dies after moving LA. If no contact can assume stayed in same LA..
if HRI_Group1516 = "Died" and HRI_Group1415 = "Not in LA" HRI_Group1516 = "Not in LA".
if HRI_Group1617 = "Died" and HRI_Group1516 = "Not in LA" HRI_Group1617 = "Not in LA".
if HRI_Group1718 = "Died" and HRI_Group1617 = "Not in LA" HRI_Group1718 = "Not in LA".
EXE.


* Remove Costs data for those not in LA.
if HRI_Group1516 = "Not in LA" health_net_cost1516 = 0.
if HRI_Group1415 = "Not in LA" health_net_cost1415 = 0.
if HRI_Group1718 = "Not in LA" health_net_cost1718 = 0.
if HRI_Group1617 = "Not in LA" health_net_cost1617 = 0.
EXE.

* Remove Costs data for those Died before start of FY.
if HRI_Group1516 = "Died" health_net_cost1516 = 0.
if HRI_Group1415 = "Died" health_net_cost1415 = 0.
if HRI_Group1718 = "Died" health_net_cost1718 = 0.
if HRI_Group1617 = "Died" health_net_cost1617 = 0.
EXE.


compute LCA_Select = x.
EXE.

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
EXE.


string PathwayLKP (A100).
exe.

compute PathwayLKP = concat(rtrim(HRI_Group1415), rtrim(HRI_Group1516), rtrim(HRI_Group1617), rtrim(HRI_Group1718)).
exe. 

save outfile  = !OFilesL + 'temp_HRI_LAT2.sav'.

* Agg Age.
get file  = !OFilesL + 'temp_HRI_LAT1.sav'.

select if AgeBand = "All".
select if  GenderSTR NE "Both".
EXE.

string PathwayLKP (A100).

compute PathwayLKP = concat(rtrim(HRI_Group1415), rtrim(HRI_Group1516), rtrim(HRI_Group1617), rtrim(HRI_Group1718)).
exe. 

save outfile  = !OFilesL + 'temp_HRI_LAT3.sav'.

* Agg Gender.
get file  = !OFilesL + 'temp_HRI_LAT1.sav'.

select if GenderSTR = "Both".
select if AgeBand NE "All".
EXE.

string PathwayLKP (A100).
exe.


compute PathwayLKP = concat(rtrim(HRI_Group1415), rtrim(HRI_Group1516), rtrim(HRI_Group1617), rtrim(HRI_Group1718)).
exe. 

save outfile  = !OFilesL + 'temp_HRI_LAT4.sav'.

* Agg Age & Gender.
get file  = !OFilesL + 'temp_HRI_LAT1.sav'.

select if  GenderSTR = "Both".
select if AgeBand = "All".
EXE.

string PathwayLKP (A100).

compute PathwayLKP = concat(rtrim(HRI_Group1415), rtrim(HRI_Group1516), rtrim(HRI_Group1617), rtrim(HRI_Group1718)).
exe. 

save outfile  = !OFilesL + 'temp_HRI_LAT5.sav'.

*bring files togther.
add files file = !OFilesL + 'temp_HRI_LAT2.sav'
/file = !OFilesL + 'temp_HRI_LAT3.sav'
/file = !OFilesL + 'temp_HRI_LAT4.sav'
/file = !OFilesL + 'temp_HRI_LAT5.sav'.
EXE.

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
compute PathwayLKP = concat(STRING (LCA_Select,F8),PathwayLKP).
EXE.
*Remove all spaces from PathwayLKP.
COMPUTE PathwayLKP = REPLACE(PathwayLKP, " ", "").
EXE.
* Create a Pathway Label for use in Tableau.
string PathwayLabel (A100).

compute PathwayLabel = concat(HRI_Group1415, ' - ', HRI_Group1516, ' - ', HRI_Group1617, HRI_Group1718, ' - ').
exe. 

* Need to save out Pathway lookup to match on the original CHIMASTER level data.
save outfile  = !OFilesL + 'temp_HRI_LA_ALLYR_CHI23.sav'
/keep chi LCA_select PathwayLKP PathwayLabel HRI_Group1617 HRI_Group1718 HRI_Group1415 HRI_Group1516 remove.

* Remove mis-match records.
select if Remove NE 1.
exe.

AGGREGATE
  /OUTFILE=*
  /BREAK=LCA_Select genderSTR AgeBand HRI_Group1617 HRI_Group1718 HRI_Group1415 HRI_Group1516 PathwayLKP PathwayLabel
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
save outfile  = !OFilesL + 'temp_HRI_LA_ALLYR23.sav'.

** LA 24.
get file  = !OFilesL + 'temp_HRI_LA_MASTER_ALLYR.sav'.

* Set LA.
compute x = 24.
EXE.

* Identify selected individuals in selected LA.

compute LCAFlag = 0.
if LCA1617 = x LCAFlag = 1.
if LCA1718 = x LCAFlag = 1.
if LCA1415 = x LCAFlag = 1.
if LCA1516 = x LCAFlag = 1.

select if LCAFlag = 1.
EXE.
 
* Identify any individuals that wheren't in selected area.
if lca1617 ne x HRI_Group1617 = 'Not in LA'.
if lca1718 ne x HRI_Group1718 = 'Not in LA'.
if lca1415 ne x HRI_Group1415 = 'Not in LA'.
if lca1516 ne x HRI_Group1516 = 'Not in LA'.
exe.

* Add death marker.
if date_death < 20170401 HRI_Group1718 = 'Died'.
if date_death < 20160401 HRI_Group1617 = 'Died'.
if date_death < 20150401 HRI_Group1516 = 'Died'.
if date_death > 20170401 and HRI_Group1718 = ' ' HRI_Group1718 = 'Died'.
EXE.


* Assume any blanks are now showing no contact in year.
if HRI_Group1516 = ' ' HRI_Group1516 = 'No Contact'.
if HRI_Group1415 = ' ' HRI_Group1415 = 'No Contact'.
if HRI_Group1718 = ' ' HRI_Group1718 = 'No Contact'.
if HRI_Group1617 = ' ' HRI_Group1617 = 'No Contact'.
EXE.


* Correct some codings where individuals dies after moving LA. If no contact can assume stayed in same LA..
if HRI_Group1516 = "Died" and HRI_Group1415 = "Not in LA" HRI_Group1516 = "Not in LA".
if HRI_Group1617 = "Died" and HRI_Group1516 = "Not in LA" HRI_Group1617 = "Not in LA".
if HRI_Group1718 = "Died" and HRI_Group1617 = "Not in LA" HRI_Group1718 = "Not in LA".
EXE.


* Remove Costs data for those not in LA.
if HRI_Group1516 = "Not in LA" health_net_cost1516 = 0.
if HRI_Group1415 = "Not in LA" health_net_cost1415 = 0.
if HRI_Group1718 = "Not in LA" health_net_cost1718 = 0.
if HRI_Group1617 = "Not in LA" health_net_cost1617 = 0.
EXE.

* Remove Costs data for those Died before start of FY.
if HRI_Group1516 = "Died" health_net_cost1516 = 0.
if HRI_Group1415 = "Died" health_net_cost1415 = 0.
if HRI_Group1718 = "Died" health_net_cost1718 = 0.
if HRI_Group1617 = "Died" health_net_cost1617 = 0.
EXE.


compute LCA_Select = x.
EXE.

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
EXE.


string PathwayLKP (A100).
exe.

compute PathwayLKP = concat(rtrim(HRI_Group1415), rtrim(HRI_Group1516), rtrim(HRI_Group1617), rtrim(HRI_Group1718)).
exe. 

save outfile  = !OFilesL + 'temp_HRI_LAT2.sav'.

* Agg Age.
get file  = !OFilesL + 'temp_HRI_LAT1.sav'.

select if AgeBand = "All".
select if  GenderSTR NE "Both".
EXE.

string PathwayLKP (A100).

compute PathwayLKP = concat(rtrim(HRI_Group1415), rtrim(HRI_Group1516), rtrim(HRI_Group1617), rtrim(HRI_Group1718)).
exe. 

save outfile  = !OFilesL + 'temp_HRI_LAT3.sav'.

* Agg Gender.
get file  = !OFilesL + 'temp_HRI_LAT1.sav'.

select if GenderSTR = "Both".
select if AgeBand NE "All".
EXE.

string PathwayLKP (A100).
exe.


compute PathwayLKP = concat(rtrim(HRI_Group1415), rtrim(HRI_Group1516), rtrim(HRI_Group1617), rtrim(HRI_Group1718)).
exe. 

save outfile  = !OFilesL + 'temp_HRI_LAT4.sav'.

* Agg Age & Gender.
get file  = !OFilesL + 'temp_HRI_LAT1.sav'.

select if  GenderSTR = "Both".
select if AgeBand = "All".
EXE.

string PathwayLKP (A100).

compute PathwayLKP = concat(rtrim(HRI_Group1415), rtrim(HRI_Group1516), rtrim(HRI_Group1617), rtrim(HRI_Group1718)).
exe. 

save outfile  = !OFilesL + 'temp_HRI_LAT5.sav'.

*bring files togther.
add files file = !OFilesL + 'temp_HRI_LAT2.sav'
/file = !OFilesL + 'temp_HRI_LAT3.sav'
/file = !OFilesL + 'temp_HRI_LAT4.sav'
/file = !OFilesL + 'temp_HRI_LAT5.sav'.
EXE.

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
compute PathwayLKP = concat(STRING (LCA_Select,F8),PathwayLKP).
EXE.
*Remove all spaces from PathwayLKP.
COMPUTE PathwayLKP = REPLACE(PathwayLKP, " ", "").
EXE.
* Create a Pathway Label for use in Tableau.
string PathwayLabel (A100).

compute PathwayLabel = concat(HRI_Group1415, ' - ', HRI_Group1516, ' - ', HRI_Group1617, HRI_Group1718, ' - ').
exe. 

* Need to save out Pathway lookup to match on the original CHIMASTER level data.
save outfile  = !OFilesL + 'temp_HRI_LA_ALLYR_CHI24.sav'
/keep chi LCA_select PathwayLKP PathwayLabel HRI_Group1617 HRI_Group1718 HRI_Group1415 HRI_Group1516 remove.

* Remove mis-match records.
select if Remove NE 1.
exe.

AGGREGATE
  /OUTFILE=*
  /BREAK=LCA_Select genderSTR AgeBand HRI_Group1617 HRI_Group1718 HRI_Group1415 HRI_Group1516 PathwayLKP PathwayLabel
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

save outfile  = !OFilesL + 'temp_HRI_LA_ALLYR24.sav'.

** LA 25.
get file  = !OFilesL + 'temp_HRI_LA_MASTER_ALLYR.sav'.

* Set LA.
compute x = 25.
EXE.

* Identify selected individuals in selected LA.

compute LCAFlag = 0.
if LCA1617 = x LCAFlag = 1.
if LCA1718 = x LCAFlag = 1.
if LCA1415 = x LCAFlag = 1.
if LCA1516 = x LCAFlag = 1.

select if LCAFlag = 1.
EXE.
 
* Identify any individuals that wheren't in selected area.
if lca1617 ne x HRI_Group1617 = 'Not in LA'.
if lca1718 ne x HRI_Group1718 = 'Not in LA'.
if lca1415 ne x HRI_Group1415 = 'Not in LA'.
if lca1516 ne x HRI_Group1516 = 'Not in LA'.
exe.

* Add death marker.
if date_death < 20170401 HRI_Group1718 = 'Died'.
if date_death < 20160401 HRI_Group1617 = 'Died'.
if date_death < 20150401 HRI_Group1516 = 'Died'.
if date_death > 20170401 and HRI_Group1718 = ' ' HRI_Group1718 = 'Died'.
EXE.


* Assume any blanks are now showing no contact in year.
if HRI_Group1516 = ' ' HRI_Group1516 = 'No Contact'.
if HRI_Group1415 = ' ' HRI_Group1415 = 'No Contact'.
if HRI_Group1718 = ' ' HRI_Group1718 = 'No Contact'.
if HRI_Group1617 = ' ' HRI_Group1617 = 'No Contact'.
EXE.


* Correct some codings where individuals dies after moving LA. If no contact can assume stayed in same LA..
if HRI_Group1516 = "Died" and HRI_Group1415 = "Not in LA" HRI_Group1516 = "Not in LA".
if HRI_Group1617 = "Died" and HRI_Group1516 = "Not in LA" HRI_Group1617 = "Not in LA".
if HRI_Group1718 = "Died" and HRI_Group1617 = "Not in LA" HRI_Group1718 = "Not in LA".
EXE.


* Remove Costs data for those not in LA.
if HRI_Group1516 = "Not in LA" health_net_cost1516 = 0.
if HRI_Group1415 = "Not in LA" health_net_cost1415 = 0.
if HRI_Group1718 = "Not in LA" health_net_cost1718 = 0.
if HRI_Group1617 = "Not in LA" health_net_cost1617 = 0.
EXE.

* Remove Costs data for those Died before start of FY.
if HRI_Group1516 = "Died" health_net_cost1516 = 0.
if HRI_Group1415 = "Died" health_net_cost1415 = 0.
if HRI_Group1718 = "Died" health_net_cost1718 = 0.
if HRI_Group1617 = "Died" health_net_cost1617 = 0.
EXE.


compute LCA_Select = x.
EXE.

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
EXE.


string PathwayLKP (A100).
exe.

compute PathwayLKP = concat(rtrim(HRI_Group1415), rtrim(HRI_Group1516), rtrim(HRI_Group1617), rtrim(HRI_Group1718)).
exe. 

save outfile  = !OFilesL + 'temp_HRI_LAT2.sav'.

* Agg Age.
get file  = !OFilesL + 'temp_HRI_LAT1.sav'.

select if AgeBand = "All".
select if  GenderSTR NE "Both".
EXE.

string PathwayLKP (A100).

compute PathwayLKP = concat(rtrim(HRI_Group1415), rtrim(HRI_Group1516), rtrim(HRI_Group1617), rtrim(HRI_Group1718)).
exe. 

save outfile  = !OFilesL + 'temp_HRI_LAT3.sav'.

* Agg Gender.
get file  = !OFilesL + 'temp_HRI_LAT1.sav'.

select if GenderSTR = "Both".
select if AgeBand NE "All".
EXE.

string PathwayLKP (A100).
exe.


compute PathwayLKP = concat(rtrim(HRI_Group1415), rtrim(HRI_Group1516), rtrim(HRI_Group1617), rtrim(HRI_Group1718)).
exe. 

save outfile  = !OFilesL + 'temp_HRI_LAT4.sav'.

* Agg Age & Gender.
get file  = !OFilesL + 'temp_HRI_LAT1.sav'.

select if  GenderSTR = "Both".
select if AgeBand = "All".
EXE.

string PathwayLKP (A100).

compute PathwayLKP = concat(rtrim(HRI_Group1415), rtrim(HRI_Group1516), rtrim(HRI_Group1617), rtrim(HRI_Group1718)).
exe. 

save outfile  = !OFilesL + 'temp_HRI_LAT5.sav'.

*bring files togther.
add files file = !OFilesL + 'temp_HRI_LAT2.sav'
/file = !OFilesL + 'temp_HRI_LAT3.sav'
/file = !OFilesL + 'temp_HRI_LAT4.sav'
/file = !OFilesL + 'temp_HRI_LAT5.sav'.
EXE.

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
compute PathwayLKP = concat(STRING (LCA_Select,F8),PathwayLKP).
EXE.
*Remove all spaces from PathwayLKP.
COMPUTE PathwayLKP = REPLACE(PathwayLKP, " ", "").
EXE.
* Create a Pathway Label for use in Tableau.
string PathwayLabel (A100).

compute PathwayLabel = concat(HRI_Group1415, ' - ', HRI_Group1516, ' - ', HRI_Group1617, HRI_Group1718, ' - ').
exe. 

* Need to save out Pathway lookup to match on the original CHIMASTER level data.
save outfile  = !OFilesL + 'temp_HRI_LA_ALLYR_CHI25.sav'
/keep chi LCA_select PathwayLKP PathwayLabel HRI_Group1617 HRI_Group1718 HRI_Group1415 HRI_Group1516 remove.

* Remove mis-match records.
select if Remove NE 1.
exe.

AGGREGATE
  /OUTFILE=*
  /BREAK=LCA_Select genderSTR AgeBand HRI_Group1617 HRI_Group1718 HRI_Group1415 HRI_Group1516 PathwayLKP PathwayLabel
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

save outfile  = !OFilesL + 'temp_HRI_LA_ALLYR25.sav'.

** LA 26.
get file  = !OFilesL + 'temp_HRI_LA_MASTER_ALLYR.sav'.

* Set LA.
compute x = 26.
EXE.

* Identify selected individuals in selected LA.

compute LCAFlag = 0.
if LCA1617 = x LCAFlag = 1.
if LCA1718 = x LCAFlag = 1.
if LCA1415 = x LCAFlag = 1.
if LCA1516 = x LCAFlag = 1.

select if LCAFlag = 1.
EXE.
 
* Identify any individuals that wheren't in selected area.
if lca1617 ne x HRI_Group1617 = 'Not in LA'.
if lca1718 ne x HRI_Group1718 = 'Not in LA'.
if lca1415 ne x HRI_Group1415 = 'Not in LA'.
if lca1516 ne x HRI_Group1516 = 'Not in LA'.
exe.

* Add death marker.
if date_death < 20170401 HRI_Group1718 = 'Died'.
if date_death < 20160401 HRI_Group1617 = 'Died'.
if date_death < 20150401 HRI_Group1516 = 'Died'.
if date_death > 20170401 and HRI_Group1718 = ' ' HRI_Group1718 = 'Died'.
EXE.

* Assume any blanks are now showing no contact in year.
if HRI_Group1516 = ' ' HRI_Group1516 = 'No Contact'.
if HRI_Group1415 = ' ' HRI_Group1415 = 'No Contact'.
if HRI_Group1718 = ' ' HRI_Group1718 = 'No Contact'.
if HRI_Group1617 = ' ' HRI_Group1617 = 'No Contact'.
EXE.


* Correct some codings where individuals dies after moving LA. If no contact can assume stayed in same LA..
if HRI_Group1516 = "Died" and HRI_Group1415 = "Not in LA" HRI_Group1516 = "Not in LA".
if HRI_Group1617 = "Died" and HRI_Group1516 = "Not in LA" HRI_Group1617 = "Not in LA".
if HRI_Group1718 = "Died" and HRI_Group1617 = "Not in LA" HRI_Group1718 = "Not in LA".
EXE.


* Remove Costs data for those not in LA.
if HRI_Group1516 = "Not in LA" health_net_cost1516 = 0.
if HRI_Group1415 = "Not in LA" health_net_cost1415 = 0.
if HRI_Group1718 = "Not in LA" health_net_cost1718 = 0.
if HRI_Group1617 = "Not in LA" health_net_cost1617 = 0.
EXE.

* Remove Costs data for those Died before start of FY.
if HRI_Group1516 = "Died" health_net_cost1516 = 0.
if HRI_Group1415 = "Died" health_net_cost1415 = 0.
if HRI_Group1718 = "Died" health_net_cost1718 = 0.
if HRI_Group1617 = "Died" health_net_cost1617 = 0.
EXE.


compute LCA_Select = x.
EXE.

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
EXE.


string PathwayLKP (A100).
exe.

compute PathwayLKP = concat(rtrim(HRI_Group1415), rtrim(HRI_Group1516), rtrim(HRI_Group1617), rtrim(HRI_Group1718)).
exe. 

save outfile  = !OFilesL + 'temp_HRI_LAT2.sav'.

* Agg Age.
get file  = !OFilesL + 'temp_HRI_LAT1.sav'.

select if AgeBand = "All".
select if  GenderSTR NE "Both".
EXE.

string PathwayLKP (A100).

compute PathwayLKP = concat(rtrim(HRI_Group1415), rtrim(HRI_Group1516), rtrim(HRI_Group1617), rtrim(HRI_Group1718)).
exe. 

save outfile  = !OFilesL + 'temp_HRI_LAT3.sav'.

* Agg Gender.
get file  = !OFilesL + 'temp_HRI_LAT1.sav'.

select if GenderSTR = "Both".
select if AgeBand NE "All".
EXE.

string PathwayLKP (A100).
exe.


compute PathwayLKP = concat(rtrim(HRI_Group1415), rtrim(HRI_Group1516), rtrim(HRI_Group1617), rtrim(HRI_Group1718)).
exe. 

save outfile  = !OFilesL + 'temp_HRI_LAT4.sav'.

* Agg Age & Gender.
get file  = !OFilesL + 'temp_HRI_LAT1.sav'.

select if  GenderSTR = "Both".
select if AgeBand = "All".
EXE.

string PathwayLKP (A100).

compute PathwayLKP = concat(rtrim(HRI_Group1415), rtrim(HRI_Group1516), rtrim(HRI_Group1617), rtrim(HRI_Group1718)).
exe. 

save outfile  = !OFilesL + 'temp_HRI_LAT5.sav'.

*bring files togther.
add files file = !OFilesL + 'temp_HRI_LAT2.sav'
/file = !OFilesL + 'temp_HRI_LAT3.sav'
/file = !OFilesL + 'temp_HRI_LAT4.sav'
/file = !OFilesL + 'temp_HRI_LAT5.sav'.
EXE.

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
compute PathwayLKP = concat(STRING (LCA_Select,F8),PathwayLKP).
EXE.
*Remove all spaces from PathwayLKP.
COMPUTE PathwayLKP = REPLACE(PathwayLKP, " ", "").
EXE.
* Create a Pathway Label for use in Tableau.
string PathwayLabel (A100).

compute PathwayLabel = concat(HRI_Group1415, ' - ', HRI_Group1516, ' - ', HRI_Group1617, HRI_Group1718, ' - ').
exe. 

* Need to save out Pathway lookup to match on the original CHIMASTER level data.
save outfile  = !OFilesL + 'temp_HRI_LA_ALLYR_CHI26.sav'
/keep chi LCA_select PathwayLKP PathwayLabel HRI_Group1617 HRI_Group1718 HRI_Group1415 HRI_Group1516 remove.

* Remove mis-match records.
select if Remove NE 1.
exe.

AGGREGATE
  /OUTFILE=*
  /BREAK=LCA_Select genderSTR AgeBand HRI_Group1617 HRI_Group1718 HRI_Group1415 HRI_Group1516 PathwayLKP PathwayLabel
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

save outfile  = !OFilesL + 'temp_HRI_LA_ALLYR26.sav'.

** LA 27.
get file  = !OFilesL + 'temp_HRI_LA_MASTER_ALLYR.sav'.

* Set LA.
compute x = 27.
EXE.

* Identify selected individuals in selected LA.

compute LCAFlag = 0.
if LCA1617 = x LCAFlag = 1.
if LCA1718 = x LCAFlag = 1.
if LCA1415 = x LCAFlag = 1.
if LCA1516 = x LCAFlag = 1.

select if LCAFlag = 1.
EXE.
 
* Identify any individuals that wheren't in selected area.
if lca1617 ne x HRI_Group1617 = 'Not in LA'.
if lca1718 ne x HRI_Group1718 = 'Not in LA'.
if lca1415 ne x HRI_Group1415 = 'Not in LA'.
if lca1516 ne x HRI_Group1516 = 'Not in LA'.
exe.

* Add death marker.
if date_death < 20170401 HRI_Group1718 = 'Died'.
if date_death < 20160401 HRI_Group1617 = 'Died'.
if date_death < 20150401 HRI_Group1516 = 'Died'.
if date_death > 20170401 and HRI_Group1718 = ' ' HRI_Group1718 = 'Died'.
EXE.


* Assume any blanks are now showing no contact in year.
if HRI_Group1516 = ' ' HRI_Group1516 = 'No Contact'.
if HRI_Group1415 = ' ' HRI_Group1415 = 'No Contact'.
if HRI_Group1718 = ' ' HRI_Group1718 = 'No Contact'.
if HRI_Group1617 = ' ' HRI_Group1617 = 'No Contact'.
EXE.


* Correct some codings where individuals dies after moving LA. If no contact can assume stayed in same LA..
if HRI_Group1516 = "Died" and HRI_Group1415 = "Not in LA" HRI_Group1516 = "Not in LA".
if HRI_Group1617 = "Died" and HRI_Group1516 = "Not in LA" HRI_Group1617 = "Not in LA".
if HRI_Group1718 = "Died" and HRI_Group1617 = "Not in LA" HRI_Group1718 = "Not in LA".
EXE.


* Remove Costs data for those not in LA.
if HRI_Group1516 = "Not in LA" health_net_cost1516 = 0.
if HRI_Group1415 = "Not in LA" health_net_cost1415 = 0.
if HRI_Group1718 = "Not in LA" health_net_cost1718 = 0.
if HRI_Group1617 = "Not in LA" health_net_cost1617 = 0.
EXE.

* Remove Costs data for those Died before start of FY.
if HRI_Group1516 = "Died" health_net_cost1516 = 0.
if HRI_Group1415 = "Died" health_net_cost1415 = 0.
if HRI_Group1718 = "Died" health_net_cost1718 = 0.
if HRI_Group1617 = "Died" health_net_cost1617 = 0.
EXE.


compute LCA_Select = x.
EXE.

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
EXE.


string PathwayLKP (A100).
exe.

compute PathwayLKP = concat(rtrim(HRI_Group1415), rtrim(HRI_Group1516), rtrim(HRI_Group1617), rtrim(HRI_Group1718)).
exe. 

save outfile  = !OFilesL + 'temp_HRI_LAT2.sav'.

* Agg Age.
get file  = !OFilesL + 'temp_HRI_LAT1.sav'.

select if AgeBand = "All".
select if  GenderSTR NE "Both".
EXE.

string PathwayLKP (A100).

compute PathwayLKP = concat(rtrim(HRI_Group1415), rtrim(HRI_Group1516), rtrim(HRI_Group1617), rtrim(HRI_Group1718)).
exe. 

save outfile  = !OFilesL + 'temp_HRI_LAT3.sav'.

* Agg Gender.
get file  = !OFilesL + 'temp_HRI_LAT1.sav'.

select if GenderSTR = "Both".
select if AgeBand NE "All".
EXE.

string PathwayLKP (A100).
exe.


compute PathwayLKP = concat(rtrim(HRI_Group1415), rtrim(HRI_Group1516), rtrim(HRI_Group1617), rtrim(HRI_Group1718)).
exe. 

save outfile  = !OFilesL + 'temp_HRI_LAT4.sav'.

* Agg Age & Gender.
get file  = !OFilesL + 'temp_HRI_LAT1.sav'.

select if  GenderSTR = "Both".
select if AgeBand = "All".
EXE.

string PathwayLKP (A100).

compute PathwayLKP = concat(rtrim(HRI_Group1415), rtrim(HRI_Group1516), rtrim(HRI_Group1617), rtrim(HRI_Group1718)).
exe. 

save outfile  = !OFilesL + 'temp_HRI_LAT5.sav'.

*bring files togther.
add files file = !OFilesL + 'temp_HRI_LAT2.sav'
/file = !OFilesL + 'temp_HRI_LAT3.sav'
/file = !OFilesL + 'temp_HRI_LAT4.sav'
/file = !OFilesL + 'temp_HRI_LAT5.sav'.
EXE.

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
compute PathwayLKP = concat(STRING (LCA_Select,F8),PathwayLKP).
EXE.
*Remove all spaces from PathwayLKP.
COMPUTE PathwayLKP = REPLACE(PathwayLKP, " ", "").
EXE.
* Create a Pathway Label for use in Tableau.
string PathwayLabel (A100).

compute PathwayLabel = concat(HRI_Group1415, ' - ', HRI_Group1516, ' - ', HRI_Group1617, HRI_Group1718, ' - ').
exe. 

* Need to save out Pathway lookup to match on the original CHIMASTER level data.
save outfile  = !OFilesL + 'temp_HRI_LA_ALLYR_CHI27.sav'
/keep chi LCA_select PathwayLKP PathwayLabel HRI_Group1617 HRI_Group1718 HRI_Group1415 HRI_Group1516 remove.

* Remove mis-match records.
select if Remove NE 1.
exe.

AGGREGATE
  /OUTFILE=*
  /BREAK=LCA_Select genderSTR AgeBand HRI_Group1617 HRI_Group1718 HRI_Group1415 HRI_Group1516 PathwayLKP PathwayLabel
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
save outfile  = !OFilesL + 'temp_HRI_LA_ALLYR27.sav'.

** LA 28.
get file  = !OFilesL + 'temp_HRI_LA_MASTER_ALLYR.sav'.

* Set LA.
compute x = 28.
EXE.

* Identify selected individuals in selected LA.

compute LCAFlag = 0.
if LCA1617 = x LCAFlag = 1.
if LCA1718 = x LCAFlag = 1.
if LCA1415 = x LCAFlag = 1.
if LCA1516 = x LCAFlag = 1.

select if LCAFlag = 1.
EXE.
 
* Identify any individuals that wheren't in selected area.
if lca1617 ne x HRI_Group1617 = 'Not in LA'.
if lca1718 ne x HRI_Group1718 = 'Not in LA'.
if lca1415 ne x HRI_Group1415 = 'Not in LA'.
if lca1516 ne x HRI_Group1516 = 'Not in LA'.
exe.

* Add death marker.
if date_death < 20170401 HRI_Group1718 = 'Died'.
if date_death < 20160401 HRI_Group1617 = 'Died'.
if date_death < 20150401 HRI_Group1516 = 'Died'.
if date_death > 20170401 and HRI_Group1718 = ' ' HRI_Group1718 = 'Died'.
EXE.


* Assume any blanks are now showing no contact in year.
if HRI_Group1516 = ' ' HRI_Group1516 = 'No Contact'.
if HRI_Group1415 = ' ' HRI_Group1415 = 'No Contact'.
if HRI_Group1718 = ' ' HRI_Group1718 = 'No Contact'.
if HRI_Group1617 = ' ' HRI_Group1617 = 'No Contact'.
EXECUTE.


* Correct some codings where individuals dies after moving LA. If no contact can assume stayed in same LA..
if HRI_Group1516 = "Died" and HRI_Group1415 = "Not in LA" HRI_Group1516 = "Not in LA".
if HRI_Group1617 = "Died" and HRI_Group1516 = "Not in LA" HRI_Group1617 = "Not in LA".
if HRI_Group1718 = "Died" and HRI_Group1617 = "Not in LA" HRI_Group1718 = "Not in LA".
EXE.


* Remove Costs data for those not in LA.
if HRI_Group1516 = "Not in LA" health_net_cost1516 = 0.
if HRI_Group1415 = "Not in LA" health_net_cost1415 = 0.
if HRI_Group1718 = "Not in LA" health_net_cost1718 = 0.
if HRI_Group1617 = "Not in LA" health_net_cost1617 = 0.
EXE.

* Remove Costs data for those Died before start of FY.
if HRI_Group1516 = "Died" health_net_cost1516 = 0.
if HRI_Group1415 = "Died" health_net_cost1415 = 0.
if HRI_Group1718 = "Died" health_net_cost1718 = 0.
if HRI_Group1617 = "Died" health_net_cost1617 = 0.
EXE.


compute LCA_Select = x.
EXE.

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
EXE.


string PathwayLKP (A100).
exe.

compute PathwayLKP = concat(rtrim(HRI_Group1415), rtrim(HRI_Group1516), rtrim(HRI_Group1617), rtrim(HRI_Group1718)).
exe. 

save outfile  = !OFilesL + 'temp_HRI_LAT2.sav'.

* Agg Age.
get file  = !OFilesL + 'temp_HRI_LAT1.sav'.

select if AgeBand = "All".
select if  GenderSTR NE "Both".
EXE.

string PathwayLKP (A100).

compute PathwayLKP = concat(rtrim(HRI_Group1415), rtrim(HRI_Group1516), rtrim(HRI_Group1617), rtrim(HRI_Group1718)).
exe. 

save outfile  = !OFilesL + 'temp_HRI_LAT3.sav'.

* Agg Gender.
get file  = !OFilesL + 'temp_HRI_LAT1.sav'.

select if GenderSTR = "Both".
select if AgeBand NE "All".
EXE.

string PathwayLKP (A100).
exe.


compute PathwayLKP = concat(rtrim(HRI_Group1415), rtrim(HRI_Group1516), rtrim(HRI_Group1617), rtrim(HRI_Group1718)).
exe. 

save outfile  = !OFilesL + 'temp_HRI_LAT4.sav'.

* Agg Age & Gender.
get file  = !OFilesL + 'temp_HRI_LAT1.sav'.

select if  GenderSTR = "Both".
select if AgeBand = "All".
EXE.

string PathwayLKP (A100).

compute PathwayLKP = concat(rtrim(HRI_Group1415), rtrim(HRI_Group1516), rtrim(HRI_Group1617), rtrim(HRI_Group1718)).

save outfile  = !OFilesL + 'temp_HRI_LAT5.sav'.

*bring files togther.
add files file = !OFilesL + 'temp_HRI_LAT2.sav'
/file = !OFilesL + 'temp_HRI_LAT3.sav'
/file = !OFilesL + 'temp_HRI_LAT4.sav'
/file = !OFilesL + 'temp_HRI_LAT5.sav'.
EXE.

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
compute PathwayLKP = concat(STRING (LCA_Select,F8),PathwayLKP).
EXE.
*Remove all spaces from PathwayLKP.
COMPUTE PathwayLKP = REPLACE(PathwayLKP, " ", "").
EXE.
* Create a Pathway Label for use in Tableau.
string PathwayLabel (A100).

compute PathwayLabel = concat(HRI_Group1415, ' - ', HRI_Group1516, ' - ', HRI_Group1617, HRI_Group1718, ' - ').
exe. 

* Need to save out Pathway lookup to match on the original CHIMASTER level data.
save outfile  = !OFilesL + 'temp_HRI_LA_ALLYR_CHI28.sav'
/keep chi LCA_select PathwayLKP PathwayLabel HRI_Group1617 HRI_Group1718 HRI_Group1415 HRI_Group1516 remove.

* Remove mis-match records.
select if Remove NE 1.
exe.

AGGREGATE
  /OUTFILE=*
  /BREAK=LCA_Select genderSTR AgeBand HRI_Group1617 HRI_Group1718 HRI_Group1415 HRI_Group1516 PathwayLKP PathwayLabel
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

save outfile  = !OFilesL + 'temp_HRI_LA_ALLYR28.sav'.

** LA 29.
get file  = !OFilesL + 'temp_HRI_LA_MASTER_ALLYR.sav'.

* Set LA.
compute x = 29.
EXE.

* Identify selected individuals in selected LA.

compute LCAFlag = 0.
if LCA1617 = x LCAFlag = 1.
if LCA1718 = x LCAFlag = 1.
if LCA1415 = x LCAFlag = 1.
if LCA1516 = x LCAFlag = 1.

select if LCAFlag = 1.
EXE.
 
* Identify any individuals that wheren't in selected area.
if lca1617 ne x HRI_Group1617 = 'Not in LA'.
if lca1718 ne x HRI_Group1718 = 'Not in LA'.
if lca1415 ne x HRI_Group1415 = 'Not in LA'.
if lca1516 ne x HRI_Group1516 = 'Not in LA'.
exe.

* Add death marker.
if date_death < 20170401 HRI_Group1718 = 'Died'.
if date_death < 20160401 HRI_Group1617 = 'Died'.
if date_death < 20150401 HRI_Group1516 = 'Died'.
if date_death > 20170401 and HRI_Group1718 = ' ' HRI_Group1718 = 'Died'.
EXE.


* Assume any blanks are now showing no contact in year.
if HRI_Group1516 = ' ' HRI_Group1516 = 'No Contact'.
if HRI_Group1415 = ' ' HRI_Group1415 = 'No Contact'.
if HRI_Group1718 = ' ' HRI_Group1718 = 'No Contact'.
if HRI_Group1617 = ' ' HRI_Group1617 = 'No Contact'.
EXE.


* Correct some codings where individuals dies after moving LA. If no contact can assume stayed in same LA..
if HRI_Group1516 = "Died" and HRI_Group1415 = "Not in LA" HRI_Group1516 = "Not in LA".
if HRI_Group1617 = "Died" and HRI_Group1516 = "Not in LA" HRI_Group1617 = "Not in LA".
if HRI_Group1718 = "Died" and HRI_Group1617 = "Not in LA" HRI_Group1718 = "Not in LA".
EXE.


* Remove Costs data for those not in LA.
if HRI_Group1516 = "Not in LA" health_net_cost1516 = 0.
if HRI_Group1415 = "Not in LA" health_net_cost1415 = 0.
if HRI_Group1718 = "Not in LA" health_net_cost1718 = 0.
if HRI_Group1617 = "Not in LA" health_net_cost1617 = 0.
EXE.

* Remove Costs data for those Died before start of FY.
if HRI_Group1516 = "Died" health_net_cost1516 = 0.
if HRI_Group1415 = "Died" health_net_cost1415 = 0.
if HRI_Group1718 = "Died" health_net_cost1718 = 0.
if HRI_Group1617 = "Died" health_net_cost1617 = 0.
EXE.


compute LCA_Select = x.
EXE.

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
EXE.


string PathwayLKP (A100).
exe.

compute PathwayLKP = concat(rtrim(HRI_Group1415), rtrim(HRI_Group1516), rtrim(HRI_Group1617), rtrim(HRI_Group1718)).
exe. 

save outfile  = !OFilesL + 'temp_HRI_LAT2.sav'.

* Agg Age.
get file  = !OFilesL + 'temp_HRI_LAT1.sav'.

select if AgeBand = "All".
select if  GenderSTR NE "Both".
EXE.

string PathwayLKP (A100).

compute PathwayLKP = concat(rtrim(HRI_Group1415), rtrim(HRI_Group1516), rtrim(HRI_Group1617), rtrim(HRI_Group1718)).
exe. 

save outfile  = !OFilesL + 'temp_HRI_LAT3.sav'.

* Agg Gender.
get file  = !OFilesL + 'temp_HRI_LAT1.sav'.

select if GenderSTR = "Both".
select if AgeBand NE "All".
EXE.

string PathwayLKP (A100).
exe.


compute PathwayLKP = concat(rtrim(HRI_Group1415), rtrim(HRI_Group1516), rtrim(HRI_Group1617), rtrim(HRI_Group1718)).
exe. 

save outfile  = !OFilesL + 'temp_HRI_LAT4.sav'.

* Agg Age & Gender.
get file  = !OFilesL + 'temp_HRI_LAT1.sav'.

select if  GenderSTR = "Both".
select if AgeBand = "All".
EXE.

string PathwayLKP (A100).

compute PathwayLKP = concat(rtrim(HRI_Group1415), rtrim(HRI_Group1516), rtrim(HRI_Group1617), rtrim(HRI_Group1718)).
exe. 

save outfile  = !OFilesL + 'temp_HRI_LAT5.sav'.

*bring files togther.
add files file = !OFilesL + 'temp_HRI_LAT2.sav'
/file = !OFilesL + 'temp_HRI_LAT3.sav'
/file = !OFilesL + 'temp_HRI_LAT4.sav'
/file = !OFilesL + 'temp_HRI_LAT5.sav'.
EXE.

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
compute PathwayLKP = concat(STRING (LCA_Select,F8),PathwayLKP).
EXE.
*Remove all spaces from PathwayLKP.
COMPUTE PathwayLKP = REPLACE(PathwayLKP, " ", "").
EXE.
* Create a Pathway Label for use in Tableau.
string PathwayLabel (A100).

compute PathwayLabel = concat(HRI_Group1415, ' - ', HRI_Group1516, ' - ', HRI_Group1617, HRI_Group1718, ' - ').
exe. 

* Need to save out Pathway lookup to match on the original CHIMASTER level data.
save outfile  = !OFilesL + 'temp_HRI_LA_ALLYR_CHI29.sav'
/keep chi LCA_select PathwayLKP PathwayLabel HRI_Group1617 HRI_Group1718 HRI_Group1415 HRI_Group1516 remove.

* Remove mis-match records.
select if Remove NE 1.
exe.

AGGREGATE
  /OUTFILE=*
  /BREAK=LCA_Select genderSTR AgeBand HRI_Group1617 HRI_Group1718 HRI_Group1415 HRI_Group1516 PathwayLKP PathwayLabel
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
save outfile  = !OFilesL + 'temp_HRI_LA_ALLYR29.sav'.

** LA 30.
get file  = !OFilesL + 'temp_HRI_LA_MASTER_ALLYR.sav'.

* Set LA.
compute x = 30.
EXE.

* Identify selected individuals in selected LA.

compute LCAFlag = 0.
if LCA1617 = x LCAFlag = 1.
if LCA1718 = x LCAFlag = 1.
if LCA1415 = x LCAFlag = 1.
if LCA1516 = x LCAFlag = 1.

select if LCAFlag = 1.
EXE.
 
* Identify any individuals that wheren't in selected area.
if lca1617 ne x HRI_Group1617 = 'Not in LA'.
if lca1718 ne x HRI_Group1718 = 'Not in LA'.
if lca1415 ne x HRI_Group1415 = 'Not in LA'.
if lca1516 ne x HRI_Group1516 = 'Not in LA'.
exe.

* Add death marker.
if date_death < 20170401 HRI_Group1718 = 'Died'.
if date_death < 20160401 HRI_Group1617 = 'Died'.
if date_death < 20150401 HRI_Group1516 = 'Died'.
if date_death > 20170401 and HRI_Group1718 = ' ' HRI_Group1718 = 'Died'.
EXE.


* Assume any blanks are now showing no contact in year.
if HRI_Group1516 = ' ' HRI_Group1516 = 'No Contact'.
if HRI_Group1415 = ' ' HRI_Group1415 = 'No Contact'.
if HRI_Group1718 = ' ' HRI_Group1718 = 'No Contact'.
if HRI_Group1617 = ' ' HRI_Group1617 = 'No Contact'.
EXE.


* Correct some codings where individuals dies after moving LA. If no contact can assume stayed in same LA..
if HRI_Group1516 = "Died" and HRI_Group1415 = "Not in LA" HRI_Group1516 = "Not in LA".
if HRI_Group1617 = "Died" and HRI_Group1516 = "Not in LA" HRI_Group1617 = "Not in LA".
if HRI_Group1718 = "Died" and HRI_Group1617 = "Not in LA" HRI_Group1718 = "Not in LA".
EXE.


* Remove Costs data for those not in LA.
if HRI_Group1516 = "Not in LA" health_net_cost1516 = 0.
if HRI_Group1415 = "Not in LA" health_net_cost1415 = 0.
if HRI_Group1718 = "Not in LA" health_net_cost1718 = 0.
if HRI_Group1617 = "Not in LA" health_net_cost1617 = 0.
EXE.

* Remove Costs data for those Died before start of FY.
if HRI_Group1516 = "Died" health_net_cost1516 = 0.
if HRI_Group1415 = "Died" health_net_cost1415 = 0.
if HRI_Group1718 = "Died" health_net_cost1718 = 0.
if HRI_Group1617 = "Died" health_net_cost1617 = 0.
EXE.


compute LCA_Select = x.
EXE.

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
EXE.


string PathwayLKP (A100).
exe.

compute PathwayLKP = concat(rtrim(HRI_Group1415), rtrim(HRI_Group1516), rtrim(HRI_Group1617), rtrim(HRI_Group1718)).
exe. 

save outfile  = !OFilesL + 'temp_HRI_LAT2.sav'.

* Agg Age.
get file  = !OFilesL + 'temp_HRI_LAT1.sav'.

select if AgeBand = "All".
select if  GenderSTR NE "Both".
EXE.

string PathwayLKP (A100).

compute PathwayLKP = concat(rtrim(HRI_Group1415), rtrim(HRI_Group1516), rtrim(HRI_Group1617), rtrim(HRI_Group1718)).
exe. 

save outfile  = !OFilesL + 'temp_HRI_LAT3.sav'.

* Agg Gender.
get file  = !OFilesL + 'temp_HRI_LAT1.sav'.

select if GenderSTR = "Both".
select if AgeBand NE "All".
EXE.

string PathwayLKP (A100).
exe.


compute PathwayLKP = concat(rtrim(HRI_Group1415), rtrim(HRI_Group1516), rtrim(HRI_Group1617), rtrim(HRI_Group1718)).
exe. 

save outfile  = !OFilesL + 'temp_HRI_LAT4.sav'.

* Agg Age & Gender.
get file  = !OFilesL + 'temp_HRI_LAT1.sav'.

select if  GenderSTR = "Both".
select if AgeBand = "All".
EXE.

string PathwayLKP (A100).

compute PathwayLKP = concat(rtrim(HRI_Group1415), rtrim(HRI_Group1516), rtrim(HRI_Group1617), rtrim(HRI_Group1718)).
exe. 

save outfile  = !OFilesL + 'temp_HRI_LAT5.sav'.

*bring files togther.
add files file = !OFilesL + 'temp_HRI_LAT2.sav'
/file = !OFilesL + 'temp_HRI_LAT3.sav'
/file = !OFilesL + 'temp_HRI_LAT4.sav'
/file = !OFilesL + 'temp_HRI_LAT5.sav'.
EXE.

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
compute PathwayLKP = concat(STRING (LCA_Select,F8),PathwayLKP).
EXE.
*Remove all spaces from PathwayLKP.
COMPUTE PathwayLKP = REPLACE(PathwayLKP, " ", "").
EXE.
* Create a Pathway Label for use in Tableau.
string PathwayLabel (A100).

compute PathwayLabel = concat(HRI_Group1415, ' - ', HRI_Group1516, ' - ', HRI_Group1617, HRI_Group1718, ' - ').
exe. 

* Need to save out Pathway lookup to match on the original CHIMASTER level data.
save outfile  = !OFilesL + 'temp_HRI_LA_ALLYR_CHI30.sav'
/keep chi LCA_select PathwayLKP PathwayLabel HRI_Group1617 HRI_Group1718 HRI_Group1415 HRI_Group1516 remove.

* Remove mis-match records.
select if Remove NE 1.
exe.

AGGREGATE
  /OUTFILE=*
  /BREAK=LCA_Select genderSTR AgeBand HRI_Group1617 HRI_Group1718 HRI_Group1415 HRI_Group1516 PathwayLKP PathwayLabel
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
save outfile  = !OFilesL + 'temp_HRI_LA_ALLYR30.sav'.


** LA 31.
get file  = !OFilesL + 'temp_HRI_LA_MASTER_ALLYR.sav'.
* Set LA.
compute x = 31.
EXE.

* Identify selected individuals in selected LA.

compute LCAFlag = 0.
if LCA1617 = x LCAFlag = 1.
if LCA1718 = x LCAFlag = 1.
if LCA1415 = x LCAFlag = 1.
if LCA1516 = x LCAFlag = 1.

select if LCAFlag = 1.
EXE.
 
* Identify any individuals that wheren't in selected area.
if lca1617 ne x HRI_Group1617 = 'Not in LA'.
if lca1718 ne x HRI_Group1718 = 'Not in LA'.
if lca1415 ne x HRI_Group1415 = 'Not in LA'.
if lca1516 ne x HRI_Group1516 = 'Not in LA'.
exe.

* Add death marker.
if date_death < 20170401 HRI_Group1718 = 'Died'.
if date_death < 20160401 HRI_Group1617 = 'Died'.
if date_death < 20150401 HRI_Group1516 = 'Died'.
if date_death > 20170401 and HRI_Group1718 = ' ' HRI_Group1718 = 'Died'.
EXE.


* Assume any blanks are now showing no contact in year.
if HRI_Group1516 = ' ' HRI_Group1516 = 'No Contact'.
if HRI_Group1415 = ' ' HRI_Group1415 = 'No Contact'.
if HRI_Group1718 = ' ' HRI_Group1718 = 'No Contact'.
if HRI_Group1617 = ' ' HRI_Group1617 = 'No Contact'.
EXE.


* Correct some codings where individuals dies after moving LA. If no contact can assume stayed in same LA..
if HRI_Group1516 = "Died" and HRI_Group1415 = "Not in LA" HRI_Group1516 = "Not in LA".
if HRI_Group1617 = "Died" and HRI_Group1516 = "Not in LA" HRI_Group1617 = "Not in LA".
if HRI_Group1718 = "Died" and HRI_Group1617 = "Not in LA" HRI_Group1718 = "Not in LA".
EXE.


* Remove Costs data for those not in LA.
if HRI_Group1516 = "Not in LA" health_net_cost1516 = 0.
if HRI_Group1415 = "Not in LA" health_net_cost1415 = 0.
if HRI_Group1718 = "Not in LA" health_net_cost1718 = 0.
if HRI_Group1617 = "Not in LA" health_net_cost1617 = 0.
EXE.

* Remove Costs data for those Died before start of FY.
if HRI_Group1516 = "Died" health_net_cost1516 = 0.
if HRI_Group1415 = "Died" health_net_cost1415 = 0.
if HRI_Group1718 = "Died" health_net_cost1718 = 0.
if HRI_Group1617 = "Died" health_net_cost1617 = 0.
EXE.


compute LCA_Select = x.
EXE.

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
EXE.


string PathwayLKP (A100).
exe.

compute PathwayLKP = concat(rtrim(HRI_Group1415), rtrim(HRI_Group1516), rtrim(HRI_Group1617), rtrim(HRI_Group1718)).
exe. 

save outfile  = !OFilesL + 'temp_HRI_LAT2.sav'.

* Agg Age.
get file  = !OFilesL + 'temp_HRI_LAT1.sav'.

select if AgeBand = "All".
select if  GenderSTR NE "Both".
EXE.

string PathwayLKP (A100).

compute PathwayLKP = concat(rtrim(HRI_Group1415), rtrim(HRI_Group1516), rtrim(HRI_Group1617), rtrim(HRI_Group1718)).
exe. 

save outfile  = !OFilesL + 'temp_HRI_LAT3.sav'.

* Agg Gender.
get file  = !OFilesL + 'temp_HRI_LAT1.sav'.

select if GenderSTR = "Both".
select if AgeBand NE "All".
EXE.

string PathwayLKP (A100).
exe.


compute PathwayLKP = concat(rtrim(HRI_Group1415), rtrim(HRI_Group1516), rtrim(HRI_Group1617), rtrim(HRI_Group1718)).
exe. 

save outfile  = !OFilesL + 'temp_HRI_LAT4.sav'.

* Agg Age & Gender.
get file  = !OFilesL + 'temp_HRI_LAT1.sav'.

select if  GenderSTR = "Both".
select if AgeBand = "All".
EXE.

string PathwayLKP (A100).

compute PathwayLKP = concat(rtrim(HRI_Group1415), rtrim(HRI_Group1516), rtrim(HRI_Group1617), rtrim(HRI_Group1718)).
exe. 

save outfile  = !OFilesL + 'temp_HRI_LAT5.sav'.

*bring files togther.
add files file = !OFilesL + 'temp_HRI_LAT2.sav'
/file = !OFilesL + 'temp_HRI_LAT3.sav'
/file = !OFilesL + 'temp_HRI_LAT4.sav'
/file = !OFilesL + 'temp_HRI_LAT5.sav'.
EXE.

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
compute PathwayLKP = concat(STRING (LCA_Select,F8),PathwayLKP).
EXE.
*Remove all spaces from PathwayLKP.
COMPUTE PathwayLKP = REPLACE(PathwayLKP, " ", "").
EXE.
* Create a Pathway Label for use in Tableau.
string PathwayLabel (A100).

compute PathwayLabel = concat(HRI_Group1415, ' - ', HRI_Group1516, ' - ', HRI_Group1617, HRI_Group1718, ' - ').
exe. 

* Need to save out Pathway lookup to match on the original CHIMASTER level data.
save outfile  = !OFilesL + 'temp_HRI_LA_ALLYR_CHI31.sav'
/keep chi LCA_select PathwayLKP PathwayLabel HRI_Group1617 HRI_Group1718 HRI_Group1415 HRI_Group1516 remove.

* Remove mis-match records.
select if Remove NE 1.
exe.

AGGREGATE
  /OUTFILE=*
  /BREAK=LCA_Select genderSTR AgeBand HRI_Group1617 HRI_Group1718 HRI_Group1415 HRI_Group1516 PathwayLKP PathwayLabel
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

save outfile  = !OFilesL + 'temp_HRI_LA_ALLYR31.sav'.

** LA 32.
get file  = !OFilesL + 'temp_HRI_LA_MASTER_ALLYR.sav'.

* Set LA.
compute x = 32.
EXE.

* Identify selected individuals in selected LA.

compute LCAFlag = 0.
if LCA1617 = x LCAFlag = 1.
if LCA1718 = x LCAFlag = 1.
if LCA1415 = x LCAFlag = 1.
if LCA1516 = x LCAFlag = 1.

select if LCAFlag = 1.
EXE.
 
* Identify any individuals that wheren't in selected area.
if lca1617 ne x HRI_Group1617 = 'Not in LA'.
if lca1718 ne x HRI_Group1718 = 'Not in LA'.
if lca1415 ne x HRI_Group1415 = 'Not in LA'.
if lca1516 ne x HRI_Group1516 = 'Not in LA'.
exe.

* Add death marker.
if date_death < 20170401 HRI_Group1718 = 'Died'.
if date_death < 20160401 HRI_Group1617 = 'Died'.
if date_death < 20150401 HRI_Group1516 = 'Died'.
if date_death > 20170401 and HRI_Group1718 = ' ' HRI_Group1718 = 'Died'.
EXE.


* Assume any blanks are now showing no contact in year.
if HRI_Group1516 = ' ' HRI_Group1516 = 'No Contact'.
if HRI_Group1415 = ' ' HRI_Group1415 = 'No Contact'.
if HRI_Group1718 = ' ' HRI_Group1718 = 'No Contact'.
if HRI_Group1617 = ' ' HRI_Group1617 = 'No Contact'.
EXE.


* Correct some codings where individuals dies after moving LA. If no contact can assume stayed in same LA..
if HRI_Group1516 = "Died" and HRI_Group1415 = "Not in LA" HRI_Group1516 = "Not in LA".
if HRI_Group1617 = "Died" and HRI_Group1516 = "Not in LA" HRI_Group1617 = "Not in LA".
if HRI_Group1718 = "Died" and HRI_Group1617 = "Not in LA" HRI_Group1718 = "Not in LA".
EXE.


* Remove Costs data for those not in LA.
if HRI_Group1516 = "Not in LA" health_net_cost1516 = 0.
if HRI_Group1415 = "Not in LA" health_net_cost1415 = 0.
if HRI_Group1718 = "Not in LA" health_net_cost1718 = 0.
if HRI_Group1617 = "Not in LA" health_net_cost1617 = 0.
EXE.

* Remove Costs data for those Died before start of FY.
if HRI_Group1516 = "Died" health_net_cost1516 = 0.
if HRI_Group1415 = "Died" health_net_cost1415 = 0.
if HRI_Group1718 = "Died" health_net_cost1718 = 0.
if HRI_Group1617 = "Died" health_net_cost1617 = 0.
EXE.


compute LCA_Select = x.
EXE.

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
EXE.


string PathwayLKP (A100).
exe.

compute PathwayLKP = concat(rtrim(HRI_Group1415), rtrim(HRI_Group1516), rtrim(HRI_Group1617), rtrim(HRI_Group1718)).
exe. 

save outfile  = !OFilesL + 'temp_HRI_LAT2.sav'.

* Agg Age.
get file  = !OFilesL + 'temp_HRI_LAT1.sav'.

select if AgeBand = "All".
select if  GenderSTR NE "Both".
EXE.

string PathwayLKP (A100).

compute PathwayLKP = concat(rtrim(HRI_Group1415), rtrim(HRI_Group1516), rtrim(HRI_Group1617), rtrim(HRI_Group1718)).
exe. 

save outfile  = !OFilesL + 'temp_HRI_LAT3.sav'.

* Agg Gender.
get file  = !OFilesL + 'temp_HRI_LAT1.sav'.

select if GenderSTR = "Both".
select if AgeBand NE "All".
EXE.

string PathwayLKP (A100).
exe.


compute PathwayLKP = concat(rtrim(HRI_Group1415), rtrim(HRI_Group1516), rtrim(HRI_Group1617), rtrim(HRI_Group1718)).
exe. 

save outfile  = !OFilesL + 'temp_HRI_LAT4.sav'.

* Agg Age & Gender.
get file  = !OFilesL + 'temp_HRI_LAT1.sav'.

select if  GenderSTR = "Both".
select if AgeBand = "All".
EXE.

string PathwayLKP (A100).

compute PathwayLKP = concat(rtrim(HRI_Group1415), rtrim(HRI_Group1516), rtrim(HRI_Group1617), rtrim(HRI_Group1718)).
exe. 

save outfile  = !OFilesL + 'temp_HRI_LAT5.sav'.

*bring files togther.
add files file = !OFilesL + 'temp_HRI_LAT2.sav'
/file = !OFilesL + 'temp_HRI_LAT3.sav'
/file = !OFilesL + 'temp_HRI_LAT4.sav'
/file = !OFilesL + 'temp_HRI_LAT5.sav'.
EXE.

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
compute PathwayLKP = concat(STRING (LCA_Select,F8),PathwayLKP).
EXE.
*Remove all spaces from PathwayLKP.
COMPUTE PathwayLKP = REPLACE(PathwayLKP, " ", "").
EXE.
* Create a Pathway Label for use in Tableau.
string PathwayLabel (A100).

compute PathwayLabel = concat(HRI_Group1415, ' - ', HRI_Group1516, ' - ', HRI_Group1617, HRI_Group1718, ' - ').
execute. 

* Need to save out Pathway lookup to match on the original CHIMASTER level data.
save outfile  = !OFilesL + 'temp_HRI_LA_ALLYR_CHI32.sav'
/keep chi LCA_select PathwayLKP PathwayLabel HRI_Group1617 HRI_Group1718 HRI_Group1415 HRI_Group1516 remove.

* Remove mis-match records.
select if Remove NE 1.
exe.

AGGREGATE
  /OUTFILE=*
  /BREAK=LCA_Select genderSTR AgeBand HRI_Group1617 HRI_Group1718 HRI_Group1415 HRI_Group1516 PathwayLKP PathwayLabel
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

save outfile  = !OFilesL + 'temp_HRI_LA_ALLYR32.sav'.


***********************************************************************************.
*get file = !OFilesL + 'temp_HRI_LA_ALLYR1.sav'.


*add files file = *
/file='/conf/linkage/output/euanpa01/Sankey_Link_dataset_Dummy.sav'.

*string Link (A4).
*Compute Link = "link".
*exe.
*if AgeBand = "All" AgeBand = "All ages".
*exe.

*string Data (A25).
*compute Data = "Sankey".
*EXECUTE.

*Select if PathwayLabel NE "Remove".
*EXECUTE.

*SAVE OUTFILE='/conf/irf/01-CPTeam/02-Functional-outputs/09-Tableau-Outputs/01-Development/02-SPSS-Outputs/03-HRI/Sankey_Link_dataset_FINAL.sav'
  /COMPRESSED.

*get FILE='/conf/irf/01-CPTeam/02-Functional-outputs/09-Tableau-Outputs/01-Development/02-SPSS-Outputs/03-HRI/Sankey_Link_dataset_FINAL.sav'.

************************************************************************************************************************************************************************************.
get file = !OFilesL + 'temp_HRI_LA_ALLYR1.sav'.

add files file = *
/file = !OFilesL + 'temp_HRI_LA_ALLYR2.sav'
/file = !OFilesL + 'temp_HRI_LA_ALLYR3.sav'
/file = !OFilesL + 'temp_HRI_LA_ALLYR4.sav'
/file = !OFilesL + 'temp_HRI_LA_ALLYR5.sav'
/file = !OFilesL + 'temp_HRI_LA_ALLYR6.sav'
/file = !OFilesL + 'temp_HRI_LA_ALLYR7.sav'
/file = !OFilesL + 'temp_HRI_LA_ALLYR8.sav'
/file = !OFilesL + 'temp_HRI_LA_ALLYR9.sav'
/file = !OFilesL + 'temp_HRI_LA_ALLYR10.sav'
/file = !OFilesL + 'temp_HRI_LA_ALLYR11.sav'
/file = !OFilesL + 'temp_HRI_LA_ALLYR12.sav'
/file = !OFilesL + 'temp_HRI_LA_ALLYR13.sav'
/file = !OFilesL + 'temp_HRI_LA_ALLYR14.sav'
/file = !OFilesL + 'temp_HRI_LA_ALLYR15.sav'
/file = !OFilesL + 'temp_HRI_LA_ALLYR16.sav'
/file = !OFilesL + 'temp_HRI_LA_ALLYR17.sav'
/file = !OFilesL + 'temp_HRI_LA_ALLYR18.sav'
/file = !OFilesL + 'temp_HRI_LA_ALLYR19.sav'
/file = !OFilesL + 'temp_HRI_LA_ALLYR20.sav'
/file = !OFilesL + 'temp_HRI_LA_ALLYR21.sav'
/file = !OFilesL + 'temp_HRI_LA_ALLYR22.sav'
/file = !OFilesL + 'temp_HRI_LA_ALLYR23.sav'
/file = !OFilesL + 'temp_HRI_LA_ALLYR24.sav'
/file = !OFilesL + 'temp_HRI_LA_ALLYR25.sav'
/file = !OFilesL + 'temp_HRI_LA_ALLYR26.sav'
/file = !OFilesL + 'temp_HRI_LA_ALLYR27.sav'
/file = !OFilesL + 'temp_HRI_LA_ALLYR28.sav'
/file = !OFilesL + 'temp_HRI_LA_ALLYR29.sav'
/file = !OFilesL + 'temp_HRI_LA_ALLYR30.sav'
/file = !OFilesL + 'temp_HRI_LA_ALLYR31.sav'
/file = !OFilesL + 'temp_HRI_LA_ALLYR32.sav'.
EXE.

alter type LCA_Select (a2).
alter type ageband (a8).

add files file = *
/file= '/conf/irf/09-Tableau-Outputs/01-Development/04-Source-Data/03-HRI/Sankey_Link_dataset_Dummy.sav'.
execute.


string Link (a4).
Compute Link = "link".
exe.

if AgeBand = "All" AgeBand = "All ages".
exe.


compute Data = "Sankey".
EXECUTE.

Select if PathwayLabel NE "Remove".
EXE.

SAVE OUTFILE = !OFilesL + 'Sankey_Link_dataset_FINAL.sav'
  /drop  PathwayLabel.

 
get FILE=  !OFilesL + 'Sankey_Link_dataset_FINAL.sav'.

rename variables (LCA_select = lca).
alter type lca (A2).
*add LA Name.
string LCAname (a25).
if lca eq ' 1' LCAname eq 'Aberdeen City'.
if lca eq ' 2' LCAname eq 'Aberdeenshire'.
if lca eq ' 3' LCAname eq 'Angus'.
if lca eq ' 4' LCAname eq 'Argyll & Bute'.
if lca eq ' 5' LCAname eq 'Scottish Borders'.
if lca eq ' 6' LCAname eq 'Clackmannanshire'.
if lca eq ' 7' LCAname eq 'West Dunbartonshire'.
if lca eq ' 8' LCAname eq 'Dumfries & Galloway'.
if lca eq ' 9' LCAname eq 'Dundee City'.
if lca eq '10' LCAname eq 'East Ayrshire'.
if lca eq '11' LCAname eq 'East Dunbartonshire'.
if lca eq '12' LCAname eq 'East Lothian'.
if lca eq '13' LCAname eq 'East Renfrewshire'.
if lca eq '14' LCAname eq 'City of Edinburgh'.
if lca eq '15' LCAname eq 'Falkirk'.
if lca eq '16' LCAname eq 'Fife'.
if lca eq '17' LCAname eq 'Glasgow City'.
if lca eq '18' LCAname eq 'Highland'.
if lca eq '19' LCAname eq 'Inverclyde'.
if lca eq '20' LCAname eq 'Midlothian'.
if lca eq '21' LCAname eq 'Moray'.
if lca eq '22' LCAname eq 'North Ayrshire'.
if lca eq '23' LCAname eq 'North Lanarkshire'.
if lca eq '24' LCAname eq 'Orkney'.
if lca eq '25' LCAname eq 'Perth & Kinross'.
if lca eq '26' LCAname eq 'Renfrewshire'.
if lca eq '27' LCAname eq 'Shetland'.
if lca eq '28' LCAname eq 'South Ayrshire'.
if lca eq '29' LCAname eq 'South Lanarkshire'.
if lca eq '30' LCAname eq 'Stirling'.
if lca eq '31' LCAname eq 'West Lothian'.
if lca eq '32' LCAname eq 'Western Isles'.
if LCAname = '' LCAname = 'Non LCA'.
frequency variables = LCAname.

String LA_CODE (a9).
if LCAname = 'Scottish Borders' LA_CODE = 'S12000026'.
if LCAname = 'Fife' LA_CODE = 'S12000015'.
if LCAname = 'Orkney' LA_CODE = 'S12000023'.
if LCAname = 'Western Isles' LA_CODE = 'S12000013'.
if LCAname = 'Dumfries & Galloway' LA_CODE = 'S12000006'.
if LCAname = 'Shetland' LA_CODE = 'S12000027'.
if LCAname = 'North Ayrshire' LA_CODE = 'S12000021'.
if LCAname = 'South Ayrshire' LA_CODE = 'S12000028'.
if LCAname = 'East Ayrshire' LA_CODE = 'S12000008'.
if LCAname = 'East Dunbartonshire' LA_CODE = 'S12000045'.
if LCAname = 'Glasgow City' LA_CODE = 'S12000046'.
if LCAname = 'East Renfrewshire' LA_CODE = 'S12000011'.
if LCAname = 'West Dunbartonshire' LA_CODE = 'S12000039'.
if LCAname = 'Renfrewshire' LA_CODE = 'S12000038'.
if LCAname = 'Inverclyde' LA_CODE = 'S12000018'.
if LCAname = 'Highland' LA_CODE = 'S12000017'.
if LCAname = 'Argyll & Bute' LA_CODE = 'S12000035'.
if LCAname = 'North Lanarkshire' LA_CODE = 'S12000044'.
if LCAname = 'South Lanarkshire' LA_CODE = 'S12000029'.
if LCAname = 'Aberdeen City' LA_CODE = 'S12000033'.
if LCAname = 'Aberdeenshire' LA_CODE = 'S12000034'.
if LCAname = 'Moray' LA_CODE = 'S12000020'.
if LCAname = 'East Lothian' LA_CODE = 'S12000010'.
if LCAname = 'West Lothian' LA_CODE = 'S12000040'.
if LCAname = 'Midlothian' LA_CODE = 'S12000019'.
if LCAname = 'City of Edinburgh' LA_CODE = 'S12000036'.
if LCAname = 'Perth & Kinross' LA_CODE = 'S12000024'.
if LCAname = 'Dundee City' LA_CODE = 'S12000042'.
if LCAname = 'Angus' LA_CODE = 'S12000041'.
if LCAname = 'Clackmannanshire' LA_CODE = 'S12000005'.
if LCAname = 'Falkirk' LA_CODE = 'S12000014'.
if LCAname = 'Stirling' LA_CODE = 'S12000030'.
EXECUTE.


SAVE OUTFILE=  !OFilesL+ 'Sankey_Link_dataset_FINAL.sav'
  /drop lca.


get file =  !OFilesL+ 'Sankey_Link_dataset_FINAL.sav'.


compute Link = link.
compute Data = 'Sankey'.
compute LCAname = 'Please Select Partnership'.
compute LA_CODE = 'DummyPAR0'.

aggregate outfile = *
/break  Link Data LCAname LA_CODE
/number = n.

add files file =*
/file = !OFilesL+ 'Sankey_Link_dataset_FINAL.sav'.
execute.

SAVE OUTFILE= !OFilesL + 'Sankey_Link_dataset_FINAL.sav'
    /drop number.

get file = !OFilesL + 'Sankey_Link_dataset_FINAL.sav'.

save outfile =!OFilesL + '/Sankey_Link_dataset_FINAL.sav'
     /drop cvd copd dementia chd hefailure refailure asthma atrialfib parkinsons liver No_LTC.

get file =  !OFilesL + '/Sankey_Link_dataset_FINAL.sav'.

*produce blank columns to match with Summary dataset.
compute Acute_Ind = 0.
compute AE_Ind = 0.
compute GLS_Ind = 0.
compute Mat_Ind = 0.
compute MH_Ind = 0.
compute No_LTC = 0.
compute OUT_Ind = 0.
compute PIS_Ind = 0.


save outfile =  !OFilesL + '/Sankey_Link_dataset_FINAL.sav'.

get file = !OFilesL + '/Sankey_Link_dataset_FINAL.sav'.


****Save final Sankey dataset.
save outfile = !OFilesL + 'Sankey_Link_dataset_FINAL.sav'
   /drop HRI_group1011 HRI_group1112 HRI_group1213 HRI_group1314.

get file =!OFilesL + 'Sankey_Link_dataset_FINAL.sav'.

rename variables mentalh_episodes = MH_episodes.

rename variables mentalh_inpatient_beddays = MH_inpatient_beddays.

rename variables mentalh_cost = MH_cost.

save outfile = !OFilesL + 'Sankey_Link_dataset_FINAL_Tableau_sorted.sav'
 /keep Link Data LCAname LA_CODE GenderSTR AgeBand HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
           PathwayLKP health_net_cost1415 health_net_cost1516 health_net_cost1617 health_net_cost1718 
           health_net_cost1415_min health_net_cost1415_max health_net_cost1516_min  health_net_cost1516_max health_net_cost1617_min
           health_net_cost1617_max health_net_cost1718_min  health_net_cost1718_max  health_net_cost Size Year TNum_LTC TNum_LTC_GRP
           acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost
           gls_episodes gls_inpatient_beddays gls_cost op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag
           diabetes epilepsy cancer arth Neurodegenerative_Grp Cardio_Grp Respiratory_Grp OtherOrgan_Grp Num_Ind Acute_Ind AE_Ind GLS_Ind Mat_Ind MH_Ind
           No_LTC OUT_Ind PIS_Ind.
execute.

get file = !OFilesL + 'Sankey_Link_dataset_FINAL_Tableau_sorted.sav'.

save translate outfile = !OFilesL + 'Sankey_Link_dataset_FINAL_Tableau_sorted.csv' 
       /type = csv/version = 8/map/replace/fieldnames/cells = values.

frequencies year.


***************.
















************************************Aggregate Non-HRIs for Alternative Chart*****************************************.  
*****************Chart just looks at HRIs/Non-HRIs/Died for demo purposes - Not Part of Main Output**********.

get file = '/conf/irf/09-Tableau-Outputs/01-Development/02-SPSS-Outputs/03-HRI/Sankey_Link_dataset_FINAL.sav'.



do if any(LCAname, 'Aberdeen City', 'Aberdeenshire', 'Angus', 'Argyll & Bute', 'City of Edinburgh', 'Clackmannanshire', 'Dumfries & Galloway', 'Dundee City', 'Scottish Borders', 'West Dunbartonshire').
compute pathwayLKP = substr(pathwayLKP, 1, 1).
ELSE.
compute pathwayLKP = substr(pathwayLKP, 1, 2).
end if.
frequencies variables = pathwayLKP.

if HRI_Group1617 eq 'High' HRI_Group1617 eq 'HRI'.
if any(HRI_Group1617, 'High to Medium', 'Low', 'Medium', 'Medium to Low', 'No Contact') HRI_Group1617 eq 'Non-HRI'.
if HRI_Group1314 eq 'High' HRI_Group1314 eq 'HRI'.
if any(HRI_Group1314, 'High to Medium', 'Low', 'Medium', 'Medium to Low', 'No Contact') HRI_Group1314 eq 'Non-HRI'.
if HRI_Group1415 eq 'High' HRI_Group1415 eq 'HRI'.
if any(HRI_Group1415, 'High to Medium', 'Low', 'Medium', 'Medium to Low', 'No Contact') HRI_Group1415 eq 'Non-HRI'.
if HRI_Group1516 eq 'High' HRI_Group1516 eq 'HRI'.
if any(HRI_Group1516, 'High to Medium', 'Low', 'Medium', 'Medium to Low', 'No Contact') HRI_Group1516 eq 'Non-HRI'.
exe.


aggregate outfile = *
/break Link Data LCAname LA_CODE GenderSTR AgeBand HRI_Group1617 HRI_Group1314 HRI_Group1415 HRI_Group1516 year TNum_LTC TNum_LTC_GRP
/health_net_cost1617 health_net_cost1314 health_net_cost1415 health_net_cost1516 health_net_cost1617_min health_net_cost1617_max health_net_cost1314_min
health_net_cost1314_max health_net_cost1415_min health_net_cost1415_max health_net_cost1516_min health_net_cost1516_max health_net_cost acute_episodes
acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost mentalh_episodes mentalh_inpatient_beddays mentalh_cost gls_episodes gls_inpatient_beddays
gls_cost op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag diabetes epilepsy cancer arth Neurodegenerative_Grp
Cardio_Grp Respiratory_Grp OtherOrgan_Grp Num_Ind Acute_Ind AE_Ind GLS_Ind Mat_Ind MH_Ind No_LTC OUT_Ind PIS_Ind Size
=sum(health_net_cost1617 health_net_cost1314 health_net_cost1415 health_net_cost1516 health_net_cost1617_min health_net_cost1617_max health_net_cost1314_min
health_net_cost1314_max health_net_cost1415_min health_net_cost1415_max health_net_cost1516_min health_net_cost1516_max health_net_cost acute_episodes
acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost mentalh_episodes mentalh_inpatient_beddays mentalh_cost gls_episodes gls_inpatient_beddays
gls_cost op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag diabetes epilepsy cancer arth Neurodegenerative_Grp
Cardio_Grp Respiratory_Grp OtherOrgan_Grp Num_Ind Acute_Ind AE_Ind GLS_Ind Mat_Ind MH_Ind No_LTC OUT_Ind PIS_Ind Size).

save outfile =  '/conf/irf/09-Tableau-Outputs/01-Development/02-SPSS-Outputs/03-HRI/Sankey_Link_dataset_FINAL_ALT.sav'.

