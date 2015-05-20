----------------------------------------------------------------------------------------------
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
@randIn(tcRandomizer,batch,standardReportPeriodic,1)
@method(test_StandardReport_WhenReportIntervalIsSetAboveZero_StandardReport1IsSentAccordingToSetIntervalAndContainsCorrectValues)
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
  -- 1. New gps position is prepared and set.
  -- 2. Properties setup is done (via setProperties) .
  -- 3. Waiting for first Standard Report is performed.
  -- 4. Values in report are checked.
  -- 5. New gps position is prepared and set.
  -- 6. Waiting for second Standard Report is performed.
  -- 7. Difference between reports is calculated.
  -- 8. Values in report are checked.
  --
  -- Results:
  --
  -- 1. New gps position is correctly set.
  -- 2. Properties are set correctly.
  -- 3. Timer is synchronized to the first standard report
  -- 4. Values in report are correct.
  -- 5. New gps position is correctly set.
  -- 6. Standard Report is delivered.
  -- 7. Difference between reports is correct.
  -- 8. Values in report are correct.
function test_StandardReport_WhenReportIntervalIsSetAboveZero_StandardReport1IsSentAccordingToSetIntervalAndContainsCorrectValues()
  generic_test_StandardReportContent({
    firstReportKey = "StandardReport1",
    reportKey = "StandardReport1",
    properties = {StandardReport1Interval=1, AcceleratedReport1Rate=1}, -- minute , divide
    firstReportInterval = 1, -- minute
    reportInterval = 1 -- minute
  })
end

Annotations:register([[
@randIn(tcRandomizer,batch,standardReportPeriodic,2)
@method(test_StandardReport_WhenReportIntervalIsSetAboveZero_StandardReport2IsSentAccordingToSetIntervalAndContainsCorrectValues)
@module(TestNormalReportsModule)
]])

--- TC checks if StandardReport 2 is sent periodically and its values are correct (setProperties used for report setup)
  -- Initial Conditions:
  --
  -- * StandardReport2Interval is set above zero.
  -- * AcceleratedReport1Rate is set to 2 - accelerated reports are not triggered
  --
  -- Steps:
  --
  -- 1. New gps position is prepared and set.
  -- 2. Properties setup is done (via setProperties) .
  -- 3. Waiting for first Standard Report is performed.
  -- 4. Values in report are checked.
  -- 5. New gps position is prepared and set.
  -- 6. Waiting for second Standard Report is performed.
  -- 7. Difference between reports is calculated.
  -- 8. Values in report are checked.
  --
  -- Results:
  --
  -- 1. New gps position is correctly set.
  -- 2. Properties are set correctly.
  -- 3. Timer is synchronized to the first standard report
  -- 4. Values in report are correct.
  -- 5. New gps position is correctly set.
  -- 6. Standard Report is delivered.
  -- 7. Difference between reports is correct.
  -- 8. Values in report are correct.
function test_StandardReport_WhenReportIntervalIsSetAboveZero_StandardReport2IsSentAccordingToSetIntervalAndContainsCorrectValues()
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
@method(test_StandardReport_WhenReportIntervalIsSetAboveZero_StandardReport3IsSentAccordingToSetIntervalAndContainsCorrectValues)
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
  -- 1. New gps position is prepared and set.
  -- 2. Properties setup is done (via setProperties) .
  -- 3. Waiting for first Standard Report is performed.
  -- 4. Values in report are checked.
  -- 5. New gps position is prepared and set.
  -- 6. Waiting for second Standard Report is performed.
  -- 7. Difference between reports is calculated.
  -- 8. Values in report are checked.
  --
  -- Results:
  --
  -- 1. New gps position is correctly set.
  -- 2. Properties are set correctly.
  -- 3. Timer is synchronized to the first standard report
  -- 4. Values in report are correct.
  -- 5. New gps position is correctly set.
  -- 6. Standard Report is delivered.
  -- 7. Difference between reports is correct.
  -- 8. Values in report are correct.
function test_StandardReport_WhenReportIntervalIsSetAboveZero_StandardReport3IsSentAccordingToSetIntervalAndContainsCorrectValues()
  generic_test_StandardReportContent({
    firstReportKey = "StandardReport3",
    reportKey = "StandardReport3",
    properties = {StandardReport3Interval=1, AcceleratedReport3Rate=1}, -- minute , divide
    firstReportInterval = 1, -- minute
    reportInterval = 1 -- minute
  })
end

Annotations:register([[
@randIn(tcRandomizer,batch,standardReportPeriodic2,1)
@method(test_StandardReport_WhenReportIntervalIsSetAboveZeroAndSetConfigReport1MessageIsSent_StandardReport1IsSentPeriodicallyWithCorrectValues)
@module(TestNormalReportsModule)
]])
--- TC checks if StandardReport 1 is sent periodically and its values are correct (SetConfigReport1 used for report setup)
  -- Initial Conditions:
  --
  -- * StandardReport1Interval is set above zero.
  -- * AcceleratedReport1Rate is set to 1 - accelerated reports are not triggered
  --
  -- Steps:
  --
  -- 1. New gps position is prepared and set.
  -- 2. SetConfigReport1 message is sent .
  -- 3. Waiting for first Standard Report is performed.
  -- 4. Values in report are checked.
  -- 5. New gps position is prepared and set.
  -- 6. Waiting for second Standard Report is performed.
  -- 7. Difference between reports is calculated.
  -- 8. Values in report are checked.
  --
  -- Results:
  --
  -- 1. New gps position is correctly set.
  -- 2. ConfigChangeReport1 is received.
  -- 3. Timer is synchronized to the first standard report
  -- 4. Values in report are correct.
  -- 5. New gps position is correctly set.
  -- 6. Standard Report is delivered.
  -- 7. Difference between reports is correct.
  -- 8. Values in report are correct.
function test_StandardReport_WhenReportIntervalIsSetAboveZeroAndSetConfigReport1MessageIsSent_StandardReport1IsSentPeriodicallyWithCorrectValues()
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

Annotations:register([[
@randIn(tcRandomizer,batch,standardReportPeriodic2,2)
@method(test_StandardReport_WhenReportIntervalIsSetAboveZeroAndSetConfigReport2MessageIsSent_StandardReport2IsSentPeriodicallyWithCorrectValues)
@module(TestNormalReportsModule)
]])
--- TC checks if StandardReport 2 is sent periodically and its values are correct (SetConfigReport1 used for report setup)
  -- Initial Conditions:
  --
  -- * StandardReport2Interval is set above zero.
  -- * AcceleratedReport2Rate is set to 1 - accelerated reports are not triggered
  --
  -- Steps:
  --
  -- 1. New gps position is prepared and set.
  -- 2. SetConfigReport2 message is sent .
  -- 3. Waiting for first Standard Report is performed.
  -- 4. Values in report are checked.
  -- 5. New gps position is prepared and set.
  -- 6. Waiting for second Standard Report is performed.
  -- 7. Difference between reports is calculated.
  -- 8. Values in report are checked.
  --
  -- Results:
  --
  -- 1. New gps position is correctly set.
  -- 2. ConfigChangeReport2 is received.
  -- 3. Timer is synchronized to the first standard report
  -- 4. Values in report are correct.
  -- 5. New gps position is correctly set.
  -- 6. Standard Report is delivered.
  -- 7. Difference between reports is correct.
  -- 8. Values in report are correct.
