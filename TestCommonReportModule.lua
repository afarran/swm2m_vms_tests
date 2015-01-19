-----------
-- CommonReports test module
-- - contains VMS reporting features
-- @module TestCommonReportModule

module("TestCommonReportModule", package.seeall)
local restoreData = nil

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
  -- if some data has to be restored then handle it
  if restoreData then
    local Fields = {
      {Name="path",Value=restoreData.path},
      {Name="offset",Value=restoreData.offset or 0},
      {Name="flags",Value="Overwrite"},
      {Name="data",Value=restoreData.data}
    }
    filesystemSW:sendMessageByName("write", Fields)
    filesystemSW:waitForMessagesByName({"writeResult"})
    if restoreData.restartVMS then
      systemSW:restartService(vmsSW.sin)
    end
    if restoreData.restartFramework then
      systemSW:restartFramework()
    end
    
    vmsSW:waitForMessagesByName({"Version"})
    restoreData = nil
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
  local sourceCodeFile = "/act/svc/VMS/Smtp.lua"
  Fields = {
    {Name="path",Value=sourceCodeFile},
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
  restoreData = {}
  restoreData.path = sourceCodeFile
  restoreData.data = readResult.data
  restoreData.offset = 0
  restoreData.restartVMS = true
  
  Fields = {
    {Name="path",Value=sourceCodeFile},
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
  
  --check if message contains Framework version
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
  -- Read 1st char of source code file - 
  local Fields = {}
  local sourceCodeFile = "/act/info/PackageVersion.txt"
  Fields = {
    {Name="path",Value=sourceCodeFile},
    {Name="offset",Value=0},
    {Name="size",Value=1},
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
  restoreData = {}
  restoreData.path = sourceCodeFile
  restoreData.data = readResult.data
  restoreData.offset = 0
  restoreData.restartFramework = true
  
  Fields = {
    {Name="path",Value=sourceCodeFile},
    {Name="offset",Value=0},
    {Name="flags",Value="Overwrite"},
    {Name="data",Value=framework.base64Encode("1")}
  }
  filesystemSW:sendMessageByName("write", Fields)
  receivedMessages = filesystemSW:waitForMessagesByName({"writeResult"})
  --restart Framework
  systemSW:restartFramework()
  
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
  
  systemSW:sendMessageByName("getTerminalInfo")
  receivedMessages = systemSW:waitForMessagesByName({"terminalInfo"})
  local terminalInfo = receivedMessages.terminalInfo
  
  --check if message contains Framework version
  assert_not_nil(
    versionMessage.IdpPackage, 
    "Version message does not contain IdpPackage (LSF version) field"
  )
  
  -- check if Framework version is reported correctly
  assert_equal(
    terminalInfo.packageVersion,
    versionMessage.IdpPackage,
    "IdpPackage from versionMessage is not equal to packageVersion from terminalInfo message"
  )
  
  --check if message contains source code hash
  assert_not_nil(
    versionMessage.SourceCodeHash, 
    "Version message does not contain SourceCodeHash (Source verification) field"
  )
end

function test_CommonReport_WhenVmsVersionHasChanged_VersionReportIsSent()
  local path = "/act/svc/VMS/main.lua"    
  vmsSW:sendMessageByName("GetVersion")
  local receivedMessages = vmsSW:waitForMessagesByName({"Version"})
  local versionMessage = receivedMessages.Version
  assert_not_nil(versionMessage, "Can't get current VMS version, Version message not received when GetVersion message was sent")
  assert_not_nil(versionMessage.VmsAgent, "Version message does not containt VmsAgent field!")
  
  local currentVersion = versionMessage.VmsAgent
  
  -- search for version info in main.lua between 800 and 1000 chars
  local data, readResult = filesystemSW:read(path, 800, 200)
  local strData = string.char(unpack(data))
  local vmsVersionOffset = string.find(strData, currentVersion)
  local vmsVersionConstantOffset = string.find(strData, "_VERSION")
  
  assert_not_nil(vmsVersionOffset, "Can't find VMS version in main.lua")
  assert_not_nil(vmsVersionConstantOffset, "Can't find VMS version declaration in main.lua")
  
  vmsVersionOffset = 800 + vmsVersionOffset - 1
  
  local writeOK = filesystemSW:write(path, vmsVersionOffset, "0")
  assert_true(writeOK, "Could not write version to VMS main.lua")
  restoreData = {}
  restoreData.path = path
  restoreData.offset = vmsVersionOffset
  restoreData.data = framework.base64Encode(currentVersion)
  restoreData.restartFramework = true
  
  systemSW:restartFramework()
  receivedMessages = vmsSW:waitForMessagesByName({"Version"})
  versionMessage = receivedMessages.Version
  
  assert_not_nil(versionMessage, "Version message not received afer VMS version changed")
  assert_not_equal(currentVersion, versionMessage.VmsAgent, "Reported VMS agent version is incorrect")
  
end

function test_CommonReport_WhenVersionMessageSendDisabled_VersionReportIsNotSent()
  assert_true(false, "Functionality not implemented?")
end