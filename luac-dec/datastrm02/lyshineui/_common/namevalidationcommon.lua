local NameValidationCommon = {}
function NameValidationCommon:CheckNameValid(text)
  local validationResult = UiCharacterServiceRequestBus.Broadcast.PreValidateNameCheck(text)
  local errorString = ""
  if validationResult == eValidStringResponse_TooShort then
    errorString = "@mm_invalidname_minlength"
  elseif validationResult == eValidStringResponse_TooLong then
    errorString = "@mm_invalidname_maxlength"
  elseif validationResult == eValidStringResponse_InvalidCharacters then
    errorString = "@mm_invalidname_corrupt"
  elseif validationResult == eValidStringResponse_BadWords then
    errorString = "@mm_invalidname_badwords"
  elseif validationResult == eValidStringResponse_MultipleSpaces then
    errorString = "@mm_invalidname_multiplespaces"
  end
  return validationResult, errorString
end
function NameValidationCommon:TrimString(s)
  return (s:gsub("^%s*(.-)%s*$", "%1"))
end
return NameValidationCommon
