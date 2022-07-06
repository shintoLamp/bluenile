* Encoding: UTF-8.
****************************************************************************************
*** Location of Death Dashboard Update Syntax Part 1 - File Preparation ***
****************************************************************************************
** Jenny Armstrong - 03/10/2018
* adapted from syntax at: \\Stats\irf\18-End-of-Life\Data Development\PEOLC 2.1 Location of death analysis

* This syntax prepares data required to create the tableau data extract for the Location of death dashboard 
* which was developed for the 2017/18 PEOLC work plan

* Syntax produces data for 2014/15 to 2017/18. 

*** Analysis contains details of the following for 2014/15 onwards (by financial year)
* total deaths in Scotland and H&SC partnerships 
* broken down by location e.g. hospital, home, care home or hospice/palliative care unit
* LTC, Cause of Death group, SIMD, Age, Gender and Urban/Rural classification

********************************************************************************************************************************************
** DEFINE FILE PATHS 

* File names are set up so only the following dates needs to be updated and file names will automatically be updated when syntax is run

*** update the following with the date the syntax is being run
*** Date Format: YYYY_MM_DD

Define !DateSyntaxRun()
'2018_12_05'
!Enddefine. 

*** Update with the date at which data is extracted
*** Date Format: YYYY_MM_DD

Define !DateExtracted()
'_extracted_2018_12_05'
!Enddefine. 

*** Update with the financial year of interest

Define !FinYearUpdate()
'201415_to_201718'
!Enddefine. 

* how to use in file paths - example
*get file = '/conf/hscdiip/01-Source-linkage-files/source-episode-file-' + !year +'.sav'. 
*Execute. 

* Analysis file locations

**** Data Extracts ****
*\\Stats\irf\18-End-of-Life\Data Extracts

*** All Activity file will be saved to the End of Life / Data Extracts folder so it can be used for other pieces of analysis if necessary
DEFINE  !pathExtracts()
'/conf/irf/18-End-of-Life/Data Extracts/'
!enddefine.

***** NOTE: if irf is full the file path above can be changed to the sourcedev PEoLC file as a temporary measure ('/conf/sourcedev/TableauUpdates/PEoLC/')
* JA 08/10/2018 syntax run - files saved in sourcedev

DEFINE  !pathExtracts()
'/conf/sourcedev/TableauUpdates/PEoLC/Data Extracts/'
!enddefine.

DEFINE !pathLTC()
'/conf/sourcedev/TableauUpdates/PEoLC/LTC update/output/'
!enddefine.



*ORIGINAL ANALYSIS FILE PATH - FOR INFO
DEFINE  !pathA()
'/conf/irf/18-End-of-Life/Data Development/PEOLC 2.1 Location of death analysis/Data Extracts/'
!enddefine.

* Hospital type lookup file location 
*** Check what HospTypesComm.sav file is available - syntax should be updated if a new lookup is available
*** details of this should be added to the syntax and dashboard notes

** 08/10/2018 - A new lookup file was made available in September 18 - some updates have been made since initial release of dashboard to community hospital classifications
* previous file HospTypesComm.sav
* new lookup file HospTypesComm_Sep18.sav - this has been changed throughout the syntax

DEFINE  !pathB()
'/conf/irf/03-Integration-Indicators/02-MSG/01-Data/05-EoL/Community Hospital lookups/'
!enddefine.

**********************************************************************************************************************************

*** SMRA DATA EXTRACTS 

* Create an "All_SMR_Activity.sav" file including SMR50, SMR01, SMR04 and NRS death records with the most up to date financial year of data

* Users must ensure that they have their own encrypted password in a file on the their home UNIX area.


INSERT FILE = '/home/federc01/pass.sps'.

*** update the discharge date selection  for each SMR extract
*** Date format: YYYY-MM-DD

*Extract Geriatric Long Stay (GLS) SMR50 data from SMRA views

GET DATA
  /TYPE=ODBC
  /CONNECT=!connect
  /SQL='SELECT  "LINK_NO", "SEX", "AGE_IN_YEARS", "COUNCIL_AREA", "ADMISSION_DATE", "DISCHARGE_DATE", '+
    '"MAIN_CONDITION", "LENGTH_OF_STAY", "LOCATION", "SIGNIFICANT_FACILITY",  '+
    '"INPATIENT_DAYCASE_IDENTIFIER", "GLS_CIS_MARKER", "ADMISSION", '+
    '"DISCHARGE","URI" FROM "ANALYSIS"."SMR01_1E_PI" WHERE '+
    '("DISCHARGE_DATE" >= ''2012-10-01'' AND "DISCHARGE_DATE" < ''2018-04-01'')' +
     'ORDER BY "LINK_NO" ASC, "ADMISSION_DATE" ASC, "DISCHARGE_DATE" ASC,' + 
     '"ADMISSION" 'ASC, "DISCHARGE" ASC, "URI" ASC
  /ASSUMEDSTRWIDTH=255.

CACHE.
EXECUTE.
DATASET NAME DataSet1 WINDOW=FRONT.

* Create a variable to identify the record type, i.e.SMR50 record

String recid (A5).
compute recid = '50B'.
execute.

save outfile =  !pathExtracts + 'SMR50_' + !FinYearUpdate + !DateExtracted + '.zsav'
 /zcompressed.

*** Extract Acute SMR01 data from SMRA views

GET DATA
  /TYPE=ODBC
  /CONNECT=!connect
  /SQL='SELECT  "LINK_NO", "SEX", "AGE_IN_YEARS", "COUNCIL_AREA", "ADMISSION_DATE", "DISCHARGE_DATE", '+
    '"MAIN_CONDITION", "LENGTH_OF_STAY", "LOCATION", "SIGNIFICANT_FACILITY", "HB_OF_RESIDENCE_NUMBER", '+
    '"INPATIENT_DAYCASE_IDENTIFIER", "GLS_CIS_MARKER", "ADMISSION", '+
    '"DISCHARGE","URI" FROM "ANALYSIS"."SMR01_PI" WHERE '+
    '("DISCHARGE_DATE" >= ''2012-10-01'' AND "DISCHARGE_DATE" < ''2018-04-01'')' +
     'ORDER BY "LINK_NO" ASC, "ADMISSION_DATE" ASC, "DISCHARGE_DATE" ASC,' + 
     '"ADMISSION" 'ASC, "DISCHARGE" ASC, "URI" ASC
  /ASSUMEDSTRWIDTH=255.

CACHE.
EXECUTE.
DATASET NAME DataSet2 WINDOW=FRONT.

* Create a variable to identify the record type, i.e.SMR01 record

String recid (A5).
compute recid = '01B'.
execute.

save outfile =  !pathExtracts + 'SMR01_' + !FinYearUpdate + !DateExtracted + '.zsav'
/zcompressed.

DATASET CLOSE ALL.

* create a file with all SMR01 and SMR50 records

add files file = !pathExtracts + 'SMR01_' + !FinYearUpdate + !DateExtracted + '.zsav'
 /file =   !pathExtracts + 'SMR50_' + !FinYearUpdate + !DateExtracted + '.zsav'.
execute. 

* Select inpatients.only

select if INPATIENT_DAYCASE_IDENTIFIER = 'I'.
execute.

**** REMOVE DUPLICATE RECORDS ****.

sort cases by LINK_NO ADMISSION_DATE DISCHARGE_DATE ADMISSION DISCHARGE URI.

* create a flag variable which will identify potential duplicate records

compute duplicate_flag=0.
if (ADMISSION_DATE=lag(ADMISSION_DATE) and DISCHARGE_DATE = lag(DISCHARGE_DATE) and LINK_NO=lag(LINK_NO)) duplicate_flag=1.
execute.

* check how many duplicate records there are in the file

frequencies duplicate_flag.

* There are some records which are the same inpatient stay. (1.6%)
* For this analysis we just want to know the number of deaths and beddays and this is calculated using the record dates so even though the second record is different and contains 
 different diagnosis info, we can delete it since the only info we need is the doa / dod information.

* remove duplicate records

select if duplicate_flag ne 1.
execute. 

*Create a flag variable for cases where date of admission = date of discharge - these could be transfers and will have LOS=0 so we won't be interested in these.

****** CHECK IF THESE SHOULD BE REMOVED FOR LOCATION OF DEATH DASHBOARD ANALYSIS - not removed for last 6 months analysis

compute length_of_stay_equal_to_zero=0.
if ADMISSION_DATE=DISCHARGE_DATE length_of_stay_equal_to_zero=1.

* check how many records this affects

frequencies length_of_stay_equal_to_zero.

*22.9% of cases have adm date = discharge date

* Investigate any records which may have the same date of admission (doa) but different date of discharge (dod), 
*(excluding those where one record doa=dod as this will have LOS=0).

sort cases by ADMISSION_DATE (A) LINK_NO (A) DISCHARGE_DATE (D).

compute duplicate_date_of_adm=0.
if (ADMISSION_DATE=lag(ADMISSION_DATE) and LINK_NO=lag(LINK_NO) and length_of_stay_equal_to_zero=0) duplicate_date_of_adm=1.

frequencies duplicate_date_of_adm.
*1046 duplicate dates of admission (0.0% of records)

*Remove the earliest discharge.
select if duplicate_date_of_adm NE 1.
execute.

*Investigate any records with same dod but different doa, (excluding those where one record doa=dod as this will have LOS=0).
sort cases by DISCHARGE_DATE (A) LINK_NO (A) ADMISSION_DATE (A).

compute duplicate_date_of_discharge=0.
if (DISCHARGE_DATE=lag(DISCHARGE_DATE) and LINK_NO=lag(LINK_NO) and length_of_stay_equal_to_zero=0) duplicate_date_of_discharge=1.

frequencies duplicate_date_of_discharge.
* 194 duplicate dates of discharge

*Remove the latest discharge

select if duplicate_date_of_discharge NE 1.
execute.

sort cases by LINK_NO.

*Save out combined Acute (SMR01) and GLS (SMR50) activity file
*that has had duplicates removed

save outfile = !pathExtracts + 'SMR01_50_' + !FinYearUpdate + !DateExtracted + '.zsav'
  /zcompressed.

** Erase individual SMR01 and SMR50 files - check combined file has saved successfully first

erase file =   !pathExtracts + 'SMR01_' + !FinYearUpdate + !DateExtracted + '.zsav'.
erase file = !pathExtracts + 'SMR50_' + !FinYearUpdate + !DateExtracted + '.zsav'.

** Extract SMR04 (mental health) data from SMRA views

GET DATA
  /TYPE=ODBC
  /CONNECT=!connect
  /SQL='SELECT "LINK_NO", "SEX", "ADMISSION_DATE", "DISCHARGE_DATE", "SPECIALTY", '+
    '"COUNCIL_AREA", "MAIN_CONDITION", "OTHER_CONDITION_1", "OTHER_CONDITION_2", '+
    '"OTHER_CONDITION_3", "OTHER_CONDITION_4", "OTHER_CONDITION_5", "DISCHARGE_TYPE", '+
    '"ADMISSION_TRANSFER_FROM", "ADMISSION_TRANSFER_FROM_LOC", "ADMISSION", '+
    '"DISCHARGE", "LOCATION", "SIGNIFICANT_FACILITY", "URI", '+
    '"MANAGEMENT_OF_PATIENT", "DATE_LAST_AMENDED" FROM "ANALYSIS"."SMR04_PI"' +
     'ORDER BY "LINK_NO" ASC, "ADMISSION_DATE" ASC, "DISCHARGE_DATE" ASC,' + 
     '"ADMISSION" 'ASC, "DISCHARGE" ASC, "URI" ASC
  /ASSUMEDSTRWIDTH=255.

String recid (A5).
compute recid = '04B'.
execute.

*Select inpatients.

select if MANAGEMENT_OF_PATIENT='1' OR MANAGEMENT_OF_PATIENT='3' OR MANAGEMENT_OF_PATIENT='5' OR MANAGEMENT_OF_PATIENT='7' OR MANAGEMENT_OF_PATIENT='A'.
Execute.

* The following date seclections should be updated

* Select activity between last financial year and end of most recent financial year
* Include cases with no discharge date - we will assume discharge date = date of death. 

if (DISCHARGE_DATE ge date.dmy(01,10,2012) and DISCHARGE_DATE le date.dmy(31,03,2018)) discharge_date_include_flag=1.
if missing(DISCHARGE_DATE)=1 discharge_date_include_flag =2.
frequencies discharge_date_include_flag.

select if discharge_date_include_flag=1 or discharge_date_include_flag=2.
execute.

**** Remove duplicate records ****

