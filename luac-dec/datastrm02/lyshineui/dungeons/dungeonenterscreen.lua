local DungeonEnterScreen = {
  Properties = {
    ScreenHeader = {
      default = EntityId(),
      order = 1
    },
    AvgGearScore = {
      default = EntityId(),
      order = 2
    },
    Frame = {
      default = EntityId(),
      order = 3
    },
    InnerFrameBg = {
      default = EntityId(),
      order = 4
    },
    Content = {
      default = EntityId(),
      order = 5
    },
    InfoContainer = {
      default = EntityId(),
      order = 6
    },
    MutatorContainer = {
      default = EntityId(),
      order = 7
    },
    InfoContentPadding = {
      default = EntityId(),
      order = 8
    },
    TopContent = {
      default = EntityId(),
      order = 9
    },
    BottomContent = {
      default = EntityId(),
      order = 9
    },
    DungeonTitle = {
      default = EntityId(),
      order = 10
    },
    GroupSizeText = {
      default = EntityId(),
      order = 12
    },
    GroupSizeIcon = {
      default = EntityId(),
      order = 13
    },
    GearScoreRequirements = {
      default = EntityId(),
      order = 14
    },
    GroupSizeCheckbox = {
      default = EntityId(),
      order = 14
    },
    RequirementsTitle = {
      default = EntityId(),
      order = 15
    },
    RequiredEquipment = {
      default = EntityId(),
      order = 15
    },
    RequiredEquipmentIcon = {
      default = EntityId(),
      order = 16
    },
    RequiredItemsContainer = {
      default = EntityId(),
      order = 16
    },
    RequiredKeyItem = {
      default = EntityId(),
      order = 16
    },
    RequiredItemIcon = {
      default = EntityId(),
      order = 16
    },
    RequiredItemText = {
      default = EntityId(),
      order = 16
    },
    RequiredItemStateIcon = {
      default = EntityId(),
      order = 16
    },
    DungeonText = {
      default = EntityId(),
      order = 20
    },
    RewardsContainer = {
      default = EntityId(),
      order = 21
    },
    RewardsTitle = {
      default = EntityId(),
      order = 22
    },
    RewardsList = {
      default = EntityId(),
      order = 23
    },
    RewardEntries = {
      default = {
        EntityId()
      },
      order = 24
    },
    TimerContainer = {
      default = EntityId(),
      order = 25
    },
    TimerContainerFrame = {
      default = EntityId(),
      order = 26
    },
    DungeonFullText = {
      default = EntityId(),
      order = 27
    },
    ElapsedTimer = {
      default = EntityId(),
      order = 28
    },
    ElapsedTimerText = {
      default = EntityId(),
      order = 29
    },
    ElapsedTimeMinutes = {
      default = EntityId(),
      order = 30
    },
    ElapsedTimeSeconds = {
      default = EntityId(),
      order = 31
    },
    EstimatedTimer = {
      default = EntityId(),
      order = 32
    },
    EstimatedTimerText = {
      default = EntityId(),
      order = 33
    },
    EstimatedTimeMinutes = {
      default = EntityId(),
      order = 34
    },
    EstimatedTimeSeconds = {
      default = EntityId(),
      order = 35
    },
    EnterButton = {
      default = EntityId(),
      order = 36
    },
    LeaveQueueButton = {
      default = EntityId(),
      order = 37
    }
  },
  requiredItemDescriptor = ItemDescriptor(),
  iconPathRoot = "lyShineui/images/icons/items/resource/",
  checkmarkIcon = "lyShineui/images/icons/misc/icon_requirement_check.dds",
  xIcon = "lyShineui/images/icons/misc/icon_requirement_X.dds",
  dungeonTimeAcceptSeconds = 0,
  groupMemberCount = 0,
  hasDifficulty = false,
  minGroupSize = 0,
  timer = 0,
  timerTick = 1,
  contentPadding = 20,
  difficultyHeight = 0,
  difficultyIconOffset = 10,
  dungeonInfoHeight = 0,
  dungeonTextHeight = 0,
  dungeonTextPaddingTop = 12,
  gearReqsHeight = 0,
  innerFrameSizeFull = 1250,
  innerFrameSizeReduced = 875,
  requirementsOffset = 40,
  requirementIconSize = 25,
  rewardsHeight = 0,
  rewardsPaddingTop = 50,
  titleTextHeight = 100,
  timerwidth = 60
}
local BaseScreen = RequireScript("LyShineUI._Common.BaseScreen")
BaseScreen:CreateNewScreen(DungeonEnterScreen)
local TimeHelpers = RequireScript("LyShineUI._Common.TimeHelperFunctions")
local PopupWrapper = RequireScript("LyShineUI.Popup.PopupRequestWrapper")
local GameModeCommon = RequireScript("LyShineUI._Common.GameModeCommon")
local StaticItemDataManager = RequireScript("LyShineUI._Common.StaticItemDataManager")
function DungeonEnterScreen:OnInit()
  BaseScreen.OnInit(self)
  self.EnterButton:SetCallback(self.OnEnterButton, self)
  self.EnterButton:SetButtonStyle(self.EnterButton.BUTTON_STYLE_HERO)
  self.EnterButton:StartStopImageSequence(true)
  self.LeaveQueueButton:SetCallback(self.OnLeaveButton, self)
  self.LeaveQueueButton:SetButtonStyle(self.LeaveQueueButton.BUTTON_STYLE_HERO)
  UiElementBus.Event.SetIsEnabled(self.Properties.LeaveQueueButton, false)
  self.ScreenHeader:SetHintCallback(self.OnExit, self)
  self.Frame:SetFrameStyle(self.Frame.FRAME_STYLE_FULLSCREEN_RIGHT)
  self:ShowTimersContainer(false)
  self.isQueued = false
  self.entranceAvailable = false
  self.hasDungeonCooldown = false
  self.requiredItemDescriptor.quantity = 1
  self.requiredItemDescriptor.slotIndex = -1
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.InventoryEntityId", function(self, data)
    self.inventoryId = data
  end)
  if self.dungeonPlayerEventHandler then
    self:BusDisconnect(self.dungeonPlayerEventHandler)
  end
  SetTextStyle(self.Properties.DungeonTitle, self.UIStyle.FONT_STYLE_DUNGEON_TITLE)
  SetTextStyle(self.Properties.RewardsTitle, self.UIStyle.FONT_STYLE_DUNGEON_SUBHEADER)
  SetTextStyle(self.Properties.RequirementsTitle, self.UIStyle.FONT_STYLE_DUNGEON_SUBHEADER)
  SetTextStyle(self.Properties.DungeonText, self.UIStyle.FONT_STYLE_DUNGEON_DESCTEXT)
  local bodyTextElements = {
    self.Properties.GroupSizeText,
    self.Properties.RequiredItemText,
    self.Properties.GearScoreRequirements,
    self.Properties.RequiredEquipment,
    self.Properties.RequiredItemText,
    self.Properties.DungeonFullText,
    self.Properties.ElapsedTimerText,
    self.Properties.EstimatedTimerText
  }
  local timerTextElements = {
    self.Properties.ElapsedTimeMinutes,
    self.Properties.ElapsedTimeSeconds,
    self.Properties.EstimatedTimeMinutes,
    self.Properties.EstimatedTimeSeconds
  }
  for i, prop in ipairs(bodyTextElements) do
    SetTextStyle(prop, self.UIStyle.FONT_STYLE_DUNGEON_BODYTEXT)
  end
  for i, prop in ipairs(timerTextElements) do
    SetTextStyle(prop, self.UIStyle.FONT_STYLE_DUNGEON_TIMERTEXT)
  end
  self:LayoutSetup()
  DynamicBus.QueueHudDisplayBus.Connect(self.entityId, self)
