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
/// File last update : 2024-09-23T20:20:40.000+02:00
/// Signature : 0ef85a9573c97f90788cc91de8ce69d2eb8056ae
/// ***************************************************************************
/// </summary>

unit fMain;

interface

uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.Variants,
  System.net.Socket,
  FMX.Types,
  FMX.Controls,
  FMX.Forms,
  FMX.Graphics,
  FMX.Dialogs,
  FMX.Controls.Presentation,
  FMX.StdCtrls,
  FMX.Memo.Types,
  FMX.ScrollBox,
  FMX.Memo;

type
  TfrmMain = class(TForm)
    btnStartAClient: TButton;
    Memo1: TMemo;
    procedure btnStartAClientClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    /// <summary>
    /// For the server thread instance
    /// </summary>
    ServerThread: TThread;
    /// <summary>
    /// Add a string on top of the memo
    /// </summary>
    procedure AddLog(msg: string);
    /// <summary>
    /// Called for each new client connexion
    /// </summary>
    procedure ServeurTraiteConnection(ClientSocket: TSocket);
  public
    /// <summary>
    /// Used as a global counter of clients
    /// </summary>
    num: integer;
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.fmx}

uses
  System.threading;

const
  CPortDEcoute = 8081;
  CTerminateur = string('|');

procedure TfrmMain.AddLog(msg: string);
begin
  if self = nil then
    exit;
  if Memo1 = nil then
    exit;

  tmonitor.Enter(Memo1);
  try
    Memo1.lines.insert(0, msg);
    Memo1.GoToTextBegin;
  finally
    tmonitor.exit(Memo1);
  end;
end;

procedure TfrmMain.btnStartAClientClick(Sender: TObject);
begin
  btnStartAClient.enabled := false;
  try
    inc(num);
    ttask.run(
      procedure
      var
        SocketClient: TSocket;
        ACK: string;
      begin
        try
          try
            SocketClient := TSocket.Create(tsockettype.tcp, tencoding.UTF8);
            try
              SocketClient.Connect('', '127.0.0.1', '', CPortDEcoute);
              if (tsocketstate.client in SocketClient.State) then
                AddLog('Client ' + num.tostring + ': client mode');
              if (tsocketstate.listening in SocketClient.State) then
                AddLog('Client ' + num.tostring + ': listening');
              if (tsocketstate.connected in SocketClient.State) then
              begin
                AddLog('Client ' + num.tostring + ': connected');
                if (-1 <> SocketClient.Send('Hello world ' + num.tostring +
                  CTerminateur)) then
                  AddLog('Client ' + num.tostring + ': message sent')
                else
                  AddLog('Client ' + num.tostring + ': sending error ' +
                    num.tostring);
              end;
              // waiting for the server ACK
              // (only necessary to be sure the server managed the message)
              ACK := '';
              repeat
                ACK := ACK + SocketClient.ReceiveString;
              until (TThread.CheckTerminated or ACK.EndsWith(CTerminateur));
              if (not ACK.isempty) then
                AddLog('Client ' + num.tostring + ': received ' +
                  ACK.Substring(0, ACK.Length - CTerminateur.Length))
              else
                AddLog('Client ' + num.tostring + ': server ACK not received.');
              SocketClient.Close;
            finally
              SocketClient.free;
            end;
          finally
            TThread.queue(nil,
              procedure
              begin
                // in case the program has already been closed,
                // avoid acess violation errors on thread exit
                if self = nil then
                  exit;
                if btnStartAClient = nil then
                  exit;
                btnStartAClient.enabled := true;
              end);
          end;
        except
          // don't do it in production projects
        end;
      end);
  except
    btnStartAClient.enabled := true;
  end;
end;

procedure TfrmMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if assigned(ServerThread) then
    ServerThread.Terminate;
  // wait for the clean Serverthread terminaison
  // in real projects add a timeout to close your program even if the thread don't
  while assigned(ServerThread) do
    sleep(100);
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  ServerThread := TThread.CreateAnonymousThread(
    procedure
    var
      ServeurSocket: TSocket;
    begin
      ServeurSocket := TSocket.Create(tsockettype.tcp, tencoding.UTF8);
      try
        ServeurSocket.Listen('127.0.0.1', '', CPortDEcoute);
        if (tsocketstate.client in ServeurSocket.State) then
          AddLog('Server: client mode ???');
        if (tsocketstate.listening in ServeurSocket.State) then
          AddLog('Server: listening');
        if (tsocketstate.connected in ServeurSocket.State) then
          AddLog('Server: connected');
        while not TThread.CheckTerminated do
          try
            ServeurTraiteConnection(ServeurSocket.accept(100));
          except
            on e: exception do
              AddLog('Server except: ' + e.Message);
          end;
        ServeurSocket.Close(true);
      finally
        ServeurSocket.free;
        ServerThread := nil;
      end;
    end);
  ServerThread.Start;
end;

procedure TfrmMain.ServeurTraiteConnection(ClientSocket: TSocket);
begin
  // timeout => no new client
  if not assigned(ClientSocket) then
    exit;

  try
    TThread.CreateAnonymousThread(
      procedure
      var
        msg: string;
      begin
        try
          msg := '';
          repeat
            msg := msg + ClientSocket.ReceiveString;
          until (TThread.CheckTerminated or msg.EndsWith(CTerminateur));
          if (not msg.isempty) then
            AddLog('Server: received message "' + msg.Substring(0,
              msg.Length - CTerminateur.Length) + '"')
          else
            AddLog('Server: no message received from this client.');
          ClientSocket.Send('ACK' + CTerminateur);
          ClientSocket.Close;
        finally
          ClientSocket.free;
        end;
      end).Start;
  except
    ClientSocket.free;
  end;
end;

initialization

{$IFDEF DEBUG }
  reportmemoryleaksonshutdown := true;

{$ENDIF }

end.
