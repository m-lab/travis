#!/usr/bin/gawk -f

# A helpful script to ensure that commands which produce too much output but
# also take a long time will be reduced to producing output at most once per
# minute.  This is useful for ensuring that there is not too much output for
# Travis, but also that there is never a period where a command doesn't output
# for ten minutes, causing Travis to think that the command is dead.

# Initialize the output time to the beginning of the epoch.
BEGIN { next_output_time = 0 }

# On every line of input, check whether it should be echoed or suppressed.
{
  current_time = systime()
  if (current_time > next_output_time) {
    print "[" strftime() "]", $0
    next_output_time = current_time + 60
  }
}
