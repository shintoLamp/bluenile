* Encoding: UTF-8.
*Copied from update by EP for 2012-13
******UPDATED BY ALISON MCCLELLAND FOR 2013-14******
****************************************************************************************************************************************
*Read in LFR data - slighlt reformatted from originial formal received from SG - notes on changes and content within excel file below and LFR3 documentation.

*Updated by JM May 2017 for 2015/16 financial year.
*Updated by DT Oct 2017 for 2015/16 financial year, aggregating Clackmannanshire and Stirling

PRESERVE.
SET DECIMAL DOT.

GET DATA  /TYPE=TXT
  /FILE=
    "/conf/irf/09-Tableau-Outputs/01-Development/04-Source-Data/01-HSC-Expenditure/2018-19/LFR3-18-19-Data.csv"
  /ENCODING='UTF8'
  /DELIMITERS=","
  /QUALIFIER='"'
  /ARRANGEMENT=DELIMITED
  /FIRSTCASE=2
  /DATATYPEMIN PERCENTAGE=95.0
  /VARIABLES=
  service A20
  sector A37
  mapname A37
  detailed_level_for_match AUTO
  Year A7
  Client_group A70
  Aberdeen_City F5.0
  Aberdeenshire F5.0
  Angus F5.0
  Argyll_and_Bute F5.0
  Clackmannanshire F4.0
  Dumfries_and_Galloway F5.0
  Dundee_City F5.0
  East_Ayrshire F5.0
  East_Dunbartonshire F4.0
  East_Lothian F5.0
  East_Renfrewshire F4.0
  City_of_Edinburgh F5.0
  Eilean_Siar F4.0
  Falkirk F5.0
  Fife F5.0
  Glasgow_City F5.0
  Highland F5.0
  Inverclyde F5.0
  Midlothian F4.0
  Moray F4.0
  North_Ayrshire F5.0
  North_Lanarkshire F5.0
  Orkney_Islands F4.0
  Perth_and_Kinross F5.0
  Renfrewshire F5.0
  Scottish_Borders F5.0
  Shetland_Islands F4.0
  South_Ayrshire F5.0
  South_Lanarkshire F5.0
  Stirling F4.0
  West_Dunbartonshire F5.0
  West_Lothian F5.0
  /MAP.
RESTORE.
CACHE.
EXECUTE.


RECODE Aberdeen_City Aberdeenshire Angus Argyll_and_Bute Clackmannanshire 
    Dumfries_and_Galloway Dundee_City East_Ayrshire East_Dunbartonshire East_Lothian East_Renfrewshire 
    City_of_Edinburgh Eilean_Siar Falkirk Fife Glasgow_City Highland Inverclyde Midlothian Moray 
    North_Ayrshire North_Lanarkshire Orkney_Islands Perth_and_Kinross Renfrewshire Scottish_Borders 
    Shetland_Islands South_Ayrshire South_Lanarkshire Stirling West_Dunbartonshire West_Lothian (SYSMIS=0).
EXECUTE.


*Flip to same format as Mapping:.
VARSTOCASES
  /MAKE Expenditure FROM Aberdeen_City Aberdeenshire Angus Argyll_and_Bute Clackmannanshire 
    Dumfries_and_Galloway Dundee_City East_Ayrshire East_Dunbartonshire East_Lothian East_Renfrewshire 
    City_of_Edinburgh Eilean_Siar Falkirk Fife Glasgow_City Highland Inverclyde Midlothian Moray 
    North_Ayrshire North_Lanarkshire Orkney_Islands Perth_and_Kinross Renfrewshire Scottish_Borders 
    Shetland_Islands South_Ayrshire South_Lanarkshire Stirling West_Dunbartonshire West_Lothian
  /INDEX=HSCP(Expenditure) 
  /KEEP=service	sector	mapname	detailed_level_for_match Year Client_Group
  /NULL=KEEP.

*Make HSCP variable same length as in Mapping (for adding files).
Alter type HSCP (a47).
RENAME VARIABLES HSCP=HSCP_NAME.
execute.

