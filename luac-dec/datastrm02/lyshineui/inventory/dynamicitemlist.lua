local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
local Spawner = RequireScript("LyShineUI._Common.Spawner")
local InventoryFilter = RequireScript("LyShineUI.Inventory.InventoryFilter")
local timeHelpers = RequireScript("LyShineUI._Common.TimeHelperFunctions")
local itemCommon = RequireScript("LyShineUI._Common.ItemCommon")
local DynamicItemList = {
  Properties = {
    GenericSpawner = {
      default = EntityId(),
      order = 1
    },
    Content = {
      default = EntityId(),
      order = 2
    },
    Scrollbox = {
      default = EntityId(),
      order = 3
    },
    LootContainerSection = {
      default = EntityId(),
      order = 4
    },
    WeaponSection = {
      default = EntityId(),
      order = 4
    },
    ArmorSection = {
      default = EntityId(),
      order = 5
    },
    AmmoSection = {
      default = EntityId(),
      order = 6
    },
    ConsumableSection = {
      default = EntityId(),
      order = 7
    },
    BaitSection = {
      default = EntityId(),
      order = 8
    },
    ToolsSection = {
      default = EntityId(),
      order = 9
    },
    MaterialSection = {
      default = EntityId(),
      order = 10
    },
    DyeSection = {
      default = EntityId(),
      order = 11
    },
    LoreSection = {
      default = EntityId(),
      order = 12
    },
    RepairKitSection = {
      default = EntityId(),
      order = 13
    },
    CookingSection = {
      default = EntityId(),
      order = 14
    },
    FurnitureSection = {
      default = EntityId(),
      order = 15
    },
    CraftingModifiersSection = {
      default = EntityId(),
      order = 16
    },
    OutpostRushSection = {
      default = EntityId(),
      order = 17
    },
    AlchemySection = {
      default = EntityId(),
      order = 18
    },
    TuningOrbSection = {
      default = EntityId(),
      order = 19
    },
    QuestSection = {
      default = EntityId(),
      order = 20
    },
    JewelSection = {
      default = EntityId(),
      order = 21
    },
    RefiningSection = {
      default = EntityId(),
      order = 22
    },
    AttributeFoodSection = {
      default = EntityId(),
      order = 23
    },
    SmeltingSection = {
      default = EntityId(),
      order = 24
    },
    TradeSkillFoodSection = {
      default = EntityId(),
      order = 25
    },
    LeatherworkingSection = {
      default = EntityId(),
      order = 26
    },
    WeavingSection = {
      default = EntityId(),
      order = 27
    },
    WoodworkingSection = {
      default = EntityId(),
      order = 28
    },
    StonecuttingSection = {
      default = EntityId(),
      order = 29
    },
    BasicFoodSection = {
      default = EntityId(),
      order = 30
    },
    ItemSlice = {
      default = "LyShineUI/Slices/ItemDraggable",
      order = 31
    },
    CachedItems = {
      default = EntityId(),
      order = 32
    },
    PrototypeItem = {
      default = EntityId(),
      order = 33
    },
    SortAndFilterBar = {
      default = EntityId(),
      order = 34
    },
    FilterInput = {
      default = EntityId(),
      order = 35
    },
    FilterText = {
      default = EntityId(),
      order = 36
    },
    SortByChrono = {
      default = EntityId(),
      order = 37
    },
    SortByGearScore = {
      default = EntityId(),
      order = 38
    },
    SortByTier = {
      default = EntityId(),
      order = 39
    },
    SortByWeight = {
      default = EntityId(),
      order = 40
    },
    ClearFilter = {
      default = EntityId(),
      order = 41
    },
    SearchIcon = {
      default = EntityId(),
      order = 42
    },
    Placeholder = {
      default = EntityId(),
      order = 43
    },
    QuestionMark = {
      default = EntityId(),
      order = 44
    },
    SearchBarBg = {
      default = EntityId(),
      order = 45
    }
  },
  contentCache = {},
  mPendingItemSpawns = 0,
  mContainerTable = nil,
  mIsInventoryContainer = false,
  mIsMapStorageContainer = false,
  mWidth = nil,
  mHeight = nil,
  mUseSections = true,
  mSpawnCallback = nil,
  mSpawnTable = nil,
  transferAllCallback = nil,
  transferAllCaller = nil,
  onTickBudgetMs = 0,
  onTickMinimumToProcess = 1,
  mMaxCachedItems = 500
}
BaseElement:CreateNewElement(DynamicItemList)
Spawner:AttachSpawner(DynamicItemList)
function DynamicItemList:OnInit()
  BaseElement.OnInit(self)
  self.canvasId = UiElementBus.Event.GetCanvas(self.entityId)
  self:BusConnect(UiSpawnerNotificationBus, self.GenericSpawner)
  self:BusConnect(UiScrollBoxNotificationBus, self.Properties.Scrollbox)
  self.mWidth = UiTransform2dBus.Event.GetLocalWidth(self.entityId)
  self.mHeight = UiTransform2dBus.Event.GetLocalHeight(self.entityId)
  self:SetSize(self.mWidth, self.mHeight)
  self.sectionInfos = {
    {
      section = self.OutpostRushSection,
      entityId = self.Properties.OutpostRushSection,
      leftCol = true,
      class = eItemClass_UI_OutpostRush,
      headerText = itemCommon:GetItemClassName(eItemClass_UI_OutpostRush),
      setHiddenWhenEmpty = true
    },
    {
      section = self.LootContainerSection,
      entityId = self.Properties.LootContainerSection,
      leftCol = true,
      class = eItemClass_LootContainer,
      headerText = itemCommon:GetItemClassName(eItemClass_LootContainer),
      setHiddenWhenEmpty = true
    },
    {
      section = self.WeaponSection,
      entityId = self.Properties.WeaponSection,
      leftCol = true,
      class = eItemClass_UI_Weapon,
      headerText = itemCommon:GetItemClassName(eItemClass_UI_Weapon)
    },
    {
      section = self.ArmorSection,
      entityId = self.Properties.ArmorSection,
      leftCol = true,
      class = eItemClass_UI_Armor,
      headerText = itemCommon:GetItemClassName(eItemClass_UI_Armor)
    },
    {
      section = self.AmmoSection,
      entityId = self.Properties.AmmoSection,
      leftCol = true,
      class = eItemClass_UI_Ammo,
      headerText = itemCommon:GetItemClassName(eItemClass_UI_Ammo)
    },
    {
      section = self.ConsumableSection,
      entityId = self.Properties.ConsumableSection,
      leftCol = true,
      class = eItemClass_UI_Consumable,
      headerText = itemCommon:GetItemClassName(eItemClass_UI_Consumable)
    },
    {
      section = self.BasicFoodSection,
      entityId = self.Properties.BasicFoodSection,
      leftCol = true,
      class = eItemClass_UI_BasicFood,
      headerText = itemCommon:GetItemClassName(eItemClass_UI_BasicFood)
    },
    {
      section = self.AttributeFoodSection,
      entityId = self.Properties.AttributeFoodSection,
      leftCol = true,
      class = eItemClass_UI_AttributeFood,
      headerText = itemCommon:GetItemClassName(eItemClass_UI_AttributeFood)
    },
    {
      section = self.TradeSkillFoodSection,
      entityId = self.Properties.TradeSkillFoodSection,
      leftCol = true,
      class = eItemClass_UI_TradeSkillFood,
      headerText = itemCommon:GetItemClassName(eItemClass_UI_TradeSkillFood)
    },
    {
      section = self.RepairKitSection,
      entityId = self.Properties.RepairKitSection,
      leftCol = true,
      class = eItemClass_UI_RepairKit,
      headerText = itemCommon:GetItemClassName(eItemClass_UI_RepairKit)
    },
    {
      section = self.CookingSection,
      entityId = self.Properties.CookingSection,
      leftCol = true,
      class = eItemClass_UI_Cooking,
      headerText = itemCommon:GetItemClassName(eItemClass_UI_Cooking)
    },
    {
      section = self.BaitSection,
      entityId = self.Properties.BaitSection,
      leftCol = true,
      class = eItemClass_UI_Bait,
      headerText = itemCommon:GetItemClassName(eItemClass_UI_Bait)
    },
    {
      section = self.CraftingModifiersSection,
      entityId = self.Properties.CraftingModifiersSection,
      leftCol = true,
      class = eItemClass_UI_CraftingModifiers,
      headerText = itemCommon:GetItemClassName(eItemClass_UI_CraftingModifiers)
    },
    {
      section = self.MaterialSection,
      entityId = self.Properties.MaterialSection,
      leftCol = true,
      class = eItemClass_UI_Material,
      headerText = itemCommon:GetItemClassName(eItemClass_UI_Material)
    },
    {
      section = self.ToolsSection,
      entityId = self.Properties.ToolsSection,
      leftCol = false,
      class = eItemClass_UI_Tools,
      headerText = itemCommon:GetItemClassName(eItemClass_UI_Tools)
    },
    {
      section = self.TuningOrbSection,
      entityId = self.Properties.TuningOrbSection,
      leftCol = false,
      class = eItemClass_UI_TuningOrbs,
      headerText = itemCommon:GetItemClassName(eItemClass_UI_TuningOrbs)
    },
    {
      section = self.JewelSection,
      entityId = self.Properties.JewelSection,
      leftCol = false,
      class = eItemClass_UI_JewelCrafting,
      headerText = itemCommon:GetItemClassName(eItemClass_UI_JewelCrafting)
    },
    {
      section = self.RefiningSection,
      entityId = self.Properties.RefiningSection,
      leftCol = false,
      class = eItemClass_UI_Refining,
      headerText = itemCommon:GetItemClassName(eItemClass_UI_Refining)
    },
    {
      section = self.SmeltingSection,
      entityId = self.Properties.SmeltingSection,
      leftCol = false,
      class = eItemClass_UI_Smelting,
      headerText = itemCommon:GetItemClassName(eItemClass_UI_Smelting)
    },
    {
      section = self.LeatherworkingSection,
      entityId = self.Properties.LeatherworkingSection,
      leftCol = false,
      class = eItemClass_UI_Leatherworking,
      headerText = itemCommon:GetItemClassName(eItemClass_UI_Leatherworking)
    },
    {
      section = self.WeavingSection,
      entityId = self.Properties.WeavingSection,
      leftCol = false,
      class = eItemClass_UI_Weaving,
      headerText = itemCommon:GetItemClassName(eItemClass_UI_Weaving)
    },
    {
      section = self.WoodworkingSection,
      entityId = self.Properties.WoodworkingSection,
      leftCol = false,
      class = eItemClass_UI_Woodworking,
      headerText = itemCommon:GetItemClassName(eItemClass_UI_Woodworking)
    },
    {
      section = self.StonecuttingSection,
      entityId = self.Properties.StonecuttingSection,
      leftCol = false,
      class = eItemClass_UI_Stonecutting,
      headerText = itemCommon:GetItemClassName(eItemClass_UI_Stonecutting)
    },
    {
      section = self.AlchemySection,
      entityId = self.Properties.AlchemySection,
      leftCol = false,
      class = eItemClass_UI_Alchemy,
      headerText = itemCommon:GetItemClassName(eItemClass_UI_Alchemy)
    },
    {
      section = self.DyeSection,
      entityId = self.Properties.DyeSection,
      leftCol = false,
      class = eItemClass_UI_Dye,
      headerText = itemCommon:GetItemClassName(eItemClass_UI_Dye)
    },
    {
      section = self.FurnitureSection,
      entityId = self.Properties.FurnitureSection,
      leftCol = false,
      class = eItemClass_UI_Furniture,
      headerText = itemCommon:GetItemClassName(eItemClass_UI_Furniture)
    },
    {
      section = self.QuestSection,
      entityId = self.Properties.QuestSection,
      leftCol = false,
      class = eItemClass_UI_Quest,
      headerText = itemCommon:GetItemClassName(eItemClass_UI_Quest)
    },
    {
      section = self.LoreSection,
      entityId = self.Properties.LoreSection,
      leftCol = false,
      class = eItemClass_UI_Lore,
      headerText = itemCommon:GetItemClassName(eItemClass_UI_Lore)
    }
  }
  for _, sectionInfo in ipairs(self.sectionInfos) do
    sectionInfo.section:SetHiddenWhenEmpty(sectionInfo.setHiddenWhenEmpty)
  end
  self.updateRequestsHi = {}
  self.updateRequestsLo = {}
  self.dataLayer:RegisterObserver(self, "UIFeatures.g_uiItemBreadcrumbsActive", function(self, dataNode)
    self.enableBreadcrumbs = dataNode:GetData()
  end)
  self.enableBreadcrumbs = self.dataLayer:GetDataNode("UIFeatures.g_uiItemBreadcrumbsActive"):GetData()
  if self.enableBreadcrumbs then
    Debug.Log("DynamicItemList OnActivate")
  end
  self.dataLayer:RegisterAndExecuteDataObserver(self, "UIFeatures.g_showInventoryDocuments", function(self, shouldShow)
    self.showDocuments = shouldShow
    if self.Properties.LoreSection:IsValid() then
      UiElementBus.Event.SetIsEnabled(self.Properties.LoreSection, self.showDocuments)
    end
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.PlayerEntityId", function(self, playerEntityId)
    self.playerEntityId = playerEntityId
  end)
  self.filter = InventoryFilter.new()
  local lineDuration = 1.2
  local lineAlpha = 1
  for i, sectionInfo in ipairs(self.sectionInfos) do
    if sectionInfo.entityId:IsValid() then
      sectionInfo.section.filter = self.filter
      sectionInfo.section:SetTransferAllInfo(self, self.CatSectionCanTransferAll, self.OnCatSectionTransferAll, sectionInfo.class)
      sectionInfo.section.Header:SetText(sectionInfo.headerText)
      sectionInfo.section.Header:SetLineVisible(true, lineDuration)
      sectionInfo.section.Header:SetLineAlpha(lineAlpha)
      sectionInfo.section.Header:SetLineColor(self.UIStyle.COLOR_TAN_LIGHT)
    end
  end
  if self.Properties.PrototypeItem:IsValid() then
    self.prototypeItemEntityId = self.Properties.PrototypeItem
    UiElementBus.Event.SetIsEnabled(self.prototypeItemEntityId, false)
    self:OnPrototypeItemSpawned(self.prototypeItemEntityId, nil)
  else
    self:SpawnSlice(self.GenericSpawner, self.ItemSlice, self.OnPrototypeItemSpawned, nil)
  end
  self.dataLayer:RegisterAndExecuteDataObserver(self, "UIFeatures.g_uiEnableInventorySortAndFilter", function(self, shouldShow)
    self.allowSortAndFilter = shouldShow
    if self.Properties.SortAndFilterBar:IsValid() then
      UiElementBus.Event.SetIsEnabled(self.Properties.SortAndFilterBar, self.allowSortAndFilter)
    end
  end)
  self.SortByChrono:SetTooltip("@ui_sort_chrono", 2)
  self.SortByGearScore:SetTooltip("@ui_sort_gearscore", 2)
  self.SortByWeight:SetTooltip("@ui_sort_weight", 2)
  self.SortByTier:SetTooltip("@ui_sort_tier", 2)
  self.QuestionMark:SetTooltip("@ui_filterDescription")
  self.QuestionMark:SetButtonStyle(self.QuestionMark.BUTTON_STYLE_QUESTION_MARK)
  self:BusConnect(DynamicBus.UITickBus)
