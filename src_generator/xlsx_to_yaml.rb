#!/usr/bin/env ruby

require 'pp'
require 'yaml'
require 'fileutils'
require 'colorize'

require 'rubyXL'
require 'rubyXL/convenience_methods'

puts "----------- csv_importer.rb ----------"

if ARGV.size != 1 then
  raise ArgumentError, "usage: #{File.basename(__FILE__)} CONFIG.rb"
end

require_relative ARGV[0]

conf = Config.new

columns_to_idx = {}
columns        = []

objects   = { :in_struct => [], :out_struct => [] }
tot_bytes = { :in_struct => 0,  :out_struct => 0  }

# Open and read file: the ".csv" file is obtained from the ".xlsx" file 
# with "File -> Save as -> Format: "Common formats: Comma Separated Values (.csv)"
objects[:origin_file] = File.basename conf.input_file_name

puts conf.input_file_name

workbook = RubyXL::Parser.parse(conf.input_file_name+".xlsx")

workbook.worksheets[0].each_with_index do |data_row,lineNumber|
  row = [];
  data_row && data_row.cells.each { |cell|
    val = cell && cell.value
    row << val;
  }
  case lineNumber
  when 0 # Do nothing
  when 1 # Select the column indexes of each field
    tmp = []
    conf.columns_map.each do |item|
      n     = item[0];
      k     = item[1];
      tmp << n;
      idx = row.index(n)
      if idx then
        columns_to_idx[k] = idx
      else
        puts "Missing column `#{n}` in header".red
      end
    end
    row.each_with_index do |item,icol|
      idx = tmp.index(item)
      if not idx then
        puts "Column \##{icol} `#{item}` not mapped".yellow
      end
    end
  else
    # Create the input and manoeuvre messages
    begin
      # Scenario message
      if row[columns_to_idx[:name]] then
        out = {}
        conf.columns_map.each do |item|
          n   = item[0];
          k   = item[1];
          idx = columns_to_idx[k];
          if idx then
            out[k] = row[idx].to_s;
          else
            out[k] = "MISSING";
          end
        end
        columns << out;
      end
    rescue => e
      puts "skipping unmappable row `#{e}`".red
      # skipping unmappable row
    end
  end
end

# Write yaml file
# Delete old files in temporary folder (if present)
FileUtils.rm_f conf.yaml_file_name
File.open( conf.yaml_file_name + ".yaml", 'w' ) do |f|
  f.write(columns.to_yaml(:Indent => 8))
end

puts "File #{conf.yaml_file_name}.yaml generated"
puts "--------------------------------------"
