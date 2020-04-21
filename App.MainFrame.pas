unit App.MainFrame;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, ExtDlgs,
  StdCtrls, ExtCtrls;

type
  IMainForm = interface
  ['{5AF57102-EFFE-4E2C-9BB5-11056049FCEE}']
    function GetGlassFooter: Boolean;
    procedure SetGlassFooter(Value: Boolean);
    function GetUseCustomFrame: Boolean;
    procedure SetUseCustomFrame(Value: Boolean);
    property GlassFooter: Boolean read GetGlassFooter write SetGlassFooter;
    property UseCustomFrame: Boolean read GetUseCustomFrame write SetUseCustomFrame;
  end;

  TfraMain = class(TFrame)
    chkEnableCustomFrame: TCheckBox;
    grpBorderIcons: TGroupBox;
    chkSysMenu: TCheckBox;
    chkMinimize: TCheckBox;
    chkMaximize: TCheckBox;
    grpBorderStyle: TGroupBox;
    rdoSingle: TRadioButton;
    rdoSizeable: TRadioButton;
    rdoDialog: TRadioButton;
    rdoToolWindow: TRadioButton;
    rdoSizeableToolWindow: TRadioButton;
    chkGlassFooter: TCheckBox;
    grpIcon: TGroupBox;
    btnResetIcon: TButton;
    btnLoadIcon: TButton;
    dlgLoadIcon: TOpenPictureDialog;
    grpCaption: TGroupBox;
    edtCaption: TEdit;
    procedure chkEnableCustomFrameClick(Sender: TObject);
    procedure chkBorderIconClick(Sender: TObject);
    procedure rdoBorderStyleClick(Sender: TObject);
    procedure chkGlassFooterClick(Sender: TObject);
    procedure btnResetIconClick(Sender: TObject);
    procedure btnLoadIconClick(Sender: TObject);
    procedure edtCaptionChange(Sender: TObject);
  public
    procedure Initialize(SupportsCustomFrame: Boolean);
  end;

implementation

{$R *.dfm}

procedure TfraMain.Initialize(SupportsCustomFrame: Boolean);
var
  Form: TForm;
begin
  Form := Parent as TForm; //Application.MainForm not set yet
  chkEnableCustomFrame.Checked := (Form as IMainForm).UseCustomFrame;
  chkEnableCustomFrame.Enabled := SupportsCustomFrame;
  chkGlassFooter.Checked := (Form as IMainForm).GlassFooter;
  chkGlassFooter.Enabled := SupportsCustomFrame;
  chkSysMenu.Checked := (biSystemMenu in Form.BorderIcons);
  chkMinimize.Checked := (biMinimize in Form.BorderIcons);
  chkMaximize.Checked := (biMaximize in Form.BorderIcons);
  case Form.BorderStyle of
    bsSingle: rdoSingle.Checked := True;
    bsSizeable: rdoSizeable.Checked := True;
    bsDialog: rdoDialog.Checked := True;
    bsToolWindow: rdoToolWindow.Checked := True;
    bsSizeToolWin: rdoSizeableToolWindow.Checked := True;
  else Assert(False);
  end;
  edtCaption.Text := Form.Caption;
end;

procedure TfraMain.rdoBorderStyleClick(Sender: TObject);
begin
  if Application.MainForm = nil then Exit;
  if Sender = rdoSingle then
    Application.MainForm.BorderStyle := bsSingle
  else if Sender = rdoSizeable then
    Application.MainForm.BorderStyle := bsSizeable
  else if Sender = rdoDialog then
    Application.MainForm.BorderStyle := bsDialog
  else if Sender = rdoToolWindow then
    Application.MainForm.BorderStyle := bsToolWindow
  else
    Application.MainForm.BorderStyle := bsSizeToolWin;
end;

procedure TfraMain.btnLoadIconClick(Sender: TObject);
begin
  if dlgLoadIcon.Execute then
  begin
    Application.MainForm.Icon.LoadFromFile(dlgLoadIcon.FileName);
    btnResetIcon.Enabled := True;
  end;
end;

procedure TfraMain.btnResetIconClick(Sender: TObject);
begin
  btnResetIcon.Enabled := False;
  Application.MainForm.Icon.Assign(nil);
end;

procedure TfraMain.chkBorderIconClick(Sender: TObject);
var
  Icon: TBorderIcon;
begin
  if Application.MainForm = nil then Exit;
  if Sender = chkSysMenu then
    Icon := biSystemMenu
  else if Sender = chkMinimize then
    Icon := biMinimize
  else
    Icon := biMaximize;
  if (Sender as TCheckBox).Checked then
    Application.MainForm.BorderIcons := Application.MainForm.BorderIcons + [Icon]
  else
    Application.MainForm.BorderIcons := Application.MainForm.BorderIcons - [Icon];
end;

procedure TfraMain.chkEnableCustomFrameClick(Sender: TObject);
begin
  (Parent as IMainForm).UseCustomFrame := chkEnableCustomFrame.Checked;
end;

procedure TfraMain.chkGlassFooterClick(Sender: TObject);
begin
  (Parent as IMainForm).GlassFooter := chkGlassFooter.Checked;
end;

procedure TfraMain.edtCaptionChange(Sender: TObject);
begin
  if Application.MainForm <> nil then Application.MainForm.Caption := edtCaption.Text;
end;

end.
