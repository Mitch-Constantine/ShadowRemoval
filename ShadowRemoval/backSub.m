function [backSubRawMap, bs] = backSub(im,bs)
%function [backSubRawMap, backSubParams] = backSub(im,backSubParams)
% Modified by SJDP based on original code by MVS 18/08/2004
% im is RGB Uint8 image read from file
% backSubParams should be left empty or ommitted on first call 
% should be fed back in after each call

%DEFAULT PARAMETERS - most can be changed after first iteration if required

% N_PROCESS = 2;                          % number of processes used (usually 2 - one for foreground and one for background)
% LEARNING_RATE_WEIGHTS = 0.000009259;    % learning rate for weight parameters (slow ~1 hr) 
% LEARNING_RATE_FOREGROUND = 0.000009259; % learning rate for mean and variance of foreground process (slow ~1 hr)
% LEARNING_RATE_BACKGROUND = 0.003975;     % learning rate for background parameter (fast ~ 100 seconds);
% INITIAL_WEIGHT_FOREGROUND = 0.4;        % initial weight for foreground process
% INITIAL_WEIGHT_BACKGROUND = 0.6;        % initial weight for background process
% INITIAL_MEAN_FOREGROUND = 128;          % initial mean for background process 
% INITIAL_VAR_BACKGROUND = 50;            % initial variance for background (quite narrow)
% INITIAL_VAR_FOREGROUND = 1000;          % initial variance for foreground (wide)
% MINIMUM_VAR_FOREGROUND = 25;                       % processes cannot have a variance less than this value
% MINIMUM_VAR_BACKGROUND = 60*60;
% MAXIMUM_BACKGROUND_WEIGHT=0.9;          % background weight cannot have a value of greater than this
% MIN_LIKELIHOOD = 0.00001;               % minimum probability value that likelihood can assume (to stop posteriors of infinity!)
% DO_PCA = 1;


N_PROCESS = 2;                          % number of processes used (usually 2 - one for foreground and one for background)

% LEARNING_RATE_WEIGHTS     = 0.000009259;    % learning rate for weight parameters (slow ~1 hr) 
% LEARNING_RATE_FOREGROUND  = 0.000009259; % learning rate for mean and variance of foreground process (slow ~1 hr)
% LEARNING_RATE_BACKGROUND  = 0.003975;     % learning rate for background parameter (fast ~ 100 seconds);

% %Settings for TrendCam Bob1 image seq. Apr/29/2011
% LEARNING_RATE_WEIGHTS     = 0.000009259;    % learning rate for weight parameters (slow ~1 hr) 
% LEARNING_RATE_FOREGROUND  = 0.00001; % learning rate for mean and variance of foreground process (slow ~1 hr)
% LEARNING_RATE_BACKGROUND  = 0.1;     % learning rate for background parameter (fast ~ 100 seconds);


%Settings for AXIS camera image seq. May/11/2011
LEARNING_RATE_WEIGHTS     = 0.000009259;    % learning rate for weight parameters (slow ~1 hr) 
LEARNING_RATE_FOREGROUND  = 0.00001; % learning rate for mean and variance of foreground process (slow ~1 hr)
LEARNING_RATE_BACKGROUND  = 0.1;     % learning rate for background parameter (fast ~ 100 seconds);



INITIAL_WEIGHT_FOREGROUND = 0.4;  %0.4;        % initial weight for foreground process
INITIAL_WEIGHT_BACKGROUND = 0.6;  %0.6;        % initial weight for background process
INITIAL_MEAN_FOREGROUND = 128;          % initial mean for background process 
INITIAL_VAR_BACKGROUND = 50;            % initial variance for background (quite narrow)
INITIAL_VAR_FOREGROUND = 1000;          % initial variance for foreground (wide)
MINIMUM_VAR_FOREGROUND = 25;                       % processes cannot have a variance less than this value
MINIMUM_VAR_BACKGROUND = 60*60;
MAXIMUM_BACKGROUND_WEIGHT=0.9;          % background weight cannot have a value of greater than this
MIN_LIKELIHOOD = 0.00001;               % minimum probability value that likelihood can assume (to stop posteriors of infinity!)
DO_PCA = 1;




%convert image to floating points
im=double(im);
 
