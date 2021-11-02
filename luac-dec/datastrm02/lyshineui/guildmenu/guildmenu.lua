local dominionCommon = RequireScript("LyShineUI._Common.DominionCommon")
local timeHelpers = RequireScript("LyShineUI._Common.TimeHelperFunctions")
local PopupWrapper = RequireScript("LyShineUI.Popup.PopupRequestWrapper")
local TerritoryDataHandler = RequireScript("LyShineUI._Common.TerritoryDataHandler")
local GuildMenu = {
  Properties = {
    ActionMapActivator = {
      default = "toggleGuildComponent"
    },
    PrimaryTabbedList = {
      default = EntityId()
    },
    SecondaryTabbedList = {
      default = EntityId()
    },
    NoGuildContainer = {
      default = EntityId(),
      order = 0
    },
    MyGuild = {
      PrimaryScreen = {
        default = EntityId()
      },
      InviteGuildButton = {
        default = EntityId()
      },
      LeaveGuildButton = {
        default = EntityId()
      },
      Overview = {
        Screen = {
          default = EntityId(),
          order = 0
        },
        LeftColumn = {
          default = EntityId(),
          order = 0
        },
        RightColumn = {
          default = EntityId(),
          order = 0
        },
        Crest = {
          default = EntityId()
        },
        CrestInvalid = {
          default = EntityId()
        },
        CrestBg = {
          default = EntityId()
        },
        Wash = {
          default = EntityId()
        },
        ArcanaBg = {
          default = EntityId()
        },
        ArcanaRing1 = {
          default = EntityId()
        },
        ArcanaRing2 = {
          default = EntityId()
        },
        ArcanaRing3 = {
          default = EntityId()
        },
        ArcanaExtras = {
          default = EntityId()
        },
        EditCrestButton = {
          default = EntityId()
        },
        GuildName = {
          default = EntityId()
        },
        GuildNameText = {
          default = EntityId()
        },
        GuildNameInput = {
          default = EntityId()
        },
        GuildNameInputBg = {
          default = EntityId()
        },
        GuildNameInputText = {
          default = EntityId()
        },
        EditGuildNameButton = {
          default = EntityId()
        },
        SubmitGuildNameButton = {
          default = EntityId()
        },
        CancelGuildNameButton = {
          default = EntityId()
        },
        ClaimCount = {
          default = EntityId()
        },
        ClaimLabel = {
          default = EntityId()
        },
        GuildLeader = {
          default = EntityId()
        },
        GuildLeaderLabel = {
          default = EntityId()
        },
        FactionName = {
          default = EntityId()
        },
        FactionLabel = {
          default = EntityId()
        },
        MessageOfTheDay = {
          default = EntityId()
        },
        MessageOfTheDayText = {
          default = EntityId()
        },
        MessageOfTheDayTitle = {
          default = EntityId()
        },
        MessageOfTheDayInputContainer = {
          default = EntityId()
        },
        MessageOfTheDayInput = {
          default = EntityId()
        },
        MessageOfTheDayInputBg = {
          default = EntityId()
        },
        MessageOfTheDayInputText = {
          default = EntityId()
        },
        EditMessageOfTheDayButton = {
          default = EntityId()
        },
        SubmitMessageOfTheDayButton = {
          default = EntityId()
        },
        CancelMessageOfTheDayButton = {
          default = EntityId()
        },
        OverviewDivider = {
          default = EntityId()
        }
      },
      Roster = {
        Screen = {
          default = EntityId(),
          order = 0
        },
        Content = {
          default = EntityId(),
          order = 1
        }
      },
      Wars = {
        Screen = {
          default = EntityId(),
          order = 0
        },
        Content = {
          default = EntityId(),
          order = 1
        }
      },
      Ranks = {
        Screen = {
          default = EntityId(),
          order = 0
        },
        Content = {
          default = EntityId(),
          order = 1
        },
        DividerLine = {
          default = EntityId()
        }
      },
      EditCrest = {
        Screen = {
          default = EntityId(),
          order = 0
        },
        Content = {
          default = EntityId(),
          order = 1
        }
      },
      SiegeWindow = {
        Screen = {
          default = EntityId(),
          order = 0
        },
        Content = {
          default = EntityId(),
          order = 1
        }
      },
      TreasuryWindow = {
        Screen = {
          default = EntityId(),
          order = 0
        },
        Content = {
          default = EntityId(),
          order = 1
        }
      }
    },
    AllGuilds = {
      PrimaryScreen = {
        default = EntityId()
      },
      NumItemsPerMouseWheelStep = {default = 4},
      ListItemBox = {
        default = EntityId()
      },
      ListItemBoxContent = {
        default = EntityId()
      },
      ListItemPrototype = {
        default = EntityId()
      },
      WalletCurrencyDisplay = {
        default = EntityId()
      },
      PageNumberContainer = {
        default = EntityId()
      },
      PrevPageButton = {
        default = EntityId()
      },
      NextPageButton = {
        default = EntityId()
      },
      RefreshButton = {
        default = EntityId()
      },
      PageNumberText = {
        default = EntityId()
      },
      PaginationButtonGroup = {
        default = EntityId()
      },
      SortNameButton = {
        default = EntityId()
      },
      SortMembersButton = {
        default = EntityId()
      },
      SortClaimsButton = {
        default = EntityId()
      },
      LoadingSpinnerContainer = {
        default = EntityId()
      },
      LoadingSpinner = {
        default = EntityId()
      },
      HeaderText = {
        default = EntityId()
      }
    }
  },
  guildMenuName = "Guild",
  onLeavePopupEventId = "Popup_OnLeave",
  onForcedRenamePopupEventId = "Popup_OnForcedRename",
  guildName = "",
  firstTimeLeaderUpdate = true,
  numGuilds = 0,
  minGuildSize = 1,
  guildsPerPage = 0,
  currentPage = 1,
  secondsBetweenSetConsequenceNotifications = 30 * timeHelpers.secondsInMinute,
  enableDominion = false,
  motdProfanityFilter = false,
  treasuryTimer = 0,
  treasuryTimerTick = 10,
  PaginationButtonTargetWidth = 36,
  DisabledInviteButtonOpacity = 0.6,
  primaryScreenTransitionOutTime = 0.1,
  primaryScreenTransitionInTime = 0.2,
  myGuildScreenTransitionOutTime = 0.1,
  myGuildScreenTransitionInTime = 0.2,
  currentPrimaryTabId = nil,
  currentPrimaryScreen = nil,
  isGuildNameInputShowing = false,
  isGuildMessageOfTheDayInputShowing = false,
  loadingSpinnerOpacity = 0.7
}
local BaseScreen = RequireScript("LyShineUI._Common.BaseScreen")
BaseScreen:CreateNewScreen(GuildMenu)
local SocialDataHandler = RequireScript("LyShineUI._Common.SocialDataHandler")
function GuildMenu:OnInit()
  BaseScreen.OnInit(self)
  self.guildMenuBusHandler = DynamicBus.GuildMenuBus.Connect(self.entityId, self)
  self.socialDataHandler = SocialDataHandler
  self.socialDataHandler:OnActivate()
  self.dataLayer:RegisterOpenEvent(self.guildMenuName, self.canvasId)
  self:BusConnect(CryActionNotificationsBus, self.ActionMapActivator)
  self:BusConnect(UiDynamicScrollBoxDataBus, self.AllGuilds.ListItemBox)
  self:BusConnect(UiDynamicScrollBoxElementNotificationBus, self.AllGuilds.ListItemBox)
  self:BusConnect(UiTextInputNotificationBus, self.Properties.MyGuild.Overview.GuildNameInput)
  self.primaryTabsData = {
    {
      text = "@ui_guildoverviewtab",
      callback = self.SelectOverviewTab,
      name = "MyGuildTab",
      isEnabled = true,
      width = 338,
      height = 70,
      glowOffsetWidth = 222
    },
    {
      text = "@ui_otherguildstitle",
      callback = self.SelectAllGuildsTab,
      name = "AllGuildsTab",
      isEnabled = true,
      width = 338,
      height = 70,
      glowOffsetWidth = 222
    }
  }
  self.secondaryTabsData = {
    {
      text = "@ui_guildoverviewtab",
      callback = self.ShowMyGuildOverview,
      name = "GuildOverviewTab",
      style = 2,
      isEnabled = true,
      iconPath = "lyshineui/images/icons/guildmenu/overview.dds"
    },
    {
      text = "@ui_guildrostertab",
      callback = self.ShowMyGuildRoster,
      name = "RosterTab",
      style = 2,
      isEnabled = true
    },
    {
      text = "@ui_guildrankstab",
      callback = self.ShowMyGuildRanks,
      name = "RanksTab",
      style = 2,
      isEnabled = true,
      iconPath = "lyshineui/images/icons/guildmenu/ranks.dds"
    },
    {
      text = "@ui_warstitle",
      callback = self.ShowMyGuildWars,
      name = "WarsTab",
      style = 2,
      isEnabled = true,
      iconPath = "lyshineui/images/icons/misc/icon_waruncolored.dds",
      secondaryText = "@ui_guildwarstabsubtitle"
    },
    {
      text = "@ui_guildsiegetab",
      callback = self.ShowMyGuildSiegeWindow,
      name = "SiegeTab",
      style = 2,
      isEnabled = true,
      iconPath = "lyshineui/images/icons/misc/icon_siegeWindowBig.dds"
    },
    {
      text = "@ui_guildtreasurytab",
      callback = self.ShowMyGuildTreasuryWindow,
      name = "TreasuryTab",
      style = 2,
      isEnabled = true,
      iconPath = "lyshineui/images/icons/guildmenu/guildMenu_iconTreasury.dds",
      secondaryText = "-"
    }
  }
  self.primaryTabNameToIndex = {}
  self.secondaryTabNameToIndex = {}
  for i = 1, #self.primaryTabsData do
    local currentTab = self.primaryTabsData[i]
    self.primaryTabNameToIndex[currentTab.name] = i
  end
  for i = 1, #self.secondaryTabsData do
    local currentTab = self.secondaryTabsData[i]
    self.secondaryTabNameToIndex[currentTab.name] = i
  end
  self.PrimaryTabbedList:SetListData(self.primaryTabsData, self)
  self.SecondaryTabbedList:SetListData(self.secondaryTabsData, self)
  self.primaryTabs = {}
  self.primaryTabs.myGuildTab = self.PrimaryTabbedList:GetIndex(self.primaryTabNameToIndex.MyGuildTab)
  self.primaryTabs.allGuildsTab = self.PrimaryTabbedList:GetIndex(self.primaryTabNameToIndex.AllGuildsTab)
  self.secondaryTabs = {}
  self.secondaryTabs.guildOverviewTab = self.SecondaryTabbedList:GetIndex(self.secondaryTabNameToIndex.GuildOverviewTab)
  self.secondaryTabs.rosterTab = self.SecondaryTabbedList:GetIndex(self.secondaryTabNameToIndex.RosterTab)
  self.secondaryTabs.ranksTab = self.SecondaryTabbedList:GetIndex(self.secondaryTabNameToIndex.RanksTab)
  self.secondaryTabs.warsTab = self.SecondaryTabbedList:GetIndex(self.secondaryTabNameToIndex.WarsTab)
  self.secondaryTabs.siegeTab = self.SecondaryTabbedList:GetIndex(self.secondaryTabNameToIndex.SiegeTab)
  self.secondaryTabs.treasuryTab = self.SecondaryTabbedList:GetIndex(self.secondaryTabNameToIndex.TreasuryTab)
  self.MyGuild.Ranks.Content:SetTab(self.secondaryTabs.ranksTab)
  self.MyGuild.TreasuryWindow.Content:SetTab(self.secondaryTabs.treasuryTab)
  self.enableDominion = self.dataLayer:GetDataFromNode("UIFeatures.g_enableDominion")
  self.secondaryTabs.warsTab:SetEnabled(self.enableDominion)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Guild.Enabled", function(self, enabled)
    if enabled then
      self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Guild.GuildLeader", self.UpdateGuildLeader)
      self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Guild.Id", self.OnGuildChange)
    end
  end)
  local registerDataObserver = self.dataLayer.RegisterDataObserver
  local registerAndExecuteDataObserver = self.dataLayer.RegisterAndExecuteDataObserver
  local registerDataCallback = self.dataLayer.RegisterDataCallback
  self.visibleOnlyDataLayerPaths = {}
  self.visibleOnlyDataLayerPaths["Hud.LocalPlayer.Guild.Name"] = {
    callback = self.UpdateGuildName,
    regFunction = registerAndExecuteDataObserver
  }
  self.visibleOnlyDataLayerPaths["Hud.LocalPlayer.Guild.Crest"] = {
    callback = self.UpdateCrest,
    regFunction = registerAndExecuteDataObserver
  }
  self.visibleOnlyDataLayerPaths["Hud.LocalPlayer.Guild.MessageOfTheDay"] = {
    callback = self.UpdateMessageOfTheDay,
    regFunction = registerAndExecuteDataObserver
  }
  self.visibleOnlyDataLayerPaths["Hud.LocalPlayer.Options.Accessibility.ChatProfanityFilter"] = {
    callback = self.FilterMessageOfTheDay,
    regFunction = registerDataObserver
  }
  self.visibleOnlyDataLayerPaths["Hud.LocalPlayer.Guild.NumClaims"] = {
    callback = self.UpdateNumClaims,
    regFunction = registerAndExecuteDataObserver
  }
  self.visibleOnlyDataLayerPaths["Hud.LocalPlayer.Guild.GuildWarCount"] = {
    callback = self.UpdateGuildWarCount,
    regFunction = registerAndExecuteDataObserver
  }
  self.visibleOnlyDataLayerPaths["Hud.LocalPlayer.Currency.Amount"] = {
    callback = self.UpdateCurrency,
    regFunction = registerAndExecuteDataObserver
  }
  self.visibleOnlyDataLayerPaths["Hud.LocalPlayer.Guild.IsFull"] = {
    callback = self.UpdateIsFull,
    regFunction = registerDataObserver
  }
  self.visibleOnlyDataLayerPaths["Hud.LocalPlayer.Guild.Rank"] = {
    callback = self.UpdatePermissions,
    regFunction = registerDataObserver
  }
  self.visibleOnlyDataLayerPaths["Hud.LocalPlayer.Guild.MemberCount"] = {
    callback = self.OnMemberCountChanged,
    regFunction = registerAndExecuteDataObserver
  }
  self.visibleOnlyDataLayerPaths["Hud.LocalPlayer.Guild.LastUpdatedMember.CharacterIdString"] = {
    callback = self.UpdateMembersOnlineCount,
    regFunction = registerDataCallback
  }
  self.visibleOnlyDataLayerPaths["Hud.LocalPlayer.Social.LastUpdatedPlayer.PlayerId"] = {
    callback = self.UpdateMembersOnlineCount,
    regFunction = registerDataCallback
  }
  self.visibleOnlyDataLayerPaths["Hud.LocalPlayer.Guild.Faction"] = {
    callback = self.UpdateFactionName,
    regFunction = registerAndExecuteDataObserver
  }
  self.dataLayer:RegisterDataCallback(self, "Hud.LocalPlayer.Guild.LastModifiedGuildWarId", self.OnGuildWarUpdated)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.SocialEntityId", function(self, socialEntityId)
    if socialEntityId then
      self:BusConnect(SocialNotificationsBus, socialEntityId)
    end
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.GDERootEntityId", function(self, socialEntityId)
    if socialEntityId then
      self:BusConnect(GuildNotificationsBus, socialEntityId)
    end
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Guild.ForcedRename", self.OnForcedRename)
  self.timeHelpers = timeHelpers
  self.otherGuilds = {}
  self.guildWars = {}
  self.guildsPerPage = 20
  self.pageKeys = {
    [0] = ""
  }
  self.currentPage = 1
  self.destinationPage = nil
  self.scoutingPhaseEndWarnings = {}
  local factionCommon = RequireScript("LyShineUI._Common.FactionCommon")
  self.factionNames = {}
  for factionEnum, factionData in ipairs(factionCommon.factionInfoTable) do
    self.factionNames[factionEnum] = factionData.factionName
  end
  local iconXPadding = 5
  local coinIconPath = "lyshineui/images/Icon_Crown"
  self.coinImgText = string.format("<img src=\"%s\" xPadding=\"%d\" yOffset=\"3\"></img>", coinIconPath, iconXPadding)
  local infinityIconPath = "lyshineui/images/icons/misc/infinity_tan.png"
  self.infinitySymbolImgText = string.format("<img src=\"%s\" xPadding=\"%d\" yOffset=\"3\"></img>", infinityIconPath, iconXPadding)
  self.currencyColorHexString = ColorRgbaToHexString(self.UIStyle.COLOR_YELLOW_GOLD)
  self.SCOUTING_PHASE_WARNING_TIME = 15 * timeHelpers.secondsInMinute
  self.AllGuilds.SortNameButton:SetCallback("SortByName", self)
  self.AllGuilds.SortMembersButton:SetCallback("SortBySize", self)
  self.AllGuilds.SortClaimsButton:SetCallback("SortByClaims", self)
  self.sortOption = "claims"
  self.sortOrder = eSocialOrderDescending
  self.AllGuilds.SortClaimsButton:SetSelectedDescending()
  UiDynamicScrollBoxBus.Event.RefreshContent(self.Properties.AllGuilds.ListItemBox)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Guild.NameLength", function(self, maxlength)
    if maxlength then
      UiTextInputBus.Event.SetMaxStringLength(self.Properties.MyGuild.Overview.GuildNameInput, maxlength)
    end
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Guild.MessageOfTheDayLength", function(self, maxlength)
    if maxlength then
      UiTextInputBus.Event.SetMaxStringLength(self.Properties.MyGuild.Overview.MessageOfTheDayInput, maxlength)
    end
  end)
  self:CreateArcanaTimelines()
  self.MyGuild.Overview.OverviewDivider:SetColor(self.UIStyle.COLOR_TAN)
  self.MyGuild.Ranks.DividerLine:SetColor(self.UIStyle.COLOR_TAN)
  SetTextStyle(self.MyGuild.Overview.GuildNameText, self.UIStyle.FONT_STYLE_GUILD_NAME_LARGE)
  local inputTextStyle = DeepClone(self.UIStyle.FONT_STYLE_GUILD_NAME_LARGE)
  inputTextStyle.fontColor = self.UIStyle.COLOR_TAN_LIGHT
  SetTextStyle(self.MyGuild.Overview.GuildNameInputText, inputTextStyle)
  UiImageBus.Event.SetColor(self.Properties.MyGuild.Overview.GuildNameInputBg, self.UIStyle.COLOR_INPUT_BG)
  SetTextStyle(self.MyGuild.Overview.MessageOfTheDayTitle, self.UIStyle.FONT_STYLE_HEADER_SMALL_CAPS)
  SetTextStyle(self.MyGuild.Overview.MessageOfTheDayText, self.UIStyle.FONT_STYLE_BODY)
  inputTextStyle = DeepClone(self.UIStyle.FONT_STYLE_BODY)
  inputTextStyle.fontColor = self.UIStyle.COLOR_TAN_LIGHT
  SetTextStyle(self.MyGuild.Overview.MessageOfTheDayInputText, inputTextStyle)
  UiImageBus.Event.SetColor(self.Properties.MyGuild.Overview.MessageOfTheDayInputBg, self.UIStyle.COLOR_INPUT_BG)
  UiElementBus.Event.SetIsEnabled(self.Properties.MyGuild.Overview.ClaimCount, true)
  SetTextStyle(self.MyGuild.Overview.ClaimLabel, self.UIStyle.FONT_STYLE_GUILD_STAT_LABEL)
  SetTextStyle(self.MyGuild.Overview.ClaimCount, self.UIStyle.FONT_STYLE_GUILD_STAT_NUMBER)
  UiElementBus.Event.SetIsEnabled(self.Properties.MyGuild.Overview.GuildLeader, true)
  SetTextStyle(self.MyGuild.Overview.GuildLeaderLabel, self.UIStyle.FONT_STYLE_GUILD_STAT_LABEL)
  SetTextStyle(self.MyGuild.Overview.GuildLeader, self.UIStyle.FONT_STYLE_GUILD_STAT_TEXT)
  UiElementBus.Event.SetIsEnabled(self.Properties.MyGuild.Overview.FactionLabel, true)
  SetTextStyle(self.MyGuild.Overview.FactionLabel, self.UIStyle.FONT_STYLE_GUILD_STAT_LABEL)
  SetTextStyle(self.MyGuild.Overview.FactionName, self.UIStyle.FONT_STYLE_GUILD_STAT_TEXT)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Social.DataSynced", function(self, synced)
    if synced then
      self.siegeDuration = WarRequestBus.Broadcast.GetWarPhaseDuration(eWarPhase_Conquest):ToHours()
    end
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Guild.SiegeWindow", function(self, siegeWindow)
    self.siegeWindow = siegeWindow
    self:RefreshSiegeWindowTabSecondaryText()
  end)
  self.dataLayer:RegisterDataObserver(self, "Hud.LocalPlayer.Options.Localization.Language", function(self, setLang)
    self:RefreshSiegeWindowTabSecondaryText()
    UiTextBus.Event.SetTextWithFlags(self.Properties.AllGuilds.HeaderText, LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement("@ui_otherguildstitlewithworld", LyShineManagerBus.Broadcast.GetWorldName()), eUiTextSet_SetAsIs)
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "UIFeatures.g_enableCompanyTreasury", function(self, companyTreasuryEnabled)
    if companyTreasuryEnabled ~= nil then
      self.secondaryTabs.treasuryTab:SetEnabled(companyTreasuryEnabled)
    end
  end)
  self.treasuryTimerTick = 1
  self.MyGuild.EditCrest.Content:SetOnCloseCallback(self.HideMyGuildEditCrest, self)
  self.MyGuild.Roster.Content:SetGuildMenuEntityId(self.entityId)
  self.MyGuild.Overview.EditCrestButton:SetCallback("ShowMyGuildEditCrest", self)
  self.MyGuild.Overview.EditCrestButton:SetText("@ui_modifycrest", false, true)
  self.MyGuild.Overview.EditCrestButton:SetTextStyle(self.UIStyle.FONT_STYLE_EDIT_BUTTON)
  self.MyGuild.Overview.EditGuildNameButton:SetCallback("OnEditName", self)
  self.MyGuild.Overview.EditGuildNameButton:SetText("@ui_modifyguildname", false, true)
  self.MyGuild.Overview.EditGuildNameButton:SetTextStyle(self.UIStyle.FONT_STYLE_EDIT_BUTTON)
  self.MyGuild.Overview.SubmitGuildNameButton:SetCallback("OnSubmitName", self)
  self.MyGuild.Overview.SubmitGuildNameButton:SetText("@ui_save")
  self.MyGuild.Overview.SubmitGuildNameButton:SetTextStyle(self.UIStyle.FONT_STYLE_BUTTON_SIMPLE_CTA)
  self.MyGuild.Overview.SubmitGuildNameButton:SetBackgroundColor(self.UIStyle.COLOR_BUTTON_SIMPLE_CTA)
  self.MyGuild.Overview.SubmitGuildNameButton:SetButtonBgTexture(self.MyGuild.Overview.SubmitGuildNameButton.BG_TEXTURE_STYLE_COLOR_BACKGROUND)
  self.MyGuild.Overview.CancelGuildNameButton:SetCallback("OnCancelEditName", self)
  self.MyGuild.Overview.CancelGuildNameButton:SetText("@ui_cancel")
  self.MyGuild.Overview.CancelGuildNameButton:SetTextStyle(self.UIStyle.FONT_STYLE_EDIT_BUTTON)
  self.MyGuild.Overview.EditMessageOfTheDayButton:SetCallback("OnEditMessageOfTheDay", self)
  self.MyGuild.Overview.EditMessageOfTheDayButton:SetText("@ui_modifymessageoftheday", false, true)
  self.MyGuild.Overview.EditMessageOfTheDayButton:SetTextStyle(self.UIStyle.FONT_STYLE_EDIT_BUTTON)
  self.MyGuild.Overview.SubmitMessageOfTheDayButton:SetCallback("OnSubmitMessageOfTheDay", self)
  self.MyGuild.Overview.SubmitMessageOfTheDayButton:SetText("@ui_save")
  self.MyGuild.Overview.SubmitMessageOfTheDayButton:SetTextStyle(self.UIStyle.FONT_STYLE_BUTTON_SIMPLE_CTA)
  self.MyGuild.Overview.SubmitMessageOfTheDayButton:SetBackgroundColor(self.UIStyle.COLOR_BUTTON_SIMPLE_CTA)
  self.MyGuild.Overview.SubmitMessageOfTheDayButton:SetButtonBgTexture(self.MyGuild.Overview.SubmitMessageOfTheDayButton.BG_TEXTURE_STYLE_COLOR_BACKGROUND)
  self.MyGuild.Overview.CancelMessageOfTheDayButton:SetCallback("OnCancelEditMessageOfTheDay", self)
  self.MyGuild.Overview.CancelMessageOfTheDayButton:SetText("@ui_cancel")
  self.MyGuild.Overview.CancelMessageOfTheDayButton:SetTextStyle(self.UIStyle.FONT_STYLE_EDIT_BUTTON)
  self.MyGuild.LeaveGuildButton:SetCallback("OnContextLeave", self)
  self.MyGuild.LeaveGuildButton:SetText("@ui_leaveguild")
  self.MyGuild.LeaveGuildButton:SetTextStyle(self.UIStyle.FONT_STYLE_EDIT_BUTTON)
  self.MyGuild.LeaveGuildButton:SetTextAlignment(self.MyGuild.LeaveGuildButton.TEXT_ALIGN_LEFT)
  self.MyGuild.InviteGuildButton:SetCallback("OnContextInvite", self)
  self.MyGuild.InviteGuildButton:SetText("@ui_sendguildinvite")
  self.MyGuild.InviteGuildButton:SetTextStyle(self.UIStyle.FONT_STYLE_BUTTON_SIMPLE_CTA)
  self.MyGuild.InviteGuildButton:SetTextColor(self.UIStyle.COLOR_BLACK)
  self.MyGuild.InviteGuildButton:SetBackgroundColor(self.UIStyle.COLOR_BUTTON_SIMPLE_CTA)
  self.MyGuild.InviteGuildButton:SetButtonBgTexture(self.MyGuild.InviteGuildButton.BG_TEXTURE_STYLE_COLOR_BACKGROUND)
  self.MyGuild.InviteGuildButton:SetTextAlignment(self.MyGuild.InviteGuildButton.TEXT_ALIGN_LEFT)
  self.AllGuilds.RefreshButton:SetCallback("OnClickRefreshPage", self)
  self.AllGuilds.RefreshButton:SetTextStyle(self.UIStyle.FONT_STYLE_EDIT_BUTTON)
  self.AllGuilds.RefreshButton:SetText("@ui_refreshpage", false, true)
  UiTextBus.Event.SetTextWithFlags(self.Properties.AllGuilds.HeaderText, LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement("@ui_otherguildstitlewithworld", LyShineManagerBus.Broadcast.GetWorldName()), eUiTextSet_SetAsIs)
