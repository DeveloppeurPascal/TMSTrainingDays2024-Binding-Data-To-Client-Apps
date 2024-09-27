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
/// File last update : 2024-09-24T22:16:00.000+02:00
/// Signature : 6b564b3e76ee6c1366bfab7f206ec2367d45a6e2
/// ***************************************************************************
/// </summary>

unit fWebCoreClientMain;

interface

uses
  System.SysUtils,
  System.Classes,
  JS,
  Web,
  WEBLib.Graphics,
  WEBLib.Controls,
  WEBLib.Forms,
  WEBLib.Dialogs,
  Vcl.StdCtrls,
  WEBLib.StdCtrls,
  Vcl.Controls,
  WEBLib.WebSocketClient,
  WebSocketCalculatorTypes;

type
  TfrmWebCoreClientMain = class(TWebForm)
    btnStart: TWebButton;
    btnStop: TWebButton;
    WebEdit1: TWebEdit;
    WebEdit2: TWebEdit;
    btnSub: TWebButton;
    btnAdd: TWebButton;
    WebMemo1: TWebMemo;
    WebSocketClient1: TWebSocketClient;
    procedure WebFormCreate(Sender: TObject);
    procedure btnStartClick(Sender: TObject);
    procedure btnStopClick(Sender: TObject);
    procedure WebSocketClient1Connect(Sender: TObject);
    procedure WebSocketClient1Disconnect(Sender: TObject);
    procedure WebSocketClient1MessageReceived(Sender: TObject;
      AMessage: string);
    procedure btnAddClick(Sender: TObject);
    procedure btnSubClick(Sender: TObject);
  private
    procedure UpdateButtons;
    procedure SendOperation(const Op: TOperator);
  public
  end;

var
  frmWebCoreClientMain: TfrmWebCoreClientMain;

implementation

{$R *.dfm}

uses
  WEBLib.JSON;

procedure TfrmWebCoreClientMain.btnAddClick(Sender: TObject);
begin
  SendOperation(TOperator.add);
end;

procedure TfrmWebCoreClientMain.btnStartClick(Sender: TObject);
begin
  btnStart.enabled := false;
  WebSocketClient1.Active := true;
end;

procedure TfrmWebCoreClientMain.btnStopClick(Sender: TObject);
begin
  btnStop.enabled := false;
  WebSocketClient1.Active := false;
end;

procedure TfrmWebCoreClientMain.btnSubClick(Sender: TObject);
begin
  SendOperation(TOperator.sub);
end;

procedure TfrmWebCoreClientMain.SendOperation(const Op: TOperator);
var
  Msg: TOperationMessage;
  nb1, nb2: integer;
begin
  nb1 := StrToInt(WebEdit1.Text);
  nb2 := StrToInt(WebEdit2.Text);
  Msg := TOperationMessage.Create(nb1, nb2, Op);
  try
    WebMemo1.Lines.add(Msg.ToString);
    WebSocketClient1.Send(Msg.ToJSON);
  finally
    Msg.free;
  end;
end;

procedure TfrmWebCoreClientMain.UpdateButtons;
begin
  btnStart.enabled := not WebSocketClient1.Active;
  btnStop.enabled := not btnStart.enabled;
  btnAdd.enabled := btnStop.enabled;
  btnSub.enabled := btnStop.enabled;
end;

procedure TfrmWebCoreClientMain.WebFormCreate(Sender: TObject);
begin
  WebSocketClient1.HostName := CWebSocketHostname;
  WebSocketClient1.Port := CWebSocketPort;
  WebSocketClient1.PathName := '/' + CWebSocketPathName;
  UpdateButtons;
end;

procedure TfrmWebCoreClientMain.WebSocketClient1Connect(Sender: TObject);
begin
  UpdateButtons;
end;

procedure TfrmWebCoreClientMain.WebSocketClient1Disconnect(Sender: TObject);
begin
  UpdateButtons;
end;

procedure TfrmWebCoreClientMain.WebSocketClient1MessageReceived(Sender: TObject;
  AMessage: string);
var
  MsgResult: TResultMessage;
  jso: TJSONObject;
begin
  MsgResult := TResultMessage.Create;
  try
    jso := TJSONObject.ParseJSONValue(AMessage) as TJSONObject;
    if assigned(jso) then
      try
        MsgResult.AsJSON := jso;
        WebMemo1.Lines.add(MsgResult.ToString);
        UpdateButtons;
      finally
        jso.free;
      end;
  finally
    MsgResult.free;
  end;
end;

end.
