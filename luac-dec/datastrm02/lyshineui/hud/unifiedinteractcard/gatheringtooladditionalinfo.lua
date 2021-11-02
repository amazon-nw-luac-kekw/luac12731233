local GatheringToolAdditionalInfo = {
  Properties = {
    PrimaryToolItem = {
      default = EntityId()
    },
    UngatherableText = {
      default = EntityId()
    },
    UngatherableIcon = {
      default = EntityId()
    },
    SkillLevelCircle = {
      default = EntityId()
    }
  },
  itemDesc = nil,
  gatheringType = "",
  hasTradeskillRank = false,
  gatheringMessages = {
    Chopping = {
      noTool = "@ui_notoolchopping",
      lowSkill = "@ui_lowskillchopping",
      icon = "lyshineui/images/icons/gatherables/chopping.dds"
    },
    Cutting = {
      noTool = "@ui_notoolcutting",
      lowSkill = "@ui_lowskillcutting",
      icon = "lyshineui/images/icons/gatherables/cutting.dds"
    },
    Dressing = {
      noTool = "@ui_notooldressing",
      lowSkill = "@ui_lowskilldressing",
      icon = "lyshineui/images/icons/gatherables/dressing.dds"
    },
    Mining = {
      noTool = "@ui_notoolmining",
      lowSkill = "@ui_lowskillmining",
      icon = "lyshineui/images/icons/gatherables/mining.dds"
    },
    AzothStaff = {
      noTool = "@ui_notoolazothstaff",
      lowSkill = "",
      icon = "lyshineui/images/icons/gatherables/azothstaff.dds"
    }
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(GatheringToolAdditionalInfo)
local FactionCommon = RequireScript("LyShineUI._Common.FactionCommon")
local EncounterDataHandler = RequireScript("LyShineUI._Common.EncounterDataHandler")
local StaticItemDataManager = RequireScript("LyShineUI._Common.StaticItemDataManager")
function GatheringToolAdditionalInfo:OnInit()
  BaseElement.OnInit(self)
  self:BusConnect(UiInteractOptionAdditionalInfoRequestsBus, self.entityId)
  self.SkillLevelCircle:SetDisplayType(self.SkillLevelCircle.DISPLAY_TYPE_WARNING)
end
function GatheringToolAdditionalInfo:OnContainerChanged()
  self:RefrehHasRequiredItem()
end
function GatheringToolAdditionalInfo:OnContainerSlotChanged(localSlotId, newItemDescriptor, oldItemDescriptor)
  self:RefrehHasRequiredItem()
end
function GatheringToolAdditionalInfo:RefrehHasRequiredItem(skipEnabledCheck)
  if not skipEnabledCheck then
    local canvasId = UiElementBus.Event.GetCanvas(self.entityId)
    local canvasEnabled = UiCanvasBus.Event.GetEnabled(canvasId)
    local isStillEnabled = UiElementBus.Event.GetAreElementAndAncestorsEnabled(self.entityId)
    if not isStillEnabled or not canvasEnabled then
      if self.containerEventHandler then
        self:BusDisconnect(self.containerEventHandler)
        self.containerEventHandler = nil
      end
      return
    end
  end
  local isAzothStaff = self.gatheringType == "AzothStaff"
  local gaheringEntityId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.GatheringEntityId")
  local tool
  if self.gatheringType == "None" or self.gatheringType == "" then
    tool = UiGatheringComponentRequestsBus.Event.GetFirstSlotWithItem(gaheringEntityId, self.itemDesc)
  else
    tool = UiGatheringComponentRequestsBus.Event.GetValidGatheringToolList(gaheringEntityId, self.gatheringType)
  end
  local inventoryId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.InventoryEntityId")
  local isAtItemCapacity = not isAzothStaff and ContainerRequestBus.Event.IsAtItemCapacity(inventoryId)
  local hasItem = tool and tool:IsValid()
  local canGather = hasItem and self.hasTradeskillRank and self.isInRequiredFaction and self.hasControllingFactionPaidUpkeep and not isAtItemCapacity
  UiElementBus.Event.SetIsEnabled(self.Properties.PrimaryToolItem, canGather)
  UiElementBus.Event.SetIsEnabled(self.Properties.UngatherableText, not canGather)
  if canGather then
    self.PrimaryToolItem:SetItem(tool, true)
    if self.containerEventHandler then
      self:BusDisconnect(self.containerEventHandler)
      self.containerEventHandler = nil
    end
  else
    local messageData = self.gatheringMessages[self.gatheringType]
    local messageText = ""
    if isAzothStaff then
      local itemDescriptor = ItemDescriptor()
      itemDescriptor.itemId = EncounterDataHandler:GetRequiredItem(self.requiredRank)
      local tier = StaticItemDataManager:GetItem(itemDescriptor.itemId).tier
      messageText = GetLocalizedReplacementText(messageData.noTool, {
        itemName = itemDescriptor:GetDisplayName(),
        tier = tier
      })
      UiImageBus.Event.SetSpritePathname(self.Properties.UngatherableIcon, messageData.icon)
      UiImageBus.Event.SetAlpha(self.Properties.UngatherableIcon, 100)
      UiElementBus.Event.SetIsEnabled(self.Properties.SkillLevelCircle, false)
    else
      if messageData then
        local iconPath = messageData.icon
        messageText = self.hasTradeskillRank and messageData.noTool or messageData.lowSkill
        UiImageBus.Event.SetSpritePathname(self.Properties.UngatherableIcon, iconPath)
        UiImageBus.Event.SetAlpha(self.Properties.UngatherableIcon, 100)
      else
        UiImageBus.Event.SetAlpha(self.Properties.UngatherableIcon, 0)
      end
      UiElementBus.Event.SetIsEnabled(self.Properties.SkillLevelCircle, not self.hasTradeskillRank)
      if not self.hasTradeskillRank then
        self.SkillLevelCircle:SetLevel(self.requiredRank)
      end
    end
    if isAtItemCapacity then
      messageText = "@ui_storage_is_full"
    end
    if not self.isInRequiredFaction then
      if self.requiredFaction == eFactionType_None then
        messageText = "@ui_gather_no_faction"
      else
        local factionData = FactionCommon.factionInfoTable[self.requiredFaction]
        messageText = LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement("@ui_gather_faction_mismatch", factionData.factionName)
      end
    elseif self.requiredFaction ~= eFactionType_None and not self.hasControllingFactionPaidUpkeep then
      local factionData = FactionCommon.factionInfoTable[self.requiredFaction]
      messageText = LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement("@ui_gather_faction_upkeep_unpaid", factionData.factionName)
    end
    UiTextBus.Event.SetTextWithFlags(self.Properties.UngatherableText, messageText, eUiTextSet_SetLocalized)
  end
end
function GatheringToolAdditionalInfo:PopulateGatheringToolAdditionalInfo(additionalInfo)
  self.itemDesc = additionalInfo.itemDescriptor
  self.gatheringType = additionalInfo.gatheringTypeName
  self.hasTradeskillRank = additionalInfo.hasTradeskillRank
  self.isInRequiredFaction = additionalInfo.isInRequiredFaction
  self.hasControllingFactionPaidUpkeep = additionalInfo.hasControllingFactionPaidUpkeep
  self.requiredRank = additionalInfo.requiredRank
  self.requiredFaction = additionalInfo.requiredFaction
  local requiresItem = self.itemDesc:IsValid()
  if self.hasTradeskillRank and (requiresItem or self.gatheringType ~= "None") then
    local inventoryId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.InventoryEntityId")
    if not self.containerEventHandler then
      self.containerEventHandler = self:BusConnect(ContainerEventBus, inventoryId)
    end
  end
  self:RefrehHasRequiredItem(true)
end
return GatheringToolAdditionalInfo
