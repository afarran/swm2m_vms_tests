require "Service/ServiceWrapper"
FilesystemServiceWrapper = {}
  FilesystemServiceWrapper.__index = FilesystemServiceWrapper
  setmetatable(FilesystemServiceWrapper, {
    __index = ServiceWrapper, -- this is what makes the inheritance work
    __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
    end,
  })
  
  function FilesystemServiceWrapper:_init()
    
    local properties = {}
          
    local messages_from = { { name ="writeResult", min=1},
                            { name ="readResult", min=2},
                            { name ="dirResult", min=3},
                            { name ="statResult", min=4},
                          }
    
    local messages_to = { { name ="write", min=1},
                          { name ="read", min=2},
                          { name ="dir", min=3},
                          { name ="stat", min=4},
                        }
      
    ServiceWrapper._init(self, {
        sin = 24, 
        name = "Filesystem", 
        messages_to = messages_to, 
        messages_from = messages_from, 
        properties = properties
    })
  end
  
  -- returns two values
  -- 1. data read
  -- 2. data readResult message
  function FilesystemServiceWrapper:read(path, offset, size, raw)
    raw = raw or false
    local readResult = nil
    local readData
    local Fields = {}
    Fields = {
      {Name="path",Value=path},
      {Name="offset",Value=offset},
      {Name="size",Value=size},
    }
    local previousWaterMark = self:getHighWaterMark()
    self:sendMessageByName("read", Fields)
    self:setHighWaterMark()
    readResult = self:waitForMessagesByName({"readResult"}).readResult
    -- restore previous watermark
    self:setHighWaterMark(previousWaterMark)
    if not readResult then return nil end
    if not raw then
      readData = framework.base64Decode(readResult.data)
    else
      readData = readResult.data
    end
    return readData, readResult
  end
  
  -- returns two values
  -- 1. if write succeded
  -- 2. writeResult message
  function FilesystemServiceWrapper:write(path, offset, data, mode, raw)
    mode = mode or "Overwrite"
    raw = raw or false
    local dataToSend
    local Fields = {}
    if not raw then 
      dataToSend = framework.base64Encode(data)
    else
      dataToSend = data
    end
    
    Fields = {
      {Name="path",Value=path},
      {Name="offset",Value=offset},
      {Name="data",Value=dataToSend},
      {Name="flags",Value=mode},
    }
    local previousWaterMark = self:getHighWaterMark()
    self:sendMessageByName("write", Fields)
    self:setHighWaterMark()
    local writeResult = self:waitForMessagesByName({"writeResult"}).writeResult
    self:setHighWaterMark(previousWaterMark)
    if not writeResult then return nil end
    
    if writeResult.result == "OK" then
      return true, writeResult
    else
      return false, writeResult
    end
  end

