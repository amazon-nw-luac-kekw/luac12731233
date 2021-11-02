local RaidPanel = {
  Properties = {
    Groups = {
      default = {
        EntityId()
      }
    },
    SearchBox = {
      default = EntityId()
    },
    SearchInputField = {
      default = EntityId()
    },
    RaidContainer = {
      default = EntityId()
    },
    ContentsText = {
      default = EntityId()
    },
    DisplaySearchText = {
      default = EntityId()
    },
    StandbyOffset = {
      default = EntityId()
    },
    StandbyDivider = {
      default = EntityId()
    },
    PageText = {
      default = EntityId()
    },
    PageNextButton = {
      default = EntityId()
    },
    PagePrevButton = {
      default = EntityId()
    },
    HeaderText = {
      default = EntityId()
    },
    RefreshButton = {
      default = EntityId()
    },
    BackfillHeader = {
      default = EntityId()
    },
    BackfillToggle = {
      default = EntityId()
    },
    Toggle1 = {
      default = EntityId()
    },
    Toggle2 = {
      default = EntityId()
    },
    QuestionMark = {
      default = EntityId()
    },
    DragInstructionContainer = {
      default = EntityId()
    },
    RaidCountText = {
      default = EntityId()
    },
    ConvertToRaidButton = {
      default = EntityId()
    },
    LeaveRaidButton = {
      default = EntityId()
    },
    FillRosterButton = {
      default = EntityId()
    },
    SignUpButton = {
      default = EntityId()
    }
  },
  NUM_GROUPS = 10,
  TIME_BETWEEN_REFRESHES = 5,
  timer = 0,
  isEnabled = false,
  playerIdList = {},
  guildMembers = {},
  useGuildList = true,
  raidMembers = {},
  raidId = nil,
  territoryId = 0,
  permissions = eRaidPermission_Normal,
  side = eRaidSide_None,
  signupEntriesPerPage = 16,
  currentPage = 1,
  totalPages = 1,
  isShowingRoster = false,
  raidRoster = RaidRoster(),
  onLeaveOtherWarEventId = "Popup_OnLeaveOtherWar"
}
local PopupWrapper = RequireScript("LyShineUI.Popup.PopupRequestWrapper")
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(RaidPanel)
local dominionCommon = RequireScript("LyShineUI._Common.DominionCommon")
local TerritoryDataHandler = RequireScript("LyShineUI._Common.TerritoryDataHandler")
function RaidPanel:OnInit()
  BaseElement.OnInit(self)
  self.signupEntriesPerPage = ConfigProviderEventBus.Broadcast.GetInt("javelin.social.war-signup-entries-per-page")
  self.raidDynamicBusHandler = DynamicBus.Raid.Connect(self.entityId, self)
  for index = 1, self.NUM_GROUPS do
    self.Groups[index - 1]:SetGroupData(index - 1, nil)
  end
  self.PageNextButton:SetCallback(self.OnStandbyNextButtonPressed, self)
  self.PagePrevButton:SetCallback(self.OnStandbyPrevButtonPressed, self)
  self.RefreshButton:SetCallback(self.RefreshRaid, self)
  self.RefreshButton:SetButtonSingleIconPath("lyshineui/images/icons/misc/icon_refresh.dds")
  self.RefreshButton:SetTooltip("@ui_refreshpage")
  self.Toggle1:SetTextStyle(self.UIStyle.FONT_STYLE_RAID_TOGGLE)
  self.Toggle2:SetTextStyle(self.UIStyle.FONT_STYLE_RAID_TOGGLE)
  self.Toggle1:SetTooltip("@ui_backfill_auto_tooltip")
  self.Toggle2:SetTooltip("@ui_backfill_manual_tooltip")
  self.BackfillToggle:SetText("@ui_auto", "@ui_manual")
  self.BackfillToggle:SetCallback("OnBackfillEnabled", "OnBackfillDisabled", self)
  self.BackfillToggle:InitToggleState(false)
  UiElementBus.Event.SetIsEnabled(self.Properties.ConvertToRaidButton, false)
  self.LeaveRaidButton:SetCallback(self.LeaveRaid, self)
  self.LeaveRaidButton:SetTextStyle(self.UIStyle.FONT_STYLE_RAID_BUTTON)
  self.SignUpButton:SetCallback(self.SignUp, self)
  self.SignUpButton:SetTextStyle(self.UIStyle.FONT_STYLE_RAID_BUTTON)
  self.SignUpButton:SetText("@ui_raid_signup_button")
  self.FillRosterButton:SetCallback(self.FillRoster, self)
  self.FillRosterButton:SetTextStyle(self.UIStyle.FONT_STYLE_RAID_BUTTON)
  self.FillRosterButton:SetText("@ui_raid_fill_button")
  self.QuestionMark:SetTooltip("@ui_backfill_tooltip")
  self.QuestionMark:SetButtonStyle(self.QuestionMark.BUTTON_STYLE_QUESTION_MARK)
