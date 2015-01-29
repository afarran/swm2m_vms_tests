require("HelmPanelDevice/HelmPanelUnibox")

---------------------------------------------------------------------- 
-- Helm Panel Device factory method
----------------------------------------------------------------------
local helmPanelDeviceFactory = {}

function helmPanelDeviceFactory.create(variant)

  local helmPanel

  if variant == "unibox" then
    if uniboxSW == nil or shellSW == nil or systemSW == nil then
      print "Helm panel device needs unibox, shell and system service wrappers!"
      return nil
    end
    helmPanel = HelmPanelUnibox(uniboxSW,shellSW,systemSW)
  end
  
  print("Helm Panel used : " .. variant)

  return helmPanel
end

return function() return helmPanelDeviceFactory end

