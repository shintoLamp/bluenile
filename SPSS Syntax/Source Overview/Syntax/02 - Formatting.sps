* Encoding: UTF-8.
* BM June 2021:
* This code has been taken from the older PLICSLite_Localities syntax.
* The purpose of the code is to add all financial years together and format some variables.
* Code has been added to create a small Tableau extract for use within Tabstore, and to add Clackmannanshire & Stirling as a Partnership.

*Add all years together.
define !file()
 '/conf/sourcedev/TableauUpdates/Source Overview/Outputs/'
!enddefine.

ADD FILES 
/file = !file + 'SourceOverview_1718.sav'
/file = !file + 'SourceOverview_1819.sav'
/file = !file + 'SourceOverview_1920.sav'
/file = !file + 'SourceOverview_2021.sav'.
execute.

*Remove Services which do not yet have a monthly breakdown.
select if not any(SMRType, 'NRS Deaths', 'Comm-MH').
select if not any(recid, 'CH', 'DN', 'OoH', 'DD', 'NSU').

*Save final version of file.
save outfile = !file + 'SourceOverview.sav'.
get file =  !file + 'SourceOverview.sav'.

*Add 9 digit LA Code.
String LA_CODE (a9).
if LCAname = 'Scottish Borders' LA_CODE = 'S12000026'.
if LCAname = 'Fife' LA_CODE = 'S12000015'.
if LCAname = 'Orkney Islands' LA_CODE = 'S12000023'.
if LCAname = 'Western Isles' LA_CODE = 'S12000013'.
if LCAname = 'Dumfries & Galloway' LA_CODE = 'S12000006'.
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

String SMR_Type (a40).
compute SMR_Type=valuelabel(SMRType).
if SMR_Type='Community Prescribing summary' SMR_Type='Prescribing'.
if SMR_Type='Psychiatric - Inpatient' SMR_Type='Mental Health - Inpatient'.
if SMRType='A & E' SMR_Type='A & E'.
if SMRType='Outpatient' SMR_Type='Outpatient'.

STRING IPDC_Description(a10).
STRING Clinic_Type_Description(a24).
STRING RefSource_Description(a100).
STRING Ref_Source(a55).

IF ipdc = "I" IPDC_Description = "Inpatient".
IF ipdc = "D" IPDC_Description = "Daycase".

IF clinic_type = 1 Clinic_Type_Description = "Consultant".
IF clinic_type = 2 Clinic_Type_Description = "Dental Consultant".

*GP Out Of Hours.
IF recid = "OoH" AND refsource = "1" RefSource_Description = "Walk-in".
IF recid = "OoH" AND refsource = "2" RefSource_Description = "Patient is caller".
IF recid = "OoH" AND refsource = "3" RefSource_Description = "SAS".
IF recid = "OoH" AND refsource = "4" RefSource_Description = "Family member/Neighbour/Friend/Member of the public".
IF recid = "OoH" AND refsource = "9" RefSource_Description = "Other".
IF recid = "OoH" AND refsource = "B" RefSource_Description = "HCP - CPN/District Nurse/Midwife".
IF recid = "OoH" AND refsource = "C" RefSource_Description = "HCP - Nursing Home/Care Home/Residential Home".
IF recid = "OoH" AND refsource = "D" RefSource_Description = "HCP - Chemist/Pharmacist".
IF recid = "OoH" AND refsource = "E" RefSource_Description = "HCP - Hospital".
IF recid = "OoH" AND refsource = "F" RefSource_Description = "HCP - Nurse".
IF recid = "OoH" AND refsource = "G" RefSource_Description = "HCP - Laboratory".
IF recid = "OoH" AND refsource = "H" RefSource_Description = "HCP - Doctor (GP)".
IF recid = "OoH" AND refsource = "I" RefSource_Description = "HCP - Other HCP".
IF recid = "OoH" AND refsource = "J" RefSource_Description = "GHCP - Other OoH Service".
IF recid = "OoH" AND refsource = "P" RefSource_Description = "Police/Prison".
IF recid = "OoH" AND refsource = "S" RefSource_Description = "Social services".
IF recid = "OoH" AND refsource = "A" RefSource_Description = "A&E".
IF recid = "OoH" AND refsource = "M" RefSource_Description = "MIU".
IF recid = "OoH" AND refsource = "N" RefSource_Description = "NHS".

