* Encoding: UTF-8.
get file = '/conf/irf/09-Tableau-Outputs/01-Development/02-SPSS-Outputs/01-HSC-Expenditure/Final_data/2018-19/ExcelOutput.sav'.

rename variables CareProgram=CareProgram_old.

alter type service (a50).

 * select if HSCP_NAME ne ''.
 * select if HSCP_NAME ne 'Non HSCP'.
 * execute.

if HSCP_NAME='Stirling' HSCP_NAME='Clackmannanshire & Stirling'.
if HSCP_NAME='Clackmannanshire' HSCP_NAME='Clackmannanshire & Stirling'.
execute.

if HSCP_NAME='Clackmannanshire & Stirling' LA_TAB_Code='LAVC99'.
execute.

aggregate outfile=*
/break Year hbr HSCP_NAME AGEGROUP HB_TAB_Code LA_TAB_Code service sector Sub_Sector CareProgram_old Total
/Expenditure=sum(Expenditure).
execute.

rename variables sub_sector=Sub_Sector_alt.

if Sub_Sector_alt='27-General Ophthalmic Servicess' Sub_Sector_alt='27-General Ophthalmic Services'.
execute.

string sub_sector (a41).
if Sub_Sector_alt eq '01-Acute IP - Non elective' sub_sector eq 'Acute'.
if Sub_Sector_alt eq '02-Acute IP - Elective' sub_sector eq 'Acute'.
if Sub_Sector_alt eq '03-Acute IP - Other' sub_sector eq 'Acute'.
if Sub_Sector_alt eq '04-Mental Health IP - Non elective' sub_sector eq 'Mental Health'.
if Sub_Sector_alt eq '05-Mental Health IP - Elective' sub_sector eq 'Mental Health'.
if Sub_Sector_alt eq '06-Mental Health IP - Other' sub_sector eq 'Mental Health'.
if Sub_Sector_alt eq '07-Geriatric LS IP - Non elective' sub_sector eq 'GLS'.
if Sub_Sector_alt eq '08-Geriatric LS IP - Elective' sub_sector eq 'GLS'.
if Sub_Sector_alt eq '09-Geriatric LS IP - Other' sub_sector eq 'GLS'.
if sub_sector_alt eq '12-Acute Day cases' sub_sector eq 'Acute'.
if sub_sector_alt eq '13-Maternity Day cases' sub_sector eq 'Maternity'.
if sub_sector_alt eq '21-Community Health - other' sub_Sector eq 'Community - Other' .
if sub_sector_alt eq '23-GMS' sub_sector eq 'GMS' .
if sub_sector_alt eq '24-GP Prescribing'sub_sector eq 'GP Prescribing' .
if sub_sector_alt eq '27-Care Homes' sub_sector eq 'Care homes' .
if sub_sector_alt eq '28-Other-Accomodation-based service' sub_sector eq 'Other' .
if sub_sector_alt eq '30-Home Care' sub_sector eq 'Home Care' .
if sub_sector_alt eq '32-Direct Payments' sub_sector eq 'Direct Payments' .
if sub_sector_alt eq '33-Other-Community-based service' sub_sector eq 'Other' .
if sub_sector_alt eq '31-Day Care' sub_sector eq 'Day Care' .
if sub_sector_alt eq '10-Maternity IP' sub_Sector eq 'Maternity' .
if sub_sector_alt eq '14-Outpatients - Accident & Emergency' sub_sector eq 'Outpatients' .
if sub_sector_alt eq '15-Outpatients - Consultant - Total' sub_sector eq 'Outpatients' .
if sub_sector_alt eq '15-Outpatients - Consultant New' sub_sector eq 'Outpatients' .
if sub_sector_alt eq '15-Outpatients - Consultant Total' sub_sector eq 'Outpatients' .
if sub_sector_alt eq '16-Outpatients - other' sub_sector eq 'Outpatients' .
if sub_sector_alt eq '17-Day Patients' sub_sector eq 'Day Patients' .
if sub_sector_alt eq '19-District Nursing' sub_sector eq 'Community - Health' .
if sub_sector_alt eq '20-Health Visiting' sub_sector eq 'Community - Health' .
if sub_sector_alt eq '26-General Dental Services' sub_sector eq 'FHS - Other (Not Mapped)' .
if sub_sector_alt eq '27-General Ophthalmic Services' sub_sector eq 'FHS - Other (Not Mapped)' .
if sub_sector_alt eq '29-Total Accommodation based services' sub_sector eq 'Total - Accommodation based services' .
if sub_sector_alt eq '34-Total Community based services' sub_sector eq 'Total - Community based services' .
execute.

