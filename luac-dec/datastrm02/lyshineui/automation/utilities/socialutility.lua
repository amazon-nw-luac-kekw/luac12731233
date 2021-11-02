local Logger = RequireScript("LyShineUI.Automation.Logger")
local InputUtility = RequireScript("LyShineUI.Automation.Utilities.InputUtility")
local MenuUtility = RequireScript("LyShineUI.Automation.Utilities.MenuUtility")
local PopupUtility = RequireScript("LyShineUI.Automation.Utilities.PopupUtility")
local Timer = RequireScript("LyShineUI.Automation.Utilities.Timer")
local DataLayer = RequireScript("LyShineUI.UiDataLayer")
local Registrar = RequireScript("LyShineUI.EntityRegistrar")
local PlayerFlyoutHandler = RequireScript("LyShineUI.FlyoutMenu.PlayerFlyoutHandler")
RequireScript("LyShineUI.FlyoutMenu.FlyoutMenuHelper")
local SocialUtility = {
  ScreenName = "SocialPane",
  Sections = {},
  FlyoutActions = {}
}
function SocialUtility:Initialize()
  self.SocialPane = DynamicBus.SocialPane.Broadcast.GetTable()
  self.Sections = {
    GroupInvite = self.SocialPane.SocialMenu.section.GroupInvite,
    FriendInvite = self.SocialPane.SocialMenu.section.FriendInvite,
    GuildInvite = self.SocialPane.SocialMenu.section.GuildInvite,
    Online = self.SocialPane.SocialMenu.section.Online,
    Offline = self.SocialPane.SocialMenu.section.Offline,
    Blocked = self.SocialPane.SocialMenu.section.Blocked,
    Muted = self.SocialPane.SocialMenu.section.Muted
  }
  self.FlyoutActions = {
    GroupInvite = PlayerFlyoutHandler.PFH_OnGroupInvite,
    GuildInvite = PlayerFlyoutHandler.PFH_OnGuildInvite,
    FriendInvite = PlayerFlyoutHandler.PFH_OnFriendInvite,
    AcceptFriendInvite = PlayerFlyoutHandler.PFH_OnAcceptFriendInvite,
    RejectFriendInvite = PlayerFlyoutHandler.PFH_OnRejectFriendInvite,
    InitiateTrade = PlayerFlyoutHandler.PFH_OnInitiateTrade,
    DuelPlayer = PlayerFlyoutHandler.PFH_PFH_OnDuelPlayer,
    MutePlayer = PlayerFlyoutHandler.PFH_OnMutePlayer,
    UnmutePlayer = PlayerFlyoutHandler.PFH_OnUnmutePlayer,
    BlockPlayer = PlayerFlyoutHandler.PFH_OnBlockPlayer,
    UnblockPlayer = PlayerFlyoutHandler.PFH_OnUnblockPlayer
  }
  self.SocialMenuCategories = {
    Invite = {
      button = self.SocialPane.Properties.NewInviteButton
    },
    Group = {
      button = self.SocialPane.Properties.AddToGroupButton
    }
  }
end
local function Log(msg)
  Logger:Log("[SocialUtility] " .. tostring(msg))
end
function SocialUtility:OpenSocialPane()
  InputUtility:PressKey("toggleSocialWindow")
end
function SocialUtility:CloseSocialPane()
  if self:IsNavBarOpen() then
    InputUtility:PressKey("toggleMenuComponent")
  end
end
function SocialUtility:IsSocialPaneOpen()
  return self.SocialPane.isShowing
end
function SocialUtility:IsSocialMenuOpen()
  return self.SocialPane.SocialMenu.isEnabled
end
function SocialUtility:IsNavBarOpen()
  return DataLayer:IsScreenOpen("NavBar")
end
function SocialUtility:OpenSocialMenuCategory(category)
  self:OpenNavBar()
  MenuUtility:ClickButton(category.button)
  while not self:IsSocialMenuOpen() do
    coroutine.yield()
  end
end
function SocialUtility:OpenNavBar()
  if not self:IsNavBarOpen() then
    InputUtility:PressKey("toggleMenuComponent")
    while not self:IsNavBarOpen() do
      coroutine.yield()
    end
  end
