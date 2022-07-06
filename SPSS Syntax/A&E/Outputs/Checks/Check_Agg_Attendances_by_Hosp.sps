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
 /keep Anon_CHI hbrescode hbtreatcode lca location cost_total_net episodes
/zcompressed. 
 

get file = !file + 'AE_' + !year +'.zsav'.