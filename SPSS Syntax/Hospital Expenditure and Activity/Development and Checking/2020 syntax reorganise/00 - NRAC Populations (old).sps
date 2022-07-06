* Encoding: UTF-8.
* Syntax for NRAC populations required for Hospital Expenditure and Activity workbook.
* Updated by Rachael Bainbridge 21/02/2019.
* Updated by Bateman McBride 03/2020.

************************************************************************************.
*Define filepath for working area on sourcedev.
Define !file()
       '/conf/sourcedev/TableauUpdates/Hospital Expenditure and Activity/Outputs/'
!Enddefine.

*** Step 1: Produce practice to LCA lookup ***.

*First create GP to LA lookup file. This is the LA where the practice is based.

get file = '/conf/linkage/output/lookups/Unicode/National Reference Files/GP_CHP.sav'.

sort cases by GP_Practice_Code.

compute chp_name = replace(chp_name, ' Community Health Partnership', '').
compute chp_name = replace(Chp_name, ' Community Health & Care Partnership', '').
compute chp_name = replace(Chp_name, ' Health and Social Care Partnership', '').
compute chp_name = replace(Chp_name, ' Community Health & Social Care Partnership', '').

if any(chp_name, 'Dunfermline & West Fife', 'Glenrothes & North East Fife', 'Kirkcaldy & Levenmouth') chp_name eq 'Fife'.
if any(chp_name, 'East Glasgow', 'North Glasgow', 'South East Glasgow', 'South West Glasgow', 'West Glasgow') chp_name eq 'Glasgow City'.
if any(chp_name, 'Edinburgh', 'Edinburgh North', 'Edinburgh South') chp_name eq 'City of Edinburgh'.
if any(chp_name, 'Mid Highland', 'North Highland', 'South East Highland') chp_name eq 'Highland'.

* In the HEA workbook, we use 'prac' to denote the 6-digit practice code. Here we format so there's no trailing spaces etc.

rename variables GP_Practice_code = prac.
rename variables chp_name = LCAname.
alter type prac (a6).

compute flag = 0.
if prac eq lag(prac) flag eq 1.
select if flag ne 1.

compute prac = replace(prac, ' ', '').
sort cases by prac.

* One duplicate exists for practice 49431, remove duplicates here.

if (lag(prac)=prac) dupcheck = 1 .
select if sysmis(dupcheck).
execute.
delete variables dupcheck.

save outfile =  !file + 'Prac_LA.sav'
/keep prac LCAname
/zcompressed.


*** Step 2: Run population files for three years ***.

* 15/16 Populations file.

get file ='/conf/hscdiip/08-Models/NRAC CHP model/model construction/201516 Model/final/NRAC_HSCP_GPprac_weighted_pop.sav'.

sort cases by gpprac.
rename variables gpprac = prac.
rename variables caregrp = NRAC_PW.
alter type prac (a6).

match files file = *
/table = !file+  'Prac_LA.sav'
/by prac.
execute.

* Code in age groups as reported on in workbook.

string AgeBand (a8).
if any(Age, '0-1', '2-4', '5-9', '10-14', '15-17') AgeBand eq '0-17'.
if any(Age, '18-19', '20-24', '25-29', '30-34', '35-39', '40-44') AgeBand eq '18-44'.
if any(Age, '45-49', '50-54', '55-59', '60-64') AgeBand eq '45-64'.
if any(Age, '65-69', '70-74') AgeBand eq '65-74'. 
if any(Age, '75-79', '80-84') AgeBand eq '75-84'. 
if any(Age, '85-89', '90+') AgeBand eq '85+'.

select if age ne 'All'.

aggregate outfile = *
/break LCAname AgeBand PRAC NRAC_PW
/Popn = sum(pop).

save outfile = !file + 'NRAC_temp.sav' /zcompressed.

get file = !file + 'NRAC_temp.sav'.

* Create an 'all ages' option.

compute AgeBand = 'All'.

aggregate outfile = *
/break LCAname AgeBand PRAC NRAC_PW
/Popn = sum(popn).

add files file = * 
 /file =  !file + 'NRAC_temp.sav'.
execute.

sort cases by prac.

if Nrac_pw eq 'Acute' Nrac_pw eq 'acute'.
if nrac_pw eq 'HCHS' nrac_pw eq 'hchs'.
if nrac_pw eq 'Mental Health & Learning Difficulties' nrac_pw eq 'mhld'.
select if any(nrac_pw, 'acute', 'hchs', 'mhld').

