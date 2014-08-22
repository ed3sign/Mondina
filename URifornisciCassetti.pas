unit URifornisciCassetti;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ADODB, DB;

type
  TfrmRifornisciCassetti = class(TForm)
    btnChiudi: TButton;
    btnRifornisci: TButton;
    mmInfo: TMemo;
    qrRifornisci: TADOQuery;
    qrQuery: TADOQuery;
    img1: TImage;
    procedure btnChiudiClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnRifornisciClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure GetInfoProdotto(CodProd: string; var Nome: string; var QtaMagazzino: Integer);
    procedure RiempiCassettoParz(CodCassetto, CodProd: string; QtaMagazzino: Integer);
    procedure RiempiCassettoTot(CodCassetto, CodProd: string; QtaUsata: Integer);
  end;

var
  frmRifornisciCassetti: TfrmRifornisciCassetti;

implementation

uses dmConnection, UMessaggi, UVisMagazzino;

{$R *.dfm}

procedure TfrmRifornisciCassetti.btnChiudiClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmRifornisciCassetti.FormShow(Sender: TObject);
begin
  mmInfo.Clear;
end;

procedure TfrmRifornisciCassetti.btnRifornisciClick(Sender: TObject);
var
  qtaUsata, qtaMagazzino: Integer;
  CodProd: string;
  CodCassetto: string;
  NomeProd: string;
begin
  mmInfo.Clear;
  qrRifornisci.SQL.Text := 'SELECT * FROM [Prodotti_Cassetti] ' +
                           'WHERE [QtaUsata] > 0';
  qrRifornisci.Active := True;
  qrRifornisci.First;
  while not qrRifornisci.Eof do
  begin
    CodProd := qrRifornisci.FieldByName('CodProdotto').AsString;
    CodCassetto := qrRifornisci.FieldByName('CodCassetto').AsString;
    qtaUsata := qrRifornisci.FieldByName('QtaUsata').AsInteger;
    GetInfoProdotto(CodProd, NomeProd, qtaMagazzino);

    if qtaMagazzino = 0 then
      mmInfo.Lines.Add('Cassetto ' + CodCassetto + ' non rifornito di ' + NomeProd)
    else
    begin
      if qtaUsata > qtaMagazzino then
      begin
        RiempiCassettoParz(CodCassetto, CodProd, qtaMagazzino);
        mmInfo.Lines.Add('Cassetto ' + CodCassetto + ' rifornito parzialmente di ' + NomeProd);
      end
      else RiempiCassettoTot(CodCassetto, CodProd, qtaUsata);
    end;
    qrRifornisci.Next;
  end;
  mmInfo.Lines.Add('Cassetti Riforniti - Operazione Terminata');
  qrRifornisci.Active := False;

  frmVisMagazzino.LoadProdotti;  
end;

procedure TfrmRifornisciCassetti.GetInfoProdotto(CodProd: string; var Nome: string; var QtaMagazzino: Integer);
begin
  qrQuery.SQL.Text := 'SELECT [Nome], [QtaTotale] FROM [Prodotti] ' +
                      'WHERE [Codice] = ' + CodProd;
  qrQuery.Active := True;
  Nome := qrQuery.FieldByName('Nome').AsString;
  QtaMagazzino := qrQuery.FieldByName('QtaTotale').AsInteger;
  qrQuery.Active := False;
end;

procedure TfrmRifornisciCassetti.RiempiCassettoTot(CodCassetto, CodProd: string; QtaUsata: Integer);
begin
  try
    qrQuery.SQL.Text := 'UPDATE [Prodotti_Cassetti] ' +
                        'SET [QtaUsata] = 0 ' +
                        'WHERE [CodCassetto] = ' + QuotedStr(CodCassetto) + ' AND ' +
                              '[CodProdotto] = ' + CodProd;
    qrQuery.ExecSQL;
    qrQuery.SQL.Text := 'UPDATE [Prodotti] ' +
                        'SET [QtaTotale] = [QtaTotale] - ' + IntToStr(QtaUsata) + ' ' +
                        'WHERE [Codice] = ' + CodProd;
    qrQuery.ExecSQL;
  except
    ShowMessage(MSG_ERRORE_SCRITTURA_DB);
  end;
end;

procedure TfrmRifornisciCassetti.RiempiCassettoParz(CodCassetto, CodProd: string; QtaMagazzino: Integer);
begin
  try
    qrQuery.SQL.Text := 'UPDATE [Prodotti_Cassetti] ' +
                        'SET [QtaUsata] =  [QtaUsata] - ' + IntToStr(QtaMagazzino) + ' ' + 
                        'WHERE [CodCassetto] = ' + QuotedStr(CodCassetto) + ' AND ' +
                              '[CodProdotto] = ' + CodProd;
    qrQuery.ExecSQL;
    qrQuery.SQL.Text := 'UPDATE [Prodotti] ' +
                        'SET [QtaTotale] = 0 ' +
                        'WHERE [Codice] = ' + CodProd;
    qrQuery.ExecSQL;
  except
    ShowMessage(MSG_ERRORE_SCRITTURA_DB);
  end;
end;

end.