RECODE HSCP_NAME ('Aberdeen_City'='Aberdeen City') ('Argyll_and_Bute'='Argyll & Bute') ('Dumfries_and_Galloway'='Dumfries & Galloway')
('Dundee_City'='Dundee City') ('East_Ayrshire'='East Ayrshire') ('East_Dunbartonshire'='East Dunbartonshire') ('East_Lothian'='East Lothian')
('East_Renfrewshire'='East Renfrewshire') ('City_of_Edinburgh'='City of Edinburgh') ('Eilean_Siar'='Western Isles')('Glasgow_City'='Glasgow City')
('North_Ayrshire'='North Ayrshire') ('North_Lanarkshire'='North Lanarkshire') ('Orkney_Islands'='Orkney')
('Perth_and_Kinross'='Perth & Kinross') ('Scottish_Borders'='Scottish Borders') ('Shetland_Islands'='Shetland')
('South_Ayrshire'='South Ayrshire') ('South_Lanarkshire'='South Lanarkshire') ('West_Dunbartonshire'='West Dunbartonshire')
('West_Lothian'='West Lothian').
execute.

*ADD HBR Cipher.
STRING hbr (A1).

if any(HSCP_NAME, 'North Ayrshire', 'South Ayrshire', 'East Ayrshire') hbr = 'A'.
if any(HSCP_NAME, 'East Dunbartonshire', 'Glasgow City', 'East Renfrewshire', 'West Dunbartonshire', 'Renfrewshire', 'Inverclyde') hbr = 'G'.
if any(HSCP_NAME, 'Highland', 'Argyll & Bute') hbr = 'H'.
if any(HSCP_NAME, 'North Lanarkshire', 'South Lanarkshire') hbr = 'L'.
if any(HSCP_NAME, 'Aberdeen City', 'Aberdeenshire', 'Moray') hbr = 'N'.
if any(HSCP_NAME, 'East Lothian', 'West Lothian', 'Midlothian', 'City of Edinburgh') hbr = 'S'.
if any(HSCP_NAME, 'Perth & Kinross', 'Dundee City', 'Angus') hbr = 'T'.
if any(HSCP_NAME, 'Clackmannanshire', 'Stirling', 'Falkirk') hbr = 'V'.
if HSCP_NAME = 'Scottish Borders' hbr = 'B'.
if HSCP_NAME = 'Fife' hbr = 'F'.
if HSCP_NAME = 'Orkney' hbr = 'R'.
if HSCP_NAME = 'Western Isles' hbr = 'W'.
if HSCP_NAME = 'Dumfries & Galloway' hbr = 'Y'.
if HSCP_NAME = 'Shetland' hbr = 'Z'.
EXECUTE.

*calculate correct LFR Expenditure before matching. Original file is in 1000 so results needs to be multiplied *1000.
COMPUTE Expenditure=Expenditure * 1000.
EXECUTE.


**add age variable to LFR Client_Groups**
**judgement call taken on nominating age groups to LFR Client_Groups DC and DM November 2013.
*create variable for age groups.
*IR edited feb 2014.  going to apporiton costs for older people into 65-74, 75+ using care home and home care data.
*EP update Mar 2014. Change to LFR3 client Groups and age groups 0-18, 18-64, 65+ to match NHS data.

*STRING AGEGROUP (A5).
*do if any (Client_Group, 'Adults with other needs', 'Adults with learning disabilities', 'Adults with mental health needs', 
'Adults with physical or sensory disabilities').
*compute AGEGROUP = '18-64'.
*else if Client_Group = 'Children and Families'.
*compute AGEGROUP = '<18'.
*else if Client_Group = 'Older Persons'.
*compute AGEGROUP = '65+'.
*end if.
*execute.

STRING AGEGROUP (A5).
do if Client_Group = 'Children and Families'.
compute AGEGROUP = '<18'.
else if Client_Group = 'Older Persons'.
compute AGEGROUP = '65+'.
else.
compute AGEGROUP = '18-64'.
end if.
execute.



*aggregate to remove client group and the addtional detailed service information.  only need down to day care home care etc for output..

aggregate outfile =*
/break YEAR hbr HSCP_NAME AGEGROUP service Sector Mapname detailed_level_for_match 
/Expenditure=sum(Expenditure).

 * dataset close DataSet2.

*Make variables same length as in All_HSCPs_final (for adding files).

Alter type HSCP_NAME (a141).
Alter type AGEGROUP (a15).

* only require for comparison remove additional expenditure columns later.
*compute expenditureORG =expenditure.
*exe.
* No difference just for completeness.
*compute expenditureNEW =expenditure.
*exe.

