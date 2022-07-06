* Encoding: UTF-8.
get file = '/conf/sourcedev/TableauUpdates/HRI/Outputs/HRI_All.sav'.

* This works for HRI_All, no changes needed.

string Partnership(a40).
String Clacks(a30).
if Partnership = '' Partnership = LCAname.
IF Partnership="Clackmannanshire" or Partnership="Stirling" Clacks="Clackmannanshire & Stirling".
VARSTOCASES
 /MAKE Partnership FROM Partnership Clacks.

delete variables LCAname.
rename variables Partnership = LCAname.
if LCAname = "Clackmannanshire & Stirling" LA_TAB_CODE = 'LAVC33'.

save outfile = '/conf/sourcedev/TableauUpdates/HRI/Outputs/HRI_All.sav'.

* This works for chart as long as Tableau is calculating the variables at the right aggregations:
* health_Expenditure_cost = sum()
* health_Expenditure_cost_min = min()
* health_Expenditure_cost_max = max()
* Rtotal_exp = sum()
* Rtotal_exp_percent = avg()
* individuals = sum()
* Population = don't let it sum at any point, should be fine as it's a string
* Individuals_sum = sum(), this could be called 'total individuals'
* Average_cost = avg()
* Percentage_pop = avg(), this might not be needed at all as 'percentage of population' is just individuals/individuals_sum
* Worth calculating in SPSS? 

get file = '/conf/sourcedev/TableauUpdates/HRI/Outputs/HRI_chart_All.sav'.

alter type lcaname(a30).
add files file = *
/file '/conf/sourcedev/TableauUpdates/HRI/Outputs/CS/HRI_chart_All_CS.sav'.

save outfile = '/conf/sourcedev/TableauUpdates/HRI/Outputs/HRI_chart_All.sav'.

*TAB codes for C&S are LAVC18 (C) and LAVC19 (S).
* Forth Valley is HBVC7.

get file = '/conf/sourcedev/TableauUpdates/HRI/Outputs/HRI_suppressed_All.sav'.

string Partnership(a6).
String Clacks(a6).
if Partnership = '' Partnership = LA_TAB_CODE.
IF Partnership="LAVC18" or Partnership="LAVC19" Clacks="LAVC33".
VARSTOCASES
 /MAKE Partnership FROM Partnership Clacks.

delete variables LA_TAB_CODE.
rename variables Partnership = LA_TAB_Code.

save outfile = '/conf/sourcedev/TableauUpdates/HRI/Outputs/HRI_suppressed_All.sav'.




