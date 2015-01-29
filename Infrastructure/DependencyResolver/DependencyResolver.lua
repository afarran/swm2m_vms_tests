-- DependencyResolver interface definition
DependencyResolver = {}
  DependencyResolver.__index = DependencyResolver

  function DependencyResolver:resolve(definition)
    D:log(type(definition))
    if type(definition) ~= "string" then
      return true
    end
    local descr = DependencyResolver:parseDef(definition)
    if _G[descr.object] == nil then
      D:log("Object "..descr.object.." not found!")
      return true
    end
    if _G[descr.object][descr.method] == nil then
      D:log("Method "..descr.method.." not found!")
      return true
    end
    return _G[descr.object][descr.method]()
  end

  function DependencyResolver:parseDef(def)
    local splt = string.split(def,',')
    local result = {}
    result['object']=splt[1]
    result['method']=splt[2]
    return result
  end