function test_StandardReport_WhenReportIntervalIsSetAboveZeroAndSetConfigReport2MessageIsSent_StandardReport2IsSentPeriodicallyWithCorrectValues()
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

Annotations:register([[
@randIn(tcRandomizer,batch,standardReportPeriodic2,3)
@method(test_StandardReport_WhenReportIntervalIsSetAboveZeroAndSetConfigReport3MessageIsSent_StandardReport3IsSentPeriodicallyWithCorrectValues)
@module(TestNormalReportsModule)
]])
--- TC checks if StandardReport 3 is sent periodically and its values are correct (SetConfigReport1 used for report setup)
  -- Initial Conditions:
  --
  -- * StandardReport3Interval is set above zero.
  -- * AcceleratedReport3Rate is set to 1 - accelerated reports are not triggered
  --
  -- Steps:
  --
  -- 1. New gps position is prepared and set.
  -- 2. SetConfigReport3 message is sent .
  -- 3. Waiting for first Standard Report is performed.
  -- 4. Values in report are checked.
  -- 5. New gps position is prepared and set.
  -- 6. Waiting for second Standard Report is performed.
  -- 7. Difference between reports is calculated.
  -- 8. Values in report are checked.
  --
  -- Results:
  --
  -- 1. New gps position is correctly set.
  -- 2. ConfigChangeReport3 is received.
  -- 3. Timer is synchronized to the first standard report
  -- 4. Values in report are correct.
  -- 5. New gps position is correctly set.
  -- 6. Standard Report is delivered.
  -- 7. Difference between reports is correct.
  -- 8. Values in report are correct.

function test_StandardReport_WhenReportIntervalIsSetAboveZeroAndSetConfigReport3MessageIsSent_StandardReport3IsSentPeriodicallyWithCorrectValues()

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

Annotations:register([[
@randIn(tcRandomizer,batch,standardReportDisabled,1)
@method(test_StandardReportDisabled_WhenStandardReport1IntervalIsSetToZero_StandardReport1IsNotSent)
@module(TestNormalReportsModule)
]])
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
function test_StandardReportDisabled_WhenStandardReport1IntervalIsSetToZero_StandardReport1IsNotSent()
  vmsSW:setPropertiesByName({PropertyChangeDebounceTime=1})
  generic_test_StandardReportDisabled(
    "StandardReport1",
    {StandardReport1Interval=0, AcceleratedReport1Rate=1},
    120, -- waiting until report not come,
    "AcceleratedReport1"
  )
end

Annotations:register([[
@randIn(tcRandomizer,batch,standardReportDisabled,2)
@method(test_StandardReportDisabled_WhenStandardReport2IntervalIsSetToZero_StandardReport2IsNotSent)
@module(TestNormalReportsModule)
]])
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

Annotations:register([[
@randIn(tcRandomizer,batch,standardReportDisabled,3)
@method(test_StandardReportDisabled_WhenStandardReport3IntervalIsSetToZero_StandardReport3IsNotSent)
@module(TestNormalReportsModule)
]])
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

Annotations:register([[
@randIn(tcRandomizer,batch,standardReportPeriodic3,1)
@method(test_StandardReport_WhenAllStandardReportsAreEnabledAndSendWithPeriodOfOneMinute_ReportsDoesNotInterfereWithEachOtherAndStandardReport1IsSendWithSetInterval)
@module(TestNormalReportsModule)
]])
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
  -- TODO: docs!
  -- [OK]
function test_StandardReport_WhenAllStandardReportsAreEnabledAndSendWithPeriodOfOneMinute_ReportsDoesNotInterfereWithEachOtherAndStandardReport1IsSendWithSetInterval()

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

Annotations:register([[
@randIn(tcRandomizer,batch,standardReportPeriodic3,2)
@method(test_StandardReport_WhenAllStandardReportsAreEnabledAndSendWithPeriodOfOneMinute_ReportsDoesNotInterfereWithEachOtherAndStandardReport2IsSendWithSetInterval)
@module(TestNormalReportsModule)
]])
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
  -- TODO: docs
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
function test_StandardReport_WhenAllStandardReportsAreEnabledAndSendWithPeriodOfOneMinute_ReportsDoesNotInterfereWithEachOtherAndStandardReport2IsSendWithSetInterval()

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

Annotations:register([[
@randIn(tcRandomizer,batch,standardReportPeriodic3,3)
@method(test_StandardReport_WhenAllStandardReportsAreEnabledAndSendWithPeriodOfOneMinute_ReportsDoesNotInterfereWithEachOtherAndStandardReport3IsSendWithSetInterval)
@module(TestNormalReportsModule)
]])
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
  -- TODO: docs
function test_StandardReport_WhenAllStandardReportsAreEnabledAndSendWithPeriodOfOneMinute_ReportsDoesNotInterfereWithEachOtherAndStandardReport3IsSendWithSetInterval()

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

Annotations:register([[
@randIn(tcRandomizer,batch,acceleratedReportPeriodic,1)
@method(test_AcceleretedReport_WhenStandardReportIntervalAndAcceleratedReportIntervalIsSet_AcceleratedReport1IsSentAccordingToSetIntervalWithCorrectValues)
@module(TestNormalReportsModule)
]])
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
  -- TODO: docs
  -- [OK]
function test_AcceleretedReport_WhenStandardReportIntervalAndAcceleratedReportIntervalIsSet_AcceleratedReport1IsSentAccordingToSetIntervalWithCorrectValues()
  generic_test_StandardReportContent({
    firstReportKey = "StandardReport1",
    reportKey = "AcceleratedReport1",
    properties = {StandardReport1Interval=2, AcceleratedReport1Rate=2},
    firstReportInterval = 2,
    reportInterval = 1
  })
end

Annotations:register([[
@randIn(tcRandomizer,batch,acceleratedReportPeriodic,2)
@method(test_AcceleretedReport_WhenStandardReportIntervalAndAcceleratedReportIntervalIsSet_AcceleratedReport2IsSentAccordingToSetIntervalWithCorrectValues)
@module(TestNormalReportsModule)
]])
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
  -- TODO: docs
  -- [OK]
