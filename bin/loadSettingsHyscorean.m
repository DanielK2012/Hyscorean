function loadSettingsHyscorean(app)
%==========================================================================
% Load Settings
%==========================================================================
% This function loads a previously saved settings file and sets all UI
% elements in the Hyscorean GUI to the corresponding values.
%
% (see Hyscorean manual for further information)
%==========================================================================
%
% Copyright (C) 2019  Luis Fabregas, Hyscorean 2018-2019
% Copyright (C) 2026  Daniel Klose,  Hyscorean 2026
%
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License 3.0 as published by
% the Free Software Foundation.
%==========================================================================

%Get path to settings file with loading GUI
[File, Path]=uigetfile('MultiSelect','off');
%If user has cancelled then return
if File == 0
  return;
end

try
  %Load settings
  FileImport = load(fullfile(Path,File));
  Settings = FileImport.Settings;
  %Set all UI elements to the corresponding values
  app.L2G_tau.Value = num2str(Settings.tauFactor1);
  app.L2G_tau2.Value = num2str(Settings.tauFactor2);
  app.L2G_sigma.Value = num2str(Settings.sigmaFactor1);
  app.L2G_sigma2.Value = num2str(Settings.sigmaFactor2);
  app.ZeroFilling2.Value = num2str(Settings.zerofilling2);
  app.ZeroFilling1.Value = num2str(Settings.zerofilling1);
  app.MaxEntBackgroundParameter.Value = num2str(Settings.MaxEntBackgroundParameter);
  app.MaxEntLagrangianMultiplier.Value = num2str(Settings.MaxEntLagrangianMultiplier);
  app.WindowType.Value = Settings.WindowType;
  switch Settings.WindowType
    case 'Hamming'
      WindowType =  'hamming';
    case 'Chebyshev'
      WindowType =  'chebyshev';
    case 'Welch'
      WindowType =  'welch';
    case 'Blackman'
      WindowType = 'blackman';
    case 'Bartlett'
      WindowType = 'bartlett';
    case 'Connes'
      WindowType = 'connes';
    case 'Cosine'
      WindowType = 'cosine';
    case '25% Tukey'
      WindowType = 'tukey25';
    case '50% Tukey'
      WindowType = 'tukey50';
    case '75% Tukey'
      WindowType = 'tukey75';
    case 'Hann'
      WindowType = 'hann';
    case 'None'
      WindowType = 'none';
  end
  try
    app.WindowTypeString = WindowType;
    app.WindowLength1.Value = num2str(Settings.WindowDecay1);
    app.WindowLength2.Value = num2str(Settings.WindowDecay2);
    app.Symmetrization_ListBox.Value = Settings.Symmetrization;
    
  catch
  end
  app.WindowType.Value = Settings.WindowType;
  app.BackgroundParameter1.Value = num2str(Settings.BackgroundParameter1);
  app.BackgroundParameter2.Value = num2str(Settings.BackgroundParameter2);
  app.Lorentz2GaussCheck.Value = Settings.Lorentz2GaussCheck;
  app.BackgroundStart1.Value = Settings.BackgroundStart1;
  app.BackgroundStart2.Value = Settings.BackgroundStart2;
  app.MinimalContourLevel.Value = Settings.MinimalContourLevel;
  try
    app.MaximalContourLevel.Value = Settings.MaximalContourLevel;
  catch
  end
  app.XUpperLimit.Value = Settings.XUpperLimit;
  app.FieldOffset.Value = Settings.FieldOffset;
  try %Try because if not the exact same file is loaded, value of list may exceed current one
    app.MultiTauDimensions.Value = Settings.MultiTauDimension;
  catch
  end
  %Set buttons
  app.BackgroundMethod2.Value = Settings.BackgroundMethod2;
  app.BackgroundMethod1.Value = Settings.BackgroundMethod1;
  app.InvertCorrection.Value = Settings.InvertCorrection;
  app.ReconstructionAlgorithm.Value = Settings.ReconstructionAlgorithm;
  
catch
  %If user loads another type of file then error occurs. Inform user.
  f = errordlg(sprintf('An error occurred while loading the settings file: \n %s \n Please check your input.',File),'File Error');
  waitfor(f);
end

end

