*Asthma analysis
*Angela Pinot de Moira
*July 2022
***************************
*Open data and create additional variables:

cd "D:\Data\workdata\707796\Results"

use "D:\Data\workdata\707796\analysis_data.dta", clear

*Parity
recode parity_m 1/4=1

*Mode of delivery
recode mode_delivery 1/2=0 3/5=1, gen(c_section)

*Household size
run  "D:\Data\workdata\707796\Do files\hh size.do" 

*Source of animal exposure
run "D:\Data\workdata\707796\Do files\animal_source.do"


*Rabbit, rodent and exotic variables:

run "D:\Data\workdata\707796\Do files\new rabbit, rodents and other_furry variables.do"


********************************************************************************
*Setup data

keep if asthma!=. 
drop if inlist(migration6,1,2) //n=1,393 excludes children who emigrated before 6th birthday
drop if doddato< bday_6 & !mi(bday_6) //501 children died before 6th birthday

*create date of 13th birthday:
gen day = day(eventda)
replace day=28 if day(eventda)==29 & month(eventda)==2
gen month = month(eventda)
gen year = (year(eventda)) + 13
gen bday_13 = mdy(month,day,year)
format bday_13 %d

*

egen outdate = rowmin(asthma_date doddato migration_date6 bday_13)
format outdate %d
format asthma_date %d

gen asthma_cox = asthma
replace asthma_cox =0 if asthma_date>outdate & asthma_date!=.

 gen start_date=bday_6 - 1
*stset timeout, failure(asthma_cox==1) origin(eventda) enter(bday_6) scale(365.25) id(lbgravff)

stset outdate, failure(asthma_cox==1) origin(eventda) enter(start_date) ///
scale(365.25) id(lbgravff) exit(time bday_6 + 365.25*7)

*drop multiples:
keep if flerfold==1

********************************************************************************
*Use reported parental history of allergy:

drop rhinitis_p_reg ///
asthma_p_reg asthma_m_reg rhinitis_m_reg
egen family_allergy_asthma = rowmax(asthma_bf asthma_m allergy_f allergy_inh_m)
recode family_allergy_asthma 0=1 1=0, gen(family_allergy_asthma2)
gen rhinitis_p_reg = allergy_f
gen asthma_p_reg = asthma_bf
gen asthma_m_reg = asthma_m
gen rhinitis_m_reg = allergy_inh_m


********************************************************************************
*Create a variable to indicate missingness (to identify study population):

egen miss = rowmiss(cat_int1 dog_int1 rabbit_int1 rodent_int1 exotic_int1 bird_int1 ///
livestock_int1 rhinitis_p_reg asthma_p_reg asthma_m_reg rhinitis_m_reg ///
mat_ed_3cat hhincome_cat crowding_cat children_cat  ///
agebirth_m_y preg_smk copenhagen sex)

recode miss 0=0 1/max=1

*Check missingness:
summ asthma_cox cat_int1 dog_int1 rabbit_int1 rodent_int1 exotic_int1 bird_int1 ///
livestock_int1 rhinitis_p_reg asthma_p_reg asthma_m_reg rhinitis_m_reg ///
mat_ed_3cat hhincome_cat crowding_cat children_cat  ///
agebirth_m_y preg_smk copenhagen  antibiotics sex miss

********************************************************************************
*Univariate analysis
/*
foreach var of varlist cat_int1 dog_int1 rabbit_int1 rodent_int1 exotic_int1 bird_int1 livestock_int1 ///
pet_dog - pet_bird cat dog other_furry {
sts graph, by(`var') ylabel(minmax)
stcox `var', nolog noshow schoenfeld(sch*) scaledsch(sca*)
stphtest, log detail
stphtest, log plot(`var') yline(0)
drop sch1 sca1
}
*/
********************************************************************************
*Table 2 - overall association

log using "D:\Data\workdata\707796\Results\Collated results\Rabbits rodents\AR_13years\FINAL\asthma_log_ije.smcl"


*Unadjusted:
foreach var of varlist cat_int1 dog_int1 rabbit_int1 rodent_int1 exotic_int1 bird_int1 livestock_int1 {
xi: stcox i.`var' if miss==0, strata(sex) vce(cluster mcpr)
est store `var'
}


