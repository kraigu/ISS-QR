ISS-QR
======

uWaterloo ISS team's QRadar scripts

Requirements
============

```
use Config::General;
use Net::SSH;
use Geo::IP;
use Text::CSV;
use Date::Manip;
```

Config
======

Defaults to ~/.qr.

```
hostname = (QRadar console)
ipcity = (path to GeoLite city database)
```

Scripts
=======

*qr-assetsearch* - look at events for anything involving the given host or MAC and date range, typically DHCP logs

*qr-relaysearch* - look at relay events for a given userid (requires the GeoLiteCity database from Maxmind and for the path to be set in .qr)

*qr-symsearch* - looks at Symantec reports for the given host and date range

*qr-vpnsearch* - look at VPN login events for a given userid

License
=======

BSD-new.

Authors
=======

Mike Patterson - University of Waterloo IST-ISS

Cheng Jie Shi - IST-ISS Winter 2013 CoOp student

Davidson Marshall - IST-ISS Fall 2013 CoOp student
