close all;
% Let TA pick from the pre-recorded wav file or record your spoken word live:
Fs = 44100; 
nBits = 16; 
nChannels = 2 ; 
ID = -1; % default audio input device 
prompt = 'type 0 (record live), 1 (wav file 1) or 2 (wav file 2) then hit enter => ';
x = input(prompt);

if x == 0 % I will say one of the words and record live
    recObj = audiorecorder(Fs,nBits,nChannels,ID);
    disp('Start speaking.')
    recordblocking(recObj, 2);
    disp('End of Recording.');
    y = getaudiodata(recObj);
    sound(y,Fs);
    
elseif x == 1 % the first word "KEY" was chosen
    [y, Fs] = audioread('word1.wav');
    sound(y,Fs);
    
elseif x == 2 % the second word "DOOR" was chosen
    [y, Fs] = audioread('word2.wav');
    sound(y,Fs);
    
else
    disp('Error!');
end
% y stores the speech sound signal, (can be wav1/wav2/record on the scene)

FT_of_y = abs(fft(y));
%plot(FT_of_y);
[max_mag,ind]=max(FT_of_y);
% disp('the largest magnitude is'); disp(max(FT_of_y));
% disp('its ind is');disp(ind(1));
ind = ind(1);

% now find the FT of the two known word data:
[word_bar,Fs1] = audioread('word1.wav');
[word_door,Fs2]=audioread('word2.wav');

FT_of_bar = abs(fft(word_bar));
FT_of_door = abs(fft(word_door));

[max_mag_of_bar, ind_bar] = max(FT_of_bar);
[max_mag_of_door, ind_door] = max(FT_of_door);
ind_bar = ind_bar(1);
ind_door = ind_door(1);

% now compare the recording with word1 and word2 and figure out which word
% was said
diff_between_bar = abs(ind_bar-ind);
diff_between_door=abs(ind_door-ind);

if diff_between_bar < diff_between_door
    disp('the spoken word was "bar"');
else
    disp('the spoken word was "door"');
end