SAVE OUTFILE =!pathname1 + 'LFR3_'+!Year+'_Master.sav'.

***********************************************************************************************************************************.
*use care home and home care activity to apportion cost to  65-74, 75-74 & 85+ to be added on to LFR 12-13 file.
***********************************************************************************************************************************.
** Change added by Euan Patterson 13/03/14 **.
** Apportionment changed so that Direct Payments and new Sub Totals for Social care can be a new lines in the output, this will align the 2011/12 & 2012/13 outputs **.
** Will still be under the sector 07_Community-Based Services but Mapname is 31-Direct Payments this means that 30-Other_Community-based services will now be 32 **.
** Need to import Shares for Direct payments and changes made to the apportionment coding as Direct Payments needs to be processed separately **.

** Home care shares - Used for all Community Based services expect Direct Payments **.
** Note this needs to be reviewed at a later time as Home care isn't the most suitable weighting for certian services within Community Based **.

********************************************************** HOME CARE *********************************************************************************************.

get file = '/conf/irf/01-CPTeam/03-Social Care/02-Activity for LFR3 Apportionment/LCA_Proportion_Shares_HomeCare_PersonalCare_2018-19.sav'.

Rename variables LCA = HSCP_NAME.
RECODE HSCP_NAME  ('Orkney Islands'='Orkney') ('Shetland Islands' = 'Shetland').
execute.

select if agegroup ge '65-74'.
execute.

* Create age group Proportion shares for Home care(HC) and Personal Care(PC).
do if Agegroup = '65-74'.
compute Proportion_Share_HC65_74 = HC_share_OP.
compute Proportion_Share_PC65_74 = PC_share_OP.
end if.
EXECUTE.

do if agegroup = '75-84'.
compute Proportion_Share_HC75_84 = HC_share_OP.
compute Proportion_Share_PC75_84 = PC_share_OP.
end if.
EXECUTE.

do if agegroup = '85+'.
compute Proportion_Share_HC85 = HC_share_OP.
compute Proportion_Share_PC85 = PC_share_OP.
end if.
EXECUTE.

aggregate outfile =*
/break HSCP_NAME
/Proportion_Share_HC65_74 Proportion_Share_PC65_74 Proportion_Share_HC75_84 Proportion_Share_PC75_84 
Proportion_Share_HC85 Proportion_Share_PC85 =sum(Proportion_Share_HC65_74 Proportion_Share_PC65_74 
Proportion_Share_HC75_84 Proportion_Share_PC75_84 Proportion_Share_HC85 Proportion_Share_PC85).
execute.

SAVE OUTFILE =!pathname1 + 'Shares_Non residential_1819.sav'.


********************************************************* DIRECT PAYMENT ******************************************************************************.

get file ='/conf/irf/01-CPTeam/03-Social Care/02-Activity for LFR3 Apportionment/LCA_Proportion_Shares_DirectPayments_2018-19.sav'.

rename variables (LCA = HSCP_NAME).

RECODE HSCP_NAME ('Argyll and Bute'='Argyll & Bute') ('Dumfries and Galloway'='Dumfries & Galloway')
('Perth and Kinross'='Perth & Kinross') ('Orkney Islands'='Orkney') ('Shetland Islands'='Shetland') ('Borders'='Scottish Borders') ('Edinburgh, City of' = 'City of Edinburgh')('Eilean Siar' = 'Western Isles').
execute.

select if agegroup ne '0-64'.
execute.

* Create age group Proportion shares.
do if agegroup = '65-74'.
compute Proportion_Share_DP65_74 = Proportion_Share_DP.
end if.
EXECUTE.

do if agegroup= '75-84'.
compute Proportion_Share_DP75_84 = Proportion_Share_DP.
end if.
EXECUTE.

do if agegroup= '85+'.
compute Proportion_Share_DP85 = Proportion_Share_DP.
end if.
EXECUTE.

aggregate outfile =*
/break HSCP_NAME
/Proportion_Share_DP65_74 Proportion_Share_DP75_84 Proportion_Share_DP85 =sum(Proportion_Share_DP65_74 Proportion_Share_DP75_84 Proportion_Share_DP85).
execute.

*Make variables same length as in All_HSCPs_final (for adding files).

alter type HSCP_NAME (A141). 

SAVE OUTFILE =!pathname1 + 'Shares_DP_1819.sav'.
EXECUTE.


