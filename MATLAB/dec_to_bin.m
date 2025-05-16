% function [N_bin] = dec_to_bin(N_dec,N_bin,Type)
function [N_bin] = dec_to_bin(N_dec,N_bit,Type)
if (strcmp(Type,'unsigned'))
    if ((N_dec>=2^N_bit) || (N_dec <0))
        disp('Errore')
        return
    end
    for cont=N_bit:-1:1
        if (N_dec>=2^(cont-1))
            N_bin(cont)=true;
            N_dec = N_dec - 2^(cont-1);
        else
            N_bin(cont)=false;
        end
    end
    N_bin=flip(N_bin);
elseif (strcmp(Type,'signed'))
    if ((N_dec>=2^(N_bit-1)) || (N_dec <-2^(N_bit-1)))
        disp('Errore')
        return
    end
    if (N_dec<0)
        N_dec = N_dec + 2^N_bit;
    end
    for cont=N_bit:-1:1
        if (N_dec>=2^(cont-1))
            N_bin(cont)=true;
            N_dec = N_dec - 2^(cont-1);
        else
            N_bin(cont)=false;
        end
    end
    N_bin=flip(N_bin);
end
