filename seer9 "/folders/myfolders/SEER_1975_2016_TEXTDATA/incidence/yr1975_2016.seer9/OTHER.TXT";                                           
                                                                                      
data SKIN;                                                                              
  infile seer9 lrecl=394;                                                             
  input                                                                               
    @ 1   PUBCSNUM             $char8.  /* Patient ID */                              
    @ 9   REG                  $char10. /* SEER registry */                           
    @ 19  MAR_STAT             $char1.  /* Marital status at diagnosis */             
    @ 20  RACE1V               $char2.  /* Race/ethnicity */                          
    @ 23  NHIADE               $char1.  /* NHIA Derived Hisp Origin */                
    @ 24  SEX                  $char1.  /* Sex */                                     
    @ 25  AGE_DX               $char3.  /* Age at diagnosis */                        
    @ 28  YR_BRTH              $char4.  /* Year of birth */                           
    @ 35  SEQ_NUM              $char2.  /* Sequence number */                         
    @ 37  MDXRECMP             $char2.  /* Month of diagnosis */                      
    @ 39  YEAR_DX              4.  /* Year of diagnosis */                       
    @ 43  PRIMSITE             $char4.  /* Primary site ICD-O-2 (1973+) */            
    @ 47  LATERAL              $char1.  /* Laterality */                              
    @ 48  HISTO2V              $char4.  /* Histologic Type ICD-O-2 */                 
    @ 52  BEHO2V               $char1.  /* Behavior Code ICD-O-2*/                    
    @ 53  HISTO3V              $char4.  /* Histologic Type ICD-O-3 */                 
    @ 57  BEHO3V               $char1.  /* Behavior code ICD-O-3 */                   
    @ 58  GRADE                $char1.  /* Grade */                                   
    @ 59  DX_CONF              $char1.  /* Diagnostic confirmation */                 
    @ 60  REPT_SRC             $char1.  /* Type of reporting source */                
    @ 61  EOD10_SZ             $char3.  /* EOD 10 - size (1988+) */                   
    @ 64  EOD10_EX             $char2.  /* EOD 10 - extension */                      
    @ 66  EOD10_PE             $char2.  /* EOD 10 - path extension */                 
    @ 68  EOD10_ND             $char1.  /* EOD 10 - lymph node */                     
    @ 69  EOD10_PN             $char2.  /* EOD 10 - positive lymph nodes examined */  
    @ 71  EOD10_NE             $char2.  /* EOD 10 - number of lymph nodes examined */ 
    @ 73  EOD13                $char13. /* EOD--old 13 digit */                       
    @ 86  EOD2                 $char2.  /* EOD--old 2 digit */                        
    @ 88  EOD4                 $char4.  /* EOD--old 4 digit */                        
    @ 92  EOD_CODE             $char1.  /* Coding system for EOD */                   
    @ 93  TUMOR_1V             $char1.  /* Tumor marker 1 */                          
    @ 94  TUMOR_2V             $char1.  /* Tumor marker 2 */                          
    @ 95  TUMOR_3V             $char1.  /* Tumor marker 3 */                          
    @ 96  CSTUMSIZ             $char3.  /* CS Tumor size */                           
    @ 99  CSEXTEN              $char3.  /* CS Extension */                            
    @ 102 CSLYMPHN             $char3.  /* CS Lymph Nodes */                          
    @ 105 CSMETSDX             $char2.  /* CS Mets at DX */                           
    @ 107 CS1SITE              $char3.  /* CS Site-Specific Factor 1 */               
    @ 110 CS2SITE              $char3.  /* CS Site-Specific Factor 2 */               
    @ 113 CS3SITE              $char3.  /* CS Site-Specific Factor 3 */               
    @ 116 CS4SITE              $char3.  /* CS Site-Specific Factor 4 */               
    @ 119 CS5SITE              $char3.  /* CS Site-Specific Factor 5 */               
    @ 122 CS6SITE              $char3.  /* CS Site-Specific Factor 6 */               
    @ 125 CS25SITE             $char3.  /* CS Site-Specific Factor 25 */              
    @ 128 DAJCCT               $char2.  /* Derived AJCC T */                          
    @ 130 DAJCCN               $char2.  /* Derived AJCC N */                          
    @ 132 DAJCCM               $char2.  /* Derived AJCC M */                          
    @ 134 DAJCCSTG             $char2.  /* Derived AJCC Stage Group */                
    @ 136 DSS1977S             $char1.  /* Derived SS1977 */                          
    @ 137 SCSSM2KO             $char1.  /* SEER Combined Summary Stage 2000 (2004+) */                     
    @ 141 CSVFIRST             $char6.  /* CS Version Input Original */               
    @ 147 CSVLATES             $char6.  /* CS Version Derived */                      
    @ 153 CSVCURRENT           $char6.  /* CS Version Input Current */                
    @ 159 SURGPRIF             $char2.  /* RX Summ--surg prim site */                 
    @ 161 SURGSCOF             $char1.  /* RX Summ--scope reg LN sur 2003+*/          
    @ 162 SURGSITF             $char1.  /* RX Summ--surg oth reg/dis */               
    @ 163 NUMNODES             $char2.  /* Number of lymph nodes */                   
    @ 166 NO_SURG              $char1.  /* Reason no cancer-directed surgery */       
    @ 170 SS_SURG              $char2.  /* Site specific surgery (1983-1997) */       
    @ 174 SURGSCOP             $char1.  /* Scope of lymph node surgery 98-02*/        
    @ 175 SURGSITE             $char1.  /* Surgery to other sites */                  
    @ 176 REC_NO               $char2.  /* Record number */                           
    @ 191 TYPE_FU              $char1.  /* Type of followup expected */               
    @ 192 AGE_1REC             $char2.  /* Age recode <1 year olds */                 
    @ 199 SITERWHO             $char5.  /* Site recode ICD-O-3/WHO 2008 */            
    @ 204 ICDOTO9V             $char4.  /* Recode ICD-O-2 to 9 */                     
    @ 208 ICDOT10V             $char4.  /* Recode ICD-O-2 to 10 */                    
    @ 218 ICCC3WHO             $char3.  /* ICCC site recode ICD-O-3/WHO 2008 */       
    @ 221 ICCC3XWHO            $char3.  /* ICCC site rec extended ICD-O-3/ WHO 2008*/ 
    @ 224 BEHTREND             $char1.  /* Behavior recode for analysis */            
    @ 226 HISTREC              $char2.  /* Broad Histology recode */                  
    @ 228 HISTRECB             $char2.  /* Brain recode */                            
    @ 230 CS0204SCHEMA         $char3.  /* CS Schema v0204*/                          
    @ 233 RAC_RECA             $char1.  /* Race recode A */                           
    @ 234 RAC_RECY             $char1.  /* Race recode Y */                           
    @ 235 ORIGRECB             $char1.  /* Origin Recode NHIA */                      
    @ 236 HST_STGA             $char1.  /* SEER historic stage A */                   
    @ 237 AJCC_STG             $char2.  /* AJCC stage 3rd edition (1988+) */          
    @ 239 AJ_3SEER             $char2.  /* SEER modified AJCC stage 3rd ed (1988+) */ 
    @ 241 SSS77VZ              $char1.  /* SEER Summary Stage 1977 (1995-2000) */     
    @ 242 SSSM2KPZ             $char1.  /* SEER Summary Stage 2000 2000 (2001-2003) */
    @ 245 FIRSTPRM             $char1.  /* First malignant primary indicator */       
    @ 246 ST_CNTY              $char5.  /* State-county recode */                     
    @ 255 CODPUB               $char5.  /* Cause of death to SEER site recode */      
    @ 260 CODPUBKM             $char5.  /* COD to site rec KM */                      
    @ 265 STAT_REC             $char1.  /* Vital status recode (study cutoff used) */ 
    @ 266 IHSLINK              $char1.  /* IHS link */                                
    @ 267 SUMM2K               $char1.  /* Historic SSG 2000 Stage */                 
    @ 268 AYASITERWHO          $char2.  /* AYA site recode/WHO 2008 */                
    @ 270 LYMSUBRWHO           $char2.  /* Lymphoma subtype recode/WHO 2008 */        
    @ 272 VSRTSADX             $char1.  /* SEER cause of death classification */      
    @ 273 ODTHCLASS            $char1.  /* SEER other cause of death classification */
    @ 274 CSTSEVAL             $char1.  /* CS EXT/Size Eval */                        
    @ 275 CSRGEVAL             $char1.  /* CS Nodes Eval */                           
    @ 276 CSMTEVAL             $char1.  /* CS Mets Eval */                            
    @ 277 INTPRIM              $char1.  /* Primary by International Rules */          
    @ 278 ERSTATUS             $char1.  /* ER Status Recode Breast Cancer (1990+)*/   
    @ 279 PRSTATUS             $char1.  /* PR Status Recode Breast Cancer (1990+)*/   
    @ 280 CSSCHEMA             $char2.  /* CS Schema - AJCC 6th Edition */            
    @ 282 CS8SITE              $char3.  /* Cs Site-specific Factor 8 */               
    @ 285 CS10SITE             $char3.  /* CS Site-Specific Factor 10*/               
    @ 288 CS11SITE             $char3.  /* CS Site-Specific Factor 11*/               
    @ 291 CS13SITE             $char3.  /* CS Site-Specific Factor 13*/               
    @ 294 CS15SITE             $char3.  /* CS Site-Specific Factor 15*/               
    @ 297 CS16SITE             $char3.  /* CS Site-Specific Factor 16*/               
    @ 300 VASINV               $char1.  /* Lymph-vascular Invasion (2004+)*/          
    @ 301 SRV_TIME_MON         $char4.  /* Survival months */                         
    @ 305 SRV_TIME_MON_FLAG    $char1.  /* Survival months flag */                    
    @ 311 INSREC_PUB           $char1.  /* Insurance Recode (2007+) */                
    @ 312 DAJCC7T              $char3.  /* Derived AJCC T 7th ed */                   
    @ 315 DAJCC7N              $char3.  /* Derived AJCC N 7th ed */                   
    @ 318 DAJCC7M              $char3.  /* Derived AJCC M 7th ed */                   
    @ 321 DAJCC7STG            $char3.  /* Derived AJCC 7 Stage Group */              
    @ 324 ADJTM_6VALUE         $char2.  /* Adjusted AJCC 6th T (1988+) */             
    @ 326 ADJNM_6VALUE         $char2.  /* Adjusted AJCC 6th N (1988+) */             
    @ 328 ADJM_6VALUE          $char2.  /* Adjusted AJCC 6th M (1988+) */             
    @ 330 ADJAJCCSTG           $char2.  /* Adjusted AJCC 6th Stage (1988+) */         
    @ 332 CS7SITE              $char3.  /* CS Site-Specific Factor 7 */               
    @ 335 CS9SITE              $char3.  /* CS Site-specific Factor 9 */               
    @ 338 CS12SITE             $char3.  /* CS Site-Specific Factor 12 */              
    @ 341 HER2                 $char1.  /* Derived HER2 Recode (2010+) */             
    @ 342 BRST_SUB             $char1.  /* Breast Subtype (2010+) */                  
    @ 348 ANNARBOR             $char1.  /* Lymphoma - Ann Arbor Stage (1983+) */      
    @ 349 SCMETSDXB_PUB        $char1.  /* SEER Combined Mets at DX-bone (2010+) */
    @ 350 SCMETSDXBR_PUB       $char1.  /* SEER Combined Mets at DX-brain (2010+) */
    @ 351 SCMETSDXLIV_PUB      $char1.  /* SEER Combined Mets at DX-liver (2010+)*/
    @ 352 SCMETSDXLUNG_PUB     $char1.  /* SEER Combined Mets at DX-lung (2010+) */            
    @ 353 T_VALUE              $char2.  /* T value - based on AJCC 3rd (1988-2003) */ 
    @ 355 N_VALUE              $char2.  /* N value - based on AJCC 3rd (1988-2003) */ 
    @ 357 M_VALUE              $char2.  /* M value - based on AJCC 3rd (1988-2003) */ 
    @ 359 MALIGCOUNT           $char2.  /* Total number of in situ/malignant tumors for patient */        
    @ 361 BENBORDCOUNT         $char2.  /* Total number of benign/borderline tumors for patient */   
    @ 364 TUMSIZS              $char3.  /* Tumor Size Summary (2016+) */
    @ 367 DSRPSG               $char5.  /* Derived SEER Cmb Stg Grp (2016+) */
    @ 372 DASRCT               $char5.  /* Derived SEER Combined T (2016+) */
    @ 377 DASRCN               $char5.  /* Derived SEER Combined N (2016+) */
    @ 382 DASRCM               $char5.  /* Derived SEER Combined M (2016+) */
    @ 387 DASRCTS              $char1.  /* Derived SEER Combined T Src (2016+) */
    @ 388 DASRCNS              $char1.  /* Derived SEER Combined N Src (2016+) */
    @ 389 DASRCMS              $char1.  /* Derived SEER Combined M Src (2016+) */
    @ 390 TNMEDNUM             $char2.  /* TNM Edition Number (2016+) */
    @ 392  METSDXLN            $char1.  /* Mets at DX-Distant LN (2016+) */
    @ 393  METSDXO             $char1.  /* Mets at DX-Other (2016+) */     ; 
    
