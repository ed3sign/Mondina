unit UReportProdottiConsegnati;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, ADODB, QRCtrls, grimgctrl, QuickRpt, ExtCtrls, QRExport,
  QRPDFFilt;

type
  TfrmReportProdottiConsegnati = class(TForm)
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
    procedure AnteprimaReport(Anno: string);
  end;

var
  frmReportProdottiConsegnati: TfrmReportProdottiConsegnati;

implementation

{$R *.dfm}

{ TfrmReportMagazzino4 }


{ **************************************************************************** }
{ *** Gestione *************************************************************** }

procedure TfrmReportProdottiConsegnati.AnteprimaReport(Anno: string);
begin
  qrProdotti.SQL.Text := 'SELECT [OrdiniMagazzino].[NomeProdotto], [OrdiniMagazzino].[Fornitore], [OrdiniMagazzino].[CostoUnitario]  ' +
                         ' FROM [OrdiniMagazzino] ' +
                         ' WHERE [OrdiniMagazzino].[Consegnato] = ''Consegnato'' AND [OrdiniMagazzino].[Anno]=' + Anno +
                         ' ORDER BY [OrdiniMagazzino].[NomeProdotto], [OrdiniMagazzino].[CostoUnitario];';

  qrProdotti.Active := True;
  lblInfo1.Caption := 'Prodotti Ordinati - ' + Anno;
  qrReport.PreviewModal;
  qrProdotti.Active := False;
end;


end.
