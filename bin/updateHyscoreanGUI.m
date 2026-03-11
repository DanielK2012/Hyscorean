function updateHyscoreanGUI(app,Processed)
%==========================================================================
% Updater of the HYSCOREAN GUI
%==========================================================================
% Automatically update all graphical elements present on the GUI according
% to the most recent data. This function is responsible for the plotting the
% main spectrum as well as for calling the function responsible for the
% plots containing the time domain signals.
% During the creation and rendering of the graphics, all UI elements are
% disabled until they are rendered to avoid overloading the main program.
%==========================================================================
%
% Copyright (C) 2019  Luis Fabregas, Hyscorean 2019
% Copyright (C) 2026  Daniel Klose,  Hyscorean 2026
%
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License 3.0 as published by
% the Free Software Foundation.
%==========================================================================

try
  
  %Deactivate all pushbuttons until the graphics are rendered  & update info display
  % set(findall(app.HyscoreanFigure, 'Style', 'pushbutton'),'enable','inactive')
  % set(findall(app.HyscoreanFigure, 'Style', 'radiobutton'),'enable','inactive')
  % set(findall(app.HyscoreanFigure, 'Style', 'checkbox'),'enable','inactive')
  % set(findall(app.HyscoreanFigure, 'Style', 'edit'),'enable','inactive')
  % set(findall(app.HyscoreanFigure, 'Style', 'slider'),'enable','inactive')
  % set(findall(app.HyscoreanFigure, 'Style', 'popupmenu'),'enable','inactive')

  h_buttons = findall(app.HyscoreanFigure, 'Type', 'uibutton');
  set(h_buttons, 'Enable', 'off');
  h_radio = findall(app.HyscoreanFigure, 'Type', 'uiradiobutton');
  set(h_radio, 'Enable', 'off');
  h_check = findall(app.HyscoreanFigure, 'Type', 'uicheckbox');
  set(h_check, 'Enable', 'off');
  h_edit = findall(app.HyscoreanFigure, 'Type', 'uieditfield');
  set(h_edit, 'Enable', 'off');
  h_slider = findall(app.HyscoreanFigure, 'Type', 'uislider');
  set(h_slider, 'Enable', 'off');
  h_dropdown = findall(app.HyscoreanFigure, 'Type', 'uidropdown');
  set(h_dropdown, 'Enable', 'off');

  app.ProcessingInfo.Text = 'Status: Rendering...';
  %Re-deactivate all which were deactivated (just aesthetic)
  if ~app.Lorentz2GaussCheck.Value
    enableDisableGUI(app,'Lorent2Gauss','off')
  end
  if ~app.Data.NUSflag
    enableDisableGUI(app,'NUSReconstruction','off')
  end
  enableDisableGUI(app,'AutomaticBackground','off')
  
  
  drawnow;
  %Enable all graphics-related GUI components
  app.PreProcessedTrace.Visible = 'on';
  app.ImaginaryTrace.Visible = 'on';
  app.NonCorrectedTrace.Visible = 'on';
  app.PlotApodizationWindow.Visible = 'on';
  app.DetachSignalPlot.Visible = 'on';
  app.ChangeSignalPlotDimension.Visible = 'on';
  app.t1_Slider.Enable = 'on';
  %Set background of all signalPlot GUI components to white to match background
  % app.PreProcessedTrace.Visible = 'off';
  % app.NonCorrectedTrace.Visible = 'off';
  % app.ImaginaryTrace.Visible = 'off';
  % app.PlotApodizationWindow.Visible = 'off';
  % app.DetachSignalPlot.BackgroundColor = 'white';
  
  % Update signal plots
  %------------------------------------------------------------------------
  Processed.TimeAxis1 = linspace(0,app.Data.TimeStep1*size(Processed.Signal,1),size(Processed.Signal,1));
  Processed.TimeAxis2 = linspace(0,app.Data.TimeStep2*size(Processed.Signal,2),size(Processed.Signal,2));
  % Activate sliders
  % Npoints = length(Processed.TimeAxis2) - str2double(app.ZeroFilling2.Value);
  % app.t1_Slider.Limits = [1 Npoints];
  % app.t1_Slider.Step = 1/(Npoints - 1);
  % app.t1_Slider.Value = 1;
  app.PlotProcessedSignal = true;
  try
    HyscoreanSignalPlot(app,Processed);
  catch
  end
  
  % Update external signal plot GUI
  %------------------------------------------------------------------------
  if isempty(app.SignalPlotIsDetached)
    app.SignalPlotIsDetached = false;
  end
  if app.SignalPlotIsDetached
    setappdata(0,'Processed',app.Processed)
    setappdata(0,'Data',app.Data)
    setappdata(0,'InvertCorrection',app.InvertCorrection.Value)
    setappdata(0,'ZeroFilling1',str2double(app.ZeroFilling1.Value))
    setappdata(0,'ZeroFilling2',str2double(app.ZeroFilling2.Value))
    setappdata(0,'WindowLength1',app.WindowLength1.Value)
    setappdata(0,'WindowLength2',app.WindowLength2.Value)
    setappdata(0,'WindowType',app.WindowType.Value)
    
    %Call graphical settings GUI
    Hyscorean_detachedSignalPlot
  end
  
  % Update Main plot
  %------------------------------------------------------------------------
  
  %Get data
  Spectrum = Processed.spectrum;
  FrequencyAxis1 = Processed.axis1;
  FrequencyAxis2 = Processed.axis2;
  
  %Get and set axis limits
  XupperLimit = str2double(app.XUpperLimit.Value);
  XlowerLimit = -XupperLimit;
  YupperLimit = XupperLimit;
  YlowerLimit = 0;
  
  %Load current graphical settings
  GraphicalSettings = getpref('hyscorean','graphicalsettings');
  
  %Type of spectrum
  if GraphicalSettings.Absolute
    Spectrum = abs(Spectrum);
  elseif GraphicalSettings.Real
    Spectrum = real(Spectrum);
  elseif GraphicalSettings.Imaginary
    Spectrum = imag(Spectrum);
  end
  
  %Select current colormap
  if isfield(app.GraphicalSettings,'ColormapName')
    colormap(colormap(app.GraphicalSettings.ColormapName))
  else
    colormap('parula')
  end
  %Compute contour levels according to minimal contour level given by user
  Levels=GraphicalSettings.Levels;
  MinimalContourLevel = str2double(app.MinimalContourLevel.Value)/100;
  MaximalContourLevel = str2double(app.MaximalContourLevel.Value)/100;
  
  if MinimalContourLevel~=0 && GraphicalSettings.Absolute
    MaximalContourLevel = MaximalContourLevel*max(max(Spectrum));
    Spectrum(Spectrum>MaximalContourLevel) = MaximalContourLevel;
    MinimalContourLevel = max(max(abs(Processed.spectrum)))*MinimalContourLevel;
    ContourLevelIncrement = (MaximalContourLevel - MinimalContourLevel)/Levels;
    ContourLevels = MinimalContourLevel:ContourLevelIncrement:MaximalContourLevel;
  else
    MaximalContourLevel = max(max(Spectrum));
    MinimalContourLevel = min(min(Spectrum));
    ContourLevelIncrement = (MaximalContourLevel - MinimalContourLevel)/Levels;
    ContourLevels = MinimalContourLevel:ContourLevelIncrement:MaximalContourLevel;
  end
  app.Processed.ContourLevels = ContourLevels;
  
  %If blindspots are to be plotted, superimpose them to the spectrum
  if app.ImposeBlindSpots.Value
    [BlindSpots,nu1,nu2] = imposeBlindSpots(app);
    BlindSpots = abs(BlindSpots);
    BlindSpots = BlindSpots/max(BlindSpots(:))*max(Spectrum(:));
    colormap('hot')
    BlindSpots = pcolor(app.mainPlot,nu1,nu2,BlindSpots);shading(app.mainPlot,'flat'), ...
    alpha(BlindSpots,0.7);
    hold(app.mainPlot,'on')
  end
  
  %Construct main plot
  switch GraphicalSettings.PlotType
    case 1 %Contour plot
      if app.ImposeBlindSpots.Value
        %If blindspots are superimposed, make contour only black to adapt to hot-colormap
        contour(app.mainPlot,FrequencyAxis1,FrequencyAxis2,Spectrum,ContourLevels,'LineWidth',GraphicalSettings.LineWidth,'Color','k');
      else
        contour(app.mainPlot,FrequencyAxis1,FrequencyAxis2,Spectrum,ContourLevels,'LineWidth',GraphicalSettings.LineWidth);
      end
    case 2 %Filled contour plot
      contourf(app.mainPlot,FrequencyAxis1,FrequencyAxis2,Spectrum,ContourLevels);
    case 3 %Pseudocolor plot
      pcolor(app.mainPlot,FrequencyAxis1,FrequencyAxis2,Spectrum),shading(app.mainPlot,'interp')
  end
  
  %Add diagonal/antidiagonal and zero-vertical auxiliary lines
  hold(app.mainPlot,'on')
  LineAxis = linspace(-XupperLimit,XupperLimit,1000);
  app.Diagonals = plot(app.mainPlot,LineAxis,abs(LineAxis),'k-.');
  set(app.mainPlot,'LineWidth',0.5)
  app.VerticalLine = plot(app.mainPlot,zeros(length(LineAxis)),abs(LineAxis),'k-','LineWidth',0.5);
  set(app.mainPlot,'LineWidth',1)
  hold(app.mainPlot,'off')
  
  %Format axes
  grid(app.mainPlot,'on')
  set(app.mainPlot,'ylim',[YlowerLimit YupperLimit],'xlim',[XlowerLimit XupperLimit])
  xlabel(app.mainPlot,'\nu_1 [MHz]');
  ylabel(app.mainPlot,'\nu_2 [MHz]');
  currentXTicks = xticks(app.mainPlot);
  currentYTicks = currentXTicks(currentXTicks>=0);
  xticks(app.mainPlot,currentXTicks)
  yticks(app.mainPlot,currentYTicks)
  set(app.mainPlot,'YTickLabel',currentYTicks,'XTickLabel',currentXTicks)
  
  
  % Finish & Exit
  %------------------------------------------------------------------------
  
  %Reactivate all pushbuttons & update info display
  app.ProcessingInfo.Text = 'Status: Finished'; drawnow;
  % set(findall(app.HyscoreanFigure, 'Style', 'pushbutton'),'enable','on')
  % set(findall(app.HyscoreanFigure, 'Style', 'radiobutton'),'enable','on')
  % set(findall(app.HyscoreanFigure, 'Style', 'checkbox'),'enable','on')
  % set(findall(app.HyscoreanFigure, 'Style', 'edit'),'enable','on')
  % set(findall(app.HyscoreanFigure, 'Style', 'slider'),'enable','on')
  % set(findall(app.HyscoreanFigure, 'Style', 'popupmenu'),'enable','on')
  % set(findall(app.HyscoreanFigure, 'Style', 'text'),'enable','on')
  
  set(h_buttons, 'Enable', 'on');
  set(h_radio, 'Enable', 'on');
  set(h_check, 'Enable', 'on');
  set(h_edit, 'Enable', 'on');
  set(h_slider, 'Enable', 'on');
  set(h_dropdown, 'Enable', 'on');

  %Re-deactivate all which were deactivated
  if ~app.Lorentz2GaussCheck.Value
    enableDisableGUI(app,'Lorent2Gauss','off')
  end
  if ~app.Data.NUSflag
    enableDisableGUI(app,'NUSReconstruction','off')
  else
    enableDisableGUI(app,'NUSReconstruction','on')
  end
  enableDisableGUI(app,'AutomaticBackground','on')
  
  
