local TitleSection = {
  Properties = {
    SectionHeader = {
      default = EntityId()
    },
    CurrentTitle = {
      default = EntityId()
    },
    ChangeButton = {
      default = EntityId()
    },
    ChangeTitleWindow = {
      default = EntityId()
    }
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(TitleSection)
function TitleSection:OnInit()
  BaseElement.OnInit(self)
  self.allTitleListData = {}
  self.allMetaAchievementListData = {}
  self.categoryToTitleIdLists = {}
  self.categoryIds = {}
  self.currentTitleId = 2140143823
  self.currentPronounType = ePronounType_None
  self.SectionHeader:SetText("@ui_title_section_title")
  self.SectionHeader:SetTextStyle(self.UIStyle.FONT_STYLE_STORE_FEATURED_TITLE)
  self.SectionHeader:SetDividerColor(self.UIStyle.COLOR_GRAY_50)
  UiTextBus.Event.SetTextWithFlags(self.Properties.CurrentTitle, "@ui_title_section_no_title", eUiTextSet_SetLocalized)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.SocialEntityId", function(self, socialEntityId)
    if not socialEntityId then
      return
    end
    if self.socialNotificationsHandler then
      self:BusDisconnect(self.socialNotificationsHandler)
    end
    self.socialNotificationsHandler = self:BusConnect(SocialNotificationsBus, socialEntityId)
    if self.metaAchievementRequestBusIsReady then
      JavSocialComponentBus.Broadcast.RequestAvailableTitles()
    end
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.JavSocialComponentBus.IsReady", function(self, isReady)
    if not isReady then
      return
    end
    local genderedTitleId = JavSocialComponentBus.Broadcast.GetActiveTitleId()
    self.currentTitleId = JavSocialComponentBus.Broadcast.GetNeutralTitleId(genderedTitleId)
    self.currentPronounType = JavSocialComponentBus.Broadcast.GetTitlePronounType()
    self.categoryIds = JavSocialComponentBus.Broadcast.GetAllTitleCategoryIds()
    self.categoryIdAndDataList = {}
    self.allCategoryOrderList = {}
    for i = 1, #self.categoryIds do
      local id = self.categoryIds[i]
      local currentCategoryData = JavSocialComponentBus.Broadcast.GetTitleCategoryData(id)
      self.categoryIdAndDataList[id] = currentCategoryData
      self.allCategoryOrderList[currentCategoryData.index] = id
    end
    self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.MetaAchievementRequestBus.IsReady", function(self, isReady)
      if not isReady then
        return
      end
      self.metaAchievementRequestBusIsReady = true
      if self.socialNotificationsHandler then
        JavSocialComponentBus.Broadcast.RequestAvailableTitles()
      end
    end)
  end)
  self.ChangeButton:SetText("@ui_change")
  self.ChangeButton:SetCallback(self.OnChangeButtonClicked, self)
  self.ChangeTitleWindow:SetOnApplyTitleCallback(self.ApplyTitle, self)
  self.ChangeTitleWindow:SetOnPronounTypeChanged(self.ChangePronounType, self)
end
function TitleSection:SetAcceptNotificationCallback(acceptNotificationCallback, acceptNotificationCallbackTable)
  self.acceptNotificationCallback = acceptNotificationCallback
  self.acceptNotificationCallbackTable = acceptNotificationCallbackTable
end
function TitleSection:OnAcceptTitleNotification(notificationId, isAccepted)
  if isAccepted and self.acceptNotificationCallback then
    if LyShineManagerBus.Broadcast.IsInState(849925872) or LyShineManagerBus.Broadcast.IsInState(921202721) or FtueSystemRequestBus.Broadcast.IsFtue() then
      local notificationData = NotificationData()
      notificationData.type = "Minor"
      notificationData.text = LyShineScriptBindRequestBus.Broadcast.LocalizeText("@ui_cannot_perform_action_at_this_time")
      notificationData.contextId = self.entityId
      notificationData.allowDuplicates = false
      UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
      return
    end
    self.acceptNotificationCallback(self.acceptNotificationCallbackTable)
  end
