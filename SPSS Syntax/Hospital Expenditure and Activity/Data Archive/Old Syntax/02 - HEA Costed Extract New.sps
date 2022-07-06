* Encoding: UTF-8.
* Syntax for Hospital Expenditure and Activity Workbook.
* JM Update 2017.
* BM update March 2019.
* BM update April 2020 - changed much of the renaming and selections in first 180 lines so that the value labels are taken directly from the SLFs,
  this will ensure that any changes made to codes will pull through to this dataset. 

*Create Parameters.
DEFINE !year()
'201819'
!ENDDEFINE.

DEFINE !file()
'/conf/sourcedev/TableauUpdates/Hospital Expenditure and Activity/Outputs/'
!ENDDEFINE.

* This line ensures you create a fresh and up-to-date lookup file every run. 
* Insert file = '/conf/sourcedev/TableauUpdates/Hospital Expenditure and Activity/Syntax/00 - Create lookup file.sps'.

*****************************************************************************
* Read in Source Episode File with required variables only.

* 13/03/19 Bateman - Changed some variables to fit with updates made to SLFs. 

get file =  '/conf/hscdiip/01-Source-linkage-files/source-episode-file-' + !year + '.zsav'
/keep year recid record_keydate1 record_keydate2 anon_CHI gender dob gpprac HBPRACCODE postcode HBRESCODE LCA HBTREATCODE location
yearstay STAY IPDC SPEC SIGFAC TADM smr01_cis_marker cij_pattype age DIAG1 cij_marker cij_admtype Cost_Total_Net
simd2020v2_HSCP2019_decile datazone2011 CA2018.

rename variables CA2018 = LA_Code.

*Select only inpatients and day cases, don't select Maternity Cases.
select if ipdc eq 'I' or ipdc eq 'D'.
select if recid ne '02B'.
* Check State Hospital not included - D101H.
select if location ne 'D101H'.

* This one command takes ~1.5 hours, just as a heads-up.
sort cases by Datazone2011.

*Match on Localities by datazone.
match files file = *
/table = '/conf/sourcedev/TableauUpdates/Hospital Expenditure and Activity/Outputs/Locality Lookup HEA.sav'
/by datazone2011.

rename variables datazone2011 = datazone.
if locality eq '' locality eq 'Unknown'.

* Fix an issue with Gender coding and missing cij_pattype.
If gender = 0 gender = 9.   
if cij_pattype = '' cij_pattype = 'Other'.

*Creates a variable for counting rows in later aggregates.
compute EpCount = 1.

*Creates Age Groups <18, 18-64 ,65-74, 75-84, 85+, and 'Missing' .
STRING agegroup (A10) .
if age = 999.00 agegroup = 'Missing'.
RECODE age (low thru 17='0-17')(18 thru 44='18-44') (45 thru 64='45-64') (65 thru 74='65-74') (75 thru 84='75-84') (85 thru high='85+') into agegroup.
 * frequencies agegroup.

* Assign Specialty names.
string specname (a40).
compute specname = valuelabel(spec).
if specname = 'General Surgery (excl Vascular, Maxillof' specname = 'General Surgery (excl Vascular)'.

*Get Specialty Groups.
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
execute.
if SpecialtyGrp = '' SpecialtyGrp = specname.
execute.

*Get names for Health Board.

string treated_board (a15).
if hbrescode eq hbtreatcode treated_board eq 'Within HBres'.
if hbrescode ne hbtreatcode treated_board eq 'Outwith HBres'.

string HBres(a35).
compute HBres = valuelabel(hbrescode).
if (HBres = 'No Fixed Abode') or
   (HBres = 'Not Known') or
   (HBres = 'Outside UK') or
   (HBres = 'Out-with Scotland / RUK') or
   (HBres = '')
   HBres = 'Other Non-Scottish Residents'.
compute HBres = replace(HBres, ' and ', ' & ').
compute HBres = replace(HBres, 'NHS ','').
if HBres ne 'Other Non-Scottish Residents' HBres = concat(HBres, ' Region').
execute.

*Get names for Local Council Areas.
string LCAname (a30).
compute LCAname = valuelabel(LCA).
compute LCAname = replace(LCAname, ' and ', ' & ').
if LCAname = 'Na h-Eileanan Siar' LCAname = 'Western Isles'.
if LCAname = '' LCAname = 'Non LCA'.

