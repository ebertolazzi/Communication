
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
  puts "type_to_C: unknown name of #{t}"
  end
  return res
end

def type_to_C_simulink( t )
  res = ""
  case t
  when /^double$/
    res = "real64_T"
  when /^single$/     
    res = "real32_T"
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

def to_size( name_vec )
  name = name_vec[0];
  vec  = name_vec[1];
  res  = ""
  dim  = 0;
  vec.each do |v|
    tv   = v[0].split(':')
    sz   = type_to_size(tv[0])
    sz  *= tv[1].to_i if tv[1]
    dim += sz
  end
  res = "#define #{name}_size #{dim}\n"
  return res
end

def to_print( name_vec )
  name = name_vec[0];
  vec  = name_vec[1];
  res  = "void\n#{name}_print( #{name} const * S ) {\n"
  res += "  int i_count;\n"
  vec.each do |v|
    tv  = v[0].split(':')
    t   = type_to_C(tv[0])
    fmt = type_to_C_fmt(tv[0])
    n   = v[1];
    if tv[1] then
      res += "  for ( i_count=0; i_count<#{tv[1]}; ++i_count )\n"
      res += "    printf( \"#{n}[%d] = %#{fmt}\\n\", i_count, S->#{n}[i_count]);\n"
    else 
      res += "  printf( \"#{n} = %#{fmt}\\n\", S->#{n});\n"
    end
  end
  res += "}\n"
  return res
end

def to_buffer( name_vec )
  name = name_vec[0];
  vec  = name_vec[1];
  res  = "void\n#{name}_to_buffer(\n  #{name} const * S,\n  uint8_t buffer[]\n) {\n"
  res += "  int i_count;\n  uint8_t * ptr = buffer;\n"
  vec.each do |v|
    tv = v[0].split(':')
    t  = type_to_C(tv[0])
    n  = v[1];
    if tv[1] then
      res += "  for ( i_count=0; i_count<#{tv[1]}; ++i_count )\n"
      res += "    { #{tv[0]}_to_buffer( S->#{n}[i_count], ptr ); ptr += #{type_to_size(tv[0])}; }\n"
    else 
      res += "  #{tv[0]}_to_buffer( S->#{n}, ptr ); ptr += #{type_to_size(tv[0])};\n"
    end
  end
  res += "}\n"
  return res
end

def from_buffer( name_vec )
  name = name_vec[0];
  vec  = name_vec[1];
  res  = "void\nbuffer_to_#{name}(\n  uint8_t const buffer[],\n  #{name} * S\n) {\n"
  res += "  int i_count;\n  uint8_t const * ptr = buffer;\n"
  vec.each do |v|
    tv = v[0].split(':')
    t  = type_to_C(tv[0])
    n  = v[1];
    if tv[1] then
      res += "  for ( i_count=0; i_count<#{tv[1]}; ++i_count )\n"
      res += "    { buffer_to_#{tv[0]}( ptr, & S->#{n}[i_count] ); ptr += #{type_to_size(tv[0])}; }\n"
    else 
      res += "  buffer_to_#{tv[0]}( ptr, &S->#{n} ); ptr += #{type_to_size(tv[0])};\n"
    end
  end
  res += "}\n"
  return res
end

def to_C_struct( name_vec )
  name   = name_vec[0];
  vec    = name_vec[1];
  res    = "typedef struct {\n";
  spaces = " " * 34
  vec.each do |v|
    tv    = v[0].split(':')
    t     = type_to_C(tv[0])
    n     = v[1];
    n    += "[" + tv[1] + "]" if tv[1] 
    n    += ";";
    c     = v[2].gsub(/\n|\r/," */\n"+spaces+"/* ");
    res  += "  #{t.ljust(10)} #{n.ljust(20)} /* #{c} */\n"
  end
  res += "} #{name};\n\n"
  res += to_size(name_vec)
  res += "\nextern\nvoid\nbuffer_to_#{name}( uint8_t const buffer[], #{name} * S );\n"
  res += "\nextern\nvoid\n#{name}_to_buffer( #{name} const * S, uint8_t buffer[] );\n"
  res += "\nextern\nvoid\n#{name}_print( #{name} const * S );\n\n"
  return res
