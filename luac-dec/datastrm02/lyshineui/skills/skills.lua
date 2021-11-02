local Skills = {
  Properties = {
    TabbedList = {
      default = EntityId()
    },
    BadgeContainer = {
      default = EntityId()
    },
    AttributesBadge = {
      default = EntityId()
    },
    WeaponsBadge = {
      default = EntityId()
    },
    MetaAchievementsBadge = {
      default = EntityId()
    },
    BioScreen = {
      default = EntityId()
    },
    AttributesScreen = {
      default = EntityId()
    },
    WeaponMasteryScreen = {
      default = EntityId()
    },
    TradeSkillsScreen = {
      default = EntityId()
    },
    MetaAchievementsScreen = {
      default = EntityId()
    },
    FrameMultiBg = {
      default = EntityId()
    },
    MasteryTreeWindow = {
      default = EntityId()
    },
    TradeskillsGathering = {
      default = EntityId()
    },
    TradeskillsCrafting = {
      default = EntityId()
    },
    CraftingTooltip = {
      default = EntityId()
    },
    ActionMapActivators = {
      default = {
        "toggleSkillsComponent"
      }
    }
  },
  SCREEN_NAME_BIO = "BioScreen",
  SCREEN_NAME_ATTRIBUTES = "AttributesScreen",
  SCREEN_NAME_WEAPON_MASTERY = "WeaponMasterScreen",
  SCREEN_NAME_TRADE_SKILLS = "TradeSkillsScreen",
  SCREEN_NAME_META_ACHIEVEMENTS = "MetaAchievementsScreen",
  screenToIndex = {},
  attributesFrameHeight = 885,
  defaultFrameHeight = 850,
  availableTradeskillPoints = 0,
  availableAttributePoints = 0,
  availableWeaponMasteryPoints = 0,
  pendingAttributePoints = 0,
  pendingTradeskillPoints = 0,
  pendingWeaponMasteryPoints = 0,
  unclaimedRewardCount = 0,
  notificationIconPath = "lyshineui/images/skills/skill_pending.png",
  notificationEmptyIconPath = "lyshineui/images/icons/misc/empty.png"
}
local BaseScreen = RequireScript("LyShineUI._Common.BaseScreen")
BaseScreen:CreateNewScreen(Skills)
local WeaponMasteryData = RequireScript("LyShineUI.Skills.WeaponMastery.WeaponMasteryData")
local tweenerCommon = RequireScript("LyShineUI._Common.ScriptedEntityTweenerCommon")
function Skills:OnInit()
  BaseScreen.OnInit(self)
  for k, v in pairs(self.Properties.ActionMapActivators) do
    self:BusConnect(CryActionNotificationsBus, v)
  end
  self.dataLayer:RegisterOpenEvent("Skills", self.canvasId)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "UIFeatures.meta-achievements", function(self, enableMetaAchievements)
    if enableMetaAchievements == nil then
      return
    end
    self.isMetaAchievementsEnabled = enableMetaAchievements
    UiElementBus.Event.SetIsEnabled(self.Properties.MetaAchievementsScreen, self.isMetaAchievementsEnabled)
    self.navTabsData = {
      {
        badgeTable = nil,
        screenName = self.SCREEN_NAME_BIO,
        text = "@ui_bio",
        callback = self.OpenBio,
        screen = self.BioScreen,
        isEnabled = true,
        showXp = false,
        width = 338,
        height = 70,
        glowOffsetWidth = 222
      },
      {
        badgeTable = self.AttributesBadge,
        screenName = self.SCREEN_NAME_ATTRIBUTES,
        text = "@ui_attributes",
        callback = self.OpenAttributes,
        screen = self.AttributesScreen,
        isEnabled = true,
        showXp = true,
        width = 338,
        height = 70,
        glowOffsetWidth = 222
      },
      {
        badgeTable = self.WeaponsBadge,
        screenName = self.SCREEN_NAME_WEAPON_MASTERY,
        text = "@ui_weapon_mastery",
        callback = self.OpenWeaponMastery,
        screen = self.WeaponMasteryScreen,
        isEnabled = true,
        showXp = false,
        width = 338,
        height = 70,
        glowOffsetWidth = 222
      },
      {
        badgeTable = nil,
        screenName = self.SCREEN_NAME_TRADE_SKILLS,
        text = "@ui_trade_skills",
        callback = self.OpenTradeSkills,
        screen = self.TradeSkillsScreen,
        isEnabled = true,
        showXp = false,
        width = 338,
        height = 70,
        glowOffsetWidth = 222
      }
    }
    if self.isMetaAchievementsEnabled then
      local data = {
        badgeTable = self.MetaAchievementsBadge,
        screenName = self.SCREEN_NAME_META_ACHIEVEMENTS,
        text = "@ui_meta_achievements",
        callback = self.OpenMetaAchievements,
        screen = self.MetaAchievementsScreen,
        isEnabled = true,
        showXp = false,
        width = 339,
        height = 70,
        glowOffsetWidth = 222
      }
      table.insert(self.navTabsData, data)
    end
    self.TabbedList:SetListData(self.navTabsData, self)
    for i, tabData in ipairs(self.navTabsData) do
      if tabData.badgeTable then
        tabData.badgeTable:SetIsShowingText(false)
      end
      self.screenToIndex[tabData.screenName] = i
    end
    self:UpdateSelectedTab()
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "javelin.enable-in-game-survey", function(self, enableInGameSurvey)
    self.inGameSurveyEnabled = enableInGameSurvey
  end)
  self:RegisterObservers()
  self.activeScreen = self.SCREEN_NAME_ATTRIBUTES
  self.MasteryTreeWindow:SetScreenVisibleCallback(self.OnSubscreenVisibilityChanged, self)
  self.TradeskillsGathering:SetScreenVisibleCallback(self.OnSubscreenVisibilityChanged, self)
  self.TradeskillsCrafting:SetScreenVisibleCallback(self.OnSubscreenVisibilityChanged, self)
  self.MetaAchievementsScreen:SetAcceptAchievementNotificationCallback(self.OnAcceptAchievementNotification, self)
  self.BioScreen.TitleSection:SetAcceptNotificationCallback(self.OnAcceptTitleNotification, self)
  self.WeaponsBadge:SetStyle(self.WeaponsBadge.STYLE_MASTERY)
  self.isFtue = FtueSystemRequestBus.Broadcast.IsFtue()
  if self.isFtue then
    DynamicBus.FtueMessageBus.Connect(self.entityId, self)
  end
