clear all;
clc;
close all;

skel_dir									 = '/home/duanbin/bb/results/DUP_Color Channel Aligned/Y1648_X1059_Z0/GMM/DUP_Color Channel Aligned-Y1648_X1059_Z0_0.002_20_503_50_5_3_tracing_';

result_dir                                   = '/home/duanbin/bb/results/DUP_Color Channel Aligned/Y1648_X1059_Z0/GMM/SWC/';

ids = 1;
TH = 4;

for k=1:length(ids)
  kk = ids(k);
  tic;disp(strcat(num2str(kk), '-th segmentation starts linking'));
  name = strcat(skel_dir, num2str(kk), '.mat');
  name_neurite = strcat(result_dir, 'DUP_', num2str(kk), '_');
  skel = linkRepairV2(name, TH);
  sepatateNeurite(name_neurite, skel);
  toc;
end



function sepatateNeurite(name, skel, seed_points_list, n)
    n = 50;

	CC = bwconncomp(skel);

	numVoxels = cellfun(@numel,CC.PixelIdxList);
    
    
	[voxelNumbers,idxes] = maxk(numVoxels, min(length(numVoxels), n));
    
    % filter out small ones than 50
    idxes(voxelNumbers<40)=[];
	% swc file
	for i=1:length(idxes)
	    tmp = false(size(skel));
	    tmp(CC.PixelIdxList{idxes(i)}) = true;
	    % add one more column
	    neurite = build_graph_structure(tmp);
        if ~isempty(neurite)
            save_to_swc_file(neurite, strcat(name, 'neurite_', num2str(i), '.swc'));
        end
	end

end