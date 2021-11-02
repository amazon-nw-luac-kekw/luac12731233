local VitalsScreen = {
  Properties = {
    Container = {
      default = EntityId()
    },
    HealthBar = {
      default = EntityId()
    },
    StaminaBar = {
      default = EntityId()
    },
    ManaBar = {
      default = EntityId()
    },
    PaperdollStatus = {
      default = EntityId()
    },
    SelfDamageNumber = {
      default = EntityId()
    },
    AbilityCooldowns = {
      default = EntityId()
    }
  },
  percentEpsilon = 0.005,
  healthPercent = 1,
  staminaPercent = 1,
  lastStaminaPercent = 1,
  manaPercent = 1,
  containerBaseY = -100,
  offsetForChat = 84,
  defaultWidth = 430,
  inventoryWidth = 400,
  threeColumnWidth = 306,
  defaultCooldownsScale = 0.8,
  HEALING_PERCENT_TO_HIDE = 0.05
}
local tweenerCommon = RequireScript("LyShineUI._Common.ScriptedEntityTweenerCommon")
local timingUtils = RequireScript("LyShineUI._Common.TimingUtils")
local BaseScreen = RequireScript("LyShineUI._Common.BaseScreen")
BaseScreen:CreateNewScreen(VitalsScreen)
function VitalsScreen:OnInit()
  BaseScreen.OnInit(self)
  self.screenStates = {
    default = {
      drawOrder = UiCanvasBus.Event.GetDrawOrder(self.canvasId),
      container = {
        x = 0,
        y = 0,
        opacity = 0.9,
        w = self.defaultWidth
      }
    },
    navBar = {
      container = {
        x = 0,
        y = 0,
        opacity = 0.9,
        w = self.defaultWidth
      },
      forceHealthBarOpacity = 1,
      forceStaminaBarOpacity = 1,
      forceManaBarOpacity = 1
    },
    inventory = {
      drawOrder = 34,
      container = {
        x = -243,
        y = 0,
        opacity = 0.9,
        w = self.inventoryWidth
      },
      forceHealthBarOpacity = 1,
      forceStaminaBarOpacity = 1,
      forceManaBarOpacity = 1,
      forcePaperdollStatusOpacity = 0
    },
    threeColumnInventory = {
      drawOrder = 34,
      container = {
        x = -506,
        y = 0,
        opacity = 0.9,
        w = self.threeColumnWidth
      },
      forceHealthBarOpacity = 1,
      forceStaminaBarOpacity = 1,
      forceManaBarOpacity = 1,
      forcePaperdollStatusOpacity = 0,
      cooldownsScale = 0.6
    },
    hidden = {
      drawOrder = 0,
      container = {
        opacity = 0,
        w = self.defaultWidth
      }
    },
    ftueHidden = {
      drawOrder = 0,
      container = {
        opacity = 0,
        w = self.defaultWidth
      }
    },
    ftueHealth = {
      container = {
        opacity = 0.9,
        w = self.defaultWidth
      },
      forceHealthBarOpacity = 1,
      forceStaminaBarOpacity = 0,
      forceManaBarOpacity = 0
    },
    siegeTurret = {
      container = {
        x = 0,
        y = 50,
        opacity = 0.9,
        w = self.defaultWidth
      },
      forceHealthBarOpacity = 1,
      forceStaminaBarOpacity = 0,
      forceManaBarOpacity = 0
    }
  }
  self.screenStateMap = {
    [2972535350] = "inventory",
    [3548394217] = "hidden",
    [2552344588] = "threeColumnInventory",
    [476411249] = "hidden",
    [3349343259] = "inventory",
    [1809891471] = "threeColumnInventory",
    [2230605386] = "hidden",
    [2478623298] = "hidden",
    [3024636726] = "hidden",
    [3766762380] = "navBar",
    [3777009031] = "hidden",
    [1823500652] = "hidden",
    [156281203] = "hidden",
    [3784122317] = "hidden",
    [2609973752] = "hidden",
    [3211015753] = "hidden",
    [640726528] = "hidden",
    [3370453353] = "hidden",
    [2896319374] = "hidden",
    [828869394] = "hidden",
    [2640373987] = "hidden",
    [2437603339] = "hidden",
    [1319313135] = "hidden",
    [1468490675] = "hidden",
    [1101180544] = "hidden",
    [3664731564] = "hidden",
    [4119896358] = "hidden",
    [319051850] = "hidden",
    [4283914359] = "hidden"
  }
  self.screenStatesToDisable = {
    [3901667439] = true,
    [1967160747] = true,
    [3576764016] = true,
    [2477632187] = true,
    [2815678723] = true,
    [3175660710] = true,
    [849925872] = true,
    [663562859] = true,
    [1634988588] = true,
    [921202721] = true,
    [3160088100] = true
  }
  self:SetScreenState("default", true, true)
  local textStyle = {
    fontFamily = self.UIStyle.FONT_FAMILY_NIMBUS_REGULAR,
    fontSize = 18,
    fontColor = self.UIStyle.COLOR_WHITE,
    fontEffect = self.UIStyle.FONT_EFFECT_DROPSHADOW
  }
  self.HealthBar:AddFillColorStop(self.UIStyle.COLOR_RED_DARK, 0)
  self.HealthBar:AddFillColorStop(self.UIStyle.COLOR_WHITE, 1)
  self.HealthBar:AddOpacityStop(0.25, 1)
  self.HealthBar:SetFadeOutDelay(3)
  self.HealthBar:SetWarningThreshold(0.25)
  self.HealthBar:SetWarningSounds(self.audioHelper.Meter_EnterHealthWarning, self.audioHelper.Meter_ExitHealthWarning)
  self.HealthBar:SetCriticalThreshold(0.05)
  self.HealthBar:SetCriticalSounds(self.audioHelper.Meter_EnterHealthCritical, self.audioHelper.Meter_ExitHealthCritical)
  self.HealthBar:SetPulseBus(DynamicBus.VitalsHealthPulse)
  self.HealthBar:SetDepleteAlpha(0.9)
  self.HealthBar:SetTextStyle(textStyle)
  self.StaminaBar:AddFillColorStop(self.UIStyle.COLOR_YELLOW_GOLD, 0)
  self.StaminaBar:AddOpacityStop(0, 1)
  self.StaminaBar:SetFadeOutDelay(1.5)
  self.StaminaBar:SetIcon(nil)
  self.StaminaBar:SetWarningThreshold(0.25)
  self.StaminaBar:SetWarningSounds(self.audioHelper.Meter_EnterStaminaWarning, self.audioHelper.Meter_ExitStaminaWarning)
  self.StaminaBar:SetCriticalThreshold(-1)
  self.StaminaBar:SetCriticalSounds(self.audioHelper.Meter_EnterStaminaCritical, self.audioHelper.Meter_ExitStaminaCritical)
  self.StaminaBar:SetPulseBus(DynamicBus.VitalsStaminaPulse)
  self.StaminaBar:SetDepleteAlpha(0.9)
  self.StaminaBar:SetTextStyle(textStyle)
  self.StaminaBar:SetTextPosition(0, -2)
  self.ManaBar:AddFillColorStop(self.UIStyle.COLOR_BLUE, 0)
  self.ManaBar:AddOpacityStop(0, 1)
  self.ManaBar:SetFadeOutDelay(1.5)
  self.ManaBar:SetIcon(nil)
  self.ManaBar:SetWarningThreshold(0.25)
  self.ManaBar:SetWarningSounds(self.audioHelper.Meter_EnterManaWarning, self.audioHelper.Meter_ExitManaWarning)
  self.ManaBar:SetCriticalThreshold(0.1)
  self.ManaBar:SetCriticalSounds(self.audioHelper.Meter_EnterManaCritical, self.audioHelper.Meter_ExitManaCritical)
  self.ManaBar:SetDepleteAlpha(0.9)
  self.ManaBar:SetTextStyle(textStyle)
  self.ManaBar:SetTextPosition(0, -3)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Options.Video.HudShowAbilityRadials", function(self, showAbilityRadials)
    self.AbilityCooldowns:SetCooldownsEnabled(showAbilityRadials)
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "UIFeatures.g_uiEnableHudSettings", function(self, hudSettingsEnabled)
    self.hudSettingsEnabled = hudSettingsEnabled
    self:UpdateContextualVisibility()
    self.containerBaseY = self.hudSettingsEnabled and -75 or -100
    self.ScriptedEntityTweener:Set(self.Properties.Container, {
      y = self.containerBaseY
    })
    self.screenStates.navBar.container.y = 0
    self.screenStates.inventory.container.y = 0
    if self.currentScreenState then
      self:SetScreenState(self.currentScreenState, true, true)
    end
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Options.Video.UseNewDamageNumbers", function(self, enableNewDamageNumbers)
    self.enableNewDamageNumbers = enableNewDamageNumbers
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.SocialEntityId", function(self, socialEntityId)
    if socialEntityId == nil then
      return
    end
    self.socialEntityId = socialEntityId
    if self.damageNumbersBus then
      self:BusDisconnect(self.damageNumbersBus)
    end
    self.damageNumbersBus = self:BusConnect(DamageNumbersNotificationBus, self.socialEntityId)
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Vitals.HealthPercent", self.OnHealthPercentUpdated)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Vitals.HealthMax", self.OnHealthMaxUpdated)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Vitals.StaminaMax", self.OnStaminaMaxUpdated)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Vitals.ManaPercent", self.OnManaPercentUpdated)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Vitals.ManaMax", self.OnManaMaxUpdated)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Vitals.CurrentManaCost", self.OnManaCostUpdated)
  self.dataLayer:RegisterCallback(self, "Hud.LocalPlayer.OnRevive", self.OnRevive)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Vitals.StaminaLocked", self.SetIsStaminaLocked)
  self:BusConnect(TickBus)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Vitals.ComponentIsActive", function(self, isActive)
    if isActive then
      self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.PlayerEntityId", function(self, staminaEntityId)
        if staminaEntityId then
          self.playerEntityId = staminaEntityId
          self.staminaState = UiStaminaRequestsBus.Event.GetStaminaState(staminaEntityId)
          self:UpdateAll()
        end
      end)
    elseif isActive == false then
      self.staminaState = nil
    end
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Options.Localization.Language", function(self, setLang)
    self.HealthBar:SetTooltip("@ui_vitals_health_tooltip")
    self.StaminaBar:SetTooltip("@ui_vitals_stamina_tooltip")
    self.ManaBar:SetTooltip("@ui_vitals_mana_tooltip")
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.TurretVitalsEntityId", function(self, vitalsEntityId)
    local useSiegeState = vitalsEntityId and vitalsEntityId:IsValid()
    if useSiegeState then
      self:SetScreenState("siegeTurret")
    elseif self.currentScreenState == "siegeTurret" then
      self:SetScreenState("default")
    end
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.VitalsEntityId", function(self, vitalsId)
    if vitalsId then
      if self.uiVitalsNotificationHandler then
        self:BusDisconnect(self.uiVitalsNotificationHandler)
      end
      self.uiVitalsNotificationHandler = self:BusConnect(UiVitalsNotificationsBus, vitalsId)
    end
  end)
  self.dataLayer:RegisterAndExecuteDataCallback(self, "Hud.LocalPlayer.Options.Video.HudAlwaysFade", function(self, hudAlwaysFade)
    if hudAlwaysFade ~= nil then
      self.hudAlwaysFade = hudAlwaysFade
      self:UpdateContextualVisibility()
    end
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.ActiveWeapon.IsSheathed", function(self, isWeaponSheathed)
    self.isWeaponSheathed = isWeaponSheathed
    self:UpdateContextualVisibility()
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.PaperdollEntityId", function(self, paperdollId)
    if paperdollId then
      self.paperdollId = paperdollId
      self:BusConnect(PaperdollEventBus, self.paperdollId)
    end
  end)
  self.dataLayer:RegisterAndExecuteDataCallback(self, "CAGE.OutOfStamina", function(self, outOfStamina)
    if outOfStamina then
      self:OnVitalUseFailed(999083124)
    end
  end)
  self.isFtue = FtueSystemRequestBus.Broadcast.IsFtue()
  if self.isFtue then
    self:SetScreenState("ftueHidden")
    DynamicBus.FtueMessageBus.Connect(self.entityId, self)
  end
  self.tutorialBusHandler = TutorialComponentNotificationsBus.Connect(self, self.canvasId)
  DynamicBus.VitalsBus.Connect(self.entityId, self)
  self:UpdateAll()
