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
    if not restoreData.multiple then
      
      
      if restoreData.restartVMS then
        systemSW:restartService(vmsSW.sin)
        vmsSW:waitForMessagesByName({"Version"})
      end
      if restoreData.restartFramework then
        systemSW:restartFramework()
        vmsSW:waitForMessagesByName({"Version"})
      end
      
      restoreData = nil
      
    else
      for idx, data in pairs(restoreData.data) do
        local writeOK, writeMsg = filesystemSW:write(data.path, data.offset or 0, data.data, nil, true)
        assert_true(writeOK, "Failed to restore file data in teardown! Path: " .. data.path)
      end
      systemSW:restartFramework()
      vmsSW:waitForMessagesByName({"Version"})
      restoreData = nil
    end
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
  
  local sourceCodeFile = "/act/svc/VMS/main.lua"
  vmsSW:sendMessageByName("GetVersion")
  local receivedMessages = vmsSW:waitForMessagesByName({"Version"})
  local versionMessage = receivedMessages.Version
  assert_not_nil(versionMessage, "Can't get current VMS version, Version message not received when GetVersion message was sent")
  assert_not_nil(versionMessage.VmsAgent, "Version message does not containt VmsAgent field!")
  
  local currentHash = versionMessage.SourceCodeHash
  
  -- read two chars
  local readData, readResult = filesystemSW:read(sourceCodeFile, 0, 2)
  
  --verify that read went OK
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
  
  local writeOK, writeResult = filesystemSW:write(sourceCodeFile, 0, ":)")
  
  assert_true(writeOK, "Writing to source code file failed")
  vmsSW:setHighWaterMark()
  --restart VMS service
  systemSW:restartService(vmsSW.sin)
  
  --wait for Version message
  receivedMessages = vmsSW:waitForMessagesByName({"Version"})
  
  --verify Version message
  versionMessage = receivedMessages.Version
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
  
  -- check if new hash is different thatn original one
  assert_not_equal(
    currentHash, 
    versionMessage.SourceCodeHash,
    "Changed source code hash is exactly the same as original hash code!"
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
  local path = "/act/info/PackageVersion.txt"
  
  local readData, readResult = filesystemSW:read(path, 0, 1)
  --verify that read went OK
  assert_not_nil(
    readResult, 
    "Could not save data into version info file"
  )
  assert_equal(
    "OK", 
    readResult.result, 
    "Error during write into service version file"
  )
  
  local versionNow = tonumber(string.char(unpack(readData)))
  local versionNext = versionNow + 1
  if (versionNext >= 10) then versionNext = 0 end
  local writeOK, writeResult = filesystemSW:write(path, 0, "" .. versionNext)
  assert_true(writeOK, "Couldn't write data to PackageVersion file")
  restoreData = {}
  restoreData.path = path
  restoreData.data = readResult.data
  restoreData.offset = 0
  restoreData.restartFramework = true
    
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
  local currentMessageDefHash = versionMessage.MessageDefHash
  local currentPropDefHash = versionMessage.PropDefHash
  
  -- search for version info in main.lua between 800 and 1000 chars
  local data, readResult = filesystemSW:read(path, 800, 200)
  local strData = string.char(unpack(data))
  local vmsVersionOffset = string.find(strData, currentVersion)
  local vmsVersionConstantOffset = string.find(strData, "_VERSION")
  
  assert_not_nil(vmsVersionOffset, "Can't find VMS version in main.lua")
  assert_not_nil(vmsVersionConstantOffset, "Can't find VMS version declaration in main.lua")
  
  vmsVersionOffset = 800 + vmsVersionOffset - 1
  
  local nextVersion = tonumber(string.sub(currentVersion, 1, 1)) + 1 -- increase version by 1
  if (nextVersion >= 10) then nextVersion = 0 end
  local writeOK = filesystemSW:write(path, vmsVersionOffset, "" .. nextVersion)
  assert_true(writeOK, "Could not write version to VMS main.lua")
  restoreData = {}
  restoreData.path = path
  restoreData.offset = vmsVersionOffset
  restoreData.data = framework.base64Encode(currentVersion)
  restoreData.restartFramework = true
  
  vmsSW:setHighWaterMark()
  systemSW:restartFramework()
  receivedMessages = vmsSW:waitForMessagesByName({"Version"})
  versionMessage = receivedMessages.Version
  
  assert_not_nil(versionMessage, "Version message not received afer VMS version changed")
  assert_not_equal(currentVersion, versionMessage.VmsAgent, "Reported VMS agent version is incorrect")
  assert_equal(currentMessageDefHash, versionMessage.MessageDefHash, "Message definition was not changed but MessageDefHash is different")
  assert_equal(currentPropDefHash, versionMessage.PropDefHash, "Property definition was not changed but PropDefHash is different")
  
end

function test_CommonReport_WhenMessageDefinitionChanged_VersionMessageIsSent()
  local path = "/act/svc/VMS/messages.lua"    
  vmsSW:sendMessageByName("GetVersion")
  local receivedMessages = vmsSW:waitForMessagesByName({"Version"})
  local versionMessage = receivedMessages.Version
  local currentVmsAgent = versionMessage.VmsAgent
  
  assert_not_nil(versionMessage, "Can't get current VMS version, Version message not received when GetVersion message was sent")
  assert_not_nil(versionMessage.MessageDefHash, "Version message does not containt MessageDefHash field!")
  local currentMessageDefHash = versionMessage.MessageDefHash
  local currentPropDefHash = versionMessage.PropDefHash
  
  local readData, readResult = filesystemSW:read(path, 0, 100)
  local strData = string.char(unpack(readData))
  
  local messageNameOffset = string.find(strData, "Message")
  assert_not_nil(messageNameOffset, "Message string not found in message definition file")
  
  messageNameOffset = messageNameOffset - 1 -- calculate real offset
  
  local writeOK, writeResult = filesystemSW:write(path, messageNameOffset, "xxasdf")
  assert_true(writeOK, "Writing to "..path.." failed!")
  
  restoreData = {}
  restoreData.path = path
  restoreData.offset = messageNameOffset
  restoreData.data = framework.base64Encode("Message")
  restoreData.restartVMS = true
  vmsSW:setHighWaterMark()
  systemSW:restartService(vmsSW.sin)
  
  receivedMessages = vmsSW:waitForMessagesByName({"Version"})
  versionMessage = receivedMessages.Version
  assert_not_nil(versionMessage, "Version message not received")
  assert_not_nil(versionMessage.MessageDefHash, "Version message does not contain MessageDefHash field")
  assert_not_equal(currentMessageDefHash, versionMessage.MessageDefHash, "MessageDefHash is expected to be different than original one!")
  assert_equal(currentPropDefHash, versionMessage.PropDefHash, "Property definition has not changed but PropDefHash is different!")
  assert_equal(currentVmsAgent, versionMessage.VmsAgent, "Vms agent has not changed but VmsAgent field is different!")
  
end

function test_CommonReport_WhenPropertyDefinitionChanged_VersionMessageIsSent()
  local path = "/act/svc/VMS/properties.lua"    
  vmsSW:sendMessageByName("GetVersion")
  local receivedMessages = vmsSW:waitForMessagesByName({"Version"})
  local versionMessage = receivedMessages.Version
  local currentVmsAgent = versionMessage.VmsAgent
  
  assert_not_nil(versionMessage, "Can't get current VMS version, Version message not received when GetVersion message was sent")
  assert_not_nil(versionMessage.PropDefHash, "Version message does not containt PropDefHash field!")
  local currentMessageDefHash = versionMessage.MessageDefHash
  local currentPropDefHash = versionMessage.PropDefHash
  
  local readData, readResult = filesystemSW:read(path, 0, 100)
  local strData = string.char(unpack(readData))
  
  local propertyOffset, propertyOffsetEnd, currentPropertyNumber = string.find(strData, "%,(%d+)%)\n")

  local currentNumber = string.sub(currentPropertyNumber, 1, 1)
  
  local nextNumber = (tonumber(currentNumber) + 1) % 10
  -- propertyNameOffset = propertyNameOffset - 1 -- Offset calculation is not needed, string.find returns match with "," so it has to be shifted +1
  local writeOK, writeResult = filesystemSW:write(path, propertyOffset, ""..nextNumber)
  assert_true(writeOK, "Write to "..path.." failed!")
  
  restoreData = {}
  restoreData.path = path
  restoreData.offset = propertyOffset
  restoreData.data = framework.base64Encode(currentPropertyNumber)
  restoreData.restartVMS = true
  
  vmsSW:setHighWaterMark()
  systemSW:restartService(vmsSW.sin)
  receivedMessages = vmsSW:waitForMessagesByName({"Version"})
  versionMessage = receivedMessages.Version
  assert_not_nil(versionMessage, "Version message not received")
  assert_not_nil(versionMessage.PropDefHash, "Version message does not contain PropDefHash field")
  assert_not_equal(currentPropDefHash, versionMessage.PropDefHash, "PropDefHash is expected to be different than original one!")
  assert_equal(currentMessageDefHash, versionMessage.MessageDefHash, "Message definition has not changed but MessageDefHash is different!")
  assert_equal(currentVmsAgent, versionMessage.VmsAgent, "Vms agent has not changed but VmsAgent field is different!")
  
end

function changeHelmPanelVersion(currentHelmPanelInterface)
  local path = uniboxSW:getServicePath() .. "main.lua"
  
  -- search for version info in main.lua between 800 and 1000 chars
  local data, readResult = filesystemSW:read(path, 800, 300)
  local strData = string.char(unpack(data))
  local helmPanelVersionOffset = string.find(strData, currentHelmPanelInterface)
  local helmPanelVersionConstantOffset = string.find(strData, "_VERSION")
  
  assert_not_nil(helmPanelVersionOffset, "Can't find HelmPanelInterface version in "..path)
  assert_not_nil(helmPanelVersionConstantOffset, "Can't find HelmPanelInterface version declaration in "..path)
  
  helmPanelVersionOffset = 800 + helmPanelVersionOffset - 1
  
  local nextVersion = tonumber(string.sub(currentHelmPanelInterface, 1, 1)) + 1 -- increase version by 1
  if (nextVersion >= 10) then nextVersion = 0 end
  local writeOK = filesystemSW:write(path, helmPanelVersionOffset, "" .. nextVersion)
  assert_true(writeOK, "Could not write version to "..path)
  restoreData = {}
  restoreData.path = path
  restoreData.offset = helmPanelVersionOffset
  restoreData.data = framework.base64Encode(currentHelmPanelInterface)
  restoreData.restartFramework = true
  
end

function test_CommonReport_WhenHelmPanelVersionHasChanged_VersionReportIsSent()
  local path = uniboxSW:getServicePath() .. "main.lua"
  local receivedMessages = vmsSW:requestMessageByName("GetVersion", nil, "Version")
  local versionMessage = receivedMessages.Version
  assert_not_nil(versionMessage, "Can't get current VMS version, Version message not received when GetVersion message was sent")
  assert_not_nil(versionMessage.HelmPanelInterface, "Version message does not containt HelmPanelInterface field!")
  
  local currentHelmPanelInterface = versionMessage.HelmPanelInterface
  local currentPropDefHash = versionMessage.PropDefHash
  local currentMessageDefHash = versionMessage.MessageDefHash
  local currentVmsAgent = versionMessage.VmsAgent
  
  changeHelmPanelVersion(currentHelmPanelInterface)
  
  vmsSW:setHighWaterMark()
  systemSW:restartFramework()
  receivedMessages = vmsSW:waitForMessagesByName({"Version"})
  versionMessage = receivedMessages.Version
  
  assert_not_nil(versionMessage, "Version message not received afer VMS version changed")
  assert_not_equal(currentHelmPanelInterface, versionMessage.HelmPanelInterface, "Reported VMS agent version is incorrect")
  assert_equal(currentPropDefHash, versionMessage.PropDefHash, "PropDefHash is expected to be different than original one!")
  assert_equal(currentMessageDefHash, versionMessage.MessageDefHash, "Message definition has not changed but MessageDefHash is different!")
  assert_equal(currentVmsAgent, versionMessage.VmsAgent, "Vms agent has not changed but VmsAgent field is different!")
  
end

function test_CommonReport_WhenMessageDefintionAndPropertyDefinitionChanged_SingleVersionReportIsSent()
  local path_properties = "/act/svc/VMS/properties.lua"
  local path_messages = "/act/svc/VMS/messages.lua"    

  
  local receivedMessages = vmsSW:requestMessageByName("GetVersion", nil, "Version")
  local versionMessage = receivedMessages.Version
  local currentVmsAgent = versionMessage.VmsAgent
  
  assert_not_nil(versionMessage, "Can't get current VMS version, Version message not received when GetVersion message was sent")
  assert_not_nil(versionMessage.PropDefHash, "Version message does not containt PropDefHash field!")
  assert_not_nil(versionMessage.MessageDefHash, "Version message does not containt MessageDefHash field!")
  local currentMessageDefHash = versionMessage.MessageDefHash
  local currentPropDefHash = versionMessage.PropDefHash
  
  -- Change property definition
  local readData, readResult = filesystemSW:read(path_properties, 0, 100)
  local strData = string.char(unpack(readData))
  
  local propertyOffset, propertyOffsetEnd, currentPropertyNumber = string.find(strData, "%,(%d+)%)\n")

  local currentNumber = string.sub(currentPropertyNumber, 1, 1)
  
  local nextNumber = (tonumber(currentNumber) + 1) % 10
  -- propertyNameOffset = propertyNameOffset - 1 -- Offset calculation is not needed, string.find returns match with "," so it has to be shifted +1
  local writeOK, writeResult = filesystemSW:write(path_properties, propertyOffset, ""..nextNumber)
  assert_true(writeOK, "Write to "..path_properties.." failed!")
  
  restoreData = {}
  restoreData.multiple = true
  restoreData.data = {}
  restoreData.data[1] = {
    path = path_properties,
    offset = propertyOffset,
    data = framework.base64Encode(currentPropertyNumber),
  }
  
  -- Change message definition
  readData, readResult = filesystemSW:read(path_messages, 0, 100)
  strData = string.char(unpack(readData))
  
  local messageNameOffset = string.find(strData, "Message")
  assert_not_nil(messageNameOffset, "Message string not found in message definition file")
  
  messageNameOffset = messageNameOffset - 1 -- calculate real offset
  
  writeOK, writeResult = filesystemSW:write(path_messages, messageNameOffset, "xxasdf")
  assert_true(writeOK, "Writing to "..path_messages.." failed!")
  
  restoreData.data[2] = {
    path = path_messages,
    offset = messageNameOffset,
    data = framework.base64Encode("Message"),
  }
  
  -- get version message and process assertions
  vmsSW:setHighWaterMark()
  systemSW:restartService(vmsSW.sin)
  receivedMessages = vmsSW:waitForMessagesByName({"Version"})
  local duplicatedReceivedMessages = vmsSW:waitForMessagesByName({"Version"}, 20)
  assert_nil(duplicatedReceivedMessages.Version, "Version Message received twice!")
  versionMessage = receivedMessages.Version
  assert_not_nil(versionMessage, "Version message not received")
  assert_not_nil(versionMessage.PropDefHash, "Version message does not contain PropDefHash field")
  assert_not_nil(versionMessage.MessageDefHash, "Version message does not contain MessageDefHash field")
  assert_not_equal(currentPropDefHash, versionMessage.PropDefHash, "PropDefHash is expected to be different than original one!")
  assert_not_equal(currentMessageDefHash, versionMessage.MessageDefHash, "MessageDefHash is expected to be different than original one!")
  assert_equal(currentVmsAgent, versionMessage.VmsAgent, "Vms agent has not changed but VmsAgent field is different!")
end