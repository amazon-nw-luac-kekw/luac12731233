local WeaponMasteryRow = {
  Properties = {
    Highlight = {
      default = EntityId()
    },
    Frame = {
      default = EntityId()
    },
    Title = {
      default = EntityId()
    },
    Icon = {
      default = EntityId()
    },
    CurrentLevel = {
      default = EntityId()
    },
    AbilitySlot1 = {
      default = EntityId()
    },
    AbilitySlot2 = {
      default = EntityId()
    },
    AbilitySlot3 = {
      default = EntityId()
    },
    AbilityIconBg1 = {
      default = EntityId()
    },
    AbilityIconBg2 = {
      default = EntityId()
    },
    AbilityIconBg3 = {
      default = EntityId()
    },
    AbilityIcon1 = {
      default = EntityId()
    },
    AbilityIcon2 = {
      default = EntityId()
    },
    AbilityIcon3 = {
      default = EntityId()
    },
    BarFill = {
      default = EntityId()
    },
    PointsAvailable = {
      default = EntityId()
    },
    PointsAvailableBorder = {
      default = EntityId()
    },
    PointsAvailableBg = {
      default = EntityId()
    },
    OwnershipHint = {
      default = EntityId()
    },
    OwnershipIcon = {
      default = EntityId()
    }
  },
  LOCKED_ABILITY_ICON = "LyshineUI\\Images\\Icons\\Misc\\icon_lock_big.png",
  ABILITY_ICON_PATH = "lyShineui/images/icons/abilities/",
  barWidth = 68,
  abilitySlotCount = 3
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(WeaponMasteryRow)
local AbilitiesCommon = RequireScript("LyShineUI._Common.AbilitiesCommon")
local tweenerCommon = RequireScript("LyShineUI._Common.ScriptedEntityTweenerCommon")
function WeaponMasteryRow:OnInit()
  BaseElement.OnInit(self)
  UiElementBus.Event.SetIsEnabled(self.Properties.OwnershipHint, false)
  self.barWidth = UiTransform2dBus.Event.GetLocalWidth(self.Properties.BarFill)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.PlayerEntityId", function(self, playerEntityId)
    self.playerEntityId = playerEntityId
  end)
  self.pointsAvailableBorderTimeline = self.ScriptedEntityTweener:TimelineCreate()
  self.pointsAvailableBorderTimeline:Add(self.Properties.PointsAvailableBorder, 0.35, {opacity = 0.8, ease = "QuadOut"})
  self.pointsAvailableBorderTimeline:Add(self.Properties.PointsAvailableBorder, 0.05, {opacity = 0.8})
  self.pointsAvailableBorderTimeline:Add(self.Properties.PointsAvailableBorder, 0.6, {
    opacity = 0.4,
    ease = "QuadInOut",
    onComplete = function()
      self.pointsAvailableBorderTimeline:Play()
    end
  })
end
function WeaponMasteryRow:OnShutdown()
  if self.pointsAvailableBorderTimeline then
    self.ScriptedEntityTweener:TimelineDestroy(self.pointsAvailableBorderTimeline)
  end
