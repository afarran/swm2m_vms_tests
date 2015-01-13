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
