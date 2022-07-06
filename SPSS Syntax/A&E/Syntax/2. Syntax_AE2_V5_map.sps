﻿* Encoding: UTF-8.
*A&E Workbook Syntax.
*Part 2 produces mapped A&E information by 2011 datazones.  
*Developed by Jamie Munro 22/04/2016.
*Updated by Federico Centoni 25/05/2021.


********UPDATE BEFORE ANY UPDATE******************
*Macros to define year.

Define !year()
'201718'
!Enddefine.

define !file()
'/conf/sourcedev/TableauUpdates/A&E/Outputs/201718/'
!enddefine.

*****************************************************************


get file = !file + 'AE' + !year +'.zsav'.

 *No LTC grouping i.e. 'All'. 
 
compute LTCgroup= 'N/A'.
aggregate outfile= *
 /break chi HBRESCODE HBTREATCODE lca ae_num agegroup LTC_Num LTCgroup location datazone simd Ref_source
/attendances = sum(episodes)
/cost = sum(cost_total_net).
execute.

*Remove blank SIMD

select if simd ge 1.
select if simd le 5.
exe. 

*alter format to allow 'All' category.

alter type LTC_Num (A3).
exe.  

save outfile= !file + 'AEpart3' + !year +'.zsav'
/zcompressed.

get file= !file + 'AEpart3' + !year +'.zsav'. 

*Create flag for each person to count numbers.

Compute individuals =1. 
exe.

aggregate outfile= *
 /break HBRESCODE HBTREATCODE lca ae_num agegroup LTC_Num  LTCgroup location datazone simd Ref_source
/attendances = sum(attendances)
/individuals = sum(individuals)
/cost = sum(cost).
execute.

save outfile= !file +'AEpart4' + !year +'.zsav'
/zcompressed. 

*Now calculate "All" Location Category.

get file= !file + 'AEpart3' + !year +'.zsav'. 

compute location = 'All'.

aggregate outfile=*
 /break chi HBRESCODE HBTREATCODE lca ae_num agegroup LTC_Num LTCgroup location datazone simd Ref_source
 /attendances = sum(attendances)
 /cost = sum(cost).
execute.

compute individuals = 1.
exe.

aggregate outfile=*
 /break HBRESCODE HBTREATCODE lca ae_num agegroup LTC_Num LTCgroup location datazone simd Ref_source
 /attendances = sum(attendances)
 /individuals= sum(individuals)
 /cost = sum(cost).
execute.

Add files file = *
 /file= !file + 'AEpart4' + !year +'.zsav'. 
exe.

save outfile = !file +'AEpart4' + !year +'.zsav'
/zcompressed.
  
*Now calculate "All" Ref_source Category.

get file= !file + 'AEpart3' + !year +'.zsav'. 

compute Ref_source = 'All'.

aggregate outfile=*
 /break chi HBRESCODE HBTREATCODE lca ae_num agegroup LTC_Num LTCgroup location Ref_source datazone simd 
 /attendances = sum(attendances)
 /cost = sum(cost).
execute.

compute individuals = 1.
exe.

aggregate outfile=*
 /break HBRESCODE HBTREATCODE lca ae_num agegroup LTC_Num LTCgroup location Ref_source datazone simd 
 /attendances = sum(attendances)
 /individuals= sum(individuals)
 /cost = sum(cost).
execute.

Add files file = *
 /file= !file + 'AEpart4' + !year +'.zsav'. 
exe.

save outfile = !file +'AEpart4' + !year +'.zsav'
/zcompressed. 

*Now calculate "All" location and "All" Ref_source.

get file= !file + 'AEpart3' + !year +'.zsav'. 

compute location = 'All'.
compute Ref_source = 'All'.

aggregate outfile= *
 /break chi HBRESCODE HBTREATCODE lca ae_num agegroup LTC_Num LTCgroup location Ref_source datazone simd 
/attendances = sum(attendances)
/cost = sum(cost).
execute.

compute individuals = 1.
exe.

aggregate outfile=*
 /break HBRESCODE HBTREATCODE lca ae_num agegroup LTC_Num LTCgroup location Ref_source datazone simd 
 /attendances = sum(attendances)
 /individuals= sum(individuals)
 /cost = sum(cost).
execute.

Add files file = *
 /file= !file +'AEpart4' + !year +'.zsav'. 
exe.

save outfile = !file +'AEpart4' + !year +'.zsav'
/zcompressed.
  
get file= !file +'AEpart4' + !year + '.zsav'.

*Aggregate file to get 'All' value for agegroup: 

Temporary.
compute Agegroup = 'all'.
aggregate outfile= !file + 'temp1.sav'
 /break HBRESCODE HBTREATCODE lca agegroup LTC_Num  LTCgroup ae_num location datazone simd Ref_source
/attendances = sum(attendances)
/individuals = sum(individuals)
/cost = sum(cost).
execute.

