/// <summary>
/// ***************************************************************************
///
/// Binding Data To Client Apps Samples
///
/// Copyright 2024 Patrick Prémartin under AGPL 3.0 license.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
/// THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
/// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
/// DEALINGS IN THE SOFTWARE.
///
/// ***************************************************************************
///
/// Sample projects to illustrate the talk "Binding Data to client apps" at
/// the TMS Training Days 2024 in Lille (France).
///
/// ***************************************************************************
///
/// Author(s) :
/// Patrick PREMARTIN
///
/// Site :
/// https://tmstrainingdays.com/
///
/// Project site :
/// https://github.com/DeveloppeurPascal/TMSTrainingDays2024-Binding-Data-To-Client-Apps
///
/// ***************************************************************************
/// File last update : 2024-09-24T21:34:44.000+02:00
/// Signature : 40819894e4ec7821d08c713b834fa5e9402ec9b2
/// ***************************************************************************
/// </summary>

unit WebSocketCalculatorTypes;

interface

{$IFDEF TMSWEBCORE}

uses
  WEBLib.JSON;
{$ELSE}

uses
  System.JSON;
{$ENDIF}

const
  CWebSocketHostname = '127.0.0.1';
  CWebSocketPort = 8080;
  CWebSocketPathName = 'E5B8C258-1BB3-4EA2-A0B7-B19CD80E9428';

type
{$SCOPEDENUMS ON}
  TOperator = (Undefined, Add, Sub);

  TOperationMessage = class
  private
    FFirstNumber: integer;
    FSecondNumber: integer;
    FOperator: TOperator;
    procedure SetAsJSON(const Value: TJSONObject);
    procedure SetFirstNumber(const Value: integer);
    procedure SetOperator(const Value: TOperator);
    procedure SetSecondNumber(const Value: integer);
    function GetAsJSON: TJSONObject;
  protected
  public
    property FirstNumber: integer read FFirstNumber write SetFirstNumber;
    property SecondNumber: integer read FSecondNumber write SetSecondNumber;
    property Op: TOperator read FOperator write SetOperator;
    property AsJSON: TJSONObject read GetAsJSON write SetAsJSON;
    constructor Create; overload; virtual;
    constructor Create(const AFirstNumber, ASecondNumber: integer;
      const AOperator: TOperator); overload; virtual;
    function ToJSON: string; virtual;
    function ToString: string; override;
  end;

  TResultMessage = class(TOperationMessage)
  private
    FValue: integer;
    procedure SetAsJSON(const Value: TJSONObject);
    procedure SetValue(const Value: integer);
    function GetAsJSON: TJSONObject;
  protected
  public
    property Value: integer read FValue write SetValue;
    property AsJSON: TJSONObject read GetAsJSON write SetAsJSON;
    constructor Create; override;
    constructor Create(const AOperation: TOperationMessage); overload; virtual;
    function ToJSON: string; override;
    function ToString: string; override;
    procedure Calculate;
  end;

implementation

uses
  System.SysUtils;

{ TOperationMessage }

constructor TOperationMessage.Create;
begin
  inherited;
  FFirstNumber := 0;
  FSecondNumber := 0;
  FOperator := TOperator.Undefined;
end;

constructor TOperationMessage.Create(const AFirstNumber, ASecondNumber: integer;
  const AOperator: TOperator);
begin
  Create;
  FirstNumber := AFirstNumber;
  SecondNumber := ASecondNumber;
  Op := AOperator;
end;

function TOperationMessage.GetAsJSON: TJSONObject;
begin
  Result := TJSONObject.Create.AddPair('FirstNumber', FFirstNumber)
    .AddPair('SecondNumber', FSecondNumber).AddPair('Operator', ord(FOperator));
end;

function TOperationMessage.ToJSON: string;
var
  jso: TJSONObject;
begin
  jso := AsJSON;
  try
    Result := jso.ToJSON;
  finally
    jso.free;
  end;
end;

function TOperationMessage.ToString: string;
begin
  Result := FFirstNumber.ToString;
  case FOperator of
    TOperator.Add:
      Result := Result + ' + ';
    TOperator.Sub:
      Result := Result + ' - ';
  else
    Result := 'undefined operator';
    exit;
  end;
  Result := Result + FSecondNumber.ToString;
end;

procedure TOperationMessage.SetAsJSON(const Value: TJSONObject);
var
  LOperator: integer;
begin
  if not assigned(Value) then
    exit;
{$IFDEF TMSWEBCORE}
  try
    FFirstNumber := (Value.GetValue('FirstNumber') as tjsonnumber).AsInt;
  except
    FFirstNumber := 0;
  end;
  try
    FSecondNumber := (Value.GetValue('SecondNumber') as tjsonnumber).AsInt;
  except
    FSecondNumber := 0;
  end;
  try
    LOperator := (Value.GetValue('Operator') as tjsonnumber).AsInt;
    Op := TOperator(LOperator);
  except
    Op := TOperator.Undefined;
  end;
{$ELSE}
  if not Value.TryGetValue<integer>('FirstNumber', FFirstNumber) then
    FFirstNumber := 0;
  if not Value.TryGetValue<integer>('SecondNumber', FSecondNumber) then
    FSecondNumber := 0;
  if not Value.TryGetValue<integer>('Operator', LOperator) then
    Op := TOperator.Undefined
  else
    Op := TOperator(LOperator); // not safe, check if it's an authorized value
{$ENDIF}
end;

procedure TOperationMessage.SetFirstNumber(const Value: integer);
begin
  FFirstNumber := Value;
end;

procedure TOperationMessage.SetOperator(const Value: TOperator);
begin
  FOperator := Value;
end;

procedure TOperationMessage.SetSecondNumber(const Value: integer);
begin
  FSecondNumber := Value;
end;

{ TResultMessage }

constructor TResultMessage.Create;
begin
  inherited;
  FValue := 0;
end;

procedure TResultMessage.Calculate;
begin
  case FOperator of
    TOperator.Add:
      Value := FFirstNumber + FSecondNumber;
    TOperator.Sub:
      Value := FFirstNumber - FSecondNumber;
  else
    Value := 0; // add something to report errors to the client
  end;
end;

constructor TResultMessage.Create(const AOperation: TOperationMessage);
begin
  Create;
  FFirstNumber := AOperation.FirstNumber;
  FSecondNumber := AOperation.SecondNumber;
  FOperator := AOperation.Op;
end;

function TResultMessage.GetAsJSON: TJSONObject;
begin
  Result := inherited.AddPair('Value', Value);
end;

function TResultMessage.ToJSON: string;
var
  jso: TJSONObject;
begin
  jso := AsJSON;
  try
    Result := jso.ToJSON;
  finally
    jso.free;
  end;
end;

function TResultMessage.ToString: string;
begin
  Result := inherited + ' = ' + FValue.ToString;
end;

procedure TResultMessage.SetAsJSON(const Value: TJSONObject);
begin
  if not assigned(Value) then
    exit;

  inherited;
{$IFDEF TMSWEBCORE}
  try
    FValue := (Value.GetValue('Value') as tjsonnumber).AsInt;
  except
    FValue := 0;
  end;
{$ELSE}
  if not Value.TryGetValue<integer>('Value', FValue) then
    FValue := 0;
{$ENDIF}
end;

procedure TResultMessage.SetValue(const Value: integer);
begin
  FValue := Value;
end;

end.
