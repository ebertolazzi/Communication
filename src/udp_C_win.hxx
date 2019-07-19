#ifndef WIN32_LEAN_AND_MEAN
  #define WIN32_LEAN_AND_MEAN
#endif

#include <Windows.h>
#include <stdio.h>
#include <Winsock2.h>
#include <Ws2tcpip.h>

#pragma comment (lib, "Ws2_32.lib")

static
void
UDP_CheckError( char const msg[] ) {
  // Get the error message, if any.
  DWORD errorMessageID = WSAGetLastError();
  if ( errorMessageID == 0 ) return ; // No error message has been recorded
  LPSTR messageBuffer = NULL;
  size_t size = FormatMessageA(
    FORMAT_MESSAGE_ALLOCATE_BUFFER |
    FORMAT_MESSAGE_FROM_SYSTEM |
    FORMAT_MESSAGE_IGNORE_INSERTS,
    NULL,
    errorMessageID,
    MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT),
    (LPSTR)&messageBuffer,
    0,
    NULL
  );
  UDP_printf("[%s]\n%s", msg, messageBuffer);
  LocalFree(messageBuffer);
}

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
    UDP_CheckError( "error: WSAStartup() failed" );
    return UDP_FALSE;
  }

  pS->socket_id = (int)socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);

  if ( pS->socket_id == INVALID_SOCKET) {
    UDP_CheckError( "error: socket() failed" );
    return UDP_FALSE;
  }

  rcvbufsize = 80000;
  setsockopt(
    pS->socket_id,
    SOL_SOCKET,
    SO_RCVBUF,
    (char*)&rcvbufsize, sizeof(rcvbufsize)
  );

  /*\
   | Set send buffer size limit
  \*/

  opt_buflen = UDP_MTU_MAX_BYTES;
  ret = setsockopt(
    pS->socket_id,
    SOL_SOCKET,
    SO_SNDBUF,
    (char *)&opt_buflen,
    sizeof(opt_buflen)
  );
  if ( ret == SOCKET_ERROR ) {
    UDP_CheckError( "error: setsockopt() failed" );
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
    UDP_CheckError( "error: ioctlsocket() failed");
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
    UDP_CheckError( "error: setsockopt() failed" );
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
    UDP_CheckError( "error: setsockopt() failed" );
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
      UDP_CheckError( "error: bind() failed" );
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
    UDP_CheckError( "error: setsockopt() failed" );
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
MultiCast_open_as_listener(
  SocketData * pS,
  char const   group_address[],
  int          group_port
) {

  int            ret, yes;
  struct ip_mreq mreq;

  /* Create UDP socket */
  pS->socket_id = (int32_t)socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
  if ( pS->socket_id < 0 ) {
    UDP_CheckError("UDP STREAMING Opening datagram socket error");
    return UDP_FALSE;
  } else {
    UDP_printf("UDP STREAMING Opening the datagram socket...OK.\n");
  }

  /* allow multiple sockets to use the same PORT number */
  yes = 1;
  ret = setsockopt( pS->socket_id, SOL_SOCKET, SO_REUSEADDR, (char*) &yes, sizeof(yes) );
  if ( ret < 0 ) {
    UDP_CheckError("UDP STREAMING Reusing ADDR failed");
    return UDP_FALSE;
  }

#if 0
  ret = setsockopt( pS->socket_id, SOL_SOCKET, SO_REUSEPORT, (char*) &yes, sizeof(yes) );
  if ( ret < 0 ) {
    UDP_printf("UDP STREAMING Reusing PORT failed\n");
    return UDP_FALSE;
  }
#endif

  memset((char *)&pS->sock_addr, 0, sizeof(pS->sock_addr));
  pS->sock_addr.sin_family      = AF_INET;
  pS->sock_addr.sin_addr.s_addr = htonl(INADDR_ANY);
  pS->sock_addr.sin_port        = htons(group_port);
  pS->sock_addr_len             = sizeof(pS->sock_addr);

  /* bind to receive address */
  ret = bind( pS->socket_id, (struct sockaddr *) &pS->sock_addr, sizeof(pS->sock_addr) );
  if ( ret < 0 ) {
    UDP_CheckError("UDP STREAMING bind socket error");
    return UDP_FALSE;
  }

  /* Preparatios for using Multicast */
  mreq.imr_multiaddr.s_addr = inet_addr(group_address);
  mreq.imr_interface.s_addr = htonl(INADDR_ANY);
  ret = setsockopt(pS->socket_id, IPPROTO_IP, IP_ADD_MEMBERSHIP, &mreq, sizeof(mreq));
  if ( ret < 0 ) {
    UDP_CheckError("UDP STREAMING setsockopt mreq");
    return UDP_FALSE;
  }
  return UDP_TRUE;
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

int
MultiCast_open_as_sender(
  SocketData * pS,
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
    UDP_printf("WSAStartup failed with error: %d\n", err);
	  return UDP_FALSE;
  } else {
    UDP_printf("UDP STREAMING Opening the datagram socket...OK.\n");
  }

  /* Create a datagram socket on which to send. */
  pS->socket_id = socket( AF_INET, SOCK_DGRAM, 0 );
  if( pS->socket_id < 0) {
    UDP_CheckError("UDP STREAMING Opening datagram socket error");
    return UDP_FALSE;
  } else {
    UDP_printf("UDP STREAMING Opening the datagram socket...OK.\n");
  }
    
  reuse = 1;
  ret   = setsockopt(
    pS->socket_id,
    SOL_SOCKET,
    SO_REUSEADDR,
    (char *)&reuse,
    sizeof(reuse)
  );
  if ( ret < 0 ) {
    UDP_CheckError("error: Setting SO_REUSEADDR");
    closesocket(pS->socket_id);
    exit(1);
  } else {
    UDP_printf("Setting SO_REUSEADDR...OK.\n");
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
    UDP_CheckError("UDP STREAMING Setting IP_MULTICAST_LOOP error");
  } else {
    UDP_printf("UDP STREAMING enabling the loopback...OK.\n" );
  }
  UDP_printf(
    "Adding multicast group %s:%li...OK.\n",
    group_address, group_port
  );

  return UDP_TRUE;
}
