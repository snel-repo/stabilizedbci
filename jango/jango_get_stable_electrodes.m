%% Load data 

addpath('/snel/home/brianna/bin/stabilizedbci/code/stabilization/');

datapath = '/snel/share/share/data/NW_Emory_Data_Sharing/Jango/Jango_WF_Isobox_2016/xds/Jango_20160626_001.mat';
data = load(datapath);

%% Extract data relevant for computing stable electrodes

spikes = data.xds.spike_counts;
duration = data.xds.meta.duration;
[num_samples, num_channels] = size(spikes);

% may want to eventually rebin to 20ms as we usually do 
fs = num_samples/duration;

%% Identify stable electrodes 

ALIGN_N = []; %from the methods section of the paper
ALIGN_TH = .01;

M1 = spikes(1:num_samples/2, :)';
M2 = spikes(num_samples/2+1:end, :)';
% what happens if we abolish the signal in a few channels? 
M2(1:5, :) = zeros(5, num_samples/2);

alignRows = identifyStableLoadingRows(M1, M2, ALIGN_N, ALIGN_TH);

