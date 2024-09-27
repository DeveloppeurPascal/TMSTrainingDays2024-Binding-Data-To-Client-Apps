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
/// File last update : 2024-09-24T18:22:10.000+02:00
/// Signature : f033558914b5e0b6cc159cadfb75254e4ae1d9a4
/// ***************************************************************************
/// </summary>

program ServerSample;

uses
  System.StartUpCopy,
  FMX.Forms,
  fServerMain in 'fServerMain.pas' {frmServerMain},
  WebSocketCalculatorTypes in '..\WebSocketCalculatorTypes.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmServerMain, frmServerMain);
  Application.Run;
end.
