* Encoding: UTF-8.
* Syntax for producing GP level data.
* Read in file created in 02 - HEA Costed Extract.sps.

*Create Parameters.

DEFINE !year()
'201819'
!ENDDEFINE.

DEFINE !file()
'/conf/sourcedev/TableauUpdates/Hospital Expenditure and Activity/Outputs/'
!ENDDEFINE.

 * get file = '/conf/sourcedev/TableauUpdates/Hospital Expenditure and Activity/Data Archive/HEA-Final-Tableau.sav'.

* This lookup should be checked every run and will likely need to be updated. 

define !ClusterLookup()
'/conf/sourcedev/TableauUpdates/Hospital Expenditure and Activity/Documentation/PracticeDetails.sav'
!enddefine.


***************************************************************************************************************************

get file = !file + 'HEA-MasterGPExtract' + !year + '.zsav'.

aggregate outfile = *
/break year recid mapcode gpPRAC HBRESCODE HBTREATCODE HBres LCA LCAname LA_CODE location agegroup specname SpecialtyGrp treated_board IPDC cij_pattype
/Bed_Days = sum(yearstay) 
/Total_Net_Cost = sum(Cost_Total_Net)
/Episodes = sum(EpCount).

save outfile = !file + 'HEA-MasterExtract-Main' + !year + '.zsav'
    /zcompressed.
get file = !file + 'HEA-MasterExtract-Main' + !year + '.zsav'. 

*Create data for All Ages.

compute agegroup ='All'.

AGGREGATE
 /OUTFILE=* 
  /break year recid mapcode HBRESCODE HBres LA_CODE LCA LCAname agegroup specname SpecialtyGrp treated_board IPDC cij_pattype gpprac
/Bed_Days = sum(Bed_Days)
/Total_Net_Cost = sum(Total_Net_Cost)
/Episodes = sum(Episodes).

add files file= *
/file= !file + 'HEA-MasterExtract-Main' + !year + '.zsav'.

save outfile = !file + 'HEA-MasterExtract-Main' + !year + '.zsav'
    /zcompressed.

*IPDC totals.

Get file = !file + 'HEA-MasterExtract-Main' + !year + '.zsav'.

Compute ipdc = 'A'.

AGGREGATE
 /OUTFILE=* 
 /break year recid mapcode HBRESCODE HBres LA_CODE LCA LCAname agegroup specname SpecialtyGrp  treated_board IPDC cij_pattype gpprac 
/Bed_Days = sum(Bed_Days)
/Total_Net_Cost = sum(Total_Net_Cost)
/Episodes = sum(Episodes).

add files file= *
/file=  !file + 'HEA-MasterExtract-Main' + !year + '.zsav'.

SAVE OUTFILE = !file + 'HEA-MasterExtract-Main' + !year + '.zsav'
    /zcompressed.

*All Spec Group.
get file = !file + 'HEA-MasterExtract-Main' + !year + '.zsav'.
compute SpecialtyGrp = 'All'.
compute specname = 'All'.

AGGREGATE
 /OUTFILE=* 
 /break year recid mapcode HBRESCODE HBres LA_CODE LCA LCAname agegroup specname SpecialtyGrp  treated_board IPDC cij_pattype gpprac
/Bed_Days = sum(Bed_Days)
/Total_Net_Cost = sum(Total_Net_Cost)
/Episodes = sum(Episodes).

add files file = *
/file = !file + 'HEA-MasterExtract-Main' + !year + '.zsav'.

save outfile  =  !file + 'HEA-MasterExtract-Main' + !year + '.zsav'
    /zcompressed.

get file =  !file + 'HEA-MasterExtract-Main' + !year + '.zsav'.

*All Patient Types.
compute cij_pattype = 'All'.

AGGREGATE
 /OUTFILE=* 
/break year recid mapcode HBRESCODE HBres LA_CODE LCA LCAname agegroup specname SpecialtyGrp treated_board IPDC cij_pattype gpprac
/Bed_Days = sum(Bed_Days)
/Total_Net_Cost = sum(Total_Net_Cost)
/Episodes = sum(Episodes).

