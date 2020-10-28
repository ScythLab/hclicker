/* Эмулятор HID-устройства. Скетч №1.
 * Двигает указатель мыши по кругу сразу при инициализации устройства.
 * 
 * Разрабатывалось на Arduino Uno ATmega328P-AU (16 MHz).
 * Автор: ScythLab Team.
 * Видео-инструкция по программе:
 * https://www.youtube.com/watch?v=vCD8bgk-iNI.
 * 
 * Используется библиотека-обертка от Adafruit:
 * https://github.com/adafruit/Adafruit-Trinket-USB/,
 * базирующаяся на библиотеке V-USB от www.obdev.at:
 * https://github.com/obdev/v-usb/tree/master/usbdrv.
 */

#include "TrinketHidCombo.h"

// Логировать сообщения в COM-порт
#define LOG_SERIAL
// Вывод отладочных данных библиотеки V-USB (см. комментарии в конечном блоке файла).
#define DEBUG_LEVEL

// Используемые пины (нужно синхронизовать с TrinketXXX/usbconfig.h)
#define PIN_USB_DPLUS       2
#define PIN_USB_DMINUS      4
#define PIN_USB_PULLUP      5

#ifdef LOG_SERIAL
  #define SerialBegin(rate) Serial.begin(rate)
  #define SerialPrint( ... ) Serial.print( __VA_ARGS__ )
  #define SerialPrintln( ... ) Serial.println( __VA_ARGS__ )
#else
  #define SerialBegin(rate)
  #define SerialPrint( ... )
  #define SerialPrintln( ... )
#endif

//----------------------------------------------------------------------------//

void setup()
{
  SerialBegin(115200);

  SerialPrintln("HID.Begin...");
  pinMode(PIN_USB_DPLUS, INPUT);
  pinMode(PIN_USB_DMINUS, INPUT);
  pinMode(PIN_USB_PULLUP, OUTPUT); // В зависимости от подключения USB-разъема, пин может не использоваться
  TrinketHidCombo.begin();
  SerialPrintln("   OK");
}

// Угол дуги, на которую перемещается курсор за один раз
#define ANGLE_STEP (PI / 360.0)
// Радису окружности движения мыши
#define CIRCLE_RADIUS 300.0
// Интервал перемещения мыши
#define STEP_DIVIDER 10

void moveMouse()
{
  static int isFirstCalc = 0;
  static int lastX;
  static int lastY;
  static float angle = 0.0;

  // Расчет координат окружности
  angle += ANGLE_STEP;
  if (angle >= 2 * PI)
    angle = 0;
  int x = sin(angle) * CIRCLE_RADIUS;
  int y = cos(angle) * CIRCLE_RADIUS;
  if (!isFirstCalc)
  {
    // Смещение относительно координат с предыдущего расчета
    int xx = x - lastX;
    int yy = y - lastY;
    TrinketHidCombo.mouseMove(xx, yy, 0);
    //SerialPrint("["); SerialPrint(xx); SerialPrint(";"); SerialPrint(yy); SerialPrintln("] ");
    //SerialPrint("x: "); SerialPrint(x); SerialPrint("; y: "); SerialPrintln(y);
  }

  isFirstCalc = 0;
  lastX = x;
  lastY = y;
}


void loop()
{
  // В документации указано, что метод должен выполняться не реже 1 раза в 10 мс.
  // Я думаю это не совсем верно: такая частота нужна только в момент инициализации HID-устройства,
  // в остальное время можно тормозить выполнение метода без вреда для общей работоспособности.
  TrinketHidCombo.poll();
  
  static int isConnected = 0; 
  int bl = TrinketHidCombo.isConnected();
  if (bl != isConnected)
  {
    isConnected = bl;
    SerialPrint("isConnected: ");
    SerialPrintln(isConnected);
  }

  // Двигаем мышь раз в STEP_DIVIDER циклов.
  // Чтобы получить универсальный код, нужно замерять прошедшее время,
  // и делать расчет относительно этого интервала, но мне лень.
  static int counter = 0;
  if (isConnected && counter++ > STEP_DIVIDER)
  {
    counter = 0;
    moveMouse();
  }

  //delay(1);
}

//----------------------------------------------------------------------------//
/*

Чтобы включить отладочную информацию нужно:
 - прописать строку "#define DEBUG_LEVEL 2" в файле usbdrv/oddebug.h;
 - раскоментировать строку "#define DEBUG_LEVEL" в начале этого файла;
 - в файле usbdrv/oddebug.c удалить функцию odDebug, если она там есть.

*/


#ifdef DEBUG_LEVEL

// Переводит символ (младшие 4 бита) в HEX-формат.
// Чтобы перевести байт целиком, нужны две конвертации: "c >> 4" и "с".
char hexAscii(char c)
{
    c &= 0xf;
    if(c >= 10)
        c += 'a' - 10 - '0';
    c += '0';
    return c;
}

// Печатает данные в COM-порт в HEX формате.
void printHex(char *data, int len)
{
    while(len--){
      char c = *data++;
      SerialPrint(hexAscii(c >> 4));
      SerialPrint(hexAscii(c));
      SerialPrint(" ");
    }
}


// Вывод отладочной информации идет с помощью макросов DBG1 и DBG2 (файл usbdrv.c).
// Библиотека использует коды prefix:
//  - 0x10 - 0x1F: usbProcessRx
//  - 0x20       : usbBuildTxBlock
//  - 0x21 - 0x24: usbGenericSetInterrupt
//  - 0xFF       : usbPoll
// Остальные коды можно использовать для собственных нужд.
extern "C" void odDebug(unsigned char prefix, unsigned char *data, unsigned char len)
{
  // Этот лог из функции usbPoll, он не очень интересен
  if (0xFF == prefix)
    return;

    // Логирование времени операции (мс), если есть сомнения в скорости ответа контроллера.
//  static uint32_t lastTmr = 0;
//  uint32_t tmr = micros() / 1000;
//  if (!lastTmr)
//    lastTmr = tmr;
//    
//  SerialPrint(prefix, HEX);
//  SerialPrint(" - ");
//  SerialPrintln(tmr - lastTmr);
//  return;

  if (prefix >= 0x10 && prefix <= 0x1F)
  {
    int usbRxToken = (prefix - 0x10);
    SerialPrint("usbRxToken[");
    SerialPrint(usbRxToken, HEX);
    SerialPrint("]: ");
    printHex(data, len);
    SerialPrintln("");
  }
  else if (0x20 == prefix)    
  {
    SerialPrint("usbTxBuf:      ");
    printHex(data + 1, len - 3);
    SerialPrintln("");
    //SerialPrintln(len);
  }
  else if (prefix >= 0x21 && prefix < 0x24)
  {
    int txStatus = (prefix - 0x21) << 3;
    SerialPrint("txStatus[");
    SerialPrint(txStatus);
    SerialPrint("]len: ");
    printHex(data, len);
    SerialPrintln("");
  }
  else
  {
    SerialPrint("prefix: "); SerialPrintln(prefix, HEX);
  }
}

#endif

