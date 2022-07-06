* Encoding: UTF-8.
*** Creation of delyed Discharge PARTNERSHIP dataset for tableau.
*** Prog created Oct 2015 by Euan Patterson.
*** syntax update by Lauren Dickson Dec 18

*** Source data file will need to be requested from delayed discharge guys (Deanna or Martin)in same format as current file.

GET DATA
  /TYPE=XLS
  /FILE='/conf/irf/09-Tableau-Outputs/01-Development/04-Source-Data/04-Delayed-Discharge/Old Data/DDcosts2012-14-V1-27-10-15.xls'
  /SHEET=name 'RawData'
  /CELLRANGE=full
  /READNAMES=on
  /ASSUMEDSTRWIDTH=32767.
EXECUTE.


*** Tidy-up file - Remove unwanted data at Partnership level.

* Remove Scotland totals.
do if LCAcode eq '60'.
 compute lcaname eq 'Scotland'.
end if.
EXECUTE.

* Remove Unknown LA data.
Select if LCAcode NE '99'.
EXECUTE.

* Rename Spec totals.
if Spec = 'AllS' Spec = 'All'.
if Spec = 'AllS' specname = 'All Specialties'.
EXECUTE.

* Create new Variable to identify Quarters and Fin Year Totals.
String Quarter (A10).
if Period = '2012-13 Quarter 1' Quarter = 'Q1'.
if Period = '2012-13 Quarter 2' Quarter = 'Q2'.
if Period = '2012-13 Quarter 3' Quarter = 'Q3'.
if Period = '2012-13 Quarter 4' Quarter = 'Q4'.
if Period = '2013-14 Quarter 1' Quarter = 'Q1'.
if Period = '2013-14 Quarter 2' Quarter = 'Q2'.
if Period = '2013-14 Quarter 3' Quarter = 'Q3'.
if Period = '2013-14 Quarter 4' Quarter = 'Q4'.
EXECUTE.

select if Quarter ne ' '. 
exe.

* Change code type.
alter type code_type (A15).
if code_type='9' code_type='Code 9'.
if code_type='S' code_type='Standard Delays'.
EXECUTE.


ALTER TYPE LCAcode (A9).
compute lcacode=ltrim(lcacode).
Recode LCAcode
('1'='S12000033')
('2'='S12000034')
('3'='S12000041')
('4'='S12000035')
('5'='S12000026')
('6'='S12000005')
('7'='S12000039')
('8'='S12000006')
('9'='S12000042')
('10'='S12000008')
('11'='S12000045')
('12'='S12000010')
('13'='S12000011')
('14'='S12000036')
('15'='S12000014')
('16'='S12000015')
('17'='S12000046')
('18'='S12000017')
('19'='S12000018')
('20'='S12000019')
('21'='S12000020')
('22'='S12000021')
('23'='S12000044')
('24'='S12000023')
('25'='S12000024')
('26'='S12000038')
('27'='S12000027')
('28'='S12000028')
('29'='S12000029')
('30'='S12000030')
('31'='S12000040')
('32'='S12000013')
('60'='S12000099').
EXECUTE.

rename variables (LCAcode = LA_Code).
rename variables (LCAname = LA_Name).
rename variables (DailyCost=DailyCostOriginal).
rename variables (TotalCost=TotalCostOriginal).

sort cases by specname Year quarter Agegroup code_type LA_Code.

if agegroup = 'All ages' agegroup = 'All'.
execute. 

delete variables delays.
Execute.

SAVE OUTFILE='/conf/irf/09-Tableau-Outputs/01-Development/02-SPSS-Outputs/04-Delayed-Discharge/DD_LA_Master_part1.sav'
  /DROP=code scode Period Board Pop.2012 Pop.2013
  /COMPRESSED.

get file = '/conf/irf/09-Tableau-Outputs/01-Development/02-SPSS-Outputs/04-Delayed-Discharge/DD_LA_Master_part1.sav'.

*Format new data to add to old.


GET DATA  /TYPE=TXT
  /FILE="/conf/irf/09-Tableau-Outputs/01-Development/04-Source-Data/04-Delayed-Discharge/Update/1415Final.csv"
  /ENCODING='UTF8'
  /DELCASE=LINE
  /DELIMITERS=","
  /QUALIFIER='"'
  /ARRANGEMENT=DELIMITED
  /FIRSTCASE=2
  /IMPORTCASE=ALL
  /VARIABLES=
  Year A7
  cennum F3.0
  census A8
  HB A1
  HBname A35
  LCAcode A2
  LA A25
  Agegroup A8
  code_type A8
  spec A4
  specname A36
  Delays F2.0
  SpecBeddays F11.8
  TotalCostOriginal F11.6
  DailyCostOriginal F11.7.
