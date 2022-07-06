* Encoding: UTF-8.
* Syntax for Hospital Expenditure and Activity Workbook.
* Re-written BM July 2020

*Create macros.

DEFINE !year()
'201617'
!ENDDEFINE.

DEFINE !file()
'/conf/sourcedev/TableauUpdates/Hospital Expenditure and Activity/Outputs/'
!ENDDEFINE.

DEFINE !NRAC()
'/conf/sourcedev/TableauUpdates/Hospital Expenditure and Activity/Outputs/NRACLCA.sav'
!ENDDEFINE.

* This line ensures you create a fresh and up-to-date lookup file every run. 
* Insert file = '/conf/sourcedev/TableauUpdates/Hospital Expenditure and Activity/Syntax/00 - Create lookup file.sps'.

******************************************************************************************.
* Read in Source Episode File with required variables only.

get file =  '/conf/hscdiip/01-Source-linkage-files/source-episode-file-' + !year + '.zsav'
/keep year recid gender dob gpprac cluster HBPRACCODE postcode HBRESCODE LCA HBTREATCODE location
yearstay IPDC SPEC SIGFAC smr01_cis_marker cij_pattype age cij_marker cij_admtype Cost_Total_Net datazone2011 Locality CA2018.
rename variables CA2018 = LA_Code.

***************
* Formatting and selections.
* Select only inpatients and day cases, don't select Maternity Cases.
select if ipdc eq 'I' or ipdc eq 'D'.
select if recid ne '02B'.
* Check State Hospital not included - D101H.
select if location ne 'D101H'.

*Match on Localities by datazone.
 * sort cases by datazone2011.
 * match files file = *
/table = !file + 'Locality Lookup HEA.sav'
/by datazone2011.
 * execute.
* Rename datazone 2011 and fill in missing localities.
rename variables datazone2011 = datazone.
if locality eq '' locality eq 'Unknown'.

* Recode missing patient types with 'other'..
if cij_pattype = '' cij_pattype = 'Other'.

*Creates a variable for counting rows in later aggregates.
compute Episodes = 1.

* Binning age groups.
STRING agegroup(A10).
if sysmis(age) agegroup = 'Missing'.
RECODE age (low thru 17='0-17')(18 thru 44='18-44') (45 thru 64='45-64') (65 thru 74='65-74') (75 thru 84='75-84') (85 thru high='85+') into agegroup.

* We get the specific names for the specialties here. The reason we don't just keep spec and its value labels is that we need to copy them over to 
* SpecialtyGrp and the value labels wouldn't be preserved.
string specname (a40).
compute specname = valuelabel(spec).
if specname = 'General Surgery (excl Vascular, Maxillof' specname = 'General Surgery (excl Vascular)'.

* We assign certain specialties group names, but the other non-grouped specialties are copied over here as otherwise
* we would have many system-missing values for this variable and we don't want to aggregate them together.
string SpecialtyGrp (a50).
recode spec 
('C1', 'C11' =  'General Surgery (excludes Vascular) - Grp')
('C4', 'C41' = 'Cardiac Surgery - Grp')
('D3', 'D4' = 'Oral Surgery & Medicine - Grp')
('C5', 'C51' =  'Ear, Nose & Throat - Grp')
('A1', 'A11' = 'General Medicine - Grp')
('C3', 'C31' = 'Anaesthetics - Grp')
('D1', 'D5', 'D6', 'D8' = 'Dental - Grp')
('G1', 'G3' =  'General Psychiatry - Grp')
('G2', 'G21', 'G22' = 'Child & Adolescent Psychiatry - Grp')
('F3', 'F31', 'F32', 'T2', 'T21' = 'Obstetrics Specialist - Grp')
('A8', 'A81', 'A82', 'AA', 'AC', 'AW', 'H1', 'J5' =  'Other medical specialties - Grp')
into SpecialtyGrp.
if (char.substr(spec,1,1) = 'C' or spec= 'F2') SpecialtyGrp = 'Surgical Specialties & Anaesthetics - Grp'.
if SpecialtyGrp = '' SpecialtyGrp = specname.

