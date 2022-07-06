* Encoding: UTF-8.
*This is the same program as 'Dashboard Syntax.sps' just without the commented-out syntax which was only relevant for 1718.
*DC 18/02/21.

*UPDATE 11/05/21 - HAVE RE-RUN TO LN828 (creating Lookup variable).
*Further fixes from feedback still to be made - will pick up asap. DC 11/05/21.


DEFINE !Outfile()
    '/conf/sourcedev/TableauUpdates/Social Care/Outputs/201819/SocialCare_1819.sav'
!ENDDEFINE.

*******************************************************************************************************************************************************.
*VARIABLE RENAMING / FORMATTING

*******************************************************************************************************************************************************.
get file = '/conf/sourcedev/TableauUpdates/Social Care/Outputs/201819/all_outputs_merged_Mar21_final.zsav'.
dataset name Mar21 window = front.

freq var Type.
if Type='People and services' Type='People and Services'.
if Type='Service usage' Type='Service Usage'.
if Type='Total clients' Type='Total Clients'.
if Type='Urban rural split' Type='Urban Rural split'.
if Type='Total Residents Locality Rate' Type='Locality Rate'.
execute.


freq var File.
alter type File (a30).
if File='CH' File='Care Home'.
if File='HC' File='Home Care'.
if File='EQ' File='Equipment'.
if File='SD' FIle='Self Directed Support'.
if File='SDS' File='Self Directed Support'.
execute.


freq var Sex.
alter type SEX (a15).
if SEX='0' SEX='Not Known'.
if SEX='Unknow' SEX='Not Known'.
if SEX='9' SEX='Not Specified'.
if SEX = 'Not Kn' SEX = 'Not Known'.
execute.


freq var LivingAlone.
alter type LivingAlone (a20).
compute LivingAlone=LTRIM(LivingAlone).
execute.

if LivingAlone='0' LivingAlone='No'.
if LivingAlone='1' LivingAlone='Yes'.
if LivingAlone='9' LivingAlone='Unknown'.
execute.

alter type period (a10).
if period='' period='2018/19'.
if period='2018' period='2018/19'.
if period='2018Q1' period='2018/19 Q1'.
if period='2018Q2' period='2018/19 Q2'.
if period='2018Q3' period='2018/19 Q3'.
if period='2018Q4' period='2018/19 Q4'.
execute.

IF Age_Band = "<65" Age_Band = "0-64".
IF Age_Band = "All ages" Age_Band = "All Ages".
EXECUTE.

IF hours_band = " < 2 hours" Hours_Band = "0 to 2 hours".
IF hours_band = "<2 hours" Hours_Band = "0 to 2 hours".
IF hours_band = "10+ hours" Hours_Band = "10 hours +".
IF hours_band = "2 to less than 4 hours" Hours_Band = "2 to 4 hours".
IF hours_band = "4 to less than 10 hours" Hours_Band = "4 to 10 hours".
EXECUTE.

*Update service type names for improved wording on display in dashboards.
alter type Servicetype (a50).
if Servicetype='both' Servicetype='Both'.
if Servicetype='All services' Servicetype='Total Community Alarms and Telecare'.
execute.

 * rename variables Breakdown=breakdown_2.
 * rename variables Breakdown_type=breakdown_type_2.
rename variables SEX=Sex.
rename variables ServiceType=Servicetype. 

**************************************************************************.
*Update numeric variables to 1 decimal place for dislpay on workbooks.
alter type Numerator (f8.1).
alter type Denominator (f8.1).
alter type Rate (f8.1).
*alter type perc (f8.1).
alter type NetCost (f8.1).
alter type GrossCost (f8.1).
alter type OOHAdvice (f8.1).
alter type OOHHomeV (f8.1).
alter type OOHPCC (f8.1).

***********************************************UPDATE based on Ag feedback for CH. 22/02/21**********************************************.
*Can't find what the update was (if any).
*Note that diag variable valid where Type = 'Emergency Admission Reason' and 'EA_Reason_top5'.
*These appear in Unscheduled Care 2 dashboard, chart 2.
*However, there is also an existing diagdescript variable......this was for old Emergency Admission Reason Type, which has now
been dropped and replaced with EA_Reason_top5 - for which diagdescript is blank, so can rename. DC 040321.
freq var diagdescript.
delete variables diagdescript.
rename variables diag=diagdescript.
*Syntax 11 updated to do this in future. DC 040321.


if sending_location='Western Isles' sending_location='Comhairle nan Eilean Siar'.
if sending_location='Shetland' sending_location='Shetland Islands'.
if sending_location='Borders' sending_location='Scottish Borders'.
execute.

*Change partnership locality names to include HSCP on to the end of the name.
freq var Locality.
*This stage was also completed by the social care team for 2018/19.
 * get file = !Outfile.
 * if sending_location='Borders' sending_location='Scottish Borders'.
 * execute.
 * if Locality='Aberdeen City' Locality='Aberdeen City HSCP'.
 * if Locality='Aberdeenshire' Locality='Aberdeenshire HSCP'.
 * if Locality='Angus' Locality='Angus HSCP'.
 * if Locality='Argyll & Bute' Locality='Argyll & Bute HSCP'.
 * if Locality='Borders' Locality='Scottish Borders HSCP'.
 * if Locality='Clackmannanshire' Locality='Clackmannanshire HSCP'.
 * if Locality='Dumfries & Galloway' Locality='Dumfries & Galloway HSCP'.
 * if Locality='Dundee City' Locality='Dundee City HSCP'.
 * if Locality='East Ayrshire' Locality='East Ayrshire HSCP'.
 * if Locality='East Dunbartonshire' Locality='East Dunbartonshire HSCP'.
 * if Locality='East Lothian' Locality='East Lothian HSCP'.
 * if Locality='East Renfrewshire' Locality='East Renfrewshire HSCP'.
 * if Locality='Edinburgh City' Locality='Edinburgh City HSCP'.
 * if Locality='Falkirk' Locality='Falkirk HSCP'.
 * if Locality='Fife' Locality='Fife HSCP'.
 * if Locality='Highland' Locality='Highland HSCP'.
 * if Locality='Inverclyde' Locality='Inverclyde HSCP'.
 * if Locality='Midlothian' Locality='Midlothian HSCP'.
 * if Locality='Moray' Locality='Moray HSCP'.
 * if Locality='North Ayrshire' Locality='North Ayrshire HSCP'.
 * if Locality='North Lanarkshire' Locality='North Lanarkshire HSCP'.
 * if Locality='Orkney HSCP' Locality='Orkney Islands HSCP'.
 * if Locality='Orkney Islands' Locality='Orkney Islands HSCP'.
 * if Locality='Outside partnership' Locality='Outside Partnership'.
 * if Locality='Perth & Kinross' Locality='Perth & Kinross HSCP'.
 * if Locality='Renfrewshire' Locality='Renfrewshire HSCP'.
 * if Locality='Shetland' Locality='Shetland HSCP'.
 * if Locality='South Ayrshire' Locality='South Ayrshire HSCP'.
 * if Locality='South Lanarkshire' Locality='South Lanarkshire HSCP'.
 * if Locality='Stirling' Locality='Stirling HSCP'.
 * if Locality='West Dunbartonshire' Locality='West Dunbartonshire HSCP'.
 * if Locality='West Lothian' Locality='West Lothian HSCP'.
 * if Locality='Western Isles' Locality='Western Isles HSCP'.
 * execute.

