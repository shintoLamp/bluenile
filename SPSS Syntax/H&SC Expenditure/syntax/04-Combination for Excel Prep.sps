* Encoding: UTF-8.
* Code to produce individual financial year data extract for Tableau.  Once all years are complete combine.

*Tayside, Fife, western Isles and Forth Valley.
******************************************************************************************************************.
*combine NHS and LFR mapped expenditure.
Get file =!pathname3 + 'LFR3_'+!Year+'_Final.sav'.

IF Service="Social Care" Service="02-Social Care".
execute.

*/drop detailed_level_for_match.
*Make variables same length as in All_chps_final (for adding files).
Alter type Sub_Sector(a41).
Alter type HSCP_NAME (a141).
Alter type AGEGROUP (a15).
alter type service (a20).
alter type sector (a37).
exe.

RENAME VARIABLES detailed_level_for_match = Detail_Sector.
alter type Detail_Sector (A60).
exe.
 
aggregate outfile = *
 /break Year hbr HSCP_NAME AGEGROUP service sector Sub_Sector Detail_Sector
 /Expenditure = sum(Expenditure).
exe. 


SAVE OUTFILE =!pathname3 + 'LFR3_'+!Year+'_Final.sav'.

add files file=!pathname3 + 'LFR3_'+!Year+'_Final.sav'
/file =!pathname3 +'/All-chps-Final-'+!year+'.sav'.
exe.

if hbr='G' and HSCP_NAME='South Lanarkshire' HSCP_NAME='Non HSCP'.
execute.

dataset name DataBase.

