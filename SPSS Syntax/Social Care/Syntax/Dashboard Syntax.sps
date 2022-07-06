* Encoding: UTF-8.
* Modify Orkney file to match with All outputs merged April file (Only required for 201718 data).
 * get file = '/conf/social-care/05-Analysts/linked_outputs/2017_18 SOURCE/Outputs/orkney.sav'.

 * alter type Numerator (f8.2).
 * alter type Denominator (f8.2).
 * alter type Rate (f8.2).
 * alter type MentalHealthProblems (f8.2).
 * alter type LearningDisability (f8.2).
 * alter type PhysicalandSensoryDisability (f8.2).
 * alter type Drugs (f8.2).
 * alter type Alcohol (f8.2).
 * alter type PalliativeCare (f8.2).
 * alter type Carer (f8.2).
 * alter type ElderlyFrail (f8.2).
 * alter type NeurologicalCondition (f8.2).
 * alter type Autism (f8.2).
 * alter type OtherVulnerableGroups (f8.2).
 * alter type NotRecorded (f8.2).
 * alter type LivingAlone (f8.2).
 * alter type SupportfromUnpaidCarer (f8.2).
 * alter type SocialWorker (f8.2).
 * alter type total (f7.0).

 * rename variables Per_MentalHealthProblems=Per_MH.
 * alter type Per_MH (f8.2).
 * rename variables Per_LearningDisability=Per_LD.
 * alter type Per_LD (f8.2).
 * rename variables Per_PhysicalandSensoryDisability=Per_PSD.
 * alter type Per_PSD (f8.2).
 * alter type Per_Drugs (f8.2).
 * alter type Per_Alcohol (f8.2).
 * alter type Per_PalliativeCare (f8.2).
 * alter type Per_Carer (f8.2).
 * alter type Per_ElderlyFrail (f8.2).
 * rename variables Per_NeurologicalCondition=Per_NeurologicalConditions.
 * alter type Per_NeurologicalConditions (f8.2).
 * alter type Per_Autism (f8.2).
 * rename variables Per_OtherVulnerableGroups=Per_OVG.
 * alter type Per_OVG (f8.2).
 * alter type Per_NotRecorded (f8.2).
 * alter type Per_LivingAlone (f8.2).
 * alter type Per_SupportfromUnpaidCarer (f8.2).
 * alter type Per_SocialWorker (f8.2).

 * alter type Dementia (f8.2).
 * alter type Per_Dementia (f8.2).

 * alter type clients (f8.2).
 * alter type clients_total (f8.2).
 * alter type perc (f8.2).

 * alter type NetCost (f8.2).
 * alter type GrossCost (f8.2).

 * rename variables breakdown_2=Breakdown.
 * alter type Breakdown (a40).
 * rename variables breakdown_type_2=Breakdown_type.
 * alter type Breakdown_type (a30).

 * alter type Arth (f8.2).
 * alter type Asthma (f8.2).
 * alter type AtrialFib (f8.2).
 * alter type Cancer (f8.2).
 * alter type CVD (f8.2).
 * alter type Liver (f8.2).
 * alter type COPD (f8.2).
 * alter type Diabetes (f8.2).
 * alter type Epilepsy (f8.2).
 * alter type CHD (f8.2).
 * alter type HeFailure (f8.2).
 * alter type MS (f8.2).
 * alter type Parkinsons (f8.2).
 * alter type ReFailure (f8.2).
 * alter type Congen (f8.2).
 * alter type Bloodbfo (f8.2).
 * alter type Endomet (f8.2).
 * alter type Digestive (f8.2).
 * alter type ArthPerc (f8.2).
 * alter type AsthmaPerc (f8.2).
 * alter type AtrialFibPerc (f8.2).
 * alter type CancerPerc (f8.2).
 * alter type CVDPerc (f8.2).
 * alter type LiverPerc (f8.2).
 * alter type COPDPerc (f8.2).
 * alter type DiabetesPerc (f8.2).
 * alter type EpilepsyPerc (f8.2).
 * alter type CHDPerc (f8.2).
 * alter type HeFailurePerc (f8.2).
 * alter type MSPerc (f8.2).
 * alter type ParkinsonsPerc (f8.2).
 * alter type ReFailurePerc (f8.2).
 * alter type CongenPerc (f8.2).
 * alter type BloodbfoPerc (f8.2).
 * alter type EndometPerc (f8.2).
 * alter type DigestivePerc (f8.2).

 * alter type Clients_denominator (f8.2).
 * alter type OOHAdvice (f8.2).
 * alter type OOHHomeV (f8.2).
 * alter type OOHPCC (f8.2).

 * save outfile = '/conf/social-care/05-Analysts/linked_outputs/2017_18 SOURCE/Outputs/orkney.sav'.

 * add files file = '/conf/social-care/05-Analysts/linked_outputs/2017_18 SOURCE/Outputs/all_outputs_merged_April20_final.zsav'
/file = '/conf/social-care/05-Analysts/linked_outputs/2017_18 SOURCE/Outputs/orkney.sav'.
 * execute.

 * save outfile = '/conf/social-care/05-Analysts/linked_outputs/2017_18 SOURCE/Outputs/all_outputs_merged_April20_final.zsav'.
***********************************************************************************************************************************.
dataset close all.

get file = '/conf/sourcedev/TableauUpdates/Social Care/Outputs/201819/all_outputs_merged_Jan21_final.zsav'.
dataset name Jan21 window = front.

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
execute.

freq var LivingAlone.

alter type LivingAlone (a20).
compute LivingAlone=LTRIM(LivingAlone).
execute.

if LivingAlone='0' LivingAlone='No'.
if LivingAlone='1' LivingAlone='Yes'.
if LivingAlone='9' LivingAlone='Unknown'.
execute.

save outfile = '/conf/sourcedev/TableauUpdates/Social Care/Outputs/201819/all_outputs_merged_Jan21_final.zsav'.
***********************************************************************************************************************************.
 * add files file = '/conf/social-care/05-Analysts/linked_outputs/2017_18 SOURCE/Outputs/all_outputs_merged_April20_final.zsav'
/file = '/conf/social-care/05-Analysts/linked_outputs/2017_18 SOURCE/Outputs/All_EA_File_top5_May20.sav'.
 * execute.

 * if diagdescript='Gastritis, Gastro Noninfec' diagdescript='Gastritis,Gastro Noninfec'.
 * if diagdescript='Migraine and Headache' diagdescript='Migraine & Headache'.
 * if diagdescript='Nausea Vomiting and Acute Abdomen Pain' diagdescript='Nausea Vomiting & Acute Abdomen Pain'.
 * if diagdescript='Synapse Collapse' diagdescript='Syncope Collapse'.
 * if diagdescript='UI - Falls' diagdescript='UI -Falls'.
 * execute.

 * save outfile = '/conf/social-care/05-Analysts/linked_outputs/2017_18 SOURCE/Outputs/all_outputs_merged_April20_final.zsav'.

*Modify reason for admission file to top 5.
 * get file = '/conf/social-care/05-Analysts/Social Care Dashboard/Social Care Dashboard v3/1718 Data/All_EA_File_top5.sav'.
 * get file = '/conf/social-care/05-Analysts/linked_outputs/2017_18 SOURCE/Outputs/All_EA_File_top5.sav'.

 * alter type File (a30).
 * if File='CH' File='Care Home'.
 * if File='HC' File='Home Care'.
 * if File='EQ' File='Equipment'.
 * execute.

 * if File='Care Home' Locality=LocalityCH.
 * execute.

 * sort cases by sending_location LocalityCH diag File Locality.

 * alter type sending_location (a33).
 * alter type diag (a40).

 * save outfile = '/conf/social-care/05-Analysts/Social Care Dashboard/Social Care Dashboard v3/1718 Data/All_EA_File_top5.sav'.
 * save outfile = '/conf/sourcedev/TableauUpdates/Social Care/Outputs/All_EA_File_top5.sav'.

*Match on top 5 reasons for admission file to master file.
 * get file = '/conf/social-care/05-Analysts/linked_outputs/2017_18 SOURCE/Outputs/all_outputs_merged_Mar20_final.zsav'.

 * sort cases by sending_location LocalityCH diag File Locality.

 * MATCH FILES /FILE=*
  /FILE= '/conf/sourcedev/TableauUpdates/Social Care/Outputs/All_EA_File_top5.sav'
  /BY sending_location LocalityCH diag File Locality.
 * EXECUTE.

 * if diag='Gastritis, Gastro Noninfec' diag='Gastritis,Gastro Noninfec'.
 * if diag='Migraine and Headache' diag='Migraine & Headache'.
 * if diag='Nausea Vomiting and Acute Abdomen Pain' diag='Nausea Vomiting & Acute Abdomen Pain'.
 * if diag='Synapse Collapse' diag='Syncope Collapse'.
 * if diag='UI - Falls' diag='UI -Falls'.
 * execute.

 * delete variables Adm Adm_all_top5 diagdescript.
 * rename variables top5=AdmReason.
 * rename variables diag=diagdescript.

get file = '/conf/sourcedev/TableauUpdates/Social Care/Outputs/201819/all_outputs_merged_Jan21_final.zsav'.


***********************************************UPDATE based on Ag feedback for CH. 22/02/21**********************************************.
rename variables diag=diagdescript.
***********************************************UPDATE based on Ag feedback for CH. 22/02/21**********************************************.

alter type period (a10).
if period='' period='2018/19'.
if period='2018' period='2018/19'.
if period='2018Q1' period='2018/19 Q1'.
if period='2018Q2' period='2018/19 Q2'.
if period='2018Q3' period='2018/19 Q3'.
if period='2018Q4' period='2018/19 Q4'.
execute.

save outfile = '/conf/sourcedev/TableauUpdates/Social Care/Outputs/201819/all_outputs_merged_updated.zsav'.