save outfile = '/conf/sourcedev/TableauUpdates/Social Care/Outputs/201819/all_outputs_merged_updated.zsav'.

*******************************************************************************************************************************************************.
*CARE HOME 

*******************************************************************************************************************************************************.
GET
  FILE='/conf/sourcedev/TableauUpdates/Social Care/Outputs/201819/all_outputs_merged_updated.zsav'.
DATASET NAME SocialCareMaster WINDOW=FRONT.


*NAME UPDATE (WHERE NOT SUBMITTED).
**************************************************.
*Only codes provided as care home names for below partnerships, so make care home name equal to locality to display data on charts.
*For West Lothian, some proper care home names were provided, as well as codes, 
the codes were manually deleted and when displayed as blank, inserted with locality name.
if File='Care Home' and sending_location='Aberdeen City' CareHomeName=Locality.
if File='Care Home' and sending_location='West Lothian' and CareHomeName='' CareHomeName=Locality.
execute.


*CARE HOME NAMES - MANUAL UPDATE.
**************************************************.
if CareHomeName="Abbotsford Care E. Wemyss" CareHomeName="Abbotsford Care E.Wemyss".
if CareHomeName="Acad (Annie'S Cottage)" CareHomeName="Acad (Annie's Cottage)".
if CareHomeName="Alexander Scott'S Hospital" CareHomeName="Alexander Scott's Hospital".
if CareHomeName="Alt- Na - Craig" CareHomeName="Alt-Na-Craig".
if CareHomeName="Alt- Na - Craig House" CareHomeName="Alt-Na-Craig House".
if CareHomeName="Anderson'S" CareHomeName="Anderson's".
if CareHomeName="Anderson'S Care Home" CareHomeName="Anderson's Care Home".
if CareHomeName="Balhousie St Ronan'S Care Home" CareHomeName="Balhousie St Ronan's Care Home".
if CareHomeName="Earlsferry House -" CareHomeName="Earlsferry House".
if CareHomeName="Jenny'S Well" CareHomeName="Jenny's Well".
if CareHomeName="Jenny'S Well (Royal Blind)" CareHomeName="Jenny's Well (Royal Blind)".
if CareHomeName="Jenny'S Well Care Home" CareHomeName="Jenny's Well Care Home".
if CareHomeName="Quarrier'S Homes" CareHomeName="Quarrier's Homes".
if CareHomeName="Quarrier`S Homes" CareHomeName="Quarrier's Homes".
if CareHomeName="Queen'S Bay Lodge" CareHomeName="Queen's Bay Lodge".
if CareHomeName="Sir Gabriel Wood'S Mariner'S Home" CareHomeName="Sir Gabriel Wood's Mariner's Home".
if CareHomeName="Sir Gabriel Woods Mariners Hom" CareHomeName="Sir Gabriel Wood's Mariners Home".
if CareHomeName="Sir Gabriel Wood'S Mariners Home" CareHomeName="Sir Gabriel Wood's Mariners Home".
if CareHomeName="Sir Jameas Mckay House" CareHomeName="Sir James Mckay House".
if CareHomeName="St Anne'S Care Home" CareHomeName="St Anne's Care Home".
if CareHomeName="St Catherine'S" CareHomeName="St Catherine's".
if CareHomeName="St Catherine'S Care Home" CareHomeName="St Catherine's Care Home".
if CareHomeName="St Clare'S Care Home" CareHomeName="St Clare's Care Home".
if CareHomeName="St Columba'S" CareHomeName="St Columba's".
if CareHomeName="St David'S Care Home" CareHomeName="St David's Care Home".
if CareHomeName="St David'S Residential Home" CareHomeName="St David's Residential Home".
if CareHomeName="St David`S Residential Home" CareHomeName="St David's Residential Home".
if CareHomeName="St John'S Residential Home" CareHomeName="St John's Residential Home".
if CareHomeName="St Joseph'S" CareHomeName="St Joseph's".
if CareHomeName="St Joseph'S Care Home" CareHomeName="St Joseph's Care Home".
if CareHomeName="St Joseph'S House" CareHomeName="St Joseph's House".
if CareHomeName="St Joseph'S - New Lodge" CareHomeName="St Joseph's - New Lodge".
if CareHomeName="St Joseph'S Nursing Home" CareHomeName="St Joseph's Nursing Home".
if CareHomeName="St Joseph'S Service - New Lodge" CareHomeName="St Joseph's Service - New Lodge".
if CareHomeName="St Joseph'S Services - New Lodge" CareHomeName="St Joseph's Services - New Lodge".
if CareHomeName="St Margaret'S" CareHomeName="St Margaret's".
if CareHomeName="St Margaret'S (C Of S)" CareHomeName="St Margaret's (C Of S)".
if CareHomeName="St Margaret'S C Of S" CareHomeName="St Margaret's C Of S".
if CareHomeName="St Margaret'S Care Home" CareHomeName="St Margaret's Care Home".
if CareHomeName="St Margaret'S Care Home Edinburgh" CareHomeName="St Margaret's Care Home Edinburgh".
if CareHomeName="St Margaret'S Care Home (Edinburgh)" CareHomeName="St Margaret's Care Home (Edinburgh)".
if CareHomeName="St Margaret'S Home" CareHomeName="St Margaret's Home".
if CareHomeName="St Margaret'S Home (Hawick)" CareHomeName="St Margaret's Home (Hawick)".
if CareHomeName="St Mary'S Care Home" CareHomeName="St Mary's Care Home".
if CareHomeName="St Ninian'S Care Home" CareHomeName="St Ninian's Care Home".
if CareHomeName="St Ninian`S Care Home" CareHomeName="St Ninian's Care Home".
if CareHomeName="St Olaf'S" CareHomeName="St Olaf's".
if CareHomeName="St Peter'S House" CareHomeName="St Peter's House".
if CareHomeName="St Raphael'S Care Home" CareHomeName="St Raphael's Care Home".
if CareHomeName="St Raphael'S Home" CareHomeName="St Raphael's Home".
if CareHomeName="St Raphael'S Nursing Home" CareHomeName="St Raphael's Nursing Home".
if CareHomeName="St Ronan'S Residential Home" CareHomeName="St Ronan's Residential Home".
if CareHomeName="St Ronan'S Care Home" CareHomeName="St Ronan's Care Home".
if CareHomeName="St Ronan'S Care Home Dundee" CareHomeName="St Ronan's Care Home Dundee".
if CareHomeName="St Serf'S Care Home" CareHomeName="St Serf's Care Home".
if CareHomeName="St Serf'S Residential Home" CareHomeName="St Serf's Residential Home".
if CareHomeName="St. Mary'S Care Home" CareHomeName="St. Mary's Care Home".
if CareHomeName="St. Raphael'S Care Home" CareHomeName="St. Raphael's Care Home".
if CareHomeName="Upper St Mungo'S Wynd" CareHomeName="Upper St Mungo's Wynd".
if CareHomeName="William Simpson'S" CareHomeName="William Simpson's".
if CareHomeName="William Simpson'S Home" CareHomeName="William Simpson's Home".
execute.

