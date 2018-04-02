function [ G ] = gradient( h, w )
%GRADIENT Summary of this function goes here
%   Detailed explanation goes here
i = zeros(2*h*(w-1)+2*w*(h-1),1);
j = zeros(2*h*(w-1)+2*w*(h-1),1);
v = zeros(2*h*(w-1)+2*w*(h-1),1);

% collect triplets here

G = sparse(i,j,v);


