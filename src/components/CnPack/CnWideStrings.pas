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

unit CnWideStrings;
{* |<PRE>
================================================================================
* ������ƣ�������������
* ��Ԫ���ƣ�WideStrings ��Ԫ��֧�� Win32/64 �� Posix
* ��Ԫ���ߣ�CnPack ������
* ��    ע���õ�Ԫʵ���˼򻯵� TCnWideStringList ���벿�� Unicode �ַ���������
*           �Լ���չ�� UTF8 �� UTF16 �ı���뺯����֧�� UTF16 �е����ֽ��ַ��� UTF8-MB4
* ����ƽ̨��WinXP SP3 + Delphi 5.0
* ���ݲ��ԣ�
* �� �� �����õ�Ԫ�е��ַ��������ϱ��ػ�����ʽ
* �޸ļ�¼��2022.11.25 V1.2
*               �� CnGB18030 �а��ƹ������� Unicode ������
*           2022.11.10 V1.1
*               UTF8 �������֧�� UTF8-MB4 �� UTF16 �е����ֽ��ַ�
*           2010.01.16 by ZhouJingyu
*               ��ʼ���ύ
================================================================================
|</PRE>}

interface

{$I CnPack.inc}

// {$DEFINE UTF16_BE}

// Delphi Ĭ�� UTF16-LE�����Ҫ���� UTF16-BE �ַ�������Ҫ���� UTF16_BE

uses
  {$IFDEF MSWINDOWS} Windows, {$ENDIF} SysUtils, Classes, IniFiles, CnNative;

const
  CN_INVALID_CODEPOINT = $FFFFFFFF;
  {* �Ƿ������ֵ}

  CN_ALTERNATIVE_CHAR  = '?';
  {* ����ת����������ʱ��Ĭ���滻�ַ�}

type
{$IFDEF UNICODE}
  TCnWideString = string;
{$ELSE}
  TCnWideString = WideString;
{$ENDIF}

  TCnCodePoint = type Cardinal;
  {* �ַ���ֵ�����߽���㣬�����ڱ��ı��뷽ʽ}

  TCn2CharRec = packed record
  {* ˫�ֽ��ַ��ṹ}
    P1: AnsiChar;
    P2: AnsiChar;
  end;
  PCn2CharRec = ^TCn2CharRec;

  TCn4CharRec = packed record
  {* ���ֽ��ַ��ṹ}
    P1: AnsiChar;
    P2: AnsiChar;
    P3: AnsiChar;
    P4: AnsiChar;
  end;
  PCn4CharRec = ^TCn4CharRec;

{ TCnWideStringList }

  TCnWideListFormat = (wlfAnsi, wlfUtf8, wlfUnicode);

  TCnWideStringList = class;
  TCnWideStringListSortCompare = function(List: TCnWideStringList; Index1, Index2: Integer): Integer;

  PCnWideStringItem = ^TCnWideStringItem;
  TCnWideStringItem = record
    FString: WideString;
    FObject: TObject;
  end;

  TCnWideStringList = class(TPersistent)
  {* WideString ��� TStringList ʵ��}
  private
    FList: TList;
    function GetName(Index: Integer): WideString;
    function GetValue(const Name: WideString): WideString;
    procedure SetValue(const Name, Value: WideString);
    procedure QuickSort(L, R: Integer; SCompare: TCnWideStringListSortCompare);
    function GetObject(Index: Integer): TObject;
    procedure PutObject(Index: Integer; const Value: TObject);
  protected
    function Get(Index: Integer): WideString; virtual;
    function GetCount: Integer; virtual;
    function GetTextStr: WideString; virtual;
    procedure Put(Index: Integer; const S: WideString); virtual;
    procedure SetTextStr(const Value: WideString); virtual;
  public
    constructor Create;
    destructor Destroy; override;
    function Add(const S: WideString): Integer; virtual;
    procedure AddStrings(Strings: TCnWideStringList); virtual;
    function AddObject(const S: string; AObject: TObject): Integer; virtual;
    procedure Assign(Source: TPersistent); override;
    procedure Clear; virtual;
    procedure Delete(Index: Integer); virtual; 
    procedure Exchange(Index1, Index2: Integer); virtual;
    function IndexOf(const S: WideString): Integer; virtual;
    function IndexOfName(const Name: WideString): Integer;
    procedure Insert(Index: Integer; const S: WideString); virtual;
    procedure LoadFromFile(const FileName: WideString); virtual;
    procedure LoadFromStream(Stream: TStream); virtual;
    procedure SaveToFile(const FileName: WideString; AFormat: TCnWideListFormat = wlfUnicode); virtual;
    procedure SaveToStream(Stream: TStream; AFormat: TCnWideListFormat = wlfUnicode); virtual;
    procedure CustomSort(Compare: TCnWideStringListSortCompare); virtual;
    procedure Sort; virtual;
    property Count: Integer read GetCount;
    property Names[Index: Integer]: WideString read GetName;
    property Objects[Index: Integer]: TObject read GetObject write PutObject;
    property Values[const Name: WideString]: WideString read GetValue write SetValue;
    property Strings[Index: Integer]: WideString read Get write Put; default;
    property Text: WideString read GetTextStr write SetTextStr;
  end;

