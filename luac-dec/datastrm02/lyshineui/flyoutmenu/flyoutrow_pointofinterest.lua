local FlyoutRow_PointOfInterest = {
  Properties = {
    ContentContainer = {
      default = EntityId()
    },
    Image = {
      default = EntityId()
    },
    ImageMask = {
      default = EntityId()
    },
    HeaderText = {
      default = EntityId()
    },
    DescriptionText = {
      default = EntityId()
    },
    StatusText = {
      default = EntityId()
    },
    DungeonReqsBox = {
      default = EntityId()
    },
    WaitingMessage = {
      default = EntityId()
    },
    LevelRecText = {
      default = EntityId()
    },
    LevelRecIcon = {
      default = EntityId()
    },
    MinPlayersText = {
      default = EntityId()
    },
    MinPlayersIcon = {
      default = EntityId()
    },
    DungeonTimers = {
      default = EntityId()
    },
    EstimatedTimerText = {
      default = EntityId()
    },
    EstimatedMins = {
      default = EntityId()
    },
    EstimatedSecs = {
      default = EntityId()
    },
    ElapsedTimerText = {
      default = EntityId()
    },
    ElapsedMins = {
      default = EntityId()
    },
    ElapsedSecs = {
      default = EntityId()
    },
    TimerSpinner = {
      default = EntityId()
    }
  },
  DEFAULT_BACKGROUND = "lyShineui/images/map/tooltipimages/mapTooltip_territory_default.png",
  groupMemberCount = 0
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(FlyoutRow_PointOfInterest)
local TimeHelpers = RequireScript("LyShineUI._Common.TimeHelperFunctions")
local TimingUtils = RequireScript("LyShineUI._Common.TimingUtils")
local mapTypes = RequireScript("LyShineUI._Common.MapTypes")
function FlyoutRow_PointOfInterest:OnInit()
  BaseElement.OnInit(self)
  self.sizingProperties = {
    self.Properties.HeaderText,
    self.Properties.DescriptionText,
    self.Properties.StatusText,
    self.Properties.MinPlayersText,
    self.Properties.LevelRecText,
    self.Properties.DungeonTimers
  }
  self.panelTypes = mapTypes.panelTypes
  self.canvasId = UiElementBus.Event.GetCanvas(self.entityId)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Group.MemberCount", function(self, memberCount)
    if not memberCount then
      return
    end
    self.groupMemberCount = memberCount
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Group.Id", function(self, groupId)
    if not groupId then
      return
    end
    self.groupId = groupId
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Progression.Level", function(self, playerLevel)
    if not playerLevel then
      return
    end
    self.playerLevel = playerLevel
  end)
