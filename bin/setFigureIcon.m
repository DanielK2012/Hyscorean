function setFigureIcon(figHandle)

% Check if javaframe is supported (pre-R2025a)
jFrameWarning = 'MATLAB:ui:javaframe:PropertyToBeRemoved';
warning('off',jFrameWarning);
try
  jFrame = get(figHandle,'javaFrame');  %#ok
catch
  jFrame = [];
end
warning('on',jFrameWarning);

% Use javaframe to set figure icon
if ~isempty(jFrame)
    Path =  fileparts(which('Hyscorean'));
    iconFile = fullfile(Path, 'bin', 'logo.png');
    jicon = javax.swing.ImageIcon(iconFile);
    jFrame.setFigureIcon(jicon);
else
  % not possible to set figure icon (would work for uifigure)
end

end
