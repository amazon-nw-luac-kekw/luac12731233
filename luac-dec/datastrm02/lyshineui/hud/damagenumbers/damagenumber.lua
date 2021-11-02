local DamageNumberPositions = {
  positions = {
    {x = 0.478, y = 0.657},
    {x = 0.951, y = 0.309},
    {x = 0.309, y = 0.951},
    {x = 0.657, y = 0.478},
    {x = 0.588, y = 0.809},
    {x = 0.251, y = 0.773},
    {x = 0.809, y = 0.588},
    {x = 0.773, y = 0.251}
  },
  index = 1
}
function DamageNumberPositions:GetNext()
  if self.index < #self.positions then
    self.index = self.index + 1
  else
    self.index = 1
  end
  return self.positions[self.index].x, self.positions[self.index].y
end
local DamageNumber = {
  Properties = {
    AnimContainer = {
      default = EntityId()
    },
    DamageNumberBase = {
      default = EntityId()
    },
    DamageIconBase = {
      default = EntityId()
    },
    WeaknessIndicator = {
      default = EntityId()
    },
    DamageNumberBaseBlocked = {
      default = EntityId()
    },
    DamageNumberAdditive = {
      default = EntityId()
    },
    DamageIconAdditive = {
      default = EntityId()
    },
    DamageNumberAdditiveBlocked = {
      default = EntityId()
    },
    WeaknessIndicatorAdditive = {
      default = EntityId()
    },
    StatusEffectBg = {
      default = EntityId()
    },
    ControlledByBus = {default = true}
  },
  POSITIONING_RANDOMNESS = 0.1,
  SCALE_FACTOR = 350,
  SCALE_RANGE_SQ = 64
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(DamageNumber)
local dataLayer = RequireScript("LyShineUI.UiDataLayer")
function DamageNumber:OnInit()
  if self.Properties.ControlledByBus then
    self:BusConnect(DamageNumbersNotificationBus, self.entityId)
  end
  UiElementBus.Event.SetIsEnabled(self.entityId, false)
  self.damageData = {}
  self.playAnimations = true
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.DamageNumbers.Player.HorizontalOffsetBase", 0.1)
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.DamageNumbers.Player.HorizontalOffsetRandomRange", 0)
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.DamageNumbers.Player.ZOffsetRandomRange", 0)
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.DamageNumbers.Player.ZOffsetBase", 1.6)
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.DamageNumbers.Player.UpdatePositionForFrames", 0)
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.DamageNumbers.Enemy.UpdatePositionForFrames", 10)
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.DamageNumbers.Enemy.UseImpactPosition", true)
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.DamageNumbers.Enemy.ZOffsetMinimum", 0.75)
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.DamageNumbers.Enemy.HorizontalOffsetBase", 0)
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.DamageNumbers.Enemy.HorizontalOffsetRandomRange", 0)
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.DamageNumbers.Enemy.VerticalOffsetRandomRange", 0)
  self.dataLayer:RegisterAndExecuteMultiObserver(self, {
    "Hud.LocalPlayer.Options.Video.UseNewDamageNumbers",
    "Hud.LocalPlayer.Options.Accessibility.TextSizeOption"
  }, function(self, values)
    local enableNewDamageNumbers = values[1]
    local textSizeOption = values[2]
    self.useNewDamageNumbers = enableNewDamageNumbers
    local fontScale = 1
    if self.useNewDamageNumbers then
      fontScale = 0.85
    end
    if textSizeOption == eAccessibilityTextOptions_Bigger then
      fontScale = fontScale + 0.25
    end
    self.ScriptedEntityTweener:Set(self.Properties.DamageNumberBase, {scaleX = fontScale, scaleY = fontScale})
    self.ScriptedEntityTweener:Set(self.Properties.DamageNumberAdditive, {scaleX = fontScale, scaleY = fontScale})
  end)
end
function DamageNumber:OnDamageDisplayed(isNew, damageType, damage, damageModifier, defenseReduction, isHeadShot, distanceFromLocalPlayerSq, numAlreadyDisplaying, isLocalPlayer)
  if isNew then
    ClearTable(self.damageData)
    self.ScriptedEntityTweener:Stop(self.Properties.AnimContainer)
  end
  local existingDamage = self.damageData[damageType]
  if not existingDamage then
    self.damageData[damageType] = {
      damage = damage,
      damageModifier = damageModifier,
      defenseReduction = defenseReduction,
      isHeadShot = isHeadShot,
      isPrimary = isNew
    }
  else
    existingDamage.damage = existingDamage.damage + damage
    existingDamage.isHeadShot = existingDamage.isHeadShot or isHeadShot
  end
  if not self.tickBusHandler then
    self.tickBusHandler = DynamicBus.UITickBus.Connect(self.entityId, self)
  end
  self.distanceFromLocalPlayerSq = distanceFromLocalPlayerSq
  self.numAlreadyDisplaying = numAlreadyDisplaying
  self.isLocalPlayerDamage = isLocalPlayer
end
function DamageNumber:OnCombinedDamageDisplayed(damageByType, isCrit, distanceFromLocalPlayerSq, numAlreadyDisplaying, isLocalPlayer, absorption)
  ClearTable(self.damageData)
  self.ScriptedEntityTweener:Stop(self.Properties.AnimContainer)
  if 2 < #damageByType then
    Log("WARNING: DamageNumber:OnCombinedDamageDisplayed - Received combintion of more than 2 damage types.")
  end
  for i = 1, #damageByType do
    local damageEntry = damageByType[i]
    local damageType = damageEntry:GetDamageTypeString()
    local existingDamage = self.damageData[damageType]
    if not existingDamage then
      self.damageData[damageType] = {
        damage = damageEntry.damageAmount,
        damageModifier = damageEntry.damageMitigation,
        isHeadShot = isCrit,
        isPrimary = i == 1,
        absorption = absorption[i].first,
        weakness = absorption[i].second
      }
    else
      local entryMitigatedDamage = damageEntry.damageAmount / damageEntry.damageMitigation - damageEntry.damageAmount
      if existingDamage.multiMitigatedDamage then
        existingDamage.multiMitigatedDamage = existingDamage.multiMitigatedDamage + entryMitigatedDamage
      else
        existingDamage.multiMitigatedDamage = existingDamage.damage / existingDamage.damageModifier - existingDamage.damage + entryMitigatedDamage
      end
      existingDamage.damage = existingDamage.damage + damageEntry.damageAmount
    end
  end
  if not self.tickBusHandler then
    self.tickBusHandler = DynamicBus.UITickBus.Connect(self.entityId, self)
  end
  self.distanceFromLocalPlayerSq = distanceFromLocalPlayerSq
  self.numAlreadyDisplaying = numAlreadyDisplaying
  self.isLocalPlayerDamage = isLocalPlayer
end
function DamageNumber:OnStatusEffectDisplayed(displayName, icon, isNegative, isLocalPlayer, distanceFromLocalPlayerSq)
  if not displayName or displayName == "" then
    return
  end
  ClearTable(self.damageData)
  UiElementBus.Event.SetIsEnabled(self.entityId, true)
  self.ScriptedEntityTweener:Stop(self.Properties.AnimContainer)
  self.ScriptedEntityTweener:Set(self.Properties.AnimContainer, {
    scaleX = 1,
    scaleY = 1,
    x = -50,
    y = 0,
    opacity = 0
  })
  self.ScriptedEntityTweener:Play(self.Properties.AnimContainer, 0.01, {opacity = 1, delay = 0.1})
  UiTextBus.Event.SetTextWithFlags(self.Properties.DamageNumberBase, displayName, eUiTextSet_SetLocalized)
  local imagePath = string.format("%s/%s.dds", "lyshineui/images/status", icon)
  UiImageBus.Event.SetSpritePathname(self.Properties.DamageIconBase, imagePath)
  UiImageBus.Event.SetColor(self.Properties.StatusEffectBg, isNegative and self.UIStyle.COLOR_RED_DARK or self.UIStyle.COLOR_BLACK)
  self.distanceFromLocalPlayerSq = distanceFromLocalPlayerSq
  local scaleFactor = self.SCALE_FACTOR
  local maxRange = self.SCALE_RANGE_SQ
  local percentToScale = 1 - Clamp(self.distanceFromLocalPlayerSq / maxRange, 0, 1)
  local distanceBasedAdditionalMovement = 0
  distanceBasedAdditionalMovement = percentToScale * scaleFactor
  distanceBasedAdditionalMovement = math.max(distanceBasedAdditionalMovement, 100)
  local xMovement = 0
  local yMovement = 0
  xMovement, yMovement = DamageNumberPositions:GetNext()
  xMovement = xMovement * distanceBasedAdditionalMovement * 0.75
  yMovement = yMovement * distanceBasedAdditionalMovement * 0.75
  xMovement = xMovement + math.random() * self.POSITIONING_RANDOMNESS * distanceBasedAdditionalMovement
  yMovement = yMovement + math.random() * self.POSITIONING_RANDOMNESS * distanceBasedAdditionalMovement
  if isLocalPlayer then
    xMovement = xMovement * -1
  end
  local fontScale = 0.7
  local fontMaxRange = 225
  local percentToScaleForFont = 1 - Clamp(self.distanceFromLocalPlayerSq / fontMaxRange, 0, 1)
  local scaleAmountMax = 0.2
  fontScale = fontScale + percentToScaleForFont * scaleAmountMax
  local popScale = fontScale + 0.1
  self:DoAnimation(xMovement, -1 * yMovement, popScale, fontScale, 3)
end
function DamageNumber:OnTick(deltaTime, timePoint)
  DynamicBus.UITickBus.Disconnect(self.entityId, self)
  self.tickBusHandler = nil
  local isLocalPlayerDamage = self.isLocalPlayerDamage
  local baseDamage = 0
  local baseIconPath
  local additiveDamage = 0
  local additiveIconPath
  local isAdditiveDamage = false
  local isHeadShot = false
  local mitigatedBaseDamage = 0
  local mitigatedAdditiveDamage = 0
  local isWeaknessBaseDamage = false
  local isWeaknessAdditiveDamage = false
  local isStrongAgainstBaseDamage = false
  local isStrongAgainstAdditiveDamage = false
  local fullyAbsorbedBaseDamage = false
  for damageType, damageData in pairs(self.damageData) do
    if damageData.isPrimary then
      self.damageTypeBase = damageType
      isHeadShot = damageData.isHeadShot
      baseDamage = damageData.damage
      baseIconPath = "lyshineui/images/icons/tooltip/icon_tooltip_" .. damageType .. "_opaque.dds"
      if not damageData.multiMitigatedDamage then
        mitigatedBaseDamage = baseDamage / damageData.damageModifier - baseDamage
      else
        mitigatedBaseDamage = damageData.multiMitigatedDamage
      end
      isWeaknessBaseDamage = damageData.weakness and 0 < damageData.weakness
      isStrongAgainstBaseDamage = damageData.absorption and 0 < damageData.absorption
      fullyAbsorbedBaseDamage = damageData.absorption and damageData.absorption >= 1
    else
      self.damageTypeAdditive = damageType
      isAdditiveDamage = true
      additiveDamage = damageData.damage
      additiveIconPath = "lyshineui/images/icons/tooltip/icon_tooltip_" .. damageType .. "_opaque.dds"
      if not damageData.multiMitigatedDamage then
        mitigatedAdditiveDamage = additiveDamage / damageData.damageModifier - additiveDamage
      else
        mitigatedAdditiveDamage = damageData.multiMitigatedDamage
      end
      isWeaknessAdditiveDamage = damageData.weakness and 0 < damageData.weakness
      isStrongAgainstAdditiveDamage = damageData.absorption and 0 < damageData.absorption
    end
    if damageType == "LocalPlayer" then
      baseDamage = damageData.damage
      isLocalPlayerDamage = true
    end
  end
  local isHeal = baseDamage < 0
  local damageTextColor
  baseDamage = math.floor(math.abs(baseDamage))
  UiElementBus.Event.SetIsEnabled(self.entityId, true)
  self.ScriptedEntityTweener:Stop(self.Properties.AnimContainer)
  self.ScriptedEntityTweener:Set(self.Properties.AnimContainer, {
    opacity = 1,
    x = 100,
    y = 0
  })
  local fontScale = 0.85
  local xMovement = 0
  local yMovement = 0
  if self.useNewDamageNumbers then
    local scaleFactor = self.SCALE_FACTOR
    local maxRange = self.SCALE_RANGE_SQ
    local percentToScale = 1 - Clamp(self.distanceFromLocalPlayerSq / maxRange, 0, 1)
    local distanceBasedAdditionalMovement = 0
    distanceBasedAdditionalMovement = percentToScale * scaleFactor
    distanceBasedAdditionalMovement = math.max(distanceBasedAdditionalMovement, 100)
    local fontMaxRange = 225
    local percentToScaleForFont = 1 - Clamp(self.distanceFromLocalPlayerSq / fontMaxRange, 0, 1)
    local scaleAmountMax = 0.5
    local scaleAmount = percentToScaleForFont * scaleAmountMax
    local maxScale = 0.7
    fontScale = scaleAmount + 0.5 + 0.15
    fontScale = math.max(fontScale, maxScale)
    if not isHeal then
      xMovement, yMovement = DamageNumberPositions:GetNext()
      xMovement = xMovement * distanceBasedAdditionalMovement
      yMovement = yMovement * distanceBasedAdditionalMovement
    else
      xMovement = 0
      yMovement = distanceBasedAdditionalMovement
    end
    xMovement = xMovement + math.random() * self.POSITIONING_RANDOMNESS * distanceBasedAdditionalMovement
    yMovement = yMovement + math.random() * self.POSITIONING_RANDOMNESS * distanceBasedAdditionalMovement
    if isLocalPlayerDamage then
      xMovement = xMovement * -1
    end
  end
  if isHeal then
    self:DoAnimation(0, 20, 0.9, 1.1, 2)
  elseif isHeadShot then
    self:DoAnimation(xMovement, -1 * yMovement, fontScale + 0.35, fontScale + 0.2, 2)
  else
    local endScale = fontScale
    if isWeaknessBaseDamage then
      endScale = fontScale + 0.1
    elseif isStrongAgainstBaseDamage then
      endScale = fontScale - 0.1
    end
    self:DoAnimation(xMovement, -1 * yMovement, fontScale + 0.05, endScale, 2)
  end
  if not isHeal then
    damageTextColor = self.UIStyle.COLOR_NAMEPLATE_DAMAGE
    local weaknessIndicatorY = -22
    local weaknessScaleY = 1
    local baseIconScale = 1.5
    local baseIconY = 1
    if isWeaknessBaseDamage then
      damageTextColor = self.UIStyle.COLOR_NAMEPLATE_WEAKNESS
      baseIconScale = 1
      baseIconY = 10
    elseif isStrongAgainstBaseDamage then
      damageTextColor = self.UIStyle.COLOR_NAMEPLATE_STRENGTH
      weaknessScaleY = -1
      weaknessIndicatorY = 22
      baseIconScale = 1
      baseIconY = -8
    end
    if isHeadShot then
      damageTextColor = self.UIStyle.COLOR_NAMEPLATE_HEADSHOT
    end
    if isLocalPlayerDamage then
      damageTextColor = self.UIStyle.COLOR_NAMEPLATE_DAMAGE_PLAYER
    end
    if isWeaknessBaseDamage or isStrongAgainstBaseDamage then
      UiElementBus.Event.SetIsEnabled(self.Properties.WeaknessIndicator, true)
      UiImageBus.Event.SetColor(self.Properties.WeaknessIndicator, damageTextColor)
      UiTransformBus.Event.SetScaleY(self.Properties.WeaknessIndicator, weaknessScaleY)
      UiTransformBus.Event.SetLocalPositionY(self.Properties.WeaknessIndicator, weaknessIndicatorY)
    else
      UiElementBus.Event.SetIsEnabled(self.Properties.WeaknessIndicator, false)
    end
    UiTransformBus.Event.SetScale(self.Properties.DamageIconBase, Vector2(baseIconScale, baseIconScale))
    UiTransformBus.Event.SetLocalPositionY(self.Properties.DamageIconBase, baseIconY)
  else
    baseDamage = "+" .. baseDamage
    damageTextColor = self.UIStyle.COLOR_NAMEPLATE_HEALING
  end
  UiTextBus.Event.SetColor(self.Properties.DamageNumberBase, damageTextColor)
  UiTextBus.Event.SetText(self.Properties.DamageNumberBase, tostring(baseDamage))
  UiImageBus.Event.SetSpritePathname(self.Properties.DamageIconBase, baseIconPath)
  UiImageBus.Event.SetColor(self.Properties.DamageIconBase, damageTextColor)
  UiElementBus.Event.SetIsEnabled(self.Properties.DamageNumberBase, baseDamage ~= 0)
  UiElementBus.Event.SetIsEnabled(self.Properties.DamageIconBase, not isHeal and self.damageTypeBase ~= "")
  if fullyAbsorbedBaseDamage then
    UiTextBus.Event.SetTextWithFlags(self.Properties.DamageNumberBase, "@immune_to_damage", eUiTextSet_SetLocalized)
    UiElementBus.Event.SetIsEnabled(self.Properties.DamageNumberBase, true)
    SetTextStyle(self.Properties.DamageNumberBase, self.UIStyle.FONT_STYLE_DAMAGE_NUMBER_STATUS)
  else
    SetTextStyle(self.Properties.DamageNumberBase, self.UIStyle.FONT_STYLE_DAMAGE_NUMBER)
  end
  if isLocalPlayerDamage and 0 < mitigatedBaseDamage then
    UiTextBus.Event.SetText(self.Properties.DamageNumberBaseBlocked, string.format("-%d", mitigatedBaseDamage))
  else
    UiTextBus.Event.SetText(self.Properties.DamageNumberBaseBlocked, "")
  end
  if isAdditiveDamage then
    additiveDamage = math.floor(math.abs(additiveDamage))
    UiTextBus.Event.SetText(self.Properties.DamageNumberAdditive, string.format("%d", additiveDamage))
    UiImageBus.Event.SetSpritePathname(self.Properties.DamageIconAdditive, additiveIconPath)
    if isLocalPlayerDamage then
      UiTextBus.Event.SetText(self.Properties.DamageNumberAdditiveBlocked, string.format("-%d", mitigatedAdditiveDamage))
      UiElementBus.Event.SetIsEnabled(self.Properties.DamageNumberAdditiveBlocked, 0 < mitigatedAdditiveDamage)
    else
      UiElementBus.Event.SetIsEnabled(self.Properties.DamageNumberAdditiveBlocked, false)
    end
    local additiveDamageColor = self.UIStyle.COLOR_NAMEPLATE_DAMAGE
    local weaknessIndicatorAdditiveScaleY = 1
    local weaknessIndicatorAdditiveY = -22
    local additiveIconScale = 1.25
    local additiveIconY = 1
    if isWeaknessAdditiveDamage then
      additiveDamageColor = self.UIStyle.COLOR_NAMEPLATE_WEAKNESS
      additiveIconScale = 1
      additiveIconY = 10
    elseif isStrongAgainstAdditiveDamage then
      additiveDamageColor = self.UIStyle.COLOR_NAMEPLATE_STRENGTH
      weaknessIndicatorAdditiveScaleY = -1
      weaknessIndicatorAdditiveY = 22
      additiveIconScale = 1
      additiveIconY = -8
    end
    if isHeadShot then
      additiveDamageColor = self.UIStyle.COLOR_NAMEPLATE_HEADSHOT
    end
    if isLocalPlayerDamage then
      additiveDamageColor = self.UIStyle.COLOR_NAMEPLATE_DAMAGE_PLAYER
    end
    if isWeaknessAdditiveDamage or isStrongAgainstAdditiveDamage then
      UiElementBus.Event.SetIsEnabled(self.Properties.WeaknessIndicatorAdditive, true)
      UiImageBus.Event.SetColor(self.Properties.WeaknessIndicatorAdditive, additiveDamageColor)
      UiTransformBus.Event.SetScaleY(self.Properties.WeaknessIndicatorAdditive, weaknessIndicatorAdditiveScaleY)
      UiTransformBus.Event.SetLocalPositionY(self.Properties.WeaknessIndicatorAdditive, weaknessIndicatorAdditiveY)
    else
      UiElementBus.Event.SetIsEnabled(self.Properties.WeaknessIndicatorAdditive, false)
    end
    UiTextBus.Event.SetColor(self.Properties.DamageNumberAdditive, additiveDamageColor)
    UiImageBus.Event.SetColor(self.Properties.DamageIconAdditive, additiveDamageColor)
    UiElementBus.Event.SetIsEnabled(self.Properties.DamageIconAdditive, self.damageTypeAdditive ~= "")
    UiTransformBus.Event.SetScale(self.Properties.DamageIconAdditive, Vector2(additiveIconScale, additiveIconScale))
    UiTransformBus.Event.SetLocalPositionY(self.Properties.DamageIconAdditive, additiveIconY)
  end
  UiElementBus.Event.SetIsEnabled(self.Properties.DamageNumberAdditive, isAdditiveDamage)
end
function DamageNumber:DoAnimation(xMovement, yMovement, startScale, endScale, visibilityDuration)
  self.ScriptedEntityTweener:Set(self.Properties.AnimContainer, {
    scaleX = 1,
    scaleY = 1,
    x = -50,
    y = 0,
    opacity = 0
  })
  self.ScriptedEntityTweener:Play(self.Properties.AnimContainer, 0.01, {opacity = 1, delay = 0.1})
  self.ScriptedEntityTweener:Play(self.Properties.AnimContainer, 4.5, {
    x = xMovement,
    y = yMovement,
    ease = "ExpoOut"
  })
  self.ScriptedEntityTweener:Play(self.Properties.AnimContainer, 0.25, {
    scaleX = startScale,
    scaleY = startScale,
    onComplete = function()
      self.ScriptedEntityTweener:Play(self.Properties.AnimContainer, 0.25, {scaleX = endScale, scaleY = endScale})
    end
  })
  self.ScriptedEntityTweener:Play(self.Properties.AnimContainer, 1, {
    opacity = 0,
    delay = visibilityDuration - 1,
    ease = "QuadOut",
    onComplete = function()
      UiElementBus.Event.SetIsEnabled(self.entityId, false)
      self.ScriptedEntityTweener:Stop(self.Properties.AnimContainer)
      DamageNumbersBus.Broadcast.OnAnimDone(self.entityId)
    end
  })
end
return DamageNumber
