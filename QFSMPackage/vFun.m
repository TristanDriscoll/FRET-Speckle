function [f,df] = vFun(v,pp,dpp1,dpp2)

f  = -fnval(pp,v.');
df = -[fnval(dpp1,v.') fnval(dpp2,v.')];
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
