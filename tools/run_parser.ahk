#Requires AutoHotkey v2.0

; Check if the file "port.txt" exists
if (FileExist("port.txt")) {
    ; If it exists, delete the file
    FileDelete "port.txt"
}

; Run the command
; exitCode := Run("cmd /c parser.exe > output.txt  2> error.txt", "", "hide")
exitCode := Run("cmd /c parser.exe", "", "hide")
