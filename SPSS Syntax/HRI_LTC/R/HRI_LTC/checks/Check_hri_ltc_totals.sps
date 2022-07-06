* Encoding: UTF-8.
*Check HRI LTC totals as output with SPSS.
get file =   '/conf/sourcedev/TableauUpdates/HRI_LTC/Outputs/1920/HRI_LTC_Totals.sav'.

select if AgeBand ne 'All ages'.
select if AgeBand ne 'Missing'.
select if Gender ne 'All'.
select if LCAname ne 'Non LCA'.

select if UserType eq 'lca-HRI_50'.
select if ServiceType eq 'Acute'.

select if LTC eq 'Any LTC'.
execute.

*Create totals for All Service Types for individuals with Any LTC.
aggregate outfile=*
 /break LCAname AgeBand Gender 
 /NumberPatients = sum(NumberPatients)
 /Total_Cost = sum(Total_Cost)
 /Total_Beddays = sum(Total_Beddays).
execute.

save outfile =  '/conf/sourcedev/TableauUpdates/HRI_LTC/R/HRI_LTC/checks/Agg_hri_ltc_totals_AnyLTC_Acute_HRI50_1920_SPSS.sav'. 

get file = '/conf/sourcedev/TableauUpdates/HRI_LTC/R/HRI_LTC/checks/Agg_hri_ltc_totals_AnyLTC_Acute_HRI50_1920_R.sav'.

*Check HRI LTC totals as output with R.
get file =  '/conf/sourcedev/TableauUpdates/HRI_LTC/R/HRI_LTC/checks/hri_ltc_totals_R.sav'.

select if Year eq '2019/20'.
select if AgeBand ne 'All ages'.
select if AgeBand ne 'Missing'.
select if Gender ne 'All'.
select if LCAname ne 'Non LCA'.

select if UserType eq 'lca-hri_50'.
select if ServiceType eq 'Acute'.

select if LTC eq 'Any LTC'.
execute.

*Create totals for All Service Types for individuals with Any LTC.
aggregate outfile=*
 /break LCAname AgeBand Gender 
 /NumberPatients = sum(NumberPatients)
 /Total_Cost = sum(Total_Cost)
 /Total_Beddays = sum(Total_Beddays).
execute.

save outfile =  '/conf/sourcedev/TableauUpdates/HRI_LTC/R/HRI_LTC/checks/Agg_hri_ltc_totals_AnyLTC_Acute_HRI50_1920_R.sav'.
