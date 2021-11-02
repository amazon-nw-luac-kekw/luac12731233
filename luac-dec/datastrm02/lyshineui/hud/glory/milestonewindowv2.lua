local CanvasCommon = RequireScript("LyShineUI._Common.CanvasCommon")
local MilestoneWindowV2 = {
  Properties = {
    FrameHeader = {
      default = EntityId()
    },
    Frame = {
      default = EntityId()
    },
    CloseButton = {
      default = EntityId()
    },
    MilestonesScrollbox = {
      default = EntityId()
    },
    MilestonesContainer = {
      default = EntityId()
    },
    MilestoneLevelPrototype = {
      default = EntityId()
    },
    LevelLine = {
      default = EntityId()
    },
    LineMask = {
      default = EntityId()
    },
    LevelFill = {
      default = EntityId()
    },
    CurrentLevelContainer = {
      default = EntityId()
    },
    CurrentLevelText = {
      default = EntityId()
    },
    CurrentLevelTextLabel = {
      default = EntityId()
    },
    ScreenScrim = {
      default = EntityId()
    },
    ContentContainer = {
      default = EntityId()
    }
  },
  clonedElements = {},
  milestones = {},
  previousMilestoneLevel = 0,
  nextMilestoneLevel = 0
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(MilestoneWindowV2)
local tweenerCommon = RequireScript("LyShineUI._Common.ScriptedEntityTweenerCommon")
function MilestoneWindowV2:OnInit()
  self.canvasId = UiElementBus.Event.GetCanvas(self.entityId)
  self.FrameHeader:SetTextAlignment(self.FrameHeader.TEXT_ALIGN_CENTER)
  self.FrameHeader:SetText("@ui_milestone_rewards")
  self.CloseButton:SetCallback(self.OnClose, self)
  self.milestoneLevelWidth = UiTransform2dBus.Event.GetLocalWidth(self.Properties.MilestoneLevelPrototype)
  self.milestoneLevelHalfWidth = self.milestoneLevelWidth / 2
  self.levelContainerHalfWidth = UiTransform2dBus.Event.GetLocalWidth(self.Properties.CurrentLevelContainer) / 2
  self.containerHalfWidth = UiTransform2dBus.Event.GetLocalWidth(self.Properties.ContentContainer) / 2
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.PlayerEntityId", function(self, playerEntityId)
    if not playerEntityId then
      return
    end
    self.playerEntityId = playerEntityId
    self:InitMilestoneData()
  end)
  SetTextStyle(self.Properties.CurrentLevelText, self.UIStyle.FONT_STYLE_MILESTONE_CURRENT_LEVEL)
  SetTextStyle(self.Properties.CurrentLevelTextLabel, self.UIStyle.FONT_STYLE_MILESTONE_CURRENT_LEVEL_LABEL)
  self.initialDrawOrder = UiCanvasBus.Event.GetDrawOrder(self.canvasId)
end
function MilestoneWindowV2:OnShutdown()
  if self.milestoneHandler then
    DynamicBus.MilestoneWindow.Disconnect(self.entityId, self)
    self.milestoneHandler = nil
  end
  for i = 1, #self.clonedElements do
    UiElementBus.Event.DestroyElement(self.clonedElements[i].entityId)
  end
  self.clonedElements = {}
end
function MilestoneWindowV2:InitMilestoneData()
  local milestoneIds = PlayerComponentRequestsBus.Event.GetRewardMilestoneIds(self.playerEntityId)
  for i = 1, #milestoneIds do
    local milestoneData = PlayerComponentRequestsBus.Event.GetRewardMilestoneData(self.playerEntityId, milestoneIds[i])
    if milestoneData:IsValid() then
      self:AddLevelData(milestoneData)
    end
  end
  local posY = 120
  self.totalWidth = 0
  for _, milestoneLevelData in ipairs(self.milestones) do
    local clonedElement = CloneUiElement(self.canvasId, self.registrar, self.Properties.MilestoneLevelPrototype, self.Properties.MilestonesContainer, true)
    table.insert(self.clonedElements, clonedElement)
    clonedElement:SetLevel(milestoneLevelData.level)
    clonedElement:SetRewardData(milestoneLevelData.data)
    milestoneLevelData.entity = clonedElement
    UiTransformBus.Event.SetLocalPosition(clonedElement.entityId, Vector2(self.totalWidth, posY))
    self.totalWidth = self.totalWidth + self.milestoneLevelWidth
  end
  UiTransform2dBus.Event.SetLocalWidth(self.Properties.MilestonesContainer, self.totalWidth)
  local levelLineWidth = self.totalWidth - self.milestoneLevelHalfWidth - self.levelContainerHalfWidth
  UiTransform2dBus.Event.SetLocalWidth(self.Properties.LevelLine, levelLineWidth)
  UiTransform2dBus.Event.SetLocalWidth(self.Properties.LineMask, self.totalWidth - self.milestoneLevelHalfWidth)
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.MilestoneWindowReady", true)
end
function MilestoneWindowV2:SetEnabled(isEnabled)
  if isEnabled then
    self.milestoneHandler = DynamicBus.MilestoneWindow.Connect(self.entityId, self)
  else
    UiElementBus.Event.SetIsEnabled(self.entityId, false)
    self.isVisible = false
    if self.milestoneHandler then
      DynamicBus.MilestoneWindow.Disconnect(self.entityId, self)
      self.milestoneHandler = nil
    end
  end
