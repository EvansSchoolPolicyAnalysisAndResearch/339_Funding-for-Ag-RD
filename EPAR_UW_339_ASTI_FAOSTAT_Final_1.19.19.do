*Title/Purpose of Do File: ASTI 2014 Agricultural R&D Public Investments (Project #339)
*Author(s): Terry Fletcher, Kirby Callaway, Mel Howlett, Pierre Biscaye
	
//OUTLINE OF FILE
// 0. Globals
	**0.1 Element/Crop Globals
	**0.2 File Directory Globals
	**0.3 COuntry Globals
	**0.4 Year Globals
** 1. Programs
	//1.1 FSClean
	//1.2 fullfaostat
	//1.3 AggALL
// 2. Creating DTA Files
	**2.1 ASTI Spending
	**2.2 ASTI FTEs
	**2.3 ASTI Governement
	**2.4 ASTI Totals
	**2.5 FAOSTAT Data
** 3. Merge DTA Files
	//3.1 Create Aggregation Profile
	//3.2 Run Aggregation Program
	//3.3 Merge ASTI FTE Data
	//3.4 Merge in Countrywide Totals
// 4. Creating Final Output
	**4.1 Merge Countries Together
	**4.2 Separate Crop Categories
	**4.3 Separate Regional Categories
	**4.4 Generate Final Variables

clear
set more off
**____________________________________________________________________________________________________________________________________________________________________________________________
//Change these variables in future waves																																					  |
global astiyear=2012 //                                                                                                                                          							  |
global faostatyear=2012 //	~WAVE~																																							  |
global numpreviousyears = 5 // How many years of FAOSTAT data do you want?  For just the current year, put 1, for the current year and the previous year put 2 etc.							  |
global input "ENTER FILEPATH HERE\New ASTI Data" //Where did you save the ASTI Data? (see 2.0 below for how to download)																	  |
global import "ENTER FILEPATH HERE\FAOSTAT Complete Dataset\"  //Where did you save the FAOSTAT data?  (go to http://www.fao.org/faostat/en/#home and use the bulk download function)		  |
global GPGcategorizations "ENTER FILEPATH HERE" //From the EPAR page, download the "GPG Correlates_Crop-Level Data Decisions FAOSTAT.xlsx" file and the "FAOSTAT File Names.xlsx" file and 	  |
												// place them in the location referenced here.																								  |
global filedirectory "ENTER FILEPATH HERE" //Where do you want the created files to go?		  																								  |
global directoryname "Name Of Data Analysis" //What do you want to call the folder for the data analysis?																					  |
**____________________________________________________________________________________________________________________________________________________________________________________________|

//////////////////////////////////////////////////////////////////////////////
//							0. Creating Globals   							//
//////////////////////////////////////////////////////////////////////////////

****************************************
**	0.1 Globals for Elements/Crops 	  **
****************************************
global numasticrops = 37 //The number of crops that will be looked at	

global domaincodes QC QV OA MK FDI EA IG TP PP PI CC FBS BC //FAOSTAT Domains
global domainQCelements Area_harvested Production Yield //Production 1-3
global domainQVelements GPV_constant_04_06_1000_I NPV_constant_04_06_1000_I GPV_current_million_US GPV_con_04_06_million_US //GNPV 4-7
global domainOAelements TotalPopulation TotalPopulationMale TotalPopulationFemale RuralPopulation UrbanPopulation //Population 8-12
global domainMKelements Gross_Domestic_Product ValueAddAgFoFish //GDP 13-14
global domainFDIelements FDItoAgFoFish Total_FDI_inflows //FDI 15-16
global domainEAelements AllDonorAgricultureFlow AllDonorAgricultureFlowRD MultilatAgricultureFlow MultilatAgricultureFlowRD BilatAgricultureFlow BilatAgricultureFlowRD PrivateAgricultureFlow PrivateAgricultureFlowRD //Foreign Investment 17-24
global domainIGelements GovExpenditureAgFoFish //Governemtn Expenditure 25
global domainTPelements ExportQuantity ExportValue ImportQuantity ImportValue //Export 43-46
global domainPPelements PPrice_LCU PPrice_SLC PPrice_USD  // Producer Prices 47-49
global domainPIelements PPrice_Index //Producer Price Index 50
global domainCCelements FdSupQtt FdSupQtgCapDay FdSupQtkgCapYr FdSupkcalCapDay PrSupQtgCapDay FatSupQtgCapDay //Food Supply 51-56
global domainFBSelements FBSProduction FBSImportQuantity FBSStockVariation FBSDomSupQt FBSSeed FBSWaste FBSFood FBSFdSupQtkgCapYr FBSFdSupkcalCapDay FBSPrSupQtgCapDay FBSFatSupQtgCapDay FBSExportQuantity FBSFeed FBSLosses FBSProcessing FBSOtheruses //FBS 57-72
global domainBCelements CBProduction CBImportQuantity CBExportQuantity CBDomSupQt CBWaste CBFdSupQtt CBFeed CBSeed CBStockVariation CBLosses CBProcessing CBOtheruses //Commodity Balance 73-84

global filestosort Data_Harvest_Production_Yield Export Annual_Prices Food_Supply Food_Balance Commodity_Balance Price_Index Gross_Net_Production_Value //These are files that are at the crop and country level
global domaincodessort QC TP PP CC FBS BC PI QV 
global filesatcountry Population GDP FDI Foreign_Aid_Flows Ag_Expenditures //These are files which are at the country level only
global domaincodescountry OA MK FDI EA IG

global domainASTIelements FTEs FTEsper100000far FTEspermillionpo GovResearchers ValueAddAgFoFish sptmillioncurrentlocal sptmillionconstant2011 sptmilconstantPPP sptmillionconstantUS sptasashareofaggdp sptmilconstperhthoufarmer sptmilconstPPPpermilpop researcherstotalftesper100000far researcherstotalftespermillionpo researcherstotalftes //ASTI 0, 26-42
global domainASTISPDelements sptmillioncurrentlocal sptmillionconstant2011 sptmilconstantPPP sptmillionconstantUS sptasashareofaggdp sptmilconstperhthoufarmer sptmilconstPPPpermilpop //ASTI Spending 33-39
global domainASTIFTEelements researcherstotalftesper100000far researcherstotalftespermillionpo researcherstotalftes 
global elementlabels `" "Researchers, total (FTEs per 100,000 farmers)" "Researchers, total (FTEs per million population)" "Researchers, total (FTEs)" "' //1-3

global crpall `" "Bananas and Plantains" "Barley" "Beans" "Coconut Palm" "Cotton" "Groundnuts" "Maize" "Oil Palm" "Other Cereals" "Other Oil-Bearing Crops" "Other Pulses" "Other Roots and Tubers" "Potatoes" "Rice" "Sorghum" "Soybeans" "Tobacco" "Wheat" "Other Fruits" "Flowers" "Vegetables" "Nuts" "Other Crops" "Cattle No Dairy" "Dairy" "Sheep and Goats" "Poultry" "Other Animals" "Forestry" "Inland Fisheries" "Marine Fisheries" "Natural Resources" "Socioeconomics" "Pastures and Forages" "On Farm Postharvest" "Ag Engineering" "Other Commodities" "'
global crplblfirst `" "Researchers, total, bananas and plantains (FTEs)" "Researchers, total, barley (FTEs)" "Researchers, total, beans (FTEs)" "Researchers, total, coconut palm (FTEs)" "Researchers, total, cotton (FTEs)" "Researchers, total, groundnuts (FTEs)" "Researchers, total, maize (FTEs)" "Researchers, total, oil palm (FTEs)" "Researchers, total, other cereals (FTEs)" "Researchers, total, other oil-bearing crops (FTEs)" "Researchers, total, other pulses (FTEs)" "Researchers, total, other roots and tubers (FTEs)" "Researchers, total, potatoes (FTEs)" "Researchers, total, rice (FTEs)" "Researchers, total, sorghum (FTEs)" "Researchers, total, soybeans (FTEs)" "Researchers, total, tobacco (FTEs)" "Researchers, total, wheat (FTEs)" "Researchers, total, other fruits (FTEs)" "Researchers, total, flowers and ornamentals (FTEs)" "Researchers, total, vegetables (FTEs)" "Researchers, total, nuts (FTEs)" "Researchers, total, other crops (FTEs)" "Researchers, total, cattle (excl. dairy) (FTEs)" "'
global crplblsecond `" "Researchers, total, dairy (FTEs)" "Researchers, total, sheep and goats (FTEs)" "Researchers, total, poultry (FTEs)" "Researchers, total, other animals (FTEs)" "Researchers, total, forestry (FTEs)" "Researchers, total, inland fisheries (FTEs)" "Researchers, total, marine fisheries (FTEs)" "Researchers, total, natural resources (FTEs)" "Researchers, total, socioeconomics (FTEs)" "Researchers, total, pastures and forages (FTEs)" "Researchers, total, on-farm postharvest (FTEs)" "Researchers, total, agricultural engineering (FTEs)" "Researchers, total, other commodities (FTEs)" "'
global crplblall : list global(crplblfirst)| global(crplblsecond)
global crpcatall `" "Subsistence Crops" "Commodity Grains" "Other Market-Oriented Crops" "New Crops" "' //1-4

global crpvarall researcherstotalbananasandplanta researcherstotalbarleyftes researcherstotalbeansftes researcherstotalcoconutpalmftes researcherstotalcottonftes researcherstotalgroundnutsftes researcherstotalmaizeftes researcherstotaloilpalmftes researcherstotalothercerealsftes researcherstotalotheroilbearingc researcherstotalotherpulsesftes researcherstotalotherrootsandtub researcherstotalpotatoesftes researcherstotalriceftes researcherstotalsorghumftes researcherstotalsoybeansftes researcherstotaltobaccoftes researcherstotalwheatftes researcherstotalotherfruits researcherstotalflowers researcherstotalvegetables researcherstotalnuts researcherstotalothercrops researcherstotalcattlenodairy researcherstotaldairy researcherstotalsheepandgoats researcherstotalpoultry researcherstotalotheranimals researcherstotalforestry researcherstotalinlandfisheries researcherstotalmarinefisheries researcherstotalnaturalresources researcherstotalsocioeconomics researcherstotalpasturesforages researcherstotalfarmpstharvest researcherstotalagengineering researcherstotalothcommodities
global crpvarshort : subinstr global crpvarall "researcherstotal" "" , all
global aggregationall AggCrops AggExport AggPricePP AggSupply AggFBalance AggCBalance AggPricePI AggValue //1-8 //Different FAOSTAT files report crops in different ways, this lets us aggregate crops in different ways depending on the FAOSTAT file


****************************************
**   0.2 File Directory Management    **
****************************************
//If you set the globals $filedirectory and $directoryname correctly above, this will produce the folders and the globals that you need for the rest of the code.
capture mkdir "$filedirectory\\${directoryname}\"
capture mkdir "$filedirectory\\${directoryname}\DTA Files"
capture mkdir "$filedirectory\\${directoryname}\DTA Files\ASTI_Unmerged"
capture mkdir "$filedirectory\\${directoryname}\DTA Files\Countries"
capture mkdir "$filedirectory\\${directoryname}\DTA Files\Disaggregated"
capture mkdir "$filedirectory\\${directoryname}\Outputs"
capture mkdir "$filedirectory\\${directoryname}\FAOSTAT DTA Files"


global merge "$filedirectory\\${directoryname}\DTA Files" 
global output "$filedirectory\\${directoryname}\Outputs" 
global savespace "$filedirectory\\${directoryname}\FAOSTAT DTA Files" 


****************************************
**         0.3 Country Globals        **
****************************************
//Before Running this section, you will need to download the data.  To do so, follow the instructions in 2.0
import delimited "$input\ASTI_Researchers.csv"
replace v2 = "Belize" if v2 == "Belize "
global astivarnum3 = $astiyear - 2005
global faovarnum = $faostatyear
keep v1 v2 v$astivarnum3
drop if v2 == "Country"
keep if ~missing(v$astivarnum3)
duplicates drop v2, force
global cntcountry = _N +1
global numcountry = _N

	global i=1
qui while $i < $cntcountry {
	global c$i = v2[$i]
	global i = $i + 1
}
clear

****************************************
**          0.4 Year Globals          **
****************************************
global cntasticrops = $numasticrops + 1 //One more than the number of crops to be looked at
global astivarnum1 = ($astiyear - 1978) //
global i = 0 //this counts years
while $i < $numpreviousyears {
global faostat$i = $faostatyear - $i
global i = $i + 1
}
global i = 1900 //This global counts excluded years
global ii = 0 //This global counts included years
global iii = 0 //This global determines if the year is in the set already
global otheryearsfaostat = ""
while $i < 2101 {
while  $ii < $numpreviousyears {
	if "${faostat$ii}" == "$i" {
		global iii = 1
	}
	global ii = $ii + 1
	}
	global ii = 0
	if "$iii" == "0" {
	global otheryearsfaostat = "$otheryearsfaostat $i"
	}
global i = $i +1
global iii = 0
}
global i = 0 //this counts years
global allyearsfaostat = ""
while $i < $numpreviousyears {

global allyearsfaostat = "$allyearsfaostat ${faostat$i}"
global i = $i + 1
}
clear
******************************************************************************
**                                1. Programs                               **
******************************************************************************

////////////////////////////////////////
//           1.1 FSclean              //
//    Clean FAOSTAT to match ASTI     //
////////////////////////////////////////

//Create a program to get rid of extra columns and relabel countries in FAOSTAT data to match ASTI data

**When we get the FAOSTAT data, it does not match up with the ASTI data. 
	//Some countries and variables are named different things, some elements or items have strange characters in them, and some variable names are too long.
	//This program cleans out strange characters, renames countries, and renames variables.
capture program drop FSclean
program FSclean

capture confirm variable itemcode
if !_rc {
drop if itemcode == 2928 | itemcode == 2948 | itemcode == 2949
}

//The if loops below are used because for some data, we want the item, for other data we want the element, for other data we want the value
	**These statements get rid of the varaiables thatwe don't want depending on which dataset we are looking at.
	if item == "Disbursement"{
		keep donor area element item itemcode value purpose year domaincode //clean unused variables 
	}
	//local j = 0 //Local variable to distinguish Export 
	if item != "Disbursement" {
		if domaincode == "TP"{
			//keep area element item value 
			//rename country area
			replace element = subinstr(element, " ", "",.)
			//local j = 1
		}
		keep area element item value itemcode year domaincode
	}
//This changes the FAOSTAT country names to the ASTI country names and removes the strange characters from the element variable
	replace area = "Central African Rep." if area== "Central African Republic"
	replace area = "Congo, Rep." if area == "Congo"
	replace area = "Cote d'Ivoire" if area == "CÃ´te d'Ivoire"
	replace area = "Gambia, The" if area == "Gambia"
	replace area = "Tanzania" if area == "United Republic of Tanzania"
	replace area = "Congo, Dem. Rep." if area == "Democratic Republic of the Congo"
	replace area = "Vietnam" if area == "Viet Nam" //For possible future waves with South Asian data
	replace area = "Laos" if area == "Lao People's Democratic Republic" //For possible future waves with South Asian data
	replace area = "Dominican Rep." if area == "Dominican Republic"
	replace area = "St Lucia" if area == "Saint Lucia"
	replace area = "Bolivia" if area == "Bolivia (Plurinational State of)"
	replace area = "Venezuela" if area == "Venezuela (Bolivarian Republic of)"
	replace element = subinstr(element, "$", "",.)
	replace element = subinstr(element, "(", "",.)
	replace element = subinstr(element, ")", "",.)
	replace element = subinstr(element, "-", "_",.)

//For certain data sets we need to clean out the items as well as the elements
	if (element== "Value US"){
		replace item = subinstr(item, "$", "",.)
		replace item = subinstr(item, "(", "",.)
		replace item = subinstr(item, ")", "",.)
		replace item = subinstr(item, "-", "_",.)
		replace item = subinstr(item, ",", "",.)
	}
	if element== "ExportQuantity"|element=="ExportValue" {
		replace item = subinstr(item, "(", "",.)
		replace item = subinstr(item, ")", "",.)
	}

//Certain variables don't have the names that we want them to, or have names that are too long. 
	**This shortens and clean up those variable names
	replace element = "Area_harvested" if element == "Area harvested"
	
	replace element = "GPV_constant_04_06_1000_I" if element == "Gross Production Value constant 2004_2006 1000 I"
	replace element = "NPV_constant_04_06_1000_I" if element == "Net Production Value constant 2004_2006 1000 I"
	replace element = "GPV_current_million_US" if element == "Gross Production Value current million US"
	replace element = "GPV_con_04_06_million_US" if element == "Gross Production Value constant 2004_2006 million US"
	replace element = "TotalPopulation" if element == "Total Population _ Both sexes"
	replace element = "TotalPopulationMale" if element == "Total Population _ Male"
	replace element = "TotalPopulationFemale" if element == "Total Population _ Female"
	replace element = "RuralPopulation" if element == "Rural population"
	replace element = "UrbanPopulation" if element == "Urban population"
	replace element = subinstr(element, "/tonne","",.)
	replace element = subinstr(element, "Producer Price ","PPrice_",.)
	replace element = "PPrice_Index" if element == "PPrice_Index 2004_2006 = 100"
	replace element = subinstr(element, "Food supply quantity tonnes", "FdSupQtt",.)
	replace element = subinstr(element, "Food supply quantity g/capita/day", "FdSupQtgCapDay",.)
	replace element = subinstr(element, "Food supply quantity kg/capita/yr", "FdSupQtkgCapYr",.)
	replace element = subinstr(element, "Food supply kcal/capita/day", "FdSupkcalCapDay",.)
	replace element = subinstr(element, "Protein supply quantity g/capita/day", "PrSupQtgCapDay",.)
	replace element = subinstr(element, "Fat supply quantity g/capita/day", "FatSupQtgCapDay",.)
	replace element = "DomSupQt" if element == "Domestic supply quantity"
	replace item = "Total_FDI_inflows" if item == "Total FDI inflows"
	replace item = "ValueAddAgFoFish" if item == "Value Added Agriculture Forestry and Fishing"
	replace item = "Gross_Domestic_Product" if item == "Gross Domestic Product"
	replace item = "FDItoAgFoFish" if item == "FDI inflows to Agriculture Forestry and Fishing"
	replace item = "GovExpenditureAgFoFish" if item == "Agriculture forestry fishing General Government"

//This loop compiles two different categories in flows down to one category with eight options, then cleans unused variables
	if item == "Disbursement"{
		replace purpose = "AllDonorAgricultureFlow" if (purpose == "Agriculture" & donor == "All Donors")
		replace purpose = "AllDonorAgricultureFlowRD" if (purpose == "Agricultural research" & donor == "All Donors")
		replace purpose = "MultilatAgricultureFlow" if (purpose == "Agriculture" & donor == "Multilateral Donors")
		replace purpose = "MultilatAgricultureFlowRD" if (purpose == "Agricultural research" & donor == "Multilateral Donors")
		replace purpose = "BilatAgricultureFlow" if (purpose == "Agriculture" & donor == "Bilateral Donors")
		replace purpose = "BilatAgricultureFlowRD" if (purpose == "Agricultural research" & donor == "Bilateral Donors")
		replace purpose = "PrivateAgricultureFlow" if (purpose == "Agriculture" & donor == "Private Donors")
		replace purpose = "PrivateAgricultureFlowRD" if (purpose == "Agricultural research" & donor == "Private Donors")
		keep area purpose value year domaincode
		rename purpose element
}
//This drops out aggregated categories which are duplicates of individual categorizations.  
//Crops_E: Miscell
//Food Balance Sheets E: Eggs, Milk - Excluding Butter, Miscell
	end

////////////////////////////////////////
//       1.2 fullfaostat              //
//  Change all FAOSTAT data to .dta   //
////////////////////////////////////////
capture program drop fullfaostat
program fullfaostat

//This program takes all of the downloaded FAOSTAT data and converts it from .csv to .dta files to make it easier to use
//This program takes a VERY LONG TIME TO RUN, so generally it will be commented out of the code 

clear
import excel "$GPGcategorizations\FAOSTAT File Names.xlsx", sheet("Sheet1") //Import a sheet with the file names
generate B = subinstr(A,".csv",".dta",.) //generate a variable with the new .dta names

//This loop creates two indexed globals fname1 fname2... which is all of the .csv names of the files and sname1, sname2, which is all of the .dta names of the files
global i = 1 //This global counts file names
global fnum = _N + 1
qui while $i < $fnum {
global fname$i = A[$i]
global sname$i = B[$i]
global i = $i +1
}
//This loop imports each file and saves it as a .dta file.  
//We do this because .dta files load much faster than .csv files and these files are very large
clear
global i = 1 //This global counts file names
qui while $i < $fnum {
import delimited "$import\${fname$i}"
save "$savespace\${sname$i}", replace
global i = $i +1
clear
}
end

////////////////////////////////////////
//           1.3 AggALL               //
//       Aggregate FAOSTAT Data       //
////////////////////////////////////////
capture program drop AggALL 
program AggALL
args ountry lement agtype averageyn
//Drop everything by the specific country and element of interest
	local ttdomaincode : word `agtype' of $domaincodessort
	local ttdomainelement : word `lement' of ${domain`ttdomaincode'elements}
	keep if area == "${c`ountry'}"
	keep if element == "`ttdomainelement'"

	//Clean out special characters (this should be the same as the cleaning list in 2.10)
	replace item = subinstr(item, "$", "",.)
	replace item = subinstr(item, "(", "",.)
	replace item = subinstr(item, ")", "",.)
	replace item = subinstr(item, ",", "",.)
	replace item = subinstr(item, " ", "",.)
	replace item = subinstr(item, "Ã©", "",.)
	replace item = subinstr(item, "&", "",.)
	replace item = subinstr(item, ".", "",.)
	replace item = subinstr(item, "-", "",.)
	replace item = subinstr(item, "+", "",.)
	//Add in extra lines for new categories
if _N >0 {
local yearcount = 0

	local cnt = _N+($numasticrops * $numpreviousyears)
	set obs `cnt'
	generate old = 0
	local j=1

while `yearcount' < $numpreviousyears {

 while `j'<$cntasticrops {

		//For each line set the country, element, and item to the correct value
		local lne = `cnt'-($numasticrops-`j')-($numasticrops * ($numpreviousyears - (`yearcount' + 1)))
		local ttcropname : word `j' of $crpall
		replace area = "${c`ountry'}" in `lne'
		replace element = "`ttdomainelement'" in `lne'
		replace item = "`ttcropname'" in `lne'
		replace old = 1 in `lne'

		//For each crop add up the FAOSTAT categories to get the ASTI category
		local tot=0
		local number = 0
		local jj=1

		while `jj'<(`cnt'-$numasticrops){
			global itname = item[`jj']
			local aggyn : list global(itname) in global(agg`agtype'crop`j')
			if `aggyn'==1 & year[`jj']== ${faostat`yearcount'} {
				local tot = `tot' + value[`jj']
				local number = `number' + 1

			}
			local jj = `jj' + 1
		}
		replace value = `tot' in `lne'
		replace year = ${faostat`yearcount'} in `lne'
		if `averageyn' == 1 {
			replace value = (`tot'/`number') in `lne'
		}
		local j = `j' + 1
}
			local yearcount = `yearcount' + 1
local j=1	
}
		//Clean up table
	keep if old==1
	drop old
	local newelement = subinstr("`ttdomainelement'"," ","_",.)
	rename value `newelement'
	drop element
	rename area country
	}
	save "$merge\Disaggregated\Y${faostatyear}_${c`ountry'}_`ttdomainelement'.dta", replace
	end 
	
//////////////////////////////////////////////////////////////////////////////
//							  2. Creating DTA Files   						//
//////////////////////////////////////////////////////////////////////////////

//For the following information go to https://www.asti.cgiar.org/data and follow the instructions as to how to download the correct documents 

//ASTI Spending
//Select all Countries (Benin, Botswana, Burkina Faso, Burundi, Cabo Verde, Cameroon, Central African Rep., Chad, Congo, Dem. Rep., Congo, Rep., Cote d'Ivoire, Eritrea, Ethiopia, Gabon, Gambia, The, Ghana, Guinea, Guinea-Bissau...
//...Kenya, Lesotho, Liberia, Madagascar, Malawi, Mali, Mauritania, Mauritius, Mozambique, Namibia, Niger, Nigeria, Rwanda, Senegal, Sierra Leone, South Africa, Swaziland, Tanzania, Togo, Uganda, Zambia, Zimbabwe)
//Select all Units, all Intensity Ratios, and all available years
//Download Data in CSV all in one sheet
//Name ASTI_Spending.csv
//Put it in the folder referenced in the first import line of 2.1 (This should be a folder called "New ASTI Data" in the location refrenced in global input above)

//ASTI Researchers
//Select all Countries all available years
//Select Disaggregate by Commodity focus, and select all
//Select Further disaggregate by commodity Item and select all
//Download Data in CSV all in one sheet
//Name ASTI_Researchers.csv
//Put it in the folder refereneced in the first import line of 2.2 (This should be a folder called "New ASTI Data" in the location refrenced in global input above)

//Government Researchers
//Disaggregate by Institutional Category
//Select All categories
//Select all available years
//Download CSV all in one sheet
//Name ASTI_Government.csv
//Put it in the folder referenced in the first import line of 2.3 (This should be a folder called "New ASTI Data" in the location refrenced in global input above)

//Total Researchers
//Select Researchers, total
//Select All Intensity Ratios
//Select all available years
//Download CSV all in one sheet
//Name ASTI_Totals.csv
//Put in in the folder reference in the first line of 2.4 (This should be a folder called "New ASTI Data" in the location refrenced in global input above)

***************************************
**      2.1 ASTI Data Spending       **
***************************************
	**This data is downloaded with columns of years, and rows of different types of spending by country
import delimited "$input\ASTI_Spending.csv"

replace v2 = "Belize" if v2 == "Belize "
. keep v1 v2 v$astivarnum1 //astivarnum should automatically ~CHANGE~ this to the correct year if astiyear is set correctly ~WAVE~
drop if v2 =="Country" //These data also have many observations which are not real observations, they are headers, this drops them.
global i = 1 // This global counts countries
qui while $i < $cntcountry {
preserve
	keep if v2 == "${c$i}"
	save "$merge\ASTI_Unmerged\Y${astiyear}_${c$i}_Spending.dta", replace
restore
global i = 1 + $i
}
global i = 2 // This global counts countries
use "$merge\ASTI_Unmerged\Y${astiyear}_${c1}_Spending.dta", clear
qui while $i < $cntcountry {
append using "$merge\ASTI_Unmerged\Y${astiyear}_${c$i}_Spending.dta"
global i = 1 + $i
}
global numASTISPD : list sizeof global(domainASTISPDelements)
global cntASTISPD = $numASTISPD + 1
////Create DTA file for spending////
global i = 1 //This global counts labels
global ii = 1 //This global counts observations
	**This loop makes another set of globals which are going to be used as varaiable labels based on the spending category names
	**we do this to easily reference them below and label variables later
qui while $i <$cntASTISPD {
global LBL$i = v1[$ii] //This creates a set of globals named after all of the spending categories LBL1, LBL2,...
global i = $i + 1
global ii = $ii + $cntcountry
}
save "$merge\ASTI_Unmerged\Y${astiyear}_Spending.dta", replace // Many of the files are labeled with "2014".  
//This should label the file with the astiyear variable.  You will not find ~CHANGE~ next to every one, but you should be able to replace all of the instances of "2014" in the document (which are not in comments).
//Apply element titles to labeled variables
global i = 1 //This global counts labels
	**This loop separates the spending data into separate files for each element
	**We do this to split the single column of data into multiple variables
	
qui while $i < $cntASTISPD { 
	use "$merge\ASTI_Unmerged\Y${astiyear}_Spending.dta", clear
	global tspendingelement : word $i of $domainASTISPDelements
	keep if v1 == "${LBL$i}" //This keeps each spending element in turn and drops all other observances
	rename v$astivarnum1 $tspendingelement //This renames the variable with the element name ~CHANGE~ if a year other than 2014 is used ~WAVE~
	label variable $tspendingelement "${LBL$i}" //This gives the variable the label that we stored above
	drop v1 //This drops the now unimportant v1 which was the element name
	rename v2 country //This labels v2, the country variable correctly
	save "$merge\ASTI_Unmerged\Y${astiyear}_${tspendingelement}.dta", replace
	global i = $i +1
}

//Remerge DTA files for Spending
	**Since we split the file into separate parts by elements above, we now need to merge it back together
keep country
qui foreach k in $domainASTISPDelements {
merge 1:1 country using "$merge\ASTI_Unmerged\Y${astiyear}_`k'.dta", nogen
}
save "$merge\ASTI_Unmerged\Y${astiyear}_Spending.dta", replace //This file now includes all of the ASTI spending, it will be merged into FAOSTAT in 2.3
clear
***************************************
**    2.2 ASTI Data FTEs by Crop     **
***************************************

//Create DTA files for FTEs by crop
	**This data comes in five columns, v1: indicator (crop), v2: country, v3:2011, v4:2014, and v5:note
	**We need to drop the extra columns and then remake the crop variables into multiple columns
import delimited "$input\ASTI_Researchers.csv"
replace v2 = "Belize" if v2 == "Belize "
drop if v2 == "Country" //Drop all observations which are just labels
keep v1 v2 v$astivarnum3 // ~WAVE~

	**This section keeps only the countries which ahve ASTI data from this year
global i = 1 // This global counts countries
qui while $i < $cntcountry {
preserve
	keep if v2 == "${c$i}"
	save "$merge\ASTI_Unmerged\Y${astiyear}_${c$i}_FTEs.dta", replace
restore
global i = 1 + $i
}
global i = 2 // This global counts countries
use "$merge\ASTI_Unmerged\Y${astiyear}_${c1}_FTEs.dta", clear
qui while $i < $cntcountry {
append using "$merge\ASTI_Unmerged\Y${astiyear}_${c$i}_FTEs.dta"
global i = 1 + $i
}
rename v2 country 
save "$merge\ASTI_Unmerged\Y${astiyear}_FTEs.dta", replace

global i = 1 // This Global counts crops

//Keeps each crop one at a time and relabels variable
qui while $i < $cntasticrops {
use "$merge\ASTI_Unmerged\Y${astiyear}_FTEs.dta", clear
global tcroplabel : word $i of $crplblall
global tcropname :word $i of $crpvarall
keep if v1 == "$tcroplabel"
drop v1
rename v$astivarnum3 $tcropname //This should automatically ~CHANGE~ so long as the ASTI FTEs keep being reported every 3 years ~WAVE~
label variable $tcropname "$tcroplabel"

save "$merge\ASTI_Unmerged\Y${astiyear}_${tcropname}.dta", replace
global i = $i +1
}


//Remerge DTA files
	**We separated the crops into their own files above, now we need to merge them back together.
global i = 1 //This global counts crop dta files
keep country
qui while $i < $cntasticrops {
global tcropname :word $i of $crpvarall
merge 1:1 country using "$merge\ASTI_Unmerged\Y${astiyear}_${tcropname}.dta", nogen
global i = $i + 1
}
save "$merge\Y${astiyear}_FTEs_Flipped.dta", replace //This file conatins The FTEs with crops broken out into separte variables.  It will be merged into the FAOSTAT directly before being merged into the other ASTI data

***************************************
**   2.3 ASTI Data FTEs Government   **
***************************************
//This document imports as a file with years as the variables, and countries as observances.
	**We first need to drop the years that we are not using
	**Then we need to drop the observances which are actually just labels.  
	**Then finally we need to rename some variables and drop anything that is not government researchers
clear
import delimited "$input\ASTI_Government.csv"
replace v2 = "Belize" if v2 == "Belize "
keep v1 v2 v$astivarnum1 //Will automatically ~CHANGE~ if using another year than 2014 ~WAVE~
drop if v2 == "Country"
	**This section keeps only the countries which ahve ASTI data from this year
global i = 1 // This global counts countries
qui while $i < $cntcountry {
preserve
	keep if v2 == "${c$i}"
	save "$merge\ASTI_Unmerged\Y${astiyear}_${c$i}_Government.dta", replace
restore
global i = 1 + $i
}
global i = 2 // This global counts countries
use "$merge\ASTI_Unmerged\Y${astiyear}_${c1}_Government.dta", clear
qui while $i < $cntcountry {
append using "$merge\ASTI_Unmerged\Y${astiyear}_${c$i}_Government.dta"
global i = 1 + $i
}
rename v2 country
rename v$astivarnum1 GovResearchers //Will automatically ~CHANGE~ if another year than 2014 ~WAVE~
keep if v1 == "Researchers, government (FTEs)"
drop v1
save "$merge\ASTI_Unmerged\Y${astiyear}_Government.dta", replace


***************************************
**     2.4 ASTI Data FTEs Totals     **
***************************************
//This file imports with years a variables, and countries with different intensities of researchers as observances
	**We first drop the label observances, and rename some variables
	**Then we split the file into elements, (different intensities of researchers)
	**Finally we remerge this file and the government one file 

clear
import delimited "$input\ASTI_Totals.csv"
replace v2 = "Belize" if v2 == "Belize "
drop if v2 == "Country"
keep v1 v2 v$astivarnum1 //Will automatically ~CHANGE~ if using another year than 2014 ~WAVE~
	**This section keeps only the countries which have ASTI data from this year
global i = 1 // This global counts countries
qui while $i < $cntcountry {
preserve
	keep if v2 == "${c$i}"
	save "$merge\ASTI_Unmerged\Y${astiyear}_${c$i}_Total_FTEs.dta", replace
restore
global i = 1 + $i
}
global i = 2 // This global counts countries
use "$merge\ASTI_Unmerged\Y${astiyear}_${c1}_Total_FTEs.dta", clear
qui while $i < $cntcountry {
append using "$merge\ASTI_Unmerged\Y${astiyear}_${c$i}_Total_FTEs.dta"
global i = 1 + $i
}

rename v2 country
save "$merge\ASTI_Unmerged\Y${astiyear}_Total_FTEs.dta", replace

global i = 1 //This global counts element labels
global numASTIFTE : list sizeof global(domainASTIFTEelements)
global cntASTIFTE = $numASTIFTE + 1

qui while $i < $cntASTIFTE {
global telementlabel : word $i of $elementlabels
global telementname :word $i of $domainASTIFTEelements
use "$merge\ASTI_Unmerged\Y${astiyear}_Total_FTEs.dta", clear

keep if v1 == "$telementlabel"
drop v1
rename v$astivarnum1 $telementname // Will automatically ~CHANGE~ if another year than 2014 is used
label variable $telementname "$telementlabel"
save "$merge\ASTI_Unmerged\Y${astiyear}_$telementname", replace
global i = $i + 1 
}
global i = 1 //This global counts elements
qui while $i < $cntASTIFTE {
global telementname :word $i of $domainASTIFTEelements
merge 1:1 country using "$merge\ASTI_Unmerged\Y${astiyear}_${telementname}.dta", nogen
global i = $i +1
}
merge 1:1 country using "$merge\ASTI_Unmerged\Y${astiyear}_Government.dta", nogen
merge 1:1 country using "$merge\ASTI_Unmerged\Y${astiyear}_Spending.dta", nogen

generate year = $astiyear
save "$merge\ASTI_Unmerged\Y${astiyear}_FTEs_Flipped_Total.dta", replace

***************************************
**         2.5 FAOSTAT Data          **
***************************************
**For this whole section, just reference the lines for the cleaning program to find where to put the files

**FAOSTAT Area Harvested, Yield, and Production Quantity Data
	//This uses data taking the following indicators under Crops from FAOSTAT (http://www.fao.org/faostat/en/#data)
	// Countries: Select all (Used: Benin  Botswana  Burkina Faso  Burundi Cabo Verde  Cameroon Central African Republic  Chad  Congo Côte d'Ivoire Democratic Republic of the Congo Eritrea  Ethiopia  Gabon Gambia  Ghana  Guinea  Guinea-Bissau Kenya  Lesotho  Liberia  Madagascar Malawi  Mali  Mauritania  Mauritius Mozambique  Namibia  Niger  Nigeria Rwanda  Senegal  Sierra Leone Swaziland  Togo  Uganda United Republic of Tanzania  Zambia Zimbabwe )
	// Elements: Area Harvested, Yield, Production Quantity
	// Items: Select all (Used: Bambara beans  Bananas  Barley Beans, dry  Broad beans, horse beans, dry Buckwheat  Cassava  Castor oil seed Chick peas  Coconuts  Cotton lint Cottonseed  Cow peas, dry  Fonio Groundnuts, with shell  Kapok fruit Karite nuts (sheanuts)  Lentils  Linseed Lupins  Maize  Maize, green  Melonseed Millet  Mustard seed  Oats  Oil, palm Oil, palm fruit  Oilseeds nes  Palm kernels Peas, dry  Pigeon peas  Plantains Potatoes  Pulses, nes  Rapeseed Rice, paddy  Roots and tubers, nes  Rye Safflower seed  Seed cotton  Sesame seed Sorghum  Soybeans  Sunflower seed Sweet potatoes  Taro (cocoyam) Tobacco, unmanufactured  Tung nuts Wheat Yams)
	// Years: 2014
	// Name: FAOSTAT_2014_Data_Harvest_Production_Yield3.csv
	
**FAOSTAT Gross Net Production Value
	// Take from Value of Agricultural production
	//Countries: Select all
	//Elements: Net Production Value constant 2004_2006 1000 I, Gross Production Value constant 2004_2006 1000 I, Gross Production Value current million US, Gross Production Value constant 2004_2006 million US
	//Items: Select All
	//Years: 2014
	//Name: FAOSTAT_2014_Gross_Net_Production_Value.csv
	
**FAOSTAT Population
	//Take from Annual population
	//Countries: Select All
	//Elements: Select All
	//Items: Population - Est. & Proj.
	// Years: 2014
	// Name: FAOSTAT_2014_Population.csv
	
**FAOSTAT GDP
	//Take from macro indicators
	//Countries: Select all
	//Elements: Value US$
	//Items: Gross Domestic Product Value Added (Agriculture, Forestry and Fishing)
	//Years: 2014
	// Name: FAOSTAT_2014_GDP.csv
	
**FAOSTAT FDI
	//Take from foreign Direct Investment (FDI)
	//Countries: Select All
	//Elements: Value US$
	//Items: FDI Inflows to Africulture, Forestry and Fishing Total FDI Inflows
	//Years: 2014
	//Name: FAOSTAT_2014_FDI.csv
	
**FAOSTAT Development Flows to Agriculture
	//Take from Development Flows to Agriculture
	//Donors: All Donors + (Total)  Bilateral Donors + (Total) Multilateral Donors + (Total) Private Donors + (Total) 
	//Recipients: Select all
	//Elements: Value US$
	//Items: Disbursment + (Total)
	//Purpose: Agricultural research Agriculture + Total
	//Years: 2014
	//Name: FAOSTAT_2014_Foreign_Aid_Flows.csv
	
**FAOSTAT Ag Expenditure
	//Take from Government Expenditure
	//Countries: Select All
	//Elements: Value $US
	//Items: Agriculture, Forestry, Fishing (General Government)
	//Years: 2014
	//Name: FAOSTAT_2014_Ag_Expenditures.csv
	
**FAOSTAT Export Value
	//Take from Crop and Livestock Products
	//Countries: Select All
	//Elements: Export Quantity, Export Value
	//Items: Select all
	//Years: 2013 (2014 NOT YET AVAILABLE)
	//Name: FAOSTAT_2013_Export.csv


clear
fullfaostat //This can be commented out once it if run once because it takes a long time to run. This program takes the FAOSTAT .csv files and creates .dta files which are faster to access. ~WAVE~


**IMPORTING FROM FULL FAOSTAT DATA
clear

//Run cleaning Program on FAOSTAT Data

//Harvest Production Yield // LIVESTOCK
use "$savespace\Production_LivestockPrimary_E_All_Data_(Normalized).dta"
keep if element == "Production" & unit == "tonnes" //drops out units which can't be compared to crops
append using "$savespace\Production_Crops_E_All_Data_(Normalized).dta"
qui foreach k in $otheryearsfaostat {
drop if year == `k'
}
generate domaincode = "QC"
drop if element == "Seed"
FSclean
save "$merge\FAOSTAT_${faostatyear}_Data_Harvest_Production_Yield.dta", replace

//Gross Net Production Value
clear
use "$savespace\Value_of_Production_E_All_Data_(Normalized).dta"
qui foreach k in $otheryearsfaostat {
drop if year == `k'
}
generate domaincode = "QV"
drop if element == "Gross Production Value (constant 2004-2006 million SLC)"
drop if element == "Gross Production Value (current million SLC)"
FSclean
save "$merge\FAOSTAT_${faostatyear}_Gross_Net_Production_Value.dta",replace

//Population
clear
use "$savespace\Population_E_All_Data_(Normalized).dta"
qui foreach k in $otheryearsfaostat {
drop if year == `k'
}
generate domaincode = "OA"
FSclean
save "$merge\FAOSTAT_${faostatyear}_Population.dta", replace

//GDP
clear
use "$savespace\Macro-Statistics_Key_Indicators_E_All_Data_(Normalized).dta"
qui foreach k in $otheryearsfaostat {
drop if year == `k'
}
generate domaincode = "MK"
keep if (item == "Gross Domestic Product"|item == "Value Added (Agriculture, Forestry and Fishing)")
keep if element == "Value US$"
FSclean
save "$merge\FAOSTAT_${faostatyear}_GDP.dta", replace

//FDI
clear
use "$savespace\Investment_ForeignDirectInvestment_E_All_Data_(Normalized).dta"
generate domaincode = "FDI"
keep if element == "Value US$"
qui foreach k in $otheryearsfaostat {
drop if year == `k'
}
FSclean
keep if (item == "Total_FDI_inflows"|item == "FDItoAgFoFish")
save "$merge\FAOSTAT_${faostatyear}_FDI.dta", replace

//Foreign Aid Flows
clear
use "$savespace\Development_Assistance_to_Agriculture_E_All_Data_(Normalized).dta"
foreach k in $otheryearsfaostat {
drop if year == `k'
}
generate domaincode = "EA"
rename recipientcountry area
keep if (item == "Disbursement" & element == "Value US$" &(donor == "All Donors"|donor == "Bilateral Donors"|donor == "Multilateral Donors"|donor == "Private Donors")&(purpose=="Agricultural research"|purpose=="Agriculture"))
FSclean
save "$merge\FAOSTAT_${faostatyear}_Foreign_Aid_Flows.dta",replace

//Agriculture Expenditures
clear
use "$savespace\Investment_GovernmentExpenditure_E_All_Data_(Normalized).dta"
qui foreach k in $otheryearsfaostat {
drop if year == `k'
}
keep if element == "Value US$"
generate domaincode = "IG"
FSclean
keep if item == "GovExpenditureAgFoFish"
save "$merge\FAOSTAT_${faostatyear}_Ag_Expenditures.dta", replace

//Export Quantity and Value
//There are other areas which need to be made to separate on whether or not we have the data. They will be marked with: ~EXPORT~
clear
use "$savespace\Trade_Crops_Livestock_E_All_Data_(Normalized).dta"
qui foreach k in $otheryearsfaostat {
drop if year == `k'
}
generate domaincode = "TP"
FSclean
save "$merge\FAOSTAT_${faostatyear}_Export.dta", replace


//Annual Producer Prices ~ADD
clear
use "$savespace\Prices_E_All_Data_(Normalized).dta"
qui foreach k in $otheryearsfaostat {
drop if year == `k'
}
generate domaincode = "PP"
FSclean
save "$merge\FAOSTAT_${faostatyear}_Annual_Prices.dta", replace

//Producer Price Index ~ADD
clear
use "$savespace\Price_Indices_E_All_Data_(Normalized).dta"
qui foreach k in $otheryearsfaostat {
drop if year == `k'
}
generate domaincode = "PI"
FSclean
save "$merge\FAOSTAT_${faostatyear}_Price_Index.dta", replace


//Food Supply Crops Primary Equivalent ~ADD // ~LIVESTOCK
clear
use "$savespace\FoodSupply_Crops_E_All_Data_(Normalized).dta"
append using "$savespace\FoodSupply_LivestockFish_E_All_Data_(Normalized).dta"
qui foreach k in $otheryearsfaostat {
drop if year == `k'
}
generate domaincode = "CC"
FSclean
save "$merge\FAOSTAT_${faostatyear}_Food_Supply.dta", replace


//Food Balance Sheets ~ADD
clear
use "$savespace\FoodBalanceSheets_E_All_Data_(Normalized).dta"
qui foreach k in $otheryearsfaostat {
drop if year == `k'
}
generate domaincode = "FBS"
FSclean
drop if item == "Population"
replace element = "FBS" + element
replace element = subinstr(element, " ", "",.)
save "$merge\FAOSTAT_${faostatyear}_Food_Balance.dta", replace


//Commodity Balance Sheets ~ADD // ~LIVESTOCK
clear
use "$savespace\CommodityBalances_Crops_E_All_Data_(Normalized).dta"
append using "$savespace\CommodityBalances_LivestockFish_E_All_Data_(Normalized).dta"
qui foreach k in $otheryearsfaostat {
drop if year == `k'
}
generate domaincode = "BC"
FSclean
replace element = "CB" + element
replace element = subinstr(element, " ", "",.)
save "$merge\FAOSTAT_${faostatyear}_Commodity_Balance.dta", replace


******************************************************************************
** 			                3. Merge DTA Files   		            		**
******************************************************************************
////////////////////////////////////////
//   3.1 Create Aggregation Profile   //
////////////////////////////////////////
//// To make aggregation easier, we are going to use a file to create lists how different parts of FAOSTAT aggregate different variables
	** This code makes a global list for each crop and aggregation set named agg1crop1 etc.  this list includes all of the FAOSTAT crop names withou space or special characters
	**These will then be used to run an aggregation program on all of the FAOSTAT data.

clear
import excel "$GPGcategorizations\GPG Correlates_Crop-Level Data Decisions FAOSTAT.xlsx", sheet("Trade - Crops and Livestock") firstrow
//import excel "R:\Project\EPAR\Working Files\RA Working Folders\Terry\339\GPG Correlates_Crop-Level Data Decisions FAOSTAT_MH.xlsx", sheet("Trade - Crops and Livestock") firstrow
replace item = subinstr(item, "$", "",.)
replace item = subinstr(item, "(", "",.)
replace item = subinstr(item, ")", "",.)
replace item = subinstr(item, ",", "",.)
replace item = subinstr(item, " ", "",.)
replace item = subinstr(item, "Ã©", "",.)
replace item = subinstr(item, "&", "",.)
replace item = subinstr(item, ".", "",.)
replace item = subinstr(item, "-", "",.)
replace item = subinstr(item, "+", "",.)

//global aggregationall AggCrops AggExport AggPricePP AggSupply AggFBalance AggCBalance AggPricePI AggValue
global numaggall : list sizeof global(aggregationall)
global cntaggall = $numaggall + 1
//There are two issues we are trying to resolve.  Taking out 4 categories which are the same for aggregation and not aggregation.  And addressing categories which have the same name after the above recoding is done...
forvalues k = 1(1)$numaggall {
global taggname : word `k' of $aggregationall
replace $taggname = "1" if $taggname == "x"
replace $taggname = "0" if $taggname == "y"
destring $taggname, replace
}
collapse (max) Agg* , by (item ASTISubCategory CropCategory)

save "$merge\Aggregation.dta", replace

global i = 1 //7
global ii = 1 //19

while $i < $cntaggall {
while $ii < $cntasticrops {
clear
use "$merge\Aggregation.dta"
global taggname : word $i of $aggregationall
global tcropname : word $ii of $crpall
keep if (ASTISubCategory == "$tcropname" & $taggname == 1)
global iii = _N
if $iii > 0 {
forvalues k = 1(1)$iii {
global tcname = item[`k']
global agg${i}crop${ii} : list global(agg${i}crop${ii}) | global(tcname)
display "${agg${i}crop${ii}}"
}
}
global ii = $ii +1
}
global ii = 1
global i = $i + 1
}

////////////////////////////////////////
//   3.2 Run Aggregation Program	  //
////////////////////////////////////////

//ASTI and FAOSTAT categorize crops differently.  
	**This section sorts the FAOSTAT categories into the different categories according to the file below
	** R:\Project\EPAR\Working Files\339 - Funding for Ag R&D Public Goods\Data Analysis\GPGs Correlates - Crop-Level Data Decisions - FINAL.docx

//Data_Harvest_Production_Yield (1QC) Gross_Net_Production_Value (8QV) Export (2TP) Annual_Prices (3PP) Price_Index (7PI) Food_Supply (4CC) Food_Balance (5FBS) Commodity_Balance (6BC)

global i=1 //This global counts countries

while $i< $cntcountry {
	forvalues k = 1(1)8 {
		global tfilename : word `k' of $filestosort
		global tdomaincode : word `k' of $domaincodessort
		global tnumdomaincode : list sizeof global(domain${tdomaincode}elements)
		global average = 0 
		if "$tdomaincode" == "PP"|"$tdomaincode" == "PI" {
			global average = 1 
		}
		forvalues kk = 1(1)$tnumdomaincode {
			global tdomainelement : word `kk' of ${domain${tdomaincode}elements}
			use "$merge\FAOSTAT_${faostatyear}_${tfilename}.dta", clear
			qui AggALL $i `kk' `k' $average
			if "`kk'" == "1" & "`k'" == "1" {
				keep item year  
				save "$merge\FAOSTAT_${faostatyear}_${c$i}.dta", replace
			}
			if "`kk'" != "1" | "`k'" != "1" {
				use "$merge\FAOSTAT_${faostatyear}_${c$i}.dta", clear
				merge 1:1 item year using "$merge\Disaggregated\Y${faostatyear}_${c$i}_${tdomainelement}.dta", nogen
				save "$merge\FAOSTAT_${faostatyear}_${c$i}.dta", replace
			}
		}
	}
	global i = $i + 1
}


//In this section the country files remain separate.  
//This was done initially to make it easier to check each step of the way that the data was being merged in correctly, and to make the data easier to manipulate

////////////////////////////////////////
//      3.3 Merge ASTI FTE Data       //
////////////////////////////////////////

//Flip ASTI data and merge it with FAOSTAT data
	**As it stands now, each of the crops in the ASTI data is a separate variable.
	**We want to change that to make one variable "Crops" which distinguishes between crops, and FTEs,  The following loop does this
	
global i = 1	//This global counts countries	
qui while $i < $cntcountry {
	clear
	use "$merge\Y${astiyear}_FTEs_Flipped.dta"
	unab researchvarsl: researcherstotal*
	global researchvars `researchvarsl'
	reshape long researcherstotal@, i(country) j(item_var) string
	gen item = "Is Missing"
	forvalues k = 1(1)$numasticrops {
		global tcrpvarname : word `k' of $crpvarshort
		global tcrpname : word `k' of $crpall
		replace item = "$tcrpname" if item_var == "$tcrpvarname"
	}
	drop item_var
	keep if country == "${c$i}"
	merge 1:m item using "$merge\FAOSTAT_${faostatyear}_${c$i}.dta", nogen //  This line merges the data into each country file
	save "$merge\Countries\Y${faostatyear}_${c$i}.dta", replace
	global i = $i + 1	
}

////////////////////////////////////////
//  3.4 Merge in Countrywide Totals   //
////////////////////////////////////////

global i=1 //This global counts countries                                      
//This loop merges in the spending and non crop specific FTE data to each of the countries,
while $i < $cntcountry {
	clear
	//Spending data
	use "$merge\ASTI_Unmerged\Y${astiyear}_Spending.dta"
	keep if country == "${c$i}"
	merge 1:m country using "$merge\Countries\Y${faostatyear}_${c$i}.dta", nogen
	save "$merge\Countries\Y${faostatyear}_${c$i}.dta", replace
	
	//Non-Crop Specific FTE Data
	use "$merge\ASTI_Unmerged\Y${astiyear}_FTEs_Flipped_Total.dta"
	rename year astiyear
	keep if country == "${c$i}"
	merge 1:m country using "$merge\Countries\Y${faostatyear}_${c$i}.dta", nogen
	save "$merge\Countries\Y${faostatyear}_${c$i}.dta", replace
	
	global i= $i +1
}

global numcountrywide : list sizeof global(domaincodescountry)
//set trace on
global i=1 //This global counts countries    
while $i < $cntcountry {
	forvalues kk = 1(1)$numcountrywide {
		global tfilename : word `kk' of $filesatcountry
		global tdomaincode : word `kk' of $domaincodescountry
		global tnumelements : list sizeof global(domain${tdomaincode}elements)
		
		forvalues kkkk = 1(1)$tnumelements {
			use "$merge\FAOSTAT_${faostatyear}_${tfilename}.dta", clear
			global telementcode : word `kkkk' of ${domain${tdomaincode}elements}
			if "$tdomaincode" == "MK" | "$tdomaincode" == "FDI" | "$tdomaincode" == "IG" {
				drop element
				rename item element
			}
			rename area country
			keep if country == "${c$i}"
			keep if element == "$telementcode"
			local newelement = subinstr("$telementcode"," ","_",.)
			keep country value year
			capture rename value `newelement'
			merge 1:m country year using "$merge\Countries\Y${faostatyear}_${c$i}.dta", nogen
			save "$merge\Countries\Y${faostatyear}_${c$i}.dta", replace
		}
	}
	global i= $i +1
}
//////////////////////////////////////////////////////////////////////////////
// 			            4. Creating Final Output		            		//
//////////////////////////////////////////////////////////////////////////////

***************************************
**  4.1 Merge Countries Together    **
***************************************
//This merges the countries all together into a Full Dataset
clear
global i=2 //This global counts countries
use "$merge\Countries\Y${faostatyear}_${c1}.dta"
qui while $i < $cntcountry {
	append using "$merge\Countries\Y${faostatyear}_${c$i}.dta"
	global i = $i + 1
}
save "$merge\Full_Dataset.dta",replace

***************************************
**   4.2 Separate Crop Categories    **
***************************************
//We want to be able to compare crops by category as well as across crops. 
	**This section adds a new variable: crop_market_cat which divides the crops by their category
	**Then it renames some long variable names for totaling
clear
use "$merge\Full_Dataset.dta"

//CLEANING //rename long variable names
rename researcherstotalftesper100000far FTEsper100000far
rename researcherstotalftespermillionpo FTEspermillionpo
rename item crop
rename researcherstotal FTEs
drop area element value itemcode domaincode
save "$merge\Full_Dataset.dta",replace


//Adding an "Unspecified" option for FTEs
drop if crop!="Bananas and Plantains"
replace crop = "Unspecified"
foreach k of varlist FTEs Production-GPV_con_04_06_million_US { //loop used because too many variables for replace
replace `k'=. 
}
append using "$merge\Full_Dataset.dta"

bys country: egen specified_FTEs = sum(FTEs)
g unspecificed_FTEs = researcherstotalftes - specified_FTEs
replace unspecificed_FTEs = 0 if unspecificed_FTEs<0 //some small rounding errors
replace FTEs = unspecificed_FTEs if crop == "Unspecified"
drop unspecificed_FTEs

//Grouping crops into broad categories
generate crop_market_cat = "Commodity Grains" if (((crop == "Barley"|(crop == "Maize")|(crop == "Rice"))| crop =="Wheat"))
replace crop_market_cat = "Orphan Crops" if (crop == "Bananas and Plantains"| /*
*/ (crop == "Beans"|(crop == "Groundnuts"|(crop == "Other Cereals" |(crop == "Other Pulses"| /*
*/ (crop == "Other Roots and Tubers" |(crop == "Potatoes" |(crop == "Sorghum" |crop == "Nuts"))))))))
replace crop_market_cat = "Other Market-Oriented Crops" if (crop == "Soybeans"|(crop == "Coconut Palm"|(crop == "Cotton"| /*
*/ (crop == "Oil Palm" |(crop== "Other Oil-Bearing Crops" |(crop=="Tobacco"))))))
replace crop_market_cat = "Livestock & Fisheries" if crop == "Cattle No Dairy" | crop == "Dairy" |crop == "Sheep and Goats" |crop == "Poultry" /*
*/ | crop == "Other Animals" | crop == "Inland Fisheries" |crop == "Marine Fisheries"|crop == "Pastures and Forages"
replace crop_market_cat = "Non Commodity Specific Researchers" if crop == "Natural Resources" | crop == "Socioeconomics" | crop == "On Farm Postharvest" /*
*/ | crop == "Ag Engineering" |crop == "Other Commodities"|crop == "Forestry"|crop == "Unspecified"
replace crop_market_cat = "Other Fruits and Vegetables" if crop == "Other Fruits" | crop == "Vegetables"
replace crop_market_cat = "Other Market-Oriented Crops" if crop == "Flowers" |crop == "Other Crops"

//More specific categories:
generate crop_market_cat_detail = crop_market_cat
replace crop_market_cat_detail = "Livestock" if crop == "Cattle No Dairy" | crop == "Dairy" |crop == "Sheep and Goats" |crop == "Poultry" /*
*/ | crop == "Other Animals" | crop == "Pastures and Forages"
replace crop_market_cat_detail = "Fisheries" if crop == "Inland Fisheries" | crop == "Marine Fisheries"
replace crop_market_cat_detail = "Forestry and Natural Resources" if crop == "Forestry" | crop == "Natural Resources"
replace crop_market_cat_detail = "Ag Engineering and On Farm Postharvest" if crop == "Ag Engineering" | crop == "On Farm Postharvest"
replace crop_market_cat_detail = "Other Commodities" if crop == "Other Commodities"
replace crop_market_cat_detail = "Socioeconomics" if crop == "Socioeconomics"
replace crop_market_cat_detail = "Unspecified" if crop == "Unspecified"

//Dealing with Missing Values

foreach k of varlist FTEs Production-GPV_con_04_06_million_US  {
bys country : egen T`k' = total(`k')
replace `k' =. if T`k'== 0
drop T`k'
}

***************************************
** 4.3 Separate Regional Categories  **
***************************************
//These regional classifications are based on the UN geoscheme maintained by the UNSD (with the exception of Sudan which is categorized as North Africa, but here is listed as East Africa since we have no other data from north Africa)

generate Region_UNSD = "Western Africa" if country=="Benin"|country=="Burkina Faso"|country=="Cabo Verde"|country=="Cote d'Ivoire"/*
*/|country=="Gambia, The"|country=="Ghana"|country=="Guinea"|country=="Guinea-Bissau"|country=="Liberia"|country=="Mali"/*
*/|country=="Mauritania"|country=="Nigeria"|country=="Senegal"|country=="Sierra Leone"|country=="Togo"|country=="Niger"

replace Region_UNSD = "Eastern Africa" if country=="Burundi"|country=="Eritrea"|country=="Ethiopia"|country=="Kenya"/*
*/|country=="Madagascar"|country=="Malawi"|country=="Mauritius"|country=="Mozambique"|country=="Rwanda"/*
*/|country=="Sudan"|country=="Uganda"|country=="Tanzania"|country=="Zambia"|country=="Zimbabwe"


replace Region_UNSD = "Southern Africa" if country=="Botswana"|country=="Lesotho"|country=="Namibia"/*
*/|country=="South Africa"|country=="Swaziland"

replace Region_UNSD = "Central Africa" if country=="Central African Rep."|country=="Chad"|country=="Congo, Dem. Rep."/*
*/|country=="Gabon"|country=="Congo, Rep."|country=="Cameroon"

***************************************
**   4.4 Generate Final Variables    **
***************************************

//Generating New Variables
generate spendingperFTEmill2011 = sptmillionconstant2011/researcherstotalftes
generate spendperGovFTEmill2011 = sptmillionconstant2011/GovResearchers
generate FTEsbyGDP = FTEs/Gross_Domestic_Product
generate FTEsbypop = FTEs/TotalPopulation
generate CropPercentFTEs = FTEs/researcherstotalftes
generate spendperFTEcropmill2011 = sptmillionconstant2011/FTEs

//generate faostat_year = $faostatyear
rename year faostat_year
generate asti_year = $astiyear
sort country crop
order country Region_UNSD faostat_year asti_year
order crop_market_cat, after(crop)

save "$output\Y${faostatyear}_Tableau_Data.dta",replace
export excel using "$output\Y${faostatyear}_Tableau_Data.xls", sheetreplace firstrow(variables)
