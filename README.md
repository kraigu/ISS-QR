ISS-QR
======

uWaterloo ISS team's QRadar scripts

Requirements
============

use Config::General;
use Net::SSH;
use Geo::IP;

Config
======

Defaults to ~/.qr.

```
hostname = (QRadar console)
ipcity = (path to GeoLite city database)

Scripts
=======

qr-symsearch - looks at Symantec reports for the given host and date range

qr-assetsearch - look at events for anything involving the given host or MAC and date range, typically DHCP logs

qr-relaysearch - look at relay events for a given userid (requires the GeoLiteCity database from Maxmind and path set in .qr)

License
=======

BSD-new.

Authors
=======

Mike Patterson <mike.patterson@uwaterloo.ca> Waterloo IST-ISS

Cheng Jie Shi <cjshi@uwaterloo.ca> Waterloo IST-ISS Winter 2013 CoOp student
