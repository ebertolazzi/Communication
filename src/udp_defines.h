
/* ============================================================================

 UDP communication with limited packed size

 Author: Enrico Bertolazzi, Francesco Biral, Gastone Pietro Rosati Papini

 ============================================================================ */

#ifndef __UDP_DEFINES_HH
#define __UDP_DEFINES_HH

#ifdef __cplusplus
  #include <cstdint>
  using std::int32_t;
  using std::int64_t;
  using std::uint32_t;
  using std::uint64_t;
  extern "C" {
#else
  #include <stdint.h>
#endif

#if defined (_DS1401)
  #include "ds1401_defines.h"
#endif

// Connection settings
#define DEFAULT_SERVER_IP "127.0.0.1"
#define SERVER_PORT       25000             // Server port
#define PACKET_BYTES      1472            // Maximum packet bytes
//#define PACKET_BYTES      90                // Maximum packet bytes
#define SUB_PACKET_SIZE   (PACKET_BYTES-20) // PACKET_BYTES - packet header

// Times
#define SLEEP_MS             1
#define APP_TIMEOUT_MS      50
#define RECV_SND_TIMEOUT_MS  5  // Warning: windows has an undocumented minimum limit of about 500 ms

// If the timeout is less than 400 ms it creates a non-blocking socket
#ifdef _WIN32
  #pragma warning (disable : 4820)
  #if RECV_SND_TIMEOUT_MS <= 400
    #define WIN_NONBLOCK
  #endif
#endif

typedef struct {
  int32_t  server_run;                // 1: run server, 0: stop server
  uint32_t total_packet_size;         // total length of the packet
  uint32_t sub_packet_position;       // sub packet position in the message
  uint32_t sub_packet_size;           // sub packet size
  int32_t  datagram_id;               // message ID
  char     datagram_part[SUB_PACKET_SIZE]; // part of datagram message
} datagram_part_t;

// Packet union
typedef union {
  uint8_t         data_buffer[SUB_PACKET_SIZE];
  datagram_part_t data_struct;
} packet_t;

typedef struct {
  int32_t  server_run;
  int32_t  datagram_id;
  uint32_t total_packet_size;
  uint32_t sub_packet_size;
  uint32_t received_packets;
  uint32_t n_packets;
  uint64_t start_time_ms;
} packet_info_t;

extern
void
Packet_Init( packet_info_t * pi, uint64_t start_time_ms );

extern
void
Packet_Add_to_buffer(
  packet_info_t  * pi,
  packet_t const * pk,
  uint8_t          buffer[],
  uint32_t         buffer_size
);

extern
void
Packet_Build_from_buffer(
  uint8_t const buffer[],
  uint32_t      packet_size,
  uint32_t      pos,
  int32_t       datagram_id,
  int32_t       run,
  packet_t    * pk
);

extern
uint32_t
Packet_Number( uint32_t packet_size );

#ifdef _WIN32
  #include <Winsock2.h>
#else
  #include <arpa/inet.h>
#endif

#include <string.h>

// --------------------------------------------------

/* Get time function (milliseconds) */
extern uint64_t get_time_ms( void );

/* Sleep function (milliseconds) */
extern void sleep_ms( uint32_t time_sleep_ms );

// --------------------------------------------------

//#define PACK_FLOAT

#include "buffer_defines.h"

#ifdef __cplusplus
}
#endif

#endif