*Adjusted 1:


*Adjusted:----------------------------------------------------------------------


cd "D:\Data\workdata\707796\Results" 

foreach var of varlist cat_int1 dog_int1 rabbit_int1 rodent_int1 bird_int1 ///
livestock_int1 {
display "`var'"
char mat_ed_3cat[omit] 2
char crowding_cat[omit] 2
xi: stcox i.cat_int1 i.dog_int1 i.rabbit_int1 i.rodent_int1 i.exotic_int1 i.bird_int1 ///
i.livestock_int1 i.rhinitis_p_reg i.asthma_p_reg i.asthma_m_reg i.rhinitis_m_reg ///
i.mat_ed_3cat i.hhincome_cat i.crowding_cat i.children_cat  ///
agebirth_m_y i.preg_smk  if miss==0,  ///
strata(sex copenhagen) nolog noshow schoenfeld(sch*) mgale(mg) scaledsch(sca*) vce(cluster mcpr)
est store adj_`var'
predict cs, csnell
stphtest, log detail
drop sch* sca* mg cs
}


********************************************************************************
*TABLE 3 - source of animal exposure

cd "D:\Data\workdata\707796\Results"

// categorical variable - none, indoor, other //
 //set up data//
rename cat_source pc 
rename dog_source pd 
rename rabbit_source pra 
rename rodent_source pro 
rename exotic_source pe 
rename bird_source  pb 
rename livestock_source fl 


/////////////

*Minimally adjusted:
foreach var of varlist pc pd pra pro pe pb fl  {
xi: stcox i.`var' if miss==0, strata(sex) vce(cluster mcpr)
est store `var'
}


*Adjusted:----------------------------------------------------------------------

cd "D:\Data\workdata\707796\Results" 

foreach var of varlist pc pd pra pro pb fl ///
 {
display "`var'"
char mat_ed_3cat[omit] 2
char crowding_cat[omit] 2
xi: stcox i.pc i.pd i.pra i.pro i.pe i.pb i.fl ///
 i.asthma_bf i.asthma_m i.allergy_f i.allergy_inh_m  ///
i.mat_ed_3cat i.hhincome_cat i.crowding_cat i.children_cat  ///
 agebirth_m_y i.preg_smk  if miss==0, strata(sex copenhagen) nolog noshow schoenfeld(sch*) scaledsch(sca*) vce(cluster mcpr)
est store adj_`var'
stphtest, log detail
drop sch* sca*
} 


*******************************************************************************
*Table 4
*Parental History Interactions 

gen paa = family_allergy_asthma 
gen paa2 = family_allergy_asthma2


foreach var of varlist cat_int1 dog_int1 rabbit_int1 rodent_int1 bird_int1 livestock_int1 {
foreach v of varlist  paa paa2   {
if "`var'"=="cat_int1" {
display "`var'"
char mat_ed_3cat[omit] 2
char crowding_cat[omit] 2
xi: stcox i.cat_int1*`v' i.dog_int1 i.rabbit_int1 i.rodent_int1 i.exotic_int1 i.bird_int1 ///
i.livestock_int1  ///
i.mat_ed_3cat i.hhincome_cat i.crowding_cat i.children_cat  ///
agebirth_m_y i.preg_smk  if miss==0,  ///
strata(sex copenhagen) nolog noshow schoenfeld(sch*) mgale(mg) scaledsch(sca*) vce(cluster mcpr)
est store `var'_`v'_a
predict cs, csnell
stphtest, log detail
drop sch* sca* mg cs
} 
else if "`var'"=="dog_int1" {
display "`var'"
char mat_ed_3cat[omit] 2
char crowding_cat[omit] 2
xi: stcox i.cat_int1 i.dog_int1*`v' i.rabbit_int1 i.rodent_int1 i.exotic_int1 i.bird_int1 ///
i.livestock_int1  ///
i.mat_ed_3cat i.hhincome_cat i.crowding_cat i.children_cat  ///
agebirth_m_y i.preg_smk  if miss==0,  ///
strata(sex copenhagen) nolog noshow schoenfeld(sch*) mgale(mg) scaledsch(sca*) vce(cluster mcpr)
est store `var'_`v'_a
predict cs, csnell
stphtest, log detail
drop sch* sca* mg cs
}
else if "`var'"=="rabbit_int1" {
display "`var'"
char mat_ed_3cat[omit] 2
char crowding_cat[omit] 2
xi: stcox i.cat_int1 i.dog_int1 i.rabbit_int1*`v' i.rodent_int1 i.exotic_int1 i.bird_int1 ///
i.livestock_int1  ///
i.mat_ed_3cat i.hhincome_cat i.crowding_cat i.children_cat  ///
agebirth_m_y i.preg_smk  if miss==0,  ///
strata(sex copenhagen) nolog noshow schoenfeld(sch*) mgale(mg) scaledsch(sca*) vce(cluster mcpr)
est store `var'_`v'_a
predict cs, csnell
stphtest, log detail
drop sch* sca* mg cs
}
else if "`var'"=="rodent_int1" {
display "`var'"
char mat_ed_3cat[omit] 2
char crowding_cat[omit] 2
xi: stcox i.cat_int1 i.dog_int1 i.rabbit_int1 i.rodent_int1*`v' i.exotic_int1 i.bird_int1 ///
i.livestock_int1  ///
i.mat_ed_3cat i.hhincome_cat i.crowding_cat i.children_cat  ///
agebirth_m_y i.preg_smk  if miss==0,  ///
strata(sex copenhagen) nolog noshow schoenfeld(sch*) mgale(mg) scaledsch(sca*) vce(cluster mcpr)
est store `var'_`v'_a
predict cs, csnell
stphtest, log detail
drop sch* sca* mg cs
}
else if "`var'"=="bird_int1" {
display "`var'"
char mat_ed_3cat[omit] 2
char crowding_cat[omit] 2
xi: stcox i.cat_int1 i.dog_int1 i.rabbit_int1 i.rodent_int1 i.exotic_int1 i.bird_int1*`v' ///
i.livestock_int1  ///
i.mat_ed_3cat i.hhincome_cat i.crowding_cat i.children_cat  ///
agebirth_m_y i.preg_smk  if miss==0,  ///
strata(sex copenhagen) nolog noshow schoenfeld(sch*) mgale(mg) scaledsch(sca*) vce(cluster mcpr)
est store `var'_`v'_a
predict cs, csnell
stphtest, log detail
drop sch* sca* mg cs
}
else if "`var'"=="livestock_int1" {
display "`var'"
char mat_ed_3cat[omit] 2
char crowding_cat[omit] 2
xi: stcox i.cat_int1 i.dog_int1 i.rabbit_int1 i.rodent_int1 i.exotic_int1 i.bird_int1 ///
i.livestock_int1*`v'  ///
i.mat_ed_3cat i.hhincome_cat i.crowding_cat i.children_cat  ///
agebirth_m_y i.preg_smk  if miss==0,  ///
strata(sex copenhagen) nolog noshow schoenfeld(sch*) mgale(mg) scaledsch(sca*) vce(cluster mcpr)
est store `var'_`v'_a
predict cs, csnell
stphtest, log detail
drop sch* sca* mg cs
}
}
}


