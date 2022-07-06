* Encoding: UTF-8.
*********Checking total Beddays (HRI Pathways DB3)*********
**********************************************************************

*Macro 1.
Define !year()
'201819'
!Enddefine.

Define !year2()
'2018/19'
!Enddefine.


define !file()
       '/conf/sourcedev/TableauUpdates/HRIpathways/Outputs/LV3/Checks/DB3_beddays/'
!Enddefine.

*Read in Source individual linkage file.
get file = '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.zsav'.


*Exclude unwanted records.
select if gender ne 0.
select if hri_lca ne 9.

*Exclude Non-service users.
select if NSU ne 1.

*Exclude East lothian outlier.
Select if Anon_CHI ne 'MDMwNTM2MTEzOQ=='.
exe.

rename variables (HRI_LcaP=lcap).

*Now classify HRIs.
String HRI_Group1819 (A30).
* Create HRI grouping.
if (lcaP lt 50) HRI_Group1819 = 'High'.
if (lcaP ge 50 and lcaP lt 65) HRI_Group1819 = 'High to Medium'.
if (lcaP ge 65 and lcaP lt 80) HRI_Group1819 = 'Medium'.
if (lcaP ge 80 and lcaP lt 95) HRI_Group1819 = 'Medium to Low'.
if (lcaP ge 95) HRI_Group1819 = 'Low'.
if lca eq '' HRI_Group1819 eq 'Not in LA'.
exe.

*Covert date_death' to numeric format.
Compute date_death = xdate.mday(death_date) + 100*xdate.month(death_date) + 10000*xdate.year(death_date).
exe.

* Add death marker.
if date_death < 20180401 HRI_Group1819 = 'Died'.
if date_death > 20180401 and HRI_Group1819 = ' ' HRI_Group1819 = 'Died'.
exe.

* Assume any blanks are now showing no contact in year.
if HRI_Group1819 = ' ' HRI_Group1819 = 'No Contact'.
exe.

String agegroup(a10).
if Age ge 0 agegroup ='All ages'.

*Set gender to 0 (='All').
compute gender = 0.
String GenderSTR(a6).
if gender = 0 GenderSTR = "All".

String FinYear(a10).
compute FinYear='2018/19'.

*Output aggregated total beddays by HRIs for each LCA.
aggregate outfile=*
 /break FinYear lca agegroup genderSTR HRI_Group1819
   /acute_beddays = sum(acute_inpatient_beddays)
   /mat_beddays = sum(mat_inpatient_beddays)
   /MH_beddays = sum(MH_inpatient_beddays)
   /gls_beddays = sum(gls_inpatient_beddays).
exe.

save outfile = !file + 'Beddays_by_LCA_201819.zsav'
   /zcompressed.

*Formatting variables.
get file = !file + 'Beddays_by_LCA_201819.zsav'.

alter type lca (A2).
*add LA Name.
string LCAname (a25).
if lca eq '01' LCAname eq 'Aberdeen City'.
if lca eq '02' LCAname eq 'Aberdeenshire'.
if lca eq '03' LCAname eq 'Angus'.
if lca eq '04' LCAname eq 'Argyll & Bute'.
if lca eq '05' LCAname eq 'Scottish Borders'.
if lca eq '06' LCAname eq 'Clackmannanshire'.
if lca eq '07' LCAname eq 'West Dunbartonshire'.
if lca eq '08' LCAname eq 'Dumfries & Galloway'.
if lca eq '09' LCAname eq 'Dundee City'.
if lca eq '10' LCAname eq 'East Ayrshire'.
if lca eq '11' LCAname eq 'East Dunbartonshire'.
if lca eq '12' LCAname eq 'East Lothian'.
if lca eq '13' LCAname eq 'East Renfrewshire'.
if lca eq '14' LCAname eq 'City of Edinburgh'.
if lca eq '15' LCAname eq 'Falkirk'.
if lca eq '16' LCAname eq 'Fife'.
if lca eq '17' LCAname eq 'Glasgow City'.
if lca eq '18' LCAname eq 'Highland'.
if lca eq '19' LCAname eq 'Inverclyde'.
if lca eq '20' LCAname eq 'Midlothian'.
if lca eq '21' LCAname eq 'Moray'.
if lca eq '22' LCAname eq 'North Ayrshire'.
if lca eq '23' LCAname eq 'North Lanarkshire'.
if lca eq '24' LCAname eq 'Orkney'.
if lca eq '25' LCAname eq 'Perth & Kinross'.
if lca eq '26' LCAname eq 'Renfrewshire'.
if lca eq '27' LCAname eq 'Shetland'.
if lca eq '28' LCAname eq 'South Ayrshire'.
if lca eq '29' LCAname eq 'South Lanarkshire'.
if lca eq '30' LCAname eq 'Stirling'.
if lca eq '31' LCAname eq 'West Lothian'.
if lca eq '32' LCAname eq 'Western Isles'.
if LCAname = '' LCAname = 'Non LCA'.


sort cases by LCAname(a).


save outfile = !file + 'Beddays_by_LCA_201819.zsav'
  /keep FinYear LCAname agegroup genderSTR HRI_Group1819 acute_beddays mat_beddays MH_beddays gls_beddays
  /zcompressed.

get file = !file + 'Beddays_by_LCA_201718.zsav'.
