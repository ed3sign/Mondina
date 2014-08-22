unit UVisCassetti;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Grids, DBGrids, DB, ADODB, ExtCtrls, NumberLabeledEdit,
  NumberEdit;

type
  TfrmVisCassetti = class(TForm)
    gbCassetti: TGroupBox;
    gbProdotti: TGroupBox;
    lbCassetti: TListBox;
    gbFiltro: TGroupBox;
    cbStudi: TComboBox;
    cbMobili: TComboBox;
    lblInfo2: TLabel;
    lblInfo1: TLabel;
    qrQuery: TADOQuery;
    dgProdotti: TDBGrid;
    dsProdotti: TDataSource;
    lblInfo3: TLabel;
    qrProdotti: TADOQuery;
    lblInfo4: TLabel;
    lblCassettoSel: TLabel;
    gbProdottoUsato: TGroupBox;
    btnInserisci: TButton;
    btnChiudi: TButton;
    lblInfo5: TLabel;
    lblProdottoSel: TLabel;
    edtProdottoUsato: TNumberEdit;
    Bevel2: TBevel;
    img1: TImage;
    procedure FormShow(Sender: TObject);
    procedure cbStudiChange(Sender: TObject);
    procedure cbMobiliChange(Sender: TObject);
    procedure lbCassettiClick(Sender: TObject);
    procedure dgProdottiCellClick(Column: TColumn);
    procedure btnChiudiClick(Sender: TObject);
    procedure btnInserisciClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure LoadProdotti;
    procedure LoadStudi;
    procedure LoadMobili;
    procedure LoadCassetti;
    procedure LoadTuttiCassetti;
    procedure ResetCampi;
    procedure ResetCampiFiltroCassetto;
    function EsisteRichiestaStudio(CodProdotto: string): Boolean;
    procedure AggiungiRichiestaStudio(CodProdotto, QtaRichiesta: string);
    procedure SommaRichiestaStudio(CodProdotto, QtaRichiesta: string);
    function GetAnnoStr: string;
  end;

var
  frmVisCassetti: TfrmVisCassetti;

implementation

uses dmConnection, UHashTable, UMessaggi;

{$R *.dfm}

var
  hsStudi: THashTable;
  hsMobili: THashTable;

{ **************************************************************************** }
{ *** Finestra *************************************************************** }

procedure TfrmVisCassetti.FormShow(Sender: TObject);
begin
  ResetCampi;
  LoadStudi;
  LoadTuttiCassetti;
end;

procedure TfrmVisCassetti.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  qrProdotti.Active := False;
end;

{ **************************************************************************** }
{ *** Componenti ************************************************************* }

procedure TfrmVisCassetti.cbStudiChange(Sender: TObject);
begin
  ResetCampi;
  qrProdotti.Active := False;
  if cbStudi.ItemIndex = 0 then LoadTuttiCassetti
  else LoadMobili;
end;

procedure TfrmVisCassetti.cbMobiliChange(Sender: TObject);
begin
  ResetCampiFiltroCassetto;
  qrProdotti.Active := False;
  LoadCassetti;
end;

procedure TfrmVisCassetti.lbCassettiClick(Sender: TObject);
begin
  LoadProdotti;
  lblCassettoSel.Caption := lbCassetti.Items[lbCassetti.ItemIndex];
  lblProdottoSel.Caption := EMPTYSTR;
  gbProdottoUsato.Visible := False;
end;

procedure TfrmVisCassetti.dgProdottiCellClick(Column: TColumn);
begin
  if not qrProdotti.IsEmpty then
  begin
    lblProdottoSel.Caption := qrProdotti.FieldByName('Nome').AsString;
    edtProdottoUsato.Text := EMPTYSTR;
    gbProdottoUsato.Visible := True;
  end;
end;

procedure TfrmVisCassetti.btnInserisciClick(Sender: TObject);
var
  qtaUsata: integer;
  CodProd: string;
  qtaRichiesta: Integer;
begin
  if edtProdottoUsato.Text = EMPTYSTR then ShowMessage(MSG_INSERIRE_DATI)
  else
  begin
    qtaUsata := StrToIntDef(edtProdottoUsato.Text, 0);
    qtaRichiesta := qtaUsata - qrProdotti.FieldByName('QtaUsata').AsInteger;

    if qtaUsata <= qrProdotti.FieldByName('QtaTotale').AsInteger then
    begin
      qrProdotti.Edit;
      qrProdotti.FieldByName('QtaUsata').AsInteger := qtaUsata;
      qrProdotti.Post;

      CodProd := qrProdotti.FieldByName('CodProdotto').AsString;
      if (EsisteRichiestaStudio(CodProd)) then SommaRichiestaStudio(CodProd, IntToStr(qtaRichiesta))
      else AggiungiRichiestaStudio(CodProd, IntToStr(qtaRichiesta));

      lblProdottoSel.Caption := EMPTYSTR;
      gbProdottoUsato.Visible := False;
    end
   else ShowMessage(MSG_QTAMAX_SUPERATA);
  end;
