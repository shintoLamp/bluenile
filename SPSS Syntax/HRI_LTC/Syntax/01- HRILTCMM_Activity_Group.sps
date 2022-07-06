* Encoding: UTF-8.
* 04. LCA-HRI-Activity. Health activities and costs breakdown.
* Orginally created by Kara Sellar 18/10/13.
* Amended and updated by ML March 2013
* Amended and updated by Alison McClelland April 2015 for HRI-200,000-days. 
* Updated KR June 2015 for Tableau Workbook.
* Updated BM May 2020 for efficiency.

Define !year()
'202021'
!Enddefine.

Define !year2()
!QUOTE(!CONCAT(!UNQUOTE(!SUBSTR(!EVAL(!year), 2, 4)), '/', !UNQUOTE(!SUBSTR(!EVAL(!year), 6, 2))))
!Enddefine.

*Macro 2.
Define !popyear()
!QUOTE(!UNQUOTE(!SUBSTR(!EVAL(!year), 2, 4)))
!Enddefine.

Define !file()
!QUOTE(!CONCAT('/conf/sourcedev/TableauUpdates/HRI_LTC/Outputs/', !UNQUOTE(!SUBSTR(!EVAL(!year), 4, 4)), '/'))
!Enddefine.

Define !HRIfileGroups()
!QUOTE(!CONCAT(!UNQUOTE(!EVAL(!file)),'HRI-',!UNQUOTE(!SUBSTR(!EVAL(!year), 4, 4)),'_groups.sav'))
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
*More detailed sub-service types -
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


get file = '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.zsav'.

select if gender ne 0.
select if hri_lca ne 9.
select if NSU ne 1.

*FC July 2019.
******Remove HRI outlier only found for 2016/17 and 2017/18 financial years. 
******Check for next update.
* select if Anon_CHI ne 'MDMwNTM2MTEzOQ=='.

compute LcaFlag50 = 0.
compute LcaFlag65 = 0.
compute LcaFlag80 = 0.
compute LcaFlag95 = 0.

if HRI_lcap le 50.00 LcaFlag50 = 1.
if HRI_lcap le 65.00 LcaFlag65 = 1.
if HRI_lcap le 80.00 LcaFlag80 = 1.
if HRI_lcap le 95.00 LcaFlag95 = 1.

string AgeBand (a16).
If (Age lt 18) AgeBand = '<18'.
If (Age ge 18 and Age le 44) AgeBand = '18-44'.
If (Age ge 45 and Age le 64) AgeBand = '45-64'.
If (Age ge 65 and Age le 74) AgeBand = '65-74'.
If (Age ge 75 and Age le 84) AgeBand = '75-84'.
If (Age ge 85) AgeBand = '85+'.

compute No_LTC = 0.
compute Any_LTC = 0.
*if alzheimers eq 1 dementia eq 1.

*Identify individuals who do/do not have an LTC.
if (cvd	= 0 and copd = 0 and dementia	= 0 and diabetes = 0 and	chd	= 0 and hefailure = 0 and	refailure = 0 and	epilepsy = 0 and 	asthma = 0	
and atrialfib = 0 and	ms = 0 and cancer = 0 and arth = 0 and parkinsons = 0 and	liver = 0) No_LTC = 1.
if (cvd	= 1 or copd = 1 or dementia	= 1 or diabetes = 1 or	chd	= 1 or hefailure = 1 or refailure = 1 or	epilepsy = 1 or	asthma = 1 or atrialfib = 1 
or ms = 1 or cancer = 1 or arth = 1 or parkinsons = 1 or	liver = 1) Any_LTC = 1.

*Identify individuals with an LTC in a specified LTC Group.
compute Neurodegenerative = 0.
compute Cardio = 0.
compute Respiratory = 0.
compute OtherOrgan = 0.
if (dementia eq 1 or ms eq 1 or parkinsons eq 1) Neurodegenerative = 1.
if (atrialfib eq 1 or chd eq 1 or cvd eq 1 or hefailure eq 1) Cardio = 1.
if (asthma eq 1 or copd eq 1) Respiratory = 1.
if (liver eq 1 or refailure eq 1) OtherOrgan = 1.


Save outfile =!HRIfileGroups
/keep year gender AgeBand health_net_cost health_net_costincDNAs acute_episodes acute_daycase_episodes acute_inpatient_episodes acute_el_inpatient_episodes acute_non_el_inpatient_episodes
acute_cost acute_daycase_cost acute_inpatient_cost acute_el_inpatient_cost acute_non_el_inpatient_cost acute_inpatient_beddays acute_el_inpatient_beddays
acute_non_el_inpatient_beddays mat_episodes mat_daycase_episodes mat_inpatient_episodes mat_cost mat_daycase_cost mat_inpatient_cost mat_inpatient_beddays
MH_episodes MH_inpatient_episodes MH_el_inpatient_episodes MH_non_el_inpatient_episodes MH_cost
MH_inpatient_cost MH_el_inpatient_cost MH_non_el_inpatient_cost MH_inpatient_beddays MH_el_inpatient_beddays
MH_non_el_inpatient_beddays gls_episodes gls_inpatient_episodes gls_el_inpatient_episodes gls_non_el_inpatient_episodes gls_cost
gls_inpatient_cost gls_el_inpatient_cost gls_non_el_inpatient_cost gls_inpatient_beddays gls_el_inpatient_beddays gls_non_el_inpatient_beddays
op_newcons_attendances op_newcons_dnas op_cost_attend op_cost_dnas ae_attendances ae_cost pis_dispensed_items pis_cost deceased hbrescode lca
DataZone2011 cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib
cancer arth parkinsons liver ms HRI_lcaP LcaFlag50 LcaFlag65 LcaFlag80 LcaFlag95 No_LTC Any_LTC Neurodegenerative Cardio Respiratory OtherOrgan
/zcompressed.

** Create totals for each Service type and Threshold level.
** PART 1 - ACUTE.
** ACUTE: HRIs - 50%.

get file = !HRIfileGroups.

Select if lcaFlag50=1.
Select if acute_episodes ge 1.

Aggregate outfile=* 
               /break=Lca Gender AgeBand cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib cancer arth parkinsons liver ms No_LTC
                /NumberPatients = n
/cvdC copdC dementiaC diabetesC chdC hefailureC refailureC epilepsyC asthmaC atrialfibC cancerC arthC parkinsonsC liverC msC No_LTCC Neurodegenerative Cardio Respiratory OtherOrgan Any_LTC
            =sum(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib cancer arth parkinsons liver ms No_LTC Neurodegenerative Cardio Respiratory OtherOrgan Any_LTC)
/Total_Cost = sum(acute_cost)
/Total_Beddays = sum(acute_inpatient_beddays).

String UserType (A11).
Compute UserType='lca-HRI_50'.
String ServiceType (A30).
Compute ServiceType='Acute'.

Save outfile = !file + 'Acute-costs-HRI_lca50.sav' /zcompressed.

** ACUTE: HRIs - 65%.

get file = !HRIfileGroups.

Select if lcaFlag65=1.
Select if acute_episodes ge 1.

