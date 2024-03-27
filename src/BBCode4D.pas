unit BBCode4D;

(*
  BBCODE FOR DELPHI
  ---------------------------------------
  Esta classe faz toda a parte de controle das mensagens e textos com tags de
  personalização BBCode, podendo ser possivel retirálas ou as converter em um
  arquivo RFT que pode ser inserido em um TRichEdit através da função
  WriteRichText que se encontra em BBCode4D.Utils

  ------------------------------------------------------------------------------
  by Weslley Capelari (22/03/2024)
*)

interface

uses
  Windows,
  Graphics,
  Winapi.RichEdit,
  Vcl.ComCtrls,
  System.Math,
  System.Classes,
  System.SysUtils,
  System.StrUtils,
  System.RegularExpressions,
  System.Generics.Collections;

type
  TBBCode4D = class
  {$REGION 'Util Types'}
  private type
    TEditStreamCallBack = function(dwCookie: LongInt; pbBuff: PByte;
      cb: LongInt; var pcb: LongInt): DWORD; stdcall;

    TEditStreamData = packed record
      dwCookie   : LongInt;
      dwError    : LongInt;
      pfnCallback: TEditStreamCallBack;
    end;
  {$ENDREGION}
  private const
    C_DEFAULT_ALIGN: string  = 'left';
    C_DEFAULT_COLOR: string  = '#000000';
    C_DEFAULT_FONT : string  = 'Calibri';
    C_DEFAULT_SIZE : Integer = 16;
    C_DEFAULT_LIST_SPACE : string = '\fi-360\li720';
    C_DEFAULT_LIST_SYMBOL: string = '\''B7';
  private
    FBBCode: string;
    FRichText: string;
    FClearText: string;
    FFonts: TList<string>;
    FColors: TList<TColor>;

    {$REGION 'Util Functions'}

    /// <summary>
    ///   Função responsável por retornar um string do tipo Hexadecimal de
    ///   acordo com um valor TColor parametrizado.
    /// </summary>
    /// <param name="AColor">A cor do sistema a ser utilizada.</param>
    /// <param name="AHastag">Se deve incluir a hashtag no retorno.</param>
    /// <returns>O texto contendo a cor indicada em Hexadecimal.</returns>
    /// <remarks>
    ///   Exemplo: <code>ColorToHex($FF000000);</code>
    ///   Resultado: <code>'#000000'</code>
    /// </remarks>
    function ColorToHex(const AColor: TColor;
      const AHastag: Boolean = True): string;


    /// <summary>
    ///   Função responsável por retornar um TColor de acordo com um valor
    ///   Hexadecimal parametrizado.
    /// </summary>
    /// <param name="AColor">A cor em Hexadecimal a ser utilizada.</param>
    /// <returns>A cor em TColor de acordo com o Hexadecimal enviado.</returns>
    /// <remarks>
    ///   Exemplo: <code>HexToColor('#000000');</code>
    ///   Resultado: <code>$FF000000</code>
    /// </remarks>
    function HexToColor(const AColor: string): TColor;

    /// <summary>
    ///   Função responsável por retornar uma string do tipo Rich EditColor
    ///   de acordo com um valor TColor parametrizado.
    /// </summary>
    /// <param name="AColor">A cor do sistema a ser utilizada.</param>
    /// <returns>
    ///   O texto contendo a cor para ser utilizada num TRichEdit.
    /// </returns>
    /// <remarks>
    ///   Exemplo: <code>ColorToRichColor($FF000000);</code>
    ///   Resultado: <code>'\red0\green0\blue0;'</code>
    /// </remarks>
    function ColorToRichColor(const AColor: TColor): string;

    /// <summary>
    ///   Função responsável por retornar uma string do tipo Rich EditColor
    ///   de acordo com um valor Hexadecimal parametrizado.
    /// </summary>
    /// <param name="AColor">A cor em Hexadecimal a ser utilizada.</param>
    /// <returns>
    ///   O texto contendo a cor para ser utilizada num TRichEdit.
    /// </returns>
    /// <remarks>
    ///   Exemplo: <code>HexToRichColor('#000000');</code>
    ///   Resultado: <code>'\red0\green0\blue0;'</code>
    /// </remarks>
    function HexToRichColor(const AColor: string): string;

    /// <summary>
    ///   Função responsável por escrever o texto enviado no TRichEdit.
    /// </summary>
    /// <param name="ARichEdit">O TRichEdit onde será escrito o texto.</param>
    /// <param name="AText">O texto a ser escrito.</param>
    /// <remarks>
    ///   Exemplo:
    ///   <code>WriteRichText(LMeuRichEdit, 'Quero escrever isso');</code>
    /// </remarks>
    procedure WriteRichText(var ARichEdit: TRichEdit; const AText: string);

    function GetIndexAlpha(const AIndex: Integer): string;
    function GetIndexRoman(const AIndex: Integer): string;

    {$ENDREGION}

    {$REGION 'BBCodeToRTF Functions'}
    function GetDefaultFormat: string;
    function GetColorList: string;
    function GetFontList: string;
    function AddColor(const AColor: string): Integer;
    function AddFont(const AFont: string): Integer;
    function FindTagContent(const AText: string; var ATagName, AAttr,
      AFullOpenTag, AFullCloseTag, AContent: string;
      var AIndex: Int64): Boolean;
    procedure ProccessTags(var AText: string;
      const ACurrColor, ACurrFont, ACurrSize: Integer;
      const ACurrAlign: string; const ACurrListType: string = ''; 
      const ACurrListItem: Integer = 1);
    function GetAttrDictionary(
      const AAttributes: string): TDictionary<string, string>;
    procedure ProccessTagColor(var AText: string; var ACurrColor: Integer;
      const AAttr: TDictionary<string, string>);
    procedure ProccessTagSize(var AText: string; var ACurrSize: Integer;
      const AAttr: TDictionary<string, string>);
    procedure ProccessTagFont(var AText: string; var ACurrFont: Integer;
      const AAttr: TDictionary<string, string>);
    procedure ProccessTagAlign(var AText, ACurrAlign: string;
      const AAttr: TDictionary<string, string>);
    procedure ProccessTagList(var AText, ATagName, ACurrList: string;
      var ACurrFont: Integer; const AAttr: TDictionary<string, string>);
    procedure ProccessTagListItem(var AText, ACurrList: string;
      var ACurrItem, ACurrFont: Integer;
      const AAttr: TDictionary<string, string>);
    procedure ProccessTagUrl(var AText: string; var ACurrFont,
      ACurrSize: Integer; const AAttr: TDictionary<string, string>);
    procedure ProccessTagEmail(var AText: string; var ACurrFont,
      ACurrSize: Integer; const AAttr: TDictionary<string, string>);
    procedure ProccessTagImage(var AText: string; var ACurrFont,
      ACurrSize: Integer; const AAttr: TDictionary<string, string>);
    {$ENDREGION}

    { RTFToBBCode Functions }

    procedure BBCodeToRTF;
    procedure RTFToBBCode;

    procedure ClearTags(var AText: string);

    constructor Create;
  public
    class function ParseBBCode(const AText: string): TBBCode4D;
    class function ParseRTF(const AText: string): TBBCode4D;

    function GetClearText: string;

    procedure WriteToRich(var ARichEdit: TRichEdit);

    property BBCode   : string read FBBCode;
    property RichText : string read FRichText;
    property ClearText: string read FClearText;
  end;

