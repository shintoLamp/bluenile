* Encoding: UTF-8.
****************************************************************************************************************************************************************************************************
* Core Team Functional-outputs, Combined Health and Social Care File - Defining parameters referenced by all syntax in folder - DM
* All IRF syntax is parametereised so only need to change paths, dates etc in this one place for Combined Health and Social Care File
* This syntax must be run (after updating) each time want to run an Combined Health and Social Care File program to define the appropriate parameters.

* Created by: DM - 13/11/2012

*Include any updates/amendments below
* Amended by: DM on 04/02/2014 - Working file created in main folder. Workings file named as pathname 1, main folder now renamed pathname 1a. 
* NOTES:
* Updated by EP for 2013-14
* Each separate Combined Health and Social Care File syntax file details parameters referenced by it and these values are found here.


*Updated by JM May 2017 for 2015/16 financial year.
****************************************************************************************************************************************************************************************************


*********************************************************************.
* 1. Pathnames
*********************************************************************.
DEFINE !year()
'2018-19'
!ENDDEFINE.

DEFINE !Mapyear()
'2018'
!ENDDEFINE.

*Create a workings Folder - Combined Health and Social Care - 'Workings' folder*.

DEFINE !pathname1()
'/conf/irf/09-Tableau-Outputs/01-Development/02-SPSS-Outputs/01-HSC-Expenditure/Workings/2018-19/'
!ENDDEFINE.


* 'lookups' sub-folder*.
DEFINE !pathname2()
'/conf/irf/09-Tableau-Outputs/01-Development/02-SPSS-Outputs/01-HSC-Expenditure/Lookups/'
!ENDDEFINE.


* 'Outputs sav files' sub- folder*.
DEFINE !pathname3()
'/conf/irf/09-Tableau-Outputs/01-Development/02-SPSS-Outputs/01-HSC-Expenditure/Final_data/2018-19/'
!ENDDEFINE.


DEFINE !pathname4()
'/conf/irf/09-Tableau-Outputs/01-Development/04-Source-Data/01-HSC-Expenditure/'
!ENDDEFINE.



*end.
*Main Folder - Combined Health and Social Care*.






DATASET NAME DataSet8 WINDOW=FRONT.
DATASET NAME DataSet9 WINDOW=FRONT.