Aggregate outfile=* 
    /break=Lca Gender AgeBand cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib cancer arth parkinsons liver ms No_LTC
    /NumberPatients = n
    /cvdC copdC dementiaC diabetesC chdC hefailureC refailureC epilepsyC asthmaC atrialfibC cancerC arthC parkinsonsC liverC msC No_LTCC Neurodegenerative Cardio Respiratory OtherOrgan Any_LTC
    =sum(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib cancer arth parkinsons liver ms No_LTC Neurodegenerative Cardio Respiratory OtherOrgan Any_LTC)
    /Total_Cost = sum(acute_cost)
    /Total_Beddays = sum(acute_inpatient_beddays).

String UserType (A11).
Compute UserType='lca-HRI_65'.
String ServiceType (A30).
Compute ServiceType='Acute'.

Save outfile = !file + 'Acute-costs-HRI_lca65.sav' /zcompressed.

** ACUTE: HRIs - 80%.

get file =  !HRIfileGroups.

Select if lcaFlag80=1.
Select if acute_episodes ge 1.

Aggregate outfile=* 
               /break=Lca Gender AgeBand cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib cancer arth parkinsons liver ms No_LTC
               /NumberPatients = n
/cvdC copdC dementiaC diabetesC chdC hefailureC refailureC epilepsyC asthmaC atrialfibC cancerC arthC parkinsonsC liverC msC No_LTCC Neurodegenerative Cardio Respiratory OtherOrgan Any_LTC
            =sum(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib cancer arth parkinsons liver ms No_LTC Neurodegenerative Cardio Respiratory OtherOrgan Any_LTC)
/Total_Cost = sum(acute_cost)
/Total_Beddays = sum(acute_inpatient_beddays).

String UserType (A11).
Compute UserType='lca-HRI_80'.
      String ServiceType (A30).
      Compute ServiceType='Acute'.

Save outfile = !file + 'Acute-costs-HRI_lca80.sav' /zcompressed.

** ACUTE: HRIs - 95%.

get file =  !HRIfileGroups.

Select if lcaFlag95=1.
Select if acute_episodes ge 1.

Aggregate outfile=* 
               /break=Lca Gender AgeBand cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib cancer arth parkinsons liver ms No_LTC
               /NumberPatients = n
/cvdC copdC dementiaC diabetesC chdC hefailureC refailureC epilepsyC asthmaC atrialfibC cancerC arthC parkinsonsC liverC msC No_LTCC Neurodegenerative Cardio Respiratory OtherOrgan Any_LTC
            =sum(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib cancer arth parkinsons liver ms No_LTC Neurodegenerative Cardio Respiratory OtherOrgan Any_LTC)
/Total_Cost = sum(acute_cost)
/Total_Beddays = sum(acute_inpatient_beddays).

String UserType (A11).
Compute UserType='lca-HRI_95'.
      String ServiceType (A30).
      Compute ServiceType='Acute'.

Save outfile = !file + 'Acute-costs-HRI_lca95.sav' /zcompressed.

** ACUTE: HRIs - 100% (ALL Patients).

get file =  !HRIfileGroups.

Select if acute_episodes ge 1.

Aggregate outfile=* 
               /break=Lca Gender AgeBand cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib cancer arth parkinsons liver ms No_LTC
               /NumberPatients = n
/cvdC copdC dementiaC diabetesC chdC hefailureC refailureC epilepsyC asthmaC atrialfibC cancerC arthC parkinsonsC liverC msC No_LTCC Neurodegenerative Cardio Respiratory OtherOrgan Any_LTC
            =sum(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib cancer arth parkinsons liver ms No_LTC Neurodegenerative Cardio Respiratory OtherOrgan Any_LTC)
/Total_Cost = sum(acute_cost)
/Total_Beddays = sum(acute_inpatient_beddays).

String UserType (A11).
Compute UserType='lca-HRI_ALL'.
      String ServiceType (A30).
      Compute ServiceType='Acute'.

Save outfile = !file + 'Acute-costs-HRI_lcaALL.sav' /zcompressed.

** ACUTE - Adding totals.

add files file =!file+'Acute-costs-HRI_lcaALL.sav'
 /file =!file+'Acute-costs-HRI_lca50.sav'
 /file =!file+'Acute-costs-HRI_lca65.sav'
 /file =!file+'Acute-costs-HRI_lca80.sav'
 /file =!file+'Acute-costs-HRI_lca95.sav'.
execute.

Save outfile = !file + 'Acute-costs-HRI_lca_Temp1.sav' /zcompressed.

compute ageband = 'All ages'.
aggregate outfile=!file+'Acute-costs-HRI_lca_Temp2.sav' 
 /break= lca gender UserType AgeBand ServiceType cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib cancer arth parkinsons liver ms No_LTC
 /NumberPatients =sum(NumberPatients)
/cvdC copdC dementiaC diabetesC chdC hefailureC refailureC epilepsyC asthmaC atrialfibC cancerC arthC parkinsonsC liverC msC No_LTCC Neurodegenerative Cardio Respiratory OtherOrgan Any_LTC
            =sum(cvdC copdC dementiaC diabetesC chdC hefailureC refailureC epilepsyC asthmaC atrialfibC cancerC arthC parkinsonsC liverC msC No_LTCC Neurodegenerative Cardio Respiratory OtherOrgan Any_LTC)
/Total_cost= sum(Total_cost)
/Total_Beddays = sum(Total_Beddays).

add files file =!file+'Acute-costs-HRI_lca_Temp1.sav'
 /file =!file+'Acute-costs-HRI_lca_Temp2.sav'.
execute.

compute gender = 0.
aggregate outfile=!file+'Acute-costs-HRI_lca_Temp3.sav'
 /break= lca UserType gender AgeBand ServiceType cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib cancer arth parkinsons liver ms No_LTC
 /NumberPatients =sum(NumberPatients)
/cvdC copdC dementiaC diabetesC chdC hefailureC refailureC epilepsyC asthmaC atrialfibC cancerC arthC parkinsonsC liverC msC No_LTCC Neurodegenerative Cardio Respiratory OtherOrgan Any_LTC
            =sum(cvdC copdC dementiaC diabetesC chdC hefailureC refailureC epilepsyC asthmaC atrialfibC cancerC arthC parkinsonsC liverC msC No_LTCC Neurodegenerative Cardio Respiratory OtherOrgan Any_LTC)
/Total_Cost = sum(Total_Cost)
/Total_Beddays = sum(Total_Beddays).

add files file =!file+'Acute-costs-HRI_lca_Temp1.sav'
 /file =!file+'Acute-costs-HRI_lca_Temp2.sav'
 /file =!file+'Acute-costs-HRI_lca_Temp3.sav'.
execute.

Save outfile = !file + 'Acute-costs-HRI_lca_Final' + !year + '.sav' /zcompressed.

** ACUTE - Housekeeping for space-saving during run.

erase file = !file + 'Acute-costs-HRI_lca_Temp1.sav'.
erase file = !file + 'Acute-costs-HRI_lca_Temp2.sav'.
erase file = !file + 'Acute-costs-HRI_lca_Temp3.sav'.
erase file = !file + 'Acute-costs-HRI_lca50.sav'.
erase file = !file + 'Acute-costs-HRI_lca65.sav'.
erase file = !file + 'Acute-costs-HRI_lca80.sav'.
erase file = !file + 'Acute-costs-HRI_lca95.sav'.
erase file = !file + 'Acute-costs-HRI_lcaALL.sav'.

