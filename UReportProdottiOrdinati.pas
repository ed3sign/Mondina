unit UReportProdottiOrdinati;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, ADODB, QRCtrls, grimgctrl, QuickRpt, ExtCtrls, QRExport,
  QRPDFFilt;

type
  TfrmReportProdottiOrdinati = class(TForm)
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
  private
    { Private declarations }
  public
    { Public declarations }
    procedure AnteprimaReport(Anno: string);
  end;

var
  frmReportProdottiOrdinati: TfrmReportProdottiOrdinati;

implementation

{$R *.dfm}

{ TfrmReportMagazzino4 }


{ **************************************************************************** }
{ *** Gestione *************************************************************** }

procedure TfrmReportProdottiOrdinati.AnteprimaReport(Anno:string);
begin
  qrProdotti.SQL.Text := 'SELECT [Prodotti].[Nome], [Prodotti_Ordinati].[QtaOrdinata], ' +
                         ' FROM [Prodotti] INNER JOIN [Prodotti_Ordinati] ' +
                              'ON [Prodotti].[Codice] = [Prodotti_Ordinati].[CodProdotto] ' +
                         ' WHERE [Prodotti_Ordinati].[Anno] = ' + Anno + ' ' +
                         ' ORDER BY [Prodotti].[Nome]';
  ShowMessage(qrProdotti.SQL.Text);
  qrProdotti.Active := True;
  lblInfo1.Caption := 'Prodotti Ordinati - ' + Anno;
  qrReport.PreviewModal;
  qrProdotti.Active := False;
end;

end.