if lcaname eq 'Shetland Islands' lcaname eq 'Shetland'.
if lcaname eq 'Orkney Islands' lcaname eq 'Orkney'.
if lcaname eq 'Comhairle nan Eilean Siar' lcaname eq 'Western Isles'.
if lcaname eq 'Dundee' lcaname eq 'Dundee City'.
alter type prac (a5).

save outfile = !file + 'NRAC_part1.sav' /zcompressed.

*Aggreagte to get LA totals. 

aggregate outfile = *
/break lcaname AgeBand NRAC_PW
/Popn = sum(popn).

save outfile = !file + 'NRAC_part2.sav' /zcompressed.

* Aggregate to get HB totals. 

string HB (A35).
if any(lcaname, 'East Ayrshire', 'North Ayrshire', 'South Ayrshire') hb eq 'NHS Ayrshire & Arran'.
if any(lcaname, 'Scottish Borders') hb eq 'NHS Borders'.
if any(lcaname, 'Dumfries & Galloway') hb eq 'NHS Dumfries & Galloway'.
if any(lcaname, 'Fife') hb eq 'NHS Fife'.
if any(lcaname, 'Clackmannanshire', 'Falkirk', 'Stirling') hb eq 'NHS Forth Valley'.
if any(lcaname, 'Aberdeen City', 'Aberdeenshire', 'Moray', 'Grampian') hb eq 'NHS Grampian'.
if any(lcaname, 'East Dunbartonshire', 'East Renfrewshire', 'Glasgow City', 'Inverclyde', 'Renfrewshire', 'West Dunbartonshire') hb eq 'NHS Greater Glasgow & Clyde'.
if any(lcaname, 'Argyll & Bute', 'Highland') hb eq 'NHS Highland'.
if any(lcaname, 'North Lanarkshire', 'South Lanarkshire') hb eq 'NHS Lanarkshire'.
if any(lcaname, 'City of Edinburgh', 'Midlothian', 'East Lothian', 'West Lothian') hb eq 'NHS Lothian'.
if any(lcaname, 'Orkney') hb eq 'NHS Orkney'.
if any(lcaname, 'Shetland') hb eq 'NHS Shetland'.
if any(lcaname, 'Angus', 'Dundee City', 'Perth & Kinross') hb eq 'NHS Tayside'.
if any(lcaname, 'Western Isles') hb eq 'NHS Western Isles'.
if any(lcaname, '', 'Other Non Scottish Residents') hb eq 'Other Non Scottish Residents'.

aggregate outfile = *
/break  hb AgeBand NRAC_PW
/Popn = sum(popn).

save outfile = !file + 'NRAC_part3.sav'.

*Add files together.

add files file = !file + 'NRAC_part1.sav' 
 /file =  !file + 'NRAC_part2.sav'
 /file = !file + 'NRAC_part3.sav'.
execute. 

string LCA_HB_SCOT (a35).
if hb eq '' LCA_HB_SCOT eq lcaname.
if lcaname eq '' LCA_HB_SCOT  eq hb.
if prac ne '' LCA_HB_SCOT  eq prac.

alter type nrac_Pw (a10).
rename variables ageband = agegroup.
alter type agegroup (a10).
sort cases by nrac_pw LCA_HB_SCOT agegroup.

string year (a4).
compute year = '1516'.

rename variables hb = HBres.

alter type lcaname (a25).
alter type prac (a5).
alter type nrac_pw (a10).

save outfile = !file + 'NRAC_1516.sav' /zcompressed.

********************************************************************************************************************************************************************************************************.
********************************************************************************************************************************************************************************************************.

* 16/17 Populations file.

get file ='/conf/hscdiip/08-Models/NRAC CHP model/model construction/201617 Model/final/NRAC_HSCP_GPprac_weighted_pop.sav'.

sort cases by gpprac.
rename variables gpprac = prac.
rename variables caregrp = NRAC_PW.
alter type prac (a6).

match files file = *
/table = !file+  'Prac_LA.sav'
/by prac.

* Code in age groups as reported on in workbook.

