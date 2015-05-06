-----------------------------------------------------------------------------------------------
-- VMS Normal Reporting test module
-----------------------------------------------------------------------------------------------
-- Contains VMS reporting features (Standard, Accelerated , Log , ConfigChange reports)
-----------------------------------------------------------------------------------------------
-- @module TestNormalReportModule
-----------------------------------------------------------------------------------------------

module("TestNormalReportsModule", package.seeall)

-- 1 turns debug output ON 
-- 0 turns debug output OFF
-- For more info see: Debugger.lua
DEBUG_MODE = 1 

-----------------------------------------------------------------------------------------------
-- SETUP
-----------------------------------------------------------------------------------------------
function suite_setup()
  -- reset of properties
  systemSW:resetProperties({vmsSW.sin})

  -- debounce
  vmsSW:setPropertiesByName({PropertyChangeDebounceTime=1})

  -- initial gps position
  local pos = {
    latitude = 0,
    longitude = 0,
    speed = 0,
    heading = 0
  }
  GPS:set(pos)

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

  vmsSW:setPropertiesByName({
      -- disabling periodic reports
      -- all *Intervals are in minutes
      -- all *Rates means "divided by rate"
      StandardReport1Interval = 0,
      AcceleratedReport1Rate = 1,
      StandardReport2Interval = 0,
      AcceleratedReport2Rate = 1,
      StandardReport3Interval = 0,
      AcceleratedReport3Rate = 1,
      -- ... and debounce time in seconds
      PropertyChangeDebounceTime=1 
  })

end
-----------------------------------------------------------------------------------------------
-- Test Cases for STANDARD REPORTS
-----------------------------------------------------------------------------------------------

Annotations:register([[
@randIn(tcRandomizer,batch,standardReportPeriodic,3)
@method(test_ATStandardReport_WhenReportIntervalIsSetAboveZero_StandardReport1IsSentPeriodicallyWithCorrectValues)
@module(TestNormalReportsModule)
]])
--- TC checks if StandardReport 1 is sent periodically and its values are correct (setProperties used for report setup)
  -- Initial Conditions:
  --
  -- * StandardReport1Interval is set above zero.
  -- * AcceleratedReport1Rate is set to 1 - accelerated reports are not triggered
  --
  -- Steps:
  --
  -- 1. Properties setup is done (via setProperties) .
  -- 2. Current gps position is requested.
  -- 3. Current gps position is checked.
  -- 4. Waiting for first Standard Report is performed.
  -- 5. New gps position is prepared and set.
  -- 6. Waiting for second Standard Report is performed.
  -- 7. Difference between reports is calculated.
  -- 8. Values in report are checked.
  --
  -- Results:
  --
  -- 1. Properties are set correctly.
  -- 2. Current gps position is fetched.
  -- 3. Current gps position is correct.
  -- 4. Timer is synchronized to the first standard report
  -- 5. New gps position is correctly set.
  -- 6. Standard Report is delivered.
  -- 7. Difference between reports is correct.
  -- 8. Values in report are correct.
  -- [OK]
function test_ATStandardReport_WhenReportIntervalIsSetAboveZero_StandardReport1IsSentPeriodicallyWithCorrectValues()
  generic_test_StandardReportContent({
    firstReportKey = "StandardReport1",
    reportKey = "StandardReport1",
    properties = {StandardReport1Interval=1, AcceleratedReport1Rate=1}, -- minute , divide
    firstReportInterval = 1, -- minute
    reportInterval = 1 -- minute
  })
end

Annotations:register([[
@randIn(tcRandomizer,batch,standardReportPeriodic,3)
@method(test_ATStandardReport_WhenReportIntervalIsSetAboveZero_StandardReport2IsSentPeriodicallyWithCorrectValues)
@module(TestNormalReportsModule)
]])
--- TC checks if StandardReport 2 is sent periodically and its values are correct (setProperties used for report setup)
  -- Initial Conditions:
  --
  -- * StandardReport2Interval is set above zero.
  -- * AcceleratedReport2Rate is set to 1 - accelerated reports are not triggered
  --
  -- Steps:
  --
  -- 1. Properties setup is done (via setProperties) .
  -- 2. Current gps position is requested.
  -- 3. Current gps position is checked.
  -- 4. Waiting for first Standard Report is performed.
  -- 5. New gps position is prepared and set.
  -- 6. Waiting for second Standard Report is performed.
  -- 7. Difference between reports is calculated.
  -- 8. Values in report are checked.
  --
  -- Results:
  --
  -- 1. Properties are set correctly.
  -- 2. Current gps position is fetched.
  -- 3. Current gps position is correct.
  -- 4. Timer is synchronized to the first standard report
  -- 5. New gps position is correctly set.
  -- 6. Standard Report is delivered.
  -- 7. Difference between reports is correct.
  -- 8. Values in report are correct.
  -- [OK]
function test_ATStandardReport_WhenReportIntervalIsSetAboveZero_StandardReport2IsSentPeriodicallyWithCorrectValues()
  generic_test_StandardReportContent({
    firstReportKey = "StandardReport2",
    reportKey = "StandardReport2",
    properties = {StandardReport2Interval=1, AcceleratedReport2Rate=1}, -- minute , divide
    firstReportInterval = 1, -- minute
    reportInterval = 1 -- minute
  })

end


Annotations:register([[
@randIn(tcRandomizer,batch,standardReportPeriodic,3)
@method(test_ATStandardReport_WhenReportIntervalIsSetAboveZero_StandardReport3IsSentPeriodicallyWithCorrectValues)
@module(TestNormalReportsModule)
]])
--- TC checks if StandardReport 3 is sent periodically and its values are correct (setProperties used for report setup)
  -- Initial Conditions:
  --
  -- * StandardReport3Interval is set above zero.
  -- * AcceleratedReport3Rate is set to 1 - accelerated reports are not triggered
  --
  -- Steps:
  --
  -- 1. Properties setup is done (via setProperties) .
  -- 2. Current gps position is requested.
  -- 3. Current gps position is checked.
  -- 4. Waiting for first Standard Report is performed.
  -- 5. New gps position is prepared and set.
  -- 6. Waiting for second Standard Report is performed.
  -- 7. Difference between reports is calculated.
  -- 8. Values in report are checked.
  --
  -- Results:
  --
  -- 1. Properties are set correctly.
  -- 2. Current gps position is fetched.
  -- 3. Current gps position is correct.
  -- 4. Timer is synchronized to the first standard report
  -- 5. New gps position is correctly set.
  -- 6. Standard Report is delivered.
  -- 7. Difference between reports is correct.
  -- 8. Values in report are correct.
  -- [OK]
function test_ATStandardReport_WhenReportIntervalIsSetAboveZero_StandardReport3IsSentPeriodicallyWithCorrectValues()
  generic_test_StandardReportContent({
    firstReportKey = "StandardReport3",
    reportKey = "StandardReport3",
    properties = {StandardReport3Interval=1, AcceleratedReport3Rate=1}, -- minute , divide
    firstReportInterval = 1, -- minute
    reportInterval = 1 -- minute
  })
end

--- TC checks if StandardReport 1 is sent periodically and its values are correct (SetConfigReport1 used for report setup)
  -- Initial Conditions:
  --
  -- * StandardReport1Interval is set above zero.
  -- * AcceleratedReport1Rate is set to 1 - accelerated reports are not triggered
  --
  -- Steps:
  --
  -- 1. SetConfigReport1 message is sent .
  -- 2. Current gps position is requested.
  -- 3. Current gps position is checked.
  -- 4. Waiting for first Standard Report is performed.
  -- 5. New gps position is prepared and set.
  -- 6. Waiting for second Standard Report is performed.
  -- 7. Difference between reports is calculated.
  -- 8. Values in report are checked.
  --
  -- Results:
  --
  -- 1. ConfigChangeReport1 is received.
  -- 2. Current gps position is fetched.
  -- 3. Current gps position is correct.
  -- 4. Timer is synchronized to the first standard report
  -- 5. New gps position is correctly set.
  -- 6. Standard Report is delivered.
  -- 7. Difference between reports is correct.
  -- 8. Values in report are correct.
  -- [OK]
function test_TTStandardReport_WhenReportIntervalIsSetAboveZeroAndSetConfigReport1MessageIsSent_StandardReport1IsSentPeriodicallyWithCorrectValues()
  generic_test_StandardReportContent({
    firstReportKey = "StandardReport1",
    reportKey ="StandardReport1",
    properties = {StandardReport1Interval=1, AcceleratedReport1Rate=1}, --minutes,divide
    firstReportInterval = 1,  --minutes
    reportInterval = 1, --minutes
    setConfigMsgKey = "SetConfigReport1",
    configChangeMsgKey = "ConfigChangeReport1",
    fields = {
      {Name = "StandardReport1Interval" , Value = 1},
      {Name = "AcceleratedReport1Rate" , Value = 1}
    }
  })
end

--- TC checks if StandardReport 2 is sent periodically and its values are correct (SetConfigReport2 used for report setup)
  -- Initial Conditions:
  --
  -- * StandardReport2Interval is set above zero.
  -- * AcceleratedReport2Rate is set to 1 - accelerated reports are not triggered
  --
  -- Steps:
  --
  -- 1. SetConfigReport2 message is sent .
  -- 2. Current gps position is requested.
  -- 3. Current gps position is checked.
  -- 4. Waiting for first Standard Report is performed.
  -- 5. New gps position is prepared and set.
  -- 6. Waiting for second Standard Report is performed.
  -- 7. Difference between reports is calculated.
  -- 8. Values in report are checked.
  --
  -- Results:
  --
  -- 1. ConfigChangeReport2 is received.
  -- 2. Current gps position is fetched.
  -- 3. Current gps position is correct.
  -- 4. Timer is synchronized to the first standard report
  -- 5. New gps position is correctly set.
  -- 6. Standard Report is delivered.
  -- 7. Difference between reports is correct.
  -- 8. Values in report are correct.
  -- [OK]
