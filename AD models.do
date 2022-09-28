*Atopic dermatitis analysis
*Angela Pinot de Moira
*18 Feb 2021
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

keep if AD!=. 
drop if migration_m==1 //n=166 excludes mothers who emigrated before birth
drop if inlist(migration,1,2) //n=91 excludes children who emigrated before birth or who immigrated after birth
drop if doddato==eventda // exclude children who died on their birthday

*create date of 13th birthday:
gen day = day(eventda)
replace day=28 if day(eventda)==29 & month(eventda)==2
gen month = month(eventda)
gen year = (year(eventda)) + 13
gen bday_13 = mdy(month,day,year)
format bday_13 %d

*

egen outdate = rowmin(AD_date doddato migration_date bday_13)
format outdate %d
format AD_date %d

gen AD_cox = AD
replace AD_cox =0 if AD_date>outdate & AD_date!=.

stset outdate, failure(AD_cox==1) origin(eventda) enter(eventda) ///
scale(365.25) id(lbgravff) exit(time eventda + 365.25*13)

*drop multiples:
keep if flerfold==1

********************************************************************************
///Use reported parental history of allergy:
drop rhinitis_p_reg ///
asthma_p_reg asthma_m_reg rhinitis_m_reg
egen family_allergy_asthma = rowmax(asthma_bf asthma_m allergy_f allergy_inh_m)
recode family_allergy_asthma 0=1 1=0, gen(family_allergy_asthma2)
gen rhinitis_p_reg = allergy_f
gen asthma_p_reg = asthma_bf
gen asthma_m_reg = asthma_m
gen rhinitis_m_reg = allergy_inh_m
//

********************************************************************************
*Create a variable to indicate missing values (to identify study population):
egen miss = rowmiss(cat_int1 dog_int1 rabbit_int1 rodent_int1 exotic_int1 bird_int1 ///
livestock_int1 rhinitis_p_reg asthma_p_reg asthma_m_reg rhinitis_m_reg ///
mat_ed_3cat hhincome_cat crowding_cat children_cat  ///
agebirth_m_y preg_smk copenhagen)

recode miss 0=0 1/max=1

*Check missingness:
summ AD_cox cat_int1 dog_int1 rabbit_int1 rodent_int1 exotic_int1 bird_int1 ///
livestock_int1 rhinitis_p_reg asthma_p_reg asthma_m_reg rhinitis_m_reg ///
mat_ed_3cat hhincome_cat crowding_cat children_cat parity_m ///
agebirth_m_y preg_smk copenhagen nursery antibiotics miss

*******************************************************************************
*log on:
log using "D:\Data\workdata\707796\Results\Collated results\Rabbits rodents\AR_13years\FINAL\AD_log_IJE.smcl"


********************************************************************************
*Univariate analysis - to check departure from linearity assumption

/*
foreach var of varlist cat_int1 dog_int1 rabbit_int1 rodent_int1 exotic_int1 bird_int1 livestock_int1 ///
dog_source - bird_source cat dog other_furry {
sts graph, by(`var') ylabel(minmax)
stcox `var', nolog noshow schoenfeld(sch*) scaledsch(sca*)
stphtest, log detail
stphtest, log plot(`var') yline(0)
drop sch1 sca1
}
*/
********************************************************************************
*TABLE 2 - overall association


*Minimally adjusted:------------------------------------------------------------
foreach var of varlist cat_int1 dog_int1 rabbit_int1 rodent_int1 exotic_int1 ///
bird_int1 livestock_int1 {
xi: stcox i.`var' if miss==0, strata(sex) vce(cluster mcpr)
est store `var'
}


*Adjusted:----------------------------------------------------------------------


cd "D:\Data\workdata\707796\Results" 