end
function DungeonEnterScreen:OnShutddown()
  DynamicBus.QueueHudDisplayBus.Disconnect(self.entityId, self)
  BaseScreen.OnShutdown(self)
end
function DungeonEnterScreen:LayoutSetup()
  self.titleTextHeight = UiTextBus.Event.GetTextHeight(self.Properties.DungeonTitle)
  UiTransform2dBus.Event.SetLocalHeight(self.Properties.DungeonTitle, self.titleTextHeight)
  self.dungeonTextHeight = UiTextBus.Event.GetTextHeight(self.Properties.DungeonText)
  UiTransform2dBus.Event.SetLocalHeight(self.Properties.DungeonText, self.dungeonTextHeight + self.rewardsPaddingTop)
  local estimatedTimerTextWidth = UiTextBus.Event.GetTextWidth(self.Properties.EstimatedTimerText)
  local elapsedTimerTextWidth = UiTextBus.Event.GetTextWidth(self.Properties.ElapsedTimerText)
  local dungeonFullTextWidth = UiTextBus.Event.GetTextWidth(self.Properties.DungeonFullText)
  UiTransform2dBus.Event.SetLocalWidth(self.Properties.EstimatedTimer, estimatedTimerTextWidth + self.timerwidth)
  UiTransform2dBus.Event.SetLocalWidth(self.Properties.ElapsedTimer, elapsedTimerTextWidth + self.timerwidth)
  UiTransform2dBus.Event.SetLocalWidth(self.Properties.DungeonFullText, dungeonFullTextWidth + self.timerwidth)
  self.TimerContainerFrame:SetLineVisible(true)
