* Encoding: UTF-8.
*Syntax for Hospital Expenditure and Activity Workbook.
*JM Update 2017.
*BMcB update March 2019.

*Create Parameters.
DEFINE !year()
'201819'
!ENDDEFINE.

DEFINE !file()
'/conf/sourcedev/TableauUpdates/Hospital Expenditure and Activity/Outputs/'
!ENDDEFINE.

* This line ensures you create a fresh and up-to-date lookup file every run. 
* Insert file = '/conf/sourcedev/TableauUpdates/Hospital Expenditure and Activity/Development and Checking/Create lookup file.sps'.

*****************************************************************************
* Read in Source Episode File with required variables only.

* 13/03/19 Bateman - Changed some variables to fit with updates made to SLFs. 

get file =  '/conf/hscdiip/01-Source-linkage-files/source-episode-file-' + !year + '.zsav'
/keep year recid record_keydate1 record_keydate2 anon_CHI gender dob gpprac HBPRACCODE postcode HBRESCODE LCA HBTREATCODE location
yearstay STAY IPDC SPEC SIGFAC TADM smr01_cis_marker cij_pattype age DIAG1 cij_marker cij_admtype Cost_Total_Net
simd2020_HSCP2019_decile datazone2011.

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

*Get Specialty Names.
string specname (a40).
if spec eq 'A1' specname eq 'General Medicine'.
if spec eq 'A11' specname eq 'Acute Medicine'.
if spec eq 'A2' specname eq 'Cardiology'.
if spec eq 'A3' specname eq 'Clinical Genetics'.
if spec eq 'A5' specname eq 'Clinical Pharmacology & Therapeutics'.
if spec eq 'A6' specname eq 'Communicable Diseases'.
if spec eq 'A7' specname eq 'Dermatology'.
if spec eq 'A8' specname eq 'Endocrinology & Diabetes'.
if spec eq 'A81' specname eq 'Endocrinology'.
if spec eq 'A82' specname eq 'Diabetes'.
if spec eq 'A9' specname eq 'Gastroenterology'.
if spec eq 'AA' specname eq 'Genito-Urinary Medicine'.
if spec eq 'AB' specname eq 'Geriatric Medicine'.
if spec eq 'AC' specname eq 'Homoeopathy'.
if spec eq 'AD' specname eq 'Medical Oncology'.
if spec eq 'AF' specname eq 'Medical Paediatrics'.
if spec eq 'AFA' specname eq 'Community Child Health'.
if spec eq 'AG' specname eq 'Nephrology'.
if spec eq 'AH' specname eq 'Neurology'.
if spec eq 'AK' specname eq 'Occupational Health'.
if spec eq 'AM' specname eq 'Palliative Medicine'.
if spec eq 'AN' specname eq 'Public Health Medicine'.
if spec eq 'AP' specname eq 'Rehabilitation Medicine'.
if spec eq 'AQ' specname eq 'Respiratory Medicine'.
if spec eq 'AR' specname eq 'Rheumatology'.
if spec eq 'AW' specname eq 'Allergy'.
if spec eq 'C1' specname eq 'General Surgery'.
if spec eq 'C11' specname eq 'General Surgery (excl Vascular)'.
if spec eq 'C12' specname eq 'Vascular Surgery'.
if spec eq 'C13' specname eq 'Oral & Maxillofacial Surgery'.
if spec eq 'C2' specname eq 'Accident & Emergency'.
if spec eq 'C3' specname eq 'Anaesthetics'.
if spec eq 'C31' specname eq 'Pain Management'.
if spec eq 'C4' specname eq 'Cardiothoracic Surgery'.
if spec eq 'C41' specname eq 'Cardiac Surgery'.
if spec eq 'C42' specname eq 'Thoracic Surgery'.
if spec eq 'C5' specname eq 'Ear, Nose & Throat (ENT)'.
if spec eq 'C6' specname eq 'Neurosurgery'.
if spec eq 'C7' specname eq 'Ophthalmology'.
if spec eq 'C8' specname eq 'Orthopaedics'.
if spec eq 'C9' specname eq 'Plastic Surgery'.
if spec eq 'CA' specname eq 'Surgical Paediatrics'.
if spec eq 'CB' specname eq 'Urology'.
if spec eq 'D1' specname eq 'Community Dental Practice'.
if spec eq 'D2' specname eq 'General Dental Practice'.
if spec eq 'D3' specname eq 'Oral Surgery'.
if spec eq 'D4' specname eq 'Oral Medicine'.
if spec eq 'D5' specname eq 'Orthodontics'.
if spec eq 'D6' specname eq 'Restorative Dentistry'.
if spec eq 'D7' specname eq 'Dental Public Health'.
if spec eq 'D8' specname eq 'Paediatric Dentistry'.
if spec eq 'E1' specname eq 'General Practice'.
if spec eq 'E11' specname eq 'GP Obstetrics'.
if spec eq 'E12' specname eq 'GP Other than Obstetrics'.
if spec eq 'F1' specname eq 'Obstetrics & Gynaecology'.
if spec eq 'F1A' specname eq 'Well Woman Service'.
if spec eq 'F1B' specname eq 'Family Planning Service'.
if spec eq 'F2' specname eq 'Gynaecology'.
if spec eq 'F3' specname eq 'Obstetrics'.
if spec eq 'F31' specname eq 'Obstetrics Ante-Natal'.
if spec eq 'F32' specname eq 'Obstetrics Post-Natal'.
if spec eq 'G1' specname eq 'General Psychiatry'.
if spec eq 'G1A' specname eq 'Community Psychiatry'.
if spec eq 'G2' specname eq 'Child & Adolescent Psychiatry'.
if spec eq 'G21' specname eq 'Child Psychiatry'.
if spec eq 'G22' specname eq 'Adolescent Psychiatry'.
if spec eq 'G3' specname eq 'Forensic Psychiatry'.
if spec eq 'G4' specname eq 'Psychiatry of Old Age'.
if spec eq 'G5' specname eq 'Learning Disability'.
if spec eq 'G6' specname eq 'Psychotherapy'.
if spec eq 'H1' specname eq 'Diagnostic Radiology'.
if spec eq 'H1A' specname eq 'Breast Screening Service'.
if spec eq 'H2' specname eq 'Clinical Oncology'.
if spec eq 'H3' specname eq 'Nuclear Medicine'.
if spec eq 'J1' specname eq 'Pathology'.
if spec eq 'J2' specname eq 'Blood Transfusion'.
if spec eq 'J3' specname eq 'Clinical Chemistry'.
if spec eq 'J4' specname eq 'Haematology'.
if spec eq 'J5' specname eq 'Immunology'.
if spec eq 'J6' specname eq 'Microbiology'.
if spec eq 'J7' specname eq 'Virology'.
if spec eq 'R1' specname eq 'Chiropodists / podiatrists'.
if spec eq 'R11' specname eq 'Surgical Podiatrists'.
if spec eq 'R2' specname eq 'Clinical psychologists'.
if spec eq 'R3' specname eq 'Dieticians'.
if spec eq 'R4' specname eq 'Occupational therapists'.
if spec eq 'R41' specname eq 'Industrial therapists'.
if spec eq 'R5' specname eq 'Physiotherapists'.
if spec eq 'R6' specname eq 'Speech and language therapists'.
if spec eq 'R81' specname eq 'Hearing aids'.
if spec eq 'R82' specname eq 'Audiometry'.
if spec eq 'R9' specname eq 'Medical Physicists'.
if spec eq 'RB' specname eq 'Physiologists'.
if spec eq 'RC' specname eq 'Dental hygienists'.
if spec eq 'RD' specname eq 'Dental Surgery Assistants'.
if spec eq 'RE' specname eq 'Physiological Measurement Technicians'.
if spec eq 'RF' specname eq 'Prosthetists/orthotists'.
if spec eq 'RG' specname eq 'Dispensing opticians'.
if spec eq 'RH' specname eq 'Optometrists'.
if spec eq 'RJ' specname eq 'Orthoptists'.
if spec eq 'RK1' specname eq 'Electroencephalography'.
if spec eq 'RK2' specname eq 'Electrocardiography'.
if spec eq 'RK3' specname eq 'Ultrasonics'.
if spec eq 'RK4' specname eq 'Nuclear medicine'.
if spec eq 'RL' specname eq 'Therapeutic radiographers'.
if spec eq 'RM' specname eq 'Medical Photographers'.
if spec eq 'RS' specname eq 'Dental Therapists'.
if spec eq 'T2' specname eq 'Midwifery'.
if spec eq 'T21' specname eq 'Community Midwifery'.
if spec eq 'XSN' specname eq 'Not Known'.
if spec eq 'XSU' specname eq 'Unspecified'.
if spec eq 'XX' specname eq 'Others'.

