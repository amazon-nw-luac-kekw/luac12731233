local FlyoutRow_CurrencyInfo = {
  Properties = {
    NameText = {
      default = EntityId()
    },
    DescriptionText = {
      default = EntityId()
    },
    Icon = {
      default = EntityId()
    },
    DerivedFromText = {
      default = EntityId()
    },
    DerivedFromContainer = {
      default = EntityId()
    }
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(FlyoutRow_CurrencyInfo)
function FlyoutRow_CurrencyInfo:OnInit()
  BaseElement.OnInit(self)
  self.initialHeight = UiTransform2dBus.Event.GetLocalHeight(self.entityId)
  self.initialWidth = UiTransform2dBus.Event.GetLocalWidth(self.entityId)
end
function FlyoutRow_CurrencyInfo:SetData(data)
  local iconPath = data.iconPath
  local currencyName = data.currencyName
  local derivedFrom = data.derivedFrom
  local descriptionText = data.descriptionText
  UiImageBus.Event.SetSpritePathname(self.Properties.Icon, iconPath)
  UiTextBus.Event.SetTextWithFlags(self.Properties.NameText, currencyName, eUiTextSet_SetLocalized)
  UiTextBus.Event.SetTextWithFlags(self.Properties.DescriptionText, descriptionText, eUiTextSet_SetLocalized)
  UiElementBus.Event.SetIsEnabled(self.Properties.DerivedFromContainer, derivedFrom ~= nil)
  if derivedFrom ~= nil then
    UiTextBus.Event.SetTextWithFlags(self.Properties.DerivedFromText, derivedFrom, eUiTextSet_SetLocalized)
  end
  local height = data.height or self.initialHeight
  local width = data.width or self.initialWidth
  UiTransform2dBus.Event.SetLocalHeight(self.entityId, height)
  UiTransform2dBus.Event.SetLocalWidth(self.entityId, width)
end
return FlyoutRow_CurrencyInfo
