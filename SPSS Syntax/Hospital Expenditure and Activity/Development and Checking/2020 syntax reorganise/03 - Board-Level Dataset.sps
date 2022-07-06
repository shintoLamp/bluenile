* Encoding: UTF-8.
* Syntax for Hospital Expenditure and Activity Workbook.
* Written BM April 2021

* The aim here is to create a supplementary dataset to the HEA workbook that gives Health Board Region totals,
* as Tableau has security issues when showing this with partnership-level access.

*Create macros.

DEFINE !year()
'201920'
!ENDDEFINE.

DEFINE !file()
'/conf/sourcedev/TableauUpdates/Hospital Expenditure and Activity/Development and Checking/2020 syntax reorganise/'
!ENDDEFINE.

DEFINE !NRAC()
'/conf/sourcedev/TableauUpdates/Hospital Expenditure and Activity/Development and Checking/2020 syntax reorganise/NRACBoard.sav'
!ENDDEFINE.

get file = !file + 'HBMaster' + !year + '.sav'.

* Aggregate the file from syntax 1 to Board level.
aggregate outfile = *
/break year recid mapcode HBRESCODE HBTREATCODE HBRegionFormat HBResName agegroup specname SpecialtyGrp treated_board IPDC cij_pattype
/Bed_Days = sum(yearstay)
/Total_Net_Cost = sum(Cost_Total_Net)
/Episodes = sum(Episodes).

* Some quick formatting for aesthetic purposes.
alter type IPDC (a9).
if IPDC eq 'A' IPDC eq 'All'.
if IPDC eq 'I' IPDC eq 'Inpatient'.
if IPDC eq 'D' IPDC eq 'Day Case'.

* Create an 'All' specialty group. This is done here to avoid under-counting after the flags are declared below.
save outfile = !file + 'BoardTemp' + !year + '.sav' /zcompressed.
get file = !file + 'BoardTemp' + !year + '.sav'.

compute SpecialtyGrp = 'All'.
compute specname = 'All'.
AGGREGATE
 /OUTFILE= *
 /break year recid mapcode HBRESCODE HBTREATCODE HBRegionFormat HBResName agegroup 
           specname SpecialtyGrp treated_board IPDC cij_pattype 
/Bed_Days = sum(Bed_Days)
/Total_Net_Cost = sum(Total_Net_Cost)
/Episodes = sum(Episodes).

add files file = *
/file = !file + 'BoardTemp' + !year + '.sav'.
save outfile = !file + 'BoardTemp' + !year + '.sav' /zcompressed.
get file = !file + 'BoardTemp' + !year + '.sav'.

* We want to create flags that select out certain groups of specialties. This is done here rather than in Tableau because
* of aggregates we are yet to perform.

* Create a flag for the delegated specialties.
numeric FlagDelegatedSpec(f1.0).
compute FlagDelegatedSpec = 0.
if (any(specname, 'Accident & Emergency', 'Forensic Psychiatry', 'General Medicine', 'General Psychiatry', 'Geriatric Medicine',
'GP Other than Obstetrics', 'Learning Disability', 'Palliative Medicine', 'Psychiatry of Old Age', 'Rehabilitation Medicine', 'Respiratory Medicine') and (SpecialtyGrp ne 'All MHLD')) 
FlagDelegatedSpec = 1.

*Flags used when individual specialty names are presented.  Avoids duplication by removing "All" spec group titles.
numeric FlagAllSpecialties(f1.0).
compute FlagAllSpecialties = 0.
if any (specname, 'All', 'Accident & Emergency', 'Acute Medicine', 'Adolescent Psychiatry', 'Allergy', 'Anaesthetics', 'Cardiac Surgery', 'Cardiology', 'Cardiothoracic Surgery',
'Child & Adolescent Psychiatry', 'Child Psychiatry', 'Clinical Oncology', 'Communicable Diseases', 'Community Dental Practice', 'Dermatology', 'Diabetes', 'Diagnostic Radiology',
'Ear, Nose & Throat (ENT)', 'Endocrinology', 'Endocrinology & Diabetes', 'Forensic Psychiatry', 'Gastroenterology', 'General Medicine', 'General Psychiatry', 'General Surgery',
'General Surgery (excl Vascular)', 'Geriatric Medicine', 'GP Other than Obstetrics', 'Gynaecology', 'Haematology', 'Homoeopathy', 'Immunology', 'Learning Disability', 'Medical Oncology',
'Medical Paediatrics', 'Nephrology', 'Neurology', 'Neurosurgery', 'Ophthalmology', 'Oral & Maxillofacial Surgery', 'Oral Medicine', 'Oral Surgery', 'Orthopaedics', 'Paediatric Dentistry',
'Pain Management', 'Palliative Medicine', 'Plastic Surgery', 'Psychiatry of Old Age', 'Rehabilitation Medicine', 'Respiratory Medicine', 'Restorative Dentistry', 'Rheumatology', 'Surgical Paediatrics',
'Thoracic Surgery', 'Urology', 'Vascular Surgery') FlagAllSpecialties = 1.

