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
  if restoreData and restoreData.data then
    for idx, data in pairs(restoreData.data) do
      local writeOK, writeMsg = filesystemSW:write(data.path, data.offset or 0, data.data, nil, true)
      assert_true(writeOK, "Failed to restore file data in teardown! Path: " .. data.path)
    end
    if restoreData.restartVMS then
      systemSW:restartService(vmsSW.sin)
      vmsSW:waitForMessagesByName({"Version"})
    end
    if restoreData.restartFramework then
      systemSW:restartFramework(true)
      vmsSW:waitForMessagesByName({"Version"})
    end
    restoreData = nil
  end
end

local function queueRestoreData(restore)
  if not restoreData then 
    restoreData = {}
    restoreData.data = {}
  end
  
  table.insert(restoreData.data, restore)
end

---
-- reads first two characters for source file
-- replaces them with ":)"
-- queues to restore the data in teardown
local function changeSourceCode()
  local sourceCodeFile = "/act/svc/VMS/main.lua"
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
  queueRestoreData(
    { path = sourceCodeFile,
      data = readResult.data,
      offset = 0,
    })
  restoreData.restartVMS = true
  local writeOK, writeResult = filesystemSW:write(sourceCodeFile, 0, ":)")
  assert_true(writeOK, "Writing to source code file failed")
end

local function changeHelmPanelVersion(currentHelmPanelInterface)
  skip("Interface unit version change tests fail on HW, if main.lua is changed, then it fails to load")
  local path = uniboxSW:getServicePath() .. "main.lua"
  
  -- search for version info in main.lua between 800 and 1000 chars
  local data, readResult = filesystemSW:read(path, 800, 400)
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
  
  queueRestoreData(
  { path = path,
    data = framework.base64Encode(currentHelmPanelInterface),
    offset = helmPanelVersionOffset,
  })
  restoreData.restartFramework = true
  
end


local function changeFirmwarePackageVersion()
  local path = "/act/info/PackageVersion.txt"
  
  local readData, readResult = filesystemSW:read(path, 0, 1)
  --verify that read went OK
  assert_not_nil(
    readResult, 
    "Could not read data from package version info file"
  )
  assert_equal(
    "OK", 
    readResult.result, 
    "Error during read data from package version info file"
  )
  
  local versionNow = tonumber(string.char(unpack(readData)))
  local versionNext = versionNow + 1
  if (versionNext >= 10) then versionNext = 0 end
  local writeOK, writeResult = filesystemSW:write(path, 0, "" .. versionNext)
  assert_true(writeOK, "Couldn't write data to PackageVersion file")
  
  
  queueRestoreData(
  { path = path,
    data = readResult.data,
    offset = 0,
  })
  restoreData.restartFramework = true

end

local function changeVmsVersion(currentVersion)
  local path = "/act/svc/VMS/main.lua"    
  
  -- search for version info in main.lua between 800 and 1000 chars
  local offsetStart = 400
  local data, readResult = filesystemSW:read(path, offsetStart, offsetStart+200)
  local strData = string.char(unpack(data))
  local vmsVersionOffset = string.find(strData, currentVersion)
  local vmsVersionConstantOffset = string.find(strData, "_VERSION")
  
  assert_not_nil(vmsVersionOffset, "Can't find VMS version in main.lua")
  assert_not_nil(vmsVersionConstantOffset, "Can't find VMS version declaration in main.lua")
  
  vmsVersionOffset = offsetStart + vmsVersionOffset - 1
  
  local nextVersion = tonumber(string.sub(currentVersion, 1, 1)) + 1 -- increase version by 1
  if (nextVersion >= 10) then nextVersion = 0 end
  local writeOK = filesystemSW:write(path, vmsVersionOffset, "" .. nextVersion)
  assert_true(writeOK, "Could not write version to VMS main.lua")
  
  queueRestoreData(
  { path = path,
    data = framework.base64Encode(currentVersion),
    offset = vmsVersionOffset,
  })
  restoreData.restartFramework = true
