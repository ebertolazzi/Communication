/*\
 | File for interfaces
 | WARNING! AUTOMATICALLY GENERATED - DO NOT EDIT
 | CSV file: Signal_Map.csv
\*/

#include "udp_defines.h"
#include "codriver_interfaces_data_structs.h"
#include <stdio.h>

#ifdef __cplusplus
  extern "C" {
#endif

/* INPUT */
void
input_data_struct_to_buffer(
  input_data_struct const * S,
  uint8_t buffer[]
) {
  int i_count;
  uint8_t * ptr = buffer;
  ptr += int32_to_buffer( S->ID, ptr );
  ptr += int32_to_buffer( S->Version, ptr );
  ptr += int32_to_buffer( S->CycleNumber, ptr );
  ptr += double_to_buffer( S->ECUupTime, ptr );
  ptr += double_to_buffer( S->TimeStamp, ptr );
  ptr += int32_to_buffer( S->Status, ptr );
  ptr += double_to_buffer( S->x, ptr );
  ptr += double_to_buffer( S->y, ptr );
  ptr += double_to_buffer( S->z, ptr );
  ptr += double_to_buffer( S->yaw, ptr );
  ptr += double_to_buffer( S->vel, ptr );
  ptr += double_to_buffer( S->yaw_rate, ptr );
  ptr += double_to_buffer( S->ax, ptr );
  ptr += double_to_buffer( S->ay, ptr );
  ptr += double_to_buffer( S->delta, ptr );
  ptr += int32_to_buffer( S->mode, ptr );
  for ( i_count=0; i_count<4; ++i_count )
    ptr += double_to_buffer( S->thresholds[i_count], ptr );
}

void
buffer_to_input_data_struct(
  uint8_t const buffer[],
  input_data_struct * S
) {
  int i_count;
  uint8_t const * ptr = buffer;
  ptr += buffer_to_int32( ptr, &S->ID );
  ptr += buffer_to_int32( ptr, &S->Version );
  ptr += buffer_to_int32( ptr, &S->CycleNumber );
  ptr += buffer_to_double( ptr, &S->ECUupTime );
  ptr += buffer_to_double( ptr, &S->TimeStamp );
  ptr += buffer_to_int32( ptr, &S->Status );
  ptr += buffer_to_double( ptr, &S->x );
  ptr += buffer_to_double( ptr, &S->y );
  ptr += buffer_to_double( ptr, &S->z );
  ptr += buffer_to_double( ptr, &S->yaw );
  ptr += buffer_to_double( ptr, &S->vel );
  ptr += buffer_to_double( ptr, &S->yaw_rate );
  ptr += buffer_to_double( ptr, &S->ax );
  ptr += buffer_to_double( ptr, &S->ay );
  ptr += buffer_to_double( ptr, &S->delta );
  ptr += buffer_to_int32( ptr, &S->mode );
  for ( i_count=0; i_count<4; ++i_count )
    ptr += buffer_to_double( ptr, & S->thresholds[i_count] );
}

void
input_data_struct_print( input_data_struct const * S ) {
  int i_count;
  printf( "ID = %d\n", S->ID);
  printf( "Version = %d\n", S->Version);
  printf( "CycleNumber = %d\n", S->CycleNumber);
  printf( "ECUupTime = %lg\n", S->ECUupTime);
  printf( "TimeStamp = %lg\n", S->TimeStamp);
  printf( "Status = %d\n", S->Status);
  printf( "x = %lg\n", S->x);
  printf( "y = %lg\n", S->y);
  printf( "z = %lg\n", S->z);
  printf( "yaw = %lg\n", S->yaw);
  printf( "vel = %lg\n", S->vel);
  printf( "yaw_rate = %lg\n", S->yaw_rate);
  printf( "ax = %lg\n", S->ax);
  printf( "ay = %lg\n", S->ay);
  printf( "delta = %lg\n", S->delta);
  printf( "mode = %d\n", S->mode);
  for ( i_count=0; i_count<4; ++i_count )
    printf( "thresholds[%d] = %lg\n", i_count, S->thresholds[i_count]);
}


/* OUTPUT */
void
output_data_struct_to_buffer(
  output_data_struct const * S,
  uint8_t buffer[]
) {
  uint8_t * ptr = buffer;
  ptr += int32_to_buffer( S->ID, ptr );
  ptr += int32_to_buffer( S->Version, ptr );
  ptr += int32_to_buffer( S->CycleNumber, ptr );
  ptr += double_to_buffer( S->ECUupTime, ptr );
  ptr += double_to_buffer( S->TimeStamp, ptr );
  ptr += int32_to_buffer( S->Status, ptr );
  ptr += double_to_buffer( S->s, ptr );
  ptr += double_to_buffer( S->n, ptr );
  ptr += double_to_buffer( S->alpha, ptr );
  ptr += double_to_buffer( S->yaw, ptr );
  ptr += double_to_buffer( S->yawRate, ptr );
  ptr += double_to_buffer( S->velocity, ptr );
  ptr += double_to_buffer( S->ax, ptr );
  ptr += double_to_buffer( S->ay, ptr );
  ptr += double_to_buffer( S->steerAngle, ptr );
  ptr += double_to_buffer( S->gasPedal, ptr );
  ptr += double_to_buffer( S->x, ptr );
  ptr += double_to_buffer( S->y, ptr );
  ptr += double_to_buffer( S->z, ptr );
}

void
buffer_to_output_data_struct(
  uint8_t const buffer[],
  output_data_struct * S
) {
  uint8_t const * ptr = buffer;
  ptr += buffer_to_int32( ptr, &S->ID );
  ptr += buffer_to_int32( ptr, &S->Version );
  ptr += buffer_to_int32( ptr, &S->CycleNumber );
  ptr += buffer_to_double( ptr, &S->ECUupTime );
  ptr += buffer_to_double( ptr, &S->TimeStamp );
  ptr += buffer_to_int32( ptr, &S->Status );
  ptr += buffer_to_double( ptr, &S->s );
  ptr += buffer_to_double( ptr, &S->n );
  ptr += buffer_to_double( ptr, &S->alpha );
  ptr += buffer_to_double( ptr, &S->yaw );
  ptr += buffer_to_double( ptr, &S->yawRate );
  ptr += buffer_to_double( ptr, &S->velocity );
  ptr += buffer_to_double( ptr, &S->ax );
  ptr += buffer_to_double( ptr, &S->ay );
  ptr += buffer_to_double( ptr, &S->steerAngle );
  ptr += buffer_to_double( ptr, &S->gasPedal );
  ptr += buffer_to_double( ptr, &S->x );
  ptr += buffer_to_double( ptr, &S->y );
  ptr += buffer_to_double( ptr, &S->z );
}

void
output_data_struct_print( output_data_struct const * S ) {
  printf( "ID = %d\n", S->ID);
  printf( "Version = %d\n", S->Version);
  printf( "CycleNumber = %d\n", S->CycleNumber);
  printf( "ECUupTime = %lg\n", S->ECUupTime);
  printf( "TimeStamp = %lg\n", S->TimeStamp);
  printf( "Status = %d\n", S->Status);
  printf( "s = %lg\n", S->s);
  printf( "n = %lg\n", S->n);
  printf( "alpha = %lg\n", S->alpha);
  printf( "yaw = %lg\n", S->yaw);
  printf( "yawRate = %lg\n", S->yawRate);
  printf( "velocity = %lg\n", S->velocity);
  printf( "ax = %lg\n", S->ax);
  printf( "ay = %lg\n", S->ay);
  printf( "steerAngle = %lg\n", S->steerAngle);
  printf( "gasPedal = %lg\n", S->gasPedal);
  printf( "x = %lg\n", S->x);
  printf( "y = %lg\n", S->y);
  printf( "z = %lg\n", S->z);
}


#ifdef __cplusplus
}
#endif
