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

#if defined(_WIN32) || defined(WIN32) || defined(_WIN64) || defined(WIN64)

#else
  #ifdef __clang__
  #pragma clang diagnostic ignored "-Wdouble-promotion"
  #elif __llvm__
  #pragma GCC diagnostic ignored "-Wdouble-promotion"
  #else
  #pragma GCC diagnostic ignored "-Wdouble-promotion"
  #endif
#endif

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



 ####  # #    # #    # #      # #    # #    #
#      # ##  ## #    # #      # ##   # #   #
 ####  # # ## # #    # #      # # #  # ####
     # # #    # #    # #      # #  # # #  #
#    # # #    # #    # #      # #   ## #   #
 ####  # #    #  ####  ###### # #    # #    #


#    # ######   ##   #####  ###### #####
#    # #       #  #  #    # #      #    #
###### #####  #    # #    # #####  #    #
#    # #      ###### #    # #      #####
#    # #      #    # #    # #      #   #
#    # ###### #    # #####  ###### #    #
#
# Generation of the C code for the seriazilation
# C_struct of the data to be serialized
# buffer_to_C_STRUCTURE -> deserialize
# C_STRUCTURE_to_buffer -> serialize
# C_STRUCTURE_print     -> write human readable contents con the structure to the stdout
#
def generate_simulink_header( tag, value )
  template = '''
/*\
  Automatically generated
\*/

#ifndef <%= @tag.upcase %>_SIMULINK_H
#define <%= @tag.upcase %>_SIMULINK_H

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

#include "<%= @tag %>.h"

extern void simulink_input_port_to_<%= @tag %>( SimStruct *S, <%= @tag %> * out );
extern void <%= @tag %>_to_simulink_output_port( <%= @tag %> * in, SimStruct * S );
extern void <%= @tag %>_simulink_set_output_signal_ports( SimStruct *S );
extern void <%= @tag %>_simulink_set_input_signal_ports( SimStruct *S );

#define <%= @tag.upcase %>_NUM_SIGNALS <%= @value[:fields].size %>

#ifdef __cplusplus
};
#endif

#endif
'''
  context = { :tag => tag, :value => value }
  eruby = Erubis::Eruby.new(template)
  eruby.evaluate(context)
end

 ####  # #    # #    # #      # #    # #    #    #####   ####  #####  #   #
#      # ##  ## #    # #      # ##   # #   #     #    # #    # #    #  # #
 ####  # # ## # #    # #      # # #  # ####      #####  #    # #    #   #
     # # #    # #    # #      # #  # # #  #      #    # #    # #    #   #
#    # # #    # #    # #      # #   ## #   #     #    # #    # #    #   #
 ####  # #    #  ####  ###### # #    # #    #    #####   ####  #####    #

def generate_simulink_body( tag, value )
  template = '''
/*\
  Automatically generated
\*/

#include "simstruc.h"
#include "buffer_defines.h"
#include "<%= @tag %>_simulink.h"
#include <stdio.h>
#include <string.h>

#ifdef __cplusplus
  extern "C" {
#endif

<%= simulink_to_struct(@tag, @value) %>
<%= simulink_from_struct(@tag, @value) %>
<%= simulink_set_output_signal(@tag, @value) %>
<%= simulink_set_input_signal(@tag, @value) %>

#ifdef __cplusplus
};
#endif

'''
  context = { :tag => tag, :value => value }
  eruby = Erubis::Eruby.new(template)
  eruby.evaluate(context)
end



#     #    #    ####### #          #    ######
##   ##   # #      #    #         # #   #     #
# # # #  #   #     #    #        #   #  #     #
#  #  # #     #    #    #       #     # ######
#     # #######    #    #       ####### #     #
#     # #     #    #    #       #     # #     #
#     # #     #    #    ####### #     # ######

 def generate_matlab( tag, value )
  template = '''
%
% Automatically generated
%
<%= to_MATLAB_struct( @tag, @value ) %>
'''
  context = { :tag => tag, :value => value }
  eruby = Erubis::Eruby.new(template)
  eruby.evaluate(context)
