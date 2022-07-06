* Encoding: UTF-8.
*Open main file.
get file = '/conf/sourcedev/TableauUpdates/Matrix/PCI/Output/Final/PCI_TDE.sav'.

*Selec a random sample (1% of the original data) for the small dataset creation. 
FILTER OFF.
USE ALL.
SAMPLE  .01.
EXECUTE.

***** Remember to append '_small' or any other name in order to create a NEW file and avoid overwritig the main file *****.
save outfile = '/conf/sourcedev/TableauUpdates/Matrix/PCI/Output/PCI_TDE_small.sav'.


