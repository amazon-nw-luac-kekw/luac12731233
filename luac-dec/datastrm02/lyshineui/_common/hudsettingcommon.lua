local HudSettingCommon = {
  entitiesToFadeOnSprint = {}
}
local tweenerCommon = RequireScript("LyShineUI._Common.ScriptedEntityTweenerCommon")
function HudSettingCommon:OnActivate()
  self.dataLayer = RequireScript("LyShineUI.UiDataLayer")
  self.ScriptedEntityTweener = RequireScript("Scripts.ScriptedEntityTweener.ScriptedEntityTweener")
  self.dataLayer:RegisterAndExecuteDataObserver(self, "UIFeatures.g_uiEnableHudSettings", function(self, hudSettingsEnabled)
    self.hudSettingsEnabled = hudSettingsEnabled
  end)
  self.dataLayer:RegisterAndExecuteDataCallback(self, "Hud.LocalPlayer.Options.Video.HudAlwaysFade", function(self, hudAlwaysFade)
    if hudAlwaysFade ~= nil then
      self.hudAlwaysFade = hudAlwaysFade
    end
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Cage.IsSprinting", function(self, isSprinting)
    if isSprinting ~= nil and self.hudSettingsEnabled then
      local fadeHud = self.hudAlwaysFade and isSprinting
      if self.lastFadeHudState ~= fadeHud then
        self.lastFadeHudState = fadeHud
        for _, entityId in ipairs(self.entitiesToFadeOnSprint) do
          if fadeHud then
            self.ScriptedEntityTweener:Stop(entityId)
            self.ScriptedEntityTweener:Play(entityId, 0.25, {opacity = 0.3, delay = 2})
          else
            self.ScriptedEntityTweener:Stop(entityId)
            self.ScriptedEntityTweener:PlayC(entityId, 0.25, tweenerCommon.fadeInQuadOut)
          end
        end
      end
    end
  end)
end
function HudSettingCommon:Reset()
  ClearTable(self.entitiesToFadeOnSprint)
end
function HudSettingCommon:RegisterEntityToFadeOnSprint(entityId)
  table.insert(self.entitiesToFadeOnSprint, entityId)
end
return HudSettingCommon
