* Encoding: UTF-8.
*04. LCA-HRI-Activity. Health activities and costs breakdown.
*Orginally created by Kara Sellar 18/10/13.
 *Amended and updated by ML March 2013
*Amended and updated by Alison McClelland April 2015 for HRI-200,000-days. 
*Updated KR June 2015 for Tableau Workbook.
*FC Oct 2018. Updated Mental Health activity flag names to reflect changes in variable formats within Source Linkage File. 

Define !file()
     '/conf/sourcedev/TableauUpdates/HRI/Outputs/'
!Enddefine.

******************************************************************
**** MUST UPDATE THESE BEFORE RUNNING ********.

Define !HRIfile255075()
      !Quote(!Concat("/conf/sourcedev/TableauUpdates/HRI/Outputs/01-HRI-", !UnQuote(!Eval(!year)), "-255075.zsav")).
!Enddefine.

*Macro 1.
Define !year()
'201920'
!Enddefine.

Define !year2()
'2019/20'
!Enddefine.

*Macro 2.
Define !popyear()
'2019'
!Enddefine.

*Aim-  to calculate breakdown of activity and costs for each of the 11 health activity categories from the master HRI and AllPatients by gender and ageband 
for local council lca.

*****************************************************************************************************************************************************

**The following steps are repeated for each of the 11 health activities for HRIs and All Patients.
* Create high level summary by service type - Acute
                                                                  Mental Health
                                                                  GLS
                                                                  Maternity
                                                                  Outpatients
                                                                  A&E
                                                                  Community Prescribing 
                                                                  All Service types (Total)  
 * MIGHT BE BETTER CREATING SEPARATE TDE FOR THIS LEVEL.
*More detailed sub-servicve types -
Actute - Acute Daycase, Acute Inpatient Elective, Acute Inpatient Non Elective, 
Mental Health  - Mental Health Daycases, Mental Health Elective, Mental Health Non-Elective, 
GLS - GLS Daycase, GLS Elective, GLS Non Elective


* 1. Get the HRI or AllPatients file (for the HRI file, set lcaflag=1 so that the HRIs for Council lcas are selected) then for each the following steps are carried out.
* 2. Create the AgeBand Variable. 
* 3. Count the total cost of the Service, the total Episodes/Attendances/despensed items and the total beddays.
* 4. Compute Variables ActivityType and usertype to identify and differentiate health activity types and All and HRI patients.
* 5. Create aggregates to calculate totals for both genders, all ages, and all genders & all ages populations and add all these files together..
* 6 .For each health activity type add HRI and AllPatient files together
* 7. Add these files together to the main activity-cost file.
* 8.Rename lca variable to lca and recode any blank lca fields to null code 99.
****************************************************************************************************************************************************

** Create totals for each Service type and Threshold level

***Number 1- ALL: HRIs - 50%**************************************.
get file = !HRIfile255075.

*Add in localities.

sort cases by datazone.
execute.

rename variables datazone = datazone2011.
execute.

match files file = *
 /table = '/conf/linkage/output/lookups/Unicode/Geography/HSCP Locality/HSCP Localities_DZ11_Lookup_20200825.sav'
 /by datazone2011.
EXECUTE.

rename variables (datazone2011 hscplocality = datazone locality).
execute.

DELETE VARIABLES HSCP2019Name to CA2011.

if locality = '' locality = 'No Locality Information'.
 

save outfile = !HRIfile255075.
 
get file = !HRIfile255075.

*rename variables (datazone=datazone2011).
* 
*rename variables (datazone2001=datazone).
*alter type datazone (A9).
select if datazone ne ' '.

Select if LcaFlag50=1.
 

compute all_episodes = (acute_episodes + MH_episodes +gls_episodes + MAT_episodes + OP_newcons_attendances + AE_attendances + pis_dispensed_items).
compute all_beddays= (acute_inpatient_beddays + MH_inpatient_beddays +gls_inpatient_beddays + MAT_inpatient_beddays).
 

Aggregate outfile=* 
               /break=locality Lca AgeBand
               /Total_Cost = Sum(health_net_cost)   
               /Episodes_Attendances=Sum(ALL_episodes)
               /Beddays=Sum(ALL_beddays)
               /NumberPatients = n.


String UserType (A11).
Compute UserType='LCA-HRI_50'.
String ServiceType (A30).
 Compute ServiceType='All'.
 

Save outfile=!file+'/10-All-costs-HRI_DZ50.zsav'
/zcompressed.

***Number 1- ALL: HRIs - 65%**************************************.