end
function DynamicItemList:SetSortAndFilterPosY(value)
  self.ScriptedEntityTweener:Set(self.Properties.SortAndFilterBar, {y = value})
end
function DynamicItemList:OnShutdown()
end
function DynamicItemList:SetUseSections(useSections)
  self.mUseSections = useSections
end
function DynamicItemList:OnSortByChrono()
  self.filter:SetSortBy(self.filter.SORT_BY_CHRONO)
  self.needUpdateSizes = true
end
function DynamicItemList:OnSortByGearScore()
  self.filter:SetSortBy(self.filter.SORT_BY_GEARSCORE)
  self.needUpdateSizes = true
end
function DynamicItemList:OnSortByWeight()
  self.filter:SetSortBy(self.filter.SORT_BY_WEIGHT)
  self.needUpdateSizes = true
end
function DynamicItemList:OnSortByTier()
  self.filter:SetSortBy(self.filter.SORT_BY_TIER)
  self.needUpdateSizes = true
end
function DynamicItemList:OnClearFilter()
  UiTextBus.Event.SetText(self.Properties.FilterText, "")
  self.filter:ParseFilterText("")
  self.needUpdateSizes = true
end
function DynamicItemList:OnEnterFilter()
  SetActionmapsForTextInput(self.canvasId, true)
  UiElementBus.Event.SetIsEnabled(self.Properties.ClearFilter, true)
  UiElementBus.Event.SetIsEnabled(self.Properties.QuestionMark, false)