end
function DungeonEnterScreen:RegisterObservers()
  self.groupDungeonInstanceState = DungeonInstanceState_NoDungeon
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Group.Id", function(self, groupId)
    if self.groupDataEventHandler then
      self:BusDisconnect(self.groupDataEventHandler)
    end
    self.groupId = groupId
    if groupId and groupId:IsValid() then
      self.groupDataEventHandler = self:BusConnect(GroupDataNotificationBus, groupId)
      self.groupDungeonInstanceState = GroupDataRequestBus.Event.GetGroupDungeonInstanceState(groupId)
    else
      self.groupDungeonInstanceState = DungeonInstanceState_NoDungeon
    end
    self:OnDungeonStateChanged(self.groupDungeonInstanceState)
  end)
  self.groupMemberCount = 0
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Group.MemberCount", function(self, memberCount)
    if not memberCount then
      return
    end
    self.groupMemberCount = memberCount
    self:UpdateEnterButton()
  end)
  self.uiArenaAndDungeonEventBusHandler = self:BusConnect(UIArenaAndDungeonEventBus)
end
function DungeonEnterScreen:UnregisterObservers()
  if self.groupDataEventHandler then
    self:BusDisconnect(self.groupDataEventHandler)
    self.groupDataEventHandler = nil
  end
  if self.uiArenaAndDungeonEventBusHandler then
    self:BusDisconnect(self.uiArenaAndDungeonEventBusHandler)
    self.uiArenaAndDungeonEventBusHandler = nil
  end
  self.dataLayer:UnregisterObserver(self, "Hud.LocalPlayer.Group.Id")
end
function DungeonEnterScreen:UpdateRequirements(minLevel, minGroupSize, gearRequired)
  local reqsTextGearScore = GetLocalizedReplacementText("@ui_dungeon_requirements_gearscore", {level = minLevel})
  local reqsTextGroup = GetLocalizedReplacementText("@ui_dungeon_requirements_groupsize", {players = minGroupSize})
  UiTextBus.Event.SetTextWithFlags(self.Properties.GearScoreRequirements, reqsTextGearScore, eUiTextSet_SetAsIs)
  UiTextBus.Event.SetTextWithFlags(self.Properties.GroupSizeText, reqsTextGroup, eUiTextSet_SetAsIs)
  local groupSizeColor
  if not self.minGroupSizeMet then
    groupSizeColor = self.UIStyle.COLOR_RED_LIGHT
  else
    groupSizeColor = self.UIStyle.COLOR_GREEN_BRIGHT
  end
  UiTextBus.Event.SetColor(self.Properties.GroupSizeText, groupSizeColor)
  UiImageBus.Event.SetColor(self.Properties.GroupSizeIcon, groupSizeColor)
  local stateIconPath = self.minGroupSizeMet and self.checkmarkIcon or self.xIcon
  UiImageBus.Event.SetSpritePathname(self.Properties.GroupSizeCheckbox, stateIconPath)
  UiTextBus.Event.SetColor(self.Properties.GroupSizeCheckbox, groupSizeColor)
  if gearRequired then
    UiTransform2dBus.Event.SetLocalHeight(self.Properties.RequiredItemsContainer, 185)
    local reqsGear = GetLocalizedReplacementText("@ui_dungeon_requirements_equipment_warning", {item = gearRequired})
    UiTextBus.Event.SetTextWithFlags(self.Properties.RequiredEquipment, reqsGear, eUiTextSet_SetAsIs)
    UiElementBus.Event.SetIsEnabled(self.Properties.RequiredEquipment, true)
    UiImageBus.Event.SetColor(self.Properties.RequiredEquipmentIcon, self.UIStyle.COLOR_YELLOW)
    UiTextBus.Event.SetColor(self.Properties.RequiredEquipment, self.UIStyle.COLOR_YELLOW)
  else
    UiTransform2dBus.Event.SetLocalHeight(self.Properties.RequiredItemsContainer, 145)
  end
end
function DungeonEnterScreen:UpdateRewardsList(rewards)
  local numRewards = rewards and #rewards or 0
  UiElementBus.Event.SetIsEnabled(self.Properties.RewardsList, 0 < numRewards)
  if 0 < numRewards then
    for i = 0, #self.RewardEntries do
      if numRewards >= i + 1 then
        local itemId = rewards[i + 1]
        local rewardEntry = self.RewardEntries[i]
        rewardEntry:SetDungeonRewardEntry(itemId, true)
        UiElementBus.Event.SetIsEnabled(self.Properties.RewardEntries[i], true)
        UiLayoutCellBus.Event.SetTargetWidth(self.Properties.RewardEntries[i], 75)
      else
        UiElementBus.Event.SetIsEnabled(self.Properties.RewardEntries[i], false)
      end
    end
  end
