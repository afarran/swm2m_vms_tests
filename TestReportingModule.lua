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
  generic_test_StandardReportContent("StandardReport1")
end

function generic_test_StandardReportContent(reportKey)
  
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
  assert_not_nil(
    initialPosition.speed,
    "No speed in position messsage."
  )
  newPosition = {
    latitude  = GPS:normalize(initialPosition.latitude)   + 1,
    longitude = GPS:normalize(initialPosition.longitude)  + 1,
    speed =  GPS:normalizeSpeed(initialPosition.speed) -- km/h
  }
  GPS:set(newPosition)
  reportMessage = vmsSW:waitForMessagesByName({reportKey})
  assert_equal(
    GPS:denormalize(newPosition.latitude), 
    tonumber(reportMessage[reportKey].Latitude), 
    "Wrong latitude"
  )
  assert_equal(
    GPS:denormalize(newPosition.longitude), 
    tonumber(reportMessage[reportKey].Longitude), 
    "Wrong longitude"
  )
  assert_equal(
    GPS:denormalizeSpeed(newPosition.speed), 
    tonumber(reportMessage[reportKey].Speed), 
    1,
    "Wrong speed"
  )
end