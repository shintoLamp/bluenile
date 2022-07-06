* Encoding: UTF-8.
get file = '//conf/sourcedev/TableauUpdates/LTC/Outputs/LTCfile.sav'.
sort cases by LCAname.
match files file=*
/by LCAname
/first TableauFlag.
Select if TableauFlag = 1.
execute.

save outfile  '//conf/sourcedev/TableauUpdates/LTC/Outputs/LTCfileTemp1.sav'
/drop TableauFlag.

get file = '//conf/sourcedev/TableauUpdates/LTC/Outputs/LTCfile.sav'.
select if data = 'map'.
execute.
sort cases by datazone.
match files file=*
/by datazone
/first TableauFlag.
Select if TableauFlag = 1.
execute.

add files file=*
/file = '//conf/sourcedev/TableauUpdates/LTC/Outputs/LTCfileTemp1.sav'.

save outfile = '//conf/sourcedev/TableauUpdates/LTC/Outputs/LTCfileTabstore.sav'
/drop TableauFlag.

erase file = '//conf/sourcedev/TableauUpdates/LTC/Outputs/LTCfileTemp1.sav'.

get file = '//conf/sourcedev/TableauUpdates/LTC/Outputs/LTCfileTabstore.sav'.
