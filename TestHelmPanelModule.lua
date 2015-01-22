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

function test_HelmPanelConnected_WhenHelmPanelDisconnectedStateIsInAGivenStateAndTheStateToggles_HelmPanelDisconnectedStateChangesCorrectly()

  local properties = vmsSW:getPropertiesByName({"HelmPanelDisconnectedState"})
  local isDisconnected = properties.HelmPanelDisconnectedState

  local change = ""
  if isDisconnected then
    change = "true"
  else
    change = "false"
  end

  shellSW:postEvent(
    uniboxSW.handleName, 
    uniboxSW.events.connected, 
    change
  )

  framework.delay(2)

  local propertiesAfterChange = vmsSW:getPropertiesByName({"HelmPanelDisconnectedState"})
  local isDisconnectedAfterChange = propertiesAfterChange.HelmPanelDisconnectedState
  assert_not_equal(isDisconnectedAfterChange, isDisconnected, "There should be change in disconnected state.")

  framework.delay(2)
    
  if isDisconnectedAfterChange then
    change = "true"
  else
    change = "false"
  end

  shellSW:postEvent(
    uniboxSW.handleName, 
    uniboxSW.events.connected, 
    change
  )

  framework.delay(2)

  local propertiesAfterSecondChange = vmsSW:getPropertiesByName({"HelmPanelDisconnectedState"})
  local isDisconnectedAfterSecondChange = propertiesAfterSecondChange.HelmPanelDisconnectedState
  assert_not_equal(isDisconnectedAfterChange, isDisconnectedAfterSecondChange, "There should be change in disconnected state.")

end

-- TODO: nothing happends after posting BUTTON_PRESSED event, not implemented yet or .. ?
function test_ButtonPressed()
  shellSW:postEvent(
    uniboxSW.handleName,
    uniboxSW.events.button_pressed,
    "true"
  )
end

-- TODO: nothing happends after posting SERVICE_ACTIVE event, not implemented yet or .. ?
function test_ServiceActive()
  shellSW:postEvent(
    uniboxSW.handleName,
    uniboxSW.events.service_active,
    "true"
  )
end