function EditStreamReader(dwCookie: DWORD_PTR; pbBuff: PByte;
  cb: Longint; var pcb: Longint): Longint; stdcall;

implementation

{ TBBCode4D }

function TBBCode4D.AddColor(const AColor: string): Integer;
var
  LColor: TColor;
  LCount: Integer;
begin
  LColor := HexToColor(AColor);
  for LCount := 0 to (FColors.Count - 1) do
    if FColors.Items[LCount] = LColor then
      Exit(LCount);

  FColors.Add(LColor);
  Result := FColors.Count;
end;

function TBBCode4D.AddFont(const AFont: string): Integer;
var
  LCount: Integer;
begin
  for LCount := 0 to (FFonts.Count - 1) do
    if FFonts.Items[LCount].ToLower.Equals(AFont.ToLower) then
      Exit(LCount);

  FFonts.Add(AFont);
  Result := FFonts.Count;
end;

procedure TBBCode4D.BBCodeToRTF;
var
  LCharset: string;
begin
  LCharset := '\ansi\ansicpg1252\deff0\nouicompat\deflang1046';

  FRichText  := FBBCode;
  FClearText := FBBCode;

  if FRichText = '' then
    Exit;

  FRichText := FRichText
    .Replace('{', '\{', [rfReplaceAll])
    .Replace('}', '\}', [rfReplaceAll]);

  FRichText := TRegEx.Create('\n', [roMultiLine]).Replace(FRichText, '\par ');

  ProccessTags(FRichText, AddColor(C_DEFAULT_COLOR), AddFont(C_DEFAULT_FONT),
    C_DEFAULT_SIZE, C_DEFAULT_ALIGN);

  ClearTags(FClearText);

  FRichText := Format(
    '{\rtf1%s' + #13#10 +
    '{\fonttbl %s}' + #13#10 +
    '{\colortbl ;%s}' + #13#10 +
    '%s' + #13#10 +
    '%s%s}',
    [LCharset, GetFontList, GetColorList, '\viewkind4\uc1', GetDefaultFormat,
      FRichText]);