if (DO_PCA)
    INITIAL_MEAN_FOREGROUND = 0;          % initial mean for background process 
    INITIAL_VAR_BACKGROUND = 50;            % initial variance for background (quite narrow)
    INITIAL_VAR_FOREGROUND = 30*30;         % initial variance for foreground (wide)
    MINIMUM_VAR_BACKGROUND = 20*20;         % processes cannot have a variance less than this value
    MINIMUM_VAR_FOREGROUND = 3*3;         % processes cannot have a variance less than this value
    
    %convert image to floating points and rotate to eigenspace
    V = [0.67488 0.4314; 0.21766 -0.89164;-0.70548 0.13736];

    comp1 = V(1,1)*im(:,:,1)+V(2,1)*im(:,:,2)+V(3,1)*im(:,:,3);
    comp2 = V(1,2)*im(:,:,1)+V(2,2)*im(:,:,2)+V(3,2)*im(:,:,3);
    im = cat(3,comp1,comp2);
end


%IF THIS IS FIRST RUN THROUGH THEN INITIALIZE VARIABLES
if (~exist('bs')|isempty(bs))
    %set evidence to empty array
    bs.evidence = []; 
    %extract image size
    [bs.imY bs.imX bs.imZ] = size(im);
    %store number of processes
    bs.nProcess = N_PROCESS;
    %learning rates
    bs.learningRateWeights = LEARNING_RATE_WEIGHTS;
    bs.learningRateForeground = LEARNING_RATE_FOREGROUND;
    bs.learningRateBackground = LEARNING_RATE_BACKGROUND;

    %INITIALIZE VALUES OF ARRAYS
    %initialize all weights
    bs.processWeight{1} = INITIAL_WEIGHT_BACKGROUND*ones(bs.imY,bs.imX);
    bs.processWeight{2} = INITIAL_WEIGHT_FOREGROUND*ones(bs.imY,bs.imX);
    %initialize means
    bs.processMean{1} = im;                                            %background process set to first image
    bs.processMean{2} = INITIAL_MEAN_FOREGROUND*ones(bs.imY,bs.imX,bs.imZ);
    %initialize variances
    bs.processVar{1} = INITIAL_VAR_BACKGROUND *ones(bs.imY,bs.imX,bs.imZ);
    bs.processVar{2} = INITIAL_VAR_FOREGROUND *ones(bs.imY,bs.imX,bs.imZ);
    %for each process
    for (cProcess = 1:bs.nProcess)
        % current likelihood for each process
        bs.likelihood{cProcess} = -0.5*sum(  ( ( im - bs.processMean{cProcess} ).^2 )./(bs.processVar{cProcess}) , 3  );
        bs.likelihood{cProcess} = ( bs.processWeight{cProcess} ./ ((2*pi)^1.5*prod(sqrt(bs.processVar{cProcess}),3)) ) .* exp(bs.likelihood{cProcess});
        %initialize auxilliary variables - described in Friedman and Russel - but roughly N is amount of data in weighted mean
        %                                                                                 S is expected first moment
        %                                                                                 Z is expected second moment
        bs.N{cProcess} = bs.processWeight{cProcess};
        bs.S{cProcess} = bs.processMean{cProcess};
        bs.Z{cProcess} = bs.processVar{cProcess}+bs.processMean{cProcess}.*bs.processMean{cProcess};
    end;
 
    %set number of processed frames to 1
    bs.nFrame = 1;
    
    
    %return 
    backSubRawMap = zeros(bs.imY,bs.imX);
    
    return;
