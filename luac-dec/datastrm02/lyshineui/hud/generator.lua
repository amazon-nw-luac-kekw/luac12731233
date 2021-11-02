local Generator = {
  Properties = {
    FrameMultiBg = {
      default = EntityId()
    },
    PrimaryTitle = {
      default = EntityId()
    },
    ListItemHeader = {
      default = EntityId()
    },
    WeightBar = {
      default = EntityId()
    },
    MaxCapacityText = {
      default = EntityId()
    },
    ItemGeneratingText = {
      default = EntityId()
    },
    ButtonTakeAll = {
      default = EntityId()
    },
    TimeRemaining = {
      default = EntityId()
    },
    IconFrames = {
      default = EntityId()
    },
    EmptyFrame = {
      default = EntityId()
    },
    ItemGenerationBar = {
      default = EntityId()
    },
    ItemGenerationBarFill = {
      default = EntityId()
    },
    ItemGenerationBarPulseMask = {
      default = EntityId()
    },
    ItemGenerationBarPulse = {
      default = EntityId()
    },
    LineHorizontal = {
      default = EntityId()
    }
  },
  itemGenerationBarInitWidth = 479,
  itemGenerationBarPulseWidth = 35,
  containerEntity = nil,
  generatorEntity = nil,
  structureStateOn = false,
  generatorName = nil
}
local BaseScreen = RequireScript("LyShineUI._Common.BaseScreen")
BaseScreen:CreateNewScreen(Generator)
local ClickRecognizer = require("LyShineUI._Common.ClickRecognizer")
function Generator:OnInit()
  BaseScreen.OnInit(self)
  self:SetVisualElements()
  ClickRecognizer:OnActivate(self, "ItemUpdateDragData", "ItemInteract", self.OnDoubleClick, nil, nil)
  self:BusConnect(GeneratorScreenRequestBus)
end
function Generator:StartTick()
  if not self.tickHandler then
    self.tickHandler = self:BusConnect(DynamicBus.UITickBus)
  end
end
function Generator:StopTick()
  self:BusDisconnect(self.tickHandler)
  self.tickHandler = nil
end
function Generator:SetVisualElements()
  SetTextStyle(self.ItemGeneratingText, self.UIStyle.FONT_STYLE_GENERATOR_INFO)
  SetTextStyle(self.MaxCapacityText, self.UIStyle.FONT_STYLE_GENERATOR_INFO)
  SetTextStyle(self.TimeRemaining, self.UIStyle.FONT_STYLE_GENERATOR_INFO)
  SetTextStyle(self.PrimaryTitle, self.UIStyle.FONT_STYLE_INVENTORY_PRIMARY_TITLE)
  self.ListItemHeader:SetText("@ui_output")
  self.ListItemHeader:SetIconVisible(false)
  self.ListItemHeader:SetLineVisible(true)
  self.ListItemHeader:SetLineAlpha(0.3)
  self.WeightBar:SetWeightIcon(false)
  self.WeightBar:SetOverageText("@ui_generator_over_weight_limit")
  self.WeightBar:SetMaxOveragePercent(0.03)
  self.ButtonTakeAll:SetText("@interact_takeAll")
  self.ButtonTakeAll:SetCallback("GeneratorTakeAll", self)
  self.ButtonTakeAll:SetBackgroundOpacity(0.2)
  local colorLine = self.UIStyle.COLOR_TAN_LIGHT
  self.LineHorizontal:SetColor(colorLine)
  local alphaLine = 0.7
  self.ScriptedEntityTweener:Set(self.Properties.LineHorizontal, {opacity = alphaLine})
