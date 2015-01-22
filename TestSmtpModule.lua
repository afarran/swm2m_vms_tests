----------- 
-- Smtp test module
-- - contains VMS features dependant on Smpt
-- @module TestSmtpModule

module("TestSmptModule", package.seeall)

function suite_setup()
  
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
  
end

-------------------------
-- Test Cases
-------------------------