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
    lblInfo6: TQRLabel;
    lblQtaTotale: TQRDBText;
    lblInfo7: TQRLabel;
    lblSoglia: TQRDBText;
    QRSysData1: TQRSysData;
    QRTextFilter1: TQRTextFilter;
  private
    { Private declarations }
  public
    { Public declarations }
    procedure AnteprimaReport;
  end;

var
  frmReportProdottiConsegnati: TfrmReportProdottiConsegnati;

implementation

uses dmConnection;

{$R *.dfm}

{ TfrmReportMagazzino1 }

{ **************************************************************************** }
{ *** Gestione *************************************************************** }

procedure TfrmReportProdottiConsegnati.AnteprimaReport;
begin
  qrProdotti.SQL.Text := 'SELECT * FROM [Prodotti] ' +
                         'WHERE [QtaTotale] < [Soglia] ' +
                         'ORDER BY [Nome]';

  qrProdotti.Active := True;
  lblInfo1.Caption := 'Prodotti Sotto Soglia - ' + DateToStr(Date);
  qrReport.PreviewModal;
  qrProdotti.Active := False;
end;

end.

