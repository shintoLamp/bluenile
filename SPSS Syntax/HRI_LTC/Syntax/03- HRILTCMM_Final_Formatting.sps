* Encoding: UTF-8.
*****************************************************Add data for all financial years together for final dataset******************************************.

Define !file()
     '/conf/sourcedev/TableauUpdates/HRI_LTC/Outputs/'
!Enddefine.

add files file = '/conf/sourcedev/TableauUpdates/HRI_LTC/Outputs/1718/HRI_LTC_Final201718.sav'
/file =   '/conf/sourcedev/TableauUpdates/HRI_LTC/Outputs/1819/HRI_LTC_Final201819.sav'
/file =   '/conf/sourcedev/TableauUpdates/HRI_LTC/Outputs/1920/HRI_LTC_Final201920.sav'
/file =   '/conf/sourcedev/TableauUpdates/HRI_LTC/Outputs/2021/HRI_LTC_Final202021.sav'.

compute AnyLTC_Flag = 0.
if LTC eq 'Any LTC' AnyLTC_Flag = 1.

*Save Final HRI LTC Dataset.
save outfile = !file + 'HRI_LTC_Final.sav'.

get file = !file + 'HRI_LTC_Final.sav'.

* Create small extract for Tabstore data migration.

sort cases by LCAname.
match files file=*
/by LCAname
/first TableauFlag.
Select if TableauFlag = 1.
execute.

save outfile = !file + 'HRI_LTC_Final_Tableau.sav'
/drop TableauFlag.

get file = !file + 'HRI_LTC_Final_Tableau.sav'.