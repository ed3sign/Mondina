unit UReportProdottiNonConsegnati;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, ADODB, QRCtrls, grimgctrl, QuickRpt, ExtCtrls, QRExport,
  QRPDFFilt;

type
  TfrmReportProdottiNonConsegnati = class(TForm)
    qrReport: TQuickRep;
    qrbTitolo: TQRBand;
    lblInfo1: TQRLabel;
    lblInfo2: TQRLabel;
    qrbDettagli: TQRBand;
    lblNome: TQRDBText;
    qrProdotti: TADOQuery;
    QRSysData1: TQRSysData;
    QRTextFilter1: TQRTextFilter;
  private
    { Private declarations }
  public
    { Public declarations }
    procedure AnteprimaReport(Anno, Fornitore: string);
  end;

var
  frmReportProdottiNonConsegnati: TfrmReportProdottiNonConsegnati;

implementation

{$R *.dfm}

{ TfrmReportMagazzino4 }


{ **************************************************************************** }
{ *** Gestione *************************************************************** }

procedure TfrmReportProdottiNonConsegnati.AnteprimaReport(Anno, Fornitore: string);
begin
  qrProdotti.SQL.Text := 'SELECT [OrdiniMagazzino].[NomeProdotto], [OrdiniMagazzino].[qtaOrdinata] ' +
                         ' FROM [OrdiniMagazzino] ' +
                         ' WHERE [OrdiniMagazzino].[Consegnato] = ''Non Consegnato'' AND [OrdiniMagazzino].[Fornitore]="' + Fornitore + '"' + 
                         ' AND [OrdiniMagazzino].[Anno] = ' + Anno +
                         ' ORDER BY [OrdiniMagazzino].[NomeProdotto], [OrdiniMagazzino].[qtaOrdinata];';

  //ShowMessage( qrProdotti.SQL.Text);
  qrProdotti.Active := True;
  lblInfo1.Caption := 'Prodotti Non Consegnati - Fornitore ' + Fornitore;
  qrReport.PreviewModal;
  qrProdotti.Active := False;
end;


end.