if Sub_Sector_alt='11-SCBU (HB treatment total)' sub_sector='Maternity'.
if Sub_Sector_alt='18-Total Hospital' sub_sector='Total - Hospital'.
if Sub_Sector_alt='22-Total Community' sub_sector='Total - NHS Community'.
if Sub_Sector_alt='25-Total Family Health Services' sub_sector='Total - Family Health Services'.
if Sub_Sector_alt='26-Total NHS' sub_sector='Total - Health'.
if Sub_Sector_alt='35-NHS + Social Care' sub_sector='Total - Health + Social Care'.
if Sub_Sector_alt='35-Total Social Care' sub_sector='Total - Social Care'.
if Sub_Sector_alt='35-Total NHS + Social Care' sub_sector='Total - Health + Social Care'.
execute.

 * select if sub_sector=''.
 * execute.

sort cases by Sub_Sector (a) AGEGROUP (a).
match files file= *
/table='/conf/irf/09-Tableau-Outputs/01-Development/02-SPSS-Outputs/01-HSC-Expenditure/Lookups/NRAC_Care_Progs_by_age.sav'
/by Sub_Sector AGEGROUP.
execute.

 * select if sub_sector='FHS - Other (Not Mapped)'.
 * execute.

 * select if CareProgram_old ne ''.
 * execute.

compute dup=0.
if CareProgram_old=CareProgram dup=1.
execute.

if CareProgram_old='gppresc' and sub_sector='FHS - Other (Not Mapped)' CareProgram='gppresc'.
execute.

if LA_TAB_Code=HB_TAB_Code LA_TAB_Code=''.
execute.

string PopLookup(a40).
compute PopLookup=concat(Year,HB_TAB_Code,LA_TAB_Code,CareProgram,AGEGROUP).
execute.

sort cases by PopLookup.
match files file=*
/table = '/conf/irf/09-Tableau-Outputs/01-Development/02-SPSS-Outputs/01-HSC-Expenditure/Final_data/2018-19/NRAC Populations/NRAC_pops.sav'
/by PopLookup.
execute.

if sysmis(population) population=0.
execute.

if LA_TAB_Code='' LA_TAB_Code=HB_TAB_Code .
execute.

sort cases by Year HB_TAB_Code LA_TAB_Code AGEGROUP service sector Sub_Sector_alt.

delete variables sub_sector.
rename variables Sub_Sector_alt=Sub_Sector.

save outfile = '/conf/irf/09-Tableau-Outputs/01-Development/02-SPSS-Outputs/01-HSC-Expenditure/Final_data/2018-19/Source Output/ExcelOutput 1819 Scot totals.sav'
/keep Year hbr HSCP_NAME AGEGROUP HB_TAB_Code LA_TAB_Code service sector Sub_Sector CareProgram Expenditure Total.

get file = '/conf/irf/09-Tableau-Outputs/01-Development/02-SPSS-Outputs/01-HSC-Expenditure/Final_data/2018-19/Source Output/ExcelOutput 1819 Scot totals.sav'.

aggregate outfile=*
/break Year hbr HSCP_NAME AGEGROUP HB_TAB_Code LA_TAB_Code service sector Sub_Sector CareProgram Total
/Expenditure=sum(Expenditure).
execute.

if service='03-NHS + Social Care' service='Health + Social Care'.
if service='35-NHS + Social Care' service='Health + Social Care'.
execute.