end

def to_MATLAB_struct( name_vec )
  name   = name_vec[0]
  vec    = name_vec[1]
  spaces = " " * 34
  res    = ""
  vec.each do |v|
    tv   = v[0].split(':')
    n    = v[1]
    nn   = "1";
    nn   = tv[1] if tv[1] 
    t    = tv[0].downcase
    c    = v[2].gsub(/\n|\r/,"\n"+spaces+"% ");
    res += "#{name}.#{n} = #{tv[0]}(zeros(#{nn},1)); % #{c}\n"
  end
  return res
end

def to_SIMULINK_struct( name_vec )
  name   = name_vec[0];
  vec    = name_vec[1];
  res    = "typedef struct {\n";
  spaces = " " * 34
  vec.each do |v|
    tv    = v[0].split(':')
    t     = type_to_C_simulink(tv[0])
    n     = v[1];
    n    += "[" + tv[1] + "]" if tv[1] 
    n    += ";";
    c     = v[2].gsub(/\n|\r/," */\n"+spaces+"/* ");
    res  += "  #{t.ljust(10)} #{n.ljust(20)} /* #{c} */\n"
  end
  res += "} #{name};\n\n"
  res += to_size(name_vec)
  res += "\nextern\nvoid\nbuffer_to_#{name}( uint8_t const buffer[], #{name} * S );\n"
  res += "\nextern\nvoid\n#{name}_to_buffer( #{name} const * S, uint8_t buffer[] );\n\n"
  return res
end

def to_SIMULINK_busInfo( name_vec )
  name   = name_vec[0];
  vec    = name_vec[1];
  res    = "  /* Bus Information */\n"
  res   += "  int_T id;\n\n"
  res   += "  slDataTypeAccess *dta = ssGetDataTypeAccess(S);\n"
  res   += "  char const * bpath = ssGetPath(S);\n";
	res   += "  DTypeId #{name}_strId = ssGetDataTypeId(S, \"" + name +"\");\n"
	res   += "  busInfoStruct *busInfo = (busInfoStruct *)malloc(#{vec.size}*sizeof(busInfoStruct));\n"
	res   += "  if(busInfo==NULL) {\n"
  res   += "    ssSetErrorStatus(S, \"Memory allocation failure\");\n"
  res   += "    return;\n"
  res   += "  }\n\n"
  res   += "  /* Calculate offsets of all primitive elements of the bus */\n\n"
  vec.each_with_index do |v,idx|
    tv    = v[0].split(':')
    t     = type_to_C_simulink2(tv[0])
    n     = 1;
    n     = tv[1] if tv[1] 
    res  += "  busInfo[#{idx}].offset   = dtaGetDataTypeElementOffset(dta, bpath, #{name}_strId, #{idx});\n"
    res  += "  id = ssGetDataTypeId(S, \"#{t}\");\n"
    res  += "  if( id == INVALID_DTYPE_ID) ssPrintf(\"Bad type '#{t}' for input N.#{idx}\\n\");\n"
    res  += "  busInfo[#{idx}].elemSize = dtaGetDataTypeSize(dta, bpath, id);\n"
    res  += "  busInfo[#{idx}].numElems = #{n};\n"
  end
  res += "  ssSetUserData(S, busInfo);\n"
  return res
end

