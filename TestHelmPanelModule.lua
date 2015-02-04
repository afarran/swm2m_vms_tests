-----------------------------------------------------------------------------------------------
-- VMS Helm Panel test module
-----------------------------------------------------------------------------------------------
-- @module TestHelmPanelModule
-----------------------------------------------------------------------------------------------

module("TestHelmPanelModule", package.seeall)
DEBUG_MODE = 1

local MAX_FIX_TIMEOUT = 60
local GPS_CHECK_INTERVAL = 60

-- global variable, to be removed
-- TODO: remove this when IDP blockage TestFramework functions are implemented
IDPBlockageFeaturesImplemented = false

-----------------------------------------------------------------------------------------------
-- SETUP
-----------------------------------------------------------------------------------------------
function suite_setup()
  -- reset of properties
  systemSW:resetProperties({vmsSW.sin})

  vmsSW:setPropertiesByName({StandardReport1Interval = 0,   -- 0 is for feature disabled
                             StandardReport2Interval = 0,
                             StandardReport3Interval = 0,
                             MinStandardReportLedFlashTime = 0}
  )


end

-- executed after each test suite
function suite_teardown()

  PS:set({jammingDetect = false, fixType = 3}) -- not to interrupt other suites

end

--- setup function
function setup()

  vmsSW:setPropertiesByName({
                               ExtPowerDisconnectedStartDebounceTime = 1,
                               ExtPowerDisconnectedEndDebounceTime = 1,
                               GpsBlockedStartDebounceTime = 1,
                               GpsBlockedEndDebounceTime = 1,
                               GpsBlockedSendReport = false,
                               IdpBlockedSendReport = false,
                               PowerDisconnectedSendReport = false,
                               HelmPanelDisconnectedSendReport = false,
                            }
  )

  GPS:set({jammingDetect = false, fixType = 3}) -- good signal quality simulated

  -- External power source disconnected from Helm panel
  helmPanel:externalPowerConnected("false")

  -- Helm Panel disconnected from terminal
  helmPanel:setConnected("false")

  framework.delay(2)  -- to let terminal go into desired state


end

--- teardown function executed after each unit test
function teardown()

  GPS:set({jammingDetect = false, fixType = 3}) -- not to interrupt other TCs

  vmsSW:setPropertiesByName({StandardReport1Interval = 0,   -- 0 is for feature disabled
                             StandardReport2Interval = 0,
                             StandardReport3Interval = 0,
                             MinStandardReportLedFlashTime = 0}
  )



end

-----------------------------------------------------------------------------------------------
-- Test Cases - TerminalConnected LED
-----------------------------------------------------------------------------------------------
--- TC checks if TerminalConnected LED is ON when IDP terminal is connected to Helm Panel
  -- Initial Conditions:
  --
  -- * Helm Panel service installed on terminal
  -- Steps:
  --
  -- 1. Simulate IDP terminal connected to Helm Panel
  -- 2. Read the state of TerminalConnected LED
  -- 3. Simulate IDP terminal disconnected from HelmPanel
  -- 4. Read the state of TerminalConnected LED
  --
  -- Results:
  --
  -- 1. Terminal is connected to Helm Panel
  -- 2. TerminalConnected LED is ON
  -- 3. Terminal disconnected from Helm Panel
  -- 4. TerminalConnected LED is OFF
Annotations:register([[
@dependOn(helmPanel,isReady)
@method(test_TerminalConnectedLED_WhenTerminalIsConnectedOrDisconnectedFromHelmPanel_TerminalConnectedLEDIsOnOrOffAccordingToConnection)
@module(TestHelmPanelModule)
]])
function test_TerminalConnectedLED_WhenTerminalIsConnectedOrDisconnectedFromHelmPanel_TerminalConnectedLEDIsOnOrOffAccordingToConnection()

  -- Terminal is connected to helm panel
  helmPanel:setConnected("true")
  framework.delay(3)  -- wait until led state is changed

  -- read TerminalConnected led when connection is estabilished
  local ledState = helmPanel:isConnectLedOn()
  assert_true(ledState, "Terminal Connected LED is not ON when terminal is connected to helm panel")
  D:log(ledState, "TerminalConnected LED state for terminal connected to helm panel")

  -- Helm Panel disconnected from terminal
  helmPanel:setConnected("false")

  framework.delay(3)  -- wait until led state is changed

  -- check LED again after switch
  ledState = helmPanel:isConnectLedOn()
  assert_false(ledState, "Terminal Connected LED is not OFF when terminal is disconnected from helm panel")
  D:log(ledState,"TerminalConnected LED state for terminal disconnected from helm panel")