* Identify potential duplicates. 
sort cases by ADMISSION_DATE DISCHARGE_DATE LINK_NO.

compute duplicate_flag=0.
if (ADMISSION_DATE=lag(ADMISSION_DATE) and DISCHARGE_DATE = lag(DISCHARGE_DATE) and LINK_NO=lag(LINK_NO)) duplicate_flag=1.
execute.

frequencies duplicate_flag.

* There are 68 records which are the same inpatient stay.
* For this analysis we just want to know the number of beddays and this is calculated using the record dates so even though the second record is different and contains 
* different diagnosis info, we can delete it since the only info we need is the doa / dod information.

select if duplicate_flag ne 1.
execute. 

* Not worried about cases where doa=dod - these could be transfers and will have LOS=0 anyway. 
compute length_of_stay_equal_to_zero=0.
if ADMISSION_DATE=DISCHARGE_DATE length_of_stay_equal_to_zero=1.
frequencies length_of_stay_equal_to_zero.

* Investigate any records which may have the same doa but different dod, (excluding those where one record doa=dod as this will have LOS=0).

sort cases by ADMISSION_DATE (A)  LINK_NO (A) DISCHARGE_DATE (D).

compute duplicate_doa=0.
if (ADMISSION_DATE=lag(ADMISSION_DATE) and  LINK_NO = lag(LINK_NO) and length_of_stay_equal_to_zero=0) duplicate_doa=1.
frequencies duplicate_doa.

*Remove the earliest discharge

select if duplicate_doa NE 1.
execute.

* Investigate any records with same dod but different doa, (excluding those where one record doa=dod as this will have LOS=0).

sort cases by DISCHARGE_DATE (A)  LINK_NO (A) ADMISSION_DATE (A).

compute duplicate_dod=0.
if (DISCHARGE_DATE=lag(DISCHARGE_DATE) and  LINK_NO = lag(LINK_NO) and length_of_stay_equal_to_zero=0) duplicate_dod=1.

frequencies duplicate_dod.
* 18 records flagged

*Remove the latest admission

select if duplicate_dod NE 1.
execute.

sort cases by  LINK_NO.

*Save out SMR04 activity.
save outfile =  !pathExtracts + 'SMR04_' + !FinYearUpdate + !DateExtracted + '.zsav'
/zcompressed.

****** Extract NRS Deaths Records ********

** update with required date for extract

* Retrieve death data.
* select data for the most recent financial year & 
* sort cases by link number and date of death when extracting data from SMR view

* data is extracted from the start of financial year 2014/15 onwards

GET DATA
  /TYPE=ODBC
  /CONNECT=!connect
  /SQL='SELECT "DATE_OF_DEATH", "INSTITUTION", "PRIMARY_CAUSE_OF_DEATH", '+
    '"SECONDARY_CAUSE_OF_DEATH_0", "SECONDARY_CAUSE_OF_DEATH_1", "SECONDARY_CAUSE_OF_DEATH_2", '+
    '"SECONDARY_CAUSE_OF_DEATH_3", "SECONDARY_CAUSE_OF_DEATH_4", "SECONDARY_CAUSE_OF_DEATH_5", '+
    '"SECONDARY_CAUSE_OF_DEATH_6", "SECONDARY_CAUSE_OF_DEATH_7", "SECONDARY_CAUSE_OF_DEATH_8", '+
    '"SECONDARY_CAUSE_OF_DEATH_9", "AGE", "SEX", "DATE_OF_BIRTH", "POSTCODE", "COUNCIL_AREA", "CHI", '+
    '"LINK_NO" FROM "ANALYSIS"."GRO_DEATHS_C" WHERE ("DATE_OF_DEATH" >= ''2014-04-01'')' +
 'ORDER BY "LINK_NO" ASC, "DATE_OF_DEATH" ASC'
  /ASSUMEDSTRWIDTH=255.

* Checking number of deaths - check for any duplicates

* data was sorted by link number and date of death before it was extracted from SMR so the following line has been commented out of the syntax
* sort cases LINK_NO DATE_OF_DEATH.

compute duplicate_death_flag =0.
if LINK_NO eq lag(LINK_NO) duplicate_death_flag =1.
execute.

frequencies duplicate_death_flag.
* No duplicates

* If duplicates are present in the file, these should be removed

select if duplicate_death_flag NE 1.
execute.

*Identify all external causes - these will be removed from analysis.

string externalcause(a1).
if  range (char.substr(PRIMARY_CAUSE_OF_DEATH,1,3),'V01','Y84') 
  or range (char.substr(SECONDARY_CAUSE_OF_DEATH_0,1,3),'V01','Y84')
  or range (char.substr(SECONDARY_CAUSE_OF_DEATH_1,1,3),'V01','Y84')
  or range (char.substr(SECONDARY_CAUSE_OF_DEATH_2,1,3),'V01','Y84')
  or range (char.substr(SECONDARY_CAUSE_OF_DEATH_3,1,3),'V01','Y84')
  or range (char.substr(SECONDARY_CAUSE_OF_DEATH_4,1,3),'V01','Y84') 
  or range (char.substr(SECONDARY_CAUSE_OF_DEATH_5,1,3),'V01','Y84')
  or range (char.substr(SECONDARY_CAUSE_OF_DEATH_6,1,3),'V01','Y84')
  or range (char.substr(SECONDARY_CAUSE_OF_DEATH_7,1,3),'V01','Y84') 
  or range (char.substr(SECONDARY_CAUSE_OF_DEATH_8,1,3),'V01','Y84')
  or range (char.substr(SECONDARY_CAUSE_OF_DEATH_9,1,3),'V01','Y84') externalcause ='1'.
execute.

* Identify deaths from falls- we want to include falls.

if  range (char.substr(PRIMARY_CAUSE_OF_DEATH,1,3),'W00','W19') 
  or range (char.substr(SECONDARY_CAUSE_OF_DEATH_0,1,3),'W00','W19')
  or range (char.substr(SECONDARY_CAUSE_OF_DEATH_1,1,3),'W00','W19')
  or range (char.substr(SECONDARY_CAUSE_OF_DEATH_2,1,3),'W00','W19')
  or range (char.substr(SECONDARY_CAUSE_OF_DEATH_3,1,3),'W00','W19')
  or range (char.substr(SECONDARY_CAUSE_OF_DEATH_4,1,3),'W00','W19') 
  or range (char.substr(SECONDARY_CAUSE_OF_DEATH_5,1,3),'W00','W19')
  or range (char.substr(SECONDARY_CAUSE_OF_DEATH_6,1,3),'W00','W19')
  or range (char.substr(SECONDARY_CAUSE_OF_DEATH_7,1,3),'W00','W19') 
  or range (char.substr(SECONDARY_CAUSE_OF_DEATH_8,1,3),'W00','W19')
  or range (char.substr(SECONDARY_CAUSE_OF_DEATH_9,1,3),'W00','W19') externalcause =''.
execute.

*Remove deaths from external causes (except falls).

select if externalcause ne '1'.
execute.

*Add in location and urban/rural information.
*** these lookup files may need updating for annual updates 
** DEC 2018. FC updated lookup files to include most up to date Postcode information 

rename variables postcode=pc7.
sort cases by pc7.

Alter type pc7(A7).
execute. 

Match files file = *
/table='/conf/linkage/output/lookups/Unicode/Geography/Scottish Postcode Directory/Scottish_Postcode_Directory_2018_2.sav'
/by pc7
/keep DATE_OF_DEATH to externalcause HB2014 HSCP2016 CA2011 UR6_2016 UR8_2016.
EXECUTE.

*Add in SIMD information.

*** Note, check if lookup file needs updating
** DEC 2018. FC updated lookup files to include most up to date Deprivation information 


match files file=*
/table='/conf/linkage/output/lookups/Unicode/Deprivation/postcode_2018_2_simd2016.sav'
/by pc7
/drop simd2016rank simd2016_sc_decile simd2016_HB2014_decile to simd2016_crime_rank.
Execute.

*Add variable for financial year.- UPDATE WITH MOST RECENT FINANCIAL YEAR

string finyear_dth(a9).
if (DATE_OF_DEATH >= date.dmy(01,04,2013) and DATE_OF_DEATH <= date.dmy(31,03,2014)) finyear_dth ='2013/14'.
if (DATE_OF_DEATH >= date.dmy(01,04,2014) and DATE_OF_DEATH <= date.dmy(31,03,2015)) finyear_dth ='2014/15'.
if (DATE_OF_DEATH >= date.dmy(01,04,2015) and DATE_OF_DEATH <= date.dmy(31,03,2016)) finyear_dth ='2015/16'.
if (DATE_OF_DEATH >= date.dmy(01,04,2016) and DATE_OF_DEATH <= date.dmy(31,03,2017)) finyear_dth ='2016/17'.
if (DATE_OF_DEATH >= date.dmy(01,04,2017) and DATE_OF_DEATH <= date.dmy(31,03,2018)) finyear_dth ='2017/18'.
execute. 

*Remove deaths not required 

FREQUENCIES finyear_dth.

select if finyear_dth ne ''.
execute.

*Assign Health Board name.

STRING hbresname(a28).
IF (HB2014='S08000015') hbresname='NHS Ayrshire & Arran'.
IF (HB2014='S08000016') hbresname='NHS Borders'.
IF (HB2014='S08000017') hbresname='NHS Dumfries & Galloway'.
IF (HB2014='S08000018') hbresname='NHS Fife'.
IF (HB2014='S08000019') hbresname='NHS Forth Valley'.
IF (HB2014='S08000020') hbresname='NHS Grampian'.
IF (HB2014='S08000021') hbresname='NHS Greater Glasgow & Clyde'.
IF (HB2014='S08000022') hbresname='NHS Highland'.
IF (HB2014='S08000023') hbresname='NHS Lanarkshire'.
IF (HB2014='S08000024') hbresname='NHS Lothian'.
IF (HB2014='S08000025') hbresname='NHS Orkney'.
IF (HB2014='S08000026') hbresname='NHS Shetland'.
IF (HB2014='S08000027') hbresname='NHS Tayside'.
IF (HB2014='S08000028') hbresname='NHS Western Isles'.
IF (HB2014='S08200001') hbresname ='England/Wales/Northern Ireland'.
EXECUTE.

string councilarea(a100).
if CA2011='S12000033'	councilarea='Aberdeen City'.
if CA2011='S12000034'	councilarea='Aberdeenshire'.
if CA2011='S12000041'	councilarea='Angus'.
if CA2011='S12000035'	councilarea='Argyll & Bute'.
if CA2011='S12000036' councilarea='City of Edinburgh' .
if CA2011='S12000005' councilarea='Clackmannanshire'.
if CA2011='S12000006' councilarea='Dumfries & Galloway'.
if CA2011='S12000042' councilarea='Dundee City'.
if CA2011='S12000008' councilarea='East Ayrshire'.
if CA2011='S12000045' councilarea='East Dunbartonshire'.
if CA2011='S12000010' councilarea='East Lothian'.
if CA2011='S12000011' councilarea='East Renfrewshire'.
if CA2011='S12000014' councilarea='Falkirk'.
if CA2011='S12000015' councilarea='Fife'.
if CA2011='S12000046' councilarea='Glasgow City'.
if CA2011='S12000017' councilarea='Highland'.
if CA2011='S12000018' councilarea='Inverclyde'.
if CA2011='S12000019' councilarea='Midlothian'.
if CA2011='S12000020' councilarea='Moray'.
if CA2011='S12000021' councilarea='North Ayrshire'.
if CA2011='S12000044' councilarea='North Lanarkshire'.
if CA2011='S12000023' councilarea='Orkney Islands'.
if CA2011='S12000024' councilarea='Perth & Kinross'.
if CA2011='S12000038' councilarea='Renfrewshire'.
if CA2011='S12000026' councilarea='Scottish Borders'.
if CA2011='S12000027' councilarea='Shetland Islands'.
if CA2011='S12000028' councilarea='South Ayrshire'.
if CA2011='S12000029' councilarea='South Lanarkshire'.
if CA2011='S12000030' councilarea='Stirling'.
if CA2011='S12000039'	councilarea='West Dunbartonshire'.
if CA2011='S12000040' councilarea='West Lothian'.
if CA2011='S12000013' councilarea='Western Isles'.

*Label HSCPs in 2016 (N=31).

