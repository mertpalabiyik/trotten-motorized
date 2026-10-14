// HC-SR04 ara parçası (yükseltici): basılmış kapak-revize'nin İÇİNE oturur.
// Altındaki 4 delik kapaktaki 4 adet Ø3 pime geçer (parça pimlere oturur, kaymaz).
// Sensör kartı parçanın üstündeki yuvaya yatar, kapsüller parçadan ve kapak tabanından geçer,
// uçları kapağın dış yüzüyle sıfır biter.

kapsul_boy  = 12.0;   // kapsülün karttan yüksekliği: KUMPASLA ÖLÇ (12–12,5 arası olur)
kapak_taban = 2.4;    // kapak-revize duvar kalınlığı
cikinti     = 0.0;    // kapsül dışarı ne kadar çıksın (0 = sıfır, -0.3 = hafif içeride)
yukseklik   = kapsul_boy - kapak_taban - cikinti;   // = 9.6

/* [Kapaktaki pimler] */
pim_x = 24;  pim_y = 11.5;   // pim merkezleri (kapak-revize: hc ± 24, ± 11.5)
pim_delik = 3.6;             // pim Ø3 + pay
pim_derin = 4.6;             // pim 4 mm boyunda

/* [Gövde ve kart] */
boy = [56, 31];              // pimlerin dışına taşar
aralik   = 26;               // kapsül merkezleri arası (kapak ile aynı)
kapsul_d = 16.8;             // kapsül Ø16 + pay
kart     = [45.6, 20.6];     // HC-SR04 kartı 45 x 20 + pay: kart bu yuvaya oturur
kart_yuva = 1.2;             // yuva derinliği
cep      = 4.0;              // kartın ön yüzündeki kristal ve SMD parçalar için cep (yuvanın altından)
kenar    = 1.5;              // kartın yaslandığı kenar
vida_x = 20.5; vida_y = 8.5; // kartın köşe delikleri (41 x 17)
vida_d = 1.7;                // M2 sac vidası
konnektor = [13, 3.2];       // 4 pinli başlığın plastik gövdesi için çentik (iki uzun kenarda)

$fn = 64;
ust = yukseklik;             // kartın alt yüzü bu yükseklikte

difference() {
    translate([-boy[0]/2, -boy[1]/2, 0]) cube([boy[0], boy[1], ust + kart_yuva]);
    // kapaktaki pimlere geçen delikler (altta)
    for (sx = [-1, 1], sy = [-1, 1]) translate([sx*pim_x, sy*pim_y, -0.01]) cylinder(d = pim_delik, h = pim_derin);
    // kapsül delikleri
    for (s = [-1, 1]) translate([s*aralik/2, 0, -1]) cylinder(d = kapsul_d, h = ust + kart_yuva + 2);
    // kart yuvası
    translate([-kart[0]/2, -kart[1]/2, ust]) cube([kart[0], kart[1], kart_yuva + 1]);
    // yuvanın altında cep: kart yalnızca kenarlara ve köşe bloklarına yaslanır
    difference() {
        translate([-kart[0]/2 + kenar, -kart[1]/2 + kenar, ust - cep]) cube([kart[0] - 2*kenar, kart[1] - 2*kenar, cep + 0.01]);
        for (sx = [-1, 1], sy = [-1, 1]) translate([sx*vida_x - 2.5, sy*vida_y - 2.5, 0]) cube([5, 5, ust]);
    }
    // köşe vida delikleri
    for (sx = [-1, 1], sy = [-1, 1]) translate([sx*vida_x, sy*vida_y, ust - 5]) cylinder(d = vida_d, h = 7);
    // pin başlığı çentiği (kart hangi yöne dönerse dönsün)
    for (sy = [-1, 1]) translate([-konnektor[0]/2, sy > 0 ? kart[1]/2 - kenar - 0.5 : -boy[1]/2 - 1, ust - konnektor[1]])
        cube([konnektor[0], sy > 0 ? boy[1]/2 - kart[1]/2 + kenar + 1.5 : boy[1]/2 - kart[1]/2 + kenar + 1.5, konnektor[1] + 5]);
}