end
function VitalsScreen:OnShutdown()
  if self.isFtue then
    DynamicBus.FtueMessageBus.Disconnect(self.entityId, self)
  end
  DynamicBus.VitalsBus.Disconnect(self.entityId, self)
  if self.tutorialBusHandler ~= nil then
    self.tutorialBusHandler:Disconnect()
    self.tutorialBusHandler = nil
  end
  if self.vitalsNotificationHandler then
    self:BusDisconnect(self.vitalsNotificationHandler)
    self.vitalsNotificationHandler = nil
  end
  if self.uiVitalsNotificationHandler then
    self:BusDisconnect(self.uiVitalsNotificationHandler)
    self.uiVitalsNotificationHandler = nil
  end
end
function VitalsScreen:OnTransitionIn(fromState, fromLevel, toState, toLevel)
  if self.isFtue and self.currentScreenState == "ftueHidden" then
    return
  end
  if self.screenStatesToDisable[toState] then
    UiElementBus.Event.SetIsEnabled(self.Properties.Container, false)
    return
  end
  local stateName = self.screenStateMap[toState] or "default"
  self:SetScreenState(stateName)
end
function VitalsScreen:OnTransitionOut(fromState, fromLevel, toState, toLevel)
  LyShineManagerBus.Broadcast.TransitionOutComplete()
  if self.isFtue and self.currentScreenState == "ftueHidden" then
    return
  end
  if self.screenStatesToDisable[fromState] and not self.screenStatesToDisable[toState] then
    UiElementBus.Event.SetIsEnabled(self.Properties.Container, true)
  end
  local stateName = self.screenStateMap[toState] or "default"
  self:SetScreenState(stateName)