end
function Generator:SetTextMessages()
  local generatorName = ItemGeneratorRequestsBus.Event.GetBuildableDisplayName(self.generatorEntity)
  UiTextBus.Event.SetTextWithFlags(self.PrimaryTitle, generatorName, eUiTextSet_SetLocalized)
  local itemName = ItemGeneratorRequestsBus.Event.GetOutputItemName(self.generatorEntity)
  local quantity = ItemGeneratorRequestsBus.Event.GetOutputQuantity(self.generatorEntity)
  local descriptor = ItemDescriptor()
  descriptor.itemId = Math.CreateCrc32(itemName)
  local keys1 = vector_basic_string_char_char_traits_char()
  local values1 = vector_basic_string_char_char_traits_char()
  keys1:push_back("quantity")
  keys1:push_back("item")
  values1:push_back(tostring(quantity))
  values1:push_back(descriptor:GetItemDisplayName())
  local itemGeneratingMessage = LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacements("@ui_generator_time_to_generate_item", keys1, values1)
  UiTextBus.Event.SetText(self.ItemGeneratingText, itemGeneratingMessage)
  local keys2 = vector_basic_string_char_char_traits_char()
  local values2 = vector_basic_string_char_char_traits_char()
  keys2:push_back("generator")
  keys2:push_back("item")
  values2:push_back(generatorName)
  values2:push_back(descriptor:GetItemDisplayName())
  local maxCapacityMessage = LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacements("@ui_generator_at_maximum_capacity", keys2, values2)
  UiTextBus.Event.SetText(self.MaxCapacityText, maxCapacityMessage)
end
function Generator:OnTransitionIn(fromState, fromLevel, toState, toLevel)
  self:StartTick()
  self.WeightBar:AnimateIn()
  local durationLineHorzMax = 1.2
  local durationLineHorzMin = 0.8
  self.LineHorizontal:SetVisible(true, math.max(math.random() * durationLineHorzMax, durationLineHorzMin))
end
function Generator:OnTransitionOut(fromState, fromLevel, toState, toLevel)
  self.containerEntity = nil
  self.generatorEntity = nil
  self.LineHorizontal:SetVisible(false, 0.1)
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Flyout.IsVisible", false)
  LocalPlayerUIRequestsBus.Broadcast.InteractPanelClosed()
  local interactorEntityNode = self.dataLayer:GetDataNode("Hud.LocalPlayer.HudComponent.InteractorEntityId")
  if interactorEntityNode then
    local interactorEntity = interactorEntityNode:GetData()
    UiInteractorComponentRequestsBus.Event.RequestCancelCommittedInteraction(interactorEntity)
  end
  if self.structureStateBusHandler then
    self.structureStateBusHandler:Disconnect()
    self.structureStateBusHandler = nil
  end
  if self.itemGeneratorEventBusHandler then
    self.itemGeneratorEventBusHandler:Disconnect()
    self.itemGeneratorEventBusHandler = nil
  end
  self:StopTick()
  LyShineManagerBus.Broadcast.TransitionOutComplete()
end
function Generator:OnTick(elapsed, timePoint)
  if self.totalTime and self.timeRemaining and self.structureStateOn then
    self.timeRemaining = math.max(0, self.timeRemaining - elapsed)
    self:RefreshUiTimer()
  end
end
function Generator:OnDoubleClick(entityId)
  local slotName = ItemContainerBus.Event.GetSlotName(entityId)
  if not slotName then
    return
  end
  local inventoryId = self.dataLayer:GetDataNode("Hud.LocalPlayer.HudComponent.InventoryEntityId"):GetData()
  if not inventoryId then
    return
  end
  local targetItem = ContainerRequestBus.Event.GetSlot(self.containerEntity, slotName)
  local stackSize = targetItem:GetStackSize()
  local sourceSlotId = tonumber(slotName)
  LocalPlayerUIRequestsBus.Broadcast.PerformContainerTradeEntity(self.containerEntity, sourceSlotId, inventoryId, -1, stackSize)
end
function Generator:OnAction(entityId, actionName)
  BaseScreen.OnAction(self, entityId, actionName)
  if type(self[actionName]) == "function" then
    self[actionName](self, entityId, actionName)
  end
end
function Generator:GeneratorTakeAll()
  LocalPlayerUIRequestsBus.Broadcast.TakeAll(self.containerEntity)
end
function Generator:GeneratorClose()
  LyShineManagerBus.Broadcast.ExitState(1809891471)
