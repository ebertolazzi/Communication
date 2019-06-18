#ifndef WIN32_LEAN_AND_MEAN
  #define WIN32_LEAN_AND_MEAN
#endif

#include <Windows.h>
#include <stdio.h>
#include <Winsock2.h>
#include <Ws2tcpip.h>

#pragma comment (lib, "Ws2_32.lib")

/*\
 |   ____             _        _
 |  / ___|  ___   ___| | _____| |_
 |  \___ \ / _ \ / __| |/ / _ \ __|
 |   ___) | (_) | (__|   <  __/ |_
 |  |____/ \___/ \___|_|\_\___|\__|
\*/

/*\
 | Open socket
\*/

Socket_open(
  SocketData * pS,
  int          bind_port
) {
  unsigned int   opt_buflen;
  struct timeval timeout;
  int            ret;

  /*\
   | Create UDP socket
  \*/

  unsigned long nonblock;
  WSADATA       wsa;
  int           rcvbufsize;
  #ifndef WIN_NONBLOCK
  DWORD         timeout_win;
  #endif
 
  pS->socket_id = 0;

  if ( WSAStartup(MAKEWORD(2, 2), &wsa) != 0 ) {
    printf( "WSAStartup() failed. Error Code: %d\n", WSAGetLastError() );
    return UDP_FALSE;
  }

  pS->socket_id = (int)socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);

  if ( pS->socket_id == INVALID_SOCKET) {
    printf( "socket() failed. Error Code: %d\n", WSAGetLastError() );
    return UDP_FALSE;
  }

  rcvbufsize = 40000;
  setsockopt(
    pS->socket_id,
    SOL_SOCKET,
    SO_RCVBUF,
    (char*)&rcvbufsize, sizeof(rcvbufsize)
  );

  /*\
   | Set send buffer size limit
  \*/

  opt_buflen = UDP_PACKET_BYTES;
  ret = setsockopt(
    pS->socket_id,
    SOL_SOCKET,
    SO_SNDBUF,
    (char *)&opt_buflen,
    sizeof(opt_buflen)
  );
  if ( ret == SOCKET_ERROR ) {
    printf( "setsockopt() failed. Error Code: %d\n", WSAGetLastError() );
    return UDP_FALSE;
  }

  /*\
   | Set send and receive time-outs
   |
   | Windows: it is used a non-blocking socket if defined time-out <= 400 ms
  \*/

  timeout.tv_sec  = 0;
  timeout.tv_usec = UDP_RECV_SND_TIMEOUT_MS * 1000;
  #ifdef WIN_NONBLOCK
  nonblock = 1;
  ret = ioctlsocket( pS->socket_id, FIONBIO, &nonblock);
  if ( ret == SOCKET_ERROR ) {
    printf( "ioctlsocket() failed. Error Code: %d\n", WSAGetLastError() );
    return UDP_FALSE;
  }
  #else
  timeout_win = timeout.tv_sec * 1000 + timeout.tv_usec / 1000;  // timeout in ms
  ret = setsockopt(
    pS->socket_id,
    SOL_SOCKET,
    SO_SNDTIMEO,
    (char const *)&timeout_win,
    sizeof(DWORD)
  );
  if ( ret == SOCKET_ERROR ) {
    printf( "setsockopt() failed. Error Code: %d\n", WSAGetLastError() );
    return UDP_FALSE;
  }
  ret = setsockopt(
    pS->socket_id,
    SOL_SOCKET,
    SO_RCVTIMEO,
    (char const *)&timeout_win,
    sizeof(DWORD)
  );
  if ( ret == SOCKET_ERROR ) {
    printf( "setsockopt() failed. Error Code: %d\n", WSAGetLastError() );
    return UDP_FALSE;
  }
  #endif

  /*\
   | If it is a server, bind socket to port
  \*/

  if ( bind_port ) {
    ret = bind(
      pS->socket_id,
      (struct sockaddr*) &pS->sock_addr,
      sizeof(pS->sock_addr)
    );
    if ( ret == SOCKET_ERROR ) {
      printf( "bind() failed. Error Code: %d\n", WSAGetLastError() );
      return UDP_FALSE;
    }
  }
  return UDP_TRUE;
}

