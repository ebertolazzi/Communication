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

#ifdef __clang__
#pragma clang diagnostic ignored "-Wdouble-promotion"
#elif __llvm__
#pragma GCC diagnostic ignored "-Wdouble-promotion"
#else
#pragma GCC diagnostic ignored "-Wdouble-promotion"
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
<%= to_SIMULINK_struct( @tag, @value ) %>

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

<%= simulink_to_buffer(@tag, @value) %>
<%= simulink_from_buffer(@tag, @value) %>
<%= simulink_set_output_signal(@tag, @value) %>
<%= simulink_set_input_signal(@tag, @value) %>

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

#include "buffer_defines.h"
#include "<%= @tag %>_simulink.h"
#include <stdio.h>
#include <string.h>

#ifdef __cplusplus
  extern "C" {
#endif

#define S_FUNCTION_LEVEL 2
#define S_FUNCTION_NAME  <%= @tag %>

/*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/
/* %%%-SFUNWIZ_defines_Changes_BEGIN --- EDIT HERE TO _END */
#define NUM_INPUTS            1
/* Input Port  0 */
#define IN_PORT_0_NAME        payload // @@@@@@@@@@@@@@@@@@@@
#define INPUT_0_WIDTH         1
#define INPUT_DIMS_0_COL      1
#define INPUT_0_DTYPE         real_T
#define INPUT_0_COMPLEX       COMPLEX_NO
#define IN_0_FRAME_BASED      FRAME_NO
#define IN_0_BUS_BASED        1
#define IN_0_BUS_NAME         <%= @tag %>
#define IN_0_DIMS             1-D
#define INPUT_0_FEEDTHROUGH   1
#define IN_0_ISSIGNED         0
#define IN_0_WORDLENGTH       8
#define IN_0_FIXPOINTSCALING  1
#define IN_0_FRACTIONLENGTH   9
#define IN_0_BIAS             0
#define IN_0_SLOPE            0.125

#define NUM_OUTPUTS           1
/* Output Port  0 */
#define OUT_PORT_0_NAME       serialized_data  // @@@@@@@@@@@@@@@@@@@@
#define OUTPUT_0_WIDTH        <%= @tag %>_size // @@@@@@@@@@@@@@@@@@@@
#define OUTPUT_DIMS_0_COL     1
#define OUTPUT_0_DTYPE        uint32_T
#define OUTPUT_0_COMPLEX      COMPLEX_NO
#define OUT_0_FRAME_BASED     FRAME_NO
#define OUT_0_BUS_BASED       0
#define OUT_0_BUS_NAME        
#define OUT_0_DIMS            1-D
#define OUT_0_ISSIGNED        1
#define OUT_0_WORDLENGTH      8
#define OUT_0_FIXPOINTSCALING 1
#define OUT_0_FRACTIONLENGTH  3
#define OUT_0_BIAS            0
#define OUT_0_SLOPE           0.125

#define NPARAMS               0

#define SAMPLE_TIME_0         INHERITED_SAMPLE_TIME
#define NUM_DISC_STATES       0
#define DISC_STATES_IC        [0]
#define NUM_CONT_STATES       0
#define CONT_STATES_IC        [0]

#define SFUNWIZ_GENERATE_TLC  0
//#define SOURCEFILES           "__SFB__"  // @@@@@@@@@@@@@@@@@@@@
#define SOURCEFILES
#define PANELINDEX            8
#define USE_SIMSTRUCT         1
#define SHOW_COMPILE_STEPS    0
#define CREATE_DEBUG_MEXFILE  0
#define SAVE_CODE_ONLY        1
#define SFUNWIZ_REVISION      3.0

#include "simstruc.h"
//#include "sfun_bus_structs.h" NON SERVE
#include "codriver_interfaces_data_structs.h"

/*
 * Code Generation Environment flag (simulation or standalone target).
 */

static int_T isSimulationTarget;

/* Macro used to check if Simulation mode is set to accelerator */

// #define isBusDWorkPresent  ( ( ( !ssRTWGenIsCodeGen(S) || isSimulationTarget ) && !ssIsExternalSim(S) ) || ssIsRapidAcceleratorActive(S) )

/*====================*
 * S-function methods *
 *====================*/
/* Function: mdlInitializeSizes ===============================================
 * Abstract:
 *   Setup sizes of the various vectors.
 */

static
void
mdlInitializeSizes(SimStruct *S) {

  DECL_AND_INIT_DIMSINFO(inputDimsInfo);
  DECL_AND_INIT_DIMSINFO(outputDimsInfo);
  ssSetNumSFcnParams(S, NPARAMS);
  if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) {
    return; /* Parameter mismatch will be reported by Simulink */
  }

  //ssSetArrayLayoutForCodeGen(S, SS_COLUMN_MAJOR);

  ssSetSimStateCompliance(S, USE_DEFAULT_SIM_STATE);

  ssSetNumContStates(S, NUM_CONT_STATES);
  ssSetNumDiscStates(S, NUM_DISC_STATES);

  if (!ssSetNumInputPorts(S, NUM_INPUTS)) return;

  /* Register <%= @tag %>_str datatype for Input port 0 */

  #if defined(MATLAB_MEX_FILE)
  if (ssGetSimMode(S) != SS_SIMMODE_SIZES_CALL_ONLY) {
    DTypeId dataTypeIdReg;
    ssRegisterTypeFromNamedObject(S, "<%= @tag %>", &dataTypeIdReg);
    if(dataTypeIdReg == INVALID_DTYPE_ID) return;
    ssSetInputPortDataType(S, 0, dataTypeIdReg);
  }
  #endif
  ssSetInputPortWidth(S, 0, INPUT_0_WIDTH);
  ssSetInputPortComplexSignal(S, 0, INPUT_0_COMPLEX);
  ssSetInputPortDirectFeedThrough(S, 0, INPUT_0_FEEDTHROUGH);
  ssSetInputPortRequiredContiguous(S, 0, 1); /*direct input signal access*/
  ssSetBusInputAsStruct(S, 0, IN_0_BUS_BASED);
  ssSetInputPortBusMode(S, 0, SL_BUS_MODE);

  if (!ssSetNumOutputPorts(S, NUM_OUTPUTS)) return;
  ssSetOutputPortWidth(S, 0, OUTPUT_0_WIDTH);
  ssSetOutputPortDataType(S, 0, SS_UINT8);
  ssSetOutputPortComplexSignal(S, 0, OUTPUT_0_COMPLEX);

  ssSetNumPWork(S, 0);

  ssSetNumSampleTimes(S, 1);
  ssSetNumRWork(S, 0);
  ssSetNumIWork(S, 0);
  ssSetNumModes(S, 0);
  ssSetNumNonsampledZCs(S, 0);

  ssSetSimulinkVersionGeneratedIn(S, "9.2");

  /* Take care when specifying exception free code - see sfuntmpl_doc.c */
  ssSetOptions(S, (SS_OPTION_EXCEPTION_FREE_CODE |
                   SS_OPTION_WORKS_WITH_CODE_REUSE));
}

