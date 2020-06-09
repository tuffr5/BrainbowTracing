function [ OPEN_EXTRACTED, OPEN_SORTED ] = update_open( OPEN )
% Sorts elements in base of ascendind f(n) values
% and extract the best candidate.
% INPUT:
% OPEN matrix
% OUTPUT:
% OPEN_EXTRACTED, node with minimum f(n) value
% OPEN_SORTED, OPEN list without the candidate node
% All functions are C\C++ compatible.
OPEN_SORTED=sortrows(OPEN,4);
OPEN_EXTRACTED=OPEN_SORTED(1,:); % estrae quello ad f(n) minima
OPEN_SORTED=OPEN_SORTED(2:end,:);
end

