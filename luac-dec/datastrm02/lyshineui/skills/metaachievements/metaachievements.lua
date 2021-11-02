local MetaAchievements = {
  Properties = {
    MetaAchievementsTreeFrame = {
      default = EntityId()
    },
    MetaAchievementsTree = {
      default = EntityId()
    },
    MetaAchievementsTreeRow = {
      default = EntityId()
    },
    MetaAchievementsSummaryScreen = {
      default = EntityId()
    },
    MetaAchievementsAchievementsScreen = {
      default = EntityId()
    },
    MetaAchievementsRewardScreen = {
      default = EntityId()
    }
  },
  iconPathPattern = "LyShineUI/Images/%s.dds",
  MAX_ACTIVE_NOTIFICATIONS = 5
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(MetaAchievements)
local tweenerCommon = RequireScript("LyShineUI._Common.ScriptedEntityTweenerCommon")
function MetaAchievements:OnInit()
  BaseElement.OnInit(self)
  self.allCompletedMetaAchievementsCount = 0
  self.allCompletedMetaAchievementsData = {}
  self.categoryIdAndDataList = {}
  self.metaAchievementIdAndDataList = {}
  self.pendingMetaAchievementData = {}
  self.MetaAchievementsSummaryScreen:SetOnClickedCallback(self.MetaAchievementsTree.OnClickedElement, self.MetaAchievementsTree)
  self.MetaAchievementsRewardScreen:SetOnClaimedRewardsCallback(self.OnClaimRewards, self)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.PlayerEntityId", function(self, playerEntityId)
    if playerEntityId then
      self.playerId = PlayerComponentRequestsBus.Event.GetPlayerIdentification(playerEntityId)
    end
    self.playerName = self.playerId and self.playerId.playerName or ""
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.MetaAchievementRequestBus.IsReady", function(self, isReady)
    if not isReady then
      return
    end
    self.categoryIds = JavMetaAchievementRequestBus.Broadcast.GetAllCategoryIds()
    self.categoryIdAndDataList = {}
    for i = 1, #self.categoryIds do
      local id = self.categoryIds[i]
      self.categoryIdAndDataList[id] = JavMetaAchievementRequestBus.Broadcast.GetCategoryData(id)
    end
    self.metaAchievementIds = JavMetaAchievementRequestBus.Broadcast.GetAllMetaAchievementIds()
    self.metaAchievementIdAndDataList = {}
    for i = 1, #self.metaAchievementIds do
      local id = self.metaAchievementIds[i]
      self.metaAchievementIdAndDataList[id] = JavMetaAchievementRequestBus.Broadcast.GetMetaAchievementData(id)
    end
    self.categoryIdToMetaAchievementIdsAndData = {}
    for i = 1, #self.categoryIds do
      local categoryId = self.categoryIds[i]
      local categoryData = self.categoryIdAndDataList[categoryId]
      local iconColorBackground = categoryData.iconColorBackground
      self.categoryIdToMetaAchievementIdsAndData[categoryId] = {}
      local idAndDataList = self.categoryIdToMetaAchievementIdsAndData[categoryId]
      for i = 1, #self.metaAchievementIds do
        local id = self.metaAchievementIds[i]
        if self.metaAchievementIdAndDataList[id].category == categoryId then
          idAndDataList[id] = {}
          idAndDataList[id].itemData = self.metaAchievementIdAndDataList[id]
          idAndDataList[id].progressCount = 0
          idAndDataList[id].hidden = false
          idAndDataList[id].playerName = self.playerName
          idAndDataList[id].iconColorBackground = iconColorBackground
          idAndDataList[id].isDisplayOneIndexed = JavMetaAchievementRequestBus.Broadcast.IsDisplayOneIndexed(id)
          idAndDataList[id].isDisplayBinary = JavMetaAchievementRequestBus.Broadcast.IsDisplayBinary(id)
        end
      end
    end
    self:SetTreeStructure()
    if not self.entityIdObserverRegistered then
      self.entityIdObserverRegistered = true
      self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.GDERootEntityId", function(self, rootEntityId)
        if rootEntityId then
          self:BusDisconnect(self.notificationHandler)
          self.notificationHandler = self:BusConnect(MetaAchievementNotificationBus, rootEntityId)
          JavMetaAchievementRequestBus.Broadcast.RequestRewardPendingAchievementIds()
          JavMetaAchievementRequestBus.Broadcast.RequestSummaryPageInfo()
        end
      end)
    end
  end)
  if not self.hasReceivedMetaAchievementsSummaryInfo then
    self:OnReceiveMetaAchievementsSummaryInformation()
  end
  self.MetaAchievementsTreeFrame:SetLineVisible(true)
  self.MetaAchievementsTreeFrame:SetFrameTextureVisible(false)
  self.MetaAchievementsTreeFrame:SetFillAlpha(0)