string hscp (a100).
if HSCP2016='S37000001' hscp='Aberdeen City'.
if HSCP2016='S37000002' hscp='Aberdeenshire'.
if HSCP2016='S37000003' hscp='Angus'.
if HSCP2016='S37000004' hscp='Argyll & Bute'.
if HSCP2016='S37000005' hscp='Clackmannanshire and Stirling'.
if HSCP2016='S37000006' hscp='Dumfries & Galloway'.
if HSCP2016='S37000007' hscp='Dundee City'.
if HSCP2016='S37000008' hscp='East Ayrshire'.
if HSCP2016='S37000009' hscp='East Dunbartonshire'.
if HSCP2016='S37000010' hscp='East Lothian'.
if HSCP2016='S37000011' hscp='East Renfrewshire'.
if HSCP2016='S37000012' hscp='Edinburgh' .
if HSCP2016='S37000013' hscp='Falkirk'.
if HSCP2016='S37000014' hscp='Fife'.
if HSCP2016='S37000015' hscp='Glasgow City'.
if HSCP2016='S37000016' hscp='Highland'.
if HSCP2016='S37000017' hscp='Inverclyde'.
if HSCP2016='S37000018' hscp='Midlothian'.
if HSCP2016='S37000019' hscp='Moray'.
if HSCP2016='S37000020' hscp='North Ayrshire'.
if HSCP2016='S37000021' hscp='North Lanarkshire'.
if HSCP2016='S37000022' hscp='Orkney Islands'.
if HSCP2016='S37000023' hscp='Perth & Kinross'.
if HSCP2016='S37000024' hscp='Renfrewshire'.
if HSCP2016='S37000025' hscp='Scottish Borders'.
if HSCP2016='S37000026' hscp='Shetland Islands'.
if HSCP2016='S37000027' hscp='South Ayrshire'.
if HSCP2016='S37000028' hscp='South Lanarkshire'.
if HSCP2016='S37000029' hscp='West Dunbartonshire'.
if HSCP2016='S37000030' hscp='West Lothian'.
if HSCP2016='S37000031' hscp='Western Isles'.
execute.

sort cases by LINK_NO.

***** CHECK VARIABLES

CTABLES
  /VLABELS VARIABLES=SEX finyear_dth DISPLAY=LABEL
  /TABLE SEX [COUNT F40.0] BY finyear_dth
  /CATEGORIES VARIABLES=SEX finyear_dth ORDER=A KEY=VALUE EMPTY=EXCLUDE.

*Save file.

save outfile= !pathExtracts + 'GRO-excluding-sudden-deaths_'  + !FinYearUpdate + !DateExtracted + '.zsav'
 /drop HB2018 HSCP2018 CA2018
 /zcompressed.

* match in hospital types
* lookup file should be sorted by location to do this

get file = !pathB + 'HospTypesComm_Sep18.sav'.
sort cases location.
save outfile = !pathB + 'HospTypesComm_Sep18.sav'. 

*********
* Create a file with all activity data. 

DATASET CLOSE ALL.
execute.

* start with the SMR activity files

add files /file = !pathExtracts + 'SMR01_50_' + !FinYearUpdate + !DateExtracted + '.zsav'
 /file = !pathExtracts + 'SMR04_' + !FinYearUpdate + !DateExtracted + '.zsav'.
execute. 

*Match in hospital type information.

rename variables LOCATION = location.
alter type location (A5).
sort cases by location.

match files file = *
              /table = !pathB + 'HospTypesComm_Sep18.sav'
              /by location.
execute.

*** CREATE LOCATION TYPE VARIABLE - 

*Flag up hospice activity and other palliative care acitvity. 

if any(location, 'C413V', 'C306V', 'A227V', 'G414V', 'L102K', 'S121K', 'C407V', 'V103V', 'S203K', 'G583V', 'W102V', 'G501K', 'H220V', 'H265V') or significant_facility='1G' type='Palliative'.
execute.

*If hospital isn't community or palliative, assume location is large hospital or a unit which is part of a main hospital.
frequencies type.

if type='' type='Large'.
execute.

* Match deaths on to SMR activity data.

sort cases by LINK_NO.

* match in deaths data

* note the "/in" subcommand creates a flag variable called "dead"
* this gives every case that came from input file (GRO deaths file) the value 1
* the value 0 is given to cases not in this file

match files file=*
 /table= !pathExtracts + 'GRO-excluding-sudden-deaths_' + !FinYearUpdate + !DateExtracted + '.zsav'
 /in=dead
 /by LINK_NO.
execute.

frequencies recid.
frequencies dead.

* Select only activity for deaths.

select if dead=1.
execute.

frequencies type.

* check number of deaths by year and location

CTABLES
  /VLABELS VARIABLES=finyear_dth type DISPLAY=LABEL
  /TABLE finyear_dth BY type [COUNT F40.0]
  /CATEGORIES VARIABLES= finyear_dth type ORDER=A KEY=VALUE EMPTY=EXCLUDE.

* check number of deaths by year (these will only be deaths where an individual had a hospital record/SMR activity)

CTABLES
  /VLABELS VARIABLES=finyear_dth dead DISPLAY=LABEL
  /TABLE finyear_dth BY dead [COUNT F40.0]
  /CATEGORIES VARIABLES= finyear_dth dead ORDER=A KEY=VALUE EMPTY=EXCLUDE.

********************************************************************************

* For the SMR04 records with a missing discharge date, set date of discharge to date of death.
do if recid ='04B' and missing(DISCHARGE_DATE)=1.
compute Test=1.
compute DISCHARGE_DATE=DATE_OF_DEATH.
end if.
execute.

* the following steps are used for QOM10 publication 
******* Identify 6 months prior to death and count bed days in between ******.
* Calculate date six months prior to death.
compute date_6month_prior_to_death=DATESUM(DATE_OF_DEATH,-183,"days").
formats date_6month_prior_to_death (date11).

*NOTE:  date 6 months prior to death was calculated and added to the file but the following steps commented out below  have not been carried out. 
* From this point onwards data will differ from the 'all activity.sav' file used for the end of life publication and MSG indicators work
* If six months prior to death falls in a hospital spell, calculate a new date of admission equal to 6 months prior to death.
*do if (ADMISSION_DATE<=date_6month_prior_to_death and DISCHARGE_DATE>=date_6month_prior_to_death).
*compute ADMISSION_DATE = date_6month_prior_to_death.
*end if.
*execute.
* Select episodes with date of admission that fall within 183 days prior to death.
*compute days_between_adm_and_death = DATEDIFF(DATE_OF_DEATH, ADMISSION_DATE, "days").
*compute six_month_flag = 0.
*if (days_between_adm_and_death<=183) six_month_flag = 1.
*select if six_month_flag=1.
*execute.
***************************************************************************************************************

* RB CHANGE: If Date of Admission is after Date of Death then remove these records.
* They may have had a stay in hospital (assuming dates wrong) but it is not recorded in their last 6 months of life.
* Affects relatively few records.

compute invalid_records=0.

do if ADMISSION_DATE > DATE_OF_DEATH.
compute invalid_records=1.
end if.

frequencies invalid_records.
*237 invalid records

select if invalid_records ne 1.
execute.

* RB CHANGE: If Date of Discharge occurs after Date of Death then set DOD=Date of Death. 
* (Otherwise you count activity after the death recorded in error).

do if (DATE_OF_DEATH<DISCHARGE_DATE).
compute test=1.
compute DISCHARGE_DATE=DATE_OF_DEATH.
end if.
execute.

* Calculate Length of Stay (LOS).

compute los=DATEDIFF(DISCHARGE_DATE,ADMISSION_DATE,"days").
execute.

*Save file with all activity at episode level relating to deaths.

save outfile=!pathExtracts + 'All_SMR_Activity_' + !FinYearUpdate + !DateExtracted + '.zsav'
/zcompressed. 

* once activity file has been created the individual SMR extracts can be deleted
* make sure everything has worked correctly before deleting the following files

erase file = !pathExtracts + 'SMR04_extracted_' + !date + '.zsav'.
erase file = !pathExtracts + 'SMR01_50_extracted_' + !date + '.zsav'.

****** Create a file with all deaths in Scotland for the time period of interest, including those who have no SMR records

get file = !pathExtracts + 'All_SMR_Activity_' + !FinYearUpdate + !DateExtracted + '.zsav'.

*Sort to ensure patient's final hospital record appears last. 
*This will allow us to aggregate to one line per patient pull in the last significant facility and, if the patient died there, determine whether it was a PC unit.

sort cases by LINK_NO DISCHARGE_DATE.

** 08/10/2018 NHS board was added as a possible breakdown so data extract can be used for IRs if needed. 
* keep pc7 in the file at this point in case any other geographies need to be matched on for IR's
* CA2011 also kept so they don't need to be manually added at the end of TDE creation to create dummy CA codes for secure version of TDE

aggregate outfile = *
   /break finyear_dth LINK_NO
   /discharge_date=max(DISCHARGE_DATE)
   /hbresname councilarea CA2011 hscp pc7 significant_facility = last(hbresname councilarea CA2011 hscp pc7 SIGNIFICANT_FACILITY)
  /date_of_death CHI institution sex age UR6_2016 simd2016_sc_quintile PRIMARY_CAUSE_OF_DEATH =  last(DATE_OF_DEATH CHI INSTITUTION SEX AGE UR6_2016 simd2016_sc_quintile PRIMARY_CAUSE_OF_DEATH).
execute.

*Flag records in current file and add on all death records. Will then need to remove duplicate death records.
compute SMR_activity_file_flag=1.
execute.

add files file = *
             /file = !pathExtracts + 'GRO-excluding-sudden-deaths_' + !FinYearUpdate + !DateExtracted + '.zsav'.
execute.

frequencies SMR_activity_file_flag.
frequencies finyear_dth.

*Flag records from the NRS deaths file which was added above.
* these will be given the SMR_activity_file_flag = 0 value

if missing(SMR_activity_file_flag) SMR_activity_file_flag=0.
execute.

CROSSTABS   SMR_activity_file_flag by finyear_dth.

*DOD only appears in original file. Aggregate based on this to determine patients which appear once/twice.
sort cases by LINK_NO DISCHARGE_DATE.

aggregate outfile = *
   mode=addvariables
   /break LINK_NO
   /discharge_date2=max(DISCHARGE_DATE).
execute.

*Want patients from original SMR activity file (with deaths) and any which only appear in second file (i.e. death records where individuals did not appear in SMR records).

if SMR_activity_file_flag=1 select_record=1.
if SMR_activity_file_flag=0 and missing(discharge_date2)=1 select_record=1.
execute.
select if select_record=1.
execute.

*Run the below check to ensure patients death records only appear once. All fine.
*sort cases by link_no.
*aggregate outfile = *
   /break link_no
   /count=N.
*execute.
*frequencies count. 

* check the number of variable information missing looks sensible
* the following are all used as filters in the tableau dashboard (except health board)

frequencies hbresname.
frequencies councilarea.
frequencies hscp.
frequencies sex.
frequencies UR6_2016.
frequencies simd2016_sc_quintile.
frequencies PRIMARY_CAUSE_OF_DEATH.

*Only interested in 2014/15 to 2016/17 deaths.
*check finyear_dth variable - 2013/14 data is included

* Custom Tables. 
CTABLES 
  /VLABELS VARIABLES=finyear_dth date_of_death DISPLAY=LABEL 
  /TABLE finyear_dth [C] BY date_of_death [S][MINIMUM, MAXIMUM, COUNT F40.0] 
  /CATEGORIES VARIABLES=finyear_dth ORDER=A KEY=VALUE EMPTY=EXCLUDE TOTAL=YES POSITION=AFTER.

**** CATEGORISE HOSPITALS
**** 08/10/2018 Community Hospital lookup fil updated from 'HospTypesComm.sav' to 'HospTypesComm_Sep18.sav'

*Use lookup to determine whether hospital is a community hospital. Not really required for this work but will leave it like this in case that breakdown is required later.
rename variables institution=location.
ALTER TYPE   location(A5).
sort cases by location.

match files file = *
 /table = !pathB + 'HospTypesComm_Sep18.sav'
 /by location.
execute.

alter type type (A40).

*** CREATE LOCATION TYPES - all locations of death

*check location types - suffix of location code. 
string loctype (a1).
compute loctype=char.substr(location, 5, 1).
exe.