function test_TTStandardReport_WhenReportIntervalIsSetAboveZeroAndSetConfigReport2MessageIsSent_StandardReport2IsSentPeriodicallyWithCorrectValues()
   generic_test_StandardReportContent({
    firstReportKey = "StandardReport2",
    reportKey ="StandardReport2",
    properties = {StandardReport2Interval=1, AcceleratedReport2Rate=1}, --minutes,divide
    firstReportInterval = 1,  --minutes
    reportInterval = 1, --minutes
    setConfigMsgKey = "SetConfigReport2",
    configChangeMsgKey = "ConfigChangeReport2",
    fields = {
      {Name = "StandardReport2Interval" , Value = 1},
      {Name = "AcceleratedReport2Rate" , Value = 1}
    }
  })
end

--- TC checks if StandardReport 3 is sent periodically and its values are correct (SetConfigReport3 used for report setup)
  -- Initial Conditions:
  --
  -- * StandardReport3Interval is set above zero.
  -- * AcceleratedReport3Rate is set to 1 - accelerated reports are not triggered
  --
  -- Steps:
  --
  -- 1. SetConfigReport3 message is sent .
  -- 2. Current gps position is requested.
  -- 3. Current gps position is checked.
  -- 4. Waiting for first Standard Report is performed.
  -- 5. New gps position is prepared and set.
  -- 6. Waiting for second Standard Report is performed.
  -- 7. Difference between reports is calculated.
  -- 8. Values in report are checked.
  --
  -- Results:
  --
  -- 1. ConfigChangeReport3 is received.
  -- 2. Current gps position is fetched.
  -- 3. Current gps position is correct.
  -- 4. Timer is synchronized to the first standard report
  -- 5. New gps position is correctly set.
  -- 6. Standard Report is delivered.
  -- 7. Difference between reports is correct.
  -- 8. Values in report are correct.
  -- [OK]
function test_TTStandardReport_WhenReportIntervalIsSetAboveZeroAndSetConfigReport3MessageIsSent_StandardReport3IsSentPeriodicallyWithCorrectValues()

  generic_test_StandardReportContent({
    firstReportKey = "StandardReport3",
    reportKey ="StandardReport3",
    properties = {StandardReport3Interval=1, AcceleratedReport3Rate=1}, --minutes,divide
    firstReportInterval = 1,  --minutes
    reportInterval = 1, --minutes
    setConfigMsgKey = "SetConfigReport3",
    configChangeMsgKey = "ConfigChangeReport3",
    fields = {
      {Name = "StandardReport3Interval" , Value = 1},
      {Name = "AcceleratedReport3Rate" , Value = 1}
    }
  })

end

--- TC checks if StandardReport 1 is not sent
  -- Initial Conditions:
  --
  -- * StandardReport1Interval is set to 0.
  -- * AcceleratedReport1Rate is set to 1 - accelerated reports are not triggered
  --
  -- Steps:
  --
  -- 1. Properties are sent.
  -- 2. Waiting for Standard Report is performed.
  --
  -- Results:
  --
  -- 1. Properties are correctly set.
  -- 2. Standard Report doesn't come and that is correct.
  -- [OK]
function test_StandardReportDisabled_WhenStandardReport1IntervalIsSetToZero_StandardReport1IsNotSent()
  vmsSW:setPropertiesByName({PropertyChangeDebounceTime=1})
  generic_test_StandardReportDisabled(
    "StandardReport1",
    {StandardReport1Interval=0, AcceleratedReport1Rate=1},
    120, -- waiting until report not come,
    "AcceleratedReport1"
  )
end

-- TC checks if StandardReport 2 is not sent
  -- Initial Conditions:
  --
  -- * StandardReport2Interval is set to 0.
  -- * AcceleratedReport2Rate is set to 1 - accelerated reports are not triggered
  --
  -- Steps:
  --
  -- 1. Properties are sent.
  -- 2. Waiting for Standard Report is performed.
  --
  -- Results:
  --
  -- 1. Properties are correctly set.
  -- 2. Standard Report doesn't come and that is correct.
  -- [OK]
function test_StandardReportDisabled_WhenStandardReport2IntervalIsSetToZero_StandardReport2IsNotSent()
  vmsSW:setPropertiesByName({PropertyChangeDebounceTime=1})
  generic_test_StandardReportDisabled(
    "StandardReport2",
    {StandardReport2Interval=0, AcceleratedReport2Rate=1},
    120, -- waiting until report not come
    "AcceleratedReport2"
  )
end

-- TC checks if StandardReport 3 is not sent
  -- Initial Conditions:
  --
  -- * StandardReport3Interval is set to 0.
  -- * AcceleratedReport3Rate is set to 1 - accelerated reports are not triggered
  --
  -- Steps:
  --
  -- 1. Properties are sent.
  -- 2. Waiting for Standard Report is performed.
  --
  -- Results:
  --
  -- 1. Properties are correctly set.
  -- 2. Standard Report doesn't come and that is correct.
  -- [OK]
function test_StandardReportDisabled_WhenStandardReport3IntervalIsSetToZero_StandardReport3IsNotSent()
  vmsSW:setPropertiesByName({PropertyChangeDebounceTime=1})
  generic_test_StandardReportDisabled(
    "StandardReport3",
    {StandardReport3Interval=0, AcceleratedReport3Rate=1},
    120,
    "AcceleratedReport3"
  )
end

--- TC checks if StandardReport 1 is sent periodically and its values are correct (setProperties used for report setup)
--- Other Standard Reports are also configured for sending. 
  -- Initial Conditions:
  -- 
  -- * StandardReport2Interval = 2,
  -- * AcceleratedReport2Rate = 2,
  -- * StandardReport3Interval = 2,
  -- * AcceleratedReport3Rate = 2,
  -- * StandardReport1Interval is set above zero.
  -- * AcceleratedReport1Rate is set to 1 - accelerated reports are not triggered
  --
  -- Steps:
  --
  -- 1. Properties setup is done (via setProperties) .
  -- 2. Current gps position is requested.
  -- 3. Current gps position is checked.
  -- 4. Waiting for first Standard Report is performed.
  -- 5. New gps position is prepared and set.
  -- 6. Waiting for second Standard Report is performed.
  -- 7. Difference between reports is calculated.
  -- 8. Values in report are checked.
  --
  -- Results:
  --
  -- 1. Properties are set correctly.
  -- 2. Current gps position is fetched.
  -- 3. Current gps position is correct.
  -- 4. Timer is synchronized to the first standard report
  -- 5. New gps position is correctly set.
  -- 6. Standard Report is delivered.
  -- 7. Difference between reports is correct.
  -- 8. Values in report are correct.
  -- [OK]
function test_CCStandardReportAll_WhenReportIntervalIsSetAboveZero_StandardReport1IsSentPeriodicallyWithCorrectValues()

  -- intervals and rates setup
  -- intervals in minutes
  vmsSW:setPropertiesByName({
      StandardReport2Interval = 2,
      AcceleratedReport2Rate = 2,
      StandardReport3Interval = 2,
      AcceleratedReport3Rate = 2,
  })

  framework.delay(60)

  generic_test_StandardReportContent({
    firstReportKey = "StandardReport1",
    reportKey = "StandardReport1",
    properties = {StandardReport1Interval=1, AcceleratedReport1Rate=1},
    firstReportInterval = 1,
    reportInterval = 1
  })
end

--- TC checks if StandardReport 2 is sent periodically and its values are correct (setProperties used for report setup)
--- Other Standard Reports are also configured for sending. 
  -- Initial Conditions:
  -- 
  -- * StandardReport1Interval = 2,
  -- * AcceleratedReport1Rate = 2,
  -- * StandardReport3Interval = 2,
  -- * AcceleratedReport3Rate = 2,
  -- * StandardReport2Interval is set above zero.
  -- * AcceleratedReport2Rate is set to 1 - accelerated reports are not triggered
  --
  -- Steps:
  --
  -- 1. Properties setup is done (via setProperties) .
  -- 2. Current gps position is requested.
  -- 3. Current gps position is checked.
  -- 4. Waiting for first Standard Report is performed.
  -- 5. New gps position is prepared and set.
  -- 6. Waiting for second Standard Report is performed.
  -- 7. Difference between reports is calculated.
  -- 8. Values in report are checked.
  --
  -- Results:
  --
  -- 1. Properties are set correctly.
  -- 2. Current gps position is fetched.
  -- 3. Current gps position is correct.
  -- 4. Timer is synchronized to the first standard report
  -- 5. New gps position is correctly set.
  -- 6. Standard Report is delivered.
  -- 7. Difference between reports is correct.
  -- 8. Values in report are correct.
  -- [OK]
function test_CCStandardReportAll_WhenReportIntervalIsSetAboveZero_StandardReport2IsSentPeriodicallyWithCorrectValues()

  -- intervals and rates setup
  -- intervals in minutes
  vmsSW:setPropertiesByName({
      StandardReport1Interval = 2,
      AcceleratedReport1Rate = 2,
      StandardReport3Interval = 2,
      AcceleratedReport3Rate = 2,
  })

  framework.delay(60)

  generic_test_StandardReportContent({
    firstReportKey = "StandardReport2",
    reportKey = "StandardReport2",
    properties = {StandardReport2Interval=1, AcceleratedReport2Rate=1},
    firstReportInterval = 1,
    reportInterval = 1
  })
end