end
function MetaAchievements:SetTreeStructure()
  self.categoryIdAndTreeDataList = {}
  for k, v in pairs(self.categoryIdAndDataList) do
    local totalCount = CountAssociativeTable(self.categoryIdToMetaAchievementIdsAndData[k])
    if totalCount ~= 0 or v.parentCategory == 0 then
      self.categoryIdAndTreeDataList[k] = {}
      local currentTreeData = self.categoryIdAndTreeDataList[k]
      currentTreeData.itemData = v
      currentTreeData.hasChildren = false
      currentTreeData.expanded = false
      currentTreeData.selected = false
      currentTreeData.completedCount = 0
      currentTreeData.totalCount = totalCount
    end
  end
  self.treeStructure = {}
  for k, v in pairs(self.categoryIdAndTreeDataList) do
    local parentCategory = v.itemData.parentCategory
    if parentCategory == 0 then
      local index = v.itemData.index
      self.treeStructure[index] = {}
      self.treeStructure[index].id = k
      self.treeStructure[index].children = {}
    end
  end
  for k, v in pairs(self.categoryIdAndTreeDataList) do
    local parentCategory = v.itemData.parentCategory
    if parentCategory ~= 0 then
      local index = v.itemData.index
      local treeDataParent = self.categoryIdAndTreeDataList[parentCategory]
      treeDataParent.hasChildren = true
      local parentIndex = self.categoryIdAndTreeDataList[parentCategory].itemData.index
      local treeStructurechildrenList = self.treeStructure[parentIndex].children
      treeStructurechildrenList[index] = {}
      treeStructurechildrenList[index].id = k
      treeStructurechildrenList[index].children = {}
    end
  end
  for i = 3, #self.treeStructure do
    local currentParentData = self.treeStructure[i]
    if currentParentData ~= nil then
      local currentParentTreeData = self.categoryIdAndTreeDataList[currentParentData.id]
      local totalCount = currentParentTreeData.totalCount
      for k, v in pairs(currentParentData.children) do
        if v ~= nil then
          local currentChildId = v.id
          totalCount = totalCount + self.categoryIdAndTreeDataList[currentChildId].totalCount
        end
      end
      currentParentTreeData.totalCount = totalCount
      if totalCount == 0 then
        self.treeStructure[i] = nil
      end
    end
  end
end
function MetaAchievements:SetScreenVisible(isVisible)
  if isVisible then
    self.ScriptedEntityTweener:PlayFromC(self.entityId, 0.3, {opacity = 0}, tweenerCommon.fadeInQuadOut)
  end
end
function MetaAchievements:TransitionIn()
  JavMetaAchievementRequestBus.Broadcast.RequestSummaryPageInfo()
  self:SetScreenVisible(true)
  if #self.pendingMetaAchievementData ~= 0 then
    self.MetaAchievementsRewardScreen:TransitionIn()
    self.MetaAchievementsRewardScreen:UpdateContent(self.pendingMetaAchievementData)
  end
end
function MetaAchievements:TransitionOut()
  self:SetScreenVisible(false)