***********************************************************************************************************************************.
DEFINE !Outfile()
    '/conf/sourcedev/TableauUpdates/Social Care/Outputs/201819/SocialCare_1819.sav'
!ENDDEFINE.

GET
  FILE='/conf/sourcedev/TableauUpdates/Social Care/Outputs/201819/all_outputs_merged_updated.zsav'.
DATASET NAME SocialCareMaster WINDOW=FRONT.

***********************************************************************************************************************************.
*****POPULATION CLASSIFICATION WORKBOOK*****
***********************************************************************************************************************************.

*Not necessary for 2018/19 update.
*We need to modify the data for Type = "Client type (social care)". 
*Apart from cases where File="Self Direct Support", the data is wide rather than tall.
*We need to convert it so that it's all tall.
*Data not included in dashboards so not required to be calculated for 2018/19.
 * DATASET COPY ClientType1.
 * DATASET ACTIVATE ClientType1.

 * SELECT IF (Type = "Client type distribution") AND (FILE = "Care Home" OR FILE = "Equipment" OR FILE = "Home Care").
 * EXECUTE.

 * ALTER TYPE DementiaS TO NotRecorded (f28).
 * EXECUTE.

 * VARSTOCASES
/MAKE ClientTypeBreakdownCount FROM DementiaS TO NotRecorded
/INDEX ClientTypeBreakdown (ClientTypeBreakdownCount).
 * EXECUTE.

 *     COMPUTE Denominator = Total.
 *     COMPUTE Numerator = ClientTypeBreakdownCount.
 * EXECUTE.

 * DATASET ACTIVATE SocialCareMaster.
 * DATASET COPY ClientType2.
 * DATASET ACTIVATE ClientType2.

 * COMPUTE Delete = 0.
 * IF Type = "Client type (social care)" AND (FILE = "Care Home" OR FILE = "Equipment" OR FILE = "Home Care") Delete = 1.
 * EXECUTE.
 * SELECT IF Delete = 0.
 * EXECUTE.

 * SELECT IF (Type = "Client Group") AND (FILE = "Self Directed Support").
 * EXECUTE.

 * compute numerator=clients.
 * execute.

 * RENAME VARIABLES Breakdown = ClientTypeBreakdown.
 * EXECUTE.
 * ALTER TYPE ClientTypeBreakdown(a28).
 * RENAME VARIABLES clients = ClientTypeBreakdownCount.
 * EXECUTE.
 * ALTER TYPE ClientTypeBreakdownCount(f3).
 * EXECUTE.

 * COMPUTE Denominator = Numerator.
 * COMPUTE Numerator = ClientTypeBreakdownCount.
 * EXECUTE.


 * ADD FILES FILE = ClientType2
    /FILE = ClientType1.
 * EXECUTE.
 * DATASET NAME ClientTypeFinal.

*We can compute the percentages using data we have rather than matching on, so let's do that now.
 * DO IF SYSMIS(Percentage_clients). 
 *     COMPUTE Percentage_clients = (Numerator / Total) * 100.
 * END IF.
 * EXECUTE.

 * DO IF File = "Care Home".
 *          COMPUTE Option1 = CareHomeName.
 *          COMPUTE Age_Band = "All Ages".
 * END IF.
 * DO IF File = "Home Care".
 *          COMPUTE Option1 = "NA".
 * END IF.
 * DO IF File = "Self Directed Support".
 *          COMPUTE Option1 = Option.
 *          COMPUTE Age_Band = "All Ages".
 * END IF.
 * DO IF File = "Equipment".                 
 *          COMPUTE Option1 = servicetype.
 * END IF.
 * EXECUTE.


 * DATASET ACTIVATE SocialCareMaster.
 * SELECT IF TYPE NE "Client type distribution" AND TYPE NE 'Client Group'.
 * EXECUTE.

 * ADD FILES FILE = SocialCareMaster
    /FILE = ClientTypeFinal.
 * DATASET NAME SocialCareMaster.
 * EXECUTE.

 * DELETE VARIABLES DementiaS TO NotRecorded.
 * DELETE VARIABLES Per_dementiaS TO Per_NotRecorded.
 * EXECUTE.

 * DATASET CLOSE ClientType1.
 * DATASET CLOSE ClientType2.
 * DATASET CLOSE ClientTypeFinal.

 * IF Type = "High Health Gain" Percentage_clients = Rate.
 * IF Type = "SPARRA" Percentage_clients = Rate.
 * IF Type = "Multi-morbidity" Percentage_clients = Rate.
 * EXECUTE.

 * SAVE OUTFILE=!Outfile
  /COMPRESSED.

***END OF Client Type Sheet*****
*******
***********************************************************************************************************************************.
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

COMPUTE Numerator = LTCTypeCount.
EXECUTE.

COMPUTE Percentage_clients = (Numerator/Denominator) * 100.
EXECUTE.

***********************************************UPDATE based on Ag feedback for CH. 22/02/21**********************************************.
******ADJUST / RE-CALCULATE FOR CH WHERE CH NAME = LOCALITY AS OTHERWISE WILL GET >100%.
***********************************************UPDATE based on Ag feedback for CH. 22/02/21**********************************************.


 * DO IF File = "Care Home".
 *          COMPUTE Option1 = CareHomeName.
 *          COMPUTE Age_Band = "All Ages".
 * END IF.
 * DO IF File = "Home Care".
 *          COMPUTE Option1 = "NA".
 * END IF.
 * DO IF File = "Self Directed Support".
 *          COMPUTE Option1 = Option.
 *          COMPUTE Age_Band = "All Ages".
 * END IF.
 * DO IF File = "Equipment".                 
 *          COMPUTE Option1 = servicetype.
 * END IF.
 * EXECUTE.

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

SAVE OUTFILE=!Outfile
  /COMPRESSED.


***********************************************************************************************************************************.
*****POPULATION DEMOGRAPHY - GEOGRAPHY*****
***********************************************************************************************************************************.
***Indicators by Locality 2***.
GET FILE = !Outfile.
    DATASET NAME SocialCareMaster.

 * select if Breakdown_type='Needs'.
 * execute.

 * COMPUTE IndicatorsByLocality2 = 0.
 * EXECUTE.

 * DO IF (File = "Home Care").
 *     DO IF (Type = "Age: rate by locality (no gender split)").
 *         COMPUTE Split1 = Locality.
 *         COMPUTE Split2 = Age_Band.
 *         COMPUTE IndicatorsByLocality2 = 1.
 *     END IF.
 *     DO IF (Type ="Weekly hours").
 *         COMPUTE Split1 = Locality.
 *         COMPUTE Split2 = Age_Band.
 *         COMPUTE Split3 = hours_band.
 *         COMPUTE IndicatorsByLocality2 = 1.
 *     END IF.
 * END IF.

DATASET COPY SDSNetCost.
DATASET ACTIVATE SDSNetCost.
SELECT IF NetCost ne SYSMIS(NetCost).
EXECUTE.
COMPUTE Type = "SDS Net Cost".
COMPUTE Numerator = NetCost.
 * COMPUTE Split1 = Locality.
 * COMPUTE Split2 = Option.
 * COMPUTE Split3 = "".
 * COMPUTE IndicatorsByLocality2 = 1.
EXECUTE.

DATASET COPY SDSGrossCost.
DATASET ACTIVATE SDSGrossCost.
COMPUTE Type = "SDS Gross Cost".
COMPUTE Numerator = GrossCost.
 * COMPUTE Split1 = Locality.
 * COMPUTE Split2 = Option.
 * COMPUTE Split3 = "".
 * COMPUTE IndicatorsByLocality2 = 1.
EXECUTE.

DATASET ACTIVATE SocialCareMaster.
ADD FILES FILE = SocialCareMaster
    /FILE = SDSNetCost
    /FILE = SDSGrossCost.
EXECUTE.
DATASET NAME SocialCareMaster window = front.

*Check breakdown values and breakdown_type for SDS before continuing. DC 09/02/21.
DATASET ACTIVATE SocialCareMaster.
temporary.
select if File = 'Self Directed Support' and any(Type, 'Service Usage', 'Client Group').
crosstabs breakdown by breakdown_type.

**********************************************************************************************.
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

DO IF ANY(Breakdown_type, "SDS Needs", "SDS Contributor").
    COMPUTE Type = Breakdown_type.
 *     COMPUTE Split1 = Locality.
 *     COMPUTE Split2 = Option.
 *     COMPUTE Split3 = breakdown_2.
 *     COMPUTE IndicatorsByLocality2 = 1.
END IF.
EXECUTE.

***Check.
temporary.
select if File = 'Self Directed Support'.
freq var Type.
*Now have 2 additional 'Type's - SDS Needs and SDS Contributor. DC 09/02/21.

***********************************************************************************************************************************.

 * DO IF (File = "Equipment" AND ANY(Type, "SDS", "Home Care")).
 *     COMPUTE Option1 = ServiceType.
 *     COMPUTE Split1 = Locality.
 *     COMPUTE Split2 = Age_Band.
 *     COMPUTE Numerator = Clients.
 *     IF Type = "SDS"           Split3 = SDS.
 *     IF Type = "Home Care"     Split3 = HC.
 *     COMPUTE IndicatorsByLocality2 = 1.
 * END IF.

 * DO IF (File = "Equipment" AND Type = "Age: rate by locality (no gender split)").
 *     COMPUTE Option1 = ServiceType.
 *     COMPUTE Split1 = Locality.
 *     COMPUTE Split2 = Age_Band.
 *     IF Type = "SDS"           Split3 = SDS.
 *     IF Type = "Home Care"     Split3 = HC.
 *     COMPUTE IndicatorsByLocality2 = 1.
 * END IF.


DATASET CLOSE SDSNetCost.
DATASET CLOSE SDSGrossCost.

SAVE OUTFILE = !Outfile.

