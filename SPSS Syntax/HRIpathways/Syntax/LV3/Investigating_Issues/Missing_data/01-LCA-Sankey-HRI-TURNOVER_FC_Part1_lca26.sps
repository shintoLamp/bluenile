* Encoding: UTF-8.
* File save location.
define !OFilesL()
       '/conf/sourcedev/TableauUpdates/HRIpathways/Outputs/LV3/Checks/Missing_Data/lca26/'
!Enddefine.




******************************************************************
*************************************************************************************************************************************************.
*** Start with last financial year (2018/2019).

Define !year()
'201819'
!Enddefine.

get file = '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.zsav'.
select if gender ne 0.
select if hri_scot ne 9.

*Mar 2019 FC. 
*Non-Service Users must be excluded by the calculations (only for health activities from 2015/16 onwards)
 Otherwise, these users will be counted in the 'Low Users' category.
select if NSU ne 1.
exe.

*SelectRefrenshire data only.
select if lca='26'.
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

*frequencies variables = scotflag.


*frequencies variables = pcDistrict.
*rename variables PC_District = PCDistrict.
*alter type PCDistrict (A18). 
*match files file =*
/Table = !clout + 'Postcode_district_from_standard_ref.sav'
/by PCDistrict.
*exe. 
*if scot_flag_1 = 1 scotflag = 1.
*exe. 

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

*frequencies HRI_Group.

*FC Dec 19 - Create Numeric 'date of birth'.
Compute dob_num = xdate.mday(dob) + 100*xdate.month(dob) + 10000*xdate.year(dob).
exe.

*Adjust age (Numeric format) to base year of latest year.
alter type dob_num (F8.0).
compute age_num= trunc((20180930-dob_num)/10000).
alter type age_num (F3.0).
exe.

*frequencies age_num.

* Create required agebands.
string AgeBand (a5).
If (Age_num lt 18) AgeBand = '<18'.
If (Age_num ge 18 and Age_num le 44) AgeBand = '18-44'.
If (Age_num ge 45 and Age_num le 64) AgeBand = '45-64'.
If (Age_num ge 65 and Age_num le 74) AgeBand = '65-74'.
If (Age_num ge 75 and Age_num le 84) AgeBand = '75-84'.
If (Age_num ge 85) AgeBand = '85+'.
exe. 

*frequencies ageband.

* Remove any individuals not within a LA.
*select if lca NE ' '.

rename variables (lca HRI_Group health_net_cost = LCA1819 HRI_Group1819 health_net_cost1819).

rename variables Anon_CHI = chi. 

sort cases by chi.


AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=AgeBand gender HRI_Group1819 LCA1819
  /health_net_cost1819_min=MIN(health_net_cost1819) 
  /health_net_cost1819_max=MAX(health_net_cost1819).

save outfile  = !OFilesL + 'temp_HRI_LA_1819_T1.zsav'
/keep year CHI gender health_net_cost1819 LCA1819  AgeBand LCA1819 HRI_Group1819 health_net_cost1819_min health_net_cost1819_max deceased date_death
/zcompressed.


*All ages.
get file  = !OFilesL + 'temp_HRI_LA_1819_T1.zsav'
/keep year CHI gender health_net_cost1819 LCA1819  AgeBand LCA1819 HRI_Group1819 deceased date_death.

compute AgeBand = 'All'.
exe.

AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=AgeBand gender HRI_Group1819 LCA1819
  /health_net_cost1819_min=MIN(health_net_cost1819) 
  /health_net_cost1819_max=MAX(health_net_cost1819).

save outfile  = !OFilesL + 'temp_HRI_LA_1819_T2.zsav'
/keep year CHI gender health_net_cost1819 LCA1819  AgeBand LCA1819 HRI_Group1819 health_net_cost1819_min health_net_cost1819_max deceased date_death
/zcompressed.


* By Gender.
get file  = !OFilesL + 'temp_HRI_LA_1819_T1.zsav'
/keep year CHI gender health_net_cost1819 LCA1819  AgeBand LCA1819 HRI_Group1819 deceased date_death.

compute gender = 0.
exe.

AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=AgeBand gender HRI_Group1819 LCA1819
  /health_net_cost1819_min=MIN(health_net_cost1819) 
  /health_net_cost1819_max=MAX(health_net_cost1819).

save outfile  = !OFilesL + 'temp_HRI_LA_1819_T3.zsav'
/keep year CHI gender health_net_cost1819 LCA1819  AgeBand LCA1819 HRI_Group1819 health_net_cost1819_min health_net_cost1819_max deceased date_death
/zcompressed.


*Both Age and gender.
get file  = !OFilesL + 'temp_HRI_LA_1819_T1.zsav'
/keep year CHI gender health_net_cost1819 LCA1819  AgeBand LCA1819 HRI_Group1819 deceased date_death.

compute AgeBand = 'All'.
compute gender = 0.
exe.

AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=AgeBand gender HRI_Group1819 LCA1819
  /health_net_cost1819_min=MIN(health_net_cost1819) 
  /health_net_cost1819_max=MAX(health_net_cost1819).

save outfile  = !OFilesL + 'temp_HRI_LA_1819_T4.zsav'
/keep year CHI gender health_net_cost1819 LCA1819  AgeBand LCA1819 HRI_Group1819 health_net_cost1819_min health_net_cost1819_max deceased date_death
/zcompressed.



add files file = !OFilesL + 'temp_HRI_LA_1819_T1.zsav'
/file = !OFilesL + 'temp_HRI_LA_1819_T2.zsav'
/file = !OFilesL + 'temp_HRI_LA_1819_T3.zsav'
/file = !OFilesL + 'temp_HRI_LA_1819_T4.zsav'.
execute.

sort cases by chi AgeBand gender.

save outfile  = !OFilesL + 'temp_HRI_LA_1819.zsav'
 /zcompressed.   

* Tidy up.
*ERASE file  = !OFilesL + 'temp_HRI_LA_1819_T1.zsav'.
*ERASE file  = !OFilesL + 'temp_HRI_LA_1819_T2.zsav'.
*ERASE file  = !OFilesL + 'temp_HRI_LA_1819_T3.zsav'.
*ERASE file  = !OFilesL + 'temp_HRI_LA_1819_T4.zsav'.



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

*SelectRefrenshire data only.
select if lca='26'.
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

*frequencies variables = scotflag.


*frequencies variables = pcDistrict.
*rename variables PC_District = PCDistrict.
*alter type PCDistrict (A18). 
*match files file =*
/Table = !clout + 'Postcode_district_from_standard_ref.sav'
/by PCDistrict.
*exe. 
*if scot_flag_1 = 1 scotflag = 1.
*exe. 

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


*FC Dec 19 - Create Numeric 'date of birth'.
Compute dob_num = xdate.mday(dob) + 100*xdate.month(dob) + 10000*xdate.year(dob).
exe.

*Adjust age (Numeric format) to base year of latest year.
alter type dob_num (F8.0).
compute age_num= trunc((20170930-dob_num)/10000).
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
exe. 

*frequencies ageband.

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



add files file = !OFilesL + 'temp_HRI_LA_1718_T1.zsav'
/file = !OFilesL + 'temp_HRI_LA_1718_T2.zsav'
/file = !OFilesL + 'temp_HRI_LA_1718_T3.zsav'
/file = !OFilesL + 'temp_HRI_LA_1718_T4.zsav'.
execute.

sort cases by chi AgeBand gender.

save outfile  = !OFilesL + 'temp_HRI_LA_1718.zsav'
/zcompressed.   


* Tidy up.
*ERASE file  = !OFilesL + 'temp_HRI_LA_1718_T1.zsav'.
*ERASE file  = !OFilesL + 'temp_HRI_LA_1718_T2.zsav'.
*ERASE file  = !OFilesL + 'temp_HRI_LA_1718_T3.zsav'.
*ERASE file  = !OFilesL + 'temp_HRI_LA_1718_T4.zsav'.


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

*SelectRefrenshire data only.
select if lca='26'.
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

*frequencies variables = scotflag.


*frequencies variables = pcDistrict.
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



*FC Dec 19 - Create Numeric 'date of birth'.
Compute dob_num = xdate.mday(dob) + 100*xdate.month(dob) + 10000*xdate.year(dob).
exe.

