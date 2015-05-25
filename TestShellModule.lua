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
  -- wait for VMS shell
  framework.delay(15)

  vmsSW:setPropertiesByName({
      MailSessionIdleTimeout = 20,
      ShellTimeout = 20,
  })


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

-- sametimes password must be cleared after TC
local clearPassword = false

-----------------------------------------------------------------------------------------------
--- teardown function executed after each unit test
function teardown()

  if clearPassword then
    D:log("Clear password")
    local result = shell:request("setpass")
    assert_not_nil(string.find(result,"Enter old password:"),"Wrong answer for setpass")
    D:log("Sending old password")
    local result = shell:request("test100")
    assert_not_nil(string.find(result,"Enter new password:"),"Wrong old password")
    D:log("Sending new password")
    local result = shell:request("")
    assert_not_nil(string.find(result,"Enter new password again:"),"Wrong answer")
    D:log("Sending new password again")
    local result = shell:request("")
    assert_not_nil(string.find(result,"Success"),"Password not changed")
    clearPassword = false
  end

  vmsSW:setPropertiesByName({
      MailSessionIdleTimeout = 20,
      ShellTimeout = 20,
  })
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
function test_ShellCommandServicelist_WhenServiceListCommandIsSentAProperServiceListIsFetched()
  
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
function test_ShellCommandIdpStatus_WhenIdpStatusCommandIsSentThenTheResponseContainsAllNeccessaryHeaders()

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

--- TC checks VMS shell command: idpinfo.
  --
  -- Initial Conditions:
  --
  -- * There should be VMS shell mode turned on.
  --
  -- Steps:
  --
  -- 1. 'idpinfo' shell command is requested.
  -- 2. Result of the 'idpinfo' shell command is checked for existance of necessary headers.
  --
  -- Results:
  --
  -- 1. Result of the 'idpinfo' shell command is fetched.
  -- 2. All necessary headers are found on the fetched list.
function test_ShellCommandIdpInfo_WhenIdpInfoCommandIsSentThenTheResponseContainsAllNeccessaryHeaders()

  -- fetching idp info
  D:log("Fetching idp info")
  local result = shell:request("idpinfo")

  -- necessary headers in response
  local headers = {
    "Modem model:",
    "Firmware version:",
    "Mobile ID:",
    "Hardware version:",
    "Protocol version:",
    "Release version:",
  }

  -- checking each header , if it exists in the response
  for _,header in pairs(headers) do
    D:log("Checking header: "..header)
    assert_not_nil(string.find(result,header),"There should be '"..header.."' header in the response of shell command 'idpstatus'")
  end

end

--- TC checks VMS shell command: propget.
  --
  -- Initial Conditions:
  --
  -- * There should be VMS shell mode turned on.
  --
  -- Steps:
  --
  -- 1. 'propget VMS' shell command is requested.
  -- 2. Result of the 'propget' shell command is checked for existance of necessary properties.
  --
  -- Results:
  --
  -- 1. Result of the 'propget' shell command is fetched.
  -- 2. All necessary properties are found on the fetched list (comparing to VMS properties definitions)
function test_ShellCommandPropget_WhenPropgetCommandIsSentThenAllPropertiesAreFoundInTheResponse()

  -- fetching idp info
  D:log("Fetching: propget VMS")
  local result = shell:request("propget VMS")

  -- get properties definitions
  local propDefs = vmsSW:getPropertiesDefinition()

  -- checking each property if it exists int the response
  for _,property in pairs(propDefs) do
    local query = "PIN="..property.pin.."%("..property.name.."%)"
    assert_not_nil(string.find(result,query),"There should be '"..query.."' query in the response of shell command 'prop get VMS'")
  end

end

--- TC checks VMS shell command: mail (entering mail mode).
  --
  -- Initial Conditions:
  --
  -- * There should be VMS shell mode turned on.
  --
  -- Steps:
  --
  -- 1. 'mail' shell command is requested.
  -- 2. 'shell' shell command is requested.
  -- 3. 'mail' shell command is requested again.
  --
  -- Results:
  --
  -- 1. 'mail' mode is correctly established.
  -- 2. 'shell' mode is correctly established.
  -- 3. 'mail' mode is correctly established.
