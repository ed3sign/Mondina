unit UHashTable;

interface

uses
  Classes;


type
  THashTable = class
    public
      constructor Create;
      destructor Destroy;
      procedure Add(aKey, aValue: string);
      function GetKey(aItemIndex: Integer): string;
    private
      Key, Value: TStringList;
  end;

implementation

{ THashTable }

procedure THashTable.Add(aKey, aValue: string);
begin
  Key.Add(aKey);
  Value.Add(aValue);
end;

constructor THashTable.Create;
begin
  Key := TStringList.Create;
  Value := TStringList.Create;
end;

destructor THashTable.Destroy;
begin
  Key.Free;
  Value.Free;
end;

function THashTable.GetKey(aItemIndex: Integer): string;
begin
  GetKey :=  Key[aItemIndex];
end;

end.
 