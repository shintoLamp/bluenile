* Encoding: UTF-8.
*****************************PLICS LITE Syntax******************************.
****KR March 2017*********.
***JD January 2018********.
****Aggregates PLICS episode level files into format for use in PLICS Lite workbook in Tableau****.
****Version includes locality breakdown****.


*Set Macros.
define !file()
 '/conf/irf/09-Tableau-Outputs/01-Development/02-SPSS-Outputs/14-PLICS Overview/'
!enddefine.

Define !Year()
 '1516'
!enddefine.

*Open PLICS episode level file.
get file = '/conf/hscdiip/01-Source-linkage-files/source-episode-file-20' + !Year + '.zsav'.

*Assign names to Partnerships.
*****BEWARE - Formatting of LCA codes can change between years.  Check all Partnerships are being captured.
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
if LCAname eq '' LCAname eq 'Non LCA'.
*frequency variables = LCAname.
execute.

*Use only 2011 datazones for linking with Localities - All Localities submitted using 2001 datazone will be set as Uknown.
 * string DataZone2011(a9).
 * compute DataZone2011 = ''.
 * if any(LCAname, 'Aberdeen City', 'Aberdeenshire', 'Scottish Borders', 'Dumfries & Galloway', 'East Renfrewshire', 'Fife', 'Inverclyde', 'Moray', 'Stirling', 'Clackmannanshire', 
'South Lanarkshire', 'Dundee City', 'Angus', 'North Lanarkshire', 'Perth & Kinross', 'Western Isles') datazone eq DataZone2011.
 * exe.

sort cases by DataZone2011.

*Match on Localities by datazone.
match files file = *
/table = '/conf/linkage/output/lookups/Unicode/Geography/HSCP Locality/HSCP Localities_DZ11_Lookup_20191216.sav'
/by DataZone2011.
EXECUTE.

*Some PLICS data is missing datazones.  Recode Locality as unknown to avoid blank.
if HSCPLocality eq '' HSCPLocality eq 'Unknown'.
EXECUTE.

*alter type record_keydate1 (a8).
*string month (a2).
*compute month = substr(record_keydate1, 5, 2).
 * exe.

**Calculate episodes for each month by row.
**BEWARE ANY LAG WITH DATA COLLECTION - SOME MONTHS MAY CONTAIN NO DATA - DO NOT ANALYSE**************.
**Star our any month with no data collected.
compute jan_episodes = 0.
compute feb_episodes = 0.
compute mar_episodes = 0.
compute apr_episodes = 0.
compute may_episodes = 0.
compute jun_episodes = 0.
compute jul_episodes = 0.
compute aug_episodes = 0.
compute sep_episodes = 0.
compute oct_episodes = 0.
compute nov_episodes = 0.
compute dec_episodes = 0.
if apr_cost gt 0 apr_episodes = 1.
if may_cost gt 0 may_episodes = 1.
if jun_cost gt 0 jun_episodes = 1.
if jul_cost gt 0 jul_episodes = 1.
if aug_cost gt 0 aug_episodes = 1.
if sep_cost gt 0 sep_episodes = 1.
if oct_cost gt 0 oct_episodes = 1.
if nov_cost gt 0 nov_episodes = 1.
if dec_cost gt 0 dec_episodes = 1.
if jan_cost gt 0 jan_episodes = 1.
if feb_cost gt 0 feb_episodes = 1.
if mar_cost gt 0 mar_episodes = 1.
exe.

*Standard Age Bands.
string AgeBand (a8). 
If (Age lt 18) AgeBand eq '<18'.
If (Age ge 18 and Age le 44) AgeBand eq '18-44'.
If (Age ge 45 and Age le 64) AgeBand eq '45-64'.
If (Age ge 65 and Age le 74) AgeBand eq '65-74'.
If (Age ge 75 and Age le 84) AgeBand eq '75-84'.
If (Age ge 85) AgeBand eq '85+'.
if age eq 999 AgeBand eq 'Unknown'.
if AgeBand eq '' AgeBand eq 'Unknown'.
exe.

