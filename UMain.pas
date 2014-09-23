unit UMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, StdCtrls, ImgList;

type
  TfrmMain = class(TForm)
    mmMenu: TMainMenu;
    mmFile: TMenuItem;
    mmLogin: TMenuItem;
    mmEsci: TMenuItem;
    mmPath: TMemo;
    mmN1: TMenuItem;
    mmInserisci: TMenuItem;
    mmInserisciU: TMenuItem;
    mmInserisciS: TMenuItem;
    mmInserisciM: TMenuItem;
    mmModifica: TMenuItem;
    mmModificaU: TMenuItem;
    mmModificaP: TMenuItem;
    mmInserisciC: TMenuItem;
    mmInserisciP: TMenuItem;
    mmModificaS: TMenuItem;
    mmModificaM: TMenuItem;
    mmModificaC: TMenuItem;
    mmN2: TMenuItem;
    mmN3: TMenuItem;
    mmAssocia: TMenuItem;
    mmUtentiCassetti: TMenuItem;
    mmProdottiCassetti: TMenuItem;
    mmVisualizza: TMenuItem;
    mmVisCassetti: TMenuItem;
    mmDatiPersonali: TMenuItem;
    mmVisMagazzino: TMenuItem;
    mmHelp: TMenuItem;
    mmAbout: TMenuItem;
    N1: TMenuItem;
    mmInserisciFP: TMenuItem;
    mmInserisciTP: TMenuItem;
    imgListMenu: TImageList;
    N2: TMenuItem;
    mmModificaFP: TMenuItem;
    mmModificaTP: TMenuItem;
    mmAssistentiSostituti: TMenuItem;
    mmStrumenti: TMenuItem;
    mmCompattaDB: TMenuItem;
    mmReport: TMenuItem;
    mmProdPerTipologia: TMenuItem;
    mmProdOrdinati: TMenuItem;
    mmProdSottoSoglia: TMenuItem;
    mmProdPerAssistente: TMenuItem;
    mmProdottiPersi: TMenuItem;
    mmVisProdottiPersi: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    mmVisProdottiOrdinati: TMenuItem;
    mmVisProdRichiestiStudi: TMenuItem;
    mmProdRichiestiStudi: TMenuItem;
    mmVisOrdiniMag: TMenuItem;
    mmProdottiFornitori: TMenuItem;
    mmProdottiConsegnati: TMenuItem;
    mmProdottiNonConsegnati: TMenuItem;
    mmRifornimentiEmergenza: TMenuItem;
    procedure mmLoginClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure mmEsciClick(Sender: TObject);
    procedure mmDatiPersonaliClick(Sender: TObject);
    procedure mmVisCassettiClick(Sender: TObject);
    procedure mmInserisciPClick(Sender: TObject);
    procedure mmInserisciUClick(Sender: TObject);
    procedure mmAboutClick(Sender: TObject);
    procedure mmUtentiCassettiClick(Sender: TObject);
    procedure mmProdottiCassettiClick(Sender: TObject);
    procedure mmVisMagazzinoClick(Sender: TObject);
    procedure mmInserisciFPClick(Sender: TObject);
    procedure mmInserisciTPClick(Sender: TObject);
    procedure mmInserisciSClick(Sender: TObject);
    procedure mmInserisciMClick(Sender: TObject);
    procedure mmInserisciCClick(Sender: TObject);
    procedure mmModificaUClick(Sender: TObject);
    procedure mmModificaPClick(Sender: TObject);
    procedure mmModificaSClick(Sender: TObject);
    procedure mmModificaMClick(Sender: TObject);
    procedure mmModificaCClick(Sender: TObject);
    procedure mmModificaFPClick(Sender: TObject);
    procedure mmModificaTPClick(Sender: TObject);
    procedure mmAssistentiSostitutiClick(Sender: TObject);
    procedure mmCompattaDBClick(Sender: TObject);
    procedure mmVisProdottiClick(Sender: TObject);
    procedure mmProdPerTipologiaClick(Sender: TObject);
    procedure mmProdOrdinatiClick(Sender: TObject);
    procedure mmProdSottoSogliaClick(Sender: TObject);
    procedure mmProdPerAssistenteClick(Sender: TObject);
    procedure mmProdottiPersiClick(Sender: TObject);
    procedure mmVisProdottiPersiClick(Sender: TObject);
    procedure mmVisProdottiOrdinatiClick(Sender: TObject);
    procedure mmVisProdRichiestiStudiClick(Sender: TObject);
    procedure mmProdRichiestiStudiClick(Sender: TObject);
    procedure mmVisOrdiniMagClick(Sender: TObject);
    procedure mmProdottiFornitoriClick(Sender: TObject);
    procedure mmProdottiConsegnatiClick(Sender: TObject);
    procedure mmProdottiNonConsegnatiClick(Sender: TObject);
    procedure mmRifornimentiEmergenzaClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure ConnessioneDB;
    procedure ImpostaPermessi(LivelloUtente: string);
    procedure CompattaDB;
  end;