if sector='05-Total NHS' sector='Total - Health'.
if sector='26-Total NHS' sector='Total - Health'.
if sector='09-Total NHS and Social Care' sector='Total - Health + Social Care'.
if sector='35-NHS + Social Care' sector='Total - Health + Social Care'.
if sector='08-Total Social Care' sector='Total - Social Care'.
if sector='35-Total Social Care' sector='Total - Social Care'.
execute.

if sector='Total - Health' Sub_Sector='Total - Health'.
if sector='Total - Health + Social Care' Sub_Sector='Total - Health + Social Care'.
if sector='Total - Social Care' Sub_Sector='Total - Social Care'.
execute.

if Sub_Sector='18-Total Hospital' Sub_sector='Total - Hospital'.
if Sub_Sector='22-Total Community' Sub_sector='Total - Community'.
if Sub_Sector='25-Total Family Health Services' Sub_sector='Total - Family Health Services'.
if Sub_Sector='29-Total Accommodation based services' Sub_sector='Total - Accommodation based services'.
if Sub_Sector='34-Total Community based services' Sub_sector='Total - Community based services'.
execute.

if CareProgram='' CareProgram='nrac'.
execute.

 * save outfile = '/conf/irf/09-Tableau-Outputs/01-Development/02-SPSS-Outputs/01-HSC-Expenditure/Final_data/2017-18/Source Output/ExcelOutput.sav'
/keep Year hbr HSCP_NAME AGEGROUP HB_TAB_Code LA_TAB_Code service sector Sub_Sector CareProgram Expenditure Total. 

 * add files file = '/conf/irf/09-Tableau-Outputs/01-Development/02-SPSS-Outputs/01-HSC-Expenditure/Final_data/2016-17/Source Output/201213 to 201516/ExcelOutput 1314 to 1617.sav'
/file = '/conf/irf/09-Tableau-Outputs/01-Development/02-SPSS-Outputs/01-HSC-Expenditure/Final_data/2017-18/Source Output/ExcelOutput.sav'.
 * execute.

 * select if Year ne '2013/14'.
 * execute.

save outfile = '/conf/irf/09-Tableau-Outputs/01-Development/02-SPSS-Outputs/01-HSC-Expenditure/Final_data/2018-19/Source Output/ExcelOutput 1819 Scot totals.sav'.

get file = '/conf/irf/09-Tableau-Outputs/01-Development/02-SPSS-Outputs/01-HSC-Expenditure/Final_data/2018-19/Source Output/ExcelOutput 1819 Scot totals.sav'.

select if service='01-Health' or service='02-Social Care'.
select if sector ne 'Total - Health'.
select if sector ne 'Total - Social Care'.
execute.

rename variables sector=sector2.
rename variables Sub_Sector=Sub_Sector2.

string sector (a37).
compute sector='All'.
execute.

string Sub_Sector (a41).
compute Sub_Sector='All'.
execute.

select if Total='S'.
execute.

compute CareProgram='nrac'.
execute.

aggregate outfile=*
/break Year hbr HSCP_NAME AGEGROUP HB_TAB_Code LA_TAB_Code service sector Sub_Sector CareProgram Total
/Expenditure=sum(Expenditure).
execute.

save outfile =  '/conf/irf/09-Tableau-Outputs/01-Development/02-SPSS-Outputs/01-HSC-Expenditure/Final_data/2018-19/Source Output/HS_All_Scot.sav'.

get file = '/conf/irf/09-Tableau-Outputs/01-Development/02-SPSS-Outputs/01-HSC-Expenditure/Final_data/2018-19/Source Output/ExcelOutput 1819 Scot totals.sav'.

select if service='Health + Social Care'.
execute.

if service='Health + Social Care' service='All-HS'.
execute.

if service='All-HS' sector='All'.
if service='All-HS' Sub_Sector='All'.
execute.

save outfile= '/conf/irf/09-Tableau-Outputs/01-Development/02-SPSS-Outputs/01-HSC-Expenditure/Final_data/2018-19/Source Output/All_HS_Scot.sav'.

*Create summary Institutional & Community Care data with sector and Sub_Sector highlighted under 'All'.
get file = '/conf/irf/09-Tableau-Outputs/01-Development/02-SPSS-Outputs/01-HSC-Expenditure/Final_data/2018-19/Source Output/ExcelOutput 1819 Scot totals.sav'.