end
function TitleSection:OnChangeButtonClicked()
  local newTitleIds = JavSocialComponentBus.Broadcast.RequestNewTitles(true)
  for i = 1, #newTitleIds do
    local newTitleId = newTitleIds[i]
    local titleData = JavSocialComponentBus.Broadcast.GetTitleData(newTitleId)
    self.allTitleListData[newTitleId] = titleData
    local metaAchievementIds = titleData.metaAchievementIds
    if metaAchievementIds ~= nil then
      for metaAchievementIndex = 1, #metaAchievementIds do
        local id = metaAchievementIds[metaAchievementIndex]
        self.allMetaAchievementListData[id] = JavMetaAchievementRequestBus.Broadcast.GetMetaAchievementData(id)
      end
    end
    local currentCategory = titleData.category
    if self.categoryToTitleIdLists[currentCategory] ~= nil then
      if self.categoryToTitleIdLists[currentCategory].newTitleIds == nil then
        self.categoryToTitleIdLists[currentCategory].newTitleIds = {}
      end
      table.insert(self.categoryToTitleIdLists[currentCategory].newTitleIds, newTitleId)
    end
  end
  local unlockedCategoryOrderList = {}
  for i = 1, #self.allCategoryOrderList do
    local categoryId = self.allCategoryOrderList[i]
    local titleIdLists = self.categoryToTitleIdLists[categoryId]
    if titleIdLists ~= nil and (titleIdLists.oldTitleIds ~= nil or titleIdLists.newTitleIds ~= nil) then
      table.insert(unlockedCategoryOrderList, categoryId)
    end
  end
  self.ChangeTitleWindow:TransitionIn(self.currentTitleId, self.currentPronounType, self.categoryToTitleIdLists, unlockedCategoryOrderList, self.categoryIdAndDataList, self.allTitleListData, self.allMetaAchievementListData)
end
function TitleSection:ApplyTitle(newTitleId)
  JavSocialComponentBus.Broadcast.RequestSetTitle(newTitleId)
  self.currentTitleId = newTitleId
end
function TitleSection:ChangePronounType(newPronounType)
  self.currentPronounType = newPronounType
  self:OnTitleChanged(self.currentTitleId)
end
function TitleSection:OnReceivedTitles(availableTitles, newTitles)
  self.categoryToTitleIdLists = {}
  for i = 1, #self.categoryIds do
    local id = self.categoryIds[i]
    self.categoryToTitleIdLists[id] = {}
  end
  local availableTitleCount = availableTitles and #availableTitles or 0
  local newTitleCount = newTitles and #newTitles or 0
  for availableIndex = 1, availableTitleCount do
    local currentAvailable = availableTitles[availableIndex]
    local isNewTitle = false
    for newIndex = 1, newTitleCount do
      if currentAvailable == newTitles[newIndex] then
        isNewTitle = true
      end
    end
    if not isNewTitle then
      local titleData = JavSocialComponentBus.Broadcast.GetTitleData(currentAvailable)
      self.allTitleListData[currentAvailable] = titleData
      local metaAchievementIds = titleData.metaAchievementIds
      if metaAchievementIds ~= nil then
        for metaAchievementIndex = 1, #metaAchievementIds do
          local id = metaAchievementIds[metaAchievementIndex]
          self.allMetaAchievementListData[id] = JavMetaAchievementRequestBus.Broadcast.GetMetaAchievementData(id)
        end
      end
      local currentCategory = titleData.category
      if self.categoryToTitleIdLists[currentCategory] ~= nil then
        if self.categoryToTitleIdLists[currentCategory].oldTitleIds == nil then
          self.categoryToTitleIdLists[currentCategory].oldTitleIds = {}
        end
        table.insert(self.categoryToTitleIdLists[currentCategory].oldTitleIds, currentAvailable)
      end
    end
  end
  if self.currentTitleId ~= 2140143823 then
    local currentTitleData = JavSocialComponentBus.Broadcast.GetTitleData(self.currentTitleId)
    local genderedTitle = self:GetGenderedTitleString(self.currentPronounType, currentTitleData)
    UiTextBus.Event.SetTextWithFlags(self.Properties.CurrentTitle, genderedTitle, eUiTextSet_SetLocalized)
  else
    UiTextBus.Event.SetTextWithFlags(self.Properties.CurrentTitle, "@ui_title_section_no_title", eUiTextSet_SetLocalized)
  end
