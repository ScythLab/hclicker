�������� ����������� �������.

������� �� ���� ������:
 - �������� �� ���� Arduino;
 - ���������-������, ����������� ����������.

������ ��� Arduino:
   hid_emulator_1 - �������� ����� ��� �������� ������ ���������.
   hid_emulator_2 - �������� ����� ���������.

�����-��������: https://www.youtube.com/watch?v=vCD8bgk-iNI.

�������� ������:
Arduino IDE: https://www.arduino.cc/en/Main/Software
���������� TrinketHIDCombo: https://github.com/adafruit/Adafruit-Trinket-USB
���������� V-USB: https://github.com/obdev/v-usb
���������� Delphi: https://www.embarcadero.com/ru/products/delphi/starter/free-download
��������� CPort: https://sourceforge.net/projects/comport/

��������� ��������� ��� Arduino:
 - ���������� � ����� C:\Users\���_������������\Documents\Arduino\libraries
 - � ��� ��������� ����� � �����������
 - �� ������ ������, �������������� Arduino IDE

��������� ���������� CPort:
 - �������������� ��������� � �����-���� �����, ��������, C:\Components\CPort
 - ���������� ���������:
   - ���������� ������ C:\Components\CPort\Source\CPortLibD2010.dproj, ��� �� ������� -> ����� "Build"
   - ���������� ������ C:\Components\CPort\Source\DsgnCPortD2010.dproj, ��� �� ������� -> ����� "Install"
   - ���� �� ���������, ����� ����� ��������� (Build) ����� CPortLibXxx.dpk,
     � ����� ���������� (Install) ����� DsgnCPortXxx.dpk,
     ��� Xxx - ������ ������ Delphi;
     ���� � ��� Delphi ����� XE, �� ����������� ��������� ������ - DXE
 - ������������ ���� � ����������:
   - ������� ���� Tools -> Options
   - � ������ �������� ���������� ����� ������ Delphi Options -> Library
     - � ��������� ������� Delphi �� ����� ���������� � Language
     - � ���������� ������� � Enviroment Options
   - � ���� Library Path ����������� ���� C:\Components\CPort\Source