foreach var of varlist cat_int1 dog_int1 rabbit_int1 rodent_int1 bird_int1 ///
livestock_int1 {
display "`var'"
char crowding_cat[omit] 2
xi: stcox i.cat_int1 i.dog_int1 i.rabbit_int1 i.rodent_int1 i.exotic_int1 i.bird_int1 ///
i.livestock_int1 i.rhinitis_p_reg i.asthma_p_reg i.asthma_m_reg ///
 i.hhincome_cat i.crowding_cat i.children_cat  ///
agebirth_m_y i.copenhagen if miss==0, strata(sex preg_smk i.rhinitis_m_reg ///
i.mat_ed_3cat) ///
nolog noshow schoenfeld(sch*) mgale(mg) scaledsch(sca*) vce(cluster mcpr)
est store adj_`var'
predict cs, csnell
stphtest, log detail
drop sch* sca* mg cs
}
 
********************************************************************************
*TABLE 3 

*Model 2 - source of animal exposure
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
*Adjusted 1:
xi: stcox i.pc i.pd i.pra i.pro i.pe i.pb i.fl ///
 i.asthma_bf i.asthma_m   ///
i.mat_ed_3cat i.hhincome_cat i.crowding_cat  ///
 agebirth_m_y i.copenhagen if miss==0,  ///
 strata(allergy_f allergy_inh_m preg_smk sex children_cat) nolog noshow schoenfeld(sch*) scaledsch(sca*) vce(cluster mcpr)
est store adj_`var'
predict cs, csnell
stphtest, log detail
drop sch* sca* cs 
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
char crowding_cat[omit] 2
xi: stcox i.cat_int1*`v' i.dog_int1 i.rabbit_int1 i.rodent_int1 i.exotic_int1 i.bird_int1 ///
i.livestock_int1  ///
 i.hhincome_cat i.crowding_cat i.children_cat  ///
agebirth_m_y i.copenhagen if miss==0, strata(sex preg_smk  ///
i.mat_ed_3cat) ///
nolog noshow schoenfeld(sch*) scaledsch(sca*) vce(cluster mcpr)
est store `var'_`v'_a
stphtest, log detail
drop sch* sca*
} 
else if "`var'"=="dog_int1" {
display "`var'"
char crowding_cat[omit] 2
xi: stcox i.cat_int1 i.dog_int1*`v' i.rabbit_int1 i.rodent_int1 i.exotic_int1 i.bird_int1 ///
i.livestock_int1  ///
 i.hhincome_cat i.crowding_cat i.children_cat  ///
agebirth_m_y i.copenhagen if miss==0, strata(sex preg_smk  ///
i.mat_ed_3cat) nolog noshow schoenfeld(sch*)  scaledsch(sca*) vce(cluster mcpr)
est store `var'_`v'_a
stphtest, log detail
drop sch* sca*
}
else if "`var'"=="rabbit_int1" {
display "`var'"
char crowding_cat[omit] 2
xi: stcox i.cat_int1 i.dog_int1 i.rabbit_int1*`v' i.rodent_int1 i.exotic_int1 i.bird_int1 ///
i.livestock_int1  ///
 i.hhincome_cat i.crowding_cat i.children_cat  ///
agebirth_m_y i.copenhagen if miss==0, strata(sex preg_smk  ///
i.mat_ed_3cat) nolog noshow schoenfeld(sch*) scaledsch(sca*) vce(cluster mcpr)
est store `var'_`v'_a
stphtest, log detail
drop sch* sca*
}
if "`var'"=="rodent_int1" {
display "`var'"
char crowding_cat[omit] 2
xi: stcox i.cat_int1 i.dog_int1 i.rabbit_int1 i.rodent_int1*`v' i.exotic_int1 i.bird_int1 ///
i.livestock_int1  ///
 i.hhincome_cat i.crowding_cat i.children_cat  ///
agebirth_m_y i.copenhagen if miss==0, strata(sex preg_smk  ///
i.mat_ed_3cat) nolog noshow schoenfeld(sch*) scaledsch(sca*) vce(cluster mcpr)
est store `var'_`v'_a
stphtest, log detail
drop sch* sca*
}
if "`var'"=="bird_int1" {
display "`var'"
char crowding_cat[omit] 2
xi: stcox i.cat_int1 i.dog_int1 i.rabbit_int1 i.rodent_int1 i.exotic_int1 i.bird_int1*`v' ///
i.livestock_int1  ///
 i.hhincome_cat i.crowding_cat i.children_cat  ///
agebirth_m_y i.copenhagen if miss==0, strata(sex preg_smk  ///
i.mat_ed_3cat) nolog noshow schoenfeld(sch*) scaledsch(sca*) vce(cluster mcpr)
est store `var'_`v'_a
stphtest, log detail
drop sch* sca*
}
if "`var'"=="livestock_int1" {
display "`var'"
char crowding_cat[omit] 2
xi: stcox i.cat_int1 i.dog_int1 i.rabbit_int1 i.rodent_int1 i.exotic_int1 i.bird_int1 ///
i.livestock_int1*`v'  ///
 i.hhincome_cat i.crowding_cat i.children_cat  ///
agebirth_m_y i.copenhagen if miss==0, strata(sex preg_smk  ///
i.mat_ed_3cat) nolog noshow schoenfeld(sch*) scaledsch(sca*) vce(cluster mcpr)
est store `var'_`v'_a
stphtest, log detail
drop sch* sca*
}
}
}

