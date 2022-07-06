* Encoding: UTF-8.
* Syntax for Hospital Expenditure and Activity workbook
* Bateman McBride, December 2020.
* Part 3 - the purpose of this syntax is to create the two main datasets for the workbook, check the data quality, and create the small extracts to use in 
* tabstore.
* Macro.
DEFINE !file()
'/conf/sourcedev/TableauUpdates/Hospital Expenditure and Activity/Outputs/'
!ENDDEFINE.

* Main syntax.
* Hospital Level.
add files 
 file = !file + 'LCALevel201617.sav'
/file = !file + 'LCALevel201718.sav'
/file = !file + 'LCALevel201819.sav'
/file = !file + 'LCALevel201920.sav'.
if lcaname = 'Clackmannanshire & Stirling' LA_code = 'S12000005'.
save outfile = !file + 'LCALevel.sav'.
get file =  !file + 'LCALevel.sav'.
sort cases by LCAname.
match files file=*
/by LCAname
/first TableauFlag.
Select if TableauFlag = 1.
execute.
save outfile = !file + 'LCALevel-Tableau.sav'.
*********************************************.
* Data quality.
 * frequencies year LCAname LA_code.
*********************************************.
* GP Level.
add files 
 file = !file + 'GPLevel201617.sav'
/file = !file + 'GPLevel201718.sav'
/file = !file + 'GPLevel201819.sav'
/file = !file + 'GPLevel201920.sav'.
if lcaname = 'Clackmannanshire & Stirling' LA_code = 'S12000005'.
save outfile = !file + 'GPLevel.sav'.
get file =  !file + 'GPLevel.sav'.
sort cases by LCAname.
match files file=*
/by LCAname
/first TableauFlag.
Select if TableauFlag = 1.
execute.
save outfile = !file + 'GPLevel-Tableau.sav'.

*********************************************.
* Data quality.
 * frequencies year LCAname LA_code.
*********************************************.
* Board Level.
add files 
 file = !file + 'BoardLevel201617.sav'
/file = !file + 'BoardLevel201718.sav'
/file = !file + 'BoardLevel201819.sav'
/file = !file + 'BoardLevel201920.sav'.
save outfile = !file + 'BoardLevel.sav'.
get file =  !file + 'BoardLevel.sav'.
sort cases by HB.
match files file=*
/by HB
/first TableauFlag.
Select if TableauFlag = 1.
execute.
save outfile = !file + 'BoardLevel-Tableau.sav'.
*********************************************.
* Data quality.
 * frequencies year LCAname LA_code.
*********************************************.