end
function RaidPanel:OnShutdown()
  if self.raidDynamicBusHandler then
    DynamicBus.Raid.Disconnect(self.entityId, self)
    self.raidDynamicBusHandler = nil
  end
end
function RaidPanel:RegisterObservers()
  if not self.isShowingRoster then
    if self.raidDataBusHandler then
      self:BusDisconnect(self.raidDataBusHandler)
      self.raidDataBusHandler = nil
    end
    self.raidDataBusHandler = self:BusConnect(RaidDataNotificationBus)
    self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.CharacterId", function(self, characterId)
      self.characterId = characterId
      if self.groupId and characterId then
        self.raidPermissions = GroupDataRequestBus.Event.GetMemberRaidPermissions(self.groupId, self.characterId)
      end
    end)
    self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Group.Id", function(self, groupId)
      self.groupId = groupId
      if self.characterId and groupId and groupId:IsValid() then
        self.raidPermissions = GroupDataRequestBus.Event.GetMemberRaidPermissions(self.groupId, self.characterId)
      end
    end)
    self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Raid.Id", function(self, raidId)
      for _, group in pairs(self.Groups) do
        group:ClearData()
      end
      if raidId and raidId:IsValid() then
        self.raidId = raidId
        self.groupIds = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Raid.GroupIds")
        local warDetails = WarDataServiceBus.Broadcast.GetWarForRaid(raidId)
        self.inWarRaid = warDetails and warDetails:IsValid()
        self:UpdateActiveRaid()
      else
        self.raidId = nil
        ClearTable(self.groupIds)
        self.inWarRaid = false
      end
    end)
  end
  self.SearchInputField:SetOnlineOnly(false)
  UiElementBus.Event.SetIsEnabled(self.Properties.SearchBox, false)
  if not self.autoCompleteBusHandler then
    self.autoCompleteBusHandler = self:BusConnect(UiTextInputAutoCompleteBus, self.SearchInputField.entityId)
    self.scrollBoxDataBusHandler = self:BusConnect(UiDynamicScrollBoxDataBus, self.Properties.RaidContainer)
    self.scrollBoxElementBusHandler = self:BusConnect(UiDynamicScrollBoxElementNotificationBus, self.Properties.RaidContainer)
    self.textInputBusHandler = self:BusConnect(UiTextInputNotificationBus, self.Properties.SearchInputField)
  end
  UiDynamicScrollBoxBus.Event.RefreshContent(self.Properties.RaidContainer)
end
function RaidPanel:UnregisterObservers()
  if self.raidDataBusHandler then
    self:BusDisconnect(self.raidDataBusHandler)
    self.raidDataBusHandler = nil
  end
  self.dataLayer:UnregisterObserver(self, "Hud.LocalPlayer.CharacterId")
  self.dataLayer:UnregisterObserver(self, "Hud.LocalPlayer.Group.Id")
  self.dataLayer:UnregisterObserver(self, "Hud.LocalPlayer.Raid.Id")
  if self.autoCompleteBusHandler then
    self:BusDisconnect(self.autoCompleteBusHandler, self.SearchInputField.entityId)
    self:BusDisconnect(self.scrollBoxDataBusHandler, self.Properties.RaidContainer)
    self:BusDisconnect(self.scrollBoxElementBusHandler, self.Properties.RaidContainer)
    self:BusDisconnect(self.textInputBusHandler, self.Properties.SearchInputField)
    self.autoCompleteBusHandler = nil
    self.scrollBoxDataBusHandler = nil
    self.scrollBoxElementBusHandler = nil
    self.textInputBusHandler = nil
  end