*Adjust age (Numeric format) to base year of latest year.
alter type dob_num (F8.0).
compute age_num= trunc((20160930-dob_num)/10000).
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



add files file = !OFilesL + 'temp_HRI_LA_1617_T1.zsav'
/file = !OFilesL + 'temp_HRI_LA_1617_T2.zsav'
/file = !OFilesL + 'temp_HRI_LA_1617_T3.zsav'
/file = !OFilesL + 'temp_HRI_LA_1617_T4.zsav'.
execute.

sort cases by chi AgeBand gender.

save outfile  = !OFilesL + 'temp_HRI_LA_1617.zsav'
/zcompressed.


* Tidy up.
*ERASE file  = !OFilesL + 'temp_HRI_LA_1617_T1.zsav'.
*ERASE file  = !OFilesL + 'temp_HRI_LA_1617_T2.zsav'.
*ERASE file  = !OFilesL + 'temp_HRI_LA_1617_T3.zsav'.
*ERASE file  = !OFilesL + 'temp_HRI_LA_1617_T4.zsav'.


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

*SelectRefrenshire data only.
select if lca='26'.
EXE.

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

*frequencies variables = scotflag.


*frequencies variables = pcDistrict.
*rename variables PC_District = PCDistrict.
*alter type PCDistrict (A18). 
*match files file =*
/Table = !clout + 'Postcode_district_from_standard_ref.sav'
/by PCDistrict.
*exe. 
*if scot_flag_1 = 1 scotflag = 1.
*exe. 

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



*FC Dec 19 - Create Numeric 'date of birth'.
Compute dob_num = xdate.mday(dob) + 100*xdate.month(dob) + 10000*xdate.year(dob).
exe.

*Adjust age (Numeric format) to base year of latest year.
alter type dob_num (F8.0).
compute age_num= trunc((20150930-dob_num)/10000).
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


add files file = !OFilesL + 'temp_HRI_LA_1516_T1.zsav'
/file = !OFilesL + 'temp_HRI_LA_1516_T2.zsav'
/file = !OFilesL + 'temp_HRI_LA_1516_T3.zsav'
/file = !OFilesL + 'temp_HRI_LA_1516_T4.zsav'.
exe.

sort cases by chi AgeBand gender.

save outfile  = !OFilesL + 'temp_HRI_LA_1516.zsav'
 /zcompressed.



* Tidy up.
*ERASE file  = !OFilesL + 'temp_HRI_LA_1516_T1.zsav'.
*ERASE file  = !OFilesL + 'temp_HRI_LA_1516_T2.zsav'.
*ERASE file  = !OFilesL + 'temp_HRI_LA_1516_T3.zsav'.
*ERASE file  = !OFilesL + 'temp_HRI_LA_1516_T4.zsav'.





*************************************************************************************************************************************************.

************************************************************************************.
*Bring all files together (Including saved data for 2014/15, 2015/16).

Get file  = !OFilesL + 'temp_HRI_LA_1819.zsav'.

****Rename deceased_flag to deceased for 1415, 1516 data and update lca codes for 'Fife' and 'Perth & Kinross' ****.
match files file = *
/file =  !OFilesL + 'temp_HRI_LA_1718.zsav'
/file =  !OFilesL + 'temp_HRI_LA_1617.zsav'
/file =  !OFilesL + 'temp_HRI_LA_1516.zsav'
/by chi AgeBand gender.
exe.

* Convert LA variable to a number.
alter type LCA1819 (F2.0).
alter type LCA1718 (F2.0).
alter type LCA1516 (F2.0).
alter type LCA1617 (F2.0).
alter type date_death (F8).

save outfile  = !OFilesL + 'temp_HRI_LA_MASTER_ALLYR_LCA26.zsav'
  /zcompressed.


* Tidy up.
*ERASE file  =  !OFilesL + 'temp_HRI_LA_1718.zsav'.
*ERASE file  =  !OFilesL + 'temp_HRI_LA_1415.zsav'.
*ERASE file  =  !OFilesL + 'temp_HRI_LA_1516.zsav'.
*ERASE file  =  !OFilesL + 'temp_HRI_LA_1617.zsav'.