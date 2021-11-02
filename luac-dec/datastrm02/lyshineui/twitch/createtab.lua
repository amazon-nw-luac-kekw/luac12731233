local CreateTab = {
  Properties = {
    SetupContainer = {
      default = EntityId(),
      order = 0
    },
    WaitingContainer = {
      default = EntityId(),
      order = 1
    },
    SelectionContainer = {
      default = EntityId(),
      order = 2
    },
    WindowSubtitle = {
      default = EntityId(),
      order = 3
    },
    SetupView = {
      OptionsRadioGroup = {
        default = EntityId()
      },
      OptionsRadioButtons = {
        SubscribersAndFollowers = {
          default = EntityId(),
          order = 0
        },
        Subscribers = {
          default = EntityId(),
          order = 1
        },
        Followers = {
          default = EntityId(),
          order = 2
        },
        Public = {
          default = EntityId(),
          order = 3
        }
      },
      StartSessionButton = {
        default = EntityId()
      },
      StartButtonSpinner = {
        default = EntityId()
      }
    },
    WaitingView = {
      WaitingSpinner = {
        default = EntityId(),
        order = 0
      },
      RequestCount = {
        default = EntityId(),
        order = 1
      },
      TimeRemaining = {
        default = EntityId(),
        order = 2
      },
      ContinueButton = {
        default = EntityId(),
        order = 3
      }
    },
    SelectionView = {
      SelectionList = {
        default = EntityId(),
        order = 0
      },
      GroupInviteButton = {
        default = EntityId(),
        order = 1
      },
      CompanyInviteButton = {
        default = EntityId(),
        order = 2
      },
      DeclineButton = {
        default = EntityId(),
        order = 3
      },
      StopSessionButton = {
        default = EntityId(),
        order = 4
      },
      SpinnerContainer = {
        default = EntityId(),
        order = 5
      },
      WaitingSpinner = {
        default = EntityId(),
        order = 6
      }
    }
  },
  currentView = nil,
  transitionInCallbacks = {},
  transitionOutCallbacks = {},
  selectedOption = nil,
  joinListMax = 200,
  waitTimeMax = 120,
  remainingWaitTime = 0,
  pollRate = 10,
  timer = 0,
  selectionEntities = {},
  selectedItems = {}
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(CreateTab)
local Spawner = RequireScript("LyShineUI._Common.Spawner")
Spawner:AttachSpawner(CreateTab)
local SocialDataHandler = RequireScript("LyShineUI._Common.SocialDataHandler")
function CreateTab:OnInit()
  BaseElement.OnInit(self)
  self.joinListMax = ConfigProviderEventBus.Broadcast.GetInt("javelin.twitch-subarmy-max-signups")
  self.transitionInCallbacks = {
    [self.SetupContainer] = self.OnSetupTransitionIn,
    [self.WaitingContainer] = self.OnWaitingTransitionIn,
    [self.SelectionContainer] = self.OnSelectionTransitionIn
  }
  self.transitionOutCallbacks = {
    [self.SetupContainer] = self.OnSetupTransitionOut,
    [self.WaitingContainer] = self.OnWaitingTransitionOut,
    [self.SelectionContainer] = self.OnSelectionTransitionOut
  }
  self:BusConnect(TwitchSystemNotificationBus)
  self:BusConnect(TwitchSubArmyNotificationBus)
  self:InitSetupView()
  self:InitWaitingView()
  self:InitSelectionView()
  self:SetCurrentView(self.SetupContainer)
  self.WaitingView.ContinueButton:SetButtonStyle(self.WaitingView.ContinueButton.BUTTON_STYLE_CTA)
  self.SelectionView.GroupInviteButton:SetButtonStyle(self.SelectionView.GroupInviteButton.BUTTON_STYLE_CTA)
  self.SelectionView.CompanyInviteButton:SetButtonStyle(self.SelectionView.CompanyInviteButton.BUTTON_STYLE_CTA)
end
function CreateTab:OnLoginStateChangedScript(isLoggedIn)
  self:SetCurrentView(self.SetupContainer)
  self:ClearList()
end
function CreateTab:SetCurrentView(viewContainer)
  if not viewContainer then
    return
  end
  UiElementBus.Event.SetIsEnabled(self.SetupContainer, viewContainer == self.SetupContainer)
  UiElementBus.Event.SetIsEnabled(self.WaitingContainer, viewContainer == self.WaitingContainer)
  UiElementBus.Event.SetIsEnabled(self.SelectionContainer, viewContainer == self.SelectionContainer)
  if self.currentView then
    self.transitionOutCallbacks[self.currentView](self)
  end
  self.currentView = viewContainer
  self.transitionInCallbacks[self.currentView](self)
end
function CreateTab:OnTick(deltaTime, timePoint)
  if self.currentView == self.WaitingContainer then
    self:TickRemainingTime(deltaTime, timePoint)
  end
  if self.currentView == self.WaitingContainer or self.currentView == self.SelectionContainer then
    self.timer = self.timer + deltaTime
    if self.timer >= self.pollRate then
      self.timer = self.timer - self.pollRate
      TwitchSubArmyRequestBus.Broadcast.RequestJoinList()
    end
  end
end
function CreateTab:OnCreateScreenVisisble(isVisible)
  UiElementBus.Event.SetIsEnabled(self.entityId, isVisible)
  if isVisible then
    if not self.tickHandler then
      self.tickHandler = self:BusConnect(DynamicBus.UITickBus)
    end
  elseif self.tickHandler then
    self:BusDisconnect(self.tickHandler)
    self.tickHandler = nil
  end
end
function CreateTab:GetSubtitle()
  return self.subtitle or ""
end
function CreateTab:OnJoinListReceived(joinList)
  local count = #joinList
  self.subtitle = LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement("@ui_subarmy_subtitle_requests", tostring(count))
  if UiElementBus.Event.IsEnabled(self.entityId) then
    UiTextBus.Event.SetTextWithFlags(self.WindowSubtitle, self.subtitle, eUiTextSet_SetAsIs)
  end
  self:SetRequestCountText(count)
  self:SetPlayerList(joinList)
end
function CreateTab:InitSetupView()
  local allowPublicSessions = ConfigProviderEventBus.Broadcast.GetBool("javelin.twitch-subarmy-allow-public-sessions")
  UiElementBus.Event.SetIsEnabled(self.SetupView.OptionsRadioButtons.Public.entityId, allowPublicSessions)
  self.optionsEntityMap = {
    [tostring(self.SetupView.OptionsRadioButtons.SubscribersAndFollowers.entityId)] = eSubArmyViewType_SubscribersAndFollowers,
    [tostring(self.SetupView.OptionsRadioButtons.Subscribers.entityId)] = eSubArmyViewType_Subscribers,
    [tostring(self.SetupView.OptionsRadioButtons.Followers.entityId)] = eSubArmyViewType_Followers,
    [tostring(self.SetupView.OptionsRadioButtons.Public.entityId)] = eSubArmyViewType_Public
  }
  local selectedEntityId = self.SetupView.OptionsRadioButtons.SubscribersAndFollowers.entityId
  UiRadioButtonGroupBus.Event.SetState(self.SetupView.OptionsRadioGroup, selectedEntityId, true)
  self.selectedOption = self.optionsEntityMap[tostring(selectedEntityId)]
  self:BusConnect(UiRadioButtonGroupNotificationBus, self.SetupView.OptionsRadioGroup)
  self.SetupView.StartSessionButton:SetCallback("OnStartSessionButton", self)
  self.SetupView.StartSessionButton:SetButtonStyle(self.SetupView.StartSessionButton.BUTTON_STYLE_TWITCH)
end
function CreateTab:OnSetupTransitionIn()
  self.subtitle = ""
  if UiElementBus.Event.IsEnabled(self.entityId) then
    UiTextBus.Event.SetTextWithFlags(self.WindowSubtitle, self.subtitle, eUiTextSet_SetAsIs)
  end
  self.SetupView.StartSessionButton:SetEnabled(true)
  UiElementBus.Event.SetIsEnabled(self.SetupView.StartButtonSpinner, false)
end
function CreateTab:OnSetupTransitionOut()
end
function CreateTab:OnRadioButtonGroupStateChange(checkedEntityId)
  self.selectedOption = self.optionsEntityMap[tostring(checkedEntityId)]
end
function CreateTab:OnStartSessionButton()
  TwitchSubArmyRequestBus.Broadcast.RequestStartSubArmy(self.selectedOption)
  self.SetupView.StartSessionButton:SetEnabled(false)
  self.SelectionView.GroupInviteButton:SetEnabled(false)
  self.SelectionView.CompanyInviteButton:SetEnabled(false)
  UiElementBus.Event.SetIsEnabled(self.SetupView.StartButtonSpinner, true)
  self.ScriptedEntityTweener:Set(self.SetupView.StartButtonSpinner, {rotation = 0})
  self.ScriptedEntityTweener:Play(self.SetupView.StartButtonSpinner, 1, {timesToPlay = -1, rotation = 359})
end
function CreateTab:OnStartSubArmyResultReceived(success)
  if success then
    self:SetCurrentView(self.SelectionContainer)
  else
    local notificationData = NotificationData()
    notificationData.type = "Minor"
    notificationData.text = "@ui_subarmy_failed_to_start"
    UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
    self.SetupView.StartSessionButton:SetEnabled(true)
    UiElementBus.Event.SetIsEnabled(self.SetupView.StartButtonSpinner, false)
  end
end
function CreateTab:InitWaitingView()
  self.WaitingView.ContinueButton:SetCallback(self.OnContinueButton, self)
  self.ScriptedEntityTweener:Set(self.WaitingView.WaitingSpinner, {rotation = 0})
  self.ScriptedEntityTweener:Play(self.WaitingView.WaitingSpinner, 4, {timesToPlay = -1, rotation = 359})
end
function CreateTab:OnWaitingTransitionIn()
  self:OnJoinListReceived({})
  self:SetRequestCountText(0)
  self:SetRemainingTimeText(self.waitTimeMax)
  self.remainingWaitTime = self.waitTimeMax
end
function CreateTab:OnWaitingTransitionOut()
end
function CreateTab:TickRemainingTime(deltaTime, timePoint)
  if self.remainingWaitTime > 0 then
    self.remainingWaitTime = self.remainingWaitTime - deltaTime
    if self.remainingWaitTime <= 0 then
      self:SetCurrentView(self.SelectionContainer)
    end
    self:SetRemainingTimeText(self.remainingWaitTime)
  end
end
function CreateTab:SetRemainingTimeText(time)
  local timeString = string.format("%d:%02d", time / 60, time % 60)
  UiTextBus.Event.SetTextWithFlags(self.WaitingView.TimeRemaining, timeString, eUiTextSet_SetAsIs)
end
function CreateTab:SetRequestCountText(count)
  local countString = string.format("%d / %d", count, self.joinListMax)
  UiTextBus.Event.SetTextWithFlags(self.WaitingView.RequestCount, countString, eUiTextSet_SetAsIs)
end
function CreateTab:OnContinueButton()
  self:SetCurrentView(self.SelectionContainer)
end
function CreateTab:InitSelectionView()
  self:ClearList()
  self:BusConnect(UiSpawnerNotificationBus, self.SelectionView.SelectionList)
  self.SelectionView.GroupInviteButton:SetCallback("OnGroupInviteButton", self)
  self.SelectionView.CompanyInviteButton:SetCallback("OnCompanyInviteButton", self)
  self.SelectionView.DeclineButton:SetCallback("OnDeclineButton", self)
  self.SelectionView.StopSessionButton:SetCallback("OnStopSessionButton", self)
  self.SelectionView.GroupInviteButton:SetEnabled(false)
  self.SelectionView.CompanyInviteButton:SetEnabled(false)
  self.SelectionView.DeclineButton:SetIsClickable(false)
  self.SelectionView.StopSessionButton:SetButtonStyle(self.SelectionView.StopSessionButton.BUTTON_STYLE_TWITCH)
  UiElementBus.Event.SetIsEnabled(self.SelectionView.SpinnerContainer, true)
  self.ScriptedEntityTweener:Set(self.SelectionView.WaitingSpinner, {rotation = 0})
  self.ScriptedEntityTweener:Play(self.SelectionView.WaitingSpinner, 4, {timesToPlay = -1, rotation = 359})
end
function CreateTab:OnSelectionTransitionIn()
end
function CreateTab:OnSelectionTransitionOut()
end
function CreateTab:ClearList()
  local children = UiElementBus.Event.GetChildren(self.SelectionView.SelectionList)
  for i = 1, #children do
    UiElementBus.Event.DestroyElement(children[i])
  end
  self.selectionEntities = {}
end
function CreateTab:SetPlayerList(playerList)
  if not playerList then
    return
  end
  if 0 < #playerList then
    UiElementBus.Event.SetIsEnabled(self.SelectionView.SpinnerContainer, false)
  else
    UiElementBus.Event.SetIsEnabled(self.SelectionView.SpinnerContainer, true)
  end
  for i = 1, #playerList do
    local selectionItem = playerList[i]
    local data = {
      playerName = selectionItem.playerName,
      twitchName = selectionItem.twitchName,
      inviteStatus = selectionItem.inviteStatus
    }
    local entityId = self.selectionEntities[selectionItem.playerName]
    if entityId then
      local entity = self.registrar:GetEntityTable(entityId)
      self:OnSelectionItemSpawned(entity, data)
    else
      self:SpawnSlice(self.SelectionView.SelectionList, "LyShineUI\\Twitch\\SelectionItem", self.OnSelectionItemSpawned, data)
    end
  end
end
function CreateTab:OnSelectionItemSpawned(entity, data)
  self.selectionEntities[data.playerName] = entity.entityId
  entity:SetPlayerName(data.playerName)
  entity:SetTwitchName(data.twitchName)
  entity:SetInviteStatus(data.inviteStatus)
  entity:SetCallback(self, self.OnSelectionChanged)
end
function CreateTab:OnSelectionChanged(entity, checked)
  local players = self:GetSelectedPlayerList()
  local enableButtons = 0 < #players
  local localPlayerFaction = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Faction")
  local localPlayerPvpFlag = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.PvpFlag")
  local localPlayerGuildId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Guild.Id")
  local isInGuild = localPlayerGuildId and localPlayerGuildId:IsValid()
  local selectedSameFaction = 0 < #players
  for i = 1, #players do
    selectedSameFaction = selectedSameFaction and players[i].playerFaction == localPlayerFaction
  end
  local pvpGroupAllowance = localPlayerPvpFlag == ePvpFlag_Off or selectedSameFaction
  local groupInviteButtonEnabled = enableButtons and pvpGroupAllowance
  local companyInviteButtonEnabled = enableButtons and isInGuild and selectedSameFaction
  local groupInviteText = groupInviteButtonEnabled and "@ui_subarmy_invite_to_group_enabled" or "@ui_subarmy_invite_to_group"
  local companyInviteText = companyInviteButtonEnabled and "@ui_subarmy_invite_to_company_enabled" or "@ui_subarmy_invite_to_company"
  local companyInviteTooltip = not isInGuild and "@ui_subarmy_invite_to_company_no_company" or nil
  self.SelectionView.GroupInviteButton:SetEnabled(groupInviteButtonEnabled)
  self.SelectionView.GroupInviteButton:SetText(groupInviteText)
  self.SelectionView.CompanyInviteButton:SetEnabled(companyInviteButtonEnabled)
  self.SelectionView.CompanyInviteButton:SetText(companyInviteText)
  if companyInviteTooltip then
    self.SelectionView.CompanyInviteButton:SetTooltip(companyInviteTooltip)
  end
  self.SelectionView.DeclineButton:SetIsClickable(enableButtons)
end
function CreateTab:GetSelectedPlayerList()
  local players = {}
  local children = UiElementBus.Event.GetChildren(self.SelectionView.SelectionList)
  for i = 1, #children do
    local entity = self.registrar:GetEntityTable(children[i])
    if entity:IsSelected() then
      local data = {
        playerName = entity:GetPlayerName(),
        playerFaction = entity:GetPlayerFaction(),
        characterIdString = entity:GetCharacterIdString(),
        twitchName = entity:GetTwitchName(),
        entity = entity
      }
      table.insert(players, data)
    end
  end
  return players
end
function CreateTab:PrepareInvitations(type)
  local players = self:GetSelectedPlayerList()
  local invitingCharacterIds = vector_basic_string_char_char_traits_char()
  for i = 1, #players do
    local item = players[i]
    invitingCharacterIds:push_back(item.characterIdString)
    TwitchSubArmyRequestBus.Broadcast.UpdateJoinEntry(item.twitchName, eSubArmyInviteStatus_Accepted)
    item.entity:SetInviteStatus(eSubArmyInviteStatus_Accepted)
    if type == "Group" then
      item.entity.groupInviteSent = true
    elseif type == "Guild" then
      item.entity.guildInviteSent = true
    end
  end
  return invitingCharacterIds
end
function CreateTab:OnGroupInviteButton()
  local invitingCharacterIds = self:PrepareInvitations("Group")
  GroupsRequestBus.Broadcast.RequestBatchDurableGroupInvites(invitingCharacterIds)
end
function CreateTab:OnCompanyInviteButton()
  local invitingCharacterIds = self:PrepareInvitations("Guild")
  GuildsComponentBus.Broadcast.RequestBatchGuildInvites(invitingCharacterIds)
end
function CreateTab:OnDeclineButton()
  self:ForEachSelectedPlayer(function(self, item)
    TwitchSubArmyRequestBus.Broadcast.UpdateJoinEntry(item.twitchName, eSubArmyInviteStatus_Declined)
  end)
end
function CreateTab:OnStopSessionButton()
  TwitchSubArmyRequestBus.Broadcast.EndSubArmy()
  self:SetCurrentView(self.SetupContainer)
  self:ClearList()
end
return CreateTab
