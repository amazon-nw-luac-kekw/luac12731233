local Attributes = {
  Properties = {
    DamageStatsLabel = {
      default = EntityId()
    },
    VitalsLabel = {
      default = EntityId()
    },
    StatSections = {
      BaseStats = {
        default = EntityId()
      },
      DamageStats = {
        default = EntityId()
      }
    },
    AttributeSpawner = {
      default = EntityId()
    },
    AttributeModifiers = {
      default = {
        EntityId()
      }
    },
    PointsAvailableContainer = {
      default = EntityId()
    },
    PointsAvailableRing1 = {
      default = EntityId()
    },
    PointsAvailableRing2 = {
      default = EntityId()
    },
    PointsAvailableRing3 = {
      default = EntityId()
    },
    PointsAvailableNumber = {
      default = EntityId()
    },
    PointsAvailableLabel = {
      default = EntityId()
    },
    ConfirmButton = {
      default = EntityId()
    },
    RespecButton = {
      default = EntityId()
    },
    WeaponLine = {
      default = EntityId()
    },
    BottomLine = {
      default = EntityId()
    },
    BottomDivider = {
      default = EntityId()
    },
    TopLine = {
      default = EntityId()
    },
    DamageLabelDivider = {
      default = EntityId()
    },
    VitalsLabelDivider = {
      default = EntityId()
    }
  },
  AttributeModifierSlicePath = "LyShineUI\\Attributes\\AttributeModifier",
  StatRowSlicePath = "LyShineUI\\Attributes\\StatRow",
  DamageStatRowSlicePath = "LyshineUI\\Attributes\\DamageStatRow",
  AttributeModifierEntities = {},
  StatRowEntities = {},
  DamageRowEntities = {},
  unspentPoints = 0,
  spentPoints = 0,
  pendingPoints = 0,
  bonusPoints = 0
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(Attributes)
local Spawner = RequireScript("LyShineUI._Common.Spawner")
Spawner:AttachSpawner(Attributes)
local PopupWrapper = RequireScript("LyShineUI.Popup.PopupRequestWrapper")
local tweenerCommon = RequireScript("LyShineUI._Common.ScriptedEntityTweenerCommon")
local WeaponMasteryData = RequireScript("LyShineUI.Skills.WeaponMastery.WeaponMasteryData")
function Attributes:OnInit()
  BaseElement.OnInit(self)
  self.AttributeModifiersData = {
    {
      text = "@ui_strength",
      tooltip = "@ui_strength_tooltip",
      description = "@ui_strength_description",
      name = "Strength",
      enum = CharacterAttributeType_Strength
    },
    {
      text = "@ui_dexterity",
      tooltip = "@ui_dexterity_tooltip",
      description = "@ui_dexterity_description",
      name = "Dexterity",
      enum = CharacterAttributeType_Dexterity
    },
    {
      text = "@ui_intelligence",
      tooltip = "@ui_intelligence_tooltip",
      description = "@ui_intelligence_description",
      name = "Intelligence",
      enum = CharacterAttributeType_Intelligence
    },
    {
      text = "@ui_focus",
      tooltip = "@ui_focus_tooltip",
      description = "@ui_focus_description",
      name = "Focus",
      enum = CharacterAttributeType_Focus
    },
    {
      text = "@ui_constitution",
      tooltip = "@ui_constitution_tooltip",
      description = "@ui_constitution_description",
      name = "Constitution",
      enum = CharacterAttributeType_Constitution
    }
  }
  self.BaseStatsData = {
    {
      text = "@ui_mana_rate",
      tooltip = "@ui_vitals_mana_rate_tooltip",
      name = "ManaRate",
      dataPath = "Hud.LocalPlayer.Vitals.ManaRate",
      pendingDataPath = "Hud.LocalPlayer.Attributes.PendingDelta.ManaRate",
      activeDataPath = "Hud.LocalPlayer.Vitals.ManaRate",
      isPercent = true,
      roundValue = true
    },
    {
      text = "@ui_max_health",
      tooltip = "@ui_vitals_health_tooltip",
      name = "Health",
      dataPath = "Hud.LocalPlayer.Vitals.HealthMax",
      pendingDataPath = "Hud.LocalPlayer.Attributes.PendingDelta.Health",
      activeDataPath = "Hud.LocalPlayer.Vitals.HealthValue",
      floorValue = true
    }
  }
  self.DamageStatsData = {
    {
      text = "@ui_main_hand_1",
      tooltip = "@ui_main_hand_1_tooltip",
      name = "MainHand1",
      pendingDataPath = "Hud.LocalPlayer.Attributes.PendingDelta.BonusDamage.main-hand-option-1",
      slotType = "main-hand-option-1",
      numberFormat = "%d"
    },
    {
      text = "@ui_main_hand_2",
      tooltip = "@ui_main_hand_2_tooltip",
      name = "MainHand2",
      pendingDataPath = "Hud.LocalPlayer.Attributes.PendingDelta.BonusDamage.main-hand-option-2",
      slotType = "main-hand-option-2",
      numberFormat = "%d"
    }
  }
  self.weaponScalingData = {
    Strength = {},
    Dexterity = {},
    Intelligence = {},
    Focus = {},
    Constitution = {}
  }
  for category, categoryData in pairs(WeaponMasteryData.data) do
    for i = 1, #categoryData do
      local currentWeaponData = categoryData[i]
      if currentWeaponData.scalePrimary then
        table.insert(self.weaponScalingData[currentWeaponData.scalePrimary], currentWeaponData)
      end
      if currentWeaponData.scaleSecondary then
        table.insert(self.weaponScalingData[currentWeaponData.scaleSecondary], currentWeaponData)
      end
    end
  end
  local healthData = {
    text = "@ui_health",
    iconSmall = "LyShineUI\\Images\\Icons\\Perks\\Health1Small.dds",
    scalePrimary = "Constitution",
    scaleSecondary = nil,
    attribute = "@ui_constitution"
  }
  table.insert(self.weaponScalingData.Constitution, healthData)
  for i = 1, #self.AttributeModifiersData do
    local data = self.AttributeModifiersData[i]
    local scalingTable = self.weaponScalingData[data.name]
    table.sort(scalingTable, function(a, b)
      if a.scalePrimary ~= b.scalePrimary then
        return a.scalePrimary == data.name
      end
    end)
    data.weaponScalingData = scalingTable
    data.itemIndex = i
    self:SetAttributeModifierData(self.AttributeModifiers[i - 1], data)
  end
  local statIndex = 1
  self:BusConnect(UiSpawnerNotificationBus, self.StatSections.BaseStats)
  for i = 1, #self.BaseStatsData do
    local data = self.BaseStatsData[i]
    data.itemIndex = statIndex
    self:SpawnSlice(self.StatSections.BaseStats, self.StatRowSlicePath, self.OnStatRowSpawned, data)
    statIndex = statIndex + 1
  end
  self:BusConnect(UiSpawnerNotificationBus, self.StatSections.DamageStats)
  for i = 1, #self.DamageStatsData do
    local data = self.DamageStatsData[i]
    data.itemIndex = i
    self:SpawnSlice(self.StatSections.DamageStats, self.DamageStatRowSlicePath, self.OnDamageStatRowSpawned, data)
  end
  self.RespecButton:SetEnabled(false)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.PlayerEntityId", function(self, playerEntityId)
    self.playerEntityId = playerEntityId
  end)
  self.ConfirmButton:SetButtonStyle(self.ConfirmButton.BUTTON_STYLE_CTA)
  self.ConfirmButton:SetIsMarkupEnabled(true)
  self.ConfirmButton:SetCallback(self.ConfirmPoints, self)
  self.ConfirmButton:SetSoundOnPress(self.audioHelper.AttributesConfirmed)
  self.RespecButton:SetText("@ui_respec")
  self.RespecButton:SetCallback(self.RespecPoints, self)
  self.WeaponLine:SetColor(self.UIStyle.COLOR_GRAY_80)
  self.BottomLine:SetColor(self.UIStyle.COLOR_GRAY_80)
  self.BottomDivider:SetColor(self.UIStyle.COLOR_GRAY_80)
  self.TopLine:SetColor(self.UIStyle.COLOR_GRAY_80)
  self.DamageLabelDivider:SetColor(self.UIStyle.COLOR_GRAY_80)
  self.VitalsLabelDivider:SetColor(self.UIStyle.COLOR_GRAY_80)
  SetTextStyle(self.Properties.DamageStatsLabel, self.UIStyle.FONT_STYLE_ATTRIBUTES_STAT_LABEL)
  SetTextStyle(self.Properties.VitalsLabel, self.UIStyle.FONT_STYLE_ATTRIBUTES_STAT_LABEL)
