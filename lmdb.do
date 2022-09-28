********************************************************************************
*Angela Pinot de Moira
*Appending raw files and creating outcome measures
*20 Jan 2021
********************************************************************************

*Announce directories:

global lmdb "D:\Data\workdata\707796\LMDB"
global mfr "D:\Data\workdata\707796\MFR"

********************************************************************************

// LMDB data

cd $lmdb // set the directory

clear all
local flist : dir "$lmdb" files "lmdb*" // creates a list of file names

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
forvalues yr=1995/2019 {
replace year = `yr' if source=="lmdb`yr'.dta":source // use the values in the label to create the new variable
}


save "lmdb_1995-2019.dta"
