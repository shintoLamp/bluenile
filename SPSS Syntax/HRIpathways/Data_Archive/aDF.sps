GET DATA  /TYPE=TXT
  /FILE='\conf\sourcedev\TableauUpdates\HRIpathways\HRI_OVERVIEW_SCOT Extract.csv'
  /ENCODING='Locale'
  /DELCASE=LINE
  /DELIMITERS="\t"
  /QUALIFIER='"'
  /ARRANGEMENT=DELIMITED
  /FIRSTCASE=2
  /IMPORTCASE=ALL
  /VARIABLES=
  AgeBand A5
  Average_cost F1.0
  Data A5
  HbCode A1
  HBname A8
  HRIGroup A30
  HRISort F1.0
  Individuals F1.0
  Individuals_sum F1.0
  LaCode A1
  LCAname A8
  NumberofRecords F1.0
  Percentagepop F1.0
  Population F3.1
  RTotal_Exp F11.2
  RTotal_Exp_Percent F11.9
  Year A7
  health_Expenditure_cost F11.3
  health_Expenditure_cost_max F1.0
  health_Expenditure_cost_min F1.0.
CACHE.
EXECUTE.
DATASET NAME DataSet8 WINDOW=FRONT.





