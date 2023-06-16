unit GDPanel;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
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

  TGDPanel = class(TPanel)
  private
    FRadius: Integer;
    FMouseDown: Boolean;
    FMousePoint: TPoint;
    FResizeOptions: TResizeOptions;
    procedure SetRadius(const Value: Integer);
    procedure SetResizeOptions(const Value: TResizeOptions);
  protected
    procedure Paint; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure Resize; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property Radius: Integer read FRadius write SetRadius;
    property ResizeOptions: TResizeOptions read FResizeOptions write SetResizeOptions;
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

procedure TGDPanel.SetRadius(const Value: Integer);
begin
  if FRadius <> Value then
  begin
    FRadius := Value;
    Invalidate;
  end;
end;

procedure TGDPanel.SetResizeOptions(const Value: TResizeOptions);
begin
  FResizeOptions.Assign(Value);
end;

procedure TGDPanel.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
const
  BORDER_SIZE = 10;
begin
  inherited;
  if (Button = mbLeft) and (FResizeOptions.CanResize) then
  begin
    if (X <= BORDER_SIZE) or (X >= Width - BORDER_SIZE) or
       (Y <= BORDER_SIZE) or (Y >= Height - BORDER_SIZE) then
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
    NewWidth := Self.Width + (X - FMousePoint.X);
    NewHeight := Self.Height + (Y - FMousePoint.Y);
    if NewWidth >= FResizeOptions.MinWidth then
      Self.Width := NewWidth;
    if NewHeight >= FResizeOptions.MinHeight then
      Self.Height := NewHeight;
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
begin
  R := ClientRect;
  Canvas.Pen.Style := psClear;
  Canvas.Brush.Color := Color;
  Canvas.RoundRect(R.Left, R.Top, R.Right, R.Bottom, FRadius, FRadius);
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

{ TResizeOptions }

constructor TResizeOptions.Create;
begin
  inherited;
  FCanResize := False;
  FMinWidth := 100;
  FMinHeight := 100;
end;

end.
