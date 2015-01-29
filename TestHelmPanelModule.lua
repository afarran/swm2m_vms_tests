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
    HelmPanelDisconnectedSendReport = true,
    IdpBlockedStartDebounceTime = SATELITE_BLOCKAGE_DEBOUNCE ,
    IdpBlockedEndDebounceTime = SATELITE_BLOCKAGE_DEBOUNCE,
    GpsBlockedStartDebounceTime = GPS_BLOCKED_START_DEBOUNCE_TIME,
    GpsBlockedEndDebounceTime = GPS_BLOCKED_END_DEBOUNCE_TIME
  })

end

-- executed after each test suite
function suite_teardown()
  -- Fix
  local position = {
    speed = 0,                      -- kmh
    latitude = 1,                   -- degrees
    longitude = 1,                  -- degrees
    fixType = 3,                    -- fix
  }

  GPS:set(position)

end

--- setup function
function setup()
  vmsSW:setHighWaterMark()
end

--- teardown function executed after each unit test
function teardown()


  vmsSW:setPropertiesByName({StandardReport1Interval = 0,   -- 0 is for feature disabled
                             StandardReport2Interval = 0,
                             StandardReport3Interval = 0,
                             MinStandardReportLedFlashTime = 0}
  )



end

-----------------------------------------------------------------------------------------------
-- Test Cases - Helm Panel connected/disconnected
-----------------------------------------------------------------------------------------------
Annotations:register([[
@dependOn(helmPanel,isReady)
@method(test_XHelmPanelConnected_WhenHelmPanelDisconnectedStateIsInAGivenStateAndTheStateToggles_HelmPanelDisconnectedStateChangesCorrectlyAndLEDTransitionsAreCorrect)
@module(TestHelmPanelModule)
]])
function test_XHelmPanelConnected_WhenHelmPanelDisconnectedStateIsInAGivenStateAndTheStateToggles_HelmPanelDisconnectedStateChangesCorrectlyAndLEDTransitionsAreCorrect()

  local properties = vmsSW:getPropertiesByName({"HelmPanelDisconnectedState"})
  local isDisconnected = properties.HelmPanelDisconnectedState

  local change = ""

  -- check LED before switch (commented out because in this way TC is unstable, LED is tested in unit test later)
  local ledState = helmPanel:isConnectLedOn()
  if isDisconnected then
    change = "true"
    --assert_false(ledState,"The IDP connect LED should be off!")
  else
    --assert_true(ledState,"The IDP connect LED should be on!")
    change = "false"
  end

  -- state transition
  helmPanel:setConnected(change)
  framework.delay(1)

  -- check LED again after switch
  local ledState = helmPanel:isConnectLedOn()
  if isDisconnected then
    --assert_true(ledState,"The IDP connect LED should be on!")
  else
    --assert_false(ledState,"The IDP connect LED should be off!")
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
  framework.delay(1)

  -- check LED after back to initail state
  local ledState = helmPanel:isConnectLedOn()
  if isDisconnected then
    change = "true"
    --assert_false(ledState,"The IDP connect LED should be off!")
  else
    change = "false"
    --assert_true(ledState,"The IDP connect LED should be on!")
  end

  -- check state transition
  local propertiesAfterSecondChange = vmsSW:getPropertiesByName({"HelmPanelDisconnectedState"})
  local isDisconnectedAfterSecondChange = propertiesAfterSecondChange.HelmPanelDisconnectedState
  assert_not_equal(isDisconnectedAfterChange, isDisconnectedAfterSecondChange, "There should be change in disconnected state.")

end

Annotations:register([[
@dependOn(helmPanel,isReady)
@method(test_XHelmPanelDisconnected_WhenHelmPanelIsDisConnected_ConnectLEDIsOff)
@module(TestHelmPanelModule)
]])
function test_XHelmPanelDisconnected_WhenHelmPanelIsDisConnected_ConnectLEDIsOff()
  helmPanel:setConnected("false")
  local ledState = helmPanel:isConnectLedOn()
  D:log(ledState,"LED-FALSE")
  assert_false(ledState,"LED should be off!")
end

function test_HelmPanelDisconnected_WhenHelmPanelIsConnected_ConnectLEDIsOn()
  helmPanel:setConnected("true")
  local ledState = helmPanel:isConnectLedOn()
  D:log(ledState,"LED-TRUE")
  assert_true(ledState,"LED should be on!")
end

function test_HelmPanelDisconnected_WhenSeveralStateChangesAreTriggered_LedWhichIndicatesConnectIsInCorrectState()
  i = 0
  while i < 3 do
    helmPanel:setConnected("true")
    local ledState = helmPanel:isConnectLedOn()
    D:log(ledState,"LED-TRUE")
    assert_true(ledState,"LED should be on!")
    helmPanel:setConnected("false")
    local ledState = helmPanel:isConnectLedOn()
    D:log(ledState,"LED-FALSE")
    assert_false(ledState,"LED should be off!")
    framework.delay(1)
    i = i+1
 end
end

-----------------------------------------------------------------------------------------------
-- Test Cases - GPS LED on/off - IN DEVELOPMENT!
----------------------------------------------------------------------------------------------

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

-----------------------------------------------------------------------------------------------
-- Test Cases - SATELITE LED on/off - IN DEVELOPMENT
-----------------------------------------------------------------------------------------------

function xtest_SateliteLED_WhenSateliteIsBlockedOrUnblocked_SateliteLedIsInCorrectState()

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