{ TCnWideMemIniFile }

  TCnWideMemIniFile = class(TMemIniFile)
  public
    constructor Create(const AFileName: string);
    procedure UpdateFile; override;
  end;

function CnUtf8EncodeWideString(const S: WideString): AnsiString;
{* �� WideString ���� Utf8 ����õ� AnsiString������ Ansi ת�����ⶪ�ַ�
  ֧�����ֽ� UTF16 �ַ��� UTF8-MB4}

function CnUtf8DecodeToWideString(const S: AnsiString): WideString;
{* �� AnsiString �� Utf8 ����õ� WideString������ Ansi ת�����ⶪ�ַ�
  ֧�����ֽ� UTF16 �ַ��� UTF8-MB4}

function GetUtf16HighByte(Rec: PCn2CharRec): Byte; {$IFDEF SUPPORT_INLINE} inline; {$ENDIF}
{* �õ�һ�� UTF 16 ˫�ֽ��ַ��ĸ�λ�ֽ�ֵ}

function GetUtf16LowByte(Rec: PCn2CharRec): Byte; {$IFDEF SUPPORT_INLINE} inline; {$ENDIF}
{* �õ�һ�� UTF 16 ˫�ֽ��ַ��ĵ�λ�ֽ�ֵ}

procedure SetUtf16HighByte(B: Byte; Rec: PCn2CharRec); {$IFDEF SUPPORT_INLINE} inline; {$ENDIF}
{* ����һ�� UTF 16 ˫�ֽ��ַ��ĸ�λ�ֽ�ֵ}

procedure SetUtf16LowByte(B: Byte; Rec: PCn2CharRec); {$IFDEF SUPPORT_INLINE} inline; {$ENDIF}
{* ����һ�� UTF 16 ˫�ֽ��ַ��ĵ�λ�ֽ�ֵ}

function GetCharLengthFromUtf8(Utf8Str: PAnsiChar): Integer;
{* ����һ UTF8�������� UTF8-MB4���ַ������ַ���}

function GetCharLengthFromUtf16(Utf16Str: PWideChar): Integer;
{* ����һ UTF16�����ܻ�� Unicode ��չƽ��������ֽ��ַ����ַ������ַ���}

function GetByteWidthFromUtf8(Utf8Str: PAnsiChar): Integer;
{* ����һ UTF8�������� UTF8-MB4���ַ����ĵ�ǰ�ַ�ռ�����ֽ�}

function GetByteWidthFromUtf16(Utf16Str: PWideChar): Integer;
{* ����һ UTF16�����ܻ�� Unicode ��չƽ��������ֽ��ַ����ַ����ĵ�ǰ�ַ�ռ�����ֽ�}

function GetCodePointFromUtf16Char(Utf16Str: PWideChar): TCnCodePoint;
{* ����һ�� Utf16 �ַ��ı���ֵ��Ҳ�д���λ�ã���ע�� Utf16Str ����ָ��һ��˫�ֽ��ַ���Ҳ����ָ��һ�����ֽ��ַ�}

function GetCodePointFromUtf164Char(PtrTo4Char: Pointer): TCnCodePoint;
{* ����һ�����ֽ� Utf16 �ַ��ı���ֵ��Ҳ�д���λ�ã�}

function GetUtf16CharFromCodePoint(CP: TCnCodePoint; PtrToChars: Pointer): Integer;
{* ����һ�� Unicode ����ֵ�Ķ��ֽڻ����ֽڱ�ʾ����� PtrToChars ָ���λ�ò�Ϊ�գ�
  �򽫽������ PtrToChars ��ָ�Ķ��ֽڻ����ֽ�����
  �������� CP ���� $FFFF ʱ�뱣֤ PtrToChars ��ָ�������������ֽڣ���֮���ֽڼ���
  ���� 1 �� 2���ֱ��ʾ������Ƕ��ֽڻ����ֽ�}

implementation

uses
  CnGB18030;

const
  CN_UTF16_4CHAR_PREFIX1_LOW  = $D8;
  CN_UTF16_4CHAR_PREFIX1_HIGH = $DC;
  CN_UTF16_4CHAR_PREFIX2_LOW  = $DC;
  CN_UTF16_4CHAR_PREFIX2_HIGH = $E0;

  CN_UTF16_4CHAR_HIGH_MASK    = $3;
  CN_UTF16_4CHAR_SPLIT_MASK   = $3FF;

  CN_UTF16_EXT_BASE           = $10000;