end
function MilestoneWindowV2:SetVisible(isVisible)
  if self.isVisible == isVisible then
    return
  end
  self.isVisible = isVisible
  if isVisible then
    UiCanvasBus.Event.SetDrawOrder(self.canvasId, CanvasCommon.POPUP_DRAW_ORDER - 1)
    UiElementBus.Event.SetIsEnabled(self.entityId, true)
    self.ScriptedEntityTweener:Play(self.Properties.ContentContainer, 0.3, {opacity = 0, y = -10}, {
      opacity = 1,
      y = 0,
      ease = "QuadOut",
      delay = 0.2
    })
    self.ScriptedEntityTweener:Play(self.Properties.ScreenScrim, 0.5, {opacity = 0}, {opacity = 1, ease = "QuadOut"})
    local currentLevelContainerPosX = UiTransformBus.Event.GetLocalPositionX(self.Properties.CurrentLevelContainer)
    local scrollOffsetX = currentLevelContainerPosX - self.containerHalfWidth
    UiScrollBoxBus.Event.SetScrollOffsetX(self.Properties.MilestonesScrollbox, -scrollOffsetX)
  else
    self.ScriptedEntityTweener:Stop(self.Properties.ScreenScrim)
    self.ScriptedEntityTweener:Stop(self.Properties.ContentContainer)
    self.ScriptedEntityTweener:Play(self.Properties.ScreenScrim, 0.15, {opacity = 0, ease = "QuadOut"})
    self.ScriptedEntityTweener:Play(self.Properties.ContentContainer, 0.15, {
      opacity = 0,
      ease = "QuadOut",
      onComplete = function()
        UiElementBus.Event.SetIsEnabled(self.entityId, false)
        UiCanvasBus.Event.SetDrawOrder(self.canvasId, self.initialDrawOrder)
      end
    })
  end
end
function MilestoneWindowV2:AddLevelData(milestoneData)
  if milestoneData.level <= 1 then
    return
  end
  local dataTable = self:GetDataFromLevel(milestoneData.level)
  if not dataTable then
    table.insert(self.milestones, {
      level = milestoneData.level,
      data = {}
    })
    dataTable = self.milestones[#self.milestones].data
    local compare = function(a, b)
      return a.level < b.level
    end
    table.sort(self.milestones, compare)
  end
  table.insert(dataTable, milestoneData)
end
function MilestoneWindowV2:GetDataFromLevel(level)
  for _, data in ipairs(self.milestones) do
    if data.level == level then
      return data.data
    end
  end
  return nil
end
function MilestoneWindowV2:IsMilestoneLevel(level)
  for _, data in ipairs(self.milestones) do
    if data.level == level then
      return true
    end
  end
  return false
end
function MilestoneWindowV2:SetCurrentLevel(level)
  local currentLevelText = GetLocalizedReplacementText("@ui_milestone_current_level", {level = level})
  UiTextBus.Event.SetText(self.Properties.CurrentLevelText, currentLevelText)
  local previousMilestoneLevel = 0
  local previousMilestonePosX = 0
  local nextMilestoneLevel = 0
  local nextMilestonePosX = 0
  local hasFoundNextMilestone = false
  for _, milestoneData in ipairs(self.milestones) do
    if level >= milestoneData.level then
      milestoneData.entity:SetDisplayState(milestoneData.entity.DISPLAY_STATE_UNLOCKED)
      previousMilestonePosX = UiTransformBus.Event.GetLocalPositionX(milestoneData.entity.entityId)
      previousMilestoneLevel = milestoneData.level
    elseif not hasFoundNextMilestone then
      hasFoundNextMilestone = true
      milestoneData.entity:SetDisplayState(milestoneData.entity.DISPLAY_STATE_NEXT)
      nextMilestonePosX = UiTransformBus.Event.GetLocalPositionX(milestoneData.entity.entityId)
      nextMilestoneLevel = milestoneData.level
    else
      milestoneData.entity:SetDisplayState(milestoneData.entity.DISPLAY_STATE_LOCKED)
    end
  end
  local levelPercent = 0
  local currentLevelContainerPosX = 0
  if hasFoundNextMilestone then
    levelPercent = (level - previousMilestoneLevel) / (nextMilestoneLevel - previousMilestoneLevel)
    if 0 < previousMilestoneLevel then
      currentLevelContainerPosX = previousMilestonePosX + levelPercent * self.milestoneLevelWidth + self.milestoneLevelHalfWidth
    else
      currentLevelContainerPosX = levelPercent * self.milestoneLevelHalfWidth
    end
  else
    if level > previousMilestoneLevel then
      levelPercent = 0.2
    end
    currentLevelContainerPosX = previousMilestonePosX + levelPercent * self.milestoneLevelWidth + self.milestoneLevelHalfWidth
  end
  currentLevelContainerPosX = Math.Clamp(currentLevelContainerPosX, self.levelContainerHalfWidth, self.totalWidth - self.levelContainerHalfWidth)
  UiTransformBus.Event.SetLocalPositionX(self.Properties.CurrentLevelContainer, currentLevelContainerPosX)
  UiTransform2dBus.Event.SetLocalWidth(self.Properties.LevelFill, currentLevelContainerPosX)
  return nextMilestoneLevel
end
function MilestoneWindowV2:GetNextMilestoneForLevel(currentLevel)
  for _, milestoneData in ipairs(self.milestones) do
    if currentLevel < milestoneData.level then
      return milestoneData.level
    end
  end
  return 0
end
function MilestoneWindowV2:OnClose()
  self:SetVisible(false)
end
return MilestoneWindowV2
