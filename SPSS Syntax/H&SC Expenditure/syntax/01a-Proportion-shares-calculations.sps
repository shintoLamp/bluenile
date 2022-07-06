* Encoding: UTF-8.
*Alison McClelland - program to calculate proportion shares. 
*03/03/2015.
*Home care and personal care - to save as a .sav file.

*Updated by JM May 2017 for 2015/16 financial year.


GET DATA  /TYPE=TXT
  /FILE="/conf/irf/01-CPTeam/02-Functional-outputs/02-Combined Health and Social Care "+
    "File/Workings/18-19/HC-PC-Hours-18-19.csv"
  /ENCODING='UTF8'
  /DELCASE=LINE
  /DELIMITERS=","
  /QUALIFIER='"'
  /ARRANGEMENT=DELIMITED
  /FIRSTCASE=2
  /IMPORTCASE=ALL
  /VARIABLES=
  LCA A19
  Agegroup A5
  HC_Hours F9.2
  PC_Hours F9.2.
CACHE.
EXECUTE.
DATASET NAME DataSet2 WINDOW=FRONT.

alter type LCA (a27).

 * DATASET ACTIVATE DataSet2.
 * DATASET COPY  CnS.
 * DATASET ACTIVATE  CnS.
 * FILTER OFF.
 * USE ALL.
 * SELECT IF (LCA="Clackmannanshire" or LCA="Stirling").
 * EXECUTE.
 * DATASET ACTIVATE  CnS.

 * compute LCA="Clackmannanshire & Stirling".
 * execute.

 * DATASET ACTIVATE CnS.
 * DATASET DECLARE CS.
 * AGGREGATE
  /OUTFILE='CS'
  /BREAK=LCA Agegroup
  /HC_Hours=SUM(HC_Hours) 
  /PC_Hours=SUM(PC_Hours).

 * dataset activate DataSet2.


 * DATASET ACTIVATE DataSet2.
 * FILTER OFF.
 * USE ALL.
 * SELECT IF (LCA<>"Clackmannanshire" and LCA<>"Stirling").
 * EXECUTE.


 * ADD FILES /FILE=*
  /FILE='CS'.
 * EXECUTE.

 * dataset close CS.
 * dataset close CnS.

*Format data so it matches last year.

RECODE LCA ('Edinburgh, City of'='City of Edinburgh') ('Eilean Siar'='Western Isles').
execute.

sort cases by lca agegroup.

aggregate outfile = mode = addvariables
 /break lca
 /Total_HC_Hours = sum(HC_Hours)
 /Total_PC_Hours = sum(PC_Hours).
execute. 

*calculate total hours less 0-64 agegroup.

temporary.
if agegroup = '0-64' HC_Hours = 0.
if agegroup = '0-64' PC_Hours = 0.
aggregate outfile = mode = addvariables
 /break lca
 /OP_HC_Hours = sum(HC_Hours)
 /OP_PC_Hours = sum(PC_Hours).
execute. 

compute HC_share_total = HC_Hours/Total_HC_Hours.
compute PC_share_total = PC_Hours/Total_PC_Hours.
compute HC_share_OP =  HC_Hours/OP_HC_Hours.
compute PC_share_OP =  PC_Hours/OP_PC_Hours.
execute.

Save outfile ='/conf/irf/01-CPTeam/03-Social Care/02-Activity for LFR3 Apportionment/LCA_Proportion_Shares_HomeCare_PersonalCare_'+!year+'.sav'.


**********************************************************************************************************************************************************************************
*Direct payments proportion shares.

GET DATA  /TYPE=TXT
  /FILE="/conf/irf/01-CPTeam/02-Functional-outputs/02-Combined Health and Social Care File/Workings/18-19/Direct-Payments-18-19.csv"
  /ENCODING='UTF8'
  /DELCASE=LINE
  /DELIMITERS=","
  /QUALIFIER='"'
  /ARRANGEMENT=DELIMITED
  /FIRSTCASE=2
  /IMPORTCASE=ALL
  /VARIABLES=
  LCA A19
  ONE F11.2
  TWO F10.2
  THREE F10.2
  FOUR F10.2
  TOTAL F11.2.
CACHE.
EXECUTE.
DATASET NAME DataSet2 WINDOW=FRONT.


* Aggregate Clackmannanshire and Stirling