** PART 2 - MENTAL HEALTH.
** Mental Health: HRIs - 50%.
get file =  !HRIfileGroups.

Select if lcaFlag50=1.
Select if MH_episodes ge 1.

Aggregate outfile=* 
               /break=Lca Gender AgeBand cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib cancer arth parkinsons liver ms No_LTC
               /NumberPatients = n
/cvdC copdC dementiaC diabetesC chdC hefailureC refailureC epilepsyC asthmaC atrialfibC cancerC arthC parkinsonsC liverC msC No_LTCC Neurodegenerative Cardio Respiratory OtherOrgan Any_LTC
            =sum(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib cancer arth parkinsons liver ms No_LTC Neurodegenerative Cardio Respiratory OtherOrgan Any_LTC)
/Total_Cost = sum(MH_cost)
/Total_Beddays = sum(MH_inpatient_beddays).

String UserType (A11).
Compute UserType='lca-HRI_50'.
      String ServiceType (A30).
      Compute ServiceType='Mental Health'.

Save outfile = !file + 'MH-costs-HRI_lca50.sav' /zcompressed.

** MENTAL HEALTH: HRIs - 65%.

get file =  !HRIfileGroups.

Select if lcaFlag65=1.
Select if MH_episodes ge 1.

Aggregate outfile=* 
               /break=Lca Gender AgeBand cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib cancer arth parkinsons liver ms No_LTC
               /NumberPatients = n
/cvdC copdC dementiaC diabetesC chdC hefailureC refailureC epilepsyC asthmaC atrialfibC cancerC arthC parkinsonsC liverC msC No_LTCC Neurodegenerative Cardio Respiratory OtherOrgan Any_LTC
            =sum(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib cancer arth parkinsons liver ms No_LTC Neurodegenerative Cardio Respiratory OtherOrgan Any_LTC)
/Total_Cost = sum(MH_cost)
/Total_Beddays = sum(MH_inpatient_beddays).

String UserType (A11).
Compute UserType='lca-HRI_65'.
      String ServiceType (A30).
      Compute ServiceType='Mental Health'.

Save outfile = !file + 'MH-costs-HRI_lca65.sav' /zcompressed.

** MENTAL HEALTH: HRIs - 80%.

get file =  !HRIfileGroups.

Select if lcaFlag80=1.
Select if MH_episodes ge 1.

Aggregate outfile=* 
               /break=Lca Gender AgeBand cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib cancer arth parkinsons liver ms No_LTC
               /NumberPatients = n
/cvdC copdC dementiaC diabetesC chdC hefailureC refailureC epilepsyC asthmaC atrialfibC cancerC arthC parkinsonsC liverC msC No_LTCC Neurodegenerative Cardio Respiratory OtherOrgan Any_LTC
            =sum(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib cancer arth parkinsons liver ms No_LTC Neurodegenerative Cardio Respiratory OtherOrgan Any_LTC)
/Total_Cost = sum(MH_cost)
/Total_Beddays  = sum(MH_inpatient_beddays).

String UserType (A11).
Compute UserType='lca-HRI_80'.
      String ServiceType (A30).
      Compute ServiceType='Mental Health'.

Save outfile = !file + 'MH-costs-HRI_lca80.sav' /zcompressed.

** MENTAL HEALTH: HRIs - 95%.

get file =  !HRIfileGroups.

Select if lcaFlag95=1.
Select if MH_episodes ge 1.

Aggregate outfile=* 
               /break=Lca Gender AgeBand cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib cancer arth parkinsons liver ms No_LTC
               /NumberPatients = n
/cvdC copdC dementiaC diabetesC chdC hefailureC refailureC epilepsyC asthmaC atrialfibC cancerC arthC parkinsonsC liverC msC No_LTCC Neurodegenerative Cardio Respiratory OtherOrgan Any_LTC
            =sum(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib cancer arth parkinsons liver ms No_LTC Neurodegenerative Cardio Respiratory OtherOrgan Any_LTC)
/Total_Cost = sum(MH_cost)
/Total_Beddays = sum(MH_inpatient_beddays).

String UserType (A11).
Compute UserType='lca-HRI_95'.
      String ServiceType (A30).
      Compute ServiceType='Mental Health'.

Save outfile = !file + 'MH-costs-HRI_lca95.sav' /zcompressed.

** MENTAL HEALTH : HRIs - 100% (ALL Patients).

get file =  !HRIfileGroups.

Select if MH_episodes ge 1.

Aggregate outfile=* 
               /break=Lca Gender AgeBand cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib cancer arth parkinsons liver ms No_LTC
               /NumberPatients = n
/cvdC copdC dementiaC diabetesC chdC hefailureC refailureC epilepsyC asthmaC atrialfibC cancerC arthC parkinsonsC liverC msC No_LTCC Neurodegenerative Cardio Respiratory OtherOrgan Any_LTC
            =sum(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib cancer arth parkinsons liver ms No_LTC Neurodegenerative Cardio Respiratory OtherOrgan Any_LTC)
/Total_Cost = sum(MH_cost)
/Total_Beddays = sum(MH_inpatient_beddays).

String UserType (A11).
Compute UserType='lca-HRI_ALL'.
      String ServiceType (A30).
      Compute ServiceType='Mental Health'.

Save outfile = !file + 'MH-costs-HRI_lcaALL.sav' /zcompressed.

** Bring all Mental Health files together and create totals.

add files file =!file+'MH-costs-HRI_lcaALL.sav'
 /file =!file+'MH-costs-HRI_lca50.sav'
 /file =!file+'MH-costs-HRI_lca65.sav'
 /file =!file+'MH-costs-HRI_lca80.sav'
 /file =!file+'MH-costs-HRI_lca95.sav'.
execute.

Save outfile = !file + 'MH-costs-HRI_lca_Temp1.sav' /zcompressed.

compute ageband = 'All ages'.
aggregate outfile=!file+'MH-costs-HRI_lca_Temp2.sav'
 /break= lca gender UserType AgeBand ServiceType cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib cancer arth parkinsons liver ms No_LTC
 /NumberPatients =sum(NumberPatients)
/cvdC copdC dementiaC diabetesC chdC hefailureC refailureC epilepsyC asthmaC atrialfibC cancerC arthC parkinsonsC liverC msC No_LTCC Neurodegenerative Cardio Respiratory OtherOrgan Any_LTC
            =sum(cvdC copdC dementiaC diabetesC chdC hefailureC refailureC epilepsyC asthmaC atrialfibC cancerC arthC parkinsonsC liverC msC No_LTCC Neurodegenerative Cardio Respiratory OtherOrgan Any_LTC)
/Total_Cost = sum(Total_Cost)
/Total_Beddays = sum(Total_Beddays).

add files file =!file+'MH-costs-HRI_lca_Temp1.sav'
 /file =!file+'MH-costs-HRI_lca_Temp2.sav'.
