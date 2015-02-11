-----------
-- Reporting test module
-- - contains VMS reporting features
-- @module TestGPSEventsModule

module("TestAbnormalReportsModule", package.seeall)

-- global variable, to be removed
IDPBlockageFeaturesImplemented = false


function suite_setup()
  -- reset of properties
  -- restarting VMS agent ?

end

-- executed after each test suite
function suite_teardown()

  GPS:set({jammingDetect = false, fixType = 3}) -- not to interrupt other suits


end

--- setup function
function setup()

  positionSW:setPropertiesByName({continuous = GPS_READ_INTERVAL})
  vmsSW:setPropertiesByName({
                               GpsJammedStartDebounceTime = 1,
                               GpsJammedEndDebounceTime = 1,
                               StandardReport1Interval = 0,
                               ExtPowerDisconnectedStartDebounceTime = 1,
                               ExtPowerDisconnectedEndDebounceTime = 1,
                               HelmPanelDisconnectedStartDebounceTime = 1,
                               HelmPanelDisconnectedEndDebounceTime = 1,
                               HwClientDisconnectedStartDebounceTime = 1,
                               HwClientDisconnectedEndDebounceTime = 1,
                               GpsBlockedStartDebounceTime = 1,
                               GpsBlockedEndDebounceTime = 1,
                               GpsJammedSendReport = false,
                               GpsBlockedSendReport = false,
                               IdpBlockedSendReport = false,
                               PowerDisconnectedSendReport = false,
                               HelmPanelDisconnectedSendReport = false,
                               HwClientDisconnectedSendReport = false,
                            }
  )

  GPS:set({jammingDetect = false, fixType = 3})

  -- External power source disconnected from Helm panel
  helmPanel:externalPowerConnected("false")

  -- Helm Panel disconnected from terminal
  helmPanel:setConnected("false")

  -- disconnecting HW Client
  shellSW:postEvent(
                    "\"_RS232\"",
                    "DTECONNECTED",
                    "false"
  )

  framework.delay(2)



end

-----------------------------------------------------------------------------------------------
--- teardown function executed after each unit test
function teardown()

  GPS:set({jammingDetect = false, fixType = 3})

  -- External power source disconnected from Helm panel
  helmPanel:externalPowerConnected("false")

  -- Helm Panel disconnected from terminal
  helmPanel:setConnected("false")

  -- disconnecting HW Client
  shellSW:postEvent(
                    "\"_RS232\"",
                    "DTECONNECTED",
                    "false"
  )

end

-------------------------
-- Test Cases
-------------------------

--- TC checks if GpsJamming AbnormalReport is sent when GPS signal is jammed for time above GpsJammedStartDebounceTime period
  -- Initial Conditions:
  --
  -- * GPS signal is good
  -- * Terminal not in GpsJammed state
  --
  -- Steps:
  --
  -- 1. Set GpsJammedStartDebounceTime to value A.
  -- 2. Set GpsJammedSendReport to true.
  -- 3. Simulate terminal in InitialPosition - GPS signal not jammed.
  -- 4. Simulate terminal in GpsJammedPosition - GPS signal jammed.
  -- 5. Before GpsJammedStartDebounceTime time passes check GpsJammedState property.
  -- 6. Wait longer than GpsJammedStartDebounceTime.
  -- 7. Check the content of received AbnormalReport.
  -- 8. Check GpsJammedState property.
  --
  -- Results:
  --
  -- 1. GpsJammedStartDebounceTime set to value A.
  -- 2. GpsJammedSendReport set to true.
  -- 3. Terminal in InitialPosition with good GPS quality.
  -- 4. GPS signal jammed.
  -- 5. GpsJammedState property should be false before GpsJammedStartDebounceTime passes.
  -- 6. AbnormalReport with GpsJammed information is sent.
  -- 7. Report contains all required fields and StatusBitmap contains GpsJammed bit set to true.
  -- 8. GpsJammedState is true after GpsJammedStartDebounceTime has passed.
function test_GpsJamming_WhenGpsSignalIsJammedForTimeAboveGpsJammedStartDebouncePeriod_GpsJammedAbnormalReportIsSent()

  -- *** Setup
  local GPS_JAMMED_START_DEBOUNCE_TIME = 10   -- seconds
  local GPS_JAMMED_END_DEBOUNCE_TIME = 5      -- seconds

  -- terminal stationary, GPS signal good initially
  local InitialPosition = {
    speed = 0,                      -- kmh
    latitude = 1,                   -- degrees
    longitude = 1,                  -- degrees
    jammingDetect = false,
  }

  -- terminal in different position (wrong GPS data)
  local GpsJammedPosition = {
    speed = 0,                      -- kmh
    latitude = 1,                   -- degrees
    longitude = 1,                  -- degrees
    jammingDetect = true,
  }

  vmsSW:setPropertiesByName({GpsJammedStartDebounceTime = GPS_JAMMED_START_DEBOUNCE_TIME,
                             GpsJammedEndDebounceTime = GPS_JAMMED_END_DEBOUNCE_TIME,
                             GpsJammedSendReport = true,
                            }
  )

  -- *** Execute
  -- terminal in initial position, gps signal not jammed
  GPS:set(InitialPosition)
  gateway.setHighWaterMark() -- to get the newest messages
  -- GPS signal is jammed from now
  GPS:set(GpsJammedPosition)
  local timeOfEvent = os.time()  -- to get exact timestamp
  D:log(timeOfEvent)

  -- checking GpsJammedState property - this is expected to be false before GPS_JAMMED_START_DEBOUNCE_TIME period passes
  local GpsJammedStateProperty = vmsSW:getPropertiesByName({"GpsJammedState"})
  assert_false(GpsJammedStateProperty["GpsJammedState"], "GpsJammedState has been changed before GpsJammedStartDebounceTime has passed")

  framework.delay(GPS_JAMMED_START_DEBOUNCE_TIME)

  -- AbnormalReport is expected with GpsJammed information
  local ReceivedMessages = vmsSW:waitForMessagesByName({"AbnormalReport"})
  -- back to initial position with no gps jamming
  GPS:set(InitialPosition)

  assert_not_nil(ReceivedMessages["AbnormalReport"], "AbnormalReport not received")

  -- checking GpsJammedState property - this is expected to be true as GPS_JAMMED_START_DEBOUNCE_TIME period has passed
  local GpsJammedStateProperty = vmsSW:getPropertiesByName({"GpsJammedState"})
  assert_true(GpsJammedStateProperty["GpsJammedState"], "GpsJammedState property has not been changed correctly when GPS jamming was detected")

  assert_equal(
    GpsJammedPosition.latitude*60000,
    tonumber(ReceivedMessages["AbnormalReport"].Latitude),
    "Wrong latitude value in GpsJammed abnormal report"
  )

  assert_equal(
    GpsJammedPosition.longitude*60000,
    tonumber(ReceivedMessages["AbnormalReport"].Longitude),
    "Wrong longitude value in GpsJammed abnormal report"
  )

  assert_equal(
    GpsJammedPosition.speed,
    tonumber(ReceivedMessages["AbnormalReport"].Speed),
    "Wrong speed value in GpsJammed abnormal report"
  )

  assert_equal(
    361,
    tonumber(ReceivedMessages["AbnormalReport"].Course),
    "Wrong course value in GpsJammed abnormal report"
  )

  assert_equal(
    "GpsJammed",
    ReceivedMessages["AbnormalReport"].EventType,
    "Wrong name of the received EventType in GpsJammed abnormal report"
  )

  assert_equal(
    timeOfEvent,
    tonumber(ReceivedMessages["AbnormalReport"].Timestamp),
    10,
    "Wrong Timestamp value in GpsJammed abnormal report"
  )

  -- TODO: update this after implementation in TestFramework file
  --[[
  assert_equal(
    InitialPosition.hdop,
    ReceivedMessages["AbnormalReport"].Hdop,
    "Wrong HDOP value in GpsJammed abnormal report"
  )

  assert_equal(
    InitialPosition.idpsnr,
    ReceivedMessages["AbnormalReport"].IdpSnr,
    "Wrong IdpSnr value in GpsJammed abnormal report"
  )

  assert_equal(
    InitialPosition.numsats,
    ReceivedMessages["AbnormalReport"].NumSats,
    "Wrong NumSats value in GpsJammed abnormal report"
  )
  --]]


  local StatusBitmap = vmsSW:decodeBitmap(ReceivedMessages["AbnormalReport"].StatusBitmap, "EventStateId")
  assert_true(StatusBitmap["GpsJammed"], "StatusBitmap has not been correctly changed when terminal detected GPS jamming")


end


--- TC checks if GpsJamming AbnormalReport is sent when GPS signal is not jammed for time above GpsJammedEndDebounceTime for terminal in GPS jammed state
  -- Initial Conditions:
  --
  -- * GPS signal is jammed
  -- * Terminal is in GpsJammed state
  --
  -- Steps:
  --
  -- 1. Set GpsJammedStartDebounceTime to value A and GpsJammedEndDebounceTime to value B.
  -- 2. Set GpsJammedSendReport to true.
  -- 3. Simulate terminal in GpsJammedPosition - GPS signal jammed for time above GpsJammedStartDebounceTime.
  -- 4. Simulate terminal in GpsNotJammedPosition - GPS signal not jammed.
  -- 5. Before GpsJammedEndDebounceTime time passes check GpsJammedState property.
  -- 6. Wait longer than GpsJammedEndDebounceTime.
  -- 7. Check the content of received AbnormalReport.
  -- 8. Check GpsJammedState property.
  --
  -- Results:
  --
  -- 1. GpsJammedStartDebounceTime set to value A and GpsJammedEndDebounceTime set to value B.
  -- 2. GpsJammedSendReport set to true.
  -- 3. Terminal in GpsJammedPosition enters gps jammed state after GpsJammedStartDebounceTime.
  -- 4. GPS signal is not jammed in GpsNotJammedPosition.
  -- 5. GpsJammedState property should be true before GpsJammedEndDebounceTime passes.
  -- 6. AbnormalReport with GpsJammed information is sent.
  -- 7. Report contains all required fields and StatusBitmap contains GpsJammed bit set to false.
  -- 8. GpsJammedState is false after GpsJammedEndDebounceTime has passed.
function test_GpsJamming_ForTerminalInGpsJammedStateWhenGpsSignalIsNotJammedForTimeAboveGpsJammedEndDebouncePeriod_GpsJammedAbnormalReportIsSent()

  -- *** Setup
  local GPS_JAMMED_START_DEBOUNCE_TIME = 1     -- seconds
  local GPS_JAMMED_END_DEBOUNCE_TIME = 10      -- seconds

  -- terminal in different position (wrong GPS data)
  local GpsJammedPosition = {
    speed = 0,                      -- kmh
    latitude = 2,                   -- degrees
    longitude = 2,                  -- degrees
    jammingDetect = true,
  }

  -- terminal in different position (wrong GPS data)
  local GpsNotJammedPosition = {
    speed = 0,                      -- kmh
    latitude = 2,                   -- degrees
    longitude = 2,                  -- degrees
    jammingDetect = false,
  }

  vmsSW:setPropertiesByName({GpsJammedStartDebounceTime = GPS_JAMMED_START_DEBOUNCE_TIME,
                             GpsJammedEndDebounceTime = GPS_JAMMED_END_DEBOUNCE_TIME,
                             GpsJammedSendReport = true
                             }
  )

  -- *** Execute
  -- GPS signal is jammed from now
  GPS:set(GpsJammedPosition)
  framework.delay(GPS_JAMMED_START_DEBOUNCE_TIME + 2)
  gateway.setHighWaterMark() -- to get the newest messages
  -- GPS signal is good again
  GPS:set(GpsNotJammedPosition)

  -- checking GpsJammedState property - this is expected to be true before GPS_JAMMED_END_DEBOUNCE_TIME period passes
  local GpsJammedStateProperty = vmsSW:getPropertiesByName({"GpsJammedState"})
  assert_true(GpsJammedStateProperty["GpsJammedState"], "GpsJammedState is incorrectly false for terminal in GpsJammed state")

  framework.delay(GPS_JAMMED_END_DEBOUNCE_TIME)

  local timeOfEvent = os.time()  -- to get exact timestamp

  -- AbnormalReport is expected with GpsJammed information
  local ReceivedMessages = vmsSW:waitForMessagesByName({"AbnormalReport"})
  assert_not_nil(ReceivedMessages["AbnormalReport"], "AbnormalReport not received")

  -- checking GpsJammedState property - this is expected to be false as GPS_JAMMED_END_DEBOUNCE_TIME period had passed
  local GpsJammedStateProperty = vmsSW:getPropertiesByName({"GpsJammedState"})
  assert_false(GpsJammedStateProperty["GpsJammedState"], "GpsJammedState property has not been changed correctly gps signal is not jammed and terminal left GpsJammed state")

  assert_equal(
    GpsNotJammedPosition.latitude*60000,
    tonumber(ReceivedMessages["AbnormalReport"].Latitude),
    "Wrong latitude value in GpsJammed abnormal report"
  )

  assert_equal(
    GpsNotJammedPosition.longitude*60000,
    tonumber(ReceivedMessages["AbnormalReport"].Longitude),
    "Wrong longitude value in GpsJammed abnormal report"
  )

  assert_equal(
    GpsNotJammedPosition.speed,
    tonumber(ReceivedMessages["AbnormalReport"].Speed),
    "Wrong speed value in GpsJammed abnormal report"
  )

  assert_equal(
    361,
    tonumber(ReceivedMessages["AbnormalReport"].Course),
    "Wrong course value in GpsJammed abnormal report"
  )

  assert_equal(
    "GpsJammed",
    ReceivedMessages["AbnormalReport"].EventType,
    "Wrong name of the received EventType in GpsJammed abnormal report"
  )

  assert_equal(
    timeOfEvent,
    tonumber(ReceivedMessages["AbnormalReport"].Timestamp),
    10,
    "Wrong Timestamp value in GpsJammed abnormal report"
  )

  -- TODO: update this after implementation in TestFramework file
  --[[
  assert_equal(
    GpsNotJammedPosition.hdop,
    ReceivedMessages["AbnormalReport"].Hdop,
    "Wrong HDOP value in GpsJammed abnormal report"
  )

  assert_equal(
    GpsNotJammedPosition.idpsnr,
    ReceivedMessages["AbnormalReport"].IdpSnr,
    "Wrong IdpSnr value in GpsJammed abnormal report"
  )

  assert_equal(
    GpsNotJammedPosition.numsats,
    ReceivedMessages["AbnormalReport"].NumSats,
    "Wrong NumSats value in GpsJammed abnormal report"
  )
  --]]

  local StatusBitmap = vmsSW:decodeBitmap(ReceivedMessages["AbnormalReport"].StatusBitmap, "EventStateId")
  assert_false(StatusBitmap["GpsJammed"], "StatusBitmap has not been correctly changed when terminal detected GPS jamming")


end


--- TC checks if GpsJamming AbnormalReport is not sent when GPS signal is not jammed for time below GpsJammedEndDebounceTime for terminal in GPS jammed state
  -- Initial Conditions:
  --
  -- * GPS signal is jammed
  -- * Terminal is in GpsJammed state
  --
  -- Steps:
  --
  -- 1. Set GpsJammedEndDebounceTime to some high value (90 seconds in example)
  -- 2. Enable sending GpsJammed reports.
  -- 3. Put terminal into gps jammed state.
  -- 4. Simulate gps signal good (not jammed) for time shorter than GpsJammedEndDebounceTime.
  -- 5. Wait for GpsJammed AbnormalReport.
  -- 6. Check GpsJammedState property.
  --
  -- Results:
  --
  -- 1. GpsJammedEndDebounceTime set to some high value.
  -- 2. GpsJammedSendReport set to true.
  -- 3. Terminal in GpsJammed state.
  -- 4. GPS signal is not jammed for time below GpsJammedEndDebounceTime.
  -- 5. GpsJammed AbnormalReport is not sent.
  -- 6. GpsJammedState is true.
 function test_GpsJamming_ForTerminalInGpsJammedStateWhenGpsSignalIsNotJammedForTimeBelowGpsJammedEndDebouncePeriod_GpsJammedAbnormalReportIsNotSent()

  -- *** Setup
  local GPS_JAMMED_START_DEBOUNCE_TIME = 1     -- seconds
  local GPS_JAMMED_END_DEBOUNCE_TIME = 90      -- seconds

  -- terminal in different position (wrong GPS data)
  local GpsJammedPosition = {
    speed = 0,                      -- kmh
    latitude = 2,                   -- degrees
    longitude = 2,                  -- degrees
    jammingDetect = true,
  }

  -- terminal in different position (wrong GPS data)
  local GpsNotJammedPosition = {
    speed = 0,                      -- kmh
    latitude = 2,                   -- degrees
    longitude = 2,                  -- degrees
    jammingDetect = false,
  }

  vmsSW:setPropertiesByName({GpsJammedStartDebounceTime = GPS_JAMMED_START_DEBOUNCE_TIME,
                             GpsJammedEndDebounceTime = GPS_JAMMED_END_DEBOUNCE_TIME,
                             GpsJammedSendReport = true
                             }
  )

  -- *** Execute
  -- GPS signal is jammed from now
  GPS:set(GpsJammedPosition)
  framework.delay(GPS_JAMMED_START_DEBOUNCE_TIME + 2)
  gateway.setHighWaterMark() -- to get the newest messages
  -- GPS signal is good again
  GPS:set(GpsNotJammedPosition)

  -- checking GpsJammedState property - this is expected to be true before GPS_JAMMED_END_DEBOUNCE_TIME period passes
  local GpsJammedStateProperty = vmsSW:getPropertiesByName({"GpsJammedState"})
  assert_true(GpsJammedStateProperty["GpsJammedState"], "GpsJammedState is incorrectly false for terminal in GpsJammed state")

  local ReceivedMessages = vmsSW:waitForMessagesByName({"AbnormalReport"}, 75)

  if(ReceivedMessages["AbnormalReport"] ~= nil and ReceivedMessages["AbnormalReport"].EventType == "GpsJammed" ) then
    assert_nil(1, "GpsJammed abnormal report sent but not expected")
  end

  -- GPS signal is jammed again from now (the pause in jamming was shorter than GPS_JAMMED_END_DEBOUNCE_TIME)
  GPS:set(GpsJammedPosition)

  -- checking GpsJammedState property - this is expected to be true as signal is still jammed
  local GpsJammedStateProperty = vmsSW:getPropertiesByName({"GpsJammedState"})
  assert_true(GpsJammedStateProperty["GpsJammedState"], "GpsJammedState is incorrectly false for terminal in GpsJammed state")



end



--- TC checks if GpsJamming AbnormalReport is not sent when GPS signal is jammed for time below GpsJammedStartDebounceTime
  -- Initial Conditions:
  --
  -- * GPS signal is not jammed
  -- * Terminal is not in GpsJammed state
  --
  -- Steps:
  --
  -- 1. Set GpsJammedStartDebounceTime to some high value (90 seconds in example).
  -- 2. Enable sending GpsJammed reports.
  -- 3. Simulate GPS signal jammed for time shorter than GpsJammedStartDebounceTime.
  -- 4. Check GpsJammedState property.
  --
  -- Results:
  --
  -- 1. GpsJammedStartDebounceTime set to some high value.
  -- 2. GpsJammedSendReport set to true.
  -- 3. GpsJammed AbnormalReport is not sent.
  -- 4. GPS signal is not jammed for time below GpsJammedEndDebounceTime.
  -- 5. GpsJammedState is not true.
function test_GpsJamming_WhenGpsSignalIsJammedForTimeBelowGpsJammedStartDebouncePeriod_GpsJammedAbnormalReportIsNotSent()

  local GPS_JAMMED_START_DEBOUNCE_TIME = 90   -- seconds
  local GPS_JAMMED_END_DEBOUNCE_TIME = 1

  vmsSW:setPropertiesByName({GpsJammedStartDebounceTime = GPS_JAMMED_START_DEBOUNCE_TIME,
                             GpsJammedEndDebounceTime = GPS_JAMMED_END_DEBOUNCE_TIME,
                             GpsJammedSendReport = true
                            }
  )

  -- terminal stationary, GPS signal good initially
  local InitialPosition = {
    speed = 0,                      -- kmh
    latitude = 1,                   -- degrees
    longitude = 1,                  -- degrees
    jammingDetect = false,
  }

  GPS:set(InitialPosition)
  framework.delay(GPS_JAMMED_END_DEBOUNCE_TIME)

  gateway.setHighWaterMark() -- to get the newest messages
  -- GPS signal is jammed from now
  GPS:set({jammingDetect = true})

  local ReceivedMessages = vmsSW:waitForMessagesByName({"AbnormalReport"}, 75)

  -- back to GPS signal not jammed
  GPS:set(InitialPosition)

  -- checking GpsJammedState property
  local GpsJammedStateProperty = vmsSW:getPropertiesByName({"GpsJammedState"})
  D:log(GpsJammedStateProperty["GpsJammedState"], "GpsJammedStateProperty")
  assert_false(GpsJammedStateProperty["GpsJammedState"], "GpsJammedState property has not been changed correctly when GPS jamming was detected")

  if(ReceivedMessages["AbnormalReport"] ~= nil and ReceivedMessages["AbnormalReport"].EventType == "GpsJammed" ) then
    assert_nil(1, "GpsJammed abnormal report sent but not expected")
  end

