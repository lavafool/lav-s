%Ini adalah implementasi Simulated Annealing untuk Traveling Salesman
%Problem

%untuk merekam waktu komputasi yang dibutuhkan
tic;

%input data
JumlahKota = 10;
X_coordinate = [ 10 3 5 40 34 98 21 90 106 183 102];
Y_coordinate = [10 120 45 71 91 23 38 98 110 140 105];
Demand = [ 0 8 7 3 4 9 3 5 3 4 6];
KapasitasKendaraan = 15;
Tawal = 10000;
Takhir = 10;
TingkatPenurunanSuhu = 0.9999;

%generate tabel jarak
MatriksJarak = GenerateDistanceMatrix(X_coordinate, Y_coordinate);

%Generate initial solution
%SolusiAwal = GenerateSolusiNearestNeighbour(MatriksJarak);
SolusiAwal = GenerateSolusiRandom(JumlahKota);
SolusiVRPAwal = ConvertToVRPSolution(SolusiAwal, Demand, KapasitasKendaraan);
JarakSolusiAwal = CalculateTotalDistance(SolusiVRPAwal, MatriksJarak);

%Catat kondisi awal
Tsekarang = Tawal;
SolusiTerbaik = SolusiAwal; %solusi global
SolusiVRPTerbaik = SolusiVRPAwal; %solusi global
jarakSolusiTerbaik = JarakSolusiAwal; % jarak solusi global
SolusiSaatIni = SolusiAwal; %solusi iterasi
SolusiVRPSaatIni = SolusiVRPAwal; %solusi iterasi
jarakSolusiSaatIni = JarakSolusiAwal; % jarak solusi iterasi

% Mulai iterasi SA
while Tsekarang > Takhir
    
    % pilih local search secara random
    Pilihan = randi(3);
    switch (Pilihan)
        case 1 % 1-insert
            SolusiTetangga = PerformInsert(SolusiSaatIni);
            SolusiVRPTetangga = ConvertToVRPSolution(SolusiTetangga, Demand, KapasitasKendaraan);
            JarakSolusiTetangga = CalculateTotalDistance(SolusiVRPTetangga, MatriksJarak);
            
        case 2 % 1-swap
            SolusiTetangga = PerformSwap(SolusiSaatIni);
            SolusiVRPTetangga = ConvertToVRPSolution(SolusiTetangga, Demand, KapasitasKendaraan);
            JarakSolusiTetangga = CalculateTotalDistance(SolusiVRPTetangga, MatriksJarak);
            
        case 3 % 2-opt
            SolusiTetangga = Perform2Opt(SolusiSaatIni);
            SolusiVRPTetangga = ConvertToVRPSolution(SolusiTetangga, Demand, KapasitasKendaraan);
            JarakSolusiTetangga = CalculateTotalDistance(SolusiVRPTetangga, MatriksJarak);
    end
    
    % Cek apakah solusi tetangga lebih baik dari solusi saat ini
    if JarakSolusiTetangga < jarakSolusiSaatIni
        SolusiSaatIni = SolusiTetangga;
        SolusiVRPSaatIni = SolusiVRPTetangga;
        jarakSolusiSaatIni = JarakSolusiTetangga;
        % cek juga apakah lebih baik dari solusi global
        if JarakSolusiTetangga < jarakSolusiTerbaik
            SolusiTerbaik = SolusiTetangga;
            SolusiVRPTerbaik = SolusiVRPTetangga;
            jarakSolusiTerbaik = JarakSolusiTetangga;
        end
    else % kalau tidak lebih baik, diterima dengan probabilitas
        if rand < (Tsekarang - Takhir) / (Tawal - Takhir);
            SolusiSaatIni = SolusiTetangga;
            SolusiVRPSaatIni = SolusiVRPTetangga;
            jarakSolusiSaatIni = JarakSolusiTetangga;
        end
    end
    Tsekarang = Tsekarang * TingkatPenurunanSuhu;
end

disp('SolusiTerbaik');
disp(SolusiTerbaik);
disp('SolusiVRPTerbaik');
disp(SolusiVRPTerbaik);
disp('jarakSolusiTerbaik');
disp(jarakSolusiTerbaik);

toc
