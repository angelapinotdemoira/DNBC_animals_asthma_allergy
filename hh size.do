*Household size variables
*Angela Pinot de Moira
*19th February 2021
********************************************************************************

*calculate number of adults in the household:
gen adult18 = a197a
recode adult18 0=1
foreach var of varlist a199b_* {
replace adult18 = adult18 + inrange(`var',18,50)
} 

*calculate the number of children in the household:
egen x=rownonmiss(a199b_*)
gen child18=0 if a198==1 | x!=0
foreach var of varlist a199b_* {
replace child18 = child18 + inrange(`var',0,17) if child18!=.
} 

*Create categorical variables:
recode adult18 1=1 2=2 3/max=3 if adult18!=., gen(adults_cat)
recode child18 0=0 1=1 2/max=2 if child18!=., gen(children_cat)

*Label variables
label variable adults_cat "Number of adults in household"
label define adults 1 "1" 2 "2" 3 ">=3" 9999 "Missing"
label val adults_cat adults

lab var children_cat "Number of children in household"
lab def children 0 "0" 1 "1" 2 ">=2" 9999 "Missing"
label val children_cat children

********************************************************************************
*Crowding variable

*Create a combined hh size variable:
gen hh_size = adult18 + child18

*Create a variable for no. of people per room:
gen crowding = hh_size/a206a

recode crowding min/0.5=1 0.50001/1=2 1.00001/max=3 if !mi(crowding), gen(crowding_cat)

lab var crowding_cat "Crowding (persons/room)"
lab def crowding 1 "<=0.5" 2 ">0.5-1" 3 ">1" 9999 "Missing"
lab val crowding_cat crowding
