classdef Hyscorean_saveSettings < matlab.apps.AppBase
%==========================================================================
% Hyscorean_saveSettings
%==========================================================================
% App Designer style dialog replacing the old GUIDE Hyscorean_saveSettings GUI.
%
% Usage from main app:
%   dlg = Hyscorean_saveSettings(app.SaveHyscoreanSettings, dlgPos);
%   uiwait(dlg.UIFigure);
%   if isvalid(dlg) && dlg.Accepted
%       app.SaveHyscoreanSettings = dlg.SaverSettings;
%   end
%   if isvalid(dlg), delete(dlg); end
%==========================================================================
%
% Copyright (C) 2019  Luis Fabregas, Hyscorean 2019
% Copyright (C) 2026  Daniel Klose,  Hyscorean 2026
%
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License 3.0 as published by
% the Free Software Foundation.
%==========================================================================


    % Public UI properties
    properties (Access = public)
        UIFigure            matlab.ui.Figure
        GridLayout          matlab.ui.container.GridLayout
        HeaderLabel         matlab.ui.control.Label
        SavePathLabel       matlab.ui.control.Label
        SavePath            matlab.ui.control.EditField
        UILoad_Button       matlab.ui.control.Button
        IdentifierLabel     matlab.ui.control.Label
        Identifier          matlab.ui.control.EditField
        ButtonGrid          matlab.ui.container.GridLayout
        SetButton           matlab.ui.control.Button
        CancelButton        matlab.ui.control.Button
    end

    % Dialog state / data exchange with main app
    properties (Access = public)
        SaverSettings = struct('IdentifierName', 'Hyscorean')
        Accepted = false
    end

    methods (Access = public)

        % Construct app
        function app = Hyscorean_saveSettings(varargin)
    
            % Create UIFigure and components
            createComponents(app)
    
            % Register app
            registerApp(app, app.UIFigure)
    
            % Run startup with all incoming constructor arguments
            runStartupFcn(app, @(app)startupFcn(app, varargin{:}))
    
            if nargout == 0
                clear app
            end
        end
    
        function delete(app)
            if ~isempty(app.UIFigure) && isvalid(app.UIFigure)
                delete(app.UIFigure)
            end
        end
    end

    methods (Access = private)

        function startupFcn(app, initialSettings, dlgPos)
            % Initialize state passed from main app.
            if nargin >= 2 && ~isempty(initialSettings)
                app.SaverSettings = initialSettings;
            end

            % Apply requested position after components exist.
            if nargin >= 3 && ~isempty(dlgPos) && isnumeric(dlgPos) && numel(dlgPos) == 4
                app.UIFigure.Position = dlgPos;
            end

            % Initialize save path from preferences.
            savePath = getpref('hyscorean', 'savepath', pwd);
            app.SavePath.Value = char(savePath);

            % Initialize identifier from incoming settings.
            if isfield(app.SaverSettings, 'IdentifierName') && ~isempty(app.SaverSettings.IdentifierName)
                app.Identifier.Value = char(app.SaverSettings.IdentifierName);
            else
                app.Identifier.Value = 'Hyscorean';
                app.SaverSettings.IdentifierName = app.Identifier.Value;
            end

            % Optional: if you have rewritten setFigureIcon for UIFigure, enable this.
            % setFigureIcon(app);
        end

        function IdentifierValueChanged(app, ~)
            % Keep struct synchronized with current identifier text.
            app.SaverSettings.IdentifierName = char(app.Identifier.Value);
        end

        function UILoad_ButtonPushed(app, ~)
            % Let user choose a directory from the OS dialog.
            currentPath = app.SavePath.Value;
            selpath = uigetdir(currentPath, 'Select default save folder');
            if isequal(selpath, 0)
                return
            end
            app.SavePath.Value = selpath;
        end

        function SetButtonPushed(app, ~)
            % Validate and optionally persist the save path preference,
            % then return updated settings to the caller.
            defaultSavePath = char(getpref('hyscorean', 'savepath', pwd));
            savePath = strtrim(char(app.SavePath.Value));

            if isempty(savePath)
                uialert(app.UIFigure, 'Please enter a valid save path.', 'Hyscorean', 'Icon', 'error');
                return
            end

            % If path changed, validate it and ask whether to save as new default.
            if ~strcmp(defaultSavePath, savePath)

                if ~isfolder(savePath)
                    choice = uiconfirm(app.UIFigure, ...
                        ['The folder given as default path does not exist. ', ...
                         'Do you want to create it? Otherwise the previous default path will be restored.'], ...
                        'Hyscorean', ...
                        'Options', {'Yes','No'}, ...
                        'DefaultOption', 1, ...
                        'CancelOption', 2, ...
                        'Icon', 'warning');

                    if strcmp(choice, 'Yes')
                        try
                            mkdir(savePath);
                        catch ME
                            uialert(app.UIFigure, ...
                                sprintf('Could not create the folder:\n%s\n\n%s', savePath, ME.message), ...
                                'Hyscorean', 'Icon', 'error');
                            return
                        end
                    else
                        app.SavePath.Value = defaultSavePath;
                        return
                    end
                end

                choice = uiconfirm(app.UIFigure, ...
                    ['The default save path has been modified and will now be saved for further sessions. ', ...
                     'Do you want to overwrite the previous default path?'], ...
                    'Hyscorean', ...
                    'Options', {'Yes','No'}, ...
                    'DefaultOption', 1, ...
                    'CancelOption', 2, ...
                    'Icon', 'question');

                if strcmp(choice, 'Yes')
                    setpref('hyscorean', 'savepath', savePath);
                end
            end

            % Return latest identifier value.
            app.SaverSettings.IdentifierName = char(app.Identifier.Value);

            app.Accepted = true;
            uiresume(app.UIFigure);
            app.UIFigure.Visible = 'off';
        end

        function CancelButtonPushed(app, ~)
            % Close without applying edits.
            app.Accepted = false;
            uiresume(app.UIFigure);
            app.UIFigure.Visible = 'off';
        end

        function UIFigureCloseRequest(app, ~)
            % Closing the dialog is equivalent to Cancel.
            app.Accepted = false;
            uiresume(app.UIFigure);
            app.UIFigure.Visible = 'off';
        end
    
        function createComponents(app)
            % Create UIFigure and hide until all components are ready.
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Name = 'Hyscorean Save Settings';
            app.UIFigure.Position = [100 100 451 177];
            app.UIFigure.Resize = 'off';
            app.UIFigure.CloseRequestFcn = createCallbackFcn(app, @UIFigureCloseRequest, true);
            try
                app.UIFigure.WindowStyle = 'modal';
            catch
                % Leave as normal figure if modal style is unavailable.
            end
    
            % Main layout.
            app.GridLayout = uigridlayout(app.UIFigure, [4 3]);
            app.GridLayout.RowHeight = {26, 28, 28, 36};
            app.GridLayout.ColumnWidth = {90, '1x', 90};
            app.GridLayout.Padding = [12 12 12 12];
            app.GridLayout.RowSpacing = 10;
            app.GridLayout.ColumnSpacing = 10;
    
            % Header / short explanation.
            app.HeaderLabel = uilabel(app.GridLayout);
            app.HeaderLabel.Text = 'Default path and identifier used by Save & Report';
            app.HeaderLabel.FontWeight = 'bold';
            app.HeaderLabel.Layout.Row = 1;
            app.HeaderLabel.Layout.Column = [1 3];
    
            % Save path label.
            app.SavePathLabel = uilabel(app.GridLayout);
            app.SavePathLabel.Text = 'Save Path';
            app.SavePathLabel.HorizontalAlignment = 'right';
            app.SavePathLabel.Layout.Row = 2;
            app.SavePathLabel.Layout.Column = 1;
    
            % Save path edit field. Exact old component name preserved: SavePath
            app.SavePath = uieditfield(app.GridLayout, 'text');
            app.SavePath.Layout.Row = 2;
            app.SavePath.Layout.Column = 2;
            app.SavePath.Tooltip = 'Default folder used when saving data and reports.';
    
            % Browse button. Exact old component name preserved: UILoad_Button
            app.UILoad_Button = uibutton(app.GridLayout, 'push');
            app.UILoad_Button.Text = 'Browse...';
            app.UILoad_Button.Layout.Row = 2;
            app.UILoad_Button.Layout.Column = 3;
            app.UILoad_Button.ButtonPushedFcn = createCallbackFcn(app, @UILoad_ButtonPushed, true);
    
            % Identifier label.
            app.IdentifierLabel = uilabel(app.GridLayout);
            app.IdentifierLabel.Text = 'Identifier';
            app.IdentifierLabel.HorizontalAlignment = 'right';
            app.IdentifierLabel.Layout.Row = 3;
            app.IdentifierLabel.Layout.Column = 1;
    
            % Identifier edit field. Exact old component name preserved: Identifier
            app.Identifier = uieditfield(app.GridLayout, 'text');
            app.Identifier.Layout.Row = 3;
            app.Identifier.Layout.Column = [2 3];
            app.Identifier.Tooltip = 'Text appended to saved output files.';
            app.Identifier.ValueChangedFcn = createCallbackFcn(app, @IdentifierValueChanged, true);
    
            % Button row.
            app.ButtonGrid = uigridlayout(app.GridLayout, [1 3]);
            app.ButtonGrid.Layout.Row = 4;
            app.ButtonGrid.Layout.Column = [1 3];
            app.ButtonGrid.ColumnWidth = {'1x', 90, 90};
            app.ButtonGrid.RowHeight = {28};
            app.ButtonGrid.Padding = [0 0 0 0];
            app.ButtonGrid.ColumnSpacing = 8;
    
            % Set button (old GUIDE callback name was Set_Callback).
            app.SetButton = uibutton(app.ButtonGrid, 'push');
            app.SetButton.Text = 'Set';
            app.SetButton.Layout.Row = 1;
            app.SetButton.Layout.Column = 2;
            app.SetButton.ButtonPushedFcn = createCallbackFcn(app, @SetButtonPushed, true);
    
            % Cancel button.
            app.CancelButton = uibutton(app.ButtonGrid, 'push');
            app.CancelButton.Text = 'Cancel';
            app.CancelButton.Layout.Row = 1;
            app.CancelButton.Layout.Column = 3;
            app.CancelButton.ButtonPushedFcn = createCallbackFcn(app, @CancelButtonPushed, true);
    
            % Show only after all components are ready.
            app.UIFigure.Visible = 'on';
        end
    end    
end
