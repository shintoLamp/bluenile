* Encoding: UTF-8.
get file = '/conf/sourcedev/TableauUpdates/A&E/R/A&E/data/AEprogram.sav'.

select if year='201920'.
select if agegroup='All'.
select if AE_Num='All'.
select if Discharge_Dest='All'.
select if Location='All'.
select if Ref_Source='All'.
select if LTCgroup='All'.
execute.

aggregate outfile =*
/break Hb_Treatment
/Attendances=sum(Attendances)
/Individuals=sum(individuals)
/Cost=sum(cost).
execute.

get file = '/conf/sourcedev/TableauUpdates/A&E/R/A&E/data/AEprogram.sav'.

select if year='201920'.

*LCA.
aggregate outfile =*
/break LCAname
/Attendances=sum(Attendances)
/Individuals=sum(individuals)
/Cost=sum(cost).
execute.

get file = '/conf/sourcedev/TableauUpdates/A&E/R/A&E/data/AEprogram.sav'.

select if year='201920'.

*HB Residence.
aggregate outfile =*
/break Hbres
/Attendances=sum(Attendances)
/Individuals=sum(individuals)
/Cost=sum(cost).
execute.

get file = '/conf/sourcedev/TableauUpdates/A&E/R/A&E/data/AEprogram.sav'.

select if year='201920'.

*HB Treatment.
aggregate outfile =*
/break Hb_Treatment
/Attendances=sum(Attendances)
/Individuals=sum(individuals)
/Cost=sum(cost).
execute.

get file = '/conf/sourcedev/TableauUpdates/A&E/R/A&E/data/AEprogram.sav'.

select if year='201920'.

*AE_Number.
aggregate outfile =*
/break AE_Num
/Attendances=sum(Attendances)
/Individuals=sum(individuals)
/Cost=sum(cost).
execute.

get file = '/conf/sourcedev/TableauUpdates/A&E/R/A&E/data/AEprogram.sav'.

select if year='201920'.

*Discharge Destination.
aggregate outfile =*
/break Discharge_Dest
/Attendances=sum(Attendances)
/Individuals=sum(individuals)
/Cost=sum(cost).
execute.

get file = '/conf/sourcedev/TableauUpdates/A&E/R/A&E/data/AEprogram.sav'.

select if year='201920'.

*Agegroup.
aggregate outfile =*
/break agegroup
/Attendances=sum(Attendances)
/Individuals=sum(individuals)
/Cost=sum(cost).
execute.

get file = '/conf/sourcedev/TableauUpdates/A&E/R/A&E/data/AEprogram.sav'.

select if year='201920'.

*LTC Group.
aggregate outfile =*
/break LTCgroup
/Attendances=sum(Attendances)
/Individuals=sum(individuals)
/Cost=sum(cost).
execute.

get file = '/conf/sourcedev/TableauUpdates/A&E/R/A&E/data/AEprogram.sav'.

select if year='201920'.

*Location.
aggregate outfile =*
/break Location
/Attendances=sum(Attendances)
/Individuals=sum(individuals)
/Cost=sum(cost).
execute.

get file = '/conf/sourcedev/TableauUpdates/A&E/R/A&E/data/AEprogram.sav'.

select if year='201920'.

*Referral Source.
aggregate outfile =*
/break Ref_Source
/Attendances=sum(Attendances)
/Individuals=sum(individuals)
/Cost=sum(cost).
execute.

get file = '/conf/sourcedev/TableauUpdates/A&E/Outputs/AEpart2201920.zsav'.

select if agegroup='All'.
select if AE_Num='All'.
select if Discharge_Dest='All'.
select if location='All'.
select if Ref_Source='All'.
select if LTCgroup='All'.
execute.

aggregate outfile =*
/break Hb_Treatment
/Attendances=sum(attendances)
/Individuals=sum(individuals)
/Cost=sum(cost).
execute.

get file = '/conf/sourcedev/TableauUpdates/A&E/Outputs/AEpart2201920.zsav'.

*LCA.
aggregate outfile=*
/break LCAname
/Attendances=sum(attendances)
/Individuals=sum(individuals)
/Cost=sum(cost).
execute.

get file = '/conf/sourcedev/TableauUpdates/A&E/Outputs/AEpart2201920.zsav'.

*HB Residence.
aggregate outfile=*
/break Hbres
/Attendances=sum(attendances)
/Individuals=sum(individuals)
/Cost=sum(cost).
execute.

get file = '/conf/sourcedev/TableauUpdates/A&E/Outputs/AEpart2201920.zsav'.

*HB Treatment.
aggregate outfile=*
/break Hb_Treatment
/Attendances=sum(attendances)
/Individuals=sum(individuals)
/Cost=sum(cost).
execute.