else
    %THIS IS NOT THE FIRST FRAME SO PARAMETERS ALREADY INITIALIZED - UPDATE PARAMETERS AND RETURN MAP
    
    %run through each process updating probability ;
    for (cProcess = 1:bs.nProcess)
        bs.likelihood{cProcess} = -0.5*sum(((im - bs.processMean{cProcess}).^2)./(bs.processVar{cProcess}), 3);
        bs.likelihood{cProcess} = (bs.processWeight{cProcess} ./ ((2*pi)^1.5*prod(sqrt(bs.processVar{cProcess}),3))) .* exp(bs.likelihood{cProcess});
    end;
    % locate all extreme cases to avoid division by 0 and NaN
    problemIndex = find(bs.likelihood{1} == 0 & bs.likelihood{2} == 0);
    bs.likelihood{1}(problemIndex) = MIN_LIKELIHOOD; bs.likelihood{2}(problemIndex) = MIN_LIKELIHOOD;
    % calculate the evidence for this
    bs.evidence = [bs.evidence sum(sum(bs.likelihood{1}+bs.likelihood{2}))];
        
    %UPDATE THE PARAMETERS
    
    %modify the learning rates to account for the fact that the series is currently finite
    learningRateForegroundModified = bs.learningRateForeground;%bs.learningRateForeground/(1-(1-bs.learningRateForeground).^bs.nFrame);
    learningRateBackgroundModified = bs.learningRateBackground;%bs.learningRateBackground/(1-(1-bs.learningRateBackground).^bs.nFrame);
    learningRateWeightsModified = bs.learningRateWeights;%bs.learningRateWeights/(1-(1-bs.learningRateWeights).^bs.nFrame);
    
    % create learning rate masks for foreground and background in exponential case
    learningRateMask{1} = learningRateBackgroundModified*(bs.processWeight{1} > bs.processWeight{2}) + learningRateForegroundModified*(bs.processWeight{1} <= bs.processWeight{2});
    learningRateMask{2} = learningRateBackgroundModified*(bs.processWeight{2} > bs.processWeight{1}) + learningRateForegroundModified*(bs.processWeight{2} <= bs.processWeight{1});
   
    %total "number" of values to be incorporated
    totalN = zeros(size(bs.N{1}));

    %for each process - update auxilliary parameters
    for (cProcess = 1:bs.nProcess)
        %calculate posterior probability for each process
        probPost{cProcess} = bs.likelihood{cProcess}./(bs.likelihood{1}+bs.likelihood{2});
        %if in initial "box-car filter" stage
        %update auxilliary parameters using exponential weighting
        bs.N{cProcess} = (1-learningRateWeightsModified*probPost{cProcess}).*bs.N{cProcess} +learningRateWeightsModified*probPost{cProcess};        
        %update other auxilliary parameters      
        bs.S{cProcess} = repmat(1-learningRateMask{cProcess}.*probPost{cProcess}, [1,1,bs.imZ]).*bs.S{cProcess} + repmat(learningRateMask{cProcess}.*probPost{cProcess},[1,1,bs.imZ]).*im;
        bs.Z{cProcess} = repmat(1-learningRateMask{cProcess}.*probPost{cProcess}, [1,1,bs.imZ]).*bs.Z{cProcess} + repmat(learningRateMask{cProcess}.*probPost{cProcess},[1,1,bs.imZ]).*im.*im;
        totalN = totalN + bs.N{cProcess};            
    end;
        
    %calculate posterior map to return to user
    backSubRawMap  = probPost{1}.*(bs.processWeight{2} > bs.processWeight{1})+probPost{2}.*(bs.processWeight{2} <= bs.processWeight{1});
    backSubRawMap = max(backSubRawMap,0.000000001);
    
    %for each process update weights, means and SD's
    for (cProcess = 1:bs.nProcess)
        %update weights means, sd's
        bs.processWeight{cProcess} = bs.N{cProcess}./totalN;
        bs.processMean{cProcess} = bs.S{cProcess}; 
        bs.processVar{cProcess}   = bs.Z{cProcess} - bs.processMean{cProcess}.^2; 
           
        %enforce minimal variance
         mask = repmat(bs.processWeight{1}>bs.processWeight{2},[1 1 bs.imZ]);
       
        problemIndex = find(mask&(bs.processVar{cProcess} < MINIMUM_VAR_BACKGROUND));
        bs.processVar{cProcess}(problemIndex) = MINIMUM_VAR_BACKGROUND;      
        problemIndex = find((1-mask)&(bs.processVar{cProcess} < MINIMUM_VAR_FOREGROUND));
        bs.processVar{cProcess}(problemIndex) = MINIMUM_VAR_FOREGROUND;
        
        
        %force weights to sit in a 
        bs.processWeight{cProcess} = max(bs.processWeight{cProcess},1-MAXIMUM_BACKGROUND_WEIGHT);
        bs.processWeight{cProcess} = min(bs.processWeight{cProcess},MAXIMUM_BACKGROUND_WEIGHT);
    end
    
    bs.nFrame = bs.nFrame+1;
end