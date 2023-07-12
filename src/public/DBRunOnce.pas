unit DBRunOnce;

interface

uses
  Windows;

function CheckRunOnce(IDStr: string): Boolean;

implementation

var
  MutexHandle: THandle = 0;

function CheckRunOnce(IDStr: string): Boolean;
begin
  MutexHandle := CreateMutex(nil, TRUE, PChar(IDStr));
  if MutexHandle <> 0 then
  begin
    if GetLastError = ERROR_ALREADY_EXISTS then
    begin
      CloseHandle(MutexHandle);
      Result := False;
      Exit;
    end;
  end;
  Result := True;
end;

initialization

finalization
  if MutexHandle <> 0 then
    CloseHandle(MutexHandle);

end.
