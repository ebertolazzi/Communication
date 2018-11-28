
/* ============================================================================

 UDP communication with limited packed size

 Author: Gastone Pietro Rosati Papini

 ============================================================================ */

#include "udp_class.hh"

#ifdef _MSC_VER
  #include <Winsock2.h>
  #include <Ws2tcpip.h>
  #include <signal.h>

  BOOL
  WINAPI
  ConsoleHandler(DWORD CEvent) {
    char mesg[128];
    switch(CEvent) {
    case CTRL_C_EVENT:
      throw InterruptException("CTRL+C received!");
      break;
    case CTRL_BREAK_EVENT:
      throw InterruptException("CTRL+BREAK received!");
      break;
    case CTRL_CLOSE_EVENT:
      throw InterruptException("Program being closed!");
      break;
    case CTRL_LOGOFF_EVENT:
      throw InterruptException("User is logging off!");
      break;
    case CTRL_SHUTDOWN_EVENT:
      throw InterruptException("User is logging off!");
      break;
    }
    return TRUE;
  }
#else
  #include <signal.h>
#endif

Socket::Socket()
{
  Socket_new( &data );
  // Taken from answer to "How can I catch a ctrl-c event? (C++)"
  #ifdef _MSC_VER
  if ( SetConsoleCtrlHandler( (PHANDLER_ROUTINE)ConsoleHandler,TRUE) == FALSE ) {
    // unable to install handler...
    // display message to the user
    std::cerr << "Unable to install handler!\n";
    std::exit(-1);
  }
  #else
  struct sigaction sigIntHandler;
  sigIntHandler.sa_handler = sig_to_exception;
  sigemptyset(&sigIntHandler.sa_mask);
  sigIntHandler.sa_flags = 0;
  sigaction(SIGINT,&sigIntHandler, NULL);
  //sigaction(SIGABRT,&sigIntHandler, NULL);
  sigaction(SIGTERM,&sigIntHandler, NULL);
  #endif
}
