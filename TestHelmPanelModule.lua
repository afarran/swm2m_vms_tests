-----------------------------------------------------------------------------------------------
-- VMS Helm Panel test module
-----------------------------------------------------------------------------------------------
-- @module TestHelmPanelModule
-----------------------------------------------------------------------------------------------

module("TestHelmPanelModule", package.seeall)
DEBUG_MODE = 1

local SATELITE_BLOCKAGE_DEBOUNCE = 1
local SATELITE_BLOCKAGE_DEBOUNCE_TOLERANCE = 0
local GPS_BLOCKED_START_DEBOUNCE_TIME = 1
local GPS_BLOCKED_END_DEBOUNCE_TIME = 1 
local MAX_FIX_TIMEOUT = 1 

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

function test_HelmPanelConnected_WhenHelmPanelDisconnectedStateIsInAGivenStateAndTheStateToggles_HelmPanelDisconnectedStateChangesCorrectlyAndLEDTransitionsAreCorrect()

  local properties = vmsSW:getPropertiesByName({"HelmPanelDisconnectedState"})
  local isDisconnected = properties.HelmPanelDisconnectedState

  local change = ""

  -- check LED before switch
  local ledState = helmPanel:isConnectLedOn()
  if isDisconnected then
    change = "true"
    assert_false(ledState,"The IDP connect LED should be off!")
  else
    assert_true(ledState,"The IDP connect LED should be on!")
    change = "false"
  end

  -- state transition
  helmPanel:setConnected(change) 
  framework.delay(4)

  -- check LED again after switch
  local ledState = helmPanel:isConnectLedOn()
  if isDisconnected then
    assert_true(ledState,"The IDP connect LED should be on!")
  else
    assert_false(ledState,"The IDP connect LED should be off!")
  end

  -- check transition
  local propertiesAfterChange = vmsSW:getPropertiesByName({"HelmPanelDisconnectedState"})
  local isDisconnectedAfterChange = propertiesAfterChange.HelmPanelDisconnectedState
  assert_not_equal(isDisconnectedAfterChange, isDisconnected, "There should be change in disconnected state.")

  if isDisconnectedAfterChange then
    change = "true"
  else
    change = "false"
  end

  --second state transition
  helmPanel:setConnected(change)
  framework.delay(2)
  
  -- check LED after back to initail state
  local ledState = helmPanel:isConnectLedOn()
  if isDisconnected then
    change = "true"
    assert_false(ledState,"The IDP connect LED should be off!")
  else
    change = "false"
    assert_true(ledState,"The IDP connect LED should be on!")
  end

  -- check state transition
  local propertiesAfterSecondChange = vmsSW:getPropertiesByName({"HelmPanelDisconnectedState"})
  local isDisconnectedAfterSecondChange = propertiesAfterSecondChange.HelmPanelDisconnectedState
  assert_not_equal(isDisconnectedAfterChange, isDisconnectedAfterSecondChange, "There should be change in disconnected state.")

end

function test_GpsLED_WhenGpsIsBlocked_GpsLedIsOff()

  -- No fix 
  local blockedPosition = {
    speed = 0,                      -- kmh
    latitude = 1,                   -- degrees
    longitude = 1,                  -- degrees
    fixType = 1,                    -- no fix
  }
   
  positionSW:setPropertiesByName({
    continuous = 0, 
    maxFixTimeout = MAX_FIX_TIMEOUT
  })
  GPS:set(blockedPosition)

  framework.delay(MAX_FIX_TIMEOUT + GPS_BLOCKED_START_DEBOUNCE_TIME + 2)

  framework.delay(120)

  local ledState = helmPanel:isGpsLedOn()
  assert_false(ledState,"The GPS LED should be off!")

end

function test_GpsLED_WhenGpsIsSetWithCorrectFix_GpsLedIsOn()

  -- Fix
  local position = {
    speed = 0,                      -- kmh
    latitude = 1,                   -- degrees
    longitude = 1,                  -- degrees
    fixType = 3,                    -- fix
  }
   
  positionSW:setPropertiesByName({
    continuous = 1, 
    maxFixTimeout = MAX_FIX_TIMEOUT
  })
  GPS:set(position)

  framework.delay(MAX_FIX_TIMEOUT + GPS_BLOCKED_START_DEBOUNCE_TIME + 2 )
 
  framework.delay(65)

  local ledState = helmPanel:isGpsLedOn()
  assert_true(ledState,"The GPS LED should be on!")

end

function test_SateliteLED_WhenSateliteIsBlockedOrUnblocked_SateliteLedIsInCorrectState()

  raiseNotImpl()

  -- block satelite
  -- TODO: where is satalite blockage in TF API ?
  
  -- wait debounce time
  framework.delay(SATELITE_BLOCKAGE_DEBOUNCE+SATELITE_BLOCKAGE_DEBOUNCE_TOLERANCE)

  -- check satelite led
  local ledState = helmPanel:isSateliteLedOn()
  assert_false(ledState,"The satelite LED should not be off!")
  
  -- unblock satelite
  -- TODO: where is satalite blockage in TF API ?

  -- wait debounce time
  framework.delay(SATELITE_BLOCKAGE_DEBOUNCE+SATELITE_BLOCKAGE_DEBOUNCE_TOLERANCE)

  -- check satelite led
  local ledState = helmPanel:isSateliteLedOn()
  assert_true(ledState,"The satelite LED should be on!")

end
---------------------------------------------------------------------------------

function raiseNotImpl()
  assert_nil(1,"Not implemented yet!")
end

-- TODO: Investigate. 
-- TODO: turned external power button manually in simulator 
-- TODO: but it does not change external power property in unibox neither vms.. 
function test_ExternalPower()

end
