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

    if (Annotations.registered[module] == nil) then
      Annotations.registered[module] = {}
    end
    Annotations.registered[module][method] = annotations
  end

  function Annotations:get(annotation,module,method)
    if Annotations.registered[module] == nil or Annotations.registered[module][method] == nil then
      return false
    end

    if Annotations.registered[module][method][annotation] then 
      return Annotations.registered[module][method][annotation]
    end

    return false
  end

  function Annotations:resolve(annotationName,module,method)

    local definition = Annotations:get(annotationName,module,method)

    if type(definition) ~= "string" then
      return true
    end
    local descr = Annotations:parseDef(definition)
    if _G[descr.object] == nil then
      D:log("Object "..descr.object.." not found!")
      return true
    end
    if _G[descr.object][descr.method] == nil then
      D:log("Method  not found!")
      return true
    end
    return _G[descr.object][descr.method](_G[descr.object],descr.args)
  end

  function Annotations:parseDef(def)
    local splt = string.split(def,',')
    local result = {}
    result['object']=splt[1]
    result['method']=splt[2]
    if #splt>2 then
      result['args'] = {}
      for i,value in pairs(splt) do
        if i>2 then
          table.insert(result['args'],value)
        end 
      end
    end
    return result
  end