end
function DungeonEnterScreen:OnEnterButton()
  LocalPlayerUIRequestsBus.Broadcast.EnterDungeon()
  self.isActivatingDungeon = true
  self:UpdateEnterButton()
  if self.groupDungeonInstanceState == DungeonInstanceState_WaitingEntry or self.groupDungeonInstanceState == DungeonInstanceState_Entered then
    self.acceptedEntry = true
    self:UpdateEnterButton()
  end
  DynamicBus.DungeonEnterScreenBus.Broadcast.OnEnterButtonPressed()
end
local popupId = "queueLeaveGroupId"
function DungeonEnterScreen:OnLeaveButton()
  local gameModeId = ArenaRequestBus.Event.GetDungeonGameModeId(self.dungeonId)
  local playerRootEntityId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.GDERootEntityId")
  local gameModeData = GameModeParticipantComponentRequestBus.Event.GetGameModeStaticData(playerRootEntityId, gameModeId)
  local message = GetLocalizedReplacementText("@ui_queue_leave_group_confirm_message", {
    minGroupSize = gameModeData.minGroupSize
  })
  if self.groupMemberCount > gameModeData.minGroupSize then
    message = "@ui_dungeon_leave_group_sufficient_members"
  end
  PopupWrapper:RequestPopup(ePopupButtons_YesNo, "@ui_queue_leave_group_confirm_title", message, popupId, self, function(self, result, eventId)
    if popupId == eventId and result == ePopupResult_Yes then
      self.groupDungeonInstanceState = DungeonInstanceState_NoDungeon
      self:SetTicking(false)
      self:HideTimersAndLeaveQueueButton()
      GroupsRequestBus.Broadcast.RequestLeaveGroup()
    end
  end)
end
function DungeonEnterScreen:SetTicking(isTicking)
  if isTicking then
    if not self.tickHandler then
      self.tickHandler = self:BusConnect(DynamicBus.UITickBus)
    end
  else
    self:BusDisconnect(self.tickHandler)
    self.tickHandler = nil
  end
end
function DungeonEnterScreen:OnTick(deltaTime)
  self.timer = self.timer + deltaTime
  if self.timer >= self.timerTick then
    self.timer = self.timer - self.timerTick
    if self.hasDungeonCooldown and self.groupDungeonInstanceState ~= DungeonInstanceState_Entered then
      local dungeonCooldownSec = UIArenaAndDungeonRequestBus.Broadcast.GetDungeonCooldownTime()
      if dungeonCooldownSec ~= -1 then
        local _, _, minutes, seconds = TimeHelpers:ConvertSecondsToDaysHoursMinutesSeconds(dungeonCooldownSec)
        local timeRemaining = string.format("%02d:%02d", minutes, seconds)
        local buttonText = LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement("@ui_dungeon_cooldown", timeRemaining)
        self.EnterButton:SetText(buttonText)
        local tooltipText = LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement("@ui_dungeon_cooldown_flyout", timeRemaining)
        self.EnterButton:SetTooltip(tooltipText)
        self.EnterButton:SetEnabled(false)
      else
        self.hasDungeonCooldown = false
        self.EnterButton:SetText("@ui_dungeon_activate")
        self.EnterButton:SetTooltip("")
        self.EnterButton:SetEnabled(true)
        self:SetTicking(false)
        self.EnterButton:SizeToText()
      end
    end
    if self.entranceAvailable then
      local dungeonRemainingTime = GroupDataRequestBus.Event.GetDungeonRemainingEnterTime(self.groupId)
      if self.groupDungeonInstanceState == DungeonInstanceState_WaitingEntry then
        self:HideTimersAndLeaveQueueButton()
        self.EnterButton:SetEnabled(true)
        self:UpdateEnterButton()
      end
      if dungeonRemainingTime == nil then
        self.entranceAvailable = false
        self.SetTicking(false)
      end
    end
    if self.isQueued then
      self:UpdateElapsedTimeQueue()
      self:SetEstimatedTimerText()
    end
  end