if hbres= 'Ayrshire & Arran Region' and (LCAname ne 'East Ayrshire'	and LCAname ne 'North Ayrshire'	and LCAname ne	'South Ayrshire')	LCAname='Non LCA'.	 	 	 	 
if hbres ='Borders Region' and LCAname ne 'Scottish Borders'	LCAname='Non LCA'.
if hbres ='Fife Region' and (LCAname ne 'Fife')	LCAname='Non LCA'.	 	 	 	 
if hbres ='Greater Glasgow & Clyde Region' and (LCAname ne 'East Dunbartonshire'	and LCAname ne 'East Renfrewshire' and LCAname ne	'Glasgow City' and LCAname ne 'Inverclyde' 
and LCAname ne	'Renfrewshire'	and LCAname ne 'West Dunbartonshire' and LCAname ne 'North Lanarkshire' and LCAname ne 'South Lanarkshire' )	LCAname='Non LCA'.	 		 
if hbres ='Highland Region' and (LCAname ne 'Argyll & Bute' and LCAname ne	'Highland')	LCAname='Non LCA'.	 	 	 	 	 
if hbres ='Lanarkshire Region' and (LCAname ne 'North Lanarkshire' and LCAname ne	'South Lanarkshire')	LCAname='Non LCA'.	 	 	 	 	 
if hbres ='Grampian Region' and (LCAname ne 'Aberdeen City' and LCAname ne	'Aberdeenshire' and LCAname ne	'Moray')	LCAname='Non LCA'.	 		 	 	 
if hbres ='Orkney Region' and LCAname ne 'Orkney Islands' LCAname='Non LCA'.	 	 	 	 	 	 	 
if hbres ='Shetland Region' and LCAname ne 'Shetland Islands' LCAname='Non LCA'.	 	 	 	 	 	 	 
if hbres ='Lothian Region' and (LCAname ne 'City of Edinburgh' and LCAname ne 'East Lothian' and LCAname ne 'Midlothian' and LCAname ne	'West Lothian')	LCAname='Non LCA'.	 		 
if hbres ='Tayside Region' and (LCAname ne 'Angus' and LCAname ne	'Dundee City' and LCAname ne 'Perth & Kinross')	LCAname='Non LCA'.	 		 	 
if hbres ='Forth Valley Region' and (LCAname ne 'Falkirk'	and LCAname ne 'Clackmannanshire' and LCAname ne 'Stirling')	LCAname='Non LCA'.	 		 
if hbres ='Western Isles Region' and LCAname ne 'Western Isles'	LCAname='Non LCA'.	 	 	 	 	 	 	 
if hbres ='Dumfries & Galloway Region' and LCAname ne 'Dumfries & Galloway' LCAname='Non LCA'.	 	 	 	 	 	 	 

sort cases by gpprac.

save outfile = !file + 'HEA-MasterExtract' + !year + '.zsav'
    /zcompressed.
get file = !file + 'HEA-MasterExtract' + !year + '.zsav'.

********************************************************************************************************************************************************

*Find if individual was Elective or non-elective.
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

*Practices which have merged/closed. This will have to be checked every run against spreadsheet from Primary Care Team.
recode gpprac (10751, 10799 = 10746) (20165 = 20170) (21806 = 21811) (25116 = 25121) (25296 = 25883) 
                       (31112, 31121 = 30769) (31422, 31441 = 31461) (38101, 38121, 38140, 38224 = 38239) (40116, 40313 = 40737) 
                       (46377, 46108 = 46625) (61057, 61490, 61227, 61428 = 61630) (61409, 60069 = 60228) (62830, 62811 = 62830) 
                       (70037, 70643 = 71449) (80895, 80683 = 80895) (86054, 86162, 86110 = 86360) (87216, 87221 = 87240) 
                       (90007, 90026 = 90187) (90064, 90079, 90083 = 90191)        
(else = copy).

*save outfile to bring back later for GP level analysis.

save outfile =  !file + 'HEA-MasterGPExtract' + !year + '.zsav'
    /zcompressed.

get file = !file + 'HEA-MasterGPExtract' + !year + '.zsav'.

* Create lca of Clackmannanshire & Stirling.
select if lcaname = 'Clackmannanshire' or lcaname = 'Stirling'.
compute lcaname = 'Clackmannanshire & Stirling'.
save outfile = !file + 'CSTemp.sav' /zcompressed.

add files file = !file + 'HEA-MasterGPExtract' + !year + '.zsav'
/file = !file + 'CSTemp.sav'.
execute.

save outfile =  !file + 'HEA-MasterGPExtract' + !year + '.zsav'
    /zcompressed.

*******************************************************************************************************************************************************************************************.
* Create main file for Hospital-level data.

aggregate outfile = *
/break year recid mapcode HBRESCODE HBTREATCODE HBres LCA LCAname LA_CODE location agegroup specname SpecialtyGrp treated_board IPDC cij_pattype locality
/Bed_Days = sum(yearstay)
/Total_Net_Cost = sum(Cost_Total_Net)
/Episodes = sum(EpCount).

save outfile = !file + 'HEA-MasterExtract' + !year + '.zsav'
    /zcompressed.

save outfile = !file + 'HEA-MasterExtract' + !year + '.sav'.

***********
*Create main file for Dashboards 1 and 2.

get file = !file + 'HEA-MasterExtract' + !year + '.zsav'.

*Remove Localities.

AGGREGATE
 /OUTFILE=* 
  /break year recid mapcode HBRESCODE HBres LA_CODE LCAname agegroup specname SpecialtyGrp  treated_board IPDC cij_pattype
/Bed_Days = sum(Bed_Days)
/Total_Net_Cost = sum(Total_Net_Cost)
/Episodes = sum(Episodes).

save outfile = !file + 'HEA-MasterExtract-Main' + !year + '.zsav'
    /zcompressed.

*Create data for All Ages.

compute agegroup ='All'.

AGGREGATE
 /OUTFILE=* 
  /break year recid mapcode HBRESCODE HBres LA_CODE LCAname agegroup specname SpecialtyGrp  treated_board IPDC cij_pattype
/Bed_Days = sum(Bed_Days)
/Total_Net_Cost = sum(Total_Net_Cost)
/Episodes = sum(Episodes).
exe.