*New Community Health Services as Outpatient Referral Source code.
if refsource eq '0' refsource eq 'E'.
exe.

*******************Current analysis does not take into account continuous inpatient stays (CIS) - each row counts as an episode.  To take CIS into account unstar the following syntax*********.
***Save extract to come back to.
*save outfile =  !file + 'PLICS_Extract_' + !Year + '.sav'.
*get file =  !file + 'PLICS_Extract_' + !Year + '.sav'.

***Select out individuals have had an CIS and sort in order of individual and CIS.
*select if cis_marker ne ''.
*sort cases by chi cis_marker.
 * exe.

***Aggregate to reduce CIS to single rows.  This will aviod multiple episodes for an individual with mutiple rows and with the same CIS marker.
*aggregate outfile = *
/break year chi lca recid SMRType gender locality location ipdc spec
refsource clinic_type ageband newcis_ipdc newpattype_cis cis_marker
/yearstay stay no_dispensed_items cost_total_net Cost_Total_Net_incDNAs april_beddays may_beddays june_beddays july_beddays august_beddays sept_beddays oct_beddays nov_beddays dec_beddays jan_beddays
feb_beddays mar_beddays april_cost may_cost june_cost july_cost august_cost sept_cost oct_cost nov_cost dec_cost jan_cost feb_cost mar_cost jan_episodes feb_episodes mar_episodes apr_episodes may_episodes
jun_episodes jul_episodes aug_episodes sep_episodes oct_episodes nov_episodes dec_episodes
= sum(yearstay stay no_dispensed_items cost_total_net Cost_Total_Net_incDNAs april_beddays may_beddays june_beddays july_beddays august_beddays sept_beddays oct_beddays nov_beddays dec_beddays jan_beddays
feb_beddays mar_beddays april_cost may_cost june_cost july_cost august_cost sept_cost oct_cost nov_cost dec_cost jan_cost feb_cost mar_cost jan_episodes feb_episodes mar_episodes apr_episodes may_episodes
jun_episodes jul_episodes aug_episodes sep_episodes oct_episodes nov_episodes dec_episodes).

***Aggregate to get the number of episodes and reduce PLICS to a less disclosive format for Source.
*aggregate outfile = *
/break year lca recid SMRType gender locality location ipdc spec
refsource clinic_type ageband newcis_ipdc newpattype_cis
/yearstay stay no_dispensed_items cost_total_net Cost_Total_Net_incDNAs april_beddays may_beddays june_beddays july_beddays august_beddays sept_beddays oct_beddays nov_beddays dec_beddays jan_beddays
feb_beddays mar_beddays april_cost may_cost june_cost july_cost august_cost sept_cost oct_cost nov_cost dec_cost jan_cost feb_cost mar_cost jan_episodes feb_episodes mar_episodes apr_episodes may_episodes
jun_episodes jul_episodes aug_episodes sep_episodes oct_episodes nov_episodes dec_episodes
= sum(yearstay stay no_dispensed_items cost_total_net Cost_Total_Net_incDNAs april_beddays may_beddays june_beddays july_beddays august_beddays sept_beddays oct_beddays nov_beddays dec_beddays jan_beddays
feb_beddays mar_beddays april_cost may_cost june_cost july_cost august_cost sept_cost oct_cost nov_cost dec_cost jan_cost feb_cost mar_cost jan_episodes feb_episodes mar_episodes apr_episodes may_episodes
jun_episodes jul_episodes aug_episodes sep_episodes oct_episodes nov_episodes dec_episodes)
/episodes = n.

*save outfile =  !file + 'PLICS_CIS_' + !Year + '.sav'.
*get file =  !file + 'PLICS_Extract_' + !Year + '.sav'.

***Select out individuals who have not had a CIS.
*select if cis_marker eq ''.



