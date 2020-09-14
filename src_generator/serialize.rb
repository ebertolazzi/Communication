#
# Ruby  functions used to serialize data and convert into
# C/C++/Simulink/Python code
#
def type_to_size( t )
  sz = 0
  t.downcase!
  case t
  when /^double$/
    sz = 8;
  when /^single$/
    sz = 4;
  when /^int8$/
    sz = 1;
  when /^uint8$/
    sz = 1;
  when /^int16$/
    sz = 2;
  when /^uint16$/
    sz = 2;
  when /^int32$/
    sz = 4;
  when /^uint32$/
    sz = 4;
  when /^int64$/
    sz = 8;
  when /^uint64$/
    sz = 8;
  else
  puts "unknown size of #{t}"
  end
  return sz
end

def type_to_C( t )
  t.downcase!
  case t
  when /^double$/
  when /^single$/
    t = 'float'
  when /^int8$/
    t += '_t';
  when /^uint8$/
    t += '_t';
  when /^int16$/
    t += '_t';
  when /^uint16$/
    t += '_t';
  when /^int32$/
    t += '_t';
  when /^uint32$/
    t += '_t';
  when /^int64$/
    t += '_t';
  when /^uint64$/
    t += '_t';
  else
  puts "type_to_C: unknown name of #{t}"
  end
  return t
end

def type_to_C_fmt( t )
  t.downcase!
  case t
  when /^double$/
    res = "lg"
  when /^single$/
    res = "g"
  when /^int8$/
    res = "hhd"
  when /^uint8$/
    res = "hhu"
  when /^int16$/
    res = "hd"
  when /^uint16$/
    res = "hu"
  when /^int32$/
    res = "d"
  when /^uint32$/
    res = "u"
  when /^int64$/
    res = "ld"
  when /^uint64$/
    res = "llu"
  else
  puts "type_to_C_fmt: unknown name of #{t}"
  end
  return res
end

def type_to_C_simulink( t )
  res = ""
  t.downcase!
  case t
  when /^double$/
    res = "real64_T";
  when /^single$/
    res = "real32_T";
  when /^int8$/
    res = t + '_T';
  when /^uint8$/
    res = t + '_T';
  when /^int16$/
    res = t + '_T';
  when /^uint16$/
    res = t + '_T';
  when /^int32$/
    res = t + '_T';
  when /^uint32$/
    res = t + '_T';
  when /^int64$/
    res = t + '_T';
  when /^uint64$/
    res = t + '_T';
  else
  puts "type_to_C_simulink: unknown name of #{t}"
  end
  return res
end

def type_to_C_simulink2( t )
  res = ""
  t.downcase!
  case t
  when /^double$/
    res = "double"
  when /^single$/
    res = "float"
  when /^int8$/
    res = t;
  when /^uint8$/
    res = t;
  when /^int16$/
    res = t;
  when /^uint16$/
    res = t;
  when /^int32$/
    res = t;
  when /^uint32$/
    res = t;
  when /^int64$/
    res = t;
  when /^uint64$/
    res = t;
  else
  puts "type_to_C_simulink: unknown name of #{t}"
  end
  return res
end

def type_to_SIMULINK( t )
  res = ""
  t.downcase!
  case t
  when /^double$/
    res = "SS_DOUBLE"
  when /^single$/
    res = "SS_SINGLE"
  when /^int8$/
    res = "SS_INT8"
  when /^uint8$/
    res = "SS_UINT8"
  when /^int16$/
    res = "SS_INT16"
  when /^uint16$/
    res = "SS_UINT16"
  when /^int32$/
    res = "SS_INT32"
  when /^uint32$/
    res = "SS_UINT32"
  when /^int64$/
    res = "SS_INT64"
  when /^uint64$/
    res = "SS_UINT64"
  else
  puts "type_to_SIMULINK: unknown name of #{t}"
  end
  return res
end

def type_to_Python_struct( t )
  # refer to https://docs.python.org/2/library/struct.html
  t.downcase!
  case t
  when /^double$/
    t = 'd'
  when /^single$/
    t = 'f'
  when /^int8$/
    t = 'b';
  when /^uint8$/
    t = 'B';
  when /^int16$/
    t = 'h';
  when /^uint16$/
    t = 'H';
  when /^int32$/
    t = 'i';
  when /^uint32$/
    t = 'I';
  when /^int64$/
    t = 'q';
  when /^uint64$/
    t = 'Q';
  else
    puts "type_to_Python_struct: unknown name of #{t}"
  end
  return t