alter type LCA (a27).

 * DATASET ACTIVATE DataSet2.
 * DATASET COPY  CnS.
 * DATASET ACTIVATE  CnS.
 * FILTER OFF.
 * USE ALL.
 * SELECT IF (LCA="Clackmannanshire" or LCA="Stirling").
 * EXECUTE.
 * DATASET ACTIVATE  CnS.

 * compute LCA="Clackmannanshire & Stirling".
 * execute.

 * DATASET ACTIVATE CnS.
 * DATASET DECLARE CS.
 * AGGREGATE
  /OUTFILE='CS'
  /BREAK=LCA
  /ONE=SUM(ONE) 
  /TWO=SUM(TWO)
  /THREE=SUM(THREE) 
  /FOUR=SUM(FOUR)
  /TOTAL=SUM(TOTAL).

 * dataset activate DataSet2.


 * DATASET ACTIVATE DataSet2.
 * FILTER OFF.
 * USE ALL.
 * SELECT IF (LCA<>"Clackmannanshire" and LCA<>"Stirling").
 * EXECUTE.


 * ADD FILES /FILE=*
  /FILE='CS'.
 * EXECUTE.

 * dataset close CS.
 * dataset close CnS.

*Format data so it matches last year.

RECODE LCA ('Edinburgh, City of'='City of Edinburgh') ('Eilean Siar'='Western Isles').
execute.

*ONE = 0-64
TWO = 65-74
THREE = 75-84
FOUR = 85+.

Compute DP_OP = Total - ONE.
execute. 

VARSTOCASES
/Make Direct_Payments from ONE, TWO, THREE, FOUR
/Index Agegroup
/Keep LCA TOTal DP_OP
/Null = keep.
execute. 

Rename Variables Agegroup = Ageband.
String Agegroup (A5).
If Ageband = 1 Agegroup = '0-64'.
If Ageband = 2 Agegroup = '65-74'.
If Ageband = 3 Agegroup = '75-84'.
If Ageband = 4 Agegroup = '85+'.
Execute. 

Do if Agegroup = '0-64'.
Compute Proportion_Share_DP = 0.
Else if agegroup ne '0-64'.
compute Proportion_Share_DP = Direct_Payments / DP_OP.
End if.
Execute. 

save outfile ='/conf/irf/01-CPTeam/03-Social Care/02-Activity for LFR3 Apportionment/LCA_Proportion_Shares_DirectPayments_'+!year+'.sav'.


******************************************************************************************************************************************************************************
*Care Home proportion shares. 


GET DATA  /TYPE=TXT
  /FILE="/conf/irf/01-CPTeam/03-Social Care/02-Activity for LFR3 Apportionment/LCA-Care-Home-Proportions-18-19.csv"
  /ENCODING='UTF8'
  /DELCASE=LINE
  /DELIMITERS=","
  /ARRANGEMENT=DELIMITED
  /FIRSTCASE=2
  /IMPORTCASE=ALL
  /VARIABLES=
  LCA A19
  Agegroup A5
  Proportion A6
  Proportion_65 A6
  Proportion_Care_Home A11.
CACHE.
EXECUTE.
DATASET NAME DataSet2 WINDOW=FRONT.

* Aggregate Clackmannanshire and Stirling

alter type LCA (a27).

 * DATASET ACTIVATE DataSet2.
 * DATASET COPY  CnS.
 * DATASET ACTIVATE  CnS.
 * FILTER OFF.
 * USE ALL.
 * SELECT IF (LCA="Clackmannanshire" or LCA="Stirling").
 * EXECUTE.
 * DATASET ACTIVATE  CnS.

 * compute LCA="Clackmannanshire & Stirling".
 * execute.

 * DATASET ACTIVATE CnS.
 * alter type Proportion(f2).
 * alter type Proportion_65(f2).
 * DATASET DECLARE CS.
 * AGGREGATE
  /OUTFILE='CS'
  /BREAK=LCA Agegroup
  /Proportion=SUM(Proportion)
  /Proportion_65=SUM(Proportion_65).

 * dataset activate CS.

 * compute Proportion=Proportion/2.
 * compute Proportion_65=Proportion_65/2.
 * compute Proportion_Care_Home=Proportion/Proportion_65.
 * execute.
 * alter type Proportion_Care_Home(f12.11).



 * alter type Proportion(a6).
 * alter type Proportion_65(a6).
 * alter type Proportion_Care_Home(a11).

 * dataset activate DataSet2.


 * DATASET ACTIVATE DataSet2.
 * FILTER OFF.
 * USE ALL.
 * SELECT IF (LCA<>"Clackmannanshire" and LCA<>"Stirling").
 * EXECUTE.


 * ADD FILES /FILE=*
  /FILE='CS'.
 * EXECUTE.

 * dataset close CS.
 * dataset close CnS.

****The excel file for care homes was already in a format which made it easier to calculate the proportion shares in excel so there is no need to do anything to this file 
other than save it as a .sav.ss

RECODE LCA ('Edinburgh City'='City of Edinburgh') ('Highlands'='Highland').
execute.

save outfile ='/conf/irf/01-CPTeam/03-Social Care/02-Activity for LFR3 Apportionment/LCA_Proportion_Shares_CH_'+!year+'.sav'.




