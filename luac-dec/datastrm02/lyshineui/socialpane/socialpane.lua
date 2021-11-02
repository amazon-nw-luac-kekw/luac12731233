local timeHelpers = RequireScript("LyShineUI._Common.TimeHelperFunctions")
local dominionCommon = RequireScript("LyShineUI._Common.DominionCommon")
local TerritoryDataHandler = RequireScript("LyShineUI._Common.TerritoryDataHandler")
local PopupWrapper = RequireScript("LyShineUI.Popup.PopupRequestWrapper")
local tweenerCommon = RequireScript("LyShineUI._Common.ScriptedEntityTweenerCommon")
local FactionCommon = RequireScript("LyShineUI._Common.FactionCommon")
local GameModeCommon = RequireScript("LyShineUI._Common.GameModeCommon")
local EFlyoutMenuTypes = {None = 0, Group = 1}
local EVoipState = {
  Disabled = 0,
  PendingJoinWorldChannel = 1,
  WorldChannel = 2,
  PendingJoinGroupChannel = 3,
  GroupChannel = 4
}
local SocialPane = {
  Properties = {
    Background = {
      default = EntityId()
    },
    GroupHealthEntities = {
      default = {
        EntityId()
      }
    },
    GroupFitter = {
      default = EntityId()
    },
    GroupAlertMessage = {
      default = EntityId()
    },
    ArmyHintContainer = {
      default = EntityId()
    },
    ArmyHint = {
      default = EntityId()
    },
    ArmyHintVisibility = {
      default = EntityId()
    },
    Pane = {
      default = EntityId()
    },
    ToolTipContainer = {
      default = EntityId()
    },
    ToolTipText = {
      default = EntityId()
    },
    NewInviteIndicator = {
      default = EntityId()
    },
    NewInviteButton = {
      default = EntityId()
    },
    SocialMenu = {
      default = EntityId()
    },
    SubArmyMenu = {
      default = EntityId()
    },
    DisabledContainer = {
      default = EntityId()
    },
    GroupHealthContainer = {
      default = EntityId()
    },
    GroupVoip = {
      default = EntityId()
    },
    GroupVoipParent = {
      default = EntityId()
    },
    ToggleGroupVoipButton = {
      default = EntityId()
    },
    ToggleGroupVoipPip = {
      default = EntityId()
    },
    ToggleGroupVoipBg = {
      default = EntityId()
    },
    ToggleHoverGlow = {
      default = EntityId()
    },
    ToggleTextOn = {
      default = EntityId()
    },
    ToggleTextOff = {
      default = EntityId()
    },
    ToggleTextLabel = {
      default = EntityId()
    },
    ButtonContainer = {
      default = EntityId()
    },
    AddToGroupButton = {
      default = EntityId()
    },
    AddToGroupButtonText = {
      default = EntityId()
    },
    LeaveGroupButton = {
      default = EntityId()
    },
    OnlineListContainer = {
      default = EntityId()
    },
    SpotlightContainer = {
      default = EntityId()
    },
    SpotLightButton = {
      default = EntityId()
    },
    SpotlightIcon = {
      default = EntityId()
    },
    SpotlightLabel = {
      default = EntityId()
    },
    SocialAlarmIndicator = {
      default = EntityId()
    },
    AlarmIconEffect = {
      default = EntityId()
    },
    AlarmIconEffectStatic = {
      default = EntityId()
    },
    AlarmIconRing = {
      default = EntityId()
    }
  },
  inviteNotifications = {},
  groupMembers = {},
  localPlayerGroupEntity = nil,
  onAcceptPopupEventId = "Popup_OnAcceptDuringWar",
  onLeavePopupEventId = "Popup_OnLeave",
  onMutePlayerEventId = "Popup_OnSocialPaneMutePlayer",
  onUnmutePlayerEventId = "Popup_OnSocialPaneUnmutePlayer",
  onBlockPlayerEventId = "Popup_OnSocialPaneBlockPlayer",
  onUnblockPlayerEventId = "Popup_OnSocialPaneUnblockPlayer",
  onInvitePlayerEventId = "Popup_OnSocialPaneInvitePlayer",
  isShowing = false,
  maxMemberCount = 5,
  memberCount = -1,
  playerToMute = nil,
  playerToUnmute = nil,
  playerToBlock = nil,
  playerToUnblock = nil,
  currentFlyoutMenuType = EFlyoutMenuTypes.None,
  currentVoipState = EVoipState.Disabled,
  mainBgWidth = 90,
  socialButtonPath = "lyshineui/images/socialpane/socialpane_buttonsocial.dds",
  socialButtonBackgroundPath = "lyshineui/images/socialpane/socialpane_buttonbg.dds",
  groupBusHandler = nil,
  screenStatesToHide = {
    [2478623298] = true,
    [2972535350] = true,
    [3349343259] = true,
    [2552344588] = true,
    [513315479] = true,
    [476411249] = true,
    [2230605386] = true,
    [3024636726] = true,
    [2901616697] = true,
    [3016573086] = true,
    [2230605386] = true,
    [3406343509] = true,
    [2477632187] = true,
    [3493198471] = true,
    [2815678723] = true,
    [3175660710] = true,
    [156281203] = true,
    [849925872] = true,
    [640726528] = true,
    [3370453353] = true,
    [3211015753] = true,
    [2640373987] = true,
    [2437603339] = true,
    [1319313135] = true,
    [1468490675] = true,
    [1101180544] = true,
    [3664731564] = true,
    [4119896358] = true,
    [319051850] = true,
    [2609973752] = true,
    [1634988588] = true,
    [319051850] = true,
    [921202721] = true
  },
  screenStatesToHideGroupHealthBars = {
    [3766762380] = true,
    [1967160747] = true,
    [3576764016] = true,
    [1643432462] = true,
    [1823500652] = true,
    [3784122317] = true,
    [4283914359] = true
  }
}
local BaseScreen = RequireScript("LyShineUI._Common.BaseScreen")
BaseScreen:CreateNewScreen(SocialPane)
local Spawner = RequireScript("LyShineUI._Common.Spawner")
Spawner:AttachSpawner(SocialPane)
RequireScript("LyShineUI.FlyoutMenu.FlyoutMenuHelper")
local warDeclarationPopupHelper = RequireScript("LyShineUI.WarDeclaration.WarDeclarationPopupHelper")
local SocialDataHandler = RequireScript("LyShineUI._Common.SocialDataHandler")
local cryActionCommon = RequireScript("LyShineUI._Common.CryActionCommon")
local CanvasCommon = RequireScript("LyShineUI._Common.CanvasCommon")
local invalidEntityId = EntityId()
function SocialPane:OnInit()
  BaseScreen.OnInit(self)
  self.socialDataHandler = SocialDataHandler
  DynamicBus.SocialPaneBus.Connect(self.entityId, self)
  UiCanvasBus.Event.SetIsPositionalInputSupported(self.canvasId, false)
  self.initialDrawOrder = UiCanvasBus.Event.GetDrawOrder(self.canvasId)
  AdjustElementToCanvasSize(self.entityId, self.canvasId)
  self:BusConnect(UiCanvasSizeNotificationBus, self.canvasId)
  self.ScriptedEntityTweener:Set(self.Properties.Pane, {
    opacity = 0,
    x = -self.mainBgWidth
  })
  self.ScriptedEntityTweener:Set(self.Properties.NewInviteIndicator, {
    opacity = 0,
    x = -self.mainBgWidth
  })
  self.ScriptedEntityTweener:Set(self.Properties.ButtonContainer, {
    opacity = 0,
    x = -self.mainBgWidth
  })
  self.ScriptedEntityTweener:Set(self.Properties.GroupVoipParent, {
    opacity = 0,
    x = -self.mainBgWidth
  })
  self.ScriptedEntityTweener:Set(self.Properties.SpotlightContainer, {
    opacity = 0,
    x = -self.mainBgWidth
  })
  self:BusConnect(DynamicBus.UITickBus)
  self:BusConnect(LoadScreenNotificationBus, self.entityId)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.GDERootEntityId", function(self, rootPlayerId)
    if not rootPlayerId then
      return
    end
    self.playerRootEntityId = rootPlayerId
    self:BusDisconnect(self.participantBusHandler)
    self.participantBusHandler = self:BusConnect(GameModeParticipantComponentNotificationBus, rootPlayerId)
    self:UpdateGroupButtons()
    self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.PvpFlag", function(self, pvpFlag)
      if not pvpFlag then
        return
      end
      self.isPvpFlaggedOrPending = FactionRequestBus.Event.IsPvpFlaggedOrPending(self.playerRootEntityId)
      local text = self.isPvpFlaggedOrPending and "@ui_pvp_group" or "@ui_group"
      UiTextBus.Event.SetTextWithFlags(self.Properties.AddToGroupButtonText, text, eUiTextSet_SetLocalized)
      local tooltip = self.isPvpFlaggedOrPending and "@ui_invitetopvpgroup_tooltip" or "@ui_invitetopvegroup_tooltip"
      self.AddToGroupButton:SetTooltip(tooltip)
      self:UpdateGroupNotifications()
    end)
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Raid.Id", function(self, raidId)
    self.isInRaid = raidId and raidId:IsValid()
    self:CheckArmyHintVisibility()
    self:UpdateGroupButtons()
  end)
  local keybinding = LyShineManagerBus.Broadcast.GetKeybind("toggleRaidWindow", "ui")
  self.ArmyHint:SetText(keybinding)
  self.enableDominion = false
  self.dataLayer:RegisterAndExecuteObserver(self, "UIFeatures.g_enableDominion", function(self, dataNode)
    self.enableDominion = dataNode and dataNode:GetData()
  end)
  self.enableReport = false
  self.dataLayer:RegisterAndExecuteDataObserver(self, "UIFeatures.g_uiEnableReportPlayer", function(self, data)
    self.enableReport = data
  end)
  self:InitVoipUI()
  self.groupMembers = {}
  for i = 0, #self.GroupHealthEntities do
    local entityTable = self.GroupHealthEntities[i]
    if entityTable then
      self.groupMembers[#self.groupMembers + 1] = {entity = entityTable}
    end
  end
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Group.Id", self.GroupIdChanged)
  self.dataLayer:RegisterDataCallback(self, "Hud.LocalPlayer.Group.Invites.Inbound.Added", self.OnNewGroupInvite)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Options.Twitch.Login", function(self, spotlightEnabled)
    local twitchSystemEnabled = self.dataLayer:GetDataFromNode("UIFeatures.g_enableTwitchSystem")
    if twitchSystemEnabled and spotlightEnabled then
      UiElementBus.Event.SetIsEnabled(self.Properties.SpotlightContainer, true)
      UiElementBus.Event.Reparent(self.Properties.SpotlightContainer, self.Properties.GroupFitter, self.Properties.GroupHealthContainer)
    else
      UiElementBus.Event.Reparent(self.Properties.SpotlightContainer, self.Properties.DisabledContainer, invalidEntityId)
      UiElementBus.Event.SetIsEnabled(self.Properties.SpotlightContainer, false)
    end
  end)
  local spotlightFlagEnabled = self.dataLayer:GetDataFromNode("UIFeatures.g_enableTwitchSpotlight")
  if spotlightFlagEnabled then
    self:UpdateSpotlightPanel({
      isEnabled = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Options.Twitch.StreamerSpotlight") or false,
      isValidated = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Twitch.IsValidated") or false,
      isActive = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.TwitchStreamerSpotlight.IsActive") or false,
      isLive = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.TwitchStreamerSpotlight.IsLive") or false,
      numViewers = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.TwitchStreamerSpotlight.NumViewers") or -1
    })
  else
    self:UpdateSpotlightPanel({isEnabled = false})
  end
  self.dataLayer:RegisterDataObserver(self, "Hud.LocalPlayer.Options.Twitch.StreamerSpotlight", function(self, isEnabled)
    self:UpdateSpotlightPanel({isEnabled = isEnabled})
  end)
  self.dataLayer:RegisterDataObserver(self, "Hud.LocalPlayer.Twitch.IsValidated", function(self, isValidated)
    self:UpdateSpotlightPanel({isValidated = isValidated})
  end)
  self.dataLayer:RegisterDataObserver(self, "Hud.LocalPlayer.TwitchStreamerSpotlight.NumViewers", function(self, numViewers)
    self:UpdateSpotlightPanel({numViewers = numViewers})
  end)
  self.dataLayer:RegisterDataObserver(self, "Hud.LocalPlayer.TwitchStreamerSpotlight.IsLive", function(self, isLive)
    self:UpdateSpotlightPanel({isLive = isLive})
  end)
  self.dataLayer:RegisterDataObserver(self, "Hud.LocalPlayer.TwitchStreamerSpotlight.isActive", function(self, isActive)
    self:UpdateSpotlightPanel({isActive = isActive})
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Options.Twitch.HideOtherStreamers", function(self, hidingStreamers)
    self.hidingStreamers = hidingStreamers
  end)
  self.isFtue = FtueSystemRequestBus.Broadcast.IsFtue()
  self.dataLayer:RegisterDataObserver(self, "Hud.LocalPlayer.SocialMenu.UpdateTotalInviteCount", self.UpdateTotalInviteCount)
  self:BusConnect(GroupsUINotificationBus)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Faction", function(self, factionType)
    if self.localPlayerFaction ~= factionType then
      self.localPlayerFaction = factionType
      for i = 1, self.memberCount do
        if self.groupMembers[i].entity.isLocalPlayer then
          self:OnMemberFactionChanged(i - 1, factionType)
          break
        end
      end
    end
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Options.Twitch.SubArmy", function(self, subArmyEnabled)
    UiElementBus.Event.SetIsEnabled(self.Properties.SpotLightButton, subArmyEnabled)
  end)
  cryActionCommon:RegisterActionListener(self, "toggleSocialWindow", 0, function(self, actionName, value)
    if FtueSystemRequestBus.Broadcast.IsFtue() then
      local notificationData = NotificationData()
      notificationData.type = "Minor"
      notificationData.text = LyShineScriptBindRequestBus.Broadcast.LocalizeText("@ftue_action_unavailable")
      notificationData.contextId = self.entityId
      notificationData.allowDuplicates = false
      UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
      return
    end
    if not self.SocialMenu.isEnabled then
      LyShineManagerBus.Broadcast.SetState(3766762380)
      self:ToggleSocialMenu()
    else
      LyShineManagerBus.Broadcast.SetState(2702338936)
    end
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Vitals.IsDead", function(self, isDead)
    self.isDead = isDead
    self:UpdateArmyHintVisibility()
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.Chat.Visibility", function(self, isVisible)
    self.isChatVisibleInHud = isVisible == true
    self:UpdateBackgroundVisibility()
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.Chat.WidgetStateEnabled", function(self, isEnabled)
    self.isChatWidgetEnabled = isEnabled == true
    self:UpdateBackgroundVisibility()
  end)
  self.AddToGroupButton:SetCallback(self.ClickAddToGroupButton, self)
  self.AddToGroupButton:SetIsUsingGlow(true)
  self.AddToGroupButton:SetBackgroundColorUnfocused(self.UIStyle.COLOR_WHITE)
  self.AddToGroupButton:SetBackgroundColorFocused(self.UIStyle.COLOR_WHITE)
  self.AddToGroupButton:SetIconColorUnfocused(self.UIStyle.COLOR_TAN)
  self.LeaveGroupButton:SetCallback(self.LeaveGroup, self)
  self.LeaveGroupButton:SetIsUsingGlow(true)
  self.LeaveGroupButton:SetBackgroundColorUnfocused(self.UIStyle.COLOR_RED)
  self.LeaveGroupButton:SetBackgroundColorFocused(self.UIStyle.COLOR_RED)
  self.LeaveGroupButton:SetIconColorUnfocused(self.UIStyle.COLOR_GRAY_70)
  self.NewInviteButton:SetCallback(self.ClickSocialMenuButton, self)
  self.NewInviteButton:SetIsUsingGlow(true)
  self.NewInviteButton:SetBackgroundPathname(self.socialButtonPath)
  self.NewInviteButton:SetBackgroundColorUnfocused(self.UIStyle.COLOR_WHITE)
  self.NewInviteButton:SetBackgroundColorFocused(self.UIStyle.COLOR_WHITE)
  self.NewInviteButton:SetSize(64, 64)
  self.NewInviteButton:SetIconPathname()
  self.SpotLightButton:SetCallback(self.ClickTwitchButton, self)
  self.SpotLightButton:SetIsUsingGlow(true)
  self.SpotLightButton:SetBackgroundPathname(self.socialButtonBackgroundPath)
  self.SpotLightButton:SetBackgroundColorUnfocused(self.UIStyle.COLOR_WHITE)
  self.SpotLightButton:SetBackgroundColorFocused(self.UIStyle.COLOR_WHITE)
  self.SpotLightButton:SetSize(64, 64)
  self.SpotLightButton:SetIconPathname()