CACHE.
EXECUTE.


rename variables (LCAcode=LA_Code).
rename variables (LA=LA_Name).
execute.


delete variables HB.
delete variables Delays.
EXECUTE.

SAVE OUTFILE='/conf/irf/09-Tableau-Outputs/01-Development/02-SPSS-Outputs/04-Delayed-Discharge/DD1415.sav'.

GET DATA  /TYPE=TXT
  /FILE="/conf/irf/09-Tableau-Outputs/01-Development/04-Source-Data/04-Delayed-Discharge/Update/1516Final.csv"
  /ENCODING='UTF8'
  /DELCASE=LINE
  /DELIMITERS=","
  /QUALIFIER='"'
  /ARRANGEMENT=DELIMITED
  /FIRSTCASE=2
  /IMPORTCASE=ALL
  /VARIABLES=
  Year A7
  cennum F3.0
  census A8
  HB A1
  HBname A35
  laresid A1
  LA A25
  Agegroup A8
  code_type A8
  spec A4
  specname A36
  Delays F2.0
  SpecBeddays F11.8
  TotalCostOriginal F11.6
  DailyCostOriginal F11.7.
CACHE.
EXECUTE.

rename variables (LA=LA_Name).
execute.

String LA_Code (A2).
If LA_Name='Aberdeen City' LA_Code='01'.
If LA_Name= 'Aberdeenshire' LA_Code='02'.
If LA_Name='Angus' LA_Code='03'.
If LA_Name='Argyll and Bute' LA_Code='04'.
If LA_Name='Scottish Borders' LA_Code='05'.
If LA_Name='Clackmannanshire' LA_Code='06'.
If LA_Name= 'West Dunbartonshire' LA_Code='07'.
If LA_Name='Dumfries & Galloway' LA_Code='08'.
If LA_Name='Dundee City' LA_Code='09'.
If LA_Name= 'East Ayrshire' LA_Code='10'.
If LA_Name='East Dunbartonshire' LA_Code='11'.
If LA_Name='East Lothian' LA_Code='12'.
If LA_Name='East Renfrewshire' LA_Code='13'.
If LA_Name='Edinburgh City' LA_Code='14'.
If LA_Name= 'Falkirk' LA_Code='15'.
If LA_Name='Fife' LA_Code='16'.
If LA_Name='Glasgow City' LA_Code='17'.
If LA_Name='Highland' LA_Code='18'.
If LA_Name= 'Inverclyde' LA_Code='19'.
If LA_Name='Midlothian' LA_Code='20'.
If LA_Name='Moray' LA_Code='21'.
If LA_Name='North Ayrshire' LA_Code='22'.
If LA_Name='North Lanarkshire' LA_Code='23'.
If LA_Name= 'Ornkey' LA_Code='24'.
If LA_Name='Perth and Kindross' LA_Code='25'.
If LA_Name='Shetland' LA_Code='27'.
If LA_Name='South Ayrshire' LA_Code='28'.
If LA_Name='South Lanarkshire' LA_Code='29'.
If LA_Name='Stirling' LA_Code='30'.
If LA_Name='West Lothian' LA_Code='31'.
If LA_Name='Eilean Siar' LA_Code='32'.
IF LA_Name='All' LA_Code='00'.
EXECUTE .


delete variables HB.
delete variables Delays.
delete variables laresid.
EXECUTE.

SAVE OUTFILE='/conf/irf/09-Tableau-Outputs/01-Development/02-SPSS-Outputs/04-Delayed-Discharge/DD1516.sav'.

GET DATA  /TYPE=TXT
  /FILE="/conf/irf/09-Tableau-Outputs/01-Development/04-Source-Data/04-Delayed-Discharge/Update/1617Final.csv"
  /ENCODING='UTF8'
  /DELCASE=LINE
  /DELIMITERS=","
  /QUALIFIER='"'
  /ARRANGEMENT=DELIMITED
  /FIRSTCASE=2
  /IMPORTCASE=ALL
  /VARIABLES=
  Year A7
  cennum F3.0
  census A8
  HB A35
  LA A25
  Agegroup A8
  code_type A8
  spec A4
  specname A36
  SpecBeddays F11.8
  TotalCostOriginal F11.6
  DailyCostOriginal F11.7.