end

local function changeMessageDefinition()
  local path = "/act/svc/VMS/messages.lua"    

  local readData, readResult = filesystemSW:read(path, 0, 100)
  local strData = string.char(unpack(readData))
  
  local messageNameOffset = string.find(strData, "Message")
  assert_not_nil(messageNameOffset, "Message string not found in message definition file")
  
  messageNameOffset = messageNameOffset - 1 -- calculate real offset
  
  local writeOK, writeResult = filesystemSW:write(path, messageNameOffset, "XXXYYY")
  assert_true(writeOK, "Writing to "..path.." failed!")
  
  
  queueRestoreData(
  { path = path,
    data = framework.base64Encode("Message"),
    offset = messageNameOffset,
  })
  restoreData.restartVMS = true
end

local function changePropertyDefinition()
  local path = "/act/svc/VMS/properties.lua"    

  local readData, readResult = filesystemSW:read(path, 0, 100)
  local strData = string.char(unpack(readData))
  
  local propertyOffset, propertyOffsetEnd, currentPropertyNumber = string.find(strData, "%,(%d+)%)\n")

  local currentNumber = string.sub(currentPropertyNumber, 1, 1)
  
  local nextNumber = (tonumber(currentNumber) + 1) % 10
  -- propertyNameOffset = propertyNameOffset - 1 -- Offset calculation is not needed, string.find returns match with "," so it has to be shifted +1
  local writeOK, writeResult = filesystemSW:write(path, propertyOffset, ""..nextNumber)
  assert_true(writeOK, "Write to "..path.." failed!")
  
  queueRestoreData(
  { path = path,
    data = framework.base64Encode(currentPropertyNumber),
    offset = propertyOffset,
  })
  restoreData.restartVMS = true
end

-------------------------
-- Test Cases
-------------------------
function test_CommonReport_WhenGetVersionMessageReceived_SendVersionInfoMessage()
  local receivedMessages = vmsSW:requestMessageByName("GetVersion", nil, "Version")
  
  --check if message was received
  local versionMessage = receivedMessages.Version
  assert_not_nil(versionMessage, "Version message not received")
  
  versionMessage:_verify({
        IdpPackage =      {assert_not_nil},
        VmsAgent =        {assert_not_nil},
        InterfaceUnit =   {assert_not_nil},
        SourceCodeHash =  {assert_not_nil},
        PropDefHash =  {assert_not_nil},
        MessageDefHash = {assert_not_nil},
        -- old fields are sent only at service start, not for GetVersion request.
        OldIdpPackage = {assert_nil},
        OldVmsAgent = {assert_nil},
        OldInterfaceUnit = {assert_nil},
        OldSourceCodeHash = {assert_nil},
        OldPropDefHash = {assert_nil},
        OldMessageDefHash = {assert_nil},
      })
end

function test_CommonReport_WhenSourceCodeHashChanged_SendVersionInfoMessage()
  
  local receivedMessages = vmsSW:requestMessageByName("GetVersion", nil, "Version")
  local versionMessage = receivedMessages.Version
  
  assert_not_nil(versionMessage, "Can't get current VMS version, Version message not received when GetVersion message was sent")
  versionMessage:_verify({
      VmsAgent = {assert_not_nil},
      SourceCodeHash = {assert_not_nil},
    })
  
  local currentHash = versionMessage.SourceCodeHash
  
  changeSourceCode()
  vmsSW:setHighWaterMark()
  --restart VMS service
  systemSW:restartService(vmsSW.sin)
  
  --wait for Version message
  receivedMessages = vmsSW:waitForMessagesByName({"Version"})
  --verify Version message
  local afterChangeVersionMessage = receivedMessages.Version
  assert_not_nil(afterChangeVersionMessage, "After Change Version message not received")
  
  versionMessage:_equal(afterChangeVersionMessage, nil, {"SourceCodeHash", "Timestamp", "OldSourceCodeHash"})
  
  versionMessage:_verify({
      SourceCodeHash = {assert_not_equal, afterChangeVersionMessage.SourceCodeHash},
      SourceCodeHash = {assert_equal, afterChangeVersionMessage.OldSourceCodeHash},
      })