end
function SocialPane:InitVoipUI()
  if VoiceChatControlBus.Broadcast.IsVoiceChatServiceActivated() then
    if VoiceChatControlBus.Broadcast.IsIn2dChannel() then
      self.currentVoipState = EVoipState.GroupChannel
    else
      self.currentVoipState = EVoipState.WorldChannel
    end
  else
    self.currentVoipState = EVoipState.Disabled
  end
  self.voipTimer = 0
  self.voipTimeout = 20
  self.voipLabelDefaultText = LyShineScriptBindRequestBus.Broadcast.LocalizeText("@ui_group_voice")
  self.voipLabelJoiningText = LyShineScriptBindRequestBus.Broadcast.LocalizeText("@ui_group_voice_joining")
  self:BusConnect(VoiceChatUiBus)
end
function SocialPane:UpdateTotalInviteCount(totalInviteCount)
  if totalInviteCount == nil then
    totalInviteCount = 0
  end
  if 0 < totalInviteCount then
    self:FadeInSocialAlarmIndicator()
  else
    self:FadeOutSocialAlarmIndicator()
  end
end
function SocialPane:UpdateGroupButtons()
  if not self.playerRootEntityId then
    return
  end
  local isInArena = PlayerArenaRequestBus.Event.IsInArena(self.playerRootEntityId)
  local isInDungeon = GameRequestsBus.Broadcast.IsInDungeonGameMode()
  local showAdd = not self.isInRaid and self.memberCount < self.maxMemberCount
  local showLeave = self.memberCount > 0
  local enableLeave = not isInArena and not isInDungeon
  UiElementBus.Event.SetIsEnabled(self.Properties.AddToGroupButton, showAdd)
  UiElementBus.Event.SetIsEnabled(self.Properties.LeaveGroupButton, showLeave)
  self.LeaveGroupButton:SetEnabled(enableLeave)
  self.ScriptedEntityTweener:Set(self.Properties.ButtonContainer, {
    y = showAdd and showLeave and 6 or -1
  })
  self.ScriptedEntityTweener:Set(self.Properties.AddToGroupButtonText, {
    y = showAdd and showLeave and 66 or 37
  })
  if showAdd and showLeave then
    self.AddToGroupButton:SetSize(40, 40)
    self.LeaveGroupButton:SetSize(40, 40)
    self.ScriptedEntityTweener:Set(self.Properties.AddToGroupButton, {y = -7})
    self.ScriptedEntityTweener:Set(self.Properties.LeaveGroupButton, {y = 30})
    self.ScriptedEntityTweener:Play(self.Properties.GroupVoipParent, 0, {y = -15})
  elseif showAdd then
    self.AddToGroupButton:SetSize(64, 64)
    self.ScriptedEntityTweener:Set(self.Properties.AddToGroupButton, {y = 0})
    self.ScriptedEntityTweener:Play(self.Properties.GroupVoipParent, 0, {y = -15})
  elseif showLeave then
    self.LeaveGroupButton:SetSize(40, 40)
    self.ScriptedEntityTweener:Set(self.Properties.LeaveGroupButton, {y = 0})
    self.ScriptedEntityTweener:Play(self.Properties.GroupVoipParent, 0, {y = -50})
  end
  local padding = UiLayoutColumnBus.Event.GetPadding(self.Properties.GroupHealthContainer)
  padding.left = self.memberCount >= self.maxMemberCount and 8 or 4
  UiLayoutColumnBus.Event.SetPadding(self.Properties.GroupHealthContainer, padding)
  for _, data in pairs(self.groupMembers) do
    data.entity:FullGroupAdjustment(self.memberCount >= self.maxMemberCount)
  end
  local tooltipText = "@ui_leavegroup"
  if self.gameModeId == GameModeCommon.GAMEMODE_OUTPOST_RUSH then
    tooltipText = "@ui_outpost_rush_leave"
  elseif self.isInRaid then
    tooltipText = "@ui_siege_abandon_title"
  elseif isInDungeon then
    tooltipText = "@ui_cannotleavegroup_in_dungeon"
  elseif isInArena then
    tooltipText = "@ui_cannotleavegroup_in_arena"
  end
  self.LeaveGroupButton:SetTooltip(tooltipText)