function test_AcceleretedReport_WhenStandardReportIntervalAndAcceleratedReportIntervalIsSet_AcceleratedReport2IsSentAccordingToSetIntervalWithCorrectValues()
  generic_test_StandardReportContent({
    firstReportKey = "StandardReport2",
    reportKey = "AcceleratedReport2",
    properties = {StandardReport2Interval=2, AcceleratedReport2Rate=2},
    firstReportInterval = 2,
    reportInterval = 1
  })
end

Annotations:register([[
@randIn(tcRandomizer,batch,acceleratedReportPeriodic,3)
@method(test_AcceleretedReport_WhenStandardReportIntervalAndAcceleratedReportIntervalIsSet_AcceleratedReport3IsSentAccordingToSetIntervalWithCorrectValues)
@module(TestNormalReportsModule)
]])
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
  -- TODO: docs
  -- [OK]
function test_AcceleretedReport_WhenStandardReportIntervalAndAcceleratedReportIntervalIsSet_AcceleratedReport3IsSentAccordingToSetIntervalWithCorrectValues()
  generic_test_StandardReportContent({
    firstReportKey = "StandardReport3",
    reportKey = "AcceleratedReport3",
    properties = {StandardReport3Interval=2, AcceleratedReport3Rate=2},
    firstReportInterval = 2,
    reportInterval = 1
  })
end


Annotations:register([[
@randIn(tcRandomizer,batch,acceleratedReportDisabled,1)
@method(test_AcceleratedReport_WhenStandardReport1IntervalIsSetAboveZeroAndAcceleratedReportInterval1DisablesFeature_StandardReportIsSentAndAcceleratedReportNotSent)
@module(TestNormalReportsModule)
]])
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
function test_AcceleratedReport_WhenStandardReport1IntervalIsSetAboveZeroAndAcceleratedReportInterval1DisablesFeature_StandardReportIsSentAndAcceleratedReportNotSent()
  generic_test_AcceleratedReportDisabledAndStandardReportEnabled(
    "StandardReport1",
    "AcceleratedReport1",
    {StandardReport1Interval=1, AcceleratedReport1Rate=1},
    80 -- waiting until report not come
  )
end

Annotations:register([[
@randIn(tcRandomizer,batch,acceleratedReportDisabled,2)
@method(test_AcceleratedReport_WhenStandardReport2IntervalIsSetAboveZeroAndAcceleratedReportInterval2DisablesFeature_StandardReportIsSentAndAcceleratedReportNotSent)
@module(TestNormalReportsModule)
]])
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
function test_AcceleratedReport_WhenStandardReport2IntervalIsSetAboveZeroAndAcceleratedReportInterval2DisablesFeature_StandardReportIsSentAndAcceleratedReportNotSent()
  generic_test_AcceleratedReportDisabledAndStandardReportEnabled(
    "StandardReport2",
    "AcceleratedReport2",
    {StandardReport2Interval=1, AcceleratedReport2Rate=1},
    80 -- waiting until report not come
  )
end

Annotations:register([[
@randIn(tcRandomizer,batch,acceleratedReportDisabled,3)
@method(test_AcceleratedReport_WhenStandardReport3IntervalIsSetAboveZeroAndAcceleratedReportInterval3DisablesFeature_StandardReportIsSentAndAcceleratedReportNotSent)
@module(TestNormalReportsModule)
]])
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
function test_AcceleratedReport_WhenStandardReport3IntervalIsSetAboveZeroAndAcceleratedReportInterval3DisablesFeature_StandardReportIsSentAndAcceleratedReportNotSent()
  generic_test_AcceleratedReportDisabledAndStandardReportEnabled(
    "StandardReport3",
    "AcceleratedReport3",
    {StandardReport3Interval=1, AcceleratedReport3Rate=1},
    80 -- waiting until report not come
  )
end

--TODO: TC for interfering with abnormal reports

-----------------------------------------------------------------------------------------------
-- Test Cases for CONFIG CHANGE REPORTS
-----------------------------------------------------------------------------------------------

Annotations:register([[
@randIn(tcRandomizer,batch,configChangeSent,1)
@method(test_ConfigChangeReport_WhenSetPropertiesMessageIsSentAndConfigPropertiesAreChanged_ConfigChangeReport1IsSent)
@module(TestNormalReportsModule)
]])
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

Annotations:register([[
@randIn(tcRandomizer,batch,configChangeSent,2)
@method(test_ConfigChangeReport_WhenSetPropertiesMessageIsSentAndConfigPropertiesAreChanged_ConfigChangeReport2IsSent)
@module(TestNormalReportsModule)
]])
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

Annotations:register([[
@randIn(tcRandomizer,batch,configChangeSent,3)
@method(test_ConfigChangeReport_WhenSetPropertiesMessageIsSentAndConfigPropertiesAreChanged_ConfigChangeReport3IsSent)
@module(TestNormalReportsModule)
]])
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

Annotations:register([[
@randIn(tcRandomizer,batch,configChangeSent2,1)
@method(test_ConfigChangeReport_WhenSetConfigReport1MessageIsSentAndConfigPropertiesAreChanged_ConfigChangeReport1IsSent)
@module(TestNormalReportsModule)
]])
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

Annotations:register([[
@randIn(tcRandomizer,batch,configChangeSent2,2)
@method(test_ConfigChangeReport_WhenSetConfigReport2MessageIsSentAndConfigPropertiesAreChanged_ConfigChangeReport2IsSent)
@module(TestNormalReportsModule)
]])
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

Annotations:register([[
@randIn(tcRandomizer,batch,configChangeSent2,3)
@method(test_ConfigChangeReport_WhenSetConfigReport3MessageIsSentAndConfigPropertiesAreChanged_ConfigChangeReport3IsSent)
@module(TestNormalReportsModule)
]])
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

Annotations:register([[
@randIn(tcRandomizer,batch,propertyDebounce,1)
@method(test_ConfigChangeReport_WhenPropertiesAreChangedTwiceDuringPropertyChangeDebounceTime_ConfigChangeReport1IsNotSent)
@module(TestNormalReportsModule)
]])
--- TC checks if property debounce time works properly.
  -- Initial Conditions:
  --
  -- * There should be PropertyChangeDebounceTime set to 1 minute.
  --
  -- Steps:
  --
  -- 1. SetProperties message is sent with changed properties values (StandardReport1Interval and AcceleratedReport1Rate).
  -- 2. SetProperties messsage is sent with initial properties values.
  --
  -- Results:
  --
  -- 1. No ConfigChangeReport1 message is sent.
  -- 2. No ConfigChangeReport1 message is sent.
function test_ConfigChangeReport_WhenPropertiesAreChangedTwiceDuringPropertyChangeDebounceTime_ConfigChangeReport1IsNotSent()

 generic_test_PropertyChangeDebounceTime(
   "ConfigChangeReport1",
    {StandardReport1Interval = 1, AcceleratedReport1Rate = 1},
    {StandardReport1Interval = 4, AcceleratedReport1Rate = 2}
 )