run;  

/*SAS code for STAT 770 Homework 1. Chose 10 variables from SEER data and give brief
description of each using descriptive statistics and frequencies, counts ect. 
Using subset of SKIN SEER data. Due 1/27/2020 */
	

/*Selecting Variables and coersing to proper data type*/
proc sql;
	CREATE TABLE SKIN_VARS as
	SELECT pubcsnum as ID,
		   input(reg, 10.) as Registry,
		   sex as Sex_,
		   mar_stat as MaritalStatus_,
		   input(age_dx, 4.) as Age,
		   year_dx as Year,
		   input(eod10_sz, 4.) as TS88_03,
		   input(cstumsiz,4.) as TS04_15,
		   rac_recy as Race_,
		   input(srv_time_mon, 4.) as MonthsSurvived,
		   beho3v as TumorBehavior_,
		   insrec_pub as Insurance_,
		   primsite as site
	FROM SKIN
	WHERE primsite in ("C440","C441","C442","C443","C444","C445","C446","C447","C448","C449")
	      AND year_dx >= 1988 and year_dx <=2015;
QUIT;

/*Combining Tumor size variables and subsetting data based on year 
Making other variables easier to interpret(Sex, registry, race) */
data SKIN_VARS;
	set SKIN_VARS;
	one=1;
	TumorSize=0;
	if TS88_03>TS04_15 then TumorSize = TS88_03;
	else TumorSize=TS04_15;
	where Year>=1988 ;
	drop TS88_03 TS04_15;
	
	/* 	Coding race */
	race="-----";
	if race_ = 1 then race="White";
	else if race_ = 2 then race="Black";
	else if race_ = 3 then race="NatAm";
	else if race_ = 4 then race="As/AI";
	else race="Other";
	
	/*Coding State Based on Registry Id */
	state="--";
	if  registry in (1501, 153, 1535, 1541) then state="CA";
	else if  registry = 1502 then state = "CT";
	else if  registry = 1520 then state = "MI";
	else if  registry = 1521 then state = "HI";
	else if  registry = 1522 then state = "IA";
	else if  registry = 1523 then state = "NM";
	else if  registry =  1525 then state = "WA";
	else if  registry =  1526 then state = "UT";
	else if  registry in (1527,  1537,  1547) then state = "GA";
	else if  registry =  1529 then state = "AK";
	else if  registry =  1542 then state = "KT";
	else if  registry =  1543 then state = "LA";
	else if  registry =  1544 then state = "NJ";
	else state="other";
	
	/*Coding Sex*/
	sex="------";
	if sex_="1" then sex = "Male";
	else sex="Female";
	
	/*Coding Tumor Behavior*/
	TumorBehavior="-------------------";
	if TumorBehavior_="0" then TumorBehavior="Benign";
	else if TumorBehavior_="1" then TumorBehavior="Mal Pot.";
	else if TumorBehavior_="2" then TumorBehavior="Carcinoma in situ";
	else if TumorBehavior_="3" then TumorBehavior="Malignant";
	else TumorBehavior="NA";
	
	/*Coding insurance*/
	Insurance="--------------";
	if Insurance_="1" then Insurance="Uninsured";
	else if Insurance_="2" then Insurance="Medicaid";
	else if Insurance_ in ("3", "4") then Insurance="Insured";
	else if Insurance_="5" then Insurance="Status Unknown";
	else Insurance="NA";
	
	/*Recoding Mariage Status*/
	MaritalStatus="---------";
	if MaritalStatus_="1" then MaritalStatus="Single";
	else if MaritalStatus_="2" then MaritalStatus="Married";
	else if MaritalStatus_ in ("3","4","5","6") then MaritalStatus="Separated";
	else MaritalStatus="Unknown";
	
	drop race_ Insurance_ Sex_ TumorBehavior_  MaritalStatus_;
	where year >= 2000;
