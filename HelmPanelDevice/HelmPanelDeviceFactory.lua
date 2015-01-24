require("HelmPanelDevice/HelmPanelUnibox")

---------------------------------------------------------------------- 
-- Helm Panel Device factory method
----------------------------------------------------------------------
local helmPanelDeviceFactory = {}

function helmPanelDeviceFactory.create(variant)

  local helmPanel

  if variant == "unibox" then
    if uniboxSW == nil or shellSW == nil then
      print "Helm panel device needs unibox and shell service wrappers!"
      return nil
    end
    helmPanel = HelmPanelUnibox(uniboxSW,shellSW)
  end
  
  print("Helm Panel used : " .. variant)

  return helmPanel
end

return function() return helmPanelDeviceFactory end