select if service='Health + Social Care'.
execute.

if service='Health + Social Care' service='All-IC'.
execute.

if service='All-IC' sector='All'.
if service='All-IC' Sub_Sector='All'.
execute.

save outfile= '/conf/irf/09-Tableau-Outputs/01-Development/02-SPSS-Outputs/01-HSC-Expenditure/Final_data/2018-19/Source Output/All_IC_Scot.sav'.

*Break service types into Institutional & Community Care from Health & Social Care and summarise data.
get file = '/conf/irf/09-Tableau-Outputs/01-Development/02-SPSS-Outputs/01-HSC-Expenditure/Final_data/2018-19/Source Output/ExcelOutput 1819 Scot totals.sav'.

if char.substr(Sector,1,2)="01" service="Institutional-Based-Care".
if char.substr(Sector,1,2)="02" service="Community-Based-Care".
if char.substr(Sector,1,2)="03" service="Community-Based-Care".
if char.substr(Sector,1,2)="06" service="Institutional-Based-Care".
if char.substr(Sector,1,2)="07" service="Community-Based-Care".
execute.

select if service="Institutional-Based-Care" or service="Community-Based-Care".
execute.

select if char.substr(Sub_Sector,1,5) ne "Total".
execute.

save outfile= '/conf/irf/09-Tableau-Outputs/01-Development/02-SPSS-Outputs/01-HSC-Expenditure/Final_data/2018-19/Source Output/IC_Files_Scot.sav'.

get file = '/conf/irf/09-Tableau-Outputs/01-Development/02-SPSS-Outputs/01-HSC-Expenditure/Final_data/2018-19/Source Output/ExcelOutput 1819 Scot totals.sav'.

if char.substr(Sector,1,2)="01" service="Institutional-Based-Care".
if char.substr(Sector,1,2)="02" service="Community-Based-Care".
if char.substr(Sector,1,2)="03" service="Community-Based-Care".
if char.substr(Sector,1,2)="06" service="Institutional-Based-Care".
if char.substr(Sector,1,2)="07" service="Community-Based-Care".
execute.

if service='Health + Social Care' service='Total - Institutional + Community'.
execute.

if service='Total - Institutional + Community' Total='S'.
execute.

select if char.substr(Sub_Sector,1,5)="Total".
select if Total ne 'Y'.
execute.

if service='Total - Institutional + Community' sector='Total - Institutional + Community'.
if service='Total - Institutional + Community' Sub_Sector='Total - Institutional + Community'.
execute.

save outfile= '/conf/irf/09-Tableau-Outputs/01-Development/02-SPSS-Outputs/01-HSC-Expenditure/Final_data/2018-19/Source Output/IC_Totals_Scot.sav'.

get file = '/conf/irf/09-Tableau-Outputs/01-Development/02-SPSS-Outputs/01-HSC-Expenditure/Final_data/2018-19/Source Output/IC_Totals_Scot.sav'.

select if service="Institutional-Based-Care" or service="Community-Based-Care".
execute.

aggregate outfile=*
/break Year hbr HSCP_NAME AGEGROUP HB_TAB_Code LA_TAB_Code service CareProgram Total
/Expenditure=sum(Expenditure).
execute.

string sector (a37).
string Sub_Sector (a41).

if service='Community-Based-Care' sector='Total - Community Based'.
if service='Institutional-Based-Care' sector='Total - Institutional Based'.
if service='Community-Based-Care' Sub_Sector='Total - Community Based'.
if service='Institutional-Based-Care' Sub_Sector='Total - Institutional Based'.
execute.

save outfile= '/conf/irf/09-Tableau-Outputs/01-Development/02-SPSS-Outputs/01-HSC-Expenditure/Final_data/2018-19/Source Output/IC_Totals_2_Scot.sav'
/keep Year hbr HSCP_NAME AGEGROUP HB_TAB_Code LA_TAB_Code service sector Sub_Sector CareProgram Total Expenditure.