end
function GuildMenu:OnShutdown()
  BaseScreen.OnShutdown(self)
  self.socialDataHandler:OnDeactivate()
  self:DestroyArcanaTimelines()
  if self.allGuildsLoadingSpinnerTimeline then
    self.ScriptedEntityTweener:TimelineDestroy(self.allGuildsLoadingSpinnerTimeline)
    self.allGuildsLoadingSpinnerTimeline = nil
  end
  if self.guildMenuBusHandler then
    DynamicBus.GuildMenuBus.Disconnect(self.entityId, self)
    self.guildMenuBusHandler = nil
  end
end
function GuildMenu:RegisterObservers()
  for path, data in pairs(self.visibleOnlyDataLayerPaths) do
    data.regFunction(self.dataLayer, self, path, data.callback)
  end
end
function GuildMenu:UnregisterObservers()
  for path, _ in pairs(self.visibleOnlyDataLayerPaths) do
    self.dataLayer:UnregisterObserver(self, path)
  end
end
function GuildMenu:OnTransitionIn(stateName, levelName)
  self.isVisible = true
  self.guildId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Guild.Id")
  self.motdProfanityFilter = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Options.Accessibility.ChatProfanityFilter")
  self.isGuildFull = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Guild.IsFull")
  self.ScriptedEntityTweener:Play(self.Properties.SecondaryTabbedList, 0.5, {opacity = 0}, {opacity = 1, ease = "QuadOut"})
  self:CheckGuildValidity()
  self:SetupButtons()
  self:RegisterObservers()
  self:UpdatePermissions()
  self:UpdateMembersOnlineCount()
  if self.currentPrimaryScreen == self.AllGuilds.PrimaryScreen then
    self:RefreshAllGuilds(true)
  end
  self.PrimaryTabbedList:SetSelected(self.primaryTabNameToIndex.MyGuildTab)
  JavelinCameraRequestBus.Broadcast.EnableDepthOfField(true)
  JavelinCameraRequestBus.Broadcast.SetDepthOfField(self.UIStyle.BLUR_DEPTH_OF_FIELD, self.UIStyle.BLUR_AMOUNT, self.UIStyle.BLUR_NEAR_DISTANCE, self.UIStyle.BLUR_NEAR_SCALE, self.UIStyle.RANGE_DEPTH_OF_FIELD)