end
function VitalsScreen:SetScreenState(screenStateName, skipAnimation, force)
  if not force and (screenStateName == self.currentScreenState or self.screenStates[screenStateName] == nil) then
    return
  end
  local isContainerOpen = LyShineManagerBus.Broadcast.IsInState(3349343259)
  local isLootDrop = isContainerOpen and self.dataLayer:GetDataFromNode("Hud.LocalPlayer.ActiveContainerIsLootDrop")
  if isContainerOpen and not isLootDrop then
    screenStateName = "threeColumnInventory"
  end
  local screenState = self.screenStates[screenStateName]
  local animTime = skipAnimation and 0 or 0.3
  local cooldownsScale = screenState.cooldownsScale or self.defaultCooldownsScale
  local containerY = screenState.container.y ~= nil and screenState.container.y + self.containerBaseY or self.containerBaseY
  self.ScriptedEntityTweener:Play(self.Properties.Container, animTime, {
    x = screenState.container.x,
    y = containerY,
    opacity = screenState.container.opacity,
    w = screenState.container.w,
    ease = "QuadOut"
  })
  self.HealthBar:SetForceOpacity(screenState.forceHealthBarOpacity, animTime)
  self.StaminaBar:SetForceOpacity(screenState.forceStaminaBarOpacity, animTime)
  self.ManaBar:SetForceOpacity(screenState.forceManaBarOpacity, animTime)
  self.PaperdollStatus:SetForceOpacity(screenState.forcePaperdollStatusOpacity, animTime)
  self.ScriptedEntityTweener:Play(self.Properties.AbilityCooldowns, animTime, {
    scaleX = cooldownsScale,
    scaleY = cooldownsScale,
    ease = "QuadOut"
  })
  local drawOrder = screenState.drawOrder ~= nil and screenState.drawOrder or self.screenStates.default.drawOrder
  UiCanvasBus.Event.SetDrawOrder(self.canvasId, drawOrder)
  for _, bar in pairs({
    self.HealthBar,
    self.StaminaBar,
    self.ManaBar
  }) do
    bar:SetIsTooltipEnabled(screenState.container.opacity ~= 0)
  end
  self.currentScreenState = screenStateName