*Get Specialty Groups.
string SpecialtyGrp (a50).
* General surgery - C1 to C11 description.
do if any(spec, 'C1','C11').
compute SpecialtyGrp = 'General Surgery (excludes Vascular) - Grp'.
 /* Cardiothoracic surgery - C4 to C41 description*/.
else if any(spec, 'C4','C41').
compute SpecialtyGrp = 'Cardiac Surgery - Grp'.
/* Oral surgery*/.
else if any(spec, 'D3','D4').
compute SpecialtyGrp = 'Oral Surgery & Medicine - Grp'.
/* ENT inc Audiology */.
else if any(spec, 'C5','C51').
compute SpecialtyGrp = 'Ear, Nose & Throat - Grp'.
/* General medicine inc Acute medicine*/.
else if any(spec, 'A1','A11').
compute SpecialtyGrp = 'General Medicine - Grp'.
/* Anaesthetics inc Pain management */.
else if any(spec, 'C3','C31').
compute SpecialtyGrp = 'Anaesthetics - Grp'.
/* Dental */.
else if any(spec, 'D1','D5','D6','D8').
compute SpecialtyGrp = 'Dental - Grp'.
/* General Psychiatry (inc Forensic)*/.
else if any(spec,'G1','G3').
compute SpecialtyGrp = 'General Psychiatry - Grp'.
/* Child and Adolescent Psychiatry group all 3 specialties together*/.
else if any(spec,'G2','G21','G22').
compute SpecialtyGrp = 'Child & Adolescent Psychiatry - Grp'.
/* Obstetrics Specialist as per Costs book*/.
else if any(spec,'F3','F31','F32','T2','T21').
compute SpecialtyGrp = 'Obstetrics Specialist - Grp'.
/* various small medical specialties cf CB line 345 (however palliative care kept separate here as over £10m)*/.
else if any(spec,'A8' ,'A81' ,'A82', 'AA', 'AC', 'AW' ,'H1', 'J5').
compute SpecialtyGrp = 'Other medical specialties - Grp'.
ELSE.
compute SpecialtyGrp = specname.
end if.