end
function RaidPanel:OnTick(deltaTime, timePoint)
  if self.isEnabled and self.isShowingRoster then
    self.timer = self.timer + deltaTime
    if self.timer >= self.TIME_BETWEEN_REFRESHES then
      self.timer = self.timer - self.TIME_BETWEEN_REFRESHES
      self:RefreshRaid()
    end
  end
end
function RaidPanel:StartTick()
  if not self.tickHandler then
    self.timer = 0
    self.tickHandler = self:BusConnect(DynamicBus.UITickBus)
  end
end
function RaidPanel:StopTick()
  if self.tickHandler then
    self:BusDisconnect(self.tickHandler)
    self.tickHandler = nil
  end
end
function RaidPanel:OnRosterChanged(roster)
  local warDetails = WarDataServiceBus.Broadcast.GetWarForTerritory(self.territoryId)
  if warDetails:IsValid() == false or warDetails:IsWarActive() == false then
    return
  end
  if not self.isShowingRoster then
    return
  end
  local signupStatus = RaidSetupRequestBus.Broadcast.GetSignupStatus(self.territoryId)
  self:OnSignupStatusChanged(self.territoryId, signupStatus)
  local backfillEnabled = RaidSetupRequestBus.Broadcast.GetIsBackfillEnabled()
  self.BackfillToggle:InitToggleState(not backfillEnabled)
  if not self.isInvasion then
    local canManage = RaidSetupRequestBus.Broadcast.HasManagePermission(self.territoryId)
    local enableToggle = ConfigProviderEventBus.Broadcast.GetBool("javelin.social.war-backfill-toggling-enabled")
    self.BackfillToggle:SetDisabled(not canManage or not enableToggle)
    UiElementBus.Event.SetIsEnabled(self.Properties.BackfillHeader, canManage)
    if canManage then
      UiTransformBus.Event.SetLocalPositionY(self.Properties.StandbyOffset, 0)
      UiElementBus.Event.SetIsEnabled(self.Properties.StandbyDivider, false)
      UiTransformBus.Event.SetLocalPositionY(self.Properties.RaidContainer, 171)
    else
      UiTransformBus.Event.SetLocalPositionY(self.Properties.StandbyOffset, -112)
      UiElementBus.Event.SetIsEnabled(self.Properties.StandbyDivider, true)
      UiTransformBus.Event.SetLocalPositionY(self.Properties.RaidContainer, 189)
    end
  else
    self.BackfillToggle:SetDisabled(true)
    UiElementBus.Event.SetIsEnabled(self.Properties.BackfillHeader, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.StandbyDivider, true)
    UiTransformBus.Event.SetLocalPositionY(self.Properties.StandbyOffset, -112)
    UiTransformBus.Event.SetLocalPositionY(self.Properties.RaidContainer, 189)
  end
  self:UpdateFromRoster(roster)
end
function RaidPanel:OnSetRosterResponseReceived(success, failureReason)
  if not self.isShowingRoster then
    return
  end
  if success then
    RaidSetupRequestBus.Broadcast.RequestSignupList(self.currentPage)
  else
    local notificationData = NotificationData()
    notificationData.type = "Minor"
    if failureReason == eRaidSetupRequestFailureReason_InGuildButNotPermitted or failureReason == eRaidSetupRequestFailureReason_NotPermitted then
      notificationData.text = "@ui_siege_set_roster_failed_not_permitted"
    elseif failureReason == eRaidSetupRequestFailureReason_InvalidPlayerInRoster then
      notificationData.text = "@ui_siege_set_roster_failed_invalid_player"
    elseif failureReason == eRaidSetupRequestFailureReason_NoMoreManualSelectionsAllowed then
      notificationData.text = "@ui_siege_set_roster_failed_no_more_selections"
    elseif failureReason == eRaidSetupRequestFailureReason_WaitingForInviteResponse then
      notificationData.text = "@ui_siege_set_roster_failed_waiting_for_invite_response"
    else
      notificationData.text = "@ui_siege_set_roster_failed"
    end
    UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
  end