*************************************************************CARE HOMES ***********************************************************************************.

get file ='/conf/irf/01-CPTeam/03-Social Care/02-Activity for LFR3 Apportionment/LCA_Proportion_Shares_CH_2018-19.sav'.

Rename variables LCA = HSCP_NAME.
RECODE HSCP_NAME  ('Orkney Islands'='Orkney') ('Shetland Islands' = 'Shetland') ('Na h-Eileanan Siar' = 'Western Isles').
execute.

select if agegroup ge '65-74'.
execute.

Alter type Proportion_Care_Home (F8.6).
execute. 

* Create age group Proportion shares.
do if agegroup = '65-74'.
compute Proportion_Share_CH65_74 = Proportion_Care_Home.
end if.
EXECUTE.

do if agegroup = '75-84'.
compute Proportion_Share_CH75_84 = Proportion_Care_Home.
end if.
EXECUTE.

do if agegroup = '85+'.
compute Proportion_Share_CH85 = Proportion_Care_Home.
end if.
EXECUTE.

aggregate outfile =*
/break HSCP_NAME
/Proportion_Share_CH65_74 Proportion_Share_CH75_84 Proportion_Share_CH85 =sum(Proportion_Share_CH65_74 Proportion_Share_CH75_84 Proportion_Share_CH85).
execute.

*Make variables same length as in All_HSCPs_final (for adding files).

Alter type HSCP_NAME (a141).

SAVE OUTFILE =!pathname1 + 'Shares_Residential_1819.sav'.
EXECUTE.


**********************************************CHECK PROPORTIONS ADD UP TO 1********************************************************.

*** Correction of approportionment shares to ensure all equal 100% ****.
* Check proportions equal 100 first then adjust 85 age group to correct total proportion to 100.

****************** Home care and personal care*************************.
get file =!pathname1 + 'Shares_Non residential_1819.sav'.
compute HC_Check = Proportion_Share_HC65_74 + Proportion_Share_HC75_84 +  Proportion_Share_HC85.
compute adjment = 1 - HC_Check. 
compute Proportion_Share_HC85 = Proportion_Share_HC85 + adjment.
compute HC_Check2 = Proportion_Share_HC65_74 + Proportion_Share_HC75_84 +  Proportion_Share_HC85.
execute.

* Personal Care.
compute PC_Check = Proportion_Share_PC65_74 + Proportion_Share_PC75_84 +  Proportion_Share_PC85.
compute adjment = 1 - PC_Check. 
compute Proportion_Share_PC85 = Proportion_Share_PC85 + adjment.
compute PC_Check2 = Proportion_Share_PC65_74 + Proportion_Share_PC75_84 +  Proportion_Share_PC85.
execute.

Alter type HSCP_NAME (A141).
execute. 

SAVE OUTFILE =!pathname1 + 'Shares_Non residential_1819.sav'
/drop HC_Check HC_Check2 PC_Check PC_Check2 adjment.
EXECUTE.

**************************** Direct Payments*****************************.
get file =!pathname1 + 'Shares_DP_1819.sav'.

compute DP_Check = Proportion_Share_DP65_74 + Proportion_Share_DP75_84 +  Proportion_Share_DP85.
compute adjment = 1 - DP_Check. 
compute Proportion_Share_DP85 = Proportion_Share_DP85 + adjment.
compute DP_Check2 = Proportion_Share_DP65_74 + Proportion_Share_DP75_84 +  Proportion_Share_DP85.
execute.

SAVE OUTFILE =!pathname1 + 'Shares_DP_1819.sav'
/drop DP_Check DP_Check2 adjment.
EXECUTE.

********************* Care homes*****************************.
Get File =!pathname1 + 'Shares_Residential_1819.sav'.
compute CH_Check = Proportion_Share_CH65_74 + Proportion_Share_CH75_84 +  Proportion_Share_CH85.
compute adjment = 1 - CH_Check. 
compute Proportion_Share_CH85 = Proportion_Share_CH85 + adjment.
compute CH_Check2 = Proportion_Share_CH65_74 + Proportion_Share_CH75_84 +  Proportion_Share_CH85.
exe.

SAVE OUTFILE =!pathname1 + 'Shares_Residential_1819.sav'
/drop CH_Check CH_Check2 adjment.
EXECUTE.

