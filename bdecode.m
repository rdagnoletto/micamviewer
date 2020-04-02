function [  ] = bdecode( A1, A2 )

wavfile1 = 'C:\Users\Rob\Desktop\mic\EastWest\EastWest_W';
wavfile2 = 'C:\Users\Rob\Desktop\mic\EastWest\EastWest_X';
wavfile3 = 'C:\Users\Rob\Desktop\mic\EastWest\EastWest_Y';
wavfile4 = 'C:\Users\Rob\Desktop\mic\EastWest\EastWest_Z';

[w Fsw] = wavread(wavfile1);
[x Fsx] = wavread(wavfile2);
[y Fsy] = wavread(wavfile3);
[z Fsz] = wavread(wavfile4);
a=-pi/4;
wavout = 0.5*(w + x*cos(a) + y*sin(a) + z*sin(0));

postwavfile = 'C:\Users\Rob\Desktop\mic\EastWest\test_west_45';

wavwrite(wavout, Fsw, postwavfile);

end