if (substr(spec,1,1) = 'C' or spec= 'F2') SpecialtyGrp = 'Surgical Specialties & Anaesthetics - Grp'.
 * frequencies specialtygrp.

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
string LCAname (a25).
if LCA eq '01' LCAname eq 'Aberdeen City'.
if LCA eq '02' LCAname eq 'Aberdeenshire'.
if LCA eq '03' LCAname eq 'Angus'.
if LCA eq '04' LCAname eq 'Argyll & Bute'.
if LCA eq '05' LCAname eq 'Scottish Borders'.
if LCA eq '06' LCAname eq 'Clackmannanshire'.
if LCA eq '07' LCAname eq 'West Dunbartonshire'.
if LCA eq '08' LCAname eq 'Dumfries & Galloway'.
if LCA eq '09' LCAname eq 'Dundee City'.
if LCA eq '10' LCAname eq 'East Ayrshire'.
if LCA eq '11' LCAname eq 'East Dunbartonshire'.
if LCA eq '12' LCAname eq 'East Lothian'.
if LCA eq '13' LCAname eq 'East Renfrewshire'.
if LCA eq '14' LCAname eq 'City of Edinburgh'.
if LCA eq '15' LCAname eq 'Falkirk'.
if LCA eq '16' LCAname eq 'Fife'.
if LCA eq '17' LCAname eq 'Glasgow City'.
if LCA eq '18' LCAname eq 'Highland'.
if LCA eq '19' LCAname eq 'Inverclyde'.
if LCA eq '20' LCAname eq 'Midlothian'.
if LCA eq '21' LCAname eq 'Moray'.
if LCA eq '22' LCAname eq 'North Ayrshire'.
if LCA eq '23' LCAname eq 'North Lanarkshire'.
if LCA eq '24' LCAname eq 'Orkney'.
if LCA eq '25' LCAname eq 'Perth & Kinross'.
if LCA eq '26' LCAname eq 'Renfrewshire'.
if LCA eq '27' LCAname eq 'Shetland'.
if LCA eq '28' LCAname eq 'South Ayrshire'.
if LCA eq '29' LCAname eq 'South Lanarkshire'.
if LCA eq '30' LCAname eq 'Stirling'.
if LCA eq '31' LCAname eq 'West Lothian'.
if LCA eq '32' LCAname eq 'Western Isles'.
if LCAname = '' LCAname = 'Non LCA'.

