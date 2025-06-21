unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, FileUtil, Graphics, Dialogs, IniFiles,
  StdCtrls, Windows, LCLIntf, ComCtrls, Buttons, ExtCtrls, Unit2, FreeImage;

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
    procedure ExecuteNoiser;
    procedure ExecuteDenoiser;
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
  FileNames: array[0..1] of string = ('noise.exe', 'noise.dpr');
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

function FlipVertical(const FileNameIn, FileNameOut: string): Boolean;
const
  DPI_VALUE = 3780; // 96 DPI em pixels por metro
var
  dib: PFIBITMAP;
  imageFormat: FREE_IMAGE_FORMAT;
  bpp: Integer;
begin
  Result := False;

  imageFormat := FreeImage_GetFileType(PChar(FileNameIn), 0);
  if imageFormat = FIF_UNKNOWN then
    imageFormat := FreeImage_GetFIFFromFilename(PChar(FileNameIn));

  if (imageFormat = FIF_UNKNOWN) or (not FreeImage_FIFSupportsReading(imageFormat)) then
    Exit;

  dib := FreeImage_Load(imageFormat, PChar(FileNameIn), BMP_DEFAULT);
  if dib = nil then Exit;

  try
    // Verifica se é 8bpp (indexada)
    bpp := FreeImage_GetBPP(dib);
    if bpp <> 8 then
    begin
      ShowMessage('The image below has no palette. EasyNoiser works only with indexed color images (8bpp):' + FileNameIn);
      Exit;
    end;

    if not FreeImage_FlipVertical(dib) then Exit;

    // Define DPI para 96 (3780 pixels por metro)
    FreeImage_SetDotsPerMeterX(dib, DPI_VALUE);
    FreeImage_SetDotsPerMeterY(dib, DPI_VALUE);

    if not FreeImage_Save(FIF_BMP, dib, PChar(FileNameOut), BMP_DEFAULT) then
      Exit;

    Result := True;
  finally
    FreeImage_Unload(dib);
  end;
end;

procedure FlipAllBMPsInFolder(const InputFolder: string);
var
  SR: TSearchRec;
  FilePath: string;
begin
  if not DirectoryExists(InputFolder) then
  begin
    ShowMessage('Input folder not found: ' + InputFolder);
    Exit;
  end;

  if FindFirst(InputFolder + '\*.bmp', faAnyFile, SR) = 0 then
  begin
    repeat
      if (SR.Attr and faDirectory) = 0 then
      begin
        FilePath := IncludeTrailingPathDelimiter(InputFolder) + SR.Name;

        if FlipVertical(FilePath, FilePath) then
          // ShowMessage('Invertido: ' + SR.Name); // se quiser ver um a um
        else
          ShowMessage('Error when inverting: ' + SR.Name);
      end;
    until FindNext(SR) <> 0;
    SysUtils.FindClose(SR);
  end
  else
    ShowMessage('No BMP file was found in the folder.');
end;

function ConvertPNGToBMP(const FileNameIn, FileNameOut: string): Boolean;
var
  dib: PFIBITMAP;
  inputFormat: FREE_IMAGE_FORMAT;
begin
  Result := False;

  // Detecta o formato do arquivo de entrada
  inputFormat := FreeImage_GetFileType(PChar(FileNameIn), 0);
  if inputFormat = FIF_UNKNOWN then
    inputFormat := FreeImage_GetFIFFromFilename(PChar(FileNameIn));

  // Verifica se o formato é válido e pode ser lido
  if (inputFormat = FIF_UNKNOWN) or (not FreeImage_FIFSupportsReading(inputFormat)) then
  begin
    ShowMessage('Unsupported input format for: ' + FileNameIn);
    Exit;
  end;

  // Carrega a imagem
  dib := FreeImage_Load(inputFormat, PChar(FileNameIn), PNG_DEFAULT);
  if dib = nil then
  begin
    ShowMessage('Failed to load image: ' + FileNameIn);
    Exit;
  end;

  try
    // Converte e salva como BMP
    if not FreeImage_Save(FIF_BMP, dib, PChar(FileNameOut), BMP_DEFAULT) then
    begin
      ShowMessage('Failed to save BMP file: ' + FileNameOut);
      Exit;
    end;

    Result := True;
  finally
    FreeImage_Unload(dib);
  end;
