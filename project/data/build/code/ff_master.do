* Fake fertilizer
* Master .do file

global dir "C:\Users\Emilia\Dropbox\Fake fertilizer\PEDL\data"
cd "$dir"

* log using "$dir/data/ff_master", replace

* run cleaning code
run "$dir/build/code/reshape_inputsurvey_fertilizerV2.do"
	* takes $dir\build\input\InputSurvey-fert_questions.csv, applies labels and some other cleaning
	* saves $dir/build\output/agrovet_survey_cleanish
		* formerly manufacturer_fertilizer 
	* saves $dir/build\output/agrovet_survey_gps  // with gps-data for variables within ranges 

* run cleaning code
run "$dir/build/code/mysteryshopping_import_clean.do"
	* takes "$dir\data\MysteryShopping.csv", applies labels and some other cleaning
	* merges on "$dir\data\label_ids.csv"
	* the above merge command adds on label_id
	* label_id is the correct id to merge with ICRAF lab data
	* creates expected nitrogen variable
	* saves "$dir\build/output\data\MysteryShopping_all.dta"

* run  "$dir/function/code/ff_stores_distance.do"
	* new version agrovet_survey_addvars in ATAI folder
	run agrovet_survey_addvars.do
	run agrovet_survey_addquality.do
	* generates variables of the number of stores within a certain distance of the current store
	* dummies for assets, etc.