def to_SIMULINK_busInfo_in_data( name_vec )
  name   = name_vec[0];
  vec    = name_vec[1];
  res    = "  uint8_T *payload = (uint8_T *) ssGetInputPortSignal(S, 0);\n"
  res   += "  uint8_T *serialized_data = (uint8_T *) ssGetOutputPortRealSignal(S, 0);\n"
  res   += "  busInfoStruct* busInfo = (busInfoStruct *) ssGetUserData(S);"
  res   += "  uint32_T  nbyte;"
  res   += "  uint8_T * ptr;"
	res   += "  /* Temporary bus copy declarations */\n"
	res   += "  #{name} tmp;\n"
	res   += "  /* Copy input bus into temporary structure */\n\n"
  vec.each_with_index do |v,idx|
    tv    = v[0].split(':')
    t     = type_to_C_simulink(tv[0])
    n     = 1;
    n     = tv[1] if tv[1]
    res  += "  ptr   = payload + busInfo[#{idx}].offset;\n";
    res  += "  nbyte = busInfo[#{idx}].elemSize * busInfo[#{idx}].numElems;\n"
    res  += "  (void) memcpy( &tmp.#{v[1]}, ptr, nbyte );\n"
    #res  += "  if ( busInfo[#{idx}].elemSize > 4 ) ssPrintf(\"#{v[1]} = %g\\n\", tmp.#{v[1]} );\n\n"
    #res  += "  else                                ssPrintf(\"#{v[1]} (I) = %d\\n\", tmp.#{v[1]} );\n\n"
  end
  res += "  #{name}_to_buffer(&tmp, serialized_data);\n"
  return res
end


def to_SIMULINK_busInfo_in_data_rtw( name_vec )
  name   = name_vec[0];
  vec    = name_vec[1];
  res    = "  uint8_T * payload         = (uint8_T *) ssGetInputPortSignal(S, 0);\n"
  res   += "  uint8_T * serialized_data = (uint8_T *) ssGetOutputPortRealSignal(S, 0);\n"
  res   += "  /* Temporary bus copy declarations */\n"
  res   += "  uint32_T nbyte;\n"
	res   += "  #{name} tmp;\n"
	res   += "  /* Copy input bus into temporary structure */\n\n"
  offs = 0;
  vec.each_with_index do |v,idx|
    tv    = v[0].split(':')
    t     = type_to_C_simulink(tv[0])
    sz    = type_to_size(tv[0])
    n     = 1;
    n     = tv[1] if tv[1]
    rd    = offs % sz;
    offs += rd; # add offset for paddind
    res  += "  nbyte = #{n} * #{sz};\n"
    res  += "  (void) memcpy( &tmp.#{v[1]}, payload + #{offs}, nbyte );\n"
    offs += n.to_i*sz.to_i;
  end
  res += "  #{name}_to_buffer(&tmp, serialized_data);\n"
  return res
end

def to_SIMULINK_message( name_vec, no_size = false )
  name   = name_vec[0]
  vec    = name_vec[1]
  spaces = " " * 34
  res    = ""
  vec.each_with_index  do |v,ipos|
    tv   = v[0].split(':')
    n    = v[1]
    nn   = "1";
    nn   = tv[1] if tv[1] 
    t    = type_to_SIMULINK(tv[0])
    res += "  /* Output Port #{ipos} */\n"
    res += "  ssSetOutputPortWidth( S, #{ipos}, #{nn} );\n" unless no_size
    res += "  ssSetOutputPortDataType( S, #{ipos}, #{t} );\n"
  end
  return res
end

def simulink_to_buffer( name_vec )
  name = name_vec[0];
  vec  = name_vec[1];
  res  = "static\nvoid\nsimulink_#{name}_to_buffer(\n"
  res += "  SimStruct *S,\n"
  res += "  uint8_t   *buffer\n) {\n"
  res += "  uint8_t * ptr = buffer;\n"
  vec.each_with_index do |v, ipos|
    tv = v[0].split(':')
    t  = type_to_C_simulink(tv[0])
    n  = v[1];
    sz = type_to_size(tv[0]);
    res += "  /* extract ``#{n}'' at position #{ipos} */\n"
    if tv[1] then
      res += "  { int i_count=0;\n"
      res += "    #{t} const ** p = (#{t} const **)ssGetInputPortSignalPtrs( S, #{ipos} );\n"
      res += "    for ( i_count=0; i_count < #{tv[1]}; ++i_count ) {\n"
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

