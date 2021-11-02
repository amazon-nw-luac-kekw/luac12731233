local CrestTab = {
  Properties = {
    CrestBack = {
      default = EntityId()
    },
    CrestFront = {
      default = EntityId()
    },
    BackgroundImageList = {
      default = EntityId()
    },
    BackgroundColorList = {
      default = EntityId()
    },
    ForegroundImageList = {
      default = EntityId()
    },
    ForegroundColorList = {
      default = EntityId()
    },
    ColorTolerance = {default = 0.01},
    ForegroundTitle = {
      default = EntityId()
    },
    BackgroundTitle = {
      default = EntityId()
    },
    CrestTitle = {
      default = EntityId()
    },
    CrestDescription = {
      default = EntityId()
    },
    ForegroundImageFrame = {
      default = EntityId()
    },
    ForegroundColorFrame = {
      default = EntityId()
    },
    BackgroundImageFrame = {
      default = EntityId()
    },
    BackgroundColorFrame = {
      default = EntityId()
    },
    ForegroundImages = {
      default = EntityId()
    },
    ForegroundColors = {
      default = EntityId()
    },
    BackgroundImages = {
      default = EntityId()
    },
    BackgroundColors = {
      default = EntityId()
    },
    ButtonSave = {
      default = EntityId()
    },
    ButtonRevert = {
      default = EntityId()
    },
    ButtonRandom = {
      default = EntityId()
    }
  },
  spawnTickets = {},
  crestData = GuildIconData(),
  foregroundColors = {},
  backgroundColors = {},
  foregrounds = {},
  backgrounds = {},
  onCloseCallback = nil,
  onCloseTable = nil,
  entitlementsEnabled = false,
  TWITCH_ENTITLEMENT_IMAGE = "lyshineui/images/entitlements/icon_entitlement_twitchprime.png",
  DELUXE_ENTITLEMENT_IMAGE = "lyshineui/images/entitlements/icon_entitlement_default.png",
  factionId = nil
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(CrestTab)
local crestTabCommon = RequireScript("LyShineUI.GuildMenu.CrestTabCommon")
local EntitlementsDataHandler = RequireScript("LyShineUI._Common.EntitlementsDataHandler")
local OmniDataHandler = RequireScript("LyShineUI._Common.OmniDataHandler")
local FactionCommon = RequireScript("LyShineUI._Common.FactionCommon")
function CrestTab:OnInit()
  BaseElement.OnInit(self)
  self.canvasId = UiElementBus.Event.GetCanvas(self.entityId)
  self:BusConnect(UiCanvasNotificationBus, self.canvasId)
  self:BusConnect(UiSpawnerNotificationBus, self.Properties.ForegroundColorList)
  self:BusConnect(UiSpawnerNotificationBus, self.Properties.BackgroundColorList)
  self:BusConnect(UiSpawnerNotificationBus, self.Properties.ForegroundImageList)
  self:BusConnect(UiSpawnerNotificationBus, self.Properties.BackgroundImageList)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "UIFeatures.g_uiEnableEntitlements", function(self, enable)
    self.entitlementsEnabled = enable
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Faction", function(self, factionId)
    local prevFactionId = self.factionId
    self.factionId = factionId
    if prevFactionId and prevFactionId ~= eFactionType_None then
      self:BuildCrestData()
      self:RandomizeCrest()
    elseif self.factionId ~= eFactionType_None then
      self:BuildCrestData()
    end
  end)
  self:SetVisualElements()