end
function GuildMenu:OnTransitionOut(stateName, levelName)
  self.isVisible = false
  self:UnregisterObservers()
  UiContextMenuBus.Broadcast.SetEnabled(false)
  LyShineManagerBus.Broadcast.TransitionOutComplete()
  self.MyGuild.TreasuryWindow.Content:ClosePopups()
  self:HideAllInputs()
  self.ScriptedEntityTweener:Play(self.Properties.SecondaryTabbedList, 0.3, {opacity = 0, ease = "QuadOut"})
  if self.currentMyGuildScreen then
    do
      local closingScreen = self.currentMyGuildScreen
      self.ScriptedEntityTweener:Play(self.currentMyGuildScreen, self.myGuildScreenTransitionOutTime, {
        opacity = 0,
        onComplete = function()
          UiElementBus.Event.SetIsEnabled(closingScreen, false)
        end
      })
      self.currentMyGuildScreen = nil
    end
  end
  if self.currentMyGuildContent and self.currentMyGuildContent.SetVisible and type(self.currentMyGuildContent.SetVisible) == "function" then
    self.currentMyGuildContent:SetVisible(false)
    self.currentMyGuildContent = nil
  end
  self.PrimaryTabbedList:SetUnselected()
  self.SecondaryTabbedList:SetUnselected()
  if self.overviewArcanaTimelines then
    for _, timeline in pairs(self.overviewArcanaTimelines) do
      timeline:Stop()
    end
  end
  self.tickForTreasury = false
  self:StopTick()
  JavelinCameraRequestBus.Broadcast.ResetDepthOfField()
  DynamicBus.FullScreenSpinner.Broadcast.SetFullscreenSpinnerVisible(false)
end
function GuildMenu:SetupButtons()
  self.MyGuild.Overview.SubmitGuildNameButton:SetBackgroundOpacity(self.UIStyle.BUTTON_SIMPLE_CTA_OPACITY)
  self.MyGuild.Overview.SubmitMessageOfTheDayButton:SetBackgroundOpacity(self.UIStyle.BUTTON_SIMPLE_CTA_OPACITY)
  self.MyGuild.Overview.EditCrestButton:SizeToText()
  self.MyGuild.Overview.EditGuildNameButton:SizeToText()
  self.MyGuild.Overview.EditMessageOfTheDayButton:SizeToText()
  self.MyGuild.InviteGuildButton:SetBackgroundOpacity(self.UIStyle.BUTTON_SIMPLE_CTA_OPACITY)
  self.AllGuilds.RefreshButton:SizeToText()
  local inviteButtonMargin = 6
  local leaveButtonWidth = UiTransform2dBus.Event.GetLocalWidth(self.Properties.MyGuild.LeaveGuildButton)
end
function GuildMenu:SelectOverviewTab()
  if self.isInValidGuild then
    if self.currentPrimaryScreen and self.currentPrimaryScreen ~= self.MyGuild.PrimaryScreen then
      do
        local screen = self.currentPrimaryScreen
        self.ScriptedEntityTweener:Play(self.currentPrimaryScreen, self.primaryScreenTransitionOutTime, {
          opacity = 0,
          onComplete = function()
            UiElementBus.Event.SetIsEnabled(screen, false)
          end
        })
      end
    end
    UiElementBus.Event.SetIsEnabled(self.Properties.MyGuild.PrimaryScreen, true)
    self.ScriptedEntityTweener:Play(self.Properties.MyGuild.PrimaryScreen, self.primaryScreenTransitionInTime, {
      opacity = 1,
      delay = self.primaryScreenTransitionOutTime
    })
    self.currentPrimaryScreen = self.MyGuild.PrimaryScreen
    self.treasuryTimer = 0
    self.MyGuild.TreasuryWindow.Content:UpdateTreasuryData()
    self.tickForTreasury = true
    self:StartTick()
    self:RefreshWars()
    self:ShowAllGuildsLoadingSpinner(false)
    if self.showingWarsTabFromNotification then
      self.SecondaryTabbedList:SetUnselected()
      self.SecondaryTabbedList:SetSelected(self.secondaryTabNameToIndex.WarsTab)
      self.showingWarsTabFromNotification = false
    elseif self.showingCompanyRenameFromNotification then
      self.SecondaryTabbedList:SetUnselected()
      self.SecondaryTabbedList:SetSelected(self.secondaryTabNameToIndex.GuildOverviewTab)
      self:OnEditName()
      self.showingCompanyRenameFromNotification = false
    elseif self.currentMyGuildContent and self.currentMyGuildContent.SetVisible and type(self.currentMyGuildContent.SetVisible) == "function" then
      self.currentMyGuildContent:SetVisible(true)
    else
      self.SecondaryTabbedList:SetUnselected()
      self.SecondaryTabbedList:SetSelected(self.secondaryTabNameToIndex.GuildOverviewTab)
    end
  else
    if self.currentPrimaryScreen and self.currentPrimaryScreen ~= self.Properties.NoGuildContainer then
      do
        local screen = self.currentPrimaryScreen
        self.ScriptedEntityTweener:Play(self.currentPrimaryScreen, self.primaryScreenTransitionOutTime, {
          opacity = 0,
          onComplete = function()
            UiElementBus.Event.SetIsEnabled(screen, false)
          end
        })
      end
    end
    UiElementBus.Event.SetIsEnabled(self.Properties.MyGuild.PrimaryScreen, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.NoGuildContainer, true)
    self.ScriptedEntityTweener:Play(self.Properties.NoGuildContainer, self.primaryScreenTransitionInTime, {
      opacity = 1,
      delay = self.primaryScreenTransitionOutTime
    })
    self.currentPrimaryScreen = self.Properties.NoGuildContainer
    self.NoGuildContainer:TransitionIn()
  end
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Flyout.IsVisible", false)
  self:HideAllInputs()
end
function GuildMenu:SelectAllGuildsTab()
  if self.currentPrimaryScreen and self.currentPrimaryScreen ~= self.AllGuilds.PrimaryScreen then
    do
      local screen = self.currentPrimaryScreen
      self.ScriptedEntityTweener:Play(self.currentPrimaryScreen, self.primaryScreenTransitionOutTime, {
        opacity = 0,
        onComplete = function()
          UiElementBus.Event.SetIsEnabled(screen, false)
        end
      })
    end
  end
  UiElementBus.Event.SetIsEnabled(self.Properties.AllGuilds.PrimaryScreen, true)
  self.ScriptedEntityTweener:Play(self.Properties.AllGuilds.PrimaryScreen, self.primaryScreenTransitionInTime, {
    opacity = 1,
    delay = self.primaryScreenTransitionOutTime
  })
  self.currentPrimaryScreen = self.AllGuilds.PrimaryScreen
  UiElementBus.Event.SetIsEnabled(self.Properties.AllGuilds.PageNumberContainer, false)
  self:RefreshAllGuilds(true)
  self.tickForTreasury = false
  self:StartTick()
  if self.currentMyGuildContent and self.currentMyGuildContent.SetVisible and type(self.currentMyGuildContent.SetVisible) == "function" then
    self.currentMyGuildContent:SetVisible(false)
  end
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Flyout.IsVisible", false)
  self:HideAllInputs()
end
function GuildMenu:CheckGuildValidity()
  local isValidGuild = self.guildId and self.guildId:IsValid()
  UiElementBus.Event.SetIsEnabled(self.Properties.MyGuild.PrimaryScreen, isValidGuild)
  UiElementBus.Event.SetIsEnabled(self.Properties.NoGuildContainer, not isValidGuild)
  self.isInValidGuild = isValidGuild