execute.

compute gender = 0.
aggregate outfile=!file+'MH-costs-HRI_lca_Temp3.sav'
 /break= lca gender UserType AgeBand ServiceType cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib cancer arth parkinsons liver ms No_LTC
 /NumberPatients =sum(NumberPatients)
/cvdC copdC dementiaC diabetesC chdC hefailureC refailureC epilepsyC asthmaC atrialfibC cancerC arthC parkinsonsC liverC msC No_LTCC Neurodegenerative Cardio Respiratory OtherOrgan Any_LTC
            =sum(cvdC copdC dementiaC diabetesC chdC hefailureC refailureC epilepsyC asthmaC atrialfibC cancerC arthC parkinsonsC liverC msC No_LTCC Neurodegenerative Cardio Respiratory OtherOrgan Any_LTC)
/Total_Cost = sum(Total_Cost)
/Total_Beddays = sum(Total_Beddays).

add files file =!file+'MH-costs-HRI_lca_Temp1.sav'
 /file =!file+'MH-costs-HRI_lca_Temp2.sav'
 /file =!file+'MH-costs-HRI_lca_Temp3.sav'.
execute. 

Save outfile = !file + 'MH-costs-HRI_lca_Final' + !year + '.sav' /zcompressed.

* Housekeeping for space-saving during run.

erase file = !file+'MH-costs-HRI_lca_Temp1.sav'.
erase file = !file+'MH-costs-HRI_lca_Temp2.sav'.
erase file = !file+'MH-costs-HRI_lca_Temp3.sav'.
erase file =!file+'MH-costs-HRI_lca95.sav'.
erase file =!file+'MH-costs-HRI_lca80.sav'.
erase file =!file+'MH-costs-HRI_lca65.sav'.
erase file =!file+'MH-costs-HRI_lca50.sav'.
erase file =!file+'MH-costs-HRI_lcaALL.sav'.


** PART 3 - GLS.
** GLS: HRIs - 50%.
get file =  !HRIfileGroups.

Select if lcaFlag50=1.
Select if gls_episodes ge 1.

Aggregate outfile=* 
               /break=Lca Gender AgeBand cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib cancer arth parkinsons liver ms No_LTC
               /NumberPatients = n
/cvdC copdC dementiaC diabetesC chdC hefailureC refailureC epilepsyC asthmaC atrialfibC cancerC arthC parkinsonsC liverC msC No_LTCC Neurodegenerative Cardio Respiratory OtherOrgan Any_LTC
            =sum(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib cancer arth parkinsons liver ms No_LTC Neurodegenerative Cardio Respiratory OtherOrgan Any_LTC)
/Total_Cost = sum(gls_cost)
/Total_Beddays = sum(gls_inpatient_beddays).

String UserType (A11).
Compute UserType='lca-HRI_50'.
      String ServiceType (A30).
      Compute ServiceType='GLS'.

Save outfile = !file + 'GLS-costs-HRI_lca50.sav' /zcompressed.

** GLS: HRIs - 65%.

get file =  !HRIfileGroups.

Select if lcaFlag65=1.
Select if gls_episodes ge 1.

Aggregate outfile=* 
               /break=Lca Gender AgeBand cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib cancer arth parkinsons liver ms No_LTC
               /NumberPatients = n
/cvdC copdC dementiaC diabetesC chdC hefailureC refailureC epilepsyC asthmaC atrialfibC cancerC arthC parkinsonsC liverC msC No_LTCC Neurodegenerative Cardio Respiratory OtherOrgan Any_LTC
            =sum(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib cancer arth parkinsons liver ms No_LTC Neurodegenerative Cardio Respiratory OtherOrgan Any_LTC)
/Total_Cost = sum(gls_cost)
/Total_Beddays = sum(gls_inpatient_beddays).

String UserType (A11).
Compute UserType='lca-HRI_65'.
      String ServiceType (A30).
      Compute ServiceType='GLS'.

Save outfile = !file + 'GLS-costs-HRI_lca65.sav' /zcompressed.

** GLS: HRIs - 80%.

get file =  !HRIfileGroups.

Select if lcaFlag80=1.
Select if gls_episodes ge 1.

Aggregate outfile=* 
               /break=Lca Gender AgeBand cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib cancer arth parkinsons liver ms No_LTC
               /NumberPatients = n
/cvdC copdC dementiaC diabetesC chdC hefailureC refailureC epilepsyC asthmaC atrialfibC cancerC arthC parkinsonsC liverC msC No_LTCC Neurodegenerative Cardio Respiratory OtherOrgan Any_LTC
            =sum(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib cancer arth parkinsons liver ms No_LTC Neurodegenerative Cardio Respiratory OtherOrgan Any_LTC)
/Total_Cost = sum(gls_cost)
/Total_Beddays = sum(gls_inpatient_beddays).

String UserType (A11).
Compute UserType='lca-HRI_80'.
      String ServiceType (A30).
      Compute ServiceType='GLS'.

Save outfile = !file + 'GLS-costs-HRI_lca80.sav' /zcompressed.

** GLS: HRIs - 95%.

get file =  !HRIfileGroups.

Select if lcaFlag95=1.
Select if gls_episodes ge 1.

Aggregate outfile=* 
               /break=Lca Gender AgeBand cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib cancer arth parkinsons liver ms No_LTC
               /NumberPatients = n
/cvdC copdC dementiaC diabetesC chdC hefailureC refailureC epilepsyC asthmaC atrialfibC cancerC arthC parkinsonsC liverC msC No_LTCC Neurodegenerative Cardio Respiratory OtherOrgan Any_LTC
            =sum(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib cancer arth parkinsons liver ms No_LTC Neurodegenerative Cardio Respiratory OtherOrgan Any_LTC)
/Total_Cost = sum(gls_cost)
/Total_Beddays= sum(gls_inpatient_beddays).

String UserType (A11).
Compute UserType='lca-HRI_95'.
      String ServiceType (A30).
      Compute ServiceType='GLS'.

Save outfile = !file + 'GLS-costs-HRI_lca95.sav' /zcompressed.

** GLS : HRIs - 100% (ALL Patients).

get file =  !HRIfileGroups.

Select if gls_episodes ge 1.

Aggregate outfile=* 
               /break=Lca Gender AgeBand cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib cancer arth parkinsons liver ms No_LTC
               /NumberPatients = n
/cvdC copdC dementiaC diabetesC chdC hefailureC refailureC epilepsyC asthmaC atrialfibC cancerC arthC parkinsonsC liverC msC No_LTCC Neurodegenerative Cardio Respiratory OtherOrgan Any_LTC
            =sum(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib cancer arth parkinsons liver ms No_LTC Neurodegenerative Cardio Respiratory OtherOrgan Any_LTC)
/Total_Cost = sum(gls_cost)
/Total_Beddays = sum(gls_inpatient_beddays).

String UserType (A11).
Compute UserType='lca-HRI_ALL'.
      String ServiceType (A30).
      Compute ServiceType='GLS'.

Save outfile = !file + 'GLS-costs-HRI_lcaALL.sav' /zcompressed.

** Bring all GLS files together and create totals.