end;

constructor TBBCode4D.Create;
begin
  inherited Create;

  FFonts  := TList<string>.Create;
  FColors := TList<TColor>.Create;
end;

function TBBCode4D.FindTagContent(const AText: string; var ATagName, AAttr,
  AFullOpenTag, AFullCloseTag, AContent: string; var AIndex: Int64): Boolean;
const
  C_OPEN_TAG_REGEX : string = '(?<full_tag>\[(?<tag>%s)(?<attr>[^\]]+)?\])';
  C_CLOSE_TAG_REGEX: string = '\[\/%s\]';
var
  LRegexOpen   : TRegEx;
  LRegexClose  : TRegEx;
  LMatchOpen   : TMatch;
  LMatchClose  : TMatch;
  LMatchTemp   : TMatch;
  LOpenTagCount: Integer;
  LOpenPattern : string;
  LClosePattern: string;
  LStartContentIndex: Int64;
  LEndContentIndex  : Int64;
begin
  Result := False;

  // Initialize outputs
  ATagName      := '';
  AAttr         := '';
  AFullOpenTag  := '';
  AFullCloseTag := '';
  AContent      := '';

  // Create Open regex pattern
  LRegexOpen := TRegEx.Create(Format(C_OPEN_TAG_REGEX, ['\w+']), [roIgnoreCase]);

  // Search for the opening tag
  LMatchOpen := LRegexOpen.Match(AText, AIndex);
  if not LMatchOpen.Success then
    Exit;

  AIndex := LMatchOpen.Index;

  if LMatchOpen.Groups.ContainsNamedGroup('tag') then
    ATagName     := LMatchOpen.Groups['tag'].Value;
  if LMatchOpen.Groups.ContainsNamedGroup('attr') then
    AAttr        := LMatchOpen.Groups['attr'].Value;
  if LMatchOpen.Groups.ContainsNamedGroup('full_tag') then
    AFullOpenTag := LMatchOpen.Groups['full_tag'].Value;

  LStartContentIndex := LMatchOpen.Index + LMatchOpen.Length;

  // Create Close regex pattern
  LOpenPattern  := Format(C_OPEN_TAG_REGEX, [ATagName]);
  LClosePattern := Format(C_CLOSE_TAG_REGEX, [ATagName]);
  LRegexClose   := TRegEx.Create(LClosePattern, [roIgnoreCase]);

  // Search for the corresponding closing tag
  LOpenTagCount := 1;
  LMatchTemp    := LMatchOpen;
  while LMatchTemp.Success and (LOpenTagCount > 0) do
  begin
    LMatchTemp := TRegEx.Create(LOpenPattern + '|' + LClosePattern, [])
      .Match(AText, LMatchTemp.Index + LMatchTemp.Length);
    if LMatchTemp.Success then
    begin
      if LMatchTemp.Value.StartsWith('[' + ATagName) then
        Inc(LOpenTagCount)  // Found another opening tag
      else
        Dec(LOpenTagCount); // Found a closing tag
    end;
  end;

  if LOpenTagCount = 0 then
  begin
    LMatchClose := LRegexClose.Match(AText, LMatchTemp.Index);
    if LMatchClose.Success then
    begin
      AFullCloseTag    := LMatchClose.Value;
      LEndContentIndex := LMatchClose.Index;
      AContent         := Copy(AText, LStartContentIndex,
        LEndContentIndex - LStartContentIndex);
      Result := True;
    end;
  end;
end;

procedure TBBCode4D.ProccessTags(var AText: string;
  const ACurrColor, ACurrFont, ACurrSize: Integer; const ACurrAlign: string;
  const ACurrListType: string; const ACurrListItem: Integer);