end

def to_dim( vec )
  res  = ""
  dim  = 0;
  vec.each do |v|
    tv   = v[0].split(':')
    sz   = type_to_size(tv[0])
    sz  *= tv[1].to_i if tv[1]
    dim += sz
  end
  return dim
end

def to_print( name, hsc )
  fds   = hsc[:fields];
  len   = fds.map { |f| f[:name].length }.max
  maxsz = fds.map { |f| f[:size].to_i }.max
  res  = "void\n#{name}_print( #{name} const * S ) {\n"
  res += "  int i_count;\n" if maxsz > 1
  fds.each do |f|
    fmt = type_to_C_fmt(f[:type])
    n   = f[:name];
    sz  = f[:size].to_i;
    if sz > 1 then
      nn = n+'[%d]';
      res += "  for ( i_count=0; i_count<#{sz}; ++i_count )\n"
      res += "    printf( \"#{nn.ljust(len)} = %#{fmt}\\n\", i_count, S->#{n}[i_count]);\n"
    else
      res += "  printf( \"#{n.ljust(len)} = %#{fmt}\\n\", S->#{n});\n"
    end
  end
  res += "}\n"
  return res
end

def to_fileprint( name, hsc )
  fds   = hsc[:fields];
  len   = fds.map { |f| f[:name].length }.max
  maxsz = fds.map { |f| f[:size].to_i }.max
  res  = "void\n#{name}_fileprint( #{name} const * S , FILE * file_stream ) {\n"
  res += "  int i_count;\n" if maxsz > 1
  fds.each do |f|
    fmt = type_to_C_fmt(f[:type])
    n   = f[:name];
    sz  = f[:size].to_i;
    if sz > 1 then
      nn = n+'[%d]';
      res += "  for ( i_count=0; i_count<#{sz}; ++i_count )\n"
      res += "    fprintf( file_stream , \"#{nn.ljust(len)} = %#{fmt}\\n\", i_count, S->#{n}[i_count]);\n"
    else
      res += "  fprintf( file_stream , \"#{n.ljust(len)} = %#{fmt}\\n\", S->#{n});\n"
    end
  end
  res += "}\n"
  return res
end

def to_buffer( name, hsc )
  fds   = hsc[:fields];
  len   = fds.map { |f| f[:name].length }.max
  maxsz = fds.map { |f| f[:size].to_i }.max
  res  = "void\n#{name}_to_buffer(\n  #{name} const * S,\n  uint8_t buffer[]\n) {\n"
  res += "  int i_count;\n" if maxsz > 1
  res += "  uint8_t * ptr = buffer;\n"
  fds.each do |f|
    tv  = type_to_C_simulink2(f[:type]);
    fmt = type_to_C_fmt(f[:type]);
    n   = f[:name];
    sz  = f[:size].to_i;
    if sz > 1 then
      res += "  for ( i_count=0; i_count<#{sz}; ++i_count )\n"
      res += "    { ptr += #{tv}_to_buffer( S->#{n}[i_count], ptr ); }\n"
    else
      res += "  ptr += #{tv}_to_buffer( S->#{n}, ptr );\n"
    end
  end
  res += "}\n"
  return res
end

def from_buffer( name, hsc )
  fds   = hsc[:fields];
  len   = fds.map { |f| f[:name].length }.max
  maxsz = fds.map { |f| f[:size].to_i }.max
  res  = "void\nbuffer_to_#{name}(\n  uint8_t const buffer[],\n  #{name} * S\n) {\n"
  res += "  int i_count;\n" if maxsz > 1
  res += "  uint8_t const * ptr = buffer;\n"
  fds.each do |f|
    tv  = type_to_C_simulink2(f[:type]);
    fmt = type_to_C_fmt(f[:type]);
    n   = f[:name];
    sz  = f[:size].to_i;
    if sz > 1 then
      res += "  for ( i_count=0; i_count<#{sz}; ++i_count )\n"
      res += "    { ptr += buffer_to_#{tv}( ptr, & S->#{n}[i_count] ); }\n"
    else
      res += "  ptr += buffer_to_#{tv}( ptr, &S->#{n} );\n"
    end
  end
  res += "}\n"
  return res
end

 ####  ##### #####  #    #  ####  #####
#        #   #    # #    # #    #   #
 ####    #   #    # #    # #        #
     #   #   #####  #    # #        #
#    #   #   #   #  #    # #    #   #
 ####    #   #    #  ####   ####    #