get file = '/conf/sourcedev/TableauUpdates/A&E/Outputs/AEpart2201920.zsav'.

*AE_Num.
aggregate outfile=*
/break AE_Num
/Attendances=sum(attendances)
/Individuals=sum(individuals)
/Cost=sum(cost).
execute.

get file = '/conf/sourcedev/TableauUpdates/A&E/Outputs/AEpart2201920.zsav'.

*Discharge Destination.
aggregate outfile=*
/break Discharge_Dest
/Attendances=sum(attendances)
/Individuals=sum(individuals)
/Cost=sum(cost).
execute.

get file = '/conf/sourcedev/TableauUpdates/A&E/Outputs/AEpart2201920.zsav'.

*Agegroup.
aggregate outfile=*
/break agegroup
/Attendances=sum(attendances)
/Individuals=sum(individuals)
/Cost=sum(cost).
execute.

get file = '/conf/sourcedev/TableauUpdates/A&E/Outputs/AEpart2201920.zsav'.

*LTC Group.
aggregate outfile=*
/break LTCgroup
/Attendances=sum(attendances)
/Individuals=sum(individuals)
/Cost=sum(cost).
execute.

get file = '/conf/sourcedev/TableauUpdates/A&E/Outputs/AEpart2201920.zsav'.

*Location.
aggregate outfile=*
/break location
/Attendances=sum(attendances)
/Individuals=sum(individuals)
/Cost=sum(cost).
execute.

get file = '/conf/sourcedev/TableauUpdates/A&E/Outputs/AEpart2201920.zsav'.

*Referral Source.
aggregate outfile=*
/break Ref_source
/Attendances=sum(attendances)
/Individuals=sum(individuals)
/Cost=sum(cost).
execute.

********************************************
Script 2 - AEpart4 file, compare totals
********************************************

get file = '/conf/sourcedev/TableauUpdates/A&E/R/A&E/data/AEpart4.sav'.

select if year='201920'.
select if agegroup='All'.
select if AE_Num='All'.
select if Location='All'.
select if Ref_Source='All'.
select if datazone='All'.
select if Locname='All'.
execute.

aggregate outfile =*
/break Hb_Treatment
/Attendances=sum(Attendances)
/Individuals=sum(Individuals)
/Cost=sum(Cost).
execute.

get file = '/conf/sourcedev/TableauUpdates/A&E/R/A&E/data/AEpart4.sav'.

select if year='201920'.

*LCA.
aggregate outfile =*
/break LCAname
/Attendances=sum(Attendances)
/Individuals=sum(Individuals)
/Cost=sum(Cost).
execute.

get file = '/conf/sourcedev/TableauUpdates/A&E/R/A&E/data/AEpart4.sav'.

select if year='201920'.

*HB Residence.
aggregate outfile =*
/break Hbres
/Attendances=sum(Attendances)
/Individuals=sum(Individuals)
/Cost=sum(Cost).
execute.

get file = '/conf/sourcedev/TableauUpdates/A&E/R/A&E/data/AEpart4.sav'.

select if year='201920'.

*HB Treatment.
aggregate outfile =*
/break Hb_Treatment
/Attendances=sum(Attendances)
/Individuals=sum(Individuals)
/Cost=sum(Cost).
execute.

get file = '/conf/sourcedev/TableauUpdates/A&E/R/A&E/data/AEpart4.sav'.

select if year='201920'.

*AE_Number.
aggregate outfile =*
/break AE_Num
/Attendances=sum(Attendances)
/Individuals=sum(Individuals)
/Cost=sum(Cost).
execute.

get file = '/conf/sourcedev/TableauUpdates/A&E/R/A&E/data/AEpart4.sav'.

select if year='201920'.

*Datazone.
aggregate outfile =*
/break datazone
/Attendances=sum(Attendances)
/Individuals=sum(Individuals)
/Cost=sum(Cost).
execute.

get file = '/conf/sourcedev/TableauUpdates/A&E/R/A&E/data/AEpart4.sav'.

select if year='201920'.

*Agegroup.
aggregate outfile =*
/break agegroup
/Attendances=sum(Attendances)
/Individuals=sum(Individuals)
/Cost=sum(Cost).
execute.

get file = '/conf/sourcedev/TableauUpdates/A&E/R/A&E/data/AEpart4.sav'.

select if year='201920'.

*SIMD.
aggregate outfile =*
/break simd
/Attendances=sum(Attendances)
/Individuals=sum(Individuals)
/Cost=sum(Cost).
execute.

get file = '/conf/sourcedev/TableauUpdates/A&E/R/A&E/data/AEpart4.sav'.

select if year='201920'.