end
function RaidPanel:OnSignupStatusChanged(territoryId, signupStatus)
  if not self.isShowingRoster or territoryId ~= self.territoryId then
    return
  end
  if RaidSetupRequestBus.Broadcast.HasManagePermission(self.territoryId) then
    self.rosterPermissions = eRaidPermission_Leader
  else
    self.rosterPermissions = signupStatus and signupStatus.permission or eRaidPermission_Normal
  end
  local canLeave = self.isShowingRoster and signupStatus and signupStatus.side ~= eRaidSide_None or self.raidId
  UiElementBus.Event.SetIsEnabled(self.Properties.LeaveRaidButton, canLeave)
  local canManage = self.isShowingRoster and RaidSetupRequestBus.Broadcast.HasManagePermission(self.territoryId)
  UiElementBus.Event.SetIsEnabled(self.Properties.FillRosterButton, canManage)
  if canManage then
    UiTransformBus.Event.SetLocalPositionY(self.Properties.LeaveRaidButton, -128)
  else
    UiTransformBus.Event.SetLocalPositionY(self.Properties.LeaveRaidButton, -102)
  end
  local allowRemoteSignup = ConfigProviderEventBus.Broadcast.GetBool("javelin.social.enable-war-signup-from-map")
  local isRemoteInteract = DynamicBus.Raid.Broadcast.IsRemoteInteract()
  local canSignUp = (allowRemoteSignup or not isRemoteInteract) and self.isShowingRoster and (not signupStatus or signupStatus.side == eRaidSide_None)
  if self.isInvasion then
    local playerLevel = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Progression.Level")
    local minLevel = ConfigProviderEventBus.Broadcast.GetInt("javelin.social.invasion-min-level") + 1
    canSignUp = canSignUp and playerLevel >= minLevel
  end
  UiElementBus.Event.SetIsEnabled(self.Properties.SignUpButton, canSignUp)
end
function RaidPanel:UpdateFromRoster(roster)
  self.raidRoster = roster
  local hasMembers = false
  local selectedPlayers = 0
  local maxGroupMembers = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Group.MaxMembers")
  for i = 1, #roster.groups do
    local group = roster.groups[i]
    local numGroupMembers = #group.members
    hasMembers = hasMembers or 0 < numGroupMembers
    self.Groups[group.groupRaidIndex]:SetGroupData(group.groupRaidIndex, nil)
    self.Groups[group.groupRaidIndex]:OnIconIndexChanged(group.iconIndex)
    self.Groups[group.groupRaidIndex]:OnColorIndexChanged(group.colorIndex)
    for j = 1, numGroupMembers do
      local member = group.members[j]
      local existingMember = self.Groups[group.groupRaidIndex].Members[j - 1].RaidMember
      if member.playerId ~= existingMember.playerId then
        existingMember:SetData(member.playerId, true, j)
      else
        existingMember:UpdateOnlineStatus()
      end
      if member.raidPermission ~= existingMember.permissions then
        existingMember:SetPermissions(member.raidPermission)
      end
    end
    for j = numGroupMembers + 1, maxGroupMembers do
      local existingMember = self.Groups[group.groupRaidIndex].Members[j - 1].RaidMember
      existingMember:ClearData()
    end
    selectedPlayers = selectedPlayers + numGroupMembers
    local hasMemberInThisGroup = 0 < numGroupMembers
    self.Groups[group.groupRaidIndex]:SetEmptyState(not hasMemberInThisGroup)
  end
  UiElementBus.Event.SetIsEnabled(self.Properties.DragInstructionContainer, not hasMembers)
  local countText = self.isInvasion and "@ui_invasion_count" or "@ui_raid_count"
  local rosterCount = GetLocalizedReplacementText(countText, {number = selectedPlayers})
  UiTextBus.Event.SetText(self.Properties.RaidCountText, rosterCount)
