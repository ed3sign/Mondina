unit UAggiornaProdotto;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, ADODB, StdCtrls, Grids, DBGrids, ExtCtrls,
  NumberLabeledEdit, TextLabeledEdit;

type
  TfrmAggiornaProdotto = class(TForm)
    dsProdotti: TDataSource;
    qrProdotti: TADOQuery;
    qrQuery: TADOQuery;
    btnChiudi: TButton;
    gbProdotti: TGroupBox;
    gbFiltro2: TGroupBox;
    Label2: TLabel;
    cbTipologie: TComboBox;
    edtFiltroProd: TTextLabeledEdit;
    dgProdotti: TDBGrid;
    lblInfo2: TLabel;
    lblProdottoSel: TLabel;
    img1: TImage;
    gbInfo: TGroupBox;
    gbComandi: TGroupBox;
    btnModifica: TButton;
    btnElimina: TButton;
    gbModifica: TGroupBox;
    Bevel1: TBevel;
    lblInfo1: TLabel;
    btnOK: TButton;
    btnAnnulla: TButton;
    edtNome: TTextLabeledEdit;
    cbTipologia: TComboBox;
    edtSoglia: TNumberLabeledEdit;
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure cbTipologieChange(Sender: TObject);
    procedure edtFiltroProdKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure dgProdottiCellClick(Column: TColumn);
    procedure btnModificaClick(Sender: TObject);
    procedure btnEliminaClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure btnAnnullaClick(Sender: TObject);
    procedure btnChiudiClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure LoadTipologie1;
    procedure LoadTipologie2;
    procedure LoadProdotti;
    procedure ResetCampi;
    procedure ResetCampiLoadProdotti;
    procedure RiempiCampi;
    procedure CancellaRecord;
    procedure ModificaRecord;
    function ProdottoCollegato(CodProdotto: string): Boolean;
  end;

var
  frmAggiornaProdotto: TfrmAggiornaProdotto;

implementation

uses dmConnection, UMessaggi;

{$R *.dfm}

{ **************************************************************************** }
{ *** Finestra *************************************************************** }

procedure TfrmAggiornaProdotto.FormShow(Sender: TObject);
begin
  ResetCampi;
  LoadTipologie1;
  LoadProdotti;
  cbTipologie.SetFocus;
end;

procedure TfrmAggiornaProdotto.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  qrProdotti.Active := True;
end;

{ **************************************************************************** }
{ *** Componenti ************************************************************* }

procedure TfrmAggiornaProdotto.cbTipologieChange(Sender: TObject);
begin
  LoadProdotti;
  ResetCampiLoadProdotti;
end;

