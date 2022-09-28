********************************************************************************
*Angela Pinot de Moira
*Creating a maternal education variable
*20 Jan 2021
********************************************************************************

*Announce directories:

global udd "D:\Data\workdata\707796\UDDA"
global dnbc "D:\Data\workdata\707796\uploaded data"


********************************************************************************
/*
// UDDA data

cd $udd // set the directory

clear all
local flist : dir "$udd" files "udda*" // creates a list of file names

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
forvalues yr=1990/2013 {
replace year = `yr' if source=="udda`yr'.dta":source // use the values in the label to create the new variable
}

*Remove duplicates:
tempvar dup n
unab vlist: _all //place all variables in the current dataset in the local macro vlist
by `vlist', sort: gen `dup'=_n
by pnr year, sort: gen `n'=_N
list if `dup'>1
list if `n'>1
drop if `dup'>1 // no observations dropped (no duplicates)

save "UDDA_1990-2013.dta"

*categorise education level:
import delimited D:\Data\workdata\707796\UDDA\audd_level_l1l4_kt.csv, delimiter(";") clear 

gen label_name = "hfaudd"
order label_name value value_label

//define the labels
qui count
local n `r(N)'
forvalues i = 1/`n' {
label define `=label_name[`i']' `=value[`i']' "`=value_label[`i']'", add
}

//save value labels in a temporary do-file with the -label-command
tempfile labeler
label save using `labeler'

//label values in UDDA_1990-2013
use "UDDA_1990-2013.dta", clear
do `labeler'
label values hfaudd hfaudd

//create a nine-category variable:
tempvar edu
decode hfaudd, gen(`edu')
encode `edu', gen(edu) label(edu) 

save "UDDA_1990-2013.dta", replace
*/
********************************************************************************
*Merge with keyfile:

use "$dnbc\DNBC_data.dta", clear
gen pnr = mcpr

joinby pnr using "$udd\UDDA_1990-2013.dta", unmatched(master)
drop if eventda==.
drop if year>year(eventda) 
recode edu 8=.
collapse (max) mat_ed=edu, by(lbgravff)

recode mat_ed (1/2=1 "short") (3=2 "medium") (4/7=3 "high"), gen(mat_ed_3cat)
label values mat_ed edu


