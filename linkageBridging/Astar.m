%---------------------------------------------------
%       A* Algorithm
%
% author: Lorenzo Tortorella
% email: lorenzotortorella1989@gmail.com
%---------------------------------------------------

function [e, L] = Astar(pos,max_FS,raggio)
% OUTPUT
% e = path cost;
% L = nodes Shortest path;
% INPUT
% pos = vector (3D) positions
% max_FS = maximum forward star to evaluate
% raggio = tolerable distance for consider a node connected
%
% SUMMARIZE:
% COMPUTE THE SHORTEST PATH BETWEEN STARTING NODE AND ENDING ONE
%
% Data il vettore delle posizioni, il massimo numero di nodi vicini e la
% tolleranza di connessione: calcola il percorso minimo di ritorno,
% con funzione euristica.
% OPEN = [ # nodo | g(n) | h(n) | f(n)| nodo predecessore]
% CLOSED = OPEN = neighbor = current
% 
% per C\C++ Code Generator
% coder.extrinsic('abv');
% eml.extrinsic('abv');
e=0; L=[]; FS=zeros(max_FS,1); % inizializzo Stella uscente
Target=pos(1,:); % coordinate 
Start=pos(end,:); % coordinate
OPEN_SORTED=[]; CLOSED=[];
neighbor=zeros(1,5); % neighbor nodes
% pongo costo Inf fra nodi non connessi
% A = setupgraph(distanze,inf,1); % vedo connessioni grafo
B =[Inf*ones(size(pos,1)-1,1); 0]; % Label
P =size(pos,1)*ones(size(pos,1),1); % Predecessori inizializzati a Start
% Inizializzo OPEN
OPEN=[size(pos,1),0,pdist2(Target,Start),pdist2(Target,Start), P(end)];
while min(size(OPEN)) ~= 0 % current_pos ~= Target
    [OPEN_EXTRACTED,OPEN_SORTED] = update_open(OPEN); % take node with lowest f(n)
    current=OPEN_EXTRACTED; % that is current node
    current_pos=pos(OPEN_EXTRACTED(1),:); % coordinates of current node
    if current_pos == Target % Target reached
        CLOSED=abv(CLOSED,current);
        break
    end
    OPEN=OPEN_SORTED; %remove current from OPEN
    CLOSED=abv(CLOSED,OPEN_EXTRACTED); %add current to CLOSED
    j=1;
    for i=1:length(pos)
        if j>max_FS
            break
        end
        if (pdist2(current_pos,pos(i,:))) < raggio
            FS(j)=i;
            j=j+1;
        end
    end
    FS=setdiff(FS,0); % neighbors nodes of current
% expanding OPEN 
    for i = 1:length(FS)
        if ismember(FS(i),CLOSED(:,1))
            continue
        end
        neighbor_pos=pos(FS(i),:); % coordinate neighbor
        tentative_g=B(current(1))+pdist2(current_pos,neighbor_pos);% f(n)
        neighbor(1)=FS(i); % node number
        neighbor(2)=B(FS(i)); % g(n) neigbor
        neighbor(3)=pdist2(neighbor_pos,Target); % h(n) neighbor
        neighbor(4)=neighbor(2)+neighbor(3); % f(n) neighbor
        neighbor(5)=P(FS(i)); % nodo predecessore
        if ~(ismember(neighbor(1),OPEN(:,1))) ||...
                (neighbor(2) > tentative_g)
           neighbor(2)=tentative_g; % aggiorno g(n)
           neighbor(4)=neighbor(2)+neighbor(3); % f(n)=g(n)+h(n)
           neighbor(5)=current(1); % nodo predecessore aggiornato
           P(FS(i))=current(1); % aggiorno Predecessori
           B(FS(i))=tentative_g; % aggiorno Label
        end
        if ~(ismember(neighbor(1),OPEN(:,1)))
            OPEN=abv(OPEN,neighbor); % espando OPEN list
        end
    end
end
% Path Cost
e = B(1);
% Shortest Path
L=CLOSED(end,1);
PRED=CLOSED(end,5);
L=abv(L,PRED);
while PRED~=CLOSED(1)
    PRED=CLOSED(CLOSED(:,1)==PRED,5);
    L=abv(L,PRED);
end
L=L';% node list
end