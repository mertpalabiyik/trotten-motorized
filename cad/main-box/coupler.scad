// TROTTEN kaplin: motor mili (6 mm D-kesit) <-> 6 mm altıgen çubuk (kesilmiş alyan)
// Dik basılır, motor ucu tablada. PETG, %100 doluluk veya 6+ duvar önerilir.

dis_cap   = 20;
boy       = 32;

/* [Motor mili – JGB37] */
mil_cap   = 6.2;     // 6 mm + baskı payı
mil_duz   = 5.6;     // düz yüzeyle karşı kenar arası (D-kesit) – kumpasla ölç
mil_derin = 14;

/* [Altıgen çubuk] */
alt_karsi = 6.25;    // 6 mm altıgen + baskı payı (karşılıklı yüzeyler arası)
alt_derin = 16;

/* [Sıkma vidası M3] */
m3_delik  = 3.3;
somun_gen = 5.8;     // M3 somun anahtar ağzı 5.5 + pay
somun_kal = 2.8;

$fn = 64;

module d_kesit() intersection() {
    cylinder(d = mil_cap, h = mil_derin + 0.01);
    translate([-mil_cap, -mil_cap, 0]) cube([mil_cap/2 + mil_duz, 2*mil_cap, mil_derin + 1]);   // düz yüzey x = mil_duz - mil_cap/2
}

module altigen() rotate([0, 0, 30]) cylinder(d = alt_karsi / cos(30), h = alt_derin + 1, $fn = 6);

// sıkma vidası + somun yuvası; yuva vidanın girdiği uçtaki yüze açılır
module sikma(z, ac_yukari) {
    translate([0, 0, z]) rotate([0, 90, 0]) cylinder(d = m3_delik, h = dis_cap);
    r = 5.6;
    translate([r, -somun_gen/2, ac_yukari ? z - somun_gen/2 : -1])
        cube([somun_kal, somun_gen, ac_yukari ? boy - z + somun_gen/2 + 1 : z + somun_gen/2 + 1]);
}

difference() {
    cylinder(d = dis_cap, h = boy);
    translate([0, 0, -0.01]) d_kesit();
    translate([0, 0, boy - alt_derin]) altigen();
    sikma(7, false);                 // motor tarafı: vida D-kesitin düz yüzüne basar
    sikma(boy - 8, true);            // altıgen tarafı: vida altıgenin bir yüzüne basar
}