end
function SocialPane:UpdateSpotlightPanel(data)
  if data.isEnabled ~= nil then
    self.spotlightIsEnabled = data.isEnabled
  end
  if data.isValidated ~= nil then
    self.spotlightIsValidated = data.isValidated
  end
  if data.isActive ~= nil then
    self.spotlightIsActive = data.isActive
  end
  if data.isLive ~= nil then
    self.spotlightIsLive = data.isLive
  end
  if data.numViewers ~= nil then
    self.spotlightNumViewers = data.numViewers
  end
  if self.spotlightIsEnabled then
    if self.spotlightIsLive then
      UiImageBus.Event.SetColor(self.Properties.SpotlightIcon, self.UIStyle.COLOR_TWITCH_PURPLE)
      if self.spotlightNumViewers then
        local viewerString = LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement("@ui_spotlight_viewers", tostring(self.spotlightNumViewers))
        UiTextBus.Event.SetText(self.Properties.SpotlightLabel, viewerString)
      end
    elseif self.spotlightIsValidated and self.spotlightIsActive then
      UiImageBus.Event.SetColor(self.Properties.SpotlightIcon, self.UIStyle.COLOR_TAN_DARK)
      UiTextBus.Event.SetTextWithFlags(self.Properties.SpotlightLabel, "@ui_spotlight_connecting", eUiTextSet_SetLocalized)
    elseif not self.spotlightIsActive then
      UiImageBus.Event.SetColor(self.Properties.SpotlightIcon, self.UIStyle.COLOR_TAN_DARK)
      UiTextBus.Event.SetTextWithFlags(self.Properties.SpotlightLabel, "@ui_spotlight_notconnected", eUiTextSet_SetLocalized)
    else
      UiImageBus.Event.SetColor(self.Properties.SpotlightIcon, self.UIStyle.COLOR_RED_DARK)
      UiTextBus.Event.SetTextWithFlags(self.Properties.SpotlightLabel, "@ui_spotlight_error", eUiTextSet_SetLocalized)
    end
  else
    UiImageBus.Event.SetColor(self.Properties.SpotlightIcon, self.UIStyle.COLOR_TAN_DARK)
    UiTextBus.Event.SetTextWithFlags(self.Properties.SpotlightLabel, "@ui_twitch_logged_in", eUiTextSet_SetLocalized)
  end
  local spotlightLabelTextHeight = UiTextBus.Event.GetTextSize(self.Properties.SpotlightLabel).y
  UiTransform2dBus.Event.SetLocalHeight(self.Properties.SpotlightLabel, spotlightLabelTextHeight)
end
function SocialPane:UpdateBackgroundVisibility()
  UiElementBus.Event.SetIsEnabled(self.Properties.Background, not self.isChatVisibleInHud or self.isChatWidgetEnabled)
end
function SocialPane:ClickTwitchButton()
  local featureEnabled = self.dataLayer:GetDataFromNode("UIFeatures.g_enableTwitchSubArmy")
  local optionEnabled = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Options.Twitch.SubArmy")
  if featureEnabled and optionEnabled then
    self:ToggleSocialMenu("SubArmy")
  end
end
function SocialPane:OnShutdown()
  if self.toggleButtonTimeline ~= nil then
    self.toggleButtonTimeline:Stop()
    self.ScriptedEntityTweener:TimelineDestroy(self.toggleButtonTimeline)
  end
  DynamicBus.SocialPaneBus.Disconnect(self.entityId, self)
  BaseScreen.OnShutdown(self)
  cryActionCommon:UnregisterActionListener(self, "ui_interact")
end
function SocialPane:VisibilityChanged(isShowing)
  if self.isFtue then
    isShowing = false
  end
  self.isShowing = isShowing
  UiCanvasBus.Event.SetIsPositionalInputSupported(self.canvasId, self.isShowing)
  if self.hideSocialAlarm then
    self:HideSocialAlarmIndicator()
  end
  if self.isShowing then
    if self.currentDrawOrder then
      UiCanvasBus.Event.SetDrawOrder(self.canvasId, CanvasCommon.SOCIAL_PANE_DRAW_ORDER)
    end
    UiElementBus.Event.SetIsEnabled(self.Properties.Pane, true)
    UiElementBus.Event.SetIsEnabled(self.Properties.NewInviteIndicator, true)
    self.ScriptedEntityTweener:PlayC(self.Properties.Pane, 0.15, tweenerCommon.socialPaneShow)
    self.ScriptedEntityTweener:PlayC(self.Properties.NewInviteIndicator, 0.15, tweenerCommon.socialPaneShow)
    self.ScriptedEntityTweener:PlayC(self.Properties.ButtonContainer, 0.15, tweenerCommon.socialPaneShow)
    self.ScriptedEntityTweener:PlayC(self.Properties.GroupVoipParent, 0.15, tweenerCommon.socialPaneShow)
    self.ScriptedEntityTweener:PlayC(self.Properties.SpotlightContainer, 0.15, tweenerCommon.socialPaneShow)
    if self.groupId and self.groupId:IsValid() then
      self:ShowAllMemberHealthBars(false)
      if not VoiceChatControlBus.Broadcast.Are3dChannelsEnabled() then
        UiElementBus.Event.SetIsEnabled(self.Properties.ToggleGroupVoipButton, false)
      end
    end
    UiElementBus.Event.SetIsEnabled(self.Properties.GroupAlertMessage, false)
    self:UpdateArmyHintVisibility()
    self.ScriptedEntityTweener:Play(self.Properties.SocialAlarmIndicator, 0.15, {opacity = 0, ease = "QuadIn"})
  else
    if self.currentDrawOrder then
      UiCanvasBus.Event.SetDrawOrder(self.canvasId, self.currentDrawOrder)
    end
    self.ScriptedEntityTweener:Play(self.Properties.Pane, 0.15, {
      opacity = 0,
      x = -self.mainBgWidth,
      ease = "QuadIn",
      onComplete = function()
        UiElementBus.Event.SetIsEnabled(self.Properties.Pane, false)
        UiElementBus.Event.SetIsEnabled(self.Properties.NewInviteIndicator, false)
      end
    })
    self.ScriptedEntityTweener:Play(self.Properties.NewInviteIndicator, 0.15, {
      opacity = 0,
      x = -self.mainBgWidth,
      ease = "QuadIn"
    })
    self.ScriptedEntityTweener:Play(self.Properties.ButtonContainer, 0.15, {
      opacity = 0,
      x = -self.mainBgWidth,
      ease = "QuadIn"
    })
    self.ScriptedEntityTweener:Play(self.Properties.GroupVoipParent, 0, {
      opacity = 0,
      x = -self.mainBgWidth,
      ease = "QuadOut"
    })
    self.ScriptedEntityTweener:Play(self.Properties.SpotlightContainer, 0.15, {
      opacity = 0,
      x = -self.mainBgWidth,
      ease = "QuadIn"
    })
    if self.groupId and self.groupId:IsValid() then
      self:ShowAllMemberHealthBars(true)
    end
    self.SocialMenu:SetEnabled(false)
    self.SubArmyMenu:SetEnabled(false)
    LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Flyout.IsVisible", false)
    UiElementBus.Event.SetIsEnabled(self.Properties.GroupAlertMessage, true)
    self:UpdateArmyHintVisibility()
    self.ScriptedEntityTweener:Play(self.Properties.SocialAlarmIndicator, 0.15, {opacity = 1, ease = "QuadIn"})
    self.SocialMenu:UpdateInvitesListCount()
  end
end
function SocialPane:UpdateArmyHintVisibility()
  local isVisible = not self.isShowing and not self.isDead
  UiElementBus.Event.SetIsEnabled(self.Properties.ArmyHintVisibility, isVisible)
end
function SocialPane:DisableGroupMember(index)
  local memberData = self.groupMembers[index]
  if memberData then
    if self.localPlayerGroupEntity and memberData.entity.entityId == self.localPlayerGroupEntity.entityId then
      self.localPlayerGroupEntity = nil
    end
    DynamicBus.GroupDataNotification.Broadcast.OnMemberRemoved(index)
    memberData.playerName = nil
    memberData.characterId = nil
    memberData.entity.isLocalPlayer = false
    UiElementBus.Event.Reparent(memberData.entity.entityId, self.Properties.DisabledContainer, invalidEntityId)
    UiElementBus.Event.SetIsEnabled(memberData.entity.entityId, false)
    if self.currentFlyoutMenuType == EFlyoutMenuTypes.Group then
      LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Flyout.IsVisible", false)
    end
  end
end
function SocialPane:GroupIdChanged(groupId)
  if not groupId then
    return
  end
  if self.groupId and groupId == self.groupId then
    return
  end
  self.groupId = groupId
  if self.groupBusHandler then
    self:BusDisconnect(self.groupBusHandler)
    self.groupBusHandler = nil
  end
  self.memberCount = 0
  for i = 1, self.maxMemberCount do
    self:DisableGroupMember(i)
  end
  if self.groupId:IsValid() then
    self.groupBusHandler = self:BusConnect(GroupDataNotificationBus, self.groupId)
    GroupDataRequestBus.Event.NotifyConnected(self.groupId)
    if VoiceChatControlBus.Broadcast.IsIn2dChannel() then
      self:SetVoipState(EVoipState.GroupChannel)
    else
      self:SetVoipState(EVoipState.PendingJoinGroupChannel)
    end
  else
    LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Group.MemberCount", 0)
    DynamicBus.GroupDataNotification.Broadcast.OnGroupDisbanded()
    UiTextBus.Event.SetText(self.Properties.GroupAlertMessage, "")
  end
  UiElementBus.Event.SetIsEnabled(self.Properties.GroupVoip, self.groupId:IsValid())
  self:UpdateGroupButtons()