end
function Attributes:SetScreenVisible(isVisible)
  if isVisible == self.screenVisible then
    return
  end
  local animDuration = 0.8
  self.screenVisible = isVisible
  if self.screenVisible == true then
    self.ScriptedEntityTweener:PlayFromC(self.entityId, 0.15, {opacity = 0}, tweenerCommon.fadeInQuadOut)
    self.ScriptedEntityTweener:PlayC(self.Properties.RespecButton, 0.8, tweenerCommon.fadeInQuadOut, 0.06)
    self.ScriptedEntityTweener:PlayC(self.Properties.ConfirmButton, 0.8, tweenerCommon.fadeInQuadOut, 0.12)
    self.WeaponLine:SetVisible(false, 0)
    self.WeaponLine:SetVisible(true, 0.9, {delay = 0.2})
    self.BottomLine:SetVisible(false, 0)
    self.BottomLine:SetVisible(true, 1.2)
    self.BottomDivider:SetVisible(false, 0)
    self.BottomDivider:SetVisible(true, 1.2)
    self.TopLine:SetVisible(false, 0)
    self.TopLine:SetVisible(true, 1.2, {delay = 0.2})
    self.DamageLabelDivider:SetVisible(false, 0)
    self.DamageLabelDivider:SetVisible(true, 0.4, {delay = 0.2})
    self.VitalsLabelDivider:SetVisible(false, 0)
    self.VitalsLabelDivider:SetVisible(true, 0.4, {delay = 0.3})
    for i = 0, #self.Properties.AttributeModifiers do
      self.ScriptedEntityTweener:Play(self.Properties.AttributeModifiers[i], 0.5, {opacity = 0}, {
        opacity = 1,
        ease = "QuadOut",
        delay = i * 0.05
      })
    end
    self:RegisterObservers()
    self:UpdateDamageStats()
    self:UpdateAvailablePointsVisibility(true)
    self:UpdateRespecState()
    self.ScriptedEntityTweener:PlayFromC(self.Properties.PointsAvailableRing1, 105, {rotation = 0}, tweenerCommon.rotateCWInfinite)
    self.ScriptedEntityTweener:PlayFromC(self.Properties.PointsAvailableRing2, 90, {rotation = 0}, tweenerCommon.rotateCCWInfinite)
    self.ScriptedEntityTweener:PlayFromC(self.Properties.PointsAvailableRing3, 120, {rotation = 0}, tweenerCommon.rotateCWInfinite)
    self.ScriptedEntityTweener:PlayFromC(self.Properties.PointsAvailableContainer, 0.6, {opacity = 0}, tweenerCommon.fadeInQuadOut, 0.2)
  else
    UiFaderBus.Event.SetFadeValue(self.Properties.RespecButton, 0)
    UiFaderBus.Event.SetFadeValue(self.Properties.ConfirmButton, 0)
    self.ScriptedEntityTweener:Stop(self.Properties.PointsAvailableRing1)
    self.ScriptedEntityTweener:Stop(self.Properties.PointsAvailableRing2)
    self.ScriptedEntityTweener:Stop(self.Properties.PointsAvailableRing3)
    self:UnregisterObservers()
  end