get file = !HRIfile255075.

select if datazone ne ' '.
Select if LcaFlag65=1.

compute all_episodes = (acute_episodes + MH_episodes +gls_episodes + MAT_episodes + OP_newcons_attendances + AE_attendances + pis_dispensed_items).
compute all_beddays= (acute_inpatient_beddays + MH_inpatient_beddays +gls_inpatient_beddays + MAT_inpatient_beddays).
 

Aggregate outfile=* 
               /break=locality Lca AgeBand
               /Total_Cost = Sum(health_net_cost)   
               /Episodes_Attendances=Sum(ALL_episodes)
               /Beddays=Sum(ALL_beddays)
               /NumberPatients = n.

String UserType (A11).
Compute UserType='LCA-HRI_65'.
String ServiceType (A30).
Compute ServiceType='All'.
 

Save outfile=!file+'/10-All-costs-HRI_DZ65.zsav'
/zcompressed.

***Number 1- ALL: HRIs - 80%**************************************.
get file = !HRIfile255075.

select if datazone ne ' '.
Select if LcaFlag80=1.

compute all_episodes = (acute_episodes + MH_episodes +gls_episodes + MAT_episodes + OP_newcons_attendances + AE_attendances + pis_dispensed_items).
compute all_beddays= (acute_inpatient_beddays + MH_inpatient_beddays +gls_inpatient_beddays + MAT_inpatient_beddays).
 

Aggregate outfile=* 
               /break=locality Lca AgeBand
               /Total_Cost = Sum(health_net_cost)   
               /Episodes_Attendances=Sum(ALL_episodes)
               /Beddays=Sum(ALL_beddays)
               /NumberPatients = n.

String UserType (A11).
Compute UserType='LCA-HRI_80'.
String ServiceType (A30).
Compute ServiceType='All'.
 

Save outfile=!file+'/10-All-costs-HRI_DZ80.zsav'
/zcompressed.

***Number 1- ACUTE: HRIs - 95%**************************************.
get file = !HRIfile255075.

select if datazone ne ' '.
Select if LcaFlag95=1.


compute all_episodes = (acute_episodes + MH_episodes +gls_episodes + MAT_episodes + OP_newcons_attendances + AE_attendances + pis_dispensed_items).
compute all_beddays= (acute_inpatient_beddays + MH_inpatient_beddays +gls_inpatient_beddays + MAT_inpatient_beddays).
 

Aggregate outfile=* 
               /break=locality Lca AgeBand
               /Total_Cost = Sum(health_net_cost)   
               /Episodes_Attendances=Sum(ALL_episodes)
               /Beddays=Sum(ALL_beddays)
               /NumberPatients = n.


String UserType (A11).
Compute UserType='LCA-HRI_95'.
String ServiceType (A30).
Compute ServiceType='All'.
 

Save outfile=!file+'/10-All-costs-HRI_DZ95.zsav'
/zcompressed.

