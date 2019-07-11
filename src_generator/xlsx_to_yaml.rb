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
#objects        = { :in_struct => [], :out_struct => [] }
#tot_bytes      = { :in_struct => 0,  :out_struct => 0  }

# Open and read file: the ".csv" file is obtained from the ".xlsx" file 
# with "File -> Save as -> Format: "Common formats: Comma Separated Values (.csv)"

puts conf.input_file_name

$workbook_data       = { :origin_file => File.basename(conf.input_file_name) }
$last_struct         = {}
$scenario_struct     = []
$manoeuvre_struct    = []
$sim_graphics_struct = []
$sim_state_struct    = []

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
    $workbook_data[:main_topic] = main_topic;
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
            data[k] = row[idx].to_s.chomp.gsub(/\s/,'_');
          else
            data[k] = "MISSING";
          end
        end
      end
    rescue => e
      puts "skipping unmappable row `#{e}`".red
      # skipping unmappable row
    end
    begin
      data1 = data.dup
      case data1[:yes_no_x]
      when 'yes', 'no'
        # save already stored structure
        if $last_struct[:struct_name] then
          puts "Save Struct #{$last_struct[:struct_name]}".green
          tmp = {
            :active   => $last_struct[:active],
            :fields   => $last_struct[:fields],
            :subtopic => $last_struct[:subtopic]
          };
          tmp[:subsubtopic] = $last_struct[:subsubtopic] if $last_struct[:subsubtopic]
          $workbook_data[ $last_struct[:struct_name].to_sym ] = tmp;
        end
        # initialize for new structure
        puts "Read Struct #{data[:name]}"
        $last_struct               = {};
        $last_struct[:struct_name] = data1[:name];
        $last_struct[:active]      = data1[:yes_no_x] == 'yes';
        m = data[:description_subtopic].match(/^(.*)\/\#\{(.*)\}$/)
        if m then
          $last_struct[:subtopic]    = m[1];
          $last_struct[:subsubtopic] = m[2];
        else
          $last_struct[:subtopic] = data1[:description_subtopic];
        end
        $last_struct[:fields] = [];
      when 'x', ''
        ok = data1[:yes_no_x] == 'x';
        data1.delete_if { |key, value| !conf.for_structs.include? key }
        data1[:mqtt] = ok;
        $last_struct[:fields] << data1.dup;
      end
    rescue => e
      puts "skipping row `#{lineNumber}` due to `#{e}`".yellow
    end

    begin
      data1 = data.dup
      if data1[:scenario] == 'x' then
        # dalla riga seleziono le colonne da salvare
        data1.delete_if { |key, value| !conf.for_structs.include? key }
        puts "add to Scenario #{data1}".blue
        $scenario_struct << data1.dup;
      end
    rescue => e
      puts "skipping row `#{lineNumber}` due to `#{e}`".yellow
    end

    begin
      data1 = data.dup
      if data1[:manoeuvre] == 'x' then
        # dalla riga seleziono le colonne da salvare
        data1.delete_if { |key, value| !conf.for_structs.include? key }
        puts "add to Manoeuvre #{data1}".green
        $manoeuvre_struct << data1;
      end
    rescue => e
      puts "skipping row `#{lineNumber}` due to `#{e}`".yellow
    end

    begin
      data1 = data.dup
      if data1[:sim_graphics] == 'x' then
        # dalla riga seleziono le colonne da salvare
        data1.delete_if { |key, value| !conf.for_structs.include? key }
        puts "add to SimGraphics #{data1}".yellow
        $sim_graphics_struct << data1;
      end
    rescue => e
      puts "skipping row `#{lineNumber}` due to `#{e}`".yellow
    end

    begin
      data1 = data.dup
      if data1[:sim_state] == 'x' then
        # dalla riga seleziono le colonne da salvare
        data1.delete_if { |key, value| !conf.for_structs.include? key }
        puts "add to SimState #{data1}".yellow
        $sim_state_struct << data1;
      end
    rescue => e
      puts "skipping row `#{lineNumber}` due to `#{e}`".yellow
    end

  end
end

# save last data
if $last_struct[:struct_name] then
  puts "Save Struct #{$last_struct[:struct_name]}".green
  tmp = {
    :active   => $last_struct[:active],
    :fields   => $last_struct[:fields],
    :subtopic => $last_struct[:subtopic]
  };
  tmp[:subsubtopic] = $last_struct[:subsubtopic] if $last_struct[:subsubtopic]
  $workbook_data[ $last_struct[:struct_name].to_sym ] = tmp;
end

# Write yaml file
# Delete old files in temporary folder (if present)
FileUtils.rm_f conf.yaml_file_name_MQTT
File.open( conf.yaml_file_name_MQTT + ".yaml", 'w' ) do |f|
  f.write($workbook_data.to_yaml(:Indent => 8))
end

puts "File #{conf.yaml_file_name_MQTT}.yaml generated"
puts "--------------------------------------"

## puts "--------------------------------------"
## pp $scenario_struct
## puts "--------------------------------------"
## pp $manoeuvre_struct
## puts "--------------------------------------"
## pp $sim_graphics_struct
## puts "--------------------------------------"

# Write yaml file
$workbook_data = {
  :origin_file => File.basename(conf.input_file_name),
  :Scenario    => $scenario_struct,
  :Manoeuvre   => $manoeuvre_struct,
  :SimGraphics => $sim_graphics_struct,
  :SimState    => $sim_state_struct
}

# Delete old files in temporary folder (if present)
FileUtils.rm_f conf.yaml_file_name_UDP
File.open( conf.yaml_file_name_UDP + ".yaml", 'w' ) do |f|
  f.write($workbook_data.to_yaml(:Indent => 8))
end

puts "File #{conf.yaml_file_name_UDP}.yaml generated"
puts "--------------------------------------"

