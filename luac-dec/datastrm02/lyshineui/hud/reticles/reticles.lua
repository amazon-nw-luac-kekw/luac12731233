local ReticlesScreen = {
  Properties = {
    BowReticle = {
      default = EntityId()
    },
    BowReticleParts = {
      Top = {
        default = EntityId()
      },
      Bottom = {
        default = EntityId()
      },
      Left = {
        default = EntityId()
      },
      Right = {
        default = EntityId()
      },
      Center = {
        default = EntityId()
      }
    },
    ObstructedReticle = {
      default = EntityId()
    },
    MeleeReticle = {
      default = EntityId()
    },
    PistolReticle = {
      default = EntityId()
    },
    PistolReticleParts = {
      Ring = {
        default = EntityId()
      },
      Left = {
        default = EntityId()
      },
      Right = {
        default = EntityId()
      },
      Center = {
        default = EntityId()
      }
    },
    RifleReticle = {
      default = EntityId()
    },
    RifleReticleParts = {
      Bottom = {
        default = EntityId()
      },
      Left = {
        default = EntityId()
      },
      Right = {
        default = EntityId()
      },
      Center = {
        default = EntityId()
      }
    },
    SpearReticle = {
      default = EntityId()
    },
    SpearReticleParts = {
      Center = {
        default = EntityId()
      },
      Left = {
        default = EntityId()
      },
      Right = {
        default = EntityId()
      }
    },
    SiegeReticle = {
      default = EntityId()
    },
    SiegeReticleParts = {
      Ballista = {
        Frame = {
          default = EntityId(),
          order = 1
        },
        Center = {
          default = EntityId(),
          order = 2
        },
        Left = {
          default = EntityId(),
          order = 3
        },
        Right = {
          default = EntityId(),
          order = 4
        }
      },
      Repeater = {
        Frame = {
          default = EntityId(),
          order = 1
        },
        Center = {
          default = EntityId(),
          order = 2
        },
        Left = {
          default = EntityId(),
          order = 3
        },
        Right = {
          default = EntityId(),
          order = 4
        },
        Ring = {
          default = EntityId(),
          order = 5
        }
      },
      Explosive = {
        Frame = {
          default = EntityId(),
          order = 1
        },
        Center = {
          default = EntityId(),
          order = 2
        },
        Left = {
          default = EntityId(),
          order = 3
        },
        Right = {
          default = EntityId(),
          order = 4
        }
      },
      PromptBG = {
        default = EntityId()
      },
      HealthMeterIcon = {
        default = EntityId()
      },
      HealthMeter = {
        default = EntityId()
      },
      HeatMeter = {
        default = EntityId()
      },
      HeatMeterElements = {
        HeatMeterBg = {
          default = EntityId()
        },
        HeatMeterFill = {
          default = EntityId()
        },
        HeatMeterFillWarning = {
          default = EntityId()
        },
        HeatMeterFillGlow = {
          default = EntityId()
        },
        HeatMeterMessage = {
          default = EntityId()
        },
        HeatMeterMessageBg = {
          default = EntityId()
        }
      },
      ExitPrompt = {
        default = EntityId()
      }
    },
    ReticleAmmo = {
      default = EntityId()
    },
    ReticleAmmoText = {
      default = EntityId()
    },
    ReticleAmmoIcon = {
      default = EntityId()
    },
    ReticleAmmoMessage = {
      default = EntityId()
    },
    ReticleAmmoMessageBg = {
      default = EntityId()
    },
    ReloadAnim = {
      default = EntityId()
    },
    HitConfirm = {
      default = EntityId()
    },
    TimeToFadeHitConfirm = {default = 0.4}
  },
  reticleToShow = nil,
  hitConfirmTime = 0,
  isPlayingAmmoMessage = false,
  isInLowAmmoState = true,
  infiniteAmmo = 0,
  INFINITE_AMMO_GAMEMODE = 1,
  INFINITE_AMMO_TURRET = 2,
  bulletAmmo = 0,
  arrowAmmo = 0,
  ammoInitPosX = 24,
  siegeAmmo = 0,
  promptVisible = false,
  isUsingHeat = false,
  forceHideReticle = false,
  fireCooldownPct = 1,
  lowAmmo = 6,
  inAccuracyTickInterval = 1,
  inAccuracyTickVal = 0,
  heatWarningThreshold = 0.6,
  maxAimTargetDistance = 150,
  framesSinceLastAimUpdate = 0,
  framesBetweenAimUpdates = 20,
  iconPathArrows = "lyshineui/images/hud/reticles/iconarrows.dds",
  iconPathCartridges = "lyshineui/images/hud/reticles/iconcartridges.dds",
  ammoFlashDuration = 0.3,
  defaultInaccuracyDuration = 0.1,
  defaultFov = 0.87266457,
  isDead = false,
  isInDeathsDoor = false,
  isVisibleForFtue = true
}
local tweenerCommon = RequireScript("LyShineUI._Common.ScriptedEntityTweenerCommon")
local BitwiseHelper = RequireScript("LyShineUI._Common.BitwiseHelpers")
local BaseScreen = RequireScript("LyShineUI._Common.BaseScreen")
BaseScreen:CreateNewScreen(ReticlesScreen)
function ReticlesScreen:OnInit()
  BaseScreen.OnInit(self)
  if not self.Properties.BowReticle:IsValid() then
    Debug.Log("ReticlesScreen: Lua property BowReticle is not set")
  end
  if not self.Properties.MeleeReticle:IsValid() then
    Debug.Log("ReticlesScreen: Lua property MeleeReticle is not set")
  end
  if not self.Properties.PistolReticle:IsValid() then
    Debug.Log("ReticlesScreen: Lua property PistolReticle is not set")
  end
  if not self.Properties.RifleReticle:IsValid() then
    Debug.Log("ReticlesScreen: Lua property RifleReticle is not set")
  end
  if not self.Properties.SpearReticle:IsValid() then
    Debug.Log("ReticlesScreen: Lua property SpearReticle is not set")
  end
  if not self.Properties.SiegeReticle:IsValid() then
    Debug.Log("ReticlesScreen: Lua property SiegeReticle is not set")
  end
  if not self.Properties.ReticleAmmo:IsValid() then
    Debug.Log("ReticlesScreen: Lua property ReticleAmmo is not set")
  end
  if not self.Properties.ReloadAnim:IsValid() then
    Debug.Log("ReticlesScreen: Lua property ReloadAnim is not set")
  end
  if not self.Properties.HitConfirm:IsValid() then
    Debug.Log("ReticlesScreen: Lua property HitConfirm is not set")
  end
  self.tickBusHandler = DynamicBus.UITickBus.Connect(self.entityId, self)
  self.isFtue = FtueSystemRequestBus.Broadcast.IsFtue()
  if self.isFtue then
    DynamicBus.FtueMessageBus.Connect(self.entityId, self)
  end
  local siegeBallista = 2561075503
  local siegeBallistaHaveTarget = 3061347746
  local siegeRepeater = 2127167522
  local siegeRepeaterHaveTarget = 841478011
  local siegeExplosive = 2101678476
  local siegeExplosiveHaveTarget = 2248019648
  local platformCannon = 4065023903
  local platformCannonHaveTarget = 2403059343
  local platformRepeater = 531770125
  local platformRepeaterHaveTarget = 3735119404
  local platformExplosive = 3606402302
  local platformExplosiveHaveTarget = 1880968222
  self.reticleTypeToPropertyTable = {
    [3488054177] = self.Properties.MeleeReticle,
    [2844931042] = self.Properties.MeleeReticle,
    [2551600555] = self.Properties.BowReticle,
    [556808695] = self.Properties.BowReticle,
    [2731617467] = self.Properties.PistolReticle,
    [653162915] = self.Properties.PistolReticle,
    [3151297237] = self.Properties.RifleReticle,
    [880517802] = self.Properties.RifleReticle,
    [2677968547] = self.Properties.SpearReticle,
    [3788244486] = self.Properties.SpearReticle,
    [siegeBallista] = self.Properties.SiegeReticle,
    [siegeBallistaHaveTarget] = self.Properties.SiegeReticle,
    [siegeRepeater] = self.Properties.SiegeReticle,
    [siegeRepeaterHaveTarget] = self.Properties.SiegeReticle,
    [siegeExplosive] = self.Properties.SiegeReticle,
    [siegeExplosiveHaveTarget] = self.Properties.SiegeReticle,
    [platformCannon] = self.Properties.SiegeReticle,
    [platformCannonHaveTarget] = self.Properties.SiegeReticle,
    [platformRepeater] = self.Properties.SiegeReticle,
    [platformRepeaterHaveTarget] = self.Properties.SiegeReticle,
    [platformExplosive] = self.Properties.SiegeReticle,
    [platformExplosiveHaveTarget] = self.Properties.SiegeReticle,
    [3572342101] = self.Properties.ObstructedReticle
  }
  self.siegeReticleTypeToParts = {
    [siegeBallista] = self.Properties.SiegeReticleParts.Ballista,
    [siegeRepeater] = self.Properties.SiegeReticleParts.Repeater,
    [siegeExplosive] = self.Properties.SiegeReticleParts.Explosive
  }
  self.siegeReticleNames = {
    [siegeBallista] = {
      siegeBallista,
      siegeBallistaHaveTarget,
      platformCannon,
      platformCannonHaveTarget
    },
    [siegeRepeater] = {
      siegeRepeater,
      siegeRepeaterHaveTarget,
      platformRepeater,
      platformRepeaterHaveTarget
    },
    [siegeExplosive] = {
      siegeExplosive,
      siegeExplosiveHaveTarget,
      platformExplosive,
      platformExplosiveHaveTarget
    }
  }
  self.siegeWeaponNameKey = siegeBallista
  self.accuracyValues = {
    [self.Properties.BowReticle] = {
      vOffsetZero = 18,
      vOffsetOne = 30,
      hOffsetZero = 11,
      hOffsetOne = 21
    },
    [self.Properties.PistolReticle] = {
      hOffsetZero = 11,
      hOffsetOne = 21,
      ringScaleZero = 1,
      ringScaleOne = 1.25
    },
    [self.Properties.RifleReticle] = {
      vOffsetZero = 5,
      vOffsetOne = 12,
      hOffsetZero = 13,
      hOffsetOne = 31
    },
    [self.Properties.SpearReticle] = {hOffsetZero = 15, hOffsetOne = 27},
    [self.Properties.SiegeReticle] = {ringScaleZero = 1, ringScaleOne = 1.1}
  }
  self.SiegeReticleParts.ExitPrompt:SetButtonStyle(self.SiegeReticleParts.ExitPrompt.BUTTON_STYLE_DEFAULT)
  self.SiegeReticleParts.ExitPrompt:SetHint("ui_interact", true)
  self.SiegeReticleParts.ExitPrompt:SetText("@ui_back")
  SetTextStyle(self.Properties.ReticleAmmoText, self.UIStyle.FONT_STYLE_RETICLE_AMMO)
  self.reloadMessageColor = self.UIStyle.COLOR_WHITE
  self.overheatMessageColor = self.UIStyle.COLOR_RED_MEDIUM
  self.SiegeReticleParts.HealthMeter:DisableValueText()
  UiTextBus.Event.SetTextWithFlags(self.Properties.SiegeReticleParts.HeatMeterElements.HeatMeterMessage, "@overheated_Description", eUiTextSet_SetLocalized)
  UiTextBus.Event.SetColor(self.Properties.SiegeReticleParts.HeatMeterElements.HeatMeterMessage, self.overheatMessageColor)
  local heatMeterMessageWidth = UiTextBus.Event.GetTextSize(self.Properties.SiegeReticleParts.HeatMeterElements.HeatMeterMessage).x
  local heatMeterMessagePadding = 60
  UiTransform2dBus.Event.SetLocalWidth(self.Properties.SiegeReticleParts.HeatMeterElements.HeatMeterMessageBg, heatMeterMessageWidth + heatMeterMessagePadding)
  UiTextBus.Event.SetTextWithFlags(self.Properties.ReticleAmmoMessage, "@ui_no_ammo", eUiTextSet_SetLocalized)
  local noAmmoMessageWidth = UiTextBus.Event.GetTextSize(self.Properties.ReticleAmmoMessage).x
  local noAmmoMessagePadding = 50
  UiTransform2dBus.Event.SetLocalWidth(self.Properties.ReticleAmmoMessageBg, noAmmoMessageWidth + noAmmoMessagePadding)
  if not self.pulseHeatMessageTimeline then
    self.pulseHeatMessageTimeline = self.ScriptedEntityTweener:TimelineCreate()
    self.pulseHeatMessageTimeline:Add(self.Properties.SiegeReticleParts.HeatMeterElements.HeatMeterMessage, self.UIStyle.DURATION_TIMELINE_FADE_IN, {opacity = 0.9})
    self.pulseHeatMessageTimeline:Add(self.Properties.SiegeReticleParts.HeatMeterElements.HeatMeterMessage, self.UIStyle.DURATION_TIMELINE_HOLD, {opacity = 0.9})
    self.pulseHeatMessageTimeline:Add(self.Properties.SiegeReticleParts.HeatMeterElements.HeatMeterMessage, self.UIStyle.DURATION_TIMELINE_FADE_OUT, {
      opacity = 0.4,
      onComplete = function()
        self.pulseHeatMessageTimeline:Play()
      end
    })
  end
  if not self.pulseHeatGlowTimeline then
    self.pulseHeatGlowTimeline = self.ScriptedEntityTweener:TimelineCreate()
    self.pulseHeatGlowTimeline:Add(self.Properties.SiegeReticleParts.HeatMeterElements.HeatMeterFillGlow, self.UIStyle.DURATION_TIMELINE_FADE_IN, {opacity = 0.9})
    self.pulseHeatGlowTimeline:Add(self.Properties.SiegeReticleParts.HeatMeterElements.HeatMeterFillGlow, self.UIStyle.DURATION_TIMELINE_HOLD, {opacity = 0.9})
    self.pulseHeatGlowTimeline:Add(self.Properties.SiegeReticleParts.HeatMeterElements.HeatMeterFillGlow, self.UIStyle.DURATION_TIMELINE_FADE_OUT, {
      opacity = 0.4,
      onComplete = function()
        self.pulseHeatGlowTimeline:Play()
      end
    })
  end
  if not self.pulseNoAmmoTimeline then
    self.pulseNoAmmoTimeline = self.ScriptedEntityTweener:TimelineCreate()
    self.pulseNoAmmoTimeline:Add(self.Properties.ReticleAmmoMessage, self.UIStyle.DURATION_TIMELINE_FADE_IN, {opacity = 0.9})
    self.pulseNoAmmoTimeline:Add(self.Properties.ReticleAmmoMessage, self.UIStyle.DURATION_TIMELINE_HOLD, {opacity = 0.9})
    self.pulseNoAmmoTimeline:Add(self.Properties.ReticleAmmoMessage, self.UIStyle.DURATION_TIMELINE_FADE_OUT, {
      opacity = 0.4,
      onComplete = function()
        self.pulseNoAmmoTimeline:Play()
      end
    })
  end
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.GameMode.ParticipantFlags.DisableAmmoConsumption", function(self, disableAmmoConsumption)
    if disableAmmoConsumption == true then
      self.infiniteAmmo = BitwiseHelper:SetFlag(self.infiniteAmmo, self.INFINITE_AMMO_GAMEMODE)
    else
      self.infiniteAmmo = BitwiseHelper:ClearFlag(self.infiniteAmmo, self.INFINITE_AMMO_GAMEMODE)
    end
    self:SetAmmo(self.currentAmmo, true)
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Group.Id", function(self, groupId)
    self.isInGroup = groupId and groupId:IsValid()
    self:ShowReticle(self.weaponName)
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.ActiveWeapon.IsSheathed", function(self, isSheathed)
    self.isActiveWeaponSheathed = isSheathed
    self:ShowReticle(self.weaponName)
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Options.Controls.AlwaysShowReticle", function(self, isAlwaysShowingReticle)
    self.isAlwaysShowingReticle = isAlwaysShowingReticle
    self:ShowReticle(self.weaponName)
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.ReticleToShow", function(self, weaponName)
    self:ShowReticle(weaponName)
    self:UpdateTarget(weaponName)
    self.weaponName = weaponName
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.ForceHideReticle", function(self, hide)
    self.forceHideReticle = hide
    self:UpdateVisibility()
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.ReticleAmmo.Arrows", function(self, ammo)
    self.arrowAmmo = ammo
    if self.reticleToShow == self.Properties.BowReticle then
      self:SetAmmo(self.arrowAmmo)
    end
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.ReticleAmmo.Bullets", function(self, ammo)
    self.bulletAmmo = ammo
    if self.reticleToShow == self.Properties.PistolReticle or self.reticleToShow == self.Properties.RifleReticle then
      self:SetAmmo(self.bulletAmmo)
    end
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.ReticleAmmo.SiegeAmmo", function(self, ammo)
    self.siegeAmmo = ammo
    if self.reticleToShow == self.Properties.SiegeReticle then
      self:SetAmmo(self.siegeAmmo)
    end
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.SiegeFireCooldownPct", function(self, cooldownPct)
    if not self.isUsingHeat and cooldownPct ~= nil and cooldownPct < self.fireCooldownPct then
      UiElementBus.Event.SetIsEnabled(self.Properties.SiegeReticleParts.HeatMeter, true)
      UiImageBus.Event.SetFillAmount(self.Properties.SiegeReticleParts.HeatMeterElements.HeatMeterFill, 0)
      self:SetOverHeatMessageVisible(true)
    end
    self.fireCooldownPct = cooldownPct
    self:SetSiegeReloadPercent(Math.Clamp(self.fireCooldownPct, 0, 1))
    if self.fireCooldownPct >= 1 then
      self:SetOverHeatMessageVisible(false)
      UiElementBus.Event.SetIsEnabled(self.Properties.SiegeReticleParts.HeatMeter, false)
    end
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.GDERootEntityId", function(self, rootEntityId)
    if rootEntityId then
      self.rootEntityId = rootEntityId
      if self.vitalsComponentHandler then
        self:BusDisconnect(self.vitalsComponentHandler)
      end
      self.vitalsComponentHandler = self:BusConnect(VitalsComponentNotificationBus, self.rootEntityId)
    end
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.IsRangedWeaponObstructed", function(self, isObstructed)
    self.isRangedWeaponObstructed = isObstructed
    if not self.reticleToShow then
      return
    end
    local isMeleeReticle = self:IsMeleeReticle()
    if self.isRangedWeaponObstructed and not isMeleeReticle then
      self:ShowReticle(3572342101)
    elseif self.reticleToShow == self.Properties.ObstructedReticle then
      self:ShowReticle(self.weaponName)
    end
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.TurretVitalsEntityId", function(self, vitalsEntityId)
    if vitalsEntityId and vitalsEntityId:IsValid() then
      self.vitalsNotificationHandler = self:BusConnect(UiVitalsNotificationsBus, vitalsEntityId)
      local currentValue = VitalsComponentRequestBus.Event.GetCurrentHealth(vitalsEntityId)
      local maxValue = VitalsComponentRequestBus.Event.GetHealthMax(vitalsEntityId)
      self:SetSiegeHealthPercent(currentValue / maxValue, true)
    else
      self:BusDisconnect(self.vitalsNotificationHandler)
      self.vitalsNotificationHandler = nil
    end
  end)
  self.dataLayer:OnChange(self, "ReticleScreen.Turret.EnteredStatus", function(self, hasEnteredTurretDataNode)
    local hasEnteredTurret = hasEnteredTurretDataNode:GetData()
    if hasEnteredTurret then
      LyShineManagerBus.Broadcast.SetState(2702338936)
    else
      self.isOverHeated = false
      self:SetOverHeatMessageVisible(false)
      self:ShowAmmoMessage(false)
    end
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "ReticleScreen.Turret.UsesAmmo", function(self, usesAmmo)
    if usesAmmo == false then
      self.infiniteAmmo = BitwiseHelper:SetFlag(self.infiniteAmmo, self.INFINITE_AMMO_TURRET)
    else
      self.infiniteAmmo = BitwiseHelper:ClearFlag(self.infiniteAmmo, self.INFINITE_AMMO_TURRET)
    end
    self:SetAmmo(self.currentAmmo, true)
  end)
  self.dataLayer:OnChange(self, "ReticleScreen.Turret.UsingHeat", function(self, usingHeatDataNode)
    self.isUsingHeat = usingHeatDataNode:GetData()
    if self.isUsingHeat then
      UiElementBus.Event.SetIsEnabled(self.Properties.SiegeReticleParts.HeatMeter, self.isUsingHeat)
      UiTextBus.Event.SetTextWithFlags(self.Properties.SiegeReticleParts.HeatMeterElements.HeatMeterMessage, "@overheated_Description", eUiTextSet_SetLocalized)
      UiTextBus.Event.SetColor(self.Properties.SiegeReticleParts.HeatMeterElements.HeatMeterMessage, self.overheatMessageColor)
      UiImageBus.Event.SetFillAmount(self.Properties.SiegeReticleParts.HeatMeterElements.HeatMeterFill, 0)
      self:SetAmmoOffsetPosX(self.isUsingHeat)
    else
      UiTextBus.Event.SetTextWithFlags(self.Properties.SiegeReticleParts.HeatMeterElements.HeatMeterMessage, "@reloading_Description", eUiTextSet_SetLocalized)
      UiTextBus.Event.SetColor(self.Properties.SiegeReticleParts.HeatMeterElements.HeatMeterMessage, self.reloadMessageColor)
    end
  end)
  self.dataLayer:OnChange(self, "ReticleScreen.Turret.TurretHeat", function(self, heatPercentDataNode)
    local heatPercent = heatPercentDataNode:GetData()
    if heatPercent ~= nil then
      self:SetSiegeHeatPercent(Math.Clamp(heatPercent / 100, 0, 1), false)
    end
  end)
  self.dataLayer:OnChange(self, "ReticleScreen.Turret.OverheatState", function(self, isOverheatedDataNode)
    local isOverheated = isOverheatedDataNode:GetData()
    self.isOverHeated = isOverheated == true
    self:SetOverHeatMessageVisible(self.isOverHeated)
  end)
  self.dataLayer:RegisterCallback(self, "Hud.LocalPlayer.ReticleReloadEnd", function(self, dataNode)
    self.ScriptedEntityTweener:Stop(self.Properties.ReloadAnim)
    UiElementBus.Event.SetIsEnabled(self.Properties.ReloadAnim, false)
  end)
  self.dataLayer:RegisterDataCallback(self, "Hud.LocalPlayer.Damage.DealtDamage", function(self, damageDealt)
    if damageDealt ~= nil and 0 < damageDealt then
      UiElementBus.Event.SetIsEnabled(self.Properties.HitConfirm, true)
      self.hitConfirmTime = self.Properties.TimeToFadeHitConfirm
    end
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "UIFeatures.g_enableReticleAccuracy", function(self, enableAccuracy)
    self.enableReticleAccuracy = enableAccuracy
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "UIFeatures.g_uiEnableHudSettings", function(self, hudSettingsEnabled)
    self.hudSettingsEnabled = hudSettingsEnabled
    self:ShowReticle(self.weaponName)
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "UIFeatures.g_uiAlwaysRaycastForNameplates", function(self, alwaysRaycast)
    self.alwaysRaycast = alwaysRaycast
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "UIFeatures.g_onlyUseCircleReticle", function(self, onlyUseCircleReticle)
    self.onlyUseCircleReticle = onlyUseCircleReticle
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Options.Video.Fov", function(self, fovDeg)
    if fovDeg then
      self.defaultFov = math.rad(fovDeg)
    end
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Vitals.IsDead", function(self, isDead)
    if isDead ~= nil then
      self:OnDeathChanged(isDead)
    end
  end)
