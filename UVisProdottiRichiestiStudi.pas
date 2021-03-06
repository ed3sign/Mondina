unit UVisProdottiRichiestiStudi;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, ADODB, StdCtrls, Grids, DBGrids, ExtCtrls;

type
  TfrmVisProdottiRichiestiStudi = class(TForm)
    img1: TImage;
    gbInfo: TGroupBox;
    dgProdotti: TDBGrid;
    gbFiltro: TGroupBox;
    lblInfo1: TLabel;
    cbAnni: TComboBox;
    btnChiudi: TButton;
    btnElimina: TButton;
    qrProdotti: TADOQuery;
    dsProdotti: TDataSource;
    qrQuery: TADOQuery;
    cbStudi: TComboBox;
    lblInfo2: TLabel;
    cbTipologie: TComboBox;
    lblInfo3: TLabel;
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnEliminaClick(Sender: TObject);
    procedure btnChiudiClick(Sender: TObject);
    procedure cbAnniChange(Sender: TObject);
    procedure cbStudiChange(Sender: TObject);
    procedure cbTipologieChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure LoadProdotti;
    procedure LoadAnni;
    procedure LoadStudi;
    procedure LoadTipologie;
    procedure CancellaRecord(Anno: string);    
  end;

var
  frmVisProdottiRichiestiStudi: TfrmVisProdottiRichiestiStudi;

implementation

uses dmConnection, UMessaggi, UHashTable;

var
  hsAssociazioneAS: THashTable;

{$R *.dfm}

{ TfrmVisProdottiRichiestiStudi }

{ **************************************************************************** }
{ *** Finestra *************************************************************** }

procedure TfrmVisProdottiRichiestiStudi.FormShow(Sender: TObject);
begin
  LoadAnni;
  LoadStudi;
  LoadTipologie;
  LoadProdotti;  
  cbAnni.SetFocus;
end;

procedure TfrmVisProdottiRichiestiStudi.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  qrProdotti.Active := False;
end;

{ **************************************************************************** }
{ *** Componenti ************************************************************* }

procedure TfrmVisProdottiRichiestiStudi.btnEliminaClick(Sender: TObject);
var
  ris: Integer;
  testo: string;
begin
  if cbAnni.ItemIndex = 0 then testo := MSG_ELIMINA_PRODOTTI_RICHIESTI_TUTTI
  else testo := MSG_ELIMINA_PRODOTTI_RICHIESTI_ANNO;
  ris := MessageDlg(testo, mtWarning, [mbYes, mbNo], 0);
  if ris = mrYes then
  begin
    CancellaRecord(cbAnni.Items[cbAnni.ItemIndex]);
    LoadAnni;
    LoadProdotti;
    ShowMessage(MSG_PRODOTTI_RICHIESTI_ELIMINATI);    
  end;
end;

procedure TfrmVisProdottiRichiestiStudi.btnChiudiClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmVisProdottiRichiestiStudi.cbAnniChange(Sender: TObject);
begin
  LoadProdotti;
end;

procedure TfrmVisProdottiRichiestiStudi.cbStudiChange(Sender: TObject);
begin
  LoadProdotti;
end;

procedure TfrmVisProdottiRichiestiStudi.cbTipologieChange(Sender: TObject);
begin
  LoadProdotti;
end;

{ **************************************************************************** }
{ *** Load ******************************************************************* }

procedure TfrmVisProdottiRichiestiStudi.LoadAnni;
begin
  cbAnni.Clear;
  cbAnni.Items.Add(' ');
  qrQuery.SQL.Text := 'SELECT DISTINCT [Anno] FROM [Prodotti_Richiesti_Studi] ORDER BY [Anno]';
  qrQuery.Active := True;
  qrQuery.First;
  while not qrQuery.Eof do
  begin
    cbAnni.Items.Add(qrQuery.FieldByName('Anno').AsString);
    qrQuery.Next;
  end;
  qrQuery.Active := False;
  cbAnni.ItemIndex := 0;
end;

