* Encoding: UTF-8.
**Add HRI Files together - LA level.
*Program by EP June 2015.
* Updated Sept 15 to for new HRI Thresholds.


Define !file()
     '/conf/sourcedev/TableauUpdates/HRI/Outputs/'
!Enddefine.

******************************************************************

*Add Main Data for different years together.

Add files file = !file+ '/1920/TAB-TDE-ALL-costs-HRI_LCA_Final201920.zsav'
 /file = !file+ '/2021/TAB-TDE-ALL-costs-HRI_LCA_Final202021.zsav' 
 /file = !file+ '/1718/TAB-TDE-ALL-costs-HRI_LCA_Final201718.zsav' 
 /file = !file+ '/1819/TAB-TDE-ALL-costs-HRI_LCA_Final201819.zsav'.

*freq vars Beddays.

recode Beddays (sysmis eq 0).
compute AllPatient_Flag = 0.
compute HRI50_Flag = 0.
compute HRI65_Flag = 0.
compute HRI80_Flag = 0.
compute HRI95_Flag = 0.
if UserType eq 'LCA-HRI_ALL' AllPatient_Flag eq 1.
if UserType eq 'LCA-HRI_50' HRI50_Flag eq 1.
if UserType eq 'LCA-HRI_65' HRI65_Flag eq 1.
if UserType eq 'LCA-HRI_80' HRI80_Flag eq 1.
if UserType eq 'LCA-HRI_95' HRI95_Flag eq 1.

alter type UserType (A20).
* Make userType and more useable label for Tableau outputs.
if UserType eq 'LCA-HRI_ALL' UserType eq 'All Service users'.
if UserType eq 'LCA-HRI_50' UserType eq 'HRI Threshold 50%'.
if UserType eq 'LCA-HRI_65' UserType eq 'HRI Threshold 65%'.
if UserType eq 'LCA-HRI_80' UserType eq 'HRI Threshold 80%'.
if UserType eq 'LCA-HRI_95' UserType eq 'HRI Threshold 95%'.

save outfile =  !file+'/TAB-TDE-ALL-costs-HRI_LCA_Final_AllYears.zsav'
/zcompressed.

* Need to create file to match on total costs.
get file =  !file+'/TAB-TDE-ALL-costs-HRI_LCA_Final_AllYears.zsav'.

SELECT IF AllPatient_Flag eq 1 and lcaname ~="Non LCA".
SELECT IF AllPatient_Flag eq 1.
RENAME VARIABLES (Total_Cost = Total_Cost_ALL).
RENAME VARIABLES (Episodes_Attendances = Episodes_Attendances_ALL).
RENAME VARIABLES (Beddays = Beddays_ALL).
RENAME VARIABLES (NumberPatients = NumberPatients_ALL).

sort cases by Year LA_CODE HB_CODE Gender AgeBand  ServiceType.

save outfile =  !file+'/TAB-TDE-ALL-costs-HRI_LCA_Final_AllYears_Totals.zsav'
/KEEP Year LCAname LA_CODE HB_CODE Gender AgeBand  ServiceType Total_Cost_ALL Episodes_Attendances_ALL Beddays_ALL NumberPatients_ALL
/zcompressed.

get file =  !file+'/TAB-TDE-ALL-costs-HRI_LCA_Final_AllYears.zsav'.

SELECT IF AllPatient_Flag NE 1 and lcaname ~="Non LCA".
SELECT IF AllPatient_Flag NE 1.

sort cases by Year LA_CODE HB_CODE Gender AgeBand ServiceType.

MATCH FILES file = *
/Table = !file+'/TAB-TDE-ALL-costs-HRI_LCA_Final_AllYears_Totals.zsav' 
/by Year LA_CODE HB_CODE Gender AgeBand  ServiceType.

RENAME VARIABLES (Total_Cost = Total_Cost_OLD).
RENAME VARIABLES (Episodes_Attendances = Episodes_Attendances_OLD).
RENAME VARIABLES (Beddays = Beddays_OLD).
RENAME VARIABLES (NumberPatients = NumberPatients_OLD).

Compute Total_Cost =  Total_Cost_ALL - Total_Cost_OLD.
Compute Episodes_Attendances = Episodes_Attendances_ALL - Episodes_Attendances_OLD.
Compute Beddays = Beddays_ALL - Beddays_OLD.
compute NumberPatients = NumberPatients_ALL - NumberPatients_OLD.
compute UserType = 'Other Service Users'.

