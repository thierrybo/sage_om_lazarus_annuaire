unit mainfrm;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, Menus,
  ActnList, ExtCtrls, Objets100cLib_3_0_TLB,
  commun;

type

  { TMainForm }

  TMainForm = class(TForm)
    aliEditionNouveau: TAction;
    aliEditionSupp: TAction;
    alEdition: TActionList;
    mmiEdition: TMenuItem;
    mmiStruct: TMenuItem;
    mmiStructTiers: TMenuItem;
    mmiEditionNouveau: TMenuItem;
    mmiEditionSupp: TMenuItem;
    mmiFichierFermer: TMenuItem;
    N1: TMenuItem;
    mmiFichierQuitter: TMenuItem;
    mmiFichier: TMenuItem;
    mmiFichierOuvrir: TMenuItem;
    mmMenu1: TMainMenu;
    OpenDialoglSelFic: TOpenDialog;
    Panel1: TPanel;
    StreamCpta: TAxcBSCPTAApplication100c;
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure mmiFichierFermerClick(Sender: TObject);
    procedure mmiFichierOuvrirClick(Sender: TObject);
    procedure mmiFichierQuitterClick(Sender: TObject);
    procedure mmiStructTiersClick(Sender: TObject);
  private
    FBaseCpta     : IBSCPTAApplication3;
    procedure InitMenu();
    procedure FermeMenu();
  public
    { Déclarations publiques }
    procedure CloseAllFrm();
  end;

var
  MainForm: TMainForm;

implementation

{$R *.lfm}

{ TMainForm }

procedure TMainForm.FormShow(Sender: TObject);
begin
  InitMenu();
end;
procedure TMainForm.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
//
end;
procedure TMainForm.mmiFichierOuvrirClick(Sender: TObject);
begin
  // Tojours même bug Lazarus, ne tient pas compte de la propriété définie dans l'éditeur.
  OpenDialoglSelFic.Title := 'Ouvrir un fichier existant';
  try
    if OpenDialoglSelFic.Execute then
    begin
      StreamCpta                  := TAxcBSCPTAApplication100c.Create(Self);
      FBaseCpta                   := StreamCpta.OleServer;
      FBaseCpta.Name              := OpenDialoglSelFic.FileName;
      FBaseCpta.Loggable.UserName := '<Administrateur>';
      FBaseCpta.Loggable.UserPwd  := '';
      Screen.Cursor := crHourGlass;
      FBaseCpta.Open;
      Screen.Cursor := crDefault;
      InitMenu();
    end;
  except on E: Exception do
    MessageErreur(E.Message);
  end;
end;
procedure TMainForm.mmiFichierFermerClick(Sender: TObject);
begin
//
end;
procedure TMainForm.mmiFichierQuitterClick(Sender: TObject);
begin
  CloseAllFrm();
  { A priori comme on sait qu'il n'y a qu'une fenêtre enfant ici on pourrait
    uniquement fermer ListeTiersForm comme ci-dessous, mais pas s'il y avait
    plusieurs fenêtres filles. }
//  if assigned(TListeTiersForm.ListeTiersForm) then
//    TListeTiersForm.ListeTiersForm.Close;
  FreeAndNil(StreamCpta);
  Close;
end;
procedure TMainForm.mmiStructTiersClick(Sender: TObject);
begin
//
end;
procedure TMainForm.FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState
  );
begin
//
end;

{$region 'Sub Frm'}

procedure TMainForm.InitMenu();
var BaseOuverte : Boolean;
begin
  BaseOuverte := False;
  try
    if FBaseCpta <> nil then BaseOuverte := FBaseCpta.IsOpen;
    mmiFichierOuvrir.Enabled  := not BaseOuverte;
    mmiFichierFermer.Enabled  := BaseOuverte;
    mmiEdition.Enabled        := BaseOuverte;
    mmiStruct.Enabled         := BaseOuverte;
  except on E: Exception do
  end;
end;
procedure TMainForm.FermeMenu;
begin
  try
    CloseAllFrm();
    { A priori comme on sait qu'il n'y a qu'une fenêtre enfant ici on pourrait
      uniquement fermer ListeTiersForm comme ci-dessous, mais pas s'il y avait
      plusieurs fenêtres filles. }
//    if assigned(TListeTiersForm.ListeTiersForm) then
//      TListeTiersForm.ListeTiersForm.Close;

    { Hack permettant de corriger le bug suivant : Si une fenêtre tiers est
      ouverte ET SI on a cliqué sur au moins un contact ou une banque, AV en
      sortie d'opération alors que la base est fermée. Pourtant le clic sur une
      banque ne fait quasimment rien, mais ProcessMessages résout le problème }
    Application.ProcessMessages;
    if ((FBaseCpta <> nil) and FBaseCpta.IsOpen) then
      FBaseCpta.Close;
    InitMenu();
  except on E: Exception do
    MessageErreur(E.Message);
  end;
end;
procedure TMainForm.CloseAllFrm;
var
  I: Integer;
begin
  { Méthode http://www.jmdoudoux.fr/delphi/fiche/index.htm }
  { Marche pas, vaut toujours 0 alors que l'autre OK }
//  for I := MDIChildCount - 1 downto 0 do
//    MDIChildren[I].Close;
  { ou }
//  for i:= 0 to MdiChildCount - 1 do
//    MDIChildren[i].Close;

  { Autre méthode http://delphi.about.com/od/vclusing/a/tscreen.htm :
  modifié en supposant que 0 est toujours le form principal }
  { Quand j'ai ouvert DetailFrm et fermé directement ListeTiersFrm plante car
   FormCount vaut 2 au lieu de 1 (ListeTiersFrm est toujours là
   Suite : Parce que je fermais mal les fenêtre, sinon marche mieux }
  for I := Screen.FormCount -1 downto 1 do
    Screen.Forms[I].Close;
end;

{$endregion}

end.