end;

procedure TfrmVisCassetti.btnChiudiClick(Sender: TObject);
begin
  Close;
end;

{ **************************************************************************** }
{ *** Reset ****************************************************************** }

procedure TfrmVisCassetti.ResetCampi;
begin
  cbMobili.Clear;
  lblCassettoSel.Caption := EMPTYSTR;
  lblProdottoSel.Caption := EMPTYSTR;
  edtProdottoUsato.Text := '0';
  gbProdottoUsato.Visible := False;
  lbCassetti.ItemIndex := -1;
end;

procedure TfrmVisCassetti.ResetCampiFiltroCassetto;
begin
  lblCassettoSel.Caption := EMPTYSTR;
  lblProdottoSel.Caption := EMPTYSTR;
  edtProdottoUsato.Text := '0';
  gbProdottoUsato.Visible := False;
  lbCassetti.ItemIndex := -1;
end;

{ **************************************************************************** }
{ *** Load ******************************************************************* }

procedure TfrmVisCassetti.LoadProdotti;
var sel: string;
begin
  qrProdotti.Active := False;
  sel := lbCassetti.Items[lbCassetti.ItemIndex];
  qrProdotti.SQL.Text := 'SELECT [Prodotti_Cassetti].*, [Prodotti].[Nome]' +
                         'FROM [Prodotti_Cassetti] INNER JOIN [Prodotti] ON ' +
                              '[Prodotti_Cassetti].[CodProdotto] = [Prodotti].[Codice] ' +
                         'WHERE [Prodotti_Cassetti].[CodCassetto] = ' + QuotedStr(sel) + ' ' +
                         'ORDER BY [Prodotti].[Nome]';
  qrProdotti.Active := True;
end;

procedure TfrmVisCassetti.LoadStudi;
begin
  hsStudi := THashTable.Create;
  cbStudi.Clear;
  cbStudi.Items.Add(' ');
  hsStudi.Add(' ', ' ');

  if LivelloUtente = '1' then
    qrQuery.SQL.Text := 'SELECT * FROM [Studi] ORDER BY [Nome]'

  else if LivelloUtente = '2' then
    qrQuery.SQL.Text := 'SELECT DISTINCT [Studi].* ' +
                        'FROM [Studi] INNER JOIN ([Mobili] INNER JOIN [Cassetti] ' +
                             'ON [Mobili].[Codice] = [Cassetti].[CodMobile]) ' +
                             'ON [Studi].[Codice] = [Mobili].[CodStudio] ' +
                        'WHERE [Cassetti].[CodAssociazioneAS] = ' + CodAssociazioneAS + ' ' +
                        'ORDER BY [Studi].[Nome]';

  qrQuery.Active := True;
  qrQuery.First;
  while not qrQuery.Eof do
  begin
    hsStudi.Add(qrQuery.FieldByName('Codice').AsString, qrQuery.FieldByName('Nome').AsString);
    cbStudi.Items.Add(qrQuery.FieldByName('Nome').AsString);
    qrQuery.Next;
  end;
  qrQuery.Active := False;
  cbStudi.ItemIndex := 0;
end;

procedure TfrmVisCassetti.LoadMobili;
var sel: string;
begin
  sel := hsStudi.GetKey(cbStudi.ItemIndex);
  hsMobili := THashTable.Create;
  cbMobili.Clear;

  if LivelloUtente = '1' then
    qrQuery.SQL.Text := 'SELECT * FROM [Mobili] WHERE [CodStudio] = ' + QuotedStr(sel) + ' ORDER BY [Nome]'

  else if LivelloUtente = '2' then
    qrQuery.SQL.Text := 'SELECT DISTINCT [Mobili].* ' +
                        'FROM [Mobili] INNER JOIN [Cassetti] ' +
                             'ON [Mobili].[Codice] = [Cassetti].[CodMobile] ' +
                        'WHERE [Cassetti].[CodAssociazioneAS] = ' + CodAssociazioneAS + ' AND ' +
                              '[Mobili].[CodStudio] = ' + QuotedStr(sel) + ' ' +
                        'ORDER BY [Mobili].[Nome]';

  qrQuery.Active := True;
  qrQuery.First;
  while not qrQuery.Eof do
  begin
    hsMobili.Add(qrQuery.FieldByName('Codice').AsString, qrQuery.FieldByName('Nome').AsString);
    cbMobili.Items.Add(qrQuery.FieldByName('Nome').AsString);
    qrQuery.Next;
  end;
  qrQuery.Active := False;
  cbMobili.ItemIndex := -1;
