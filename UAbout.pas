unit UAbout;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

type
  TfrmAbout = class(TForm)
    btnOK: TButton;
    img1: TImage;
    gbInfo: TGroupBox;
    lblInfo2: TLabel;
    lblTitolo: TLabel;
    Label1: TLabel;
    procedure btnOKClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmAbout: TfrmAbout;

implementation

{$R *.dfm}

{ **************************************************************************** }
{ *** Componenti ************************************************************* }

procedure TfrmAbout.btnOKClick(Sender: TObject);
begin
  Close;
end;

end.
