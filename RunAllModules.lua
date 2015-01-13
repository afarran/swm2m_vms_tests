-- Test Framework
cfg, framework, gateway, lsf, device, gps = require "TestFramework"()
lunatest = require "lunatest"

-- Global variables used in the tests
GPS_PROCESS_TIME = 1                                                -- seconds
GATEWAY_TIMEOUT = 60                                                -- in seconds
TIMEOUT_MSG_NOT_EXPECTED = 20                                       -- in seconds
GEOFENCE_INTERVAL = 10                                              -- in seconds
GPS_READ_INTERVAL = 1                                               -- used to configure the time interval of updating the position , in seconds

-- Services Wrappers
require("Service/PositionServiceWrapper")
require("Service/VmsServiceWrapper")
positionSW = PositionServiceWrapper()
vmsSW = VmsServiceWrapper() -- TODO: investigate why creation of this object spoils data in positionServiceWrapper? (see TC in TestReportingModule)

-- Gps Frontend
require("Gps/GpsFrontend")
GPS = GpsFrontend()

-- Randomizer
FORCE_ALL_TESTCASES = false                                  -- determines whether to run all TCs or to use random TC for similar features -
tcRandomizer =  require "Randomizer"()

-- Profiles
profileFactory = require("Profile/ProfileFactory")()
hardwareVariant = 1 -- TODO: avlHelperFunctions.getTerminalHardwareVersion()   -- 1,2 and 3 for 600, 700 and 800 available
profile = profileFactory.create(hardwareVariant)

--- Called before the start of any test suites
local function setup()
  print("*** VMS Feature Tests Started ***")
  math.randomseed(os.time())
  io.output():setvbuf("no")
  --include the following test suites in the feature tests:
  lunatest.suite("TestReportingModule")

end

local function teardown()
  print("*** VMS Feature Tests Completed ***")
  framework.printResults()
end

--- Runs Feature Tests
-- @tparam table args array of string arguments
-- @usage
-- [-v]                     Verbose option
-- [-t] [<string pattern>]  Execute test cases that match string pattern
-- [-s] [<string pattern>]  Execute test suites that match string pattern
for idx, val in ipairs(arg) do print(idx, val) end

setup()
lunatest.run(nil, arg)
teardown()
