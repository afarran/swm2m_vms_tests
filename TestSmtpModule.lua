----------- 
-- Smtp test module
-- - contains VMS features dependant on Smpt
-- @module TestSmtpModule

require "Email/SmtpWrapper"

local smtp = SmtpWrapper(serialMain)
smtp:setTimeout(5)

module("TestSmtpModule", package.seeall)

local SMTPclear = {}

function suite_setup()
  serialMain:open()
end

-- executed after each test suite
function suite_teardown()
  framework.delay(1) -- for some reason simulator blocks if serial port is closed too soon
  serialMain:close()
end

--- setup function
function setulp()
  gateway.setHighWaterMark()
end

-----------------------------------------------------------------------------------------------
--- teardown function executed after each unit test
function teardown()
  if SMTPclear then
    for index, command in pairs(SMTPclear) do
      smtp:execute(command)
      smtp:getResponse()
    end
    SMTPclear = {}
  end
end

-------------------------
-- Test Cases
-------------------------

function test_SMTP_WhenSMTPCommandCalled_ServerReturnsSMTPServiceReady()
  assert_true(smtp:ready(), "Smtp is not ready - serial port not opened")
  smtp:start()
  SMTPclear[1] = "QUIT"
  local startResponse = smtp:getResponse()
  assert_not_nil(startResponse, "SMTP module did not return start message")
  assert_match("^220.*SMTP Service Ready%. VMS v(%d+)%.(%d+)%.(%d+)", startResponse, "SMTP start message is incorrect")
  
end

local function startSmtp()
  assert_true(smtp:ready(), "Smtp is not ready - serial port not opened")
  smtp:start()
  SMTPclear[1] = "QUIT"
  local startResponse = smtp:getResponse()
  assert_not_nil(startResponse, "SMTP module did not return start message")
end

function test_SMTP_WhenHELOCommandCalled_ServerReturnsHeloMessage()
  startSmtp()  
  smtp:execute("HELO")
  local heloResponse = smtp:getResponse()
  assert_match("^250 Hello from IDP terminal", heloResponse, "HELO command response incorrect")
end

function test_SMTP_WhenQUITCommandCalled_ServerReturnsGoodbye()
  startSmtp()
  smtp:execute("QUIT")
  SMTPclear = {}
  local quitResponse = smtp:getResponse()
  assert_match("^221 Goodbye", quitResponse, "QUIT command response incorrect")  
end

function test_SMTP_WhenEHLOCommandCalled_ServerReturnsHelloMessageAndSize()
  startSmtp()
  smtp:execute("EHLO")
  local ehloResponse = smtp:getResponse()
  assert_match("^250 Hello from IDP terminal$", ehloResponse, "EHLO command response incorrect - does not contain HELO msg")
  assert_match("^250 SIZE (%d+)$", ehloResponse, "EHLO command response incorrect - does not contain SIZE")
end

function test_SMTP_WhenNOOPCommandCalled_ServerReturnsOk()
  startSmtp()
  smtp:execute("NOOP")
  local noopResponse = smtp:getResponse()
  assert_match("^250 OK", noopResponse, "NOOP command response incorrect")
end