end
function RaidPanel:OnSignupListReceived(pageNum, totalPages, list)
  if not self.isShowingRoster then
    return
  end
  local pageText = GetLocalizedReplacementText("@ui_siege_standby_page_text", {
    currentPage = tostring(pageNum),
    totalPages = tostring(totalPages)
  })
  UiTextBus.Event.SetText(self.Properties.PageText, pageText)
  self.currentPage = pageNum
  self.totalPages = totalPages
  ClearTable(self.playerIdList)
  for index = 1, #list do
    self.playerIdList[index] = list[index]
  end
  UiDynamicScrollBoxBus.Event.RefreshContent(self.Properties.RaidContainer)
end
function RaidPanel:GetCurrentSignupListPage()
  return self.currentPage
end
function RaidPanel:GetSignupEntriesPerPage()
  return self.signupEntriesPerPage
end
function RaidPanel:OnSignupResponseReceived(success, failureReason)
  if not self.isEnabled or not self.isShowingRoster then
    return
  end
  if not success then
    Log("ERR - RaidPanel:OnSignupResponseReceived: Signup failed with reason " .. tostring(failureReason))
    local notificationData = NotificationData()
    notificationData.type = "Minor"
    if failureReason == eRaidSetupRequestFailureReason_SignupFull then
      notificationData.text = "@ui_siege_signup_failed_full"
    elseif failureReason == eRaidSetupRequestFailureReason_ConquestTimeOverlaps then
      notificationData.text = "@ui_siege_signup_failed_conquestoverlaps"
    elseif failureReason == eRaidSetupRequestFailureReason_RemoteSignupNotAllowed then
      notificationData.text = "@ui_siege_signup_failed_remotesignup"
    elseif failureReason == eRaidSetupRequestFailureReason_NotInFaction then
      notificationData.text = "@ui_siege_signup_failed_notinfaction"
    elseif failureReason == eRaidSetupRequestFailureReason_Banned then
      notificationData.text = "@ui_siege_signup_failed_banned"
    else
      notificationData.text = "@ui_siege_signup_failed"
    end
    UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
  end
  self:RefreshRaid()
end
function RaidPanel:OnLeaveResponseReceived(territoryId, success, failureReason)
  if not self.isShowingRoster then
    return
  end
  if not success then
    local notificationData = NotificationData()
    notificationData.type = "Minor"
    notificationData.text = "@ui_siege_leave_failed"
    UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
  end
  if self.territoryToLeaveFrom and self.territoryToLeaveFrom == territoryId then
    self.territoryToLeaveFrom = nil
    RaidSetupRequestBus.Broadcast.RequestSignup(self.side)
  end
  if self.territoryId == territoryId then
    if not RaidSetupRequestBus.Broadcast.HasManagePermission(self.territoryId) then
      LyShineManagerBus.Broadcast.ExitState(1468490675)
      return
    end
    self:RefreshRaid()
  end
end
function RaidPanel:OnStandbyNextButtonPressed()
  if self.currentPage < self.totalPages then
    RaidSetupRequestBus.Broadcast.RequestSignupList(self.currentPage + 1)
  end
end
function RaidPanel:OnStandbyPrevButtonPressed()
  if self.currentPage > 1 then
    RaidSetupRequestBus.Broadcast.RequestSignupList(self.currentPage - 1)
  end
end
function RaidPanel:OnBackfillEnabled()
  RaidSetupRequestBus.Broadcast.RequestSetBackfillEnabled(true)
  self.BackfillToggle:SetDisabled(true)
