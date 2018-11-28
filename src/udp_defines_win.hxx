/*\
 | Get time function (milliseconds)
\*/

uint64_t
get_time_ms() {
  uint64_t time_ms;
  LARGE_INTEGER time_query;
  LARGE_INTEGER frequency;

  QueryPerformanceFrequency(&frequency);
  QueryPerformanceCounter(&time_query);
  time_query.QuadPart *= 1000000;
  time_ms = (time_query.QuadPart / frequency.QuadPart) / 1000;
  return time_ms;
}

void
sleep_ms( uint32_t time_sleep_ms )
{ Sleep(time_sleep_ms); }