end
function DynamicItemList:OnExitFilter()
  SetActionmapsForTextInput(self.canvasId, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.ClearFilter, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.QuestionMark, true)
end
function DynamicItemList:OnFilterInputChange()
  local filterText = UiTextBus.Event.GetText(self.Properties.FilterText)
  self.filter:ParseFilterText(filterText)
  self.needUpdateSizes = true
end
function DynamicItemList:SetSize(width, height)
  self.mWidth = width
  self.mHeight = height
  UiTransform2dBus.Event.SetLocalWidth(self.Properties.Scrollbox, self.mWidth)
  UiTransform2dBus.Event.SetLocalHeight(self.Properties.Scrollbox, self.mHeight)
end
function DynamicItemList:SetGlobalStorageId(id)
  self.mIsMapStorageContainer = true
  self.globalStorageId = id
  if self.containerBus then
    self:BusDisconnect(self.containerBus)
    self.containerBus = nil
  end
  self.containerId = nil
  if not self.mIsInventoryContainer then
    for k, sectionInfo in pairs(self.sectionInfos) do
      sectionInfo.section:SetGlobalStorageId(id)
    end
  end
end
function DynamicItemList:SetContainer(containerId, containerTable)
  if self.containerBus then
    self:BusDisconnect(self.containerBus)
    self.containerBus = nil
  end
  self.mContainerTable = containerTable
  self.containerId = containerId
  self.globalStorageId = nil
  if self.containerId and self.containerId:IsValid() then
    self.containerBus = self:BusConnect(ContainerEventBus, self.containerId)
  end
  self.dirtySlots = true
  ClearTable(self.updateRequestsHi)
  ClearTable(self.updateRequestsLo)
  local inventoryId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.InventoryEntityId")
  self.mIsInventoryContainer = inventoryId == containerId
  if not self.mIsInventoryContainer then
    for k, sectionInfo in pairs(self.sectionInfos) do
      sectionInfo.section:ClearAll()
    end
  end