function test_ShellCommandMail_WhenMailCommandIsSentShellIsSwitchedToMailMode()

  -- Requesting mail mode
  D:log("Requesting mail mode")
  local result = shell:request("mail")
  assert_not_nil(string.find(result,"mail>"),"shell should be in 'mail' mode")

  -- Requesting shell mode
  D:log("Requesting shell mode")
  local result = shell:request("shell")
  assert_not_nil(string.find(result,"shell>"),"shell should be in 'shell' mode")

  -- Requesting mail mode
  D:log("Requesting mail mode again")
  local result = shell:request("mail")
  assert_not_nil(string.find(result,"mail>"),"shell should be in 'mail' mode")
end

--- TC checks VMS if setting ShellTimeout switches to mail mode (from shell mode).
  --
  -- Steps:
  --
  -- 1. Mail mode is executed.
  -- 2. ShellTimeout is changed for 1 minute.
  -- 3. Shell mode is executed.
  -- 4. Waiting for 1 minute is performed.
  --
  -- Results:
  --
  -- 1. Mail mode is correctly established.
  -- 2. ShellTimeout is correctly set.
  -- 3. Shell mode is correctly established.
  -- 4. Shell is switched to 'mail' mode.
function test_ShellTimeout_WhenShellTimeoutIsSetFormOneMinute_ShellModeIsCorretlySwitchedToMailModeWithinOneMinuteTimeout()

  D:log("Checking mail mode")
  local result = shell:request("mail")
  assert_not_nil(string.find(result,"mail>"),"No mail mode established.")

  -- ShellTimeout set to 1 minute.
  vmsSW:setPropertiesByName({
    ShellTimeout  = 1,
  })

  D:log("Checking shell mode")
  local result = shell:request("shell")
  assert_not_nil(string.find(result,"shell>"),"No shell mode established.")
  D:log("Checking mail mode")
  local result = shell:request("mail")
  assert_not_nil(string.find(result,"mail>"),"No mail mode established.")
  D:log("Checking shell mode")
  local result = shell:request("shell")
  assert_not_nil(string.find(result,"shell>"),"No shell mode established.")

  D:log("Waiting for shell session idle timeout (60s)")
  framework.delay(60+15)

  D:log("Checking mail mode")
  local result = shell:request("")
  assert_not_nil(string.find(result,"mail>"),"Idle timeout has not been executed")
  
end

--- TC checks VMS if setting ShellTimeout switches to mail mode (from shell lua mode).
  --
  -- Steps:
  --
  -- 1. Mail mode is executed.
  -- 2. ShellTimeout is changed for 1 minute.
  -- 3. Lua mode is executed.
  -- 4. Waiting for 1 minute is performed.
  --
  -- Results:
  --
  -- 1. Mail mode is correctly established.
  -- 2. ShellTimeout is correctly set.
  -- 3. Lua mode is correctly established.
  -- 4. Shell is switched to 'mail' mode.
function test_ShellTimeout_WhenShellTimeoutIsSetFormOneMinute_LuaModeIsCorretlySwitchedToMailModeWithinOneMinuteTimeout()

  D:log("Checking mail mode")
  local result = shell:request("mail")
  assert_not_nil(string.find(result,"mail>"),"No mail mode established.")

  -- ShellTimeout set to 1 minute.
  vmsSW:setPropertiesByName({
    ShellTimeout  = 1,
  })

  D:log("Checking shell mode")
  local result = shell:request("shell")
  D:log("Checking mail mode")
  local result = shell:request("mail")
  assert_not_nil(string.find(result,"mail>"),"No mail mode established.")
  local result = shell:request("shell")
  local result = shell:request("mail")
  local result = shell:request("shell")
  local result = shell:request("lua")
  assert_not_nil(string.find(result,"lua>"),"No lua mode established.")

  D:log("Waiting for shell session idle timeout (60s)")
  framework.delay(60+15)

  D:log("Checking mail mode")
  local result = shell:request("")
  assert_not_nil(string.find(result,"mail>"),"Idle timeout has not been executed")

