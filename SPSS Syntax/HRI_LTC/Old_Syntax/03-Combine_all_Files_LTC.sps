*****************************************************Add data for all financial years together for final dataset******************************************.

Define !file()
     '/conf/irf/09-Tableau-Outputs/01-Development/02-SPSS-Outputs/03-HRI/LTC/'
!Enddefine.

*get file= !file + 'HRI_LTC_Radar_201516.sav'.
*frequencies variables = lcaname.


add files file = !file + 'HRI_LTC_Radar_201112.sav'
/file =  !file + 'HRI_LTC_Radar_201213.sav'
/file =  !file + 'HRI_LTC_Radar_201314.sav'
/file =  !file + 'HRI_LTC_Radar_201415.sav'
/file =  !file + 'HRI_LTC_Radar_201516.sav'.
exe.

compute AnyLTC_Flag = 0.
if LTC eq 'Any LTC' AnyLTC_Flag = 1.
exe.

*Save Final HRI LTC Dataset.
save outfile = !file +'HRI_LTC_Radar_2011-16.sav'
/compressed.
get file =  !file +'HRI_LTC_Radar_2011-16.sav'.
