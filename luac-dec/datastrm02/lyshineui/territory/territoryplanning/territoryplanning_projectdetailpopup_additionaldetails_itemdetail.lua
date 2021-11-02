local TerritoryPlanning_ProjectDetailPopup_AdditionalDetails_ItemDetail = {
  Properties = {
    Icon = {
      default = EntityId()
    },
    Text = {
      default = EntityId()
    },
    IconBg = {
      default = EntityId()
    }
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(TerritoryPlanning_ProjectDetailPopup_AdditionalDetails_ItemDetail)
function TerritoryPlanning_ProjectDetailPopup_AdditionalDetails_ItemDetail:OnInit()
  BaseElement.OnInit(self)
end
function TerritoryPlanning_ProjectDetailPopup_AdditionalDetails_ItemDetail:OnShutdown()
end
function TerritoryPlanning_ProjectDetailPopup_AdditionalDetails_ItemDetail:SetAdditionalItemDetail(icon, text)
  UiElementBus.Event.SetIsEnabled(self.Properties.Icon, icon ~= nil)
  UiElementBus.Event.SetIsEnabled(self.Properties.Text, text ~= nil)
  UiElementBus.Event.SetIsEnabled(self.Properties.IconBg, icon ~= nil)
  if icon then
    UiImageBus.Event.SetSpritePathname(self.Properties.Icon, icon)
  end
  if text then
    UiTextBus.Event.SetTextWithFlags(self.Properties.Text, text, eUiTextSet_SetLocalized)
  end
end
return TerritoryPlanning_ProjectDetailPopup_AdditionalDetails_ItemDetail
