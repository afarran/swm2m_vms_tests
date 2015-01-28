----------- 
-- Smtp test module
-- - contains VMS features dependant on Smpt
-- @module TestSmtpModule

require "UtilLibs/Text"
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
  assert_match("^220", startResponse, "SMTP start message is incorrect")
  
end

local function startSmtp()
  assert_true(smtp:ready(), "Smtp is not ready - serial port not opened")
  smtp:start()
  SMTPclear[1] = "QUIT"
  local startResponse = smtp:getResponse()
  assert_not_nil(startResponse, "SMTP module did not return start message")
end

function test_SMTP_WhenHELOCommandCalled_ServerReturns250()
  startSmtp()  
  smtp:execute("HELO")
  local heloResponse = smtp:getResponse()
  assert_match("^250", heloResponse, "HELO command response incorrect")
end

function test_SMTP_WhenQUITCommandCalled_ServerReturns221()
  startSmtp()
  smtp:execute("QUIT")
  SMTPclear = {}
  local quitResponse = smtp:getResponse()
  assert_match("^221", quitResponse, "QUIT command response incorrect")  
end

function test_SMTP_WhenEHLOCommandCalled_ServerReturns250and250forSize()
  startSmtp()
  smtp:execute("EHLO")
  local ehloResponse = smtp:getResponse()
  ehloResponse = string.split(ehloResponse, "\r\n")
  assert_match("^250", ehloResponse[1], "EHLO command response incorrect - does not contain HELO msg")
  assert_match("^250 SIZE (%d+)$", ehloResponse[2], "EHLO command response incorrect - does not contain SIZE")
end

function test_SMTP_WhenNOOPCommandCalled_ServerReturns250()
  startSmtp()
  smtp:execute("NOOP")
  local noopResponse = smtp:getResponse()
  assert_match("^250", noopResponse, "NOOP command response incorrect")
end

function test_SMTP_WhenRSETCommandCalled_ServerReturns250()
  startSmtp()
  smtp:execute("RSET")
  local rsetResponse = smtp:getResponse()
  assert_match("^250", rsetResponse, "RSET command response incorrect")
end

--- Test SMTP MAIL FROM
-- correct syntax for MAIL command is: "MAIL FROM:<reverse-path> [SP <mail-parameters> ] <CRLF>"
function test_SMTP_WhenCorrectMAILFROMCommandCalled_ServerReturns250()
  startSmtp()
  smtp:execute("MAIL FROM: <test@skywave.com>")
  local mailResponse = smtp:getResponse()
  assert_match("^250", mailResponse, "MAIL FROM response incorrect")
end

function test_SMTP_WhenMAILFROMCommandCalledWithBrokenReversePath_ServerReturns5xx()
  startSmtp()
  smtp:execute("MAIL FROM:test@skywave.com<>")
  local mailResponse = smtp:getResponse()
  assert_match("^5%d%d", mailResponse, "MAIL FROM response incorrect")
end

function test_SMTP_WhenMAILFROMCommandCalledWithIncorrectEmail_ServerReturns5xx()
  startSmtp()
  smtp:execute("MAIL FROM:<test@skywave>")
  local mailResponse = smtp:getResponse()
  assert_match("^5%d%d", mailResponse, "MAIL FROM response incorrect")
end
