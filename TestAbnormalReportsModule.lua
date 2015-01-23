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
                               GpsJammedSendReport = false,
                               GpsBlockedSendReport = false,
                               IdpBlockedSendReport = false,
                               PowerDisconnectedSendReport = false,
                               HelmPanelDisconnectedSendReport = true,
                            }
  )

  GPS:set({jammingDetect = false, fixType = 3})

  -- External power source disconnected from Helm panel
  shellSW:postEvent(
                    uniboxSW.handleName,
                    uniboxSW.events.external_power_connected,
                    "false"
  )

  -- Helm Panel disconnected from terminal
  shellSW:postEvent(
                    uniboxSW.handleName,
                    uniboxSW.events.connected,
                    "false"
  )





end

-----------------------------------------------------------------------------------------------
--- teardown function executed after each unit test
function teardown()

  GPS:set({jammingDetect = false, fixType = 3})


end

-------------------------
-- Test Cases
-------------------------

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


function test_GpsJamming_ForTerminalInGpsJammedStateWhenGpsSignalIsNotJammedForTimeAboveGpsJammedEndDebouncePeriod_GpsJammedAbnormalReportIsSent()

  -- *** Setup
  local GPS_JAMMED_START_DEBOUNCE_TIME = 1    -- seconds
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


function test_GpsJamming_ForTerminalInGpsJammedStateWhenGpsSignalIsNotJammedForTimeBelowGpsJammedEndDebouncePeriod_GpsJammedAbnormalReportIsNotSent()

  -- *** Setup
  local GPS_JAMMED_START_DEBOUNCE_TIME = 1    -- seconds
  local GPS_JAMMED_END_DEBOUNCE_TIME = 30      -- seconds

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

  local ReceivedMessages = vmsSW:waitForMessagesByName({"AbnormalReport"}, 15)

  if(ReceivedMessages["AbnormalReport"] ~= nil and ReceivedMessages["AbnormalReport"].EventType == "GpsJammed" ) then
    assert_nil(1, "GpsJammed abnormal report sent but not expected")
  end

  -- GPS signal is jammed again from now (the pause in jamming was shorter than GPS_JAMMED_END_DEBOUNCE_TIME)
  GPS:set(GpsJammedPosition)

  -- checking GpsJammedState property - this is expected to be true as signal is still jammed
  local GpsJammedStateProperty = vmsSW:getPropertiesByName({"GpsJammedState"})
  assert_true(GpsJammedStateProperty["GpsJammedState"], "GpsJammedState is incorrectly false for terminal in GpsJammed state")



end



function test_GpsJamming_WhenGpsSignalIsJammedForTimeBelowGpsJammedStartDebouncePeriod_GpsJammedAbnormalReportIsNotSent()

  local GPS_JAMMED_START_DEBOUNCE_TIME = 30   -- seconds
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

  local ReceivedMessages = vmsSW:waitForMessagesByName({"AbnormalReport"}, 15)

  GPS:set(InitialPosition)

  -- checking GpsJammedState property
  local GpsJammedStateProperty = vmsSW:getPropertiesByName({"GpsJammedState"})
  D:log(GpsJammedStateProperty["GpsJammedState"], "GpsJammedStateProperty")
  assert_false(GpsJammedStateProperty["GpsJammedState"], "GpsJammedState property has not been changed correctly when GPS jamming was detected")

  if(ReceivedMessages["AbnormalReport"] ~= nil and ReceivedMessages["AbnormalReport"].EventType == "GpsJammed" ) then
    assert_nil(1, "GpsJammed abnormal report sent but not expected")
  end

end


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

  local ReceivedMessages = vmsSW:waitForMessagesByName({"AbnormalReport"}, 15)

  -- back to not jammed signal
  GPS:set(InitialPosition)


  if(ReceivedMessages["AbnormalReport"] ~= nil and ReceivedMessages["AbnormalReport"].EventType == "GpsJammed" ) then
    assert_nil(1, "GpsJammed abnormal report sent but not expected")
  end