end
function DungeonEnterScreen:UpdateRequiredItem()
  local requiredItems = ArenaRequestBus.Event.GetArenaRequiredItems(self.dungeonId)
  self.useItemRequirement = 0 < #requiredItems and not ConfigProviderEventBus.Broadcast.GetBool("javelin.enable-easy-dungeon-testing")
  UiElementBus.Event.SetIsEnabled(self.Properties.RequiredKeyItem, self.useItemRequirement)
  if self.useItemRequirement then
    self.requiredItemDescriptor.itemId = requiredItems[1].itemId
    self.requiredItemAmount = requiredItems[1].quantity
    self.requiredItemTdi = StaticItemDataManager:GetTooltipDisplayInfo(self.requiredItemDescriptor)
    local iconPath = self.iconPathRoot .. self.requiredItemTdi.iconPath .. ".dds"
    UiImageBus.Event.SetSpritePathname(self.Properties.RequiredItemIcon, iconPath)
    local currentItemAmount = ContainerRequestBus.Event.GetMaxUniqueItemCount(self.inventoryId, self.requiredItemDescriptor, false)
    self.hasRequiredItem = currentItemAmount >= self.requiredItemAmount
  end
end
function DungeonEnterScreen:UpdateElapsedTimeQueue()
  local now = TimeHelpers:ServerNow()
  self.elapsedTime = now:SubtractSeconds(self.startTime):ToSeconds()
  local _, _, minutes, seconds = TimeHelpers:ConvertSecondsToDaysHoursMinutesSeconds(self.elapsedTime)
  local minuteText = string.format("%02d ", minutes)
  local secondText = string.format("%02d ", seconds)
  UiTextBus.Event.SetText(self.Properties.ElapsedTimeMinutes, minuteText)
  UiTextBus.Event.SetText(self.Properties.ElapsedTimeSeconds, secondText)