end
function Attributes:RegisterObservers()
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Attributes.UnspentPoints", self.SetUnspentPointsData)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Attributes.PendingPoints", self.SetPendingPoints)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Attributes.SpentPoints", self.SetSpentPoints)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Attributes.BonusPoints", self.SetBonusPoints)
  for i, entity in pairs(self.AttributeModifierEntities) do
    entity:RegisterObservers()
  end
  for i, entity in pairs(self.StatRowEntities) do
    entity:RegisterObservers()
  end
  for i, entity in pairs(self.DamageRowEntities) do
    entity:RegisterObservers()
  end
end
function Attributes:UnregisterObservers()
  self.dataLayer:UnregisterObserver(self, "Hud.LocalPlayer.Attributes.UnspentPoints")
  self.dataLayer:UnregisterObserver(self, "Hud.LocalPlayer.Attributes.PendingPoints")
  self.dataLayer:UnregisterObserver(self, "Hud.LocalPlayer.Attributes.SpentPoints")
  for i, entity in pairs(self.AttributeModifierEntities) do
    entity:UnregisterObservers()
  end
  for i, entity in pairs(self.StatRowEntities) do
    entity:UnregisterObservers()
  end
  for i, entity in pairs(self.DamageRowEntities) do
    entity:UnregisterObservers()
  end