end

Annotations:register([[
@randIn(tcRandomizer,batch,propertyDebounce,2)
@method(test_ConfigChangeReport_WhenPropertiesAreChangedTwiceDuringPropertyChangeDebounceTime_ConfigChangeReport2IsNotSent)
@module(TestNormalReportsModule)
]])
--- TC checks if property debounce time works properly.
  -- Initial Conditions:
  --
  -- * There should be PropertyChangeDebounceTime set to 1 minute.
  --
  -- Steps:
  --
  -- 1. SetProperties message is sent with changed properties values (StandardReport2Interval and AcceleratedReport2Rate).
  -- 2. SetProperties messsage is sent with initial properties values.
  --
  -- Results:
  --
  -- 1. No ConfigChangeReport2 message is sent.
  -- 2. No ConfigChangeReport2 message is sent.
function  test_ConfigChangeReport_WhenPropertiesAreChangedTwiceDuringPropertyChangeDebounceTime_ConfigChangeReport2IsNotSent()

 generic_test_PropertyChangeDebounceTime(
   "ConfigChangeReport2",
    {StandardReport2Interval = 1, AcceleratedReport2Rate = 1},
    {StandardReport2Interval = 4, AcceleratedReport2Rate = 2}
 )

end

Annotations:register([[
@randIn(tcRandomizer,batch,propertyDebounce,3)
@method(test_ConfigChangeReport_WhenPropertiesAreChangedTwiceDuringPropertyChangeDebounceTime_ConfigChangeReport3IsNotSent)
@module(TestNormalReportsModule)
]])
--- TC checks if property debounce time works properly.
  -- Initial Conditions:
  --
  -- * There should be PropertyChangeDebounceTime set to 1 minute.
  --
  -- Steps:
  --
  -- 1. SetProperties message is sent with changed properties values (StandardReport3Interval and AcceleratedReport3Rate).
  -- 2. SetProperties messsage is sent with initial properties values.
  --
  -- Results:
  --
  -- 1. No ConfigChangeReport3 message is sent.
  -- 2. No ConfigChangeReport3 message is sent.
function  test_ConfigChangeReport_WhenPropertiesAreChangedTwiceDuringPropertyChangeDebounceTime_ConfigChangeReport3IsNotSent()

 generic_test_PropertyChangeDebounceTime(
   "ConfigChangeReport3",
    {StandardReport3Interval = 1, AcceleratedReport3Rate = 1},
    {StandardReport3Interval = 4, AcceleratedReport3Rate = 2}
 )

end

Annotations:register([[
@randIn(tcRandomizer,batch,propertyDebounce2,1)
@method(test_ConfigChangeReport_WhenTwoConfigChangeReportsAreSentInDebouncePeriod_DifferencesBetweenTimestampsOfConfigChangeReport1AreCorrect)
@module(TestNormalReportsModule)
]])
--- TC checks if two ConfigChange reports have correct timestamps.
  -- Initial Conditions:
  --
  -- * Actions are performed after first/zero ConfigChangeReport1 report is received.
  --
  -- Steps:
  --
  -- 1. PropertyChangeDebounceTime is set to 60 seconds.
  -- 2. Properties are changed (StandardReport1Interval, AcceleratedReport1Rate)
  -- 3. Properties are changed again.
  -- 4. Difference between timestamps in ConfigChangeReport1 reports is calculated.
  --
  -- Results:
  --
  -- 1. PropertyChangeDebounceTime is correctly set.
  -- 2. First ConfigChangeReport1 message is sent.
  -- 3. Second ConfigChangeReport1 message is sent.
  -- 4. Difference between timestamps is correct.
function test_ConfigChangeReport_WhenTwoConfigChangeReportsAreSentInDebouncePeriod_DifferencesBetweenTimestampsOfConfigChangeReport1AreCorrect()
  
  generic_TimestampsInConfigChangeReports(
   "ConfigChangeReport1",
    {StandardReport1Interval = 1, AcceleratedReport1Rate = 1},
    {StandardReport1Interval = 4, AcceleratedReport1Rate = 2}
  )

end

Annotations:register([[
@randIn(tcRandomizer,batch,propertyDebounce2,2)
@method(test_ConfigChangeReport_WhenTwoConfigChangeReportsAreSentInDebouncePeriod_DifferencesBetweenTimestampsOfConfigChangeReport2AreCorrect)
@module(TestNormalReportsModule)
]])
--- TC checks if two ConfigChange reports have correct timestamps.
  -- Initial Conditions:
  --
  -- * Actions are performed after first/zero ConfigChangeReport2 report is received.
  --
  -- Steps:
  --
  -- 1. PropertyChangeDebounceTime is set to 60 seconds.
  -- 2. Properties are changed (StandardReport2Interval, AcceleratedReport2Rate)
  -- 3. Properties are changed again.
  -- 4. Difference between timestamps in ConfigChangeReport2 reports is calculated.
  --
  -- Results:
  --
  -- 1. PropertyChangeDebounceTime is correctly set.
  -- 2. First ConfigChangeReport2 message is sent.
  -- 3. Second ConfigChangeReport2 message is sent.
  -- 4. Difference between timestamps is correct.
function test_ConfigChangeReport_WhenTwoConfigChangeReportsAreSentInDebouncePeriod_DifferencesBetweenTimestampsOfConfigChangeReport2AreCorrect()
  
  generic_TimestampsInConfigChangeReports(
   "ConfigChangeReport2",
    {StandardReport2Interval = 1, AcceleratedReport2Rate = 1},
    {StandardReport2Interval = 4, AcceleratedReport2Rate = 2}
  )

end

Annotations:register([[
@randIn(tcRandomizer,batch,propertyDebounce2,3)
@method(test_ConfigChangeReport_WhenTwoConfigChangeReportsAreSentInDebouncePeriod_DifferencesBetweenTimestampsOfConfigChangeReport3AreCorrect)
@module(TestNormalReportsModule)
]])
--- TC checks if two ConfigChange reports have correct timestamps.
  -- Initial Conditions:
  --
  -- * Actions are performed after first/zero ConfigChangeReport3 report is received.
  --
  -- Steps:
  --
  -- 1. PropertyChangeDebounceTime is set to 60 seconds.
  -- 2. Properties are changed (StandardReport3Interval, AcceleratedReport3Rate)
  -- 3. Properties are changed again.
  -- 4. Difference between timestamps in ConfigChangeReport3 reports is calculated.
  --
  -- Results:
  --
  -- 1. PropertyChangeDebounceTime is correctly set.
  -- 2. First ConfigChangeReport3 message is sent.
  -- 3. Second ConfigChangeReport3 message is sent.
  -- 4. Difference between timestamps is correct.
