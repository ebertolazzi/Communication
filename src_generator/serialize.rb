
def type_to_size( t )
  sz = 0
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
    res = "hd"
  when /^uint8$/
    res = "hu"
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
    res = "lu"
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
    res = "single"
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
  maxsz = fds.map { |f| f[:size].length }.max
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

def to_buffer( name, hsc )
  fds   = hsc[:fields];
  len   = fds.map { |f| f[:name].length }.max
  maxsz = fds.map { |f| f[:size].length }.max
  res  = "void\n#{name}_to_buffer(\n  #{name} const * S,\n  uint8_t buffer[]\n) {\n"
  res += "  int i_count;\n" if maxsz > 1
  res += "  uint8_t * ptr = buffer;\n"
  fds.each do |f|
    tv  = f[:type];
    fmt = type_to_C_fmt(tv);
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
  maxsz = fds.map { |f| f[:size].length }.max
  res  = "void\nbuffer_to_#{name}(\n  uint8_t const buffer[],\n  #{name} * S\n) {\n"
  res += "  int i_count;\n" if maxsz > 1
  res += "  uint8_t * ptr = buffer;\n"
  fds.each do |f|
    tv  = f[:type];
    fmt = type_to_C_fmt(tv);
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

def to_mqtt_topic( name, data )
  main_topic  = data[:main_topic];
  subtopic    = data[name][:subtopic];
  subsubtopic = data[name][:subsubtopic];
  res  = "void\n#{name}_topic(\n"
  res += "  #{name} * S,\n"
  res += "  char topic[],\n"
  res += "  int topic_len\n"
  res += ") {\n"
  res += "  char const * topic = \"#{main_topic}/#{subtopic}\";\n"
  if subtopic and subtopic.length > 0 then
    res += "  snprintf( topic, topic_max_len, \"%s/%d\", topic, S->#{subsubtopic} );\n"
  else
    res += "  snprintf( topic, topic_max_len, \"%s\", topic );\n"
  end
  res += "}\n"
  return res
end

def to_C_struct( name, hsc )
  fds   = hsc[:fields];
  len   = fds.map { |f| f[:name].length }.max
  maxsz = fds.map { |f| f[:size].length }.max
  res   = "typedef struct {\n";
  dim   = 0;
  fds.each do |f|
    tv = f[:type];
    n  = f[:name];
    sz = f[:size].to_i;
    n += "[#{sz}]" if sz > 1
    n += ';'
    res += "  #{tv.ljust(6)} #{n.ljust(len+6)}"
    res += " /* #{f[:comment]} */\n"
    dim += type_to_size(tv);
  end
  res += "} #{name};\n\n"
  res += "#define #{name}_size #{dim}\n"
  res += "\nextern\nvoid\nbuffer_to_#{name}( uint8_t const buffer[], #{name} * S );\n"
  res += "\nextern\nvoid\n#{name}_to_buffer( #{name} const * S, uint8_t buffer[] );\n"
  res += "\nextern\nvoid\n#{name}_print( #{name} const * S );\n\n"
  return res
end

def to_MATLAB_struct( name, hsc )
  fds   = hsc[:fields];
  len   = fds.map { |f| f[:name].length }.max
  maxsz = fds.map { |f| f[:size].length }.max
  res   = "";
  fds.each do |f|
    tv = f[:type];
    n  = f[:name];
    sz = f[:size].to_i;
    res += "#{name}.#{n.ljust(len)} = #{tv}(zeros(#{sz},1)); % #{f[:comment]}\n"
  end
  return res
end

def to_SIMULINK_struct( name, hsc )
  fds   = hsc[:fields];
  len   = fds.map { |f| f[:name].length }.max
  maxsz = fds.map { |f| f[:size].length }.max
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
    dim += type_to_size(tv);
  end
  res += "} #{name};\n\n"
  res += "#define #{name}_size #{dim}\n"
  res += "\nextern\nvoid\nbuffer_to_#{name}( uint8_t const buffer[], #{name} * S );\n"
  res += "\nextern\nvoid\n#{name}_to_buffer( #{name} const * S, uint8_t buffer[] );\n\n"
  return res
end

def to_SIMULINK_busInfo( name, hsc )
  fds   = hsc[:fields];
  len   = fds.map { |f| f[:name].length }.max
  maxsz = fds.map { |f| f[:size].length }.max
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
  maxsz = fds.map { |f| f[:size].length }.max
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
    #res  += "  if ( busInfo[#{idx}].elemSize > 4 ) ssPrintf(\"#{v[1]} = %g\\n\", tmp.#{v[1]} );\n\n"
    #res  += "  else                                ssPrintf(\"#{v[1]} (I) = %d\\n\", tmp.#{v[1]} );\n\n"
    res += "\n";
  end
  res += "  #{name}_to_buffer(&tmp, serialized_data);\n"
  return res
end

def to_SIMULINK_busInfo_in_data_rtw( name, hsc )
  fds   = hsc[:fields];
  len   = fds.map { |f| f[:name].length }.max
  maxsz = fds.map { |f| f[:size].length }.max
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

def to_SIMULINK_message( name, hsc, no_size = false )
  fds   = hsc[:fields];
  len   = fds.map { |f| f[:name].length }.max
  maxsz = fds.map { |f| f[:size].length }.max
  res   = ""
  fds.each_with_index do |f,ipos|
    tv   = f[:type];
    t    = type_to_SIMULINK(tv);
    sz   = type_to_size(tv);
    res += "  /* Output Port #{ipos} */\n"
    res += "  ssSetOutputPortWidth( S, #{ipos}, #{sz} );\n" unless no_size
    res += "  ssSetOutputPortDataType( S, #{ipos}, #{t} );\n\n"
  end
  return res