--- TC checks if StandardReport 3 is sent periodically and its values are correct (setProperties used for report setup)
--- Other Standard Reports are also configured for sending. 
  -- Initial Conditions:
  -- 
  -- * StandardReport2Interval = 2,
  -- * AcceleratedReport2Rate = 2,
  -- * StandardReport1Interval = 2,
  -- * AcceleratedReport1Rate = 2,
  -- * StandardReport3Interval is set above zero.
  -- * AcceleratedReport3Rate is set to 1 - accelerated reports are not triggered
  --
  -- Steps:
  --
  -- 1. Properties setup is done (via setProperties) .
  -- 2. Current gps position is requested.
  -- 3. Current gps position is checked.
  -- 4. Waiting for first Standard Report is performed.
  -- 5. New gps position is prepared and set.
  -- 6. Waiting for second Standard Report is performed.
  -- 7. Difference between reports is calculated.
  -- 8. Values in report are checked.
  --
  -- Results:
  --
  -- 1. Properties are set correctly.
  -- 2. Current gps position is fetched.
  -- 3. Current gps position is correct.
  -- 4. Timer is synchronized to the first standard report
  -- 5. New gps position is correctly set.
  -- 6. Standard Report is delivered.
  -- 7. Difference between reports is correct.
  -- 8. Values in report are correct.
  -- [OK]
function test_CCStandardReportAll_WhenReportIntervalIsSetAboveZero_StandardReport3IsSentPeriodicallyWithCorrectValues()

  -- intervals and rates setup
  -- intervals in minutes
  vmsSW:setPropertiesByName({
      StandardReport1Interval = 2,
      AcceleratedReport1Rate = 2,
      StandardReport2Interval = 2,
      AcceleratedReport2Rate = 2,
  })

  framework.delay(60)

  generic_test_StandardReportContent({
    firstReportKey = "StandardReport3",
    reportKey = "StandardReport3",
    properties = {StandardReport3Interval=1, AcceleratedReport3Rate=1},
    firstReportInterval = 1,
    reportInterval = 1
  })
end



-----------------------------------------------------------------------------------------------
-- Test Cases for ACCELERATED REPORTS
-----------------------------------------------------------------------------------------------

--- TC checks if AcceleratedReport 1 is sent periodically and its values are correct (setProperties used for setup)
  -- Initial Conditions:
  --
  -- * StandardReport1Interval is set above zero.
  -- * AcceleratedReport1Rate is set to 2 - this will trigger accelerated report.
  --
  -- Steps:
  --
  -- 1. Properties setup is done (via setProperties).
  -- 2. Current gps position is requested.
  -- 3. Current gps position is checked.
  -- 4. Waiting for Standard Report is performed.
  -- 5. New gps position is prepared and set.
  -- 6. Waiting for AcceleratedReport is performed.
  -- 7. Difference between reports is calculated.
  -- 8. Values in report are checked.
  --
  -- Results:
  --
  -- 1. Properties are set correctly.
  -- 2. Current gps position is fetched.
  -- 3. Current gps position is correct.
  -- 4. Timer is synchronized to the first standard report.
  -- 5. New gps position is correctly set.
  -- 6. Accelerated Report is delivered.
  -- 7. Difference between reports is correct.
  -- 8. Values in report are correct.
  -- [OK]
function test_CCAcceleretedReport_WhenStandardReportIntervalAndAcceleratedReportIntervalIsSet_AcceleratedReport1IsSentWithCorrectValues()
  generic_test_StandardReportContent({
    firstReportKey = "StandardReport1",
    reportKey = "AcceleratedReport1",
    properties = {StandardReport1Interval=2, AcceleratedReport1Rate=2},
    firstReportInterval = 2,
    reportInterval = 1
  })
end

--- TC checks if AcceleratedReport 2 is sent periodically and its values are correct (setProperties used for setup)
  -- Initial Conditions:
  --
  -- * StandardReport2Interval is set above zero.
  -- * AcceleratedReport2Rate is set to 2 - this will trigger accelerated report.
  --
  -- Steps:
  --
  -- 1. Properties setup is done (via setProperties) .
  -- 2. Current gps position is requested.
  -- 3. Current gps position is checked.
  -- 4. Waiting for Standard Report is performed.
  -- 5. New gps position is prepared and set.
  -- 6. Waiting for AcceleratedReport is performed.
  -- 7. Difference between reports is calculated.
  -- 8. Values in report are checked.
  --
  -- Results:
  --
  -- 1. Properties are set correctly.
  -- 2. Current gps position is fetched.
  -- 3. Current gps position is correct.
  -- 4. Timer is synchronized to the first standard report.
  -- 5. New gps position is correctly set.
  -- 6. Accelerated Report is delivered.
  -- 7. Difference between reports is correct.
  -- 8. Values in report are correct.
  -- [OK]
function test_XCCAcceleretedReport_WhenStandardReportIntervalAndAcceleratedReportIntervalIsSet_AcceleratedReport2IsSentWithCorrectValues()
  generic_test_StandardReportContent({
    firstReportKey = "StandardReport2",
    reportKey = "AcceleratedReport2",
    properties = {StandardReport2Interval=2, AcceleratedReport2Rate=2},
    firstReportInterval = 2,
    reportInterval = 1
  })
end

--- TC checks if AcceleratedReport 3 is sent periodically and its values are correct (setProperties used for setup)
  -- Initial Conditions:
  --
  -- * StandardReport3Interval is set above zero.
  -- * AcceleratedReport3Rate is set to 2 - this will trigger accelerated report.
  --
  -- Steps:
  --
  -- 1. Properties setup is done (via setProperties) .
  -- 2. Current gps position is requested.
  -- 3. Current gps position is checked.
  -- 4. Waiting for Standard Report is performed.
  -- 5. New gps position is prepared and set.
  -- 6. Waiting for AcceleratedReport is performed.
  -- 7. Difference between reports is calculated.
  -- 8. Values in report are checked.
  --
  -- Results:
  --
  -- 1. Properties are set correctly.
  -- 2. Current gps position is fetched.
  -- 3. Current gps position is correct.
  -- 4. Timer is synchronized to the first standard report.
  -- 5. New gps position is correctly set.
  -- 6. Accelerated Report is delivered.
  -- 7. Difference between reports is correct.
  -- 8. Values in report are correct.
  -- [OK]
function test_CCAcceleretedReport_WhenStandardReportIntervalAndAcceleratedReportIntervalIsSet_AcceleratedReport3IsSentWithCorrectValues()
  generic_test_StandardReportContent({
    firstReportKey = "StandardReport3",
    reportKey = "AcceleratedReport3",
    properties = {StandardReport3Interval=2, AcceleratedReport3Rate=2},
    firstReportInterval = 2,
    reportInterval = 1
  })
end

--- TC checks if StandardReport 1 is sent and accelerated report is not sent.
  -- Initial Conditions:
  --
  -- * StandardReport1Interval is set to 1.
  -- * AcceleratedReport1Rate is set to 1 - accelerated reports are not triggered
  --
  -- Steps:
  --
  -- 1. Properties are sent.
  -- 2. Waiting for Standard Report is performed.
  -- 3. Waiting for Accelerated Report is performed.
  --
  -- Results:
  --
  -- 1. Properties are correctly set.
  -- 2. Standard Report is sent correctly.
  -- 3. Accelerated Report is not sent and that is correct.
  -- [OK]
function test_AcceleratedReportDisabledAndStandardReportEnabled_WhenStandardReport1IntervalIsSetAboveZeroAndAcceleratedReportInterval1DisablesFeature_StandardReportIsSentAndAcceleratedReportNotSent()
  generic_test_AcceleratedReportDisabledAndStandardReportEnabled(
    "StandardReport1",
    "AcceleratedReport1",
    {StandardReport1Interval=1, AcceleratedReport1Rate=1},
    80 -- waiting until report not come
  )
end

--- TC checks if StandardReport 2 is sent and accelerated report is not sent.
  -- Initial Conditions:
  --
  -- * StandardReport2Interval is set to 1.
  -- * AcceleratedReport2Rate is set to 1 - accelerated reports are not triggered
  --
  -- Steps:
  --
  -- 1. Properties are sent.
  -- 2. Waiting for Standard Report is performed.
  -- 3. Waiting for Accelerated Report is performed.
  --
  -- Results:
  --
  -- 1. Properties are correctly set.
  -- 2. Standard Report is sent correctly.
  -- 3. Accelerated Report is not sent and that is correct.
  -- [OK]
function test_AcceleratedReportDisabledAndStandardReportEnabled_WhenStandardReport2IntervalIsSetAboveZeroAndAcceleratedReportInterval2DisablesFeature_StandardReportIsSentAndAcceleratedReportNotSent()
  generic_test_AcceleratedReportDisabledAndStandardReportEnabled(
    "StandardReport2",
    "AcceleratedReport2",
    {StandardReport2Interval=1, AcceleratedReport2Rate=1},
    80 -- waiting until report not come
  )
end

--- TC checks if StandardReport 3 is sent and accelerated report is not sent.
  -- Initial Conditions:
  --
  -- * StandardRepor3Interval is set to 1.
  -- * AcceleratedReport3Rate is set to 1 - accelerated reports are not triggered
  --
  -- Steps:
  --
  -- 1. Properties are sent.
  -- 2. Waiting for Standard Report is performed.
  -- 3. Waiting for Accelerated Report is performed.
  --
  -- Results:
  --
  -- 1. Properties are correctly set.
  -- 2. Standard Report is sent correctly.
  -- 3. Accelerated Report is not sent and that is correct.
  -- [OK?]
