local HealingTarget = {
  Properties = {
    HealingTargetLabel = {
      default = EntityId()
    },
    HealingTargetName = {
      default = EntityId()
    },
    Healthbar = {
      default = EntityId()
    },
    HealthbarFill = {
      default = EntityId()
    },
    UnlockHintIcon = {
      default = EntityId()
    },
    UnlockHintText = {
      default = EntityId()
    },
    TargetSelfIcon = {
      default = EntityId()
    },
    TargetSelfText = {
      default = EntityId()
    }
  },
  battleTokenIconPath = "lyshineui/images/HUD/WarHUD/icon_BattleTokens.dds"
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(HealingTarget)
function HealingTarget:OnInit()
  BaseElement.OnInit(self)
  UiElementBus.Event.SetIsEnabled(self.entityId, false)
  SetTextStyle(self.Properties.HealingTargetLabel, self.UIStyle.FONT_STYLE_HEALING_TARGET_LABEL)
  SetTextStyle(self.Properties.HealingTargetName, self.UIStyle.FONT_STYLE_BODY_NEW_WHITE)
  SetTextStyle(self.Properties.UnlockHintText, self.UIStyle.FONT_STYLE_BODY_NEW_WHITE)
  SetTextStyle(self.Properties.TargetSelfText, self.UIStyle.FONT_STYLE_BODY_NEW_WHITE)
  self.UnlockHintIcon:SetKeybindMapping("camera_lock_toggle")
  UiTextBus.Event.SetTextWithFlags(self.Properties.UnlockHintText, "@exit_auto_target_hint", eUiTextSet_SetLocalized)
  self:UpdateHintTextPosition(self.UnlockHintIcon, self.Properties.UnlockHintText)
  self.TargetSelfIcon:SetKeybindMapping("self_target")
  UiTextBus.Event.SetTextWithFlags(self.Properties.TargetSelfText, "@ui_target_self", eUiTextSet_SetLocalized)
  self:UpdateHintTextPosition(self.TargetSelfIcon, self.Properties.TargetSelfText)
  self.dataLayer:RegisterDataCallback(self, "Hud.LocalPlayer.Keybind.camera_lock_toggle.combat", function(self, data)
    self:UpdateHintTextPosition(self.UnlockHintIcon, self.Properties.UnlockHintText)
  end)
  self.dataLayer:RegisterDataCallback(self, "Hud.LocalPlayer.Keybind.self_target.player", function(self, data)
    self:UpdateHintTextPosition(self.TargetSelfIcon, self.Properties.TargetSelfText)
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HealingTarget.Name", function(self, name)
    if not name or #name == 0 then
      UiElementBus.Event.SetIsEnabled(self.entityId, false)
      return
    end
    if self.targetName then
      self.dataLayer:UnregisterObserver(self, "Hud.Marker.HealthBarColor." .. self.targetName)
      self.dataLayer:UnregisterObserver(self, "Hud.Marker.HealingTargetNameColor." .. self.targetName)
    end
    UiElementBus.Event.SetIsEnabled(self.entityId, true)
    self.targetName = name
    self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.Marker.HealthBarColor." .. self.targetName, function(self, color)
      if color then
        UiImageBus.Event.SetColor(self.Properties.HealthbarFill, color)
      end
    end)
    self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.Marker.HealingTargetNameColor." .. self.targetName, function(self, color)
      if color then
        UiTextBus.Event.SetColor(self.Properties.HealingTargetName, color)
      end
    end)
    UiTextBus.Event.SetTextWithFlags(self.Properties.HealingTargetName, name or "", eUiTextSet_SetAsIs)
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HealingTarget.Health", function(self, health)
    if health then
      UiProgressBarBus.Event.SetProgressPercent(self.Properties.Healthbar, health / 100)
    end
  end)
end
function HealingTarget:UpdateHintTextPosition(hintEntity, textEntity)
  local hintWidth = hintEntity:GetWidth()
  local padding = 5
  self.ScriptedEntityTweener:Set(textEntity, {
    x = hintWidth + padding
  })
end
function HealingTarget:OnShutdown()
  self.dataLayer:UnregisterObservers(self)
end
return HealingTarget
