unit GDPanel;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls;

type
  TResizeOptions = class(TPersistent)
  private
    FCanResize: Boolean;
    FMinWidth: Integer;
    FMinHeight: Integer;
  public
    constructor Create;
  published
    property CanResize: Boolean read FCanResize write FCanResize default False;
    property MinWidth: Integer read FMinWidth write FMinWidth default 100;
    property MinHeight: Integer read FMinHeight write FMinHeight default 100;
  end;

type
  TBorders = (bdNone, bdLeft, bdRight, bdTop, bdBottom);

type
  TGDPanelAlign = (paNone, paLeft, paTop, paRight, paBottom, paClient,
    paCenter);

type
  TGDPanel = class(TPanel)
  private
    FRadius: Integer;
    FMouseDown: Boolean;
    FMousePoint: TPoint;
    FResizeOptions: TResizeOptions;
    FResizingBorder: TBorders;
    FGDPanelAlign: TGDPanelAlign;
    procedure SetGDPanelAlign(Value: TGDPanelAlign);
    procedure SetRadius(const Value: Integer);
    procedure SetResizeOptions(const Value: TResizeOptions);
  protected
    procedure Paint; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure Resize; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property Radius: Integer read FRadius write SetRadius;
    property ResizeOptions: TResizeOptions read FResizeOptions
      write SetResizeOptions;
    property AlignPanel: TGDPanelAlign read FGDPanelAlign write SetGDPanelAlign;
    property Align stored False;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Biblioteca GD', [TGDPanel]);
end;

{ TGDPanel }

constructor TGDPanel.Create(AOwner: TComponent);
begin
  inherited;
  BevelOuter := bvNone;
  BorderStyle := bsNone;
  DoubleBuffered := True;
  ParentBackground := False;
  FRadius := 15;
  FResizeOptions := TResizeOptions.Create;
end;

destructor TGDPanel.Destroy;
begin
  FResizeOptions.Free;
  inherited;
end;

procedure TGDPanel.Resize;
var
  Region: HRGN;
begin
  inherited;
  Region := CreateRoundRectRgn(0, 0, Width, Height, FRadius, FRadius);
  SetWindowRgn(Handle, Region, True);
  DeleteObject(Region); // Libera a regi�o ap�s us�-la
end;

procedure TGDPanel.SetGDPanelAlign(Value: TGDPanelAlign);
begin
  if FGDPanelAlign <> Value then
  begin
    FGDPanelAlign := Value;

    case Value of
      paNone:
        inherited Align := alNone;
      paLeft:
        inherited Align := alLeft;
      paTop:
        inherited Align := alTop;
      paRight:
        inherited Align := alRight;
      paBottom:
        inherited Align := alBottom;
      paClient:
        inherited Align := alClient;
      paCenter:
        begin
          inherited Align := alNone;
          Left := (Parent.ClientWidth - Width) div 2;
          Top := (Parent.ClientHeight - Height) div 2;
        end;
    end;
  end;
end;

procedure TGDPanel.SetRadius(const Value: Integer);
begin
  if FRadius <> Value then
  begin
    FRadius := Value;
    Invalidate; // Force the control to be repainted
  end;
end;

procedure TGDPanel.SetResizeOptions(const Value: TResizeOptions);
begin
  FResizeOptions.Assign(Value);
end;

procedure TGDPanel.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
const
  BORDER_SIZE = 10;
begin
  inherited;
  if (Button = mbLeft) and (FResizeOptions.CanResize) then
  begin
    if (Y <= BORDER_SIZE) then
      FResizingBorder := bdTop
    else if (Y >= Height - BORDER_SIZE) then
      FResizingBorder := bdBottom
    else if (X <= BORDER_SIZE) then
      FResizingBorder := bdLeft
    else if (X >= Width - BORDER_SIZE) then
      FResizingBorder := bdRight
    else
      FResizingBorder := bdNone;

    if FResizingBorder <> bdNone then
    begin
      FMouseDown := True;
      FMousePoint := Point(X, Y);
    end;
  end;
end;

procedure TGDPanel.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  NewWidth, NewHeight: Integer;
begin
  inherited;
  if FMouseDown and FResizeOptions.CanResize then
  begin
    case FResizingBorder of
      bdLeft:
        begin
          NewWidth := Self.Width - X + FMousePoint.X;
          if NewWidth >= FResizeOptions.MinWidth then
          begin
            Self.Width := NewWidth;
            Self.Left := Self.Left + X - FMousePoint.X;
          end;
        end;
      bdRight:
        begin
          NewWidth := Self.Width + X - FMousePoint.X;
          if NewWidth >= FResizeOptions.MinWidth then
            Self.Width := NewWidth;
        end;
      bdTop:
        begin
          NewHeight := Self.Height - Y + FMousePoint.Y;
          if NewHeight >= FResizeOptions.MinHeight then
          begin
            Self.Height := NewHeight;
          end;
        end;
      bdBottom:
        begin
          NewHeight := Self.Height + Y - FMousePoint.Y;
          if NewHeight >= FResizeOptions.MinHeight then
            Self.Height := NewHeight;
        end;
    end;

    FMousePoint := Point(X, Y);
  end;
end;


procedure TGDPanel.MouseUp(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  inherited;
  FMouseDown := False;
end;

procedure TGDPanel.Paint;
var
  R: TRect;
  Bitmap: TBitmap;
begin
  R := ClientRect;

  Bitmap := TBitmap.Create;
  try
    Bitmap.SetSize(Width, Height);
    Bitmap.Canvas.Pen.Style := psClear;
    Bitmap.Canvas.Brush.Color := Color;
    Bitmap.Canvas.RoundRect(R.Left, R.Top, R.Right, R.Bottom, FRadius, FRadius);

    Canvas.StretchDraw(R, Bitmap);
  finally
    Bitmap.Free;
  end;
end;

{ TResizeOptions }

constructor TResizeOptions.Create;
begin
  inherited;
  FCanResize := False;
  FMinWidth := 100;
  FMinHeight := 100;
end;

end.