add files file = *
/file =   !file + 'HEA-MasterExtract-Main' + !year + '.zsav'.

save outfile  = !file + 'HEA-MasterExtract-Main' + !year + '.zsav'
    /zcompressed.

*All treated Boards .
get file = !file + 'HEA-MasterExtract-Main' + !year + '.zsav'.

compute treated_board = 'All'.

AGGREGATE
 /OUTFILE=* 
/break year recid mapcode HBRESCODE HBres LA_CODE LCA LCAname agegroup specname SpecialtyGrp treated_board IPDC cij_pattype gpprac
/Bed_Days = sum(Bed_Days)
/Total_Net_Cost = sum(Total_Net_Cost)
/Episodes = sum(Episodes).

add files file = *
/file =  !file + 'HEA-MasterExtract-Main' + !year + '.zsav'.

save outfile =  !file + 'HEA-MasterExtract-Main' + !year + '.zsav'
    /zcompressed.

get file =  !file + 'HEA-MasterExtract-Main' + !year + '.zsav'.

*Due to population aggregation issues in Tableau, Specialty groups need an 'All Specialty' for filtering.
if SpecialtyGrp eq 'Child & Adolescent Psychiatry - Grp' specname eq 'All Child & Adolescent Psychiatry'.
if SpecialtyGrp eq 'Dental - Grp' specname eq 'All Dental'.
if SpecialtyGrp eq 'General Medicine - Grp' specname eq 'All General Medicine'.
if SpecialtyGrp eq 'General Psychiatry - Grp' specname eq 'All General Pyschiatry'.
if SpecialtyGrp eq 'Other medical specialties - Grp' specname eq 'All Other Medical Specialties'.
if SpecialtyGrp eq 'Oral Surgery & Medicine - Grp' specname eq 'All Oral Surgery'.
if SpecialtyGrp eq 'Surgical Specialties & Anaesthetics - Grp' specname eq 'All Surgical Specialties'.
select if any (specname, 'All Child & Adolescent Psychiatry', 'All Dental', 'All General Medicine', 'All General Pyschiatry', 'All Other Medical Specialties', 
                                     'All Oral Surgery', 'All Surgical Specialties').

AGGREGATE
 /OUTFILE=* 
/break year recid mapcode HBRESCODE HBres LA_CODE LCA LCAname agegroup specname SpecialtyGrp treated_board IPDC cij_pattype gpprac
/Bed_Days = sum(Bed_Days)
/Total_Net_Cost = sum(Total_Net_Cost)
/Episodes = sum(Episodes).

add files file = *
/file =  !file + 'HEA-MasterExtract-Main' + !year + '.zsav'.  

save outfile =  !file + 'HEA-MasterExtract-Main' + !year + '.zsav'
    /zcompressed.

*********************************************************************** Number of cases fine to this point - 738 missing, ~3m total.

*Get All Delegated Specialty for selection.
get file =  !file + 'HEA-MasterExtract-Main' + !year + '.zsav'.

select if any (specname, 'Accident & Emergency', 'Acute Medicine', 'Adolescent Psychiatry', 'Allergy', 'Anaesthetics', 'Cardiac Surgery', 'Cardiology', 'Cardiothoracic Surgery',
'Child & Adolescent Psychiatry', 'Child Psychiatry', 'Clinical Oncology', 'Communicable Diseases', 'Community Dental Practice', 'Dermatology', 'Diabetes', 'Diagnostic Radiology',
'Ear, Nose & Throat (ENT)', 'Endocrinology', 'Endocrinology & Diabetes', 'Forensic Psychiatry', 'Gastroenterology', 'General Medicine', 'General Psychiatry', 'General Surgery',
'General Surgery (excl Vascular)', 'Geriatric Medicine', 'GP Other than Obstetrics', 'Gynaecology', 'Haematology', 'Homoeopathy', 'Immunology', 'Learning Disability', 'Medical Oncology',
'Medical Paediatrics', 'Nephrology', 'Neurology', 'Neurosurgery', 'Ophthalmology', 'Oral & Maxillofacial Surgery', 'Oral Medicine', 'Oral Surgery', 'Orthopaedics', 'Paediatric Dentistry',
'Pain Management', 'Palliative Medicine', 'Plastic Surgery', 'Psychiatry of Old Age', 'Rehabilitation Medicine', 'Respiratory Medicine', 'Restorative Dentistry', 'Rheumatology', 'Surgical Paediatrics',
'Thoracic Surgery', 'Urology', 'Vascular Surgery').
execute.
select if any (specname, 'Accident & Emergency', 'Forensic Psychiatry', 'General Medicine', 'General Psychiatry', 'Geriatric Medicine',
'GP Other than Obstetrics', 'Learning Disability', 'Palliative Medicine', 'Psychiatry of Old Age', 'Rehabilitation Medicine', 'Respiratory Medicine').
execute.
select if SpecialtyGrp ne 'All MHLD'.
execute.

