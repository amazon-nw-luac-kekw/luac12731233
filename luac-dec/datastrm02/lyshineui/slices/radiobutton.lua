local RadioButton = {
  Properties = {
    Background = {
      default = EntityId()
    },
    Highlight = {
      default = EntityId()
    },
    Dot = {
      default = EntityId()
    }
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(RadioButton)
function RadioButton:OnInit()
  self.groupEntityId = UiRadioButtonBus.Event.GetGroup(self.entityId)
  self.isChecked = UiRadioButtonBus.Event.GetState(self.entityId)
end
function RadioButton:OnShutdown()
  if self.timeline then
    self.ScriptedEntityTweener:TimelineDestroy(self.timeline)
  end
end
function RadioButton:AddToGroup(groupEntityId)
  if groupEntityId then
    UiRadioButtonGroupBus.Event.AddRadioButton(groupEntityId, self.entityId)
    self.groupEntityId = groupEntityId
    self.isChecked = UiRadioButtonGroupBus.Event.GetState(groupEntityId) == self.entityId
  end
end
function RadioButton:SetIsChecked(isChecked)
  if self.groupEntityId then
    UiRadioButtonGroupBus.Event.SetState(self.groupEntityId, self.entityId, isChecked)
  end
end
function RadioButton:GetIsChecked()
  return self.isChecked
end
function RadioButton:OnChange(checkedButtonId)
  self.isChecked = UiRadioButtonBus.Event.GetState(self.entityId)
  if self.isChecked then
    self.audioHelper:PlaySound(self.audioHelper.Accept)
  end
end
function RadioButton:OnHoverStart()
  self.ScriptedEntityTweener:Play(self.Properties.Background, self.UIStyle.DURATION_BUTTON_FADE_IN, {opacity = 1, ease = "QuadOut"})
  if self.isChecked then
    return
  end
  if not self.timeline then
    self.timeline = self.ScriptedEntityTweener:TimelineCreate()
    self.timeline:Add(self.Properties.Highlight, self.UIStyle.DURATION_TIMELINE_FADE_OUT, {opacity = 0.2})
    self.timeline:Add(self.Properties.Highlight, self.UIStyle.DURATION_TIMELINE_FADE_IN, {opacity = 0.4})
    self.timeline:Add(self.Properties.Highlight, self.UIStyle.DURATION_TIMELINE_HOLD, {
      opacity = 0.4,
      onComplete = function()
        self.timeline:Play()
      end
    })
  end
  self.ScriptedEntityTweener:Play(self.Properties.Highlight, self.UIStyle.DURATION_BUTTON_FADE_IN, {opacity = 0.4, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.Properties.Highlight, self.UIStyle.DURATION_BUTTON_FADE_IN_HOLD, {
    opacity = 0.4,
    delay = self.UIStyle.DURATION_BUTTON_FADE_IN,
    onComplete = function()
      self.timeline:Play()
    end
  })
  self.audioHelper:PlaySound(self.audioHelper.OnHover_ButtonSimpleText)
end
function RadioButton:OnHoverEnd()
  self.ScriptedEntityTweener:Play(self.Properties.Background, self.UIStyle.DURATION_BUTTON_FADE_OUT, {opacity = 0.6, ease = "QuadOut"})
  if self.timeline then
    self.timeline:Stop()
  end
  self.ScriptedEntityTweener:Play(self.Properties.Highlight, self.UIStyle.DURATION_BUTTON_FADE_OUT, {opacity = 0, ease = "QuadOut"})
end
return RadioButton
