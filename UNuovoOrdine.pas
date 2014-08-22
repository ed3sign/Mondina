unit UNuovoOrdine;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, NumberLabeledEdit, StdCtrls, ExtCtrls, TextLabeledEdit, DB,
  ADODB;

type
  TfrmOrdinaProd = class(TForm)
    btnAnnulla: TButton;
    btnOK: TButton;
    btnApplica: TButton;
    qrQuery: TADOQuery;
    tblProdotti: TADOTable;
    img1: TImage;
    gbInfo: TGroupBox;
    lblInfo1: TLabel;
    lblInfo2: TLabel;
    edtCodice: TTextLabeledEdit;
    edtNome: TTextLabeledEdit;
    cbTipologia: TComboBox;
    edtNumProdPerConf: TNumberLabeledEdit;
    edtSoglia: TNumberLabeledEdit;
    cbFornitori: TComboBox;
    edtSconto: TNumberLabeledEdit;
    edtNumConfPerScatola: TNumberLabeledEdit;
    edtIVA: TNumberLabeledEdit;
    edtCostoConf: TNumberLabeledEdit;
    procedure FormShow(Sender: TObject);
    procedure btnApplicaClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure btnAnnullaClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure ResetCampi;
    procedure LoadTipologie;
    procedure LoadFornitori;
    procedure AddProdotto;
  end;

var
  frmOrdinaProd: TfrmOrdinaProd;

implementation

  uses dmConnection, UMessaggi, UVisMagazzino;

{$R *.dfm}

{ TfrmOrdinaProdotto}

{ **************************************************************************** }
{ *** Finestra *************************************************************** }

procedure TfrmOrdinaProd.FormShow(Sender: TObject);
begin
  LoadTipologie;
  LoadFornitori;
  ResetCampi;
end;

{ **************************************************************************** }
{ *** Componenti ************************************************************* }

procedure TfrmOrdinaProd.btnApplicaClick(Sender: TObject);
begin
  if (Trim(edtCodice.Text) = EMPTYSTR) or (Trim(edtNome.Text) = EMPTYSTR) or
     (cbTipologia.ItemIndex = -1) or (cbFornitori.ItemIndex = -1) or
     (Trim(edtNumConfPerScatola.Text) = EMPTYSTR) or (Trim(edtNumProdPerConf.Text) = EMPTYSTR) or
     (Trim(edtCostoConf.Text) = EMPTYSTR) or (Trim(edtSconto.Text) = EMPTYSTR) or
     (Trim(edtIVA.Text) = EMPTYSTR) or (Trim(edtSoglia.Text) = EMPTYSTR) then
     
    ShowMessage(MSG_INSERIRE_DATI)
  else
  begin
    AddProdotto;
    LoadTipologie;
    LoadFornitori;
    ResetCampi;
  end;
end;

procedure TfrmOrdinaProd.btnOKClick(Sender: TObject);
begin
  if (Trim(edtCodice.Text) = EMPTYSTR) or (Trim(edtNome.Text) = EMPTYSTR) or
     (cbTipologia.ItemIndex = -1) or (cbFornitori.ItemIndex = -1) or
     (Trim(edtNumConfPerScatola.Text) = EMPTYSTR) or (Trim(edtNumProdPerConf.Text) = EMPTYSTR) or
     (Trim(edtCostoConf.Text) = EMPTYSTR) or (Trim(edtSconto.Text) = EMPTYSTR) or
     (Trim(edtIVA.Text) = EMPTYSTR) or (Trim(edtSoglia.Text) = EMPTYSTR) then

    ShowMessage(MSG_INSERIRE_DATI)
  else
  begin
    AddProdotto;
    Close;
  end;
end;

procedure TfrmOrdinaProd.btnAnnullaClick(Sender: TObject);
begin
  Close;
end;

{ **************************************************************************** }
{ *** Reset ****************************************************************** }

procedure TfrmOrdinaProd.ResetCampi;
begin
  edtCodice.Text := EMPTYSTR;
  edtNumConfPerScatola.Text := '0';
  edtNumProdPerConf.Text := '1';
  edtCostoConf.Text := '0';
  edtSconto.Text := '0';
  edtIVA.Text := '0';  
  edtSoglia.Text := '0';
  edtCodice.SetFocus;
end;

{ **************************************************************************** }
{ *** Load ******************************************************************* }

procedure TfrmOrdinaProd.LoadTipologie;
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

procedure TfrmOrdinaProd.LoadFornitori;
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

{ **************************************************************************** }
{ *** Gestione *************************************************************** }

procedure TfrmOrdinaProd.AddProdotto;
var
  NumProdPerConf: Integer;
  Sconto, IVA, CostoConf, CostoUni: Real;
begin
  try
    NumProdPerConf := StrToIntDef(edtNumProdPerConf.Text, 0);
    if NumProdPerConf = 0 then NumProdPerConf := 1;
    CostoConf := StrToFloatDef(edtCostoConf.Text, 0.0);
    Sconto := StrToFloatDef(edtSconto.Text, 0.0);
    IVA := StrToFloatDef(edtIVA.Text, 0.0);
    CostoUni := ((CostoConf-((CostoConf*Sconto) / 100))*(1 + IVA/100)) / NumProdPerConf;

    tblProdotti.Active := True;
    tblProdotti.Insert;
    tblProdotti.FieldByName('CodiceAcquisto').AsString := edtCodice.Text;
    tblProdotti.FieldByName('Nome').AsString := edtNome.Text;
    tblProdotti.FieldByName('Tipologia').AsString := cbTipologia.Items[cbTipologia.ItemIndex];
    tblProdotti.FieldByName('Fornitore').AsString := cbFornitori.Items[cbFornitori.ItemIndex];
    tblProdotti.FieldByName('NumConfPerScatola').AsInteger := StrToIntDef(edtNumConfPerScatola.Text, 0);
    tblProdotti.FieldByName('NumProdPerConf').AsInteger := NumProdPerConf;
    tblProdotti.FieldByName('CostoConfezione').AsFloat := CostoConf;
    tblProdotti.FieldByName('Sconto').AsFloat := Sconto;
    tblProdotti.FieldByName('IVA').AsFloat := IVA;
    tblProdotti.FieldByName('Soglia').AsInteger := StrToIntDef(edtSoglia.Text, 0);
    tblProdotti.FieldByName('CostoUnitario').AsFloat := CostoUni;
    tblProdotti.FieldByName('QtaTotale').AsInteger := 0;
    tblProdotti.Post;
    tblProdotti.Active := False;    
  except
    ShowMessage(MSG_ERRORE_SCRITTURA_DB);
  end;
end;

end.

