#@osa-lang:AppleScript
-- Get the URL from the clipboard
set myurl to (the clipboard)

-- Display a dialog with a text field to edit the URL
display dialog "Confirm the URL:" default answer myurl buttons {"Cancel", "Continue"} default button "Continue"
set {button_pressed, edited_url} to {button returned of the result, text returned of the result}
if button_pressed is not "Continue" then
	display dialog "Aborted."
	return
end if

-- Escape the URL
on encodeCharacter(theCharacter)
	set theASCIINumber to (the ASCII number theCharacter)
	set theHexList to {"0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "A", "B", "C", "D", "E", "F"}
	set theFirstItem to item ((theASCIINumber div 16) + 1) of theHexList
	set theSecondItem to item ((theASCIINumber mod 16) + 1) of theHexList
	return ("%" & theFirstItem & theSecondItem) as string
end encodeCharacter

on encodeText(theText, encodeCommonSpecialCharacters, encodeExtendedSpecialCharacters)
	set theStandardCharacters to "abcdefghijklmnopqrstuvwxyz0123456789"
	set theCommonSpecialCharacterList to "$+!'/?;&@=#%><{}\"~`^\\|*"
	set theExtendedSpecialCharacterList to ".-_:"
	set theAcceptableCharacters to theStandardCharacters
	if encodeCommonSpecialCharacters is false then set theAcceptableCharacters to theAcceptableCharacters & theCommonSpecialCharacterList
	if encodeExtendedSpecialCharacters is false then set theAcceptableCharacters to theAcceptableCharacters & theExtendedSpecialCharacterList
	set theEncodedText to ""
	repeat with theCurrentCharacter in theText
		if theCurrentCharacter is in theAcceptableCharacters then
			set theEncodedText to (theEncodedText & theCurrentCharacter)
		else
			set theEncodedText to (theEncodedText & encodeCharacter(theCurrentCharacter)) as string
		end if
	end repeat
	return theEncodedText
end encodeText
--set escaped_url to do shell script "echo " & quoted form of myurl & " | sed 's/[\\/\\&]/\\\\&/g'"
set escaped_url to encodeText(myurl, true, true)


-- Run the curl command and parse JSON
set get_url to "curl -s https://api.song.link/v1-alpha.1/links?url=" & quoted form of escaped_url
set response to do shell script "curl -s https://api.song.link/v1-alpha.1/links?url=" & quoted form of escaped_url

-- Extract the value of "pageUrl" using AppleScript
set pageUrl to text of (do shell script "echo " & quoted form of response & " | grep -o '\"pageUrl\":\"[^\"]*' | cut -d'\"' -f4")

-- Copy the value to clipboard
set the clipboard to pageUrl

display dialog "Universal song link: " & pageUrl & " copied to clipboard."
