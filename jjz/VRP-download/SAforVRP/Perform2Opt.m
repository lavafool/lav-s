function [Solusi2Opt  Kota_1 Kota_2]= Perform2Opt(SolusiAwal)
JumlahKota = numel(SolusiAwal) - 2;
Index_1 = randi(JumlahKota) + 1;
Index_2 = Index_1;
while Index_1 >= Index_2
    Index_1 = randi(JumlahKota) + 1;
    Index_2 = randi(JumlahKota) + 1;
end
Kota_1 = SolusiAwal(Index_1); 
Kota_2 = SolusiAwal(Index_2);
Solusi2Opt = SolusiAwal;
Solusi2Opt(Index_1:Index_2) = SolusiAwal(Index_2:-1:Index_1);