end
function SocialPane:OnMemberAdded(index, characterId, characterName, characterIcon, joinedNewGroup)
  local groupMemberData = self.groupMembers[index + 1]
  if groupMemberData and groupMemberData.characterId ~= characterId then
    UiElementBus.Event.SetIsEnabled(groupMemberData.entity.entityId, true)
    if groupMemberData.characterId == nil then
      self.memberCount = self.memberCount + 1
    end
    groupMemberData.characterId = characterId
    groupMemberData.characterName = characterName
    groupMemberData.playerIndex = index + 1
    groupMemberData.playerIcon = characterIcon
    groupMemberData.entity:UpdateData(groupMemberData)
    self.audioHelper:PlaySound(self.audioHelper.GroupOtherLeft)
    DynamicBus.GroupDataNotification.Broadcast.OnMemberAdded(index + 1, groupMemberData.entity.isLocalPlayer)
    LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Group.Members." .. tostring(index + 1) .. ".CharacterId", characterId)
    local insertBeforeEntityId = invalidEntityId
    local container = self.Properties.DisabledContainer
    if groupMemberData.entity.isLocalPlayer then
      self.localPlayerGroupEntity = groupMemberData.entity
      container = self.localPlayerGroupEntity.entityId
      LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Group.Members." .. tostring(index + 1) .. ".IsLocalPlayer", true)
      local firstEntityId = UiElementBus.Event.GetChild(self.Properties.GroupHealthContainer, 0)
      if firstEntityId then
        insertBeforeEntityId = firstEntityId
      end
    else
      if not joinedNewGroup then
        self:EnqueueMinorGroupMemberNotification("@ui_groupmemberjoinedmessage", characterName)
      end
      LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Group.Members." .. tostring(index + 1) .. ".IsLocalPlayer", false)
      for i = groupMemberData.playerIndex + 1, #self.groupMembers do
        local nextPlayerData = self.groupMembers[i]
        if nextPlayerData and nextPlayerData.characterId and not nextPlayerData.entity.isLocalPlayer then
          insertBeforeEntityId = nextPlayerData.entity.entityId
          break
        end
      end
    end
    UiElementBus.Event.Reparent(groupMemberData.entity.entityId, self.Properties.GroupHealthContainer, insertBeforeEntityId)
    groupMemberData.entity:ShowHealthBar(not self.isShowing)
    if self.isShowing == false then
      UiElementBus.Event.SetIsEnabled(self.Properties.NewInviteIndicator, false)
    end
    LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Group.MemberCount", self.memberCount)
  end
  self:UpdateGroupButtons()
end
function SocialPane:OnMemberRemoved(index, characterId)
  local groupMemberData = self.groupMembers[index + 1]
  if groupMemberData.characterId == characterId then
    if not groupMemberData.entity.isLocalPlayer then
      self:EnqueueMinorGroupMemberNotification("@ui_groupmemberleftmessage", groupMemberData.characterName)
    end
    self.memberCount = self.memberCount - 1
    LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Group.MemberCount", self.memberCount)
    self:DisableGroupMember(index + 1)
    self:UpdateGroupButtons()
  end
end
function SocialPane:CheckArmyHintVisibility()
  local isVisible = self.isInRaid and self.gameModeId == nil
  UiElementBus.Event.SetIsEnabled(self.Properties.ArmyHintContainer, isVisible)
end
function SocialPane:OnEnteredGameMode(gameModeEntityId, gameModeId)
  self.gameModeId = gameModeId
  self:CheckArmyHintVisibility()
  self:UpdateGroupButtons()
end
function SocialPane:OnExitedGameMode(gameModeEntityId)
  self.gameModeId = nil
  self:CheckArmyHintVisibility()
  self:UpdateGroupButtons()
end
function SocialPane:EnqueueMinorGroupMemberNotification(locTag, memberCharacterName)
  local notificationData = NotificationData()
  notificationData.type = "Minor"
  notificationData.text = LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement(locTag, memberCharacterName)
  UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
end
function SocialPane:IsGroupMemberAdded(index)
  if self.groupMembers then
    local groupMemberData = self.groupMembers[index]
    return groupMemberData and groupMemberData.characterId and groupMemberData.characterId ~= ""
  else
    return false
  end
end
function SocialPane:OnMemberNameChanged(index, newName)
  if self.groupMembers[index + 1].characterId ~= nil then
    self.groupMembers[index + 1].entity:UpdateName(newName)
    LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Group.Members." .. tostring(index + 1) .. ".CharacterName", newName)
  end
end
function SocialPane:OnMemberIconChanged(index, newIcon)
  if self.groupMembers[index + 1].characterId ~= nil then
    self.groupMembers[index + 1].entity:UpdatePlayerIcon(newIcon)
  end
end
function SocialPane:OnMemberFactionChanged(index, newFaction)
  if newFaction ~= 0 and self.groupMembers[index + 1].characterId ~= nil then
    self.groupMembers[index + 1].entity:UpdateFaction(newFaction)
    LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Group.Members." .. tostring(index + 1) .. ".Faction", newFaction)
  end
end
function SocialPane:OnMemberLevelChanged(index, newLevel)
  if newLevel ~= 0 and self.groupMembers[index + 1].characterId ~= nil then
    self.groupMembers[index + 1].entity:UpdateLevel(newLevel)
    LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Group.Members." .. tostring(index + 1) .. ".Level", newLevel)
  end
end
function SocialPane:OnMemberHealthChanged(index, newHealth)
  if self.groupMembers[index + 1].characterId ~= nil then
    self.groupMembers[index + 1].entity:UpdateHealth(newHealth)
    LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Group.Members." .. tostring(index + 1) .. ".HealthPct", newHealth)
  end
end
function SocialPane:OnMemberManaChanged(index, newMana)
  if self.groupMembers[index + 1].characterId ~= nil then
    self.groupMembers[index + 1].entity:UpdateMana(newMana)
  end
end
function SocialPane:OnMemberLeaderStatusChanged(index, isLeader)
  local groupMemberData = self.groupMembers[index + 1]
  if groupMemberData.entity.isLocalPlayer then
    LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Group.IsGroupLeader", isLeader)
  end
end
function SocialPane:OnMemberDeathsDoorStatusChanged(index, isDeathsDoor)
  if self.groupMembers[index + 1].characterId ~= nil then
    self.groupMembers[index + 1].entity:UpdateDeathsDoor(isDeathsDoor)
    LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Group.Members." .. tostring(index + 1) .. ".IsDeathsDoor", isDeathsDoor)
  end
end
function SocialPane:OnMemberOnlineStatusChanged(index, isOnline)
  if self.groupMembers[index + 1].characterId ~= nil then
    self.groupMembers[index + 1].entity:UpdateOnlineStatus(isOnline)
  end
end
function SocialPane:OnMemberPositionChanged(index, newWorldPos)
  if self.groupMembers[index + 1].characterId ~= nil then
    LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Group.Members." .. tostring(index + 1) .. ".WorldPosition", newWorldPos)
  end
end
function SocialPane:OnMemberWaypointChanged(index, newWaypointPos)
  if self.groupMembers[index + 1].characterId ~= nil then
    LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Group.Members." .. tostring(index + 1) .. ".Waypoint", newWaypointPos)
  end
end
function SocialPane:OnMemberGameModeIndexChanged(index, newGameModeIndex)
  if self.groupMembers[index + 1].characterId ~= nil then
    LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Group.Members." .. tostring(index + 1) .. ".GameModeIndex", newGameModeIndex)
  end
end
function SocialPane:IsInGroupVoip()
  return self.currentVoipState == EVoipState.GroupChannel
end
function SocialPane:OnVoiceChatChannelJoinedUi()
  if self.currentVoipState then
    if self.currentVoipState == EVoipState.PendingJoinGroupChannel then
      self:SetVoipState(EVoipState.GroupChannel)
    elseif self.currentVoipState == EVoipState.PendingJoinWorldChannel then
      self:SetVoipState(EVoipState.WorldChannel)
    end
  end
end
function SocialPane:OnChannelJoinFailedUi()
  self:RevertVoipState()
end
function SocialPane:OnVoiceChatDisabledUi()
  self:SetVoipState(EVoipState.WorldChannel)
end
function SocialPane:SetVoipState(newVoipState)
  if newVoipState == EVoipState.WorldChannel then
    UiCheckboxBus.Event.SetState(self.Properties.ToggleGroupVoipButton, false)
    self.ScriptedEntityTweener:Play(self.Properties.ToggleGroupVoipPip, 0.085, {x = -3, ease = "QuadOut"})
    self.ScriptedEntityTweener:Play(self.Properties.ToggleGroupVoipBg, 0.085, {
      imgColor = self.UIStyle.COLOR_TOGGLEOFF,
      ease = "QuadOut"
    })
    UiElementBus.Event.SetIsEnabled(self.Properties.ToggleTextOn, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.ToggleTextOff, true)
    self:StopVoipJoiningTextAnim()
  elseif newVoipState == EVoipState.GroupChannel then
    UiCheckboxBus.Event.SetState(self.Properties.ToggleGroupVoipButton, true)
    self.ScriptedEntityTweener:Play(self.Properties.ToggleGroupVoipPip, 0.085, {x = 26, ease = "QuadOut"})
    self.ScriptedEntityTweener:Play(self.Properties.ToggleGroupVoipBg, 0.085, {
      imgColor = self.UIStyle.COLOR_TOGGLEON,
      ease = "QuadOut"
    })
    UiElementBus.Event.SetIsEnabled(self.Properties.ToggleTextOn, true)
    UiElementBus.Event.SetIsEnabled(self.Properties.ToggleTextOff, false)
    self:StopVoipJoiningTextAnim()
  elseif newVoipState == EVoipState.PendingJoinWorldChannel or newVoipState == EVoipState.PendingJoinGroupChannel then
    self.voipTimer = 0
    self:StartVoipJoiningTextAnim()
  elseif newVoipState == EVoipState.Disabled then
    self:StopVoipJoiningTextAnim()
  end
  self.currentVoipState = newVoipState
end
function SocialPane:StartVoipJoiningTextAnim()
  UiTextBus.Event.SetText(self.Properties.ToggleTextLabel, self.voipLabelJoiningText)
  self.voipAnimIndex = 0
  self.voipAnimTimer = 0
  self.voipLoadingDots = ""
end
function SocialPane:StopVoipJoiningTextAnim()
  UiTextBus.Event.SetText(self.Properties.ToggleTextLabel, self.voipLabelDefaultText)
end
function SocialPane:RevertVoipState()
  if not VoiceChatControlBus.Broadcast.IsVoiceChatServiceActivated() then
    self:SetVoipState(EVoipState.WorldChannel)
  elseif VoiceChatControlBus.Broadcast.IsIn2dChannel() then
    self:SetVoipState(EVoipState.GroupChannel)
  elseif VoiceChatControlBus.Broadcast.IsIn3dChannel() then
    self:SetVoipState(EVoipState.WorldChannel)
  else
    self:SetVoipState(EVoipState.WorldChannel)
  end
end
function SocialPane:OnToggleVoip()
  if self.currentVoipState == EVoipState.GroupChannel then
    VoiceChatClientBus.Broadcast.RequestToggleGroupChannelPresence(false)
    self:SetVoipState(EVoipState.PendingJoinWorldChannel)
  elseif self.currentVoipState == EVoipState.WorldChannel then
    VoiceChatClientBus.Broadcast.RequestToggleGroupChannelPresence(true)
    self:SetVoipState(EVoipState.PendingJoinGroupChannel)
  end