*Location.
aggregate outfile =*
/break Location
/Attendances=sum(Attendances)
/Individuals=sum(Individuals)
/Cost=sum(Cost).
execute.

get file = '/conf/sourcedev/TableauUpdates/A&E/R/A&E/data/AEpart4.sav'.

select if year='201920'.

*Referral Source.
aggregate outfile =*
/break Ref_Source
/Attendances=sum(Attendances)
/Individuals=sum(Individuals)
/Cost=sum(Cost).
execute.

*Compare with file produced using SPSS code.
get file = '/conf/sourcedev/TableauUpdates/A&E/Outputs/AEpart4201920.zsav'.

select if agegroup='All'.
select if AE_Num='All'.
select if location='All'.
select if Ref_source='All'.
select if datazone='Agg'.
select if Locname='All'.
execute.

aggregate outfile =*
/break Hb_Treatment
/Attendances=sum(Attendances)
/Individuals=sum(Individuals)
/Cost=sum(Cost).
execute.

get file = '/conf/sourcedev/TableauUpdates/A&E/Outputs/AEpart4201920.zsav'.

*LCA.
aggregate outfile =*
/break LCAname
/Attendances=sum(Attendances)
/Individuals=sum(Individuals)
/Cost=sum(Cost).
execute.

get file = '/conf/sourcedev/TableauUpdates/A&E/Outputs/AEpart4201920.zsav'.

*HB Residence.
aggregate outfile =*
/break Hbres
/Attendances=sum(Attendances)
/Individuals=sum(Individuals)
/Cost=sum(Cost).
execute.

get file = '/conf/sourcedev/TableauUpdates/A&E/Outputs/AEpart4201920.zsav'.

*HB Treatment.
aggregate outfile =*
/break Hb_Treatment
/Attendances=sum(Attendances)
/Individuals=sum(Individuals)
/Cost=sum(Cost).
execute.

get file = '/conf/sourcedev/TableauUpdates/A&E/Outputs/AEpart4201920.zsav'.

*AE_Number.
aggregate outfile =*
/break AE_Num
/Attendances=sum(Attendances)
/Individuals=sum(Individuals)
/Cost=sum(Cost).
execute.

get file = '/conf/sourcedev/TableauUpdates/A&E/Outputs/AEpart4201920.zsav'.

*Datazone.
aggregate outfile =*
/break datazone
/Attendances=sum(Attendances)
/Individuals=sum(Individuals)
/Cost=sum(Cost).
execute.

get file = '/conf/sourcedev/TableauUpdates/A&E/Outputs/AEpart4201920.zsav'.

*Agegroup.
aggregate outfile =*
/break agegroup
/Attendances=sum(Attendances)
/Individuals=sum(Individuals)
/Cost=sum(Cost).
execute.

get file = '/conf/sourcedev/TableauUpdates/A&E/Outputs/AEpart4201920.zsav'.

*SIMD.
aggregate outfile =*
/break simd
/Attendances=sum(Attendances)
/Individuals=sum(Individuals)
/Cost=sum(Cost).
execute.

get file = '/conf/sourcedev/TableauUpdates/A&E/Outputs/AEpart4201920.zsav'.

*Location.
aggregate outfile =*
/break Location
/Attendances=sum(Attendances)
/Individuals=sum(Individuals)
/Cost=sum(Cost).
execute.

get file = '/conf/sourcedev/TableauUpdates/A&E/Outputs/AEpart4201920.zsav'.

*Referral Source.
aggregate outfile =*
/break Ref_Source
/Attendances=sum(Attendances)
/Individuals=sum(Individuals)
/Cost=sum(Cost).
execute.

***********************************************
Script 3 - AE locality file, compare totals
***********************************************

get file = '/conf/sourcedev/TableauUpdates/A&E/R/A&E/data/AElocality.sav'.

select if year='201920'.
select if agegroup='All'.
select if AE_Num='All'.
select if LTC_Num='All'.
select if location='All'.
select if Ref_source='All'.
select if Locality='Agg'.
execute.

aggregate outfile =*
/break Hb_Treatment
/Attendances=sum(Attendances)
/Individuals=sum(Individuals)
/Cost=sum(Cost).
execute.

get file = '/conf/sourcedev/TableauUpdates/A&E/R/A&E/data/AElocality.sav'.

select if year='201920'.

*LCA.
aggregate outfile =*
/break LCAname
/Attendances=sum(Attendances)
/Individuals=sum(Individuals)
/Cost=sum(Cost).
execute.

get file = '/conf/sourcedev/TableauUpdates/A&E/R/A&E/data/AElocality.sav'.

select if year='201920'.

*HB Residence.
aggregate outfile =*
/break Hbres
/Attendances=sum(Attendances)
/Individuals=sum(Individuals)
/Cost=sum(Cost).
execute.

