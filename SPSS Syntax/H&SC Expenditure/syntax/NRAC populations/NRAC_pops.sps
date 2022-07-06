* Encoding: UTF-8.
* NRAC population files for 2014/15 - 2017/18.

*0-64 and 65+ age group.
PRESERVE.
SET DECIMAL DOT.

GET DATA  /TYPE=TXT
  /FILE=
    "/conf/irf/09-Tableau-Outputs/01-Development/02-SPSS-Outputs/01-HSC-Expenditure/Final_data/2018-1"+
    "9/NRAC Populations/NRAC Pops - H&SC Exp Workbook 1516 - 1819.csv"
  /ENCODING='UTF8'
  /DELIMITERS=","
  /QUALIFIER='"'
  /ARRANGEMENT=DELIMITED
  /FIRSTCASE=2
  /DATATYPEMIN PERCENTAGE=95.0
  /VARIABLES=
  Year AUTO
  CouncilAreaName AUTO
  CouncilAreaCode9 AUTO
  PopulationName AUTO
  Population AUTO
  NHSBoardName AUTO
  NHSBoardCode9 AUTO
  AgeBandSubmitted AUTO
  /MAP.
RESTORE.
CACHE.
EXECUTE.

string agegroup (a6).
if any(agebandsubmitted, '0-1', '2-4', '5-9', '10-14', '15-17', '18-19', '20-24', '25-29', '30-34', '35-39', '40-44', '45-49', '50-54', '55-59', '60-64') agegroup eq '0-64'.
if agebandsubmitted ge '65-69' agegroup eq '65+'.
execute.

aggregate outfile = *
/break year councilareaname AgeGroup PopulationName
/population = sum(population).

save outfile = '/conf/irf/09-Tableau-Outputs/01-Development/02-SPSS-Outputs/01-HSC-Expenditure/Final_data/2018-19/NRAC Populations/NRAC_pops65.sav'.

*75+ age group.
PRESERVE.
SET DECIMAL DOT.

GET DATA  /TYPE=TXT
  /FILE=
    "/conf/irf/09-Tableau-Outputs/01-Development/02-SPSS-Outputs/01-HSC-Expenditure/Final_data/2018-1"+
    "9/NRAC Populations/NRAC Pops - H&SC Exp Workbook 1516 - 1819.csv"
  /ENCODING='UTF8'
  /DELIMITERS=","
  /QUALIFIER='"'
  /ARRANGEMENT=DELIMITED
  /FIRSTCASE=2
  /DATATYPEMIN PERCENTAGE=95.0
  /VARIABLES=
  Year AUTO
  CouncilAreaName AUTO
  CouncilAreaCode9 AUTO
  PopulationName AUTO
  Population AUTO
  NHSBoardName AUTO
  NHSBoardCode9 AUTO
  AgeBandSubmitted AUTO
  /MAP.
RESTORE.
CACHE.
EXECUTE.

string agegroup (a6).
if agebandsubmitted ge '75-79' agegroup eq '75+'.
select if agegroup eq '75+'.
execute.

aggregate outfile = *
/break year councilareaname AgeGroup PopulationName
/population = sum(population).

save outfile = '/conf/irf/09-Tableau-Outputs/01-Development/02-SPSS-Outputs/01-HSC-Expenditure/Final_data/2018-19/NRAC Populations/NRAC_pops75.sav'.

*All age groups.
PRESERVE.
SET DECIMAL DOT.

GET DATA  /TYPE=TXT
  /FILE=
    "/conf/irf/09-Tableau-Outputs/01-Development/02-SPSS-Outputs/01-HSC-Expenditure/Final_data/2018-1"+
    "9/NRAC Populations/NRAC Pops - H&SC Exp Workbook 1516 - 1819.csv"
  /ENCODING='UTF8'
  /DELIMITERS=","
  /QUALIFIER='"'
  /ARRANGEMENT=DELIMITED
  /FIRSTCASE=2
  /DATATYPEMIN PERCENTAGE=95.0
  /VARIABLES=
  Year AUTO
  CouncilAreaName AUTO
  CouncilAreaCode9 AUTO
  PopulationName AUTO
  Population AUTO
  NHSBoardName AUTO
  NHSBoardCode9 AUTO
  AgeBandSubmitted AUTO
  /MAP.
RESTORE.
CACHE.
EXECUTE.

string agegroup (a6).
compute agegroup = 'All'.