function test_AcceleratedReportDisabledAndStandardReportEnabled_WhenStandardReport3IntervalIsSetAboveZeroAndAcceleratedReportInterval3DisablesFeature_StandardReportIsSentAndAcceleratedReportNotSent()
  generic_test_AcceleratedReportDisabledAndStandardReportEnabled(
    "StandardReport3",
    "AcceleratedReport3",
    {StandardReport3Interval=1, AcceleratedReport3Rate=1},
    80 -- waiting until report not come
  )
end

--- TC checks if AcceleratedReport 1 is sent periodically and its values are correct (setProperties used for setup)
--- 4/3 Accelerated Report Interval (80secs)
--- NOT TOTAL DIVISION of Accelerated Report Interval
  -- Initial Conditions:
  --
  -- * StandardReport1Interval is set to 4
  -- * AcceleratedReport1Rate is set to 3 - this will trigger accelerated report.
  --
  -- Steps:
  --
  -- 1. Properties setup is done (via setProperties).
  -- 2. Current gps position is requested.
  -- 3. Current gps position is checked.
  -- 4. Waiting for Standard Report is performed.
  -- 5. New gps position is prepared and set.
  -- 6. Waiting for AcceleratedReport is performed.
  -- 7. Difference between reports is calculated.
  -- 8. Values in report are checked.
  --
  -- Results:
  --
  -- 1. Properties are set correctly.
  -- 2. Current gps position is fetched.
  -- 3. Current gps position is correct.
  -- 4. Timer is synchronized to the first standard report.
  -- 5. New gps position is correctly set.
  -- 6. Accelerated Report is delivered.
  -- 7. Difference between reports is correct.
  -- 8. Values in report are correct.
  -- [OK]
function test_CCAcceleretedReportDivisionVariant43_WhenStandardReportIntervalAndAcceleratedReportIntervalIsSet_AcceleratedReport1IsSentWithCorrectValues()
  generic_test_StandardReportContent({
    firstReportKey = "StandardReport1",
    reportKey = "AcceleratedReport1",
    properties = {StandardReport1Interval=4, AcceleratedReport1Rate=3},
    firstReportInterval = 4,
    reportInterval = 4/3
  })
end

--- TC checks if AcceleratedReport 1 is sent periodically and its values are correct (setProperties used for setup)
--- 2/3 Accelerated Report Interval (40secs)
--- NOT TOTAL DIVISION of Accelerated Report Interval
  -- Initial Conditions:
  --
  -- * StandardReport1Interval is set to 2
  -- * AcceleratedReport1Rate is set to 3 - this will trigger accelerated report.
  --
  -- Steps:
  --
  -- 1. Properties setup is done (via setProperties).
  -- 2. Current gps position is requested.
  -- 3. Current gps position is checked.
  -- 4. Waiting for Standard Report is performed.
  -- 5. New gps position is prepared and set.
  -- 6. Waiting for AcceleratedReport is performed.
  -- 7. Difference between reports is calculated.
  -- 8. Values in report are checked.
  --
  -- Results:
  --
  -- 1. Properties are set correctly.
  -- 2. Current gps position is fetched.
  -- 3. Current gps position is correct.
  -- 4. Timer is synchronized to the first standard report.
  -- 5. New gps position is correctly set.
  -- 6. Accelerated Report is delivered.
  -- 7. Difference between reports is correct.
  -- 8. Values in report are correct.
  -- [FAILS, BUG?]
function test_CCAcceleretedReportDivisionVariant23_WhenStandardReportIntervalAndAcceleratedReportIntervalIsSet_AcceleratedReport1IsSentWithCorrectValues()
  generic_test_StandardReportContent({
    firstReportKey = "StandardReport1",
    reportKey = "AcceleratedReport1",
    properties = {StandardReport1Interval=2, AcceleratedReport1Rate=3},
    firstReportInterval = 2,
    reportInterval = 2/3
  })
end

-----------------------------------------------------------------------------------------------
-- Test Cases for CONFIG CHANGE REPORTS
-----------------------------------------------------------------------------------------------

--- TC checks if ConfigChangeReport 1 is sent and its values are correct (setProperties used for setup)
  -- Initial Conditions:
  --
  -- * Properties: StandardReport1Interval and AcceleratedReport1Rate are requested
  -- * Properties are received and used in TC.
  --
  -- Steps:
  --
  -- 1. Modified properties are changed and sent.
  -- 2. Waiting for message ConfigChangeReport1 is performed.
  -- 3. Report values are checked.
  --
  -- Results:
  --
  -- 1. Properties are set correctly.
  -- 2. Message ConfigChangeReport is received.
  -- 3. Report values are correct.
  -- [OK]
function test_ConfigChangeReport_WhenSetPropertiesMessageIsSentAndConfigPropertiesAreChanged_ConfigChangeReport1IsSent()
  -- get properties
  local propertiesToChange = {"StandardReport1Interval", "AcceleratedReport1Rate"}
  local propertiesBeforeChange = vmsSW:getPropertiesByName(propertiesToChange)
  D:log(framework.dump(propertiesBeforeChange))

  generic_test_ConfigChangeReportConfigChangeReportIsSent(
   "ConfigChangeReport1",
    propertiesToChange,
    propertiesBeforeChange,
    false
  )
end

--- TC checks if ConfigChangeReport 2 is sent and its values are correct (setProperties used for setup)
  -- Initial Conditions:
  --
  -- * Properties: StandardReport2Interval and AcceleratedReport2Rate are requested
  -- * Properties are received and used in TC.
  --
  -- Steps:
  --
  -- 1. Modified properties are changed and sent.
  -- 2. Waiting for message ConfigChangeReport2 is performed.
  -- 3. Report values are checked.
  --
  -- Results:
  --
  -- 1. Properties are set correctly.
  -- 2. Message ConfigChangeReport is received.
  -- 3. Report values are correct.
  -- [OK]
function test_ConfigChangeReport_WhenSetPropertiesMessageIsSentAndConfigPropertiesAreChanged_ConfigChangeReport2IsSent()

  -- get properties
  local propertiesToChange = {"StandardReport2Interval", "AcceleratedReport2Rate"}
  local propertiesBeforeChange = vmsSW:getPropertiesByName(propertiesToChange)
  D:log(framework.dump(propertiesBeforeChange))

  generic_test_ConfigChangeReportConfigChangeReportIsSent(
   "ConfigChangeReport2",
   propertiesToChange,
   propertiesBeforeChange,
   false
  )
end

--- TC checks if ConfigChangeReport 3 is sent and its values are correct (setProperties used for setup)
  -- Initial Conditions:
  --
  -- * Properties: StandardReport3Interval and AcceleratedReport3Rate are requested
  -- * Properties are received and used in TC.
  --
  -- Steps:
  --
  -- 1. Modified properties are changed and sent.
  -- 2. Waiting for message ConfigChangeReport3 is performed.
  -- 3. Report values are checked.
  --
  -- Results:
  --
  -- 1. Properties are set correctly.
  -- 2. Message ConfigChangeReport is received.
  -- 3. Report values are correct.
  -- [OK]
function test_ConfigChangeReport_WhenSetPropertiesMessageIsSentAndConfigPropertiesAreChanged_ConfigChangeReport3IsSent()

  -- get properties
  local propertiesToChange = {"StandardReport3Interval", "AcceleratedReport3Rate"}
  local propertiesBeforeChange = vmsSW:getPropertiesByName(propertiesToChange)
  D:log(framework.dump(propertiesBeforeChange))

  generic_test_ConfigChangeReportConfigChangeReportIsSent(
   "ConfigChangeReport3",
   propertiesToChange ,
   propertiesBeforeChange,
   false
  )
end

--- TC checks if ConfigChangeReport 1 is sent and its values are correct (message SetConfigReport1 used for setup)
  -- Initial Conditions:
  --
  -- * Properties: StandardReport1Interval and AcceleratedReport1Rate are requested
  -- * Properties are received and used in TC.
  --
  -- Steps:
  --
  -- 1. Properties are changed and sent.
  -- 2. Waiting for message ConfigChangeReport1 is performed.
  -- 3. Message SetConfigReport1 is sent (with changed properties)
  -- 4. Waiting for message ConfigChangeReport1 is performed.
  -- 5. Report values are checked.
  --
  -- Results:
  --
  -- 1. Properties are set correctly.
  -- 2. Message ConfigChangeReport1 is received.
  -- 3. Message SetConfigReport1 is correctly sent.
  -- 4. Message ConfigChangeReport1 is received.
  -- 5. Report values are correct.
  -- [OK]
function test_ConfigChangeReport_WhenSetConfigReport1MessageIsSentAndConfigPropertiesAreChanged_ConfigChangeReport1IsSent()

  -- get properties
  local propertiesToChange = {"StandardReport1Interval", "AcceleratedReport1Rate"}
  local propertiesBeforeChange = vmsSW:getPropertiesByName(propertiesToChange)

  generic_test_ConfigChangeReportConfigChangeReportIsSent(
   "ConfigChangeReport1",
   propertiesToChange,
   propertiesBeforeChange,
   "SetConfigReport1"
  )
end

--- TC checks if ConfigChangeReport 2 is sent and its values are correct (message SetConfigReport2 used for setup)
  -- Initial Conditions:
  --
  -- * Properties: StandardReport2Interval and AcceleratedReport2Rate are requested
  -- * Properties are received and used in TC.
  --
  -- Steps:
  --
  -- 1. Properties are changed and sent.
  -- 2. Waiting for message ConfigChangeReport2 is performed.
  -- 3. Message SetConfigReport2 is sent (with changed properties)
  -- 4. Waiting for message ConfigChangeReport2 is performed.
  -- 5. Report values are checked.
  --
  -- Results:
  --
  -- 1. Properties are set correctly.
  -- 2. Message ConfigChangeReport2 is received.
  -- 3. Message SetConfigReport2 is correctly sent.
  -- 4. Message ConfigChangeReport2 is received.
  -- 5. Report values are correct.
  -- [OK]