end
function CrestTab:SetVisualElements()
  SetTextStyle(self.Properties.ForegroundTitle, self.UIStyle.FONT_STYLE_TITLE_GENERIC_SMALL)
  SetTextStyle(self.Properties.BackgroundTitle, self.UIStyle.FONT_STYLE_TITLE_GENERIC_SMALL)
  if self.Properties.CrestTitle then
    SetTextStyle(self.Properties.CrestTitle, self.UIStyle.FONT_STYLE_TITLE_GENERIC_SMALL)
  end
  UiTextBus.Event.SetTextWithFlags(self.Properties.ForegroundTitle, "@ui_foreground", eUiTextSet_SetLocalized)
  UiTextBus.Event.SetTextWithFlags(self.Properties.BackgroundTitle, "@ui_background", eUiTextSet_SetLocalized)
  local frameLineAlpha = 0.5
  self.ForegroundImageFrame:SetLineAlpha(frameLineAlpha)
  self.ForegroundImageFrame:SetFrameTextureVisible(false)
  self.ForegroundColorFrame:SetLineAlpha(frameLineAlpha)
  self.ForegroundColorFrame:SetFrameTextureVisible(false)
  self.BackgroundImageFrame:SetLineAlpha(frameLineAlpha)
  self.BackgroundImageFrame:SetFrameTextureVisible(false)
  self.BackgroundColorFrame:SetLineAlpha(frameLineAlpha)
  self.BackgroundColorFrame:SetFrameTextureVisible(false)
  if self.Properties.ButtonSave:IsValid() then
    self.ButtonSave:SetText("@ui_save")
    self.ButtonSave:SetCallback("SubmitCrest", self)
    self.ButtonSave:SetButtonStyle(self.ButtonSave.BUTTON_STYLE_CTA)
    self.ButtonSave:SetSoundOnPress(self.audioHelper.Crest_Submit)
  end
  if self.Properties.ButtonRevert:IsValid() then
    self.ButtonRevert:SetText("@ui_cancel")
    self.ButtonRevert:SetCallback("RevertCrest", self)
    self.ButtonRevert:SetSoundOnPress(self.audioHelper.Crest_Revert)
  end
  if self.Properties.ButtonRandom:IsValid() then
    self.ButtonRandom:SetText("@ui_randomize")
    self.ButtonRandom:SetCallback(self.RandomizeCrest, self)
    self.ButtonRandom:SetSoundOnPress(self.audioHelper.Crest_Revert)
  end
end
function CrestTab:SetScreenVisible(isVisible)
  if isVisible then
    self.ForegroundImageFrame:SetLineVisible(true, 1.2, {delay = 0.1})
    self.ForegroundColorFrame:SetLineVisible(true, 1.2, {delay = 0.2})
    self.BackgroundImageFrame:SetLineVisible(true, 1.2, {delay = 0.3})
    self.BackgroundColorFrame:SetLineVisible(true, 1.2, {delay = 0.4})
    self:UpdateCrest()
    self.entitlementBus = self:BusConnect(EntitlementNotificationBus)
  else
    self.ForegroundColorFrame:SetLineVisible(false, 0.6, {delay = 0.1})
    self.BackgroundColorFrame:SetLineVisible(false, 0.6, {delay = 0.1})
    self.ForegroundImageFrame:SetLineVisible(false, 0.6, {delay = 0.2})
    self.BackgroundImageFrame:SetLineVisible(false, 0.6, {delay = 0.2})
    self:BusDisconnect(self.entitlementBus)
  end
end
function CrestTab:OnEntitlementsChange()
  self:UpdateCrest()
end
function CrestTab:FillCrestPartIds()
  if self.idsFilled then
    return
  end
  self.idsFilled = true
  self.foregroundColorIds = {}
  self.backgroundColorIds = {}
  self.foregroundImageIds = {}
  self.backgroundImageIds = {}
  local countNode = self.dataLayer:Call(926587304)
  local count = 0
  if countNode then
    count = countNode:GetData()
  end
  for i = 1, count do
    local crestPartNode = self.dataLayer:Call(2985482927, i)
    if crestPartNode then
      local crestPart = crestPartNode:GetData()
      if crestPart then
        local isImage = 0 < string.len(crestPart.image)
        if isImage then
          if crestPart.isForeground then
            table.insert(self.foregroundImageIds, crestPart.id)
          else
            table.insert(self.backgroundImageIds, crestPart.id)
          end
        elseif crestPart.isForeground then
          table.insert(self.foregroundColorIds, crestPart.id)
        else
          table.insert(self.backgroundColorIds, crestPart.id)
        end
      end
    end
  end
  local sortById = function(a, b)
    return a < b
  end
  table.sort(self.foregroundColorIds, sortById)
  table.sort(self.backgroundColorIds, sortById)
  table.sort(self.foregroundImageIds, sortById)
  table.sort(self.backgroundImageIds, sortById)