***********************************************************************************************************************************.
*EQ Population Classification chart 2 reads from Percentage_clients variable - so need to copy % values from Rate into this variable.
*NB: same chart in HC seems to read from Rate variable, so no change needed there.
*DC 09/02/21.
GET FILE = !Outfile.
    DATASET NAME SocialCareMaster.

do if File = 'Equipment' and Type = 'Percentage of clients with one or more LTCs'.
compute Percentage_clients = Rate.
end if.
execute.

SAVE OUTFILE = !Outfile.
***********************************************************************************************************************************.
***Primary Care - Out of Hours***
***********************************************************************************************************************************.
GET FILE = !Outfile.
    DATASET NAME SocialCareMaster.
DATASET COPY outOfHours.
DATASET ACTIVATE outOfHours.

SELECT IF Type = "Out of Hours".
EXECUTE.

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

SAVE OUTFILE = !Outfile.

***********************************************************************************************************************************.
***Comparators*********************************
***********************************************************************************************************************************.
 * GET FILE = !Outfile.
 * DATASET NAME SocialCareMaster.
 * SORT CASES BY File.
 * EXECUTE.
 * DATASET COPY PopulationLookup.
 * DATASET ACTIVATE PopulationLookup.
 * SELECT IF Type = "Locality Rate".
 * EXECUTE.

 * SAVE OUTFILE = '/conf/sourcedev/TableauUpdates/Social Care/Outputs/201819/CareHomePopulationLookup.sav'
    /KEEP File Numerator.
 * GET FILE = '/conf/sourcedev/TableauUpdates/Social Care/Outputs/201819/CareHomePopulationLookup.sav'.
 * DATASET NAME PopulationLookup.
 * RENAME VARIABLES Numerator = LocalityCareHomePopulation.
 * SORT CASES BY File.
 * EXECUTE.
 * SELECT IF Area NE "" AND Area NE "Inside - HB" AND Area NE "Outside - HB".
 * EXECUTE.

 * DATASET ACTIVATE SocialCareMaster.
 * MATCH FILES FILE = SocialCareMaster
    /FILE = PopulationLookup
    /BY File.
 * EXECUTE.
 * DATASET NAME SocialCareMaster.

 * DATASET CLOSE PopulationLookup.

 * SAVE OUTFILE = !Outfile.



***********************************************************************************************************************************.
***TRANSFORM FIELDS FOR SORTING PLUS LAST MINUTE CHANGES***
***********************************************************************************************************************************.
GET FILE = !Outfile.
DATASET NAME SocialCareMaster.

IF Age_Band = "<65" Age_Band = "0-64".
IF Age_Band = "All ages" Age_Band = "All Ages".
EXECUTE.

IF hours_band = " < 2 hours" Hours_Band = "0 to 2 hours".
IF hours_band = "<2 hours" Hours_Band = "0 to 2 hours".
IF hours_band = "10+ hours" Hours_Band = "10 hours +".
IF hours_band = "2 to less than 4 hours" Hours_Band = "2 to 4 hours".
IF hours_band = "4 to less than 10 hours" Hours_Band = "4 to 10 hours".
EXECUTE.

string LOOKUP (a100).
compute LOOKUP=concat(File,Locality,Type).
execute.

rename variables Breakdown=breakdown_2.
rename variables Breakdown_type=breakdown_type_2.
rename variables SEX=Sex.
rename variables ServiceType=Servicetype. 

***********************************************UPDATE based on Ag feedback for CH. 22/02/21**********************************************.

*This stage was completed by the social care team for 2018/19.
*EXCEPT WHERE FOR CH, WHERE LOCALITY IS BLANK - NEED TO COPY LOCALITY_CH INTO LOCALITY THEN RUN BELOW.
*DC 18/02/21.

Do if File = 'CH' and Locality = ''.
compute Locality = Locality_CH.
end if.
execute.

if sending_location='Aberdeen City' and Locality ne 'Aberdeen City' and Locality ne '' and Locality ne 'Aberdeen North' and Locality ne 'Aberdeen Central' and Locality ne 'Aberdeen South' and Locality ne 'Aberdeen West' Locality='Outside Partnership'.
if sending_location='Aberdeenshire' and Locality ne 'Aberdeenshire HSCP' and Locality ne '' and Locality ne 'Banff & Buchan' and Locality ne 'Buchan' and Locality ne 'Formartine' and 
Locality ne 'Garioch' and Locality ne 'Kincardine & Mearns' and Locality ne 'Marr' Locality='Outside Partnership'.
if sending_location='Angus' and Locality ne 'Angus' and Locality ne '' and Locality ne 'Angus North East' and Locality ne 'Angus North West' and Locality ne 'Angus South East' and Locality ne 'Angus South West' Locality='Outside Partnership'.
if sending_location='Argyll & Bute' and Locality ne 'Argyll & Bute' and Locality ne '' and Locality ne 'Bute' and Locality ne 'Helensburgh and Lomond' and Locality ne 'Islay Jura and Colonsay' and Locality ne 'Kintyre' and Locality ne 'Mid Argyll' and
Locality ne 'Mull Iona Coll and Tiree' and Locality ne 'Oban and Lorn' Locality='Outside Partnership'.
if sending_location='Borders' and Locality ne 'Borders' and Locality ne '' and Locality ne 'Berwickshire' and Locality ne 'Cheviot' and Locality ne 'Eildon' and 
Locality ne 'Teviot and Liddesdale' and Locality ne 'Tweeddale' Locality='Outside Partnership'.
if sending_location='Clackmannanshire' and Locality ne 'Clackmannanshire' and Locality ne '' Locality='Outside Partnership'.
if sending_location='Dumfries & Galloway' and Locality ne 'Dumfries & Galloway' and Locality ne '' and Locality ne 'Annandale & Eskdale' and Locality ne 'Nithsdale' and Locality ne 'Stewartry' and
Locality ne 'Wigtownshire' Locality='Outside Partnership'.
if sending_location='Dundee City' and Locality ne 'Dundee City' and Locality ne '' and Locality ne 'Coldside' and Locality ne 'Dundee East End' and Locality ne 'Dundee North East' and
Locality ne 'Dundee West End' and Locality ne 'Lochee' and Locality ne 'Maryfield' and Locality ne 'Strathmartine' and Locality ne 'The Ferry' Locality='Outside Partnership'.
if sending_location='East Ayrshire' and Locality ne 'East Ayrshire' and Locality ne '' and Locality ne 'Kilmarnock' and Locality ne 'Northern' and Locality ne 'Southern' Locality='Outside Partnership'.
if sending_location='East Dunbartonshire' and Locality ne 'East Dunbartonshire' and Locality ne '' and Locality ne 'East Dunbartonshire East' and Locality ne 'East Dunbartonshire West' Locality='Outside Partnership'.
if sending_location='East Lothian' and Locality ne 'East Lothian' and Locality ne '' and Locality ne 'East Lothian East' and Locality ne 'East Lothian West' Locality='Outside Partnership'.
if sending_location='East Renfrewshire' and Locality ne 'East Renfrewshire' and Locality ne '' and Locality ne 'Barrhead' and Locality ne 'Eastwood' Locality='Outside Partnership'.
if sending_location='Edinburgh City' and Locality ne 'Edinburgh City' and Locality ne '' and Locality ne 'Edinburgh North East' and Locality ne 'Edinburgh North West' and Locality ne 'Edinburgh South East' and
Locality ne 'Edinburgh South West' Locality='Outside Partnership'.
if sending_location='Falkirk' and Locality ne 'Falkirk' and Locality ne '' and Locality ne 'Falkirk Central' and Locality ne 'Falkirk East' and Locality ne 'Falkirk West' Locality='Outside Partnership'.
if sending_location='Fife' and Locality ne 'Fife' and Locality ne '' and Locality ne 'City of Dunfermline' and Locality ne 'Cowdenbeath' and Locality ne 'Glenrothes' and Locality ne 'Kirkcaldy' and
Locality ne 'Levenmouth' and Locality ne 'North East Fife' and Locality ne 'South West Fife' Locality='Outside Partnership'.
if sending_location='Glasgow City' and Locality ne 'Glasgow City' and Locality ne '' and Locality ne 'Glasgow North East' and Locality ne 'Glasgow North West' and Locality ne 'Glasgow South' Locality='Outside Partnership'.
if sending_location='Highland' and Locality ne 'Highland' and Locality ne '' and Locality ne 'Badenoch and Strathspey' and Locality ne 'Caithness' and Locality ne 'East Ross' and Locality ne 'Inverness' and Locality ne 'Lochaber' and 
Locality ne 'Mid Ross' and Locality ne 'Nairn & Nairnshire' and Locality ne 'Skye, Lochalsh and West Ross' and Locality ne 'Sutherland' Locality='Outside Partnership'.
if sending_location='Inverclyde' and Locality ne 'Inverclyde' and Locality ne '' and Locality ne 'Inverclyde Central' and Locality ne 'Inverclyde East' and Locality ne 'Inverclyde West' Locality='Outside Partnership'.
if sending_location='Midlothian' and Locality ne 'Midlothian' and Locality ne '' and Locality ne 'Midlothian (East)' and Locality ne 'Midlothian (West)' Locality='Outside Partnership'.
if sending_location='Moray' and Locality ne 'Moray' and Locality ne '' and Locality ne 'Moray East' and Locality ne 'Moray West' Locality='Outside Partnership'.
if sending_location='North Ayrshire' and Locality ne 'North Ayrshire' and Locality ne '' and Locality ne 'Arran' and Locality ne 'Garnock Valley' and Locality ne 'Irvine' and Locality ne 'Kilwinning' and 
Locality ne 'North Coast & Cumbraes' and Locality ne 'Three Towns' Locality='Outside Partnership'.
if sending_location='North Lanarkshire' and Locality ne 'North Lanarkshire' and Locality ne '' and Locality ne 'Airdrie' and Locality ne 'Bellshill' and Locality ne 'Coatbridge' and Locality ne 'Motherwell' and 
Locality ne 'North Lanarkshire North' and Locality ne 'Wishaw' Locality='Outside Partnership'.
if sending_location='Orkney' and Locality ne 'Orkney' and Locality ne '' and Locality ne 'Isles' and Locality ne 'Orkney East' and Locality ne 'Orkney West' Locality='Outside Partnership'.
if sending_location='Perth & Kinross' and Locality ne 'Perth & Kinross' and Locality ne '' and Locality ne 'North Perthshire' and Locality ne 'Perth City' and Locality ne 'South Perthshire' Locality='Outside Partnership'.
if sending_location='Renfrewshire' and Locality ne 'Renfrewshire' and Locality ne '' and Locality ne 'Paisley' and Locality ne 'Renfrewshire North West and South' Locality='Outside Partnership'.
if sending_location='Shetland' and Locality ne 'Shetland' and Locality ne '' and Locality ne 'Central Mainland' and Locality ne 'Lerwick & Bressay' and Locality ne 'North Isles' and Locality ne 'North Mainland' and
Locality ne 'South Mainland' and Locality ne 'West Mainland' and Locality ne 'Whalsay & Skerries' Locality='Outside Partnership'.
if sending_location='South Ayrshire' and Locality ne 'South Ayrshire' and Locality ne '' and Locality ne 'Ayr North and Former Coalfield Communities' and Locality ne 'Ayr South and Coylton' and
Locality ne 'Girvan and South Carrick Villages' and Locality ne 'Maybole and North Carrick Communities' and Locality ne 'Prestwick' and Locality ne 'Troon' Locality='Outside Partnership'.
if sending_location='South Lanarkshire' and Locality ne 'South Lanarkshire' and Locality ne '' and Locality ne 'Clydesdale' and Locality ne 'East Kilbride' and Locality ne 'Hamilton' and 
Locality ne 'Rutherglen Cambuslang' Locality='Outside Partnership'.
if sending_location='Stirling' and Locality ne 'Stirling' and Locality ne '' and Locality ne 'Rural Stirling' and Locality ne 'Stirling City with the Eastern Villages Bridge of Allan and Dunblane' Locality='Outside Partnership'.
if sending_location='West Dunbartonshire' and Locality ne 'West Dunbartonshire' and Locality ne '' and Locality ne 'Clydebank' and Locality ne 'Dumbarton/Alexandria' Locality='Outside Partnership'.
if sending_location='West Lothian' and Locality ne 'West Lothian' and Locality ne '' and Locality ne 'West Lothian (East)' and Locality ne 'West Lothian (West)' Locality='Outside Partnership'.
if sending_location='Western Isles' and Locality ne 'Western Isles' and Locality ne '' and Locality ne 'Barra' and Locality ne 'Harris' and Locality ne 'Rural Lewis' and 
Locality ne 'Stornoway & Broadbay' and Locality ne 'Uist' Locality='Outside Partnership'.
execute.

 * if Locality='' Locality='Unknown'.
 * execute.

 * save outfile = !Outfile.

