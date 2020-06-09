dirPrefix                                                 = '/home/duanbin/bb/data/';
sampleNamePrefix                                          = 'DUP_Color Channel Aligned/Y1648_X1059_Z0/';
matNamePrefix                                             = 'DUP_Color Channel Aligned-Y1648_X1059_Z0';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SUPERVOXEL GENERATION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
superVoxelOpts.dataset                                                   = [dirPrefix 'denoised/' sampleNamePrefix '[DENOISED]' matNamePrefix '.mat'];
superVoxelOpts.brightnessThreshold                                       = 0.1;
superVoxelOpts.spatialDistanceCalculationOpts.upperBound                 = 2;
superVoxelOpts.splitInconsistentSVopts.maxPerimeter                      = 0.5;
superVoxelOpts.splitInconsistentSVopts.connectivity                      = 26;
superVoxelOpts.splitInconsistentSVopts.subdivisionSizeThreshold          = 10;
superVoxelOpts.HMINTH26                                                  = 0.006;
superVoxelOpts.filePreamble                                              = [dirPrefix 'supervoxel/' sampleNamePrefix matNamePrefix '_ws0.006_isplit0.5_20_augmented0.1'];

supervoxelize(superVoxelOpts);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% CONSERVATIVE MERGING OF SUPERVOXELS %%%%%%%%%%%%%%%%%%%%%%%%%
mergeOpts.loadFilename                                                   = [dirPrefix 'supervoxel/' sampleNamePrefix matNamePrefix '_ws0.006_isplit0.5_20_augmented0.1_aff.mat']; % PVhippo1_bm4d_sigma500_ws0.006_isplit0.5_20_augmented0.1_aff.mat';
mergeOpts.saveFileName                                                   = [dirPrefix 'merged/' sampleNamePrefix matNamePrefix '_ws0.006_isplit0.5_20_augmented0.1_minmax_demixFirst50_5_smallLast_maxCdist10'];
mergeOpts.zAnisotropy                                                    = 3;
mergeOpts.demix.maxSimilarNeighborNormLUVDist                            = 50; % * sqrt(size(svMeans, 2)/4);
mergeOpts.demix.minImprovementFactor                                     = 10;
mergeOpts.demix.maxSizeForDemixing                                       = 500;
mergeOpts.mergeSmallSuperVoxels.luvColorDistanceUpperBound               = 20;
mergeOpts.mergeSmallSuperVoxels.disconnectedSVsizeTh                     = 20;
mergeOpts.mergeSmallSuperVoxels.maxVoxColorDist                          = 0.5;
mergeOpts.mergeWRTnAo.sDist                                              = sqrt(3);
mergeOpts.mergeWRTnAo.minDotProduct                                      = 0.9659; % pi/12 % sqrt(3)/2;
mergeOpts.mergeWRTnAo.maxColorDist                                       = 10; % * sqrt(size(svMeans, 2)/4);
mergeOpts.mergeWRTnAo.normFlag                                           = true;
mergeOpts.mergeWRTnAo.maxVoxColorDist                                    = 0.5;
mergeOpts.mergeSingleNeighborSuperVoxels.maxVoxColorDist                 = 0.5;
mergeOpts.mergeCloseNeighborhoods.maxDistNormLUV                         = 10; % * sqrt(size(svMeans, 2)/4);
mergeOpts.mergeCloseNeighborhoods.maxVoxColorDist                        = 0.5;
mergeSupervoxels(mergeOpts);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SEGMENTATION OF MERGED SUPERVOXELS %%%%%%%%%%%%%%%%%%%%%%%%%
mergedSvFileName                    = [dirPrefix 'merged/' sampleNamePrefix matNamePrefix '_ws0.006_isplit0.5_20_augmented0.1_minmax_demixFirst50_5_smallLast_maxCdist10_sAff10.mat'];
graphData.c                         = 2e-3;
graphData.colorRadiusForPure        = 20;
graphData.minSizeForPure            = 50;
graphData.maxPerim                  = 0.4;
graphData.spatialNhoodRadius        = sqrt(9)+eps;
graphData.maxColorRadiusForProximal = 50;
graphData.minEdgeCountForProximal   = 5;
graphData.opts_irbleigs.K           = 3;
graphData.GMM.K                     = 4;
graphData.sampleNamePrefix          = ['~/bb/results/' sampleNamePrefix 'GMM/' matNamePrefix];
[index, graphData]                  = segmentImageGMM(mergedSvFileName, graphData);
writeTracingScript(mergedSvFileName, index, graphData);

% [index, graphData]                  = segmentImageGMM(mergedSvFileName, graphData);
% writeProjectedSegmentationScript(mergedSvFileName, index, graphData);
% writeTracingScript(mergedSvFileName, index, graphData);
delete(gcp('nocreate'));