add files file= *
/file= !file + 'HEA-MasterExtract-Main' + !year + '.zsav'.

save outfile = !file + 'HEA-MasterExtract-Main' + !year + '.zsav'
    /zcompressed.

*IPDC totals.

Get file = !file + 'HEA-MasterExtract-Main' + !year + '.zsav'.

Compute ipdc = 'A'.

AGGREGATE
 /OUTFILE=* 
 /break year recid mapcode HBRESCODE HBres LA_CODE LCAname agegroup specname SpecialtyGrp  treated_board IPDC cij_pattype
/Bed_Days = sum(Bed_Days)
/Total_Net_Cost = sum(Total_Net_Cost)
/Episodes = sum(Episodes).

add files file= *
/file=  !file + 'HEA-MasterExtract-Main' + !year + '.zsav'.

save outfile = !file + 'HEA-MasterExtract-Main' + !year + '.zsav'
    /zcompressed.

*All Spec Group.
get file = !file + 'HEA-MasterExtract-Main' + !year + '.zsav'.
compute SpecialtyGrp = 'All'.
compute specname = 'All'.

AGGREGATE
 /OUTFILE=* 
 /break year recid mapcode HBRESCODE HBres LA_CODE LCAname agegroup specname SpecialtyGrp  treated_board IPDC cij_pattype
/Bed_Days = sum(Bed_Days)
/Total_Net_Cost = sum(Total_Net_Cost)
/Episodes = sum(Episodes).

add files file = *
/file = !file + 'HEA-MasterExtract-Main' + !year + '.zsav'.

save outfile  =  !file + 'HEA-MasterExtract-Main' + !year + '.zsav'
    /zcompressed.
execute.

get file =  !file + 'HEA-MasterExtract-Main' + !year + '.zsav'.

*All Patient Types.
compute cij_pattype = 'All'.

AGGREGATE
 /OUTFILE=* 
/break year recid mapcode HBRESCODE HBres LA_CODE LCAname agegroup specname SpecialtyGrp treated_board IPDC cij_pattype
/Bed_Days = sum(Bed_Days)
/Total_Net_Cost = sum(Total_Net_Cost)
/Episodes = sum(Episodes).

add files file = *
/file =   !file + 'HEA-MasterExtract-Main' + !year + '.zsav'.
execute.

save outfile  = !file + 'HEA-MasterExtract-Main' + !year + '.zsav'
    /zcompressed.
execute.

*All treated Boards .
get file = !file + 'HEA-MasterExtract-Main' + !year + '.zsav'.

compute treated_board = 'All'.

AGGREGATE
 /OUTFILE=* 
/break year recid mapcode HBRESCODE HBres LA_CODE LCAname agegroup specname SpecialtyGrp treated_board IPDC cij_pattype
/Bed_Days = sum(Bed_Days)
/Total_Net_Cost = sum(Total_Net_Cost)
/Episodes = sum(Episodes).

add files file = *
/file =  !file + 'HEA-MasterExtract-Main' + !year + '.zsav'.
execute.

save outfile =  !file + 'HEA-MasterExtract-Main' + !year + '.zsav'
    /zcompressed.

get file =  !file + 'HEA-MasterExtract-Main' + !year + '.zsav'.

*Due to population aggrigation issues in Tableau, Specialty groups need an 'All Specialty' for filtering.

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
/break year recid mapcode HBRESCODE HBres LA_CODE LCAname agegroup specname SpecialtyGrp treated_board IPDC cij_pattype 
/Bed_Days = sum(Bed_Days)
/Total_Net_Cost = sum(Total_Net_Cost)
/Episodes = sum(Episodes).

add files file = *
/file =  !file + 'HEA-MasterExtract-Main' + !year + '.zsav'.  
execute.

save outfile =  !file + 'HEA-MasterExtract-Main' + !year + '.zsav'
    /zcompressed.

*Get All Delegated Specialties for selection.
get file =  !file + 'HEA-MasterExtract-Main' + !year + '.zsav'.

select if any (specname, 'Accident & Emergency', 'Acute Medicine', 'Adolescent Psychiatry', 'Allergy', 'Anaesthetics', 'Cardiac Surgery', 'Cardiology', 'Cardiothoracic Surgery',
'Child & Adolescent Psychiatry', 'Child Psychiatry', 'Clinical Oncology', 'Communicable Diseases', 'Community Dental Practice', 'Dermatology', 'Diabetes', 'Diagnostic Radiology',
'Ear, Nose & Throat (ENT)', 'Endocrinology', 'Endocrinology & Diabetes', 'Forensic Psychiatry', 'Gastroenterology', 'General Medicine', 'General Psychiatry', 'General Surgery',
'General Surgery (excl Vascular)', 'Geriatric Medicine', 'GP Other than Obstetrics', 'Gynaecology', 'Haematology', 'Homoeopathy', 'Immunology', 'Learning Disability', 'Medical Oncology',
'Medical Paediatrics', 'Nephrology', 'Neurology', 'Neurosurgery', 'Ophthalmology', 'Oral & Maxillofacial Surgery', 'Oral Medicine', 'Oral Surgery', 'Orthopaedics', 'Paediatric Dentistry',
'Pain Management', 'Palliative Medicine', 'Plastic Surgery', 'Psychiatry of Old Age', 'Rehabilitation Medicine', 'Respiratory Medicine', 'Restorative Dentistry', 'Rheumatology', 'Surgical Paediatrics',
'Thoracic Surgery', 'Urology', 'Vascular Surgery').

