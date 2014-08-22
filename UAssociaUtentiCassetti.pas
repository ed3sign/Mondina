unit UAssociaUtentiCassetti;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, DB, ADODB, Grids, DBGrids;

type
  TfrmAssociaUtentiCassetti = class(TForm)
    gbCassetti: TGroupBox;
    lblInfo4: TLabel;
    lblCassettoSel: TLabel;
    lbCassetti: TListBox;
    gbFiltro: TGroupBox;
    lblInfo2: TLabel;
    lblInfo1: TLabel;
    cbStudi: TComboBox;
    cbMobili: TComboBox;
    gbUtenti: TGroupBox;
    gbCassettiAcc: TGroupBox;
    btnElimina: TButton;
    btnInserisci: TButton;
    btnChiudi: TButton;
    qrQuery: TADOQuery;
    img1: TImage;
    qrUtenti: TADOQuery;
    dgUtenti: TDBGrid;
    lblInfo3: TLabel;
    lblAssociazioneSel: TLabel;
    dgCassettiAcc: TDBGrid;
    dsUtenti: TDataSource;
    dsCassettiAcc: TDataSource;
    qrCassettiAcc: TADOQuery;
    lblCassettoAccSel: TLabel;
    procedure FormShow(Sender: TObject);
    procedure cbStudiChange(Sender: TObject);
    procedure cbMobiliChange(Sender: TObject);
    procedure lbCassettiClick(Sender: TObject);
    procedure btnEliminaClick(Sender: TObject);
    procedure btnInserisciClick(Sender: TObject);
    procedure btnChiudiClick(Sender: TObject);
    procedure dgUtentiCellClick(Column: TColumn);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure dgCassettiAccCellClick(Column: TColumn);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure LoadStudi;
    procedure LoadMobili;
    procedure LoadCassetti;
    procedure LoadTuttiCassetti;
    procedure LoadCassettiUtente;
    procedure ResetCampi;
    procedure ResetCampiFiltroCassetto;
    procedure ResetCampiSelUtente;
    function EsisteCassetto(Username, Cassetto, Tipo: string): Boolean;
    procedure InserisciCassetto;
    procedure CancellaCassetto;
    procedure AggiornaListaCassetti;
  end;

var
  frmAssociaUtentiCassetti: TfrmAssociaUtentiCassetti;

implementation

uses dmConnection, UHashTable, UMessaggi;

{$R *.dfm}

{ TfrmAssociaUtentiCassetti }

var
  hsStudi: THashTable;
  hsMobili: THashTable;

{ **************************************************************************** }
{ *** Finestra *************************************************************** }

procedure TfrmAssociaUtentiCassetti.FormShow(Sender: TObject);
begin
  qrUtenti.SQL.Text := 'SELECT DISTINCT ([AssociazioneAS].[Codice]), ' +
                               '[AssociazioneAS].[Posizione], [AssociazioneAS].[Nome], ' +
                               '[qrAssistente].[NominativoAssistente], [qrSostituto].[NominativoSostituto] ' +
                       'FROM [AssociazioneAS], (' +
                            'SELECT [Utenti].[Cognome] + '' '' + [Utenti].[Nome] AS [NominativoAssistente], [Utenti].[Username] ' +
                            'FROM [AssociazioneAS] INNER JOIN [Utenti] ON [AssociazioneAS].[UsernameAssistente]=[Utenti].[Username] ' +
                            ') AS [qrAssistente], (' +
                            'SELECT [Utenti].[Cognome] + '' '' + [Utenti].[Nome] AS [NominativoSostituto], [Utenti].[Username] ' +
                            'FROM [AssociazioneAS] INNER JOIN [Utenti] ON [AssociazioneAS].[UsernameSostituto]=[Utenti].[Username] ' +
                            ') AS [qrSostituto] ' +
                       'WHERE [AssociazioneAS].[UsernameAssistente] = [qrAssistente].[Username] AND ' +
                             '[AssociazioneAS].[UsernameSostituto] = [qrSostituto].[Username] ' +
                       'ORDER BY [AssociazioneAS].[Posizione]';

  qrUtenti.Active := True;
  qrCassettiAcc.Active := False;
  ResetCampi;
  LoadStudi;
  LoadTuttiCassetti;
end;

procedure TfrmAssociaUtentiCassetti.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  qrUtenti.Active := False;
  qrCassettiAcc.Active := False;
end;

{ **************************************************************************** }
{ *** Componenti ************************************************************* }

