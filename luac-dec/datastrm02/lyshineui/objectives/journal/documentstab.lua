local DocumentsTab = {
  Properties = {
    TotalUnread = {
      default = EntityId()
    },
    NoDocumentsText = {
      default = EntityId()
    },
    TopicView = {
      View = {
        default = EntityId()
      },
      TopicList = {
        default = EntityId()
      },
      TopicListContent = {
        default = EntityId()
      },
      TopicListTitle = {
        default = EntityId()
      },
      DrawnLine = {
        default = EntityId()
      }
    },
    ChapterView = {
      View = {
        default = EntityId()
      },
      Title = {
        default = EntityId()
      },
      TopicList = {
        default = EntityId()
      },
      ChapterList = {
        default = EntityId()
      },
      ChapterGrid = {
        default = EntityId()
      },
      ChapterTopicListTitle = {
        default = EntityId()
      },
      ChapterTopicContent = {
        default = EntityId()
      },
      DrawnLine = {
        default = EntityId()
      },
      DrawnLineHorizontal = {
        default = EntityId()
      },
      Frame = {
        default = EntityId()
      }
    },
    PageView = {
      View = {
        default = EntityId()
      },
      Title = {
        default = EntityId()
      },
      PageNumberHeader = {
        default = EntityId()
      },
      BackButton = {
        default = EntityId()
      },
      ContentContainer = {
        default = EntityId()
      },
      ChapterList = {
        default = EntityId()
      },
      PageChapterListTitle = {
        default = EntityId()
      },
      PageChapterContent = {
        default = EntityId()
      },
      PageList = {
        default = EntityId()
      },
      LargePages = {
        TwoLeft = {
          default = EntityId()
        },
        Left = {
          default = EntityId()
        },
        Center = {
          default = EntityId()
        },
        Right = {
          default = EntityId()
        },
        TwoRight = {
          default = EntityId()
        }
      },
      PrevPageArrow = {
        default = EntityId()
      },
      NextPageArrow = {
        default = EntityId()
      },
      DrawnLine = {
        default = EntityId()
      },
      DrawnLineHorizontal = {
        default = EntityId()
      },
      Frame = {
        default = EntityId()
      }
    },
    DebugSetAllNewButton = {
      default = EntityId()
    }
  },
  journalEntries = {},
  topicOrderEntries = {},
  chapterOrderEntries = {},
  selectedTopicId = nil,
  selectedChapterId = nil,
  visibleTopic = nil,
  visibleChapter = nil,
  visibleTopicCount = 0,
  visibleChapterCount = 0,
  visiblePageNumber = 0,
  inactivePageOffset = 762,
  inactivePageScale = 1,
  inactivePageOpacity = 0.5,
  wraparoundPageOpacity = 0,
  openToLoreId = nil,
  numSlidingPages = 0,
  JOURNAL_ACTIVE_PAGES = 5,
  currentViewState = 0,
  VIEW_STATE_CHAPTER = 1,
  VIEW_STATE_PAGE = 2,
  radioTabsByChapterId = {},
  DEBUG = false
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(DocumentsTab)
local dataLayer = RequireScript("LyShineUI.UiDataLayer")
function DocumentsTab:OnInit()
  BaseElement.OnInit(self)
  self.dataLayer = dataLayer
  self:BusConnect(UiDynamicScrollBoxDataBus, self.Properties.ChapterView.TopicList)
  self:BusConnect(UiDynamicScrollBoxDataBus, self.Properties.PageView.ChapterList)
  self:BusConnect(UiDynamicScrollBoxElementNotificationBus, self.Properties.ChapterView.TopicList)
  self:BusConnect(UiDynamicScrollBoxElementNotificationBus, self.Properties.PageView.ChapterList)
  local topicEntries = JournalDataManagerBus.Broadcast.GetTopicEntries()
  for i = 1, #topicEntries do
    self.topicOrderEntries[topicEntries[i].topicId] = topicEntries[i].order
    local loreData = LoreDataManagerBus.Broadcast.GetLoreData(topicEntries[i].topicId)
    self.journalEntries[topicEntries[i].order] = {
      locked = true,
      isNew = false,
      title = loreData.title,
      body = loreData.body,
      id = topicEntries[i].topicId,
      imagePath = loreData.imagePath ~= "" and loreData.imagePath or nil,
      chapters = {}
    }
  end
  local chapterEntries = JournalDataManagerBus.Broadcast.GetChapterEntries()
  for i = 1, #chapterEntries do
    if self.topicOrderEntries[chapterEntries[i].topicId] ~= nil then
      self.chapterOrderEntries[chapterEntries[i].chapterId] = chapterEntries[i].order
      local loreData = LoreDataManagerBus.Broadcast.GetLoreData(chapterEntries[i].chapterId)
      self.journalEntries[self.topicOrderEntries[chapterEntries[i].topicId]].chapters[chapterEntries[i].order] = {
        locked = true,
        isNew = false,
        title = loreData.title,
        body = loreData.body,
        id = chapterEntries[i].chapterId,
        imagePath = loreData.imagePath ~= "" and loreData.imagePath or nil,
        pages = {}
      }
    end
  end
  local journalEntries = JournalDataManagerBus.Broadcast.GetJournalEntries()
  for i = 1, #journalEntries do
    if journalEntries[i].topicId ~= nil and journalEntries[i].topicId ~= "" and journalEntries[i].achievementId ~= "" then
      local topicIndex = self.topicOrderEntries[journalEntries[i].topicId]
      local chapterIndex = self.chapterOrderEntries[journalEntries[i].chapterId]
      if topicIndex and chapterIndex then
        if self.journalEntries[topicIndex].chapters[chapterIndex].pages[journalEntries[i].order] == nil then
          local loreData = LoreDataManagerBus.Broadcast.GetLoreData(journalEntries[i].pageId)
          local loreLocation = loreData.location
          if loreLocation.x == 0 and loreLocation.y == 0 then
            loreLocation = nil
          end
          self.journalEntries[topicIndex].chapters[chapterIndex].pages[journalEntries[i].order] = {
            locked = true,
            isNew = false,
            title = loreData.title,
            body = loreData.body,
            data = journalEntries[i],
            achievementId = loreData.achievementId,
            imagePath = loreData.imagePath ~= "" and loreData.imagePath or nil,
            subtitle = loreData.subtitle ~= "" and loreData.subtitle or nil,
            locationName = loreData.locationName ~= "" and loreData.locationName or nil,
            location = loreLocation
          }
        end
      else
        local errorLog = string.format("JOURNAL DATA ERROR:\n")
        errorLog = errorLog .. string.format("    journalEntries[%s].topicId = %s\n", tostring(i), tostring(journalEntries[i].topicId))
        errorLog = errorLog .. string.format("    journalEntries[%s].chapterId = %s\n", tostring(i), tostring(journalEntries[i].chapterId))
        errorLog = errorLog .. string.format("    self.topicOrderEntries[journalEntries[i].topicId] = %s\n", tostring(topicIndex))
        errorLog = errorLog .. string.format("    self.chapterOrderEntries[journalEntries[i].chapterId] = %s", tostring(chapterIndex))
        Debug.Log(errorLog)
      end
    end
  end
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.PlayerEntityId", function(self, data)
    self.playerEntityId = data
    if data then
      self:UpdateLockedStatus(false)
    end
  end)
  self.viewEntityByState = {
    [self.VIEW_STATE_CHAPTER] = self.Properties.ChapterView.View,
    [self.VIEW_STATE_PAGE] = self.Properties.PageView.View
  }
  self.PageView.BackButton:SetText("@ui_back")
  self.PageView.BackButton:SetButtonSingleIconPath("lyshineui/images/icons/misc/icon_back.dds")
  self.PageView.BackButton:SetButtonSingleIconSize(16)
  self.PageView.BackButton:PositionButtonSingleIconToText()
  self.PageView.BackButton:SetCallback(self.OnReturnToTopic, self)
  local viewTitleStyle = {
    fontFamily = self.UIStyle.FONT_FAMILY_PICA,
    fontSize = 58,
    characterSpacing = 100,
    fontColor = self.UIStyle.COLOR_TAN
  }
  SetTextStyle(self.Properties.TopicView.TopicListTitle, viewTitleStyle)
  SetTextStyle(self.Properties.ChapterView.Title, self.UIStyle.FONT_STYLE_JOURNAL_HEADER)
  SetTextStyle(self.Properties.ChapterView.ChapterTopicListTitle, self.UIStyle.FONT_STYLE_JOURNAL_HEADER)
  SetTextStyle(self.Properties.PageView.Title, self.UIStyle.FONT_STYLE_JOURNAL_HEADER)
  SetTextStyle(self.Properties.PageView.PageChapterListTitle, self.UIStyle.FONT_STYLE_JOURNAL_HEADER)
  UiTextBus.Event.SetTextWithFlags(self.Properties.ChapterView.Title, "@journal_chapters_title", eUiTextSet_SetLocalized)
  self.TopicView.DrawnLine:SetColor(self.UIStyle.COLOR_GRAY_80)
  self.ChapterView.DrawnLine:SetColor(self.UIStyle.COLOR_GRAY_80)
  self.ChapterView.DrawnLineHorizontal:SetColor(self.UIStyle.COLOR_GRAY_80)
  self.ChapterView.Frame:SetLineColor(self.UIStyle.COLOR_GRAY_80)
  self.PageView.DrawnLine:SetColor(self.UIStyle.COLOR_GRAY_80)
  self.PageView.DrawnLineHorizontal:SetColor(self.UIStyle.COLOR_GRAY_80)
  self.PageView.Frame:SetLineColor(self.UIStyle.COLOR_GRAY_80)
  self.TotalUnread:SetIsShowingText(false)
  self.PageView.LargePages.TwoLeft:SetDocumentTabEntity(self)
  self.PageView.LargePages.Left:SetDocumentTabEntity(self)
  self.PageView.LargePages.Center:SetDocumentTabEntity(self)
  self.PageView.LargePages.Right:SetDocumentTabEntity(self)
  self.PageView.LargePages.TwoRight:SetDocumentTabEntity(self)
  if self.DEBUG then
    self:DebugPrint()
    self.DebugSetAllNewButton:SetCallback(self.OnClickDebugSetAllNew, self)
    self.DebugSetAllNewButton:SetText("DEBUG Set All Discovered as New")
    UiElementBus.Event.SetIsEnabled(self.Properties.DebugSetAllNewButton, true)
  end
