%% This m-file shows how to generate data in MATLAB , pass it through optisystem and configure simulation parameters 
%-----------------------------------------------
clc
close all
clear all
%-----------------------------------------------

%% transmition

%read video file
v = VideoReader('Dubstep Bird Original 4 Sec Video.3gp');
%get size of one frame
x=read(v,1);
frame_size=size(imresize(x,0.25));
%get the size of frame after converting it from decimal to binary 
binary_frame_size=size(de2bi(rgb2gray(read(v, 1))));
%declaring vector to concatenate all frame together
N_arr=frame_size(1)*frame_size(2);
N_array=binary_frame_size(1)*binary_frame_size(2)/16;
N_total=v.NumberOfFrames*N_array;
R_binary=zeros(1,N_total);
G_binary=zeros(1,N_total);
B_binary=zeros(1,N_total);
binary_received_frame=zeros(v.NumberOfFrames,N_array);



for i = 1 : v.NumberOfFrames  %fill in the appropriate number
    this_frame = read(v, i);
    this_frame=imresize(this_frame,0.25);
    [R_binary((i*N_array)-(N_array-1):i*N_array), G_binary((i*N_array)-(N_array-1):i*N_array), B_binary((i*N_array)-(N_array-1):i*N_array)] = RGB_to_Binary(this_frame);
  
end

RGB_binary=[R_binary G_binary B_binary];
Tx_data=RGB_binary;

k=2^ceil(log2(length(Tx_data)));
Tx_zp=[Tx_data zeros(1,k-length(Tx_data))];
% 
% [audio,fs]=audioread('Dubstep Bird.3gp');

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
    save 'E:\transmittedSamples1.dat' concatenatedTime_TransmittedSamples -ascii
    
    %--------------------------------------------------------------------------
    % Starting the OptiSystem Software
    %--------------------------------------------------------------------------
    
    % create a COM server running OptiSystem
    optsys = actxserver('optisystem.application');
    
    % This pause is necessary to allow OptiSystem to be opened before
    % call open the project
    pause(10);
    
    % Open the OptiSystem file defined by the path
    optsys.Open('E:\MATLAB_optisystem_cosimulation.osd');
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
    pulseGenerator.SetParameterValue( 'Filename', 'E:\transmittedSamples1.dat' );
   
    
    %% setting power of laser to the power you want as an example
    CWlaser        = Canvas.GetComponentByName('CW Laser');
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
    
%     [ne, BER] = biterr(Tx_zp,received_signal);


% Now you are required to calculate BER at the optimum sampling time 

%%
figure
Rx_data=received_signal(1:length(Tx_data));
% received_rgb(:,:,s)=Rx_data;

R_binaryr=Rx_data(1:length(R_binary));
G_binaryr=Rx_data(length(R_binary)+1:2*length(R_binary));
B_binaryr=Rx_data(2*length(R_binary)+1:3*length(R_binary));

for i= 1 : v.NumberOfFrames
      R_binary_frame=R_binaryr((i*N_array)-(N_array-1):i*N_array);
      G_binary_frame=G_binaryr((i*N_array)-(N_array-1):i*N_array);
      B_binary_frame=B_binaryr((i*N_array)-(N_array-1):i*N_array);
      B = Binary_to_RGB( R_binary_frame,G_binary_frame,B_binary_frame, frame_size(1),frame_size(2));
      imshow(imresize(B,8))
      pause(1/30)     
end

