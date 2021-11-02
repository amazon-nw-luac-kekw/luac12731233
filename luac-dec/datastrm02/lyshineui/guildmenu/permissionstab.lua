local PermissionsTab = {
  Properties = {
    RankSelectors = {
      default = EntityId()
    },
    RankSelectorPrototype = {
      default = EntityId()
    },
    PermissionCheckboxPrototype = {
      default = EntityId()
    },
    PermissionPrototypeText = {
      default = EntityId()
    },
    ActiveRankText = {
      default = EntityId()
    },
    MemberPermissionsContainer = {
      default = EntityId()
    },
    MemberPermissionsTitle = {
      default = EntityId()
    },
    MemberPermissionsList = {
      default = EntityId()
    },
    CommunicationsPermissionsContainer = {
      default = EntityId()
    },
    CommunicationsPermissionsTitle = {
      default = EntityId()
    },
    CommunicationsPermissionsList = {
      default = EntityId()
    },
    StructuresPermissionsContainer = {
      default = EntityId()
    },
    StructuresPermissionsTitle = {
      default = EntityId()
    },
    StructuresPermissionsList = {
      default = EntityId()
    },
    TreasuryPermissionsContainer = {
      default = EntityId()
    },
    TreasuryPermissionsTitle = {
      default = EntityId()
    },
    TreasuryPermissionsList = {
      default = EntityId()
    }
  },
  selectedRankIndex = 0,
  rankSelectors = {},
  permissionCheckBoxes = {},
  allowedString = "@ui_can"
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(PermissionsTab)
local dataLayer = RequireScript("LyShineUI.UiDataLayer")
function PermissionsTab:OnInit()
  BaseElement.OnInit(self)
  self.canvasId = UiElementBus.Event.GetCanvas(self.entityId)
  self.dataLayer = dataLayer
  self.containerByPermissionName = {
    ["@ui_permission_invite"] = {
      container = self.MemberPermissionsList,
      isVisible = true
    },
    ["@ui_permission_kick"] = {
      container = self.MemberPermissionsList,
      isVisible = true
    },
    ["@ui_permission_promote"] = {
      container = self.MemberPermissionsList,
      isVisible = true
    },
    ["@ui_permission_demote"] = {
      container = self.MemberPermissionsList,
      isVisible = true
    },
    ["@ui_permission_declare_war"] = {
      container = self.CommunicationsPermissionsList,
      isVisible = true
    },
    ["@ui_permission_guild_chat_listen"] = {
      container = self.CommunicationsPermissionsList,
      isVisible = true
    },
    ["@ui_permission_guild_chat_speak"] = {
      container = self.CommunicationsPermissionsList,
      isVisible = true
    },
    ["@ui_permission_officer_chat_listen"] = {
      container = self.CommunicationsPermissionsList,
      isVisible = true
    },
    ["@ui_permission_officer_chat_speak"] = {
      container = self.CommunicationsPermissionsList,
      isVisible = true
    },
    ["@ui_permission_setmotd"] = {
      container = self.CommunicationsPermissionsList,
      isVisible = true
    },
    ["@ui_permission_war_raid_manage"] = {
      container = self.CommunicationsPermissionsList,
      isVisible = true
    },
    ["@ui_permission_build_structures"] = {
      container = self.StructuresPermissionsList,
      isVisible = true
    },
    ["@ui_permission_cancel_structures"] = {
      container = self.StructuresPermissionsList,
      isVisible = true
    },
    ["@ui_permission_plantseed_farm"] = {
      container = self.StructuresPermissionsList,
      isVisible = true
    },
    ["@ui_permission_use_structures"] = {
      container = self.StructuresPermissionsList,
      isVisible = true
    },
    ["@ui_permission_seal_structures"] = {
      container = self.StructuresPermissionsList,
      isVisible = true
    },
    ["@ui_permission_assign_structures"] = {
      container = self.StructuresPermissionsList,
      isVisible = true
    },
    ["@ui_permission_demolish_structures"] = {
      container = self.StructuresPermissionsList,
      isVisible = true
    },
    ["@ui_permission_deposit_in_structure"] = {
      container = self.StructuresPermissionsList,
      isVisible = true
    },
    ["@ui_permission_withdraw_from_structure"] = {
      container = self.StructuresPermissionsList,
      isVisible = true
    },
    ["@ui_permission_demolish_territories"] = {
      container = self.StructuresPermissionsList,
      isVisible = false
    },
    ["@ui_permission_territory_project_management"] = {
      container = self.StructuresPermissionsList,
      isVisible = true
    },
    ["@ui_permission_territory_taxation"] = {
      container = self.StructuresPermissionsList,
      isVisible = true
    },
    ["@ui_permission_build_defensive_structures"] = {
      container = self.StructuresPermissionsList,
      isVisible = true
    },
    ["@ui_permission_treasury_deposit"] = {
      container = self.TreasuryPermissionsList,
      isVisible = true
    },
    ["@ui_permission_treasury_withdraw"] = {
      container = self.TreasuryPermissionsList,
      isVisible = true
    },
    ["@ui_permission_treasury_set_daily_limit"] = {
      container = self.TreasuryPermissionsList,
      isVisible = true
    }
  }
  self.dataLayer:RegisterAndExecuteDataObserver(self, "UIFeatures.g_uiAllowGuildRankChanges", function(self, allowGuildRankChanges)
    self.allowGuildRankChanges = allowGuildRankChanges
  end)
  SetTextStyle(self.MemberPermissionsTitle, self.UIStyle.FONT_STYLE_PERMISSIONS_SUBHEADER)
  SetTextStyle(self.CommunicationsPermissionsTitle, self.UIStyle.FONT_STYLE_PERMISSIONS_SUBHEADER)
  SetTextStyle(self.StructuresPermissionsTitle, self.UIStyle.FONT_STYLE_PERMISSIONS_SUBHEADER)
  SetTextStyle(self.TreasuryPermissionsTitle, self.UIStyle.FONT_STYLE_PERMISSIONS_SUBHEADER)
  SetTextStyle(self.PermissionPrototypeText, self.UIStyle.FONT_STYLE_PERMISSIONS)
  SetTextStyle(self.ActiveRankText, self.UIStyle.FONT_STYLE_CRAFTING_HEADER)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Guild.Enabled", function(self, enabled)
    if enabled then
      self:ClearPermissions()
      self:InitRankSelectors()
      self:InitPermissions()
      self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Guild.Id", function(self, guildId)
        self.guildId = guildId
        if self.guildId and self.guildId:IsValid() then
          self:OnRanksChanged()
        end
      end)
      self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Guild.Rank", self.OnPlayerRankChanged)
    else
      self.dataLayer:UnregisterObserver(self, "Hud.LocalPlayer.Guild.Id")
      self.dataLayer:UnregisterObserver(self, "Hud.LocalPlayer.Guild.Rank")
    end
  end)
  self.dataLayer:RegisterDataObserver(self, "Hud.LocalPlayer.Options.Localization.Language", function(self, setLang)
    self:SetRankText()
    if self.guildId then
      self:OnRanksChanged()
    end
  end)
