%% This m-file shows how to generate data in MATLAB , pass it through optisystem and configure simulation parameters 
%-----------------------------------------------
clc
close all
clear all
%-----------------------------------------------
%%
% N=256;%number of bits
% numberOfSamplesPerBit = 4;
% bitRate               = 10E9;
% sampleRate = bitRate * numberOfSamplesPerBit;
% tx_power           = 0; % in dBm
% number_of_frames=1;
%%
%---------------------initialization-------------
% for frame=1:number_of_frames
    A = imread('image.jpg');
A_resized = imresize(A,0.35);
[R_binary, G_binary, B_binary] = RGB_to_Binary(A_resized);
data=[R_binary G_binary B_binary];

k=2^ceil(log2(length(data)));
Tx_zp=[data zeros(1,k-length(data))];

%% 
N=length(Tx_zp);%number of bits
numberOfSamplesPerBit = 4;
bitRate               = 2*10^6;
sampleRate = bitRate * numberOfSamplesPerBit;
tx_power           = 0; % in dBm
number_of_frames=1;
frame=1;

%% 

%     data(1,:)=randint(1,N);%generating bits
    
    % Converting to samples
    transmittedSamples = reshape(repmat(Tx_zp,numberOfSamplesPerBit,1),1,[]);
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
    optsys.Open('C:\Users\hp\Desktop\signal.osd');
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
    load output
    received_signal(frame,:)=InputPort1.Sequence;
    [ne, BER] = biterr(Tx_zp,received_signal);
    Rx=received_signal(1:length(data));
    
    R_recieved=Rx(1:length(Rx)/3);
    G_recieved=Rx(1+length(Rx)/3:length(Rx)*2/3);
    B_recieved=Rx(1+length(Rx)*2/3:end);
   B = Binary_to_RGB( R_recieved, G_recieved, B_recieved, size(A_resized,1), size(A_resized,2) );
   figure(2)
imshow(B)

    %% closing optisystem
%     optsys.Quit;
    pause(10)
    
    
    
% end

% Now you are required to calculate BER at the optimum sampling time 

