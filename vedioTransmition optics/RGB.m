    v = VideoReader('Dubstep Bird Original 4 Sec Video.3gp');
    [Rx_audio,fs]=audioread('Dubstep Bird Original 4 Sec Video.3gp');
    %get size of one frame
    x=read(v,1);
    frame_size=size(x);
    %get the size of frame after converting it from decimal to binary 
    binary_frame_size=size(de2bi(rgb2gray(read(v, 1))));
    %declaring vector to concatenate all frame together
    N_array=binary_frame_size(1)*binary_frame_size(2);
    N_total=v.NumberOfFrames*N_array;


    load signalR
    R_binaryr1=InputPort1.Sequence;
    R_binaryr1=R_binaryr1(1:N_total);
    
    
    load signalG
    G_binaryr1=InputPort1.Sequence;
    G_binaryr1=G_binaryr1(1:N_total);
    
    
    load signalB
    B_binaryr1=InputPort1.Sequence;
    B_binaryr1=B_binaryr1(1:N_total);
    
    
writerObj = vision.VideoFileWriter('out.avi','AudioInputPort',true);

nFrames   = 35;

% assign FrameRate (by default it is 30)

writerObj.FrameRate =  9.9900;

% length of the audio to be put per frame

    
 for i= 1 : v.NumberOfFrames
      R_binary_frame=R_binaryr1((i*N_array)-(N_array-1):i*N_array);
      G_binary_frame=G_binaryr1((i*N_array)-(N_array-1):i*N_array);
      B_binary_frame=B_binaryr1((i*N_array)-(N_array-1):i*N_array);
      
      R_de=(bi2de(reshape(R_binary_frame,25344,8)))';
      G_de=(bi2de(reshape(G_binary_frame,25344,8)))';
      B_de=(bi2de(reshape(B_binary_frame,25344,8)))';
      
      R_f=reshape(R_de,144,176);
      G_f=reshape(G_de,144,176);
      B_f=reshape(B_de,144,176);
      
      B(:,:,1)=uint8(R_f);
      B(:,:,3)=uint8(G_f);
      B(:,:,2)=uint8(B_f);
      imshow(B)
      pause(1/30)     
      
          val = size(Rx_audio,1)/nFrames;
    Frame=B;
    % adding the audio variable in the step function
    step(writerObj,Frame,Rx_audio(val*(i-1)+1:val*i,:));
 end

 release(writerObj)