end

--- TC checks if TerminalConnected LED is not flashing when feature is disabled (MinStandardReportLedFlashTime is set to 0)
  -- Initial Conditions:
  --
  -- * Helm Panel service installed on terminal
  -- Steps:
  --
  -- 1. Set StandardReport1Interval, StandardReport2Interval and StandardReport3Interval to 1 minute
  -- 2. Set MinStandardReportLedFlashTime to 0
  -- 3. Wait for longer than one minute to make sure a StandardReport is sent
  -- 4. Read the state of TerminalConnected LED
  --
  -- Results:
  --
  -- 1. StandardReport1Interval, StandardReport2Interval and StandardReport3Interval set to 1 minute
  -- 2. MinStandardReportLedFlashTime set to 0
  -- 3. StandardReport is sent after 1 minute
  -- 4. TerminalConnected LED is not flashing
Annotations:register([[
@dependOn(helmPanel,isReady)
@method(test_TerminalConnectedLED_WhenMinStandardReportLedFlashTimeIsSetTo0AndStandardReportsAreBeingSent_TerminalConnectedLEDIsNotFlashing)
@module(TestHelmPanelModule)
]])
function test_TerminalConnectedLED_WhenMinStandardReportLedFlashTimeIsSetTo0AndStandardReportsAreBeingSent_TerminalConnectedLEDIsNotFlashing()

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
  assert_false(helmPanel:isConnectLedFlashingFast(), "Terminal Connected LED is flashing when feature is disabled")
  assert_false(helmPanel:isConnectLedFlashingSlow(), "Terminal Connected LED is flashing when feature is disabled")

end



--- TC checks if TerminalConnected LED is flashing fast when standard reports are being sent
  -- Initial Conditions:
  --
  -- * Helm Panel service installed on terminal
  -- Steps:
  --
  -- 1. Set StandardReport1Interval to 1 minute
  -- 2. Set MinStandardReportLedFlashTime to some value (less than StandardReport1Interval)
  -- 3. Wait for longer than one minute to make sure a StandardReport is sent
  -- 4. Read the state of the TerminalConnected LED for time longer than MIN_STANDARD_REPORT_FLASH_TIME
  -- 5. Check if TerminalConnected LED was flashing for MIN_STANDARD_REPORT_FLASH_TIME period after sending StandardReport
  --
  -- Results:
  --
  -- 1. StandardReport1Interval set to 1 minute
  -- 2. MinStandardReportLedFlashTime set to value above 0 but below StandardReport1Interval
  -- 3. StandardReport is sent after 1 minute
  -- 4. State of TerminalConnected LED is read periodically every couple of seconds and timestamps when LED is flashing fast are saved
  -- 5. Assertion is performed checking if LED was flashing for correct time after sending standard report