end
function VitalsScreen:UpdateAll()
  self.healthPercent = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Vitals.HealthPercent")
  self:UpdateHealth(true)
  if self.staminaState then
    self.staminaPercent = self.staminaState:GetStaminaPercent()
    self:UpdateStamina(true)
  end
  self.manaPercent = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Vitals.ManaPercent")
  self:UpdateMana(true)
  self:UpdateContextualVisibility()
end
function VitalsScreen:OnHealthPercentUpdated(data)
  if self:ShouldUpdatePercent(self.healthPercent, data, 0) then
    self.healthPercent = data
    self:UpdateHealth()
    if self.healthPercent == 1 then
      self.audioHelper:PlaySound(self.audioHelper.Meter_FullHealth)
    end
    self:UpdateContextualVisibility()
  end
end
function VitalsScreen:SetVisible(visible)
  local screenStateName = self.currentScreenState or "default"
  local screenState = self.screenStates[screenStateName]
  screenState = screenState or self.screenStates.default
  local opacity = visible and screenState.container.opacity or 0
  self.ScriptedEntityTweener:Play(self.Properties.Container, 0.2, {opacity = opacity, ease = "QuadOut"})
end
function VitalsScreen:OnHealthMaxUpdated(data)
  if data ~= nil then
    self.maxHealth = data
    self.HealthBar:SetMaxValue(data)
  end