sort cases by File (a) sending_location (a) CareHomeName (a).

save outfile = '/conf/sourcedev/TableauUpdates/Social Care/Outputs/201819/all_outputs_merged_updated.zsav'
/ZCOMPRESSED.


*CARE HOME - CREATE 'Outside Partnership' where Locality = blank.
***************************************************************************.

***********************************************UPDATE based on Ag feedback for CH. 22/02/21**********************************************.
*This stage was completed by the social care team for 2018/19.
*EXCEPT FOR CH, WHERE LOCALITY IS BLANK - NEED TO COPY LOCALITY_CH INTO LOCALITY THEN RUN BELOW.
*DC 18/02/21.
*DONE IN ANALYST SYNTAX. DC 040321.

 * Do if File = 'CH' and Locality = ''.
 * compute Locality = Locality_CH.
 * end if.
 * execute.

 * if sending_location='Aberdeen City' and Locality ne 'Aberdeen City' and Locality ne '' and Locality ne 'Aberdeen North' and Locality ne 'Aberdeen Central' and Locality ne 'Aberdeen South' and Locality ne 'Aberdeen West' Locality='Outside Partnership'.
 * if sending_location='Aberdeenshire' and Locality ne 'Aberdeenshire HSCP' and Locality ne '' and Locality ne 'Banff & Buchan' and Locality ne 'Buchan' and Locality ne 'Formartine' and 
Locality ne 'Garioch' and Locality ne 'Kincardine & Mearns' and Locality ne 'Marr' Locality='Outside Partnership'.
 * if sending_location='Angus' and Locality ne 'Angus' and Locality ne '' and Locality ne 'Angus North East' and Locality ne 'Angus North West' and Locality ne 'Angus South East' and Locality ne 'Angus South West' Locality='Outside Partnership'.
 * if sending_location='Argyll & Bute' and Locality ne 'Argyll & Bute' and Locality ne '' and Locality ne 'Bute' and Locality ne 'Helensburgh and Lomond' and Locality ne 'Islay Jura and Colonsay' and Locality ne 'Kintyre' and Locality ne 'Mid Argyll' and
Locality ne 'Mull Iona Coll and Tiree' and Locality ne 'Oban and Lorn' Locality='Outside Partnership'.
 * if sending_location='Borders' and Locality ne 'Borders' and Locality ne '' and Locality ne 'Berwickshire' and Locality ne 'Cheviot' and Locality ne 'Eildon' and 
Locality ne 'Teviot and Liddesdale' and Locality ne 'Tweeddale' Locality='Outside Partnership'.
 * if sending_location='Clackmannanshire' and Locality ne 'Clackmannanshire' and Locality ne '' Locality='Outside Partnership'.
 * if sending_location='Dumfries & Galloway' and Locality ne 'Dumfries & Galloway' and Locality ne '' and Locality ne 'Annandale & Eskdale' and Locality ne 'Nithsdale' and Locality ne 'Stewartry' and
Locality ne 'Wigtownshire' Locality='Outside Partnership'.
 * if sending_location='Dundee City' and Locality ne 'Dundee City' and Locality ne '' and Locality ne 'Coldside' and Locality ne 'Dundee East End' and Locality ne 'Dundee North East' and
