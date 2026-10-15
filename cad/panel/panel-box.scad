// TROTTEN buton paneli: 0,91" OLED (128x32) + 3 adet 6x6 tactile switch (▲ ▼ ■) + arkada RJ45 keystone (Digitus aletsiz, 20x20x36)
// Masanın ön kenarının altına, üstteki iki kanattan ahşap vidasıyla takılır.
// Kutunun üstü açıktır, masa tablası kapak olur. Ön yüz kullanıcıya doğru 10° yukarı bakar.
// Koordinatlar: X genişlik, Y derinlik (+Y masanın içine), Z yükseklik (z=0 tablaya değen üst kenar, kutu -Z'ye sarkar).

/* [Kutu] */
genislik   = 112;
yukseklik  = 28;      // tabladan aşağı sarkma (20x20 keystone + mandallar için)
derinlik   = 58;      // ön yüzden arka duvara: 36 mm keystone + arkasında kablo payı
egim       = 10;      // ön yüz eğimi (derece)
duvar      = 2.0;
on_duvar   = 2.6;     // buton somunları 6 mm'ye kadar duvar kabul eder

/* [Kanatlar] */
kanat      = 16;
kanat_k    = 4;
ahsap_vida = 4.2;
ahsap_kafa = 8.5;

/* [OLED 0,91" – kart 38 x 12 mm] */
oled_kart  = [38.8, 12.8];   // kart 38 x 12 + pay
oled_derin = 3.6;            // cam + kart kalınlığı (cebin derinliği)
pencere    = [26, 10.6];     // cam 25 x 10 + pay: cam bu deliğe oturur, ön yüzle aynı hizada
oled_cilt  = 1.4;            // kartın yaslandığı ön deri kalınlığı (cam kalınlığı kadar)
pencere_x  = -3.5;           // pencere merkezinin kart merkezine göre kayması (pinlerin tersi yönde)
oled_u     = -30;            // kart merkezinin ön yüzdeki yatay konumu

/* [Butonlar: 6x6 mm tactile switch + baskı başlık] */
buton_delik = 10.6;          // başlık gövdesi Ø10 + pay
sw_kafes    = 6.4;           // switch gövdesi 6x6 + pay
sw_yukseklik = 5.0;          // switch toplam yüksekliği (taban + siyah çubuğun ucu): kumpasla ölç (4.3 / 5 / 7 olabilir)
baslik_flans = 1.2;          // buton-basligi.scad ile aynı
baslik_tirnak = 1.0;         // başlığın altındaki çubuk yuvasının derinliği (buton-basligi.scad ile aynı)
flans_cebi  = 12.6;          // başlık flanşı Ø12 + pay
flans_bosluk = 0.5;          // flanşın arkasında basma payı
kafes_duvar = 1.2;
kafes_derin = 8;             // yuvanın iç yüzeyden içeri uzunluğu
flans_arka  = -on_duvar - baslik_flans - flans_bosluk;
// switch'in arka yüzünün oturduğu dayanak: başlık duvara yaslıyken çubuğa 0,1 mm boşlukla değer
sw_arka = -on_duvar - baslik_flans + baslik_tirnak - sw_yukseklik - 0.1;
butonlar    = [[0, "up"], [20, "down"], [42, "stop"]];   // ön yüzde yatay konum (▲ ▼ yan yana, ■ ayrı)

/* [RJ45 keystone: düz arka duvarın sağ ucunda, gövdesi kutunun içinde] */
ks_delik = [20.3, 20.3];     // Digitus aletsiz keystone: gövde 20 x 20, mandallar 23, boy 36
ks_x     = 44;               // delik merkezinin yatay konumu
ks_mandal = 23;              // mandal açıklığı: iç tarafta bu kadar boşluk kalmalı
ks_z     = -14;              // delik merkezi (tabladan aşağı)
sag_ek   = 2;                // keystone mandalları sağ duvara değmesin

$fn = 64;

on_kayma = yukseklik * tan(egim);   // ön yüzün altı, üstüne göre bu kadar ileride
x_sol = -genislik/2;
x_sag = genislik/2 + sag_ek;
gen   = x_sag - x_sol;

// ön yüz koordinat sistemi: u yatay (X), v ön yüz boyunca yukarı, w yüzün normaline (dışa)
module yuzde(u, v) {
    // yüz ortası: z = -yukseklik/2
    translate([u, -on_kayma/2 + v*sin(egim) , -yukseklik/2 + v*cos(egim)])
        rotate([90 - egim, 0, 0]) children();
}

module dis_govde() {
    hull() {
        translate([x_sol, 0, -0.01]) cube([gen, derinlik, 0.01]);                  // üst kenar
        translate([x_sol, -on_kayma, -yukseklik]) cube([gen, derinlik + on_kayma, 0.01]);  // alt (arka duvar dik)
    }
}

module ic_bosluk() {
    hull() {
        translate([x_sol + duvar, on_duvar/cos(egim), -0.0]) cube([gen - 2*duvar, derinlik - duvar - on_duvar/cos(egim), 0.1]);
        translate([x_sol + duvar, -on_kayma + on_duvar/cos(egim), -yukseklik + duvar])
            cube([gen - 2*duvar, derinlik + on_kayma - duvar - on_duvar/cos(egim), 0.01]);
    }
}

