* Encoding: UTF-8.
add files file = !file + 'HEA-MasterExtractTEST201516.zsav'
/file = !file + 'HEA-MasterExtractTEST201617.zsav'
/file = !file + 'HEA-MasterExtractTEST201718.zsav'
/file=  !file + 'HEA-MasterExtractTEST201819.zsav'.
execute.

save outfile = !file + 'HEAtest.sav' /zcompressed.
get file = !file + 'HEAtest.sav'.

alter type location(a5).
sort cases by location.

*Match with list created in BO to identify Acute/Community/Mental Health care providers.
match files file =*
/table = '/conf/irf/09-Tableau-Outputs/01-Development/04-Source-Data/02-PLICS/Hosp_Services.sav'
/by location.
execute.

frequencies locname.

* Added by Bateman 03/2019.

alter type locname(a70).
rename variables postcode = pcd.

*Match with lookup file to get correct Location name.
match files file = *
    /table =  '/conf/linkage/output/lookups/Data Management/standard reference files/location.sav'
    /by location.
execute.

frequencies locname.

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
execute.

FREQUENCIES type.

select if locname = ''.
execute.

frequencies location.

get file = '/conf/sourcedev/TableauUpdates/Hospital Expenditure and Activity/Data Archive/2020 Update/HEA-Final-Tableau.sav'.

if location = 'A217H' locname = 'Woodland View'.
if location = 'E006V' locname = 'The Farndon Unit'.
if location = 'G503H' locname = 'Drumchapel Hospital'.
if location = 'G517H' locname = 'Beatson West of Scotland Cancer Centre'.
if location = 'G518V' locname = 'Quayside Nursing Home'.
if location = 'G584V' locname = 'Robin House Childrens Hospice Association Scotland'.
if location = 'G604V' locname = 'NE Class East Social Work Day Unit'.
if location = 'G611H' locname = 'Netherton'.
if location = 'G614H' locname = 'Orchard View'.
if location = 'H220V' locname = 'Highland Hospice'.
if location = 'H239V' locname = 'Howard Doris Centre'.
if location = 'T317V' locname = 'Rachel House Childrens Hospice'.
if location = 'T319H' locname = 'Whitehills Health and Community Care Centre'.
if location = 'Y146H' locname = 'Dumfries & Galloway Royal Infirmary'.
if location = 'Y177C' locname = 'Mountainhall Treatment Centre'.
execute.

save outfile =  '/conf/sourcedev/TableauUpdates/Hospital Expenditure and Activity/Data Archive/2020 Update/HEA-Final-Tableau.sav'.







