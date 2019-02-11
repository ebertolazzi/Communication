
/* ============================================================================
 UDP communication with limited packed size
 ============================================================================ */

#ifndef __UDP_C_CLASS_HH
#define __UDP_C_CLASS_HH

#include "udp_defines.h"

#if defined(_WIN32) || defined(WIN32) || defined(_WIN64) || defined(WIN64)
  typedef int socklen_t;
#else
  #ifdef __linux__
    #include <linux/types.h>
  #else
    #include <sys/kernel_types.h>
  #endif
#endif

#ifdef __cplusplus
extern "C" {
#endif

#include <stdlib.h>
#include <string.h>

#ifndef UDP_TRUE
  #define UDP_TRUE 1
#endif

#ifndef UDP_FALSE
  #define UDP_FALSE -1
#endif

#ifndef __cplusplus
  #define nullptr NULL
#endif

typedef struct  {
  int                socket_id;
  int                server_run; // bool
  struct sockaddr_in target_addr;
  socklen_t          target_addr_len;
  uint64_t           timeout_ms;
} SocketData;

extern
void
Socket_new( SocketData * pS );

extern
void
Socket_check( SocketData * pS );

extern
void
Socket_open_as_client(
  SocketData * pS,
  char const   addr[],
  int          port
);

extern
void
Socket_open_as_server(
  SocketData * pS,
  int          port
);

extern
void
Socket_open_addr(
  SocketData * pS,
  char const   addr[],
  int          port
);

extern
int
Socket_open( SocketData * pS, int bind_port );

extern
int
Socket_close( SocketData * pS );

extern
int
Socket_send(
  SocketData * pS,
  int32_t      message_id,
  uint8_t      message[],
  uint32_t     message_size
);

extern
int
Socket_receive(
  SocketData * pS,
  int32_t    * message_id,
  uint8_t      message[],
  uint32_t     message_size,
  uint64_t     start_time
);

#ifdef __cplusplus
}
#endif

#endif
