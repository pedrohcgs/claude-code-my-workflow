* ============================================================================
* Fertilizer Quality in Kenya --- path configuration
* ============================================================================
* $root must be set before calling this file (master.do sets it, or set
* it manually: global root "C:/git/fake-fertilizer")

clear all
set more off

* --- Derived paths (all flow from $root) ---
global project  "$root/project"
global data     "$project/data"
global input    "$data/build/input"
global analysis "$root/analysis"
global code     "$analysis/code"
global output   "$analysis/output"
global temp     "$analysis/temp"
global figures  "$analysis/figures"
