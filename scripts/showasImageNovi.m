
function [OutputMatrix] = showasImageNovi(InputMatrix)
%[rows,cols]=size(InputMatrix);

minValue=min(min(InputMatrix));
maxValue=max(max(InputMatrix));
Range=maxValue-minValue;


OutputMatrix = ((InputMatrix - minValue)/Range)*255 ;