if hbres= 'Ayrshire & Arran Region' and (LCAname ne 'East Ayrshire'	and LCAname ne 'North Ayrshire'	and LCAname ne	'South Ayrshire')	LCAname='Non LCA'.	 	 	 	 
if hbres ='Borders Region' and LCAname ne 'Scottish Borders'	LCAname='Non LCA'.
if hbres ='Fife Region' and (LCAname ne 'Fife')	LCAname='Non LCA'.	 	 	 	 
if hbres ='Greater Glasgow & Clyde Region' and (LCAname ne 'East Dunbartonshire'	and LCAname ne 'East Renfrewshire' and LCAname ne	'Glasgow City' and LCAname ne 'Inverclyde' 
and LCAname ne	'Renfrewshire'	and LCAname ne 'West Dunbartonshire' and LCAname ne 'North Lanarkshire' and LCAname ne 'South Lanarkshire' )	LCAname='Non LCA'.	 		 
if hbres ='Highland Region' and (LCAname ne 'Argyll & Bute' and LCAname ne	'Highland')	LCAname='Non LCA'.	 	 	 	 	 
if hbres ='Lanarkshire Region' and (LCAname ne 'North Lanarkshire' and LCAname ne	'South Lanarkshire')	LCAname='Non LCA'.	 	 	 	 	 
if hbres ='Grampian Region' and (LCAname ne 'Aberdeen City' and LCAname ne	'Aberdeenshire' and LCAname ne	'Moray')	LCAname='Non LCA'.	 		 	 	 
if hbres ='Orkney Region' and LCAname ne 'Orkney' LCAname='Non LCA'.	 	 	 	 	 	 	 
if hbres ='Shetland Region' and LCAname ne 'Shetland' LCAname='Non LCA'.	 	 	 	 	 	 	 
if hbres ='Lothian Region' and (LCAname ne 'City of Edinburgh' and LCAname ne 'East Lothian' and LCAname ne 'Midlothian' and LCAname ne	'West Lothian')	LCAname='Non LCA'.	 		 
if hbres ='Tayside Region' and (LCAname ne 'Angus' and LCAname ne	'Dundee City' and LCAname ne 'Perth & Kinross')	LCAname='Non LCA'.	 		 	 
if hbres ='Forth Valley Region' and (LCAname ne 'Falkirk'	and LCAname ne 'Clackmannanshire' and LCAname ne 'Stirling')	LCAname='Non LCA'.	 		 
if hbres ='Western Isles Region' and LCAname ne 'Western Isles'	LCAname='Non LCA'.	 	 	 	 	 	 	 
if hbres ='Dumfries & Galloway Region' and LCAname ne 'Dumfries & Galloway' LCAname='Non LCA'.	 	 	 	 	 	 	 

sort cases by gpprac.

save outfile = !file + 'MasterPLICS-Extract' + !year + '.zsav'
    /zcompressed.
get file = !file + 'MasterPLICS-Extract' + !year + '.zsav'.

********************************************************************************************************************************************************

 * CROSSTABS
  /TABLES=HBres BY LCAname
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT
  /COUNT ROUND CELL.

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

* check.
 * frequencies mapcode.

 * save outfile = !file + 'MasterPLICS-Extract' + !year + '.sav'.
 * get file = !file + 'MasterPLICS-Extract' + !year + '.sav'.

*Practices which have merged/closed.
if gpprac eq 11433 gpprac eq 11128.
if gpprac eq 20165 gpprac eq 20170.
if gpprac eq 38154 gpprac eq 38205.
if gpprac eq 40099 gpprac eq 40691.
if gpprac eq 40506 gpprac eq 40718.
if gpprac eq 49341 gpprac eq 49799.
if gpprac eq 61432 gpprac eq 61447.
if gpprac eq 62351 gpprac eq 63917.
if gpprac eq 71059 gpprac eq 71256.
If gpprac eq 78344 gpprac eq 78359.
if gpprac eq 86069 gpprac eq 86355.
if gpprac eq 90064 gpprac eq 90191.
if gpprac eq 90079 gpprac eq 90191.
if gpprac eq 20240 gpprac eq 20254.
if gpprac eq 25563 gpprac eq 25864.
if gpprac eq 25578 gpprac eq 25864.
if gpprac eq 38031 gpprac eq 38210.
if gpprac eq 38099 gpprac eq 38224.
if gpprac eq 46199 gpprac eq 46606.
if gpprac eq 49657 gpprac eq 49799.
if gpprac eq 52311 gpprac eq 52414.
if gpprac eq 52363 gpprac eq 52414.
if gpprac eq 52378 gpprac eq 40718.
if gpprac eq 61127 gpprac eq 61490.
if gpprac eq 61428 gpprac eq 61490.
if gpprac eq 62331 gpprac eq 63917.
if gpprac eq 78096 gpprac eq 78185.
if gpprac eq 80664 gpprac eq 80927.
if gpprac eq 80912 gpprac eq 80927.

*Add 9 digit LA Code.
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

 * CROSSTABS
  /TABLES=LA_CODE BY LCAname
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT
  /COUNT ROUND CELL.

