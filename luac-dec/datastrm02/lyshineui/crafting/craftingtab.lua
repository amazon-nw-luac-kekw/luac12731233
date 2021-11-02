local CraftingTab = {
  Properties = {
    HoverGlow = {
      default = EntityId()
    },
    Hash = {
      default = EntityId()
    },
    Text = {
      default = EntityId()
    },
    TextSelected = {
      default = EntityId()
    },
    Icon = {
      default = EntityId()
    },
    Tooltip = {
      default = EntityId()
    }
  },
  pressCallback = nil,
  pressTable = nil
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(CraftingTab)
function CraftingTab:OnInit()
  UiElementBus.Event.SetIsEnabled(self.HoverGlow, false)
  UiElementBus.Event.SetIsEnabled(self.Hash, false)
  self.Properties.TextSelected = UiElementBus.Event.FindDescendantByName(self.entityId, "TextSelected")
end
function CraftingTab:SetCallback(command, table)
  self.pressCallback = command
  self.pressTable = table
end
function CraftingTab:OnFocus()
  if self.mIsUsingTooltip then
    self.Tooltip:OnTooltipSetterHoverStart()
  end
  UiElementBus.Event.SetIsEnabled(self.HoverGlow, true)
  if not self.timeline then
    self.timeline = self.ScriptedEntityTweener:TimelineCreate()
    self.timeline:Add(self.HoverGlow, self.UIStyle.DURATION_TIMELINE_FADE_OUT, {opacity = 0.2})
    self.timeline:Add(self.HoverGlow, self.UIStyle.DURATION_TIMELINE_FADE_IN, {opacity = 0.4})
    self.timeline:Add(self.HoverGlow, self.UIStyle.DURATION_TIMELINE_HOLD, {
      opacity = 0.4,
      onComplete = function()
        self.timeline:Play()
      end
    })
  end
  self.ScriptedEntityTweener:Play(self.Properties.HoverGlow, self.UIStyle.DURATION_BUTTON_FADE_IN, {opacity = 0.4, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.Properties.HoverGlow, self.UIStyle.DURATION_BUTTON_FADE_IN_HOLD, {
    opacity = 0.4,
    delay = self.UIStyle.DURATION_BUTTON_FADE_IN,
    onComplete = function()
      self.timeline:Play()
    end
  })
  UiElementBus.Event.SetIsEnabled(self.Hash, true)
  self.ScriptedEntityTweener:Play(self.Hash, 0.2, {opacity = 0}, {opacity = 1, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.Text, 0.2, {opacity = 0.5}, {opacity = 1, ease = "QuadOut"})
  self.audioHelper:PlaySound(self.audioHelper.Crafting_Tab_Hover)
  if self.Icon then
    self.ScriptedEntityTweener:Play(self.Icon, 0.2, {opacity = 0.75}, {opacity = 1, ease = "QuadOut"})
  end
end
function CraftingTab:OnUnfocus()
  if self.mIsUsingTooltip then
    self.Tooltip:OnTooltipSetterHoverEnd()
  end
  self.ScriptedEntityTweener:Play(self.HoverGlow, 0.3, {opacity = 0, ease = "QuadIn"})
  self.ScriptedEntityTweener:Play(self.Hash, 0.05, {opacity = 1}, {opacity = 0, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.Text, 0.2, {opacity = 1}, {opacity = 0.5, ease = "QuadOut"})
  if self.Icon then
    self.ScriptedEntityTweener:Play(self.Icon, 0.2, {opacity = 1}, {opacity = 0.75, ease = "QuadOut"})
  end
end
function CraftingTab:OnPress()
  if self.mIsUsingTooltip then
    self.Tooltip:OnTooltipSetterHoverEnd()
  end
  self.audioHelper:PlaySound(self.audioHelper.Crafting_Tab_Select)
end
function CraftingTab:SetText(text)
  UiTextBus.Event.SetTextWithFlags(self.Properties.Text, text, eUiTextSet_SetLocalized)
  UiTextBus.Event.SetTextWithFlags(self.Properties.TextSelected, text, eUiTextSet_SetLocalized)
end
function CraftingTab:OnSelected()
  if self.pressCallback and self.pressTable and type(self.pressCallback) == "function" then
    self.pressCallback(self.pressTable, self)
  end
end
function CraftingTab:GetState()
  return UiRadioButtonBus.Event.GetState(self.entityId)
end
function CraftingTab:SetTooltip(value)
  if value == nil or value == "" then
    self.mIsUsingTooltip = false
    UiElementBus.Event.SetIsEnabled(self.Tooltip.entityId, false)
  else
    self.mIsUsingTooltip = true
    self.Tooltip:SetSimpleTooltip(value)
    UiElementBus.Event.SetIsEnabled(self.Tooltip.entityId, true)
  end
end
function CraftingTab:OnShutdown()
  if self.timeline ~= nil then
    self.timeline:Stop()
    self.ScriptedEntityTweener:TimelineDestroy(self.timeline)
  end
end
return CraftingTab
