* Encoding: UTF-8.
*Check HRI LTC ALL totals as output with SPSS.
get file =   '/conf/sourcedev/TableauUpdates/HRI_LTC/Outputs/1920/HRI_LTC_All_Totals.sav'.

select if AgeBand ne 'All ages'.
select if AgeBand ne 'Missing'.
select if Gender ne 'All'.
select if LCAname ne 'Non LCA'.

select if ServiceType eq 'Acute'.
execute.

*Create totals for All Service Types for individuals with Any LTC.
aggregate outfile=*
 /break LCAname AgeBand Gender LTC
 /NumberPatients_ALL = sum(NumberPatients_ALL)
 /Total_Cost_ALL = sum(Total_Cost_ALL)
 /Total_Beddays_ALL = sum(Total_Beddays_ALL).
execute.

sort cases by LTC(a).

save outfile =  '/conf/sourcedev/TableauUpdates/HRI_LTC/R/HRI_LTC/checks/Agg_hri_ltc_ALL_totals_Acute_1920_SPSS.sav'. 

get file = '/conf/sourcedev/TableauUpdates/HRI_LTC/R/HRI_LTC/checks/Agg_hri_ltc_ALL_totals_Acute_1920_R.sav'.

*Check HRI LTC totals as output with R.
get file =  '/conf/sourcedev/TableauUpdates/HRI_LTC/R/HRI_LTC/checks/hri_ltc_all_totals_R.sav'.

select if Year eq '2019/20'.
select if AgeBand ne 'All ages'.
select if AgeBand ne 'Missing'.
select if Gender ne 'All'.
select if LCAname ne 'Non LCA'.

select if ServiceType eq 'Acute'.

*Create totals for All Service Types for individuals with Any LTC.
aggregate outfile=*
 /break LCAname AgeBand Gender LTC
 /NumberPatients_ALL = sum(NumberPatients_ALL)
 /Total_Cost_ALL = sum(Total_Cost_ALL)
 /Total_Beddays_ALL = sum(Total_Beddays_ALL).
execute.

sort cases by LTC(a).

save outfile =  '/conf/sourcedev/TableauUpdates/HRI_LTC/R/HRI_LTC/checks/Agg_hri_ltc_ALL_totals_Acute_1920_R.sav'.