save outfile =  !file+'/TAB-TDE-ALL-costs-HRI_LCA_Final_AllYears_OtherUsers.zsav'
/keep Year LCAname LA_CODE HB_CODE HBName Gender AgeBand UserType ServiceType Total_Cost Episodes_Attendances Beddays NumberPatients
AllPatient_Flag HRI50_Flag HRI65_Flag HRI80_Flag HRI95_Flag
/zcompressed.


* Bring files togther and add Blank row for Tableau.
add files file = !file+'/TAB-TDE-ALL-costs-HRI_LCA_Final_AllYears.zsav'
/file =  !file+'/TAB-TDE-ALL-costs-HRI_LCA_Final_AllYears_OtherUsers.zsav'.

* Add data type for TDE.
String Data (A20).
Compute Data = 'Standard'.
EXECUTE.

* Create codes to suppress area's on variation charts.
* Feb. 2019. HB codes for NHS Fife and NHS Tayside have been updated to reflect updates in Source Linkage Files.

String HB_TAB_Code (a6).
if HB_CODE ='S08000015'  HB_TAB_Code ='HBVC9'.
if HB_CODE ='S08000016'  HB_TAB_Code ='HBVC5'.
if HB_CODE ='S08000017'  HB_TAB_Code ='HBVC11'.
if HB_CODE ='S08000029'  HB_TAB_Code ='HBVC12'.
if HB_CODE ='S08000019'  HB_TAB_Code ='HBVC7'.
if HB_CODE ='S08000020'  HB_TAB_Code ='HBVC14'.
if HB_CODE ='S08000021'  HB_TAB_Code ='HBVC8'.
if HB_CODE ='S08000022'  HB_TAB_Code ='HBVC13'.
if HB_CODE ='S08000023'  HB_TAB_Code ='HBVC1'.
if HB_CODE ='S08000024'  HB_TAB_Code ='HBVC3'.
if HB_CODE ='S08000025'  HB_TAB_Code ='HBVC6'.
if HB_CODE ='S08000026'  HB_TAB_Code ='HBVC4'.
if HB_CODE ='S08000030'  HB_TAB_Code ='HBVC10'.
if HB_CODE ='S08000028'  HB_TAB_Code ='HBVC2'.

String LA_TAB_Code (a6).
if LCAname = 'Scottish Borders' LA_TAB_Code =	'LAVC11'.
if LCAname = 'Fife' LA_TAB_Code ='LAVC2'.
if LCAname = 'Orkney' LA_TAB_Code ='LAVC26'.
if LCAname = 'Western Isles' LA_TAB_Code ='LAVC8'.
if LCAname = 'Dumfries & Galloway' LA_TAB_Code ='LAVC20'.
if LCAname = 'Shetland' LA_TAB_Code ='LAVC9'.
if LCAname = 'North Ayrshire' LA_TAB_Code ='LAVC10'.
if LCAname = 'South Ayrshire' LA_TAB_Code ='LAVC21'.
if LCAname = 'East Ayrshire' LA_TAB_Code ='LAVC1'.
if LCAname = 'East Dunbartonshire' LA_TAB_Code ='LAVC22'.
if LCAname = 'Glasgow City' LA_TAB_Code ='LAVC23'.
if LCAname = 'East Renfrewshire' LA_TAB_Code ='LAVC12'.
if LCAname = 'West Dunbartonshire' LA_TAB_Code ='LAVC13'.
if LCAname = 'Renfrewshire' LA_TAB_Code ='LAVC31'.
if LCAname = 'Inverclyde' LA_TAB_Code ='LAVC3'.
if LCAname = 'Highland' LA_TAB_Code ='LAVC4'.
if LCAname = 'Argyll & Bute' LA_TAB_Code ='LAVC24'.
if LCAname = 'North Lanarkshire' LA_TAB_Code ='LAVC32'.
if LCAname = 'South Lanarkshire' LA_TAB_Code ='LAVC14'.
if LCAname = 'Aberdeen City' LA_TAB_Code ='LAVC25'.
if LCAname = 'Aberdeenshire' LA_TAB_Code ='LAVC15'.
if LCAname = 'Moray' LA_TAB_Code ='LAVC5'.
if LCAname = 'East Lothian' LA_TAB_Code ='LAVC27'.
if LCAname = 'West Lothian' LA_TAB_Code ='LAVC17'.
if LCAname = 'Midlothian' LA_TAB_Code ='LAVC6'.
if LCAname = 'City of Edinburgh' LA_TAB_Code ='LAVC16'.
if LCAname = 'Perth & Kinross' LA_TAB_Code =	'LAVC7'.
if LCAname = 'Dundee City' LA_TAB_Code ='LAVC28'.
if LCAname = 'Angus' LA_TAB_Code ='LAVC30'.
if LCAname = 'Clackmannanshire' LA_TAB_Code ='LAVC18'.
if LCAname = 'Falkirk' LA_TAB_Code ='LAVC29'.
if LCAname = 'Stirling' LA_TAB_Code ='LAVC19'.

