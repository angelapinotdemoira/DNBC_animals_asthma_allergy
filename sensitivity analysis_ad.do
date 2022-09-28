*Atopic dermatitis sensitivity analysis
*Angela Pinot de Moira
*6 December 2021
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
*Select study population:
egen miss = rowmiss(cat_int1 dog_int1 other_furry_int1 bird_int1 ///
livestock_int1 allergy_f asthma_bf asthma_m allergy_inh_m ///
mat_ed_3cat hhincome_cat crowding_cat children_cat ///
agebirth_m_y preg_smk copenhagen ad)

drop if miss!=0

*For cox regression:
*Create an indicator to identify children without missing data:
keep if AD!=. 
drop if migration_m==1 //n=166 excludes mothers who emigrated before birth
drop if inlist(migration,1,2) //n=91 excludes children who emigrated before birth or who immigrated after birth

*drop multiples:
keep if flerfold==1

/*
*identify registry cases occurring after 4th interview:
format AD_date %d

gen AD_cox = AD
replace AD_cox =0 if AD_date>i4_dato & AD_date!=.

*remove children who emigrated or died before 4th interview:
egen out = rowmin(doddato migration_date)
format out %d
drop if out<i4_dato & i4_dato!=.
*/


*identify registry cases occurring after 13th birthday:
*create date of 13th birthday:
gen day = day(eventda)
replace day=28 if day(eventda)==29 & month(eventda)==2
gen month = month(eventda)
gen year = (year(eventda)) + 13
gen bday_13 = mdy(month,day,year)
format bday_13 %d

gen AD_cox = AD
replace AD_cox =0 if AD_date>bday_13 & AD_date!=.

*remove children who emigrated or died before 13th birthday:
egen out = rowmin(doddato migration_date)
format out %d
drop if out<bday_13 & bday_13!=.

********************************************************************************
*DNBC model:

*Unadjusted
foreach var of varlist cat_int1 dog_int1 rabbit_int1 rodent_int1 ///
exotic_int1 bird_int1 livestock_int1 {
xi: logistic i.ad i.`var' if miss==0, vce(cluster mcpr)
est store `var'
}


*Adjusted

xi: logistic i.ad i.cat_int1 i.dog_int1 i.rabbit_int1 i.rodent_int1 ///
i.exotic_int1 i.bird_int1 ///
i.livestock_int1 allergy_f asthma_bf asthma_m allergy_inh_m ///
i.mat_ed_3cat i.hhincome_cat i.crowding_cat i.children_cat  ///
agebirth_m_y i.preg_smk i.copenhagen i.sex if miss==0, vce(cluster mcpr)
est store adj


*Registry:

*Unadjusted
foreach var of varlist cat_int1 dog_int1 rabbit_int1 rodent_int1 ///
exotic_int1 bird_int1 livestock_int1 {
xi: logistic i.AD_cox i.`var' if miss==0, vce(cluster mcpr)
est store `var'_reg
}


*Adjusted

xi: logistic i.AD_cox i.cat_int1 i.dog_int1 i.rabbit_int1 i.rodent_int1 ///
i.exotic_int1 i.bird_int1 ///
i.livestock_int1 allergy_f asthma_bf asthma_m allergy_inh_m ///
i.mat_ed_3cat i.hhincome_cat i.crowding_cat i.children_cat  ///
agebirth_m_y i.preg_smk i.copenhagen i.sex if miss==0, vce(cluster mcpr)
est store adj_reg



******************************************************************************
/////Tabulate results/////

*Esttab

esttab    cat_int1 cat_int1_reg dog_int1 dog_int1_reg ///
rabbit_int1 rabbit_int1_reg ///
rodent_int1 rodent_int1_reg ///
exotic_int1 exotic_int1_reg ///
 bird_int1 bird_int1_reg ///
livestock_int1 livestock_int1_reg ///
adj adj_reg ///
using sensitivity_analysis_AD, /// 
wide eform b(2) ci(2) one tab /// 
mtitles ("Unadjusted cat HR (95% CI)_dnbc" ///
"Unadjusted cat HR (95% CI)_reg" ///
"Unadjusted dog HR (95% CI)_dnbc" ///
"Unadjusted dog HR (95% CI)_reg" ///
"Unadjusted rabbit HR (95% CI)_dnbc" ///
"Unadjusted rabbit HR (95% CI)_reg" ///
"Unadjusted rodent HR (95% CI)_dnbc" ///
"Unadjusted rodent HR (95% CI)_reg" ///
"Unadjusted exotic HR (95% CI)_dnbc" ///
"Unadjusted exotic HR (95% CI)_reg" ///
"Unadjusted bird HR (95% CI)_dnbc" ///
"Unadjusted bird HR (95% CI)_reg" ///
"Unadjusted livestock HR (95% CI)_dnbc" ///
"Unadjusted livestock HR (95% CI)_reg" ///
"Adjusted HR (95% CI)_dnbc" ///
"Adjusted HR (95% CI)_reg" ///
) noisily replace
