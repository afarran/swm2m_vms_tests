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
end

-- executed after each test suite
function suite_teardown()

end

--- setup function
function setup()
  vmsSW:setPropertiesByName({
      MailSessionIdleTimeout = 1,
      GpsInEmails = true,
      AllowedEmailDomains = "",
    })
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
  vmsSW:setPropertiesByName({
      AllowedEmailDomains = ""})
end

-------------------------
-- Test Cases
-------------------------

function test_SMTP_WhenSMTPCommandCalled_ServerReturnsSMTPServiceReady()
  if not smtp:ready() then
    skip("Smtp is not ready - serial port not opened (".. serialMain.name .. ")")
  end
  assert_true(smtp:ready(), "Smtp is not ready - serial port not opened")
  smtp:start()
  SMTPclear[1] = "QUIT"
  local startResponse = smtp:getResponse()
  assert_not_nil(startResponse, "SMTP module did not return start message")
  assert_match("^220.*\r\n", startResponse, "SMTP start message is incorrect")

end

local function startSmtp()
  if not smtp:ready() then
    skip("Smtp is not ready - serial port not opened (".. serialMain.name .. ")")
  end
  assert_true(smtp:ready(), "Smtp is not ready - serial port not opened")
  smtp:start()
  SMTPclear[1] = "QUIT"
  local startResponse = smtp:getResponse()
  assert_not_nil(startResponse, "SMTP module did not return start message")
  assert_match("^220.*\r\n", startResponse, "SMTP start message is incorrect")
end

--- Test SMTP Hello command
--Servers MUST NOT return the extended EHLO-style response to a HELO command.
function test_SMTP_WhenHELOCommandCalled_ServerReturns250()
  startSmtp()
  smtp:execute("HELO")
  local heloResponse = smtp:getResponse()
  heloResponse = string.split(heloResponse, "\r\n") -- split also removes \r\n
  assert_match("^250.*", heloResponse[1], "HELO command response incorrect")
  assert_nil(heloResponse[2], "HELO command responded with additional infromation")
end

function test_SMTP_WhenHELOWithParameterCommandCalled_ServerReturns250()
  startSmtp()
  smtp:execute("HELO skywave.com")
  local heloResponse = smtp:getResponse()
  heloResponse = string.split(heloResponse, "\r\n")
  assert_match("^250.*", heloResponse[1], "HELO command response incorrect")
  assert_nil(heloResponse[2], "HELO command responded with additional infromation")
end

--- Test EHLO command
function test_SMTP_WhenEHLOCommandCalled_ServerReturns250and250forSize()
  startSmtp()
  smtp:execute("EHLO")
  local ehloResponse = smtp:getResponse()
  ehloResponse = string.split(ehloResponse, "\r\n")
  assert_match("^250.*", ehloResponse[1], "EHLO command response incorrect - does not contain HELO msg")
  assert_match("^250 SIZE (%d+).*$", ehloResponse[2], "EHLO command response incorrect - does not contain SIZE")
end

function test_SMTP_WhenEHLOWithParameterCommandCalled_ServerReturns250and250forSize()
  startSmtp()
  smtp:execute("EHLO skywave.com")
  local ehloResponse = smtp:getResponse()
  ehloResponse = string.split(ehloResponse, "\r\n")
  assert_match("^250.*", ehloResponse[1], "EHLO command response incorrect - does not contain HELO msg")
  assert_match("^250 SIZE (%d+).*", ehloResponse[2], "EHLO command response incorrect - does not contain SIZE")
end


function test_SMTP_WhenQUITCommandCalled_ServerReturns221()
  startSmtp()
  smtp:execute("QUIT")
  SMTPclear = {}
  local quitResponse = smtp:getResponse()
  assert_match("^221.*\r\n", quitResponse, "QUIT command response incorrect")
end



function test_SMTP_WhenNOOPCommandCalled_ServerReturns250()
  startSmtp()
  smtp:execute("NOOP")
  local noopResponse = smtp:getResponse()
  assert_match("^250.*\r\n", noopResponse, "NOOP command response incorrect")
end

function test_SMTP_WhenRSETCommandCalled_ServerReturns250()
  startSmtp()
  smtp:execute("RSET")
  local rsetResponse = smtp:getResponse()
  assert_match("^250.*\r\n", rsetResponse, "RSET command response incorrect")
end

