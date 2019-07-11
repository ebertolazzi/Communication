#!/usr/bin/env ruby

require 'pp'
require 'erubis'
require 'yaml'
require 'fileutils'
require_relative "./serialize.rb"

data = YAML.load_file("./signalmap_UDP.yaml")

 #####        #     #
#     #       #     # ######   ##   #####  ###### #####
#             #     # #       #  #  #    # #      #    #
#       ##### ####### #####  #    # #    # #####  #    #
#             #     # #      ###### #    # #      #####
#     #       #     # #      #    # #    # #      #   #
 #####        #     # ###### #    # #####  ###### #    #

#
# Generation of the C code for the seriazilation
# C_struct of the data to be serialized
# buffer_to_C_STRUCTURE -> deserialize
# C_STRUCTURE_to_buffer -> serialize
# C_STRUCTURE_print     -> write human readable contents con the structure to the stdout
#
def generate_c_header( tag, value )
  template = '''
/*\
  Automatically generated
\*/

#ifndef <%= @tag.upcase %>_H
#define <%= @tag.upcase %>_H

#ifdef __cplusplus
  #include <cstdint>
  using std::uint8_t;
  using std::uint32_t;
  using std::uint64_t;
  using std::int8_t;
  using std::int32_t;
  using std::int64_t;
  extern "C" {
#else
  #include <stdint.h>
#endif

#ifdef __cplusplus
  extern "C" {
#endif

#if defined(_DS1401)
  #include "ds1401_defines.h"
#endif

/* C structure for <%= @tag %> */
<%= to_C_struct( @tag, @value ) %>

/* print <%= @tag %> struct on stdio */
extern
void
buffer_to_<%= @tag %>( uint8_t const buffer[], <%= @tag %> * S );

/* serialize <%= @tag %> struct to buffer */
extern
void
<%= @tag %>_to_buffer( <%= @tag %> const * S, uint8_t buffer[] );

/* get buffer and un-serialize to <%= @tag %> struct */
extern
void
<%= @tag %>_print( <%= @tag %> const * S );

#ifdef __cplusplus
};
#endif

#endif
'''
  context = { :tag => tag, :value => value }
  eruby = Erubis::Eruby.new(template)
  eruby.evaluate(context)
end

 #####        ######
#     #       #     #  ####  #####  #   #
#             #     # #    # #    #  # #
#       ##### ######  #    # #    #   #
#             #     # #    # #    #   #
#     #       #     # #    # #    #   #
 #####        ######   ####  #####    #

def generate_c_body( tag, value )
  template = '''
/*\
  Automatically generated
\*/

#include "buffer_defines.h"
#include "<%= @tag %>.h"
#include <stdio.h>
#include <string.h>

#ifdef __cplusplus
  extern "C" {
#endif

/* print <%= @tag %> struct on stdio */
<%= to_print( @tag, @value ) %>

/* serialize <%= @tag %> struct to buffer */
<%= to_buffer( @tag, @value ) %>

/* get buffer and un-serialize to <%= @tag %> struct */
<%= from_buffer( @tag, @value ) %>

#ifdef __cplusplus
};
#endif

'''
  context = { :tag => tag, :value => value }
  eruby = Erubis::Eruby.new(template)
  eruby.evaluate(context)
end


sep = "\n\n\n\n\n"

FileUtils.mkdir_p "./generated"

base_src = File.expand_path('../src', File.dirname(__FILE__))
FileUtils.cp "#{base_src}/buffer_defines.h",      "./generated"
FileUtils.cp "#{base_src}/buffer_defines_hton.c", "./generated"
FileUtils.cp "#{base_src}/buffer_defines_ntoh.c", "./generated"

# reconstruct field for UDP struct
pp data.keys
udp_data = {
  :scenario     => { :fields => data[:Scenario]    },
  :manoeuvre    => { :fields => data[:Manoeuvre]   },
  :sim_graphics => { :fields => data[:SimGraphics] },
  :sim_state    => { :fields => data[:SimState]    }
};

###data.keys.each do |tag|
###  if tag != :origin_file and tag != :main_topic then
###    value = data[tag];
###    value.each do |hsc|
###      hsc1 = hsc.dup;
###      hsc1.delete(:scenario);
###      hsc1.delete(:manoeuvre);
###      hsc1.delete(:sim_graphics);
###      hsc1.delete(:mqtt);
###      udp_data[:scenario][:fields]     << hsc1 if hsc[:scenario]     == "x"
###      udp_data[:manoeuvre][:fields]    << hsc1 if hsc[:manoeuvre]    == "x"
###      udp_data[:sim_graphics][:fields] << hsc1 if hsc[:sim_graphics] == "x"
###    end
###  end
###end

prefix = "generated/"
udp_data.each do |key,value|
  puts "key = #{key}"
  ###puts "value = #{value}"
  File.open( prefix+key.to_s+".h", "w" ) { |f| f.puts generate_c_header( key.to_s, value ) }
  File.open( prefix+key.to_s+".c", "w" ) { |f| f.puts generate_c_body( key.to_s, value )   }
end

##
## data.keys.each do |tag|
##   if tag != :origin_file and tag != :main_topic then
##     value = data[tag];
##     ## puts to_MATLAB_struct( tag, value )+sep
##     ## puts to_SIMULINK_struct( tag, value )+sep
##     ## puts to_SIMULINK_busInfo( tag, value )+sep
##     ## puts to_SIMULINK_busInfo_in_data( tag, value )+sep
##     ## puts to_SIMULINK_busInfo_in_data_rtw( tag, value )+sep
##     ## puts to_SIMULINK_message( tag, value )+sep
##     ## puts simulink_to_buffer( tag, value )+sep
##     ## puts simulink_from_buffer( tag, value )+sep
##     ## puts simulink_set_output_signal( tag, value )+sep
##     ## puts simulink_set_input_signal( tag, value )+sep
## 
##     prefix = "generated/"+tag.to_s
##     File.open( prefix+".h", "w" ) { |f| f.puts generate_c_header( tag, data )   }
##     File.open( prefix+".c", "w" ) { |f| f.puts generate_c_body( tag, data )     }
##   end
## end
##