def to_C_struct( name, hsc )
  fds   = hsc[:fields];
  len   = fds.map { |f| f[:name].length }.max
  maxsz = fds.map { |f| f[:size].to_i }.max
  res   = "typedef struct {\n";
  dim   = 0;
  fds.each do |f|
    tv = f[:type];
    n  = f[:name];
    sz = f[:size].to_i;
    n += "[#{sz}]" if sz > 1
    n += ';'
    res += "  #{type_to_C(tv).ljust(8)} #{n.ljust(len+6)}"
    res += " /* #{f[:comment]} */\n"
    dim += sz*type_to_size(tv);
  end
  res += "} #{name};\n\n"
  res += "/* size of the serialized version of struct #{name} */\n"
  res += "#define #{name}_size  #{dim}\n"
  res += "#define #{name}_n_fields #{fds.size}\n"
  ##res += "\nextern\nvoid\nbuffer_to_#{name}( uint8_t const buffer[], #{name} * S );\n"
  ##res += "\nextern\nvoid\n#{name}_to_buffer( #{name} const * S, uint8_t buffer[] );\n"
  ##res += "\nextern\nvoid\n#{name}_print( #{name} const * S );\n\n"
  ##res += "\nextern\nvoid\n#{name}_MQTT_topic( #{name} const * S, char topic[], int topic_len );\n\n"
  return res
end

def to_MATLAB_struct( name, hsc )
  fds   = hsc[:fields];
  len   = fds.map { |f| f[:name].length }.max
  maxsz = fds.map { |f| f[:size].to_i }.max
  res   = "";
  fds.each do |f|
    tv = f[:type];
    n  = f[:name];
    sz = f[:size].to_i;
    res += "#{name}.#{n.ljust(len)} = #{tv}(zeros(#{sz},1)); % #{f[:comment]}\n"
  end
  return res
end


#     #  #####  ####### #######
##   ## #     #    #       #
# # # # #     #    #       #
#  #  # #     #    #       #
#     # #   # #    #       #
#     # #    #     #       #
#     #  #### #    #       #

def to_MQTT_topic( name, data )
  main_topic  = data[:main_topic];
  subtopic    = data[name][:subtopic];
  subsubtopic = data[name][:subsubtopic];
  res  = "void\n#{name}_MQTT_topic(\n"
  res += "  #{name} const * S,\n"
  res += "  char topic[],\n"
  res += "  int topic_max_len\n"
  res += ") {\n"
  res += "  char const * base_topic = \"#{main_topic}/#{subtopic}\";\n"
  if subsubtopic and subsubtopic.length > 0 then
    res += "  snprintf( topic, topic_max_len, \"%s/%d\", base_topic, S->#{subsubtopic} );\n"
  else
    res += "  snprintf( topic, topic_max_len, \"%s\", base_topic );\n"
  end
  res += "}\n\n"
  res += "int\n#{name}_MQTT_compare( char const topic[] ) {\n"
  res += "  int topic_len = #{1+main_topic.length+subtopic.length};\n"
  res += "  char const * topic_ref = \"#{main_topic}/#{subtopic}\";\n"
  res += "  return strncmp( topic, topic_ref, topic_len );\n"
  res += "}\n"
  return res
end

def to_MQTT_alltopics( name, data )
  main_topic  = data[:main_topic];
  subtopic    = data[name][:subtopic];
  subsubtopic = data[name][:subsubtopic];
  res  = "void\n#{name}_MQTT_alltopics( char topic[], int topic_max_len ) {\n"
  res += "  char const * base_topic = \"#{main_topic}/#{subtopic}\";\n"
  if subtopic and subtopic.length > 0 then
    res += "  snprintf( topic, topic_max_len, \"%s/#\", base_topic );\n"
  else
    res += "  snprintf( topic, topic_max_len, \"%s\", base_topic );\n"
  end
  res += "}\n"
  return res
end

 ####  # #    # #    # #      # #    # #    #
#      # ##  ## #    # #      # ##   # #   #
 ####  # # ## # #    # #      # # #  # ####
     # # #    # #    # #      # #  # # #  #
#    # # #    # #    # #      # #   ## #   #
 ####  # #    #  ####  ###### # #    # #    #