end

def simulink_to_buffer( name, hsc )
  fds   = hsc[:fields];
  len   = fds.map { |f| f[:name].length }.max
  maxsz = fds.map { |f| f[:size].length }.max

  res  = "static\nvoid\nsimulink_#{name}_to_buffer(\n"
  res += "  SimStruct *S,\n"
  res += "  uint8_t   *buffer\n) {\n"
  res += "  uint8_t * ptr = buffer;\n"
  res += "  int   i_count = 0;\n" if maxsz > 1

  fds.each_with_index do |f,ipos|
    tv   = f[:type];
    t    = type_to_C_simulink(tv);
    sz   = type_to_size(tv);
    n    = f[:name];

    res += "  /* extract ``#{n}'' at position #{ipos} */\n"
    if tv[1] then
      res += "  { #{t} const ** p = (#{t} const **)ssGetInputPortSignalPtrs( S, #{ipos} );\n"
      res += "    for ( i_count=0; i_count < #{sz}; ++i_count ) {\n"
      res += "      #{tv[0]}_to_buffer( *p[i_count], ptr ); ptr += #{sz};\n"
      res += "    }\n"
      res += "  }\n"
    else 
      res += "  { #{t} const ** p = (#{t} const **)ssGetInputPortSignalPtrs( S, #{ipos} );\n"
      res += "    #{tv[0]}_to_buffer( **p, ptr ); ptr += #{sz};\n"
      res += "  }\n"
    end
  end
  res += "}\n\n"
  return res
end

def simulink_from_buffer( name, hsc )
  fds   = hsc[:fields];
  len   = fds.map { |f| f[:name].length }.max
  maxsz = fds.map { |f| f[:size].length }.max

  res  = "static\nvoid\nsimulink_buffer_to_#{name}(\n"
  res += "  uint8_t const * buffer,\n"
  res += "  SimStruct     * S\n) {\n"
  res += "  uint8_t const * ptr = buffer;\n"
  res += "  int         i_count = 0;\n" if maxsz > 1

  fds.each_with_index do |f,ipos|
    tv = f[:type];
    t  = type_to_C_simulink(tv);
    sz = type_to_size(tv);
    n  = f[:name];

    res += "  /* store ``#{n}'' at position #{ipos} */\n"
    res += "  { #{t} * p = (#{t} *)ssGetOutputPortSignal( S, #{ipos} );\n"
    if sz > 1 then
      res += "    for ( i_count=0; i_count < #{sz}; ++i_count )\n"
      res += "      ptr += buffer_to_#{tv}( ptr, &p[i_count] );\n"
    else
      res += "    ptr += buffer_to_#{tv}( ptr, p );\n"
    end
    res += "  }\n"
  end
  res += "}\n\n"
  return res
end

def simulink_set_output_signal( name, hsc )
  fds   = hsc[:fields];
  len   = fds.map { |f| f[:name].length }.max
  maxsz = fds.map { |f| f[:size].length }.max

  res  = "static\nvoid\nsimulink_#{name}_set_output_signal( SimStruct *S ) {\n"
  ##res += "  int nout = #{vec.size()};\n"
  ##res += "  if (!ssSetNumOutputPorts(S, nout)) return;\n\n"

  fds.each_with_index do |f,ipos|
    tv = f[:type];
    t  = type_to_SIMULINK(tv);
    sz = type_to_size(tv);
    n  = f[:name];

    res += "  /* Map Output Port #{ipos} to ``#{n}'' */\n"
    res += "  ssSetOutputPortWidth( S, #{ipos}, #{sz} );\n"
    res += "  ssSetOutputPortDataType( S, #{ipos}, #{t} );\n"
    res += "  ssSetOutputPortComplexSignal( S, #{ipos}, COMPLEX_NO );\n\n"
  end
  res += "}\n\n"
  res += "#define #{name.upcase}_NUM_OUTPUTS #{fds.size}\n\n"
  return res
end

def simulink_set_input_signal( name, hsc )
  fds   = hsc[:fields];
  len   = fds.map { |f| f[:name].length }.max
  maxsz = fds.map { |f| f[:size].length }.max

  res  = "static\nvoid\nsimulink_#{name}_set_input_signal( SimStruct *S ) {\n"
  ##res += "  int nout = #{vec.size()};\n"
  ##res += "  if (!ssSetNumInputPorts(S, nout)) return;\n\n"

  fds.each_with_index do |f,ipos|
    tv = f[:type];
    t  = type_to_SIMULINK(tv);
    sz = type_to_size(tv);
    n  = f[:name];

    res += "  /* Map Input Port #{ipos} to ``#{n}'' */\n"
    res += "  ssSetInputPortWidth( S, #{ipos}, #{sz} );\n"
    res += "  ssSetInputPortDataType( S, #{ipos}, #{t} );\n"
    res += "  ssSetInputPortComplexSignal( S, #{ipos}, COMPLEX_NO );\n"
    res += "  ssSetInputPortRequiredContiguous( S, #{ipos}, 1 );\n\n"
  end
  res += "}\n\n"
  res += "#define #{name.upcase}_NUM_INPUTS #{fds.size}\n\n"
  return res
end