* Create a flag for specialties that are groups.
numeric FlagGroupSpecs(f1.0).
compute FlagGroupSpecs = 0.
if SpecialtyGrp ne specname FlagGroupSpecs = 1.

save outfile = !file + 'BoardTemp' + !year + '.sav' /zcompressed.

* Create an 'All Delegated' group.
select if FlagDelegatedSpec = 1.
compute SpecialtyGrp = 'All Delegated'.
compute specname = 'All Delegated'.
compute FlagAllSpecialties = 0.
compute FlagGroupSpecs = 0.
aggregate outfile = *
/break year recid mapcode HBRESCODE HBTREATCODE HBRegionFormat HBResName 
    agegroup specname SpecialtyGrp treated_board IPDC cij_pattype
/Bed_Days = sum(bed_days)
/Total_Net_Cost = sum(Total_Net_Cost)
/Episodes = sum(Episodes)
/FlagGroupSpecs = max(FlagGroupSpecs)
/FlagAllSpecialties = max(FlagAllSpecialties)
/FlagDelegatedSpec = max(FlagDelegatedSpec).

add files file = *
/file = !file + 'BoardTemp' + !year + '.sav'.
execute.

save outfile = !file + 'BoardTemp' + !year + '.sav' /zcompressed.
get file = !file + 'BoardTemp' + !year + '.sav'.

* Create an 'All Ages' group.
compute agegroup = 'All Ages'.
aggregate outfile = *
/break year recid mapcode HBRESCODE HBTREATCODE HBRegionFormat HBResName 
          agegroup specname SpecialtyGrp treated_board IPDC cij_pattype
/Bed_Days = sum(bed_days)
/Total_Net_Cost = sum(Total_Net_Cost)
/Episodes = sum(Episodes)
/FlagGroupSpecs = max(FlagGroupSpecs)
/FlagAllSpecialties = max(FlagAllSpecialties)
/FlagDelegatedSpec = max(FlagDelegatedSpec).

add files file = *
/file = !file + 'BoardTemp' + !year + '.sav'.

save outfile = !file + 'BoardTemp' + !year + '.sav' /zcompressed.
get file = !file + 'BoardTemp' + !year + '.sav'.

******************************************************************************************************************************.
*Matching on NRAC populations

*/ Firstly, we want to define the care type in line with the NRAC lookup
The majority of groups come under the 'acute' classification, apart from those in the recode
In the NRAC lookup, 'hchs' acts as our 'All' classification, but does not equal the sum of the other care types
This is why we have to assign 'hchs' to the 'All' and 'All delegated' specialty groups */.
string CareType(A10).
compute CareType = 'acute'.
recode SpecialtyGrp 
('Child & Adolescent Psychiatry - Grp',  'General Psychiatry - Grp', 'Learning Disability', 'Psychiatry of Old Age' = 'mhld')
('GP Obstetrics', 'Obstetrics Specialist - Grp' = 'maternity')
('All', 'All Delegated' = 'hchs')
into CareType.

* The NRAC lookup has practice and LCA populations, this variable ensures we use the correct ones.
string NRACmatch(a10).
compute NRACmatch = 'HB Level'.


aggregate outfile = *
/break year recid mapcode HBRESCODE HBTREATCODE HBRegionFormat HBResName 
           caretype NRACmatch agegroup specname SpecialtyGrp treated_board IPDC cij_pattype
/Bed_Days = sum(Bed_Days)
/Total_Net_Cost = sum(Total_Net_Cost)
/Episodes = sum(Episodes)
/FlagGroupSpecs = max(FlagGroupSpecs)
/FlagAllSpecialties = max(FlagAllSpecialties)
/FlagDelegatedSpec = max(FlagDelegatedSpec).

rename variables HBResName = HB.
sort cases by HB year agegroup caretype nracmatch.

*Add NRAC populations.
match files file = *
/table = !NRAC
/by hb year agegroup caretype nracmatch.
execute.

