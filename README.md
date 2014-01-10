ISS-QR
======

uWaterloo ISS team's QRadar scripts

Requirements
============

```
use Config::General;
use Net::SSH;
```

Scripts
=======

  * qr-symsearch - looks at Symantec reports for the given host and date range
  * qr-assetsearch - look at events for anything involving the given host or MAC and date range, typically DHCP logs
  * qr-vpnsearch - look at VPN login events for a given userid

License
=======

BSD-new.

Authors
=======

  * Mike Patterson <mike.patterson@uwaterloo.ca> Waterloo IST-ISS
  * Cheng Jie Shi <cjshi@uwaterloo.ca> Waterloo IST-ISS Winter 2013 CoOp student
  * Davidson Marshall <damarsha@uwaterloo.ca> Waterloo IST-ISS Fall 2013 CoOp student