end

function test_CommonReport_WhenSourceCodeHasNotChange_VersionReportIsNotSent()
  systemSW:restartService(vmsSW.sin)
  local receivedMessages = vmsSW:waitForMessagesByName({"Version"}, 20)
  
  assert_nil(receivedMessages.Vesion, "Version message sent incorrectly")
  
end

function test_CommonReport_WhenFirmwarePackageHasChanged_VersionReportIsSent()
  local Fields = {}
  
  local receivedMessages = vmsSW:requestMessageByName("GetVersion", nil, "Version")
  local versionMessage = receivedMessages.Version
  
  assert_not_nil(versionMessage, "Version message not received")
  
  versionMessage:_verify({
      IdpPackage =      {assert_not_nil},
      VmsAgent =        {assert_not_nil},
      InterfaceUnit =   {assert_not_nil},
      SourceCodeHash =  {assert_not_nil},
      PropDefHash =  {assert_not_nil},
      MessageDefHash = {assert_not_nil},
      -- old fields are sent only at service start, not for GetVersion request.
      OldIdpPackage = {assert_nil},
      OldVmsAgent = {assert_nil},
      OldInterfaceUnit = {assert_nil},
      OldSourceCodeHash = {assert_nil},
      OldPropDefHash = {assert_nil},
      OldMessageDefHash = {assert_nil},
    })
  
  changeFirmwarePackageVersion()
  --restart Framework
  systemSW:restartFramework(true)
  
  --wait for Version message
  vmsSW:setHighWaterMark()
  receivedMessages = vmsSW:waitForMessagesByName({"Version"})
  
  receivedMessages = systemSW:requestMessageByName("getTerminalInfo", nil, "terminalInfo")
  local terminalInfo = receivedMessages.terminalInfo
  
  --verify Version message
  local versionMessageAfterChange = receivedMessages.Version
  assert_not_nil(versionMessageAfterChange, "Version message not received")
  
  versionMessageAfterChange:_equal(versionMessage, nil, {"Timestamp", "OldIdpPackage", "IdpPackage"} )
  
  versionMessageAfterChange:_verify({
      IdpPackage = {assert_not_equal, versionMessage.IdpPackage},
      IdpPackage = {assert_equal, terminalInfo.packageVersion},
      OldIdpPackage = {assert_equal, versionMessage.IdpPackage},
    })
end

function test_CommonReport_WhenVmsVersionHasChanged_VersionReportIsSent()
  local receivedMessages = vmsSW:requestMessageByName("GetVersion", nil, "Version")
  local versionMessage = receivedMessages.Version
  assert_not_nil(versionMessage, "Can't get current VMS version, Version message not received when GetVersion message was sent")

  versionMessage:_verify({
      IdpPackage =      {assert_not_nil},
      VmsAgent =        {assert_not_nil},
      InterfaceUnit =   {assert_not_nil},
      SourceCodeHash =  {assert_not_nil},
      PropDefHash =  {assert_not_nil},
      MessageDefHash = {assert_not_nil},
      -- old fields are sent only at service start, not for GetVersion request.
      OldIdpPackage = {assert_nil},
      OldVmsAgent = {assert_nil},
      OldInterfaceUnit = {assert_nil},
      OldSourceCodeHash = {assert_nil},
      OldPropDefHash = {assert_nil},
      OldMessageDefHash = {assert_nil},
    })

  changeVmsVersion(versionMessage.VmsAgent)
  
  vmsSW:setHighWaterMark()
  systemSW:restartFramework(true)
  receivedMessages = vmsSW:waitForMessagesByName({"Version"})
  local versionMessageAfterChange = receivedMessages.Version
  
  assert_not_nil(versionMessage, "VMS version message not received")
  
  versionMessageAfterChange:_equal(versionMessage, nil, {"Timestamp", "VmsAgent", "OldVmsAgent", "SourceCodeHash", "OldSourceCodeHash"})
  
  versionMessageAfterChange:_verify({
    VmsAgent = {assert_not_equal, versionMessage.VmsAgent},
    OldVmsAgent = {assert_equal, versionMessage.VmsAgent},
  })
  
  
