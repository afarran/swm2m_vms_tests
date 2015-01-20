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
end

--- setup function
function setup()

  positionSW:setPropertiesByName({continuous = GPS_READ_INTERVAL})
  vmsSW:setPropertiesByName({GpsJammedEndDebounceTime = 1})
  GPS:set({jammingDetect = false, fixType = 3})


end

-----------------------------------------------------------------------------------------------
--- teardown function executed after each unit test
function teardown()


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
                             GpsJammedSendReport = true
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
                             IdpBlockedSendReport = false,
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
                             IdpBlockedSendReport = false,
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
  local POWER_DISCONNECTED_START_DEBOUNCE_TIME = 20   -- seconds
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

  framework.delay(POWER_DISCONNECTED_END_DEBOUNCE_TIME)

  -- checking PowerDisconnectedState property - this is expected to be false - terminal is powered on for time longer than
  local PowerDisconnectedStateProperty = vmsSW:getPropertiesByName({"PowerDisconnectedState"})
  assert_false(PowerDisconnectedStateProperty["PowerDisconnectedState"], "PowerDisconnectedState is incorrectly true")
  D:log(PowerDisconnectedStateProperty, "PowerDisconnectedStateProperty in the start of TC")

  systemSW:restartFramework()

  local timeOfEvent = os.time()  -- to get exact timestamp


  -- receiving all from mobile messages sent after setHighWaterMark()
  local receivedMessages = gateway.getReturnMessages()
  -- look for StationaryIntervalSat messages
  local AllReceivedAbnormalReports = framework.filterMessages(receivedMessages, framework.checkMessageType(115, 50)) -- TODO: service wrapper functions need to be modified


  local PowerDisconnectedAbnormalReport = nil
  for index = 1 , #AllReceivedAbnormalReports, 1 do
    if AllReceivedAbnormalReports[index].Payload.EventType == "PowerDisconnected" then
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