********************************************************************************
*Table 5 - timing of exposure


*Create a variable to indicate missing values (to identify study population):

egen miss2 = rowmiss(cat dog bird rabbit rodent exotic ///
asthma_bf asthma_m allergy_f allergy_inh_m   ///
mat_ed_3cat hhincome_cat crowding_cat children_cat  ///
agebirth_m_y preg_smk sex copenhagen)

recode miss2 0=0 1/max=1

/////////////


*Unadjusted:
foreach var of varlist cat dog rabbit rodent bird {
xi: stcox i.`var' if miss2==0, strata(sex) vce(cluster mcpr)
est store `var'_time
}

foreach var of varlist cat dog rabbit rodent bird {
display "`var'"
char mat_ed_3cat[omit] 2
char crowding_cat[omit] 2
xi: stcox i.cat i.dog i.rabbit i.rodent i.exotic i.bird ///
 i.asthma_bf i.asthma_m i.allergy_f i.allergy_inh_m ///
i.mat_ed_3cat i.hhincome_cat i.crowding_cat i.children_cat  ///
 agebirth_m_y i.preg_smk  if miss2==0, strata(sex copenhagen) nolog noshow schoenfeld(sch*) scaledsch(sca*) vce(cluster mcpr)
est store adj_`var'_timing
stphtest, log detail
drop sch* sca*
} 




********************************************************************************
*Table S2

*Stratified by sex

foreach var of varlist cat_int1 dog_int1 rabbit_int1 rodent_int1 bird_int1 ///
livestock_int1 {
foreach n of numlist  1 2   {
display "`var'"
if `n'==1 {
char mat_ed_3cat[omit] 2
char crowding_cat[omit] 2
xi: stcox i.cat_int1 i.dog_int1 i.rabbit_int1 i.rodent_int1 i.exotic_int1 i.bird_int1 ///
i.livestock_int1 i.rhinitis_p_reg i.asthma_p_reg i.asthma_m_reg i.rhinitis_m_reg ///
i.mat_ed_3cat i.hhincome_cat i.crowding_cat i.children_cat  ///
agebirth_m_y i.preg_smk  if miss==0 & sex==`n',  ///
strata(copenhagen) nolog noshow schoenfeld(sch*) mgale(mg) scaledsch(sca*) vce(cluster mcpr)
est store adj_`var'_`n'
predict cs, csnell
stphtest, log detail
drop sch* sca* mg cs
}
else if `n'==2 {
char mat_ed_3cat[omit] 2
char crowding_cat[omit] 2
xi: stcox i.cat_int1 i.dog_int1 i.rabbit_int1 i.rodent_int1 i.exotic_int1 i.bird_int1 ///
i.livestock_int1 i.rhinitis_p_reg  i.asthma_m_reg i.rhinitis_m_reg ///
i.mat_ed_3cat i.hhincome_cat i.crowding_cat i.children_cat  ///
agebirth_m_y i.preg_smk i.copenhagen if miss==0 & sex==`n',  ///
strata(i.asthma_p_reg) nolog noshow schoenfeld(sch*) mgale(mg) scaledsch(sca*) vce(cluster mcpr)
est store adj_`var'_`n'
predict cs, csnell
stphtest, log detail
drop sch* sca* mg cs
}
}
}