end
function DynamicItemList:SetSpawnableSlice(sliceName)
  self.ItemSlice = sliceName
end
function DynamicItemList:SetSpawnCallback(command, table)
  self.mSpawnCallback = command
  self.mSpawnTable = table
end
function DynamicItemList:ExecuteSpawnCallback(entity)
  if self.mSpawnCallback ~= nil and self.mSpawnTable ~= nil then
    if type(self.mSpawnCallback) == "function" then
      self.mSpawnCallback(self.mSpawnTable, entity)
    elseif type(self.mSpawnTable[self.mSpawnCallback]) == "function" then
      self.mSpawnTable[self.mSpawnCallback](self.mSpawnTable, entity)
    end
  end
end
function DynamicItemList:UpdateLists()
  if self.enableBreadcrumbs then
    Debug.Log("DynamicItemList:UpdateLists")
  end
  local numAvailableSlots = 0
  if self.containerId and self.containerId:IsValid() then
    numAvailableSlots = ContainerRequestBus.Event.GetNumSlots(self.containerId) or 0
    for slotId = 0, numAvailableSlots - 1 do
      local slot = ContainerRequestBus.Event.GetSlot(self.containerId, tostring(slotId))
      self:QueueSlotUpdate(false, slotId, nil)
    end
  elseif self.globalStorageId and self.globalStorageId ~= "" then
    local slots = GlobalStorageRequestBus.Event.GetStorageContents(self.playerEntityId, self.globalStorageId)
    numAvailableSlots = #slots or 0
    for i = 1, numAvailableSlots do
      self:DoSlotUpdate(i, slots[i])
    end
  else
    Log("WARNING: DynamicItemList:UpdateLists() - need to set a valid containerId or globalStorageId for this dynamic item list.")
    return
  end
  if numAvailableSlots < (self.availableSlotsCount or 0) then
    for slotId = numAvailableSlots, self.availableSlotsCount - 1 do
      self:QueueSlotUpdate(false, slotId, nil)
    end
  end
  self.availableSlotsCount = numAvailableSlots
  self.dirtySlots = false
  self.needUpdateSizes = true