add files file =!file+'GLS-costs-HRI_lcaALL.sav'
 /file =!file+'GLS-costs-HRI_lca50.sav'
 /file =!file+'GLS-costs-HRI_lca65.sav'
 /file =!file+'GLS-costs-HRI_lca80.sav'
 /file =!file+'GLS-costs-HRI_lca95.sav'.
execute.

Save outfile=!file+'GLS-costs-HRI_lca_Temp1.sav' /zcompressed.

compute ageband = 'All ages'.
aggregate outfile=!file+'GLS-costs-HRI_lca_Temp2.sav'
 /break= lca gender UserType AgeBand ServiceType cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib cancer arth parkinsons liver ms No_LTC
 /NumberPatients =sum(NumberPatients)
/cvdC copdC dementiaC diabetesC chdC hefailureC refailureC epilepsyC asthmaC atrialfibC cancerC arthC parkinsonsC liverC msC No_LTCC Neurodegenerative Cardio Respiratory OtherOrgan Any_LTC
            =sum(cvdC copdC dementiaC diabetesC chdC hefailureC refailureC epilepsyC asthmaC atrialfibC cancerC arthC parkinsonsC liverC msC No_LTCC Neurodegenerative Cardio Respiratory OtherOrgan Any_LTC)
/Total_Cost = sum(Total_Cost)
/Total_Beddays = sum(Total_Beddays).

add files file =!file+'GLS-costs-HRI_lca_Temp1.sav'
 /file =!file+'GLS-costs-HRI_lca_Temp2.sav'.
execute.

compute gender = 0.
aggregate outfile=!file+'GLS-costs-HRI_lca_Temp3.sav'
 /break= lca gender UserType AgeBand ServiceType cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib cancer arth parkinsons liver ms No_LTC
 /NumberPatients =sum(NumberPatients)
/cvdC copdC dementiaC diabetesC chdC hefailureC refailureC epilepsyC asthmaC atrialfibC cancerC arthC parkinsonsC liverC msC No_LTCC Neurodegenerative Cardio Respiratory OtherOrgan Any_LTC
            =sum(cvdC copdC dementiaC diabetesC chdC hefailureC refailureC epilepsyC asthmaC atrialfibC cancerC arthC parkinsonsC liverC msC No_LTCC Neurodegenerative Cardio Respiratory OtherOrgan Any_LTC)
/Total_Cost = sum(Total_Cost)
/Total_Beddays = sum(Total_Beddays).

add files file =!file+'GLS-costs-HRI_lca_Temp1.sav'
 /file =!file+'GLS-costs-HRI_lca_Temp2.sav'
 /file =!file+'GLS-costs-HRI_lca_Temp3.sav'.
execute.

Save outfile = !file + 'GLS-costs-HRI_lca_Final'+ !year + '.sav' /zcompressed.

* Housekeeping for space-saving during run.

erase file = !file + 'GLS-costs-HRI_lca_Temp1.sav'.
erase file = !file + 'GLS-costs-HRI_lca_Temp2.sav'.
erase file = !file + 'GLS-costs-HRI_lca_Temp3.sav'.
erase file = !file + 'GLS-costs-HRI_lca95.sav'.
erase file = !file + 'GLS-costs-HRI_lca80.sav'.
erase file = !file + 'GLS-costs-HRI_lca65.sav'.
erase file = !file + 'GLS-costs-HRI_lca50.sav'.
erase file = !file + 'GLS-costs-HRI_lcaALL.sav'.

** PART 4 - OTHER.
** Other: HRIs - 50%.

get file =  !HRIfileGroups.

Select if lcaFlag50=1.
Select if MAT_episodes ge 1 or OP_newcons_attendances ge 1 or ae_attendances ge 1 or pis_dispensed_items  ge 1.
compute other_cost  = mat_cost + op_cost_attend + ae_cost + pis_cost.

Aggregate outfile=* 
               /break=Lca Gender AgeBand cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib cancer arth parkinsons liver ms No_LTC
               /NumberPatients = n
/cvdC copdC dementiaC diabetesC chdC hefailureC refailureC epilepsyC asthmaC atrialfibC cancerC arthC parkinsonsC liverC msC No_LTCC Neurodegenerative Cardio Respiratory OtherOrgan Any_LTC
            =sum(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib cancer arth parkinsons liver ms No_LTC Neurodegenerative Cardio Respiratory OtherOrgan Any_LTC)
/Total_Cost = sum(other_cost)
/Total_Beddays = sum(mat_inpatient_beddays).

String UserType (A11).
Compute UserType='lca-HRI_50'.
      String ServiceType (A30).
      Compute ServiceType='Other'.

Save outfile = !file + 'Other-costs-HRI_lca50.sav' /zcompressed.

** Other: HRIs - 65%.

get file =  !HRIfileGroups.

Select if lcaFlag65=1.
Select if MAT_episodes ge 1 or OP_newcons_attendances ge 1 or ae_attendances ge 1 or pis_dispensed_items  ge 1.
compute other_cost  = mat_cost + op_cost_attend + ae_cost + pis_cost.

Aggregate outfile=* 
               /break=Lca Gender AgeBand cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib cancer arth parkinsons liver ms No_LTC
               /NumberPatients = n
/cvdC copdC dementiaC diabetesC chdC hefailureC refailureC epilepsyC asthmaC atrialfibC cancerC arthC parkinsonsC liverC msC No_LTCC Neurodegenerative Cardio Respiratory OtherOrgan Any_LTC
            =sum(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib cancer arth parkinsons liver ms No_LTC Neurodegenerative Cardio Respiratory OtherOrgan Any_LTC)
/Total_Cost = sum(other_cost)
/Total_Beddays = sum(mat_inpatient_beddays).

String UserType (A11).
Compute UserType='lca-HRI_65'.
      String ServiceType (A30).
      Compute ServiceType='Other'.

Save outfile=!file+'Other-costs-HRI_lca65.sav' /zcompressed.

** Other: HRIs - 80%.

get file =  !HRIfileGroups.

Select if lcaFlag80=1.
Select if MAT_episodes ge 1 or OP_newcons_attendances ge 1 or ae_attendances ge 1 or pis_dispensed_items  ge 1.
compute other_cost  = mat_cost + op_cost_attend + ae_cost + pis_cost.

Aggregate outfile=* 
               /break=Lca Gender AgeBand cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib cancer arth parkinsons liver ms No_LTC
               /NumberPatients = n
/cvdC copdC dementiaC diabetesC chdC hefailureC refailureC epilepsyC asthmaC atrialfibC cancerC arthC parkinsonsC liverC msC No_LTCC Neurodegenerative Cardio Respiratory OtherOrgan Any_LTC
            =sum(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib cancer arth parkinsons liver ms No_LTC Neurodegenerative Cardio Respiratory OtherOrgan Any_LTC)
/Total_Cost = sum(other_cost)
/Total_Beddays = sum(mat_inpatient_beddays).

String UserType (A11).
Compute UserType='lca-HRI_80'.
      String ServiceType (A30).
      Compute ServiceType='Other'.

Save outfile=!file+'Other-costs-HRI_lca80.sav' /zcompressed.

