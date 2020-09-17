%% Load data 

datapath0 = '/snel/share/share/data/NW_Emory_Data_Sharing/Jango/Jango_WF_Isobox_2016/xds/Jango_20160626_001.mat';
datapathk = '/snel/share/share/data/NW_Emory_Data_Sharing/Jango/Jango_WF_Isobox_2016/xds/Jango_20160627_001.mat';

day0_data = load(datapath0);
dayk_data = load(datapathk);

day0_spikes = {day0_data.xds.spike_counts'}; % N x T
dayk_spikes = {dayk_data.xds.spike_counts'}; % N x T

%% Add required paths 
startDir = pwd;
cd('/snel/home/brianna/bin/stabilizedbci/code/'); 
addStabilizationProjectPaths();
cd(startDir); 

%% Fit baseline stabilizer 

nLatents = 10; % Number of latents to use for stabilizaton; see methods and
               % supplemental figure 7 of the paper for a discusson on 
               % choosing this value

baselineStabilizer = fitBaseStabilizer(day0_spikes, nLatents);

%% Update Stabilizer 

updatedStabilizer = updateStabilizer(baselineStabilizer, dayk_spikes, ...
                                     'ALIGN_N', 60, 'ALIGN_TH', .01); 

%% Get stabilizer matrices

[baselineBeta, baselineO] = getStabilizatonMatrices(baselineStabilizer);
[updatedBeta, updatedO] = getStabilizatonMatrices(updatedStabilizer); 

%% Get latent state 

% Now we extract latent state in all 3 ways 
nEvalTrials = 1;
baselineInstabilitiesLatentState = cell(1, nEvalTrials); 
updatedInstabilitiesLatentState = cell(1, nEvalTrials); 
baselineOriginalLatentState = cell(1, nEvalTrials); 
for tI = 1:nEvalTrials
    baselineInstabilitiesLatentState{tI} = bsxfun(@plus, baselineBeta*dayk_spikes{tI}, baselineO);
    updatedInstabilitiesLatentState{tI} = bsxfun(@plus, updatedBeta*dayk_spikes{tI}, updatedO);
    baselineOriginalLatentState{tI} = bsxfun(@plus, baselineBeta*day0_spikes{tI}, baselineO);
end

%% Plot 

exTrial = 1;
figure();
for lI = 1:nLatents
    subplot(ceil(nLatents/2)+1, 2, lI); 
    plot(baselineOriginalLatentState{exTrial}(lI, 1:50), 'ko-'); 
    hold on;
    plot(updatedInstabilitiesLatentState{exTrial}(lI, 1:50), 'b.-'); 
    plot(baselineInstabilitiesLatentState{exTrial}(lI, 1:50), 'r--');
    ylabel(['Latent ', num2str(lI), ' (a.u.)']); 
    if lI == nLatents
        xlabel('Bin Number')
        leg = legend('Baseline stabilizer with original data', 'Updated stabilizer with instabiliites', 'Baseline stabilizer with instabilities');
        set(leg, 'Position', [.65, .05, .2, .1], 'FontSize', 15); 
    end
    set(gcf, 'Position', [0 0, 1000, 800]); 
end


