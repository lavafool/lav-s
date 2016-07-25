function solusivrp = ConvertToVRPSolution (solusitsp, demandkota, kapasitaskendaraan)
jumlahkota = numel(solusitsp) - 2;
solusivrp = ones (1, jumlahkota * 2 + 1);
demandsekarang = 0;
indexvrpsekarang = 1;

for i =2 : jumlahkota + 1
    if demandsekarang + demandkota(solusitsp(i)) <= kapasitaskendaraan  % tidak perlu buat rute baru
        demandsekarang = demandsekarang + demandkota(solusitsp(i));
        indexvrpsekarang = indexvrpsekarang + 1;
        solusivrp (indexvrpsekarang) = solusitsp (i);
    else % perlu buat rute baru
        % sisipkan depot kota 1
        %demandsekarang = 0; 
        indexvrpsekarang = indexvrpsekarang + 1;
        solusivrp (indexvrpsekarang) = 1;
        % sisipkan kota berikutnya di rutebaru
        demandsekarang = demandkota(solusitsp(i));
        indexvrpsekarang = indexvrpsekarang + 1;
        solusivrp (indexvrpsekarang) = solusitsp (i);
    end
    
    
end