end
function DungeonEnterScreen:UpdateEnterButton()
  local dungeonAvailable = self.isDungeonAvailable
  local minGroupSizeEnforced = ConfigProviderEventBus.Broadcast.GetBool("javelin.enable-dungeon-group-restriction") and not ConfigProviderEventBus.Broadcast.GetBool("javelin.enable-easy-dungeon-testing")
  self.minGroupSizeMet = not minGroupSizeEnforced or self.groupMemberCount >= self.minGroupSize
  self.isItemRequirementMet = not self.useItemRequirement or self.hasRequiredItem
  local dungeonCooldownSec = UIArenaAndDungeonRequestBus.Broadcast.GetDungeonCooldownTime()
  self.hasDungeonCooldown = dungeonCooldownSec ~= -1
  local playerRootEntityId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.GDERootEntityId")
  local isInOutpostRushQueue = GameModeParticipantComponentRequestBus.Event.IsInQueueForGameMode(playerRootEntityId, GameModeCommon.GAMEMODE_OUTPOST_RUSH)
  self.EnterButton:SetTooltip("")
  local dungeonHasBeenStarted = false
  if isInOutpostRushQueue then
    local buttonText = "@ui_dungeon_queued_blocked"
    self.EnterButton:SetText(buttonText)
    self.EnterButton:SetTooltip("@ui_dungeon_outpost_rush")
    self.EnterButton:SetEnabled(false)
  elseif self.acceptedEntry then
    self.EnterButton:SetText("@ui_dungeon_activating")
    self.EnterButton:SetEnabled(false)
    dungeonHasBeenStarted = true
  else
    local isInSpecificDungeon = not ArenaRequestBus.Event.IsGroupInDungeon(self.dungeonId)
    local isAlreadyInDungeon = self.groupDungeonInstanceState ~= DungeonInstanceState_NoDungeon and isInSpecificDungeon
    if isAlreadyInDungeon and self.groupDungeonInstanceState ~= DungeonInstanceState_Entered then
      local buttonText = "@ui_dungeon_queued_blocked"
      local tooltipText = "@ui_dungeon_group_in_active_dungeon"
      if self.groupDungeonInstanceState == DungeonInstanceState_Queued then
        tooltipText = "@ui_dungeon_group_already_in_queue_dungeon"
      end
      self.EnterButton:SetText(buttonText)
      self.EnterButton:SetTooltip(tooltipText)
      self.EnterButton:SetEnabled(false)
      self:HideTimersAndLeaveQueueButton()
    elseif self.groupDungeonInstanceState == DungeonInstanceState_WaitingEntry then
      self.entranceAvailable = true
      self.isQueued = false
      self.EnterButton:SetEnabled(true)
      self.EnterButton:SetText("@ui_enter_dungeon")
      dungeonHasBeenStarted = true
    elseif self.groupDungeonInstanceState == DungeonInstanceState_Entered then
      self.EnterButton:SetEnabled(true)
      self.EnterButton:SetText("@join_group_in_dungeon")
      dungeonHasBeenStarted = true
    elseif self.groupDungeonInstanceState == DungeonInstanceState_Queued then
      self.EnterButton:SetEnabled(false)
      self.EnterButton:SetText("@ui_dungeon_group_in_queue")
      self:ShowTimersAndLeaveQueueButton()
      dungeonHasBeenStarted = true
    elseif dungeonAvailable then
      local buttonText = "@ui_dungeon_activate"
      self.EnterButton:SetTooltip("")
      if not self.isItemRequirementMet then
        buttonText = "@ui_dungeon_queued_blocked"
        local tooltip = GetLocalizedReplacementText("@ui_dungeon_required_item_tooltip", {
          quantity = self.requiredItemAmount,
          item = self.requiredItemTdi.displayName
        })
        self.EnterButton:SetTooltip(tooltip)
      elseif not self.minGroupSizeMet then
        buttonText = "@ui_dungeon_queued_blocked"
        self.EnterButton:SetTooltip("@ui_dungeon_not_enough_members")
        self:HideTimersAndLeaveQueueButton()
        self:LayoutSetup()
      elseif not self.allMembersInProximity then
        buttonText = "@ui_dungeon_queued_blocked"
        self.EnterButton:SetTooltip("@ui_dungeon_group_proximity")
      elseif not self.allMembersAlive then
        buttonText = "@ui_dungeon_queued_blocked"
        self.EnterButton:SetTooltip("@ui_dungeon_group_dead")
      elseif self.isActivatingDungeon then
        buttonText = "@ui_dungeon_activating"
      elseif self.hasDungeonCooldown then
        local _, _, minutes, seconds = TimeHelpers:ConvertSecondsToDaysHoursMinutesSeconds(dungeonCooldownSec)
        local timeRemaining = string.format("%02d:%02d", minutes, seconds)
        buttonText = LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement("@ui_dungeon_cooldown", timeRemaining)
        self.EnterButton:SetText(buttonText)
        local tooltipText = LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement("@ui_dungeon_cooldown_flyout", timeRemaining)
        self.EnterButton:SetTooltip(tooltipText)
        self:SetTicking(true)
      end
      self.EnterButton:SetText(buttonText)
      local buttonEnabled = not self.isActivatingDungeon and self.isItemRequirementMet and self.allMembersInProximity and self.allMembersAlive and self.minGroupSizeMet and not self.hasDungeonCooldown
      self.EnterButton:SetEnabled(buttonEnabled)
    else
      self:SetEstimatedTimerText()
    end
  end
  if self.useItemRequirement then
    local requiredItemLocTag = dungeonHasBeenStarted and "@ui_dungeon_required_item_started" or "@ui_dungeon_required_item"
    local requiredItemText = GetLocalizedReplacementText(requiredItemLocTag, {
      quantity = self.requiredItemAmount,
      item = self.requiredItemTdi.displayName
    })
    UiTextBus.Event.SetText(self.Properties.RequiredItemText, requiredItemText)
    local showItemChecked = dungeonHasBeenStarted or self.hasRequiredItem
    local stateIconPath = showItemChecked and self.checkmarkIcon or self.xIcon
    local textColor = showItemChecked and self.UIStyle.COLOR_GREEN_BRIGHT or self.UIStyle.COLOR_RED_LIGHT
    UiImageBus.Event.SetSpritePathname(self.Properties.RequiredItemStateIcon, stateIconPath)
    UiTextBus.Event.SetColor(self.Properties.RequiredItemText, textColor)
  end
  UiElementBus.Event.SetIsEnabled(self.Properties.DungeonFullText, not dungeonAvailable)
  self.EnterButton:SizeToText()