***Number 1- ACUTE: HRIs - 100% (ALL Patients**************************************.
get file = !HRIfile255075.

select if datazone ne ' '.
 

compute all_episodes = (acute_episodes + MH_episodes +gls_episodes + MAT_episodes + OP_newcons_attendances + AE_attendances + pis_dispensed_items).
compute all_beddays= (acute_inpatient_beddays + MH_inpatient_beddays +gls_inpatient_beddays + MAT_inpatient_beddays).
 

Aggregate outfile=* 
               /break=locality Lca AgeBand
               /Total_Cost = Sum(health_net_cost)   
               /Episodes_Attendances=Sum(ALL_episodes)
               /Beddays=Sum(ALL_beddays)
               /NumberPatients = n.


String UserType (A11).
Compute UserType='LCA-HRI_ALL'.
String ServiceType (A30).
Compute ServiceType='All'.
 

Save outfile=!file+'/10-All-costs-HRI_DZALL.zsav'
/zcompressed.


** Bring all Locality files together and create totals.

add files file =!file+'/10-All-costs-HRI_DZALL.zsav'
 /file =!file+'/10-All-costs-HRI_DZ50.zsav'
 /file =!file+'/10-All-costs-HRI_DZ65.zsav'
 /file =!file+'/10-All-costs-HRI_DZ80.zsav'
 /file =!file+'/10-All-costs-HRI_DZ95.zsav'.
 

Save outfile=!file+'/10-All-costs-HRI_DZ_Temp1.zsav'
/zcompressed.

compute ageband = 'All ages'.
aggregate outfile=!file+'/10-All-costs-HRI_DZ_Temp2.zsav'
 /break= locality lca AgeBand UserType ServiceType
 /Total_Cost=Sum(Total_Cost)
 /Episodes_Attendances=Sum(Episodes_Attendances)
 /Beddays = sum(Beddays)
 /NumberPatients =sum(NumberPatients).


add files file =!file+'/10-All-costs-HRI_DZ_Temp1.zsav'
 /file =!file+'/10-All-costs-HRI_DZ_Temp2.zsav'.
  

Save outfile=!file+'/10-All-costs-HRI_DZ_Final.zsav'
/zcompressed.

********************************

Get file=!file+'/10-All-costs-HRI_DZ_Final.zsav'.


* Create year.
String Year (a7).
compute Year = !year2.
*add LA Name.
string LCAname (a25).
if lca eq '01' LCAname eq 'Aberdeen City'.
if lca eq '02' LCAname eq 'Aberdeenshire'.
if lca eq '03' LCAname eq 'Angus'.
if lca eq '04' LCAname eq 'Argyll & Bute'.
if lca eq '05' LCAname eq 'Scottish Borders'.
if lca eq '06' LCAname eq 'Clackmannanshire'.
if lca eq '07' LCAname eq 'West Dunbartonshire'.
if lca eq '08' LCAname eq 'Dumfries & Galloway'.
if lca eq '09' LCAname eq 'Dundee City'.
if lca eq '10' LCAname eq 'East Ayrshire'.
if lca eq '11' LCAname eq 'East Dunbartonshire'.
if lca eq '12' LCAname eq 'East Lothian'.
if lca eq '13' LCAname eq 'East Renfrewshire'.
if lca eq '14' LCAname eq 'City of Edinburgh'.
if lca eq '15' LCAname eq 'Falkirk'.
if lca eq '16' LCAname eq 'Fife'.
if lca eq '17' LCAname eq 'Glasgow City'.
if lca eq '18' LCAname eq 'Highland'.
if lca eq '19' LCAname eq 'Inverclyde'.
if lca eq '20' LCAname eq 'Midlothian'.
if lca eq '21' LCAname eq 'Moray'.
if lca eq '22' LCAname eq 'North Ayrshire'.
if lca eq '23' LCAname eq 'North Lanarkshire'.
if lca eq '24' LCAname eq 'Orkney'.
if lca eq '25' LCAname eq 'Perth & Kinross'.
if lca eq '26' LCAname eq 'Renfrewshire'.
if lca eq '27' LCAname eq 'Shetland'.
if lca eq '28' LCAname eq 'South Ayrshire'.
if lca eq '29' LCAname eq 'South Lanarkshire'.
if lca eq '30' LCAname eq 'Stirling'.
if lca eq '31' LCAname eq 'West Lothian'.
if lca eq '32' LCAname eq 'Western Isles'.
if lca eq ' 1' LCAname eq 'Aberdeen City'.
if lca eq ' 2' LCAname eq 'Aberdeenshire'.
if lca eq ' 3' LCAname eq 'Angus'.
if lca eq ' 4' LCAname eq 'Argyll & Bute'.
if lca eq ' 5' LCAname eq 'Scottish Borders'.
if lca eq ' 6' LCAname eq 'Clackmannanshire'.
if lca eq ' 7' LCAname eq 'West Dunbartonshire'.
if lca eq ' 8' LCAname eq 'Dumfries & Galloway'.
if lca eq ' 9' LCAname eq 'Dundee City'.
if LCAname = '' LCAname = 'Non LCA'.
 
*frequency variables = LCAname.


***FC Oct. 2018. Updated Fife and Perth & Kinross LA codes according to Source Linkage file.
String LA_CODE (a9).
if LCAname = 'Scottish Borders' LA_CODE = 'S12000026'.
if LCAname = 'Fife' LA_CODE = 'S12000015'.
if LCAname = 'Orkney' LA_CODE = 'S12000023'.
if LCAname = 'Western Isles' LA_CODE = 'S12000013'.
if LCAname = 'Dumfries & Galloway' LA_CODE = 'S12000006'.
if LCAname = 'Shetland' LA_CODE = 'S12000027'.
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
if LCAname = 'City of Edinburgh' LA_CODE = 'S12000036'.
if LCAname = 'Perth & Kinross' LA_CODE = 'S12000024'.
if LCAname = 'Dundee City' LA_CODE = 'S12000042'.
if LCAname = 'Angus' LA_CODE = 'S12000041'.
if LCAname = 'Clackmannanshire' LA_CODE = 'S12000005'.
if LCAname = 'Falkirk' LA_CODE = 'S12000014'.
if LCAname = 'Stirling' LA_CODE = 'S12000030'.
 

String HBname (a40).
if any (LCAname, 'North Ayrshire', 'South Ayrshire', 'East Ayrshire') HBname eq 'Ayrshire & Arran Region'.
if LCAname eq 'Scottish Borders'   HBname eq  'Borders Region'.
if LCAname eq 'Dumfries & Galloway'    HBNAME eq  'Dumfries & Galloway Region'.
if LCAname eq 'Fife'    HBNAME =  'Fife Region'.
if any (LCAname, 'Stirling', 'Falkirk', 'Clackmannanshire')  HBNAME eq 'Forth Valley Region'.
if any (LCAname, 'Aberdeen City', 'Aberdeenshire', 'Moray') HBNAME eq  'Grampian Region'.
if any (LCAname, 'Glasgow City', 'East Dunbartonshire', 'Renfrewshire', 'East Renfrewshire', 'West Dunbartonshire', 'Inverclyde', 'Renfrewshire') HBname eq 'Greater Glasgow & Clyde Region'.
if any (LCAname, 'Argyll & Bute', 'Highland') HBname eq 'Highland Region'.
if any (LCAname, 'South Lanarkshire', 'North Lanarkshire') HBname eq 'Lanarkshire Region'.
if any (LCAname, 'City of Edinburgh', 'East Lothian', 'Midlothian', 'West Lothian') HBname eq 'Lothian Region'.
if LCAname eq 'Orkney'  HBNAME eq  'Orkney Region'.
if LCAname eq 'Shetland'  HBNAME eq  'Shetland Region'.
if any (LCAname, 'Angus', 'Perth & Kinross', 'Dundee City') HBname eq 'Tayside Region'.
if LCaname eq 'Western Isles'   HBNAME eq 'Western Isles Region'.
 

*frequencies variables =HBname.

String HB_CODE (a9).

if HBname = 'Ayrshire & Arran Region'             HB_CODE =  'S08000015'.
if HBname = 'Borders Region'           HB_CODE=          'S08000016'.
if HBname = 'Dumfries & Galloway Region'           HB_CODE =         'S08000017'.
if HBname = 'Fife Region'           HB_CODE =         'S08000029'.
if HBname = 'Forth Valley Region'          HB_CODE =         'S08000019'.
if HBname = 'Grampian Region'          HB_CODE =         'S08000020'.
if HBname = 'Greater Glasgow & Clyde Region'          HB_CODE =         'S08000021'.
if HBname = 'Highland Region'          HB_CODE =         'S08000022'.
if HBname = 'Lanarkshire Region'           HB_CODE =         'S08000023'.
if HBname = 'Lothian Region'           HB_CODE =         'S08000024'.
if HBname = 'Orkney Region'           HB_CODE =         'S08000025'.
if HBname = 'Shetland Region'           HB_CODE =         'S08000026'.
if HBname = 'Tayside Region'           HB_CODE =         'S08000030'.
if HBname = 'Western Isles Region'         HB_CODE =         'S08000028'.
EXECUTE.


Save outfile=!file+'/TAB-TDE-ALL-costs-HRI_Locality_Final' + !year + '.zsav'
/keep Year locality LCAname LA_CODE HB_CODE HBName AgeBand UserType ServiceType Total_Cost Episodes_Attendances Beddays NumberPatients
/zcompressed.

*save translate outfile='/conf/linkage/output/ODUROs/TAB-TDE-ALL-costs-HRI_DZ_Final' + !year + '.xlsx'
/version=12/type=xls/replace/fieldnames/map.
* 


********************************************************************************************************************************************.

*DELETE working FILES FOR HOUSEKEEPING*.
ERASE FILE= !file+'/10-All-costs-HRI_DZALL.zsav'.
ERASE FILE= !file+'/10-All-costs-HRI_DZ50.zsav'.
ERASE FILE= !file+'/10-All-costs-HRI_DZ65.zsav'.
ERASE FILE= !file+'/10-All-costs-HRI_DZ80.zsav'.
ERASE FILE= !file+'/10-All-costs-HRI_DZ95.zsav'.
ERASE FILE= !file+'/10-All-costs-HRI_DZ_Temp1.zsav'.
ERASE FILE= !file+'/10-All-costs-HRI_DZ_Temp2.zsav'.   
ERASE FILE= !file+'/10-All-costs-HRI_DZ_Final.zsav'.


EXECUTE.


