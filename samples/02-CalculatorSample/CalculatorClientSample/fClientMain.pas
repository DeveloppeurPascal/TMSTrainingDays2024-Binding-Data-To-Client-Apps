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
/// File last update : 2024-09-23T21:21:14.000+02:00
/// Signature : e82c75d978ca944d65adba125b14781f6eba5325
/// ***************************************************************************
/// </summary>

unit fClientMain;

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
  TMSTrainingDays2024Sample,
  Olf.Net.Socket.Messaging,
  FMX.StdCtrls,
  FMX.Controls.Presentation,
  FMX.Edit,
  FMX.Layouts;

type
  TfrmClientMain = class(TForm)
    GridPanelLayout1: TGridPanelLayout;
    Edit1: TEdit;
    Edit2: TEdit;
    btnAdd: TButton;
    btnSub: TButton;
    AniIndicator1: TAniIndicator;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnAddClick(Sender: TObject);
    procedure btnSubClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    /// <summary>
    /// Used for the client instance
    /// </summary>
    client: TTMSTrainingDays2024SampleClient;
    /// <summary>
    /// Connect the client to the server if it doesn't already exist
    /// </summary>
    procedure ConnectToTheServer;
    /// <summary>
    /// Called when the server send a result.
    /// </summary>
    procedure DoReceivedResult(Const ASender: TOlfSMSrvConnectedClient;
      Const AMessage: TResultMessage);
    /// <summary>
    /// Lock the screen and show a waiting animation
    /// </summary>
    procedure BlockScreen;
    /// <summary>
    /// Unlock the screen
    /// </summary>
    procedure UnblockScreen;
  public
  end;

var
  frmClientMain: TfrmClientMain;

implementation

{$R *.fmx}

procedure TfrmClientMain.BlockScreen;
begin
  GridPanelLayout1.Enabled := false;
  AniIndicator1.Visible := true;
  AniIndicator1.Enabled := true;
end;

procedure TfrmClientMain.btnAddClick(Sender: TObject);
var
  Msg: TAddMessage;
begin
  ConnectToTheServer;
  Msg := TAddMessage.Create;
  try
    Msg.FirstNumber := Edit1.Text.ToInteger;
    Msg.SecondNumber := Edit2.Text.ToInteger;
    BlockScreen;
    client.SendMessage(Msg);
  finally
    Msg.free;
  end;
end;

procedure TfrmClientMain.btnSubClick(Sender: TObject);
var
  Msg: TSubMessage;
begin
  ConnectToTheServer;
  Msg := TSubMessage.Create;
  try
    Msg.FirstNumber := Edit1.Text.ToInteger;
    Msg.SecondNumber := Edit2.Text.ToInteger;
    BlockScreen;
    client.SendMessage(Msg);
  finally
    Msg.free;
  end;
end;

procedure TfrmClientMain.ConnectToTheServer;
begin
  if not assigned(client) then
  begin
    client := TTMSTrainingDays2024SampleClient.Create('127.0.0.1', 8080);
    client.onReceiveResultMessage := DoReceivedResult;
    client.Connect;
  end;
end;

procedure TfrmClientMain.DoReceivedResult(const ASender
  : TOlfSMSrvConnectedClient; const AMessage: TResultMessage);
var
  Value: integer;
begin
  Value := AMessage.Value;
  tthread.Queue(nil,
    procedure
    begin
      UnblockScreen;
      ShowMessage('Result : ' + Value.ToString);
    end);
end;

procedure TfrmClientMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  client.free;
end;

procedure TfrmClientMain.FormCreate(Sender: TObject);
begin
  UnblockScreen;
  Edit1.Text := random(100).ToString;
  Edit2.Text := random(100).ToString;
end;

procedure TfrmClientMain.UnblockScreen;
begin
  AniIndicator1.Enabled := false;
  AniIndicator1.Visible := false;
  GridPanelLayout1.Enabled := true;
end;

initialization

{$IFDEF DEBUG}
  ReportMemoryLeaksOnShutdown := true;
{$ENDIF}
randomize;

end.
