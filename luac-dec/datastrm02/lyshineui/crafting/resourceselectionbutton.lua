local ResourceSelectionButton = {
  Properties = {
    AmountText = {
      default = EntityId()
    },
    ButtonFocus = {
      default = EntityId()
    },
    ButtonSelected = {
      default = EntityId()
    },
    Tooltip = {
      default = EntityId()
    }
  },
  callbackFunction = nil,
  callbackTable = nil,
  enabled = true,
  selected = false,
  value = 0
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(ResourceSelectionButton)
function ResourceSelectionButton:OnInit()
  BaseElement:OnInit(self)
end
function ResourceSelectionButton:SetSelected(enable)
  local animDuration = 0.3
  if enable then
    self.selected = true
    self.ScriptedEntityTweener:Play(self.Properties.AmountText, animDuration, {
      textColor = self.UIStyle.COLOR_WHITE,
      ease = "QuadOut"
    })
    self.ScriptedEntityTweener:Play(self.Properties.ButtonSelected, animDuration, {opacity = 1, ease = "QuadOut"})
    self.ScriptedEntityTweener:Play(self.Properties.ButtonFocus, animDuration, {opacity = 0, ease = "QuadOut"})
  else
    self.selected = false
    if self.enabled then
      self.ScriptedEntityTweener:Play(self.Properties.AmountText, animDuration, {
        textColor = self.UIStyle.COLOR_GRAY_70,
        ease = "QuadOut"
      })
    end
    self.ScriptedEntityTweener:Play(self.Properties.ButtonSelected, animDuration, {opacity = 0, ease = "QuadOut"})
  end
end
function ResourceSelectionButton:SetSelectedByValue(value)
  self:SetSelected(self.enabled and value == self.value)
end
function ResourceSelectionButton:SetEnabled(enable)
  self.enabled = enable
  if self.enabled then
    UiTextBus.Event.SetColor(self.Properties.AmountText, self.UIStyle.COLOR_GRAY_70)
    self.Tooltip:SetSimpleTooltip("")
  else
    UiTextBus.Event.SetColor(self.Properties.AmountText, self.UIStyle.COLOR_RED_DARK)
  end
end
function ResourceSelectionButton:SetSimpleTooltip(value)
  self.Tooltip:SetSimpleTooltip(value)
end
function ResourceSelectionButton:SetPrimaryText(text)
  UiTextBus.Event.SetTextWithFlags(self.Properties.AmountText, text, eUiTextSet_SetLocalized)
end
function ResourceSelectionButton:OnFocus()
  if self.enabled then
    if not self.timeline then
      self.timeline = self.ScriptedEntityTweener:TimelineCreate()
      self.timeline:Add(self.Properties.ButtonFocus, self.UIStyle.DURATION_TIMELINE_FADE_OUT, {opacity = 0.5})
      self.timeline:Add(self.Properties.ButtonFocus, self.UIStyle.DURATION_TIMELINE_FADE_IN, {opacity = 1})
      self.timeline:Add(self.Properties.ButtonFocus, self.UIStyle.DURATION_TIMELINE_HOLD, {
        opacity = 1,
        onComplete = function()
          self.timeline:Play()
        end
      })
    end
    self.ScriptedEntityTweener:Play(self.Properties.ButtonFocus, self.UIStyle.DURATION_BUTTON_FADE_IN, {opacity = 1, ease = "QuadOut"})
    self.ScriptedEntityTweener:Play(self.Properties.ButtonFocus, self.UIStyle.DURATION_BUTTON_FADE_IN_HOLD, {
      opacity = 1,
      delay = self.UIStyle.DURATION_BUTTON_FADE_IN,
      onComplete = function()
        self.timeline:Play()
      end
    })
    self.ScriptedEntityTweener:Play(self.Properties.AmountText, self.UIStyle.DURATION_BUTTON_FADE_IN, {
      textColor = self.UIStyle.COLOR_WHITE,
      ease = "QuadOut"
    })
    self.audioHelper:PlaySound(self.audioHelper.Crafting_Item_Hover)
  else
    self.Tooltip:OnTooltipSetterHoverStart()
  end
end
function ResourceSelectionButton:OnUnfocus()
  if self.enabled then
    local animDuration = 0.3
    if not self.selected then
      self.ScriptedEntityTweener:Play(self.Properties.AmountText, animDuration, {
        textColor = self.UIStyle.COLOR_GRAY_70,
        ease = "QuadOut"
      })
    end
    self.ScriptedEntityTweener:Play(self.Properties.ButtonFocus, animDuration, {opacity = 0, ease = "QuadOut"})
  else
    self.Tooltip:OnTooltipSetterHoverEnd()
  end
end
function ResourceSelectionButton:SetCallback(callback, callingTable, returnData)
  self.callbackFunction = callback
  self.callbackTable = callingTable
  self.value = returnData
end
function ResourceSelectionButton:OnPress(entityId)
  if not self.enabled then
    return
  end
  local animDuration = 0.15
  self.ScriptedEntityTweener:Play(self.Properties.ButtonFocus, animDuration, {opacity = 0, ease = "QuadOut"})
  if self.callbackFunction ~= nil and self.callbackTable ~= nil and type(self.callbackFunction) == "function" then
    self.callbackFunction(self.callbackTable, self.entityId, self.value)
  end
  self.audioHelper:PlaySound(self.audioHelper.Crafting_Item_Select)
end
function ResourceSelectionButton:OnShutdown()
  if self.timeline ~= nil then
    self.timeline:Stop()
    self.ScriptedEntityTweener:TimelineDestroy(self.timeline)
    self.timeline = nil
  end
end
return ResourceSelectionButton