************************************************************************************************************************************************************************************.
*** Now need to apportion expenditure by the different age groups then merge files back together for the different services ***.
*** 65-74 age group ***.
****************************************HOME CARE AND PERSONAL CARE 65-74****************************************************************************************

GET FILE =!pathname1 + 'LFR3_'+!Year+'_Master.sav'.

*select out older people client group to carry out apportionment.

select if agegroup='65+'.
EXECUTE.

* Now also need to select out Direct Payments*.
select if sector ne '06-Accommodation-based services'.
select if mapname ne '32-Direct Payments'.
execute.

*aggregate to allow apportionment for the aggregated expenditure groups that are to be included in output.

Aggregate outfile =*
/break Year hbr HSCP_NAME AGEGROUP service sector mapname detailed_level_for_match 
/Expenditure=sum(Expenditure).
execute.

sort cases by HSCP_NAME.
EXECUTE.

match files file =*
/table=!pathname1 + 'Shares_Non residential_1819.sav'
/by HSCP_NAME.
execute.

*******This is the old way which doesn't consider personal care which I think will be unsuitable************
*now calculate 65-74 proportion.
* Standard approach from 11-12 - Apportioned based on Home care activity only.
*compute expenditureORG =expenditure * Proportion_Share_HC65_74.
*exe.

**************************************************************************************************************************************************************************
Alison McClelland - for 2013/14 how should we be apportioning "Managed Personalised Budgets (SDS2)" - should this be apportioned here?
**************************************************************************************************************************************************************************

* New approach using HC & PC activity.
do if detailed_level_for_match = 'Home Care - Free Personal Care (aged 65+)'.
compute expenditure =expenditure * Proportion_Share_PC65_74.
else if detailed_level_for_match ne 'Home Care - Free Personal Care (aged 65+)'.
compute expenditure =expenditure * Proportion_Share_HC65_74.
end if.
EXECUTE.

compute agegroup ='65-74'.
execute.

SAVE OUTFILE =!pathname1 + 'LFR3_'+!Year+'_6574_non_residential_ExDP.sav'.


***************************DIRECT PAYMENTS 65-74***********************************.
*. repeat for Direct Payments based using Direct Payments age proportions.

GET FILE =!pathname1 + 'LFR3_'+!Year+'_Master.sav'.

*select out older peple client group to carry out apportionment.

select if agegroup='65+'.
EXECUTE.
* Now also need to select out Direct Payments*.
select if sector ne '06-Accommodation-based services'.
select if mapname = '32-Direct Payments'.
execute.

***West Lothian has not recorded any Direct Payment expenditure [Excel file?]***.

*aggregate to allow apportionment for the aggregated expenditure groups that are to be included in output.

Aggregate outfile =*
/break Year hbr HSCP_NAME AGEGROUP service sector mapname detailed_level_for_match 
/Expenditure=sum(Expenditure).
execute.

sort cases by HSCP_NAME.

match files file =*
/table=!pathname1 + 'Shares_DP_1819.sav'
/by HSCP_NAME.
execute.

*now calculate 65-74 proportion.
** Warning Check how many HSCPs have recorded DP expenditure on the LFR3 *. 
** In 2013/14 there is 1 who did recorded expenditure but activity is reported in the SG publication, may need to consider how to adjust for this issue **. 
compute expenditure =expenditure * Proportion_Share_DP65_74.
execute.

compute agegroup ='65-74'.
execute.

SAVE OUTFILE =!pathname1 + 'LFR3_'+!Year+'_6574_non_residential_DP.sav'.


****************************************************** CARE HOMES 65-74*************************************************************.

GET FILE =!pathname1 + 'LFR3_'+!Year+'_Master.sav'.

*select out older peple client group to carry out apportionment.

select if agegroup='65+'.
EXECUTE.

select if sector eq '06-Accommodation-based services'.
execute.

*aggregate to allow apportionment for the aggregated expenditure groups that are to be included in output.

Aggregate outfile =*
/break Year hbr HSCP_NAME AGEGROUP service sector mapname detailed_level_for_match 
/Expenditure=sum(Expenditure).
execute.

sort cases by HSCP_NAME.

match files file =*
/table=!pathname1 + 'Shares_Residential_1819.sav'
/by HSCP_NAME.
execute.

compute expenditure=expenditure * Proportion_Share_CH65_74.
EXECUTE.

