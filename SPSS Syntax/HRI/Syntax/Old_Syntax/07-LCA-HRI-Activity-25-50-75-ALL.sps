* Encoding: UTF-8.
*04. LCA-HRI-Activity. Health activities and costs breakdown.
*Orginally created by Kara Sellar 18/10/13.
 *Amended and updated by ML March 2013
*Amended and updated by Alison McClelland April 2015 for HRI-200,000-days. 
*Updated KR June 2015 for Tableau Workbook.
*FC Oct 2018. Updated Mental Health activity flag names to reflect changes in variable formats within Source Linkage File. 

 * Define !file()
     '/conf/irf/09-Tableau-Outputs/01-Development/02-SPSS-Outputs/03-HRI/Working Folder'
!Enddefine.

Define !file()
     '/conf/sourcedev/TableauUpdates/HRI/1718/Outputs/'
!Enddefine.



******************************************************************
***** MUST UPDATE THESE BEFORE RUNNING ********.

Define !HRIfile255075()
     '/conf/sourcedev/TableauUpdates/HRI/1718/Outputs/01-HRI-1718-255075.sav'.
!Enddefine.

*Macro 1.
Define !year()
'201718'
!Enddefine.

Define !year2()
'2017/18'
!Enddefine.

*Macro 2.
Define !popyear()
'2017'
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

** HRI THRESHOLDS amended - Sept 15 - EP.
** Now <50, <65, <80, <95. 
*** Also creating HRI_Groups High (<50), High to Meduim (50-<65), Meduim (65-<80), Meduim to Low (80-<95) and Low (95+).
****************************************************************************************************************************************************

get file = '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.zsav'.
select if gender ne 0.
select if hri_lca ne 9.
*Feb. 2019 FC. 
*Non-Service Users must be excluded by the calculations (only for health activities from 2015/16 onwards)
 Otherwise, these users will be counted in the 'Low Users' category.
select if NSU ne 1.
exe.


rename variables (HRI_LcaP=lcap)(HRI_hbP=hbp)(HRI_scotP=Scotp).

* Create required agebands.
string AgeBand (A15).
If (Age lt 18) AgeBand = '<18'.
If (Age ge 18 and Age le 44) AgeBand = '18-44'.
If (Age ge 45 and Age le 64) AgeBand = '45-64'.
If (Age ge 65 and Age le 74) AgeBand = '65-74'.
If (Age ge 75 and Age le 84) AgeBand = '75-84'.
If (Age ge 85) AgeBand = '85+'.
*Execute. 

*frequencies variables= ageband.

* Create HRI flags for different Thresholds.
if LcaP le 50 LcaFlag50 = 1.
if hbp le 50 HBFlag50 = 1.
if Scotp le 50 ScotFlag50 = 1.

if LcaP le 65 LcaFlag65 = 1.
if hbp le 65 HBFlag65 = 1.
if Scotp le 65 ScotFlag65 = 1.

if LcaP le 80 LcaFlag80 = 1.
if hbp le 80 HBFlag80 = 1.
if Scotp le 80 ScotFlag80 = 1.

if LcaP le 95 LcaFlag95 = 1.
if hbp le 95 HBFlag95 = 1.
if Scotp le 95 ScotFlag95 = 1.
*exe.

String HRI_Group (A30).
* Create HRI grouping.
if (lcaP lt 50) HRI_Group = 'High'.
if (lcaP ge 50 and lcaP lt 65) HRI_Group = 'High to Medium'.
if (lcaP ge 65 and lcaP lt 80) HRI_Group = 'Medium'.
if (lcaP ge 80 and lcaP lt 95) HRI_Group = 'Medium to Low'.
if (lcaP ge 95) HRI_Group = 'Low'.
*rename variables (hb2 = hb).
EXE.

RENAME VARIABLES datazone2011 = datazone.
alter type datazone (A9).
EXE.




***FC Oct. 2018. All Mental Health variables were renamed according to Source Linkage File update. 
***Other variables were also renamed: HB of residence 'hbres' (now 'hbrescode') and 'deceased flag' (now 'deceased').

Save outfile =!HRIfile255075
/keep year gender health_net_cost health_net_costincDNAs acute_episodes acute_daycase_episodes acute_inpatient_episodes acute_el_inpatient_episodes acute_non_el_inpatient_episodes
acute_cost acute_daycase_cost acute_inpatient_cost acute_el_inpatient_cost acute_non_el_inpatient_cost acute_inpatient_beddays acute_el_inpatient_beddays
acute_non_el_inpatient_beddays mat_episodes mat_daycase_episodes mat_inpatient_episodes mat_cost mat_daycase_cost mat_inpatient_cost mat_inpatient_beddays
MH_episodes MH_daycase_episodes MH_inpatient_episodes MH_el_inpatient_episodes MH_non_el_inpatient_episodes MH_cost
MH_daycase_cost MH_inpatient_cost MH_el_inpatient_cost MH_non_el_inpatient_cost MH_inpatient_beddays MH_el_inpatient_beddays
MH_non_el_inpatient_beddays gls_episodes gls_daycase_episodes gls_inpatient_episodes gls_el_inpatient_episodes gls_non_el_inpatient_episodes gls_cost
gls_daycase_cost gls_inpatient_cost gls_el_inpatient_cost gls_non_el_inpatient_cost gls_inpatient_beddays gls_el_inpatient_beddays gls_non_el_inpatient_beddays
op_newcons_attendances op_newcons_dnas op_cost_attend op_cost_dnas ae_attendances ae_cost pis_dispensed_items pis_cost deceased hbrescode lca
simd2016_sc_quintile simd2016_sc_decile simd2016_HB2014_decile simd2016_HB2014_quintile cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib 
cancer arth parkinsons liver lcaP hbP ScotP LcaFlag50 HBFlag50 ScotFlag50 LcaFlag65 HBFlag65 ScotFlag65
LcaFlag80 HBFlag80 ScotFlag80 LcaFlag95 HBFlag95 ScotFlag95 HRI_Group AgeBand datazone. 




** Create totals for each Service type and Threshold level

***Number 1- ACUTE: HRIs - 50%**************************************.
get file = !HRIfile255075.

Select if LcaFlag50=1.
Select if acute_episodes ge 1.
exe.

rename variables (acute_cost = Total_Cost) (acute_episodes = Episodes_Attendances) (Acute_inpatient_beddays = Beddays).

Aggregate outfile=* 
               /break=Lca Gender AgeBand
               /Total_Cost Episodes_Attendances Beddays=Sum(Total_Cost Episodes_Attendances Beddays)      
               /NumberPatients = n.


String UserType (A11).
Compute UserType='LCA-HRI_50'.
      String ServiceType (A30).
      Compute ServiceType='Acute'.
Execute.

Save outfile=!file+'/08-Acute-costs-HRI_LCA50.sav'.



***Number 1- ACUTE: HRIs - 65%**************************************.

get file = !HRIfile255075.

Select if LcaFlag65=1.
Select if acute_episodes ge 1.


rename variables (acute_cost = Total_Cost) (acute_episodes = Episodes_Attendances) (Acute_inpatient_beddays = Beddays).

Aggregate outfile=* 
               /break=Lca Gender AgeBand
               /Total_Cost Episodes_Attendances Beddays=Sum(Total_Cost Episodes_Attendances Beddays)      
               /NumberPatients = n.


String UserType (A11).
Compute UserType='LCA-HRI_65'.
      String ServiceType (A30).
      Compute ServiceType='Acute'.
Execute.