********************************************************************************
*Table S2

*Stratified by sex


foreach var of varlist cat_int1 dog_int1 rabbit_int1 rodent_int1 bird_int1 ///
livestock_int1 {
foreach n of numlist  1 2   {
display "`var'"
if `n'==1 {
*Male
char crowding_cat[omit] 2
xi: stcox  i.cat_int1 i.dog_int1 i.rabbit_int1 i.rodent_int1 i.exotic_int1 i.bird_int1 ///
i.livestock_int1  ///
i.rhinitis_p_reg i.asthma_p_reg   ///
  i.crowding_cat i.children_cat   preg_smk  ///
 agebirth_m_y  i.hhincome_cat  if miss==0 & sex==1, strata(i.rhinitis_m_reg ///
 i.mat_ed_3cat i.asthma_m_reg   ) nolog noshow schoenfeld(sch*) scaledsch(sca*) vce(cluster mcpr)
est store adj_`var'_`n'
stphtest, log detail
drop sch* sca*
}
else if `n'==2 {
*Female
char crowding_cat[omit] 2
xi: stcox  i.cat_int1 i.dog_int1 i.rabbit_int1 i.rodent_int1 i.exotic_int1 i.bird_int1 ///
i.livestock_int1  ///
i.rhinitis_p_reg  i.asthma_m_reg   ///
 i.hhincome_cat  i.crowding_cat i.children_cat  ///
 i.rhinitis_m_reg i.mat_ed_3cat ///
 agebirth_m_y  if miss==0 & sex==2, strata(i.asthma_p_reg i.preg_smk) nolog noshow schoenfeld(sch*) scaledsch(sca*) vce(cluster mcpr)
est store adj_`var'_`n'
stphtest, log detail
drop sch* sca*
} 
}
}

