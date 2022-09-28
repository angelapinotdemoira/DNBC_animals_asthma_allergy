/*Angela Pinot de Moira
Rhinitis outcome variable
4th February 2021
*/

********************************************************************************

*Announce directories:

global lprdiag "D:\Data\workdata\707796\LPRDIAG"
global lmdb "D:\Data\workdata\707796\LMDB"
global dnbc "D:\Data\workdata\707796\uploaded data"


********************************************************************************
*Merge population with lmdb data

cd $lmdb

clear all

use eventda lbgravff bcpr flerfold flernr outcome using "$dnbc\DNBC_data.dta"

by bcpr, sort: gen n=_N
keep if n==1 
drop n

gen pnr=bcpr

merge 1:m pnr using "lmdb_1995-2019.dta"
drop if _merge==2
drop _merge

*Remove duplicates:
tempvar dup n
unab vlist: _all //place all variables in the current dataset in the local macro vlist
summ `vlist'
by `vlist', sort: gen `dup'=_n
tab `dup'
keep if `dup'==1 // run a sensitivity analysis to see how this affects % with AD

********************************************************************************
*Append with lpr data

tempfile lmdb
save `lmdb'

use eventda lbgravff bcpr flerfold flernr outcome using "$dnbc\DNBC_data.dta", clear

by bcpr, sort: gen n=_N
keep if n==1 
drop n

gen pnr=bcpr

merge 1:m pnr using "$lprdiag\merged_lpradm_lprdiag_1995-2018.dta", keepusing(pnr recnum d_inddto d_uddto c_adiag c_diag c_diagtype c_tildiag)
drop if _merge==2
drop _merge

/*
tempvar dup n
unab vlist: _all //place all variables in the current dataset in the local macro vlist
summ `vlist'
by `vlist', sort: gen `dup'=_n
tab `dup' // there are no duplicates
*/

append using `lmdb', gen(append)

********************************************************************************
*Create an age at diagnosis:

*Create an start date for hospital episodes:
replace eksd = d_inddto if eksd==.

gen age = floor((eksd - eventda)/365.25)

drop if age<6 //ONLY INCLUDE DIAGNOSES MADE AFTER 6 YEARS

*****************************************************
/*Rhinitis

CRITERIA 1 (BASED ON ICD-10)

>=1 hospital contact for:

J30 "hay fever and allergic rhnitis"
J30.0 "vasomotor rhinitis"
J30.1 "allergic rhinitis due to pollen"
J30.2 "other seasonal allergic rhinitis"
J30.3 "other allergic rhinitis"
J30.4 "allergic rhinitis, unspecified"
J31.0 "chronic rhinitis"

***

CRITERIA 2 (BASED ON ATC and ICD-10)

>=2 filled prescriptions within 12 months of:

R01AD01 - R01AD60 "inhaled corticosteroids for rhinitis"

And no hospital contact for (exclusion criteria):
J33 - "nasal polyps"
(J330, J331, J338, J339)
J010-J019 "acute sinusitis"
J320-J329 "chronic sinusitis"

***

CRITERIA 3 (BASED ON ICD-10 AND ATC)

>=2 filled prescriptions of:

R06A "antihistamines for systemic use"

And no hospital contact for:
L29 "pruritus" or
DL50 "allergic urticaria"

***

CRITERIA 4 (BASED ON ATC)

>=1 filled prescriptions of:
V01A "specific immune therapy, allergen substract therapy" and/or
S01GX "medication for allergic conjunctivitis"

*/

***************************************************************************

gen criteria_1 = 1 if regexm(c_adiag,"^DJ30") | regexm(c_adiag,"^DJ310")

*Create an in (start) date
gen criteria_1_in = d_inddto if criteria_1==1

*****************************************************************************
				
gen criteria_2 = 1 if regexm(atc,"^R01AD")   

gen criteria_2excl = 1 if regexm(c_adiag,"^DJ33") | regexm(c_adiag,"^DJ01") ///
							| regexm(c_adiag,"^DJ32")
 							
******************************************************************************
							
gen criteria_3 = 1 if regexm(atc,"^R06A")   

gen criteria_3excl = 1 if regexm(c_adiag,"^DL29") | regexm(c_adiag,"^DL50") 
							

*****************************************************************************
gen criteria_4 = 1 if regexm(atc,"^V01A") | regexm(atc,"^S01GX")

*Create an in (start) date
gen criteria_4_in = eksd if criteria_4==1

format *_in %d


*****************************************************************************
//Now create timebands for each medication use 
//- to identify overlapping medication
// and exclude montelukast with diagnoses of allergic rhinits



*Create an end date for prescriptions (1 month after prescription/discharge)
gen eksd_out = eksd + 30.4167 if append==1 // prescription data - creates a window of a month 
										  //(but note this could end up being longer than a month)
											
replace eksd_out = d_uddto + 30.4167 if append==0 // prescription data - creates a window of a month 
										  //(but note this could end up being longer than a month)
											

format eksd_* %d

****
*drop irrelevant observations:

drop if criteria_1==. & criteria_2==. & criteria_2excl==. & criteria_3==. & ///
		criteria_3excl==. & criteria_4==.

****

*Generate an id for each observation:
sort pnr eksd
gen id =_n

*Expand the dataset
expand 2


*Create a time variable for each duplicate observation
by id, sort: gen time =cond(_n==1, eksd, eksd_out) 
format time %d

*Create a variable which indicates whether each time is a start or end date
by id: gen inout = cond(_n==1, 1,-1) 

*Create a status variable for each individual
gsort pnr time -inout
by pnr: gen status = sum(inout) 

*Now create the time band
by pnr: gen time_band = sum(inlist(status[_n-1],0,.))

****
*Identify co-occurring events for criteria 2 and 3:

by pnr time_band, sort: egen c2_excl_count = total(criteria_2excl)
by pnr time_band, sort: egen c3_excl_count = total(criteria_3excl)

replace criteria_2=. if c2_excl_count>0
replace criteria_3=. if c3_excl_count>0


*Create in (start) dates
gen criteria_2_in = eksd if criteria_2==1
gen criteria_3_in = eksd if criteria_3==1

format *_in %d

****
*drop duplicate observations:
drop if inout==-1

*Collapse the dataset to obtain summaries for each criteria:

collapse (max) criteria_1 criteria_2 criteria_3 criteria_4 (min) ///
criteria_1_in criteria_2_in criteria_3_in criteria_4_in (mean) eventda, by(pnr)

foreach num of numlist 1/4 {
gen age_`num' = floor((criteria_`num'_in - eventda)/365.25)
}
egen rhinitis6 = rowmax(criteria_1 criteria_2 criteria_3 criteria_4)
egen rhinitis6_date = rowmin(criteria_1_in criteria_2_in criteria_3_in criteria_4_in)
format rhinitis6_date %d
************************************************************************
*keep only relevant variables:
keep pnr rhinitis6 rhinitis6_date

************************************************************************
*Merge with DNBC data to obtain denominator (DNBC children with valid cpr number):

tempfile rhinitis
save `rhinitis'

clear all

use bcpr using "$dnbc\DNBC_data.dta"

by bcpr, sort: gen n=_N
keep if n==1 
drop n

rename bcpr pnr

merge 1:1 pnr using `rhinitis'
drop if _merge==2
drop _merge






/*Merge with DNBC data:
tempfile rhinitis
save `rhinitis'

use "$dnbc\DNBC_data.dta", clear

gen pnr=bcpr

merge m:1 pnr using `rhinitis', keepusing (rhinitis rhinitis_date)
drop if _merge==2
rename _merge merge_rhinitis

*/