end
function DynamicItemList:UpdateSizes()
  if self.enableBreadcrumbs then
    Debug.Log("DynamicItemList UpdateSizes")
  end
  local currentPosition = UiScrollBoxBus.Event.GetScrollOffset(self.Properties.Scrollbox)
  self.totalItems = 0
  local spawnedCount = 0
  local leftHeight, rightHeight
  for k, sectionInfo in ipairs(self.sectionInfos) do
    if sectionInfo.entityId:IsValid() then
      local leftItems = 0
      local rightItems = 0
      if sectionInfo.leftCol then
        leftHeight, leftItems = sectionInfo.section:SetTop(leftHeight)
      else
        rightHeight, rightItems = sectionInfo.section:SetTop(rightHeight)
      end
      self.totalItems = self.totalItems + leftItems + rightItems
    end
  end
  if self.mContainerTable and self.mContainerTable.OnContainerItemCountChange then
    local spawningCount = self:GetNumSpawning()
    if spawningCount == 0 and not self:AreQueuesEmpty() then
      spawningCount = 1
    end
    self.mContainerTable:OnContainerItemCountChange(spawnedCount + spawningCount)
  end
  local overAllListHeight = math.max(leftHeight, rightHeight)
  UiTransform2dBus.Event.SetLocalHeight(self.Properties.Content, overAllListHeight)
  UiScrollBoxBus.Event.SetScrollOffset(self.Properties.Scrollbox, currentPosition)