end
function SocialPane:TickVoipJoin(deltaTime, timePoint)
  if self.currentVoipState ~= EVoipState.PendingJoinWorldChannel and self.currentVoipState ~= EVoipState.PendingJoinGroupChannel then
    return
  end
  self.voipTimer = self.voipTimer + deltaTime
  self.voipAnimTimer = self.voipAnimTimer + deltaTime
  if self.voipAnimTimer >= 0.5 then
    if self.voipAnimIndex < 3 then
      self.voipLoadingDots = self.voipLoadingDots .. "."
      self.voipAnimIndex = self.voipAnimIndex + 1
    else
      self.voipLoadingDots = ""
      self.voipAnimIndex = 0
    end
    UiTextBus.Event.SetText(self.Properties.ToggleTextLabel, self.voipLabelJoiningText .. self.voipLoadingDots)
    self.voipAnimTimer = 0
  end
  if self.voipTimer < self.voipTimeout then
    return
  end
  self:RevertVoipState()
end
function SocialPane:OnGroupInviteSent(characterIdString)
  self.socialDataHandler:GetPlayerIdentification_ServerCall(self, function(self, result)
    local playerId
    if 0 < #result then
      playerId = result[1].playerId
    else
      Log("ERR - SocialPane:OnGroupInviteSent: Player not found.")
      return
    end
    local notificationData = NotificationData()
    notificationData.type = "Minor"
    notificationData.text = GetLocalizedReplacementText("@ui_groupinvitesentmessage", {
      playerName = playerId.playerName
    })
    UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
  end, function(self, reason)
    if reason == eSocialRequestFailureReasonThrottled then
      Log("ERR - SocialPane:OnGroupInviteSent: Throttled.")
    elseif reason == eSocialRequestFailureReasonTimeout then
      Log("ERR - SocialPane:OnGroupInviteSent: Timed Out.")
    end
  end, characterIdString)
end
function SocialPane:OnGroupInviteRemoved(inviteId, reason, isSender, characterIdString)
  if not isSender then
    local isBlocked = JavSocialComponentBus.Broadcast.IsPlayerBlocked(characterIdString)
    if isBlocked then
      return
    end
  end
  self.inviteRemovedReason = reason
  self.inviteRemovedIsSender = isSender
  self.isRaidInvite = false
  if characterIdString ~= "" then
    self.socialDataHandler:GetPlayerIdentification_ServerCall(self, self.OnGroupInviteRemoved_OnPlayerIdReady, self.OnGroupInviteRemoved_OnPlayerIdFailed, characterIdString)
  else
    self.isRaidInvite = true
    local data = {
      {
        playerId = {
          playerName = "@ui_war_invite_name"
        }
      }
    }
    self:OnGroupInviteRemoved_OnPlayerIdReady(data)
  end
  for notificationId, notificationData in pairs(self.inviteNotifications) do
    if notificationData.id == inviteId then
      UiNotificationsBus.Broadcast.RescindNotification(notificationData.notificationId, true, true)
      self.inviteNotifications[notificationId] = nil
      break
    end
  end
end
function SocialPane:OnGroupInviteRemoved_OnPlayerIdReady(result)
  local playerId
  if 0 < #result then
    playerId = result[1].playerId
  else
    Log("ERR - SocialPane:OnGroupInviteRemoved_OnPlayerIdReady: Player not found.")
    return
  end
  local isStreamerModeUIHideEnabled = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Options.Social.StreamerModeUI")
  if isStreamerModeUIHideEnabled and not self.inviteRemovedIsSender then
    return
  end
  local notificationData = NotificationData()
  notificationData.type = "Minor"
  local locTag
  if self.inviteRemovedReason == eGroupsInviteRemovedReason_Accepted then
    if self.isRaidInvite then
      locTag = "@ui_groupinviteacceptraid"
    else
      locTag = "@ui_groupinviteacceptsentmessage"
    end
  elseif self.inviteRemovedReason == eGroupsInviteRemovedReason_Rejected then
    if self.isRaidInvite then
      locTag = "@ui_groupinvitedeclineraid"
    else
      locTag = "@ui_groupinvitedeclinesentmessage"
    end
  elseif self.inviteRemovedReason == eGroupsInviteRemovedReason_Withdrawn then
    if self.isRaidInvite then
      locTag = "@ui_groupinvitewithdrawnraid"
    elseif self.inviteRemovedIsSender then
      locTag = "@ui_groupinvitewithdrawnsendermessage"
    else
      locTag = "@ui_groupinvitewithdrawnreceivermessage"
    end
  elseif self.inviteRemovedReason == eGroupsInviteRemovedReason_JoinedOtherGroup then
    if self.inviteRemovedIsSender then
      locTag = "@ui_fromplayerjoinedgrouperrormessage"
    else
      locTag = "@ui_toplayerjoinedgrouperrormessage"
    end
  elseif self.inviteRemovedReason == eGroupsInviteRemovedReason_TimedOut then
    if self.isRaidInvite then
      locTag = "@ui_groupinvitetimedoutraid"
    else
      locTag = "@ui_groupinvitetimedouterrormessage"
    end
  elseif self.inviteRemovedReason == eGroupsInviteRemovedReason_PlayerDisconnected then
    if self.inviteRemovedIsSender then
      locTag = "@ui_groupfromplayerofflineerrormessage"
    else
      locTag = "@ui_groupinvitetoplayerofflineerrormessage"
    end
  elseif self.inviteRemovedReason == eGroupsInviteRemovedReason_GroupFull then
    locTag = "@ui_groupinvitefailedgroupfullmessage"
  elseif self.inviteRemovedReason == eGroupsInviteRemovedReason_Failed then
    if self.isRaidInvite then
      locTag = "@ui_groupinvitefailedraid"
    else
      locTag = "@ui_groupinvitefailederrormessage"
    end
  elseif self.inviteRemovedReason == eGroupsInviteRemovedReason_InvalidFaction then
    if self.inviteRemovedIsSender then
      locTag = "@ui_cannotinvitein_pvp_wrong_faction"
    else
      return
    end
  elseif self.inviteRemovedReason == eGroupsInviteRemovedReason_UnavailableFTUE then
    if self.inviteRemovedIsSender then
      locTag = "@ui_grouptoplayerisinftueerrormessage"
    else
      return
    end
  else
    Log("ERR - Unexpected removed reason " .. tostring(self.inviteRemovedReason))
    return
  end
  notificationData.text = LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement(locTag, playerId.playerName)
  UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
end
function SocialPane:OnGroupInviteRemoved_OnPlayerIdFailed(reason)
  if reason == eSocialRequestFailureReasonThrottled then
    Log("ERR - SocialPane:OnGroupInviteRemoved_OnPlayerIdFailed: Throttled.")
  elseif reason == eSocialRequestFailureReasonTimeout then
    Log("ERR - SocialPane:OnGroupInviteRemoved_OnPlayerIdFailed: Timed Out.")
  end
end
function SocialPane:OnGroupInviteReply(accepted, characterIdString)
  self.inviteReplyAccepted = accepted
  self.socialDataHandler:GetPlayerIdentification_ServerCall(self, self.OnGroupInviteReply_OnPlayerIdReady, self.OnGroupInviteReply_OnPlayerIdFailed, characterIdString)
end
function SocialPane:OnGroupInviteReply_OnPlayerIdReady(result)
  local playerId
  if 0 < #result then
    playerId = result[1].playerId
  else
    Log("ERR - SocialPane:OnGroupInviteReply_OnPlayerIdReady: Player not found.")
    return
  end
  local notificationData = NotificationData()
  notificationData.type = "Minor"
  local locTag
  if self.inviteReplyAccepted then
    locTag = "@ui_groupinviteacceptreceivedmessage"
  else
    locTag = "@ui_groupinvitedeclinereceivedmessage"
  end
  notificationData.text = LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement(locTag, playerId.playerName)
  UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
end
function SocialPane:OnGroupInviteReply_OnPlayerIdFailed(reason)
  if reason == eSocialRequestFailureReasonThrottled then
    Log("ERR - SocialPane:OnGroupInviteReply_OnPlayerIdFailed: Throttled.")
  elseif reason == eSocialRequestFailureReasonTimeout then
    Log("ERR - SocialPane:OnGroupInviteReply_OnPlayerIdFailed: Timed Out.")
  end
end
function SocialPane:OnGroupError(errorType, characterIdString)
  self.groupErrorType = errorType
  self.socialDataHandler:GetPlayerIdentification_ServerCall(self, self.OnGroupError_OnPlayerIdReady, self.OnGroupError_OnPlayerIdFailed, characterIdString)
end
function SocialPane:OnGroupError_OnPlayerIdReady(result)
  local playerId
  if 0 < #result then
    playerId = result[1].playerId
  else
    Log("ERR - SocialPane:OnGroupError_OnPlayerIdReady: Player not found.")
    return
  end
  local alreadyInvited = self.groupErrorType == eGroupsRequestErrors_AlreadyInvited
  local notificationData = NotificationData()
  notificationData.type = "Groups"
  notificationData.title = alreadyInvited and "@ui_groupalreadyinvitederrortitle" or "@ui_grouperrortitle"
  notificationData.allowDuplicates = false
  local locTag
  if self.groupErrorType == eGroupsRequestErrors_UnknownError then
    locTag = "@ui_groupunknownerror"
  elseif self.groupErrorType == eGroupsRequestErrors_MaxInvitesSent then
    locTag = "@ui_groupmaxinviteserrormessage"
  elseif alreadyInvited then
    locTag = "@ui_groupalreadyinvitederrormessage"
  elseif self.groupErrorType == eGroupsRequestErrors_InvalidInvite then
    locTag = ""
  elseif self.groupErrorType == eGroupsRequestErrors_ReceiverOffline then
    locTag = "@ui_grouptoplayerofflineerrormessage"
  elseif self.groupErrorType == eGroupsRequestErrors_SenderOffline then
    locTag = "@ui_groupfromplayerofflineerrormessage"
  elseif self.groupErrorType == eGroupsRequestErrors_GroupNotAvailable then
    locTag = "@ui_groupnotavailableerrormessage"
  elseif self.groupErrorType == eGroupsRequestErrors_AlreadyGrouped then
    locTag = "@ui_groupedalreadyerrormessage"
  elseif self.groupErrorType == eGroupsRequestErrors_InSameGroup then
    locTag = "@ui_insamegrouperrormessage"
  elseif self.groupErrorType == eGroupsRequestErrors_MaxGroupSize then
    locTag = "@ui_groupmaxsizeerrormessage"
  elseif self.groupErrorType == eGroupsRequestErrors_GroupFull then
    locTag = "@ui_groupfullerrormessage"
  else
    Log("ERR - Unexpected error type " .. tostring(self.groupErrorType))
  end
  notificationData.text = LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement(locTag, playerId.playerName)
  UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
