#ifndef SOCKET_ERROR
  #define SOCKET_ERROR (-1)
#endif

/*\
 | Get time function (milliseconds)
\*/

#include <sys/time.h>
#include <unistd.h>

uint64_t
get_time_ms() {
  uint64_t time_ms;
  struct timeval time_get;
  gettimeofday(&time_get, NULL);
  time_ms = (uint64_t) (time_get.tv_sec*1000 + time_get.tv_usec/1000);
  return time_ms;
}

void
sleep_ms( uint32_t time_sleep_ms )
{ usleep(time_sleep_ms*1000); }
