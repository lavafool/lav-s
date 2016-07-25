%Ini adalah implementasi Tabu Search untuk Traveling Salesman
%Problem

%untuk merekam waktu komputasi yang dibutuhkan
tic;

%input data
JumlahKota = 10;
X_coordinate = [ 10 3 5 40 34 98 21 90 106 183 102];
Y_coordinate = [10 120 45 71 91 23 38 98 110 140 105];
Demand = [ 0 8 7 3 4 9 3 5 3 4 6];
KapasitasKendaraan = 15;

% tabu list
PanjangTabu = 10;
TabuList = ones(PanjangTabu, 3);

% Parameter TS
JumlahIterasiMaksimum = 1000;
JumlahSolusiTetangga = 100;

%generate tabel Jarak
MatriksJarak = GenerateDistanceMatrix(X_coordinate, Y_coordinate);
JaarakSolusiMaksimum = sum(sum(MatriksJarak));

%Generate initial solution
%SolusiAwal = GenerateSolusiNearestNeighbour(MatriksJarak);
SolusiAwal = GenerateSolusiRandom(JumlahKota);
SolusiVRPAwal = ConvertToVRPSolution(SolusiAwal, Demand, KapasitasKendaraan);
JarakSolusiAwal = CalculateTotalDistance(SolusiVRPAwal, MatriksJarak);

%Catat kondisi awal
%Tsekarang = Tawal;
SolusiTerbaik = SolusiAwal; %solusi global
SolusiVRPTerbaik = SolusiVRPAwal; %solusi global
JarakSolusiTerbaik = JarakSolusiAwal; % Jarak solusi global
SolusiSaatIni = SolusiAwal; %solusi iterasi
SolusiVRPSaatIni = SolusiVRPAwal; %solusi iterasi
JarakSolusiSaatIni = JarakSolusiAwal; % Jarak solusi iterasi

TabelSolusiTSPTetangga = zeros(JumlahSolusiTetangga, JumlahKota + 2);
TabelSolusiVRPTetangga = zeros(JumlahSolusiTetangga, JumlahKota * 2 + 1);
TabelJarakSolusiVRPTetangga = zeros(1, JumlahSolusiTetangga);
TabelOperasiLocalSearch = zeros(JumlahSolusiTetangga, 3);

SolusiTSPTetanggaTerbaik = zeros(1, JumlahKota + 2);
SolusiVRPTetanggaTerbaik = zeros(1, JumlahKota * 2 + 1);
JarakSolusiVRPTetanggaTerbaik = 0;

SolusiTSPTetanggaTabuTerbaik = zeros(1, JumlahKota + 2);
SolusiVRPTetanggaTabuTerbaik = zeros(1, JumlahKota * 2 + 1);
JarakSolusiVRPTetanggaTabuTerbaik = 0;