*save outfile to bring back later for GP level analysis.

save outfile =  !file + 'MasterPLICS-GPExtract' + !year + '.zsav'
    /zcompressed.

get file = !file + 'MasterPLICS-GPExtract' + !year + '.zsav'.

*************************************************************************************************************************************************************************************************************.

aggregate outfile = *
/break year recid mapcode HBRESCODE HBTREATCODE HBres LCA LCAname LA_CODE location agegroup specname SpecialtyGrp treated_board IPDC cij_pattype locality
/Bed_Days = sum(yearstay)
/Total_Net_Cost = sum(Cost_Total_Net)
/Episodes = sum(EpCount).

save outfile = !file + 'MasterPLICS-Extract' + !year + '.zsav'
    /zcompressed.

***********
*Create main file for Dasboards 1 and 2.

get file = !file + 'MasterPLICS-Extract' + !year + '.zsav'.

*Remove Localities.

AGGREGATE
 /OUTFILE=* 
  /break year recid mapcode HBRESCODE HBres LA_CODE LCAname agegroup specname SpecialtyGrp  treated_board IPDC cij_pattype
/Bed_Days = sum(Bed_Days)
/Total_Net_Cost = sum(Total_Net_Cost)
/Episodes = sum(Episodes).

save outfile = !file + 'MasterPLICS-Extract_Main' + !year + '.zsav'
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
/file= !file + 'MasterPLICS-Extract_Main' + !year + '.zsav'.

save outfile = !file + 'MasterPLICS-Extract_Main' + !year + '.zsav'
    /zcompressed.

*IPDC totals.

Get file = !file + 'MasterPLICS-Extract_Main' + !year + '.zsav'.

Compute ipdc = 'A'.

AGGREGATE
 /OUTFILE=* 
 /break year recid mapcode HBRESCODE HBres LA_CODE LCAname agegroup specname SpecialtyGrp  treated_board IPDC cij_pattype
/Bed_Days = sum(Bed_Days)
/Total_Net_Cost = sum(Total_Net_Cost)
/Episodes = sum(Episodes).

add files file= *
/file=  !file + 'MasterPLICS-Extract_Main' + !year + '.zsav'.
exe.

SAVE OUTFILE = !file + 'MasterPLICS-Extract_Main' + !year + '.zsav'
    /zcompressed.
execute.

*All Spec Group.
get file = !file + 'MasterPLICS-Extract_Main' + !year + '.zsav'.
compute SpecialtyGrp = 'All'.
compute specname = 'All'.

AGGREGATE
 /OUTFILE=* 
 /break year recid mapcode HBRESCODE HBres LA_CODE LCAname agegroup specname SpecialtyGrp  treated_board IPDC cij_pattype
/Bed_Days = sum(Bed_Days)
/Total_Net_Cost = sum(Total_Net_Cost)
/Episodes = sum(Episodes).

add files file = *
/file = !file + 'MasterPLICS-Extract_Main' + !year + '.zsav'.

save outfile  =  !file + 'MasterPLICS-Extract_Main' + !year + '.zsav'
    /zcompressed.
execute.

get file =  !file + 'MasterPLICS-Extract_Main' + !year + '.zsav'.

*All Patient Types.
compute cij_pattype = 'All'.

AGGREGATE
 /OUTFILE=* 
/break year recid mapcode HBRESCODE HBres LA_CODE LCAname agegroup specname SpecialtyGrp treated_board IPDC cij_pattype
/Bed_Days = sum(Bed_Days)
/Total_Net_Cost = sum(Total_Net_Cost)
/Episodes = sum(Episodes).

add files file = *
/file =   !file + 'MasterPLICS-Extract_Main' + !year + '.zsav'.
execute.

save outfile  = !file + 'MasterPLICS-Extract_Main' + !year + '.zsav'
    /zcompressed.
execute.

*All treated Boards .
get file = !file + 'MasterPLICS-Extract_Main' + !year + '.zsav'.

compute treated_board = 'All'.

AGGREGATE
 /OUTFILE=* 
/break year recid mapcode HBRESCODE HBres LA_CODE LCAname agegroup specname SpecialtyGrp treated_board IPDC cij_pattype
/Bed_Days = sum(Bed_Days)
/Total_Net_Cost = sum(Total_Net_Cost)
/Episodes = sum(Episodes).

add files file = *
/file =  !file + 'MasterPLICS-Extract_Main' + !year + '.zsav'.
execute.

save outfile =  !file + 'MasterPLICS-Extract_Main' + !year + '.zsav'
    /zcompressed.