end
function Skills:OnShutdown()
  if self.isFtue then
    DynamicBus.FtueMessageBus.Disconnect(self.entityId, self)
  end
  BaseScreen.OnShutdown(self)
end
function Skills:OnCryAction(actionName)
  for k, v in pairs(self.Properties.ActionMapActivators) do
    if actionName == v then
      LyShineManagerBus.Broadcast.ToggleState(3576764016)
    end
  end
end
function Skills:CloseAllTabs()
  for i = 1, #self.navTabsData do
    local currNavData = self.navTabsData[i]
    currNavData.screen:TransitionOut()
  end
end
function Skills:OpenTradeSkills()
  if self.isMasteryTutorialActive then
    return
  end
  self.activeScreen = self.SCREEN_NAME_TRADE_SKILLS
  self:UpdateSelectedTab()
end
function Skills:OpenWeaponMastery()
  self.activeScreen = self.SCREEN_NAME_WEAPON_MASTERY
  self:UpdateSelectedTab()
end
function Skills:OpenAttributes()
  if self.isMasteryTutorialActive then
    return
  end
  self.activeScreen = self.SCREEN_NAME_ATTRIBUTES
  self:UpdateSelectedTab()
end
function Skills:OpenBio()
  if self.isMasteryTutorialActive then
    return
  end
  self.activeScreen = self.SCREEN_NAME_BIO
  self:UpdateSelectedTab()