add files file = '/conf/irf/09-Tableau-Outputs/01-Development/02-SPSS-Outputs/01-HSC-Expenditure/Final_data/2018-19/Source Output/IC_Totals_Scot.sav'
/file = '/conf/irf/09-Tableau-Outputs/01-Development/02-SPSS-Outputs/01-HSC-Expenditure/Final_data/2018-19/Source Output/IC_Totals_2_Scot.sav'.
execute.

aggregate outfile=*
/break Year hbr HSCP_NAME AGEGROUP HB_TAB_Code LA_TAB_Code service sector Sub_Sector CareProgram Total
/Expenditure=sum(Expenditure).
execute.

save outfile= '/conf/irf/09-Tableau-Outputs/01-Development/02-SPSS-Outputs/01-HSC-Expenditure/Final_data/2018-19/Source Output/IC_Final_Totals_Scot.sav'.

add files file = '/conf/irf/09-Tableau-Outputs/01-Development/02-SPSS-Outputs/01-HSC-Expenditure/Final_data/2018-19/Source Output/IC_Final_Totals_Scot.sav'
/file = '/conf/irf/09-Tableau-Outputs/01-Development/02-SPSS-Outputs/01-HSC-Expenditure/Final_data/2018-19/Source Output/IC_Files_Scot.sav'.
execute.

select if service="Institutional-Based-Care" or service="Community-Based-Care".
execute.

select if sector ne 'Total - Community Based'.
select if sector ne 'Total - Institutional Based'.
execute.

rename variables sector=sector2.
rename variables Sub_Sector=Sub_Sector2.

string sector (a37).
compute sector='All'.
execute.

string Sub_Sector (a41).
compute Sub_Sector='All'.
execute.

select if Total='S'.
execute.

compute CareProgram='nrac'.
execute.

 * if CareProgram='COTE' CareProgram='nrac'.
 * if CareProgram='Community' CareProgram='nrac'.
 * execute.

aggregate outfile=*
/break Year hbr HSCP_NAME AGEGROUP HB_TAB_Code LA_TAB_Code service sector Sub_Sector CareProgram Total
/Expenditure=sum(Expenditure).
execute.

save outfile= '/conf/irf/09-Tableau-Outputs/01-Development/02-SPSS-Outputs/01-HSC-Expenditure/Final_data/2018-19/Source Output/IC_All_Scot.sav'. 

*Add all summary files together to create updated Source file.
add files file = '/conf/irf/09-Tableau-Outputs/01-Development/02-SPSS-Outputs/01-HSC-Expenditure/Final_data/2018-19/Source Output/ExcelOutput 1819 Scot totals.sav'
/file = '/conf/irf/09-Tableau-Outputs/01-Development/02-SPSS-Outputs/01-HSC-Expenditure/Final_data/2018-19/Source Output/HS_All_Scot.sav'
/file = '/conf/irf/09-Tableau-Outputs/01-Development/02-SPSS-Outputs/01-HSC-Expenditure/Final_data/2018-19/Source Output/All_HS_Scot.sav'
/file = '/conf/irf/09-Tableau-Outputs/01-Development/02-SPSS-Outputs/01-HSC-Expenditure/Final_data/2018-19/Source Output/IC_Files_Scot.sav'
/file = '/conf/irf/09-Tableau-Outputs/01-Development/02-SPSS-Outputs/01-HSC-Expenditure/Final_data/2018-19/Source Output/IC_Final_Totals_Scot.sav'
/file = '/conf/irf/09-Tableau-Outputs/01-Development/02-SPSS-Outputs/01-HSC-Expenditure/Final_data/2018-19/Source Output/All_IC_Scot.sav'
/file = '/conf/irf/09-Tableau-Outputs/01-Development/02-SPSS-Outputs/01-HSC-Expenditure/Final_data/2018-19/Source Output/IC_All_Scot.sav'.
execute.

if Sub_Sector='15-Outpatients - Consultant - Total' Sub_Sector='15-Outpatients - Consultant New'.
if Sub_Sector='15-Outpatients - Consultant Total' Sub_Sector='15-Outpatients - Consultant New'.
execute.

