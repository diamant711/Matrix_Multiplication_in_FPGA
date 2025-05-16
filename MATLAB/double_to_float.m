%function [M_bin E_bin] = double_to_float(N_dec,M_bit,E_bit)
function [S_bin M_bin E_bin] = double_to_float(N_dec,M_bit,E_bit)
E=0;
if N_dec < 0
    S_bin=true;
else
    S_bin=false;
end
N_dec=abs(N_dec);
if N_dec>=1
while (N_dec>=1)
    N_dec=N_dec/2;
    E=E+1;
end
else
while (N_dec<0.5)
    N_dec=N_dec*2;
    E=E-1;
end
end
if (E>=2^(E_bit-1)) || (E<-2^(E_bit-1))
    disp('Errore')
    E_bin=nan;
    M_bin=nan;
    S_bin=nan;
    return
else
    M_bin=dec_to_bin(floor(N_dec*2^M_bit),M_bit,'unsigned');
    E_bin=dec_to_bin(E,E_bit,'signed');
end