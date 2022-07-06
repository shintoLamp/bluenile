* Encoding: UTF-8.
* LTC Syntax to create population figures for different demographic breakdowns using raw population estimates.
* Updated - Rachael Bainbridge 17/01/2019.
* Updated - Bateman McBride April 2020.

* Macros to define year.
* NOTE: 20XX/YY financial year uses 20XX population estimates so syntax reflects this, as so for every year 
* Need to runfor four financial years.

Define !year()
'2020'
!Enddefine.

define !finyear()
'202021'
!enddefine.

* Run on sourcedev.
Define !file()
'/conf/sourcedev/TableauUpdates/LTC/Outputs/202021/'
!Enddefine. 

*** Run this for each financial year needed - amend 'year' in macro above.

*Get MYE Population file.
get file= '/conf/linkage/output/lookups/Unicode/Populations/Estimates/CA2019_pop_est_1981_2020.sav'.

alter type year (A4).

select if year = !year.
execute.

Compute lca = 0. 
If CA2011 = 'S12000026' lca = 5. 
If CA2011 = 'S12000015' lca = 16. 
If CA2011 = 'S12000023' lca = 24. 
If CA2011 = 'S12000013' lca = 32. 
If CA2011 = 'S12000006' lca = 08. 
If CA2011 = 'S12000027' lca = 27. 
If CA2011 = 'S12000021' lca = 22. 
If CA2011 = 'S12000028' lca = 28. 
If CA2011 = 'S12000008' lca = 10. 
If CA2011 = 'S12000045' lca = 11. 
If CA2011 = 'S12000046' lca = 17. 
If CA2011 = 'S12000011' lca = 13. 
If CA2011 = 'S12000039' lca = 7. 
If CA2011 = 'S12000038' lca = 26. 
If CA2011 = 'S12000018' lca = 19. 
If CA2011 = 'S12000017' lca = 18. 
If CA2011 = 'S12000044' lca = 23. 
If CA2011 = 'S12000029' lca = 29. 
If CA2011 = 'S12000033' lca = 1. 
If CA2011 = 'S12000034' lca = 2. 
If CA2011 = 'S12000020' lca = 21. 
If CA2011 = 'S12000010' lca = 12. 
If CA2011 = 'S12000040' lca = 31. 
If CA2011 = 'S12000019' lca = 20. 
If CA2011 = 'S12000036' lca = 14. 
If CA2011 = 'S12000024' lca = 25. 
If CA2011 = 'S12000042' lca = 9. 
If CA2011 = 'S12000041' lca = 3. 
If CA2011 = 'S12000005' lca = 6. 
If CA2011 = 'S12000014' lca = 15. 
If CA2011 = 'S12000030' lca = 30. 
If CA2011 = 'S12000035' lca = 4.
execute.

rename variables Pop= population.

*create age groups.
string agegroup (a6).
recode Age (0 thru 17= '0-17')(18 thru 44= '18-44')(45 thru 64= '45-64')(65 thru 74= '65-74')(75 thru 84='75-84')(85 thru hi = '85+') into agegroup.
frequencies agegroup. 

sort cases by lca sex agegroup.
aggregate outfile = * 
 /break lca sex agegroup
 /population= sum(population).

save outfile= !file + !year +'.sav'
/zcompressed.

* Create an 'all age groups' section.

compute agegroup='All'.

aggregate outfile = * 
 /break lca Sex agegroup
 /population= sum(population). 

add files file= *
  /file=  !file + !year +'.sav'.

save outfile= !file + !year +'.sav'
/zcompressed.

*Create an 'all genders' section.

compute sex=3.

aggregate outfile = * 
 /break lca Sex agegroup
 /population= sum(population). 

add files file= *
  /file=  !file + !year +'.sav'.

aggregate outfile = * mode ADDVARIABLES
 /break Sex agegroup
 /scot_population= sum(population). 

sort cases by lca sex agegroup.

*Add health board variable. 
String hbres (A9).
If (lca=10) or (lca=22) or (lca=28) hbres = 'S08000015'.
If (lca=5) hbres = 'S08000016'.
If (lca=8) hbres = 'S08000017'.
If (lca=16) hbres = 'S08000018'.
If (lca=6) or (lca=15) or (lca=30) hbres = 'S08000019'.
If (lca=1) or (lca=2) or (lca=21) hbres = 'S08000020'.
If (lca=17) or (lca=19) or (lca=11) or (lca=13) or (lca=26) or (lca=7) hbres = 'S08000021'.
If (lca=4) or (lca=18) hbres = 'S08000022'.
If (lca=23) or (lca=29) hbres = 'S08000023'.
If (lca=12) or (lca=14) or (lca=20) or (lca=31) hbres = 'S08000024'.
If (lca=24) hbres = 'S08000025'.
If (lca=27) hbres = 'S08000026'.
If (lca=3) or (lca=9) or (lca=25) hbres = 'S08000027'.
If (lca=32) hbres = 'S08000028'.
execute. 

aggregate outfile = * mode ADDVARIABLES
 /break hbres Sex agegroup
 /hbres_population= sum(population). 

sort cases by lca sex agegroup.

delete variables hbres.
string year (A6).
compute year = !finyear.

*Save file with financial year in title to align with other syntax.
save outfile= !file + 'agegroups' + !finyear + '.sav'
/zcompressed.

get file=  !file + 'agegroups' + !finyear + '.sav'.

* tidy up.
erase file = !file + !year +'.sav'.