----
--- Test SMTP MAIL FROM
-- correct syntax for MAIL command is: "MAIL FROM:<reverse-path> [SP <mail-parameters> ] <CRLF>"
function test_SMTP_WhenMAILCorrectCommandCalled_ServerReturns250()
  startSmtp()
  smtp:execute("MAIL FROM: <test@skywave.com>")
  local mailResponse = smtp:getResponse()
  assert_match("^250.*\r\n", mailResponse, "MAIL FROM response incorrect")
end

  --If the mailbox specification is not acceptable for
  --some reason, the server MUST return a reply indicating whether the
  --failure is permanent (i.e., will occur again if the client tries to
  --send the same address again) or temporary (i.e., the address might be
  --accepted if the client tries again later).
function test_SMTP_WhenMAILCommandCalledWithBrokenReversePath_ServerReturns5xx()
  startSmtp()
  smtp:execute("MAIL FROM:test@skywave.com<>")
  local mailResponse = smtp:getResponse()
  assert_match("^5%d%d.*\r\n", mailResponse, "MAIL FROM response incorrect")
end

function test_SMTP_WhenMAILCommandCalledWithIncorrectEmail_ServerReturns5xx()
  startSmtp()
  smtp:execute("MAIL FROM:<test@skywave>")
  local mailResponse = smtp:getResponse()
  assert_match("^5%d%d.*\r\n", mailResponse, "MAIL FROM response incorrect")
end

function test_SMTP_WhenMAILCommandCalledWithEmptyMail_ServerReturns5xx()
  startSmtp()
  smtp:execute("MAIL FROM:")
  local mailResponse = smtp:getResponse()
  assert_match("^5%d%d.*\r\n", mailResponse, "MAIL FROM response incorrect")