{ TCnWideStringList }

function WideCompareText(const S1, S2: WideString): Integer;
begin
{$IFDEF MSWINDOWS}
  Result := CompareStringW(LOCALE_USER_DEFAULT, NORM_IGNORECASE, PWideChar(S1),
    Length(S1), PWideChar(S2), Length(S2)) - 2;
{$ELSE}
  Result := WideCompareStr(S1, S2);
{$ENDIF}
end;

function TCnWideStringList.Add(const S: WideString): Integer;
begin
  Result := Count;
  Insert(Count, S);
end;

function TCnWideStringList.AddObject(const S: string;
  AObject: TObject): Integer;
begin
  Result := Add(S);
  PutObject(Result, AObject);
end;

procedure TCnWideStringList.AddStrings(Strings: TCnWideStringList);
var
  I: Integer;
begin
  for I := 0 to Strings.Count - 1 do
    Add(Strings[I]);
end;

procedure TCnWideStringList.Assign(Source: TPersistent);
begin
  if Source is TCnWideStringList then
  begin
    Clear;
    AddStrings(TCnWideStringList(Source));
    Exit;
  end;
  inherited Assign(Source);
end;

procedure TCnWideStringList.Clear;
var
  I: Integer;
  P: PCnWideStringItem;
begin
  for I := 0 to Count - 1 do
  begin
    P := PCnWideStringItem(FList[I]);
    Dispose(P);
  end;
  FList.Clear;
end;

constructor TCnWideStringList.Create;
begin
  inherited;
  FList := TList.Create;
end;

procedure TCnWideStringList.CustomSort(Compare: TCnWideStringListSortCompare);
begin
  if Count > 1 then
    QuickSort(0, Count - 1, Compare);
end;

procedure TCnWideStringList.Delete(Index: Integer);
var
  P: PCnWideStringItem;
begin
  P := PCnWideStringItem(FList[Index]);
  FList.Delete(Index);
  Dispose(P);
end;

destructor TCnWideStringList.Destroy;
begin
  Clear;
  FList.Free;
  inherited;
end;

procedure TCnWideStringList.Exchange(Index1, Index2: Integer);
begin
  FList.Exchange(Index1, Index2);
end;

function TCnWideStringList.Get(Index: Integer): WideString;
begin
  Result := PCnWideStringItem(FList[Index])^.FString;
end;

function TCnWideStringList.GetCount: Integer;
begin
  Result := FList.Count;
end;

function TCnWideStringList.GetName(Index: Integer): WideString;
var
  P: Integer;
begin
  Result := Get(Index);
  P := Pos('=', Result);
  if P <> 0 then
    SetLength(Result, P - 1) else
    SetLength(Result, 0);
end;

function TCnWideStringList.GetObject(Index: Integer): TObject;
begin
  Result := PCnWideStringItem(FList[Index])^.FObject;
end;

function TCnWideStringList.GetTextStr: WideString;
var
  I, L, Size, C: Integer;
  P: PwideChar;
  S, LB: WideString;
begin
  C := GetCount;
  Size := 0;
  LB := #13#10;
  for I := 0 to C - 1 do Inc(Size, Length(Get(I)) + Length(LB));
  SetString(Result, nil, Size);
  P := Pointer(Result);
  for I := 0 to C - 1 do
  begin
    S := Get(I);
    L := Length(S);
    if L <> 0 then
    begin
      System.Move(Pointer(S)^, P^, L*SizeOf(WideChar));
      Inc(P, L);
    end;
    L := Length(LB);
    if L <> 0 then
    begin
      System.Move(Pointer(LB)^, P^, L*SizeOf(WideChar));
      Inc(P, L);
    end;
  end;
end;

function TCnWideStringList.GetValue(const Name: WideString): WideString;
var
  I: Integer;
begin
  I := IndexOfName(Name);
  if I >= 0 then
    Result := Copy(Get(I), Length(Name) + 2, MaxInt) else
    Result := '';
end;

function TCnWideStringList.IndexOf(const S: WideString): Integer;
begin
  for Result := 0 to GetCount - 1 do
    if WideCompareText(Get(Result), S) = 0 then Exit;
  Result := -1;
end;

function TCnWideStringList.IndexOfName(const Name: WideString): Integer;
var
  P: Integer;
  S: string;
begin
  for Result := 0 to GetCount - 1 do
  begin
    S := Get(Result);
    P := Pos('=', S);
    if (P <> 0) and (WideCompareText(Copy(S, 1, P - 1), Name) = 0) then Exit;
  end;
  Result := -1;
end;

procedure TCnWideStringList.Insert(Index: Integer; const S: WideString);
var
  P: PCnWideStringItem;