***Aggregate to get the number of episodes and reduce PLICS to a less disclosive format for Source.
***Use if data is collected for all months.
aggregate outfile = *
/break year lca recid SMRType gender location HSCPLocality ipdc spec
refsource clinic_type ageband cij_ipdc cij_pattype
/yearstay stay no_dispensed_items cost_total_net Cost_Total_Net_incDNAs apr_beddays may_beddays jun_beddays jul_beddays aug_beddays sep_beddays oct_beddays nov_beddays dec_beddays jan_beddays
feb_beddays mar_beddays apr_cost may_cost jun_cost jul_cost aug_cost sep_cost oct_cost nov_cost dec_cost jan_cost feb_cost mar_cost jan_episodes feb_episodes mar_episodes apr_episodes may_episodes
jun_episodes jul_episodes aug_episodes sep_episodes oct_episodes nov_episodes dec_episodes
= sum(yearstay stay no_dispensed_items cost_total_net Cost_Total_Net_incDNAs apr_beddays may_beddays jun_beddays jul_beddays aug_beddays sep_beddays oct_beddays nov_beddays dec_beddays jan_beddays
feb_beddays mar_beddays apr_cost may_cost jun_cost jul_cost aug_cost sep_cost oct_cost nov_cost dec_cost jan_cost feb_cost mar_cost jan_episodes feb_episodes mar_episodes apr_episodes may_episodes
jun_episodes jul_episodes aug_episodes sep_episodes oct_episodes nov_episodes dec_episodes)
/episodes = n.

***Aggregate to get the number of episodes and reduce PLICS to a less disclosive format for Source.
***Use if data is not collected for all months.  Remove any months with no data.
 * aggregate outfile = *
/break year 
   lca 
   recid 
   SMRType 
   gender 
   location 
   locality 
   ipdc 
   spec
   refsource 
   clinic_type 
   ageband
   newcis_ipdc 
   newpattype_cis
/yearstay 
   stay no_dispensed_items 
   cost_total_net 
   Cost_Total_Net_incDNAs 
   april_beddays 
   may_beddays 
   june_beddays 
   july_beddays 
   august_beddays 
   sept_beddays 
   oct_beddays 
   nov_beddays 
   dec_beddays
   jan_beddays
   feb_beddays   
   mar_beddays
   april_cost 
   may_cost 
   june_cost 
   july_cost 
   august_cost 
   sept_cost 
   oct_cost 
   nov_cost 
   dec_cost
   jan_cost
   feb_cost
   mar_cost  
   apr_episodes 
   may_episodes
   jun_episodes 
   jul_episodes 
   aug_episodes 
   sep_episodes 
   oct_episodes 
   nov_episodes 
   dec_episodes
   jan_episodes
   feb_episodes
   mar_episodes
   = sum(yearstay 
   stay 
   no_dispensed_items 
   cost_total_net 
   Cost_Total_Net_incDNAs 
   april_beddays 
   may_beddays 
   june_beddays 
   july_beddays 
   august_beddays 
   sept_beddays 
   oct_beddays 
   nov_beddays 
   dec_beddays
   jan_beddays
   feb_beddays   
   mar_beddays
   april_cost 
   may_cost 
   june_cost 
   july_cost 
   august_cost 
   sept_cost 
   oct_cost 
   nov_cost 
   dec_cost  
   jan_cost
   feb_cost
   mar_cost  
   apr_episodes 
   may_episodes
   jun_episodes 
   jul_episodes 
   aug_episodes 
   sep_episodes 
   oct_episodes 
   nov_episodes 
   dec_episodes
   jan_episodes
   feb_episodes
   mar_episodes)
/episodes = n.



***Add indiduals who have and have not had a CIS.
*add files file = *
/file =  !file + 'PLICS_CIS_' + !Year + '.sav'.
 * exe.

***Remove temp files to save space.
*erase file =  !file + 'PLICS_CIS_' + !Year + '.sav'.
*erase file =  !file + 'PLICS_Extract_' + !Year + '.sav'.

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
frequency variables = LCAname.

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

frequencies variables = HBname.

String HB_CODE (a9).