end
function DynamicItemList:OnTransitionIn(fromState, fromLevel, toState, toLevel)
  if self.enableBreadcrumbs then
    Debug.Log("DynamicItemList:OnTransitionIn")
  end
  if self.dirtySlots and self.containerId and self.containerId:IsValid() and (fromState ~= 2972535350 or toState ~= 3349343259) then
    self.disableItemMove = true
    self:UpdateLists()
    self.disableItemMove = false
  end
  self.onTickBudgetMs = 1
  self.onTickMinimumToProcess = 10
end
function DynamicItemList:OnTransitionOut(fromState, fromLevel, toState, toLevel)
  if self.enableBreadcrumbs then
    Debug.Log("DynamicItemList:OnTransitionOut")
  end
  self.onTickBudgetMs = 0
  self.onTickMinimumToProcess = 1
end
function DynamicItemList:ClearList()
  if self.enableBreadcrumbs then
    Debug.Log("DynamicItemList:ClearList")
  end
  for k, sectionInfo in pairs(self.sectionInfos) do
    sectionInfo.section:ClearAll()
  end
  self.availableSlotsCount = 0
  self.needUpdateSizes = true
end
function DynamicItemList:OnContainerSlotChanged(slotNum, newItemDescriptor, oldItemDescriptor)
  self:QueueSlotUpdate(true, slotNum, nil)
end
function DynamicItemList:OnSlotUpdate(localSlotId, itemSlot, action)
  self.dirtySlots = true
  self:QueueSlotUpdate(false, localSlotId, action)
end
function DynamicItemList:GetNumberItems()
  return self.totalItems
end
function DynamicItemList:AreQueuesEmpty()
  for k, request in pairs(self.updateRequestsHi) do
    return false
  end
  for k, request in pairs(self.updateRequestsLo) do
    return false
  end
  return true
end
function DynamicItemList:OnTick(delta, timePoint)
  local requestsProcessed = 0
  local now = timeHelpers:ServerNow()
  local timeSpentMs = 0
  while timeSpentMs < self.onTickBudgetMs or requestsProcessed < self.onTickMinimumToProcess do
    local k, request = next(self.updateRequestsHi)
    if not request then
      k, request = next(self.updateRequestsLo)
    end
    if request then
      requestsProcessed = requestsProcessed + 1
      self.updateRequestsHi[request.localSlotId] = nil
      self.updateRequestsLo[request.localSlotId] = nil
      self.needUpdateSizes = true
      self:DoSlotUpdateById(request.localSlotId)
    else
      break
    end
    timeSpentMs = timeHelpers:ServerNow():Subtract(now):ToMillisecondsUnrounded()
  end
  if self.needUpdateSizes and requestsProcessed == 0 then
    self:UpdateSizes()
    self:UpdateOnScreenItems()
    self.needUpdateSizes = false
    UiCanvasBus.Event.QueueHoverInteractableReset(self.canvasId)
  elseif not self.needUpdateSizes then
    local scrollOffset = UiScrollBoxBus.Event.GetScrollOffset(self.Properties.Scrollbox)
    if scrollOffset.y ~= self.lastScrollOffsetY then
      self.needUpdateSizes = true
    end
  end
end
function DynamicItemList:QueueSlotUpdate(highPriority, localSlotId, action)
  if self.containerId then
    local updateRequest = {localSlotId = localSlotId, action = action}
    if highPriority then
      self.updateRequestsLo[localSlotId] = nil
      self.updateRequestsHi[localSlotId] = updateRequest
    elseif not self.updateRequestsHi[localSlotId] then
      self.updateRequestsLo[localSlotId] = updateRequest
    end
  end
