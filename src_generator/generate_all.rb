#!/usr/bin/env ruby

require 'pp'
require 'erubis'
require 'yaml'
require 'fileutils'
require "./serialize.rb"

data = YAML.load_file("./signalmap.yaml")

def generate_c_header( tag, data )
  template = '''
/*\
  Automatically generated
\*/

#ifndef <%= @tag.upcase %>_H
#define <%= @tag.upcase %>_H

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

/* build topic for <%= @tag %> struct */
extern
void
<%= @tag %>_mqtt_topic( <%= @tag %> const * S, char topic[], int topic_len );

/* build topic for <%= @tag %> struct */
extern
void
<%= @tag %>_mqtt_alltopics( <%= @tag %> const * S, char topic[], int topic_len );

#endif
'''
  context = { :tag => tag, :value => data[tag] }
  eruby = Erubis::Eruby.new(template)
  eruby.evaluate(context)  
end

def generate_c_body( tag, data )
  template = '''
/*\
  Automatically generated
\*/

#include "buffer_defines.h"
#include "<%= @tag %>.h"

/* print <%= @tag %> struct on stdio */
<%= to_print( @tag, @value ) %>

/* serialize <%= @tag %> struct to buffer */
<%= to_buffer( @tag, @value ) %>

/* get buffer and un-serialize to <%= @tag %> struct */
<%= from_buffer( @tag, @value ) %>

/* build topic for <%= @tag %> struct */
<%= to_mqtt_topic( @tag, @data ) %>

/* build topic for <%= @tag %> struct */
<%= to_mqtt_alltopics( @tag, @data ) %>

'''
  context = { :tag => tag, :value => data[tag], :data => data }
  eruby = Erubis::Eruby.new(template)
  eruby.evaluate(context)  
end

def generate_cpp_header( tag, data )
  template = '''
/*\
  Automatically generated
\*/

#ifndef <%= @tag.upcase %>_HH
#define <%= @tag.upcase %>_HH

#include <mosquitto.h>
#include <mosquittopp.h>

class Mqtt_<%= @tag %>_publisher : public mosqpp::mosquittopp {
public:
  Mqtt_<%= @tag %>( char const id[] )
  : mosqpp::mosquittopp( id, true )
  {}

  void
  publish( <%= @tag %> const & S, )

};

class Mqtt_<%= @tag %>_subscriber : public mosqpp::mosquittopp {
public:
  Mqtt_<%= @tag %>( char const id[], bool clean_session )
  : mosqpp::mosquittopp( id, clean_session )
  {}

  virtual
  void
  on_connect( int result );

  virtual
  void
  on_message( const struct mosquitto_message *message );
};

#endif

'''
  context = { :tag => tag, :value => data[tag] }
  eruby = Erubis::Eruby.new(template)
  eruby.evaluate(context)  
end

def generate_cpp_body( tag, data )
  template = '''
/*\
  Automatically generated
\*/
'''
  context = { :tag => tag, :value => data[tag] }
  eruby = Erubis::Eruby.new(template)
  eruby.evaluate(context)  
end

sep = "\n\n\n\n\n"

FileUtils.mkdir_p "./generated"
FileUtils.cp "../src/buffer_defines.h",      "./generated"
FileUtils.cp "../src/buffer_defines_hton.c", "./generated"
FileUtils.cp "../src/buffer_defines_ntoh.c", "./generated"

data.keys.each do |tag|
  if tag != :origin_file and tag != :main_topic then
    value = data[tag];
    ## puts to_print( tag, value )+sep
    ## puts to_buffer( tag, value )+sep
    ## puts from_buffer( tag, value )+sep
    ## puts to_C_struct( tag, value )+sep
    ## puts to_MATLAB_struct( tag, value )+sep
    ## puts to_SIMULINK_struct( tag, value )+sep
    ## puts to_SIMULINK_busInfo( tag, value )+sep
    ## puts to_SIMULINK_busInfo_in_data( tag, value )+sep
    ## puts to_SIMULINK_busInfo_in_data_rtw( tag, value )+sep
    ## puts to_SIMULINK_message( tag, value )+sep
    ## puts simulink_to_buffer( tag, value )+sep
    ## puts simulink_from_buffer( tag, value )+sep
    ## puts simulink_set_output_signal( tag, value )+sep
    ## puts simulink_set_input_signal( tag, value )+sep
    ## puts to_mqtt_topic( tag, data )+sep

    prefix = "generated/"+tag.to_s

    File.open( prefix+".h",   "w" ) { |f| f.puts generate_c_header( tag, data )   }
    File.open( prefix+".c",   "w" ) { |f| f.puts generate_c_body( tag, data )     }
    #File.open( prefix+".hpp", "w" ) { |f| f.puts generate_cpp_header( tag, data ) }
    #File.open( prefix+".cpp", "w" ) { |f| f.puts generate_cpp_body( tag, data )   }
  end
end
