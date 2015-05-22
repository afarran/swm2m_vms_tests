-------------------------
-- Pop3 test module
-- contains VMS features dependant on pop3
-- @module TestPop3Module
-------------------------

module("TestPop3Module", package.seeall)

require "UtilLibs/Text"
require "Email/Pop3Wrapper"
require "Email/SmtpWrapper"

-------------------------
-- SETUP
-------------------------

-- setup for wrappers verbosity
local SILENT = true

-- setup for waiting after message is sent via smtp, sometimes it needs time
local TRIES_AFTER_SENDING_EMAIL = 10 -- how many tries should be performed
local WAIT_FOR_MESSAGE_DELAY = 60    -- how many seconds of the delay after each try

-- user setup
local DOMAIN = "isadatapro.skywave.com"
local USER = "<terminal_id>@"..DOMAIN -- it will be filled in suite setup
local PASSWD = "abcd123"

-------------------------
-- SETUP
-------------------------

-- pop session wrapper
local pop3 = Pop3Wrapper(serialMain,SILENT)
pop3:setTimeout(5)

-- smtp session wrapper
local smtp = SmtpWrapper(serialMain,SILENT)
smtp:setTimeout(5)


-------------------------
-- LOGIC
-------------------------

-- pop3 session state
local logged = false;
-- gps position in emails
local gpsInEmails = false

local function login()
  pop3:start()
  D:log("Login to POP3 server")
  local result = pop3:request("USER "..USER)
  assert_not_nil(string.find(result,"+OK"),"POP3 USER command failed ")
  D:log("Correct user name")
  local result = pop3:request("PASS "..PASSWD)
  assert_not_nil(string.find(result,"+OK%s*password%s*accepted"),"POP3 PASS command failed")
  D:log("Correct password")
  logged = true
end

local function quit()
  D:log("Exiting session")
  local result = pop3:request("QUIT")
  assert_not_nil(string.find(result,"+OK"),"POP3 QUIT command failed")
  logged = false
end

local function getMessagesNo()
  local result = pop3:request("LIST")
  assert_not_nil(string.find(result,"+OK%s*%d*%s*messages"),"POP3 LIST command failed")
  local no = tonumber(string.match(result,"+OK%s*(%d*)%s*messages"))
  assert_not_nil(no, "Wrong messages number.")
  return no
end

-------------------------
-- SETUP/TEARDOWN
-------------------------
function suite_setup()

  -- needs some time to start shell
  framework.delay(25)

  -- gps in emails randomization
  if lunatest.random_int(0, 100) > 50 then
    gpsInEmails = true
  end

  vmsSW:setPropertiesByName({
      MailSessionIdleTimeout = 20,
      GpsInEmails = true,
      AllowedEmailDomains = " ",
    })

  local mobileId = idpSW:getPropertiesByName({'mobileID'})
  USER = mobileId['mobileID'].."@"..DOMAIN
  D:log("Using user: "..USER)

end

-- executed after each test suite
function suite_teardown()
end

--- setup function
function setup()
end

function teardown()
  -- force quit
  if logged then
    quit()
  end
end

-------------------------
-- Test Cases
-------------------------

--- TC checks commands: USER, PASS, QUIT for authorization.
  -- 
  -- Initial conditions:
  -- 
  -- * pop3 shell session is established
  --
  -- Steps:
  --
  -- 1. 'USER <username>' request is sent.
  -- 2. 'PASS passwd' request is sent.
  -- 3. 'QUIT' request is sent.
  --
  -- Results:
  --
  -- 1. '+OK' status is received.
  -- 2. '+OK password accepted' status is received.
  -- 3. '+OK' status is received.
function test_Login_WhenUserNameAndPasswordIsSent_CorrectServerResponseIsReceived()
  
  -- starting pop3 shell
  pop3:start()

  -- login
  D:log("Login to POP3 server")
  local result = pop3:request("USER "..USER)
  assert_not_nil(string.find(result,"+OK"),"POP3 USER command failed ")
  D:log("Correct user name")
  local result = pop3:request("PASS "..PASSWD)
  assert_not_nil(string.find(result,"+OK%s*password%s*accepted"),"POP3 PASS command failed")
  D:log("Correct password")

  -- exit
  D:log("Exiting session")
  local result = pop3:request("QUIT")
  assert_not_nil(string.find(result,"+OK"),"POP3 QUIT command failed")
