// 6x6 mm tactile switch için buton başlıkları (3 adet: ▲ ▼ ■)
// AMS / çok renkli baskı:
// parca = "taban"   : flanş + gövde + işaretler, üç başlıkta aynı renk (1. renk)
// parca = "ust_yon" : ▲ ve ▼ başlıklarının üst kısmı (2. renk)
// parca = "ust_dur" : ■ başlığının üst kısmı (3. renk, ör. kırmızı)
// Hepsi aynı koordinatta: slicer'da tek nesne olarak birleştir, her parçaya renk ata.
// Tek renkli yazıcı için: parca = "kabartma" (ust_z'de filament değiştir).
// Flanş tablada basılır.

parca = "govde";

tirnak_cap   = 3.9;  // 6x6 switch'in siyah çubuğu Ø3,5 + pay: başlık bu yuvayla çubuğa oturur
tirnak_derin = 1.0;  // panel-kutusu.scad'deki baslik_tirnak ile aynı
govde_cap  = 10;     // panel deliği 10,6
govde_boy  = 4.4;    // duvar 2,6 + dışarı taşma 1,8
flans_cap  = 12;     // switch yuvasının takma kanalından (12,4) geçmeli, delikten (10,6) büyük olmalı
flans_k    = 1.2;
isaret_k   = 0.6;    // işaretin kalınlığı (0,2 mm katmanda 3 katman)
pah        = 0.6;    // üst kenar pahı
ust_k      = 1.6;    // üst renkli kısmın kalınlığı (0,2 mm katmanda 8 katman)

ust_z = flans_k + govde_boy;           // başlığın üst yüzü
kabartma_z = ust_z;                    // tek renk: bu yükseklikte filament değiştir

$fn = 64;

module isaret(tip) {
    if (tip == "up")   polygon([[-3.2, -2.2], [3.2, -2.2], [0, 3.2]]);
    if (tip == "down") polygon([[-3.2, 2.2], [3.2, 2.2], [0, -3.2]]);
    if (tip == "stop") translate([-2.4, -2.4]) square(4.8);
}

module govde_ham() {
    difference() {
        union() {
            cylinder(d = flans_cap, h = flans_k);
            cylinder(d = govde_cap, h = ust_z - pah);
            translate([0, 0, ust_z - pah]) cylinder(d1 = govde_cap, d2 = govde_cap - 2*pah, h = pah);
        }
        translate([0, 0, -0.01]) cylinder(d = tirnak_cap, h = tirnak_derin + 0.01);
    }
}

module ust_bolge() translate([-10, -10, ust_z - ust_k]) cube([20, 20, ust_k + 1]);

module baslik(tip, i) {
    if (parca == "govde")
        difference() { govde_ham(); translate([0, 0, ust_z - isaret_k]) linear_extrude(isaret_k + 1) isaret(tip); }
    if (parca == "isaret")
        translate([0, 0, ust_z - isaret_k]) linear_extrude(isaret_k) offset(delta = -0.05) isaret(tip);
    if (parca == "kabartma")
        union() { govde_ham(); translate([0, 0, ust_z - 0.01]) linear_extrude(isaret_k + 0.01) isaret(tip); }
    // AMS: taban (işaretler üst kısmın içinden yüzeye kadar çıkar) + renkli üst kısım
    if (parca == "taban")
        union() {
            difference() { govde_ham(); ust_bolge(); }
            intersection() { govde_ham(); translate([0, 0, ust_z - ust_k - 0.01]) linear_extrude(ust_k + 0.02) isaret(tip); }
        }
    if ((parca == "ust_yon" && tip != "stop") || (parca == "ust_dur" && tip == "stop"))
        difference() {
            intersection() { govde_ham(); ust_bolge(); }
            translate([0, 0, ust_z - ust_k - 1]) linear_extrude(ust_k + 2) isaret(tip);
        }
}

for (i = [0:2]) translate([i * 16, 0, 0]) baslik(["up", "down", "stop"][i], i);