end
function MetaAchievements:UpdateContentScreen(categoryId)
  if categoryId == 3458754147 then
    self.MetaAchievementsAchievementsScreen:TransitionOut()
    self.MetaAchievementsSummaryScreen:TransitionIn()
  else
    self.MetaAchievementsSummaryScreen:TransitionOut()
    if categoryId == 181160428 and self.categoryIdAndTreeDataList then
      local title = self.categoryIdAndTreeDataList[categoryId].itemData.title
      self.MetaAchievementsAchievementsScreen:OnUpdateAchievements(title, self.allCompletedMetaAchievementsData)
    else
      JavMetaAchievementRequestBus.Broadcast.RequestAllProgressForCategory(categoryId)
    end
    self.MetaAchievementsAchievementsScreen:TransitionIn()
  end
end
function MetaAchievements:UpdateHiddenStatus(metaAchievementData, idAndDataList)
  local metaAchievementItemData = metaAchievementData.itemData
  local hiddenText = metaAchievementItemData.hiddenText
  if hiddenText ~= nil and hiddenText ~= "" then
    local predecessorIds = metaAchievementItemData.predecessorIds
    local numpredecessorIds = #predecessorIds
    local updatedTotal = self:GetTotal(metaAchievementData)
    if numpredecessorIds == 0 then
      if updatedTotal <= metaAchievementData.progressCount then
        metaAchievementData.hidden = false
      else
        metaAchievementData.hidden = true
      end
    else
      metaAchievementData.hidden = false
      for predecessorIndex = 1, numpredecessorIds do
        local currentpredecessorId = predecessorIds[predecessorIndex]
        local currentpredecessorData = idAndDataList[currentpredecessorId]
        if updatedTotal > currentpredecessorData.progressCount then
          metaAchievementData.hidden = true
          break
        end
      end
    end
  else
    metaAchievementData.hidden = false
  end