compute agegroup='65-74'.
EXECUTE.

SAVE OUTFILE =!pathname1 + 'LFR3_'+!Year+'_6574_residential.sav'.

***************************************************NEXT AGEGROUP 75-84 ***************************************************************************.
*********************************************HOME CARE AND PERSONAL CARE 75-84************************************************************.

GET FILE =!pathname1 + 'LFR3_'+!Year+'_Master.sav'.

*select out older people client group to carry out apportionment.

select if agegroup='65+'.
EXECUTE.

* Now also need to select out Direct Payments*.
select if sector ne '06-Accommodation-based services'.
select if mapname ne '32-Direct Payments'.
execute.

*aggregate to allow apportionment for the aggregated expenditure groups that are to be included in output.

Aggregate outfile =*
/break Year hbr HSCP_NAME AGEGROUP service sector mapname detailed_level_for_match 
/Expenditure=sum(Expenditure).
execute.

sort cases by HSCP_NAME.

match files file =*
/table=!pathname1 + 'Shares_Non residential_1819.sav'
/by HSCP_NAME.
execute.

*now calculate 75-84 proportion.
********OLD METHOD******.
* Standard approach from 11-12 - Apportioned based on Home care activity only.
*compute expenditure =expenditure * Proportion_Share_HC75_84.
*exe.

* New approach using HC & PC activity.
do if detailed_level_for_match = 'Home Care - Free Personal Care (aged 65+)'.
compute expenditure =expenditure * Proportion_Share_PC75_84.
else if detailed_level_for_match ne 'Home Care - Free Personal Care (aged 65+)'.
compute expenditure =expenditure * Proportion_Share_HC75_84.
end if.
EXECUTE.

compute agegroup ='75-84'.
execute.

SAVE OUTFILE =!pathname1 + 'LFR3_'+!Year+'_7584_non_residential_ExDP.sav'.


***********************DIRECT PAYMENTS 75-84************************
. repeat for Direct Payments based using Direct Payments age proportions.

GET FILE =!pathname1 + 'LFR3_'+!Year+'_Master.sav'.

*select out older peple client group to carry out apportionment.

select if agegroup='65+'.
EXECUTE.
* Now also need to select out Direct Payments*.
select if sector ne '06-Accommodation-based services'.
select if mapname = '32-Direct Payments'.
execute.

*aggregate to allow apportionment for the aggregated expenditure groups that are to be included in output.

Aggregate outfile =*
/break Year hbr HSCP_NAME AGEGROUP service sector mapname detailed_level_for_match 
/Expenditure=sum(Expenditure).
execute.

sort cases by HSCP_NAME.

match files file =*
/table=!pathname1 + 'Shares_DP_1819.sav'
/by HSCP_NAME.
execute.

*now calculate 65-74 proportion.
** Warning Check how many HSCPs have recorded DP expenditure on the LFR3 *. 
** In 2013/14 there is 1 who did recorded expenditure but activity is reported in the SG publication, may need to consider how to adjust for this issue **. 
*compute expenditureORG =expenditure * Proportion_Share_DP75_84.
*exe.
* No difference just for completeness.
compute expenditure =expenditure * Proportion_Share_DP75_84.
EXECUTE.

compute agegroup ='75-84'.
execute.

SAVE OUTFILE =!pathname1 + 'LFR3_'+!Year+'_7584_non_residential_DP.sav'.


************************************************** CARE HOMES 75-84 **********************************************.


GET FILE =!pathname1 + 'LFR3_'+!Year+'_Master.sav'.

*select out older peple client group to carry out apportionment.

select if agegroup='65+'.
EXECUTE.

select if sector eq '06-Accommodation-based services'.
execute.

*aggregate to allow apportionment for the aggregated expenditure groups that are to be included in output.

Aggregate outfile =*
/break Year hbr HSCP_NAME AGEGROUP service sector mapname detailed_level_for_match 
/Expenditure=sum(Expenditure).
execute.

sort cases by HSCP_NAME.

match files file =*
/table=!pathname1 + 'Shares_Residential_1819.sav'
/by HSCP_NAME.
execute.

*now calculate 75-84 proportion.
*compute expenditureORG =expenditure * Proportion_Share_CH75_84.
*exe.
* No difference just for completeness.
compute expenditure =expenditure * Proportion_Share_CH75_84.
EXECUTE.