end
function TitleSection:OnUnlockTitle(titleId)
  local titleData = JavSocialComponentBus.Broadcast.GetTitleData(titleId)
  self.allTitleListData[titleId] = titleData
  local metaAchievementIds = titleData.metaAchievementIds
  if metaAchievementIds ~= nil then
    for metaAchievementIndex = 1, #metaAchievementIds do
      local id = metaAchievementIds[metaAchievementIndex]
      self.allMetaAchievementListData[id] = JavMetaAchievementRequestBus.Broadcast.GetMetaAchievementData(id)
    end
  end
  local notificationData = NotificationData()
  notificationData.type = "Generic"
  notificationData.title = "@ui_playertitle_notification_title"
  notificationData.hasChoice = true
  notificationData.contextId = self.entityId
  notificationData.declineTextOverride = "@ui_dismiss"
  notificationData.callbackName = "OnAcceptTitleNotification"
  local genderedTitle = self:GetGenderedTitleString(self.currentPronounType, titleData)
  notificationData.text = GetLocalizedReplacementText("@ui_playertitle_notification_desc", {
    color = ColorRgbaToHexString(self.UIStyle.COLOR_YELLOW),
    title = "&quot;" .. genderedTitle .. "&quot;"
  })
  notificationData.acceptTextOverride = "@ui_view_details"
  UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
end
function TitleSection:OnTitleChanged(pronounTitleId)
  local neutralTitle = JavSocialComponentBus.Broadcast.GetNeutralTitleId(pronounTitleId)
  self.currentTitleId = neutralTitle
  if neutralTitle ~= 2140143823 then
    self.currentPronounType = JavSocialComponentBus.Broadcast.GetTitlePronounType()
    local currentTitleData = self.allTitleListData[neutralTitle]
    local genderedTitle = self:GetGenderedTitleString(self.currentPronounType, currentTitleData)
    UiTextBus.Event.SetTextWithFlags(self.Properties.CurrentTitle, genderedTitle, eUiTextSet_SetLocalized)
  else
    UiTextBus.Event.SetTextWithFlags(self.Properties.CurrentTitle, "@ui_title_section_no_title", eUiTextSet_SetLocalized)
  end
end
function TitleSection:OnCurrentTitleExpired(expiredTitleId)
  local notificationData = NotificationData()
  notificationData.type = "Generic"
  notificationData.title = "@ui_playertitle_notification_expired_title"
  notificationData.hasChoice = true
  notificationData.contextId = self.entityId
  notificationData.declineTextOverride = "@ui_dismiss"
  notificationData.callbackName = "OnAcceptTitleNotification"
  local expiredTitleData = self.allTitleListData[expiredTitleId]
  local genderedTitle = self:GetGenderedTitleString(self.currentPronounType, expiredTitleData)
  notificationData.text = GetLocalizedReplacementText("@ui_playertitle_notification_expired_desc", {
    color = ColorRgbaToHexString(self.UIStyle.COLOR_YELLOW),
    title = "&quot;" .. genderedTitle .. "&quot;"
  })
  notificationData.acceptTextOverride = "@ui_view_details"
  UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
end
function TitleSection:GetGenderedTitleString(pronounType, data)
  local genderedTitle = ""
  if pronounType == ePronounType_Male then
    genderedTitle = data.titleMale
  elseif pronounType == ePronounType_Female then
    genderedTitle = data.titleFemale
  else
    genderedTitle = data.title
  end
  return genderedTitle
end
return TitleSection
