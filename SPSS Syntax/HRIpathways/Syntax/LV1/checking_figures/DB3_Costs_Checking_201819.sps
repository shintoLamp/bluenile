* Encoding: UTF-8.
*********Checking total costs (HRI Pathways LV1 DB3)*********
**********************************************************************

*Macro 1.
Define !year()
'201819'
!Enddefine.

Define !year2()
'2018/19'
!Enddefine.


define !file()
       '/conf/sourcedev/TableauUpdates/HRIpathways/Outputs/LV1/New folder/'
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
 /break FinYear agegroup genderSTR HRI_Group1819
   /Acute_serv_cost = sum(acute_cost)
   /AE_serv_cost = sum(AE_cost)
   /Mat_serv_cost = sum(mat_cost)
   /MH_serv_cost = sum(mh_cost)
   /Out_serv_cost = sum(OP_cost_attend)
   /Gls_serv_cost = sum(gls_cost).
exe.

save outfile = !file + 'Scotland_Costs_by_Service_Type_201819.zsav'
   /zcompressed.

