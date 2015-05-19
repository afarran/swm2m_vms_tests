-----------
-- Vms shell test module
-- - contains VMS features dependant on vms shell
-- @module TestShellModule

require "UtilLibs/Text"
require "Serial/RsShellWrapper"

local shell = RsShellWrapper(serialMain)
shell:setTimeout(5)

module("TestShellModule", package.seeall)

function suite_setup()

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

function test_XXX()

end

local function startShell()
  if not shell:ready() then
    skip("Shell is not ready - serial port not opened (".. serialMain.name .. ")")
  end
  assert_true(shell:ready(), "Shell is not ready - serial port not opened")
  shell:start()
end