end

function test_CommonReport_WhenMessageDefinitionChanged_VersionMessageIsSent()
  vmsSW:sendMessageByName("GetVersion")
  local receivedMessages = vmsSW:waitForMessagesByName({"Version"})
  local versionMessage = receivedMessages.Version
  
  assert_not_nil(versionMessage, "Can't get current VMS version, Version message not received when GetVersion message was sent")
  
  versionMessage:_verify({
      IdpPackage =      {assert_not_nil},
      VmsAgent =        {assert_not_nil},
      InterfaceUnit =   {assert_not_nil},
      SourceCodeHash =  {assert_not_nil},
      PropDefHash =  {assert_not_nil},
      MessageDefHash = {assert_not_nil},
      -- old fields are sent only at service start, not for GetVersion request.
      OldIdpPackage = {assert_nil},
      OldVmsAgent = {assert_nil},
      OldInterfaceUnit = {assert_nil},
      OldSourceCodeHash = {assert_nil},
      OldPropDefHash = {assert_nil},
      OldMessageDefHash = {assert_nil},
    })
  
  changeMessageDefinition()
  
  vmsSW:setHighWaterMark()
  systemSW:restartService(vmsSW.sin)
  
  receivedMessages = vmsSW:waitForMessagesByName({"Version"})
  local versionMessageAfterChange = receivedMessages.Version
  assert_not_nil(versionMessageAfterChange, "Version message not received")
  
  versionMessageAfterChange:_equal(versionMessage, nil, {"Timestamp", "MessageDefHash", "OldMessageDefHash"})
  
  versionMessageAfterChange:_verify({
        MessageDefHash = {assert_not_equal, versionMessage.MessageDefHash},
        OldMessageDefHash = {assert_equal, versionMessage.MessageDefHash},
      })
      
end

function test_CommonReport_WhenPropertyDefinitionChanged_VersionMessageIsSent()
  vmsSW:sendMessageByName("GetVersion")
  local receivedMessages = vmsSW:waitForMessagesByName({"Version"})
  local versionMessage = receivedMessages.Version
  assert_not_nil(versionMessage, "Can't get current VMS version, Version message not received when GetVersion message was sent")
  
  versionMessage:_verify({
    IdpPackage =      {assert_not_nil},
    VmsAgent =        {assert_not_nil},
    InterfaceUnit =   {assert_not_nil},
    SourceCodeHash =  {assert_not_nil},
    PropDefHash =  {assert_not_nil},
    MessageDefHash = {assert_not_nil},
    -- old fields are sent only at service start, not for GetVersion request.
    OldIdpPackage = {assert_nil},
    OldVmsAgent = {assert_nil},
    OldInterfaceUnit = {assert_nil},
    OldSourceCodeHash = {assert_nil},
    OldPropDefHash = {assert_nil},
    OldMessageDefHash = {assert_nil},
  })
  
  changePropertyDefinition()
  
  vmsSW:setHighWaterMark()
  systemSW:restartService(vmsSW.sin)
  receivedMessages = vmsSW:waitForMessagesByName({"Version"})
  local versionMessageAfterChange = receivedMessages.Version
  assert_not_nil(versionMessageAfterChange, "Version message not received")
  
  versionMessageAfterChange:_equal(versionMessage, nil, {"Timestamp", "PropDefHash", "OldPropDefHash"})
  
  versionMessageAfterChange:_verify({
        PropDefHash = {assert_not_equal, versionMessage.PropDefHash},
        OldPropDefHash = {assert_equal, versionMessage.PropDefHash}
      })
  
end