*Categorise locations.
*Use location to flag Hospice/PC units.
if any(location, 'C413V', 'C306V', 'A227V', 'G414V', 'L102K', 'S121K', 'C407V', 'V103V', 'S203K', 'G583V', 'W102V', 'G501K', 'H220V', 'H265V') type='Hospice / Palliative Care Unit'.
execute.
*Use significant facility to flag PC units if date of discharge is same as date of death.
if discharge_date=date_of_death and significant_facility='1G' type='Hospice / Palliative Care Unit'.
execute.
* Use location suffix to identify Care Home locations.
if (type='' and any(loctype, 'C', 'K', 'R', 'V')) type='Care home'.
execute.
* Use location to identify hospitals.
if type='Community' type='Hospital'.
if (type='' and any(loctype, 'H', 'J')) type = 'Hospital'.
execute.
*Recode private hospitals (suffix V) into Hospital group.
if type='Care home' and any(location, 'G412V', 'G502V', 'L330V', 'S124V') type='Hospital'.
* Use location D201N to identify Home. Also include other micellaneous locations.
if (type='' and (location='D201N' or location='d102n')) type='Home'.
if type='' type='Home'.
execute.

crosstabs loctype by type.

*Create count for deaths and calculate all required totals.
compute death=1.
execute.

* deaths per year

crosstabs finyear_dth by death.

*** save out file before aggregations are made

save outfile = !pathExtracts + 'All_SMR_Activity_ready_for_aggregations_1_' + !FinYearUpdate + !DateExtracted + '.zsav'
  /zcompressed.

* Tidy variables and create categories

get file = !pathExtracts + 'All_SMR_Activity_ready_for_aggregations_1_' + !FinYearUpdate + !DateExtracted + '.zsav'.

* rename variables ready for Tableau

rename variables finyear_dth = Financial_Year_of_Death.
rename variables hscp = HSCP.
rename variables type = Location_Type.
rename variables PRIMARY_CAUSE_OF_DEATH = Cause_of_death_code.
rename variables hbresname = Health_Board.
rename variables UR6_2016 = Urban_Rural_6_fold.
rename variables simd2016_sc_quintile = SIMD_Quintile.

if councilarea = ' ' councilarea = 'Missing'.
execute.

**** Create a variable with urban rural classification labels

string Urban_Rural_Classification (A22).
 IF Urban_Rural_6_fold = 1 Urban_Rural_Classification = "Large Urban Areas".
IF Urban_Rural_6_fold = 2 Urban_Rural_Classification = "Other Urban Areas".
IF Urban_Rural_6_fold = 3 Urban_Rural_Classification = "Accessible Small Towns".
IF Urban_Rural_6_fold = 4 Urban_Rural_Classification = "Remote Small Towns".
IF Urban_Rural_6_fold = 5 Urban_Rural_Classification = "Accessible Rural".
IF Urban_Rural_6_fold = 6 Urban_Rural_Classification = "Remote Rural".
IF missing(Urban_Rural_6_fold) Urban_Rural_Classification = "Missing".
EXECUTE.
 
frequencies Urban_Rural_Classification.

**** Reformat SIMD variable

alter type SIMD_Quintile (A7).
if SIMD_Quintile = ' ' SIMD_Quintile = 'Missing'.
execute.

FREQUENCIES SIMD_Quintile.

* update gender categories and create labels

frequencies sex.
* NRS records 1 = Male, 2 = Female, 9 = Unknown
* 0 = ?, code as missing for now (CHECK)

*Create gender labels.
string Gender(a7).
if sex eq '1' Gender='Male'.
if sex eq '2' Gender='Female'.
if sex eq '9' Gender='Missing'.
if sex eq '0' Gender='Missing'.
if Gender = ' ' Gender = 'Missing'.
execute. 

frequencies gender.

*Create age groups.
* create and age category variable based on Age

recode AGE ( 0 thru 54=1) (55 thru 64=2) (65 thru 74=3) (75 thru 84=4) (85 thru high=5) into age_cat.
execute.

* create age group variable with labels

string Age_Group(a10).
if age_cat=1 Age_Group='0-54'.
if age_cat=2 Age_Group='55-64'.
if age_cat=3 Age_Group='65-74'.
if age_cat=4 Age_Group='75-84'.
if age_cat=5 Age_Group='85+'.
if Age_Group = ' ' Age_Group = 'Missing'.
execute.

frequencies age_group.
* no missing ages

save outfile = !pathExtracts + 'All_SMR_Activity_ready_for_aggregations_2_' + !FinYearUpdate + !DateExtracted + '.zsav'
 /zcompressed.

**** Cause of death diagnosis grouping *****

* Syntax creates cause of death diagnosis groupings by high level ICD10 categories
* ICD website: http://apps.who.int/classifications/icd10/browse/2010/en

************* COD groupings *************************

get file = !pathExtracts + 'All_SMR_Activity_ready_for_aggregations_2_' + !FinYearUpdate + !DateExtracted + '.zsav'.

*** Add Cause of Death Group information ***

** create a string variable with the first 3 characters of the cause of death code

string COD_code_3string (A3).
compute COD_code_3string = char.substr(Cause_of_death_code,1,3).
execute.

* create a string variable with a full description of the high level cause of death groups

string Diagnosis_group_1(A222). 

* high level groups - based on first 3 characters of diagnosis code (from ICD-10 categories on WHO website)
* note - the following will take a few minutes to run (this section could be made more efficient...)