end

 #####
#     #   #     #   #    # ######   ##   #####  ###### #####
#         #     #   #    # #       #  #  #    # #      #    #
#       ##### ##### ###### #####  #    # #    # #####  #    #
#         #     #   #    # #      ###### #    # #      #####
#     #   #     #   #    # #      #    # #    # #      #   #
 #####              #    # ###### #    # #####  ###### #    #

 def generate_cpp_header( tag, value )
  template = '''
/*\
  Automatically generated
\*/

#ifndef <%= @tag.upcase %>_CPP_HH
#define <%= @tag.upcase %>_CPP_HH

#include "<%= @tag %>.h"
#include <iostream>

extern void <%=  @tag %>_log_header( std::ostream & stream );
extern void <%=  @tag %>_log_read_line( std::istream & stream, <%=  @tag %> & S );
extern void <%=  @tag %>_log_write_line( std::ostream & stream, <%=  @tag %> const & S );
extern void <%=  @tag %>_log_write_line_pretty_print( std::ostream & stream, <%=  @tag %> const & S );

#endif
'''
  context = { :tag => tag, :value => value }
  eruby = Erubis::Eruby.new(template)
  eruby.evaluate(context)
end


 ####    #     #   #####   ####  #####  #   #
#    #   #     #   #    # #    # #    #  # #
#      ##### ##### #####  #    # #    #   #
#        #     #   #    # #    # #    #   #
#    #   #     #   #    # #    # #    #   #
 ####              #####   ####  #####    #

 def generate_cpp_body( tag, value )
  template = '''
/*\
  Automatically generated
\*/

#include "<%= @tag %>_cpp.hh"
#include <sstream>

<%= to_log_header( @tag, @value ) %>
<%= to_log_read_line( @tag, @value ) %>
<%= to_log_write_line( @tag, @value ) %>
<%= to_log_write_line_pretty_print( @tag, @value ) %>

'''
  context = { :tag => tag, :value => value }
  eruby = Erubis::Eruby.new(template)
  eruby.evaluate(context)
end

sep = "\n\n\n\n\n"

FileUtils.mkdir_p "./generated"

base_src = File.expand_path('../src', File.dirname(__FILE__))
#FileUtils.cp "#{base_src}/buffer_defines.h",      "./generated"
#FileUtils.cp "#{base_src}/buffer_defines_hton.c", "./generated"
#FileUtils.cp "#{base_src}/buffer_defines_ntoh.c", "./generated"

# reconstruct field for UDP struct
pp data.keys
udp_data = {
  :scenario     => { :fields => data[:Scenario]    },
  :manoeuvre    => { :fields => data[:Manoeuvre]   },
  :sim_graphics => { :fields => data[:SimGraphics] },
  :sim_state    => { :fields => data[:SimState]    }
};

prefix = "generated/"
udp_data.each do |key,value|
  puts "key = #{key}"
  ###puts "value = #{value}"
  File.open( prefix+key.to_s+".h",  "w" ) { |f| f.puts generate_c_header( key.to_s, value ) }
  File.open( prefix+key.to_s+".c",  "w" ) { |f| f.puts generate_c_body( key.to_s, value ) }
  File.open( prefix+key.to_s+"_cpp.hh", "w" ) { |f| f.puts generate_cpp_header( key.to_s, value ) }
  File.open( prefix+key.to_s+"_cpp.cc", "w" ) { |f| f.puts generate_cpp_body( key.to_s, value ) }
  File.open( prefix+key.to_s+"_simulink.h", "w" ) { |f| f.puts generate_simulink_header( key.to_s, value ) }
  File.open( prefix+key.to_s+"_simulink.c", "w" ) { |f| f.puts generate_simulink_body( key.to_s, value ) }
  File.open( prefix+key.to_s+"_matlab_data_struct.m", "w" ) { |f| f.puts generate_matlab( key.to_s, value ) }
end