end
function RaidPanel:OnBackfillDisabled()
  RaidSetupRequestBus.Broadcast.RequestSetBackfillEnabled(false)
  self.BackfillToggle:SetDisabled(true)
end
function RaidPanel:OnSetBackfillEnabledResponseReceived(success, backfillEnabled, failureReason)
  self.BackfillToggle:SetDisabled(false)
  self.BackfillToggle:InitToggleState(not backfillEnabled)
  if not success then
    local notificationData = NotificationData()
    notificationData.type = "Minor"
    if failureReason == eRaidSetupRequestFailureReason_NotPermitted then
      notificationData.text = self.isInvasion and "@ui_siege_set_backfill_failed_not_permitted_invasion" or "@ui_siege_set_backfill_failed_not_permitted"
    else
      notificationData.text = "@ui_siege_set_backfill_failed"
    end
    UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
  end
end
function RaidPanel:OnLocalPlayerPermissionsChanged(permissions)
  self.raidPermissions = permissions
end
function RaidPanel:SetData(territoryId, side, isShowingRoster)
  self.territoryId = territoryId
  self.side = side
  self.isShowingRoster = isShowingRoster
  if self.isEnabled then
    self:RegisterObservers()
    if self.isShowingRoster then
      self:StartTick()
    else
      ClearTable(self.playerIdList)
      UiDynamicScrollBoxBus.Event.RefreshContent(self.Properties.RaidContainer)
    end
    local warDetails = WarDataServiceBus.Broadcast.GetWarForTerritory(territoryId)
    if warDetails:IsValid() == false or warDetails:IsWarActive() == false then
      return
    end
    self.isInvasion = warDetails:IsInvasion()
    local signupStatus = RaidSetupRequestBus.Broadcast.GetSignupStatus(self.territoryId)
    self:OnSignupStatusChanged(self.territoryId, signupStatus)
    headerText = self.isInvasion and "@ui_raid_invasion_header" or "@ui_raid_war_header"
    UiTextBus.Event.SetTextWithFlags(self.Properties.HeaderText, headerText, eUiTextSet_SetLocalized)
  end
end
function RaidPanel:GetPlayerPermissions()
  if self.isShowingRoster then
    return self.rosterPermissions
  else
    return self.raidPermissions
  end
end
function RaidPanel:IsInvasion()
  return self.isInvasion
end
function RaidPanel:SetPlayerPermissions(data)
  if self.isShowingRoster or self.inWarRaid then
    RaidSetupRequestBus.Broadcast.RequestSetPlayerPermissions(data.playerId, data.groupIndex, data.indexInGroup, data.permission)
  elseif self.raidId then
    GroupsRequestBus.Broadcast.RequestSetRaidMemberPermission(data.characterId, data.permission)
  end
end
function RaidPanel:SetGroupData(groupIndex, groupId, iconIndex, colorIndex)
  if self.isShowingRoster or self.inWarRaid then
    RaidSetupRequestBus.Broadcast.RequestSetGroupData(groupIndex, 0, iconIndex, colorIndex, 0)
  elseif self.raidId then
    GroupsRequestBus.Broadcast.RequestSetGroupColor(groupId, iconIndex)
    GroupsRequestBus.Broadcast.RequestSetGroupIcon(groupId, colorIndex)
  end
end
function RaidPanel:CheckKickRaidMemberCooldown()
  local kickRaidMemberCooldown = RaidSetupRequestBus.Broadcast.GetKickRaidMemberCooldown()
  local now = TimePoint:Now()
  if kickRaidMemberCooldown > now then
    local cooldownRemainingSec = kickRaidMemberCooldown:Subtract(now):ToSeconds()
    local notificationText = GetLocalizedReplacementText("@ui_kick_raid_member_cooldown", {secRemaining = cooldownRemainingSec})
    local notificationData = NotificationData()
    notificationData.type = "Minor"
    notificationData.text = notificationText
    UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
    return false
  else
    return true
  end
