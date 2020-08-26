#!/usr/bin/env ruby

require 'pp'
require 'erubis'
require 'yaml'
require 'fileutils'
require_relative "./serialize.rb"

data = YAML.load_file("./signalmap_MQTT.yaml")

# Generation of the Python code for the seriazilation

# coded by Giammarco Valenti 5/6/2020
# University fo Trento

def generate_Python_mqtt_script( data )
  template = '''

#
# Automatically generated
# This code was generated:
# <%= Time.now.strftime("%d/%m/%Y %H:%M") %>
#

import struct

# DECODING KEYS (for general purpose)

<% @data.keys.each do |tag|
  if tag != :origin_file and tag != :main_topic and @data[tag][:active] then %>
    <% @data[tag][:fields].delete_if { |v| !v[:mqtt] } %>
<%= to_Python_decoding_key( tag , @data[tag] ) %>
<% end; end; %>

# DECODING

<% @data.keys.each do |tag|
  if tag != :origin_file and tag != :main_topic and @data[tag][:active] then %>
    <% @data[tag][:fields].delete_if { |v| !v[:mqtt] } %>
<%= to_Python_dict( tag , @data[tag] ) %>
<% end; end; %>

# DECODING (true values)

<% @data.keys.each do |tag|
  if tag != :origin_file and tag != :main_topic and @data[tag][:active] then %>
    <% @data[tag][:fields].delete_if { |v| !v[:mqtt] } %>
<%= to_Python_dict_true_values( tag , @data[tag] ) %>
<% end; end; %>

# ENCODING

<% @data.keys.each do |tag|
  if tag != :origin_file and tag != :main_topic and @data[tag][:active] then %>
    <% @data[tag][:fields].delete_if { |v| !v[:mqtt] } %>
<%= from_Python_dict( tag , @data[tag] ) %>
<% end; end; %>

# MQTT specific utilities

# generate topics

<% @data.keys.each do |tag|
  if tag != :origin_file and tag != :main_topic and @data[tag][:active] then %>
    <% @data[tag][:fields].delete_if { |v| !v[:mqtt] } %>
<%= to_Python_MQTT_topic( tag , @data[tag] , @data ) %>
<% end; end; %>

# compare topics

<% @data.keys.each do |tag|
  if tag != :origin_file and tag != :main_topic and @data[tag][:active] then %>
    <% @data[tag][:fields].delete_if { |v| !v[:mqtt] } %>
<%= compare_Python_MQTT_topic( tag , @data ) %>
<% end; end; %>

# decode from payload and topic

<%= to_Python_dict_universal( @data ) %>

<%= to_Python_dict_universal_true_values( @data ) %>

'''
  context = { :data => data, :main_topic => data[:main_topic] }
  eruby = Erubis::Eruby.new(template)
  eruby.evaluate(context)
end

FileUtils.mkdir_p "./generated_4_py"
# FileUtils.cp "../src/buffer_defines.h",      "./generated"
# FileUtils.cp "../src/buffer_defines_hton.c", "./generated"
# FileUtils.cp "../src/buffer_defines_ntoh.c", "./generated"

prefix = "generated_4_py/"+data[:main_topic]+"_Python_mqtt"
File.open( prefix+".py",   "w" ) { |f| f.puts generate_Python_mqtt_script( data ) }

