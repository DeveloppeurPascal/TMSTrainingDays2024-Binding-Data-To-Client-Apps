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
/// File last update : 2024-09-23T20:32:05.957+02:00
/// Signature : 31b16bdec26883370c0091570df9315e6c9c49d2
/// ***************************************************************************
/// </summary>

unit TMSTrainingDays2024Sample;

// ****************************************
// * TMS Training Days 2024 sample
// ****************************************
// 
// Sample client/server API for the TMS
// Training Days 2024.
// 
// ****************************************
// File generator : Socket Messaging Code Generator (v1.1)
// Website : https://smcodegenerator.olfsoftware.fr/ 
// Generation date : 23/09/2024 20:32:05
// 
// Don't do any change on this file. They will be erased by next generation !
// ****************************************

// To compile this unit you need Olf.Net.Socket.Messaging.pas from
// https://github.com/DeveloppeurPascal/Socket-Messaging-Library
//
// Direct link to the file :
// https://raw.githubusercontent.com/DeveloppeurPascal/Socket-Messaging-Library/main/src/Olf.Net.Socket.Messaging.pas

interface

uses
  System.Classes,
  Olf.Net.Socket.Messaging;

type
  /// <summary>
  /// Message ID 1: Add
  /// </summary>
  /// <remarks>
  /// Sent to the server with the numbers to add.
  /// </remarks>
  TAddMessage = class(TOlfSMMessage)
  private
    FFirstNumber: integer;
    FSecondNumber: integer;
    procedure SetFirstNumber(const Value: integer);
    procedure SetSecondNumber(const Value: integer);
  public
    /// <summary>
    /// First number
    /// </summary>
    property FirstNumber: integer read FFirstNumber write SetFirstNumber;
    /// <summary>
    /// Second number
    /// </summary>
    property SecondNumber: integer read FSecondNumber write SetSecondNumber;
    constructor Create; override;
    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;
    function GetNewInstance: TOlfSMMessage; override;
  end;

  /// <summary>
  /// Message ID 3: Result
  /// </summary>
  /// <remarks>
  /// Sent by the server with the result of the
  /// operation.
  /// </remarks>
  TResultMessage = class(TOlfSMMessage)
  private
    FValue: integer;
    procedure SetValue(const Value: integer);
  public
    /// <summary>
    /// Value
    /// </summary>
    property Value: integer read FValue write SetValue;
    constructor Create; override;
    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;
    function GetNewInstance: TOlfSMMessage; override;
  end;

  /// <summary>
  /// Message ID 2: Sub
  /// </summary>
  /// <remarks>
  /// Sent to the server with the numbers to
  /// substract.
  /// </remarks>
  TSubMessage = class(TOlfSMMessage)
  private
    FFirstNumber: integer;
    FSecondNumber: integer;
    procedure SetFirstNumber(const Value: integer);
    procedure SetSecondNumber(const Value: integer);
  public
    /// <summary>
    /// First number
    /// </summary>
    property FirstNumber: integer read FFirstNumber write SetFirstNumber;
    /// <summary>
    /// Second number
    /// </summary>
    property SecondNumber: integer read FSecondNumber write SetSecondNumber;
    constructor Create; override;
    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;
    function GetNewInstance: TOlfSMMessage; override;
  end;

  TTMSTrainingDays2024SampleServer = class(TOlfSMServer)
  private
  protected
    procedure onReceiveMessage1(Const ASender: TOlfSMSrvConnectedClient;
      Const AMessage: TOlfSMMessage);
    procedure onReceiveMessage2(Const ASender: TOlfSMSrvConnectedClient;
      Const AMessage: TOlfSMMessage);
  public
    onReceiveAddMessage
      : TOlfSMReceivedMessageEvent<TAddMessage>;
    onReceiveSubMessage
      : TOlfSMReceivedMessageEvent<TSubMessage>;
    constructor Create; override;
  end;

  TTMSTrainingDays2024SampleClient = class(TOlfSMClient)
  private
  protected
    procedure onReceiveMessage3(Const ASender: TOlfSMSrvConnectedClient;
      Const AMessage: TOlfSMMessage);
  public
    onReceiveResultMessage
      : TOlfSMReceivedMessageEvent<TResultMessage>;
    constructor Create; override;
  end;

procedure RegisterMessagesReceivedByTheServer(Const Server: TOlfSMServer);
procedure RegisterMessagesReceivedByTheClient(Const Client: TOlfSMClient);

implementation

uses
  System.SysUtils;

procedure RegisterMessagesReceivedByTheServer(Const Server: TOlfSMServer);
begin
  Server.RegisterMessageToReceive(TAddMessage.Create);
  Server.RegisterMessageToReceive(TSubMessage.Create);
end;

procedure RegisterMessagesReceivedByTheClient(Const Client: TOlfSMClient);
begin
  Client.RegisterMessageToReceive(TResultMessage.Create);
end;

{$REGION 'TTMSTrainingDays2024SampleServer'}