end
function FlyoutRow_PointOfInterest:SetData(data)
  if not (data and data.header) or not data.subtext then
    Log("[FlyoutRow_PointOfInterest] Error: invalid data passed to SetData")
    return
  end
  self.outpostId = data.outpostId
  self.header = data.header
  self.bottomPadding = data.bottomPadding
  UiTextBus.Event.SetTextWithFlags(self.Properties.HeaderText, data.header, eUiTextSet_SetLocalized)
  SetTextStyle(self.Properties.HeaderText, self.UIStyle.FONT_STYLE_FLYOUT_MAP_POI_HEADER)
  UiTextBus.Event.SetTextWithFlags(self.Properties.DescriptionText, data.subtext, eUiTextSet_SetLocalized)
  SetTextStyle(self.Properties.DescriptionText, self.UIStyle.FONT_STYLE_FLYOUT_MAP_POI_SUBTEXT)
  local descTextHeight = UiTextBus.Event.GetTextHeight(self.Properties.DescriptionText)
  UiLayoutCellBus.Event.SetTargetHeight(self.Properties.StatusText, descTextHeight)
  local hasRecommendLevel = data.recommendedLevel ~= nil
  local hasMinimumPlayers = data.minimumPlayers ~= nil
  UiElementBus.Event.SetIsEnabled(self.Properties.DungeonReqsBox, hasRecommendLevel or hasMinimumPlayers)
  UiElementBus.Event.SetIsEnabled(self.Properties.MinPlayersText, hasMinimumPlayers)
  UiElementBus.Event.SetIsEnabled(self.Properties.MinPlayersIcon, hasMinimumPlayers)
  UiElementBus.Event.SetIsEnabled(self.Properties.LevelRecText, hasRecommendLevel)
  if hasRecommendLevel or hasMinimumPlayers then
    if hasMinimumPlayers then
      local minGroupSizeMet = self.groupMemberCount >= data.minimumPlayers
      local groupSizeLoc = data.showDungeonInfo and "@ui_dungeon_requirements_groupsize" or "@ui_flyout_recommended_groupsize"
      local minPlayersText = GetLocalizedReplacementText(groupSizeLoc, {
        players = data.minimumPlayers
      })
      UiTextBus.Event.SetTextWithFlags(self.Properties.MinPlayersText, minPlayersText, eUiTextSet_SetAsIs)
      SetTextStyle(self.Properties.MinPlayersText, minGroupSizeMet and self.UIStyle.STANDARD_BODY_TEXT_GREEN or self.UIStyle.STANDARD_BODY_TEXT_RED)
      UiImageBus.Event.SetColor(self.Properties.MinPlayersIcon, minGroupSizeMet and self.UIStyle.COLOR_GREEN_BRIGHT or self.UIStyle.COLOR_RED_LIGHT)
    end
    if hasRecommendLevel then
      local recommendedLevelMet = self.playerLevel >= data.recommendedLevel
      local recommendedLevelText = GetLocalizedReplacementText("@ui_dungeon_requirements_gearscore", {
        level = data.recommendedLevel
      })
      UiTextBus.Event.SetTextWithFlags(self.Properties.LevelRecText, recommendedLevelText, eUiTextSet_SetAsIs)
      SetTextStyle(self.Properties.LevelRecText, recommendedLevelMet and self.UIStyle.STANDARD_BODY_TEXT_GREEN or self.UIStyle.STANDARD_BODY_TEXT_RED)
      UiImageBus.Event.SetColor(self.Properties.LevelRecIcon, recommendedLevelMet and self.UIStyle.COLOR_GREEN_BRIGHT or self.UIStyle.COLOR_RED_LIGHT)
    end
  end
  local showStatusText = data.statusText ~= nil
  UiElementBus.Event.SetIsEnabled(self.Properties.StatusText, showStatusText)
  if showStatusText then
    UiTextBus.Event.SetTextWithFlags(self.Properties.StatusText, data.statusText, eUiTextSet_SetLocalized)
    SetTextStyle(self.Properties.StatusText, self.UIStyle.FONT_STYLE_FLYOUT_MAP_POI_STATUSTEXT)
    local textHeight = UiTextBus.Event.GetTextHeight(self.Properties.StatusText)
    UiLayoutCellBus.Event.SetTargetHeight(self.Properties.StatusText, textHeight)
    if data.statusColor then
      UiTextBus.Event.SetColor(self.Properties.StatusText, data.statusColor)
    end
  end
  local isInGroup = self.groupId and self.groupId:IsValid()
  local groupDungeonInstanceState = DungeonInstanceState_NoDungeon
  local showDungeonTimers = false
  if isInGroup then
    groupDungeonInstanceState = GroupDataRequestBus.Event.GetGroupDungeonInstanceState(self.groupId)
    showDungeonTimers = groupDungeonInstanceState == DungeonInstanceState_Queued and data.showDungeonInfo
  end
  UiElementBus.Event.SetIsEnabled(self.Properties.DungeonTimers, showDungeonTimers)
  if showDungeonTimers then
    local estimatedTimerTextWidth = UiTextBus.Event.GetTextWidth(self.Properties.EstimatedTimerText)
    local elapsedTimerTextWidth = UiTextBus.Event.GetTextWidth(self.Properties.ElapsedTimerText)
    local maxTimerLabelWidth = math.max(estimatedTimerTextWidth, elapsedTimerTextWidth)
    UiTransform2dBus.Event.SetLocalWidth(self.Properties.EstimatedTimerText, maxTimerLabelWidth)
    UiTransform2dBus.Event.SetLocalWidth(self.Properties.ElapsedTimerText, maxTimerLabelWidth)
    SetTextStyle(self.Properties.WaitingMessage, self.UIStyle.STANDARD_BODY_TEXT)
    SetTextStyle(self.Properties.ElapsedTimerText, self.UIStyle.STANDARD_BODY_TEXT)
    SetTextStyle(self.Properties.EstimatedTimerText, self.UIStyle.STANDARD_BODY_TEXT)
    self.ScriptedEntityTweener:Play(self.Properties.TimerSpinner, 2.5, {rotation = 0}, {timesToPlay = -1, rotation = 359})
    if isInGroup then
      local now = TimeHelpers:ServerNow()
      local startTime = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.QueueStartTime")
      local elapsedTime = startTime == nil and 0 or now:SubtractSeconds(startTime):ToSeconds()
      local estimatedTime = GroupDataRequestBus.Event.GetDungeonRemainingEnterTime(self.groupId) + elapsedTime
      self:SetTimerText(estimatedTime, "EstimatedMins", "EstimatedSecs")
      self:SetTimerText(elapsedTime, "ElapsedMins", "ElapsedSecs")
      TimingUtils:Delay(1, self, function(self)
        local groupDungeonInstanceState = GroupDataRequestBus.Event.GetGroupDungeonInstanceState(self.groupId)
        local now = TimeHelpers:ServerNow()
        local startTime = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.QueueStartTime")
        local elapsedTime = startTime == nil and 0 or now:SubtractSeconds(startTime):ToSeconds()
        self:SetTimerText(elapsedTime, "ElapsedMins", "ElapsedSecs")
        local canvasId = UiElementBus.Event.GetCanvas(self.entityId)
        local canvasEnabled = UiCanvasBus.Event.GetEnabled(canvasId)
        local isStillEnabled = UiElementBus.Event.GetAreElementAndAncestorsEnabled(self.entityId)
        if not (isStillEnabled and canvasEnabled) or groupDungeonInstanceState ~= DungeonInstanceState_Queued then
          TimingUtils:StopDelay(self)
          showDungeonTimers = false
          UiElementBus.Event.SetIsEnabled(self.Properties.DungeonTimers, false)
          self:SizeToEnabledContentItems()
        end
      end, true)
    end
  end
  UiImageBus.Event.SetSpritePathname(self.Properties.Image, data.tooltipBackground or self.DEFAULT_BACKGROUND)
  self:SizeToEnabledContentItems()