compute specname = 'All Delegated'.
compute SpecialtyGrp = 'All Delegated'. 

AGGREGATE
 /OUTFILE=* 
/break year recid mapcode HBRESCODE HBres LA_CODE LCA LCAname agegroup specname SpecialtyGrp treated_board IPDC cij_pattype gpprac
/Bed_Days = sum(Bed_Days)
/Total_Net_Cost = sum(Total_Net_Cost)
/Episodes = sum(Episodes).

add files file = *
/file = !file + 'HEA-MasterExtract-Main' + !year + '.zsav'.

save outfile =  !file + 'HEA-MasterExtract-Main' + !year + '.zsav'
    /zcompressed.

get file = !file + 'HEA-MasterExtract-Main' + !year + '.zsav'.

****************************************** Still at 3m cases, 850 missing.

*Rename IPDC for aesthetics.

alter type IPDC (a9).
if IPDC eq 'A' IPDC eq 'All'.
if IPDC eq 'I' IPDC eq 'Inpatient'.
if IPDC eq 'D' IPDC eq 'Day Case'.

string LCA_HB_SCOT (A35).
compute LCA_HB_SCOT = LCAname.

*Aggregate out recid?.

AGGREGATE
 /OUTFILE=* 
/break year HBRESCODE HBres LCA_HB_SCOT LA_CODE LCA LCAname agegroup specname SpecialtyGrp treated_board IPDC cij_pattype gpprac
/Bed_Days = sum(Bed_Days)
/Total_Net_Cost = sum(Total_Net_Cost)
/Episodes = sum(Episodes).
execute.

save outfile =  !file + 'HEA-MasterExtract-Main' + !year + '.zsav'
    /zcompressed.

***************

get file =  !file + 'HEA-MasterExtract-Main' + !year + '.zsav'.

**************************** Problem area. Bateman 25/03/19 ****************************
* This section now works fine, but I've had to alter type on a lot of variables. It may be worth coming back to this as it could cause a mismatch in Tableau's expected format.

sort cases by gpprac.
rename variables gpprac = prac.
alter type prac(a6).
alter type lcaname(a25).

frequencies variables = lcaname.

compute prac = LTRIM(prac).
alter type prac(a5).

*Match LA list to the formatted file.
match files file = *
/table = '/conf/irf/01-CPTeam/02-Functional-outputs/04-PLICS Functional Outputs/Lookups/Tableau/Prac_LCA_List.sav'
/by prac.
execute.

alter type lca (a25).
compute lca=valuelabel(lca).
execute.

*Ensure formatting is correct.
 * if lca eq 'Shetland Islands' lca eq 'Shetland'.
 * if lca eq 'Orkney Islands' lca eq 'Orkney'.
if lca eq 'Borders' lca eq 'Scottish Borders'.
if lca eq 'Dumfries and Galloway' lca eq 'Dumfries & Galloway'.
if lca eq 'Argyll and Bute' lca eq 'Argyll & Bute'.
if lca eq 'Perth and Kinross' lca eq 'Perth & Kinross'.
if lca eq 'Edinburgh' lca eq 'City of Edinburgh'.
if lca eq 'Dundee' lca eq 'Dundee City'.
if lca eq 'Na h-Eileanan Siar' lca eq 'Western Isles'.
if lca eq '' lca eq 'Non LCA'.