end
function GuildMenu:OnExit()
  LyShineManagerBus.Broadcast.ExitState(1967160747)
end
function GuildMenu:StartTick()
  if not self.tickHandler then
    self.tickHandler = self:BusConnect(DynamicBus.UITickBus)
  end
end
function GuildMenu:StopTick()
  if not self.tickForTreasury and not self.tickForNotifications and self.tickHandler then
    self:BusDisconnect(self.tickHandler)
    self.tickHandler = nil
  end
end
function GuildMenu:CheckForTickingNotifications()
  local numTicking = 0
  for _, waring in pairs(self.scoutingPhaseEndWarnings) do
    numTicking = numTicking + 1
  end
  if numTicking == 0 then
    self.tickForNotifications = false
    self:StopTick()
  end
end
function GuildMenu:OnTick(delta, timePoint)
  if self.tickForNotifications then
    local tickingNotificationRemoved = false
    if not self.warningsToRemove then
      self.warningsToRemove = {}
    else
      ClearTable(self.warningsToRemove)
    end
    for k, warning in pairs(self.scoutingPhaseEndWarnings) do
      local now = LocalPlayerComponentRequestBus.Broadcast.GetCurrentSyncedWallClockTime()
      local phaseTimeRemainingSeconds = warning.phaseEndTime:Subtract(now):ToSeconds()
      if phaseTimeRemainingSeconds <= self.SCOUTING_PHASE_WARNING_TIME then
        local warDetails = WarDataClientRequestBus.Broadcast.GetWarDetails(warning.warId)
        local nextPhase = warDetails:GetNextPhase()
        local nextPhaseText = dominionCommon:GetWarPhaseText(nextPhase)
        local notificationData = NotificationData()
        notificationData.type = "WarMultiple"
        local timeText = self.timeHelpers:ConvertSecondsToHrsMinSecString(phaseTimeRemainingSeconds, false)
        notificationData.text = LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement("@ui_warnotification_scouting_phase_warning", timeText)
        notificationData.title = LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement("@ui_warnotification_phase_soon_title", nextPhaseText)
        notificationData.maximumDuration = 7
        UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
        table.insert(self.warningsToRemove, k)
      end
    end
    for i, k in ipairs(self.warningsToRemove) do
      tickingNotificationRemoved = true
      self.scoutingPhaseEndWarnings[k] = nil
    end
    if tickingNotificationRemoved then
      self:CheckForTickingNotifications()
    end
  end
  if self.tickForTreasury then
    self.treasuryTimer = self.treasuryTimer + delta
    if self.treasuryTimer >= self.treasuryTimerTick then
      self.treasuryTimer = self.treasuryTimer - self.treasuryTimerTick
      self.MyGuild.TreasuryWindow.Content:UpdateTreasuryData()
    end
  end
end
function GuildMenu:OnMemberCountChanged(numMembers)
  if self.numMembers == numMembers then
    return
  end
  self.numMembers = numMembers
  self.secondaryTabs.rosterTab:SetIconValue(numMembers)
end
function GuildMenu:UpdateMembersOnlineCount()
  local numOnlineMembers = GuildsComponentBus.Broadcast.GetNumOnlineGuildMembers()
  if self.numOnlineMembers == numOnlineMembers then
    return
  end
  self.numOnlineMembers = numOnlineMembers
  local onlineString = LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement("@ui_guildmembersonline", tostring(numOnlineMembers))
  self.secondaryTabs.rosterTab:SetSecondaryText(onlineString)
end
function GuildMenu:OnCryAction(actionName)
  local isWarDeclarationPopupOpen = self.dataLayer:IsScreenOpen("WarDeclarationPopup")
  if not isWarDeclarationPopupOpen then
    LyShineManagerBus.Broadcast.ToggleState(1967160747)
  end
end
function GuildMenu:OnPopupResult(result, eventId)
  if eventId == self.onLeavePopupEventId and result == ePopupResult_Yes then
    GuildsComponentBus.Broadcast.RequestLeaveGuild()
  elseif eventId == self.onForcedRenamePopupEventId and result == ePopupResult_Yes then
    self:ShowCompanyRename()
  end
end
function GuildMenu:OnLocalGuildOwnershipChanged()
  self.audioHelper:PlaySound(self.audioHelper.Guild_OwnershipChanged)
end
function GuildMenu:GetGuildDetailedDataFailure(reason)
  if reason == eSocialRequestFailureReasonThrottled then
    Log("ERR - GuildMenu:OnShowWarNotification: GuildData request throttled")
  elseif reason == eSocialRequestFailureReasonTimeout then
    Log("ERR - GuildMenu:OnShowWarNotification: GuildData request timed out")
  end
end
function GuildMenu:OnShowWarNotification(warDetails)
  local myRaidId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Raid.Id")
  if myRaidId and warDetails:IsRaidInWar(myRaidId) then
    return
  end
  self.guildId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Guild.Id")
  local defenderGuildId = warDetails:GetDefenderGuildId()
  local warEndTime = warDetails:GetWarEndTime()
  local function successCallback(self, result)
    local guildData
    if 0 < #result then
      guildData = type(result[1]) == "table" and result[1].guildData or result[1]
    else
      Log("ERR - GuildMenu:OnShowWarNotification: GuildData request returned with no data")
      return
    end
    if guildData and guildData:IsValid() then
      local guildNameText = string.format("<font color=\"#%2x%2x%2x\">%s</font>", self.UIStyle.COLOR_RED.r * 255, self.UIStyle.COLOR_RED.g * 255, self.UIStyle.COLOR_RED.b * 255, guildData.guildName)
      local now = LocalPlayerComponentRequestBus.Broadcast.GetCurrentSyncedWallClockTime()
      local warTimeRemaining = warEndTime:Subtract(now):ToSeconds()
      local warTimeRemainingText = string.format("<font color=\"#%2x%2x%2x\">%s</font>", self.UIStyle.COLOR_TAN_LIGHT.r * 255, self.UIStyle.COLOR_TAN_LIGHT.g * 255, self.UIStyle.COLOR_TAN_LIGHT.b * 255, self.timeHelpers:ConvertToShorthandString(warTimeRemaining, false))
      local keys = vector_basic_string_char_char_traits_char()
      keys:push_back("guildName")
      keys:push_back("timeRemaining")
      local values = vector_basic_string_char_char_traits_char()
      values:push_back(guildNameText)
      values:push_back(warTimeRemainingText)
      local message = LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacements("@ui_warnotification_message_single", keys, values)
      local isDefending = defenderGuildId == self.guildId
      local notificationData = NotificationData()
      notificationData.type = "WarSingle"
      notificationData.text = message
      notificationData.title = "@ui_warnotification_title"
      notificationData.guildCrest = guildData.crestData
      notificationData.hasChoice = true
      notificationData.acceptTextOverride = "@ui_warnotification_viewdetail"
      notificationData.declineTextOverride = "@ui_warnotification_dismiss"
      notificationData.contextId = self.entityId
      notificationData.callbackName = "OnWarNotificationChoice"
      UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
    end
  end
  local attackingGuildId = warDetails:GetAttackerGuildId()
  local otherGuildId = self.guildId == attackingGuildId and warDetails:GetDefenderGuildId() or attackingGuildId
  self.socialDataHandler:GetGuildDetailedData_ServerCall(self, successCallback, self.GetGuildDetailedDataFailure, otherGuildId)
end
function GuildMenu:OnShowMultipleWarsNotification(numWars, isDefending)
  local numWarsText = string.format("<font color=\"#%2x%2x%2x\">%d</font>", self.UIStyle.COLOR_RED.r * 255, self.UIStyle.COLOR_RED.g * 255, self.UIStyle.COLOR_RED.b * 255, numWars)
  local message = LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement("@ui_warnotification_message_multiple", numWarsText)
  local notificationData = NotificationData()
  notificationData.type = "WarMultiple"
  notificationData.hasChoice = true
  notificationData.acceptTextOverride = "@ui_warnotification_viewdetail"
  notificationData.declineTextOverride = "@ui_warnotification_dismiss"
  notificationData.contextId = self.entityId
  notificationData.callbackName = "OnWarNotificationChoice"
  notificationData.text = message
  notificationData.title = "@ui_warnotification_title"
  UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
end
function GuildMenu:OnGuildTreasuryWithdrawFunds(amountWithdrawn, response)
  local needsReplacement = true
  local message = ""
  if response == eGuildTreasuryResponse_Success then
    message = "@ui_treasury_notification_withdrawalsuccess"
  elseif response == eGuildTreasuryResponse_DoesNotHavePrivilege then
    message = "@ui_treasury_tooltip_withdrawal_nopermissons"
    needsReplacement = false
  elseif response == eGuildTreasuryResponse_NotEnoughTreasuryFunds then
    message = "@ui_treasury_notification_withdrawalcappedfunds"
  elseif response == eGuildTreasuryResponse_WithdrawCappedByDailyLimit then
    message = "@ui_treasury_notification_withdrawalcappeddailylimit"
  else
    message = "@ui_treasury_notification_error_generic"
    needsReplacement = false
  end
  if needsReplacement then
    message = self:GetTreasuryNotificationReplacementText(message, amountWithdrawn)
  end
  self:ShowMinorNotification(message)
  self.treasuryTimer = 0
  self.MyGuild.TreasuryWindow.Content:UpdateTreasuryData()
  if 0 < amountWithdrawn then
    self.audioHelper:PlaySound(self.audioHelper.Treasury_Withdrawal)
  end
end
function GuildMenu:OnGuildTreasuryDepositFunds(amountDeposited)
  self:ShowMinorNotification("@ui_treasury_notification_depositsuccess", amountDeposited)
  self.treasuryTimer = 0
  self.MyGuild.TreasuryWindow.Content:UpdateTreasuryData()
  if 0 < amountDeposited then
    self.audioHelper:PlaySound(self.audioHelper.Treasury_Deposit)
  end
end
function GuildMenu:OnGuildTreasuryRequestFailed(reason)
  local message
  if reason == eGuildTreasuryResponse_Success then
    message = "@ui_treasury_notification_depositsuccess"
  elseif reason == eGuildTreasuryResponse_DoesNotHavePrivilege then
    message = "@ui_treasury_tooltip_deposit_nopermissons"
  elseif reason == eGuildTreasuryResponse_NotEnoughPlayerFunds then
    message = "@ui_treasury_notification_depositcappedplayerfunds"
  elseif reason == eGuildTreasuryResponse_DepositCappedByTreasuryMax then
    message = "@ui_treasury_notification_depositcappedtreasurymax"
  else
    message = "@ui_treasury_notification_error_generic"
  end
  self:ShowMinorNotification(message)
  self.treasuryTimer = 0
  self.MyGuild.TreasuryWindow.Content:UpdateTreasuryData()
end
function GuildMenu:OnGuildTreasurySetDailyWithdrawalLimit(newWithdrawalLimit, response)
  local needsReplacement = true
  local message = ""
  if response == eGuildTreasuryResponse_Success then
    if 0 < newWithdrawalLimit then
      message = "@ui_treasury_notification_setdailylimitsuccess"
    else
      message = GetLocalizedReplacementText("@ui_treasury_notification_setdailylimitsuccessinfinite", {
        infinityImage = self.infinitySymbolImgText
      })
      needsReplacement = false
    end
    self.audioHelper:PlaySound(self.audioHelper.Treasury_SetDailyLimit)
  elseif response == eGuildTreasuryResponse_DoesNotHavePrivilege then
    message = "@ui_treasury_tooltip_changedailywithdrawallimit_nopermissons"
    needsReplacement = false
  else
    message = "@ui_treasury_notification_error_generic"
    needsReplacement = false
  end
  if needsReplacement then
    message = self:GetTreasuryNotificationReplacementText(message, newWithdrawalLimit)
  end
  self:ShowMinorNotification(message)
  self.treasuryTimer = 0
  self.MyGuild.TreasuryWindow.Content:UpdateTreasuryData()
end
function GuildMenu:OnGuildCreatedFailed(response)
  local creationFailedResponseToText = {
    [eGuildCreationFailureResponse_AlreadyInGuild] = "@ui_guild_creation_failed_alreadyInGuild",
    [eGuildCreationFailureResponse_Throttled] = "@ui_guild_creation_failed_throttled",
    [eGuildCreationFailureResponse_InvalidGuildName] = "@ui_guild_creation_failed_invalidName",
    [eGuildCreationFailureResponse_NotInFaction] = "@ui_guild_creation_failed_notInFaction",
    [eGuildCreationFailureResponse_BadWords] = "@ui_createguildname_use_badword"
  }
  local failureText = creationFailedResponseToText[response]
  failureText = failureText or "@ui_guild_creation_failed"
  self:ShowMinorNotification(failureText)
  DynamicBus.FullScreenSpinner.Broadcast.SetFullscreenSpinnerVisible(false)
