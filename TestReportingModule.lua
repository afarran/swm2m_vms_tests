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
  
  positionSW:sendMessageByName(
    "getPosition",
    {fixType = "3D"}
  )
  
  positionMessage = positionSW:waitForMessagesByName({"position"}) 
  initialPosition = positionMessage.position
  
  assert_not_nil(
    initialPosition.longitude,
    "No longitude in position messsage."
  )
  assert_not_nil(
    initialPosition.latitude,
    "No latitude in position messsage."
  )
  
  newPosition = {
    latitude  = GPS:normalize(initialPosition.latitude)   + 1,
    longitude = GPS:normalize(initialPosition.longitude)  + 1
  }
  
  GPS:set(newPosition)
  
  reportMessage = vmsSW:waitForMessagesByName({"StandardReport1"})
 
  print(framework.dump(reportMessage))
  
  assert_equal(
    GPS:denormalize(newPosition.latitude), 
    reportMessage["StandardReport1"].Latitude, 
    "Wrong latitude"
  )
  
end

