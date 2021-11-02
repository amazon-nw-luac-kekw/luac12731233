local StaticItemDataManager = RequireScript("LyShineUI._Common.StaticItemDataManager")
RequireScript("LyShineUI.FlyoutMenu.FlyoutMenuHelper")
local QualityBar = {
  Properties = {
    NormalBar = {
      default = EntityId()
    },
    FineBar = {
      default = EntityId()
    },
    SuperiorBar = {
      default = EntityId()
    },
    ArtisanBar = {
      default = EntityId()
    },
    FlawlessBar = {
      default = EntityId()
    },
    RollRangeBar = {
      default = EntityId()
    },
    MinGearScoreText = {
      default = EntityId()
    },
    MaxGearScoreText = {
      default = EntityId()
    },
    GearScoreTitleText = {
      default = EntityId()
    },
    TooltipSetter = {
      default = EntityId()
    },
    FlashShort = {
      default = EntityId()
    },
    FlashLong = {
      default = EntityId()
    }
  },
  parent = nil,
  rollRange = 100,
  barMaxValue = 330,
  maxGearScore = 0,
  isUsingTooltip = false
}
local COMMON_THRESH = 1
local UNCOMMON_THRESH = 2
local RARE_THRESH = 3
local EPIC_THRESH = 4
local LEGENDARY_THRESH = 5
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(QualityBar)
function QualityBar:OnInit()
  BaseElement.OnInit(self)
  self.thresholds = {}
  for i = 0, 5 do
    self.thresholds[i + 1] = LocalPlayerUIRequestsBus.Broadcast.GetItemRarityData(i)
  end
  self.thresholds[0] = ItemRarityData()
  self.orderedBars = {
    self.Properties.NormalBar,
    self.Properties.FineBar,
    self.Properties.SuperiorBar,
    self.Properties.ArtisanBar,
    self.Properties.FlawlessBar
  }
  if self.Properties.TooltipSetter:IsValid() then
    self.isUsingTooltip = true
    self.TooltipSetter:SetSimpleTooltip("@crafting_quality_desc")
  end
end
function QualityBar:OnShutdown()
end
function QualityBar:SetRollData(rollData)
  self.recipeData = nil
  self.thresholds[UNCOMMON_THRESH] = Clamp(rollData.percents[2], 0, 100)
  self.thresholds[RARE_THRESH] = Clamp(rollData.percents[3], 0, 100)
  self.thresholds[EPIC_THRESH] = Clamp(rollData.percents[4], 0, 100)
  self.thresholds[LEGENDARY_THRESH] = Clamp(rollData.percents[5], 0, 100)
  self.rollData = rollData
  self.barMaxValue = 100
  UiImageBus.Event.SetColor(self.entityId, rollData.barColor)
  self:UpdateBarPositions()
end
function QualityBar:GetUpdatedRollData()
  return self.rollData
end
function QualityBar:SetRecipeData(recipeData, resultItemId, resultItemTier, ingredients, playFlash)
  self.recipeData = recipeData
  self.resultItemId = resultItemId
  local itemData = ItemDataManagerBus.Broadcast.GetItemData(self.resultItemId)
  self.gearScoreRollRange = GearScoreRange()
  self.gearScoreRollRange.minValue = itemData.gearScoreRange.minValue
  self.gearScoreRollRange.maxValue = itemData.gearScoreRange.maxValue
  if itemData.gearScoreOverride > 0 then
    self.gearScoreRollRange.minValue = itemData.gearScoreOverride
    self.gearScoreRollRange.maxValue = itemData.gearScoreOverride
    self.minGearScoreBonus = 0
    self.maxGearScoreBonus = 0
  else
    local craftingBonusRange = CraftingRequestBus.Broadcast.GetGearScoreBonus(self.recipeData, resultItemTier, self.resultItemId, ingredients)
    self.minGearScoreBonus = craftingBonusRange.minValue - recipeData.baseGearScore
    self.maxGearScoreBonus = craftingBonusRange.maxValue - recipeData.baseGearScore
    if 0 < recipeData.baseGearScore then
      self.gearScoreRollRange.minValue = recipeData.baseGearScore
      self.gearScoreRollRange.maxValue = recipeData.baseGearScore
    end
  end
  self:UpdateGearScores(playFlash)
