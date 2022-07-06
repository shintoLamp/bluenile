* Encoding: UTF-8.
* Updated by Rachael Bainbridge 17/01/2019.
* Updated by Bateman McBride April 2020.

* Run on sourcedev.
Define !file()
'/conf/sourcedev/TableauUpdates/LTC/Outputs/'
!Enddefine. 

* Make sure this is adjusted to reflect the most recent lookup in cl-out. It will take the form 'HSCP Localities_DZ11_Lookup_CCYYMMDD.sav'. Just put the date in this macro.

Define !recentlookup()
'20200825'
!enddefine.

*********************.

* Macro for creating the locality-level lookup for any given financial year.

Define !DatazoneLookup(finyear, !TOKENS(1))
    get file = !QUOTE(!CONCAT((!UNQUOTE(!EVAL(!file))), (!UNQUOTE(!EVAL(!finyear))), '/', 'Datazone', (!UNQUOTE(!EVAL(!finyear))), '.sav')). 
    
    sort cases by datazone2011.
    
    match files file = *
     /table = !QUOTE(!CONCAT('/conf/linkage/output/lookups/Unicode/Geography/HSCP Locality/HSCP Localities_DZ11_Lookup_', (!UNQUOTE(!EVAL(!recentlookup))), '.sav'))
     /by datazone2011
     /keep datazone2011 to population HSCPLocality.
    
    rename variables HSCPLocality = locality.
    
    aggregate outfile = *
     /break locality sex agegroup
     /population = sum(population).
    
    sort cases by locality sex agegroup.
    
    save outfile = !QUOTE(!CONCAT((!UNQUOTE(!EVAL(!file))), (!UNQUOTE(!EVAL(!finyear))), '/', 'Locality', (!UNQUOTE(!EVAL(!finyear))), '.sav'))
    /zcompressed. 
!enddefine.

* Run for each relevant FY.
!DatazoneLookup finyear = '201718'.
!DatazoneLookup finyear = '201819'.
!DatazoneLookup finyear = '201920'.
!DatazoneLookup finyear = '202021'.