string AgeBand (a8).
if any(Age, '0-1', '2-4', '5-9', '10-14', '15-17') AgeBand eq '0-17'.
if any(Age, '18-19', '20-24', '25-29', '30-34', '35-39', '40-44') AgeBand eq '18-44'.
if any(Age, '45-49', '50-54', '55-59', '60-64') AgeBand eq '45-64'.
if any(Age, '65-69', '70-74') AgeBand eq '65-74'. 
if any(Age, '75-79', '80-84') AgeBand eq '75-84'. 
if any(Age, '85-89', '90+') AgeBand eq '85+'.

select if age ne 'All'.

aggregate outfile = *
/break LCAname AgeBand PRAC NRAC_PW
/Popn = sum(pop).

save outfile = !file + 'NRAC_temp.sav' /zcompressed.

get file = !file + 'NRAC_temp.sav'.

* Create an 'all ages' option.

compute AgeBand = 'All'.

aggregate outfile = *
/break LCAname AgeBand PRAC NRAC_PW
/Popn = sum(popn).

add files file = * 
 /file =  !file + 'NRAC_temp.sav'.
execute.

sort cases by prac.

if Nrac_pw eq 'Acute' Nrac_pw eq 'acute'.
if nrac_pw eq 'HCHS' nrac_pw eq 'hchs'.
if nrac_pw eq 'Mental Health & Learning Difficulties' nrac_pw eq 'mhld'.
select if any(nrac_pw, 'acute', 'hchs', 'mhld').

if lcaname eq 'Shetland Islands' lcaname eq 'Shetland'.
if lcaname eq 'Orkney Islands' lcaname eq 'Orkney'.
if lcaname eq 'Comhairle nan Eilean Siar' lcaname eq 'Western Isles'.
if lcaname eq 'Dundee' lcaname eq 'Dundee City'.
alter type prac (a5).

save outfile = !file + 'NRAC_part1.sav' /zcompressed.

*Aggreagte to get LA totals. 

aggregate outfile = *
/break lcaname AgeBand NRAC_PW
/Popn = sum(popn).

save outfile = !file + 'NRAC_part2.sav' /zcompressed.

* Aggregate to get HB totals. 

string HB (A35).
if any(lcaname, 'East Ayrshire', 'North Ayrshire', 'South Ayrshire') hb eq 'NHS Ayrshire & Arran'.
if any(lcaname, 'Scottish Borders') hb eq 'NHS Borders'.
if any(lcaname, 'Dumfries & Galloway') hb eq 'NHS Dumfries & Galloway'.
if any(lcaname, 'Fife') hb eq 'NHS Fife'.
if any(lcaname, 'Clackmannanshire', 'Falkirk', 'Stirling') hb eq 'NHS Forth Valley'.
if any(lcaname, 'Aberdeen City', 'Aberdeenshire', 'Moray', 'Grampian') hb eq 'NHS Grampian'.
if any(lcaname, 'East Dunbartonshire', 'East Renfrewshire', 'Glasgow City', 'Inverclyde', 'Renfrewshire', 'West Dunbartonshire') hb eq 'NHS Greater Glasgow & Clyde'.
if any(lcaname, 'Argyll & Bute', 'Highland') hb eq 'NHS Highland'.
if any(lcaname, 'North Lanarkshire', 'South Lanarkshire') hb eq 'NHS Lanarkshire'.
if any(lcaname, 'City of Edinburgh', 'Midlothian', 'East Lothian', 'West Lothian') hb eq 'NHS Lothian'.
if any(lcaname, 'Orkney') hb eq 'NHS Orkney'.
if any(lcaname, 'Shetland') hb eq 'NHS Shetland'.
if any(lcaname, 'Angus', 'Dundee City', 'Perth & Kinross') hb eq 'NHS Tayside'.
if any(lcaname, 'Western Isles') hb eq 'NHS Western Isles'.
if any(lcaname, '', 'Other Non Scottish Residents') hb eq 'Other Non Scottish Residents'.

aggregate outfile = *
/break  hb AgeBand NRAC_PW
/Popn = sum(popn).

save outfile = !file + 'NRAC_part3.sav' /zcompressed.

*Add files together.

add files file = !file + 'NRAC_part1.sav' 
 /file =  !file + 'NRAC_part2.sav'
 /file = !file + 'NRAC_part3.sav'.
execute. 

string LCA_HB_SCOT (a35).
if hb eq '' LCA_HB_SCOT eq lcaname.
if lcaname eq '' LCA_HB_SCOT  eq hb.
if prac ne '' LCA_HB_SCOT  eq prac.

