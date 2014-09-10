unit UAssociaProdottiFornitori;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Grids, DBGrids, TextEdit, DB, ADODB,
  NumberEdit, TextLabeledEdit;

type
  TfrmAssociaProdottiFornitori = class(TForm)
    gbProdottiCassetto: TGroupBox;
    gbProdotti: TGroupBox;
    btnChiudi: TButton;
    gbCassetti: TGroupBox;
    lblInfo4: TLabel;
    lblCassettoSel: TLabel;
    lbCassetti: TListBox;
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
    gbFiltro2: TGroupBox;
    Label1: TLabel;
    cbTipologie: TComboBox;
    edtFiltroProd: TTextLabeledEdit;
    Bevel2: TBevel;
    img1: TImage;
    Label2: TLabel;
    lblProdCassSel: TLabel;
    edtQtaMax: TTextEdit;
    procedure FormShow(Sender: TObject);
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
    procedure LoadFornitori;
    procedure ResetCampi;
    procedure ResetCampiFiltroCassetto;    
    procedure LoadProdottiFornitore;
    procedure LoadProdotti;
    procedure InserisciProdotto;
    procedure EliminaProdotto;
    function EsisteProdotto(Fornitore, Nome: string): Boolean;
  end;

var
  frmAssociaProdottiFornitori: TfrmAssociaProdottiFornitori;

implementation

uses UHashTable, dmConnection, UMessaggi;

{$R *.dfm}

var
  hsStudi: THashTable;
  hsMobili: THashTable;

{ **************************************************************************** }
{ *** Finestra *************************************************************** }

procedure TfrmAssociaProdottiFornitori.FormShow(Sender: TObject);
begin
  ResetCampi;
  LoadFornitori;
  LoadProdotti;
  LoadTipologie;
end;

procedure TfrmAssociaProdottiFornitori.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  qrProdCassetto.Active := False;
  qrProdotti.Active := False;
end;

{ **************************************************************************** }
{ *** Componenti ************************************************************* }

procedure TfrmAssociaProdottiFornitori.lbCassettiClick(Sender: TObject);
begin
  lblCassettoSel.Caption := lbCassetti.Items[lbCassetti.itemIndex];
  LoadProdottiFornitore;
  btnElimina.Enabled := False;
  gbQtaMaxProd.Visible := False;
  lblProdSel.Caption := EMPTYSTR;
  lblProdCassSel.Caption := EMPTYSTR;
end;

procedure TfrmAssociaProdottiFornitori.dgProdottiCellClick(Column: TColumn);
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