Locality ne 'Dundee West End' and Locality ne 'Lochee' and Locality ne 'Maryfield' and Locality ne 'Strathmartine' and Locality ne 'The Ferry' Locality='Outside Partnership'.
 * if sending_location='East Ayrshire' and Locality ne 'East Ayrshire' and Locality ne '' and Locality ne 'Kilmarnock' and Locality ne 'Northern' and Locality ne 'Southern' Locality='Outside Partnership'.
 * if sending_location='East Dunbartonshire' and Locality ne 'East Dunbartonshire' and Locality ne '' and Locality ne 'East Dunbartonshire East' and Locality ne 'East Dunbartonshire West' Locality='Outside Partnership'.
 * if sending_location='East Lothian' and Locality ne 'East Lothian' and Locality ne '' and Locality ne 'East Lothian East' and Locality ne 'East Lothian West' Locality='Outside Partnership'.
 * if sending_location='East Renfrewshire' and Locality ne 'East Renfrewshire' and Locality ne '' and Locality ne 'Barrhead' and Locality ne 'Eastwood' Locality='Outside Partnership'.
 * if sending_location='Edinburgh City' and Locality ne 'Edinburgh City' and Locality ne '' and Locality ne 'Edinburgh North East' and Locality ne 'Edinburgh North West' and Locality ne 'Edinburgh South East' and
Locality ne 'Edinburgh South West' Locality='Outside Partnership'.
 * if sending_location='Falkirk' and Locality ne 'Falkirk' and Locality ne '' and Locality ne 'Falkirk Central' and Locality ne 'Falkirk East' and Locality ne 'Falkirk West' Locality='Outside Partnership'.
 * if sending_location='Fife' and Locality ne 'Fife' and Locality ne '' and Locality ne 'City of Dunfermline' and Locality ne 'Cowdenbeath' and Locality ne 'Glenrothes' and Locality ne 'Kirkcaldy' and
Locality ne 'Levenmouth' and Locality ne 'North East Fife' and Locality ne 'South West Fife' Locality='Outside Partnership'.
 * if sending_location='Glasgow City' and Locality ne 'Glasgow City' and Locality ne '' and Locality ne 'Glasgow North East' and Locality ne 'Glasgow North West' and Locality ne 'Glasgow South' Locality='Outside Partnership'.
 * if sending_location='Highland' and Locality ne 'Highland' and Locality ne '' and Locality ne 'Badenoch and Strathspey' and Locality ne 'Caithness' and Locality ne 'East Ross' and Locality ne 'Inverness' and Locality ne 'Lochaber' and 
Locality ne 'Mid Ross' and Locality ne 'Nairn & Nairnshire' and Locality ne 'Skye, Lochalsh and West Ross' and Locality ne 'Sutherland' Locality='Outside Partnership'.
 * if sending_location='Inverclyde' and Locality ne 'Inverclyde' and Locality ne '' and Locality ne 'Inverclyde Central' and Locality ne 'Inverclyde East' and Locality ne 'Inverclyde West' Locality='Outside Partnership'.
 * if sending_location='Midlothian' and Locality ne 'Midlothian' and Locality ne '' and Locality ne 'Midlothian (East)' and Locality ne 'Midlothian (West)' Locality='Outside Partnership'.
 * if sending_location='Moray' and Locality ne 'Moray' and Locality ne '' and Locality ne 'Moray East' and Locality ne 'Moray West' Locality='Outside Partnership'.
 * if sending_location='North Ayrshire' and Locality ne 'North Ayrshire' and Locality ne '' and Locality ne 'Arran' and Locality ne 'Garnock Valley' and Locality ne 'Irvine' and Locality ne 'Kilwinning' and 
Locality ne 'North Coast & Cumbraes' and Locality ne 'Three Towns' Locality='Outside Partnership'.
 * if sending_location='North Lanarkshire' and Locality ne 'North Lanarkshire' and Locality ne '' and Locality ne 'Airdrie' and Locality ne 'Bellshill' and Locality ne 'Coatbridge' and Locality ne 'Motherwell' and 
Locality ne 'North Lanarkshire North' and Locality ne 'Wishaw' Locality='Outside Partnership'.
 * if sending_location='Orkney' and Locality ne 'Orkney' and Locality ne '' and Locality ne 'Isles' and Locality ne 'Orkney East' and Locality ne 'Orkney West' Locality='Outside Partnership'.
 * if sending_location='Perth & Kinross' and Locality ne 'Perth & Kinross' and Locality ne '' and Locality ne 'North Perthshire' and Locality ne 'Perth City' and Locality ne 'South Perthshire' Locality='Outside Partnership'.
 * if sending_location='Renfrewshire' and Locality ne 'Renfrewshire' and Locality ne '' and Locality ne 'Paisley' and Locality ne 'Renfrewshire North West and South' Locality='Outside Partnership'.
 * if sending_location='Shetland' and Locality ne 'Shetland' and Locality ne '' and Locality ne 'Central Mainland' and Locality ne 'Lerwick & Bressay' and Locality ne 'North Isles' and Locality ne 'North Mainland' and
Locality ne 'South Mainland' and Locality ne 'West Mainland' and Locality ne 'Whalsay & Skerries' Locality='Outside Partnership'.
 * if sending_location='South Ayrshire' and Locality ne 'South Ayrshire' and Locality ne '' and Locality ne 'Ayr North and Former Coalfield Communities' and Locality ne 'Ayr South and Coylton' and
Locality ne 'Girvan and South Carrick Villages' and Locality ne 'Maybole and North Carrick Communities' and Locality ne 'Prestwick' and Locality ne 'Troon' Locality='Outside Partnership'.
 * if sending_location='South Lanarkshire' and Locality ne 'South Lanarkshire' and Locality ne '' and Locality ne 'Clydesdale' and Locality ne 'East Kilbride' and Locality ne 'Hamilton' and 
Locality ne 'Rutherglen Cambuslang' Locality='Outside Partnership'.
 * if sending_location='Stirling' and Locality ne 'Stirling' and Locality ne '' and Locality ne 'Rural Stirling' and Locality ne 'Stirling City with the Eastern Villages Bridge of Allan and Dunblane' Locality='Outside Partnership'.
 * if sending_location='West Dunbartonshire' and Locality ne 'West Dunbartonshire' and Locality ne '' and Locality ne 'Clydebank' and Locality ne 'Dumbarton/Alexandria' Locality='Outside Partnership'.
 * if sending_location='West Lothian' and Locality ne 'West Lothian' and Locality ne '' and Locality ne 'West Lothian (East)' and Locality ne 'West Lothian (West)' Locality='Outside Partnership'.
 * if sending_location='Western Isles' and Locality ne 'Western Isles' and Locality ne '' and Locality ne 'Barra' and Locality ne 'Harris' and Locality ne 'Rural Lewis' and 