if range(COD_code_3string, 'A00','A09') Diagnosis_group_1 ='Certain infectious and parasitic diseases'.
if range(COD_code_3string, 'A15','A19') Diagnosis_group_1 ='Certain infectious and parasitic diseases'.
if range(COD_code_3string, 'A20','A28') Diagnosis_group_1 ='Certain infectious and parasitic diseases'.
if range(COD_code_3string, 'A30','A49') Diagnosis_group_1 ='Certain infectious and parasitic diseases'.
if range(COD_code_3string, 'A50','A64') Diagnosis_group_1 ='Certain infectious and parasitic diseases'.
if range(COD_code_3string, 'A65','A69') Diagnosis_group_1 ='Certain infectious and parasitic diseases'.
if range(COD_code_3string, 'A70','A74') Diagnosis_group_1 ='Certain infectious and parasitic diseases'.
if range(COD_code_3string, 'A75','A79') Diagnosis_group_1 ='Certain infectious and parasitic diseases'.
if range(COD_code_3string, 'A80','A89') Diagnosis_group_1 ='Certain infectious and parasitic diseases'.
if range(COD_code_3string, 'A90','A99') Diagnosis_group_1 ='Certain infectious and parasitic diseases'.
if range(COD_code_3string, 'B00','B09') Diagnosis_group_1 ='Certain infectious and parasitic diseases'.
if range(COD_code_3string, 'B15','B19') Diagnosis_group_1 ='Certain infectious and parasitic diseases'.
if range(COD_code_3string, 'B20','B24') Diagnosis_group_1 ='Certain infectious and parasitic diseases'.
if range(COD_code_3string, 'B25','B34') Diagnosis_group_1 ='Certain infectious and parasitic diseases'.
if range(COD_code_3string, 'B35','B49') Diagnosis_group_1 ='Certain infectious and parasitic diseases'.
if range(COD_code_3string, 'B50','B64') Diagnosis_group_1 ='Certain infectious and parasitic diseases'.
if range(COD_code_3string, 'B65','B83') Diagnosis_group_1 ='Certain infectious and parasitic diseases'.
if range(COD_code_3string, 'B85','B89') Diagnosis_group_1 ='Certain infectious and parasitic diseases'.
if range(COD_code_3string, 'B90','B94') Diagnosis_group_1 ='Certain infectious and parasitic diseases'.
if range(COD_code_3string, 'B95','B98') Diagnosis_group_1 ='Certain infectious and parasitic diseases'.
if range(COD_code_3string, 'B99','B99') Diagnosis_group_1 ='Certain infectious and parasitic diseases'.
if range(COD_code_3string, 'C00','C97') Diagnosis_group_1 ='Neoplasms'.
if range(COD_code_3string, 'D00','D09') Diagnosis_group_1 ='Neoplasms'.
if range(COD_code_3string, 'D10','D36') Diagnosis_group_1 ='Neoplasms'.
if range(COD_code_3string, 'D37','D48') Diagnosis_group_1 ='Neoplasms'.
if range(COD_code_3string, 'D50','D53') Diagnosis_group_1 ='Diseases of the blood and blood-forming organs and certain disorders involving the immune mechanism'.
if range(COD_code_3string, 'D55','D59') Diagnosis_group_1 ='Diseases of the blood and blood-forming organs and certain disorders involving the immune mechanism'.
if range(COD_code_3string, 'D60','D64') Diagnosis_group_1 ='Diseases of the blood and blood-forming organs and certain disorders involving the immune mechanism'.
if range(COD_code_3string, 'D65','D69') Diagnosis_group_1 ='Diseases of the blood and blood-forming organs and certain disorders involving the immune mechanism'.
if range(COD_code_3string, 'D70','D77') Diagnosis_group_1 ='Diseases of the blood and blood-forming organs and certain disorders involving the immune mechanism'.
if range(COD_code_3string, 'D80','D89') Diagnosis_group_1 ='Diseases of the blood and blood-forming organs and certain disorders involving the immune mechanism'.
if range(COD_code_3string, 'E00','E07') Diagnosis_group_1 ='Endocrine, nutritional and metabolic diseases'.
if range(COD_code_3string, 'E10','E14') Diagnosis_group_1 ='Endocrine, nutritional and metabolic diseases'.
if range(COD_code_3string, 'E15','E16') Diagnosis_group_1 ='Endocrine, nutritional and metabolic diseases'.
if range(COD_code_3string, 'E20','E35') Diagnosis_group_1 ='Endocrine, nutritional and metabolic diseases'.
if range(COD_code_3string, 'E40','E46') Diagnosis_group_1 ='Endocrine, nutritional and metabolic diseases'.
if range(COD_code_3string, 'E50','E64') Diagnosis_group_1 ='Endocrine, nutritional and metabolic diseases'.
if range(COD_code_3string, 'E65','E68') Diagnosis_group_1 ='Endocrine, nutritional and metabolic diseases'.
if range(COD_code_3string, 'E70','E90') Diagnosis_group_1 ='Endocrine, nutritional and metabolic diseases'.
if range(COD_code_3string, 'F00','F09') Diagnosis_group_1 ='Mental and behavioural disorders'.
if range(COD_code_3string, 'F10','F19') Diagnosis_group_1 ='Mental and behavioural disorders'.
if range(COD_code_3string, 'F20','F29') Diagnosis_group_1 ='Mental and behavioural disorders'.
if range(COD_code_3string, 'F30','F39') Diagnosis_group_1 ='Mental and behavioural disorders'.
if range(COD_code_3string, 'F40','F48') Diagnosis_group_1 ='Mental and behavioural disorders'.
if range(COD_code_3string, 'F50','F59') Diagnosis_group_1 ='Mental and behavioural disorders'.
if range(COD_code_3string, 'F60','F69') Diagnosis_group_1 ='Mental and behavioural disorders'.
if range(COD_code_3string, 'F70','F79') Diagnosis_group_1 ='Mental and behavioural disorders'.
if range(COD_code_3string, 'F80','F89') Diagnosis_group_1 ='Mental and behavioural disorders'.
if range(COD_code_3string, 'F90','F98') Diagnosis_group_1 ='Mental and behavioural disorders'.
if range(COD_code_3string, 'F99','F99') Diagnosis_group_1 ='Mental and behavioural disorders'.
if range(COD_code_3string, 'G00','G09') Diagnosis_group_1 ='Diseases of the nervous system'.
if range(COD_code_3string, 'G10','G14') Diagnosis_group_1 ='Diseases of the nervous system'.
if range(COD_code_3string, 'G20','G26') Diagnosis_group_1 ='Diseases of the nervous system'.
if range(COD_code_3string, 'G30','G32') Diagnosis_group_1 ='Diseases of the nervous system'.
if range(COD_code_3string, 'G35','G37') Diagnosis_group_1 ='Diseases of the nervous system'.
if range(COD_code_3string, 'G40','G47') Diagnosis_group_1 ='Diseases of the nervous system'.
if range(COD_code_3string, 'G50','G59') Diagnosis_group_1 ='Diseases of the nervous system'.
if range(COD_code_3string, 'G60','G64') Diagnosis_group_1 ='Diseases of the nervous system'.
if range(COD_code_3string, 'G70','G73') Diagnosis_group_1 ='Diseases of the nervous system'.
if range(COD_code_3string, 'G80','G83') Diagnosis_group_1 ='Diseases of the nervous system'.
if range(COD_code_3string, 'G90','G99') Diagnosis_group_1 ='Diseases of the nervous system'.
if range(COD_code_3string, 'H00','H06') Diagnosis_group_1 ='Diseases of the eye and adnexa'.
if range(COD_code_3string, 'H10','H13') Diagnosis_group_1 ='Diseases of the eye and adnexa'.
if range(COD_code_3string, 'H15','H22') Diagnosis_group_1 ='Diseases of the eye and adnexa'.
if range(COD_code_3string, 'H25','H28') Diagnosis_group_1 ='Diseases of the eye and adnexa'.
if range(COD_code_3string, 'H30','H36') Diagnosis_group_1 ='Diseases of the eye and adnexa'.
if range(COD_code_3string, 'H40','H42') Diagnosis_group_1 ='Diseases of the eye and adnexa'.
if range(COD_code_3string, 'H43','H45') Diagnosis_group_1 ='Diseases of the eye and adnexa'.
if range(COD_code_3string, 'H46','H48') Diagnosis_group_1 ='Diseases of the eye and adnexa'.
if range(COD_code_3string, 'H49','H52') Diagnosis_group_1 ='Diseases of the eye and adnexa'.
if range(COD_code_3string, 'H53','H54') Diagnosis_group_1 ='Diseases of the eye and adnexa'.
if range(COD_code_3string, 'H55','H59') Diagnosis_group_1 ='Diseases of the eye and adnexa'.
if range(COD_code_3string, 'H60','H62') Diagnosis_group_1 ='Diseases of the ear and mastoid process'.
if range(COD_code_3string, 'H65','H75') Diagnosis_group_1 ='Diseases of the ear and mastoid process'.
if range(COD_code_3string, 'H80','H83') Diagnosis_group_1 ='Diseases of the ear and mastoid process'.
if range(COD_code_3string, 'H90','H95') Diagnosis_group_1 ='Diseases of the ear and mastoid process'.
if range(COD_code_3string, 'I00','I02') Diagnosis_group_1 ='Diseases of the circulatory system'.
if range(COD_code_3string, 'I05','I09') Diagnosis_group_1 ='Diseases of the circulatory system'.
if range(COD_code_3string, 'I10','I15') Diagnosis_group_1 ='Diseases of the circulatory system'.
if range(COD_code_3string, 'I20','I25') Diagnosis_group_1 ='Diseases of the circulatory system'.
if range(COD_code_3string, 'I26','I28') Diagnosis_group_1 ='Diseases of the circulatory system'.
if range(COD_code_3string, 'I30','I52') Diagnosis_group_1 ='Diseases of the circulatory system'.
if range(COD_code_3string, 'I60','I69') Diagnosis_group_1 ='Diseases of the circulatory system'.
if range(COD_code_3string, 'I70','I79') Diagnosis_group_1 ='Diseases of the circulatory system'.
if range(COD_code_3string, 'I80','I89') Diagnosis_group_1 ='Diseases of the circulatory system'.
if range(COD_code_3string, 'I95','I99') Diagnosis_group_1 ='Diseases of the circulatory system'.
if range(COD_code_3string, 'J00','J06') Diagnosis_group_1 ='Diseases of the respiratory system'.
if range(COD_code_3string, 'J09','J18') Diagnosis_group_1 ='Diseases of the respiratory system'.
if range(COD_code_3string, 'J20','J22') Diagnosis_group_1 ='Diseases of the respiratory system'.
if range(COD_code_3string, 'J30','J39') Diagnosis_group_1 ='Diseases of the respiratory system'.
if range(COD_code_3string, 'J40','J47') Diagnosis_group_1 ='Diseases of the respiratory system'.
if range(COD_code_3string, 'J60','J70') Diagnosis_group_1 ='Diseases of the respiratory system'.
if range(COD_code_3string, 'J80','J84') Diagnosis_group_1 ='Diseases of the respiratory system'.
if range(COD_code_3string, 'J85','J86') Diagnosis_group_1 ='Diseases of the respiratory system'.
if range(COD_code_3string, 'J90','J94') Diagnosis_group_1 ='Diseases of the respiratory system'.
if range(COD_code_3string, 'J95','J99') Diagnosis_group_1 ='Diseases of the respiratory system'.
if range(COD_code_3string, 'K00','K93') Diagnosis_group_1 ='Diseases of the digestive system'.
if range(COD_code_3string, 'L00','L08') Diagnosis_group_1 ='Diseases of the skin and subcutaneous tissue'.
if range(COD_code_3string, 'L10','L14') Diagnosis_group_1 ='Diseases of the skin and subcutaneous tissue'.
if range(COD_code_3string, 'L20','L30') Diagnosis_group_1 ='Diseases of the skin and subcutaneous tissue'.
if range(COD_code_3string, 'L40','L45') Diagnosis_group_1 ='Diseases of the skin and subcutaneous tissue'.
if range(COD_code_3string, 'L50','L54') Diagnosis_group_1 ='Diseases of the skin and subcutaneous tissue'.
if range(COD_code_3string, 'L55','L59') Diagnosis_group_1 ='Diseases of the skin and subcutaneous tissue'.
if range(COD_code_3string, 'L60','L75') Diagnosis_group_1 ='Diseases of the skin and subcutaneous tissue'.
if range(COD_code_3string, 'L80','L99') Diagnosis_group_1 ='Diseases of the skin and subcutaneous tissue'.
if range(COD_code_3string, 'M00','M25') Diagnosis_group_1 ='Diseases of the musculoskeletal system and connective tissue'.
if range(COD_code_3string, 'M30','M36') Diagnosis_group_1 ='Diseases of the musculoskeletal system and connective tissue'.
if range(COD_code_3string, 'M40','M54') Diagnosis_group_1 ='Diseases of the musculoskeletal system and connective tissue'.
if range(COD_code_3string, 'M60','M79') Diagnosis_group_1 ='Diseases of the musculoskeletal system and connective tissue'.
if range(COD_code_3string, 'M80','M94') Diagnosis_group_1 ='Diseases of the musculoskeletal system and connective tissue'.
if range(COD_code_3string, 'M95','M99') Diagnosis_group_1 ='Diseases of the musculoskeletal system and connective tissue'.
if range(COD_code_3string, 'N00','N08') Diagnosis_group_1 ='Diseases of the genitourinary system'.
if range(COD_code_3string, 'N10','N16') Diagnosis_group_1 ='Diseases of the genitourinary system'.
if range(COD_code_3string, 'N17','N19') Diagnosis_group_1 ='Diseases of the genitourinary system'.
if range(COD_code_3string, 'N20','N23') Diagnosis_group_1 ='Diseases of the genitourinary system'.
if range(COD_code_3string, 'N25','N29') Diagnosis_group_1 ='Diseases of the genitourinary system'.
if range(COD_code_3string, 'N30','N39') Diagnosis_group_1 ='Diseases of the genitourinary system'.
if range(COD_code_3string, 'N40','N51') Diagnosis_group_1 ='Diseases of the genitourinary system'.
if range(COD_code_3string, 'N60','N64') Diagnosis_group_1 ='Diseases of the genitourinary system'.
if range(COD_code_3string, 'N70','N77') Diagnosis_group_1 ='Diseases of the genitourinary system'.
if range(COD_code_3string, 'N80','N98') Diagnosis_group_1 ='Diseases of the genitourinary system'.
if range(COD_code_3string, 'N99','N99') Diagnosis_group_1 ='Diseases of the genitourinary system'.
if range(COD_code_3string, 'O00','O08') Diagnosis_group_1 ='Pregnancy, childbirth and the puerperium'.
if range(COD_code_3string, 'O10','O16') Diagnosis_group_1 ='Pregnancy, childbirth and the puerperium'.
if range(COD_code_3string, 'O20','O29') Diagnosis_group_1 ='Pregnancy, childbirth and the puerperium'.
if range(COD_code_3string, 'O30','O48') Diagnosis_group_1 ='Pregnancy, childbirth and the puerperium'.
if range(COD_code_3string, 'O60','O75') Diagnosis_group_1 ='Pregnancy, childbirth and the puerperium'.
if range(COD_code_3string, 'O80','O84') Diagnosis_group_1 ='Pregnancy, childbirth and the puerperium'.
if range(COD_code_3string, 'O85','O92') Diagnosis_group_1 ='Pregnancy, childbirth and the puerperium'.
if range(COD_code_3string, 'O94','O99') Diagnosis_group_1 ='Pregnancy, childbirth and the puerperium'.
if range(COD_code_3string, 'P00','P04') Diagnosis_group_1 ='Certain conditions originating in the perinatal period'.
if range(COD_code_3string, 'P05','P08') Diagnosis_group_1 ='Certain conditions originating in the perinatal period'.
if range(COD_code_3string, 'P10','P15') Diagnosis_group_1 ='Certain conditions originating in the perinatal period'.
if range(COD_code_3string, 'P20','P29') Diagnosis_group_1 ='Certain conditions originating in the perinatal period'.
if range(COD_code_3string, 'P35','P39') Diagnosis_group_1 ='Certain conditions originating in the perinatal period'.
if range(COD_code_3string, 'P50','P61') Diagnosis_group_1 ='Certain conditions originating in the perinatal period'.
if range(COD_code_3string, 'P70','P74') Diagnosis_group_1 ='Certain conditions originating in the perinatal period'.
if range(COD_code_3string, 'P75','P78') Diagnosis_group_1 ='Certain conditions originating in the perinatal period'.
if range(COD_code_3string, 'P80','P83') Diagnosis_group_1 ='Certain conditions originating in the perinatal period'.
if range(COD_code_3string, 'P90','P96') Diagnosis_group_1 ='Certain conditions originating in the perinatal period'.
if range(COD_code_3string, 'Q00','Q07') Diagnosis_group_1 ='Congenital malformations, deformations and chromosomal abnormalities'.
if range(COD_code_3string, 'Q10','Q18') Diagnosis_group_1 ='Congenital malformations, deformations and chromosomal abnormalities'.
if range(COD_code_3string, 'Q20','Q28') Diagnosis_group_1 ='Congenital malformations, deformations and chromosomal abnormalities'.
if range(COD_code_3string, 'Q30','Q34') Diagnosis_group_1 ='Congenital malformations, deformations and chromosomal abnormalities'.
if range(COD_code_3string, 'Q35','Q37') Diagnosis_group_1 ='Congenital malformations, deformations and chromosomal abnormalities'.
if range(COD_code_3string, 'Q38','Q45') Diagnosis_group_1 ='Congenital malformations, deformations and chromosomal abnormalities'.
if range(COD_code_3string, 'Q50','Q56') Diagnosis_group_1 ='Congenital malformations, deformations and chromosomal abnormalities'.
if range(COD_code_3string, 'Q60','Q64') Diagnosis_group_1 ='Congenital malformations, deformations and chromosomal abnormalities'.
if range(COD_code_3string, 'Q65','Q79') Diagnosis_group_1 ='Congenital malformations, deformations and chromosomal abnormalities'.
if range(COD_code_3string, 'Q80','Q89') Diagnosis_group_1 ='Congenital malformations, deformations and chromosomal abnormalities'.
if range(COD_code_3string, 'Q90','Q99') Diagnosis_group_1 ='Congenital malformations, deformations and chromosomal abnormalities'.
if range(COD_code_3string, 'R00','R09') Diagnosis_group_1 ='Symptoms, signs and abnormal clinical and laboratory findings, not elsewhere classified'.
if range(COD_code_3string, 'R10','R19') Diagnosis_group_1 ='Symptoms, signs and abnormal clinical and laboratory findings, not elsewhere classified'.
if range(COD_code_3string, 'R20','R23') Diagnosis_group_1 ='Symptoms, signs and abnormal clinical and laboratory findings, not elsewhere classified'.
if range(COD_code_3string, 'R25','R29') Diagnosis_group_1 ='Symptoms, signs and abnormal clinical and laboratory findings, not elsewhere classified'.
if range(COD_code_3string, 'R30','R39') Diagnosis_group_1 ='Symptoms, signs and abnormal clinical and laboratory findings, not elsewhere classified'.
if range(COD_code_3string, 'R40','R46') Diagnosis_group_1 ='Symptoms, signs and abnormal clinical and laboratory findings, not elsewhere classified'.
if range(COD_code_3string, 'R47','R49') Diagnosis_group_1 ='Symptoms, signs and abnormal clinical and laboratory findings, not elsewhere classified'.
if range(COD_code_3string, 'R50','R69') Diagnosis_group_1 ='Symptoms, signs and abnormal clinical and laboratory findings, not elsewhere classified'.
if range(COD_code_3string, 'R70','R79') Diagnosis_group_1 ='Symptoms, signs and abnormal clinical and laboratory findings, not elsewhere classified'.
if range(COD_code_3string, 'R80','R82') Diagnosis_group_1 ='Symptoms, signs and abnormal clinical and laboratory findings, not elsewhere classified'.
if range(COD_code_3string, 'R83','R89') Diagnosis_group_1 ='Symptoms, signs and abnormal clinical and laboratory findings, not elsewhere classified'.
if range(COD_code_3string, 'R90','R94') Diagnosis_group_1 ='Symptoms, signs and abnormal clinical and laboratory findings, not elsewhere classified'.
if range(COD_code_3string, 'R95','R99') Diagnosis_group_1 ='Symptoms, signs and abnormal clinical and laboratory findings, not elsewhere classified'.
if range(COD_code_3string, 'S00','S09') Diagnosis_group_1 ='Injury, poisoning and certain other consequences of external causes'.
if range(COD_code_3string, 'S10','S19') Diagnosis_group_1 ='Injury, poisoning and certain other consequences of external causes'.
if range(COD_code_3string, 'S20','S29') Diagnosis_group_1 ='Injury, poisoning and certain other consequences of external causes'.
if range(COD_code_3string, 'S30','S39') Diagnosis_group_1 ='Injury, poisoning and certain other consequences of external causes'.
if range(COD_code_3string, 'S40','S49') Diagnosis_group_1 ='Injury, poisoning and certain other consequences of external causes'.
if range(COD_code_3string, 'S50','S59') Diagnosis_group_1 ='Injury, poisoning and certain other consequences of external causes'.
if range(COD_code_3string, 'S60','S69') Diagnosis_group_1 ='Injury, poisoning and certain other consequences of external causes'.
if range(COD_code_3string, 'S70','S79') Diagnosis_group_1 ='Injury, poisoning and certain other consequences of external causes'.
if range(COD_code_3string, 'S80','S89') Diagnosis_group_1 ='Injury, poisoning and certain other consequences of external causes'.
if range(COD_code_3string, 'S90','S99') Diagnosis_group_1 ='Injury, poisoning and certain other consequences of external causes'.
if range(COD_code_3string, 'T00','T07') Diagnosis_group_1 ='Injury, poisoning and certain other consequences of external causes'.
if range(COD_code_3string, 'T08','T14') Diagnosis_group_1 ='Injury, poisoning and certain other consequences of external causes'.
if range(COD_code_3string, 'T15','T19') Diagnosis_group_1 ='Injury, poisoning and certain other consequences of external causes'.
if range(COD_code_3string, 'T20','T32') Diagnosis_group_1 ='Injury, poisoning and certain other consequences of external causes'.
if range(COD_code_3string, 'T33','T35') Diagnosis_group_1 ='Injury, poisoning and certain other consequences of external causes'.
if range(COD_code_3string, 'T36','T50') Diagnosis_group_1 ='Injury, poisoning and certain other consequences of external causes'.
if range(COD_code_3string, 'T51','T65') Diagnosis_group_1 ='Injury, poisoning and certain other consequences of external causes'.
if range(COD_code_3string, 'T66','T78') Diagnosis_group_1 ='Injury, poisoning and certain other consequences of external causes'.
if range(COD_code_3string, 'T79','T79') Diagnosis_group_1 ='Injury, poisoning and certain other consequences of external causes'.
if range(COD_code_3string, 'T80','T88') Diagnosis_group_1 ='Injury, poisoning and certain other consequences of external causes'.
if range(COD_code_3string, 'T90','T98') Diagnosis_group_1 ='Injury, poisoning and certain other consequences of external causes'.
if range(COD_code_3string, 'V01','X59') Diagnosis_group_1 ='External causes of morbidity and mortality'.
if range(COD_code_3string, 'X60','X84') Diagnosis_group_1 ='External causes of morbidity and mortality'.
if range(COD_code_3string, 'X85','Y09') Diagnosis_group_1 ='External causes of morbidity and mortality'.
if range(COD_code_3string, 'Y10','Y34') Diagnosis_group_1 ='External causes of morbidity and mortality'.
if range(COD_code_3string, 'Y35','Y36') Diagnosis_group_1 ='External causes of morbidity and mortality'.
if range(COD_code_3string, 'Y40','Y84') Diagnosis_group_1 ='External causes of morbidity and mortality'.
if range(COD_code_3string, 'Y85','Y89') Diagnosis_group_1 ='External causes of morbidity and mortality'.
if range(COD_code_3string, 'Y90','Y98') Diagnosis_group_1 ='External causes of morbidity and mortality'.
if range(COD_code_3string, 'Z00','Z13') Diagnosis_group_1 ='Factors influencing health status and contact with health services'.
if range(COD_code_3string, 'Z20','Z29') Diagnosis_group_1 ='Factors influencing health status and contact with health services'.
if range(COD_code_3string, 'Z30','Z39') Diagnosis_group_1 ='Factors influencing health status and contact with health services'.
if range(COD_code_3string, 'Z40','Z54') Diagnosis_group_1 ='Factors influencing health status and contact with health services'.
if range(COD_code_3string, 'Z55','Z65') Diagnosis_group_1 ='Factors influencing health status and contact with health services'.
if range(COD_code_3string, 'Z70','Z76') Diagnosis_group_1 ='Factors influencing health status and contact with health services'.
if range(COD_code_3string, 'Z80','Z99') Diagnosis_group_1 ='Factors influencing health status and contact with health services'.
if range(COD_code_3string, 'U00','U49') Diagnosis_group_1 ='Codes for special purposes'.
if range(COD_code_3string, 'U80','U89') Diagnosis_group_1 ='Codes for special purposes'.
Execute.

