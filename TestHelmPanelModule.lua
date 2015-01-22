-----------------------------------------------------------------------------------------------
-- VMS Helm Panel test module
-----------------------------------------------------------------------------------------------
-- @module TestHelmPanelModule
-----------------------------------------------------------------------------------------------

module("TestHelmPanelModule", package.seeall)
DEBUG_MODE = 1

-----------------------------------------------------------------------------------------------
-- SETUP
-----------------------------------------------------------------------------------------------
function suite_setup()
  -- reset of properties 
  systemSW:resetProperties({vmsSW.sin})

  -- debounce
  vmsSW:setPropertiesByName({
    PropertyChangeDebounceTime=1,
    HelmPanelDisconnectedStartDebounceTime=1,
    HelmPanelDisconnectedEndDebounceTime=1
  })

end

-- executed after each test suite
function suite_teardown()
end

--- setup function
function setup()
  vmsSW:setHighWaterMark()
end

--- teardown function executed after each unit test
function teardown()
  
end
-----------------------------------------------------------------------------------------------
-- Test Cases 
-----------------------------------------------------------------------------------------------

function test_HelmPanelConnected_X()

  local properties = vmsSW:getPropertiesByName({"HelmPanelDisconnectedState"})

  local isDisconnected = properties.HelmPanelDisconnectedState

  local change = "true"

  if isDisconnected then
    change = "false"
  end

  D:log("Helm")
  D:log(properties)

  shellSW:postEvent(
    uniboxSW.handleName, 
    uniboxSW.events.connected, 
    change
  )

end