CACHE.
EXECUTE.

rename variables (HB=HBname).
rename variables (LA=LA_Name).
execute.


String LA_Code (A2).
If LA_Name='Aberdeen City' LA_Code='01'.
If LA_Name= 'Aberdeenshire' LA_Code='02'.
If LA_Name='Angus' LA_Code='03'.
If LA_Name='Argyll and Bute' LA_Code='04'.
If LA_Name='Scottish Borders' LA_Code='05'.
If LA_Name='Clackmannanshire' LA_Code='06'.
If LA_Name= 'West Dunbartonshire' LA_Code='07'.
If LA_Name='Dumfries & Galloway' LA_Code='08'.
If LA_Name='Dundee City' LA_Code='09'.
If LA_Name= 'East Ayrshire' LA_Code='10'.
If LA_Name='East Dunbartonshire' LA_Code='11'.
If LA_Name='East Lothian' LA_Code='12'.
If LA_Name='East Renfrewshire' LA_Code='13'.
If LA_Name='Edinburgh City' LA_Code='14'.
If LA_Name= 'Falkirk' LA_Code='15'.
If LA_Name='Fife' LA_Code='16'.
If LA_Name='Glasgow City' LA_Code='17'.
If LA_Name='Highland' LA_Code='18'.
If LA_Name= 'Inverclyde' LA_Code='19'.
If LA_Name='Midlothian' LA_Code='20'.
If LA_Name='Moray' LA_Code='21'.
If LA_Name='North Ayrshire' LA_Code='22'.
If LA_Name='North Lanarkshire' LA_Code='23'.
If LA_Name= 'Ornkey' LA_Code='24'.
If LA_Name='Perth and Kindross' LA_Code='25'.
If LA_Name='Shetland' LA_Code='27'.
If LA_Name='South Ayrshire' LA_Code='28'.
If LA_Name='South Lanarkshire' LA_Code='29'.
If LA_Name='Stirling' LA_Code='30'.
If LA_Name='West Lothian' LA_Code='31'.
If LA_Name='Eilean Siar' LA_Code='32'.
IF LA_Name='ALL' LA_Code='00'.
EXECUTE .

SAVE OUTFILE='/conf/irf/09-Tableau-Outputs/01-Development/02-SPSS-Outputs/04-Delayed-Discharge/DD1617.sav'.

add files file = *
 /file = '/conf/irf/09-Tableau-Outputs/01-Development/02-SPSS-Outputs/04-Delayed-Discharge/DD1415.sav'
 /file = '/conf/irf/09-Tableau-Outputs/01-Development/02-SPSS-Outputs/04-Delayed-Discharge/DD1516.sav'.
execute.

** Tidy-up file - Remove unwanted data at Partnership level.
ALTER TYPE CENSUS (MOYR6).
ALTER TYPE CENSUS (A8).

RECODE LA_Name ('All' = 'ALL') ('Borders' = 'Scottish Borders') ('Western Isles' = 'Comhairle nan Eilean Siar').
freq var LA_Name.

* Remove Unknown LA data.
Select if LA_Code NE '99'.
EXECUTE.

* Rename Spec totals.
if Spec = 'AllS' Spec = 'All'.
if Spec = 'AllS' specname = 'All Specialties'.
EXECUTE.

String Quarter (A10).
if any(census, 'APR 2014', 'MAY 2014', 'JUN 2014', 'APR 2015', 'MAY 2015', 'JUN 2015', 'APR 2016', 'MAY 2016', 'JUN 2016') Quarter = 'Q1'.
if any(census, 'JUL 2014', 'AUG 2014', 'SEP 2014', 'JUL 2015', 'AUG 2015', 'SEP 2015', 'JUL 2016', 'AUG 2016', 'SEP 2016') Quarter = 'Q2'.
if any(census, 'OCT 2014', 'NOV 2014', 'DEC 2014', 'OCT 2015', 'NOV 2015', 'DEC 2015', 'OCT 2016', 'NOV 2016', 'DEC 2016') Quarter = 'Q3'.
if any(census, 'JAN 2015', 'FEB 2015', 'MAR 2015', 'JAN 2016', 'FEB 2016', 'MAR 2016', 'JAN 2017', 'FEB 2017', 'MAR 2017') Quarter = 'Q4'.
EXECUTE.


