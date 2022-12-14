function [] = aps_save(save_name,varargin)
% aps_save(save_name,varargin)
% function that decides on which save option to use.
% Large matlab variables (2^31 Bytes) should use the later -v7.3 option
%
% INPUTS: 
% save_name     String with the filename of the save datafile
% varagin       Variables which need to be save. 
%               Note these are the actual variabels and not their names.
% 
% EXAMPLE for saving the lonlat variable in results.mat:
% >> aps_save('results.mat',lonlat)
%
%     Copyright (C) 2016  Bekaert David - davidbekaert.com
% 
%     This program is free software; you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation; either version 2 of the License, or
%     (at your option) any later version.
% 
%     This program is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
% 
%     You should have received a copy of the GNU General Public License along
%     with this program; if not, write to the Free Software Foundation, Inc.,
%     51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
%
% By Bekaert David - Jan 2016
% modifications:
% DB    02/2016     Check if the save folder exist, if not make it.
% DB    10/2016     Include the option to append to a file in case it already exists.
% DB    10/2016     Do not attempt to make no-name directory.
% DB    10/2017     Add .mat to file names in case user omited it.


% maximum number of bytes before using the -v3.7 option to save
n_bytes_max = 2^31;       % is about 2 GB

% getting the number of bytes of the variables we are saving and update the
% switch_option if needed.
var_str = [];
switch_option = 'n';        % defaut save option when 'n'
for k=1:length(varargin)
    var_name{k} = inputname(k+1);
    var_str = [var_str ',''' inputname(k+1) ''''];
    eval([var_name{k} ' =  varargin{' num2str(k) '} ;']);
    
    % checking the bytes of each variable
    data = whos(var_name{k});
    if data.bytes>=n_bytes_max
        switch_option='y';
    end
end

% check if the save folder exists, if not make it.
[path,temp,ext] = fileparts(save_name);
if ~isempty(path)
    if exist(path,'dir')~=7
        mkdir(path);
    end
end

% if the dsave file does not end with .mat then append it, otherwize matlab
% might not find it...
if ~strcmpi(ext,'.mat')
    save_name = [save_name '.mat'];
end

% choose the saving option
if exist(save_name,'file')==2
    fprintf('File exist will append\n')
    if strcmpi(switch_option,'y')
       fprintf('Your variables are reaching 2GB limit, revert to save -v7.3 \nThis will be slower but avoids matlab not saving the data\n') ;
       % Matlab refuese to append in the "-v7.3" mode to an different formatted file.
       % check if this is "-v7.3" file
       x = evalc(['type(''', save_name, ''')']);
       test_flag = strcmp(x(2:20), 'MATLAB 7.3 MAT-file');
       % save the data
       if test_flag==1 
           eval(['save(''' save_name '''' var_str ',''-v7.3'',''-append'');'])
       else
          fprintf('matlab cannot save this file because it was originally not saved with -v7.3 option.\nWill change the formating...\n') 
          % solution load the file and write it as -v3.7
          temp = load(save_name);
          movefile(save_name,[save_name '_original']);          % backup original file.
          save(save_name, '-struct', 'temp','-v7.3');
          % now append the new data.
          eval(['save(''' save_name '''' var_str ',''-v7.3'');'])
       end
    else
       eval(['save(''' save_name '''' var_str ',''-append'');'])
    end      
else
    if strcmpi(switch_option,'y')
       fprintf('Your variables are reaching 2GB limit, revert to save -v7.3 \nThis will be slower but avoids matlab not saving the data\n') ;
       eval(['save(''' save_name '''' var_str ',''-v7.3'');'])
    else
       eval(['save(''' save_name '''' var_str ');'])
    end
end
