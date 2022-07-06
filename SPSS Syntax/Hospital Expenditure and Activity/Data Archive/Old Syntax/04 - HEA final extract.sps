* Encoding: UTF-8.
* Written by Bateman McBride, May 2020.
* Part of the Hospital Expenditure and Activity workbook syntax.
* Adds files together that were created in syntax 02 and 03, and creates a small extract of data for use with the tabstore drive.

define !file()
'/conf/sourcedev/TableauUpdates/Hospital Expenditure and Activity/Outputs/'
!enddefine.

* This command will need to be changed based on financial years run.
add files file =  !file + 'HEA-Main201516.sav'
 /file = !file + 'HEA-Main201617.sav'
 /file = !file + 'HEA-Main201718.sav'
 /file = !file + 'HEA-Main201819.sav'.

alter type location(a7).
alter type prac (a25).

save outfile = !file + 'HEA-Final1.zsav'
    /zcompressed.

add files file= !file + 'HEA-PracticeLevel201516.zsav'
 /file = !file + 'HEA-PracticeLevel201617.zsav'
 /file = !file + 'HEA-PracticeLevel201718.zsav'
 /file = !file + 'HEA-PracticeLevel201819.zsav'.
execute.

save outfile = !file + 'HEA-Final2.zsav'.

add files file = !file + 'HEA-Final1.zsav'
    /file = !file + 'HEA-Final2.zsav'.
execute.

alter type prac(f5.0).
alter type year(f4.0).

if lcapractice='Orkney' lcapractice='Orkney Islands'.
if lcapractice='Shetland' lcapractice='Shetland Islands'.
execute.

save outfile =  !file + 'HEA-Final-Tableau.sav'. 

*Additional code to match on old CA codes in order to match on security filters.
get file = !file + 'HEA-Final-Tableau.sav'. 

sort cases by LA_Code.
match files file=*
/table = '/conf/sourcedev/TableauUpdates/Hospital Expenditure and Activity/Data Archive/TempLookup.sav'
/by LA_Code.
execute.

delete variables LA_Code.
rename variables CA2011=LA_Code.

save outfile =  !file + 'HEA-Final-Tableau.sav'. 

erase file = !file + 'HEA-Final1.zsav'.
erase file = !file + 'HEA-Final2.zsav'.

* Create extract with one row for each partnership.

get file =  !file + 'HEA-Final.sav'. 
 * get file = '//conf/sourcedev/TableauUpdates/Hospital Expenditure and Activity/Outputs/HEA-Final.sav'.
sort cases by LCAname.
match files file=*
/by LCAname
/first TableauFlag.
Select if TableauFlag = 1.
execute.

save outfile  '//conf/sourcedev/TableauUpdates/Hospital Expenditure and Activity/Outputs/HEA-Final-Tableau.sav'
/drop TableauFlag.