end
function DungeonEnterScreen:OnTransitionIn(stateName, levelName)
  self.ScreenHeader:SetText("@ui_dungeon_screen_header")
  local interactorEntity = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.InteractorEntityId")
  local interactable = UiInteractorComponentRequestsBus.Event.GetInteractable(interactorEntity)
  self.dungeonId = TransformBus.Event.GetRootId(interactable)
  local gameModeId = ArenaRequestBus.Event.GetDungeonGameModeId(self.dungeonId)
  if self.dungeonEventHandler then
    self:BusDisconnect(self.dungeonEventHandler)
  end
  self.dungeonEventHandler = self:BusConnect(ArenaEventBus, self.dungeonId)
  local playerRootEntityId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.GDERootEntityId")
  local gameModeData = GameModeParticipantComponentRequestBus.Event.GetGameModeStaticData(playerRootEntityId, gameModeId)
  self.isDungeonAvailable = not ArenaRequestBus.Event.IsArenaActive(self.dungeonId)
  self.isActivatingDungeon = false
  self.allMembersInProximity = ArenaRequestBus.Event.GetAllGroupMembersInProximity(self.dungeonId)
  self.allMembersAlive = ArenaRequestBus.Event.GetAllGroupMembersAlive(self.dungeonId)
  self.minGroupSize = gameModeData.minGroupSize
  self.requiredGearText = false
  self.acceptedEntry = false
  if gameModeData.requirementText ~= nil and gameModeData.requirementText ~= "" then
    self.requiredGearText = gameModeData.requirementText
  end
  self:UpdateRequiredItem()
  self:RegisterObservers()
  self:UpdateEnterButton()
  self:SetBackgroundImage(gameModeData.backgroundImagePath or false)
  self:UpdateRequirements(gameModeData.requiredLevel, self.minGroupSize, self.requiredGearText)
  self:UpdateRewardsList(gameModeData.possibleItemDropIds)
  UiTextBus.Event.SetTextWithFlags(self.Properties.DungeonTitle, gameModeData.displayName, eUiTextSet_SetLocalized)
  UiTextBus.Event.SetTextWithFlags(self.Properties.DungeonText, gameModeData.description, eUiTextSet_SetLocalized)
  self.titleTextHeight = UiTextBus.Event.GetTextHeight(self.Properties.DungeonTitle)
  UiTransform2dBus.Event.SetLocalHeight(self.Properties.DungeonTitle, self.titleTextHeight)
  JavCameraControllerRequestBus.Broadcast.OverrideCameraState("UI_SignUp", 0.5)
  self.audioHelper:PlaySound(self.audioHelper.Crafting_Intro)
  if self.isQueued then
    self.startTime = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.QueueStartTime")
    self:UpdateElapsedTimeQueue()
    self:SetEstimatedTimerText()
  end
end
function DungeonEnterScreen:OnTransitionOut(fromStateName, fromLevelName, toStateName, toLevelName)
  self:UnregisterObservers()
  if self.dungeonEventHandler then
    self:BusDisconnect(self.dungeonEventHandler)
    self.dungeonEventHandler = nil
  end
  local interactorEntity = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.InteractorEntityId")
  if interactorEntity then
    UiInteractorComponentRequestsBus.Event.RequestCancelCommittedInteraction(interactorEntity)
  end
  JavCameraControllerRequestBus.Broadcast.RestoreCameraState("UI_SignUp", 0.5)
  LyShineManagerBus.Broadcast.TransitionOutComplete()
end
function DungeonEnterScreen:ShowTimersAndLeaveQueueButton()
  UiElementBus.Event.SetIsEnabled(self.Properties.EnterButton, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.LeaveQueueButton, true)
  self:ShowTimersContainer(true)
  local isEstimatedTimeVisible = UiElementBus.Event.IsEnabled(self.Properties.EstimatedTimerText)
  local isElapsedTimeVisible = UiElementBus.Event.IsEnabled(self.Properties.ElapsedTimerText)
  local isDungeonFullMsgVisible = UiElementBus.Event.IsEnabled(self.Properties.DungeonFullText)
  self.fullsizeTimerContainer = isElapsedTimeVisible and (isEstimatedTimeVisible or isDungeonFullMsgVisible)
  if not self.fullsizeTimerContainer then
    UiTransform2dBus.Event.SetLocalHeight(self.Properties.TimerContainer, 50)
    self.TimerContainerFrame:SetHeight(50)
  end
  self.isQueued = true
  self:SetTicking(true)
end
function DungeonEnterScreen:HideTimersAndLeaveQueueButton()
  UiElementBus.Event.SetIsEnabled(self.Properties.EnterButton, true)
  UiElementBus.Event.SetIsEnabled(self.Properties.LeaveQueueButton, false)
  self:ShowTimersContainer(false)
  self.isQueued = false
  UiTransform2dBus.Event.SetLocalHeight(self.Properties.TimerContainer, 80)
  self.TimerContainerFrame:SetHeight(80)
  UiTextBus.Event.SetText(self.Properties.ElapsedTimeMinutes, string.format("%02d ", 0))
  UiTextBus.Event.SetText(self.Properties.ElapsedTimeSeconds, string.format("%02d ", 0))
end
function DungeonEnterScreen:OnDungeonActivateResult(response)
  self:OnExit()
  if response ~= eDungeonActivateResponse_Success then
    local notificationData = NotificationData()
    notificationData.type = "Minor"
    if response == eDungeonActivateResponse_NotEnoughMembers then
      notificationData.text = "@ui_dungeon_not_enough_members"
    elseif response == eDungeonActivateResponse_NotEnoughMembersInProximity then
      notificationData.text = "@ui_dungeon_group_proximity"
    else
      notificationData.text = "@ui_dungeon_activate_failure"
    end
    UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
  end
  self.isActivatingArena = false
