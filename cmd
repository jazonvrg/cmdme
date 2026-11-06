set PDK /data/loadtest-eda-design/INNOVUS/DESIGN/GPDK
set MAC /data/thithietkevmbd/home/competitor01/pd_metro_card/macro_PLACEHOLDER/v2
set RUN [pwd]
foreach {c v t} {slow 1.08 125.0 fast 1.32 0.0} {
    create_library_set -name PH_${c}_libs -timing [list $PDK/LIBS/GPDK045/timing/$c.lib $MAC/sram_placeholder_$c.lib $RUN/pad_model.lib]
    create_opcond -name PH_${c}_opcond -process 1.0 -voltage $v -temperature $t
    create_timing_condition -name PH_${c}_tc -opcond PH_${c}_opcond -library_sets [list PH_${c}_libs]
    create_rc_corner -name PH_${c}_rc -temperature $t -qrc_tech $PDK/TECH/qrcTechFile -cap_table $PDK/TECH/capTable
    create_delay_corner -name PH_${c}_dc -early_timing_condition [list PH_${c}_tc] -late_timing_condition [list PH_${c}_tc] -early_rc_corner PH_${c}_rc -late_rc_corner PH_${c}_rc
    create_analysis_view -name PH_${c}_view -constraint_mode PH_func -delay_corner PH_${c}_dc
}
set_analysis_view -setup {PH_typ_view PH_slow_view PH_fast_view} -hold {PH_typ_view PH_slow_view PH_fast_view}
set_db extract_rc_coupled true
set_db delaycal_enable_si true
extract_rc
foreach v {PH_typ_view PH_slow_view PH_fast_view} {
    report_timing -view $v -max_paths 1 > reports/sta_${v}_setup.rpt
    report_timing -view $v -early -max_paths 1 > reports/sta_${v}_hold.rpt
}
foreach f [lsort [glob reports/sta_PH_*.rpt]] { catch {exec grep -m1 "Path 1:" $f} o; puts "$f : $o" }