*Change partnership locality names to include HSCP on to the end of the name.
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
***********************************************************************************************************************************.
*Update numeric variables to 1 decimal place for dislpay on workbooks.
alter type Numerator (f8.1).
alter type Denominator (f8.1).
alter type Rate (f8.1).
 * alter type SupportfromUnpaidCarer (f8.1).
 * alter type SocialWorker (f8.1).
 * alter type Per_LivingAlone (f8.1).
 * alter type Per_SupportfromUnpaidCarer (f8.1).
 * alter type Per_SocialWorker (f8.1).
 * alter type Per_dementia (f8.1).
 * alter type clients_total (f8.1).
alter type perc (f8.1).
alter type NetCost (f8.1).
alter type GrossCost (f8.1).
alter type Percentage_clients (f8.1).
 * alter type Clients_denominator (f8.1).
alter type OOHAdvice (f8.1).
alter type OOHHomeV (f8.1).
alter type OOHPCC (f8.1).

*Update Out of Hours types so full name is displayed.
alter type OutOfHoursType (a80).
if OutOfHoursType='OOHAdvice' OutOfHoursType='Out of Hours Doctor/Nurse Advice'.
if OutOfHoursType='OOHHomeV' OutOfHoursType='Out of Hours Home Visit'.
if OutOfHoursType='OOHPCC' OutOfHoursType='Out of Hours Primary Care Emergency Centre/Primary Care Centre'.
execute.

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

*Update service type names for improved wording on display in dashboards.
alter type Servicetype (a50).
if Servicetype='both' Servicetype='Both'.
if Servicetype='All services' Servicetype='Total Community alarms and Telecare'.
execute.

*Rename variables to match 2017/18 names when adding files together.
rename variables OOHAdvice=OutofHours_Doctor_NurseAdvice.
rename variables OOHHomeV=OutofHours_HomeVisit.
rename variables OOHPCC=OutofHours_PrimaryCareEmergencyCentre_PrimaryCareCentre.

*Compute top 5 admission reason percentage variable for chart on Unscheduled Care 2 dashboard.
compute Top5_Adm_Perc=Adm/Adm_all_top5.
execute.

save outfile= !Outfile.

***********************************************************************************************************************************.
*Modify care home names to include capital and small case letters where appropriate, some manual changes also required where apostrophe included in name.
*###Commented out as already done by social care team. ### DC 21/01/21.

 * get file = !Outfile.

 * Begin Program.
 * import spss

 * # Open the dataset with write access
# Read in the CareHomeNames, which must be the first variable "spss.Cursor([10]..."
cur = spss.Cursor([32], accessType = 'w')

 * # Create a new variable, string length 73
cur.AllocNewVarsBuffer(80)
cur.SetOneVarNameAndType('ch_name_tidy', 73)
cur.CommitDictionary()

 * # Loop through every case and write the tidied care home name
for i in range(cur.GetCaseCount()):
    # Read a case and save the care home name
    # We need to strip trailing spaces
    care_home_name = cur.fetchone()[0].rstrip()

 *     # Write the tidied name to the SPSS dataset
    cur.SetValueChar('ch_name_tidy', str(care_home_name).title())
    cur.CommitCase()

 * # Close the connection to the dataset
cur.close() 
End Program.

 * delete variables CareHomeName.
 * rename variables ch_name_tidy=CareHomeName.
***********************************************************************************************************************************.
get file = !Outfile.
dataset name SocialCareMaster window = front.
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

*Only codes provided as care home names for below partnerships, so make care home name equal to locality to display data on charts.
*For West Lothian, some proper care home names were provided, as well as codes, the codes were manually deleted and when displayed as blank, inserted with locality name.
if File='Care Home' and sending_location='Aberdeen City' CareHomeName=Locality.
if File='Care Home' and sending_location='West Lothian' and CareHomeName='' CareHomeName=Locality.
execute.

save outfile = !Outfile.
***********************************************************************************************************************************.
 * Get file = !Outfile.

*Compute client percentage=rate for below Type.
 * if File='Home Care' and Type='Percentage of clients with one or more LTCs' Percentage_clients=Rate.
 * execute.

*Change AdmReason from numeric to string variable.
 * alter type AdmReason (a5).

 * compute AdmReason=LTRIM(AdmReason).
 * execute.

 * if File='Home Care' and AdmReason ne '' Type='Emergency admission reason'.
 * execute.

*Sort to fix Emergency bed day rate figures for HSCPs, change name of locality from Unknown to name of HSCP, File = Care Home.
 * sort cases by File (a) Type (a).

 * save outfile = !Outfile.

 * Get file = !Outfile.

*Modify Type for Care Home file, originally blank with top 5 admission reason, change type to Emergency admission reason.
 * if File='Care Home' and AdmReason ne '' Type='Emergency admission reason'.
 * execute.

 * if File='Care Home' and Type='Emergency admission reason' Locality=LocalityCH.
 * execute.

 * if File='Care Home' and Type='Emergency admission reason' and Locality='' Locality='Unknown'.
 * execute.

 * save outfile = !Outfile.

 * Get file = !Outfile.

 * if File='Equipment' and simd2016_HSCP2016_quintile ne '' Type='Deprivation profile (SIMD quintiles)'.
 * execute.

 * if File='Equipment' and Type='Percentage of clients with one or more LTCs' Percentage_clients=Rate.
 * execute.

 * if File='Equipment' and AdmReason ne '' Type='Emergency admission reason'.
 * execute.

 * if File='Equipment' and Type='Out of Hours' and Locality='Unknown' Locality=sending_location.
 * execute.

 * save outfile = !Outfile.

*Equipment, A&E attendance rate, Emergency admission rate and Emergency bed day rate.
 * Get file = !Outfile.

*Select out three Types of interest in the Equipment workbook.
 * select if File='Equipment'.
 * execute.

 * select if Type='A&E attendance rate' or Type='Emergency admission rates' or Type='Emergency bed day rate'.
 * execute.

*Select only locality information.
 * select if Locality ne sending_location.
 * execute.

 * save outfile = '/conf/social-care/05-Analysts/Social Care Dashboard/Social Care Dashboard v3/Equipment_Locality.sav'.

 * Get file = !Outfile.

*Now repeat for HSCPs.
 * select if File='Equipment'.
 * execute.

 * select if Type='A&E attendance rate' or Type='Emergency admission rates' or Type='Emergency bed day rate'.
 * execute.

 * if Locality='Clackmannanshire' Locality='Clackmannanshire HSCP'.
 * execute.

 * select if Locality ne sending_location.
 * execute.

 * compute EQ_File=sysmis(EQ_File).
 * compute EQ_File=1.
 * execute.

*Aggregate for HSCPs in order to calculate denomiantors and rates as they were not in the initial file.
 * aggregate outfile=*