aggregate outfile = *
/break year councilareaname AgeGroup PopulationName
/population = sum(population).

save outfile = '/conf/irf/09-Tableau-Outputs/01-Development/02-SPSS-Outputs/01-HSC-Expenditure/Final_data/2018-19/NRAC Populations/NRAC_popsAll.sav'.

add files file = '/conf/irf/09-Tableau-Outputs/01-Development/02-SPSS-Outputs/01-HSC-Expenditure/Final_data/2018-19/NRAC Populations/NRAC_pops65.sav'
/file = '/conf/irf/09-Tableau-Outputs/01-Development/02-SPSS-Outputs/01-HSC-Expenditure/Final_data/2018-19/NRAC Populations/NRAC_pops75.sav'
/file = '/conf/irf/09-Tableau-Outputs/01-Development/02-SPSS-Outputs/01-HSC-Expenditure/Final_data/2018-19/NRAC Populations/NRAC_popsAll.sav'.
execute.

string CareProgram (a15).
if populationname eq 'NRAC Acute Datazone Population' careprogram eq 'acute'.
if populationname eq 'NRAC COTE Datazone Population' careprogram eq 'COTE'.
if populationname eq 'NRAC Datazone Population' careprogram eq 'nrac'.
if populationname eq 'NRAC HCHS Datazone Population' careprogram eq 'hchs'.
if populationname eq 'NRAC Maternity Datazone Population' careprogram eq 'maternity'.
if populationname eq 'NRAC MHLD Datazone Population' careprogram eq 'mhld'.
if populationname eq 'NRAC Prescribing Datazone Population' careprogram eq 'gppresc'.
if populationname eq 'NRAC Community Datazone Population' careprogram eq 'Community'.
exe.

rename variables councilareaname=lcaname.
alter type lcaname (a141).

save outfile = '/conf/irf/09-Tableau-Outputs/01-Development/02-SPSS-Outputs/01-HSC-Expenditure/Final_data/2018-19/NRAC Populations/NRAC_pops.sav'
/keep year lcaname careprogram agegroup population.

get file = '/conf/irf/09-Tableau-Outputs/01-Development/02-SPSS-Outputs/01-HSC-Expenditure/Final_data/2018-19/NRAC Populations/NRAC_pops.sav'.

select if lcaname ne ''.
execute.

if any(lcaname, 'Aberdeen City', 'Aberdeenshire', 'Moray') lcaname eq 'Grampian Region'.
if any(lcaname, 'Angus', 'Dundee City', 'Perth and Kinross') lcaname eq 'Tayside Region'.
if any(lcaname, 'Argyll and Bute', 'Highland') lcaname eq 'Highland Region'.
if any(lcaname, 'City of Edinburgh', 'East Lothian', 'Midlothian', 'West Lothian') lcaname eq 'Lothian Region'.
if any(lcaname, 'Clackmannanshire', 'Falkirk', 'Stirling') lcaname eq 'Forth Valley Region'.
if any(lcaname, 'Na h-Eileanan Siar') lcaname eq 'Western Isles Region'.
if any(lcaname, 'Dumfries and Galloway') lcaname eq 'Dumfries & Galloway Region'.
if any(lcaname, 'East Ayrshire', 'North Ayrshire', 'South Ayrshire') lcaname eq 'Ayrshire & Arran Region'.
if any(lcaname, 'East Dunbartonshire', 'East Renfrewshire', 'Glasgow City', 'Inverclyde', 'Renfrewshire', 'West Dunbartonshire') lcaname eq 'Glasgow & Clyde Region'.
if any(lcaname, 'Fife') lcaname eq 'Fife Region'.
if any(lcaname, 'North Lanarkshire', 'South Lanarkshire') lcaname eq 'Lanarkshire Region'.
if any(lcaname, 'Orkney Islands') lcaname eq 'Orkney Region'.
if any(lcaname, 'Scottish Borders') lcaname eq 'Borders Region'.
if any(lcaname, 'Shetland Islands') lcaname eq 'Shetland Region'.
frequencies variables = lcaname.

aggregate outfile = *
/break year LCAname AgeGroup careprogram
/population = sum(population).

save outfile = '/conf/irf/09-Tableau-Outputs/01-Development/02-SPSS-Outputs/01-HSC-Expenditure/Final_data/2018-19/NRAC Populations/NRAC_popsRegion.sav'.

