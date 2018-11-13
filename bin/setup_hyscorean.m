

InstallationPath = pwd;
MATLAB_version = version;
OS = computer;
allFilesOK = true;


fprintf('---------------------------------------------------------------------------\n')
fprintf('Hyscorean: A GUI for HYSCORE processing and fitting     (c)2018 ETH Zurich \n')
fprintf('Version 1.0                                                                \n')
fprintf('---------------------------------------------------------------------------\n')
fprintf('Installation info                                                          \n')
fprintf('Path %s \n',InstallationPath)
fprintf('MATLAB version: %\n',MATLAB_version)
fprintf('OS: %s \n',OS)
fprintf('Java Version: %s \n',JavaVersion)
fprintf('Verfying Hyscorean directory contents: \n')
if allFilesOK
fprintf('No missing files \n')
end

%Set Hyscorean default paths

fprintf('Setting Hyscorean paths... ')
%Check if installation path is already in the matlab search path
if isempty(strfind(getenv('MATLABPATH'),InstallationPath))
  %Check if MATLABPATH already contains other paths and adjust input
  if isempty( getenv('MATLABPATH'))
    setenv('MATLABPATH', [getenv('MATLABPATH') '=' InstallationPath ';' InstallationPath '\bin']);
  else
    setenv('MATLABPATH', [getenv('MATLABPATH') ';' InstallationPath ';' InstallationPath '\bin']);    
  end
end
fprintf('done. \n')

% Set Sourcetree's local git path as a OS environmental path
fprintf('Searching for Sourcetree path...')
cd C:\
[DOS_status,DOS_output] = dos('dir Sourcetree /s /b /AD');
cd(InstallationPath)
fprintf('done. \n')
if ~strcmp(DOS_output(1:14),'File Not Found')
  %If Sourcetree is found
  fprintf('Setting SourceTree local git environment path... ')
  StrPos = strfind(DOS_output,'C:\');
  AtlassianPath = DOS_output(StrPos(1):StrPos(2)-1);
  EnviromentalVariablePATH = strcat(AtlassianPath,'\git_local\bin');
  %Check if Atlassian path is already in the PATH variable
  if isempty(strfind(getenv('PATH'),EnviromentalVariablePATH))
    setenv('PATH', [getenv('PATH') ';' EnviromentalVariablePATH]);
    fprintf('done. \n')
  end
else
    fprintf('Sourcetree path not found. Make sure it is properly installed\n')
    fprintf('and located in the C: drive of your computer. \n')
end

