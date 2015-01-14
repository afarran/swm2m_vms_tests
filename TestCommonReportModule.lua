-----------
-- CommonReports test module
-- - contains VMS reporting features
-- @module TestCommonReportModule

module("TestCommonReportModule", package.seeall)
local restoreSourcecode = false
local SourcecodeData = ""

function suite_setup()
  -- reset of properties 
  -- restarting VMS agent ?
    
end

-- executed after each test suite
function suite_teardown()
end

--- setup function
function setup()
  gateway.setHighWaterMark()
end

-----------------------------------------------------------------------------------------------
--- teardown function executed after each unit test
function teardown()
  gateway.setHighWaterMark()
  if restoreSourcecode then
    local Fields = {
      {Name="path",Value="/act/svc/VMS/Smtp.lua"},
      {Name="offset",Value=0},
      {Name="flags",Value="Overwrite"},
      {Name="data",Value=SourcecodeData}
    }
    filesystemSW:sendMessageByName("write", Fields)
    filesystemSW:waitForMessagesByName({"writeResult"})
    systemSW:restartService(vmsSW.sin)
    vmsSW:waitForMessagesByName({"Version"})
    restoreSourcecode = false
  end
end

-------------------------
-- Test Cases
-------------------------
function test_CommonReport_WhenGetVersionMessageReceived_SendVersionInfoMessage()
  vmsSW:sendMessageByName("GetVersion")
  local receivedMessages = vmsSW:waitForMessagesByName({"Version"})
  
  local versionMessage = receivedMessages.Version
  
  --check if message was received
  assert_not_nil(versionMessage, "Version message not received")
  
  --check if message contains agent version
  assert_not_nil(versionMessage.VmsAgent, "Version message does not contain VmsAgent (version) field")
  
  --check if message contains 
  assert_not_nil(versionMessage.IdpPackage, "Version message does not contain IdpPackage (LSF version) field")
  
  --check if message contains source code hash
  assert_not_nil(versionMessage.SourceCodeHash, "Version message does not contain SourceCodeHash (Source verification) field")

end

function test_CommonReport_WhenSourceCodeHashChanged_SendVersionInfoMessage()
  -- Read 1st char of source code file - 
  local Fields = {}
  Fields = {
    {Name="path",Value="/act/svc/VMS/Smtp.lua"},
    {Name="offset",Value=0},
    {Name="size",Value=2},
  }
    
  filesystemSW:sendMessageByName("read", Fields)
  --wait till wait message is received
  local receivedMessages = filesystemSW:waitForMessagesByName({"readResult"})
  
  --verify that read went OK
  local readResult = receivedMessages.readResult
  assert_not_nil(
    readResult, 
    "Could not save data into version info file"
  )
  assert_equal(
    "OK", 
    readResult.result, 
    "Error during write into service version file"
  )
  restoreSourcecode = true
  SourcecodeData = readResult.data
  
  Fields = {
    {Name="path",Value="/act/svc/VMS/Smtp.lua"},
    {Name="offset",Value=0},
    {Name="flags",Value="Overwrite"},
    {Name="data",Value=framework.base64Encode(":)")}
  }
  filesystemSW:sendMessageByName("write", Fields)
  receivedMessages = filesystemSW:waitForMessagesByName({"writeResult"})
  --restart VMS service
  systemSW:restartService(vmsSW.sin)
  
  --wait for Version message
  receivedMessages = vmsSW:waitForMessagesByName({"Version"})
  
  --verify Version message
  local versionMessage = receivedMessages.Version
  assert_not_nil(
    versionMessage, 
    "Version message not received"
  )
  
  --check if message contains agent version
  assert_not_nil(
    versionMessage.VmsAgent, 
    "Version message does not contain VmsAgent (version) field"
  )
  
  --check if message contains 
  assert_not_nil(
    versionMessage.IdpPackage, 
    "Version message does not contain IdpPackage (LSF version) field"
  )
  
  --check if message contains source code hash
  assert_not_nil(
    versionMessage.SourceCodeHash, 
    "Version message does not contain SourceCodeHash (Source verification) field"
  )
  
end

function test_CommonReport_WhenSourceCodeHasNotChange_VersionReportIsNotSent()
  systemSW:restartService(vmsSW.sin)
  local receivedMessages = vmsSW:waitForMessagesByName({"Version"}, 20)
  
  assert_nil(receivedMessages.Vesion, "Version message sent incorrectly")
  
end

function test_CommonReport_WhenFirmwarePackageHasChanged_VersionReportIsSent()
  assert_true(false, "TC not implemented yet")
end

function test_CommonReport_WhenVmsVersionHasChanged_VersionReportIsSent()
  assert_true(false, "TC not implemented yet")
end

function test_CommonReport_WhenVersionMessageSendDisabled_VersionReportIsNotSent()
  assert_true(false, "Functionality not implemented?")
end

function test_CommonReport_WhenServiceStartsUp_StartupMessageIsSent()
  assert_true(fasle, "Functionality not implemented?")
end