Annotations:register([[
@dependOn(helmPanel,isReady)
@method(test_TerminalConnectedLED_WhenMinStandardReportLedFlashTimeIsSetToValueAbove0AndStandardReportsAreBeingSent_TerminalConnectedLEDIsFlashingForMinStandardReportLedFlashTime)
@module(TestHelmPanelModule)
]])
function test_TerminalConnectedLED_WhenMinStandardReportLedFlashTimeIsSetToValueAbove0AndStandardReportsAreBeingSent_TerminalConnectedLEDIsFlashingForMinStandardReportLedFlashTime()

  -- *** Setup
  local ledFlashingStateTrueTable = {}
  local STANDARD_REPORT_1_INTERVAL = 1
  local MIN_STANDARD_REPORT_FLASH_TIME = 30

  vmsSW:setPropertiesByName({StandardReport1Interval = STANDARD_REPORT_1_INTERVAL,
                             MinStandardReportLedFlashTime = MIN_STANDARD_REPORT_FLASH_TIME}     -- feature enabled
  )
  -- *** Execute
  local standardReportEnabledStartTime = os.time()
  D:log(standardReportEnabledStartTime)
  local currentTime = 0

  gateway.setHighWaterMark() -- to get the newest messages
  framework.delay(STANDARD_REPORT_1_INTERVAL*60 - 10)

  currentTime = os.time()

  while currentTime < standardReportEnabledStartTime + STANDARD_REPORT_1_INTERVAL*60 + MIN_STANDARD_REPORT_FLASH_TIME + 10  do
      currentTime = os.time()
      if(helmPanel:isConnectLedFlashingFast()) then
        currentTime = os.time()
        ledFlashingStateTrueTable[#ledFlashingStateTrueTable + 1] = currentTime
      end
  end

  D:log(next(ledFlashingStateTrueTable))
  assert_not_nil(next(ledFlashingStateTrueTable),"LED was not in flashing fast state at when terminal was sending StandardReports" )
  D:log(ledFlashingStateTrueTable)
  local lastElementIndex = table.getn(ledFlashingStateTrueTable)
  assert_equal(ledFlashingStateTrueTable[lastElementIndex] - ledFlashingStateTrueTable[1],
  MIN_STANDARD_REPORT_FLASH_TIME,
  8,
  "IDP Connected LED was flashing for incorrect period of time when MIN_STANDARD_REPORT_FLASH_TIME is set above zero"
  )

end

Annotations:register([[
@dependOn(helmPanel,isReady)
@method(test_TerminalConnectedLED_WhenMinStandardReportLedFlashTimeIsSetToValueAbove0AndStandardIsWaitingInQueueToBeSent_TerminalConnectedLEDIsFlashing)
@module(TestHelmPanelModule)
]])
function test_TerminalConnectedLED_WhenMinStandardReportLedFlashTimeIsSetToValueAbove0AndStandardIsWaitingInQueueToBeSent_TerminalConnectedLEDIsFlashing()

  -- TODO this need to be modified when an implementation of the function allowing IDP blockage will be done
  -- device profile application
  skip("waiting for implementation of direct shell usage - property cannot be read by GetProperties message when satellite signal is blocked")

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
  --TODO:
  -- GPS:set({blackaSe = true})
  D:log("communication blocked")

  local currentTime = os.time()
  -- this needs to be modified - property cannot be read by GetProperties message when satellite signal is blocked
  -- shell command should be used
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


Annotations:register([[
@dependOn(helmPanel,isReady)
@method(test_MinStandardReportLedFlashTime_WhenToMobileEmailIsUnread_TerminalConnectedLEDIsFlashingSlowly)
@module(TestHelmPanelModule)
]])
function test_TerminalConnectedLED_WhenToMobileEmailIsUnread_TerminalConnectedLEDIsFlashingSlowly()

  -- TODO: update this TC when receiving emails by VMS will be implemented and available in test framework
  skip("Receiving Emails is not implemented yet")

  -- *** Setup
  local ledFlashingStateTrueTable = {}
  local STANDARD_REPORT_1_INTERVAL = 1
  local MIN_STANDARD_REPORT_FLASH_TIME = 5

  vmsSW:setPropertiesByName({MinStandardReportLedFlashTime = MIN_STANDARD_REPORT_FLASH_TIME})     -- feature enabled

  local standardReportEnabledStartTime = os.time()
  D:log(standardReportEnabledStartTime)

  gateway.setHighWaterMark() -- to get the newest messages

  -- simulate receivied email now
  helmPanel:isConnectLedFlashingSlow()
  assert_true(helmPanel:isConnectLedFlashingSlow(), "IDP Connected LED is not flashing slow when to-mobile email is received")

end

-----------------------------------------------------------------------------------------------
-- Test Cases - GPS LED on/off
----------------------------------------------------------------------------------------------

Annotations:register([[
@dependOn(helmPanel,isReady)
@method(test_GpsLED_WhenGpsIsBlockedAndNotBlocked_GpsLedIsOffOrOnAccordingToGPSSignal)
@module(TestHelmPanelModule)
]])
function test_GpsLED_WhenGpsIsBlockedAndNotBlocked_GpsLedIsOffOrOnAccordingToGPSSignalPresence()

  local GPS_BLOCKED_START_DEBOUNCE_TIME = 1
  local GPS_BLOCKED_END_DEBOUNCE_TIME = 1

  vmsSW:setPropertiesByName({
                               GpsBlockedStartDebounceTime = GPS_BLOCKED_START_DEBOUNCE_TIME,
                               GpsBlockedEndDebounceTime = GPS_BLOCKED_END_DEBOUNCE_TIME,
                               GpsBlockedSendReport = false,
                            }
  )

  positionSW:setPropertiesByName({maxFixTimeout = MAX_FIX_TIMEOUT})
  GPS:set({fixType = 1})

  framework.delay(MAX_FIX_TIMEOUT + GPS_BLOCKED_START_DEBOUNCE_TIME + GPS_CHECK_INTERVAL)

  local ledState = helmPanel:isGpsLedOn()
  assert_false(ledState,"The GPS LED is not Off when there is no GPS signal")

  GPS:set({fixType = 3})
  framework.delay(GPS_BLOCKED_END_DEBOUNCE_TIME + GPS_CHECK_INTERVAL)

  ledState = helmPanel:isGpsLedOn()
  assert_true(ledState,"The GPS LED is not ON when GPS signal is good")

end


-----------------------------------------------------------------------------------------------
-- Test Cases - SATELLITE LED
-----------------------------------------------------------------------------------------------

Annotations:register([[
@dependOn(helmPanel,isReady)
@method(test_SatelliteLED_WhenIDPSignalIsBeingEstabilished_SatelliteLEDIsFlashingSlowly)
@module(TestHelmPanelModule)
]])
function test_SatelliteLED_WhenIDPSignalIsBeingEstabilished_SatelliteLEDIsFlashingSlowly()

  if IDPBlockageFeaturesImplemented == false then skip("API for setting Satellite Control State has not been implemented yet - no use to perform TC") end

  -- *** Setup
  local IDP_BLOCKED_START_DEBOUNCE_TIME = 1     -- seconds
  local IDP_BLOCKED_END_DEBOUNCE_TIME = 20      -- seconds

  vmsSW:setPropertiesByName({
                             IdpBlockedStartDebounceTime = IDP_BLOCKED_START_DEBOUNCE_TIME,
                             IdpBlockedEndDebounceTime = IDP_BLOCKED_END_DEBOUNCE_TIME,
                             IdpBlockedSendReport = false,
                             }
  )

  -- *** Execute
  ------------------------------------------------------------------------------
  -- IDP signal is blocked - LED is expected to be OFF
  ------------------------------------------------------------------------------

  vmsSW:SatelliteControlState("NotActive")
  framework.delay(IDP_BLOCKED_START_DEBOUNCE_TIME)   -- wait until terminal goes back to IdpBlocked = true state

  local ledState = helmPanel:isSatelliteLedOn()
  assert_false(ledState, "Satellite LED is not OFF when IDP link is unavailable")

  ------------------------------------------------------------------------------
  -- IDP signal is being estabilished - LED is expected to be flashing slowly
  ------------------------------------------------------------------------------
  vmsSW:SatelliteControlState("Active")
  ledState = helmPanel:isSatelliteLedFlashingSlow()
  assert_true(ledState, "Satellite LED is not flashing slowly when IDP connection is being estabilished")

end


Annotations:register([[
@dependOn(helmPanel,isReady)
@method(test_SatelliteLED_WhenIDPSignalIsNotAvailableOrIDPSignalIsGood_SatelliteLEDIsOffForIDPBlockedAndOnForIdpSignalGood)
@module(TestHelmPanelModule)
]])
function test_SatelliteLED_WhenIDPSignalIsNotAvailableOrIDPSignalIsGood_SatelliteLEDIsOffForIDPBlockedAndOnForIdpSignalGood()


  if IDPBlockageFeaturesImplemented == false then skip("API for setting Satellite Control State has not been implemented yet - no use to perform TC") end

  -- *** Setup
  local IDP_BLOCKED_START_DEBOUNCE_TIME = 1     -- seconds
  local IDP_BLOCKED_END_DEBOUNCE_TIME = 1       -- seconds

  vmsSW:setPropertiesByName({
                             IdpBlockedStartDebounceTime = IDP_BLOCKED_START_DEBOUNCE_TIME,
                             IdpBlockedEndDebounceTime = IDP_BLOCKED_END_DEBOUNCE_TIME,
                             IdpBlockedSendReport = false,
                             }
  )

  -- *** Execute
  ------------------------------------------------------------------------------
  -- IDP signal is blocked - LED is expected to be OFF
  ------------------------------------------------------------------------------

  vmsSW:SatelliteControlState("NotActive")
  framework.delay(IDP_BLOCKED_START_DEBOUNCE_TIME)   -- wait until terminal goes back to IdpBlocked = true state

  local ledState = helmPanel:isSatelliteLedOn()
  assert_false(ledState, "Satellite LED is not OFF when IDP link is unavailable")

  ------------------------------------------------------------------------------
  -- IDP signal is estabilished - LED is expected to be ON
  ------------------------------------------------------------------------------
  vmsSW:SatelliteControlState("Active")
  framework.delay(IDP_BLOCKED_END_DEBOUNCE_TIME)   -- wait until terminal goes back to IdpBlocked = false state
  ledState = helmPanel:isSatelliteLedOn()
  assert_true(ledState, "Satellite LED is not ON when IDP link is OK")

end