end
function Skills:OpenMetaAchievements()
  if self.isMasteryTutorialActive then
    return
  end
  self.activeScreen = self.SCREEN_NAME_META_ACHIEVEMENTS
  self:UpdateSelectedTab()
end
function Skills:UpdateTabPoints(tabName, value)
  local targetIndex = self.screenToIndex[tabName]
  local badgeTable = self.navTabsData[targetIndex].badgeTable
  UiElementBus.Event.SetIsEnabled(badgeTable.entityId, 0 < value)
  if 0 < value then
    badgeTable:SetNumber(value)
    if self.screenVisible then
      badgeTable:StartAnimation(true)
    end
  else
    badgeTable:StopAnimation()
  end
end
function Skills:UpdateSkillsAvailableNotification()
  local skillsAvailable = self.availableTradeskillPoints > 0 or 0 < self.availableAttributePoints or 0 < self.availableWeaponMasteryPoints or 0 < self.pendingTradeskillPoints or 0 < self.pendingAttributePoints or 0 < self.pendingWeaponMasteryPoints
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Skills.HaveAvailablePoints", skillsAvailable)
end
function Skills:SetAvailableAttributesPoints(data)
  if data ~= nil then
    self.availableAttributePoints = data
    self:UpdateSkillsAvailableNotification()
    self:UpdateTabPoints(self.SCREEN_NAME_ATTRIBUTES, self.availableAttributePoints)
  end
end
function Skills:CollectAvailableMasteryPointsByGroup(group)
  local availableMasteryPoints = 0
  for i = 1, #group do
    availableMasteryPoints = availableMasteryPoints + ProgressionPointRequestBus.Event.GetUnallocatedPoolPoints(self.playerEntityId, group[i].tableNameId)
  end
  return availableMasteryPoints
end
function Skills:UpdateAvailableWeaponMasteryPoints()
  self.availableWeaponMasteryPoints = 0
  self.availableWeaponMasteryPoints = self.availableWeaponMasteryPoints + self:CollectAvailableMasteryPointsByGroup(WeaponMasteryData.data.OneHandedWeaponsData)
  self.availableWeaponMasteryPoints = self.availableWeaponMasteryPoints + self:CollectAvailableMasteryPointsByGroup(WeaponMasteryData.data.TwoHandedWeaponsData)
  self.availableWeaponMasteryPoints = self.availableWeaponMasteryPoints + self:CollectAvailableMasteryPointsByGroup(WeaponMasteryData.data.RangedWeaponsData)
  self.availableWeaponMasteryPoints = self.availableWeaponMasteryPoints + self:CollectAvailableMasteryPointsByGroup(WeaponMasteryData.data.MagicSkillsData)
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Skills.MasteryPoints", self.availableWeaponMasteryPoints)
  self:UpdateSkillsAvailableNotification()
  self:UpdateTabPoints(self.SCREEN_NAME_WEAPON_MASTERY, self.availableWeaponMasteryPoints)
end
function Skills:SetAttributesPending(data)
  if data ~= nil then
    self.pendingAttributePoints = data
    self:UpdateSkillsAvailableNotification()
  end
end
function Skills:SetWeaponMasteryPending(data)
  if data ~= nil then
    self.pendingWeaponMasteryPoints = data
    self:UpdateSkillsAvailableNotification()
  end
