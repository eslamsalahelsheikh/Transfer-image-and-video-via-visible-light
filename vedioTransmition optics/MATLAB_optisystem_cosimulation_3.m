%% This m-file shows how to generate data in MATLAB , pass it through optisystem and configure simulation parameters 
%-----------------------------------------------
clc
close all
clear all
%-----------------------------------------------

%% transmition

%read video file
v = VideoReader('Dubstep Bird.3gp');
%get size of one frame
frame_size=size(read(v,1));
%get the size of frame after converting it from decimal to binary 
binary_frame_size=size(de2bi(rgb2gray(read(v, 1))));
%declaring vector to concatenate all frame together
N_array=binary_frame_size(1)*binary_frame_size(2);
N_total=v.NumberOfFrames*N_array;
binary_frame_shaped=zeros(1,N_total);
binary_received_frame=zeros(v.NumberOfFrames,N_array);
figure
for i = 1 : v.NumberOfFrames  %fill in the appropriate number
    this_frame = read(v, i);
    image(this_frame)
    this_frame_gray=rgb2gray(this_frame);
    binary_frame=de2bi(this_frame_gray);
    binary_frame_shaped((i*N_array)-(N_array-1):i*N_array)=reshape(binary_frame,1,N_array);
    pause(1/30)
end
Tx_data=zeros(1,length(binary_frame_shaped)/3);
for j=1:3:length(binary_frame_shaped)
    n_ones=find(binary_frame_shaped(j:j+2));
    if length(n_ones) >=2
        Tx_data((j+2)/3)=1;
    else
        Tx_data((j+2)/3)=0;
    end
end

k=2^ceil(log2(length(Tx_data)));
Tx_zp=[Tx_data zeros(1,k-length(Tx_data))];
[audio,fs]=audioread('Dubstep Bird.3gp');

%%
N=length(Tx_zp);%number of bits
numberOfSamplesPerBit = 4;
bitRate               = 2*10^6;
sampleRate = bitRate * numberOfSamplesPerBit;
tx_power           = 0; % in dBm
number_of_frames=1;
frame=1;

%%
%---------------------initialization-------------

    % Converting to samples
    transmittedSamples = transpose(rectpulse( Tx_zp.', numberOfSamplesPerBit ));
    % adding the time base vector where sample to sample differnce is the
    % sample time
    transmitterTimeVector = transpose( ( 0 : length( transmittedSamples ) - 1 ) / sampleRate );
    %Saving the samples in a specified folder to be transmitted to
    %optisystem- so plz change the path to your folder path
    concatenatedTime_TransmittedSamples = [ transmitterTimeVector transmittedSamples(1,:).' ];
    save 'C:\Users\hp\Desktop\transmittedSamples1.dat' concatenatedTime_TransmittedSamples -ascii
    
    %--------------------------------------------------------------------------
    % Starting the OptiSystem Software
    %--------------------------------------------------------------------------
    
    % create a COM server running OptiSystem
    optsys = actxserver('optisystem.application');
    
    % This pause is necessary to allow OptiSystem to be opened before
    % call open the project
    pause(10);
    
    % Open the OptiSystem file defined by the path
    optsys.Open('C:\Users\hp\Desktop\multimodesignal.osd');
    % Specify and define the parameters that will be varied in the project
    %---------------------------------------------------------------------
    
    
    Document        = optsys.GetActiveDocument;
    LayoutMngr      = Document.GetLayoutMgr;
    CurrentLyt      = LayoutMngr.GetCurrentLayout;
    Canvas          = CurrentLyt.GetCurrentCanvas;
    
    %% setting bitrate, samples perbit, and frame length
    CurrentLyt.SetParameterValue( 'Bit rate', bitRate)
    CurrentLyt.SetParameterValue( 'Sequence length',N)
    CurrentLyt.SetParameterValue( 'Samples per bit', numberOfSamplesPerBit)
    
    
    %%
    %---------------------setting component parameters
    %% Setting pulse generators to generate the data files you already saved before
    pulseGenerator = Canvas.GetComponentByName('Measured Pulse Sequence');
    pulseGenerator.SetParameterValue( 'Filename', 'C:\Users\hp\Desktop\transmittedSamples1.dat' );
   
    
    %% setting power of laser to the power you want as an example
    CWlaser        = Canvas.GetComponentByName('Spatial CW Laser');
    CWlaser.SetParameterValue( 'Power', tx_power );
%     
      
 
    %%
    %% Run the project
    %-----------------
    
    Document.CalculateProject( true , true);
    %% return to matlab
    %% loading the signal saved by the matlab component in the optisystem,
    %% so you must change the path of matlab component in optisystem.
    %% note that the signal is a strucure that contains signal, noise, time
    %% vector so you must choose signal as follows:
    load signal
    received_signal(frame,:)=InputPort1.Sequence;
    
    
    %% closing optisystem
%     optsys.Quit;
%     pause(10)
%     
    
    [ne, BER] = biterr(Tx_zp,received_signal);


% Now you are required to calculate BER at the optimum sampling time 

%%
figure
receive_data=received_signal;
Rx_data=receive_data(1:N_total/3);
data_recovery=zeros(1,length(binary_frame_shaped));

for k=1:length(Rx_data)
    if Rx_data(k)==1
        data_recovery(k*3-2:k*3)=ones(1,3);
    else
        data_recovery(k*3-2:k*3)=zeros(1,3);
    end
end
    
for i= 1 : v.NumberOfFrames
    binary_received_frame=data_recovery((i*N_array)-(N_array-1):i*N_array);
    shaped_received_data=reshape(binary_received_frame,binary_frame_size(1),binary_frame_size(2));    
    decimal_frame=bi2de(shaped_received_data); 
    decimal_frame=decimal_frame';
    final_frame=reshape(decimal_frame,frame_size(1),frame_size(2));
    final_frame=uint8(final_frame);
    imshow(final_frame)
    pause(1/30)
    
end