def to_SIMULINK_struct( name, hsc )
  fds   = hsc[:fields];
  len   = fds.map { |f| f[:name].length }.max
  maxsz = fds.map { |f| f[:size].to_i }.max
  dim   = 0;
  res   = "typedef struct {\n";
  fds.each do |f|
    tv   = f[:type];
    t    = type_to_C_simulink(tv);
    n    = f[:name];
    sz   = f[:size].to_i;
    n   += "[#{sz}]" if sz > 1
    n   += ';'
    res += "  #{t.ljust(10)} #{n.ljust(len+6)} /* #{f[:comment]} */\n"
    dim += sz*type_to_size(tv);
  end
  res += "} #{name};\n\n"
  res += "#define #{name}_size #{dim}\n"
  #res += "\nextern\nvoid\nbuffer_to_#{name}( uint8_t const buffer[], #{name} * S );\n"
  #res += "\nextern\nvoid\n#{name}_to_buffer( #{name} const * S, uint8_t buffer[] );\n\n"
  return res
end

def to_SIMULINK_busInfo( name, hsc )
  fds   = hsc[:fields];
  len   = fds.map { |f| f[:name].length }.max
  maxsz = fds.map { |f| f[:size].to_i }.max
  dim   = 0;

  res    = "  /* Bus Information */\n"
  res   += "  int_T id;\n\n"
  res   += "  slDataTypeAccess *dta = ssGetDataTypeAccess(S);\n"
  res   += "  char const * bpath = ssGetPath(S);\n";
	res   += "  DTypeId #{name}_strId = ssGetDataTypeId(S, \"#{name}\");\n"
	res   += "  busInfoStruct *busInfo = (busInfoStruct *)malloc(#{fds.size} * sizeof(busInfoStruct));\n"
	res   += "  if(busInfo==NULL) {\n"
  res   += "    ssSetErrorStatus(S, \"Memory allocation failure\");\n"
  res   += "    return;\n"
  res   += "  }\n\n"
  res   += "  /* Calculate offsets of all primitive elements of the bus */\n\n"

  fds.each_with_index do |f,idx|
    tv   = f[:type];
    t    = type_to_C_simulink(tv);
    n    = f[:name];
    sz   = f[:size].to_i;
    n   += "[#{sz}]" if sz > 1
    n   += ';'
    res += "  busInfo[#{idx}].offset   = dtaGetDataTypeElementOffset(dta, bpath, #{name}_strId, #{idx});\n"
    res += "  id = ssGetDataTypeId(S, \"#{t}\");\n"
    res += "  if( id == INVALID_DTYPE_ID) ssPrintf(\"Bad type '#{t}' for input N.#{idx}\\n\");\n"
    res += "  busInfo[#{idx}].elemSize = dtaGetDataTypeSize(dta, bpath, id);\n"
    res += "  busInfo[#{idx}].numElems = #{n};\n\n"
  end
  res += "  ssSetUserData(S, busInfo);\n"
  return res
end

def to_SIMULINK_busInfo_in_data( name, hsc )
  fds   = hsc[:fields];
  len   = fds.map { |f| f[:name].length }.max
  maxsz = fds.map { |f| f[:size].to_i }.max
  dim   = 0;

  res   = "  uint8_T *payload = (uint8_T *) ssGetInputPortSignal(S, 0);\n"
  res  += "  uint8_T *serialized_data = (uint8_T *) ssGetOutputPortRealSignal(S, 0);\n"
  res  += "  busInfoStruct* busInfo = (busInfoStruct *) ssGetUserData(S);"
  res  += "  uint32_T  nbyte;"
  res  += "  uint8_T * ptr;"
	res  += "  /* Temporary bus copy declarations */\n"
	res  += "  #{name} tmp;\n"
	res  += "  /* Copy input bus into temporary structure */\n\n"

  fds.each_with_index do |f,idx|
    tv   = f[:type];
    t    = type_to_C_simulink(tv);
    n    = f[:name];
    sz   = f[:size].to_i;
    n   += "[#{sz}]" if sz > 1
    n   += ';'
    res += "  ptr   = payload + busInfo[#{idx}].offset;\n";
    res += "  nbyte = busInfo[#{idx}].elemSize * busInfo[#{idx}].numElems;\n"
    res += "  (void) memcpy( &tmp.#{n}, ptr, nbyte );\n"
  end
  res += "  #{name}_to_buffer(&tmp, serialized_data);\n"
  return res
end

