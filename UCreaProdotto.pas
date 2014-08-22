unit UCreaProdotto;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, NumberLabeledEdit, StdCtrls, ExtCtrls, TextLabeledEdit, DB,
  ADODB;

type
  TfrmCreaProdotto = class(TForm)
    btnAnnulla: TButton;
    btnOK: TButton;
    btnApplica: TButton;
    qrQuery: TADOQuery;
    tblProdotti: TADOTable;
    img1: TImage;
    gbInfo: TGroupBox;
    edtNome: TTextLabeledEdit;
    edtSoglia: TTextLabeledEdit;
    cbTipologia: TComboBox;
    Label1: TLabel;
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
    procedure AddProdotto;
  end;

var
  frmCreaProdotto: TfrmCreaProdotto;

implementation

uses dmConnection, UMessaggi;

{$R *.dfm}

{ TfrmCreaProdotto }

{ **************************************************************************** }
{ *** Finestra *************************************************************** }

procedure TfrmCreaProdotto.FormShow(Sender: TObject);
begin
  LoadTipologie;
  ResetCampi;
end;

{ **************************************************************************** }
{ *** Componenti ************************************************************* }

procedure TfrmCreaProdotto.btnApplicaClick(Sender: TObject);
begin
  if (Trim(edtNome.Text) = EMPTYSTR) or (cbTipologia.ItemIndex = -1) then

    ShowMessage(MSG_INSERIRE_DATI)
  else
  begin
    AddProdotto;
    LoadTipologie;
    ResetCampi;
  end;
end;

procedure TfrmCreaProdotto.btnOKClick(Sender: TObject);
begin
  if (Trim(edtNome.Text) = EMPTYSTR) or (cbTipologia.ItemIndex = -1) then
    ShowMessage(MSG_INSERIRE_DATI)
  else
  begin
    AddProdotto;
    Close;
  end;
end;

procedure TfrmCreaProdotto.btnAnnullaClick(Sender: TObject);
begin
  Close;
end;

{ **************************************************************************** }
{ *** Reset ****************************************************************** }

procedure TfrmCreaProdotto.ResetCampi;
begin
  edtNome.Text := EMPTYSTR;
  edtNome.SetFocus;
end;

{ **************************************************************************** }
{ *** Load ******************************************************************* }

procedure TfrmCreaProdotto.LoadTipologie;
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

procedure TfrmCreaProdotto.AddProdotto;
begin
  try
    tblProdotti.Active := True;
    tblProdotti.Insert;
    tblProdotti.FieldByName('Nome').AsString := edtNome.Text;
    tblProdotti.FieldByName('Tipologia').AsString := cbTipologia.Items[cbTipologia.ItemIndex];
    tblProdotti.FieldByName('Soglia').AsInteger := StrToIntDef(edtSoglia.Text, 0);
    tblProdotti.FieldByName('QtaTotale').AsInteger := 0;
    tblProdotti.Post;
    tblProdotti.Active := False;    
  except
    ShowMessage(MSG_ERRORE_SCRITTURA_DB);
  end;
end;

end.
