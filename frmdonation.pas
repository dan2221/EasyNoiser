unit frmDonation;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, LCLIntf, Clipbrd;

type

  { TfrmDonation }

  TfrmDonation = class(TForm)
    btnClipboard: TButton;
    Edit1: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    KofiLink: TLabel;
    Label5: TLabel;
    superthanksLink: TLabel;
    paypalLink: TLabel;
    procedure btnClipboardClick(Sender: TObject);
    procedure KofiLinkClick(Sender: TObject);
    procedure paypalLinkClick(Sender: TObject);
    procedure superthanksLinkClick(Sender: TObject);
  private

  public

  end;

var
  formDonation: TfrmDonation;

implementation

{$R *.lfm}

{ TfrmDonation }

procedure TfrmDonation.KofiLinkClick(Sender: TObject);
begin
  OpenURL('https://ko-fi.com/danchavyn');
end;

procedure TfrmDonation.btnClipboardClick(Sender: TObject);
begin
  Clipboard.AsText := '888a0f24-fc77-4105-b8ea-e1f919849c4f';
end;

procedure TfrmDonation.paypalLinkClick(Sender: TObject);
begin
  OpenURL('https://www.paypal.com/donate/?hosted_button_id=RK8T3UG4T2LCU');
end;

procedure TfrmDonation.superthanksLinkClick(Sender: TObject);
begin
  OpenURL('https://www.youtube.com/playlist?list=PLa-mXLTenBmKFWyTz2OeIF-b6gNuYOWzw');
end;

end.