def to_SIMULINK_busInfo_in_data_rtw( name, hsc )
  fds   = hsc[:fields];
  len   = fds.map { |f| f[:name].length }.max
  maxsz = fds.map { |f| f[:size].to_i }.max
  dim   = 0;

  res   = "  uint8_T * payload         = (uint8_T *) ssGetInputPortSignal(S, 0);\n"
  res  += "  uint8_T * serialized_data = (uint8_T *) ssGetOutputPortRealSignal(S, 0);\n"
  res  += "  /* Temporary bus copy declarations */\n"
	res  += "  #{name} tmp;\n"
	res  += "  /* Copy input bus into temporary structure */\n\n"

  offs = 0;

  fds.each_with_index do |f,idx|
    tv   = f[:type];
    t    = type_to_C_simulink(tv);
    sz   = type_to_size(tv);
    n    = f[:size]
    rd   = offs % sz;
    offs += rd; # add offset for paddind
    nbyte = n.to_i*sz.to_i
    res  += "  (void) memcpy( &tmp.#{f[:name]}, payload + #{offs}, #{nbyte} );\n"
    res  += "\n"
    offs += n.to_i*sz.to_i;
  end
  res += "  #{name}_to_buffer(&tmp, serialized_data);\n"
  return res
end

def simulink_to_struct( name, hsc )
  fds   = hsc[:fields];
  len   = fds.map { |f| f[:name].length }.max
  maxsz = fds.map { |f| f[:size].to_i }.max

  res  = "void\nsimulink_input_port_to_#{name}( SimStruct *S, #{name} * out ) {\n"
  res += "  int i_count = 0;\n"

  fds.each_with_index do |f,ipos|
    t  = type_to_C_simulink(f[:type]);
    tv = type_to_C_simulink2(f[:type]);
    sz = f[:size].to_i;
    n  = f[:name];

    res += "  /* extract ``#{n}'' at position #{ipos} */\n"
    res += "  { #{t} const * p = (#{t} const *)ssGetInputPortSignalPtrs( S, #{ipos} );\n"
    res += "    if ( p == NULL ) {\n"
    res += "      #ifdef SS_STDIO_AVAILABLE\n"
    res += "        ssPrintf(\"null pointer at port #{ipos} for ``#{n}''\\n\");\n"
    res += "      #endif\n"
    res += "    } else {\n"
    if sz > 1 then
      res += "      for ( i_count=0; i_count < #{sz}; ++i_count ) out->#{n}[i_count] = p[i_count];\n"
    else
      res += "      out->#{n} = *p;\n"
    end
    res += "    }\n  }\n"
  end
  res += "}\n\n"
  return res
end

def simulink_from_struct( name, hsc )
  fds   = hsc[:fields];
  len   = fds.map { |f| f[:name].length }.max
  maxsz = fds.map { |f| f[:size].to_i }.max

  res  = "void\n#{name}_to_simulink_output_port( #{name} * in, SimStruct * S ) {\n"
  res += "  int i_count = 0;\n"

  fds.each_with_index do |f,ipos|
    t  = type_to_C_simulink(f[:type]);
    tv = type_to_C_simulink2(f[:type]);
    sz = f[:size].to_i;
    n  = f[:name];

    res += "  /* store ``#{n}'' at port #{ipos} */\n"
    if sz > 1 then
      res += "  memcpy( ssGetOutputPortSignal( S, #{ipos} ), in->#{n}, sizeof(#{type_to_C(f[:type])})*#{sz} );\n"
    else
      res += "  memcpy( ssGetOutputPortSignal( S, #{ipos} ), (void*)(&in->#{n}), sizeof(#{type_to_C(f[:type])}) );\n"
    end
  end
  res += "}\n\n"
  return res
end

def simulink_set_output_signal( name, hsc )
  fds   = hsc[:fields];
  len   = fds.map { |f| f[:name].length }.max
  maxsz = fds.map { |f| f[:size].to_i }.max

  res  = "void\n#{name}_simulink_set_output_signal_ports( SimStruct *S ) {\n"
  ##res += "  int nout = #{vec.size()};\n"
  ##res += "  if (!ssSetNumOutputPorts(S, nout)) return;\n\n"

  fds.each_with_index do |f,ipos|
    tv    = f[:type];
    t     = type_to_SIMULINK(tv);
    sz    = type_to_size(tv);
    n     = f[:name];
    nelem = f[:size].to_i;

    res += "  /* Map Output Port #{ipos} to ``#{n}'' */\n"
    res += "  ssSetOutputPortWidth( S, #{ipos}, #{nelem} );\n"
    res += "  ssSetOutputPortDataType( S, #{ipos}, #{t} );\n"
    res += "  ssSetOutputPortComplexSignal( S, #{ipos}, COMPLEX_NO );\n\n"
  end
  res += "}\n"
  return res
end

