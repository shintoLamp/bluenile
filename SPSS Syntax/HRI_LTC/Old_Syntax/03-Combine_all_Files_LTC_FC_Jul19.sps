* Encoding: UTF-8.
*****************************************************Add data for all financial years together for final dataset******************************************.

Define !file()
     '/conf/sourcedev/TableauUpdates/HRI_LTC/Outputs/'
!Enddefine.

*get file= !file + 'HRI_LTC_Radar_201516.sav'.
*frequencies variables = lcaname.


add files file = !file + 'HRI_LTC_Radar_201314.sav'
/file =  !file + 'HRI_LTC_Radar_201415.sav'
/file =  !file + 'HRI_LTC_Radar_201516.sav'
/file =  !file + 'HRI_LTC_Radar_201617.sav'
/file =  !file + 'HRI_LTC_Radar_201718.sav'.
exe.

compute AnyLTC_Flag = 0.
if LTC eq 'Any LTC' AnyLTC_Flag = 1.
exe.

*Save Final HRI LTC Dataset.
save outfile = !file +'HRI_LTC_Radar_2013-18.zsav'
/zcompressed.

get file =  !file +'HRI_LTC_Radar_2013-18.zsav'.
