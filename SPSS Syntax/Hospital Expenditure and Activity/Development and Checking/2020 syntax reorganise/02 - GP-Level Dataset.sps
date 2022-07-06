﻿* Encoding: UTF-8.
* Syntax for Hospital Expenditure and Activity Workbook.
* Re-written BM July 2020

*Create macros.

DEFINE !year()
'201920'
!ENDDEFINE.

DEFINE !file()
'/conf/sourcedev/TableauUpdates/Hospital Expenditure and Activity/Development and Checking/2020 syntax reorganise/'
!ENDDEFINE.

DEFINE !NRAC()
'/conf/sourcedev/TableauUpdates/Hospital Expenditure and Activity/Development and Checking/2020 syntax reorganise/NRACPractice.sav'
!ENDDEFINE.

***************************************************************************************************************************************.

get file = !file + 'GPMasterTest' + !year + '.sav'.

*Practices which have merged/closed. This will have to be checked every run against spreadsheet from Primary Care Team.
recode gpprac (10751, 10799 = 10746) (20165 = 20170) (21806 = 21811) (25116 = 25121) (25296 = 25883) 
                       (31112, 31121 = 30769) (31422, 31441 = 31461) (38101, 38121, 38140, 38224 = 38239) (40116, 40313 = 40737) 
                       (46377, 46108 = 46625) (61057, 61490, 61227, 61428 = 61630) (61409, 60069 = 60228) (62830, 62811 = 62830) 
                       (70037, 70643 = 71449) (80895, 80683 = 80895) (86054, 86162, 86110 = 86360) (87216, 87221 = 87240) 
                       (90007, 90026 = 90187) (90064, 90079, 90083 = 90191)        
(else = copy).

aggregate outfile = *
/break year recid gpprac cluster HBRESCODE HBTREATCODE HBRegionFormat HBResName LCA LCAname LA_CODE agegroup specname SpecialtyGrp treated_board IPDC cij_pattype locality
/Bed_Days = sum(yearstay)
/Total_Net_Cost = sum(Cost_Total_Net)
/Episodes = sum(Episodes).

rename variables gpprac = prac.
alter type prac(a5).
sort cases by prac.

* This lookup should not change, it lists practice codes and the LCA they are situated in.
match files file = *
/table = '/conf/irf/01-CPTeam/02-Functional-outputs/04-PLICS Functional Outputs/Lookups/Tableau/Prac_LCA_List.sav'
/by prac.
execute.

* This flag checks whether the LCA from the Source Linkage Files matches the LCA the practice is in.
compute originflag = 0.
if lcaname ne lcapractice originflag = 1.

*Excluded Practice Flag.
*As some South Lanarkshire practices are recorded under GGC HB, they are flagged to remove from any GGC HB analysis at practice level.
compute ExcludedFlag = 0.
compute LankFlag = 0.
if any (lcaname, 'South Lanarkshire', 'North Lanarkshire') and hbregionformat ne 'Lanarkshire Region' ExcludedFlag eq 1.
if any (lcaname, 'South Lanarkshire', 'North Lanarkshire') and char.substr(prac, 1, 1) eq '4' LankFlag eq 1.

* Create 'All' Specialties group. Done here to avoid undercounting based on flags below.
save outfile = !file + 'HEAGPTestTemp' + !year + '.sav' /zcompressed.
get file = !file + 'HEAGPTestTemp' + !year + '.sav'.

compute SpecialtyGrp = 'All'.
compute specname = 'All'.
AGGREGATE
 /OUTFILE= *
 /break year recid prac cluster HBRESCODE HBTREATCODE HBRegionFormat HBResName LCA LCAname LA_CODE agegroup specname SpecialtyGrp treated_board IPDC cij_pattype locality
/Bed_Days = sum(Bed_Days)
/Total_Net_Cost = sum(Total_Net_Cost)
/Episodes = sum(Episodes)
/FlagOrigin = max(originflag)
/FlagExcluded = max(excludedflag)
/FlagLanarkshire = max(Lankflag).

add files file = *
/file = !file + 'HEAGPTestTemp' + !year + '.sav'.
save outfile = !file + 'HEAGPTestTemp' + !year + '.sav' /zcompressed.
get file = !file + 'HEAGPTestTemp' + !year + '.sav'.

* Create a flag for the delegated specialties.
numeric FlagDelegatedSpec(f1.0).
compute FlagDelegatedSpec = 0.
if (any(specname, 'Accident & Emergency', 'Forensic Psychiatry', 'General Medicine', 'General Psychiatry', 'Geriatric Medicine',
'GP Other than Obstetrics', 'Learning Disability', 'Palliative Medicine', 'Psychiatry of Old Age', 'Rehabilitation Medicine', 'Respiratory Medicine') and (SpecialtyGrp ne 'All MHLD')) 
FlagDelegatedSpec = 1.
execute.

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

