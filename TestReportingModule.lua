-----------
-- Reporting test module
-- - contains VMS reporting features
-- @module TestReportingModule

module("TestReportingModule", package.seeall)


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

function test_StandardReportContent()
  
  vmsSW:setPropertiesByName({StandardReport1Interval=1})
  
  positionSW:sendMessageByName("getPosition",{fixType = "3D"})
  positionMessage = positionSW:waitForMessagesByName({"position"}) 
  initialPosition = positionMessage.position
  assert_not_nil(initialPosition.longitude,"No longitude in position messsage.")
  assert_not_nil(initialPosition.latitude,"No latitude in position messsage.")
  
  newPosition = {
    latitude = initialPosition.latitude/60000 + 1,
    longitude = initialPosition.longitude/60000 + 1
  }
  
  gps.set(newPosition)
  framework.delay(GPS_PROCESS_TIME + GPS_READ_INTERVAL)
  
  reportMessage = vmsSW:waitForMessagesByName({"StandardReport1"})
 
  print(framework.dump(reportMessage))
  assert_equal(reportMessage["StandardReport1"].Latitude,newPosition.latitude, "Wrong latitude")
  
end