* We want to specify whether someone was treated inside or outside their Board of residence.
numeric treated_board(f1.0).
if hbrescode eq hbtreatcode treated_board eq 1.
if hbrescode ne hbtreatcode treated_board eq 0.
add value labels treated_board
1 'Within HB of Residence'
2 'Outwith HB of Residence'.

* Create Health Board of Residence variable with the names of the board. We want them in the format 'HBNAME Region', and
* any 'and' we want to be an ampersand. Any cases that don't fit are recoded to 'Other Non-Scottish Residents'.
string HBRegionFormat(a35).
compute HBRegionFormat = valuelabel(hbrescode).
if (HBRegionFormat = 'No Fixed Abode') or
   (HBRegionFormat = 'Not Known') or
   (HBRegionFormat = 'Outside UK') or
   (HBRegionFormat = 'Out-with Scotland / RUK') or
   (HBRegionFormat = '')
   HBRegionFormat = 'Other Non-Scottish Residents'.
compute HBRegionFormat = replace(HBRegionFormat, ' and ', ' & ').
compute HBRegionFormat = replace(HBRegionFormat, 'NHS ','').
if HBRegionFormat ne 'Other Non-Scottish Residents' HBRegionFormat = concat(HBRegionFormat, ' Region').

string HBResName(a35).
compute HBResName = valuelabel(hbrescode).
if (HBResName = 'No Fixed Abode') or
   (HBResName = 'Not Known') or
   (HBResName = 'Outside UK') or
   (HBResName = 'Out-with Scotland / RUK') or
   (HBResName = '')
   HBResName = 'Other Non-Scottish Residents'.
compute HBResName = replace(HBResName, ' and ', ' & ').

*Get names for Local Council Areas.
string LCAname (a30).
compute LCAname = valuelabel(LCA).
compute LCAname = replace(LCAname, ' and ', ' & ').
if LCAname = 'Na h-Eileanan Siar' LCAname = 'Western Isles'.
if HBResName = 'NHS Orkney' LCAname = 'Orkney Islands'.
if HBResName = 'NHS Shetland' LCAname = 'Shetland Islands'.
if LCAname = '' LCAname = 'Non LCA'.

* This series of statements checks if the LCA assigned to a case is inside the Board. If not, we assign the LCA as being 'Non-LCA'.
if HBRegionFormat= 'Ayrshire & Arran Region' and (LCAname ne 'East Ayrshire'	and LCAname ne 'North Ayrshire'	and LCAname ne	'South Ayrshire')	LCAname='Non LCA'.	 	 	 	 
if HBRegionFormat ='Borders Region' and LCAname ne 'Scottish Borders'	LCAname='Non LCA'.
if HBRegionFormat ='Fife Region' and (LCAname ne 'Fife')	LCAname='Non LCA'.	 	 	 	 
if HBRegionFormat ='Greater Glasgow & Clyde Region' and (LCAname ne 'East Dunbartonshire'	and LCAname ne 'East Renfrewshire' and LCAname ne	'Glasgow City' and LCAname ne 'Inverclyde' 
and LCAname ne	'Renfrewshire'	and LCAname ne 'West Dunbartonshire' and LCAname ne 'North Lanarkshire' and LCAname ne 'South Lanarkshire' )	LCAname='Non LCA'.	 		 
if HBRegionFormat ='Highland Region' and (LCAname ne 'Argyll & Bute' and LCAname ne	'Highland')	LCAname='Non LCA'.	 	 	 	 	 
if HBRegionFormat ='Lanarkshire Region' and (LCAname ne 'North Lanarkshire' and LCAname ne	'South Lanarkshire')	LCAname='Non LCA'.	 	 	 	 	 
if HBRegionFormat ='Grampian Region' and (LCAname ne 'Aberdeen City' and LCAname ne	'Aberdeenshire' and LCAname ne	'Moray')	LCAname='Non LCA'.	 		 	 	 
if HBRegionFormat ='Orkney Region' and LCAname ne 'Orkney Islands' LCAname='Non LCA'.	 	 	 	 	 	 	 
if HBRegionFormat ='Shetland Region' and LCAname ne 'Shetland Islands' LCAname='Non LCA'.	 	 	 	 	 	 	 
if HBRegionFormat ='Lothian Region' and (LCAname ne 'City of Edinburgh' and LCAname ne 'East Lothian' and LCAname ne 'Midlothian' and LCAname ne	'West Lothian')	LCAname='Non LCA'.	 		 
if HBRegionFormat ='Tayside Region' and (LCAname ne 'Angus' and LCAname ne	'Dundee City' and LCAname ne 'Perth & Kinross')	LCAname='Non LCA'.	 		 	 
if HBRegionFormat ='Forth Valley Region' and (LCAname ne 'Falkirk'	and LCAname ne 'Clackmannanshire' and LCAname ne 'Stirling')	LCAname='Non LCA'.	 		 
if HBRegionFormat ='Western Isles Region' and LCAname ne 'Western Isles'	LCAname='Non LCA'.	 	 	 	 	 	 	 
if HBRegionFormat ='Dumfries & Galloway Region' and LCAname ne 'Dumfries & Galloway' LCAname='Non LCA'.