* Change code type.
alter type code_type (A15).
if code_type='Standard' code_type='Standard Delays'.
EXECUTE.

ALTER TYPE LA_Code (A9).
compute LA_Code=ltrim(LA_Code).
Recode LA_Code
('1'='S12000033')
('2'='S12000034')
('3'='S12000041')
('4'='S12000035')
('5'='S12000026')
('6'='S12000005')
('7'='S12000039')
('8'='S12000006')
('9'='S12000042')
('10'='S12000008')
('11'='S12000045')
('12'='S12000010')
('13'='S12000011')
('14'='S12000036')
('15'='S12000014')
('16'='S12000015')
('17'='S12000046')
('18'='S12000017')
('19'='S12000018')
('20'='S12000019')
('21'='S12000020')
('22'='S12000021')
('23'='S12000044')
('24'='S12000023')
('25'='S12000024')
('26'='S12000038')
('27'='S12000027')
('28'='S12000028')
('29'='S12000029')
('30'='S12000030')
('31'='S12000040')
('32'='S12000013').
EXECUTE.

if HBname = 'SCOTLAND'  LA_Code = 'S12000099'.
if HBname = 'SCOTLAND'  LA_Name = 'Scotland'.
select if LA_Code ne '00'.
execute. 

aggregate outfile = *
/break Year Quarter LA_Code LA_Name Agegroup code_type spec specname
/SpecBeddays TotalCostOriginal DailyCostOriginal = sum(SpecBeddays TotalCostOriginal DailyCostOriginal). 
execute. 


if LA_Name = 'Borders' LA_Name = 'Scottish Borders'.
if LA_Name = 'City of Edinburgh' LA_Name = 'Edinburgh City'.
if LA_Name = 'Orkney' LA_Name = 'Orkney Islands'.
if LA_Name = 'Shetland' LA_Name = 'Shetland Islands'.
if LA_Name = 'Western Isles' LA_Name = 'Comhairle nan Eilean Siar'.
execute.


SAVE OUTFILE= '/conf/irf/09-Tableau-Outputs/01-Development/02-SPSS-Outputs/04-Delayed-Discharge/DD_LA_Master_part2.sav'
  /COMPRESSED.

*Add old and new data. 

add files file = '/conf/irf/09-Tableau-Outputs/01-Development/02-SPSS-Outputs/04-Delayed-Discharge/DD_LA_Master_part1.sav'
/file = '/conf/irf/09-Tableau-Outputs/01-Development/02-SPSS-Outputs/04-Delayed-Discharge/DD_LA_Master_part2.sav'.
exe.

*Create annual total

Temporary.
compute Quarter = 'FinYear '. 
aggregate outfile =  '/conf/irf/09-Tableau-Outputs/01-Development/02-SPSS-Outputs/04-Delayed-Discharge/annualpart2.sav'
/break Year Quarter LA_Code LA_Name Agegroup code_type spec specname
/SpecBeddays TotalCostOriginal DailyCostOriginal = sum(SpecBeddays TotalCostOriginal DailyCostOriginal).
EXECUTE.

add files file = * 
 /file =  '/conf/irf/09-Tableau-Outputs/01-Development/02-SPSS-Outputs/04-Delayed-Discharge/annualpart2.sav'.
execute. 

select if agegroup ne '18-74'.
exe.

sort cases by specname Year quarter Agegroup code_type LA_Code LA_Name.

SAVE OUTFILE='/conf/irf/09-Tableau-Outputs/01-Development/02-SPSS-Outputs/04-Delayed-Discharge/DD_LA_Master.sav'.

get file = '/conf/irf/09-Tableau-Outputs/01-Development/02-SPSS-Outputs/04-Delayed-Discharge/DD_LA_Master.sav'.


* Need to create file with all data for All Specialties, Codes, Ages that has data for each quarter so that in Tableau complete timeseries always shown.
*Also need to add in two new years and a few new specialties to template.

GET DATA /TYPE=XLSX
  /FILE='/conf/irf/09-Tableau-Outputs/01-Development/04-Source-Data/04-Delayed-Discharge/Set_up_data_Template.xlsx'
  /SHEET=name 'Template'
  /CELLRANGE=full
  /READNAMES=on
  /ASSUMEDSTRWIDTH=32767.
EXECUTE.

