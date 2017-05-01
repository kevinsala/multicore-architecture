# Compile utils first
VHDL_SOURCES = $(PWD)/../utils.vhd \
                $(PWD)/../ALU.vhd \
                $(PWD)/../ALU_MUL_seg.vhd \
                $(PWD)/../arbiter.vhd \
                $(PWD)/../bypass_unit.vhd \
                $(PWD)/../cache_data.vhd \
                $(PWD)/../cache_inst.vhd \
                $(PWD)/../cache_stage.vhd \
                $(PWD)/../comp_28bits.vhd \
                $(PWD)/../decode.vhd \
                $(PWD)/../detention_unit.vhd \
                $(PWD)/../exception.vhd \
                $(PWD)/../fetch.vhd \
                $(PWD)/../inkel_pentiun.vhd \
                $(PWD)/../memory.vhd \
                $(PWD)/../mux2_32bits.vhd \
                $(PWD)/../mux4_32bits.vhd \
                $(PWD)/../mux8_32bits.vhd \
                $(PWD)/../Mux_2_3bits.vhd \
                $(PWD)/../pc.vhd \
                $(PWD)/../ram.vhd \
                $(PWD)/../reg_AC.vhd \
                $(PWD)/../reg_bank.vhd \
                $(PWD)/../reg_DA.vhd \
                $(PWD)/../reg_FD.vhd \
                $(PWD)/../reg_MUL.vhd \
                $(PWD)/../reg_priv_status.vhd \
                $(PWD)/../reg_status.vhd \
                $(PWD)/../reg_W.vhd \
                $(PWD)/../rob.vhd \
                $(PWD)/../sign_ext.vhd \
                $(PWD)/../store_buffer.vhd
TOPLEVEL = inkel_pentiun
MODULE = test_inkel_pentiun

COCOTB = ./cocotb
SIM = ghdl

GHDL_ARGS = --ieee=synopsys -fexplicit

include $(COCOTB)/makefiles/Makefile.inc
include $(COCOTB)/makefiles/Makefile.sim