end
function RaidPanel:RemovePlayer(data)
  if self.isShowingRoster or self.inWarRaid then
    RaidSetupRequestBus.Broadcast.RequestRemovePlayerFromRoster(data.playerId, data.groupIndex, data.indexInGroup)
  elseif self.raidId then
    GroupsRequestBus.Broadcast.RequestRemoveRaidMember(data.characterId)
  end
end
function RaidPanel:KickPlayer(data)
  if self:CheckKickRaidMemberCooldown() and (self.isShowingRoster or self.inWarRaid) then
    RaidSetupRequestBus.Broadcast.RequestKickPlayer(data.playerId)
  end
end
function RaidPanel:SetMemberToSlot(raidMember, targetRaidMember)
  if self.isShowingRoster or self.inWarRaid then
    if not targetRaidMember.groupIndex or targetRaidMember.groupIndex < 0 then
      Debug.Log("RaidPanel:SetMemberToSlot: invalid group index")
      return
    end
    if not raidMember.groupIndex then
      RaidSetupRequestBus.Broadcast.RequestAddPlayerToRoster(raidMember.playerId, targetRaidMember.groupIndex)
    elseif targetRaidMember.characterId then
      RaidSetupRequestBus.Broadcast.RequestSwapPlayers(raidMember.playerId, raidMember.groupIndex, raidMember.indexInGroup, targetRaidMember.playerId, targetRaidMember.groupIndex, targetRaidMember.indexInGroup)
    else
      RaidSetupRequestBus.Broadcast.RequestMovePlayer(raidMember.playerId, raidMember.groupIndex, raidMember.indexInGroup, targetRaidMember.groupIndex)
    end
  elseif self.raidId then
    if targetRaidMember.characterId then
      GroupsRequestBus.Broadcast.RequestSwapRaidMembers(raidMember.characterId, targetRaidMember.characterId)
    else
      GroupsRequestBus.Broadcast.RequestMoveRaidMember(raidMember.characterId, targetRaidMember.groupIndex)
    end
  end
end
function RaidPanel:UpdateActiveRaid()
  for index = 1, #self.groupIds do
    self.Groups[index - 1]:SetGroupData(index - 1, self.groupIds[index])
  end
end
function RaidPanel:GetNumElements()
  return #self.playerIdList
end
function RaidPanel:OnElementBecomingVisible(entityId, index)
  local matchItem = self.registrar:GetEntityTable(entityId)
  if matchItem then
    matchItem:SetData(self.playerIdList[index + 1], false, index + 1)
  end
end
function RaidPanel:OnGetRaidMembers(raidData)
  ClearTable(self.raidMembers)
  for i = 1, #raidData do
    for j = 1, #raidData[i] do
      self.Groups[i - 1].Members[j - 1]:SetName(raidData[i][j].playerName, raidData[i][j], true)
      table.insert(self.raidMembers, raidData[i][j].playerName)
    end
  end
end
function RaidPanel:OnUpdateMatchingList(list)
  ClearTable(self.playerIdList)
  if list then
    local inRaid = false
    for i = 1, #list do
      inRaid = false
      for j = 1, #self.raidMembers do
        if self.raidMembers[j] == list[i] then
          inRaid = true
          break
        end
      end
      if not inRaid then
        table.insert(self.playerIdList, list[i])
      end
    end
  end
  UiDynamicScrollBoxBus.Event.RefreshContent(self.Properties.RaidContainer)
end
function RaidPanel:SetEnabled(enable)
  if self.isEnabled ~= enable then
    UiElementBus.Event.SetIsEnabled(self.entityId, enable)
    self.isEnabled = enable
    if not self.isEnabled then
      self:UnregisterObservers()
      self:StopTick()
      if self.leaveRaidEventId then
        PopupWrapper:KillPopup(self.leaveRaidEventId)
        self.leaveRaidEventId = nil
      end
    end
  end
end
function RaidPanel:FillRoster()
  RaidSetupRequestBus.Broadcast.RequestFillRoster()
