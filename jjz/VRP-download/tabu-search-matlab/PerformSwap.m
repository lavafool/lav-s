function [SolusiSwap Kota_1 Kota_2] = PerformSwap(SolusiAwal)
JumlahKota = numel(SolusiAwal) - 2;
Index_1 = randi(JumlahKota) + 1;
Index_2 = Index_1;
while Index_2 == Index_1
    Index_2 = randi(JumlahKota) + 1;
end
Kota_1 = SolusiAwal(Index_1); 
Kota_2 = SolusiAwal(Index_2);
SolusiSwap = SolusiAwal;
SolusiSwap(Index_1) = SolusiAwal(Index_2);
SolusiSwap(Index_2) = SolusiAwal(Index_1);
end