end
function DynamicItemList:DoSlotUpdateById(localSlotId)
  local slot = ContainerRequestBus.Event.GetSlot(self.containerId, tostring(localSlotId))
  self:DoSlotUpdate(localSlotId, slot)
end
function DynamicItemList:DoSlotUpdate(localSlotId, slot)
  for _, sectionInfo in pairs(self.sectionInfos) do
    sectionInfo.section:DoSlotUpdate(localSlotId, slot, self.mUseSections)
  end
  self.needUpdateSizes = true
end
function DynamicItemList:OnScrollOffsetChanged(offset)
  DynamicBus.ConfirmationPopup.Broadcast.HideConfirmationPopup()
  self:UpdateOnScreenItems(offset)
end
function DynamicItemList:PrepareItemEntity(itemEntityId)
  local itemTable = self.registrar:GetEntityTable(itemEntityId)
  local itemLayout
  if itemTable.ItemLayout == nil then
    itemLayout = itemTable
    itemTable:ConnectContainerBus(itemTable.entityId)
    itemTable:SetTooltipEnabled(true)
  else
    itemLayout = itemTable.ItemLayout
  end
  if self.mIsInventoryContainer then
    itemTable:SetIsInInventory(true)
    itemTable:SetModeType(itemLayout.MODE_TYPE_INVENTORY)
  else
    itemTable:SetModeType(itemLayout.MODE_TYPE_CONTAINER)
    itemTable.containerTable = self.mContainerTable
    if self.mIsMapStorageContainer then
      itemTable:SetIsInMapStorageContainer(true)
    end
  end
end
function DynamicItemList:RequestItemSpawn()
  if #self.contentCache > 0 then
    local itemEntityId = table.remove(self.contentCache)
    self:SetItemIsShowing(itemEntityId, true)
    return itemEntityId
  end
  if self.Properties.CachedItems then
    local numChildren = UiElementBus.Event.GetNumChildElements(self.Properties.CachedItems)
    if numChildren and 0 < numChildren then
      local itemEntityId = UiElementBus.Event.GetChild(self.Properties.CachedItems, 0)
      UiElementBus.Event.Reparent(itemEntityId, self.Properties.Content, EntityId())
      self:PrepareItemEntity(itemEntityId)
      UiElementBus.Event.SetIsEnabled(itemEntityId, false)
      self:SetItemIsShowing(itemEntityId, true)
      return itemEntityId
    end
  end
  if self.prototypeItemEntityId then
    local name = UiCanvasBus.Event.GetCanvasName(self.canvasId)
    Log("WARNING: Cloning draggable item in DynamicItemList in '%s' canvas. Consider increasing cache size.", name)
    local itemTable = CloneUiElement(self.canvasId, self.registrar, self.prototypeItemEntityId, self.Properties.Content, false)
    self:PrepareItemEntity(itemTable.entityId)
    self:SetItemIsShowing(itemTable.entityId, true)
    return itemTable.entityId
  end
  Debug.Log("WARNING: No Prototype item found in DynamicItemList:RequestItemSpawn! Returning nil.")
  return nil
end
function DynamicItemList:OnPrototypeItemSpawned(entity, spawnData)
  if type(entity) == "table" then
    self.prototypeItemEntityId = entity.entityId
  else
    self.prototypeItemEntityId = entity
  end
  UiElementBus.Event.SetIsEnabled(self.prototypeItemEntityId, false)
  if self.Properties.CachedItems:IsValid() then
    local count = UiElementBus.Event.GetNumChildElements(self.Properties.CachedItems)
    local itemsNeeded = 8 * (math.ceil(UiTransform2dBus.Event.GetLocalHeight(self.Properties.Scrollbox) / 60) + 2)
    for i = count, itemsNeeded do
      local itemTable = CloneUiElement(self.canvasId, self.registrar, self.prototypeItemEntityId, self.Properties.CachedItems, false)
    end
    if count < itemsNeeded then
      local name = UiCanvasBus.Event.GetCanvasName(self.canvasId)
      Log("WARNING: Cloning %d draggable item in DynamicItemList in '%s' canvas. Consider increasing cache size.", itemsNeeded - count, name)
    end
  end