end
function PermissionsTab:ClearPermissions()
  for _, permissionCheckBox in pairs(self.permissionCheckBoxes) do
    UiElementBus.Event.DestroyElement(permissionCheckBox.permissionEntityId)
  end
  self.permissionCheckBoxes = {}
  for _, rankSelector in pairs(self.rankSelectors) do
    UiElementBus.Event.DestroyElement(rankSelector.entityId)
  end
  self.rankSelectors = {}
end
function PermissionsTab:OnShutdown()
  self:ClearPermissions()
  self.dataLayer:UnregisterObservers(self)
end
function PermissionsTab:SetTab(tabTable)
  self.tabTable = tabTable
  self:SetRankText()
end
function PermissionsTab:SetVisible(isVisible)
  self.isVisible = isVisible
end
function PermissionsTab:InitRankSelectors()
  local numRanks = GuildsComponentBus.Broadcast.GetNumRanks()
  for i = 1, numRanks do
    local rankEntityId = UiCanvasBus.Event.CloneElement(self.canvasId, self.RankSelectorPrototype.entityId, self.RankSelectors, EntityId())
    UiElementBus.Event.SetIsEnabled(rankEntityId, true)
    UiRadioButtonGroupBus.Event.AddRadioButton(self.RankSelectors, rankEntityId)
    rankEntity = self.registrar:GetEntityTable(rankEntityId)
    rankEntity:SetSelectedCallback("OnRankSelected", self, rankEntityId)
    table.insert(self.rankSelectors, rankEntity)
  end
end
function PermissionsTab:InitPermissions()
  local permissions = GuildsComponentBus.Broadcast.GetPrivileges()
  local listTotalMargin = 26
  local listHeights = {
    [self.MemberPermissionsList] = listTotalMargin,
    [self.CommunicationsPermissionsList] = listTotalMargin,
    [self.StructuresPermissionsList] = listTotalMargin,
    [self.TreasuryPermissionsList] = listTotalMargin
  }
  for i = 1, #permissions do
    local permissionContainerData = self.containerByPermissionName[permissions[i].name]
    if permissionContainerData then
      if permissionContainerData.isVisible then
        local container = permissionContainerData.container
        local permissionEntityId = UiCanvasBus.Event.CloneElement(self.canvasId, self.PermissionCheckboxPrototype, container, EntityId())
        UiElementBus.Event.SetIsEnabled(permissionEntityId, true)
        local textElement = UiElementBus.Event.FindDescendantByName(permissionEntityId, "Text")
        local checkBoxElement = UiElementBus.Event.FindDescendantByName(permissionEntityId, "Button_Checkbox")
        self.permissionCheckBoxes[tostring(checkBoxElement)] = {
          entityId = checkBoxElement,
          permissionEntityId = permissionEntityId,
          textEntityId = textElement,
          permissionId = permissions[i].id,
          name = permissions[i].name
        }
        listHeights[container] = listHeights[container] + UiTransform2dBus.Event.GetLocalHeight(permissionEntityId)
      end
    else
      Debug.Log("err - No container data defined for permission with name " .. tostring(permissions[i].name))
    end
  end
  UiLayoutCellBus.Event.SetTargetHeight(self.MemberPermissionsContainer, listHeights[self.MemberPermissionsList])
  UiLayoutCellBus.Event.SetTargetHeight(self.CommunicationsPermissionsContainer, listHeights[self.CommunicationsPermissionsList])
  UiLayoutCellBus.Event.SetTargetHeight(self.StructuresPermissionsContainer, listHeights[self.StructuresPermissionsList])
  UiLayoutCellBus.Event.SetTargetHeight(self.TreasuryPermissionsContainer, listHeights[self.TreasuryPermissionsList])
  self:UpdatePermissions()