end
function DungeonEnterScreen:SetPlayerGearScore(value)
  local gearScoreText = GetLocalizedReplacementText("@ui_dungeon_player_average_gear_score", {level = value})
  UiElementBus.Event.SetIsEnabled(self.Properties.AvgGearScore, value ~= nil and 0 < value)
  UiTextBus.Event.SetTextWithFlags(self.Properties.AvgGearScore, gearScoreText, eUiTextSet_SetAsIs)
end
function DungeonEnterScreen:SetEstimatedTimerText()
  local now = TimeHelpers:ServerNow()
  self.dungeonEstimatedTime = GroupDataRequestBus.Event.GetDungeonRemainingEnterTime(self.groupId) + now:SubtractSeconds(self.startTime):ToSeconds()
  local _, _, minutes, seconds = TimeHelpers:ConvertSecondsToDaysHoursMinutesSeconds(self.dungeonEstimatedTime)
  local minuteText = string.format("%02d ", minutes)
  local secondText = string.format("%02d ", seconds)
  UiTextBus.Event.SetText(self.Properties.EstimatedTimeMinutes, string.format("%02d ", minuteText))
  UiTextBus.Event.SetText(self.Properties.EstimatedTimeSeconds, string.format("%02d ", secondText))
end
function DungeonEnterScreen:SetBackgroundImage(image)
  local backgroundImagePath
  local fallbackImage = "LyShineUI/Images/Dungeons/dungeonImages/dungeonImages_DungeonAmrine.dds"
  if image and image ~= "" then
    backgroundImagePath = image
  else
    backgroundImagePath = fallbackImage
  end
  UiImageBus.Event.SetSpritePathname(self.Properties.InnerFrameBg, backgroundImagePath)
end
function DungeonEnterScreen:ShowTimersContainer(showTimers)
  UiElementBus.Event.SetIsEnabled(self.Properties.TimerContainer, showTimers)
  local containerHeight = 0
  local timersPadding = showTimers and 15 or 0
  local bottomTextContainers = {
    self.Properties.RequiredItemsContainer,
    self.Properties.TimerContainer
  }
  for i, prop in ipairs(bottomTextContainers) do
    if UiElementBus.Event.IsEnabled(prop) then
      local getPropHeight = UiTransform2dBus.Event.GetLocalHeight(prop) or 0
      containerHeight = containerHeight + getPropHeight
    end
  end
  UiTransform2dBus.Event.SetLocalHeight(self.Properties.BottomContent, containerHeight + timersPadding)
end
function DungeonEnterScreen:OnFocusRequiredItem()
  DynamicBus.TooltipsRequestBus.Broadcast.ShowTooltip(self.requiredItemTdi, nil)
end
function DungeonEnterScreen:OnUnfocusRequiredItem()
  DynamicBus.TooltipsRequestBus.Broadcast.HideTooltip()
end
function DungeonEnterScreen:OnDungeonAcceptedFromBanner()
  self:OnEnterButton()
end
function DungeonEnterScreen:OnArenaStateChanged(isActive)
  self.isDungeonAvailable = not isActive
  self:UpdateEnterButton()
end
function DungeonEnterScreen:OnArenaEndTimeChanged(secondsRemaining)
  self.EstimatedTimerElement:SetTimeSeconds(secondsRemaining, true)
end
function DungeonEnterScreen:OnGroupMembersProximityChanged(allMembersInProximity)
  self.allMembersInProximity = allMembersInProximity
  self:UpdateEnterButton()
end
function DungeonEnterScreen:OnGroupInDungeonChanged(isGroupInDungeon)
  self:UpdateEnterButton()
end
function DungeonEnterScreen:OnDungeonStateChanged(isActive)
  self.isDungeonAvailable = not isActive
  self:UpdateEnterButton()
end
function DungeonEnterScreen:OnDungeonEndTimeChanged(secondsRemaining)
  self.EstimatedTimerElement:SetTimeSeconds(secondsRemaining, true)
end
function DungeonEnterScreen:OnGroupMembersAliveChanged(allMembersAlive)
  self.allMembersAlive = allMembersAlive
  self:UpdateEnterButton()
end
function DungeonEnterScreen:OnDungeonStateChanged(instanceState)
  if instanceState == DungeonInstanceState_Queued then
    self.startTime = TimeHelpers:ServerNow()
  end
  self.groupDungeonInstanceState = instanceState
  self:UpdateEnterButton()
end
function DungeonEnterScreen:OnExit()
  LyShineManagerBus.Broadcast.ExitState(4119896358)
end
return DungeonEnterScreen
