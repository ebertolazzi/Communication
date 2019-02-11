/*\
 | File for interfaces
 | WARNING! AUTOMATICALLY GENERATED - DO NOT EDIT
 | CSV file: Signal_Map.csv
\*/

#ifndef CODRIVER_INTERFACES_DATA_STRUCTS_H
#define CODRIVER_INTERFACES_DATA_STRUCTS_H

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

#if defined(_DS1401)
  #include "ds1401_defines.h"
#endif

typedef struct {
  int32_t    ID;                  /* Enumeration  */
                                  /* 01=Scenario message */
                                  /* 11=Manoeuvre message, */
  int32_t    Version;             /* Value is: 1201 */
  int32_t    CycleNumber;         /* This is an increasing number */
  double     ECUupTime;           /* Means system up-time */
  double     TimeStamp;           /* UTC time difference after 1st January 1970, obtained from GPS time with leap seconds (Unix epoch) */
  int32_t    Status;              /* 0 = ACTIVE, 0 != Fail  (means working correctly or not) */
  double     x;                   /*  */
  double     y;                   /*  */
  double     z;                   /*  */
  double     yaw;                 /*  */
  double     vel;                 /*  */
  double     yaw_rate;            /*  */
  double     ax;                  /*  */
  double     ay;                  /*  */
  double     delta;               /*  */
  int32_t    mode;                /* 0 = NOT_DEFINED, 1 = ECO, 2 = NORMAL, 3 = SPORT */
  double     thresholds[4];       /*  */
} input_data_struct;

#define input_data_struct_size 140

extern
void
buffer_to_input_data_struct( uint8_t const buffer[], input_data_struct * S );

extern
void
input_data_struct_to_buffer( input_data_struct const * S, uint8_t buffer[] );

extern
void
input_data_struct_print( input_data_struct const * S );



typedef struct {
  int32_t    ID;                  /* Enumeration  */
                                  /* 01=Scenario message */
                                  /* 11=Manoeuvre message, */
  int32_t    Version;             /* Value is: 1201 */
  int32_t    CycleNumber;         /* This is an increasing number */
  double     ECUupTime;           /* Means system up-time */
  double     TimeStamp;           /* UTC time difference after 1st January 1970, obtained from GPS time with leap seconds (Unix epoch) */
  int32_t    Status;              /* 0 = ACTIVE, 0 != Fail  (means working correctly or not) */
  double     s;                   /* actual curvilinear coordinate w.r.t. ref. Line */
  double     n;                   /* actual suggested by optimal manoeuvre */
  double     alpha;               /* actual suggested by optimal manoeuvre */
  double     yaw;                 /* actual suggested by optimal manoeuvre */
  double     yawRate;             /* actual suggested by optimal manoeuvre */
  double     velocity;            /* actual suggested by optimal manoeuvre */
  double     ax;                  /* actual suggested by optimal manoeuvre */
  double     ay;                  /* actual suggested by optimal manoeuvre */
  double     steerAngle;          /* actual suggested by optimal manoeuvre */
  double     gasPedal;            /* actual suggested by optimal manoeuvre */
  double     x;                   /* actual suggested by optimal manoeuvre */
  double     y;                   /* actual suggested by optimal manoeuvre */
  double     z;                   /* actual suggested by optimal manoeuvre */
} output_data_struct;

#define output_data_struct_size 136

extern
void
buffer_to_output_data_struct( uint8_t const buffer[], output_data_struct * S );

extern
void
output_data_struct_to_buffer( output_data_struct const * S, uint8_t buffer[] );

extern
void
output_data_struct_print( output_data_struct const * S );


#ifdef __cplusplus
} // extern "C"
#endif

#endif