Add files file = *
 /file= !file + 'temp1.sav'.
execute.

*Aggregate file to get 'All' value for LTC_num:  

Temporary.
compute LTC_Num = 'All'.
aggregate outfile= !file + 'temp1.sav'
 /break HBRESCODE HBTREATCODE lca ae_num agegroup LTC_Num LTCgroup location datazone simd Ref_source
/attendances = sum(attendances)
/individuals = sum(individuals)
/cost = sum(cost).
execute.

Add files file = *
 /file= !file + 'temp1.sav'.
exe.

save outfile = !file + 'AEpart4' + !year +'.zsav'
/zcompressed.

get file= !file + 'AEpart4' + !year +'.zsav'. 

*Aggregate file to get 'All' value for ae_num:  

Temporary.
compute ae_num = 'All'.
aggregate outfile= !file + 'temp1.sav'
 /break HBRESCODE HBTREATCODE lca ae_num agegroup LTC_Num LTCgroup location datazone simd Ref_source
/attendances = sum(attendances)
/individuals = sum(individuals)
/cost = sum(cost).
execute.

Add files file = *
 /file= !file + 'temp1.sav'.
exe.

save outfile = !file + 'AEpart4' + !year +'.zsav'
/zcompressed.
 

get file= !file + 'AEpart4' + !year +'.zsav'. 

Alter type lca (F2.0).
exe.

If agegroup = 'all' agegroup = 'All'. 
exe. 

*Now aggegate for 'All' datazone.

Temporary.
compute datazone = 'Agg'.
aggregate outfile= !file + 'temp1.sav'
 /break HBRESCODE HBTREATCODE lca ae_num agegroup LTC_Num LTCgroup location datazone simd Ref_source
/attendances = sum(attendances)
/individuals = sum(individuals)
/cost = sum(cost).
execute.

Add files file = *
 /file= !file + 'temp1.sav'.
exe.

save outfile = !file + 'AEpart4' + !year +'.zsav'
/zcompressed.
  

get file= !file + 'AEpart4' + !year +'.zsav'. 

*Match on Hospital names 

SORT CASES by location.
execute.

*****Check on Location lookup file updates*******

alter type location (a5).

Match files file= *
 /table = '/conf/linkage/output/lookups/Data Management/standard reference files/location.sav' 
 /by location.    
execute.

If (location = 'All') locname = 'All'. 
exe. 

*Add on missing Glasgow hospital.

If (location = 'G991Z') Locname = 'Stobhill ACH'.
exe. 

save outfile= !file + 'AEpart4' + !year +'.zsav'
 /drop Add1 Add2 Add3 Add4 Add5 Summary Start Close Destination GpSurgeryInd SMR00 SMR01 SMR02 SMR04 SMR06 SMR11 SMR20 SMR25 SMR30 SMR50 filler
/zcompressed.

get file= !file + 'AEpart4' + !year +'.zsav'.  
 
*Match on council area descriptions.
rename variables lca=lcacode.
alter type lcacode (A2).
sort cases by lcacode.
execute.
match files file=*
 /table '/conf/irf/05-lookups/04-geography/LCA_lookup.sav'
 /by lcacode.
execute. 


*Add 9 digit LA Code.
String LA_CODE (a9).
if LCAname = 'Scottish Borders' LA_CODE = 'S12000026'.
if LCAname = 'Fife' LA_CODE = 'S12000015'.
if LCAname = 'Orkney Islands' LA_CODE = 'S12000023'.
if LCAname = 'Comhairle nan Eilean Siar' LA_CODE = 'S12000013'.
if LCAname = 'Dumfries & Galloway' LA_CODE = 'S12000006'.
if LCAname = 'Shetland Islands' LA_CODE = 'S12000027'.
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
if LCAname = 'Edinburgh City' LA_CODE = 'S12000036'.
if LCAname = 'Perth & Kinross' LA_CODE = 'S12000024'.
if LCAname = 'Dundee City' LA_CODE = 'S12000042'.
if LCAname = 'Angus' LA_CODE = 'S12000041'.
if LCAname = 'Clackmannanshire' LA_CODE = 'S12000005'.
if LCAname = 'Falkirk' LA_CODE = 'S12000014'.
if LCAname = 'Stirling' LA_CODE = 'S12000030'.
exe.


*FC May 2021. Add Clackmannashire & Stirling.
String Clacks(a30).
IF (LCAname = "Clackmannanshire") or (LCAname = "Stirling") Clacks="Clackmannanshire & Stirling".
VARSTOCASES
 /MAKE LCAname FROM LCAname Clacks.

*Add Health Board names:

