********************************************************************************
*Angela Pinot de Moira
*Appending raw files
*3rd February 2021
********************************************************************************

*Announce directories:

global lpradm "D:\Data\workdata\707796\LPRADM"
global lprbes "D:\Data\workdata\707796\LPRBES"
global lprdiag "D:\Data\workdata\707796\LPRDIAG"
global mfr "D:\Data\workdata\707796\MFR"

********************************************************************************

// LPRADM data

cd $lpradm // set the directory

clear all
local flist : dir "$lpradm" files "lpradm*" // creates a list of file names

dis `"`flist'"' // displays the list with inverted commas wrapped around each object
gen source=.
local i 0
foreach f in `flist' {
append using "`f'"
replace source= `++i' if mi(source) // source is replaced by incremental values
label def source1 `i' "`f'", add // a label is created which is the filename corresponding to i
}

label value source source1 // label the new variable "source" with the label created in the loop

*Create a year variable:
gen year=.
forvalues yr=1995/2018 {
replace year = `yr' if source=="lpradm`yr'.dta":source1 // use the values in the label to create the new variable
}


*Remove duplicates:
tempvar dup n
unab vlist: _all //place all variables in the current dataset in the local macro vlist
by `vlist', sort: gen `dup'=_N
tab `dup' // no duplicates

save "lpradm_1995-2018.dta", replace


********************************************************************************

//LPRDIAG


cd $lprdiag // set the directory

clear all
local flist : dir "$lprdiag" files "lprdiag*" // creates a list of file names

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
forvalues yr=1995/2018 {
replace year = `yr' if source=="lprdiag`yr'.dta":source // use the values in the label to create the new variable
}


*Remove duplicates:
tempvar dup n
unab vlist: _all //place all variables in the current dataset in the local macro vlist
by `vlist', sort: gen `dup'=_n
tab `dup' // duplicates
keep if `dup'==1

save "lprdiag_1995-2018.dta"


********************************************************************************

//LPRBES


cd $lprbes // set the directory

clear all
local flist : dir "$lprbes" files "lprbes*" // creates a list of file names

dis `"`flist'"' // displays the list with inverted commas wrapped around each object
gen source=.
local i 0
foreach f in `flist' {
append using "`f'"
replace source= `++i' if mi(source) // source is replaced by incremental values
label def source2 `i' "`f'", add // a label is created which is the filename corresponding to i
}

label value source source2 // label the new variable "source" with the label created in the loop

*Create a year variable:
gen year=.
forvalues yr=1995/2018 {
replace year = `yr' if source=="lprbes`yr'.dta":source2 // use the values in the label to create the new variable
}


*Remove duplicates:
tempvar dup n
unab vlist: _all //place all variables in the current dataset in the local macro vlist
by `vlist', sort: gen `dup'=_n
tab `dup' // duplicates
keep if `dup'==1

save "lprbes_1995-2018.dta"

********************************************************************************
*Merge together

cd $lpradm // set the directory

clear all
use "lpradm_1995-2018.dta"
rename source source_adm
rename year year_adm

merge 1:m recnum using $lprdiag\lprdiag_1995-2018.dta

keep if _merge==3 
drop _merge

rename source source_diag
rename year year_diag

save $lprdiag\merged_lpradm_lprdiag_1995-2018.dta

joinby recnum using $lprbes\lprbes_1995-2018.dta, unmatched(master)
drop _merge
rename source source_bes
rename year year_bes

save $lprdiag\merged_lpradm_lprdiag_lprbes_1995-2018.dta