aggregate outfile=*
/break Year hbr HSCP_NAME AGEGROUP HB_TAB_Code LA_TAB_Code service sector Sub_Sector CareProgram Total
/Expenditure=sum(Expenditure).
execute.

save outfile = '/conf/irf/09-Tableau-Outputs/01-Development/02-SPSS-Outputs/01-HSC-Expenditure/Final_data/2018-19/Source Output/SourceOutput_Lv1.sav'.

*Calculate All totals for each Sector, H&SC and I&C.
get file = '/conf/irf/09-Tableau-Outputs/01-Development/02-SPSS-Outputs/01-HSC-Expenditure/Final_data/2018-19/Source Output/SourceOutput_Lv1.sav'. 

select if Sub_Sector='Total - Hospital' or Sub_Sector='Total - Community' or Sub_Sector='Total - Family Health Services' or Sub_Sector='Total - Accommodation based services' or Sub_Sector='Total - Community based services'.
execute.

compute Sub_Sector='All'.
compute CareProgram='nrac'.
execute.

save outfile = '/conf/irf/09-Tableau-Outputs/01-Development/02-SPSS-Outputs/01-HSC-Expenditure/Final_data/2018-19/Source Output/1819 Sub_Sector totals_Lv1.sav'.

add files file = '/conf/irf/09-Tableau-Outputs/01-Development/02-SPSS-Outputs/01-HSC-Expenditure/Final_data/2018-19/Source Output/SourceOutput_Lv1.sav'
/file = '/conf/irf/09-Tableau-Outputs/01-Development/02-SPSS-Outputs/01-HSC-Expenditure/Final_data/2018-19/Source Output/1819 Sub_Sector totals_Lv1.sav'.
execute.

save outfile = '/conf/irf/09-Tableau-Outputs/01-Development/02-SPSS-Outputs/01-HSC-Expenditure/Final_data/2018-19/Source Output/SourceOutput_Lv1_Feb21.sav'.

SAVE TRANSLATE OUTFILE = '/conf/irf/09-Tableau-Outputs/01-Development/02-SPSS-Outputs/01-HSC-Expenditure/Final_data/2018-19/Source Output/SourceOutput_Lv1_Feb21.xlsx'
  /TYPE=XLS
  /VERSION=12
  /REPLACE
  /FIELDNAMES
  /CELLS=VALUES.

*Include additional variables to create final main Source output file.
get file = '/conf/irf/09-Tableau-Outputs/01-Development/02-SPSS-Outputs/01-HSC-Expenditure/Final_data/2018-19/Source Output/SourceOutput_Lv1_Feb21.sav'. 

if LA_TAB_Code=HB_TAB_Code LA_TAB_Code=''.
execute.

string HB_NAME (a40).
if hbr='A' HB_NAME='Ayrshire & Arran Region'.
if hbr='B' HB_NAME='Borders Region'.
if hbr='Y' HB_NAME='Dumfries & Galloway Region'.
if hbr='F' HB_NAME='Fife Region'.
if hbr='V' HB_NAME='Forth Valley Region'.
if hbr='G' HB_NAME='Glasgow & Clyde Region'.
if hbr='N' HB_NAME='Grampian Region'.
if hbr='H' HB_NAME='Highland Region'.
if hbr='L' HB_NAME='Lanarkshire Region'.
if hbr='S' HB_NAME='Lothian Region'.
if hbr='R' HB_NAME='Orkney Region'.
if hbr='Z' HB_NAME='Shetland Region'.
if hbr='T' HB_NAME='Tayside Region'.
if hbr='W' HB_NAME='Western Isles Region'.
execute.

rename variables HSCP_NAME=CHPNAME.
alter type Expenditure (f8.0).
alter type LA_TAB_Code (a6).