var
  LPosStart: Int64;

  LTagName     : string;
  LAttributes  : string;
  LFullOpenTag : string;
  LFullCloseTag: string;
  LContent     : string;
  LNewContent  : string;

  LDictAttr: TDictionary<string, string>;

  LColor: Integer;
  LFont : Integer;
  LSize : Integer;
  LAlign: string;
  LListT: string;
  LListI: Integer;
begin
  // Procura por alguma abertura de Tag
  LPosStart := 0;      
  LListT := ACurrListType;
  LListI := ACurrListItem;
  
  while FindTagContent(AText, LTagName, LAttributes, LFullOpenTag,
    LFullCloseTag, LContent, LPosStart) do
  begin
    LColor := ACurrColor;
    LFont  := ACurrFont;
    LSize  := ACurrSize;
    LAlign := ACurrAlign;  

    LDictAttr := GetAttrDictionary(LAttributes);

    LNewContent := Copy(LContent, 1);
    // Simple Tags
    case AnsiIndexStr(LTagName.ToLower, [
      'b', 'i', 'u', 's', 'o', 'sub', 'sup', 'shadow', 'lower', 'upper',
      'small']) of
      0: LNewContent := Format('\b1 %s\b0', [LNewContent]);
      1: LNewContent := Format('\i1 %s\i0', [LNewContent]);
      2: LNewContent := Format('\ul1 %s\ul0', [LNewContent]);
      3: LNewContent := Format('\strike1 %s\strike0', [LNewContent]);
      4: LNewContent := Format('\out1 %s\out0', [LNewContent]);
      5: LNewContent := Format('\sub %s\nosupersub', [LNewContent]);
      6: LNewContent := Format('\super %s\nosupersub', [LNewContent]);
      7: LNewContent := Format('\shad1 %s\shad0', [LNewContent]);
      8: LNewContent := Format('%s', [LNewContent.ToLower]);
      9: LNewContent := Format('%s', [LNewContent.ToUpper]);
      10: LNewContent := Format('\scaps1 %s\scaps0', [LNewContent]);
    end;

    // Complex Tags
    case AnsiIndexStr(LTagName.ToLower, [
      'color', 'size', 'font', 'align', 'list', 'ul', 'ol', 'li', 'url',
      'email', 'img']) of
      0: ProccessTagColor(LNewContent, LColor, LDictAttr);
      1: ProccessTagSize(LNewContent, LSize, LDictAttr);
      2: ProccessTagFont(LNewContent, LFont, LDictAttr);
      3: ProccessTagAlign(LNewContent, LAlign, LDictAttr);
      4, 5, 6: ProccessTagList(LNewContent, LTagName, LListT, LFont, LDictAttr);
      7: ProccessTagListItem(LNewContent, LListT, LListI, LFont, LDictAttr);
      8: ProccessTagUrl(LNewContent, LFont, LSize, LDictAttr);
      9: ProccessTagEmail(LNewContent, LFont, LSize, LDictAttr);
      10: ProccessTagImage(LNewContent, LFont, LSize, LDictAttr);
    end;

    ProccessTags(LNewContent, LColor, LFont, LSize, LAlign, LListT, LListI);

    LContent := LFullOpenTag + LContent + LFullCloseTag;

    AText := AText.Replace(LContent, LNewContent, [rfIgnoreCase, rfReplaceAll]);

    LPosStart := LPosStart + LNewContent.Length;
  end;
end;

function TBBCode4D.GetAttrDictionary(
  const AAttributes: string): TDictionary<string, string>;
const
  C_REGEX: string = '(?<name>[\w]*)=["”]?(?<value>[^"”\n]*)["”]?[ ]?';
var
  LMatches: TMatchCollection;
  LCount  : Integer;
  LName   : string;
  LValue  : string;
begin
  Result := TDictionary<string, string>.Create;

  LMatches := TRegEx.Matches(AAttributes, C_REGEX, [roIgnoreCase]);

  if LMatches.Count <= 0 then
    Exit;

  for LCount := 0 to (LMatches.Count - 1) do
  begin
    LName  := LMatches.Item[LCount].Groups.Item['name'].Value;
    LValue := LMatches.Item[LCount].Groups.Item['value'].Value;
    if LName.IsEmpty then
      LName := 'default';
    Result.Add(LName, LValue);
  end;
end;