begin
  New(P);
  P^.FString := S;
  FList.Insert(Index, P);
end;

procedure TCnWideStringList.LoadFromFile(const FileName: WideString);
var
  Stream: TStream;
begin
  Stream := TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
  try
    LoadFromStream(Stream);
  finally
    Stream.Free;
  end;
end;

procedure TCnWideStringList.LoadFromStream(Stream: TStream);
var
  Size, Len: Integer;
  S: WideString;
  HeaderStr, SA: AnsiString;
begin
  Size := Stream.Size - Stream.Position;
  if Size >= 3 then
  begin
    SetLength(HeaderStr, 3);
    Stream.Read(Pointer(HeaderStr)^, 3);
    if HeaderStr = #$EF#$BB#$BF then // utf-8 format
    begin
      SetLength(SA, Size - 3);
      Stream.Read(Pointer(SA)^, Size - 3);
{$IFDEF MSWINDOWS}
      Len := MultiByteToWideChar(CP_UTF8, 0, PAnsiChar(SA), -1, nil, 0);
      SetLength(S, Len);
      MultiByteToWideChar(CP_UTF8, 0, PAnsiChar(SA), -1, PWideChar(S), Len);
{$ELSE}
      S := UTF8ToWideString(SA);
{$ENDIF}
      SetTextStr(S);
      Exit;
    end;
    Stream.Position := Stream.Position - 3;  
  end;

  if Size >= 2 then
  begin
    SetLength(HeaderStr, 2);
    Stream.Read(Pointer(HeaderStr)^, 2);
    if HeaderStr = #$FF#$FE then // utf-8 format
    begin
      SetLength(S, (Size - 2) div SizeOf(WideChar));
      Stream.Read(Pointer(S)^, (Size - 2) div SizeOf(WideChar) * SizeOf(WideChar));
      SetTextStr(S);
      Exit;
    end;
    Stream.Position := Stream.Position - 2;  
  end;
      
  SetString(SA, nil, Size);
  Stream.Read(Pointer(SA)^, Size);
  SetTextStr({$IFDEF UNICODE}string{$ENDIF}(SA));
end;

procedure TCnWideStringList.Put(Index: Integer; const S: WideString);
var
  P: PCnWideStringItem;
begin
  P := PCnWideStringItem(FList[Index]);
  P^.FString := S;
end;

procedure TCnWideStringList.PutObject(Index: Integer; const Value: TObject);
begin
  PCnWideStringItem(FList[Index])^.FObject := Value;
end;

procedure TCnWideStringList.QuickSort(L, R: Integer;
  SCompare: TCnWideStringListSortCompare);
var
  I, J, P: Integer;
begin
  repeat
    I := L;
    J := R;
    P := (L + R) shr 1;
    repeat
      while SCompare(Self, I, P) < 0 do Inc(I);
      while SCompare(Self, J, P) > 0 do Dec(J);
      if I <= J then
      begin
        Exchange(I, J);
        if P = I then
          P := J
        else if P = J then
          P := I;
        Inc(I);
        Dec(J);
      end;
    until I > J;
    if L < J then QuickSort(L, J, SCompare);
    L := I;
  until I >= R;
end;

procedure TCnWideStringList.SaveToFile(const FileName: WideString; AFormat: TCnWideListFormat);
var
  Stream: TStream;
begin
  Stream := TFileStream.Create(FileName, fmCreate);
  try
    SaveToStream(Stream, AFormat);
  finally
    Stream.Free;
  end;
end;

procedure TCnWideStringList.SaveToStream(Stream: TStream; AFormat: TCnWideListFormat);
var
  S: WideString;
  HeaderStr, SA: AnsiString;
  Len: Integer;
begin
  S := GetTextStr;
  if AFormat = wlfAnsi then
  begin
    SA := AnsiString(S);
    Stream.WriteBuffer(Pointer(SA)^, Length(SA) * SizeOf(AnsiChar));
  end
  else if AFormat = wlfUtf8 then
  begin
    HeaderStr := #$EF#$BB#$BF;
    Stream.WriteBuffer(Pointer(HeaderStr)^, Length(HeaderStr) * SizeOf(AnsiChar));
{$IFDEF MSWINDOWS}
    Len := WideCharToMultiByte(CP_UTF8, 0, PWideChar(S), -1, nil, 0, nil, nil);
    SetLength(SA, Len);
    WideCharToMultiByte(CP_UTF8, 0, PWideChar(S), -1, PAnsiChar(SA), Len, nil, nil);
{$ELSE}
    SA := UTF8Encode(S);
{$ENDIF}
    Stream.WriteBuffer(Pointer(SA)^, Length(SA) * SizeOf(AnsiChar) - 1);
  end
  else if AFormat = wlfUnicode then
  begin
    HeaderStr := #$FF#$FE;
    Stream.WriteBuffer(Pointer(HeaderStr)^, Length(HeaderStr) * SizeOf(AnsiChar));
    Stream.WriteBuffer(Pointer(S)^, Length(S) * SizeOf(WideChar));
  end;
