
table.size = function(inTable)
  local size = 0
  if inTable == nil then return size end
  for _, _ in pairs(inTable) do 
    size = size + 1
  end
  return size
end

-- splits list-like table (number indexes from 1) into two tables
-- e.g. a = {1,2,3,4,5}
-- b,c = table.split(a, 3)
-- b = {1,2,3}
-- c = {4,5}
table.split = function(inTable, index)
  local ltable = {}
  local rtable = {}
  for i=1, index do
    ltable[i] = inTable[i]
  end
  
  for i=index+1, table.size(inTable) do
    rtable[i-index] = inTable[i]
  end
  
  return ltable, rtable
end

-- converts list to table of key = true elements
-- e.g. {"A", "B", "C"}
-- result = {A= true, B=true, C=true}
table.trueList = function(inTable)
  local result = {}
  for idx, key in pairs(inTable) do
    result[key] = true
  end
  return result
end

--
--local a = {1,2,3,4,5}
--local b, c = table.split(a, 3)



