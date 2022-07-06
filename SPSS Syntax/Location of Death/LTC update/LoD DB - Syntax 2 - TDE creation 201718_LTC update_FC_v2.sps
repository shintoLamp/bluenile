* Encoding: UTF-8.
***********************************************************************************************
*** Location of Death Dashboard Syntax Part 2 - Tableau Data Extract Creation ***
***********************************************************************************************
** Jenny Armstrong - 03/10/2018
* adapted from syntax at: \\Stats\irf\18-End-of-Life\Data Development\PEOLC 2.1 Location of death analysis

* This syntax generates the tableau data extract to produce 2.1 Location of death dashboard 
* which was developed for the 2017/18 PEOLC work plan

* Syntax produces the tableau data extract containing 2014/15 data onwards
* This data is then used to populate the Location of Death dashboard published on the Source platform

*** Analysis contains details of the following for 2014/15 onwards (by financial year)
* total deaths in Scotland and H&SC partnerships 
* broken down by location e.g. hospital, home, care home or hospice/palliative care unit
* LTC, Cause of Death group, SIMD, Age, Gender and Urban/Rural classification

********************************************************************************************************************************************
** DEFINE FILE PATHS & DATE OF UPDATES

* File names are set up so only the following dates needs to be updated and file names will automatically be updated

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

* how to use in file paths
*get file = '/conf/hscdiip/01-Source-linkage-files/source-episode-file-' + !year +'.zsav'. 
*Execute. 

*** Analysis file locations

**** Data Extracts ****
*\\Stats\irf\18-End-of-Life\Data Extracts

***** NOTE: if irf is full the file path above can be changed to the sourcedev PEoLC file as a temporary measure ('/conf/sourcedev/TableauUpdates/PEoLC/')
* JA 08/10/2018 syntax run - files saved in sourcedev

***  End of Life / Data Extracts folder 
DEFINE  !pathExtracts()
'/conf/irf/18-End-of-Life/Data Extracts/'
!enddefine.

DEFINE  !pathExtracts()
'/conf/sourcedev/TableauUpdates/PEoLC/Data Extracts/'
!enddefine.

* Tableau Data Extract
*\\Stats\sourcedev\TableauUpdates\PEoLC

* The previous year's Tableau data extract can be found at the following location
* This is where the most up to date TDE should also be saved

DEFINE  !pathTDE()
'/conf/sourcedev/TableauUpdates/PEoLC/LTC update/output/'
!enddefine.

* NOTE: once the updated TDE is available, the previous version containing fewer years of data
* should be deleted (only after the dashboard & data have been tested and proved to be correct & working)

*ORIGINAL ANALYSIS FILE PATH - FOR INFO
*DEFINE  !pathC()
'/conf/irf/18-End-of-Life/Data Development/PEOLC 2.1 Location of death analysis/Data Extracts/Tableau/'
!enddefine.

**********************************************************************************************************************************

* TDE creation - "all" category for all variables were removed
* each "all" category aggregate will be created directly in Tableau.
* An LTC variable will also be added in Tableau to reflect the change in multiple LTC couting (eg. LTC1, LTC2, etc).



get file = !pathTDE + '1. All deaths aggregated file_' + !FinYearUpdate + !DateSyntaxRun + '.zsav'.

*Flag with LTC known those records with missing LTC information.

if sysmis(LTC_Total) LTC_Total = 99.
execute.
 
alter type LTC_Total (A7).
if LTC_Total = '  99.00' LTC_Total = 'Unknown'.
if LTC_Total = '   1.00' LTC_Total = '1'.
if LTC_Total = '   2.00' LTC_Total = '2'.
if LTC_Total = '   3.00' LTC_Total = '3'.
if LTC_Total = '   4.00' LTC_Total = '4'.
if LTC_Total = '   5.00' LTC_Total = '5'.
if LTC_Total = '    .00' LTC_Total = '0'.
execute.

frequencies LTC_Total.


save outfile = !pathLTC + '1 temp total deaths aggregate file.zsav'
 /zcompressed.

