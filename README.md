
## Event encoding
<pre>
  varint(event_type)
  varint(delta_microseconds)
  varint(data_length)
  data
</pre>

## Events
<pre>
  COMMAND:            50
  NAVDATA:            51
  VIDEO:              52
  CONTROL_TO_DRONE:   53
  CONTROL_FROM_DRONE: 54
</pre>
