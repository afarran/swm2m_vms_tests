
-------------------------
-- Pop3 test module
-- contains VMS features dependant on pop3
-- @module TestPop3Module
-------------------------

module("TestPop3Module", package.seeall)

require "UtilLibs/Text"
require "Email/Pop3Wrapper"

-------------------------
-- SETUP
-------------------------

-- setup for wrappers verbosity
local SILENT = true

-- setup for waiting after message is sent via smtp, sometimes it needs time
local TRIES_AFTER_SENDING_EMAIL = 10 -- how many tries should be performed
local WAIT_FOR_MESSAGE_DELAY = 60    -- how many second of the delay after each try

-- user setup
local DOMAIN = "isadatapro.skywave.com"
local USER = "<terminal_id>@"..DOMAIN
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
  --framework.delay(15)

  vmsSW:setPropertiesByName({
      MailSessionIdleTimeout = 20,
      GpsInEmails = true,
      AllowedEmailDomains = " ",
    })

  local terminalId = systemSW:getTerminalId()
  USER = terminalId.."@"..DOMAIN
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

function test_Login_GORUNWhenUserNameAndPasswordIsSent_CorrectServerResponseIsReceived()
  
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

function test_List_WhenListRequested_CorrectServerResponseIsReceived()
 
  -- login 
  login()

  -- request LIST
  local result = pop3:request("LIST")
  assert_not_nil(string.find(result,"+OK%s*%d*%s*messages"),"POP3 LIST command failed")

  -- quit
  quit()
end

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

  -- delete message
  D:log("Delete message no "..messagesNo)
  local result = pop3:request("DELE "..messagesNo)
  assert_not_nil(string.find(result,"+OK"),"Cannot delete message")

  quit()

  -- checking messages count after deleting message
  login()
  local messagesNoFinal = getMessagesNo()
  assert_equal(messagesNoBefore,messagesNoFinal,"Wrong messages number after deleting message")
  quit()

end

function test_Stat_WhenStatCommandIsSent_CorrectResponseIsReceived()

  login()
  local result = pop3:request("STAT")
  assert_not_nil(string.find(result,"+OK%s*%s*%s*%d*"),"Wrong response to command: STAT")
  quit()
end