select if any (specname, 'Accident & Emergency', 'Forensic Psychiatry', 'General Medicine', 'General Psychiatry', 'Geriatric Medicine',
'GP Other than Obstetrics', 'Learning Disability', 'Palliative Medicine', 'Psychiatry of Old Age', 'Rehabilitation Medicine', 'Respiratory Medicine').

select if SpecialtyGrp ne 'All MHLD'.

compute specname = 'All Delegated'.
compute SpecialtyGrp = 'All Delegated'. 

AGGREGATE
 /OUTFILE=* 
/break year recid mapcode HBRESCODE HBres LA_CODE LCAname agegroup specname SpecialtyGrp treated_board IPDC cij_pattype
/Bed_Days = sum(Bed_Days)
/Total_Net_Cost = sum(Total_Net_Cost)
/Episodes = sum(Episodes).

add files file = *
/file = !file + 'HEA-MasterExtract-Main' + !year + '.zsav'.

save outfile =  !file + 'HEA-MasterExtract-Main' + !year + '.zsav'
    /zcompressed.

*Rename IPDC for aesthetics.
alter type IPDC (a9).
if IPDC eq 'A' IPDC eq 'All'.
if IPDC eq 'I' IPDC eq 'Inpatient'.
if IPDC eq 'D' IPDC eq 'Day Case'.

string LCA_HB_SCOT (A35).
compute LCA_HB_SCOT = LCAname.

*Aggregate out recid? - Bateman March 2019: I don't know why this comment is a question.

AGGREGATE
 /OUTFILE=* 
/break year HBRESCODE HBres LCA_HB_SCOT LA_CODE LCAname agegroup specname SpecialtyGrp treated_board IPDC cij_pattype
/Bed_Days = sum(Bed_Days)
/Total_Net_Cost = sum(Total_Net_Cost)
/Episodes = sum(Episodes).

save outfile =  !file + 'HEA-MasterExtract-Main' + !year + '.zsav'
    /zcompressed.

***************

get file =  !file + 'HEA-MasterExtract-Main' + !year + '.zsav'.

*Aggregate for HB totals.
if hbres= 'Ayrshire & Arran Region' LCA_HB_SCOT = 'NHS Ayrshire & Arran'.	 
if hbres ='Borders Region' LCA_HB_SCOT = 'NHS Borders Region'.	 
if hbres ='Fife Region' LCA_HB_SCOT = 'NHS Fife'.	 
if hbres ='Greater Glasgow & Clyde Region' LCA_HB_SCOT = 'NHS Greater Glasgow & Clyde'.	 		 
if hbres ='Highland Region' LCA_HB_SCOT = 'NHS Highland'.	  	 	 
if hbres ='Lanarkshire Region' LCA_HB_SCOT = 'NHS Lanarkshire'.	  	 	 	 
if hbres ='Grampian Region' LCA_HB_SCOT = 'NHS Grampian'.	 	 	 	 
if hbres ='Orkney Region' LCA_HB_SCOT = 'NHS Orkney'.	  	 	 	 
if hbres ='Shetland Region' LCA_HB_SCOT = 'NHS Shetland'.	  	 	 
if hbres ='Lothian Region' LCA_HB_SCOT = 'NHS Lothian'.	  		 
if hbres ='Tayside Region' LCA_HB_SCOT = 'NHS Tayside'.	 	 	 
if hbres ='Forth Valley Region' LCA_HB_SCOT = 'NHS Forth Valley'.	 	 
if hbres ='Western Isles Region' LCA_HB_SCOT = 'NHS Western Isles'.	 	 	 	 
if hbres ='Dumfries & Galloway Region' LCA_HB_SCOT = 'NHS Dumfries & Galloway'.	 	 	 	 	 	 

aggregate outfile = *
  /break year HBRESCODE hbres LCA_HB_SCOT agegroup specname SpecialtyGrp treated_board IPDC cij_pattype
/Bed_Days = sum(Bed_Days)
/Total_Net_Cost = sum(Total_Net_Cost)
/Episodes = sum(Episodes).

add files file = *
 /file =  !file + 'HEA-MasterExtract-Main' + !year + '.zsav'.

save outfile =  !file + 'HEA-MasterExtract-Main' + !year + '.zsav'
    /zcompressed.

get file =  !file + 'HEA-MasterExtract-Main' + !year + '.zsav'.

