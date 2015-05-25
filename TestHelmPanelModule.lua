-----------------------------------------------------------------------------------------------
-- VMS Interface Unit test module
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

  GPS:set({jammingDetect = false, fixType = 3}) -- not to interrupt other suites

end

--- setup function
function setup()

  vmsSW:setPropertiesByName({
                               GpsBlockedStartDebounceTime = 1,
                               GpsBlockedEndDebounceTime = 1,
                               GpsBlockedSendReport = false,
                               IdpBlockedSendReport = false,
                               PowerDisconnectedSendReport = false,
                               InterfaceUnitDisconnectedSendReport = false,
                            }
  )

  GPS:set({jammingDetect = false, fixType = 3}) -- good signal quality simulated

  -- Interface Unit disconnected from terminal
  InterfaceUnitHelpSW:setPropertiesByName({uniboxConnected = false})

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

--- TC checks if TerminalConnected LED is not flashing when feature is disabled (MinStandardReportLedFlashTime is set to 0)
  -- Initial Conditions:
  --
  -- * Interface Unit service installed on terminal
  -- Steps:
  --
  -- 1. Set StandardReport1Interval, StandardReport2Interval and StandardReport3Interval to 1 minute
  -- 2. Set MinStandardReportLedFlashTime to 0
  -- 3. Wait for standard report OTA message
  -- 4. Read the state of TerminalConnected LED
  --
  -- Results:
  --
  -- 1. StandardReport1Interval, StandardReport2Interval and StandardReport3Interval set to 1 minute
  -- 2. MinStandardReportLedFlashTime set to 0
  -- 3. StandardReport is sent 
  -- 4. TerminalConnected LED is not flashing (slow)
Annotations:register([[
@dependOn(helmPanel,isReady)
@method(test_TerminalConnectedLED_WhenMinStandardReportLedFlashTimeIsSetTo0AndStandardReportsAreBeingSent_TerminalConnectedLEDIsNotFlashing)
@module(TestHelmPanelModule)
]])
function test_TerminalConnectedLED_WhenMinStandardReportLedFlashTimeIsSetTo0AndStandardReportsAreBeingSent_TerminalConnectedLEDIsNotFlashing()

  vmsSW:setPropertiesByName({StandardReport1Interval = 1,
                             StandardReport2Interval = 0,
                             StandardReport3Interval = 0,
                             MinStandardReportLedFlashTime = 0}     -- 0 is for feature disabled
  )

  gateway.setHighWaterMark() -- to get the newest messages
  -- wait for report
  vmsSW:waitForMessagesByName(
    {'StandardReport1'},
    120
  )

  -- chack LED state
  assert_false(InterfaceUnitHelpSW:isConnectLedFlashingSlow(), "Terminal Connected LED is flashing when feature is disabled")

end


--- TC checks if TerminalConnected LED is flashing slow when standard reports are being sent
  -- Initial Conditions:
  --
  -- * Interface Unit service installed on terminal
  -- Steps:
  --
  -- 1. Set StandardReport1Interval to 1 minute
  -- 2. Set MinStandardReportLedFlashTime to some value (less than StandardReport1Interval)
  -- 3. Wait for standard report OTA message
  -- 4. Read the state of the TerminalConnected LED for time longer than MIN_STANDARD_REPORT_FLASH_TIME
  -- 5. Check if TerminalConnected LED was flashing for MIN_STANDARD_REPORT_FLASH_TIME period after sending StandardReport
  --
  -- Results:
  --
  -- 1. StandardReport1Interval set to 1 minute
  -- 2. MinStandardReportLedFlashTime set to value above 0 but below StandardReport1Interval
  -- 3. StandardReport is sent
  -- 4. State of TerminalConnected LED is read periodically every couple of seconds and timestamps when LED is flashing fast are saved
  -- 5. Assertion is performed checking if LED was flashing for correct time after sending standard report
Annotations:register([[
@dependOn(helmPanel,isReady)
@method(test_TerminalConnectedLED_WhenMinStandardReportLedFlashTimeIsSetToValueAbove0AndStandardReportsAreBeingSent_TerminalConnectedLEDIsFlashingForMinStandardReportLedFlashTime)
@module(TestHelmPanelModule)
]])
function test_TerminalConnectedLED_WhenMinStandardReportLedFlashTimeIsSetToValueAbove0AndStandardReportsAreBeingSent_TerminalConnectedLEDIsFlashingForMinStandardReportLedFlashTime()

  -- *** Setup
  local STANDARD_REPORT_1_INTERVAL = 1   -- minutes
  local FLASH_TIME = 30                  
  
  vmsSW:setPropertiesByName({StandardReport1Interval = STANDARD_REPORT_1_INTERVAL,
                             StandardReport2Interval = 0,
                             StandardReport3Interval = 0, 
                             MinStandardReportLedFlashTime = FLASH_TIME},     -- feature enabled
                             InterfaceUnitDisconnectedStartDebounceTime = 1,  -- seconds
                             InterfaceUnitDisconnectedEndDebounceTime = 1,    -- seconds
  )
  
  -- Interface Unit disconnected from terminal
  InterfaceUnitHelpSW:setPropertiesByName({uniboxConnected = true})
  gateway.setHighWaterMark() -- to get the newest messages

   -- wait for report
  local message = vmsSW:waitForMessagesByName(
    {'StandardReport1'},
    120
  )

  local startTime = os.time()
  local currentTime = os.time()

  while currentTime - startTime  < FLASH_TIME   do
    D:log(InterfaceUnitHelpSW:isConnectLedFlashingSlow())
      assert_true(InterfaceUnitHelpSW:isConnectLedFlashingSlow(), "Slow flash has been active for improper period of time")
      D:log(InterfaceUnitHelpSW:isConnectLedFlashingSlow())
      framework.delay(2)
      local currentTime = os.time()
  end

