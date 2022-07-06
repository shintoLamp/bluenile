* Encoding: UTF-8.
* Syntax for NRAC populations required for Hospital Expenditure and Activity workbook.
* Updated by Rachael Bainbridge 21/02/2019.
* Updated by Bateman McBride 03/2020.

************************************************************************************.
*Define filepath for working area on sourcedev.
Define !file()
       '/conf/sourcedev/TableauUpdates/Hospital Expenditure and Activity/Development and Checking/2020 syntax reorganise/'
!Enddefine.

*** Step 1: Produce practice to LCA lookup ***.

*First create GP to LA lookup file. This is the LA where the practice is based.

get file = '/conf/linkage/output/lookups/Unicode/National Reference Files/GP_CHP.sav'.

sort cases by GP_Practice_Code.

compute chp_name = replace(chp_name, ' Community Health Partnership', '').
compute chp_name = replace(Chp_name, ' Community Health & Care Partnership', '').
compute chp_name = replace(Chp_name, ' Health and Social Care Partnership', '').
compute chp_name = replace(Chp_name, ' Community Health & Social Care Partnership', '').
execute.

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

rename variables Address1 = PracticeName.

save outfile =  !file + 'Prac_LA.sav'
/keep prac LCAname PracticeName
/zcompressed.

********************************************************************************************************************************************************************************************************.
********************************************************************************************************************************************************************************************************.
*** Step 2: Run population files for all years ***.

* 16/17 Populations file.

get file ='/conf/hscdiip/08-Models/NRAC CHP model/model construction/201617 Model/final/NRAC_HSCP_GPprac_weighted_pop.sav'.

sort cases by gpprac.
rename variables gpprac = prac.
rename variables caregrp = caretype.
alter type prac (a6).

match files file = *
/table = !file+  'Prac_LA.sav'
/by prac.
execute.

* Code in age groups as reported on in workbook.

string agegroup(a10).
RECODE age ('0-1', '2-4', '5-9', '10-14', '15-17'='0-17')
                    ('18-19', '20-24', '25-29', '30-34', '35-39', '40-44'='18-44') 
                    ('45-49', '50-54', '55-59', '60-64'='45-64') 
                    ( '65-69', '70-74'='65-74') 
                    ('75-79', '80-84'='75-84') 
                    ('85-89', '90+'='85+')
                    ('All' = 'All Ages') 
into agegroup.
 * select if age ne 'All'.

aggregate outfile = *
/break LCAname Agegroup PRAC caretype PracticeName
/Popn = sum(pop).

save outfile = !file + 'NRAC_temp.sav' /zcompressed.
get file = !file + 'NRAC_temp.sav'.

* Create a block of C&S.
select if lcaname = 'Clackmannanshire' or lcaname = 'Stirling'.
compute lcaname = 'Clackmannanshire & Stirling'.
aggregate outfile = !file + 'CSPopTemp.sav'
/break lcaname AgeGroup PRAC caretype
/Popn = sum(popn).

add files file = !file + 'NRAC_temp.sav' 
/file =  !file + 'CSPopTemp.sav'.
execute.

sort cases by prac.

if caretype eq 'Acute' caretype eq 'acute'.
if caretype eq 'HCHS' caretype eq 'hchs'.
if caretype eq 'Mental Health & Learning Difficulties' caretype eq 'mhld'.
select if any(caretype, 'acute', 'hchs', 'mhld').
execute.
frequencies lcaname.

alter type prac (a5).

save outfile = !file + 'NRAC_part1.sav' /zcompressed.

*Aggregate to get LA totals. 

aggregate outfile = *
/break lcaname Agegroup caretype
/Popn = sum(popn).

save outfile = !file + 'NRAC_part2.sav' /zcompressed.

* Aggregate to get HB totals. 

string HB (A35).
if any(lcaname, 'East Ayrshire', 'North Ayrshire', 'South Ayrshire') hb eq 'NHS Ayrshire & Arran'.
if any(lcaname, 'Scottish Borders') hb eq 'NHS Borders'.
if any(lcaname, 'Dumfries & Galloway') hb eq 'NHS Dumfries & Galloway'.
if any(lcaname, 'Fife') hb eq 'NHS Fife'.
if any(lcaname, 'Clackmannanshire', 'Falkirk', 'Stirling', 'Clackmannanshire & Stirling') hb eq 'NHS Forth Valley'.
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
execute.

* Health Board totals but don't include C&S because it'll double-count.
select if lcaname ne 'Clackmannanshire & Stirling'.
aggregate outfile = *
/break hb AgeGroup caretype
/Popn = sum(popn).

save outfile = !file + 'NRAC_part3.sav'.

*Add files together.

add files file = !file + 'NRAC_part1.sav' 
 /file =  !file + 'NRAC_part2.sav'
 /file = !file + 'NRAC_part3.sav'.
execute. 

string year (a4).
compute year = '1617'.
string NRACmatch(a10).
if hb eq '' NRACmatch eq 'LCA Level'.
if lcaname eq '' NRACmatch eq 'HB Level'.
if prac ne '' NRACmatch eq 'Prac Level'.
execute.