dataset Activate DataBase.

 * /*Extract for national indicators. Total for HSCPs and Scotland of all expenditure excluding <18 yr olds.
 * dataset copy Indi20.
 * dataset Activate Indi20.

 * select if (AGEGROUP<>"<18" AND AGEGROUP<>"All") and char.substr(HSCP_NAME,1,3)<>"NHS".
 * EXECUTE.

 * DATASET ACTIVATE Indi20.
 * DATASET DECLARE RightAge.
 * AGGREGATE
  /OUTFILE='RightAge'
  /BREAK=Year HSCP_NAME
  /Expenditure=SUM(Expenditure).

 * dataset close Indi20.
 * dataset activate RightAge.

 * DATASET DECLARE RightAgeSc.
 * AGGREGATE
  /OUTFILE='RightAgeSc'
  /BREAK=Year
  /Expenditure=SUM(Expenditure).
 * dataset activate RightAgeSc.
 * string HSCP_NAME(a141).
 * compute HSCP_NAME="SCOTLAND".
 * execute.


 * DATASET ACTIVATE RightAge.
 * ADD FILES /FILE=*
  /FILE='RightAgeSc'.
 * EXECUTE.
 * dataset close RightAgeSc.

 * SAVE TRANSLATE OUTFILE='/conf/irf/09-Tableau-Outputs/01-Development/02-SPSS-Outputs/01-HSC-Expenditure/Final_data/'+!Year+'/Indicator20Totals_JN_CS.xlsx'
  /TYPE=XLS
  /VERSION=12
  /MAP
  /REPLACE
  /FIELDNAMES
  /CELLS=VALUES
  /keep Year HSCP_NAME Expenditure.

******************************************************************************************************************************




String AGEGROUP1(a15).
COMPUTE AGEGROUP1=AGEGROUP.
if AGEGROUP="<18" AGEGROUP1="0-64".
if AGEGROUP="18-64" AGEGROUP1="0-64".
if AGEGROUP="75-84" AGEGROUP1="75+".
if AGEGROUP="85+" AGEGROUP1="75+".
EXECUTE.


DATASET ACTIVATE DataBase.
DATASET DECLARE DATA2.
AGGREGATE
  /OUTFILE='DATA2'
  /BREAK=Year hbr HSCP_NAME AGEGROUP1 service sector Sub_Sector Detail_Sector
  /Expenditure=SUM(Expenditure).

DATASET ACTIVATE DATA2.


DATASET COPY  DATA2A.
DATASET ACTIVATE  DATA2A.
FILTER OFF.
USE ALL.
SELECT IF (AGEGROUP1="65-74" OR AGEGROUP1="75+").
EXECUTE.
DATASET ACTIVATE  DATA2A.

COMPUTE AGEGROUP1="65+".
EXECUTE.

DATASET DECLARE DATA2B.
AGGREGATE
  /OUTFILE='DATA2B'
  /BREAK=Year hbr HSCP_NAME AGEGROUP1 service sector Sub_Sector Detail_Sector
  /Expenditure=SUM(Expenditure).

DATASET CLOSE DATA2A.

DATASET ACTIVATE  DATA2.

ADD FILES /FILE=*
  /FILE='DATA2B'.
EXECUTE.

RENAME VARIABLES AGEGROUP1=AGEGROUP.

SELECT IF (AGEGROUP<>"65-74").
EXECUTE.

if AGEGROUP="Miss" AGEGROUP="Missing".
execute.

DATASET NAME DataBase.

DATASET CLOSE DATA2B.




String HB_TAB_Code (a6).
if HBR = 'A' HB_TAB_Code =	'HBVC9'.
if HBR = 'B'	HB_TAB_Code =	'HBVC5'.
if HBR = 'Y'	HB_TAB_Code =	'HBVC11'.
if HBR = 'F'	HB_TAB_Code =	'HBVC12'.
if HBR = 'V'	HB_TAB_Code =	'HBVC7'.
if HBR = 'N'	HB_TAB_Code =	'HBVC14'.
if HBR = 'G'	HB_TAB_Code =	'HBVC8'.
if HBR = 'H'	HB_TAB_Code =	'HBVC13'.
if HBR = 'L'	HB_TAB_Code =	'HBVC1'.
if HBR = 'S'	HB_TAB_Code =	'HBVC3'.
if HBR = 'R'	HB_TAB_Code =	'HBVC6'.
if HBR = 'Z'	HB_TAB_Code =	'HBVC4'.
if HBR = 'T'	HB_TAB_Code =	'HBVC10'.
if HBR = 'W'	HB_TAB_Code =	'HBVC2'.
if HBR = 'O' HB_TAB_Code='Non Scottish Residents'.

String LA_TAB_Code (a7).
if HSCP_NAME = 'Scottish Borders' LA_TAB_Code =	'LAVC11'.
if HSCP_NAME = 'Fife' LA_TAB_Code =	'LAVC2'.
if HSCP_NAME = 'Orkney Islands' LA_TAB_Code =	'LAVC26'.
if HSCP_NAME = 'Orkney' LA_TAB_Code =	'LAVC26'.
if HSCP_NAME = 'Western Isles' LA_TAB_Code =	'LAVC8'.
if HSCP_NAME = 'Dumfries & Galloway' LA_TAB_Code =	'LAVC20'.
if HSCP_NAME = 'Shetland Islands' LA_TAB_Code =	'LAVC9'.
if HSCP_NAME = 'Shetland' LA_TAB_Code =	'LAVC9'.
if HSCP_NAME = 'North Ayrshire' LA_TAB_Code =	'LAVC10'.
if HSCP_NAME = 'South Ayrshire' LA_TAB_Code =	'LAVC21'.
if HSCP_NAME = 'East Ayrshire' LA_TAB_Code =	'LAVC1'.
if HSCP_NAME = 'East Dunbartonshire' LA_TAB_Code =	'LAVC22'.
if HSCP_NAME = 'Glasgow City' LA_TAB_Code =	'LAVC23'.
if HSCP_NAME = 'East Renfrewshire' LA_TAB_Code =	'LAVC12'.
if HSCP_NAME = 'West Dunbartonshire' LA_TAB_Code =	'LAVC13'.
if HSCP_NAME = 'Renfrewshire' LA_TAB_Code =	'LAVC31'.
if HSCP_NAME = 'Inverclyde' LA_TAB_Code =	'LAVC3'.
if HSCP_NAME = 'Highland' LA_TAB_Code =	'LAVC4'.
if HSCP_NAME = 'Argyll & Bute' LA_TAB_Code =	'LAVC24'.
if HSCP_NAME = 'North Lanarkshire' LA_TAB_Code =	'LAVC32'.
if HSCP_NAME = 'South Lanarkshire' LA_TAB_Code =	'LAVC14'.
if HSCP_NAME = 'Aberdeen City' LA_TAB_Code =	'LAVC25'.
if HSCP_NAME = 'Aberdeenshire' LA_TAB_Code =	'LAVC15'.
if HSCP_NAME = 'Moray' LA_TAB_Code =	'LAVC5'.
if HSCP_NAME = 'East Lothian' LA_TAB_Code =	'LAVC27'.
if HSCP_NAME = 'West Lothian' LA_TAB_Code =	'LAVC17'.
if HSCP_NAME = 'Midlothian' LA_TAB_Code =	'LAVC6'.
if HSCP_NAME = 'City of Edinburgh' LA_TAB_Code =	'LAVC16'.
if HSCP_NAME = 'Perth & Kinross' LA_TAB_Code =	'LAVC7'.
if HSCP_NAME = 'Dundee City' LA_TAB_Code =	'LAVC28'.
if HSCP_NAME = 'Angus' LA_TAB_Code =	'LAVC30'.
if HSCP_NAME = 'Clackmannanshire' LA_TAB_Code =	'LAVC18'.
if HSCP_NAME = 'Stirling' LA_TAB_Code =	'LAVC19'.
if HSCP_NAME = 'Falkirk' LA_TAB_Code =	'LAVC29'.
if HBR = 'O' LA_TAB_Code='Non Scottish Residents'.
EXECUTE.

*Hopefully Just for 2017.... CHP to HSCP Transfer has resulted in a number of cases where there are no 
CHPs, so they need coded.

if HSCP_NAME="Non HSCP" LA_TAB_Code =	'Missing'.
Execute.

*code the HBs.
if char.substr(HSCP_NAME,1,3)='NHS' LA_TAB_Code=HB_TAB_Code.
execute.


SORT CASES BY Sub_sector (A) AGEGROUP(A).
alter type sub_sector (a41).
exe.

match files file= *
/table=!pathname2 + 'NRAC_Care_Progs_by_age.sav'
/by Sub_Sector AGEGROUP.
exe.

*get file=!pathname2 + 'NRAC_Care_Progs_by_age.sav'.


***Lables all Sub-Sectors with the correct number - BEWARE these may change over time if more Sub-Sectors are added.
string Sub_Sector_alt (a40).
if sub_sector eq 'Acute' and detail_Sector eq 'IP - Non elective' Sub_Sector_alt eq '01-Acute IP - Non elective'.
if sub_sector eq 'Acute' and detail_Sector eq 'IP - Elective' Sub_Sector_alt eq '02-Acute IP - Elective'.
if sub_sector eq 'Acute' and detail_Sector eq 'IP - Other' Sub_Sector_alt eq '03-Acute IP - Other'.
if sub_sector eq 'Mental Health' and detail_Sector eq 'IP - Non elective' Sub_Sector_alt eq '04-Mental Health IP - Non elective'.
if sub_sector eq 'Mental Health' and detail_Sector eq 'IP - Elective' Sub_Sector_alt eq '05-Mental Health IP - Elective'.
if sub_sector eq 'Mental Health' and detail_Sector eq 'IP - Other' Sub_Sector_alt eq '06-Mental Health IP - Other'.
if sub_sector eq 'GLS' and detail_Sector eq 'IP - Non elective' Sub_Sector_alt eq '07-Geriatric LS IP - Non elective'.
if sub_sector eq 'GLS' and detail_Sector eq 'IP - Elective' Sub_Sector_alt eq '08-Geriatric LS IP - Elective'.
if sub_sector eq 'GLS' and detail_Sector eq 'IP - Other' Sub_Sector_alt eq '09-Geriatric LS IP - Other'.
if detail_sector eq 'IP' sub_sector_alt eq '10-Maternity IP'.
if detail_sector eq 'SCBU (HB treatment total)' sub_sector_alt eq '11-SCBU (HB treatment total)'.
if sub_sector eq 'Acute' and detail_sector eq 'Day cases' sub_sector_alt eq '12-Acute Day cases'.
if sub_sector eq 'Maternity' and detail_sector eq 'Day cases' sub_sector_alt eq '13-Maternity Day cases'.
if detail_sector eq 'Accident & Emergency' sub_Sector_alt eq '14-Outpatients - Accident & Emergency'.
if detail_sector eq 'Consultant - Total' sub_sector_alt eq '15-Outpatients - Consultant New'.
if detail_sector eq 'Consultant - Return' sub_sector_alt eq '15*-Outpatients - Consultant Return'.
if detail_sector eq 'Outpatients' sub_sector_alt eq '16-Outpatients - other'.
if detail_sector eq 'Other' and service eq '01-NHS' sub_sector_alt eq '16-Outpatients - other'.
if detail_sector eq 'Other' and service eq 'Institutional Based' sub_sector_alt eq '16-Outpatients - other'.
if detail_sector eq 'Day Patients' sub_sector_alt eq '17-Day Patients'.
if detail_sector eq 'District Nursing' sub_sector_alt eq '19-District Nursing'.
if detail_sector eq 'Health Visiting' sub_sector_alt eq '20-Health Visiting'.
if sub_Sector eq 'Community - Other' sub_sector_alt eq '21-Community Health - other'.
if sub_sector eq 'GMS' sub_sector_alt eq '23-GMS'.
if sub_sector eq 'GP Prescribing' sub_sector_alt eq '24-GP Prescribing'.
if detail_sector eq 'General Dental Services' sub_sector_alt eq '26-General Dental Services'.
if detail_sector eq 'General Ophthalmic Services' sub_sector_alt eq '27-General Ophthalmic Servicess'.
if sub_sector eq 'Care homes' sub_sector_alt eq '27-Care Homes'.
if sector eq 'Accommodation based services' and sub_sector eq 'Other' sub_sector_alt eq '28-Other-Accomodation-based service'.
if sub_sector eq 'Home Care' sub_sector_alt eq '30-Home Care'.
if sub_sector eq 'Direct Payments' sub_sector_alt eq '32-Direct Payments'.
if sector eq 'Community based services' and sub_sector eq 'Other' sub_sector_alt eq '33-Other-Community-based service'.
if detail_sector eq 'Chiropody' sub_sector_alt eq '21-Community Health - other'.
if detail_sector eq 'Dietetics' sub_sector_alt eq '21-Community Health - other'.
if detail_sector eq 'Occupational Therapy' sub_sector_alt eq '21-Community Health - other'.
if detail_sector eq 'Outpatients - Nurse led' sub_sector_alt eq '16-Outpatients - other'.
if detail_sector eq 'Physiotherapy' sub_sector_alt eq '21-Community Health - other'.
if detail_sector eq 'Speech Therapy' sub_sector_alt eq '21-Community Health - other'.
if sub_sector eq 'Day Care' sub_sector_alt eq '31-Day Care'.
execute.




***Corrects any issues with sector or service names.
string sector_alt (a30).
if sector eq 'Hospital' sector_alt eq '01-Hospital'.
if sector eq 'NHS - Community' Sector_alt eq '02-Community'.
if sector eq 'Family Health Services' sector_alt eq '03-FamilyHealthServices'.
if sector eq 'Other' sector_alt eq '04-Other'.
if sector eq 'Accommodation based services' sector_alt eq '06-Accommodation-based services'.
if sector eq 'Community based services' sector_alt eq '07-Community-based services'.
frequencies variables = sector_alt.

string Service_alt (a30).
if service eq '01-NHS' service_alt eq '01-Health'.
if service eq 'Social Care' service_alt eq '02-Social Care'.
if service eq 'Community Based' service_alt eq 'Community-Based-Care'.
if service eq 'Institutional Based' service_alt eq 'Institutional-Based-Care'.
exe.

do if sub_sector_alt ne '' and (char.substr(detail_sector, 1, 5) ne 'Total').
compute sub_sector = sub_sector_alt.
else.
compute sub_sector = detail_Sector.
end if.
if sector_alt ne '' sector eq sector_alt.
if service_alt ne '' service eq service_alt.
execute.

*this bit is fine.
 if Sub_Sector="Other" Sub_Sector="16-Outpatients - other".
 execute.

if Detail_Sector="Pharmaceutical services - Other" sub_sector="999".
execute.

DATASET ACTIVATE DataBase.
DATASET DECLARE DatasetBasePrime.
AGGREGATE
  /OUTFILE='DatasetBasePrime'
  /BREAK=Year hbr HSCP_NAME AGEGROUP HB_TAB_Code LA_TAB_Code service sector Sub_Sector CareProgram
  /Expenditure=SUM(Expenditure).


DATASET ACTIVATE DatasetBasePrime.
DATASET close DataBase.


* Scotland Totals.

 * USE ALL.
 * COMPUTE filter_$=(Sub_Sector<>"999").
 * VARIABLE LABELS filter_$ 'Sub_Sector<>"999" (FILTER)'.
 * VALUE LABELS filter_$ 0 'Not Selected' 1 'Selected'.
 * FORMATS filter_$ (f1.0).
 * FILTER BY filter_$.
 * EXECUTE.

  select if NOT(HB_TAB_Code="Non Sc" and sector="03-FamilyHealthServices").
  Execute.


DATASET ACTIVATE DatasetBasePrime.
USE ALL.
COMPUTE filter_$=(HB_TAB_Code=LA_TAB_Code).
VARIABLE LABELS filter_$ 'HB_TAB_Code=LA_TAB_Code (FILTER)'.
VALUE LABELS filter_$ 0 'Not Selected' 1 'Selected'.
FORMATS filter_$ (f1.0).
FILTER BY filter_$.
EXECUTE.

DATASET DECLARE Scotland.
AGGREGATE
  /OUTFILE='Scotland'
  /BREAK=Year AGEGROUP service sector Sub_Sector
  /Expenditure=SUM(Expenditure).
DATASET ACTIVATE Scotland.

string HB_TAB_Code(a6).
string LA_TAB_Code(a7).
compute HB_TAB_Code="M".
compute LA_TAB_Code="M".
execute.

DATASET ACTIVATE DatasetBasePrime.

use all.
delete variables filter_$.

ADD FILES /FILE=*
  /FILE='Scotland'.
EXECUTE.

dataset close Scotland.

*Create Subtotals

*extract for tableau other.
dataset copy SFR24.
dataset activate SFR24.

select if Sub_Sector='SFR24 Sub-contracted'.
exe.

SAVE OUTFILE ='/conf/irf/09-Tableau-Outputs/01-Development/02-SPSS-Outputs/01-HSC-Expenditure/Final_data/'+!Year+'/SFR24.sav'.

DATASET ACTIVATE DatasetBasePrime.

Dataset close SFR24.

*Sector Totals

select if not any(Sub_Sector, '999', 'SFR24 Sub-contracted').
exe.

 * DATASET ACTIVATE DatasetBasePrime.
 * USE ALL.
 * COMPUTE filter_$=(Sub_Sector<>"26-General Dental Services" and Sub_Sector<>"27-General "+
    "Ophthalmic Servicess").
 * VARIABLE LABELS filter_$ 'Sub_Sector<>"26-General Dental Services" and Sub_Sector<>"27-General '+
    'Ophthalmic Servicess" (FILTER)'.
 * VALUE LABELS filter_$ 0 'Not Selected' 1 'Selected'.
 * FORMATS filter_$ (f1.0).
 * FILTER BY filter_$.
 * EXECUTE.

*removed from below CareProgram.

DATASET DECLARE SectorSum.
AGGREGATE
  /OUTFILE='SectorSum'
  /BREAK=Year hbr HSCP_NAME AGEGROUP HB_TAB_Code LA_TAB_Code service sector 
  /Expenditure=SUM(Expenditure).
dataset activate SectorSum.

string Sub_Sector(a41).
if char.substr(Sector,1,2)="01" Sub_Sector="18-Total Hospital".
if char.substr(Sector,1,2)="02" Sub_Sector="22-Total Community".
if char.substr(Sector,1,2)="04" Sub_Sector="99-Other".
if char.substr(Sector,1,2)="03" Sub_Sector="25-Total Family Health Services".
if char.substr(Sector,1,2)="06" Sub_Sector="29-Total Accommodation based services".
if char.substr(Sector,1,2)="07" Sub_Sector="34-Total Community based services".
execute.


DATASET ACTIVATE DatasetBasePrime.

USE ALL.

ADD FILES /FILE=*
  /FILE='SectorSum'.
EXECUTE.

dataset activate SectorSum.

* removed from below CareProgram.
DATASET DECLARE ServiceSum.
AGGREGATE
  /OUTFILE='ServiceSum'
  /BREAK=Year hbr HSCP_NAME AGEGROUP HB_TAB_Code LA_TAB_Code service 
  /Expenditure=SUM(Expenditure).
dataset activate ServiceSum.


string Sector(a37).
string Sub_Sector(a41).


if char.substr(service,1,2)="01"  Sector='26-Total NHS'.
if char.substr(service,1,2)="02"  Sector='35-Total Social Care'.
if char.substr(service,1,2)="01"  Sub_Sector='26-Total NHS'.
if char.substr(service,1,2)="02"  Sub_Sector='35-Total Social Care'.
execute.


DATASET ACTIVATE DatasetBasePrime.

ADD FILES /FILE=*
  /FILE='ServiceSum'.
EXECUTE.

dataset activate SectorSum.


*removed from below CareProgram.
DATASET DECLARE GrandTotal.
AGGREGATE
  /OUTFILE='GrandTotal'
  /BREAK=Year hbr HSCP_NAME AGEGROUP HB_TAB_Code LA_TAB_Code 
  /Expenditure=SUM(Expenditure).
dataset activate GrandTotal.

string Service(a20).
string Sector(a37).
string Sub_Sector(a41).

compute Service="35-NHS + Social Care".
compute Sector='35-NHS + Social Care'.
compute Sub_Sector='35-NHS + Social Care'.
execute.


DATASET ACTIVATE DatasetBasePrime.

ADD FILES /FILE=*
  /FILE='GrandTotal'.
EXECUTE.

dataset close SectorSum.
dataset close ServiceSum.
dataset close GrandTotal.

if service="01-NHS" service="01-Health".
execute.

string Total(a1).

Compute Total="N".
execute.

if Sub_Sector="26-Total NHS" Total="Y".
if Sub_Sector="03-NHS + Social Care" Total="Y".
if Sub_Sector="35-Total Social Care" Total="Y".
if Sub_Sector="27-Care Homes" Total="D".
if Sub_Sector="28-Other-Accomodation-based service" Total="D".
if Sub_Sector="30-Home Care" Total="D".
if Sub_Sector="31-Day Care" Total="D".
if Sub_Sector="32-Direct Payments" Total="D".
if Sub_Sector="33-Other-Community-based service" Total="D".
if Sub_Sector="18-Total Hospital" Total="S".
if Sub_Sector="22-Total Community" Total="S".
if Sub_Sector="25-Total Family Health Services" Total="S".
if Sub_Sector="29-Total Accommodation based services" Total="S".
if Sub_Sector="34-Total Community based services" Total="S".
execute.

if LA_TAB_Code =" " LA_TAB_Code="Missing".
execute.

SAVE OUTFILE='/conf/irf/09-Tableau-Outputs/01-Development/02-SPSS-Outputs/01-HSC-Expenditure/Final_data/'+!Year+'/ExcelOutput.sav'.
EXE.

* LFR Output.

SAVE TRANSLATE OUTFILE='/conf/irf/09-Tableau-Outputs/01-Development/02-SPSS-Outputs/01-HSC-Expenditure/Final_data/'+!Year+'/LFR_exceldata.xlsx'
  /TYPE=XLS
  /VERSION=12
  /MAP
  /REPLACE
  /FIELDNAMES
  /CELLS=VALUES
  /keep Year HB_TAB_Code LA_TAB_Code AGEGROUP service sector Sub_Sector Total Expenditure.

*Service Output.



DATASET ACTIVATE DatasetBasePrime.
USE ALL.
COMPUTE filter_$=(Total="S").
VARIABLE LABELS filter_$ 'Total="S" (FILTER)'.
VALUE LABELS filter_$ 0 'Not Selected' 1 'Selected'.
FORMATS filter_$ (f1.0).
FILTER BY filter_$.
EXECUTE.

DATASET DECLARE Service.
AGGREGATE
  /OUTFILE='Service'
  /BREAK=Year hbr HSCP_NAME AGEGROUP HB_TAB_Code LA_TAB_Code service Total
  /Expenditure=SUM(Expenditure).
dataset activate Service.

if char.substr(service,1,2)="01" service="01-NHS".
execute.

alter type LA_TAB_Code (a7).
if LA_TAB_Code =" " LA_TAB_Code="Missing".

Compute Total="N".
execute.

SAVE TRANSLATE OUTFILE='/conf/irf/09-Tableau-Outputs/01-Development/02-SPSS-Outputs/01-HSC-Expenditure/Final_data/'+!Year+'/Service_exceldata.xlsx'
  /TYPE=XLS
  /VERSION=12
  /MAP
  /REPLACE
  /FIELDNAMES
  /CELLS=VALUES
  /keep Year HB_TAB_Code LA_TAB_Code AGEGROUP service Total Expenditure.


DATASET ACTIVATE DatasetBasePrime.
use all.

string BOC_sector(a40).

if char.substr(Sector,1,2)="01" BOC_sector="Institutional-Based-Care".
if char.substr(Sector,1,2)="02" BOC_sector="Community-Based-Care".
if char.substr(Sector,1,2)="03" BOC_sector="Community-Based-Care".
if char.substr(Sector,1,2)="06" BOC_sector="Institutional-Based-Care".
if char.substr(Sector,1,2)="07" BOC_sector="Community-Based-Care".
execute.


DATASET ACTIVATE DatasetBasePrime.
USE ALL.
COMPUTE filter_$=(Total="S").
VARIABLE LABELS filter_$ 'Total="S" (FILTER)'.
VALUE LABELS filter_$ 0 'Not Selected' 1 'Selected'.
FORMATS filter_$ (f1.0).
FILTER BY filter_$.
EXECUTE.

DATASET DECLARE BOC.
AGGREGATE
  /OUTFILE='BOC'
  /BREAK=Year hbr HSCP_NAME AGEGROUP HB_TAB_Code LA_TAB_Code BOC_sector Total
  /Expenditure=SUM(Expenditure).
dataset activate BOC.

Compute Total="N".
execute.

if LA_TAB_Code =" " LA_TAB_Code="Missing".

select if BOC_sector="Institutional-Based-Care" or BOC_sector="Community-Based-Care".
EXECUTE.

SAVE TRANSLATE OUTFILE='/conf/irf/09-Tableau-Outputs/01-Development/02-SPSS-Outputs/01-HSC-Expenditure/Final_data/'+!Year+'/BOC_exceldata.xlsx'
  /TYPE=XLS
  /VERSION=12
  /MAP
  /REPLACE
  /FIELDNAMES
  /CELLS=VALUES
  /keep Year HB_TAB_Code LA_TAB_Code AGEGROUP BOC_sector Total Expenditure.



dataset close Service.
dataset close BOC.

dataset activate DatasetBasePrime.

use all.