end
function MetaAchievements:OnReceiveMetaAchievementsSummaryInformation(recentlyCompletedMetaAchievements, nearlyCompletedMetaAchievementIdAndProgress, allCompletedMetaAchievements)
  self.hasReceivedMetaAchievementsSummaryInfo = true
  local treeStructureCount = self.treeStructure and #self.treeStructure or 0
  local allCompletedMetaAchievementsCount = allCompletedMetaAchievements and #allCompletedMetaAchievements or 0
  if allCompletedMetaAchievementsCount > self.allCompletedMetaAchievementsCount or allCompletedMetaAchievementsCount == 0 then
    for i = 1, allCompletedMetaAchievementsCount do
      local metaAchievementId = allCompletedMetaAchievements[i]
      local metaAchievementData = self.metaAchievementIdAndDataList[metaAchievementId]
      if metaAchievementData ~= nil then
        local categoryId = metaAchievementData.category
        local idAndDataList = self.categoryIdToMetaAchievementIdsAndData[categoryId]
        if idAndDataList == nil then
          Log("ERROR: MetaAchievements:OnReceiveMetaAchievementsSummaryInformation -- Category Id didn't have any data: " .. tostring(categoryId))
        else
          local metaAchievementFullData = idAndDataList[metaAchievementId]
          local updatedTotal = self:GetTotal(metaAchievementFullData)
          if updatedTotal > metaAchievementFullData.progressCount then
            local categoryTreeData = self.categoryIdAndTreeDataList[categoryId]
            categoryTreeData.completedCount = categoryTreeData.completedCount + 1
            metaAchievementFullData.progressCount = updatedTotal
            local newCompletedListIndex = #self.allCompletedMetaAchievementsData + 1
            self.allCompletedMetaAchievementsData[newCompletedListIndex] = {}
            local newListData = self.allCompletedMetaAchievementsData[newCompletedListIndex]
            newListData.itemData = metaAchievementFullData.itemData
            newListData.progressCount = metaAchievementFullData.progressCount
            newListData.hidden = metaAchievementFullData.hidden
            newListData.iconColorBackground = metaAchievementFullData.iconColorBackground
            newListData.isDisplayOneIndexed = metaAchievementFullData.isDisplayOneIndexed
            newListData.isDisplayBinary = metaAchievementFullData.isDisplayBinary
            newListData.playerName = self.playerName
          end
        end
      end
    end
    self.allCompletedMetaAchievementsCount = allCompletedMetaAchievementsCount
    for i = 1, treeStructureCount do
      local currentParentData = self.treeStructure[i]
      if currentParentData ~= nil and CountAssociativeTable(currentParentData.children) ~= 0 then
        local completedCount = 0
        for k, v in pairs(currentParentData.children) do
          if v ~= nil then
            local currentChildId = v.id
            completedCount = completedCount + self.categoryIdAndTreeDataList[currentChildId].completedCount
          end
        end
        local currentParentTreeData = self.categoryIdAndTreeDataList[currentParentData.id]
        currentParentTreeData.completedCount = completedCount
      end
    end
    self.categoryProgressData = {}
    for i = 3, treeStructureCount do
      local currentParentData = self.treeStructure[i]
      if currentParentData ~= nil then
        local currentParentTreeData = self.categoryIdAndTreeDataList[currentParentData.id]
        local newCategoryProgressDataIndex = i - 2
        self.categoryProgressData[newCategoryProgressDataIndex] = {}
        local currentData = self.categoryProgressData[newCategoryProgressDataIndex]
        currentData.id = currentParentData.id
        currentData.title = currentParentTreeData.itemData.title
        currentData.completedCount = currentParentTreeData.completedCount
        currentData.totalCount = currentParentTreeData.totalCount
      end
    end
    self.recentlyCompletedMetaAchievementData = {}
    local recentlyCompletedMetaAchievementsCount = recentlyCompletedMetaAchievements and #recentlyCompletedMetaAchievements or 0
    for i = 1, recentlyCompletedMetaAchievementsCount do
      self.recentlyCompletedMetaAchievementData[i] = {}
      local newData = self.recentlyCompletedMetaAchievementData[i]
      local recentId = recentlyCompletedMetaAchievements[i]
      local metaAchievementData = self.metaAchievementIdAndDataList[recentId]
      local categoryId = metaAchievementData.category
      local categoryDataList = self.categoryIdToMetaAchievementIdsAndData[categoryId]
      local fullMetaAchievementsData = categoryDataList[recentId]
      local updatedTotal = self:GetTotal(fullMetaAchievementsData)
      newData.itemData = metaAchievementData
      newData.progressCount = updatedTotal
      newData.hidden = false
      newData.playerName = self.playerName
      local categoryData = self.categoryIdAndDataList[categoryId]
      newData.iconColorBackground = categoryData.iconColorBackground
      newData.isDisplayOneIndexed = fullMetaAchievementsData.isDisplayOneIndexed
      newData.isDisplayBinary = fullMetaAchievementsData.isDisplayBinary
    end
  end
  local nearlyCompletedMetaAchievementData = {}
  local nearlyCompletedMetaAchievementIdAndProgressCount = nearlyCompletedMetaAchievementIdAndProgress and #nearlyCompletedMetaAchievementIdAndProgress or 0
  for i = 1, nearlyCompletedMetaAchievementIdAndProgressCount do
    nearlyCompletedMetaAchievementData[i] = {}
    local newData = nearlyCompletedMetaAchievementData[i]
    local nearlyIdAndProgress = nearlyCompletedMetaAchievementIdAndProgress[i]
    local metaAchievementData = self.metaAchievementIdAndDataList[nearlyIdAndProgress.first]
    newData.itemData = metaAchievementData
    newData.progressCount = nearlyIdAndProgress.second
    newData.playerName = self.playerName
    local categoryId = metaAchievementData.category
    local categoryData = self.categoryIdAndDataList[categoryId]
    newData.iconColorBackground = categoryData.iconColorBackground
    local categoryDataList = self.categoryIdToMetaAchievementIdsAndData[categoryId]
    local fullMetaAchievementsData = categoryDataList[nearlyIdAndProgress.first]
    newData.isDisplayOneIndexed = fullMetaAchievementsData.isDisplayOneIndexed
    newData.isDisplayBinary = fullMetaAchievementsData.isDisplayBinary
    self:UpdateHiddenStatus(newData, self.categoryIdToMetaAchievementIdsAndData[categoryId])
  end
  self.MetaAchievementsSummaryScreen:UpdateSummaryData(self.recentlyCompletedMetaAchievementData, nearlyCompletedMetaAchievementData, self.categoryProgressData)
  if self.categoryIdAndTreeDataList then
    for k, v in pairs(self.categoryIdAndTreeDataList) do
      v.selected = false
    end
    if 0 < treeStructureCount then
      local id = self.treeStructure[1].id
      self.categoryIdAndTreeDataList[id].selected = true
    end
    self.MetaAchievementsTree:OnDataSet(self.categoryIdAndTreeDataList, self.treeStructure, self.UpdateContentScreen, self, false)
  end
  self:UpdateContentScreen(3458754147)