procedure TfrmAggiornaProdotto.edtFiltroProdKeyUp(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  LoadProdotti;
  ResetCampiLoadProdotti;
end;

procedure TfrmAggiornaProdotto.dgProdottiCellClick(Column: TColumn);
begin
  if not qrProdotti.IsEmpty then
  begin
    lblProdottoSel.Caption := qrProdotti.FieldByName('Nome').AsString;
    gbModifica.Visible := False;
    gbComandi.Visible := True;
  end;
end;

procedure TfrmAggiornaProdotto.btnModificaClick(Sender: TObject);
begin
  RiempiCampi;
  gbComandi.Visible := False;
  gbModifica.Visible := True;
end;

procedure TfrmAggiornaProdotto.btnEliminaClick(Sender: TObject);
var
  ris: Integer;
  codProd: string;
begin
  gbComandi.Visible := False;
  ris := MessageDlg(MSG_ELIMINA_RECORD, mtWarning, [mbYes, mbNo], 0);
  if ris = mrYes then
  begin
    codProd := qrProdotti.FieldByName('Codice').AsString;
    if ProdottoCollegato(codProd) then Showmessage(MSG_PRODOTTO_COLLEGATO)
    else CancellaRecord;
  end;
  lblProdottoSel.Caption := EMPTYSTR;
end;

procedure TfrmAggiornaProdotto.btnOKClick(Sender: TObject);
begin
  if (Trim(edtNome.Text) = EMPTYSTR) or (Trim(edtSoglia.Text) = EMPTYSTR) or
     (cbTipologia.ItemIndex = -1) then

     ShowMessage(MSG_INSERIRE_DATI)
  else
  begin
      ModificaRecord;
      gbModifica.Visible := False;
      lblProdottoSel.Caption := EMPTYSTR;
  end;
end;

procedure TfrmAggiornaProdotto.btnAnnullaClick(Sender: TObject);
begin
  gbModifica.Visible := False;
  lblProdottoSel.Caption := EMPTYSTR;
end;

procedure TfrmAggiornaProdotto.btnChiudiClick(Sender: TObject);
begin
  Close;
end;

{ **************************************************************************** }
{ *** Reset ****************************************************************** }

procedure TfrmAggiornaProdotto.ResetCampi;
begin
  edtNome.Text := EMPTYSTR;
  cbTipologia.Clear;
  edtSoglia.Text := EMPTYSTR;

  lblProdottoSel.Caption := EMPTYSTR;
  gbComandi.Visible := False;
  gbModifica.Visible := False;
  edtFiltroProd.Text := EMPTYSTR;
end;

procedure TfrmAggiornaProdotto.ResetCampiLoadProdotti;
begin
  lblProdottoSel.Caption := EMPTYSTR;
  gbComandi.Visible := False;
  gbModifica.Visible := False;
end;

{ **************************************************************************** }
{ *** Load ******************************************************************* }

procedure TfrmAggiornaProdotto.LoadTipologie1;
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

procedure TfrmAggiornaProdotto.LoadTipologie2;
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

procedure TfrmAggiornaProdotto.LoadProdotti;
begin
  qrProdotti.Active := False;
  qrProdotti.SQL.Text := 'SELECT * ' +
                         'FROM [Prodotti] ' + 
                         'WHERE (1 = 1)';

  if cbTipologie.ItemIndex > 0 then
    qrProdotti.SQL.Text := qrProdotti.SQL.Text +
                           ' AND ([Tipologia] = ' + QuotedStr(cbTipologie.Items[cbTipologie.ItemIndex]) + ')';

  if edtFiltroProd.Text <> EMPTYSTR then
    qrProdotti.SQL.Text := qrProdotti.SQL.Text +
                           ' AND ([Nome] LIKE ' + QuotedStr('%' + edtFiltroProd.Text + '%') + ')';

  qrProdotti.SQL.Text := qrProdotti.SQL.Text + ' ORDER BY [Nome]';
  qrProdotti.Active := True;
end;

{ **************************************************************************** }
{ *** Gestione *************************************************************** }

procedure TfrmAggiornaProdotto.RiempiCampi;
begin
  LoadTipologie2;
  edtNome.Text := qrProdotti.FieldByName('Nome').AsString;
  cbTipologia.ItemIndex := cbTipologia.Items.IndexOf(qrProdotti.FieldByName('Tipologia').AsString);
  edtSoglia.Text := qrProdotti.FieldByName('Soglia').AsString;
end;


procedure TfrmAggiornaProdotto.CancellaRecord;
var codProdotto: string;
begin
  try
    codProdotto := qrProdotti.FieldByName('Codice').AsString;
    qrQuery.SQL.Text := 'DELETE FROM [Prodotti_Ordinati] WHERE [codProdotto] = ' + codProdotto;
    qrQuery.ExecSQL;
    qrQuery.SQL.Text := 'DELETE FROM [Prodotti_Persi] WHERE [codProdotto] = ' + codProdotto;
    qrQuery.ExecSQL;
    qrProdotti.Delete;
  except
    ShowMessage(MSG_ERRORE_SCRITTURA_DB);
  end;
end;

procedure TfrmAggiornaProdotto.ModificaRecord;
begin
  try
    qrProdotti.Edit;
    qrProdotti.FieldByName('Nome').AsString := edtNome.Text;
    qrProdotti.FieldByName('Tipologia').AsString := cbTipologia.Items[cbTipologia.ItemIndex];
    qrProdotti.FieldByName('Soglia').AsInteger := StrToIntDef(edtSoglia.Text, 0);
    qrProdotti.Post;
    qrProdotti.Active := False;
    qrProdotti.Active := True;    
  except
    ShowMessage(MSG_ERRORE_SCRITTURA_DB);
  end;
end;

function TfrmAggiornaProdotto.ProdottoCollegato(CodProdotto: string): Boolean;
var res: Boolean;
begin
  res := True;
  qrQuery.SQL.Text := 'SELECT [CodProdotto] FROM [Prodotti_Cassetti] ' +
                      'WHERE [CodProdotto] = ' + CodProdotto;
  qrQuery.Active := True;
  if qrQuery.IsEmpty then
  begin
    qrQuery.Active := False;
    qrQuery.SQL.Text := 'SELECT [CodProdotto] FROM [Prodotti_Richiesti_Studi] ' +
                        'WHERE [CodProdotto] = ' + CodProdotto;
    qrQuery.Active := True;
    if qrQuery.IsEmpty then res := False;
    qrQuery.Active := False;
  end;
  qrQuery.Active := False;
  ProdottoCollegato := res;
end;

end.