end


--- TC checks if GpsJamming AbnormalReport is not sent when GPS signal is jammed for time above GpsJammedStartDebounceTime period but GpsJammed reports are disabled
  -- Initial Conditions:
  --
  -- * GPS signal is good
  -- * Terminal not in GpsJammed state
  --
  -- Steps:
  --
  -- 1. Set GpsJammedStartDebounceTime to value A.
  -- 2. Disable sending GpsJammed reports.
  -- 3. Simulate GPS signal jammed for time above GpsJammedStartDebounceTime.
  -- 4. Wait for GpsJammed AbnormalReport.
  -- 5. Check GpsJammedState property.
  --
  -- Results:
  --
  -- 1. GpsJammedStartDebounceTime set to value A.
  -- 2. GpsJammedSendReport set to false.
  -- 3. GPS signal jammed for time longer than GpsJammedStartDebounceTime.
  -- 4. GpsJammed AbnormalReport is not sent.
  -- 5. GpsJammedState property should be true after GpsJammedStartDebounceTime passes.
function test_GpsJamming_WhenGpsSignalIsJammedForTimeAboveGpsJammedStartDebouncePeriodButGpsJammedReportsAreDisabled_GpsJammedAbnormalReportIsNotSent()

  local GPS_JAMMED_START_DEBOUNCE_TIME = 1   -- seconds
  local GPS_JAMMED_END_DEBOUNCE_TIME = 1     -- seconds

  vmsSW:setPropertiesByName({GpsJammedStartDebounceTime = GPS_JAMMED_START_DEBOUNCE_TIME,
                             GpsJammedEndDebounceTime = GPS_JAMMED_END_DEBOUNCE_TIME,
                             GpsJammedSendReport = false
                            }
  )

  -- terminal stationary, GPS signal good initially
  local InitialPosition = {
    speed = 0,                      -- kmh
    latitude = 1,                   -- degrees
    longitude = 1,                  -- degrees
    jammingDetect = false,
  }
  gateway.setHighWaterMark() -- to get the newest messages
  GPS:set(InitialPosition)
  -- GPS signal is jammed from now
  GPS:set({jammingDetect = true})
  framework.delay(GPS_JAMMED_START_DEBOUNCE_TIME)

  -- checking GpsJammedState property
  local GpsJammedStateProperty = vmsSW:getPropertiesByName({"GpsJammedState"})
  D:log(framework.dump(GpsJammedStateProperty["GpsJammedState"]))
  assert_true(GpsJammedStateProperty["GpsJammedState"], "GpsJammedState property has not been changed correctly when GPS jamming was detected")

  local ReceivedMessages = vmsSW:waitForMessagesByName({"AbnormalReport"}, 75)

  -- back to not jammed signal
  GPS:set(InitialPosition)


  if(ReceivedMessages["AbnormalReport"] ~= nil and ReceivedMessages["AbnormalReport"].EventType == "GpsJammed" ) then
    assert_nil(1, "GpsJammed abnormal report sent but not expected")
  end

end

--- TC checks if GpsBlocked AbnormalReport is sent when GPS signal is blocked for time above GpsBlockedStartDebounceTime period
  -- Initial Conditions:
  --
  -- * GPS signal is good
  -- * Terminal not in GpsBlocked state
  --
  -- Steps:
  --
  -- 1. Set GpsBlockedStartDebounceTime to value A, GpsBlockedEndDebounceTime to value B and maxFixTimeout in Position service to 60 seconds.
  -- 2. Set GpsBlockedSendReport to true.
  -- 3. Simulate terminal in InitialPosition - GPS signal not blocked.
  -- 4. Simulate terminal in GpsBlockedPosition - no valid fix provided.
  -- 5. Wait for maxFixTimeout period.
  -- 6. Before GpsBlockedStartDebounceTime time passes check GpsBlockedState property.
  -- 7. Wait longer than GpsBlockedStartDebounceTime.
  -- 8. Check the content of received AbnormalReport.
  -- 9. Check GpsBlockedState property.
  --
  -- Results:
  --
  -- 1. Settings applied successfully.
  -- 2. GpsBlockedSendReport set to true.
  -- 3. Terminal in InitialPosition with good GPS quality.
  -- 4. GPS signal blocked.
  -- 5. MaxFixTimeout time passes.
  -- 6. GpsBlockedState property should be false before GpsBlockedStartDebounceTime passes.
  -- 7. AbnormalReport with GpsBlocked information is sent after GpsBlockedStartDebounceTime.
  -- 8. Report contains all required fields and StatusBitmap contains GpsBlocked bit set to true.
  -- 9. GpsBlockedState is true after GpsBlockedStartDebounceTime has passed.
function test_GpsBlocked_WhenGpsSignalIsBlockedForTimeAboveGpsBlockedStartDebouncePeriod_GpsBlockedAbnormalReportIsSent()

  -- *** Setup
  local GPS_BLOCKED_START_DEBOUNCE_TIME = 20   -- seconds
  local GPS_BLOCKED_END_DEBOUNCE_TIME = 1      -- seconds
  local MAX_FIX_TIMEOUT = 60                   -- seconds (60 seconds is the minimum allowed value for this property)

  -- terminal stationary, GPS signal good initially
  local InitialPosition = {
    speed = 0,                      -- kmh
    latitude = 1,                   -- degrees
    longitude = 1,                  -- degrees
    fixType = 3,                    -- valid fix
   }

  -- terminal in different position (no valid fix provided)
  local GpsBlockedPosition = {
    speed = 0,                      -- kmh
    latitude = 1,                   -- degrees
    longitude = 1,                  -- degrees
    fixType = 1,                    -- no fix
  }

  vmsSW:setPropertiesByName({GpsBlockedStartDebounceTime = GPS_BLOCKED_START_DEBOUNCE_TIME,
                             GpsBlockedEndDebounceTime = GPS_BLOCKED_END_DEBOUNCE_TIME,
                             GpsBlockedSendReport = true,
                             }
  )

  positionSW:setPropertiesByName({maxFixTimeout = MAX_FIX_TIMEOUT})

  -- *** Execute
  -- terminal in initial position, gps signal not blocked
  GPS:set(InitialPosition)
  gateway.setHighWaterMark() -- to get the newest messages
  -- GPS signal is blocked from now
  GPS:set(GpsBlockedPosition)

  -- waiting until MAX_FIX_TIMEOUT time passes - no new fix provided during this period
  framework.delay(MAX_FIX_TIMEOUT)

  -- checking GpsBlockedState property - this is expected to be false before GPS_BLOCKED_START_DEBOUNCE_TIME period passes
  local GpsBlockedStateProperty = vmsSW:getPropertiesByName({"GpsBlockedState"})
  assert_false(GpsBlockedStateProperty["GpsBlockedState"], "GpsBlockedState has been changed before GpsBlockedStartDebounceTime has passed")
  D:log(GpsBlockedStateProperty, "GpsBlockedStateProperty before GpsBlockedStartDebounceTime")

  framework.delay(GPS_BLOCKED_START_DEBOUNCE_TIME)

  local timeOfEvent = os.time()  -- to get exact timestamp
  D:log(timeOfEvent)

  -- AbnormalReport is expected with GpsBlocked information
  local ReceivedMessages = vmsSW:waitForMessagesByName({"AbnormalReport"})
  local GpsBlockedStateProperty = vmsSW:getPropertiesByName({"GpsBlockedState"})

  -- back to initial position with no gps blockage
  GPS:set(InitialPosition)
  framework.delay(MAX_FIX_TIMEOUT + GPS_BLOCKED_END_DEBOUNCE_TIME)   -- wait until terminal goes back to GpsBlocked = false state

  assert_not_nil(ReceivedMessages["AbnormalReport"], "AbnormalReport not received")

  -- checking GpsBlockedState property - this is expected to be true as GPS_BLOCKED_START_DEBOUNCE_TIME period has passed
  assert_true(GpsBlockedStateProperty["GpsBlockedState"], "GpsBlockedState property has not been changed correctly when GPS blockage was detected")
  D:log(GpsBlockedStateProperty, "GpsBlockedStateProperty after GpsBlockedStartDebounceTime")

  assert_equal(
    GpsBlockedPosition.latitude*60000,
    tonumber(ReceivedMessages["AbnormalReport"].Latitude),
    "Wrong latitude value in GpsBlocked abnormal report"
  )

  assert_equal(
    GpsBlockedPosition.longitude*60000,
    tonumber(ReceivedMessages["AbnormalReport"].Longitude),
    "Wrong longitude value in GpsBlocked abnormal report"
  )

  assert_equal(
    GpsBlockedPosition.speed,
    tonumber(ReceivedMessages["AbnormalReport"].Speed),
    "Wrong speed value in GpsBlocked abnormal report"
  )

  assert_equal(
    361,
    tonumber(ReceivedMessages["AbnormalReport"].Course),
    "Wrong course value in GpsBlocked abnormal report"
  )

  assert_equal(
    "GpsBlocked",
    ReceivedMessages["AbnormalReport"].EventType,
    "Wrong name of the received EventType in GpsBlocked abnormal report"
  )

  assert_equal(
    timeOfEvent,
    tonumber(ReceivedMessages["AbnormalReport"].Timestamp),
    20,
    "Wrong Timestamp value in GpsBlocked abnormal report"
  )

  -- TODO: update this after implementation in TestFramework file
  --[[
  assert_equal(
    GpsBlockedPosition.hdop,
    ReceivedMessages["AbnormalReport"].Hdop,
    "Wrong HDOP value in GpsBlocked abnormal report"
  )

  assert_equal(
    GpsBlockedPosition.idpsnr,
    ReceivedMessages["AbnormalReport"].IdpSnr,
    "Wrong IdpSnr value in GpsBlocked abnormal report"
  )

  assert_equal(
    GpsBlockedPosition.numsats,
    ReceivedMessages["AbnormalReport"].NumSats,
    "Wrong NumSats value in GpsBlocked abnormal report"
  )
  --]]


  local StatusBitmap = vmsSW:decodeBitmap(ReceivedMessages["AbnormalReport"].StatusBitmap, "EventStateId")
  assert_true(StatusBitmap["GpsBlocked"], "StatusBitmap has not been correctly changed when terminal detected GPS blockage")

end


--- TC checks if GpsBlocked AbnormalReport is not sent when GPS signal is blocked for time above GpsBlockedStartDebounceTime period but GpsBlocked reports are disabled
  -- Initial Conditions:
  --
  -- * GPS signal is good
  -- * Terminal not in GpsBlocked state
  --
  -- Steps:
  --
  -- 1. Set GpsBlockedStartDebounceTime to value A, GpsBlockedEndDebounceTime to value B and maxFixTimeout in Position service to 60 seconds.
  -- 2. Set GpsBlockedSendReport to true.
  -- 3. Simulate terminal in InitialPosition - GPS signal not blocked.
  -- 4. Simulate terminal in GpsBlockedPosition - no valid fix provided.
  -- 5. Wait for maxFixTimeout period.
  -- 6. Before GpsBlockedStartDebounceTime time passes check GpsBlockedState property.
  -- 7. Wait longer than GpsBlockedStartDebounceTime.
  -- 8. Check the content of received AbnormalReport.
  -- 9. Check GpsBlockedState property.
  --
  -- Results:
  --
  -- 1. Settings applied successfully.
  -- 2. GpsBlockedSendReport set to true.
  -- 3. Terminal in InitialPosition with good GPS quality.
  -- 4. GPS signal blocked.
  -- 5. MaxFixTimeout time passes.
  -- 6. GpsBlockedState property should be false before GpsBlockedStartDebounceTime passes.
  -- 7. AbnormalReport with GpsBlocked information is sent after GpsBlockedStartDebounceTime.
  -- 8. Report contains all required fields and StatusBitmap contains GpsBlocked bit set to true.
  -- 9. GpsBlockedState is true after GpsBlockedStartDebounceTime has passed.
function test_GpsBlocked_ForTerminalInGpsBlockedStateWhenGpsSignalIsNotBlockedForTimeAboveGpsBlockedEndDebouncePeriod_GpsBlockedAbnormalReportIsSent()

  -- *** Setup
  local GPS_BLOCKED_START_DEBOUNCE_TIME = 1     -- seconds
  local GPS_BLOCKED_END_DEBOUNCE_TIME = 10      -- seconds
  local MAX_FIX_TIMEOUT = 60                    -- seconds (60 seconds is the minimum allowed value for this property)

  -- terminal stationary, GPS signal good initially
  local InitialPosition = {
    speed = 0,                      -- kmh
    latitude = 1,                   -- degrees
    longitude = 1,                  -- degrees
    fixType = 3,                    -- valid fix
   }

  -- terminal in different position (no valid fix provided)
  local GpsBlockedPosition = {
    speed = 0,                      -- kmh
    latitude = 1,                   -- degrees
    longitude = 1,                  -- degrees
    fixType = 1,                    -- no fix
  }

  vmsSW:setPropertiesByName({GpsBlockedStartDebounceTime = GPS_BLOCKED_START_DEBOUNCE_TIME,
                             GpsBlockedEndDebounceTime = GPS_BLOCKED_END_DEBOUNCE_TIME,
                             GpsBlockedSendReport = true,
                             }
  )

  positionSW:setPropertiesByName({maxFixTimeout = MAX_FIX_TIMEOUT})

  -- *** Execute
  -- terminal in initial position, gps signal not blocked
  GPS:set(InitialPosition)

  local GpsBlockedStateProperty = vmsSW:getPropertiesByName({"GpsBlockedState"})
  D:log(framework.dump(GpsBlockedStateProperty), "GpsBlockedStateProperty before GpsBlockedEndDebounceTime")
  assert_false(GpsBlockedStateProperty["GpsBlockedState"], "GpsBlockedState has not been changed when GPS blockage has been not detected")

  -- GPS signal is blocked from now
  GPS:set(GpsBlockedPosition)
  -- waiting until terminal goes to GpsBlocked = true state
  framework.delay(MAX_FIX_TIMEOUT + GPS_BLOCKED_START_DEBOUNCE_TIME)

  -- AbnormalReport is expected with GpsBlocked information
  local ReceivedMessages = vmsSW:waitForMessagesByName({"AbnormalReport"})
  assert_not_nil(ReceivedMessages["AbnormalReport"], "AbnormalReport not received")

  local GpsBlockedStateProperty = vmsSW:getPropertiesByName({"GpsBlockedState"})
  D:log(framework.dump(GpsBlockedStateProperty), "GpsBlockedStateProperty before GpsBlockedEndDebounceTime")
  assert_true(GpsBlockedStateProperty["GpsBlockedState"], "GpsBlockedState has not been changed when GPS blockage has been detected")

  gateway.setHighWaterMark() -- to get the newest messages
  -- back to initial position with good GPS signal quality
  GPS:set(InitialPosition)
  framework.delay(2)   -- wait until terminal gets valid fixes

  -- checking GpsBlockedState property - this is expected to be true as GPS_BLOCKED_END_DEBOUNCE_TIME period has not passed yet
  GpsBlockedStateProperty = vmsSW:getPropertiesByName({"GpsBlockedState"})
  print(framework.dump(GpsBlockedStateProperty), "GpsBlockedStateProperty before GpsBlockedEndDebounceTime")
  assert_true(GpsBlockedStateProperty["GpsBlockedState"], "GpsBlockedState has been changed before GpsBlockedEndDebounceTime has passed")

  -- waiting until terminal goes to GpsBlocked = false state
  framework.delay(GPS_BLOCKED_END_DEBOUNCE_TIME)

  -- AbnormalReport is expected with GpsBlocked information
  local ReceivedMessages = vmsSW:waitForMessagesByName({"AbnormalReport"})
  assert_not_nil(ReceivedMessages["AbnormalReport"], "AbnormalReport not received")

  local timeOfEvent = os.time()  -- to get exact timestamp
  D:log(timeOfEvent)

  -- checking GpsBlockedState property - this is expected to be false as GPS_BLOCKED_END_DEBOUNCE_TIME period has passed
  GpsBlockedStateProperty = vmsSW:getPropertiesByName({"GpsBlockedState"})
  assert_false(GpsBlockedStateProperty["GpsBlockedState"], "GpsBlockedState property has not been changed correctly when GPS signal is good again")
  D:log(GpsBlockedStateProperty, "GpsBlockedStateProperty after GpsBlockedEndDebounceTime")

  assert_equal(
    GpsBlockedPosition.latitude*60000,
    tonumber(ReceivedMessages["AbnormalReport"].Latitude),
    "Wrong latitude value in GpsBlocked abnormal report"
  )

  assert_equal(
    GpsBlockedPosition.longitude*60000,
    tonumber(ReceivedMessages["AbnormalReport"].Longitude),
    "Wrong longitude value in GpsBlocked abnormal report"
  )

  assert_equal(
    GpsBlockedPosition.speed,
    tonumber(ReceivedMessages["AbnormalReport"].Speed),
    "Wrong speed value in GpsBlocked abnormal report"
  )

  assert_equal(
    361,
    tonumber(ReceivedMessages["AbnormalReport"].Course),
    "Wrong course value in GpsBlocked abnormal report"
  )

  assert_equal(
    "GpsBlocked",
    ReceivedMessages["AbnormalReport"].EventType,
    "Wrong name of the received EventType in GpsBlocked abnormal report"
  )

  assert_equal(
    timeOfEvent,
    tonumber(ReceivedMessages["AbnormalReport"].Timestamp),
    40,
    "Wrong Timestamp value in GpsBlocked abnormal report"
  )

  -- TODO: update this after implementation in TestFramework file
  --[[
  assert_equal(
    GpsBlockedPosition.hdop,
    ReceivedMessages["AbnormalReport"].Hdop,
    "Wrong HDOP value in GpsBlocked abnormal report"
  )

  assert_equal(
    GpsBlockedPosition.idpsnr,
    ReceivedMessages["AbnormalReport"].IdpSnr,
    "Wrong IdpSnr value in GpsBlocked abnormal report"
  )

  assert_equal(
    GpsBlockedPosition.numsats,
    ReceivedMessages["AbnormalReport"].NumSats,
    "Wrong NumSats value in GpsBlocked abnormal report"
  )
  --]]


  local StatusBitmap = vmsSW:decodeBitmap(ReceivedMessages["AbnormalReport"].StatusBitmap, "EventStateId")
  assert_false(StatusBitmap["GpsBlocked"], "StatusBitmap has not been changed correctly when GPS signal is good again")

end


--- TC checks if GpsBlocked AbnormalReport is not sent when GpsBlocked reports are disabled for terminal in GpsBlocked state
  -- Initial Conditions:
  --
  -- * GPS signal is good
  -- * Terminal not in GpsBlocked state
  --
  -- Steps:
  --
  -- 1. Set GpsBlockedStartDebounceTime to value A, GpsBlockedEndDebounceTime to value B and maxFixTimeout to 60 seconds
  -- 2. Disable sending GpsBlocked reports.
  -- 3. Simulate GPS signal blocked for time above maxFixTimeout and GpsBlockedStartDebounceTime.
  -- 4. Wait for GpsBlocked AbnormalReport.
  -- 5. Check GpsBlockedState property.
  --
  -- Results:
  --
  -- 1. Settings applied successfully.
  -- 2. GpsBlockedSendReport set to false.
  -- 3. GPS signal blocked.
  -- 4. GpsBlocked AbnormalReport is not sent.
  -- 5. GpsBlockedState property is true after GpsBlockedStartDebounceTime.