get file =  !file + 'MasterPLICS-Extract_Main' + !year + '.zsav'.

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
/file =  !file + 'MasterPLICS-Extract_Main' + !year + '.zsav'.  
execute.

save outfile =  !file + 'MasterPLICS-Extract_Main' + !year + '.zsav'
    /zcompressed.


*Get All Delegated Specialty for selection.
get file =  !file + 'MasterPLICS-Extract_Main' + !year + '.zsav'.

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
/file = !file + 'MasterPLICS-Extract_Main' + !year + '.zsav'.

save outfile =  !file + 'MasterPLICS-Extract_Main' + !year + '.zsav'
    /zcompressed.

*Rename IPDC for astheatics.
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

save outfile =  !file + 'MasterPLICS-Extract_Main' + !year + '.zsav'
    /zcompressed.

***************

get file =  !file + 'MasterPLICS-Extract_Main' + !year + '.zsav'.

********************
*********************

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
 /file =  !file + 'MasterPLICS-Extract_Main' + !year + '.zsav'.

save outfile =  !file + 'MasterPLICS-Extract_Main' + !year + '.zsav'
    /zcompressed.

*******************************************************
*******************************************************
*******************************************************

get file =  !file + 'MasterPLICS-Extract_Main' + !year + '.zsav'.

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
if any(LCA_HB_SCOT, 'Orkney', 'NHS Orkney') hb eq 'NHS Orkney'.
if any(LCA_HB_SCOT, 'Shetland', 'NHS Shetland') hb eq 'NHS Shetland'.
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

save outfile =  !file + 'MasterPLICS-Extract_Main' + !year + '.zsav'
    /zcompressed.

get file =   !file + 'MasterPLICS-Extract_Main' + !year + '.zsav'.

*Add healthboard totals as columns to partnership rows. 

select if any(LCA_HB_SCOT, 'NHS Ayrshire & Arran', 'NHS Borders', 'NHS Dumfries & Galloway', 'NHS Fife', 'NHS Forth Valley', 'NHS Grampian', 
'NHS Greater Glasgow & Clyde', 'NHS Highland', 'NHS Lanarkshire', 'NHS Lothian', 'NHS Orkney', 'NHS Shetland', 'NHS Tayside', 'NHS Western Isles').
exe.

rename variables Bed_Days = HBBed_Days.
rename variables Total_Net_Cost = HBTotal_Net_Cost.
rename variables Episodes = HBEpisodes.
rename variables Popn = HBPopn.

sort cases by hbrescode agegroup specname SpecialtyGrp treated_board ipdc cij_pattype AllSpecGrp NRAC_PW DelegatedSpecGrp AllSpecname. 
execute.

save outfile =  !file + 'PLICS_Region_Total_' + !year + '.zsav'
    /zcompressed.

get file =   !file + 'MasterPLICS-Extract_Main' + !year + '.zsav'.

select if not(any(LCA_HB_SCOT, 'NHS Ayrshire & Arran', 'NHS Borders', 'NHS Dumfries & Galloway', 'NHS Fife', 'NHS Forth Valley', 'NHS Grampian', 
'NHS Greater Glasgow & Clyde', 'NHS Highland', 'NHS Lanarkshire', 'NHS Lothian', 'NHS Orkney', 'NHS Shetland', 'NHS Tayside', 'NHS Western Isles')).

sort cases by hbrescode agegroup specname SpecialtyGrp treated_board ipdc cij_pattype AllSpecGrp NRAC_PW DelegatedSpecGrp AllSpecname. 
execute.

*** Problem - this command is claiming that the two files mentioned are not sorted in the same way. However on line 746 we sort region total in the exact
*** same way as the main extract is sorted on line 756. Similarly, the match files command on line 764 asks for the matches to be made in that same order.

match files file = * 
 /table =  !file + 'PLICS_Region_Total_' + !year + '.zsav'
 /by  hbrescode agegroup specname SpecialtyGrp treated_board ipdc cij_pattype AllSpecGrp NRAC_PW DelegatedSpecGrp AllSpecname.
execute.

*Separate Data. 
String Data (A9).
Compute Data = 'Main'.

save outfile = !file + 'PLICS_PART_Total_' + !year + '.zsav'
    /drop LCA_HB_SCOT
    /zcompressed.

get file =  !file + 'PLICS_PART_Total_' + !year + '.zsav'.

*********************************************************************************
*Now produce hospital level data.

get file = !file + 'MasterPLICS-Extract' + !Year + '.zsav'.

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
    /table =  '/conf/linkage/output/lookups/Data Management/standard reference files/location.sav'
    /by location.