def simulink_set_input_signal( name, hsc )
  fds   = hsc[:fields];
  len   = fds.map { |f| f[:name].length }.max
  maxsz = fds.map { |f| f[:size].to_i }.max

  res  = "void\n#{name}_simulink_set_input_signal_ports( SimStruct *S ) {\n"
  ##res += "  int nout = #{vec.size()};\n"
  ##res += "  if (!ssSetNumInputPorts(S, nout)) return;\n\n"

  fds.each_with_index do |f,ipos|
    tv    = f[:type];
    t     = type_to_SIMULINK(tv);
    sz    = type_to_size(tv);
    n     = f[:name];
    nelem = f[:size].to_i;

    res += "  /* Map Input Port #{ipos} to ``#{n}'' */\n"
    res += "  ssSetInputPortWidth( S, #{ipos}, #{nelem} );\n"
    res += "  ssSetInputPortDirectFeedThrough( S, #{ipos}, 1 );\n\n"
    res += "  ssSetInputPortDataType( S, #{ipos}, #{t} );\n"
    res += "  ssSetInputPortComplexSignal( S, #{ipos}, COMPLEX_NO );\n"
    res += "  ssSetInputPortRequiredContiguous( S, #{ipos}, 1 );\n\n"

  end
  res += "}\n"
  return res
end

#       #######  #####
#       #     # #     #
#       #     # #
#       #     # #  ####
#       #     # #     #
#       #     # #     #
####### #######  #####

def to_log_header( name, hsc )
  fds   = hsc[:fields];
  len   = fds.map { |f| f[:name].length }.max
  maxsz = fds.map { |f| f[:size].to_i }.max
  res  = "void\n#{name}_log_header( std::ostream & stream ) {\n"
  fds.each do |f|
    n   = f[:name];
    sz  = f[:size].to_i;
    if sz > 1 then
      res += "  for ( int i_count=0; i_count<#{sz}; ++i_count )\n"
      res += "    stream << \"'#{n}_\" << i_count << \"'\\t\";\n"
    else
      res += "  stream << \"'#{n}'\\t\";\n"
    end
  end
  res += "  stream << '\\n';\n"
  res += "}\n"
  return res
end

def to_log_write_line( name, hsc )
  fds   = hsc[:fields];
  len   = fds.map { |f| f[:name].length }.max
  maxsz = fds.map { |f| f[:size].to_i }.max
  res  = "void\n#{name}_log_write_line( std::ostream & stream, #{name} const & S ) {\n"
  fds.each do |f|
    n   = f[:name];
    sz  = f[:size].to_i;
    if sz > 1 then
      res += "  for ( int i_count=0; i_count<#{sz}; ++i_count )\n"
      res += "    stream << S.#{n}[i_count] << '\\t';\n"
    else
      res += "  stream << S.#{n} << '\\t';\n"
    end
  end
  res += "  stream << '\\n';\n"
  res += "}\n"
  return res
end

def to_log_write_line_pretty_print( name, hsc )
  fds   = hsc[:fields];
  len   = fds.map { |f| f[:name].length }.max
  maxsz = fds.map { |f| f[:size].to_i }.max
  res  = "void\n#{name}_log_write_line_pretty_print( std::ostream & stream, #{name} const & S ) {\n"
  fds.each do |f|
    n   = f[:name];
    sz  = f[:size].to_i;
    if sz > 1 then
      res += "  for ( int i_count=0; i_count<#{sz}; ++i_count )\n"
      res += "    stream <<  \"#{n}[ \" << i_count << \"] = \" << S.#{n}[i_count] << '\\n';\n"
    else
      res += "  stream << \"#{n} = \" << S.#{n} << '\\n';\n"
    end
  end
  res += "  stream << '\\n';\n"
  res += "}\n"
  return res
end
def to_log_read_line( name, hsc )
  fds   = hsc[:fields];
  len   = fds.map { |f| f[:name].length }.max
  maxsz = fds.map { |f| f[:size].to_i }.max
  res  = "void\n#{name}_log_read_line( std::istream & stream, #{name} & S ) {\n"
  res += "  std::istringstream iss;\n  std::string str;\n"
  res += "  getline( stream, str);\n  iss.str(str);\n"
  fds.each do |f|
    n   = f[:name];
    sz  = f[:size].to_i;
    if sz > 1 then
      res += "  for ( int i_count=0; i_count<#{sz}; ++i_count )\n"
      res += "    iss >> S.#{n}[i_count];\n"
    else
      res += "  iss >> S.#{n};\n"
    end
  end
  res += "}\n"
  return res
end

