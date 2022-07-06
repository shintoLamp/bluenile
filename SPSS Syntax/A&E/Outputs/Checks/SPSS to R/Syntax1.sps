* Encoding: UTF-8.
get file = '/conf/sourcedev/TableauUpdates/A&E/R/A&E/output/AE_Final.sav'.

select if agegroup ne '' and agegroup ne 'All'.
execute.

aggregate outfile = *
/break year LCAcode
/count=n.
execute.

get file = '/conf/sourcedev/TableauUpdates/A&E/Outputs/AE_Final.sav'.

aggregate outfile = *
/break year lcacode
/count=n.
execute.


get file = '/conf/sourcedev/TableauUpdates/A&E/R/A&E/output/AE_Final.sav'.

select if agegroup ne '' and agegroup ne 'All'.
execute.

aggregate outfile = *
/break year AE_Num
/count=n.
execute.

get file = '/conf/sourcedev/TableauUpdates/A&E/Outputs/AE_Final.sav'.

aggregate outfile = *
/break year AE_Num
/count=n.
execute.


get file = '/conf/sourcedev/TableauUpdates/A&E/R/A&E/output/AE_Final.sav'.

select if agegroup ne '' and agegroup ne 'All'.
execute.

aggregate outfile = *
/break year agegroup
/count=n.
execute.

get file = '/conf/sourcedev/TableauUpdates/A&E/Outputs/AE_Final.sav'.

aggregate outfile = *
/break year agegroup
/count=n.
execute.


get file = '/conf/sourcedev/TableauUpdates/A&E/R/A&E/output/AE_Final.sav'.

select if agegroup ne '' and agegroup ne 'All'.
execute.

aggregate outfile = *
/break year LCAname
/count=n.
execute.

get file = '/conf/sourcedev/TableauUpdates/A&E/Outputs/AE_Final.sav'.

aggregate outfile = *
/break year LCAname
/count=n.
execute.


get file = '/conf/sourcedev/TableauUpdates/A&E/R/A&E/output/AE_Final.sav'.

select if agegroup ne '' and agegroup ne 'All'.
execute.

aggregate outfile = *
/break year Hbres
/count=n.
execute.

get file = '/conf/sourcedev/TableauUpdates/A&E/Outputs/AE_Final.sav'.

aggregate outfile = *
/break year Hbres
/count=n.
execute.


get file = '/conf/sourcedev/TableauUpdates/A&E/R/A&E/output/AE_Final.sav'.

select if agegroup ne '' and agegroup ne 'All'.
execute.

aggregate outfile = *
/break year Hb_Treatment
/count=n.
execute.

get file = '/conf/sourcedev/TableauUpdates/A&E/Outputs/AE_Final.sav'.

aggregate outfile = *
/break year Hb_Treatment
/count=n.
execute.


get file = '/conf/sourcedev/TableauUpdates/A&E/R/A&E/output/AE_Final.sav'.

select if agegroup ne '' and agegroup ne 'All'.
execute.

aggregate outfile = *
/break year Location
/count=n.
execute.

get file = '/conf/sourcedev/TableauUpdates/A&E/Outputs/AE_Final.sav'.

aggregate outfile = *
/break year Location
/count=n.
execute.


get file = '/conf/sourcedev/TableauUpdates/A&E/R/A&E/output/AE_Final.sav'.

select if agegroup ne '' and agegroup ne 'All'.
execute.

aggregate outfile = *
/break year Ref_Source
/count=n.
execute.

get file = '/conf/sourcedev/TableauUpdates/A&E/Outputs/AE_Final.sav'.

aggregate outfile = *
/break year Ref_Source
/count=n.
execute.


get file = '/conf/sourcedev/TableauUpdates/A&E/R/A&E/output/AE_Final.sav'.

select if agegroup ne '' and agegroup ne 'All'.
execute.

aggregate outfile = *
/break year Discharge_Dest
/count=n.
execute.

get file = '/conf/sourcedev/TableauUpdates/A&E/Outputs/AE_Final.sav'.

aggregate outfile = *
/break year Discharge_Dest
/count=n.
execute.


get file = '/conf/sourcedev/TableauUpdates/A&E/R/A&E/output/AE_Final.sav'.

select if agegroup ne '' and agegroup ne 'All'.
execute.

aggregate outfile = *
/break year agegroup
/Att=sum(Attendances)
/Ind=sum(individuals)
/Cost=sum(cost).
execute.

get file = '/conf/sourcedev/TableauUpdates/A&E/Outputs/AE_Final.sav'.

aggregate outfile = *
/break year agegroup
/Att=sum(attendances)
/Ind=sum(individuals)
/Cost=sum(cost).
execute.
