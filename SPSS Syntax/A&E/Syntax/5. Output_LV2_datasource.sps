* Encoding: UTF-8.
*Define input file path.
Define !file()
'/conf/sourcedev/TableauUpdates/A&E/Outputs/'
!Enddefine.

*Define input file path.
Define !output()
'/conf/sourcedev/TableauUpdates/A&E/Outputs/LV2/'
!Enddefine.

get file = '/conf/sourcedev/TableauUpdates/A&E/Outputs/AE_Final.sav'.

select if Data eq 'Data'.
execute.

save outfile =  '/conf/sourcedev/TableauUpdates/A&E/Outputs/LV2/AE_Final.sav'
  /drop lcacode LTC_Num simd Locality
  /zcompressed.

*Please note that the following code shoudn't be run if the Tableau data extract is fully refreshed from PreProd server. 
*Create small data set to upload the data source through Source tabvol.
*get file = '/conf/sourcedev/TableauUpdates/A&E/Outputs/LV2/AE_LV2_201920.sav'.

*sort cases by LCAname.
*match files file=*
/by LCAname
/first TableauFlag.
*Select if TableauFlag = 1.
*execute.

*save outfile = '/conf/sourcedev/TableauUpdates/A&E/AE_Final_LV2.sav'
/drop TableauFlag.

*get file =  '/conf/sourcedev/TableauUpdates/A&E/AE_Final_LV2.sav'.