* update variable names to match names used in Tableau dashboard and so aliases don't need to be updated

rename variables councilarea = Council_Area.
rename variables Total_deaths = Deaths.


if Location_Type = 'Hospice / Palliative Care Unit' Location_Type = 'Hospice / Palliative Care'.
execute.

save outfile = !pathLTC  + '2 temp total deaths aggregate file.zsav'
 /zcompressed.

*** Add Scotland and Location type total columns to the file

get file = !pathLTC  + '2 temp total deaths aggregate file.zsav'.

**** Add a column to the data containing the Scotland Total 
*Create count total for Scotland.
* add Scotland variable on to data set
* note - dont include council area / CA2011 variable in the list of variables to break data on as we want a total across all CAs

aggregate outfile = * mode=addvariables
 /break Financial_Year_of_Death Age_Group Gender Location_Type Urban_Rural_Classification
 SIMD_Quintile LTC1 LTC2 LTC3 LTC4 LTC5 LTC6 LTC7 LTC8 LTC9 LTC10 LTC11 LTC12 LTC_Total Cause_of_Death
 /Scotland_Deaths=sum(Deaths).
execute.

**** Add a variable that holds a total for All Location types
**** create a seperate lookup file to do so and match back in All_Locations column/variable
**** the row including the "All" locations category can be kept as a row in the data

frequencies Location_Type. 

sort cases by Financial_Year_of_Death Council_Area CA2011 Age_Group Gender Urban_Rural_Classification
 SIMD_Quintile LTC1 LTC2 LTC3 LTC4 LTC5 LTC6 LTC7 LTC8 LTC9 LTC10 LTC11 LTC12 LTC_Total Cause_of_Death.

save outfile = !pathLTC+ '3 temp total deaths aggregate file.zsav'
 /zcompressed.


rename variables Deaths = All_Location_Deaths.

save outfile = !pathLTC+ '4 temp total deaths aggregate file.zsav'
 /zcompressed.



***************************************** NOTE, for individual location type totals see line 515 of syntax *****************************************************
******                      total hospital deaths, total care home deaths, total hospice deaths, total home deaths
***********************************************************************************************************************************************************************

get file = !pathLTC+ '4 temp total deaths aggregate file.zsav'.

** add a dummy council area variable so two versions of the data file can be saved
** one with all CA information, and one with the dummy CA variable that can be used to apply security settings in Tableau
** so HSCPs can only see their own data
** council areas will be replaced by a random ID.

**** NOTE - IF SYNTAX IS TO BE SHARED WITH LOCAL ANALYSTS THIS SECTION SHOULD BE REMOVED

