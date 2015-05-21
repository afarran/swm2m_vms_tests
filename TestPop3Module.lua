-----------
-- Pop3 test module
-- - contains VMS features dependant on Smpt
-- @module TestPop3Module

require "UtilLibs/Text"
require "Email/Pop3Wrapper"

local pop3 = Pop3Wrapper(serialMain)
pop3:setTimeout(5)

module("TestPop3Module", package.seeall)


function suite_setup()
  vmsSW:setPropertiesByName({
      MailSessionIdleTimeout = 1,
      GpsInEmails = true,
      AllowedEmailDomains = " ",
    })
end

-- executed after each test suite
function suite_teardown()

end

--- setup function
function setup()
  --gateway.setHighWaterMark()
end

-----------------------------------------------------------------------------------------------
--- teardown function executed after each unit test
function teardown()
end

-------------------------
-- Test Cases
-------------------------

function test_POP3_ServerReady()
  if not pop3:ready() then
    skip("Pop3 is not ready - serial port not opened (".. serialMain.name .. ")")
  end
  assert_true(pop3:ready(), "Pop3 is not ready - serial port not opened")
  pop3:start()
  local result = pop3:execute("")
  D:log(result)
end

