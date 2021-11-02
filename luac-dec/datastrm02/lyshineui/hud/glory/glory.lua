local Glory = {
  Properties = {
    GloryBar = {
      default = EntityId()
    },
    GlorySkillEffect = {
      default = EntityId()
    },
    LevelText = {
      default = EntityId()
    },
    SelfRegister = {default = false}
  },
  DataPathObserverHandlerPrefix = "OnObserverUpdate"
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(Glory)
function Glory:OnInit()
  BaseElement.OnInit(self)
  self.enableGloryBar = false
  self.dataLayer:RegisterAndExecuteDataObserver(self, "UIFeatures.g_uiEnableGloryBar", function(self, data)
    self.enableGloryBar = data
    UiElementBus.Event.SetIsEnabled(self.entityId, self.enableGloryBar)
  end)
  self.ScriptedEntityTweener:Set(self.entityId, {opacity = 0})
  self.DataPaths = {
    Level = "Hud.LocalPlayer.Progression.Level",
    AvailablePoints = "Hud.LocalPlayer.Skills.HaveAvailablePoints"
  }
  if self.SelfRegister then
    self:RegisterObservers()
  end
end
function Glory:SetVisible(newVisible, speed, delay)
  speed = speed or 0.35
  delay = delay or 0.35
  if self.isVisible and not newVisible then
    self.ScriptedEntityTweener:Play(self.entityId, speed, {
      opacity = 0,
      delay = delay,
      ease = "QuadOut"
    })
  elseif not self.isVisible and newVisible then
    self.ScriptedEntityTweener:Stop(self.entityId)
    self.ScriptedEntityTweener:Play(self.entityId, speed, {
      opacity = 1,
      delay = delay,
      ease = "QuadOut"
    })
  end
  self.isVisible = newVisible
end
function Glory:OnShutdown()
  self:UnregisterObservers()
end
function Glory:RegisterObservers()
  for pathKey, pathData in pairs(self.DataPaths) do
    local observerHandlerName = self.DataPathObserverHandlerPrefix .. tostring(pathKey)
    if self[observerHandlerName] ~= nil then
      self.dataLayer:RegisterAndExecuteDataObserver(self, pathData, self[observerHandlerName])
    else
      Log("Could not find observer Handler: " .. observerHandlerName)
    end
  end
end
function Glory:UnregisterObservers()
  self.dataLayer:UnregisterObservers(self)
end
function Glory:OnObserverUpdateLevel(data)
  if data == nil then
    return
  end
  self.level = data
  self:UpdateLevel()
end
function Glory:OnObserverUpdateAvailablePoints(haveAvailablePoints)
  if haveAvailablePoints == nil or self.GlorySkillEffect == nil or not self.GlorySkillEffect:IsValid() then
    return
  end
  local animDuration = 0.3
  if haveAvailablePoints then
    UiElementBus.Event.SetIsEnabled(self.Properties.GlorySkillEffect, true)
    self.ScriptedEntityTweener:Play(self.Properties.GlorySkillEffect, animDuration, {opacity = 1, ease = "QuadOut"})
    UiFlipbookAnimationBus.Event.SetCurrentFrame(self.Properties.GlorySkillEffect, 0)
    UiFlipbookAnimationBus.Event.Start(self.Properties.GlorySkillEffect)
  else
    self.ScriptedEntityTweener:Play(self.Properties.GlorySkillEffect, animDuration, {
      opacity = 0,
      ease = "QuadOut",
      onComplete = function()
        UiFlipbookAnimationBus.Event.Stop(self.Properties.GlorySkillEffect)
        UiElementBus.Event.SetIsEnabled(self.Properties.GlorySkillEffect, false)
      end
    })
  end
end
function Glory:UpdateLevel()
  UiTextBus.Event.SetText(self.Properties.LevelText, self.level)
end
return Glory