end


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
                             IdpBlockedSendReport = false,
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

  -- *** Execute

  -- TODO: uncomment this section when the funtions are implemented
  -- SatelliteControlState("Active")
  framework.delay(IDP_BLOCKED_END_DEBOUNCE_TIME)   -- wait until terminal goes back to IdpBlocked = false state


  -- terminal in initial position, Satellite Control State is Active now (IDP not blocked)
  GPS:set(InitialPosition)
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

  -- *** Execute


  -- TODO: uncomment this section when the funtions are implemented
  -- SatelliteControlState("Active")

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




function test_PowerDisconnected_WhenTerminalIsOffForTimeAbovePowerDisconnectedStartDebouncePeriod_PowerDisconnectedAbnormalReportIsSentWhenTerminalIsOnAgain()

  -- *** Setup
  local POWER_DISCONNECTED_START_DEBOUNCE_TIME = 1   -- seconds
  local POWER_DISCONNECTED_END_DEBOUNCE_TIME = 1      -- seconds
  local PROPERTIES_SAVE_INTERVAL = 600                      -- seconds

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
  }


  vmsSW:setPropertiesByName({PowerDisconnectedStartDebounceTime = POWER_DISCONNECTED_START_DEBOUNCE_TIME,
                             PowerDisconnectedEndDebounceTime = POWER_DISCONNECTED_END_DEBOUNCE_TIME,
                             PowerDisconnectedSendReport = true,
                             }, false, true
  )

  -- *** Execute
  -- terminal in initial position
  GPS:set(InitialPosition)
  framework.delay(PROPERTIES_SAVE_INTERVAL)
  gateway.setHighWaterMark() -- to get the newest messages
  framework.delay(POWER_DISCONNECTED_START_DEBOUNCE_TIME)

  -- checking PowerDisconnectedState property - this is expected to be false - terminal is powered on for time longer than
  local PowerDisconnectedStateProperty = vmsSW:getPropertiesByName({"PowerDisconnectedState"})
  assert_false(PowerDisconnectedStateProperty["PowerDisconnectedState"], "PowerDisconnectedState is incorrectly true")
  D:log(PowerDisconnectedStateProperty, "PowerDisconnectedStateProperty in the start of TC")

  systemSW:restartFramework()

  GPS:set(AfterRebootPosition)

  local timeOfEvent = os.time()  -- to get exact timestamp

  -- receiving all from mobile messages sent after setHighWaterMark()
  local receivedMessages = gateway.getReturnMessages()
 -- look for AbnormalReport messages
  local AllReceivedAbnormalReports = framework.filterMessages(receivedMessages, framework.checkMessageType(115, 50)) -- TODO: service wrapper functions need to be modified

  D:log(AllReceivedAbnormalReports)

  local PowerDisconnectedAbnormalReport = nil
  for index = 1 , #AllReceivedAbnormalReports, 1 do
    local StatusBitmap = vmsSW:decodeBitmap(AllReceivedAbnormalReports[index].Payload.StatusBitmap, "EventStateId")
    D:log(StatusBitmap["PowerDisconnected"] )
    if AllReceivedAbnormalReports[index].Payload.EventType == "PowerDisconnected" and StatusBitmap["PowerDisconnected"] == true then
        PowerDisconnectedAbnormalReport = AllReceivedAbnormalReports[index]
        break
    end
  end


  D:log(PowerDisconnectedAbnormalReport)

  assert_not_nil(PowerDisconnectedAbnormalReport, "AbnormalReport  with PowerDisconnected information not received")

  assert_equal(
    InitialPosition.latitude*60000,
    tonumber(PowerDisconnectedAbnormalReport.Payload.Latitude),
    "Wrong latitude value in PowerDisconnected abnormal report"
  )

  assert_equal(
    InitialPosition.longitude*60000,
    tonumber(PowerDisconnectedAbnormalReport.Payload.Longitude),
    "Wrong longitude value in PowerDisconnected abnormal report"
  )

  assert_equal(
    InitialPosition.speed,
    tonumber(PowerDisconnectedAbnormalReport.Payload.Speed),
    "Wrong speed value in PowerDisconnected abnormal report"
  )

  assert_equal(
    361,
    tonumber(PowerDisconnectedAbnormalReport.Payload.Course),
    "Wrong course value in PowerDisconnected abnormal report"
  )

  assert_equal(
    timeOfEvent,
    tonumber(PowerDisconnectedAbnormalReport.Payload.Timestamp),
    20,
    "Wrong Timestamp value in PowerDisconnected abnormal report"
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


  local StatusBitmap = vmsSW:decodeBitmap(PowerDisconnectedAbnormalReport.Payload.StatusBitmap, "EventStateId")
  assert_true(StatusBitmap["PowerDisconnected"], "PowerDisconnected bit in StatusBitmap has not been correctly changed when terminal was power-cycled")

end



function test_PowerDisconnected_WhenTerminalIsOffForTimeBelowPowerDisconnectedStartDebouncePeriod_PowerDisconnectedAbnormalReportIsNotSentWhenTerminalIsOnAgain()

  -- *** Setup
  local POWER_DISCONNECTED_START_DEBOUNCE_TIME = 1          -- seconds
  local POWER_DISCONNECTED_END_DEBOUNCE_TIME = 4000         -- seconds
  local PROPERTIES_SAVE_INTERVAL = 600                      -- seconds

  -- terminal stationary
  local InitialPosition = {
    speed = 0,                      -- kmh
    latitude = 1,                   -- degrees
    longitude = 1,                  -- degrees
  }

  vmsSW:setPropertiesByName({PowerDisconnectedStartDebounceTime = POWER_DISCONNECTED_START_DEBOUNCE_TIME,
                             PowerDisconnectedEndDebounceTime = POWER_DISCONNECTED_END_DEBOUNCE_TIME,
                             PowerDisconnectedSendReport = true,
                             }, false, true
  )

  -- *** Execute
  -- terminal in initial position
  GPS:set(InitialPosition)
  gateway.setHighWaterMark() -- to get the newest messages

  framework.delay(POWER_DISCONNECTED_START_DEBOUNCE_TIME)

  -- checking PowerDisconnectedState property - this is expected to be false - terminal is powered on for time longer than
  local PowerDisconnectedStateProperty = vmsSW:getPropertiesByName({"PowerDisconnectedState"})
  assert_false(PowerDisconnectedStateProperty["PowerDisconnectedState"], "PowerDisconnectedState is incorrectly true")
  D:log(PowerDisconnectedStateProperty, "PowerDisconnectedStateProperty in the start of TC")

  D:log(os.time(), "timestamp before saving properties")
  framework.delay(PROPERTIES_SAVE_INTERVAL + 5) -- wait until previous SysTime is saved in non volatile memory
  D:log(os.time(), "timestamp after saving properties")

  systemSW:restartFramework()

  local timeOfEvent = os.time()  -- to get exact timestamp


  -- receiving all from mobile messages sent after setHighWaterMark()
  local receivedMessages = gateway.getReturnMessages()
 -- look for AbnormalReport messages
  local AllReceivedAbnormalReports = framework.filterMessages(receivedMessages, framework.checkMessageType(115, 50)) -- TODO: service wrapper functions need to be modified


  local PowerDisconnectedAbnormalReport = nil
  for index = 1 , #AllReceivedAbnormalReports, 1 do
    if AllReceivedAbnormalReports[index].Payload.EventType == "PowerDisconnected" then
        PowerDisconnectedAbnormalReport = AllReceivedAbnormalReports[index]
        break
    end
  end


  D:log(PowerDisconnectedAbnormalReport)

  assert_nil(PowerDisconnectedAbnormalReport, "AbnormalReport with PowerDisconnected information received but not expected")


end




function test_PowerDisconnected_ForTerminalInPowerDisconnectedStateWhenTerminalIsOnForTimeAbovePowerDisconnectedEndDebouncePeriod_PowerDisconnectedAbnormalReportIsSent()

  -- *** Setup
  local POWER_DISCONNECTED_START_DEBOUNCE_TIME = 30     -- seconds
  local POWER_DISCONNECTED_END_DEBOUNCE_TIME = 1      -- seconds

  -- terminal stationary
  local InitialPosition = {
    speed = 0,                      -- kmh
    latitude = 1,                   -- degrees
    longitude = 1,                  -- degrees
  }

  vmsSW:setPropertiesByName({PowerDisconnectedStartDebounceTime = POWER_DISCONNECTED_START_DEBOUNCE_TIME,
                             PowerDisconnectedEndDebounceTime = POWER_DISCONNECTED_END_DEBOUNCE_TIME,
                             PowerDisconnectedSendReport = true,
                             }, false, true
  )

  -- *** Execute
  -- terminal in initial position
  GPS:set(InitialPosition)
  gateway.setHighWaterMark() -- to get the newest messages

  systemSW:restartFramework()

  framework.delay(2) -- wait until the VMS is up again
  --[[
  -- checking PowerDisconnectedState property - this is expected to be true - terminal has been off for time longer than PowerDisconnectedStartDebounceTime
  local PowerDisconnectedStateProperty = vmsSW:getPropertiesByName({"PowerDisconnectedState"})
  assert_true(PowerDisconnectedStateProperty["PowerDisconnectedState"], "PowerDisconnectedState is incorrectly false")
  D:log(PowerDisconnectedStateProperty, "PowerDisconnectedStateProperty in the start of TC")
  --]]
  framework.delay(POWER_DISCONNECTED_START_DEBOUNCE_TIME)

  local timeOfEvent = os.time()  -- to get exact timestamp

  -- receiving all from mobile messages sent after setHighWaterMark()
  local receivedMessages = gateway.getReturnMessages()
 -- look for AbnormalReport messages
  local AllReceivedAbnormalReports = framework.filterMessages(receivedMessages, framework.checkMessageType(115, 50)) -- TODO: service wrapper functions need to be modified

  -- checking PowerDisconnectedState property - this is expected to be false - terminal is powered on for time longer than
  local PowerDisconnectedStateProperty = vmsSW:getPropertiesByName({"PowerDisconnectedState"})
  assert_false(PowerDisconnectedStateProperty["PowerDisconnectedState"], "PowerDisconnectedState is incorrectly true")
  D:log(PowerDisconnectedStateProperty, "PowerDisconnectedStateProperty in the start of TC")

  local PowerDisconnectedAbnormalReport = nil
  for index = 1 , #AllReceivedAbnormalReports, 1 do

    local StatusBitmap = vmsSW:decodeBitmap(AllReceivedAbnormalReports[index].Payload.StatusBitmap, "EventStateId")
    D:log(StatusBitmap["PowerDisconnected"])
    if AllReceivedAbnormalReports[index].Payload.EventType == "PowerDisconnected" and StatusBitmap["PowerDisconnected"] ~= true then
        PowerDisconnectedAbnormalReport = AllReceivedAbnormalReports[index]
        break
    end
  end


  D:log(PowerDisconnectedAbnormalReport)

  assert_not_nil(PowerDisconnectedAbnormalReport, "AbnormalReport  with PowerDisconnected information not received")

  assert_equal(
    InitialPosition.latitude*60000,
    tonumber(PowerDisconnectedAbnormalReport.Payload.Latitude),
    "Wrong latitude value in PowerDisconnected abnormal report"
  )

  assert_equal(
    InitialPosition.longitude*60000,
    tonumber(PowerDisconnectedAbnormalReport.Payload.Longitude),
    "Wrong longitude value in PowerDisconnected abnormal report"
  )

  assert_equal(
    InitialPosition.speed,
    tonumber(PowerDisconnectedAbnormalReport.Payload.Speed),
    "Wrong speed value in PowerDisconnected abnormal report"
  )

  assert_equal(
    361,
    tonumber(PowerDisconnectedAbnormalReport.Payload.Course),
    "Wrong course value in PowerDisconnected abnormal report"
  )

  assert_equal(
    timeOfEvent,
    tonumber(PowerDisconnectedAbnormalReport.Payload.Timestamp),
    20,
    "Wrong Timestamp value in PowerDisconnected abnormal report"
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


  local StatusBitmap = vmsSW:decodeBitmap(PowerDisconnectedAbnormalReport.Payload.StatusBitmap, "EventStateId")
  assert_false(StatusBitmap["PowerDisconnected"], "PowerDisconnected bit in StatusBitmap has not been correctly changed when terminal was power-cycled")

end




function test_PowerDisconnected_WhenTerminalIsOffForTimeAbovePowerDisconnectedStartDebouncePeriodButPowerDisconnectedReportsAreDisabled_PowerDisconnectedAbnormalReportAreNotSentWhenTerminalIsOnAgain()

  -- *** Setup
  local POWER_DISCONNECTED_START_DEBOUNCE_TIME = 1   -- seconds
  local POWER_DISCONNECTED_END_DEBOUNCE_TIME = 1      -- seconds

  -- terminal stationary
  local InitialPosition = {
    speed = 0,                      -- kmh
    latitude = 1,                   -- degrees
    longitude = 1,                  -- degrees
  }

  vmsSW:setPropertiesByName({PowerDisconnectedStartDebounceTime = POWER_DISCONNECTED_START_DEBOUNCE_TIME,
                             PowerDisconnectedEndDebounceTime = POWER_DISCONNECTED_END_DEBOUNCE_TIME,
                             PowerDisconnectedSendReport = false,
                             }, false, true
  )

  -- *** Execute
  -- terminal in initial position
  GPS:set(InitialPosition)
  gateway.setHighWaterMark() -- to get the newest messages

  framework.delay(POWER_DISCONNECTED_START_DEBOUNCE_TIME)


  systemSW:restartFramework()

  local timeOfEvent = os.time()  -- to get exact timestamp

  -- receiving all from mobile messages sent after setHighWaterMark()
  local receivedMessages = gateway.getReturnMessages()
 -- look for AbnormalReport messages
  local AllReceivedAbnormalReports = framework.filterMessages(receivedMessages, framework.checkMessageType(115, 50)) -- TODO: service wrapper functions need to be modified

  D:log(AllReceivedAbnormalReports)

  local PowerDisconnectedAbnormalReport = nil
  for index = 1 , #AllReceivedAbnormalReports, 1 do
    local StatusBitmap = vmsSW:decodeBitmap(AllReceivedAbnormalReports[index].Payload.StatusBitmap, "EventStateId")
    D:log(StatusBitmap["PowerDisconnected"] )
    if AllReceivedAbnormalReports[index].Payload.EventType == "PowerDisconnected" then
        PowerDisconnectedAbnormalReport = AllReceivedAbnormalReports[index]
        break
    end
  end


  D:log(PowerDisconnectedAbnormalReport)

  assert_nil(PowerDisconnectedAbnormalReport, "AbnormalReport  with PowerDisconnected information received when sending reports is disabled")


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


function test_GpsBlocked_WhenGpsSignalIsBlockedAndNoFixWasEverObtainedByTerminal_DefaultValuesOfLattitudeAndLongitudeAreSentInReports()

  -- TODO: THIS need to be a first TC to be run - just after formatting terminal!

  -- *** Setup
  -- terminal in some position but no valid fix provided
  local GpsBlockedPosition = {
                              speed = 0,                      -- kmh
                              latitude = 1,                   -- degrees
                              longitude = 1,                  -- degrees
                              fixType = 1,                    -- no fix
  }

  -- GPS signal is blocked from now - no fix provided
  GPS:set(GpsBlockedPosition)

  vmsSW:setPropertiesByName({
                             StandardReport1Interval = 2,
                             AcceleratedReport1Rate = 2,
                            }
  )

  -- *** Execute
  gateway.setHighWaterMark() -- to get the newest messages
  -- Waiting for StandardReport
  local ReceivedMessages = vmsSW:waitForMessagesByName({"StandardReport1"}, 125)
  D:log(ReceivedMessages["StandardReport1"])

  ReceivedMessages = vmsSW:waitForMessagesByName({"AcceleratedReport1"}, 125)
  D:log(ReceivedMessages["AcceleratedReport1"])


  assert_equal(
    5460000,
    tonumber(ReceivedMessages["StandardReport1"].Latitude),
    "Wrong latitude value in StandardReport received when no fix has been obtained by terminal"
  )

  assert_equal(
    10860000,
    tonumber(ReceivedMessages["StandardReport1"].Longitude),
    "Wrong longitude value in StandardReport received when no fix has been obtained by terminal"
  )


  assert_equal(
    5460000,
    tonumber(ReceivedMessages["AcceleratedReport1"].Latitude),
    "Wrong latitude value in AcceleratedReport received when no fix has been obtained by terminal"
  )

  assert_equal(
    10860000,
    tonumber(ReceivedMessages["AcceleratedReport1"].Longitude),
    "Wrong longitude value in AcceleratedReport received when no fix has been obtained by terminal"
  )


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
  shellSW:postEvent(
                    uniboxSW.handleName,
                    uniboxSW.events.external_power_connected,
                    "true"
  )

  D:log("HELM PANEL CONNECTED")

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

  local StatusBitmap = vmsSW:decodeBitmap(ReceivedMessages["AbnormalReport"].StatusBitmap, "EventStateId")
  assert_false(StatusBitmap["ExtPowerDisconnected"], "StatusBitmap has not been correctly changed to false when external power source of helm panel was connected")


  D:log("HELM PANEL DISCONNECTED")

  -- back to exernal power disconnected
  shellSW:postEvent(
                    uniboxSW.handleName,
                    uniboxSW.events.external_power_connected,
                    "false"
  )


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

  D:log("HELM PANEL CONNECTED")
  -- Helm Panel is connected to external power from now
  shellSW:postEvent(
                    uniboxSW.handleName,
                    uniboxSW.events.external_power_connected,
                    "true"
  )

  framework.delay(EXT_POWER_DISCONNECTED_END_DEBOUNCE_TIME)


  -- checking ExtPowerDisconnectedState property
  local ExtPowerDisconnectedStateProperty = vmsSW:getPropertiesByName({"ExtPowerDisconnectedState"})
  D:log(framework.dump(ExtPowerDisconnectedStateProperty["ExtPowerDisconnectedState"]), "ExtPowerDisconnectedStateProperty" )
  assert_false(ExtPowerDisconnectedStateProperty["ExtPowerDisconnectedState"], "ExtPowerDisconnectedState property is incorrectly true")

  gateway.setHighWaterMark() -- to get the newest messages

  D:log("HELM PANEL DISCONNECTED")
  -- Helm Panel is connected to external power from now
  shellSW:postEvent(
                    uniboxSW.handleName,
                    uniboxSW.events.external_power_connected,
                    "false"
  )

  -- checking ExtPowerDisconnectedState property
  local ExtPowerDisconnectedStateProperty = vmsSW:getPropertiesByName({"ExtPowerDisconnectedState"})
  D:log(framework.dump(ExtPowerDisconnectedStateProperty["ExtPowerDisconnectedState"]), "ExtPowerDisconnectedStateProperty")
  assert_false(ExtPowerDisconnectedStateProperty["ExtPowerDisconnectedState"], "ExtPowerDisconnectedState has changed to true before ExtPowerDisconnectedStartDebounceTime time has passed")

  framework.delay(EXT_POWER_DISCONNECTED_START_DEBOUNCE_TIME)
  timeOfEvent = os.time()

  local ReceivedMessages = vmsSW:waitForMessagesByName({"AbnormalReport"})
  D:log(ReceivedMessages["AbnormalReport"])

  -- checking ExtPowerDisconnectedState property
  local ExtPowerDisconnectedStateProperty = vmsSW:getPropertiesByName({"ExtPowerDisconnectedState"})
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
  D:log("HELM PANEL CONNECTED")
  -- Helm Panel is connected to external power from now
  shellSW:postEvent(
                    uniboxSW.handleName,
                    uniboxSW.events.external_power_connected,
                    "true"
  )

  local ReceivedMessages = vmsSW:waitForMessagesByName({"AbnormalReport"}, 15)
  D:log(ReceivedMessages["AbnormalReport"])

  if(ReceivedMessages["AbnormalReport"] ~= nil and ReceivedMessages["AbnormalReport"].EventType == "ExtPowerDisconnected" ) then
    assert_nil(1, "ExtPowerDisconnected abnormal report sent but not expected")
  end

  D:log("HELM PANEL DISCONNECTED")
  -- back to exernal power disconnected
  shellSW:postEvent(
                    uniboxSW.handleName,
                    uniboxSW.events.external_power_connected,
                    "false"
  )


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
  shellSW:postEvent(
                    uniboxSW.handleName,
                    uniboxSW.events.external_power_connected,
                    "true"
  )

  framework.delay(EXT_POWER_DISCONNECTED_END_DEBOUNCE_TIME)

  -- checking ExtPowerDisconnectedState property
  local ExtPowerDisconnectedStateProperty = vmsSW:getPropertiesByName({"ExtPowerDisconnectedState"})
  D:log(framework.dump(ExtPowerDisconnectedStateProperty["ExtPowerDisconnectedState"]), "ExtPowerDisconnectedStateProperty" )
  assert_false(ExtPowerDisconnectedStateProperty["ExtPowerDisconnectedState"], "ExtPowerDisconnectedState property is incorrectly true")

  gateway.setHighWaterMark() -- to get the newest messages
  D:log("HELM PANEL DISCONNECTED")
  -- Helm Panel is connected to external power from now
  shellSW:postEvent(
                    uniboxSW.handleName,
                    uniboxSW.events.external_power_connected,
                    "false"
  )

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

  D:log("HELM PANEL CONNECTED")
  -- Helm Panel is connected to external power from now
  shellSW:postEvent(
                    uniboxSW.handleName,
                    uniboxSW.events.external_power_connected,
                    "true"
  )

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

  D:log("HELM PANEL DISCONNECTED")
  -- Helm Panel is connected to external power from now
  shellSW:postEvent(
                    uniboxSW.handleName,
                    uniboxSW.events.external_power_connected,
                    "false"
  )

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
  shellSW:postEvent(
                    uniboxSW.handleName,
                    uniboxSW.events.connected,
                    "true"
  )

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

  local StatusBitmap = vmsSW:decodeBitmap(ReceivedMessages["AbnormalReport"].StatusBitmap, "EventStateId")
  assert_false(StatusBitmap["HelmPanelDisconnected"], "StatusBitmap has not been correctly changed to false when Helm panel was connected to terminal")

  D:log("HELM PANEL DISCONNECTED FROM TERMINAL")

  -- back to helm panel disconnected
  shellSW:postEvent(
                    uniboxSW.handleName,
                    uniboxSW.events.connected,
                    "false"
  )


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
  shellSW:postEvent(
                    uniboxSW.handleName,
                    uniboxSW.events.connected,
                    "true"
  )

  D:log("HELM PANEL CONNECTED TO TERMINAL")
  framework.delay(HELM_PANEL_DISCONNECTED_END_DEBOUNCE_TIME)

  -- checking HelmPanelDisconnectedState property
  HelmPanelDisconnectedStateProperty = vmsSW:getPropertiesByName({"HelmPanelDisconnectedState"})
  D:log(framework.dump(HelmPanelDisconnectedStateProperty["HelmPanelDisconnectedState"]), "HelmPanelDisconnectedState")
  assert_false(HelmPanelDisconnectedStateProperty["HelmPanelDisconnectedState"], "HelmPanelDisconnectedState property has not been changed after HelmPanelDisconnectedEndDebounceTime has passed")

  D:log("HELM PANEL DISCONNECTED TO TERMINAL")
  gateway.setHighWaterMark() -- to get the newest messages
  -- Helm Panel is connected to terminal from now
  shellSW:postEvent(
                    uniboxSW.handleName,
                    uniboxSW.events.connected,
                    "false"
  )

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

  local StatusBitmap = vmsSW:decodeBitmap(ReceivedMessages["AbnormalReport"].StatusBitmap, "EventStateId")
  assert_true(StatusBitmap["HelmPanelDisconnected"], "StatusBitmap has not been correctly changed to false when Helm panel was disconnected from terminal")

  D:log("HELM PANEL DISCONNECTED FROM TERMINAL")

  -- back to helm panel disconnected
  shellSW:postEvent(
                    uniboxSW.handleName,
                    uniboxSW.events.connected,
                    "false"
  )


end




function test_HelmPanelDisconnected_WhenHelmPanelIsConnectedForTimeBelowHelmPanelDisconnectedEndDebounceTime_HelmPanelDisconnectedAbnormalReportIsNotSent()

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
  shellSW:postEvent(
                    uniboxSW.handleName,
                    uniboxSW.events.connected,
                    "true"
  )

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
  shellSW:postEvent(
                    uniboxSW.handleName,
                    uniboxSW.events.connected,
                    "false"
  )


end