save outfile =  !file+'/TAB-TDE-ALL-costs-HRI_LCA_Final_AllYears_MAIN.zsav'
/zcompressed.

*Datazone level for MAPS and localities.

Add files file = !file+ '/1920/TAB-TDE-ALL-costs-HRI_DZ_Final201920.zsav'
 /file = !file+ '/2021/TAB-TDE-ALL-costs-HRI_DZ_Final202021.zsav' 
 /file = !file+ '/1718/TAB-TDE-ALL-costs-HRI_DZ_Final201718.zsav' 
 /file = !file+ '/1819/TAB-TDE-ALL-costs-HRI_DZ_Final201819.zsav'.

** Need to add SIMD2016 by Datazone.
sort cases by datazone.
ALTER TYPE datazone (a9).

MATCH FILES file = *
/Table  = '/conf/irf/09-Tableau-Outputs/01-Development/04-Source-Data/03-HRI/2020simd.sav'
/by DataZone.

ALTER TYPE datazone (A9).

Add files file = *
 /file = !file+ '/1920/TAB-TDE-ALL-costs-HRI_Locality_Final201920.zsav' 
 /file = !file+ '/2021/TAB-TDE-ALL-costs-HRI_Locality_Final202021.zsav' 
 /file = !file+ '/1718/TAB-TDE-ALL-costs-HRI_Locality_Final201718.zsav' 
 /file = !file+ '/1819/TAB-TDE-ALL-costs-HRI_Locality_Final201819.zsav'.

compute AllPatient_Flag = 0.
compute HRI50_Flag = 0.
compute HRI65_Flag = 0.
compute HRI80_Flag = 0.
compute HRI95_Flag = 0.

if UserType eq 'LCA-HRI_ALL' AllPatient_Flag eq 1.
if UserType eq 'LCA-HRI_50' HRI50_Flag eq 1.
if UserType eq 'LCA-HRI_65' HRI65_Flag eq 1.
if UserType eq 'LCA-HRI_80' HRI80_Flag eq 1.
if UserType eq 'LCA-HRI_95' HRI95_Flag eq 1.

alter type UserType (A20).
if UserType eq 'LCA-HRI_50' UserType eq 'HRI Threshold 50%'.
if UserType eq 'LCA-HRI_65' UserType eq 'HRI Threshold 65%'.
if UserType eq 'LCA-HRI_80' UserType eq 'HRI Threshold 80%'.
if UserType eq 'LCA-HRI_95' UserType eq 'HRI Threshold 95%'.

* Add data type for TDE.
String Data (A20).
Compute Data = 'Map'.

* Create codes to suppress area's on variation charts.
* Feb. 2019. HB codes for NHS Fife and NHS Tayside have been updated to reflect updates in Source Linkage Files.