function TBBCode4D.GetClearText: string;
const
  C_REGEX: string =
    '\[(?<tag>[a-zA-Z]+)[=]*[^[]*\](?<content>(?>[^[]+|(?R)))*\[\/\k<tag>\]';
var
  LRegEx: TRegEx;
  LTrimmedText: string;
begin
  LTrimmedText := Trim('');

  // Se após o trim o texto estiver vazio, sai da função
  if LTrimmedText = '' then
    Exit('');

  // Cria a instância de TRegEx uma única vez
  LRegEx := TRegEx.Create(C_REGEX);

  // Processa o texto removendo tags BBCode
  //while LRegEx.IsMatch(Result) do
  Result := LRegEx.Replace(LTrimmedText, '${content}');
end;

function TBBCode4D.GetColorList: string;
var
  LCount: Integer;
begin
  Result := '';
  for LCount := 0 to (FColors.Count - 1) do
    Result := Result + ColorToRichColor(FColors[LCount]) + ';';
end;

function TBBCode4D.GetDefaultFormat: string;
begin
  Result := Format('\pard\q%s\cf%d\f%d\fs%d', [C_DEFAULT_ALIGN[1],
    AddColor(C_DEFAULT_COLOR), AddFont(C_DEFAULT_FONT), C_DEFAULT_SIZE]);
end;

function TBBCode4D.GetFontList: string;
var
  LCount: Integer;
begin
  Result := '';
  for LCount := 0 to (FFonts.Count - 1) do
    Result := Result + Format('{\f%d\fnil\fcharset%d %s;}',
        [LCount, 0, FFonts[LCount]]);
end;

class function TBBCode4D.ParseBBCode(const AText: string): TBBCode4D;
begin
  Result := TBBCode4D.Create;
  try
    Result.FBBCode := AText;
    Result.BBCodeToRTF;
  except
    raise;
  end;
end;

class function TBBCode4D.ParseRTF(const AText: string): TBBCode4D;
begin
  Result := TBBCode4D.Create;
  try
    Result.FRichText := AText;
    Result.RTFToBBCode;
  except
    raise;
  end;
end;

procedure TBBCode4D.ProccessTagAlign(var AText, ACurrAlign: string;
  const AAttr: TDictionary<string, string>);
var
  LValue: string;
begin
  LValue := '';
  if AAttr.ContainsKey('default') then
    LValue := AAttr.Items['default'];

  if (LValue.IsEmpty) or
    (not MatchStr(LValue.ToLower, ['left', 'center', 'right', 'justify'])) then
    Exit;

  AText := Format('\pard\q%s %s', [LValue[1], AText, ACurrAlign[1]]);

  ACurrAlign := LValue;
end;

procedure TBBCode4D.ProccessTagColor(var AText: string; var ACurrColor: Integer;
  const AAttr: TDictionary<string, string>);
const
  C_COLOR_NAME: TArray<string> =
    ['aqua', 'black', 'blue', 'fuschia', 'gray', 'green', 'lime', 'maroon',
    'navy', 'olive', 'purple', 'red', 'silver', 'teal', 'white', 'yellow',
    'orange', 'pink', 'cyan', 'magenta', 'brown', 'beige', 'gold', 'indigo',
    'lavender', 'violet'];
  C_COLOR_HEX: TArray<string> =
    ['#00FFFF', '#000000', '#0000FF', '#FF00FF', '#808080', '#008000', '#00FF00',
    '#800000', '#000080', '#808000', '#800080', '#FF0000', '#C0C0C0', '#008080',
    '#FFFFFF', '#FFFF00', '#FFA500', '#FFC0CB', '#00FFFF', '#FF00FF', '#A52A2A',
    '#F5F5DC', '#FFD700', '#4B0082', '#E6E6FA', '#EE82EE'];
var
  LValue: string;
  LIndex: Integer;
begin
  LValue := '';
  if AAttr.ContainsKey('default') then
    LValue := AAttr.Items['default'];

  if MatchStr(LValue.ToLower, C_COLOR_NAME) then
    LValue := C_COLOR_HEX[TArray.IndexOf<string>(
        C_COLOR_NAME, LValue.ToLower)];

  if not ((LValue.Length = 6) or
    ((LValue.Length = 7) and (LValue.StartsWith('#')))) then
    Exit;

  LIndex := AddColor(LValue);

  AText := Format('\cf%d %s\cf%d ', [LIndex, AText, ACurrColor]);

  ACurrColor := LIndex;
end;

