********************************************************************************
*Angela Pinot de Moira
*Appending raw files for income variable; creating variable
*20 Jan 2021
********************************************************************************

*Announce directories:

global bef "D:\Data\workdata\707796\BEF"
global ind "D:\Data\workdata\707796\IND"
global dnbc "D:\Data\workdata\707796\uploaded data"
global mfr "D:\Data\workdata\707796\MFR"


********************************************************************************
/*
// BEF data

cd $bef // set the directory

clear all
local flist : dir "$bef" files "bef*" // creates a list of file names

dis `"`flist'"' // displays the list with inverted commas wrapped around each object
gen source=.
local i 0
foreach f in `flist' {
append using "`f'"
replace source= `++i' if mi(source) // source is replaced by incremental values
label def source `i' "`f'", add // a label is created which is the filename corresponding to i
}

label value source source // label the new variable "source" with the label created in the loop

*Create a year variable:
gen year=.
forvalues yr=1990/2011 {
replace year = `yr' if source=="bef`yr'.dta":source // use the values in the label to create the new variable
}
gen year_minus1 = year

*Remove duplicates:
tempvar dup n
unab vlist: _all //place all variables in the current dataset in the local macro vlist
by `vlist', sort: gen `dup'=_n
by pnr year, sort: gen `n'=_N
list if `dup'>1
list if `n'>1
drop if `dup'>1 // no observations dropped (no duplicates)



save "BEF_1990-2011.dta"

********************************************************************************

//IND data

cd $ind // set the directory

clear all
local flist : dir "$ind" files "ind*" // creates a list of file names

dis `"`flist'"' // displays the list with inverted commas wrapped around each object
gen source=.
local i 0
foreach f in `flist' {
append using "`f'"
replace source= `++i' if mi(source) // source is replaced by incremental values
label def source `i' "`f'", add // a label is created which is the filename corresponding to i
}

label value source source // label the new variable "source" with the label created in the loop

*Create a year variable:
gen year=.
forvalues yr=1990/2011 {
replace year = `yr' if source=="ind`yr'.dta":source // use the values in the label to create the new variable
}

drop if inlist(source,"ind2012.dta":source,"ind2013.dta":source) // only up to year 2011 is needed

gen year_minus1 = year

*Remove duplicates:
tempvar dup n
unab vlist: _all //place all variables in the current dataset in the local macro vlist
by `vlist', sort: gen `dup'=_n
by pnr year, sort: gen `n'=_N
list if `dup'>1
list if `n'>1
drop if `dup'>1

save "IND_1990-2011.dta"

/*
*Check equivalised income same in all family members:
merge 1:1 pnr year using `bef'

gen aekvivadisp_14 = aekvivadisp_13

collapse (min)aekvivadisp_14 (max) aekvivadisp_13, by (familie_id year)

*/

*/
********************************************************************************
//Income year prior to birth

cd $mfr // set the directory

use lbgravff pnr cpr_moder cpr_fader using "births_long.dta", clear

keep if pnr==cpr_moder
keep lbgravff cpr_fader

merge 1:1 lbgravff using "$dnbc\DNBC_data.dta", keepusing(lbgravnr lbnr eventda bcpr mcpr flerfold flernr outcome a19*)
drop _merge

gen year_birth = year(eventda)
gen year_minus1 = year_birth - 1

*drop if bcpr=="" 

gen pnr = mcpr
by pnr year_minus1 (bcpr), sort: gen n2=_n
keep if n2==1 //mothers with multiple children in one year that aren't twins
drop n

*1) merge with BEF file to obtain family id:

merge 1:1 pnr year_minus1 using $bef\BEF_1990-2011.dta, keepusing(familie_id)
drop if _merge==2
rename _merge bef_merge
rename pnr pnr_dnbc // rename pnr of mother - it will be replaced by pnr in bef file

*2) join with bef using family id

joinby familie_id year_minus1 using $bef\BEF_1990-2011.dta, unmatched(master)
drop _merge

*********************************************

//merge with IND
replace pnr=mcpr if mi(pnr) //fill in missing pnrs

*first delete duplicates (keeping relevant observation)
by pnr year_minus1, sort: gen n=_N 
drop if n==2 & pnr!=mcpr & pnr!=cpr_fader
drop if bcpr=="XXXXX" & pnr!=mcpr
drop if bcpr=="XXXXX" & pnr!=mcpr

merge 1:1 pnr year_minus1 using $ind\IND_1990-2011.dta
drop if _merge==2
drop _merge



********************************************************************************
*Place equivalised hh income into categories based on income year before birth:

*First identify the population of mothers (i.e. exclude fathers and others in the family)
*this is to prevent larger families being over-represented in the percentiles
*or single mothers being under-represented

keep if pnr==mcpr

*DST income:
forvalues yr=1995/2002 {
gen hhincome_`yr' = aekvivadisp_13 if year_minus1==`yr'
}

gen hhincome_cat=.
forvalues yr = 1995/2002 {
_pctile hhincome_`yr', p(25,50,75)
return list
replace hhincome_cat = 1 if hhincome_`yr'<=`r(r1)'
replace hhincome_cat = 2 if hhincome_`yr'<=`r(r2)' & hhincome_`yr'>`r(r1)' & hhincome_`yr'!=.
replace hhincome_cat = 3 if hhincome_`yr'<=`r(r3)' & hhincome_`yr'>`r(r2)' & hhincome_`yr'!=.
replace hhincome_cat = 4 if hhincome_`yr'>`r(r3)' & hhincome_`yr'!=.
tab hhincome_cat
}



keep mcpr year_birth hhincome_cat hybrid_hhincome_cat