end
function MetaAchievements:OnReceiveProgressForCategory(progress)
  if #progress == 0 then
    return
  end
  local categoryId = self.metaAchievementIdAndDataList[progress[1].first].category
  local title = self.categoryIdAndTreeDataList[categoryId].itemData.title
  local idAndDataList = self.categoryIdToMetaAchievementIdsAndData[categoryId]
  for i = 1, #progress do
    local metaAchievementId = progress[i].first
    local metaAchievementProgress = progress[i].second
    local metaAchievementData = idAndDataList[metaAchievementId]
    metaAchievementData.progressCount = metaAchievementProgress
  end
  local dataList = {}
  for i = 1, #progress do
    local metaAchievementId = progress[i].first
    local metaAchievementData = idAndDataList[metaAchievementId]
    self:UpdateHiddenStatus(metaAchievementData, idAndDataList)
    table.insert(dataList, metaAchievementData)
  end
  self.MetaAchievementsAchievementsScreen:OnUpdateAchievements(title, dataList)
end
function MetaAchievements:OnMetaAchievementThresholdReached(id, currentValue, targetValue)
  if not self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Options.Misc.MetaAchievementPopupsEnabled") then
    return
  end
  local data = self.metaAchievementIdAndDataList[id]
  local iconPath = string.format(self.iconPathPattern, data.icon)
  local category = data.category
  local categoryDataList = self.categoryIdToMetaAchievementIdsAndData[category]
  local fullMetaAchievementsData = categoryDataList[id]
  local currentValueIndexed = fullMetaAchievementsData.isDisplayOneIndexed and currentValue + 1 or currentValue
  local targetValueIndexed = fullMetaAchievementsData.isDisplayOneIndexed and targetValue + 1 or targetValue
  local iconColorBackground = fullMetaAchievementsData.iconColorBackground
  self.notificationFillPercent = targetValue ~= 0 and currentValueIndexed / targetValueIndexed or 0
  self.notificationFillImage = iconColorBackground
  local typeCount = UiNotificationsBus.Broadcast.GetNumNotificationsByType("FillMetaAchievement")
  if typeCount < self.MAX_ACTIVE_NOTIFICATIONS then
    local notificationData = NotificationData()
    notificationData.type = "FillMetaAchievement"
    notificationData.icon = iconPath
    notificationData.title = data.title
    local fractionText = string.format("%d / %d", currentValueIndexed, targetValueIndexed)
    local descriptionText = GetLocalizedReplacementText(data.description, {number = fractionText})
    notificationData.text = GetLocalizedReplacementText("@ui_meta_achievements_threshold_reached_text", {
      percentage = tostring(math.ceil(self.notificationFillPercent * 100)),
      description = descriptionText
    })
    notificationData.maximumDuration = 5
    notificationData.contextId = self.entityId
    UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
  end
