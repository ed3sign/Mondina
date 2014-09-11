program Magazzino;

uses
  Forms,
  UMain in 'UMain.pas' {frmMain},
  dmConnection in 'dmConnection.pas' {dmCnt: TDataModule},
  ULogin in 'ULogin.pas' {frmLogin},
  UModAccesso in 'UModAccesso.pas' {frmLoginModAccesso},
  UDatiPersonali in 'UDatiPersonali.pas' {frmVisDatiPersonali},
  UVisCassetti in 'UVisCassetti.pas' {frmVisCassetti},
  UHashTable in 'UHashTable.pas',
  UCreaOrdine in 'UCreaOrdine.pas' {frmCreaOrdine},
  UMessaggi in 'UMessaggi.pas',
  UCreaUtente in 'UCreaUtente.pas' {frmCreaUtente},
  UAbout in 'UAbout.pas' {frmAbout},
  UAssociaUtentiCassetti in 'UAssociaUtentiCassetti.pas' {frmAssociaUtentiCassetti},
  UAssociaProdottiCassetti in 'UAssociaProdottiCassetti.pas' {frmAssociaProdottiCassetti},
  UVisOrdiniMag in 'UVisOrdiniMag.pas' {frmVisOrdiniMag},
  URifornisciCassetti in 'URifornisciCassetti.pas' {frmRifornisciCassetti},
  UCreaFornitore in 'UCreaFornitore.pas' {frmCreaFornitore},
  UCreaTipologiaProdotto in 'UCreaTipologiaProdotto.pas' {frmCreaTipologiaProdotto},
  UCreaStudi in 'UCreaStudi.pas' {frmCreaStudio},
  UCreaMobile in 'UCreaMobile.pas' {frmCreaMobile},
  UCreaCassetto in 'UCreaCassetto.pas' {frmCreaCassetto},
  UAggiornaUtente in 'UAggiornaUtente.pas' {frmAggiornaUtente},
  UAggiornaProdotto in 'UAggiornaProdotto.pas' {frmAggiornaProdotto},
  UAggiornaStudio in 'UAggiornaStudio.pas' {frmAggiornaStudio},
  UAggiornaFornitore in 'UAggiornaFornitore.pas' {frmAggiornaFornitore},
  UAggiornaTipologia in 'UAggiornaTipologia.pas' {frmAggiornaTipologia},
  UAggiornaMobile in 'UAggiornaMobile.pas' {frmAggiornaMobile},
  UAggiornaCassetto in 'UAggiornaCassetto.pas' {frmAggiornaCassetto},
  UVisProdottiPerTipologia in 'UVisProdottiPerTipologia.pas' {frmProdottiPerTipologia},
  UReportProdottiPerTipologia in 'UReportProdottiPerTipologia.pas' {frmReportProdottiPerTipologia},
  UVisProdottiOrdinati in 'UVisProdottiOrdinati.pas' {frmProdottiOrdinati},
  UVisProdottiPerAssistente in 'UVisProdottiPerAssistente.pas' {frmProdottiPerAssistente},
  UReportProdottiPerAssistente in 'UReportProdottiPerAssistente.pas' {frmReportProdottiPerAssistente},
  UAssociaAssistentiSostituti in 'UAssociaAssistentiSostituti.pas' {frmAssociaAssistentiSostituti},
  UCreaAssociazioneAS in 'UCreaAssociazioneAS.pas' {frmCreaAssociazioneAS},
  USostituisciUtente in 'USostituisciUtente.pas' {frmSostituisciUtente},
  UGestioneDatabase in 'UGestioneDatabase.pas',
  UReportProdottiSottoSoglia in 'UReportProdottiSottoSoglia.pas' {frmReportProdottiSottoSoglia},
  UVisProdottiPersi in 'UVisProdottiPersi.pas' {frmProdottiPersi},
  UCreaProdottoPerso in 'UCreaProdottoPerso.pas' {frmCreaProdottoPerso},
  UVisProdottiPersiSelPagina in 'UVisProdottiPersiSelPagina.pas' {frmProdottiPersiSelPagina},
  UReportProdottiPersi in 'UReportProdottiPersi.pas' {frmReportProdottiPersi},
  UVisProdottiCassetti in 'UVisProdottiCassetti.pas' {frmVisProdottiCassetti},
  UProdottiOrdinati in 'UProdottiOrdinati.pas' {frmVisProdottiOrdinati},
  UVisProdottiRichiestiStudi in 'UVisProdottiRichiestiStudi.pas' {frmVisProdottiRichiestiStudi},
  UProdottiRichiestiStudi in 'UProdottiRichiestiStudi.pas' {frmProdottiRichiestiStudi},
  UReportProdottiRichiestiStudi in 'UReportProdottiRichiestiStudi.pas' {frmReportProdottiRichiestiStudi},
  UVisMagazzino in 'UVisMagazzino.pas' {frmVisMagazzino},
  UCreaProdotto in 'UCreaProdotto.pas' {frmCreaProdotto},
  UAssociaProdottiFornitori in 'UAssociaProdottiFornitori.pas' {frmAssociaProdottiFornitori},
  UReportProdottiConsegnati in 'UReportProdottiConsegnati.pas' {frmReportProdottiConsegnati};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmMain, frmMain);
  Application.CreateForm(TdmCnt, dmCnt);
  Application.CreateForm(TfrmLogin, frmLogin);
  Application.CreateForm(TfrmLoginModAccesso, frmLoginModAccesso);
  Application.CreateForm(TfrmVisDatiPersonali, frmVisDatiPersonali);
  Application.CreateForm(TfrmVisCassetti, frmVisCassetti);
  Application.CreateForm(TfrmCreaOrdine, frmCreaOrdine);
  Application.CreateForm(TfrmCreaUtente, frmCreaUtente);
  Application.CreateForm(TfrmAbout, frmAbout);
  Application.CreateForm(TfrmAssociaUtentiCassetti, frmAssociaUtentiCassetti);
  Application.CreateForm(TfrmAssociaProdottiCassetti, frmAssociaProdottiCassetti);
  Application.CreateForm(TfrmVisOrdiniMag, frmVisOrdiniMag);
  Application.CreateForm(TfrmRifornisciCassetti, frmRifornisciCassetti);
  Application.CreateForm(TfrmCreaFornitore, frmCreaFornitore);
  Application.CreateForm(TfrmCreaTipologiaProdotto, frmCreaTipologiaProdotto);
  Application.CreateForm(TfrmCreaStudio, frmCreaStudio);
  Application.CreateForm(TfrmCreaMobile, frmCreaMobile);
  Application.CreateForm(TfrmCreaCassetto, frmCreaCassetto);
  Application.CreateForm(TfrmAggiornaUtente, frmAggiornaUtente);
  Application.CreateForm(TfrmAggiornaProdotto, frmAggiornaProdotto);
  Application.CreateForm(TfrmAggiornaStudio, frmAggiornaStudio);
  Application.CreateForm(TfrmAggiornaFornitore, frmAggiornaFornitore);
  Application.CreateForm(TfrmAggiornaTipologia, frmAggiornaTipologia);
  Application.CreateForm(TfrmAggiornaMobile, frmAggiornaMobile);
  Application.CreateForm(TfrmAggiornaCassetto, frmAggiornaCassetto);
  Application.CreateForm(TfrmProdottiPerTipologia, frmProdottiPerTipologia);
  Application.CreateForm(TfrmReportProdottiPerTipologia, frmReportProdottiPerTipologia);
  Application.CreateForm(TfrmProdottiOrdinati, frmProdottiOrdinati);
  Application.CreateForm(TfrmProdottiPerAssistente, frmProdottiPerAssistente);
  Application.CreateForm(TfrmReportProdottiPerAssistente, frmReportProdottiPerAssistente);
  Application.CreateForm(TfrmAssociaAssistentiSostituti, frmAssociaAssistentiSostituti);
  Application.CreateForm(TfrmCreaAssociazioneAS, frmCreaAssociazioneAS);
  Application.CreateForm(TfrmSostituisciUtente, frmSostituisciUtente);
  Application.CreateForm(TfrmReportProdottiSottoSoglia, frmReportProdottiSottoSoglia);
  Application.CreateForm(TfrmProdottiPersi, frmProdottiPersi);
  Application.CreateForm(TfrmCreaProdottoPerso, frmCreaProdottoPerso);
  Application.CreateForm(TfrmProdottiPersiSelPagina, frmProdottiPersiSelPagina);
  Application.CreateForm(TfrmReportProdottiPersi, frmReportProdottiPersi);
  Application.CreateForm(TfrmVisProdottiCassetti, frmVisProdottiCassetti);
  Application.CreateForm(TfrmVisProdottiOrdinati, frmVisProdottiOrdinati);
  Application.CreateForm(TfrmVisProdottiRichiestiStudi, frmVisProdottiRichiestiStudi);
  Application.CreateForm(TfrmProdottiRichiestiStudi, frmProdottiRichiestiStudi);
  Application.CreateForm(TfrmReportProdottiRichiestiStudi, frmReportProdottiRichiestiStudi);
  Application.CreateForm(TfrmVisMagazzino, frmVisMagazzino);
  Application.CreateForm(TfrmCreaProdotto, frmCreaProdotto);
  Application.CreateForm(TfrmAssociaProdottiFornitori, frmAssociaProdottiFornitori);
  Application.CreateForm(TfrmReportProdottiConsegnati, frmReportProdottiConsegnati);
  Application.Run;
end.

