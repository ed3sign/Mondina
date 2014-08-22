unit UVisProdottiCassetti;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, DBGrids, StdCtrls, ExtCtrls, TextLabeledEdit, DB, ADODB;

type
  TfrmVisProdottiCassetti = class(TForm)
    qrProdotti: TADOQuery;
    dsProdotti: TDataSource;
    qrQuery: TADOQuery;
    gbFiltro: TGroupBox;
    lblInfo1: TLabel;
    cbTipologie: TComboBox;
    edtFiltroProd: TTextLabeledEdit;
    gbInfo: TGroupBox;
    lblInfo3: TLabel;
    lblProdSel: TLabel;
    dgProdotti: TDBGrid;
    btnChiudi: TButton;
    img1: TImage;
    gbCassetti: TGroupBox;
    Label1: TLabel;
    lbCassetti: TListBox;
    GroupBox1: TGroupBox;
    lblInfo2: TLabel;
    Label2: TLabel;
    cbStudi: TComboBox;
    cbMobili: TComboBox;
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure cbTipologieChange(Sender: TObject);
    procedure btnChiudiClick(Sender: TObject);
    procedure dgProdottiCellClick(Column: TColumn);
    procedure edtFiltroProdKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure cbStudiChange(Sender: TObject);
    procedure cbMobiliChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure ResetCampi;
    procedure LoadProdotti;
    procedure LoadTipologie;
    procedure ResetCampiLoadProdotti;
    procedure LoadCassetti(CodProd: string);
    procedure LoadMobili(CodProd: string);
    procedure LoadStudi(CodProd: string);
  end;

var
  frmVisProdottiCassetti: TfrmVisProdottiCassetti;

implementation

uses dmConnection, UHashTable;

{$R *.dfm}

{ TfrmVisProdottiCassetti }

var
  hsStudi: THashTable;
  hsMobili: THashTable;
  
{ **************************************************************************** }
{ *** Finestra *************************************************************** }

procedure TfrmVisProdottiCassetti.FormShow(Sender: TObject);
begin
  ResetCampi;
  LoadTipologie;
  LoadProdotti;
  cbTipologie.SetFocus;
end;

procedure TfrmVisProdottiCassetti.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  qrProdotti.Active := False;
end;

{ **************************************************************************** }
{ *** Componenti ************************************************************* }

procedure TfrmVisProdottiCassetti.cbTipologieChange(Sender: TObject);
begin
  LoadProdotti;
  ResetCampiLoadProdotti;
end;

procedure TfrmVisProdottiCassetti.btnChiudiClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmVisProdottiCassetti.dgProdottiCellClick(Column: TColumn);
var CodProd: string;
begin
  if not qrProdotti.IsEmpty then
  begin
    CodProd := qrProdotti.FieldByName('Codice').AsString;
    lblProdSel.Caption := qrProdotti.FieldByName('Nome').AsString;
    LoadStudi(CodProd);
    cbMobili.Clear;
    lbCassetti.Clear;
  end;
end;

