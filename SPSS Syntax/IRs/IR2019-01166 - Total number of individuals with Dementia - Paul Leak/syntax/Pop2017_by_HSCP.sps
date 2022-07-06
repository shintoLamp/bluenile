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

compute Age0_17=sum(age0 to age17).
compute Age18_44=sum(age18 to age44).
compute Age45_49=sum(age45 to age49).
compute Age50_54=sum(age50 to age54).
compute Age55_59=sum(age55 to age59).
compute Age60_64=sum(age60 to age64).
compute Age65_69=sum(age65 to age69).
compute Age70_74=sum(age70 to age74).
compute Age75_79=sum(age75 to age79).
compute Age80_84=sum(age80 to age84).
compute Age85_89=sum(age85 to age89).
compute Age90plus=sum(age90plus).
compute All_ages=sum(age0 to age90plus).
execute.

aggregate outfile=*
/break year HSCP2018 sex 
/Age0_17=sum(Age0_17)
/Age18_44=sum(Age18_44)
/Age45_49=sum(Age45_49)
/Age50_54=sum(Age50_54)
/Age55_59=sum(Age55_59)
/Age60_64=sum(Age60_64)
/Age65_69=sum(Age65_69)
/Age70_74=sum(Age70_74)
/Age75_79=sum(Age75_79)
/Age80_84=sum(Age80_84)
/Age85_89=sum(Age85_89)
/Age90plus=sum(Age90plus)
/AllAges=sum(All_ages).
execute. 

save outfile = !output + 'Pop2017_by_HSCP.sav'.

get file = !output + 'Pop2017_by_HSCP.sav'.

rename variables sex=gender.

varstocases
/make pop from Age0_17 to AllAges
/index agegroup(pop).

alter type agegroup (a25).

if agegroup='Age0_17' agegroup='0-17 years'.
if agegroup='Age18_44' agegroup='18-44 years'.
if agegroup='Age45_49' agegroup ='45-49 years'.
if agegroup='Age50_54' agegroup ='50-54 years'.
if agegroup='Age55_59' agegroup ='55-59 years'.
if agegroup='Age60_64' agegroup ='60-64 years'.
if agegroup='Age65_69' agegroup ='65-69 years'.
if agegroup='Age70_74' agegroup ='70-74 years'.
if agegroup='Age75_79' agegroup ='75-79 years'.
if agegroup='Age80_84' agegroup ='80-84 years'.
if agegroup='Age85_89' agegroup ='85-89 years'.
if agegroup='Age90plus' agegroup ='90+ years'.
if agegroup='AllAges' agegroup='All ages'.
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

*Select agegroups for comparison of expected prevalence cases .
select if agegroup ne '0-17 years' and agegroup ne '18-44 years' and agegroup ne '45-49 years' and agegroup ne '50-54 years' and agegroup ne '55-59 years' and agegroup ne 'All ages'.
execute.

save outfile = !output + 'Pop2017_by_HSCP_selected_AgeGroups.sav'
  /keep hscp agegroup gender_type pop.

get file =  !output + 'Pop2017_by_HSCP_selected_AgeGroups.sav'.

save translate outfile = !output + 'Pop2017_by_HSCP_selected_AgeGroups.xlsx' 
       /type =xlsx/version = 12/map/replace/fieldnames/cells = values.