end
function Generator:ItemUpdateDragData(entityId)
  local slotName = ItemContainerBus.Event.GetSlotName(entityId)
  local inventoryId = self.dataLayer:GetDataNode("Hud.LocalPlayer.HudComponent.InventoryEntityId"):GetData()
  if not inventoryId then
    return
  end
  local itemSlot = ContainerRequestBus.Event.GetSlot(inventoryId, slotName)
  local stackSize = itemSlot:GetStackSize()
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.ItemDragging.ContainerType", eItemDragContext_Container)
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.ItemDragging.ContainerId", self.containerEntity)
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.ItemDragging.ContainerSlotId", slotName)
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.ItemDragging.StackSize", stackSize)
end
function Generator:RegisterWithGeneratorInteractable(containerEntity, generatorEntity, generatorIsActive)
  self.containerEntity = containerEntity
  self.generatorEntity = generatorEntity
  self.itemGeneratorEventBusHandler = ItemGeneratorEventBus.Connect(self, self.generatorEntity)
  self:SetTextMessages()
  self.maxEncumbrance = ContainerRequestBus.Event.GetMaximumEncumbrance(self.containerEntity)
  self.WeightBar:SetMaxValue(self.maxEncumbrance / 10)
  ItemListBus.Event.BindToContainer(self.Properties.IconFrames, self.containerEntity, -1)
  self:StateChange(generatorIsActive)
  LyShineManagerBus.Broadcast.QueueState(1809891471)
end
function Generator:StateChange(isActive)
  self.structureStateOn = isActive
  UiElementBus.Event.SetIsEnabled(self.MaxCapacityText, not isActive)
  UiElementBus.Event.SetIsEnabled(self.TimeRemaining, isActive)
  UiElementBus.Event.SetIsEnabled(self.ItemGeneratingText, isActive)
  UiElementBus.Event.SetIsEnabled(self.ItemGenerationBar, isActive)
  self:SetPulseVisible(isActive)
end
function Generator:UnregisterInteractable()
  self:GeneratorClose()
end
function Generator:UpdateTimer(timeRemainingMS, totalTimeMS)
  self.timeRemaining = math.max(0, timeRemainingMS / 1000)
  self.totalTime = totalTimeMS / 1000
  self:RefreshUiTimer()
end
function Generator:RefreshUiTimer()
  local timeRemainingText = LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement("@ui_fuelremaining", string.format("%.0f", math.ceil(self.timeRemaining)))
  UiTextBus.Event.SetText(self.Properties.TimeRemaining, timeRemainingText)
  local percent = 1
  if self.totalTime > 0 then
    percent = (self.totalTime - self.timeRemaining) / self.totalTime
  end
  UiTransformBus.Event.SetScaleX(self.ItemGenerationBarFill, percent)
  UiTransform2dBus.Event.SetLocalWidth(self.ItemGenerationBarPulseMask, self.itemGenerationBarInitWidth * percent)
  local itemWeight = 0
  local itemDraggable = UiElementBus.Event.FindDescendantByName(self.IconFrames.entityId, "ItemDraggable")
  local draggableTable = self.registrar:GetEntityTable(itemDraggable)
  if draggableTable ~= nil then
    itemWeight = draggableTable.ItemLayout.mItemData_weight
  end
  self.WeightBar:SetValue(itemWeight / 10, 0)
end
function Generator:SetPulseVisible(IsVisible)
  if IsVisible then
    self.ScriptedEntityTweener:Stop(self.ItemGenerationBarPulse)
    self.ScriptedEntityTweener:Play(self.ItemGenerationBarPulse, 1, {
      x = -self.itemGenerationBarPulseWidth,
      opacity = 1
    }, {
      x = self.itemGenerationBarInitWidth + self.itemGenerationBarPulseWidth,
      opacity = 0,
      ease = "QuadIn",
      onComplete = function()
        self:SetPulseVisible(true)
      end
    })
  else
    self.ScriptedEntityTweener:Set(self.ItemGenerationBarPulse, {
      x = -self.itemGenerationBarPulseWidth
    })
  end
end
function Generator:OnShutdown()
  ClickRecognizer:OnDeactivate(self)
  if self.structureStateBusHandler then
    self.structureStateBusHandler:Disconnect()
    self.structureStateBusHandler = nil
  end
  if self.itemGeneratorEventBusHandler then
    self.itemGeneratorEventBusHandler:Disconnect()
    self.itemGeneratorEventBusHandler = nil
  end
  BaseScreen.OnShutdown(self)
end
return Generator
