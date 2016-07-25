function [SolusiInsert Kota_1 Kota_2] = PerformInsert(SolusiAwal)
JumlahKota = numel(SolusiAwal) - 2;
Index_1 = randi(JumlahKota) + 1;
Index_2 = Index_1;
while Index_2 == Index_1
    Index_2 = randi(JumlahKota) + 1;
end
Kota_1 = SolusiAwal(Index_1); 
Kota_2 = SolusiAwal(Index_2);
SolusiInsert = SolusiAwal;
if Index_1 > Index_2 %Jika yg dipindahkan ada di sebelah kanan
    SolusiInsert(Index_2) = SolusiAwal(Index_1);
    SolusiInsert(Index_2 + 1 : Index_1) = SolusiAwal(Index_2 : Index_1 - 1);
else %Jika yg dipindahkan ada di sebelah kiri
    SolusiInsert(Index_2) = SolusiAwal(Index_1);
    SolusiInsert(Index_1 : Index_2 - 1) = SolusiAwal(Index_1+ 1 : Index_2);
end