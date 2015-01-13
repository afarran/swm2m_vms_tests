-----------
-- CommonReports test module
-- - contains VMS reporting features
-- @module TestCommonReportModule

module("TestCommonReportModule", package.seeall)


function suite_setup()
  -- reset of properties 
  -- restarting VMS agent ?
    
end

-- executed after each test suite
function suite_teardown()
end

--- setup function
function setup()
end

-----------------------------------------------------------------------------------------------
--- teardown function executed after each unit test
function teardown()
  
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
  --rewrite SourceCodeHash so when new hash is calculated they wont be equal, that should trigger the Version message
  local Fields = {}
  local newHashCode = 42475
  Fields = {{Name="path",Value="/data/svc/VMS/version.dat"},
          {Name="offset",Value=0},
          {Name="flags",Value="Overwrite"},
          {Name="data",Value=framework.base64Encode("V{HelmPanelInterface=\"\",MessageDefHash=53522,PropDefHash=51399,SourceCodeHash=" .. newHashCode ..",VmsAgent=\"1.2.0\",IdpPackage=\"5.0.7.8877\",}\n")}}
    
  filesystemSW:sendMessageByName("write", Fields)
  --wait till wait message is received
  local receivedMessages = filesystemSW:waitForMessagesByName({"writeResult"})
  
  --verify that write went OK
  local writeResult = receivedMessages.writeResult
  assert_not_nil(writeResult, "Could not save data into version info file")
  assert_equal("OK", writeResult.result, "Error during write into service version file")
  
  --restart VMS service
  systemSW:restartService(vmsSW.sin)
  
  --wait for Version message
  receivedMessages = vmsSW:waitForMessagesByName({"Version"})
  
  --verify Version message
  local versionMessage = receivedMessages.Version
  assert_not_nil(versionMessage, "Version message not received")
  
  --check if message contains agent version
  assert_not_nil(versionMessage.VmsAgent, "Version message does not contain VmsAgent (version) field")
  
  --check if message contains 
  assert_not_nil(versionMessage.IdpPackage, "Version message does not contain IdpPackage (LSF version) field")
  
  --check if message contains source code hash
  assert_not_nil(versionMessage.SourceCodeHash, "Version message does not contain SourceCodeHash (Source verification) field")
  
  assert_not_equal(newHashCode, versionMessage.SourceCodeHash, "Version Report SourceCodeHash is expected to be different from initial")
  
end