string HB (a35).
if any(LCA_HB_SCOT, 'East Ayrshire', 'North Ayrshire', 'South Ayrshire', 'NHS Ayrshire & Arran') hb eq 'NHS Ayrshire & Arran'.
if any(LCA_HB_SCOT, 'Scottish Borders', 'NHS Borders') hb eq 'NHS Borders'.
if any(LCA_HB_SCOT, 'Dumfries & Galloway', 'NHS Dumfries & Galloway') hb eq 'NHS Dumfries & Galloway'.
if any(LCA_HB_SCOT, 'Fife', 'NHS Fife') hb eq 'NHS Fife'.
if any(LCA_HB_SCOT, 'Clackmannanshire', 'Falkirk', 'Stirling', 'NHS Forth Valley') hb eq 'NHS Forth Valley'.
if any(LCA_HB_SCOT, 'Aberdeen City', 'Aberdeenshire', 'Moray', 'Grampian', 'NHS Grampian') hb eq 'NHS Grampian'.
if any(LCA_HB_SCOT, 'East Dunbartonshire', 'East Renfrewshire', 'Glasgow City', 'Inverclyde', 'Renfrewshire', 'West Dunbartonshire',
'NHS Greater Glasgow & Clyde') hb eq 'NHS Greater Glasgow & Clyde'.
if any(LCA_HB_SCOT, 'Argyll & Bute', 'Highland', 'NHS Highland') hb eq 'NHS Highland'.
if any(LCA_HB_SCOT, 'North Lanarkshire', 'South Lanarkshire', 'NHS Lanarkshire') hb eq 'NHS Lanarkshire'.
if any(LCA_HB_SCOT, 'City of Edinburgh', 'Midlothian', 'East Lothian', 'West Lothian', 'NHS Lothian') hb eq 'NHS Lothian'.
if any(LCA_HB_SCOT, 'Orkney Islands', 'NHS Orkney') hb eq 'NHS Orkney'.
if any(LCA_HB_SCOT, 'Shetland Islands', 'NHS Shetland') hb eq 'NHS Shetland'.
if any(LCA_HB_SCOT, 'Angus', 'Dundee City', 'Perth & Kinross', 'NHS Tayside') hb eq 'NHS Tayside'.
if any(LCA_HB_SCOT, 'Western Isles', 'NHS Western Isles') hb eq 'NHS Western Isles'.

*Flag for Specialties and Delegated Specialties.
compute AllSpecGrp = 0.

*Flags used when Specialty Groups are presented.  Keeps data at single row to avoid aggregation issues.
if any (specname, 'All', 'All Child & Adolescent Psychiatry', 'All Dental', 'All General Medicine', 'All General Pyschiatry', 'All Oral Surgery', 'All Other Medical Specialties',
'All Surgical Specialties', 'Cardiology', 'Clinical Oncology', 'Communicable Diseases', 'Dermatology', 'Gastroenterology', 'Geriatric Medicine', 'GP Other than Obstetrics', 'Haematology',
'Learning Disability', 'Medical Oncology', 'Medical Paediatrics', 'Nephrology', 'Neurology', 'Palliative Medicine', 'Psychiatry of Old Age', 'Rehabilitation Medicine', 'Respiratory Medicine',
'Restorative Dentistry', 'Rheumatology') AllSpecGrp = 1.

compute DelegatedSpecGrp = 0.

*Flags used to select delegated specialties only.
if any (specname, 'All Delegated', 'Accident & Emergency', 'Forensic Psychiatry', 'General Medicine', 'General Psychiatry', 'Geriatric Medicine',
'GP Other than Obstetrics', 'Learning Disability', 'Palliative Medicine', 'Psychiatry of Old Age', 'Rehabilitation Medicine', 'Respiratory Medicine')
DelegatedSpecGrp = 1.

compute AllSpecname = 0.

*Flags used when individual specialty names are presented.  Avoids duplication by removing "All" spec group titles.
if any (specname, 'All', 'Accident & Emergency', 'Acute Medicine', 'Adolescent Psychiatry', 'Allergy', 'Anaesthetics', 'Cardiac Surgery', 'Cardiology', 'Cardiothoracic Surgery',
'Child & Adolescent Psychiatry', 'Child Psychiatry', 'Clinical Oncology', 'Communicable Diseases', 'Community Dental Practice', 'Dermatology', 'Diabetes', 'Diagnostic Radiology',
'Ear, Nose & Throat (ENT)', 'Endocrinology', 'Endocrinology & Diabetes', 'Forensic Psychiatry', 'Gastroenterology', 'General Medicine', 'General Psychiatry', 'General Surgery',
'General Surgery (excl Vascular)', 'Geriatric Medicine', 'GP Other than Obstetrics', 'Gynaecology', 'Haematology', 'Homoeopathy', 'Immunology', 'Learning Disability', 'Medical Oncology',
'Medical Paediatrics', 'Nephrology', 'Neurology', 'Neurosurgery', 'Ophthalmology', 'Oral & Maxillofacial Surgery', 'Oral Medicine', 'Oral Surgery', 'Orthopaedics', 'Paediatric Dentistry',
'Pain Management', 'Palliative Medicine', 'Plastic Surgery', 'Psychiatry of Old Age', 'Rehabilitation Medicine', 'Respiratory Medicine', 'Restorative Dentistry', 'Rheumatology', 'Surgical Paediatrics',
'Thoracic Surgery', 'Urology', 'Vascular Surgery') AllSpecname = 1.

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

sort cases by year NRAC_PW LCA_HB_SCOT agegroup.

*Add NRAC populations.
match files file = *
/table =  '/conf/sourcedev/TableauUpdates/Hospital Expenditure and Activity/Outputs/NRACfinal.sav'
/by year NRAC_PW LCA_HB_SCOT agegroup.

save outfile =  !file + 'HEA-MasterExtract-Main' + !year + '.zsav'
    /zcompressed.

get file =   !file + 'HEA-MasterExtract-Main' + !year + '.zsav'.

*Add healthboard totals as columns to partnership rows. 

