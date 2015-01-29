-- Annotations interface definition
Annotations = {}
  Annotations.__index = Annotations
  Annotations.registered = {}

  function Annotations:register(docstr)
    local module
    local method
    local annotations = {}

    local found = {string.gmatch(docstr, "@(%w+)%(([%w,_]+)%)")}
    for key,value in found[1] do
      if key == "module" then
        module = value
      elseif key == "method" then
        method = value
      end
      annotations[key]=value
    end
    -- D:log(module,"module")
    -- D:log(method,"method")
    -- D:log(annotations,"annotations")

    if (Annotations.registered[module] == nil) then
      Annotations.registered[module] = {}
    end
    Annotations.registered[module][method] = annotations

    D:log(Annotations.registered,"registered")
  end

  function Annotations:get(annotation,module,method)

    if Annotations.registered[module] == nil or 
       Annotations.registered[module][method] == nil then
      return false
    end

    if Annotations.registered[module][method][annotation] then 
      return Annotations.registered[module][method][annotation]
    end

    return false

  end
  
  