function test_ConfigChangeReport_WhenSetConfigReport2MessageIsSentAndConfigPropertiesAreChanged_ConfigChangeReport2IsSent()

  -- get properties
  local propertiesToChange = {"StandardReport2Interval", "AcceleratedReport2Rate"}
  local propertiesBeforeChange = vmsSW:getPropertiesByName(propertiesToChange)
  D:log(framework.dump(propertiesBeforeChange))

  generic_test_ConfigChangeReportConfigChangeReportIsSent(
   "ConfigChangeReport2",
   propertiesToChange,
   propertiesBeforeChange,
   "SetConfigReport2"
  )
end

--- TC checks if ConfigChangeReport 3 is sent and its values are correct (message SetConfigReport3 used for setup)
  -- Initial Conditions:
  --
  -- * Properties: StandardReport3Interval and AcceleratedReport3Rate are requested
  -- * Properties are received and used in TC.
  --
  -- Steps:
  --
  -- 1. Properties are changed and sent.
  -- 2. Waiting for message ConfigChangeReport3 is performed.
  -- 3. Message SetConfigReport3 is sent (with changed properties)
  -- 4. Waiting for message ConfigChangeReport3 is performed.
  -- 5. Report values are checked.
  --
  -- Results:
  --
  -- 1. Properties are set correctly.
  -- 2. Message ConfigChangeReport3 is received.
  -- 3. Message SetConfigReport3 is correctly sent.
  -- 4. Message ConfigChangeReport3 is received.
  -- 5. Report values are correct.
  -- [OK]
function test_ConfigChangeReport_WhenSetConfigReport3MessageIsSentAndConfigPropertiesAreChanged_ConfigChangeReport3IsSent()

  -- get properties
  local propertiesToChange = {"StandardReport3Interval", "AcceleratedReport3Rate"}
  local propertiesBeforeChange = vmsSW:getPropertiesByName(propertiesToChange)
  D:log(framework.dump(propertiesBeforeChange))

  generic_test_ConfigChangeReportConfigChangeReportIsSent(
   "ConfigChangeReport3",
   propertiesToChange,
   propertiesBeforeChange,
   "SetConfigReport3"
  )
end

-- [OK]
function test_PropertyChangeDebounceTime_WhenPropertiesAreChangedTwiceDuringDebounceTime_ConfigChangeReport1IsNotSent()

 generic_test_PropertyChangeDebounceTime(
   "ConfigChangeReport1",
    {StandardReport1Interval = 1, AcceleratedReport1Rate = 1},
    {StandardReport1Interval = 4, AcceleratedReport1Rate = 2}
 )

end

-- [OK]
function test_PropertyChangeDebounceTime_WhenPropertiesAreChangedTwiceDuringDebounceTime_ConfigChangeReport2IsNotSent()

 generic_test_PropertyChangeDebounceTime(
   "ConfigChangeReport2",
    {StandardReport2Interval = 1, AcceleratedReport2Rate = 1},
    {StandardReport2Interval = 4, AcceleratedReport2Rate = 2}
 )

end

-- [OK]
function test_PropertyChangeDebounceTime_WhenPropertiesAreChangedTwiceDuringDebounceTime_ConfigChangeReport3IsNotSent()

 generic_test_PropertyChangeDebounceTime(
   "ConfigChangeReport3",
    {StandardReport3Interval = 1, AcceleratedReport3Rate = 1},
    {StandardReport3Interval = 4, AcceleratedReport3Rate = 2}
 )

end

-- [OK]
function test_PropertyChangeDebounceTimeTimestampDiff_WhenConfigChangeReportsAreSentInDebouncePeriod_DifferencesBetweenTimeoutsOfConfigChangeReport1AreCorrect()
  
  generic_TimestampsInConfigChangeReports(
   "ConfigChangeReport1",
    {StandardReport1Interval = 1, AcceleratedReport1Rate = 1},
    {StandardReport1Interval = 4, AcceleratedReport1Rate = 2}
  )

end

-- [OK]
function test_PropertyChangeDebounceTimeTimestampDiff_WhenConfigChangeReportsAreSentInDebouncePeriod_DifferencesBetweenTimeoutsOfConfigChangeReport2AreCorrect()
  
  generic_TimestampsInConfigChangeReports(
   "ConfigChangeReport2",
    {StandardReport2Interval = 1, AcceleratedReport2Rate = 1},
    {StandardReport2Interval = 4, AcceleratedReport2Rate = 2}
  )

end

-- [OK]
function test_PropertyChangeDebounceTimeTimestampDiff_WhenConfigChangeReportsAreSentInDebouncePeriod_DifferencesBetweenTimeoutsOfConfigChangeReport3AreCorrect()
  
  generic_TimestampsInConfigChangeReports(
   "ConfigChangeReport3",
    {StandardReport3Interval = 1, AcceleratedReport3Rate = 1},
    {StandardReport3Interval = 4, AcceleratedReport3Rate = 2}
  )
end

-- [OK]
function test_ConfigChangeViaShell_WhenConfigChangeIsTriggeredViaShellServiceExecuteCommand_ConfigChangeReport1IsSentImmediatelyOnlyOnce()
  -- get properties
  local propertiesToChange = {"StandardReport1Interval"}
  local propertiesBeforeChange = vmsSW:getPropertiesByName(propertiesToChange)
  D:log(framework.dump(propertiesBeforeChange))

  vmsSW:setPropertiesByName({PropertyChangeDebounceTime=1})

  generic_setConfigViaShell(
   "ConfigChangeReport1",
    propertiesToChange,
    propertiesBeforeChange
  )
end

-- [OK]
function test_ConfigChangeViaShell_WhenConfigChangeIsTriggeredViaShellServiceExecuteCommand_ConfigChangeReport2IsSentImmediatelyOnlyOnce()
  -- get properties
  local propertiesToChange = {"StandardReport2Interval"}
  local propertiesBeforeChange = vmsSW:getPropertiesByName(propertiesToChange)
  D:log(framework.dump(propertiesBeforeChange))
  
  vmsSW:setPropertiesByName({PropertyChangeDebounceTime=1})

  generic_setConfigViaShell(
   "ConfigChangeReport2",
    propertiesToChange,
    propertiesBeforeChange
  )
end

-- [OK]
function test_ConfigChangeViaShell_WhenConfigChangeIsTriggeredViaShellServiceExecuteCommand_ConfigChangeReport3IsSentImmediatelyOnlyOnce()
  -- get properties
  local propertiesToChange = {"StandardReport3Interval"}
  local propertiesBeforeChange = vmsSW:getPropertiesByName(propertiesToChange)
  D:log(framework.dump(propertiesBeforeChange))

  vmsSW:setPropertiesByName({PropertyChangeDebounceTime=1})

  generic_setConfigViaShell(
   "ConfigChangeReport3",
    propertiesToChange,
    propertiesBeforeChange
  )
end

-----------------------------------------------------------------------------------------------
-- Test Cases for LOG REPORTS
-----------------------------------------------------------------------------------------------

--- TC checks if Log Report is sent periodically  and its values are correct.
  -- Initial Conditions:
  --
  -- * There should be min 2 log items configured in TC setup.
  --
  -- Steps:
  --
  -- 1. Properties are set (LogReport,StandardReport1).
  -- 2. Random gps position is requested via GpsFrontend.
  -- 3. Log filter is configured (Log agent)
  -- 4. Waiting for first standard report is performed.
  -- 5. Delay is performed for collecting logs.
  -- 6. Logs values are checked.
  -- 7. Spacer times between logs are checked.
  --
  -- Results:
  --
  -- 1. Properties are set correctly.
  -- 2. Gps position is set.
  -- 3. Log filter is set.
  -- 4. Timer is synchronized to the first standard report
  -- 5. Logs are collected.
  -- 6. Logs values are correct.
  -- 7. Spacer times between logs are correct.
  -- [OK]
function test_LogReport_WhenGpsPositionIsSetAndLogFilterEstablished_LogEntriesShouldCollectCorrectDataInCorrectInterval()

  local logReportXKey = "LogReport"

  local properties = {
    LogReportInterval = 1,
  }

  local timeForLogging = 2*60+20
  local itemsInLog = 2

  generic_test_LogReports(logReportXKey, properties, timeForLogging, itemsInLog)
end

-- [OK]
function test_LogReportNegative_WhenLogReportIsDisabledAndLogFilterEstablished_LogEntriesShouldNotCollectData()

  local logReportXKey = "LogReport"

  local properties = {
    LogReportInterval = 1,
  }

  local timeForLogging = 30

  generic_test_LogReportsNegative(logReportXKey, properties, timeForLogging)
end

-----------------------------------------------------------------------------------------------
-- DEFAULT VALUES tests
-----------------------------------------------------------------------------------------------

function test_DefaultValues_WhenPropertiesAreRequestedAfterPropertiesReset_CorrectDefaultValuesAreGiven()
  -- reset of properties
  systemSW:resetProperties({vmsSW.sin})

   -- get properties
  local propertiesToCheck = {
    "StandardReport1Interval",
    "AcceleratedReport1Rate",
    "LogReport1Rate",
    "StandardReport2Interval",
    "AcceleratedReport2Rate",
    "LogReport2Rate",
    "StandardReport3Interval",
    "AcceleratedReport3Rate",
    "LogReport3Rate",
  }

  local propertiesValues = {
    StandardReport1Interval = 60,
    AcceleratedReport1Rate = 1,
    LogReport1Rate = 1,
    StandardReport2Interval = 60,
    AcceleratedReport2Rate = 1,
    LogReport2Rate = 1,
    StandardReport3Interval = 60,
    AcceleratedReport3Rate = 1,
    LogReport3Rate = 1
  }

  local propertiesFetched = vmsSW:getPropertiesByName(propertiesToCheck)

  for key,value in pairs(propertiesValues) do
    assert_not_nil(propertiesFetched[key],"Property "..key.." not found!")
    assert_equal(value,tonumber(propertiesFetched[key]),"Property "..key.." - wrong default ")
  end