end
function VitalsScreen:UpdateHealth(force)
  if self.healthPercent == nil or not IsUsableNumber(self.healthPercent) then
    return
  end
  if self.isFtue and self.healthPercent < 0.8 and self.currentScreenState == "ftueHidden" then
    self:SetScreenState("ftueHealth")
  end
  self.HealthBar:SetPercentage(Math.Clamp(self.healthPercent, 0, 1), force, force)
end
function VitalsScreen:OnStaminaMaxUpdated(data)
  if data ~= nil then
    self.StaminaBar:SetMaxValue(data)
  end
end
function VitalsScreen:UpdateStamina(force)
  if not (self.staminaPercent ~= nil and IsUsableNumber(self.staminaPercent)) or self.lastStaminaPercent == nil then
    return
  end
  local isReplenishing = self.staminaPercent < 1 and self.staminaPercent > self.lastStaminaPercent and self.staminaPercent > 0
  self.StaminaBar:SetPercentage(Math.Clamp(self.staminaPercent, 0, 1), force or isReplenishing, force)
  if self.staminaPercent == 1 then
    self.audioHelper:PlaySound(self.audioHelper.Meter_FullStamina)
  end
end
function VitalsScreen:SetIsStaminaLocked(isStaminaLocked)
  if isStaminaLocked then
    self.StaminaBar:AddFillColorStop(self.UIStyle.COLOR_TAN_MEDIUM, 0)
    self.audioHelper:PlaySound(self.audioHelper.Meter_StaminaLocked)
  else
    self.StaminaBar:AddFillColorStop(self.UIStyle.COLOR_YELLOW_GOLD, 0)
    self.audioHelper:PlaySound(self.audioHelper.Meter_StaminaUnlocked)
  end
end
function VitalsScreen:OnManaMaxUpdated(data)
  self.manaMax = data
  self.ManaBar:SetMaxValue(self.manaMax)
end
function VitalsScreen:OnVitalUseFailed(vitalName)
  if vitalName == 1624655410 then
    self.ManaBar:OnInsufficientVitals()
  elseif vitalName == 999083124 then
    self.StaminaBar:OnInsufficientVitals()
  end
