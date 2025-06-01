unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, FileUtil, Graphics, Dialogs, IniFiles,
  StdCtrls, Windows, LCLIntf, ComCtrls, Buttons, ExtCtrls, Unit2;

type

  { TForm1 }

  TForm1 = class(TForm)
    ButtonAbout: TButton;
    ButtonOpenExplorer: TButton;
    ButtonBrowse: TButton;
    ButtonDenoise: TButton;
    ButtonNoise: TButton;
    CheckBoxOpenFolder: TCheckBox;
    DirectoryLabel: TLabel;
    FieldPath: TEdit;
    LabelProgress: TLabel;
    LabelInfo: TLabel;
    SelectDirectoryDialog1: TSelectDirectoryDialog;
    ButtonYoutube: TSpeedButton;
    ButtonSupport: TSpeedButton;
    procedure ButtonAboutClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ButtonBrowseClick(Sender: TObject);
    procedure ButtonDenoiseClick(Sender: TObject);
    procedure ButtonNoiseClick(Sender: TObject);
    procedure ButtonOpenExplorerClick(Sender: TObject);
    procedure CheckFiles;
    procedure ExecutarNoiser;
    procedure ExecutarDenoiser;
    procedure EnableOrDisableObjects(Status: Boolean);
    procedure VerificarCheckBoxOpenFolder;
    function GetImageDirectory: string;
    procedure ButtonYoutubeClick(Sender: TObject);
    procedure ButtonSupportClick(Sender: TObject);
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

procedure TForm1.CheckFiles;
var
  ExecutablePath: string;
  FileNames: array[0..3] of string = ('noise.exe', 'noise.dpr', 'VampConvert.exe', 'ajustar_dpi_lote.exe');
  i: Integer;
  FilePath: string;
begin
  // Obtém o diretório do executável atual
  ExecutablePath := ExtractFilePath(ParamStr(0));

  // Verifica se os arquivos existem
  for i := Low(FileNames) to High(FileNames) do
  begin
    FilePath := IncludeTrailingPathDelimiter(ExecutablePath) + FileNames[i];
    if not FileExists(FilePath) then
    begin
      // Exibe a mensagem de erro
      ShowMessage('The file "' + FileNames[i] + '" was not found!' +
                  sLineBreak + 'The program will be closed!');

      // Encerra a aplicação
      Application.Terminate;
      Exit; // Adiciona um Exit para garantir que não continue após a terminação
    end;
  end;
end;


{ TForm1 }


procedure TForm1.VerificarCheckBoxOpenFolder;
var
  ConfigFile: TIniFile;
  ConfigPath, PastaAbrir: string;
begin
  ConfigPath := ExtractFilePath(ParamStr(0)) + 'config.ini';
  PastaAbrir := FieldPath.Text;

  ConfigFile := TIniFile.Create(ConfigPath);
  try
    // Escreve a configuração de abrir pasta na seção 'Geral'
    ConfigFile.WriteBool('Settings', 'AbrirPasta', CheckBoxOpenFolder.Checked);

    // Se marcado, abre a pasta
    if CheckBoxOpenFolder.Checked then
    begin
      if DirectoryExists(PastaAbrir) then
      begin
        ShellExecute(0, 'open', 'cmd.exe',
          PChar('/C start "" /MAX explorer.exe "' + PastaAbrir + '"'),
          nil, SW_HIDE);
      end;
    end;
  finally
    ConfigFile.Free;
  end;
end;

procedure RunAndWait(const FileName: string);
var
  StartInfo: TStartupInfo;
  ProcInfo: TProcessInformation;
begin
  ZeroMemory(@StartInfo, SizeOf(StartInfo));
  StartInfo.cb := SizeOf(StartInfo);
  StartInfo.dwFlags := STARTF_USESHOWWINDOW;
  StartInfo.wShowWindow := SW_SHOWNORMAL; // exibe a janela do terminal

  if CreateProcess(nil, PChar(FileName), nil, nil, False, 0, nil, nil, StartInfo, ProcInfo) then
  begin
    WaitForSingleObject(ProcInfo.hProcess, INFINITE);
    CloseHandle(ProcInfo.hProcess);
    CloseHandle(ProcInfo.hThread);
  end
  else
    ShowMessage('Erro ao executar o script: ' + FileName);
end;

procedure TForm1.ExecutarNoiser;
var
  SpritesDir, ExecDir: string;
  F: TextFile;
  BatPath: string;
