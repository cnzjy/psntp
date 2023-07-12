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

unit CnHashMap;
{* |<PRE>
================================================================================
* ������ƣ�CnPack
* ��Ԫ���ƣ�CnHashMap ʵ�ֵ�Ԫ
* ��Ԫ���ߣ�Pan Ying
* ��    ע���õ�ԪΪ CnHashMap ��ʵ�ֵ�Ԫ��
* ����ƽ̨��PWin2000Pro + Delphi 5.01
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* �� �� �����õ�Ԫ�е��ַ��������ϱ��ػ�����ʽ
* �޸ļ�¼��v0.96   2021/1/2  by Liu Xiao
*               Add new class TCnHashMap for Int64 and Integer/TObject
*           v0.96   2004/2/7  by beta
*               Add new class TCnStrToPtrHashMap
*           v0.95   2002/8/3  by Pan Ying
*               Add support for custom defined hash code method
*               Add New Class TCnStrToStrHashMap
*           v0.91   2002/7/28 by Pan Ying
*               Add new hash code method interface
*               Add private member FLengthBit and some support method
*               Now change Incr Length Method.
*           v0.90   2002/7/14 by Pan Ying
*               Just write the TCnBaseHashMap.
================================================================================
|</PRE>}

interface

{$I CnPack.inc}

uses
  Classes, SysUtils, CnNative;

const
  CN_HASH_MAP_DEFAULT_CAPACITY = 16;

  CN_HASH_MAP_DEFAULT_LOADFACTOR = 0.75;

  CN_HASH_MAP_MAX_CAPACITY = 1 shl 30;