*Outpatient.
IF recid = "00B" AND refsource = "1" RefSource_Description = "GP".
IF recid = "00B" AND refsource = "2" RefSource_Description = "Consultant at this Health Board/ Health Care Provider".
IF recid = "00B" AND refsource = "4" RefSource_Description = "Consultant from a Health Board/ Health Care Provider outwith this Health Board area".
IF recid = "00B" AND refsource = "5" RefSource_Description = "Self referral".
IF recid = "00B" AND refsource = "6" RefSource_Description = "Prison/Penal Establishments".
IF recid = "00B" AND refsource = "7" RefSource_Description = "Judicial".
IF recid = "00B" AND refsource = "8" RefSource_Description = "Local Authority/Voluntary Agency".
IF recid = "00B" AND refsource = "9" RefSource_Description = "Other (including Armed Forces)".
IF recid = "00B" AND refsource = "A" RefSource_Description = "Accident and Emergency Department".
IF recid = "00B" AND refsource = "B" RefSource_Description = "Optometrist/Optician".
IF recid = "00B" AND refsource = "C" RefSource_Description = "Allied Health Professional (AHP)".
IF recid = "00B" AND refsource = "D" RefSource_Description = "Dental Practitioner".
IF recid = "00B" AND refsource = "E" RefSource_Description = "Community Health Service (excluding Optometrist/Optician and Allied Health Professional (AHP))".
IF recid = "00B" AND refsource = "N" RefSource_Description = "NHS24".

*Accident & Emergency.
IF recid = "AE2" AND refsource = "01" RefSource_Description = "Self Referral".
IF recid = "AE2" AND refsource = "01A" RefSource_Description = "Self Referral by Patient".
IF recid = "AE2" AND refsource = "01B" RefSource_Description = "Self Referral by Associated Person".
IF recid = "AE2" AND refsource = "02" RefSource_Description = "Healthcare Professional/Service/Organisation".
IF recid = "AE2" AND refsource = "02A" RefSource_Description = "GP referral from usual GP practice".
IF recid = "AE2" AND refsource = "02B" RefSource_Description = "Out-of-Hours Services referral out-with normal working hours from a primary care OOH services".
IF recid = "AE2" AND refsource = "02C" RefSource_Description = "999 emergency services (inc SAS Paramedic Practitioner)".
IF recid = "AE2" AND refsource = "02D" RefSource_Description = "NHS24".
IF recid = "AE2" AND refsource = "02E" RefSource_Description = "Minor injuries unit".
IF recid = "AE2" AND refsource = "02F" RefSource_Description = "Same hospital (excl Minor Injuries Units)".
IF recid = "AE2" AND refsource = "02G" RefSource_Description = "Other hospital (excl Minor Injuries Units)".
IF recid = "AE2" AND refsource = "02H" RefSource_Description = "Other healthcare professional".
IF recid = "AE2" AND refsource = "02J" RefSource_Description = "GP referral for admission".
IF recid = "AE2" AND refsource = "03" RefSource_Description = "Local Authority".
IF recid = "AE2" AND refsource = "03A" RefSource_Description = "Education".
IF recid = "AE2" AND refsource = "03B" RefSource_Description = "Social Services".
IF recid = "AE2" AND refsource = "03C" RefSource_Description = "Police".
IF recid = "AE2" AND refsource = "03D" RefSource_Description = "Other local authority department".
IF recid = "AE2" AND refsource = "03E" RefSource_Description = "Local Authority - Unknown".
IF recid = "AE2" AND refsource = "04" RefSource_Description = "Private professional/agency/organisation".
IF recid = "AE2" AND refsource = "04A" RefSource_Description = "Private professional/agency/organisation".
IF recid = "AE2" AND refsource = "05" RefSource_Description = "Other agency".
IF recid = "AE2" AND refsource = "05A" RefSource_Description = "Prison/penal establishment".
IF recid = "AE2" AND refsource = "05B" RefSource_Description = "Judicial".
IF recid = "AE2" AND refsource = "05C" RefSource_Description = "Voluntary agency".
IF recid = "AE2" AND refsource = "05D" RefSource_Description = "Armed Forces".
IF recid = "AE2" AND refsource = "98" RefSource_Description = "Other".
IF recid = "AE2" AND refsource = "99" RefSource_Description = "Not Known".