end
function FlyoutRow_PointOfInterest:OnViewOutpostStorage()
  DynamicBus.Map.Broadcast.OnShowPanel(self.panelTypes.Storage, self.outpostId, self.header)
end
function FlyoutRow_PointOfInterest:SizeToEnabledContentItems()
  self.flyoutSize = 0
  local flyoutheight = 0
  local bottomPadding = self.bottomPadding or 20
  local minimumFlyoutHeight = 114
  local spacing = 5
  for i, prop in ipairs(self.sizingProperties) do
    if UiElementBus.Event.IsEnabled(prop) then
      local getPropHeight = UiTransform2dBus.Event.GetLocalHeight(prop) or 0
      local getPropTextHeight = UiTextBus.Event.GetTextHeight(prop) or 0
      local minPropSize = math.max(getPropHeight, getPropTextHeight)
      flyoutheight = flyoutheight + minPropSize + spacing
    end
  end
  self.flyoutSize = math.max(flyoutheight + bottomPadding, minimumFlyoutHeight)
  UiLayoutCellBus.Event.SetTargetHeight(self.entityId, self.flyoutSize)
  UiTransform2dBus.Event.SetLocalHeight(self.entityId, self.flyoutSize)
  UiTransform2dBus.Event.SetLocalHeight(self.Properties.ImageMask, self.flyoutSize - 2)
end
function FlyoutRow_PointOfInterest:SetTimerText(rawtime, propMins, propSecs)
  local _, _, minutes, seconds = TimeHelpers:ConvertSecondsToDaysHoursMinutesSeconds(rawtime)
  local minuteText = string.format("%02d ", minutes)
  local secondText = string.format("%02d ", seconds)
  UiTextBus.Event.SetText(self.Properties[propMins], string.format("%02d ", minuteText))
  UiTextBus.Event.SetText(self.Properties[propSecs], string.format("%02d ", secondText))
end
return FlyoutRow_PointOfInterest