end
function ReticlesScreen:IsMeleeReticle()
  return self.reticleToShow == self.Properties.MeleeReticle or self.reticleToShow == self.Properties.SpearReticle
end
function ReticlesScreen:SetSiegeHealthPercent(percent, forceAnim)
  self.SiegeReticleParts.HealthMeter:SetPercentage(Math.Clamp(percent, 0, 1), forceAnim, forceAnim)
end
function ReticlesScreen:SetSiegeReloadPercent(percent)
  self:SetSiegeHeatPercent(percent, true)
end
function ReticlesScreen:SetSiegeHeatPercent(percent, isReload)
  local fullPercent = 0.23
  local imgFillPercent = percent * fullPercent
  self.ScriptedEntityTweener:Play(self.Properties.SiegeReticleParts.HeatMeterElements.HeatMeterFill, 0.15, {imgFill = imgFillPercent})
  self.ScriptedEntityTweener:Play(self.Properties.SiegeReticleParts.HeatMeterElements.HeatMeterFillWarning, 0.15, {imgFill = imgFillPercent})
  if isReload then
    return
  end
  if percent >= self.heatWarningThreshold and not self.isRepeaterHeatWarningVisible then
    self.isRepeaterHeatWarningVisible = true
    self.ScriptedEntityTweener:Play(self.Properties.SiegeReticleParts.HeatMeterElements.HeatMeterFillWarning, 0.3, {opacity = 1, ease = "QuadOut"})
  elseif percent < self.heatWarningThreshold and self.isRepeaterHeatWarningVisible and not self.isOverHeated then
    self.isRepeaterHeatWarningVisible = false
    self.ScriptedEntityTweener:Play(self.Properties.SiegeReticleParts.HeatMeterElements.HeatMeterFillWarning, 0.3, {opacity = 0, ease = "QuadOut"})
  end