def simulink_from_buffer( name_vec )
  name = name_vec[0];
  vec  = name_vec[1];
  res  = "static\nvoid\nsimulink_buffer_to_#{name}(\n"
  res += "  uint8_t const * buffer,\n"
  res += "  SimStruct     * S\n) {\n"
  res += "  uint8_t const * ptr = buffer;\n"
  vec.each_with_index do |v, ipos|
    tv = v[0].split(':')
    t  = type_to_C_simulink(tv[0])
    n  = v[1];
    sz = type_to_size(tv[0]);
    res += "  /* store ``#{n}'' at position #{ipos} */\n"
    if tv[1] then
      res += "  { int i_count=0;\n"
      res += "    #{t} * p = (#{t} *)ssGetOutputPortSignal( S, #{ipos} );\n"
      res += "    for ( i_count=0; i_count < #{tv[1]}; ++i_count ) {\n"
      res += "      buffer_to_#{tv[0]}( ptr, &p[i_count] ); ptr += #{sz};\n"
      res += "    }\n"
      res += "  }\n"
    else 
      res += "  { #{t} * p = (#{t} *)ssGetOutputPortSignal( S, #{ipos} );\n"
      res += "    buffer_to_#{tv[0]}( ptr, p ); ptr += #{sz};\n"
      res += "  }\n"
    end
  end
  res += "}\n\n"
  return res
end

def simulink_set_output_signal( name_vec )
  name = name_vec[0]
  vec  = name_vec[1]
  res  = "static\nvoid\nsimulink_#{name}_set_output_signal( SimStruct *S ) {\n"
  ##res += "  int nout = #{vec.size()};\n"
  ##res += "  if (!ssSetNumOutputPorts(S, nout)) return;\n\n"
  vec.each_with_index  do |v,ipos|
    tv   = v[0].split(':')
    n    = v[1]
    nn   = "1";
    nn   = tv[1] if tv[1] 
    t    = type_to_SIMULINK(tv[0])
    res += "  /* Map Output Port #{ipos} to ``#{n}'' */\n"
    res += "  ssSetOutputPortWidth( S, #{ipos}, #{nn} );\n"
    res += "  ssSetOutputPortDataType( S, #{ipos}, #{t} );\n"
    res += "  ssSetOutputPortComplexSignal( S, #{ipos}, COMPLEX_NO );\n"
  end
  res += "}\n\n"
  res += "#define #{name.upcase}_NUM_OUTPUTS #{vec.size()}\n\n"
  return res
end

def simulink_set_input_signal( name_vec )
  name = name_vec[0]
  vec  = name_vec[1]
  res  = "static\nvoid\nsimulink_#{name}_set_input_signal( SimStruct *S ) {\n"
  ##res += "  int nout = #{vec.size()};\n"
  ##res += "  if (!ssSetNumInputPorts(S, nout)) return;\n\n"
  vec.each_with_index  do |v,ipos|
    tv   = v[0].split(':')
    n    = v[1]
    nn   = "1";
    nn   = tv[1] if tv[1] 
    t    = type_to_SIMULINK(tv[0])
    res += "  /* Map Input Port #{ipos} to ``#{n}'' */\n"
    res += "  ssSetInputPortWidth( S, #{ipos}, #{nn} );\n"
    res += "  ssSetInputPortDataType( S, #{ipos}, #{t} );\n"
    res += "  ssSetInputPortComplexSignal( S, #{ipos}, COMPLEX_NO );\n"
    res += "  ssSetInputPortRequiredContiguous( S, #{ipos}, 1 );\n"
  end
  res += "}\n\n"
  res += "#define #{name.upcase}_NUM_INPUTS #{vec.size()}\n\n"
  return res
end