local Logger = RequireScript("LyShineUI.Automation.Logger")
local InputUtility = RequireScript("LyShineUI.Automation.Utilities.InputUtility")
local DataLayer = RequireScript("LyShineUI.UiDataLayer")
local MenuUtility = RequireScript("LyShineUI.Automation.Utilities.MenuUtility")
local PopupUtility = {
  Popups = {}
}
local function Log(msg)
  Logger:Log("[PopupUtility] " .. tostring(msg))
end
function PopupUtility:Initialize()
  self.PopupScreen = DynamicBus.Popup.Broadcast.GetTable("PopupScreen")
  self.ConfirmationPopup = DynamicBus.ConfirmationPopup.Broadcast.GetTable("ConfirmationPopup")
  self.WarTutorialPopup = DynamicBus.WarTutorialPopup.Broadcast.GetTable("WarTutorialPopup")
  self.WarDeclarationPopup = DynamicBus.WarDeclarationPopup.Broadcast.GetTable("WarDeclarationPopup")
  self.Popups = {
    Popup = {
      Table = self.PopupScreen,
      ScreenName = "Popup",
      PositiveButton = self.PopupScreen.Properties.ButtonYes,
      NegativeButton = self.PopupScreen.Properties.ButtonNo,
      CloseButton = self.PopupScreen.Properties.ButtonClose
    },
    ConfirmationPopup = {
      Table = self.ConfirmationPopup,
      ScreenName = "ConfirmationPopup",
      PositiveButton = self.ConfirmationPopup.Properties.ConfirmationButton,
      NegativeButton = self.ConfirmationPopup.Properties.CancelButton
    },
    WarTutorialPopup = {
      Table = self.WarTutorialPopup,
      ScreenName = "WarTutorialPopup",
      CloseButton = self.WarTutorialPopup.Properties.CloseButton
    },
    WarDeclarationPopup = {
      Table = self.WarDeclarationPopup,
      ScreenName = "WarDeclarationPopup",
      PositiveButton = self.WarDeclarationPopup.Properties.DeclareButtonAccept,
      NegativeButton = self.WarDeclarationPopup.Properties.DeclareButtonCancel,
      CloseButton = self.WarDeclarationPopup.Properties.ConfirmationButtonExit
    }
  }
end
function PopupUtility:IsPopupOpen(popup)
  return DataLayer:IsScreenOpen(popup.ScreenName)
end
function PopupUtility:IsAnyPopupOpen()
  return self:GetOpenPopup() ~= nil
end
function PopupUtility:GetOpenPopup()
  for _, popup in pairs(self.Popups) do
    if self:IsPopupOpen(popup) then
      return popup
    end
  end
  return nil
end
function PopupUtility:WaitUntilPopupIsOpen(popup)
  Log("Info: waiting for popup " .. popup.ScreenName)
  while not self:IsPopupOpen(popup.ScreenName) do
    coroutine.yield()
  end
end
function PopupUtility:WaitUntilAnyPopupIsOpen()
  Log("Info: waiting for any popup")
  while not self:IsAnyPopupOpen() do
    coroutine.yield()
  end
end
local function Click(buttonName)
  popup = PopupUtility:GetOpenPopup()
  if popup == nil then
    error("No open popup")
  end
  if not popup[buttonName] then
    error("Popup doesn't have " .. buttonName .. " assigned")
  end
  MenuUtility:ClickButton(popup[buttonName])
end
function PopupUtility:PopupClickPositive()
  Click("PositiveButton")
end
function PopupUtility:PopupClickNegative()
  Click("NegativeButton")
end
function PopupUtility:PopupClickClose()
  Click("CloseButton")
end
return PopupUtility