function test_GpsBlocked_WhenGpsSignalIsBlockedForTimeAboveGpsBlockedStartDebouncePeriodButGpsBlockedReportsAreDisabled_GpsBlockedAbnormalReportIsNotSent()

  -- *** Setup
  local GPS_BLOCKED_START_DEBOUNCE_TIME = 1    -- seconds
  local GPS_BLOCKED_END_DEBOUNCE_TIME = 1      -- seconds
  local MAX_FIX_TIMEOUT = 60                   -- seconds (60 seconds is the minimum allowed value for this property)

  -- terminal stationary, GPS signal good initially
  local InitialPosition = {
    speed = 0,                      -- kmh
    latitude = 1,                   -- degrees
    longitude = 1,                  -- degrees
    fixType = 3,                    -- valid fix
   }

  -- terminal in different position (no valid fix provided)
  local GpsBlockedPosition = {
    speed = 0,                      -- kmh
    latitude = 1,                   -- degrees
    longitude = 1,                  -- degrees
    fixType = 1,                    -- no fix
  }

  vmsSW:setPropertiesByName({GpsBlockedStartDebounceTime = GPS_BLOCKED_START_DEBOUNCE_TIME,
                             GpsBlockedEndDebounceTime = GPS_BLOCKED_END_DEBOUNCE_TIME,
                             GpsBlockedSendReport = false,
                             }
  )

  positionSW:setPropertiesByName({maxFixTimeout = MAX_FIX_TIMEOUT})

  -- *** Execute
  -- terminal in initial position, gps signal not blocked
  GPS:set(InitialPosition)
  gateway.setHighWaterMark() -- to get the newest messages
  -- GPS signal is blocked from now
  GPS:set(GpsBlockedPosition)

  -- waiting until MAX_FIX_TIMEOUT + GPS_BLOCKED_START_DEBOUNCE_TIME time passes - no new fix provided during this period
  framework.delay(MAX_FIX_TIMEOUT + GPS_BLOCKED_START_DEBOUNCE_TIME)

  -- AbnormalReport with GpsBlocked information is not expected
  local ReceivedMessages = vmsSW:waitForMessagesByName({"AbnormalReport"}, 15)
  local GpsBlockedStateProperty = vmsSW:getPropertiesByName({"GpsBlockedState"})

  -- back toinitial position, gps signal not blocked
  GPS:set(InitialPosition)

  -- checking if AbnormalReport related to GpsBlocked has not been sent by terminal
  if(ReceivedMessages["AbnormalReport"] ~= nil and ReceivedMessages["AbnormalReport"].EventType == "GpsBlocked" ) then
    assert_nil(1, "GpsBlocked abnormal report sent but not expected")
  end

  -- checking GpsBlockedState property - this is expected to be true as GPS_BLOCKED_START_DEBOUNCE_TIME period has passed
  assert_true(GpsBlockedStateProperty["GpsBlockedState"], "GpsBlockedState property has not been changed correctly when GPS blockage was detected")
  D:log(GpsBlockedStateProperty, "GpsBlockedState")


end



--- TC checks if GpsBlocked AbnormalReport is not sent when GPS signal is blocked below GpsBlockedStartDebounceTime period
  -- Initial Conditions:
  --
  -- * GPS signal is good
  -- * Terminal not in GpsBlocked state
  --
  -- Steps:
  --
  -- 1. Set GpsBlockedStartDebounceTime to value A, GpsBlockedEndDebounceTime to value B and maxFixTimeout to 60 seconds
  -- 2. Enable sending GpsBlocked reports.
  -- 3. Simulate GPS signal blocked for time above maxFixTimeout.
  -- 4. Wait shorter than  GpsBlockedStartDebounceTime and check if GpsBlocked AbnormalReport has not been sent.
  --
  -- Results:
  --
  -- 1. Settings applied successfully.
  -- 2. GpsBlockedSendReport set to true.
  -- 3. GPS signal blocked.
  -- 4. GpsBlocked AbnormalReport is not sent by terminal.
function test_GpsBlocked_WhenGpsSignalIsBlockedForTimeBelowGpsBlockedStartDebouncePeriod_GpsBlockedAbnormalReportIsNotSent()

  -- *** Setup
  local GPS_BLOCKED_START_DEBOUNCE_TIME = 1    -- seconds
  local GPS_BLOCKED_END_DEBOUNCE_TIME = 20     -- seconds
  local MAX_FIX_TIMEOUT = 60                   -- seconds (60 seconds is the minimum allowed value for this property)

  -- terminal stationary, GPS signal good initially
  local InitialPosition = {
    speed = 0,                      -- kmh
    latitude = 1,                   -- degrees
    longitude = 1,                  -- degrees
    fixType = 3,                    -- valid fix
   }

  -- terminal in different position (no valid fix provided)
  local GpsBlockedPosition = {
    speed = 0,                      -- kmh
    latitude = 1,                   -- degrees
    longitude = 1,                  -- degrees
    fixType = 1,                    -- no fix
  }

  vmsSW:setPropertiesByName({GpsBlockedStartDebounceTime = GPS_BLOCKED_START_DEBOUNCE_TIME,
                             GpsBlockedEndDebounceTime = GPS_BLOCKED_END_DEBOUNCE_TIME,
                             GpsBlockedSendReport = true,
                             }
  )

  positionSW:setPropertiesByName({maxFixTimeout = MAX_FIX_TIMEOUT})

  -- *** Execute
  -- terminal in initial position, gps signal not blocked
  GPS:set(InitialPosition)
  gateway.setHighWaterMark() -- to get the newest messages
  -- GPS signal is blocked from now
  GPS:set(GpsBlockedPosition)

  -- waiting until MAX_FIX_TIMEOUT time passes - no new fix provided during this period
  framework.delay(MAX_FIX_TIMEOUT)

  -- AbnormalReport with GpsBlocked information is not expected
  local ReceivedMessages = vmsSW:waitForMessagesByName({"AbnormalReport"}, 10)

  -- back toinitial position, gps signal not blocked
  GPS:set(InitialPosition)

  -- checking if AbnormalReport related to GpsBlocked has not been sent by terminal
  if(ReceivedMessages["AbnormalReport"] ~= nil and ReceivedMessages["AbnormalReport"].EventType == "GpsBlocked" ) then
    assert_nil(1, "GpsBlocked abnormal report sent but not expected")
  end

end




--- TC checks if GpsBlocked AbnormalReport is not sent when GPS signal is good below GpsBlockedEndDebounceTime period for terminal in GpsBlocked state
  -- Initial Conditions:
  --
  -- * GPS signal is blocked
  -- * Terminal in GpsBlocked state
  --
  -- Steps:
  --
  -- 1. Set GpsBlockedStartDebounceTime to value A, GpsBlockedEndDebounceTime to value B and maxFixTimeout to 60 seconds
  -- 2. Enable sending GpsBlocked reports.
  -- 3. Simulate GPS signal blocked for time above maxFixTimeout and GpsBlockedStartDebounceTime.
  -- 4. Simulate GPS good.
  -- 4. Wait shorter than GpsBlockedEndDebounceTime and check if GpsBlocked AbnormalReport has not been sent.
  --
  -- Results:
  --
  -- 1. Settings applied successfully.
  -- 2. GpsBlockedSendReport set to true.
  -- 3. Terminal enters GpsBlocked state.
  -- 4. Valid fix is provided.
  -- 4. GpsBlocked AbnormalReport is not sent by terminal.
function test_GpsBlocked_ForTerminalInGpsBlockedStateWhenGpsSignalIsNotBlockedForTimeBelowGpsBlockedEndDebouncePeriod_GpsBlockedAbnormalReportIsNotSent()

  -- *** Setup
  local GPS_BLOCKED_START_DEBOUNCE_TIME = 1     -- seconds
  local GPS_BLOCKED_END_DEBOUNCE_TIME = 20      -- seconds
  local MAX_FIX_TIMEOUT = 60                    -- seconds (60 seconds is the minimum allowed value for this property)

  -- terminal stationary, GPS signal good initially
  local InitialPosition = {
    speed = 0,                      -- kmh
    latitude = 1,                   -- degrees
    longitude = 1,                  -- degrees
    fixType = 3,                    -- valid fix
   }

  -- terminal in different position (no valid fix provided)
  local GpsBlockedPosition = {
    speed = 0,                      -- kmh
    latitude = 1,                   -- degrees
    longitude = 1,                  -- degrees
    fixType = 1,                    -- no fix
  }

  vmsSW:setPropertiesByName({GpsBlockedStartDebounceTime = GPS_BLOCKED_START_DEBOUNCE_TIME,
                             GpsBlockedEndDebounceTime = GPS_BLOCKED_END_DEBOUNCE_TIME,
                             GpsBlockedSendReport = true,
                             }
  )

  positionSW:setPropertiesByName({maxFixTimeout = MAX_FIX_TIMEOUT})

  -- *** Execute
  -- terminal in initial position, gps signal not blocked
  GPS:set(InitialPosition)

  local GpsBlockedStateProperty = vmsSW:getPropertiesByName({"GpsBlockedState"})
  D:log(framework.dump(GpsBlockedStateProperty), "GpsBlockedStateProperty before GpsBlockedEndDebounceTime")
  assert_false(GpsBlockedStateProperty["GpsBlockedState"], "GpsBlockedState has not been changed when GPS blockage has been not detected")

  -- GPS signal is blocked from now
  GPS:set(GpsBlockedPosition)
  -- waiting until terminal goes to GpsBlocked = true state
  framework.delay(MAX_FIX_TIMEOUT + GPS_BLOCKED_START_DEBOUNCE_TIME)

  -- AbnormalReport is expected with GpsBlocked information
  local ReceivedMessages = vmsSW:waitForMessagesByName({"AbnormalReport"})
  assert_not_nil(ReceivedMessages["AbnormalReport"], "AbnormalReport not received")

  local GpsBlockedStateProperty = vmsSW:getPropertiesByName({"GpsBlockedState"})
  D:log(framework.dump(GpsBlockedStateProperty), "GpsBlockedStateProperty before GpsBlockedEndDebounceTime")
  assert_true(GpsBlockedStateProperty["GpsBlockedState"], "GpsBlockedState has not been changed when GPS blockage has been detected")

  gateway.setHighWaterMark() -- to get the newest messages
  -- back to initial position with good GPS signal quality
  GPS:set(InitialPosition)

  -- AbnormalReport with GpsBlocked information is not expected
  local ReceivedMessages = vmsSW:waitForMessagesByName({"AbnormalReport"}, 10)

  framework.delay(10) -- to let terminal go to GpsBlocked = false state (not to interrupt other TCs)

  -- checking if AbnormalReport related to GpsBlocked has not been sent by terminal
  if(ReceivedMessages["AbnormalReport"] ~= nil and ReceivedMessages["AbnormalReport"].EventType == "GpsBlocked" ) then
    assert_nil(1, "GpsBlocked abnormal report sent but not expected")
  end


end


function test_GpsBlocked_WhenGpsSignalIsBlocked_TimeStampsReportedInPeriodicReportsAreTheSame()

  -- TODO: random selection of number of Accelerated and Standard report may be added in the future - for now it runs on report number 1

  -- *** Setup
  local GPS_BLOCKED_START_DEBOUNCE_TIME = 400   -- seconds
  local GPS_BLOCKED_END_DEBOUNCE_TIME = 1       -- seconds
  local MAX_FIX_TIMEOUT = 60                    -- seconds (60 seconds is the minimum allowed value for this property)

  -- terminal stationary, GPS signal good initially
  local InitialPosition = {
    speed = 0,                      -- kmh
    latitude = 1,                   -- degrees
    longitude = 1,                  -- degrees
    fixType = 3,                    -- valid fix
   }

  -- terminal in different position (no valid fix provided)
  local GpsBlockedPosition = {
    speed = 0,                      -- kmh
    latitude = 1,                   -- degrees
    longitude = 1,                  -- degrees
    fixType = 1,                    -- no fix
  }

  vmsSW:setPropertiesByName({GpsBlockedStartDebounceTime = GPS_BLOCKED_START_DEBOUNCE_TIME,
                             GpsBlockedEndDebounceTime = GPS_BLOCKED_END_DEBOUNCE_TIME,
                             GpsBlockedSendReport = true,
                             StandardReport1Interval = 2,
                             AcceleratedReport1Rate = 2,
                            }
  )

  positionSW:setPropertiesByName({maxFixTimeout = MAX_FIX_TIMEOUT})

  -- *** Execute
  -- terminal in initial position, gps signal not blocked
  GPS:set(InitialPosition)
  -- GPS signal is blocked from now
  GPS:set(GpsBlockedPosition)

  -- waiting until MAX_FIX_TIMEOUT time passes - no new fix provided during this period
  framework.delay(MAX_FIX_TIMEOUT + 10)
  -----------------------------------------------------------------------------------------------------
  -- GPS is blocked but GPS_BLOCKED_START_DEBOUNCE_TIME has not passed
  -----------------------------------------------------------------------------------------------------
  gateway.setHighWaterMark() -- to get the newest messages
  -- Waiting for StandardReport
  local ReceivedMessages = vmsSW:waitForMessagesByName({"StandardReport1"}, 125)
  -- getting timestamp from first StandardReport
  local StandardReportTimestamp1 = tonumber(ReceivedMessages["StandardReport1"].Timestamp)
  -- waiting for AcceleratedReport
  ReceivedMessages = vmsSW:waitForMessagesByName({"AcceleratedReport1"}, 125)
  -- getting timestamp from first AcceleratedReport
  local AcceleratedReportTimestamp1 = tonumber(ReceivedMessages["AcceleratedReport1"].Timestamp)
  D:log({StandardReportTimestamp1, AcceleratedReportTimestamp1})

  gateway.setHighWaterMark() -- to get the newest messages
  ReceivedMessages = vmsSW:waitForMessagesByName({"StandardReport1"}, 125)
  local StandardReportTimestamp2 = tonumber(ReceivedMessages["StandardReport1"].Timestamp)
  ReceivedMessages = vmsSW:waitForMessagesByName({"AcceleratedReport1"}, 125)
  local AcceleratedReportTimestamp2 = tonumber(ReceivedMessages["AcceleratedReport1"].Timestamp)
  D:log({StandardReportTimestamp2, AcceleratedReportTimestamp2})

  -- timestamps are expected to be the same
  assert_equal(StandardReportTimestamp1,
               StandardReportTimestamp2,
               "When GPS is blocked but GPS_BLOCKED_START_DEBOUNCE_TIME has not passed StandardReports does not contain the same timestamps"
  )

  assert_equal(AcceleratedReportTimestamp1,
               AcceleratedReportTimestamp2,
               "When GPS is blocked but GPS_BLOCKED_START_DEBOUNCE_TIME has not passed AcceleratedReports does not contain the same timestamps"
  )

  -----------------------------------------------------------------------------------------------------
  -- waiting until GPS_BLOCKED_START_DEBOUNCE_TIME passes
  -----------------------------------------------------------------------------------------------------

  ReceivedMessages = vmsSW:waitForMessagesByName({"AbnormalReport"}, 200)

  local StatusBitmap = vmsSW:decodeBitmap(ReceivedMessages["AbnormalReport"].StatusBitmap, "EventStateId")
  assert_true(StatusBitmap["GpsBlocked"], "StatusBitmap has not been correctly changed when terminal detected GPS blockage")

  -----------------------------------------------------------------------------------------------------
  -- GPS is blocked and GPS_BLOCKED_START_DEBOUNCE_TIME has passed
  -----------------------------------------------------------------------------------------------------
  -- Waiting for StandardReport
  ReceivedMessages = vmsSW:waitForMessagesByName({"StandardReport1"}, 125)
  -- getting timestamp from first StandardReport
  StandardReportTimestamp1 = tonumber(ReceivedMessages["StandardReport1"].Timestamp)
  -- waiting for AcceleratedReport
  ReceivedMessages = vmsSW:waitForMessagesByName({"AcceleratedReport1"}, 125)
  -- getting timestamp from first AcceleratedReport
  AcceleratedReportTimestamp1 = tonumber(ReceivedMessages["AcceleratedReport1"].Timestamp)
  D:log({StandardReportTimestamp1, AcceleratedReportTimestamp1})

  framework.delay(65) -- wait for "next series" of Accelerated and Standard Reports

  gateway.setHighWaterMark() -- to get the newest messages
  ReceivedMessages = vmsSW:waitForMessagesByName({"StandardReport1"}, 125)
  StandardReportTimestamp2 = tonumber(ReceivedMessages["StandardReport1"].Timestamp)

  StatusBitmap = vmsSW:decodeBitmap(ReceivedMessages["StandardReport1"].StatusBitmap, "EventStateId")
  assert_true(StatusBitmap["GpsBlocked"], "StatusBitmap in StandardReport has not been correctly changed when terminal detected GPS blockage")

  ReceivedMessages = vmsSW:waitForMessagesByName({"AcceleratedReport1"}, 125)
  AcceleratedReportTimestamp2 = tonumber(ReceivedMessages["AcceleratedReport1"].Timestamp)

  StatusBitmap = vmsSW:decodeBitmap(ReceivedMessages["AcceleratedReport1"].StatusBitmap, "EventStateId")
  assert_true(StatusBitmap["GpsBlocked"], "StatusBitmap in AcceleratedReport has not been correctly changed when terminal detected GPS blockage")

  D:log({StandardReportTimestamp2, AcceleratedReportTimestamp2})

  -- timestamps are expected to be the same
  assert_not_equal(StandardReportTimestamp1,
                   StandardReportTimestamp2,
                  "When GPS is blocked and GPS_BLOCKED_START_DEBOUNCE_TIME has passed StandardReports still contain the same timestamps"
  )


  assert_not_equal(AcceleratedReportTimestamp1,
                   AcceleratedReportTimestamp2,
                   "When GPS is blocked and GPS_BLOCKED_START_DEBOUNCE_TIME has passed AcceleratedReports still contain the same timestamps"
  )

  -- back to good GPS quality
  GPS:set(InitialPosition)


end


function test_GpsBlocked_WhenGpsSignalIsBlockedAndNoFixWasObtainedByTerminal_DefaultValuesOfLattitudeAndLongitudeAreSentInReports()

  -- *** Setup
  local MAX_FIX_TIMEOUT = 60                   -- seconds (60 seconds is the minimum allowed value for this property)
  local PROPERTIES_SAVE_INTERVAL = 600         -- seconds

  -- terminal in some position but no valid fix provided
  local GpsBlockedPosition = {
                              speed = 0,                      -- kmh
                              latitude = 1,                   -- degrees
                              longitude = 1,                  -- degrees
                              fixType = 1,                    -- no fix
  }
  -- GPS signal is blocked from now - no fix provided
  GPS:set(GpsBlockedPosition)
  ----------------------------------------------------------------------------------------
  -- params.dat file should be deleted - no gps information should be there
  ----------------------------------------------------------------------------------------

  local deleteParamsFileMessage = {SIN = 26, MIN = 1}
	deleteParamsFileMessage.Fields = {{Name="tag",Value=0},{Name="data",Value="del /data/svc/VMS/params.dat"}}
	gateway.submitForwardMessage(deleteParamsFileMessage)

  -- This is an alternative way of deleting the file - that caused troubles
  --[[
  local deleteParamsFileMessage = {SIN = 24, MIN = 1}
	deleteParamsFileMessage.Fields = {{Name="path",Value="/data/svc/VMS/params.dat"},{Name="offset",Value=0},{Name="flags",Value="Truncate"},{Name="data",Value=""}}
	gateway.submitForwardMessage(deleteParamsFileMessage)
  --]]

  positionSW:setPropertiesByName({maxFixTimeout = 60,
                                  acquireTimeout = 1,
                                 })

  vmsSW:setPropertiesByName({
                             StandardReport1Interval = 2,
                             AcceleratedReport1Rate = 2,
                            }, false, true
  )

  -- systemSW:restartService(positionSW.sin)

  D:log(os.time(), "restart performed")
  systemSW:restartFramework()
  D:log(os.time(), "after restart")

  -- *** Execute
  gateway.setHighWaterMark() -- to get the newest messages
  -- Waiting for StandardReport
  local ReceivedMessages1 = vmsSW:waitForMessagesByName({"StandardReport1"}, PROPERTIES_SAVE_INTERVAL)
  D:log(ReceivedMessages1["StandardReport1"])

  local ReceivedMessages2 = vmsSW:waitForMessagesByName({"AcceleratedReport1"}, PROPERTIES_SAVE_INTERVAL)
  D:log(ReceivedMessages2["AcceleratedReport1"])

  assert_not_nil(ReceivedMessages1["StandardReport1"], "StandardReport1 not received")
  assert_not_nil(ReceivedMessages1["AcceleratedReport1"], "AcceleratedReport1 not received")

  assert_equal(
    5460000,
    tonumber(ReceivedMessages1["StandardReport1"].Latitude),
    "Wrong latitude value in StandardReport received when no fix has been obtained by terminal"
  )

  assert_equal(
    10860000,
    tonumber(ReceivedMessages1["StandardReport1"].Longitude),
    "Wrong longitude value in StandardReport received when no fix has been obtained by terminal"
  )

  assert_equal(
    361,
    tonumber(ReceivedMessages1["StandardReport1"].Course),
    "Wrong Course value in StandardReport received when no fix has been obtained by terminal"
  )

  assert_equal(
    0,
    tonumber(ReceivedMessages1["StandardReport1"].Speed),
    "Wrong Speed value in StandardReport received when no fix has been obtained by terminal"
  )


  assert_equal(
    5460000,
    tonumber(ReceivedMessages2["AcceleratedReport1"].Latitude),
    "Wrong latitude value in AcceleratedReport received when no fix has been obtained by terminal"
  )

  assert_equal(
    10860000,
    tonumber(ReceivedMessages2["AcceleratedReport1"].Longitude),
    "Wrong longitude value in AcceleratedReport received when no fix has been obtained by terminal"
  )

  assert_equal(
    361,
    tonumber(ReceivedMessages2["AcceleratedReport1"].Course),
    "Wrong Course value in AcceleratedReport received when no fix has been obtained by terminal"
  )

  assert_equal(
    0,
    tonumber(speed["AcceleratedReport1"].Speed),
    "Wrong longitude value in AcceleratedReport received when no fix has been obtained by terminal"
  )



end