frequencies variables = lca.

*Flag practices under wrong LA.
compute PracFlag = 0.
if LCAname ne LCA PracFlag eq 1.

*Flag for practices under wrong HB.
compute flag = 0.
if hbres= 'NHS Ayrshire & Arran' and (LCAname ne 'East Ayrshire'	and LCAname ne 'North Ayrshire'	and LCAname ne	'South Ayrshire')	flag =1.	 	 	 	 
if hbres ='NHS Borders' and LCAname ne 'Borders'	flag =1.
if hbres ='NHS Fife' and (LCAname ne 'Fife')	flag =1.	 	 	 	 
if hbres ='NHS Greater Glasgow & Clyde' and (LCAname ne 'East Dunbartonshire'	and LCAname ne 'East Renfrewshire' and LCAname ne	'Glasgow City' and LCAname ne 'Inverclyde' 
and LCAname ne	'Renfrewshire'	and LCAname ne 'West Dunbartonshire' and LCAname ne 'North Lanarkshire' and LCAname ne 'South Lanarkshire' )	flag =1.		 
if hbres ='NHS Highland' and (LCAname ne 'Argyll and Bute' and LCAname ne	'Highland')	flag =1.	 	 	 	 	 
if hbres ='NHS Lanarkshire' and (LCAname ne 'North Lanarkshire' and LCAname ne	'South Lanarkshire')	flag =1.	 	 	 	 	 
if hbres ='NHS Grampian' and (LCAname ne 'Aberdeen City' and LCAname ne	'Aberdeenshire' and LCAname ne	'Moray')	flag =1.	 		 	 	 
if hbres ='NHS Orkney' and LCAname ne 'Orkney Islands' flag =1. 	 	 	 	 	 	 
if hbres ='NHS Shetland' and LCAname ne 'Shetland Islands' flag =1. 	 	 	 	 	 	 
if hbres ='NHS Lothian' and (LCAname ne 'City of Edinburgh' and LCAname ne 'East Lothian' and LCAname ne 'Midlothian' and LCAname ne	'West Lothian')	flag =1.	 		 
if hbres ='NHS Tayside' and (LCAname ne 'Angus' and LCAname ne	'Dundee City' and LCAname ne 'Perth and Kinross')	flag =1. 	 
if hbres ='NHS Forth Valley' and (LCAname ne 'Falkirk'	and LCAname ne 'Clackmannanshire' and LCAname ne 'Stirling')	flag =1.	 
if hbres ='NHS Western Isles' and LCAname ne 'Western Isles'	flag =1. 	 	 	 	 	 	 
if hbres ='NHS Dumfries & Galloway' and LCAname ne 'Dumfries and Galloway' flag =1. 	 	 	 	 	 

*Flag for Delegated Specialties Selections.
compute AllSpecGrp = 0.

if any (specname, 'All', 'All Child & Adolescent Psychiatry', 'All Dental', 'All General Medicine', 'All General Pyschiatry', 'All Oral Surgery', 'All Other Medical Specialties',
'All Surgical Specialties', 'Cardiology', 'Clinical Oncology', 'Communicable Diseases', 'Dermatology', 'Gastroenterology', 'Geriatric Medicine', 'GP Other than Obstetrics', 'Haematology',
'Learning Disability', 'Medical Oncology', 'Medical Paediatrics', 'Nephrology', 'Neurology', 'Palliative Medicine', 'Psychiatry of Old Age', 'Rehabilitation Medicine', 'Respiratory Medicine',
'Restorative Dentistry', 'Rheumatology') AllSpecGrp = 1.

compute DelegatedSpecGrp = 0.

if any (specname, 'All Delegated', 'Accident & Emergency', 'Forensic Psychiatry', 'General Medicine', 'General Psychiatry', 'Geriatric Medicine',
'GP Other than Obstetrics', 'Learning Disability', 'Palliative Medicine', 'Psychiatry of Old Age', 'Rehabilitation Medicine', 'Respiratory Medicine')
DelegatedSpecGrp = 1.

compute AllSpecname = 0.