function test_MinStandardReportLedFlashTime_WhenMinStandardReportLedFlashTimeIsSetTo0AndStandardReportsAreBeingSent_TerminalConnectedLEDIsNotFlashing()

  -- *** Setup
  local STANDARD_REPORT_1_INTERVAL = 1
  local STANDARD_REPORT_2_INTERVAL = 1
  local STANDARD_REPORT_3_INTERVAL = 1

  vmsSW:setPropertiesByName({StandardReport1Interval = 1,
                             StandardReport2Interval = 1,
                             StandardReport3Interval = 1,
                             MinStandardReportLedFlashTime = 0}     -- 0 is for feature disabled
  )
  -- *** Execute
  framework.delay(65)
  assert_false(helmPanel:isConnectLedFlashingSlow(), "Terminal Connected LED is flashing when feature is disabled")


end


function test_MinStandardReportLedFlashTime_WhenMinStandardReportLedFlashTimeIsSetToValueAbove0AndStandardReportsAreBeingSent_TerminalConnectedLEDIsFlashingForMinStandardReportLedFlashTime()

  -- *** Setup
  local ledFlashingStateTrueTable = {}
  local STANDARD_REPORT_1_INTERVAL = 1
  local MIN_STANDARD_REPORT_FLASH_TIME = 30

  vmsSW:setPropertiesByName({StandardReport1Interval = STANDARD_REPORT_1_INTERVAL,
                             MinStandardReportLedFlashTime = MIN_STANDARD_REPORT_FLASH_TIME}     -- feature enabled
  )

  local standardReportEnabledStartTime = os.time()
  D:log(standardReportEnabledStartTime)
  local currentTime = 0

  gateway.setHighWaterMark() -- to get the newest messages
  framework.delay(STANDARD_REPORT_1_INTERVAL*60 - 10)

  currentTime = os.time()

  while currentTime < standardReportEnabledStartTime + STANDARD_REPORT_1_INTERVAL*60 + MIN_STANDARD_REPORT_FLASH_TIME + 10  do
      currentTime = os.time()
      if(helmPanel:isConnectLedFlashing()) then
        currentTime = os.time()
        ledFlashingStateTrueTable[#ledFlashingStateTrueTable + 1] = currentTime
      end
  end

  D:log(ledFlashingStateTrueTable)

  local lastElementIndex = table.getn(ledFlashingStateTrueTable)

  assert_equal(ledFlashingStateTrueTable[lastElementIndex] - ledFlashingStateTrueTable[1],
  MIN_STANDARD_REPORT_FLASH_TIME,
  8,
  "IDP Connected LED was flashing for incorrect period of time when MIN_STANDARD_REPORT_FLASH_TIME is set above zero"
  )

end


function test_MinStandardReportLedFlashTime_WhenMinStandardReportLedFlashTimeIsSetToValueAbove0AndStandardIsWaitingInQueueToBeSent_TerminalConnectedLEDIsFlashing()

  -- TODO this need to be modified when an implementation of the function allowing IDP blockage will be done
  -- device profile application
  if IDPBlockageFeaturesImplemented == false then skip("API for setting Satellite Control State has not been implemented yet - no use to perform TC") end

  -- *** Setup
  local ledFlashingStateTrueTable = {}
  local STANDARD_REPORT_1_INTERVAL = 1
  local MIN_STANDARD_REPORT_FLASH_TIME = 5

  vmsSW:setPropertiesByName({StandardReport1Interval = STANDARD_REPORT_1_INTERVAL,
                             MinStandardReportLedFlashTime = MIN_STANDARD_REPORT_FLASH_TIME}     -- feature enabled
  )

  local standardReportEnabledStartTime = os.time()
  D:log(standardReportEnabledStartTime)

  gateway.setHighWaterMark() -- to get the newest messages
  framework.delay(STANDARD_REPORT_1_INTERVAL*60 - 10)

  local currentTime = os.time()

  while currentTime < standardReportEnabledStartTime + STANDARD_REPORT_1_INTERVAL*60 + 60 do
      currentTime = os.time()
      if(helmPanel:isConnectLedFlashing()) then
        currentTime = os.time()
        ledFlashingStateTrueTable[#ledFlashingStateTrueTable + 1] = currentTime
      end
  end

  D:log(ledFlashingStateTrueTable)

  local lastElementIndex = table.getn(ledFlashingStateTrueTable)

  assert_gt(ledFlashingStateTrueTable[lastElementIndex],
  standardReportEnabledStartTime + STANDARD_REPORT_1_INTERVAL*60 + MIN_STANDARD_REPORT_FLASH_TIME + 5,
  8,
  "IDP Connected LED was not flashing when StandardReport was waiting in queue while IDP Blockage"
  )

end



function raiseNotImpl()
  assert_nil(1,"Not implemented yet!")
end

-- TODO: Investigate.
-- TODO: turned external power button manually in simulator
-- TODO: but it does not change external power property in unibox neither vms..
function test_ExternalPower()

end


---------------------------------------------------------------------------------
-- This test case if just for reporting test framework issue. REMOVE AFTER FIX!
---------------------------------------------------------------------------------
function test_getPropertiesBug()
  i = 0
  while i < 10 do
    helmPanel:setConnected("true") -- this is posting event via shell service(lua code chunk)
    local result = lsf.getProperties(162, {2})
    D:log(result,"RESULT")
    helmPanel:setConnected("false")
    local result = lsf.getProperties(162, {2})
    D:log(result,"RESULT")
    framework.delay(1)
    i = i+1
 end

end
