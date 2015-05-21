-----------
-- Pop3 test module
-- - contains VMS features dependant on Smpt
-- @module TestPop3Module

require "UtilLibs/Text"
require "Email/Pop3Wrapper"

local pop3 = Pop3Wrapper(serialMain)
pop3:setTimeout(5)

local smtp = SmtpWrapper(serialMain)
smtp:setTimeout(5)

module("TestPop3Module", package.seeall)

USER = "terminal_id@isadatapro.skywave.com"
PASSWD = "abcd123"

function suite_setup()

  -- needs some time to start shell
  --framework.delay(15)

  vmsSW:setPropertiesByName({
      MailSessionIdleTimeout = 1,
      GpsInEmails = true,
      AllowedEmailDomains = " ",
    })

  local terminalId = systemSW:getTerminalId()
  USER = terminalId.."@isadatapro.skywave.com"

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

function test_Login_WhenUserNameAndPasswordIsSent_CorrectServerResponseIsReceived()

  D:log("Login to POP3 server")
  local result = pop3:request("USER "..USER)
  assert_not_nil(string.find(result,"+OK"),"POP3 USER command failed ")
  D:log("Correct user name")

  local result = pop3:request("PASS "..PASSWD)
  assert_not_nil(string.find(result,"+OK%s*password%s*accepted"),"POP3 PASS command failed")
  D:log("Correct password")
end

function test_List_WhenListRequested_CorrectServerResponseIsReceived()
 
  -- login 
  D:log("Login to POP3 server")
  local result = pop3:request("USER "..USER)
  assert_not_nil(string.find(result,"+OK"),"POP3 USER command failed ")
  D:log("Correct user name")
  local result = pop3:request("PASS "..PASSWD)
  assert_not_nil(string.find(result,"+OK%s*password%s*accepted"),"POP3 PASS command failed")
  D:log("Correct password")

  -- request LIST
  local result = pop3:request("LIST")
  assert_not_nil(string.find(result,"+OK%s*%d*%s*messages"),"POP3 LIST command failed")

end

function test_GORUNRetrive_WhenMailIsSentViaSmtp_ItIsPossibleToRetriveItViaPop3()
  
  -- login 
  D:log("Login to POP3 server")
  local result = pop3:request("USER "..USER)
  assert_not_nil(string.find(result,"+OK"),"POP3 USER command failed ")
  D:log("Correct user name")
  local result = pop3:request("PASS "..PASSWD)
  assert_not_nil(string.find(result,"+OK%s*password%s*accepted"),"POP3 PASS command failed")
  D:log("Correct password")
  
  -- checking messages number before sending email
  local result = pop3:request("LIST")
  assert_not_nil(string.find(result,"+OK%s*%d*%s*messages"),"POP3 LIST command failed")
  local messagesNoBefore = string.match(result,"+OK%s*(%d*)%s*messages")
  assert_not_nil(messagesNoBefore, "Wrong messages number.")
  D:log("Messages no before sendin email: "..messagesNoBefore)

  D:log("Sending test email message")
  pop3:request("quit")
  --sendViaSmtp
  smtp:sendMail({
    from = "pblo@pblo.com",
    to = {USER},
    subject = "Test subject",
    data = "Test content"
  })
  D:log("Restoring pop3 session")
  pop3:start()

  -- login 
  D:log("Login to POP3 server")
  local result = pop3:request("USER "..USER)
  assert_not_nil(string.find(result,"+OK"),"POP3 USER command failed ")
  D:log("Correct user name")
  local result = pop3:request("PASS "..PASSWD)
  assert_not_nil(string.find(result,"+OK%s*password%s*accepted"),"POP3 PASS command failed")
  D:log("Correct password")

  -- request LIST
  local result = pop3:request("LIST")
  assert_not_nil(string.find(result,"+OK%s*%d*%s*messages"),"POP3 LIST command failed")

  local messagesNo = string.match(result,"+OK%s*(%d*)%s*messages")
  assert_not_nil(messagesNo, "Wrong messages number.")
  D:log("Messages no: "..messagesNo)
  assert_gt(0,tonumber(messagesNo), "Wrong messages number.")
  assert_equal(1,tonumber(messagesNo) - tonumber(messagesNoBefore),"Wrong messages diff.")
  -- BUG HERE: always 0 on the list
 
  -- retrieve message
  --TODO

end

function test_Stat_WhenStatCommandIsSent_CorrectResponseIsReceived()

  -- login 
  D:log("Login to POP3 server, user: "..USER)
  local result = pop3:request("USER "..USER)
  assert_not_nil(string.find(result,"+OK"),"POP3 USER command failed ")
  D:log("Correct user name")
  local result = pop3:request("PASS "..PASSWD)
  assert_not_nil(string.find(result,"+OK%s*password%s*accepted"),"POP3 PASS command failed")
  D:log("Correct password")

  local result = pop3:request("STAT")
  assert_not_nil(string.find(result,"+OK%s*%s*%s*%d*"),"Wrong response to command: STAT")
end