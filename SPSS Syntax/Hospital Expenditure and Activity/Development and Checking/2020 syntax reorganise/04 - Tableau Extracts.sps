* Encoding: UTF-8.
* Syntax for Hospital Expenditure and Activity workbook
* Bateman McBride, December 2020.
* Part 3 - the purpose of this syntax is to create the two main datasets for the workbook, check the data quality, and create the small extracts to use in 
* tabstore.
* Macro.
DEFINE !file()
'/conf/sourcedev/TableauUpdates/Hospital Expenditure and Activity/Development and Checking/2020 syntax reorganise/'
!ENDDEFINE.

* Main syntax.
* Hospital Level.
add files file = !file + 'HEATest201516.sav'
/file = !file + 'HEATest201617.sav'
/file = !file + 'HEATest201718.sav'
/file = !file + 'HEATest201819.sav'
/file = !file + 'HEATest201920.sav'.
save outfile = !file + 'HospitalLevel.sav'.
*********************************************.
* Data quality.
 * frequencies year LCAname LA_code.
*********************************************.
* GP Level.
add files file = !file + 'GPtest201516.sav'
/file = !file + 'GPtest201617.sav'
/file = !file + 'GPtest201718.sav'
/file = !file + 'GPtest201819.sav'
/file = !file + 'GPtest201920.sav'.
alter type ipdc(a9).
compute ipdc = valuelabel(ipdc).
save outfile = !file + 'GPLevel.sav'.
*********************************************.
* Data quality.
 * frequencies year LCAname LA_code.
*********************************************.
add files file = !file + 'HospitalLevel.sav' /in=HospitalFlag
/file = !file + 'GPLevel.sav'.
execute.
string Data(a4).
if HospitalFlag=1 Data='Hosp'.
if HospitalFlag=0 Data='GP'.
frequencies Data.
save outfile = !file + 'HEA-Final.sav'.

* Tableau Small extract.
sort cases by LCAname.
match files file=*
/by LCAname
/first TableauFlag.
Select if TableauFlag = 1.
execute.
save outfile !file + 'HEA-Final-Tableau.sav'
/drop TableauFlag.
