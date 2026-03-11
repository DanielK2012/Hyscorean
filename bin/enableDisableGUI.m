function enableDisableGUI(app,Panel,Action)
%==========================================================================
% HYSCORE blind spot simulator
%==========================================================================
% Function for enabling or disabling different groups of UI elements of
% Hyscorean fast and in one line. 
%==========================================================================
%
% Copyright (C) 2019  Luis Fabregas, Hyscorean 2019
% Copyright (C) 2026  Daniel Klose,  Hyscorean 2026
% 
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License 3.0 as published by
% the Free Software Foundation.
%==========================================================================

switch Panel
  
  case 'NUSReconstruction'
    app.MaxEntBackgroundParameter.Enable = Action;
    app.BackgroundParameterText.Enable = Action;
    if strcmp(Action,'on')
    switch app.ReconstructionAlgorithm.Value
      case 'constant-lambda CAMERA'
        app.MaxEntLagrangianMultiplier.Enable = 'on';
        app.LagrangeMultiplierText.Enable = 'on';
        app.BackgroundParameterText.Enable = 'on';
        app.MaxEntBackgroundParameter.Enable = 'on';
      case {'constant-aim CAMERA', 'FFM-CG', 'FFM-GD'} %{2,3,4}
        app.MaxEntLagrangianMultiplier.Enable = 'off';
        app.LagrangeMultiplierText.Enable = 'off';
        app.BackgroundParameterText.Enable = 'on';
        app.MaxEntBackgroundParameter.Enable = 'on';
      otherwise
        app.MaxEntLagrangianMultiplier.Enable = 'off';
        app.LagrangeMultiplierText.Enable = 'off';
        app.BackgroundParameterText.Enable = 'off';
        app.MaxEntBackgroundParameter.Enable = 'off';
    end
    else
      app.MaxEntLagrangianMultiplier.Enable = Action;
      app.LagrangeMultiplierText.Enable = Action;
      app.BackgroundParameterText.Enable = Action;
      app.NUSReconstructionText.Enable = Action;
    end
    app.NUSReconstructionText.Enable = Action;
    app.ReconstructionAlgorithm.Enable = Action;
    app.plotNUSgridText.Enable = Action;
    app.plotNUSgrid.Enable = Action;
    
  case 'Lorent2Gauss'
    app.L2G_sigma.Enable = Action;
    app.L2G_sigma2.Enable = Action;
    app.L2GSigmaText.Enable = Action;
    app.L2GSigmaText2.Enable = Action;
    app.L2GTauText.Enable = Action;
    app.L2GTauText2.Enable = Action;
    app.L2G_tau.Enable = Action;
    app.L2G_tau2.Enable = Action;
    
  case 'AutomaticBackground'
    app.BackgroundStart1.Enable = Action;
    app.BackgroundStart2.Enable = Action;
    
  case 'SG-Filtering'
    app.FilterOrder.Enable = Action;
    app.FilterOrderText.Enable = Action;
    app.FrameLength.Enable = Action;
    app.FrameLengthText.Enable = Action;
end