end
function QualityBar:UpdateGearScores(playFlash)
  local staticItemData = StaticItemDataManager:GetItem(self.resultItemId)
  UiElementBus.Event.SetIsEnabled(self.entityId, staticItemData ~= nil)
  if not staticItemData then
    return
  end
  self.minGearScore = staticItemData.gearScoreRange.minValue
  if self.minGearScoreBonus < 0 then
    self.minGearScore = self.minGearScore + self.minGearScoreBonus
  end
  self.maxGearScore = math.max(staticItemData.gearScoreRange.maxValue, self.gearScoreRollRange.maxValue + self.maxGearScoreBonus)
  if self.minGearScore > self.maxGearScore then
    local tempMax = self.maxGearScore
    self.maxGearScore = self.minGearScore
    self.minGearScore = tempMax
  end
  UiTextBus.Event.SetTextWithFlags(self.Properties.MinGearScoreText, tostring(self.minGearScore), eUiTextSet_SetAsIs)
  UiTextBus.Event.SetTextWithFlags(self.Properties.MaxGearScoreText, tostring(self.maxGearScore), eUiTextSet_SetAsIs)
  self.rollData = {
    percents = {
      0,
      0,
      0,
      0,
      0
    },
    gearScores = {},
    tooltips = {}
  }
  local bars = {
    self.Properties.NormalBar,
    self.Properties.FineBar,
    self.Properties.SuperiorBar,
    self.Properties.ArtisanBar,
    self.Properties.FlawlessBar
  }
  for index, bar in ipairs(bars) do
    local baseMinScore = staticItemData.gearScoreRange.minValue
    local baseMaxScore = staticItemData.gearScoreRange.minValue
    local baseMinPercent = math.max(0, (baseMinScore - self.minGearScore) / (self.maxGearScore - self.minGearScore))
    local baseMaxPercent = math.min(1, (baseMaxScore - self.minGearScore) / (self.maxGearScore - self.minGearScore))
    if index == LEGENDARY_THRESH then
      baseMaxPercent = 1
    end
    local anchors = UiAnchors(baseMinPercent, 0, baseMaxPercent, 1)
    UiTransform2dBus.Event.SetAnchorsScript(bars[index], anchors)
    local descriptor = ItemDescriptor()
    descriptor.itemId = self.resultItemId
    descriptor.gearScore = baseMinScore
    self.rollData.tooltips[index] = {
      itemTable = StaticItemDataManager:GetTooltipDisplayInfo(descriptor, nil),
      itemId = descriptor.itemId
    }
  end
  self:UpdateBarPositions(playFlash)
end
function QualityBar:UpdateBarPositions(playFlash)
  local gearScoreRange = self.maxGearScore - self.minGearScore
  local minimumGearRoll = self.gearScoreRollRange.minValue + self.minGearScoreBonus
  local maximumGearRoll = self.gearScoreRollRange.maxValue + self.maxGearScoreBonus
  local minGearScoreOffsetForLooks = 0
  local maxGearScoreOffsetForLooks = 0
  if maximumGearRoll == minimumGearRoll then
    if maximumGearRoll == self.maxGearScore then
      minGearScoreOffsetForLooks = 1
    else
      maxGearScoreOffsetForLooks = 1
    end
  end
  local anchorLeft = Math.Clamp((minimumGearRoll - minGearScoreOffsetForLooks - self.minGearScore) / gearScoreRange, 0, 1)
  local anchorRight = Math.Clamp((maximumGearRoll + maxGearScoreOffsetForLooks - self.minGearScore) / gearScoreRange, 0, 1)
  local rollBarAnchors = UiAnchors(anchorLeft, 0.5, anchorRight, 0.5)
  if playFlash and self.Properties.FlashShort:IsValid() and self.Properties.FlashLong:IsValid() then
    UiElementBus.Event.SetIsEnabled(self.Properties.FlashShort, true)
    UiElementBus.Event.SetIsEnabled(self.Properties.FlashLong, true)
    self.ScriptedEntityTweener:Play(self.Properties.FlashShort, 0.2, {opacity = 0}, {opacity = 0.8, ease = "QuadOut"})
    self.ScriptedEntityTweener:Play(self.Properties.FlashLong, 0.2, {
      opacity = 0,
      scaleX = 0.6,
      scaleY = 0.6
    }, {
      opacity = 0.8,
      scaleX = 1,
      scaleY = 1,
      ease = "QuadOut"
    })
    self.ScriptedEntityTweener:Play(self.Properties.FlashShort, 1, {opacity = 0.8}, {
      opacity = 0,
      ease = "QuadOut",
      delay = 0.2
    })
    self.ScriptedEntityTweener:Play(self.Properties.FlashLong, 1, {opacity = 0.8}, {
      opacity = 0,
      scaleX = 1,
      scaleY = 1,
      ease = "QuadOut",
      delay = 0.2,
      onComplete = function()
        UiElementBus.Event.SetIsEnabled(self.Properties.FlashShort, false)
        UiElementBus.Event.SetIsEnabled(self.Properties.FlashLong, false)
      end
    })
  end
  local gearScoreText = string.format("%d-%d", minimumGearRoll, maximumGearRoll)
  UiTextBus.Event.SetTextWithFlags(self.Properties.GearScoreTitleText, gearScoreText, eUiTextSet_SetAsIs)
  local bars = {
    {
      bar = self.Properties.NormalBar,
      tooltipJson = self.rollData.tooltips[1],
      typeIndex = 1
    },
    {
      bar = self.Properties.FineBar,
      tooltipJson = self.rollData.tooltips[2],
      typeIndex = 2
    },
    {
      bar = self.Properties.SuperiorBar,
      tooltipJson = self.rollData.tooltips[3],
      typeIndex = 3
    },
    {
      bar = self.Properties.ArtisanBar,
      tooltipJson = self.rollData.tooltips[4],
      typeIndex = 4
    },
    {
      bar = self.Properties.FlawlessBar,
      tooltipJson = self.rollData.tooltips[5],
      typeIndex = 5
    },
    {
      anchors = rollBarAnchors,
      bar = self.Properties.RollRangeBar,
      animates = true
    }
  }
  for k, bar in pairs(bars) do
    if bar.bar:IsValid() then
      if bar.anchors then
        UiElementBus.Event.SetIsEnabled(bar.bar, bar.anchors.right > bar.anchors.left)
      end
      if bar.animates then
        do
          local anchorsStart = UiTransform2dBus.Event.GetAnchors(bar.bar)
          self.ScriptedEntityTweener:Play(bar.bar, 0.3, {
            scaleX = 1,
            ease = "QuadOut",
            onUpdate = function(currentValue, currentProgressPercent)
              local anchorLeft = Lerp(anchorsStart.left, bar.anchors.left, currentProgressPercent)
              local anchorTop = Lerp(anchorsStart.top, bar.anchors.top, currentProgressPercent)
              local anchorRight = Lerp(anchorsStart.right, bar.anchors.right, currentProgressPercent)
              local anchorBottom = Lerp(anchorsStart.bottom, bar.anchors.bottom, currentProgressPercent)
              local anchorsThisFrame = UiAnchors(anchorLeft, anchorTop, anchorRight, anchorBottom)
              UiTransform2dBus.Event.SetAnchorsScript(bar.bar, anchorsThisFrame)
            end,
            onComplete = function()
              UiTransform2dBus.Event.SetAnchorsScript(bar.bar, bar.anchors)
            end
          })
        end
      elseif bar.anchors then
        UiTransform2dBus.Event.SetAnchorsScript(bar.bar, bar.anchors)
      end
    end
  end
