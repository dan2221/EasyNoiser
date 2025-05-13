unit Unit2;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Buttons,
  ExtCtrls, LCLIntf;

type

  { TForm3 }

  TForm3 = class(TForm)
    BitBtn1: TBitBtn;
    Label1: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    LabelPy: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    LabelLinkVampyre: TLabel;
    LabelLinkVampyre1: TLabel;
    LabelTitle2: TLabel;
    procedure BitBtn1Click(Sender: TObject);
    procedure LabelLinkVampyreClick(Sender: TObject);
    procedure LabelPyClick(Sender: TObject);
  private

  public

  end;

var
  Form3: TForm3;

implementation

{$R *.lfm}

{ TForm3 }

procedure TForm3.BitBtn1Click(Sender: TObject);
begin
  OpenURL('https://www.youtube.com/channel/UCvWEo-Qj_iOsRTsz4KqP_lA');
end;

procedure TForm3.LabelLinkVampyreClick(Sender: TObject);
begin
  OpenURL('https://imaginglib.sourceforge.io/index.php');
end;

procedure TForm3.LabelPyClick(Sender: TObject);
begin
  OpenURL('https://pyinstaller.org/en/stable/');
end;

end.

