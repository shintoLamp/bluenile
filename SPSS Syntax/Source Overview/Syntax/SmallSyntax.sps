* Encoding: UTF-8.
get file = '//conf/sourcedev/TableauUpdates/Source Overview/Outputs/SourceOverview.sav'.
sort cases by LA_Code.
match files file=*
/by LA_Code
/first TableauFlag.
Select if TableauFlag = 1.
delete variables TableauFlag.
save outfile = '//conf/sourcedev/TableauUpdates/Source Overview/Outputs/SourceOverview-Small.sav'.