var
  frmMain: TfrmMain;

implementation

uses ULogin, UDatiPersonali, UVisCassetti, UCreaProdotto,
  UMessaggi, UCreaUtente, UAbout, UAssociaUtentiCassetti,
  UAssociaProdottiCassetti, UVisMagazzino, UCreaFornitore,
  UCreaTipologiaProdotto, UCreaStudi, UCreaMobile, UCreaCassetto,
  UAggiornaUtente, UAggiornaProdotto, UAggiornaStudio, UAggiornaFornitore,
  UAggiornaTipologia, UAggiornaMobile, UAggiornaCassetto,
  UAssociaAssistentiSostituti, dmConnection, UGestioneDatabase,
  UVisProdottiCassetti, UVisProdottiPerTipologia, UVisProdottiOrdinati,
  UReportProdottiSottoSoglia, UVisProdottiPerAssistente,
  UVisProdottiPersiSelPagina, UVisProdottiPersi, UProdottiOrdinati,
  UVisProdottiRichiestiStudi, UProdottiRichiestiStudi, UVisOrdiniMag,
  UAssociaProdottiFornitori, UReportProdottiConsegnati,
  UVisProdottiConsegnati, UProdottiNonConsegnati,
  UVisRifornimentiEmergenza;

{$R *.dfm}

{ **************************************************************************** }
{ *** Finestra *************************************************************** }

procedure TfrmMain.FormShow(Sender: TObject);
begin
  Username := EMPTYSTR;
  LivelloUtente := EMPTYSTR;
  CodAssociazioneAS := EMPTYSTR;
  ImpostaPermessi('0');
  ConnessioneDB;
end;

{ **************************************************************************** }
{ *** Gestione *************************************************************** }

