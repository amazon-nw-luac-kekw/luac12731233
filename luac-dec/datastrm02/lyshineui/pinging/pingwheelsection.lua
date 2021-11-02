local PingWheelSection = {
  Properties = {
    Icon = {
      default = EntityId()
    },
    IconPulse = {
      default = EntityId()
    },
    Focus = {
      default = EntityId()
    }
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(PingWheelSection)
function PingWheelSection:OnInit()
end
function PingWheelSection:OnSectionFocus()
  self.ScriptedEntityTweener:Play(self.Properties.Focus, 0.3, {opacity = 1, ease = "QuadOut"})
  self.ScriptedEntityTweener:Stop(self.Properties.IconPulse)
  self.ScriptedEntityTweener:Set(self.Properties.IconPulse, {
    opacity = 0.8,
    scaleY = 1,
    scaleX = 1
  })
  if not self.timelinePulse then
    self.timelinePulse = self.ScriptedEntityTweener:TimelineCreate()
    self.timelinePulse:Add(self.Properties.IconPulse, 0.8, {
      opacity = 0,
      scaleY = 1.8,
      scaleX = 1.8
    })
    self.timelinePulse:Add(self.Properties.IconPulse, 0.5, {opacity = 0})
    self.timelinePulse:Add(self.Properties.IconPulse, 0.01, {
      opacity = 1,
      scaleY = 1,
      scaleX = 1,
      onComplete = function()
        self.timelinePulse:Play()
      end
    })
  end
  self.timelinePulse:Play()
  self.audioHelper:PlaySound(self.audioHelper.Ping_Wheel_OnHover)
end
function PingWheelSection:OnSectionUnfocus()
  self.ScriptedEntityTweener:Play(self.Properties.Focus, 0.2, {opacity = 0, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.Properties.IconPulse, 0.1, {opacity = 0, ease = "QuadOut"})
  if self.timelinePulse then
    self.timelinePulse:Stop()
  end
end
function PingWheelSection:SetSectionData(sectionData)
  self.pingType = sectionData.pingType
  self.selectionText = sectionData.text
  self.pingIconPath = sectionData.iconPath
  self.pingColor = sectionData.color
  UiImageBus.Event.SetColor(self.Properties.IconPulse, sectionData.color)
  UiImageBus.Event.SetSpritePathname(self.Properties.Icon, sectionData.iconPath)
end
function PingWheelSection:GetSelectionText()
  return self.selectionText
end
function PingWheelSection:GetPingType()
  return self.pingType
end
function PingWheelSection:GetPingColor()
  return self.pingColor
end
function PingWheelSection:GetPingIconPath()
  return self.pingIconPath
end
function PingWheelSection:OnShutdown()
  if self.timelinePulse then
    self.timelinePulse:Stop()
    self.ScriptedEntityTweener:TimelineDestroy(self.timelinePulse)
  end
end
return PingWheelSection