*Check interaction:
foreach var of varlist cat_int1 dog_int1 rabbit_int1 rodent_int1 bird_int1 ///
livestock_int1 {
if "`var'"=="cat_int1" {
display "`var'"
char crowding_cat[omit] 2
xi: stcox i.cat_int1*i.sex i.dog_int1 i.rabbit_int1 i.rodent_int1 i.exotic_int1 i.bird_int1 ///
i.livestock_int1 i.rhinitis_p_reg i.asthma_p_reg i.asthma_m_reg ///
 i.hhincome_cat i.crowding_cat i.children_cat  ///
agebirth_m_y i.copenhagen if miss==0, strata(preg_smk i.rhinitis_m_reg ///
i.mat_ed_3cat) nolog noshow schoenfeld(sch*) mgale(mg) scaledsch(sca*) vce(cluster mcpr)
predict cs, csnell
stphtest, log detail
drop sch* sca* mg cs
} 
else if "`var'"=="dog_int1" {
display "`var'"
char crowding_cat[omit] 2
xi: stcox i.cat_int1 i.dog_int1*i.sex i.rabbit_int1 i.rodent_int1 i.exotic_int1 i.bird_int1 ///
i.livestock_int1 i.rhinitis_p_reg i.asthma_p_reg i.asthma_m_reg ///
 i.hhincome_cat i.crowding_cat i.children_cat  ///
agebirth_m_y i.copenhagen if miss==0, strata(preg_smk i.rhinitis_m_reg ///
i.mat_ed_3cat) nolog noshow schoenfeld(sch*) mgale(mg) scaledsch(sca*) vce(cluster mcpr)
predict cs, csnell
stphtest, log detail
drop sch* sca* mg cs
}
else if "`var'"=="rabbit_int1" {
display "`var'"
char crowding_cat[omit] 2
xi: stcox i.cat_int1 i.dog_int1 i.rabbit_int1*i.sex i.rodent_int1 i.exotic_int1 i.bird_int1 ///
i.livestock_int1 i.rhinitis_p_reg i.asthma_p_reg i.asthma_m_reg ///
 i.hhincome_cat i.crowding_cat i.children_cat  ///
agebirth_m_y i.copenhagen if miss==0, strata(preg_smk i.rhinitis_m_reg ///
i.mat_ed_3cat) nolog noshow schoenfeld(sch*) mgale(mg) scaledsch(sca*) vce(cluster mcpr)
predict cs, csnell
stphtest, log detail
drop sch* sca* mg cs
}
if "`var'"=="rodent_int1" {
display "`var'"
char crowding_cat[omit] 2
xi: stcox i.cat_int1 i.dog_int1 i.rabbit_int1 i.rodent_int1*i.sex i.exotic_int1 i.bird_int1 ///
i.livestock_int1 i.rhinitis_p_reg i.asthma_p_reg i.asthma_m_reg ///
 i.hhincome_cat i.crowding_cat i.children_cat ///
agebirth_m_y i.copenhagen if miss==0, strata(preg_smk i.rhinitis_m_reg ///
i.mat_ed_3cat) nolog noshow schoenfeld(sch*) mgale(mg) scaledsch(sca*) vce(cluster mcpr)
predict cs, csnell
stphtest, log detail
drop sch* sca* mg cs
}
if "`var'"=="bird_int1" {
display "`var'"
char crowding_cat[omit] 2
xi: stcox i.cat_int1 i.dog_int1 i.rabbit_int1 i.rodent_int1 i.exotic_int1 i.bird_int1*i.sex ///
i.livestock_int1 i.rhinitis_p_reg i.asthma_p_reg i.asthma_m_reg ///
 i.hhincome_cat i.crowding_cat i.children_cat  ///
agebirth_m_y i.copenhagen if miss==0, strata(preg_smk i.rhinitis_m_reg ///
i.mat_ed_3cat) nolog noshow schoenfeld(sch*) mgale(mg) scaledsch(sca*) vce(cluster mcpr)
predict cs, csnell
stphtest, log detail
drop sch* sca* mg cs
}
if "`var'"=="livestock_int1" {
display "`var'"
char crowding_cat[omit] 2
xi: stcox i.cat_int1 i.dog_int1 i.rabbit_int1 i.rodent_int1 i.exotic_int1 i.bird_int1 ///
i.livestock_int1*i.sex i.rhinitis_p_reg i.asthma_p_reg i.asthma_m_reg ///
 i.hhincome_cat i.crowding_cat i.children_cat ///
agebirth_m_y i.copenhagen if miss==0, strata(preg_smk i.rhinitis_m_reg ///
i.mat_ed_3cat) nolog noshow schoenfeld(sch*) mgale(mg) scaledsch(sca*) vce(cluster mcpr)
predict cs, csnell
stphtest, log detail
drop sch* sca* mg cs
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
i.livestock_int1 i.rhinitis_p_reg i.asthma_p_reg i.asthma_m_reg ///
 i.hhincome_cat i.crowding_cat i.children_cat ///
agebirth_m_y i.copenhagen if miss==0 & mat_ed_3cat==`n', strata(sex preg_smk i.rhinitis_m_reg ///
) nolog noshow schoenfeld(sch*) mgale(mg) scaledsch(sca*) vce(cluster mcpr)
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
char crowding_cat[omit] 2
quietly xi: stcox i.cat_int1 i.mat_ed_3cat i.dog_int1 i.rabbit_int1 i.rodent_int1 i.exotic_int1 i.bird_int1 ///
i.livestock_int1 i.rhinitis_p_reg i.asthma_p_reg i.asthma_m_reg ///
 i.hhincome_cat i.crowding_cat i.children_cat ///
agebirth_m_y i.copenhagen if miss==0, strata(sex preg_smk i.rhinitis_m_reg ///
) 
est store a
quietly  xi: stcox i.cat_int1*i.mat_ed_3cat i.dog_int1 i.rabbit_int1 i.rodent_int1 i.exotic_int1 i.bird_int1 ///
i.livestock_int1 i.rhinitis_p_reg i.asthma_p_reg i.asthma_m_reg ///
 i.hhincome_cat i.crowding_cat i.children_cat  ///
agebirth_m_y i.copenhagen if miss==0, strata(sex preg_smk i.rhinitis_m_reg ///
)  
est store b
lrtest a b
} 
else if "`var'"=="dog_int1" {
display "`var'"
char crowding_cat[omit] 2
quietly  xi: stcox i.cat_int1 i.dog_int1 i.mat_ed_3cat i.rabbit_int1 i.rodent_int1 i.exotic_int1 i.bird_int1 ///
i.livestock_int1 i.rhinitis_p_reg i.asthma_p_reg i.asthma_m_reg ///
 i.hhincome_cat i.crowding_cat i.children_cat ///
agebirth_m_y i.copenhagen if miss==0, strata(sex preg_smk i.rhinitis_m_reg ///
) 
est store a
quietly  xi: stcox i.cat_int1 i.dog_int1*i.mat_ed_3cat i.rabbit_int1 i.rodent_int1 i.exotic_int1 i.bird_int1 ///
i.livestock_int1 i.rhinitis_p_reg i.asthma_p_reg i.asthma_m_reg ///
 i.hhincome_cat i.crowding_cat i.children_cat  ///
agebirth_m_y i.copenhagen if miss==0, strata(sex preg_smk i.rhinitis_m_reg ///
) 
est store b
lrtest a b
}
else if "`var'"=="rabbit_int1" {
display "`var'"
char crowding_cat[omit] 2
quietly  xi: stcox i.cat_int1 i.dog_int1 i.rabbit_int1 i.mat_ed_3cat i.rodent_int1 i.exotic_int1 i.bird_int1 ///
i.livestock_int1 i.rhinitis_p_reg i.asthma_p_reg i.asthma_m_reg ///
 i.hhincome_cat i.crowding_cat i.children_cat ///
agebirth_m_y i.copenhagen if miss==0, strata(sex preg_smk i.rhinitis_m_reg ///
) 
est store a
quietly xi: stcox i.cat_int1 i.dog_int1 i.rabbit_int1*i.mat_ed_3cat i.rodent_int1 i.exotic_int1 i.bird_int1 ///
i.livestock_int1 i.rhinitis_p_reg i.asthma_p_reg i.asthma_m_reg ///
 i.hhincome_cat i.crowding_cat i.children_cat  ///
agebirth_m_y i.copenhagen if miss==0, strata(sex preg_smk i.rhinitis_m_reg ///
) 
est store b
lrtest a b
}
if "`var'"=="rodent_int1" {
display "`var'"
char crowding_cat[omit] 2
quietly xi: stcox i.cat_int1 i.dog_int1 i.rabbit_int1 i.rodent_int1 i.mat_ed_3cat i.exotic_int1 i.bird_int1 ///
i.livestock_int1 i.rhinitis_p_reg i.asthma_p_reg i.asthma_m_reg ///
 i.hhincome_cat i.crowding_cat i.children_cat  ///
agebirth_m_y i.copenhagen if miss==0, strata(sex preg_smk i.rhinitis_m_reg ///
) 
est store a
quietly xi: stcox i.cat_int1 i.dog_int1 i.rabbit_int1 i.rodent_int1*i.mat_ed_3cat i.exotic_int1 i.bird_int1 ///
i.livestock_int1 i.rhinitis_p_reg i.asthma_p_reg i.asthma_m_reg ///
 i.hhincome_cat i.crowding_cat i.children_cat  ///
agebirth_m_y i.copenhagen if miss==0, strata(sex preg_smk i.rhinitis_m_reg ///
) 
est store b
lrtest a b
}
if "`var'"=="bird_int1" {
display "`var'"
char crowding_cat[omit] 2
quietly xi: stcox i.cat_int1 i.dog_int1 i.rabbit_int1 i.rodent_int1 i.exotic_int1 ///
i.bird_int1 i.mat_ed_3cat ///
i.livestock_int1 i.rhinitis_p_reg i.asthma_p_reg i.asthma_m_reg ///
 i.hhincome_cat i.crowding_cat i.children_cat  ///
agebirth_m_y i.copenhagen if miss==0, strata(sex preg_smk i.rhinitis_m_reg ///
)  
est store a
quietly xi: stcox i.cat_int1 i.dog_int1 i.rabbit_int1 i.rodent_int1 i.exotic_int1 ///
i.bird_int1*i.mat_ed_3cat ///
i.livestock_int1 i.rhinitis_p_reg i.asthma_p_reg i.asthma_m_reg ///
 i.hhincome_cat i.crowding_cat i.children_cat ///
agebirth_m_y i.copenhagen if miss==0, strata(sex preg_smk i.rhinitis_m_reg ///
) 
est store b
lrtest a b
}
if "`var'"=="livestock_int1" {
display "`var'"
char crowding_cat[omit] 2
quietly xi: stcox i.cat_int1 i.dog_int1 i.rabbit_int1 i.rodent_int1 i.exotic_int1 i.bird_int1 ///
i.livestock_int1 i.mat_ed_3cat i.rhinitis_p_reg i.asthma_p_reg i.asthma_m_reg ///
 i.hhincome_cat i.crowding_cat i.children_cat ///
agebirth_m_y i.copenhagen if miss==0, strata(sex preg_smk i.rhinitis_m_reg ///
) 
est store a
quietly xi: stcox i.cat_int1 i.dog_int1 i.rabbit_int1 i.rodent_int1 i.exotic_int1 i.bird_int1 ///
i.livestock_int1*i.mat_ed_3cat i.rhinitis_p_reg i.asthma_p_reg i.asthma_m_reg ///
 i.hhincome_cat i.crowding_cat i.children_cat ///
agebirth_m_y i.copenhagen if miss==0, strata(sex preg_smk i.rhinitis_m_reg ///
)  
est store b
lrtest a b
}
}

