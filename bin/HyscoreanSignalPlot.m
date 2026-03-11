function HyscoreanSignalPlot(app,Processed)
%==========================================================================
% Time-domain signal traces updater 
%==========================================================================
% Interactively display the traces of the different time-domain traces
% processed throughout Hyscorean via GUI slider.  
% This function is responsible for the update and functionality of the
% signal plot in the Hyscorean main-GUI, as well as for the detached signal
% plot GUI.
%
% Allows the user to switch between signal at different stages of
% processing as well as its real and imaginary parts and the apodization
% window.
%
% (see Hyscorean manual for more information)
%==========================================================================
%
% Copyright (C) 2019  Luis Fabregas, Hyscorean 2019
% Copyright (C) 2026  Daniel Klose,  Hyscorean 2026
% 
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License 3.0 as published by
% the Free Software Foundation.
%==========================================================================



% Preparations
%------------------------------------------------------------------------

%Clear axes
cla(app.signal_t1)
hold(app.signal_t1,'on')

%Check crucial fields and set defaults if needed
if app.Data.NUSflag
  PlotStyle = '.';
else
  PlotStyle = '-';
end
if app.Data.NUSflag
  NUSgrid = app.Data.NUSgrid;
else
    NUSgrid = ones(size(Processed.Signal));
end
if isempty(app.PlotProcessedSignal)
  app.PlotProcessedSignal = true;
end
if isempty(app.PlotBackground)
  PlotSecondCorrection = false;
else
  PlotSecondCorrection = app.PlotBackground;
end
if isempty(app.PlotImaginarySignal)
  PlotImaginarySignal = false;
else
  PlotImaginarySignal = app.PlotImaginarySignal;
end

if isempty(app.PlotWithZeroFilling)
   PlotWithZeroFilling = false;
else
   PlotWithZeroFilling = app.PlotWithZeroFilling;
end
app.Data.BackgroundStartIndex1 = int32(str2double(app.BackgroundStart1.Value));
if app.Data.BackgroundStartIndex1 < 1
    app.Data.BackgroundStartIndex1 = 1;
end
app.Data.BackgroundStartIndex2 = int32(str2double(app.BackgroundStart2.Value));
if app.Data.BackgroundStartIndex2 < 1
    app.Data.BackgroundStartIndex2 = 1;
end
%Find which of the signals to be plotted has the largest maximum
ylimMax = max(max(real(Processed.Signal)));
ylimMin = min(min(real(Processed.Signal)));
if ylimMax < max(max(real(app.Data.NonCorrectedIntegral)))
  ylimMax = max(max(real(app.Data.NonCorrectedIntegral)));
end
if ylimMin > min(min(real(app.Data.NonCorrectedIntegral)))
  ylimMin =  min(min(real(app.Data.NonCorrectedIntegral)));
end
if ylimMax < max(max(real(app.Data.PreProcessedSignal)))
  ylimMax = max(max(real(app.Data.PreProcessedSignal)));
end
if ylimMin > min(min(real(app.Data.PreProcessedSignal)))
  ylimMin =  min(min(real(app.Data.PreProcessedSignal)));
end
%Construct time axes for the signals
if  PlotWithZeroFilling
  TimeAxis1 = Processed.TimeAxis1(1:length(Processed.TimeAxis1));
  TimeAxis2 = Processed.TimeAxis2(1:length(Processed.TimeAxis2));
else
  TimeAxis1 = Processed.TimeAxis1(1:length(Processed.TimeAxis1)-str2double(app.ZeroFilling1.Value));
  TimeAxis2 = Processed.TimeAxis2(1:length(Processed.TimeAxis2)-str2double(app.ZeroFilling2.Value));
end
%Get current position of the slider
SliderPosition = round(app.t1_Slider.Value);

% Processed signal
%------------------------------------------------------------------------

