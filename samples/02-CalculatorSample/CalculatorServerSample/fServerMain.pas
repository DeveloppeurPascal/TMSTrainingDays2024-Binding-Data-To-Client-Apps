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
/// File last update : 2024-09-23T20:59:54.000+02:00
/// Signature : 0feda37820a04b1950fa186878cd7adb0ea908d2
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
  FMX.Memo.Types,
  FMX.StdCtrls,
  FMX.Layouts,
  FMX.Controls.Presentation,
  FMX.ScrollBox,
  FMX.Memo,
  TMSTrainingDays2024Sample,
  Olf.Net.Socket.Messaging;

type
  TfrmServerMain = class(TForm)
    Memo1: TMemo;
    GridPanelLayout1: TGridPanelLayout;
    btnStartServer: TButton;
    btnStopServer: TButton;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure btnStopServerClick(Sender: TObject);
    procedure btnStartServerClick(Sender: TObject);
  private
    /// <summary>
    /// Instance of the server
    /// </summary>
    Server: TTMSTrainingDays2024SampleServer;
    /// <summary>
    /// Enable or disable buttons depending on server state
    /// </summary>
    procedure UpdateButtons;
    /// <summary>
    /// called when an ADD message is received
    /// </summary>
    procedure DoAddOperation(Const ASender: TOlfSMSrvConnectedClient;
      Const AMessage: TAddMessage);
    /// <summary>
    /// called when an SUB message is received
    /// </summary>
    procedure DoSubOperation(Const ASender: TOlfSMSrvConnectedClient;
      Const AMessage: TSubMessage);
    /// <summary>
    /// Add a string to the memo
    /// </summary>
    procedure AddLog(Txt: String);
  public
  end;

var
  frmServerMain: TfrmServerMain;

implementation

{$R *.fmx}

procedure TfrmServerMain.AddLog(Txt: String);
begin
  TThread.Queue(nil,
    procedure
    begin
      Memo1.lines.add(Txt);
    end);
end;

procedure TfrmServerMain.btnStartServerClick(Sender: TObject);
begin
  Server := TTMSTrainingDays2024SampleServer.Create('127.0.0.1', 8080);
  Server.onReceiveAddMessage := DoAddOperation;
  Server.onReceiveSubMessage := DoSubOperation;
  Server.Listen;
  while not Server.isListening do
    sleep(100);
  UpdateButtons;
end;

procedure TfrmServerMain.btnStopServerClick(Sender: TObject);
begin
  FreeAndNil(Server);
  UpdateButtons;
end;

procedure TfrmServerMain.DoAddOperation(const ASender: TOlfSMSrvConnectedClient;
const AMessage: TAddMessage);
var
  ResMsg: TResultMessage;
begin
  ResMsg := TResultMessage.Create;
  try
    ResMsg.Value := AMessage.FirstNumber + AMessage.SecondNumber;
    ASender.SendMessage(ResMsg);
    AddLog(AMessage.FirstNumber.tostring + ' + ' +
      AMessage.SecondNumber.tostring + ' = ' + ResMsg.Value.tostring);
  finally
    ResMsg.free;
  end;
end;

procedure TfrmServerMain.DoSubOperation(const ASender: TOlfSMSrvConnectedClient;
const AMessage: TSubMessage);
var
  ResMsg: TResultMessage;
begin
  ResMsg := TResultMessage.Create;
  try
    ResMsg.Value := AMessage.FirstNumber - AMessage.SecondNumber;
    ASender.SendMessage(ResMsg);
    AddLog(AMessage.FirstNumber.tostring + ' - ' +
      AMessage.SecondNumber.tostring + ' = ' + ResMsg.Value.tostring);
  finally
    ResMsg.free;
  end;
end;

procedure TfrmServerMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Server.free;
  // Just in case
  sleep(1000);
end;

procedure TfrmServerMain.FormCreate(Sender: TObject);
begin
  UpdateButtons;
end;

procedure TfrmServerMain.UpdateButtons;
begin
  btnStopServer.Enabled := assigned(Server) and Server.isListening;
  btnStartServer.Enabled := not btnStopServer.Enabled;
end;

initialization

{$IFDEF DEBUG}
  ReportMemoryLeaksOnShutdown := true;
{$ENDIF}

end.
