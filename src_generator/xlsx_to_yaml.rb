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

$workbook_data = {}
$last_struct   = {}

workbook = RubyXL::Parser.parse(conf.input_file_name+".xlsx")

workbook.worksheets[0].each_with_index do |data_row,lineNumber|
  row = [];
  data_row && data_row.cells.each { |cell|
    val = cell && cell.value
    row << val;
  }
  case lineNumber
  when 0
    #  ___             __
    # | _ \_____ __ __/  \
    # |   / _ \ V  V / () |
    # |_|_\___/\_/\_/ \__/
    #
    version    = data_row[0].value
    main_topic = data_row[1].value
    puts "MAIN TOPIC=#{main_topic} #{version}"
  when 1
    #  _  _             _
    # | || |___ __ _ __| |___ _ _
    # | __ / -_) _` / _` / -_) '_|
    # |_||_\___\__,_\__,_\___|_|
    #
    # Select the column indexes of each field
    tmp = []
    conf.columns_map.each do |item|
      n = item[0];
      k = item[1];
      tmp << n;
      idx = row.index(n)
      if idx then
        columns_to_idx[k] = idx
        puts "Mapped column \##{idx} to `#{n}`".green
      else
        puts "Missing column `#{n}` in header".red
      end
    end
    row.each_with_index do |item,icol|
      idx = tmp.index(item)
      if not idx then
        puts "Column \##{icol} with field `#{item}` not mapped".yellow
      end
    end
  else
    #     _      _
    #  __| |__ _| |_ __ _
    # / _` / _` |  _/ _` |
    # \__,_\__,_|\__\__,_|
    #
    # Create the input and manoeuvre messages
    begin
      # Scenario message
      if row[columns_to_idx[:name]] then
        data = {}
        conf.columns_map.each do |item|
          n   = item[0];
          k   = item[1];
          idx = columns_to_idx[k];
          if idx then
            data[k] = row[idx].to_s;
          else
            data[k] = "MISSING";
          end
        end
        columns << data;
      end
    rescue => e
      puts "skipping unmappable row `#{e}`".red
      # skipping unmappable row
    end
    begin
      case data[:yes_no_x]
      when 'yes' || 'no'
        if $last_struct[:active] then
          tmp = {
            :fields      => $last_struct[:fields],
            :subtopic    => $last_struct[:subtopic]
          };
          tmp[:subsubtopic] = $last_struct[:subsubtopic] if $last_struct[:subsubtopic]
          $workbook_data[ $last_struct[:struct_name] ] = tmp;
        end
        $last_struct               = {};
        $last_struct[:struct_name] = data[:name];
        $last_struct[:active]      = data[:yes_no_x] == 'yes';
        m = data[:description_subtopic].match(/^(.*)\/\#\{(.*)\}$/)
        if m then
          $last_struct[:subtopic]    = m[1];
          $last_struct[:subsubtopic] = m[2];
        else
          $last_struct[:subtopic] = data[:description_subtopic];
        end

        $last_struct[:fields] = [];

      when 'x'
        data.delete_if { |key, value| !conf.for_structs.include? key }
        $last_struct[:fields] << data;
      when ''
        puts "NO DATA=#{data[:name]}".cyan
      end
    rescue => e
      puts "skipping row `#{lineNumber}` due to `#{e}`".yellow
    end
  end
end

# Write yaml file
# Delete old files in temporary folder (if present)
FileUtils.rm_f conf.yaml_file_name
File.open( conf.yaml_file_name + ".yaml", 'w' ) do |f|
  f.write($workbook_data.to_yaml(:Indent => 8))
end

puts "File #{conf.yaml_file_name}.yaml generated"
puts "--------------------------------------"