///////////////////////////////////////////////////////////////////////////////

*Table S5

gen med = mat_ed_3cat

foreach var of varlist cat_int1 dog_int1 rabbit_int1 rodent_int1 bird_int1 ///
livestock_int1 {
foreach n of numlist 1 2 3 {
display "`var'"
display "`n'"
char crowding_cat[omit] 2
xi: stcox i.cat_int1 i.dog_int1 i.rabbit_int1 i.rodent_int1 i.exotic_int1 i.bird_int1 ///
i.livestock_int1 i.rhinitis_p_reg i.asthma_p_reg i.asthma_m_reg i.rhinitis_m_reg ///
i.hhincome_cat i.crowding_cat i.children_cat  ///
agebirth_m_y i.preg_smk  if miss==0 & mat_ed_3cat==`n',  strata(sex copenhagen) ///
nolog noshow schoenfeld(sch*) mgale(mg) scaledsch(sca*) vce(cluster mcpr)
est store a_mat_ed_`var'_`n'
predict cs, csnell
stphtest, log detail
drop sch* sca* mg cs
}
}



*LRtests (for maternal education):


foreach var of varlist cat_int1 dog_int1 rabbit_int1 rodent_int1 bird_int1 ///
livestock_int1 {
if "`var'"=="cat_int1" {
display "`var'"
char mat_ed_3cat[omit] 2
char crowding_cat[omit] 2
quietly xi: stcox i.cat_int1 i.mat_ed_3cat i.dog_int1 i.rabbit_int1 i.rodent_int1 i.exotic_int1 i.bird_int1 ///
i.livestock_int1 i.rhinitis_p_reg i.asthma_p_reg i.asthma_m_reg i.rhinitis_m_reg ///
i.hhincome_cat i.crowding_cat i.children_cat  ///
agebirth_m_y i.preg_smk  if miss==0,  strata(sex copenhagen)  
est store a
quietly xi: stcox i.cat_int1*i.mat_ed_3cat i.dog_int1 i.rabbit_int1 i.rodent_int1 i.exotic_int1 i.bird_int1 ///
i.livestock_int1 i.rhinitis_p_reg i.asthma_p_reg i.asthma_m_reg i.rhinitis_m_reg ///
i.hhincome_cat i.crowding_cat i.children_cat  ///
agebirth_m_y i.preg_smk  if miss==0,  strata(sex copenhagen) 
est store b
lrtest a b
} 
else if "`var'"=="dog_int1" {
display "`var'"
char mat_ed_3cat[omit] 2
char crowding_cat[omit] 2
quietly xi: stcox i.cat_int1 i.dog_int1 i.mat_ed_3cat i.rabbit_int1 i.rodent_int1 i.exotic_int1 i.bird_int1 ///
i.livestock_int1 i.rhinitis_p_reg i.asthma_p_reg i.asthma_m_reg i.rhinitis_m_reg ///
i.hhincome_cat i.crowding_cat i.children_cat  ///
agebirth_m_y i.preg_smk  if miss==0,  strata(sex copenhagen)  
est store a
quietly xi: stcox i.cat_int1 i.dog_int1*i.mat_ed_3cat i.rabbit_int1 i.rodent_int1 i.exotic_int1 i.bird_int1 ///
i.livestock_int1 i.rhinitis_p_reg i.asthma_p_reg i.asthma_m_reg i.rhinitis_m_reg ///
i.hhincome_cat i.crowding_cat i.children_cat  ///
agebirth_m_y i.preg_smk  if miss==0,  strata(sex copenhagen)  
est store b
lrtest a b
}
else if "`var'"=="rabbit_int1" {
display "`var'"
char mat_ed_3cat[omit] 2
char crowding_cat[omit] 2
quietly  xi: stcox i.cat_int1 i.dog_int1 i.rabbit_int1 i.mat_ed_3cat i.rodent_int1 i.exotic_int1 i.bird_int1 ///
i.livestock_int1 i.rhinitis_p_reg i.asthma_p_reg i.asthma_m_reg i.rhinitis_m_reg ///
i.hhincome_cat i.crowding_cat i.children_cat  ///
agebirth_m_y i.preg_smk  if miss==0,  strata(sex copenhagen) 
est store a
quietly  xi: stcox i.cat_int1 i.dog_int1 i.rabbit_int1*i.mat_ed_3cat i.rodent_int1 i.exotic_int1 i.bird_int1 ///
i.livestock_int1 i.rhinitis_p_reg i.asthma_p_reg i.asthma_m_reg i.rhinitis_m_reg ///
i.hhincome_cat i.crowding_cat i.children_cat  ///
agebirth_m_y i.preg_smk  if miss==0,  strata(sex copenhagen) 
est store b
lrtest a b
}
if "`var'"=="rodent_int1" {
display "`var'"
char mat_ed_3cat[omit] 2
char crowding_cat[omit] 2
quietly xi: stcox i.cat_int1 i.dog_int1 i.rabbit_int1 i.rodent_int1 i.mat_ed_3cat i.exotic_int1 i.bird_int1 ///
i.livestock_int1 i.rhinitis_p_reg i.asthma_p_reg i.asthma_m_reg i.rhinitis_m_reg ///
i.hhincome_cat i.crowding_cat i.children_cat  ///
agebirth_m_y i.preg_smk  if miss==0,  strata(sex copenhagen)  
est store a
quietly xi: stcox i.cat_int1 i.dog_int1 i.rabbit_int1 i.rodent_int1*i.mat_ed_3cat i.exotic_int1 i.bird_int1 ///
i.livestock_int1 i.rhinitis_p_reg i.asthma_p_reg i.asthma_m_reg i.rhinitis_m_reg ///
i.hhincome_cat i.crowding_cat i.children_cat  ///
agebirth_m_y i.preg_smk  if miss==0,  strata(sex copenhagen)  
est store b
lrtest a b
}
if "`var'"=="bird_int1" {
display "`var'"
char mat_ed_3cat[omit] 2
char crowding_cat[omit] 2
quietly xi: stcox i.cat_int1 i.dog_int1 i.rabbit_int1 i.rodent_int1 i.exotic_int1 i.bird_int1 i.mat_ed_3cat ///
i.livestock_int1 i.rhinitis_p_reg i.asthma_p_reg i.asthma_m_reg i.rhinitis_m_reg ///
i.hhincome_cat i.crowding_cat i.children_cat  ///
agebirth_m_y i.preg_smk  if miss==0,  strata(sex copenhagen)  
est store a 
quietly xi: stcox i.cat_int1 i.dog_int1 i.rabbit_int1 i.rodent_int1 i.exotic_int1 i.bird_int1*i.mat_ed_3cat ///
i.livestock_int1 i.rhinitis_p_reg i.asthma_p_reg i.asthma_m_reg i.rhinitis_m_reg ///
i.hhincome_cat i.crowding_cat i.children_cat  ///
agebirth_m_y i.preg_smk  if miss==0,  strata(sex copenhagen) 
est store b
lrtest a b
}
if "`var'"=="livestock_int1" {
display "`var'"
char mat_ed_3cat[omit] 2
char crowding_cat[omit] 2
quietly xi: stcox i.cat_int1 i.dog_int1 i.rabbit_int1 i.rodent_int1 i.exotic_int1 i.bird_int1 ///
i.livestock_int1 i.mat_ed_3cat i.rhinitis_p_reg i.asthma_p_reg i.asthma_m_reg i.rhinitis_m_reg ///
i.hhincome_cat i.crowding_cat i.children_cat  ///
agebirth_m_y i.preg_smk  if miss==0,  strata(sex copenhagen)  
est store a
quietly xi: stcox i.cat_int1 i.dog_int1 i.rabbit_int1 i.rodent_int1 i.exotic_int1 i.bird_int1 ///
i.livestock_int1*i.mat_ed_3cat i.rhinitis_p_reg i.asthma_p_reg i.asthma_m_reg i.rhinitis_m_reg ///
i.hhincome_cat i.crowding_cat i.children_cat  ///
agebirth_m_y i.preg_smk  if miss==0,  strata(sex copenhagen) 
est store b
lrtest a b
}
}


