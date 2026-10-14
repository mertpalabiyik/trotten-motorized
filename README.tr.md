# TROTTEN Motorized

[English](README.md) · **Türkçe**

Elle çevrilen **IKEA TROTTEN** oturma/ayakta çalışma masasını bir **ESP32**, 12V redüktörlü bir motor ve birkaç ucuz modülle motorlu hale getirir.
Masa, ESPHome üzerinden **Home Assistant**'tan kontrol edilir. İstersen masanın önüne küçük OLED ekranlı bir **buton paneli** de takabilirsin; panel Home Assistant ya da WiFi yokken de çalışır.

<p align="center">
  <img src="docs/images/build/cover-sensor-flush.jpg" width="30%" alt="Kapalı kutu, sensör kapakla aynı hizada">
  <img src="docs/images/build/assembled-open.jpg" width="30%" alt="Motor, röle, LM2596 ve ESP32 yerinde">
  <img src="docs/images/build/wiring-inside.jpg" width="30%" alt="Kutunun içindeki kablolama">
</p>

## Özellikler

- Krankın yerine geçer: motor, basılmış bir kaplinle masanın 6 mm altıgen girişini çevirir.
- **Yükseklik ölçümü:** yere bakan bir HC-SR04 ultrasonik sensörle yapılır. Masa hedef yüksekliğe gelince durur.
- **Home Assistant:**
  - konum ayarlı bir `Masa` cover varlığı,
  - anlık yükseklik sensörü,
  - cihazın hafızasında saklanan, ayarlanabilir 3 kademe.
- **Ön panel (isteğe bağlı):** 0,91" OLED ve ▲ ▼ ■ tuşları. Ana kutuya standart bir RJ45 patch kabloyla bağlanır. Home Assistant'tan açılıp kapatılabildiği için aynı firmware panelli de panelsiz de çalışır.
- **İnternetsiz çalışır:** WiFi ya da HA gidince yeniden başlamaz. Her harekette 40 sn güvenlik süresi var.
- Motor, kartlar ve sensör masanın altında tek bir kutuda duruyor. Sigorta ve DC jak dışarıdan erişilebilir.

## Malzeme listesi

| Parça | Not |
|---|---|
| ESP32-WROOM DevKit (30 pin) | Aynı pin dizilimine sahip her ESP32 kartı olur |
| 2'li röle modülü, JQC-3FF-S-Z, 5V bobin | H-köprü olarak bağlanır (kablolamaya bak) |
| LM2596 voltaj düşürücü (HW-411) | Hiçbir şey bağlamadan önce **5,0V**'a ayarla |
| HC-SR04 ultrasonik sensör | Yükseklik ölçümü |
| 3 × 10kΩ direnç | ECHO için voltaj bölücü (5V → 3,3V) |
| 12V redüktörlü motor, 37 mm (JGB37-520 / 37GB555 ailesi) | 6 mm D-kesitli mil |
| 12V adaptör, en az 3A | Laptop ya da LED adaptörü de olur, yeter ki 12V ve en az 3A versin |
| Panel tipi 5×20 sigorta yuvası + 4A sigorta | Kapağın arka duvarında |
| Panel tipi DC jak DC-022, 5,5×2,1 mm | Kapağın arka duvarında |
| Wago 221 klemens (3'lü + 5'li) | 12V ve GND dağıtımı |
| 4 adet M3 sıcak gömme insert, M3 / M2.5 vidalar, 4×16 ahşap vidası | |
| **Panel (isteğe bağlı):** 0,91" SSD1306 128×32 I2C OLED, 3 adet 6×6 mm tactile switch, 2 adet RJ45 keystone, düz patch kablo | |

## Baskı parçaları

