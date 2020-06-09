function writeSegmentationWithTracingScript(mergedSvFileName, index, graphData)
load(mergedSvFileName);
load(superVoxelOpts.dataset);
clusterCount                                 = max(index);
segmentation = zeros(stackSize); for kka=1:clusterCount; thisCluster = find(index==kka); for kkb=1:numel(thisCluster); segmentation(svCells{thisCluster(kkb)}) = kka; end; end;
voxelCount                                   = numel(segmentation);
xTileCount                                   = round((clusterCount+1)/3);
yTileCount                                   = ceil((clusterCount+1)/xTileCount);
compx                                        = size(segmentation,1)+size(segmentation,3);
compy                                        = size(segmentation,2)+size(segmentation,3);
bigSegmentation                              = ones( (size(segmentation,1)+1)*xTileCount-1, (size(segmentation,2)+1)*yTileCount-1, size(bbVol,3), size(bbVol,4));
bigTracing                                   = false( (size(segmentation,1)+1)*xTileCount-1, (size(segmentation,2)+1)*yTileCount-1, size(bbVol,3));
xTile                                        = 1;
yTile                                        = 1;
bigSegmentation(1:size(segmentation,1), 1:size(segmentation,2), :,:) = bbVol;
bigTracing(1:size(segmentation,1), 1:size(segmentation,2), :,:) = squeeze(max(bbVol, [], 4));

for kk=1:clusterCount
  [xTile, yTile]                             = ind2sub([xTileCount yTileCount], kk+1);
  tmp2                                       = find(segmentation==kk);
  tmp3                                    	 = false(size(segmentation));
  tmp3(tmp2) = true;
  skel = Skeleton3D(tmp3);
  bigTracing((xTile-1)*(size(segmentation,1)+1)+1:xTile*(size(segmentation,1)+1)-1, (yTile-1)*(size(segmentation,2)+1)+1:yTile*(size(segmentation,2)+1)-1, :) = skel;
  for mm = 1:size(bbVol, 4)
    tmp1                                     = zeros(size(segmentation));
    tmp1(tmp2)                               = bbVol(tmp2+(mm-1)*voxelCount);
    if mm == 1
        tmp4 = tmp1;
    else
        tmp4 = cat(4, tmp4, tmp1);
    end
  end
  bigSegmentation((xTile-1)*(size(segmentation,1)+1)+1:xTile*(size(segmentation,1)+1)-1, (yTile-1)*(size(segmentation,2)+1)+1:yTile*(size(segmentation,2)+1)-1, :, :) = tmp4;
end
writeFileName = [graphData.sampleNamePrefix '_' num2str(graphData.c) '_' num2str(graphData.colorRadiusForPure) '_' num2str(graphData.minSizeForPure)];
writeFileName = [writeFileName num2str(graphData.spatialNhoodRadius) '_' num2str(graphData.maxColorRadiusForProximal) '_'];
writeFileName = [writeFileName num2str(graphData.minEdgeCountForProximal) '_' num2str(graphData.opts_irbleigs.K)];

writeFileName = [writeFileName '_results.mat'];
% 
save(writeFileName, 'bigTracing', 'bigSegmentation', '-v7.3');
% 16-bit Tiff segmentation

% clear data;
% data = uint16(bigSegmentation);
% 
% outputFileName = [writeFileName '_segmentation.tif'];
% % This is a direct interface to libtiff
% 
% addpath '/home/duanbin/Downloads/Fiji.app/scripts'
% ImageJ
% 
% imp = copytoImagePlus(data,'XYZC');
% 
% ij.IJ.saveAsTiff(imp, outputFileName);
% 
% clear data;
% clear imp;
% 
% data = logical(bigTracing);
% 
% outputFileName = [writeFileName '_tracing.tif'];
% 
% imp = copytoImagePlus(data,'XYZ');
% 
% ij.IJ.saveAsTiff(imp, outputFileName);

% dim = size(bigSegmentation);
% 
% clear data;
% data = uint16(bigSegmentation);
% 
% outputFileName = [writeFileName '_segmentation.tif'];
% % This is a direct interface to libtiff
% for j=1:dim(3)
%     for jj=1:dim(4)
%         if j==1 && jj==1
%             t = Tiff(outputFileName,'w');
%             tagstruct.ImageLength     = size(data,1);
%             tagstruct.ImageWidth      = size(data,2);
%             tagstruct.Photometric     = Tiff.Photometric.MinIsBlack;
%             tagstruct.BitsPerSample   = 16;
%             tagstruct.SamplesPerPixel = 1;
%             tagstruct.RowsPerStrip    = 16;
%             tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
%             tagstruct.Software        = 'MATLAB';
%             t.setTag(tagstruct)
%             t.write(data(:,:,j,jj));
%         else
%             t = Tiff(outputFileName,'a');
%             tagstruct.ImageLength     = size(data,1);
%             tagstruct.ImageWidth      = size(data,2);
%             tagstruct.Photometric     = Tiff.Photometric.MinIsBlack;
%             tagstruct.BitsPerSample   = 16;
%             tagstruct.SamplesPerPixel = 1;
%             tagstruct.RowsPerStrip    = 16;
%             tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
%             tagstruct.Software        = 'MATLAB';
%             t.setTag(tagstruct)
%             t.write(data(:,:,j,jj))
%         end
%     end
%     t.close();
% end
% 
% % 16-bit Tiff tracing
% clear data;
% data = logical(bigTracing);
% 
% outputFileName = [writeFileName '_tracing.tif'];
% % This is a direct interface to libtiff
% for j=1:dim(4)
%     if (j==1)
%         t = Tiff(outputFileName,'w');
%         tagstruct.ImageLength     = size(data,1);
%         tagstruct.ImageWidth      = size(data,2);
%         tagstruct.Photometric     = Tiff.Photometric.MinIsBlack;
%         tagstruct.BitsPerSample   = 16;
%         tagstruct.SamplesPerPixel = 1;
%         tagstruct.RowsPerStrip    = 16;
%         tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
%         tagstruct.Software        = 'MATLAB';
%         t.setTag(tagstruct)
%         t.write(data(:,:,j));
%     else
%         t = Tiff(outputFileName,'a');
%         tagstruct.ImageLength     = size(data,1);
%         tagstruct.ImageWidth      = size(data,2);
%         tagstruct.Photometric     = Tiff.Photometric.MinIsBlack;
%         tagstruct.BitsPerSample   = 16;
%         tagstruct.SamplesPerPixel = 1;
%         tagstruct.RowsPerStrip    = 16;
%         tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
%         tagstruct.Software        = 'MATLAB';
%         t.setTag(tagstruct)
%         t.write(data(:,:,j))
%     end
%     t.close();
% end
end