alter type nrac_Pw (a10).
rename variables ageband = agegroup.
alter type agegroup (a10).
sort cases by nrac_pw LCA_HB_SCOT agegroup.

string year (a4).
compute year = '1617'.

rename variables hb = HBres.

alter type lcaname (a25).
alter type prac (a5).
alter type nrac_pw (a10).

save outfile = !file + 'NRAC_1617.sav' /zcompressed.

********************************************************************************************************************************************************************************************************.
********************************************************************************************************************************************************************************************************.

* 17/18 Populations file.
* issue noticed with this file - there are 64 practices with no HSCP / LA / HB attached. Contact costs team to query this.
* 3 practices where LCAname does not match on from lookup, these are old practices which have closed in 2001/2002 - they should not have populations attached to them! Query this.

get file ='/conf/hscdiip/08-Models/NRAC CHP model/model construction/201718 Model/final/NRAC_CHP_model_GPprac_weighted_pop.sav'.

*alter types required as it is a locale file.
alter type gpprac (A5).
alter type HSCP (A9).
alter type CA (A9).
alter type HB2006 (A9).
alter type HB2014 (A9).
alter type age (A5).
alter type sex (A6).
alter type caregrp (A40).

sort cases by gpprac.
rename variables gpprac = prac.
rename variables caregrp = NRAC_PW.
alter type prac (a6).

match files file = *
/table = !file+  'Prac_LA.sav'
/by prac.

* Code in age groups as reported on in workbook.

string AgeBand (a8).
if any(Age, '0-1', '2-4', '5-9', '10-14', '15-17') AgeBand eq '0-17'.
if any(Age, '18-19', '20-24', '25-29', '30-34', '35-39', '40-44') AgeBand eq '18-44'.
if any(Age, '45-49', '50-54', '55-59', '60-64') AgeBand eq '45-64'.
if any(Age, '65-69', '70-74') AgeBand eq '65-74'. 
if any(Age, '75-79', '80-84') AgeBand eq '75-84'. 
if any(Age, '85-89', '90+') AgeBand eq '85+'.

select if age ne 'All'.

aggregate outfile = *
/break LCAname AgeBand PRAC NRAC_PW
/Popn = sum(pop).

save outfile = !file + 'NRAC_temp.sav' /zcompressed.

get file = !file + 'NRAC_temp.sav'.

* Create an 'all ages' option.

compute AgeBand = 'All'.

aggregate outfile = *
/break LCAname AgeBand PRAC NRAC_PW
/Popn = sum(popn).

add files file = * 
 /file =  !file + 'NRAC_temp.sav'.
execute.

sort cases by prac.

if Nrac_pw eq 'Acute' Nrac_pw eq 'acute'.
if nrac_pw eq 'HCHS' nrac_pw eq 'hchs'.
if nrac_pw eq 'Mental Health & Learning Difficulties' nrac_pw eq 'mhld'.
select if any(nrac_pw, 'acute', 'hchs', 'mhld').

if lcaname eq 'Shetland Islands' lcaname eq 'Shetland'.
if lcaname eq 'Orkney Islands' lcaname eq 'Orkney'.
if lcaname eq 'Comhairle nan Eilean Siar' lcaname eq 'Western Isles'.
if lcaname eq 'Dundee' lcaname eq 'Dundee City'.
alter type prac (a5).

save outfile = !file + 'NRAC_part1.sav' /zcompressed.

*Aggreagte to get LA totals. 

aggregate outfile = *
/break lcaname AgeBand NRAC_PW
/Popn = sum(popn).

save outfile = !file + 'NRAC_part2.sav' /zcompressed.

* Aggregate to get HB totals. 

