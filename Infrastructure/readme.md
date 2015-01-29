Annotations/Annotations.lua | DependencyResolver/DependencyResolver.lua

Managing dependencies with installed/enabled services.

1. Some TCs need to have given service installed on the device.
2. If the service is not installed/enabled the TC should skip.
3. I assumed that the best way to achieve such behaviour would be aspect style with usage of annotations.
4. I was quite dissapointed that I could not act in this way in LUA. Well there is something like annotation but not in the style I ment - this is rather for ldoc docs... :(
5. So I implemented simple annotation engine :)
6. The Annotations works in this way:

a) First you annotate like in other languages (almost):
```
 Annotations:register([[
 @dependOn(helmPanel,isReady)
 @method(test_XXX)
 @module(TestHelmPanelModule)
 ]])
 function test_XXX()
  --implementation
```
b) Then resolver is able to get annotation @dependencies and invoke by reflection needed method (in this case helmPanel:isReady())

```
function DependencyResolver:resolve(definition)
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
  return _G[descr.object][descr.method](_G[descr.object])
end
```

c) This method is an aspect - in this example it just check terminal if helm panel device (unibox) is installed and enabled. All logic and reason to change is here.

```
function HelmPanelUnibox:isReady()
  local serviceList = self.system:requestMessageByName("getServiceList",nil,"serviceList")
  local disabledList = framework.base64Decode(serviceList.serviceList.disabledList)
  local sinList = framework.base64Decode(serviceList.serviceList.sinList)
  local enabled = false
  for i,v in ipairs(sinList) do
    if tonumber(v) == tonumber(self.device.sin) then
      enabled = true
      break
    end
  end
  for i,v in ipairs(disabledList) do
    if tonumber(self.device.sin) == tonumber(v) then
      enabled = false
    end
  end
  if enabled then
    return true
  end
  return "Unibox is not installed!"
end


```

Any TC can be annotated in this way - no need to do more.

Other annotations can be designed - that is the piece of design which can be tuned (simple but works).

pblo


