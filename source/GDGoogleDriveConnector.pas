unit GDGoogleDriveConnector;

interface

uses
  System.SysUtils, System.Classes, System.Net.HttpClient, System.Net.URLClient,
  System.Net.Mime, GDOAuthConnector, System.IOUtils, System.JSON;

type
  TGDGoogleDriveConnector = class(TComponent)
  private
    FDrivePath: String;
    FFilePath: String;
    FOAuthConnector: TGDOAuthConnector;
    procedure SetDrivePath(const Value: String);
    procedure SetFilePath(const Value: String);
    procedure SetOAuthConnector(const Value: TGDOAuthConnector);
    function GetMimeType(const FileName: string): string;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure PostFile;
  published
    property DrivePath: String read FDrivePath write SetDrivePath;
    property FilePath: String read FFilePath write SetFilePath;
    property OAuthConnector: TGDOAuthConnector read FOAuthConnector
      write SetOAuthConnector;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Biblioteca GD', [TGDGoogleDriveConnector]);
end;

{ TGDGoogleDriveConnector }

constructor TGDGoogleDriveConnector.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
end;

destructor TGDGoogleDriveConnector.Destroy;
begin
  inherited;
end;

function TGDGoogleDriveConnector.GetMimeType(const FileName: string): string;
var
  Ext: string;
begin
  Ext := LowerCase(ExtractFileExt(FileName));

  if Ext = '.jpg' then
    Result := 'image/jpeg'
  else if Ext = '.png' then
    Result := 'image/png'
  else if Ext = '.pdf' then
    Result := 'application/pdf'
  else if Ext = '.txt' then
    Result := 'text/plain'
  else if Ext = '.doc' then
    Result := 'application/msword'
  else if Ext = '.docx' then
    Result := 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
  else
    Result := 'application/octet-stream'; // tipo MIME padrão
end;

procedure TGDGoogleDriveConnector.SetDrivePath(const Value: String);
begin
  FDrivePath := Value;
end;

procedure TGDGoogleDriveConnector.SetFilePath(const Value: String);
begin
  FFilePath := Value;
end;

procedure TGDGoogleDriveConnector.SetOAuthConnector
  (const Value: TGDOAuthConnector);
begin
  FOAuthConnector := Value;
end;

procedure TGDGoogleDriveConnector.PostFile;
var
  HttpClient: THTTPClient;
  HttpContent: TStringStream;
  HttpResponse: IHTTPResponse;
  AccessToken, ContentType: string;
  MetaData: TJSONObject;
  MetaDataString: string;
  FileContent: TStringList;
  ParentArray: TJSONArray;
  Boundary: string;
begin
  HttpClient := THTTPClient.Create;
  AccessToken := FOAuthConnector.GetToken;
  ContentType := GetMimeType(FFilePath);
  Boundary := 'foo_bar_baz'; // Isto é um delimitador arbitrário.

  // Cria o objeto de metadados.
  MetaData := TJSONObject.Create;
  MetaData.AddPair('name', ExtractFileName(FFilePath));
  ParentArray := TJSONArray.Create;
  ParentArray.Add(FDrivePath);
  MetaData.AddPair('parents', ParentArray);

  // Converte o objeto de metadados em uma string.
  MetaDataString := MetaData.ToString;

  // Lê o conteúdo do arquivo em uma TStringList.
  FileContent := TStringList.Create;
  FileContent.LoadFromFile(FFilePath);

  // Cria o corpo da solicitação.
  HttpContent := TStringStream.Create(
    '--' + Boundary + #13#10 +
    'Content-Type: application/json; charset=UTF-8' + #13#10#13#10 +
    MetaDataString + #13#10 +
    '--' + Boundary + #13#10 +
    'Content-Type: ' + ContentType + #13#10#13#10 +
    FileContent.Text + #13#10 +
    '--' + Boundary + '--'
  );

  try
    HttpClient.ContentType := 'multipart/related; boundary=' + Boundary;
    HttpClient.CustomHeaders['Authorization'] := 'Bearer ' + AccessToken;

    HttpResponse := HttpClient.Post('https://www.googleapis.com/upload/drive/v3/files?uploadType=multipart', HttpContent);

    if HttpResponse.StatusCode <> 200 then
      raise Exception.CreateFmt('Falha ao enviar o arquivo. Status: %d. Resposta: %s',
        [HttpResponse.StatusCode, HttpResponse.ContentAsString]);
  finally
    MetaData.Free;
    FileContent.Free;
    HttpContent.Free;
    HttpClient.Free;
    ParentArray.Free;
  end;
end;



end.
