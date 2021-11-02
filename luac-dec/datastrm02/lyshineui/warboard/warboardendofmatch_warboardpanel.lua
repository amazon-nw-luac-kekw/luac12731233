local WarboardEndOfMatch_WarboardPanel = {
  Properties = {
    WarboardText = {
      default = EntityId()
    }
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(WarboardEndOfMatch_WarboardPanel)
function WarboardEndOfMatch_WarboardPanel:OnInit()
  BaseElement.OnInit(self)
end
function WarboardEndOfMatch_WarboardPanel:OnShutdown()
end
return WarboardEndOfMatch_WarboardPanel
