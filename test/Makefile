# Compile utils first
VHDL_SOURCES = $(PWD)/../utils.vhd \
                $(PWD)/../ALU.vhd \
                $(PWD)/../ALU_MUL.vhd \
                $(PWD)/../arbiter.vhd \
                $(PWD)/../bypass_unit.vhd \
                $(PWD)/../cache_data.vhd \
                $(PWD)/../cache_inst.vhd \
                $(PWD)/../cache_stage.vhd \
                $(PWD)/../cache_tags.vhd \
                $(PWD)/../comp_28bits.vhd \
                $(PWD)/../decode.vhd \
                $(PWD)/../detention_unit.vhd \
                $(PWD)/../fetch.vhd \
                $(PWD)/../inkel_pentiun.vhd \
                $(PWD)/../lookup_stage.vhd \
                $(PWD)/../memory.vhd \
                $(PWD)/../mux2_1.vhd \
                $(PWD)/../mux2_32bits.vhd \
                $(PWD)/../mux4_32bits.vhd \
                $(PWD)/../Mux_2_3bits.vhd \
                $(PWD)/../pc.vhd \
                $(PWD)/../ram.vhd \
                $(PWD)/../reg_AL.vhd \
                $(PWD)/../reg_bank.vhd \
                $(PWD)/../reg_CW.vhd \
                $(PWD)/../reg_DA.vhd \
                $(PWD)/../reg_FD.vhd \
                $(PWD)/../reg_LC.vhd \
                $(PWD)/../reg_status.vhd \
                $(PWD)/../sign_ext.vhd \
                $(PWD)/../Switch_UD.vhd
TOPLEVEL = inkel_pentiun
MODULE = test_inkel_pentiun

COCOTB = /home/markmb/vhdl/cocotb

include $(COCOTB)/makefiles/Makefile.inc
include $(COCOTB)/makefiles/Makefile.sim