////////////////////////////////////////////////////////////////////////////////

*********************************esttab results*********************************

/////Tabulate results/////

*Overall and by family history:

esttab    cat_int1 dog_int1 rabbit_int1 rodent_int1 bird_int1 livestock_int1 ///
adj_cat_int1 adj_dog_int1 adj_rabbit_int1 adj_rodent_int1 adj_bird_int1 adj_livestock_int1 ///
cat_int1_paa_a cat_int1_paa2_a  ///
dog_int1_paa_a dog_int1_paa2_a  ///
rabbit_int1_paa_a rabbit_int1_paa2_a  ///
rodent_int1_paa_a rodent_int1_paa2_a  ///
bird_int1_paa_a bird_int1_paa2_a  ///
livestock_int1_paa_a livestock_int1_paa2_a   ///
using asthma_models_0722_final, /// 
wide eform b(%12.2fc) ci(%12.2fc) one tab /// 
mtitles ("Minimally cat HR (95% CI)" ///
"Minimally dog HR (95% CI)" ///
"Minimally rabbit HR (95% CI)" ///
"Minimally rodent HR (95% CI)" ///
"Minimally bird HR (95% CI)" ///
"Minimally livestock HR (95% CI)" ///
"Adjusted cat HR (95% CI)" ///
"Adjusted dog HR (95% CI)" ///
"Adjusted rabbit HR (95% CI)" ///
"Adjusted rodent HR (95% CI)" ///
"Adjusted bird HR (95% CI)" ///
"Adjusted livestock HR (95% CI)" ///
"Adjusted cat HR (95% CI) - no family history" ///
"Adjusted cat HR (95% CI) - family history" ///
"Adjusted dog HR (95% CI)  - no family history" ///
"Adjusted dog HR (95% CI) - family history" ///
"Adjusted rabbit HR (95% CI) - no family history" ///
"Adjusted rabbit HR (95% CI) - family history" ///
"Adjusted rodent HR (95% CI) - no family history" ///
"Adjusted rodent HR (95% CI) - family history" ///
"Adjusted bird HR (95% CI) - no family history" ///
"Adjusted bird HR (95% CI) - family history" ///
"Adjusted livestock HR (95% CI) - no family history" ///
"Adjusted livestock HR (95% CI) - family history" ///
) noisily replace



