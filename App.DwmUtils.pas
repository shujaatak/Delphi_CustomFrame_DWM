unit App.DwmUtils;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, ImgList, Controls, Forms, StdCtrls,
  ExtCtrls, ComCtrls;

type
{$IF not Declared(UnicodeString)}
  UnicodeString = WideString;
{$IFEND}

  TImageListAddIconFixer = class helper for TCustomImageList
  public
    function AddIcon(Image: TIcon): Integer; //remove the size checking, given TIcon isn't
  end;                                       //necessarily accurate, and the API will resize anyway

procedure AddFormIconToImageList(Form: TForm; ImageList: TCustomImageList);
function Create32BitImageList(Owner: TComponent; Width, Height: Integer;
  AllocBy: Integer = 4): TImageList;

procedure DrawGlassCaption(Form: TForm; const Text: UnicodeString;
  var R: TRect; UseStdFont: Boolean; HorzAlignment: TAlignment = taLeftJustify;
  VertAlignment: TTextLayout = tlCenter; ShowAccel: Boolean = False); overload;
procedure DrawGlassCaption(Form: TForm; var R: TRect; UseStdFont: Boolean = True;
  HorzAlignment: TAlignment = taLeftJustify; VertAlignment: TTextLayout = tlCenter;
  ShowAccel: Boolean = False); overload;

procedure EnableAppropriateDoubleBuffering(Control: TWinControl);

function IsVista: Boolean; inline; //useful for deciding what caption colour to use when maximised

function FormsHaveCompatibilityCoords: Boolean;
function GetDwmBorderIconsRect(Form: TForm): TRect;
function GetRealWindowRect(Handle: HWND; var R: TRect): Boolean;
procedure ShowSystemMenu(Form: TForm; const Message: TWMNCRButtonUp);

implementation

{$J+}

uses CommCtrl, DwmApi, ImageHlp, UxTheme, Math, Themes;

type
  TImageListAccess = class(TCustomImageList);

procedure AddFormIconToImageList(Form: TForm; ImageList: TCustomImageList);
var
  IconHandle: HICON;
begin
  if not Form.Icon.Empty then
    IconHandle := Form.Icon.Handle
  else
    IconHandle := Application.Icon.Handle;
  IconHandle := CopyImage(IconHandle, IMAGE_ICON, ImageList.Width, ImageList.Height,
    LR_COPYFROMRESOURCE);
  ImageList_AddIcon(ImageList.Handle, IconHandle); //avoid VCL verifying the icon size
  DestroyIcon(IconHandle);
  TImageListAccess(ImageList).Change;
end;

function Create32BitImageList(Owner: TComponent; Width, Height: Integer;
  AllocBy: Integer = 4): TImageList;
begin
  Result := TImageList.Create(Owner);
  Result.AllocBy := AllocBy;
  Result.Width := Width;
  Result.Height := Height;
  if GetComCtlVersion < ComCtlVersionIE6 then Exit;
  {$IF DECLARED(cd32Bit)}
  Result.ColorDepth := cd32Bit;
  {$ELSE}
  Result.Handle := ImageList_Create(Width, Height, ILC_COLOR32 or ILC_MASK,
    AllocBy, AllocBy)
  {$IFEND}
end;

procedure DrawGlassCaption(Form: TForm; const Text: UnicodeString; var R: TRect;
  UseStdFont: Boolean; HorzAlignment: TAlignment; VertAlignment: TTextLayout;
  ShowAccel: Boolean);
const
  BasicFormat = DT_SINGLELINE or DT_END_ELLIPSIS;
  HorzFormat: array[TAlignment] of UINT = (DT_LEFT, DT_RIGHT, DT_CENTER);
  VertFormat: array[TTextLayout] of UINT = (DT_TOP, DT_VCENTER, DT_BOTTOM);
  AccelFormat: array[Boolean] of UINT = (DT_NOPREFIX, 0);
