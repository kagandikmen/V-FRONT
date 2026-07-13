# QuestaSim run.do Script
# Created:      2026-07-13
# Modified:     2026-07-13
# Author:       Kagan Dikmen

file mkdir $BUILD_DIR

if {[file exists $BUILD_DIR/work]} {
    vdel -lib $BUILD_DIR/work -all
}

vlib $BUILD_DIR/work
vmap work $BUILD_DIR/work

vlog {*}$INCLUDE -f $FLIST {*}$TBLIST

vsim -voptargs=+acc \
    -wlf $BUILD_DIR/vsim.wlf \
    -g MEM_INIT_FILE=\"$MEMFILE\" \
    -g RESET_ADDR=$RESET_ADDR \
    work.$TOP

# log all signals from the start
log -r /*

if {![batch_mode]} {
    add wave -r /*
}

run -all
