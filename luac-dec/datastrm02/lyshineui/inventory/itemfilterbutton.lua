local ItemFilterButton = {
  Properties = {
    Icon = {
      default = EntityId()
    },
    Tooltip = {
      default = EntityId()
    }
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(ItemFilterButton)
function ItemFilterButton:OnInit()
end
function ItemFilterButton:OnFocus()
  if self.mIsUsingTooltip then
    self.Tooltip:OnTooltipSetterHoverStart()
  end
  self.ScriptedEntityTweener:Play(self.Icon, 0.1, {
    imgColor = self.UIStyle.COLOR_WHITE
  })
  self.audioHelper:PlaySound(self.audioHelper.OnHover_ButtonSimpleText)
end
function ItemFilterButton:OnUnfocus()
  if self.mIsUsingTooltip then
    self.Tooltip:OnTooltipSetterHoverEnd()
  end
  self.ScriptedEntityTweener:Play(self.Icon, 0.1, {
    imgColor = self.UIStyle.COLOR_TAN
  })
end
function ItemFilterButton:OnPress()
  self.audioHelper:PlaySound(self.audioHelper.Crafting_Tab_Select)
end
function ItemFilterButton:SetTooltip(value)
  if value == nil or value == "" then
    self.mIsUsingTooltip = false
    UiElementBus.Event.SetIsEnabled(self.Tooltip.entityId, false)
  else
    self.mIsUsingTooltip = true
    self.Tooltip:SetSimpleTooltip(value)
    UiElementBus.Event.SetIsEnabled(self.Tooltip.entityId, true)
  end
end
function ItemFilterButton:OnShutdown()
end
return ItemFilterButton