end;

procedure TCnWideStringList.SetTextStr(const Value: WideString);
var
  P, Start: PWideChar;
  S: WideString;
begin
  Clear;
  P := Pointer(Value);
  if P <> nil then
    while P^ <> #0 do
    begin
      Start := P;
      while not (Ord(P^) in [0, 10, 13]) do Inc(P);
      SetString(S, Start, P - Start);
      Add(S);
      if P^ = #13 then Inc(P);
      if P^ = #10 then Inc(P);
    end;
end;

procedure TCnWideStringList.SetValue(const Name, Value: WideString);
var
  I: Integer;
begin
  I := IndexOfName(Name);
  if Value <> '' then
  begin
    if I < 0 then I := Add('');
    Put(I, Name + '=' + Value);
  end else
  begin
    if I >= 0 then Delete(I);
  end;
end;

function StringListCompareStrings(List: TCnWideStringList; Index1, Index2: Integer): Integer;
begin
  Result := WideCompareText(PCnWideStringItem(List.FList[Index1])^.FString,
                            PCnWideStringItem(List.FList[Index2])^.FString);
end;

procedure TCnWideStringList.Sort;
begin
  CustomSort(StringListCompareStrings);
end;

{ TCnWideMemIniFile }

constructor TCnWideMemIniFile.Create(const AFileName: string);
var
  WList: TCnWideStringList;
  List: TStringList;
begin
  inherited Create(AFileName);
  WList := nil;
  List := nil;
  try
    WList := TCnWideStringList.Create;
    WList.LoadFromFile(AFileName);
    List := TStringList.Create;
    List.Text := WList.Text;
    SetStrings(List);
  finally
    WList.Free;
    List.Free;
  end;   
end;

procedure TCnWideMemIniFile.UpdateFile;
var
  WList: TCnWideStringList;
  List: TStringList;
begin
  WList := nil;
  List := nil;
  try
    List := TStringList.Create;
    GetStrings(List);
    WList := TCnWideStringList.Create;
    WList.Text := List.Text;
    WList.SaveToFile(FileName, wlfUtf8);
  finally
    WList.Free;
    List.Free;
  end;   
end;

// D5 ��û������ UTF8/Ansi ת���������ҵͰ汾��ʹ��Ҳ��֧�� UTF8-MB4�����д�����Ʒ
// Ϊ�����߼��������SourceChars �����ַ���������
function InternalUnicodeToUtf8(Dest: PAnsiChar; MaxDestBytes: Cardinal;
  Source: PWideChar; SourceChars: Cardinal): Cardinal;
var
  I, Cnt: Cardinal;
  C: Cardinal;
begin
  Result := 0;
  if Source = nil then
    Exit;

  Cnt := 0;
  I := 0;
  if Dest <> nil then
  begin
    while (I < SourceChars) and (Cnt < MaxDestBytes) do
    begin
      if (SourceChars - I >= 2) and (GetByteWidthFromUtf16(@(Source[I])) = 4) then
      begin
        // ���ַ������ֽڣ�Ҫ�������
        C := GetCodePointFromUtf164Char(PAnsiChar(@(Source[I])));
        Inc(I, 2); // �������� WideChar
      end
      else
      begin
        C := Cardinal(Source[I]);
        Inc(I); // ����һ�� WideChar
      end;

      if C <= $7F then
      begin
        Dest[Cnt] := AnsiChar(C);
        Inc(Cnt);
      end
      else if C > $FFFF then
      begin
        if Cnt + 4 > MaxDestBytes then
          Break;

        Dest[Cnt] := AnsiChar($F0 or (C shr 18));
        Dest[Cnt + 1] := AnsiChar($80 or ((C shr 12) and $3F));
        Dest[Cnt + 2] := AnsiChar($80 or ((C shr 6) and $3F));
        Dest[Cnt + 3] := AnsiChar($80 or (C and $3F));
        Inc(Cnt, 4);
      end
      else if C > $7FF then
      begin
        if Cnt + 3 > MaxDestBytes then
          Break;
        Dest[Cnt] := AnsiChar($E0 or (C shr 12));
        Dest[Cnt + 1] := AnsiChar($80 or ((C shr 6) and $3F));
        Dest[Cnt + 2] := AnsiChar($80 or (C and $3F));
        Inc(Cnt, 3);
      end
      else //  $7F < Source[i] <= $7FF
      begin
        if Cnt + 2 > MaxDestBytes then
          Break;
        Dest[Cnt] := AnsiChar($C0 or (C shr 6));
        Dest[Cnt + 1] := AnsiChar($80 or (C and $3F));
        Inc(Cnt, 2);
      end;
    end;

    if Cnt >= MaxDestBytes then
      Cnt := MaxDestBytes - 1;
    Dest[Cnt] := #0;
  end
  else
  begin
    while I < SourceChars do
    begin
      if (SourceChars - I >= 2) and (GetByteWidthFromUtf16(@(Source[I])) = 4) then
      begin
        // ���ַ������ֽڣ�Ҫ�������
        C := GetCodePointFromUtf164Char(PAnsiChar(@(Source[I])));
        Inc(I, 2); // �������� WideChar
      end
      else
      begin
        C := Cardinal(Source[I]);
        Inc(I);
      end;

      if C > $7F then
      begin
        if C > $7FF then
        begin
          if C > $FFFF then
            Inc(Cnt);
          Inc(Cnt);
        end;
        Inc(Cnt);
      end;
      Inc(Cnt);
    end;
  end;
  Result := Cnt + 1;
