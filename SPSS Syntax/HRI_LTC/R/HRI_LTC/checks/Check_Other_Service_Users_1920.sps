* Encoding: UTF-8.

**Check SPSS Figures'.
get file = '/conf/sourcedev/TableauUpdates/HRI_LTC/Data_Archive/2021_update/HRI_LTC_Final_Tableau.zsav'.

select if Year eq '2019/20'.
*select if AgeBand ne 'All ages'.
*select if Gender ne 'All'.
select if UserType eq 'Other Service Users'.
execute. 

save outfile =  '/conf/sourcedev/TableauUpdates/HRI_LTC/R/HRI_LTC/checks/Other_Service_Users_All_Ages_1920_SPSS.zsav'
 /drop HRI50_Flag HRI65_Flag HRI80_Flag HRI95_Flag NumberPatients_ALL Total_Cost_ALL Total_Beddays_ALL Point X Y GroupLTC_Flag IndividualLTC_Flag AnyLTC_Flag NumberPat_HRIGrp Total_Cost_HRIGrp Total_Beddays_HRIGrp
 /zcompressed.

get file =  '/conf/sourcedev/TableauUpdates/HRI_LTC/R/HRI_LTC/checks/Other_Service_Users_All_Ages_1920_SPSS.zsav'.

select if AgeBand ne 'All ages'.
select if Gender ne 'All'.
select if ServiceType eq 'ALL'.
select if LCAname ne 'Non LCA'.
select if AgeBand ne 'Missing'.
select if (LTC eq 'Any LTC') or (LTC eq 'No LTC').
execute.

*Create totals for All Service Types for individuals with Any LTC and No LTC.
aggregate outfile=*
 /break LCAname AgeBand Gender LTC 
 /NumberPatients = sum(NumberPatients)
 /Total_Cost = sum(Total_Cost)
 /Total_Beddays = sum(Total_Beddays).
execute.

save outfile = '/conf/sourcedev/TableauUpdates/HRI_LTC/R/HRI_LTC/checks/Agg_Totals_AnyLTC_NoLTC_1920_SPSS.sav'.


**Check R figures'.
get file =  '/conf/sourcedev/TableauUpdates/HRI_LTC/R/HRI_LTC/checks/Other_Service_Users_R.sav'.

select if Year eq '2019/20'.
select if UserType eq 'Other Service Users'.
select if ServiceType eq 'ALL'.
select if (LTC eq 'Any LTC') or (LTC eq 'No LTC').
select if AgeBand ne 'Missing'.
select if LCAname ne 'Non LCA'.
execute.
 

*Create totals for All Service Types for individuals with Any LTC and No LTC.
aggregate outfile=*
 /break LCAname AgeBand Gender LTC 
 /NumberPatients = sum(NumberPatients)
 /Total_Cost = sum(Total_Cost)
 /Total_Beddays = sum(Total_Beddays).
execute.

save outfile = '/conf/sourcedev/TableauUpdates/HRI_LTC/R/HRI_LTC/checks/Agg_Totals_AnyLTC_NoLTC_1920_R.sav'.

get file =  '/conf/sourcedev/TableauUpdates/HRI_LTC/R/HRI_LTC/checks/Agg_Totals_AnyLTC_NoLTC_1920_R.sav'.