* Use record ID and Inpatient/Day case marker to find out whether an individual was elective or non-elective.
* This needs to be done due to the cost mapping process splitting these across different mapping codes than the SLFs do.
string mapcode(a3).
do if recid = '01B' and IPDC = 'I' and cij_pattype = 'Non-Elective'.
compute mapcode ='01A'.
else if recid = '01B' and IPDC = 'I' and cij_pattype = 'Elective'.
compute mapcode = '01B'.
else if recid = '01B' and IPDC = 'I' and (cij_pattype ~= 'Elective' or cij_pattype ~= 'Non-Elective' ).
compute mapcode = '01C'.
else if recid = '01B' and IPDC = 'D'.
compute mapcode = '02'.
else if recid = '04B' and IPDC = 'I' and cij_pattype = 'Non-Elective'.
compute mapcode = '03A'.
else if recid = '04B' and IPDC = 'I' and cij_pattype = 'Elective'.
compute mapcode = '03B'.
else if recid = '04B' and IPDC = 'I' and  (cij_pattype ~= 'Elective' or cij_pattype ~= 'Non-Elective' ).
compute mapcode = '03D'.
else if recid = '50B' and cij_pattype = 'Non-Elective'.
compute mapcode = '04A'.
else if recid = '50B' and cij_pattype = 'Elective'.
compute mapcode = '04B'.
else if recid = '50B' and (cij_pattype ~= 'Elective' or cij_pattype ~= 'Non-Elective' ).
compute mapcode = '04C'.
else if recid = '02B' and IPDC = 'I'.
compute mapcode = '05'.
else if recid = '02B' and IPDC = 'D'.
compute mapcode = '06'.
ELSE.
compute mapcode = '99'.
end if.

*****************************************************************************************************************************.
* Here we save out the data for use in the second part of the syntax (GP practice level data).
save outfile = !file + 'GPMaster' + !year + '.sav' /zcompressed.
 * save outfile = !file + 'HBMaster' + !year + '.sav' /zcompressed.
*****************************************************************************************************************************.
get file = !file + 'GPMaster' + !year + '.sav'.

* Create lca of Clackmannanshire & Stirling.
select if lcaname = 'Clackmannanshire' or lcaname = 'Stirling'.
compute lcaname = 'Clackmannanshire & Stirling'.
save outfile = !file + 'CSTemp.sav' /zcompressed.

add files file = !file + 'GPMaster' + !year + '.sav'
/file = !file + 'CSTemp.sav'.
execute.

* First major aggregate, self-explanatory but it provides us with the main measures we use in the workbook.
aggregate outfile = *
/break year recid mapcode HBRESCODE HBTREATCODE HBRegionFormat HBResName LCA LCAname LA_CODE location agegroup specname SpecialtyGrp treated_board IPDC cij_pattype locality
/Bed_Days = sum(yearstay)
/Total_Net_Cost = sum(Cost_Total_Net)
/Episodes = sum(Episodes).

