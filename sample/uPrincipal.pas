unit uPrincipal;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.ComCtrls, Vcl.StdCtrls, Vcl.ExtCtrls, BBCode4D;

type
  TFrmPrincipal = class(TForm)
    pnlBody: TPanel;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    mmoBBCode: TMemo;
    redtBBCode: TRichEdit;
    procedure mmoBBCodeChange(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmPrincipal: TFrmPrincipal;

implementation

{$R *.dfm}

procedure TFrmPrincipal.FormShow(Sender: TObject);
begin
  mmoBBCode.OnChange(nil);
end;

procedure TFrmPrincipal.mmoBBCodeChange(Sender: TObject);
begin
  TBBCode4D.ParseBBCode(mmoBBCode.Lines.Text).WriteToRich(redtBBCode);
end;

end.
