; Обёртка (wrapper) для RVC Android@Windows, позволяющий запускать сервер только путём запуска этой программы
; без необходимости нажимать кнопку "Start!" в главном окне сервера
;
; Wrapper for RVC Android@Windows, allowing start server via with this program
; without manual clicking on "Start!" button in server's main window
; 
; Сам сервер взят отсюда: http://4pda.ru/forum/index.php?showtopic=209914
;
; Автор обёртки, Wrapper author: dls, codelans@gmail.com
; 07.02.2013

Dim $server_name = "AndroidServer.exe"
Dim $port = 15900

Func GetHwndFromPID($PID)
	; Ищем Window Handler ($hWnd) 
	; по известному Process Id ($aPID)
	Dim $PID_current = ""	
	Dim $hWnd = ""	
	$theWinlist = Winlist()
		Do
			For $i = 1 To $theWinlist[0][0]
				If $theWinlist[$i][0] <> "" Then
					$PID_current = WinGetProcess($theWinlist[$i][1])
					If $PID_current = $PID Then
						$hWnd = $theWinlist[$i][1]
						ExitLoop
					EndIf
				EndIf
			Next
		Until $hWnd <> 0
		
	Return $hWnd
EndFunc

Func print_help()
	ConsoleWrite(@CRLF)
	ConsoleWrite("Wrapper for RVC Android@Windows allowing start it automatically." & @CRLF)
	ConsoleWrite("  In Windows Vista/7 you should start this with admin privilegies" & @CRLF)
	ConsoleWrite("  because of original RVC Android@Windows requires them" & @CRLF)
	ConsoleWrite("Usage: " & @ScriptName & " [-port <number>] [-exe <exe name or full path>] [-h|-help]" & @CRLF)
	ConsoleWrite("* Where -port is port for server binding (default: " & $port & ")" & @CRLF)
	ConsoleWrite("*       -exe is path to server's exe (default local: " & $server_name & ")" & @CRLF)
	ConsoleWrite("*       -h or -help for print this message" & @CRLF)
	ConsoleWrite(@CRLF)
	ConsoleWrite("Author: dls; codelans@gmail.com" & @CRLF)
	ConsoleWrite("version 0.1; 07.02.2013" & @CRLF)	
EndFunc

; Пробегаем по входным параметрам
for $Param = 1 To $CmdLine[0]
	Switch $CmdLine[$Param]
		Case "-port"
			If ($Param+1 <= $CmdLine[0]) and StringIsInt($CmdLine[$Param+1]) Then ; не выходим ли за границы массива				
				$port = $CmdLine[$Param+1]
				$Param = $Param + 1 ; пропускаем одну итерацию
				ContinueLoop
			else
				ConsoleWriteError("Error: incorrect -port parameter" & @CRLF)				
				print_help()
				Exit 1
			EndIf
		Case "-exe"
			If $Param+1 <= $CmdLine[0] and FileExists($CmdLine[$Param+1]) Then ; не выходим ли за границы массива
				$server_name = $CmdLine[$Param+1]
				$Param = $Param + 1 ; пропускаем одну итерацию
				ContinueLoop
			else
				ConsoleWriteError("Error: incorrect -exe parameter" & @CRLF)				
				print_help()
				Exit 1
			EndIf
		Case "-help", "-h"
			print_help()
			Exit 0
		Case Else
			ConsoleWriteError("Error: Unknown parameter '" & $CmdLine[$Param] & "'" & @CRLF)
			print_help()
			Exit 1
	EndSwitch
Next

; Запускаем сервер, если не найден
if Not ProcessExists($server_name) Then
	Run($server_name)
Endif

ProcessWait ($server_name, 7)

; Если не удалось запустить - выходим
Dim $pid = ProcessExists($server_name)
if not $pid Then
	MsgBox(16, $server_name & " не найлен", "Не удается ни найти уже запущенный " & $server_name & ","& @CRLF & _
	"ни запустить самостоятельно." & @CRLF & "Недостаточно прав?" & @CRLF & _
	"Запустите с правами адмнинистратора (требование самого сервера)" & @CRLF & _
	"Указали путь не к тому файлу?" & @CRLF & _
	"Вероятно правильный .exe сервера - AndroidServer.exe " & @CRLF & _
	"Ошибка в самом " & $server_name & "?" & @CRLF & _
	"Попробуйте запустить сервер вручную, без этой обёртки." & @CRLF)
	Exit 1
Else ; процесс в памяти есть, получаем handler окна	
	Dim $hwnd = GetHwndFromPID($pid)
Endif


WinSetState($hwnd, "", @SW_RESTORE)

; Если новый порт отличается от старого
; Нужен для случая, если сервер уже запущен, чтобы зря его не перезапускать
Dim $old_port = ControlGetText($hwnd, "", "[REGEXPCLASS:WindowsForms10\.EDIT; INSTANCE:1]") 
if $old_port <> $port Then
	ControlSetText($hwnd, "", "[REGEXPCLASS:WindowsForms10\.EDIT; INSTANCE:1]", $port)
	
	; если уже запущен - останавливаем
	; чтобы перезапустить с новым портом
	if ControlGetHandle($hwnd, "", "[REGEXPCLASS:WindowsForms10\.BUTTON; INSTANCE:1; TEXT:Stop!]") Then
		ControlClick($hwnd, "", "[REGEXPCLASS:WindowsForms10\.BUTTON; INSTANCE:1; TEXT:Stop!]")
	EndIf
Endif

; Запускаем сервер путём клика на "Start!"
$a = ControlClick($hwnd, "", "[REGEXPCLASS:WindowsForms10\.BUTTON; TEXT:Start!]")

WinSetState($hwnd, "", @SW_SHOW)