end

--- TC checks commands: LIST for fetching messages count.
  -- 
  -- Initial conditions:
  -- 
  -- * pop3 shell session is established
  -- * authorization is performed
  --
  -- Steps:
  --
  -- 1. 'LIST' request is sent.
  --
  -- Results:
  --
  -- 1. '+OK x messages' status is received.
function test_List_WhenListRequested_CorrectServerResponseIsReceived()
 
  -- login 
  login()

  -- request LIST
  local result = pop3:request("LIST")
  assert_not_nil(string.find(result,"+OK%s*%d*%s*messages"),"POP3 LIST command failed")

  -- quit
  quit()
end

--- TC checks commands: LIST, RETR, TOP, DELE, RETR, QUIT for receiving and deleting email message. 
  -- 
  -- Initial conditions:
  -- 
  -- * pop3 shell session is established
  -- * authorization is performed
  --
  -- Steps:
  --
  -- 1. Initial messages count is requested (LIST).
  -- 2. E-mail messages is sent via smtp.
  -- 3. Checking inbox is perfomed in a loop.
  -- 4. Messages count is checked.
  -- 5. Message is retrieved (RETR).
  -- 6. gpsInEmails is checked (if exists or not,randomly)
  -- 7. 'TOP' command is sent.
  -- 8. 'DELE' command is sent.
  -- 9. 'RSET' command is sent.
  -- 10. Messages count is checked.
  -- 11. 'DELE' command is sent.
  -- 12. 'QUIT' command is sent.
  -- 13. Messages count is checked.
  --
  -- Results:
  --
  -- 1. Initial messages count is fetched.
  -- 2. E-mail is corretly sent.
  -- 3. Messages count is received.
  -- 4. Messages count is correct.
  -- 5. '+OK' status is received.
  -- 6. gpsInEmails result is correct.
  -- 7. '+OK' status is received.
  -- 8. '+OK' status is received (means deleted flag is set).
  -- 9. '+OK' status is received (means deleted flag is unset).
  -- 10. Messages count is correct.
  -- 11. '+OK' status is received (means deleted flag is set).
  -- 12. Message is finaly deleted.
  -- 13. Messages count is correct.
function test_Retrive_WhenMailIsSentViaSmtp_ItIsPossibleToRetriveItViaPop3()
 
  -- login pop3 session
  login()
 
  -- checking messages number before sending email
  local messagesNoBefore = getMessagesNo()
  D:log("Messages no before sendin email: "..messagesNoBefore)

  -- quit pop3 session
  quit()

  -- sending test message
  D:log("Sending test email message")
  pop3:request("quit")
  smtp:sendMail({
    from = "pblo@pblo.com",
    to = {USER},
    subject = "Test subject",
    data = "Test content"
  })

  -- waiting for test message (it can take several minutes)
  local tries = TRIES_AFTER_SENDING_EMAIL
  local messagesNo = 0 
  while tries > 0 do
    login()
    local messagesNo = getMessagesNo()
    quit()
    if messagesNo - messagesNoBefore == 1 then
      break
    end
    framework.delay(WAIT_FOR_MESSAGE_DELAY)
    tries = tries - 1
  end

  -- checking messages number
  D:log("Messages no: "..messagesNo)
  assert_not_nil(messagesNo, "Wrong messages number.")
  assert_gt(0,tonumber(messagesNo), "Wrong messages number.")
  assert_equal(1,tonumber(messagesNo) - tonumber(messagesNoBefore),"Wrong messages diff.")

  login()

  -- retrieve message
  D:log("Retrive message no "..messagesNo)
  local result = pop3:request("RETR "..messagesNo)
  assert_not_nil(string.find(result,"+OK"),"Cannot retrieve message")

  -- checking gpsInEmails
  local pattern = ".*Pos:[^,]*,[^,]*,.*"
  if gpsInEmails then
    D:log("Checking gps position in email content. It should exists.")
    assert_not_nil(string.find(result,pattern,1,false),"There is no gps position in email")
  else
    D:log("Checking gps position in email content. It should not exists.")
    assert_nil(string.find(result,pattern,1,false),"There should not be gps position in email")
  end

  -- top message
  D:log("top message no "..messagesNo)
  local result = pop3:request("TOP "..messagesNo.." 1")
  assert_not_nil(string.find(result,"+OK"),"Cannot top message")

  -- uidl message
  -- QUESTION: is UIDL command implemented?
  -- D:log("uidl message no "..messagesNo)
  -- local result = pop3:request("UIDL "..messagesNo.." 1")
  -- assert_not_nil(string.find(result,"+OK"),"Cannot UIDL message")

  -- delete message
  D:log("Delete message no "..messagesNo)
  local result = pop3:request("DELE "..messagesNo)
  assert_not_nil(string.find(result,"+OK"),"Cannot delete message")

  -- rset message
  D:log("Rset message no "..messagesNo)
  local result = pop3:request("RSET "..messagesNo)
  assert_not_nil(string.find(result,"+OK"),"Cannot rset message")

  quit() -- that should not delete message

  -- checking messages count after rset message
  login()
  local messagesNoFinal = getMessagesNo()
  assert_equal(messagesNoBefore+1,messagesNoFinal,"Wrong messages number after deleting message")

  -- delete message again
  D:log("Delete message no "..messagesNo)
  local result = pop3:request("DELE "..messagesNo)
  assert_not_nil(string.find(result,"+OK"),"Cannot delete message")

  quit()  -- that should delete message

  -- checking messages count after deleting message
  login()
  local messagesNoFinal = getMessagesNo()
  assert_equal(messagesNoBefore,messagesNoFinal,"Wrong messages number after deleting message")
  quit()

