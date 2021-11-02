local FlyoutRow_Ability = {
  Properties = {
    AbilityName = {
      default = EntityId()
    },
    AbilityIcon = {
      default = EntityId()
    },
    AbilityDescription = {
      default = EntityId()
    },
    CooldownLabel = {
      default = EntityId()
    },
    CooldownTime = {
      default = EntityId()
    },
    CooldownIcon = {
      default = EntityId()
    }
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(FlyoutRow_Ability)
function FlyoutRow_Ability:OnInit()
  BaseElement.OnInit(self)
  self.descriptionTop = UiTransformBus.Event.GetLocalPositionY(self.Properties.AbilityDescription)
  self.bottomPadding = 20
end
function FlyoutRow_Ability:SetData(data)
  if not data or not data.abilityName then
    Log("[FlyoutRow_Ability] Error: invalid data passed to SetData")
    return
  end
  UiTextBus.Event.SetTextWithFlags(self.Properties.AbilityName, data.abilityName, eUiTextSet_SetLocalized)
  SetTextStyle(self.Properties.AbilityName, self.UIStyle.FONT_STYLE_ABILITY_TOOLTIP_HEADER)
  UiElementBus.Event.SetIsEnabled(self.Properties.AbilityIcon, data.abilityIcon ~= nil)
  if data.abilityIcon then
    UiImageBus.Event.SetSpritePathname(self.Properties.AbilityIcon, data.abilityIcon)
  end
  UiElementBus.Event.SetIsEnabled(self.Properties.CooldownLabel, data.cooldownTime ~= nil)
  UiElementBus.Event.SetIsEnabled(self.Properties.CooldownTime, data.cooldownTime ~= nil)
  SetTextStyle(self.Properties.CooldownLabel, self.UIStyle.FONT_STYLE_ABILITY_TOOLTIP_DESCRIPTION)
  SetTextStyle(self.Properties.CooldownTime, self.UIStyle.FONT_STYLE_ABILITY_TOOLTIP_DURATION)
  if data.cooldownTime then
    UiTextBus.Event.SetText(self.Properties.CooldownTime, data.cooldownTime)
  end
  UiTextBus.Event.SetTextWithFlags(self.Properties.AbilityDescription, data.abilityDescription, eUiTextSet_SetLocalized)
  SetTextStyle(self.Properties.AbilityDescription, self.UIStyle.FONT_STYLE_ABILITY_TOOLTIP_DESCRIPTION)
  local textHeight = UiTextBus.Event.GetTextHeight(self.Properties.AbilityDescription)
  local totalHeight = self.descriptionTop + textHeight + self.bottomPadding
  UiTransform2dBus.Event.SetLocalHeight(self.entityId, totalHeight)
  UiLayoutCellBus.Event.SetTargetHeight(self.entityId, totalHeight)
end
return FlyoutRow_Ability