procedure TBBCode4D.ProccessTagEmail(var AText: string; var ACurrFont,
  ACurrSize: Integer; const AAttr: TDictionary<string, string>);
const
  C_REGEX: string = '^[\w\-\.]+@([\w-]+\.)+[\w-]{2,4}$';
  C_DEFAULT_COLOR: Integer = 0;
var
  LValue: string;
begin
  LValue := '';
  if AAttr.ContainsKey('default') then
    LValue := AAttr.Items['default'];

  if LValue.IsEmpty then
    LValue := AText;

  if LValue.IsEmpty then
    Exit;

  if not TRegEx.IsMatch(LValue, C_REGEX, [roIgnoreCase, roMultiLine]) then
    Exit;

  AText := Format(
    '{\cf%d{\field{\*\fldinst{HYPERLINK mailto:%s }}' +
    '{\fldrslt{%s\ul0\cf%d}}}}\f%d\fs%d',
    [C_DEFAULT_COLOR, LValue, AText, C_DEFAULT_COLOR, ACurrFont, ACurrSize]);
end;

procedure TBBCode4D.ProccessTagFont(var AText: string; var ACurrFont: Integer;
  const AAttr: TDictionary<string, string>);
var
  LValue: string;
  LInt  : Integer;
begin
  LValue := '';
  if AAttr.ContainsKey('default') then
    LValue := AAttr.Items['default'];

  if LValue.IsEmpty then
    Exit;

  LInt := AddFont(LValue);

  AText := Format('\f%d %s\f%d ', [LInt, AText, ACurrFont]);

  ACurrFont := LInt;
end;

procedure TBBCode4D.ProccessTagList(var AText, ATagName, ACurrList: string;
  var ACurrFont: Integer; const AAttr: TDictionary<string, string>);
var
  LValue: string;
begin
  LValue := '';
  if AAttr.ContainsKey('default') then
    LValue := AAttr.Items['default'];

  if ATagName.ToLower.Equals('ol') then
    LValue := '1'
  else if ATagName.ToLower.Equals('ul') then
    LValue := '';

  if (not LValue.IsEmpty) and
    (not MatchStr(LValue, ['1', 'a', 'A', 'i', 'I'])) then
    Exit;

  ACurrList := LValue;

  AText := Format('\pard %s\pard', [AText]);

  AText := AText.Replace('\par ', '', [rfReplaceAll]);
end;

procedure TBBCode4D.ProccessTagListItem(var AText, ACurrList: string;
  var ACurrItem, ACurrFont: Integer; const AAttr: TDictionary<string, string>);
var
  LValue: string;
  LItem : string;
  LFont : Integer;
begin
  LFont := ACurrFont;

  if ACurrList.IsEmpty then
  begin
    LValue := C_DEFAULT_LIST_SYMBOL;
    LFont  := AddFont('Symbol');
    LItem  := Format('{\*\pn\pnlvlblt\pnf%d\pnindent0{\pntxtb%s}}',
      [LFont, LValue]);
  end
  else if ACurrList.ToLower.Equals('a') then
  begin
    LValue := ' ' + GetIndexAlpha(ACurrItem) + '.';
    LItem  := Format(
      '{\*\pn\pnlvlbody\pnf%d\pnindent0\pnstart1\pnlcltr{\pntxta.}}',
      [ACurrFont]);
  end
  else if ACurrList.ToLower.Equals('i') then
  begin
    LValue := ' ' + GetIndexRoman(ACurrItem) + '.';
    LItem  := Format(
      '{\*\pn\pnlvlbody\pnf%d\pnindent0\pnstart1\pnucrm{\pntxta.}}',
      [ACurrFont]);
  end
  else
  begin
    LValue := ' ' + IntToStr(ACurrItem) + '.';
    LItem  := Format(
      '{\*\pn\pnlvlbody\pnf%d\pnindent0\pnstart1\pndec{\pntxta.}}',
      [ACurrFont]);
  end;

  if ACurrItem > 1 then
    LItem := '';

  if ACurrList.Equals('A') or ACurrList.Equals('I') then
    LValue := LValue.ToUpper;
  LValue := Format('%s\tab', [LValue]);

  AText := Format('{\pntext\f%d%s}%s %s\par', [LFont, LValue, LItem, AText]);

  ACurrItem := ACurrItem + 1;
end;

procedure TBBCode4D.ProccessTagImage(var AText: string; var ACurrFont,
  ACurrSize: Integer; const AAttr: TDictionary<string, string>);