end
function GuildMenu:OnSetGuildMemberRankFailedReason(recipientCharacterIdString, reason)
  if reason == eSetGuildMemberRankFailureReasonNoConsul then
    self.socialDataHandler:GetPlayerIdentification_ServerCall(self, self.OnSetGuildMemberRankFailedNoConsul_OnPlayerIdReady, self.OnPlayerIdFailed, recipientCharacterIdString)
  end
end
function GuildMenu:OnSetGuildMemberRankFailedNoConsul_OnPlayerIdReady(result)
  local playerId = self:OnPlayerIdReady(result)
  if playerId then
    local notificationData = NotificationData()
    notificationData.type = "Guild"
    notificationData.title = "@ui_guildsetmemberrankfailednoconsultitle"
    notificationData.guildCrest = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Guild.Crest")
    notificationData.text = GetLocalizedReplacementText("@ui_guildsetmemberrankfailednoconsulmessage", {
      playerName = playerId.playerName
    })
    UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
  end
end
function GuildMenu:GetTreasuryNotificationReplacementText(locTag, amount)
  return GetLocalizedReplacementText(locTag, {
    colorHex = self.currencyColorHexString,
    amount = GetLocalizedCurrency(amount),
    coinImage = self.coinImgText
  })
end
function GuildMenu:ShowMinorNotification(message)
  local notificationData = NotificationData()
  notificationData.type = "Minor"
  notificationData.text = message
  UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
end
function GuildMenu:OnEscapeKeyPressed()
  if not self.MyGuild.TreasuryWindow.Content:ClosePopups() then
    self:OnExit()
  end
end
function GuildMenu:GetNumElements()
  local numElements = 0
  if self.currentPrimaryScreen == self.AllGuilds.PrimaryScreen then
    numElements = #self.otherGuilds
  end
  return numElements
end
function GuildMenu:OnElementBecomingVisible(rootEntity, index)
  local warEndTime, guildData
  if self.otherGuilds[index + 1] then
    guildData = self.otherGuilds[index + 1]
  end
  if guildData then
    local isAtWar = IsAtWarWithGuild(guildData.guildId)
    local warId = WarDataClientRequestBus.Broadcast.GetWarId(guildData.guildId)
    local listItem = self.registrar:GetEntityTable(rootEntity)
    if listItem ~= nil then
      local listItemData = {
        guildId = guildData.guildId,
        guildName = guildData.guildName,
        guildMasterCharacterIdString = guildData.guildMasterCharacterIdString,
        crestData = guildData.crestData,
        numMembers = guildData.numMembers,
        numClaims = guildData.numClaims,
        isLocalPlayerGuild = guildData.guildId == self.guildId,
        isAtWar = isAtWar,
        warEndTime = isAtWar and WarRequestBus.Broadcast.GetWarEndTime(warId) or nil,
        warId = warId
      }
      listItem:SetData(listItemData)
    end
  end
end
function GuildMenu:OnGuildChange(guildId)
  self.guildId = guildId
  self.firstTimeLeaderUpdate = true
  if not self.isVisible then
    return
  end
  self:CheckGuildValidity()
  self:UpdatePermissions()
  self:UpdateMembersOnlineCount()
  self.PrimaryTabbedList:SetSelected(self.primaryTabNameToIndex.MyGuildTab)
  DynamicBus.FullScreenSpinner.Broadcast.SetFullscreenSpinnerVisible(false)
end
function GuildMenu:UpdateGuildName(guildName)
  if self.guildName == guildName then
    return
  end
  self.guildName = guildName
  UiTextBus.Event.SetText(self.Properties.MyGuild.Overview.GuildNameText, self.guildName)
  UiTextInputBus.Event.SetText(self.Properties.MyGuild.Overview.GuildNameInput, self.guildName)
  if self.guildName and self.guildName ~= "" then
    self.primaryTabs.myGuildTab:SetText(self.guildName)
  else
    self.primaryTabs.myGuildTab:SetText("@ui_create_company")
  end
end
function GuildMenu:UpdateGuildLeader(guildLeaderCharacterId)
  if guildLeaderCharacterId == nil then
    return
  end
  if not self.firstTimeLeaderUpdate then
    self.socialDataHandler:GetPlayerIdentification_ServerCall(self, self.UpdateGuildLeaderNotify_OnPlayerIdReady, self.OnPlayerIdFailed, guildLeaderCharacterId)
  else
    self.socialDataHandler:GetPlayerIdentification_ServerCall(self, self.UpdateGuildLeader_OnPlayerIdReady, self.OnPlayerIdFailed, guildLeaderCharacterId)
  end
  self.firstTimeLeaderUpdate = false
end
function GuildMenu:UpdateNumClaims(numClaims)
  if self.numClaims == numClaims then
    return
  end
  self.numClaims = numClaims
  UiTextBus.Event.SetText(self.Properties.MyGuild.Overview.ClaimCount, tostring(numClaims))
  UiTextBus.Event.SetTextWithFlags(self.Properties.MyGuild.Overview.ClaimLabel, numClaims == 1 and "@ui_guildoneclaimowned" or "@ui_guildclaimsowned", eUiTextSet_SetLocalized)
end
function GuildMenu:UpdateFactionName(factionType)
  UiTextBus.Event.SetTextWithFlags(self.Properties.MyGuild.Overview.FactionName, self.factionNames[factionType], eUiTextSet_SetLocalized)
end
function GuildMenu:UpdateCrest(crestData)
  if self.crestData == crestData then
    return
  end
  self.crestData = crestData
  local isValid = crestData:IsValid()
  UiElementBus.Event.SetIsEnabled(self.Properties.MyGuild.Overview.Crest, isValid)
  UiElementBus.Event.SetIsEnabled(self.Properties.MyGuild.Overview.CrestInvalid, not isValid)
  if isValid then
    self.MyGuild.Overview.Crest:SetIcon(crestData)
    self.MyGuild.EditCrest.Content:SetCrestData(crestData)
    self:SetWashColor(crestData.backgroundColor)
    self:SetArcanaColor(crestData.foregroundColor)
  else
    self:SetWashColor(self.UIStyle.COLOR_TAN_LIGHT)
    self:SetArcanaColor(self.UIStyle.COLOR_TAN)
  end
end
function GuildMenu:UpdateIsFull(isFull)
  if self.isGuildFull == isFull then
    return
  end
  self.isGuildFull = isFull
  self:UpdatePermissions()
end
function GuildMenu:SetWashColor(washColor)
  if washColor == self.UIStyle.COLOR_WHITE then
    washColor.a = 0.5
  end
  UiImageBus.Event.SetColor(self.Properties.MyGuild.Overview.Wash, washColor)
end
function GuildMenu:SetArcanaColor(arcanaColor)
  UiImageBus.Event.SetColor(self.Properties.MyGuild.Overview.ArcanaBg, arcanaColor)
  UiImageBus.Event.SetColor(self.Properties.MyGuild.Overview.ArcanaExtras, arcanaColor)
  UiImageBus.Event.SetColor(self.Properties.MyGuild.Overview.ArcanaRing1, arcanaColor)
  UiImageBus.Event.SetColor(self.Properties.MyGuild.Overview.ArcanaRing2, arcanaColor)
  UiImageBus.Event.SetColor(self.Properties.MyGuild.Overview.ArcanaRing3, arcanaColor)
end
function GuildMenu:UpdateMessageOfTheDay(newMessageOfTheDay)
  if self.guildMessageOfTheDay == newMessageOfTheDay then
    return
  end
  self.guildMessageOfTheDay = newMessageOfTheDay
  self:FilterMessageOfTheDay(self.motdProfanityFilter)
end
function GuildMenu:FilterMessageOfTheDay(filterSetting)
  self.motdProfanityFilter = filterSetting
  local motd = self.guildMessageOfTheDay
  local isProfanityFilterEnabled = ConfigProviderEventBus.Broadcast.GetBool("javelin.enable-chat-profanity-filter")
  if isProfanityFilterEnabled and self.motdProfanityFilter then
    motd = ProfanityFilterRequestBus.Broadcast.ProcessText(self.guildMessageOfTheDay)
  end
  UiTextBus.Event.SetText(self.Properties.MyGuild.Overview.MessageOfTheDayText, motd)
  UiTextInputBus.Event.SetText(self.Properties.MyGuild.Overview.MessageOfTheDayInput, motd)
end
function GuildMenu:UpdateGuildWarCount(numGuildWars)
  if self.numGuildWars == numGuildWars then
    return
  end
  self.numGuildWars = numGuildWars
  self.secondaryTabs.warsTab:SetIconValue(numGuildWars)
  self.secondaryTabs.warsTab:SetWarning(0 < numGuildWars)
  self.MyGuild.Wars.Content:ShowNoWarsMessage(numGuildWars == 0)
end
function GuildMenu:UpdateCurrency(currencyAmount)
  if self.currencyAmount == currencyAmount then
    return
  end
  self.currencyAmount = currencyAmount
  self.AllGuilds.WalletCurrencyDisplay:SetCurrencyAmount(currencyAmount)
  if self.currentPrimaryScreen == self.AllGuilds.PrimaryScreen then
    local listItems = UiElementBus.Event.GetChildren(self.Properties.AllGuilds.ListItemBoxContent)
    for i = 1, #listItems do
      if UiElementBus.Event.IsEnabled(listItems[i]) then
        local otherGuildListItem = self.registrar:GetEntityTable(listItems[i])
        otherGuildListItem:OnUpdateCurrency(currencyAmount)
      end
    end
  end
end
function GuildMenu:UpdatePermissions()
  self.isGuildMaster = GuildsComponentBus.Broadcast.IsGuildMaster()
  UiElementBus.Event.SetIsEnabled(self.Properties.MyGuild.Overview.EditCrestButton, self.isGuildMaster)
  UiElementBus.Event.SetIsEnabled(self.Properties.MyGuild.Overview.EditGuildNameButton, self.isGuildMaster)
  self.hasMotdEditPrivilege = GuildsComponentBus.Broadcast.HasPrivilege(eGuildPrivilegeId_MOTD_Set)
  UiElementBus.Event.SetIsEnabled(self.Properties.MyGuild.Overview.EditMessageOfTheDayButton, self.hasMotdEditPrivilege)
  self.hasMemberInvitePrivilege = GuildsComponentBus.Broadcast.HasPrivilege(eGuildPrivilegeId_Member_Invite)
  self.MyGuild.LeaveGuildButton:SetEnabled(true)
  self.MyGuild.LeaveGuildButton:SetTooltip(nil)
  self.MyGuild.LeaveGuildButton:SetTextColor(self.UIStyle.COLOR_WHITE)
  local isValidGuild = self.guildId and self.guildId:IsValid()
  local canInvite = isValidGuild and self.hasMemberInvitePrivilege and not self.isGuildFull
  if canInvite then
    self.MyGuild.InviteGuildButton:SetTooltip(nil)
    self.MyGuild.InviteGuildButton:SetEnabled(true)
  elseif not isValidGuild then
    self.MyGuild.InviteGuildButton:SetTooltip("@ui_cantinvite_noguild")
    self.MyGuild.InviteGuildButton:SetEnabled(false)
  elseif not self.hasMemberInvitePrivilege then
    self.MyGuild.InviteGuildButton:SetTooltip("@ui_cantinvite_lackpermission")
    self.MyGuild.InviteGuildButton:SetEnabled(false)
  elseif self.isGuildFull then
    self.MyGuild.InviteGuildButton:SetTooltip("@ui_cantinvite_guildfull")
    self.MyGuild.InviteGuildButton:SetEnabled(false)
  end