get file =  '/conf/irf/09-Tableau-Outputs/01-Development/02-SPSS-Outputs/01-HSC-Expenditure/Final_data/2018-19/NRAC Populations/NRAC_pops.sav'.

select if lcaname ne ''.
execute.

compute lcaname eq 'Scotland'.
aggregate outfile = *
/break year LCAname AgeGroup careprogram
/population = sum(population).

save outfile = '/conf/irf/09-Tableau-Outputs/01-Development/02-SPSS-Outputs/01-HSC-Expenditure/Final_data/2018-19/NRAC Populations/NRAC_popsScot.sav'.

add files file = '/conf/irf/09-Tableau-Outputs/01-Development/02-SPSS-Outputs/01-HSC-Expenditure/Final_data/2018-19/NRAC Populations/NRAC_pops.sav'
/file = '/conf/irf/09-Tableau-Outputs/01-Development/02-SPSS-Outputs/01-HSC-Expenditure/Final_data/2018-19/NRAC Populations/NRAC_popsRegion.sav'
/file = '/conf/irf/09-Tableau-Outputs/01-Development/02-SPSS-Outputs/01-HSC-Expenditure/Final_data/2018-19/NRAC Populations/NRAC_popsScot.sav'.
execute.

aggregate outfile = *
/break year LCAname AgeGroup careprogram
/population = sum(population).

if lcaname eq 'Orkney Islands' lcaname eq 'Orkney'.
if lcaname eq 'Shetland Islands' lcaname eq 'Shetland'.
if lcaname eq 'Comhairle nan Eilean Siar' lcaname eq 'Western Isles'.
if lcaname eq 'Na h-Eileanan Siar' lcaname eq 'Western Isles'.
execute.

rename variables year=year2.

string year (a7).
if year2 eq 2015 year eq '2015/16'.
if year2 eq 2016 year eq '2016/17'.
if year2 eq 2017 year eq '2017/18'.
if year2 eq 2018 year eq '2018/19'.
execute.

alter type agegroup (a15).
rename variables lcaname = chpname.
*rename variables population = NRAC.
sort cases by year chpname agegroup.
execute.

select if chpname ne ''.
execute.

String LA_TAB_Code (a7).
if CHPNAME = 'Scottish Borders' LA_TAB_Code =	'LAVC11'.
if CHPNAME = 'Fife' LA_TAB_Code =	'LAVC2'.
if CHPNAME = 'Orkney' LA_TAB_Code =	'LAVC26'.
if CHPNAME = 'Western Isles' LA_TAB_Code =	'LAVC8'.
if CHPNAME = 'Dumfries and Galloway' LA_TAB_Code =	'LAVC20'.
if CHPNAME = 'Shetland' LA_TAB_Code =	'LAVC9'.
if CHPNAME = 'North Ayrshire' LA_TAB_Code =	'LAVC10'.
if CHPNAME = 'South Ayrshire' LA_TAB_Code =	'LAVC21'.
if CHPNAME = 'East Ayrshire' LA_TAB_Code =	'LAVC1'.
if CHPNAME = 'East Dunbartonshire' LA_TAB_Code =	'LAVC22'.
if CHPNAME = 'Glasgow City' LA_TAB_Code =	'LAVC23'.
if CHPNAME = 'East Renfrewshire' LA_TAB_Code =	'LAVC12'.
if CHPNAME = 'West Dunbartonshire' LA_TAB_Code =	'LAVC13'.
if CHPNAME = 'Renfrewshire' LA_TAB_Code =	'LAVC31'.
if CHPNAME = 'Inverclyde' LA_TAB_Code =	'LAVC3'.
if CHPNAME = 'Highland' LA_TAB_Code =	'LAVC4'.
if CHPNAME = 'Argyll and Bute' LA_TAB_Code =	'LAVC24'.
if CHPNAME = 'North Lanarkshire' LA_TAB_Code =	'LAVC32'.
if CHPNAME = 'South Lanarkshire' LA_TAB_Code =	'LAVC14'.
if CHPNAME = 'Aberdeen City' LA_TAB_Code =	'LAVC25'.
if CHPNAME = 'Aberdeenshire' LA_TAB_Code =	'LAVC15'.
if CHPNAME = 'Moray' LA_TAB_Code =	'LAVC5'.
if CHPNAME = 'East Lothian' LA_TAB_Code =	'LAVC27'.
if CHPNAME = 'West Lothian' LA_TAB_Code =	'LAVC17'.
if CHPNAME = 'Midlothian' LA_TAB_Code =	'LAVC6'.
if CHPNAME = 'City of Edinburgh' LA_TAB_Code =	'LAVC16'.
if CHPNAME = 'Perth and Kinross' LA_TAB_Code =	'LAVC7'.
if CHPNAME = 'Dundee City' LA_TAB_Code =	'LAVC28'.
if CHPNAME = 'Angus' LA_TAB_Code =	'LAVC30'.
if CHPNAME = 'Clackmannanshire' LA_TAB_Code =	'LAVC18'.
if CHPNAME = 'Falkirk' LA_TAB_Code =	'LAVC29'.
if CHPNAME = 'Stirling' LA_TAB_Code =	'LAVC19'.
EXECUTE.