end
function SocialUtility:SearchForPlayer(playerName)
  Log("Info: searching for player with name " .. playerName)
  MenuUtility:ClickButton(self.SocialPane.SocialMenu.SearchTextInput)
  InputUtility:TypeString(playerName)
  Log("Info: waiting for search results")
  while self.SocialPane.SocialMenu.displayingMatches == 0 do
    coroutine.yield()
  end
  local playerButton
  while playerButton == nil do
    local entityId = UiDynamicScrollBoxBus.Event.GetChildAtElementIndex(self.SocialPane.SocialMenu.Properties.DropdownListScrollbox, 0)
    local entityTable = Registrar:GetEntityTable(entityId)
    if entityTable.playerName == playerName then
      playerButton = entityTable
    end
    coroutine.yield()
  end
  return playerButton
end
function SocialUtility:GetFirstElementInSection(section)
  local entity
  local entityId = UiDynamicScrollBoxBus.Event.GetEntityIdAtElementIndexInSection(self.SocialPane.SocialMenu.Properties.ListHolder, section - 1, 0)
  if entityId ~= nil then
    entity = Registrar:GetEntityTable(entityId)
  end
  if entity == nil then
    error("No elements found in section " .. section)
  end
  return entity
end
function SocialUtility:FocusOnPlayerButton(playerButton)
  InputUtility:SetCursorPosition(MenuUtility:GetObjectViewportPosition(playerButton))
  Log("Info: waiting for flyout")
  while not DataLayer:GetDataFromNode("Hud.LocalPlayer.Flyout.IsVisible") do
    coroutine.yield()
  end
  coroutine.yield()
end
function SocialUtility:ExecuteFlyoutAction(action)
  local button
  for key, entityId in pairs(GetFlyoutMenu().rowEntities) do
    local row = Registrar:GetEntityTable(entityId)
    if row.options then
      for _, option in pairs(row.options) do
        if option.callback == action then
          button = option.entity
          break
        end
      end
    end
  end
  if button == nil then
    error("Button with given action not found")
  end
  MenuUtility:ClickButton(button)
end
function SocialUtility:SearchForPlayerAndExecuteAction(playerName, action)
  local playerButton = self:SearchForPlayer(playerName)
  self:FocusOnPlayerButton(playerButton)
  return self:ExecuteFlyoutAction(action)
end
function SocialUtility:GetFirstPlayerInSectionAndExecuteAction(section, action)
  local playerButton = self:GetFirstElementInSection(section)
  self:FocusOnPlayerButton(playerButton)
  self:ExecuteFlyoutAction(action)
end
function SocialUtility:InviteToFriends(playerName)
  self:SearchForPlayerAndExecuteAction(playerName, self.FlyoutActions.FriendInvite)
end
function SocialUtility:AcceptFriendInvite()
  self:GetFirstPlayerInSectionAndExecuteAction(self.Sections.FriendInvite, self.FlyoutActions.AcceptFriendInvite)
end
function SocialUtility:InviteToGroup(playerName)
  self:SearchForPlayerAndExecuteAction(playerName, self.FlyoutActions.GroupInvite)
end
function SocialUtility:AcceptGroupInvite()
  local playerButton = self:GetFirstElementInSection(self.Sections.GroupInvite)
  local groupId
  MenuUtility:ClickButton(playerButton.Properties.AcceptButton)
  Log("Info: waiting for group id change")
  while groupId == nil or not groupId:IsValid() do
    groupId = DataLayer:GetDataFromNode("Hud.LocalPlayer.Group.Id")
    coroutine.yield()
  end
end
function SocialUtility:InviteToGuild(playerName)
  self:SearchForPlayerAndExecuteAction(playerName, self.FlyoutActions.GuildInvite)
end
function SocialUtility:AcceptGuildInvite()
  local playerButton = self:GetFirstElementInSection(self.Sections.GuildInvite)
  local guildId
  MenuUtility:ClickButton(playerButton.Properties.AcceptButton)
  Log("Info: waiting for guild id change")
  while guildId == nil or not guildId:IsValid() do
    guildId = DataLayer:GetDataFromNode("Hud.LocalPlayer.Guild.Id")
    coroutine.yield()
  end
end
function SocialUtility:MutePlayer(playerName)
  self:SearchForPlayerAndExecuteAction(playerName, self.FlyoutActions.MutePlayer)
  PopupUtility:WaitUntilAnyPopupIsOpen()
  PopupUtility:PopupClickPositive()
end
function SocialUtility:BlockPlayer(playerName)
  self:SearchForPlayerAndExecuteAction(playerName, self.FlyoutActions.BlockPlayer)
  PopupUtility:WaitUntilAnyPopupIsOpen()
  PopupUtility:PopupClickPositive()
end
return SocialUtility
