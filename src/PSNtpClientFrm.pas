unit PSNtpClientFrm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.DateUtils,
  System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, IdBaseComponent, IdComponent, IdUDPBase,
  IdUDPClient, IdSNTP, Vcl.StdCtrls, Vcl.Mask, Vcl.ExtCtrls, Vcl.ComCtrls,
  System.IniFiles, System.Win.Registry, IdAntiFreezeBase, IdAntiFreeze, CnTrayIcon,
  Vcl.Menus, CnCommon, Vcl.Samples.Spin, CnInetUtils;

const
  SAppCaption = 'PlumeSoft 网络对时小工具';
  csAppVer = 'v1.1';

type
  TPSNtpClientForm = class(TForm)
    idsntp: TIdSNTP;
    grp1: TGroupBox;
    btnMin: TButton;
    btnClose: TButton;
    lbledtServer: TLabeledEdit;
    chkAutoSync: TCheckBox;
    dtpTime: TDateTimePicker;
    btnSync: TButton;
    tmr1: TTimer;
    lblLast: TLabel;
    lblSucc: TLabel;
    idntfrz1: TIdAntiFreeze;
    chkAutoRun: TCheckBox;
    pmTrayIcon: TPopupMenu;
    mniShow: TMenuItem;
    mniX1: TMenuItem;
    sePort: TSpinEdit;
    lblTime: TLabel;
    procedure lbledtServerChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure tmr1Timer(Sender: TObject);
    procedure btnSyncClick(Sender: TObject);
    procedure chkAutoSyncClick(Sender: TObject);
    procedure dtpTimeChange(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure mniShowClick(Sender: TObject);
    procedure chkAutoRunClick(Sender: TObject);
    procedure btnMinClick(Sender: TObject);
  private
    { Private declarations }
    FExiting: Boolean;
    FIni: TCustomIniFile;
    FUpdating: Boolean;
    FLastDate: TDateTime;
    FSuccDate: TDateTime;
    FLastSucc: Boolean;
    FTrayIcon: TCnTrayIcon;
    FSyncing: Boolean;
    procedure ReadCfg;
    procedure SaveCfg;
    procedure GetCfgFromControls;
    function DoSync: Boolean;
    function DoSyncHttp: Boolean;
    procedure UpdateLabel;
    procedure OnTrayIconClick(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure OnTrayIconDblClick(Sender: TObject);
    function GetAutoRun: Boolean;
    procedure SetAutoRun(const Value: Boolean);
    property AutoRun: Boolean read GetAutoRun write SetAutoRun;
  public
    { Public declarations }
  end;

var
  PSNtpClientForm: TPSNtpClientForm;

implementation

{$R *.dfm}

function ConvertUTCToLocalTime(UTCDateTime: TDateTime): TDateTime;
begin
  Result := TTimeZone.Local.ToLocalTime(UTCDateTime);
end;

function SetLocalTimeFromUTC(utcdt: TDateTime): Boolean;
var
  st: TSystemTime;
begin
  DateTimeToSystemTime(ConvertUTCToLocalTime(utcdt), st);
  Result := SetLocalTime(st);
end;

procedure TPSNtpClientForm.btnCloseClick(Sender: TObject);
begin
  if QueryDlg('确定要退出吗？') then
  begin
    FExiting := True;
    Close;
  end;
end;

procedure TPSNtpClientForm.btnMinClick(Sender: TObject);
begin
  FTrayIcon.HideApplication;
end;

procedure TPSNtpClientForm.btnSyncClick(Sender: TObject);
begin
  DoSync;
end;

procedure TPSNtpClientForm.chkAutoRunClick(Sender: TObject);
begin
  AutoRun := chkAutoRun.Checked;
end;

procedure TPSNtpClientForm.chkAutoSyncClick(Sender: TObject);
begin
  GetCfgFromControls;
end;

function TPSNtpClientForm.DoSync: Boolean;
begin
  Result := False;
  if FSyncing then
    Exit;

  FSyncing := True;
  try
    try
      if Pos('http://', lbledtServer.Text) = 1 then
        FLastSucc := DoSyncHttp
      else
      begin
        idsntp.Host := lbledtServer.Text;
        idsntp.Port := sePort.Value;
        FLastSucc := idsntp.SyncTime;
      end;
    except
      FLastSucc := False;
    end;
    FLastDate := Now;
    if FLastSucc then
      FSuccDate := Now;
    UpdateLabel;
    SaveCfg;
    Result := FLastSucc;
  finally
    FSyncing := False;
  end;
end;

function TPSNtpClientForm.DoSyncHttp: Boolean;
var
  TimeStr: string;
  DT: TDateTime;
  Delta: TDateTime;
begin
  TimeStr := string(CnInet_GetString(lbledtServer.Text));
  // 2023-10-18 09:29:20.443
  if Length(TimeStr) = 23 then
  begin
    if sePort.Value >= 0 then
      Delta := EncodeTime(0, 0, 0, sePort.Value)
    else
      Delta := -EncodeTime(0, 0, 0, -sePort.Value);

    DT := EncodeDate(
      StrToInt(Copy(TimeStr, 1, 4)),
      StrToInt(Copy(TimeStr, 6, 2)),
      StrToInt(Copy(TimeStr, 9, 2))) +
      EncodeTime(
      StrToInt(Copy(TimeStr, 12, 2)),
      StrToInt(Copy(TimeStr, 15, 2)),
      StrToInt(Copy(TimeStr, 18, 2)),
      StrToInt(Copy(TimeStr, 21, 3))) +
      Delta; // 毫秒补偿
    Result := SetLocalTimeFromUTC(DT);
  end
  else
    Result := False;
end;

procedure TPSNtpClientForm.dtpTimeChange(Sender: TObject);
begin
  GetCfgFromControls;
end;

procedure TPSNtpClientForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if not FExiting then
  begin
    Action := caNone;
    FTrayIcon.HideApplication;
  end;
end;

procedure TPSNtpClientForm.FormCreate(Sender: TObject);
begin
  Application.Title := SAppCaption + ' ' + csAppVer;
  Caption := Application.Title;
  FTrayIcon := TCnTrayIcon.Create(Self);
  FTrayIcon.OnClick := OnTrayIconClick;
  FTrayIcon.OnDblClick := OnTrayIconDblClick;
  FTrayIcon.PopupMenu := pmTrayIcon;
  FTrayIcon.UseAppIcon := True;
  FTrayIcon.Hint := Application.Title;
  FTrayIcon.Active := True;
  FIni := TRegistryIniFile.Create('Software\PlumeSoft\PSNtpClient');
  chkAutoRun.Checked := AutoRun;
  ReadCfg;
  UpdateLabel;
end;

procedure TPSNtpClientForm.FormDestroy(Sender: TObject);
begin
  FIni.Free;
end;

procedure TPSNtpClientForm.OnTrayIconDblClick(Sender: TObject);
begin
  mniShowClick(nil);
end;

procedure TPSNtpClientForm.OnTrayIconClick(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  mniShowClick(nil);
end;

function TPSNtpClientForm.GetAutoRun: Boolean;
begin
  with TRegistryIniFile.Create('Software\Microsoft\Windows\CurrentVersion\Run') do
  try
    Result := ReadString('', 'PSNtpClient', '') <> '';
  finally
    Free;
  end;
end;

procedure TPSNtpClientForm.GetCfgFromControls;
begin
  if FUpdating then
    Exit;
  FUpdating := True;
  try
    SaveCfg;
  finally
    FUpdating := False;
  end;
end;

procedure TPSNtpClientForm.lbledtServerChange(Sender: TObject);
begin
  GetCfgFromControls;
end;

procedure TPSNtpClientForm.mniShowClick(Sender: TObject);
begin
  FTrayIcon.ShowApplication;
  BringToFront;
end;

procedure TPSNtpClientForm.ReadCfg;
begin
  FUpdating := True;
  try
    lbledtServer.Text := FIni.ReadString('', 'Host', 'time.pool.aliyun.com');
    sePort.Value := FIni.ReadInteger('', 'Port', 123);
    chkAutoSync.Checked := FIni.ReadBool('', 'AutoSync', True);
    dtpTime.Time := FIni.ReadTime('', 'SyncTime', EncodeTime(8, 0, 0, 0));
    FLastDate := FIni.ReadDateTime('', 'LastDate', 0);
    FSuccDate := FIni.ReadDateTime('', 'SuccDate', 0);
    FLastSucc := FIni.ReadBool('', 'LastSucc', False);
  finally
    FUpdating := False;
  end;
end;

procedure TPSNtpClientForm.SaveCfg;
begin
  FIni.WriteString('', 'Host', lbledtServer.Text);
  FIni.WriteInteger('', 'Port', sePort.Value);
  FIni.WriteBool('', 'AutoSync', chkAutoSync.Checked);
  FIni.WriteTime('', 'SyncTime', dtpTime.Time);
  FIni.WriteDateTime('', 'LastDate', FLastDate);
  FIni.WriteDateTime('', 'SuccDate', FSuccDate);
  FIni.WriteBool('', 'LastSucc', FLastSucc);
end;

procedure TPSNtpClientForm.SetAutoRun(const Value: Boolean);
begin
  with TRegistryIniFile.Create('Software\Microsoft\Windows\CurrentVersion\Run') do
  try
    if Value then
      WriteString('', 'PSNtpClient', Format('"%s" -min', [Application.ExeName]))
    else
      DeleteKey('', 'PSNtpClient');
  finally
    Free;
  end;
end;

procedure TPSNtpClientForm.tmr1Timer(Sender: TObject);
begin
  if chkAutoSync.Checked and (Date <> Int(FLastDate)) and (Time >= dtpTime.Time) then
  begin
    DoSync;
  end;
  lblTime.Caption := '当前时间: ' + DateTimeToStr(Now);
end;

procedure TPSNtpClientForm.UpdateLabel;
const
  csBools: array[Boolean] of string = ('失败', '成功');
begin
  if FLastDate > 0 then
    lblLast.Caption := '最后对时: ' + DateTimeToStr(FLastDate) + ' 对时' + csBools[FLastSucc]
  else
    lblLast.Caption := '最后对时: ' + '无';
  if FSuccDate > 0 then
    lblSucc.Caption := '成功对时: ' + DateTimeToStr(FSuccDate)
  else
    lblSucc.Caption := '成功对时: ' + '无';
end;

end.
