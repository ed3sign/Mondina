unit UCreaOrdine;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, NumberLabeledEdit, StdCtrls, ExtCtrls, TextLabeledEdit, DB,
  ADODB;

type
  TfrmCreaOrdine = class(TForm)
    img1: TImage;
    btnAnnulla: TButton;
    btnOK: TButton;
    gbInfo: TGroupBox;
    lblInfo1: TLabel;
    lblInfo2: TLabel;
    edtCodice: TTextLabeledEdit;
    edtNome: TTextLabeledEdit;
    cbTipologia: TComboBox;
    edtNumProdPerConf: TNumberLabeledEdit;
    cbFornitori: TComboBox;
    edtSconto: TNumberLabeledEdit;
    edtNumConfPerScatola: TNumberLabeledEdit;
    edtIVA: TNumberLabeledEdit;
    edtCostoConf: TNumberLabeledEdit;
    qrQuery: TADOQuery;
    tblProdotti: TADOTable;
    edtQtaOrd: TNumberLabeledEdit;
    procedure FormShow(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure btnAnnullaClick(Sender: TObject);
    procedure cbFornitoriChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure ResetCampi;
    procedure LoadTipologie;
    procedure LoadFornitori;
    procedure AddProdotto;
    function GetAnnoStr: string;
  end;

var
  frmCreaOrdine: TfrmCreaOrdine;

implementation

uses dmConnection, UMessaggi, UVisMagazzino;

{$R *.dfm}

{ TfrmCreaProdotto }

{ **************************************************************************** }
{ *** Finestra *************************************************************** }

procedure TfrmCreaOrdine.FormShow(Sender: TObject);
begin
  LoadTipologie;
  LoadFornitori;
  ResetCampi;
  edtNome.Text :=  frmVisMagazzino.lblProdSel.Caption;
end;

{ **************************************************************************** }
{ *** Componenti ************************************************************* }

procedure TfrmCreaOrdine.cbFornitoriChange(Sender: TObject);
var
Cod: string;
begin
    qrQuery.SQL.Text := 'SELECT [Fornitori_Prodotti].[CodiceAcquisto]' +
                             'FROM ([Fornitori_Prodotti] ' +
                             'INNER JOIN [Prodotti] ON [Fornitori_Prodotti].[IdProdotto] = [Prodotti].[Codice]) ' +
                             'INNER JOIN [Fornitori] ON [Fornitori_Prodotti].[Fornitore] = [Fornitori].[Fornitore] ' +
                             'WHERE [Fornitori_Prodotti].[Fornitore] = ' + QuotedStr(cbFornitori.Items[cbFornitori.ItemIndex]) + ' AND [Prodotti].[Nome] = ' + QuotedStr(edtNome.Text);
    qrQuery.Open;

    Cod := qrQuery.Fields[0].AsString;
    edtCodice.Text := Cod
end;

procedure TfrmCreaOrdine.btnOKClick(Sender: TObject);
begin
  if (Trim(edtCodice.Text) = EMPTYSTR) or (Trim(edtNome.Text) = EMPTYSTR) or
     (cbTipologia.ItemIndex = -1) or (cbFornitori.ItemIndex = -1) or
     (Trim(edtNumConfPerScatola.Text) = EMPTYSTR) or (Trim(edtNumProdPerConf.Text) = EMPTYSTR) or
     (Trim(edtCostoConf.Text) = EMPTYSTR) or (Trim(edtSconto.Text) = EMPTYSTR) or
     (Trim(edtIVA.Text) = EMPTYSTR) or (Trim(edtQtaOrd.Text) = EMPTYSTR) then
    ShowMessage(MSG_INSERIRE_DATI)
  else
  begin
    AddProdotto;
    ResetCampi;
    Close;
  end;
end;

procedure TfrmCreaOrdine.btnAnnullaClick(Sender: TObject);
begin
  Close;
end;

{ **************************************************************************** }
{ *** Reset ****************************************************************** }

procedure TfrmCreaOrdine.ResetCampi;
begin
  edtCodice.Text := EMPTYSTR;
  edtNome.Text := EMPTYSTR;
  edtNumConfPerScatola.Text := '0';
  edtNumProdPerConf.Text := '1';
  edtCostoConf.Text := '0';
  edtSconto.Text := '0';
  edtIVA.Text := '0';
  edtQtaOrd.Text := '0';
  cbFornitori.SetFocus;
end;

{ **************************************************************************** }
{ *** Load ******************************************************************* }

procedure TfrmCreaOrdine.LoadFornitori;
begin
  cbFornitori.Clear;
  qrQuery.SQL.Text := 'SELECT [Fornitore] FROM [Fornitori] ORDER BY [Fornitore]';
  qrQuery.Active := True;
  qrQuery.First;
  while not qrQuery.Eof do
  begin
    cbFornitori.Items.Add(qrQuery.FieldByName('Fornitore').AsString);
    qrQuery.Next;
  end;
  qrQuery.Active := False;
  cbFornitori.ItemIndex := -1;
end;

procedure TfrmCreaOrdine.LoadTipologie;
begin
  cbTipologia.Clear;
  qrQuery.SQL.Text := 'SELECT [Tipologia] FROM [Tipologie_Prodotti] ORDER BY [Tipologia]';
  qrQuery.Active := True;
  qrQuery.First;
  while not qrQuery.Eof do
  begin
    cbTipologia.Items.Add(qrQuery.FieldByName('Tipologia').AsString);
    qrQuery.Next;
  end;
  qrQuery.Active := False;
  cbTipologia.ItemIndex := -1;
end;


{ **************************************************************************** }
{ *** Gestione *************************************************************** }

function TfrmCreaOrdine.GetAnnoStr: string;
var
  myYear, myMonth, myDay : Word;
begin
  DecodeDate(Date, myYear, myMonth, myDay);
  GetAnnoStr := IntToStr(myYear);
end;

procedure TfrmCreaOrdine.AddProdotto;
var
  NumProdPerConf, QtaOrd: Integer;
  Sconto, IVA, CostoConf, CostoUni: Real;
begin
  try
    QtaOrd := StrToIntDef(edtQtaOrd.Text, 0);
    NumProdPerConf := StrToIntDef(edtNumProdPerConf.Text, 0);
    if NumProdPerConf = 0 then NumProdPerConf := 1;
    CostoConf := StrToFloatDef(edtCostoConf.Text, 0.0);
    Sconto := StrToFloatDef(edtSconto.Text, 0.0);
    IVA := StrToFloatDef(edtIVA.Text, 0.0);
    CostoUni := ((CostoConf-((CostoConf*Sconto) / 100))*(1 + IVA/100)) / NumProdPerConf;

    tblProdotti.Active := True;
    tblProdotti.Insert;
    tblProdotti.FieldByName('CodiceAcquisto').AsString := edtCodice.Text;
    tblProdotti.FieldByName('NomeProdotto').AsString := edtNome.Text;
    tblProdotti.FieldByName('Tipologia').AsString := cbTipologia.Items[cbTipologia.ItemIndex];
    tblProdotti.FieldByName('Fornitore').AsString := cbFornitori.Items[cbFornitori.ItemIndex];
    tblProdotti.FieldByName('NumConfPerScatola').AsInteger := StrToIntDef(edtNumConfPerScatola.Text, 0);
    tblProdotti.FieldByName('NumProdPerConf').AsInteger := NumProdPerConf;
    tblProdotti.FieldByName('CostoConfezione').AsFloat := CostoConf;
    tblProdotti.FieldByName('Sconto').AsFloat := Sconto;
    tblProdotti.FieldByName('IVA').AsFloat := IVA;
    tblProdotti.FieldByName('Anno').AsInteger := StrToInt(GetAnnoStr);
    tblProdotti.FieldByName('CostoUnitario').AsFloat := CostoUni;
    tblProdotti.FieldByName('qtaOrdinata').AsInteger := QtaOrd;
    tblProdotti.Post;
    tblProdotti.Active := False;    
  except
    ShowMessage(MSG_ERRORE_SCRITTURA_DB);
  end;
end;

end.