end
function DocumentsTab:DebugPrint()
  Debug.Log("DocumentList")
  for _, topicTable in ipairs(self.journalEntries) do
    Debug.Log("  " .. topicTable.id .. "(" .. tostring(topicTable.locked) .. ")")
    for _, chapterTable in ipairs(topicTable.chapters) do
      Debug.Log("    " .. chapterTable.id .. "(" .. tostring(chapterTable.locked) .. ")")
      for pageNumber, pageInfo in ipairs(chapterTable.pages) do
        Debug.Log("      " .. pageInfo.data.pageId .. ", Page " .. tostring(pageNumber) .. "(" .. tostring(pageInfo.locked) .. ")")
      end
    end
  end
end
function DocumentsTab:OnClickDebugSetAllNew()
  for _, topicTable in ipairs(self.journalEntries) do
    for _, chapterTable in ipairs(topicTable.chapters) do
      for pageNumber, pageInfo in ipairs(chapterTable.pages) do
        if not pageInfo.locked then
          pageInfo.isNew = true
        end
      end
    end
  end
  self:UpdateLockedStatus(true)
end
function DocumentsTab:IsLocked(achievementId)
  return achievementId and achievementId ~= 0 and not AchievementRequestBus.Event.IsAchievementUnlocked(self.playerEntityId, achievementId)