end
function ReticlesScreen:OnHealthChangedUi(vitalsStatChanged)
  local currentValue = vitalsStatChanged.newVitalsStat.value
  local maxValue = vitalsStatChanged.newVitalsStat.maxValue
  self:SetSiegeHealthPercent(currentValue / maxValue, false)
end
function ReticlesScreen:SetOverHeatMessageVisible(isVisible)
  if isVisible then
    self.pulseHeatMessageTimeline:Play()
    self.pulseHeatGlowTimeline:Play()
    self.ScriptedEntityTweener:Play(self.Properties.SiegeReticleParts.HeatMeterElements.HeatMeterMessageBg, 0.3, {opacity = 0.3, ease = "QuadOut"})
  else
    self.isRepeaterHeatWarningVisible = false
    self.ScriptedEntityTweener:Play(self.Properties.SiegeReticleParts.HeatMeterElements.HeatMeterMessageBg, 0.4, {opacity = 0, ease = "QuadOut"})
    self.ScriptedEntityTweener:Play(self.Properties.SiegeReticleParts.HeatMeterElements.HeatMeterMessage, 0.3, {opacity = 0, ease = "QuadOut"})
    self.ScriptedEntityTweener:Play(self.Properties.SiegeReticleParts.HeatMeterElements.HeatMeterFillGlow, 0.3, {opacity = 0, ease = "QuadOut"})
    self.ScriptedEntityTweener:Play(self.Properties.SiegeReticleParts.HeatMeterElements.HeatMeterFillWarning, 0.3, {opacity = 0, ease = "QuadOut"})
  end
