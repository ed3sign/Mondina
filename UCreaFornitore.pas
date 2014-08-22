unit UCreaFornitore;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, TextLabeledEdit, ADODB, DB;

type
  TfrmCreaFornitore = class(TForm)
    qrQuery: TADOQuery;
    tblFornitori: TADOTable;
    btnApplica: TButton;
    btnOK: TButton;
    btnAnnulla: TButton;
    img1: TImage;
    gbInfo: TGroupBox;
    edtNome: TTextLabeledEdit;
    edtTelefono: TTextLabeledEdit;
    edtContatto: TTextLabeledEdit;
    edtCitta: TTextLabeledEdit;
    edtCellulare: TTextLabeledEdit;
    procedure btnApplicaClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure btnAnnullaClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    function EsisteFornitore(Fornitore: string): Boolean;    
    procedure ResetCampi;
    procedure AddFornitore;        
  end;

var
  frmCreaFornitore: TfrmCreaFornitore;

implementation

uses dmConnection, UMessaggi;

{$R *.dfm}

{ TfrmCreaFornitore }

{ **************************************************************************** }
{ *** Finestra *************************************************************** }

procedure TfrmCreaFornitore.FormShow(Sender: TObject);
begin
  ResetCampi;
end;

{ **************************************************************************** }
{ *** Componenti ************************************************************* }

procedure TfrmCreaFornitore.btnApplicaClick(Sender: TObject);
begin
  if (Trim(edtNome.Text) = EMPTYSTR) or (Trim(edtCitta.Text) = EMPTYSTR) or
     (Trim(edtContatto.Text) = EMPTYSTR) or (Trim(edtTelefono.Text) = EMPTYSTR) or
     (Trim(edtCellulare.Text) = EMPTYSTR) then ShowMessage(MSG_INSERIRE_DATI)
  else
  begin
    if EsisteFornitore(edtNome.Text) then ShowMessage(MSG_COD_FORNITORE_ESISTENTE)
    else
    begin
      AddFornitore;
      ResetCampi;
    end;
  end;
end;

procedure TfrmCreaFornitore.btnOKClick(Sender: TObject);
begin
  if (Trim(edtNome.Text) = EMPTYSTR) or (Trim(edtCitta.Text) = EMPTYSTR) or
     (Trim(edtContatto.Text) = EMPTYSTR) or (Trim(edtTelefono.Text) = EMPTYSTR) or
     (Trim(edtCellulare.Text) = EMPTYSTR) then ShowMessage(MSG_INSERIRE_DATI)
  else
  begin
    if EsisteFornitore(edtNome.Text) then ShowMessage(MSG_COD_FORNITORE_ESISTENTE)
    else
    begin
      AddFornitore;
      Close;
    end;
  end;
end;

procedure TfrmCreaFornitore.btnAnnullaClick(Sender: TObject);
begin
  Close;
end;

{ **************************************************************************** }
{ *** Reset ****************************************************************** }

procedure TfrmCreaFornitore.ResetCampi;
begin
  edtNome.Text := EMPTYSTR;
  edtCitta.Text := EMPTYSTR;
  edtContatto.Text := EMPTYSTR;
  edtTelefono.Text := EMPTYSTR;
  edtCellulare.Text := EMPTYSTR;
  edtNome.SetFocus;
end;

{ **************************************************************************** }
{ *** Gestione *************************************************************** }

procedure TfrmCreaFornitore.AddFornitore;
begin
  try
    tblFornitori.Active := True;
    tblFornitori.Insert;
    tblFornitori.FieldByName('Fornitore').AsString := edtNome.Text;
    tblFornitori.FieldByName('Telefono').AsString := edtTelefono.Text;
    tblFornitori.FieldByName('Citta').AsString := edtCitta.Text;
    tblFornitori.FieldByName('Contatto').AsString := edtContatto.Text;
    tblFornitori.FieldByName('Cellulare').AsString := edtCellulare.Text;
    tblFornitori.Post;
    tblFornitori.Active := False;
  except
    ShowMessage(MSG_ERRORE_SCRITTURA_DB);
  end;
end;

function TfrmCreaFornitore.EsisteFornitore(Fornitore: string): Boolean;
var res: Boolean;
begin
  res := True;
  qrQuery.SQL.Text := 'SELECT [Fornitore] FROM [Fornitori] ' +
                      'WHERE [Fornitore] = ' + QuotedStr(Fornitore);
  qrQuery.Active := True;
  if qrQuery.IsEmpty then res := False;
  qrQuery.Active := False;
  EsisteFornitore := res;
end;

end.
