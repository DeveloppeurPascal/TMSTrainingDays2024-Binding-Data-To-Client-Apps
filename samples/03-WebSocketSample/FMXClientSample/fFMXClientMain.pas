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
/// File last update : 2024-09-24T19:59:52.000+02:00
/// Signature : 1420c9b408d137f804c09bb0ec654e201f73eb94
/// ***************************************************************************
/// </summary>

unit fFMXClientMain;

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
  FMX.Memo.Types,
  FMX.Edit,
  FMX.ScrollBox,
  FMX.Memo,
  FMX.Controls.Presentation,
  FMX.StdCtrls,
  FMX.Layouts,
  FMX.TMSFNCWebSocketCommon,
  FMX.TMSFNCCustomComponent,
  FMX.TMSFNCWebSocketClient,
  WebSocketCalculatorTypes;

type
  TfrmFMXClientMain = class(TForm)
    GridPanelLayout1: TGridPanelLayout;
    btnStart: TButton;
    btnStop: TButton;
    Memo1: TMemo;
    GridPanelLayout2: TGridPanelLayout;
    Edit1: TEdit;
    Edit2: TEdit;
    btnAdd: TButton;
    btnSub: TButton;
    TMSFNCWebsocketClient1: TTMSFNCWebsocketClient;
    procedure btnStartClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnStopClick(Sender: TObject);
    procedure btnAddClick(Sender: TObject);
    procedure btnSubClick(Sender: TObject);
    procedure TMSFNCWebsocketClient1Connect(Sender: TObject;
      AConnection: TTMSFNCWebSocketConnection);
    procedure TMSFNCWebsocketClient1Disconnect(Sender: TObject;
      AConnection: TTMSFNCWebSocketConnection);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure TMSFNCWebsocketClient1MessageReceived(Sender: TObject;
      AConnection: TTMSFNCWebSocketConnection; const aMessage: string);
  private
    procedure UpdateButtons;
    procedure SendOperation(const Op: TOperator);
  public
  end;

var
  frmFMXClientMain: TfrmFMXClientMain;

implementation

{$R *.fmx}

uses
  System.JSON;

procedure TfrmFMXClientMain.btnAddClick(Sender: TObject);
begin
  SendOperation(TOperator.add);
end;

procedure TfrmFMXClientMain.btnStartClick(Sender: TObject);
begin
  btnStart.Enabled := false;
  TMSFNCWebsocketClient1.Active := true;
end;

procedure TfrmFMXClientMain.btnStopClick(Sender: TObject);
begin
  btnStop.Enabled := false;
  TMSFNCWebsocketClient1.Active := false;
end;

procedure TfrmFMXClientMain.btnSubClick(Sender: TObject);
begin
  SendOperation(TOperator.sub);
end;

procedure TfrmFMXClientMain.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  TMSFNCWebsocketClient1.Active := false;
end;

procedure TfrmFMXClientMain.FormCreate(Sender: TObject);
begin
  Memo1.Lines.Clear;
  UpdateButtons;
  TMSFNCWebsocketClient1.Hostname := CWebSocketHostname;
  TMSFNCWebsocketClient1.port := CWebSocketPort;
  TMSFNCWebsocketClient1.PathName := CWebSocketPathName;
  Edit1.Text := random(100).ToString;
  Edit2.Text := random(100).ToString;
end;

procedure TfrmFMXClientMain.SendOperation(const Op: TOperator);
var
  Msg: TOperationMessage;
begin
  Msg := TOperationMessage.Create(string(Edit1.Text).ToInteger,
    string(Edit2.Text).ToInteger, Op);
  try
    Memo1.Lines.add(Msg.ToString);
    TMSFNCWebsocketClient1.Send(Msg.ToJSON);
  finally
    Msg.free;
  end;
end;

procedure TfrmFMXClientMain.TMSFNCWebsocketClient1Connect(Sender: TObject;
  AConnection: TTMSFNCWebSocketConnection);
begin
  tthread.queue(nil,
    procedure
    begin
      UpdateButtons
    end);
end;

procedure TfrmFMXClientMain.TMSFNCWebsocketClient1Disconnect(Sender: TObject;
AConnection: TTMSFNCWebSocketConnection);
begin
  tthread.queue(nil,
    procedure
    begin
      UpdateButtons
    end);
end;

procedure TfrmFMXClientMain.TMSFNCWebsocketClient1MessageReceived
  (Sender: TObject; AConnection: TTMSFNCWebSocketConnection;
const aMessage: string);
var
  MsgResult: TResultMessage;
  jso: TJSONObject;
begin
  MsgResult := TResultMessage.Create;
  try
    jso := TJSONObject.ParseJSONValue(aMessage) as TJSONObject;
    if assigned(jso) then
      try
        MsgResult.AsJSON := jso;
        tthread.synchronize(nil,
          procedure
          begin
            Memo1.Lines.add(MsgResult.ToString);
            UpdateButtons;
          end);
      finally
        jso.free;
      end;
  finally
    MsgResult.free;
  end;
end;

procedure TfrmFMXClientMain.UpdateButtons;
begin
  btnStart.Enabled := not TMSFNCWebsocketClient1.Active;
  btnStop.Enabled := not btnStart.Enabled;
  GridPanelLayout2.Enabled := btnStop.Enabled;
end;

initialization

{$IFDEF DEBUG}
  ReportMemoryLeaksOnShutdown := true;
{$ENDIF}
randomize;

end.