*Identify the Location type and Health Board of each Location using the Location Code.
string typeCode (a1).
compute typeCode = substr(location, 5, 1).
string LocHB (a1).
compute LocHB = substr(location, 1, 1).

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

save outfile  = !file + 'PLICS-Hospital_' + !Year + '.zsav'
    /zcompressed.

*All Ages.

get file =  !file + 'PLICS-Hospital_' + !Year + '.zsav'.

compute agegroup ='All'.

AGGREGATE
 /OUTFILE=* 
/break year recid HBRESCODE HBres HB_Name LA_CODE LCAname location locname type agegroup specname SpecialtyGrp treated_board IPDC cij_pattype locality
acute mental_health community
/Bed_Days = sum(Bed_Days)
/Total_Net_Cost = sum(Total_Net_Cost)
/Episodes = sum(Episodes).

save OUTFILE =!file + 'PLICS_IPDC_only_TAgeAll.zsav'
    /zcompressed.

add files file= !file + 'PLICS-Hospital_' + !Year + '.zsav'
/file= !file + 'PLICS_IPDC_only_TAgeAll.zsav'.

save outfile = !file + 'PLICS-Hospital_' + !Year + '.zsav'
    /zcompressed.


*All Location.
*get file = '/conf/linkage/output/keirro/PLICS-Hospital_1516.sav'.
*compute location = 'All'.
*compute summary = 'All'.

*frequencies variables = location summary.

*AGGREGATE
 /OUTFILE=* 
/break year recid HBRESCODE HBres HB_Name LA_CODE LCAname location locname type agegroup specname SpecialtyGrp treated_board IPDC cij_pattype
acute mental_health community
/Bed_Days = sum(Bed_Days)
/Total_Net_Cost = sum(Total_Net_Cost)
/Episodes = sum(Episodes).

*SAVE OUTFILE =  '/conf/linkage/output/keirro/PLCS_LOC_A.sav'
/compressed.

*add files file= '/conf/linkage/output/keirro/PLICS-Hospital_1516.sav'
/file=  '/conf/linkage/output/keirro/PLCS_LOC_A.sav'.

*save outfile ='/conf/linkage/output/keirro/PLICS-Hospital_1516.sav'
/compressed.

*IPDC totals.
Get file =!file + 'PLICS-Hospital_' + !Year + '.zsav'.

Compute ipdc = 'A'.

AGGREGATE
 /OUTFILE=* 
/break year recid HBRESCODE HBres HB_Name LA_CODE LCAname location locname type agegroup specname SpecialtyGrp treated_board IPDC cij_pattype locality
acute mental_health community
/Bed_Days = sum(Bed_Days)
/Total_Net_Cost = sum(Total_Net_Cost)
/Episodes = sum(Episodes).

save OUTFILE = !file + 'PLCS_IPDC_A.zsav'
    /zcompressed.

add files file=!file + 'PLICS-Hospital_' + !Year + '.zsav'
    /file= !file + 'PLCS_IPDC_A.zsav'.

save OUTFILE =!file + 'PLICS-Hospital_' + !Year + '.zsav'
    /zcompressed.

*All Spec Group.
get file =!file + 'PLICS-Hospital_' + !Year + '.zsav'.
compute SpecialtyGrp = 'All'.
compute specname = 'All'.

AGGREGATE
 /OUTFILE=* 
/break year recid HBRESCODE HBres HB_Name LA_CODE LCAname location locname type agegroup specname SpecialtyGrp treated_board IPDC cij_pattype locality
acute mental_health community
/Bed_Days = sum(Bed_Days)
/Total_Net_Cost = sum(Total_Net_Cost)
/Episodes = sum(Episodes).

save outfile = !file + 'PLICS_SpecialtyGrp_All.zsav'     
    /zcompressed.

add files file =!file + 'PLICS-Hospital_' + !Year + '.zsav'
    /file = !file + 'PLICS_SpecialtyGrp_All.zsav'.    

save outfile  =!file + 'PLICS-Hospital_' + !Year + '.zsav'
    /zcompressed.

get file =!file + 'PLICS-Hospital_' + !Year + '.zsav'.

*All patient types.

compute cij_pattype = 'All'.

AGGREGATE
 /OUTFILE=* 
/break year recid HBRESCODE HBres HB_Name LA_CODE LCAname location locname type agegroup specname SpecialtyGrp treated_board IPDC cij_pattype locality
acute mental_health community
/Bed_Days = sum(Bed_Days)
/Total_Net_Cost = sum(Total_Net_Cost)
/Episodes = sum(Episodes).

save outfile =!file + 'PLICS_IPDC_Adm_All.zsav'     
    /zcompressed.

