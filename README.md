# RPI0USBCA - Urząd certyfikacji na Raspberry Pi Zero przez USB

__rpi0usbca__ - Jest to skrypt w języku powłoki BASH, za pomocą którego możemy utworzyć nasz Urząd Certyfikacji niezbędny do
korzystania z takich usług jak stunnel czy OpenVPN. Skrypt umożliwia w podstawowym stopniu tworzenie oraz zarządzanie
certyfikatami.

Wymagania:

* Dystrybucja systemu Linux korzystająca z paczek Debian oraz narzędzia `apt-get`
* pakiet whiptail (zainstalowany w systemie)
* pakiet openssl (dostępny w repozytorium lub preinstalowany)
* pakiet mini-httpd (dostępny w repozytorium)

Instalacja:

1. git clone https://git.morketsmerke.net/xf0r3m/rpi0usbca
2. chmod +x _rpi0usbca/run.sh_

* Aby nasz skrypt startował wraz zalogowanie się przez SSH, należy dopisać poniższą linię do pliku `.profile`.

```
sudo $HOME/rpi0usbca-master/run.sh $LINES $COLUMNS
```

Gdzie `$LINES` i `$COLUMNS` są zmiennym środowiskowymi powłoki, przechowywującymmi kolejno liczbę linii oraz kolumn
bierzącego terminala.

* Dla automatyzacji, warto zmienić ustawienia naszego użytkownika w pliku _/etc/sudoers_ na `NOPASSWD`.

* Jak przygotować Raspberry Pi Zero do połączenia usb, poradnik znajduje się [tutaj](https://morketsmerke.net/raspberry-pi-zero-polaczenie-przez-usb/)

Uruchomienie (__wymaga uprawnień administratora__):
```
$ sudo rpi0usbca/run.sh $LINES $COLUMNS
```
* Wyjaśnienie `$LINES` i `$COLUMNS` patrz wyżej, sekcja _Instalacja_.

