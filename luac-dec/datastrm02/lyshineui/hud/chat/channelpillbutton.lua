local ChannelPillButton = {
  Properties = {
    Highlight = {
      default = EntityId()
    },
    ChannelPill = {
      default = EntityId()
    }
  },
  channelData = nil
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(ChannelPillButton)
function ChannelPillButton:OnInit()
  if type(self.ChannelPill) == "table" and self.ChannelPill.SetLockedOpen then
    self.ChannelPill:SetLockedOpen(true)
  end
end
function ChannelPillButton:OnShutdown()
  if self.highlightTimeline then
    self.ScriptedEntityTweener:TimelineDestroy(self.highlightTimeline)
  end
end
function ChannelPillButton:SetChannelData(channelData)
  self.ChannelPill:SetChannelData(channelData)
  self.channelData = channelData
end
function ChannelPillButton:GetChannelData()
  return self.channelData
end
function ChannelPillButton:GetChannelName()
  if self.channelData and self.channelData.name then
    return self.channelData.name
  end
  return nil
end
function ChannelPillButton:SetCallback(command, table)
  self.callback = command
  self.callbackTable = table
end
function ChannelPillButton:SetCanInteract(canInteract)
  local opacity = canInteract and 1 or 0.5
  UiFaderBus.Event.SetFadeValue(self.entityId, opacity)
  UiInteractableBus.Event.SetIsHandlingEvents(self.entityId, canInteract)
end
function ChannelPillButton:OnHover()
  if not self.highlightTimeline then
    self.highlightTimeline = self.ScriptedEntityTweener:TimelineCreate()
    self.highlightTimeline:Add(self.Properties.Highlight, self.UIStyle.DURATION_TIMELINE_FADE_OUT, {opacity = 0.1})
    self.highlightTimeline:Add(self.Properties.Highlight, self.UIStyle.DURATION_TIMELINE_FADE_IN, {opacity = 0.17})
    self.highlightTimeline:Add(self.Properties.Highlight, self.UIStyle.DURATION_TIMELINE_HOLD, {
      opacity = 0.17,
      onComplete = function()
        self.highlightTimeline:Play()
      end
    })
  end
  self.ScriptedEntityTweener:Play(self.Properties.Highlight, self.UIStyle.DURATION_BUTTON_FADE_IN, {opacity = 0.17, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.Properties.Highlight, self.UIStyle.DURATION_BUTTON_FADE_IN_HOLD, {
    opacity = 0.17,
    delay = self.UIStyle.DURATION_BUTTON_FADE_IN,
    onComplete = function()
      self.highlightTimeline:Play()
    end
  })
  self.audioHelper:PlaySound(self.audioHelper.OnHover_ButtonSimpleText)
end
function ChannelPillButton:OnUnhover()
  self.highlightTimeline:Stop()
  self.ScriptedEntityTweener:Play(self.Properties.Highlight, 0.1, {opacity = 0})
end
function ChannelPillButton:OnClick()
  if self.callbackTable and type(self.callback) == "function" then
    self.callback(self.callbackTable, self.channelData)
  end
  self.audioHelper:PlaySound(self.audioHelper.Accept)
end
function ChannelPillButton:GetWidth()
  if not self.pillOffset then
    self.pillOffset = UiTransformBus.Event.GetLocalPositionX(self.Properties.ChannelPill)
  end
  return self.ChannelPill:GetWidth() + self.pillOffset
end
return ChannelPillButton