Locality ne 'Stornoway & Broadbay' and Locality ne 'Uist' Locality='Outside Partnership'.
 * execute.

 * if Locality='' Locality='Unknown'.
 * execute.

 * save outfile = !Outfile.



*******************************************************************************************************************************************************.
*POPULATION CLASSIFICATION - LTC DISTRIBUTION

*******************************************************************************************************************************************************.
get file = '/conf/sourcedev/TableauUpdates/Social Care/Outputs/201819/all_outputs_merged_updated.zsav'.
dataset name SocialCareMaster window = front.

*It's also the case that the data is wide rather than tall for Type=LTCDistribution, so we need to do a Vars to Cases.
DATASET COPY LTCDistribution.
DATASET ACTIVATE LTCDistribution.

*Just choose the cases where the data is wide and we want to make it tall, and do the VARSTOCASES operation.
SELECT IF Type = "LTC Distribution".
EXECUTE.

VARSTOCASES
/MAKE LTCTypeCount FROM arth TO digestive
/INDEX LTCTypeBreakdown (LTCTypeCount).
EXECUTE.


***********************************************UPDATE based on Ag feedback for CH. 22/02/21**********************************************.
******ADJUST / RE-CALCULATE FOR CH WHERE CH NAME = LOCALITY AS OTHERWISE WILL GET >100%.

COMPUTE Numerator = LTCTypeCount.
EXECUTE.

COMPUTE Percentage_clients = (Numerator/Denominator) * 100.
EXECUTE.

alter type Percentage_clients (f8.1).

***NEW***
*Check no % over 100.
temporary.
select if Percentage_clients >100.
crosstabs sending_location by File.
*Note that because client can have >1 LTC, the sum of Percentage_clients for LTCTypeBreakdown will be >100%.
*DC 040321.

*Now, we need to delete these cases from the main file and add on the modified data.
DATASET ACTIVATE SocialCareMaster.
SELECT IF Type NE "LTC Distribution".
EXECUTE.

ADD FILES FILE = LTCDistribution
    /FILE = SocialCareMaster.
EXECUTE.

DATASET NAME SocialCareMaster.

DELETE VARIABLES ArthPerc TO DigestivePerC.
EXECUTE.
DELETE VARIABLES arth TO digestive.
EXECUTE.

DATASET CLOSE LTCDistribution.

**************************************************************************.
*Update LTC names so full name is dislpayed.
alter type LTCTypeBreakdown (a50).
if LTCTypeBreakdown='arth' LTCTypeBreakdown='Arthritis Artherosis'.
if LTCTypeBreakdown='asthma' LTCTypeBreakdown='Asthma'.
if LTCTypeBreakdown='atrialfib' LTCTypeBreakdown='Atrial Fibrillation'.
if LTCTypeBreakdown='bloodbfo' LTCTypeBreakdown='Diseases of Blood and Blood Forming Organs'.
if LTCTypeBreakdown='cancer' LTCTypeBreakdown='Cancer'.
if LTCTypeBreakdown='chd' LTCTypeBreakdown='Coronary heart Disease (CHD)'.
if LTCTypeBreakdown='congen' LTCTypeBreakdown='Congenital Problems'.
if LTCTypeBreakdown='copd' LTCTypeBreakdown='Chronic Obstructive Pulmonary Disease (COPD)'.
if LTCTypeBreakdown='cvd' LTCTypeBreakdown='Cerebrovascular Disease (CVD)'.
if LTCTypeBreakdown='diabetes' LTCTypeBreakdown='Diabetes'.
if LTCTypeBreakdown='dementia' LTCTypeBreakdown='Dementia'.
if LTCTypeBreakdown='digestive' LTCTypeBreakdown='Other Diseases of Digestive System'.
if LTCTypeBreakdown='endomet' LTCTypeBreakdown='Other Endocrine Metabolic Diseases'.
if LTCTypeBreakdown='epilepsy' LTCTypeBreakdown='Epilepsy'.
if LTCTypeBreakdown='hefailure' LTCTypeBreakdown='Heart Failure'.
if LTCTypeBreakdown='liver' LTCTypeBreakdown='Chronic Liver Disease'.
if LTCTypeBreakdown='ms' LTCTypeBreakdown='Multiple Sclerosis'.
if LTCTypeBreakdown='parkinsons' LTCTypeBreakdown='Parkinsons'.
if LTCTypeBreakdown='refailure' LTCTypeBreakdown='Renal Failure'.
execute.

sort cases by File Type sending_location Locality period.

*Re-order variables.
add files file = *
/keep sending_location Locality LocalityCH period File Type CareHomeName
Numerator Denominator Rate
LTCNo LTCTypeBreakdown LTCTypeCount Percentage_clients
Sex Age_Band 
AEReferralSource diagdescript Adm top5 Adm_all_top5
hours_band LivingAlone Servicetype EQ_HC
SDS_NeedType SDS_NeedGroup Option NetCost GrossCost
OOHAdvice OOHHomeV OOHPCC NursingCareProvision
simd2020v2_HSCP2019_quintile UR2_2016 urbanrural LA.
execute.



*EQ Population Classification chart 2 reads from Percentage_clients variable - so need to copy % values from Rate into this variable.
*NB: same chart in HC seems to read from Rate variable, so no change needed there.
*DC 09/02/21.
do if File = 'Equipment' and Type = 'Percentage of clients with one or more LTCs'.
compute Percentage_clients = Rate.
end if.
execute.

save outfile = '/conf/sourcedev/TableauUpdates/Social Care/Outputs/201819/all_outputs_merged_updated.zsav'
/ZCOMPRESSED.


*******************************************************************************************************************************************************.
*SDS - NET/GROSS COST; NEW TYPE CATEGORIES (NEEDS / CONTRIBUTOR).

*******************************************************************************************************************************************************.
***Indicators by Locality 2***.
dataset close all.