*Source and timing of exposure
esttab  pc pd pra pro pb fl adj_pc adj_pd adj_pra adj_pro adj_pb adj_fl /// 
cat_time dog_time rabbit_time rodent_time bird_time ///
adj_cat_timing adj_dog_timing adj_rabbit_timing adj_rodent_timing ///
adj_bird_timing ///
  using asthma_source_timing_0722, ///
wide eform b(%12.2fc) ci(%12.2fc) one tab ///
mtitles ("Unadjusted pet cat HR (95% CI)" ///
"Unadjusted pet dog HR (95% CI)" ///
"Unadjusted pet rabbit HR (95% CI)" ///
"Unadjusted pet rodent HR (95% CI)" ///
"Unadjusted pet bird HR (95% CI)" ///
"Unadjusted farm animals HR (95% CI)" ///
"Adjusted CAT source HR (95% CI)" ///
"Adjusted DOG source HR (95% CI)" ///
"Adjusted RABBIT source HR (95% CI)" ///
"Adjusted RODENT source HR (95% CI)" ///
"Adjusted BIRD source HR (95% CI)" ///
"Adjusted LIVESTOCK source HR (95% CI)" ///
"Unadjusted cat timing HR (95% CI)" ///
"Unadjusted dog timing HR (95% CI)" ///
"Unadjusted rabbit timing HR (95% CI)" ///
"Unadjusted rodent timing HR (95% CI)" ///
"Unadjusted bird timing HR (95% CI)" ///
"Adjusted CAT timing HR (95% CI)" ///
"Adjusted DOG timing HR (95% CI)" ///
"Adjusted RABBIT timing HR (95% CI)" ///
"Adjusted RODENT timing HR (95% CI)" ///
"Adjusted BIRD timing HR (95% CI)" ///
) noisily replace

     ///

