program pClicker;

uses
  Forms,
  uMain in 'uMain.pas' {fmClicker};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfmClicker, fmClicker);
  Application.Run;
end.
