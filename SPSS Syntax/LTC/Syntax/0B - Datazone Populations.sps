* Encoding: UTF-8.
* LTC Syntax to create population figures for different demographic breakdowns using raw population estimates by datazone.
* Updated by Rachael Bainbridge 17/01/2019.
* Updated by Bateman McBride April 2020.

*Macros to define year.
* READ: 20XX/YY financial year uses 20XX population estimates so syntax reflects this, however the file should be saved with financial year in title. 

Define !year()
'2020'
!Enddefine.

define !finyear()
'202021'
!enddefine.

* Run on sourcedev.
Define !file()
'/conf/sourcedev/TableauUpdates/LTC/Outputs/202021/'
!Enddefine. 

***********.
* Again as in syntax A, need to run this part for each financial year needed. Amend year in macro above.

get file= '/conf/linkage/output/lookups/Unicode/Populations/Estimates/DataZone2011_pop_est_2011_2020.sav'.

alter type Year (A4).
select if Year= !year. 

recode sex ('M' = 1)('F' = 2) into SEXn.

compute agegroup1=sum (age0, age1, age2, age3, age4, age5, age6, age7, age8, age9, age10, age11, age12, age13, age14, age15, age16, age17).
compute agegroup2 =sum (age18, age19, age20, age21, age22, age23, age24, age25, age26, age27, age28, age29, age30, age31, age32, age33, age34, age35, age36, age37, age38, age39, age40, age41, age42, age43, age44).
compute agegroup3 =sum (age45, age46, age47, age48, age49, age50, age51, age52, age53, age54, age55, age56, age57, age58, age59, age60, age61, age62, age63, age64).
compute agegroup4 =sum (age65, age66, age67, age68, age69, age70, age71, age72, age73, age74).
compute agegroup5 =sum (age75, age76, age77, age78, age79, age80, age81, age82, age83, age84).
compute agegroup6 =sum (age85, age86, age87, age88, age89, age90plus).

****

string agegroup (A6).
compute agegroup = '0-17'.
rename variables agegroup1=population. 

save outfile= !file + 'DZpart1.sav'
   /keep datazone2011 agegroup SEXn population
   /zcompressed.

compute agegroup = '18-44'.
rename variables population=agegroup1.
rename variables agegroup2=population.

save outfile= !file + 'DZpart2.sav'
   /keep datazone2011 agegroup SEXn population
   /zcompressed.

compute agegroup = '45-64'.
rename variables population=agegroup2.
rename variables agegroup3=population.

save outfile= !file + 'DZpart3.sav'
   /keep datazone2011 agegroup SEXn population
   /zcompressed.

compute agegroup = '65-74'.
rename variables population=agegroup3.
rename variables agegroup4=population.

save outfile= !file + 'DZpart4.sav'
   /keep datazone2011 agegroup SEXn population
   /zcompressed.

compute agegroup = '75-84'.
rename variables population=agegroup4.
rename variables agegroup5=population.

save outfile= !file + 'DZpart5.sav'
   /keep datazone2011 agegroup SEXn population
   /zcompressed.

compute agegroup = '85+'.
rename variables population=agegroup5.
rename variables agegroup6=population.

save outfile= !file + 'DZpart6.sav'
   /keep datazone2011 agegroup SEXn population
   /zcompressed.

add files file= !file + 'DZpart1.sav'
  /file= !file +'DZpart2.sav'
  /file= !file +'DZpart3.sav'
  /file= !file +'DZpart4.sav'
  /file= !file +'DZpart5.sav'
  /file= !file +'DZpart6.sav'.

rename variables SEXn=SEX. 

save outfile= !file + 'DZ' + !year + '.sav'
/zcompressed.

compute sex=3.

aggregate outfile = * 
 /break datazone2011 SEX agegroup
 /population= sum(population). 

add files file= *
  /file= !file + 'DZ' + !year + '.sav'.

save outfile= !file + 'DZ' + !year + '.sav'
/zcompressed.

compute agegroup ='All'.

aggregate outfile = * 
 /break datazone2011 SEX agegroup
 /population= sum(population). 

add files file= *
  /file= !file + 'DZ' + !year + '.sav'.

sort cases by DataZone2011 agegroup sex. 

rename variables  DataZone2011= 'datazone2011'.
alter type datazone2011 (A9).

*save with financial year in title to reflect othe syntax. 
save outfile= !file + 'Datazone' + !finyear + '.sav'
/zcompressed.

*******

get file= !file + 'Datazone' + !finyear + '.sav'.

* Tidy up.
erase file = !file +'DZpart1.sav'.
erase file = !file +'DZpart2.sav'.
erase file = !file +'DZpart3.sav'.
erase file = !file +'DZpart4.sav'.
erase file = !file +'DZpart5.sav'.
erase file = !file +'DZpart6.sav'.
erase file = !file + 'DZ' + !year + '.sav'.