get file = '/conf/sourcedev/TableauUpdates/Social Care/Outputs/201819/all_outputs_merged_updated.zsav'.
dataset name SocialCareMaster window = front.

DATASET COPY SDSNetCost.
DATASET ACTIVATE SDSNetCost.
SELECT IF NetCost ne SYSMIS(NetCost).
EXECUTE.

COMPUTE Type = "SDS Net Cost".
COMPUTE Numerator = NetCost.
EXECUTE.

DATASET COPY SDSGrossCost.
DATASET ACTIVATE SDSGrossCost.
COMPUTE Type = "SDS Gross Cost".
COMPUTE Numerator = GrossCost.
EXECUTE.

DATASET ACTIVATE SocialCareMaster.
ADD FILES FILE = SocialCareMaster
    /FILE = SDSNetCost
    /FILE = SDSGrossCost.
EXECUTE.
DATASET NAME SocialCareMaster window = front.

**********************************************************************************************.
*Check breakdown values and breakdown_type for SDS before continuing. DC 09/02/21.
DATASET ACTIVATE SocialCareMaster.
temporary.
select if File = 'Self Directed Support' and any(Type, 'Service Usage', 'Client Group').
crosstabs SDS_NeedType by SDS_NeedGroup.

***Commented this out as labels blank, so would make Breakdown_type blank. DC 09/02/21.
 * compute Breakdown_type=valuelabel(Breakdown_type).
 * execute.

 * alter type Breakdown_type (a30).
 * if Breakdown_type='Needs' Breakdown_type='SDS Needs'.
 * if Breakdown_type='Contribution' Breakdown_type='SDS Contributor'.
 * execute.
**********************************************************************************************.

***Update TYPE for SDS.
temporary.
select if File = 'Self Directed Support'.
freq var Type.

DO IF ANY(SDS_NeedGroup, "SDS Needs", "SDS Contributor").
    COMPUTE Type = SDS_NeedGroup.
END IF.
EXECUTE.

***Check.
temporary.
select if File = 'Self Directed Support'.
freq var Type.
*Now have 2 additional 'Type's - SDS Needs and SDS Contributor. DC 09/02/21.

DATASET CLOSE SDSNetCost.
DATASET CLOSE SDSGrossCost.

SAVE OUTFILE = '/conf/sourcedev/TableauUpdates/Social Care/Outputs/201819/all_outputs_merged_updated.zsav'
/ZCOMPRESSED.


*******************************************************************************************************************************************************.
*PRIMARY CARE - OUT OF HOURS
Combine OOHAdvice OOHHomeV OOHPCC percentages into a single variable: OutOfHoursType.
*******************************************************************************************************************************************************.
dataset close all.

get file = '/conf/sourcedev/TableauUpdates/Social Care/Outputs/201819/all_outputs_merged_updated.zsav'.
dataset name SocialCareMaster window = front.

DATASET COPY outOfHours.
DATASET ACTIVATE outOfHours.

SELECT IF Type = "Out of Hours".
EXECUTE.

*Combine OOHAdvice OOHHomeV OOHPCC into a single variable: OutOfHoursType.
*NB: Out of Hours Count is actually % contained in OOHAdvice / OOHHomeV / OOHPCC.
*?Impact of renaming this variable to OOH_Perc on dashboards? DC 11/05/21.
VARSTOCASES
    /MAKE OutOfHoursCount from OOHAdvice OOHHomeV OOHPCC
    /INDEX OutOfHoursType (OutOfHoursCount).
EXECUTE.


DATASET ACTIVATE SocialCareMaster.
SELECT IF Type NE "Out of Hours".
EXECUTE.

ADD FILES FILE = outOfHours
    /FILE = SocialCareMaster.
EXECUTE.
DATASET NAME SocialCareMaster.

DATASET CLOSE outOfHours.

**************************************************************************.
*Update Out of Hours types so full name is displayed.
alter type OutOfHoursType (a80).
if OutOfHoursType='OOHAdvice' OutOfHoursType='Out of Hours Doctor/Nurse Advice'.
if OutOfHoursType='OOHHomeV' OutOfHoursType='Out of Hours Home Visit'.
if OutOfHoursType='OOHPCC' OutOfHoursType='Out of Hours Primary Care Emergency Centre/Primary Care Centre'.
execute.


**************************************************************************.
*Rename variables to match 2017/18 names when adding files together.
*DO WE NEED TO RETAIN THESE VARIABLES AS THEY ARE NOW EMPTY? DC 11/05/21.
rename variables OOHAdvice=OutofHours_Doctor_NurseAdvice.
rename variables OOHHomeV=OutofHours_HomeVisit.
rename variables OOHPCC=OutofHours_PrimaryCareEmergencyCentre_PrimaryCareCentre.

freq var OutofHours_Doctor_NurseAdvice
OutofHours_HomeVisit
OutofHours_PrimaryCareEmergencyCentre_PrimaryCareCentre.



**************************************************************************.
***PRIMARY CARE - OOH PERCENTAGES - CARE HOME.
*Modify OOH percentages when care home name = locality to ensure percentage is limited to 100%.
**************************************************************************.
***NEW***DC 040321.
*Where missing CH names have been set to Locality (Aberdeen City / West Lothian), there will be duplicate rows 
- per quarter and OOH Type - 
so summing these by CH Name will create OutOfHoursCount % over 100. DC 040321.

*Flag affected records.
if File = 'Care Home' and Type = 'Out of Hours' and any(Locality, 'Aberdeen Central', 'Aberdeen North', 'Aberdeen South', 'Aberdeen City', 
'West Lothian (East)', 'West Lothian (West)') OOHnew = 1.
execute.

if File = 'Care Home' and Type = 'Out of Hours' and any(sending_location, 'Aberdeen City', 'West Lothian') and 
Locality = 'Outside Partnership' OOHnew = 1.
execute.

*sort cases by File (a) Type (a) sending_location (a) period (a).

 * compute OutOfHoursCount_CH=0.
 * if File='Care Home' OutOfHoursCount_CH=OutOfHoursCount.
 * execute.

*Extract data to create new totals.
dataset activate SocialCareMaster.
dataset copy OOHnew.
dataset activate OOHnew.
select if OOHnew = 1.
execute.