end
function MetaAchievements:OnMetaAchievementCompleted(id)
  local data = self.metaAchievementIdAndDataList[id]
  if data == nil then
    return
  end
  local newData = {}
  local categoryId = data.category
  local categoryDataList = self.categoryIdToMetaAchievementIdsAndData[categoryId]
  local fullMetaAchievementsData = categoryDataList[id]
  local updatedTotal = self:GetTotal(fullMetaAchievementsData)
  newData.itemData = data
  newData.progressCount = updatedTotal
  newData.hidden = false
  newData.playerName = self.playerName
  local categoryData = self.categoryIdAndDataList[categoryId]
  newData.iconColorBackground = categoryData.iconColorBackground
  newData.isDisplayOneIndexed = fullMetaAchievementsData.isDisplayOneIndexed
  newData.isDisplayBinary = fullMetaAchievementsData.isDisplayBinary
  self.MetaAchievementsSummaryScreen:AddRecentlyCompletedMetaAchievement(newData)
  if not self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Options.Misc.MetaAchievementPopupsEnabled") then
    return
  end
  local titlesIds = JavMetaAchievementRequestBus.Broadcast.GetTitlesIdsForMetaAchievement(id)
  local numTitlesIds = titlesIds and #titlesIds or 0
  if numTitlesIds ~= 0 then
    table.insert(self.pendingMetaAchievementData, fullMetaAchievementsData)
    local oldUnclaimedRewardCount = self.dataLayer:GetDataFromNode("MetaAchievements.UnclaimedRewardCount")
    LyShineDataLayerBus.Broadcast.SetData("MetaAchievements.UnclaimedRewardCount", oldUnclaimedRewardCount + numTitlesIds)
  end
  self.notificationBackgroundImage = categoryData.iconColorBackground
  local typeCount = UiNotificationsBus.Broadcast.GetNumNotificationsByType("MetaAchievementCompleted")
  if typeCount < self.MAX_ACTIVE_NOTIFICATIONS then
    local notificationData = NotificationData()
    notificationData.type = "MetaAchievementCompleted"
    notificationData.icon = string.format(self.iconPathPattern, data.icon)
    notificationData.title = "@ui_meta_achievements_unlocked"
    if not FtueSystemRequestBus.Broadcast.IsFtue() then
      notificationData.hasChoice = true
    end
    notificationData.contextId = self.entityId
    notificationData.declineTextOverride = "@ui_dismiss"
    notificationData.callbackName = "OnAcceptAchievementNotification"
    if numTitlesIds == 0 then
      notificationData.acceptTextOverride = "@ui_meta_achievements_view_detail"
      notificationData.text = data.title
    else
      notificationData.acceptTextOverride = "@ui_meta_achievements_claim_reward"
      if numTitlesIds == 1 then
        notificationData.text = data.title .. "\n" .. GetLocalizedReplacementText("@ui_meta_achievements_claim_reward_desc_one", {
          color = ColorRgbaToHexString(self.UIStyle.COLOR_YELLOW)
        })
      else
        notificationData.text = data.title .. "\n" .. GetLocalizedReplacementText("@ui_meta_achievements_claim_reward_desc_mult", {
          color = ColorRgbaToHexString(self.UIStyle.COLOR_YELLOW),
          number = numTitlesIds
        })
      end
    end
    UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
  end
