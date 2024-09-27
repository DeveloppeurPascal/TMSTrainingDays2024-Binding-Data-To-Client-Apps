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
/// File last update : 2024-09-24T19:59:08.000+02:00
/// Signature : e9d7bd74131c25a444d7d701e83e58bac958c7d3
/// ***************************************************************************
/// </summary>

unit fVCLClientMain;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.ToolWin,
  Vcl.ComCtrls,
  Vcl.TMSFNCWebSocketCommon,
  Vcl.TMSFNCCustomComponent,
  Vcl.TMSFNCWebSocketClient,
  Vcl.ExtCtrls,
  WebSocketCalculatorTypes,
  Vcl.TMSFNCTypes,
  Vcl.TMSFNCUtils,
  Vcl.TMSFNCGraphics,
  Vcl.TMSFNCGraphicsTypes,
  Vcl.TMSFNCCustomControl,
  Vcl.TMSFNCWaitingIndicator;

type
  TfrmVCLClientMain = class(TForm)
    Memo1: TMemo;
    ToolBar1: TToolBar;
    btnStart: TButton;
    btnStop: TButton;
    TMSFNCWebsocketClient1: TTMSFNCWebsocketClient;
    Panel1: TPanel;
    Edit1: TEdit;
    btnSub: TButton;
    btnAdd: TButton;
    Edit2: TEdit;
    TMSFNCWaitingIndicator1: TTMSFNCWaitingIndicator;
    procedure FormCreate(Sender: TObject);
    procedure btnStopClick(Sender: TObject);
    procedure btnStartClick(Sender: TObject);
    procedure btnAddClick(Sender: TObject);
    procedure btnSubClick(Sender: TObject);
    procedure TMSFNCWebsocketClient1MessageReceived(Sender: TObject;
      AConnection: TTMSFNCWebSocketConnection; const aMessage: string);
    procedure TMSFNCWebsocketClient1Connect(Sender: TObject;
      AConnection: TTMSFNCWebSocketConnection);
    procedure TMSFNCWebsocketClient1Disconnect(Sender: TObject;
      AConnection: TTMSFNCWebSocketConnection);
  private
    procedure UpdateButtons;
    procedure SendOperation(const Op: TOperator);
    procedure LockScreen;
    procedure UnlockScreen;
  public
  end;

var
  frmVCLClientMain: TfrmVCLClientMain;

implementation

{$R *.dfm}

uses
  System.JSON;

procedure TfrmVCLClientMain.btnAddClick(Sender: TObject);
begin
  SendOperation(TOperator.Add);
end;

procedure TfrmVCLClientMain.btnStartClick(Sender: TObject);
begin
  btnStart.enabled := false;
  TMSFNCWebsocketClient1.Active := true;
end;

procedure TfrmVCLClientMain.btnStopClick(Sender: TObject);
begin
  btnStop.enabled := false;
  TMSFNCWebsocketClient1.Active := false;
end;

procedure TfrmVCLClientMain.btnSubClick(Sender: TObject);
begin
  SendOperation(TOperator.Sub);
end;

procedure TfrmVCLClientMain.FormCreate(Sender: TObject);
begin
  Memo1.Clear;
  UnlockScreen;
  TMSFNCWebsocketClient1.Hostname := CWebSocketHostname;
  TMSFNCWebsocketClient1.port := CWebSocketPort;
  TMSFNCWebsocketClient1.PathName := CWebSocketPathName;
  Edit1.Text := random(100).ToString;
  Edit2.Text := random(100).ToString;
end;

procedure TfrmVCLClientMain.LockScreen;
begin
  Panel1.enabled := false;
  TMSFNCWaitingIndicator1.Visible := true;
  TMSFNCWaitingIndicator1.Active := true;
end;

procedure TfrmVCLClientMain.SendOperation(const Op: TOperator);
var
  Msg: TOperationMessage;
begin
  Msg := TOperationMessage.Create(string(Edit1.Text).ToInteger,
    string(Edit2.Text).ToInteger, Op);
  try
    LockScreen;
    Memo1.Lines.Add(Msg.ToString);
    TMSFNCWebsocketClient1.Send(Msg.ToJSON);
  finally
    Msg.free;
  end;
end;

procedure TfrmVCLClientMain.TMSFNCWebsocketClient1Connect(Sender: TObject;
  AConnection: TTMSFNCWebSocketConnection);
begin
  tthread.queue(nil,
    procedure
    begin
      UnlockScreen;
    end);
end;

procedure TfrmVCLClientMain.TMSFNCWebsocketClient1Disconnect(Sender: TObject;
AConnection: TTMSFNCWebSocketConnection);
begin
  tthread.queue(nil,
    procedure
    begin
      UnlockScreen;
    end);
end;

procedure TfrmVCLClientMain.TMSFNCWebsocketClient1MessageReceived
  (Sender: TObject; AConnection: TTMSFNCWebSocketConnection;
const aMessage: string);
var
  MsgResult: TResultMessage;
  jso: TJSONObject;
begin
  // tthread.synchronize(nil,
  // procedure
  // begin
  // Memo1.lines.add('Received : ' + aMessage);
  // end);
  MsgResult := TResultMessage.Create;
  try
    jso := TJSONObject.ParseJSONValue(aMessage) as TJSONObject;
    if assigned(jso) then
      try
        MsgResult.AsJSON := jso;
        tthread.synchronize(nil,
          procedure
          begin
            Memo1.Lines.Add(MsgResult.ToString);
            UnlockScreen;
          end);
      finally
        jso.free;
      end;
  finally
    MsgResult.free;
  end;
end;

procedure TfrmVCLClientMain.UnlockScreen;
begin
  TMSFNCWaitingIndicator1.Active := false;
  TMSFNCWaitingIndicator1.Visible := false;
  Panel1.enabled := true;
  UpdateButtons;
end;

procedure TfrmVCLClientMain.UpdateButtons;
begin
  btnStart.enabled := not TMSFNCWebsocketClient1.Active;
  btnStop.enabled := not btnStart.enabled;
  Panel1.enabled := btnStop.enabled;
end;

initialization

{$IFDEF DEBUG}
  ReportMemoryLeaksOnShutdown := true;
{$ENDIF}
randomize;

end.
