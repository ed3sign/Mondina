unit UMessaggi;

interface

uses Dialogs;

const
  MSG_INSERIRE_DATI = 'Inserire i dati richiesti.';
  MSG_NO_CONNESSIONE_DB = 'Connessione al Database non avvenuta con successo.';
  MSG_ERRORE_SCRITTURA_DB = 'Errore di scrittura nel Database.';
  MSG_CAMPI_PSW = 'I campi password devono coincidere.';
  MSG_NO_LOGIN = 'Username o password errati.';
  MSG_QTAMAX_SUPERATA = 'Inserimento errato. Non puoi superare la quantità massima.';
  MSG_PSW_MODIFICATA = 'Password modificata';


  MSG_ELIMINA_PRODOTTO = 'Vuoi eliminare il prodotto dal cassetto?';
  MSG_ELIMINA_RECORD = 'Vuoi eliminare il record selezionato?';
  MSG_ELIMINA_PRODOTTI_ORDINATI_TUTTI = 'Vuoi eliminare tutti i prodotti ordinati?';
  MSG_ELIMINA_PRODOTTI_ORDINATI_ANNO = 'Vuoi eliminare i prodotti ordinati dell''anno selezionato?';
  MSG_ELIMINA_PRODOTTI_RICHIESTI_TUTTI = 'Vuoi eliminare tutti i prodotti richiesti dagli studi?';
  MSG_ELIMINA_PRODOTTI_RICHIESTI_ANNO = 'Vuoi eliminare i prodotti richiesti dagli studi dell''anno selezionato?';
  MSG_ELIMINA_PRODOTTI_PERSI = 'Vuoi eliminare tutti i prodotti persi?';

  MSG_CASSETTO_ESISTENTE = 'Cassetto già inserito in lista';
  MSG_PRODOTTO_ESISTENTE = 'Prodotto già inserito in lista';

  MSG_USERNAME_ESISTENTE = 'Username esistente. Inserire un altro username.';
  MSG_COD_FORNITORE_ESISTENTE = 'Fornitore esistente. Inserire un altro fornitore.';
  MSG_COD_TIPOLOGIA_ESISTENTE = 'Tipologia esistente. Inserire un''altra tipologia.';
  MSG_COD_STUDIO_ESISTENTE = 'Codice studio esistente. Inserire un altro codice studio.';
  MSG_COD_MOBILE_ESISTENTE = 'Codice mobile esistente. Inserire un altro codice mobile.';
  MSG_COD_CASSETTO_ESISTENTE = 'Codice cassetto esistente. Inserire un altro codice cassetto.';

  MSG_UTENTE_ASSOCIATO_ELIMINA = 'L''utente selezionato è associato ad assistenti - sostituti e/o a prodotti persi. Impossibile eliminarlo.';
  MSG_UTENTE_ASSOCIATO_MODIFICA = 'L''utente selezionato è associato ad assistenti - sostituti. Impossibile modificare il livello.';
  MSG_UTENTE_ASSOCIATO_SOSTITUISCI = 'Il secondo utente selezionato è associato a assistenti - sostituti. Impossibile effettuare la sostituzione.';

  MSG_PRODOTTO_COLLEGATO = 'Il prodotto selezionato è collegato a dei cassetti o è richiesto da uno studio. Impossibile eliminarlo.';
  MSG_STUDIO_COLLEGATO = 'Lo studio selezionato è collegato a dei mobili. Impossibile eliminarlo.';
  MSG_FORNITORE_COLLEGATO = 'Il fornitore selezionato è collegato a dei prodotti. Impossibile eliminarlo.';
  MSG_TIPOLOGIA_COLLEGATA = 'La tipologia selezionata è collegata a dei prodotti. Impossibile eliminarla.';
  MSG_MOBILE_COLLEGATO = 'Il mobile selezionato è collegato a degli studi. Impossibile eliminarlo.';
  MSG_CASSETTO_COLLEGATO = 'Il cassetto selezionato è collegato a degli utenti e/o a dei prodotti. Impossibile eliminarlo.';
  MSG_ASSOCIAZIONE_COLLEGATA = 'L''associazione selezionata è collegata a dei cassetti o a dei prodotti richiesti. Impossibile eliminarla.';

  MSG_SELEZIONARE_ANNO = 'Selezionare un anno.';
  MSG_SELEZIONARE_STUDIO = 'Selezionare uno studio.';  
  MSG_SELEZIONARE_PAGINA = 'Selezionare una pagina.';

  MSG_DATABASE_COMPATTA = 'Chiudere ogni applicazione Magazzino aperta. Vuoi compattare il Database?';
  MSG_DATABASE_COMPATTATO_SI = 'Database compattato correttamente.';
  MSG_DATABASE_COMPATTATO_NO = 'Database non compattato correttamente.';

  MSG_PRODOTTI_ORDINATI_ELIMINATI = 'I prodotti ordinati dell''anno selezionato sono stati eliminati.';
  MSG_PRODOTTI_RICHIESTI_ELIMINATI = 'I prodotti richiesti dagli studi dell''anno selezionato sono stati eliminati.';
  MSG_PRODOTTO_PERSO_INSERITO = 'Prodotto perso inserito correttamente.';
  MSG_PREZZI_UNITARI_CALCOLATI = 'Prezzi unitari calcolati correttamente.';
  
procedure ShowMessage(Msg: string);

implementation

procedure ShowMessage(Msg: string);
begin
  MessageDlg(Msg, mtWarning, [mbOK], 0);
end;

end.