end
function Attributes:UpdateAvailablePointsVisibility(forceAnimations)
  local isPointsAvailableHighlighted = self.unspentPoints > 0
  if self.isPointsAvailableHighlighted == isPointsAvailableHighlighted and not forceAnimations then
    return
  end
  self.isPointsAvailableHighlighted = isPointsAvailableHighlighted
  if isPointsAvailableHighlighted then
    self.ScriptedEntityTweener:Play(self.Properties.PointsAvailableNumber, 0.3, {
      textColor = self.UIStyle.COLOR_XP
    })
    self.ScriptedEntityTweener:Play(self.Properties.PointsAvailableLabel, 0.3, {
      textColor = self.UIStyle.COLOR_WHITE
    })
  else
    self.ScriptedEntityTweener:Play(self.Properties.PointsAvailableNumber, 0.3, {
      textColor = self.UIStyle.COLOR_GRAY_50
    })
    self.ScriptedEntityTweener:Play(self.Properties.PointsAvailableLabel, 0.3, {
      textColor = self.UIStyle.COLOR_WHITE
    })
  end
end
function Attributes:SetUnspentPointsData(data)
  if data ~= nil then
    self.unspentPoints = data
    UiTextBus.Event.SetText(self.Properties.PointsAvailableNumber, self.unspentPoints)
    self:UpdateAvailablePointsVisibility()
  end
end
function Attributes:SetPendingPoints(data)
  if data ~= nil then
    self.pendingPoints = data
    self.ConfirmButton:SetEnabled(self.pendingPoints > 0)
    if self.pendingPoints > 0 then
      self.ConfirmButton:OnFocus()
    else
      self.ConfirmButton:OnUnfocus()
    end
    local buttonText = "@ui_no_points_spent"
    if self.pendingPoints > 1 then
      buttonText = GetLocalizedReplacementText("@ui_commit_points", {
        points = self.pendingPoints
      })
    elseif self.pendingPoints == 1 then
      buttonText = "@ui_commit_1_point"
    end
    self.ConfirmButton:SetText(buttonText)
    self:UpdateRespecState()
    self:UpdateAvailablePointsVisibility()
  end
end
function Attributes:SetSpentPoints(data)
  if data ~= nil then
    self.spentPoints = data
    self:UpdateRespecState()
  end
end
function Attributes:SetBonusPoints(data)
  if data ~= nil then
    self.bonusPoints = data
  end
end
function Attributes:UpdateRespecState()
  local isEnabled = false
  local canAfford = false
  if self.spentPoints > self.bonusPoints then
    self.respecCost = AttributeRequestBus.Event.GetAttributeRespecCost(self.playerEntityId) or 0
    local ownedCurrency = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Currency.Amount") or 0
    canAfford = ownedCurrency >= self.respecCost
    isEnabled = true
    local tooltipText = "@ui_respec_attributes"
    if not canAfford then
      tooltipText = LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement("@ui_attrib_respec_warning_unaffordable", GetLocalizedCurrency(self.respecCost))
    end
    self.RespecButton:SetTooltip(tooltipText)
  end
  self.RespecButton:SetEnabled(isEnabled and canAfford)
end
function Attributes:TransitionIn()
  self:SetScreenVisible(true)
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Attributes.ScreenChecked", true)
end
function Attributes:TransitionOut()
  self:SetScreenVisible(false)