end
function ReticlesScreen:ShowAmmoMessage(show)
  if show then
    self.isPlayingAmmoMessage = true
    self.pulseNoAmmoTimeline:Play()
    self.ScriptedEntityTweener:PlayC(self.Properties.ReticleAmmoMessageBg, 0.3, tweenerCommon.opacityTo30)
  else
    self.isPlayingAmmoMessage = false
    self.pulseNoAmmoTimeline:Stop()
    self.ScriptedEntityTweener:Stop(self.Properties.ReticleAmmoMessageBg)
    self.ScriptedEntityTweener:Set(self.Properties.ReticleAmmoMessage, {opacity = 0})
    self.ScriptedEntityTweener:Set(self.Properties.ReticleAmmoMessageBg, {opacity = 0})
  end
end
function ReticlesScreen:SetAmmo(ammo, forceCalc)
  if ammo and (ammo ~= self.currentAmmo or forceCalc) then
    if self.infiniteAmmo > 0 then
      UiTextBus.Event.SetText(self.Properties.ReticleAmmoText, "\226\136\158")
    else
      UiTextBus.Event.SetText(self.Properties.ReticleAmmoText, tostring(ammo))
    end
    if ammo < self.lowAmmo and self.infiniteAmmo == 0 then
      self.isInLowAmmoState = true
      local upscalePercent = (self.lowAmmo - ammo) / self.lowAmmo
      local scale = 1 + upscalePercent
      self.ScriptedEntityTweener:PlayFromC(self.Properties.ReticleAmmoText, self.ammoFlashDuration, {
        scaleX = scale,
        scaleY = scale,
        textColor = self.UIStyle.COLOR_RED_MEDIUM
      }, tweenerCommon.scaleTo1)
      self.ScriptedEntityTweener:PlayC(self.Properties.ReticleAmmoIcon, self.ammoFlashDuration, tweenerCommon.imgToRed)
    elseif self.isInLowAmmoState then
      self.isInLowAmmoState = false
      self.ScriptedEntityTweener:Stop(self.Properties.ReticleAmmoText)
      self.ScriptedEntityTweener:Stop(self.Properties.ReticleAmmoIcon)
      self.ScriptedEntityTweener:Set(self.Properties.ReticleAmmoText, {
        textColor = self.UIStyle.FONT_STYLE_RETICLE_AMMO.fontColor,
        scaleX = 1,
        scaleY = 1
      })
      self.ScriptedEntityTweener:Set(self.Properties.ReticleAmmoIcon, {
        imgColor = self.UIStyle.COLOR_WHITE
      })
    end
    if ammo <= 0 and self.reticleToShow == self.Properties.SiegeReticle and not self.isPlayingAmmoMessage and self.infiniteAmmo == 0 then
      self:ShowAmmoMessage(true)
    elseif self.isPlayingAmmoMessage then
      self:ShowAmmoMessage(false)
    end
    if self.enableReticleAccuracy then
      self:SetInaccuracy(1, 0)
    end
    self.currentAmmo = ammo
  end