save outfile = !file + 'NRAC_1617.sav' /zcompressed.

********************************************************************************************************************************************************************************************************.
********************************************************************************************************************************************************************************************************.

* 17/18 Populations file.
* issue noticed with this file - there are 64 practices with no HSCP / LA / HB attached. Contact costs team to query this.
* 3 practices where LCAname does not match on from lookup, these are old practices which have closed in 2001/2002 - they should not have populations attached to them! Query this.

get file ='/conf/hscdiip/08-Models/NRAC CHP model/model construction/201718 Model/final/NRAC_CHP_model_GPprac_weighted_pop.sav'.

*alter types required as it is a locale file.
 * alter type gpprac (A5).
 * alter type HSCP (A9).
 * alter type CA (A9).
 * alter type HB2006 (A9).
 * alter type HB2014 (A9).
 * alter type age (A5).
 * alter type sex (A6).
 * alter type caregrp (A40).

sort cases by gpprac.
rename variables gpprac = prac.
rename variables caregrp = caretype.
alter type prac (a6).

match files file = *
/table = !file+  'Prac_LA.sav'
/by prac.
execute.

* Code in age groups as reported on in workbook.

string agegroup(a10).
RECODE age ('0-1', '2-4', '5-9', '10-14', '15-17'='0-17')
                    ('18-19', '20-24', '25-29', '30-34', '35-39', '40-44'='18-44') 
                    ('45-49', '50-54', '55-59', '60-64'='45-64') 
                    ( '65-69', '70-74'='65-74') 
                    ('75-79', '80-84'='75-84') 
                    ('85-89', '90+'='85+')
                    ('All' = 'All Ages') 
into agegroup.
 * select if age ne 'All'.

aggregate outfile = *
/break LCAname Agegroup PRAC caretype PracticeName
/Popn = sum(pop).

save outfile = !file + 'NRAC_temp.sav' /zcompressed.
get file = !file + 'NRAC_temp.sav'.

* Create a block of C&S.
select if lcaname = 'Clackmannanshire' or lcaname = 'Stirling'.
compute lcaname = 'Clackmannanshire & Stirling'.
aggregate outfile = !file + 'CSPopTemp.sav'
/break lcaname AgeGroup PRAC caretype
/Popn = sum(popn).

add files file = !file + 'NRAC_temp.sav' 
/file =  !file + 'CSPopTemp.sav'.
execute.

sort cases by prac.

if caretype eq 'Acute' caretype eq 'acute'.
if caretype eq 'HCHS' caretype eq 'hchs'.
if caretype eq 'Mental Health & Learning Difficulties' caretype eq 'mhld'.
select if any(caretype, 'acute', 'hchs', 'mhld').
execute.
frequencies lcaname.

alter type prac (a5).

save outfile = !file + 'NRAC_part1.sav' /zcompressed.

*Aggregate to get LA totals. 

aggregate outfile = *
/break lcaname Agegroup caretype
/Popn = sum(popn).

save outfile = !file + 'NRAC_part2.sav' /zcompressed.

* Aggregate to get HB totals. 

string HB (A35).
if any(lcaname, 'East Ayrshire', 'North Ayrshire', 'South Ayrshire') hb eq 'NHS Ayrshire & Arran'.
if any(lcaname, 'Scottish Borders') hb eq 'NHS Borders'.
if any(lcaname, 'Dumfries & Galloway') hb eq 'NHS Dumfries & Galloway'.
if any(lcaname, 'Fife') hb eq 'NHS Fife'.
if any(lcaname, 'Clackmannanshire', 'Falkirk', 'Stirling', 'Clackmannanshire & Stirling') hb eq 'NHS Forth Valley'.
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
execute.

* Health Board totals but don't include C&S because it'll double-count.
select if lcaname ne 'Clackmannanshire & Stirling'.
aggregate outfile = *
/break hb AgeGroup caretype
/Popn = sum(popn).

save outfile = !file + 'NRAC_part3.sav'.

*Add files together.

add files file = !file + 'NRAC_part1.sav' 
 /file =  !file + 'NRAC_part2.sav'
 /file = !file + 'NRAC_part3.sav'.
execute. 

string year (a4).
compute year = '1718'.
string NRACmatch(a10).
if hb eq '' NRACmatch eq 'LCA Level'.
if lcaname eq '' NRACmatch eq 'HB Level'.
if prac ne '' NRACmatch eq 'Prac Level'.
execute.

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
alter type caregrp (A37).

sort cases by gpprac.
rename variables gpprac = prac.
rename variables caregrp = caretype.
alter type prac (a6).

match files file = *
/table = !file+  'Prac_LA.sav'
/by prac.
execute.

* Code in age groups as reported on in workbook.

string agegroup(a10).
RECODE age ('0-1', '2-4', '5-9', '10-14', '15-17'='0-17')
                    ('18-19', '20-24', '25-29', '30-34', '35-39', '40-44'='18-44') 
                    ('45-49', '50-54', '55-59', '60-64'='45-64') 
                    ( '65-69', '70-74'='65-74') 
                    ('75-79', '80-84'='75-84') 
                    ('85-89', '90+'='85+')
                    ('All' = 'All Ages') 