end
function QualityBar:GetMaxGearScoreRoll()
  if self.gearScoreRollRange then
    return self.gearScoreRollRange.maxValue + self.maxGearScoreBonus
  end
  return 0
end
function QualityBar:OnFocus()
  if not self.isUsingTooltip then
    return
  end
  self.TooltipSetter:OnTooltipSetterHoverStart()
end
function QualityBar:OnUnfocus()
  if not self.isUsingTooltip then
    return
  end
  self.TooltipSetter:OnTooltipSetterHoverEnd()
end
function QualityBar:UpdateBarHighlights(position)
  local bars = {
    self.NormalBar,
    self.FineBar,
    self.SuperiorBar,
    self.ArtisanBar,
    self.FlawlessBar
  }
  local highlightedBar
  for i = 1, #bars do
    local anchor = UiTransform2dBus.Event.GetAnchors(bars[i].entityId)
    if position >= anchor.left and position < anchor.right then
      local highlight = UiElementBus.Event.FindChildByName(bars[i].entityId, "Highlight")
      UiElementBus.Event.SetIsEnabled(highlight, true)
      highlightedBar = bars[i]
    else
      local highlight = UiElementBus.Event.FindChildByName(bars[i].entityId, "Highlight")
      UiElementBus.Event.SetIsEnabled(highlight, false)
    end
  end
  return highlightedBar
end
function QualityBar:ClearBarHighlights()
  local bars = {
    self.NormalBar,
    self.FineBar,
    self.SuperiorBar,
    self.ArtisanBar,
    self.FlawlessBar
  }
  for i = 1, #bars do
    local highlight = UiElementBus.Event.FindChildByName(bars[i].entityId, "Highlight")
    UiElementBus.Event.SetIsEnabled(highlight, false)
  end
end
function QualityBar:GetMaxAffixLevel()
  for i = 1, #self.rollData.gearScores do
    if tonumber(self.rollData.gearScores[i]) == self.maxGearScore then
      return i
    end
  end
  return 1
end
function QualityBar:GetGearScoreRollRange()
  local gearScoreRange = GearScoreRange()
  gearScoreRange.minValue = self.gearScoreRollRange.minValue + self.minGearScoreBonus
  gearScoreRange.maxValue = self.gearScoreRollRange.maxValue + self.maxGearScoreBonus
  return gearScoreRange
end
return QualityBar