end;

procedure ConvertAllPNGsToBMPs(const InputFolder: string);
var
  SR: TSearchRec;
  PngPath, BmpPath, FileNameNoExt: string;
begin
  if not DirectoryExists(InputFolder) then
  begin
    ShowMessage('Input folder not found: ' + InputFolder);
    Exit;
  end;

  if FindFirst(InputFolder + '\*.png', faAnyFile, SR) = 0 then
  begin
    repeat
      if (SR.Attr and faDirectory) = 0 then
      begin
        PngPath := IncludeTrailingPathDelimiter(InputFolder) + SR.Name;
        FileNameNoExt := ChangeFileExt(SR.Name, '');
        BmpPath := IncludeTrailingPathDelimiter(InputFolder) + FileNameNoExt + '.bmp';

        if not ConvertPNGToBMP(PngPath, BmpPath) then
          ShowMessage('Failed to convert: ' + SR.Name);
      end;
    until FindNext(SR) <> 0;
    SysUtils.FindClose(SR);
  end
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
    ShowMessage('Error when running the script: ' + FileName);
end;

procedure TForm1.ExecuteNoiser;
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

    // Run Noiser
    Writeln(F, 'cd /D "' + SpritesDir + '"');
    Writeln(F, 'for %%i in (*.bmp) do noise "%%i" /n');

    // Delete files
    Writeln(F, 'del noise.exe');
    Writeln(F, 'del noise.dpr');
  finally
    CloseFile(F);
  end;

  RunAndWait(PChar(BatPath));
  DeleteFile(PChar(BatPath)); // Corrigido para aceitar AnsiString
end;

procedure TForm1.ExecuteDenoiser;
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

    Writeln(F, 'cd /D "' + SpritesDir + '"');
    Writeln(F, 'for %%i in (*.bmp) do noise "%%i"');

    // Delete copies of the executables
    Writeln(F, 'del noise.exe');
    Writeln(F, 'del noise.dpr');
  finally
    CloseFile(F);
  end;

  RunAndWait(PChar(BatPath));
  DeleteFile(PChar(BatPath)); // Corrigido para aceitar AnsiString
end;

procedure TForm1.ButtonNoiseClick(Sender: TObject);
var
  imgFolder: string;
begin
  imgFolder := FieldPath.Text;
  EnableOrDisableObjects(False);
  LabelProgress.Caption:='Processing images...';

  // FreeImage
  FreeImage_Initialise(False);

  ConvertAllPNGsToBMPs(FieldPath.Text); // Convert PNG files

  // You can see below how the noise process works //////////////////////

  FlipAllBMPsInFolder(imgFolder); // Invert and set the images' DP! to 96

  ExecuteNoiser; // Call Noiser to process the files

  FlipAllBMPsInFolder(imgFolder); // Repeat the process with images

  // End of the process /////////////////////////////////////////////////

  FreeImage_DeInitialise;

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
var
  imgFolder: string;
begin
  imgFolder := FieldPath.Text;
  EnableOrDisableObjects(False);
  LabelProgress.Caption:='Processing images...';

  // FreeImage
  FreeImage_Initialise(False);

  ConvertAllPNGsToBMPs(FieldPath.Text); // Convert PNG files

  // You can see below how the noise process works //////////////////////

  FlipAllBMPsInFolder(imgFolder); // Invert and set the images' DP! to 96

  ExecuteDenoiser; // Call Denoiser to process the files

  FlipAllBMPsInFolder(imgFolder); // Repeat the process with images

  // End of the process /////////////////////////////////////////////////

  FreeImage_DeInitialise;

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

