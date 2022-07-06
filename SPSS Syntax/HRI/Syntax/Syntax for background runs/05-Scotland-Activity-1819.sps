* Encoding: UTF-8.
*04. Scot-HRI-Activity. Health activities and costs breakdown.
*Orginally created by Kara Sellar 18/10/13.
 *Amended and updated by ML March 2014
*Amended and updated by Alison McClelland April 2015 for HRI-200,000-days. 
*Updated KR June 2015 for Tableau Workbook.
*FC Oct 2018. Updated Mental Health activity flag names to reflect changes in variable formats within Source Linkage File. 

Define !file()
     '/conf/sourcedev/TableauUpdates/HRI/Outputs/1819/'
!Enddefine.


Define !HRIfile255075()
      !Quote(!Concat("/conf/sourcedev/TableauUpdates/HRI/Outputs/1819/01-HRI-", !UnQuote(!Eval(!year)), "-255075.zsav")).
!Enddefine.

******************************************************************
***** MUST UPDATE THESE BEFORE RUNNING ********.
*Macro 1.
Define !year()
'201819'
!Enddefine.

Define !year2()
'2018/19'
!Enddefine.

*Macro 2.
Define !popyear()
'2018'
!Enddefine.

*Aim-  to calculate breakdown of activity and costs for each of the 11 health activity categories from the master HRI and AllPatients by gender and ageband 
for local council Scot.

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


* 1. Get the HRI or AllPatients file (for the HRI file, set Scotflag=1 so that the HRIs for Council Scots are selected) then for each the following steps are carried out.
* 2. Create the AgeBand Variable. 
* 3. Count the total cost of the Service, the total Episodes/Attendances/despensed items and the total beddays.
* 4. Compute Variables ActivityType and usertype to identify and differentiate health activity types and All and HRI patients.
* 5. Create aggregates to calculate totals for both genders, all ages, and all genders & all ages populations and add all these files together..
* 6 .For each health activity type add HRI and AllPatient files together
* 7. Add these files together to the main activity-cost file.
* 8.Rename Scot variable to Scot and recode any blank Scot fields to null code 99.
****************************************************************************************************************************************************

** Create totals for each Service type and Threshold level
***Number 1- ACUTE: HRIs - 50%**************************************.
get file = !HRIfile255075.

Select if ScotFlag50=1.
Select if acute_episodes ge 1.

string hb(a30).
compute hb = 'Sc'.

rename variables (acute_cost = Total_Cost) (acute_episodes = Episodes_Attendances) (Acute_inpatient_beddays = Beddays).

Aggregate outfile=* 
               /break=HB Gender AgeBand
               /Total_Cost Episodes_Attendances Beddays=Sum(Total_Cost Episodes_Attendances Beddays)      
               /NumberPatients = n.

String UserType (A11).
Compute UserType='Scot-HRI_50'.
      String ServiceType (A30).
      Compute ServiceType='Acute'.

Save outfile=!file+'/08-Acute-costs-HRI_Scot50.zsav'
/zcompressed.

***Number 1- ACUTE: HRIs - 65%**************************************.

get file = !HRIfile255075.

Select if ScotFlag65=1.
Select if acute_episodes ge 1.

string hb (A30).
compute hb = 'Sc'.

rename variables (acute_cost = Total_Cost) (acute_episodes = Episodes_Attendances) (Acute_inpatient_beddays = Beddays).

Aggregate outfile=* 
               /break=HB Gender AgeBand
               /Total_Cost Episodes_Attendances Beddays=Sum(Total_Cost Episodes_Attendances Beddays)      
               /NumberPatients = n.

String UserType (A11).
Compute UserType='Scot-HRI_65'.
      String ServiceType (A30).
      Compute ServiceType='Acute'.

Save outfile=!file+'/08-Acute-costs-HRI_Scot65.zsav'
/zcompressed.

***Number 1- ACUTE: HRIs - 80%**************************************.
get file = !HRIfile255075.

Select if ScotFlag80=1.
Select if acute_episodes ge 1.
string hb (A30).
compute hb = 'Sc'.

rename variables (acute_cost = Total_Cost) (acute_episodes = Episodes_Attendances) (Acute_inpatient_beddays = Beddays).

Aggregate outfile=* 
               /break=HB Gender AgeBand
               /Total_Cost Episodes_Attendances Beddays=Sum(Total_Cost Episodes_Attendances Beddays)      
               /NumberPatients = n.

String UserType (A11).
Compute UserType='Scot-HRI_80'.
      String ServiceType (A30).
      Compute ServiceType='Acute'.

Save outfile=!file+'/08-Acute-costs-HRI_Scot80.zsav'
/zcompressed.

***Number 1- ACUTE: HRIs - 95%**************************************.
get file = !HRIfile255075.

Select if ScotFlag95=1.
Select if acute_episodes ge 1.
string hb (A30).
compute hb = 'Sc'.

rename variables (acute_cost = Total_Cost) (acute_episodes = Episodes_Attendances) (Acute_inpatient_beddays = Beddays).

Aggregate outfile=* 
               /break=HB Gender AgeBand
               /Total_Cost Episodes_Attendances Beddays=Sum(Total_Cost Episodes_Attendances Beddays)      
               /NumberPatients = n.

String UserType (A11).
Compute UserType='Scot-HRI_95'.
      String ServiceType (A30).
      Compute ServiceType='Acute'.

Save outfile=!file+'/08-Acute-costs-HRI_Scot95.zsav'
/zcompressed.