String HB_TAB_Code (a6).
if HB_CODE ='S08000015'  HB_TAB_Code ='HBVC9'.
if HB_CODE ='S08000016'  HB_TAB_Code ='HBVC5'.
if HB_CODE ='S08000017'  HB_TAB_Code ='HBVC11'.
if HB_CODE ='S08000029'  HB_TAB_Code ='HBVC12'.
if HB_CODE ='S08000019'  HB_TAB_Code ='HBVC7'.
if HB_CODE ='S08000020'  HB_TAB_Code ='HBVC14'.
if HB_CODE ='S08000021'  HB_TAB_Code ='HBVC8'.
if HB_CODE ='S08000022'  HB_TAB_Code ='HBVC13'.
if HB_CODE ='S08000023'  HB_TAB_Code ='HBVC1'.
if HB_CODE ='S08000024'  HB_TAB_Code ='HBVC3'.
if HB_CODE ='S08000025'  HB_TAB_Code ='HBVC6'.
if HB_CODE ='S08000026'  HB_TAB_Code ='HBVC4'.
if HB_CODE ='S08000030'  HB_TAB_Code ='HBVC10'.
if HB_CODE ='S08000028'  HB_TAB_Code ='HBVC2'.

String LA_TAB_Code (a6).
if LCAname = 'Scottish Borders' LA_TAB_Code =	'LAVC11'.
if LCAname = 'Fife' LA_TAB_Code ='LAVC2'.
if LCAname = 'Orkney' LA_TAB_Code ='LAVC26'.
if LCAname = 'Western Isles' LA_TAB_Code ='LAVC8'.
if LCAname = 'Dumfries & Galloway' LA_TAB_Code ='LAVC20'.
if LCAname = 'Shetland' LA_TAB_Code ='LAVC9'.
if LCAname = 'North Ayrshire' LA_TAB_Code ='LAVC10'.
if LCAname = 'South Ayrshire' LA_TAB_Code ='LAVC21'.
if LCAname = 'East Ayrshire' LA_TAB_Code ='LAVC1'.
if LCAname = 'East Dunbartonshire' LA_TAB_Code ='LAVC22'.
if LCAname = 'Glasgow City' LA_TAB_Code ='LAVC23'.
if LCAname = 'East Renfrewshire' LA_TAB_Code ='LAVC12'.
if LCAname = 'West Dunbartonshire' LA_TAB_Code ='LAVC13'.
if LCAname = 'Renfrewshire' LA_TAB_Code ='LAVC31'.
if LCAname = 'Inverclyde' LA_TAB_Code ='LAVC3'.
if LCAname = 'Highland' LA_TAB_Code ='LAVC4'.
if LCAname = 'Argyll & Bute' LA_TAB_Code ='LAVC24'.
if LCAname = 'North Lanarkshire' LA_TAB_Code ='LAVC32'.
if LCAname = 'South Lanarkshire' LA_TAB_Code ='LAVC14'.
if LCAname = 'Aberdeen City' LA_TAB_Code ='LAVC25'.
if LCAname = 'Aberdeenshire' LA_TAB_Code ='LAVC15'.
if LCAname = 'Moray' LA_TAB_Code ='LAVC5'.
if LCAname = 'East Lothian' LA_TAB_Code ='LAVC27'.
if LCAname = 'West Lothian' LA_TAB_Code ='LAVC17'.
if LCAname = 'Midlothian' LA_TAB_Code ='LAVC6'.
if LCAname = 'City of Edinburgh' LA_TAB_Code ='LAVC16'.
if LCAname = 'Perth & Kinross' LA_TAB_Code =	'LAVC7'.
if LCAname = 'Dundee City' LA_TAB_Code ='LAVC28'.
if LCAname = 'Angus' LA_TAB_Code ='LAVC30'.
if LCAname = 'Clackmannanshire' LA_TAB_Code ='LAVC18'.
if LCAname = 'Falkirk' LA_TAB_Code ='LAVC29'.
if LCAname = 'Stirling' LA_TAB_Code ='LAVC19'.

if Locality = '' Locality = 'Map'.

SAVE OUTFILE= !file+'/DZ_HRI_All.zsav'
/zcompressed.

get file =  !file+'/DZ_HRI_All.zsav'.

add files file=*
/file =  !file+'/TAB-TDE-ALL-costs-HRI_LCA_Final_AllYears_MAIN.zsav'.

show n.

SAVE OUTFILE= !file+'/HRI_All.sav'.

get file = !file+'/HRI_All.sav'.

*Create suppressed data.

SAVE OUTFILE= !file+'/HRI_suppressed_All.sav' 
 /drop LCAname LA_CODE HB_CODE HBname.

*Create data for Overview chart.

Add files file = !file+ '/1920/TDE_201920_Final.zsav'  
 /file = !file+ '/2021/TDE_202021_Final.zsav' 
 /file = !file+ '/1718/TDE_201718_Final.zsav'
 /file = !file+ '/1819/TDE_201819_Final.zsav'. 