end
function GuildMenu:ShowGuildNameInput(show)
  if show == self.isGuildNameInputShowing or self.isGuildNameInputTransitioning then
    return
  end
  self.isGuildNameInputTransitioning = true
  self.isGuildNameInputShowing = show
  local animTime = 0.15
  local buttonOffset = 54
  local buttonY = 64
  local buttonStagger = 0.05
  if show then
    UiTextInputBus.Event.SetText(self.Properties.MyGuild.Overview.GuildNameInput, self.guildName)
    UiElementBus.Event.SetIsEnabled(self.Properties.MyGuild.Overview.GuildNameInput, true)
    self.ScriptedEntityTweener:Play(self.Properties.MyGuild.Overview.GuildNameInput, animTime, {opacity = 0}, {opacity = 1})
    self.ScriptedEntityTweener:Play(self.Properties.MyGuild.Overview.SubmitGuildNameButton, animTime, {y = buttonOffset}, {y = buttonY})
    self.ScriptedEntityTweener:Play(self.Properties.MyGuild.Overview.CancelGuildNameButton, animTime, {y = buttonOffset}, {delay = buttonStagger, y = buttonY})
    SetActionmapsForTextInput(self.canvasId, true)
    self.ScriptedEntityTweener:Play(self.Properties.MyGuild.Overview.EditGuildNameButton, animTime, {
      opacity = 0,
      y = buttonOffset,
      onComplete = function()
        UiElementBus.Event.SetIsEnabled(self.Properties.MyGuild.Overview.EditGuildNameButton, false)
        UiElementBus.Event.SetIsEnabled(self.Properties.MyGuild.Overview.GuildNameText, false)
        self.isGuildNameInputTransitioning = false
        UiCanvasBus.Event.SetActiveInteractable(self.canvasId, self.Properties.MyGuild.Overview.GuildNameInput, true)
        UiTextInputBus.Event.BeginEdit(self.Properties.MyGuild.Overview.GuildNameInput)
      end
    })
  else
    UiElementBus.Event.SetIsEnabled(self.Properties.MyGuild.Overview.GuildNameText, true)
    UiElementBus.Event.SetIsEnabled(self.Properties.MyGuild.Overview.EditGuildNameButton, true)
    self.ScriptedEntityTweener:Play(self.Properties.MyGuild.Overview.EditGuildNameButton, animTime, {opacity = 0, y = buttonOffset}, {
      delay = buttonStagger,
      opacity = 1,
      y = buttonY
    })
    self.ScriptedEntityTweener:Play(self.Properties.MyGuild.Overview.GuildNameInput, animTime, {opacity = 1}, {
      opacity = 0,
      onComplete = function()
        UiElementBus.Event.SetIsEnabled(self.Properties.MyGuild.Overview.GuildNameInput, false)
        self.isGuildNameInputTransitioning = false
      end
    })
    self.ScriptedEntityTweener:Play(self.Properties.MyGuild.Overview.SubmitGuildNameButton, animTime, {y = buttonY}, {y = buttonOffset})
    self.ScriptedEntityTweener:Play(self.Properties.MyGuild.Overview.CancelGuildNameButton, animTime, {y = buttonY}, {y = buttonOffset})
  end
end
function GuildMenu:ShowGuildMessageOfTheDayInput(show, resetInput)
  if show == self.isGuildMessageOfTheDayInputShowing or self.isGuildMessageOfTheDayInputTransitioning then
    return
  end
  self.isGuildMessageOfTheDayInputTransitioning = true
  self.isGuildMessageOfTheDayInputShowing = show
  local animTime = 0.15
  local buttonOffset = 106
  local buttonY = 94
  local buttonStagger = 0.05
  if show then
    UiElementBus.Event.SetIsEnabled(self.Properties.MyGuild.Overview.MessageOfTheDayInputContainer, true)
    self.ScriptedEntityTweener:Play(self.Properties.MyGuild.Overview.MessageOfTheDayInputContainer, animTime, {opacity = 0}, {opacity = 1})
    self.ScriptedEntityTweener:Play(self.Properties.MyGuild.Overview.SubmitMessageOfTheDayButton, animTime, {y = buttonOffset}, {y = buttonY})
    self.ScriptedEntityTweener:Play(self.Properties.MyGuild.Overview.CancelMessageOfTheDayButton, animTime, {y = buttonOffset}, {delay = buttonStagger, y = buttonY})
    self.ScriptedEntityTweener:Play(self.Properties.MyGuild.Overview.EditMessageOfTheDayButton, animTime, {
      opacity = 0,
      y = buttonOffset,
      onComplete = function()
        UiElementBus.Event.SetIsEnabled(self.Properties.MyGuild.Overview.EditMessageOfTheDayButton, false)
        UiElementBus.Event.SetIsEnabled(self.Properties.MyGuild.Overview.MessageOfTheDayText, false)
        self.isGuildMessageOfTheDayInputTransitioning = false
        UiCanvasBus.Event.SetActiveInteractable(self.canvasId, self.Properties.MyGuild.Overview.MessageOfTheDayInput, true)
        UiTextInputBus.Event.BeginEdit(self.Properties.MyGuild.Overview.MessageOfTheDayInput)
      end
    })
  else
    UiElementBus.Event.SetIsEnabled(self.Properties.MyGuild.Overview.MessageOfTheDayText, true)
    UiElementBus.Event.SetIsEnabled(self.Properties.MyGuild.Overview.EditMessageOfTheDayButton, true)
    self.ScriptedEntityTweener:Play(self.Properties.MyGuild.Overview.EditMessageOfTheDayButton, animTime, {opacity = 0, y = buttonOffset}, {
      delay = buttonStagger,
      opacity = 1,
      y = buttonY
    })
    self.ScriptedEntityTweener:Play(self.Properties.MyGuild.Overview.MessageOfTheDayInputContainer, animTime, {opacity = 1}, {
      opacity = 0,
      onComplete = function()
        UiElementBus.Event.SetIsEnabled(self.Properties.MyGuild.Overview.MessageOfTheDayInputContainer, false)
        self.isGuildMessageOfTheDayInputTransitioning = false
        if resetInput then
          self:FilterMessageOfTheDay(self.motdProfanityFilter)
        end
      end
    })
    self.ScriptedEntityTweener:Play(self.Properties.MyGuild.Overview.SubmitMessageOfTheDayButton, animTime, {y = buttonY}, {y = buttonOffset})
    self.ScriptedEntityTweener:Play(self.Properties.MyGuild.Overview.CancelMessageOfTheDayButton, animTime, {y = buttonY}, {y = buttonOffset})
  end
end
function GuildMenu:HideAllInputs()
  self:ShowGuildNameInput(false)
  local resetInput = true
  self:ShowGuildMessageOfTheDayInput(false, resetInput)
end
function GuildMenu:OnClickRefreshPage()
  self:RefreshAllGuilds()
end
function GuildMenu:RefreshAllGuilds(resetToFirstPage)
  UiInteractableBus.Event.SetIsHandlingEvents(self.Properties.AllGuilds.PrevPageButton, false)
  UiInteractableBus.Event.SetIsHandlingEvents(self.Properties.AllGuilds.NextPageButton, false)
  UiInteractableBus.Event.SetIsHandlingEvents(self.Properties.AllGuilds.RefreshButton, false)
  if resetToFirstPage then
    self.pageKeys = {
      [0] = ""
    }
    self.currentPage = 1
    self.destinationPage = self.currentPage
  end
  local newPageKey = self.pageKeys[self.destinationPage - 1]
  local isSortingByName = self.sortOption == "name"
  local isSortingByClaims = self.sortOption == "claims"
  if isSortingByName then
    self.socialDataHandler:RequestListGuildsByName_ServerCall(self, self.AllGuildsReceived, self.AllGuildsRequestFailed, self.sortOrder, self.guildsPerPage, newPageKey)
  elseif isSortingByClaims then
    self.socialDataHandler:RequestListGuildsByClaims_ServerCall(self, self.AllGuildsReceived, self.AllGuildsRequestFailed, self.sortOrder, self.guildsPerPage, newPageKey)
  else
    self.socialDataHandler:RequestListGuildsByMembers_ServerCall(self, self.AllGuildsReceived, self.AllGuildsRequestFailed, self.sortOrder, self.guildsPerPage, newPageKey)
  end
  self:ShowAllGuildsLoadingSpinner(true)
end
function GuildMenu:GetGuildsInWorldText()
  return GetLocalizedReplacementText("@ui_guildsinworld", {
    number = self.numGuilds or 0,
    worldName = LyShineManagerBus.Broadcast.GetWorldName()
  })
end
function GuildMenu:GetOtherGuildsText()
  return LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement("@ui_otherguildssubtitle", LyShineManagerBus.Broadcast.GetWorldName())
end
function GuildMenu:AllGuildsReceived(results, pageKey)
  self.pageKeys[self.destinationPage] = pageKey
  self.currentPage = self.destinationPage
  self.otherGuilds = {}
  if 0 < #results then
    for i = 1, #results do
      local guildData = {
        guildId = results[i].guildId,
        guildName = results[i].guildName,
        guildMasterCharacterIdString = results[i].guildMasterCharacterIdString,
        crestData = results[i].crestData,
        numMembers = results[i].numMembers,
        numClaims = results[i].numClaims,
        index = i
      }
      table.insert(self.otherGuilds, guildData)
    end
  end
  self:UpdatePageContainer()
  UiDynamicScrollBoxBus.Event.RefreshContent(self.Properties.AllGuilds.ListItemBox)
  self:ShowAllGuildsLoadingSpinner(false)
end
function GuildMenu:AllGuildsRequestFailed(reason)
  if reason == eSocialRequestFailureReasonThrottled then
    Log("ERR - GuildMenu:AllGuildsRequestFailed: Throttled")
  elseif reason == eSocialRequestFailureReasonTimeout then
    Log("ERR - GuildMenu:AllGuildsRequestFailed: Timed Out")
  end
  if self.destinationPage then
    self.currentPage = self.destinationPage
  end
  self:UpdatePageContainer()
  self:ShowAllGuildsLoadingSpinner(false)
end
function GuildMenu:OnPlayerIdFailed(reason)
  if reason == eSocialRequestFailureReasonThrottled then
    Log("ERR - GuildMenu:OnPlayerIdFailed: Throttled.")
  elseif reason == eSocialRequestFailureReasonTimeout then
    Log("ERR - GuildMenu:OnPlayerIdFailed: Timed Out.")
  end
end
function GuildMenu:OnPlayerIdReady(result)
  local playerId
  if 0 < #result then
    playerId = result[1].playerId
  else
    Log("ERR - GuildMenu:OnPlayerIdReady: Player not found.")
    return
  end
  return playerId
end
function GuildMenu:UpdateGuildLeader_OnPlayerIdReady(result)
  local playerId = self:OnPlayerIdReady(result)
  if playerId then
    UiTextBus.Event.SetText(self.Properties.MyGuild.Overview.GuildLeader, playerId.playerName)
  end
end
function GuildMenu:UpdateGuildLeaderNotify_OnPlayerIdReady(result)
  local playerId = self:OnPlayerIdReady(result)
  if playerId then
    UiTextBus.Event.SetText(self.Properties.MyGuild.Overview.GuildLeader, playerId.playerName)
    local notificationData = NotificationData()
    notificationData.contextId = self.entityId
    notificationData.type = "Guild"
    notificationData.title = "@ui_guildownershipchangetitle"
    notificationData.guildCrest = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Guild.Crest")
    notificationData.text = GetLocalizedReplacementText("@ui_guildownershipchangemessage", {
      playerName = playerId.playerName
    })
    UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
  end
end
function GuildMenu:RefreshWars()
  local numWars = WarDataClientRequestBus.Broadcast.GetNumWars()
  self.secondaryTabs.warsTab:SetIconValue(numWars)
  self.secondaryTabs.warsTab:SetWarning(0 < numWars)
  if self.currentMyGuildScreen ~= self.MyGuild.Wars.Screen then
    return
  end
  self.guildWars = {}
  local warIds = WarDataClientRequestBus.Broadcast.GetWarIds()
  local guildIds = vector_GuildId()
  local lookupOwnGuild = false
  if warIds then
    for i = 1, #warIds do
      local warDetails = WarDataClientRequestBus.Broadcast.GetWarDetails(warIds[i])
      if warDetails:IsValid() and warDetails:IsGuildInWar(self.guildId) then
        local territoryId = warDetails:GetTerritoryId()
        local territoryName = TerritoryDataHandler:GetTerritoryNameFromTerritoryId(territoryId)
        local siegeStartTime = warDetails:GetConquestStartTime():Subtract(WallClockTimePoint()):ToSecondsRoundedUp()
        local data = {
          warId = warIds[i],
          territoryId = territoryId,
          territoryName = territoryName,
          warEndTime = WarRequestBus.Broadcast.GetWarEndTime(warIds[i]),
          siegeStartTime = siegeStartTime,
          isInvasion = warDetails:IsInvasion()
        }
        if not warDetails:IsAttackingGuild(self.guildId) then
          data.siegeWindow = self.siegeWindow
        end
        if not warDetails:IsInvasion() then
          local otherGuildId = warDetails:GetOtherGuild(self.guildId)
          data.guildId = otherGuildId
          guildIds:push_back(otherGuildId)
        else
          data.guildId = self.guildId
          lookupOwnGuild = true
        end
        table.insert(self.guildWars, data)
      end
    end
  end
  self.MyGuild.Wars.Content:ShowNoWarsMessage(numWars == 0)
  if numWars == 0 then
    return
  end
  if lookupOwnGuild then
    guildIds:push_back(self.guildId)
  end
  self.socialDataHandler:RequestGetGuilds_ServerCall(self, self.GuildWarDataReceived, self.GuildWarDataRequestFailed, guildIds)