procedure TfrmMain.ConnessioneDB;
var DirPrg: string;
begin
  DirPRG := ExtractFilePath(Application.ExeName);
  mmPath.Lines.LoadFromFile(DirPRG + '\' + NOME_TXT);
  try
    dmCnt.AdoCnt.Connected := False;
    dmCnt.AdoCnt.ConnectionString := CNT_STRING + mmPath.Text;
    dmCnt.AdoCnt.Connected := True;
    frmLogin.ShowModal;
  except
    ShowMessage(MSG_NO_CONNESSIONE_DB);
    Close;
  end;
end;

procedure TfrmMain.ImpostaPermessi(LivelloUtente: string);
begin
  if LivelloUtente = '0' then
  begin
    mmVisualizza.Visible := False;
    mmInserisci.Visible := False;
    mmModifica.Visible := False;
    mmAssocia.Visible := False;
    mmReport.Visible := False;
    mmStrumenti.Visible := False;
  end
  else if LivelloUtente = '1' then
  begin
    mmVisualizza.Visible := True;
    mmVisMagazzino.Visible := True;
    mmVisOrdiniMag.Visible := True;
    mmVisProdottiPersi.Visible := True;
    mmVisProdottiOrdinati.Visible := True;
    mmVisProdRichiestiStudi.Visible := True;
    mmInserisci.Visible := True;
    mmModifica.Visible := True;
    mmAssocia.Visible := True;
    mmReport.Visible := True;
    mmStrumenti.Visible := True;
  end
  else if LivelloUtente = '2' then
  begin
    mmVisualizza.Visible := True;
    mmVisMagazzino.Visible := False;
    mmVisOrdiniMag.Visible := False;
    mmVisProdottiPersi.Visible := False;
    mmVisProdottiOrdinati.Visible := False;
    mmVisProdRichiestiStudi.Visible := False;    
    mmInserisci.Visible := False;
    mmModifica.Visible := False;
    mmAssocia.Visible := False;
    mmReport.Visible := False;
    mmStrumenti.Visible := False;
  end;
end;

procedure TfrmMain.CompattaDB;
var
  DirPrg: string;
  ris: Integer;
begin
  ris := MessageDlg(MSG_DATABASE_COMPATTA, mtWarning, [mbYes, mbNo], 0);
  if ris = mrYes then
  begin
    DirPRG := ExtractFilePath(Application.ExeName);
    mmPath.Lines.LoadFromFile(DirPRG + '\' + NOME_TXT);
    if CompattaDatabase(mmPath.Text) then ShowMessage(MSG_DATABASE_COMPATTATO_SI)
    else ShowMessage(MSG_DATABASE_COMPATTATO_NO);
  end;
end;

{ **************************************************************************** }
{ *** Menu File ************************************************************** }

procedure TfrmMain.mmLoginClick(Sender: TObject);
begin
  frmLogin.ShowModal;
end;

procedure TfrmMain.mmEsciClick(Sender: TObject);
begin
  Close;
end;

{ **************************************************************************** }
{ *** Menu Visualizza ******************************************************** }

procedure TfrmMain.mmDatiPersonaliClick(Sender: TObject);
begin
  frmVisDatiPersonali.ShowModal;
end;

procedure TfrmMain.mmVisCassettiClick(Sender: TObject);
begin
  frmVisCassetti.ShowModal;
end;

procedure TfrmMain.mmVisMagazzinoClick(Sender: TObject);
begin
  frmVisMagazzino.ShowModal;
end;

procedure TfrmMain.mmVisProdottiClick(Sender: TObject);
begin
  frmVisProdottiCassetti.ShowModal;
end;

procedure TfrmMain.mmVisProdottiPersiClick(Sender: TObject);
begin
  frmProdottiPersi.ShowModal;
end;

procedure TfrmMain.mmVisProdottiOrdinatiClick(Sender: TObject);
begin
  frmVisProdottiOrdinati.ShowModal;
end;

procedure TfrmMain.mmVisProdRichiestiStudiClick(Sender: TObject);
begin
  frmVisProdottiRichiestiStudi.ShowModal;
end;

procedure TfrmMain.mmVisOrdiniMagClick(Sender: TObject);
begin
  frmVisOrdiniMag.ShowModal;
end;

{ **************************************************************************** }
{ *** Menu Inserisci ********************************************************* }

procedure TfrmMain.mmInserisciPClick(Sender: TObject);
begin
  frmCreaProdotto.ShowModal;
end;

procedure TfrmMain.mmInserisciUClick(Sender: TObject);
begin
  frmCreaUtente.ShowModal;
end;

procedure TfrmMain.mmInserisciFPClick(Sender: TObject);
begin
  frmCreaFornitore.ShowModal;
end;

procedure TfrmMain.mmInserisciTPClick(Sender: TObject);
begin
  frmCreaTipologiaProdotto.ShowModal;
end;

procedure TfrmMain.mmInserisciSClick(Sender: TObject);
begin
  frmCreaStudio.ShowModal;
end;

procedure TfrmMain.mmInserisciMClick(Sender: TObject);
begin
  frmCreaMobile.ShowModal;
end;

procedure TfrmMain.mmInserisciCClick(Sender: TObject);
begin
  frmCreaCassetto.ShowModal;
end;

{ **************************************************************************** }
{ *** Menu Modifica ********************************************************** }

procedure TfrmMain.mmModificaUClick(Sender: TObject);
begin
  frmAggiornaUtente.ShowModal;
end;

procedure TfrmMain.mmModificaPClick(Sender: TObject);
begin
  frmAggiornaProdotto.ShowModal;
end;

procedure TfrmMain.mmModificaSClick(Sender: TObject);
begin
  frmAggiornaStudio.ShowModal;
end;

procedure TfrmMain.mmModificaMClick(Sender: TObject);
begin
  frmAggiornaMobile.ShowModal;
end;

procedure TfrmMain.mmModificaCClick(Sender: TObject);
begin
  frmAggiornaCassetto.ShowModal;
end;

procedure TfrmMain.mmModificaFPClick(Sender: TObject);
begin
  frmAggiornaFornitore.ShowModal;
end;

procedure TfrmMain.mmModificaTPClick(Sender: TObject);
begin
  frmAggiornaTipologia.ShowModal;
end;

{ **************************************************************************** }
{ *** Menu Associa *********************************************************** }

procedure TfrmMain.mmUtentiCassettiClick(Sender: TObject);
begin
  frmAssociaUtentiCassetti.ShowModal;
end;

procedure TfrmMain.mmProdottiCassettiClick(Sender: TObject);
begin
  frmAssociaProdottiCassetti.ShowModal;
end;

procedure TfrmMain.mmAssistentiSostitutiClick(Sender: TObject);
begin
  frmAssociaAssistentiSostituti.ShowModal;
end;

procedure TfrmMain.mmProdottiFornitoriClick(Sender: TObject);
begin
  frmAssociaProdottiFornitori.ShowModal;
end;

{ **************************************************************************** }
{ *** Menu Report ************************************************************ }

procedure TfrmMain.mmProdPerTipologiaClick(Sender: TObject);
begin
  frmProdottiPerTipologia.ShowModal;
end;

procedure TfrmMain.mmProdOrdinatiClick(Sender: TObject);
begin
  frmProdottiOrdinati.ShowModal;
end;

procedure TfrmMain.mmProdSottoSogliaClick(Sender: TObject);
begin
  frmReportProdottiSottoSoglia.AnteprimaReport;
end;

procedure TfrmMain.mmProdPerAssistenteClick(Sender: TObject);
begin
  frmProdottiPerAssistente.ShowModal;
end;

procedure TfrmMain.mmProdottiPersiClick(Sender: TObject);
begin
  frmProdottiPersiSelPagina.ShowModal;
end;

procedure TfrmMain.mmProdRichiestiStudiClick(Sender: TObject);
begin
  frmProdottiRichiestiStudi.ShowModal;
end;

procedure TfrmMain.mmProdottiConsegnatiClick(Sender: TObject);
begin
  frmProdottiConsegnati.ShowModal;
end;

procedure TfrmMain.mmProdottiNonConsegnatiClick(Sender: TObject);
begin
  frmProdottiNonConsegnati.ShowModal;
end;

procedure TfrmMain.mmRifornimentiEmergenzaClick(Sender: TObject);
begin
  frmRifornimentiEmergenza.ShowModal;
end;

{ **************************************************************************** }
{ *** Menu Strumenti ********************************************************* }

procedure TfrmMain.mmCompattaDBClick(Sender: TObject);
begin
  CompattaDB;
end;

{ **************************************************************************** }
{ *** Menu About ************************************************************* }

procedure TfrmMain.mmAboutClick(Sender: TObject);
begin
  frmAbout.ShowModal;
end;

end.
