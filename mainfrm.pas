unit mainfrm;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, Menus,
  ActnList, ExtCtrls, Objets100cLib_3_0_TLB,
  LCLType { pour VK_ESCAPE };

type

  { TMainForm }

  TMainForm = class(TForm)
    mmMenu1: TMainMenu;
    mmiFichier: TMenuItem;
    mmiFichierOuvrir: TMenuItem;
    mmiFichierFermer: TMenuItem;
    mmiFichierQuitter: TMenuItem;
    mmiEdition: TMenuItem;
    mmiEditionNouveau: TMenuItem;
    mmiEditionSupp: TMenuItem;
    mmiStruct: TMenuItem;
    mmiStructTiers: TMenuItem;
    N1: TMenuItem;
    OpenDialoglSelFic: TOpenDialog;
    Panel1: TPanel;
    alEdition: TActionList;
    aliEditionNouveau: TAction;
    aliEditionSupp: TAction;
    StreamCpta: TAxcBSCPTAApplication100c;
    procedure FormShow(Sender: TObject);
    procedure mmiFichierOuvrirClick(Sender: TObject);
    procedure mmiFichierFermerClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure mmiFichierQuitterClick(Sender: TObject);
    procedure mmiStructTiersClick(Sender: TObject);
//    procedure mmiEditionNouveauClick(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    FBaseCpta     : IBSCPTAApplication3;
    FTiersCourant : IBOTiers3;
//    FListeTiers   : FrmListeTiers;
    procedure InitMenu();
    procedure FermeMenu();
  public
    { Déclarations publiques }
    procedure CloseAllFrm();
  end;

var
  MainForm: TMainForm;

implementation

uses detailfrm, listetiersfrm, NewTiersFrm, commun;

{$R *.lfm}

{ TMainForm }
{$region 'Events Frm'}

procedure TMainForm.FormShow(Sender: TObject);
begin
  InitMenu();
end;
procedure TMainForm.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  FermeMenu;
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
  FermeMenu;
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
  try
    CloseAllFrm();
    { A priori comme on sait qu'il n'y a qu'une fenêtre enfant ici on pourrait
      uniquement fermer ListeTiersForm comme ci-dessous, mais pas s'il y avait
      plusieurs fenêtres filles. }
//    if assigned(TListeTiersForm.ListeTiersForm) then
//      TListeTiersForm.ListeTiersForm.Close;
    TListeTiersForm.ListeTiersForm := TListeTiersForm.Create(Self, FBaseCpta);
    TListeTiersForm.ListeTiersForm.Show();
  except on E: Exception do
    MessageErreur(E.Message);
  end;
end;
procedure TMainForm.FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState
  );
begin
{ VB :
  If e.KeyCode = Keys.Escape AndAlso Not Me.ActiveMdiChild Is Nothing Then
      Me.ActiveMdiChild.Close()
  End If }

{ Marche pas comme VB }
  if (Key = VK_ESCAPE) and (MDIChildCount > 0) then
      MDIChildren[0].Close;
end;

{ Remplacé par un TactionList }
//procedure TMainForm.mmiEditionNouveauClick(Sender: TObject);
//var
//  A : Integer;
//begin
//  { A priori ne sert à rien (c'était dans ex VB }
//  A := 3;
//end;

{$endregion}

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