*GP Out Of Hours.
IF recid = "OoH" AND refsource = "1" Ref_Source = "Walk-in".
IF recid = "OoH" AND refsource = "2" Ref_Source = "Patient is caller".
IF recid = "OoH" AND refsource = "3" Ref_Source = "SAS".
IF recid = "OoH" AND refsource = "4" Ref_Source = "Family member/Neighbour/Friend/Member of the public".
IF recid = "OoH" AND refsource = "9" Ref_Source = "Other".
IF recid = "OoH" AND refsource = "B" Ref_Source = "HCP - CPN/District Nurse/Midwife".
IF recid = "OoH" AND refsource = "C" Ref_Source = "HCP - Nursing Home/Care Home/Residential Home".
IF recid = "OoH" AND refsource = "D" Ref_Source = "HCP - Chemist/Pharmacist".
IF recid = "OoH" AND refsource = "E" Ref_Source = "HCP - Hospital".
IF recid = "OoH" AND refsource = "F" Ref_Source = "HCP - Nurse".
IF recid = "OoH" AND refsource = "G" Ref_Source = "HCP - Laboratory".
IF recid = "OoH" AND refsource = "H" Ref_Source = "HCP - Doctor (GP)".
IF recid = "OoH" AND refsource = "I" Ref_Source = "HCP - Other HCP".
IF recid = "OoH" AND refsource = "J" Ref_Source = "GHCP - Other OoH Service".
IF recid = "OoH" AND refsource = "P" Ref_Source = "Police/Prison".
IF recid = "OoH" AND refsource = "S" Ref_Source = "Social services".
IF recid = "OoH" AND refsource = "A" Ref_Source = "A&E".
IF recid = "OoH" AND refsource = "M" Ref_Source = "MIU".
IF recid = "OoH" AND refsource = "N" Ref_Source = "NHS".

*Outpatient.
IF recid = "00B" AND refsource = "1" Ref_Source = "GP".
IF recid = "00B" AND refsource = "2" Ref_Source = "Consultant - Within Health Board".
IF recid = "00B" AND refsource = "4" Ref_Source = "Consultant - Outwith Health Board".
IF recid = "00B" AND refsource = "5" Ref_Source = "Self referral".
IF recid = "00B" AND refsource = "6" Ref_Source = "Prison/Penal Establishments".
IF recid = "00B" AND refsource = "7" Ref_Source = "Judicial".
IF recid = "00B" AND refsource = "8" Ref_Source = "Local Authority/Voluntary Agency".
IF recid = "00B" AND refsource = "9" Ref_Source = "Other (including Armed Forces)".
IF recid = "00B" AND refsource = "A" Ref_Source = "A&E Department".
IF recid = "00B" AND refsource = "B" Ref_Source = "Optometrist/Optician".
IF recid = "00B" AND refsource = "C" Ref_Source = "Allied Health Professional (AHP)".
IF recid = "00B" AND refsource = "D" Ref_Source = "Dental Practitioner".
IF recid = "00B" AND refsource = "E" Ref_Source = "Community Health Service".
IF recid = "00B" AND refsource = "N" Ref_Source = "NHS24".

