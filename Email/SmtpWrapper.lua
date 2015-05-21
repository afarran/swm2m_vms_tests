cfg, framework, gateway, lsf, device, gps = require "TestFramework"()

require("Serial/ShellWrapper")

SmtpWrapper = {}
  SmtpWrapper.__index = SmtpWrapper
  setmetatable(SmtpWrapper, {
    __index = ShellWrapper, -- this is what makes the inheritance work
    __call = function(cls, ...)
      local self = setmetatable({}, cls)
      self:_init(...)
      return self
    end,})

  function SmtpWrapper:start()
    local response = self:request("")
    if not string.match(response, ".*mail>") then
      self:request("mail")
    end
    self:execute("smtp")
  end

  --- sends an email over SMTP rs232 session.
  -- TODO strip from lunatest assertions and add error handling
  -- @tparam table mailInfo
  -- @tparam string mailInfo.from sender 
  -- @tparam table mailInfo.to list of receipents
  -- @tparam string mailInfo.data data to send
  -- @tparam string mailInfo.subject mail subject
  -- @usage
  -- local mailInfo = {
  --    from = "skywave@skywave.com",
  --    to = {"s1@skywave.com", "s2@skywave.com"},
  --    subject = "some subject", 
  --    data = "some data",
  -- }  
  function SmtpWrapper:sendMail(mailInfo)
    if not self:ready() then
      D:log("Smtp is not ready - serial port not opened (".. self.port.name .. ")")
      return nil
    end
    
    mailInfo.data = mailInfo.data or ""
    mailInfo.subject = mailInfo.subject or ""
    self:start()
        
    local startResponse = self:getResponse()
    assert_not_nil(startResponse, "SMTP module did not return start message")
    assert_match("^220.*\r\n", startResponse, "SMTP start message is incorrect")
  
    self:request("HELO")
    self:request("MAIL FROM:<" .. mailInfo.from .. ">")
    
    for idx, recipient in pairs(mailInfo.to) do
      local response = self:request("RCPT TO:<" .. recipient.. ">")      
      assert_match("^250.*\r\n", response, "RCPT TO response incorrect for " .. recipient .. " recipient")
    end
    
    local response = self:request("DATA")
    assert_match("^354.*\r\n", response, "DATA command response is incorrect")

    self:execute("From: " .. mailInfo.from)
    self:execute("To: " .. self:_prepareBodyRecipients(mailInfo.to))
    self:execute("Subject: " .. mailInfo.subject)
    self:execute("") -- blank line delimits header
    self:execute("Some special message data")

    response = self:request("\r\n.", "\r\n")
    assert_match("^250.*\r\n", response, "DATA command end response is incorrect")
    self:request("QUIT")
  end
  
  function SmtpWrapper:_prepareBodyRecipients(recepientsTable)
    local result = ""
    for idx, recipient in pairs(recepientsTable) do
      result = result .. recipient .. ", "
    end
    return result
  end