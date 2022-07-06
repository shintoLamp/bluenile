* Encoding: UTF-8.
***created by D McMaster 28/10/2013
*** Updated by EP March 2014.
*** Revamped layout - CHPs have to be renamed from 2012/13 Health Mapping Summary to merge with LFR file provided by SG
****UPDATED BY ALISON MCCLELLAND 27/02/2015****
***NOTE 2012/13 Health Mapping Summary did not have same age split as LFR. These have to be aligned. 
*____________________________________________________________________________________________


* Merge Mapped and UNmapped expenditure to create New NHS Expenditure file.
add files file ='/conf/hscdiip/11-mapping/'+!Mapyear+'/data/outputs/Mapped-Summary-Final-Scotland3.sav'
/file '/conf/hscdiip/11-mapping/'+!Mapyear+'/data/outputs/Unmapped-Summary-Final-Scotland.sav'
/drop mapyear sector SubSector.
exe.

if hscp_code='S37000032' and hscp_name='' hscp_name='Fife'.
if hscp_code='S37000033' and hscp_name='' hscp_name='Perth & Kinross'.
if hscp_code='S37000034' and hscp_name='' hscp_name='Glasgow City'.
if hscp_code='S37000035' and hscp_name='' hscp_name='North Lanarkshire'.
execute.

* Correct Unmapped-Summary so that variables align with mapped.
if hbr = "" hbr = hbt.
if HealthBoardR = "" HealthBoardR = HealthBoardT.
if HSCP_Code = "" HSCP_Code = "N/A".
if HSCP_name = "" HSCP_name = "Non HSCP".
if age_band = 0 age_band = 999.
if age_desc = "" age_desc = "Missing".
if HSCP_name = 'N/A' HSCP_name = 'Non HSCP'.
EXECUTE.

*add year.
STRING YEAR (A7).
COMPUTE YEAR='2018/19'.
execute.

* match on summary levels for outputs including number codes for tidy functional output ordering.
* will need updated to include Julies new list for 12-13.

SORT CASES BY mapcode.
alter type mapsection (a59).

*Check.
*get file =!pathname2 + 'Functional_output_summary_level_lookup_1415.sav'.
match files file =*
/TABLE =!pathname2 + 'Functional_output_summary_level_lookup_1819.sav'
/by mapcode.
EXECUTE.

* Remove expenditure for Mental Health - State Hospital *.
select if Sub_sector ne "Drop".
execute.

* Recode age groupings to match LFR3.
if age_band = 1 Age_desc = "<18".
if age_band = 2 Age_desc = "18-64".
if age_band = 3 Age_desc = "65-74".
if age_band = 4 Age_desc = "75-84".
if age_band = 5 Age_desc = "85+".
execute.

rename variables Age_desc = AGEGROUP.
*rename variables HSCP_name = HSCP_nameOLD.
rename variables Total_Net_Costs = Expenditure.

SAVE OUTFILE=!pathname1 + '/All-chps-Temp1-'+!year+'.sav'
/keep YEAR hbr HSCP_NAME AGEGROUP service Sector Sub_sector Detail_Sector Expenditure.

* Need to create ALL age band totals.
compute AGEGROUP = "All".
execute.

aggregate outfile =*
/break YEAR hbr HSCP_NAME AGEGROUP service Sector Sub_sector Detail_Sector
/Expenditure=sum(Expenditure).
execute.

SAVE OUTFILE=!pathname1 + '/All-chps-Temp2-'+!year+'.sav'
/keep YEAR hbr HSCP_NAME AGEGROUP service Sector Sub_sector Detail_Sector Expenditure.

get file =!pathname1 + '/All-chps-Temp2-'+!year+'.sav'.

* Merge files.
add files file =!pathname1 + '/All-chps-Temp1-'+!year+'.sav'
/file =!pathname1 + '/All-chps-Temp2-'+!year+'.sav'.
execute.

alter type HSCP_NAME (a57).

SAVE OUTFILE=!pathname1 + '/All-chps-Temp3-'+!year+'.sav'
/keep YEAR hbr HSCP_NAME AGEGROUP service Sector Sub_sector Detail_Sector Expenditure.

* Need to create Board totals.
select if HBR ne 'O'.
execute.

aggregate outfile =*
/break YEAR hbr AGEGROUP service Sector Sub_sector Detail_Sector 
/Expenditure=sum(Expenditure).
execute.

string HSCP_NAME (a57).
if hbr='A' HSCP_NAME ='NHS Ayrshire & Arran'.
if hbr='B' HSCP_NAME ='NHS Borders'.
if hbr='F' HSCP_NAME ='NHS Fife'.
if hbr='G' HSCP_NAME ='NHS Greater Glasgow & Clyde'.
if hbr='H' HSCP_NAME='NHS Highland'.
if hbr='L' HSCP_NAME='NHS Lanarkshire'.
if hbr='N' HSCP_NAME='NHS Grampian'.
if hbr='R' HSCP_NAME='NHS Orkney'.
if hbr='S' HSCP_NAME='NHS Lothian'.
if hbr='T' HSCP_NAME='NHS Tayside'.
if hbr='V' HSCP_NAME='NHS Forth Valley'.
if hbr='W' HSCP_NAME='NHS Western Isles'.
if hbr='Y' HSCP_NAME='NHS Dumfries & Galloway'.
if hbr='Z' HSCP_NAME='NHS Shetland'.
if hbr='O' HSCP_NAME='Non Scottish Residents'.
execute.

SAVE OUTFILE=!pathname1 + '/All-chps-Temp4-'+!year+'.sav'
/keep YEAR hbr HSCP_NAME AGEGROUP service Sector Sub_sector Detail_Sector Expenditure.

* Merge CHP and Board totals.
add files file=!pathname1 + '/All-chps-Temp3-'+!year+'.sav'
/file=!pathname1 + '/All-chps-Temp4-'+!year+'.sav'.
execute.

Alter type HSCP_NAME (a141).
Alter type AGEGROUP (a15).
alter type service (a20).
alter type sector (a37).

if HSCP_NAME='Dundee' HSCP_NAME='Dundee City'.
if HSCP_NAME='Edinburgh' HSCP_NAME='City of Edinburgh'.
execute.

Aggregate outfile = *
/break = YEAR hbr HSCP_NAME AGEGROUP service Sector Sub_sector Detail_Sector
/Expenditure = sum(Expenditure).
execute.

select if hbr ne 'D'.
execute.

alter type sub_sector (a41).

RECODE HSCP_NAME ('Argyll and Bute'='Argyll & Bute') ('Dumfries and Galloway'='Dumfries & Galloway') 
('Perth and Kinross'='Perth & Kinross') ('Orkney Islands'='Orkney') ('Shetland Islands'='Shetland').

SAVE OUTFILE=!pathname3 + '/All-chps-Final-'+!year+'.sav'
/keep YEAR hbr HSCP_NAME AGEGROUP service Sector Sub_sector Detail_Sector Expenditure.

get file = !pathname3 + '/All-chps-Final-'+!year+'.sav'.

*To align with LFR we need to add on grouping to distinguish between NHS and Social Care Spent retaining the output order.