String Hbres (a35).
if LCAname = 'Scottish Borders' hbres eq 'Borders Region'.
if LCAname = 'Fife' hbres eq 'Fife Region'.
if LCAname = 'Orkney Islands' hbres eq 'Orkney Region'.
if LCAname = 'Comhairle nan Eilean Siar' hbres eq 'Western Isles Region'.
if LCAname = 'Dumfries & Galloway' hbres eq 'Dumfries & Galloway Region'.
if LCAname = 'Shetland Islands' hbres eq 'Shetland Region'.
if LCAname = 'North Ayrshire' hbres eq 'Ayrshire & Arran Region'.
if LCAname = 'South Ayrshire' hbres eq 'Ayrshire & Arran Region'.
if LCAname = 'East Ayrshire' hbres eq 'Ayrshire & Arran Region'.
if LCAname = 'East Dunbartonshire' hbres eq 'Greater Glasgow & Clyde Region'.
if LCAname = 'Glasgow City' hbres eq 'Greater Glasgow & Clyde Region'.
if LCAname = 'East Renfrewshire' hbres eq 'Greater Glasgow & Clyde Region'.
if LCAname = 'West Dunbartonshire' hbres eq 'Greater Glasgow & Clyde Region'.
if LCAname = 'Renfrewshire' hbres eq 'Greater Glasgow & Clyde Region'.
if LCAname = 'Inverclyde' hbres eq 'Greater Glasgow & Clyde Region'.
if LCAname = 'Highland'  hbres eq 'Highland Region'.
if LCAname = 'Argyll & Bute'  hbres eq 'Highland Region'.
if LCAname = 'North Lanarkshire' hbres eq 'Lanarkshire Region'.
if LCAname = 'South Lanarkshire' hbres eq 'Lanarkshire Region'.
if LCAname = 'Aberdeen City' hbres eq 'Grampian Region'.
if LCAname = 'Aberdeenshire' hbres eq 'Grampian Region'.
if LCAname = 'Moray' hbres eq 'Grampian Region'.
if LCAname = 'East Lothian' hbres eq 'Lothian Region'.
if LCAname = 'West Lothian' hbres eq 'Lothian Region'.
if LCAname = 'Midlothian' hbres eq 'Lothian Region'.
if LCAname = 'Edinburgh City' hbres eq 'Lothian Region'.
if LCAname = 'Perth & Kinross' hbres eq 'Tayside Region'.
if LCAname = 'Dundee City' hbres eq 'Tayside Region'.
if LCAname = 'Angus' hbres eq 'Tayside Region'.
if LCAname = 'Clackmannanshire' hbres eq 'Forth Valley Region'.
if LCAname = 'Falkirk' hbres eq 'Forth Valley Region'.
if LCAname = 'Stirling' hbres eq 'Forth Valley Region'.
*FC May 2021. Add Clackmannashire & Stirling.
if LCAname = 'Clackmannanshire & Stirling' hbres eq 'Forth Valley Region'.
exe.

String Hb_Treatment (a35).
***Feb 2019. Deals with "funny", blank, Outwith Scotland, no fixed abode and Not Known HB treatcodes respectively'.
Do if Not(any(hbtreatcode,  '', 'S08200001',  'S08200002' , 'S08200003')).      
Compute HB_Treatment = Concat(ValueLabels(hbtreatcode), ' Region').
End if.
** HB treatcodes for NHS Fife and NHS Tayside were updated (e.g. S08000018 and S08000027).
if HBTREATCODE eq 'S08000015' Hb_Treatment eq 'Ayrshire & Arran Region'.
if HBTREATCODE eq 'S08000016' Hb_Treatment eq 'Borders Region'.
if HBTREATCODE eq 'S08000017' Hb_Treatment eq 'Dumfries & Galloway Region'.
if HBTREATCODE eq 'S08000029' Hb_Treatment eq 'Fife Region'.
if HBTREATCODE eq 'S08000019' Hb_Treatment eq 'Forth Valley Region'.
if HBTREATCODE eq 'S08000020' Hb_Treatment eq 'Grampian Region'.
if HBTREATCODE eq 'S08000021' Hb_Treatment eq 'Greater Glasgow & Clyde Region'.
if HBTREATCODE eq 'S08000022' Hb_Treatment eq 'Highland Region'.
if HBTREATCODE eq 'S08000023' Hb_Treatment eq 'Lanarkshire Region'.
if HBTREATCODE eq 'S08000024' Hb_Treatment eq 'Lothian Region'.
if HBTREATCODE eq 'S08000025' Hb_Treatment eq 'Orkney Region'.
if HBTREATCODE eq 'S08000026' Hb_Treatment eq 'Shetland Region'.
if HBTREATCODE eq 'S08000030' Hb_Treatment eq 'Tayside Region'.
if HBTREATCODE eq 'S08000028' Hb_Treatment eq 'Western Isles Region'.
exe.

*Add year 

String year (A8).
compute year= !year.
exe.  

alter type datazone (A27).
exe.

save outfile= !file + 'AEpart4' + !year +'.zsav'
 /drop HBTREATCODE HBRESCODE 
 /zcompressed.



****END.