end
function MetaAchievements:OnReceiveRewardPendingMetaAchievements(pendingMetaAchievementIds)
  local numPendingRewards = 0
  for i = 1, #pendingMetaAchievementIds do
    local id = pendingMetaAchievementIds[i]
    local titlesIds = JavMetaAchievementRequestBus.Broadcast.GetTitlesIdsForMetaAchievement(id)
    numPendingRewards = numPendingRewards + (titlesIds and #titlesIds or 0)
  end
  LyShineDataLayerBus.Broadcast.SetData("MetaAchievements.UnclaimedRewardCount", numPendingRewards)
  if numPendingRewards ~= 0 then
    for i = 1, #pendingMetaAchievementIds do
      local id = pendingMetaAchievementIds[i]
      local metaAchievementIdAndData = self.metaAchievementIdAndDataList[id]
      if metaAchievementIdAndData and metaAchievementIdAndData.category then
        local idAndDataList = self.categoryIdToMetaAchievementIdsAndData[metaAchievementIdAndData.category]
        self.pendingMetaAchievementData[i] = idAndDataList and idAndDataList[id] or nil
      end
    end
    local typeCount = UiNotificationsBus.Broadcast.GetNumNotificationsByType("RewardPendingMetaAchievements")
    if typeCount < self.MAX_ACTIVE_NOTIFICATIONS then
      local notificationData = NotificationData()
      notificationData.type = "RewardPendingMetaAchievements"
      notificationData.title = "@ui_meta_achievements_rewards_available"
      notificationData.hasChoice = true
      notificationData.contextId = self.entityId
      notificationData.declineTextOverride = "@ui_dismiss"
      notificationData.callbackName = "OnAcceptAchievementNotification"
      if numPendingRewards == 1 then
        notificationData.text = GetLocalizedReplacementText("@ui_meta_achievements_rewards_available_desc_one", {
          color = ColorRgbaToHexString(self.UIStyle.COLOR_YELLOW)
        })
        notificationData.acceptTextOverride = "@ui_meta_achievements_claim_reward"
      else
        notificationData.text = GetLocalizedReplacementText("@ui_meta_achievements_rewards_available_desc_mult", {
          color = ColorRgbaToHexString(self.UIStyle.COLOR_YELLOW),
          number = numPendingRewards
        })
        notificationData.acceptTextOverride = "@ui_meta_achievements_claim_rewards"
      end
      UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
    end
  else
    self.pendingMetaAchievementData = {}
  end
end
function MetaAchievements:OnAcceptAchievementNotification(notificationId, isAccepted)
  if isAccepted and self.acceptAchievementNotificationCallbackFunction then
    if LyShineManagerBus.Broadcast.IsInState(849925872) or LyShineManagerBus.Broadcast.IsInState(921202721) or FtueSystemRequestBus.Broadcast.IsFtue() then
      local notificationData = NotificationData()
      notificationData.type = "Minor"
      notificationData.text = LyShineScriptBindRequestBus.Broadcast.LocalizeText("@ui_cannot_perform_action_at_this_time")
      notificationData.contextId = self.entityId
      notificationData.allowDuplicates = false
      UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
      return
    end
    self.acceptAchievementNotificationCallbackFunction(self.acceptAchievementNotificationCallbackTable)
  end
end
function MetaAchievements:SetAcceptAchievementNotificationCallback(callbackFn, callbackTable)
  self.acceptAchievementNotificationCallbackFunction = callbackFn
  self.acceptAchievementNotificationCallbackTable = callbackTable
end
function MetaAchievements:OnClaimRewards()
  JavMetaAchievementRequestBus.Broadcast.ClearPendingMetaAchievements()
  local typeCount = UiNotificationsBus.Broadcast.GetNumNotificationsByType("ClaimRewards")
  if typeCount < self.MAX_ACTIVE_NOTIFICATIONS then
    local notificationData = NotificationData()
    notificationData.type = "ClaimRewards"
    notificationData.title = "@ui_meta_achievements_rewards_claimed"
    notificationData.maximumDuration = 5
    local rewardCount = self.dataLayer:GetDataFromNode("MetaAchievements.UnclaimedRewardCount")
    if rewardCount == 1 then
      notificationData.text = "@ui_meta_achievements_rewards_claimed_desc_one"
    else
      notificationData.text = GetLocalizedReplacementText("@ui_meta_achievements_rewards_claimed_desc_mult", {number = rewardCount})
    end
    UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
  end
  JavMetaAchievementRequestBus.Broadcast.RequestSummaryPageInfo()
end
function MetaAchievements:GetTotal(fullMetaAchievementsData)
  return fullMetaAchievementsData.itemData.total
end
return MetaAchievements