end

  --The transaction
  --starts with a MAIL command that gives the sender identification.  (In
  --general, the MAIL command may be sent only when no mail transaction
  --is in progress;
function test_SMTP_WhenMAILCorrectCommandCalledTwice_ServerReturns5xx()
  startSmtp()
  smtp:execute("MAIL FROM:<skywave1@skywave.com>")
  local mailResponse = smtp:getResponse()
  assert_match("^250.*\r\n", mailResponse, "MAIL FROM response incorrect")

  smtp:execute("MAIL FROM:<skywave1@skywave.com>")
  mailResponse = smtp:getResponse()
  assert_match("^5%d%d.*\r\n", mailResponse, "MAIL FROM second response incorrect")
end

--Since it has been a common source of errors, it is worth noting that
--   spaces are not permitted on either side of the colon following FROM
--   in the MAIL command or TO in the RCPT command.

function test_SMTP_WhenMAILWithSpaceBeforeColonCalled_ServerReturns550()
  startSmtp()
  smtp:execute("HELO")
  local response = smtp:getResponse()
  smtp:execute("MAIL FROM :<skywave1@skywave.com>")
  response = smtp:getResponse()
  assert_match("^550.*\r\n", response, "MAIL FROM :<path> response incorrect")

end

function test_SMTP_WhenMAILWithSpaceAfterColonCalled_ServerReturns550()
  startSmtp()
  smtp:execute("HELO")
  local response = smtp:getResponse()
  smtp:execute("MAIL FROM: <skywave1@skywave.com>")
  response = smtp:getResponse()
  assert_match("^550.*\r\n", response, "MAIL FROM: <path> response incorrect")

end

function test_SMTP_WhenMAILWithSpaceBeforeAndAfterColonCalled_ServerReturns550()
  startSmtp()
  smtp:execute("HELO")
  local response = smtp:getResponse()
  smtp:execute("MAIL FROM : <skywave1@skywave.com>")
  response = smtp:getResponse()
  assert_match("^550.*\r\n", response, "MAIL FROM : <path> response incorrect")

end

--- Test SMTP RECPT TO
-- RCPT TO:<forward-path> [ SP <rcpt-parameters> ] <CRLF>
--The first or only argument to this command includes a forward-path
--(normally a mailbox and domain, always surrounded by "<" and ">"
--brackets) identifying one recipient.  If accepted, the SMTP server
--returns a "250 OK" reply and stores the forward-path.

function test_SMTP_WhenRCPTCorrectCommandCalled_ServerReturns250()
  startSmtp()
  smtp:execute("HELO")
  local response = smtp:getResponse()
  smtp:execute("MAIL FROM:<skywave@skywave.com>")
  response = smtp:getResponse()
  smtp:execute("RCPT TO:<receiver@skywave.com>")
  response = smtp:getResponse()
  assert_match("^250.*\r\n", response, "RCPT TO response incorrect")

end

function test_SMTP_WhenRCPTCorrectCommandCalledMultipleTimes_ServerReturns250()
  startSmtp()
  smtp:execute("HELO")
  response = smtp:getResponse()
  smtp:execute("MAIL FROM:<skywave@skywave.com>")
  local response = smtp:getResponse()
  for index=1, 10 do
    smtp:execute("RCPT TO:<receiver"..index.."@skywave.com>")
    response = smtp:getResponse()
    assert_match("^250.*\r\n", response, "RCPT TO response incorrect for " .. index .. " receipment")
  end
end

function test_SMTP_WhenRCPTCommandCalledTooManyTimes_ServerReturns552()
  startSmtp()
  smtp:execute("HELO")
  response = smtp:getResponse()
  smtp:execute("MAIL FROM:<skywave@skywave.com>")
  local full_response = ""
  local response = smtp:getResponse()
  local match
  for index=1,2000 do
    smtp:execute("RCPT TO:<receiver"..index.."@skywave.com>")
    response = smtp:getResponse(nil, 0.025)
    match = string.match(response, "^452.*\r\n")
    if match then break end
  end
  assert_match("^452.*\r\n", match, "RCPT TO did not return 452 Too many recipients")
end


function test_SMTP_WhenRCPTWithMalformedForwardPathCalled_ServerReturns5xx()
  startSmtp()
  smtp:execute("HELO")
  response = smtp:getResponse()
  smtp:execute("RCPT TO:receiver-skywave")
  local response = smtp:getResponse()
  assert_match("^5%d%d.*\r\n", response, "RCPT TO response incorrect")

end

--If a RCPT command appears without a previous MAIL command, the server MUST
  -- return a 503 "Bad sequence of commands" response.
function test_SMTP_WhenRCPTCommandCalledBeforeMAILCommand_ServerReturns503()
  startSmtp()
  smtp:execute("HELO")
  local response = smtp:getResponse()
  smtp:execute("RCPT TO:<receiver@skywave.com>")
  response = smtp:getResponse()
  assert_match("^503.*\r\n", response, "RCPT should be refused if called before MAIL")

end

---DATA command tests
--DATA <CRLF>
--   If accepted, the SMTP server returns a 354 Intermediate reply and
--   considers all succeeding lines up to but not including the end of
--   mail data indicator to be the message text.  When the end of text is
--   successfully received and stored, the SMTP-receiver sends a "250 OK"
--   reply.
function test_SMTP_WhenDATACorrectCommandCalled_ServerReturns354()
  startSmtp()
  smtp:execute("HELO")
  local response = smtp:getResponse()
  smtp:execute("MAIL FROM:<skywave@skywave.com>")
  response = smtp:getResponse()
  smtp:execute("RCPT TO:<receiver@skywave.com>")
  response = smtp:getResponse()
  smtp:execute("DATA")
  response = smtp:getResponse()
  assert_match("^354.*\r\n", response, "DATA command response is incorrect")
  SMTPclear[1] = "\r\n.\r\n"
  SMTPclear[2] = "QUIT"
end

function test_SMTP_WhenDATACommandCalledDataPassedWithEndChar_ServerReturns250()
  startSmtp()
  smtp:execute("HELO")
  local response = smtp:getResponse()
  smtp:execute("MAIL FROM:<skywave@skywave.com>")
  response = smtp:getResponse()
  smtp:execute("RCPT TO:<receiver@skywave.com>")
  response = smtp:getResponse()
  smtp:execute("DATA")
  response = smtp:getResponse()
  assert_match("^354.*\r\n", response, "DATA command response is incorrect")

  smtp:execute("Some message data")
  smtp:execute("More message data")

  smtp:execute("\r\n.", "\r\n")
  response = smtp:getResponse()
  assert_match("^250.*\r\n", response, "DATA command end response is incorrect")
end



--If there was no MAIL, or no RCPT, command, or all such commands were
--   rejected, the server MAY return a "command out of sequence" (503) or
--   "no valid recipients" (554) reply in response to the DATA command.
function test_SMTP_WhenDATACommandCalledBeforeMAILCommand_ServerReturns5xx()
  startSmtp()
  smtp:execute("HELO")
  local response = smtp:getResponse()
  smtp:execute("DATA")
  response = smtp:getResponse()
  SMTPclear[1] = "\r\n.\r\n"
  SMTPclear[2] = "QUIT"
  assert_match("^5%d%d.*\r\n", response, "DATA command response is incorrect")

end

function test_SMTP_WhenDATACommandCalledBeforeRCPTCommand_ServerReturns5xx()
  startSmtp()
  smtp:execute("HELO")
  local response = smtp:getResponse()
  smtp:execute("MAIL FROM:<skywave@skywave.com>")
  response = smtp:getResponse()
  smtp:execute("DATA")
  response = smtp:getResponse()
  SMTPclear[1] = "\r\n.\r\n"
  SMTPclear[2] = "QUIT"
  assert_match("^5%d%d.*\r\n", response, "DATA command response is incorrect")

end


------------------------------------------------------------------------------------
--Several commands (RSET, DATA, QUIT) are specified as not permitting
--   parameters.  In the absence of specific extensions offered by the
--   server and accepted by the client, clients MUST NOT send such
--   parameters and servers SHOULD reject commands containing them as
--   having invalid syntax.
--   future extensions, commands that are specified in this document as
--   not accepting arguments (DATA, RSET, QUIT) SHOULD return a 501
--   message if arguments are supplied in the absence of EHLO-
--   advertised extensions.

function test_SMTP_WhenRSETWithParameterCalled_ServerReturns501()
  startSmtp()
  smtp:execute("RSET someparam")
  local mailResponse = smtp:getResponse()
  assert_match("^501.*\r\n", mailResponse, "RSET with parameter response incorrect")
end

function test_SMTP_WhenQUITWithParameterCalled_ServerReturns501()
  startSmtp()
  smtp:execute("QUIT someparam")
  local mailResponse = smtp:getResponse()
  assert_match("^501.*\r\n", mailResponse, "QUIT with parameter response incorrect")
end

function test_SMTP_WhenDATAWithParameterCalled_ServerReturns501()
  startSmtp()
  smtp:execute("DATA someparam")
  SMTPclear[1] = "\r\n.\r\n"
  SMTPclear[2] = "QUIT"
  local mailResponse = smtp:getResponse()
  assert_match("^501", mailResponse, "DATA with parameter response incorrect")
end

function test_SMTP_WhenIDLETimeoutExceeded_ServerReturns421()
  local timeout = 1
  vmsSW:setPropertiesByName({MailSessionIdleTimeout = timeout})
  startSmtp()
  local response, waitTime = smtp:getResponse(timeout*60 + 5)

  assert_match("^421.*\r\n", response, "Timeout message incorrect")
  SMTPclear = {}
  assert_equal(timeout*60, waitTime, 5, "Timeout value incorrect")
end

function test_SMTP_WhenIDLETimeout2MinsExceeded_ServerReturns421()
  local timeout = 2
  vmsSW:setPropertiesByName({MailSessionIdleTimeout = timeout})
  startSmtp()
  local response, waitTime = smtp:getResponse(timeout*60 + 5)

  assert_match("^421.*\r\n", response, "Timeout message incorrect")
  SMTPclear = {}
  assert_equal(timeout*60, waitTime, 5, "Timeout value incorrect")
end

function test_SMTP_WhenIDLETimeoutExceededInDATAMode_ServerReturns421()
  local timeout = 1
  vmsSW:setPropertiesByName({MailSessionIdleTimeout = timeout})
  startSmtp()
  smtp:execute("HELO")
  response = smtp:getResponse()
  smtp:execute("MAIL FROM:<skywave@skywave.com>")
  response = smtp:getResponse()
  smtp:execute("RCPT TO:<receiver@skywave.com>")
  response = smtp:getResponse()
  smtp:execute("DATA")
  response = smtp:getResponse()
  SMTPclear[1] = "\r\n.\r\n"
  SMTPclear[2] = "QUIT"

  local response, waitTime = smtp:getResponse(timeout*60 + 5)

  assert_match("^421.*\r\n", response, "Timeout message incorrect")
  SMTPclear = {}
  assert_equal(timeout*60, waitTime, 5, "Timeout value incorrect")
end

function test_SMTP_WhenIDLETimeoutExceededAfterCommands_ServerReturns421()
  local timeout = 1
  vmsSW:setPropertiesByName({MailSessionIdleTimeout = timeout})

  startSmtp()
  smtp:execute("HELO")
  response = smtp:getResponse()
  smtp:execute("MAIL FROM:<skywave@skywave.com>")
  response = smtp:getResponse()
  framework.delay(timeout*60/2)
  smtp:execute("RCPT TO:<receiver@skywave.com>")
  response = smtp:getResponse()

  local response, waitTime = smtp:getResponse(timeout*60 + 5)

  assert_match("^421.*\r\n", response, "Timeout message incorrect")
  SMTPclear = {}
  assert_equal(timeout*60, waitTime, 5, "Timeout value incorrect")
end


function test_SMTP_WhenWrongCommandIsExecutedMultipleTimes_ServerRetursOnlyOne500response()

  startSmtp()
  smtp:execute("", "\r\n")
  local  response = smtp:getResponse()
  D:log(response)
  smtp:execute("", "\r\n")
  response = smtp:getResponse()
  D:log(response)
  smtp:execute("", "\r\n")
  response = smtp:getResponse()
  D:log(response)
  local spittedResponse = string.split(response,"\r\n")
  D:log(spittedResponse)
  assert_equal(1, #spittedResponse, 0,"There is an incorrect response in when wrong command is executed multiple times - too many 500 responses")

end


function test_SMTP_WhenTextEndedWithCRInsteadOfCRLFAreIsSent_TextIsNotTreatedAsCommand()

  startSmtp()
  smtp:execute("HELO", "\r")
  local  response = smtp:getResponse()
  D:log(response)
  assert_nil(response, "Text ended with only CR (not CRLF) was executed as a command")

end

function test_SMTP_WhenTextIsSentWithoutCRLF_421ConnectionTimeoutIsSentAfterTimeout()
  local timeout = 1
  vmsSW:setPropertiesByName({MailSessionIdleTimeout = timeout})
  startSmtp()
  smtp:execute("HELO", "")
  local response = smtp:getResponse(65)
  D:log(response)
  assert_match("^421.*\r\n", response, "A command not ended with CRLF was executed after timeout instead of 421 Connection timeout message sent in response")

end

function test_SMTP_WhenCorrectMailToigwsatkywavecomIsSent_ServerReturns250AndEmailMessageIsSent()
  local gpsFix = GPS:getRandom()
  GPS:set(gpsFix)
  vmsSW:setHighWaterMark()
  
  SMTPclear[1] = "QUIT"
  
  local mailInfo = {
    from = "sii@skywave.com", 
    to = {"sii@pl.sii.eu", "igws@skywave.com"}, 
    subject = "some subject", 
    data = "some data"
  }
  smtp:sendMail(mailInfo)
  SMTPclear = {}
  local emailMessage = vmsSW:waitForMessagesByName("Email")["Email"]
  assert_not_nil(emailMessage, "Email message not received")
  
  emailMessage:_verify({
    Timestamp =      {assert_not_nil},
    Latitude =        {assert_equal, GPS:degrees2MiliMinutes(gpsFix.latitude), 1},
    Longitude =   {assert_equal, GPS:degrees2MiliMinutes(gpsFix.longitude), 1},
    From = mailInfo.from,
    Subject =  mailInfo.subject,
    Recipients = {assert_not_nil},
    Data = mailInfo.data .. "\r\n",
  })
end

function test_SMTP_WhenCorrectMailToUserDifferentThanigwsatkywavecomIsSent_ServerReturns250AndEmailMessageIsNotSent()
  local gpsFix = GPS:getRandom()
  GPS:set(gpsFix)
  vmsSW:setHighWaterMark()
  
  SMTPclear[1] = "QUIT"
  
  local mailInfo = {
    from = "sii@skywave.com", 
    to = {"sii@pl.sii.eu", "somemail@skywave.com"}, 
    subject = "some subject", 
    data = "some data"
  }
  smtp:sendMail(mailInfo)
  SMTPclear = {}
  local emailMessage = vmsSW:waitForMessagesByName("Email", 15)["Email"]
  assert_nil(emailMessage, "Email message received")
  
end
-- TODO: Test if HELO command issued - session should be reset (HELO/EHLO invokes RSET) - not possible to test in current implementation
-- TODO: Test if RSET properly resets session information - not possible to test in current implementation