if CHPNAME='NHS Ayrshire & Arran' CHPNAME=' Ayrshire & Arran Region'.
if CHPNAME='NHS Borders' CHPNAME=' Borders Region'.
if CHPNAME='NHS Dumfries & Galloway' CHPNAME=' Dumfries & Galloway Region'.
if CHPNAME='NHS Fife' CHPNAME=' Fife Region'.
if CHPNAME='NHS Forth Valley' CHPNAME=' Forth Valley Region'.
if CHPNAME='NHS Greater Glasgow & Clyde' CHPNAME=' Glasgow & Clyde Region'.
if CHPNAME='NHS Grampian' CHPNAME=' Grampian Region'.
if CHPNAME='NHS Highland' CHPNAME=' Highland Region'.
if CHPNAME='NHS Lanarkshire' CHPNAME=' Lanarkshire Region'.
if CHPNAME='NHS Lothian' CHPNAME=' Lothian Region'.
if CHPNAME='NHS Orkney' CHPNAME=' Orkney Region'.
if CHPNAME='NHS Shetland' CHPNAME=' Shetland Region'.
if CHPNAME='NHS Tayside' CHPNAME=' Tayside Region'.
if CHPNAME='NHS Western Isles' CHPNAME=' Western Isles Region'.
execute.

string PopLookup(a40).
compute PopLookup=concat(Year,HB_TAB_Code,LA_TAB_Code,CareProgram,AGEGROUP).
execute.

string DummyVariable (a6).
compute DummyVariable='Dummy'.
execute.

string Data (a15).
if service='01-Health' or service='02-Social Care' or service='All-HS' or service='Health + Social Care' Data='Data_HSC'.
if service='All-IC' or service='Community-Based-Care' or service='Institutional-Based-Care' or service='Total - Institutional + Community' Data='Data_BOS'.
execute.

string HB_CODE (a9).
if HB_TAB_Code="HBVC9" HB_CODE="S08000015".
if HB_TAB_Code="HBVC5" HB_CODE="S08000016".
if HB_TAB_Code="HBVC11" HB_CODE="S08000017".
if HB_TAB_Code="HBVC12" HB_CODE="S08000018".
if HB_TAB_Code="HBVC7" HB_CODE="S08000019".
if HB_TAB_Code="HBVC14" HB_CODE="S08000020".
if HB_TAB_Code="HBVC8" HB_CODE="S08000021".
if HB_TAB_Code="HBVC13" HB_CODE="S08000022".
if HB_TAB_Code="HBVC1" HB_CODE="S08000023".
if HB_TAB_Code="HBVC3" HB_CODE="S08000024".
if HB_TAB_Code="HBVC6" HB_CODE="S08000025".
if HB_TAB_Code="HBVC4" HB_CODE="S08000026".
if HB_TAB_Code="HBVC10" HB_CODE="S08000027".
if HB_TAB_Code="HBVC2" HB_CODE="S08000028".
execute.

string LA_CODE (a9).
if LA_TAB_Code="LAVC8" LA_CODE="S12000013".
if LA_TAB_Code="LAVC30" LA_CODE="S12000041".
if LA_TAB_Code="LAVC28" LA_CODE="S12000042".
if LA_TAB_Code="LAVC7" LA_CODE="S12000024".
if LA_TAB_Code="LAVC9" LA_CODE="S12000027".
if LA_TAB_Code="LAVC26" LA_CODE="S12000023".
if LA_TAB_Code="LAVC16" LA_CODE="S12000036".
if LA_TAB_Code="LAVC27" LA_CODE="S12000010".
if LA_TAB_Code="LAVC6" LA_CODE="S12000019".
if LA_TAB_Code="LAVC17" LA_CODE="S12000040".
if LA_TAB_Code="LAVC32" LA_CODE="S12000044".
if LA_TAB_Code="LAVC14" LA_CODE="S12000029".
if LA_TAB_Code="LAVC24" LA_CODE="S12000035".
if LA_TAB_Code="LAVC4" LA_CODE="S12000017".
if LA_TAB_Code="LAVC22" LA_CODE="S12000045".
if LA_TAB_Code="LAVC12" LA_CODE="S12000011".
if LA_TAB_Code="LAVC23" LA_CODE="S12000046".
if LA_TAB_Code="LAVC3" LA_CODE="S12000018".
if LA_TAB_Code="LAVC31" LA_CODE="S12000038".
if LA_TAB_Code="LAVC13" LA_CODE="S12000039".
if LA_TAB_Code="LAVC25" LA_CODE="S12000033".
if LA_TAB_Code="LAVC15" LA_CODE="S12000034".
if LA_TAB_Code="LAVC5" LA_CODE="S12000020".
if LA_TAB_Code="LAVC18" LA_CODE="S12000005".
if LA_TAB_Code="LAVC29" LA_CODE="S12000014".
if LA_TAB_Code="LAVC19" LA_CODE="S12000030".
if LA_TAB_Code="LAVC2" LA_CODE="S12000015".
if LA_TAB_Code="LAVC20" LA_CODE="S12000006".
if LA_TAB_Code="LAVC11" LA_CODE="S12000026".
if LA_TAB_Code="LAVC1" LA_CODE="S12000008".
if LA_TAB_Code="LAVC10" LA_CODE="S12000021".
if LA_TAB_Code="LAVC21" LA_CODE="S12000028".
execute.

