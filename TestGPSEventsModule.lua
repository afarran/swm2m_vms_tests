-----------
-- Reporting test module
-- - contains VMS reporting features
-- @module TestGPSEventsModule

module("TestGPSEventsModule", package.seeall)


function suite_setup()
  -- reset of properties
  -- restarting VMS agent ?




end

-- executed after each test suite
function suite_teardown()
end

--- setup function
function setup()

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

  local JAMMING_LEVEL = 121                   -- integer decribing level of signal jamming, no unit
  local GPS_JAMMED_START_DEBOUNCE_TIME = 10   -- seconds
  local GPS_JAMMED_END_DEBOUNCE_TIME = 1

  vmsSW:setPropertiesByName({GpsJammedStartDebounceTime = GPS_JAMMED_DEBOUNCE_TIME, GpsJammedEndDebounceTime = GPS_JAMMED_END_DEBOUNCE_TIME}

  )

  -- terminal stationary, GPS signal good initially
  local InitialPosition = {
    speed = 0,                      -- kmh
    latitude = 1,                   -- degrees
    longitude = 1,                  -- degrees
    jammingDetect = false,
    jammingLevel = JAMMING_LEVEL,
  }

  GPS:set(InitialPosition)
  -- GPS signal is jammed from now
  GPS:set({jammingDetect = true})

  -- terminal in different position (wrong GPS data)
  local GpsJammedPosition = {
    speed = 0,                      -- kmh
    latitude = 2,                   -- degrees
    longitude = 2,                  -- degrees
    jammingDetect = true,
    jammingLevel = JAMMING_LEVEL,
  }
  GPS:set(GpsJammedPosition)
  framework.delay(GPS_JAMMED_START_DEBOUNCE_TIME)


 local ReceivedMessages = vmsSW:waitForMessagesByName({"AbnormalReport"})

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

  -- back to initial position with no gps jamming
  GPS:set(InitialPosition)


end



function test_GpsJamming_WhenGpsSignalIsJammedForTimeBelowGpsJammedStartDebouncePeriod_GpsJammedAbnormalReportIsNotSent()

  local JAMMING_LEVEL = 121                   -- integer decribing level of signal jamming, no unit
  local GPS_JAMMED_START_DEBOUNCE_TIME = 30   -- seconds
  local GPS_JAMMED_END_DEBOUNCE_TIME = 1

  vmsSW:setPropertiesByName({GpsJammedStartDebounceTime = GPS_JAMMED_DEBOUNCE_TIME,
                             GpsJammedEndDebounceTime = GPS_JAMMED_END_DEBOUNCE_TIME}
  )

  -- terminal stationary, GPS signal good initially
  local InitialPosition = {
    speed = 0,                      -- kmh
    latitude = 1,                   -- degrees
    longitude = 1,                  -- degrees
    jammingDetect = false,
    jammingLevel = JAMMING_LEVEL,
  }

  GPS:set(InitialPosition)
  -- GPS signal is jammed from now
  GPS:set({jammingDetect = true})

  local ReceivedMessages = vmsSW:waitForMessagesByName({"AbnormalReport"}, 15)

  if(ReceivedMessages["AbnormalReport"] ~= nil) then
    assert_equal(
     "GpsJammed",
      ReceivedMessages["AbnormalReport"].EventType,
     "GpsJammed abnormal report sent but not expected"
    )
  end
  GPS:set(InitialPosition)




end