end

--- TC checks if setpass command is able to set password correctly.
  --
  -- Steps:
  --
  -- 1. 'setpass' command is sent.
  -- 2. Old password is sent.
  -- 3. New password is sent.
  -- 4. New password is sent.
  -- 5. Access level 1 is requested
  --
  -- Results:
  --
  -- 1. Old password prompt is received.
  -- 2. New password prompt is received.
  -- 3. New password prompt is received.
  -- 4. Success status is received.
  -- 5. Shell in level 1 is established.
function test_SetPass_WhenSetPassIsInvokedAndPasswordGiven_TheNewPasswordIsCorrectlySet()
  
  clearPassword = true
  
  D:log("Sending setpass command")
  local result = shell:request("setpass")
  assert_not_nil(string.find(result,"Enter old password:"),"Wrong answer for setpass")
  D:log("Sending old password")
  local result = shell:request("")
  assert_not_nil(string.find(result,"Enter new password:"),"Wrong old password")
  D:log("Sending new password")
  local result = shell:request("test100")
  assert_not_nil(string.find(result,"Enter new password again:"),"Wrong answer")
  D:log("Sending new password again")
  local result = shell:request("test100")
  assert_not_nil(string.find(result,"Success"),"Password not changed")

  local result = shell:request("access 1")
  local result = shell:request("test100")
 
  assert_not_nil(string.find(result,"shell:1"),"Access level has not been changed.")
  local result = shell:request("exit")
  
end

--- TC checks if access level zero has its restrictions.
  --
  -- Steps:
  --
  -- 1. Password setup and access level 1 is requested .
  -- 2. Access level zero is requested.
  -- 3. Command 'prop get' is requested.
  -- 4. Command 'prop set' is requested.
  -- 5. Command 'service list' is requested.
  -- 6. Command 'service disable' is requested.
  -- 7. Command 'service enable' is requested.
  --
  -- Results:
  --
  -- 1. Access level 1 is established.
  -- 2. Access level zero is established.
  -- 3. Access restriction response is sent.
  -- 4. Access restriction response is sent.
  -- 5. Access restriction response is sent.
  -- 6. Access restriction response is sent.
  -- 7. Access restriction response is sent.
function test_Access_WhenAccessLevelZeroIsEstablished_ThenRestrictionsOfThisLevelAreValid()

  clearPassword = true

  D:log("Sending setpass command")
  local result = shell:request("setpass")
  assert_not_nil(string.find(result,"Enter old password:"),"Wrong answer for setpass")
  D:log("Sending old password")
  local result = shell:request("")
  assert_not_nil(string.find(result,"Enter new password:"),"Wrong old password")
  D:log("Sending new password")
  local result = shell:request("test100")
  assert_not_nil(string.find(result,"Enter new password again:"),"Wrong answer")
  D:log("Sending new password again")
  local result = shell:request("test100")
  assert_not_nil(string.find(result,"Success"),"Password not changed")

  local result = shell:request("access 1")
  local result = shell:request("test100")

  assert_not_nil(string.find(result,"shell:1"),"Access level has not been changed.")
  local result = shell:request("exit")
  assert_not_nil(string.find(result,"shell"),"Wrong shell level.")
  
  local result = shell:request("prop get system")
  assert_not_nil(string.find(result,"error: Insufficient access level"),"There should be a message: insufficient access level")
  local result = shell:request("prop set system 1 1 ")
  assert_not_nil(string.find(result,"error: Insufficient access level"),"There should be a message: insufficient access level")
  local result = shell:request("service list")
  assert_not_nil(string.find(result,"error: Insufficient access level"),"There should be a message: insufficient access level")
  local result = shell:request("service disable VMS")
  assert_not_nil(string.find(result,"error: Insufficient access level"),"There should be a message: insufficient access level")
  local result = shell:request("service enable VMS")
  assert_not_nil(string.find(result,"error: Insufficient access level"),"There should be a message: insufficient access level")
  
end

