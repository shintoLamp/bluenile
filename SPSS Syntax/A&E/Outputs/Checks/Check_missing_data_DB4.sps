* Encoding: UTF-8.
*Define input file path.
Define !file()
'/conf/sourcedev/TableauUpdates/A&E/Outputs/'
!Enddefine.

*Define input file path.
Define !output()
'/conf/sourcedev/TableauUpdates/A&E/Outputs/AE_LV2/'
!Enddefine.

get file = '/conf/sourcedev/TableauUpdates/AE/Outputs/AE_Final_201819.zsav'.

select if Data eq 'Data'.
execute.

save outfile =  '/conf/sourcedev/TableauUpdates/AE/Outputs/AE_LV2/AE_LV2_201819.sav'
  /drop lcacode LTC_Num simd Locality.

get file =  '/conf/sourcedev/TableauUpdates/AE/Outputs/AE_LV2/AE_LV2_201819.zsav'.

Select if LCAname eq 'Aberdeen City'.

select if LTCgroup eq 'All' and Ref_source eq 'All' and datazone eq 'All' and locname eq 'All' and Hb_Treatment eq 'All' and year eq '201819'.
exe. 

aggregate outfile=*
 /break agegroup Discharge_Dest AE_num
  /tot_attendaces = sum(attendances)
  /tot_cost = sum(cost).
execute.

select if Discharge_Dest ne 'All'.
execute.

select if AE_num eq '5+'.
execute.
