unit UReportEmergenza;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, ADODB, QRCtrls, grimgctrl, QuickRpt, ExtCtrls, QRExport,
  QRPDFFilt;

type
  TfrmReportEmergenza = class(TForm)
    qrReport: TQuickRep;
    qrbTitolo: TQRBand;
    lblInfo1: TQRLabel;
    lblInfo2: TQRLabel;
    lblInfo4: TQRLabel;
    qrbDettagli: TQRBand;
    lblNome: TQRDBText;
    lblQtaOrdinata: TQRDBText;
    qrProdotti: TADOQuery;
    QRSysData1: TQRSysData;
    QRTextFilter1: TQRTextFilter;
    QRLabel1: TQRLabel;
    QRDBText1: TQRDBText;
    QRLabel2: TQRLabel;
    QRDBText3: TQRDBText;
    QRLabel3: TQRLabel;
    Mobile: TQRDBText;
    QRLabel4: TQRLabel;
    QRDBText4: TQRDBText;
  private
    { Private declarations }
  public
    { Public declarations }
    procedure AnteprimaReport(Anno: string);
  end;

var
  frmReportEmergenza: TfrmReportEmergenza;

implementation

{$R *.dfm}

{ TfrmReportMagazzino4 }


{ **************************************************************************** }
{ *** Gestione *************************************************************** }

procedure TfrmReportEmergenza.AnteprimaReport(Anno: string);
begin
   qrProdotti.SQL.Text := 'SELECT [Prodotti].[Nome] AS Prodotto, [RifornimentiEmergenza].[qta], [RifornimentiEmergenza].[Utente], ' +
                          ' [Utenti].[Nome], [RifornimentiEmergenza].[Data], ' +
                          ' [Cassetti].[Codice], [Mobili].[Nome] AS Mobile, [Studi].[Nome] AS Studio FROM [Utenti] ' +
                          ' INNER JOIN ([Prodotti] INNER JOIN (([Studi] INNER JOIN ([Mobili] INNER JOIN [Cassetti] ON [Mobili].[Codice] = [Cassetti].[CodMobile]) ' +
                          ' ON [Studi].[Codice] = [Mobili].[CodStudio]) INNER JOIN [RifornimentiEmergenza] ON [Cassetti].[Codice] = [RifornimentiEmergenza].[Cassetto]) ' +
                          ' ON [Prodotti].[Codice] = [RifornimentiEmergenza].[IdProdotto]) ON [Utenti].[Username] = [RifornimentiEmergenza].[Utente] ' +
                          ' WHERE YEAR([RifornimentiEmergenza].[Data])='+anno+';';


  //ShowMessage(qrProdotti.SQL.Text);
  qrProdotti.Active := True;
  lblInfo1.Caption := 'Rifornimenti d''Emergenza - ' + Anno;
  qrReport.PreviewModal;
  qrProdotti.Active := False;
end;

end.
