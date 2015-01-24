-----------------------------------------------------------------------------------------------
-- VMS Helm Panel test module
-----------------------------------------------------------------------------------------------
-- @module TestHelmPanelModule
-----------------------------------------------------------------------------------------------

module("TestHelmPanelModule", package.seeall)
DEBUG_MODE = 1

local SATELITE_BLOCKAGE_DEBOUNCE = 1
local SATELITE_BLOCKAGE_DEBOUNCE_TOLERANCE = 0
local GPS_BLOCKED_START_DEBOUNCE_TIME = 20
local GPS_BLOCKED_END_DEBOUNCE_TIME = 1 
local MAX_FIX_TIMEOUT = 60  

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
    HelmPanelDisconnectedEndDebounceTime=1,
    IdpBlockedStartDebounceTime = SATELITE_BLOCKAGE_DEBOUNCE ,
    IdpBlockedEndDebounceTime = SATELITE_BLOCKAGE_DEBOUNCE,
    GpsBlockedStartDebounceTime = GPS_BLOCKED_START_DEBOUNCE_TIME,
    GpsBlockedEndDebounceTime = GPS_BLOCKED_END_DEBOUNCE_TIME
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

  helmPanel:setConnected(change) 

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

  helmPanel:setConnected(change)
 
  framework.delay(2)

  local propertiesAfterSecondChange = vmsSW:getPropertiesByName({"HelmPanelDisconnectedState"})
  local isDisconnectedAfterSecondChange = propertiesAfterSecondChange.HelmPanelDisconnectedState
  assert_not_equal(isDisconnectedAfterChange, isDisconnectedAfterSecondChange, "There should be change in disconnected state.")

end


function test_SateliteLED()

  raiseNotImpl()

  -- block satelite
  -- TODO: where is satalite blockage in TF API ?
  
  -- wait debounce time
  framework.delay(SATELITE_BLOCKAGE_DEBOUNCE+SATELITE_BLOCKAGE_DEBOUNCE_TOLERANCE)

  -- check satelite led
  local ledState = helmPanel:isSateliteLedOn()
  assert_false(ledState,"The satelite led should not be off!")
  
  -- unblock satelite
  -- TODO: where is satalite blockage in TF API ?

  -- wait debounce time
  framework.delay(SATELITE_BLOCKAGE_DEBOUNCE+SATELITE_BLOCKAGE_DEBOUNCE_TOLERANCE)

  -- check satelite led
  local ledState = helmPanel:isSateliteLedOn()
  assert_true(ledState,"The satelite led should be on!")

end

function test_GpsLEDIsOff()

  -- No fix 
  local blockedPosition = {
    speed = 0,                      -- kmh
    latitude = 1,                   -- degrees
    longitude = 1,                  -- degrees
    fixType = 1,                    -- no fix
  }
   
  positionSW:setPropertiesByName({continuous = 1, maxFixTimeout = MAX_FIX_TIMEOUT})
  GPS:set(blockedPosition)

  framework.delay(MAX_FIX_TIMEOUT + GPS_BLOCKED_START_DEBOUNCE_TIME)

  local ledState = helmPanel:isGpsLedOn()
  assert_false(ledState,"The satelite led should be off!")

end

function test_GpsLEDIsOn()

  -- Fix
  local position = {
    speed = 0,                      -- kmh
    latitude = 1,                   -- degrees
    longitude = 1,                  -- degrees
    fixType = 3,                    -- fix
  }
   
  positionSW:setPropertiesByName({continuous = 1, maxFixTimeout = MAX_FIX_TIMEOUT})
  GPS:set(position)

  framework.delay(MAX_FIX_TIMEOUT + GPS_BLOCKED_START_DEBOUNCE_TIME)

  local ledState = helmPanel:isGpsLedOn()
  assert_true(ledState,"The satelite led should be on!")

end

function raiseNotImpl()
  assert_nil(1,"Not implemented yet!")
end

-- TODO: Investigate. 
-- TODO: turned external power button manually in simulator 
-- TODO: but it does not change external power property in unibox neither vms.. 
function test_ExternalPower()

end