compute agegroup='75-84'.
EXECUTE.

SAVE OUTFILE =!pathname1 + 'LFR3_'+!Year+'_7584_residential.sav'.

*************************************************NEXT AGEGROUP  85+ *****************************************************.
****************************************HOME CARE AND PERSONAL CARE 85+*****************************************.

GET FILE =!pathname1 + 'LFR3_'+!Year+'_Master.sav'.

*select out older people client group to carry out apportionment.

select if agegroup='65+'.
EXECUTE.

* Now also need to select out Direct Payments*.
select if sector ne '06-Accommodation-based services'.
select if mapname ne '32-Direct Payments'.
execute.

*aggregate to allow apportionment for the aggregated expenditure groups that are to be included in output.

Aggregate outfile =*
/break Year hbr HSCP_NAME AGEGROUP service sector mapname detailed_level_for_match 
/Expenditure=sum(Expenditure).
execute.

sort cases by HSCP_NAME.

match files file =*
/table=!pathname1 + 'Shares_Non residential_1819.sav'
/by HSCP_NAME.
execute.

*now calculate 85+ proportion.
********OLD METHOD*******
* Standard approach from 11-12 - Apportioned based on Home care activity only.
*compute expenditure =expenditure * Proportion_Share_HC85.
*exe.

* New approach using HC & PC activity.
do if detailed_level_for_match = 'Home Care - Free Personal Care (aged 65+)'.
compute expenditure =expenditure * Proportion_Share_PC85.
else if detailed_level_for_match ne 'Home Care - Free Personal Care (aged 65+)'.
compute expenditure =expenditure * Proportion_Share_HC85.
end if.
EXECUTE.

compute agegroup ='85+'.
execute.

SAVE OUTFILE =!pathname1 + 'LFR3_'+!Year+'_85_non_residential_ExDP.sav'.


***********************************************DIRECT PAYMENTS 85+************************************************************************
. repeat for Direct Payments based using Direct Payments age proportions.

GET FILE =!pathname1 + 'LFR3_'+!Year+'_Master.sav'.

*select out older peple client group to carry out apportionment.

select if agegroup='65+'.
EXECUTE.
* Now also need to select out Direct Payments*.
select if sector ne '06-Accommodation-based services'.
select if mapname = '32-Direct Payments'.
execute.

*aggregate to allow apportionment for the aggregated expenditure groups that are to be included in output.

Aggregate outfile =*
/break Year hbr HSCP_NAME AGEGROUP service sector mapname detailed_level_for_match 
/Expenditure=sum(Expenditure).
execute.

sort cases by HSCP_NAME.

match files file =*
/table=!pathname1 + 'Shares_DP_1819.sav'
/by HSCP_NAME.
execute.

*now calculate 85+ proportion.
** Warning Check how many HSCPs have recorded DP expenditure on the LFR3 *. 
** In 2013/14 there is 1 who did recorded expenditure but activity is reported in the SG publication, may need to consider how to adjust for this issue **. 
*compute expenditureORG =expenditure * Proportion_Share_DP85.
*exe.
* No difference just for completeness.
compute expenditure =expenditure * Proportion_Share_DP85.
EXECUTE.

compute agegroup ='85+'.
execute.

SAVE OUTFILE =!pathname1 + 'LFR3_'+!Year+'_85_non_residential_DP.sav'.


*********************************************** CARE HOMES  85+******************************************************.


GET FILE =!pathname1 + 'LFR3_'+!Year+'_Master.sav'.

*select out older peple client group to carry out apportionment.

select if agegroup='65+'.
EXECUTE.

select if sector eq '06-Accommodation-based services'.
execute.

*aggregate to allow apportionment for the aggregated expenditure groups that are to be included in output.

Aggregate outfile =*
/break Year hbr HSCP_NAME AGEGROUP service sector mapname detailed_level_for_match 
/Expenditure=sum(Expenditure).
execute.

sort cases by HSCP_NAME.

match files file =*
/table=!pathname1 + 'Shares_Residential_1819.sav'
/by HSCP_NAME.
execute.

*now calculate 85+ proportion.
*compute expenditureORG =expenditure * Proportion_Share_CH85.
*exe.
* No difference just for completeness.
compute expenditure =expenditure * Proportion_Share_CH85.
EXECUTE.

compute agegroup='85+'.
EXECUTE.