ALTER TYPE quarter (A10).
ALTER TYPE specname (A36).
ALTER TYPE Spec (a4).
sort cases by specname Year quarter Agegroup code_type LA_Code.
exe.

SAVE OUTFILE='/conf/irf/09-Tableau-Outputs/01-Development/02-SPSS-Outputs/04-Delayed-Discharge/Template.sav'.

if year = '2012-13' year = '2014-15'.
if year = '2013-14' year = '2015-16'.
if year = '2013-14' year = '2016-17'.
EXECUTE.

SAVE OUTFILE='/conf/irf/09-Tableau-Outputs/01-Development/02-SPSS-Outputs/04-Delayed-Discharge/Template2.sav'.

select if specname = 'All Specialties' or specname = 'Cardiology' or specname = 'Cardiothoracic Surgery'.
EXECUTE.

if specname = 'All Specialties' specname = 'Accident & Emergency'.
if specname = 'Cardiology' specname = 'GP Obstetrics'.
if specname = 'Cardiothoracic Surgery' specname = 'Tropical Medicine'.
EXECUTE.

SAVE OUTFILE='/conf/irf/09-Tableau-Outputs/01-Development/02-SPSS-Outputs/04-Delayed-Discharge/Template3.sav'.

add files file = '/conf/irf/09-Tableau-Outputs/01-Development/02-SPSS-Outputs/04-Delayed-Discharge/Template.sav'
 /file = '/conf/irf/09-Tableau-Outputs/01-Development/02-SPSS-Outputs/04-Delayed-Discharge/Template2.sav'
 /file = '/conf/irf/09-Tableau-Outputs/01-Development/02-SPSS-Outputs/04-Delayed-Discharge/Template3.sav'.
execute.

SAVE OUTFILE='/conf/irf/09-Tableau-Outputs/01-Development/02-SPSS-Outputs/04-Delayed-Discharge/Template4.sav'.

select if LA_Code = 'S12000013'.
compute  LA_Code = 'S12000099'.
execute. 

add files file = *
 /file ='/conf/irf/09-Tableau-Outputs/01-Development/02-SPSS-Outputs/04-Delayed-Discharge/Template4.sav'.
execute. 

if agegroup = 'All ages' agegroup = 'All'.
execute. 

sort cases by specname Year quarter Agegroup code_type LA_Code.

*compute test=1.
MATCH FILES /FILE=*
  /FILE='/conf/irf/09-Tableau-Outputs/01-Development/02-SPSS-Outputs/04-Delayed-Discharge/DD_LA_Master.sav'
  /BY specname Year Quarter Agegroup code_type LA_Code.
EXECUTE.

*Fix missing LA Names.
if LA_CODE = 'S12000026' LA_Name = 'Scottish Borders'.
if LA_CODE = 'S12000015' LA_Name = 'Fife'.
if LA_CODE = 'S12000023' LA_Name = 'Orkney'.
if LA_CODE = 'S12000013' LA_Name = 'Western Isles'.
if LA_CODE = 'S12000006' LA_Name = 'Dumfries & Galloway'.
if LA_CODE = 'S12000027' LA_Name = 'Shetland'.
if LA_CODE = 'S12000021' LA_Name = 'North Ayrshire'.
if LA_CODE = 'S12000028' LA_Name = 'South Ayrshire'.
if LA_CODE = 'S12000008' LA_Name = 'East Ayrshire'.
if LA_CODE = 'S12000045' LA_Name = 'East Dunbartonshire'.
if LA_CODE = 'S12000046' LA_Name = 'Glasgow City'.
if LA_CODE = 'S12000011' LA_Name = 'East Renfrewshire'.
if LA_CODE = 'S12000039' LA_Name = 'West Dunbartonshire'.
if LA_CODE = 'S12000038' LA_Name = 'Renfrewshire'.
if LA_CODE = 'S12000018' LA_Name = 'Inverclyde'.
if LA_CODE = 'S12000017' LA_Name = 'Highland'.
if LA_CODE = 'S12000035' LA_Name = 'Argyll & Bute'.
if LA_CODE = 'S12000044' LA_Name = 'North Lanarkshire'.
if LA_CODE = 'S12000029' LA_Name = 'South Lanarkshire'.
if LA_CODE = 'S12000033' LA_Name = 'Aberdeen City'.
if LA_CODE = 'S12000034' LA_Name = 'Aberdeenshire'.
if LA_CODE = 'S12000020' LA_Name = 'Moray'.
if LA_CODE = 'S12000010' LA_Name = 'East Lothian'.
if LA_CODE = 'S12000040' LA_Name = 'West Lothian'.
if LA_CODE = 'S12000019' LA_Name = 'Midlothian'.
if LA_CODE = 'S12000036' LA_Name = 'City of Edinburgh'.
if LA_CODE = 'S12000024' LA_Name = 'Perth & Kinross'.
if LA_CODE = 'S12000042' LA_Name = 'Dundee City'.
if LA_CODE = 'S12000041' LA_Name = 'Angus'.
if LA_CODE = 'S12000005' LA_Name = 'Clackmannanshire'.
if LA_CODE = 'S12000014' LA_Name = 'Falkirk'.
if LA_CODE = 'S12000030' LA_Name = 'Stirling'.
if LA_CODE = 'S12000099' LA_Name = 'Scotland'.
EXECUTE.