catch Error
  
  w = errordlg(sprintf('Error found during rendering of graphics: \n %s',Error.message));
  waitfor(w);
  %Reactivate all pushbuttons & update info display
  app.ProcessingInfo.Text = 'Status: Error'; drawnow;
  % set(findall(app.HyscoreanFigure, 'Style', 'pushbutton'),'enable','on')
  % set(findall(app.HyscoreanFigure, 'Style', 'radiobutton'),'enable','on')
  % set(findall(app.HyscoreanFigure, 'Style', 'checkbox'),'enable','on')
  % set(findall(app.HyscoreanFigure, 'Style', 'edit'),'enable','on')
  % set(findall(app.HyscoreanFigure, 'Style', 'slider'),'enable','on')
  % set(findall(app.HyscoreanFigure, 'Style', 'popupmenu'),'enable','on')
  % set(findall(app.HyscoreanFigure, 'Style', 'text'),'enable','on')
  
  set(h_buttons, 'Enable', 'on');
  set(h_radio, 'Enable', 'on');
  set(h_check, 'Enable', 'on');
  set(h_edit, 'Enable', 'on');
  set(h_slider, 'Enable', 'on');
  set(h_dropdown, 'Enable', 'on');
  app.TraceButtonGroup.Enable = 'on';

  %Re-deactivate all which were deactivated
  if ~app.Lorentz2GaussCheck.Value
    enableDisableGUI(app,'Lorent2Gauss','off')
  end
  if ~app.Data.NUSflag
    enableDisableGUI(app,'NUSReconstruction','off')
  else
    enableDisableGUI(app,'NUSReconstruction','on')
  end
  enableDisableGUI(app,'AutomaticBackground','on')
  
  
end

drawnow;