SAVE OUTFILE =!pathname1 + 'LFR3_'+!Year+'_85_residential.sav'.

************************CREATE ALL AGES TOTAL***************************.

GET FILE =!pathname1 + 'LFR3_'+!Year+'_Master.sav'.

compute agegroup='All'.
execute.

*compute expenditureORG =expenditure.
*exe.
* No difference just for completeness.
*compute expenditureNEW =expenditure.
*exe.

SAVE OUTFILE =!pathname1 + 'LFR3_'+!Year+'_AllAge.sav'.

**combine LFR and the age group files - residential and non residential.
add files file=!pathname1 + 'LFR3_'+!Year+'_Master.sav'
/file=!pathname1 + 'LFR3_'+!Year+'_6574_non_residential_ExDP.sav'
/file=!pathname1 + 'LFR3_'+!Year+'_6574_non_residential_DP.sav'
/file=!pathname1 + 'LFR3_'+!Year+'_6574_residential.sav'
/file=!pathname1 + 'LFR3_'+!Year+'_7584_non_residential_ExDP.sav'
/file=!pathname1 + 'LFR3_'+!Year+'_7584_non_residential_DP.sav'
/file=!pathname1 + 'LFR3_'+!Year+'_7584_residential.sav'
/file=!pathname1 + 'LFR3_'+!Year+'_85_non_residential_ExDP.sav'
/file=!pathname1 + 'LFR3_'+!Year+'_85_non_residential_DP.sav'
/file=!pathname1 + 'LFR3_'+!Year+'_85_residential.sav'
/file=!pathname1 + 'LFR3_'+!Year+'_AllAge.sav'.
execute.

*Aggregate outfile =*
*/break Year hbr HSCP_NAME AGEGROUP service sector mapname detailed_level_for_match 
*/ExpenditureORG ExpenditureNEW =sum(ExpenditureORG ExpenditureNEW).
*EXECUTE.

Aggregate outfile =*
/break Year hbr HSCP_NAME AGEGROUP service sector mapname detailed_level_for_match 
/Expenditure =sum(Expenditure).
EXECUTE.

SAVE OUTFILE =!pathname1 + 'LFR3_'+!Year+'_T1.sav'.

*create HB totals for output.

aggregate outfile=*
/BREAK Year hbr AGEGROUP service sector mapname detailed_level_for_match 
/Expenditure=sum(Expenditure).
execute.

string HSCP_NAME (a141).
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
execute.


SAVE OUTFILE =!pathname1 + 'LFR3_'+!Year+'_T2.sav'
/keep Year hbr HSCP_NAME AGEGROUP service sector mapname detailed_level_for_match Expenditure.

*combine with HB total file.

add files file =!pathname1 + 'LFR3_'+!Year+'_T2.sav'
/file =!pathname1 + 'LFR3_'+!Year+'_T1.sav'.
execute.

select if agegroup NE '65+'.
EXECUTE.

SAVE OUTFILE =!pathname1 + 'LFR3_'+!Year+'_T3.sav'
/keep Year hbr HSCP_NAME AGEGROUP service sector mapname detailed_level_for_match Expenditure.

* Added Feb 2016 by EP **.
* Need to change Service, sector and mapname so that names are more suitable for Tableau..
GET FILE =!pathname1 + 'LFR3_'+!Year+'_T3.sav'.

*Service.
compute service = "Social Care".
EXECUTE.

* Sector.
if Sector = '06-Accommodation-based services' Sector = 'Accommodation based services'.
if Sector = '07-Community-based services' Sector = 'Community based services'.
EXECUTE.

*mapname.
if mapname = '27-Care Homes' mapname = 'Care homes'.
if mapname= '28-Other-Accommodation-based service' mapname = 'Other'.
if mapname = '30-Home Care' mapname = 'Home Care'.
if mapname = '31-Day Care' mapname= 'Day Care'.
if mapname = '32-Direct Payments' mapname = 'Direct Payments'.
if mapname = '33-Other-Community-based service' mapname = 'Other'.
EXECUTE.

RENAME VARIABLES (mapname = Sub_Sector).
alter type Sub_Sector (a41).

SAVE OUTFILE =!pathname3 + 'LFR3_'+!Year+'_Final.sav'.

 *   get file = !pathname3 + 'LFR3_'+!Year+'_Final.sav'.

