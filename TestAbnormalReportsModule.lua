-----------
-- Reporting test module
-- - contains VMS reporting features
-- @module TestGPSEventsModule

module("TestAbnormalReportsModule", package.seeall)


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
  GPS:set({jammingDetect = false})

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
  local GPS_JAMMED_START_DEBOUNCE_TIME = 30   -- seconds
  local GPS_JAMMED_END_DEBOUNCE_TIME = 1      -- seconds

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
    latitude = 2,                   -- degrees
    longitude = 2,                  -- degrees
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
  timeOfEvent = os.time()  -- to get exact timestamp
  GPS:set({jammingDetect = true})
  framework.delay(5)                      -- wait until gps position is read
  GPS:set(GpsJammedPosition)
  framework.delay(GPS_JAMMED_START_DEBOUNCE_TIME)

  local ReceivedMessages = vmsSW:waitForMessagesByName({"AbnormalReport"})

  -- back to initial position with no gps jamming
  GPS:set(InitialPosition)

  assert_not_nil(ReceivedMessages["AbnormalReport"], "AbnormalReport not received")

  assert_equal(
    InitialPosition.latitude*60000,
    tonumber(ReceivedMessages["AbnormalReport"].Latitude),
    "Wrong latitude value in GpsJammed abnormal report"
  )

  assert_equal(
    InitialPosition.longitude*60000,
    tonumber(ReceivedMessages["AbnormalReport"].Longitude),
    "Wrong longitude value in GpsJammed abnormal report"
  )

  assert_equal(
    InitialPosition.speed,
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
    5,
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

  -- TODO: add checking StatusBitmap when the helper function is ready

end


function test_GpsJamming_ForTerminalInGpsJammedStateWhenGpsSignalIsNotJammedForTimeAboveGpsJammedEndDebouncePeriod_GpsJammedAbnormalReportIsSent()

  -- *** Setup
  local GPS_JAMMED_START_DEBOUNCE_TIME = 1    -- seconds
  local GPS_JAMMED_END_DEBOUNCE_TIME = 1      -- seconds

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
  framework.delay(GPS_JAMMED_START_DEBOUNCE_TIME)
  gateway.setHighWaterMark() -- to get the newest messages
  -- GPS signal is good again
  timeOfEvent = os.time()  -- to get exact timestamp
  GPS:set(GpsNotJammedPosition)
  framework.delay(GPS_JAMMED_END_DEBOUNCE_TIME)

  local ReceivedMessages = vmsSW:waitForMessagesByName({"AbnormalReport"})

  assert_not_nil(ReceivedMessages["AbnormalReport"], "AbnormalReport not received")

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
    5,
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

  -- TODO: add checking StatusBitmap when the helper function is ready

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
  gateway.setHighWaterMark() -- to get the newest messages
  GPS:set(InitialPosition)
  -- GPS signal is jammed from now
  GPS:set({jammingDetect = true})

  local ReceivedMessages = vmsSW:waitForMessagesByName({"AbnormalReport"}, 15)

  GPS:set(InitialPosition)

  if(ReceivedMessages["AbnormalReport"] ~= nil and ReceivedMessages["AbnormalReport"].EventType == "GpsJammed" ) then
    assert_nil(1, "GpsJammed abnormal report sent but not expected")
  end


  -- TODO: add checking StatusBitmap when the helper function is ready

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

  local ReceivedMessages = vmsSW:waitForMessagesByName({"AbnormalReport"}, 15)

  -- back to not jammed signal
  GPS:set(InitialPosition)

  if(ReceivedMessages["AbnormalReport"] ~= nil and ReceivedMessages["AbnormalReport"].EventType == "GpsJammed" ) then
    assert_nil(1, "GpsJammed abnormal report sent but not expected")
  end


  -- TODO: add checking StatusBitmap when the helper function is ready


end