begin
  SpritesDir := FieldPath.Text;
  ExecDir := ExtractFilePath(ParamStr(0));
  BatPath := ExecDir + 'temp_script.bat';

  // Writing a batch file to run
  AssignFile(F, BatPath);
  Rewrite(F);
  try
    Writeln(F, '@echo off');

    // Copy programs to the pics folder
    Writeln(F, 'copy "' + ExecDir + 'noise.exe" "' + SpritesDir + '\noise.exe"');
    Writeln(F, 'copy "' + ExecDir + 'noise.dpr" "' + SpritesDir + '\noise.dpr"');
    Writeln(F, 'copy "' + ExecDir + 'VampConvert.exe" "' + SpritesDir + '\VampConvert.exe"');
    Writeln(F, 'copy "' + ExecDir + 'ajustar_dpi_lote.exe" "' + SpritesDir + '\ajustar_dpi_lote.exe"');
    Writeln(F, 'cd /D "' + SpritesDir + '"');


    Writeln(F, 'for %%f in (*.bmp) do VampConvert -infile="%%f" -outfile="%%f" -flip');
    Writeln(F, 'ajustar_dpi_lote.exe "' + SpritesDir + '"');
    Writeln(F, 'for %%i in (*.bmp) do noise "%%i" /n');
    Writeln(F, 'for %%f in (*.bmp) do VampConvert -infile="%%f" -outfile="%%f" -flip');
    Writeln(F, 'ajustar_dpi_lote.exe "' + SpritesDir + '"');
    Writeln(F, 'del noise.exe');
    Writeln(F, 'del noise.dpr');
    Writeln(F, 'del VampConvert.exe');
    Writeln(F, 'del ajustar_dpi_lote.exe');
  finally
    CloseFile(F);
  end;

  RunAndWait(PChar(BatPath));
  DeleteFile(PChar(BatPath)); // Corrigido para aceitar AnsiString
end;

procedure TForm1.ExecutarDenoiser;
var
  SpritesDir, ExecDir: string;
  F: TextFile;
  BatPath: string;
begin
  SpritesDir := FieldPath.Text;
  ExecDir := ExtractFilePath(ParamStr(0));
  BatPath := ExecDir + 'temp_script.bat';

  // Writing a batch file to run
  AssignFile(F, BatPath);
  Rewrite(F);
  try
    Writeln(F, '@echo off');
    // Copy programs to the pics folder
    Writeln(F, 'copy "' + ExecDir + 'noise.exe" "' + SpritesDir + '\noise.exe"');
    Writeln(F, 'copy "' + ExecDir + 'noise.dpr" "' + SpritesDir + '\noise.dpr"');
    Writeln(F, 'copy "' + ExecDir + 'VampConvert.exe" "' + SpritesDir + '\VampConvert.exe"');
    Writeln(F, 'copy "' + ExecDir + 'ajustar_dpi_lote.exe" "' + SpritesDir + '\ajustar_dpi_lote.exe"');
    Writeln(F, 'cd /D "' + SpritesDir + '"');

    // Convert png to bmp while invert them and delete png files
    Writeln(F, 'for %%f in (*.png) do VampConvert -infile="%%f.bmp" -outfile="%%f" -flip');
    Writeln(F, 'for %%f in (*.bmp) do VampConvert -infile="%%f" -outfile="%%f" -flip');
    Writeln(F, 'del *.png');

    Writeln(F, 'ajustar_dpi_lote.exe "' + SpritesDir + '"');
    Writeln(F, 'for %%i in (*.bmp) do noise "%%i"');
    Writeln(F, 'for %%f in (*.bmp) do VampConvert -infile="%%f" -outfile="%%f" -flip');
    Writeln(F, 'ajustar_dpi_lote.exe "' + SpritesDir + '"');

    // Delete copies of the executables
    Writeln(F, 'del noise.exe');
    Writeln(F, 'del noise.dpr');
    Writeln(F, 'del VampConvert.exe');
    Writeln(F, 'del ajustar_dpi_lote.exe');
  finally
    CloseFile(F);
  end;

  RunAndWait(PChar(BatPath));
  DeleteFile(PChar(BatPath)); // Corrigido para aceitar AnsiString
end;

procedure TForm1.ButtonNoiseClick(Sender: TObject);
begin
  EnableOrDisableObjects(False);
  LabelProgress.Caption:='Processing images...';
  ExecutarNoiser;
  LabelProgress.Caption:='DONE!';
  VerificarCheckBoxOpenFolder;
  EnableOrDisableObjects(True);
end;

procedure TForm1.EnableOrDisableObjects(Status: Boolean);
begin
  ButtonNoise.Enabled := Status;
  ButtonDenoise.Enabled := Status;
  ButtonBrowse.Enabled := Status;
  ButtonOpenExplorer.Enabled := Status; // Corrigido aqui
  FieldPath.Enabled := Status;
end;

procedure TForm1.ButtonOpenExplorerClick(Sender: TObject);
begin
  if DirectoryExists(FieldPath.Text) then
  begin
    ShellExecute(0, 'open', 'explorer.exe', PChar(FieldPath.Text), nil, SW_NORMAL);
  end
  else
    ShowMessage('The directory provided does not exist.');
end;