procedure TfrmAssociaUtentiCassetti.cbStudiChange(Sender: TObject);
begin
  cbMobili.Clear;
  ResetCampiFiltroCassetto;
  if cbStudi.ItemIndex = 0 then LoadTuttiCassetti
  else LoadMobili;
end;

procedure TfrmAssociaUtentiCassetti.cbMobiliChange(Sender: TObject);
begin
  ResetCampiFiltroCassetto;
  LoadCassetti;
end;

procedure TfrmAssociaUtentiCassetti.lbCassettiClick(Sender: TObject);
begin
  if lblAssociazioneSel.Caption <> EMPTYSTR then
  begin
    lblCassettoSel.Caption := lbCassetti.Items[lbCassetti.itemIndex];
    dgCassettiAcc.SelectedIndex := -1;
    lblCassettoAccSel.Caption := EMPTYSTR;
    btnElimina.Enabled := False;
    btnInserisci.Enabled := True;
  end;
end;

procedure TfrmAssociaUtentiCassetti.btnEliminaClick(Sender: TObject);
begin
  CancellaCassetto;
  lblCassettoAccSel.Caption := EMPTYSTR;
  btnElimina.Enabled := False;
  AggiornaListaCassetti;
end;

procedure TfrmAssociaUtentiCassetti.btnInserisciClick(Sender: TObject);
begin
  InserisciCassetto;
  lblCassettoSel.Caption := EMPTYSTR;
  lbCassetti.ItemIndex := -1;
  btnInserisci.Enabled := False;
  AggiornaListaCassetti;
end;

procedure TfrmAssociaUtentiCassetti.btnChiudiClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmAssociaUtentiCassetti.dgUtentiCellClick(Column: TColumn);
begin
  if not qrUtenti.IsEmpty then
  begin
    lblAssociazioneSel.Caption := qrUtenti.FieldByName('Nome').AsString;
    ResetCampiSelUtente;
    LoadCassettiUtente;
  end;
end;

procedure TfrmAssociaUtentiCassetti.dgCassettiAccCellClick(
  Column: TColumn);
begin
  if not qrCassettiAcc.IsEmpty then
  begin
    lblCassettoAccSel.Caption := qrCassettiAcc.FieldByName('Codice').AsString;
    lblCassettoSel.Caption := EMPTYSTR;
    lbCassetti.ItemIndex := -1;
    btnElimina.Enabled := True;
    btnInserisci.Enabled := False;
  end;
end;

{ **************************************************************************** }
{ *** Reset ****************************************************************** }

procedure TfrmAssociaUtentiCassetti.ResetCampi;
begin
  btnElimina.Enabled := False;
  btnInserisci.Enabled := False;
  lblAssociazioneSel.Caption := EMPTYSTR;
  lblCassettoAccSel.Caption := EMPTYSTR;
  lblCassettoSel.Caption := EMPTYSTR;
  dgCassettiAcc.SelectedIndex := -1;
  cbMobili.Clear;
  btnChiudi.SetFocus;
end;

procedure TfrmAssociaUtentiCassetti.ResetCampiFiltroCassetto;
begin
  btnElimina.Enabled := False;
  btnInserisci.Enabled := False;
  lblCassettoSel.Caption := EMPTYSTR;
  dgCassettiAcc.SelectedIndex := -1;
  lbCassetti.ItemIndex := -1;
end;

procedure TfrmAssociaUtentiCassetti.ResetCampiSelUtente;
begin
  btnElimina.Enabled := False;
  btnInserisci.Enabled := False;
  lblCassettoSel.Caption := EMPTYSTR;
  lblCassettoAccSel.Caption := EMPTYSTR;
  dgCassettiAcc.SelectedIndex := -1;
  lbCassetti.ItemIndex := -1;
end;

{ **************************************************************************** }
{ *** Load ******************************************************************* }

procedure TfrmAssociaUtentiCassetti.LoadCassetti;
var sel: string;
begin
  sel := hsMobili.GetKey(cbMobili.ItemIndex);
  lbCassetti.Clear;
  qrQuery.SQL.Text := 'SELECT * FROM [Cassetti] ' +
                      'WHERE [CodAssociazioneAS] = 0 AND [CodMobile] = ' + QuotedStr(sel) + ' ' +
                      'ORDER BY [Codice]';
  qrQuery.Active := True;
  qrQuery.First;
  while not qrQuery.Eof do
  begin
    lbCassetti.Items.Add(qrQuery.FieldByName('Codice').AsString);
    qrQuery.Next;
  end;
  qrQuery.Active := False;
  lbCassetti.ItemIndex := -1;
end;