var
  LValue: string;
begin
  LValue := '';
  if AAttr.ContainsKey('default') then
    LValue := AAttr.Items['default'];

  //AText := AText.Replace('\par', '\par' + #13#10 + '> ', [rfReplaceAll]);

  AText := Format(
    '{\field{\*\fldinst{INCLUDEPICTURE "c:\\\\filename.bmp" MERGEFORMAT \\d \\w3000 \\h4500 \\pm1 \\px0 \\py0 \\pw0}}}',
    [AText, ACurrFont, ACurrSize]);
end;

procedure TBBCode4D.ProccessTagSize(var AText: string; var ACurrSize: Integer;
  const AAttr: TDictionary<string, string>);
var
  LValue: string;
  LInt  : Integer;
begin
  LValue := '';
  if AAttr.ContainsKey('default') then
    LValue := AAttr.Items['default'];

  if LValue.IsEmpty then
    Exit;

  if not TryStrToInt(LValue, LInt) then
    LInt := ACurrSize;

  AText := Format('\fs%d %s\fs%d ', [LInt, AText, ACurrSize]);

  ACurrSize := LInt;
end;

procedure TBBCode4D.ProccessTagUrl(var AText: string; var ACurrFont,
  ACurrSize: Integer; const AAttr: TDictionary<string, string>);
const
  C_REGEX: string =
    '^(?:(?:(?:https?|ftp):)?\/\/)(?:\S+(?::\S*)?@)?(?:(?!(?:10|127)(?:\.\d' +
    '{1,3}){3})(?!(?:169\.254|192\.168)(?:\.\d{1,3}){2})(?!172\.(?:1[6-9]|2' +
    '\d|3[0-1])(?:\.\d{1,3}){2})(?:[1-9]\d?|1\d\d|2[01]\d|22[0-3])(?:\.(?:1' +
    '?\d{1,2}|2[0-4]\d|25[0-5])){2}(?:\.(?:[1-9]\d?|1\d\d|2[0-4]\d|25[0-4])' +
    ')|(?:(?:[a-z0-9\x{00a1}-\x{ffff}][a-z0-9\x{00a1}-\x{ffff}_-]{0,62})?[a' +
    '-z0-9\x{00a1}-\x{ffff}]\.)+(?:[a-z\x{00a1}-\x{ffff}]{2,}\.?))(?::\d{2,' +
    '5})?(?:[/?#]\S*)?$';
  C_DEFAULT_COLOR: Integer = 0;
var
  LValue: string;
begin
  LValue := '';
  if AAttr.ContainsKey('default') then
    LValue := AAttr.Items['default'];

  if LValue.IsEmpty then
    LValue := AText;

  if LValue.IsEmpty then
    Exit;

  if not TRegEx.IsMatch(LValue, C_REGEX, [roIgnoreCase, roMultiLine]) then
    Exit;

  AText := Format(
    '{\cf%d{\field{\*\fldinst{HYPERLINK %s }}' +
    '{\fldrslt{%s\ul0\cf%d}}}}\f%d\fs%d',
    [C_DEFAULT_COLOR, LValue, AText, C_DEFAULT_COLOR, ACurrFont, ACurrSize]);
end;

procedure TBBCode4D.RTFToBBCode;
begin
  //
end;

procedure TBBCode4D.WriteToRich(var ARichEdit: TRichEdit);
begin
  try
    WriteRichText(ARichEdit, FRichText);
  except
    raise;
  end;
end;

procedure TBBCode4D.ClearTags(var AText: string);
var
  LPosStart: Int64;

  LTagName     : string;
  LAttributes  : string;
  LFullOpenTag : string;
  LFullCloseTag: string;
  LContent     : string;
  LNewContent  : string;
begin
  // Procura por alguma abertura de Tag
  LPosStart := 0;
  while FindTagContent(AText, LTagName, LAttributes, LFullOpenTag,
    LFullCloseTag, LContent, LPosStart) do
  begin
    LNewContent := Copy(LContent, 1);

    ClearTags(LNewContent);

    LContent := LFullOpenTag + LContent + LFullCloseTag;

    AText := AText.Replace(LContent, LNewContent, [rfIgnoreCase, rfReplaceAll]);

    LPosStart := LPosStart + LNewContent.Length;
  end;
end;

function TBBCode4D.ColorToHex(const AColor: TColor;
  const AHastag: Boolean): string;
