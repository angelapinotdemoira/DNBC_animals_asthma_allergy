*Allergic rhinitis sensitivity analysis_from age 6
*Angela Pinot de Moira
*September 2022
***************************
*Open data and create additional variables:


run "D:\Data\workdata\707796\Do files\allergic rhinitis_from age6.do" 

merge 1:m pnr using "D:\Data\workdata\707796\analysis_data.dta"
recode rhinitis6 .=0 if _merge==3 & outcome==1
drop _merge // merge is the same as merge_ad
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



cd "D:\Data\workdata\707796\Results"

********************************************************************************
**Select population:

egen miss = rowmiss(cat_int1 dog_int1 rabbit_int1 rodent_int1 exotic_int1 bird_int1 ///
livestock_int1 allergy_f asthma_bf asthma_m allergy_inh_m ///
mat_ed_3cat hhincome_cat crowding_cat children_cat  ///
agebirth_m_y preg_smk copenhagen inh_all_ever)

drop if miss!=0

*drop multiples:
keep if flerfold==1

keep if rhinitis6!=. 
replace rhinitis6 =0 if  rhinitis6_date>y11_besvardato_m &  rhinitis6_date!=.


drop if inlist(migration6,1,2) //n=107 excludes children who emigrated before 7-year FU or immigrated within year before
drop if migration6==3 & migration_date6<y11_besvardato_m & y11_besvardato_m!=.

drop if doddato< y11_besvardato_m & !mi(y11_besvardato_m) 

**************************
**Logistic regression

*DNBC
foreach var of varlist cat_int1 dog_int1 rabbit_int1 rodent_int1 exotic_int1  bird_int1 livestock_int1 {
xi: logistic i.inh_all_ever i.`var', vce(cluster mcpr)
est store `var'
}


char mat_ed_3cat[omit] 2
char crowding_cat[omit] 2
xi: logistic i.inh_all_ever i.cat_int1 i.dog_int1 i.rabbit_int1 i.rodent_int1 ///
i.exotic_int1  i.bird_int1 ///
i.livestock_int1 allergy_f asthma_bf asthma_m allergy_inh_m ///
i.mat_ed_3cat i.hhincome_cat i.crowding_cat i.children_cat  ///
agebirth_m_y i.preg_smk i.sex i.copenhagen, vce(cluster mcpr)
est store adj


*Registry

foreach var of varlist cat_int1 dog_int1 rabbit_int1 rodent_int1 exotic_int1  bird_int1 livestock_int1 {
xi: logistic i.rhinitis6 i.`var', vce(cluster mcpr)
est store `var'_reg
}


char mat_ed_3cat[omit] 2
char crowding_cat[omit] 2
xi: logistic i.rhinitis6 i.cat_int1 i.dog_int1 i.rabbit_int1 i.rodent_int1 ///
i.exotic_int1  i.bird_int1 ///
i.livestock_int1 allergy_f asthma_bf asthma_m allergy_inh_m ///
i.mat_ed_3cat i.hhincome_cat i.crowding_cat i.children_cat  ///
agebirth_m_y i.preg_smk i.sex i.copenhagen, vce(cluster mcpr)
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
using sensitivity_analysis_ar, /// 
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

