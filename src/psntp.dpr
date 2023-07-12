program psntp;

uses
  Vcl.Forms,
  System.SysUtils,
  PSNtpClientFrm in 'PSNtpClientFrm.pas' {PSNtpClientForm},
  DBRunOnce in 'public\DBRunOnce.pas';

{$R *.res}

begin
  Application.Initialize;
  if not CheckRunOnce('{D1235738-EB7B-4889-834E-E078690F7147}') then
    Exit;

  if FindCmdLineSwitch('min') then
  begin
    Application.MainFormOnTaskbar := False;
    Application.ShowMainForm := False;
  end
  else
    Application.MainFormOnTaskbar := True;
  Application.CreateForm(TPSNtpClientForm, PSNtpClientForm);
  Application.Run;
end.
