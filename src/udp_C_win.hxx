#pragma comment (lib, "Ws2_32.lib")

#include <Windows.h>

#ifndef WIN32_LEAN_AND_MEAN
  #define WIN32_LEAN_AND_MEAN
#endif

#include <stdio.h>
#include <Winsock.h>
#include <Ws2tcpip.h>

/*\
 | Open socket
\*/

int
Socket_open( SocketData * pS, int bind_port ) {

  unsigned int   opt_buflen;
  struct timeval timeout;

  /*\
   | Create UDP socket
  \*/

  unsigned long nonblock;
  DWORD         timeout_win;
  WSADATA       wsa;
  int           rcvbufsize;

  pS->socket_id = 0;

  if ( WSAStartup(MAKEWORD(2, 2), &wsa) != 0 ) {
    printf( "WSAStartup() failed. Error Code: %d\n", WSAGetLastError() );
    return FALSE;
  }

  pS->socket_id = (int)socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);

  if ( pS->socket_id == INVALID_SOCKET) {
    printf( "socket() failed. Error Code: %d\n", WSAGetLastError() );
    return FALSE;
  }

  rcvbufsize = 40000;
  setsockopt( pS->socket_id,
              SOL_SOCKET,
              SO_RCVBUF,
              (char*)&rcvbufsize, sizeof(rcvbufsize) );

  /*\
   | Set send buffer size limit
  \*/

  opt_buflen = PACKET_BYTES;
  if ( setsockopt( pS->socket_id,
                   SOL_SOCKET,
                   SO_SNDBUF,
                   (char *)&opt_buflen,
                   sizeof(opt_buflen) ) == SOCKET_ERROR ) {
    printf( "setsockopt() failed. Error Code: %d\n", WSAGetLastError() );
    return FALSE;
  }

  /*\
   | Set send and receive time-outs
   |
   | Windows: it is used a non-blocking socket if defined time-out <= 400 ms
  \*/

  timeout.tv_sec  = 0;
  timeout.tv_usec = RECV_SND_TIMEOUT_MS * 1000;
  #if defined(WIN_NONBLOCK)
  nonblock = 1;
  if ( ioctlsocket( pS->socket_id,
                    FIONBIO,
                    &nonblock) == SOCKET_ERROR ) {
    printf( "ioctlsocket() failed. Error Code: %d\n", WSAGetLastError() );
    return FALSE;
  }
  #else
  timeout_win = timeout.tv_sec * 1000 + timeout.tv_usec / 1000;  // timeout in ms
  if ( setsockopt( pS->socket_id,
                   SOL_SOCKET,
                   SO_SNDTIMEO,
                   (char const *)&timeout_win,
                   sizeof(DWORD) ) == SOCKET_ERROR ) {
    printf( "setsockopt() failed. Error Code: %d\n", WSAGetLastError() );
    return FALSE;
  }
  if ( setsockopt( pS->socket_id,
                   SOL_SOCKET,
                   SO_RCVTIMEO,
                   (char const *)&timeout_win,
                   sizeof(DWORD) ) == SOCKET_ERROR ) {
    printf( "setsockopt() failed. Error Code: %d\n", WSAGetLastError() );
    return FALSE;
  }
  #endif

  /*\
   | If it is a server, bind socket to port
  \*/

  if ( bind_port ) {
    if ( bind( pS->socket_id,
               (struct sockaddr*) &pS->target_addr,
               sizeof(pS->target_addr) ) == SOCKET_ERROR ) {
      printf( "bind() failed. Error Code: %d\n", WSAGetLastError() );
      return FALSE;
    }
  }
  return TRUE;
}

/*\
 | Close socket
\*/

int
Socket_close( SocketData * pS ) {
  if ( closesocket(pS->socket_id) == SOCKET_ERROR ) {
    printf( "setsockopt() failed. Error Code: %d\n", WSAGetLastError() );
    WSACleanup();
    return FALSE;
  }
  WSACleanup();
  return TRUE;
}