--- TC checks if IdpBlocked AbnormalReport is sent when Satellite Control State is not active for time above IdpBlockedStartDebounceTime period
  -- Initial Conditions:
  --
  -- * Satellite Control State is active
  -- * Terminal not in IdpBlocked state
  --
  -- Steps:
  --
  -- 1. Set IdpBlockedStartDebounceTime to value A, IdpBlockedEndDebounceTime to value B
  -- 2. Enable sending IdpBlocked reports.
  -- 3. Simulate terminal in InitialPosition with Satellite Control State = not active.
  -- 4. Check IdpBlockedState property before IdpBlockedStartDebounceTime passes.
  -- 5. Wait longer than IdpBlockedStartDebounceTime and check if IdpBlocked AbnormalReport has been sent.
  -- 6. Check the content of the AbnormalReport.
  -- 7. Check the StatusBitmap in the AbnormalReport.
  -- 8. Check the IdpBlockedState property.
  --
  -- Results:
  --
  -- 1. Settings applied successfully.
  -- 2. IdpBlockedSendReport set to true.
  -- 3. Terminal in InitialPosition with Satellite Control State = not active.
  -- 4. IdpBlockedState property is expected to be false before IdpBlockedStartDebounceTime passes.
  -- 5. AbnormalReport with IdpBlocked information is sent after IdpBlockedStartDebounceTime.
  -- 7. IdpBlocked AbnormalReport contains all the required information.
  -- 8. IdpBlocked bit in StatusBitmap is set to true.
  -- 9. IdpBlockedState is true after IdpBlockedStartDebounceTime has passed.
function test_IdpBlocked_WhenSatelliteControlStateIsNotActiveForTimeAboveIdpBlockedStartDebouncePeriod_IdpBlockedAbnormalReportIsSent()

  -- device profile application
  if IDPBlockageFeaturesImplemented == false then skip("API for setting Satellite Control State has not been implemented yet - no use to perform TC") end

  -- *** Setup
  local IDP_BLOCKED_START_DEBOUNCE_TIME = 20   -- seconds
  local IDP_BLOCKED_END_DEBOUNCE_TIME = 1      -- seconds

  -- terminal stationary
  local InitialPosition = {
    speed = 0,                      -- kmh
    latitude = 1,                   -- degrees
    longitude = 1,                  -- degrees
  }

  vmsSW:setPropertiesByName({IdpBlockedStartDebounceTime = IDP_BLOCKED_START_DEBOUNCE_TIME,
                             IdpBlockedEndDebounceTime = IDP_BLOCKED_END_DEBOUNCE_TIME,
                             IdpBlockedSendReport = true,
                             }
  )



  -- TODO: uncomment this section when the funtions are implemented
  -- SatelliteControlState("Active")
  framework.delay(IDP_BLOCKED_END_DEBOUNCE_TIME)   -- wait until terminal goes back to IdpBlocked = false state


  -- terminal in initial position, Satellite Control State is Active now (IDP not blocked)
  GPS:set(InitialPosition)

  -- *** Execute
  gateway.setHighWaterMark() -- to get the newest messages
  -- Satellite Control State is not Active now - IDP blockage starts
  -- TODO: uncomment this section when the funtions are implemented
  -- SatelliteControlState("NotActive")

  -- checking IdpBlockedState property - this is expected to be false before IDP_BLOCKED_START_DEBOUNCE_TIME period passes
  local IdpBlockedStateProperty = vmsSW:getPropertiesByName({"IdpBlockedState"})
  assert_false(IdpBlockedStateProperty["IdpBlockedState"], "IdpBlockedState has been changed before IdpBlockedStartDebounceTime has passed")
  D:log(IdpBlockedStateProperty, "IdpBlockedStateProperty before IdpBlockedStartDebounceTime")

  framework.delay(IDP_BLOCKED_START_DEBOUNCE_TIME)

  local timeOfEvent = os.time()  -- to get exact timestamp
  D:log(timeOfEvent)

  -- AbnormalReport is expected with IdpBlocked information
  local ReceivedMessages = vmsSW:waitForMessagesByName({"AbnormalReport"})
  local IdpBlockedStateProperty = vmsSW:getPropertiesByName({"IdpBlockedState"})

  -- Back to Satellite Control State = Active
  -- TODO: uncomment this section when the funtions are implemented
  -- SatelliteControlState("Active")
  framework.delay(IDP_BLOCKED_END_DEBOUNCE_TIME)   -- wait until terminal goes back to IdpBlocked = false state

  assert_not_nil(ReceivedMessages["AbnormalReport"], "AbnormalReport not received")

  -- checking IdpBlockedState property - this is expected to be true as IDP_BLOCKED_START_DEBOUNCE_TIME period has passed
  assert_true(IdpBlockedStateProperty["IdpBlockedState"], "IdpBlockedState property has not been changed correctly when ")
  D:log(IdpBlockedStateProperty, "IdpBlockedStateProperty after IdpBlockedStartDebounceTime")

  assert_equal(
    InitialPosition.latitude*60000,
    tonumber(ReceivedMessages["AbnormalReport"].Latitude),
    "Wrong latitude value in IdpBlocked abnormal report"
  )

  assert_equal(
    InitialPosition.longitude*60000,
    tonumber(ReceivedMessages["AbnormalReport"].Longitude),
    "Wrong longitude value in IdpBlocked abnormal report"
  )

  assert_equal(
    InitialPosition.speed,
    tonumber(ReceivedMessages["AbnormalReport"].Speed),
    "Wrong speed value in IdpBlocked abnormal report"
  )

  assert_equal(
    361,
    tonumber(ReceivedMessages["AbnormalReport"].Course),
    "Wrong course value in IdpBlocked abnormal report"
  )

  assert_equal(
    "IdpBlocked",
    ReceivedMessages["AbnormalReport"].EventType,
    "Wrong name of the received EventType in IdpBlocked abnormal report"
  )

  assert_equal(
    timeOfEvent,
    tonumber(ReceivedMessages["AbnormalReport"].Timestamp),
    20,
    "Wrong Timestamp value in IdpBlocked abnormal report"
  )

  -- TODO: update this after implementation in TestFramework file
  --[[
  assert_equal(
    InitialPosition.hdop,
    ReceivedMessages["AbnormalReport"].Hdop,
    "Wrong HDOP value in IdpBlocked abnormal report"
  )

  assert_equal(
    InitialPosition.idpsnr,
    ReceivedMessages["AbnormalReport"].IdpSnr,
    "Wrong IdpSnr value in IdpBlocked abnormal report"
  )

  assert_equal(
    InitialPosition.numsats,
    ReceivedMessages["AbnormalReport"].NumSats,
    "Wrong NumSats value in IdpBlocked abnormal report"
  )
  --]]


  local StatusBitmap = vmsSW:decodeBitmap(ReceivedMessages["AbnormalReport"].StatusBitmap, "EventStateId")
  assert_true(StatusBitmap["IdpBlocked"], "StatusBitmap has not been correctly changed when terminal detected IDP blockage")

end



--- TC checks if IdpBlocked AbnormalReport is not sent when Satellite Control State not active for time above IdpBlockedStartDebounceTime but IdpBlocked reports are disabled
  -- Initial Conditions:
  --
  -- * Satellite Control State is active
  -- * Terminal not in IdpBlocked state
  --
  -- Steps:
  --
  -- 1. Set IdpBlockedStartDebounceTime to value A, IdpBlockedEndDebounceTime to value B
  -- 2. Disable sending IdpBlocked reports.
  -- 3. Simulate terminal in InitialPosition with Satellite Control State = not active.
  -- 4. Wait longer than IdpBlockedStartDebounceTime.
  -- 5. Check if IdpBlocked AbnormalReport has not been sent.
  -- 6. Check IdpBlockedState property.
  --
  -- Results:
  --
  -- 1. Settings applied successfully.
  -- 2. IdpBlockedSendReport set to false.
  -- 3. Terminal in InitialPosition with Satellite Control State = not active.
  -- 4. Satellite Control State = not active longer than IdpBlockedStartDebounceTime.
  -- 5. AbnormalReport with IdpBlocked information is not sent after IdpBlockedStartDebounceTime.
  -- 6. IdpBlockedState is set to true after IdpBlockedStartDebounceTime.
function test_IdpBlocked_WhenSatelliteControlStateIsNotActiveForTimeAboveIdpBlockedStartDebouncePeriodButIdpBlockedReportsAreDisabled_IdpBlockedAbnormalReportIsNotSent()

  -- device profile application
  if IDPBlockageFeaturesImplemented == false then skip("API for setting Satellite Control State has not been implemented yet - no use to perform TC") end

  -- *** Setup
  local IDP_BLOCKED_START_DEBOUNCE_TIME = 1    -- seconds
  local IDP_BLOCKED_END_DEBOUNCE_TIME = 1      -- seconds

  -- terminal stationary
  local InitialPosition = {
    speed = 0,                      -- kmh
    latitude = 1,                   -- degrees
    longitude = 1,                  -- degrees
  }

  vmsSW:setPropertiesByName({IdpBlockedStartDebounceTime = IDP_BLOCKED_START_DEBOUNCE_TIME,
                             IdpBlockedEndDebounceTime = IDP_BLOCKED_END_DEBOUNCE_TIME,
                             IdpBlockedSendReport = false,
                             }
  )

  -- *** Execute

  -- TODO: uncomment this section when the funtions are implemented
  -- SatelliteControlState("Active")
  framework.delay(IDP_BLOCKED_END_DEBOUNCE_TIME)   -- wait until terminal goes back to IdpBlocked = false state

  gateway.setHighWaterMark() -- to get the newest messages
  -- Satellite Control State is not Active now - IDP blockage starts
  -- TODO: uncomment this section when the funtions are implemented
  -- SatelliteControlState("NotActive")

  framework.delay(IDP_BLOCKED_START_DEBOUNCE_TIME)

  -- AbnormalReport is not expected with IdpBlocked information
  local ReceivedMessages = vmsSW:waitForMessagesByName({"AbnormalReport"}, 15)
  local IdpBlockedStateProperty = vmsSW:getPropertiesByName({"IdpBlockedState"})

  -- Back to Satellite Control State = Active
  -- TODO: uncomment this section when the funtions are implemented
  -- SatelliteControlState("Active")
  framework.delay(IDP_BLOCKED_END_DEBOUNCE_TIME)   -- wait until terminal goes back to IdpBlocked = false state

  if(ReceivedMessages["AbnormalReport"] ~= nil and ReceivedMessages["AbnormalReport"].EventType == "IdpBlocked" ) then
    assert_nil(1, "IdpBlocked abnormal report sent but not expected")
  end

  assert__nil(ReceivedMessages["AbnormalReport"], "AbnormalReport not received")

  -- checking IdpBlockedState property - this is expected to be true as IDP_BLOCKED_START_DEBOUNCE_TIME period has passed
  assert_true(IdpBlockedStateProperty["IdpBlockedState"], "IdpBlockedState property has not been changed correctly when ")
  D:log(IdpBlockedStateProperty, "IdpBlockedStateProperty after IdpBlockedStartDebounceTime")


end





--- TC checks if IdpBlocked AbnormalReport is not sent when Satellite Control State is not active for time below IdpBlockedStartDebounceTime period
  -- Initial Conditions:
  --
  -- * Satellite Control State is active
  -- * Terminal not in IdpBlocked state
  --
  -- Steps:
  --
  -- 1. Set IdpBlockedStartDebounceTime to value A, IdpBlockedEndDebounceTime to value B
  -- 2. Enable sending IdpBlocked reports.
  -- 3. Simulate terminal in InitialPosition with Satellite Control State = not active.
  -- 4. Wait shorter than IdpBlockedStartDebounceTime and check if IdpBlocked report is not sent.
  -- 5. Simulate terminal in Satellite Control State = active.
  --
  -- Results:
  --
  -- 1. Settings applied successfully.
  -- 2. IdpBlockedSendReport set to true.
  -- 3. Terminal in InitialPosition with Satellite Control State = not active.
  -- 4. IdpBlocked repoort is not sent.
  -- 5. IDP signal quality good again.
function test_IdpBlocked_WhenSatelliteControlStateIsNotActiveForTimeBelowIdpBlockedStartDebouncePeriod_IdpBlockedAbnormalReportIsNotSent()

  -- device profile application
  if IDPBlockageFeaturesImplemented == false then skip("API for setting Satellite Control State has not been implemented yet - no use to perform TC") end

  -- *** Setup
  local IDP_BLOCKED_START_DEBOUNCE_TIME = 30    -- seconds
  local IDP_BLOCKED_END_DEBOUNCE_TIME = 1       -- seconds

  -- terminal stationary
  local InitialPosition = {
    speed = 0,                      -- kmh
    latitude = 1,                   -- degrees
    longitude = 1,                  -- degrees
  }

  vmsSW:setPropertiesByName({IdpBlockedStartDebounceTime = IDP_BLOCKED_START_DEBOUNCE_TIME,
                             IdpBlockedEndDebounceTime = IDP_BLOCKED_END_DEBOUNCE_TIME,
                             IdpBlockedSendReport = true,
                             }
  )


  -- TODO: uncomment this section when the funtions are implemented
  -- SatelliteControlState("Active")

  -- *** Execute
  gateway.setHighWaterMark() -- to get the newest messages
  -- Satellite Control State is not Active now - IDP blockage starts
  -- TODO: uncomment this section when the funtions are implemented
  -- SatelliteControlState("NotActive")

  -- AbnormalReport is not expected with IdpBlocked information - Satellite Control State was not Active for time shorter than IDP_BLOCKED_START_DEBOUNCE_TIME
  local ReceivedMessages = vmsSW:waitForMessagesByName({"AbnormalReport"}, 15)
  local IdpBlockedStateProperty = vmsSW:getPropertiesByName({"IdpBlockedState"})

  -- Back to Satellite Control State = Active
  -- TODO: uncomment this section when the funtions are implemented
  -- SatelliteControlState("Active")
  framework.delay(IDP_BLOCKED_END_DEBOUNCE_TIME)   -- wait until terminal goes back to IdpBlocked = false state


  if(ReceivedMessages["AbnormalReport"] ~= nil and ReceivedMessages["AbnormalReport"].EventType == "IdpBlocked" ) then
    assert_nil(1, "IdpBlocked abnormal report sent but not expected")
  end

   -- checking IdpBlockedState property - this is expected to be true as IDP_BLOCKED_START_DEBOUNCE_TIME period has passed
  assert_true(IdpBlockedStateProperty["IdpBlockedState"], "IdpBlockedState property has not been changed correctly when ")
  D:log(IdpBlockedStateProperty, "IdpBlockedStateProperty after IdpBlockedStartDebounceTime")


end



--- TC checks if IdpBlocked AbnormalReport is not sent when Satellite Control State not active for time above IdpBlockedStartDebounceTime but IdpBlocked reports are disabled
  -- Initial Conditions:
  --
  -- * Satellite Control State is active
  -- * Terminal not in IdpBlocked state
  --
  -- Steps:
  --
  -- 1. Set IdpBlockedStartDebounceTime to value A, IdpBlockedEndDebounceTime to value B
  -- 2. Disable sending IdpBlocked reports.
  -- 3. Simulate terminal in InitialPosition with Satellite Control State = not active.
  -- 4. Wait longer than IdpBlockedStartDebounceTime.
  -- 5. Check if IdpBlocked AbnormalReport has not been sent.
  -- 6. Check IdpBlockedState property.
  --
  -- Results:
  --
  -- 1. Settings applied successfully.
  -- 2. IdpBlockedSendReport set to false.
  -- 3. Terminal in InitialPosition with Satellite Control State = not active.
  -- 4. Satellite Control State = not active longer than IdpBlockedStartDebounceTime.
  -- 5. AbnormalReport with IdpBlocked information is not sent after IdpBlockedStartDebounceTime.
  -- 6. IdpBlockedState is set to true after IdpBlockedStartDebounceTime.
function test_IdpBlocked_ForTerminalInIdpBlockedStateWhenSatelliteControlStateIsActiveForTimeAboveIdpBlockedEndDebouncePeriod_IdpBlockedAbnormalReportIsSent()

  -- device profile application
  if IDPBlockageFeaturesImplemented == false then skip("API for setting Satellite Control State has not been implemented yet - no use to perform TC") end

  -- *** Setup
  local IDP_BLOCKED_START_DEBOUNCE_TIME = 1    -- seconds
  local IDP_BLOCKED_END_DEBOUNCE_TIME = 20      -- seconds

  -- terminal stationary
  local InitialPosition = {
    speed = 0,                      -- kmh
    latitude = 1,                   -- degrees
    longitude = 1,                  -- degrees
  }

  vmsSW:setPropertiesByName({IdpBlockedStartDebounceTime = IDP_BLOCKED_START_DEBOUNCE_TIME,
                             IdpBlockedEndDebounceTime = IDP_BLOCKED_END_DEBOUNCE_TIME,
                             IdpBlockedSendReport = true,
                             }
  )

  -- *** Execute

  -- terminal in initial position, Satellite Control State is Active now (IDP not blocked)
  GPS:set(InitialPosition)
  -- Satellite Control State is not Active now - IDP blockage starts
  -- TODO: uncomment this section when the funtions are implemented
  -- SatelliteControlState("NotActive")

  framework.delay(IDP_BLOCKED_START_DEBOUNCE_TIME)

  -- checking IdpBlockedState property - this is expected to be false before IDP_BLOCKED_START_DEBOUNCE_TIME period passes
  local IdpBlockedStateProperty = vmsSW:getPropertiesByName({"IdpBlockedState"})
  assert_true(IdpBlockedStateProperty["IdpBlockedState"], "Terminal not in IdpBlockedState")
  D:log(IdpBlockedStateProperty, "IdpBlockedStateProperty after IdpBlockedStartDebounceTime")

  -- Satellite Control State is Active now - IDP blockage ends
  -- TODO: uncomment this section when the funtions are implemented
  -- SatelliteControlState("Active")

  local timeOfEvent = os.time()  -- to get exact timestamp

  -- checking IdpBlockedState property - this is expected to be true before IDP_BLOCKED_END_DEBOUNCE_TIME period passes
  local IdpBlockedStateProperty = vmsSW:getPropertiesByName({"IdpBlockedState"})
  assert_true(IdpBlockedStateProperty["IdpBlockedState"], "Terminal IdpBlockedState before IDP_BLOCKED_END_DEBOUNCE_TIME has passed")
  D:log(IdpBlockedStateProperty, "IdpBlockedStateProperty after IdpBlockedStartDebounceTime")

  framework.delay(IDP_BLOCKED_END_DEBOUNCE_TIME)   -- wait until terminal goes back to IdpBlocked = false state
  -- AbnormalReport is expected with IdpBlocked information
  local ReceivedMessages = vmsSW:waitForMessagesByName({"AbnormalReport"})
  IdpBlockedStateProperty = vmsSW:getPropertiesByName({"IdpBlockedState"})

  assert_not_nil(ReceivedMessages["AbnormalReport"], "AbnormalReport not received")

  -- checking IdpBlockedState property - this is expected to be true as IDP_BLOCKED_END_DEBOUNCE_TIME period has passed
  assert_false(IdpBlockedStateProperty["IdpBlockedState"], "IdpBlockedState property has not been changed correctly when ")
  D:log(IdpBlockedStateProperty, "IdpBlockedStateProperty after IdpBlockedStartDebounceTime")

  assert_equal(
    InitialPosition.latitude*60000,
    tonumber(ReceivedMessages["AbnormalReport"].Latitude),
    "Wrong latitude value in IdpBlocked abnormal report"
  )

  assert_equal(
    InitialPosition.longitude*60000,
    tonumber(ReceivedMessages["AbnormalReport"].Longitude),
    "Wrong longitude value in IdpBlocked abnormal report"
  )

  assert_equal(
    InitialPosition.speed,
    tonumber(ReceivedMessages["AbnormalReport"].Speed),
    "Wrong speed value in IdpBlocked abnormal report"
  )

  assert_equal(
    361,
    tonumber(ReceivedMessages["AbnormalReport"].Course),
    "Wrong course value in IdpBlocked abnormal report"
  )

  assert_equal(
    "IdpBlocked",
    ReceivedMessages["AbnormalReport"].EventType,
    "Wrong name of the received EventType in IdpBlocked abnormal report"
  )

  assert_equal(
    timeOfEvent,
    tonumber(ReceivedMessages["AbnormalReport"].Timestamp),
    20,
    "Wrong Timestamp value in IdpBlocked abnormal report"
  )

  -- TODO: update this after implementation in TestFramework file
  --[[
  assert_equal(
    InitialPosition.hdop,
    ReceivedMessages["AbnormalReport"].Hdop,
    "Wrong HDOP value in IdpBlocked abnormal report"
  )

  assert_equal(
    InitialPosition.idpsnr,
    ReceivedMessages["AbnormalReport"].IdpSnr,
    "Wrong IdpSnr value in IdpBlocked abnormal report"
  )

  assert_equal(
    InitialPosition.numsats,
    ReceivedMessages["AbnormalReport"].NumSats,
    "Wrong NumSats value in IdpBlocked abnormal report"
  )
  --]]


  local StatusBitmap = vmsSW:decodeBitmap(ReceivedMessages["AbnormalReport"].StatusBitmap, "EventStateId")
  assert_false(StatusBitmap["IdpBlocked"], "StatusBitmap has not been correctly changed when terminal detected IDP blockage")