end

-----------------------------------------------------------------------------------------------
-- DRIFT OVER TIME
-- The Report Capability shall ensure that periodic reports do not drift over time.
-----------------------------------------------------------------------------------------------


function test_DriftOverTime_Standard1AndAccelerated()
  generic_test_DriftOverTime_StandardAndAccelerated(
    {StandardReport1Interval=4, AcceleratedReport1Rate=4},
    "ConfigChangeReport1",
    "StandardReport1",
    "AcceleratedReport1",
    4, --min
    1, --min
    3
  )
end

function test_DriftOverTime_Standard2AndAccelerated()
  generic_test_DriftOverTime_StandardAndAccelerated(
    {StandardReport2Interval=4, AcceleratedReport2Rate=4},
    "ConfigChangeReport2",
    "StandardReport2",
    "AcceleratedReport2",
    4, --min
    1, --min
    3
  )
end

function test_DriftOverTime_Standard3AndAccelerated()
  generic_test_DriftOverTime_StandardAndAccelerated(
    {StandardReport3Interval=4, AcceleratedReport3Rate=4},
    "ConfigChangeReport3",
    "StandardReport3",
    "AcceleratedReport3",
    4, --min
    1, --min
    3
  )
end

function generic_test_DriftOverTime_StandardAndAccelerated(properties,configChangeMsgKey,SRKey,ARKey,SRInterval,ARInterval,ARItems)

  local tolerance = 40 --secs
  local lastTimestamp = 0
  local dataToAnalysis = {}

  -- setup for : StandardReportXInterval and AcceleratedReportXRate
  vmsSW:setPropertiesByName(properties)

  vmsSW:waitForMessagesByName(
    {configChangeMsgKey},
    30
  )

  D:log("Waiting for first standard report "..SRKey)
  local message = vmsSW:waitForMessagesByName(
    {SRKey},
    SRInterval*60 + 2 * tolerance
  )
  assert_not_nil(
    message,
    "First Standard Report not received"
  )
  assert_not_nil(
    message[SRKey],
    "First Standard Report not received!"
  )
  assert_not_nil(
    message[SRKey].Timestamp,
    "Timestamp in Standard Report not received! "..SRKey
  )

  lastTimestamp = tonumber(message[SRKey].Timestamp)

  for i=1,ARItems do
    -- simulate system overload to trigger drift
    if i == 1 then
      D:log("Simulating system overload..")
      local overloadThread = coroutine.create(
        function()
          shellSW:eval("local stime = os.time();while 1 do if os.time() - stime > 90 then break end end")
        end
      )
      coroutine.resume(overloadThread)
    end
    D:log("Waiting for accelerated report "..ARKey)
    local message = vmsSW:waitForMessagesByName(
      {ARKey},
      ARInterval*60 + tolerance
    )
    assert_not_nil(
      message,
      "Accelerated Report not received! Number in sequence: "..i
    )
    assert_not_nil(
      message[ARKey],
      "Accelerated Report not received! Number in sequence: "..i
    )
    assert_not_nil(
      message[ARKey].Timestamp,
      "Timestamp in Accelerated Report not received!"
    )
    local diff = tonumber(message[ARKey].Timestamp) - lastTimestamp
    D:log(diff,"time-diff")
    lastTimestamp = tonumber(message[ARKey].Timestamp)
    table.insert(dataToAnalysis,diff)
  end

  D:log("Waiting for last standard report "..SRKey)
  local message = vmsSW:waitForMessagesByName(
    {SRKey},
    ARInterval*60 + tolerance -- last report with AR interval!
  )
  assert_not_nil(
    message,
    "Last Standard Report not received"
  )
  assert_not_nil(
    message[SRKey],
    "Lat Standard Report not received!"
  )
  assert_not_nil(
    message[SRKey].Timestamp,
    "Timestamp in Standard Report not received!"
  )
  local diff = tonumber(message[SRKey].Timestamp) - lastTimestamp

  table.insert(dataToAnalysis,diff)
  D:log(dataToAnalysis,"final-data")

  assert_true(
    driftAnalyse:perform(dataToAnalysis,60,2,-2),
    "Found inconsistency in scheduling reports! Reports: "..SRKey .. " / "..ARKey
  )

end

-----------------------------------------------------------------------------------------------
-- POLL REQUEST / RESPONSE Test cases
-----------------------------------------------------------------------------------------------

function test_PollRequest_WhenPollRequest1MessageIsSend_CorrectPollResponse1MessageIsReceived()
  generic_test_PollRequest(
    "PollRequest1", 
    "PollResponse1"
  )
end

function test_PollRequest_WhenPollRequest2MessageIsSend_CorrectPollResponse2MessageIsReceived()
  generic_test_PollRequest(
    "PollRequest2", 
    "PollResponse2"
  )
end

function test_PollRequest_WhenPollRequest3MessageIsSend_CorrectPollResponse3MessageIsReceived()
  generic_test_PollRequest(
    "PollRequest3", 
    "PollResponse3"
  )
end

function test_PollRequest_WhenPollRequest1IsRequestedDuringStandardAndAcceleratedReportsCycle_AcceleratedIntervalIsCorrect()

   generic_test_PollRequestWithOthers(
     "PollRequest1",
     "PollResponse1",
     "StandardReport1",
     "AcceleratedReport1",
     {
      StandardReport1Interval = 2,
      AcceleratedReport1Rate = 2,
     },
     2,
     1
   )

end

function test_PollRequest_WhenPollRequest2IsRequestedDuringStandardAndAcceleratedReportsCycle_AcceleratedIntervalIsCorrect()

   generic_test_PollRequestWithOthers(
     "PollRequest2",
     "PollResponse2",
     "StandardReport2",
     "AcceleratedReport2",
     {
      StandardReport2Interval = 2,
      AcceleratedReport2Rate = 2,
     },
     2,
     1
   )

end

function test_PollRequest_WhenPollRequest3IsRequestedDuringStandardAndAcceleratedReportsCycle_AcceleratedIntervalIsCorrect()

   generic_test_PollRequestWithOthers(
     "PollRequest3",
     "PollResponse3",
     "StandardReport3",
     "AcceleratedReport3",
     {
      StandardReport3Interval = 2,
      AcceleratedReport3Rate = 2,
     },
     2,
     1
   )

end

function generic_test_PollRequest(pollRequestMsgKey, pollResponseMsgKey)

  -- new position setup
  local newPosition = {
    latitude  = 1,
    longitude = 1,
    speed =  0 -- km/h
  }
  GPS:set(newPosition)

  -- sent poll message
  vmsSW:sendMessageByName(pollRequestMsgKey)

  -- wait for reponse
  local reportMessage = vmsSW:waitForMessagesByName(pollResponseMsgKey)
  assert_not_nil(reportMessage,"There is no poll response report message!")
  assert_not_nil(reportMessage[pollResponseMsgKey],"There is no poll response report message!")

  -- check values of the response
  assert_equal(
    GPS:denormalize(newPosition.latitude),
    tonumber(reportMessage[pollResponseMsgKey].Latitude),
    "Wrong latitude in " .. pollResponseMsgKey
  )
  assert_equal(
    GPS:denormalize(newPosition.longitude),
    tonumber(reportMessage[pollResponseMsgKey].Longitude),
    "Wrong longitude in " .. pollResponseMsgKey
  )
  assert_equal(
    GPS:denormalizeSpeed(newPosition.speed),
    tonumber(reportMessage[pollResponseMsgKey].Speed),
    1,
    "Wrong speed in " .. pollResponseMsgKey
  )

  D:log(reportMessage[pollResponseMsgKey].Course)
  assert_equal(
    361,
    tonumber(reportMessage[pollResponseMsgKey].Course),
    0,
    "Wrong course in report " .. pollResponseMsgKey
  )

  -- some of values are being checked just for their existance
  -- TODO_not_implemented: add checking values of following fields when test framework functions will be implemented
  assert_not_nil(
    reportMessage[pollResponseMsgKey].Timestamp,
    "No timestamp in " .. pollResponseMsgKey
  )
  assert_not_nil(
    reportMessage[pollResponseMsgKey].Hdop,
    "No Hdop in " .. pollResponseMsgKey
  )
  assert_not_nil(
    reportMessage[pollResponseMsgKey].NumSats,
    "No NumSats in " .. pollResponseMsgKey
  )
  assert_not_nil(
    reportMessage[pollResponseMsgKey].IdpCnr,
    "No IdpCnr in " .. pollResponseMsgKey
  )
  assert_not_nil(
    reportMessage[pollResponseMsgKey].StatusBitmap,
    "No StatusBitmap in " .. pollResponseMsgKey
  )


end

-----------------------------------------------------------------------------------------------
-- GENERIC LOGIC for test cases
-----------------------------------------------------------------------------------------------

