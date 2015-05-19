-----------
-- Vms shell test module
-- - contains VMS features dependant on vms shell
-- @module TestShellModule

require "UtilLibs/Text"
require "Serial/RsShellWrapper"

local shell = RsShellWrapper(serialMain)
shell:setTimeout(5)

module("TestShellModule", package.seeall)

function suite_setup()

end

-- executed after each test suite
function suite_teardown()

end

--- setup function
function setup()
  --gateway.setHighWaterMark()
end

-----------------------------------------------------------------------------------------------
--- teardown function executed after each unit test
function teardown()
end

-------------------------
-- Test Cases
-------------------------

-- Starts shell , turns it to shell mode if mail mode detected.
local function startShell()
  if not shell:ready() then
    skip("Shell is not ready - serial port not opened (".. serialMain.name .. ")")
  end
  assert_true(shell:ready(), "Shell is not ready - serial port not opened")
  shell:start()
end


--- TC checks VMS shell command: servicelist.
  --
  -- Initial Conditions:
  --
  -- * There should be VMS shell mode turned on.
  --
  -- Steps:
  --
  -- 1. Servicelist shell command is requested.
  -- 2. Result of the servicelist shell command is checked for existance of necessary services.
  --
  -- Results:
  --
  -- 1. Result of the servicelist shell command is fetched.
  -- 2. All dependant services are detected on the fetched list.
function test_ShellCommandServicelist_WhenServiceListCommandIsSendAProperServiceListIsFetched()
  
  -- preparing shell
  D:log("Preparing shell")
  startShell()

  -- fetching service list
  D:log("Fetching service list")
  local result = shell:request("servicelist")

  -- services that should be on the list
  local services = {
    {16,"system"},
    {18,"message"},
    {22,"serial"},
    {115,"VMS"},
    {21,"geofence"},
    {25,"eio"},
    {33,"ip"},
    {162,"UniboxInOut"},
  }
  
  -- checking each service , if it exists on the list
  for _,service in pairs(services) do
    D:log("Checking service: "..service[2])
    assert_not_nil(string.find(result,service[1]..'%s*'..service[2]),"There should be "..service[2].." service on the list.") 
  end
end
