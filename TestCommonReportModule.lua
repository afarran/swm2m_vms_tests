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
  
end