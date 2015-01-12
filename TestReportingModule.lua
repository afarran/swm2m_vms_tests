-----------
-- Reporting test module
-- - contains VMS reporting features
-- @module TestReportingModule

module("TestReportingModule", package.seeall)


function suite_setup()
  -- reset of properties 
  -- restarting VMS agent ?
  
  --vmsServiceWrapper:setPropertiesByName({StandardReport1Interval=1})
  
  
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

function test_StandardReportContent()
  
  
  positionServiceWrapper:sendMessageByName("getPosition",{fixType = "3D"})
  positionMessage = positionServiceWrapper:waitForMessages({1})  -- TODO: add to ServiceMapper a method: waitForMessagesByName()
  
  initialPosition = positionMessage.position
  assert_not_nil(initialPosition.longitude,"No longitude in position messsage.")
  assert_not_nil(initialPosition.latitude,"No latitude in position messsage.")
  
  newPosition = {
    latitude = initialPosition.latitude + 60000,
    longitude = initialPosition.longitude + 60000
  }
  
  gps.set(newPosition)
  framework.delay(GPS_PROCESS_TIME + GPS_READ_INTERVAL)
  
  --TODO : finish this TC, some problems to investigate
  
end

