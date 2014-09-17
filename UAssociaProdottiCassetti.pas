unit UAssociaProdottiCassetti;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Grids, DBGrids, TextEdit, DB, ADODB,
  NumberEdit, TextLabeledEdit;

type
  TfrmAssociaProdottiCassetti = class(TForm)
    gbProdottiCassetto: TGroupBox;
    gbProdotti: TGroupBox;
    btnChiudi: TButton;
    gbCassetti: TGroupBox;
    lblInfo4: TLabel;
    lblCassettoSel: TLabel;
    lbCassetti: TListBox;
    gbFiltro: TGroupBox;
    lblInfo2: TLabel;
    lblInfo1: TLabel;
    cbStudi: TComboBox;
    cbMobili: TComboBox;
    dgProdotti: TDBGrid;
    dgProdCassetto: TDBGrid;
    lblInfo3: TLabel;
    lblProdSel: TLabel;
    qrQuery: TADOQuery;
    qrProdCassetto: TADOQuery;
    dsProdCassetto: TDataSource;
    qrProdotti: TADOQuery;
    dsProdotti: TDataSource;
    btnElimina: TButton;
    gbQtaMaxProd: TGroupBox;
    btnInserisci: TButton;
    edtQtaMax: TNumberEdit;
    gbFiltro2: TGroupBox;
    Label1: TLabel;
    cbTipologie: TComboBox;
    edtFiltroProd: TTextLabeledEdit;
    Bevel2: TBevel;
    img1: TImage;
    Label2: TLabel;
    lblProdCassSel: TLabel;
    procedure FormShow(Sender: TObject);
    procedure cbStudiChange(Sender: TObject);
    procedure cbMobiliChange(Sender: TObject);
    procedure lbCassettiClick(Sender: TObject);
    procedure edtFiltroProdKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure dgProdottiCellClick(Column: TColumn);
    procedure btnEliminaClick(Sender: TObject);
    procedure dgProdCassettoCellClick(Column: TColumn);
    procedure btnChiudiClick(Sender: TObject);
    procedure btnInserisciClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure cbTipologieChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure LoadTipologie;
    procedure LoadStudi;
    procedure LoadMobili;
    procedure LoadCassetti;
    procedure LoadTuttiCassetti;
    procedure ResetCampi;
    procedure ResetCampiFiltroCassetto;    
    procedure LoadProdottiCassetto;
    procedure LoadProdotti;
    procedure InserisciProdotto;
    procedure EliminaProdotto;
    function EsisteProdotto(CodProd, CodCassetto: string): Boolean;
  end;

var
  frmAssociaProdottiCassetti: TfrmAssociaProdottiCassetti;

implementation

uses UHashTable, dmConnection, UMessaggi;

{$R *.dfm}

var
  hsStudi: THashTable;
  hsMobili: THashTable;

{ **************************************************************************** }
{ *** Finestra *************************************************************** }

procedure TfrmAssociaProdottiCassetti.FormShow(Sender: TObject);
begin
  ResetCampi;
  LoadStudi;
  LoadTuttiCassetti;
  LoadProdotti;
  LoadTipologie;
  cbStudi.SetFocus;
end;

procedure TfrmAssociaProdottiCassetti.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  qrProdCassetto.Active := False;
  qrProdotti.Active := False;
end;

{ **************************************************************************** }
{ *** Componenti ************************************************************* }

procedure TfrmAssociaProdottiCassetti.cbStudiChange(Sender: TObject);
begin
  cbMobili.Clear;
  ResetCampi;
  qrProdCassetto.Active := False;
  if cbStudi.ItemIndex = 0 then LoadTuttiCassetti
  else LoadMobili;
end;

procedure TfrmAssociaProdottiCassetti.cbMobiliChange(Sender: TObject);
begin
  ResetCampiFiltroCassetto;
  qrProdCassetto.Active := False;
  LoadCassetti;
end;

procedure TfrmAssociaProdottiCassetti.lbCassettiClick(Sender: TObject);
begin
  lblCassettoSel.Caption := lbCassetti.Items[lbCassetti.itemIndex];
  LoadProdottiCassetto;
  btnElimina.Enabled := False;
  gbQtaMaxProd.Visible := False;
  lblProdSel.Caption := EMPTYSTR;
  lblProdCassSel.Caption := EMPTYSTR;
end;

procedure TfrmAssociaProdottiCassetti.dgProdottiCellClick(Column: TColumn);
begin
  if (not qrProdotti.IsEmpty) and (lblCassettoSel.Caption <> EMPTYSTR) then
  begin
    lblProdSel.Caption := qrProdotti.FieldByName('Nome').AsString;
    btnElimina.Enabled := False;
    edtQtaMax.Text := EMPTYSTR;
    lblProdCassSel.Caption := EMPTYSTR;
    gbQtaMaxProd.Visible := True;
  end;
end;

procedure TfrmAssociaProdottiCassetti.dgProdCassettoCellClick(
  Column: TColumn);