if HBname = 'Ayrshire & Arran Region'              HB_CODE =         'S08000015'.
if HBname = 'Borders Region'                       HB_CODE =         'S08000016'.
if HBname = 'Dumfries & Galloway Region'           HB_CODE =         'S08000017'.
if HBname = 'Fife Region'                          HB_CODE =         'S08000018'.
if HBname = 'Forth Valley Region'                  HB_CODE =         'S08000019'.
if HBname = 'Grampian Region'                      HB_CODE =         'S08000020'.
if HBname = 'Greater Glasgow & Clyde Region'       HB_CODE =         'S08000021'.
if HBname = 'Highland Region'                      HB_CODE =         'S08000022'.
if HBname = 'Lanarkshire Region'                   HB_CODE =         'S08000023'.
if HBname = 'Lothian Region'                       HB_CODE =         'S08000024'.
if HBname = 'Orkney Region'                        HB_CODE =         'S08000025'.
if HBname = 'Shetland Region'                      HB_CODE =         'S08000026'.
if HBname = 'Tayside Region'                       HB_CODE =         'S08000027'.
if HBname = 'Western Isles Region'                 HB_CODE =         'S08000028'.
EXECUTE.

save outfile = !file + 'PLICSLite_V4.zsav'
    /ZCOMPRESSED.
get file = !file + 'PLICSLite_V4.zsav'.

*Sort cases by Specialty code to match on Specialty names.
rename variables spec=speccode.
sort cases by speccode.

 * get file = '/conf/irf/09-Tableau-Outputs/01-Development/04-Source-Data/14-PLICS Overview/SpecLookup.sav'. 
 * get file ='/conf/linkage/output/lookups/Unicode/National Reference Files/Specialty_Groupings.sav'.

*Match with lookup file - BEWARE - location of lookup file may change.
match files file =*
/table = '/conf/linkage/output/lookups/Unicode/National Reference Files/Specialty_Groupings.sav'
/by speccode.
exe.

*Sort cases by location code to match on Hospital names.
sort cases by location.

ALTER TYPE location(a5).

*Match with location lookup file in clout.
match files file = *
/table =  '/conf/linkage/output/lookups/Unicode/National Reference Files/location.sav'
/by location.
exe.

*Get health board of hospital from hospital code - Used to indentify those treated at a hosptial within or outside their Health Board of Residence in Tableau.
string LocHB (a1).
compute LocHB = char.substr(location, 1, 1).
String Hosp_HB_Code (a40).
if LocHB = 'A'          Hosp_HB_Code =       'S08000015'.
if LocHB = 'B'          Hosp_HB_Code =       'S08000016'.
if LocHB = 'Y'          Hosp_HB_Code =       'S08000017'.
if LocHB = 'F'          Hosp_HB_Code =       'S08000018'.
if LocHB = 'V'          Hosp_HB_Code =       'S08000019'.
if LocHB = 'N'          Hosp_HB_Code =       'S08000020'.
if LocHB = 'G'          Hosp_HB_Code =       'S08000021'.
if LocHB = 'H'          Hosp_HB_Code =       'S08000022'.
if LocHB = 'L'          Hosp_HB_Code =       'S08000023'.
if LocHB = 'S'          Hosp_HB_Code =       'S08000024'.
if LocHB = 'R'          Hosp_HB_Code =       'S08000025'.
if LocHB = 'Z'          Hosp_HB_Code =       'S08000026'.
if LocHB = 'T'          Hosp_HB_Code =       'S08000027'.
if LocHB = 'W'          Hosp_HB_Code =       'S08000028'.
exe.


*gender update?.
alter type gender (a7).
if gender eq '      1' gender eq 'Male'.
if gender eq '      2' gender eq 'Female'.
if gender eq '      0' or gender eq '      9'  or gender eq '' gender eq 'Unknown'.
exe.

COMPUTE Year = !Year.
EXECUTE.