end
function ReticlesScreen:SetAmmoIcon(iconPath)
  if iconPath and iconPath ~= self.currentAmmoIconPath then
    UiImageBus.Event.SetSpritePathname(self.Properties.ReticleAmmoIcon, iconPath)
    self.currentAmmoIconPath = iconPath
  end
end
function ReticlesScreen:SetAmmoOffsetPosX(isOffsetPosition)
  local repeaterAmmoOffset = self.ammoInitPosX + 30
  local ammoNewPosition = isOffsetPosition and repeaterAmmoOffset or self.ammoInitPosX
  UiTransformBus.Event.SetLocalPositionX(self.Properties.ReticleAmmo, ammoNewPosition)
end
function ReticlesScreen:SetInaccuracy(spread, duration)
  duration = duration ~= nil and duration or self.defaultInaccuracyDuration
  if self.reticleToShow == self.Properties.BowReticle then
    local verticalOffset = Lerp(self.accuracyValues[self.Properties.BowReticle].vOffsetZero, self.accuracyValues[self.Properties.BowReticle].vOffsetOne, spread)
    self.ScriptedEntityTweener:Play(self.Properties.BowReticleParts.Top, duration, {y = verticalOffset})
    self.ScriptedEntityTweener:Play(self.Properties.BowReticleParts.Bottom, duration, {
      y = -verticalOffset
    })
    local horizontalOffset = Lerp(self.accuracyValues[self.Properties.BowReticle].hOffsetZero, self.accuracyValues[self.Properties.BowReticle].hOffsetOne, spread)
    self.ScriptedEntityTweener:Play(self.Properties.BowReticleParts.Right, duration, {x = horizontalOffset})
    self.ScriptedEntityTweener:Play(self.Properties.BowReticleParts.Left, duration, {
      x = -horizontalOffset
    })
  elseif self.reticleToShow == self.Properties.PistolReticle then
    local horizontalOffset = Lerp(self.accuracyValues[self.Properties.PistolReticle].hOffsetZero, self.accuracyValues[self.Properties.PistolReticle].hOffsetOne, spread / 2)
    self.ScriptedEntityTweener:Play(self.Properties.PistolReticleParts.Right, duration, {x = horizontalOffset})
    self.ScriptedEntityTweener:Play(self.Properties.PistolReticleParts.Left, duration, {
      x = -horizontalOffset
    })
    local ringScale = Lerp(self.accuracyValues[self.Properties.PistolReticle].ringScaleZero, self.accuracyValues[self.Properties.PistolReticle].ringScaleOne, spread)
    self.ScriptedEntityTweener:Play(self.Properties.PistolReticleParts.Ring, duration, {scaleX = ringScale, scaleY = ringScale})
  elseif self.reticleToShow == self.Properties.RifleReticle then
    local verticalOffset = Lerp(self.accuracyValues[self.Properties.RifleReticle].vOffsetZero, self.accuracyValues[self.Properties.RifleReticle].vOffsetZero, spread)
    self.ScriptedEntityTweener:Play(self.Properties.RifleReticleParts.Bottom, duration, {y = verticalOffset})
    local horizontalOffset = Lerp(self.accuracyValues[self.Properties.RifleReticle].hOffsetZero, self.accuracyValues[self.Properties.RifleReticle].hOffsetOne, spread)
    self.ScriptedEntityTweener:Play(self.Properties.RifleReticleParts.Right, duration, {x = horizontalOffset})
    self.ScriptedEntityTweener:Play(self.Properties.RifleReticleParts.Left, duration, {
      x = -horizontalOffset
    })
  elseif self.reticleToShow == self.Properties.SpearReticle then
    local horizontalOffset = Lerp(self.accuracyValues[self.Properties.SpearReticle].hOffsetZero, self.accuracyValues[self.Properties.SpearReticle].hOffsetOne, spread)
    self.ScriptedEntityTweener:Play(self.Properties.SpearReticleParts.Right, duration, {x = horizontalOffset})
    self.ScriptedEntityTweener:Play(self.Properties.SpearReticleParts.Left, duration, {
      x = -horizontalOffset
    })
  elseif self.reticleToShow == self.Properties.SiegeReticle then
    local parts = self.siegeReticleTypeToParts[self.siegeWeaponNameKey]
    if parts.Ring then
      ringScale = Lerp(self.accuracyValues[self.Properties.SiegeReticle].ringScaleZero, self.accuracyValues[self.Properties.SiegeReticle].ringScaleOne, spread)
      self.ScriptedEntityTweener:Play(parts.Ring, duration, {scaleX = ringScale, scaleY = ringScale})
    end
  end