| Dosya | Ne işe yarar |
|---|---|
| `cad/main-box/body1-remix.stl` | Taban plakası: motor yuvası ve röle, LM2596, ESP32 için ayaklar (pashiran'ın Body1'inden uyarlandı) |
| `cad/main-box/cover.stl` | Kapak: HC-SR04 pencereleri, havalandırma, RJ45 keystone, USB, DC jak ve sigorta delikleri |
| `cad/main-box/hcsr04-spacer.stl` | Kapağın içindeki pimlere oturur, HC-SR04'ü yükseltir; kapsüller kapakla aynı hizada biter |
| `cad/main-box/coupler.stl` | Motor mili (6 mm D) ile masanın altıgen ucu (6 mm) arasındaki kaplin, M3 sabitleme vidası |
| `cad/panel/panel-box.stl` | Ön panel kutusu (OLED, 3 switch, RJ45). Masanın ön kenarının altına takılır |
| `cad/panel/button-caps-AMS.3mf` | Bambu AMS için iki renkli buton başlıkları (renkler atanmış) |
| `cad/panel/ams/*.stl` | Aynı başlıklar, her çok renkli dilimleyici için ayrı gövdeler halinde |
| `cad/panel/button-caps-single-color.stl` | Tek renkli sürüm (renk değişim yüksekliğinde duraklat) |

Tüm parçalar STL'lerin yanında parametrik **OpenSCAD** dosyası (`.scad`) olarak da var.

**PETG** ile bas; kutular için PLA da olur. Kaplini %100 doluluk ve dik konumda bas.

<p align="center">
  <img src="docs/images/main-box.png" width="45%" alt="Taban plakası">
  <img src="docs/images/panel-box.png" width="45%" alt="Panel kutusu">
</p>

## Kablolama

<p align="center">
  <img src="docs/images/wiring-a.png" width="48%" alt="Kablolama A">
  <img src="docs/images/wiring-b.png" width="48%" alt="Kablolama B">
</p>

### ESP32 pinleri

| ESP32 | Nereye |
|---|---|
| VIN | LM2596 OUT+ (5V) |
| GND | LM2596 OUT−, panel GND |
| 3V3 | Röle modülü VCC (optokuplör tarafı), panel OLED VCC |
| GPIO26 | Röle IN1 (yukarı) |
| GPIO27 | Röle IN2 (aşağı) |
| GPIO5 | HC-SR04 TRIG |
| GPIO18 | HC-SR04 ECHO, bölücü üzerinden (aşağıda) |
| GPIO21 / GPIO22 | OLED SDA / SCL |
| GPIO32 / GPIO33 / GPIO25 | Panel ▲ / ▼ / ■ (her switch'in diğer ucu GND'ye) |

**Röle H-köprüsü:** iki NO kontağı +12V'a, iki NC kontağı GND'ye, iki COM ucu motorun iki kablosuna bağlanır. İki röle de bırakılmışken motorun uçları kısa devre olur, yani motor frenlenir.

**Röle besleme:** JD-VCC jumper'ını çıkar. Sonra:
- JD-VCC → 5V
- VCC → 3,3V
- GND → ortak toprak

HC-SR04'ün VCC'si ve röle bobinleri LM2596'nın 5V çıkışından beslenir.

