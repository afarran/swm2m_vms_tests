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

  -- needs some time to start shell
  --framework.delay(15)

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
  pop3:start()
  if not pop3:ready() then
    skip("Pop3 is not ready - serial port not opened (".. serialMain.name .. ")")
  end
  assert_true(pop3:ready(), "Pop3 is not ready - serial port not opened")
end

function teardown()
  pop3:request("quit")
end

-----------------------------------------------------------------------------------------------

-------------------------
-- Test Cases
-------------------------

function test_POP3_WhenUserNameAndPasswordIsSent_CorrectServerResponseIsReceived()
  D:log("POP3 login test")
  login()
end

function test_POP3_ServerLogin()
  D:log("POP3 login test")
  login()
end
--- LOGIC

function login()
  D:log("Login to POP3 server")
  local result = pop3:request("USER pblo")
  assert_not_nil(string.find(result,"+OK%s*pblo%s*accepted"),"POP3 USER command failed")
  D:log("Correct user name")
  local result = pop3:request("PASS abcd123")
  assert_not_nil(string.find(result,"+OK%s*password%s*accepted"),"POP3 PASS command failed")
  D:log("Correct password")
end