module isaret(tip) {
    // butonun altına 0,6 mm gömülü sembol
    if (tip == "up")   polygon([[-4.5, -3], [4.5, -3], [0, 4]]);
    if (tip == "down") polygon([[-4.5, 3], [4.5, 3], [0, -4]]);
    if (tip == "stop") translate([-3.5, -3.5]) square(7);
}

module panel() {
    difference() {
        union() {
            difference() { dis_govde(); translate([0, 0, 0.01]) ic_bosluk(); }
            // switch yuvaları (ön yüzün içinde kare kafes)
            // altları tabana kadar dolu: baskıda destek malzemesi gerekmez
            intersection() {
                dis_govde();
                for (b = butonlar) hull() for (dz = [0, -12]) translate([0, 0, dz]) yuzde(b[0], 0)
                    translate([-flans_cebi/2 - kafes_duvar, -flans_cebi/2 - kafes_duvar, -on_duvar - kafes_derin]) cube([flans_cebi + 2*kafes_duvar, flans_cebi + 2*kafes_duvar, kafes_derin + 0.5]);
            }
            // kanatlar
            for (s = [-1, 1]) {
                translate([s > 0 ? x_sag - 0.01 : x_sol - kanat + 0.01, 4, -kanat_k])
                    cube([kanat, derinlik - 8, kanat_k]);
                // kanadın altında 45° destek: solda ortada, sağda keystone fişine yer kalsın diye kanadın iki ucunda
                hull() {
                    translate([s > 0 ? x_sag - 0.01 : x_sol - kanat + 0.01, derinlik/2 - 4, -kanat_k - 0.01]) cube([kanat, 8, 0.01]);
                    translate([s > 0 ? x_sag - 0.01 : x_sol - 0.01, derinlik/2 - 4, -kanat_k - kanat]) cube([0.02, 8, 0.01]);
                }
            }
        }
        // OLED penceresi ve cebi (cep içeriden)
        yuzde(oled_u, 0) {
            translate([pencere_x - pencere[0]/2, -pencere[1]/2, -on_duvar - 1]) cube([pencere[0], pencere[1], on_duvar + 2]);
            translate([-oled_kart[0]/2, -oled_kart[1]/2, -on_duvar - 1]) cube([oled_kart[0], oled_kart[1], on_duvar + 1 - oled_cilt]);
        }
        // switch takma kanalı ve açık arka: yalnızca kutunun iç hacminde (dış duvarlar delinmez)
        intersection() {
            translate([0, 0, 0.01]) ic_bosluk();
            for (b = butonlar) yuzde(b[0], 0) {
                // switch ve başlık kutunun açık üstünden aşağı kayarak cebe oturur
                translate([-flans_cebi/2, 0, flans_arka]) cube([flans_cebi, 60, -flans_arka - on_duvar + 0.01]);
                translate([-sw_kafes/2, 0, sw_arka]) cube([sw_kafes, 60, flans_arka - sw_arka + 0.01]);
                // cebin arkası açık (bacaklar ve kablolar için), ortada 4 mm dayanak çubuğu kalır
                // bacaklar 12,5 x 5 mm aralıklı ve gövdeden taşar: açıklık kafes duvarlarını da kapsar
                // 6x6 switch bacakları 6,5 x 4,5 mm aralıklı: ortada 2 mm dayanak çubuğu, iki yanda bacak açıklığı
                for (sv = [-1, 1]) translate([-4, sv > 0 ? 1 : -4, -40]) cube([8, 3, 40 + sw_arka + 0.01]);
            }
        }
        // butonlar + semboller
        for (b = butonlar) yuzde(b[0], 0) {
            translate([0, 0, -on_duvar - 1]) cylinder(d = buton_delik, h = on_duvar + 2);
            // switch cebi
            translate([-flans_cebi/2, -flans_cebi/2, flans_arka]) cube([flans_cebi, flans_cebi, -flans_arka - on_duvar + 0.01]);
            translate([-sw_kafes/2, -sw_kafes/2, sw_arka]) cube([sw_kafes, sw_kafes, flans_arka - sw_arka + 0.01]);
        }
        // keystone deliği: arka duvar (fiş arkadan takılır, jack gövdesi içeride)
        translate([ks_x - ks_delik[0]/2, derinlik - duvar - 1, ks_z - ks_delik[1]/2]) cube([ks_delik[0], duvar + 2, ks_delik[1]]);
        // kanat vida delikleri (havşalı, alttan)
        for (s = [-1, 1], y = [10, derinlik - 10]) translate([s > 0 ? x_sag + kanat/2 : x_sol - kanat/2, y, 0]) {
            translate([0, 0, -kanat_k - 1]) cylinder(d = ahsap_vida, h = kanat_k + 2);
            translate([0, 0, -kanat_k - 0.01]) cylinder(d1 = ahsap_kafa, d2 = ahsap_vida, h = (ahsap_kafa - ahsap_vida)/2);
        }
    }
    // OLED'i cebe bastıran iki tırnak yeri (sıcak silikonla da sabitlenebilir)
}

// Baskı yönü: kutunun altı tablada, açık üst yukarı. Ön yüz 10° eğimli, kanatların altı 45° destekli.
translate([0, 0, yukseklik]) panel();
