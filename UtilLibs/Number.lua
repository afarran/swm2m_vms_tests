function decimalToBinary(num)

  local tableOfBits={}
  while num>0 do
    rest=math.fmod(num,2)
    tableOfBits[#tableOfBits+1]=rest
    num=(num-rest)/2
  end
  for i=1,32 do -- tableOfBits should always be 32 bits long
    if(tableOfBits[i]== nil) then tableOfBits[i] = 0 end
  end

  return tableOfBits

end

function binaryToDecimal(bitset)
  local result = 0
  for index, bit in pairs(bitset) do
    result = result + bit * math.pow(2,index-1)
  end
  return result
end