string Council_Area_dummy (A100).
compute Council_Area_dummy = Council_Area. 
if Council_Area_dummy='Highland' Council_Area_dummy = 'LA 100'.
if Council_Area_dummy='Fife' Council_Area_dummy =  'LA 101'.
if Council_Area_dummy='Angus' Council_Area_dummy =  'LA 102'.
if Council_Area_dummy='Glasgow City' Council_Area_dummy =  'LA 103'.
if  Council_Area_dummy='North Ayrshire' Council_Area_dummy =  'LA 104'.
if  Council_Area_dummy='Midlothian' Council_Area_dummy =  'LA 105'.
if  Council_Area_dummy='Perth & Kinross' Council_Area_dummy =  'LA 106'.
if Council_Area_dummy='East Ayrshire' Council_Area_dummy =  'LA 107'.
if  Council_Area_dummy='West Lothian' Council_Area_dummy =  'LA 108'.
if Council_Area_dummy='Clackmannanshire' Council_Area_dummy =  'LA 109'.
if  Council_Area_dummy='South Lanarkshire' Council_Area_dummy =  'LA 110'.
if  Council_Area_dummy='Scottish Borders' Council_Area_dummy =  'LA 111'.
if Council_Area_dummy='Western Isles' Council_Area_dummy =  'LA 112'.
if Council_Area_dummy='City of Edinburgh' Council_Area_dummy =  'LA 113'.
if Council_Area_dummy='East Renfrewshire' Council_Area_dummy =  'LA 114'.
if  Council_Area_dummy='Moray' Council_Area_dummy =  'LA 115'.
if Council_Area_dummy='Dumfries & Galloway' Council_Area_dummy =  'LA 116'.
if  Council_Area_dummy='Shetland Islands' Council_Area_dummy =  'LA 117'.
if Council_Area_dummy='East Dunbartonshire' Council_Area_dummy =  'LA 118'.
if  Council_Area_dummy='Stirling' Council_Area_dummy =  'LA 119'.
if Council_Area_dummy='Dundee City' Council_Area_dummy =  'LA 120'.
if Council_Area_dummy='Aberdeenshire' Council_Area_dummy =  'LA 121'.
if  Council_Area_dummy='North Lanarkshire' Council_Area_dummy =  'LA 122'.
if Council_Area_dummy='Inverclyde' Council_Area_dummy =  'LA 123'.
if Council_Area_dummy ='Aberdeen City' Council_Area_dummy = 'LA 124'.
if Council_Area_dummy='Argyll & Bute' Council_Area_dummy =  'LA 125'.
if Council_Area_dummy='West Dunbartonshire' Council_Area_dummy =  'LA 126'.
if Council_Area_dummy='South Ayrshire' Council_Area_dummy =  'LA 127'.
if Council_Area_dummy='East Lothian' Council_Area_dummy =  'LA 128'.
if Council_Area_dummy='Renfrewshire' Council_Area_dummy =  'LA 129'.
if Council_Area_dummy='Orkney Islands' Council_Area_dummy =  'LA 130'.
if Council_Area_dummy='Falkirk' Council_Area_dummy =  'LA 131'.
execute.

FREQUENCIES Council_Area_dummy.

****** FINAL TABLEAU DATA EXTRACT (TDE) .SAV FILE **************
* both of the following are needed, TDE with council area and tde with only dummy council area variable

* full data file TDE including council area names.

RENAME VARIABLES CA2011 = LA_CODE.
exe.

save outfile = !pathLTC + '1. Location of death TDE ' + !DateSyntaxRun +'.sav'
/keep Financial_Year_of_Death Council_Area Council_Area_dummy LA_CODE Age_Group Gender Urban_Rural_Classification
 SIMD_Quintile LTC1 LTC2 LTC3 LTC4 LTC5 LTC6 LTC7 LTC8 LTC9 LTC10 LTC11 LTC12 LTC_Total Cause_of_Death Location_Type Scotland_Deaths All_Location_Deaths.

get file = !pathLTC + '1. Location of death TDE ' + !DateSyntaxRun +'.sav'.

Alter type SIMD_Quintile(A24). 
exe.

IF SIMD_Quintile = '      1' SIMD_Quintile = '1 - Most deprived'.
IF SIMD_Quintile = '      2' SIMD_Quintile = '2'.
IF SIMD_Quintile = '      3' SIMD_Quintile = '3'.
IF SIMD_Quintile = '      4' SIMD_Quintile = '4'.
IF SIMD_Quintile = '      5' SIMD_Quintile = '5 - Least deprived'.
execute.

frequencies SIMD_Quintile.

if Cause_of_Death ='Neoplasms' Cause_of_Death='Cancers'.
execute.

frequencies Cause_of_Death.

save outfile = !pathLTC + '1. Location of death TDE ' + !DateSyntaxRun +'.zsav'
  /zcompressed.

get file = !pathLTC + '1. Location of death TDE ' + !DateSyntaxRun +'.sav'.


* security file version of TDE so HCSPs can only see the name of their own HSCP when data is viewed in Tableau
***** Dummy version of council area and partnership names removed 

save outfile = !pathLTC + '1. Location of death TDE Dummy HSCP ' + !DateSyntaxRun +'.sav'
  /drop Council_Area LA_CODE.

* check council area variable is definitely not included in final file 

get file = !pathLTC + '1. Location of death TDE Dummy HSCP ' + !DateSyntaxRun +'.sav'.