/break sending_location Area LocalityCH Type Sex Age_Band NursingCareProvision LivingAlone SupportfromUnpaidCarer SocialWorker total Per_LivingAlone Per_SupportfromUnpaidCarer Per_SocialWorker
File Dementia Per_Dementia simd2016_HSCP2016_quintile UR2_2016 hours_band Servicetype Clients HC clients_total perc Option NetCost GrossCost breakdown_2 Percentage_clients breakdown_type_2 LTCNo
Clients_denominator AEReferralSource diag EQ_File urbanrural diagdescript LA SDS SPARRA Adm top5 Adm_all_top5 ClientTypeBreakdownCount ClientTypeBreakdown LTCTypeBreakdown LTCTypeCount OutofHoursType
OutofHoursCount OOHAdvice OOHHomeV OOHPCC LocalityCareHomePopulation CareHomeName
/Numerator=sum(Numerator)
/Denominator=sum(Denominator).
 * execute.

 * string Locality (a68).
 * compute Locality=sending_location.
 * execute.

 * compute Rate=(Numerator/Denominator)*1000.
 * execute.

 * string LOOKUP (a100).
 * compute LOOKUP=concat(File,Locality,Type).
 * execute.

 * save outfile = '/conf/social-care/05-Analysts/Social Care Dashboard/Social Care Dashboard v3/Equipment_HSCP.sav'.

*Add both files together to get locality and HSCP information.
 * add files file = '/conf/social-care/05-Analysts/Social Care Dashboard/Social Care Dashboard v3/Equipment_Locality.sav'
/file = '/conf/social-care/05-Analysts/Social Care Dashboard/Social Care Dashboard v3/Equipment_HSCP.sav'.
 * execute.

 * save outfile = '/conf/social-care/05-Analysts/Social Care Dashboard/Social Care Dashboard v3/Equipment_All.sav'.

 * Get file = !Outfile.

*Exclude identical information from main file so custom file can be added without any issues. 
 * compute flag=0.
 * if File='Equipment' and Type='A&E attendance rate' or File='Equipment' and Type='Emergency admission rates' or File='Equipment' and Type='Emergency bed day rate' Flag=1.
 * execute.

 * select if Flag=0.
 * execute.

 * delete variables Flag.

*Add custom file to main social care file.
 * add files file = *
/file = '/conf/social-care/05-Analysts/Social Care Dashboard/Social Care Dashboard v3/Equipment_All.sav'.
 * execute.

 * save outfile = !Outfile.

 * GET FILE='/conf/social-care/05-Analysts/Social Care Dashboard/Social Care Dashboard v3/SocialCare3.sav'.

 * get file = !Outfile.

 * select if Age_band='All ages'.
 * execute.

 * save outfile = !Outfile.

 * get file = !Outfile.

 * sort cases by File (a) Type (a).

 * GET
  FILE='/conf/sourcedev/TableauUpdates/Social Care/Outputs/all_outputs_merged_Mar20_final.zsav'.
 * DATASET NAME SocialCareMaster WINDOW=FRONT.

 * select if File='Equipment' and Type='Home Care'.
 * execute.

 * select if File='Home Care'.
 * execute.

 * get file = !Outfile.

 * select if File='Equipment'.
 * execute.

 * select if Type='Emergency admission rates' or Type='Emergency bed day rate'.
 * execute.

 * select if Type='Emergency bed day rate' or Type='A&E attendance rate' or Type='Emergency admission rates'.
 * execute.

 * select if Type='Emergency admission reason'.
 * execute.

 * select if AdmReason ne ''.
 * execute.

 * select if Type='Emergency admission reason'.
 * execute.

 * select if File='SD'.
 * execute.

 * sort cases by Locality (a) AdmReason (d).

 * get file = !Outfile.

 * select if Age_band ne 'All ages'.
 * execute.

 * if Age_band='0-64' Age_band='All Ages'.
 * if Age_band='65-74' Age_band='All Ages'.
 * if Age_band='75-84' Age_band='All Ages'.
 * if Age_band='85+' Age_band='All Ages'.
 * execute.

 * aggregate outfile=*
/break Locality sending_location Area LocalityCH Type Sex Age_Band NursingCareProvision File simd2016_HSCP2016_quintile UR2_2016 hours_band Servicetype HC Option 
breakdown_2 breakdown_type_2 LTCNo AEReferralSource urbanrural LA diagdescript AdmReason ClientTypeBreakdown LTCTypeBreakdown OutofHoursType CareHomeName
/Numerator=sum(Numerator)
/Denominator=sum(Denominator)
/LivingAlone=sum(LivingAlone)
/SupportfromUnpaidCarer=sum(SupportfromUnpaidCarer)
/SocialWorker=sum(SocialWorker)
/total=sum(total)
/Per_LivingAlone=sum(Per_LivingAlone)
/Per_SupportfromUnpaidCarer=sum(Per_SupportfromUnpaidCarer)
/Per_SocialWorker=sum(Per_SocialWorker)
/Dementia=sum(Dementia)
/Per_Dementia=sum(Per_Dementia)
/Clients=sum(Clients)
/clients_total=sum(clients_total)
/perc=sum(perc)
/NetCost=sum(NetCost)
/GrossCost=sum(GrossCost)
/Percentage_clients=sum(Percentage_clients)
/Clients_denominator=sum(Clients_denominator)
/diag2=sum(diag2)
/EQ_File=sum(EQ_File)
/ClientTypeBreakdownCount=sum(ClientTypeBreakdownCount)
/LTCTypeCount=sum(LTCTypeCount)
/OutofHoursCount=sum(OutofHoursCount)
/OOHAdvice=sum(OOHAdvice)
/OOHHomeV=sum(OOHHomeV)
/OOHPCC=sum(OOHPCC)
/LocalityCareHomePopulation=sum(LocalityCareHomePopulation).
 * execute.

 * compute Rate=(Numerator/Denominator)*1000.
 * execute.

 * get file = !Outfile.

 * select if File='Equipment'.
 * execute.

 * select if Type='Home Care'.
 * execute.

 * select if Locality=sending_location.
 * execute.

 * select if Servicetype ne 'All services'.
 * execute.

 * compute Servicetype='All services'.
 * execute.

 * aggregate outfile=*
/break Locality sending_location Area LocalityCH Numerator Denominator Rate Type Sex Age_Band NursingCareProvision LivingAlone SupportfromUnpaidCarer SocialWorker total Per_LivingAlone Per_SupportfromUnpaidCarer Per_SocialWorker
File Dementia Per_Dementia simd2016_HSCP2016_quintile UR2_2016 hours_band Servicetype HC Option NetCost GrossCost breakdown_2 Percentage_clients breakdown_type_2 LTCNo
Clients_denominator AEReferralSource diag EQ_File urbanrural LA diagdescript SDS SPARRA Adm top5 Adm_all_top5 ClientTypeBreakdownCount ClientTypeBreakdown LTCTypeBreakdown LTCTypeCount OutofHoursType
OutofHoursCount OOHAdvice OOHHomeV OOHPCC LocalityCareHomePopulation CareHomeName
/clients=sum(clients)
/clients_total=sum(clients_total).
 * execute.

 * compute perc=(clients/clients_total)*100.
 * execute.

 * select if sending_location ne 'Clackmannanshire'.
 * execute.

 * save outfile = '/conf/social-care/05-Analysts/Social Care Dashboard/Social Care Dashboard v3/Equipment_HomeCare_HSCP.sav'.

 * add files file = !Outfile
/file = '/conf/social-care/05-Analysts/Social Care Dashboard/Social Care Dashboard v3/Equipment_HomeCare_HSCP.sav'.
 * execute.

 * save outfile = !Outfile.

 * get file = !Outfile.

 * select if File='Equipment' and Type='Home Care'.
 * execute.

*Manual check to remove additional rows for file=Equipment and type=Home Care, percentages and client totals also modified. Will see if there is a fix that can be done in SPSS in future.
 * sort cases by File (a) Type (a) Locality (a) Servicetype (a).

 * save outfile = !Outfile.

*Add in all services totals for locality=HSCP in order to fix deprivation chart.
 * get file = !Outfile.

 * select if File='Equipment' and Type='Deprivation profile (SIMD quintiles)'.
 * execute.

 * select if Locality=sending_location.
 * execute.

 * select if Locality ne 'Clackmannanshire'.
 * execute.

 * compute Servicetype='All services'.
 * execute.

*Aggregate for HSCPs in order to calculate denomiantors and rates as they were not in the initial file.
 * aggregate outfile=*
/break Locality sending_location Area LocalityCH Type Sex Age_Band NursingCareProvision LivingAlone SupportfromUnpaidCarer SocialWorker total Per_LivingAlone Per_SupportfromUnpaidCarer Per_SocialWorker
File Dementia Per_Dementia simd2016_HSCP2016_quintile UR2_2016 hours_band Servicetype Clients HC clients_total perc Option NetCost GrossCost breakdown_2 Percentage_clients breakdown_type_2 LTCNo
Clients_denominator AEReferralSource diag EQ_File urbanrural diagdescript LA SDS SPARRA Adm top5 Adm_all_top5 ClientTypeBreakdownCount ClientTypeBreakdown LTCTypeBreakdown LTCTypeCount OutofHoursType
OutofHoursCount OOHAdvice OOHHomeV OOHPCC LocalityCareHomePopulation CareHomeName
/Numerator=sum(Numerator)
/Denominator=sum(Denominator).
 * execute.

 * compute Rate=(Numerator/Denominator)*1000.
 * execute.

 * string LOOKUP (a100).
 * compute LOOKUP=concat(File,Locality,Type).
 * execute.

 * save outfile = '/conf/social-care/05-Analysts/Social Care Dashboard/Social Care Dashboard v3/Equipment_Deprivation_HSCP_AllServices.sav'.

 * add files file = !Outfile