string HB (A35).
if any(lcaname, 'East Ayrshire', 'North Ayrshire', 'South Ayrshire') hb eq 'NHS Ayrshire & Arran'.
if any(lcaname, 'Scottish Borders') hb eq 'NHS Borders'.
if any(lcaname, 'Dumfries & Galloway') hb eq 'NHS Dumfries & Galloway'.
if any(lcaname, 'Fife') hb eq 'NHS Fife'.
if any(lcaname, 'Clackmannanshire', 'Falkirk', 'Stirling') hb eq 'NHS Forth Valley'.
if any(lcaname, 'Aberdeen City', 'Aberdeenshire', 'Moray', 'Grampian') hb eq 'NHS Grampian'.
if any(lcaname, 'East Dunbartonshire', 'East Renfrewshire', 'Glasgow City', 'Inverclyde', 'Renfrewshire', 'West Dunbartonshire') hb eq 'NHS Greater Glasgow & Clyde'.
if any(lcaname, 'Argyll & Bute', 'Highland') hb eq 'NHS Highland'.
if any(lcaname, 'North Lanarkshire', 'South Lanarkshire') hb eq 'NHS Lanarkshire'.
if any(lcaname, 'City of Edinburgh', 'Midlothian', 'East Lothian', 'West Lothian') hb eq 'NHS Lothian'.
if any(lcaname, 'Orkney') hb eq 'NHS Orkney'.
if any(lcaname, 'Shetland') hb eq 'NHS Shetland'.
if any(lcaname, 'Angus', 'Dundee City', 'Perth & Kinross') hb eq 'NHS Tayside'.
if any(lcaname, 'Western Isles') hb eq 'NHS Western Isles'.
if any(lcaname, '', 'Other Non Scottish Residents') hb eq 'Other Non Scottish Residents'.

aggregate outfile = *
/break  hb AgeBand NRAC_PW
/Popn = sum(popn).

save outfile = !file + 'NRAC_part3.sav' /zcompressed.

*Add files together.

add files file = !file + 'NRAC_part1.sav' 
 /file =  !file + 'NRAC_part2.sav'
 /file = !file + 'NRAC_part3.sav'.
execute. 

string LCA_HB_SCOT (a35).
if hb eq '' LCA_HB_SCOT eq lcaname.
if lcaname eq '' LCA_HB_SCOT  eq hb.
if prac ne '' LCA_HB_SCOT  eq prac.

alter type nrac_Pw (a10).
rename variables ageband = agegroup.
alter type agegroup (a10).
sort cases by nrac_pw LCA_HB_SCOT agegroup.

string year (a4).
compute year = '1718'.

rename variables hb = HBres.

alter type lcaname (a25).
alter type prac (a5).
alter type nrac_pw (a10).

save outfile = !file + 'NRAC_1718.sav' /zcompressed.



********************************************************************************************************************************************************************************************************.
********************************************************************************************************************************************************************************************************.

* 18/19 populations.

get file ='/conf/hscdiip/08-Models/NRAC CHP model/model construction/201819 Model/final/NRAC_CHP_model_GPprac_weighted_pop.sav'.

*alter types required as it is a locale file.
alter type gpprac (A5).
alter type HSCP (A9).
alter type CA (A9).
alter type HB2006 (A9).
alter type HB2018 (A9).
alter type age (A5).
alter type sex (A6).
alter type caregrp (A40).

sort cases by gpprac.
rename variables gpprac = prac.
rename variables caregrp = NRAC_PW.
alter type prac (a6).

match files file = *
/table = !file+  'Prac_LA.sav'
/by prac.

* Code in age groups as reported on in workbook.

string AgeBand (a8).
if any(Age, '0-1', '2-4', '5-9', '10-14', '15-17') AgeBand eq '0-17'.
if any(Age, '18-19', '20-24', '25-29', '30-34', '35-39', '40-44') AgeBand eq '18-44'.
if any(Age, '45-49', '50-54', '55-59', '60-64') AgeBand eq '45-64'.
if any(Age, '65-69', '70-74') AgeBand eq '65-74'. 
if any(Age, '75-79', '80-84') AgeBand eq '75-84'. 
if any(Age, '85-89', '90+') AgeBand eq '85+'.

select if age ne 'All'.

aggregate outfile = *
/break LCAname AgeBand PRAC NRAC_PW
/Popn = sum(pop).

save outfile = !file + 'NRAC_temp.sav' /zcompressed.

get file = !file + 'NRAC_temp.sav'.

* Create an 'all ages' option.

compute AgeBand = 'All'.

aggregate outfile = *
/break LCAname AgeBand PRAC NRAC_PW
/Popn = sum(popn).

add files file = * 
 /file =  !file + 'NRAC_temp.sav'.
execute.

sort cases by prac.

if Nrac_pw eq 'Acute' Nrac_pw eq 'acute'.
if nrac_pw eq 'HCHS' nrac_pw eq 'hchs'.
if nrac_pw eq 'Mental Health & Learning Difficulties' nrac_pw eq 'mhld'.
select if any(nrac_pw, 'acute', 'hchs', 'mhld').

