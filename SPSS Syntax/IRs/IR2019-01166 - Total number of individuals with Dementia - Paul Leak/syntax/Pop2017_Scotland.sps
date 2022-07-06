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

aggregate outfile=*
/break year sex 
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

save outfile = !output + 'Pop2017_All_Scotland.sav'.

get file = !output + 'Pop2017_All_Scotland.sav'.

rename variables sex=gender.

*Create gender labels.
string gender_type(a6).
if gender ='M' gender_type='Male'.
if gender ='F'  gender_type='Female'.
execute.

save outfile = !output + 'Pop2017_Scotland_by_Gender.sav'
   /keep hscp gender_type agegroup pop.

get file = !output + 'Pop2017_Scotland_by_Gender.sav'.

save translate outfile = !output + 'Pop2017_Scotland_by_Gender.xlsx' 
       /type =xlsx/version = 12/map/replace/fieldnames/cells = values.