constructor TTMSTrainingDays2024SampleServer.Create;
begin
  inherited;
  RegisterMessagesReceivedByTheServer(self);
  SubscribeToMessage(1, onReceiveMessage1);
  SubscribeToMessage(2, onReceiveMessage2);
end;

procedure TTMSTrainingDays2024SampleServer.onReceiveMessage1(const ASender: TOlfSMSrvConnectedClient;
const AMessage: TOlfSMMessage);
begin
  if not(AMessage is TAddMessage) then
    exit;
  if not assigned(onReceiveAddMessage) then
    exit;
  onReceiveAddMessage(ASender, AMessage as TAddMessage);
end;

procedure TTMSTrainingDays2024SampleServer.onReceiveMessage2(const ASender: TOlfSMSrvConnectedClient;
const AMessage: TOlfSMMessage);
begin
  if not(AMessage is TSubMessage) then
    exit;
  if not assigned(onReceiveSubMessage) then
    exit;
  onReceiveSubMessage(ASender, AMessage as TSubMessage);
end;

{$ENDREGION}

{$REGION 'TTMSTrainingDays2024SampleClient'}

constructor TTMSTrainingDays2024SampleClient.Create;
begin
  inherited;
  RegisterMessagesReceivedByTheClient(self);
  SubscribeToMessage(3, onReceiveMessage3);
end;

procedure TTMSTrainingDays2024SampleClient.onReceiveMessage3(const ASender: TOlfSMSrvConnectedClient;
const AMessage: TOlfSMMessage);
begin
  if not(AMessage is TResultMessage) then
    exit;
  if not assigned(onReceiveResultMessage) then
    exit;
  onReceiveResultMessage(ASender, AMessage as TResultMessage);
end;

{$ENDREGION}

{$REGION 'TAddMessage' }

constructor TAddMessage.Create;
begin
  inherited;
  MessageID := 1;
  FFirstNumber := 0;
  FSecondNumber := 0;
end;

function TAddMessage.GetNewInstance: TOlfSMMessage;
begin
  result := TAddMessage.Create;
end;

procedure TAddMessage.LoadFromStream(Stream: TStream);
begin
  inherited;
  if (Stream.read(FFirstNumber, sizeof(FFirstNumber)) <> sizeof(FFirstNumber)) then
    raise exception.Create('Can''t load "FirstNumber" value.');
  if (Stream.read(FSecondNumber, sizeof(FSecondNumber)) <> sizeof(FSecondNumber)) then
    raise exception.Create('Can''t load "SecondNumber" value.');
end;

procedure TAddMessage.SaveToStream(Stream: TStream);
begin
  inherited;
  Stream.Write(FFirstNumber, sizeof(FFirstNumber));
  Stream.Write(FSecondNumber, sizeof(FSecondNumber));
end;

procedure TAddMessage.SetFirstNumber(const Value: integer);
begin
  FFirstNumber := Value;
end;

procedure TAddMessage.SetSecondNumber(const Value: integer);
begin
  FSecondNumber := Value;
end;

{$ENDREGION}

{$REGION 'TResultMessage' }

constructor TResultMessage.Create;
begin
  inherited;
  MessageID := 3;
  FValue := 0;
end;

function TResultMessage.GetNewInstance: TOlfSMMessage;
begin
  result := TResultMessage.Create;
end;

procedure TResultMessage.LoadFromStream(Stream: TStream);
begin
  inherited;
  if (Stream.read(FValue, sizeof(FValue)) <> sizeof(FValue)) then
    raise exception.Create('Can''t load "Value" value.');
end;

procedure TResultMessage.SaveToStream(Stream: TStream);
begin
  inherited;
  Stream.Write(FValue, sizeof(FValue));
end;

procedure TResultMessage.SetValue(const Value: integer);
begin
  FValue := Value;
end;

{$ENDREGION}

{$REGION 'TSubMessage' }

constructor TSubMessage.Create;
begin
  inherited;
  MessageID := 2;
  FFirstNumber := 0;
  FSecondNumber := 0;
end;

function TSubMessage.GetNewInstance: TOlfSMMessage;
begin
  result := TSubMessage.Create;
end;

procedure TSubMessage.LoadFromStream(Stream: TStream);
begin
  inherited;
  if (Stream.read(FFirstNumber, sizeof(FFirstNumber)) <> sizeof(FFirstNumber)) then
    raise exception.Create('Can''t load "FirstNumber" value.');
  if (Stream.read(FSecondNumber, sizeof(FSecondNumber)) <> sizeof(FSecondNumber)) then
    raise exception.Create('Can''t load "SecondNumber" value.');
end;

procedure TSubMessage.SaveToStream(Stream: TStream);
begin
  inherited;
  Stream.Write(FFirstNumber, sizeof(FFirstNumber));
  Stream.Write(FSecondNumber, sizeof(FSecondNumber));
end;

procedure TSubMessage.SetFirstNumber(const Value: integer);
begin
  FFirstNumber := Value;
end;

procedure TSubMessage.SetSecondNumber(const Value: integer);
begin
  FSecondNumber := Value;
end;

{$ENDREGION}

end.
