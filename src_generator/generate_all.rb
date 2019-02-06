#!/usr/bin/env ruby

require 'pp'
require 'erubis'
require 'yaml'
require 'fileutils'
require "./serialize.rb"

csv            = "./signal_map/Signal_Map.csv"
name           = "codriver"
base_name_sfun = name + "_interfaces_sfun"

system("ruby csv_importer.rb #{csv} #{name}")

data = YAML.load_file("./#{name}.yml")

input_data_struct  = data[:in_struct]
output_data_struct = data[:out_struct]

file = "#{name}_interfaces_data_structs"
context = {
  :file           => file,
  :name           => name,
  :base_name_sfun => base_name_sfun,
  :csv            => File.basename(csv),
  :input          => ['input_data_struct',input_data_struct],
  :output         => ['output_data_struct',output_data_struct],
  :n_input        => input_data_struct.size(),
  :input_size     => to_dim(input_data_struct),
  :n_outputs      => output_data_struct.size(),
  :output_size    => to_dim(output_data_struct),
}

FileUtils.mkdir_p "../src_matlab/"
FileUtils.mkdir_p "../src_udp/"

puts "generate #{file}.h"
input = File.read(file + '.h.tmpl')
eruby = Erubis::Eruby.new(input)    # or Erubis::XmlEruby
File.write( "../src_udp/" + file + '.h', eruby.evaluate(context) );

puts "generate #{file}.c"
input = File.read(file + '.c.tmpl')
eruby = Erubis::Eruby.new(input)
File.write( "../src_udp/" + file + '.c', eruby.evaluate(context) );

file = "#{base_name_sfun}_data_structs.h"
puts "generate #{file}"
input = File.read( file + '.tmpl' )
eruby = Erubis::Eruby.new(input)
File.write( "../src_matlab/" + file, eruby.evaluate(context) );

file = "#{name}_interfaces_matlab_data_structs.m"
puts "generate #{file}"
input = File.read(file + '.tmpl')
eruby = Erubis::Eruby.new(input)
File.write( "../src_matlab/" + file, eruby.evaluate(context) );


FileUtils.mkdir_p "../src_matlab/"
file = "sfun_bus_structs.h"
puts "generate #{file}"
input = File.read(file + '.tmpl')
eruby = Erubis::Eruby.new(input)
File.write( "../src_matlab/" + file, eruby.evaluate(context) );

file = "serializer.c"
puts "generate #{file}"
input = File.read(file + '.tmpl')
eruby = Erubis::Eruby.new(input)
File.write( "../src_matlab/" + file, eruby.evaluate(context) );

file = "udp_packet_creator.c"
puts "generate #{file}"
input = File.read(file + '.tmpl')
eruby = Erubis::Eruby.new(input)
File.write( "../src_matlab/" + file, eruby.evaluate(context) );

#file = "#{name}_interfaces_matlab_data_structs.m"
#puts "generate #{file}"
#input = File.read(file + '.tmpl')
#eruby = Erubis::Eruby.new(input)
#File.write( "../src_matlab/" + file, eruby.evaluate(context) );