select if any(LCA_HB_SCOT, 'NHS Ayrshire & Arran', 'NHS Borders', 'NHS Dumfries & Galloway', 'NHS Fife', 'NHS Forth Valley', 'NHS Grampian', 
'NHS Greater Glasgow & Clyde', 'NHS Highland', 'NHS Lanarkshire', 'NHS Lothian', 'NHS Orkney', 'NHS Shetland', 'NHS Tayside', 'NHS Western Isles').

rename variables Bed_Days = HBBed_Days.
rename variables Total_Net_Cost = HBTotal_Net_Cost.
rename variables Episodes = HBEpisodes.
rename variables Popn = HBPopn.

sort cases by hbrescode agegroup specname SpecialtyGrp treated_board ipdc cij_pattype AllSpecGrp NRAC_PW DelegatedSpecGrp AllSpecname. 
execute.

save outfile =  !file + 'HEA-RegionTotal' + !year + '.zsav'
    /zcompressed.

get file =   !file + 'HEA-MasterExtract-Main' + !year + '.zsav'.

select if not(any(LCA_HB_SCOT, 'NHS Ayrshire & Arran', 'NHS Borders', 'NHS Dumfries & Galloway', 'NHS Fife', 'NHS Forth Valley', 'NHS Grampian', 
'NHS Greater Glasgow & Clyde', 'NHS Highland', 'NHS Lanarkshire', 'NHS Lothian', 'NHS Orkney', 'NHS Shetland', 'NHS Tayside', 'NHS Western Isles')).

sort cases by hbrescode agegroup specname SpecialtyGrp treated_board ipdc cij_pattype AllSpecGrp NRAC_PW DelegatedSpecGrp AllSpecname. 
execute.

match files file = * 
 /table =  !file + 'HEA-RegionTotal' + !year + '.zsav'
 /by  hbrescode agegroup specname SpecialtyGrp treated_board ipdc cij_pattype AllSpecGrp NRAC_PW DelegatedSpecGrp AllSpecname.
execute.

*Separate Data. 
String Data (A9).
Compute Data = 'Main'.

save outfile = !file + 'HEA-PartnershipTotal' + !year + '.zsav'
    /drop LCA_HB_SCOT
    /zcompressed.

*********************************************************************************
*Now produce hospital level data.

get file = !file + 'HEA-MasterExtract' + !Year + '.zsav'.

select if specialtygrp ne 'All MHLD'.
sort cases by location.
alter type location(a5).

*Match with list created in BO to identify Acute/Community/Mental Health care providers.
match files file =*
/table = '/conf/irf/09-Tableau-Outputs/01-Development/04-Source-Data/02-PLICS/Hosp_Services.sav'
/by location.

* Added by Bateman 03/2019.

alter type locname(a70).

*Match with lookup file to get correct Location name.
match files file = *
    /table =  '/conf/linkage/output/lookups/Unicode/National Reference Files/location.sav'
    /by location.

*Identify the Location type and Health Board of each Location using the Location Code.
string typeCode (a1).
compute typeCode = char.substr(location, 5, 1).
string LocHB (a1).
compute LocHB = char.substr(location, 1, 1).

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

frequencies variables = type.

String HB_NAME (a40).
if LocHB = 'A'           HB_NAME =       'Ayrshire & Arran Region'.
if LocHB = 'B'           HB_NAME=        'Borders Region'.
if LocHB = 'Y'           HB_NAME =       'Dumfries & Galloway Region'.
if LocHB = 'F'           HB_NAME =       'Fife Region'.
if LocHB = 'V'          HB_NAME =       'Forth Valley Region'.
if LocHB = 'N'          HB_NAME =       'Grampian Region'.
if LocHB = 'G'          HB_NAME =       'Greater Glasgow & Clyde Region'.
if LocHB = 'H'          HB_NAME =       'Highland Region'.
if LocHB = 'L'           HB_NAME =       'Lanarkshire Region'.
if LocHB = 'S'           HB_NAME =       'Lothian Region'.
if LocHB = 'R'           HB_NAME =       'Orkney Region'.
if LocHB = 'Z'           HB_NAME =       'Shetland Region'.
if LocHB = 'T'           HB_NAME =       'Tayside Region'.
if LocHB = 'W'         HB_NAME =       'Western Isles Region'.
if LocHB = 'D'          HB_NAME =       'Golden Jubilee'.
if LocHB = 'C' and hbtreatcode eq 'S08000007' HB_NAME = 'Greater Glasgow & Clyde Region'.
if LocHB = 'C' and hbtreatcode eq 'S08000008' HB_NAME = 'Highland Region'.
if LocHB = 'C' and hbtreatcode eq 'S27000001' HB_NAME = 'Private Care'.
execute.

***************************************************************************
***************************************************************************
 
string HBtreat (a40).
compute HBtreat = valuelabel(hbrescode).
if (HBtreat = 'No Fixed Abode') or
   (HBtreat = 'Not Known') or
   (HBtreat = 'Outside UK') or
   (HBtreat = 'Out-with Scotland / RUK') or
   (HBtreat = '')
   HBtreat = 'Other Non-Scottish Residents'.
if HBtreat ne 'Other Non-Scottish Residents' HBtreat = concat(HBtreat, ' Region').
compute HBtreat = replace(HBtreat, ' and ', ' & ').
compute HBtreat = replace(HBtreat, 'NHS ','').
execute.