SAVE OUTFILE= !file+'/HRI_chart_All.sav'.

*Create data for Scotland overview.

Add files file = !file+ '/1920/TAB-TDE-ALL-costs-HRI_Scot_Final201920.zsav'
 /file = !file+ '/2021/TAB-TDE-ALL-costs-HRI_Scot_Final202021.zsav'
 /file = !file+ '/1718/TAB-TDE-ALL-costs-HRI_Scot_Final201718.zsav'
 /file = !file+ '/1819/TAB-TDE-ALL-costs-HRI_Scot_Final201819.zsav'.

SAVE OUTFILE= !file+'/HRI_Scot_All.sav'.

get file =!file+'/HRI_Scot_All.sav'.

frequencies hbname.

*************************************
*End of syntax.






























*temporary.
*select if $casenum<=650000.
*SAVE TRANSLATE OUTFILE='/conf/linkage/output/keirro/TAB-TDE-ALL-costs-HRI_LCA_Final_combinedPart1.xlsx'
  /TYPE=XLS   /VERSION=12  /MAP  /REPLACE  /FIELDNAMES
  /CELLS=VALUES .

*temporary.
*select if $casenum>650000.
*SAVE TRANSLATE OUTFILE='/conf/linkage/output/keirro/TAB-TDE-ALL-costs-HRI_LCA_Final_combinedPart2.xlsx'
  /TYPE=XLS   /VERSION=12  /MAP  /REPLACE  /FIELDNAMES
  /CELLS=VALUES .













*SAVE TRANSLATE OUTFILE='/conf/irf/01-CPTeam/02-Functional-outputs/08-HRI-200,000-days/2010-2014/Tableau Outputs/DZ_HRI_All.xlsx'
  /TYPE=XLS
  /VERSION=12
  /MAP
  /REPLACE
  /FIELDNAMES
 /drop chp_2012_simd2012_quintile chp_2012_simd2012_decile chp_2011_simd2012_quintile chp_2011_simd2012_decile chp_subarea_2011_simd2012_quintile chp_subarea_2011_simd2012_decile
chpsimd2012quintile chpsimd2012decile hbsimd2012quintile hbsimd2012decile hb2014simd2012decile hb2014simd2012quintile simd2012tp15 simd2012bt15 simd2009V2score
scsimd2009V2quintile scsimd2009V2decile hbsimd2009V2quintile hbsimd2009V2decile hb2014simd2009V2decile hb2014simd2009V2quintile chpsimd2009V2quintile
chpsimd2009V2decile chp_2012_simd2009v2_quintile chp_2012_simd2009v2_decile chp_2011_simd2009v2_quintile chp_2011_simd2009v2_decile chp_subarea_2011_simd2009v2_quintile
chp_subarea_2011_simd2009v2_decile simd2009V2tp15 simd2009V2bt15 simd2006score scsimd2006quintile scsimd2006decile hbsimd2006quintile hbsimd2006decile
hb2014simd2006decile hb2014simd2006quintile simd2006tp15 simd2006bt15 simd2004score scsimd2004quintile scsimd2004decile hbsimd2004quintile hbsimd2004decile
hb2014simd2004decile hb2014simd2004quintile simd2004tp15 simd2004bt15
  /CELLS=VALUES.

**********************************************************************************************************************************************************************************************.
*LA Files for Stack bars.

*add files file = !file+'/TAB-TDE-ALL-costs-HRI_LCA_Percent_Final1314.sav'
/file = !file+'/TAB-TDE-ALL-costs-HRI_LCA_Percent_Final1213.sav'
/file = !file+'/TAB-TDE-ALL-costs-HRI_LCA_Percent_Final1112.sav'
/file = !file+'/TAB-TDE-ALL-costs-HRI_LCA_Percent_Final1011.sav'
/drop Total_Cost Episodes_Attendances Beddays NumberPatients Total_Cost_LA Episodes_Attendances_LA NumberPatients_LA.
*exe.

*compute AllPatient_Flag = 0.
*compute HRI50_Flag = 0.
*compute HRI65_Flag = 0.
*compute HRI80_Flag = 0.
*compute HRI95_Flag = 0.
*EXECUTE.


