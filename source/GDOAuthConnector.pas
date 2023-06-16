unit GDOAuthConnector;

interface

uses
  System.Classes,
  JOSE.Core.JWT,
  JOSE.Core.Builder,
  JOSE.Core.JWK,
  JOSE.Core.JWS,
  JOSE.Types.Bytes,
  JOSE.Encoding.Base64,
  JOSE.Consumer,
  DateUtils,
  IdHTTP,
  JOSE.Core.JWA.Encryption,
  JOSE.Producer,
  System.SysUtils,
  JOSE.Core.Base,
  JOSE.Core.Parts,
  JOSE.Core.JWA,
  JOSE.Core.JWE,
  JOSE.Context,
  JOSE.Consumer.Validators,
  System.Net.HttpClient,
  System.NetEncoding,
  System.JSON,
  Vcl.Dialogs,
  Clipbrd,
  REST.OpenSSL;

type
  TGDOAuthConnector = class(TComponent)
  private
    FPrivateKey: String;
    procedure SetPrivateKey(const Value: String);
    function GenerateSignedJWT: String;
    function VerifyAccessToken(accessToken: string): Boolean;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function GetToken: String;
    function VerifySignature(AToken: String): Boolean;
  published
    property PrivateKey: String read FPrivateKey write SetPrivateKey;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Biblioteca GD', [TGDOAuthConnector]);
end;

{ TGDOAuthConnector }

constructor TGDOAuthConnector.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
end;

destructor TGDOAuthConnector.Destroy;
begin
  inherited;
end;

procedure TGDOAuthConnector.SetPrivateKey(const Value: String);
begin
  FPrivateKey := Value;
end;

function TGDOAuthConnector.GenerateSignedJWT: string;
var
  //LPrivateKey: TOpenSSLAsymmetricKey;
  LToken: string;
  //LToken: string;
  HttpClient: THTTPClient;
  RequestContent: TStringStream;
  ResponseContent: TStringStream;
  ResponseJSON: TJSONObject;
  accessToken: string;
begin
 { LPrivateKeyBytes := TNetEncoding.Base64.DecodeStringToBytes(FPrivateKey);

  try
    // Cria o objeto TRSAKey com a chave privada
    LKey := TRSAKey.Create(LPrivateKeyBytes);

    try
      // Gera o token JWT usando a chave privada
      LToken := TJOSE.SignedJWT(['RS256'])
        .Claims.SetClaim('iss', 'Delphi JOSE Library')
        .Claims.SetClaim('iat', Now)
        .Claims.SetClaim('exp', Now + 1)
        .SigningKey(LKey)
        .CompactToken;

      // Faça o que você precisa com o token gerado...
    finally
      LKey.Free;
    end;
  finally
    SetLength(LPrivateKeyBytes, 0);
  end;

  HttpClient := THTTPClient.Create;
  RequestContent := TStringStream.Create('');
  ResponseContent := TStringStream.Create;

  try
    RequestContent.WriteString('grant_type=' + TNetEncoding.URL.Encode
      ('authorization_code'));
    RequestContent.WriteString('&assertion=' + TNetEncoding.URL.Encode(LToken));

    HttpClient.ContentType := 'application/x-www-form-urlencoded';
    HttpClient.Post('https://oauth2.googleapis.com/token', RequestContent,
      ResponseContent);
    // Exibir a resposta JSON para fins de depuração
    Clipboard.AsText:= LToken;
    ShowMessage(ResponseContent.DataString);
    ResponseJSON := TJSONObject.ParseJSONValue(ResponseContent.DataString)
      as TJSONObject;
    try
      accessToken := ResponseJSON.GetValue('access_token').Value;
    finally
      ResponseJSON.Free;
    end;
  finally
    HttpClient.Free;
    RequestContent.Free;
    ResponseContent.Free;
  end;

  Result := accessToken; }
end;

function TGDOAuthConnector.VerifyAccessToken(accessToken: string): Boolean;
var
  HttpClient: THTTPClient;
  HttpResponse: IHTTPResponse;
begin
  HttpClient := THTTPClient.Create;
  try
    HttpClient.CustomHeaders['Authorization'] := 'Bearer ' + accessToken;
    HttpResponse := HttpClient.Get
      ('https://www.googleapis.com/oauth2/v3/userinfo');

    Result := HttpResponse.StatusCode = 200;
  finally
    HttpClient.Free;
  end;
end;

function TGDOAuthConnector.VerifySignature(AToken: String): Boolean;
var
  LKey: TJWK;
  LToken: TJWT;
begin
  LKey := TJWK.Create(FPrivateKey);

  try
    LToken := TJOSE.Verify(LKey, AToken);

    try
      Result := Assigned(LToken) and LToken.Verified;
    finally
      LToken.Free;
    end;
  finally
    LKey.Free;
  end;
end;

function TGDOAuthConnector.GetToken: String;
var
  LToken: String;
begin
  LToken := GenerateSignedJWT;
  if VerifyAccessToken(LToken) then
  begin
    Result := LToken;
  end
  else
    Result := '';

end;

end.