if HB_NAME eq '' HB_NAME eq hbtreat.

frequencies variables = HB_NAME.

save outfile  = !file + 'HEA-Hospital' + !Year + '.zsav'
    /zcompressed.

*All Ages.

get file =  !file + 'HEA-Hospital' + !Year + '.zsav'.

compute agegroup ='All'.

AGGREGATE
 /OUTFILE=* 
/break year recid HBRESCODE HBres HB_Name LA_CODE LCAname location locname type agegroup specname SpecialtyGrp treated_board IPDC cij_pattype locality
acute mental_health community
/Bed_Days = sum(Bed_Days)
/Total_Net_Cost = sum(Total_Net_Cost)
/Episodes = sum(Episodes).

add files file=*
/file = !file + 'HEA-Hospital' + !year + '.zsav'.

save outfile = !file + 'HEA-Hospital' + !Year + '.zsav'
    /zcompressed.

*IPDC totals.
Get file =!file + 'HEA-Hospital' + !Year + '.zsav'.

Compute ipdc = 'A'.

AGGREGATE
 /OUTFILE=* 
/break year recid HBRESCODE HBres HB_Name LA_CODE LCAname location locname type agegroup specname SpecialtyGrp treated_board IPDC cij_pattype locality
acute mental_health community
/Bed_Days = sum(Bed_Days)
/Total_Net_Cost = sum(Total_Net_Cost)
/Episodes = sum(Episodes).

add files file=*
/file = !file + 'HEA-Hospital' + !year + '.zsav'.

save OUTFILE =!file + 'HEA-Hospital' + !Year + '.zsav'
    /zcompressed.

*All Spec Group.
get file =!file + 'HEA-Hospital' + !Year + '.zsav'.
compute SpecialtyGrp = 'All'.
compute specname = 'All'.

AGGREGATE
 /OUTFILE=* 
/break year recid HBRESCODE HBres HB_Name LA_CODE LCAname location locname type agegroup specname SpecialtyGrp treated_board IPDC cij_pattype locality
acute mental_health community
/Bed_Days = sum(Bed_Days)
/Total_Net_Cost = sum(Total_Net_Cost)
/Episodes = sum(Episodes).

add files file=*
/file = !file + 'HEA-Hospital' + !year + '.zsav'. 

save outfile  =!file + 'HEA-Hospital' + !Year + '.zsav'
    /zcompressed.

* All patient types.
get file =!file + 'HEA-Hospital' + !Year + '.zsav'.

compute cij_pattype = 'All'.

AGGREGATE
 /OUTFILE=* 
/break year recid HBRESCODE HBres HB_Name LA_CODE LCAname location locname type agegroup specname SpecialtyGrp treated_board IPDC cij_pattype locality
acute mental_health community
/Bed_Days = sum(Bed_Days)
/Total_Net_Cost = sum(Total_Net_Cost)
/Episodes = sum(Episodes).

add files file=*
/file = !file + 'HEA-Hospital' + !year + '.zsav'.  

save outfile  = !file + 'HEA-Hospital' + !Year + '.zsav'
    /zcompressed.

*All treated Boards .
get file = !file + 'HEA-Hospital' + !Year + '.zsav'.

compute treated_board = 'All'.

AGGREGATE
 /OUTFILE=* 
/break year recid HBRESCODE HBres HB_Name LA_CODE LCAname location locname type agegroup specname SpecialtyGrp treated_board IPDC cij_pattype locality
acute mental_health community
/Bed_Days = sum(Bed_Days)
/Total_Net_Cost = sum(Total_Net_Cost)
/Episodes = sum(Episodes).

add files file=*
/file = !file + 'HEA-Hospital' + !year + '.zsav'. 

save outfile = !file + 'HEA-Hospital' + !Year + '.zsav'
    /zcompressed.

get file = !file + 'HEA-Hospital' + !Year + '.zsav'.

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
/break year recid HBRESCODE HBres HB_Name LA_CODE LCAname location locname type agegroup specname SpecialtyGrp treated_board IPDC cij_pattype locality
acute mental_health community
/Bed_Days = sum(Bed_Days)
/Total_Net_Cost = sum(Total_Net_Cost)
/Episodes = sum(Episodes).

add files file=*
/file = !file + 'HEA-Hospital' + !year + '.zsav'.

save outfile = !file + 'HEA-Hospital' + !Year + '.zsav'
    /zcompressed.

get file = !file + 'HEA-Hospital' + !Year + '.zsav'.

AGGREGATE
 /OUTFILE=* 
/break year recid HBRESCODE HBres HB_Name LA_CODE LCAname location locname type agegroup specname SpecialtyGrp treated_board IPDC cij_pattype locality
acute mental_health community
/Bed_Days = sum(Bed_Days)
/Total_Net_Cost = sum(Total_Net_Cost)
/Episodes = sum(Episodes).

*Get All Delegated Specialty for selection.

get file = !file + 'HEA-Hospital' + !Year + '.zsav'.

