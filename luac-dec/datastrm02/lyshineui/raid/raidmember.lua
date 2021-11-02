local RaidMember = {
  Properties = {
    NameText = {
      default = EntityId()
    },
    StatusIndicator = {
      default = EntityId()
    },
    PlayerBg = {
      default = EntityId()
    },
    DragIndicator = {
      default = EntityId()
    },
    Crown = {
      default = EntityId()
    },
    Hover = {
      default = EntityId()
    },
    GroupLeaderIcon = {
      default = EntityId()
    },
    NumberText = {
      default = EntityId()
    },
    PlayerIcon = {
      default = EntityId()
    }
  },
  name = "",
  dragToMoveGroups = false,
  permissions = eRaidPermission_Normal,
  groupIndex = nil,
  indexInGroup = nil,
  index = 0,
  delayFactorSeconds = 1
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(RaidMember)
local PlayerFlyoutHandler = RequireScript("LyShineUI.FlyoutMenu.PlayerFlyoutHandler")
PlayerFlyoutHandler:AttachPlayerFlyoutHandler(RaidMember)
local socialDataHandler = RequireScript("LyShineUI._Common.SocialDataHandler")
function RaidMember:OnInit()
  BaseElement.OnInit(self)
  self:InitPlayerFlyoutHandler(false)
  self.draggableHandler = self:BusConnect(UiDraggableNotificationBus, self.entityId)
  self.dragCanvas = EntityId()
  self.clonedElement = EntityId()
end
function RaidMember:OnShutdown()
end
function RaidMember:SetData(playerId, dragToMoveGroups, index)
  if self.playerId == playerId and self.dragToMoveGroups == dragToMoveGroups then
    return
  end
  self.playerId = playerId or SimplePlayerIdentification()
  self.index = index
  self.PlayerIcon:StartSpinner()
  self.PFH.playerId = playerId
  self:PFH_SetPlayerId(playerId)
  self.PlayerIcon:SetPlayerId(self.playerId)
  self.PlayerIcon:RequestPlayerIconData()
  self.characterId = self.playerId.characterIdString
  self:SetName(self.playerId.playerName)
  UiElementBus.Event.SetIsEnabled(self.Properties.PlayerIcon, true)
  self.dragToMoveGroups = dragToMoveGroups
  self.isStandby = self.groupIndex == nil
  if self.isStandby then
    if self.Properties.NumberText:IsValid() then
      local entriesPerPage = DynamicBus.Raid.Broadcast.GetSignupEntriesPerPage()
      local currentPage = DynamicBus.Raid.Broadcast.GetCurrentSignupListPage()
      UiTextBus.Event.SetText(self.Properties.NumberText, (currentPage - 1) * entriesPerPage + index)
    end
    UiTransformBus.Event.SetLocalPositionX(self.Properties.NameText, 57)
  else
    UiTransformBus.Event.SetLocalPositionX(self.Properties.NameText, 36)
    if self.Properties.PlayerBg:IsValid() then
      UiElementBus.Event.SetIsEnabled(self.Properties.PlayerBg, true)
    end
  end
  UiElementBus.Event.SetIsEnabled(self.Properties.StatusIndicator, false)
  self:UpdateOnlineStatus()
  UiElementBus.Event.SetIsEnabled(self.Properties.DragIndicator, true)
end
function RaidMember:SetName(name)
  self.name = name
  UiTextBus.Event.SetText(self.Properties.NameText, name)
  self.localPlayer = self.name == self.dataLayer:GetDataFromNode("Hud.LocalPlayer.PlayerName")
  self:UpdatePlayerNameTextStyle()
end
function RaidMember:ClearData()
  self.playerId = SimplePlayerIdentification()
  self.name = ""
  self.permissions = eRaidPermission_Normal
  UiTextBus.Event.SetTextWithFlags(self.Properties.NameText, "@ui_raid_member_empty", eUiTextSet_SetLocalized)
  self.characterId = nil
  self.dragToMoveGroups = false
  UiElementBus.Event.SetIsEnabled(self.Properties.Crown, false)
  UiTransform2dBus.Event.SetLocalWidth(self.Properties.NameText, 120)
  UiElementBus.Event.SetIsEnabled(self.Properties.PlayerIcon, false)
  UiImageBus.Event.SetColor(self.Properties.StatusIndicator, self.UIStyle.COLOR_RED)
  UiElementBus.Event.SetIsEnabled(self.Properties.PlayerBg, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.StatusIndicator, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.DragIndicator, false)
  self:UpdatePlayerNameTextStyle()
  self:SetLeaderStatus(false)
  UiElementBus.Event.SetIsEnabled(self.Properties.StatusIndicator, false)
  UiTransformBus.Event.SetLocalPositionX(self.Properties.NameText, 12)
end
function RaidMember:UpdateOnlineStatus()
  if not self.Properties.StatusIndicator:IsValid() or not self.playerId:IsValid() then
    return
  end
  socialDataHandler:GetRemotePlayerOnlineStatus_ServerCall(self, function(self, result)
    if 0 < #result then
      self:SetIsOnline(result[1].isOnline)
    end
  end, nil, self.playerId:GetCharacterIdString())
end
function RaidMember:SetIsOnline(isOnline)
  if not self.Properties.StatusIndicator:IsValid() or not self.playerId:IsValid() then
    return
  end
  UiElementBus.Event.SetIsEnabled(self.Properties.StatusIndicator, true)
  local color = self.UIStyle.COLOR_RED
  if isOnline then
    color = self.UIStyle.COLOR_GREEN_BRIGHT
  end
  UiImageBus.Event.SetColor(self.Properties.StatusIndicator, color)
end
function RaidMember:SetPermissions(permissions)
  UiElementBus.Event.SetIsEnabled(self.Properties.Crown, permissions > eRaidPermission_Normal)
  if permissions > eRaidPermission_Normal then
    UiTransform2dBus.Event.SetLocalWidth(self.Properties.NameText, 100)
  else
    UiTransform2dBus.Event.SetLocalWidth(self.Properties.NameText, 120)
  end
  local color = self.UIStyle.COLOR_TAN_LIGHT
  local iconPath = "LyShineUI/Images/Raid/icon_raidAssistant.dds"
  if permissions == eRaidPermission_Leader then
    color = self.UIStyle.COLOR_YELLOW_GOLD
    iconPath = "LyShineUI/Images/Raid/icon_raidLeader.dds"
  end
  UiImageBus.Event.SetColor(self.Properties.Crown, color)
  UiImageBus.Event.SetSpritePathname(self.Properties.Crown, iconPath)
  self.permissions = permissions
end
function RaidMember:SetLeaderStatus(isLeader)
  UiElementBus.Event.SetIsEnabled(self.Properties.GroupLeaderIcon, isLeader)
end
function RaidMember:UpdatePlayerNameTextStyle()
  if self.localPlayer then
    textStyle = {
      fontFamily = self.UIStyle.FONT_FAMILY_NIMBUS_SEMIBOLD,
      fontColor = self.UIStyle.COLOR_YELLOW
    }
  elseif GuildsComponentBus.Broadcast.IsGuildMate(self.characterId) then
    textStyle = {
      fontFamily = self.UIStyle.FONT_FAMILY_NIMBUS_MEDIUM,
      fontColor = self.UIStyle.COLOR_NAMEPLATE_GUILD
    }
  else
    textStyle = {
      fontFamily = self.UIStyle.FONT_FAMILY_NIMBUS_MEDIUM,
      fontColor = self.UIStyle.COLOR_TAN_LIGHT
    }
  end
  SetTextStyle(self.Properties.NameText, textStyle)
end
function RaidMember:OnHoverStart()
  if g_isDragging then
    return
  end
  self.audioHelper:PlaySound(self.audioHelper.Crafting_Item_Hover)
  self.ScriptedEntityTweener:Play(self.Properties.Hover, 0.1, {opacity = 0}, {opacity = 1, ease = "QuadOut"})
  if self.characterId ~= nil then
    self:PFH_ShowFlyout(self.entityId)
  end
end
function RaidMember:OnHoverEnd()
  self.ScriptedEntityTweener:Play(self.Properties.Hover, 0.05, {opacity = 1}, {opacity = 0, ease = "QuadOut"})
end
function RaidMember:OnNewPermissions(data)
  DynamicBus.Raid.Broadcast.SetPlayerPermissions(data)
end
function RaidMember:OnRemove(data)
  DynamicBus.Raid.Broadcast.RemovePlayer(data)
end
function RaidMember:OnKick(data)
  DynamicBus.Raid.Broadcast.KickPlayer(data)
end
function RaidMember:OnPressed()
end
function RaidMember:OnReleased(entityId)
end
function RaidMember:OnDragStart(position)
  self:OnHoverEnd()
  self.dragStartMouse = UiCursorBus.Broadcast.GetUiCursorPosition()
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Flyout.IsVisible", false)
  self.isProxy = UiDraggableBus.Event.IsProxy(self.entityId)
  if self.isProxy == nil then
    self.isProxy = true
  end
  UiDraggableBus.Event.SetCanDropOnAnyCanvas(self.entityId, true)
  if g_isDragging then
    return
  end
  if not self.isProxy then
    g_isDragging = true
    self.dragCanvas = UiCanvasManagerBus.Broadcast.CreateCanvas()
    if self.dragCanvas:IsValid() then
      UiCanvasBus.Event.SetDrawOrder(self.dragCanvas, 999)
      UiCanvasBus.Event.SetCanvasSize(self.dragCanvas, Vector2(1920, 1080))
      self.clonedElement = UiCanvasBus.Event.CloneElement(self.dragCanvas, self.entityId, EntityId(), EntityId())
      if self.clonedElement:IsValid() then
        self.dataLayer:RegisterEntity("CurrentDraggable", self.clonedElement)
        local clonedTable = self.registrar:GetEntityTable(self.clonedElement)
        clonedTable.name = self.name
        clonedTable.characterId = self.characterId
        clonedTable.prevGroupIndex = self.groupIndex
        clonedTable.permissions = self.permissions
        clonedTable.PlayerIcon:StopSpinner()
        if self.PlayerIcon.isSpinning or not self.PlayerIcon.playerIcon then
          UiElementBus.Event.SetIsEnabled(clonedTable.Properties.PlayerIcon, false)
          UiElementBus.Event.SetIsEnabled(clonedTable.Properties.StatusIndicator, false)
        else
          clonedTable.PlayerIcon:SetPlayerIcon(self.PlayerIcon.playerIcon)
        end
        UiTransformBus.Event.SetScaleToDevice(self.clonedElement, true)
        local anchors = UiTransform2dBus.Event.GetAnchors(self.clonedElement)
        local offsets = UiTransform2dBus.Event.GetOffsets(self.clonedElement)
        anchors.bottom = 0.5
        anchors.left = 0.5
        anchors.right = 0.5
        anchors.top = 0.5
        UiTransform2dBus.Event.SetAnchors(self.clonedElement, anchors, true, false)
        UiTransform2dBus.Event.SetOffsets(self.clonedElement, offsets)
        local numberText = UiElementBus.Event.FindChildByName(self.clonedElement, "Number")
        if numberText:IsValid() then
          UiElementBus.Event.SetIsEnabled(numberText, false)
        end
        UiDraggableBus.Event.SetAsProxy(self.clonedElement, self.entityId, position)
      end
    end
  else
    UiTransformBus.Event.SetViewportPosition(self.entityId, position)
  end
end
function RaidMember:OnDrag(position)
  if self.isProxy then
    UiTransformBus.Event.SetViewportPosition(self.entityId, position)
  end
end
function RaidMember:OnDragEnd(position)
  if self.isProxy then
    UiDraggableBus.Event.ProxyDragEnd(self.entityId, position)
  else
    local canvasId = UiElementBus.Event.GetCanvas(self.entityId)
    UiCanvasBus.Event.SetActiveInteractable(canvasId, EntityId(), false)
    if self.dragCanvas:IsValid() then
      if self.clonedElement:IsValid() then
        self.dataLayer:UnregisterEntity("CurrentDraggable")
        UiElementBus.Event.DestroyElement(self.clonedElement)
      end
      UiCanvasManagerBus.Broadcast.UnloadCanvas(self.dragCanvas)
      self.dragCanvas = EntityId()
    end
  end
  g_isDragging = false
  UiDraggableBus.Event.SetCanDropOnAnyCanvas(self.entityId, false)
end
function RaidMember:ShowName(isEnabled)
  UiElementBus.Event.SetIsEnabled(self.Properties.NameText, isEnabled)
end
return RaidMember