procedure TfrmAssociaUtentiCassetti.LoadMobili;
var sel: string;
begin
  sel := hsStudi.GetKey(cbStudi.ItemIndex);
  hsMobili := THashTable.Create;
  cbMobili.Clear;
  qrQuery.SQL.Text := 'SELECT * FROM [Mobili] ' +
                      'WHERE [CodStudio] = ' + QuotedStr(sel) + ' ' +
                      'ORDER BY [Nome]';
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

procedure TfrmAssociaUtentiCassetti.LoadStudi;
begin
  hsStudi := THashTable.Create;
  cbStudi.Clear;
  cbStudi.Items.Add(' ');
  hsStudi.Add(' ', ' ');
  qrQuery.SQL.Text := 'SELECT * FROM [Studi] ORDER BY [Nome]';
  qrQuery.Active := True;
  qrQuery.First;
  while not qrQuery.Eof do
  begin
    hsStudi.Add(qrQuery.FieldByName('Codice').AsString, qrQuery.FieldByName('Nome').AsString);
    cbStudi.Items.Add(qrQuery.FieldByName('Nome').AsString);
    qrQuery.Next;
  end;
  qrQuery.Active := False;
  cbStudi.ItemIndex := 0;
end;

procedure TfrmAssociaUtentiCassetti.LoadTuttiCassetti;
begin
  lbCassetti.Clear;
  qrQuery.SQL.Text := 'SELECT * FROM [Cassetti] WHERE [CodAssociazioneAS] = 0 ORDER BY [Codice]';
  qrQuery.Active := True;
  qrQuery.First;
  while not qrQuery.Eof do
  begin
    lbCassetti.Items.Add(qrQuery.FieldByName('Codice').AsString);
    qrQuery.Next;
  end;
  qrQuery.Active := False;
  lbCassetti.ItemIndex := -1;
end;

procedure TfrmAssociaUtentiCassetti.LoadCassettiUtente;
var
  CodAssociazione: string;
begin
  CodAssociazione := qrUtenti.FieldByName('Codice').AsString;
  qrCassettiAcc.SQL.Text := 'SELECT * ' +
                            'FROM [Cassetti] ' +
                            'WHERE [CodAssociazioneAS] = ' + CodAssociazione + ' ' +
                            'ORDER BY [Codice]';
  qrCassettiAcc.Active := True;
end;

procedure TfrmAssociaUtentiCassetti.AggiornaListaCassetti;
begin
  if cbMobili.ItemIndex = -1 then LoadTuttiCassetti
  else LoadCassetti;
end;

{ **************************************************************************** }
{ *** Gestione *************************************************************** }

function TfrmAssociaUtentiCassetti.EsisteCassetto(Username, Cassetto, Tipo: string): Boolean;
var ris: Boolean;
begin
  ris := True;
  qrQuery.SQL.Text := 'SELECT [CodCassetto] ' +
                      'FROM [Utenti_Cassetti] ' +
                      'WHERE [Username] = ' + QuotedStr(Username) + ' AND ' +
                            '[CodCassetto] = ' + QuotedStr(Cassetto) + ' AND ' +
                            '[Tipo] = ' + QuotedStr(Tipo);
  qrQuery.Active := True;
  if qrQuery.IsEmpty then ris := False;
  qrQuery.Active := False;
  EsisteCassetto := ris;
end;

procedure TfrmAssociaUtentiCassetti.CancellaCassetto;
begin
  try
    qrCassettiAcc.Edit;
    qrCassettiAcc.FieldByName('CodAssociazioneAS').AsString := '0';
    qrCassettiAcc.Post;
    qrCassettiAcc.Active := False;
    qrCassettiAcc.Active := True;
  except
    ShowMessage(MSG_ERRORE_SCRITTURA_DB);
  end;
end;

procedure TfrmAssociaUtentiCassetti.InserisciCassetto;
var CodAssociazione, CodCassetto: string;
begin
  try
    CodAssociazione := qrUtenti.FieldByName('Codice').AsString;
    CodCassetto := lbCassetti.Items[lbCassetti.ItemIndex];
    qrQuery.SQL.Text := 'UPDATE [Cassetti] ' +
                        'SET [CodAssociazioneAS] = ' + CodAssociazione + ' ' +
                        'WHERE [Codice] = ' + QuotedStr(CodCassetto);
    qrQuery.ExecSQL;
    qrCassettiAcc.Active := False;
    qrCassettiAcc.Active := True;
  except
    ShowMessage(MSG_ERRORE_SCRITTURA_DB);
  end;
end;

end.