* check all codes have been assigned a diagnosis group

temporary.
select if Diagnosis_group_1 = ' '.
frequencies Cause_of_death_code.
EXECUTE.

*there should be no codes missing a diagnosis group, if a code is missing, add it to the syntax classifying codes into diagnosis_group_1 above and rerun

frequencies Diagnosis_group_1.
* check diagnosis groups don't appear twice

* if some diagnoses haven't been assigned a group
* these could be cases where cause of death information is missing
* recode these to cause of death unknown

if Diagnosis_group_1 = '' Diagnosis_group_1 ='Unknown Cause of death'.
Execute.

* NOTE - there should be no Unknown causes here as they are linked to NRS death records which should always have cause specified in the record


***** Create Cause of Death Group variable with "Other Causes" category

* causes have been categorised as "other" due to either low numbers/disclosure control or due to the sensitive nature of the cause or how 
* meaningful the description of the cause is e.g. Symptoms, signs and abnormal clinical and laboratory findings, not elsewhere classified, is not very informative

string COD_Group (A222).
execute.

Compute COD_Group = Diagnosis_group_1.
execute.

** individual COD code data wont be available after aggregations are carried out

if COD_Group= 'Certain conditions originating in the perinatal period' COD_Group = 'Other Causes'.
if COD_Group = 'Certain infectious and parasitic diseases' COD_Group = 'Other Causes'.
if COD_Group = 'Congenital malformations, deformations and chromosomal abnormalities' COD_Group = 'Other Causes'.
if COD_Group = 'Diseases of the blood and blood-forming organs and certain disorders involving the immune mechanism' COD_Group = 'Other Causes'.
if COD_Group = 'Diseases of the ear and mastoid process' COD_Group = 'Other Causes'.
if COD_Group = 'Diseases of the eye and adnexa' COD_Group = 'Other Causes'.
if COD_Group = 'Diseases of the musculoskeletal system and connective tissue' COD_Group = 'Other Causes'.
if COD_Group = 'Diseases of the skin and subcutaneous tissue' COD_Group = 'Other Causes'.
if COD_Group = 'External causes of morbidity and mortality' COD_Group = 'Other Causes'.
if COD_Group = 'Pregnancy, childbirth and the puerperium' COD_Group = 'Other Causes'.
If COD_Group = 'Symptoms, signs and abnormal clinical and laboratory findings, not elsewhere classified' COD_Group = 'Other Causes'.
If COD_Group ='Factors influencing health status and contact with health services' COD_Group = 'Other Causes'.
execute.

FREQUENCIES COD_Group.

rename variables COD_Group = Cause_of_Death.

* lookup file - Cause of death codes and groups (this will only include causes of death which occured for individuals in NRS records 2014/15 - 2017/18)
* create lookup file for cause of death code and cause of death group (both including and excluding "other causes")

temporary.
compute flag = 1.
aggregate outfile = !pathExtracts + 'Cause of death code and groups lookup_' + !FinYearUpdate + !DateExtracted + '.zsav'
/break Cause_of_death_code Cause_of_Death Diagnosis_group_1
/flag = sum(flag).
execute.

sort cases CHI.
rename variables CHI = chi.
alter type chi (A10).

* check how many records are missing CHI numbers

compute missingchi = 0.
if chi = ' ' missingchi = 1.
FREQUENCIES missingchi.
* 4% of records across all years of data
* check by year

crosstabs Financial_Year_Of_Death by missingchi.

save outfile = !pathExtracts + 'All patients - incl blank CHIs_' + !FinYearUpdate + !DateExtracted + '.zsav'
 /zcompressed.


*****************************************
*** Long Term Condition information
  
* LTC information is taken from the source linkage files and matched on at patient level.
 
** save patient level file excluding blank CHI's so LTC flags can be matched to data set
 ** blank CHI's need to be removed to allow LTC information to be matched at patient level
 
temporary.
select if chi NE ''.
save outfile = !pathExtracts + 'All patients ready for matching LTC information_' + !FinYearUpdate + !DateExtracted + '.zsav'
 /zcompressed.
execute.

* save a version of file including only blank CHIs
 * these will be added back into the file after LTC information has been added, these CHIs will be categorised as LTC =  LTC Information Unknown
 
temporary.
select if chi EQ ''.
save outfile = !pathExtracts + 'All blank CHI patients_' + !FinYearUpdate + !DateExtracted + '.zsav'
 /compressed.
execute.

******** LONG TERM CONDITIONS LOOKUP FILES ******

* create LTC lookup files for each financial year of interest
* NOTE: due to the file size, these lookup files should be deleted once they are no longer needed

**** NOTE: where date "extracted" in file names refers to the date the syntax was run and the time date was taken from SLF files, not
**** the date the data that makes up the SLFs was extracted from SMR

** NOTE: sorting each SLF by chi can take a few minutes, saving the file can also take a couple of minutes

*2017/18 

get file = '/conf/hscdiip/01-Source-linkage-files/source-individual-file-201718.zsav'.
 
sort cases by CHI.
 
save outfile = !pathExtracts + 'SLF LTC flag 1718 lookup'+ !DateExtracted + '.zsav'
 /keep chi arth asthma atrialfib cancer cvd chd copd dementia diabetes epilepsy
 refailure hefailure liver parkinsons ms arth_date asthma_date atrialfib_date cancer_date cvd_date
 liver_date copd_date dementia_date diabetes_date epilepsy_date chd_date hefailure_date ms_date 
 parkinsons_date refailure_date 
 /zcompressed.
 
*2016/17

get file = '/conf/hscdiip/01-Source-linkage-files/source-individual-file-201617.zsav'.
 
sort cases by CHI.
 
save outfile = !pathExtracts + 'SLF LTC flag 1617 lookup'+ !DateExtracted + '.zsav'
 /keep chi arth asthma atrialfib cancer cvd chd copd dementia diabetes epilepsy
 refailure hefailure liver parkinsons ms arth_date asthma_date atrialfib_date cancer_date cvd_date
 liver_date copd_date dementia_date diabetes_date epilepsy_date chd_date hefailure_date ms_date 
 parkinsons_date refailure_date 
 /zcompressed.
 
*2015/16
 
get file = '/conf/hscdiip/01-Source-linkage-files/source-individual-file-201516.zsav'.
 
sort cases by CHI.
 
save outfile = !pathExtracts + 'SLF LTC flag 1516 lookup'+ !DateExtracted + '.zsav'
 /keep chi arth asthma atrialfib cancer cvd chd copd dementia diabetes epilepsy
 refailure hefailure liver parkinsons ms arth_date asthma_date atrialfib_date cancer_date cvd_date
 liver_date copd_date dementia_date diabetes_date epilepsy_date chd_date hefailure_date ms_date 
 parkinsons_date refailure_date 
 /zcompressed.
 
* 2014/15
 
get file = '/conf/hscdiip/01-Source-linkage-files/source-individual-file-201415.zsav'.
 
sort cases by CHI.

save outfile = !pathExtracts + 'SLF LTC flag 1415 lookup'+ !DateExtracted + '.zsav'
 /keep chi arth asthma atrialfib cancer cvd chd copd dementia diabetes epilepsy
 refailure hefailure liver parkinsons ms arth_date asthma_date atrialfib_date cancer_date cvd_date
 liver_date copd_date dementia_date diabetes_date epilepsy_date chd_date hefailure_date ms_date 
 parkinsons_date refailure_date 
 /zcompressed.