end
function ReticlesScreen:OnTick(deltaTime, timePoint)
  if self.hitConfirmTime > 0 then
    self.hitConfirmTime = self.hitConfirmTime - deltaTime
    if self.hitConfirmTime <= 0 then
      UiElementBus.Event.SetIsEnabled(self.Properties.HitConfirm, false)
    end
  end
  if self.enableReticleAccuracy and self.reticleToShow and (self.reticleToShow == self.Properties.BowReticle or self.reticleToShow == self.Properties.PistolReticle or self.reticleToShow == self.Properties.RifleReticle or self.reticleToShow == self.Properties.SpearReticle) then
    self.inAccuracyTickVal = self.inAccuracyTickVal + 1
    if self.inAccuracyTickVal > self.inAccuracyTickInterval then
      self.inAccuracyTickVal = 0
      local inaccuracyScaleFactor = 0.65
      inaccuracyScaleFactor = inaccuracyScaleFactor * WeaponAccuracyRequestBus.Event.GetEstimatedInaccuracy(self.rootEntityId)
      local currentFov = JavCameraControllerRequestBus.Broadcast.GetCameraFov()
      if currentFov ~= 0 then
        local fovDistortion = self.defaultFov ^ currentFov
        local fovScaleFactor = self.defaultFov / currentFov
        inaccuracyScaleFactor = inaccuracyScaleFactor * fovScaleFactor * fovDistortion
      end
      self:SetInaccuracy(inaccuracyScaleFactor)
    end
  end
  if self.alwaysRaycast or self.reticleToShow == self.Properties.BowReticle or self.reticleToShow == self.Properties.PistolReticle or self.reticleToShow == self.Properties.RifleReticle or self.reticleToShow == self.Properties.SpearReticle or self.reticleToShow == self.Properties.SiegeReticle then
    self.framesSinceLastAimUpdate = self.framesSinceLastAimUpdate + 1
    if self.framesSinceLastAimUpdate > self.framesBetweenAimUpdates then
      LocalPlayerMarkerRequestBus.Broadcast.UpdateAimedTargets(self.maxAimTargetDistance)
      self.framesSinceLastAimUpdate = 0
    end
  end