end
function WeaponMasteryRow:Update()
  local unspentPoints = ProgressionPointRequestBus.Event.GetUnallocatedPoolPoints(self.playerEntityId, self.tableNameId)
  self.hasUnspentPoints = 0 < unspentPoints
  UiElementBus.Event.SetIsEnabled(self.Properties.PointsAvailable, self.hasUnspentPoints)
  if self.hasUnspentPoints then
    UiTextBus.Event.SetText(self.Properties.PointsAvailable, tostring(unspentPoints or 0))
    UiTextBus.Event.SetColor(self.Properties.PointsAvailable, self.UIStyle.COLOR_MASTERY)
  end
  self:SetPointsAvailableTimelinePlaying(self.hasUnspentPoints)
  local maxRank = CategoricalProgressionRequestBus.Event.GetMaxRank(self.playerEntityId, self.tableNameId)
  local currentLevel = CategoricalProgressionRequestBus.Event.GetRank(self.playerEntityId, self.tableNameId)
  UiTextBus.Event.SetText(self.Properties.CurrentLevel, currentLevel + 1)
  local currentProgress = CategoricalProgressionRequestBus.Event.GetProgression(self.playerEntityId, self.tableNameId)
  local requiredProgress = CategoricalProgressionRequestBus.Event.GetMaxPointsForRank(self.playerEntityId, self.tableNameId, currentLevel)
  if 0 < requiredProgress and maxRank > currentLevel then
    local barPercent = currentProgress / requiredProgress * self.barWidth
    UiTransform2dBus.Event.SetLocalWidth(self.Properties.BarFill, barPercent)
  else
    UiTransform2dBus.Event.SetLocalWidth(self.Properties.BarFill, self.barWidth)
  end
  local abilities = CharacterAbilityRequestBus.Event.GetActiveAbilityMoveDataByAbilityTableId(self.playerEntityId, self.tableNameId)
  for i = 1, self.abilitySlotCount do
    local abilityElement = self.Properties["AbilitySlot" .. i]
    local abilityIconBg = self.Properties["AbilityIconBg" .. i]
    local abilityIcon = self.Properties["AbilityIcon" .. i]
    if i < #abilities then
      local displayIcon = AbilitiesCommon.emptyIcon
      local bgPath = AbilitiesCommon:GetBackgroundPath(nil)
      if abilities[i] then
        displayIcon = self.ABILITY_ICON_PATH .. abilities[i].displayIcon .. ".png"
        bgPath = AbilitiesCommon:GetBackgroundPath(abilities[i].uiCategory)
        UiTransformBus.Event.SetScale(abilityIcon, Vector2(1, 1))
        self.ScriptedEntityTweener:Set(abilityElement, {opacity = 1})
      end
      UiImageBus.Event.SetSpritePathname(abilityIcon, displayIcon)
      UiImageBus.Event.SetSpritePathname(abilityIconBg, bgPath)
    else
      UiElementBus.Event.SetIsEnabled(abilityIcon, true)
      UiImageBus.Event.SetSpritePathname(abilityIcon, self.LOCKED_ABILITY_ICON)
      UiTransformBus.Event.SetScale(abilityIcon, Vector2(0.65, 0.65))
      self.ScriptedEntityTweener:Set(abilityElement, {opacity = 0.3})
    end
  end
end
function WeaponMasteryRow:SetTableInfo(tableName, tableIndex)
  self.tableName = tableName
  self.tableIndex = tableIndex
end
function WeaponMasteryRow:SetAbilityTableId(tableNameId)
  self.tableNameId = tableNameId
end
function WeaponMasteryRow:SetText(text)
  UiTextBus.Event.SetTextWithFlags(self.Properties.Title, text, eUiTextSet_SetLocalized)
end
function WeaponMasteryRow:SetTooltip(value)
  self.Frame:SetSimpleTooltip(value)
end
function WeaponMasteryRow:SetIcon(icon)
  self.icon = icon
  UiImageBus.Event.SetSpritePathname(self.Properties.Icon, icon)
end
function WeaponMasteryRow:SetCallback(cbTable, cbFunc)
  self.cbTable = cbTable
  self.cbFunc = cbFunc
end
function WeaponMasteryRow:SetIsVisible(isVisible, animDelay)
  if isVisible == self.isVisible then
    return
  end
  self.isVisible = isVisible
  if not isVisible then
    if self.highlightTimeline then
      self.highlightTimeline:Stop()
      UiElementBus.Event.SetIsEnabled(self.Properties.Highlight, false)
    end
    self:SetPointsAvailableTimelinePlaying(false)
  else
    animDelay = animDelay or 0
    self.ScriptedEntityTweener:PlayFromC(self.entityId, 0.5, {opacity = 0}, tweenerCommon.fadeInQuadOut, animDelay)
    self:SetPointsAvailableTimelinePlaying(self.hasUnspentPoints)
  end
