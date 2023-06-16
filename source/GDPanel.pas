unit GDPanel;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls;

type
  TGDPanel = class(TPanel)
  private
    FRadius: Integer;
    FMouseDown: Boolean;
    FMousePoint: TPoint;
    procedure SetRadius(const Value: Integer);
  protected
    procedure Paint; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property Radius: Integer read FRadius write SetRadius;
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
  BevelOuter := bvNone; // Set BevelOuter to bvNone
  FRadius := 15;
end;

procedure TGDPanel.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited;
  if Button = mbLeft then
  begin
    FMouseDown := True;
    FMousePoint := Point(X, Y);
  end;
end;

procedure TGDPanel.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  inherited;
  if FMouseDown then
  begin
    Self.Width := Self.Width + (X - FMousePoint.X);
    Self.Height := Self.Height + (Y - FMousePoint.Y);
    FMousePoint := Point(X, Y);
  end;
end;

procedure TGDPanel.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
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

procedure TGDPanel.SetRadius(const Value: Integer);
begin
  if FRadius <> Value then
  begin
    FRadius := Value;
    Invalidate;
  end;
end;

end.