end
function CrestTab:GetCrestPartById(id)
  local crestPartNode = self.dataLayer:Call(2380342559, id)
  if crestPartNode then
    return crestPartNode:GetData()
  end
end
function CrestTab:SetButtonDisplayInfo(crestButton, spawnType, crestPartId, displayName, rewardKey, colorOrImage)
  if spawnType == eRewardTypeGuildBackgroundColor or spawnType == eRewardTypeGuildForegroundColor then
    crestButton:SetColor(colorOrImage)
  else
    crestButton:SetImage(colorOrImage)
  end
  crestButton:SetDisplayName(displayName)
  crestButton:SetEntitlementData(spawnType, rewardKey)
  crestButton.crestPartId = crestPartId
  crestButton:SetIsLocked(false)
end
function CrestTab:BuildCrestData()
  self:FillCrestPartIds()
  local index = 1
  local numChildren = UiElementBus.Event.GetNumChildElements(self.Properties.BackgroundColorList)
  for i = 1, #self.backgroundColorIds do
    local crestPart = self:GetCrestPartById(self.backgroundColorIds[i])
    local colorFaction = crestPart.faction
    if self.factionId == colorFaction or colorFaction == eFactionType_Any then
      local rewardKey = Math.CreateCrc32(crestPart.entitlementId)
      local isEntitlement = rewardKey ~= 0
      if not isEntitlement or self.entitlementsEnabled then
        if index > numChildren then
          local ticket = UiSpawnerBus.Event.Spawn(self.Properties.BackgroundColorList)
          self.spawnTickets[ticket] = {
            spawnType = eRewardTypeGuildBackgroundColor,
            id = crestPart.id,
            displayName = crestPart.displayName,
            color = crestPart.color,
            rewardKey = rewardKey,
            parentId = self.Properties.BackgroundColorList
          }
        else
          local crestButton = self.registrar:GetEntityTable(UiElementBus.Event.GetChild(self.Properties.BackgroundColorList, index - 1))
          if crestButton then
            index = index + 1
            self:SetButtonDisplayInfo(crestButton, eRewardTypeGuildBackgroundColor, crestPart.id, crestPart.displayName, rewardKey, crestPart.color)
          end
        end
      end
    end
  end
  self:ClearRemainingElements(self.Properties.BackgroundColorList, index)
  index = 1
  numChildren = UiElementBus.Event.GetNumChildElements(self.Properties.ForegroundColorList)
  for i = 1, #self.foregroundColorIds do
    local crestPart = self:GetCrestPartById(self.foregroundColorIds[i])
    local colorFaction = crestPart.faction
    if self.factionId == colorFaction or colorFaction == eFactionType_Any then
      local rewardKey = Math.CreateCrc32(crestPart.entitlementId)
      local isEntitlement = rewardKey ~= 0
      if not isEntitlement or self.entitlementsEnabled then
        if index > numChildren then
          local ticket = UiSpawnerBus.Event.Spawn(self.Properties.ForegroundColorList)
          self.spawnTickets[ticket] = {
            spawnType = eRewardTypeGuildForegroundColor,
            id = crestPart.id,
            displayName = crestPart.displayName,
            color = crestPart.color,
            rewardKey = rewardKey,
            parentId = self.Properties.ForegroundColorList
          }
        else
          local crestButton = self.registrar:GetEntityTable(UiElementBus.Event.GetChild(self.Properties.ForegroundColorList, index - 1))
          if crestButton then
            index = index + 1
            self:SetButtonDisplayInfo(crestButton, eRewardTypeGuildForegroundColor, crestPart.id, crestPart.displayName, rewardKey, crestPart.color)
          end
        end
      end
    end
  end
  self:ClearRemainingElements(self.Properties.ForegroundColorList, index)
  index = 1
  numChildren = UiElementBus.Event.GetNumChildElements(self.Properties.BackgroundImageList)
  for i = 1, #self.backgroundImageIds do
    local crestPart = self:GetCrestPartById(self.backgroundImageIds[i])
    local crestFaction = crestPart.faction
    if self.factionId == crestFaction or crestFaction == eFactionType_Any then
      local rewardKey = Math.CreateCrc32(crestPart.entitlementId)
      local isEntitlement = rewardKey ~= 0
      if not isEntitlement or self.entitlementsEnabled then
        if index > numChildren then
          local ticket = UiSpawnerBus.Event.Spawn(self.Properties.BackgroundImageList)
          self.spawnTickets[ticket] = {
            spawnType = eRewardTypeGuildCrest,
            id = crestPart.id,
            imageName = crestPart.image,
            displayName = crestPart.displayName,
            rewardKey = rewardKey,
            parentId = self.Properties.BackgroundImageList
          }
        else
          local crestButton = self.registrar:GetEntityTable(UiElementBus.Event.GetChild(self.Properties.BackgroundImageList, index - 1))
          if crestButton then
            index = index + 1
            self:SetButtonDisplayInfo(crestButton, eRewardTypeGuildCrest, crestPart.id, crestPart.displayName, rewardKey, crestPart.image)
          end
        end
      end
    end
  end
  self:ClearRemainingElements(self.Properties.BackgroundImageList, index)
  index = 1
  numChildren = UiElementBus.Event.GetNumChildElements(self.Properties.ForegroundImageList)
  for i = 1, #self.foregroundImageIds do
    local crestPart = self:GetCrestPartById(self.foregroundImageIds[i])
    local crestId = crestPart.id
    local crestFaction = crestPart.faction
    if self.factionId == crestFaction or crestFaction == eFactionType_Any then
      local rewardKey = Math.CreateCrc32(crestPart.entitlementId)
      local isEntitlement = rewardKey ~= 0
      if not isEntitlement or self.entitlementsEnabled then
        if index > numChildren then
          local ticket = UiSpawnerBus.Event.Spawn(self.Properties.ForegroundImageList)
          self.spawnTickets[ticket] = {
            spawnType = eRewardTypeGuildCrest,
            id = crestPart.id,
            imageName = crestPart.image,
            displayName = crestPart.displayName,
            rewardKey = rewardKey,
            parentId = self.Properties.ForegroundImageList
          }
        else
          local crestButton = self.registrar:GetEntityTable(UiElementBus.Event.GetChild(self.Properties.ForegroundImageList, index - 1))
          if crestButton then
            index = index + 1
            self:SetButtonDisplayInfo(crestButton, eRewardTypeGuildCrest, crestPart.id, crestPart.displayName, rewardKey, crestPart.image)
          end
        end
      end
    end
  end
  self:ClearRemainingElements(self.Properties.ForegroundImageList, index)
  if self.Properties.CrestDescription then
    local factionData = FactionCommon.factionInfoTable[self.factionId]
    if factionData then
      local crestDescriptionText = GetLocalizedReplacementText("@ui_crest_description", {
        faction = factionData.factionName
      })
      UiTextBus.Event.SetText(self.Properties.CrestDescription, crestDescriptionText)
    end
  end