*******************************************************************************
********************************************************************************


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
using AD_models_0722_final, /// 
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



*Source of exposure
esttab  pc pd pra pro pb fl adj_pc adj_pd adj_pra adj_pro adj_pb adj_fl /// 
  using AD_source_0722, ///
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
using AD_stratified_0722, /// 
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


tabout cat_int1 dog_int1 rabbit_int1 rodent_int1  bird_int1 livestock_int1 ///
cat_source dog_source rabbit_source rodent_source  bird_source livestock_source ///
AD_cox using table_AD_0722.txt if miss==0, replace /// 
c(freq col) f(0c 1) clab(N %) 

tabout cat_int1 dog_int1 rabbit_int1 rodent_int1  bird_int1 livestock_int1 ///
AD_cox using table_AD_0722.txt if miss==0 & family_allergy_asthma==0, append ///
c(freq col) f(0c 1) clab(N %) 

tabout cat_int1 dog_int1 rabbit_int1 rodent_int1  bird_int1 livestock_int1 ///
AD_cox using table_AD_0722.txt if miss==0 & family_allergy_asthma==1, append ///
c(freq col) f(0c 1) clab(N %) 

tabout cat_int1 dog_int1 rabbit_int1 rodent_int1  bird_int1 livestock_int1 ///
AD_cox using table_AD_0722.txt if miss==0 & sex==1, append ///
c(freq col) f(0c 1) clab(N %) 

tabout cat_int1 dog_int1 rabbit_int1 rodent_int1  bird_int1 livestock_int1 ///
AD_cox using table_AD_0722.txt if miss==0 & sex==2, append ///
c(freq col) f(0c 1) clab(N %) 

tabout cat_int1 dog_int1 rabbit_int1 rodent_int1  bird_int1 livestock_int1 ///
AD_cox using table_AD_0722.txt if miss==0 & mat_ed_3cat==1, append ///
c(freq col) f(0c 1) clab(N %) 

tabout cat_int1 dog_int1 rabbit_int1 rodent_int1  bird_int1 livestock_int1 ///
AD_cox using table_AD_0722.txt if miss==0 & mat_ed_3cat==2, append ///
c(freq col) f(0c 1) clab(N %)

tabout cat_int1 dog_int1 rabbit_int1 rodent_int1  bird_int1 livestock_int1 ///
AD_cox using table_AD_0722.txt if miss==0 & mat_ed_3cat==3, append ///
c(freq col) f(0c 1) clab(N %) 

log off

********************************************************************************
********************************************************************************
