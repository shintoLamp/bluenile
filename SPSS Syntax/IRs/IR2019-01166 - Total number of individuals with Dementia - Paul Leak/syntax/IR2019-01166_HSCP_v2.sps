* Encoding: UTF-8.
*Define output path.
DEFINE  !output()
'/conf/sourcedev/TableauUpdates/IRs/IR2019-01166 - Total number of individuals with Dementia - Paul Leak/Output/'
!enddefine.


* Encoding: UTF-8.
*Read in information from Source linkage file to the episode level for 2017/18.
get file =  '/conf/hscdiip/01-Source-linkage-files/source-episode-file-201718.zsav'.

*Flag those individuals with Dementia.
compute LTC=0.
if dementia =1 LTC=1.
execute.

*Select only those individulas with Dementia.
select if LTC=1.
execute.
*Select all activities from all Health Services.
*select if recid='00B' or recid='01B' or recid='02B' or recid='04B' or recid='AE2' or recid='GLS' or recid='PIS'.
*execute. 

*Detect duplicated CHI numbers.
sort cases by Anon_CHI.
compute dup=0.
if Anon_CHI=lag(Anon_CHI) dup=1.
execute.

frequencies dup.

*Exclude records with duplicated CHIs.
select if dup=0.
execute.

*Classify Individuals by 5 years age band

string agegroup (a25).
if age ge 0 and age le 17 agegroup='0-17 years'.
if age ge 18 and age le 44 agegroup='18-44 years'.
if age ge 45 and age le 49 agegroup='45-49 years'.
if age ge 50 and age le 54 agegroup='50-54 years'.
if age ge 55 and age le 59 agegroup='55-59 years'.
if age ge 60 and age le 64 agegroup='60-64 years'.
if age ge 65 and age le 69 agegroup='65-69 years'.
if age ge 70 and age le 74 agegroup='70-74 years'.
if age ge 75 and age le 79 agegroup='75-79 years'.
if age ge 80 and age le 84 agegroup='80-84 years'.
if age ge 85 and age le 89 agegroup='85-89 years'.
if age ge 90 and age le 94 agegroup='90-94 years'.
if age ge 95 agegroup='95+ years'.
execute.

if agegroup = ' ' agegroup='Unknown'.
execute.

frequencies agegroup.

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

*Calculate Total Individuals with Dementia broken down by HSCPs, agegroup, gender.
aggregate outfile =*
  /break year hscp agegroup gender 
  /tot_individuals=sum(LTC).
execute.


*Create gender labels.
string gender_type(a6).
if gender =1 gender_type='Male'.
if gender =2 gender_type='Female'.
execute.

save outfile = !output + 'Total Individuals with Dementia by agegroup gender HSCP for 201718.sav' 
  /keep hscp agegroup gender_type tot_individuals.
 
get file = !output + 'Total Individuals with Dementia by agegroup gender HSCP for 201718.sav'. 

save translate outfile = !output + 'Total Individuals with Dementia by agegroup gender HSCP for 201718.xlsx' 
       /type =xlsx/version = 12/map/replace/fieldnames/cells = values.

*Aggrgeate total individuals back to HSCP level.
aggregate outfile =*
 /break hscp 
  /tot_individuals = sum(tot_individuals).
execute.

save outfile = !output + 'Total Individuals with Dementia by HSCP for 201718.sav'. 

get file = !output + 'Total Individuals with Dementia by HSCP for 201718.sav'. 

save translate outfile = !output + 'Total Individuals with Dementia by HSCP for 201718.xlsx' 
       /type =xlsx/version = 12/map/replace/fieldnames/cells = values.