Save outfile=!file+'/08-Acute-costs-HRI_LCA65.sav'.

***Number 1- ACUTE: HRIs - 80%**************************************.
get file = !HRIfile255075.

Select if LcaFlag80=1.
Select if acute_episodes ge 1.


rename variables (acute_cost = Total_Cost) (acute_episodes = Episodes_Attendances) (Acute_inpatient_beddays = Beddays).

Aggregate outfile=* 
               /break=Lca Gender AgeBand
               /Total_Cost Episodes_Attendances Beddays=Sum(Total_Cost Episodes_Attendances Beddays)      
               /NumberPatients = n.


String UserType (A11).
Compute UserType='LCA-HRI_80'.
      String ServiceType (A30).
      Compute ServiceType='Acute'.
Execute.

Save outfile=!file+'/08-Acute-costs-HRI_LCA80.sav'.

***Number 1- ACUTE: HRIs - 95%**************************************.
get file = !HRIfile255075.

Select if LcaFlag95=1.
Select if acute_episodes ge 1.


rename variables (acute_cost = Total_Cost) (acute_episodes = Episodes_Attendances) (Acute_inpatient_beddays = Beddays).

Aggregate outfile=* 
               /break=Lca Gender AgeBand
               /Total_Cost Episodes_Attendances Beddays=Sum(Total_Cost Episodes_Attendances Beddays)      
               /NumberPatients = n.


String UserType (A11).
Compute UserType='LCA-HRI_95'.
      String ServiceType (A30).
      Compute ServiceType='Acute'.
Execute.

Save outfile=!file+'/08-Acute-costs-HRI_LCA95.sav'.