* once LTC lookup files are created they can be matched on to each year individually 
* carry out match one year at a time
 
get file =  !pathExtracts + 'All patients ready for matching LTC information_' + !FinYearUpdate + !DateExtracted + '.zsav'.

* 2014/15
 
select if Financial_Year_of_Death = '2014/15'.
execute.

** match in LTC information for 2014/15 (file currently only includes records where chi is known)
** records with missing chi numbers will be matched back in at the end and given LTC = LTCUnknown

Match files file = *
 /table= !pathExtracts + 'SLF LTC flag 1415 lookup'+ !DateExtracted + '.zsav'
 /by chi.
EXECUTE.

**** CHECK LTCs

* create a variable containing all Long term conditions (LTCs)

string LTC (A60).
IF cancer=1 LTC = 'Cancer'.
if cvd=1 LTC='CVD'.
if chd=1 LTC='CHD'.
if copd=1 LTC='COPD'.
if arth=1 LTC='Arthritis'.
if diabetes=1 LTC='Diabetes'.
if atrialfib=1 LTC='Atrial Fibrilliation'.
if refailure=1 LTC='Renal failure'.
if hefailure=1 LTC='Heart failure'.
if liver=1 LTC='Liver Disease'.
if asthma=1 LTC='Asthma'.
if epilepsy=1 LTC='Epilepsy'.
if dementia=1 LTC='Dementia'.
if parkinsons=1 LTC= 'Parkinsons'.
if ms=1 LTC='MS'.
IF LTC = ' ' LTC = 'No LTC'.
EXECUTE.
 
frequencies LTC.
 
* create variable which holds the total number of LTCs per patient who has died
 
compute LTC_Total=arth+asthma+atrialfib+cancer+cvd+liver+copd+dementia+diabetes+epilepsy+chd+hefailure+ms+parkinsons+refailure.
 
* create flags for number of LTCs 
 
compute ZeroLTC=0.
compute OneLTC=0.
compute TwoLTC=0.
compute ThreeLTC=0.
compute FourLTC=0.
compute FivePlusLTC=0.
compute LTCUnknown=0.
exe.
 
if LTC_Total=0 ZeroLTC=1.
if LTC_Total=1 OneLTC=1.
if LTC_Total=2 TwoLTC=1.
if LTC_Total=3 ThreeLTC=1.
if LTC_Total=4 FourLTC=1.
if LTC_Total gt 5 LTC_Total=5.
if LTC_Total=5 FivePlusLTC=1.
if missing(LTC_Total) LTCUnknown =1.
exe.

If LTCUnknown = 1 LTC = 'LTC Information Unknown'.
execute.

frequencies LTC.

save outfile = !pathExtracts + '201415 deaths including LTCs_' + !DateSyntaxRun + '.zsav'
  /zcompressed.
 
* SLF extract file is no longer needed - check the file including LTCs has saved correctly before deleting the following lookup
 
erase file = !pathExtracts + 'SLF LTC flag 1415 lookup'+ !DateExtracted + '.zsav'.
 
* 2015/16

get file =  !pathExtracts + 'All patients ready for matching LTC information_' + !FinYearUpdate + !DateExtracted + '.zsav'.
 
select if Financial_Year_of_Death = '2015/16'.
 
Match files file = *
 /table= !pathExtracts + 'SLF LTC flag 1516 lookup' + !DateExtracted + '.zsav'
 /by chi.
EXECUTE.
 
* create a variable containing all Long term conditions (LTCs)
 
string LTC (A60).
IF cancer=1 LTC = 'Cancer'.
if cvd=1 LTC='CVD'.
if chd=1 LTC='CHD'.
if copd=1 LTC='COPD'.
if arth=1 LTC='Arthritis'.
if diabetes=1 LTC='Diabetes'.
if atrialfib=1 LTC='Atrial Fibrilliation'.
if refailure=1 LTC='Renal failure'.
if hefailure=1 LTC='Heart failure'.
if liver=1 LTC='Liver Disease'.
if asthma=1 LTC='Asthma'.
if epilepsy=1 LTC='Epilepsy'.
if dementia=1 LTC='Dementia'.
if parkinsons=1 LTC= 'Parkinsons'.
if ms=1 LTC='MS'.
IF LTC = ' ' LTC = 'No LTC'.
EXECUTE.
 
frequencies LTC.
 
* create variable which holds the total number of LTCs per patient who has died
 
compute LTC_Total=arth+asthma+atrialfib+cancer+cvd+liver+copd+dementia+diabetes+epilepsy+chd+hefailure+ms+parkinsons+refailure.
 
* create flags for number of LTCs - possibly use this later
 
if LTC_Total gt 5 LTC_Total=5.
compute ZeroLTC=0.
compute OneLTC=0.
compute TwoLTC=0.
compute ThreeLTC=0.
compute FourLTC=0.
compute FivePlusLTC=0.
compute LTCUnknown=0.
exe.
 
if LTC_Total=0 ZeroLTC=1.
if LTC_Total=1 OneLTC=1.
if LTC_Total=2 TwoLTC=1.
if LTC_Total=3 ThreeLTC=1.
if LTC_Total=4 FourLTC=1.
if LTC_Total=5 FivePlusLTC=1.
if missing(LTC_Total) LTCUnknown =1.
exe.

If LTCUnknown = 1 LTC = 'LTC Information Unknown'.
execute.

frequencies LTC.

save outfile = !pathExtracts + '201516 deaths including LTCs_' + !DateSyntaxRun + '.zsav'
 /zcompressed.
 
* SLF extract and blank chi lookup for year files are no longer needed
 
erase file = !pathExtracts + 'SLF LTC flag 1516 lookup' + !DateExtracted + '.zsav'.

* 2016/17
 
get file = !pathExtracts + 'All patients ready for matching LTC information_' + !FinYearUpdate + !DateExtracted + '.zsav'.

select if Financial_Year_of_Death = '2016/17'.
execute.
 
Match files file = *
 /table= !pathExtracts + 'SLF LTC flag 1617 lookup'+ !DateExtracted + '.zsav'
 /by chi.
EXECUTE.
 
* create a variable containing all Long term conditions (LTCs)
 
string LTC (A60).
IF cancer=1 LTC = 'Cancer'.
if cvd=1 LTC='CVD'.
if chd=1 LTC='CHD'.
if copd=1 LTC='COPD'.
if arth=1 LTC='Arthritis'.
if diabetes=1 LTC='Diabetes'.
if atrialfib=1 LTC='Atrial Fibrilliation'.
if refailure=1 LTC='Renal failure'.
if hefailure=1 LTC='Heart failure'.
if liver=1 LTC='Liver Disease'.
if asthma=1 LTC='Asthma'.
if epilepsy=1 LTC='Epilepsy'.
if dementia=1 LTC='Dementia'.
if parkinsons=1 LTC= 'Parkinsons'.
if ms=1 LTC='MS'.
IF LTC = ' ' LTC = 'No LTC'.
EXECUTE.
 
frequencies LTC.
 
* create variable which holds the total number of LTCs per patient who has died
 
compute LTC_Total=arth+asthma+atrialfib+cancer+cvd+liver+copd+dementia+diabetes+epilepsy+chd+hefailure+ms+parkinsons+refailure.
 
* create flags for number of LTCs - possibly use this later
 
if LTC_Total gt 5 LTC_Total=5.
compute ZeroLTC=0.
compute OneLTC=0.
compute TwoLTC=0.
compute ThreeLTC=0.
compute FourLTC=0.
compute FivePlusLTC=0.
compute LTCUnknown=0.
exe.
 
if LTC_Total=0 ZeroLTC=1.
if LTC_Total=1 OneLTC=1.
if LTC_Total=2 TwoLTC=1.
if LTC_Total=3 ThreeLTC=1.
if LTC_Total=4 FourLTC=1.
if LTC_Total=5 FivePlusLTC=1.
if missing(LTC_Total) LTCUnknown =1.
exe.

If LTCUnknown = 1 LTC = 'LTC Information Unknown'.
execute.

frequencies LTC.

save outfile = !pathExtracts + '201617 deaths including LTCs_' + !DateSyntaxRun + '.zsav'
  /zcompressed.
 
* Source Linkage File extract file is no longer needed
 
erase file = !pathExtracts + 'SLF LTC flag 1617 lookup'+ !DateExtracted + '.zsav'.

*2017/18
 
get file = !pathExtracts + 'All patients ready for matching LTC information_' + !FinYearUpdate + !DateExtracted + '.zsav'.

select if Financial_Year_of_Death = '2017/18'.
execute.
 
Match files file = *
 /table= !pathExtracts + 'SLF LTC flag 1718 lookup'+ !DateExtracted + '.zsav'
 /by chi.
EXECUTE.

*****LTC approach - OLD method****
****************************************** 
* create a variable containing all Long term conditions (LTCs) for each patient,
  including those one with multiple LTCs (up to 12).
 
string LTC1 to LTC12 (a20).

compute l=1.

*ARTH.
do if arth=1.
   do repeat x=LTC1 to LTC12.
   if x <>'' l=(l+1).
   end repeat.  
   if l=1 LTC1='Arth'.
   if l=2 LTC2='Arth'.
   if l=3 LTC3='Arth'.
   if l=4 LTC4='Arth'.
   if l=5 LTC5='Arth'.
   if l=6 LTC6='Arth'.
   if l=7 LTC7='Arth'.
   if l=8 LTC8='Arth'.
   if l=9 LTC9='Arth'.
   if l=10 LTC10='Arth'.
   if l=11 LTC11='Arth'.
   if l=12 LTC12='Arth'.
end if.

compute l=1.

*ASTHMA.
do if asthma=1.
   do repeat x=LTC1 to LTC12.
   if x <>'' l=(l+1).
   end repeat.  
   if l=1 LTC1='Asthma'.
   if l=2 LTC2='Asthma'.
   if l=3 LTC3='Asthma'.
   if l=4 LTC4='Asthma'.
   if l=5 LTC5='Asthma'.
   if l=6 LTC6='Asthma'.
   if l=7 LTC7='Asthma'.
   if l=8 LTC8='Asthma'.
   if l=9 LTC9='Asthma'.
   if l=10 LTC10='Asthma'.
   if l=11 LTC11='Asthma'.
   if l=12 LTC12='Asthma'.
end if.

compute l=1.

*ATRIALFIB.
do if atrialfib=1.
   do repeat x=LTC1 to LTC12.
   if x <>'' l=(l+1).
   end repeat.  
   if l=1 LTC1='Atrialfib'.
   if l=2 LTC2='Atrialfib'.
   if l=3 LTC3='Atrialfib'.
   if l=4 LTC4='Atrialfib'.
   if l=5 LTC5='Atrialfib'.
   if l=6 LTC6='Atrialfib'.
   if l=7 LTC7='Atrialfib'.
   if l=8 LTC8='Atrialfib'.
   if l=9 LTC9='Atrialfib'.
   if l=10 LTC10='Atrialfib'.
   if l=11 LTC11='Atrialfib'.
   if l=12 LTC12='Atrialfib'.
end if.

compute l=1.

*CANCER.
do if cancer=1.
   do repeat x=LTC1 to LTC12.
   if x <>'' l=(l+1).
   end repeat.  
   if l=1 LTC1='cancer'.
   if l=2 LTC2='cancer'.
   if l=3 LTC3='cancer'.
   if l=4 LTC4='cancer'.
   if l=5 LTC5='cancer'.
   if l=6 LTC6='cancer'.
   if l=7 LTC7='cancer'.
   if l=8 LTC8='cancer'.
   if l=9 LTC9='cancer'.
   if l=10 LTC10='cancer'.
   if l=11 LTC11='cancer'.
   if l=12 LTC12='cancer'.
end if.

compute l=1.

*CVD.
do if cvd=1.
   do repeat x=LTC1 to LTC12.
   if x <>'' l=(l+1).
   end repeat.  
   if l=1 LTC1='cvd'.
   if l=2 LTC2='cvd'.
   if l=3 LTC3='cvd'.
   if l=4 LTC4='cvd'.
   if l=5 LTC5='cvd'.
   if l=6 LTC6='cvd'.
   if l=7 LTC7='cvd'.
   if l=8 LTC8='cvd'.
   if l=9 LTC9='cvd'.
   if l=10 LTC10='cvd'.
   if l=11 LTC11='cvd'.
   if l=12 LTC12='cvd'.
end if.

compute l=1.