**ECHO bölücüsü** (ESP32 pinleri 5V'a dayanmaz):

```
ECHO ──[10k]──●──[10k]──[10k]── GND
              │
            GPIO18   (≈ 3,3V)
```

**Panel kablosu** (iki keystone da T568B'ye göre bağlanır, araya düz patch kablo):

| ESP32 | Damar rengi | Panel |
|---|---|---|
| 3V3 | turuncu | OLED VCC |
| GND | turuncu-beyaz + yeşil-beyaz | OLED GND, 3 switch'in ortak ucu |
| GPIO21 | yeşil | OLED SDA |
| GPIO22 | mavi | OLED SCL |
| GPIO25 | mavi-beyaz | ■ DUR |
| GPIO32 | kahverengi | ▲ YUKARI |
| GPIO33 | kahverengi-beyaz | ▼ AŞAĞI |

Numaralı kablo listesiyle adım adım rehber: [`docs/guide-tr.html`](docs/guide-tr.html)

## Firmware (ESPHome)

İki dosya var, tek fark varlık adlarının dili:
- `firmware/trotten-masa.yaml`: Türkçe varlık adları
- `firmware/trotten-desk.yaml`: İngilizce varlık adları

**Kurulum:**
1. `firmware/secrets.example.yaml` dosyasını `secrets.yaml` adıyla kopyala ve içine yeni bir API anahtarı yaz.
2. `min_h` ve `max_h` değerlerini masanın gerçek en alt ve en üst yüksekliğine göre ayarla (cm).
3. İlk yüklemeyi bir kez USB üzerinden yap: Home Assistant'taki ESPHome eklentisiyle ya da `esphome run trotten-masa.yaml` komutuyla. **LM2596, VIN'i beslerken ESP'ye USB takma.**
4. WiFi bilgisini yükleme sırasında (Improv) ya da `Trotten Masa` adlı yedek erişim noktasından gir.
5. Home Assistant cihazı kendisi bulur; sorduğunda API anahtarını gir. Sonraki güncellemeler WiFi üzerinden yapılır.

### Home Assistant varlıkları

| Varlık | Görevi |
|---|---|
| `Masa` (cover) | Aç = en üst, kapat = en alt, konum kaydırıcısı = yükseklik |
| `Masa Yüksekliği` | Anlık yükseklik (cm) |
| `Kademe 1/2/3` + `Kademe 1/2/3'e git` | Ayarlanabilir, cihazın hafızasında saklanır |
| `Buton Paneli` (anahtar) | Panel bağlanınca bunu aç |
| `Yeniden Başlat` | Panel takıldıktan sonra OLED'in tanınması için bir kez bas |

### Panelin çalışması

- **▲ / ▼ kısa bas:** masa en üste ya da en alta gider. Hareket sırasında herhangi bir tuş durdurur.
- **▲ / ▼ basılı tut:** tuttuğun sürece gider, bırakınca durur.
- **■:** her durumda durdurur.
- **Ekran:** yüksekliği ve hareket yönünü gösterir. Hareket sırasında hedef yüksekliği, dururken `HA BAGLI` ya da `HA YOK` yazar.

## Kalibrasyon ve sorun giderme

- **Masa ters yöne gidiyor:** motorun iki kablosunun yerini değiştir (ya da iki COM kablosunun).
- **Yükseklik `--.-` görünüyor:** bölücünün ortası **birinci** ve **ikinci** direncin arasından alınmalı; GPIO18'de yaklaşık 3,3V olmalı.
- **Yükseklik sabit miktarda kayık:** ultrasonik filtredeki `offset:` değerini ayarla.
- **Ekran boş:** `Buton Paneli` anahtarı açık mı bak. Paneli taktıktan sonra `Yeniden Başlat`'a bas.

## Emeği geçenler ve lisans

- Taban plakası, **pashiran**'ın tasarımından uyarlandı. Bu tasarım [flosommerfeld/ESP8266-IKEA-Skarsta-Trotten-Web-Dashboard](https://github.com/flosommerfeld/ESP8266-IKEA-Skarsta-Trotten-Web-Dashboard) projesinde ([Instructable](https://www.instructables.com/Motorizing-an-IKEA-SKARSTA-Table/)) kullanılmıştı. Uyarlamanın derlenebilmesi için orijinal `Body1.stl` dosyası `cad/original/` klasöründe duruyor.
- Firmware MIT, 3D modeller CC BY-NC-SA 4.0 lisanslı. Ayrıntılar [LICENSE](LICENSE) dosyasında.

IKEA ve TROTTEN, Inter IKEA Systems B.V.'nin markalarıdır. Bu projenin IKEA ile bir bağlantısı yoktur. Masanda değişiklik yapmak kendi sorumluluğundadır.