end
function PermissionsTab:OnRankSelected(entityId)
  self.selectedRankIndex = UiElementBus.Event.GetIndexOfChildByEntityId(self.RankSelectors, entityId)
  self:UpdatePermissions()
end
function PermissionsTab:OnRanksChanged()
  self:UpdateRankSelectors()
  self:UpdatePermissions()
end
function PermissionsTab:UpdateRankSelectors()
  local numRanks = GuildsComponentBus.Broadcast.GetNumRanks()
  if self.selectedRankIndex > numRanks - 1 then
    self.selectedRankIndex = 0
  end
  for i = 1, numRanks do
    local rankEntity = self.rankSelectors[i]
    local rankName = GuildsComponentBus.Broadcast.GetRankName(i - 1)
    rankEntity:SetText(rankName)
    rankEntity:SetTextPrefix(tostring(i) .. ".", true)
    rankEntity:SetShowingExtraIndicator(i - 1 == self.playerRank)
    if self.selectedRankIndex == i - 1 then
      UiRadioButtonGroupBus.Event.SetState(self.RankSelectors, rankEntity.entityId, true)
      self.rankSelectors[i]:OnSelected()
    end
  end
end
function PermissionsTab:UpdatePermissions()
  local numRanks = GuildsComponentBus.Broadcast.GetNumRanks()
  if numRanks == 0 then
    return
  end
  if 0 > self.selectedRankIndex or numRanks <= self.selectedRankIndex then
    self.selectedRankIndex = 0
  end
  for _, data in pairs(self.permissionCheckBoxes) do
    local rankHasPrivilege = GuildsComponentBus.Broadcast.RankHasPrivilege(self.selectedRankIndex, data.permissionId)
    UiCheckboxBus.Event.SetState(data.entityId, rankHasPrivilege)
    local string = GetLocalizedReplacementText(data.name, {
      allowed = self.allowedString
    })
    UiTextBus.Event.SetText(data.textEntityId, string)
    if rankHasPrivilege then
      UiTextBus.Event.SetColor(data.textEntityId, self.UIStyle.COLOR_GRAY_80)
    else
      UiTextBus.Event.SetColor(data.textEntityId, self.UIStyle.COLOR_GRAY_50)
    end
  end
  UiTextBus.Event.SetTextWithFlags(self.Properties.ActiveRankText, GuildsComponentBus.Broadcast.GetRankName(self.selectedRankIndex), eUiTextSet_SetLocalized)
end
function PermissionsTab:OnSecurityLevelChange(entityId)
  local entity = Entity(entityId)
  local securityLevel = tonumber(entity:GetName())
  JavSocialComponentBus.Broadcast.RequestGuildRankEditSecurityLevel(self.selectedRankIndex, securityLevel)
end
function PermissionsTab:OnPermissionChange(entityId)
  local data = self.permissionCheckBoxes[tostring(entityId)]
  JavSocialComponentBus.Broadcast.RequestGuildRankTogglePrivilege(self.selectedRankIndex, data.permissionId)
end
function PermissionsTab:OnPlayerRankChanged(rank)
  if rank ~= nil then
    if self.playerRank ~= nil then
      local oldRankSelector = self.rankSelectors[self.playerRank + 1]
      if oldRankSelector then
        oldRankSelector:SetShowingExtraIndicator(false)
      end
    end
    self.playerRank = rank
    local rankSelector = self.rankSelectors[rank + 1]
    if rankSelector ~= nil then
      rankSelector:SetShowingExtraIndicator(true)
    end
    self:SetRankText()
  end
end
function PermissionsTab:SetRankText()
  if self.playerRank then
    local localizedRankText = LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement("@ui_currentrank", GuildsComponentBus.Broadcast.GetRankName(self.playerRank))
    if self.tabTable then
      self.tabTable:SetSecondaryText(localizedRankText)
    end
  end
end
return PermissionsTab