end;

function InternalUtf8ToUnicode(Dest: PWideChar; MaxDestChars: Cardinal;
  Source: PAnsiChar; SourceBytes: Cardinal): Cardinal;
var
  K: Integer;
  I, Cnt: Cardinal;
  C: Byte;
  WC: Cardinal;
begin
  if Source = nil then
  begin
    Result := 0;
    Exit;
  end;

  Result := Cardinal(-1);
  Cnt := 0;
  I := 0;
  if Dest <> nil then
  begin
    while (I < SourceBytes) and (Cnt < MaxDestChars) do
    begin
      WC := Cardinal(Source[I]);
      Inc(I);

      if (WC and $80) <> 0 then
      begin
        if I >= SourceBytes then Exit;          // incomplete multibyte char

        if (WC and $F0) = $F0 then              // ���ֽڣ����������ٲ��������ַ���ƴ���ַ�ֵ����������ֽڵ� UTF16 ����
        begin
          if SourceBytes - I < 3 then Exit;     // �������ֽ�������˳�

          // WC �ǵ�һ���ֽڣ�ȡ����λ���������ֽڸ�ȡ����λ���õ����
          WC := ((WC and $7) shl 18) + ((Cardinal(Source[I]) and $3F) shl 12)
            + ((Cardinal(Source[I + 1]) and $3F) shl 6) + (Cardinal(Source[I + 2]) and $3F);

          // ����������� UTF16 �ַ��������� Cnt
          K := GetUtf16CharFromCodePoint(WC, @(Dest[Cnt]));
          if K = 2 then // ���������ֽ��ַ����Ȳ���һ�� WideChar����һ���� if �󲽽�
            Inc(Cnt);
          Inc(I, 3);
        end
        else
        begin
          WC := WC and $3F;
          if (WC and $20) <> 0 then
          begin
            C := Byte(Source[I]);
            Inc(I);
            if (C and $C0) <> $80 then Exit;      // malformed trail byte or out of range char
            if I >= SourceBytes then Exit;        // incomplete multibyte char
            WC := (WC shl 6) or (C and $3F);
          end;
          C := Byte(Source[I]);
          Inc(I);
          if (C and $C0) <> $80 then Exit;       // malformed trail byte

          Dest[Cnt] := WideChar((WC shl 6) or (C and $3F));
        end;
      end
      else
        Dest[Cnt] := WideChar(WC);
      Inc(Cnt);
    end;
    if Cnt >= MaxDestChars then Cnt := MaxDestChars - 1;
    Dest[Cnt] := #0;
  end
  else
  begin
    while (I < SourceBytes) do
    begin
      C := Byte(Source[I]);
      Inc(I);

      if (C and $80) <> 0 then                  // ���λΪ 1�����ٶ��ֽ�
      begin
        if I >= SourceBytes then                // incomplete multibyte char
          Exit;

        C := C and $3F;                         // ���µ�һ���ֽڵĵ���λ��ǰ��λ�Ѿ����� 11 ��
        if (C and $20) <> 0 then                // ����� 1110�����ʾ���������ֽ�
        begin
          if (C and $10) <> 0 then              // ����� 11110�����ʾ�������ֽ�
          begin
            C := Byte(Source[I]);               // �����ĸ��еĵڶ����ֽ�
            Inc(I);
            if (C and $C0) <> $80 then          // ���ֽ������λ���� 10
              Exit;                             // malformed trail byte or out of range char
            if I >= SourceBytes then
              Exit;                             // incomplete multibyte char

            Inc(Cnt);                           // ���ֽڵ� UTF8��Ӧ��Ӧ UTF16 �е����� WideChar����������һ
          end;

          C := Byte(Source[I]);                 // ���ĸ��еĵ������ֽڣ��������еĵڶ����ֽ�
          Inc(I);
          if (C and $C0) <> $80 then            // ���ֽ������λ���� 10�������˳�
            Exit;
          if I >= SourceBytes then
            Exit;                               // incomplete multibyte char
        end;

        C := Byte(Source[I]);                   // ���ĸ��еĵ��ĸ��ֽڣ��������еĵ������ֽڣ�������еĵڶ����ֽ�
        Inc(I);
        if (C and $C0) <> $80 then              // ���ֽ������λ���� 10�������˳�
          Exit;                                 // malformed trail byte
      end;

      Inc(Cnt);
    end;
  end;
  Result := Cnt + 1;