end
function SocialPane:OnGroupError_OnPlayerIdFailed(reason)
  if reason == eSocialRequestFailureReasonThrottled then
    Log("ERR - SocialPane:OnGroupError_OnPlayerIdFailed: Throttled.")
  elseif reason == eSocialRequestFailureReasonTimeout then
    Log("ERR - SocialPane:OnGroupError_OnPlayerIdFailed: Timed Out.")
  end
end
function SocialPane:OnKickVoteInitiated(fromCharacterId, targetCharacterId, expiry)
  self.isKickVoteActive = true
  self.groupKickTargetPlayerName = nil
  local fromPlayerName
  for _, memberData in ipairs(self.groupMembers) do
    if memberData.characterId == fromCharacterId then
      fromPlayerName = memberData.characterName
    end
    if memberData.characterId == targetCharacterId then
      self.groupKickTargetPlayerName = memberData.characterName
    end
  end
  if not self.groupKickTargetPlayerName then
    return
  end
  local localPlayerCharacterId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.CharacterId")
  if localPlayerCharacterId == fromCharacterId then
    self:SendGroupKickMinorNotification("@ui_group_kick_started_vote")
    return
  end
  if not fromPlayerName then
    return
  end
  local now = TimePoint:Now()
  local duration = expiry:Subtract(now):ToSecondsUnrounded()
  local title = GetLocalizedReplacementText("@ui_group_kick_choice_title", {
    color = ColorRgbaToHexString(self.UIStyle.COLOR_YELLOW_GOLD),
    playerName = self.groupKickTargetPlayerName
  })
  local text = GetLocalizedReplacementText("@ui_group_kick_choice_text", {
    color = ColorRgbaToHexString(self.UIStyle.COLOR_YELLOW_GOLD),
    fromPlayerName = fromPlayerName,
    targetPlayerName = self.groupKickTargetPlayerName
  })
  local notificationData = NotificationData()
  notificationData.type = "GroupKick"
  notificationData.title = title
  notificationData.text = text
  notificationData.hasChoice = true
  notificationData.maximumDuration = duration
  notificationData.showProgress = true
  notificationData.acceptTextOverride = "@ui_group_kick_choice_accept"
  notificationData.declineTextOverride = "@ui_group_kick_choice_decline"
  notificationData.contextId = self.entityId
  notificationData.callbackName = "OnGroupKickChoice"
  self.groupKickNotificationId = UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
end
function SocialPane:OnGroupKickChoice(notificationId, isAccepted)
  GroupsRequestBus.Broadcast.RequestKickVotePlayer(isAccepted)
end
function SocialPane:OnInitiateKickVoteFailed(error)
  if error == eGroupVoteKickError_InProgress then
    self:SendGroupKickMinorNotification("@ui_group_kick_error_in_progress")
  elseif error == eGroupVoteKickError_InvalidTarget then
    self:SendGroupKickMinorNotification("@ui_group_kick_error_invalid_target")
  elseif error == eGroupVoteKickError_TooFrequent then
    self:SendGroupKickMinorNotification("@ui_group_kick_error_too_frequent")
  end
end
function SocialPane:OnSubmitKickVoteFailed(error)
  if error == eGroupVoteKickError_NotInProgress then
    self:SendGroupKickMinorNotification("@ui_group_kick_error_not_in_progress")
  elseif error == eGroupVoteKickError_AlreadyVoted then
    self:SendGroupKickMinorNotification("@ui_group_kick_error_already_voted")
  end
end
function SocialPane:OnKickVoteEnded(error)
  self.isKickVoteActive = false
  if self.groupKickNotificationId then
    UiNotificationsBus.Broadcast.RescindNotification(self.groupKickNotificationId, true, true)
    self.groupKickNotificationId = nil
  end
  if not self.groupKickTargetPlayerName then
    return
  end
  if error == eGroupVoteKickError_NotKicked then
    self:SendGroupKickMinorNotification("@ui_group_kick_ended_not_kicked")
  elseif error == eGroupVoteKickError_TimedOut then
    self:SendGroupKickMinorNotification("@ui_group_kick_ended_timed_out")
  end
  self.groupKickTargetPlayerName = nil
end
function SocialPane:SendGroupKickMinorNotification(locTag)
  local text = GetLocalizedReplacementText(locTag, {
    color = ColorRgbaToHexString(self.UIStyle.COLOR_YELLOW_GOLD),
    playerName = self.groupKickTargetPlayerName
  })
  local notificationData = NotificationData()
  notificationData.type = "Minor"
  notificationData.text = text
  UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
end
function SocialPane:IsKickVoteActive()
  return self.isKickVoteActive