*LIVER.
do if liver=1.
   do repeat x=LTC1 to LTC12.
   if x <>'' l=(l+1).
   end repeat.  
   if l=1 LTC1='liver'.
   if l=2 LTC2='liver'.
   if l=3 LTC3='liver'.
   if l=4 LTC4='liver'.
   if l=5 LTC5='liver'.
   if l=6 LTC6='liver'.
   if l=7 LTC7='liver'.
   if l=8 LTC8='liver'.
   if l=9 LTC9='liver'.
   if l=10 LTC10='liver'.
   if l=11 LTC11='liver'.
   if l=12 LTC12='liver'.
end if.

compute l=1.

*COPD.
do if copd=1.
   do repeat x=LTC1 to LTC12.
   if x <>'' l=(l+1).
   end repeat.  
   if l=1 LTC1='copd'.
   if l=2 LTC2='copd'.
   if l=3 LTC3='copd'.
   if l=4 LTC4='copd'.
   if l=5 LTC5='copd'.
   if l=6 LTC6='copd'.
   if l=7 LTC7='copd'.
   if l=8 LTC8='copd'.
   if l=9 LTC9='copd'.
   if l=10 LTC10='copd'.
   if l=11 LTC11='copd'.
   if l=12 LTC12='copd'.
end if.

compute l=1.

*DEMENTIA.
do if dementia=1.
   do repeat x=LTC1 to LTC12.
   if x <>'' l=(l+1).
   end repeat.  
   if l=1 LTC1='dementia'.
   if l=2 LTC2='dementia'.
   if l=3 LTC3='dementia'.
   if l=4 LTC4='dementia'.
   if l=5 LTC5='dementia'.
   if l=6 LTC6='dementia'.
   if l=7 LTC7='dementia'.
   if l=8 LTC8='dementia'.
   if l=9 LTC9='dementia'.
   if l=10 LTC10='dementia'.
   if l=11 LTC11='dementia'.
   if l=12 LTC12='dementia'.
end if.

compute l=1.

*DIABETES.
do if diabetes=1.
   do repeat x=LTC1 to LTC12.
   if x <>'' l=(l+1).
   end repeat.  
   if l=1 LTC1='diabetes'.
   if l=2 LTC2='diabetes'.
   if l=3 LTC3='diabetes'.
   if l=4 LTC4='diabetes'.
   if l=5 LTC5='diabetes'.
   if l=6 LTC6='diabetes'.
   if l=7 LTC7='diabetes'.
   if l=8 LTC8='diabetes'.
   if l=9 LTC9='diabetes'.
   if l=10 LTC10='diabetes'.
   if l=11 LTC11='diabetes'.
   if l=12 LTC12='diabetes'.
end if.

compute l=1.

*EPILEPSY.
do if epilepsy=1.
   do repeat x=LTC1 to LTC12.
   if x <>'' l=(l+1).
   end repeat.  
   if l=1 LTC1='epilepsy'.
   if l=2 LTC2='epilepsy'.
   if l=3 LTC3='epilepsy'.
   if l=4 LTC4='epilepsy'.
   if l=5 LTC5='epilepsy'.
   if l=6 LTC6='epilepsy'.
   if l=7 LTC7='epilepsy'.
   if l=8 LTC8='epilepsy'.
   if l=9 LTC9='epilepsy'.
   if l=10 LTC10='epilepsy'.
   if l=11 LTC11='epilepsy'.
   if l=12 LTC12='epilepsy'.
end if.

compute l=1.

*CHD.
do if chd=1.
   do repeat x=LTC1 to LTC12.
   if x <>'' l=(l+1).
   end repeat.  
   if l=1 LTC1='chd'.
   if l=2 LTC2='chd'.
   if l=3 LTC3='chd'.
   if l=4 LTC4='chd'.
   if l=5 LTC5='chd'.
   if l=6 LTC6='chd'.
   if l=7 LTC7='chd'.
   if l=8 LTC8='chd'.
   if l=9 LTC9='chd'.
   if l=10 LTC10='chd'.
   if l=11 LTC11='chd'.
   if l=12 LTC12='chd'.
end if.

compute l=1.

*HEFAILURE.
do if hefailure=1.
   do repeat x=LTC1 to LTC12.
   if x <>'' l=(l+1).
   end repeat.  
   if l=1 LTC1='hefailure'.
   if l=2 LTC2='hefailure'.
   if l=3 LTC3='hefailure'.
   if l=4 LTC4='hefailure'.
   if l=5 LTC5='hefailure'.
   if l=6 LTC6='hefailure'.
   if l=7 LTC7='hefailure'.
   if l=8 LTC8='hefailure'.
   if l=9 LTC9='hefailure'.
   if l=10 LTC10='hefailure'.
   if l=11 LTC11='hefailure'.
   if l=12 LTC12='hefailure'.
end if.

compute l=1.

*MS.
do if ms=1.
   do repeat x=LTC1 to LTC12.
   if x <>'' l=(l+1).
   end repeat.  
   if l=1 LTC1='ms'.
   if l=2 LTC2='ms'.
   if l=3 LTC3='ms'.
   if l=4 LTC4='ms'.
   if l=5 LTC5='ms'.
   if l=6 LTC6='ms'.
   if l=7 LTC7='ms'.
   if l=8 LTC8='ms'.
   if l=9 LTC9='ms'.
   if l=10 LTC10='ms'.
   if l=11 LTC11='ms'.
   if l=12 LTC12='ms'.
end if.

compute l=1.

*PARKINSONS.
do if parkinsons=1.
   do repeat x=LTC1 to LTC12.
   if x <>'' l=(l+1).
   end repeat.  
   if l=1 LTC1='parkinsons'.
   if l=2 LTC2='parkinsons'.
   if l=3 LTC3='parkinsons'.
   if l=4 LTC4='parkinsons'.
   if l=5 LTC5='parkinsons'.
   if l=6 LTC6='parkinsons'.
   if l=7 LTC7='parkinsons'.
   if l=8 LTC8='parkinsons'.
   if l=9 LTC9='parkinsons'.
   if l=10 LTC10='parkinsons'.
   if l=11 LTC11='parkinsons'.
   if l=12 LTC12='parkinsons'.
end if.

compute l=1.

*REFAILURE.
do if refailure=1.
   do repeat x=LTC1 to LTC12.
   if x <>'' l=(l+1).
   end repeat.  
   if l=1 LTC1='refailure'.
   if l=2 LTC2='refailure'.
   if l=3 LTC3='refailure'.
   if l=4 LTC4='refailure'.
   if l=5 LTC5='refailure'.
   if l=6 LTC6='refailure'.
   if l=7 LTC7='refailure'.
   if l=8 LTC8='refailure'.
   if l=9 LTC9='refailure'.
   if l=10 LTC10='refailure'.
   if l=11 LTC11='refailure'.
   if l=12 LTC12='refailure'.
end if.
Execute.

*Create variable which holds the total number of LTCs per patient who has died.
compute LTC_Total=arth+asthma+atrialfib+cancer+cvd+liver+copd+dementia+diabetes+epilepsy+chd+hefailure+ms+parkinsons+refailure.

*Create flags for number of LTCs - possibly use this later
 
if LTC_Total gt 5 LTC_Total=5.
compute ZeroLTC=0.
compute OneLTC=0.
compute TwoLTC=0.
compute ThreeLTC=0.
compute FourLTC=0.
compute FivePlusLTC=0.
compute LTCUnknown=0.
exe.
 
if LTC_Total=0 ZeroLTC=1.
if LTC_Total=1 OneLTC=1.
if LTC_Total=2 TwoLTC=1.
if LTC_Total=3 ThreeLTC=1.
if LTC_Total=4 FourLTC=1.
if LTC_Total=5 FivePlusLTC=1.
if missing(LTC_Total) LTCUnknown =1.
exe.

*If LTCUnknown = 1 LTC = 'LTC Information Unknown'.
*execute.

*frequencies LTC.

save outfile = !pathLTC + '201718 deaths including LTCs_' + !DateSyntaxRun + '.zsav'
 /zcompressed.
 
* Source Linkage File extract file is no longer needed
 
erase file = !pathExtracts + 'SLF LTC flag 1718 lookup'+ !DateExtracted + '.zsav'.

**** Create patient level file with all years of data ****
* create patient level file with all years and all LTCs to match to original full without LTC information.

DATASET CLOSE all.

get file = !pathLTC + '201718 deaths including LTCs_' + !DateSyntaxRun + '.zsav'.
 
*add files file = *
 /file  = !pathExtracts + '201617 deaths including LTCs_' + !DateSyntaxRun + '.zsav'
 /file  = !pathExtracts + '201516 deaths including LTCs_' + !DateSyntaxRun + '.zsav'
 /file = !pathExtracts + '201415 deaths including LTCs_' + !DateSyntaxRun + '.zsav'.
*execute.
 
frequencies Financial_Year_of_death.
 
save outfile = !pathExtracts + 'All deaths where CHI known_' + !FinYearUpdate + !DateSyntaxRun + '.zsav'
 /zcompressed.
 
* delete individual year files (make sure all years file has saved correctly first)
 
erase file = !pathExtracts + '201415 deaths including LTCs_' + !DateSyntaxRun + '.zsav'.
erase file = !pathExtracts + '201516 deaths including LTCs_' + !DateSyntaxRun + '.zsav'.
erase file = !pathExtracts + '201617 deaths including LTCs_' + !DateSyntaxRun + '.zsav'.
erase file = !pathExtracts + '201718 deaths including LTCs_' + !DateSyntaxRun + '.zsav'.
 
* create file with all information including data for patients where CHI is not known
*** add back in all blank CHI's now LTC information has been matched on

DATASET CLOSE all. 

get file =  !pathLTC + 'All deaths where CHI known_' + !FinYearUpdate + !DateSyntaxRun + '.zsav'.

add files file = *
 /file =  !pathExtracts + 'All blank CHI patients_' + !FinYearUpdate + !DateExtracted + '.zsav'.
execute.

* check LTC categories

*frequencies LTC.

*temporary.
*select if LTC = ' '.
*frequencies LTCUnknown.
*execute.

* update LTC unknown category to include those with blank CHI's whihc have just been added into the file
* where it is not possible to determine whether a patient has had an LTC or not

*if LTC = ' ' LTC = 'LTC Information Unknown'.
*if sysmis(LTCUnknown) LTCUnknown = 1.
*execute.

*FREQUENCIES LTC.

*sort cases chi.

*** check all variable categories - does the amount of missing information look sensible?

*frequencies financial_year_of_death councilarea gender age_group location_type cause_of_death Urban_Rural_Classification
 SIMD_Quintile LTC LTC_Total.

*** LTC_Total sysmis values - possibly code as 99? check how this would impact syntax later on

*** save patient level file with all deaths regardless of whether chi is known or not

save outfile = !pathLTC +  'All deaths_' + !FinYearUpdate + !DateSyntaxRun + '.zsav'
 /zcompressed.

DATASET CLOSE all.

get file = !pathLTC +  'All deaths_'  + !FinYearUpdate + !DateSyntaxRun + '.zsav'.


select if Financial_Year_of_Death = '2017/18'.
execute.

* create an aggregate version of the file to get the total number of deaths and to keep only the variables of interest
 
aggregate outfile = *
 /break Financial_Year_of_Death chi HSCP councilarea CA2011 Age_Group Gender Location_Type Urban_Rural_Classification
 SIMD_Quintile LTC1 LTC2 LTC3 LTC4 LTC5 LTC6 LTC7 LTC8 LTC9 LTC10 LTC11 LTC12 LTC_Total Cause_of_Death
 /death=sum(death).

save outfile = !pathLTC + '2. Patient level file - all deaths_' + !FinYearUpdate + !DateSyntaxRun + '.zsav'
 /zcompressed.


*** Final file to be used to create Tableau data extract

aggregate outfile = *
 /break Financial_Year_of_Death councilarea CA2011 Age_Group Gender Location_Type Urban_Rural_Classification
 SIMD_Quintile LTC1 LTC2 LTC3 LTC4 LTC5 LTC6 LTC7 LTC8 LTC9 LTC10 LTC11 LTC12 LTC_Total Cause_of_Death
 /Total_deaths=sum(death).
execute.

frequencies councilarea.
* remove records where council area information is missing

frequencies CA2011.
* CA2011 and councilarea should be the same

Select if councilarea NE 'Missing'.
execute.
 
save outfile = !pathLTC + '1. All deaths aggregated file_' + !FinYearUpdate + !DateSyntaxRun + '.zsav'
  /zcompressed.

* Open syntax 2 to create Tableau data extract
