close all;
txMsg = 'WX';
SPB = 20;
% define step-like waveform to send over channel
training_bitseq = [zeros(1,20),ones(1,40)];
msg_bit = text2bitseq(txMsg);
tx_bit = [training_bitseq,msg_bit];
tx_wave = bitseq2waveform(tx_bit,SPB);
rx_wave=txrx(tx_wave);

% fit_rcv(rx_wave,c,d,k,a) fits rx_wave by a function of the form
% y(n) = c + k*(1-a^(n-d)) for n >= d and 0 otherwise.


% find optimal c and k
c = min(rx_wave)+0.02;
k = max(rx_wave)-min(rx_wave)-0.03;

filtered_rx_wave =[c,c,c,c,c,c,c,c,c,c];
window = filtered_rx_wave;
for i = 11:length(rx_wave)
    filtered_rx_wave = [filtered_rx_wave,mean(window)];
    window=[window(2:end),rx_wave(i)]; 
end
rx_wave = filtered_rx_wave;

% % find optimal d
% d = 100; a = 0.925;
% posible_mses_for_d = [];
% for d = 200:800
%     thisMse = fit_rcv(rx_wave,c,d,k,a);
%     posible_mses_for_d = [posible_mses_for_d, thisMse];
% end
% [min_MSE_for_d,indd]=min(posible_mses_for_d);
% d = indd+100;

for p = 1:1000
    thisSampleValue = rx_wave(p);
    check40successiveIncreament;
    if have40continousIncrease
        break;
    end
end
d = p;  

%find the optimal a
posible_mses_for_a=[];
for a = 0.5:0.01:1
    thisMse = fit_rcv(rx_wave,c,d,k,a);
    posible_mses_for_a = [posible_mses_for_a, thisMse];
end
[min_MSE_for_a,inda]=min(posible_mses_for_a);
a = 0.01*inda + 0.49;

% % % Do not change the code below % % %
%threshold = (2*c+k)/2;
threshold = 0.5*(max(rx_wave)+min(rx_wave));

mse = fit_rcv(rx_wave,c,d,k,a); % fit channel output to model

title('Step Response'); % put title on graph
display(['MSE = ' num2str(mse)]); % print out MSE of fit

figure(2);plot([1:length(tx_wave)],tx_wave);

% try to equalize the rx_wave to make it a perfect square wave
equalized_rxWave =[rx_wave(1)];
% STEP 1: get rid of ISI and offset
lengthOfOriginalRxWave = length(rx_wave);
for i = 2:lengthOfOriginalRxWave
    nextValue=(1/((1-a)*k))*(rx_wave(i)-a*rx_wave(i-1))-c;
    equalized_rxWave=[equalized_rxWave,nextValue];
end
% STEP 2: apply moving average to filter out high frequncy noise
rxWaveDataArray =[zeros(1,10)];
window = rxWaveDataArray;
for i = 11:length(equalized_rxWave)
    rxWaveDataArray = [rxWaveDataArray,mean(window)];
    window=[window(2:end),equalized_rxWave(i)]; 
end
% NOW, THE ONLY PROBLEM OF THE RX_WAVE SHOULD BE THE HORIZONTAL SHIFTING
% THE BEST RX_WAVEFORM IS STROED AS "rxWaveDataArray"

% try to decode the bit sequence from the equalized and filtered rx_wave
decoded_bitseq = [];
start_sample = d-400;
start_sample = start_sample + 60*20;
start_sample = start_sample + SPB -1;
for k = start_sample:SPB:length(equalized_rxWave)
    if rxWaveDataArray(k)>threshold
        decoded_bitseq = [decoded_bitseq,1];
    else
        decoded_bitseq = [decoded_bitseq,0];
    end
end

figure(3);plot([1:length(equalized_rxWave)],rxWaveDataArray);hold on;
yline(threshold);xline(start_sample);

figure(4);subplot(211);stem(tx_bit);subplot(212);stem(decoded_bitseq);

%%%
decoded_bitseq = decoded_bitseq(1:16);
rxMsg = bitseq2text(decoded_bitseq);


