* Encoding: UTF-8.
* FC. Nov. 2018. Syntax Updated for 2017/18 financial year 
  Variables 'Provides_nursing_care', 'DataCanx', 'Capacity 7' were excluded as they were not provided with the last Care Inspectorate data.


define !path() 
"/conf/sourcedev/TableauUpdates/HRI/Outputs/"
!enddefine.
*DEFINE !Lookup()  '/conf/linkage/output/lookups/' !ENDDEFINE.


 * GET DATA  /TYPE=TXT
  /FILE="/conf/sourcedev/TableauUpdates/HRI/Outputs/CareHome201819.csv"
  /ENCODING='UTF8'
  /DELCASE=LINE
  /DELIMITERS=","
  /QUALIFIER='"'
  /ARRANGEMENT=DELIMITED
  /FIRSTCASE=2
  /IMPORTCASE=ALL
  /VARIABLES=
  CaseNumber A12
  ServiceType A27
  ServiceName A150
  CareService A40
  Subtype A31
  DateReg A8
  Quality_of_Care_and_Support F1.0
  Quality_of_Environment F1.0
  Quality_of_Staffing F1.0
  Quality_of_Mgmt_and_Lship F1.0
  CompanyName A99
  AccomStreetAddress1 A68
  AccomStreetAddress1a A68
  AccomStreetAddress1b A68
  AccomStreetAddress1c A68
  AccomPostCodeCity A25
  AccomPostCodeno A9
  AccomPhoneNumber A60
  Council_Area_Name A40.
 * CACHE.
 * EXECUTE.

GET DATA
  /TYPE=XLSX
  /FILE='/conf/sourcedev/TableauUpdates/HRI/Outputs/CareHome202021.xlsx'
  /SHEET=name 'CareHome202021'
  /CELLRANGE=FULL
  /READNAMES=ON
  /DATATYPEMIN PERCENTAGE=95.0
  /HIDDEN IGNORE=YES.
EXECUTE.

string Council_Area (a40).
recode Council_Area_Name ("Aberdeen City"="Aberdeen City") ("Aberdeenshire"="Aberdeenshire") ("Angus"="Angus")
                               ("Argyll & Bute"="Argyll and Bute")("Clackmannanshire"="Clackmannanshire")("Dumfries & Galloway"="Dumfries and Galloway")
                               ("Dundee City"="Dundee City")("East Ayrshire"="East Ayrshire")("East Dunbartonshire"="East Dunbartonshire")
                               ("East Lothian"="East Lothian")("East Renfrewshire"="East Renfrewshire")("City of Edinburgh"="City of Edinburgh")
                               ("Falkirk"="Falkirk")("Fife"="Fife")("Glasgow City"="Glasgow")("Highland"="Highland")("Inverclyde"="Inverclyde")("Midlothian"="Midlothian")
                               ("Moray"="Moray")("Na h-Eileanan Siar"="Western Isles")("North Ayrshire"="North Ayrshire")("North Lanarkshire"="North Lanarkshire")("Orkney Islands"="Orkney")
                               ("Perth & Kinross"="Perth and Kinross")("Renfrewshire"="Renfrewshire")("Scottish Borders"="Scottish Borders")("Shetland Islands"="Shetland")
                               ("South Ayrshire"="South Ayrshire")("South Lanarkshire"="South Lanarkshire")("Stirling"="Stirling")("West Dunbartonshire"="West Dunbartonshire")
                               ("West Lothian"="West Lothian") into Council_Area.
execute.

string Partnership(a40).
String Clacks(a30).
if Partnership = '' Partnership = Council_Area.
IF Partnership="Clackmannanshire" or Partnership="Stirling" Clacks="Clackmannanshire & Stirling".
VARSTOCASES
 /MAKE Partnership FROM Partnership Clacks.

delete variables Council_Area.
rename variables Partnership = Council_Area.

frequencies Council_Area.

rename variables CSNumber = CaseNumber Service_Postcode = accompostcodeno Registered_Places = Capacity7.
alter type accompostcodeno(a9).

match files file = *
/in=mainfile
/table='/conf/irf/09-Tableau-Outputs/01-Development/05-CarehomeData/CareHomePostCodeLookup.sav'
/in=lookupfile
/by CaseNumber.
execute.

frequencies accompostcodeno.
sort cases by accompostcodeno.
execute.

crosstabs mainfile by lookupfile.
delete variables mainfile lookupfile.

sort cases by CaseNumber.