if LA_CODE="" LA_CODE=HB_CODE.
if LA_TAB_Code='' LA_TAB_Code=HB_TAB_Code.
execute.

sort cases by PopLookup.
match files file=*
/table = '/conf/irf/09-Tableau-Outputs/01-Development/02-SPSS-Outputs/01-HSC-Expenditure/Final_data/2018-19/NRAC Populations/NRAC_pops.sav'
/by PopLookup.
execute.

rename variables PopLookup=Poplookup.

save outfile = '/conf/irf/09-Tableau-Outputs/01-Development/02-SPSS-Outputs/01-HSC-Expenditure/Final_data/2018-19/FinalSourceOutput_Lv1_Feb21.sav'
/keep Year HB_NAME CHPNAME AGEGROUP HB_TAB_Code LA_TAB_Code service sector Sub_Sector CareProgram Expenditure Total Poplookup DummyVariable Data HB_CODE LA_CODE population.

get file = '/conf/irf/09-Tableau-Outputs/01-Development/02-SPSS-Outputs/01-HSC-Expenditure/Final_data/2018-19/FinalSourceOutput_Lv1_Feb21.sav'.

delete variables Poplookup.

select if HB_TAB_Code='M'.
execute.

compute HB_NAME='Scotland'.
compute CHPNAME='Scotland'.
compute HB_CODE=''.
compute LA_CODE=''.
compute HB_TAB_Code=''.
compute LA_TAB_Code=''.
execute.

string PopLookup (a40).
compute PopLookup eq concat(year, HB_TAB_Code, CareProgram, AgeGroup).
execute.

if HB_TAB_Code='' HB_TAB_Code='M'.
if LA_TAB_Code='' LA_TAB_Code='M'.
execute.

aggregate outfile = *
/break Year CHPNAME AGEGROUP service sector Sub_Sector total HB_CODE HB_NAME HB_TAB_Code LA_TAB_Code CareProgram Data PopLookup DummyVariable
/Expenditure = sum(Expenditure).
execute.

sort cases by PopLookup.
match files file=*
/table = '/conf/irf/09-Tableau-Outputs/01-Development/02-SPSS-Outputs/01-HSC-Expenditure/Final_data/2018-19/NRAC Populations/NRAC_pops.sav'
/by PopLookup.
execute.

rename variables PopLookup=Poplookup.

compute exp_per_cap=expenditure/population.
execute.

alter type CHPNAME (a27).
alter type AGEGROUP (a7).
alter type service (a33).
alter type sector (a33).
alter type Sub_Sector (a37).

add files file = *
/file = '/conf/irf/09-Tableau-Outputs/01-Development/02-SPSS-Outputs/01-HSC-Expenditure/Final_data/2017-18/Source Output/HSC_PUB_DATA_2014-18ScotLv1.sav'.
execute.

select if Year ne '2014/15'.
execute.

save outfile = '/conf/irf/09-Tableau-Outputs/01-Development/02-SPSS-Outputs/01-HSC-Expenditure/Final_data/2018-19/Source Output/HSC_PUB_DATA_2015-19ScotLv1.sav'.
