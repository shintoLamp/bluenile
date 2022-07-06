* Encoding: UTF-8.
IF Age_Band = "<65" Age_Band = "0-64".
EXECUTE.

IF hours_band = " < 2 hours" Hours_Band = "0 to 2 hours".
IF hours_band = "<2 hours" Hours_Band = "0 to 2 hours".
IF hours_band = "10+ hours" Hours_Band = "10 hours +".
IF hours_band = "2 to less than 4 hours" Hours_Band = "2 to 4 hours".
IF hours_band = "4 to less than 10 hours" Hours_Band = "4 to 10 hours".
EXECUTE.

string LOOKUP (a100).
compute LOOKUP=concat(File,Locality,Type).
execute.

rename variables Breakdown=breakdown_2.
rename variables Breakdown_type=breakdown_type_2.
rename variables SEX=Sex.
rename variables ServiceType=Servicetype. 

if sending_location='Aberdeen City' and Locality ne 'Aberdeen City' and Locality ne '' and Locality ne 'Aberdeen North' and Locality ne 'Aberdeen Central' and Locality ne 'Aberdeen South' and Locality ne 'Aberdeen West' Locality='Outside Partnership'.
if sending_location='Aberdeenshire' and Locality ne 'Aberdeenshire' and Locality ne '' and Locality ne 'Banff & Buchan' and Locality ne 'Buchan' and Locality ne 'Formartine' and 
Locality ne 'Garioch' and Locality ne 'Kincardine & Mearns' and Locality ne 'Marr' Locality='Outside Partnership'.
if sending_location='Angus' and Locality ne 'Angus' and Locality ne '' and Locality ne 'Angus North East' and Locality ne 'Angus North West' and Locality ne 'Angus South East' and Locality ne 'Angus South West' Locality='Outside Partnership'.
if sending_location='Argyll & Bute' and Locality ne 'Argyll & Bute' and Locality ne '' and Locality ne 'Bute' and Locality ne 'Helensburgh and Lomond' and Locality ne 'Islay Jura and Colonsay' and Locality ne 'Kintyre' and Locality ne 'Mid Argyll' and
Locality ne 'Mull Iona Coll and Tiree' and Locality ne 'Oban and Lorn' Locality='Outside Partnership'.
if sending_location='Borders' and Locality ne 'Borders' and Locality ne '' and Locality ne 'Berwickshire' and Locality ne 'Cheviot' and Locality ne 'Eildon' and 
Locality ne 'Teviot and Liddesdale' and Locality ne 'Tweeddale' Locality='Outside Partnership'.
if sending_location='Clackmannanshire' and Locality ne 'Clackmannanshire' and Locality ne '' Locality='Outside Partnership'.
if sending_location='Dumfries & Galloway' and Locality ne 'Dumfries & Galloway' and Locality ne '' and Locality ne 'Annandale & Eskdale' and Locality ne 'Nithsdale' and Locality ne 'Stewartry' and
Locality ne 'Wigtownshire' Locality='Outside Partnership'.
if sending_location='Dundee City' and Locality ne 'Dundee City' and Locality ne '' and Locality ne 'Coldside' and Locality ne 'Dundee East End' and Locality ne 'Dundee North East' and
Locality ne 'Dundee West End' and Locality ne 'Lochee' and Locality ne 'Maryfield' and Locality ne 'Strathmartine' and Locality ne 'The Ferry' Locality='Outside Partnership'.
if sending_location='East Ayrshire' and Locality ne 'East Ayrshire' and Locality ne '' and Locality ne 'Kilmarnock' and Locality ne 'Northern' and Locality ne 'Southern' Locality='Outside Partnership'.
if sending_location='East Dunbartonshire' and Locality ne 'East Dunbartonshire' and Locality ne '' and Locality ne 'East Dunbartonshire East' and Locality ne 'East Dunbartonshire West' Locality='Outside Partnership'.
if sending_location='East Lothian' and Locality ne 'East Lothian' and Locality ne '' and Locality ne 'East Lothian East' and Locality ne 'East Lothian West' Locality='Outside Partnership'.
if sending_location='East Renfrewshire' and Locality ne 'East Renfrewshire' and Locality ne '' and Locality ne 'Barrhead' and Locality ne 'Eastwood' Locality='Outside Partnership'.
if sending_location='Edinburgh City' and Locality ne 'Edinburgh City' and Locality ne '' and Locality ne 'Edinburgh North East' and Locality ne 'Edinburgh North West' and Locality ne 'Edinburgh South East' and
Locality ne 'Edinburgh South West' Locality='Outside Partnership'.
if sending_location='Falkirk' and Locality ne 'Falkirk' and Locality ne '' and Locality ne 'Falkirk Central' and Locality ne 'Falkirk East' and Locality ne 'Falkirk West' Locality='Outside Partnership'.
if sending_location='Fife' and Locality ne 'Fife' and Locality ne '' and Locality ne 'City of Dunfermline' and Locality ne 'Cowdenbeath' and Locality ne 'Glenrothes' and Locality ne 'Kirkcaldy' and
Locality ne 'Levenmouth' and Locality ne 'North East Fife' and Locality ne 'South West Fife' Locality='Outside Partnership'.
if sending_location='Glasgow City' and Locality ne 'Glasgow City' and Locality ne '' and Locality ne 'Glasgow North East' and Locality ne 'Glasgow North West' and Locality ne 'Glasgow South' Locality='Outside Partnership'.
if sending_location='Highland' and Locality ne 'Highland' and Locality ne '' and Locality ne 'Badenoch and Strathspey' and Locality ne 'Caithness' and Locality ne 'East Ross' and Locality ne 'Inverness' and Locality ne 'Lochaber' and 
Locality ne 'Mid Ross' and Locality ne 'Nairn & Nairnshire' and Locality ne 'Skye, Lochalsh and West Ross' and Locality ne 'Sutherland' Locality='Outside Partnership'.
if sending_location='Inverclyde' and Locality ne 'Inverclyde' and Locality ne '' and Locality ne 'Inverclyde Central' and Locality ne 'Inverclyde East' and Locality ne 'Inverclyde West' Locality='Outside Partnership'.
if sending_location='Midlothian' and Locality ne 'Midlothian' and Locality ne '' and Locality ne 'Midlothian (East)' and Locality ne 'Midlothian (West)' Locality='Outside Partnership'.
if sending_location='Moray' and Locality ne 'Moray' and Locality ne '' and Locality ne 'Moray East' and Locality ne 'Moray West' Locality='Outside Partnership'.
if sending_location='North Ayrshire' and Locality ne 'North Ayrshire' and Locality ne '' and Locality ne 'Arran' and Locality ne 'Garnock Valley' and Locality ne 'Irvine' and Locality ne 'Kilwinning' and 
Locality ne 'North Coast & Cumbraes' and Locality ne 'Three Towns' Locality='Outside Partnership'.
if sending_location='North Lanarkshire' and Locality ne 'North Lanarkshire' and Locality ne '' and Locality ne 'Airdrie' and Locality ne 'Bellshill' and Locality ne 'Coatbridge' and Locality ne 'Motherwell' and 
Locality ne 'North Lanarkshire North' and Locality ne 'Wishaw' Locality='Outside Partnership'.
if sending_location='Orkney' and Locality ne 'Orkney' and Locality ne '' and Locality ne 'Isles' and Locality ne 'Orkney East' and Locality ne 'Orkney West' Locality='Outside Partnership'.
if sending_location='Perth & Kinross' and Locality ne 'Perth & Kinross' and Locality ne '' and Locality ne 'North Perthshire' and Locality ne 'Perth City' and Locality ne 'South Perthshire' Locality='Outside Partnership'.
if sending_location='Renfrewshire' and Locality ne 'Renfrewshire' and Locality ne '' and Locality ne 'Paisley' and Locality ne 'Renfrewshire North West and South' Locality='Outside Partnership'.
if sending_location='Shetland' and Locality ne 'Shetland' and Locality ne '' and Locality ne 'Central Mainland' and Locality ne 'Lerwick & Bressay' and Locality ne 'North Isles' and Locality ne 'North Mainland' and
Locality ne 'South Mainland' and Locality ne 'West Mainland' and Locality ne 'Whalsay & Skerries' Locality='Outside Partnership'.
if sending_location='South Ayrshire' and Locality ne 'South Ayrshire' and Locality ne '' and Locality ne 'Ayr North and Former Coalfield Communities' and Locality ne 'Ayr South and Coylton' and
Locality ne 'Girvan and South Carrick Villages' and Locality ne 'Maybole and North Carrick Communities' and Locality ne 'Prestwick' and Locality ne 'Troon' Locality='Outside Partnership'.
if sending_location='South Lanarkshire' and Locality ne 'South Lanarkshire' and Locality ne '' and Locality ne 'Clydesdale' and Locality ne 'East Kilbride' and Locality ne 'Hamilton' and 
Locality ne 'Rutherglen Cambuslang' Locality='Outside Partnership'.
if sending_location='Stirling' and Locality ne 'Stirling' and Locality ne '' and Locality ne 'Rural Stirling' and Locality ne 'Stirling City with the Eastern Villages Bridge of Allan and Dunblane' Locality='Outside Partnership'.
if sending_location='West Dunbartonshire' and Locality ne 'West Dunbartonshire' and Locality ne '' and Locality ne 'Clydebank' and Locality ne 'Dumbarton/Alexandria' Locality='Outside Partnership'.
if sending_location='West Lothian' and Locality ne 'West Lothian' and Locality ne '' and Locality ne 'West Lothian (East)' and Locality ne 'West Lothian (West)' Locality='Outside Partnership'.
if sending_location='Western Isles' and Locality ne 'Western Isles' and Locality ne '' and Locality ne 'Barra' and Locality ne 'Harris' and Locality ne 'Rural Lewis' and 
Locality ne 'Stornoway & Broadbay' and Locality ne 'Uist' Locality='Outside Partnership'.
execute.