* We don't need the group 'All MHLD' as these specialties are covered elsewhere.
select if specialtygrp ne 'All MHLD'.
sort cases by location.
alter type location(a5).

* Match with list created in BO to identify Acute/Community/Mental Health care providers.
* This list is currently out of date, but no-one seems to know how to create it.
match files file =*
/table = '/conf/irf/09-Tableau-Outputs/01-Development/04-Source-Data/02-PLICS/Hosp_Services.sav'
/by location.
alter type locname(a70).
* Match with national lookup file to get correct Location (hospital) name.
match files file = *
    /table =  '/conf/linkage/output/lookups/Unicode/National Reference Files/location.sav'
    /by location.

*****************************************************************************************.
* This part has caused issues in the past. Every location in the dataset should have a corresponding name.  
 * frequencies locname.
* Bateman 26/08/20 - 938 missing location names.
 * select if locname eq ''.
 * execute.
 * frequencies location.

* The following location names have failed to fill in for all years, so this code is added.
if location = 'A217H' locname = 'Woodland View'.
if location = 'E006V' locname = 'The Farndon Unit'.
if location = 'G503H' locname = 'Drumchapel Hospital'.
if location = 'G517H' locname = 'Beatson West of Scotland Cancer Centre'.
if location = 'G518V' locname = 'Quayside Nursing Home'.
if location = 'G584V' locname = 'Robin House Childrens Hospice Association Scotland'.
if location = 'G604V' locname = 'NE Class East Social Work Day Unit'.
if location = 'G611H' locname = 'Netherton'.
if location = 'G614H' locname = 'Orchard View'.
if location = 'H220V' locname = 'Highland Hospice'.
if location = 'H239V' locname = 'Howard Doris Centre'.
if location = 'T317V' locname = 'Rachel House Childrens Hospice'.
if location = 'T319H' locname = 'Whitehills Health and Community Care Centre'.
if location = 'Y146H' locname = 'Dumfries & Galloway Royal Infirmary'.
if location = 'Y177C' locname = 'Mountainhall Treatment Centre'.
*****************************************************************************************.

* Use the location code to identify the type and Health Board of each location.
string typeCode (a1).
compute typeCode = char.substr(location, 5, 1).
string LocHB (a1).
compute LocHB = char.substr(location, 1, 1).

* Section for Type of hospital.
String type (a20).
do if typeCode eq 'H'.
        compute type = 'NHS Hospital'.
    else if typeCode eq 'V'.
        compute type = 'Private Care'.
    else if typeCode eq 'K'.
        compute type = 'Contractual Hospital'.
    else.
        compute type = 'Other'.
end if.
**** Test.
 * frequencies type.
****.

* Section for determining Health Board of hospital.
String Hospital_Board (a40).
if LocHB = 'A'           Hospital_Board =       'Ayrshire & Arran Region'.
if LocHB = 'B'           Hospital_Board=        'Borders Region'.
if LocHB = 'C' and hbtreatcode eq 'S08000007' Hospital_Board = 'Greater Glasgow & Clyde Region'.
if LocHB = 'C' and hbtreatcode eq 'S08000008' Hospital_Board = 'Highland Region'.
if LocHB = 'C' and hbtreatcode eq 'S27000001' Hospital_Board = 'Private Care'.
if LocHB = 'D'          Hospital_Board =       'Golden Jubilee'.
if LocHB = 'F'           Hospital_Board =       'Fife Region'.
if LocHB = 'G'          Hospital_Board =       'Greater Glasgow & Clyde Region'.
if LocHB = 'H'          Hospital_Board =       'Highland Region'.
if LocHB = 'L'           Hospital_Board =       'Lanarkshire Region'.
if LocHB = 'N'          Hospital_Board =       'Grampian Region'.
if LocHB = 'R'           Hospital_Board =       'Orkney Region'.
if LocHB = 'S'           Hospital_Board =       'Lothian Region'.
if LocHB = 'T'           Hospital_Board =       'Tayside Region'.
if LocHB = 'V'          Hospital_Board =       'Forth Valley Region'.
if LocHB = 'W'         Hospital_Board =       'Western Isles Region'.
if LocHB = 'Y'           Hospital_Board =       'Dumfries & Galloway Region'.
if LocHB = 'Z'           Hospital_Board =       'Shetland Region'.
execute.

