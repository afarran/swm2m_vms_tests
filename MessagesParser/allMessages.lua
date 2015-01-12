FORWARD  MSG of system (SIN 16) :
{ name ="getTerminalInfo", min=1},
{ name ="getTerminalStatus", min=2},
{ name ="getServiceList", min=3},
{ name ="getServiceInfo", min=4},
{ name ="restartService", min=5},
{ name ="resetTerminal", min=6},
{ name ="getTerminalMetrics", min=7},
{ name ="getProperties", min=8},
{ name ="setProperties", min=9},
{ name ="resetProperties", min=10},
{ name ="saveProperties", min=11},
{ name ="revertProperties", min=12},
{ name ="restartFramework", min=13},
{ name ="setPassword", min=14},
{ name ="disableService", min=15},
{ name ="setEnabledServices", min=16},
{ name ="setFactoryPassword", min=247},
****
RETURN  MSG of system (SIN 16) :
{ name ="terminalInfo", min=1},
{ name ="terminalStatus", min=2},
{ name ="serviceList", min=3},
{ name ="serviceInfo", min=4},
{ name ="propertyValues", min=5},
{ name ="termReset", min=6},
{ name ="timeSync", min=7},
{ name ="terminalRegistration", min=8},
{ name ="setPasswordResult", min=9},
{ name ="disableServiceResult", min=10},
FORWARD  MSG of idp (SIN 27) :
{ name ="getSReg", min=1},
{ name ="setSreg", min=2},
{ name ="getMetrics", min=3},
****
RETURN  MSG of idp (SIN 27) :
{ name ="getSRegResult", min=1},
{ name ="setSRegResult", min=2},
{ name ="metricsResult", min=3},
FORWARD  MSG of message (SIN 18) :
{ name ="getStatus", min=1},
{ name ="cancel", min=2},
****
RETURN  MSG of message (SIN 18) :
{ name ="custom", min=1},
{ name ="msgStatus", min=2},
{ name ="msgInvalid", min=3},
{ name ="msgError", min=4},
FORWARD  MSG of log (SIN 23) :
{ name ="setDataLogFilter", min=1},
{ name ="setDebugLogFilter", min=2},
{ name ="getDataLogCount", min=3},
{ name ="getDebugLogCount", min=4},
{ name ="getDataLogEntries", min=5},
{ name ="getDebugLogEntries", min=6},
{ name ="clearLogs", min=7},
{ name ="setUploadDataLogFilter", min=8},
{ name ="setUploadDebugLogFilter", min=9},
{ name ="getUploadDataLogCount", min=10},
{ name ="getUploadDebugLogCount", min=11},
{ name ="setDebugLogFilter2", min=12},
{ name ="getDebugLogEntries2", min=13},
{ name ="setUploadDebugLogFilter2", min=14},
****
RETURN  MSG of log (SIN 23) :
{ name ="dataLogFilter", min=1},
{ name ="debugLogFilter", min=2},
{ name ="dataLogCount", min=3},
{ name ="debugLogCount", min=4},
{ name ="dataLogEntries", min=5},
{ name ="debugLogEntries", min=6},
{ name ="uploadDataLogFilter", min=7},
{ name ="uploadDebugLogFilter", min=8},
{ name ="uploadDataLogCount", min=9},
{ name ="uploadDebugLogCount", min=10},
{ name ="uploadDataLogEntries", min=11},
{ name ="uploadDebugLogEntries", min=12},
{ name ="debugLogFilter2", min=13},
{ name ="debugLogEntries2", min=14},
{ name ="uploadDebugLogFilter2", min=15},
{ name ="uploadDebugLogEntries2", min=16},
FORWARD  MSG of eio (SIN 25) :
{ name ="readPort", min=1},
{ name ="writePort", min=2},
{ name ="pulsePort", min=3},
****
RETURN  MSG of eio (SIN 25) :
{ name ="portValue", min=1},
{ name ="portAlarm", min=2},
FORWARD  MSG of position (SIN 20) :
{ name ="getPosition", min=1},
{ name ="getLastPosition", min=2},
{ name ="getSources", min=3},
****
RETURN  MSG of position (SIN 20) :
{ name ="position", min=1},
{ name ="sources", min=2},
FORWARD  MSG of report (SIN 19) :
{ name ="generateReport", min=1},
****
RETURN  MSG of report (SIN 19) :
{ name ="simpleReport", min=1},
{ name ="fullReport", min=2},
{ name ="EIO", min=3},
{ name ="noEIO", min=4},
{ name ="fullReport2", min=5},
FORWARD  MSG of filesystem (SIN 24) :
{ name ="write", min=1},
{ name ="read", min=2},
{ name ="dir", min=3},
{ name ="stat", min=4},
****
RETURN  MSG of filesystem (SIN 24) :
{ name ="writeResult", min=1},
{ name ="readResult", min=2},
{ name ="dirResult", min=3},
{ name ="statResult", min=4},
FORWARD  MSG of shell (SIN 26) :
{ name ="executeCmd", min=1},
{ name ="executeLua", min=2},
{ name ="executePrivilegedCmd", min=3},
{ name ="executePrivilegedLua", min=4},
{ name ="getAccessInfo", min=5},
{ name ="setAccessLevel", min=6},
{ name ="changeAccessPassword", min=7},
****
RETURN  MSG of shell (SIN 26) :
{ name ="cmdResult", min=1},
{ name ="accessInfo", min=2},
{ name ="accessSetChangeResult", min=3},
FORWARD  MSG of geofence (SIN 21) :
{ name ="setCircle", min=1},
{ name ="setPolygon", min=2},
{ name ="enableFence", min=3},
{ name ="updateAlarmCond", min=4},
{ name ="getStatus", min=5},
{ name ="getAllStatus", min=6},
{ name ="setRectangle", min=7},
****
RETURN  MSG of geofence (SIN 21) :
{ name ="alarm", min=1},
{ name ="fenceStatus", min=2},
{ name ="allFencesStatus", min=3},
{ name ="alarms", min=4},
FORWARD  MSG of cell (SIN 29) :
{ name ="listOperation", min=1},
{ name ="getLists", min=2},
****
RETURN  MSG of cell (SIN 29) :
{ name ="operationResult", min=1},
{ name ="lists", min=2},
FORWARD  MSG of eeio (SIN 30) :
{ name ="readPort", min=1},
{ name ="writePort", min=2},
****
RETURN  MSG of eeio (SIN 30) :
{ name ="portValue", min=1},
{ name ="portAlarm", min=2},
{ name ="portValues", min=3},
FORWARD  MSG of power (SIN 17) :
{ name ="powerOff", min=1},
****
RETURN  MSG of power (SIN 17) :
{ name ="extPowerAlarm", min=1},
{ name ="powerOnAlarm", min=2},
{ name ="powerOffResult", min=3},
FORWARD  MSG of campaign (SIN 32) :
{ name ="start", min=1},
{ name ="frag", min=2},
{ name ="operation", min=3},
{ name ="getStates", min=5},
****
RETURN  MSG of campaign (SIN 32) :
{ name ="requestfrags", min=1},
{ name ="state", min=2},
{ name ="states", min=3},
FORWARD  MSG of ip (SIN 33) :
{ name ="channelSend", min=1},
{ name ="channelOpen", min=2},
{ name ="channelClose", min=3},
{ name ="channelDispose", min=4},
{ name ="channelOpenClose", min=5},
{ name ="resyncAck", min=7},
{ name ="SMTPsend", min=25},
****
RETURN  MSG of ip (SIN 33) :
{ name ="channelSend", min=1},
{ name ="channelOpen", min=2},
{ name ="channelClose", min=3},
{ name ="channelDispose", min=4},
{ name ="channelOpenClose", min=5},
{ name ="allocateTCP", min=6},
{ name ="resync", min=7},
{ name ="allocateUDP", min=17},
{ name ="allocateFTP", min=21},
{ name ="allocateNativeSMTP", min=25},
{ name ="allocateDirectedSMTP", min=26},