end
function Attributes:OnShutdown()
  for i, entity in pairs(self.AttributeModifierEntities) do
    UiElementBus.Event.DestroyElement(entity.entityId)
    self.AttributeModifierEntities[i] = nil
  end
  for i, entity in pairs(self.StatRowEntities) do
    UiElementBus.Event.DestroyElement(entity.entityId)
    self.StatRowEntities[i] = nil
  end
  for i, entity in pairs(self.DamageRowEntities) do
    UiElementBus.Event.DestroyElement(entity.entityId)
    self.DamageRowEntities[i] = nil
  end
  self.dataLayer:UnregisterObservers(self)
end
function Attributes:SetAttributeModifierData(entity, data)
  entity:SetName(data.name)
  entity:SetEnum(data.enum)
  entity:SetText(data.text)
  entity:SetTooltip(data.tooltip)
  entity:SetWeaponScalingData(data)
  entity:SetCallbacks(self.IncrementAttribute, self.DecrementAttribute, self)
  self.AttributeModifierEntities[data.itemIndex] = entity
end
function Attributes:OnStatRowSpawned(entity, data)
  entity:SetText(data.text)
  entity:SetName(data.name)
  entity:SetTooltip(data.tooltip)
  entity:SetIsPercent(data.isPercent)
  entity:SetNumberFormat(data.numberFormat)
  entity:SetDivisor(data.divisor)
  if data.floorValue then
    entity:SetFloorValue(data.floorValue)
  end
  if data.roundValue then
    entity:SetRoundValue(data.roundValue)
  end
  if data.dataPath then
    entity:SetDataPath(data.dataPath)
  end
  if data.pendingDataPath then
    entity:SetPendingDataPath(data.pendingDataPath)
  end
  if data.activeDataPath then
    entity:SetActiveDataPath(data.activeDataPath)
  end
  if data.ebusRequest then
    entity:SetEbusRequest(data.ebusRequest)
  end
  self.StatRowEntities[data.itemIndex] = entity
end
function Attributes:OnDamageStatRowSpawned(entity, data)
  entity:SetName(data.name)
  if data.dataPath then
    entity:SetDataPath(data.dataPath)
  end
  if data.numberFormat then
    entity:SetNumberFormat(data.numberFormat)
  end
  if data.pendingDataPath then
    entity:SetPendingDataPath(data.pendingDataPath)
  end
  if data.slotType then
    entity:SetSlotType(data.slotType)
  end
  if data.ebusRequest then
    entity:SetEbusRequest(data.ebusRequest)
  end
  entity:SetHint("quickslot-weapon" .. data.itemIndex)
  self.DamageRowEntities[data.itemIndex] = entity
end
function Attributes:UpdateDamageStats()
  for i, entity in pairs(self.DamageRowEntities) do
    entity:RefreshItemData()
  end
end
function Attributes:OnPointsChanged()
  for i, entity in pairs(self.StatRowEntities) do
    entity:UpdateByEbusRequest()
  end
  self:UpdateDamageStats()
end
function Attributes:ConfirmPoints(entity)
  AttributeRequestBus.Event.ApplyAttributeChanges(self.playerEntityId)
  self:OnPointsChanged()
end
function Attributes:RespecPoints(entity)
  local canRespec = AttributeRequestBus.Event.CanRespec(self.playerEntityId)
  if canRespec then
    local respecWarning = GetLocalizedReplacementText("@ui_attrib_respec_warning", {
      cost = GetLocalizedCurrency(self.respecCost)
    })
    PopupWrapper:RequestPopup(ePopupButtons_YesNo, "@ui_respec_warning_title", respecWarning, "attrib_respec_id", self, self.OnPopupResult)
  end
end
function Attributes:OnPopupResult(result, eventId)
  if eventId == "attrib_respec_id" and result == ePopupResult_Yes then
    AttributeRequestBus.Event.ResetAllAttributePoints(self.playerEntityId)
    self:OnPointsChanged()
  end
end
function Attributes:IncrementAttribute(enumAttribute, amount)
  AttributeRequestBus.Event.AddPendingPointsToAttribute(self.playerEntityId, enumAttribute, amount)
end
function Attributes:DecrementAttribute(enumAttribute, amount)
  AttributeRequestBus.Event.RemovePendingPointsFromAttribute(self.playerEntityId, enumAttribute, amount)
end
return Attributes
