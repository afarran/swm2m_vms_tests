--- Runs Feature Tests
-- @tparam table args array of string arguments
-- @usage
-- [-v]                     Verbose option
-- [-t] [<string pattern>]  Execute test cases that match string pattern
-- [-s] [<string pattern>]  Execute test suites that match string pattern
-- [-p] [<port>]  Use specific gateway port
-- [-com] [<comport>]  Use specific com port for console communication

for idx, val in ipairs(arg) do 
  print(idx, val) 
  
  if val == "-p" then
    GatewayPort = arg[idx+1]
    print("Using port " .. GatewayPort)
  end
  
  if val == "-com" then
    ComPort = arg[idx+1]
  end
end
ComPort = ComPort or "com"

-- Annotations
require("Infrastructure/Annotations/Annotations")

-- Test Framework
cfg, framework, gateway, lsf, device, gps = require "TestFramework"()
lunatest = require "lunatest"

-- Global variables used in the tests
GPS_PROCESS_TIME = 1                                                -- seconds
GATEWAY_TIMEOUT = 60                                                -- in seconds
TIMEOUT_MSG_NOT_EXPECTED = 20                                       -- in seconds
GEOFENCE_INTERVAL = 10                                              -- in seconds
GPS_READ_INTERVAL = 1          -- used to configure the time interval of updating the position , in seconds

-- Debugger
require("Debugger/Debugger")
D = Debugger()

-- Services Wrappers
require("Service/PositionServiceWrapper")
require("Service/VmsServiceWrapper")
require("Service/FilesystemServiceWrapper")
require("Service/SystemServiceWrapper")
require("Service/GeofenceServiceWrapper")
require("Service/LogServiceWrapper")
require("Service/ShellServiceWrapper")
require("Service/UniboxServiceWrapper")
require("Service/InterfaceUnitHelpServiceWrapper")

-- Gps Frontend
require("Gps/GpsFrontend")
GPS = GpsFrontend()

positionSW = PositionServiceWrapper()
filesystemSW = FilesystemServiceWrapper()
systemSW = SystemServiceWrapper()
vmsSW = VmsServiceWrapper()
geofenceSW = GeofenceServiceWrapper()
logSW = LogServiceWrapper()
shellSW = ShellServiceWrapper()
uniboxSW = UniboxServiceWrapper()
InterfaceUnitHelpSW = InterfaceUnitHelpServiceWrapper()


require("Serial/RealSerialWrapper")
serialMain = RealSerialWrapper({name=ComPort, open=true, newline="\r\n"})

-- Helm Panel
helmPanelFactory = require("HelmPanelDevice/HelmPanelDeviceFactory")()
helmPanel = helmPanelFactory.create("unibox")

-- perform data analysis
require("Infrastructure/DataAnalyse/DriftAnalyse")
driftAnalyse = DriftAnalyse()


-- Randomizer
FORCE_ALL_TESTCASES = false                                  -- determines whether to run all TCs or to use random TC for similar features -
tcRandomizer =  require "Randomizer"()

-- Profiles
profileFactory = require("Profile/ProfileFactory")()
hardwareVariant = systemSW:getTerminalHardwareVersion(false)   -- so far only 690 is available, so we are not resolving variant
profile = profileFactory.create(hardwareVariant)

--- Called before the start of any test suites
local function setup()
  print("*** VMS Feature Tests Started ***")
  math.randomseed(os.time())
  io.output():setvbuf("no")
  --include the following test suites in the feature tests:
  lunatest.suite("TestNormalReportsModule")
  lunatest.suite("TestCommonReportModule")
  lunatest.suite("TestAbnormalReportsModule")
  lunatest.suite("TestGeofenceModule")
  lunatest.suite("TestHelmPanelModule")
  lunatest.suite("TestSmtpModule")
  lunatest.suite("TestShellModule")
  lunatest.suite("TestPop3Module")
end

local function teardown()
  serialMain:close()
  print("*** VMS Feature Tests Completed ***")
  framework.printResults()
end


setup()
lunatest.run(nil, arg)
teardown()