end
function SocialPane:OnToggleHoverStart(entityId, actionName)
  if self.toggleButtonTimeline == nil then
    self.toggleButtonTimeline = self.ScriptedEntityTweener:TimelineCreate()
    self.toggleButtonTimeline:Add(self.ToggleHoverGlow, self.UIStyle.DURATION_TIMELINE_FADE_OUT, {opacity = 0.5})
    self.toggleButtonTimeline:Add(self.ToggleHoverGlow, self.UIStyle.DURATION_TIMELINE_FADE_IN, {opacity = 1})
    self.toggleButtonTimeline:Add(self.ToggleHoverGlow, self.UIStyle.DURATION_TIMELINE_HOLD, {
      opacity = 1,
      onComplete = function()
        self.toggleButtonTimeline:Play()
      end
    })
  end
  self.ScriptedEntityTweener:Play(self.Properties.ToggleHoverGlow, self.UIStyle.DURATION_BUTTON_FADE_IN, {opacity = 1, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.Properties.ToggleHoverGlow, self.UIStyle.DURATION_BUTTON_FADE_IN_HOLD, {
    opacity = 1,
    delay = self.UIStyle.DURATION_BUTTON_FADE_IN,
    onComplete = function()
      self.toggleButtonTimeline:Play()
    end
  })
  if self:IsInGroupVoip() then
    self:SetToolTipSizeAndPosition("@ui_leavegroupvoip", self.GroupVoip, -20)
  else
    self:SetToolTipSizeAndPosition("@ui_joingroupvoip", self.GroupVoip, -20)
  end
  self:ToggleToolTip(true)
  self.audioHelper:PlaySound(self.audioHelper.GroupOnIconHover)
end
function SocialPane:OnToggleHoverEnd(entityId, actionName)
  self.ScriptedEntityTweener:Play(self.Properties.ToggleHoverGlow, 0.15, {opacity = 0, ease = "QuadOut"})
  self:ToggleToolTip(false)
end
function SocialPane:OnNewGroupInvite(inviteIndex)
  local invitesNode = self.dataLayer:GetDataNode("Hud.LocalPlayer.Group.Invites")
  local inviteData = invitesNode[tostring(inviteIndex)]:GetData()
  local warDetails = WarDataClientRequestBus.Broadcast.GetWarDetails(inviteData.warId)
  if inviteData.senderCharacterIdString == "" and (warDetails:IsValid() or inviteData.gameModeId ~= 0) then
    self:ShowGroupInviteNotification(inviteData, nil, warDetails)
  elseif not PlayerArenaRequestBus.Event.IsInArena(self.playerRootEntityId) then
    self.pendingInviteData = inviteData
    self.socialDataHandler:GetPlayerIdentification_ServerCall(self, self.OnNewGroupInvite_OnPlayerIdReady, self.OnNewGroupInvite_OnPlayerIdFailed, inviteData.senderCharacterIdString)
  end
end
function SocialPane:OnNewGroupInvite_OnPlayerIdReady(result)
  local playerId
  if 0 < #result then
    playerId = result[1].playerId
  else
    Log("ERR - SocialPane:OnNewGroupInvite_OnPlayerIdReady: Player not found.")
    return
  end
  self:ShowGroupInviteNotification(self.pendingInviteData, playerId.playerName)
end
function SocialPane:ShowGroupInviteNotification(inviteData, playerName, warDetails)
  local isWarInvite = warDetails ~= nil
  local isGameModeInvite = inviteData.gameModeId ~= 0
  local isPvPGroup = false
  local isFtue = FtueSystemRequestBus.Broadcast.IsFtue()
  local isStreamerModeUIHideEnabled = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Options.Social.StreamerModeUI")
  if isFtue or isStreamerModeUIHideEnabled and not isWarInvite and not isGameModeInvite then
    return
  end
  local notificationData = NotificationData()
  if isGameModeInvite then
    notificationData.type = "GameModeInvite"
    if inviteData.gameModeId == 2444859928 then
      notificationData.title = "@ui_outpost_rush_invite_notification_title"
      notificationData.text = "@ui_outpost_rush_invite_notification_text"
      notificationData.icon = "LyShineUI/Images/Icons/OutpostRush/icon_outpostRush.dds"
    else
      notificationData.title = "<UNSUPPORTED GAME MODE ID>"
      notificationData.text = "<UNSUPPORTED GAME MODE ID>"
    end
    notificationData.priority = eNotificationPriority_VeryHigh
  elseif isWarInvite then
    local siegeStartTime = warDetails:GetConquestStartTime():Subtract(WallClockTimePoint()):ToSecondsRoundedUp()
    local inviteText = GetLocalizedReplacementText(warDetails:IsInvasion() and "@ui_receivedinvasiongroupinvitemessage" or "@ui_receivedwargroupinvitemessage", {
      territoryName = TerritoryDataHandler:GetTerritoryNameFromTerritoryId(warDetails:GetTerritoryId()),
      startTime = timeHelpers:GetLocalizedServerTime(siegeStartTime),
      endTime = timeHelpers:GetLocalizedServerTime(siegeStartTime + dominionCommon:GetSiegeDuration())
    })
    notificationData.type = "WarInvite"
    notificationData.title = warDetails:IsInvasion() and "@ui_receivedinvasiongroupinvitetitle" or "@ui_receivedwargroupinvitetitle"
    notificationData.text = inviteText
    notificationData.priority = eNotificationPriority_VeryHigh
  else
    isPvPGroup = inviteData:IsPvPGroup()
    local canAccept = isPvPGroup == self.isPvpFlaggedOrPending
    local title = isPvPGroup and "@ui_receivedgroupinvitetitle_pvp" or "@ui_receivedgroupinvitetitle_pve"
    local text = self:GetGroupInviteMessageText(isPvPGroup, playerName, canAccept)
    if not canAccept then
      notificationData.declineTextOverride = "@ui_receivedgroupinvite_hide"
    end
    notificationData.canAccept = canAccept
    notificationData.type = isPvPGroup and "PvPGroupInvite" or "PvEGroupInvite"
    notificationData.title = title
    notificationData.text = text
    notificationData.priority = eNotificationPriority_High
  end
  notificationData.hasChoice = true
  notificationData.contextId = self.entityId
  notificationData.callbackName = "OnGroupInviteNotificationChoice"
  local notificationId = UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
  self.inviteNotifications[tostring(notificationId)] = {
    id = inviteData.inviteId,
    notificationId = notificationId,
    isWarInvite = isWarInvite,
    isPvPGroup = isPvPGroup,
    playerName = playerName
  }
  self.audioHelper:PlaySound(self.audioHelper.OnInvitedToGuild)
end
function SocialPane:UpdateGroupNotifications()
  for notificationId, notificationData in pairs(self.inviteNotifications) do
    if not notificationData.isWarInvite then
      local canAccept = notificationData.isPvPGroup == self.isPvpFlaggedOrPending
      local text = self:GetGroupInviteMessageText(notificationData.isPvPGroup, notificationData.playerName, canAccept)
      local declineTextOverride = canAccept and "@ui_receivedgroupinvite_decline" or "@ui_receivedgroupinvite_hide"
      local newNotificationData = {
        text = text,
        declineTextOverride = declineTextOverride,
        canAccept = canAccept
      }
      DynamicBus.NotificationsRequestBus.Broadcast.UpdateNotification(notificationId, newNotificationData)
    end
  end
end
function SocialPane:GetGroupInviteMessageText(isPvPGroup, playerName, canAccept)
  local locTag
  if canAccept then
    locTag = isPvPGroup and "@ui_receivedgroupinvitemessage_pvp" or "@ui_receivedgroupinvitemessage_pve"
  else
    locTag = isPvPGroup and "@ui_receivedgroupinvitemessage_pvp_wrong_flag" or "@ui_receivedgroupinvitemessage_pve_wrong_flag"
  end
  return GetLocalizedReplacementText(locTag, {playerName = playerName})
end
function SocialPane:OnNewGroupInvite_OnPlayerIdFailed(reason)
  if reason == eSocialRequestFailureReasonThrottled then
    Log("ERR - SocialPane:OnNewGroupInvite_OnPlayerIdFailed: Throttled.")
  elseif reason == eSocialRequestFailureReasonTimeout then
    Log("ERR - SocialPane:OnNewGroupInvite_OnPlayerIdFailed: Timed Out.")
  end
end
function SocialPane:OnGroupInviteNotificationChoice(notificationId, isAccepted)
  local notificationData = self.inviteNotifications[tostring(notificationId)]
  self.inviteNotifications[tostring(notificationId)] = nil
  if isAccepted then
    local canAccept = notificationData.isWarInvite or notificationData.isPvPGroup == self.isPvpFlaggedOrPending
    if canAccept then
      local myRaidId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Raid.Id")
      local isInOutpostRushQueue = GameModeParticipantComponentRequestBus.Event.IsInQueueForGameMode(self.playerRootEntityId, GameModeCommon.GAMEMODE_OUTPOST_RUSH)
      if myRaidId and myRaidId:IsValid() then
        self.pendingNotificationId = notificationData.id
        local isInOutpostRush = GameModeParticipantComponentRequestBus.Event.IsInGameMode(self.playerRootEntityId, GameModeCommon.GAMEMODE_OUTPOST_RUSH)
        if isInOutpostRush then
          local modeEntityId = GameModeParticipantComponentRequestBus.Event.GetGameModeEntityId(self.playerRootEntityId, GameModeCommon.GAMEMODE_OUTPOST_RUSH)
          local penaltyInSeconds = GameModeComponentRequestBus.Event.GetGameModeRejoinPenaltyTimeSec(modeEntityId)
          local message = "@ui_outpost_rush_leave_desc"
          if 0 < penaltyInSeconds then
            local timeRemainingString = timeHelpers:ConvertToTwoLargestTimeEstimate(penaltyInSeconds, false)
            message = GetLocalizedReplacementText("@ui_outpost_rush_leave_group_desc_time", {time = timeRemainingString})
          end
          PopupWrapper:RequestPopup(ePopupButtons_YesNo, "@ui_outpost_rush_leave_title", message, self.onAcceptPopupEventId, self, self.OnPopupResult)
        else
          PopupWrapper:RequestPopup(ePopupButtons_YesNo, "@ui_siege_abandon_and_accept_group_title", "@ui_siege_abandon_and_accept_group_message", self.onAcceptPopupEventId, self, self.OnPopupResult)
        end
      elseif isInOutpostRushQueue then
        self.pendingNotificationId = notificationData.id
        PopupWrapper:RequestPopup(ePopupButtons_YesNo, "@ui_acceptinvitepopuptitle", "@ui_queuewarning_accept", self.onAcceptPopupEventId, self, self.OnPopupResult)
      else
        GroupsRequestBus.Broadcast.RequestReplyToGroupInvite(notificationData.id, true)
        self.audioHelper:PlaySound(self.audioHelper.OnGuildNotificationAccept)
      end
    end
  else
    GroupsRequestBus.Broadcast.RequestReplyToGroupInvite(notificationData.id, false)
    self.audioHelper:PlaySound(self.audioHelper.OnGuildNotificationDecline)
  end
end
function SocialPane:LeaveGroup()
  local title = "@ui_leavegrouppopuptitle"
  local message = "@ui_leavegrouppopupmessage"
  local myRaidId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Raid.Id")
  local isInOutpostRushQueue = GameModeParticipantComponentRequestBus.Event.IsInQueueForGameMode(self.playerRootEntityId, GameModeCommon.GAMEMODE_OUTPOST_RUSH)
  if self.gameModeId == GameModeCommon.GAMEMODE_OUTPOST_RUSH then
    local modeEntityId = GameModeParticipantComponentRequestBus.Event.GetGameModeEntityId(self.playerRootEntityId, GameModeCommon.GAMEMODE_OUTPOST_RUSH)
    local penaltyInSeconds = GameModeComponentRequestBus.Event.GetGameModeRejoinPenaltyTimeSec(modeEntityId)
    message = "@ui_outpost_rush_leave_desc"
    if 0 < penaltyInSeconds then
      local timeRemainingString = timeHelpers:ConvertToTwoLargestTimeEstimate(penaltyInSeconds, false)
      message = GetLocalizedReplacementText("@ui_outpost_rush_leave_desc_time", {time = timeRemainingString})
    end
  elseif myRaidId and myRaidId:IsValid() then
    title = "@ui_siege_abandon_title"
    message = "@ui_siege_abandon_message"
  elseif isInOutpostRushQueue then
    message = "@ui_queuewarning_leave"
  else
    local groupDungeonInstanceState = GroupDataRequestBus.Event.GetGroupDungeonInstanceState(self.groupId)
    if groupDungeonInstanceState == DungeonInstanceState_Queued then
      local gameModeId = GroupDataRequestBus.Event.GetDungeonGameModeId(self.groupId)
      local gameModeData = GameModeParticipantComponentRequestBus.Event.GetGameModeStaticData(self.playerRootEntityId, gameModeId)
      message = GetLocalizedReplacementText("@ui_queue_leave_group_confirm_message", {
        minGroupSize = gameModeData.minGroupSize
      })
    end
  end
  PopupWrapper:RequestPopup(ePopupButtons_YesNo, title, message, self.onLeavePopupEventId, self, self.OnPopupResult)
  self:ToggleToolTip(false)
end
function SocialPane:IsInGroup(playerId)
  local playerName = playerId.playerName
  for _, memberData in ipairs(self.groupMembers) do
    if memberData.playerName == playerName then
      return true
    end
  end
  return false
end
function SocialPane:ClickSocialMenuButton()
  self:ToggleSocialMenu()
end
function SocialPane:ClickAddToGroupButton()
  self:ToggleSocialMenu("GroupInvite")
end
function SocialPane:ToggleSocialMenu(reason)
  if reason == "SubArmy" then
    self.SocialMenu:SetEnabled(false, nil)
    local isEnabled = not self.SubArmyMenu.isEnabled
    self.SubArmyMenu:SetEnabled(isEnabled)
  else
    self.SubArmyMenu:SetEnabled(false)
    local isEnabled = not self.SocialMenu.isEnabled
    if self.SocialMenu.openReason ~= reason and isEnabled == false then
      self.SocialMenu:SetEnabled(isEnabled, reason)
      isEnabled = true
    end
    self.SocialMenu:SetEnabled(isEnabled, reason)
  end
  self:ToggleToolTip(false)
  self.audioHelper:PlaySound(self.audioHelper.GroupInviteSent)
end
function SocialPane:ShowAllMemberHealthBars(show)
  for _, data in pairs(self.groupMembers) do
    data.entity:ShowHealthBar(show)
    if not show then
      data.entity:FullGroupAdjustment(self.memberCount >= self.maxMemberCount)
    end
  end
end
function SocialPane:OnPopupResult(result, eventId)
  if result == ePopupResult_No then
    if eventId == self.onAcceptPopupEventId then
      GroupsRequestBus.Broadcast.RequestReplyToGroupInvite(self.pendingNotificationId, false)
      self.audioHelper:PlaySound(self.audioHelper.OnGuildNotificationDecline)
      self.pendingNotificationId = nil
    end
  elseif result == ePopupResult_Yes then
    if eventId == self.onLeavePopupEventId then
      if self.gameModeId == GameModeCommon.GAMEMODE_OUTPOST_RUSH then
        local playerEntityId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.PlayerEntityId")
        GameModeParticipantComponentRequestsBus.Event.SendClientEvent(playerEntityId, 2612035792)
      else
        GroupsRequestBus.Broadcast.RequestLeaveGroup()
      end
    elseif eventId == self.onAcceptPopupEventId then
      GroupsRequestBus.Broadcast.RequestReplyToGroupInvite(self.pendingNotificationId, true)
      self.audioHelper:PlaySound(self.audioHelper.OnGuildNotificationAccept)
      self.pendingNotificationId = nil
    elseif eventId == self.onMutePlayerEventId then
      ChatComponentBus.Broadcast.SendSetChatMute(self.playerToMute)
      self.playerToMute = nil
    elseif eventId == self.onUnmutePlayerEventId then
      ChatComponentBus.Broadcast.SendClearChatMute(self.playerToUnmute)
      self.playerToUnmute = nil
    elseif eventId == self.onBlockPlayerEventId then
      JavSocialComponentBus.Broadcast.RequestSetSocialBlock(self.playerToBlock)
      self.playerToBlock = nil
    elseif eventId == self.onUnblockPlayerEventId then
      JavSocialComponentBus.Broadcast.RequestClearSocialBlock(self.playerToUnblock)
      self.playerToUnblock = nil
    elseif eventId == self.onInvitePlayerEventId then
      GroupsRequestBus.Broadcast.RequestGroupInvite(self.playerToInvite)
      self.playerToInvite = nil
    end
  end
end
function SocialPane:OnFlyoutMenuClosed(entityId)
  self.currentFlyoutMenuType = EFlyoutMenuTypes.None
end
function SocialPane:OnWhisperPlayer(playerName)
  DynamicBus.ChatBus.Broadcast.OpenWhisperToPlayer(playerName)
end
function SocialPane:OnGroupInvite(simplePlayerId)
  local isInOutpostRushQueue = GameModeParticipantComponentRequestBus.Event.IsInQueueForGameMode(self.playerRootEntityId, GameModeCommon.GAMEMODE_OUTPOST_RUSH)
  if isInOutpostRushQueue then
    self.playerToInvite = simplePlayerId.characterIdString
    PopupWrapper:RequestPopup(ePopupButtons_YesNo, "@ui_invitetogroup", "@ui_queuewarning_invite", self.onInvitePlayerEventId, self, self.OnPopupResult)
  else
    GroupsRequestBus.Broadcast.RequestGroupInvite(simplePlayerId.characterIdString)
  end
end
function SocialPane:OnFriendInvite(simplePlayerId)
  if simplePlayerId == nil then
    Debug.Log("ERR - SocialPane:OnFriendInvite: playerId is nil")
    return
  end
  JavSocialComponentBus.Broadcast.RequestFriendStatusChange(eFriendRequestType_Invite, simplePlayerId:GetCharacterIdString())
  local notificationData = NotificationData()
  notificationData.type = "FriendInvite"
  notificationData.contextId = self.entityId
  notificationData.title = "@ui_friendrequesttitle"
  notificationData.text = GetLocalizedReplacementText("@ui_friendrequestsendermessage", {
    playerName = simplePlayerId.playerName
  })
  UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
end
function SocialPane:OnGuildInvite(simplePlayerId)
  GuildsComponentBus.Broadcast.RequestGuildInvite(simplePlayerId:GetCharacterIdString())
end
function SocialPane:OnViewTwitchStream(markerId)
  local channel = MarkerRequestBus.Event.GetTwitchChannel(markerId)
  if channel then
    OptionsDataBus.Broadcast.OpenTwitchStreamInBrowser(channel)
  end
end
function SocialPane:OnReport(reportData)
  DynamicBus.ReportPlayerBus.Broadcast.OpenReport(reportData.playerId)
end
function SocialPane:OnSpectate(characterId)
  LocalPlayerUIRequestsBus.Broadcast.RequestSpectatePlayer(characterId)
end
function SocialPane:OnDeclareWar(data)
  if self.enableDominion then
    warDeclarationPopupHelper:ShowWarDeclarationPopup(data.guildId, data.guildName, data.guildCrest, 0)
  end
end
function SocialPane:OnMutePlayer(characterId)
  self.playerToMute = characterId
  PopupWrapper:RequestPopup(ePopupButtons_YesNo, "@ui_mute_player", "@ui_mute_confirm", self.onMutePlayerEventId, self, self.OnPopupResult)
end
function SocialPane:OnUnmutePlayer(characterId)
  self.playerToUnmute = characterId
  PopupWrapper:RequestPopup(ePopupButtons_YesNo, "@ui_unmute_player", "@ui_unmute_confirm", self.onUnmutePlayerEventId, self, self.OnPopupResult)
end
function SocialPane:OnBlockPlayer(characterId)
  self.playerToBlock = characterId
  PopupWrapper:RequestPopup(ePopupButtons_YesNo, "@ui_block_player", "@ui_block_confirm", self.onBlockPlayerEventId, self, self.OnPopupResult)
end
function SocialPane:OnUnblockPlayer(characterId)
  self.playerToUnblock = characterId
  PopupWrapper:RequestPopup(ePopupButtons_YesNo, "@ui_unblock_player", "@ui_unblock_confirm", self.onUnblockPlayerEventId, self, self.OnPopupResult)
end
function SocialPane:ToggleToolTip(isVisible)
  local tooltipOpacity = UiFaderBus.Event.GetFadeValue(self.Properties.ToolTipContainer) or 0
  local xOffset = -20
  local animDuration = 0.13
  self.ScriptedEntityTweener:Stop(self.Properties.ToolTipContainer)
  if isVisible then
    if self.SocialMenu.isEnabled then
      return
    else
      self.ScriptedEntityTweener:PlayFromC(self.Properties.ToolTipContainer, 0.15, {opacity = 0, x = xOffset}, tweenerCommon.socialPaneShow)
    end
  end
  if isVisible ~= true and 0 < tooltipOpacity then
    self.ScriptedEntityTweener:Play(self.Properties.ToolTipContainer, animDuration, {opacity = 0, ease = "QuadOut"})
  end
end
function SocialPane:SetToolTipSizeAndPosition(text, entity, offset)
  UiTextBus.Event.SetTextWithFlags(self.Properties.ToolTipText, text, eUiTextSet_SetLocalized)
  local textSize = UiTextBus.Event.GetTextSize(self.Properties.ToolTipText)
  local textWidth = textSize.x
  local paddingX = 19
  textWidth = textWidth + paddingX
  UiTransform2dBus.Event.SetLocalWidth(self.Properties.ToolTipContainer, textWidth)
  local EntityCanvasPos = UiTransformBus.Event.GetCanvasPosition(entity)
  local ToolTipCanvasPos = UiTransformBus.Event.GetCanvasPosition(self.Properties.ToolTipContainer)
  ToolTipCanvasPos.y = EntityCanvasPos.y
  UiTransformBus.Event.SetCanvasPosition(self.Properties.ToolTipContainer, ToolTipCanvasPos)
  local currentTooltipY = UiTransformBus.Event.GetLocalPositionY(self.Properties.ToolTipContainer)
  self.ScriptedEntityTweener:Set(self.Properties.ToolTipContainer, {
    y = currentTooltipY + offset
  })
end
function SocialPane:FadeInSocialAlarmIndicator()
  if FtueSystemRequestBus.Broadcast.IsFtue() then
    return
  end
  UiElementBus.Event.SetIsEnabled(self.Properties.SocialAlarmIndicator, true)
  if self.isShowing then
    self.ScriptedEntityTweener:Set(self.Properties.SocialAlarmIndicator, {opacity = 0})
  else
    self.ScriptedEntityTweener:Play(self.Properties.SocialAlarmIndicator, 0.05, {opacity = 0}, {opacity = 1})
    self.ScriptedEntityTweener:Play(self.Properties.SocialAlarmIndicator, 0.15, {scaleX = 0, scaleY = 0}, {scaleX = 1.15, scaleY = 1.15})
    self.ScriptedEntityTweener:Play(self.Properties.SocialAlarmIndicator, 0.2, {scaleX = 1.15, scaleY = 1.15}, {
      scaleX = 1,
      scaleY = 1,
      delay = 0.25
    })
  end
  UiFlipbookAnimationBus.Event.SetCurrentFrame(self.Properties.AlarmIconEffect, 0)
  UiFlipbookAnimationBus.Event.Start(self.Properties.AlarmIconEffect)
  self.ScriptedEntityTweener:Set(self.Properties.AlarmIconRing, {rotation = 0})
  self.ScriptedEntityTweener:PlayC(self.Properties.AlarmIconRing, 22, tweenerCommon.rotateCWInfinite)
  UiCanvasBus.Event.SetDrawOrder(self.canvasId, CanvasCommon.TOP_LEVEL_DRAW_ORDER)
  self.currentDrawOrder = CanvasCommon.TOP_LEVEL_DRAW_ORDER
end
function SocialPane:FadeOutSocialAlarmIndicator()
  if UiCanvasBus.Event.GetEnabled(self.canvasId) then
    self.hideSocialAlarm = true
    self.ScriptedEntityTweener:Play(self.Properties.SocialAlarmIndicator, 0.5, {
      opacity = 0,
      ease = "QuadIn",
      onComplete = function()
        self:HideSocialAlarmIndicator()
      end
    })
  else
    self:HideSocialAlarmIndicator()
  end
end
function SocialPane:HideSocialAlarmIndicator()
  UiElementBus.Event.SetIsEnabled(self.Properties.SocialAlarmIndicator, false)
  UiFlipbookAnimationBus.Event.Stop(self.Properties.AlarmIconEffect)
  self.ScriptedEntityTweener:Stop(self.Properties.AlarmIconRing)
  UiCanvasBus.Event.SetDrawOrder(self.canvasId, self.initialDrawOrder)
  self.currentDrawOrder = self.initialDrawOrder
  self.hideSocialAlarm = false
end
function SocialPane:FadeDownAlarmEffect(isFaded)
  self.ScriptedEntityTweener:Play(self.Properties.AlarmIconEffectStatic, 0.3, {
    opacity = isFaded and 0.5 or 1
  })
end
function SocialPane:OnTransitionIn(fromState, fromLevel, toState, toLevel)
  if self.screenStatesToHide[toState] then
    UiCanvasBus.Event.SetEnabled(self.canvasId, false)
  elseif self.screenStatesToHideGroupHealthBars[toState] then
    self:VisibilityChanged(true)
  else
    self:VisibilityChanged(false)
  end
end
function SocialPane:OnTransitionOut(fromState, fromLevel, toState, toLevel)
  if self.screenStatesToHide[fromState] and self.canvasId then
    UiCanvasBus.Event.SetEnabled(self.canvasId, true)
  end
  if self.screenStatesToHideGroupHealthBars[toState] then
    self:VisibilityChanged(true)
  else
    self:VisibilityChanged(false)
  end
  LyShineManagerBus.Broadcast.TransitionOutComplete()
end
function SocialPane:OnCanvasSizeOrScaleChange(canvasId)
  if self.canvasId == canvasId then
    AdjustElementToCanvasSize(self.entityId, self.canvasId)
  end
end
function SocialPane:OnLoadingScreenDismissed()
  self:UpdateGroupButtons()
end
function SocialPane:OnTick(deltaTime, timePoint)
  self:TickVoipJoin(deltaTime, timePoint)
end
function SocialPane:ShowGroupAlertMessage(msg)
  UiTextBus.Event.SetText(self.Properties.GroupAlertMessage, msg)
end
function SocialPane:RejectAllInvites()
  self.SocialMenu:RejectAllInvites()
end
return SocialPane