type
  ECnHashException = class(Exception);

  {     When an EOutOfMemory exception throw,means there is not enough
  Memory to keep the map,just maybe need more memory.}


  {    This Record is used as the internal method to store data,
    it use variant so can support int,string,object and so on.}
  TCnHashMapRec = record
    Key: Variant;
    HashCode: Integer;
            //when -2 ,as nothing;when -1, as deleted;
    Value: Variant;
  end;

  {Some type used to calculate the int hash code}
  TCnHashCodeType = (CnHashMove, CnHashMod);

  {Your can define your own function to calculate hash code,
    but sure it need less than the list Length}
  TCnCustomHashCodeMethod = function(AKey: Variant; AListLength, ATotalRec: Integer): Integer;

  {    This is the loew level hash map ,all others' ancestor.
     Some method just abstract.'}
  TCnBaseHashMap = class(TPersistent)
  private
    FIncr: Integer;
            //how much space should be alloc when full
    FSize: Integer;
            //how many data stored.
    FCurPos: Integer;
            //enum point
    FLengthBit: Integer;

    FHashCodeMethod: TCnHashCodeType;
    FUseCustomHash: Boolean;
    FOnCustomHashCode: TCnCustomHashCodeMethod;
            //the type

    procedure SetIncr(Value: Integer);
    procedure CreateList(Length: Integer);

    function VariantHashCode(AKey: Variant): Integer; virtual;
            //ATTENTION: override in every inherit
    function IntHashCode(AKey: Integer): Integer;

    procedure DeleteValue(AValue: Variant); virtual;
            //this procedure used to delete no use value,may be needed override

    function Search(AKey: Variant): Integer;
    procedure SetHashCodeMethod(const Value: TCnHashCodeType);
    procedure SetUseCustomHash(const Value: Boolean);
    procedure SetOnCustomHashCode(const Value: TCnCustomHashCodeMethod);
  protected
    FList: array of TCnHashMapRec;
            //store the map
    procedure ReSizeList(NewLength: Integer);
            //use to change the internal list's size

    procedure AddInternal(AKey, AValue: Variant);
    function DeleteInternal(AKey: Variant): Boolean;
    function FindInternal(AKey: Variant; var AValue: Variant): Boolean;

    function GetNextInternal(var AKey, AValue: Variant): Boolean;

    function HasHashCode(AKey: Variant): Integer;
  public
    constructor Create(AListLength: Integer = 8; AIncr: Integer = 2);
    destructor Destroy; override;

    procedure Add(AKey, AValue: Variant); overload; virtual;
    function Delete(AKey: Variant): Boolean; overload; virtual;
    function Find(AKey: Variant; var AValue: Variant): Boolean; overload; virtual;

    procedure Refresh;
            //use if many data has been deleted,takes a long time

    //use to list all key and value
    procedure StartEnum;
    function GetNext(var AKey, AValue: Variant): Boolean; overload; virtual;
            //return false when all hava been listed

    property Incr: Integer read FIncr write SetIncr;
    property Size: Integer read FSize;
    property HashCodeMethod: TCnHashCodeType read FHashCodeMethod write SetHashCodeMethod;
    property UseCustomHash: Boolean read FUseCustomHash write SetUseCustomHash;
    property OnCustomHashCode: TCnCustomHashCodeMethod read FOnCustomHashCode write SetOnCustomHashCode;

  end;

  TCnStrToStrHashMap = class(TCnBaseHashMap)
  private
    function VariantHashCode(AKey: Variant): Integer; override;

  public
    procedure Add(const AKey, AValue: string); reintroduce; overload;
    function Delete(const AKey: string): Boolean; reintroduce; overload;
    function Find(const AKey: string; var AValue: string): Boolean; reintroduce; overload;

    function GetNext(var AKey, AValue: string): Boolean; reintroduce; overload;
  end;

  TCnWideStrToWideStrHashMap = class(TCnBaseHashMap)
  private
    function VariantHashCode(AKey: Variant): Integer; override;

  public
    procedure Add(const AKey, AValue: WideString); reintroduce; overload;
    function Delete(const AKey: WideString): Boolean; reintroduce; overload;
    function Find(const AKey: WideString; var AValue: WideString): Boolean; reintroduce; overload;

    function GetNext(var AKey, AValue: WideString): Boolean; reintroduce; overload;
  end;

  TCnStrToPtrHashMap = class(TCnBaseHashMap)
  private
    function VariantHashCode(AKey: Variant): Integer; override;
  public
    procedure Add(const AKey: string; AValue: Pointer); reintroduce; overload;
    function Delete(const AKey: string): Boolean; reintroduce; overload;
    function Find(const AKey: string; var AValue: Pointer): Boolean; reintroduce; overload;
    function GetNext(var AKey: string; var AValue: Pointer): Boolean; reintroduce; overload;
  end;

  TCnStrToVariantHashMap = class(TCnBaseHashMap)
  private
    function VariantHashCode(AKey: Variant): Integer; override;
  public
    procedure Add(const AKey: string; AValue: Variant); reintroduce; overload;
    function Delete(const AKey: string): Boolean; reintroduce; overload;
    function Find(const AKey: string; var AValue: Variant): Boolean; reintroduce; overload;
    function GetNext(var AKey: string; var AValue: Variant): Boolean; reintroduce; overload;
  end;

  TCnHashNode = class(TObject)
  {* TCnHashMap ������ڵ��࣬�� Key �� Value �������ã������� Int64 ��ʽ�� Key �� Value}
  private
    FHash: Integer;
    FNext: TCnHashNode;
    FKey: TObject;
    FValue: TObject;
{$IFNDEF CPU64BITS}      // 32 λ��Ҫ���� 64 λ�� Key �� Value����Ҫ����Ĵ洢�ռ��� 32 λ
    FKey32: TObject;
    FValue32: TObject;
{$ENDIF}
    function GetKey: TObject;
    procedure SetKey(const Value: TObject);
    procedure SetValue(const Value: TObject);
    function GetValue: TObject;
{$IFNDEF CPU64BITS}
    function GetKey32: TObject;
    function GetValue32: TObject;
    procedure SetKey32(const Value: TObject);
    procedure SetValue32(const Value: TObject);
{$ENDIF}
    function GetKey64: Int64;
    function GetValue64: Int64;
    procedure SetKey64(const Value: Int64);
    procedure SetValue64(const Value: Int64);
  public
    property Hash: Integer read FHash write FHash;
    property Key: TObject read GetKey write SetKey;
    {* 32 λ�����µ� Key �ĵ� 32 λ��64 λ�����µ��� 64 λ Key}
    property Value: TObject read GetValue write SetValue;
    {* 32 λ�����µ� Value �ĵ� 32 λ��64 λ�����µ��� 64 λ Value}
{$IFNDEF CPU64BITS}
    property Key32: TObject read GetKey32 write SetKey32;
    {* 32 λ�����µ� Key �ĸ� 32 λ}
    property Value32: TObject read GetValue32 write SetValue32;
    {* 32 λ�����µ� Value �ĸ� 32 λ}
{$ENDIF}
    property Key64: Int64 read GetKey64 write SetKey64;
    {* Key ������ 64 λ}
    property Value64: Int64 read GetValue64 write SetValue64;
    {* Value ������ 64 λ}

    property Next: TCnHashNode read FNext write FNext;
  end;

  TCnHashNodeArray = array of TCnHashNode;

  TCnHashMap = class;

  TCnHashFreeNodeEvent = procedure(Sender: TCnHashMap; Node: TCnHashNode) of object;

  ICnHashMapIterator = interface
  {* TCnHashMap �ı������ӿڣ�������ָ���һ���ǿսڵ㣬�������� Eof}
    function Eof: Boolean;
    {* �Ƿ��Ѿ�û��ָ��}
    procedure Next;
    {* ��ȥָ����һ���ڵ㣬���û��һ�������� Eof}
    function CurrentNode: TCnHashNode;
    {* ���ص�ǰ�ڵ㣬ע�ⲻҪ�޸� Node �� HashCode �� Key}
    function CurrentIndex: Integer;
    {* ���ص�ǰ�ڵ����ڵ��������ͷ���ڵ������±�}
  end;

  TCnHashMap = class(TObject)
  {* �ο� JDK 1.7 ʵ�ֵ� Object �� Object �ļ��� HashMap����ʹ�� Variant ���������
    Ҫͬʱ֧�� 32 λ�� 64 λ�������� Integer��Key Ҫ֧�� Int32/64��TObject }
  private
    FTable: TCnHashNodeArray; // Hash �������������ͷ�������ǣ����� FCapacity �� 2 ���� * SizeOf(TObject)
    FLoadFactor: Real;
    FSize: Integer;
    FCapacity: Integer;
    FThreshold: Integer;
    FModCount: Integer;
    FOnFreeNode: TCnHashFreeNodeEvent;
    procedure CheckResize;
    procedure Resize(NewCapacity: Integer);
    procedure ClearAll(Shrink: Boolean = False);

    function Get(HashCode: Integer; Key: TObject; out Value: TObject {$IFNDEF CPU64BITS};
      Key32: TObject = nil; ValueHigh32: Pointer = nil {$ENDIF}): Boolean;
    {* ʵ�ʵ� Get ������HashCode ����������ˣ������Ƿ������ Value ֵ��32 λ�£����ֵ�и� 32 λ����ͨ�� ValueHigh32 ����}
    function Put(HashCode: Integer; Key, Value: TObject {$IFNDEF CPU64BITS};
      KeyHigh32: TObject = nil; ValueHigh32: TObject = nil {$ENDIF}): TCnHashNode;
    {* ʵ�ʵ� Put ������HashCode ����������ˣ����ظ��ȥ�� Node����������򸲸�}
    function Contain(HashCode: Integer; Key: TObject {$IFNDEF CPU64BITS};
      KeyHigh32: TObject = nil {$ENDIF}): TCnHashNode;
    {* ʵ�ʵĲ��Ҳ�����HashCode ����������ˣ����ش�� Key �Ľڵ�}
    function Del(HashCode: Integer; Key: TObject {$IFNDEF CPU64BITS};
      KeyHigh32: TObject = nil {$ENDIF}): Boolean;
    {* ʵ�ʵ�ɾ��������HashCode ����������ˣ������Ƿ��ҵ���ɾ����False ʱ��ʾû�ҵ�}
  protected
    function IndexForHash(H, L: Integer): Integer;
    function HashCodeFromObject(Obj: TObject): Integer; virtual;
    function HashCodeFromInteger(I: Integer): Integer; virtual;
    function HashCodeFromInt64(I64: Int64): Integer; virtual;

    function KeyEqual(Key1, Key2: TObject {$IFNDEF CPU64BITS}; Key132, Key232: TObject {$ENDIF}): Boolean; virtual;
    {* �ڲ��Ƚ� Key �ķ�����Ĭ��Ϊ���õ�ַ�ȶԣ���������ء�
      ע�� Key �� TObject ʱ���� Key32 �̶�Ϊ 0����Ϊ���� 32 ���� 64 λ�¾�һ�� Key �͹���}

    procedure DoFreeNode(Node: TCnHashNode); virtual;
  public
    constructor Create(ACapacity: Integer = CN_HASH_MAP_DEFAULT_CAPACITY;
      ALoadFactor: Double = CN_HASH_MAP_DEFAULT_LOADFACTOR); virtual;
    destructor Destroy; override;

    procedure Add(Key: TObject; Value: TObject); overload;
    procedure Add(Key: Integer; Value: Integer); overload;
    procedure Add(Key: Int64; Value: Int64); overload;

    procedure Remove(Key: TObject); overload;
    procedure Remove(Key: Integer); overload;
    procedure Remove(Key: Int64); overload;

    function HasKey(Key: TObject): Boolean; overload;
    function HasKey(Key: Integer): Boolean; overload;
    function HasKey(Key: Int64): Boolean; overload;

    function Find(Key: TObject): TObject; overload;
    function Find(Key: Integer): Integer; overload;
    function Find(Key: Int64): Int64; overload;

    function Find(Key: TObject; out OutObj: TObject): Boolean; overload;
    function Find(Key: Integer; out OutInt: Integer): Boolean; overload;
    function Find(Key: Int64; out OutInt64: Int64): Boolean; overload;

    function CreateIterator: ICnHashMapIterator;
    {*  ����һ���������ӿ�ʵ��}
    procedure Clear;
    {* ���ȫ������}
    property Size: Integer read FSize;
    {* ����Ԫ�ظ���}
    property Capacity: Integer read FCapacity;
    {* ����������������������}

    property OnFreeNode: TCnHashFreeNodeEvent read FOnFreeNode write FOnFreeNode;
    {* �ͷ� Node ʱ�Ļص������ͷ� Node �е�����}
  end;

implementation

resourcestring
  SCnHashInValidFactor = 'Invalid Hash Map Load Factor';
  SCnHashConcurrentError = 'Modified by Others when Iteratoring';

type
  PObject = ^TObject;

  TCnHashMapIterator = class(TInterfacedObject, ICnHashMapIterator)
  {* ICnHashMapIterator ��ʵ����}
  private
    FMap: TCnHashMap;
    FEof: Boolean;
    FCurrentNodeRef: TCnHashNode;
    FCurrentTableIndex: Integer;
    FModCount: Integer;
    procedure First;
  public
    constructor Create(Map: TCnHashMap);
    destructor Destroy; override;

    function Eof: Boolean;
    procedure Next;
    function CurrentNode: TCnHashNode;
    function CurrentIndex: Integer;
  end;

{ TCnBaseHashMap }

procedure TCnBaseHashMap.Add(AKey, AValue: Variant);
begin
  AddInternal(AKey, AValue);
end;

procedure TCnBaseHashMap.AddInternal(AKey, AValue: Variant);
var
  I, J: Integer;
  Pos, DeletedPos: Integer;
begin
  //if smaller,then enlarge the size
  if Size >= Length(FList) then
    ReSizeList(Size * Incr);

  //calculate hash code
  I := HasHashCode(AKey);
  DeletedPos := -1;
  Pos := I;

  for J := Low(FList) to High(FList) do
  begin
    Pos := (I + J) mod Length(FList);

    if FList[Pos].HashCode = -2 then
      Break
    else if (FList[Pos].HashCode = I) and (FList[Pos].Key = AKey) then
      Break;

    if (DeletedPos < 0) and (FList[Pos].HashCode = -1) then
      DeletedPos := Pos;
  end;

  if (FList[Pos].HashCode = -2) or
    ((FList[Pos].HashCode = I) and (FList[Pos].Key = AKey)) then //new record
  begin
    if (FList[Pos].HashCode = I) and (FList[Pos].Key = AKey) then
      DeleteValue(FList[Pos].Value)
    else
      Inc(FSize);

    FList[Pos].Key := AKey;
    FList[Pos].HashCode := I;

    FList[Pos].Value := AValue;
  end
  else if DeletedPos >= 0 then
  begin
    Pos := DeletedPos;

    FList[Pos].Key := AKey;
    FList[Pos].HashCode := I;
    FList[Pos].Value := AValue;

    Inc(FSize);
  end;
end;

constructor TCnBaseHashMap.Create(AListLength, AIncr: Integer);
begin
  inherited Create;

  // set All the Initial value first here.
  FIncr := 15;
  FSize := 0;

  Incr := AIncr;

  FHashCodeMethod := CnHashMod;

  FOnCustomHashCode := nil;
  FUseCustomHash := false;

  CreateList(AListLength);
end;

procedure TCnBaseHashMap.CreateList(Length: Integer);
var
  I: Integer;
  nTemp: Integer;
begin
  FSize := 0;
  SetLength(FList, Length);

  for I := Low(FList) to High(FList) do
    FList[I].HashCode := -2; //just think -2 is space

  FLengthBit := 1;
  nTemp := 2;

  while nTemp < Length do
  begin
    nTemp := nTemp * 2;

    Inc(FLengthBit);
  end;
end;

function TCnBaseHashMap.Delete(AKey: Variant): Boolean;
begin
  Result := DeleteInternal(AKey);
end;

function TCnBaseHashMap.DeleteInternal(AKey: Variant): Boolean;
var
  Pos: Integer;
begin
  Pos := Search(AKey);

  if Pos = -1 then
    Result := false
  else
  begin
    FList[Pos].HashCode := -1; //deleted
    DeleteValue(FList[Pos].Value);

    dec(FSize);

    Result := true;
  end;
end;

procedure TCnBaseHashMap.DeleteValue(AValue: Variant);
begin
  //just donothing here;
end;

destructor TCnBaseHashMap.Destroy;
var
  I: Integer;
begin
  for I := Low(FList) to High(FList) do
    if FList[I].HashCode >= 0 then
      DeleteValue(FList[I].Value);

  SetLength(FList, 0);

  inherited;
end;

function TCnBaseHashMap.Find(AKey: Variant; var AValue: Variant): Boolean;
begin
  Result := FindInternal(AKey, AValue);
end;

function TCnBaseHashMap.FindInternal(AKey: Variant; var AValue: Variant): Boolean;
var
  Pos: Integer;
begin
  Pos := Search(AKey);

  if Pos = -1 then
    Result := false
  else
  begin
    AValue := FList[Pos].Value;

    Result := true;
  end;
end;

function TCnBaseHashMap.GetNext(var AKey, AValue: Variant): Boolean;
begin
  Result := GetNextInternal(AKey, AValue);
end;

function TCnBaseHashMap.GetNextInternal(var AKey,
  AValue: Variant): Boolean;
var
  I: Integer;
begin
  I := FCurPos + 1;

  while (I < Length(FList)) and (FList[I].HashCode < 0) do
    Inc(I);

  if I >= Length(FList) then
    Result := false
  else
  begin
    FCurPos := I;
    AKey := FList[I].Key;
    AValue := FList[I].Value;

    Result := true;
  end;
end;

function TCnBaseHashMap.HasHashCode(AKey: Variant): Integer;
begin
  if UseCustomHash then
    Result := OnCustomHashCode(AKey, Length(FList), Size)
  else
    Result := IntHashCode(VariantHashCode(AKey));
end;

function TCnBaseHashMap.IntHashCode(AKey: Integer): Integer;
var
  nTemp, nTemp2, nTemp3: Integer;
begin
  {ATTENTION: New Hash Code Method add here}

  case (HashCodeMethod) of
    CnHashMove:
      begin
        nTemp := Abs(AKey);
        nTemp2 := 0;
        nTemp3 := 1 shl FLengthBit;

        while (nTemp > 0) do
        begin
          Inc(nTemp2, nTemp mod nTemp3);

          nTemp := nTemp shr FLengthBit;
        end;

        Result := nTemp2;
      end;


    CnHashMod:
      Result := AKey mod Length(FList);

  else
    //we treat as the Mod Method
    Result := AKey mod Length(FList);
  end;

  Result := Abs(Result);
end;

procedure TCnBaseHashMap.Refresh;
var
  nNewLen: Integer;
begin
  nNewLen := Length(FList);

  while nNewLen > Size do nNewLen := nNewLen div Incr;

  if nNewLen <= 0 then
    nNewLen := Incr;

  while nNewLen <= Size do nNewLen := nNewLen * Incr;

  ReSizeList(nNewLen);
end;

procedure TCnBaseHashMap.ReSizeList(NewLength: Integer);
var
  TempList: array of TCnHashMapRec;
  I: Integer;
begin
  //this is a protected procedure,not directly called outside

  //first we check the NewLength is valid
  if (NewLength < Size) then
    raise ECnHashException.Create('New list size is not valid');

  //then we do the actual act,this will take a long time if list is long
  SetLength(TempList, Length(FList));

  try

    for I := Low(TempList) to High(TempList) do
      TempList[I] := FList[I];

    CreateList(NewLength);

    for I := Low(TempList) to High(TempList) do
      if TempList[I].HashCode >= 0 then
        AddInternal(TempList[I].Key, TempList[I].Value);

  finally
    SetLength(TempList, 0);
  end;

end;

function TCnBaseHashMap.Search(AKey: Variant): Integer;
var
  I, J: Integer;
  Pos: Integer;
begin
  Result := -1;

  //calculate hash code first
  I := HasHashCode(AKey);

  for J := Low(FList) to High(FList) do
  begin
    Pos := (I + J) mod Length(FList);

    if FList[Pos].HashCode = -2 then
      Break
    else if (FList[Pos].HashCode = I) and (FList[Pos].Key = AKey) then
    begin
      Result := Pos;
      Break;
    end;
  end;
end;

procedure TCnBaseHashMap.SetHashCodeMethod(const Value: TCnHashCodeType);
begin
  if (FHashCodeMethod <> Value) then
  begin
    //we should refresh this list,because hash code has been changed also
    FHashCodeMethod := Value;
    Refresh;
  end;
end;

procedure TCnBaseHashMap.SetIncr(Value: Integer);
begin
  if (Value <= 1) then
    raise ECnHashException.Create('Incr should be lagerer than 1')
  else
    if (Value <> FIncr) then
      FIncr := Value;
end;

procedure TCnBaseHashMap.SetOnCustomHashCode(
  const Value: TCnCustomHashCodeMethod);
begin
  if Assigned(Value) then
  begin
    FOnCustomHashCode := Value;
    if UseCustomHash then
      Refresh;
  end
  else
  //close  UseCustomHash
  begin
    FOnCustomHashCode := Value;
    UseCustomHash := false;
  end;
end;

procedure TCnBaseHashMap.SetUseCustomHash(const Value: Boolean);
begin
  if (Value <> FUseCustomHash) then
    if not (Value) then
    begin
      FUseCustomHash := Value;

      Refresh;
    end
    else
      if Assigned(OnCustomHashCode) then
      begin
        FUseCustomHash := Value;

        Refresh;
      end;
end;

procedure TCnBaseHashMap.StartEnum;
begin
  FCurPos := -1;
end;

function TCnBaseHashMap.VariantHashCode(AKey: Variant): Integer;
begin
  //here is just a example
  //u should change it when it's a string or an object
  Result := Integer(AKey);
end;

{ TCnStrToStrHashMap }

procedure TCnStrToStrHashMap.Add(const AKey, AValue: string);
begin
  AddInternal(AKey, AValue);
end;

function TCnStrToStrHashMap.Delete(const AKey: string): Boolean;
begin
  Result := DeleteInternal(AKey);
end;

function TCnStrToStrHashMap.Find(const AKey: string;
  var AValue: string): Boolean;
var
  myValue: Variant;
begin
  Result := FindInternal(Variant(AKey), myValue);

  if Result then
    AValue := myValue;
end;

function TCnStrToStrHashMap.GetNext(var AKey, AValue: string): Boolean;
var
  myKey, myValue: Variant;
begin
  Result := GetNextInternal(myKey, myValue);

  if Result then
  begin
    AKey := myKey;
    AValue := myValue;
  end;
end;

function TCnStrToStrHashMap.VariantHashCode(AKey: Variant): Integer;
var
  myHashCode, I: Integer;
  HashString: string;
begin
  myHashCode := 0;
  HashString := AKey;

  for I := 1 to Length(HashString) do
    myHashCode := myHashCode shl 5 + ord(HashString[I]) + myHashCode;

  Result := Abs(myHashCode);
end;

{ TCnWideStrToWideStrHashMap }

procedure TCnWideStrToWideStrHashMap.Add(const AKey, AValue: WideString);
begin
  AddInternal(AKey, AValue);
end;

function TCnWideStrToWideStrHashMap.Delete(const AKey: WideString): Boolean;
begin
  Result := DeleteInternal(AKey);
end;

function TCnWideStrToWideStrHashMap.Find(const AKey: WideString;
  var AValue: WideString): Boolean;
var
  myValue: Variant;
begin
  Result := FindInternal(Variant(AKey), myValue);

  if Result then
    AValue := myValue;
end;

function TCnWideStrToWideStrHashMap.GetNext(var AKey, AValue: WideString): Boolean;
var
  myKey, myValue: Variant;
begin
  Result := GetNextInternal(myKey, myValue);

  if Result then
  begin
    AKey := myKey;
    AValue := myValue;
  end;
end;

function TCnWideStrToWideStrHashMap.VariantHashCode(AKey: Variant): Integer;
var
  myHashCode, I: Integer;
  HashString: WideString;
begin
  myHashCode := 0;
  HashString := AKey;

  for I := 1 to Length(HashString) do
    myHashCode := myHashCode shl 5 + ord(HashString[I]) + myHashCode;

  Result := Abs(myHashCode);
end;

{ TCnShortStrToPtrHashMap }

function TCnStrToPtrHashMap.VariantHashCode(AKey: Variant): Integer;
var
  iHashCode, I: Integer;
  HashString: string;
begin
  iHashCode := 0;
  HashString := AKey;

  for I := 1 to Length(HashString) do
    iHashCode := iHashCode shl 5 + Ord(HashString[I]) + iHashCode;

  Result := Abs(iHashCode);
end;

procedure TCnStrToPtrHashMap.Add(const AKey: string; AValue: Pointer);
begin
  AddInternal(AKey, Integer(AValue));
end;

function TCnStrToPtrHashMap.Delete(const AKey: string): Boolean;
begin
  Result := DeleteInternal(AKey);
end;

function TCnStrToPtrHashMap.Find(const AKey: string; var AValue: Pointer): Boolean;
var
  vValue: Variant;
begin
  Result := FindInternal(Variant(AKey), vValue);

  if Result then
    AValue := Pointer(Integer(vValue));
end;

function TCnStrToPtrHashMap.GetNext(var AKey: string; var AValue: Pointer): Boolean;
var
  vKey, vValue: Variant;
begin
  Result := GetNextInternal(vKey, vValue);

  if Result then
  begin
    AKey := vKey;
    AValue := Pointer(Integer(vValue));
  end;
end;

{ TCnStrToVariantHashMap }

procedure TCnStrToVariantHashMap.Add(const AKey: string; AValue: Variant);
begin
  AddInternal(AKey, AValue);
end;

function TCnStrToVariantHashMap.Delete(const AKey: string): Boolean;
begin
  Result := DeleteInternal(AKey);
end;

function TCnStrToVariantHashMap.Find(const AKey: string;
  var AValue: Variant): Boolean;
begin
  Result := FindInternal(Variant(AKey), AValue);
end;

function TCnStrToVariantHashMap.GetNext(var AKey: string;
  var AValue: Variant): Boolean;
var
  vKey: Variant;
begin
  Result := GetNextInternal(vKey, AValue);

  if Result then
    AKey := vKey;
end;

function TCnStrToVariantHashMap.VariantHashCode(AKey: Variant): Integer;
var
  iHashCode, I: Integer;
  HashString: string;
begin
  iHashCode := 0;
  HashString := AKey;

  for I := 1 to Length(HashString) do
    iHashCode := iHashCode shl 5 + Ord(HashString[I]) + iHashCode;

  Result := Abs(iHashCode);
end;

//------------------------------------------------------------------------------
// TCnHashMap ����ʵ��
//------------------------------------------------------------------------------

function GetObjectHashCode(Obj: TObject): Integer;
begin
{$IFDEF OBJECT_HAS_GETHASHCODE}
  Result := Obj.GetHashCode; // ������ 64 λ�� 32 λ���۵�
{$ELSE}
  Result := Integer(Obj);
{$ENDIF}
end;

{ TCnHashMap }

procedure TCnHashMap.Add(Key, Value: Int64);
begin
{$IFDEF CPU64BITS}
  Put(HashCodeFromInt64(Key), TObject(Key), TObject(Value));
{$ELSE}
  Put(HashCodeFromInt64(Key), TObject(Int64Rec(Key).Lo), TObject(Int64Rec(Value).Lo),
    TObject(Int64Rec(Key).Hi), TObject(Int64Rec(Value).Hi));
{$ENDIF}
end;

procedure TCnHashMap.Add(Key, Value: Integer);
begin
  Put(HashCodeFromInteger(Key), TObject(Key), TObject(Value)
    {$IFNDEF CPU64BITS}, nil, nil {$ENDIF});
end;

procedure TCnHashMap.Add(Key, Value: TObject);
begin
  Put(HashCodeFromObject(Key), Key, Value
    {$IFNDEF CPU64BITS} , nil, nil {$ENDIF});
end;

procedure TCnHashMap.CheckResize;
begin
  if FSize > FThreshold then
    Resize(FCapacity shl 1);
end;

procedure TCnHashMap.Clear;
begin
  ClearAll(True);
end;

function TCnHashMap.Contain(HashCode: Integer; Key: TObject {$IFNDEF CPU64BITS};
  KeyHigh32: TObject {$ENDIF}): TCnHashNode;
var
  Idx: Integer;
  Node: TCnHashNode;
begin
  Result := nil;
  Idx := IndexForHash(HashCode, FCapacity);

  Node := FTable[Idx];
  if Node = nil then
    Exit;

  repeat
    if KeyEqual(Key, Node.Key {$IFNDEF CPU64BITS}, KeyHigh32, Node.Key32 {$ENDIF}) then
    begin
      Result := Node;
      Exit;
    end;
    Node := Node.Next;
  until Node = nil;
end;

constructor TCnHashMap.Create(ACapacity: Integer; ALoadFactor: Double);
begin
  if ACapacity <= 0 then
    ACapacity := CN_HASH_MAP_DEFAULT_CAPACITY;
  FLoadFactor := ALoadFactor;
  if (FLoadFactor <= 0.0) or (FLoadFactor >= 1.0) then
    raise ECnHashException.Create(SCnHashInValidFactor);

  FCapacity := GetUInt32PowerOf2GreaterEqual(ACapacity);
  if FCapacity = 0 then
    FCapacity := CN_HASH_MAP_MAX_CAPACITY;

  // �� FCapacity ��С��ʼ�� FTable ��̬����
  SetLength(FTable, FCapacity);
  FThreshold := Trunc(FLoadFactor * FCapacity);
end;

function TCnHashMap.CreateIterator: ICnHashMapIterator;
begin
  Result := TCnHashMapIterator.Create(Self);
end;

function TCnHashMap.Del(HashCode: Integer; Key: TObject {$IFNDEF CPU64BITS};
  KeyHigh32: TObject {$ENDIF}): Boolean;
var
  Idx: Integer;
  Node, Prev: TCnHashNode;
begin
  Result := False;
  Idx := IndexForHash(HashCode, FCapacity);

  Node := FTable[Idx];
  if Node = nil then
    Exit;

  Prev := nil;
  repeat
    if KeyEqual(Key, Node.Key {$IFNDEF CPU64BITS}, KeyHigh32, Node.Key32 {$ENDIF}) then
    begin
      // ����� Node��Ҫɾ
      if FTable[Idx] = Node then
      begin
        // ����ͷ
        FTable[Idx] := Node.Next;
      end;
      if Prev <> nil then
        Prev.Next := Node.Next;

      DoFreeNode(Node);
      Node.Free;

      Inc(FModCount);
      Dec(FSize);

      Result := True;
      Exit;
    end;

    Prev := Node;
    Node := Node.Next;
  until Node = nil;
end;

destructor TCnHashMap.Destroy;
begin
  ClearAll; // ����Ҫ�ٷ���
  SetLength(FTable, 0);
  inherited;
end;

procedure TCnHashMap.DoFreeNode(Node: TCnHashNode);
begin
  if Assigned(FOnFreeNode) then
    FOnFreeNode(Self, Node);
end;

function TCnHashMap.Find(Key: TObject): TObject;
begin
  Result := nil;
  Get(HashCodeFromObject(Key), Key, Result);
end;

function TCnHashMap.Find(Key: Integer): Integer;
var
  Obj: TObject;
begin
  Obj := nil;
  Get(HashCodeFromInteger(Key), TObject(Key), Obj);
  Result := Integer(Obj);
end;

function TCnHashMap.Find(Key: Int64): Int64;
var
{$IFNDEF CPU64BITS}
  VLo, VHi: TObject;
{$ELSE}
  Obj: TObject;
{$ENDIF}
begin
{$IFDEF CPU64BITS}
  Obj := nil;
  Get(HashCodeFromInteger(Key), TObject(Key), Obj);
  Result := Int64(Obj);
{$ELSE}
  VLo := nil;
  VHi := nil;
  if Get(HashCodeFromInteger(Key), TObject(Int64Rec(Key).Lo), VLo,
    TObject(Int64Rec(Key).Hi), @VHi) then
  begin
    Int64Rec(Result).Hi := Cardinal(VHi);
    Int64Rec(Result).Lo := Cardinal(VLo);
  end
  else
    Result := 0;
{$ENDIF}
end;

function TCnHashMap.Get(HashCode: Integer; Key: TObject; out Value: TObject
  {$IFNDEF CPU64BITS}; Key32: TObject; ValueHigh32: Pointer {$ENDIF}): Boolean;
var
  Idx: Integer;
  Node: TCnHashNode;
begin
  Result := False;
  Idx := IndexForHash(HashCode, FCapacity);

  Node := FTable[Idx];
  if Node = nil then
    Exit;

  repeat
    if KeyEqual(Key, Node.Key {$IFNDEF CPU64BITS}, Key32, Node.Key32 {$ENDIF}) then
    begin
      Result := True;
      Value := Node.Value;
{$IFNDEF CPU64BITS}
      if ValueHigh32 <> nil then
        (PObject(ValueHigh32))^ := Node.Value32;
{$ENDIF}
      Break;
    end;
    Node := Node.Next;
  until Node = nil;
end;

function TCnHashMap.HashCodeFromInt64(I64: Int64): Integer;
var
  H, L: Cardinal;
begin
  H := Int64Rec(I64).Hi;
  L := Int64Rec(I64).Lo;

  Result := H xor L;
  if Result <> 0 then
    Result := Result xor (Result shr 16);
end;

function TCnHashMap.HashCodeFromInteger(I: Integer): Integer;
begin
  Result := I xor (I shr 16);
end;

function TCnHashMap.HashCodeFromObject(Obj: TObject): Integer;
begin
  Result := GetObjectHashCode(Obj);
  if Result <> 0 then
    Result := Result xor (Result shr 16);
end;

function TCnHashMap.HasKey(Key: TObject): Boolean;
begin
  Result := Contain(HashCodeFromObject(Key), Key) <> nil;
end;

function TCnHashMap.HasKey(Key: Integer): Boolean;
begin
  Result := Contain(HashCodeFromInteger(Key), TObject(Key)) <> nil;
end;

function TCnHashMap.HasKey(Key: Int64): Boolean;
begin
{$IFDEF CPU64BITS}
  Result := Contain(HashCodeFromInt64(Key), TObject(Key)) <> nil;
{$ELSE}
  Result := Contain(HashCodeFromInt64(Key), TObject(Int64Rec(Key).Lo),
    TObject(Int64Rec(Key).Hi)) <> nil;
{$ENDIF}
end;

function TCnHashMap.IndexForHash(H, L: Integer): Integer;
begin
  Result := H and (L - 1);
end;

function TCnHashMap.Put(HashCode: Integer; Key, Value: TObject
 {$IFNDEF CPU64BITS}; KeyHigh32, ValueHigh32: TObject {$ENDIF}): TCnHashNode;
var
  Idx: Integer;
  Node, Prev: TCnHashNode;

  function PutKeyValueToNode(ANode: TCnHashNode): TCnHashNode;
  begin
    ANode.Hash := HashCode;
    ANode.Key := Key;
    ANode.Value := Value;
{$IFNDEF CPU64BITS}
    ANode.Key32 := KeyHigh32;
    ANode.Value32 := ValueHigh32;
{$ENDIF}
    Result := ANode;
  end;

begin
  Idx := IndexForHash(HashCode, FCapacity);

  Node := FTable[Idx];
  if Node = nil then
  begin
    FTable[Idx] := TCnHashNode.Create;
    Result := PutKeyValueToNode(FTable[Idx]);
    Inc(FModCount);
    Inc(FSize);
    CheckResize;
  end
  else
  begin
    repeat
      if KeyEqual(Key, Node.Key {$IFNDEF CPU64BITS}, KeyHigh32, Node.Key32 {$ENDIF}) then // �ҵ��� Key��ֱ���� Value
      begin
        Result := PutKeyValueToNode(Node);
        Inc(FModCount);
        Exit;
      end;
      Prev := Node;
      Node := Node.Next;
    until Node = nil;

    // û�ҵ���Node ���������һ���ڵ㣬���µ�
    Prev.Next := TCnHashNode.Create;
    Result := PutKeyValueToNode(Prev.Next);
    Inc(FModCount);
    Inc(FSize);
    CheckResize;
  end;
end;

procedure TCnHashMap.Remove(Key: Int64);
begin
{$IFDEF CPU64BITS}
  Del(HashCodeFromInt64(Key), TObject(Key));
{$ELSE}
  Del(HashCodeFromInt64(Key), TObject(Int64Rec(Key).Lo), TObject(Int64Rec(Key).Hi));
{$ENDIF}
end;

procedure TCnHashMap.Remove(Key: Integer);
begin
  Del(HashCodeFromInteger(Key), TObject(Key));
end;

procedure TCnHashMap.Remove(Key: TObject);
begin
  Del(HashCodeFromObject(Key), Key);
end;

procedure TCnHashMap.Resize(NewCapacity: Integer);
var
  It: ICnHashMapIterator;
  Idx: Integer;
  Node, P, Prev: TCnHashNode;
  NewTable: TCnHashNodeArray;
begin
  if NewCapacity > CN_HASH_MAP_MAX_CAPACITY then
    NewCapacity := CN_HASH_MAP_MAX_CAPACITY;

  if NewCapacity = FCapacity then
    Exit;

  SetLength(NewTable, NewCapacity);
  It := CreateIterator;
  while not It.Eof do
  begin
    Node := It.CurrentNode;
    It.Next;  // ������������һ���ڵ㣬��Ϊ����˽ڵ�ᱻժ��

    Node.Next := nil; // Node ��ԭ������ժ��

    // �õ� HashCode�����¼��� Index�������� Table ��λ��
    Idx := IndexForHash(Node.Hash, NewCapacity);
    if NewTable[Idx] = nil then
    begin
      NewTable[Idx] := Node;
    end
    else
    begin
      // �Ѿ����ˣ�������β
      P := NewTable[Idx];

      repeat
        Prev := P;
        P := P.Next;
      until P = nil;
      // �ҵ�����β������ Node
      Prev.Next := Node;
    end;
  end;
  It := nil;

  SetLength(FTable, 0);
  FTable := NewTable;

  FCapacity := NewCapacity;
  FThreshold := Trunc(FloadFactor * FCapacity);
end;

procedure TCnHashMap.ClearAll(Shrink: Boolean);
var
  I: Integer;
  Node, T: TCnHashNode;
begin
  for I := Low(FTable) to High(FTable) do
  begin
    Node := FTable[I];
    while Node <> nil do
    begin
      T := Node.Next;
      DoFreeNode(Node);
      Node.Free;
      Node := T;
    end;

    FTable[I] := nil;
  end;
  FSize := 0;

  if Shrink and (Cardinal(FCapacity) > GetUInt32PowerOf2GreaterEqual(CN_HASH_MAP_DEFAULT_CAPACITY)) then
  begin
    FCapacity := GetUInt32PowerOf2GreaterEqual(CN_HASH_MAP_DEFAULT_CAPACITY);
    SetLength(FTable, FCapacity);
    FThreshold := Trunc(FLoadFactor * FCapacity);
  end;
end;

function TCnHashMap.KeyEqual(Key1, Key2: TObject
  {$IFNDEF CPU64BITS}; Key132, Key232: TObject {$ENDIF}): Boolean;
begin
  Result := (Key1 = Key2) {$IFNDEF CPU64BITS} and (Key132 = Key232) {$ENDIF};
end;

function TCnHashMap.Find(Key: TObject; out OutObj: TObject): Boolean;
begin
  Result := Get(HashCodeFromObject(Key), Key, OutObj);
end;

function TCnHashMap.Find(Key: Integer; out OutInt: Integer): Boolean;
var
  Obj: TObject;
begin
  Result := Get(HashCodeFromInteger(Key), TObject(Key), Obj);
  if Result then
    OutInt := Integer(Obj);
end;

function TCnHashMap.Find(Key: Int64; out OutInt64: Int64): Boolean;
var
{$IFNDEF CPU64BITS}
  VLo, VHi: TObject;
{$ELSE}
  Obj: TObject;
{$ENDIF}
begin
{$IFDEF CPU64BITS}
  Obj := nil;
  Result := Get(HashCodeFromInteger(Key), TObject(Key), Obj);
  if Result then
    OutInt64 := Int64(Obj);
{$ELSE}
  VLo := nil;
  VHi := nil;
  Result := Get(HashCodeFromInteger(Key), TObject(Int64Rec(Key).Lo), VLo,
    TObject(Int64Rec(Key).Hi), @VHi);
  if Result then
  begin
    Int64Rec(OutInt64).Hi := Cardinal(VHi);
    Int64Rec(OutInt64).Lo := Cardinal(VLo);
  end;
{$ENDIF}
end;

{ TCnHashNode }

function TCnHashNode.GetKey: TObject;
begin
  Result := FKey;
end;

{$IFNDEF CPU64BITS}

function TCnHashNode.GetKey32: TObject;
begin
  Result := FKey32;
end;

{$ENDIF}

function TCnHashNode.GetKey64: Int64;
begin
{$IFDEF CPU64BITS}
  Result := Int64(FKey);
{$ELSE}
  Int64Rec(Result).Hi := Cardinal(FKey32);
  Int64Rec(Result).Lo := Cardinal(FKey);
{$ENDIF}
end;

function TCnHashNode.GetValue: TObject;
begin
  Result := FValue;
end;

{$IFNDEF CPU64BITS}

function TCnHashNode.GetValue32: TObject;
begin
  Result := FValue32;
end;

{$ENDIF}

function TCnHashNode.GetValue64: Int64;
begin
{$IFDEF CPU64BITS}
  Result := Int64(FValue);
{$ELSE}
  Int64Rec(Result).Hi := Cardinal(FValue32);
  Int64Rec(Result).Lo := Cardinal(FValue);
{$ENDIF}
end;

procedure TCnHashNode.SetKey(const Value: TObject);
begin
  FKey := Value;
end;

{$IFNDEF CPU64BITS}

procedure TCnHashNode.SetKey32(const Value: TObject);
begin
  FKey32 := Value;
end;

{$ENDIF}

procedure TCnHashNode.SetKey64(const Value: Int64);
begin
{$IFDEF CPU64BITS}
  FKey := TObject(Value);
{$ELSE}
  FKey32 := TObject(Int64Rec(Value).Hi);
  FKey := TObject(Int64Rec(Value).Lo);
{$ENDIF}
end;

procedure TCnHashNode.SetValue(const Value: TObject);
begin
  FValue := Value;
end;

{$IFNDEF CPU64BITS}

procedure TCnHashNode.SetValue32(const Value: TObject);
begin
  FValue32 := Value;
end;

{$ENDIF}

procedure TCnHashNode.SetValue64(const Value: Int64);
begin
{$IFDEF CPU64BITS}
  FValue := TObject(Value);
{$ELSE}
  FValue32 := TObject(Int64Rec(Value).Hi);
  FValue := TObject(Int64Rec(Value).Lo);
{$ENDIF}
end;

{ TCnHashMapIterator }

constructor TCnHashMapIterator.Create(Map: TCnHashMap);
begin
  inherited Create;
  FMap := Map;
  FCurrentTableIndex := -1;
  FModCount := FMap.FModCount;
  First;
end;

function TCnHashMapIterator.CurrentIndex: Integer;
begin
  Result := FCurrentTableIndex;
end;

function TCnHashMapIterator.CurrentNode: TCnHashNode;
begin
  Result := FCurrentNodeRef;
end;

destructor TCnHashMapIterator.Destroy;
begin

  inherited;
end;

function TCnHashMapIterator.Eof: Boolean;
begin
  Result := FEof;
end;

procedure TCnHashMapIterator.First;
var
  I: Integer;
begin
  if FModCount <> FMap.FModCount then
    raise ECnHashException.Create(SCnHashConcurrentError);

  for I := Low(FMap.FTable) to High(FMap.FTable) do
  begin
    if FMap.FTable[I] <> nil then
    begin
      FCurrentNodeRef := FMap.FTable[I];
      FCurrentTableIndex := I;
      Exit;
    end;
  end;
  FEof := True;
end;

procedure TCnHashMapIterator.Next;
var
  I: Integer;
begin
  if FModCount <> FMap.FModCount then
    raise ECnHashException.Create(SCnHashConcurrentError);

  if not FEof then
  begin
    if FCurrentNodeRef.Next <> nil then // ��������滹��
    begin
      FCurrentNodeRef := FCurrentNodeRef.Next;
      Exit;
    end;

    // ���������û��
    if FCurrentTableIndex < High(FMap.FTable) then
    begin
      for I := FCurrentTableIndex + 1 to High(FMap.FTable) do
      begin
        if FMap.FTable[I] <> nil then
        begin
          FCurrentNodeRef := FMap.FTable[I];
          FCurrentTableIndex := I;
          Exit;
        end;
      end;
    end;
    FEof := True;
  end;  
end;

end.

