function [dY,dX]=createDiffMatrix(Pi,Pg)
% createDiffMatrix is an accessory C-MEX function for vectorFieldDiv
%
% SYNOPSIS   [dX,dY]=createDiffMatrix(Pi,Pg)
%
% INPUT      Pi and Pg are the matrices containing the set of 2D point coordinates.
%
%                   M=[ y1 x1     and   N=[ y1 x1
%                       y2 x2              y2 x2
%                        ...                ...
%                       ym xm ]            yn xn ]
%
% OUTPUT   dY :
%          dX :
% 
% REMARK   
%
% C-MEX file - Aaron Ponti 11/26/02
%
% Copyright (C) 2017, Danuser Lab - UTSouthwestern 
%
% This file is part of BioSensorsPackage.
% 
% BioSensorsPackage is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% 
% BioSensorsPackage is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with BioSensorsPackage.  If not, see <http://www.gnu.org/licenses/>.
% 
% 
