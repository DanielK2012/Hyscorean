function Settings = getSettings(app)
%==========================================================================
% Hyscorean Retrieve Settings 
%==========================================================================
% This function collects the current settings of the Hyscorean GUI and puts
% them on a structure which will later be saved. 
%==========================================================================
%
% Copyright (C) 2019  Luis Fabregas, Hyscorean 2019
% Copyright (C) 2026  Daniel Klose,  Hyscorean 2026
% 
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License 3.0 as published by
% the Free Software Foundation.
%==========================================================================

 % Retrieve and store current GUI settings 
  Settings.tauFactor1 = str2double(app.L2G_tau.Value);
  Settings.sigmaFactor1 = str2double(app.L2G_sigma.Value);
  Settings.zerofilling1 = str2double(app.ZeroFilling1.Value);
  Settings.tauFactor2 = str2double(app.L2G_tau2.Value);
  Settings.sigmaFactor2 = str2double(app.L2G_sigma2.Value);
  Settings.Lorentz2GaussCheck = app.Lorentz2GaussCheck.Value;
  Settings.zerofilling1 = str2double(app.ZeroFilling1.Value);
  Settings.zerofilling2 = str2double(app.ZeroFilling2.Value);
  Settings.WindowDecay1 = str2double(app.WindowLength1.Value);
  Settings.WindowDecay2 = str2double(app.WindowLength1.Value);
  Settings.WindowType = app.WindowType.Value;
  Settings.BackgroundMethod2 = app.BackgroundMethod2.Value;
  Settings.BackgroundMethod1 = app.BackgroundMethod1.Value;
  Settings.BackgroundParameter1 = str2double(app.BackgroundParameter1.Value);
  Settings.BackgroundParameter2 = str2double(app.BackgroundParameter2.Value);
  Settings.BackgroundCorrection2D = 0;
  Settings.InvertCorrection = app.InvertCorrection.Value;
  Settings.FieldOffset = app.FieldOffset.Value;
  Settings.BackgroundStart1 = app.BackgroundStart1.Value;
  Settings.BackgroundStart2 = app.BackgroundStart2.Value;
  Settings.MultiTauDimension = app.MultiTauDimensions.Value;
  Settings.MinimalContourLevel = app.MinimalContourLevel.Value;
  Settings.MaximalContourLevel = app.MaximalContourLevel.Value;
  Settings.XUpperLimit = app.XUpperLimit.Value;
  Settings.ReconstructionAlgorithm = app.ReconstructionAlgorithm.Value;
  Settings.MaxEntBackgroundParameter = str2double(app.MaxEntBackgroundParameter.Value);
  Settings.MaxEntLagrangianMultiplier = str2double(app.MaxEntLagrangianMultiplier.Value);
  Settings.Symmetrization = app.Symmetrization_ListBox.Value;
  
  