// Revize Body1 için kapak (Body3 yerine)
// Koordinatlar body1-revize.stl ile aynı: z=0 tabla, z arttıkça aşağı (masanın altına doğru).
// Kapak Body1 plakasının dış kenarını sarar, 4 köşede Body1'deki M3 insertlere vidalanır.

duvar   = 2.4;
bosluk  = 0.5;
plaka   = [[-247.5, 8.2], [-117.5, 183.2]];   // Body1 plaka dış sınırı (x, y)
ust_z   = 0.5;                                // kapak üst kenarı, tablanın 0.5 mm altı
ic_taban = 47;                                // motor ön plakası 45.3'e kadar iniyor
vida_noktalari = [[-124.5, 28.3], [-124.5, 175.3], [-241.8, 28.3], [-202.6, 176.3]];
insert_z = 8;                                 // Body1'de insert deliklerinin alt yüzü
mil = [-221.9, 15.1];                         // mil ekseni (x, z)
hc  = [-160, 160];  hc_aralik = 26;  hc_cap = 16.6;
esp_usb_x = -146;
/* [Arka duvar – panel montaj] */
sigorta_x = -180;  sigorta_delik = 12.3;   // 5x20 panel sigorta yuvası (12 mm gövde)
jak_x     = -228;  jak_delik     = 11.2;   // DC-022 5,5x2,1 panel jak (11 mm gövde)
panel_z   = 26;                            // tabladan aşağı mesafe (delik merkezi)
/* [Ön duvar – buton paneli RJ45 keystone] */
ks_delik = [14.9, 16.3];  ks_x = -195;  ks_z = 28;   // jack gevşekse deliği 0,2 mm küçült

$fn = 56;

x0 = plaka[0].x - bosluk;  x1 = plaka[1].x + bosluk;
y0 = plaka[0].y - bosluk;  y1 = plaka[1].y + bosluk;
alt_z = ic_taban + duvar;

module kapak() {
    difference() {
        union() {
            difference() {
                translate([x0 - duvar, y0 - duvar, ust_z]) cube([x1 - x0 + 2*duvar, y1 - y0 + 2*duvar, alt_z - ust_z]);
                translate([x0, y0, ust_z - 1]) cube([x1 - x0, y1 - y0, ic_taban - ust_z + 1]);
            }
            for (p = vida_noktalari) translate([p.x, p.y, insert_z + 0.2]) cylinder(d = 9, h = alt_z - insert_z - 0.2);
            for (sx = [-1,1], sy = [-1,1]) translate([hc.x + sx*24, hc.y + sy*11.5, ic_taban - 4]) cylinder(d = 3, h = 4.1);
        }
        // vida delikleri: alttan havşalı
        for (p = vida_noktalari) {
            translate([p.x, p.y, 0]) cylinder(d = 3.4, h = alt_z + 1);
            translate([p.x, p.y, insert_z + 0.2 + 6]) cylinder(d = 6.5, h = alt_z);
        }
        // kaplin / altıgen çıkışı (ön duvar), alttan yuvarlak U
        hull() {
            translate([mil.x, y0 + 1, mil.y + 3]) rotate([90, 0, 0]) cylinder(d = 16, h = duvar + 2);
            translate([mil.x - 8, y0 - duvar - 1, ust_z - 1]) cube([16, duvar + 2, 1]);
        }
        // HC-SR04 pencereleri
        for (s = [-1,1]) translate([hc.x + s*hc_aralik/2, hc.y, ic_taban - 1]) cylinder(d = hc_cap, h = duvar + 2);
        // buton paneli: RJ45 keystone (ön duvar, motor kaplini ile LM2596 arası)
        translate([ks_x - ks_delik[0]/2, y0 - duvar - 1, ks_z - ks_delik[1]/2]) cube([ks_delik[0], duvar + 2, ks_delik[1]]);
        translate([ks_x - 11, y0 - (duvar - 2.0), ks_z - 11.5]) cube([22, duvar, 23]);   // duvar keystone için içten 2,0 mm'ye incelir
        // ESP32 USB (ön duvar)
        translate([esp_usb_x - 7, y0 - duvar - 1, 20]) cube([14, duvar + 2, 10]);
        // arka duvar: DC jak + dışarıdan değiştirilebilir sigorta
        translate([jak_x, y1 - 1, panel_z]) rotate([-90, 0, 0]) cylinder(d = jak_delik, h = duvar + 2);
        translate([sigorta_x, y1 - 1, panel_z]) rotate([-90, 0, 0]) cylinder(d = sigorta_delik, h = duvar + 2);
        // LM2596 ve röle için havalandırma (taban)
        for (i = [0:5]) translate([-190 + i*8, 95, ic_taban - 1]) cube([3, 40, duvar + 2]);
    }
}

// Baskı yönü: kapağın tabanı tablada
translate([0, 0, alt_z]) rotate([180, 0, 0]) kapak();   // ters çevir (aynalama değil)