end;

procedure TfrmVisCassetti.LoadCassetti;
var sel: string;
begin
  sel := hsMobili.GetKey(cbMobili.ItemIndex);
  lbCassetti.Clear;

  if LivelloUtente = '1' then
    qrQuery.SQL.Text := 'SELECT [Codice] FROM [Cassetti] ' +
                        'WHERE [CodMobile] = ' + QuotedStr(sel) + ' ' +
                        'ORDER BY [Codice]'

  else if LivelloUtente = '2' then
      qrQuery.SQL.Text := 'SELECT [Codice] FROM [Cassetti] ' +
                          'WHERE [CodAssociazioneAS] = ' + CodAssociazioneAS + ' AND ' +
                                '[CodMobile] = ' + QuotedStr(sel) + ' ' +
                          'ORDER BY [Codice]';
                          
  qrQuery.Active := True;
  qrQuery.First;
  while not qrQuery.Eof do
  begin
    lbCassetti.Items.Add(qrQuery.FieldByName('Codice').AsString);
    qrQuery.Next;
  end;
  qrQuery.Active := False;
  lbCassetti.ItemIndex := -1;
end;

procedure TfrmVisCassetti.LoadTuttiCassetti;
begin
  lbCassetti.Clear;

  if LivelloUtente = '1' then
    qrQuery.SQL.Text := 'SELECT * FROM [Cassetti] ORDER BY [Codice]'

  else if LivelloUtente = '2' then
    qrQuery.SQL.Text := 'SELECT * FROM [Cassetti] ' +
                        'WHERE [CodAssociazioneAS] = ' + CodAssociazioneAS + ' ' +
                        'ORDER BY [Codice]';
                        
  qrQuery.Active := True;
  qrQuery.First;
  while not qrQuery.Eof do
  begin
    lbCassetti.Items.Add(qrQuery.FieldByName('Codice').AsString);
    qrQuery.Next;
  end;
  qrQuery.Active := False;
  lbCassetti.ItemIndex := -1;
end;

{ **************************************************************************** }
{ *** Gestione *************************************************************** }

function TfrmVisCassetti.GetAnnoStr: string;
var
  myYear, myMonth, myDay : Word;
begin
  DecodeDate(Date, myYear, myMonth, myDay);
  GetAnnoStr := IntToStr(myYear);
end;

function TfrmVisCassetti.EsisteRichiestaStudio(CodProdotto: string): Boolean;
var
  res: Boolean;
  Anno: string;
begin
  Anno := GetAnnoStr;
  res := True;
  qrQuery.SQL.Text := 'SELECT [CodProdotto] FROM [Prodotti_Richiesti_Studi] ' +
                      'WHERE [CodProdotto] = ' + CodProdotto + ' AND ' +
                            '[CodAssociazioneAS] = ' + CodAssociazioneAS + ' AND ' +
                            '[Anno] = ' + Anno;
  qrQuery.Active := True;
  if qrQuery.IsEmpty then res := False;
  qrQuery.Active := False;
  EsisteRichiestaStudio := res;
end;

procedure TfrmVisCassetti.AggiungiRichiestaStudio(CodProdotto, QtaRichiesta: string);
var Anno: string;
begin
  try
    Anno := GetAnnoStr;
    qrQuery.SQL.Text := 'INSERT INTO [Prodotti_Richiesti_Studi] ([Anno], [CodAssociazioneAS], [CodProdotto], QtaRichiesta) ' +
                        'VALUES (' + Anno + ', ' + CodAssociazioneAS +', ' + CodProdotto + ', ' + QtaRichiesta + ')';
    qrQuery.ExecSQL;
  except
    ShowMessage(MSG_ERRORE_SCRITTURA_DB);
  end;
end;

procedure TfrmVisCassetti.SommaRichiestaStudio(CodProdotto, QtaRichiesta: string);
var Anno: string;
begin
  try
    Anno := GetAnnoStr;
    qrQuery.SQL.Text := 'UPDATE [Prodotti_Richiesti_Studi] ' +
                        'SET [QtaRichiesta] = [QtaRichiesta] + ' + QtaRichiesta + ' ' +
                        'WHERE [CodProdotto] = ' + CodProdotto + ' AND ' +
                              '[CodAssociazioneAS] = ' + CodAssociazioneAS + ' AND ' +
                              '[Anno] = ' + Anno;
    qrQuery.ExecSQL;
  except
    ShowMessage(MSG_ERRORE_SCRITTURA_DB);
  end;
end;

end.