end
function DocumentsTab:UpdateLockedStatus(markNew)
  self.visibleTopicCount = 0
  local totalNewTopicPages = 0
  for _, topicTable in ipairs(self.journalEntries) do
    local newTopic = false
    local topicNewPageCount = 0
    local topicUnlockedPageCount = 0
    local topicDiscoveredChapterCount = 0
    local topicCompletedChapterCount = 0
    local topicLocked = true
    for _, chapterTable in ipairs(topicTable.chapters) do
      local newChapter = false
      local newPageCount = 0
      local chapterLocked = true
      local chapterCompleted = true
      for pageNumber, pageInfo in ipairs(chapterTable.pages) do
        local isCurrentPage = self.openToLoreId == pageInfo.data.pageId
        local isLocked = self:IsLocked(pageInfo.achievementId) and not isCurrentPage
        if markNew and not pageInfo.isNew and pageInfo.locked and not isLocked and not isCurrentPage then
          pageInfo.isNew = true
          newChapter = true
        end
        if pageInfo.isNew then
          newPageCount = newPageCount + 1
          topicNewPageCount = topicNewPageCount + 1
        end
        pageInfo.locked = isLocked
        chapterLocked = chapterLocked and pageInfo.locked
        if pageInfo.locked then
          chapterCompleted = false
        else
          topicUnlockedPageCount = topicUnlockedPageCount + 1
        end
      end
      if markNew and not chapterTable.isNew and newChapter then
        chapterTable.isNew = true
        newTopic = true
      end
      chapterTable.locked = chapterLocked
      chapterTable.newPageCount = newPageCount
      chapterTable.completed = chapterCompleted
      topicLocked = topicLocked and chapterTable.locked
      if not chapterTable.locked then
        topicDiscoveredChapterCount = topicDiscoveredChapterCount + 1
        if chapterTable.completed then
          topicCompletedChapterCount = topicCompletedChapterCount + 1
        end
      end
    end
    if markNew and not topicTable.isNew and newTopic then
      topicTable.isNew = true
    end
    topicTable.locked = topicLocked
    topicTable.newPageCount = topicNewPageCount
    topicTable.unlockedPageCount = topicUnlockedPageCount
    topicTable.visibleChapterCount = topicDiscoveredChapterCount
    topicTable.completedChapterCount = topicCompletedChapterCount
    if not topicTable.locked then
      self.visibleTopicCount = self.visibleTopicCount + 1
    end
    totalNewTopicPages = totalNewTopicPages + topicNewPageCount
  end
  if 0 < totalNewTopicPages then
    UiElementBus.Event.SetIsEnabled(self.Properties.TotalUnread, true)
    self.TotalUnread:SetNumber(totalNewTopicPages)
    self.TotalUnread:StartAnimation(true)
  else
    UiElementBus.Event.SetIsEnabled(self.Properties.TotalUnread, false)
    self.TotalUnread:StopAnimation()
  end