** Other: HRIs - 95%.

get file =  !HRIfileGroups.

Select if lcaFlag95=1.
Select if MAT_episodes ge 1 or OP_newcons_attendances ge 1 or ae_attendances ge 1 or pis_dispensed_items  ge 1.
compute other_cost  = mat_cost + op_cost_attend + ae_cost + pis_cost.

Aggregate outfile=* 
               /break=Lca Gender AgeBand cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib cancer arth parkinsons liver ms No_LTC
               /NumberPatients = n
/cvdC copdC dementiaC diabetesC chdC hefailureC refailureC epilepsyC asthmaC atrialfibC cancerC arthC parkinsonsC liverC msC No_LTCC Neurodegenerative Cardio Respiratory OtherOrgan Any_LTC
            =sum(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib cancer arth parkinsons liver ms No_LTC Neurodegenerative Cardio Respiratory OtherOrgan Any_LTC)
/Total_Cost = sum(other_cost)
/Total_Beddays = sum(mat_inpatient_beddays).

String UserType (A11).
Compute UserType='lca-HRI_95'.
      String ServiceType (A30).
      Compute ServiceType='Other'.

Save outfile=!file+'Other-costs-HRI_lca95.sav' /zcompressed.

** Other : HRIs - 100% (ALL Patients).

get file =  !HRIfileGroups.

Select if MAT_episodes ge 1 or OP_newcons_attendances ge 1 or ae_attendances ge 1 or pis_dispensed_items  ge 1.
compute other_cost  = mat_cost + op_cost_attend + ae_cost + pis_cost.

Aggregate outfile=* 
               /break=Lca Gender AgeBand cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib cancer arth parkinsons liver ms No_LTC
               /NumberPatients = n
/cvdC copdC dementiaC diabetesC chdC hefailureC refailureC epilepsyC asthmaC atrialfibC cancerC arthC parkinsonsC liverC msC No_LTCC Neurodegenerative Cardio Respiratory OtherOrgan Any_LTC
            =sum(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib cancer arth parkinsons liver ms No_LTC Neurodegenerative Cardio Respiratory OtherOrgan Any_LTC)
/Total_Cost = sum(other_cost)
/Total_Beddays = sum(mat_inpatient_beddays).

String UserType (A11).
Compute UserType='lca-HRI_ALL'.
      String ServiceType (A30).
      Compute ServiceType='Other'.

Save outfile=!file+'Other-costs-HRI_lcaALL.sav'.

** Bring all Other HRI files together and create totals.

add files file =!file+'Other-costs-HRI_lcaALL.sav'
 /file =!file+'Other-costs-HRI_lca50.sav'
 /file =!file+'Other-costs-HRI_lca65.sav'
 /file =!file+'Other-costs-HRI_lca80.sav'
 /file =!file+'Other-costs-HRI_lca95.sav'.
execute.

Save outfile=!file+'Other-costs-HRI_lca_Temp1.sav' /zcompressed.

compute ageband = 'All ages'.
aggregate outfile=!file+'Other-costs-HRI_lca_Temp2.sav'
 /break= lca gender UserType AgeBand ServiceType cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib cancer arth parkinsons liver ms No_LTC
 /NumberPatients =sum(NumberPatients)
/cvdC copdC dementiaC diabetesC chdC hefailureC refailureC epilepsyC asthmaC atrialfibC cancerC arthC parkinsonsC liverC msC No_LTCC Neurodegenerative Cardio Respiratory OtherOrgan Any_LTC
            =sum(cvdC copdC dementiaC diabetesC chdC hefailureC refailureC epilepsyC asthmaC atrialfibC cancerC arthC parkinsonsC liverC msC No_LTCC Neurodegenerative Cardio Respiratory OtherOrgan Any_LTC)
/Total_Cost = sum(Total_Cost)
/Total_Beddays = sum(Total_Beddays).

add files file =!file+'Other-costs-HRI_lca_Temp1.sav'
 /file =!file+'Other-costs-HRI_lca_Temp2.sav'.
execute.

compute gender = 0.
aggregate outfile=!file+'Other-costs-HRI_lca_Temp3.sav'
 /break= lca gender UserType AgeBand ServiceType cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib cancer arth parkinsons liver ms No_LTC
 /NumberPatients =sum(NumberPatients)
/cvdC copdC dementiaC diabetesC chdC hefailureC refailureC epilepsyC asthmaC atrialfibC cancerC arthC parkinsonsC liverC msC No_LTCC Neurodegenerative Cardio Respiratory OtherOrgan Any_LTC
            =sum(cvdC copdC dementiaC diabetesC chdC hefailureC refailureC epilepsyC asthmaC atrialfibC cancerC arthC parkinsonsC liverC msC No_LTCC Neurodegenerative Cardio Respiratory OtherOrgan Any_LTC)
/Total_Cost = sum(Total_Cost)
/Total_Beddays = sum(Total_Beddays).

add files file =!file+'Other-costs-HRI_lca_Temp1.sav'
 /file =!file+'Other-costs-HRI_lca_Temp2.sav'
 /file =!file+'Other-costs-HRI_lca_Temp3.sav'.
execute.

Save outfile = !file + 'Other-costs-HRI_lca_Final' + !year + '.sav' /zcompressed.

erase file = !file + 'Other-costs-HRI_lca_Temp1.sav'.
erase file = !file + 'Other-costs-HRI_lca_Temp2.sav'.
erase file = !file + 'Other-costs-HRI_lca_Temp3.sav'.
erase file = !file + 'Other-costs-HRI_lca95.sav'. 
erase file = !file + 'Other-costs-HRI_lca80.sav'. 
erase file = !file + 'Other-costs-HRI_lca65.sav'. 
erase file = !file + 'Other-costs-HRI_lca50.sav'. 
erase file = !file + 'Other-costs-HRI_lcaALL.sav'. 

** PART 5 - TOTALS.
** Totals: HRIs - 50%.

get file =  !HRIfileGroups.
Select if lcaFlag50=1.

compute Total_Beddays = acute_inpatient_beddays + MH_inpatient_beddays + mat_inpatient_beddays + gls_inpatient_beddays.

Aggregate outfile=* 
               /break=Lca Gender AgeBand cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib cancer arth parkinsons liver ms No_LTC
               /NumberPatients = n
/cvdC copdC dementiaC diabetesC chdC hefailureC refailureC epilepsyC asthmaC atrialfibC cancerC arthC parkinsonsC liverC msC No_LTCC Neurodegenerative Cardio Respiratory OtherOrgan Any_LTC
            =sum(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib cancer arth parkinsons liver ms No_LTC Neurodegenerative Cardio Respiratory OtherOrgan Any_LTC)
/Total_Cost = sum(health_net_cost)
/Total_Beddays = sum(Total_Beddays).

String UserType (A11).
Compute UserType='lca-HRI_50'.
      String ServiceType (A30).
      Compute ServiceType='ALL'.

Save outfile = !file + 'ALL-costs-HRI_lca50.sav' /zcompressed.

** Totals: HRIs - 65%.

get file =  !HRIfileGroups.

