%function [N_dec] = float_to_double(S_bin, M_bin, E_bin)
function [N_dec] = float_to_double(S_bin, M_bin, E_bin)
M_bit = length(M_bin);
N_dec=(-1)^S_bin*bin_to_dec(M_bin,'unsigned')*2^(bin_to_dec(E_bin,'signed')-M_bit);