/* Function: mdlInitializeSampleTimes =========================================
 * Abstract:
 *    Specifiy  the sample time.
 */
static
void
mdlInitializeSampleTimes(SimStruct *S) {
  ssSetSampleTime(S, 0, SAMPLE_TIME_0);
  ssSetModelReferenceSampleTimeDefaultInheritance(S);
  ssSetOffsetTime(S, 0, 0.0);
}

#define MDL_SET_INPUT_PORT_DATA_TYPE
static
void
mdlSetInputPortDataType(SimStruct *S, int port, DTypeId dType) {
  ssSetInputPortDataType(S, 0, dType);
}

#define MDL_SET_OUTPUT_PORT_DATA_TYPE
static
void
mdlSetOutputPortDataType(SimStruct *S, int port, DTypeId dType) {
  ssSetOutputPortDataType(S, 0, dType);
}

#define MDL_SET_DEFAULT_PORT_DATA_TYPES
static
void
mdlSetDefaultPortDataTypes(SimStruct *S) {
  ssSetInputPortDataType(S, 0, SS_DOUBLE);
  ssSetOutputPortDataType(S, 0, SS_DOUBLE);
}

#define MDL_SET_WORK_WIDTHS
#if defined(MDL_SET_WORK_WIDTHS) && defined(MATLAB_MEX_FILE)

static
void
mdlSetWorkWidths(SimStruct *S) {
}

#endif

#define MDL_START  /* Change to #undef to remove function */

#if defined(MDL_START)
/* Function: mdlStart =======================================================
 * Abstract:
 *    This function is called once at start of model execution. If you
 *    have states that should be initialized once, this is the place
 *    to do it.
 */
static
void
mdlStart(SimStruct *S) {
}
#endif /*  MDL_START */

/* Function: mdlOutputs =======================================================
 *
 */
static
void
mdlOutputs(SimStruct *S, int_T tid) {
  <%= to_SIMULINK_busInfo_in_data_rtw(@tag, @value) %>
}

/* Function: mdlTerminate =====================================================
 * Abstract:
 *    In this function, you should perform any actions that are necessary
 *    at the termination of a simulation.  For example, if memory was
 *    allocated in mdlStart, this is the place to free it.
 */
static
void
mdlTerminate(SimStruct *S) {
  /* Free stored bus information */
}

#if 0
/* print <%= @tag %> struct on stdio */
<%= to_SIMULINK_busInfo( @tag, @value ) %>

/* serialize <%= @tag %> struct to buffer */
<%= to_SIMULINK_busInfo_in_data( @tag, @value ) %>

/* get buffer and un-serialize to <%= @tag %> struct */
<%= to_SIMULINK_busInfo_in_data_rtw( @tag, @value ) %>

/* get buffer and un-serialize to <%= @tag %> struct */
<%= to_SIMULINK_message( @tag, @value ) %>
#endif

#ifdef __cplusplus
};
#endif

#ifdef  MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif

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
  File.open( prefix+key.to_s+".h", "w" ) { |f| f.puts generate_c_header( key.to_s, value ) }
  File.open( prefix+key.to_s+".c", "w" ) { |f| f.puts generate_c_body( key.to_s, value )   }
  File.open( prefix+key.to_s+"_simulink.h", "w" ) { |f| f.puts generate_simulink_header( key.to_s, value ) }
  File.open( prefix+key.to_s+"_simulink.c", "w" ) { |f| f.puts generate_simulink_body( key.to_s, value )   }
end