function test_ConfigChangeReport_WhenTwoConfigChangeReportsAreSentInDebouncePeriod_DifferencesBetweenTimestampsOfConfigChangeReport3AreCorrect()
  
  generic_TimestampsInConfigChangeReports(
   "ConfigChangeReport3",
    {StandardReport3Interval = 1, AcceleratedReport3Rate = 1},
    {StandardReport3Interval = 4, AcceleratedReport3Rate = 2}
  )
end

Annotations:register([[
@randIn(tcRandomizer,batch,configChangeViaShell,1)
@method(test_ConfigChangeViaShell_WhenConfigChangeIsTriggeredViaShellServiceExecuteCommand_ConfigChangeReport1IsSentImmediatelyOnlyOnce)
@module(TestNormalReportsModule)
]])
--- TC checks if ConfigChangeReport1 is sent after changes made via console.
  --
  -- Steps:
  --
  -- 1. Changed properties are set via shell.
  -- 2. Waiting for other reports is performed.
  -- 3. Values in ConfigChangeReport1 are checked.
  -- 4. Change source string is checked.
  -- 5. Timestamp of the report is checked.
  --
  -- Results:
  --
  -- 1. ConfigChangeReport1 message is performed.
  -- 2. No other reports are sent. 
  -- 3. Values in ConfigChangeReport1 are correct.
  -- 4. Change source string is correct.
  -- 5. Timestamp of the report is correct.
  -- REVIEW:endshere
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

Annotations:register([[
@randIn(tcRandomizer,batch,configChangeViaShell,2)
@method(test_ConfigChangeViaShell_WhenConfigChangeIsTriggeredViaShellServiceExecuteCommand_ConfigChangeReport2IsSentImmediatelyOnlyOnce)
@module(TestNormalReportsModule)
]])
--- TC checks if ConfigChangeReport2 is sent after changes made via console.
  --
  -- Steps:
  --
  -- 1. Changed properties are set via shell.
  -- 2. Waiting for other reports is performed.
  -- 3. Values in ConfigChangeReport2 are checked.
  -- 4. Change source string is checked.
  -- 5. Timestamp of the report is checked.
  --
  -- Results:
  --
  -- 1. ConfigChangeReport2 message is performed.
  -- 2. No other reports are sent. 
  -- 3. Values in ConfigChangeReport2 are correct.
  -- 4. Change source string is correct.
  -- 5. Timestamp of the report is correct.
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

Annotations:register([[
@randIn(tcRandomizer,batch,configChangeViaShell,3)
@method(test_ConfigChangeViaShell_WhenConfigChangeIsTriggeredViaShellServiceExecuteCommand_ConfigChangeReport3IsSentImmediatelyOnlyOnce3)
@module(TestNormalReportsModule)
]])
--- TC checks if ConfigChangeReport3 is sent after changes made via console.
  --
  -- Steps:
  --
  -- 1. Changed properties are set via shell.
  -- 2. Waiting for other reports is performed.
  -- 3. Values in ConfigChangeReport3 are checked.
  -- 4. Change source string is checked.
  -- 5. Timestamp of the report is checked.
  --
  -- Results:
  --
  -- 1. ConfigChangeReport3 message is performed.
  -- 2. No other reports are sent. 
  -- 3. Values in ConfigChangeReport3 are correct.
  -- 4. Change source string is correct.
  -- 5. Timestamp of the report is correct.
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
function test_LogReport_WhenGpsPositionIsSetAndLogFilterEstablished_LogEntriesShouldCollectCorrectDataInCorrectInterval()

  local logReportXKey = "LogReport"

  local properties = {
    LogReportInterval = 1,
  }

  local timeForLogging = 2*60+20
  local itemsInLog = 2

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

--- TC checks if Log Reports are properly disabled.
  -- Initial Conditions:
  --
  -- * There should be firts log report received with known interval
  -- * There should be configuration prepared in a way that disables Log Reports.
  --
  -- Steps:
  --
  -- 1. Waiting for initial log report is performed.
  -- 2. Log interval is set to zero.
  -- 3. Log filter is set for 2 minutes.
  -- 4. Waiting for log items is performed.
  --
  -- Results:
  --
  -- 1. Initial log report is received.
  -- 2. Property with log interval is correctly set.
  -- 3. Log filter is correctly set.
  -- 4. There is no log items.
function test_LogReportNegative_WhenLogReportIsDisabledAndLogFilterEstablished_LogEntriesShouldNotCollectData()

  local logReportXKey = "LogReport"

  -- set log interval to 1
  local properties = {
    LogReportInterval = 1,
  }

  -- set properties for log interval calculation (LogReportInterval)
  vmsSW:setPropertiesByName(properties)

  -- wait for initial log report
  vmsSW:waitForMessagesByName(logReportXKey)

  -- set log interval to 0
  properties = {
    LogReportInterval = 0,
  }
  
  -- set properties for log interval calculation (LogReportInterval)
  vmsSW:setPropertiesByName(properties)

  -- time for logging
  local timeForLogging = 2 * 60 -- 2 minutes

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

  -- there should be no log items
  assert_equal(counter,0,0,"There should be not items in logs!")

end

-----------------------------------------------------------------------------------------------
-- DEFAULT VALUES tests
-----------------------------------------------------------------------------------------------

--- TC checks if reset of properties restores proper default values.
  --
  -- Steps:
  --
  -- 1.Reset of properties is requested via system service.
  -- 2.Properties are fetched via OTA message.
  -- 3.Each property value is compared with default value.
  --
  -- Results:
  --
  -- 1.Reset of properties is properly performed.
  -- 2.Properties are correctly fetched.
  -- 3.Each property has correct default value.