***Number 1- ACUTE: HRIs - 100% (ALL Patients**************************************.
get file = !HRIfile255075.

select if lca ne ' '.
Select if acute_episodes ge 1.


rename variables (acute_cost = Total_Cost) (acute_episodes = Episodes_Attendances) (Acute_inpatient_beddays = Beddays).

Aggregate outfile=* 
               /break=Lca Gender AgeBand
               /Total_Cost Episodes_Attendances Beddays=Sum(Total_Cost Episodes_Attendances Beddays)      
               /NumberPatients = n.

String UserType (A11).
Compute UserType='LCA-HRI_ALL'.
Execute.
      String ServiceType (A30).
      Compute ServiceType='Acute'.
Execute.

Save outfile=!file+'/08-Acute-costs-HRI_LCAALL.sav'.


** Bring all Acute file together and create totals.

add files file =!file+'/08-Acute-costs-HRI_LCAALL.sav'
 /file =!file+'/08-Acute-costs-HRI_LCA50.sav'
 /file =!file+'/08-Acute-costs-HRI_LCA65.sav'
 /file =!file+'/08-Acute-costs-HRI_LCA80.sav'
 /file =!file+'/08-Acute-costs-HRI_LCA95.sav'.
exe.

Save outfile=!file+'/08-Acute-costs-HRI_LCA_Temp1.sav'.

compute ageband = 'All ages'.
aggregate outfile=!file+'/08-Acute-costs-HRI_LCA_Temp2.sav'
 /break= lca gender AgeBand UserType ServiceType
 /Total_Cost Episodes_Attendances Beddays=Sum(Total_Cost Episodes_Attendances Beddays)
 /NumberPatients =sum(NumberPatients).


add files file =!file+'/08-Acute-costs-HRI_LCA_Temp1.sav'
 /file =!file+'/08-Acute-costs-HRI_LCA_Temp2.sav'.
execute. 

compute gender = 0.
aggregate outfile=!file+'/08-Acute-costs-HRI_LCA_Temp3.sav'
 /break= lca gender AgeBand UserType ServiceType
 /Total_Cost Episodes_Attendances Beddays=Sum(Total_Cost Episodes_Attendances Beddays)
 /NumberPatients =sum(NumberPatients).



add files file =!file+'/08-Acute-costs-HRI_LCA_Temp1.sav'
 /file =!file+'/08-Acute-costs-HRI_LCA_Temp2.sav'
 /file =!file+'/08-Acute-costs-HRI_LCA_Temp3.sav'.
execute. 

Save outfile=!file+'/08-Acute-costs-HRI_LCA_Final13.sav'.

****************************************************************************************************************************************************************************.
***Number 2- Mental Health: HRIs - 50%**************************************.
get file = !HRIfile255075.

Select if LcaFlag50=1.
Select if MH_episodes ge 1.


Aggregate outfile=* 
               /break=Lca Gender AgeBand
               /Total_Cost=Sum(MH_cost)      
               /Episodes_Attendances=Sum(MH_episodes)
               /Beddays=Sum(MH_inpatient_beddays)
               /NumberPatients = n.


String UserType (A11).
Compute UserType='LCA-HRI_50'.
String ServiceType (A30).
Compute ServiceType='Mental Health'.
execute.

Save outfile=!file+'/08-MH-costs-HRI_LCA50.sav'.

***Number 2 - Mental Health: HRIs - 65%**************************************.

get file = !HRIfile255075.

Select if LcaFlag65=1.
Select if MH_episodes ge 1.
rename variables (MH_cost = Total_Cost) (MH_episodes = Episodes_Attendances) (MH_inpatient_beddays = Beddays).

Aggregate outfile=* 
               /break=Lca Gender AgeBand
               /Total_Cost Episodes_Attendances Beddays=Sum(Total_Cost Episodes_Attendances Beddays)      
               /NumberPatients = n.


String UserType (A11).
Compute UserType='LCA-HRI_65'.
String ServiceType (A30).
Compute ServiceType='Mental Health'.
Execute.

Save outfile=!file+'/08-MH-costs-HRI_LCA65.sav'.

***Number 2- Mental Health: HRIs - 80%**************************************.
get file = !HRIfile255075.

Select if LcaFlag80=1.
Select if MH_episodes ge 1.

rename variables (MH_cost = Total_Cost) (MH_episodes = Episodes_Attendances) (MH_inpatient_beddays = Beddays).

Aggregate outfile=* 
               /break=Lca Gender AgeBand
               /Total_Cost Episodes_Attendances Beddays=Sum(Total_Cost Episodes_Attendances Beddays)      
               /NumberPatients = n.


String UserType (A11).
Compute UserType='LCA-HRI_80'.
String ServiceType (A30).
Compute ServiceType='Mental Health'.
Execute.

Save outfile=!file+'/08-MH-costs-HRI_LCA80.sav'.

***Number 2- MENTAL HEALTH: HRIs - 95%**************************************.
get file = !HRIfile255075.

Select if LcaFlag95=1.
Select if MH_episodes ge 1.


rename variables (MH_cost = Total_Cost) (MH_episodes = Episodes_Attendances) (MH_inpatient_beddays = Beddays).

Aggregate outfile=* 
               /break=Lca Gender AgeBand
               /Total_Cost Episodes_Attendances Beddays=Sum(Total_Cost Episodes_Attendances Beddays)      
               /NumberPatients = n.

String UserType (A11).
Compute UserType='LCA-HRI_95'.
String ServiceType (A30).
Compute ServiceType='Mental Health'.
Execute.

Save outfile=!file+'/08-MH-costs-HRI_LCA95.sav'.

***Number 2- MENTAL HEALTH : HRIs - 100% (ALL Patients**************************************.
get file = !HRIfile255075.

select if lca ne ' '.
Select if MH_episodes ge 1.

rename variables (MH_cost = Total_Cost) (MH_episodes = Episodes_Attendances) (MH_inpatient_beddays = Beddays).

Aggregate outfile=* 
               /break=Lca Gender AgeBand
               /Total_Cost Episodes_Attendances Beddays=Sum(Total_Cost Episodes_Attendances Beddays)      
               /NumberPatients = n.

String UserType (A11).
Compute UserType='LCA-HRI_ALL'.
String ServiceType (A30).
Compute ServiceType='Mental Health'.
Execute.

Save outfile=!file+'/08-MH-costs-HRI_LCAALL.sav'.


** Bring all Acute file together and create totals.

add files file =!file+'/08-MH-costs-HRI_LCAALL.sav'
 /file =!file+'/08-MH-costs-HRI_LCA50.sav'
 /file =!file+'/08-MH-costs-HRI_LCA65.sav'
 /file =!file+'/08-MH-costs-HRI_LCA80.sav'
 /file =!file+'/08-MH-costs-HRI_LCA95.sav'.
exe.

Save outfile=!file+'/08-MH-costs-HRI_LCA_Temp1.sav'.

compute ageband = 'All ages'.
aggregate outfile=!file+'/08-MH-costs-HRI_LCA_Temp2.sav'
 /break= lca gender AgeBand UserType ServiceType
 /Total_Cost Episodes_Attendances Beddays=Sum(Total_Cost Episodes_Attendances Beddays)      
 /NumberPatients =sum(NumberPatients).


add files file =!file+'/08-MH-costs-HRI_LCA_Temp1.sav'
 /file =!file+'/08-MH-costs-HRI_LCA_Temp2.sav'.
execute. 

compute gender = 0.
aggregate outfile=!file+'/08-MH-costs-HRI_LCA_Temp3.sav'
 /break= lca gender AgeBand UserType ServiceType
 /Total_Cost Episodes_Attendances Beddays=Sum(Total_Cost Episodes_Attendances Beddays)     
 /NumberPatients =sum(NumberPatients).


add files file =!file+'/08-MH-costs-HRI_LCA_Temp1.sav'
 /file =!file+'/08-MH-costs-HRI_LCA_Temp2.sav'
 /file =!file+'/08-MH-costs-HRI_LCA_Temp3.sav'.
execute. 

Save outfile=!file+'/08-MH-costs-HRI_LCA_Final13.sav'.

***********************************************************************************************************************************************************************************.
***Number 3- GLS: HRIs - 50%**************************************.
get file = !HRIfile255075.

Select if LcaFlag50=1.
Select if GLS_episodes ge 1.
rename variables (GLS_cost = Total_Cost) (GLS_episodes = Episodes_Attendances) (GLS_inpatient_beddays = Beddays).

Aggregate outfile=* 
               /break=Lca Gender AgeBand
               /Total_Cost Episodes_Attendances Beddays=Sum(Total_Cost Episodes_Attendances Beddays)      
               /NumberPatients = n.


String UserType (A11).
Compute UserType='LCA-HRI_50'.
String ServiceType (A30).
Compute ServiceType='GLS'.
Execute.

Save outfile=!file+'/08-GLS-costs-HRI_LCA50.sav'.

***Number 3 - GLS: HRIs - 65%**************************************.

get file = !HRIfile255075.

Select if LcaFlag65=1.
Select if GLS_episodes ge 1.

rename variables (GLS_cost = Total_Cost) (GLS_episodes = Episodes_Attendances) (GLS_inpatient_beddays = Beddays).

Aggregate outfile=* 
               /break=Lca Gender AgeBand
               /Total_Cost Episodes_Attendances Beddays=Sum(Total_Cost Episodes_Attendances Beddays)      
               /NumberPatients = n.


String UserType (A11).
Compute UserType='LCA-HRI_65'.
String ServiceType (A30).
Compute ServiceType='GLS'.
Execute.

Save outfile=!file+'/08-GLS-costs-HRI_LCA65.sav'.

***Number 3- GLS: HRIs - 80%**************************************.
get file = !HRIfile255075.

Select if LcaFlag80=1.
Select if GLS_episodes ge 1.


rename variables (GLS_cost = Total_Cost) (GLS_episodes = Episodes_Attendances) (GLS_inpatient_beddays = Beddays).

Aggregate outfile=* 
               /break=Lca Gender AgeBand
               /Total_Cost Episodes_Attendances Beddays=Sum(Total_Cost Episodes_Attendances Beddays)      
               /NumberPatients = n.


String UserType (A11).
Compute UserType='LCA-HRI_80'.
      String ServiceType (A30).
      Compute ServiceType='GLS'.
Execute.

Save outfile=!file+'/08-GLS-costs-HRI_LCA80.sav'.

***Number 3- GLS: HRIs - 95%**************************************.
get file = !HRIfile255075.

Select if LcaFlag95=1.
Select if GLS_episodes ge 1.


rename variables (GLS_cost = Total_Cost) (GLS_episodes = Episodes_Attendances) (GLS_inpatient_beddays = Beddays).

Aggregate outfile=* 
               /break=Lca Gender AgeBand
               /Total_Cost Episodes_Attendances Beddays=Sum(Total_Cost Episodes_Attendances Beddays)      
               /NumberPatients = n.


String UserType (A11).
Compute UserType='LCA-HRI_95'.
      String ServiceType (A30).
      Compute ServiceType='GLS'.
Execute.

Save outfile=!file+'/08-GLS-costs-HRI_LCA95.sav'.

***Number 3- GLS : HRIs - 100% (ALL Patients**************************************.
get file = !HRIfile255075.

select if lca ne ' '.
Select if GLS_episodes ge 1.
rename variables (GLS_cost = Total_Cost) (GLS_episodes = Episodes_Attendances) (GLS_inpatient_beddays = Beddays).

Aggregate outfile=* 
               /break=Lca Gender AgeBand
               /Total_Cost Episodes_Attendances Beddays=Sum(Total_Cost Episodes_Attendances Beddays)      
               /NumberPatients = n.

String UserType (A11).
Compute UserType='LCA-HRI_ALL'.
      String ServiceType (A30).
      Compute ServiceType='GLS'.
Execute.

Save outfile=!file+'/08-GLS-costs-HRI_LCAALL.sav'.


** Bring all Acute file together and create totals.

add files file =!file+'/08-GLS-costs-HRI_LCAALL.sav'
 /file =!file+'/08-GLS-costs-HRI_LCA50.sav'
 /file =!file+'/08-GLS-costs-HRI_LCA65.sav'
 /file =!file+'/08-GLS-costs-HRI_LCA80.sav'
 /file =!file+'/08-GLS-costs-HRI_LCA95.sav'.
exe.

Save outfile=!file+'/08-GLS-costs-HRI_LCA_Temp1.sav'.

compute ageband = 'All ages'.
aggregate outfile=!file+'/08-GLS-costs-HRI_LCA_Temp2.sav'
 /break= lca gender AgeBand UserType ServiceType
 /Total_Cost Episodes_Attendances Beddays=Sum(Total_Cost Episodes_Attendances Beddays)    
 /NumberPatients =sum(NumberPatients).


add files file =!file+'/08-GLS-costs-HRI_LCA_Temp1.sav'
 /file =!file+'/08-GLS-costs-HRI_LCA_Temp2.sav'.
execute. 

compute gender = 0.
aggregate outfile=!file+'/08-GLS-costs-HRI_LCA_Temp3.sav'
 /break= lca gender AgeBand UserType ServiceType
 /Total_Cost Episodes_Attendances Beddays=Sum(Total_Cost Episodes_Attendances Beddays)    
 /NumberPatients =sum(NumberPatients).


add files file =!file+'/08-GLS-costs-HRI_LCA_Temp1.sav'
 /file =!file+'/08-GLS-costs-HRI_LCA_Temp2.sav'
 /file =!file+'/08-GLS-costs-HRI_LCA_Temp3.sav'.
execute. 

Save outfile=!file+'/08-GLS-costs-HRI_LCA_Final13.sav'.

********************************************************************************************************************************************************************************.
***Number 4 - MAT: HRIs - 50%**************************************.
get file = !HRIfile255075.

Select if LcaFlag50=1.
Select if MAT_episodes ge 1.

rename variables (MAT_cost = Total_Cost) (MAT_episodes = Episodes_Attendances) (MAT_inpatient_beddays = Beddays).

Aggregate outfile=* 
               /break=Lca Gender AgeBand
               /Total_Cost Episodes_Attendances Beddays=Sum(Total_Cost Episodes_Attendances Beddays)      
               /NumberPatients = n.


String UserType (A11).
Compute UserType='LCA-HRI_50'.
      String ServiceType (A30).
      Compute ServiceType='MAT'.
Execute.

Save outfile=!file+'/08-MAT-costs-HRI_LCA50.sav'.

***Number 4 - MAT: HRIs - 65%**************************************.

get file = !HRIfile255075.

Select if LcaFlag65=1.
Select if MAT_episodes ge 1.


rename variables (MAT_cost = Total_Cost) (MAT_episodes = Episodes_Attendances) (MAT_inpatient_beddays = Beddays).

Aggregate outfile=* 
               /break=Lca Gender AgeBand
               /Total_Cost Episodes_Attendances Beddays=Sum(Total_Cost Episodes_Attendances Beddays)      
               /NumberPatients = n.


String UserType (A11).
Compute UserType='LCA-HRI_65'.
      String ServiceType (A30).
      Compute ServiceType='MAT'.
Execute.

Save outfile=!file+'/08-MAT-costs-HRI_LCA65.sav'.

***Number 4 - MAT: HRIs - 80%**************************************.
get file = !HRIfile255075.

Select if LcaFlag80=1.
Select if MAT_episodes ge 1.

rename variables (MAT_cost = Total_Cost) (MAT_episodes = Episodes_Attendances) (MAT_inpatient_beddays = Beddays).

Aggregate outfile=* 
               /break=Lca Gender AgeBand
               /Total_Cost Episodes_Attendances Beddays=Sum(Total_Cost Episodes_Attendances Beddays)      
               /NumberPatients = n.


String UserType (A11).
Compute UserType='LCA-HRI_80'.
      String ServiceType (A30).
      Compute ServiceType='MAT'.
Execute.

Save outfile=!file+'/08-MAT-costs-HRI_LCA80.sav'.

***Number 4 - MAT: HRIs - 95%**************************************.
get file = !HRIfile255075.

Select if LcaFlag95=1.
Select if MAT_episodes ge 1.


rename variables (MAT_cost = Total_Cost) (MAT_episodes = Episodes_Attendances) (MAT_inpatient_beddays = Beddays).

Aggregate outfile=* 
               /break=Lca Gender AgeBand
               /Total_Cost Episodes_Attendances Beddays=Sum(Total_Cost Episodes_Attendances Beddays)      
               /NumberPatients = n.

String UserType (A11).
Compute UserType='LCA-HRI_95'.
      String ServiceType (A30).
      Compute ServiceType='MAT'.
Execute.

Save outfile=!file+'/08-MAT-costs-HRI_LCA95.sav'.

***Number 4 - MAT : HRIs - 100% (ALL Patients**************************************.
get file = !HRIfile255075.

select if lca ne ' '.
Select if MAT_episodes ge 1.


rename variables (MAT_cost = Total_Cost) (MAT_episodes = Episodes_Attendances) (MAT_inpatient_beddays = Beddays).

Aggregate outfile=* 
               /break=Lca Gender AgeBand
               /Total_Cost Episodes_Attendances Beddays=Sum(Total_Cost Episodes_Attendances Beddays)      
               /NumberPatients = n.

String UserType (A11).
Compute UserType='LCA-HRI_ALL'.
String ServiceType (A30).
 Compute ServiceType='MAT'.
Execute.

Save outfile=!file+'/08-MAT-costs-HRI_LCAALL.sav'.


** Bring all Acute file together and create totals.

add files file =!file+'/08-MAT-costs-HRI_LCAALL.sav'
 /file =!file+'/08-MAT-costs-HRI_LCA50.sav'
 /file =!file+'/08-MAT-costs-HRI_LCA65.sav'
 /file =!file+'/08-MAT-costs-HRI_LCA80.sav'
 /file =!file+'/08-MAT-costs-HRI_LCA95.sav'.
exe.

Save outfile=!file+'/08-MAT-costs-HRI_LCA_Temp1.sav'.

compute ageband = 'All ages'.
aggregate outfile=!file+'/08-MAT-costs-HRI_LCA_Temp2.sav'
 /break= lca gender AgeBand UserType ServiceType
 /Total_Cost Episodes_Attendances Beddays=Sum(Total_Cost Episodes_Attendances Beddays)   
 /NumberPatients =sum(NumberPatients).


add files file =!file+'/08-MAT-costs-HRI_LCA_Temp1.sav'
 /file =!file+'/08-MAT-costs-HRI_LCA_Temp2.sav'.
execute. 

compute gender = 0.
aggregate outfile=!file+'/08-MAT-costs-HRI_LCA_Temp3.sav'
 /break= lca gender AgeBand UserType ServiceType
 /Total_Cost Episodes_Attendances Beddays=Sum(Total_Cost Episodes_Attendances Beddays)   
 /NumberPatients =sum(NumberPatients).



add files file =!file+'/08-MAT-costs-HRI_LCA_Temp1.sav'
 /file =!file+'/08-MAT-costs-HRI_LCA_Temp2.sav'
 /file =!file+'/08-MAT-costs-HRI_LCA_Temp3.sav'.
execute. 

Save outfile=!file+'/08-MAT-costs-HRI_LCA_Final13.sav'.


*******************************************************************************************************************************************************.
***Number 5 - OP: HRIs - 50%**************************************.
get file = !HRIfile255075.

Select if LcaFlag50=1.
Select if OP_newcons_attendances  ge 1.


rename variables (op_cost_attend = Total_Cost) (op_newcons_attendances = Episodes_Attendances).

Aggregate outfile=* 
               /break=Lca Gender AgeBand
               /Total_Cost Episodes_Attendances =Sum(Total_Cost Episodes_Attendances)      
               /NumberPatients = n.


String UserType (A11).
Compute UserType='LCA-HRI_50'.
String ServiceType (A30).
Compute ServiceType='OP'.
execute.


Save outfile=!file+'/08-OP-costs-HRI_LCA50.sav'.

***Number 5 - OP: HRIs - 65%**************************************.

get file = !HRIfile255075.

Select if LcaFlag65=1.
Select if OP_newcons_attendances  ge 1.

rename variables (op_cost_attend = Total_Cost) (op_newcons_attendances = Episodes_Attendances).

Aggregate outfile=* 
               /break=Lca Gender AgeBand
               /Total_Cost Episodes_Attendances =Sum(Total_Cost Episodes_Attendances)      
               /NumberPatients = n.


String UserType (A11).
Compute UserType='LCA-HRI_65'.
      String ServiceType (A30).
      Compute ServiceType='OP'.
Execute.

Save outfile=!file+'/08-OP-costs-HRI_LCA65.sav'.

***Number 5 - OP: HRIs - 80%**************************************.
get file = !HRIfile255075.

Select if LcaFlag80=1.
Select if OP_newcons_attendances  ge 1.


rename variables (op_cost_attend = Total_Cost) (op_newcons_attendances = Episodes_Attendances).

Aggregate outfile=* 
               /break=Lca Gender AgeBand
               /Total_Cost Episodes_Attendances =Sum(Total_Cost Episodes_Attendances)      
               /NumberPatients = n.


String UserType (A11).
Compute UserType='LCA-HRI_80'.
      String ServiceType (A30).
      Compute ServiceType='OP'.
Execute.

Save outfile=!file+'/08-OP-costs-HRI_LCA80.sav'.

***Number 5 - OP: HRIs - 95%**************************************.
get file = !HRIfile255075.

Select if LcaFlag95=1.
Select if OP_newcons_attendances  ge 1.


rename variables (op_cost_attend = Total_Cost) (op_newcons_attendances = Episodes_Attendances).

Aggregate outfile=* 
               /break=Lca Gender AgeBand
               /Total_Cost Episodes_Attendances =Sum(Total_Cost Episodes_Attendances)      
               /NumberPatients = n.


String UserType (A11).
Compute UserType='LCA-HRI_95'.
      String ServiceType (A30).
      Compute ServiceType='OP'.
Execute.

Save outfile=!file+'/08-OP-costs-HRI_LCA95.sav'.

***Number 5 - OP : HRIs - 100% (ALL Patients**************************************.
get file = !HRIfile255075.

select if lca ne ' '.
Select if OP_newcons_attendances  ge 1.

rename variables (op_cost_attend = Total_Cost) (op_newcons_attendances = Episodes_Attendances).

Aggregate outfile=* 
               /break=Lca Gender AgeBand
               /Total_Cost Episodes_Attendances =Sum(Total_Cost Episodes_Attendances)      
               /NumberPatients = n.

String UserType (A11).
Compute UserType='LCA-HRI_ALL'.
      String ServiceType (A30).
      Compute ServiceType='OP'.
Execute.

Save outfile=!file+'/08-OP-costs-HRI_LCAALL.sav'.


** Bring all Acute file together and create totals.

add files file =!file+'/08-OP-costs-HRI_LCAALL.sav'
 /file =!file+'/08-OP-costs-HRI_LCA50.sav'
 /file =!file+'/08-OP-costs-HRI_LCA65.sav'
 /file =!file+'/08-OP-costs-HRI_LCA80.sav'
 /file =!file+'/08-OP-costs-HRI_LCA95.sav'.
exe.

*Add in missing beddays variable.
Compute Beddays = 0.
Save outfile=!file+'/08-OP-costs-HRI_LCA_Temp1.sav'.

compute ageband = 'All ages'.
aggregate outfile=!file+'/08-OP-costs-HRI_LCA_Temp2.sav'
 /break= lca gender AgeBand UserType ServiceType
 /Total_Cost Episodes_Attendances Beddays=Sum(Total_Cost Episodes_Attendances Beddays)  
 /NumberPatients =sum(NumberPatients).


add files file =!file+'/08-OP-costs-HRI_LCA_Temp1.sav'
 /file =!file+'/08-OP-costs-HRI_LCA_Temp2.sav'.
execute. 

compute gender = 0.
aggregate outfile=!file+'/08-OP-costs-HRI_LCA_Temp3.sav'
 /break= lca gender AgeBand UserType ServiceType
 /Total_Cost Episodes_Attendances Beddays=Sum(Total_Cost Episodes_Attendances Beddays)  
 /NumberPatients =sum(NumberPatients).



add files file =!file+'/08-OP-costs-HRI_LCA_Temp1.sav'
 /file =!file+'/08-OP-costs-HRI_LCA_Temp2.sav'
 /file =!file+'/08-OP-costs-HRI_LCA_Temp3.sav'.
exe. 

Save outfile=!file+'/08-OP-costs-HRI_LCA_Final13.sav'.


********************************************************************************************************************************************************.

***Number 6 - AE: HRIs - 50%**************************************.
get file = !HRIfile255075.

Select if LcaFlag50=1.
Select if AE_attendances  ge 1.
rename variables (ae_cost = Total_Cost) (AE_attendances = Episodes_Attendances).

Aggregate outfile=* 
               /break=Lca Gender AgeBand
               /Total_Cost Episodes_Attendances =Sum(Total_Cost Episodes_Attendances)      
               /NumberPatients = n.


String UserType (A11).
Compute UserType='LCA-HRI_50'.
      String ServiceType (A30).
      Compute ServiceType='AE'.
Execute.

Save outfile=!file+'/08-AE-costs-HRI_LCA50.sav'.

***Number 6 - AE: HRIs - 65%**************************************.
get file = !HRIfile255075.

Select if LcaFlag65=1.
Select if ae_attendances  ge 1.


rename variables (ae_cost = Total_Cost) (AE_attendances = Episodes_Attendances).

Aggregate outfile=* 
               /break=Lca Gender AgeBand
               /Total_Cost Episodes_Attendances =Sum(Total_Cost Episodes_Attendances)      
               /NumberPatients = n.


String UserType (A11).
Compute UserType='LCA-HRI_65'.
      String ServiceType (A30).
      Compute ServiceType='AE'.
Execute.

Save outfile=!file+'/08-AE-costs-HRI_LCA65.sav'.

***Number 6 - AE: HRIs - 80%**************************************.
get file = !HRIfile255075.

Select if LcaFlag80=1.
Select if AE_attendances  ge 1.


rename variables (ae_cost = Total_Cost) (AE_attendances = Episodes_Attendances).

Aggregate outfile=* 
               /break=Lca Gender AgeBand
               /Total_Cost Episodes_Attendances =Sum(Total_Cost Episodes_Attendances)      
               /NumberPatients = n.



String UserType (A11).
Compute UserType='LCA-HRI_80'.
      String ServiceType (A30).
      Compute ServiceType='AE'.
Execute.

Save outfile=!file+'/08-AE-costs-HRI_LCA80.sav'.

***Number 6 - AE: HRIs - 95%**************************************.
get file = !HRIfile255075.

Select if LcaFlag95=1.
Select if AE_attendances  ge 1.


rename variables (ae_cost = Total_Cost) (AE_attendances = Episodes_Attendances).

Aggregate outfile=* 
               /break=Lca Gender AgeBand
               /Total_Cost Episodes_Attendances =Sum(Total_Cost Episodes_Attendances)      
               /NumberPatients = n.


String UserType (A11).
Compute UserType='LCA-HRI_95'.
      String ServiceType (A30).
      Compute ServiceType='AE'.
Execute.

Save outfile=!file+'/08-AE-costs-HRI_LCA95.sav'.

***Number 6 - AE : HRIs - 100% (ALL Patients**************************************.
get file = !HRIfile255075.

select if lca ne ' '.
Select if AE_attendances  ge 1.


rename variables (ae_cost = Total_Cost) (AE_attendances = Episodes_Attendances).

Aggregate outfile=* 
               /break=Lca Gender AgeBand
               /Total_Cost Episodes_Attendances =Sum(Total_Cost Episodes_Attendances)      
               /NumberPatients = n.


String UserType (A11).
Compute UserType='LCA-HRI_ALL'.
      String ServiceType (A30).
      Compute ServiceType='AE'.
Execute.

Save outfile=!file+'/08-AE-costs-HRI_LCAALL.sav'.


** Bring all Acute file together and create totals.

add files file =!file+'/08-AE-costs-HRI_LCAALL.sav'
 /file =!file+'/08-AE-costs-HRI_LCA50.sav'
 /file =!file+'/08-AE-costs-HRI_LCA65.sav'
 /file =!file+'/08-AE-costs-HRI_LCA80.sav'
 /file =!file+'/08-AE-costs-HRI_LCA95.sav'.
exe.
*Add in missing beddays variable.
Compute Beddays = 0.
Save outfile=!file+'/08-AE-costs-HRI_LCA_Temp1.sav'.

compute ageband = 'All ages'.
aggregate outfile=!file+'/08-AE-costs-HRI_LCA_Temp2.sav'
 /break= lca gender AgeBand UserType ServiceType
 /Total_Cost Episodes_Attendances Beddays=Sum(Total_Cost Episodes_Attendances Beddays) 
 /NumberPatients =sum(NumberPatients).


add files file =!file+'/08-AE-costs-HRI_LCA_Temp1.sav'
 /file =!file+'/08-AE-costs-HRI_LCA_Temp2.sav'.
execute. 

compute gender = 0.
aggregate outfile=!file+'/08-AE-costs-HRI_LCA_Temp3.sav'
 /break= lca gender AgeBand UserType ServiceType
 /Total_Cost Episodes_Attendances Beddays=Sum(Total_Cost Episodes_Attendances Beddays)  
 /NumberPatients =sum(NumberPatients).



add files file =!file+'/08-AE-costs-HRI_LCA_Temp1.sav'
 /file =!file+'/08-AE-costs-HRI_LCA_Temp2.sav'
 /file =!file+'/08-AE-costs-HRI_LCA_Temp3.sav'.
execute. 

Save outfile=!file+'/08-AE-costs-HRI_LCA_Final13.sav'.

*******************************************************************************************************************************************************************.

***Number 7 - PIS: HRIs - 50%**************************************.
get file = !HRIfile255075.

Select if LcaFlag50=1.
Select if pis_dispensed_items  ge 1.
rename variables (pis_cost = Total_Cost) (pis_dispensed_items  = Episodes_Attendances).

Aggregate outfile=* 
               /break=Lca Gender AgeBand
               /Total_Cost Episodes_Attendances =Sum(Total_Cost Episodes_Attendances)      
               /NumberPatients = n.


String UserType (A11).
Compute UserType='LCA-HRI_50'.
      String ServiceType (A30).
      Compute ServiceType='PIS'.
Execute.

Save outfile=!file+'/08-PIS-costs-HRI_LCA50.sav'.

***Number 7 - PIS: HRIs - 65%**************************************.
get file = !HRIfile255075.

Select if LcaFlag65=1.
Select if pis_dispensed_items  ge 1.


rename variables (pis_cost = Total_Cost) (pis_dispensed_items  = Episodes_Attendances).

Aggregate outfile=* 
               /break=Lca Gender AgeBand
               /Total_Cost Episodes_Attendances =Sum(Total_Cost Episodes_Attendances)      
               /NumberPatients = n.


String UserType (A11).
Compute UserType='LCA-HRI_65'.
      String ServiceType (A30).
      Compute ServiceType='PIS'.
Execute.

Save outfile=!file+'/08-PIS-costs-HRI_LCA65.sav'.

***Number 7 - PIS: HRIs - 80%**************************************.
get file = !HRIfile255075.

Select if LcaFlag80=1.
Select if pis_dispensed_items  ge 1.


rename variables (pis_cost = Total_Cost) (pis_dispensed_items  = Episodes_Attendances).

Aggregate outfile=* 
               /break=Lca Gender AgeBand
               /Total_Cost Episodes_Attendances =Sum(Total_Cost Episodes_Attendances)      
               /NumberPatients = n.


String UserType (A11).
Compute UserType='LCA-HRI_80'.
      String ServiceType (A30).
      Compute ServiceType='PIS'.
Execute.

Save outfile=!file+'/08-PIS-costs-HRI_LCA80.sav'.

***Number 7 - PIS: HRIs - 95%**************************************.
get file = !HRIfile255075.

Select if LcaFlag95=1.
Select if pis_dispensed_items  ge 1.

rename variables (pis_cost = Total_Cost) (pis_dispensed_items  = Episodes_Attendances).

Aggregate outfile=* 
               /break=Lca Gender AgeBand
               /Total_Cost Episodes_Attendances =Sum(Total_Cost Episodes_Attendances)      
               /NumberPatients = n.


String UserType (A11).
Compute UserType='LCA-HRI_95'.
      String ServiceType (A30).
      Compute ServiceType='PIS'.
Execute.

Save outfile=!file+'/08-PIS-costs-HRI_LCA95.sav'.

***Number 7 - PIS : HRIs - 100% (ALL Patients**************************************.
get file = !HRIfile255075.

select if lca ne ' '.
Select if pis_dispensed_items  ge 1.


rename variables (pis_cost = Total_Cost) (pis_dispensed_items  = Episodes_Attendances).

Aggregate outfile=* 
               /break=Lca Gender AgeBand
               /Total_Cost Episodes_Attendances =Sum(Total_Cost Episodes_Attendances)      
               /NumberPatients = n.


String UserType (A11).
Compute UserType='LCA-HRI_ALL'.
      String ServiceType (A30).
      Compute ServiceType='PIS'.
Execute.

Save outfile=!file+'/08-PIS-costs-HRI_LCAALL.sav'.


** Bring all Acute file together and create totals.

add files file =!file+'/08-PIS-costs-HRI_LCAALL.sav'
 /file =!file+'/08-PIS-costs-HRI_LCA50.sav'
 /file =!file+'/08-PIS-costs-HRI_LCA65.sav'
 /file =!file+'/08-PIS-costs-HRI_LCA80.sav'
 /file =!file+'/08-PIS-costs-HRI_LCA95.sav'.
exe.
*Add in missing beddays variable.
Compute Beddays = 0.
Save outfile=!file+'/08-PIS-costs-HRI_LCA_Temp1.sav'.

compute ageband = 'All ages'.
aggregate outfile=!file+'/08-PIS-costs-HRI_LCA_Temp2.sav'
 /break= lca gender AgeBand UserType ServiceType
 /Total_Cost Episodes_Attendances Beddays=Sum(Total_Cost Episodes_Attendances Beddays)  
 /NumberPatients =sum(NumberPatients).


add files file =!file+'/08-PIS-costs-HRI_LCA_Temp1.sav'
 /file =!file+'/08-PIS-costs-HRI_LCA_Temp2.sav'.
execute. 

compute gender = 0.
aggregate outfile=!file+'/08-PIS-costs-HRI_LCA_Temp3.sav'
 /break= lca gender AgeBand UserType ServiceType
 /Total_Cost Episodes_Attendances Beddays=Sum(Total_Cost Episodes_Attendances Beddays)  
 /NumberPatients =sum(NumberPatients).



add files file =!file+'/08-PIS-costs-HRI_LCA_Temp1.sav'
 /file =!file+'/08-PIS-costs-HRI_LCA_Temp2.sav'
 /file =!file+'/08-PIS-costs-HRI_LCA_Temp3.sav'.
execute. 

Save outfile=!file+'/08-PIS-costs-HRI_LCA_Final13.sav'.


*******************************************************************************************************************************************************.
***Number 4 - ALL: HRIs - 50%**************************************.
get file = !HRIfile255075.

Select if LcaFlag50=1.
compute all_episodes = (acute_episodes + MH_episodes +gls_episodes + MAT_episodes + OP_newcons_attendances + AE_attendances + pis_dispensed_items).
compute all_beddays= (acute_inpatient_beddays + MH_inpatient_beddays +gls_inpatient_beddays + MAT_inpatient_beddays).


Aggregate outfile=* 
               /break=Lca Gender AgeBand
               /Total_Cost = Sum(health_net_cost) 
               /Episodes_Attendances=Sum(ALL_episodes)
               /Beddays=Sum(ALL_beddays)
               /NumberPatients = n.


String UserType (A11).
Compute UserType='LCA-HRI_50'.
String ServiceType (A30).
Compute ServiceType='ALL'.
Execute.

Save outfile=!file+'/08-ALL-costs-HRI_LCA50.sav'.

***Number 8 - TOTALS: HRIs - 65%**************************************.
get file = !HRIfile255075.
Select if LcaFlag65=1.


compute all_episodes = (acute_episodes + MH_episodes +gls_episodes + MAT_episodes + OP_newcons_attendances + AE_attendances + pis_dispensed_items).
compute all_beddays= (acute_inpatient_beddays + MH_inpatient_beddays +gls_inpatient_beddays + MAT_inpatient_beddays).
EXECUTE.

Aggregate outfile=* 
               /break=Lca Gender AgeBand
               /Total_Cost = Sum(health_net_cost) 
               /Episodes_Attendances=Sum(ALL_episodes)
               /Beddays=Sum(ALL_beddays)
               /NumberPatients = n.


String UserType (A11).
Compute UserType='LCA-HRI_65'.
String ServiceType (A30).
 Compute ServiceType='ALL'.
Execute.

Save outfile=!file+'/08-ALL-costs-HRI_LCA65.sav'.

***Number 4 - ALL: HRIs - 80%**************************************.
get file = !HRIfile255075.

Select if LcaFlag80=1.
compute all_episodes = (acute_episodes + MH_episodes +gls_episodes + MAT_episodes + OP_newcons_attendances + AE_attendances + pis_dispensed_items).
compute all_beddays= (acute_inpatient_beddays + MH_inpatient_beddays +gls_inpatient_beddays + MAT_inpatient_beddays).
EXECUTE.

Aggregate outfile=* 
               /break=Lca Gender AgeBand
               /Total_Cost = Sum(health_net_cost) 
               /Episodes_Attendances=Sum(ALL_episodes)
               /Beddays=Sum(ALL_beddays)
               /NumberPatients = n.

String UserType (A11).
Compute UserType='LCA-HRI_80'.
String ServiceType (A30).
Compute ServiceType='ALL'.
Execute.

Save outfile=!file+'/08-ALL-costs-HRI_LCA80.sav'.
***Number 4 - ALL: HRIs - 95%**************************************.
get file = !HRIfile255075.

Select if LcaFlag95=1.
compute all_episodes = (acute_episodes + MH_episodes +gls_episodes + MAT_episodes + OP_newcons_attendances + AE_attendances + pis_dispensed_items).
compute all_beddays= (acute_inpatient_beddays + MH_inpatient_beddays +gls_inpatient_beddays + MAT_inpatient_beddays).
EXECUTE.

Aggregate outfile=* 
               /break=Lca Gender AgeBand
               /Total_Cost = Sum(health_net_cost) 
               /Episodes_Attendances=Sum(ALL_episodes)
               /Beddays=Sum(ALL_beddays)
               /NumberPatients = n.


String UserType (A11).
Compute UserType='LCA-HRI_95'.
String ServiceType (A30).
Compute ServiceType='ALL'.
Execute.

Save outfile=!file+'/08-ALL-costs-HRI_LCA95.sav'.

***Number 4 - ALL : HRIs - 100% (ALL Patients**************************************.
get file = !HRIfile255075.

select if lca ne ' '.
compute all_episodes = (acute_episodes + MH_episodes +gls_episodes + MAT_episodes + OP_newcons_attendances + AE_attendances + pis_dispensed_items).
compute all_beddays= (acute_inpatient_beddays + MH_inpatient_beddays +gls_inpatient_beddays + MAT_inpatient_beddays).
EXECUTE.

Aggregate outfile=* 
               /break=Lca Gender AgeBand
               /Total_Cost = Sum(health_net_cost) 
               /Episodes_Attendances=Sum(ALL_episodes)
               /Beddays=Sum(ALL_beddays)
               /NumberPatients = n.



String UserType (A11).
Compute UserType='LCA-HRI_ALL'.
String ServiceType (A30).
Compute ServiceType='ALL'.
Execute.

Save outfile=!file+'/08-ALL-costs-HRI_LCAALL.sav'.


** Bring all Acute file together and create totals.

add files file =!file+'/08-ALL-costs-HRI_LCAALL.sav'
 /file =!file+'/08-ALL-costs-HRI_LCA50.sav'
 /file =!file+'/08-ALL-costs-HRI_LCA65.sav'
 /file =!file+'/08-ALL-costs-HRI_LCA80.sav'
 /file =!file+'/08-ALL-costs-HRI_LCA95.sav'.
exe.

Save outfile=!file+'/08-ALL-costs-HRI_LCA_Temp1.sav'.

compute ageband = 'All ages'.
aggregate outfile=!file+'/08-ALL-costs-HRI_LCA_Temp2.sav'
 /break= lca gender AgeBand UserType ServiceType
 /Total_Cost Episodes_Attendances Beddays=Sum(Total_Cost Episodes_Attendances Beddays)  
 /NumberPatients =sum(NumberPatients).


add files file =!file+'/08-ALL-costs-HRI_LCA_Temp1.sav'
 /file =!file+'/08-ALL-costs-HRI_LCA_Temp2.sav'.
execute. 

compute gender = 0.
aggregate outfile=!file+'/08-ALL-costs-HRI_LCA_Temp3.sav'
 /break= lca gender AgeBand UserType ServiceType
 /Total_Cost Episodes_Attendances Beddays=Sum(Total_Cost Episodes_Attendances Beddays)  
 /NumberPatients =sum(NumberPatients).



add files file =!file+'/08-ALL-costs-HRI_LCA_Temp1.sav'
 /file =!file+'/08-ALL-costs-HRI_LCA_Temp2.sav'
 /file =!file+'/08-ALL-costs-HRI_LCA_Temp3.sav'.
exe. 

Save outfile=!file+'/08-ALL-costs-HRI_LCA_Final13.sav'.
******************************************************************************************************************************************************************************.
** ADD files together and create required geographies.

add files file =!file+'/08-ALL-costs-HRI_LCA_Final13.sav'
 /file =!file+'/08-Acute-costs-HRI_LCA_Final13.sav'
 /file =!file+'/08-MH-costs-HRI_LCA_Final13.sav'
 /file =!file+'/08-GLS-costs-HRI_LCA_Final13.sav'
 /file =!file+'/08-MAT-costs-HRI_LCA_Final13.sav'
 /file =!file+'/08-OP-costs-HRI_LCA_Final13.sav'
 /file =!file+'/08-AE-costs-HRI_LCA_Final13.sav'
 /file =!file+'/08-PIS-costs-HRI_LCA_Final13.sav'.
EXE.

* Recreate Gender as a string.
RENAME VARIABLES (gender = oldgender).
String Gender (A10).
if oldgender = 0 Gender = "Both".
if oldgender = 1 Gender = "Male".
if oldgender = 2 Gender = "Female".


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
exe.
*frequency variables = LCAname.


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
exe.

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
EXE.

*frequencies variables =HBname.


***FC Oct. 2018 - Updated NHS Fife and Tayisde HB codes based on Source Linkage files updates.
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


Save outfile=!file+'/TAB-TDE-ALL-costs-HRI_LCA_Final' + !year + '.sav'
/keep Year LCAname LA_CODE HB_CODE HBname Gender AgeBand UserType ServiceType Total_Cost Episodes_Attendances Beddays NumberPatients.

get file=!file+'/TAB-TDE-ALL-costs-HRI_LCA_Final' + !year + '.sav'.
**********************************************************************************************************************************************.
*DELETE working FILES FOR HOUSEKEEPING*.
ERASE FILE= !file+'/08-Acute-costs-HRI_LCAALL.sav'.
ERASE FILE= !file+'/08-Acute-costs-HRI_LCA50.sav'.
ERASE FILE= !file+'/08-Acute-costs-HRI_LCA65.sav'.
ERASE FILE= !file+'/08-Acute-costs-HRI_LCA80.sav'.
ERASE FILE= !file+'/08-Acute-costs-HRI_LCA95.sav'.
ERASE FILE =!file+'/08-Acute-costs-HRI_LCA_Temp1.sav'.
ERASE FILE =!file+'/08-Acute-costs-HRI_LCA_Temp2.sav'.   
ERASE FILE =!file+'/08-Acute-costs-HRI_LCA_Temp3.sav'.

ERASE FILE= !file+'/08-MH-costs-HRI_LCAALL.sav'.
ERASE FILE= !file+'/08-MH-costs-HRI_LCA50.sav'.
ERASE FILE= !file+'/08-MH-costs-HRI_LCA65.sav'.
ERASE FILE= !file+'/08-MH-costs-HRI_LCA80.sav'.
ERASE FILE= !file+'/08-MH-costs-HRI_LCA95.sav'.
ERASE FILE =!file+'/08-MH-costs-HRI_LCA_Temp1.sav'.
ERASE FILE =!file+'/08-MH-costs-HRI_LCA_Temp2.sav'.   
ERASE FILE =!file+'/08-MH-costs-HRI_LCA_Temp3.sav'.

ERASE FILE= !file+'/08-MAT-costs-HRI_LCAALL.sav'.
ERASE FILE= !file+'/08-MAT-costs-HRI_LCA50.sav'.
ERASE FILE= !file+'/08-MAT-costs-HRI_LCA65.sav'.
ERASE FILE= !file+'/08-MAT-costs-HRI_LCA80.sav'.
ERASE FILE= !file+'/08-MAT-costs-HRI_LCA95.sav'.
ERASE FILE =!file+'/08-MAT-costs-HRI_LCA_Temp1.sav'.
ERASE FILE =!file+'/08-MAT-costs-HRI_LCA_Temp2.sav'.   
ERASE FILE =!file+'/08-MAT-costs-HRI_LCA_Temp3.sav'.

ERASE FILE= !file+'/08-OP-costs-HRI_LCAALL.sav'.
ERASE FILE= !file+'/08-OP-costs-HRI_LCA50.sav'.
ERASE FILE= !file+'/08-OP-costs-HRI_LCA65.sav'.
ERASE FILE= !file+'/08-OP-costs-HRI_LCA80.sav'.
ERASE FILE= !file+'/08-OP-costs-HRI_LCA95.sav'.
ERASE FILE =!file+'/08-OP-costs-HRI_LCA_Temp1.sav'.
ERASE FILE =!file+'/08-OP-costs-HRI_LCA_Temp2.sav'.   
ERASE FILE =!file+'/08-OP-costs-HRI_LCA_Temp3.sav'.

ERASE FILE= !file+'/08-AE-costs-HRI_LCAALL.sav'.
ERASE FILE= !file+'/08-AE-costs-HRI_LCA50.sav'.
ERASE FILE= !file+'/08-AE-costs-HRI_LCA65.sav'.
ERASE FILE= !file+'/08-AE-costs-HRI_LCA80.sav'.
ERASE FILE= !file+'/08-AE-costs-HRI_LCA95.sav'.
ERASE FILE =!file+'/08-AE-costs-HRI_LCA_Temp1.sav'.
ERASE FILE =!file+'/08-AE-costs-HRI_LCA_Temp2.sav'.   
ERASE FILE =!file+'/08-AE-costs-HRI_LCA_Temp3.sav'.

ERASE FILE= !file+'/08-GLS-costs-HRI_LCAALL.sav'.
ERASE FILE= !file+'/08-GLS-costs-HRI_LCA50.sav'.
ERASE FILE= !file+'/08-GLS-costs-HRI_LCA65.sav'.
ERASE FILE= !file+'/08-GLS-costs-HRI_LCA80.sav'.
ERASE FILE= !file+'/08-GLS-costs-HRI_LCA95.sav'.
ERASE FILE =!file+'/08-GLS-costs-HRI_LCA_Temp1.sav'.
ERASE FILE =!file+'/08-GLS-costs-HRI_LCA_Temp2.sav'.   
ERASE FILE =!file+'/08-GLS-costs-HRI_LCA_Temp3.sav'.

ERASE FILE= !file+'/08-PIS-costs-HRI_LCAALL.sav'.
ERASE FILE= !file+'/08-PIS-costs-HRI_LCA50.sav'.
ERASE FILE= !file+'/08-PIS-costs-HRI_LCA65.sav'.
ERASE FILE= !file+'/08-PIS-costs-HRI_LCA80.sav'.
ERASE FILE= !file+'/08-PIS-costs-HRI_LCA95.sav'.
ERASE FILE =!file+'/08-PIS-costs-HRI_LCA_Temp1.sav'.
ERASE FILE =!file+'/08-PIS-costs-HRI_LCA_Temp2.sav'.   
ERASE FILE =!file+'/08-PIS-costs-HRI_LCA_Temp3.sav'.

ERASE FILE= !file+'/08-ALL-costs-HRI_LCAALL.sav'.
ERASE FILE= !file+'/08-ALL-costs-HRI_LCA50.sav'.
ERASE FILE= !file+'/08-ALL-costs-HRI_LCA65.sav'.
ERASE FILE= !file+'/08-ALL-costs-HRI_LCA80.sav'.
ERASE FILE= !file+'/08-ALL-costs-HRI_LCA95.sav'.
ERASE FILE =!file+'/08-ALL-costs-HRI_LCA_Temp1.sav'.
ERASE FILE =!file+'/08-ALL-costs-HRI_LCA_Temp2.sav'.   
ERASE FILE =!file+'/08-ALL-costs-HRI_LCA_Temp3.sav'.

ERASE FILE=!file+'/08-ALL-costs-HRI_LCA_Final.sav'.
ERASE FILE=!file+'/08-Acute-costs-HRI_LCA_Final.sav'.
ERASE FILE=!file+'/08-MH-costs-HRI_LCA_Final.sav'.
ERASE FILE=!file+'/08-GLS-costs-HRI_LCA_Final.sav'.
ERASE FILE=!file+'/08-MAT-costs-HRI_LCA_Final.sav'.
ERASE FILE=!file+'/08-OP-costs-HRI_LCA_Final.sav'.
ERASE FILE=!file+'/08-AE-costs-HRI_LCA_Final.sav'.
ERASE FILE=!file+'/08-PIS-costs-HRI_LCA_Final.sav'.


EXECUTE.