*if UserType eq 'LCA-HRI_50' HRI50_Flag eq 1.
*if UserType eq 'LCA-HRI_65' HRI65_Flag eq 1.
*if UserType eq 'LCA-HRI_80' HRI80_Flag eq 1.
*if UserType eq 'LCA-HRI_95' HRI95_Flag eq 1.

* Make userType and more useable label for Tableau outputs.
*alter type UserType (A20).
*alter type ChtM_Cost (A20).
*alter type ChtM_EpisAtte (A20).
*alter type ChtM_Beddays (A20).
*alter type ChtM_Pats (A20).

*Make chart labels more useful.

*if ChtM_Cost = 'Cost_perThres'  and UserType eq 'LCA-HRI_50' ChtM_Cost = 'HRI Threshold 50%'.
*if ChtM_Cost = 'Cost_perThres'  and UserType eq 'LCA-HRI_65' ChtM_Cost = 'HRI Threshold 65%'.
*if ChtM_Cost = 'Cost_perThres'  and UserType eq 'LCA-HRI_80' ChtM_Cost = 'HRI Threshold 80%'.
*if ChtM_Cost = 'Cost_perThres'  and UserType eq 'LCA-HRI_95' ChtM_Cost = 'HRI Threshold 95%'.

*if ChtM_EpisAtte = 'EpisAtte_perThres'  and UserType eq 'LCA-HRI_50' ChtM_EpisAtte  = 'HRI Threshold 50%'.
*if ChtM_EpisAtte = 'EpisAtte_perThres'  and UserType eq 'LCA-HRI_65' ChtM_EpisAtte  = 'HRI Threshold 65%'.
*if ChtM_EpisAtte = 'EpisAtte_perThres'  and UserType eq 'LCA-HRI_80' ChtM_EpisAtte  = 'HRI Threshold 80%'.
*if ChtM_EpisAtte = 'EpisAtte_perThres'  and UserType eq 'LCA-HRI_95' ChtM_EpisAtte  = 'HRI Threshold 95%'.

*if ChtM_Beddays = 'Beddays_perThres'  and UserType eq 'LCA-HRI_50' ChtM_Beddays  = 'HRI Threshold 50%'.
*if ChtM_Beddays = 'Beddays_perThres'  and UserType eq 'LCA-HRI_65' ChtM_Beddays  = 'HRI Threshold 65%'.
*if ChtM_Beddays = 'Beddays_perThres'  and UserType eq 'LCA-HRI_80' ChtM_Beddays  = 'HRI Threshold 80%'.
*if ChtM_Beddays = 'Beddays_perThres'  and UserType eq 'LCA-HRI_95' ChtM_Beddays  = 'HRI Threshold 95%'.

*if ChtM_Pats = 'Pats_perThres'  and UserType eq 'LCA-HRI_50' ChtM_Pats  = 'HRI Threshold 50%'.
*if ChtM_Pats = 'Pats_perThres'  and UserType eq 'LCA-HRI_65' ChtM_Pats  = 'HRI Threshold 65%'.
*if ChtM_Pats = 'Pats_perThres'  and UserType eq 'LCA-HRI_80' ChtM_Pats  = 'HRI Threshold 80%'.
*if ChtM_Pats = 'Pats_perThres'  and UserType eq 'LCA-HRI_95' ChtM_Pats  = 'HRI Threshold 95%'.

*if UserType eq 'LCA-HRI_50' UserType eq 'HRI Threshold 50%'.
*if UserType eq 'LCA-HRI_65' UserType eq 'HRI Threshold 65%'.
*if UserType eq 'LCA-HRI_80' UserType eq 'HRI Threshold 80%'.
*if UserType eq 'LCA-HRI_95' UserType eq 'HRI Threshold 95%'.

*EXECUTE.

* Add data type for TDE.
*String Data (A20).
*Compute Data = 'Stackedbar'.
*EXECUTE.

*SAVE OUTFILE = !file+'/LA_HRI_Stacked_All.sav'.

*SAVE TRANSLATE OUTFILE='/conf/irf/01-CPTeam/02-Functional-outputs/08-HRI-200,000-days/2010-2014/Tableau Outputs/LA_HRI_Stacked_All.xlsx'
  /TYPE=XLS
  /VERSION=12
  /MAP
  /REPLACE
  /FIELDNAMES
  /CELLS=VALUES.