end
function ReticlesScreen:UpdateTarget(weaponName)
  if not self.reticleToShow or not weaponName then
    return
  end
  local color = ColorRgba(255, 255, 255, 1)
  if string.find(weaponName, "HaveTarget") ~= nil then
    color = ColorRgba(255, 0, 0, 1)
  end
  local numChildren = UiElementBus.Event.GetNumChildElements(self.reticleToShow)
  if 0 < numChildren then
    local childEntity
    for i = 0, numChildren - 1 do
      childEntity = UiElementBus.Event.GetChild(self.reticleToShow, i)
      UiImageBus.Event.SetColor(childEntity, color)
    end
  else
    UiImageBus.Event.SetColor(self.reticleToShow, color)
  end
end
function ReticlesScreen:ShowReticle(weaponNameCrc)
  DynamicBus.QuickslotsBus.Broadcast.SetIsUsingSiegeWeapon(false)
  UiElementBus.Event.SetIsEnabled(self.Properties.BowReticle, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.MeleeReticle, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.PistolReticle, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.RifleReticle, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.SpearReticle, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.SiegeReticle, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.ReticleAmmo, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.ObstructedReticle, false)
  if self.promptVisible then
    self.ScriptedEntityTweener:Play(self.Properties.SiegeReticleParts.PromptBG, 0.35, {
      x = 400,
      opacity = 0,
      ease = "QuadIn",
      onComplete = function()
        UiElementBus.Event.SetIsEnabled(self.Properties.SiegeReticleParts.PromptBG, false)
      end
    })
    self.promptVisible = false
  end
  local meleeCrc = 3488054177
  if weaponNameCrc == meleeCrc and not self.isAlwaysShowingReticle and self.isActiveWeaponSheathed then
    weaponNameCrc = 0
  elseif self.isAlwaysShowingReticle and (not weaponNameCrc or weaponNameCrc == 0) and not self.isFtue then
    weaponNameCrc = meleeCrc
  end
  if not weaponNameCrc and (self.isInGroup or not self.isActiveWeaponSheathed) then
    weaponNameCrc = meleeCrc
  end
  if weaponNameCrc then
    if self.onlyUseCircleReticle then
      self.reticleToShow = self.Properties.PistolReticle
    else
      self.reticleToShow = self.reticleTypeToPropertyTable[weaponNameCrc]
    end
    if self.reticleToShow then
      UiElementBus.Event.SetIsEnabled(self.reticleToShow, true)
      local isMeleeReticle = self:IsMeleeReticle()
      if not isMeleeReticle then
        if self.reticleToShow == self.Properties.BowReticle then
          self:SetAmmo(self.arrowAmmo, true)
          self:SetAmmoIcon(self.iconPathArrows)
        elseif self.reticleToShow == self.Properties.PistolReticle or self.reticleToShow == self.Properties.RifleReticle then
          self:SetAmmo(self.bulletAmmo, true)
          self:SetAmmoIcon(self.iconPathCartridges)
        elseif self.reticleToShow == self.Properties.SiegeReticle then
          DynamicBus.QuickslotsBus.Broadcast.SetIsUsingSiegeWeapon(true)
          self:SetAmmo(self.siegeAmmo, true)
          self:SetAmmoIcon(self.iconPathCartridges)
          self.siegeWeaponType = weaponNameCrc
          self.siegeWeaponNameKey = 2561075503
          for keyName, weaponTable in pairs(self.siegeReticleNames) do
            local showReticle = IsInsideTable(weaponTable, self.siegeWeaponType)
            local parts = self.siegeReticleTypeToParts[keyName]
            if parts and parts.Frame then
              UiElementBus.Event.SetIsEnabled(parts.Frame, showReticle)
            end
            if showReticle then
              self.siegeWeaponNameKey = keyName
            end
          end
          self.promptVisible = true
          UiElementBus.Event.SetIsEnabled(self.Properties.SiegeReticleParts.PromptBG, true)
          self.ScriptedEntityTweener:Play(self.Properties.SiegeReticleParts.PromptBG, 0.35, {
            x = 0,
            opacity = 1,
            ease = "QuadOut"
          })
        end
        UiElementBus.Event.SetIsEnabled(self.Properties.ReticleAmmo, true)
        self:SetAmmoOffsetPosX(false)
      end
    end
  end