end
function GuildMenu:GuildWarDataReceived(results)
  local dataChanged = false
  for i = 1, #results do
    local guildData = results[i]
    for _, data in ipairs(self.guildWars) do
      if data.guildId and data.guildId == guildData.guildId then
        data.guildName = guildData.guildName
        data.guildMasterCharacterIdString = guildData.guildMasterCharacterIdString
        data.crestData = guildData.crestData
        data.numMembers = guildData.numMembers
        data.numClaims = guildData.numClaims
        data.faction = guildData.faction
        local warDetails = WarDataClientRequestBus.Broadcast.GetWarDetails(data.warId)
        if not warDetails:IsAttackingGuild(data.guildId) then
          data.siegeWindow = guildData.siegeWindow
        end
        data.isInvasion = warDetails:IsInvasion()
        dataChanged = true
      end
    end
  end
  if dataChanged then
    self:SortGuildWars()
  end
  self.MyGuild.Wars.Content:SetWarData(self.guildWars)
end
function GuildMenu:GuildWarDataRequestFailed(reason)
  if reason == eSocialRequestFailureReasonThrottled then
    Log("ERR - GuildMenu:GuildWarDataRequestFailed: Throttled")
  elseif reason == eSocialRequestFailureReasonTimeout then
    Log("ERR - GuildMenu:GuildWarDataRequestFailed: Timed Out")
  end
end
function GuildMenu:SortGuildWars()
  if not self.compare then
    function self.compare(first, second)
      if self.sortOrder == eSocialOrderDescending and first.numClaims ~= second.numClaims then
        return first.numClaims > second.numClaims
      elseif self.sortOrder == eSocialOrderDescending and first.numMembers ~= second.numMembers then
        return first.numMembers > second.numMembers
      end
      return string.lower(first.guildName) < string.lower(second.guildName)
    end
  end
  table.sort(self.guildWars, self.compare)
end
function GuildMenu:OnGuildWarAdded(warId, guildId)
  if guildId and guildId:IsValid() then
    local numWars = WarDataClientRequestBus.Broadcast.GetNumWars()
    self.secondaryTabs.warsTab:SetIconValue(numWars)
    self.secondaryTabs.warsTab:SetWarning(0 < numWars)
    if self.currentMyGuildScreen == self.MyGuild.Wars.Screen then
      for i = 1, #self.guildWars do
        if self.guildWars[i].guildId == guildId then
          self.guildWars[i].warId = warId
          self.guildWars[i].warEndTime = WarRequestBus.Broadcast.GetWarEndTime(warId)
          self.MyGuild.Wars.Content:SetWarData(self.guildWars)
          return
        end
      end
      table.insert(self.guildWars, {guildId = guildId, warId = warId})
      local guildIds = vector_GuildId()
      guildIds:push_back(guildId)
      self.socialDataHandler:RequestGetGuilds_ServerCall(self, self.GuildWarDataReceived, self.AllGuildsRequestFailed, guildIds)
    end
    if self.currentPrimaryScreen == self.AllGuilds.PrimaryScreen then
      self:RefreshAllGuilds()
    end
  end
end
function GuildMenu:OnGuildWarRemoved(warId)
  if not warId then
    return
  end
  local numWars = WarDataClientRequestBus.Broadcast.GetNumWars()
  self.secondaryTabs.warsTab:SetIconValue(numWars)
  self.secondaryTabs.warsTab:SetWarning(0 < numWars)
  if self.currentMyGuildScreen == self.MyGuild.Wars.Screen then
    for i = 1, #self.guildWars do
      if self.guildWars[i].warId == warId then
        table.remove(self.guildWars, i)
        self.MyGuild.Wars.Content:SetWarData(self.guildWars)
        LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Flyout.IsVisible", false)
        break
      end
    end
  end
  if self.currentPrimaryScreen == self.AllGuilds.PrimaryScreen then
    self:RefreshAllGuilds()
  end
end
function GuildMenu:OnGuildWarUpdated(warId)
  if warId then
    local warDetails = WarDataClientRequestBus.Broadcast.GetWarDetails(warId)
    local playerGuildId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Guild.Id")
    if warDetails:IsWarActive() then
      if not playerGuildId or not warDetails:IsGuildInWar(playerGuildId) then
        return
      end
      local guildId = warDetails:GetOtherGuild(playerGuildId)
      if not guildId:IsValid() then
        return
      end
      self:OnGuildWarAdded(warId, guildId)
    else
      self:OnGuildWarRemoved(warId)
    end
    local warPhase = warDetails:GetWarPhase()
    local phaseEndTime = warDetails:GetPhaseEndTime()
    local now = LocalPlayerComponentRequestBus.Broadcast.GetCurrentSyncedWallClockTime()
    local phaseTimeRemainingSeconds = phaseEndTime:Subtract(now):ToSeconds()
    if warPhase == eWarPhase_PreWar and phaseTimeRemainingSeconds > self.SCOUTING_PHASE_WARNING_TIME then
      local warning = {warId = warId, phaseEndTime = phaseEndTime}
      self.scoutingPhaseEndWarnings[warId] = warning
      self.tickForNotifications = true
      self:StartTick()
    end
  end
end
function GuildMenu:OnWarNotificationChoice(notificationId, isAccepted)
  if isAccepted then
    self:ShowWarsTab()
  end
end
function GuildMenu:RefreshSiegeWindowTabSecondaryText()
  if self.siegeWindow then
    local siegeWindowText = dominionCommon:GetSiegeWindowText(self.siegeWindow, self.siegeDuration)
    self.secondaryTabs.siegeTab:SetSecondaryText(siegeWindowText)
  end
end
function GuildMenu:ShowWarsTab()
  self.showingWarsTabFromNotification = true
  LyShineManagerBus.Broadcast.SetState(1967160747)
  UiElementBus.Event.SetIsEnabled(self.Properties.MyGuild.Overview.Screen, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.MyGuild.EditCrest.Screen, false)
end
function GuildMenu:ShowCompanyRename()
  self.showingCompanyRenameFromNotification = true
  LyShineManagerBus.Broadcast.SetState(1967160747)
end
function GuildMenu:UpdatePageContainer()
  if self.currentPrimaryScreen == self.AllGuilds.PrimaryScreen then
    if self.currentPage > 1 then
      UiInteractableBus.Event.SetIsHandlingEvents(self.Properties.AllGuilds.PrevPageButton, true)
      UiImageBus.Event.SetColor(self.Properties.AllGuilds.PrevPageButton, self.UIStyle.COLOR_TAN)
    else
      UiInteractableBus.Event.SetIsHandlingEvents(self.Properties.AllGuilds.PrevPageButton, false)
      UiImageBus.Event.SetColor(self.Properties.AllGuilds.PrevPageButton, self.UIStyle.COLOR_TAN_DARK)
    end
    if self.pageKeys[self.currentPage] == "" then
      UiInteractableBus.Event.SetIsHandlingEvents(self.Properties.AllGuilds.NextPageButton, false)
      UiImageBus.Event.SetColor(self.Properties.AllGuilds.NextPageButton, self.UIStyle.COLOR_TAN_DARK)
    else
      UiInteractableBus.Event.SetIsHandlingEvents(self.Properties.AllGuilds.NextPageButton, true)
      UiImageBus.Event.SetColor(self.Properties.AllGuilds.NextPageButton, self.UIStyle.COLOR_TAN)
    end
    UiInteractableBus.Event.SetIsHandlingEvents(self.Properties.AllGuilds.RefreshButton, true)
    local keyValueVectors = TableToKeyValueVectors({
      number = self.currentPage
    })
    local pageNumberString = LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacements("@ui_otherguilds_pagenumber", keyValueVectors.keys, keyValueVectors.values)
    UiTextBus.Event.SetText(self.Properties.AllGuilds.PageNumberText, pageNumberString)
    UiElementBus.Event.SetIsEnabled(self.Properties.AllGuilds.PageNumberContainer, true)
    UiScrollBoxBus.Event.SetScrollOffset(self.Properties.AllGuilds.ListItemBox, Vector2(0, 0))
  else
    UiElementBus.Event.SetIsEnabled(self.Properties.AllGuilds.PageNumberContainer, false)
  end
end
function GuildMenu:OnPreviousPage()
  if self.currentPage <= 1 then
    self.currentPage = 1
    self.destinationPage = nil
  else
    self.destinationPage = self.currentPage - 1
  end
  self:RefreshAllGuilds()
end
function GuildMenu:OnNextPage()
  self.destinationPage = self.currentPage + 1
  self:RefreshAllGuilds()
end
function GuildMenu:ClearScreens()
  if self.currentMyGuildScreen then
    do
      local closingScreen = self.currentMyGuildScreen
      self.ScriptedEntityTweener:Play(self.currentMyGuildScreen, self.myGuildScreenTransitionOutTime, {
        opacity = 0,
        onComplete = function()
          UiElementBus.Event.SetIsEnabled(closingScreen, false)
        end
      })
      self.currentMyGuildScreen = nil
    end
  end
  if self.currentMyGuildContent and self.currentMyGuildContent.SetVisible and type(self.currentMyGuildContent.SetVisible) == "function" then
    self.currentMyGuildContent:SetVisible(false)
    self.currentMyGuildContent = nil
  end
  if self.overviewArcanaTimelines then
    for _, timeline in pairs(self.overviewArcanaTimelines) do
      timeline:Stop()
    end
  end
  self:HideAllInputs()
end
function GuildMenu:ShowMyGuildOverview()
  self:ClearScreens()
  UiElementBus.Event.SetIsEnabled(self.Properties.MyGuild.Overview.Screen, true)
  if not self.isEditingCrest then
    self.ScriptedEntityTweener:Play(self.Properties.MyGuild.Overview.Screen, self.myGuildScreenTransitionInTime, {
      opacity = 1,
      delay = self.myGuildScreenTransitionOutTime
    })
  else
    self:HideMyGuildEditCrest()
  end
  self.currentMyGuildScreen = self.MyGuild.Overview.Screen
  if not self.overviewArcanaTimelines then
    self:CreateArcanaTimelines()
  end
  for _, timeline in pairs(self.overviewArcanaTimelines) do
    timeline:Play()
  end
  self.MyGuild.Overview.OverviewDivider:SetVisible(false, 0)
  self.MyGuild.Overview.OverviewDivider:SetVisible(true, 0.8)
end
function GuildMenu:ShowMyGuildEditCrest()
  UiElementBus.Event.SetIsEnabled(self.Properties.MyGuild.EditCrest.Screen, true)
  self.ScriptedEntityTweener:Play(self.Properties.MyGuild.Overview.Screen, self.myGuildScreenTransitionOutTime, {opacity = 0})
  self.ScriptedEntityTweener:Play(self.Properties.MyGuild.EditCrest.Screen, self.myGuildScreenTransitionInTime, {
    opacity = 1,
    delay = self.myGuildScreenTransitionOutTime
  })
  self.isEditingCrest = true
  self.MyGuild.EditCrest.Content:SetScreenVisible(true)
