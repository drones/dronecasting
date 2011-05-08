
assert = require 'assert'
pcap = require 'pcap'# with UDP payload patch!
{intervalSet, varintsEncode, joinBuffers} = require './util'


EVENTS = 
  COMMAND:            50
  NAVDATA:            51
  VIDEO:              52
  CONTROL_TO_DRONE:   53
  CONTROL_FROM_DRONE: 54

DRONE_IP = '192.168.1.1'


dronecastFromPcap = (path, callback) ->

  last_us = 0
  bufs = []

  _handleEvent = (raw_packet, data, event_type) ->
    {tv_sec, tv_usec} = raw_packet.pcap_header
    us = (tv_sec * 1e6) + tv_usec
    delta_us = us - last_us
    last_us = us

    bufs.push joinBuffers [
      varintsEncode([event_type, delta_us, data.length]),
      data # We need to copy this. joinBuffers does that.
    ]

  tcp_tracker = new pcap.TCP_tracker
  pcap_session = pcap.createOfflineSession(path, "")

  endOnTimeout pcap_session
  pcap_session.on 'end', () ->
    callback null, joinBuffers(bufs)

  pcap_session.on 'packet', (raw_packet) ->
    try
      packet = pcap.decode.packet raw_packet
      ip = packet.link.ip
      {udp, tcp} = ip

      if udp
        eventType = if udp.dport == 5556 and ip.daddr == DRONE_IP
          EVENTS.COMMAND
        else if udp.dport == 5554 and ip.saddr == DRONE_IP
          EVENTS.NAVDATA
        else if udp.dport == 5555 and ip.saddr == DRONE_IP
          EVENTS.VIDEO
        if eventType?
          #data = raw_packet.slice(udp.data_offset, udp.length)
          data = udp.data
          _handleEvent raw_packet, data, eventType

    catch e
      # e.g. some IPv6 packets


endOnTimeout = (s) ->
  last_t = new Date().getTime()
  s.on 'packet', () ->
    last_t = new Date().getTime()
  interval = intervalSet 500, () ->
    if new Date().getTime() - last_t > 600
      clearInterval interval
      s.emit 'end'

