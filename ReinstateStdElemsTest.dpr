program ReinstateStdElemsTest;

uses
  Forms,
  App.MainFrame in 'App.MainFrame.pas' {fraMain: TFrame},
  App.MainForm in 'App.MainForm.pas' {frmMain},
  App.DwmUtils in 'App.DwmUtils.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
