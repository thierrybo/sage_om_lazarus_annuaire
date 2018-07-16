program annuaire;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, mainfrm
  { you can add units after this },
  Commun, listetiersfrm, detailfrm;

{$R *.res}

begin
  RequireDerivedFormResource := True;
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TListeTiersForm, ListeTiersForm);
  Application.CreateForm(TDetailForm, DetailForm);
  Application.Run;
end.