/file = '/conf/social-care/05-Analysts/Social Care Dashboard/Social Care Dashboard v3/Equipment_Deprivation_HSCP_AllServices.sav'.
 * execute.

 * save outfile = !Outfile.

*Remove records where care home name is null for age and gender breakdown, causing double counting in charts.
 * get file = !Outfile.

 * compute flag=0.
 * if File='Care Home' and Type='Age and gender breakdown' and Locality ne 'Outside Partnership' and CareHomeName='' flag=1.
 * execute.

 * select if flag=0.
 * execute.

 * delete variables flag.

 * save outfile = !Outfile.

***********************************************UPDATE based on Ag feedback for CH. 22/02/21**********************************************.
*UPDATE FOR GLASGOW 1819. DC 22/02/21.
***********************************************************************************************************************************.
*Modify OOH percentages when care home name = locality to ensure percentage is limited to 100%.
dataset close all.
get file = !Outfile.
dataset name SocialCareMaster window = front.

 * select if File='Care Home'.
 * select if Type='Out of Hours'.
 * execute.

sort cases by File (a) Type (a) sending_location (a) period (a).

compute OutOfHoursCount_CH=0.
if File='Care Home' OutOfHoursCount_CH=OutOfHoursCount.
execute.

*Modify OOH count due to care home name=locality for Aberdeen City HSCP, Edinburgh City HSCP and West Lothian HSCP all others remain unchanged 2017/18.
 * if Locality='Aberdeen Central' OutOfHoursCount_CH=OutOfHoursCount_CH/57.
 * if Locality='Aberdeen North' OutOfHoursCount_CH=OutOfHoursCount_CH/17.
 * if Locality='Aberdeen South' OutOfHoursCount_CH=OutOfHoursCount_CH/29.
 * if Locality='Aberdeen West' OutOfHoursCount_CH=OutOfHoursCount_CH/32.
 * if sending_location='Aberdeen City' and Locality='Outside Partnership' OutOfHoursCount_CH=OutOfHoursCount_CH/57.
 * if sending_location='Aberdeen City' and Locality='Unknown' OutOfHoursCount_CH=OutOfHoursCount_CH/2.
 * execute.

 * if Locality='West Lothian (East)' OutOfHoursCount_CH=OutOfHoursCount_CH/37.
 * if Locality='West Lothian (West)' OutOfHoursCount_CH=OutOfHoursCount_CH/28.
 * if sending_location='West Lothian' and Locality='Outside Partnership' OutOfHoursCount_CH=OutOfHoursCount_CH/33.
 * if sending_location='West Lothian' and Locality='Unknown' OutOfHoursCount_CH=OutOfHoursCount_CH/2.
 * execute.

 * if Locality='Edinburgh North East' OutOfHoursCount_CH=OutOfHoursCount_CH/17.
 * if Locality='Edinburgh North West' OutOfHoursCount_CH=OutOfHoursCount_CH/20.
 * if Locality='Edinburgh South East' OutOfHoursCount_CH=OutOfHoursCount_CH/22.
 * if Locality='Edinburgh South West' OutOfHoursCount_CH=OutOfHoursCount_CH/11.
 * if sending_location='Edinburgh City' and Locality='Outside Partnership' OutOfHoursCount_CH=OutOfHoursCount_CH/81.
 * if sending_location='Edinburgh City' and Locality='Unknown' OutOfHoursCount_CH=OutOfHoursCount_CH/3.
 * execute.

*2018/19.
if File='Care Home' and Locality='Aberdeen Central' and period='2018/19 Q1' OutOfHoursCount_CH=OutOfHoursCount_CH/25.
if File='Care Home' and Locality='Aberdeen Central' and period='2018/19 Q2' OutOfHoursCount_CH=OutOfHoursCount_CH/16.
if File='Care Home' and Locality='Aberdeen Central' and period='2018/19 Q3' OutOfHoursCount_CH=OutOfHoursCount_CH/15.
if File='Care Home' and Locality='Aberdeen Central' and period='2018/19 Q4' OutOfHoursCount_CH=OutOfHoursCount_CH/17.

if File='Care Home' and Locality='Aberdeen North' and period='2018/19 Q1' OutOfHoursCount_CH=OutOfHoursCount_CH/23.
if File='Care Home' and Locality='Aberdeen North' and period='2018/19 Q2' OutOfHoursCount_CH=OutOfHoursCount_CH/19.
if File='Care Home' and Locality='Aberdeen North' and period='2018/19 Q3' OutOfHoursCount_CH=OutOfHoursCount_CH/23.
if File='Care Home' and Locality='Aberdeen North' and period='2018/19 Q4' OutOfHoursCount_CH=OutOfHoursCount_CH/16.

if File='Care Home' and Locality='Aberdeen South' and period='2018/19 Q1' OutOfHoursCount_CH=OutOfHoursCount_CH/24.
if File='Care Home' and Locality='Aberdeen South' and period='2018/19 Q2' OutOfHoursCount_CH=OutOfHoursCount_CH/29.
if File='Care Home' and Locality='Aberdeen South' and period='2018/19 Q3' OutOfHoursCount_CH=OutOfHoursCount_CH/26.
if File='Care Home' and Locality='Aberdeen South' and period='2018/19 Q4' OutOfHoursCount_CH=OutOfHoursCount_CH/29.

if File='Care Home' and sending_location='Aberdeen City' and Locality='Outside Partnership' and period='2018/19 Q1' OutOfHoursCount_CH=OutOfHoursCount_CH/38.
if File='Care Home' and sending_location='Aberdeen City' and Locality='Outside Partnership' and period='2018/19 Q2' OutOfHoursCount_CH=OutOfHoursCount_CH/27.
if File='Care Home' and sending_location='Aberdeen City' and Locality='Outside Partnership' and period='2018/19 Q3' OutOfHoursCount_CH=OutOfHoursCount_CH/34.
if File='Care Home' and sending_location='Aberdeen City' and Locality='Outside Partnership' and period='2018/19 Q4' OutOfHoursCount_CH=OutOfHoursCount_CH/41.
execute.

if File='Care Home' and Locality='West Lothian (East)' and CareHomeName='West Lothian (East)' and period='2018/19 Q1' OutOfHoursCount_CH=OutOfHoursCount_CH/14.
if File='Care Home' and Locality='West Lothian (East)' and CareHomeName='West Lothian (East)' and period='2018/19 Q2' OutOfHoursCount_CH=OutOfHoursCount_CH/14.
 * if Locality='West Lothian (East)' and CareHomeName='West Lothian (East)' and period='2018/19 Q3' OutOfHoursCount_CH=OutOfHoursCount_CH/37.
 * if Locality='West Lothian (East)' and CareHomeName='West Lothian (East)' andperiod='2018/19 Q4' OutOfHoursCount_CH=OutOfHoursCount_CH/37.
execute.

if File='Care Home' and Locality='West Lothian (West)' and CareHomeName='West Lothian (West)' and period='2018/19 Q1' OutOfHoursCount_CH=OutOfHoursCount_CH/13.
if File='Care Home' and Locality='West Lothian (West)' and CareHomeName='West Lothian (West)' and period='2018/19 Q2' OutOfHoursCount_CH=OutOfHoursCount_CH/8.
 * if Locality='West Lothian (West)' and CareHomeName='West Lothian (West)' and period='2018/19 Q3' OutOfHoursCount_CH=OutOfHoursCount_CH/28.
 * if Locality='West Lothian (West)' and CareHomeName='West Lothian (West)' and period='2018/19 Q4' OutOfHoursCount_CH=OutOfHoursCount_CH/28.
execute.

if File='Care Home' and sending_location='West Lothian' and Locality='Outside Partnership' and CareHomeName='Outside Partnership' and period='2018/19 Q1' OutOfHoursCount_CH=OutOfHoursCount_CH/14.
if File='Care Home' and sending_location='West Lothian' and Locality='Outside Partnership' and CareHomeName='Outside Partnership' and period='2018/19 Q2' OutOfHoursCount_CH=OutOfHoursCount_CH/14.
 * if sending_location='West Lothian' and Locality='Outside Partnership' and CareHomeName='Outside Partnership' and period='2018/19 Q3' OutOfHoursCount_CH=OutOfHoursCount_CH/33.
 * if sending_location='West Lothian' and Locality='Outside Partnership' and CareHomeName='Outside Partnership' and period='2018/19 Q4' OutOfHoursCount_CH=OutOfHoursCount_CH/33.
execute.

alter type OutOfHoursCount_CH (f8.1).

save outfile = !Outfile.
***********************************************************************************************************************************.
*Manually update Care Home AE Referral Source when care home name = locality to ensure percentage is limited to 100%.
*Affects records where Care Home name = Locality (ie no care home name was submitted) - so Aberdeen City & West Lothian.
*Get SPSS file, select if Type = 'A&E referral source' and HSCP = Aberdeen City or West Lothian.
dataset close all.
get file = !Outfile.
dataset name master window = front.

select if File = 'Care Home' and Type = 'A&E referral source' and (sending_location = 'Aberdeen City' or sending_location = 'West Lothian').
execute.

*Keep only relevant variables.
add files file = *
/keep sending_location Locality LocalityCH CareHomeName period File Type Numerator Denominator Rate AEReferralSource
LOOKUP.
execute.

Sort cases by sending_location LocalityCH CareHomeName period AEReferralSource.
*Notice that for Q1, Aberdeen Central (localityCH), and Aberdeen Central (Care Home Name) there are multiple rows for each referral source.
*These need to be aggregated so 1 row per referral source, with new numerators, denominators and rates calculated.

*First, create totals per referral source.
aggregate outfile = * 
/break sending_location Locality LocalityCH CareHomeName period File Type AEReferralSource LOOKUP
/Numerator = sum(Numerator).
execute.
dataset name agg window = front.

