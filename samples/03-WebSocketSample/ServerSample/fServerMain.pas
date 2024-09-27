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
/// File last update : 2024-09-24T19:44:16.000+02:00
/// Signature : a66e6f183de69ecbb7c0058359ec9f536f70d2a0
/// ***************************************************************************
/// </summary>

unit fServerMain;

interface

uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.Variants,
  FMX.Types,
  FMX.Controls,
  FMX.Forms,
  FMX.Graphics,
  FMX.Dialogs,
  FMX.TMSFNCWebSocketCommon,
  FMX.Controls.Presentation,
  FMX.StdCtrls,
  FMX.Layouts,
  FMX.TMSFNCCustomComponent,
  FMX.TMSFNCWebSocketServer,
  FMX.Memo.Types,
  FMX.ScrollBox,
  FMX.Memo;

type
  TfrmServerMain = class(TForm)
    TMSFNCWebSocketServer1: TTMSFNCWebSocketServer;
    GridPanelLayout1: TGridPanelLayout;
    btnStart: TButton;
    btnStop: TButton;
    Memo1: TMemo;
    procedure btnStopClick(Sender: TObject);
    procedure btnStartClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure TMSFNCWebSocketServer1Connect(Sender: TObject;
      AConnection: TTMSFNCWebSocketConnection);
    procedure TMSFNCWebSocketServer1Disconnect(Sender: TObject;
      AConnection: TTMSFNCWebSocketConnection);
    procedure TMSFNCWebSocketServer1Close(Sender: TObject;
      AConnection: TTMSFNCWebSocketConnection; const aData: TBytes);
    procedure TMSFNCWebSocketServer1Allow(Sender: TObject;
      AConnection: TTMSFNCWebSocketServerConnection; var AAllow: Boolean);
    procedure TMSFNCWebSocketServer1MessageReceived(Sender: TObject;
      AConnection: TTMSFNCWebSocketConnection; const aMessage: string);
  private
    procedure UpdateButtons;
  public

  end;

var
  frmServerMain: TfrmServerMain;

implementation

{$R *.fmx}

uses
  System.JSON,
  WebSocketCalculatorTypes;

procedure TfrmServerMain.btnStartClick(Sender: TObject);
begin
  TMSFNCWebSocketServer1.Active := true;
  UpdateButtons;
end;

procedure TfrmServerMain.btnStopClick(Sender: TObject);
begin
  TMSFNCWebSocketServer1.Active := false;
  UpdateButtons;
end;

procedure TfrmServerMain.FormCreate(Sender: TObject);
begin
  UpdateButtons;
  TMSFNCWebSocketServer1.port := CWebSocketPort;
  TMSFNCWebSocketServer1.PathName := CWebSocketPathName;
end;

procedure TfrmServerMain.TMSFNCWebSocketServer1Allow(Sender: TObject;
  AConnection: TTMSFNCWebSocketServerConnection; var AAllow: Boolean);
begin
  tthread.synchronize(nil,
    procedure
    var
      i: integer;
    begin
      for i := 0 to AConnection.HandshakeRequest.RawHeaders.Count - 1 do
        Memo1.lines.add(AConnection.HandshakeRequest.RawHeaders[i]);
    end);
  AAllow := true;
end;

procedure TfrmServerMain.TMSFNCWebSocketServer1Close(Sender: TObject;
AConnection: TTMSFNCWebSocketConnection; const aData: TBytes);
begin
  tthread.synchronize(nil,
    procedure
    begin
      Memo1.lines.add('Close');
    end);
end;

procedure TfrmServerMain.TMSFNCWebSocketServer1Connect(Sender: TObject;
AConnection: TTMSFNCWebSocketConnection);
begin
  tthread.synchronize(nil,
    procedure
    begin
      Memo1.lines.add('Connect (' + AConnection.PeerIP + ')');
    end);
end;

procedure TfrmServerMain.TMSFNCWebSocketServer1Disconnect(Sender: TObject;
AConnection: TTMSFNCWebSocketConnection);
begin
  tthread.synchronize(nil,
    procedure
    begin
      Memo1.lines.add('Disconnect (' + AConnection.PeerIP + ')');
    end);
end;

procedure TfrmServerMain.TMSFNCWebSocketServer1MessageReceived(Sender: TObject;
AConnection: TTMSFNCWebSocketConnection; const aMessage: string);
var
  MsgCalc: TOperationMessage;
  MsgResult: TResultMessage;
  jso: TJSONObject;
begin
  tthread.synchronize(nil,
    procedure
    begin
      Memo1.lines.add('Received (' + AConnection.PeerIP + ') : ' + aMessage);
    end);
  MsgCalc := TOperationMessage.Create;
  try
    jso := TJSONObject.ParseJSONValue(aMessage) as TJSONObject;
    if assigned(jso) then
      try
        MsgCalc.AsJSON := jso;
        MsgResult := TResultMessage.Create(MsgCalc);
        try
          MsgResult.Calculate;
          AConnection.Send(MsgResult.ToJSON);
        finally
          MsgResult.Free;
        end;
      finally
        jso.Free;
      end;
  finally
    MsgCalc.Free;
  end;
end;

procedure TfrmServerMain.UpdateButtons;
begin
  btnStart.Enabled := not TMSFNCWebSocketServer1.Active;
  btnStop.Enabled := not btnStart.Enabled;
end;

initialization

{$IFDEF DEBUG}
  ReportMemoryLeaksOnShutdown := true;
{$ENDIF}

end.
