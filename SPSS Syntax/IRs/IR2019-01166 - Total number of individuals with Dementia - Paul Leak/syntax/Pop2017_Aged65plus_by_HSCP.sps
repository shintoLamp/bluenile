* Encoding: UTF-8.
*Paul Leak - Scottih Government
*Output Population estimates by Age Band (17-44, 18-44, 45-49, 50-54, 55-59, 60-64, 65-69, 70-74, 75-79, 80-84, 85-89, 90-94, 95+) 
* and by Gender (Male, Female) for each HSCPs.
*Year: 2017.

DEFINE  !output()
'/conf/sourcedev/TableauUpdates/IRs/IR2019-01166 - Total number of individuals with Dementia - Paul Leak/Output/'
!enddefine.

*Read in Population estimates file.
get file = '/conf/linkage/output/lookups/Unicode/Populations/Estimates/DataZone2011_pop_est_2011_2018.sav'.

select if year=2017.
execute.

compute Aged65plus=sum(age65 to age90plus).
execute.

aggregate outfile=*
/break year HSCP2018 sex 
/Aged65_plus=sum(Aged65plus).
execute. 

save outfile = !output + 'Pop2017_Aged65plus_by_HSCP_temp.sav'.

get file = !output + 'Pop2017_Aged65plus_by_HSCP_temp.sav'.

rename variables sex=gender.

varstocases
/make pop Aged65_plus
/index agegroup(pop).

alter type agegroup (a25).

if agegroup='Age65_plus' agegroup ='65+ years'.
execute.

if agegroup = ' ' agegroup='Unknown'.
execute.


*Label HSCPs in 2018 (N=31).
string hscp (a100).
if HSCP2018='S37000001' hscp='Aberdeen City'.
if HSCP2018='S37000002' hscp='Aberdeenshire'.
if HSCP2018='S37000003' hscp='Angus'.
if HSCP2018='S37000004' hscp='Argyll & Bute'.
if HSCP2018='S37000005' hscp='Clackmannanshire and Stirling'.
if HSCP2018='S37000006' hscp='Dumfries & Galloway'.
if HSCP2018='S37000007' hscp='Dundee City'.
if HSCP2018='S37000008' hscp='East Ayrshire'.
if HSCP2018='S37000009' hscp='East Dunbartonshire'.
if HSCP2018='S37000010' hscp='East Lothian'.
if HSCP2018='S37000011' hscp='East Renfrewshire'.
if HSCP2018='S37000012' hscp='Edinburgh' .
if HSCP2018='S37000013' hscp='Falkirk'.
if HSCP2018='S37000032' hscp='Fife'.
if HSCP2018='S37000015' hscp='Glasgow City'.
if HSCP2018='S37000016' hscp='Highland'.
if HSCP2018='S37000017' hscp='Inverclyde'.
if HSCP2018='S37000018' hscp='Midlothian'.
if HSCP2018='S37000019' hscp='Moray'.
if HSCP2018='S37000020' hscp='North Ayrshire'.
if HSCP2018='S37000021' hscp='North Lanarkshire'.
if HSCP2018='S37000022' hscp='Orkney Islands'.
if HSCP2018='S37000033' hscp='Perth & Kinross'.
if HSCP2018='S37000024' hscp='Renfrewshire'.
if HSCP2018='S37000025' hscp='Scottish Borders'.
if HSCP2018='S37000026' hscp='Shetland Islands'.
if HSCP2018='S37000027' hscp='South Ayrshire'.
if HSCP2018='S37000028' hscp='South Lanarkshire'.
if HSCP2018='S37000029' hscp='West Dunbartonshire'.
if HSCP2018='S37000030' hscp='West Lothian'.
if HSCP2018='S37000031' hscp='Western Isles'.
execute.

if hscp = ' ' hscp ='Unknown'.
execute.

*Create gender labels.
string gender_type(a6).
if gender ='M' gender_type='Male'.
if gender ='F'  gender_type='Female'.
execute.


save outfile = !output + 'Pop2017_by_HSCP_Aged65plus.sav'
  /keep hscp agegroup gender_type pop.

get file =  !output + 'Pop2017_by_HSCP_Aged65plus.sav'.

save translate outfile = !output + 'Pop2017_by_HSCP_Aged65plus.xlsx' 
       /type =xlsx/version = 12/map/replace/fieldnames/cells = values.