function generic_test_PollRequestWithOthers(pollRequestMsgKey, pollResponseMsgKey, standardReportKey, acceleratedReportKey, properties, standardInterval, acceleratedInterval)

  -- setup standard and accelerated report intervals
  vmsSW:setPropertiesByName(properties)
  framework.delay(5)

  -- wait for first standard report
  local standardMsg = vmsSW:waitForMessagesByName(
    standardReportKey,
    standardInterval*60 + 20
  )
  D:log(standardMsg)
  assert_not_nil(standardMsg,"Standard report not received.")
  assert_not_nil(standardMsg[standardReportKey],"Standard report not received.")

  -- poll request / response in the middle of accelerated interval
  framework.delay(acceleratedInterval*60/2)
  vmsSW:sendMessageByName(pollRequestMsgKey)
  local pollMessage = vmsSW:waitForMessagesByName(pollResponseMsgKey)
  D:log(pollMessage)
  assert_not_nil(pollMessage,"There is no poll response report message!")
  assert_not_nil(pollMessage[pollResponseMsgKey],"There is no poll response report message!")

  -- wait for accelerated report
  local acceleratedMsg = vmsSW:waitForMessagesByName(
    acceleratedReportKey,
    acceleratedInterval*60 + 20
  )
  D:log(acceleratedMsg)
  assert_not_nil(acceleratedMsg,"Accelerated report not received.")
  assert_not_nil(acceleratedMsg[acceleratedReportKey],"Accelerated report not received.")

  -- check timestamp diff
  local timestampDiff = tonumber(acceleratedMsg[acceleratedReportKey].Timestamp) - tonumber(standardMsg[standardReportKey].Timestamp)
  D:log(timestampDiff)
  assert_equal(acceleratedInterval*60,timestampDiff,5,"Wrong interval of accelerated report (poll report was requested before).")

end

function generic_test_LogReportsNegative(logReportXKey, properties, timeForLogging)

  -- set properties for log interval calculation (StandardReportXInterval, LogReportXRate)
  vmsSW:setPropertiesByName(properties)

  --synchronize first log report
  vmsSW:waitForMessagesByName(logReportXKey)

  framework.delay(5)

  --set log filter
  logSW:setLogFilter(
    vmsSW.sin, {
    vmsSW:getMinFrom(logReportXKey)},
    os.time()+5,
    os.time()+timeForLogging+5,
    "True"
  )

  -- wait for log reports
  framework.delay(timeForLogging)

  -- get reports from log
  local logEntries = logSW:getLogEntries(itemsInLog)

  -- it must be loop here because operand '#' doesn't count dictionary items :(
  local counter = 0
  for key,value in pairs(logEntries) do
    counter = counter + 1 
  end

  D:log(logEntries)
  assert_equal(counter,0,0,"There should be not items in logs!")

end

-- generic logic for Log Reports TCs
function generic_test_LogReports(logReportXKey, properties, timeForLogging, itemsInLog)

  local filterTimeout = 10

  -- prerequisites
  assert_lt(3,itemsInLog,0,"There should be min 2 log items! Configure TC!")

  -- set properties for log interval calculation (LogReportXRate, StandardReportXInterval)
  vmsSW:setPropertiesByName(properties)

  -- set position for reports
  gpsPosition = GPS:setRandom()
  
  --synchronize first standard report
  vmsSW:waitForMessagesByName(logReportXKey)


  --set log filter
  logSW:setLogFilter(
    vmsSW.sin, {
    vmsSW:getMinFrom(logReportXKey)},
    os.time()+5,
    os.time()+timeForLogging+filterTimeout,
    "True"
  )

  -- wait for log reports
  framework.delay(timeForLogging+filterTimeout)

  -- get reports from log
  local logEntries = logSW:getLogEntries(itemsInLog)

  local counter = 0
  -- check if data is correct
  for i,_ in pairs(logEntries) do
    D:log(logEntries[i].log,"entry "..i)
    -- latitude
    assert_equal(
      GPS:denormalize(gpsPosition.latitude),
      tonumber(logEntries[i].log.Latitude),
      0,
      "Wrong latitude in Log Report, entry: "..i
    )
    assert_equal(
      GPS:denormalize(gpsPosition.longitude),
      tonumber(logEntries[i].log.Longitude),
      0,
      "Wrong longitude in Log Report, entry: "..i
    )
    assert_equal(
      GPS:denormalizeSpeed(gpsPosition.speed),
      tonumber(logEntries[i].log.Speed),
      1,
      "Wrong speed in Log Report, entry: "..i
    )
    -- some of values are being checked just for their existance
    assert_not_nil(
      logEntries[i].log.Timestamp,
      "No timestamp in Log Report, entry: " .. i
    )
    assert_not_nil(
      logEntries[i].log.Course,
      "No Course in Log Report, entry: " .. i
    ) 
    assert_not_nil(
      logEntries[i].log.Hdop,
      "No Hdop in Log Report, entry: " .. i
    )
    assert_not_nil(
      logEntries[i].log.NumSats,
      "No NumSats in Log Report, entry: " .. i
    )
    assert_not_nil(
      logEntries[i].log.IdpCnr,
      "No IdpCnr in Log Entry, entry: " .. i
    )
    if i>1 then
      -- check if timeout between log entries is correct
      local timeDiff = tonumber(logEntries[i-1].log.Timestamp) - tonumber(logEntries[i].log.Timestamp)
      assert_equal(
        properties.LogReportInterval*60,
        timeDiff,
        5,
        "Log Report Interval should be "..(properties.LogReportInterval*60)
      )
    end
    counter = counter + 1 
  end
  assert_equal(itemsInLog,counter,0,"Wrong number of items in log!")

end

-- This is generic function for configure and test reports (StandardReport,AcceleratedReport)
function generic_test_StandardReportContent(configuration)
  local firstReportKey = configuration.firstReportKey  -- first report name
  local reportKey = configuration.reportKey -- second report name
  local properties = configuration.properties -- StandardReportXInterval, AcceleratedReportXRate
  local firstReportInterval = configuration.firstReportInterval -- first report interval
  local reportInterval = configuration.reportInterval -- second report interval
  local setConfigMsgKey = configuration.setConfigMsgKey -- setConfig message name
  local fields = configuration.fields -- fields for setConfig message
  local configChangeMsgKey = configuration.configChangeMsgKey -- configChange message name

  -- testing via message
  if setConfigMsgKey then
    -- change config to trigger ConfigChange message (SetConfigReportX used)
    -- setting :  StandardReportXInterval, AcceleratedReportXRate
    vmsSW:sendMessageByName(
      setConfigMsgKey,
      fields
    )
    vmsSW:waitForMessagesByName(
      {configChangeMsgKey},
      30
    )
  else
    -- setting :  StandardReportXInterval, AcceleratedReportXRate
    vmsSW:setPropertiesByName(properties)
  end

  -- wait for raport to ensure that values will be fetched from current gps changes
  -- and to synchronize report sequence
  D:log("Waiting for first report "..firstReportKey)
  local preReportMessage = vmsSW:waitForMessagesByName(
    {firstReportKey},
    firstReportInterval*60*2
  )
  assert_not_nil(
    preReportMessage,
    "First Report not received"
  )
  assert_not_nil(
    preReportMessage[firstReportKey],
    "First Report not received!"
  )
  local timestampStart = preReportMessage[firstReportKey].Timestamp

  -- new position setup
  local newPosition = {
    latitude  = 1,
    longitude = 1,
    speed =  0,
    heading = 0
  }
  GPS:set(newPosition)
  framework.delay(GPS_READ_INTERVAL + GPS_PROCESS_TIME)

  -- wait for next report
  D:log("Waiting for second report "..reportKey)
  local reportMessage = vmsSW:waitForMessagesByName(
    {reportKey},
    reportInterval*60*2
  )
  assert_not_nil(
    reportMessage,
    "Second Report not received"
  )
  assert_not_nil(
    reportMessage[reportKey],
    "Second Report not received"
  )

  -- calculate time diff
  local timestampEnd = reportMessage[reportKey].Timestamp
  local timestampDiff = timestampEnd - timestampStart
  assert_equal(
    reportInterval*60,
    timestampDiff,
    5,
    "Wrong time diff between raports"
  )

  -- check values
  assert_equal(
    GPS:denormalize(newPosition.latitude),
    tonumber(reportMessage[reportKey].Latitude),
    "Wrong latitude in " .. reportKey
  )
  assert_equal(
    GPS:denormalize(newPosition.longitude),
    tonumber(reportMessage[reportKey].Longitude),
    "Wrong longitude in " .. reportKey
  )
  assert_equal(
    GPS:denormalizeSpeed(newPosition.speed),
    tonumber(reportMessage[reportKey].Speed),
    1,
    "Wrong speed in " .. reportKey
  )
  D:log(reportMessage[reportKey].Course)
  assert_equal(
    361,
    tonumber(reportMessage[reportKey].Course),
    0,
    "Wrong course in report " .. reportKey
  )

  -- some of values are being checked just for their existance
  -- TODO_not_implemented: add checking values of following fields when test framework functions will be implemented
  assert_not_nil(
    reportMessage[reportKey].Timestamp,
    "No timestamp in " .. reportKey
  )
  assert_not_nil(
    reportMessage[reportKey].Hdop,
    "No Hdop in " .. reportKey
  )
  assert_not_nil(
    reportMessage[reportKey].NumSats,
    "No NumSats in " .. reportKey
  )
  assert_not_nil(
    reportMessage[reportKey].IdpCnr,
    "No IdpCnr in " .. reportKey
  )
  assert_not_nil(
    reportMessage[reportKey].StatusBitmap,
    "No StatusBitmap in " .. reportKey
  )

end

