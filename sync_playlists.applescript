-- To install:
--  1. Compile: `osacompile -o sync_playlists.app sync_playlists.applescript
--  2. Install: `mkdir -p ~/Library/Music/Scripts; mv sync_playlists.app ~/Library/Music/Scripts/
global originalDelimiter
global illegalCharacters1
global illegalCharacters2
global tmpdir

set originalDelimiter to AppleScript's text item delimiters
set tmpdir to my make_dir("/tmp/", "playlists")

set illegalCharacters1 to {"~", "?", "!", "@", "#", "$", "%", "&", "*", "=", "+", "{", "}", "<", ">", "|", "\\", "/", ";", ":", "×", "÷"}
set illegalCharacters2 to {"'", "\"", ",", "`", "^", "˘"}

-- `illegalCharacters1`: will be converted to "_"
-- `illegalCharacters2`: will be removed from name

tell application "Music"
	--set all_ps to (get name of every user playlist whose smart is false and special kind is none)
	set all_pls to (get every user playlist whose smart is false and special kind is none)
	repeat with plist in all_pls
		--set end of mydata to (get name of  pl) & " - " & (get the count of every track in pl)
		set playlistName to my clean_name(name of plist)
		log (playlistName)
		set plistTracks to (get tracks of plist)

		set playlistFilePath to tmpdir & playlistName & ".m3u"

		my clear_file(playlistFilePath)
		set playlistFile to open for access (POSIX path of playlistFilePath) with write permission
		--tell current application to write ("#EXTM3U" & return) to playlistFile
		write ("#EXTM3U" & return) to playlistFile

		repeat with aTrack in plistTracks
			set trackDur to duration of aTrack as integer
			set trackName to name of aTrack
			set trackArtist to artist of aTrack
			set loc to location of aTrack
			set trackPath to POSIX path of loc

			set m3uLine to ("#EXTINF:" & trackDur & "," & trackName & " - " & trackArtist & return)
			--tell current application
			write m3uLine to playlistFile
			write (trackPath & return) to playlistFile
			--end tell
		end repeat
		close access playlistFile
	end repeat
end tell

do shell script "$HOME/Library/Music/Scripts/rsync_playlists.sh"

on log_out(message, vars)
	set AppleScript's text item delimiters to ("
	")
	if (vars is missing value) then
		log ({message} as string)
	else
		log ({message, vars} as string)
	end if
	set AppleScript's text item delimiters to originalDelimiter
end log_out

(*
  DESCRIPTION: Cleans the illigal characters from a string.
  @param Str originalName = the string to clean
  @return Str - the cleaned string
*)
on clean_name(originalName)
	-- Clean accents
	set originalNameQuoted to (quoted form of (originalName as string))
	try
		set cleanAccents to (do shell script ({"echo ", originalNameQuoted, " | iconv -f UTF-8 -t ASCII//TRANSLIT"} as string))
	on error e number 1
		display dialog ({"Cannot clean ", originalNameQuoted, return, "Using original name …"} as string) with title myTitle buttons {"OK"} default button 1 with icon iconError giving up after 10
		set cleanAccents to originalNameQuoted
	end try

	-- Clean illegal characters 1
	set AppleScript's text item delimiters to illegalCharacters1
	set listName to every text item of cleanAccents
	set AppleScript's text item delimiters to "_"
	set listNameString to (listName as string)

	-- Clean illegal characters 2
	set AppleScript's text item delimiters to illegalCharacters2
	set listName to every text item of listNameString
	set AppleScript's text item delimiters to ""
	set listNameString to (listName as string)

	-- Return
	set AppleScript's text item delimiters to originalDelimiter
	return listNameString
end clean_name

(*
  DESCRIPTION: Make a folder if it doesn't exist.
  @param Str folderPath = path to root folder (in which to create new folder)
  @param Str newName = name of the new folder
  @return Str - path to the new folder (folderPath/newName)
*)
on make_dir(folderPath, newName)
	tell application "Finder"
		set newPath to ({POSIX path of folderPath as string, newName} as string)
		set found to ((do shell script ({"if [ -d \"", newPath, "\" ]; then echo 1; fi"} as string)) = "1")
		if (not found) then
			make new folder at (POSIX file folderPath) with properties {name:newName}
		end if
	end tell
	return ({newPath, "/"} as string)
end make_dir

on clear_file(filename)
	set found to ((do shell script ({"if [ -f \"", filename, "\" ]; then echo 1; fi"} as string)) = "1")
	if (found) then
		do shell script "rm \"" & filename & "\""
	end if
end clear_file
