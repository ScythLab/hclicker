/* Эмулятор HID-устройства. Скетч №2.
 * Управляется командами через COM-порт. Нажимает клавиши и двигает мышь.
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

// Из тех. документации:
// CH340 supports common baud rates: 50, 75, 100, 110, 134.5, 150, 300, 600, 900, 1200, 1800, 2400, 3600, 4800, 9600, 14400, 19200, 28800, 33600, 38400, 56000, 57600, 76800, 115200, 128000, 153600, 230400, 460800, 921600, 1500000, 2000000 baud.
// Transmitter baud rate error is less than 0.3%, receiver baud rate error tolerance is at most 2%.
#define SERIAL_BAUDRATE 115200
// Логировать сообщения в COM-порт
#define LOG_SERIAL
// Использовать светодиоды для индикации нажатых кнопок
#define USE_DIODE

// Используемые пины (нужно синхронизовать с TrinketXXX/usbconfig.h)
#define PIN_USB_DPLUS       2
#define PIN_USB_DMINUS      4
#define PIN_USB_PULLUP      5
#ifdef USE_DIODE
  // Светодиоды
  #define PIN_DIODE_MOUSE   6
  #define PIN_DIODE_KEYB    7
#endif

// Расширение ASCII-таблицы символов
#define PSEUDO_ASCII_F1  0x80
#define PSEUDO_ASCII_F12 (PSEUDO_ASCII_F1 + 11)

#ifdef LOG_SERIAL
  #define SerialPrint( ... )   Serial.print  ( __VA_ARGS__ )
  #define SerialPrintln( ... ) Serial.println( __VA_ARGS__ )
#else
  #define SerialPrint( ... )
  #define SerialPrintln( ... )
#endif

void setup()
{
  Serial.begin(SERIAL_BAUDRATE);

#ifdef USE_DIODE
  pinMode(PIN_DIODE_MOUSE, OUTPUT);
  pinMode(PIN_DIODE_KEYB, OUTPUT);
#endif

  SerialPrintln("HID.Begin...");
  pinMode(PIN_USB_DPLUS, INPUT);
  pinMode(PIN_USB_DMINUS, INPUT); // В примерах идет режим INPUT, но OUTPUT тоже подходит и может работать лучше
  pinMode(PIN_USB_PULLUP, OUTPUT); // В зависимости от подключения USB-разъема, пин может не использоваться
  TrinketHidCombo.begin();
  SerialPrintln("   OK");
}

// Обработчик управляющих команд
void process()
{
  if (!Serial.available())
    return;

  // Если тип устройства ранее не был зачитан, то сделаем это
  static char devType = 0;
  if (!devType)
    devType = Serial.read();

  // Обработка команд в зависимости от выбранного устройства
  switch (devType)
  {
    // Мышь
    case 'M':
    {
      // Формат пакета: левая кнопка; правая кнопка; смещение по горизонтали; смещение по вертикали.
      // Левая и правая кнопки: если значение отлично от нуля - кнопка нажата, если ноль - отпущена.
      
      // Дождемся всего пакета.
      if (Serial.available() < 4)
        return;
        
      uint8_t mouse1 = (Serial.read()) ? MOUSEBTN_LEFT_MASK : 0;
      uint8_t mouse2 = (Serial.read()) ? MOUSEBTN_RIGHT_MASK : 0;
      signed char x = Serial.read();
      signed char y = Serial.read();
      uint8_t mask = mouse1 | mouse2;
      //SerialPrint("Mouse.mask: 0x"); SerialPrint(mask);
      //SerialPrint("; x:"); SerialPrint(x);
      //SerialPrint("; y:"); SerialPrintln(y);
      TrinketHidCombo.mouseMove(x, y, mask);
#ifdef USE_DIODE
      // Включим диод пока кнопка зажата
      digitalWrite(PIN_DIODE_MOUSE, (mask) ? HIGH : LOW);
#endif
      break;
    }
      
    // Клавиатура
    case 'K':
    {
      // Формат пакета: ASCII-код нажимаемого символа.
      // Если требуется отпустить кнопку, то символ должен быть NULL.
      
      // Дождемся всего пакета
      if (Serial.available() < 1)
        return;
        
      uint8_t ascii = Serial.read();
      uint8_t modifier, keycode;
      // TRICKY: Функциональные клавиши (VK_F1..VK_F12) будем передавать в диапазоне 0x80+.
      if (ascii >= PSEUDO_ASCII_F1 && ascii <= PSEUDO_ASCII_F12)
      {
        keycode = KEYCODE_F1 + ascii - PSEUDO_ASCII_F1;
        modifier = 0;
      }
      else
        ASCII_to_keycode(ascii, TrinketHidCombo.getLEDstate(), &modifier, &keycode);
      // Проверим корректность преобразования символов
      if (keycode || !ascii)
      {
        TrinketHidCombo.pressKey(modifier, keycode);
#ifdef USE_DIODE
        // Включим диод пока кнопка зажата
        digitalWrite(PIN_DIODE_KEYB, (keycode) ? HIGH : LOW);
#endif
      }
      else
      {
        SerialPrint("Wrong ASCII: 0x");
        SerialPrintln((uint8_t)ascii, HEX);
      }
      break;
    }

    default:
    {
      SerialPrint("Wrong device type: 0x");
      SerialPrintln((uint8_t)devType, HEX);
    }
  } // switch (devType)

  // Пакет обработан, обнулим текущее устройство.
  devType = 0;
}

void loop()
{
  // В документации указано, что метод должен выполняться не реже 1 раза в 10 мс.
  // Я думаю это не совсем верно: такая частота нужна только в момент инициализации HID-устройства,
  // в остальное время можно тормозить выполнение метода без вреда для общей работоспособности.
  TrinketHidCombo.poll();


  static int isConnected = 0;
  if (TrinketHidCombo.isConnected())
  {
    // Логирование подключения HID-устройства
    if (!isConnected)
    {
      isConnected = 1;
      SerialPrintln("HID connected");
    }

    // Обработка команд из COM-порта
    process();
  }
  else if (isConnected)
  {
    // Логирование отключения HID-устройства
    isConnected = 0;
    SerialPrintln("HID disconnected");
  }
}