end
function CrestTab:ClearRemainingElements(entityId, index)
  while index <= UiElementBus.Event.GetNumChildElements(entityId) do
    UiElementBus.Event.DestroyElement(UiElementBus.Event.GetChild(entityId, index - 1))
  end
end
function CrestTab:SetCrestData(crestData)
  if self.crestData == crestData then
    return
  end
  self.crestData = crestData
  self:UpdateCrest()
end
function CrestTab:SetRadioButton(radioGroupId, crestPartId)
  local childList = UiElementBus.Event.GetChildren(radioGroupId)
  for i = 1, #childList do
    local entityTable = self.registrar:GetEntityTable(childList[i])
    local radioButton = entityTable:GetRadioButton()
    local isSelected = entityTable.crestPartId == crestPartId
    UiRadioButtonGroupBus.Event.SetState(radioGroupId, radioButton, isSelected)
    if isSelected then
      entityTable:OnSelected(true)
    else
      entityTable:OnUnselected()
    end
  end
end
function CrestTab:RandomCrestItem(entitlementType, itemList)
  local randomItem = math.random(#itemList)
  return itemList[randomItem]
end
function CrestTab:RandomizeCrest()
  self:FillCrestPartIds()
  local backgroundImages = {}
  for i, id in ipairs(self.backgroundImageIds) do
    local crestPart = self:GetCrestPartById(id)
    if crestPart.faction == self.factionId or crestPart.faction == eFactionType_Any and not self:IsLocked(eRewardTypeGuildCrest, Math.CreateCrc32(crestPart.entitlementId)) then
      table.insert(backgroundImages, {
        id = id,
        image = crestPart.image
      })
    end
  end
  local foregroundImages = {}
  for i, id in ipairs(self.foregroundImageIds) do
    local crestPart = self:GetCrestPartById(id)
    if crestPart.faction == self.factionId or crestPart.faction == eFactionType_Any and not self:IsLocked(eRewardTypeGuildCrest, Math.CreateCrc32(crestPart.entitlementId)) then
      table.insert(foregroundImages, {
        id = id,
        image = crestPart.image
      })
    end
  end
  local backgroundColors = {}
  for i, id in ipairs(self.backgroundColorIds) do
    local crestPart = self:GetCrestPartById(id)
    if crestPart.faction == self.factionId or crestPart.faction == eFactionType_Any and not self:IsLocked(eRewardTypeGuildBackgroundColor, Math.CreateCrc32(crestPart.entitlementId)) then
      table.insert(backgroundColors, {
        id = id,
        color = crestPart.color
      })
    end
  end
  local foregroundColors = {}
  for i, id in ipairs(self.foregroundColorIds) do
    local crestPart = self:GetCrestPartById(id)
    if crestPart.faction == self.factionId or crestPart.faction == eFactionType_Any and not self:IsLocked(eRewardTypeGuildForegroundColor, Math.CreateCrc32(crestPart.entitlementId)) then
      table.insert(foregroundColors, {
        id = id,
        color = crestPart.color
      })
    end
  end
  local randomForeColor = self:RandomCrestItem(eRewardTypeGuildForegroundColor, foregroundColors)
  local randomBackColor = self:RandomCrestItem(eRewardTypeGuildBackgroundColor, backgroundColors)
  local randomForeImage = self:RandomCrestItem(eRewardTypeGuildCrest, foregroundImages)
  local randomBackImage = self:RandomCrestItem(eRewardTypeGuildCrest, backgroundImages)
  self.crestData = GuildIconData()
  self.crestData.foregroundColor = randomForeColor.color
  self.crestData.backgroundColor = randomBackColor.color
  self.crestData.foregroundImagePath = randomForeImage.image
  self.crestData.backgroundImagePath = randomBackImage.image
  UiImageBus.Event.SetColor(self.Properties.CrestFront, self.crestData.foregroundColor)
  UiImageBus.Event.SetColor(self.Properties.CrestBack, self.crestData.backgroundColor)
  UiImageBus.Event.SetSpritePathname(self.Properties.CrestFront, self.crestData.foregroundImagePath)
  UiImageBus.Event.SetSpritePathname(self.Properties.CrestBack, self.crestData.backgroundImagePath)
  self:SetRadioButton(self.Properties.ForegroundColorList, randomForeColor.id)
  self:SetRadioButton(self.Properties.BackgroundColorList, randomBackColor.id)
  self:SetRadioButton(self.Properties.ForegroundImageList, randomForeImage.id)
  self:SetRadioButton(self.Properties.BackgroundImageList, randomBackImage.id)
end
function CrestTab:IsLocked(entitlementType, rewardKey)
  local isUnlocked = false
  if not rewardKey or rewardKey == 0 then
    return false
  else
    isUnlocked = EntitlementRequestBus.Broadcast.IsEntryIdOfRewardTypeEntitled(entitlementType, rewardKey)
  end
  return not isUnlocked
end
function CrestTab:GetEntitlementIds(entitlementType, rewardKey)
  local entitlementIds = {}
  if not rewardKey or rewardKey == 0 then
    return entitlementIds
  else
    entitlementIds = EntitlementRequestBus.Broadcast.GetEntitlementsForEntryIdOfRewardType(entitlementType, rewardKey)
  end
  return entitlementIds
end
function CrestTab:GetEntitlementSource(entitlementType, rewardKey)
  local entitlementIds = self:GetEntitlementIds(entitlementType, rewardKey)
  for i = 1, #entitlementIds do
    local entitlementData = EntitlementRequestBus.Broadcast.GetEntitlementData(entitlementIds[i])
    if entitlementData and string.len(entitlementData.entitlementInfo) > 0 then
      local image = entitlementData.icon
      if string.len(image) == 0 then
        image = self.DELUXE_ENTITLEMENT_IMAGE
      end
      return entitlementData.entitlementInfo, image
    end
  end
  return ""
end
function CrestTab:OnCrestButtonTooltipHoverStart(crestButton)
  if crestButton.isLocked then
    local rows = {}
    local grantInfo = EntitlementsDataHandler:GetGrantorForRewardTypeAndKey(crestButton.spawnType, crestButton.rewardKey)
    local rewardDisplayInfo = EntitlementsDataHandler:GetEntitlementDisplayInfo(crestButton.spawnType, crestButton.rewardKey)
    local productType = rewardDisplayInfo.typeString
    if grantInfo then
      if grantInfo.grantor ~= nil then
        self.sourceType = grantInfo.grantor.sourceType
      else
        self.sourceType = ""
      end
    end
    local row = {
      slicePath = "LyShineUI/Tooltip/DynamicTooltip",
      itemTable = {
        displayName = crestButton.displayName,
        sourceType = self.sourceType,
        productType = productType
      },
      rewardType = crestButton.spawnType,
      rewardKey = crestButton.rewardKey,
      availableProducts = crestButton.availableProducts,
      dynamicInfoText = "@ui_do_not_own",
      dynamicInfoColor = self.UIStyle.COLOR_RED,
      disclaimerText = "@ui_mtx_disclaimer"
    }
    if crestButton.spawnType == eRewardTypeGuildCrest then
      row.itemTable.spriteName = UiImageBus.Event.GetSpritePathname(crestButton.Properties.Image)
      row.itemTable.spriteColor = crestButton.UIStyle.COLOR_WHITE
      row.itemTable.displayName = "@ui_crest_emblem"
      row.itemTable.description = "@ui_crest_emblem_description_default"
    else
      row.itemTable.spriteName = "LyShineUI/Images/dyes/dyeColorSwatch.png"
      row.itemTable.spriteColor = crestButton.color
      row.itemTable.description = "@ui_crest_color_description_default"
    end
    table.insert(rows, row)
    local flyoutMenu = GetFlyoutMenu(self.dataLayer, self.registrar)
    if LocalPlayerUIRequestsBus.Broadcast.IsFlyoutMenuEnabled() then
      flyoutMenu:SetOpenLocation(crestButton.entityId, flyoutMenu.PREFER_RIGHT)
      flyoutMenu:EnableFlyoutDelay(true, 0.1)
      flyoutMenu:SetFadeInTime(0.3)
      flyoutMenu:SetRowData(rows)
      flyoutMenu:DockToCursor(10)
    end
  end
end
function CrestTab:OnCrestButtonTooltipHoverEnd(crestButton)
end
function CrestTab:OnCrestButtonTooltipClick(crestButton)
  if crestButton.availableProducts and #crestButton.availableProducts > 0 then
    local flyoutMenu = GetFlyoutMenu(self.dataLayer, self.registrar)
    flyoutMenu:SetSourceHoverOnly(false)
    flyoutMenu:Lock()
  end
end
function CrestTab:OnTopLevelEntitiesSpawned(ticket, entities)
  for ticketKey, data in pairs(self.spawnTickets) do
    if ticketKey == ticket then
      local crestButton = self.registrar:GetEntityTable(entities[1])
      crestButton:SetRadioButtonGroup(data.parentId)
      if data.parentId == self.Properties.ForegroundImageList then
        crestButton:SetImageScale(1.4)
        crestButton:SetSoundOnFocus(self.audioHelper.FrontEnd_OnCrestForgroundHover)
        crestButton:SetSoundOnPress(self.audioHelper.FrontEnd_OnCrestForgroundPress)
      elseif data.parentId == self.Properties.ForegroundColorList then
        crestButton:SetSoundOnFocus(self.audioHelper.FrontEnd_OnCrestForgroundColorHover)
        crestButton:SetSoundOnPress(self.audioHelper.FrontEnd_OnCrestForgroundColorPress)
      elseif data.parentId == self.Properties.BackgroundImageList then
        crestButton:SetSoundOnFocus(self.audioHelper.FrontEnd_OnCrestBackgroundHover)
        crestButton:SetSoundOnPress(self.audioHelper.FrontEnd_OnCrestBackgroundPress)
      elseif data.parentId == self.Properties.BackgroundColorList then
        crestButton:SetSoundOnFocus(self.audioHelper.FrontEnd_OnCrestBackgroundColorHover)
        crestButton:SetSoundOnPress(self.audioHelper.FrontEnd_OnCrestBackgroundColorPress)
      end
      crestButton:SetTooltipCallbacks(self, self.OnCrestButtonTooltipHoverStart, self.OnCrestButtonTooltipHoverEnd, self.OnCrestButtonTooltipClick)
      local colorOrImage
      if data.spawnType == eRewardTypeGuildForegroundColor or data.spawnType == eRewardTypeGuildBackgroundColor then
        colorOrImage = data.color
      elseif data.spawnType == eRewardTypeGuildCrest then
        colorOrImage = data.imageName
      end
      self:SetButtonDisplayInfo(crestButton, data.spawnType, data.id, data.displayName, data.rewardKey, colorOrImage)
      self.spawnTickets[ticketKey] = nil
    end
  end
  if not next(self.spawnTickets) then
    crestTabCommon:ResizeImageList(self.Properties.BackgroundImageList)
    crestTabCommon:ResizeImageList(self.Properties.ForegroundImageList)
  end
end
function CrestTab:UpdateEntitlementForEntity(offers, entityTable)
  if self.entitlementsEnabled then
    local locked = self:IsLocked(entityTable.spawnType, entityTable.rewardKey)
    local source, image = self:GetEntitlementSource(entityTable.spawnType, entityTable.rewardKey)
    if locked then
      local availableProducts = OmniDataHandler:SearchOffersForRewardTypeAndKey(offers, entityTable.spawnType, entityTable.rewardKey)
      local grantInfo = EntitlementsDataHandler:GetGrantorForRewardTypeAndKey(entityTable.spawnType, entityTable.rewardKey)
      for i, product in ipairs(availableProducts) do
        if string.len(source) == 0 and 0 < string.len(product.productData.displayName) then
          source = product.productData.displayName
        end
      end
      entityTable:SetAvailableProducts(availableProducts, grantInfo)
    elseif entityTable.rewardKey ~= nil and string.len(entityTable.rewardKey) > 0 then
      entityTable:SetEntitlementImageSource(image)
    end
    entityTable:SetIsLocked(locked)
  else
    entityTable:SetEntitlementImageSource(nil)
    entityTable:SetIsLocked(false)
  end
end
function CrestTab:UpdateCrest()
  OmniDataHandler:GetOmniOffers(self, function(self, offers)
    UiImageBus.Event.SetSpritePathname(self.Properties.CrestBack, self.crestData.backgroundImagePath)
    UiImageBus.Event.SetColor(self.Properties.CrestBack, self.crestData.backgroundColor)
    UiImageBus.Event.SetSpritePathname(self.Properties.CrestFront, self.crestData.foregroundImagePath)
    UiImageBus.Event.SetColor(self.Properties.CrestFront, self.crestData.foregroundColor)
    local backgroundImages = UiElementBus.Event.GetChildren(self.Properties.BackgroundImageList)
    for i = 1, #backgroundImages do
      local imageButton = self.registrar:GetEntityTable(backgroundImages[i])
      local imagePath = imageButton:GetImage()
      local isSelected = self.crestData.backgroundImagePath == imagePath
      UiRadioButtonGroupBus.Event.SetState(self.Properties.BackgroundImageList, imageButton:GetRadioButton(), isSelected)
      if isSelected then
        imageButton:OnSelected(true)
      else
        imageButton:OnUnselected()
      end
      self:UpdateEntitlementForEntity(offers, imageButton)
    end
    local foregroundImages = UiElementBus.Event.GetChildren(self.Properties.ForegroundImageList)
    for i = 1, #foregroundImages do
      local imageButton = self.registrar:GetEntityTable(foregroundImages[i])
      local imagePath = imageButton:GetImage()
      local isSelected = self.crestData.foregroundImagePath == imagePath
      UiRadioButtonGroupBus.Event.SetState(self.Properties.ForegroundImageList, imageButton:GetRadioButton(), isSelected)
      if isSelected then
        imageButton:OnSelected(true)
      else
        imageButton:OnUnselected()
      end
      self:UpdateEntitlementForEntity(offers, imageButton)
    end
    local backgroundColors = UiElementBus.Event.GetChildren(self.Properties.BackgroundColorList)
    for i = 1, #backgroundColors do
      local colorButton = self.registrar:GetEntityTable(backgroundColors[i])
      local color = colorButton:GetColor()
      local isSelected = color:IsClose(self.crestData.backgroundColor, self.Properties.ColorTolerance)
      UiRadioButtonGroupBus.Event.SetState(self.Properties.BackgroundColorList, colorButton:GetRadioButton(), isSelected)
      if isSelected then
        colorButton:OnSelected(true)
      else
        colorButton:OnUnselected()
      end
      self:UpdateEntitlementForEntity(offers, colorButton)
    end
    local foregroundColors = UiElementBus.Event.GetChildren(self.Properties.ForegroundColorList)
    for i = 1, #foregroundColors do
      local colorButton = self.registrar:GetEntityTable(foregroundColors[i])
      local color = colorButton:GetColor()
      local isSelected = color:IsClose(self.crestData.foregroundColor, self.Properties.ColorTolerance)
      UiRadioButtonGroupBus.Event.SetState(self.Properties.ForegroundColorList, colorButton:GetRadioButton(), isSelected)
      if isSelected then
        colorButton:OnSelected(true)
      else
        colorButton:OnUnselected()
      end
      self:UpdateEntitlementForEntity(offers, colorButton)
    end
  end)
end
function CrestTab:OnAction(entityId, actionName)
  if type(self[actionName]) == "function" then
    self[actionName](self, entityId, actionName)
  end
end
function CrestTab:SetOnCloseCallback(callback, table)
  self.onCloseCallback = callback
  self.onCloseTable = table
end
function CrestTab:GetCrestData()
  local crestData = GuildIconData()
  crestData.backgroundImagePath = UiImageBus.Event.GetSpritePathname(self.Properties.CrestBack)
  crestData.backgroundColor = UiImageBus.Event.GetColor(self.Properties.CrestBack)
  crestData.foregroundImagePath = UiImageBus.Event.GetSpritePathname(self.Properties.CrestFront)
  crestData.foregroundColor = UiImageBus.Event.GetColor(self.Properties.CrestFront)
  return crestData
end
function CrestTab:SubmitCrest()
  local saveGuildCrest = true
  self:ExecuteCallback(saveGuildCrest)
end
function CrestTab:RevertCrest()
  self:UpdateCrest()
  local saveGuildCrest = false
  self:ExecuteCallback(saveGuildCrest)
end
function CrestTab:ExecuteCallback(saveGuildCrest)
  if self.onCloseCallback ~= nil then
    self.onCloseCallback(self.onCloseTable, saveGuildCrest)
  end
end
function CrestTab:SelectForeground(entityId, actionName)
  local selectedItem = UiRadioButtonGroupBus.Event.GetState(entityId)
  local entityTable = self.registrar:GetEntityTable(selectedItem)
  local imagePathname = entityTable:GetImage()
  UiImageBus.Event.SetSpritePathname(self.Properties.CrestFront, imagePathname)
end
function CrestTab:SelectBackground(entityId, actionName)
  local selectedItem = UiRadioButtonGroupBus.Event.GetState(entityId)
  local entityTable = self.registrar:GetEntityTable(selectedItem)
  local imagePathname = entityTable:GetImage()
  UiImageBus.Event.SetSpritePathname(self.Properties.CrestBack, imagePathname)
end
function CrestTab:SelectFGColor(entityId, actionName)
  local selectedItem = UiRadioButtonGroupBus.Event.GetState(entityId)
  local entityTable = self.registrar:GetEntityTable(selectedItem)
  local color = entityTable:GetColor()
  UiImageBus.Event.SetColor(self.Properties.CrestFront, color)
end
function CrestTab:SelectBGColor(entityId, actionName)
  local selectedItem = UiRadioButtonGroupBus.Event.GetState(entityId)
  local entityTable = self.registrar:GetEntityTable(selectedItem)
  local color = entityTable:GetColor()
  UiImageBus.Event.SetColor(self.Properties.CrestBack, color)
end
return CrestTab