end



--- TC checks if TerminalConnected LED is flashing fast when standard report is waiting in queue
  -- Initial Conditions:
  --
  -- * Interface Unit service installed on terminal
  -- Steps:
  --
  -- 1. Set StandardReport1Interval to 1 minute
  -- 2. Set MinStandardReportLedFlashTime to value above zero
  -- 3. Block air communication
  -- 4. Read the state of the TerminalConnected LED for time longer than MinStandardReportLedFlashTime set previously
  --
  -- Results:
  --
  -- 1. StandardReport1Interval set to 1 minute
  -- 2. MinStandardReportLedFlashTime set to value above 0
  -- 3. StandardReport is generated after one minute but cannot be sent due to air communication blockage
  -- 4. TerminalConnected LED is flasing for time longer than MinStandardReportLedFlashTime
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
      if(InterfaceUnitHelpSW:isConnectLedFlashing()) then
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



--- TC checks if TerminalConnected LED is flashing slowly when an incoming email is waiting to be read
  -- Initial Conditions:
  --
  -- * Interface Unit service installed on terminal
  -- Steps:
  --
  -- 1. Simulate an incoming email message received
  -- 2. Read TerminalConnected LED state
  --
  -- Results:
  --
  -- 1. Email message received by terminal
  -- 2. TerminalConnected LED is flashing slowly when email waits to be read
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
  InterfaceUnitHelpSW:isConnectLedFlashingSlow()
  assert_true(InterfaceUnitHelpSW:isConnectLedFlashingSlow(), "IDP Connected LED is not flashing slow when to-mobile email is received")

end

-----------------------------------------------------------------------------------------------
-- Test Cases - GPS LED on/off
----------------------------------------------------------------------------------------------

--- TC checks if GPS LED is OFF when GPS signal is blocked
  -- Initial Conditions:
  --
  -- * Interface Unit service installed on terminal
  -- Steps:
  --
  -- 1. Set GpsBlockedStartDebounceTime and GpsBlockedEndDebounceTime to 1 second (to get immediate change)
  -- 2. Simulate GPS signal blocked for time above GpsBlockedStartDebounceTime
  -- 3. Read state of GPS LED
  -- 4. Simulate GPS signal not blocked for time above GpsBlockedEndDebounceTime
  -- 5. Read state of GPS LED
  --
  -- Results:
  --
  -- 1. GpsBlockedStartDebounceTime and GpsBlockedEndDebounceTime set to 1 seconds
  -- 2. GPS signal blocked - terminal enters GpsBlockedState after GpsBlockedStartDebounceTime
  -- 3. GPS LED is OFF
  -- 4. GPS sinal good - terminal leaves GpsBlockedState after GpsBlockedEndDebounceTime
  -- 5. GPS LES is ON
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

  framework.delay(GPS_BLOCKED_START_DEBOUNCE_TIME + GPS_CHECK_INTERVAL)

  local ledState = InterfaceUnitHelpSW:isConnectLedFlashingFast()
  
  assert_false(ledState,"The GPS LED is not Off when there is no GPS signal")

  GPS:set({fixType = 3})
  framework.delay(GPS_BLOCKED_END_DEBOUNCE_TIME + GPS_CHECK_INTERVAL)

  ledState = InterfaceUnitHelpSW:isGpsLedOn()
  assert_true(ledState,"The GPS LED is not ON when GPS signal is good")

end


-----------------------------------------------------------------------------------------------
-- Test Cases - SATELLITE LED
-----------------------------------------------------------------------------------------------