end;

// �� WideString ���� Utf8 ����õ� AnsiString������ Ansi ת�����ⶪ�ַ�
function CnUtf8EncodeWideString(const S: WideString): AnsiString;
var
  L: Integer;
  Temp: AnsiString;
begin
  Result := '';
  if S = '' then Exit;
  SetLength(Temp, Length(S) * 3); // SetLength includes space for null terminator

  L := InternalUnicodeToUtf8(PAnsiChar(Temp), Length(Temp) + 1, PWideChar(S), Length(S));
  if L > 0 then
    SetLength(Temp, L - 1)
  else
    Temp := '';
  Result := Temp;
end;

// �� AnsiString �� Utf8 ����õ� WideString������ Ansi ת�����ⶪ�ַ�
function CnUtf8DecodeToWideString(const S: AnsiString): WideString;
var
  L: Integer;
begin
  Result := '';
  if S = '' then Exit;
  SetLength(Result, Length(S));

  L := InternalUtf8ToUnicode(PWideChar(Result), Length(Result) + 1, PAnsiChar(S), Length(S));
  if L > 0 then
    SetLength(Result, L - 1)
  else
    Result := '';
end;

function GetUtf16HighByte(Rec: PCn2CharRec): Byte;
begin
{$IFDEF UTF16_BE}
  Result := Byte(Rec^.P1);
{$ELSE}
  Result := Byte(Rec^.P2); // UTF16-LE �ĸߵ�λ���û�
{$ENDIF}
end;

function GetUtf16LowByte(Rec: PCn2CharRec): Byte;
begin
{$IFDEF UTF16_BE}
  Result := Byte(Rec^.P2);
{$ELSE}
  Result := Byte(Rec^.P1); // UTF16-LE �ĸߵ�λ���û�
{$ENDIF}
end;

procedure SetUtf16HighByte(B: Byte; Rec: PCn2CharRec);
begin
{$IFDEF UTF16_BE}
  Rec^.P1 := AnsiChar(B);
{$ELSE}
  Rec^.P2 := AnsiChar(B); // UTF16-LE �ĸߵ�λ���û�
{$ENDIF}
end;

procedure SetUtf16LowByte(B: Byte; Rec: PCn2CharRec);
begin
{$IFDEF UTF16_BE}
  Rec^.P2 := AnsiChar(B);
{$ELSE}
  Rec^.P1 := AnsiChar(B); // UTF16-LE �ĸߵ�λ���û�
{$ENDIF}
end;

function GetCharLengthFromUtf8(Utf8Str: PAnsiChar): Integer;
var
  L: Integer;
begin
  Result := 0;
  while Utf8Str^ <> #0 do
  begin
    L := GetByteWidthFromUtf8(Utf8Str);
    Inc(Utf8Str, L);
    Inc(Result);
  end;
end;

function GetCharLengthFromUtf16(Utf16Str: PWideChar): Integer;
var
  L: Integer;
begin
  Result := 0;
  while Utf16Str^ <> #0 do
  begin
    L := GetByteWidthFromUtf16(Utf16Str);
    Utf16Str := PWideChar(TCnNativeInt(Utf16Str) + L);
    Inc(Result);
  end;
end;

function GetByteWidthFromUtf8(Utf8Str: PAnsiChar): Integer;
var
  B: Byte;
begin
  B := Byte(Utf8Str^);
  if B >= $FC then        // 6 �� 1��1 �� 0���Ȳ������߻�� 1 �����
    Result := 6
  else if B >= $F8 then   // 5 �� 1��1 �� 0
    Result := 5
  else if B >= $F0 then   // 4 �� 1��1 �� 0
    Result := 4
  else if B >= $E0 then   // 3 �� 1��1 �� 0
    Result := 3
  else if B >= $B0 then   // 2 �� 1��1 �� 0
    Result := 2
  else                    // ����
    Result := 1;
end;

function GetByteWidthFromUtf16(Utf16Str: PWideChar): Integer;
var
  P: PCn2CharRec;
  B1, B2: Byte;
