* Encoding: UTF-8.
** MSG Source Platform Syntax
** Developed by Bateman McBride June 2020.

** The purpose of this syntax is to create a single .sav file for use within the MSG Workbook on the Source platform.
** The syntax will draw from the regular outputs of the monthly MSG update, which are stored in irf.

Define !outfile()
    '/conf/sourcedev/TableauUpdates/MSG/Outputs/'
!Enddefine.

Define !infile()
    '/conf/irf/03-Integration-Indicators/02-MSG/01-Data/'
!Enddefine.

Define !populations()
   '/conf/linkage/output/lookups/Unicode/Populations/Estimates/DataZone2011_pop_est_2011_2018.sav'
!Enddefine.

***********************

* Adjust populations file for our uses.
get file = !populations.

* Duplicate population data for estimates not available yet

numeric Year_two. 
numeric Year_three.
if (Year=2018) Year_two=2019.
if (Year=2019) Year_three=2020.
VARSTOCASES 
 /MAKE Year FROM Year Year_two Year_three.

* Create age groups used in MSG publication (<18, 18+, 18-64, 65+).

Compute under18_pop = Sum(age0 to age17).
Compute over18_pop = Sum(age18 to age90plus).
Compute over18_under65_pop = Sum(age18 to age64).
Compute over65_pop = Sum(age65 to age90plus).

Dataset Declare Pops.
aggregate outfile = Pops
    /Break Datazone2011 year CA2019
    /under18_pop = Sum(under18_pop)
    /over18_pop = Sum(over18_pop)
    /over18_under65_pop = Sum(over18_under65_pop)
    /over65_pop = Sum(over65_pop)
    /total_pop = Sum(total_pop).

dataset activate Pops.
alter type CA2019(a25).
compute CA2019 = valuelabel(CA2019).

if CA2019 = 'Orkney Islands' CA2019 = 'Orkney'.
if CA2019 = 'Shetland Islands' CA2019 = 'Shetland'.
if CA2019 = 'Na h-Eileanan Siar' CA2019 = 'Western Isles'.
compute CA2019 = replace(CA2019, ' and ', ' & ').

save outfile = !outfile + 'Populations.sav' /zcompressed.

***********************

* Format Indicator 1a and add 'Indicator' variable for flag.

get file = !infile + '01-02-Admissions-beddays/02-Breakdowns/1a-Admissions-breakdown.sav'.

string Indicator(a2).
compute Indicator = '1a'.

aggregate outfile = * 
/BREAK = council Locality AreaTreated AGE_GROUPS month month_num year Indicator
   /OneA_Admissions = sum(Admissions).

sort cases by Indicator locality year month_num.

save outfile = !outfile + '1a.sav' /zcompressed.

* Format and seperate indicators 2a, 2b and 2c.

get file = !infile + '01-02-Admissions-beddays/02-Breakdowns/2a-Acute-Beddays-breakdown.sav'.

add files /file = * 
  /file = !infile + '01-02-Admissions-beddays/02-Breakdowns/2b-GLS-Beddays-breakdown.sav'    /in = TwoB
  /file = !infile + '01-02-Admissions-beddays/02-Breakdowns/2c-MH-Beddays-breakdown.sav'     /in = TwoC. 
execute.

String Indicator (A2). 
if (TwoB = 0 and TwoC = 0) Indicator = '2a'. 
if (TwoB = 1) Indicator = '2b'. 
if (TwoC = 1) Indicator = '2c'. 
execute. 

delete variables TwoB TwoC.
rename variables month=Month.
alter type Month(A6).

aggregate outfile = * 
/break = council Locality AreaTreated AGE_GROUPS Month month_num year Indicator
   /unplanned_beddays = Sum(unplanned_beddays).

temporary.
select if Indicator = '2a'.
aggregate outfile = *  mode = addvariables
/break = council Locality AreaTreated AGE_GROUPS Month month_num year Indicator
   /Two_a = sum(unplanned_beddays).

temporary.
select if Indicator = '2b'.
aggregate outfile = *  mode = addvariables
/break = council Locality AreaTreated AGE_GROUPS Month month_num year Indicator
   /Two_b = sum(unplanned_beddays).

temporary.
select if Indicator = '2c'.
aggregate outfile = *  mode = addvariables
/break = council Locality AreaTreated AGE_GROUPS Month month_num year Indicator
   /Two_c = sum(unplanned_beddays).

aggregate outfile = *
    /break = council Locality AGE_GROUPS Month month_num year AreaTreated Indicator
    /Two_a = first(Two_a)
    /Two_b = first(Two_b)
    /Two_c = first(Two_c).

save outfile = !outfile + '2abc.sav' /zcompressed.