run;


proc freq data=SKIN_VARS;
	table site;
run;


**************************************************;
/* Descriptive Statistics for Age at Diagnosis  */
**************************************************;
title2 "Age at Diagnosis";
proc means data=SKIN_VARS mean median std maxdec=2;
	var age;
	where age<999;
run;

/* Showing number of observations that were removed due to missing obs */
proc freq data=SKIN_VARS;
	table age /  nopercent nocum;
	where age>=120;
run;

/* Histogram for age*/
proc sgplot data=SKIN_VARS ;
	histogram age / binstart=0 binwidth=10 showbins;
	where age<999;
run;


**************************************************;
/* Descriptive Statistics for Tumor Size         */
**************************************************;
title2 "Tumor Size in mm";
proc means data=SKIN_VARS mean median std maxdec=2;
	var TumorSize;
	where TumorSize<989;
run;

/* Showing number of observations that were removed due to imprecise measures  */
proc freq data=SKIN_VARS;
	table TumorSize /  nopercent nocum;
	where TumorSize>=989;
run;

/* Histogram for Tumor size*/
proc sgplot data=SKIN_VARS ;
	histogram TumorSize / binstart=0 binwidth=25 showbins;
	where TumorSize<989;
run;

**************************************************;
/* Descriptive Statistics for Survival Months    */
**************************************************;
title2 "Months Survived";
proc means data=SKIN_VARS mean median std maxdec=2;
	var MonthsSurvived;
	where MonthsSurvived<9999;