SAVE OUTFILE='/conf/irf/09-Tableau-Outputs/01-Development/02-SPSS-Outputs/04-Delayed-Discharge/DD_LA_Master_v2.sav'
  /COMPRESSED.


* Identify delegated Specialites.
Get file ='/conf/irf/09-Tableau-Outputs/01-Development/02-SPSS-Outputs/04-Delayed-Discharge/DD_LA_Master_v2.sav'.

string delegated (A3).
compute delegated='No'.
* Not included 'C2' as A&E.
if any(spec,'A1','AB','AP','AQ','G1','G5','G21','G22','G3','G4','AM','E12') delegated='Yes'.
exe.

*Reduce to Delegated Specs only.
Select if delegated = 'Yes'.
exe.

* Create Flag to identify data.
String Data (A10).
compute Data = 'Delegated'.
exe.

SAVE OUTFILE='/conf/irf/09-Tableau-Outputs/01-Development/02-SPSS-Outputs/04-Delayed-Discharge/DD_LA_Master_temp3.sav'
  /COMPRESSED.

compute Spec = 'All'.
compute specname = 'All Specialties'.
EXECUTE.

AGGREGATE
  /OUTFILE= *
  /BREAK=Year AgeGroup code_type LA_Code LA_Name Quarter Data specname Spec 
  /SpecBeddays=SUM(SpecBeddays) 
  /TotalCostOriginal=SUM(TotalCostOriginal).


add files file = *
 /file = '/conf/irf/09-Tableau-Outputs/01-Development/02-SPSS-Outputs/04-Delayed-Discharge/DD_LA_Master_temp3.sav'.
EXECUTE.

save outfile =  '/conf/irf/09-Tableau-Outputs/01-Development/02-SPSS-Outputs/04-Delayed-Discharge/DD_LA_Master_temp4.sav'.

Get file ='/conf/irf/09-Tableau-Outputs/01-Development/02-SPSS-Outputs/04-Delayed-Discharge/DD_LA_Master_v2.sav'.

* Create Flag to identify data.
String Data (A10).
compute Data = 'Standard'.
exe.

add files file = *
/file ='/conf/irf/09-Tableau-Outputs/01-Development/02-SPSS-Outputs/04-Delayed-Discharge/DD_LA_Master_temp4.sav'.
EXECUTE.



**************************
*OLD pops look up. Changing to raw to line up with indicators. 

*rename variables agegroup = age_group.
*SORT CASES BY Year(A) LA_Code(A) Age_Group(A).

*** Create a Lookup to match on Populations within Tableau.
*String PopLKP (A50).
*compute PopLKP = CONCAT(Year, LA_Code, Age_Group).
*EXECUTE.

* Remove FinYear Totals from file - TEST to see if required in Tableau.
*select if Quarter NE 'FinYear'.
*exe.
********************

* Tidy up file.
recode SpecBeddays DailyCostOriginal TotalCostOriginal (sysmis = 0).
EXECUTE.

* Re-Calculate Daily Cost.
Compute DailyCostOriginal = TotalCostOriginal/SpecBeddays.
exe.


* Add Blank row for Tableau.
add files file =*
/file ='/conf/irf/09-Tableau-Outputs/01-Development/02-SPSS-Outputs/04-Delayed-Discharge/Blank_row.xlsx'.
exe.

*Add on populations

alter type agegroup (A6). 

sort cases by LA_CODE year agegroup.