-- this is generic function for testing Config Change Reports
function generic_test_ConfigChangeReportConfigChangeReportIsSent(messageKey,propertiesToChange,propertiesBeforeChange,setConfigMsgKey)

  propertiesToChangeValues = {}
  propertiesToChangeValues2 = {}
  propertiesToChangeValuesForMessage = {}

  for i=1, #propertiesToChange do
    propertiesToChangeValues[propertiesToChange[i]] = propertiesBeforeChange[propertiesToChange[i]] + 1
    propertiesToChangeValues2[propertiesToChange[i]] = propertiesBeforeChange[propertiesToChange[i]] + 2
    table.insert(
      propertiesToChangeValuesForMessage,
      { Name = propertiesToChange[i],  Value = (propertiesBeforeChange[propertiesToChange[i]] + 2) }
    )
  end

  -- properties must be changed anyway (the same value after and before properties reset doesn't trigger report)
  -- setting: StandardReportXInterval, AcceleratedReportXRate
  vmsSW:setPropertiesByName(propertiesToChangeValues)

  -- testing via message
  if setConfigMsgKey then
    -- raport triggered by setProperties is passed
    vmsSW:waitForMessagesByName(
      {messageKey},
      30
    )
    -- change config to trigger ConfigChange message (SetConfigReportX used)
    vmsSW:sendMessageByName(
      setConfigMsgKey,
      propertiesToChangeValuesForMessage
    )
  end

  -- wait for message
  local configChangeMessage = vmsSW:waitForMessagesByName(
    {messageKey},
    30
  )
  assert_not_nil(
    configChangeMessage,
    "No "..messageKey
  )
  assert_not_nil(
    configChangeMessage[messageKey],
    "No "..messageKey
  )

  -- one more time we fetch properties
  local propertiesCurrent = vmsSW:getPropertiesByName(propertiesToChange)
  D:log(propertiesCurrent,"PC")


  -- checking if raported values are correct
  for i=1, #propertiesToChange do
    local exp
    if setConfigMsgKey then
      exp = tonumber(propertiesToChangeValues2[propertiesToChange[i]])
    else
      exp = tonumber(propertiesToChangeValues[propertiesToChange[i]])
    end
    assert_equal(
      exp,
      tonumber(configChangeMessage[messageKey][propertiesToChange[i]]),
      0,
      "Property " .. propertiesToChange[i] .. " has not changed!"
    )
    -- check with current properties 
    assert_equal(
      propertiesCurrent[propertiesToChange[i]],
      tonumber(configChangeMessage[messageKey][propertiesToChange[i]]),
      0,
      "Property " .. propertiesToChange[i] .. " is different than property fetched from lsf!"
    )
  end

  D:log(configChangeMessage)
  if setConfigMsgKey then
    -- source OTA
    assert_equal("OTA",configChangeMessage[messageKey].ChangeSource,"Wrong source - should be OTA")
  else
    -- source console
    assert_equal("Console",configChangeMessage[messageKey].ChangeSource,"Wrong source - should be console")
  end

  -- check timestamp
  assert_not_nil(configChangeMessage[messageKey].Timestamp, "No timestamp in message.")

end

-- This is generic function for disabled standard reports test
function generic_test_StandardReportDisabled(reportKey,properties,reportInterval,acceleratedReportKey)

  -- setup
  if setConfigMsgKey then
    --setting for: StandardReportXInterval, AcceleratedReportXRate
    vmsSW:sendMessageByName(
      setConfigMsgKey,
      fields
    )
    vmsSW:waitForMessagesByName(
      {configChangeMsgKey},
      30
    )
  else
    --setting for: StandardReportXInterval, AcceleratedReportXRate
    vmsSW:setPropertiesByName(properties)
  end
  
  framework.delay(65) -- for timer from previous setup, that's hard to test

  D:log("Waiting for standard report - should not come - "..reportKey)
  local reportMessage = vmsSW:waitForMessagesByName(
    {reportKey},
    reportInterval
  )
  D:log(reportMessage,"reportMessage")
  assert_equal(0,tonumber(reportMessage.count),"Message"..reportKey.." should not come!")

  D:log("Waiting for accelerated report - should not come - "..acceleratedReportKey)
  local reportMessage = vmsSW:waitForMessagesByName(
    {acceleratedReportKey},
    reportInterval
  )
  assert_equal(0,tonumber(reportMessage.count),"Message"..reportKey.." should not come!")
end

-- This is generic function for disabled accelerated reports test (and standard reports enabled)
function generic_test_AcceleratedReportDisabledAndStandardReportEnabled(standardReportKey, reportKey,properties,reportInterval,setConfigMsgKey,configChangeMsgKey,fields)

  -- setup
  if setConfigMsgKey then
    -- change config to trigger ConfigChange message (SetConfigReportX used)
    -- Setup for: StandardReportXInterval, AcceleratedReportXRate
    vmsSW:sendMessageByName(
      setConfigMsgKey,
      fields
    )
    vmsSW:waitForMessagesByName(
      {configChangeMsgKey},
      30
    )
  else
    -- Setup for: StandardReportXInterval, AcceleratedReportXRate
    vmsSW:setPropertiesByName(properties)
  end

  local reportMessageStandard = vmsSW:waitForMessagesByName(
    {standardReportKey},
    reportInterval
  )

  assert_not_nil(
    reportMessageStandard,
    "Standard Report not received"
  )
  assert_not_nil(
    reportMessageStandard[standardReportKey],
    "Standard Report not received!"
  )

  D:log("Waiting for report - should not come - "..reportKey)
  local reportMessage = vmsSW:waitForMessagesByName(
    {reportKey},
    reportInterval
  )
  D:log(reportMessage,"reportMessage")
  assert_equal(0,tonumber(reportMessage.count),"Message"..reportKey.." should not come!")
end

-- generic method to check if property change for time below PropertyChangeDebounceTime is not 'noticed'
function generic_test_PropertyChangeDebounceTime(configChangeMsgKey,initialProperties,changedProperties)

  vmsSW:setPropertiesByName({PropertyChangeDebounceTime=1})
  framework.delay(2)

  -- initial values for : StandardReportXInterval, AcceleratedReportXRate
  vmsSW:setPropertiesByName(initialProperties)
  local reportMessage = vmsSW:waitForMessagesByName(
    {configChangeMsgKey}
  )

  vmsSW:setPropertiesByName({PropertyChangeDebounceTime=60}) 
  framework.delay(2)
  vmsSW:setHighWaterMark()

  -- changed values for : StandardReportXInterval, AcceleratedReportXRate
  vmsSW:setPropertiesByName(changedProperties)
  framework.delay(2)
  vmsSW:setPropertiesByName(initialProperties)

  local reportMessage = vmsSW:waitForMessagesByName(
    {configChangeMsgKey},
    80
  )

  -- this config change message should not be sent   
  assert_equal(0,tonumber(reportMessage.count),"Message"..configChangeMsgKey.." should not come!")

end

-- generic method to check if two ConfigChange reports have correct timestamps
function generic_TimestampsInConfigChangeReports(configChangeMsgKey,initialProperties,changedProperties)

  framework.delay(65)
  vmsSW:setHighWaterMark()

  vmsSW:setPropertiesByName({PropertyChangeDebounceTime=1})
  framework.delay(2)

  -- changed values for : StandardReportXInterval, AcceleratedReportXRate
  vmsSW:setPropertiesByName(changedProperties)

  local reportMessageZero = vmsSW:waitForMessagesByName(
    {configChangeMsgKey},
    90
  )

  vmsSW:setPropertiesByName({PropertyChangeDebounceTime=60})
  framework.delay(5)

  -- initial values for : StandardReportXInterval, AcceleratedReportXRate
  vmsSW:setPropertiesByName(initialProperties)

  local reportMessageFirst = vmsSW:waitForMessagesByName(
    {configChangeMsgKey},
    90
  )

  -- changed values for : StandardReportXInterval, AcceleratedReportXRate
  vmsSW:setPropertiesByName(changedProperties)

  local reportMessageSecond = vmsSW:waitForMessagesByName(
    {configChangeMsgKey},
    90
  )
  assert_equal(  
    60,
    tonumber(reportMessageSecond[configChangeMsgKey].Timestamp) - tonumber(reportMessageFirst[configChangeMsgKey].Timestamp),
    5,
    "Not correct difference between timestamps."
  )

end

function generic_setConfigViaShell(messageKey,propertiesToChange,propertiesBeforeChange)

  propertiesToChangeValues = {}

  for i=1, #propertiesToChange do
    propertiesToChangeValues[propertiesToChange[i]] = propertiesBeforeChange[propertiesToChange[i]] + 1
  end

  -- properties set via shell (prop set *)
  -- property StandardReportXInterval
  vmsSW:setPropertiesViaShell(shellSW,propertiesToChangeValues)

  -- wait for message
  local configChangeMessage = vmsSW:waitForMessagesByName(
    {messageKey},
    15
  )
  assert_not_nil(
    configChangeMessage,
    "No "..messageKey
  )
  assert_not_nil(
    configChangeMessage[messageKey],
    "No "..messageKey
  )

  -- no others report should come
  local configChangeMessageWait = vmsSW:waitForMessagesByName(
    {messageKey},
    120
  )
  assert_equal(0,tonumber(configChangeMessageWait.count),"Message"..messageKey.." should not come!")

  -- checking if raported values are correct
  for i=1, #propertiesToChange do
    local exp = tonumber(propertiesToChangeValues[propertiesToChange[i]])
    assert_equal(
      exp,
      tonumber(configChangeMessage[messageKey][propertiesToChange[i]]),
      0,
      "Property " .. propertiesToChange[i] .. " has not changed!"
    )
  end

  D:log(configChangeMessage)
  -- source console
  assert_equal("Console",configChangeMessage[messageKey].ChangeSource,"Wrong source - should be console")

  -- check timestamp
  assert_not_nil(configChangeMessage[messageKey].Timestamp, "No timestamp in message.")

end
