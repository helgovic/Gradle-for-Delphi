unit URunBat;

interface

uses
  Windows, Messages, SysUtils, Classes, Forms, Dialogs;

type
  EPipeError = class(Exception);

function RunPipe(const psCommandLine, psWorkDir: string;
   const phInputHandle: THandle = 0): string; overload;
function Command(const Params, RunDir: string): string;

var
   LastCmd: String;
   LastOutput: String;

implementation

uses
  DateUtils, UFGetJars;

const
  BUFFER_SIZE = 4096;
  MAX_CMDLINE_SIZE = 32768;
  MAX_BUFFER_SIZE = 255;

function GetLastWindowsError : String;
var
  dwrdError          :  DWord;
  pchrBuffer         :  PChar;
begin
  dwrdError := GetLastError;
  GetMem(pchrBuffer, MAX_BUFFER_SIZE);
  try
    FormatMessage(FORMAT_MESSAGE_FROM_SYSTEM, nil, dwrdError, 0, pchrBuffer,
      MAX_BUFFER_SIZE, nil);
    Result := String(pchrBuffer);
  finally
    FreeMem(pchrBuffer, MAX_BUFFER_SIZE);
  end;
end;

function RunPipe(const psCommandLine, psWorkDir: string;
  const phInputHandle: THandle): String;
var
  iError, iBytesRead: Cardinal;
  hReadHandle, hWriteHandle: THandle;
  Security: TSecurityAttributes;
  ProcInfo: TProcessInformation;
  Buf: PByte;
  StartupInfo: TStartupInfo;
  bDone: Boolean;
  iCounter: Integer;
  ACmdLine: array[0..MAX_CMDLINE_SIZE] of Char;
  AWorkDir: array[0..MAX_PATH] of Char;
  ErrorMessage, sComSpec: string;
begin

  Result := '';

  sComSpec := Trim(GetEnvironmentVariable('COMSPEC'));

  Security.lpSecurityDescriptor := nil;
  Security.bInheritHandle := true;
  Security.nLength := SizeOf(Security);

  if CreatePipe(hReadHandle, hWriteHandle, @Security, BUFFER_SIZE) then
  begin
    try
      { Startup Info for command process }
      with StartupInfo do
      begin
        lpReserved := nil;
        lpDesktop := nil;
        lpTitle := nil;
        dwFlags := STARTF_USESTDHANDLES or STARTF_USESHOWWINDOW;
        cbReserved2 := 0;
        lpReserved2 := nil;
        { Prevent the command window being displayed }
        wShowWindow := SW_HIDE;
        { Standard Input - Default handle }
        if phInputHandle = 0 then
          hStdInput := GetStdHandle(STD_INPUT_HANDLE)
        else
          hStdInput := phInputHandle;
        { Standard Output - Point to Write end of pipe }
        hStdOutput := hWriteHandle;
        { Standard Error - Default handle }
        hStdError := GetStdHandle(STD_ERROR_HANDLE);
      end;

      StartupInfo.cb := SizeOf(StartupInfo);

      FillChar(ACmdLine[Low(ACmdLine)],
        Length(ACmdLine) * SizeOf(ACmdLine[Low(ACmdLine)]), 0);
      // 6 chars for '/C "' and '"#0'
      StrPCopy(ACmdLine,
        '/C "' + Copy(psCommandLine, 1, MAX_CMDLINE_SIZE - 6) + '"');

      FillChar(AWorkDir[Low(AWorkDir)],
        Length(AWorkDir) * SizeOf(AWorkDir[Low(AWorkDir)]), 0);
      StrPCopy(AWorkDir, Copy(psWorkDir, 1, MAX_CMDLINE_SIZE - 1));

      //BuildOptionExpert.LogLine(mtDebug, 'Executing: %s', [ACmdLine]);
      if CreateProcess(PChar(sComSpec), ACmdLine, nil, nil, True,
        CREATE_NEW_PROCESS_GROUP or NORMAL_PRIORITY_CLASS, nil, AWorkDir,
        StartupInfo, ProcInfo) then
      begin
        try
          { We don't need this handle any more, and keeping it open on this end
            will cause errors. It remains open for the child process though. }
          CloseHandle(hWriteHandle);
          { Allocate memory to the buffer }
          GetMem(Buf, BUFFER_SIZE * SizeOf(Char));
          try
            bDone := false;
            while not bDone do
            begin
              Application.ProcessMessages;
              if not Windows.ReadFile(hReadHandle, Buf^, BUFFER_SIZE,
                iBytesRead, nil) then
              begin
                iError := GetLastError;
                case iError of
                  ERROR_BROKEN_PIPE: // Broken pipe means client app has ended.
                    bDone := true;
                  ERROR_INVALID_HANDLE:
                    raise EPipeError.Create('Error: Invalid Handle');
                  ERROR_HANDLE_EOF:
                    raise EPipeError.Create('Error: End of file');
                  ERROR_IO_PENDING:
                    ; // Do nothing... just waiting
                  else
                    raise EPipeError.Create('Error: #' + IntToStr(iError));
                end;
              end;

              if iBytesRead > 0 then
              begin
                for iCounter := 0 to iBytesRead - 1 do
                  Result := Result + Char(PAnsiChar(Buf)[iCounter]);
              end;
            end;
          finally
            FreeMem(Buf, BUFFER_SIZE);
          end;
        finally
          CloseHandle(ProcInfo.hThread);
          CloseHandle(ProcInfo.hProcess);
        end
      end else
      begin
        ErrorMessage := GetLastWindowsError;
        CloseHandle(hWriteHandle);
        raise EPipeError.CreateFmt('Error: %s.'#13#10'(Command="%s")',
          [ErrorMessage, psCommandLine]);
      end;
    finally
      CloseHandle(hReadHandle);
    end;
  end;
end;

function Command(const Params, RunDir: string): string;
begin
  LastCmd := Params;
  LastOutput := RunPipe(LastCmd, RunDir);
  Result := LastOutput;
end;

end.