into agegroup.
 * select if age ne 'All'.

aggregate outfile = *
/break LCAname Agegroup PRAC caretype PracticeName
/Popn = sum(pop).

save outfile = !file + 'NRAC_temp.sav' /zcompressed.
get file = !file + 'NRAC_temp.sav'.

* Create a block of C&S.
select if lcaname = 'Clackmannanshire' or lcaname = 'Stirling'.
compute lcaname = 'Clackmannanshire & Stirling'.
aggregate outfile = !file + 'CSPopTemp.sav'
/break lcaname AgeGroup PRAC caretype
/Popn = sum(popn).

add files file = !file + 'NRAC_temp.sav' 
/file =  !file + 'CSPopTemp.sav'.
execute.

sort cases by prac.

if caretype eq 'Acute' caretype eq 'acute'.
if caretype eq 'HCHS' caretype eq 'hchs'.
if caretype eq 'Mental Health & Learning Difficulties' caretype eq 'mhld'.
select if any(caretype, 'acute', 'hchs', 'mhld').
execute.
frequencies lcaname.

alter type prac (a5).

save outfile = !file + 'NRAC_part1.sav' /zcompressed.

*Aggregate to get LA totals. 

aggregate outfile = *
/break lcaname Agegroup caretype
/Popn = sum(popn).

save outfile = !file + 'NRAC_part2.sav' /zcompressed.

* Aggregate to get HB totals. 

string HB (A35).
if any(lcaname, 'East Ayrshire', 'North Ayrshire', 'South Ayrshire') hb eq 'NHS Ayrshire & Arran'.
if any(lcaname, 'Scottish Borders') hb eq 'NHS Borders'.
if any(lcaname, 'Dumfries & Galloway') hb eq 'NHS Dumfries & Galloway'.
if any(lcaname, 'Fife') hb eq 'NHS Fife'.
if any(lcaname, 'Clackmannanshire', 'Falkirk', 'Stirling', 'Clackmannanshire & Stirling') hb eq 'NHS Forth Valley'.
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
execute.

* Health Board totals but don't include C&S because it'll double-count.
select if lcaname ne 'Clackmannanshire & Stirling'.
aggregate outfile = *
/break hb AgeGroup caretype
/Popn = sum(popn).

save outfile = !file + 'NRAC_part3.sav'.

*Add files together.

add files file = !file + 'NRAC_part1.sav' 
 /file =  !file + 'NRAC_part2.sav'
 /file = !file + 'NRAC_part3.sav'.
execute. 

string year (a4).
compute year = '1819'.
string NRACmatch(a10).
if hb eq '' NRACmatch eq 'LCA Level'.
if lcaname eq '' NRACmatch eq 'HB Level'.
if prac ne '' NRACmatch eq 'Prac Level'.
execute.

save outfile = !file + 'NRAC_1819.sav' /zcompressed.

***********************************************************************************.
***********************************************************************************.
* Currently using estimates for 19/20 based on 18/19 model.

compute year = '1920'.
save outfile = !file + 'NRAC_1920.sav' /zcompressed.

****************************************************************************************************************************************************************.
****************************************************************************************************************************************************************.
*** Step 3: Combine files ***.
add files 
 /file = !file + 'NRAC_1617.sav'
 /file = !file + 'NRAC_1718.sav'
 /file = !file + 'NRAC_1819.sav'
 /file = !file + 'NRAC_1920.sav'.

alter type lcaname(a30) caretype(a10).
if lcaname = 'Dundee' lcaname = 'Dundee City'.
if lcaname = 'Orkney' lcaname = 'Orkney Islands'.
if lcaname = 'Shetland' lcaname = 'Shetland Islands'.

select if (lcaname ne '') or (hb ne '') or (prac ne '').

sort cases by hb lcaname prac year caretype NRACMatch agegroup.
save outfile = !file + 'NRACfinal.sav'.

* Save out LCA level populations.
get file = !file + 'NRACfinal.sav'.
select if NRACmatch = 'LCA Level'.
sort cases by lcaname year agegroup caretype nracmatch.
save outfile = !file + 'NRACLCA.sav' /zcompressed.

* Save out Practice-level populations.
get file = !file + 'NRACfinal.sav'.
select if NRACmatch = 'Prac Level'.
sort cases by lcaname year agegroup prac caretype nracmatch.
save outfile = !file + 'NRACPractice.sav' /zcompressed.

* Save out Practice-level populations.
get file = !file + 'NRACfinal.sav'.
select if NRACmatch = 'HB Level'.
sort cases by hb year agegroup caretype nracmatch.
save outfile = !file + 'NRACBoard.sav' /zcompressed.

erase file = !file + 'NRAC_1617.sav'.
erase file = !file + 'NRAC_1718.sav'.
erase file = !file + 'NRAC_1819.sav'.
erase file = !file + 'NRAC_1920.sav'.
erase file = !file + 'NRAC_part1.sav'.
erase file = !file + 'NRAC_part2.sav'.
erase file = !file + 'NRAC_part3.sav'.