begin
  Result := 2;

  P := PCn2CharRec(Utf16Str);
  B1 := GetUtf16HighByte(P);

  if (B1 >= CN_UTF16_4CHAR_PREFIX1_LOW) and (B1 < CN_UTF16_4CHAR_PREFIX1_HIGH) then
  begin
    // ����������ֽ��ַ�ƴһ�飬��ֵ�� $D800 �� $DBFF ֮�䣬Ҳ���Ǹ�˫�ֽڵĸ�λ�ֽ��� [$D8, $DC) ������
    Inc(P);
    B2 := GetUtf16HighByte(P);

    // ��ô�����ں�����������ֽ��ַ�Ӧ���� $DC00 �� $DFFF ֮�䣬
    if (B2 >= CN_UTF16_4CHAR_PREFIX2_LOW) and (B2 < CN_UTF16_4CHAR_PREFIX2_HIGH) then
      Result := 4;

    // ���ĸ��ֽ����һ�����ֽ� Unicode �ַ��������Ǹ�ֵ�ı���ֵ
  end;
end;

function GetCodePointFromUtf16Char(Utf16Str: PWideChar): TCnCodePoint;
var
  R: Word;
  C2: PCn2CharRec;
begin
  if GetByteWidthFromUtf16(Utf16Str) = 4 then // ���ֽ��ַ�
    Result := GetCodePointFromUtf164Char(PAnsiChar(Utf16Str))
  else  // ��ͨ˫�ֽ��ַ�
  begin
    C2 := PCn2CharRec(Utf16Str);
    R := Byte(C2^.P1) shl 8 + Byte(C2^.P2);       // ˫�ֽ��ַ���ֵ������Ǳ���ֵ

{$IFDEF UTF16_BE}
    Result := TCnCodePoint(R);
{$ELSE}
    Result := TCnCodePoint(UInt16ToBigEndian(R)); // UTF16-LE Ҫ����ֵ
{$ENDIF}
  end;
end;

function GetCodePointFromUtf164Char(PtrTo4Char: Pointer): TCnCodePoint;
var
  TH, TL: Word;
  C2: PCn2CharRec;
begin
  C2 := PCn2CharRec(PtrTo4Char);

  // ��һ���ֽڣ�ȥ����λ�� 110110���ڶ����ֽ����ţ��� 2 + 8 = 10 λ
  TH := (GetUtf16HighByte(C2) and CN_UTF16_4CHAR_HIGH_MASK) shl 8 + GetUtf16LowByte(C2);
  Inc(C2);

  // �������ֽڣ�ȥ����λ�� 110111�����ĸ��ֽ����ţ��� 2 + 8 = 10 λ
  TL := (GetUtf16HighByte(C2) and CN_UTF16_4CHAR_HIGH_MASK) shl 8 + GetUtf16LowByte(C2);

  // �� 10 λƴ�� 10 λ
  Result := TH shl 10 + TL + CN_UTF16_EXT_BASE;
  // ����ȥ $10000 ���ֵ��ǰ 10 λӳ�䵽 $D800 �� $DBFF ֮�䣬�� 10 λӳ�䵽 $DC00 �� $DFFF ֮��
end;

function GetUtf16CharFromCodePoint(CP: TCnCodePoint; PtrToChars: Pointer): Integer;
var
  C2: PCn2CharRec;
  L, H: Byte;
  LW, HW: Word;
begin
  if CP >= CN_UTF16_EXT_BASE then
  begin
    if PtrToChars <> nil then
    begin
      CP := CP - CN_UTF16_EXT_BASE;
      // ����� 10 λ��ǰ���ֽڣ������ 10 λ�ź����ֽ�

      LW := CP and CN_UTF16_4CHAR_SPLIT_MASK;          // �� 10 λ�����������ֽ�
      HW := (CP shr 10) and CN_UTF16_4CHAR_SPLIT_MASK; // �� 10 λ����һ�����ֽ�

      L := HW and $FF;
      H := (HW shr 8) and CN_UTF16_4CHAR_HIGH_MASK;
      H := H or CN_UTF16_4CHAR_PREFIX1_LOW;              // 1101 1000
      C2 := PCn2CharRec(PtrToChars);

      SetUtf16LowByte(L, C2);
      SetUtf16HighByte(H, C2);

      L := LW and $FF;
      H := (LW shr 8) and CN_UTF16_4CHAR_HIGH_MASK;
      H := H or CN_UTF16_4CHAR_PREFIX1_HIGH;              // 1101 1100
      Inc(C2);

      SetUtf16LowByte(L, C2);
      SetUtf16HighByte(H, C2);
    end;
    Result := 2;
  end
  else
  begin
    if PtrToChars <> nil then
    begin
      C2 := PCn2CharRec(PtrToChars);
      SetUtf16LowByte(Byte(CP and $00FF), C2);
      SetUtf16HighByte(Byte(CP shr 8), C2);
    end;
    Result := 1;
  end;
end;

end.