String HB_TAB_Code (a6).
if any(chpname,  'North Ayrshire', 'East Ayrshire', 'South Ayrshire', 'Ayrshire & Arran Region') HB_TAB_Code =	'HBVC9'.
if any(chpname, 'Scottish Borders', 'Borders Region')	HB_TAB_Code =	'HBVC5'.
if any(chpname, 'Dumfries and Galloway', 'Dumfries & Galloway Region')	HB_TAB_Code =	'HBVC11'.
if any(chpname, 'Fife', 'Fife Region') HB_TAB_Code =	'HBVC12'.
if any(chpname, 'Clackmannanshire', 'Falkirk', 'Stirling', 'Forth Valley Region') HB_TAB_Code =	'HBVC7'.
if any(chpname, 'Aberdeen City', 'Aberdeenshire', 'Moray', 'Grampian Region') HB_TAB_Code =	'HBVC14'.
if any(chpname, 'East Dunbartonshire', 'Glasgow City', 'East Renfrewshire', 'West Dunbartonshire', 'Renfrewshire', 'Inverclyde', 'Glasgow & Clyde Region')	HB_TAB_Code =	'HBVC8'.
if any(chpname, 'Highland', 'Argyll and Bute', 'Highland Region') HB_TAB_Code =	'HBVC13'.
if any(chpname, 'North Lanarkshire', 'South Lanarkshire', 'Lanarkshire Region') HB_TAB_Code =	'HBVC1'.
if any(chpname, 'East Lothian', 'West Lothian', 'Midlothian', 'City of Edinburgh', 'Lothian Region')	HB_TAB_Code =	'HBVC3'.
if any(chpname, 'Orkney', 'Orkney Region') HB_TAB_Code =	'HBVC6'.
if any(chpname, 'Shetland', 'Shetland Region')	HB_TAB_Code =	'HBVC4'.
if any(chpname, 'Perth and Kinross', 'Dundee City', 'Angus', 'Tayside Region')	HB_TAB_Code =	'HBVC10'.
if any(chpname, 'Western Isles', 'Western Isles Region')	HB_TAB_Code =	'HBVC2'.
execute.

save outfile = '/conf/irf/09-Tableau-Outputs/01-Development/02-SPSS-Outputs/01-HSC-Expenditure/Final_data/2018-19/NRAC Populations/NRAC_pops.sav'.

*Combine Stirling & Clacks populations. 
select if chpname = 'Stirling' or chpname = 'Clackmannanshire'.
execute. 

compute chpname = 'Clackmannashire & Stirling'.
compute  LA_TAB_Code = 'LAVC99'.
execute. 

aggregate outfile = *
/break year chpname AgeGroup careprogram LA_TAB_Code HB_TAB_Code
/population = sum(population).
execute. 

add files file = *
 /file = '/conf/irf/09-Tableau-Outputs/01-Development/02-SPSS-Outputs/01-HSC-Expenditure/Final_data/2018-19/NRAC Populations/NRAC_pops.sav'. 
execute.

select if chpname ne 'Stirling' and chpname ne 'Clackmannanshire'.
execute. 

string PopLookup (a40).
compute PopLookup = concat(year, HB_TAB_Code, LA_TAB_Code, CareProgram, AgeGroup).
sort cases by PopLookup.
execute.

save outfile = '/conf/irf/09-Tableau-Outputs/01-Development/02-SPSS-Outputs/01-HSC-Expenditure/Final_data/2018-19/NRAC Populations/NRAC_pops.sav'
/keep PopLookup Population.

get file = '/conf/irf/09-Tableau-Outputs/01-Development/02-SPSS-Outputs/01-HSC-Expenditure/Final_data/2018-19/NRAC Populations/NRAC_pops.sav'.
