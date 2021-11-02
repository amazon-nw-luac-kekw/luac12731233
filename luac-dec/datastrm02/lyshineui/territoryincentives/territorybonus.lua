local TerritoryBonus = {
  Properties = {
    BonusTitle = {
      default = EntityId()
    },
    BonusDescription = {
      default = EntityId()
    },
    BonusDiscountHolder = {
      default = EntityId()
    },
    BonusDiscountValue = {
      default = EntityId()
    },
    BonusImage = {
      default = EntityId()
    }
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(TerritoryBonus)
function TerritoryBonus:OnInit()
  BaseElement.OnInit(self)
  self:SetVisualElements()
end
function TerritoryBonus:SetVisualElements()
  local bonusTitleStyle = {
    fontFamily = self.UIStyle.FONT_FAMILY_PICA,
    fontSize = 32,
    fontColor = self.UIStyle.COLOR_WHITE
  }
  local bonusDescriptionStyle = {
    fontFamily = self.UIStyle.FONT_FAMILY_NIMBUS_REGULAR,
    fontSize = 28,
    fontColor = self.UIStyle.COLOR_GRAY_80
  }
  local bonusDiscountValueStyle = {
    fontFamily = self.UIStyle.FONT_FAMILY_CASLON,
    fontSize = 40,
    fontColor = self.UIStyle.COLOR_WHITE
  }
  SetTextStyle(self.Properties.BonusTitle, bonusTitleStyle)
  SetTextStyle(self.Properties.BonusDescription, bonusDescriptionStyle)
  SetTextStyle(self.Properties.BonusDiscountValue, bonusDiscountValueStyle)
  UiElementBus.Event.SetIsEnabled(self.Properties.BonusDiscountHolder, false)
end
function TerritoryBonus:SetText(value)
  UiTextBus.Event.SetTextWithFlags(self.Properties.BonusTitle, value, eUiTextSet_SetLocalized)
end
function TerritoryBonus:SetTextDescription(value)
  UiTextBus.Event.SetTextWithFlags(self.Properties.BonusDescription, value, eUiTextSet_SetLocalized)
end
function TerritoryBonus:SetDiscountValue(value)
  if value then
    UiElementBus.Event.SetIsEnabled(self.Properties.BonusDiscountHolder, true)
    UiTextBus.Event.SetText(self.Properties.BonusDiscountValue, value)
  end
end
function TerritoryBonus:SetImage(value)
  UiImageBus.Event.SetSpritePathname(self.Properties.BonusImage, value)
end
function TerritoryBonus:SetEnabled(isEnabled)
  if isEnabled then
    UiDesaturatorBus.Event.SetSaturationValue(self.entityId, 1)
  else
    UiDesaturatorBus.Event.SetSaturationValue(self.entityId, 0)
  end
end
return TerritoryBonus
