unit UCreaProdottoPerso;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, TextLabeledEdit, Grids, DBGrids, NumberEdit,
  DB, ADODB;

type
  TfrmCreaProdottoPerso = class(TForm)
    img1: TImage;
    gbUtente: TGroupBox;
    gbProdotti: TGroupBox;
    lblInfo3: TLabel;
    lblProdSel: TLabel;
    dgProdotti: TDBGrid;
    gbFiltro2: TGroupBox;
    Label1: TLabel;
    cbTipologie: TComboBox;
    edtFiltroProd: TTextLabeledEdit;
    btnChiudi: TButton;
    cbModalita: TComboBox;
    Label2: TLabel;
    cbUtenti: TComboBox;
    Label3: TLabel;
    gbQtaPersa: TGroupBox;
    Bevel2: TBevel;
    btnInserisci: TButton;
    edtQtaPersa: TNumberEdit;
    dsProdotti: TDataSource;
    qrQuery: TADOQuery;
    qrProdotti: TADOQuery;
    tblProdottiPersi: TADOTable;
    procedure cbModalitaChange(Sender: TObject);
    procedure dgProdottiCellClick(Column: TColumn);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure cbTipologieChange(Sender: TObject);
    procedure edtFiltroProdChange(Sender: TObject);
    procedure btnChiudiClick(Sender: TObject);
    procedure btnInserisciClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure ResetCampi;
    procedure ResetCampiLoadProdotti;
    procedure LoadProdotti;
    procedure LoadTipologie;
    procedure LoadUtenti(Modalita: Integer);
    procedure AddProdottoPerso;
  end;

var
  frmCreaProdottoPerso: TfrmCreaProdottoPerso;

implementation

uses dmConnection, UHashTable, UMessaggi, UVisProdottiPersi;

{$R *.dfm}

{ TfrmCreaProdottoPerso }

var
  hsUtenti: THashTable;

{ **************************************************************************** }
{ *** Finestra *************************************************************** }

procedure TfrmCreaProdottoPerso.FormShow(Sender: TObject);
begin
  ResetCampi;
  LoadUtenti(cbModalita.ItemIndex);
  LoadTipologie;
  LoadProdotti;
  cbModalita.SetFocus;
end;

procedure TfrmCreaProdottoPerso.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  qrProdotti.Active := False;
end;

{ **************************************************************************** }
{ *** Componenti ************************************************************* }

procedure TfrmCreaProdottoPerso.cbModalitaChange(Sender: TObject);
begin
  LoadUtenti(cbModalita.ItemIndex);
end;

procedure TfrmCreaProdottoPerso.dgProdottiCellClick(Column: TColumn);
begin
  if not (qrProdotti.IsEmpty) and (cbUtenti.ItemIndex <> -1) then
  begin
    lblProdSel.Caption := qrProdotti.FieldByName('Nome').AsString;
    edtQtaPersa.Text := EMPTYSTR;
    gbQtaPersa.Visible := True;
  end;
end;

procedure TfrmCreaProdottoPerso.cbTipologieChange(Sender: TObject);
begin
  LoadProdotti;
  ResetCampiLoadProdotti;
end;

procedure TfrmCreaProdottoPerso.edtFiltroProdChange(Sender: TObject);
begin
  LoadProdotti;
  ResetCampiLoadProdotti;
end;

procedure TfrmCreaProdottoPerso.btnChiudiClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmCreaProdottoPerso.btnInserisciClick(Sender: TObject);
begin
  if (Trim(edtQtaPersa.Text) = EMPTYSTR) then ShowMessage(MSG_INSERIRE_DATI)
  else AddProdottoPerso;
end;

{ **************************************************************************** }
{ *** Reset ****************************************************************** }

procedure TfrmCreaProdottoPerso.ResetCampi;
begin
  cbModalita.ItemIndex := 0;
  edtFiltroProd.Text := EMPTYSTR;
  edtQtaPersa.Text := EMPTYSTR;
  gbQtaPersa.Visible := False;
  lblProdSel.Caption := EMPTYSTR;
end;

procedure TfrmCreaProdottoPerso.ResetCampiLoadProdotti;
begin
  edtQtaPersa.Text := EMPTYSTR;
  gbQtaPersa.Visible := False;
  lblProdSel.Caption := EMPTYSTR;
end;

