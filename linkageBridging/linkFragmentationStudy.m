function skel = linkBlockandRepairV2(filename, TH)
% use a KDTree searcher to accelerate the process
% still under development
% Author: Duan, Bin
% Date: Apr 1, 2020

load(filename)

rng(0,'twister');
r = randi([1 100],1,10);

w = size(skel,1);
l = size(skel,2);
h = size(skel,3);

CC = bwconncomp(skel);
numVoxels = cellfun(@numel,CC.PixelIdxList);

if length(numVoxels) == 1
    return
end

for i=1:length(numVoxels)
    idxes = CC.PixelIdxList{i};
    if length(idxes) > 100
    % remove one point randomly
        skel(idxes(r)) = false;
    end
end
save('/home/duanbin/bb/results/PVSOMcre_Mche_mk2_gfp_stitchedHist_8bit/Y1755_X1000_Z188/GMMBrokenLinks/skelwithbrokenlinks_10.mat', 'skel', '-v7.3');
% for i=1:length(numVoxels)
%     if numVoxels(i) < TH - 10
%         skel(CC.PixelIdxList{i})=false;
%     end
% end

% initial step: condense, convert to voxels and back, detect cells
[~,node,link] = Skel2Graph3D(skel,0);

% total length of network
wl = sum(cellfun('length',{node.links}));

skel2 = Graph2Skel3D(node,link,w,l,h);
[A2,node2,link2] = Skel2Graph3D(skel2,0);

% calculate new total length of network
wl_new = sum(cellfun('length',{node2.links}));

% iterate the same steps until network length changed by less than 0.5%
while(wl_new~=wl)

    wl = wl_new;   
    
     skel2 = Graph2Skel3D(node2,link2,w,l,h);
     [A2,node2,link2] = Skel2Graph3D(skel2,0);

     wl_new = sum(cellfun('length',{node2.links}));

end

% display result
% figure();
% hold on;
% for i=1:length(node2)
%     x1 = node2(i).comx;
%     y1 = node2(i).comy;
%     z1 = node2(i).comz;
%     
%     if(node2(i).ep==1)
%         ncol = 'c';
%     else
%         ncol = 'y';
%     end
%     
%     for j=1:length(node2(i).links)    % draw all connections of each node
%         if(node2(node2(i).conn(j)).ep==1)
%             col='k'; % branches are black
%         else
%             col='r'; % links are red
%         end
%         if(node2(i).ep==1)
%             col='k';
%         end
% 
%         
%         % draw edges as lines using voxel positions
%         for k=1:length(link2(node2(i).links(j)).point)-1            
%             [x3,y3,z3]=ind2sub([w,l,h],link2(node2(i).links(j)).point(k));
%             [x2,y2,z2]=ind2sub([w,l,h],link2(node2(i).links(j)).point(k+1));
%             line([y3 y2],[x3 x2],[z3 z2],'Color',col,'LineWidth',2);
%         end
%     end
%     
%     % draw all nodes as yellow circles
%     plot3(y1,x1,z1,'o','Markersize',9,...
%         'MarkerFaceColor',ncol,...
%         'Color','k');
% end
% axis image;
% axis off;
% set(gcf, 'Color','white')
% set(gca, 'YDir', 'reverse', 'ZDir', 'reverse');
% drawnow;

G = graph(A2);

% find all end points
ep = find([node2.ep]);
X = [node2(ep).comx node2(ep).comy node2(ep).comz];
X = reshape(X, [], 3);
Mdl = KDTreeSearcher(X);

for i=1:length(ep)
    smallest_dist_idx = [];
    smallest_dist = TH;
    query = [node2(ep(i)).comx node2(ep(i)).comy node2(ep(i)).comz];
    tt = rangesearch(Mdl, query, TH);
    tt = [tt{1}];
    % remove connected component
    for j = 1:length(tt)
        if ep(i) == ep(tt(j))
            continue;
        else
            P = shortestpath(G,ep(i),ep(tt(j)));
            if isempty(P)
                value = [node2(ep(tt(j))).comx node2(ep(tt(j))).comy node2(ep(tt(j))).comz];
                dists=pdist2(query, value);
                if dists < smallest_dist
                    smallest_dist = dists;
                    smallest_dist_idx = j;
                end
            end
        end
    end
    if ~isempty(smallest_dist_idx)
        value = [node2(ep(tt(smallest_dist_idx))).comx node2(ep(tt(smallest_dist_idx))).comy node2(ep(tt(smallest_dist_idx))).comz];
        dists=pdist2(query, value);
        % link the two nodes
        iii = ep(i);
        jjj = ep(tt(smallest_dist_idx));
        % update node.ep
        node2(iii).ep = 0;
        node2(jjj).ep = 0;
        % update label
        node2(jjj).label = node2(iii).label;
        % update conn
        tmp = node2(iii).conn;
        node2(iii).conn = [tmp node2(jjj).conn];
        node2(jjj).conn = [node2(jjj).conn tmp];
        % update link2
        cursor = length(link2);
        link2(cursor+1).n1 = iii;
        link2(cursor+1).n2 = jjj;
        link2(cursor+1).point = [node2(iii).idx' node2(jjj).idx'];
        link2(cursor+1).label = node2(iii).label;

        % update links
        node2(iii).links = [node2(iii).links length(link2)];
        node2(jjj).links = [node2(jjj).links length(link2)];

        % update graph G for subgraph purpose
        G = addedge(G, iii, jjj, floor(dists));
    end
end

skel3 = false(size(skel2));
for i=length(link)+1:length(link2)
    % generate points
    [xs,ys,zs]=ind2sub([w,l,h],link2(i).point(1));
    [xe,ye,ze]=ind2sub([w,l,h],link2(i).point(2));
    count = 0;
    
    flag_x = 1;
    flag_y = 1;
    flag_z = 1;
    
    if xs > xe; flag_x = -1; end
    if ys > ye; flag_y = -1; end
    if zs > ze; flag_z = -1; end
    
    for ii=xs:flag_x:xe             
        for jj=ys:flag_y:ye
            for kk=zs:flag_z:ze
                tmp = [ii jj kk];
                count = count + 1;
                if count == 1
                    posiz = tmp;
                else
                    posiz = [posiz; tmp];
                end
            end
        end
    end
    
    feasible = 0;
    ia=1;
    factor=1.1;
    while feasible ~= 1 % RUN UNTIL A SOLUTION IS REACHED

        [cost(ia), L]=Astar(posiz,size(posiz,1),factor);

        if cost(ia) < Inf % CHECK ON THE COST VALUE
            feasible=1;
        else
            ia=ia+1; % iteration number 
        end
    end
    skel3(sub2ind(size(skel3), posiz(L,1),posiz(L,2),posiz(L,3))) = true;
%     skel3 = bwskel(skel3);
end

clear skel;

skel = skel2 | skel3; 
end