if any (specname, 'Accident & Emergency', 'Acute Medicine', 'Adolescent Psychiatry', 'All', 'Allergy', 'Anaesthetics', 'Cardiac Surgery', 'Cardiology', 'Cardiothoracic Surgery',
'Child & Adolescent Psychiatry', 'Child Psychiatry', 'Clinical Oncology', 'Communicable Diseases', 'Community Dental Practice', 'Dermatology', 'Diabetes', 'Diagnostic Radiology',
'Ear, Nose & Throat (ENT)', 'Endocrinology', 'Endocrinology & Diabetes', 'Forensic Psychiatry', 'Gastroenterology', 'General Medicine', 'General Psychiatry', 'General Surgery',
'General Surgery (excl Vascular)', 'Geriatric Medicine', 'GP Other than Obstetrics', 'Gynaecology', 'Haematology', 'Homoeopathy', 'Immunology', 'Learning Disability', 'Medical Oncology',
'Medical Paediatrics', 'Nephrology', 'Neurology', 'Neurosurgery', 'Ophthalmology', 'Oral & Maxillofacial Surgery', 'Oral Medicine', 'Oral Surgery', 'Orthopaedics', 'Paediatric Dentistry',
'Pain Management', 'Palliative Medicine', 'Plastic Surgery', 'Psychiatry of Old Age', 'Rehabilitation Medicine', 'Respiratory Medicine', 'Restorative Dentistry', 'Rheumatology', 'Surgical Paediatrics',
'Thoracic Surgery', 'Urology', 'Vascular Surgery') AllSpecname = 1.

*Excluded Practice Flag.
*As some South Lanarkshire practices are recorded under GGC HB, they are flagged to remove from any GGC HB analysis at practice level.
compute ExcludedFlag = 0.
compute LankFlag = 0.
if any (lcaname, 'South Lanarkshire', 'North Lanarkshire') and hbres ne 'Lanarkshire Region' ExcludedFlag eq 1.
if any (lcaname, 'South Lanarkshire', 'North Lanarkshire') and char.substr(prac, 1, 1) eq '4' LankFlag eq 1.

select if LankFlag ne 1.

*New 2C and 17J practices.
if any (prac, '13369', '15006', '15909', '15913', '15928', '15947', '15951', '15985', '16511', '16598', '18288', '20502', '22033', '25614', '25794', '25807', '25811', '25826', '30063',
 '30152', '30167', '30561', '31391', '34986', '34991', '39123', '40633', '40667', '46589', '49727', '55342', '59911', '59950', '59998', '60021', '62806', '63495', '64002', '64017', '64021',
'64036', '64041', '65804', '65912', '70061', '70338', '70963', '71171', '71203', '71218', '71237', '76207', '77252', '78081', '80791', '80861', '80946', '80999', '84097', '85206', '80931', 
'86995', '87630', '90153', '90168', '30171') ExcludedFlag eq 1.

*New Admin Practices.
if any (prac, '15932', '16367', '18004', '19007', '19011', '21859', '21948', '21952', '21967', '21971', '22000', '22048', '46593', '54980', '55997', '56504', '58001', '60001', '65908',
'70041', '71261', '71350', '80804', '80819', '80823', '84971', '84985', '84990', '85992', '15858', '22029', '22052', '15858', '22052', '60035', '60040') ExcludedFlag eq 1.
execute.

save outfile = !file + 'HEA-PracticeLevel' + !year + '.zsav'
    /zcompressed. 

get file =   !file + 'HEA-PracticeLevel' + !year + '.zsav'.

compute year = ''.
compute prac = 'Please Select Practice'.
compute hbrescode = ''.
compute HBres = ''.
compute LA_CODE = 'Dummy'.
compute LCAname = 'Please Select Partnership'.
compute agegroup = ''.
compute specname = ''.
compute SpecialtyGrp = ''.
compute treated_board = ''.
compute ipdc = ''.
compute cij_pattype = ''.
compute Bed_Days = 0.
compute Total_Net_Cost = 0.
compute Episodes = 0.
compute lca = ''.
compute count = 0.
compute PracFlag = 0.
compute flag = 0.
compute AllSpecGrp = 0.
compute DelegatedSpecGrp = 0.
compute AllSpecname = 0.
compute ExcludedFlag = 0.
compute LankFlag = 0.