*Save final version of individual financial year.
save outfile = !file + 'PLICSLite_' + !Year + '.zsav'
/ZCOMPRESSED
/drop Add1 Add2 Add3 Add4 Add5 Postcode Summary Start Close Destination GpSurgeryInd SMR00 SMR01 SMR02 SMR04 SMR06 SMR11 SMR20 SMR25 SMR30 SMR50 filler locHB Grouping.
get file = !file + 'PLICSLite_' + !Year + '.zsav'.



********************************************************************************************************.
*********TO BE RUN ONCE ALL FINANCIAL YEARS HAVE BEEN COMPLETED***********.
********************************************************************************************************.
*Add all years together.
define !file()
 '/conf/irf/09-Tableau-Outputs/01-Development/02-SPSS-Outputs/14-PLICS Overview/'
!enddefine.

ADD FILES file = !file + '/PLICSLite_1516.zsav'
/file= !file + 'PLICSLite_1617.zsav'
/file= !file + 'PLICSLite_1718.zsav'
/file= !file + 'PLICSLite_1819.zsav'.
exe.

*Remove Services which do not yet have a monthly breakdown - To be included in future versions.
*select if not any(SMRType, 'NRS Deaths', 'PIS').
select if not any(SMRType, 'NRS Deaths', 'Comm-MH').
exe.
select if not any(recid, 'CH', 'DN', 'OoH', 'DD', 'NSU').
exe.

**********Episodes being rename "Stays".
*Rename variables episodes = Stays.

*Save final version of file.
save outfile = !file + 'PLICSLite_FINAL.sav'
/compressed.
get file =  !file + 'PLICSLite_FINAL.sav'.

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
EXECUTE.

String SMR_Type (a40).
compute SMR_Type=valuelabel(SMRType).
if SMR_Type='Community Prescribing summary' SMR_Type='Prescribing'.
if SMR_Type='Psychiatric - Inpatient' SMR_Type='Mental Health - Inpatient'.
if SMRType='A & E' SMR_Type='A & E'.
if SMRType='Outpatient' SMR_Type='Outpatient'.
execute.


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
EXECUTE.

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
EXECUTE.

RENAME VARIABLES apr_beddays = april_beddays.
RENAME VARIABLES jun_beddays = june_beddays.
RENAME VARIABLES aug_beddays = august_beddays.
RENAME VARIABLES sep_beddays = sept_beddays.
RENAME VARIABLES apr_cost = april_cost.
RENAME VARIABLES jun_cost = june_cost.
RENAME VARIABLES aug_cost = august_cost.
RENAME VARIABLES sep_cost = sept_cost.
EXECUTE.

string year_description (a10).
if year = '1516' year_description = '2015/16'.
if year = '1617' year_description = '2016/17'.
if year = '1718' year_description = '2017/18'.
if year = '1819' year_description = '2018/19'.
execute.

compute attendances=episodes.
alter type attendances (f7.0).
compute Episodes_Attendances=episodes.
alter type Episodes_Attendances (f7.0).
execute.

rename variables HSCPLocality=Locality.
rename variables speccode=spec.
rename variables Description=SpecName.
rename variables cij_pattype=newpattype_cis.
rename variables cij_ipdc=newcis_ipdc.

save outfile = !file + 'PLICSLite_FINAL.sav'
/compressed.
get file =  !file + 'PLICSLite_FINAL.sav'.
**********************************************************************************************END**********************************************************************************************************************************
*************************************************************************************************************************************************************************************************************************************.

 * SELECT IF refsource NE "" AND RefSource_Description = "".
 * EXECUTE.

 * SELECT IF LA_CODE = "".
 * EXECUTE.

get file =  !file + 'PLICSLite_FINAL.sav'.

if recid='AE2' and location='C206H' and LCAname='West Dunbartonshire' Hosp_HB_Code=HB_Code.
if recid='AE2' and location='C313H' and LCAname='Inverclyde' Hosp_HB_Code=HB_Code.
if recid='AE2' and location='C418H' and LCAname='Renfrewshire' Hosp_HB_Code=HB_Code.
execute.

save outfile = !file + 'PLICSLite_FINAL.sav'.








