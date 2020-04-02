function [  ] = A2B(  )

c = 340;

wavfile1 = 'C:\Users\Rob\Desktop\FYDPWangHouse\ThousandMiles_3_North.wav';
wavfile2 = 'C:\Users\Rob\Desktop\FYDPWangHouse\ThousandMiles_3_East.wav';
wavfile3 = 'C:\Users\Rob\Desktop\FYDPWangHouse\ThousandMiles_3_West.wav';
wavfile4 = 'C:\Users\Rob\Desktop\FYDPWangHouse\ThousandMiles_3_South.wav';
wavchunksizefix(wavfile1);
wavchunksizefix(wavfile2);
wavchunksizefix(wavfile3);
wavchunksizefix(wavfile4);
[FLU, Fs1] = wavread(wavfile1);
[FRD, Fs2] = wavread(wavfile2);
[BLD, Fs3] = wavread(wavfile3);
[BRU, Fs4] = wavread(wavfile4);

sizes = [length(FLU) length(FRD) length(BLD) length(BRU)];
minsize = min(sizes);

FLU = FLU(1:minsize);
FRD = FRD(1:minsize);
BLD = BLD(1:minsize);
BRU = BRU(1:minsize);

FRD = FRD*1.1;

Wo = (FLU+FRD+BLD+BRU)/20;
Xo = (FLU+FRD-BLD-BRU)/20;
Yo = (FLU-FRD+BLD-BRU)/20;
Zo = (FLU-FRD-BLD+BRU)/20;

FWn = [1 1/c 1/(3*c^2)];
FWd = [1 1/(3*c)];

FXYZn = [1 1/(3*c) 1/(3*c^2)];
FXYZn = FXYZn*sqrt(6);
FXYZd =  [1 1/(3*c)];

W = filter(FWn, FWd, Wo);
X = filter(FXYZn, FXYZd, Xo);
Y = filter(FXYZn, FXYZd, Yo);
Z = filter(FXYZn, FXYZd, Zo);
negX = -1*X;
negY = -1*Y;
postwavfile1 = 'C:\Users\Rob\Desktop\FYDPWangHouse\B\TM_3_boost_W.wav';
postwavfile2 = 'C:\Users\Rob\Desktop\FYDPWangHouse\B\TM_3_boost_X.wav';
postwavfile3 = 'C:\Users\Rob\Desktop\FYDPWangHouse\B\TM_3_boost_Y.wav';
postwavfile4 = 'C:\Users\Rob\Desktop\FYDPWangHouse\B\TM_3_boost_Z.wav';

postwavfile5 = 'C:\Users\Rob\Desktop\FYDPWangHouse\B\TM_3_boost_negX.wav';
postwavfile6 = 'C:\Users\Rob\Desktop\FYDPWangHouse\B\TM_3_boost_negY.wav';
wavwrite(W, Fs1, postwavfile1);
wavwrite(X, Fs1, postwavfile2);
wavwrite(Y, Fs1, postwavfile3);
wavwrite(Z, Fs1, postwavfile4);

wavwrite(negX, Fs1, postwavfile5);
wavwrite(negY, Fs1, postwavfile6);

end
function wavchunksizefix( filename )
d = dir(filename);
fileSize = d.bytes;
fid=fopen(filename,'r+','l');
fseek(fid,4,-1);
fwrite(fid,fileSize-8,'uint32');
fseek(fid,40,-1);
fwrite(fid,fileSize-44,'uint32');
fclose(fid);
end

