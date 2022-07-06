* Encoding: UTF-8.
* Combined file ro produce data source for Tableau data visualisation on ISD website.
* Add main IRF publilcation data source and level 1 Scotland file together to produce this file.

get file = '/conf/irf/09-Tableau-Outputs/01-Development/02-SPSS-Outputs/01-HSC-Expenditure/Final_data/2017-18/Source Output/HSC_PUB_DATA_2014-18ScotLv1.sav'
/drop exp_per_cap.

add files file =*
/file = '/conf/irf/09-Tableau-Outputs/01-Development/02-SPSS-Outputs/01-HSC-Expenditure/Final_data/2017-18/Source Output/HSC_PUB_DATA_2014-18Part.sav'.
execute.

save outfile = '/conf/irf/09-Tableau-Outputs/01-Development/02-SPSS-Outputs/01-HSC-Expenditure/Final_data/2017-18/HSC_PUB_DATA_TABLEAUTEST.sav'.