end
function ReticlesScreen:OnShutdown()
  DynamicBus.UITickBus.Disconnect(self.entityId, self)
  self.tickBusHandler = nil
  if self.isFtue then
    DynamicBus.FtueMessageBus.Disconnect(self.entityId, self)
  end
  if self.pulseHeatMessageTimeline then
    self.pulseHeatMessageTimeline:Stop()
    self.ScriptedEntityTweener:TimelineDestroy(self.pulseHeatMessageTimeline)
  end
  if self.pulseHeatGlowTimeline then
    self.pulseHeatGlowTimeline:Stop()
    self.ScriptedEntityTweener:TimelineDestroy(self.pulseHeatGlowTimeline)
  end
  if self.pulseNoAmmoTimeline then
    self.pulseNoAmmoTimeline:Stop()
    self.ScriptedEntityTweener:TimelineDestroy(self.pulseNoAmmoTimeline)
  end
end
function ReticlesScreen:SetElementVisibleForFtue(isVisible)
  self.isVisibleForFtue = isVisible
  self:UpdateVisibility()
end
function ReticlesScreen:OnDeathsDoorChanged(isInDeathsDoor, timeRemaining, deathsDoorCooldownRemaining)
  self.isInDeathsDoor = isInDeathsDoor
  self:UpdateVisibility()
end
function ReticlesScreen:OnDeathChanged(isDead)
  self.isDead = isDead
  self:UpdateVisibility()
end
function ReticlesScreen:OnTransitionOut(fromState, fromLevel, toState, toLevel)
  LyShineManagerBus.Broadcast.TransitionOutComplete()
end
function ReticlesScreen:UpdateVisibility()
  local isVisible = not self.isDead and not self.isInDeathsDoor and self.isVisibleForFtue and not self.forceHideReticle
  UiElementBus.Event.SetIsEnabled(self.entityId, isVisible)
end
return ReticlesScreen