*Create ROW COUNT per Locality, OOHType and period (CH names all = Locality).
aggregate outfile = * mode = ADDVARIABLES
/break Locality period OutOfHoursType
/OOHRowCount = n.
execute.

*Aggregate multiple rows per CH name (as set to Locality, there will be duplicates) and split by OOH Type.
*NB: summing OutOfHoursCount (created at LN518 by combining OOHAdvice / OOHHomeV / OOHPCC) is actually summing percentages,
as that is what was contained in OOHAdvice / OOHHomeV / OOHPCC. DC 11/05/21.
dataset declare OOHagg.
aggregate outfile = OOHagg
/break File Type sending_location Locality LocalityCH CareHomeName period OutOfHoursType
/OutOfHoursCount = sum(OutOfHoursCount)
/OOHRowCount = max(OOHRowCount).
execute.


*Calculate new OOH percentages per Type.
*I'm not sure why this works, as numerator based on summed % but figures look reasonable! DC 11/05/21.
dataset activate OOHagg.
compute OutOfHoursCount_CH = OutOfHoursCount/OOHRowCount.
execute.
alter type OutOfHoursCount_CH(f8.1).
*So where Care Home Name = Locality, should have 3 rows per Quarter (one per OOH Type) and OutOfHoursCount_CH % will add up to 100.

*Now combine back with main file.
dataset activate OOHagg.
delete variables OutOfHoursCount OOHRowCount.
rename variables OutOfHoursCount_CH = OutOfHoursCount.

dataset activate SocialCareMaster.
select if sysmis(OOHnew).
execute.

add files file = OOHagg
/file = SocialCareMaster.
execute.
dataset name SCMaster window = front.

sort cases by File Type sending_location Locality CareHomeName period.

dataset activate SCMaster.
dataset close SocialCareMaster.
dataset close OOHnew.
dataset close OOHagg.

delete variables OOHnew.

*Modify OOH count due to care home name=locality for Aberdeen City HSCP, Edinburgh City HSCP and West Lothian HSCP - 
all others remain unchanged 2017/18.
*2018/19.
 * if File='Care Home' and Locality='Aberdeen Central' and period='2018/19 Q1' OutOfHoursCount_CH=OutOfHoursCount_CH/25.
 * if File='Care Home' and Locality='Aberdeen Central' and period='2018/19 Q2' OutOfHoursCount_CH=OutOfHoursCount_CH/16.
 * if File='Care Home' and Locality='Aberdeen Central' and period='2018/19 Q3' OutOfHoursCount_CH=OutOfHoursCount_CH/15.
 * if File='Care Home' and Locality='Aberdeen Central' and period='2018/19 Q4' OutOfHoursCount_CH=OutOfHoursCount_CH/17.

 * if File='Care Home' and Locality='Aberdeen North' and period='2018/19 Q1' OutOfHoursCount_CH=OutOfHoursCount_CH/23.
 * if File='Care Home' and Locality='Aberdeen North' and period='2018/19 Q2' OutOfHoursCount_CH=OutOfHoursCount_CH/19.
 * if File='Care Home' and Locality='Aberdeen North' and period='2018/19 Q3' OutOfHoursCount_CH=OutOfHoursCount_CH/23.
 * if File='Care Home' and Locality='Aberdeen North' and period='2018/19 Q4' OutOfHoursCount_CH=OutOfHoursCount_CH/16.

 * if File='Care Home' and Locality='Aberdeen South' and period='2018/19 Q1' OutOfHoursCount_CH=OutOfHoursCount_CH/24.
 * if File='Care Home' and Locality='Aberdeen South' and period='2018/19 Q2' OutOfHoursCount_CH=OutOfHoursCount_CH/29.
 * if File='Care Home' and Locality='Aberdeen South' and period='2018/19 Q3' OutOfHoursCount_CH=OutOfHoursCount_CH/26.
 * if File='Care Home' and Locality='Aberdeen South' and period='2018/19 Q4' OutOfHoursCount_CH=OutOfHoursCount_CH/29.

 * if File='Care Home' and sending_location='Aberdeen City' and Locality='Outside Partnership' and period='2018/19 Q1' OutOfHoursCount_CH=OutOfHoursCount_CH/38.
 * if File='Care Home' and sending_location='Aberdeen City' and Locality='Outside Partnership' and period='2018/19 Q2' OutOfHoursCount_CH=OutOfHoursCount_CH/27.
 * if File='Care Home' and sending_location='Aberdeen City' and Locality='Outside Partnership' and period='2018/19 Q3' OutOfHoursCount_CH=OutOfHoursCount_CH/34.
 * if File='Care Home' and sending_location='Aberdeen City' and Locality='Outside Partnership' and period='2018/19 Q4' OutOfHoursCount_CH=OutOfHoursCount_CH/41.
 * execute.

 * if File='Care Home' and Locality='West Lothian (East)' and CareHomeName='West Lothian (East)' and period='2018/19 Q1' OutOfHoursCount_CH=OutOfHoursCount_CH/14.
 * if File='Care Home' and Locality='West Lothian (East)' and CareHomeName='West Lothian (East)' and period='2018/19 Q2' OutOfHoursCount_CH=OutOfHoursCount_CH/14.
 * if Locality='West Lothian (East)' and CareHomeName='West Lothian (East)' and period='2018/19 Q3' OutOfHoursCount_CH=OutOfHoursCount_CH/37.
 * if Locality='West Lothian (East)' and CareHomeName='West Lothian (East)' andperiod='2018/19 Q4' OutOfHoursCount_CH=OutOfHoursCount_CH/37.
 * execute.

 * if File='Care Home' and Locality='West Lothian (West)' and CareHomeName='West Lothian (West)' and period='2018/19 Q1' OutOfHoursCount_CH=OutOfHoursCount_CH/13.
 * if File='Care Home' and Locality='West Lothian (West)' and CareHomeName='West Lothian (West)' and period='2018/19 Q2' OutOfHoursCount_CH=OutOfHoursCount_CH/8.
 * if Locality='West Lothian (West)' and CareHomeName='West Lothian (West)' and period='2018/19 Q3' OutOfHoursCount_CH=OutOfHoursCount_CH/28.
 * if Locality='West Lothian (West)' and CareHomeName='West Lothian (West)' and period='2018/19 Q4' OutOfHoursCount_CH=OutOfHoursCount_CH/28.
 * execute.

 * if File='Care Home' and sending_location='West Lothian' and Locality='Outside Partnership' and CareHomeName='Outside Partnership' and period='2018/19 Q1' OutOfHoursCount_CH=OutOfHoursCount_CH/14.
 * if File='Care Home' and sending_location='West Lothian' and Locality='Outside Partnership' and CareHomeName='Outside Partnership' and period='2018/19 Q2' OutOfHoursCount_CH=OutOfHoursCount_CH/14.
 * if sending_location='West Lothian' and Locality='Outside Partnership' and CareHomeName='Outside Partnership' and period='2018/19 Q3' OutOfHoursCount_CH=OutOfHoursCount_CH/33.
 * if sending_location='West Lothian' and Locality='Outside Partnership' and CareHomeName='Outside Partnership' and period='2018/19 Q4' OutOfHoursCount_CH=OutOfHoursCount_CH/33.
 * execute.

 * alter type OutOfHoursCount_CH (f8.1).

