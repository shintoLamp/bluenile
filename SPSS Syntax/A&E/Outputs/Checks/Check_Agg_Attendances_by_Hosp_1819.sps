* Encoding: UTF-8.
Define !year()
'201819'
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
 /keep Anon_CHI hbrescode hbtreatcode lca location cost_total_net episodes
/zcompressed. 
 

get file = !file + 'AE_' + !year +'.zsav'.

SORT CASES by location.
exe.

alter type location(a5).
exe.

*Match on location codes to bring Hospital names in.
Match files file= *
 /table = '/conf/linkage/output/lookups/Unicode/National Reference Files/location.sav' 
 /by location.    
execute.

select if Anon_CHI ne ''.
exe.

aggregate outfile=*
  /break Anon_CHI hbtreatcode Lca locname 
  /attendances=sum(episodes).
execute.

select if lca ne ''.
exe.

aggregate outfile=*
  /break hbtreatcode lca locname
  /attendances=sum(attendances).
execute.

alter type lca (F2).
alter type lca (A2).
exe.

*Match on council area descriptions.
rename variables lca=lcacode.
sort cases by lcacode.
match files file=*
 /table '/conf/irf/05-lookups/04-geography/LCA_lookup.sav'
 /by lcacode.
exe. 


