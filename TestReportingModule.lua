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

function test_StandardReport()
  
  gps.set({speed=10}) 
  vmsServiceWrapper:setPropertiesByName({StandardReport1Interval=1})
  
end