match files file = *
 /table = '/conf/irf/09-Tableau-Outputs/01-Development/02-SPSS-Outputs/04-Delayed-Discharge/populations.sav' 
 /by LA_CODE year agegroup.
execute. 


SAVE OUTFILE='/conf/irf/09-Tableau-Outputs/01-Development/02-SPSS-Outputs/04-Delayed-Discharge/DD_LA_Master_Scot.sav'. 

get file = '/conf/irf/09-Tableau-Outputs/01-Development/02-SPSS-Outputs/04-Delayed-Discharge/DD_LA_Master_Scot.sav'. 

*Turn Scotland data into columms. 

select if LA_Name = 'Scotland'.
execute.  

rename variables SpecBeddays=Scot_Beddays.
rename variables DailyCostOriginal=Scot_DailyCost.
rename variables TotalCostOriginal=Scot_TotalCost.  
execute. 

sort cases by Year specname Quarter AgeGroup code_type Data.

save outfile = '/conf/irf/09-Tableau-Outputs/01-Development/02-SPSS-Outputs/04-Delayed-Discharge/temp1.sav'
 /keep Year specname Quarter AgeGroup code_type Data Scot_Beddays Scot_DailyCost Scot_TotalCostOriginal scot_population.

get file = '/conf/irf/09-Tableau-Outputs/01-Development/02-SPSS-Outputs/04-Delayed-Discharge/DD_LA_Master_Scot.sav'. 

sort cases by Year specname Quarter AgeGroup code_type Data.

match files file = * 
 /table =  '/conf/irf/09-Tableau-Outputs/01-Development/02-SPSS-Outputs/04-Delayed-Discharge/temp1.sav'
 /by Year specname Quarter AgeGroup code_type Data.
execute. 

select if LA_Name ne 'Scotland'.
execute.

SAVE OUTFILE='/conf/irf/09-Tableau-Outputs/01-Development/02-SPSS-Outputs/04-Delayed-Discharge/DD_LA_Master.sav'. 

*LD added in to ensure variables names in dashboard calculations are the same to make refreshing easier.

get file = '/conf/irf/09-Tableau-Outputs/01-Development/02-SPSS-Outputs/04-Delayed-Discharge/DD_LA_Master.sav'.

rename variables (LA_Code=LCAcode).
rename variables (LA_Name=LA).
rename variables (DailyCostOriginal=DailyCost).
rename variables (TotalCostOriginal=TotalCost).

execute.

SAVE OUTFILE='/conf/irf/09-Tableau-Outputs/01-Development/02-SPSS-Outputs/04-Delayed-Discharge/DD_LA_Master.sav'.

get file='/conf/irf/09-Tableau-Outputs/01-Development/02-SPSS-Outputs/04-Delayed-Discharge/DD_LA_Master.sav'.

if LA_CODE='01' LA_CODE='S12000033'.
if LA_CODE='02' LA_CODE='S12000034'.
if LA_CODE='03' LA_CODE='S12000041'.
if LA_CODE='04' LA_CODE='S12000035'.
if LA_CODE='05' LA_CODE='S12000026'.
if LA_CODE='06' LA_CODE='S12000005'.
if LA_CODE='07' LA_CODE='S12000039'.
if LA_CODE='08' LA_CODE='S12000006'.
if LA_CODE='09' LA_CODE='S12000042'.
execute. 

frequencies LA_CODE.

save outfile='/conf/sourcedev/federc01/SOURCE_UpDates/DD_UpDate/DD_LA_Master.sav'.



****************************************************************************************************************************************************

*Now produce data for Scotland workbook.

get file = '/conf/irf/09-Tableau-Outputs/01-Development/02-SPSS-Outputs/04-Delayed-Discharge/DD_LA_Master_Scot.sav'. 

FREQUENCIES LA_CODE.


select if LA_Name = 'Scotland'.
execute.  

*LD added in to ensure variables names in dashboard calculations are the same to make refreshing easier.
rename variables (LA_Code=LCAcode).
rename variables (LA_Name=LA).
execute.

SAVE OUTFILE='/conf/irf/09-Tableau-Outputs/01-Development/02-SPSS-Outputs/04-Delayed-Discharge/DD_LA_Master_Scot.sav'. 

get file ='/conf/irf/09-Tableau-Outputs/01-Development/02-SPSS-Outputs/04-Delayed-Discharge/DD_LA_Master_Scot.sav'. 
