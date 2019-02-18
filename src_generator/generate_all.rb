#!/usr/bin/env ruby

require 'pp'
require 'erubis'
require 'yaml'
require 'fileutils'
require "./serialize.rb"

data = YAML.load_file("./signalmap.yaml")

sep = "\n\n\n\n\n"

data.keys.each do |tag|
  if tag != :origin_file and tag != :main_topic then
    value = data[tag];
    puts to_print( tag, value )+sep
    puts to_buffer( tag, value )+sep
    puts from_buffer( tag, value )+sep
    puts to_C_struct( tag, value )+sep
    puts to_MATLAB_struct( tag, value )+sep
    puts to_SIMULINK_struct( tag, value )+sep
    puts to_SIMULINK_busInfo( tag, value )+sep
    puts to_SIMULINK_busInfo_in_data( tag, value )+sep
    puts to_SIMULINK_busInfo_in_data_rtw( tag, value )+sep
    puts to_SIMULINK_message( tag, value )+sep
    puts simulink_to_buffer( tag, value )+sep
    puts simulink_from_buffer( tag, value )+sep
    puts simulink_set_output_signal( tag, value )+sep
    puts simulink_set_input_signal( tag, value )+sep
    puts to_mqtt_topic( tag, data )+sep
  end
end
