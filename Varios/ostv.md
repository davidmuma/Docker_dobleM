# <b>Configuración de oscam + tvheadend </B>

oscam.conf
```
[global]
logfile                       = stdout
fallbacktimeout               = 5500
bindwait                      = 40
nice                          = -1
maxlogsize                    = 200
waitforcards                  = 0
waitforcards_extra_delay      = 550
preferlocalcards              = 1
lb_mode                       = 10
lb_nbest_readers              = 2
lb_min_ecmcount               = 3
lb_max_ecmcount               = 250
lb_reopen_seconds             = 900
lb_retrylimit                 = 800
lb_max_readers                = 10

[cache]
max_time                      = 8

[dvbapi]
enabled                       = 1
au                            = 1
pmt_mode                      = 4
listen_port                   = 9999
user                          = tvheadend
boxtype                       = pc

[webif]
httpport                      = 8888
serverip                      = 192.168.1.55
httpuser                      = oscam
httppwd                       = oscam
httprefresh                   = 5
httpshowmeminfo               = 1
httpshowloadinfo              = 1
httpallowed                   = 0.0.0.0-255.255.255.255
aulow                         = 120
hideclient_to                 = 120
```

oscam.user
```
[account]
 user = tvheadend
 monlevel = 4
 suppresscmd08 = 1
 keepalive = 1
 au = 1
 group = 1
 max_connections = 4
 penalty = 0
```