if Locality='' Locality='Unknown'.
execute.

*Change partnership locality names to include HSCP on to the end of the name.
if sending_location='Borders' sending_location='Scottish Borders'.
execute.

if Locality='Aberdeen City' Locality='Aberdeen City HSCP'.
if Locality='Aberdeenshire' Locality='Aberdeenshire HSCP'.
if Locality='Angus' Locality='Angus HSCP'.
if Locality='Argyll & Bute' Locality='Argyll & Bute HSCP'.
if Locality='Borders' Locality='Scottish Borders HSCP'.
if Locality='Clackmannanshire' Locality='Clackmannanshire HSCP'.
if Locality='Dumfries & Galloway' Locality='Dumfries & Galloway HSCP'.
if Locality='Dundee City' Locality='Dundee City HSCP'.
if Locality='East Ayrshire' Locality='East Ayrshire HSCP'.
if Locality='East Dunbartonshire' Locality='East Dunbartonshire HSCP'.
if Locality='East Lothian' Locality='East Lothian HSCP'.
if Locality='East Renfrewshire' Locality='East Renfrewshire HSCP'.
if Locality='Edinburgh City' Locality='Edinburgh City HSCP'.
if Locality='Falkirk' Locality='Falkirk HSCP'.
if Locality='Fife' Locality='Fife HSCP'.
if Locality='Highland' Locality='Highland HSCP'.
if Locality='Inverclyde' Locality='Inverclyde HSCP'.
if Locality='Midlothian' Locality='Midlothian HSCP'.
if Locality='Moray' Locality='Moray HSCP'.
if Locality='North Ayrshire' Locality='North Ayrshire HSCP'.
if Locality='North Lanarkshire' Locality='North Lanarkshire HSCP'.
if Locality='Orkney HSCP' Locality='Orkney Islands HSCP'.
if Locality='Orkney Islands' Locality='Orkney Islands HSCP'.
if Locality='Outside partnership' Locality='Outside Partnership'.
if Locality='Perth & Kinross' Locality='Perth & Kinross HSCP'.
if Locality='Renfrewshire' Locality='Renfrewshire HSCP'.
if Locality='Shetland' Locality='Shetland HSCP'.
if Locality='South Ayrshire' Locality='South Ayrshire HSCP'.
if Locality='South Lanarkshire' Locality='South Lanarkshire HSCP'.
if Locality='Stirling' Locality='Stirling HSCP'.
if Locality='West Dunbartonshire' Locality='West Dunbartonshire HSCP'.
if Locality='West Lothian' Locality='West Lothian HSCP'.
if Locality='Western Isles' Locality='Western Isles HSCP'.
execute.

Begin Program.
import spss

# Open the dataset with write access
# Read in the CareHomeNames, which must be the first variable "spss.Cursor([10]..."
cur = spss.Cursor([10], accessType = 'w')

# Create a new variable, string length 73
cur.AllocNewVarsBuffer(80)
cur.SetOneVarNameAndType('ch_name_tidy', 73)
cur.CommitDictionary()

# Loop through every case and write the tidied care home name
for i in range(cur.GetCaseCount()):
    # Read a case and save the care home name
    # We need to strip trailing spaces
    care_home_name = cur.fetchone()[0].rstrip()

    # Write the tidied name to the SPSS dataset
    cur.SetValueChar('ch_name_tidy', str(care_home_name).title())
    cur.CommitCase()

# Close the connection to the dataset
cur.close() 
End Program.

delete variables CareHomeName.
rename variables ch_name_tidy=CareHomeName.
