* Encoding: UTF-8.
get file =  '/conf/linkage/output/lookups/Unicode/Geography/HSCP Locality/HSCP Localities_DZ11_Lookup_20200825.sav'.

delete variables HSCP2019 to HB2014.
delete variables CA2019 to CA2011.

rename variables (HSCPLocality = locality)(HSCP2019Name = partnership)(CA2019Name=lcaname).

* Formatting for the usual spelling and grammar used on Source platform.

if locality = 'Na h-Eileanan Siar' locality = 'Western Isles'.
if locality = 'Argyll and Bute' locality = 'Argyll & Bute'.
if locality = 'Dumfries and Galloway' locality = 'Dumfries & Galloway'.
if locality = 'Orkney Islands' locality = 'Orkney'.
if locality = 'Shetland Islands' locality = 'Shetland'.
if locality = 'Perth and Kinross' locality = 'Perth & Kinross'.
execute.

if partnership = 'Argyll and Bute' partnership = 'Argyll & Bute'.
if partnership = 'Dumfries and Galloway' partnership = 'Dumfries & Galloway'.
if partnership = 'Orkney Islands' partnership = 'Orkney'.
if partnership = 'Shetland Islands' partnership = 'Shetland'.
if partnership = 'Perth and Kinross' partnership = 'Perth & Kinross'.
if partnership = 'Clackmannanshire and Stirling' partnership = 'Clackmannanshire & Stirling'.
execute.

delete variables lcaname.
sort cases by datazone2011.
save outfile = '/conf/sourcedev/TableauUpdates/Hospital Expenditure and Activity/Outputs/Locality Lookup HEA.sav' /zcompressed.
