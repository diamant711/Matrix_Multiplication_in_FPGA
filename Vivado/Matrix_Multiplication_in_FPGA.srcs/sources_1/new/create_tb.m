clear variables
close all
Baudrate = 115200;
DT=round(1e9/115200);
TX=[0:255];
FILENAME='test_bench_vhdl.txt';
fid=fopen(FILENAME,'wt');
fprintf(fid,'%s\n','P21_Test_TX : process');
fprintf(fid,'%s\n','begin');
fprintf(fid,'%s\n',['TB_D_IN <= ''1'';']);
fprintf(fid,'%s%d%s\n','wait for ', DT*10, ' ns;');        
for q=1:length(TX)
    seq=flip(dec2bin(TX(q),8));
    fprintf(fid,'%s\n',['TB_D_IN <= ''0'';']);
    fprintf(fid,'%s%d%s\n','wait for ', DT, ' ns;');        
    for w=1:length(seq)
        if strcmp(seq(w),'1')
            fprintf(fid,'%s\n',['TB_D_IN <= ''1'';']);
        else
            fprintf(fid,'%s\n',['TB_D_IN <= ''0'';']);
        end
        fprintf(fid,'%s%d%s\n','wait for ', DT, ' ns;');        
    end
    fprintf(fid,'%s\n',['TB_D_IN <= ''1'';']);
    fprintf(fid,'%s%d%s\n','wait for ', DT, ' ns;');        
end

fprintf(fid,'%s\n','wait;');
fprintf(fid,'%s\n','end process;');
fclose(fid);



