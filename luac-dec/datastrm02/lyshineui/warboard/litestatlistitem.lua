local LiteStatListItem = {
  Properties = {
    StatName = {
      default = EntityId()
    },
    StatValue = {
      default = EntityId()
    }
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(LiteStatListItem)
function LiteStatListItem:OnInit()
  BaseElement.OnInit(self)
end
function LiteStatListItem:OnShutdown()
end
function LiteStatListItem:SetData(statName, statValue)
  UiTextBus.Event.SetTextWithFlags(self.Properties.StatName, statName, eUiTextSet_SetLocalized)
  UiTextBus.Event.SetText(self.Properties.StatValue, statValue)
end
return LiteStatListItem