end

--- TC checks commands: STAT.
  -- Initial conditions:
  -- 
  -- * pop3 shell session is established
  -- * authorization is performed
  --
  -- Steps:
  --
  -- 1. 'STAT' command is sent.
  --
  -- Results:
  --
  -- 1. Correct response is received.
function test_Stat_WhenStatCommandIsSent_CorrectResponseIsReceived()

  login()
  local result = pop3:request("STAT")
  assert_not_nil(string.find(result,"+OK%s*%s*%s*%d*"),"Wrong response to command: STAT")
  quit()
end

--- TC checks commands: NOOP.
  -- Initial conditions:
  -- 
  -- * pop3 shell session is established
  -- * authorization is performed
  --
  -- Steps:
  --
  -- 1. 'NOOP' command is sent.
  --
  -- Results:
  --
  -- 1. Correct response is received.
function test_Noop_WhenNoopCommnadIsSent_CorrectResponseIsReceived()
  login()
  local result = pop3:request("NOOP")
  assert_not_nil(string.find(result,"+OK"),"Wrong response to command: NOOP")
  quit()
end

--- TC checks commands: APOP (if implementation exists in vms pop3)
  -- Initial conditions:
  -- 
  -- * pop3 shell session is established
  -- * authorization is performed
  --
  -- Steps:
  --
  -- 1. 'APOP' command is sent.
  --
  -- Results:
  --
  -- 1. Correct is checked for syntax error (occurs when command does not exists)
function test_ApopImplemented_WhenApopCommnadIsSent_CorrectResponseIsReceived()
  login()
  local result = pop3:request("APOP fakeuser c4c9334bac560ecc979e58001b3e22fb")
  assert_nil(string.find(result,"syntax error"),"Command APOP not implemented")
  quit()
end

--- TC checks commands: RSET (if implementation exists in vms pop3)
  -- Initial conditions:
  -- 
  -- * pop3 shell session is established
  -- * authorization is performed
  --
  -- Steps:
  --
  -- 1. 'RSET' command is sent.
  --
  -- Results:
  --
  -- 1. Correct is checked for syntax error (occurs when command does not exists)
function test_RsetImplemented_WhenRsetCommnadIsSent_CorrectResponseIsReceived()
  login()
  local result = pop3:request("RSET")
  assert_nil(string.find(result,"syntax error"),"Command RSET not implemented")
  quit()
end

--- TC checks commands: UIDL (if implementation exists in vms pop3)
  -- Initial conditions:
  -- 
  -- * pop3 shell session is established
  -- * authorization is performed
  --
  -- Steps:
  --
  -- 1. 'UIDL' command is sent.
  --
  -- Results:
  --
  -- 1. Correct is checked for syntax error (occurs when command does not exists)
function test_UidlImplemented_WhenUidlCommnadIsSent_CorrectResponseIsReceived()
  login()
  local result = pop3:request("UIDL 1 1")
  assert_nil(string.find(result,"syntax error"),"Command UIDL not implemented")
  quit()
end