aggregate outfile = *
/break year prac hbrescode HBres LA_CODE LCAname agegroup specname SpecialtyGrp treated_board ipdc cij_pattype lca
/Bed_Days Total_Net_Cost Episodes count PracFlag flag AllSpecGrp DelegatedSpecGrp AllSpecname ExcludedFlag LankFlag
= sum(Bed_Days Total_Net_Cost Episodes count PracFlag flag AllSpecGrp DelegatedSpecGrp AllSpecname ExcludedFlag LankFlag).

add files file = *
/file =  !file + 'HEA-PracticeLevel' + !year + '.zsav'.
execute.

save outfile =  !file + 'HEA-PracticeLevel' + !year + '.zsav'
    /zcompressed.

get file = !file + 'HEA-PracticeLevel' + !year + '.zsav'.

*For matching on correct populations.
STRING NRAC_PW (A10).

* Set all to acute then change for specific specialities.
compute NRAC_PW = 'acute'.
If SpecialtyGrp = 'Child & Adolescent Psychiatry - Grp' NRAC_PW = 'mhld'.
If SpecialtyGrp = 'General Psychiatry - Grp' NRAC_PW = 'mhld'.
If SpecialtyGrp = 'Learning Disability' NRAC_PW = 'mhld'.
If SpecialtyGrp = 'Psychiatry of Old Age' NRAC_PW = 'mhld'.
If SpecialtyGrp = 'GP Obstetrics' NRAC_PW = 'maternity'.
If SpecialtyGrp = 'Obstetrics Specialist - Grp' NRAC_PW = 'maternity'.
If SpecialtyGrp = 'All' NRAC_PW = 'hchs'.
If SpecialtyGrp = 'All Delegated' NRAC_PW = 'hchs'.

compute LCA_HB_SCOT = prac.

sort cases by year NRAC_PW LCA_HB_SCOT agegroup.

*Add NRAC populations.
match files file = *
/table =  '/conf/sourcedev/TableauUpdates/Hospital Expenditure and Activity/Outputs/NRACfinal.sav'
/by year NRAC_PW LCA_HB_SCOT agegroup.
execute.

save outfile =   !file + 'HEA-PracticeLevel' + !year + '.zsav'
    /zcompressed.

*********************************************************************************************************************************.

get file =   !file + 'HEA-PracticeLevel' + !year + '.zsav'.

*Add healthboard totals as columns to partnership rows. 

sort cases by hbrescode agegroup specname SpecialtyGrp treated_board ipdc cij_pattype AllSpecGrp NRAC_PW DelegatedSpecGrp AllSpecname. 
alter type ipdc(a9).

******************************************************************** Should this be 'add files'?.

match files file = * 
 /table =  !file + 'HEA-RegionTotal' + !year + '.zsav'
 /by  hbrescode agegroup specname SpecialtyGrp treated_board ipdc cij_pattype AllSpecGrp NRAC_PW DelegatedSpecGrp AllSpecname.

String Data (A9).
compute data = 'GP'.

alter type prac(a25).
if prac eq 'Please' prac eq 'Please Select Practice'.

save outfile = !file + 'HEA-PracticeLevel' + !year + '.zsav'
    /zcompressed.

get file = !file + 'HEA-PracticeLevel' + !year + '.zsav'. 

*match on clusters

String Practice (A5).
compute Practice = prac.
execute.

* This is because the following file to match on has Practice as a float.
alter type Practice(F11.0).

sort cases by Practice.

* Check this lookup every run.

match files file = *
   /table= !ClusterLookup
   /by Practice.
execute.

* Check you're dropping all the unnecessary variables from the lookup above.

save outfile =  !file + 'HEA-PracticeLevel' + !year + '.zsav'
    /drop NHSBoard HSCPName Listsize Address1 Address2 Address3 Address4 Postcode Telephone Dispensing
    /zcompressed.

get file = !file + 'HEA-PracticeLevel' + !year + '.zsav'.
