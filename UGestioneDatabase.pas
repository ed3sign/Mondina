unit UGestioneDatabase;

interface

uses
  ComObj, SysUtils, Variants;

function CompattaDatabase(dbPath: string): Boolean;

implementation

uses dmConnection;

function CompattaDatabase(dbPath: string): Boolean;
var
  V: OleVariant;
  res: Boolean;
  dbTempPath: string;
  dbConn, dbTempConn: string;
begin
  res := True;
  dbTempPath := ExtractFileDir(dbPath) + 'TEMP_' + ExtractFileName(dbPath);
  dbConn := CNT_STRING + dbPath;
  dbTempConn := CNT_STRING + dbTempPath;

  try
    if FileExists(dbTempPath) then DeleteFile(dbTempPath);  
    dmCnt.AdoCnt.Connected := False;
    v := CreateOLEObject('JRO.JetEngine');
    v.CompactDatabase(dbConn, dbTempConn);
    DeleteFile(dbPath);
    RenameFile(dbTempPath, dbPath);
    v := Unassigned;
    dmCnt.AdoCnt.Connected := True;
  except
    res := False;
  end;
  CompattaDatabase := res;
end;

end.