end
function Skills:UpdateScreenStates()
  UiElementBus.Event.SetIsEnabled(self.Properties.MasteryTreeWindow, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.TradeskillsGathering, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.TradeskillsCrafting, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.CraftingTooltip, false)
  local activeIndex = self.screenToIndex[self.activeScreen]
  for i = 1, #self.navTabsData do
    local currNavData = self.navTabsData[i]
    local currScreenEntity = currNavData.screen.entityId
    if currNavData.isEnabled then
      if currNavData.screenName == self.activeScreen then
        local frameHeight = self.activeScreen == self.SCREEN_NAME_ATTRIBUTES and self.attributesFrameHeight or self.defaultFrameHeight
        local duration = self.activeScreen == self.SCREEN_NAME_ATTRIBUTES and 0.3 or 0.1
        self.ScriptedEntityTweener:Play(self.Properties.FrameMultiBg, duration, {h = frameHeight, ease = "QuadOut"})
        currNavData.screen:TransitionIn()
        UiElementBus.Event.SetIsEnabled(currScreenEntity, true)
        self.ScriptedEntityTweener:Play(currScreenEntity, 0.5, {opacity = 1, ease = "QuadOut"})
        DynamicBus.GloryBarBus.Broadcast.SetXpVisible(currNavData.showXp)
      else
        currNavData.screen:TransitionOut()
        UiElementBus.Event.SetIsEnabled(currScreenEntity, false)
      end
    else
      UiElementBus.Event.SetIsEnabled(currScreenEntity, false)
    end
  end
end
function Skills:SetActiveScreenByIndex(index)
  if self.navTabsData[index] then
    self.activeScreen = self.navTabsData[index].screenName
    self:UpdateSelectedTab()
  end
end
function Skills:SetScreenEnabled(screenName, isEnabled)
  local tabIndex = self.screenToIndex[screenName]
  local tabData = self.navTabsData[tabIndex]
  if tabData then
    if tabData.isEnabled == isEnabled then
      return
    end
    tabData.isEnabled = isEnabled
    self:UpdateScreenStates()
  end
end
function Skills:RegisterObservers()
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.PlayerEntityId", function(self, playerEntityId)
    self.playerEntityId = playerEntityId
    if playerEntityId then
      self.progHandler = self:BusConnect(ProgressionPointsNotificationBus, self.playerEntityId)
      self:UpdateAvailableWeaponMasteryPoints()
    end
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Attributes.UnspentPoints", self.SetAvailableAttributesPoints)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Attributes.PendingPoints", self.SetAttributesPending)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.WeaponMastery.PendingPoints", self.SetWeaponMasteryPending)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "UIFeatures.g_uiEnableAttributes", function(self, data)
    self:SetScreenEnabled(self.SCREEN_NAME_ATTRIBUTES, data)
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "UIFeatures.g_uiEnableTradeskills", function(self, data)
    self:SetScreenEnabled(self.SCREEN_NAME_TRADE_SKILLS, data)
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "UIFeatures.g_uiEnableWeaponMastery", function(self, data)
    self:SetScreenEnabled(self.SCREEN_NAME_WEAPON_MASTERY, data)
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "MetaAchievements.UnclaimedRewardCount", function(self, count)
    if count ~= nil and self.isMetaAchievementsEnabled then
      self.unclaimedRewardCount = count
      self:UpdateTabPoints(self.SCREEN_NAME_META_ACHIEVEMENTS, count)
    end
  end)
end
function Skills:ExecuteObservers()
  local attributeData = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Attributes.UnspentPoints")
  if attributeData then
    self:SetAvailableAttributesPoints(attributeData)
  end
  self:UpdateAvailableWeaponMasteryPoints()
end
function Skills:SetScreenVisible(isVisible)
  local animDuration = 0.8
  self.screenVisible = isVisible
  if self.screenVisible == true then
    for i, tabData in pairs(self.navTabsData) do
      if tabData.badgeTable and UiElementBus.Event.IsEnabled(tabData.badgeTable.entityId) then
        tabData.badgeTable:StartAnimation(true)
      end
    end
    self:UpdateScreenStates()
  else
    for i, tabData in pairs(self.navTabsData) do
      if tabData.badgeTable then
        tabData.badgeTable:StopAnimation(true)
      end
    end
    self:CloseAllTabs()
    self.TabbedList:SetUnselected()
  end
end
function Skills:OnProgressionPointsChanged(pointId, oldLevel, newLevel)
  self:UpdateAvailableWeaponMasteryPoints()
end
function Skills:OnUnallocatedProgressionPointsChanged(poolId, oldLevel, newLevel)
  self:UpdateAvailableWeaponMasteryPoints()