end
function DocumentsTab:OnAddToJournal(loreId)
  local loreData = LoreDataManagerBus.Broadcast.GetLoreData(loreId)
  local newPageNumber
  local unlockedPageCount = 0
  for _, topicTable in ipairs(self.journalEntries) do
    for _, chapterTable in ipairs(topicTable.chapters) do
      unlockedPageCount = 0
      for pageNumber, pageInfo in ipairs(chapterTable.pages) do
        if not pageInfo.locked then
          unlockedPageCount = unlockedPageCount + 1
        end
        if pageInfo.data.pageId == loreId then
          newPageNumber = pageNumber
          pageInfo.locked = false
          pageInfo.isNew = true
        end
      end
      if newPageNumber then
        if unlockedPageCount == #chapterTable.pages then
          LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Journal.ChapterComplete", chapterTable.id)
        elseif unlockedPageCount == 0 then
          LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Journal.NewChapterId", chapterTable.id)
        else
          local notificationData = NotificationData()
          notificationData.type = "Inventory"
          notificationData.maximumDuration = 7
          notificationData.title = "@ui_journal_notification_title"
          local notificationBodyText = LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement("@ui_journal_notification_body", loreData.title)
          local notificationSubText = GetLocalizedReplacementText("@ui_journal_notification_info", {
            chapterTitle = chapterTable.title,
            currentPage = tostring(newPageNumber),
            totalPages = tostring(#chapterTable.pages)
          })
          notificationData.text = notificationBodyText .. "\n" .. notificationSubText
          UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
        end
        return
      end
    end
  end
end
function DocumentsTab:OnShutdown()
  self.dataLayer:UnregisterObservers(self)
end
function DocumentsTab:SetStartingPage(loreId)
  self.openToLoreId = loreId
end
function DocumentsTab:OnTransitionIn()
  UiElementBus.Event.SetIsEnabled(self.Properties.NoDocumentsText, false)
  if self.openToLoreId then
    self:GoToPage(self.openToLoreId)
    self.openToLoreId = nil
  else
    self:UpdateLockedStatus(true)
    if not self.selectedTopicId then
      for t = 1, #self.journalEntries do
        local topicTable = self.journalEntries[t]
        if not topicTable.locked then
          self.selectedTopicId = topicTable.id
          break
        end
      end
    end
    if self.selectedTopicId then
      self:AnimateTransition(self.VIEW_STATE_CHAPTER, function()
        self:SetTopic(self.selectedTopicId)
      end, self)
    else
      UiElementBus.Event.SetIsEnabled(self.Properties.NoDocumentsText, true)
      self.ScriptedEntityTweener:Play(self.Properties.NoDocumentsText, 0.3, {opacity = 0}, {opacity = 1, ease = "QuadOut"})
    end
  end
  local lastStateOutTime = 0.15
  self.ChapterView.DrawnLine:SetVisible(false, 0)
  self.ChapterView.DrawnLineHorizontal:SetVisible(false, 0)
  self.ChapterView.Frame:ResetLines()
  self.ChapterView.DrawnLine:SetVisible(true, 2, {delay = lastStateOutTime})
  self.ChapterView.DrawnLineHorizontal:SetVisible(true, 2, {delay = lastStateOutTime})
  self.ChapterView.Frame:SetLineVisible(true, 2)
  self.PageView.DrawnLine:SetVisible(false, 0)
  self.PageView.DrawnLineHorizontal:SetVisible(false, 0)
  self.PageView.Frame:ResetLines()
  self.PageView.DrawnLine:SetVisible(true, 2, {delay = lastStateOutTime})
  self.PageView.DrawnLineHorizontal:SetVisible(true, 2, {delay = lastStateOutTime})
  self.PageView.Frame:SetLineVisible(true, 2)
end
function DocumentsTab:GoToPage(loreId)
  for _, topicTable in ipairs(self.journalEntries) do
    for _, chapterTable in ipairs(topicTable.chapters) do
      for pageNumber, pageInfo in ipairs(chapterTable.pages) do
        if pageInfo.data.pageId == loreId then
          if pageInfo.isNew then
            local event = UiAnalyticsEvent("ui_journal_read_now")
            event:AddAttribute("page_id", pageInfo.data.pageId)
            event:Send()
            pageInfo.isNew = false
          end
          self:UpdateLockedStatus(true)
          local openPageIndex = pageNumber - 1
          self:AnimateTransition(self.VIEW_STATE_PAGE, function()
            self:SetTopic(topicTable.id)
            if chapterTable ~= self.visibleChapter then
              self:ShowChapter(chapterTable, openPageIndex)
            else
              self:SetPage(openPageIndex)
            end
          end, self)
          break
        end
      end
    end
  end
end
function DocumentsTab:GetNumElements()
  local busId = UiDynamicScrollBoxDataBus.GetCurrentBusId()
  if busId == self.Properties.ChapterView.TopicList then
    return self.visibleTopicCount
  elseif busId == self.Properties.PageView.ChapterList then
    return self.visibleChapterCount
  end
  return 0
end
function DocumentsTab:OnElementBecomingVisible(entityId, index)
  local busId = UiDynamicScrollBoxElementNotificationBus.GetCurrentBusId()
  if busId == self.Properties.ChapterView.TopicList then
    local indexCount = -1
    for t = 1, #self.journalEntries do
      local topicTable = self.journalEntries[t]
      if not topicTable.locked then
        indexCount = indexCount + 1
      end
      if indexCount == index then
        local visibleTopicTable = self.registrar:GetEntityTable(entityId)
        local unlockedChapters = 0
        for _, chapterTable in ipairs(topicTable.chapters) do
          if not chapterTable.locked then
            unlockedChapters = unlockedChapters + 1
          end
        end
        visibleTopicTable:SetUserData(topicTable)
        if busId == self.Properties.ChapterView.TopicList then
          visibleTopicTable:AddToRadioGroup(self.Properties.ChapterView.ChapterTopicContent)
          UiRadioButtonGroupBus.Event.SetState(self.Properties.ChapterView.ChapterTopicContent, entityId, topicTable.id == self.visibleTopic.id)
          if topicTable.id == self.visibleTopic.id and visibleTopicTable.OnSelected then
            visibleTopicTable:OnSelected()
          elseif topicTable.id ~= self.visibleTopic.id and visibleTopicTable.OnUnselected then
            visibleTopicTable:OnUnselected()
          end
        end
        visibleTopicTable:SetIsVisible(true)
        return
      end
    end
  elseif busId == self.Properties.PageView.ChapterList then
    local indexCount = -1
    for c = 1, #self.visibleTopic.chapters do
      local chapterTable = self.visibleTopic.chapters[c]
      if not chapterTable.locked then
        indexCount = indexCount + 1
      end
      if indexCount == index then
        local radioTab = self.registrar:GetEntityTable(entityId)
        local unlockedPages = 0
        for i = 1, #chapterTable.pages do
          if not chapterTable.pages[i].locked then
            unlockedPages = unlockedPages + 1
          end
        end
        radioTab:AddToRadioGroup(self.Properties.PageView.PageChapterContent)
        radioTab:SetUserData(chapterTable)
        UiRadioButtonGroupBus.Event.SetState(self.Properties.PageView.PageChapterContent, entityId, chapterTable.id == self.visibleChapter.id)
        if chapterTable.id == self.visibleChapter.id and radioTab.OnSelected then
          radioTab:OnSelected()
        elseif chapterTable.id ~= self.visibleChapter.id and radioTab.OnUnselected then
          radioTab:OnUnselected()
        end
        radioTab:SetIsVisible(true)
        self.radioTabsByChapterId[chapterTable.id] = radioTab
        return
      end
    end
  end
end
function DocumentsTab:OnElementHidden(entityId)
  local busId = UiDynamicScrollBoxElementNotificationBus.GetCurrentBusId()
  if busId == self.Properties.ChapterView.TopicList then
    local visibleTopicTable = self.registrar:GetEntityTable(entityId)
    visibleTopicTable:RemoveFromRadioGroup(self.Properties.ChapterView.ChapterTopicContent)
    visibleTopicTable:SetIsVisible(false)
  end
end
function DocumentsTab:SetActive(active, callback)
  local animTime = 0.3
  local lineInTime = 1.2
  local endingOpacity = 1
  self.isActive = active
  if active then
    UiElementBus.Event.SetIsEnabled(self.entityId, true)
    self:OnTransitionIn()
  else
    endingOpacity = 0
    self:AnimateTransition(0)
  end
  self.ScriptedEntityTweener:Play(self.entityId, animTime, {
    opacity = endingOpacity,
    onComplete = function()
      if not active then
        UiElementBus.Event.SetIsEnabled(self.entityId, false)
      end
      if callback ~= nil and type(callback) == "function" then
        callback()
      end
    end
  })
end
function DocumentsTab:Refresh()
  local stateToRefresh = self.currentViewState > 0 and self.currentViewState or self.VIEW_STATE_CHAPTER
  self.currentViewState = 0
  self:AnimateTransition(stateToRefresh)
end
function DocumentsTab:SetTopic(topicId)
  self.selectedTopicId = topicId
  self.visibleTopic = self.journalEntries[self.topicOrderEntries[self.selectedTopicId]]
  self.visibleChapterCount = 0
  for _, chapterTable in pairs(self.visibleTopic.chapters) do
    if not chapterTable.locked then
      self.visibleChapterCount = self.visibleChapterCount + 1
    end
  end
  UiDynamicScrollBoxBus.Event.RefreshContent(self.Properties.ChapterView.TopicList)
  UiDynamicLayoutBus.Event.SetNumChildElements(self.Properties.ChapterView.ChapterGrid, self.visibleChapterCount)
  local indexCount = -1
  for c = 1, #self.visibleTopic.chapters do
    local chapterTable = self.visibleTopic.chapters[c]
    if not chapterTable.locked then
      indexCount = indexCount + 1
      local visibleChapterTable = self.registrar:GetEntityTable(UiElementBus.Event.GetChild(self.Properties.ChapterView.ChapterGrid, indexCount))
      visibleChapterTable:SetUserData(chapterTable)
      visibleChapterTable:SetIsVisible(true)
    end
  end
  local cellSize = UiLayoutGridBus.Event.GetCellSize(self.Properties.ChapterView.ChapterGrid)
  local gridSpacing = UiLayoutGridBus.Event.GetSpacing(self.Properties.ChapterView.ChapterGrid)
  local numCells = indexCount
  local gridWidth = UiTransform2dBus.Event.GetLocalWidth(self.Properties.ChapterView.ChapterGrid)
  local columnCount = math.floor((gridWidth + gridSpacing.x) / (cellSize.x + gridSpacing.x))
  local rowCount = math.floor(numCells / columnCount)
  if 0 < numCells % columnCount then
    rowCount = rowCount + 1
  end
  local gridHeight = rowCount * cellSize.y + gridSpacing.y * (rowCount - 1)
  UiTransform2dBus.Event.SetLocalHeight(self.Properties.ChapterView.ChapterGrid, gridHeight)
end
function DocumentsTab:OnChangeTopicRadio(entityId)
  local selectedTopic = UiRadioButtonGroupBus.Event.GetState(entityId)
  self:OnChangeTopic(selectedTopic)
end
function DocumentsTab:OnChangeTopic(entityId)
  local topic = self.registrar:GetEntityTable(entityId)
  local topicData = topic:GetUserData()
  local topicId = type(topicData) == "table" and topicData.id or topicData
  self:AnimateTransition(self.VIEW_STATE_CHAPTER, function()
    self:SetTopic(topicId)
  end, self)
end
function DocumentsTab:OnReturnToTopic()
  self:OnChangeTopicRadio(self.Properties.ChapterView.ChapterTopicContent)
end
function DocumentsTab:OnSelectChapterRadio(entityId)
  local selectedTopic = UiRadioButtonGroupBus.Event.GetState(entityId)
  self:OnSelectChapter(selectedTopic)
end
function DocumentsTab:OnSelectChapter(entityId)
  local chapter = self.registrar:GetEntityTable(entityId)
  local chapterData = chapter:GetUserData()
  local firstUnlockedPage = 0
  for p = 1, #chapterData.pages do
    if not chapterData.pages[p].locked then
      firstUnlockedPage = p - 1
      break
    end
  end
  self:AnimateTransition(self.VIEW_STATE_PAGE, function()
    self:ShowChapter(chapterData, firstUnlockedPage)
  end, self)
end
function DocumentsTab:ShowChapter(chapterTable, pageNumber)
  self.visibleChapter = chapterTable
  UiDynamicLayoutBus.Event.SetNumChildElements(self.PageView.PageList, #self.visibleChapter.pages)
  for i = 1, #self.visibleChapter.pages do
    local pageIconId = UiElementBus.Event.GetChild(self.PageView.PageList, i - 1)
    local pageIcon = self.registrar:GetEntityTable(pageIconId)
    pageIcon:SetUserData(self.visibleChapter.pages[i])
    local title = self.visibleChapter.title
    UiTextBus.Event.SetTextWithFlags(self.Properties.PageView.Title, title, eUiTextSet_SetLocalized)
    if not self.visibleChapter.pages[i].locked then
      pageIcon:SetCallback(self.AnimateToPage, self, i - 1)
    end
  end
  self.radioTabsByChapterId = {}
  UiDynamicScrollBoxBus.Event.RefreshContent(self.Properties.PageView.ChapterList)
  self:SetPage(pageNumber)
end
function DocumentsTab:SetPageAnimationData(entityId, xPos, scale, opacity)
  UiTransformBus.Event.SetLocalPositionX(entityId, xPos)
  UiTransformBus.Event.SetScale(entityId, Vector2(scale, scale))
  UiFaderBus.Event.SetFadeValue(entityId, opacity)
end
function DocumentsTab:SetPage(pageNumber, skipMarkingNew)
  local pageIconId, pageIcon
  if self.visiblePageNumber ~= nil then
    pageIconId = UiElementBus.Event.GetChild(self.PageView.PageList, self.visiblePageNumber)
    pageIcon = self.registrar:GetEntityTable(pageIconId)
    if pageIcon then
      pageIcon:SetActive(false)
    end
  end
  local textColor = self.UIStyle.COLOR_WHITE
  if self.visibleChapter.pages[pageNumber + 1] and self.visibleChapter.pages[pageNumber + 1].locked then
    textColor = self.UIStyle.COLOR_GRAY_50
  end
  local pageNumberText = LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement("@journal_page_number", tostring(pageNumber + 1))
  self.ScriptedEntityTweener:Play(self.Properties.PageView.PageNumberHeader, 0.1, {textColor = textColor, ease = "QuadOut"})
  UiTextBus.Event.SetTextWithFlags(self.Properties.PageView.PageNumberHeader, pageNumberText, eUiTextSet_SetAsIs)
  self.visiblePageNumber = pageNumber % #self.visibleChapter.pages
  if not self.visibleChapter.locked and not skipMarkingNew and self.visibleChapter.pages[self.visiblePageNumber + 1].isNew then
    local chapterIndex = self.chapterOrderEntries[self.visibleChapter.id]
    self.visibleTopic.chapters[chapterIndex].pages[self.visiblePageNumber + 1].isNew = false
    self.visibleChapter.newPageCount = self.visibleChapter.newPageCount - 1
    self.visibleTopic.newPageCount = self.visibleTopic.newPageCount - 1
    if self.radioTabsByChapterId[self.visibleChapter.id] then
      self.radioTabsByChapterId[self.visibleChapter.id]:SetUnreadNumber(self.visibleChapter.newPageCount)
    end
    local event = UiAnalyticsEvent("ui_journal_read_later")
    event:AddAttribute("page_id", self.visibleChapter.pages[self.visiblePageNumber + 1].data.pageId)
    event:Send()
  end
  self:UpdateLockedStatus(false)
  pageIconId = UiElementBus.Event.GetChild(self.PageView.PageList, self.visiblePageNumber)
  pageIcon = self.registrar:GetEntityTable(pageIconId)
  pageIcon:SetActive(true)
  if not skipMarkingNew then
    pageIcon:SetIsNew(false)
  end
  UiElementBus.Event.SetIsEnabled(self.PageView.PrevPageArrow, #self.visibleChapter.pages > 1)
  UiElementBus.Event.SetIsEnabled(self.PageView.NextPageArrow, #self.visibleChapter.pages > 1)
  self.PageView.LargePages.Center:SetActive(true)
  self.PageView.LargePages.Left:SetActive(false)
  self.PageView.LargePages.Right:SetActive(false)
  self.PageView.LargePages.TwoLeft:SetActive(false)
  self.PageView.LargePages.TwoRight:SetActive(false)
  self.PageView.LargePages.TwoLeft:ShowScrollBar(false)
  self.PageView.LargePages.Left:ShowScrollBar(false)
  self.PageView.LargePages.Center:ShowScrollBar(true)
  self.PageView.LargePages.Right:ShowScrollBar(false)
  self.PageView.LargePages.TwoRight:ShowScrollBar(false)
  UiElementBus.Event.SetIsEnabled(self.PageView.LargePages.Center.entityId, true)
  self:SetPageAnimationData(self.PageView.LargePages.Center.entityId, 0, 1, 1)
  self.PageView.LargePages.Center:SetUserData(self.visibleChapter.pages[self.visiblePageNumber + 1])
  local visible = #self.visibleChapter.pages > 1
  UiElementBus.Event.SetIsEnabled(self.PageView.LargePages.Left.entityId, visible)
  UiElementBus.Event.SetIsEnabled(self.PageView.LargePages.Right.entityId, visible)
  UiElementBus.Event.SetIsEnabled(self.PageView.LargePages.TwoLeft.entityId, visible)
  UiElementBus.Event.SetIsEnabled(self.PageView.LargePages.TwoRight.entityId, visible)
  if visible then
    local leftPageOpacity = self:GetPageOpacity(self.visiblePageNumber - 1)
    local rightPageOpacity = self:GetPageOpacity(self.visiblePageNumber + 1)
    self:SetPageAnimationData(self.PageView.LargePages.Left.entityId, -self.inactivePageOffset, self.inactivePageScale, leftPageOpacity)
    self:SetPageAnimationData(self.PageView.LargePages.Right.entityId, self.inactivePageOffset, self.inactivePageScale, rightPageOpacity)
    self:SetPageAnimationData(self.PageView.LargePages.TwoLeft.entityId, -self.inactivePageOffset * 2, self.inactivePageScale, leftPageOpacity)
    self:SetPageAnimationData(self.PageView.LargePages.TwoRight.entityId, self.inactivePageOffset * 2, self.inactivePageScale, rightPageOpacity)
    self.PageView.LargePages.Left:SetUserData(self.visibleChapter.pages[(self.visiblePageNumber - 1 + #self.visibleChapter.pages) % #self.visibleChapter.pages + 1])
    self.PageView.LargePages.Right:SetUserData(self.visibleChapter.pages[(self.visiblePageNumber + 1 + #self.visibleChapter.pages) % #self.visibleChapter.pages + 1])
    self.PageView.LargePages.TwoLeft:SetUserData(self.visibleChapter.pages[(self.visiblePageNumber - 2 + #self.visibleChapter.pages) % #self.visibleChapter.pages + 1])
    self.PageView.LargePages.TwoRight:SetUserData(self.visibleChapter.pages[(self.visiblePageNumber + 2 + #self.visibleChapter.pages) % #self.visibleChapter.pages + 1])
    for _, page in pairs(self.PageView.LargePages) do
      page:SetScroll(0)
    end
  end
end
function DocumentsTab:OnPageAnimationComplete(nextPageNumber, expectAnother, callback, callbackArg)
  self.numSlidingPages = self.numSlidingPages - 1
  if self.numSlidingPages == 0 then
    self:SetPage(nextPageNumber, expectAnother)
    if type(callback) == "function" then
      callback(self, callbackArg)
    end
  end
end
function DocumentsTab:OnPrevPage(callback, callbackArg, expectAnother)
  if #self.visibleChapter.pages > 1 and self.numSlidingPages <= 0 then
    local newPageNumber = (self.visiblePageNumber - 1) % #self.visibleChapter.pages
    if newPageNumber > self.visiblePageNumber then
      self:AnimateToPage(newPageNumber)
      return
    end
    self.numSlidingPages = self.JOURNAL_ACTIVE_PAGES
    self.audioHelper:PlaySound(self.audioHelper.Lore_ChangePage)
    local pageIconId = UiElementBus.Event.GetChild(self.PageView.PageList, self.visiblePageNumber)
    local pageIcon = self.registrar:GetEntityTable(pageIconId)
    pageIcon:SetActive(false)
    pageIconId = UiElementBus.Event.GetChild(self.PageView.PageList, newPageNumber)
    pageIcon = self.registrar:GetEntityTable(pageIconId)
    pageIcon:SetActive(true)
    local leftPageOpacity = self:GetPageOpacity(newPageNumber - 1)
    local rightPageOpacity = self:GetPageOpacity(newPageNumber + 1)
    local slideTime = expectAnother and 0.1 or 0.3
    self.PageView.LargePages.Center:SetScroll(0)
    local slideEase = expectAnother and "Linear" or "QuadOut"
    self.ScriptedEntityTweener:Play(self.PageView.LargePages.Center.entityId, slideTime, {x = 0}, {
      x = self.inactivePageOffset,
      scaleX = self.inactivePageScale,
      scaleY = self.inactivePageScale,
      opacity = rightPageOpacity,
      ease = slideEase,
      onComplete = function()
        self:OnPageAnimationComplete(self.visiblePageNumber - 1, expectAnother, callback, callbackArg)
      end
    })
    self.ScriptedEntityTweener:Play(self.PageView.LargePages.Left.entityId, slideTime, {
      x = -self.inactivePageOffset
    }, {
      x = 0,
      scaleX = 1,
      scaleY = 1,
      opacity = 1,
      ease = slideEase,
      onComplete = function()
        self:OnPageAnimationComplete(self.visiblePageNumber - 1, expectAnother, callback, callbackArg)
      end
    })
    self.ScriptedEntityTweener:Play(self.PageView.LargePages.Right.entityId, slideTime, {
      x = self.inactivePageOffset
    }, {
      x = self.inactivePageOffset * 2,
      scaleX = self.inactivePageScale,
      scaleY = self.inactivePageScale,
      opacity = rightPageOpacity,
      ease = slideEase,
      onComplete = function()
        self:OnPageAnimationComplete(self.visiblePageNumber - 1, expectAnother, callback, callbackArg)
      end
    })
    self.ScriptedEntityTweener:Play(self.PageView.LargePages.TwoLeft.entityId, slideTime, {
      x = -self.inactivePageOffset * 2
    }, {
      x = -self.inactivePageOffset,
      scaleX = self.inactivePageScale,
      scaleY = self.inactivePageScale,
      opacity = leftPageOpacity,
      ease = slideEase,
      onComplete = function()
        self:OnPageAnimationComplete(self.visiblePageNumber - 1, expectAnother, callback, callbackArg)
      end
    })
    self.ScriptedEntityTweener:Play(self.PageView.LargePages.TwoRight.entityId, slideTime, {
      x = self.inactivePageOffset * 2
    }, {
      x = self.inactivePageOffset * 3,
      scaleX = self.inactivePageScale,
      scaleY = self.inactivePageScale,
      opacity = rightPageOpacity,
      ease = slideEase,
      onComplete = function()
        self:OnPageAnimationComplete(self.visiblePageNumber - 1, expectAnother, callback, callbackArg)
      end
    })
  end
end
function DocumentsTab:OnNextPage(callback, callbackArg, expectAnother)
  if #self.visibleChapter.pages > 1 and self.numSlidingPages <= 0 then
    local newPageNumber = (self.visiblePageNumber + 1) % #self.visibleChapter.pages
    if newPageNumber < self.visiblePageNumber then
      self:AnimateToPage(newPageNumber)
      return
    end
    self.numSlidingPages = self.JOURNAL_ACTIVE_PAGES
    self.audioHelper:PlaySound(self.audioHelper.Lore_ChangePage)
    local pageIconId = UiElementBus.Event.GetChild(self.PageView.PageList, self.visiblePageNumber)
    local pageIcon = self.registrar:GetEntityTable(pageIconId)
    pageIcon:SetActive(false)
    pageIconId = UiElementBus.Event.GetChild(self.PageView.PageList, newPageNumber)
    pageIcon = self.registrar:GetEntityTable(pageIconId)
    pageIcon:SetActive(true)
    local leftPageOpacity = self:GetPageOpacity(newPageNumber - 1)
    local rightPageOpacity = self:GetPageOpacity(newPageNumber + 1)
    local slideTime = expectAnother and 0.1 or 0.3
    self.PageView.LargePages.Center:SetScroll(0)
    local slideEase = expectAnother and "Linear" or "QuadOut"
    self.ScriptedEntityTweener:Play(self.PageView.LargePages.Center.entityId, slideTime, {x = 0}, {
      x = -self.inactivePageOffset,
      scaleX = self.inactivePageScale,
      scaleY = self.inactivePageScale,
      opacity = leftPageOpacity,
      ease = slideEase,
      onComplete = function()
        self:OnPageAnimationComplete(self.visiblePageNumber + 1, expectAnother, callback, callbackArg)
      end
    })
    self.ScriptedEntityTweener:Play(self.PageView.LargePages.Left.entityId, slideTime, {
      x = -self.inactivePageOffset
    }, {
      x = -self.inactivePageOffset * 2,
      scaleX = self.inactivePageScale,
      scaleY = self.inactivePageScale,
      opacity = leftPageOpacity,
      ease = slideEase,
      onComplete = function()
        self:OnPageAnimationComplete(self.visiblePageNumber + 1, expectAnother, callback, callbackArg)
      end
    })
    self.ScriptedEntityTweener:Play(self.PageView.LargePages.Right.entityId, slideTime, {
      x = self.inactivePageOffset
    }, {
      x = 0,
      scaleX = 1,
      scaleY = 1,
      opacity = 1,
      ease = slideEase,
      onComplete = function()
        self:OnPageAnimationComplete(self.visiblePageNumber + 1, expectAnother, callback, callbackArg)
      end
    })
    self.ScriptedEntityTweener:Play(self.PageView.LargePages.TwoLeft.entityId, slideTime, {
      x = -self.inactivePageOffset * 2
    }, {
      x = -self.inactivePageOffset * 3,
      scaleX = self.inactivePageScale,
      scaleY = self.inactivePageScale,
      opacity = leftPageOpacity,
      ease = slideEase,
      onComplete = function()
        self:OnPageAnimationComplete(self.visiblePageNumber + 1, expectAnother, callback, callbackArg)
      end
    })
    self.ScriptedEntityTweener:Play(self.PageView.LargePages.TwoRight.entityId, slideTime, {
      x = self.inactivePageOffset * 2
    }, {
      x = self.inactivePageOffset,
      scaleX = self.inactivePageScale,
      scaleY = self.inactivePageScale,
      opacity = rightPageOpacity,
      ease = slideEase,
      onComplete = function()
        self:OnPageAnimationComplete(self.visiblePageNumber + 1, expectAnother, callback, callbackArg)
      end
    })
  end
end
function DocumentsTab:OnPrevPageHoverStart()
  self.ScriptedEntityTweener:Play(self.Properties.PageView.PrevPageArrow, 0.15, {opacity = 1})
end
function DocumentsTab:OnPrevPageHoverEnd()
  self.ScriptedEntityTweener:Play(self.Properties.PageView.PrevPageArrow, 0.15, {opacity = 0.6})
end
function DocumentsTab:OnNextPageHoverStart()
  self.ScriptedEntityTweener:Play(self.Properties.PageView.NextPageArrow, 0.15, {opacity = 1})
end
function DocumentsTab:OnNextPageHoverEnd()
  self.ScriptedEntityTweener:Play(self.Properties.PageView.NextPageArrow, 0.15, {opacity = 0.6})
end
function DocumentsTab:AnimateToPage(endPage)
  if self.visiblePageNumber == endPage then
    return
  end
  if endPage < self.visiblePageNumber then
    self:OnPrevPage(self.AnimateToPage, endPage, self.visiblePageNumber - endPage > 1)
  else
    self:OnNextPage(self.AnimateToPage, endPage, endPage - self.visiblePageNumber > 1)
  end
end
function DocumentsTab:GetPageOpacity(pageNumber)
  if pageNumber < 0 or pageNumber > #self.visibleChapter.pages - 1 then
    return self.wraparoundPageOpacity
  end
  return self.inactivePageOpacity
end
function DocumentsTab:AnimateTransition(newViewState, midChangeFn, midChangeTable)
  local lastStateOutTime = 0.15
  local newStateInTime = 0.15
  local slideAmount = 60
  function doMidChange()
    if type(midChangeFn) == "function" and type(midChangeTable) == "table" then
      midChangeFn(midChangeTable)
    end
    if self.currentViewState ~= newViewState then
      if self.viewEntityByState[self.currentViewState] then
        UiElementBus.Event.SetIsEnabled(self.viewEntityByState[self.currentViewState], false)
      end
      if self.viewEntityByState[newViewState] then
        UiElementBus.Event.SetIsEnabled(self.viewEntityByState[newViewState], true)
      end
      self.currentViewState = newViewState
    end
  end
  if newViewState ~= self.currentViewState then
    local oldEndX = slideAmount * -1
    local newStartX = slideAmount
    if newViewState < self.currentViewState then
      oldEndX = slideAmount
      newStartX = slideAmount * -1
    end
    if self.viewEntityByState[self.currentViewState] then
      self.ScriptedEntityTweener:Play(self.viewEntityByState[self.currentViewState], lastStateOutTime, {
        opacity = 0,
        x = oldEndX,
        ease = "QuadIn",
        onComplete = doMidChange
      })
    else
      lastStateOutTime = 0
    end
    if self.viewEntityByState[newViewState] then
      self.ScriptedEntityTweener:Play(self.viewEntityByState[newViewState], newStateInTime, {x = newStartX}, {
        opacity = 1,
        x = 0,
        delay = lastStateOutTime,
        ease = "QuadOut"
      })
    end
  end
  if newViewState == self.VIEW_STATE_CHAPTER then
    if self.currentViewState == self.VIEW_STATE_CHAPTER then
      self.ScriptedEntityTweener:Play(self.Properties.ChapterView.ChapterList, lastStateOutTime, {
        opacity = 0,
        ease = "QuadIn",
        onComplete = doMidChange
      })
      self.ScriptedEntityTweener:Play(self.Properties.ChapterView.ChapterList, newStateInTime, {
        opacity = 1,
        delay = lastStateOutTime + 0.05,
        ease = "QuadOut"
      })
    end
  elseif newViewState == self.VIEW_STATE_PAGE and self.currentViewState == self.VIEW_STATE_PAGE then
    self.ScriptedEntityTweener:Play(self.Properties.PageView.ContentContainer, lastStateOutTime, {
      opacity = 0,
      ease = "QuadIn",
      onComplete = doMidChange
    })
    self.ScriptedEntityTweener:Play(self.Properties.PageView.ContentContainer, newStateInTime, {
      opacity = 1,
      delay = lastStateOutTime + 0.05,
      ease = "QuadOut"
    })
  end
  self:SetChapterViewTabsVisible(newViewState == self.VIEW_STATE_CHAPTER)
  self:SetPageViewTabsVisible(newViewState == self.VIEW_STATE_PAGE)
  if newViewState > self.currentViewState then
    self.audioHelper:PlaySound(self.audioHelper.Lore_ChangeViewIn)
  elseif newViewState < self.currentViewState then
    self.audioHelper:PlaySound(self.audioHelper.Lore_ChangeViewOut)
  else
    self.audioHelper:PlaySound(self.audioHelper.Lore_RefreshView)
  end
  if lastStateOutTime == 0 then
    doMidChange()
  end
end
function DocumentsTab:TopicRefreshContent()
  UiDynamicLayoutBus.Event.SetNumChildElements(self.Properties.TopicView.TopicListContent, self.visibleTopicCount)
  local topicListEntityIds = UiElementBus.Event.GetChildren(self.Properties.TopicView.TopicListContent)
  local topicIndex = 1
  for i = 1, #topicListEntityIds do
    for j = topicIndex, #self.journalEntries do
      if self.journalEntries[j].locked then
        topicIndex = topicIndex + 1
      else
        break
      end
    end
    local topicTable = self.journalEntries[topicIndex]
    local visibleTopicTable = self.registrar:GetEntityTable(topicListEntityIds[i])
    visibleTopicTable:SetUserData(topicTable)
    visibleTopicTable:SetIsVisible(true)
    topicIndex = topicIndex + 1
  end
  local itemHeight = 270
  local padding = UiLayoutColumnBus.Event.GetPadding(self.Properties.TopicView.TopicListContent)
  local spacing = UiLayoutColumnBus.Event.GetSpacing(self.Properties.TopicView.TopicListContent)
  local height = padding.top + itemHeight * self.visibleTopicCount + spacing * (self.visibleTopicCount - 1)
  local offsets = UiTransform2dBus.Event.GetOffsets(self.Properties.TopicView.TopicListContent)
  offsets.bottom = offsets.top + height
  UiTransform2dBus.Event.SetOffsets(self.Properties.TopicView.TopicListContent, offsets)
end
function DocumentsTab:SetTopicViewCardsVisible(isVisible)
  if isVisible then
    self:TopicRefreshContent()
  else
    local topicListEntityIds = UiElementBus.Event.GetChildren(self.Properties.TopicView.TopicListContent)
    for i = 1, #topicListEntityIds do
      local chapterCard = self.registrar:GetEntityTable(topicListEntityIds[i])
      chapterCard:SetIsVisible(isVisible)
    end
  end
end
function DocumentsTab:SetChapterViewTabsVisible(isVisible)
  local chapterViewTabEntityIds = UiElementBus.Event.GetChildren(self.Properties.ChapterView.ChapterTopicContent)
  for i = 1, #chapterViewTabEntityIds do
    local radioTab = self.registrar:GetEntityTable(chapterViewTabEntityIds[i])
    radioTab:SetIsVisible(isVisible)
  end
  local chapterListEntityIds = UiElementBus.Event.GetChildren(self.Properties.ChapterView.ChapterGrid)
  for i = 1, #chapterListEntityIds do
    local chapterCard = self.registrar:GetEntityTable(chapterListEntityIds[i])
    chapterCard:SetIsVisible(isVisible)
  end
end
function DocumentsTab:SetPageViewTabsVisible(isVisible)
  local pageViewTabEntityIds = UiElementBus.Event.GetChildren(self.Properties.PageView.PageChapterContent)
  for i = 1, #pageViewTabEntityIds do
    local radioTab = self.registrar:GetEntityTable(pageViewTabEntityIds[i])
    radioTab:SetIsVisible(isVisible)
  end
end
return DocumentsTab