string TreatedHBRegion (a40).
compute  TreatedHBRegion = valuelabel(hbrescode).
if (TreatedHBRegion = 'No Fixed Abode') or
   (TreatedHBRegion = 'Not Known') or
   (TreatedHBRegion = 'Outside UK') or
   (TreatedHBRegion = 'Out-with Scotland / RUK') or
   (TreatedHBRegion = '')
   TreatedHBRegion = 'Other Non-Scottish Residents'.
if TreatedHBRegion ne 'Other Non-Scottish Residents' TreatedHBRegion = concat(TreatedHBRegion, ' Region').
compute TreatedHBRegion = replace(TreatedHBRegion, ' and ', ' & ').
compute TreatedHBRegion = replace(TreatedHBRegion, 'NHS ','').
execute.
if Hospital_Board eq '' Hospital_Board eq TreatedHBRegion.

**** Test.
 * frequencies Hospital_Board.
*****.

* Some quick formatting for aesthetic purposes.
alter type IPDC (a9).
if IPDC eq 'A' IPDC eq 'All'.
if IPDC eq 'I' IPDC eq 'Inpatient'.
if IPDC eq 'D' IPDC eq 'Day Case'.

* Create an 'All' specialty group. This is done here to avoid under-counting after the flags are declared below.
save outfile = !file + 'LCATemp' + !year + '.sav' /zcompressed.
get file = !file + 'LCATemp' + !year + '.sav'.

compute SpecialtyGrp = 'All'.
compute specname = 'All'.

AGGREGATE
 /OUTFILE= *
 /break year recid mapcode HBRESCODE HBTREATCODE HBRegionFormat HBResName Hospital_Board TreatedHBRegion LCA LCAname LA_CODE location locname type agegroup specname SpecialtyGrp treated_board IPDC cij_pattype locality
/Bed_Days = sum(Bed_Days)
/Total_Net_Cost = sum(Total_Net_Cost)
/Episodes = sum(Episodes).

add files file = *
/file = !file + 'LCATemp' + !year + '.sav'.
save outfile = !file + 'LCATemp' + !year + '.sav' /zcompressed.
get file = !file + 'LCATemp' + !year + '.sav'.

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

save outfile = !file + 'LCATemp' + !year + '.sav' /zcompressed.

* Create an 'All Delegated' group.
select if FlagDelegatedSpec = 1.
compute SpecialtyGrp = 'All Delegated'.
compute specname = 'All Delegated'.
compute FlagAllSpecialties = 0.
compute FlagGroupSpecs = 0.
aggregate outfile = *
/break year recid mapcode HBRESCODE HBTREATCODE HBRegionFormat HBResName Hospital_Board TreatedHBRegion LCA LCAname LA_CODE location locname type agegroup specname SpecialtyGrp treated_board IPDC cij_pattype locality
/Bed_Days = sum(bed_days)
/Total_Net_Cost = sum(Total_Net_Cost)
/Episodes = sum(Episodes)
/FlagGroupSpecs = max(FlagGroupSpecs)
/FlagAllSpecialties = max(FlagAllSpecialties)
/FlagDelegatedSpec = max(FlagDelegatedSpec).

add files file = *
/file = !file + 'LCATemp' + !year + '.sav'.
execute.

save outfile = !file + 'LCATemp' + !year + '.sav' /zcompressed.
get file = !file + 'LCATemp' + !year + '.sav'.

