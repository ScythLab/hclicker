Прототип аппаратного кликера.

Состоит из двух частей:
 - эмулятор на базе Arduino;
 - программа-кликер, управляющая эмулятором.

Скетчи для Arduino:
   hid_emulator_1 - тестовый скетч для проверки работы эмулятора.
   hid_emulator_2 - основной скетч эмулятора.

Видео-описание: https://www.youtube.com/watch?v=vCD8bgk-iNI.

Полезные ссылки:
Arduino IDE: https://www.arduino.cc/en/Main/Software
Библиотека TrinketHIDCombo: https://github.com/adafruit/Adafruit-Trinket-USB
Библиотека V-USB: https://github.com/obdev/v-usb
Бесплатный Delphi: https://www.embarcadero.com/ru/products/delphi/starter/free-download
Компонент CPort: https://sourceforge.net/projects/comport/

Установка библиотек для Arduino:
 - переходите в папку C:\Users\ИМЯ_ПОЛЬЗОВАТЕЛЯ\Documents\Arduino\libraries
 - в нее копируете папку с библиотекой
 - на всякий случай, перезапускаете Arduino IDE

Установка компонента CPort:
 - распаковываете компонент в какую-либо папку, например, C:\Components\CPort
 - инсталяция компонент:
   - открываете проект C:\Components\CPort\Source\CPortLibD2010.dproj, ПКМ на проекте -> пункт "Build"
   - открываете проект C:\Components\CPort\Source\DsgnCPortD2010.dproj, ПКМ на проекте -> пункт "Install"
   - если не сработало, тогда нужно построить (Build) пакет CPortLibXxx.dpk,
     а затем установить (Install) пакет DsgnCPortXxx.dpk,
     где Xxx - версия вашего Delphi;
     если у вас Delphi новее XE, то используйте последние пакеты - DXE
 - настраиваете пути к компоненту:
   - главное меню Tools -> Options
   - в дереве настроек необходимо найти раздел Delphi Options -> Library
     - в последних версиях Delphi он может находиться в Language
     - в предыдущих версиях в Enviroment Options
   - в поле Library Path дописываете путь C:\Components\CPort\Source
