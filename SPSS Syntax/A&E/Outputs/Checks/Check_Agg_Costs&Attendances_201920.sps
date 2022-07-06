* Encoding: UTF-8.
Define !year()
'201920'
!Enddefine.

Define !file()
'/conf/sourcedev/TableauUpdates/A&E/Outputs/Checks/'
!Enddefine.


Get file = '/conf/hscdiip/01-Source-linkage-files/source-episode-file-' + !year +'.zsav'.

*Select only A&E admissions.
Select if recid = 'AE2'.
exe. 


sort cases by Anon_CHI. 
exe.

*Add variable for episode count.
compute episodes = 1.
exe.

save outfile = !file + 'AE_' + !year +'.zsav'
 /keep Anon_CHI lca spec location cost_total_net episodes
/zcompressed. 
 

get file = !file + 'AE_' + !year +'.zsav'.


*Calculate aggregated attendances and cost to individual level by LCA, Specialty and Treatment Location code.
aggregate outfile =*
 /break Anon_CHI lca spec location
 /cost = sum(cost_total_net)
 /attendances = sum(episodes). 
execute.

*Match on council area descriptions.
rename variables lca=lcacode.
sort cases by lcacode.
match files file=*
 /table '/conf/irf/05-lookups/04-geography/LCA_lookup.sav'
 /by lcacode.
exe. 

*Add variable for individuals count.
compute individuals = 1.
exe.

*Calculate aggregated Costs and Attendances by Specialty and Hospital Location Code for each LCA.
aggregate outfile =*
 /break LCAname spec location
 /individuals = sum(individuals)
 /cost = sum(cost)
 /attendances = sum(attendances). 
execute.


save outfile = !file + 'Agg_AE_by_Spec_Hosp_201920.sav'.

get file =  !file + 'Agg_AE_by_Spec_Hosp_201920.sav'.

*Calculate aggregated Costs and Attendances by LCA.
aggregate outfile =*
 /break LCAname
 /individuals = sum(individuals)
 /cost = sum(cost)
 /attendances = sum(attendances). 
execute.

save outfile = !file + 'Agg_AE_by_LCA_201920.sav'.