select if any (specname, 'Accident & Emergency', 'Acute Medicine', 'Adolescent Psychiatry', 'Allergy', 'Anaesthetics', 'Cardiac Surgery', 'Cardiology', 'Cardiothoracic Surgery',
'Child & Adolescent Psychiatry', 'Child Psychiatry', 'Clinical Oncology', 'Communicable Diseases', 'Community Dental Practice', 'Dermatology', 'Diabetes', 'Diagnostic Radiology',
'Ear, Nose & Throat (ENT)', 'Endocrinology', 'Endocrinology & Diabetes', 'Forensic Psychiatry', 'Gastroenterology', 'General Medicine', 'General Psychiatry', 'General Surgery',
'General Surgery (excl Vascular)', 'Geriatric Medicine', 'GP Other than Obstetrics', 'Gynaecology', 'Haematology', 'Homoeopathy', 'Immunology', 'Learning Disability', 'Medical Oncology',
'Medical Paediatrics', 'Nephrology', 'Neurology', 'Neurosurgery', 'Ophthalmology', 'Oral & Maxillofacial Surgery', 'Oral Medicine', 'Oral Surgery', 'Orthopaedics', 'Paediatric Dentistry',
'Pain Management', 'Palliative Medicine', 'Plastic Surgery', 'Psychiatry of Old Age', 'Rehabilitation Medicine', 'Respiratory Medicine', 'Restorative Dentistry', 'Rheumatology', 'Surgical Paediatrics',
'Thoracic Surgery', 'Urology', 'Vascular Surgery').
select if any (specname, 'Accident & Emergency', 'Child & Adolescent Psychiatry', 'Child Psychiatry', 'Forensic Psychiatry', 'General Medicine', 'General Psychiatry', 'Geriatric Medicine',
'GP Other than Obstetrics', 'Learning Disability', 'Palliative Medicine', 'Psychiatry of Old Age', 'Rehabilitation Medicine', 'Respiratory Medicine', 'Adolescent Psychiatry').
select if SpecialtyGrp ne 'All MHLD'.

compute specname = 'All Delegated'.
compute SpecialtyGrp = 'All Delegated'. 

AGGREGATE
 /OUTFILE=* 
/break year recid HBRESCODE HBres HB_Name LA_CODE LCAname location locname type agegroup specname SpecialtyGrp treated_board IPDC cij_pattype locality
acute mental_health community
/Bed_Days = sum(Bed_Days)
/Total_Net_Cost = sum(Total_Net_Cost)
/Episodes = sum(Episodes).

add files file=*
/file = !file + 'HEA-Hospital' + !year + '.zsav'.

save outfile = !file + 'HEA-Hospital' + !Year + '.zsav'
    /zcompressed.

AGGREGATE
 /OUTFILE=* 
/break year HBRESCODE HBres HB_Name LA_CODE LCAname location locname type agegroup specname SpecialtyGrp treated_board IPDC cij_pattype locality
acute mental_health community
/Bed_Days = sum(Bed_Days)
/Total_Net_Cost = sum(Total_Net_Cost)
/Episodes = sum(Episodes).

save outfile = !file + 'HEA-Hospital' + !Year + '.zsav'
    /zcompressed.

get file = !file + 'HEA-Hospital' + !Year + '.zsav'.

*Rename IPDC for aesthetics.

alter type IPDC (a9).
if IPDC eq 'A' IPDC eq 'All'.
if IPDC eq 'I' IPDC eq 'Inpatient'.
if IPDC eq 'D' IPDC eq 'Day Case'.

 * frequencies variables = IPDC.

compute treat_hb_flag = 0.
if hbres eq hb_name treat_hb_flag eq 1.
if hbres ne hb_name treat_hb_flag eq 0.
execute.

*Flag for Specialties and Delegated Specialties.
compute AllSpecGrp = 0.

if any (specname, 'All', 'All Child & Adolescent Psychiatry', 'All Dental', 'All General Medicine', 'All General Pyschiatry', 'All Oral Surgery', 'All Other Medical Specialties',
'All Surgical Specialties', 'Cardiology', 'Clinical Oncology', 'Communicable Diseases', 'Dermatology', 'Gastroenterology', 'Geriatric Medicine', 'GP Other than Obstetrics', 'Haematology',
'Learning Disability', 'Medical Oncology', 'Medical Paediatrics', 'Nephrology', 'Neurology', 'Palliative Medicine', 'Psychiatry of Old Age', 'Rehabilitation Medicine', 'Respiratory Medicine',
'Restorative Dentistry', 'Rheumatology') AllSpecGrp = 1.

compute DelegatedSpecGrp = 0.

if any (specname, 'All Delegated', 'Accident & Emergency',  'Forensic Psychiatry', 'General Medicine', 'General Psychiatry', 'Geriatric Medicine',
'GP Other than Obstetrics', 'Learning Disability', 'Palliative Medicine', 'Psychiatry of Old Age', 'Rehabilitation Medicine', 'Respiratory Medicine')
DelegatedSpecGrp = 1.

*Remove non-Scots.
Select if HB_NAME ne 'Other Non Scottish Residents'.

*Separate Data. 
String Data (A9).
Compute Data = 'Hosp'.

save outfile = !file + 'HEA-Hospital' + !Year + '.zsav'
    /zcompressed.

get file = !file + 'HEA-Hospital' + !Year + '.zsav'.


*************************
*Add two main files

add files file = !file + 'HEA-Hospital' + !Year + '.zsav'
    /file =   !file + 'HEA-PartnershipTotal' + !year + '.zsav'.

save outfile = !file + 'HEA-Main' + !Year + '.sav'.

get file = !file + 'HEA-Main' + !Year + '.sav'.