#####  #  #  ####  #  #  ####  #   #
#   #  # #    #    #  #  #  #  ##  #
####    #     #    ####  #  #  # # #
#      #      #    #  #  ####  #  ## (module struck pack/unpack)

def to_Python_decoding_key( name, hsc )
  fds   = hsc[:fields]; 
  len   = fds.map { |f| f[:name].length }.max
  maxsz = fds.map { |f| f[:size].to_i }.max
  # first part of decoding key (name + !)
  res   = "#{name}_DK = '" 
  res   += "!"; # network standard for byte order in python struct module
  dim   = 0;   # initialize dimension
  fds.each do |f|
    tv = f[:type];
    n  = f[:name];
    sz = f[:size].to_i;
    for i in 1..sz
      res += "#{type_to_Python_struct(tv)}"
      dim += sz*type_to_size(tv);
    end
  end
  res += "'"
  res += "\n    # size of the serialized version of struct #{name}\n"
  res += "    # #{name} size  #{dim}\n"
  res += "    # #{name} n fields #{fds.size}\n"
  return res
end

def to_Python_dict( name, hsc )
  fds   = hsc[:fields]; 
  len   = fds.map { |f| f[:name].length }.max
  maxsz = fds.map { |f| f[:size].to_i }.max
  res   = "def #{name}_decode( payload ):\n" # network standard for byte order in python struct module
  res   += "    # decode #{name} from packed binary data to python dictonary\n"
  res   += "    " 
  res   += to_Python_decoding_key( name, hsc )
  i = 0
  index_field = 0
  res   += "\n    msg = struct.unpack( #{name}_DK , payload )"
  res   += "\n    return { '_message_type_' : '#{name}' , "
  fds.each do |f|
    # get properties
    tv = f[:type];
    n  = f[:name];
    sz = f[:size].to_i;
    # add field name
    res += "'#{f[:name]}' : "
    # add field content (scalar or vector)
    if sz <= 1 then
      res += "msg[#{i}]"
       i += 1
    else
      res += " ["
      for j in 1..sz
        res += " msg[#{i}] "
        res += "," unless j == sz
        i += 1
      end
      res += "] "
    end
    index_field += 1
    res += " , " unless index_field == (fds.length)  # coma is needed till the last
  end
  res += " } "
  res += " \n\n\n "
  return res
end

def to_Python_dict_true_values( name, hsc )
  fds   = hsc[:fields]; 
  len   = fds.map { |f| f[:name].length }.max
  maxsz = fds.map { |f| f[:size].to_i }.max
  res   = "def #{name}_decode_true_values( payload ):\n" # network standard for byte order in python struct module
  res   += "    # decode #{name} from packed binary data to python dictonary, returning true values (no gain/offset)\n"
  res   += "    " 
  res   += to_Python_decoding_key( name, hsc )
  i = 0
  index_field = 0
  res   += "\n    msg = struct.unpack( #{name}_DK , payload )"
  res   += "\n    return { '_message_type_' : '#{name}' , "
  fds.each do |f|
    # get properties
    tv = f[:type];
    n  = f[:name];
    sz = f[:size].to_i;
    # add field name
    res += "'#{f[:name]}' : "
    # add field content (scalar or vector)
    if sz <= 1 then
      res += "msg[#{i}] / #{f[:gain]}" # in future add offset
       i += 1
    else
      res += " ["
      for j in 1..sz
        res += " msg[#{i}] / #{f[:gain]} " # in future add offset
        res += "," unless j == sz
        i += 1
      end
      res += "] "
    end
    index_field += 1
    res += " , " unless index_field == (fds.length)  # coma is needed till the last
  end
  res += " } "
  res += " \n\n\n "
  return res
end

def from_Python_dict( name, hsc )

  fds   = hsc[:fields]; 
  len   = fds.map { |f| f[:name].length }.max
  maxsz = fds.map { |f| f[:size].to_i }.max
  res   = "def #{name}_encode( dict ):\n" # network standard for byte order in python struct module
  res   += "    # encode #{name} from python dictonary to packed binary data\n"
  res   += "    " 
  res   += to_Python_decoding_key( name, hsc )
  i = 0
  index_field = 0
  res   += "\n    return struct.pack( #{name}_DK , " # start writing the function
  fds.each do |f|
    # get properties
    tv = f[:type];
    n  = f[:name];
    sz = f[:size].to_i;
    # extract field content (scalar or vector)
    if sz <= 1 then
      res += "dict['#{f[:name]}']"
      i += 1
    else
      for j in 0..sz-1
        res += " dict['#{f[:name]}'][#{j}] "
        res += "," unless j == (sz-1)
        i += 1
      end
    end
    index_field += 1
    res += " , " unless index_field == (fds.length)  # coma is needed till the last
  end
  res += " ) "
  res += " \n\n\n "
  return res