if lcaname eq 'Shetland Islands' lcaname eq 'Shetland'.
if lcaname eq 'Orkney Islands' lcaname eq 'Orkney'.
if lcaname eq 'Comhairle nan Eilean Siar' lcaname eq 'Western Isles'.
if lcaname eq 'Dundee' lcaname eq 'Dundee City'.
alter type prac (a5).

save outfile = !file + 'NRAC_part1.sav' /zcompressed.

*Aggreagte to get LA totals. 

aggregate outfile = *
/break lcaname AgeBand NRAC_PW
/Popn = sum(popn).

save outfile = !file + 'NRAC_part2.sav' /zcompressed.

* Aggregate to get HB totals. 

string HB (A35).
if any(lcaname, 'East Ayrshire', 'North Ayrshire', 'South Ayrshire') hb eq 'NHS Ayrshire & Arran'.
if any(lcaname, 'Scottish Borders') hb eq 'NHS Borders'.
if any(lcaname, 'Dumfries & Galloway') hb eq 'NHS Dumfries & Galloway'.
if any(lcaname, 'Fife') hb eq 'NHS Fife'.
if any(lcaname, 'Clackmannanshire', 'Falkirk', 'Stirling') hb eq 'NHS Forth Valley'.
if any(lcaname, 'Aberdeen City', 'Aberdeenshire', 'Moray', 'Grampian') hb eq 'NHS Grampian'.
if any(lcaname, 'East Dunbartonshire', 'East Renfrewshire', 'Glasgow City', 'Inverclyde', 'Renfrewshire', 'West Dunbartonshire') hb eq 'NHS Greater Glasgow & Clyde'.
if any(lcaname, 'Argyll & Bute', 'Highland') hb eq 'NHS Highland'.
if any(lcaname, 'North Lanarkshire', 'South Lanarkshire') hb eq 'NHS Lanarkshire'.
if any(lcaname, 'City of Edinburgh', 'Midlothian', 'East Lothian', 'West Lothian') hb eq 'NHS Lothian'.
if any(lcaname, 'Orkney') hb eq 'NHS Orkney'.
if any(lcaname, 'Shetland') hb eq 'NHS Shetland'.
if any(lcaname, 'Angus', 'Dundee City', 'Perth & Kinross') hb eq 'NHS Tayside'.
if any(lcaname, 'Western Isles') hb eq 'NHS Western Isles'.
if any(lcaname, '', 'Other Non Scottish Residents') hb eq 'Other Non Scottish Residents'.

aggregate outfile = *
/break  hb AgeBand NRAC_PW
/Popn = sum(popn).

save outfile = !file + 'NRAC_part3.sav' /zcompressed.

*Add files together.

add files file = !file + 'NRAC_part1.sav' 
 /file =  !file + 'NRAC_part2.sav'
 /file = !file + 'NRAC_part3.sav'.
execute. 

string LCA_HB_SCOT (a35).
if hb eq '' LCA_HB_SCOT eq lcaname.
if lcaname eq '' LCA_HB_SCOT  eq hb.
if prac ne '' LCA_HB_SCOT  eq prac.

alter type nrac_Pw (a10).
rename variables ageband = agegroup.
alter type agegroup (a10).
sort cases by nrac_pw LCA_HB_SCOT agegroup.

string year (a4).
compute year = '1819'.

rename variables hb = HBres.

alter type lcaname (a25).
alter type prac (a5).
alter type nrac_pw (a10).

save outfile = !file + 'NRAC_1819.sav' /zcompressed.

****************************************************************************************************************************************************************.
****************************************************************************************************************************************************************.

*** Step 3: Combine files ***.

add files 
 /file = !file + 'NRAC_1516.sav'
 /file = !file + 'NRAC_1617.sav'
 /file = !file + 'NRAC_1718.sav'
 /file = !file + 'NRAC_1819.sav'.

rename variables (NRAC_PW = CareType) (LCA_HB_SCOT = NRAC_Key).

sort cases by year CareType NRAC_Key agegroup.

save outfile = !file + 'NRACPracticefinal.sav' /zcompressed.

get file = !file + 'NRACPracticefinal.sav'.

select if length(NRAC_Key) > 5.
execute.

save outfile = !file + 'NRACLCAfinal.sav' /zcompressed.

