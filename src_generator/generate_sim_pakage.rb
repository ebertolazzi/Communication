#!/usr/bin/env ruby

require 'fileutils'

unitn_sim_package = "unitn_sim_package"

FileUtils.rm_rf   unitn_sim_package;
FileUtils.mkdir_p unitn_sim_package;

base = "../src_udp/"
out  = unitn_sim_package+"/src_udp"
FileUtils.mkdir_p out

FileUtils.cp base+"buffer_defines.h",                    out
FileUtils.cp base+"codriver_interfaces_data_structs.h",  out
FileUtils.cp base+"udp_C_class.h",                       out
FileUtils.cp base+"udp_defines.h",                       out
FileUtils.cp base+"codriver_interfaces_data_structs.c",  out
FileUtils.cp base+"udp_C_class.c",                       out
FileUtils.cp base+"udp_C_class.c",                       out
FileUtils.cp base+"udp_defines.c",                       out
FileUtils.cp base+"udp_hton.c",                          out
FileUtils.cp base+"udp_ntoh.c",                          out
FileUtils.cp base+"udp_C_unix.hxx",                      out
FileUtils.cp base+"udp_C_win.hxx",                       out
FileUtils.cp base+"udp_defines_unix.hxx",                out
FileUtils.cp base+"udp_defines_win.hxx",                 out

base = "../src_matlab/"
FileUtils.cp base+"serializer.c",                       unitn_sim_package
FileUtils.cp base+"udp_packet_creator.c",               unitn_sim_package

FileUtils.cp base+"compile_sfunction.m",                       unitn_sim_package
FileUtils.cp base+"init_test_serializer.m",                    unitn_sim_package
FileUtils.cp base+"codriver_interfaces_matlab_data_structs.m", unitn_sim_package

FileUtils.cp base+"codriver_input_data_struct_bus.mat",        unitn_sim_package
