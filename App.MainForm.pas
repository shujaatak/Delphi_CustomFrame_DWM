unit App.MainForm;
{
  Demonstrates how to set up drawing on a DWM title bar. For the actual drawing, the
  demo 'just' reinstates the default UI elements (namely the icon and caption).
  Requires D2007 or later; see Readme.txt for commentary.

  Chris Rolliston, April 2010/January 2011 (added a few fixes).
}
interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Buttons,
  StdCtrls, ExtCtrls, App.MainFrame;

type
  TfrmMain = class(TForm, IMainForm)
    ClientFrame: TfraMain;
    btnClose: TSpeedButton;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    SpeedButton3: TSpeedButton;
    procedure FormActivate(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
  strict private
    FDwmBorderIconsRect: TRect;
    FGlassFooter: Boolean;
    FOldIconChangeHandler: TNotifyEvent;
    FSysIconImageList: TImageList;
    FUseCustomFrame: Boolean;
    FWndFrameSize: Integer;
    function GetSysIconRect: TRect;
    procedure IconChanged(Sender: TObject);
    procedure InvalidateCustomTitleBar;
    procedure RecalcGlassFrameBounds(UpdateFrame: Boolean = True);
  protected
    procedure AdjustClientRect(var Rect: TRect); override; //make sub-ctrls' Align property work in light of our having to zero out the top part of the non-client area
    procedure Paint; override;
    procedure PaintWindow(DC: HDC); override;
    procedure Resize; override;
    procedure CMTextChanged(var Message: TMessage); message CM_TEXTCHANGED;
    procedure WMActivate(var Message: TWMActivate); message WM_ACTIVATE;
    procedure WMNCCalcSize(var Message: TWMNCCalcSize); message WM_NCCALCSIZE;
    procedure WMNCHitTest(var Message: TWMNCHitTest); message WM_NCHITTEST;
    procedure WMNCRButtonUp(var Message: TWMNCRButtonUp); message WM_NCRBUTTONUP;
    procedure WMSetIcon(var Message: TWMSetIcon); message WM_SETICON;
    procedure WMWindowPosChanging(var Message: TWMWindowPosChanging);
      message WM_WINDOWPOSCHANGING;
    procedure WMWindowPosChanged(var Message: TWMWindowPosChanged);
      message WM_WINDOWPOSCHANGED;
    procedure WndProc(var Message: TMessage); override;
    { IMainForm }
    function GetGlassFooter: Boolean;
    procedure SetGlassFooter(Value: Boolean);
    function GetUseCustomFrame: Boolean;
    procedure SetUseCustomFrame(Value: Boolean);
  public
    constructor Create(AOwner: TComponent); override;
    property UseCustomFrame: Boolean read FUseCustomFrame write SetUseCustomFrame;
  end;

var
  frmMain: TfrmMain;

implementation

uses CommCtrl, DwmApi, UxTheme, App.DwmUtils;

{$R *.dfm}

constructor TfrmMain.Create(AOwner: TComponent);
begin
  inherited;
  ReportMemoryLeaksOnShutdown := True;
  EnableAppropriateDoubleBuffering(Self);
  SetUseCustomFrame(DwmCompositionEnabled);
  ClientFrame.Initialize(FUseCustomFrame);
  FOldIconChangeHandler := Icon.OnChange;
  Icon.OnChange := IconChanged;
end;

procedure TfrmMain.AdjustClientRect(var Rect: TRect);
begin
  inherited;
  if FUseCustomFrame then Inc(Rect.Top, GlassFrame.Top);
end;

procedure TfrmMain.CMTextChanged(var Message: TMessage);
begin
  inherited;
  InvalidateCustomTitleBar;
end;

function TfrmMain.GetSysIconRect: TRect;
begin
  if not (biSystemMenu in BorderIcons) or not (BorderStyle in [bsSingle, bsSizeable]) then
    SetRectEmpty(Result)
  else
  begin
    Result.Left := 0;
    Result.Right := GetSystemMetrics(SM_CXSMICON);
    Result.Bottom := GetSystemMetrics(SM_CYSMICON);
    { I'm not quite sure of the precise placing to be honest - what is used below just
      worked for me on Vista and W7 respectively, at both normal and large fonts. }
    if WindowState = wsMaximized then
      if IsVista then
        Result.Top := GlassFrame.Top - Result.Bottom - 2
      else
        Result.Top := GlassFrame.Top - Result.Bottom - 4
    else if IsVista then
      Result.Top := 6 
    else
      Result.Top := 8;
    Inc(Result.Bottom, Result.Top);
  end;
end;

procedure TfrmMain.IconChanged(Sender: TObject);
begin
  FreeAndNil(FSysIconImageList);
  FOldIconChangeHandler(Sender);
end;

procedure TfrmMain.Paint;
var
  R: TRect;
begin
  if FUseCustomFrame then
  begin
    R := GetSysIconRect;
    if not IsRectEmpty(R) then
    begin
      { Drawing the icon via a 32 bit image list ensures it is    }
      { painted correctly, even if the icon itself is not 32 bit. }
      if FSysIconImageList = nil then
      begin
        FSysIconImageList := Create32BitImageList(Self, GetSystemMetrics(SM_CXSMICON),
          GetSystemMetrics(SM_CYSMICON), 1);
        AddFormIconToImageList(Self, FSysIconImageList);
      end;
      R := GetSysIconRect;
      FSysIconImageList.Draw(Canvas, R.Left, R.Top, 0);
      R.Left := R.Right + FWndFrameSize - 3;
    end
    else
      R.Left := 0;
    if WindowState = wsMaximized then
      R.Top := FWndFrameSize
    else
      R.Top := 0;
    R.Right := FDwmBorderIconsRect.Left - FWndFrameSize - 1;
    R.Bottom := GlassFrame.Top;
    DrawGlassCaption(Self, R);
    SelectClipRgn(Canvas.Handle, 0); //just in case we fancy doing something in the client area in an OnPaint handler
  end;
  inherited;
end;

procedure TfrmMain.PaintWindow(DC: HDC);
var
  R: TRect;
begin
  { fix issue of form being painted black when going from wsMinimized to wsMaximized }
  if UseCustomFrame then
  begin
    R := GetClientRect;
    with GlassFrame do
      ExcludeClipRect(DC, Left, Top, R.Right - Right, R.Bottom - Bottom);
  end;
  inherited;
end;

procedure TfrmMain.RecalcGlassFrameBounds(UpdateFrame: Boolean = True);
var
  R: TRect;
begin
  SetRectEmpty(R);
  AdjustWindowRectEx(R, GetWindowLong(Handle, GWL_STYLE), False,
    GetWindowLong(Handle, GWL_EXSTYLE));
  FWndFrameSize := R.Right;
  if FUseCustomFrame then
    GlassFrame.Top := -R.Top
  else
    GlassFrame.Top := 0;
  if FGlassFooter then
    GlassFrame.Bottom := btnClose.Height + FWndFrameSize * 2
  else
    GlassFrame.Bottom := 0;
  if UpdateFrame then
    SetWindowPos(Handle, 0, Left, Top, Width, Height, SWP_FRAMECHANGED);
end;

procedure TfrmMain.Resize;
begin
  if FUseCustomFrame then FDwmBorderIconsRect := GetDwmBorderIconsRect(Self);
  inherited;
end;

procedure TfrmMain.WMActivate(var Message: TWMActivate);
begin
  inherited;
  InvalidateCustomTitleBar; //clInactiveCaptionText may resolve to a different colour than clCaptionText
end;

procedure TfrmMain.WMNCCalcSize(var Message: TWMNCCalcSize);
begin
  if not FUseCustomFrame then
    inherited
  else
    with Message.CalcSize_Params.rgrc[0] do
    begin
      Inc(Left, FWndFrameSize);
      Dec(Right, FWndFrameSize);
      Dec(Bottom, FWndFrameSize);
    end;
end;

procedure TfrmMain.WMNCHitTest(var Message: TWMNCHitTest);
var
  ClientPos: TPoint;
  IconRect: TRect;
begin
  inherited;
  if not UseCustomFrame then Exit;
  case Message.Result of
    HTCLIENT: {to be dealt with below};
    HTMINBUTTON, HTMAXBUTTON, HTCLOSE:
    begin
      Message.Result := HTCAPTION; //slay ghost btns when running on Win64
      Exit;
    end;
  else Exit;
  end;
  ClientPos := ScreenToClient(Point(Message.XPos, Message.YPos));
  if ClientPos.Y > GlassFrame.Top then Exit;
  IconRect := GetSysIconRect;
  if (ClientPos.X < IconRect.Right) and ((WindowState = wsMaximized) or
     ((ClientPos.Y >= IconRect.Top) and (ClientPos.Y < IconRect.Bottom))) then
    Message.Result := HTSYSMENU
  else if ClientPos.Y < FWndFrameSize then
    Message.Result := HTTOP
  else
    Message.Result := HTCAPTION;
end;

procedure TfrmMain.WMNCRButtonUp(var Message: TWMNCRButtonUp);
begin
  if not UseCustomFrame or not (biSystemMenu in BorderIcons) then
    inherited
  else
    case Message.HitTest of
      HTCAPTION, HTSYSMENU: ShowSystemMenu(Self, Message);
    else inherited;
    end;
end;

procedure TfrmMain.WMSetIcon(var Message: TWMSetIcon);
begin
  inherited;
  InvalidateCustomTitleBar;
end;

procedure TfrmMain.WMWindowPosChanging(var Message: TWMWindowPosChanging);
const
  SWP_STATECHANGED = $8000;
begin
  { VCL's default invalidation has wrong assumptions for our use of the GlassFrame property }
  if FUseCustomFrame then
    if (Message.WindowPos.flags and SWP_STATECHANGED) = SWP_STATECHANGED then
      Invalidate
    else
      InvalidateCustomTitleBar;
  inherited;
  { trap changes to the BorderStyle property here in lieu of an overrideable setter }
  if (Message.WindowPos.flags and SWP_FRAMECHANGED <> 0) and FUseCustomFrame and
     (Message.WindowPos.flags <> SWP_FRAMECHANGED) then
    RecalcGlassFrameBounds(False);
end;

procedure TfrmMain.WMWindowPosChanged(var Message: TWMWindowPosChanged);
begin
  inherited;
  if (Message.WindowPos.flags and SWP_FRAMECHANGED <> 0) and FUseCustomFrame then
    Realign;
end;

procedure TfrmMain.WndProc(var Message: TMessage);
begin
  if not FUseCustomFrame or not HandleAllocated or not DwmDefWindowProc(Handle,
    Message.Msg, Message.WParam, Message.LParam, Message.Result) then inherited;
end;

{ IMainForm implementation }

function TfrmMain.GetGlassFooter: Boolean;
begin
  Result := FGlassFooter;
end;

procedure TfrmMain.SetGlassFooter(Value: Boolean);
begin
  if Value = FGlassFooter then Exit;
  FGlassFooter := Value;
  RecalcGlassFrameBounds;
end;

function TfrmMain.GetUseCustomFrame: Boolean;
begin
  Result := FUseCustomFrame;
end;

procedure TfrmMain.SetUseCustomFrame(Value: Boolean);
begin
  if FUseCustomFrame = Value then Exit;
  FUseCustomFrame := Value;
  RecalcGlassFrameBounds;
end;

procedure TfrmMain.InvalidateCustomTitleBar;
var
  R: TRect;
begin
  if not HandleAllocated or not FUseCustomFrame then Exit;
  R.Left := 0;
  R.Top := 0;
  R.Right := Width;
  R.Bottom := GlassFrame.Top;
  InvalidateRect(Handle, @R, False);
end;

{ general event handlers }

procedure TfrmMain.FormActivate(Sender: TObject);
begin
  OnActivate := nil;
  if not DwmCompositionEnabled then
    MessageDlg('Glass is not enabled, so this demo demos precisely nought. All that ' +
      'code for nothing!', mtWarning, [mbOK], 0)
  else if FormsHaveCompatibilityCoords then
    MessageDlg('Since this EXE has not been marked for running on the Vista sub-system ' +
      'or later, only the sizeable border styles are likely to work correctly.', mtWarning, [mbOK], 0)
end;

procedure TfrmMain.btnCloseClick(Sender: TObject);
begin
  Close;
end;

end.