get file = '/conf/sourcedev/TableauUpdates/A&E/R/A&E/data/AElocality.sav'.

select if year='201920'.

*HB Treatment.
aggregate outfile =*
/break Hb_Treatment
/Attendances=sum(Attendances)
/Individuals=sum(Individuals)
/Cost=sum(Cost).
execute.

get file = '/conf/sourcedev/TableauUpdates/A&E/R/A&E/data/AElocality.sav'.

select if year='201920'.

*Locality.
aggregate outfile =*
/break Locality
/Attendances=sum(Attendances)
/Individuals=sum(Individuals)
/Cost=sum(Cost).
execute.

get file = '/conf/sourcedev/TableauUpdates/A&E/R/A&E/data/AElocality.sav'.

select if year='201920'.

*AE_Number.
aggregate outfile =*
/break AE_Num
/Attendances=sum(Attendances)
/Individuals=sum(Individuals)
/Cost=sum(Cost).
execute.

get file = '/conf/sourcedev/TableauUpdates/A&E/R/A&E/data/AElocality.sav'.

select if year='201920'.

*Agegroup.
aggregate outfile =*
/break agegroup
/Attendances=sum(Attendances)
/Individuals=sum(Individuals)
/Cost=sum(Cost).
execute.

get file = '/conf/sourcedev/TableauUpdates/A&E/R/A&E/data/AElocality.sav'.

select if year='201920'.

*Location.
aggregate outfile =*
/break Location
/Attendances=sum(Attendances)
/Individuals=sum(Individuals)
/Cost=sum(Cost).
execute.

get file = '/conf/sourcedev/TableauUpdates/A&E/R/A&E/data/AElocality.sav'.

select if year='201920'.

*Referral Source.
aggregate outfile =*
/break Ref_Source
/Attendances=sum(Attendances)
/Individuals=sum(Individuals)
/Cost=sum(Cost).
execute.

*Compare with file produced using SPSS code.
get file = '/conf/sourcedev/TableauUpdates/A&E/Outputs/AElocality201920.zsav'.

select if agegroup='All'.
select if AE_Num='All'.
select if LTC_Num='All'.
select if location='All'.
select if Ref_source='All'.
select if Locality='Agg'.
execute.

aggregate outfile =*
/break Hb_Treatment
/Attendances=sum(Attendances)
/Individuals=sum(Individuals)
/Cost=sum(Cost).
execute.

get file = '/conf/sourcedev/TableauUpdates/A&E/Outputs/AElocality201920.zsav'.

*LCA.
aggregate outfile =*
/break LCAname
/Attendances=sum(Attendances)
/Individuals=sum(Individuals)
/Cost=sum(Cost).
execute.

get file = '/conf/sourcedev/TableauUpdates/A&E/Outputs/AElocality201920.zsav'.

*HB Residence.
aggregate outfile =*
/break Hbres
/Attendances=sum(Attendances)
/Individuals=sum(Individuals)
/Cost=sum(Cost).
execute.

get file = '/conf/sourcedev/TableauUpdates/A&E/Outputs/AElocality201920.zsav'.

*HB Treatment.
aggregate outfile =*
/break Hb_Treatment
/Attendances=sum(Attendances)
/Individuals=sum(Individuals)
/Cost=sum(Cost).
execute.

get file = '/conf/sourcedev/TableauUpdates/A&E/Outputs/AElocality201920.zsav'.

*Locality.
aggregate outfile =*
/break Locality
/Attendances=sum(Attendances)
/Individuals=sum(Individuals)
/Cost=sum(Cost).
execute.

get file = '/conf/sourcedev/TableauUpdates/A&E/Outputs/AElocality201920.zsav'.

*AE_Number.
aggregate outfile =*
/break AE_Num
/Attendances=sum(Attendances)
/Individuals=sum(Individuals)
/Cost=sum(Cost).
execute.

get file = '/conf/sourcedev/TableauUpdates/A&E/Outputs/AElocality201920.zsav'.

*Agegroup.
aggregate outfile =*
/break agegroup
/Attendances=sum(Attendances)
/Individuals=sum(Individuals)
/Cost=sum(Cost).
execute.

get file = '/conf/sourcedev/TableauUpdates/A&E/Outputs/AElocality201920.zsav'.

*Location.
aggregate outfile =*
/break Location
/Attendances=sum(Attendances)
/Individuals=sum(Individuals)
/Cost=sum(Cost).
execute.

get file = '/conf/sourcedev/TableauUpdates/A&E/Outputs/AElocality201920.zsav'.

*Referral Source.
aggregate outfile =*
/break Ref_Source
/Attendances=sum(Attendances)
/Individuals=sum(Individuals)
/Cost=sum(Cost).
execute.