function test_CommonReport_WhenHelmPanelVersionHasChanged_VersionReportIsSent()
  local path = uniboxSW:getServicePath() .. "main.lua"
  local receivedMessages = vmsSW:requestMessageByName("GetVersion", nil, "Version")
  local versionMessage = receivedMessages.Version
  assert_not_nil(versionMessage, "Can't get current VMS version, Version message not received when GetVersion message was sent")

  versionMessage:_verify({
    IdpPackage =      {assert_not_nil},
    VmsAgent =        {assert_not_nil},
    InterfaceUnit =   {assert_not_nil},
    SourceCodeHash =  {assert_not_nil},
    PropDefHash =  {assert_not_nil},
    MessageDefHash = {assert_not_nil},
    -- old fields are sent only at service start, not for GetVersion request.
    OldIdpPackage = {assert_nil},
    OldVmsAgent = {assert_nil},
    OldInterfaceUnit = {assert_nil},
    OldSourceCodeHash = {assert_nil},
    OldPropDefHash = {assert_nil},
    OldMessageDefHash = {assert_nil},
  })
  
  changeHelmPanelVersion(versionMessage.InterfaceUnit)
  
  vmsSW:setHighWaterMark()
  systemSW:restartFramework(true)
  receivedMessages = vmsSW:waitForMessagesByName({"Version"})
  local versionMessageAfterChange = receivedMessages.Version
  
  versionMessageAfterChange:_equal(versionMessage, nil, {"Timestamp", "InterfaceUnit", "OldInterfaceUnit"})
  
  versionMessageAfterChange:_verify({
      InterfaceUnit = {assert_not_equal, versionMessage.InterfaceUnit},
      OldInterfaceUnit = {assert_equal, versionMessage.InterfaceUnit},
    })
   
end

function test_CommonReport_WhenMessageDefintionAndPropertyDefinitionChanged_SingleVersionReportIsSent()
    
  local receivedMessages = vmsSW:requestMessageByName("GetVersion", nil, "Version")
  local versionMessage = receivedMessages.Version
  assert_not_nil(versionMessage, "Can't get current VMS version, Version message not received when GetVersion message was sent")

  versionMessage:_verify({
    IdpPackage =      {assert_not_nil},
    VmsAgent =        {assert_not_nil},
    InterfaceUnit =   {assert_not_nil},
    SourceCodeHash =  {assert_not_nil},
    PropDefHash =  {assert_not_nil},
    MessageDefHash = {assert_not_nil},
    -- old fields are sent only at service start, not for GetVersion request.
    OldIdpPackage = {assert_nil},
    OldVmsAgent = {assert_nil},
    OldInterfaceUnit = {assert_nil},
    OldSourceCodeHash = {assert_nil},
    OldPropDefHash = {assert_nil},
    OldMessageDefHash = {assert_nil},
  })
  
  changePropertyDefinition()
  changeMessageDefinition()
  
  -- get version message and process assertions
  vmsSW:setHighWaterMark()
  systemSW:restartService(vmsSW.sin)
  receivedMessages = vmsSW:waitForMessagesByName({"Version"})
  
  local duplicatedReceivedMessages = vmsSW:waitForMessagesByName({"Version"}, 20)  
  assert_nil(duplicatedReceivedMessages.Version, "Version Message received twice!")
  
  local versionMessageAfterChange = receivedMessages.Version
  assert_not_nil(versionMessageAfterChange, "Version message not received")
  
  versionMessageAfterChange:_equal(versionMessage, nil, 
    {"Timestamp", "PropDefHash", "OldPropDefHash", "MessageDefHash", "OldMessageDefHash"})
  
  versionMessageAfterChange:_verify({
      PropDefHash = {assert_not_equal, versionMessage.PropDefHash},
      OldPropDefHash = {assert_equal, versionMessage.PropDefHash},
      MessageDefHash = {assert_not_equal, versionMessage.MessageDefHash},
      OldMessageDefHash = {assert_equal, versionMessage.MessageDefHash},
    })
  
end