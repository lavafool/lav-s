function Solusi2Opt= Perform2Opt_md(SolusiAwal)
if numel(SolusiAwal)>3;
JumlahKota = numel(SolusiAwal) - 2;
Index_1 = randi(JumlahKota) + 1;
Index_2 = Index_1;
while Index_1 > Index_2
    Index_1 = randi(JumlahKota) + 1;
    Index_2 = randi(JumlahKota) + 1;
end
Solusi2Opt = SolusiAwal;
Solusi2Opt(Index_1:Index_2) = SolusiAwal(Index_2:-1:Index_1);
else
    Solusi2Opt=SolusiAwal;
end