add files file =!file + 'PLICS-Hospital_' + !Year + '.zsav'
/file =!file + 'PLICS_IPDC_Adm_All.zsav'.    

save outfile  = !file + 'PLICS-Hospital_' + !Year + '.zsav'
    /zcompressed.

*All treated Boards .
get file = !file + 'PLICS-Hospital_' + !Year + '.zsav'.

compute treated_board = 'All'.

AGGREGATE
 /OUTFILE=* 
/break year recid HBRESCODE HBres HB_Name LA_CODE LCAname location locname type agegroup specname SpecialtyGrp treated_board IPDC cij_pattype locality
acute mental_health community
/Bed_Days = sum(Bed_Days)
/Total_Net_Cost = sum(Total_Net_Cost)
/Episodes = sum(Episodes).

save outfile = !file + 'PLICS_IPDC_TBoard_All.zsav'     
    /zcompressed.

add files file = !file + 'PLICS-Hospital_' + !Year + '.zsav'
    /file = !file + 'PLICS_IPDC_TBoard_All.zsav'.    

save outfile = !file + 'PLICS-Hospital_' + !Year + '.zsav'
    /zcompressed.
get file = !file + 'PLICS-Hospital_' + !Year + '.zsav'.

*Due to population aggrigation issues in Tableau, Spcialy groups need an 'All Specialty' for filtering.
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

save outfile = !file + 'PLICS_IPDC_SpecAll.zsav'
    /zcompressed.

add files file = !file + 'PLICS-Hospital_' + !Year + '.zsav'
    /file = !file + 'PLICS_IPDC_SpecAll.zsav'.    

save outfile = !file + 'PLICS-Hospital_' + !Year + '.zsav'
    /zcompressed.
get file = !file + 'PLICS-Hospital_' + !Year + '.zsav'.

AGGREGATE
 /OUTFILE=* 
/break year recid HBRESCODE HBres HB_Name LA_CODE LCAname location locname type agegroup specname SpecialtyGrp treated_board IPDC cij_pattype locality
acute mental_health community
/Bed_Days = sum(Bed_Days)
/Total_Net_Cost = sum(Total_Net_Cost)
/Episodes = sum(Episodes).

*Get All Delegated Specialty for selection.

get file = !file + 'PLICS-Hospital_' + !Year + '.zsav'.

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
execute.

FREQUENCIES specname.

******************************************************************

compute specname = 'All Delegated'.
compute SpecialtyGrp = 'All Delegated'. 

AGGREGATE
 /OUTFILE=* 
/break year recid HBRESCODE HBres HB_Name LA_CODE LCAname location locname type agegroup specname SpecialtyGrp treated_board IPDC cij_pattype locality
acute mental_health community
/Bed_Days = sum(Bed_Days)
/Total_Net_Cost = sum(Total_Net_Cost)
/Episodes = sum(Episodes).

save outfile = !file + 'PLICS_IPDC_Delegated.zsav'
    /zcompressed.

add files file = !file + 'PLICS-Hospital_' + !Year + '.zsav'
    /file = !file + 'PLICS_IPDC_Delegated.zsav'.

save outfile = !file + 'PLICS-Hospital_' + !Year + '.zsav'
    /zcompressed.

AGGREGATE
 /OUTFILE=* 
/break year HBRESCODE HBres HB_Name LA_CODE LCAname location locname type agegroup specname SpecialtyGrp treated_board IPDC cij_pattype locality
acute mental_health community
/Bed_Days = sum(Bed_Days)
/Total_Net_Cost = sum(Total_Net_Cost)
/Episodes = sum(Episodes).

save outfile = !file + 'PLICS-Hospital_' + !Year + '.zsav'
    /zcompressed.

get file = !file + 'PLICS-Hospital_' + !Year + '.zsav'.

*Rename IPDC for aesthetics.

alter type IPDC (a9).
if IPDC eq 'A' IPDC eq 'All'.
if IPDC eq 'I' IPDC eq 'Inpatient'.
if IPDC eq 'D' IPDC eq 'Day Case'.

frequencies variables = IPDC.

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

save outfile = !file + 'PLICS-Hospital_' + !Year + '.zsav'
    /zcompressed.

get file = !file + 'PLICS-Hospital_' + !Year + '.zsav'.


*************************
*Add two main files

add files file =   !file + 'PLICS-Hospital_' + !Year + '.zsav'
    /file =   !file + 'PLICS_PART_Total_' + !year + '.zsav'.

save outfile = !file + 'PLICS-Main' + !Year + '.sav'.
get file = !file + 'PLICS-Main' + !Year + '.sav'.