procedure TfrmVisProdottiCassetti.edtFiltroProdKeyUp(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  LoadProdotti;
  ResetCampiLoadProdotti;
end;

procedure TfrmVisProdottiCassetti.cbStudiChange(Sender: TObject);
var CodProd: string;
begin
  CodProd := qrProdotti.FieldByName('Codice').AsString;
  if cbStudi.ItemIndex <> -1 then
  begin
    LoadMobili(CodProd);
    lbCassetti.Clear;
  end;
end;

procedure TfrmVisProdottiCassetti.cbMobiliChange(Sender: TObject);
var CodProd: string;
begin
  CodProd := qrProdotti.FieldByName('Codice').AsString;
  if cbMobili.ItemIndex <> -1 then LoadCassetti(CodProd);
end;

{ **************************************************************************** }
{ *** Reset ****************************************************************** }

procedure TfrmVisProdottiCassetti.ResetCampi;
begin
  cbStudi.Clear;
  cbMobili.Clear;
  lbCassetti.Clear;
  edtFiltroProd.Text := EMPTYSTR;
  lblProdSel.Caption := EMPTYSTR;
end;

procedure TfrmVisProdottiCassetti.ResetCampiLoadProdotti;
begin
  cbStudi.Clear;
  cbMobili.Clear;
  lbCassetti.Clear;
  lblProdSel.Caption := EMPTYSTR;
end;

{ **************************************************************************** }
{ *** Load ******************************************************************* }

procedure TfrmVisProdottiCassetti.LoadProdotti;
begin
  qrProdotti.Active := False;
  qrProdotti.SQL.Text := 'SELECT [Prodotti].[Codice], [Prodotti].[CodiceAcquisto], ' +
                                '[Prodotti].[Nome], [Prodotti].[Tipologia], ' +
                                'SUM([Prodotti_Cassetti].[QtaTotale]) AS [SommaQtaTotale] ' +
                         'FROM [Prodotti] LEFT OUTER JOIN [Prodotti_Cassetti] ' +
                         'ON [Prodotti].[Codice] = [Prodotti_Cassetti].[CodProdotto] ' +
                         'WHERE (1 = 1)';

  if cbTipologie.ItemIndex > 0 then
    qrProdotti.SQL.Text := qrProdotti.SQL.Text +
                           ' AND ([Prodotti].[Tipologia] = ' + QuotedStr(cbTipologie.Items[cbTipologie.ItemIndex]) + ')';

  if edtFiltroProd.Text <> EMPTYSTR then
    qrProdotti.SQL.Text := qrProdotti.SQL.Text +
                           ' AND ([Prodotti].[CodiceAcquisto] LIKE ' + QuotedStr('%' + edtFiltroProd.Text + '%') + ' OR ' +
                           '[Prodotti].[Nome] LIKE ' + QuotedStr('%' + edtFiltroProd.Text + '%') + ')';

  qrProdotti.SQL.Text := qrProdotti.SQL.Text + ' GROUP BY [Prodotti].[Codice], [Prodotti].[CodiceAcquisto], ' +
                                                         '[Prodotti].[Nome], [Prodotti].[Tipologia] ';
  qrProdotti.SQL.Text := qrProdotti.SQL.Text + 'ORDER BY [Prodotti].[Nome]';
  qrProdotti.Active := True;
end;

procedure TfrmVisProdottiCassetti.LoadTipologie;
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

procedure TfrmVisProdottiCassetti.LoadMobili(CodProd: string);
var sel: string;
begin
  sel := hsStudi.GetKey(cbStudi.ItemIndex);
  hsMobili := THashTable.Create;
  cbMobili.Clear;
  qrQuery.SQL.Text := 'SELECT DISTINCT [Mobili].* ' +
                      'FROM [Mobili] INNER JOIN ([Cassetti] INNER JOIN [Prodotti_Cassetti] ' +
                      'ON [Cassetti].[Codice] = [Prodotti_Cassetti].[CodCassetto]) ' +
                      'ON [Mobili].[Codice] = [Cassetti].[CodMobile] ' +
                      'WHERE [Mobili].[CodStudio] = ' + QuotedStr(sel) + ' AND ' +
                            '[Prodotti_Cassetti].[CodProdotto] = ' + CodProd + ' ' +
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

procedure TfrmVisProdottiCassetti.LoadStudi(CodProd: string);
begin
  hsStudi := THashTable.Create;
  cbStudi.Clear;
  qrQuery.SQL.Text := 'SELECT DISTINCT [Studi].* ' +
                      'FROM [Studi] INNER JOIN ([Mobili] INNER JOIN ([Cassetti] INNER JOIN [Prodotti_Cassetti] ' +
                      'ON [Cassetti].[Codice] = [Prodotti_Cassetti].[CodCassetto]) ' +
                      'ON [Mobili].[Codice] = [Cassetti].[CodMobile]) ON [Studi].[Codice] = [Mobili].[CodStudio] ' +
                      'WHERE [Prodotti_Cassetti].[CodProdotto] = ' + CodProd + ' ' +
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
  cbStudi.ItemIndex := -1;
end;

procedure TfrmVisProdottiCassetti.LoadCassetti(CodProd: string);
var sel: string;
begin
  sel := hsMobili.GetKey(cbMobili.ItemIndex);
  lbCassetti.Clear;
  qrQuery.SQL.Text := 'SELECT [Cassetti].[Codice], [Cassetti].[Codice] + '' - ('' + Format([Prodotti_Cassetti].[QtaTotale], ''0'') + '')'' AS [NumCassetto] ' +
                      'FROM [Cassetti] INNER JOIN [Prodotti_Cassetti] ' +
                      'ON [Cassetti].[Codice] = [Prodotti_Cassetti].[CodCassetto] ' +
                      'WHERE [Cassetti].[CodMobile] = ' + QuotedStr(sel) + ' AND ' +
                            '[Prodotti_Cassetti].[CodProdotto] = ' + CodProd + ' ' +
                      'ORDER BY [Cassetti].[Codice]';

  qrQuery.Active := True;
  qrQuery.First;
  while not qrQuery.Eof do
  begin
    lbCassetti.Items.Add(qrQuery.FieldByName('NumCassetto').AsString);
    qrQuery.Next;
  end;
  qrQuery.Active := False;
  lbCassetti.ItemIndex := -1;
end;

end.