end
function VitalsScreen:OnManaCostUpdated(data)
  if not IsUsableNumber(data) then
    return
  end
  self.manaCurrentSpellCost = data
  if self.manaMax ~= nil and self.manaMax > 0 then
    local costPercentage = math.max(self.manaCurrentSpellCost / self.manaMax, 0)
    local manaOpacity = 0
    if 0 < costPercentage then
      manaOpacity = 1
    else
      manaOpacity = self.screenStates[self.currentScreenState] and self.screenStates[self.currentScreenState].forceManaBarOpacity or nil
    end
    self.ManaBar:SetForceOpacity(manaOpacity)
    self.ManaBar:SetCostPercentage(costPercentage)
  end
end
function VitalsScreen:OnManaPercentUpdated(data)
  if self:ShouldUpdatePercent(self.manaPercent, data) then
    self.manaPercent = data
    self:UpdateMana()
    self:UpdateContextualVisibility()
  end
end
function VitalsScreen:UpdateMana(force)
  if self.manaPercent == nil or not IsUsableNumber(self.manaPercent) then
    return
  end
  self.ManaBar:SetPercentage(Math.Clamp(self.manaPercent, 0, 1), force, force)
  if self.manaPercent == 1 then
    self.audioHelper:PlaySound(self.audioHelper.Meter_FullMana)
  end
end
function VitalsScreen:ShouldUpdatePercent(oldValue, newValue, percentEpsilon)
  return newValue ~= nil and (not Math.IsClose(oldValue, newValue, percentEpsilon and percentEpsilon or self.percentEpsilon) or newValue <= 0 and 0 < oldValue or 1 <= newValue and oldValue < 1)
end
function VitalsScreen:OnTutorialRevealUIElement(elementName)
  if elementName == "Health" then
    self:SetScreenState("default")
  elseif elementName == "Stamina" then
  end
end
function VitalsScreen:OnTutorialStopHighlightingUIElement(elementName)
  self:UpdateAll()
end
function VitalsScreen:OnTick(deltaTime, timePoint)
  local isInSpectatorMode = SpectatorUIRequestBus.Broadcast.IsInSpectatorMode()
  local currentStaminaPercent = 0
  if isInSpectatorMode then
    currentStaminaPercent = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Vitals.StaminaPercent")
  elseif self.staminaState then
    currentStaminaPercent = self.staminaState:GetStaminaPercent()
  end
  if currentStaminaPercent ~= nil and (currentStaminaPercent > self.staminaPercent or self:ShouldUpdatePercent(self.staminaPercent, currentStaminaPercent)) then
    self.lastStaminaPercent = self.staminaPercent
    self.staminaPercent = currentStaminaPercent
    self:UpdateStamina()
    self:UpdateContextualVisibility()
  end
  self.lastTimePoint = timePoint
end
function VitalsScreen:SetElementVisibleForFtue(isVisible)
  if isVisible then
    self.ScriptedEntityTweener:PlayC(self.entityId, self.UIStyle.DURATION_FTUE_OUTRO, tweenerCommon.fadeInQuadOut)
  else
    self.ScriptedEntityTweener:PlayC(self.entityId, self.UIStyle.DURATION_FTUE_OUTRO, tweenerCommon.fadeOutQuadOut)
  end
end
function VitalsScreen:OnRevive()
  if not self.reviveNotification then
    local notificationData = NotificationData()
    notificationData.type = "Revive"
    notificationData.hasChoice = true
    notificationData.contextId = self.entityId
    notificationData.callbackName = "OnReviveChoice"
    notificationData.title = "@ui_resurrect"
    notificationData.maximumDuration = 120
    notificationData.showProgress = true
    notificationData.declineOnTimeout = true
    self.reviveNotification = UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
    local rootEntityId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.GDERootEntityId")
    self.vitalsNotificationHandler = self:BusConnect(VitalsComponentNotificationBus, rootEntityId)
  end
