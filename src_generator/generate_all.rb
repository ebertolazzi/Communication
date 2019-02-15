#!/usr/bin/env ruby

require 'pp'
require 'erubis'
require 'yaml'
require 'fileutils'
require "./serialize.rb"

data = YAML.load_file("./signalmap.yaml")

tag = :Header
sep = "\n\n\n\n\n"

puts to_print(tag,data[tag])+sep
puts to_buffer(tag,data[tag])+sep
puts from_buffer(tag,data[tag])+sep
puts to_C_struct(tag,data[tag])+sep
puts to_MATLAB_struct(tag,data[tag])+sep
puts to_SIMULINK_struct(tag,data[tag])+sep
puts to_SIMULINK_busInfo(tag,data[tag])+sep
puts to_SIMULINK_busInfo_in_data(tag,data[tag])+sep
puts to_SIMULINK_busInfo_in_data_rtw(tag,data[tag])+sep
puts to_SIMULINK_message(tag,data[tag])+sep
puts simulink_to_buffer(tag,data[tag])+sep
puts simulink_from_buffer(tag,data[tag])+sep
puts simulink_set_output_signal(tag,data[tag])+sep
puts simulink_set_input_signal(tag,data[tag])+sep











