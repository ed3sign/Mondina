unit UAggiornaFornitore;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ADODB, DB, StdCtrls, ExtCtrls, TextLabeledEdit, Grids, DBGrids;

type
  TfrmAggiornaFornitore = class(TForm)
    img1: TImage;
    btnChiudi: TButton;
    gbFornitori: TGroupBox;
    lblInfo2: TLabel;
    lblFornitoreSel: TLabel;
    dgFornitori: TDBGrid;
    gbInfo: TGroupBox;
    gbComandi: TGroupBox;
    btnModifica: TButton;
    btnElimina: TButton;
    gbModifica: TGroupBox;
    Bevel1: TBevel;
    btnOK: TButton;
    btnAnnulla: TButton;
    dsFornitori: TDataSource;
    qrQuery: TADOQuery;
    edtCitta: TTextLabeledEdit;
    edtContatto: TTextLabeledEdit;
    edtTelefono: TTextLabeledEdit;
    edtCellulare: TTextLabeledEdit;
    qrFornitori: TADOQuery;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure dgFornitoriCellClick(Column: TColumn);
    procedure btnModificaClick(Sender: TObject);
    procedure btnEliminaClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure btnAnnullaClick(Sender: TObject);
    procedure btnChiudiClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure ResetCampi;
    procedure CancellaRecord;
    procedure ModificaRecord;
    procedure RiempiCampi;
    function FornitoreCollegato(CodFornitore: string): Boolean;
  end;

var
  frmAggiornaFornitore: TfrmAggiornaFornitore;

implementation

uses dmConnection, UMessaggi;

{$R *.dfm}

{ TfrmAggiornaFornitore }

{ **************************************************************************** }
{ *** Finestra *************************************************************** }

procedure TfrmAggiornaFornitore.FormShow(Sender: TObject);
begin
  ResetCampi;
  qrFornitori.SQL.Text := 'SELECT * FROM [Fornitori] ORDER BY [Fornitore]';
  qrFornitori.Active := True;
end;

procedure TfrmAggiornaFornitore.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  qrFornitori.Active := False;
end;

{ **************************************************************************** }
{ *** Componenti ************************************************************* }

procedure TfrmAggiornaFornitore.dgFornitoriCellClick(Column: TColumn);
begin
  if not qrFornitori.IsEmpty then
  begin
    lblFornitoreSel.Caption := qrFornitori.FieldByName('Fornitore').AsString;
    gbModifica.Visible := False;
    gbComandi.Visible := True;
  end;
end;

procedure TfrmAggiornaFornitore.btnModificaClick(Sender: TObject);
begin
  RiempiCampi;
  gbComandi.Visible := False;
  gbModifica.Visible := True;
end;

procedure TfrmAggiornaFornitore.btnEliminaClick(Sender: TObject);
var ris: Integer;
begin
  gbComandi.Visible := False;
  ris := MessageDlg(MSG_ELIMINA_RECORD, mtWarning, [mbYes, mbNo], 0);
  if ris = mrYes then
  begin
   if FornitoreCollegato(lblFornitoreSel.Caption) then Showmessage(MSG_FORNITORE_COLLEGATO)
   else CancellaRecord;
  end;
  lblFornitoreSel.Caption := EMPTYSTR;
end;

procedure TfrmAggiornaFornitore.btnOKClick(Sender: TObject);
begin
  if (Trim(edtCitta.Text) = EMPTYSTR) or
     (Trim(edtContatto.Text) = EMPTYSTR) or (Trim(edtTelefono.Text) = EMPTYSTR) or
     (Trim(edtCellulare.Text) = EMPTYSTR) then ShowMessage(MSG_INSERIRE_DATI)
  else
  begin
    ModificaRecord;
    gbModifica.Visible := False;
    lblFornitoreSel.Caption := EMPTYSTR;
  end;
end;

procedure TfrmAggiornaFornitore.btnAnnullaClick(Sender: TObject);
begin
  gbModifica.Visible := False;
  lblFornitoreSel.Caption := EMPTYSTR;
end;

procedure TfrmAggiornaFornitore.btnChiudiClick(Sender: TObject);
begin
  Close;
end;

{ **************************************************************************** }
{ *** Reset ****************************************************************** }

procedure TfrmAggiornaFornitore.ResetCampi;
begin
  edtCitta.Text := EMPTYSTR;
  edtContatto.Text := EMPTYSTR;
  edtTelefono.Text := EMPTYSTR;
  edtCellulare.Text := EMPTYSTR;

  lblFornitoreSel.Caption := EMPTYSTR;
  gbComandi.Visible := False;
  gbModifica.Visible := False;
  btnChiudi.SetFocus;  
end;

{ **************************************************************************** }
{ *** Gestione *************************************************************** }

procedure TfrmAggiornaFornitore.ModificaRecord;
begin
  try
    qrFornitori.Edit;
    qrFornitori.FieldByName('Telefono').AsString := edtTelefono.Text;
    qrFornitori.FieldByName('Citta').AsString := edtCitta.Text;
    qrFornitori.FieldByName('Contatto').AsString := edtContatto.Text;
    qrFornitori.FieldByName('Cellulare').AsString := edtCellulare.Text;
    qrFornitori.Post;
  except
    ShowMessage(MSG_ERRORE_SCRITTURA_DB);
  end;
end;

procedure TfrmAggiornaFornitore.CancellaRecord;
begin
  try
    qrFornitori.Delete;
  except
    ShowMessage(MSG_ERRORE_SCRITTURA_DB);
  end;
end;

function TfrmAggiornaFornitore.FornitoreCollegato(CodFornitore: string): Boolean;
var res: Boolean;
begin
  res := True;
  qrQuery.SQL.Text := 'SELECT [Fornitore] FROM [Prodotti] ' +
                      'WHERE [Fornitore] = ' + QuotedStr(CodFornitore);
  qrQuery.Active := True;
  if qrQuery.IsEmpty then res := False;
  qrQuery.Active := False;
  FornitoreCollegato := res;
end;

procedure TfrmAggiornaFornitore.RiempiCampi;
begin
  edtTelefono.Text := qrFornitori.FieldByName('Telefono').AsString;
  edtCitta.Text := qrFornitori.FieldByName('Citta').AsString;
  edtContatto.Text := qrFornitori.FieldByName('Contatto').AsString;
  edtCellulare.Text := qrFornitori.FieldByName('Cellulare').AsString;
end;

end.