match files file =*/in=mainfile
/table='/conf/irf/09-Tableau-Outputs/01-Development/05-CarehomeData/CareHomePostCodeLookup1415.sav'/in=lookupfile
/by CaseNumber.
execute.

crosstabs mainfile by lookupfile.
delete variables mainfile lookupfile.

if  AccomPostCodeno = ' '  AccomPostCodeno =AccomPostCodeno1415.
execute.

compute check=0.
if  AccomPostCodeno = ' '  check=1.
frequencies check.

delete variables AccomPostCodeno1415.

alter type AccomPostCodeno  (A21).
rename variables (AccomPostCodeno=pc7).
execute.

*Two postcodes were wrongly enetered for the care home. Replace with correct ones.
compute pc7 =replace(pc7,'DD10 4RT','DD11 4RT').
compute pc7 =replace(pc7,'G69 2YB','G53 7EF').
execute.

sort cases by pc7.

compute len=length(pc7).
execute.

frequencies len.

if len=8 pc7=concatenate(char.substr(pc7,1,4),char.substr(pc7,6,3)).
if len=7 pc7=concatenate(char.substr(pc7,1,3),char.substr(pc7,5,3)).
if len=6 pc7=concatenate(char.substr(pc7,1,3)," ",char.substr(pc7,4,3)).
execute.

frequencies pc7.

alter type pc7(a7).
sort cases by pc7.
match files file =*/in=mainfile
/table= '/conf/irf/09-Tableau-Outputs/01-Development/03-Workbooks/09-Lookup/Tableaulookup.sav'/in=lookupfile
/by pc7.
execute.

crosstabs mainfile by lookupfile.

delete variables mainfile lookupfile.

sort cases by datazone.

match files file =*/in=mainfile
/table="/conf/irf/09-Tableau-Outputs/01-Development/05-CarehomeData/DZ_Meshblock11.sav"/in=lookupfile
/by datazone.
execute.

*care home with postcode AB55 5JS has no corresponding datazone information.

crosstabs mainfile by lookupfile.

compute CH_Flag=1.
string GeoType (A10)  .
compute GeoType='CareHome'.
rename variables (pc7=Postcode).
exe.

*Add on postcode sector to allow mapping in Tableau. 

rename variables (Postcode = pc7). 
sort cases by pc7.

match files file = *
 /table = '/conf/linkage/output/lookups/Unicode/Geography/Scottish Postcode Directory/Scottish_Postcode_Directory_2021_2.sav'
 /by pc7.
execute.

rename variables (PCSector=Postcode).

save outfile = !path + 'FinalCareHome_2021.zsav' 
/keep ServiceName Council_Area Postcode Subtype ServiceType LA_code datazone Long Lat CH_Flag GeoType Capacity7
/zcompressed.


SAVE TRANSLATE 
OUTFILE= '/conf/irf/09-Tableau-Outputs/01-Development/05-CarehomeData/FinalCareHome_2021.xlsx' 
/TYPE=XLS  
/VERSION=12   
/MAP  
/REPLACE   
/FIELDNAMES  
/keep ServiceName Council_Area Postcode Subtype ServiceType LA_code datazone Long Lat CH_Flag GeoType Capacity7.

get file = !path + 'FinalCareHome_2021.zsav'.

***Select only those Service Subtypes to be used for HRI update consistently with 2017/18 Care Home information.***

Select if any(Subtype,'Alcohol & Drug Misuse','Blood Borne Virus','Children & Young People','Learning Disabilities','Mental Health Problems','Older People','Physical and Sensory Impairment','Respite Care and Short Breaks').
execute.

frequencies postcode.

SAVE TRANSLATE OUTFILE= 
'/conf/irf/09-Tableau-Outputs/01-Development/05-CarehomeData/FinalCareHome_2021_Source.xlsx' 
/TYPE=XLS   /VERSION=12   /MAP   /REPLACE   /FIELDNAMES  
/keep ServiceName Council_Area Postcode Subtype ServiceType LA_code datazone Long Lat CH_Flag GeoType Capacity7	.

rename variables Council_Area = LCAname.

save outfile = !path + 'FinalCareHome_2021_Source.sav' 
/keep ServiceName LCAname Postcode Subtype ServiceType LA_code datazone Long Lat CH_Flag GeoType Capacity7.

get file = !path + 'FinalCareHome_2021_Source.sav'.

 * match files file = *
/table = !path + 'HRI_All.sav'
/by datazone.
 * execute.