function test_DefaultValues_WhenPropertiesAreRequestedAfterPropertiesReset_CorrectDefaultValuesAreGiven()
  -- reset of properties
  systemSW:resetProperties({vmsSW.sin})

   -- get properties
  local propertiesToCheck = {
    "StandardReport1Interval",
    "AcceleratedReport1Rate",
    "LogReportInterval",
    "StandardReport2Interval",
    "AcceleratedReport2Rate",
    "StandardReport3Interval",
    "AcceleratedReport3Rate",
  }

  local propertiesValues = {
    StandardReport1Interval = 60,
    AcceleratedReport1Rate = 1,
    LogReportInterval = 15,
    StandardReport2Interval = 0,
    AcceleratedReport2Rate = 1,
    StandardReport3Interval = 0,
    AcceleratedReport3Rate = 1,
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

Annotations:register([[
@randIn(tcRandomizer,batch,driftOverTime,1)
@method(test_DriftOverTime_Standard1AndAccelerated)
@module(TestNormalReportsModule)
]])
--- TC checks if standard and accelerated reports timing do not drift over time.
  --
  -- Steps:
  --
  -- 1. Configuration is prepared (StandardReport1Interval=4, AcceleratedReport1Rate=4)
  -- 2. Waiting for first StandardReport1 is performed.
  -- 3. System overload is simulated.
  -- 4. Timeouts of standard/accelerated are being saved for analyse.
  -- 5. Correctness of timeouts is being checked.
  --
  -- Results:
  --
  -- 1. Configuration is set.
  -- 2. StandardReport1 is received.
  -- 3. Separate thread is spawned for overload simulation.
  -- 4. Timeouts of standard/accelerated are saved for analyse.
  -- 5. There is no drift in time.
function test_DriftOverTime_Standard1AndAccelerated()
  generic_test_DriftOverTime_StandardAndAccelerated(
    {StandardReport1Interval=4, AcceleratedReport1Rate=4},
    "ConfigChangeReport1",
    "StandardReport1",
    "AcceleratedReport1",
    4, --min (standard report interval)
    1, --min (accelerated report interval)
    3
  )
end

Annotations:register([[
@randIn(tcRandomizer,batch,driftOverTime,2)
@method(test_DriftOverTime_Standard2AndAccelerated)
@module(TestNormalReportsModule)
]])
--- TC checks if standard and accelerated reports timing do not drift over time.
  --
  -- Steps:
  --
  -- 1. Configuration is prepared (StandardReport2Interval=4, AcceleratedReport2Rate=4)
  -- 2. Waiting for first StandardReport2 is performed.
  -- 3. System overload is simulated.
  -- 4. Timeouts of standard/accelerated are being saved for analyse.
  -- 5. Correctness of timeouts is being checked.
  --
  -- Results:
  --
  -- 1. Configuration is set.
  -- 2. StandardReport2 is received.
  -- 3. Separate thread is spawned for overload simulation.
  -- 4. Timeouts of standard/accelerated are saved for analyse.
  -- 5. There is no drift in time.
function test_DriftOverTime_Standard2AndAccelerated()
  generic_test_DriftOverTime_StandardAndAccelerated(
    {StandardReport2Interval=4, AcceleratedReport2Rate=4},
    "ConfigChangeReport2",
    "StandardReport2",
    "AcceleratedReport2",
    4, --min (standard report interval)
    1, --min (accelerated report interval)
    3
  )
end

Annotations:register([[
@randIn(tcRandomizer,batch,driftOverTime,3)
@method(test_DriftOverTime_Standard3AndAccelerated)
@module(TestNormalReportsModule)
]])
--- TC checks if standard and accelerated reports timing do not drift over time.
  --
  -- Steps:
  --
  -- 1. Configuration is prepared (StandardReport3Interval=4, AcceleratedReport3Rate=4)
  -- 2. Waiting for first StandardReport3 is performed.
  -- 3. System overload is simulated.
  -- 4. Timeouts of standard/accelerated are being saved for analyse.
  -- 5. Correctness of timeouts is being checked.
  --
  -- Results:
  --
  -- 1. Configuration is set.
  -- 2. StandardReport3 is received.
  -- 3. Separate thread is spawned for overload simulation.
  -- 4. Timeouts of standard/accelerated are saved for analyse.
  -- 5. There is no drift in time.
function test_DriftOverTime_Standard3AndAccelerated()
  generic_test_DriftOverTime_StandardAndAccelerated(
    {StandardReport3Interval=4, AcceleratedReport3Rate=4},
    "ConfigChangeReport3",
    "StandardReport3",
    "AcceleratedReport3",
    4, --min (standard report interval)
    1, --min (accelerated report interval)
    3
  )
end


-----------------------------------------------------------------------------------------------
-- POLL REQUEST / RESPONSE Test cases
-----------------------------------------------------------------------------------------------

Annotations:register([[
@randIn(tcRandomizer,batch,pollResponse,1)
@method(test_PollRequest_WhenPollRequest1MessageIsSend_CorrectPollResponse1MessageIsReceived)
@module(TestNormalReportsModule)
]])
--- TC checks if PollResponse1 message is send after PollRequest1.
  -- Initial Conditions:
  --
  -- * Gps position is set. 
  --
  -- Steps:
  --
  -- 1. PollRequest1 message is sent.
  -- 2. Fields of PollResponse1 message are validated.
  --
  -- Results:
  --
  -- 1. PollResponse1 message is received.
  -- 2. Fields of PollResponse1 message are correct.
function test_PollRequest_WhenPollRequest1MessageIsSend_CorrectPollResponse1MessageIsReceived()
  generic_test_PollRequest(
    "PollRequest1", 
    "PollResponse1"
  )
end

Annotations:register([[
@randIn(tcRandomizer,batch,pollResponse,2)
@method(test_PollRequest_WhenPollRequest2MessageIsSend_CorrectPollResponse2MessageIsReceived)
@module(TestNormalReportsModule)
]])
--- TC checks if PollResponse2 message is send after PollRequest2.
  -- Initial Conditions:
  --
  -- * Gps position is set. 
  --
  -- Steps:
  --
  -- 1. PollRequest2 message is sent.
  -- 2. Fields of PollResponse2 message are validated.
  --
  -- Results:
  --
  -- 1. PollResponse2 message is received.
  -- 2. Fields of PollResponse2 message are correct.
function test_PollRequest_WhenPollRequest2MessageIsSend_CorrectPollResponse2MessageIsReceived()
  generic_test_PollRequest(
    "PollRequest2", 
    "PollResponse2"
  )
end

Annotations:register([[
@randIn(tcRandomizer,batch,pollResponse,3)
@method(test_PollRequest_WhenPollRequest3MessageIsSend_CorrectPollResponse3MessageIsReceived)
@module(TestNormalReportsModule)
]])
--- TC checks if PollResponse3 message is send after PollRequest3.
  -- Initial Conditions:
  --
  -- * Gps position is set. 
  --
  -- Steps:
  --
  -- 1. PollRequest3 message is sent.
  -- 2. Fields of PollResponse3 message are validated.
  --
  -- Results:
  --
  -- 1. PollResponse3 message is received.
  -- 2. Fields of PollResponse3 message are correct.
function test_PollRequest_WhenPollRequest3MessageIsSend_CorrectPollResponse3MessageIsReceived()
  generic_test_PollRequest(
    "PollRequest3", 
    "PollResponse3"
  )
end

Annotations:register([[
@randIn(tcRandomizer,batch,pollResponseWithOthers,1)
@method(test_PollRequest_WhenPollRequest1IsRequestedDuringStandardAndAcceleratedReportsCycle_AcceleratedIntervalIsCorrect)
@module(TestNormalReportsModule)
]])
--- TC checks requesting reports on demand (PollRequest/PollResponse) does not interfere with other reports timing.
  --
  -- Steps:
  --
  -- 1. Setup is done: StandardReport1Interval and AcceleratedReport1Rate are set to 2
  -- 2. Waiting for first Standard Report is performed.
  -- 3. In the middle of AcceleratedReport1 interval the PollRequest1 message is sent.
  -- 4. Waiting for AcceleratedReport1 is performed.
  -- 5. Timeout between reports is calculated. 
  --
  -- Results:
  --
  -- 1. Setup is correctly finished.
  -- 2. StandardReport1 is received.
  -- 3. PollResponse1 message is received.
  -- 4. AcceleratedReport1 is received.
  -- 5. Timeout between reports is correct.
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

Annotations:register([[
@randIn(tcRandomizer,batch,pollResponseWithOthers,2)
@method(test_PollRequest_WhenPollRequest2IsRequestedDuringStandardAndAcceleratedReportsCycle_AcceleratedIntervalIsCorrect)
@module(TestNormalReportsModule)
]])
--- TC checks requesting reports on demand (PollRequest/PollResponse) does not interfere with other reports timing.
  --
  -- Steps:
  --
  -- 1. Setup is done: StandardReport2Interval and AcceleratedReport1Rate are set to 2
  -- 2. Waiting for first Standard Report is performed.
  -- 3. In the middle of AcceleratedReport2 interval the PollRequest2 message is sent.
  -- 4. Waiting for AcceleratedReport2 is performed.
  -- 5. Timeout between reports is calculated. 
  --
  -- Results:
  --
  -- 1. Setup is correctly finished.
  -- 2. StandardReport2 is received.
  -- 3. PollResponse2 message is received.
  -- 4. AcceleratedReport2 is received.
  -- 5. Timeout between reports is correct.
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

Annotations:register([[
@randIn(tcRandomizer,batch,pollResponseWithOthers,3)
@method(test_PollRequest_WhenPollRequest3IsRequestedDuringStandardAndAcceleratedReportsCycle_AcceleratedIntervalIsCorrect)
@module(TestNormalReportsModule)
]])
--- TC checks requesting reports on demand (PollRequest/PollResponse) does not interfere with other reports timing.
  --
  -- Steps:
  --
  -- 1. Setup is done: StandardReport3Interval and AcceleratedReport1Rate are set to 2
  -- 2. Waiting for first Standard Report is performed.
  -- 3. In the middle of AcceleratedReport3 interval the PollRequest3 message is sent.
  -- 4. Waiting for AcceleratedReport1 is performed.
  -- 5. Timeout between reports is calculated. 
  --
  -- Results:
  --
  -- 1. Setup is correctly finished.
  -- 2. StandardReport3 is received.
  -- 3. PollResponse3 message is received.
  -- 4. AcceleratedReport3 is received.
  -- 5. Timeout between reports is correct.
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


--- Test if reportInterval is still 1 minute when StandardReport1Interval / AcceleratedReport1Rate = less than 1.
function test_StandardReport1_TheMinimumIntervalBetween2PositionReportsFromSameReportingServiceIs1minute()
  generic_test_StandardReportContent({
    firstReportKey = "StandardReport1",
    reportKey = "StandardReport1",  -- Accelerated report should not come at all
    properties = {StandardReport1Interval=1, AcceleratedReport1Rate=4}, -- 1/4
    firstReportInterval = 2,
    reportInterval = 1 -- report interval should be still 1 minute
  })
end

--- Test if reportInterval is still 1 minute when StandardReport2Interval / AcceleratedReport2Rate = less than 1.
function test_StandardReport2_TheMinimumIntervalBetween2PositionReportsFromSameReportingServiceIs1minute()
  generic_test_StandardReportContent({
    firstReportKey = "StandardReport2",
    reportKey = "StandardReport2",  -- Accelerated report should not come at all
    properties = {StandardReport2Interval=1, AcceleratedReport2Rate=4}, -- 1/4
    firstReportInterval = 2,
    reportInterval = 1 -- report interval should be still 1 minute
  })
end

--- Test if reportInterval is still 1 minute when StandardReport3Interval / AcceleratedReport3Rate = less than 1.
function test_StandardReport2_TheMinimumIntervalBetween2PositionReportsFromSameReportingServiceIs1minute()
  generic_test_StandardReportContent({
    firstReportKey = "StandardReport3",
    reportKey = "StandardReport3",  -- Accelerated report should not come at all
    properties = {StandardReport3Interval=1, AcceleratedReport3Rate=4}, -- 1/4
    firstReportInterval = 2,
    reportInterval = 1 -- report interval should be still 1 minute
  })
end


-----------------------------------------------------------------------------------------------
-- GENERIC LOGIC for test cases
-----------------------------------------------------------------------------------------------

--- Generic function which can be configured in multiple ways.
-- See the usage in TCs above.
--
-- It checks if sending PollRequest message in the middle of other reports timeout does not affect it.
-- 
-- Steps:
--   1. Configuration is prepared (TC method passes it).
--   2. Waiting for first standard report is performed.
--   3. In the middle of accelerated report interval the PollRequest message is sent.
--   4. Waiting for accelerated report is performed.
--   5. Correctness of timeouts is checked.
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

--- Generic function which can be configured in multiple ways.
-- See the usage in TCs above.
--
-- This is generic function for configure and test reports (StandardReport,AcceleratedReport)
-- 
-- Steps:
--   1. New gps position is set.
--   2. Configuration passed from TC is set (via config message or set properties message).
--   3. Waiting for first report is performed to synchronize report sequence.
--   4. Values of the report are checked.
--   5. New gps position is set.
--   6. Waiting for next report is performed.
--   6. Time difference between reports is calculated and checked.
--   7. Values of the report are checked.
function generic_test_StandardReportContent(configuration)

  -- setting values from configuration
  local firstReportKey = configuration.firstReportKey  -- first report name
  local reportKey = configuration.reportKey -- second report name
  local properties = configuration.properties -- StandardReportXInterval, AcceleratedReportXRate
  local firstReportInterval = configuration.firstReportInterval -- first report interval
  local reportInterval = configuration.reportInterval -- second report interval
  local setConfigMsgKey = configuration.setConfigMsgKey -- setConfig message name
  local fields = configuration.fields -- fields for setConfig message
  local configChangeMsgKey = configuration.configChangeMsgKey -- configChange message name

  -- new position setup
  D:log("Setting initial gps position")
  local newPosition = {
    latitude  = 1,
    longitude = 1,
    speed =  1,
    heading = 1
  }
  GPS:set(newPosition)
  framework.delay(GPS_READ_INTERVAL + GPS_PROCESS_TIME)

  -- testing via message
  if setConfigMsgKey then
    D:log("Using setConfigMsg for setup")
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
    D:log("Using setProperties for setup")
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
  D:log("First report "..firstReportKey.." is sent")

  -- check values from first report
  D:log("Checking values from first report -  "..firstReportKey)
  assert_equal(
    GPS:denormalize(newPosition.latitude),
    tonumber(preReportMessage[firstReportKey].Latitude),
    "Wrong latitude in " .. firstReportKey
  )
  assert_equal(
    GPS:denormalize(newPosition.longitude),
    tonumber(preReportMessage[firstReportKey].Longitude),
    "Wrong longitude in " .. firstReportKey
  )
  assert_equal(
    GPS:denormalizeSpeed(newPosition.speed),
    tonumber(preReportMessage[firstReportKey].Speed),
    1,
    "Wrong speed in " .. firstReportKey
  )
  assert_equal(
    1,
    tonumber(preReportMessage[firstReportKey].Course),
    0,
    "Wrong course in report " .. firstReportKey
  )

  -- saving timestamp for diff calculations
  local timestampStart = preReportMessage[firstReportKey].Timestamp

  -- new position setup
  D:log("Setting second gps position")
  local newPosition = {
    latitude  = 2,
    longitude = 2,
    speed =  2,
    heading = 2
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
  D:log("Second report "..firstReportKey.." is sent")

  -- calculate time diff
  D:log("Checking diff between timestamps of two reports")
  local timestampEnd = reportMessage[reportKey].Timestamp
  local timestampDiff = timestampEnd - timestampStart
  assert_equal(
    reportInterval*60,
    timestampDiff,
    5,
    "Wrong time diff between raports"
  )

  D:log("Checking values from second report -  "..reportKey)
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
  assert_equal(
    2,
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

-- Generic function which can be configured in multiple ways.
-- See the usage in TCs above.
--
-- This is generic function for testing Config Change Reports.
-- 
-- Steps:
--   1. Properties values are incremented. 
--   2. Properties are sent (via setPropertiesByName or setConfig message).
--   3. Waiting for ConfigChange report is performed.
--   4. Properties are fetched.
--   5. Raport values are checked.
--   6. Raport values are compared to fetched properties.
--   7. Change source is checked.
--   8. Timestamp is checked.
function generic_test_ConfigChangeReportConfigChangeReportIsSent(messageKey,propertiesToChange,propertiesBeforeChange,setConfigMsgKey)

  propertiesToChangeValues = {}
  propertiesToChangeValues2 = {}
  propertiesToChangeValuesForMessage = {}

  -- setting properties to change
  for i=1, #propertiesToChange do
    -- values for first setup (by setPropertiesByName)
    propertiesToChangeValues[propertiesToChange[i]] = propertiesBeforeChange[propertiesToChange[i]] + 1 
    -- values for second setup (by setConfigReportX message)
    propertiesToChangeValues2[propertiesToChange[i]] = propertiesBeforeChange[propertiesToChange[i]] + 2 
    table.insert(
      propertiesToChangeValuesForMessage,
      { Name = propertiesToChange[i],  Value = (propertiesBeforeChange[propertiesToChange[i]] + 2) }
    )
  end

  -- first setup (by setPropertiesByName)
  vmsSW:setPropertiesByName(propertiesToChangeValues)

  -- testing via message
  if setConfigMsgKey then
    -- raport triggered by setProperties is passed
    vmsSW:waitForMessagesByName(
      {messageKey},
      30
    )
    -- values for second setup (by setConfigReportX message)
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
    --TODO: check fields in ConfigChangeReport (previous and current)
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

--- Generic function which can be configured in multiple ways.
-- See the usage in TCs above.
--
-- This checkes if standard reports are disabled properly.
-- 
-- Steps:
--   1. Properties are set (via system service or vms) in a way that disables reports.
--   2. Standard report is checked (should not come).
--   3. Accelerated report is checked (should not come).
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

  vmsSW:setHighWaterMark()

  D:log("Waiting for standard/accelerated report - should not come")
  local reportMessage = vmsSW:waitForMessagesByName(
    {reportKey,acceleratedReportKey},
    reportInterval
  )
  D:log(reportMessage,"reportMessage")
  assert_equal(0,tonumber(reportMessage.count),"Message"..reportKey.." should not come!")

end

-- This is generic function for disabled accelerated reports test (and standard reports enabled)
-- 
-- Steps:
--   1. Properties are set (via system service or vms) in a way that disables accelerated reports and enables standard reports.
--   2. Waiting for standard report is performed.
--   3. Standard report is received.
--   4. Waiting for accelerated report is performed.
--   5. Accelerated report should not come.
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

--- Generic function which can be configured in multiple ways.
-- See the usage in TCs above.
--
-- It checks if property debounce time works properly.
-- 
-- Steps:
--   1. Property change debounce time is set to 1 minute.
--   2. Properties are changed.
--   3. Properties are restored to previous values.
--   4. ConfigChange message is not sent (means configuration change has had no impact)
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

--- Generic function which can be configured in multiple ways.
-- See the usage in TCs above.
--
-- It checks if two ConfigChange reports have correct timestamps.
-- 
-- Steps:
--   1. Property change debounce time is set to 1 second. 
--   2. Properties are changed.
--   3. Waiting for zero ConfigChange message is performed.
--   4. Property change debounce time is set to 60 seconds.
--   5. Initial properties are set after 5 seconds.
--   6. Waiting for ConfigChange first message is performed.
--   7. Properties are changed.
--   8. Waiting for ConfigChange second message is performed.
--   9. Difference between timestamps is checked.
function generic_TimestampsInConfigChangeReports(configChangeMsgKey,initialProperties,changedProperties)
 
  framework.delay(65) -- because previous TC could have had longer debounce time
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

--- Generic function which can be configured in multiple ways.
-- See the usage in TCs above.
--
-- It checks if ConfigChangeReport is sent after changes made via console.
-- 
-- Steps:
--   1. Properties to change are incremented.
--   2. Properties are set via shell (vms service wrapper has such functionality)
--   3. Waiting for ConfigChangeReportX message is performed.
--   4. It is checked if no others reports comming.
--   5. Values in ConfigChangeReportX are checked.
--   6. Change source is checked for console string.
--   7. Timestamp of the report is checked.
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

--- Generic function which can be configured in multiple ways.
-- See the usage in TCs above.
--
-- It checks if standard and accelerated reports timing do not drift over time.
-- 
-- Steps:
--   1. Configuration is prepared (TC method passes it).
--   2. Waiting for first standard report is performed.
--   3. System overload is simulated (in a separate thread)
--   4. Timeouts of standard/accelerated are saved for analyse.
--   5. Correctness of timeouts is checked.
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

--- Generic function which can be configured in multiple ways.
-- See the usage in TCs above.
--
-- It checks if PollResponse message is send after PollRequest.
-- 
-- Steps:
--   1. Gps position is sent. 
--   2. PollRequest message is set.
--   3. PollResponse message is received.
--   4. Fields of PollResponse message are validated.
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