begin
  Result :=
    // Red
    IntToHex(GetRValue(AColor), 2) +
    // Green
    IntToHex(GetGValue(AColor), 2) +
    // Blue
    IntToHex(GetBValue(AColor), 2);
end;

function TBBCode4D.HexToColor(const AColor: string): TColor;
var
  LColor: string;
begin
  // Define como resultado padrão a cor Preta
  Result := $000000;

  // Remove o Hashtag da cor enviada
  LColor := AColor.Replace('#', '', [rfReplaceAll]);

  try
    // Caso o hexadecimal tenha 6 caracteres converte em TColor
    if Length(LColor) = 6 then
      Result := RGB(
          // Red
          StrToInt('$'+ Copy(LColor, 1, 2)),
          // Green
          StrToInt('$'+ Copy(LColor, 3, 2)),
          // Blue
          StrToInt('$'+ Copy(LColor, 5, 2)));
  except
    // Suprime as exceções
  end;
end;

function TBBCode4D.ColorToRichColor(const AColor: TColor): string;
begin
  Result := HexToRichColor(ColorToHex(AColor));
end;

function TBBCode4D.HexToRichColor(const AColor: string): string;
var
  LRed: Integer;
  LBlue: Integer;
  LGreen: Integer;
  LColor: string;
begin
  // Define como resultado padrão um string vazio
  Result := '';

  // Remove o Hashtag da cor enviada
  LColor := AColor.Replace('#', '', [rfReplaceAll]);

  // Caso o hexadecimal tenha 6 caracteres extrai seus valores
  if Length(LColor) = 6 then
  begin
    LRed   := StrToInt('$' + Copy(LColor, 1, 2));
    LGreen := StrToInt('$' + Copy(LColor, 3, 2));
    LBlue  := StrToInt('$' + Copy(LColor, 5, 2));

    Result := Format('\red%d\green%d\blue%d', [LRed, LGreen, LBlue]);
  end;
end;

procedure TBBCode4D.WriteRichText(var ARichEdit: TRichEdit;
  const AText: string);
var
  LData: TEditStreamData;
  LStream: TStringStream;
begin
  LStream := TStringStream.Create(AText);

  try
    if Assigned(LStream) and Assigned(ARichEdit) then
    begin
      try
        with LData do
        begin
          dwCookie    := LongInt(LStream);
          dwError     := 0;
          pfnCallback := @EditStreamReader;
        end;

        ARichEdit.Lines.Clear;

        ARichEdit.Perform(EM_STREAMIN, SF_RTF or SFF_SELECTION,
          LongInt(@LData));
      except

      end;
    end;
  finally

  end;
end;

function EditStreamReader(dwCookie: DWORD_PTR; pbBuff: PByte;
  cb: Longint; var pcb: Longint): Longint; stdcall;
begin
  Result := 0;  // assume no error
  try
    pcb := TStream(dwCookie).Read(pbBuff^, cb); // read data from stream
  except
    Result := -1;  // indicates error to calling routine
  end;
end;

function TBBCode4D.GetIndexAlpha(const AIndex: Integer): string;
const
  C_LIST_ALPHA: string = 'abcdefghijklmnopqrstuvwxyz';
var
  LCurrent: Integer;
  LAux: Integer;
begin
  Result := '';
  LCurrent := AIndex;
  while LCurrent > 0 do
  begin
    if LCurrent > 26 then
      LAux := Floor(LCurrent / 26)
    else
      LAux := LCurrent;

    LCurrent := LCurrent - (LAux * 26);

    Result := Result + C_LIST_ALPHA[LAux];
  end;
end;

function TBBCode4D.GetIndexRoman(const AIndex: Integer): string;
const
  C_VALORES: array[1..13] of Integer =
    (1000, 900, 500, 400, 100, 90, 50, 40, 10, 9, 5, 4, 1);
  C_SIMBOLOS: array[1..13] of string =
    ('M', 'CM', 'D', 'CD', 'C', 'XC', 'L', 'XL', 'X', 'IX', 'V', 'IV', 'I');
var
  LCount: Integer;
  LValor: Integer;
begin
  Result := '';
  LValor := AIndex;
  for LCount := 1 to Length(C_VALORES) do
  begin
    while LValor >= C_VALORES[LCount] do
    begin
      LValor := LValor - C_VALORES[LCount];
      Result := Result + C_SIMBOLOS[LCount];
    end;
  end;
end;

end.