end

def from_Python_dict_true_values( name, hsc )

  fds   = hsc[:fields]; 
  len   = fds.map { |f| f[:name].length }.max
  maxsz = fds.map { |f| f[:size].to_i }.max
  res   = "def #{name}_encode_true_values( dict ):\n" # network standard for byte order in python struct module
  res   += "    # encode #{name} from python dictonary to packed binary data, using gain/offset free values\n"
  res   += "    " 
  res   += to_Python_decoding_key( name, hsc )
  i = 0
  index_field = 0
  res   += "\n    return struct.pack( #{name}_DK , " # start writing the function
  fds.each do |f|
    # get properties
    tv = f[:type];
    n  = f[:name];
    sz = f[:size].to_i;
    # extract field content (scalar or vector)
    if sz <= 1 then
      res += "dict['#{f[:name]}'] * #{f[:gain]} " # add offset in future
      i += 1
    else
      for j in 0..sz-1
        res += " dict['#{f[:name]}'][#{j}] * #{f[:gain]} " # add offset in future
        res += "," unless j == (sz-1)
        i += 1
      end
    end
    index_field += 1
    res += " , " unless index_field == (fds.length)  # coma is needed till the last
  end
  res += " ) "
  res += " \n\n\n "
  return res

end

#####  #  #  ####  #  #  ####  #   #
#   #  # #    #    #  #  #  #  ##  #
####    #     #    ####  #  #  # # #
#      #      #    #  #  ####  #  ## MQTT utlities

def to_Python_MQTT_topic( name, hsc, data )

  fds   = hsc[:fields]; 
  len   = fds.map { |f| f[:name].length }.max
  maxsz = fds.map { |f| f[:size].to_i }.max
  res   = "def #{name}_MQTT_topic( dict ):\n" # network standard for byte order in python struct module
  res   += "    # from #{name} from python dictonary to mqtt topic\n"
  res   += "    " 
  main_topic  = data[:main_topic]
  subtopic    = data[name][:subtopic]
  subsubtopic = data[name][:subsubtopic]

  if subsubtopic and subsubtopic.length > 0 then
    res += "    return '#{main_topic}/#{subtopic}/' + str(dict['#{subsubtopic}'])\n"
  else
    res += "    return '#{main_topic}/#{subtopic}'\n"
  end

  return res
end

def compare_Python_MQTT_topic( name , data )

  res   = "def #{name}_MQTT_topic_compare( topic ):\n" 
  res   += "    # return true if the topic is the one of #{name}\n"
  res   += "    " 
  main_topic  = data[:main_topic]
  subtopic    = data[name][:subtopic]
  
  res += "    return '#{main_topic}/#{subtopic}' in topic\n"

  return res
end

def to_Python_dict_universal( data )

  res   = "def all_MQTT_decoding( topic , payload ):\n" 
  res   += "    # return the proper decoded dictionary based on the base topic\n"
  res   += "    dict = {}\n"
  res   += "    if not topic: # null string return false\n"
  res   += "        print('empty topic')\n"
  data.keys.each do |tag|
    if tag != :origin_file and tag != :main_topic and data[tag][:active] then
      res += "    elif #{tag}_MQTT_topic_compare( topic ):\n"
      res += "        dict = #{tag}_decode( payload )\n"
    end
  end
  res   += "    else:\n"
  res   += "        print('unmanaged topic:' + topic + ' - message discarderd')\n"
  res   += "    return dict\n"
  return res

end

def to_Python_dict_universal_true_values( data )

  res   = "def all_MQTT_decoding_true_values( topic , payload ):\n" 
  res   += "    # return the proper decoded dictionary based on the base topic\n"
  res   += "    dict = {}\n"
  res   += "    if not topic: # null string return false\n"
  res   += "        print('empty topic')\n"
  data.keys.each do |tag|
    if tag != :origin_file and tag != :main_topic and data[tag][:active] then
      res += "    elif #{tag}_MQTT_topic_compare( topic ):\n"
      res += "        dict = #{tag}_decode_true_values( payload )\n"
    end
  end
  res   += "    else:\n"
  res   += "        print('unmanaged topic:' + topic + ' - message discarderd')\n"
  res   += "    return dict\n"
  return res

end