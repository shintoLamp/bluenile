* Encoding: UTF-8.
*****************************PLICS LITE Syntax******************************.
****KR March 2017*********.
***JD January 2018********.
****Aggregates PLICS episode level files into format for use in PLICS Lite workbook in Tableau****.
****Version includes locality breakdown****.
* BM June 2021 - changed file paths and names to reflect Source Overview workbook name.

*Set Macros.
define !file()
 '/conf/sourcedev/TableauUpdates/Source Overview/Outputs/'
!enddefine.

Define !Year()
 '2021'
!enddefine.

*Open Source linkage file (episode level).
get file = '/conf/hscdiip/01-Source-linkage-files/source-episode-file-20' + !Year + '.zsav'.

*Assign names to Partnerships.
*Amended to use value labels from SLF, BM 06/21.
string LCAname(a30).
compute LCAname = valuelabel(LCA).
compute LCAname = replace(LCAname, ' and ', ' & ').
if LCAname = 'Na h-Eileanan Siar' LCAname = 'Western Isles'.
if LCAname eq '' LCAname eq 'Non LCA'.
*frequency variables = LCAname.

*Match on Localities by datazone.
sort cases by DataZone2011.
match files file = *
/table = '/conf/linkage/output/lookups/Unicode/Geography/HSCP Locality/HSCP Localities_DZ11_Lookup_20200825.sav'
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

*New Community Health Services as Outpatient Referral Source code.
if refsource eq '0' refsource eq 'E'.

***Aggregate to get the number of episodes and reduce data to a less disclosive format for Source.
aggregate outfile = *
/break year lca LCAname recid SMRType gender location HSCPLocality ipdc spec
refsource clinic_type ageband cij_ipdc cij_pattype
/yearstay stay 
no_dispensed_items 
cost_total_net Cost_Total_Net_incDNAs 
apr_beddays may_beddays jun_beddays jul_beddays aug_beddays sep_beddays oct_beddays nov_beddays dec_beddays jan_beddays feb_beddays mar_beddays 
apr_cost may_cost jun_cost jul_cost aug_cost sep_cost oct_cost nov_cost dec_cost jan_cost feb_cost mar_cost 
apr_episodes may_episodes jun_episodes jul_episodes aug_episodes sep_episodes oct_episodes nov_episodes dec_episodes jan_episodes feb_episodes mar_episodes 
= sum(yearstay stay 
no_dispensed_items 
cost_total_net Cost_Total_Net_incDNAs 
apr_beddays may_beddays jun_beddays jul_beddays aug_beddays sep_beddays oct_beddays nov_beddays dec_beddays jan_beddays feb_beddays mar_beddays 
apr_cost may_cost jun_cost jul_cost aug_cost sep_cost oct_cost nov_cost dec_cost jan_cost feb_cost mar_cost 
apr_episodes may_episodes jun_episodes jul_episodes aug_episodes sep_episodes oct_episodes nov_episodes dec_episodes jan_episodes feb_episodes mar_episodes)
/episodes = n.

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

save outfile = !file + 'SourceOverview_Temp.sav'
    /ZCOMPRESSED.
get file = !file + 'SourceOverview_Temp.sav'.

*Sort cases by Specialty code to match on Specialty names.
rename variables spec=speccode.
sort cases by speccode.
*Match with lookup file - BEWARE - location of lookup file may change.
match files file =*
/table = '/conf/linkage/output/lookups/Unicode/National Reference Files/Specialty_Groupings.sav'
/by speccode.

*Sort cases by location code to match on Hospital names.
sort cases by location.
ALTER TYPE location(a5).
*Match with location lookup file in clout.
match files file = *
/table =  '/conf/linkage/output/lookups/Unicode/National Reference Files/location.sav'
/by location.

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

*gender update.
alter type gender (a7).
if gender eq '      1' gender eq 'Male'.
if gender eq '      2' gender eq 'Female'.
if gender eq '      0' or gender eq '      9'  or gender eq '' gender eq 'Unknown'.

alter type Year(a7).
COMPUTE Year = concat('20', char.substr(!Year,1,2), '/', char.substr(!Year,3,2)).
execute.

*Save final version of individual financial year.
save outfile = !file + 'SourceOverview_' + !Year + '.sav'
/ZCOMPRESSED
/drop Add1 Add2 Add3 Add4 Add5 Postcode Summary Start Close Destination GpSurgeryInd SMR00 SMR01 SMR02 SMR04 SMR06 SMR11 SMR20 SMR25 SMR30 SMR50 filler locHB Grouping.
get file = !file + 'SourceOverview_' + !Year + '.sav'.