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
    gbQtaMaxProdEdit: TGroupBox;
    Bevel1: TBevel;
    btnEdit: TButton;
    edtQtaMaxEdit: TTextEdit;
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
    procedure btnEditClick(Sender: TObject);
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
    procedure ModificaProdotto;
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
  gbQtaMaxProdEdit.Visible := False;
  lblProdSel.Caption := EMPTYSTR;
  lblProdCassSel.Caption := EMPTYSTR;
end;

procedure TfrmAssociaProdottiFornitori.dgProdottiCellClick(Column: TColumn);
var
Cod : string;
begin
  if (not qrProdotti.IsEmpty) and (lblCassettoSel.Caption <> EMPTYSTR) then
  begin
    lblProdSel.Caption := qrProdotti.FieldByName('Nome').AsString;
    qrQuery.SQL.Text := 'SELECT [Fornitori_Prodotti].[CodiceAcquisto] ' +
                      ' FROM [Fornitori_Prodotti] INNER JOIN [Prodotti] ON [Prodotti].[Codice] = [Fornitori_Prodotti].[IdProdotto] ' +
                      'WHERE [Prodotti].[Nome] = ' + QuotedStr(lblProdSel.Caption) + ' AND ' +
                      '[Fornitori_Prodotti].[Fornitore] = ' + QuotedStr(lblCassettoSel.Caption) + ';';
    qrQuery.Open;

    Cod := qrQuery.Fields[0].AsString;
    if EsisteProdotto(lblCassettoSel.Caption, lblProdSel.Caption) then
    begin
      btnElimina.Enabled := False;
      edtQtaMaxEdit.Text := Cod;
      lblProdCassSel.Caption := EMPTYSTR;
      gbQtaMaxProdEdit.Visible := True;
      gbQtaMaxProd.Visible := False;
    end
    else
    begin
      btnElimina.Enabled := False;
      edtQtaMax.Text := EMPTYSTR;
      lblProdCassSel.Caption := EMPTYSTR;
      gbQtaMaxProd.Visible := True;
      gbQtaMaxProdEdit.Visible := False;
    end
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
    gbQtaMaxProdEdit.Visible := False;
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


procedure TfrmAssociaProdottiFornitori.btnEditClick(Sender: TObject);
var
  nome, codAcquisto: string;
begin
  nome := qrProdotti.FieldByName('Nome').AsString;
  begin
    if Trim(edtQtaMaxEdit.Text) = EMPTYSTR then ShowMessage(MSG_INSERIRE_DATI)
    else
    begin
      codAcquisto := edtQtaMaxEdit.Text;
      ModificaProdotto;
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

function TfrmAssociaProdottiFornitori.EsisteProdotto(Fornitore, Nome:string): Boolean;
var ris: Boolean;
begin
  ris := True;
  qrQuery.SQL.Text := 'SELECT [Prodotti].[Nome] ' +
                      ' FROM [Prodotti] INNER JOIN [Fornitori_Prodotti] ON [Prodotti].[Codice] = [Fornitori_Prodotti].[IdProdotto] ' +
                      ' WHERE [Prodotti].[Nome] = ' + QuotedStr(Nome) + ' AND ' +
                            '[Fornitori_Prodotti].[Fornitore] = ' + QuotedStr(Fornitore) + ';';

  //ShowMessage(qrQuery.SQL.Text);
  qrQuery.Active := True;

  if qrQuery.IsEmpty then ris := False;
  qrQuery.Active := False;
  EsisteProdotto := ris;
end;

procedure TfrmAssociaProdottiFornitori.EliminaProdotto;
var
  Cod: Integer;

begin
  try

    qrQuery.SQL.Text := 'SELECT [Prodotti].[Codice] ' +
                      ' FROM [Prodotti] INNER JOIN [Fornitori_Prodotti] ON [Prodotti].[Codice] = [Fornitori_Prodotti].[IdProdotto] ' +
                      ' WHERE [Prodotti].[Nome] = ' + QuotedStr(lblProdCassSel.Caption);
    qrQuery.Open;

    Cod := qrQuery.Fields[0].AsInteger;

    qrQuery.SQL.Text := 'DELETE FROM [Fornitori_Prodotti] ' +
                          ' WHERE [IdProdotto] = ' + IntToStr(Cod) + ' AND ' +
                                '[Fornitore] = ' + QuotedStr(lblCassettoSel.Caption) + ';';
    //ShowMessage(qrQuery.SQL.Text);
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
                        'VALUES (' + QuotedStr(edtQtaMax.Text) +', ' + QuotedStr(lbCassetti.Items[lbCassetti.ItemIndex]) + ', ' + CodProd + ')';
    qrQuery.ExecSQL;
  except
    ShowMessage(MSG_ERRORE_SCRITTURA_DB);
  end;
end;

procedure TfrmAssociaProdottiFornitori.ModificaProdotto;
var CodProd: string;
begin
  try
    CodProd := qrProdotti.FieldByName('Codice').AsString;
    qrQuery.SQL.Text := 'UPDATE [Fornitori_Prodotti] SET [CodiceAcquisto]=' + QuotedStr(edtQtaMaxEdit.Text) +
                        'WHERE ([Fornitori_Prodotti].[Fornitore] = ' + QuotedStr(lblCassettoSel.Caption) + ' AND [Fornitori_Prodotti].[IdProdotto] = ' + CodProd + ');';
    qrQuery.ExecSQL;
  except
    ShowMessage(MSG_ERRORE_SCRITTURA_DB);
  end;
end;

end.