Select if lcaFlag65=1.
compute Total_Beddays = acute_inpatient_beddays + MH_inpatient_beddays + mat_inpatient_beddays + gls_inpatient_beddays.

Aggregate outfile=* 
               /break=Lca Gender AgeBand cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib cancer arth parkinsons liver ms No_LTC
               /NumberPatients = n
/cvdC copdC dementiaC diabetesC chdC hefailureC refailureC epilepsyC asthmaC atrialfibC cancerC arthC parkinsonsC liverC msC No_LTCC Neurodegenerative Cardio Respiratory OtherOrgan Any_LTC
            =sum(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib cancer arth parkinsons liver ms No_LTC Neurodegenerative Cardio Respiratory OtherOrgan Any_LTC)
/Total_Cost = sum(health_net_cost)
/Total_Beddays = sum(Total_Beddays).

String UserType (A11).
Compute UserType='lca-HRI_65'.
      String ServiceType (A30).
      Compute ServiceType='ALL'.

Save outfile = !file + 'ALL-costs-HRI_lca65.sav' /zcompressed.

** Totals: HRIs - 80%.

get file =  !HRIfileGroups.
Select if lcaFlag80=1.
compute Total_Beddays = acute_inpatient_beddays + MH_inpatient_beddays + mat_inpatient_beddays + gls_inpatient_beddays.

Aggregate outfile=* 
               /break=Lca Gender AgeBand cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib cancer arth parkinsons liver ms No_LTC
               /NumberPatients = n
/cvdC copdC dementiaC diabetesC chdC hefailureC refailureC epilepsyC asthmaC atrialfibC cancerC arthC parkinsonsC liverC msC No_LTCC Neurodegenerative Cardio Respiratory OtherOrgan Any_LTC
            =sum(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib cancer arth parkinsons liver ms No_LTC Neurodegenerative Cardio Respiratory OtherOrgan Any_LTC)
/Total_Cost = sum(health_net_cost)
/Total_Beddays = sum(Total_Beddays).

String UserType (A11).
Compute UserType='lca-HRI_80'.
      String ServiceType (A30).
      Compute ServiceType='ALL'.

Save outfile = !file + 'ALL-costs-HRI_lca80.sav' /zcompressed.

** Totals: HRIs - 95%.

get file =  !HRIfileGroups.

Select if lcaFlag95=1.
compute Total_Beddays = acute_inpatient_beddays + MH_inpatient_beddays + mat_inpatient_beddays + gls_inpatient_beddays.

Aggregate outfile=* 
               /break=Lca Gender AgeBand cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib cancer arth parkinsons liver ms No_LTC
               /NumberPatients = n
/cvdC copdC dementiaC diabetesC chdC hefailureC refailureC epilepsyC asthmaC atrialfibC cancerC arthC parkinsonsC liverC msC No_LTCC Neurodegenerative Cardio Respiratory OtherOrgan Any_LTC
            =sum(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib cancer arth parkinsons liver ms No_LTC Neurodegenerative Cardio Respiratory OtherOrgan Any_LTC)
/Total_Cost = sum(health_net_cost)
/Total_Beddays = sum(Total_Beddays).

String UserType (A11).
Compute UserType='lca-HRI_95'.
      String ServiceType (A30).
      Compute ServiceType='ALL'.

Save outfile = !file + 'ALL-costs-HRI_lca95.sav' /zcompressed.

** Totals: HRIs - 100% (ALL Patients).

get file =  !HRIfileGroups.
compute Total_Beddays = acute_inpatient_beddays + MH_inpatient_beddays + mat_inpatient_beddays + gls_inpatient_beddays.

Aggregate outfile=* 
               /break=Lca Gender AgeBand cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib cancer arth parkinsons liver ms No_LTC
               /NumberPatients = n
/cvdC copdC dementiaC diabetesC chdC hefailureC refailureC epilepsyC asthmaC atrialfibC cancerC arthC parkinsonsC liverC msC No_LTCC Neurodegenerative Cardio Respiratory OtherOrgan Any_LTC
            =sum(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib cancer arth parkinsons liver ms No_LTC Neurodegenerative Cardio Respiratory OtherOrgan Any_LTC)
/Total_Cost = sum(health_net_cost)
/Total_Beddays = sum(Total_Beddays).

String UserType (A11).
Compute UserType='lca-HRI_ALL'.
      String ServiceType (A30).
      Compute ServiceType='ALL'.

Save outfile = !file + 'ALL-costs-HRI_lcaALL.sav'.

** Bring all Totals files together and create totals.

add files file =!file+'ALL-costs-HRI_lcaALL.sav'
 /file =!file+'ALL-costs-HRI_lca50.sav'
 /file =!file+'ALL-costs-HRI_lca65.sav'
 /file =!file+'ALL-costs-HRI_lca80.sav'
 /file =!file+'ALL-costs-HRI_lca95.sav'.
execute.

Save outfile=!file+'ALL-costs-HRI_lca_Temp1.sav' /zcompressed.

compute ageband = 'All ages'.
aggregate outfile=!file+'ALL-costs-HRI_lca_Temp2.sav'
 /break= lca gender UserType AgeBand ServiceType cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib cancer arth parkinsons liver ms No_LTC
 /NumberPatients =sum(NumberPatients)
/cvdC copdC dementiaC diabetesC chdC hefailureC refailureC epilepsyC asthmaC atrialfibC cancerC arthC parkinsonsC liverC msC No_LTCC Neurodegenerative Cardio Respiratory OtherOrgan Any_LTC
            =sum(cvdC copdC dementiaC diabetesC chdC hefailureC refailureC epilepsyC asthmaC atrialfibC cancerC arthC parkinsonsC liverC msC No_LTCC Neurodegenerative Cardio Respiratory OtherOrgan Any_LTC)
/Total_Cost = sum(Total_Cost)
/Total_Beddays = sum(Total_Beddays).

add files file =!file+'ALL-costs-HRI_lca_Temp1.sav'
 /file =!file+'ALL-costs-HRI_lca_Temp2.sav'.
execute.

compute gender = 0.
aggregate outfile=!file+'ALL-costs-HRI_lca_Temp3.sav'
 /break= lca gender UserType AgeBand ServiceType cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib cancer arth parkinsons liver ms No_LTC
 /NumberPatients =sum(NumberPatients)
/cvdC copdC dementiaC diabetesC chdC hefailureC refailureC epilepsyC asthmaC atrialfibC cancerC arthC parkinsonsC liverC msC No_LTCC Neurodegenerative Cardio Respiratory OtherOrgan Any_LTC
            =sum(cvdC copdC dementiaC diabetesC chdC hefailureC refailureC epilepsyC asthmaC atrialfibC cancerC arthC parkinsonsC liverC msC No_LTCC Neurodegenerative Cardio Respiratory OtherOrgan Any_LTC)
/Total_Cost = sum(Total_Cost)
/Total_Beddays= sum(Total_Beddays).

add files file =!file+'ALL-costs-HRI_lca_Temp1.sav'
 /file =!file+'ALL-costs-HRI_lca_Temp2.sav'
 /file =!file+'ALL-costs-HRI_lca_Temp3.sav'.
execute.