procedure TForm1.ButtonBrowseClick(Sender: TObject);
var
  SelectedDir: string;
  ConfigFile: TIniFile;
  ConfigPath: string;
begin
  SelectDirectoryDialog1.InitialDir := ExtractFileDir(ParamStr(0));
  if SelectDirectoryDialog1.Execute then
  begin
    SelectedDir := SelectDirectoryDialog1.Filename;
    if DirectoryExists(SelectedDir) then
    begin
      // Define o conteúdo do Text Field
      FieldPath.Text := SelectedDir;

      // Caminho do arquivo de configuração (no mesmo diretório do executável)
      ConfigPath := ExtractFilePath(ParamStr(0)) + 'config.ini';

      // Cria ou abre o arquivo INI e grava a seção/campo
      ConfigFile := TIniFile.Create(ConfigPath);
      try
        ConfigFile.WriteString('Paths', 'ImageDirectory', SelectedDir);
      finally
        ConfigFile.Free;
      end;
    end;
  end
  else
    ShowMessage('No directory selected');
end;

procedure TForm1.ButtonDenoiseClick(Sender: TObject);
begin
  EnableOrDisableObjects(False);
  LabelProgress.Caption:='Processing images...';
  ExecutarDenoiser;
  LabelProgress.Caption:='DONE!';
  VerificarCheckBoxOpenFolder;
  EnableOrDisableObjects(True);
end;

function TForm1.GetImageDirectory: string;
var
  ConfigFile: TIniFile;
  ConfigPath: string;
begin
  // Caminho do arquivo de configuração (no mesmo diretório do executável)
  ConfigPath := ExtractFilePath(ParamStr(0)) + 'config.ini';

  // Verifica se o arquivo de configuração existe
  if FileExists(ConfigPath) then
  begin
    ConfigFile := TIniFile.Create(ConfigPath);
    try
      // Lê o valor da chave 'ImageDirectory' na seção 'Paths'
      Result := ConfigFile.ReadString('Paths', 'ImageDirectory', '');
    finally
      ConfigFile.Free;
    end;
  end
  else
  begin
    // Retorna uma string vazia se o arquivo não existir
    Result := '';
  end;
end;

procedure TForm1.ButtonYoutubeClick(Sender: TObject);
begin
  OpenURL('https://www.youtube.com/channel/UCvWEo-Qj_iOsRTsz4KqP_lA');
end;

procedure TForm1.ButtonSupportClick(Sender: TObject);
begin
  OpenURL('https://ko-fi.com/danchavyn');
end;


procedure TForm1.FormCreate(Sender: TObject);
var
  ConfigFile: TIniFile;
  ConfigPath: string;
  ImageDirectory: string;
  AbrirPasta: Boolean; // Substitui AbrirPastaSetting
begin
  // Verifica a existência dos arquivos essênciais
  CheckFiles;

  LabelProgress.Caption := '';

  // Caminho do arquivo de configuração (no mesmo diretório do executável)
  ConfigPath := ExtractFilePath(ParamStr(0)) + 'config.ini';
  ImageDirectory := ExtractFilePath(ParamStr(0)) + 'pics';

  // Caso não exista arquivo de configuração...
  if not FileExists(ConfigPath) then
  begin
    // Cria ou abre o arquivo INI e grava valores padrões
    ConfigFile := TIniFile.Create(ConfigPath);
    try
      ConfigFile.WriteString('Paths', 'ImageDirectory', ImageDirectory);
      ConfigFile.WriteBool('Settings', 'AbrirPasta', False); // valor padrão
    finally
      ConfigFile.Free;
    end;

    // Verifica se o diretório de imagens existe
    if not DirectoryExists(ImageDirectory) then
    begin
      // Tenta criar o diretório
      if not CreateDir(ImageDirectory) then
        ShowMessage('Failed to create directory!');
    end;
  end;

  // Cria uma instância de TIniFile para leitura
  ConfigFile := TIniFile.Create(ConfigPath);
  try
    // Lê o diretório da chave 'ImageDirectory' na seção 'Paths'
    ImageDirectory := ConfigFile.ReadString('Paths', 'ImageDirectory', '');

    // Lê a configuração da chave 'AbrirPasta' como booleano na seção 'Geral'
    AbrirPasta := ConfigFile.ReadBool('Settings', 'AbrirPasta', False);

    if AbrirPasta then
      begin
        CheckBoxOpenFolder.Checked := True;
      end
    else
      begin
        CheckBoxOpenFolder.Checked := False;
      end;

  finally
    ConfigFile.Free; // Libera a memória
  end;

  // Atualiza o campo de texto com o diretório de imagem
  FieldPath.Text := GetImageDirectory;
end;

procedure TForm1.ButtonAboutClick(Sender: TObject);
begin
  Form3.Left := Self.Left;
  Form3.Top := Self.Top;
  Form3.ShowModal;
end;


// Chama o procedimento ao iniciar o programa
initialization

end.

