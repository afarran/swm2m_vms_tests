-----------
--  test Main module
--- contains VMS general features
-- @module TestMainModule

module("TestMainModule", package.seeall)
local tearDownSteps = {
    steps = {},
  }
  
tearDownSteps.add = function(step) table.insert(tearDownSteps.steps, step) end

function suite_setup()

end


function suite_teardown()

end

--- setup function
function setup()
  gateway.setHighWaterMark()
end

-----------------------------------------------------------------------------------------------
--- teardown function executed after each unit test
function teardown()
  for idx, step in pairs(tearDownSteps.steps) do
    step()
  end
  
end

----------------------------------------------------------------------
-- Test Building Blocks
----------------------------------------------------------------------

--- Function breaks VMS service.
-- It renames mail.lua file to mail2.lua to invoke critical error on startup
local function spoilService()
  local path = vmsSW:getServicePath() 
  local inFile = "mail.lua"
  local outFile = "mail2.lua"
  
  local result = shellSW:renameFile(path .. inFile, outFile)
  tearDownSteps.add(function()
      shellSW:renameFile(path .. outFile, inFile)
  end)
  
  
end

-------------------------
-- Test Cases
-------------------------
--- Tests if VMS disables itself when cricital error occurs
-- 1. spoil VMS by messing in source code
-- 2. Restart framework
-- 3. Check if service was disabled
function test_MainModule_WhenCriticalErrorOnVmsStartup_VmsServiceIsDisabled()
  spoilService()
  systemSW:restartFramework(true)
  
  tearDownSteps.add(
    function()
      systemSW:enableService(vmsSW)
      systemSW:restartFramework(true)
      local vmsInfo = systemSW:getServiceInfo(vmsSW)
      assert_equal(vmsInfo.enabled, "True", "Service disabled")
      assert_equal(vmsInfo.running, "True", "Service not running")
    end
  )
  
  local vmsInfo = systemSW:getServiceInfo(vmsSW)
  assert_equal(vmsInfo.enabled, "False", "Service running, but critical error should disable it.")  
  
end