% function [N_dec] = bin_to_dec(N_bin,Type)
function [N_dec] = bin_to_dec(N_bin,Type)
N_bin=flip(N_bin);
if ~islogical(N_bin)
    N_bin = (N_bin == '1');
end
N_bit=length(N_bin);
N_dec = 0;
for cont=N_bit:-1:1
    N_dec = N_dec + 2^(cont-1) * N_bin(cont);
end
if (strcmp(Type,'signed') && (N_dec >= 2^(N_bit-1)))
    N_dec = N_dec - 2^N_bit;
elseif (~strcmp(Type,'signed'))
    disp('Errore')
end
end