begin
  if not qrProdCassetto.IsEmpty then
  begin
    lblProdCassSel.Caption := qrProdCassetto.FieldByName('Nome').AsString;
    btnElimina.Enabled := True;
    gbQtaMaxProd.Visible := False;
    lblProdSel.Caption := EMPTYSTR;
  end;
end;

procedure TfrmAssociaProdottiCassetti.cbTipologieChange(Sender: TObject);
begin
  LoadProdotti;
end;

procedure TfrmAssociaProdottiCassetti.edtFiltroProdKeyUp(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  LoadProdotti;
end;

procedure TfrmAssociaProdottiCassetti.btnEliminaClick(Sender: TObject);
var res: Integer;
begin
  res := MessageDlg(MSG_ELIMINA_PRODOTTO, mtWarning, [mbYes, mbNo], 0);
  if res = mrYes then
  begin
    EliminaProdotto;
    LoadProdotti;
    LoadProdottiCassetto;
  end;
  btnElimina.Enabled := False;
  lblProdCassSel.Caption := EMPTYSTR;
end;

procedure TfrmAssociaProdottiCassetti.btnInserisciClick(Sender: TObject);
var
  qtaIns, qtaMax: Integer;
  codProd: string;
begin
  codProd := qrProdotti.FieldByName('Codice').AsString;
  if EsisteProdotto(codProd, lblCassettoSel.Caption) then
  begin
    ShowMessage(MSG_PRODOTTO_ESISTENTE);
    gbQtaMaxProd.Visible := False;
    lblProdSel.Caption := EMPTYSTR;
  end
  else
  begin
    if Trim(edtQtaMax.Text) = EMPTYSTR then ShowMessage(MSG_INSERIRE_DATI)
    else
    begin
      qtaIns := StrToIntDef(edtQtaMax.Text, 0);
      qtaMax := qrProdotti.FieldByName('QtaTotale').AsInteger;

      if qtaIns <= qtaMax then
      begin
        InserisciProdotto;
        LoadProdotti;
        LoadProdottiCassetto;
        lblProdSel.Caption := EMPTYSTR;
      end
      else ShowMessage(MSG_QTAMAX_SUPERATA);
    end;
  end;
end;

procedure TfrmAssociaProdottiCassetti.btnChiudiClick(Sender: TObject);
begin
  Close;
end;

{ **************************************************************************** }
{ *** Reset ****************************************************************** }

procedure TfrmAssociaProdottiCassetti.ResetCampi;
begin
  cbMobili.Clear;
  lblCassettoSel.Caption := EMPTYSTR;
  lblProdSel.Caption := EMPTYSTR;
  lblProdCassSel.Caption := EMPTYSTR;
  btnElimina.Enabled := False;
  edtQtaMax.Text := EMPTYSTR;
  gbQtaMaxProd.Visible := False;
  edtFiltroProd.Text := EMPTYSTR;
  lbCassetti.ItemIndex := -1;
end;

procedure TfrmAssociaProdottiCassetti.ResetCampiFiltroCassetto;
begin
  lblCassettoSel.Caption := EMPTYSTR;
  lblProdSel.Caption := EMPTYSTR;
  lblProdCassSel.Caption := EMPTYSTR;  
  btnElimina.Enabled := False;
  edtQtaMax.Text := EMPTYSTR;
  gbQtaMaxProd.Visible := False;
  edtFiltroProd.Text := EMPTYSTR;
  lbCassetti.ItemIndex := -1;
end;

{ **************************************************************************** }
{ *** Load ******************************************************************* }

procedure TfrmAssociaProdottiCassetti.LoadTipologie;
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

procedure TfrmAssociaProdottiCassetti.LoadCassetti;
var sel: string;
begin
  sel := hsMobili.GetKey(cbMobili.ItemIndex);
  lbCassetti.Clear;
  qrQuery.SQL.Text := 'SELECT * FROM [Cassetti] WHERE [CodMobile] = ' + QuotedStr(sel) + ' ORDER BY [Codice]';
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

procedure TfrmAssociaProdottiCassetti.LoadMobili;
var sel: string;
begin
  sel := hsStudi.GetKey(cbStudi.ItemIndex);
  hsMobili := THashTable.Create;
  cbMobili.Clear;
  qrQuery.SQL.Text := 'SELECT * FROM [Mobili] WHERE [CodStudio] = ' + QuotedStr(sel) + ' ORDER BY [Nome]';
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

procedure TfrmAssociaProdottiCassetti.LoadStudi;
begin
  hsStudi := THashTable.Create;
  cbStudi.Clear;
  cbStudi.Items.Add(' ');
  hsStudi.Add(' ', ' ');
  qrQuery.SQL.Text := 'SELECT * FROM [Studi] ORDER BY [Nome]';
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

procedure TfrmAssociaProdottiCassetti.LoadTuttiCassetti;
begin
  lbCassetti.Clear;
  qrQuery.SQL.Text := 'SELECT * FROM [Cassetti] ORDER BY [Codice]';
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

procedure TfrmAssociaProdottiCassetti.LoadProdottiCassetto;
var sel: string;
begin
  sel := lbCassetti.Items[lbCassetti.itemIndex];
  qrProdCassetto.Active := False;
  qrProdCassetto.SQL.Text := 'SELECT [Prodotti_Cassetti].*, [Prodotti].[Nome], [Prodotti].[Tipologia] ' +
                             'FROM [Prodotti] INNER JOIN [Prodotti_Cassetti] ' +
                             'ON [Prodotti].[Codice] = [Prodotti_Cassetti].[CodProdotto] ' +
                             'WHERE [Prodotti_Cassetti].[CodCassetto] = ' + QuotedStr(sel) + ' ' +
                             'ORDER BY [Prodotti].[Nome]';
  qrProdCassetto.Active := True;
end;

procedure TfrmAssociaProdottiCassetti.LoadProdotti;
begin
  qrProdotti.Active := False;
  qrProdotti.SQL.Text := 'SELECT [Codice], [Tipologia], [Nome], [QtaTotale] ' +
                         'FROM [Prodotti] ' +
                         'WHERE (1 = 1)';

  if cbTipologie.ItemIndex > 0 then
    qrProdotti.SQL.Text := qrProdotti.SQL.Text + ' AND ([Tipologia] = ' + QuotedStr(cbTipologie.Items[cbTipologie.ItemIndex]) + ')';

  if edtFiltroProd.Text <> EMPTYSTR then
    qrProdotti.SQL.Text := qrProdotti.SQL.Text + ' AND ([Nome] LIKE ' + QuotedStr('%' + edtFiltroProd.Text + '%') + ')';

  qrProdotti.SQL.Text := qrProdotti.SQL.Text + ' ORDER BY [Nome]';
  qrProdotti.Active := True;
  lblProdSel.Caption := EMPTYSTR;
  btnElimina.Enabled := False;
  edtQtaMax.Text := EMPTYSTR;
  gbQtaMaxProd.Visible := False;
end;

{ **************************************************************************** }
{ *** Gestione *************************************************************** }

function TfrmAssociaProdottiCassetti.EsisteProdotto(CodProd, CodCassetto: string): Boolean;
var ris: Boolean;
begin
  ris := True;
  qrQuery.SQL.Text := 'SELECT [CodCassetto] ' +
                      'FROM [Prodotti_Cassetti] ' +
                      'WHERE [CodCassetto] = ' + QuotedStr(CodCassetto) + ' AND ' +
                            '[CodProdotto] = ' + codProd;
  qrQuery.Active := True;
  if qrQuery.IsEmpty then ris := False;
  qrQuery.Active := False;
  EsisteProdotto := ris;
end;

procedure TfrmAssociaProdottiCassetti.EliminaProdotto;
var
  codProd: string;
  qtaTotCass: integer;
  qtaUsata: integer;
begin
  try
    codProd := qrProdCassetto.FieldByName('CodProdotto').AsString;
    qtaTotCass := qrProdCassetto.FieldByName('QtaTotale').AsInteger;
    qtaUsata := qrProdCassetto.FieldByName('QtaUsata').AsInteger;

    qrQuery.SQL.Text := 'UPDATE [Prodotti] ' +
                          'SET [QtaTotale] = [QtaTotale] +  ' + IntToStr(qtaTotCass-qtaUsata)  + ' ' +
                          'WHERE [Codice] = ' + codProd;
    qrQuery.ExecSQL;

    qrQuery.SQL.Text := 'DELETE FROM [Prodotti_Cassetti] ' +
                          'WHERE [CodCassetto] = ' + QuotedStr(lbCassetti.Items[lbCassetti.ItemIndex]) + ' AND ' +
                                '[CodProdotto] = ' + codProd;
    qrQuery.ExecSQL;
  except
    ShowMessage(MSG_ERRORE_SCRITTURA_DB);
  end;
end;

procedure TfrmAssociaProdottiCassetti.InserisciProdotto;
var CodProd: string;
begin
  try
    CodProd := qrProdotti.FieldByName('Codice').AsString;
    qrQuery.SQL.Text := 'INSERT INTO [Prodotti_Cassetti] ([CodCassetto], [CodProdotto], [QtaTotale], [QtaUsata]) ' +
                        'VALUES (' + QuotedStr(lbCassetti.Items[lbCassetti.ItemIndex]) + ', ' + codProd + ', ' + edtQtaMax.Text +', 0)';
    qrQuery.ExecSQL;

    qrQuery.SQL.Text := 'UPDATE [Prodotti] ' +
                        'SET [QtaTotale] = [QtaTotale] - ' + edtQtaMax.Text + ' ' +
                        'WHERE [Codice] = ' + CodProd;
    qrQuery.ExecSQL;
  except
    ShowMessage(MSG_ERRORE_SCRITTURA_DB);
  end;
end;

end.