*Then create denominator totals as a new variable (by dropping referral source from break line).
dataset activate agg.
aggregate outfile = * mode = addvariables
/break sending_location Locality LocalityCH CareHomeName period File Type LOOKUP
/Denominator = sum(Numerator).
execute.

*Recaluclate Rates.
dataset activate agg.
numeric Rate(f8.1).
compute Rate = (Numerator/Denominator)*100.
execute.

*Add back into main file.
dataset activate agg.
dataset close master.
get file = !Outfile.
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

***********************************************************************************************************************************.
if sending_location='Western Isles' sending_location='Comhairle nan Eilean Siar'.
if sending_location='Shetland' sending_location='Shetland Islands'.
execute.

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

save outfile = !Outfile.
***********************************************************************************************************************************.
*Sort A&E referral source for Aberdeen City, West Lothian and Edinburgh City localities as care home name=locality, percentages thrown off.
 * get file = !Outfile.

 * select if File='Care Home' and Type='A&E referral source'.
 * execute.

 * save outfile = !Outfile.

 * get file = !Outfile.

 * if diagdescript='Unknown' diagdescript='Other/Unknown'.
 * execute.

 * save outfile = !Outfile.

*Select out Aberdeenshire SDS data and save as a separate file in case required in future, for 2017/18 only.
 * get file = !Outfile.

 * select if File='Self Directed Support' and sending_location='Aberdeenshire'.
 * execute.

 * save outfile = '/conf/sourcedev/TableauUpdates/Social Care/Outputs/Aberdeenshire_Data1718.sav'.

*Remove Aberdeenshire SDS data from data source as this contains errors. This is the case for 2017/18 and 2018/19 data.
 * get file = !Outfile.

 * compute flag=0.
 * if File='Self Directed Support' and sending_location='Aberdeenshire' flag=1.
 * execute.

 * select if flag=0.
 * execute.

 * delete variables flag.

 * save outfile = !Outfile.

 * get file = !Outfile.

*Remove cases in Equipment file for type = Percentage of clients with one or more LTCs.
 * sort cases by File (a) Type (a) sending_location (a).

 * save outfile = !Outfile.

*For some localities outwith where locality=care home name, the percentage is greater than 100%, review once workbooks are being checked.
 * get file = !Outfile.

 * select if File='Care Home'.
 * execute.

 * select if Type='Out of Hours'.
 * execute.

 * select if sending_location='Edinburgh City' or sending_location='West Lothian'.
 * execute.