end
function DynamicItemList:ReturnItemSpawn(itemEntityId)
  UiElementBus.Event.SetIsEnabled(itemEntityId, false)
  table.insert(self.contentCache, itemEntityId)
  self:SetItemIsShowing(itemEntityId, false)
end
function DynamicItemList:SetItemIsShowing(itemEntityId, isShowing)
  local itemTable = self.registrar:GetEntityTable(itemEntityId)
  if itemTable then
    itemTable:SetItemIsShowing(isShowing)
    if isShowing then
      itemTable.containerId = self.containerId
    else
      itemTable:OnReturnedToCache()
    end
  end
end
function DynamicItemList:UpdateOnScreenItems(scroll)
  scroll = scroll or UiScrollBoxBus.Event.GetScrollOffset(self.Properties.Scrollbox)
  self.lastScrollOffsetY = scroll.y
  local scrollHeight = UiTransform2dBus.Event.GetLocalHeight(self.Properties.Scrollbox)
  for _, sectionInfo in pairs(self.sectionInfos) do
    sectionInfo.section:UpdateOnScreenItems(scroll, scrollHeight)
  end
end
function DynamicItemList:SetRepairAllEnabled(enabled)
  for k, sectionInfo in ipairs(self.sectionInfos) do
    if sectionInfo.entityId:IsValid() then
      sectionInfo.section:SetRepairAllEnabled(enabled)
    end
  end
end
function DynamicItemList:SetTransferAllInfo(caller, canTransferAllFn, transferAllFn, buttonText, direction)
  self.transferAllCaller = caller
  self.canTransferAllCallback = canTransferAllFn
  self.transferAllCallback = transferAllFn
  for k, sectionInfo in ipairs(self.sectionInfos) do
    if sectionInfo.entityId:IsValid() then
      sectionInfo.section:SetTransferAllText(buttonText)
      sectionInfo.section:SetButtonArrowDirection(direction)
      sectionInfo.section:UpdateEnabledState()
    end
  end
end
function DynamicItemList:CatSectionCanTransferAll(itemClass)
  if self.transferAllCaller and type(self.canTransferAllCallback) == "function" then
    return self.canTransferAllCallback(self.transferAllCaller, itemClass)
  end
  return false
end
function DynamicItemList:OnCatSectionTransferAll(itemClass)
  if self.transferAllCaller and type(self.transferAllCallback) == "function" then
    self.transferAllCallback(self.transferAllCaller, itemClass)
  end
end
function DynamicItemList:OnHoverSearchBar()
  self.ScriptedEntityTweener:Play(self.Properties.Placeholder, 0.1, {
    textColor = self.UIStyle.COLOR_WHITE
  })
  self.ScriptedEntityTweener:Play(self.Properties.SearchIcon, 0.1, {
    imgColor = self.UIStyle.COLOR_WHITE
  })
  self.ScriptedEntityTweener:Play(self.Properties.SearchBarBg, 0.1, {opacity = 1})
  self.audioHelper:PlaySound(self.audioHelper.OnHover_ButtonSimpleText)
end
function DynamicItemList:OnUnhoverSearchBar()
  self.ScriptedEntityTweener:Play(self.Properties.Placeholder, 0.1, {
    textColor = self.UIStyle.COLOR_GRAY_50
  })
  self.ScriptedEntityTweener:Play(self.Properties.SearchIcon, 0.1, {
    imgColor = self.UIStyle.COLOR_TAN
  })
  self.ScriptedEntityTweener:Play(self.Properties.SearchBarBg, 0.1, {opacity = 0.9})
end
function DynamicItemList:OnHoverClearFilter()
  UiImageBus.Event.SetSpritePathname(self.Properties.ClearFilter, "LyShineUI/Images/socialpane/icon_clear_field_highlight.png")
  self.ScriptedEntityTweener:Play(self.Properties.ClearFilter, 0.1, {scaleX = 1.1, scaleY = 1.1})
  self.audioHelper:PlaySound(self.audioHelper.OnHover_ButtonSimpleText)
end
function DynamicItemList:OnUnhoverClearFilter()
  UiImageBus.Event.SetSpritePathname(self.Properties.ClearFilter, "LyShineUI/Images/socialpane/icon_clear_field.png")
  self.ScriptedEntityTweener:Play(self.Properties.ClearFilter, 0.1, {scaleX = 1, scaleY = 1})
end
return DynamicItemList
