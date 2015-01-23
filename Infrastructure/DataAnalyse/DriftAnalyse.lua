-- DriftAnalyse 
-- Implementation of algorithm for analyze anti-drift feature
-- Delays are cumulated and even then final balance is checked (with tolerance if needed)
DriftAnalyse = {}
  DriftAnalyse.__index = DriftAnalyse
  setmetatable(DriftAnalyse, {
    __call = function(cls, ...)
      local self = setmetatable({}, cls)
      self:_init(...)
      return self
    end,})

  function DriftAnalyse:_init()
  end
  
  function DriftAnalyse:perform(data,interval,tolerance_max,tolerance_min) 

    local cumulatedDiff = 0

    for i,item in ipairs(data) do
      if item > interval then
        cumulatedDiff = cumulatedDiff + (item-interval)
      elseif item < interval then
        if cumulatedDiff - (interval - item) == 0 then
          cumulatedDiff = 0
        else
          cumulatedDiff = cumulatedDiff - (interval - item)
        end
      end
    end

    if cumulatedDiff > tolerance_max or cumulatedDiff < tolerance_min  then
      return false
    end

    return true
  end

-- usage
-- finalData = {4,116,60,61,60,58,61,60}
-- da = DriftAnalyse()
-- if not da:perform(finalData,60,2,-2) then print("found inconsistency!") end
