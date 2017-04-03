classdef intensitygram < d12pack.report
    %INTENSITYGRAM Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Axes
        SubAxes
    end
    
    methods
        function obj = intensitygram(varargin)
            obj@d12pack.report;
            obj.Type = 'Intensity Report';
                    
            if nargin == 0
                return
            else
                DateTime = varargin{1};
                Value = varargin{2};
                Value = Value/max(Value);
                Title = varargin{3};
                Dates = dateshift(DateTime(1),'start','day'):dateshift(DateTime(end),'start','day');
                nDates = numel(Dates);
                nPages = ceil(nDates/10);
            end
            
            obj.Figure.NumberTitle = 'off';
            obj.Figure.Name = sprintf('Page %i of %i',1,nPages);
            obj.Title = Title;
            
            if nPages > 1
                for iPage = 2:nPages
                    obj(iPage,1) = d12pack.intensitygram;
                    obj(iPage,1).Figure.NumberTitle = 'off';
                    obj(iPage,1).Figure.Name = sprintf('Page %i of %i',iPage,nPages);
                    obj(iPage,1).PageNumber = [iPage,nPages];
                    obj(iPage,1).Title = Title;
                end
            end
            
            if exist('DateTime','var') == 1
                iDate = nDates;
                for iPage = nPages:-1:1
                    figure(obj(iPage,1).Figure);
                    obj(iPage,1).initAxes;
%                     obj(iPage,1).initLegend;
                    
                    while iDate > (iPage-1)*10
                        if iDate > 0
                            % Select the axes that will be plotted to
                            iAx = mod(iDate,10);
                            if iAx == 0
                                iAx = 10;
                            end
                            
                            idxDate = DateTime >= Dates(iDate) & DateTime < Dates(iDate) + caldays(1);
                            idx  = idxDate;
                            DateTimeTemp = DateTime(idx);
                            ValueTemp = Value(idx);
                            
                            obj(iPage,1).plotDay(...
                                obj(iPage,1).Axes(iAx),...
                                DateTimeTemp,...
                                ValueTemp);
                        end
                        iDate = iDate - 1;
                    end % End of while
                end % End of for
            end % End of if
        end % End of class constructor
        
        %% initAxes creates 10 axes to plot on
        function obj = initAxes(obj)
            x = 36;
            w = obj.Body.Position(3) - x - 36;
            h = floor((obj.Body.Position(4) - 72)/10);
            
            obj.Axes = gobjects(10,1);
            obj.SubAxes = gobjects(10,1);
            for iAx = 1:10
                y = obj.Body.Position(4) - iAx*h;
                
                obj.Axes(iAx) = axes(obj.Body);
                obj.Axes(iAx).Units = 'pixels';
                obj.Axes(iAx).Position = [x,y,w,h];
                
                obj.Axes(iAx).TickLength = [0,0];
                obj.Axes(iAx).YLimMode = 'manual';
                obj.Axes(iAx).YLim = [0,1];
                obj.Axes(iAx).YTick = .25:.25:.75;
                obj.Axes(iAx).YTickLabel = {'25%','50%','75%'};
                obj.Axes(iAx).YGrid = 'on';
                obj.Axes(iAx).XLimMode = 'manual';
                obj.Axes(iAx).XLim = [0,24];
                obj.Axes(iAx).XTick = 0:2:24;
                obj.Axes(iAx).XTickLabel = '';
                obj.Axes(iAx).XGrid = 'on';
                obj.Axes(iAx).Color = 'none';
                
            end
            obj.Axes(10).XTickLabel = obj.Axes(10).XTick;
            hLabel = xlabel(obj.Axes(10),'Time of Day (hours)');
            
            % Box in the plots
            hBoxAxes = axes(obj.Body);
            hBoxAxes.Units = 'pixels';
            hBoxAxes.Position = [x, y, w, h*10];
            hBoxAxes.XLimMode = 'manual';
            hBoxAxes.XLim = [0,1];
            hBoxAxes.YLimMode = 'manual';
            hBoxAxes.YLim = [0,1];
            xBox = [0,1,1,0,0];
            yBox = [0,0,1,1,0];
            hBox = plot(hBoxAxes,xBox,yBox);
            hBox.Color = 'black';
            hBox.LineWidth = 0.5;
            hBoxAxes.Visible = 'off';
        end % End of initAxes
        
        %% Legend
        function initLegend(obj)
            x = 36;
            y = 0;
            w = 468;
            h = 40;
            
            hLegendAxes = axes(obj.Body); % Make a new axes for logo
            hLegendAxes.Visible = 'off'; % Set axes visibility
            hLegendAxes.Units = 'pixels';
            hLegendAxes.Position = [x,y,w,h];
            hLegendAxes.XLimMode = 'manual';
            hLegendAxes.XLim = [0,468];
            hLegendAxes.YLimMode = 'manual';
            hLegendAxes.YLim = [0,36];
            
            w = 13;
            h = 10;
            
            a = 17;
            b = 2;
            
            a2 = 17;
            b2 = -3;
            
            blue   = [180, 211, 227]/255; % circadian stimulus
            grey   = [226, 226, 226]/255; % excluded data
            red    = [255, 215, 215]/255; % error
            yellow = [255, 255, 191]/255; % noncompliance
            purple = [186, 141, 186]/255; % in bed
            green  = [124, 197, 118]/255; % at work
            
            % Circadian Stimulus
            x = 6;
            y = 25;
            dim = [x,y,w,h];
            hRec = rectangle(hLegendAxes,'Position',dim,'FaceColor',blue);
            hTxt = text(hLegendAxes,x+a,y+b,'Intensity');
            hTxt.VerticalAlignment = 'baseline';
            hTxt.FontName = 'Arial';
            hTxt.FontSize = 8;
            
        end % End of initLegend
        
    end
    
    methods (Static)
        %%
        function plotDay(hAxes,DateTime,Value)
            hold(hAxes,'on');
            
            Hours = hours(timeofday(DateTime));
            
            % Plot and format Circadian Stimulus
            hCS = plot(hAxes,Hours,Value);
            hCS.Color = [1, 33, 105]/255;
            hCS.DisplayName = 'Intensity';
            
            % Add Date label
            hDate = ylabel(hAxes,datestr(DateTime(1),'yyyy\nmmm dd'));
            hDate.Position(1) = 24;
            hDate.Rotation = 90;
            hDate.HorizontalAlignment = 'center';
            hDate.VerticalAlignment = 'top';
            hDate.FontSize = 8;
            
            hold(hAxes,'off');
        end
    end
    
end

