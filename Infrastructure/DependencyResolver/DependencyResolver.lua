-- DependencyResolver interface definition
DependencyResolver = {}
  DependencyResolver.__index = DependencyResolver

  function DependencyResolver:resolve(definition)
    D:log(definition,"def")
    return true 
  end