end
function WeaponMasteryRow:SetPointsAvailableTimelinePlaying(isPlaying)
  UiElementBus.Event.SetIsEnabled(self.Properties.PointsAvailableBorder, isPlaying)
  UiElementBus.Event.SetIsEnabled(self.Properties.PointsAvailableBg, isPlaying)
  if isPlaying then
    self.pointsAvailableBorderTimeline:Play()
    self.ScriptedEntityTweener:PlayFromC(self.Properties.PointsAvailableBg, 10, {rotation = 0}, tweenerCommon.rotateCCWInfinite)
  else
    self.pointsAvailableBorderTimeline:Stop()
    self.ScriptedEntityTweener:Stop(self.Properties.PointsAvailableBg)
  end
end
function WeaponMasteryRow:OnClick()
  if self.cbTable and self.cbFunc then
    self.cbFunc(self.cbTable, self.tableName, self.tableIndex)
  end
  self.audioHelper:PlaySound(self.audioHelper.WeaponMastery_WeaponClick)
end
function WeaponMasteryRow:OnFocus()
  self.Frame:OnTooltipSetterHoverStart()
  local animTime = self.UIStyle.DURATION_BUTTON_FADE_IN
  self.ScriptedEntityTweener:PlayC(self.Properties.Frame, animTime, tweenerCommon.imgToWhite)
  self.ScriptedEntityTweener:PlayC(self.Properties.Icon, animTime, tweenerCommon.imgToGray80)
  self.ScriptedEntityTweener:PlayC(self.Properties.Title, animTime, tweenerCommon.textToWhite)
  if self.hasUnspentPoints then
    self.ScriptedEntityTweener:PlayC(self.Properties.PointsAvailable, animTime, tweenerCommon.textToWhite)
  end
  if not self.highlightTimeline then
    self.highlightTimeline = self.ScriptedEntityTweener:TimelineCreate()
    self.highlightTimeline:Add(self.Properties.Highlight, self.UIStyle.DURATION_TIMELINE_FADE_OUT, {opacity = 0.6})
    self.highlightTimeline:Add(self.Properties.Highlight, self.UIStyle.DURATION_TIMELINE_FADE_IN, {opacity = 1})
    self.highlightTimeline:Add(self.Properties.Highlight, self.UIStyle.DURATION_TIMELINE_HOLD, {
      opacity = 1,
      onComplete = function()
        self.highlightTimeline:Play()
      end
    })
  end
  UiElementBus.Event.SetIsEnabled(self.Properties.Highlight, true)
  self.ScriptedEntityTweener:Play(self.Properties.Highlight, animTime, {opacity = 1, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.Properties.Highlight, self.UIStyle.DURATION_BUTTON_FADE_IN_HOLD, {
    opacity = 1,
    delay = animTime,
    onComplete = function()
      self.highlightTimeline:Play()
    end
  })
  self.audioHelper:PlaySound(self.audioHelper.WeaponMastery_WeaponHover)
end
function WeaponMasteryRow:OnUnfocus()
  self.Frame:OnTooltipSetterHoverEnd()
  local animTime = self.UIStyle.DURATION_BUTTON_FADE_OUT
  self.ScriptedEntityTweener:PlayC(self.Properties.Frame, animTime, tweenerCommon.imgToTan)
  self.ScriptedEntityTweener:PlayC(self.Properties.Icon, animTime, tweenerCommon.imgToTan)
  self.ScriptedEntityTweener:PlayC(self.Properties.Title, animTime, tweenerCommon.textToGray80)
  if self.hasUnspentPoints then
    self.ScriptedEntityTweener:PlayC(self.Properties.PointsAvailable, animTime, tweenerCommon.textToMastery)
  end
  self.highlightTimeline:Stop()
  self.ScriptedEntityTweener:PlayC(self.Properties.Highlight, animTime, tweenerCommon.fadeOutQuadOut, nil, function()
    UiElementBus.Event.SetIsEnabled(self.Properties.Highlight, false)
  end)
end
return WeaponMasteryRow