% Mulai iterasi TS
for i = 1 : JumlahIterasiMaksimum
    
    %generate solusi tetangga
    for j = 1 : JumlahSolusiTetangga
        
        Pilihan = randi(3);
        switch (Pilihan)
            case 1 % 1-insert
                [TabelSolusiTSPTetangga(j, :) Kota_1 Kota_2 ] = PerformInsert(SolusiSaatIni);
                TabelSolusiVRPTetangga(j, :) = ConvertToVRPSolution(TabelSolusiTSPTetangga(j, :), Demand, KapasitasKendaraan);
                TabelJarakSolusiVRPTetangga(j) = CalculateTotalDistance(TabelSolusiVRPTetangga(j, :), MatriksJarak);
                
            case 2 % 1-swap
                [TabelSolusiTSPTetangga(j, :)  Kota_1 Kota_2 ] = PerformSwap(SolusiSaatIni);
                TabelSolusiVRPTetangga(j, :) = ConvertToVRPSolution(TabelSolusiTSPTetangga(j, :), Demand, KapasitasKendaraan);
                TabelJarakSolusiVRPTetangga(j) = CalculateTotalDistance(TabelSolusiVRPTetangga(j, :), MatriksJarak);
                
            case 3 % 2-opt
                [TabelSolusiTSPTetangga(j, :)  Kota_1 Kota_2 ] = Perform2Opt(SolusiSaatIni);
                TabelSolusiVRPTetangga(j, :) = ConvertToVRPSolution(TabelSolusiTSPTetangga(j, :), Demand, KapasitasKendaraan);
                TabelJarakSolusiVRPTetangga(j) = CalculateTotalDistance(TabelSolusiVRPTetangga(j, :), MatriksJarak);
        end
        TabelOperasiLocalSearch(j, :) = [Pilihan  Kota_1 Kota_2];
    end
    
    %bedakan antara yg tabu maupun yg tidak tabu
    ApakahTabu = zeros(1, JumlahSolusiTetangga);
    for j = 1 : JumlahSolusiTetangga
        for k = 1 : PanjangTabu
            if TabelOperasiLocalSearch(j, :) == TabuList(k, :)
                ApakahTabu(j) = 1;
            end
        end
    end
    
    %cari solusi tetangga terbaik yg tabu maupun yg tidak tabu
    IndeksTabuTerbaik = 1;
    IndeksTidakTabuTerbaik = 1;  
    JarakSolusiVRPTetanggaTerbaik = JaarakSolusiMaksimum;
    JarakSolusiVRPTetanggaTabuTerbaik = JaarakSolusiMaksimum;
    for j = 1 : JumlahSolusiTetangga
        if  ApakahTabu(j) == 0 % apabila tidak tabu
            if TabelJarakSolusiVRPTetangga(j) < JarakSolusiVRPTetanggaTerbaik
                SolusiTSPTetanggaTerbaik = TabelSolusiTSPTetangga(j, :);
                SolusiVRPTetanggaTerbaik = TabelSolusiVRPTetangga(j, :);
                JarakSolusiVRPTetanggaTerbaik = TabelJarakSolusiVRPTetangga(j);
                IndeksTidakTabuTerbaik = j;
            end
        else
            if TabelJarakSolusiVRPTetangga(j) < JarakSolusiVRPTetanggaTabuTerbaik
                SolusiTSPTetanggaTabuTerbaik = TabelSolusiTSPTetangga(j, :);
                SolusiVRPTetanggaTabuTerbaik = TabelSolusiVRPTetangga(j, :);
                JarakSolusiVRPTetanggaTabuTerbaik = TabelJarakSolusiVRPTetangga(j);
                IndeksTabuTerbaik = j;
            end
        end
    end
    
    % uji yg tabu dengan global, kalau tidak masukkan yg tidak tabu
    if JarakSolusiVRPTetanggaTabuTerbaik < JarakSolusiTerbaik
        SolusiTerbaik = SolusiTSPTetanggaTabuTerbaik; %solusi global
        SolusiVRPTerbaik = SolusiVRPTetanggaTabuTerbaik; %solusi global
        JarakSolusiTerbaik = JarakSolusiVRPTetanggaTabuTerbaik; % Jarak solusi global
        SolusiSaatIni = SolusiTSPTetanggaTabuTerbaik; %solusi iterasi
        SolusiVRPSaatIni = SolusiVRPTetanggaTabuTerbaik; %solusi iterasi
        JarakSolusiSaatIni = JarakSolusiVRPTetanggaTabuTerbaik; % Jarak solusi iterasi
        %update tabu list
        IndeksTabuList = mod(i, PanjangTabu) + 1;
        TabuList(IndeksTabuList, :) = TabelOperasiLocalSearch(IndeksTabuTerbaik, :);
    else %update solusi saat ini dari solusi tidak tabu
        SolusiSaatIni = SolusiTSPTetanggaTerbaik; %solusi iterasi
        SolusiVRPSaatIni = SolusiVRPTetanggaTerbaik; %solusi iterasi
        JarakSolusiSaatIni = JarakSolusiVRPTetanggaTerbaik; % Jarak solusi iterasi
        if JarakSolusiVRPTetanggaTerbaik < JarakSolusiTerbaik
            SolusiTerbaik = SolusiTSPTetanggaTerbaik; %solusi global
            SolusiVRPTerbaik = SolusiVRPTetanggaTerbaik; %solusi global
            JarakSolusiTerbaik = JarakSolusiVRPTetanggaTerbaik; % Jarak solusi global
        end
        %update tabu list
        IndeksTabuList = mod(i, PanjangTabu) + 1;
        TabuList(IndeksTabuList, :) = TabelOperasiLocalSearch(IndeksTidakTabuTerbaik, :);
    end
end
%disp('berapa kali PP');
%berapakalipp = hitungberapakalipp (sol2);
%disp(berapakalipp);

disp ('Jarak Terbaik');
disp (JarakSolusiTerbaik);
disp (SolusiVRPTerbaik);
toc