end
function RaidPanel:SignUp()
  local warDetails = WarDataServiceBus.Broadcast.GetWarForTerritory(self.territoryId)
  local siegeTime = warDetails:GetConquestStartTime()
  local siegeDuration = dominionCommon:GetSiegeDuration()
  local territories = RaidSetupRequestBus.Broadcast.GetSignedUpTerritories()
  for i = 1, #territories do
    local otherWarDetails = WarDataServiceBus.Broadcast.GetWarForTerritory(territories[i])
    local otherSiegeTime = otherWarDetails:GetConquestStartTime()
    if siegeDuration > math.abs(otherSiegeTime:Subtract(siegeTime):ToSeconds()) then
      self.territoryToLeaveFrom = territories[i]
      local confirmationText = GetLocalizedReplacementText("@ui_siege_signup_conquest_overlap_confirm", {
        territoryName = TerritoryDataHandler:GetTerritoryNameFromTerritoryId(self.territoryToLeaveFrom)
      })
      PopupWrapper:RequestPopup(ePopupButtons_YesNo, "@ui_siege_signup_conquest_overlap_title", confirmationText, self.onLeaveOtherWarEventId, self, self.OnPopupResult)
      return
    end
  end
  RaidSetupRequestBus.Broadcast.RequestSignup(self.side)
end
function RaidPanel:OnPopupResult(result, eventId)
  if result ~= ePopupResult_Yes then
    return
  end
  if eventId == self.onLeaveOtherWarEventId then
    RaidSetupRequestBus.Broadcast.RequestLeave(self.territoryToLeaveFrom)
  end
end
function RaidPanel:ConvertToRaid()
  GroupsRequestBus.Broadcast.RequestConvertToRaid()
end
function RaidPanel:LeaveRaid()
  if self.isShowingRoster then
    self.leaveRaidEventId = "LeaveRaid"
    local raidId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Raid.Id")
    if raidId and raidId:IsValid() then
      local warDetails = WarDataServiceBus.Broadcast.GetWarForTerritory(self.territoryId)
      if warDetails and warDetails:IsRaidInWar(raidId) then
        PopupWrapper:RequestPopup(ePopupButtons_YesNo, "@ui_siege_abandon_title", "@ui_siege_abandon_message", self.leaveRaidEventId, self, self.OnAbandonSignupResult)
      end
    else
      PopupWrapper:RequestPopup(ePopupButtons_YesNo, "@ui_siege_signup_abandon_title", "@ui_siege_signup_abandon_message", self.leaveRaidEventId, self, self.OnAbandonSignupResult)
    end
  elseif self.raidId then
    self.leaveRaidEventId = "LeaveRaid"
    PopupWrapper:RequestPopup(ePopupButtons_YesNo, "@ui_leavegrouppopuptitle", "@ui_leavegrouppopupmessage", self.leaveRaidEventId, self, self.OnLeaveGroupResult)
  end
end
function RaidPanel:OnLeaveGroupResult(result, eventId)
  self.leaveRaidEventId = nil
  if result ~= ePopupResult_Yes then
    return
  end
  GroupsRequestBus.Broadcast.RequestLeaveGroup()
end
function RaidPanel:OnAbandonSignupResult(result, eventId)
  self.leaveRaidEventId = nil
  if result ~= ePopupResult_Yes then
    return
  end
  RaidSetupRequestBus.Broadcast.RequestLeave(self.territoryId)
end
function RaidPanel:OnStartEdit()
  self.SearchInputField:OnStartEdit()
end
function RaidPanel:OnEndEdit()
  self.SearchInputField:OnEndEdit()
end
function RaidPanel:OnTextInputChange(text)
end
function RaidPanel:RefreshRaid()
  if self.isShowingRoster then
    local roster = RaidSetupRequestBus.Broadcast.GetRoster()
    self:OnRosterChanged(roster)
    RaidSetupRequestBus.Broadcast.RequestRoster()
    RaidSetupRequestBus.Broadcast.RequestSignupList(self.currentPage)
    self.timer = 0
  else
    self:UpdateActiveRaid()
  end
end
return RaidPanel
