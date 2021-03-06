function Background = fitBackground2D(Data,options,StartIndex)
%
% Fits background decay according to the model selected by
% options.model along dimension options.dim starting at data point
% options.start
%
% options   specifies the background model and background fit parameters
%  .BackgroundModel   0  fractal, n variable,  exp(-k*t^(n/3))
%                     1  n-dimensional, n fixed, exp(-k*t^(n/3))
%                     2  Polynomial
%                     3  Exponential (polynomial fitted to logarithm)
% 
% the following options need to be defined only if the corresponding 
% model is requested
%   .homdim     fractal dimension for homogeneous distribution (model 1)
%   .PolynomialOrder      order of polynomial (model 3)
%
% output:
% 
% Background      background matrix with same dimensions as data
%
% adapted from G. Jeschke by L. Fabregas, 2018

% Initiallize
%------------------------------------------------------------------------
Background = zeros(size(Data));
%Check which dimension has to be corrected and adjust matrices
if isfield(options,'Dimension') && options.Dimension == 1
    Data = Data.';
    Background = Background.'; 
end;
%Add this additional input form to allow it to be used inside parfor loops
if nargin>2
  options.start = StartIndex;
end
[Dimension1,Dimension2] = size(Data);
SolverOptions = optimset('MaxFunEvals',10000,'Display','off');
Offset = 1000;
% Fit Background
%------------------------------------------------------------------------
for Index = 1:Dimension1
    Time2Fit = options.start:Dimension2;
    Time2Extrapolate = 1:Dimension2;
    %Add offset to be able to fit stretched exponential functions directly
    Data2Fit = Offset + Data(Index,options.start:end);
    NaNValid = ~isnan(Data2Fit); % Get indices where Data2Fit is valid (non NaN)
    PolynomialFit = polyfit_hyscorean(Time2Fit,log(Data2Fit),1); % linear fit of logarithm
    switch options.BackgroundModel
        case 0
            v0=[-PolynomialFit(1) Offset 3];
            v0 = real(v0);
            Minimizer = @(v)rms_stretched_private(real(v),Time2Fit(NaNValid),Data2Fit(NaNValid));
            v1 = fminsearch(Minimizer,v0,SolverOptions);
            BackgroundTrace =decaynD_private(v1(1:2),Time2Extrapolate,v1(3));
%             figure(3),clf,plot(BackgroundTrace),hold on,plot(Data2Fit(NaNValid)),drawnow
        case 1
            v0=[abs(PolynomialFit(1)) Offset];
            Minimizer = @(v)rms_stretched_private(v,Time2Fit(NaNValid),Data2Fit(NaNValid),options.homdim);
            v1 = fminsearch(Minimizer,v0,SolverOptions);
            BackgroundTrace =decaynD_private(v1(1:2),Time2Extrapolate,options.homdim);
        case 2 %Polynomial fit
            PolynomialFit = polyfit_hyscorean(Time2Fit(NaNValid),Data2Fit(NaNValid),options.PolynomialOrder);
            BackgroundTrace = polyval(PolynomialFit,Time2Extrapolate);             
        case 3 %Exponential fit (Polynomial of logarithm)
            PolynomialFit = polyfit_hyscorean(Time2Fit(NaNValid),log(Data2Fit(NaNValid)),options.PolynomialOrder);
            BackgroundTrace = exp(polyval(PolynomialFit,Time2Extrapolate));
    end;
    Background(Index,:) = BackgroundTrace - Offset;

end;
%Prepare background for output
Background=real(Background);
if isfield(options,'Dimension') && options.Dimension == 1
    Background = Background.';
end;

function rms = rms_stretched_private(v,x,y,homdim)
%RMS_streched	Root mean square error of function exp(-k*t^ksi).
%	rms = rms_stretched(v,x,y).
%	
%  Parameter: v(2) Amplitude, v(1) Zeitkonstante, v(3) ksi

%	Copyright (c) 2004 by Gunnar Jeschke

if v(1)<0, rms=1.0e6; return; end;
if length(v) > 2
    homdim = v(3);
end;
v = real(v);
sim = decaynD_private(v(1:2),x,homdim);
rms = norm(sim-y);

function sim=decaynD_private(v,x,hom_dim)
%
%

sim=real(v(2)*exp(-(v(1)*x).^(hom_dim/3)));
