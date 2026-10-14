// Body1 revize – pashiran'ın Body1.stl'i temel alındı
// - Aynalandı: motor plakanın diğer kenarında
// - Eski kart ayakları ve optik endstop tutucusu söküldü
// - 2'li röle, LM2596 ve ESP32 (30 pin) yuvaları eklendi
// Orijinal koordinatlar: plaka z -4..0 (z=0 tablaya değer), parçalar aşağı sarkar.

aynala = true;
pilot_m3 = 2.5;
ayak_h = 6;

role      = [160, -115.25];  role_delik = [33, 45];   // kumpasla kontrol et
lm        = [175, -45];      lm_delik   = [16, 30];   // çapraz iki delik
esp       = [146, -46];      esp_delik  = [24, 47];   // 30 pin USB-C DevKit, 4 köşe deliği
esp_yukseklik = 18;          // kart altında pin + jumper boşluğu

$fn = 48;

module eski_ayaklar() {
    for (b = [[163.1,171.1,-104.4,-96.5],[163.1,171.1,-169.4,-161.5],[120.8,128.1,-169.4,-161.5],
              [120.8,128.1,-104.4,-96.5],[167,175,-85.2,-77.3],[167,175,-29.2,-21.3],
              [140,148,-85.2,-77.3],[140,148,-29.2,-21.3]])
        translate([b[0]-0.4, b[2]-0.4, -9.6]) cube([b[1]-b[0]+0.8, b[3]-b[2]+0.8, 9.6-4.03]);
    // optik endstop tutucusu
    translate([199.5, -46.5, -21]) cube([3.5, 29, 21-8.05]);
}

module ayak(x, y) {
    translate([x, y, -4 - ayak_h]) difference() {
        cylinder(d = 6.5, h = ayak_h + 0.5);
        translate([0, 0, -1]) cylinder(d = pilot_m3, h = ayak_h);
    }
}

module yeni_yuvalar() {
    for (sx = [-1,1], sy = [-1,1]) ayak(role.x + sx*role_delik.x/2, role.y + sy*role_delik.y/2);
    for (s = [-1,1]) ayak(lm.x + s*lm_delik.x/2, lm.y + s*lm_delik.y/2);
    // ESP32: 4 uzun ayak (USB-C ucu plakanın ön kenarına bakar)
    for (sx = [-1,1], sy = [-1,1]) translate([esp.x + sx*esp_delik.x/2, esp.y + sy*esp_delik.y/2, -4 - esp_yukseklik])
        difference() {
            cylinder(d = 6, h = esp_yukseklik + 0.5);
            translate([0, 0, -1]) cylinder(d = pilot_m3, h = 10);
        }
}

// Motor bloğu (ön plaka + bilezik) orijinalde y -96.3..-83.2 arasında, kenar (y=-8.2) ile arası 75 mm.
kaplin_payi = 57;                       // motor ön yüzü ile plaka kenarı arası: ön vida noktalarından ~50 mm geride
kaydir = 75 - kaplin_payi;              // bloğu kenara doğru kaydırma miktarı
blok = [197.4, -96.35, -45.5];          // blok kutusunun köşesi
blok_boy = [50.2, 13.25, 42.5];         // z -45.5..-3.0 (plakanın üst 3 mm'sine dokunulmaz)

module body1() import("../original/Body1.stl");

module motor_blogu() intersection() { body1(); translate(blok) cube(blok_boy); }

module yuva_dolgu() {
    // bloğun boşalttığı yeri, hemen arkasındaki düz yuva kesitiyle doldur
    translate([0, 13.3, 0]) intersection() {
        body1();
        translate([blok.x, blok.y - 13.35, blok.z]) cube([blok_boy.x, 13.4, -blok.z + 0.1]);  // plakanın tam kalınlığı (yuva tavanındaki oluk dahil)
    }
}

module body1_revize() {
    union() {
        difference() {
            body1();
            eski_ayaklar();
            translate(blok) cube([blok_boy.x, blok_boy.y, -blok.z + 0.1]);
        }
        yuva_dolgu();
        translate([0, kaydir, 0]) motor_blogu();
        yeni_yuvalar();
    }
}

// Baskı yönü: tablaya değen yüz (z=0) tablada
rotate([180, 0, 0])
    if (aynala) mirror([1, 0, 0]) body1_revize(); else body1_revize();