end
function GuildMenu:HideMyGuildEditCrest(saveGuildCrest)
  local editorCrestData = self.MyGuild.EditCrest.Content:GetCrestData()
  if self.crestData ~= editorCrestData and saveGuildCrest then
    GuildsComponentBus.Broadcast.RequestEditGuildIcon(self.MyGuild.EditCrest.Content:GetCrestData())
  end
  self.ScriptedEntityTweener:Play(self.Properties.MyGuild.EditCrest.Screen, self.myGuildScreenTransitionOutTime, {
    opacity = 0,
    onComplete = function()
      UiElementBus.Event.SetIsEnabled(self.Properties.MyGuild.EditCrest.Screen, false)
    end
  })
  self.ScriptedEntityTweener:Play(self.Properties.MyGuild.Overview.Screen, self.myGuildScreenTransitionInTime, {
    opacity = 1,
    delay = self.myGuildScreenTransitionOutTime
  })
  self.isEditingCrest = false
  self.MyGuild.EditCrest.Content:SetScreenVisible(false)
end
function GuildMenu:ShowMyGuildRoster()
  self:ClearScreens()
  UiElementBus.Event.SetIsEnabled(self.Properties.MyGuild.Roster.Screen, true)
  UiElementBus.Event.SetIsEnabled(self.Properties.MyGuild.EditCrest.Screen, false)
  self.ScriptedEntityTweener:Play(self.Properties.MyGuild.Roster.Screen, self.myGuildScreenTransitionInTime, {
    opacity = 1,
    delay = self.myGuildScreenTransitionOutTime
  })
  self.currentMyGuildScreen = self.MyGuild.Roster.Screen
  self.currentMyGuildContent = self.MyGuild.Roster.Content
  self.MyGuild.Roster.Content:SetVisible(true)
end
function GuildMenu:ShowMyGuildWars()
  self:ClearScreens()
  UiElementBus.Event.SetIsEnabled(self.Properties.MyGuild.EditCrest.Screen, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.MyGuild.Wars.Screen, true)
  self.ScriptedEntityTweener:Play(self.Properties.MyGuild.Wars.Screen, self.myGuildScreenTransitionInTime, {
    opacity = 1,
    delay = self.myGuildScreenTransitionOutTime
  })
  self.currentMyGuildScreen = self.MyGuild.Wars.Screen
  self.currentMyGuildContent = self.MyGuild.Wars.Content
  self:RefreshWars()
  self.MyGuild.Wars.Content:SetVisible(true)
end
function GuildMenu:ShowMyGuildRanks()
  self:ClearScreens()
  UiElementBus.Event.SetIsEnabled(self.Properties.MyGuild.EditCrest.Screen, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.MyGuild.Ranks.Screen, true)
  self.ScriptedEntityTweener:Play(self.Properties.MyGuild.Ranks.Screen, self.myGuildScreenTransitionInTime, {
    opacity = 1,
    delay = self.myGuildScreenTransitionOutTime
  })
  self.currentMyGuildScreen = self.MyGuild.Ranks.Screen
  self.currentMyGuildContent = self.MyGuild.Ranks.Content
  self.MyGuild.Ranks.DividerLine:SetVisible(false, 0)
  self.MyGuild.Ranks.DividerLine:SetVisible(true, 2)
end
function GuildMenu:ShowMyGuildSiegeWindow()
  self:ClearScreens()
  UiElementBus.Event.SetIsEnabled(self.Properties.MyGuild.EditCrest.Screen, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.MyGuild.SiegeWindow.Screen, true)
  self.ScriptedEntityTweener:Play(self.Properties.MyGuild.SiegeWindow.Screen, self.myGuildScreenTransitionInTime, {
    opacity = 1,
    delay = self.myGuildScreenTransitionOutTime
  })
  self.currentMyGuildScreen = self.MyGuild.SiegeWindow.Screen
  self.currentMyGuildContent = self.MyGuild.SiegeWindow.Content
  self.MyGuild.SiegeWindow.Content:SetVisible(true)
end
function GuildMenu:ShowMyGuildTreasuryWindow()
  self:ClearScreens()
  UiElementBus.Event.SetIsEnabled(self.Properties.MyGuild.EditCrest.Screen, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.MyGuild.TreasuryWindow.Screen, true)
  self.ScriptedEntityTweener:Play(self.Properties.MyGuild.TreasuryWindow.Screen, self.myGuildScreenTransitionInTime, {
    opacity = 1,
    delay = self.myGuildScreenTransitionOutTime
  })
  self.currentMyGuildScreen = self.MyGuild.TreasuryWindow.Screen
  self.currentMyGuildContent = self.MyGuild.TreasuryWindow.Content
  self.MyGuild.TreasuryWindow.Content:SetVisible(true)
end
function GuildMenu:ShowAllGuildsLoadingSpinner(value)
  UiElementBus.Event.SetIsEnabled(self.Properties.AllGuilds.LoadingSpinnerContainer, value)
  if value then
    if not self.allGuildsLoadingSpinnerTimeline then
      self.allGuildsLoadingSpinnerTimeline = self:CreateInfiniteRotationTimeline(self.AllGuilds.LoadingSpinner, 1)
    end
    self.allGuildsLoadingSpinnerTimeline:Play()
    self.ScriptedEntityTweener:Play(self.Properties.AllGuilds.LoadingSpinnerContainer, 0.3, {opacity = 0}, {
      opacity = self.loadingSpinnerOpacity
    })
  elseif self.allGuildsLoadingSpinnerTimeline then
    self.allGuildsLoadingSpinnerTimeline:Stop()
    self.ScriptedEntityTweener:Set(self.Properties.AllGuilds.LoadingSpinner, {rotation = 0})
  end
end
function GuildMenu:OnPermissionSelect()
  self.audioHelper:PlaySound(self.audioHelper.Guild_PermissionSelect)
end
function GuildMenu:OnClose()
  LyShineManagerBus.Broadcast.ExitState(1967160747)
end
function GuildMenu:OnEditName()
  local textFieldId = self.Properties.MyGuild.Overview.GuildNameInput
  if textFieldId:IsValid() then
    self:ShowGuildNameInput(true)
  end
end
function GuildMenu:OnEditMessageOfTheDay()
  local textFieldId = self.Properties.MyGuild.Overview.MessageOfTheDayInput
  if textFieldId:IsValid() then
    self:ShowGuildMessageOfTheDayInput(true)
  end
end
function GuildMenu:OnSubmitName()
  local textFieldId = self.Properties.MyGuild.Overview.GuildNameInput
  if textFieldId:IsValid() then
    do
      local newName = UiTextInputBus.Event.GetText(textFieldId)
      if newName ~= "" then
        if newName == self.guildName then
          self:ShowGuildNameInput(false)
          return
        end
        if GuildsComponentBus.Broadcast.IsValidGuildName(newName, true) then
          self.socialDataHandler:RequestGuildNameAvailability_ServerCall(self, function(self, name, success)
            if success then
              GuildsComponentBus.Broadcast.RequestEditGuildName(newName)
            else
              self:NotifyEditGuildNameFailed()
            end
          end, function()
            self:NotifyEditGuildNameFailed()
          end, newName)
        end
      end
    end
  end
  self:ShowGuildNameInput(false)
end
function GuildMenu:NotifyEditGuildNameFailed()
  local notificationData = NotificationData()
  notificationData.type = "Minor"
  notificationData.text = "@ui_create_company_invalid_name_taken"
  UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
end
function GuildMenu:OnSubmitMessageOfTheDay()
  local textFieldId = self.Properties.MyGuild.Overview.MessageOfTheDayInput
  if textFieldId:IsValid() then
    local newMessageOfTheDay = UiTextInputBus.Event.GetText(textFieldId)
    if self.guildMessageOfTheDay == newMessageOfTheDay then
      self:ShowGuildMessageOfTheDayInput(false)
      return
    end
    local clientAccepted = GuildsComponentBus.Broadcast.RequestEditGuildMOTD(newMessageOfTheDay)
    if clientAccepted then
      self:ShowGuildMessageOfTheDayInput(false)
    end
  end
end
function GuildMenu:OnCancelEditName()
  self:ShowGuildNameInput(false)
end
function GuildMenu:OnCancelEditMessageOfTheDay()
  local resetInput = true
  self:ShowGuildMessageOfTheDayInput(false, resetInput)
end
function GuildMenu:OnForcedRename(isForcedRename)
  if isForcedRename then
    PopupWrapper:RequestPopup(ePopupButtons_YesNo, "@ui_forcedrename", "@ui_forcedrename_description", self.onForcedRenamePopupEventId, self, self.OnPopupResult)
  end
end
function GuildMenu:OnContextLeave()
  local rejoinTime = GuildsComponentBus.Broadcast.GetGuildRejoiningCooldownSeconds()
  local switchTime = GuildsComponentBus.Broadcast.GetGuildSwitchingCooldownSeconds()
  local numMembers = GuildsComponentBus.Broadcast.GetNumGuildMembers()
  local confirmText
  if numMembers == 1 then
    confirmText = "@ui_leaveguild_alone_confirm"
  else
    confirmText = "@ui_leaveguild_confirm"
  end
  PopupWrapper:RequestPopup(ePopupButtons_YesNo, "@ui_leaveguild", confirmText, self.onLeavePopupEventId, self, self.OnPopupResult)
end
function GuildMenu:OnContextInvite()
  DynamicBus.SocialPaneBus.Broadcast.ToggleSocialMenu("GuildInvite")
end
function GuildMenu:SortByName()
  local previousSortOption = self.sortOption
  self.sortOption = "name"
  self.AllGuilds.SortMembersButton:SetDeselected()
  self.AllGuilds.SortClaimsButton:SetDeselected()
  if previousSortOption ~= self.sortOption or self.sortOrder == eSocialOrderDescending then
    self.sortOrder = eSocialOrderAscending
    self.AllGuilds.SortNameButton:SetSelectedAscending()
  else
    self.sortOrder = eSocialOrderDescending
    self.AllGuilds.SortNameButton:SetSelectedDescending()
  end
  if self.currentPrimaryScreen == self.AllGuilds.PrimaryScreen then
    self:RefreshAllGuilds(true)
  end
end
function GuildMenu:SortBySize()
  local previousSortOption = self.sortOption
  self.sortOption = "size"
  self.AllGuilds.SortNameButton:SetDeselected()
  self.AllGuilds.SortClaimsButton:SetDeselected()
  if previousSortOption ~= self.sortOption or self.sortOrder == eSocialOrderAscending then
    self.sortOrder = eSocialOrderDescending
    self.AllGuilds.SortMembersButton:SetSelectedDescending()
  else
    self.sortOrder = eSocialOrderAscending
    self.AllGuilds.SortMembersButton:SetSelectedAscending()
  end
  if self.currentPrimaryScreen == self.AllGuilds.PrimaryScreen then
    self:RefreshAllGuilds(true)
  end
end
function GuildMenu:SortByClaims()
  self.sortOption = "claims"
  self.AllGuilds.SortNameButton:SetDeselected()
  self.AllGuilds.SortMembersButton:SetDeselected()
  self.sortOrder = eSocialOrderDescending
  self.AllGuilds.SortClaimsButton:SetSelectedDescending()
  if self.currentPrimaryScreen == self.AllGuilds.PrimaryScreen then
    self:RefreshAllGuilds(true)
  end
end
function GuildMenu:CreateArcanaTimelines()
  if self.overviewArcanaTimelines then
    self:DestroyArcanaTimelines()
  end
  self.overviewArcanaTimelines = {}
  self.overviewArcanaTimelines.Ring1 = self:CreateInfiniteRotationTimeline(self.MyGuild.Overview.ArcanaRing1, 120)
  self.overviewArcanaTimelines.Ring2 = self:CreateInfiniteRotationTimeline(self.MyGuild.Overview.ArcanaRing2, 60)
  self.overviewArcanaTimelines.Ring3 = self:CreateInfiniteRotationTimeline(self.MyGuild.Overview.ArcanaRing3, 90)
end
function GuildMenu:CreateInfiniteRotationTimeline(entityId, duration)
  local timeline = self.ScriptedEntityTweener:TimelineCreate()
  timeline:Add(entityId, duration, {
    rotation = 360,
    ease = "Linear",
    onComplete = function()
      UiTransformBus.Event.SetZRotation(entityId, 0)
      timeline:Play()
    end
  })
  return timeline
end
function GuildMenu:DestroyArcanaTimelines()
  if self.overviewArcanaTimelines then
    for _, timeline in pairs(self.overviewArcanaTimelines) do
      timeline:Stop()
      self.ScriptedEntityTweener:TimelineDestroy(timeline)
    end
  end
end
function GuildMenu:EnterChatField()
  SetActionmapsForTextInput(self.canvasId, true)
end
function GuildMenu:OnTextInputEndEdit()
  SetActionmapsForTextInput(self.canvasId, false)
end
return GuildMenu