*Accident & Emergency.
IF recid = "AE2" AND refsource = "01" Ref_Source = "Self Referral".
IF recid = "AE2" AND refsource = "01A" Ref_Source = "Self Referral by Patient".
IF recid = "AE2" AND refsource = "01B" Ref_Source = "Self Referral by Associated Person".
IF recid = "AE2" AND refsource = "02" Ref_Source = "Healthcare Professional/Service/Organisation".
IF recid = "AE2" AND refsource = "02A" Ref_Source = "GP referral from usual GP practice".
IF recid = "AE2" AND refsource = "02B" Ref_Source = "OOH Services referral out-with normal working hours".
IF recid = "AE2" AND refsource = "02C" Ref_Source = "999 emergency services (inc SAS Paramedic Practitioner)".
IF recid = "AE2" AND refsource = "02D" Ref_Source = "NHS24".
IF recid = "AE2" AND refsource = "02E" Ref_Source = "Minor injuries unit".
IF recid = "AE2" AND refsource = "02F" Ref_Source = "Same hospital (excl Minor Injuries Units)".
IF recid = "AE2" AND refsource = "02G" Ref_Source = "Other hospital (excl Minor Injuries Units)".
IF recid = "AE2" AND refsource = "02H" Ref_Source = "Other healthcare professional".
IF recid = "AE2" AND refsource = "02J" Ref_Source = "GP referral for admission".
IF recid = "AE2" AND refsource = "03" Ref_Source = "Local Authority".
IF recid = "AE2" AND refsource = "03A" Ref_Source = "Education".
IF recid = "AE2" AND refsource = "03B" Ref_Source = "Social Services".
IF recid = "AE2" AND refsource = "03C" Ref_Source = "Police".
IF recid = "AE2" AND refsource = "03D" Ref_Source = "Other local authority department".
IF recid = "AE2" AND refsource = "03E" Ref_Source = "Local Authority - Unknown".
IF recid = "AE2" AND refsource = "04" Ref_Source = "Private professional/agency/organisation".
IF recid = "AE2" AND refsource = "04A" Ref_Source = "Private professional/agency/organisation".
IF recid = "AE2" AND refsource = "05" Ref_Source = "Other agency".
IF recid = "AE2" AND refsource = "05A" Ref_Source = "Prison/penal establishment".
IF recid = "AE2" AND refsource = "05B" Ref_Source = "Judicial".
IF recid = "AE2" AND refsource = "05C" Ref_Source = "Voluntary agency".
IF recid = "AE2" AND refsource = "05D" Ref_Source = "Armed Forces".
IF recid = "AE2" AND refsource = "98" Ref_Source = "Other".
IF recid = "AE2" AND refsource = "99" Ref_Source = "Not Known".

RENAME VARIABLES apr_beddays = april_beddays.
RENAME VARIABLES jun_beddays = june_beddays.
RENAME VARIABLES aug_beddays = august_beddays.
RENAME VARIABLES sep_beddays = sept_beddays.
RENAME VARIABLES apr_cost = april_cost.
RENAME VARIABLES jun_cost = june_cost.
RENAME VARIABLES aug_cost = august_cost.
RENAME VARIABLES sep_cost = sept_cost.

compute attendances=episodes.
alter type attendances (f7.0).
compute Episodes_Attendances=episodes.
alter type Episodes_Attendances (f7.0).

rename variables HSCPLocality=Locality.
rename variables speccode=spec.
rename variables Description=SpecName.
rename variables cij_pattype=newpattype_cis.
rename variables cij_ipdc=newcis_ipdc.

* Create C&S partnership.
string Partnership(a40).
String Clacks(a30).
if Partnership = '' Partnership = LCAname.
IF Partnership="Clackmannanshire" or Partnership="Stirling" Clacks="Clackmannanshire & Stirling".
VARSTOCASES
 /MAKE Partnership FROM Partnership Clacks.
delete variables LCAname.
rename variables Partnership = LCAname.

*Delete Non LCA.
STRING LCA_flag (A8). 
RECODE LCAname ('Non LCA'='99') (ELSE='1') INTO LCA_flag. 
VARIABLE LABELS  LCA_flag 'Flag for Non LCA'. 
EXECUTE.

select if(LCA_flag = "1").
execute.

*Save Dataset.
save outfile = !file + 'SourceOverview.sav'.
get file =  !file + 'SourceOverview.sav'.

* Create small extract for Tabstore.

sort cases by LCAname.
match files file=*
    /by LCAname
    /first TableauFlag.
Select if TableauFlag = 1.
save outfile = !file + 'SourceOverview_Tableau.sav'
/drop TableauFlag.