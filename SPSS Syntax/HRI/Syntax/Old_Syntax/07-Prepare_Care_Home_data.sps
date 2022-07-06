* Encoding: UTF-8.
* FC. Nov. 2018. Syntax Updated for 2017/18 financial year 
  Variables 'Provides_nursing_care', 'DataCanx', 'Capacity 7' were excluded as they were not provided with the last Care Inspectorate data.
* Re-written by Bateman McBride, Jan 2020.
* Edited Bateman McBride, Jan 2021 to update lookups

* The purpose of this syntax is to read in data from the Care Home Inspectorate, and re-format it for use in Tableau workbooks. 
* The way this is done is by reading data, formatting the postcode variables, and then matching on to lookups that give us accurate coordinates of each care home.

* Define the file path you would like to use for your outputs.

define !path() 
"/conf/sourcedev/TableauUpdates/HRI/Outputs/"
!enddefine.

* I have chosen to read in the data from the Care Home Inspectorate as Excel, as there have been some issues reading it in as *.csv.

GET DATA
  /TYPE=XLSX
  /FILE='/conf/sourcedev/TableauUpdates/HRI/Outputs/CareHome201920.xlsx'
  /CELLRANGE=FULL
  /READNAMES=ON
  /DATATYPEMIN PERCENTAGE=95.0
  /HIDDEN IGNORE=YES.
EXECUTE.

* Ensure the Council_Area variable contains standard naming convention for LAs.

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

rename variables CSNumber = CaseNumber.
rename variables Registered_Places = Capacity7.

* We are only interested in the following subtypes for the HRI workbook.

Select if any(Subtype,'Alcohol & Drug Misuse','Blood Borne Virus','Children & Young People','Learning Disabilities','Mental Health Problems','Older People','Physical and Sensory Impairment','Respite Care and Short Breaks').
execute.

sort cases by CaseNumber.

alter type Service_Postcode(a21).
rename variables (Service_Postcode=pc7).
execute.

*Two postcodes were wrongly enetered for the care home. Replace with correct ones.

compute pc7 =replace(pc7,'DD10 4RT','DD11 4RT').
compute pc7 =replace(pc7,'G69 2YB','G53 7EF').
execute.

sort cases by pc7.

* This section reformats the postcode variable to fit with what is expected in the lookups. 
* 7-letter postcodes are a continuous string.
* 6-letter postcodes have a space in the middle.
* 5-letter postcodes have two spaces in the middle.

compute pc7 = replace(pc7, ' ', '').
compute len = length(pc7).
execute.

if len = 5 pc7 = concatenate(char.substr(pc7,1,2), "  ",char.substr(pc7,3,3)).
if len = 6 pc7 = concatenate(char.substr(pc7,1,3), " ",char.substr(pc7,4,3)).
execute. 

*************************************************************************************
* This match files allows us to bring Datazone into our dataset.

alter type pc7(a7).
sort cases by pc7.
match files file =*
/table= '/conf/irf/09-Tableau-Outputs/01-Development/03-Workbooks/09-Lookup/Tableaulookup.sav'
/by pc7.
execute.

rename variables (datazone2011=datazone).
sort cases by datazone.

* The meshblock lookup file brings in the latitude and longitude of a care home based on the postcode.

match files file =*
/table="/conf/irf/09-Tableau-Outputs/01-Development/05-CarehomeData/DZ_Meshblock11.sav"
/by datazone.
execute.

compute CH_Flag=1.
string GeoType (A10)  .
compute GeoType='CareHome'.
rename variables (pc7=Postcode).

*Add on postcode sector to allow mapping in Tableau. 

rename variables (Postcode = pc7). 
sort cases by pc7.

* This ensures we have the correct 'Post Code Sector' for all the pc7 cases in our dataset.

match files file = *
 /table = '/conf/linkage/output/lookups/Unicode/Geography/Scottish Postcode Directory/Scottish_Postcode_Directory_2020_2.sav' 
 /by pc7.
execute.

rename variables (PCSector=Postcode).

* This drops all of the unnecessary variables.

SAVE TRANSLATE OUTFILE= 
'/conf/irf/09-Tableau-Outputs/01-Development/05-CarehomeData/FinalCareHome_1920_Source.xlsx' 
/TYPE=XLS   /VERSION=12   /MAP   /REPLACE   /FIELDNAMES  
/keep ServiceName Council_Area Postcode Subtype ServiceType LA_code datazone Long Lat CH_Flag GeoType Capacity7	.

rename variables Council_Area = LCAname.

save outfile = !path + 'FinalCareHome_1920_Source.sav' 
/keep ServiceName Council_Area LCAname Postcode Subtype ServiceType LA_code datazone Long Lat CH_Flag GeoType Capacity7.

get file = !path + 'FinalCareHome_1920_Source.sav'.