Save outfile=!file+'ALL-costs-HRI_lca_Final'+ !year + '.sav' /zcompressed.

* Housekeeping for space-saving during run.

erase file = !file + 'ALL-costs-HRI_lca_Temp1.sav'.
erase file = !file + 'ALL-costs-HRI_lca_Temp2.sav'.
erase file = !file + 'ALL-costs-HRI_lca_Temp3.sav'.
erase file = !file + 'ALL-costs-HRI_lca95.sav'.
erase file = !file + 'ALL-costs-HRI_lca80.sav'.
erase file = !file + 'ALL-costs-HRI_lca65.sav'.
erase file = !file + 'ALL-costs-HRI_lca50.sav'.
erase file = !file + 'ALL-costs-HRI_lcaALL.sav'.

** PART 6 - Finalising dataset.
** Add files together and create required geographies.

add files file =!file+'ALL-costs-HRI_lca_Final' + !year + '.sav'
 /file =!file+'Acute-costs-HRI_lca_Final' + !year + '.sav'
 /file =!file+'MH-costs-HRI_lca_Final' + !year + '.sav'
 /file =!file+'GLS-costs-HRI_lca_Final' + !year + '.sav'
 /file =!file+'Other-costs-HRI_lca_Final' + !year + '.sav'.
execute.

* Recreate Gender as a string.
RENAME VARIABLES (gender = oldgender).
String Gender (A10).
if oldgender = 0 Gender = "All".
if oldgender = 1 Gender = "Male".
if oldgender = 2 Gender = "Female".

* Create year.
String Year (a7).
compute Year = !year2.

frequencies lca.

*add LA Name.
string LCAname (a25).
compute LCAname = VALUELABEL(lca).
if LCAname = '' LCAname = 'Non LCA'.
if LCAname = 'Na h-Eileanan Siar' LCAname = 'Western Isles'.
execute.

save outfile= !file +'LTC_temp.zsav'
  /zcompressed.

get file = !file +'LTC_temp.zsav'.

*Add LA code.
String LA_CODE (a9).
if LCAname = 'Scottish Borders' LA_CODE = 'S12000026'.
if LCAname = 'Fife' LA_CODE = 'S12000015'.
if LCAname = 'Orkney Islands' LA_CODE = 'S12000023'.
if LCAname = 'Western Isles' LA_CODE = 'S12000013'.
if LCAname = 'Dumfries and Galloway' LA_CODE = 'S12000006'.
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
if LCAname = 'Argyll and Bute' LA_CODE = 'S12000035'.
if LCAname = 'North Lanarkshire' LA_CODE = 'S12000044'.
if LCAname = 'South Lanarkshire' LA_CODE = 'S12000029'.
if LCAname = 'Aberdeen City' LA_CODE = 'S12000033'.
if LCAname = 'Aberdeenshire' LA_CODE = 'S12000034'.
if LCAname = 'Moray' LA_CODE = 'S12000020'.
if LCAname = 'East Lothian' LA_CODE = 'S12000010'.
if LCAname = 'West Lothian' LA_CODE = 'S12000040'.
if LCAname = 'Midlothian' LA_CODE = 'S12000019'.
if LCAname = 'City of Edinburgh' LA_CODE = 'S12000036'.
if LCAname = 'Perth and Kinross' LA_CODE = 'S12000024'.
if LCAname = 'Dundee City' LA_CODE = 'S12000042'.
if LCAname = 'Angus' LA_CODE = 'S12000041'.
if LCAname = 'Clackmannanshire' LA_CODE = 'S12000005'.
if LCAname = 'Falkirk' LA_CODE = 'S12000014'.
if LCAname = 'Stirling' LA_CODE = 'S12000030'.

*FC Apr 2021. Add Clackmannashire & Stirling.
String Clacks(a30).
IF (LCAname = "Clackmannanshire") or (LCAname = "Stirling") Clacks="Clackmannanshire & Stirling".
VARSTOCASES
 /MAKE LCAname FROM LCAname Clacks.


* Add HB name.
String HBname (a40).
if any (LCAname, 'North Ayrshire', 'South Ayrshire', 'East Ayrshire') HBname eq 'Ayrshire & Arran Region'.
if LCAname eq 'Scottish Borders'   HBname eq  'Borders Region'.
if LCAname eq 'Dumfries and Galloway'    HBNAME eq  'Dumfries & Galloway Region'.
if LCAname eq 'Fife'    HBNAME =  'Fife Region'.

*FC April 2021. Added C&S to HBname'.
if any (LCAname, 'Stirling', 'Falkirk', 'Clackmannanshire', 'Clackmannanshire & Stirling')  HBNAME eq 'Forth Valley Region'.
if any (LCAname, 'Aberdeen City', 'Aberdeenshire', 'Moray') HBNAME eq  'Grampian Region'.
if any (LCAname, 'Glasgow City', 'East Dunbartonshire', 'Renfrewshire', 'East Renfrewshire', 'West Dunbartonshire', 'Inverclyde', 'Renfrewshire') HBname eq 'Greater Glasgow & Clyde Region'.
if any (LCAname, 'Argyll and Bute', 'Highland') HBname eq 'Highland Region'.
if any (LCAname, 'South Lanarkshire', 'North Lanarkshire') HBname eq 'Lanarkshire Region'.
if any (LCAname, 'City of Edinburgh', 'East Lothian', 'Midlothian', 'West Lothian') HBname eq 'Lothian Region'.
if LCAname eq 'Orkney Islands'  HBNAME eq  'Orkney Region'.
if LCAname eq 'Shetland Islands'  HBNAME eq  'Shetland Region'.
if any (LCAname, 'Angus', 'Perth and Kinross', 'Dundee City') HBname eq 'Tayside Region'.
if LCaname eq 'Western Isles'   HBNAME eq 'Western Isles Region'.

* Add HB code.

String HB_CODE (a9).
*FC July 2019.
*HB codes for NHS Tayside and NHS Fife were updated.

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

recode Total_Beddays(Sysmis = 0).

Save outfile=!file+'HRI_LTC_MM_LCA_Costs' + !year + '.sav'
/keep Year LCAname LA_CODE HB_CODE Gender AgeBand UserType ServiceType NumberPatients Total_Cost Total_Beddays
cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib cancer arth parkinsons liver ms No_LTC Any_LTC
cvdC copdC dementiaC diabetesC chdC hefailureC refailureC epilepsyC asthmaC atrialfibC cancerC arthC parkinsonsC liverC msC No_LTCC
Neurodegenerative Cardio Respiratory OtherOrgan
/zcompressed.

erase file = !file + 'ALL-costs-HRI_lca_Final'+ !year + '.sav'.
erase file = !file + 'Acute-costs-HRI_lca_Final'+ !year + '.sav'.
erase file = !file + 'GLS-costs-HRI_lca_Final'+ !year + '.sav'.
erase file = !file + 'MH-costs-HRI_lca_Final'+ !year + '.sav'.
erase file = !file + 'Other-costs-HRI_lca_Final'+ !year + '.sav'.
erase file = !HRIfileGroups.

get file = !file + 'HRI_LTC_MM_LCA_Costs' + !year + '.sav'.