end
function VitalsScreen:OnReviveChoice(notificationId, isAccepted)
  local isInDeathsDoor = VitalsComponentRequestBus.Event.IsDeathsDoor(self.playerEntityId)
  local isDead = VitalsComponentRequestBus.Event.IsDead(rootEntityId)
  if isInDeathsDoor and not isDead then
    if isAccepted then
      UiVitalsRequestsBus.Event.OnRequestReviveAccepted(self.playerEntityId)
    else
      UiVitalsRequestsBus.Event.OnRequestReviveDeclined(self.playerEntityId)
    end
    self.reviveNotification = nil
    self:RescindReviveNotification()
  end
end
function VitalsScreen:RescindReviveNotification()
  if self.reviveNotification then
    UiNotificationsBus.Broadcast.RescindNotification(self.reviveNotification, true, true)
    self.reviveNotification = nil
  end
  if self.vitalsNotificationHandler then
    self:BusDisconnect(self.vitalsNotificationHandler)
    self.vitalsNotificationHandler = nil
  end
end
function VitalsScreen:OnDeathsDoorChanged(isInDeathsDoor, timeRemaining, deathsDoorCooldownRemaining)
  local rootEntityId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.GDERootEntityId")
  local isDead = VitalsComponentRequestBus.Event.IsDead(rootEntityId)
  if not isDead then
    self:RescindReviveNotification()
  elseif not isInDeathsDoor then
    self:RescindReviveNotification()
  end
end
function VitalsScreen:UpdateContextualVisibility()
  if self.hudSettingsEnabled then
    local containerOpacity = 0.9
    if self.hudAlwaysFade and self.isWeaponSheathed and self.staminaPercent > 0.99 and 0.99 < self.healthPercent and 0.99 < self.manaPercent then
      containerOpacity = 0
    end
    if self.screenStates.default.container.opacity ~= containerOpacity then
      self.screenStates.default.container.opacity = containerOpacity
      if not self.currentScreenState then
        self.currentScreenState = "default"
      end
      timingUtils:StopDelay(self)
      timingUtils:Delay(0.4, self, function()
        self:SetScreenState(self.currentScreenState, false, true)
      end)
    end
  end
end
function VitalsScreen:OnHealthChangedUi(vitalsStatChanged)
  if not self.hudSettingsEnabled then
    return
  end
  local prevValue = vitalsStatChanged.lastValue
  local newValue = vitalsStatChanged.newVitalsStat.value
  local prevMaxValue = vitalsStatChanged.lastMaxValue
  local newMaxValue = vitalsStatChanged.newVitalsStat.maxValue
  local tookDamage = prevValue ~= newValue and prevMaxValue == newMaxValue
  if tookDamage then
    local damageAmount = prevValue - newValue
    if damageAmount <= 0 then
      local healthPercentChange = math.abs(damageAmount) / newMaxValue
      if healthPercentChange < self.HEALING_PERCENT_TO_HIDE then
        return
      end
    end
    if damageAmount < 0 then
      if not self.enableNewDamageNumbers then
        self.SelfDamageNumber:OnDamageDisplayed(true, "Standard", damageAmount, 0, 0, false)
      else
        DamageNumbersBus.Broadcast.DisplayLocalPlayerNumber(self.socialEntityId, eXpEventType_PlayerDamage, math.floor(damageAmount), 0)
      end
    end
  end
end
function VitalsScreen:OnCombinedDamageDisplayed(damageByType, isCrit, distanceFromLocalPlayerSq, numAlreadyDisplaying, isLocalPlayer, absorption)
  if not self.enableNewDamageNumbers then
    self.SelfDamageNumber:OnCombinedDamageDisplayed(damageByType, isCrit, distanceFromLocalPlayerSq, numAlreadyDisplaying, isLocalPlayer, absorption)
  end
end
function VitalsScreen:OnPaperdollSlotUpdate(localSlotId, slot)
  local activeWeaponSlotId = PaperdollRequestBus.Event.GetActiveSlot(self.paperdollId, ePaperdollSlotAlias_ActiveWeapon)
  local isActiveSlot = localSlotId == activeWeaponSlotId
  if isActiveSlot then
    self.AbilityCooldowns:SetAbilitiesForItem(localSlotId, slot)
    self.AbilityCooldowns:UpdateAbilityTimers()
  end
end
return VitalsScreen