if app.PlotProcessedSignal
  %Switch to change between t1 and t2 traces
  if app.ChangeSignalPlotDimension.Value
      ProcessedSignalTrace = Processed.Signal(SliderPosition,:);
    TimeAxis = TimeAxis2';
  else
      ProcessedSignalTrace = Processed.Signal(:,SliderPosition);
    TimeAxis = TimeAxis1';
  end
  if  PlotWithZeroFilling
    ProcessedSignalTrace = ProcessedSignalTrace(1:length(ProcessedSignalTrace));
  else
      if app.ChangeSignalPlotDimension.Value
    ProcessedSignalTrace = ProcessedSignalTrace(1:length(ProcessedSignalTrace)-str2double(app.ZeroFilling2.Value));
      else
        ProcessedSignalTrace = ProcessedSignalTrace(1:length(ProcessedSignalTrace)-str2double(app.ZeroFilling1.Value));
      end
  end
  
  ProcessedSignalTrace = ProcessedSignalTrace/max(max(real(Processed.Signal)));
  
%   ProcessedSignalTrace = ProcessedSignalTrace/max(max(abs(Processed.Signal)));
      if PlotImaginarySignal
        plot(app.signal_t1,TimeAxis,imag(ProcessedSignalTrace),'k','Linewidth',1)
      else
        plot(app.signal_t1,TimeAxis,real(ProcessedSignalTrace),'k','Linewidth',1)
      end
end

% First background correction 
%------------------------------------------------------------------------

if app.NonCorrectedTrace.Value
  
  %Check if the correction order has been inverted
  if app.InvertCorrection.Value
    if PlotImaginarySignal
      SignalTrace = imag(app.Data.NonCorrectedIntegral(SliderPosition,:));
      Background1Trace = imag(app.Data.Background1(SliderPosition,:));
    else
      SignalTrace = real(app.Data.NonCorrectedIntegral(SliderPosition,:));
      Background1Trace = real(app.Data.Background1(SliderPosition,:));
    end
  else
    if PlotImaginarySignal
      SignalTrace = imag(app.Data.NonCorrectedIntegral(:,SliderPosition));
      Background1Trace = imag(app.Data.Background1(:,SliderPosition));
    else
      SignalTrace = real(app.Data.NonCorrectedIntegral(:,SliderPosition));
      Background1Trace = real(app.Data.Background1(:,SliderPosition));
    end
  end
  
  %Rescale and zero-adjust the signal trace
      if PlotImaginarySignal
        Mean = mean(imag(app.Data.NonCorrectedIntegral(:,end)),'omitnan');
      else
        Mean = mean(real(app.Data.NonCorrectedIntegral(:,end)),'omitnan');
      end
  if isnan(Mean)
    Mean = 0;
  end
  SignalTrace = SignalTrace - Mean;
  SignalTrace = SignalTrace/max(max(real(app.Data.NonCorrectedIntegral)));

  
  %Construct axis and plot
  Axis = linspace(min(app.Data.CorrectedTimeAxis1),max(app.Data.CorrectedTimeAxis1),length(SignalTrace));
  plot(app.signal_t1,Axis,SignalTrace,PlotStyle,'MarkerSize',16,'Color',[0.2 0.2 0.9])
  hold(app.signal_t1,'on')
  
  %Rescale and zero-adjust the background trace
  Background1Trace = Background1Trace - Mean;
  Background1Trace = Background1Trace/max(max(real(app.Data.NonCorrectedIntegral)));

  %Construct axis and plot
  Axis = linspace(min(app.Data.CorrectedTimeAxis1),max(app.Data.CorrectedTimeAxis1),length(Background1Trace));
  plot(app.signal_t1,Axis,Background1Trace,'Color',[0.2 0.2 0.9],'LineStyle','--')
  hold(app.signal_t1,'on')
  
  %Set line and label with background fit start time
  XCoordinate = Axis(app.Data.BackgroundStartIndex1)*[1 1];
  YCoordinate = [0.9*ylimMin 1.1*ylimMax];
  line(app.signal_t1,XCoordinate,YCoordinate,'Color',[0.2 0.2 0.9],'LineStyle','--')
  text(app.signal_t1,1.1*Axis(app.Data.BackgroundStartIndex1),ylimMin,sprintf('%i ns',round(1000*Axis(app.Data.BackgroundStartIndex1),0)),'Color',[0.2 0.2 0.9]);
  hold(app.signal_t1,'on');
end

% Second background correction
%------------------------------------------------------------------------