var
  DTTOpts: TDTTOpts;            { This routine doesn't use GetThemeSysFont and          }
  Element: TThemedWindow;       { GetThemeSysColor because they just return theme       }
  IsVistaAndMaximized: Boolean; { defaults that will be overridden by the 'traditional' }
  NCM: TNonClientMetrics;       { settings as and when the latter are set by the user.  }
  ThemeData: HTHEME;

  procedure DoTextOut;
  begin
    with ThemeServices.GetElementDetails(Element) do
      DrawThemeTextEx(ThemeData, Form.Canvas.Handle, Part, State, PWideChar(Text),
        Length(Text), BasicFormat or AccelFormat[ShowAccel] or HorzFormat[HorzAlignment] or
          VertFormat[VertAlignment], @R, DTTOpts);
  end;
begin
  IsVistaAndMaximized := IsVista and (Form.WindowState = wsMaximized);
  ThemeData := OpenThemeData(0, 'CompositedWindow::Window');
  Assert(ThemeData <> 0, SysErrorMessage(GetLastError));
  try
    if UseStdFont then
    begin
      NCM.cbSize := SizeOf(NCM);
      if SystemParametersInfo(SPI_GETNONCLIENTMETRICS, 0, @NCM, 0) then
        if Form.BorderStyle in [bsToolWindow, bsSizeToolWin] then
          Form.Canvas.Font.Handle := CreateFontIndirect(NCM.lfSmCaptionFont)
        else
          Form.Canvas.Font.Handle := CreateFontIndirect(NCM.lfCaptionFont);
    end;
    ZeroMemory(@DTTOpts, SizeOf(DTTOpts));
    DTTOpts.dwSize := SizeOf(DTTOpts);
    DTTOpts.dwFlags := DTT_COMPOSITED or DTT_TEXTCOLOR;
    if not UseStdFont then
      DTTOpts.crText := ColorToRGB(Form.Canvas.Font.Color)
    else if IsVistaAndMaximized then
      DTTOpts.dwFlags := DTTOpts.dwFlags and not DTT_TEXTCOLOR
    else if Form.Active then
      DTTOpts.crText := GetSysColor(COLOR_CAPTIONTEXT)
    else
      DTTOpts.crText := GetSysColor(COLOR_INACTIVECAPTIONTEXT); 
    if not IsVistaAndMaximized then
    begin
      DTTOpts.dwFlags := DTTOpts.dwFlags or DTT_GLOWSIZE;
      DTTOpts.iGlowSize := 15;
    end;
    if Form.WindowState = wsMaximized then
      if Form.Active then
        Element := twMaxCaptionActive
      else
        Element := twMaxCaptionInactive
    else if Form.BorderStyle in [bsToolWindow, bsSizeToolWin] then
      if Form.Active then
        Element := twSmallCaptionActive
      else
        Element := twSmallCaptionInactive
    else
      if Form.Active then
        Element := twCaptionActive
      else
        Element := twCaptionInactive;
    DoTextOut;
    if IsVistaAndMaximized then DoTextOut;
  finally
    CloseThemeData(ThemeData);
  end;
end;

procedure DrawGlassCaption(Form: TForm; var R: TRect; UseStdFont: Boolean;
  HorzAlignment: TAlignment; VertAlignment: TTextLayout; ShowAccel: Boolean);
begin
  DrawGlassCaption(Form, Form.Caption, R, UseStdFont, HorzAlignment, VertAlignment,
    ShowAccel);
end;

type
  TWinControlAccess = class(TWinControl);

  TToolBarFixer = class
  strict private
    class procedure CustomDrawHandler(ToolBar: TToolBar; const ARect: TRect;
      var DefaultDraw: Boolean);
  public
    class procedure Fix(ToolBar: TToolBar); static;
  end;

class procedure TToolBarFixer.CustomDrawHandler(ToolBar: TToolBar; const ARect: TRect;
  var DefaultDraw: Boolean);
begin
  ToolBar.Canvas.FillRect(ARect);
end;

class procedure TToolBarFixer.Fix(ToolBar: TToolBar);
begin
  if not (ToolBar.Parent is TPanel) and not Assigned(ToolBar.OnCustomDraw) and
    ((ToolBar.DrawingStyle = dsNormal) or not (gdoGradient in ToolBar.GradientDrawingOptions)) then
    ToolBar.OnCustomDraw := TToolBarFixer.CustomDrawHandler;
end;

function IsAppropriateToDoubleBuffer(Control: TWinControl): Boolean;
  function WithinGlassRange: Boolean;
  var
    R: TRect;
  begin
    if not (Control.Parent is TCustomForm) then
      Result := False
    else
    begin
      R := Control.Parent.ClientRect;
      with TCustomForm(Control.Parent).GlassFrame do
      begin
        Inc(R.Left, Left);
        Inc(R.Top, Top);
        Dec(R.Right, Right);
        Dec(R.Bottom, Bottom);
      end;
      Result := (Control.Left < R.Left) or (Control.Top < R.Top) or
        (Control.Left + Control.Width > R.Right) or
        (Control.Top + Control.Height > R.Bottom);
    end;
  end;
begin
  if (Control is TCustomRichEdit) then
    Result := False
  else if Control is TButtonControl then
    Result := WithinGlassRange //double buffering kills the fade in/out animation, so only enable it if we have to
  else if Control is TToolBar then
  begin
    TToolBarFixer.Fix(TToolBar(Control));
    Result := WithinGlassRange;
  end
  else
  begin
    Result := True;
    if Control is TCustomGroupBox then
    begin
      TWinControlAccess(Control).ParentBackground := False;
      if not (csAcceptsControls in Control.ControlStyle) then
      begin //get WS_CLIPCHILDREN window style set to avoid flicker
        Control.ControlStyle := Control.ControlStyle + [csAcceptsControls];
        if Control.HandleAllocated then Control.Perform(CM_RECREATEWND, 0, 0)
      end;
    end;
  end;
end;

procedure EnableAppropriateDoubleBuffering(Control: TWinControl);
{$IF CompilerVersion = 18.5}
var
  I: Integer;
begin
  if not IsAppropriateToDoubleBuffer(Control) then Exit;
  Control.DoubleBuffered := True;
  for I := Control.ControlCount - 1 downto 0 do
    if Control.Controls[I] is TWinControl then
      EnableAppropriateDoubleBuffering(TWinControl(Control.Controls[I]));
end;
{$ELSE}
  procedure CheckChildControls(Parent: TWinControl);
  var
    I: Integer;
    Child: TWinControl;
  begin
    for I := Parent.ControlCount - 1 downto 0 do
      if Parent.Controls[I] is TWinControl then
      begin
        Child := TWinControl(Parent.Controls[I]);
        if Child.ParentDoubleBuffered then
          if IsAppropriateToDoubleBuffer(Child) then
            CheckChildControls(Child)
          else
            Child.DoubleBuffered := False;
      end;
  end;
begin
  Control.DoubleBuffered := IsAppropriateToDoubleBuffer(Control);
  if Control.DoubleBuffered then CheckChildControls(Control);
end;
{$IFEND}

function FormsHaveCompatibilityCoords: Boolean;
const
  Value: (DontKnow, No, Yes) = DontKnow;
var
  Image: PloadedImage;
begin
  if Value = DontKnow then
    if Win32MajorVersion < 6 then
      Value := No
    else
    begin
      Image := ImageLoad(PAnsiChar(AnsiString(GetModuleName(MainInstance))), '');
      if Image = nil then RaiseLastOSError;
      if Image.FileHeader.OptionalHeader.MajorSubsystemVersion >= 6 then
        Value := No
      else
        Value := Yes;
      ImageUnload(Image);
    end;
  Result := (Value = Yes) and DwmCompositionEnabled;
end;

function InternalGetDwmBorderIconsRect(Form: TForm): TRect; inline
begin
  if DwmGetWindowAttribute(Form.Handle, DWMWA_CAPTION_BUTTON_BOUNDS, @Result,
    SizeOf(Result)) <> S_OK then SetRectEmpty(Result);
end;

function GetDwmBorderIconsRect(Form: TForm): TRect;
begin
  if Win32MajorVersion >= 6 then
    Result := InternalGetDwmBorderIconsRect(Form)
  else
    SetRectEmpty(Result);
end;

function GetRealWindowRect(Handle: HWND; var R: TRect): Boolean;
begin
  Result := (GetParent(Handle) = 0) and DwmCompositionEnabled and
    (DwmGetWindowAttribute(Handle, DWMWA_EXTENDED_FRAME_BOUNDS, @R, SizeOf(R)) = S_OK);
  if not Result then
    Result := GetWindowRect(Handle, R);
end;

function IsVista: Boolean; inline;
begin
  Result := (Win32MajorVersion = 6) and (Win32MinorVersion = 0);
end;

{ No idea why we have to initialise the menu ourselves, or indeed, why we have to show
  the thing manually in the first place, given WM_NCHITTEST is properly handled. That
  said, this routine also sets the correct 'default' (i.e., bold) item, which Vista
  doesn't bother doing properly even with standard window frames. }

procedure ShowSystemMenu(Form: TForm; const Message: TWMNCRButtonUp);
var
  Cmd: WPARAM;
  Menu: HMENU;

  procedure UpdateItem(ID: UINT; Enable: Boolean; MakeDefaultIfEnabled: Boolean = False);
  const
    Flags: array[Boolean] of UINT = (MF_GRAYED, MF_ENABLED);
  begin
    EnableMenuItem(Menu, ID, MF_BYCOMMAND or Flags[Enable]);
    if MakeDefaultIfEnabled and Enable then
      SetMenuDefaultItem(Menu, ID, MF_BYCOMMAND);
  end;
begin
  Menu := GetSystemMenu(Form.Handle, False);
  if Form.BorderStyle in [bsSingle, bsSizeable, bsToolWindow, bsSizeToolWin] then
  begin
    SetMenuDefaultItem(Menu, UINT(-1), 0);
    UpdateItem(SC_RESTORE, Form.WindowState <> wsNormal, True);
    UpdateItem(SC_MOVE, Form.WindowState <> wsMaximized);
    UpdateItem(SC_SIZE, (Form.WindowState <> wsMaximized) and
      (Form.BorderStyle in [bsSizeable, bsSizeToolWin]));
    UpdateItem(SC_MINIMIZE, (biMinimize in Form.BorderIcons) and
      (Form.BorderStyle in [bsSingle, bsSizeable]));
    UpdateItem(SC_MAXIMIZE, (biMaximize in Form.BorderIcons) and
      (Form.BorderStyle in [bsSingle, bsSizeable]) and
      (Form.WindowState <> wsMaximized), True);
  end;
  if Message.HitTest = HTSYSMENU then
    SetMenuDefaultItem(Menu, SC_CLOSE, MF_BYCOMMAND);
  Cmd := WPARAM(TrackPopupMenu(Menu, TPM_RETURNCMD or GetSystemMetrics(SM_MENUDROPALIGNMENT),
    Message.XCursor, Message.YCursor, 0, Form.Handle, nil));
  PostMessage(Form.Handle, WM_SYSCOMMAND, Cmd, 0)
end;

{ TImageListAddIconFixer }

function TImageListAddIconFixer.AddIcon(Image: TIcon): Integer;
begin
  if Image = nil then
    Result := Add(nil, nil)
  else
  begin
    Result := ImageList_AddIcon(Handle, Image.Handle);
    Change;
  end;
end;

end.