end



--- TC checks if IdpBlocked AbnormalReport is sent when Satellite Control State active for time above IdpBlockedEndDebounceTime for terminal in IdpBlocked state
  -- Initial Conditions:
  --
  -- * Satellite Control State is not active
  -- * Terminal in IdpBlocked state
  --
  -- Steps:
  --
  -- 1. Set IdpBlockedStartDebounceTime to value A, IdpBlockedEndDebounceTime to value B
  -- 2. Enable sending IdpBlocked reports.
  -- 3. Put terminal to IdpBlocked state.
  -- 4. Simulate Satellite Control State = active.
  -- 5. Before IdpBlockedEndDebounceTime time passes check IdpBlockedState property
  -- 6. Wait longer than IdpBlockedEndDebounceTime and receive IdpBlocked AbnormalReport
  -- 7. Verify the content of report, check IdpBlocked bit in it.
  -- 8. Check IdpBlockedState property.
  --
  -- Results:
  --
  -- 1. Settings applied successfully.
  -- 2. IdpBlockedSendReport set to true.
  -- 3. Terminal in IdpBlocked state.
  -- 4. Satellite Control State = active.
  -- 5. IdpBlockedState is true before IdpBlockedEndDebounceTime passes.
  -- 6. AbnormalReport with IdpBlocked information is sent after IdpBlockedEndDebounceTime.
  -- 7. Report contains all required information, IdpBlocked bit is set to false.
  -- 8. IdpBlockedState is set to false after IdpBlockedEndDebounceTime.
function test_IdpBlocked_ForTerminalInIdpBlockedStateWhenSatelliteControlStateIsActiveForTimeBelowIdpBlockedEndDebouncePeriod_IdpBlockedAbnormalReportIsNotSent()

  -- device profile application
  if IDPBlockageFeaturesImplemented == false then skip("API for setting Satellite Control State has not been implemented yet - no use to perform TC") end

  -- *** Setup
  local IDP_BLOCKED_START_DEBOUNCE_TIME = 1    -- seconds
  local IDP_BLOCKED_END_DEBOUNCE_TIME = 30      -- seconds

  -- terminal stationary
  local InitialPosition = {
    speed = 0,                      -- kmh
    latitude = 1,                   -- degrees
    longitude = 1,                  -- degrees
  }

  vmsSW:setPropertiesByName({IdpBlockedStartDebounceTime = IDP_BLOCKED_START_DEBOUNCE_TIME,
                             IdpBlockedEndDebounceTime = IDP_BLOCKED_END_DEBOUNCE_TIME,
                             IdpBlockedSendReport = true,
                             }
  )

  -- *** Execute

  -- terminal in initial position, Satellite Control State is Active now (IDP not blocked)
  GPS:set(InitialPosition)
  -- Satellite Control State is not Active now - IDP blockage starts
  -- TODO: uncomment this section when the funtions are implemented
  -- SatelliteControlState("NotActive")

  framework.delay(IDP_BLOCKED_START_DEBOUNCE_TIME)

  -- checking IdpBlockedState property - this is expected to be false before IDP_BLOCKED_START_DEBOUNCE_TIME period passes
  local IdpBlockedStateProperty = vmsSW:getPropertiesByName({"IdpBlockedState"})
  assert_true(IdpBlockedStateProperty["IdpBlockedState"], "Terminal not in IdpBlockedState")
  D:log(IdpBlockedStateProperty, "IdpBlockedStateProperty after IdpBlockedStartDebounceTime")

  -- Satellite Control State is Active now - IDP blockage ends
  -- TODO: uncomment this section when the funtions are implemented
  -- SatelliteControlState("Active")

  -- AbnormalReport is not expected with IdpBlocked information
  local ReceivedMessages = vmsSW:waitForMessagesByName({"AbnormalReport"}, 15)
  IdpBlockedStateProperty = vmsSW:getPropertiesByName({"IdpBlockedState"})

  framework.delay(IDP_BLOCKED_END_DEBOUNCE_TIME)   -- wait until terminal goes back to IdpBlocked = false state
  -- checking IdpBlockedState property - this is expected to be true as IDP_BLOCKED_END_DEBOUNCE_TIME period has not passed
  assert_true(IdpBlockedStateProperty["IdpBlockedState"], "IdpBlockedState property has been changed before IDP_BLOCKED_END_DEBOUNCE_TIME has passed")

  if(ReceivedMessages["AbnormalReport"] ~= nil and ReceivedMessages["AbnormalReport"].EventType == "IdpBlocked" ) then
    assert_nil(1, "IdpBlocked abnormal report sent but not expected")
  end

  IdpBlockedStateProperty = vmsSW:getPropertiesByName({"IdpBlockedState"})
  -- checking IdpBlockedState property - this is expected to be false as IDP_BLOCKED_END_DEBOUNCE_TIME period has passed
  assert_false(IdpBlockedStateProperty["IdpBlockedState"], "IdpBlockedState property has not been changed before IDP_BLOCKED_END_DEBOUNCE_TIME has passed")

  device.setIO(31, ext_voltage)    -- setting external power voltage (in eio service)

end





--- TC checks if PowerDisconnected AbnormalReport is sent when terminal is power cycled
  -- Initial Conditions:
  --
  -- * Satellite Control State is not active
  -- * Terminal in IdpBlocked state
  --
  -- Steps:
  --
  -- 1. Set IdpBlockedStartDebounceTime to value A, IdpBlockedEndDebounceTime to value B
  -- 2. Enable sending IdpBlocked reports.
  -- 3. Put terminal to IdpBlocked state.
  -- 4. Simulate Satellite Control State = active.
  -- 5. Before IdpBlockedEndDebounceTime time passes check IdpBlockedState property
  -- 6. Wait longer than IdpBlockedEndDebounceTime and receive IdpBlocked AbnormalReport
  -- 7. Verify the content of report, check IdpBlocked bit in it.
  -- 8. Check IdpBlockedState property.
  --
  -- Results:
  --
  -- 1. Settings applied successfully.
  -- 2. IdpBlockedSendReport set to true.
  -- 3. Terminal in IdpBlocked state.
  -- 4. Satellite Control State = active.
  -- 5. IdpBlockedState is true before IdpBlockedEndDebounceTime passes.
  -- 6. AbnormalReport with IdpBlocked information is sent after IdpBlockedEndDebounceTime.
  -- 7. Report contains all required information, IdpBlocked bit is set to false.
  -- 8. IdpBlockedState is set to false after IdpBlockedEndDebounceTime.
function test_PowerDisconnected_WhenTerminalIsPoweCycled_OnePowerDisconnectedAbnormalReportIsSentAfterPowerDisconnectedStartDebounceTimeAndSecondPowerDisconnectedAbnormalReportIsSentAfterPowerDisconnectedEndDebounceTime()

  -- *** Setup
  local POWER_DISCONNECTED_START_DEBOUNCE_TIME = 5    -- seconds
  local POWER_DISCONNECTED_END_DEBOUNCE_TIME = 60     -- seconds
  local PROPERTIES_SAVE_INTERVAL = 600                -- seconds

  -- terminal stationary
  local InitialPosition = {
    speed = 0,                      -- kmh
    latitude = 1,                   -- degrees
    longitude = 1,                  -- degrees
  }

  -- terminal stationary
  local AfterRebootPosition = {
    speed = 7,                      -- kmh
    latitude = 5,                   -- degrees
    longitude = 5,                  -- degrees
    heading = 90,                   -- degrees
  }

  vmsSW:setPropertiesByName({PowerDisconnectedStartDebounceTime = POWER_DISCONNECTED_START_DEBOUNCE_TIME,
                             PowerDisconnectedEndDebounceTime = POWER_DISCONNECTED_END_DEBOUNCE_TIME,
                             PowerDisconnectedSendReport = true,
                             }, false, true
  )

  -- *** Execute
  -- terminal in initial position
  GPS:set(InitialPosition)
  framework.delay(PROPERTIES_SAVE_INTERVAL + 5)
  gateway.setHighWaterMark() -- to get the newest messages
  framework.delay(POWER_DISCONNECTED_START_DEBOUNCE_TIME)

  -- checking PowerDisconnectedState property - this is expected to be false - terminal is powered on for time longer than
  local PowerDisconnectedStateProperty = vmsSW:getPropertiesByName({"PowerDisconnectedState"})
  assert_false(PowerDisconnectedStateProperty["PowerDisconnectedState"], "PowerDisconnectedState is incorrectly true")
  D:log(PowerDisconnectedStateProperty, "PowerDisconnectedStateProperty in the start of TC")

  systemSW:restartFramework()

  GPS:set(AfterRebootPosition)

  local terminalOnTimeStamp = os.time()  -- to get exact timestamp


  framework.delay(POWER_DISCONNECTED_END_DEBOUNCE_TIME + 5)

  -- receiving all from mobile messages sent after setHighWaterMark()
  local receivedMessages = gateway.getReturnMessages()
  -- look for AbnormalReport messages
  local AllReceivedAbnormalReports = framework.filterMessages(receivedMessages, framework.checkMessageType(115, 50)) -- TODO: service wrapper functions need to be modified

  local PowerDisconnectedAbnormalReportTrue = nil
  for index = 1 , #AllReceivedAbnormalReports, 1 do
    local StatusBitmap = vmsSW:decodeBitmap(AllReceivedAbnormalReports[index].Payload.StatusBitmap, "EventStateId")
    D:log(StatusBitmap["PowerDisconnected"] )
    if AllReceivedAbnormalReports[index].Payload.EventType == "PowerDisconnected" and StatusBitmap["PowerDisconnected"] == true then
        PowerDisconnectedAbnormalReportTrue = AllReceivedAbnormalReports[index]
        break
    end
  end

  local PowerDisconnectedAbnormalReportFalse = nil
  for index = 1 , #AllReceivedAbnormalReports, 1 do
    local StatusBitmap = vmsSW:decodeBitmap(AllReceivedAbnormalReports[index].Payload.StatusBitmap, "EventStateId")
    D:log(StatusBitmap["PowerDisconnected"] )
    if AllReceivedAbnormalReports[index].Payload.EventType == "PowerDisconnected" and StatusBitmap["PowerDisconnected"] == true then
        PowerDisconnectedAbnormalReportFalse = AllReceivedAbnormalReports[index]
        break
    end
  end

  D:log(PowerDisconnectedAbnormalReportTrue)
  D:log(PowerDisconnectedAbnormalReportFalse)

  assert_not_nil(PowerDisconnectedAbnormalReportFalse, "AbnormalReport with PowerDisconnected bit = false not received")
  assert_not_nil(PowerDisconnectedAbnormalReportTrue, "AbnormalReport  with PowerDisconnected bit = true not received")

  assert_equal(
    AfterRebootPosition.latitude*60000,
    tonumber(PowerDisconnectedAbnormalReportFalse.Payload.Latitude),
    "Wrong latitude value in PowerDisconnected abnormal report"
  )

  assert_equal(
    AfterRebootPosition.longitude*60000,
    tonumber(PowerDisconnectedAbnormalReportFalse.Payload.Longitude),
    "Wrong longitude value in PowerDisconnected abnormal report"
  )

  assert_equal(
    AfterRebootPosition.speed*5.39956803,
    tonumber(PowerDisconnectedAbnormalReportFalse.Payload.Speed),
    2,
    "Wrong speed value in PowerDisconnected abnormal report"
  )

  assert_equal(
    AfterRebootPosition.heading,
    tonumber(PowerDisconnectedAbnormalReportFalse.Payload.Course),
    "Wrong course value in PowerDisconnected abnormal report"
  )

  assert_equal(
    terminalOnTimeStamp + POWER_DISCONNECTED_START_DEBOUNCE_TIME,
    tonumber(PowerDisconnectedAbnormalReportTrue.Payload.Timestamp),
    20,
    "Wrong Timestamp value in PowerDisconnected abnormal report"
  )

  -- TODO: update this after implementation in TestFramework file
  --[[
  assert_equal(
    InitialPosition.hdop,
    PowerDisconnectedAbnormalReportFalse.Payload.Hdop,
    "Wrong HDOP value in IdpBlocked abnormal report"
  )

  assert_equal(
    InitialPosition.idpsnr,
    PowerDisconnectedAbnormalReportFalse.Payload.IdpSnr,
    "Wrong IdpSnr value in IdpBlocked abnormal report"
  )

  assert_equal(
    InitialPosition.numsats,
    PowerDisconnectedAbnormalReportFalse.Payload.NumSats,
    "Wrong NumSats value in IdpBlocked abnormal report"
  )
  --]]

  assert_equal(
    InitialPosition.latitude*60000,
    tonumber(PowerDisconnectedAbnormalReportTrue.Payload.Latitude),
    "Wrong latitude value in PowerDisconnected abnormal report send after POWER_DISCONNECTED_END_DEBOUNCE_TIME"
  )

  assert_equal(
    InitialPosition.longitude*60000,
    tonumber(PowerDisconnectedAbnormalReportTrue.Payload.Longitude),
    "Wrong longitude value in PowerDisconnected abnormal report send after POWER_DISCONNECTED_END_DEBOUNCE_TIME"
  )

  assert_equal(
    InitialPosition.speed,
    tonumber(PowerDisconnectedAbnormalReportTrue.Payload.Speed),
    "Wrong speed value in PowerDisconnected abnormal report send after POWER_DISCONNECTED_END_DEBOUNCE_TIME"
  )

  assert_equal(
    361,
    tonumber(PowerDisconnectedAbnormalReportTrue.Payload.Course),
    "Wrong course value in PowerDisconnected abnormal report send after POWER_DISCONNECTED_END_DEBOUNCE_TIME"
  )

  -- TODO: update this after implementation in TestFramework file
  --[[
  assert_equal(
    InitialPosition.hdop,
    PowerDisconnectedAbnormalReportTrue.Payload.Hdop,
    "Wrong HDOP value in IdpBlocked abnormal report"
  )

  assert_equal(
    InitialPosition.idpsnr,
    PowerDisconnectedAbnormalReportTrue.Payload.IdpSnr,
    "Wrong IdpSnr value in IdpBlocked abnormal report"
  )

  assert_equal(
    InitialPosition.numsats,
    PowerDisconnectedAbnormalReportTrue.Payload.NumSats,
    "Wrong NumSats value in IdpBlocked abnormal report"
  )
  --]]



end



function test_ExtPowerDisconnected_WhenHelmPanelIsConnectedToExternalPowerSourceForTimeAboveExtPowerDisconnectedEndDebounceTime_ExtPowerDisconnectedAbnormalReportIsSent()

  local EXT_POWER_DISCONNECTED_START_DEBOUNCE_TIME = 1
  local EXT_POWER_DISCONNECTED_END_DEBOUNCE_TIME = 30

  -- *** Setup
  -- terminal in some position but no valid fix provided
  local InitialPosition = {
                              speed = 0,                      -- kmh
                              latitude = 1,                   -- degrees
                              longitude = 1,                  -- degrees
                              fixType = 3,                    -- valid fix
  }

  vmsSW:setPropertiesByName({
                             ExtPowerDisconnectedStartDebounceTime = EXT_POWER_DISCONNECTED_START_DEBOUNCE_TIME,
                             ExtPowerDisconnectedEndDebounceTime = EXT_POWER_DISCONNECTED_END_DEBOUNCE_TIME,
                             ExtPowerDisconnectedSendReport = true,
                            }
  )

  -- *** Execute
  GPS:set(InitialPosition)

  -- checking ExtPowerDisconnectedState property
  local ExtPowerDisconnectedStateProperty = vmsSW:getPropertiesByName({"ExtPowerDisconnectedState"})
  D:log(framework.dump(ExtPowerDisconnectedStateProperty["ExtPowerDisconnectedState"]), "ExtPowerDisconnectedState")
  assert_true(ExtPowerDisconnectedStateProperty["ExtPowerDisconnectedState"], "ExtPowerDisconnectedState property is incorrectly false")


  gateway.setHighWaterMark() -- to get the newest messages
  -- Helm Panel is connected to external power from now
  helmPanel:externalPowerConnected("true")

  D:log("EXTERNAL POWER SOURCE OF HELM PANEL CONNECTED")

  -- checking ExtPowerDisconnectedState property
  local ExtPowerDisconnectedStateProperty = vmsSW:getPropertiesByName({"ExtPowerDisconnectedState"})
  D:log(framework.dump(ExtPowerDisconnectedStateProperty["ExtPowerDisconnectedState"]), "ExtPowerDisconnectedState")
  assert_true(ExtPowerDisconnectedStateProperty["ExtPowerDisconnectedState"], "ExtPowerDisconnectedState has changed to false before ExtPowerDisconnectedEndDebounceTime time has passed")

  framework.delay(EXT_POWER_DISCONNECTED_END_DEBOUNCE_TIME)


  timeOfEvent = os.time()

  local ReceivedMessages = vmsSW:waitForMessagesByName({"AbnormalReport"})
  D:log(ReceivedMessages["AbnormalReport"])

  assert_not_nil(ReceivedMessages["AbnormalReport"], "AbnormalReport not received")

  assert_equal(
    InitialPosition.latitude*60000,
    tonumber(ReceivedMessages["AbnormalReport"].Latitude),
    "Wrong latitude value in ExtPowerDisconnected abnormal report"
  )

  assert_equal(
    InitialPosition.longitude*60000,
    tonumber(ReceivedMessages["AbnormalReport"].Longitude),
    "Wrong longitude value in ExtPowerDisconnected abnormal report"
  )

  assert_equal(
    InitialPosition.speed,
    tonumber(ReceivedMessages["AbnormalReport"].Speed),
    "Wrong speed value in ExtPowerDisconnected abnormal report"
  )

  assert_equal(
    361,
    tonumber(ReceivedMessages["AbnormalReport"].Course),
    "Wrong course value in ExtPowerDisconnected abnormal report"
  )

  assert_equal(
    "ExtPowerDisconnected",
    ReceivedMessages["AbnormalReport"].EventType,
    "Wrong name of the received EventType in ExtPowerDisconnected abnormal report"
  )

  assert_equal(
    timeOfEvent,
    tonumber(ReceivedMessages["AbnormalReport"].Timestamp),
    10,
    "Wrong Timestamp value in ExtPowerDisconnected abnormal report"
  )
  --]]
  -- TODO: update this after implementation in TestFramework file
  --[[
  assert_equal(
    InitialPosition.hdop,
    PowerDisconnectedAbnormalReport.Payload.Hdop,
    "Wrong HDOP value in IdpBlocked abnormal report"
  )

  assert_equal(
    InitialPosition.idpsnr,
    PowerDisconnectedAbnormalReport.Payload.IdpSnr,
    "Wrong IdpSnr value in IdpBlocked abnormal report"
  )

  assert_equal(
    InitialPosition.numsats,
    PowerDisconnectedAbnormalReport.Payload.NumSats,
    "Wrong NumSats value in IdpBlocked abnormal report"
  )
  --]]

  local StatusBitmap = vmsSW:decodeBitmap(ReceivedMessages["AbnormalReport"].StatusBitmap, "EventStateId")
  assert_false(StatusBitmap["ExtPowerDisconnected"], "StatusBitmap has not been correctly changed to false when external power source of helm panel was connected")


  D:log("EXTERNAL POWER SOURCE OF HELM PANEL DISCONNECTED")

  -- back to exernal power disconnected
  helmPanel:externalPowerConnected("false")

end