SAVE OUTFILE = '/conf/sourcedev/TableauUpdates/Social Care/Outputs/201819/all_outputs_merged_updated.zsav'
/ZCOMPRESSED.


*******************************************************************************************************************************************************.
***A&E REFERRAL SOURCE - CH.

*******************************************************************************************************************************************************.
*Manually update Care Home AE Referral Source when care home name = locality to ensure percentage is limited to 100%.
*Affects records where Care Home name = Locality (ie no care home name was submitted) - so Aberdeen City & West Lothian.
*Get SPSS file, select if Type = 'A&E referral source' and HSCP = Aberdeen City or West Lothian.
*DC 040321.
dataset close all.
get file =  '/conf/sourcedev/TableauUpdates/Social Care/Outputs/201819/all_outputs_merged_updated.zsav'.
dataset name master window = front.

select if File = 'Care Home' and Type = 'A&E referral source' and (sending_location = 'Aberdeen City' or sending_location = 'West Lothian').
execute.
*Notice that where CH name = Locality, there are multiple rows per referral source, when there should only be one for each.

*Keep only relevant variables.
add files file = *
/keep sending_location Locality LocalityCH CareHomeName period File Type Numerator Denominator Rate AEReferralSource.
execute.

Sort cases by sending_location LocalityCH CareHomeName period AEReferralSource.
*Notice that for Q1, Aberdeen Central (localityCH), and Aberdeen Central (Care Home Name) there are multiple rows for each referral source.
*These need to be aggregated so 1 row per referral source, with new numerators, denominators and rates calculated.

*First, create totals per referral source.
aggregate outfile = * 
/break sending_location Locality LocalityCH CareHomeName period File Type AEReferralSource
/Numerator = sum(Numerator).
execute.
dataset name agg window = front.

*Then create denominator totals as a new variable (by dropping referral source from break line).
dataset activate agg.
aggregate outfile = * mode = addvariables
/break sending_location Locality LocalityCH CareHomeName period File Type
/Denominator = sum(Numerator).
execute.

*Recaluclate Rates.
dataset activate agg.
numeric Rate(f8.1).
compute Rate = (Numerator/Denominator)*100.
execute.

*Now compare data in 'agg' window with 'master' - there should only be one row per referral source, when CH name = Locality, 
and % (Rate) should add up to no more than 100% for all referral sources.

*Add back into main file.
dataset activate agg.
dataset close master.
get file =  '/conf/sourcedev/TableauUpdates/Social Care/Outputs/201819/all_outputs_merged_updated.zsav'.
dataset name master window = front.

*Flag records to be deleted from main file.
string delete(a1).
do if File = 'Care Home' and Type = 'A&E referral source' and (sending_location = 'Aberdeen City' or sending_location = 'West Lothian').
compute delete = 'y'.
end if.
execute.

freq var delete.
*So dropping 527 records.

select if delete ne 'y'.
execute.

*Add agg data to main file.
add files file = agg
/file = master.
execute.
dataset name final window = front.

sort cases by File Type sending_location Locality CareHomeName.

delete variables delete.

*******************************************************************************************************************************************************.
*Compute top 5 admission reason percentage variable for chart on Unscheduled Care 2 dashboard.

*******************************************************************************************************************************************************.
dataset activate final.
dataset close agg.
dataset close master.

numeric Top5_Adm_Perc(f3.1).
compute Top5_Adm_Perc=(Adm/Adm_all_top5)*100.
execute.



*******************************************************************************************************************************************************.
*ADD LA CODE FOR SECURITY FILTERS.

*******************************************************************************************************************************************************.
rename variables sending_location=LCAname.
alter type LCAname (a35).

*Add 9 digit LA Code, this is so security filters can be applied to the data source.
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
execute.

rename variables LCAname=sending_location.

string LOOKUP (a100).
compute LOOKUP=concat(File,Locality,Type).
execute.

save outfile = '/conf/sourcedev/TableauUpdates/Social Care/Outputs/201819/SocialCare_1819.sav'.

crosstabs Type by File.

*****************************************************END******************************************************************************.

get file= !Outfile.
dataset name Tableau window = front.

do if Type = 'Percentage of clients with one or more LTCs'.
compute Percentage_clients = Rate.
end if.
execute.

temporary.
select if Locality = ''.
crosstabs sending_location by Type by File.

********************************************************************************************************************************************.
get file= !Outfile.
dataset name Tableau window = front.

select if File = 'Self Directed Support' and Type = 'Age and gender breakdown'.
execute.

select if sending_location = 'Glasgow City'.
execute.

*Create Glasgow HSCP total for Locality variable = check if should include 'Outside Partnership' first.
dataset declare GGC_agg.
aggregate outfile = GGC_agg
/break sending_location period File Type 



select if File = 'Equipment' and Type = 'Home Care'.
execute.