procedure TfrmAssociaProdottiFornitori.dgProdCassettoCellClick(
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

procedure TfrmAssociaProdottiFornitori.cbTipologieChange(Sender: TObject);
begin
  LoadProdotti;
end;

procedure TfrmAssociaProdottiFornitori.edtFiltroProdKeyUp(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  LoadProdotti;
end;

procedure TfrmAssociaProdottiFornitori.btnEliminaClick(Sender: TObject);
var res: Integer;
begin
  res := MessageDlg(MSG_ELIMINA_PRODOTTO, mtWarning, [mbYes, mbNo], 0);
  if res = mrYes then
  begin
    EliminaProdotto;
    LoadProdotti;
    LoadProdottiFornitore;
  end;
  btnElimina.Enabled := False;
  lblProdCassSel.Caption := EMPTYSTR;
end;

procedure TfrmAssociaProdottiFornitori.btnInserisciClick(Sender: TObject);
var
  nome, codAcquisto: string;
begin
  nome := qrProdotti.FieldByName('Nome').AsString;
  //if EsisteProdotto(nome, lblCassettoSel.Caption) then
  //begin
   // ShowMessage(MSG_PRODOTTO_ESISTENTE);
   // gbQtaMaxProd.Visible := False;
  //  lblProdSel.Caption := EMPTYSTR;
  //end
  //else
  begin
    if Trim(edtQtaMax.Text) = EMPTYSTR then ShowMessage(MSG_INSERIRE_DATI)
    else
    begin
      codAcquisto := edtQtaMax.Text;
      InserisciProdotto;
      LoadProdotti;
      LoadProdottiFornitore;
      lblProdSel.Caption := EMPTYSTR;
    end;
  end;
end;

procedure TfrmAssociaProdottiFornitori.btnChiudiClick(Sender: TObject);
begin
  Close;
end;

{ **************************************************************************** }
{ *** Reset ****************************************************************** }

procedure TfrmAssociaProdottiFornitori.ResetCampi;
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

procedure TfrmAssociaProdottiFornitori.ResetCampiFiltroCassetto;
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

procedure TfrmAssociaProdottiFornitori.LoadTipologie;
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

procedure TfrmAssociaProdottiFornitori.LoadFornitori;
begin
  lbCassetti.Clear;
  qrQuery.SQL.Text := 'SELECT [Fornitore] FROM [Fornitori] ORDER BY [Fornitore]';
  qrQuery.Active := True;
  qrQuery.First;
  while not qrQuery.Eof do
  begin
    lbCassetti.Items.Add(qrQuery.FieldByName('Fornitore').AsString);
    qrQuery.Next;
  end;
  qrQuery.Active := False;
  lbCassetti.ItemIndex := -1;
end;

procedure TfrmAssociaProdottiFornitori.LoadProdottiFornitore;
var sel: string;
begin
  sel := lbCassetti.Items[lbCassetti.itemIndex];
  qrProdCassetto.Active := False;
  qrProdCassetto.SQL.Text := 'SELECT [Fornitori_Prodotti].*, [Prodotti].[Nome], [Prodotti].[Tipologia], [Fornitori].[Fornitore] ' +
                             'FROM ([Fornitori_Prodotti] ' +
                             'INNER JOIN [Prodotti] ON [Fornitori_Prodotti].[IdProdotto] = [Prodotti].[Codice]) ' +
                             'INNER JOIN [Fornitori] ON [Fornitori_Prodotti].[Fornitore] = [Fornitori].[Fornitore] ' +
                             'WHERE [Fornitori_Prodotti].[Fornitore] = ' + QuotedStr(sel) + ' ' +
                             'ORDER BY [Prodotti].[Nome]';
  qrProdCassetto.Active := True;
end;

procedure TfrmAssociaProdottiFornitori.LoadProdotti;
begin
  qrProdotti.Active := False;
  qrProdotti.SQL.Text := 'SELECT [Codice], [Tipologia], [Nome], [QtaTotale] ' +
                         'FROM [Prodotti] ' +
                         'WHERE (1 = 1)';

  if cbTipologie.ItemIndex > 0 then
    qrProdotti.SQL.Text := qrProdotti.SQL.Text +
                           ' AND ([Tipologia] = ' + QuotedStr(cbTipologie.Items[cbTipologie.ItemIndex]) + ')';

  if edtFiltroProd.Text <> EMPTYSTR then
    qrProdotti.SQL.Text := qrProdotti.SQL.Text +
                           ' [Nome] LIKE ' + QuotedStr('%' + edtFiltroProd.Text + '%') + ')';

  qrProdotti.SQL.Text := qrProdotti.SQL.Text + ' ORDER BY [Nome]';
  qrProdotti.Active := True;
  lblProdSel.Caption := EMPTYSTR;
  btnElimina.Enabled := False;
  edtQtaMax.Text := EMPTYSTR;
  gbQtaMaxProd.Visible := False;
end;

{ **************************************************************************** }
{ *** Gestione *************************************************************** }

function TfrmAssociaProdottiFornitori.EsisteProdotto(Fornitore, Nome: string): Boolean;
var ris: Boolean;
begin
  ris := True;
  qrQuery.SQL.Text := 'SELECT [Prodotti].[Nome] ' +
                      'FROM [Prodotti] INNER JOIN [Fornitori_Prodotti] ON [Prodotti].[Codice] = [Fornitori_Prodotti].[IdProdotto]' +
                      'WHERE [Prodotti].[Nome] = ' + QuotedStr(Nome) + ' AND ' +
                            '[Fornitori_Prodotti].[Fornitore] = ' + Fornitore;
  qrQuery.Active := True;
  if qrQuery.IsEmpty then ris := False;
  qrQuery.Active := False;
  EsisteProdotto := ris;
end;

procedure TfrmAssociaProdottiFornitori.EliminaProdotto;
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

procedure TfrmAssociaProdottiFornitori.InserisciProdotto;
var CodProd: string;
begin
  try
    CodProd := qrProdotti.FieldByName('Codice').AsString;
    qrQuery.SQL.Text := 'INSERT INTO [Fornitori_Prodotti] ([CodiceAcquisto], [Fornitore], [IdProdotto]) ' +
                        'VALUES (' + edtQtaMax.Text +', ' + QuotedStr(lbCassetti.Items[lbCassetti.ItemIndex]) + ', ' + codProd + ')';
    qrQuery.ExecSQL;
  except
    ShowMessage(MSG_ERRORE_SCRITTURA_DB);
  end;
end;

end.