if PlotSecondCorrection
  
  %Check if the correction order has been inverted
  if app.InvertCorrection.Value
    if PlotImaginarySignal
      SignalTrace = imag(app.Data.FirstBackgroundCorrected(:,SliderPosition));
      Background2Trace = imag(app.Data.Background2(:,SliderPosition));
    else
      SignalTrace = real(app.Data.FirstBackgroundCorrected(:,SliderPosition));
      Background2Trace = real(app.Data.Background2(:,SliderPosition));
    end
  else
    if PlotImaginarySignal
      SignalTrace = imag(app.Data.FirstBackgroundCorrected(SliderPosition,:));
      Background2Trace = imag(app.Data.Background2(SliderPosition,:));
    else
      SignalTrace = real(app.Data.FirstBackgroundCorrected(SliderPosition,:));
      Background2Trace = real(app.Data.Background2(SliderPosition,:));
    end
  end
  if PlotImaginarySignal
    Mean = mean(imag(app.Data.FirstBackgroundCorrected(end,:)),'omitnan');
  else
    Mean = mean(real(app.Data.FirstBackgroundCorrected(end,:)),'omitnan');
  end
  if isnan(Mean)
    Mean = 0;
  end
  
  %Rescale and zero-adjust the signal trace
  SignalTrace = SignalTrace - Mean;
  SignalTrace = SignalTrace/max(max(real(app.Data.FirstBackgroundCorrected)));
  
  %Construct axis and plot
  Axis = linspace(min(app.Data.CorrectedTimeAxis1),max(app.Data.CorrectedTimeAxis1),length(SignalTrace));
  plot(app.signal_t1,Axis,SignalTrace,PlotStyle,'MarkerSize',16,'Color',[0.6 0.0 0.8])
  hold(app.signal_t1,'on')
  
  %Rescale and zero-adjust the background trace
  Background2Trace = Background2Trace - Mean;
  Background2Trace = Background2Trace/max(max(real(app.Data.FirstBackgroundCorrected)));
  
  %Construct axis and plot
  Axis = linspace(min(app.Data.CorrectedTimeAxis1),max(app.Data.CorrectedTimeAxis1),length(Background2Trace));
  plot(app.signal_t1,Axis,Background2Trace,'Color',[0.6 0.0 0.8],'LineStyle','--')
  hold(app.signal_t1,'on')
  
  %Set line and label with background fit start time
  XCoordinate = Axis(app.Data.BackgroundStartIndex2)*[1 1];
  YCoordinate = [0.9*ylimMin 1.1*ylimMax];
  line(app.signal_t1,XCoordinate,YCoordinate,'Color',[0.6 0.0 0.8],'LineStyle','--')
  text(app.signal_t1,1.1*Axis(app.Data.BackgroundStartIndex2),ylimMax,sprintf('%i ns',round(1000*Axis(app.Data.BackgroundStartIndex2),0)),'Color',[0.6 0.0 0.8])
  hold(app.signal_t1,'on')
  
end

% Signal after background correction
%------------------------------------------------------------------------

if app.PreProcessedTrace.Value
  
  %Switch to change between t1 and t2 traces
  if app.ChangeSignalPlotDimension.Value
    if PlotImaginarySignal
      PreProcessedSignalTrace = imag(app.Data.PreProcessedSignal(SliderPosition,:));
    else
      PreProcessedSignalTrace = real(app.Data.PreProcessedSignal(SliderPosition,:));
    end
    PreProcessedSignalTrace(NUSgrid(SliderPosition,:)==0) = NaN;
  else
    if PlotImaginarySignal
      PreProcessedSignalTrace = imag(app.Data.PreProcessedSignal(:,SliderPosition));
    else
      PreProcessedSignalTrace = real(app.Data.PreProcessedSignal(:,SliderPosition));
    end
    PreProcessedSignalTrace(NUSgrid(:,SliderPosition)==0) = NaN;
  end
  
      if PlotImaginarySignal
        Mean = mean(imag(app.Data.PreProcessedSignal(end,:)),'omitnan');
      else
        Mean = mean(real(app.Data.PreProcessedSignal(end,:)),'omitnan');
      end
  
  %Rescale and zero-adjust the trace
  PreProcessedSignalTrace = PreProcessedSignalTrace - Mean;
  PreProcessedSignalTrace = PreProcessedSignalTrace/max(max(real(app.Data.PreProcessedSignal)));
  
  %Get axis for plot
  Axis = linspace(min(app.Data.CorrectedTimeAxis1),max(app.Data.CorrectedTimeAxis1),length(PreProcessedSignalTrace));
  
  %Plot and hold
  plot(app.signal_t1,Axis,PreProcessedSignalTrace,PlotStyle,'MarkerSize',16,'Color',[0.9 0.2 0.2])
  hold(app.signal_t1,'on')
  
