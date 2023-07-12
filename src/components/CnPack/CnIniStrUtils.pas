{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     �й����Լ��Ŀ���Դ�������������                         }
{                   (C)Copyright 2001-2023 CnPack ������                       }
{                   ------------------------------------                       }
{                                                                              }
{            ���������ǿ�Դ��������������������� CnPack �ķ���Э������        }
{        �ĺ����·�����һ����                                                }
{                                                                              }
{            ������һ��������Ŀ����ϣ�������ã���û���κε���������û��        }
{        �ʺ��ض�Ŀ�Ķ������ĵ���������ϸ���������� CnPack ����Э�顣        }
{                                                                              }
{            ��Ӧ���Ѿ��Ϳ�����һ���յ�һ�� CnPack ����Э��ĸ��������        }
{        ��û�У��ɷ������ǵ���վ��                                            }
{                                                                              }
{            ��վ��ַ��http://www.cnpack.org                                   }
{            �����ʼ���master@cnpack.org                                       }
{                                                                              }
{******************************************************************************}

unit CnIniStrUtils;
{* |<PRE>
================================================================================
* ������ƣ�������������
* ��Ԫ���ƣ���չ�� INI ���ʵ��ַ�������Ԫ
* ��Ԫ���ߣ���Х (liuxiao@cnpack.org)
* ��    ע���� CnIni ��Ԫ�������
* ����ƽ̨��PWin2000Pro + Delphi 5.0
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi 5/6
* �� �� �����õ�Ԫ�е��ַ��������ϱ��ػ�����ʽ
* �޸ļ�¼��2004.02.08 V1.0
*               �� CnIni ��Ԫ�з�����˵�Ԫ
================================================================================
|</PRE>}

interface

{$I CnPack.inc}

uses
  Classes, Graphics, {$IFDEF MSWINDOWS} Windows, {$ELSE} System.Types, System.UITypes, {$ENDIF} SysUtils;

//==============================================================================
// ������չ INI ����ַ�����������
//==============================================================================

function StringToFontStyles(const Styles: string): TFontStyles;
function FontStylesToString(Styles: TFontStyles): string;
function FontToString(Font: TFont): string;
function FontToStringEx(Font: TFont; BaseFont: TFont): string;
procedure StringToFont(const Str: string; Font: TFont);
procedure StringToFontEx(const Str: string; Font: TFont; BaseFont: TFont);
function RectToStr(Rect: TRect): string;
function StrToRect(const Str: string; const Def: TRect): TRect;
function PointToStr(P: TPoint): string;
function StrToPoint(const Str: string; const Def: TPoint): TPoint;

implementation

uses
  CnCommon;

const
  csLefts  = ['[', '{', '('];
  csRights = [']', '}', ')'];

//==============================================================================
// ������չ INI ����ַ�����������
//==============================================================================

function FontStylesToString(Styles: TFontStyles): string;
begin
  Result := '';
{$IFDEF MSWINDOWS}
  if fsBold in Styles then Result := Result + 'B';
  if fsItalic in Styles then Result := Result + 'I';
  if fsUnderline in Styles then Result := Result + 'U';
  if fsStrikeOut in Styles then Result := Result + 'S';
{$ELSE}
  if TFontStyle.fsBold in Styles then Result := Result + 'B';
  if TFontStyle.fsItalic in Styles then Result := Result + 'I';
  if TFontStyle.fsUnderline in Styles then Result := Result + 'U';
  if TFontStyle.fsStrikeOut in Styles then Result := Result + 'S';
{$ENDIF}
end;

function StringToFontStyles(const Styles: string): TFontStyles;
begin
  Result := [];
{$IFDEF MSWINDOWS}
  if Pos('B', UpperCase(Styles)) > 0 then Include(Result, fsBold);
  if Pos('I', UpperCase(Styles)) > 0 then Include(Result, fsItalic);
  if Pos('U', UpperCase(Styles)) > 0 then Include(Result, fsUnderline);
  if Pos('S', UpperCase(Styles)) > 0 then Include(Result, fsStrikeOut);
{$ELSE}
  if Pos('B', UpperCase(Styles)) > 0 then Include(Result, TFontStyle.fsBold);
  if Pos('I', UpperCase(Styles)) > 0 then Include(Result, TFontStyle.fsItalic);
  if Pos('U', UpperCase(Styles)) > 0 then Include(Result, TFontStyle.fsUnderline);
  if Pos('S', UpperCase(Styles)) > 0 then Include(Result, TFontStyle.fsStrikeOut);
{$ENDIF}
end;

function FontToString(Font: TFont): string;
{$IFDEF MSWINDOWS}
var
  S: string;
{$ENDIF}
begin
  with Font do
  begin
{$IFDEF MSWINDOWS}
    if not CharsetToIdent(Charset, S) then
      S := IntToStr(Charset);
    Result := Format('%s,%d,%s,%d,%s,%s', [Name, Size,
      FontStylesToString(Style), Ord(Pitch), ColorToString(Color), S]);
{$ELSE}
    Result := Format('%s,%f,%s', [Family, Size, FontStylesToString(Style)]);
{$ENDIF}
  end;
end;

function FontToStringEx(Font: TFont; BaseFont: TFont): string;
var
  AName, ASize, AStyle {$IFDEF MSWINDOWS}, APitch, AColor, ACharSet {$ENDIF}: string;
begin
  if BaseFont = nil then
    Result := FontToString(Font)
  else
  begin
    AName := '';
    ASize := '';
    AStyle := '';

    if Font.Style <> BaseFont.Style then
      AStyle := FontStylesToString(Font.Style);

{$IFDEF MSWINDOWS}
    if not SameText(Font.Name, BaseFont.Name) then
      AName := Font.Name;
    if Font.Size <> BaseFont.Size then
      ASize := IntToStr(Font.Size);

    if Font.Pitch <> BaseFont.Pitch then
      APitch := IntToStr(Ord(Font.Pitch))
    else
      APitch := '';
    if Font.Color <> BaseFont.Color then
      AColor := ColorToString(Font.Color)
    else
      AColor := '';
    if Font.Charset <> BaseFont.Charset then
    begin
      if not CharsetToIdent(Font.Charset, ACharSet) then
        ACharSet := IntToStr(Font.Charset);
    end
    else
      ACharSet := '';

    Result := Format('%s,%s,%s,%s,%s,%s', [AName, ASize, AStyle, APitch, AColor,
      ACharSet]);

{$ELSE}
    if not SameText(Font.Family, BaseFont.Family) then
      AName := Font.Family;
    if Font.Size <> BaseFont.Size then
      ASize := FloatToStr(Font.Size);

    Result := Format('%s,%s,%s', [AName, ASize, AStyle]);
{$ENDIF}
  end;
end;

type
  THackFont = class(TFont);

procedure StringToFont(const Str: string; Font: TFont);
begin
  StringToFontEx(Str, Font, nil);
end;

procedure StringToFontEx(const Str: string; Font: TFont; BaseFont: TFont);
const
  Delims = [',', ';'];
var
{$IFDEF MSWINDOWS}
  FontChange: TNotifyEvent;
  Charset: Longint;
{$ENDIF}
  Pos: Integer;
  I: Byte;
  S: string;
begin
  if Font = nil then
    Exit;
  try
{$IFDEF MSWINDOWS}
    FontChange := Font.OnChange;
    Font.OnChange := nil;
{$ENDIF}

    try
      if BaseFont <> nil then
        Font.Assign(BaseFont);
      Pos := 1;
      I := 0;
      while Pos <= Length(Str) do begin
        Inc(I);
        S := Trim(ExtractSubstr(Str, Pos, Delims));
        case I of
          1: if S <> '' then
             begin
{$IFDEF MSWINDOWS}
               Font.Name := S;
{$ELSE}
               Font.Family := S;
{$ENDIF}
             end;
          2: if S <> '' then
             begin
{$IFDEF MSWINDOWS}
               Font.Size := StrToIntDef(S, Font.Size);
{$ELSE}
               Font.Size := StrToFloatDef(S, Font.Size);
{$ENDIF}
             end;
          3: if S <> '' then Font.Style := StringToFontStyles(S) else Font.Style := [];
{$IFDEF MSWINDOWS}
          4: if S <> '' then Font.Pitch := TFontPitch(StrToIntDef(S, Ord(Font.Pitch)));
          5: if S <> '' then Font.Color := StringToColor(S);
          6: if S <> '' then
            begin
              if IdentToCharset(S, Charset) then
                Font.Charset := Charset
              else
                Font.Charset := TFontCharset(StrToIntDef(S, Font.Charset));
            end;
{$ENDIF}
        end;
      end;
    finally
{$IFDEF MSWINDOWS}
      Font.OnChange := FontChange;
      THackFont(Font).Changed;
{$ENDIF}
    end;
  except
    ;
  end;
end;

function RectToStr(Rect: TRect): string;
begin
  with Rect do
    Result := Format('[%d,%d,%d,%d]', [Left, Top, Right, Bottom]);
end;

function StrToRect(const Str: string; const Def: TRect): TRect;
var
  S: string;
  Temp: string;
  I: Integer;
begin
  Result := Def;
  S := Str;
  if CharInSet(S[1], csLefts) and CharInSet(S[Length(S)], csRights) then begin
    Delete(S, 1, 1); SetLength(S, Length(S) - 1);
  end;
  I := Pos(',', S);
  if I > 0 then begin
    Temp := Trim(Copy(S, 1, I - 1));
    Result.Left := StrToIntDef(Temp, Def.Left);
    Delete(S, 1, I);
    I := Pos(',', S);
    if I > 0 then begin
      Temp := Trim(Copy(S, 1, I - 1));
      Result.Top := StrToIntDef(Temp, Def.Top);
      Delete(S, 1, I);
      I := Pos(',', S);
      if I > 0 then begin
        Temp := Trim(Copy(S, 1, I - 1));
        Result.Right := StrToIntDef(Temp, Def.Right);
        Delete(S, 1, I);
        Temp := Trim(S);
        Result.Bottom := StrToIntDef(Temp, Def.Bottom);
      end;
    end;
  end;
end;

function PointToStr(P: TPoint): string;
begin
  with P do Result := Format('[%d,%d]', [X, Y]);
end;

function StrToPoint(const Str: string; const Def: TPoint): TPoint;
var
  S: string;
  Temp: string;
  I: Integer;
begin
  Result := Def;
  S := Str;
  if CharInSet(S[1], csLefts) and CharInSet(S[Length(Str)], csRights) then begin
    Delete(S, 1, 1); SetLength(S, Length(S) - 1);
  end;
  I := Pos(',', S);
  if I > 0 then begin
    Temp := Trim(Copy(S, 1, I - 1));
    Result.X := StrToIntDef(Temp, Def.X);
    Delete(S, 1, I);
    Temp := Trim(S);
    Result.Y := StrToIntDef(Temp, Def.Y);
  end;
end;

end.