***Number 1- ACUTE: HRIs - 100% (ALL Patients**************************************.
get file = !HRIfile255075.

Select if acute_episodes ge 1.
string hb (A30).
compute hb = 'Sc'.

rename variables (acute_cost = Total_Cost) (acute_episodes = Episodes_Attendances) (Acute_inpatient_beddays = Beddays).

Aggregate outfile=* 
               /break=HB Gender AgeBand
               /Total_Cost Episodes_Attendances Beddays=Sum(Total_Cost Episodes_Attendances Beddays)      
               /NumberPatients = n.

String UserType (A11).
Compute UserType='Scot-HRI_ALL'.
      String ServiceType (A30).
      Compute ServiceType='Acute'.

Save outfile=!file+'/08-Acute-costs-HRI_ScotALL.zsav'
/zcompressed.

** Bring all Acute file together and create totals.

add files file =!file+'/08-Acute-costs-HRI_ScotALL.zsav'
 /file =!file+'/08-Acute-costs-HRI_Scot50.zsav'
 /file =!file+'/08-Acute-costs-HRI_Scot65.zsav'
 /file =!file+'/08-Acute-costs-HRI_Scot80.zsav'
 /file =!file+'/08-Acute-costs-HRI_Scot95.zsav'.

Save outfile=!file+'/08-Acute-costs-HRI_Scot_Temp1.zsav'
/zcompressed.

compute ageband = 'All ages'.
aggregate outfile=!file+'/08-Acute-costs-HRI_Scot_Temp2.zsav'
 /break= HB gender AgeBand UserType ServiceType
 /Total_Cost Episodes_Attendances Beddays=Sum(Total_Cost Episodes_Attendances Beddays)
 /NumberPatients =sum(NumberPatients).

add files file =!file+'/08-Acute-costs-HRI_Scot_Temp1.zsav'
 /file =!file+'/08-Acute-costs-HRI_Scot_Temp2.zsav'.
compute gender = 0.

aggregate outfile=!file+'/08-Acute-costs-HRI_Scot_Temp3.zsav'
 /break= HB gender AgeBand UserType ServiceType
 /Total_Cost Episodes_Attendances Beddays=Sum(Total_Cost Episodes_Attendances Beddays)
 /NumberPatients =sum(NumberPatients).

add files file =!file+'/08-Acute-costs-HRI_Scot_Temp1.zsav'
 /file =!file+'/08-Acute-costs-HRI_Scot_Temp2.zsav'
 /file =!file+'/08-Acute-costs-HRI_Scot_Temp3.zsav'.

Save outfile=!file+'/08-Acute-costs-HRI_Scot_Final'+ !year + '.zsav'
/zcompressed.

** Housekeeping for Acute section.

ERASE FILE= !file+'/08-Acute-costs-HRI_ScotALL.zsav'.
ERASE FILE= !file+'/08-Acute-costs-HRI_Scot50.zsav'.
ERASE FILE= !file+'/08-Acute-costs-HRI_Scot65.zsav'.
ERASE FILE= !file+'/08-Acute-costs-HRI_Scot80.zsav'.
ERASE FILE= !file+'/08-Acute-costs-HRI_Scot95.zsav'.
ERASE FILE =!file+'/08-Acute-costs-HRI_Scot_Temp1.zsav'.
ERASE FILE =!file+'/08-Acute-costs-HRI_Scot_Temp2.zsav'.   
ERASE FILE =!file+'/08-Acute-costs-HRI_Scot_Temp3.zsav'.

****************************************************************************************************************************************************************************.
****************************************************************************************************************************************************************************

***Number 2- Mental Health: HRIs - 50%**************************************.
get file = !HRIfile255075.

Select if ScotFlag50=1.
Select if MH_episodes ge 1.

string hb (A30).
compute hb = 'Sc'.

rename variables (MH_cost = Total_Cost) (MH_episodes = Episodes_Attendances) (MH_inpatient_beddays = Beddays).

Aggregate outfile=* 
               /break=HB Gender AgeBand
               /Total_Cost Episodes_Attendances Beddays=Sum(Total_Cost Episodes_Attendances Beddays)      
               /NumberPatients = n.

String UserType (A11).
Compute UserType='Scot-HRI_50'.
      String ServiceType (A30).
      Compute ServiceType='Mental Health'.

Save outfile=!file+'/08-MH-costs-HRI_Scot50.zsav'
/zcompressed.

***Number 2- MENTAL HEALTH: HRIs - 65%**************************************.
get file = !HRIfile255075.

Select if ScotFlag65=1.
Select if MH_episodes ge 1.
string hb (A30).
compute hb = 'Sc'.

rename variables (MH_cost = Total_Cost) (MH_episodes = Episodes_Attendances) (MH_inpatient_beddays = Beddays).

Aggregate outfile=* 
               /break=HB Gender AgeBand
               /Total_Cost Episodes_Attendances Beddays=Sum(Total_Cost Episodes_Attendances Beddays)      
               /NumberPatients = n.

String UserType (A11).
Compute UserType='Scot-HRI_65'.
      String ServiceType (A30).
      Compute ServiceType='Mental Health'.

Save outfile=!file+'/08-MH-costs-HRI_Scot65.zsav'
/zcompressed.

***Number 2- MENTAL HEALTH: HRIs - 80%**************************************.
get file = !HRIfile255075.

Select if ScotFlag80=1.
Select if MH_episodes ge 1.
string hb (A30).
compute hb = 'Sc'.
rename variables (MH_cost = Total_Cost) (MH_episodes = Episodes_Attendances) (MH_inpatient_beddays = Beddays).

Aggregate outfile=* 
               /break=HB Gender AgeBand
               /Total_Cost Episodes_Attendances Beddays=Sum(Total_Cost Episodes_Attendances Beddays)      
               /NumberPatients = n.

String UserType (A11).
Compute UserType='Scot-HRI_80'.
      String ServiceType (A30).
      Compute ServiceType='Mental Health'.

Save outfile=!file+'/08-MH-costs-HRI_Scot80.zsav'
/zcompressed.

***Number 2- MENTAL HEALTH: HRIs - 95%**************************************.
get file = !HRIfile255075.

Select if ScotFlag95=1.
Select if MH_episodes ge 1.
string hb (A30).
compute hb = 'Sc'.

rename variables (MH_cost = Total_Cost) (MH_episodes = Episodes_Attendances) (MH_inpatient_beddays = Beddays).

Aggregate outfile=* 
               /break=HB Gender AgeBand
               /Total_Cost Episodes_Attendances Beddays=Sum(Total_Cost Episodes_Attendances Beddays)      
               /NumberPatients = n.

String UserType (A11).
Compute UserType='Scot-HRI_95'.
      String ServiceType (A30).
      Compute ServiceType='Mental Health'.

Save outfile=!file+'/08-MH-costs-HRI_Scot95.zsav'
/zcompressed.

***Number 2- MENTAL HEALTH : HRIs - 100% (ALL Patients**************************************.
get file = !HRIfile255075.

Select if MH_episodes ge 1.
string hb (A30).
compute hb = 'Sc'.

rename variables (MH_cost = Total_Cost) (MH_episodes = Episodes_Attendances) (MH_inpatient_beddays = Beddays).

Aggregate outfile=* 
               /break=HB Gender AgeBand
               /Total_Cost Episodes_Attendances Beddays=Sum(Total_Cost Episodes_Attendances Beddays)      
               /NumberPatients = n.

String UserType (A11).
Compute UserType='Scot-HRI_ALL'.
      String ServiceType (A30).
      Compute ServiceType='Mental Health'.

Save outfile=!file+'/08-MH-costs-HRI_ScotALL.zsav'
/zcompressed.

** Bring all Acute file together and create totals.

add files file =!file+'/08-MH-costs-HRI_ScotALL.zsav'
 /file =!file+'/08-MH-costs-HRI_Scot50.zsav'
 /file =!file+'/08-MH-costs-HRI_Scot65.zsav'
 /file =!file+'/08-MH-costs-HRI_Scot80.zsav'
 /file =!file+'/08-MH-costs-HRI_Scot95.zsav'.

Save outfile=!file+'/08-MH-costs-HRI_Scot_Temp1.zsav'
/zcompressed.

compute ageband = 'All ages'.
aggregate outfile=!file+'/08-MH-costs-HRI_Scot_Temp2.zsav'
 /break= HB gender AgeBand UserType ServiceType
 /Total_Cost=Sum(Total_Cost)
 /Episodes_Attendances=Sum(Episodes_Attendances)
 /Beddays = sum(Beddays)
 /NumberPatients =sum(NumberPatients).

add files file =!file+'/08-MH-costs-HRI_Scot_Temp1.zsav'
 /file =!file+'/08-MH-costs-HRI_Scot_Temp2.zsav'.

compute gender = 0.
aggregate outfile=!file+'/08-MH-costs-HRI_Scot_Temp3.zsav'
 /break= HB gender AgeBand UserType ServiceType
 /Total_Cost=Sum(Total_Cost)
 /Episodes_Attendances=Sum(Episodes_Attendances)
 /Beddays = sum(Beddays)
 /NumberPatients =sum(NumberPatients).

add files file =!file+'/08-MH-costs-HRI_Scot_Temp1.zsav'
 /file =!file+'/08-MH-costs-HRI_Scot_Temp2.zsav'
 /file =!file+'/08-MH-costs-HRI_Scot_Temp3.zsav'.

Save outfile=!file+'/08-MH-costs-HRI_Scot_Final' + !year + '.zsav'
/zcompressed.

** Housekeeping for Mental Health section.

ERASE FILE= !file+'/08-MH-costs-HRI_ScotALL.zsav'.
ERASE FILE= !file+'/08-MH-costs-HRI_Scot50.zsav'.
ERASE FILE= !file+'/08-MH-costs-HRI_Scot65.zsav'.
ERASE FILE= !file+'/08-MH-costs-HRI_Scot80.zsav'.
ERASE FILE= !file+'/08-MH-costs-HRI_Scot95.zsav'.
ERASE FILE =!file+'/08-MH-costs-HRI_Scot_Temp1.zsav'.
ERASE FILE =!file+'/08-MH-costs-HRI_Scot_Temp2.zsav'.   
ERASE FILE =!file+'/08-MH-costs-HRI_Scot_Temp3.zsav'.

***********************************************************************************************************************************************************************************
***********************************************************************************************************************************************************************************.
***Number 3 - GLS: HRIs - 50%**************************************.
get file = !HRIfile255075.

Select if ScotFlag50=1.
Select if gls_episodes ge 1.
string hb (A30).
compute hb = 'Sc'.

rename variables (gls_cost = Total_Cost) (gls_episodes = Episodes_Attendances) (gls_inpatient_beddays = Beddays).

Aggregate outfile=* 
               /break=HB Gender AgeBand
               /Total_Cost Episodes_Attendances Beddays=Sum(Total_Cost Episodes_Attendances Beddays)      
               /NumberPatients = n.

String UserType (A11).
Compute UserType='Scot-HRI_50'.
      String ServiceType (A30).
      Compute ServiceType='GLS'.

Save outfile=!file+'/08-GLS-costs-HRI_Scot50.zsav'
/zcompressed.

***Number 3- GLS: HRIs - 65%**************************************.
get file = !HRIfile255075.

Select if ScotFlag65=1.
Select if gls_episodes ge 1.
string hb (A30).
compute hb = 'Sc'.

rename variables (gls_cost = Total_Cost) (gls_episodes = Episodes_Attendances) (gls_inpatient_beddays = Beddays).

Aggregate outfile=* 
               /break=HB Gender AgeBand
               /Total_Cost Episodes_Attendances Beddays=Sum(Total_Cost Episodes_Attendances Beddays)      
               /NumberPatients = n.

String UserType (A11).
Compute UserType='Scot-HRI_65'.
      String ServiceType (A30).
      Compute ServiceType='GLS'.

Save outfile=!file+'/08-GLS-costs-HRI_Scot65.zsav'
/zcompressed.

***Number 3- GLS: HRIs - 80%**************************************.
get file = !HRIfile255075.

Select if ScotFlag80=1.
Select if gls_episodes ge 1.
string hb (A30).
compute hb = 'Sc'.

rename variables (gls_cost = Total_Cost) (gls_episodes = Episodes_Attendances) (gls_inpatient_beddays = Beddays).

Aggregate outfile=* 
               /break=HB Gender AgeBand
               /Total_Cost Episodes_Attendances Beddays=Sum(Total_Cost Episodes_Attendances Beddays)      
               /NumberPatients = n.

String UserType (A11).
Compute UserType='Scot-HRI_80'.
      String ServiceType (A30).
      Compute ServiceType='GLS'.

Save outfile=!file+'/08-GLS-costs-HRI_Scot80.zsav'
/zcompressed.

***Number 3- GLS: HRIs - 95%**************************************.
get file = !HRIfile255075.

Select if ScotFlag95=1.
Select if gls_episodes ge 1.
string hb (A30).
compute hb = 'Sc'.

rename variables (gls_cost = Total_Cost) (gls_episodes = Episodes_Attendances) (gls_inpatient_beddays = Beddays).

Aggregate outfile=* 
               /break=HB Gender AgeBand
               /Total_Cost Episodes_Attendances Beddays=Sum(Total_Cost Episodes_Attendances Beddays)      
               /NumberPatients = n.

String UserType (A11).
Compute UserType='Scot-HRI_95'.
      String ServiceType (A30).
      Compute ServiceType='GLS'.

Save outfile=!file+'/08-GLS-costs-HRI_Scot95.zsav'
/zcompressed.

***Number 3- GLS : HRIs - 100% (ALL Patients**************************************.

get file = !HRIfile255075.

Select if gls_episodes ge 1.
string hb (A30).
compute hb = 'Sc'.

rename variables (gls_cost = Total_Cost) (gls_episodes = Episodes_Attendances) (gls_inpatient_beddays = Beddays).

Aggregate outfile=* 
               /break=HB Gender AgeBand
               /Total_Cost Episodes_Attendances Beddays=Sum(Total_Cost Episodes_Attendances Beddays)      
               /NumberPatients = n.

String UserType (A11).
Compute UserType='Scot-HRI_ALL'.
      String ServiceType (A30).
      Compute ServiceType='GLS'.

Save outfile=!file+'/08-GLS-costs-HRI_ScotALL.zsav'
/zcompressed.

** Bring all GLS files together and create totals.

add files file =!file+'/08-GLS-costs-HRI_ScotALL.zsav'
 /file =!file+'/08-GLS-costs-HRI_Scot50.zsav'
 /file =!file+'/08-GLS-costs-HRI_Scot65.zsav'
 /file =!file+'/08-GLS-costs-HRI_Scot80.zsav'
 /file =!file+'/08-GLS-costs-HRI_Scot95.zsav'.

Save outfile=!file+'/08-GLS-costs-HRI_Scot_Temp1.zsav'
/zcompressed.

compute ageband = 'All ages'.
aggregate outfile=!file+'/08-GLS-costs-HRI_Scot_Temp2.zsav'
 /break= HB gender AgeBand UserType ServiceType
 /Total_Cost=Sum(Total_Cost)
 /Episodes_Attendances=Sum(Episodes_Attendances)
 /Beddays = sum(Beddays)
 /NumberPatients =sum(NumberPatients).

add files file =!file+'/08-GLS-costs-HRI_Scot_Temp1.zsav'
 /file =!file+'/08-GLS-costs-HRI_Scot_Temp2.zsav'.

compute gender = 0.
aggregate outfile=!file+'/08-GLS-costs-HRI_Scot_Temp3.zsav'
 /break= HB gender AgeBand UserType ServiceType
 /Total_Cost=Sum(Total_Cost)
 /Episodes_Attendances=Sum(Episodes_Attendances)
 /Beddays = sum(Beddays)
 /NumberPatients =sum(NumberPatients).

add files file =!file+'/08-GLS-costs-HRI_Scot_Temp1.zsav'
 /file =!file+'/08-GLS-costs-HRI_Scot_Temp2.zsav'
 /file =!file+'/08-GLS-costs-HRI_Scot_Temp3.zsav'.
execute. 

Save outfile=!file+'/08-GLS-costs-HRI_Scot_Final'+ !year + '.zsav'
/zcompressed.

** Housekeeping for GLS section

ERASE FILE= !file+'/08-GLS-costs-HRI_ScotALL.zsav'.
ERASE FILE= !file+'/08-GLS-costs-HRI_Scot50.zsav'.
ERASE FILE= !file+'/08-GLS-costs-HRI_Scot65.zsav'.
ERASE FILE= !file+'/08-GLS-costs-HRI_Scot80.zsav'.
ERASE FILE= !file+'/08-GLS-costs-HRI_Scot95.zsav'.
ERASE FILE =!file+'/08-GLS-costs-HRI_Scot_Temp1.zsav'.
ERASE FILE =!file+'/08-GLS-costs-HRI_Scot_Temp2.zsav'.   
ERASE FILE =!file+'/08-GLS-costs-HRI_Scot_Temp3.zsav'.

********************************************************************************************************************************************************************************.
********************************************************************************************************************************************************************************
***Number 4 - MAT: HRIs - 50%**************************************.

get file = !HRIfile255075.

Select if ScotFlag50=1.
Select if MAT_episodes ge 1.
string hb (A30).
compute hb = 'Sc'.

rename variables (MAT_cost = Total_Cost) (MAT_episodes = Episodes_Attendances) (MAT_inpatient_beddays = Beddays).

Aggregate outfile=* 
               /break=HB Gender AgeBand
               /Total_Cost Episodes_Attendances Beddays=Sum(Total_Cost Episodes_Attendances Beddays)      
               /NumberPatients = n.

String UserType (A11).
Compute UserType='Scot-HRI_50'.
      String ServiceType (A30).
      Compute ServiceType='MAT'.

Save outfile=!file+'/08-MAT-costs-HRI_Scot50.zsav'
/zcompressed.

***Number 4 - MAT: HRIs - 65%**************************************.
get file = !HRIfile255075.

Select if ScotFlag65=1.
Select if MAT_episodes ge 1.
string hb (A30).
compute hb = 'Sc'.

rename variables (MAT_cost = Total_Cost) (MAT_episodes = Episodes_Attendances) (MAT_inpatient_beddays = Beddays).

Aggregate outfile=* 
               /break=HB Gender AgeBand
               /Total_Cost Episodes_Attendances Beddays=Sum(Total_Cost Episodes_Attendances Beddays)      
               /NumberPatients = n.

String UserType (A11).
Compute UserType='Scot-HRI_65'.
String ServiceType (A30).
Compute ServiceType='MAT'.

Save outfile=!file+'/08-MAT-costs-HRI_Scot65.zsav'
/zcompressed.

***Number 4 - MAT: HRIs - 80%**************************************.
get file = !HRIfile255075.

Select if ScotFlag80=1.
Select if MAT_episodes ge 1.
string hb (A30).
compute hb = 'Sc'.

rename variables (MAT_cost = Total_Cost) (MAT_episodes = Episodes_Attendances) (MAT_inpatient_beddays = Beddays).

Aggregate outfile=* 
               /break=HB Gender AgeBand
               /Total_Cost Episodes_Attendances Beddays=Sum(Total_Cost Episodes_Attendances Beddays)      
               /NumberPatients = n.

String UserType (A11).
Compute UserType='Scot-HRI_80'.
     String ServiceType (A30).
      Compute ServiceType='MAT'.

Save outfile=!file+'/08-MAT-costs-HRI_Scot80.zsav'
/zcompressed.

***Number 4 - MAT: HRIs - 95%**************************************.
get file = !HRIfile255075.

Select if ScotFlag95=1.
Select if MAT_episodes ge 1.
string hb (A30).
compute hb = 'Sc'.

rename variables (MAT_cost = Total_Cost) (MAT_episodes = Episodes_Attendances) (MAT_inpatient_beddays = Beddays).

Aggregate outfile=* 
               /break=HB Gender AgeBand
               /Total_Cost Episodes_Attendances Beddays=Sum(Total_Cost Episodes_Attendances Beddays)      
               /NumberPatients = n.

String UserType (A11).
Compute UserType='Scot-HRI_95'.
String ServiceType (A30).
      Compute ServiceType='MAT'.

Save outfile=!file+'/08-MAT-costs-HRI_Scot95.zsav'
/zcompressed.

***Number 4 - MAT : HRIs - 100% (ALL Patients**************************************.
get file = !HRIfile255075.

Select if MAT_episodes ge 1.
string hb (A30).
compute hb = 'Sc'.

rename variables (MAT_cost = Total_Cost) (MAT_episodes = Episodes_Attendances) (MAT_inpatient_beddays = Beddays).

Aggregate outfile=* 
               /break=HB Gender AgeBand
               /Total_Cost Episodes_Attendances Beddays=Sum(Total_Cost Episodes_Attendances Beddays)      
               /NumberPatients = n.

String UserType (A11).
Compute UserType='Scot-HRI_ALL'.
      String ServiceType (A30).
      Compute ServiceType='MAT'.

Save outfile=!file+'/08-MAT-costs-HRI_ScotALL.zsav'
/zcompressed.

** Bring all Maternity files together and create totals.

add files file =!file+'/08-MAT-costs-HRI_ScotALL.zsav'
 /file =!file+'/08-MAT-costs-HRI_Scot50.zsav'
 /file =!file+'/08-MAT-costs-HRI_Scot65.zsav'
 /file =!file+'/08-MAT-costs-HRI_Scot80.zsav'
 /file =!file+'/08-MAT-costs-HRI_Scot95.zsav'.

Save outfile=!file+'/08-MAT-costs-HRI_Scot_Temp1.zsav'
/zcompressed.

compute ageband = 'All ages'.
aggregate outfile=!file+'/08-MAT-costs-HRI_Scot_Temp2.zsav'
 /break= HB gender AgeBand UserType ServiceType
 /Total_Cost=Sum(Total_Cost)
 /Episodes_Attendances=Sum(Episodes_Attendances)
 /Beddays = sum(Beddays)
 /NumberPatients =sum(NumberPatients).

add files file =!file+'/08-MAT-costs-HRI_Scot_Temp1.zsav'
 /file =!file+'/08-MAT-costs-HRI_Scot_Temp2.zsav'.

compute gender = 0.
aggregate outfile=!file+'/08-MAT-costs-HRI_Scot_Temp3.zsav'
 /break= HB gender AgeBand UserType ServiceType
 /Total_Cost=Sum(Total_Cost)
 /Episodes_Attendances=Sum(Episodes_Attendances)
 /Beddays = sum(Beddays)
 /NumberPatients =sum(NumberPatients).

add files file =!file+'/08-MAT-costs-HRI_Scot_Temp1.zsav'
 /file =!file+'/08-MAT-costs-HRI_Scot_Temp2.zsav'
 /file =!file+'/08-MAT-costs-HRI_Scot_Temp3.zsav'.

Save outfile=!file+'/08-MAT-costs-HRI_Scot_Final'+!year+'.zsav'
/zcompressed.

** Housekeeping for Maternity section

ERASE FILE= !file+'/08-MAT-costs-HRI_ScotALL.zsav'.
ERASE FILE= !file+'/08-MAT-costs-HRI_Scot50.zsav'.
ERASE FILE= !file+'/08-MAT-costs-HRI_Scot65.zsav'.
ERASE FILE= !file+'/08-MAT-costs-HRI_Scot80.zsav'.
ERASE FILE= !file+'/08-MAT-costs-HRI_Scot95.zsav'.
ERASE FILE =!file+'/08-MAT-costs-HRI_Scot_Temp1.zsav'.
ERASE FILE =!file+'/08-MAT-costs-HRI_Scot_Temp2.zsav'.   
ERASE FILE =!file+'/08-MAT-costs-HRI_Scot_Temp3.zsav'.

*******************************************************************************************************************************************************.
*******************************************************************************************************************************************************
***Number 5 - OP: HRIs - 50%**************************************.

get file = !HRIfile255075.

Select if ScotFlag50=1.
Select if OP_newcons_attendances  ge 1.
string hb (A30).
compute hb = 'Sc'.

Aggregate outfile=* 
               /break=HB Gender AgeBand
               /Total_Cost=Sum(op_cost_attend)      
               /Episodes_Attendances=Sum(OP_newcons_attendances  )
               /NumberPatients = n.

String UserType (A11).
Compute UserType='Scot-HRI_50'.
     String ServiceType (A30).
      Compute ServiceType='OP'.

Save outfile=!file+'/08-OP-costs-HRI_Scot50.zsav'
/zcompressed.

***Number 5 - OP: HRIs - 65%*************************************.
get file = !HRIfile255075.

Select if ScotFlag65=1.
Select if OP_newcons_attendances  ge 1.
string hb (A30).
compute hb = 'Sc'.

Aggregate outfile=* 
               /break=HB Gender AgeBand
               /Total_Cost=Sum(op_cost_attend)      
               /Episodes_Attendances=Sum(OP_newcons_attendances  )
               /NumberPatients = n.

String UserType (A11).
Compute UserType='Scot-HRI_65'.
String ServiceType (A30).
      Compute ServiceType='OP'.

Save outfile=!file+'/08-OP-costs-HRI_Scot65.zsav'
/zcompressed.

***Number 5 - OP: HRIs - 80%**************************************.
get file = !HRIfile255075.

Select if ScotFlag80=1.
Select if OP_newcons_attendances  ge 1.
string hb (A30).
compute hb = 'Sc'.

Aggregate outfile=* 
               /break=HB Gender AgeBand
               /Total_Cost=Sum(op_cost_attend)      
               /Episodes_Attendances=Sum(OP_newcons_attendances  )
               /NumberPatients = n.

String UserType (A11).
Compute UserType='Scot-HRI_80'.
      String ServiceType (A30).
      Compute ServiceType='OP'.

Save outfile=!file+'/08-OP-costs-HRI_Scot80.zsav'
/zcompressed.

***Number 5 - OP: HRIs - 95%**************************************.
get file = !HRIfile255075.

Select if ScotFlag95=1.
Select if OP_newcons_attendances  ge 1.
string hb (A30).
compute hb = 'Sc'.

Aggregate outfile=* 
               /break=HB Gender AgeBand
               /Total_Cost=Sum(op_cost_attend)      
               /Episodes_Attendances=Sum(OP_newcons_attendances  )
               /NumberPatients = n.

String UserType (A11).
Compute UserType='Scot-HRI_95'.
      String ServiceType (A30).
      Compute ServiceType='OP'.

Save outfile=!file+'/08-OP-costs-HRI_Scot95.zsav'
/zcompressed.

***Number 5 - OP : HRIs - 100% (ALL Patients)**************************************.
get file = !HRIfile255075.

Select if OP_newcons_attendances  ge 1.
string hb (A30).
compute hb = 'Sc'.

Aggregate outfile=* 
               /break=HB Gender AgeBand
               /Total_Cost=Sum(op_cost_attend)      
               /Episodes_Attendances=Sum(OP_newcons_attendances  )
               /NumberPatients = n.

String UserType (A11).
Compute UserType='Scot-HRI_ALL'.
      String ServiceType (A30).
      Compute ServiceType='OP'.

Save outfile=!file+'/08-OP-costs-HRI_ScotALL.zsav'
/zcompressed.

** Bring all OP files together and create totals.

add files file =!file+'/08-OP-costs-HRI_ScotALL.zsav'
 /file =!file+'/08-OP-costs-HRI_Scot50.zsav'
 /file =!file+'/08-OP-costs-HRI_Scot65.zsav'
 /file =!file+'/08-OP-costs-HRI_Scot80.zsav'
 /file =!file+'/08-OP-costs-HRI_Scot95.zsav'.

*Add in missing beddays variable.
Compute Beddays = 0.
Save outfile=!file+'/08-OP-costs-HRI_Scot_Temp1.zsav'
/zcompressed.

compute ageband = 'All ages'.
aggregate outfile=!file+'/08-OP-costs-HRI_Scot_Temp2.zsav'
 /break= HB gender AgeBand UserType ServiceType
 /Total_Cost=Sum(Total_Cost)
 /Episodes_Attendances=Sum(Episodes_Attendances)
 /Beddays = sum(Beddays)
 /NumberPatients =sum(NumberPatients).

add files file =!file+'/08-OP-costs-HRI_Scot_Temp1.zsav'
 /file =!file+'/08-OP-costs-HRI_Scot_Temp2.zsav'.

compute gender = 0.
aggregate outfile=!file+'/08-OP-costs-HRI_Scot_Temp3.zsav'
 /break= HB gender AgeBand UserType ServiceType
 /Total_Cost=Sum(Total_Cost)
 /Episodes_Attendances=Sum(Episodes_Attendances)
 /Beddays = sum(Beddays)
 /NumberPatients =sum(NumberPatients).

add files file =!file+'/08-OP-costs-HRI_Scot_Temp1.zsav'
 /file =!file+'/08-OP-costs-HRI_Scot_Temp2.zsav'
 /file =!file+'/08-OP-costs-HRI_Scot_Temp3.zsav'.

Save outfile=!file+'/08-OP-costs-HRI_Scot_Final' + !year + '.zsav'
/zcompressed.

** Housekeeping for OP section.

ERASE FILE= !file+'/08-OP-costs-HRI_ScotALL.zsav'.
ERASE FILE= !file+'/08-OP-costs-HRI_Scot50.zsav'.
ERASE FILE= !file+'/08-OP-costs-HRI_Scot65.zsav'.
ERASE FILE= !file+'/08-OP-costs-HRI_Scot80.zsav'.
ERASE FILE= !file+'/08-OP-costs-HRI_Scot95.zsav'.
ERASE FILE =!file+'/08-OP-costs-HRI_Scot_Temp1.zsav'.
ERASE FILE =!file+'/08-OP-costs-HRI_Scot_Temp2.zsav'.   
ERASE FILE =!file+'/08-OP-costs-HRI_Scot_Temp3.zsav'.

********************************************************************************************************************************************************
********************************************************************************************************************************************************.
***Number 6 - AE: HRIs - 50%**************************************.
get file = !HRIfile255075.

Select if ScotFlag50=1.
Select if ae_attendances  ge 1.
string hb (A30).
compute hb = 'Sc'.

Aggregate outfile=* 
               /break=HB Gender AgeBand
               /Total_Cost=Sum(ae_cost)      
               /Episodes_Attendances=Sum(ae_attendances  )
               /NumberPatients = n.

String UserType (A11).
Compute UserType='Scot-HRI_50'.
      String ServiceType (A30).
      Compute ServiceType='AE'.

Save outfile=!file+'/08-AE-costs-HRI_Scot50.zsav'
/zcompressed.

***Number 6 - AE: HRIs - 65%**************************************.
get file = !HRIfile255075.

Select if ScotFlag65=1.
Select if AE_attendances  ge 1.
string hb (A30).
compute hb = 'Sc'.

Aggregate outfile=* 
               /break=HB Gender AgeBand
               /Total_Cost=Sum(ae_cost)      
               /Episodes_Attendances=Sum(AE_attendances  )
               /NumberPatients = n.

String UserType (A11).
Compute UserType='Scot-HRI_65'.
      String ServiceType (A30).
      Compute ServiceType='AE'.

Save outfile=!file+'/08-AE-costs-HRI_Scot65.zsav'
/zcompressed.

***Number 6 - AE: HRIs - 80%**************************************.
get file = !HRIfile255075.

Select if ScotFlag80=1.
Select if AE_attendances  ge 1.
string hb (A30).
compute hb = 'Sc'.

Aggregate outfile=* 
               /break=HB Gender AgeBand
               /Total_Cost=Sum(ae_cost)      
               /Episodes_Attendances=Sum(AE_attendances  )
               /NumberPatients = n.

String UserType (A11).
Compute UserType='Scot-HRI_80'.
      String ServiceType (A30).
      Compute ServiceType='AE'.

Save outfile=!file+'/08-AE-costs-HRI_Scot80.zsav'
/zcompressed.

***Number 6 - AE: HRIs - 95%**************************************.
get file = !HRIfile255075.

Select if ScotFlag95=1.
Select if AE_attendances  ge 1.
string hb (A30).
compute hb = 'Sc'.

Aggregate outfile=* 
               /break=HB Gender AgeBand
               /Total_Cost=Sum(ae_cost)      
               /Episodes_Attendances=Sum(AE_attendances  )
               /NumberPatients = n.

String UserType (A11).
Compute UserType='Scot-HRI_95'.
      String ServiceType (A30).
      Compute ServiceType='AE'.

Save outfile=!file+'/08-AE-costs-HRI_Scot95.zsav'
/zcompressed.

***Number 6 - AE : HRIs - 100% (ALL Patients**************************************.
get file = !HRIfile255075.

Select if AE_attendances  ge 1.
string hb (A30).
compute hb = 'Sc'.

Aggregate outfile=* 
               /break=HB Gender AgeBand
               /Total_Cost=Sum(ae_cost)      
               /Episodes_Attendances=Sum(AE_attendances  )
               /NumberPatients = n.

String UserType (A11).
Compute UserType='Scot-HRI_ALL'.
      String ServiceType (A30).
      Compute ServiceType='AE'.

Save outfile=!file+'/08-AE-costs-HRI_ScotALL.zsav'
/zcompressed.


** Bring all AE files together and create totals.

add files file =!file+'/08-AE-costs-HRI_ScotALL.zsav'
 /file =!file+'/08-AE-costs-HRI_Scot50.zsav'
 /file =!file+'/08-AE-costs-HRI_Scot65.zsav'
 /file =!file+'/08-AE-costs-HRI_Scot80.zsav'
 /file =!file+'/08-AE-costs-HRI_Scot95.zsav'.

*Add in missing beddays variable.
Compute Beddays = 0.
Save outfile=!file+'/08-AE-costs-HRI_Scot_Temp1.zsav'
/zcompressed.

compute ageband = 'All ages'.
aggregate outfile=!file+'/08-AE-costs-HRI_Scot_Temp2.zsav'
 /break= HB gender AgeBand UserType ServiceType
 /Total_Cost=Sum(Total_Cost)
 /Episodes_Attendances=Sum(Episodes_Attendances)
 /Beddays = sum(Beddays)
 /NumberPatients =sum(NumberPatients).

add files file =!file+'/08-AE-costs-HRI_Scot_Temp1.zsav'
 /file =!file+'/08-AE-costs-HRI_Scot_Temp2.zsav'.

compute gender = 0.
aggregate outfile=!file+'/08-AE-costs-HRI_Scot_Temp3.zsav'
 /break= HB gender AgeBand UserType ServiceType
 /Total_Cost=Sum(Total_Cost)
 /Episodes_Attendances=Sum(Episodes_Attendances)
 /Beddays = sum(Beddays)
 /NumberPatients =sum(NumberPatients).

add files file =!file+'/08-AE-costs-HRI_Scot_Temp1.zsav'
 /file =!file+'/08-AE-costs-HRI_Scot_Temp2.zsav'
 /file =!file+'/08-AE-costs-HRI_Scot_Temp3.zsav'.

Save outfile=!file+'/08-AE-costs-HRI_Scot_Final' + !year + '.zsav'
/zcompressed.

** Housekeeping for A&E section.

ERASE FILE= !file+'/08-AE-costs-HRI_ScotALL.zsav'.
ERASE FILE= !file+'/08-AE-costs-HRI_Scot50.zsav'.
ERASE FILE= !file+'/08-AE-costs-HRI_Scot65.zsav'.
ERASE FILE= !file+'/08-AE-costs-HRI_Scot80.zsav'.
ERASE FILE= !file+'/08-AE-costs-HRI_Scot95.zsav'.
ERASE FILE =!file+'/08-AE-costs-HRI_Scot_Temp1.zsav'.
ERASE FILE =!file+'/08-AE-costs-HRI_Scot_Temp2.zsav'.   
ERASE FILE =!file+'/08-AE-costs-HRI_Scot_Temp3.zsav'.

*******************************************************************************************************************************************************************.
*******************************************************************************************************************************************************************
***Number 7 - PIS: HRIs - 50%**************************************.
get file = !HRIfile255075.

Select if ScotFlag50=1.
Select if pis_dispensed_items  ge 1.
string hb (A30).
compute hb = 'Sc'.

Aggregate outfile=* 
               /break=HB Gender AgeBand
               /Total_Cost=Sum(pis_cost)      
               /Episodes_Attendances=Sum(pis_dispensed_items )
               /NumberPatients = n.

String UserType (A11).
Compute UserType='Scot-HRI_50'.
      String ServiceType (A30).
      Compute ServiceType='PIS'.

Save outfile=!file+'/08-PIS-costs-HRI_Scot50.zsav'
/zcompressed.

***Number 7 - PIS: HRIs - 65%**************************************.
get file = !HRIfile255075.

Select if ScotFlag65=1.
Select if pis_dispensed_items  ge 1.
string hb (A30).
compute hb = 'Sc'.

Aggregate outfile=* 
               /break=HB Gender AgeBand
               /Total_Cost=Sum(pis_cost)      
               /Episodes_Attendances=Sum(pis_dispensed_items )
               /NumberPatients = n.

String UserType (A11).
Compute UserType='Scot-HRI_65'.
      String ServiceType (A30).
      Compute ServiceType='PIS'.

Save outfile=!file+'/08-PIS-costs-HRI_Scot65.zsav'
/zcompressed.

***Number 7 - PIS: HRIs - 80%**************************************.
get file = !HRIfile255075.

Select if ScotFlag80=1.
Select if pis_dispensed_items  ge 1.
string hb (A30).
compute hb = 'Sc'.

Aggregate outfile=* 
               /break=HB Gender AgeBand
               /Total_Cost=Sum(pis_cost)      
               /Episodes_Attendances=Sum(pis_dispensed_items )
               /NumberPatients = n.

String UserType (A11).
Compute UserType='Scot-HRI_80'.
      String ServiceType (A30).
      Compute ServiceType='PIS'.

Save outfile=!file+'/08-PIS-costs-HRI_Scot80.zsav'
/zcompressed.

***Number 7 - PIS: HRIs - 95%**************************************.
get file = !HRIfile255075.

Select if ScotFlag95=1.
Select if pis_dispensed_items  ge 1.
string hb (A30).
compute hb = 'Sc'.

Aggregate outfile=* 
               /break=HB Gender AgeBand
               /Total_Cost=Sum(pis_cost)      
               /Episodes_Attendances=Sum(pis_dispensed_items )
               /NumberPatients = n.

String UserType (A11).
Compute UserType='Scot-HRI_95'.
      String ServiceType (A30).
      Compute ServiceType='PIS'.

Save outfile=!file+'/08-PIS-costs-HRI_Scot95.zsav'
/zcompressed.

***Number 7 - PIS : HRIs - 100% (ALL Patients**************************************.
get file = !HRIfile255075.

Select if pis_dispensed_items  ge 1.
string hb (A30).
compute hb = 'Sc'.

Aggregate outfile=* 
               /break=HB Gender AgeBand
               /Total_Cost=Sum(pis_cost)      
               /Episodes_Attendances=Sum(pis_dispensed_items )
               /NumberPatients = n.

String UserType (A11).
Compute UserType='Scot-HRI_ALL'.
      String ServiceType (A30).
      Compute ServiceType='PIS'.

Save outfile=!file+'/08-PIS-costs-HRI_ScotALL.zsav'
/zcompressed.

** Bring all Acute file together and create totals.

add files file =!file+'/08-PIS-costs-HRI_ScotALL.zsav'
 /file =!file+'/08-PIS-costs-HRI_Scot50.zsav'
 /file =!file+'/08-PIS-costs-HRI_Scot65.zsav'
 /file =!file+'/08-PIS-costs-HRI_Scot80.zsav'
 /file =!file+'/08-PIS-costs-HRI_Scot95.zsav'.

*Add in missing beddays variable.
Compute Beddays = 0.
Save outfile=!file+'/08-PIS-costs-HRI_Scot_Temp1.zsav'
/zcompressed.

compute ageband = 'All ages'.
aggregate outfile=!file+'/08-PIS-costs-HRI_Scot_Temp2.zsav'
 /break= HB gender AgeBand UserType ServiceType
 /Total_Cost=Sum(Total_Cost)
 /Episodes_Attendances=Sum(Episodes_Attendances)
 /Beddays = sum(Beddays)
 /NumberPatients =sum(NumberPatients).

add files file =!file+'/08-PIS-costs-HRI_Scot_Temp1.zsav'
 /file =!file+'/08-PIS-costs-HRI_Scot_Temp2.zsav'.

compute gender = 0.
aggregate outfile=!file+'/08-PIS-costs-HRI_Scot_Temp3.zsav'
 /break= HB gender AgeBand UserType ServiceType
 /Total_Cost=Sum(Total_Cost)
 /Episodes_Attendances=Sum(Episodes_Attendances)
 /Beddays = sum(Beddays)
 /NumberPatients =sum(NumberPatients).

add files file =!file+'/08-PIS-costs-HRI_Scot_Temp1.zsav'
 /file =!file+'/08-PIS-costs-HRI_Scot_Temp2.zsav'
 /file =!file+'/08-PIS-costs-HRI_Scot_Temp3.zsav'.

Save outfile=!file+'/08-PIS-costs-HRI_Scot_Final' + !year + '.zsav'
/zcompressed.

** Housekeeping for PIS section.

ERASE FILE= !file+'/08-PIS-costs-HRI_ScotALL.zsav'.
ERASE FILE= !file+'/08-PIS-costs-HRI_Scot50.zsav'.
ERASE FILE= !file+'/08-PIS-costs-HRI_Scot65.zsav'.
ERASE FILE= !file+'/08-PIS-costs-HRI_Scot80.zsav'.
ERASE FILE= !file+'/08-PIS-costs-HRI_Scot95.zsav'.
ERASE FILE =!file+'/08-PIS-costs-HRI_Scot_Temp1.zsav'.
ERASE FILE =!file+'/08-PIS-costs-HRI_Scot_Temp2.zsav'.   
ERASE FILE =!file+'/08-PIS-costs-HRI_Scot_Temp3.zsav'.

*******************************************************************************************************************************************************.
*******************************************************************************************************************************************************
***Number 8 - TOTALS: HRIs - 50%**************************************.
get file = !HRIfile255075.
Select if ScotFlag50=1.
string hb (A30).
compute hb = 'Sc'.

compute all_episodes = (acute_episodes + MH_episodes +gls_episodes + MAT_episodes + OP_newcons_attendances + AE_attendances + pis_dispensed_items).
compute all_beddays= (acute_inpatient_beddays + MH_inpatient_beddays +gls_inpatient_beddays + MAT_inpatient_beddays).

Aggregate outfile=* 
               /break=HB Gender AgeBand
               /Total_Cost = Sum(health_net_cost) 
               /Episodes_Attendances=Sum(ALL_episodes)
               /Beddays=Sum(ALL_beddays)
               /NumberPatients = n.

String UserType (A11).
Compute UserType='Scot-HRI_50'.
      String ServiceType (A30).
      Compute ServiceType='ALL'.

Save outfile=!file+'/08-ALL-costs-HRI_Scot50.zsav'
/zcompressed.

***Number 4 - ALL: HRIs - 65%**************************************.
get file = !HRIfile255075.

Select if ScotFlag65=1.
string hb (A30).
compute HB = 'Sc'.
compute all_episodes = (acute_episodes + MH_episodes +gls_episodes + MAT_episodes + OP_newcons_attendances + AE_attendances + pis_dispensed_items).
compute all_beddays= (acute_inpatient_beddays + MH_inpatient_beddays +gls_inpatient_beddays + MAT_inpatient_beddays).

Aggregate outfile=* 
               /break=HB Gender AgeBand
               /Total_Cost = Sum(health_net_cost) 
               /Episodes_Attendances=Sum(ALL_episodes)
               /Beddays=Sum(ALL_beddays)
               /NumberPatients = n.

String UserType (A11).
Compute UserType='Scot-HRI_65'.
      String ServiceType (A30).
      Compute ServiceType='ALL'.

Save outfile=!file+'/08-ALL-costs-HRI_Scot65.zsav'
/zcompressed.

***Number 4 - ALL: HRIs - 80%**************************************.
get file = !HRIfile255075.

Select if ScotFlag80=1.
string hb (A30).
compute hb= 'Sc'.
compute all_episodes = (acute_episodes + MH_episodes +gls_episodes + MAT_episodes + OP_newcons_attendances + AE_attendances + pis_dispensed_items).
compute all_beddays= (acute_inpatient_beddays + MH_inpatient_beddays +gls_inpatient_beddays + MAT_inpatient_beddays).

Aggregate outfile=* 
               /break=HB Gender AgeBand
               /Total_Cost = Sum(health_net_cost) 
               /Episodes_Attendances=Sum(ALL_episodes)
               /Beddays=Sum(ALL_beddays)
               /NumberPatients = n.

String UserType (A11).
Compute UserType='Scot-HRI_80'.
      String ServiceType (A30).
      Compute ServiceType='ALL'.

Save outfile=!file+'/08-ALL-costs-HRI_Scot80.zsav'
/zcompressed.

***Number 4 - ALL: HRIs - 95%**************************************.
get file = !HRIfile255075.

Select if ScotFlag95=1.
string hb (A30).
compute hb= 'Sc'.
compute all_episodes = (acute_episodes + MH_episodes +gls_episodes + MAT_episodes + OP_newcons_attendances + AE_attendances + pis_dispensed_items).
compute all_beddays= (acute_inpatient_beddays + MH_inpatient_beddays +gls_inpatient_beddays + MAT_inpatient_beddays).

Aggregate outfile=* 
               /break=HB Gender AgeBand
               /Total_Cost = Sum(health_net_cost) 
               /Episodes_Attendances=Sum(ALL_episodes)
               /Beddays=Sum(ALL_beddays)
               /NumberPatients = n.

String UserType (A11).
Compute UserType='Scot-HRI_95'.
      String ServiceType (A30).
      Compute ServiceType='ALL'.

Save outfile=!file+'/08-ALL-costs-HRI_Scot95.zsav'
/zcompressed.

***Number 4 - ALL : HRIs - 100% (ALL Patients**************************************.
get file = !HRIfile255075.

string hb (A30).
compute hb = 'Sc'.
compute all_episodes = (acute_episodes + MH_episodes +gls_episodes + MAT_episodes + OP_newcons_attendances + AE_attendances + pis_dispensed_items).
compute all_beddays= (acute_inpatient_beddays + MH_inpatient_beddays +gls_inpatient_beddays + MAT_inpatient_beddays).

Aggregate outfile=* 
               /break=HB Gender AgeBand
               /Total_Cost = Sum(health_net_cost) 
               /Episodes_Attendances=Sum(ALL_episodes)
               /Beddays=Sum(ALL_beddays)
               /NumberPatients = n.

String UserType (A11).
Compute UserType='Scot-HRI_ALL'.
      String ServiceType (A30).
      Compute ServiceType='ALL'.

Save outfile=!file+'/08-ALL-costs-HRI_ScotALL.zsav'
/zcompressed.

** Bring all Acute file together and create totals.

add files file =!file+'/08-ALL-costs-HRI_ScotALL.zsav'
 /file =!file+'/08-ALL-costs-HRI_Scot50.zsav'
 /file =!file+'/08-ALL-costs-HRI_Scot65.zsav'
 /file =!file+'/08-ALL-costs-HRI_Scot80.zsav'
 /file =!file+'/08-ALL-costs-HRI_Scot95.zsav'.

Save outfile=!file+'/08-ALL-costs-HRI_Scot_Temp1.zsav'
/zcompressed.

compute ageband = 'All ages'.
aggregate outfile=!file+'/08-ALL-costs-HRI_Scot_Temp2.zsav'
 /break= HB gender AgeBand UserType ServiceType
 /Total_Cost=Sum(Total_Cost)
 /Episodes_Attendances=Sum(Episodes_Attendances)
 /Beddays = sum(Beddays)
 /NumberPatients =sum(NumberPatients).

add files file =!file+'/08-ALL-costs-HRI_Scot_Temp1.zsav'
 /file =!file+'/08-ALL-costs-HRI_Scot_Temp2.zsav'.

compute gender = 0.
aggregate outfile=!file+'/08-ALL-costs-HRI_Scot_Temp3.zsav'
 /break= HB gender AgeBand UserType ServiceType
 /Total_Cost=Sum(Total_Cost)
 /Episodes_Attendances=Sum(Episodes_Attendances)
 /Beddays = sum(Beddays)
 /NumberPatients =sum(NumberPatients).

add files file =!file+'/08-ALL-costs-HRI_Scot_Temp1.zsav'
 /file =!file+'/08-ALL-costs-HRI_Scot_Temp2.zsav'
 /file =!file+'/08-ALL-costs-HRI_Scot_Temp3.zsav'.

Save outfile=!file+'/08-ALL-costs-HRI_Scot_Final'+ !year + '.zsav'
/zcompressed.

** Housekeeping for ALL section.

ERASE FILE= !file+'/08-ALL-costs-HRI_ScotALL.zsav'.
ERASE FILE= !file+'/08-ALL-costs-HRI_Scot50.zsav'.
ERASE FILE= !file+'/08-ALL-costs-HRI_Scot65.zsav'.
ERASE FILE= !file+'/08-ALL-costs-HRI_Scot80.zsav'.
ERASE FILE= !file+'/08-ALL-costs-HRI_Scot95.zsav'.
ERASE FILE =!file+'/08-ALL-costs-HRI_Scot_Temp1.zsav'.
ERASE FILE =!file+'/08-ALL-costs-HRI_Scot_Temp2.zsav'.   
ERASE FILE =!file+'/08-ALL-costs-HRI_Scot_Temp3.zsav'.

******************************************************************************************************************************************************************************.
** ADD files together and create required geographies.

add files file = !file+'/08-ALL-costs-HRI_Scot_Final' + !year + '.zsav'
 /file =!file+'/08-Acute-costs-HRI_Scot_Final' + !year +'.zsav'
 /file =!file+'/08-MH-costs-HRI_Scot_Final' + !year +'.zsav'
 /file =!file+'/08-GLS-costs-HRI_Scot_Final' + !year +'.zsav'
 /file =!file+'/08-MAT-costs-HRI_Scot_Final' + !year +'.zsav'
 /file =!file+'/08-OP-costs-HRI_Scot_Final' + !year +'.zsav'
 /file =!file+'/08-AE-costs-HRI_Scot_Final' + !year +'.zsav'
 /file =!file+'/08-PIS-costs-HRI_Scot_Final' + !year + '.zsav'.

* Recreate Gender as a string.
RENAME VARIABLES (gender = oldgender).
String Gender (A10).
if oldgender = 0 Gender = "Both".
if oldgender = 1 Gender = "Male".
if oldgender = 2 Gender = "Female".

* Create year.
String Year (a7).
compute Year = !year2.

*add Scot Name.
String HBname (a40).
compute HBname eq 'Scotland Region'.
String HB_CODE (a9).
compute HB_CODE eq 'S08000060'.

Save outfile=!file+'/TAB-TDE-ALL-costs-HRI_Scot_Final' + !year + '.zsav'
/keep Year HBname HB_CODE Gender AgeBand UserType ServiceType Total_Cost Episodes_Attendances Beddays NumberPatients
/zcompressed.

get file=!file+'/TAB-TDE-ALL-costs-HRI_Scot_Final' + !year + '.zsav'.

**********************************************************************************************************************************************.
*DELETE working FILES FOR HOUSEKEEPING*.

ERASE FILE=!file+'/08-ALL-costs-HRI_Scot_Final' + !year + '.zsav'.
ERASE FILE=!file+'/08-Acute-costs-HRI_Scot_Final' + !year + '.zsav'.
ERASE FILE=!file+'/08-MH-costs-HRI_Scot_Final' + !year + '.zsav'.
ERASE FILE=!file+'/08-GLS-costs-HRI_Scot_Final' + !year + '.zsav'.
ERASE FILE=!file+'/08-MAT-costs-HRI_Scot_Final' + !year + '.zsav'.
ERASE FILE=!file+'/08-OP-costs-HRI_Scot_Final' + !year + '.zsav'.
ERASE FILE=!file+'/08-AE-costs-HRI_Scot_Final' + !year + '.zsav'.
ERASE FILE=!file+'/08-PIS-costs-HRI_Scot_Final' + !year + '.zsav'.
