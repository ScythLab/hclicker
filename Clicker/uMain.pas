unit uMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ExtCtrls, CPort;

type
  TfmClicker = class(TForm)
    cbPortList: TComboBox;
    btnRefresh: TButton;
    btnOpenClose: TButton;
    ComPort: TComPort;
    cbBaudRateList: TComboBox;
    gbMouse: TGroupBox;
    edtX: TEdit;
    edtY: TEdit;
    cbLeftMouse: TCheckBox;
    cbRightMouse: TCheckBox;
    btnMouse: TButton;
    gbKeyboard: TGroupBox;
    tbKSpeed: TTrackBar;
    btnKeyboard: TButton;
    edtText: TEdit;
    tbMSpeed: TTrackBar;
    tmrMouse: TTimer;
    tmrKeyBoard: TTimer;
    mmLog: TMemo;
    cbTest: TCheckBox;
    tmrTest: TTimer;
    procedure btnRefreshClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnOpenCloseClick(Sender: TObject);
    procedure ComPortChangeState(Sender: TObject);
    procedure btnMouseClick(Sender: TObject);
    procedure tmrMouseTimer(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnKeyboardClick(Sender: TObject);
    procedure tmrKeyBoardTimer(Sender: TObject);
    procedure ComPortRxChar(Sender: TObject; Count: Integer);
    procedure cbTestClick(Sender: TObject);
    procedure tmrTestTimer(Sender: TObject);

  private
    // Общие поля
    FMinBaudRate: TBaudRate;
    // Поля для движения мышью
    FDeltaX, FDeltaY: Single;
    FMoveDist: Integer;
    FMouseSpeed: Integer;
    FMouseL, FMouseR: Boolean;
    FMouseDt: DWORD;
    // Поля для печати текста
    FKeybInterval: Integer;
    FKeybText: AnsiString;
    FKeybDt: DWORD;

    // Отправляет команду на перемещение мыши.
    procedure MoveMouse(x, y: ShortInt; l, r: Boolean);
    // Отправляет команду на нажатие клавиши (только ASCII-символы и несколько расширенных псевдо-символов).
    procedure PressAsciiKey(ascii: AnsiChar; delay: Integer);
    // Отправляет команду на нажатие клавиши.
    // Если symbol - кирилица, то преобразовывает его к английской букве в соответствии с раскладкой.
    procedure PressEngRusKey(symbol: AnsiChar; delay: Integer);
    // Отправляет команду на нажатие функциональной клавиши.
    procedure PressFuncKey(code: Byte; delay: Integer);
    // Открывает COM-порт для работы.
    procedure OpenComPort();
    // Закрывает COM-порт.
    procedure CloseComPort();
    // Печатает лог
    procedure AddLog(const msg: string); overload;
    procedure AddLog(const frmt: string; const args: array of const); overload;

  public
    { Public declarations }
  end;

var
  fmClicker: TfmClicker;

implementation

{$R *.dfm}

uses
  StrUtils;

const
  // Расширение таблицы ASCII псевдо-символами
  PSEUDO_ASCII_F1 = $80;
  PSEUDO_ASCII_F12 = PSEUDO_ASCII_F1 + 11;

type
  // Пакет эмуляции мыши.
  TMousePack = packed record
    DevType: AnsiChar;
    Left: Boolean;
    Right: Boolean;
    X: ShortInt;
    Y: ShortInt;
  end;
  // Пакет эмуляции клавиатуры.
  TKeybPack = packed record
    DevType: AnsiChar;
    Symbol: AnsiChar;
  end;

procedure TfmClicker.MoveMouse(x, y: ShortInt; l, r: Boolean);
var
  pack: TMousePack;
begin
  pack.DevType := 'M';
  pack.Left := l;
  pack.Right := r;
  pack.X := x;
  pack.Y := y;
  ComPort.Write(pack, SizeOf(pack));
end;

procedure TfmClicker.PressAsciiKey(ascii: AnsiChar; delay: Integer);
var
  pack: TKeybPack;
begin
  if (Ord(ascii) > PSEUDO_ASCII_F12) then
  begin
    AddLog('Символ 0x%x выходит за границы ASCII', [Byte(ascii)]);
    Exit;
  end;

  pack.DevType := 'K';
  pack.Symbol := ascii;
  ComPort.Write(pack, SizeOf(pack));
  Sleep(delay);
  pack.Symbol := #0;
  ComPort.Write(pack, SizeOf(pack));
end;

procedure TfmClicker.PressEngRusKey(symbol: AnsiChar; delay: Integer);
  function RusSymbolToEng(symbol: AnsiChar): AnsiChar;
  const
    // Таблицы преобразования русских символов в английские.
    SYMBOLS_RUS: AnsiString = 'ёйцукенгшщзхъфывапролджэячсмитьбюЁЙЦУКЕНГШЩЗХЪФЫВАПРОЛДЖЭЯЧСМИТЬБЮ';
    SYMBOLS_ENG: AnsiString = '`qwertyuiop[]asdfghjkl;''zxcvbnm,.~QWERTYUIOP{}ASDFGHJKL:"ZXCVBNM<>?';
  var
    p: Integer;
  begin
    // Лучше пользоваться функциями VkKeyScanEx и MapVirtualKey, но с ними лень разбираться.
    p := Pos(symbol, SYMBOLS_RUS);
    if (p = 0) then
      Exit(symbol);

    Result := SYMBOLS_ENG[p];
  end;
begin
  // BUG: С русской раскладкой все равно имеются проблемы с некоторыми символами ("№;:?., и подобные).
  symbol := RusSymbolToEng(symbol);
  PressAsciiKey(symbol, delay);
end;

procedure TfmClicker.PressFuncKey(code: Byte; delay: Integer);
begin
  if (code in [VK_F1..VK_F12]) then
    PressAsciiKey(AnsiChar(PSEUDO_ASCII_F1 + code - VK_F1), delay);
end;

// Таймер печати текста.
procedure TfmClicker.tmrKeyBoardTimer(Sender: TObject);
var
  symbol: AnsiChar;
begin
  // Задержка перед печатью
  if (GetTickCount() < FKeybDt) then
    Exit;

  if (FKeybText <> '') then
  begin
    symbol := FKeybText[1];
    Delete(FKeybText, 1, 1);
    PressEngRusKey(symbol, FKeybInterval div 4);
  end;

  tmrKeyBoard.Enabled := (FKeybText <> '');
end;

// Таймер движения мышкой.
procedure TfmClicker.tmrMouseTimer(Sender: TObject);
var
  x, y, dist: Integer;
begin
  // Задержка перед анимацией
  if (GetTickCount() < FMouseDt) then
    Exit;

  if (FMouseSpeed > FMoveDist) then
    dist := FMoveDist
  else
    dist := FMouseSpeed;

  x := Round(FDeltaX * dist);
  y := Round(FDeltaY * dist);
  Dec(FMoveDist, dist);
  tmrMouse.Enabled := (FMoveDist > 0);
  MoveMouse(x, y, FMouseL, FMouseR);
  // Если была зажата какая-либо кнопка мыши, то в конце движения нужно ее отпустить
  if (not tmrMouse.Enabled)and(FMouseL or FMouseR) then
    MoveMouse(0, 0, False, False);
end;

procedure TfmClicker.tmrTestTimer(Sender: TObject);
begin
  if (not ComPort.Connected) then
    Exit;

  PressFuncKey(VK_F2, 100);
end;

procedure TfmClicker.btnKeyboardClick(Sender: TObject);
begin
  FKeybInterval := (tbKSpeed.Max - tbKSpeed.Position + tbKSpeed.Min) * 10;
  FKeybText := edtText.Text;

  FKeybDt := GetTickCount() + 2000; // Задержка перед печатью
  tmrKeyBoard.Interval := FKeybInterval;
  tmrKeyBoard.Enabled := True;
end;

procedure TfmClicker.btnMouseClick(Sender: TObject);
var
  isDataCorrect: Boolean;
  x, y: Integer;
  flLen: Single;
begin
  tmrMouse.Enabled := False;

  isDataCorrect := TryStrToInt(edtX.Text, x) and TryStrToInt(edtY.Text, y);
  if (not isDataCorrect) then
  begin
    MessageDlg('Wrong X/Y delta', mtError, [mbOK], 0);
    Exit;
  end;

  // Определим вектор движения мыши и длину отрезка
  flLen := Sqrt(x * x + y * y);
  FDeltaX := x / flLen;
  FDeltaY := y / flLen;
  FMoveDist := Round(flLen);

  FMouseSpeed := tbMSpeed.Position * 3;
  // Эмулятор мыши не может за раз перемещать курсор более чем на 127 пикселей.
  if (Abs(FDeltaX * FMouseSpeed) > 127)or(Abs(FDeltaY * FMouseSpeed) > 127) then
  begin
    MessageDlg('Mouse speed is too big', mtError, [mbOK], 0);
    Exit;
  end;
  FMouseL := cbLeftMouse.Checked;
  FMouseR := cbRightMouse.Checked;
  FMouseDt := GetTickCount() + 1000; // Задержка перед анимацией
  tmrMouse.Enabled := True;
end;

procedure TfmClicker.AddLog(const msg: string);
begin
  mmLog.Lines.Add(msg);
end;

procedure TfmClicker.AddLog(const frmt: string; const args: array of const);
begin
  AddLog(Format(frmt, args));
end;

procedure TfmClicker.OpenComPort();
begin
  if (ComPort.Connected) then
    Exit;

  ComPort.Port := cbPortList.Text;
  ComPort.BaudRate := TBaudRate(Integer(FMinBaudRate) + cbBaudRateList.ItemIndex);
  ComPort.Open();
end;

procedure TfmClicker.cbTestClick(Sender: TObject);
begin
  tmrTest.Enabled := cbTest.Checked;
end;

procedure TfmClicker.CloseComPort();
begin
  if (not ComPort.Connected) then
    Exit;

  ComPort.Close();
end;

procedure TfmClicker.btnOpenCloseClick(Sender: TObject);
begin
  if (ComPort.Connected) then
  begin
    CloseComPort();
    Exit;
  end;

  OpenComPort();
end;

procedure TfmClicker.btnRefreshClick(Sender: TObject);
var
  prevPort: string;
  prevIndex: Integer;
  ports: TStrings;

  // Определение портов "в лоб", работает не очень хорошо, т.к.:
  // - номер порта может быть больше 10;
  // - если порт занят, то он не попадет в список.
  //procedure EnumComPorts(ports: TStrings);
  //var
  //  i: Integer;
  //  hFile: THandle;
  //  portName: string;
  //begin
  //  for i := 0 to 10 do
  //  begin
  //    portName := 'COM' + IntToStr(i + 1);
  //    hFile := CreateFile(PChar(portName), GENERIC_READ or GENERIC_WRITE, 0, nil, OPEN_EXISTING, FILE_FLAG_OVERLAPPED, 0);
  //    if (hFile = INVALID_HANDLE_VALUE) then
  //      Continue;
  //
  //    CloseHandle(hFile);
  //    ports.Add(portName);
  //  end;
  //end;
begin
  prevPort := cbPortList.Text;
  ports := cbPortList.Items;
  ports.Clear();
  EnumComPorts(ports);
  prevIndex := ports.IndexOf(prevPort);
  if (prevIndex <> -1) then
    cbPortList.ItemIndex := prevIndex
  else if (ports.Count > 0) then
    cbPortList.ItemIndex := 0;
end;

procedure TfmClicker.ComPortChangeState(Sender: TObject);
var
  bl: Boolean;
begin
  bl := ComPort.Connected;
  if (bl) then
    btnOpenClose.Caption := 'Close'
  else
    btnOpenClose.Caption := 'Open';

  btnMouse.Enabled := bl;
  btnKeyboard.Enabled := bl;
end;

procedure TfmClicker.ComPortRxChar(Sender: TObject; Count: Integer);
var
  astr: AnsiString;
begin
  // Добавим в лог сообщение из COM-порта.
  SetLength(astr, count);
  ComPort.Read(astr[1], count);
  mmLog.Text := mmLog.Text + astr;
end;

procedure TfmClicker.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  tmrMouse.Enabled := False;
  tmrKeyBoard.Enabled := False;
  CloseComPort();
end;

procedure TfmClicker.FormCreate(Sender: TObject);
var
  rate: TBaudRate;
begin
  // Доступные скорости COM-порта
  FMinBaudRate := br9600;
  cbBaudRateList.Items.Clear();
  for rate := FMinBaudRate to br256000 do
    cbBaudRateList.Items.Add(BaudRateToStr(rate));
  // Установим скорость 115200
  cbBaudRateList.ItemIndex := Integer(br115200) - Integer(FMinBaudRate);

  mmLog.Clear();
  btnRefreshClick(nil);
end;

end.