save outfile = !file + 'HEAGPTestTemp' + !year + '.sav' /zcompressed.

get file = !file + 'HEAGPTestTemp' + !year + '.sav'.
select if FlagDelegatedSpec = 1.
compute SpecialtyGrp = 'All Delegated'.
compute specname = 'All Delegated'.
compute FlagAllSpecialties = 0.
compute FlagGroupSpecs = 0.
aggregate outfile = !file + 'Temp1' + !year + '.sav'
/break year prac cluster lcapractice HBRESCODE HBTREATCODE HBRegionFormat HBResName LCA LCAname LA_CODE agegroup specname SpecialtyGrp treated_board IPDC cij_pattype locality
/Bed_Days = sum(bed_days)
/Total_Net_Cost = sum(Total_Net_Cost)
/Episodes = sum(Episodes)
/FlagOrigin FlagDelegatedSpec FlagAllSpecialties FlagGroupSpecs FlagExcluded FlagLanarkshire
= max(originflag FlagDelegatedSpec FlagAllSpecialties FlagGroupSpecs FlagExcluded FlagLanarkshire).

add files file = *
/file = !file + 'HEAGPTestTemp' + !year + '.sav'.

save outfile = !file + 'HEAGPTestTemp' + !year + '.sav' /zcompressed.
get file = !file + 'HEAGPTestTemp' + !year + '.sav'.

* Create an 'All Ages' group.
compute agegroup = 'All Ages'.
aggregate outfile = !file + 'Temp3' + !year + '.sav'
/break year prac cluster lcapractice HBRESCODE HBTREATCODE HBRegionFormat HBResName LCA LCAname LA_CODE agegroup specname SpecialtyGrp treated_board IPDC cij_pattype locality
/Bed_Days = sum(bed_days)
/Total_Net_Cost = sum(Total_Net_Cost)
/Episodes = sum(Episodes)
/FlagOrigin FlagDelegatedSpec FlagAllSpecialties FlagGroupSpecs FlagExcluded FlagLanarkshire
= max(originflag FlagDelegatedSpec FlagAllSpecialties FlagGroupSpecs FlagExcluded FlagLanarkshire).

add files file = *
/file = !file + 'HEAGPTestTemp' + !year + '.sav'.

save outfile = !file + 'HEAGPTestTemp' + !year + '.sav' /zcompressed.
get file = !file + 'HEAGPTestTemp' + !year + '.sav'.

************************************************************************************.
* We now need to match on the NRAC populations.

* Firstly, we want to define the care type in line with the NRAC lookup. 
* The majority of groups come under the 'acute' classification, apart from those in the recode.
string CareType(A10).
compute CareType = 'acute'.
recode SpecialtyGrp 
('Child & Adolescent Psychiatry - Grp',  'General Psychiatry - Grp', 'Learning Disability', 'Psychiatry of Old Age' = 'mhld')
('GP Obstetrics', 'Obstetrics Specialist - Grp' = 'maternity')
('All', 'All Delegated' = 'hchs')
into CareType.

string NRACmatch(a10).
compute NRACmatch = 'Prac Level'.

sort cases by lcaname year agegroup prac caretype nracmatch.

match files file = *
/table = !NRAC
/by lcaname year agegroup prac caretype nracmatch.
execute.

*************************************************************************************.
rename variables popn = population.
numeric BedDaysPer1000(f8.2) EpisodesPer1000(f8.2) ExpenditurePer1000(f8.2).
if population ne 0 BedDaysPer1000 = (bed_days/population)*1000.
if population ne 0 EpisodesPer1000 = (Episodes/population)*1000.
if population ne 0 ExpenditurePer1000 = (Total_Net_Cost/population)*1000.

aggregate outfile = *
/break year prac practicename cluster lcapractice HBRESCODE HBTREATCODE HBRegionFormat HBResName LCA LCAname LA_CODE agegroup specname SpecialtyGrp caretype treated_board IPDC cij_pattype locality
/Bed_Days = sum(Bed_Days)
/Total_Net_Cost = sum(Total_Net_Cost)
/Episodes = sum(Episodes)
/Population = first(population)
/BedDaysPer1000 = sum(BedDaysPer1000)
/EpisodesPer1000 = sum(EpisodesPer1000)
/ExpenditurePer1000 = sum(ExpenditurePer1000)
/FlagOrigin FlagDelegatedSpec FlagAllSpecialties FlagGroupSpecs FlagExcluded FlagLanarkshire
= max(originflag FlagDelegatedSpec FlagAllSpecialties FlagGroupSpecs FlagExcluded FlagLanarkshire).

* Change CA2018 values to CA2011 values for Tableau security filters.
if LA_code = 'S12000047' LA_code = 'S12000015'.
if LA_code = 'S12000048' LA_code = 'S12000024'.

save outfile = !file + 'GPtest' + !year + '.sav' /zcompressed.

erase file = !file + 'HEAGPTestTemp' + !year + '.sav'.