/*\
 | Close socket
\*/

int
Socket_close( SocketData * pS ) {
  if ( closesocket(pS->socket_id) == SOCKET_ERROR ) {
    printf( "setsockopt() failed. Error Code: %d\n", WSAGetLastError() );
    WSACleanup();
    return UDP_FALSE;
  }
  WSACleanup();
  return UDP_TRUE;
}

/*\
 |   __  __       _ _   _               _
 |  |  \/  |_   _| | |_(_) ___ __ _ ___| |_
 |  | |\/| | | | | | __| |/ __/ _` / __| __|
 |  | |  | | |_| | | |_| | (_| (_| \__ \ |_
 |  |_|  |_|\__,_|_|\__|_|\___\__,_|___/\__|
\*/

int
MultiCast_open_as_sender(
  SocketData * pS,
  char const   local_address[],
  char const   group_address[],
  int          group_port
) {

  WORD    wVersionRequested;
  WSADATA wsaData;
  int     err, ret, reuse;
  char    loopch;

  /* Use the MAKEWORD(lowbyte, highbyte) macro declared in Windef.h */
  wVersionRequested = MAKEWORD(2, 2);

  err = WSAStartup(wVersionRequested, &wsaData);
  if (err != 0) {
    /* Tell the user that we could not find a usable */
    /* Winsock DLL.                                  */
    printf("WSAStartup failed with error: %d\n", err);
	  return UDP_FALSE;
  } else {
    printf("UDP STREAMING Opening the datagram socket...OK.\n");
  }

  /* Create a datagram socket on which to send. */
  pS->socket_id = socket( AF_INET, SOCK_DGRAM, 0 );
  if( pS->socket_id < 0) {
    printf(
      "UDP STREAMING Opening datagram socket error %s(socket dev %li)\n",
      strerror(errno), pS->socket_id
    );
	return UDP_FALSE;
  } else {
    printf("UDP STREAMING Opening the datagram socket...OK.\n");
  }
    
  reuse = 1;
  ret   = setsockopt(
    pS->socket_id,
    SOL_SOCKET,
    SO_REUSEADDR,
    (char *)&reuse,
    sizeof(reuse)
  );
  if ( ret < 0 )    {
    printf("Setting SO_REUSEADDR error %s\n",strerror(errno));
    closesocket(pS->socket_id);
    exit(1);
  } else {
    printf("Setting SO_REUSEADDR...OK.\n");
  }

  /* Initialize the group sockaddr structure  */
  memset( (char *) &(pS->sock_addr), 0, sizeof(pS->sock_addr));
  pS->sock_addr.sin_family = AF_INET;
  InetPton(AF_INET, group_address, &pS->sock_addr.sin_addr.s_addr);
  //pS->sock_addr.sin_addr.s_addr = inet_addr( group_address );
  pS->sock_addr.sin_port = htons( group_port );
  pS->sock_addr_len      = sizeof( pS->sock_addr );

  // Enable loopback so you do  receive your own datagrams.

  loopch = 1;
  ret = setsockopt(
    pS->socket_id,
    IPPROTO_IP,
    IP_MULTICAST_LOOP,
    (char *)&loopch,
    sizeof(loopch)
  );
  if ( ret < 0 ) {
    printf(
      "UDP STREAMING Setting IP_MULTICAST_LOOP error %li %s\n",
      ret, strerror(errno)
    );
  } else {
    printf("UDP STREAMING enabling the loopback...OK.\n" );
  }
  printf(
    "Adding multicast group %s:%li on %s...OK.\n",
    group_address, group_port, local_address
  );

  return UDP_TRUE;
}