*Stratified results
esttab a_mat_ed_cat_int1_1 a_mat_ed_dog_int1_1 a_mat_ed_rabbit_int1_1 ///
a_mat_ed_rodent_int1_1 a_mat_ed_bird_int1_1 a_mat_ed_livestock_int1_1 ///
a_mat_ed_cat_int1_2 a_mat_ed_dog_int1_2 a_mat_ed_rabbit_int1_2 ///
a_mat_ed_rodent_int1_2 a_mat_ed_bird_int1_2 a_mat_ed_livestock_int1_2 ///
a_mat_ed_cat_int1_3 a_mat_ed_dog_int1_3 a_mat_ed_rabbit_int1_3 ///
a_mat_ed_rodent_int1_3 a_mat_ed_bird_int1_3 a_mat_ed_livestock_int1_3 ///
adj_cat_int1_1 adj_dog_int1_1 adj_rabbit_int1_1 adj_rodent_int1_1 ///
adj_bird_int1_1 adj_livestock_int1_1 ///
adj_cat_int1_2 adj_dog_int1_2 adj_rabbit_int1_2 adj_rodent_int1_2 /// 
adj_bird_int1_2 adj_livestock_int1_2 ///
using asthma_stratified_0722, /// 
wide eform b(%12.2fc) ci(%12.2fc) one tab /// 
mtitles ("Adjusted CAT HR (95% CI) - low maternal ed" ///
"Adjusted DOG HR (95% CI) - low maternal ed" ///
"Adjusted RABBIT HR (95% CI) - low maternal ed" ///
"Adjusted RODENT HR (95% CI) - low maternal ed" ///
"Adjusted BIRD HR (95% CI) - low maternal ed" ///
"Adjusted LIVESTOCK HR (95% CI) - low maternal ed" ///
"Adjusted CAT HR (95% CI) - medium maternal ed" ///
"Adjusted DOG HR (95% CI) - medium maternal ed" ///
"Adjusted RABBIT HR (95% CI) - medium maternal ed" ///
"Adjusted RODENT HR (95% CI) - medium maternal ed" ///
"Adjusted BIRD HR (95% CI) - medium maternal ed" ///
"Adjusted LIVESTOCK HR (95% CI) - medium maternal ed" ///
"Adjusted CAT HR (95% CI) - high maternal ed" ///
"Adjusted DOG HR (95% CI) - high maternal ed" ///
"Adjusted RABBIT HR (95% CI) - high maternal ed" ///
"Adjusted RODENT HR (95% CI) - high maternal ed" ///
"Adjusted BIRD HR (95% CI) - high maternal ed" ///
"Adjusted LIVESTOCK HR (95% CI) - high maternal ed" ///
"Adjusted CAT HR (95% CI) - males" ///
"Adjusted DOG HR (95% CI) - males" ///
"Adjusted RABBIT HR (95% CI) - males" ///
"Adjusted RODENT HR (95% CI) - males" ///
"Adjusted BIRD HR (95% CI) - males" ///
"Adjusted LIVESTOCK HR (95% CI) - males" ///
"Adjusted CAT HR (95% CI)  - females" ///
"Adjusted DOG HR (95% CI)  - females" ///
"Adjusted RABBIT HR (95% CI)  - females" ///
"Adjusted RODENT HR (95% CI)  - females" ///
"Adjusted BIRD HR (95% CI)  - females" ///
"Adjusted LIVESTOCK HR (95% CI)  - females" ///
) noisily replace