run;

/* Showing number of observations that were removed due to imprecise measures  */
proc freq data=SKIN_VARS;
	table MonthsSurvived /  nopercent nocum;
	where MonthsSurvived>=9999;
run;

/* Histogram for Survival Months*/
proc sgplot data=SKIN_VARS ;
	histogram MonthsSurvived / binstart=0 binwidth=12 showbins;
	where MonthsSurvived<9999;
run;

*********************************************
/* Counts and relative frequencies for Sex */
*********************************************;
title "Breakdown by Sex";
proc freq data=SKIN_VARS;
	table Sex / nocum;
run;

/* barplot for Sex */
proc sgplot data=SKIN_VARS;
	vbar Sex;
run;


**********************************************
/* Counts and relative frequencies for Race */
**********************************************;
title "Breakdown by Race";
proc freq data=SKIN_VARS;
	table Race / nocum;
run;

/* barplot for Race */
proc sgplot data=SKIN_VARS;
	vbar Race;
run;


******************************************
/* Counting number of obs for each year */
******************************************;
Title "Yearly Trend For Total Diagnoses";
proc sql;
	create table years as
	select year, sum(one) as Count
	from SKIN_VARS
	group by year;
quit;

/* Using counts of diagnosis by year for trend of diagnosis every year */
proc sgplot data=years;
	scatter x=year y=count;
	reg x=year y=count;
	xaxis  min=1988 max=2018;
run;


***********************************************
/* Counts and relative frequencies for State */
***********************************************;
title "Breakdown by State";
proc freq data=SKIN_VARS;
	table State / nocum;
run;

/* barplot for State */
proc sgplot data=SKIN_VARS;
	vbar State;
run;


**********************************************
/* Counts and relative frequencies for Race */
**********************************************;
title "Breakdown by Marital Status";
proc freq data=SKIN_VARS;
	table MaritalStatus / nocum;
run;

/* barplot for Marital Status */
proc sgplot data=SKIN_VARS;
	vbar MaritalStatus;
run;


********************************************************
/* Counts and relative frequencies for Tumor Behavior */
********************************************************;
title "Breakdown by Tumor Behavior";
proc freq data=SKIN_VARS;
	table TumorBehavior / nocum;
run;

/* barplot for Tumor Behavior */
proc sgplot data=SKIN_VARS;
	vbar TumorBehavior;
run;


***************************************************
/* Counts and relative frequencies for Insurance */
***************************************************;
title "Breakdown by Insurance";
proc freq data=SKIN_VARS;
	table Insurance / nocum;
run;

/* barplot for Insurance */
proc sgplot data=SKIN_VARS;
	vbar Insurance;
run;