* Create an 'All Ages' group.
compute agegroup = 'All Ages'.
aggregate outfile = *
/break year recid mapcode HBRESCODE HBTREATCODE HBRegionFormat HBResName Hospital_Board TreatedHBRegion 
LCA LCAname LA_CODE location locname type agegroup specname SpecialtyGrp treated_board IPDC cij_pattype locality
/Bed_Days = sum(bed_days)
/Total_Net_Cost = sum(Total_Net_Cost)
/Episodes = sum(Episodes)
/FlagGroupSpecs = max(FlagGroupSpecs)
/FlagAllSpecialties = max(FlagAllSpecialties)
/FlagDelegatedSpec = max(FlagDelegatedSpec).

add files file = *
/file = !file + 'LCATemp' + !year + '.sav'.

save outfile = !file + 'LCATemp' + !year + '.sav' /zcompressed.
get file = !file + 'LCATemp' + !year + '.sav'.

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

*** Test.
frequencies caretype.
****.

* The NRAC lookup has practice and LCA populations, this variable ensures we use the correct ones.
string NRACmatch(a10).
compute NRACmatch = 'LCA Level'.

* The important break here is at locality level.

aggregate outfile = *
/break year recid mapcode HBRESCODE HBTREATCODE HBRegionFormat HBResName Hospital_Board TreatedHBRegion 
LCA LCAname LA_CODE location locname type caretype NRACmatch agegroup specname SpecialtyGrp treated_board IPDC cij_pattype locality
/Bed_Days = sum(Bed_Days)
/Total_Net_Cost = sum(Total_Net_Cost)
/Episodes = sum(Episodes)
/FlagGroupSpecs = max(FlagGroupSpecs)
/FlagAllSpecialties = max(FlagAllSpecialties)
/FlagDelegatedSpec = max(FlagDelegatedSpec).

 * save outfile = !file + 'LCAMaster' + !year + '.sav' /zcompressed.

* The NRAC populations match on at age group and caretype at the lowest, so here we aggregate out the locality data to end up with one row per 
* LCA with the breaks also being on the main filters in the workbook.

 * get file = !file + 'LCAMaster' + !year + '.sav'.

 * aggregate outfile = *
/break year HBRESCODE HBTREATCODE HBRegionFormat HBResName TreatedHBRegion Hospital_Board LCA LCAname location locname type caretype nracmatch LA_CODE agegroup specname SpecialtyGrp treated_board IPDC cij_pattype
/Bed_Days = sum(Bed_Days)
/Total_Net_Cost = sum(Total_Net_Cost)
/Episodes = sum(Episodes)
/FlagGroupSpecs = max(FlagGroupSpecs)
/FlagAllSpecialties = max(FlagAllSpecialties)
/FlagDelegatedSpec = max(FlagDelegatedSpec).

sort cases by lcaname year agegroup caretype nracmatch.

*Add NRAC populations.
match files file = *
/table = !NRAC
/by lcaname year agegroup caretype nracmatch.
execute.

if lcaname = 'Clackmannanshire & Stirling' LA_code = 'S12000005'.

aggregate outfile = *
/break year HBRESCODE HBTREATCODE HBRegionFormat HBResName TreatedHBRegion Hospital_Board LCA LCAname locality location locname type caretype nracmatch LA_CODE agegroup specname SpecialtyGrp treated_board IPDC cij_pattype
/Bed_Days = sum(Bed_Days)
/Total_Net_Cost = sum(Total_Net_Cost)
/Episodes = sum(Episodes)
/Popn = first(popn)
/FlagGroupSpecs = max(FlagGroupSpecs)
/FlagAllSpecialties = max(FlagAllSpecialties)
/FlagDelegatedSpec = max(FlagDelegatedSpec).

* Change CA2018 values to CA2011 values for Tableau security filters.
if LA_code = 'S12000047' LA_code = 'S12000015'.
if LA_code = 'S12000048' LA_code = 'S12000024'.

save outfile = !file + 'LCALevel' + !year + '.sav'.

erase file = !file + 'LCATemp' + !year + '.sav'.
 * erase file = !file + 'LCAMaster' + !year + '.sav'.