*2017/18 list.
 * if File='Care Home' and Type='Out of Hours' and sending_location='Angus' and Locality='Outside Partnership' and CareHomeName='Redwood House Care Home' OutOfHoursCount_CH=OutOfHoursCount_CH/2.
 * if File='Care Home' and Type='Out of Hours' and sending_location='Argyll & Bute' and Locality='Outside Partnership' and CareHomeName='Arcadia Gardens Care Home' OutOfHoursCount_CH=OutOfHoursCount_CH/2.
 * if File='Care Home' and Type='Out of Hours' and sending_location='Argyll & Bute' and Locality='Outside Partnership' and CareHomeName='Ardenlee Residential Home' OutOfHoursCount_CH=OutOfHoursCount_CH/2.
 * if File='Care Home' and Type='Out of Hours' and sending_location='Argyll & Bute' and Locality='Outside Partnership' and CareHomeName='Balquhidder House Care Home' OutOfHoursCount_CH=OutOfHoursCount_CH/2.
 * if File='Care Home' and Type='Out of Hours' and sending_location='Dumfries & Galloway' and Locality='Unknown' and CareHomeName='' OutOfHoursCount_CH=OutOfHoursCount_CH/2.
 * if File='Care Home' and Type='Out of Hours' and sending_location='East Ayrshire' and Locality='Unknown' and CareHomeName='' OutOfHoursCount_CH=OutOfHoursCount_CH/2.
 * if File='Care Home' and Type='Out of Hours' and sending_location='East Renfrewshire' and Locality='Outside Partnership' and CareHomeName='Abbey Lodge Care Home' OutOfHoursCount_CH=OutOfHoursCount_CH/2.
 * if File='Care Home' and Type='Out of Hours' and sending_location='East Renfrewshire' and Locality='Outside Partnership' and CareHomeName='Lindsayfield Lodge Care Home' OutOfHoursCount_CH=OutOfHoursCount_CH/2.
 * if File='Care Home' and Type='Out of Hours' and sending_location='East Renfrewshire' and Locality='Outside Partnership' and CareHomeName='Westwood Care Home' OutOfHoursCount_CH=OutOfHoursCount_CH/2.
 * if File='Care Home' and Type='Out of Hours' and sending_location='East Renfrewshire' and Locality='Unknown' and CareHomeName='' OutOfHoursCount_CH=OutOfHoursCount_CH/2.
 * if File='Care Home' and Type='Out of Hours' and sending_location='Falkirk' and Locality='Falkirk Central' and CareHomeName='Carrondale Nursing Home' OutOfHoursCount_CH=OutOfHoursCount_CH/2.
 * if File='Care Home' and Type='Out of Hours' and sending_location='Falkirk' and Locality='Falkirk Central' and CareHomeName='Newcarron Court Care Home' OutOfHoursCount_CH=OutOfHoursCount_CH/2.
 * if File='Care Home' and Type='Out of Hours' and sending_location='Falkirk' and Locality='Falkirk East' and CareHomeName='Airthrey Care Nursing Home' OutOfHoursCount_CH=OutOfHoursCount_CH/2.
 * if File='Care Home' and Type='Out of Hours' and sending_location='Falkirk' and Locality='Falkirk East' and CareHomeName="St Margaret's" OutOfHoursCount_CH=OutOfHoursCount_CH/2.
 * if File='Care Home' and Type='Out of Hours' and sending_location='Falkirk' and Locality='Falkirk West' and CareHomeName='Balhousie Wheatlands' OutOfHoursCount_CH=OutOfHoursCount_CH/2.
 * if File='Care Home' and Type='Out of Hours' and sending_location='Falkirk' and Locality='Outside Partnership' and CareHomeName='Blackfaulds House Nursing Home' OutOfHoursCount_CH=OutOfHoursCount_CH/2.
 * if File='Care Home' and Type='Out of Hours' and sending_location='Falkirk' and Locality='Outside Partnership' and CareHomeName='Linlithgow Care Home' OutOfHoursCount_CH=OutOfHoursCount_CH/2.
 * if File='Care Home' and Type='Out of Hours' and sending_location='Falkirk' and Locality='Outside Partnership' and CareHomeName='The Erskine Home' OutOfHoursCount_CH=OutOfHoursCount_CH/2.
 * if File='Care Home' and Type='Out of Hours' and sending_location='Fife' and Locality='City of Dunfermline' and CareHomeName='The Beeches Nursing Home' OutOfHoursCount_CH=OutOfHoursCount_CH/2.
 * if File='Care Home' and Type='Out of Hours' and sending_location='Fife' and Locality='Cowdenbeath' and CareHomeName='Abbotsford Care Cowdenbeath' OutOfHoursCount_CH=OutOfHoursCount_CH/2.
 * if File='Care Home' and Type='Out of Hours' and sending_location='Fife' and Locality='Cowdenbeath' and CareHomeName='Craigie House.' OutOfHoursCount_CH=OutOfHoursCount_CH/2.
 * if File='Care Home' and Type='Out of Hours' and sending_location='Fife' and Locality='Cowdenbeath' and CareHomeName='Lister House' OutOfHoursCount_CH=OutOfHoursCount_CH/2.
 * if File='Care Home' and Type='Out of Hours' and sending_location='Fife' and Locality='Cowdenbeath' and CareHomeName='Ostlers House' OutOfHoursCount_CH=OutOfHoursCount_CH/2.
 * if File='Care Home' and Type='Out of Hours' and sending_location='Fife' and Locality='Cowdenbeath' and CareHomeName='Valley House' OutOfHoursCount_CH=OutOfHoursCount_CH/2.
 * if File='Care Home' and Type='Out of Hours' and sending_location='Fife' and Locality='Glenrothes' and CareHomeName='Abbotsford Care Kinglassie' OutOfHoursCount_CH=OutOfHoursCount_CH/2.
 * if File='Care Home' and Type='Out of Hours' and sending_location='Fife' and Locality='Glenrothes' and CareHomeName='Balfarg Care Centre' OutOfHoursCount_CH=OutOfHoursCount_CH/2.
 * if File='Care Home' and Type='Out of Hours' and sending_location='Fife' and Locality='Glenrothes' and CareHomeName='Finavon Court' OutOfHoursCount_CH=OutOfHoursCount_CH/2.
 * if File='Care Home' and Type='Out of Hours' and sending_location='Fife' and Locality='Glenrothes' and CareHomeName='Lomond Court Nursing Home' OutOfHoursCount_CH=OutOfHoursCount_CH/2.
 * if File='Care Home' and Type='Out of Hours' and sending_location='Fife' and Locality='Glenrothes' and CareHomeName='Napier House' OutOfHoursCount_CH=OutOfHoursCount_CH/2.
 * if File='Care Home' and Type='Out of Hours' and sending_location='Fife' and Locality='Glenrothes' and CareHomeName='Preston House' OutOfHoursCount_CH=OutOfHoursCount_CH/2.
 * if File='Care Home' and Type='Out of Hours' and sending_location='Fife' and Locality='Kirkcaldy' and CareHomeName='Raith Manor' OutOfHoursCount_CH=OutOfHoursCount_CH/2.
 * if File='Care Home' and Type='Out of Hours' and sending_location='Fife' and Locality='Levenmouth' and CareHomeName='Abbotsford Care East Wemyss' OutOfHoursCount_CH=OutOfHoursCount_CH/2.
 * if File='Care Home' and Type='Out of Hours' and sending_location='Fife' and Locality='Levenmouth' and CareHomeName='Auchtermairnie Care Home' OutOfHoursCount_CH=OutOfHoursCount_CH/2.
 * if File='Care Home' and Type='Out of Hours' and sending_location='Fife' and Locality='Levenmouth' and CareHomeName='Scoonie House' OutOfHoursCount_CH=OutOfHoursCount_CH/2.
 * if File='Care Home' and Type='Out of Hours' and sending_location='Fife' and Locality='North East Fife' and CareHomeName='Earlsferry House' OutOfHoursCount_CH=OutOfHoursCount_CH/2.
 * if File='Care Home' and Type='Out of Hours' and sending_location='Fife' and Locality='North East Fife' and CareHomeName='Ladywalk House' OutOfHoursCount_CH=OutOfHoursCount_CH/2.
 * if File='Care Home' and Type='Out of Hours' and sending_location='Fife' and Locality='North East Fife' and CareHomeName='Lomond View' OutOfHoursCount_CH=OutOfHoursCount_CH/2.
 * if File='Care Home' and Type='Out of Hours' and sending_location='Fife' and Locality='North East Fife' and CareHomeName='Northeden House' OutOfHoursCount_CH=OutOfHoursCount_CH/2.
 * if File='Care Home' and Type='Out of Hours' and sending_location='Fife' and Locality='North East Fife' and CareHomeName='Rosturk House' OutOfHoursCount_CH=OutOfHoursCount_CH/2.
 * if File='Care Home' and Type='Out of Hours' and sending_location='Fife' and Locality='North East Fife' and CareHomeName='St Andrews House Care Home' OutOfHoursCount_CH=OutOfHoursCount_CH/2.
 * if File='Care Home' and Type='Out of Hours' and sending_location='Fife' and Locality='North East Fife' and CareHomeName='Windmill House Nursing Home' OutOfHoursCount_CH=OutOfHoursCount_CH/2.
 * if File='Care Home' and Type='Out of Hours' and sending_location='Fife' and Locality='Outside Partnership' and CareHomeName='Ancaster House' OutOfHoursCount_CH=OutOfHoursCount_CH/2.
 * if File='Care Home' and Type='Out of Hours' and sending_location='Fife' and Locality='Outside Partnership' and CareHomeName='Cairdean House' OutOfHoursCount_CH=OutOfHoursCount_CH/2.
 * if File='Care Home' and Type='Out of Hours' and sending_location='Fife' and Locality='Outside Partnership' and CareHomeName='Moyness Nursing Home' OutOfHoursCount_CH=OutOfHoursCount_CH/2.
 * if File='Care Home' and Type='Out of Hours' and sending_location='Fife' and Locality='Outside Partnership' and CareHomeName='Wheatlands' OutOfHoursCount_CH=OutOfHoursCount_CH/2.
 * if File='Care Home' and Type='Out of Hours' and sending_location='Fife' and Locality='South West Fife' and CareHomeName='Bandrum Nursing Home' OutOfHoursCount_CH=OutOfHoursCount_CH/2.
 * if File='Care Home' and Type='Out of Hours' and sending_location='Fife' and Locality='South West Fife' and CareHomeName='Forth Bay' OutOfHoursCount_CH=OutOfHoursCount_CH/2.
 * if File='Care Home' and Type='Out of Hours' and sending_location='Fife' and Locality='Unknown' and CareHomeName='' OutOfHoursCount_CH=OutOfHoursCount_CH/2.
 * if File='Care Home' and Type='Out of Hours' and sending_location='Highland' and Locality='Inverness' and CareHomeName='Telford Centre' OutOfHoursCount_CH=OutOfHoursCount_CH/2.
 * if File='Care Home' and Type='Out of Hours' and sending_location='Highland' and Locality='Nairn & Nairnshire' and CareHomeName='Hebron House Nursing Home' OutOfHoursCount_CH=OutOfHoursCount_CH/2.
 * if File='Care Home' and Type='Out of Hours' and sending_location='Highland' and Locality='Outside Partnership' and CareHomeName='Abbeyside Nursing Home' OutOfHoursCount_CH=OutOfHoursCount_CH/2.
 * if File='Care Home' and Type='Out of Hours' and sending_location='Highland' and Locality='Outside Partnership' and CareHomeName='Balhousie Pitlochry Care Home' OutOfHoursCount_CH=OutOfHoursCount_CH/2.
 * if File='Care Home' and Type='Out of Hours' and sending_location='Highland' and Locality='Outside Partnership' and CareHomeName='Meadowlark Care Centre' OutOfHoursCount_CH=OutOfHoursCount_CH/2.
 * if File='Care Home' and Type='Out of Hours' and sending_location='Highland' and Locality='Outside Partnership' and CareHomeName='The Grove Care Home' OutOfHoursCount_CH=OutOfHoursCount_CH/2.
 * if File='Care Home' and Type='Out of Hours' and sending_location='Highland' and Locality='Skye, Lochalsh and West Ross' and CareHomeName='Lochbroom House' OutOfHoursCount_CH=OutOfHoursCount_CH/2.
 * if File='Care Home' and Type='Out of Hours' and sending_location='North Ayrshire' and Locality='North Coast & Cumbraes' and CareHomeName='Haylie House' OutOfHoursCount_CH=OutOfHoursCount_CH/2.
 * if File='Care Home' and Type='Out of Hours' and sending_location='North Ayrshire' and Locality='Outside Partnership' and CareHomeName='Erskine Home' OutOfHoursCount_CH=OutOfHoursCount_CH/2.
 * if File='Care Home' and Type='Out of Hours' and sending_location='North Lanarkshire' and Locality='North Lanarkshire North' and CareHomeName='Craig-En-Goyne Nursing Home' OutOfHoursCount_CH=OutOfHoursCount_CH/2.
 * if File='Care Home' and Type='Out of Hours' and sending_location='North Lanarkshire' and Locality='Outside Partnership' and CareHomeName='Campsie View Nursing Home' OutOfHoursCount_CH=OutOfHoursCount_CH/2.
 * if File='Care Home' and Type='Out of Hours' and sending_location='North Lanarkshire' and Locality='Outside Partnership' and CareHomeName='Golfhill Care Home' OutOfHoursCount_CH=OutOfHoursCount_CH/2.
 * if File='Care Home' and Type='Out of Hours' and sending_location='North Lanarkshire' and Locality='Outside Partnership' and CareHomeName='Mossvale Care Home' OutOfHoursCount_CH=OutOfHoursCount_CH/2.
 * if File='Care Home' and Type='Out of Hours' and sending_location='North Lanarkshire' and Locality='Outside Partnership' and CareHomeName='Springboig Care Home' OutOfHoursCount_CH=OutOfHoursCount_CH/2.
 * if File='Care Home' and Type='Out of Hours' and sending_location='Shetland Islands' and Locality='Central Mainland' and CareHomeName='Walter & Joan Gray Home' OutOfHoursCount_CH=OutOfHoursCount_CH/2.
 * if File='Care Home' and Type='Out of Hours' and sending_location='Shetland Islands' and Locality='Lerwick & Bressay' and CareHomeName='Edward Thomason House' OutOfHoursCount_CH=OutOfHoursCount_CH/2.
 * if File='Care Home' and Type='Out of Hours' and sending_location='Shetland Islands' and Locality='Lerwick & Bressay' and CareHomeName='Taing House' OutOfHoursCount_CH=OutOfHoursCount_CH/2.
 * if File='Care Home' and Type='Out of Hours' and sending_location='Shetland Islands' and Locality='North Mainland' and CareHomeName='North Haven Care Centre' OutOfHoursCount_CH=OutOfHoursCount_CH/2.
 * if File='Care Home' and Type='Out of Hours' and sending_location='Shetland Islands' and Locality='South Mainland' and CareHomeName='Overtonlea Care Centre' OutOfHoursCount_CH=OutOfHoursCount_CH/2.
 * if File='Care Home' and Type='Out of Hours' and sending_location='Shetland Islands' and Locality='West Mainland' and CareHomeName='Wastview Care Centre' OutOfHoursCount_CH=OutOfHoursCount_CH/2.
 * if File='Care Home' and Type='Out of Hours' and sending_location='South Ayrshire' and Locality='Prestwick' and CareHomeName='Heathfield Care Home' OutOfHoursCount_CH=OutOfHoursCount_CH/2.
 * if File='Care Home' and Type='Out of Hours' and sending_location='South Ayrshire' and Locality='Unknown' and CareHomeName='' OutOfHoursCount_CH=OutOfHoursCount_CH/2.
 * if File='Care Home' and Type='Out of Hours' and sending_location='South Lanarkshire' and Locality='Outside Partnership' and CareHomeName='Mearns House Care Home' OutOfHoursCount_CH=OutOfHoursCount_CH/2.
 * if File='Care Home' and Type='Out of Hours' and sending_location='South Lanarkshire' and Locality='Outside Partnership' and CareHomeName='Three Bridges Care Home' OutOfHoursCount_CH=OutOfHoursCount_CH/2.
 * if File='Care Home' and Type='Out of Hours' and sending_location='South Lanarkshire' and Locality='Unknown' and CareHomeName='' OutOfHoursCount_CH=OutOfHoursCount_CH/2.
 * if File='Care Home' and Type='Out of Hours' and sending_location='Stirling' and Locality='Stirling City with the Eastern Villages Bridge of Allan and Dunblane' and CareHomeName='Upper Springland' OutOfHoursCount_CH=OutOfHoursCount_CH/2.
 * if File='Care Home' and Type='Out of Hours' and sending_location='West Dunbartonshire' and Locality='Clydebank' and CareHomeName='Hillview Nursing Home' OutOfHoursCount_CH=OutOfHoursCount_CH/2.
 * execute.

 * save outfile = !Outfile.