*Table of cases

gen cat_source= pc 
gen dog_source= pd 
gen rabbit_source= pra 
gen rodent_source= pro 
gen exotic_source= pe 
gen bird_source=  pb 
gen livestock_source= fl 



tabout cat_int1 dog_int1 rabbit_int1 rodent_int1 exotic_int1 bird_int1 livestock_int1 ///
cat_source dog_source rabbit_source rodent_source exotic_source bird_source livestock_source ///
asthma_cox using table_asthma_0722.txt if miss==0, replace /// 
c(freq col) f(0c 1) clab(N %) 

tabout cat_int1 dog_int1 rabbit_int1 rodent_int1 exotic_int1 bird_int1 livestock_int1 ///
asthma_cox using table_asthma_0722.txt if miss==0 & family_allergy_asthma==0, append ///
c(freq col) f(0c 1) clab(N %) 

tabout cat_int1 dog_int1 rabbit_int1 rodent_int1 exotic_int1 bird_int1 livestock_int1 ///
asthma_cox using table_asthma_0722.txt if miss==0 & family_allergy_asthma==1, append ///
c(freq col) f(0c 1) clab(N %) 

tabout cat_int1 dog_int1 rabbit_int1 rodent_int1 exotic_int1 bird_int1 livestock_int1 ///
asthma_cox using table_asthma_0722.txt if miss==0 & sex==1, append ///
c(freq col) f(0c 1) clab(N %) 

tabout cat_int1 dog_int1 rabbit_int1 rodent_int1 exotic_int1 bird_int1 livestock_int1 ///
asthma_cox using table_asthma_0722.txt if miss==0 & sex==2, append ///
c(freq col) f(0c 1) clab(N %) 

tabout cat_int1 dog_int1 rabbit_int1 rodent_int1 exotic_int1 bird_int1 livestock_int1 ///
asthma_cox using table_asthma_0722.txt if miss==0 & mat_ed_3cat==1, append ///
c(freq col) f(0c 1) clab(N %) 

tabout cat_int1 dog_int1 rabbit_int1 rodent_int1 exotic_int1 bird_int1 livestock_int1 ///
asthma_cox using table_asthma_0722.txt if miss==0 & mat_ed_3cat==2, append ///
c(freq col) f(0c 1) clab(N %) 

tabout cat_int1 dog_int1 rabbit_int1 rodent_int1 exotic_int1 bird_int1 livestock_int1 ///
asthma_cox using table_asthma_0722.txt if miss==0 & mat_ed_3cat==3, append ///
c(freq col) f(0c 1) clab(N %) 

tabout cat dog rabbit rodent exotic bird ///
asthma_cox using table_asthma_timing_0722.txt if miss2==0, replace ///
c(freq col) f(0c 1) clab(N %)