*****************************************************************************************************************************************************.
* Bring files togther and add Blank row for Tableau.
*add files file ='/conf/irf/01-CPTeam/02-Functional-outputs/08-HRI-200,000-days/2010-2014/Tableau Outputs/BlankRow_LA_TDE.sav'
/file =  !file+'/TAB-TDE-ALL-costs-HRI_LCA_Final_AllYears_MAIN.sav'.
*exe.


*get file='/conf/irf/01-CPTeam/02-Functional-outputs/08-HRI-200,000-days/2010-2014/Tableau Outputs/BlankRow_LA_TDE.sav'.

*alter type ageband (a15).
*add files file =*
*/file =  !file+'/TAB-TDE-ALL-costs-HRI_LCA_Final_AllYears_MAIN'+!year+'.sav'.
*exe.

 * get file =  !file+'/TAB-TDE-ALL-costs-HRI_LCA_Final_AllYears_MAIN'+!year+'.sav'.
*save outfile = !file + 'TAB_HRI_SPSS_Raw.sav'.
 * save outfile = !file + 'TAB_HRI_SPSS_Raw'+!year+'.sav'.


*get file =  !file + 'TAB_HRI_SPSS_Raw.sav'.
 * get file = !file + 'TAB_HRI_SPSS_Raw'+!year+'.sav'.

************************************Create Dummy data.

 * COMPUTE Random_Number=RV.UNIFORM(0.5,0.8).
 * EXECUTE.

 * compute Total_Cost = (Total_Cost*Random_Number).
 * compute Episodes_Attendances = (Episodes_Attendances*Random_Number).
 * compute Beddays = (Beddays*Random_Number).
 * compute NumberPatients = (NumberPatients*Random_Number).



*save outfile = !file + 'TAB_HRI_SPSS_Raw_DUMMY.sav'
/drop Random_Number.

 * save outfile = !file + 'TAB_HRI_SPSS_Raw_DUMMY'+!year+'.sav'
/drop Random_Number.


*get file =  !file + 'TAB_HRI_SPSS_Raw_DUMMY.sav'.
 * get file = !file + 'TAB_HRI_SPSS_Raw_DUMMY'+!year+'.sav'.




 * SAVE TRANSLATE OUTFILE='/conf/linkage/output/keirro/TAB_HRI_SPSS_Raw'+!year+'.xlsx'
  /TYPE=XLS
  /VERSION=12
  /MAP
  /REPLACE
  /FIELDNAMES
  /CELLS=VALUES.

* Produce Suppressed file required for Tableau.
*get file =  !file+'/TAB-TDE-ALL-costs-HRI_LCA_Final_AllYears_MAIN.sav'.

 * get file =  !file+'/TAB-TDE-ALL-costs-HRI_LCA_Final_AllYears_MAIN'+!year+'.sav'.
 * SAVE TRANSLATE OUTFILE='/conf/linkage/output/keirro/TAB_HRI_SPSS_Raw_Suppressed'+!year+'.xlsx'
  /TYPE=XLS
  /VERSION=12
  /MAP
  /REPLACE
  /FIELDNAMES
  /CELLS=VALUES
  /DROP=LCAname LA_CODE HB_CODE HBname.




 * get file=!file+'/TAB-TDE-ALL-costs-HRI_Scot_Final' + !year + '.sav'.


 * SAVE TRANSLATE OUTFILE='/conf/linkage/output/keirro/TAB_HRI_SPSS_Raw_Scot_Suppressed'+!year+'.xlsx'
  /TYPE=XLS
  /VERSION=12
  /MAP
  /REPLACE
  /FIELDNAMES
  /CELLS=VALUES
  /DROP=HB_CODE HBname.



*SAVE TRANSLATE OUTFILE='/conf/irf/01-CPTeam/02-Functional-outputs/09-Tableau-Outputs/01-Development/02-SPSS-Outputs/03-HRI/TAB_HRI_SPSS_Raw_Suppressed.xlsx'
  /TYPE=XLS
  /VERSION=12
  /MAP
  /REPLACE
  /FIELDNAMES
  /CELLS=VALUES
  /DROP=LCAname LA_CODE HB_CODE HBname.

****************************************************************************************************************************************************************************************************
*****