end
function Skills:UpdateSelectedTab()
  local targetIndex = self.screenToIndex[self.activeScreen]
  if targetIndex ~= nil then
    self:UpdateScreenStates()
  end
end
function Skills:OnTransitionIn(fromStateName, fromLevelName, toStateName, toLevelName)
  if fromStateName == 1913028995 then
    return
  end
  JavelinCameraRequestBus.Broadcast.EnableDepthOfField(true)
  JavelinCameraRequestBus.Broadcast.SetDepthOfField(self.UIStyle.BLUR_DEPTH_OF_FIELD, self.UIStyle.BLUR_AMOUNT, self.UIStyle.BLUR_NEAR_DISTANCE, self.UIStyle.BLUR_NEAR_SCALE, self.UIStyle.RANGE_DEPTH_OF_FIELD)
  self:UpdateAvailableWeaponMasteryPoints()
  if self.availableAttributePoints > 0 then
    self.TabbedList:SetSelected(self.screenToIndex[self.SCREEN_NAME_ATTRIBUTES])
  elseif 0 < self.availableWeaponMasteryPoints then
    self.TabbedList:SetSelected(self.screenToIndex[self.SCREEN_NAME_WEAPON_MASTERY])
  elseif 0 < self.unclaimedRewardCount then
    self.TabbedList:SetSelected(self.screenToIndex[self.SCREEN_NAME_META_ACHIEVEMENTS])
  else
    self.TabbedList:SetSelected(self.screenToIndex[self.activeScreen])
  end
  self:SetScreenVisible(true)
  if self.inGameSurveyEnabled then
    DynamicBus.InGameSurvey.Broadcast.TryShowInGameSurvey()
  end
  self.audioHelper:PlaySound(self.audioHelper.Screen_SkillsOpen)
end
function Skills:OnTransitionOut(stateName, levelName)
  JavelinCameraRequestBus.Broadcast.ResetDepthOfField()
  self:SetScreenVisible(false)
  LyShineManagerBus.Broadcast.TransitionOutComplete()
  DynamicBus.GloryBarBus.Broadcast.SetXpVisible(false)
  self.audioHelper:PlaySound(self.audioHelper.Screen_SkillsClose)
end
function Skills:OnSubscreenVisibilityChanged(screenTable, isVisible)
  self:SetTabsVisible(not isVisible)
end
function Skills:OnAcceptAchievementNotification()
  if LyShineManagerBus.Broadcast.GetCurrentState() ~= 3576764016 then
    LyShineManagerBus.Broadcast.SetState(3576764016)
  end
  self.TabbedList:SetUnselected()
  self.TabbedList:SetSelected(self.screenToIndex[self.SCREEN_NAME_META_ACHIEVEMENTS])
end
function Skills:OnAcceptTitleNotification()
  if LyShineManagerBus.Broadcast.GetCurrentState() ~= 3576764016 then
    LyShineManagerBus.Broadcast.SetState(3576764016)
  end
  self.TabbedList:SetUnselected()
  self.TabbedList:SetSelected(self.screenToIndex[self.SCREEN_NAME_BIO])
end
function Skills:SetTabsVisible(isVisible)
  if isVisible then
    UiElementBus.Event.SetIsEnabled(self.Properties.TabbedList, true)
    self.ScriptedEntityTweener:PlayC(self.Properties.TabbedList, 0.15, tweenerCommon.fadeInQuadOut)
    self.ScriptedEntityTweener:PlayC(self.Properties.BadgeContainer, 0.15, tweenerCommon.fadeInQuadOut)
  else
    self.ScriptedEntityTweener:PlayC(self.Properties.TabbedList, 0.15, tweenerCommon.fadeOutQuadIn, nil, function()
      UiElementBus.Event.SetIsEnabled(self.Properties.TabbedList, false)
    end)
    self.ScriptedEntityTweener:PlayC(self.Properties.BadgeContainer, 0.15, tweenerCommon.fadeOutQuadIn)
  end
end
function Skills:SetMasteryTutorialActive(isActive)
  self.isMasteryTutorialActive = isActive
end
return Skills