function test_ExtPowerDisconnected_WhenHelmPanelIsDisconnectedFromExternalPowerSourceForTimeAboveExtPowerDisconnectedStartDebounceTime_ExtPowerDisconnectedAbnormalReportIsSent()

  local EXT_POWER_DISCONNECTED_START_DEBOUNCE_TIME = 30
  local EXT_POWER_DISCONNECTED_END_DEBOUNCE_TIME = 1

  -- *** Setup
  -- terminal in some position but no valid fix provided
  local InitialPosition = {
                              speed = 0,                      -- kmh
                              latitude = 1,                   -- degrees
                              longitude = 1,                  -- degrees
                              fixType = 3,                    -- valid fix
  }

  vmsSW:setPropertiesByName({
                             ExtPowerDisconnectedStartDebounceTime = EXT_POWER_DISCONNECTED_START_DEBOUNCE_TIME,
                             ExtPowerDisconnectedEndDebounceTime = EXT_POWER_DISCONNECTED_END_DEBOUNCE_TIME,
                             ExtPowerDisconnectedSendReport = true,
                            }
  )

  -- *** Execute
  GPS:set(InitialPosition)

  -- checking ExtPowerDisconnectedState property
  local ExtPowerDisconnectedStateProperty = vmsSW:getPropertiesByName({"ExtPowerDisconnectedState"})
  D:log(framework.dump(ExtPowerDisconnectedStateProperty["ExtPowerDisconnectedState"]), "ExtPowerDisconnectedState")
  assert_true(ExtPowerDisconnectedStateProperty["ExtPowerDisconnectedState"], "ExtPowerDisconnectedState property is incorrectly false")

  D:log("EXTERNAL POWER SOURCE OF HELM PANEL CONNECTED")
  -- Helm Panel is connected to external power from now
  helmPanel:externalPowerConnected("true")

  framework.delay(EXT_POWER_DISCONNECTED_END_DEBOUNCE_TIME)

  framework.delay(10) -- this delay is added due to TC failing for too many messages processes at once

  -- checking ExtPowerDisconnectedState property
  ExtPowerDisconnectedStateProperty = vmsSW:getPropertiesByName({"ExtPowerDisconnectedState"})
  D:log(framework.dump(ExtPowerDisconnectedStateProperty["ExtPowerDisconnectedState"]), "ExtPowerDisconnectedStateProperty" )
  assert_false(ExtPowerDisconnectedStateProperty["ExtPowerDisconnectedState"], "ExtPowerDisconnectedState property is incorrectly true")

  gateway.setHighWaterMark() -- to get the newest messages

  D:log("EXTERNAL POWER SOURCE OF HELM PANEL DISCONNECTED")
  -- Helm Panel is disconnected from external power from now
  helmPanel:externalPowerConnected("false")

  -- checking ExtPowerDisconnectedState property
  ExtPowerDisconnectedStateProperty = vmsSW:getPropertiesByName({"ExtPowerDisconnectedState"})
  D:log(framework.dump(ExtPowerDisconnectedStateProperty["ExtPowerDisconnectedState"]), "ExtPowerDisconnectedStateProperty")
  assert_false(ExtPowerDisconnectedStateProperty["ExtPowerDisconnectedState"], "ExtPowerDisconnectedState has changed to true before ExtPowerDisconnectedStartDebounceTime time has passed")

  framework.delay(EXT_POWER_DISCONNECTED_START_DEBOUNCE_TIME)
  timeOfEvent = os.time()

  local ReceivedMessages = vmsSW:waitForMessagesByName({"AbnormalReport"})
  D:log(ReceivedMessages["AbnormalReport"])

  -- checking ExtPowerDisconnectedState property
  ExtPowerDisconnectedStateProperty = vmsSW:getPropertiesByName({"ExtPowerDisconnectedState"})
  D:log(framework.dump(ExtPowerDisconnectedStateProperty["ExtPowerDisconnectedState"]), "ExtPowerDisconnectedState")
  assert_true(ExtPowerDisconnectedStateProperty["ExtPowerDisconnectedState"], "ExtPowerDisconnectedState property is incorrectly false after ExtPowerDisconnectedStartDebounceTime")

  assert_not_nil(ReceivedMessages["AbnormalReport"], "AbnormalReport not received")

  assert_equal(
    InitialPosition.latitude*60000,
    tonumber(ReceivedMessages["AbnormalReport"].Latitude),
    "Wrong latitude value in ExtPowerDisconnected abnormal report"
  )

  assert_equal(
    InitialPosition.longitude*60000,
    tonumber(ReceivedMessages["AbnormalReport"].Longitude),
    "Wrong longitude value in ExtPowerDisconnected abnormal report"
  )

  assert_equal(
    InitialPosition.speed,
    tonumber(ReceivedMessages["AbnormalReport"].Speed),
    "Wrong speed value in ExtPowerDisconnected abnormal report"
  )

  assert_equal(
    361,
    tonumber(ReceivedMessages["AbnormalReport"].Course),
    "Wrong course value in ExtPowerDisconnected abnormal report"
  )

  assert_equal(
    "ExtPowerDisconnected",
    ReceivedMessages["AbnormalReport"].EventType,
    "Wrong name of the received EventType in ExtPowerDisconnected abnormal report"
  )

  assert_equal(
    timeOfEvent,
    tonumber(ReceivedMessages["AbnormalReport"].Timestamp),
    10,
    "Wrong Timestamp value in ExtPowerDisconnected abnormal report"
  )
  --]]
  -- TODO: update this after implementation in TestFramework file
  --[[
  assert_equal(
    InitialPosition.hdop,
    PowerDisconnectedAbnormalReport.Payload.Hdop,
    "Wrong HDOP value in IdpBlocked abnormal report"
  )

  assert_equal(
    InitialPosition.idpsnr,
    PowerDisconnectedAbnormalReport.Payload.IdpSnr,
    "Wrong IdpSnr value in IdpBlocked abnormal report"
  )

  assert_equal(
    InitialPosition.numsats,
    PowerDisconnectedAbnormalReport.Payload.NumSats,
    "Wrong NumSats value in IdpBlocked abnormal report"
  )
  --]]


  local StatusBitmap = vmsSW:decodeBitmap(ReceivedMessages["AbnormalReport"].StatusBitmap, "EventStateId")
  assert_true(StatusBitmap["ExtPowerDisconnected"], "StatusBitmap has not been correctly changed to true when external power source of helm panel was disconnected")


end


function test_ExtPowerDisconnected_WhenHelmPanelIsConnectedToExternalPowerSourceForTimeBelowExtPowerDisconnectedEndDebounceTime_ExtPowerDisconnectedAbnormalReportIsNotSent()

  local EXT_POWER_DISCONNECTED_START_DEBOUNCE_TIME = 1
  local EXT_POWER_DISCONNECTED_END_DEBOUNCE_TIME = 30

  -- *** Setup
  -- terminal in some position but no valid fix provided
  local InitialPosition = {
                              speed = 0,                      -- kmh
                              latitude = 1,                   -- degrees
                              longitude = 1,                  -- degrees
                              fixType = 3,                    -- valid fix
  }

  vmsSW:setPropertiesByName({
                             ExtPowerDisconnectedStartDebounceTime = EXT_POWER_DISCONNECTED_START_DEBOUNCE_TIME,
                             ExtPowerDisconnectedEndDebounceTime = EXT_POWER_DISCONNECTED_END_DEBOUNCE_TIME,
                             ExtPowerDisconnectedSendReport = true,
                            }
  )

  -- *** Execute
  GPS:set(InitialPosition)

  -- checking ExtPowerDisconnectedState property
  local ExtPowerDisconnectedStateProperty = vmsSW:getPropertiesByName({"ExtPowerDisconnectedState"})
  D:log(framework.dump(ExtPowerDisconnectedStateProperty["ExtPowerDisconnectedState"]), "ExtPowerDisconnectedState")
  assert_true(ExtPowerDisconnectedStateProperty["ExtPowerDisconnectedState"], "ExtPowerDisconnectedState property is incorrectly false")

  gateway.setHighWaterMark() -- to get the newest messages
  D:log("EXTERNAL POWER SOURCE OF HELM PANEL CONNECTED")
  -- Helm Panel is connected to external power from now
  helmPanel:externalPowerConnected("true")

  local ReceivedMessages = vmsSW:waitForMessagesByName({"AbnormalReport"}, 15)
  D:log(ReceivedMessages["AbnormalReport"])

  if(ReceivedMessages["AbnormalReport"] ~= nil and ReceivedMessages["AbnormalReport"].EventType == "ExtPowerDisconnected" ) then
    assert_nil(1, "ExtPowerDisconnected abnormal report sent but not expected")
  end

  D:log("EXTERNAL POWER SOURCE OF  HELM PANEL DISCONNECTED")
  -- back to exernal power disconnected
  helmPanel:externalPowerConnected("false")


end


function test_ExtPowerDisconnected_WhenHelmPanelIsDisonnectedFromExternalPowerSourceForTimeBelowExtPowerDisconnectedStartDebounceTime_ExtPowerDisconnectedAbnormalReportIsNotSent()

  local EXT_POWER_DISCONNECTED_START_DEBOUNCE_TIME = 30
  local EXT_POWER_DISCONNECTED_END_DEBOUNCE_TIME = 1

  -- *** Setup
  -- terminal in some position but no valid fix provided
  local InitialPosition = {
                              speed = 0,                      -- kmh
                              latitude = 1,                   -- degrees
                              longitude = 1,                  -- degrees
                              fixType = 3,                    -- valid fix
  }

  vmsSW:setPropertiesByName({
                             ExtPowerDisconnectedStartDebounceTime = EXT_POWER_DISCONNECTED_START_DEBOUNCE_TIME,
                             ExtPowerDisconnectedEndDebounceTime = EXT_POWER_DISCONNECTED_END_DEBOUNCE_TIME,
                             ExtPowerDisconnectedSendReport = true,
                            }
  )

  -- *** Execute
  GPS:set(InitialPosition)

  -- checking ExtPowerDisconnectedState property
  local ExtPowerDisconnectedStateProperty = vmsSW:getPropertiesByName({"ExtPowerDisconnectedState"})
  D:log(framework.dump(ExtPowerDisconnectedStateProperty["ExtPowerDisconnectedState"]), "ExtPowerDisconnectedState")
  assert_true(ExtPowerDisconnectedStateProperty["ExtPowerDisconnectedState"], "ExtPowerDisconnectedState property is incorrectly false")

  D:log("HELM PANEL CONNECTED")
  -- Helm Panel is connected to external power from now
  helmPanel:externalPowerConnected("true")

  framework.delay(EXT_POWER_DISCONNECTED_END_DEBOUNCE_TIME)

  -- checking ExtPowerDisconnectedState property
  local ExtPowerDisconnectedStateProperty = vmsSW:getPropertiesByName({"ExtPowerDisconnectedState"})
  D:log(framework.dump(ExtPowerDisconnectedStateProperty["ExtPowerDisconnectedState"]), "ExtPowerDisconnectedStateProperty" )
  assert_false(ExtPowerDisconnectedStateProperty["ExtPowerDisconnectedState"], "ExtPowerDisconnectedState property is incorrectly true")

  gateway.setHighWaterMark() -- to get the newest messages
  D:log("EXTERNAL POWER SOURCE OF HELM PANEL DISCONNECTED")
  -- Helm Panel is disconnected from external power from now
  helmPanel:externalPowerConnected("false")

  local ReceivedMessages = vmsSW:waitForMessagesByName({"AbnormalReport"}, 15)
  D:log(ReceivedMessages["AbnormalReport"])


  if(ReceivedMessages["AbnormalReport"] ~= nil and ReceivedMessages["AbnormalReport"].EventType == "ExtPowerDisconnected" ) then
    assert_nil(1, "ExtPowerDisconnected abnormal report sent but not expected")
  end

  framework.delay(EXT_POWER_DISCONNECTED_START_DEBOUNCE_TIME)


end


function test_ExtPowerDisconnected_WhenExternalPowerIsConnectedAndDisconnectedForTimeAboveThresholdButExtPowerDisconnectedReportsAreDisabled_ExtPowerDisconnectedAbnormalReportIsNotSent()

  local EXT_POWER_DISCONNECTED_START_DEBOUNCE_TIME = 1
  local EXT_POWER_DISCONNECTED_END_DEBOUNCE_TIME = 1

  -- *** Setup
  -- terminal in some position but no valid fix provided
  local InitialPosition = {
                              speed = 0,                      -- kmh
                              latitude = 1,                   -- degrees
                              longitude = 1,                  -- degrees
                              fixType = 3,                    -- valid fix
  }

  vmsSW:setPropertiesByName({
                             ExtPowerDisconnectedStartDebounceTime = EXT_POWER_DISCONNECTED_START_DEBOUNCE_TIME,
                             ExtPowerDisconnectedEndDebounceTime = EXT_POWER_DISCONNECTED_END_DEBOUNCE_TIME,
                             ExtPowerDisconnectedSendReport = false,
                            }
  )

  -- *** Execute
  GPS:set(InitialPosition)

  -- checking ExtPowerDisconnectedState property
  local ExtPowerDisconnectedStateProperty = vmsSW:getPropertiesByName({"ExtPowerDisconnectedState"})
  D:log(framework.dump(ExtPowerDisconnectedStateProperty["ExtPowerDisconnectedState"]), "ExtPowerDisconnectedState")
  assert_true(ExtPowerDisconnectedStateProperty["ExtPowerDisconnectedState"], "ExtPowerDisconnectedState property is incorrectly false")

  D:log("EXTERNAL POWER SOURCE OF HELM PANEL CONNECTED")
  -- Helm Panel is connected to external power from now
  helmPanel:externalPowerConnected("true")

  framework.delay(EXT_POWER_DISCONNECTED_END_DEBOUNCE_TIME)

  local ReceivedMessages = vmsSW:waitForMessagesByName({"AbnormalReport"}, 10)
  D:log(ReceivedMessages["AbnormalReport"])

  if(ReceivedMessages["AbnormalReport"] ~= nil and ReceivedMessages["AbnormalReport"].EventType == "ExtPowerDisconnected" ) then
    assert_nil(1, "ExtPowerDisconnected abnormal report sent but not expected - sending reports is disabled")
  end

  -- checking ExtPowerDisconnectedState property
  local ExtPowerDisconnectedStateProperty = vmsSW:getPropertiesByName({"ExtPowerDisconnectedState"})
  D:log(framework.dump(ExtPowerDisconnectedStateProperty["ExtPowerDisconnectedState"]), "ExtPowerDisconnectedStateProperty" )
  assert_false(ExtPowerDisconnectedStateProperty["ExtPowerDisconnectedState"], "ExtPowerDisconnectedState property is incorrectly true")

  gateway.setHighWaterMark() -- to get the newest messages

  D:log("EXTERNAL POWER SOURCE OF  HELM PANEL DISCONNECTED")
  -- Helm Panel is disconnected from external power from now
  helmPanel:externalPowerConnected("false")

  framework.delay(EXT_POWER_DISCONNECTED_START_DEBOUNCE_TIME)

  local ReceivedMessages = vmsSW:waitForMessagesByName({"AbnormalReport"}, 10)
  D:log(ReceivedMessages["AbnormalReport"])

  if(ReceivedMessages["AbnormalReport"] ~= nil and ReceivedMessages["AbnormalReport"].EventType == "ExtPowerDisconnected" ) then
    assert_nil(1, "ExtPowerDisconnected abnormal report sent but not expected - sending reports is disabled")
  end

  -- checking ExtPowerDisconnectedState property
  local ExtPowerDisconnectedStateProperty = vmsSW:getPropertiesByName({"ExtPowerDisconnectedState"})
  D:log(framework.dump(ExtPowerDisconnectedStateProperty["ExtPowerDisconnectedState"]), "ExtPowerDisconnectedState")
  assert_true(ExtPowerDisconnectedStateProperty["ExtPowerDisconnectedState"], "ExtPowerDisconnectedState property is incorrectly false after ExtPowerDisconnectedStartDebounceTime")



end



function test_HelmPanelDisconnected_WhenHelmPanelIsConnectedForTimeAboveHelmPanelDisconnectedEndDebounceTime_HelmPanelDisconnectedAbnormalReportIsSent()

  local HELM_PANEL_DISCONNECTED_START_DEBOUNCE_TIME = 1
  local HELM_PANEL_DISCONNECTED_END_DEBOUNCE_TIME = 30

  -- *** Setup
  -- terminal in some position but no valid fix provided
  local InitialPosition = {
                             speed = 0,                      -- kmh
                             latitude = 1,                   -- degrees
                             longitude = 1,                  -- degrees
                             fixType = 3,                    -- valid fix
  }

  vmsSW:setPropertiesByName({
                             HelmPanelDisconnectedStartDebounceTime = HELM_PANEL_DISCONNECTED_START_DEBOUNCE_TIME,
                             HelmPanelDisconnectedEndDebounceTime = HELM_PANEL_DISCONNECTED_END_DEBOUNCE_TIME,
                             HelmPanelDisconnectedSendReport = true,
                            }
  )

  -- *** Execute
  GPS:set(InitialPosition)

  -- checking HelmPanelDisconnectedState property
  local HelmPanelDisconnectedStateProperty = vmsSW:getPropertiesByName({"HelmPanelDisconnectedState"})
  D:log(framework.dump(HelmPanelDisconnectedStateProperty["HelmPanelDisconnectedState"]), "HelmPanelDisconnectedState")
  assert_true(HelmPanelDisconnectedStateProperty["HelmPanelDisconnectedState"], "HelmPanelDisconnectedState property is incorrectly false")


  gateway.setHighWaterMark() -- to get the newest messages
  -- Helm Panel is connected to terminal from now
  helmPanel:setConnected("true")

  D:log("HELM PANEL CONNECTED TO TERMINAL")

  -- checking HelmPanelDisconnectedState property
  HelmPanelDisconnectedStateProperty = vmsSW:getPropertiesByName({"HelmPanelDisconnectedState"})
  D:log(framework.dump(HelmPanelDisconnectedStateProperty["HelmPanelDisconnectedState"]), "HelmPanelDisconnectedState")
  assert_true(HelmPanelDisconnectedStateProperty["HelmPanelDisconnectedState"], "HelmPanelDisconnectedState property has been changed before HelmPanelDisconnectedEndDebounceTime has passed")

  framework.delay(HELM_PANEL_DISCONNECTED_END_DEBOUNCE_TIME)

  timeOfEvent = os.time()

  local ReceivedMessages = vmsSW:waitForMessagesByName({"AbnormalReport"})
  D:log(ReceivedMessages["AbnormalReport"])

  -- checking HelmPanelDisconnectedState property
  HelmPanelDisconnectedStateProperty = vmsSW:getPropertiesByName({"HelmPanelDisconnectedState"})
  D:log(framework.dump(HelmPanelDisconnectedStateProperty["HelmPanelDisconnectedState"]), "HelmPanelDisconnectedState")
  assert_false(HelmPanelDisconnectedStateProperty["HelmPanelDisconnectedState"], "HelmPanelDisconnectedState property has not been changed after HelmPanelDisconnectedEndDebounceTime has passed")

  assert_not_nil(ReceivedMessages["AbnormalReport"], "AbnormalReport not received")

  assert_equal(
    InitialPosition.latitude*60000,
    tonumber(ReceivedMessages["AbnormalReport"].Latitude),
    "Wrong latitude value in HelmPanelDisconnected abnormal report"
  )

  assert_equal(
    InitialPosition.longitude*60000,
    tonumber(ReceivedMessages["AbnormalReport"].Longitude),
    "Wrong longitude value in HelmPanelDisconnected abnormal report"
  )

  assert_equal(
    InitialPosition.speed,
    tonumber(ReceivedMessages["AbnormalReport"].Speed),
    "Wrong speed value in HelmPanelDisconnected abnormal report"
  )

  assert_equal(
    361,
    tonumber(ReceivedMessages["AbnormalReport"].Course),
    "Wrong course value in HelmPanelDisconnected abnormal report"
  )

  assert_equal(
    "HelmPanelDisconnected",
    ReceivedMessages["AbnormalReport"].EventType,
    "Wrong name of the received EventType in HelmPanelDisconnected abnormal report"
  )

  assert_equal(
    timeOfEvent,
    tonumber(ReceivedMessages["AbnormalReport"].Timestamp),
    10,
    "Wrong Timestamp value in HelmPanelDisconnected abnormal report"
  )

  -- TODO: update this after implementation in TestFramework file
  --[[
  assert_equal(
    GpsNotJammedPosition.hdop,
    ReceivedMessages["AbnormalReport"].Hdop,
    "Wrong HDOP value in GpsJammed abnormal report"
  )

  assert_equal(
    GpsNotJammedPosition.idpsnr,
    ReceivedMessages["AbnormalReport"].IdpSnr,
    "Wrong IdpSnr value in GpsJammed abnormal report"
  )

  assert_equal(
    GpsNotJammedPosition.numsats,
    ReceivedMessages["AbnormalReport"].NumSats,
    "Wrong NumSats value in GpsJammed abnormal report"
  )
  --]]

  local StatusBitmap = vmsSW:decodeBitmap(ReceivedMessages["AbnormalReport"].StatusBitmap, "EventStateId")
  assert_false(StatusBitmap["HelmPanelDisconnected"], "StatusBitmap has not been correctly changed to false when Helm panel was connected to terminal")

  D:log("HELM PANEL DISCONNECTED FROM TERMINAL")

  -- back to helm panel disconnected
  helmPanel:setConnected("false")


end