procedure TfrmVisProdottiRichiestiStudi.LoadStudi;
begin
  hsAssociazioneAS := THashTable.Create;
  cbStudi.Clear;
  cbStudi.Items.Add(' ');
  cbStudi.Items.Add('AMMINISTRATORE');
  qrQuery.SQL.Text := 'SELECT [Codice], [Nome] FROM [AssociazioneAS] ORDER BY [Nome]';
  qrQuery.Active := True;
  qrQuery.First;
  while not qrQuery.Eof do
  begin
    hsAssociazioneAS.Add(qrQuery.FieldByName('Codice').AsString, qrQuery.FieldByName('Nome').AsString);
    cbStudi.Items.Add(qrQuery.FieldByName('Nome').AsString);
    qrQuery.Next;
  end;
  qrQuery.Active := False;
  cbStudi.ItemIndex := 0;
end;

procedure TfrmVisProdottiRichiestiStudi.LoadTipologie;
begin
  cbTipologie.Clear;
  cbTipologie.Items.Add(' ');
  qrQuery.SQL.Text := 'SELECT [Tipologia] FROM [Tipologie_Prodotti] ORDER BY [Tipologia]';
  qrQuery.Active := True;
  qrQuery.First;
  while not qrQuery.Eof do
  begin
    cbTipologie.Items.Add(qrQuery.FieldByName('Tipologia').AsString);
    qrQuery.Next;
  end;
  qrQuery.Active := False;
  cbTipologie.ItemIndex := 0;
end;

procedure TfrmVisProdottiRichiestiStudi.LoadProdotti;
var Anno, Tipologia, sel: string;
begin
  qrProdotti.Active := False;
  qrProdotti.SQL.Text := 'SELECT [Prodotti_Richiesti_Studi].[Anno], ' +
                                '[AssociazioneAS].[Nome] AS [NomeStudio],[Prodotti].[Tipologia], ' +
                                '[Prodotti].[Nome], [Prodotti_Richiesti_Studi].[QtaRichiesta] ' +
                         'FROM [Prodotti] RIGHT OUTER JOIN ([AssociazioneAS] RIGHT OUTER JOIN [Prodotti_Richiesti_Studi] ON ' + 
                              '[AssociazioneAS].[Codice] = [Prodotti_Richiesti_Studi].[CodAssociazioneAS]) ON ' +
                              '[Prodotti].[Codice] = [Prodotti_Richiesti_Studi].[CodProdotto] ' +
                         'WHERE (1 = 1) ';

  if cbAnni.ItemIndex <> 0 then
  begin
    Anno := cbAnni.Items[cbAnni.ItemIndex];
    qrProdotti.SQL.Text := qrProdotti.SQL.Text + 'AND [Prodotti_Richiesti_Studi].[Anno] = ' + Anno + ' ';
  end;

  if cbStudi.ItemIndex <> 0 then
  begin
    if cbStudi.ItemIndex = 1 then sel := '0'
    else  sel := hsAssociazioneAS.GetKey(cbStudi.ItemIndex-2);
    qrProdotti.SQL.Text := qrProdotti.SQL.Text + 'AND [Prodotti_Richiesti_Studi].[CodAssociazioneAS] = ' + sel + ' ';
  end;

  if cbTipologie.ItemIndex <> 0 then
  begin
    Tipologia := cbTipologie.Items[cbTipologie.ItemIndex];
    qrProdotti.SQL.Text := qrProdotti.SQL.Text + 'AND [Prodotti].[Tipologia] = ' + QuotedStr(Tipologia) + ' ';
  end;
  qrProdotti.SQL.Text := qrProdotti.SQL.Text + 'ORDER BY [Prodotti_Richiesti_Studi].[Anno], ' +
                                                        '[AssociazioneAS].[Nome], ' +
                                                        '[Prodotti].[Tipologia], ' +
                                                        '[Prodotti].[Nome]';
  qrProdotti.Active := True;
end;

{ **************************************************************************** }
{ *** Gestione *************************************************************** }

procedure TfrmVisProdottiRichiestiStudi.CancellaRecord(Anno: string);
begin
  try
    if anno = ' ' then
      qrQuery.SQL.Text := 'DELETE FROM [Prodotti_Richiesti_Studi]'
    else
      qrQuery.SQL.Text := 'DELETE FROM [Prodotti_Richiesti_Studi] WHERE [Anno] = ' + Anno;
    qrQuery.ExecSQL;
  except
    ShowMessage(MSG_ERRORE_SCRITTURA_DB);
  end;
end;

end.