{ **************************************************************************** }
{ *** Load ******************************************************************* }

procedure TfrmCreaProdottoPerso.LoadProdotti;
begin
  qrProdotti.Active := False;
  qrProdotti.SQL.Text := 'SELECT [Codice], [CodiceAcquisto], [Nome], [Tipologia] ' +
                         'FROM [Prodotti] ' +
                         'WHERE (1 = 1)';

  if cbTipologie.ItemIndex > 0 then
    qrProdotti.SQL.Text := qrProdotti.SQL.Text +
                           ' AND ([Tipologia] = ' + QuotedStr(cbTipologie.Items[cbTipologie.ItemIndex]) + ')';

  if edtFiltroProd.Text <> EMPTYSTR then
    qrProdotti.SQL.Text := qrProdotti.SQL.Text +
                           ' AND ([CodiceAcquisto] LIKE ' + QuotedStr('%' + edtFiltroProd.Text + '%') + ' OR ' +
                           '[Nome] LIKE ' + QuotedStr('%' + edtFiltroProd.Text + '%') + ')';

  qrProdotti.SQL.Text := qrProdotti.SQL.Text + ' ORDER BY [Nome]';
  qrProdotti.Active := True;
end;

procedure TfrmCreaProdottoPerso.LoadTipologie;
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

procedure TfrmCreaProdottoPerso.LoadUtenti(Modalita: Integer);
begin
  hsUtenti := THashTable.Create;
  cbUtenti.Clear;
  if Modalita = 0 then
    qrQuery.SQL.Text := 'SELECT [Utenti].[Username], [Utenti].[Cognome], [Utenti].[Nome], ' +
                               '[Utenti].[Cognome] + '' '' + [Utenti].[Nome] AS [Nominativo] ' +
                        'FROM [Utenti] INNER JOIN [AssociazioneAS] ' +
                        'ON [Utenti].[Username] = [AssociazioneAS].[UsernameAssistente] ' +
                        'ORDER BY [Utenti].[Cognome], [Utenti].[Nome]'
  else if Modalita = 1 then
    qrQuery.SQL.Text := 'SELECT [Utenti].[Username], [Utenti].[Cognome], [Utenti].[Nome], ' +
                               '[Utenti].[Cognome] + '' '' + [Utenti].[Nome] AS [Nominativo] ' +
                        'FROM [Utenti] INNER JOIN [AssociazioneAS] ' +
                        'ON [Utenti].[Username] = [AssociazioneAS].[UsernameSostituto] ' +
                        'ORDER BY [Utenti].[Cognome], [Utenti].[Nome]';

  qrQuery.Active := True;
  qrQuery.First;
  while not qrQuery.Eof do
  begin
    hsUtenti.Add(qrQuery.FieldByName('Username').AsString, qrQuery.FieldByName('Nominativo').AsString);
    cbUtenti.Items.Add(qrQuery.FieldByName('Nominativo').AsString);
    qrQuery.Next;
  end;
  qrQuery.Active := False;
  cbUtenti.ItemIndex := -1;
end;

procedure TfrmCreaProdottoPerso.AddProdottoPerso;
var CodProdotto, Username: string;
begin
  try
    CodProdotto := qrProdotti.FieldByName('Codice').AsString;
    Username := hsUtenti.GetKey(cbUtenti.ItemIndex);
    tblProdottiPersi.Active := True;
    tblProdottiPersi.Insert;
    tblProdottiPersi.FieldByName('Data').AsString := DateToStr(Now);
    tblProdottiPersi.FieldByName('CodProdotto').AsString := CodProdotto;
    tblProdottiPersi.FieldByName('Username').AsString := Username;
    tblProdottiPersi.FieldByName('Stato').AsString := cbModalita.Items[cbModalita.ItemIndex];
    tblProdottiPersi.FieldByName('QtaPersa').AsString := edtQtaPersa.Text;
    tblProdottiPersi.Post;
    tblProdottiPersi.Active := False;
    frmProdottiPersi.ResetCampi;
    frmProdottiPersi.LoadProdotti;
    ResetCampi;
    LoadUtenti(cbModalita.ItemIndex);
    LoadProdotti;
    ShowMessage(MSG_PRODOTTO_PERSO_INSERITO);
  except
    ShowMessage(MSG_ERRORE_SCRITTURA_DB);
  end;
end;

end.