function test_HelmPanelDisconnected_WhenHelmPanelIsDisconnectedForTimeAboveHelmPanelDisconnectedStartDebounceTime_HelmPanelDisconnectedAbnormalReportIsSent()

  local HELM_PANEL_DISCONNECTED_START_DEBOUNCE_TIME = 30
  local HELM_PANEL_DISCONNECTED_END_DEBOUNCE_TIME = 1

  -- *** Setup
  -- terminal in some position but no valid fix provided
  local InitialPosition = {
                             speed = 0,                      -- kmh
                             latitude = 1,                   -- degrees
                             longitude = 1,                  -- degrees
                             fixType = 3,                    -- valid fix
  }

  vmsSW:setPropertiesByName({
                             HelmPanelDisconnectedStartDebounceTime = HELM_PANEL_DISCONNECTED_START_DEBOUNCE_TIME,
                             HelmPanelDisconnectedEndDebounceTime = HELM_PANEL_DISCONNECTED_END_DEBOUNCE_TIME,
                             HelmPanelDisconnectedSendReport = true,
                            }
  )

  -- *** Execute
  GPS:set(InitialPosition)

  -- checking HelmPanelDisconnectedState property
  local HelmPanelDisconnectedStateProperty = vmsSW:getPropertiesByName({"HelmPanelDisconnectedState"})
  D:log(framework.dump(HelmPanelDisconnectedStateProperty["HelmPanelDisconnectedState"]), "HelmPanelDisconnectedState")
  assert_true(HelmPanelDisconnectedStateProperty["HelmPanelDisconnectedState"], "HelmPanelDisconnectedState property is incorrectly false")

  -- Helm Panel is connected to terminal from now
  helmPanel:setConnected("true")

  D:log("HELM PANEL CONNECTED TO TERMINAL")
  framework.delay(HELM_PANEL_DISCONNECTED_END_DEBOUNCE_TIME)

  -- checking HelmPanelDisconnectedState property
  HelmPanelDisconnectedStateProperty = vmsSW:getPropertiesByName({"HelmPanelDisconnectedState"})
  D:log(framework.dump(HelmPanelDisconnectedStateProperty["HelmPanelDisconnectedState"]), "HelmPanelDisconnectedState")
  assert_false(HelmPanelDisconnectedStateProperty["HelmPanelDisconnectedState"], "HelmPanelDisconnectedState property has not been changed after HelmPanelDisconnectedEndDebounceTime has passed")

  D:log("HELM PANEL DISCONNECTED FROM TERMINAL")
  gateway.setHighWaterMark() -- to get the newest messages
  -- Helm Panel is disconnected from terminal from now
  helmPanel:setConnected("false")

  -- checking HelmPanelDisconnectedState property
  HelmPanelDisconnectedStateProperty = vmsSW:getPropertiesByName({"HelmPanelDisconnectedState"})
  D:log(framework.dump(HelmPanelDisconnectedStateProperty["HelmPanelDisconnectedState"]), "HelmPanelDisconnectedState")
  assert_false(HelmPanelDisconnectedStateProperty["HelmPanelDisconnectedState"], "HelmPanelDisconnectedState property has been changed before HelmPanelDisconnectedEndDebounceTime has passed")

  framework.delay(HELM_PANEL_DISCONNECTED_START_DEBOUNCE_TIME)

  timeOfEvent = os.time()

  local ReceivedMessages = vmsSW:waitForMessagesByName({"AbnormalReport"})
  D:log(ReceivedMessages["AbnormalReport"])

  assert_not_nil(ReceivedMessages["AbnormalReport"], "AbnormalReport not received")

  assert_equal(
    InitialPosition.latitude*60000,
    tonumber(ReceivedMessages["AbnormalReport"].Latitude),
    "Wrong latitude value in HelmPanelDisconnected abnormal report"
  )

  assert_equal(
    InitialPosition.longitude*60000,
    tonumber(ReceivedMessages["AbnormalReport"].Longitude),
    "Wrong longitude value in HelmPanelDisconnected abnormal report"
  )

  assert_equal(
    InitialPosition.speed,
    tonumber(ReceivedMessages["AbnormalReport"].Speed),
    "Wrong speed value in HelmPanelDisconnected abnormal report"
  )

  assert_equal(
    361,
    tonumber(ReceivedMessages["AbnormalReport"].Course),
    "Wrong course value in HelmPanelDisconnected abnormal report"
  )

  assert_equal(
    "HelmPanelDisconnected",
    ReceivedMessages["AbnormalReport"].EventType,
    "Wrong name of the received EventType in HelmPanelDisconnected abnormal report"
  )

  assert_equal(
    timeOfEvent,
    tonumber(ReceivedMessages["AbnormalReport"].Timestamp),
    10,
    "Wrong Timestamp value in HelmPanelDisconnected abnormal report"
  )

  -- TODO: update this after implementation in TestFramework file
  --[[
  assert_equal(
    GpsNotJammedPosition.hdop,
    ReceivedMessages["AbnormalReport"].Hdop,
    "Wrong HDOP value in GpsJammed abnormal report"
  )

  assert_equal(
    GpsNotJammedPosition.idpsnr,
    ReceivedMessages["AbnormalReport"].IdpSnr,
    "Wrong IdpSnr value in GpsJammed abnormal report"
  )

  assert_equal(
    GpsNotJammedPosition.numsats,
    ReceivedMessages["AbnormalReport"].NumSats,
    "Wrong NumSats value in GpsJammed abnormal report"
  )
  --]]

  local StatusBitmap = vmsSW:decodeBitmap(ReceivedMessages["AbnormalReport"].StatusBitmap, "EventStateId")
  assert_true(StatusBitmap["HelmPanelDisconnected"], "StatusBitmap has not been correctly changed to false when Helm panel was disconnected from terminal")


end




function test_HelmPanelDisconnected_ForTerminalInHelmPanelDisconnectedStateTrueWhenHelmPanelIsConnectedForTimeBelowHelmPanelDisconnectedEndDebounceTime_HelmPanelDisconnectedAbnormalReportIsNotSent()

  local HELM_PANEL_DISCONNECTED_START_DEBOUNCE_TIME = 1
  local HELM_PANEL_DISCONNECTED_END_DEBOUNCE_TIME = 30

  -- *** Setup
  -- terminal in some position but no valid fix provided
  local InitialPosition = {
                             speed = 0,                      -- kmh
                             latitude = 1,                   -- degrees
                             longitude = 1,                  -- degrees
                             fixType = 3,                    -- valid fix
  }

  vmsSW:setPropertiesByName({
                             HelmPanelDisconnectedStartDebounceTime = HELM_PANEL_DISCONNECTED_START_DEBOUNCE_TIME,
                             HelmPanelDisconnectedEndDebounceTime = HELM_PANEL_DISCONNECTED_END_DEBOUNCE_TIME,
                             HelmPanelDisconnectedSendReport = true,
                            }
  )

  -- *** Execute
  GPS:set(InitialPosition)

  -- checking HelmPanelDisconnectedState property
  local HelmPanelDisconnectedStateProperty = vmsSW:getPropertiesByName({"HelmPanelDisconnectedState"})
  D:log(framework.dump(HelmPanelDisconnectedStateProperty["HelmPanelDisconnectedState"]), "HelmPanelDisconnectedState")
  assert_true(HelmPanelDisconnectedStateProperty["HelmPanelDisconnectedState"], "HelmPanelDisconnectedState property is incorrectly false")


  gateway.setHighWaterMark() -- to get the newest messages

  D:log("HELM PANEL CONNECTED TO TERMINAL")
  -- Helm Panel is connected to terminal from now
  helmPanel:setConnected("true")

  local ReceivedMessages = vmsSW:waitForMessagesByName({"AbnormalReport"}, 15)
  D:log(ReceivedMessages["AbnormalReport"])

  framework.delay(HELM_PANEL_DISCONNECTED_END_DEBOUNCE_TIME)

  if(ReceivedMessages["AbnormalReport"] ~= nil and ReceivedMessages["AbnormalReport"].EventType == "HelmPanelDisconnected" ) then
    assert_nil(1, "HelmPanelDisconnected abnormal report sent but not expected - sending reports disabled")
  end
  -- checking HelmPanelDisconnectedState property
  HelmPanelDisconnectedStateProperty = vmsSW:getPropertiesByName({"HelmPanelDisconnectedState"})
  D:log(framework.dump(HelmPanelDisconnectedStateProperty["HelmPanelDisconnectedState"]), "HelmPanelDisconnectedState")
  assert_false(HelmPanelDisconnectedStateProperty["HelmPanelDisconnectedState"], "HelmPanelDisconnectedState property has not been changed after HelmPanelDisconnectedEndDebounceTime has passed")

  -- back to helm panel disconnected
  helmPanel:setConnected("false")


end


function test_HelmPanelDisconnected_ForTerminalInHelmPanelDisconnectedStateFalseWhenHelmPanelIsDisconnectedForTimeBelowHelmPanelDisconnectedStartDebounceTime_HelmPanelDisconnectedAbnormalReportIsNotSent()

  local HELM_PANEL_DISCONNECTED_START_DEBOUNCE_TIME = 30
  local HELM_PANEL_DISCONNECTED_END_DEBOUNCE_TIME = 1

  -- *** Setup
  -- terminal in some position but no valid fix provided
  local InitialPosition = {
                             speed = 0,                      -- kmh
                             latitude = 1,                   -- degrees
                             longitude = 1,                  -- degrees
                             fixType = 3,                    -- valid fix
  }

  vmsSW:setPropertiesByName({
                             HelmPanelDisconnectedStartDebounceTime = HELM_PANEL_DISCONNECTED_START_DEBOUNCE_TIME,
                             HelmPanelDisconnectedEndDebounceTime = HELM_PANEL_DISCONNECTED_END_DEBOUNCE_TIME,
                             HelmPanelDisconnectedSendReport = true,
                            }
  )

  -- *** Execute
  GPS:set(InitialPosition)

  -- checking HelmPanelDisconnectedState property
  local HelmPanelDisconnectedStateProperty = vmsSW:getPropertiesByName({"HelmPanelDisconnectedState"})
  D:log(framework.dump(HelmPanelDisconnectedStateProperty["HelmPanelDisconnectedState"]), "HelmPanelDisconnectedState")
  assert_true(HelmPanelDisconnectedStateProperty["HelmPanelDisconnectedState"], "HelmPanelDisconnectedState property is incorrectly false")

  D:log("HELM PANEL CONNECTED TO TERMINAL")
  -- Helm Panel is connected to terminal from now
  helmPanel:setConnected("true")

  framework.delay(HELM_PANEL_DISCONNECTED_END_DEBOUNCE_TIME)

  -- checking HelmPanelDisconnectedState property
  HelmPanelDisconnectedStateProperty = vmsSW:getPropertiesByName({"HelmPanelDisconnectedState"})
  D:log(framework.dump(HelmPanelDisconnectedStateProperty["HelmPanelDisconnectedState"]), "HelmPanelDisconnectedState")
  assert_false(HelmPanelDisconnectedStateProperty["HelmPanelDisconnectedState"], "HelmPanelDisconnectedState property has not been changed after HelmPanelDisconnectedEndDebounceTime has passed")

  gateway.setHighWaterMark() -- to get the newest messages

  D:log("HELM PANEL DISCONNECTED FROM TERMINAL")
  -- Helm Panel is disconnected from terminal from now
  helmPanel:setConnected("false")

  local ReceivedMessages = vmsSW:waitForMessagesByName({"AbnormalReport"}, 15)
  D:log(ReceivedMessages["AbnormalReport"])

  framework.delay(HELM_PANEL_DISCONNECTED_START_DEBOUNCE_TIME)

  if(ReceivedMessages["AbnormalReport"] ~= nil and ReceivedMessages["AbnormalReport"].EventType == "HelmPanelDisconnected" ) then
    assert_nil(1, "HelmPanelDisconnected abnormal report sent but not expected - sending reports disabled")
  end

  -- checking HelmPanelDisconnectedState property
  HelmPanelDisconnectedStateProperty = vmsSW:getPropertiesByName({"HelmPanelDisconnectedState"})
  D:log(framework.dump(HelmPanelDisconnectedStateProperty["HelmPanelDisconnectedState"]), "HelmPanelDisconnectedState")
  assert_true(HelmPanelDisconnectedStateProperty["HelmPanelDisconnectedState"], "HelmPanelDisconnectedState property has not been changed after HelmPanelDisconnectedEndDebounceTime has passed")


end


function test_HelmPanelDisconnected_ForTerminalInHelmPanelDisconnectedStateTrueWhenHelmPanelIsConnectedAndConnectedForTimeAboveThresholdAndHelmPanelDisconnectedReportsAreDisabled_HelmPanelDisconnectedAbnormalReportIsNotSent()

  local HELM_PANEL_DISCONNECTED_START_DEBOUNCE_TIME = 1
  local HELM_PANEL_DISCONNECTED_END_DEBOUNCE_TIME = 1

  -- *** Setup
  -- terminal in some position but no valid fix provided
  local InitialPosition = {
                             speed = 0,                      -- kmh
                             latitude = 1,                   -- degrees
                             longitude = 1,                  -- degrees
                             fixType = 3,                    -- valid fix
  }

  vmsSW:setPropertiesByName({
                             HelmPanelDisconnectedStartDebounceTime = HELM_PANEL_DISCONNECTED_START_DEBOUNCE_TIME,
                             HelmPanelDisconnectedEndDebounceTime = HELM_PANEL_DISCONNECTED_END_DEBOUNCE_TIME,
                             HelmPanelDisconnectedSendReport = false,
                            }
  )

  -- *** Execute
  GPS:set(InitialPosition)

  -- checking HelmPanelDisconnectedState property
  local HelmPanelDisconnectedStateProperty = vmsSW:getPropertiesByName({"HelmPanelDisconnectedState"})
  D:log(framework.dump(HelmPanelDisconnectedStateProperty["HelmPanelDisconnectedState"]), "HelmPanelDisconnectedState")
  assert_true(HelmPanelDisconnectedStateProperty["HelmPanelDisconnectedState"], "HelmPanelDisconnectedState property is incorrectly false")

  D:log("HELM PANEL CONNECTED TO TERMINAL")
  -- Helm Panel is connected to terminal from now
  helmPanel:setConnected("true")

  framework.delay(HELM_PANEL_DISCONNECTED_END_DEBOUNCE_TIME)

  local ReceivedMessages = vmsSW:waitForMessagesByName({"AbnormalReport"}, 15)
  D:log(ReceivedMessages["AbnormalReport"])

  -- checking HelmPanelDisconnectedState property
  HelmPanelDisconnectedStateProperty = vmsSW:getPropertiesByName({"HelmPanelDisconnectedState"})
  D:log(framework.dump(HelmPanelDisconnectedStateProperty["HelmPanelDisconnectedState"]), "HelmPanelDisconnectedState")
  assert_false(HelmPanelDisconnectedStateProperty["HelmPanelDisconnectedState"], "HelmPanelDisconnectedState property has not been changed after HelmPanelDisconnectedEndDebounceTime has passed")

  gateway.setHighWaterMark() -- to get the newest messages

  helmPanel:setConnected("false")

  D:log("HELM PANEL DISCONNECTED FROM TERMINAL")
  -- Helm Panel is diconnected to terminal from now
  helmPanel:setConnected("false")

  framework.delay(HELM_PANEL_DISCONNECTED_START_DEBOUNCE_TIME)

  ReceivedMessages = vmsSW:waitForMessagesByName({"AbnormalReport"}, 15)
  D:log(ReceivedMessages["AbnormalReport"])

  if(ReceivedMessages["AbnormalReport"] ~= nil and ReceivedMessages["AbnormalReport"].EventType == "HelmPanelDisconnected" ) then
    assert_nil(1, "HelmPanelDisconnected abnormal report sent but not expected - sending reports disabled")
  end

  -- checking HelmPanelDisconnectedState property
  HelmPanelDisconnectedStateProperty = vmsSW:getPropertiesByName({"HelmPanelDisconnectedState"})
  D:log(framework.dump(HelmPanelDisconnectedStateProperty["HelmPanelDisconnectedState"]), "HelmPanelDisconnectedState")
  assert_true(HelmPanelDisconnectedStateProperty["HelmPanelDisconnectedState"], "HelmPanelDisconnectedState property has not been changed after HelmPanelDisconnectedEndDebounceTime has passed")


end



function test_HwClientDisconnected_ForTerminalInHwClientDisconnectedStateTrueWhenHwClientIsConnectedForTimeAboveHwClientDisconnectedEndDebounceTime_HwClientDisconnectedAbnormalReportIsSent()

  local HW_CLIENT_DISCONNECTED_START_DEBOUNCE_TIME = 1
  local HW_CLIENT_DISCONNECTED_END_DEBOUNCE_TIME = 30


  -- *** Setup
  -- terminal in some position but no valid fix provided
  local InitialPosition = {
                             speed = 0,                      -- kmh
                             latitude = 1,                   -- degrees
                             longitude = 1,                  -- degrees
                             fixType = 3,                    -- valid fix
  }

  vmsSW:setPropertiesByName({
                             HwClientDisconnectedStartDebounceTime = HW_CLIENT_DISCONNECTED_START_DEBOUNCE_TIME,
                             HwClientDisconnectedEndDebounceTime = HW_CLIENT_DISCONNECTED_END_DEBOUNCE_TIME,
                             HwClientDisconnectedSendReport = true,
                            }
  )

  -- *** Execute
  GPS:set(InitialPosition)

  -- checking HwClientDisconnectedState property
  local HwClientDisconnectedStateProperty = vmsSW:getPropertiesByName({"HwClientDisconnectedState"})
  D:log(framework.dump(HwClientDisconnectedStateProperty["HwClientDisconnectedState"]), "HwClientDisconnectedState")
  assert_true(HwClientDisconnectedStateProperty["HwClientDisconnectedState"], "HwClientDisconnectedState property is incorrectly false")

  gateway.setHighWaterMark() -- to get the newest messages

  D:log("HW CLIENT CONNECTED TO TERMINAL")
  -- Hw client is connected to terminal
  shellSW:postEvent(
                    "\"_RS232\"",
                    "DTECONNECTED",
                    "true"
  )

  framework.delay(3)

  -- checking HwClientDisconnectedState property
  HwClientDisconnectedStateProperty = vmsSW:getPropertiesByName({"HwClientDisconnectedState"})
  D:log(framework.dump(HwClientDisconnectedStateProperty["HwClientDisconnectedState"]), "HwClientDisconnectedState")
  assert_true(HwClientDisconnectedStateProperty["HwClientDisconnectedState"], "HwClientDisconnectedState property is incorrectly false before HW_CLIENT_DISCONNECTED_END_DEBOUNCE_TIME has passed")

  framework.delay(HW_CLIENT_DISCONNECTED_END_DEBOUNCE_TIME)
  timeOfEvent = os.time()

  local ReceivedMessages = vmsSW:waitForMessagesByName({"AbnormalReport"})
  D:log(ReceivedMessages["AbnormalReport"])

  -- checking HwClientDisconnectedState property
  HwClientDisconnectedStateProperty = vmsSW:getPropertiesByName({"HwClientDisconnectedState"})
  D:log(framework.dump(HwClientDisconnectedStateProperty["HwClientDisconnectedState"]), "HwClientDisconnectedState")
  assert_false(HwClientDisconnectedStateProperty["HwClientDisconnectedState"], "HwClientDisconnectedState property has not been changed after HW_CLIENT_DISCONNECTED_END_DEBOUNCE_TIME has passed")

  assert_not_nil(ReceivedMessages["AbnormalReport"], "AbnormalReport not received")

  assert_equal(
    InitialPosition.latitude*60000,
    tonumber(ReceivedMessages["AbnormalReport"].Latitude),
    "Wrong latitude value in HwClientDisconnected abnormal report"
  )

  assert_equal(
    InitialPosition.longitude*60000,
    tonumber(ReceivedMessages["AbnormalReport"].Longitude),
    "Wrong longitude value in HwClientDisconnected abnormal report"
  )

  assert_equal(
    InitialPosition.speed,
    tonumber(ReceivedMessages["AbnormalReport"].Speed),
    "Wrong speed value in HwClientDisconnected abnormal report"
  )

  assert_equal(
    361,
    tonumber(ReceivedMessages["AbnormalReport"].Course),
    "Wrong course value in HwClientDisconnected abnormal report"
  )

  assert_equal(
    "HwClientDisconnected",
    ReceivedMessages["AbnormalReport"].EventType,
    "Wrong name of the received EventType in HwClientDisconnected abnormal report"
  )

  assert_equal(
    timeOfEvent,
    tonumber(ReceivedMessages["AbnormalReport"].Timestamp),
    10,
    "Wrong Timestamp value in HwClientDisconnected abnormal report"
  )

  -- TODO: update this after implementation in TestFramework file
  --[[
  assert_equal(
    GpsNotJammedPosition.hdop,
    ReceivedMessages["AbnormalReport"].Hdop,
    "Wrong HDOP value in GpsJammed abnormal report"
  )

  assert_equal(
    GpsNotJammedPosition.idpsnr,
    ReceivedMessages["AbnormalReport"].IdpSnr,
    "Wrong IdpSnr value in GpsJammed abnormal report"
  )

  assert_equal(
    GpsNotJammedPosition.numsats,
    ReceivedMessages["AbnormalReport"].NumSats,
    "Wrong NumSats value in GpsJammed abnormal report"
  )
  --]]

  local StatusBitmap = vmsSW:decodeBitmap(ReceivedMessages["AbnormalReport"].StatusBitmap, "EventStateId")
  assert_false(StatusBitmap["HwClientDisconnected"], "StatusBitmap has not been correctly changed to false when Hw panel was connected from terminal")


end


