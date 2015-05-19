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
  -- Starts shell , turns it to shell mode if mail mode detected.
  D:log("Preparing shell")
  if not shell:ready() then
    skip("Shell is not ready - serial port not opened (".. serialMain.name .. ")")
  end
  assert_true(shell:ready(), "Shell is not ready - serial port not opened")
  shell:start()
end

-----------------------------------------------------------------------------------------------
--- teardown function executed after each unit test
function teardown()
end

-------------------------
-- Test Cases
-------------------------


--- TC checks VMS shell command: servicelist.
  --
  -- Initial Conditions:
  --
  -- * There should be VMS shell mode turned on.
  --
  -- Steps:
  --
  -- 1. 'servicelist' shell command is requested.
  -- 2. Result of the 'servicelist' shell command is checked for existance of necessary services.
  --
  -- Results:
  --
  -- 1. Result of the 'servicelist' shell command is fetched.
  -- 2. All dependant services are detected on the fetched list.
function test_ShellCommandServicelist_WhenServiceListCommandIsSendAProperServiceListIsFetched()
  
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

--- TC checks VMS shell command: idpstatus.
  --
  -- Initial Conditions:
  --
  -- * There should be VMS shell mode turned on.
  --
  -- Steps:
  --
  -- 1. 'idpstatus' shell command is requested.
  -- 2. Result of the 'idpstatus' shell command is checked for existance of necessary headers.
  --
  -- Results:
  --
  -- 1. Result of the 'idpstatus' shell command is fetched.
  -- 2. All necessary headers are found on the fetched list.
function test_ShellCommandIdpStatus_WhenIdpStatusCommandIsSendXXXXX()

  -- fetching idp status
  D:log("Fetching idp status")
  local result = shell:request("idpstatus")

  -- necessary headers in response
  local headers = {
    "Global Status:",
    "Last GPS info:",
    "Virtual Carrier ID:",
    "Subframe number:",
    "Configuration ID:",
    "Fix type:",
    "Latitude:",
    "Longitude:",
    "Number of PRNs:",
    "Beam number:",
  }

  -- checking each header , if it exists in the response
  for _,header in pairs(headers) do
    D:log("Checking header: "..header)
    assert_not_nil(string.find(result,header),"There should be '"..header.."' header in the response of shell command 'idpstatus'") 
  end
end