end

% Apodization Window
%------------------------------------------------------------------------

if app.PlotApodizationWindow.Value
  
%   %Get window decay
    WindowDecay1 = str2double(app.WindowLength1.Value);
    WindowDecay2 = str2double(app.WindowLength2.Value);
    WindowMenuState = app.WindowType.Value;
    WindowType =  WindowMenuState;
  % switch WindowMenuState
  %   case 1
  %    WindowType =  'hamming';
  %   case 2
  %    WindowType =  'chebyshev';  
  %   case 3
  %    WindowType =  'welch';
  %   case 4
  %     WindowType = 'blackman'; 
  %   case 5
  %     WindowType = 'bartlett';
  %   case 6
  %     WindowType = 'connes';
  %   case 7
  %     WindowType = 'cosine';
  %   case 8
  %     WindowType = 'tukey25';
  %   case 9
  %     WindowType = 'tukey50';
  %   case 10
  %     WindowType = 'tukey75';
  %   case 11
  %     WindowType = 'hann';
  %   case 12
  %     WindowType = 'none';  
  % end

  [~,Window1,Window2] = apodizationWin(Processed.Signal,WindowType,WindowDecay1,WindowDecay2);
    if ~app.ChangeSignalPlotDimension.Value
      Window = Window1;
      WindowDecay = WindowDecay1;
      TimeAxis = TimeAxis1;
    else
      Window = Window2;
      WindowDecay = WindowDecay2;
      TimeAxis = TimeAxis2;
    end
  
  %Adjust window to current axis
  Window = ylimMax*Window/max(Window);
  if WindowDecay>=length(TimeAxis)
    Window=Window(1:length(TimeAxis));
  end
  if WindowDecay<length(TimeAxis)
    if iscolumn(Window)
      Window = Window';
    end
    Window=[Window Window(end)+zeros(1,length(TimeAxis)-WindowDecay)];
  end
  %Plot and hold
  plot(app.signal_t1,TimeAxis,Window,'Color',[0.1 0.7 0.1])
  hold(app.signal_t1,'on')
  
end

% Format axes accordingly
%------------------------------------------------------------------------

%Set axes limits
set(app.signal_t1,'ytick',[],'ylim',[0.9*ylimMin 1.1*ylimMax],'xlim',[min(TimeAxis1) max(TimeAxis1)])

%Format axis labels and trace information according to current dimension
if app.ChangeSignalPlotDimension.Value
  set(app.signal_t1,'xlim',[min(TimeAxis2) max(TimeAxis2)])
  try
    %Try to use 1 digit after comma
    set(app.signal_t1,'XTick',round(linspace(TimeAxis2(1),TimeAxis2(end),10),1))
  catch
    %If not possible use 2 digits
    set(app.signal_t1,'XTick',round(linspace(TimeAxis2(1),TimeAxis2(end),10),2))
  end
  xlabel(app.signal_t1,'t_2 [\mus]','FontSize',8);
  set(app.trace2Info,'Text',sprintf('Trace along t2 at t1 = %.f ns',round(1000*Processed.TimeAxis1(SliderPosition),1)))
else
  set(app.signal_t1,'xlim',[min(TimeAxis1) max(TimeAxis1)])
  try
    %Try to use 1 digit after comma
    set(app.signal_t1,'xtick',round(linspace(TimeAxis1(1),TimeAxis1(end),10),1))
  catch
    %If not possible use 2 digits
    set(app.signal_t1,'xtick',round(linspace(TimeAxis1(1),TimeAxis1(end),10),2))
  end
  xlabel(app.signal_t1,'t_1 [\mus]','FontSize',8);
  app.trace2Info.Text = sprintf('Trace along t1 at t2 = %.f ns',round(1000*Processed.TimeAxis2(SliderPosition),1));
end
app.signal_t1.FontSize = 8;

%Stop holding
hold(app.signal_t1,'off')