function test_HwClientDisconnected_ForTerminalInHwClientDisconnectedStateFalseWhenHwClientIsDisconnectedForTimeAboveHwClientDisconnectedStartDebounceTime_HwClientDisconnectedAbnormalReportIsSent()

  local HW_CLIENT_DISCONNECTED_START_DEBOUNCE_TIME = 30
  local HW_CLIENT_DISCONNECTED_END_DEBOUNCE_TIME = 1


  -- *** Setup
  -- terminal in some position but no valid fix provided
  local InitialPosition = {
                             speed = 0,                      -- kmh
                             latitude = 1,                   -- degrees
                             longitude = 1,                  -- degrees
                             fixType = 3,                    -- valid fix
  }

  vmsSW:setPropertiesByName({
                             HwClientDisconnectedStartDebounceTime = HW_CLIENT_DISCONNECTED_START_DEBOUNCE_TIME,
                             HwClientDisconnectedEndDebounceTime = HW_CLIENT_DISCONNECTED_END_DEBOUNCE_TIME,
                             HwClientDisconnectedSendReport = true,
                            }
  )

  -- *** Execute
  GPS:set(InitialPosition)

  D:log("HW CLIENT CONNECTED TO TERMINAL")
  -- Hw client is connected to terminal
  shellSW:postEvent(
                    "\"_RS232\"",
                    "DTECONNECTED",
                    "true"
  )

  framework.delay(HW_CLIENT_DISCONNECTED_END_DEBOUNCE_TIME)

  -- checking HwClientDisconnectedState property
  HwClientDisconnectedStateProperty = vmsSW:getPropertiesByName({"HwClientDisconnectedState"})
  D:log(framework.dump(HwClientDisconnectedStateProperty["HwClientDisconnectedState"]), "HwClientDisconnectedState")
  assert_false(HwClientDisconnectedStateProperty["HwClientDisconnectedState"], "HwClientDisconnectedState property is incorrectly true after HW_CLIENT_DISCONNECTED_END_DEBOUNCE_TIME has passed")

  D:log(os.time(), "HW CLIENT DISCONNECTED FROM TERMINAL")

  gateway.setHighWaterMark() -- to get the newest messages
  -- Hw client is disconnected from terminal
  shellSW:postEvent(
                    "\"_RS232\"",
                    "DTECONNECTED",
                    "false"
  )

  -- checking HwClientDisconnectedState property
  HwClientDisconnectedStateProperty = vmsSW:getPropertiesByName({"HwClientDisconnectedState"})
  D:log(framework.dump(HwClientDisconnectedStateProperty["HwClientDisconnectedState"]), "HwClientDisconnectedState")
  assert_false(HwClientDisconnectedStateProperty["HwClientDisconnectedState"], "HwClientDisconnectedState property is incorrectly true before HW_CLIENT_DISCONNECTED_START_DEBOUNCE_TIME has passed")

  framework.delay(HW_CLIENT_DISCONNECTED_START_DEBOUNCE_TIME)

  local ReceivedMessages = vmsSW:waitForMessagesByName({"AbnormalReport"})


  timeOfEvent = os.time()

  -- checking HwClientDisconnectedState property
  HwClientDisconnectedStateProperty = vmsSW:getPropertiesByName({"HwClientDisconnectedState"})
  D:log(framework.dump(HwClientDisconnectedStateProperty["HwClientDisconnectedState"]), "HwClientDisconnectedState")
  assert_true(HwClientDisconnectedStateProperty["HwClientDisconnectedState"], "HwClientDisconnectedState property is incorrectly false after HW_CLIENT_DISCONNECTED_START_DEBOUNCE_TIME has passed")


  D:log(ReceivedMessages["AbnormalReport"])
  assert_not_nil(ReceivedMessages["AbnormalReport"], "AbnormalReport not received")

  assert_equal(
    InitialPosition.latitude*60000,
    tonumber(ReceivedMessages["AbnormalReport"].Latitude),
    "Wrong latitude value in HwClientDisconnected abnormal report"
  )

  assert_equal(
    InitialPosition.longitude*60000,
    tonumber(ReceivedMessages["AbnormalReport"].Longitude),
    "Wrong longitude value in HwClientDisconnected abnormal report"
  )

  assert_equal(
    InitialPosition.speed,
    tonumber(ReceivedMessages["AbnormalReport"].Speed),
    "Wrong speed value in HwClientDisconnected abnormal report"
  )

  assert_equal(
    361,
    tonumber(ReceivedMessages["AbnormalReport"].Course),
    "Wrong course value in HwClientDisconnected abnormal report"
  )

  assert_equal(
    "HwClientDisconnected",
    ReceivedMessages["AbnormalReport"].EventType,
    "Wrong name of the received EventType in HwClientDisconnected abnormal report"
  )

  assert_equal(
    timeOfEvent,
    tonumber(ReceivedMessages["AbnormalReport"].Timestamp),
    10,
    "Wrong Timestamp value in HwClientDisconnected abnormal report"
  )
  -- TODO: update this after implementation in TestFramework file
  --[[
  assert_equal(
    GpsNotJammedPosition.hdop,
    ReceivedMessages["AbnormalReport"].Hdop,
    "Wrong HDOP value in GpsJammed abnormal report"
  )

  assert_equal(
    GpsNotJammedPosition.idpsnr,
    ReceivedMessages["AbnormalReport"].IdpSnr,
    "Wrong IdpSnr value in GpsJammed abnormal report"
  )

  assert_equal(
    GpsNotJammedPosition.numsats,
    ReceivedMessages["AbnormalReport"].NumSats,
    "Wrong NumSats value in GpsJammed abnormal report"
  )
  --]]

  local StatusBitmap = vmsSW:decodeBitmap(ReceivedMessages["AbnormalReport"].StatusBitmap, "EventStateId")
  assert_true(StatusBitmap["HwClientDisconnected"], "StatusBitmap has not been correctly changed to true when Hw panel was disconnected from terminal")


end



function test_HwClientDisconnected_ForTerminalInHwClientDisconnectedStateTrueWhenHwClientIsConnectedForTimeBelowHwClientDisconnectedEndDebounceTime_HwClientDisconnectedAbnormalReportIsNotSent()

  local HW_CLIENT_DISCONNECTED_START_DEBOUNCE_TIME = 1
  local HW_CLIENT_DISCONNECTED_END_DEBOUNCE_TIME = 30


  -- *** Setup
  -- terminal in some position but no valid fix provided
  local InitialPosition = {
                             speed = 0,                      -- kmh
                             latitude = 1,                   -- degrees
                             longitude = 1,                  -- degrees
                             fixType = 3,                    -- valid fix
  }

  vmsSW:setPropertiesByName({
                             HwClientDisconnectedStartDebounceTime = HW_CLIENT_DISCONNECTED_START_DEBOUNCE_TIME,
                             HwClientDisconnectedEndDebounceTime = HW_CLIENT_DISCONNECTED_END_DEBOUNCE_TIME,
                             HwClientDisconnectedSendReport = true,
                            }
  )

  -- *** Execute
  GPS:set(InitialPosition)

  gateway.setHighWaterMark() -- to get the newest messages

  D:log("HW CLIENT CONNECTED TO TERMINAL")
  -- Hw client is connected to terminal
  shellSW:postEvent(
                    "\"_RS232\"",
                    "DTECONNECTED",
                    "true"
  )

  local ReceivedMessages = vmsSW:waitForMessagesByName({"AbnormalReport"}, 15)
  D:log(ReceivedMessages["AbnormalReport"])

  -- back to HW Client disconnected
  shellSW:postEvent(
                    "\"_RS232\"",
                    "DTECONNECTED",
                    "false"
  )

  if(ReceivedMessages["AbnormalReport"] ~= nil and ReceivedMessages["AbnormalReport"].EventType == "HwClientDisconnected" ) then
    assert_nil(1, "HwClientDisconnected abnormal report sent but not expected")
  end

  -- checking HwClientDisconnectedState property
  local HwClientDisconnectedStateProperty = vmsSW:getPropertiesByName({"HwClientDisconnectedState"})
  D:log(framework.dump(HwClientDisconnectedStateProperty["HwClientDisconnectedState"]), "HwClientDisconnectedState")
  assert_true(HwClientDisconnectedStateProperty["HwClientDisconnectedState"], "HwClientDisconnectedState property is incorrectly false - HW_CLIENT_DISCONNECTED_END_DEBOUNCE_TIME has not passed")

end




function test_HwClientDisconnected_ForTerminalInHwClientDisconnectedStateFalseWhenHwClientIsDisconnectedForTimeBelowHwClientDisconnectedStartDebounceTime_HwClientDisconnectedAbnormalReportIsNotSent()

  local HW_CLIENT_DISCONNECTED_START_DEBOUNCE_TIME = 30
  local HW_CLIENT_DISCONNECTED_END_DEBOUNCE_TIME = 1


  -- *** Setup
  -- terminal in some position but no valid fix provided
  local InitialPosition = {
                             speed = 0,                      -- kmh
                             latitude = 1,                   -- degrees
                             longitude = 1,                  -- degrees
                             fixType = 3,                    -- valid fix
  }

  vmsSW:setPropertiesByName({
                             HwClientDisconnectedStartDebounceTime = HW_CLIENT_DISCONNECTED_START_DEBOUNCE_TIME,
                             HwClientDisconnectedEndDebounceTime = HW_CLIENT_DISCONNECTED_END_DEBOUNCE_TIME,
                             HwClientDisconnectedSendReport = true,
                            }
  )

  -- *** Execute
  GPS:set(InitialPosition)

  D:log("HW CLIENT CONNECTED TO TERMINAL")
  -- Hw client is connected to terminal
  shellSW:postEvent(
                    "\"_RS232\"",
                    "DTECONNECTED",
                    "true"
  )

  framework.delay(HW_CLIENT_DISCONNECTED_END_DEBOUNCE_TIME)

  -- checking HwClientDisconnectedState property
  HwClientDisconnectedStateProperty = vmsSW:getPropertiesByName({"HwClientDisconnectedState"})
  D:log(framework.dump(HwClientDisconnectedStateProperty["HwClientDisconnectedState"]), "HwClientDisconnectedState")
  assert_false(HwClientDisconnectedStateProperty["HwClientDisconnectedState"], "HwClientDisconnectedState property is incorrectly true after HW_CLIENT_DISCONNECTED_END_DEBOUNCE_TIME has passed")

  D:log(os.time(), "HW CLIENT DISCONNECTED FROM TERMINAL")

  gateway.setHighWaterMark() -- to get the newest messages
  -- Hw client is disconnected from terminal
  shellSW:postEvent(
                    "\"_RS232\"",
                    "DTECONNECTED",
                    "false"
  )

  local ReceivedMessages = vmsSW:waitForMessagesByName({"AbnormalReport"}, 15)

  if(ReceivedMessages["AbnormalReport"] ~= nil and ReceivedMessages["AbnormalReport"].EventType == "HwClientDisconnected" ) then
    assert_nil(1, "HwClientDisconnected abnormal report sent but not expected")
  end

  -- checking HwClientDisconnectedState property
  HwClientDisconnectedStateProperty = vmsSW:getPropertiesByName({"HwClientDisconnectedState"})
  D:log(framework.dump(HwClientDisconnectedStateProperty["HwClientDisconnectedState"]), "HwClientDisconnectedState")
  assert_false(HwClientDisconnectedStateProperty["HwClientDisconnectedState"], "HwClientDisconnectedState property is incorrectly true before HW_CLIENT_DISCONNECTED_START_DEBOUNCE_TIME has passed")


end




function test_HwClientDisconnected_ForTerminalInHwClientDisconnectedStateTrueWhenHwClientIsConnectedDisconnectedForTimeAboveThresholdsButHwClientDisconnectedReportsAreDisabled_HwClientDisconnectedAbnormalReportIsNotSent()

  local HW_CLIENT_DISCONNECTED_START_DEBOUNCE_TIME = 1
  local HW_CLIENT_DISCONNECTED_END_DEBOUNCE_TIME = 1


  -- *** Setup
  -- terminal in some position but no valid fix provided
  local InitialPosition = {
                             speed = 0,                      -- kmh
                             latitude = 1,                   -- degrees
                             longitude = 1,                  -- degrees
                             fixType = 3,                    -- valid fix
  }

  vmsSW:setPropertiesByName({
                             HwClientDisconnectedStartDebounceTime = HW_CLIENT_DISCONNECTED_START_DEBOUNCE_TIME,
                             HwClientDisconnectedEndDebounceTime = HW_CLIENT_DISCONNECTED_END_DEBOUNCE_TIME,
                             HwClientDisconnectedSendReport = false,
                            }
  )

  -- *** Execute
  GPS:set(InitialPosition)

  gateway.setHighWaterMark() -- to get the newest messages
  D:log("HW CLIENT CONNECTED TO TERMINAL")
  -- Hw client is connected to terminal
  shellSW:postEvent(
                    "\"_RS232\"",
                    "DTECONNECTED",
                    "true"
  )

  framework.delay(HW_CLIENT_DISCONNECTED_END_DEBOUNCE_TIME)

  local ReceivedMessages = vmsSW:waitForMessagesByName({"AbnormalReport"}, 15)

  if(ReceivedMessages["AbnormalReport"] ~= nil and ReceivedMessages["AbnormalReport"].EventType == "HwClientDisconnected" ) then
    assert_nil(1, "HwClientDisconnected abnormal report sent but not expected - sendind reports is disabled")
  end

  -- checking HwClientDisconnectedState property
  HwClientDisconnectedStateProperty = vmsSW:getPropertiesByName({"HwClientDisconnectedState"})
  D:log(framework.dump(HwClientDisconnectedStateProperty["HwClientDisconnectedState"]), "HwClientDisconnectedState")
  assert_false(HwClientDisconnectedStateProperty["HwClientDisconnectedState"], "HwClientDisconnectedState property is incorrectly true after HW_CLIENT_DISCONNECTED_END_DEBOUNCE_TIME has passed")

  gateway.setHighWaterMark() -- to get the newest messages
  D:log(os.time(), "HW CLIENT DISCONNECTED FROM TERMINAL")
  -- Hw client is disconnected from terminal
  shellSW:postEvent(
                    "\"_RS232\"",
                    "DTECONNECTED",
                    "false"
  )

  ReceivedMessages = vmsSW:waitForMessagesByName({"AbnormalReport"}, 15)

  if(ReceivedMessages["AbnormalReport"] ~= nil and ReceivedMessages["AbnormalReport"].EventType == "HwClientDisconnected" ) then
    assert_nil(1, "HwClientDisconnected abnormal report sent but not expected - sending reports is disabled")
  end

  -- checking HwClientDisconnectedState property
  HwClientDisconnectedStateProperty = vmsSW:getPropertiesByName({"HwClientDisconnectedState"})
  D:log(framework.dump(HwClientDisconnectedStateProperty["HwClientDisconnectedState"]), "HwClientDisconnectedState")
  assert_true(HwClientDisconnectedStateProperty["HwClientDisconnectedState"], "HwClientDisconnectedState property is incorrectly false after HW_CLIENT_DISCONNECTED_START_DEBOUNCE_TIME has passed")


end




function test_SetProperties_WhenSetPropertiesMessageIsSet_PropertiesIncludedInTheMessageAreCorrectlySetAndPropertiesMessageReportsCorrectValues()

 	local SetPropertiesMessage = {SIN = vmsSW.sin, MIN = vmsSW:getMinTo("SetProperties")}
  D:log(SetPropertiesMessage)

  local enabled =  true

  local function nameValueToArray(data)
    local result = {}
    for index, row in pairs(data) do
      local value = row.Value
      if type(value) == "boolean" then
        if value then
          value = "True"
        else
          value = "False"
        end
      end
      result[row.Name] = "" .. value
    end
    return result
  end

  local function nameToArray(data)
    local result = {}
    for index, row in pairs(data) do
      result[#result+1] = row.Name
    end
    return result
  end


  for counter = 1, 3, 1 do

    if counter%2 > 0 then
      enabled = true else
      enabled = false
    end

    SetPropertiesMessage.Fields = {
      {Name="GpsJammedSendReport",Value=enabled},
      {Name="GpsJammedStartDebounceTime",Value=counter},
      {Name="GpsJammedEndDebounceTime",Value=counter},
      {Name="GpsBlockedSendReport",Value=enabled},
      {Name="GpsBlockedStartDebounceTime",Value=counter},
      {Name="GpsBlockedEndDebounceTime",Value=counter},
      {Name="IdpBlockedSendReport",Value=enabled},
      {Name="IdpBlockedStartDebounceTime",Value=counter},
      {Name="IdpBlockedEndDebounceTime",Value=counter},
      {Name="HwClientDisconnectedSendReport",Value=enabled},
      {Name="HwClientDisconnectedStartDebounceTime",Value=counter},
      {Name="HwClientDisconnectedEndDebounceTime",Value=counter},
      {Name="HelmPanelDisconnectedSendReport",Value=enabled},
      {Name="HelmPanelDisconnectedStartDebounceTime",Value=counter},
      {Name="HelmPanelDisconnectedEndDebounceTime",Value=counter},
      {Name="ExtPowerDisconnectedSendReport",Value=enabled},
      {Name="ExtPowerDisconnectedStartDebounceTime",Value=counter},
      {Name="ExtPowerDisconnectedEndDebounceTime",Value=counter},
      {Name="PowerDisconnectedSendReport",Value=enabled},
      {Name="PowerDisconnectedStartDebounceTime",Value=counter},
      {Name="PowerDisconnectedEndDebounceTime",Value=counter},
      {Name="PropertyChangeDebounceTime",Value=counter},
      {Name="MinStandardReportLedFlashTime",Value=counter}
    }

    gateway.submitForwardMessage(SetPropertiesMessage)
    framework.delay(3) -- to allow terminal to save properties

    gateway.setHighWaterMark() -- to get the newest messages
    -- requesting Properties message
    local GetPropertiesMessage = {SIN = vmsSW.sin, MIN = vmsSW:getMinTo("GetProperties")}
    gateway.submitForwardMessage(GetPropertiesMessage)

    -- waiting for Properties message as the response
    ReceivedMessages = vmsSW:waitForMessagesByName({"Properties"})

    assert_not_nil(ReceivedMessages["Properties"], "Properties message not received in response for GetProperties message")

    local ReceivedProperties = ReceivedMessages["Properties"]
    local SetProperties = nameValueToArray(SetPropertiesMessage.Fields)
    local propertyGetByLsf = vmsSW:getPropertiesByName(nameToArray(SetPropertiesMessage.Fields))

    -- modification of propertyGetByLsf entries - conversion to strings
    for index, row in pairs(propertyGetByLsf) do
      value = propertyGetByLsf[index]
      if type(value) == "boolean" then
        if value then
          value = "True"
        else
          value = "False"
        end
      end
      propertyGetByLsf[index] = "" .. value
    end

    D:log(ReceivedProperties)
    D:log(SetProperties)
    D:log(propertyGetByLsf)


    for name, value in pairs(ReceivedProperties) do
          if name ~= "MIN" and name~= "SIN"  and name~= "Name" then
          assert_equal(SetProperties[name], propertyGetByLsf[name], "Property:" ..ReceivedProperties[name] .."has not been correctly set by message")
          assert_equal(SetProperties[name], ReceivedProperties[name], "Property:" ..ReceivedProperties[name] .."has not been correctly set by message")
        end
    end


  end
end


function test_MultipleAbnormalReportsEnabled_When3AbnormalReportsAreTriggered_3AbnormalReportsAreSentByTerminal()

  -- *** Setup
  vmsSW:setPropertiesByName({
                               GpsJammedStartDebounceTime = 1,
                               GpsJammedEndDebounceTime = 1,
                               StandardReport1Interval = 0,
                               ExtPowerDisconnectedStartDebounceTime = 1,
                               ExtPowerDisconnectedEndDebounceTime = 1,
                               HelmPanelDisconnectedStartDebounceTime = 1,
                               HelmPanelDisconnectedEndDebounceTime = 1,
                               GpsJammedSendReport = true,
                               PowerDisconnectedSendReport = true,
                               HelmPanelDisconnectedSendReport = true,
                            }
  )

  gateway.setHighWaterMark() -- to get the newest messages
  GPS:set({jammingDetect = true, fixType = 3})

  -- External power source disconnected from Helm panel
  helmPanel:externalPowerConnected("true")

  -- Helm Panel disconnected from terminal
  helmPanel:setConnected("true")

  framework.delay(35)

  -- receiving all from mobile messages sent after setHighWaterMark()
  local receivedMessages = gateway.getReturnMessages()
  -- look for AbnormalReport messages
  local AllReceivedAbnormalReports = framework.filterMessages(receivedMessages, framework.checkMessageType(115, 50)) -- TODO: service wrapper functions need to be modified

  local namesOfAbnormalReports = {}

  for index, row in pairs(AllReceivedAbnormalReports) do
    namesOfAbnormalReports[#namesOfAbnormalReports+1] = AllReceivedAbnormalReports[index].Payload.EventType
  end

  local expectedAbnormalReports = {"ExtPowerDisconnected", "GpsJammed","HelmPanelDisconnected"}

  D:log(expectedAbnormalReports)
  D:log(namesOfAbnormalReports)
  local counter = 0

  for indexExpected, rowExpected in pairs(expectedAbnormalReports) do

    counter = 0

    for indexReceived, rowReceived in pairs(namesOfAbnormalReports) do
      if expectedAbnormalReports[indexExpected] == namesOfAbnormalReports[indexReceived]  then
        break
      else
          counter = counter + 1
      end
    end
      assert_lt(table.getn(namesOfAbnormalReports), counter, "Abnormal report not received: " .. expectedAbnormalReports[indexExpected] )

  end

end