--- TC checks if Satellite LED is flashing slowly when IDP link is being estabilished
  -- Initial Conditions:
  --
  -- * Interface Unit service installed on terminal
  -- Steps:
  --
  -- 1. Set IdpBlockedStartDebounceTime to 1 second and IdpBlockedEndDebounceTime to 20 seconds (not to get immediate change)
  -- 2. Simulate IDP connection loss for time above IdpBlockedStartDebounceTime
  -- 3. Simulate IDP connection good
  -- 4. Read Satellite LED state before IdpBlockedEndDebounceTime passes
  --
  -- Results:
  --
  -- 1. IdpBlockedStartDebounceTime and IdpBlockedEndDebounceTime set correctly
  -- 2. IDP connection is lost for time longer than IdpBlockedStartDebounceTime - terminal enters IDP blocked state
  -- 3. IDP connection is good again
  -- 4. Satellite LED is flashing slowly when connection is being estabilished
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

  local ledState = InterfaceUnitHelpSW:isSatelliteLedOn()
  assert_false(ledState, "Satellite LED is not OFF when IDP link is unavailable")

  ------------------------------------------------------------------------------
  -- IDP signal is being estabilished - LED is expected to be flashing slowly
  ------------------------------------------------------------------------------
  vmsSW:SatelliteControlState("Active")
  ledState = InterfaceUnitHelpSW:isSatelliteLedFlashingSlow()
  assert_true(ledState, "Satellite LED is not flashing slowly when IDP connection is being estabilished")

end


--- TC checks if Satellite LED is ON and OFF according to IDP connection
  -- Initial Conditions:
  --
  -- * Interface Unit service installed on terminal
  -- Steps:
  --
  -- 1. Set IdpBlockedStartDebounceTime to 1 second and IdpBlockedEndDebounceTime to 1 seconds (to get immediate change)
  -- 2. Simulate IDP connection loss for time above IdpBlockedStartDebounceTime
  -- 3. Read Satellite LED state
  -- 4. Simulate IDP connection good for time above IdpBlockedEndDebounceTime
  -- 5. Read Satellite LED state
  --
  -- Results:
  --
  -- 1. IdpBlockedStartDebounceTime and IdpBlockedEndDebounceTime set correctly
  -- 2. IDP connection is lost for time longer than IdpBlockedStartDebounceTime - terminal enters IDP blocked state
  -- 3. Satellite LED is OFF
  -- 4. IDP connection is good for time longer than IdpBlockedEndDebounceTime - terminal leaves IDP blocked state
  -- 5. Satellite LED is ON
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

  local ledState = InterfaceUnitHelpSW:isSatelliteLedOn()
  assert_false(ledState, "Satellite LED is not OFF when IDP link is unavailable")

  ------------------------------------------------------------------------------
  -- IDP signal is estabilished - LED is expected to be ON
  ------------------------------------------------------------------------------
  vmsSW:SatelliteControlState("Active")
  framework.delay(IDP_BLOCKED_END_DEBOUNCE_TIME)   -- wait until terminal goes back to IdpBlocked = false state
  ledState = InterfaceUnitHelpSW:isSatelliteLedOn()
  assert_true(ledState, "Satellite LED is not ON when IDP link is OK")

end
-----------------------------------------------------------------------------------------------
-- Test Cases - TerminalConnected LED
-----------------------------------------------------------------------------------------------
--- TC checks if TerminalConnected LED is ON when IDP terminal is connected to Interface Unit
  -- Initial Conditions:
  --
  -- * Interface Unit service installed on terminal
  -- Steps:
  --
  -- 1. Simulate IDP terminal connected to Interface Unit
  -- 2. Read the state of TerminalConnected LED
  -- 3. Simulate IDP terminal disconnected from HelmPanel
  -- 4. Read the state of TerminalConnected LED
  --
  -- Results:
  --
  -- 1. Terminal is connected to Interface Unit
  -- 2. TerminalConnected LED is ON
  -- 3. Terminal disconnected from Interface Unit
  -- 4. TerminalConnected LED is OFF
Annotations:register([[
@dependOn(helmPanel,isReady)
@method(test_TerminalConnectedLED_WhenTerminalIsConnectedOrDisconnectedFromHelmPanel_TerminalConnectedLEDIsOnOrOffAccordingToConnection)
@module(TestHelmPanelModule)
]])
function test_TerminalConnectedLED_WhenTerminalIsConnectedOrDisconnectedFromHelmPanel_TerminalConnectedLEDIsOnOrOffAccordingToConnection()

  -- Terminal is connected to Interface Unit
  InterfaceUnitHelpSW:setPropertiesByName({uniboxConnected = true})
  framework.delay(3)  -- wait until led state is changed

  -- read TerminalConnected led when connection is estabilished
  local ledState = InterfaceUnitHelpSW:isConnectLedOn()
  assert_true(ledState, "Terminal Connected LED is not ON when terminal is connected to Interface Unit")
  D:log(ledState, "TerminalConnected LED state for terminal connected to Interface Unit")

  -- Interface Unit disconnected from terminal
  InterfaceUnitHelpSW:setPropertiesByName({uniboxConnected = false})

  framework.delay(3)  -- wait until led state is changed

  -- check LED again after switch
  ledState = InterfaceUnitHelpSW:isConnectLedOn()
  assert_false(ledState, "Terminal Connected LED is not OFF when terminal is disconnected from Interface Unit")
  D:log(ledState,"TerminalConnected LED state for terminal disconnected from Interface Unit")

end

