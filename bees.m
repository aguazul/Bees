function bees()
% BEES: Launches a GUI simulation that is used to model the foraging behavior of bees.
%   (note that no arguments are required because all input is controlled through the GUI.)
%
%   START/PAUSE/CONTINUE Button
%   When this button is in the START stage you can set up the simulation to begin with
%   a certain number of bees, flowers, and flower types.  The number of bees and flowers
%   cannot be changed once a simulation begins, although the number of flower types and
%   nutrition values can.  Clicking START will start the simulation.  You can pause the
%   simulation at anytime by clicking PAUSE and restart it by clicking CONTINUE.
%
%   TURBO MODE
%   Check the TURBO MODE checkbox if you simply want to crunch data in the background
%   without seeing the fancy animations of the bees.  This is useful to quickly proceed
%   through many flower visits in a short amount of time.  Please note that the simulation
%   will still occasionally update the graphics so that it is clear that the simulation
%   is still running.  Unchecking the TURBO MODE checkbox will return the simulation to
%   regular graphics mode.
%
%   BEE CONTROLS
%   1) Number of Bees: Change this to any value from 1 to 100 before starting the simulation
%   2) Speed: Changes the speed of the bees.  Values from 0 to 100 are allowed.  Use this to
%       quickly proceed through many visits by increasing speed or slow the bees (or even stop)
%       so that they are easier to see and click on.
%   3) Learning Rate: The Rescorla-Wagner rule makes use of the learning rate variable to
%       determine how quickly bees associate a flowers nutrition value with its color.
%       This can be changed in real-time to make the bees learn faster or slower.
%   4) Length of Stay: Flowers have a fixed amount of nectar and will die when all of the nectar
%       has been consumed by the bees.  This variable determines how much nectar a bee will
%       consume during each visit to a flower.  By increasing this variable bees stay longer
%       (thus consuming more nectar) at each flower.  Decreasing this variable has the opposite
%       effect.  This variable can be changed in real-time.
%
%   FLOWER CONTROLS
%   1) Number of Flowers: Change this to any value from 2 to 12 before starting the simulation
%   2) Flower Types: Changes the number of flower types in the simulation, which can be between
%       2 and 10.  This variable can be changed in real-time.  Changing this variable will
%       cause the appropriate nutritional values edit boxes to be displayed or hidden.  The
%       simulation always attempts to have at least 2 of each flower type if possible.
%   3) Nutritional Values: Allows you to change the nutrition value of each flower type/color.
%       These variables can be changed in real-time thus allowing you to change which flower
%       color is most nutritious at any time during the simulation.
%
%   BEE SPEECH BUBBLE - Clicking on a bee displays the following information:
%   1) Desire: Shows which flower types the selected bee likes the most
%   2) History: Shows the last 10 flower types/colors that the selected bee has visited
%   3) Graph: Clicking the graph shows the entire history of the selected bee in line-graph
%       format.  Also note the Beta value is shown here for the selected bee and can be changed.

% THEORY OF THE SIMULATION/MODEL
%   The following simulation was based on work by Narendra & Thatachar (1989) and Williams(1992)
%   The model uses the Rescorla-Wagner rule as the algorithm for learning.
%
%   The equations used are:
%   m(b) --> m(b) + E*delta  with delta = r(b) - m(b)
%   
%   P[a] = exp(beta*M(a))/sum(exp(beta*M(a)))

% figure f is the main GUI where the bees and flowers are displayed
f = figure('Visible', 'on', 'Name', 'Reinforcement Learning of Bees', 'Position', [35 35 950 650]);
hStartStop = uicontrol('Style', 'pushbutton', 'String', 'Start', 'ForegroundColor', [0 .5 0], 'FontWeight', 'bold', 'Callback', {@hStartStop_Callback}, 'Position', [855 600 80 40]);
hflowertxt = uicontrol('Style', 'text', 'String', 'Flower Types', 'BackgroundColor', [.8 .8 .8], 'HorizontalAlignment', 'left', 'Position', [845 510 75 14]);
hflowertypes = uicontrol('Style', 'slider', 'Min', 2, 'Max', 10, 'Value', 2, 'SliderStep', [.12 .12], 'Callback', {@hflowertypes_Callback}, 'Position', [845 495 101 10]);
hflowerdisp = uicontrol('Style', 'text', 'String', get(hflowertypes, 'value'), 'BackgroundColor', [.8 .8 .8], 'Position', [920 510 25 16]);

% FLOWER GUI CONTROLS
hflower = uicontrol ('Style', 'text', 'String', 'FLOWER', 'FontWeight', 'bold', 'BackgroundColor', [.8 .8 .8], 'Position', [855 580 80 14]);
hflower2 = uicontrol ('Style', 'text', 'String', 'CONTROLS', 'FontWeight', 'bold', 'BackgroundColor', [.8 .8 .8], 'Position', [855 570 80 14]);
hnoflowerstxt = uicontrol('Style', 'text', 'String', 'No. flowers', 'BackgroundColor', [.8 .8 .8], 'HorizontalAlignment', 'left', 'Position', [845 550 75 14]);
hnoflowersdisp = uicontrol('Style', 'slider', 'Min', 2, 'Max', 12, 'Value', 10, 'SliderStep', [.1 .1], 'Callback', {@hnoflowersdisp_Callback}, 'Position', [845 535 101 10]);
hnoflowerstypes = uicontrol('Style', 'text', 'String', get(hnoflowersdisp, 'value'), 'BackgroundColor', [.8 .8 .8], 'Position', [921 550 25 16]);
hnutrition = uicontrol ('Style', 'text', 'String', 'Nutritional Values', 'HorizontalAlignment', 'left', 'BackgroundColor', [.8 .8 .8], 'Position', [845 470 150 14]);
hnutrition1txt = uicontrol('Style', 'text', 'String', 'Yellow', 'BackgroundColor', [1 1 0], 'Position', [845 450 80 14]);
hnutrition1disp = uicontrol('Style', 'edit', 'String', 2, 'Callback', {@hnutrition_Callback}, 'Position', [920,450,30,16]);
hnutrition2txt = uicontrol('Style', 'text', 'String', 'Blue', 'BackgroundColor', [0 0 1], 'ForegroundColor', [1 1 1], 'Position', [845 430 80 14]);
hnutrition2disp = uicontrol('Style', 'edit', 'String', 1, 'Callback', {@hnutrition_Callback}, 'Position', [920 430 30 16]);
hnutrition3txt = uicontrol('Style', 'text', 'String', 'Red', 'BackgroundColor', [1 0 0], 'Position', [845 410 80 14], 'Visible', 'off');
hnutrition3disp = uicontrol('Style', 'edit', 'String', 1, 'Callback', {@hnutrition_Callback}, 'Position', [920 410 30 16], 'Visible', 'off');
hnutrition4txt = uicontrol('Style', 'text', 'String', 'Lime', 'BackgroundColor', [.5 1 0], 'Position', [845 390 80 14], 'Visible', 'off');
hnutrition4disp = uicontrol('Style', 'edit', 'String', 1, 'Callback', {@hnutrition_Callback}, 'Position', [920 390 30 16], 'Visible', 'off');
hnutrition5txt = uicontrol('Style', 'text', 'String', 'Green', 'BackgroundColor', [.3 .7 0], 'Position', [845 370 80 14], 'Visible', 'off');
hnutrition5disp = uicontrol('Style', 'edit', 'String', 1, 'Callback', {@hnutrition_Callback}, 'Position', [920 370 30 16], 'Visible', 'off');
hnutrition6txt = uicontrol('Style', 'text', 'String', 'Aqua', 'BackgroundColor', [0 1 1], 'Position', [845 350 80 14], 'Visible', 'off');
hnutrition6disp = uicontrol('Style', 'edit', 'String', 1, 'Callback', {@hnutrition_Callback}, 'Position', [920 350 30 16], 'Visible', 'off');
hnutrition7txt = uicontrol('Style', 'text', 'String', 'Orange', 'BackgroundColor', [1 .6 0], 'Position', [845 330 80 14], 'Visible', 'off');
hnutrition7disp = uicontrol('Style', 'edit', 'String', 1, 'Callback', {@hnutrition_Callback}, 'Position', [920 330 30 16], 'Visible', 'off');
hnutrition8txt = uicontrol('Style', 'text', 'String', 'Plum', 'BackgroundColor', [.5 0 1], 'ForegroundColor', [1 1 1], 'Position', [845 310 80 14], 'Visible', 'off');
hnutrition8disp = uicontrol('Style', 'edit', 'String', 1, 'Callback', {@hnutrition_Callback}, 'Position', [920 310 30 16], 'Visible', 'off');
hnutrition9txt = uicontrol('Style', 'text', 'String', 'Purple', 'BackgroundColor', [.7 .2 1], 'Position', [845 290 80 14], 'Visible', 'off');
hnutrition9disp = uicontrol('Style', 'edit', 'String', 1, 'Callback', {@hnutrition_Callback}, 'Position', [920 290 30 16], 'Visible', 'off');
hnutrition10txt = uicontrol('Style', 'text', 'String', 'Pink', 'BackgroundColor', [1 0 1], 'Position', [845 270 80 14], 'Visible', 'off');
hnutrition10disp = uicontrol('Style', 'edit', 'String', 1, 'Callback', {@hnutrition_Callback}, 'Position', [920 270 30 16], 'Visible', 'off');

% BEE GUI CONTROLS
hbee = uicontrol ('Style', 'text', 'String', 'BEE CONTROLS', 'BackgroundColor', [.8 .8 .8], 'FontWeight', 'bold', 'Position', [5 610 82 14]);
hnobeestxt = uicontrol('Style', 'text', 'String', 'Number of Bees', 'BackgroundColor', [.8 .8 .8], 'HorizontalAlignment', 'left', 'Position', [100 610 100 14]);
hnobeesdisp = uicontrol('Style', 'slider', 'Min', 1, 'Max', 100, 'Value', 5, 'SliderStep', [.01 .01], 'Callback', {@hnobeesdisp_Callback}, 'Position', [100 595 135 10]);
hnobeestypes = uicontrol('Style', 'text', 'String', get(hnobeesdisp, 'value'), 'BackgroundColor', [.8 .8 .8], 'Position', [209 608 35 16]);
hspeedtxt = uicontrol('Style', 'text', 'String', 'Speed', 'HorizontalAlignment', 'left', 'BackgroundColor', [.8 .8 .8], 'Position', [260 610 100 14]);
hspeeddisp = uicontrol('Style', 'slider', 'Min',0, 'Max', 100, 'Value', 10, 'SliderStep', [.01 .01], 'Callback', {@hspeeddisp_Callback}, 'Position', [260 595 135 10]);
hspeedtypes = uicontrol('Style', 'text', 'String', get(hspeeddisp, 'value'), 'BackgroundColor', [.8 .8 .8], 'Position', [369 608 35 16]);
hepsilontxt = uicontrol('Style', 'text', 'String', 'Learning Rate', 'HorizontalAlignment', 'left', 'BackgroundColor', [.8 .8 .8], 'Position', [420 610 100 14]);
hepsilondisp = uicontrol('Style', 'slider', 'Min',0, 'Max', 1, 'Value',.25, 'SliderStep', [.01 .01], 'Callback', {@hepsilondisp_Callback}, 'Position', [420 595 135 10]);
hepsilontypes = uicontrol('Style', 'text', 'String', get(hepsilondisp, 'value'), 'BackgroundColor', [.8 .8 .8], 'Position', [521 608 35 16]);
hlosttxt = uicontrol('Style', 'text', 'String', 'Length of Stay', 'HorizontalAlignment', 'left', 'BackgroundColor', [.8 .8 .8], 'Position', [580 610 100 14]);
hlostdisp = uicontrol('Style', 'slider', 'Min', 1, 'Max', 500, 'Value', 50, 'SliderStep', [.01 .01], 'Callback', {@hlostdisp_Callback}, 'Position', [580 595 135 10]);
hlosttypes = uicontrol('Style', 'text', 'String', get(hlostdisp, 'value'), 'BackgroundColor', [.8 .8 .8], 'Position', [689 608 35 16]);
hturbomode = uicontrol('Style', 'checkbox', 'String', 'Turbo Mode', 'FontWeight', 'bold', 'BackgroundColor', [.8 .8 .8], 'Position', [740 600 100 40]);

ha = axes('Units', 'pixels', 'xLim', [-500 500], 'yLim', [-500 500], 'zLim', [-500 500], 'Visible', 'off', 'color', 'none', 'Position', [40 40 800 550]);
hold on

% LOAD AND DRAW GRASS
[loadC loadM loadA] = imread('grass.png', 'png');
grass = image(loadC, 'Parent', ha);
set(grass, 'XData', [-500 500], 'YData', [-500 500]);

% LOAD RATIO BAR IMAGES (appear when you click on a bee)
for a = 1:10
    eval(['[loadC loadM loadA] = imread(''' int2str(a) 'px.png'', ''png'');']);
    ratioImg(a) = image(loadC, 'Parent', ha);
    set(ratioImg(a), 'visible', 'off');
end

% LOAD SPEECH BUBBLE IMAGES
[loadC loadM loadA] = imread('speechLeft.png', 'png');
speechL = image(loadC, 'Parent', ha);
set(speechL, 'AlphaData', loadA, 'visible', 'off');
[loadC loadM loadA] = imread('speechRight.png', 'png');
speechR = image(loadC, 'Parent', ha);
set(speechR, 'AlphaData', loadA, 'visible', 'off');
[loadC loadM loadA] = imread('graph.png', 'png');
graphImg = image(loadC, 'Parent', ha);
set(graphImg, 'AlphaData', loadA, 'visible', 'off');

% LOAD HISTORY BAR IMAGES (appear when you click on a bee)
[loadC loadM loadA] = imread('blue.png', 'png');
for a = 1:10
    historyImg(a) = image(loadC, 'Parent', ha);
    set (historyImg(a), 'Visible', 'off');
end
clear loadC;
clear loadM;
clear loadA;

% INITIALIZING GLOBAL VARIABLES (accessable by all sub-functions of bees2D
% co stores the current object (whichever object is selected by the user)
co = 0;
% oldco keeps track of what the previous co was
oldco = 0;
% oldHist keeps track of what the previous history was
oldHist = 0;
% graphOn is 1 when a bee's graph is displayed
graphOn = 0;
% beesThatAreMoving is a vector used to speed up movement loop by only moving bees that are not yet at their targets instead of looping through all bees
beesThatAreMoving = [];
% livingFlowers is a vector used for the same reason as beesThatAreMoving
livingFlowers = [0];
% E is epsilon (the learning rate)
E = 0;
% turboCount is a counter that keeps track of how many trials have passed during turbo mode
turboCount = 0;
% bee is a structure where all aspects of the bees are stored in the bee structure
%   image = the animated gif pixel values including alpha values
%   frame = keeps track of which frame the bee is on
%   pos = current position of the bee in format: (x1 x1+sizeX;y1 y1+sizeY)
%   direction = either left or right
%   target = number of the flower the bee has on target
%   nectar = amount of nectar the bee has sucked
%   beta = beta value for this bee
%   m = a matrix which keeps the m values for each color of flower
%   history = a matrix which records the color of flowers the bee has visited
bee = struct('image', [], 'frame', 1, 'pos', [], 'direction', 'left', 'target', 1, 'nectar', 1, 'beta', 1, 'm', [], 'history', []);
% flower is a structure where all aspects of the flowers are kept
%   image = the correct color of image for this flower type
%   pos = the position of the flower
%   color = the color (type) of flower
%   nectar = the amount of nectar the flower has left
flower = struct('image', [], 'pos', [], 'color', 0, 'nectar', 0);

% load the bee animated gif (left image is default)
[beeAnimeL, beeColors] = imread('bumblebee2.gif', 'gif', 'frames', 'all');
% colormap is required for gif images to display correct colors
colormap(beeColors);
% images are loaded upside down and must be flipped along Y direction
beeAnimeL = flipdim(beeAnimeL, 1);
% bumblebee2.gif shows a bee facing to the left. A seperate image must be used for when the bees are traveling to the right
beeAnimeR = flipdim(beeAnimeL, 2);
%initialize the beeAlphaL variable to be the same dimentions as beeAnimeL
beeAlphaL = beeAnimeL;
% alpha data is represented as 63 in the image, so change 63 to 0
beeAlphaL(find(beeAnimeL == 63)) = 0;
% black pixels are represented as 0 but we want these to show, so alpha = 1
beeAlphaL(find(beeAnimeL == 0)) = 1;
% change all remaining pixels to alpha = 1
beeAlphaL = logical(beeAlphaL);
% repeat as above but in the right facing image
beeAlphaR = beeAnimeR;
beeAlphaR(find(beeAnimeR == 63)) = 0;
beeAlphaR(find(beeAnimeR == 0)) = 1;
beeAlphaR = logical(beeAlphaR);
clc

    function hStartStop_Callback(source, eventdata)
        % currentState = the current value of the Start/Pause/Continue button
        currentState = get(hStartStop, 'String');
        if isequal(currentState, 'Start') % currentState will only equal 'Start' once so initialize is only called once
            set(hStartStop, 'String', 'Pause', 'ForegroundColor', [.5 0 0]);
            initialize();
            while isequal(get(hStartStop, 'String'), 'Pause')
                moveBees();  % handles bee's movment and where P and M are updated
                feedBees();  % handles bees that are at their target flower 
                selectBees();% handles the user's mouse clicks to select bees
            end
        elseif isequal(currentState, 'Pause')
            set(hStartStop, 'String', 'Continue', 'ForegroundColor', [0 .5 0]);
        elseif isequal(currentState, 'Continue')
            set(hStartStop, 'String', 'Pause', 'ForegroundColor', [.5 0 0]);
            while isequal(get(hStartStop, 'String'), 'Pause')
                moveBees();
                feedBees();
                selectBees();
            end
        end

        function initialize()
            % constant which determines the number of flowers the model begins with
            FLOWERS_AT_START = get(hnoflowersdisp, 'value');

            % INITIALIZING FLOWERS
            for nextGrow = 1:FLOWERS_AT_START
                growFlower();
            end

            % constant that determines number of bees at the beginning of the model
            BEES_AT_START = get(hnobeesdisp, 'value');
            beesThatAreMoving = ones(1, BEES_AT_START);
            % E = epsilon, which is the learning rate used in Rescorla-Wagner rule
            E = get(hepsilondisp, 'value');

            % INITIALIZING BEES
            for init = 1:BEES_AT_START
                % start bee with frame 1
                bee(init).image = image(beeAnimeL(:,:,:,1), 'Parent', ha);
                % choose a random starting X and Y position
                bee(init).pos(:,1) = [round((rand-.5)*1000);round((rand-.5)*1000)];
                % XData and YData propterties of image must have [x1 x2; y1 y2] format where x2 and y2 are just x1+sizeX and y1+sizeY this image is 38x38
                bee(init).pos(:,2) = [bee(init).pos(1,1)+38;bee(init).pos(2,1)+38];
                % update image position and alpha values
                set(bee(init).image, 'XData', bee(init).pos(1,:), 'YData', bee(init).pos(2,:), 'AlphaData', beeAlphaL(:,:,:,1));
                % choose a random starting frame so that now all bees fly the same
                bee(init).frame = round(rand*7) + 1;
                % choose a target flower to fly to
                bee(init).target = floor(rand*FLOWERS_AT_START+1);
                % set a random beta between 0 and 1
                bee(init).beta = rand;
                % set all m values to zero
                bee(init).m = [0 0 0 0 0 0 0 0 0 0];
                % give the bee 1 nectar to start with
                bee(init).nectar = 1;
                % initialize the bee's history to empty
                bee(init).history = [];
            end
            % In order to keep the correct objects displayed in the correct order to prevent incorrect overlapping
            % the children of the axes 'ha' must be arranged appropriately as follows
            changeChildren = get(ha, 'children');
            % the objects involved with the speech bubbles must always be on top so we select them
            % and move them to the top of the children list.  There are 23 speech bubble objects.
            speechChildren = changeChildren(end-(23+FLOWERS_AT_START):end-(1+FLOWERS_AT_START));
            % erase the speech bubble object's old position
            changeChildren(end-(23+FLOWERS_AT_START):end-(1+FLOWERS_AT_START)) = [];
            % add them to the top of the list
            changeChildren = [speechChildren; changeChildren];
            % reset the children of 'ha' to the new order
            set(ha, 'children', changeChildren);
        end

        function growFlower()
            % count the number of flowers of each color
            colorTotals = zeros(1, 10);
            for countF = find(livingFlowers)
                if countF > 0 && size(flower(countF).color, 1) > 0
                    colorTotals(flower(countF).color) = colorTotals(flower(countF).color) + 1;
                end
            end
            % finding the next empty slot in livingFlowers vector
            aGrow = 1;
            try % must try/catch this to prevent 'index out of range' error
                while livingFlowers(aGrow) == 1
                    aGrow = aGrow + 1;
                end
            catch
                % no action needed, just continue
            end
            livingFlowers(aGrow) = 1;
            % find the types of flowers that have less than 2 currently displayed.  This prevents
            % a certain type of flower from being completely eaten, which tends to happen when
            % it is especially nutritious
            colorTotals(round(get(hflowertypes, 'value'))+1:end) = [];
            lessThan2ofColor = find(colorTotals < 2);
            if size(lessThan2ofColor, 2) > 0
                % Since this flower type has less than 2, make the new flower of this type/color
                flower(aGrow).color = lessThan2ofColor(1, ceil(rand*size(lessThan2ofColor, 2)));
            else
                % choose a random flower color
                flower(aGrow).color = floor(rand*get(hflowertypes, 'value') + 1);
            end
            flower(aGrow).nectar = 500;
            %        eval(['flower(aGrow).nutrition = hnutrition' int2str(flower(aGrow).color) 'disp;']);
            % load appropriate flower graphic based on the selected color
            % notice all filenames are 6 characters (including spaces)  spaces are removed with deblank function below
            flowerFileNames = ['yellow';'blue  ';'red   ';'lime  ';'green ';'aqua  ';'orange';'plum  ';'purple';'pink  '];
            % fColor, fMap, and fAlpha are initialized to prevent a nasty warning while using them in eval
            fColor = [];
            fMap = [];
            fAlpha = [];
            % handy little eval function condenses 20 lines of code into 1 which loads the correct color flower images
            eval(['[fColor, fMap, fAlpha] = imread(''' deblank(flowerFileNames(flower(aGrow).color, :)) '.png'', ''png'');']);
            % stores the image data into the flower structure
            flower(aGrow).image = image(fColor, 'Parent', ha);
            set(flower(aGrow).image, 'AlphaData', fAlpha);
            % check to see if the flower is too close to another flower
            flowerOverlaps = 1;
            while flowerOverlaps
                flowerOverlaps = 0;
                flower(aGrow).pos(:,1) = [round((rand-.57)*880);round((rand-.57)*880)];
                flower(aGrow).pos(:,2) = [flower(aGrow).pos(1,1)+120;flower(aGrow).pos(2,1)+120];
                for bGrow = find(livingFlowers)
                    if bGrow ~= aGrow && flower(aGrow).pos(1,1) < flower(bGrow).pos(1,1) + 180 && flower(aGrow).pos(1,1) > flower(bGrow).pos(1,1) - 180 && flower(aGrow).pos(2,1) < flower(bGrow).pos(2,1) + 180 && flower(aGrow).pos(2,1) > flower(bGrow).pos(2,1) - 180
                        flowerOverlaps = 1;
                        break;
                    end
                end
            end
            % update the position of the flower image using pos values
            set(flower(aGrow).image, 'XData', flower(aGrow).pos(1,:), 'YData', flower(aGrow).pos(2,:));
            set(flower(aGrow).image, 'XData', flower(aGrow).pos(1,:), 'YData', flower(aGrow).pos(2,:));

            % Prevents the flowers from overlapping bees by moving them to the bottom of children list
            changeChildren = get(ha, 'children');
            lastChild = changeChildren(1);
            changeChildren(1) = [];
            grassChild = changeChildren(end);
            changeChildren(end) = [];
            changeChildren = [changeChildren; lastChild];
            changeChildren = [changeChildren; grassChild];
            set(ha, 'children', changeChildren);
        end

        % Controls all the bees' movements
        function moveBees();
            % When turbo mode is on then speed is set to maximum so the bees arrive at target flower instantly
            if get(hturbomode, 'Value')
                speed = 1000;
            else
                % If turbo mode is off then speed is controled by the user
                speed = get(hspeeddisp, 'value');
            end
            % Loop through all bees that are not at their target flower
            for a = find(beesThatAreMoving == 1)
                % There are 8 frames to the bee animated gif.  If the frame counter is at 9 then set it back to first frame (1)
                if bee(a).frame == 9
                    bee(a).frame = 1;
                end
                % Check to see if this bee is within speed steps of its target flower
                if round(bee(a).pos(1,1)) < flower(bee(a).target).pos(1,1) + 45 + speed && round(bee(a).pos(1,1)) > flower(bee(a).target).pos(1,1) + 45 - speed  && round(bee(a).pos(2,1)) < flower(bee(a).target).pos(2,1) + 60 + speed && round(bee(a).pos(2,1)) > flower(bee(a).target).pos(2,1) + 60 - speed
                    % Bee is at its target so it is no longer moving
                    beesThatAreMoving(a) = 0;
                    bee(a).pos(1,:) = [flower(bee(a).target).pos(1,1) + 45 flower(bee(a).target).pos(1,1) + 83];
                    bee(a).pos(2,:) = [flower(bee(a).target).pos(2,1) + 60 flower(bee(a).target).pos(2,1) + 98];
                    % Update m using Rescorla-Wagner rule: m(b) --> m(b) + E*delta  with delta = r(b) - m(b)
                    delta = eval(['str2num(get(hnutrition' int2str(flower(bee(a).target).color) 'disp, ''String''))-bee(a).m(flower(bee(a).target).color);']);
                    bee(a).m(flower(bee(a).target).color) = bee(a).m(flower(bee(a).target).color) + E*delta;
                    bee(a).history = [bee(a).history; flower(bee(a).target).color];
                    % bee is not at target so proceed by moving it towards its target
                else
                    % In order to prevent division by zero, ensure the denominator (x distance difference) isn't 0
                    if ((flower(bee(a).target).pos(1,1) + 45)-bee(a).pos(1,1)) == 0
                        % if x distance difference is 0 then set M (the slope) to 1
                        M = 1; % M = slope
                    else
                        % Calculate the slope between the bee and its target flower
                        M = abs(((flower(bee(a).target).pos(2,1) + 60) - bee(a).pos(2,1))/((flower(bee(a).target).pos(1,1) + 45)-bee(a).pos(1,1)));
                    end
                end
                % If bee is to the left of its target flower
                if bee(a).pos(1,1) < flower(bee(a).target).pos(1,1) + 45
                    bee(a).direction = 'right';
                    % Maximum movement in either X or Y direction is speed.  The use of the variable M and this if statement
                    % makes the bees travel in straight lines to their target flowers
                    if M >= 1
                        bee(a).pos(1,:) = bee(a).pos(1,:) + speed/M;
                    elseif M < 1
                        bee(a).pos(1,:) = bee(a).pos(1,:) + speed;
                    end
                    % If bee is to the right of its target flower
                elseif bee(a).pos(1,1) > flower(bee(a).target).pos(1,1) + 45
                    bee(a).direction = 'left';
                    if M >= 1
                        bee(a).pos(1,:) = bee(a).pos(1,:) - speed/M;
                    elseif M < 1
                        bee(a).pos(1,:) = bee(a).pos(1,:) - speed;
                    end
                end
                if bee(a).pos(2,1) < flower(bee(a).target).pos(2,1) + 60
                    if M >= 1
                        bee(a).pos(2,:) = bee(a).pos(2,:) + speed;
                    elseif M < 1
                        bee(a).pos(2,:) = bee(a).pos(2,:) + M * speed;
                    end
                elseif bee(a).pos(2,1) > flower(bee(a).target).pos(2,1) + 60
                    if M >= 1
                        bee(a).pos(2,:) = bee(a).pos(2,:) - speed;
                    elseif M < 1
                        bee(a).pos(2,:) = bee(a).pos(2,:) - M * speed;
                    end
                end
                % Update the position of the bee's image
                set(bee(a).image, 'XData', bee(a).pos(1,:));
                set(bee(a).image, 'YData', bee(a).pos(2,:));
                % Two seperate images are used for left and right facing bees.  Depending on which direction the
                % bee is traveling, set the appropriate image
                if isequal(bee(a).direction, 'left')
                    set(bee(a).image, 'CData', beeAnimeL(:,:,:,bee(a).frame));
                    set(bee(a).image, 'AlphaData', beeAlphaL(:,:,:,bee(a).frame));
                else
                    set(bee(a).image, 'CData', beeAnimeR(:,:,:,bee(a).frame));
                    set(bee(a).image, 'AlphaData', beeAlphaR(:,:,:,bee(a).frame));
                end
                % Increment the frame counter for this bee
                bee(a).frame = bee(a).frame + 1;
            end
            % If turbo mode is on then only redraw graphics 1 out of 1000 times otherwise do it every time
            if ~get(hturbomode, 'Value')
                drawnow;
            else
                if turboCount == 1950 %1900 = approx 50 trials
                    drawnow;
                    turboCount = 0;
                else
                    turboCount = turboCount + 1;
                end
            end
        end

        % Controls the bees once they reach their target flowers
        function feedBees()
            % find bees which are at their target flowers (therefore they are not moving)
            for aFeed = find(beesThatAreMoving == 0)
                % Make sure the target flower still has nectar
                if flower(bee(aFeed).target).nectar > 0
                    % subtract 1 nectar that the bee 'eats' from the flower's nectar value
                    flower(bee(aFeed).target).nectar = flower(bee(aFeed).target).nectar - 1;
                    % give 1 nectar to the bee
                    bee(aFeed).nectar = bee(aFeed).nectar + 1;
                    %Once the bee's nectar supply is greater than the length-of-stay value then choose a new flower
                    if bee(aFeed).nectar > get(hlostdisp, 'value') - rand*get(hspeeddisp, 'value')
                        % Remove the bee's nectar
                        bee(aFeed).nectar = 0;
                        % Choose a new target for this bee
                        beeChangeTarget(aFeed);
                        % Add the bee to the list of bees that are moving
                        beesThatAreMoving(aFeed) = 1;
                    end
                else % The flower is out of nectar, so kill it
                    % Remove it from the list of living flowers
                    livingFlowers(bee(aFeed).target) = 0;
                    % Delete the image data
                    delete(flower(bee(aFeed).target).image);
                    % Grow a new flower to replace the dead one
                    growFlower();
                    % Find the bees which were on their way to the flower that died and give them a new target
                    for b = find(beesThatAreMoving == 1)
                        if bee(b).target == bee(aFeed).target
                            beeChangeTarget(b);
                        end
                    end
                    % Find the bees which were also at the flower that died and give them a new target
                    for bFeed = find(beesThatAreMoving == 0)
                        if bee(bFeed).target == bee(aFeed).target && aFeed ~= bFeed
                            beesThatAreMoving(bFeed) = 1;
                            beeChangeTarget(bFeed);
                        end
                    end
                    % Also change the target of the current be since its flower died
                    beesThatAreMoving(aFeed) = 1;
                    beeChangeTarget(aFeed);
                end
            end
        end

        % Processes how bees choose a new target flower
        function beeChangeTarget(thisBee)
            % P[a] = exp(beta*M(a))/sum(exp(beta*M(a)))
            % sumOfP is the denominator of the equation used to calculate P of each flower type. (sum(exp(beta*M(a))))
            sumOfP = 0;
            for updateP = 1:10
                sumOfP = sumOfP + exp(bee(thisBee).beta * bee(thisBee).m(updateP));
            end
            % Calculate P for each flower color/type
            totalP = [1 0 0];
            for updateP = 1:10
                P(updateP) = exp(bee(thisBee).beta * bee(thisBee).m(updateP))/sumOfP;
                totalP = [totalP; totalP(updateP, 2) totalP(updateP, 2)+P(updateP) updateP];
            end
            flowerDoesntExists = 1;
            chosenColor = 0;
            randomChoice = 0;
            % Select a color of flower to go to based on the P values of the bee that is choosing a new target flower
            while flowerDoesntExists || chosenColor == 0
                colorChoice = rand;
                for c = 2:size(totalP, 1)
                    if colorChoice > totalP(c,1) && colorChoice <= totalP(c,2)
                        chosenColor = totalP(c,3);
                        break;
                    end
                end
                % If a choice hasn't been made after 100 attempts then just choose a random flower color
                if randomChoice > 100
                    chosenColor = floor(rand*get(hnoflowersdisp, 'value')+1);
                else
                    % Count the number of failed attempts to choose a new target flower color/type
                    randomChoice = randomChoice + 1;
                end
                % Check to see if the chosen flower color/type is currently present
                for a = find(livingFlowers)
                    if flower(a).color == chosenColor && a ~= bee(thisBee).target
                        flowerDoesntExists = 0;
                        break;
                    end
                end
            end

            % Calculate the distance between the bee and all the flowers of the chosen color/type
            dist2Flower = [];
            for a = find(livingFlowers)
                if flower(a).color == chosenColor
                    dist2Flower = [dist2Flower; a sqrt((flower(a).pos(1,1) + 45  - bee(thisBee).pos(1,1))^2 + (flower(a).pos(2,1) + 60 - bee(thisBee).pos(2,1))^2)];
                end
            end
            % Find the closest flower of the chosen color/type
            closest = [1 inf];
            for a = 1:size(dist2Flower,1)
                if dist2Flower(a, 2) < closest(1, 2) && dist2Flower(a,2) > 0
                    closest = [dist2Flower(a,1) dist2Flower(a, 2)];
                end
            end
            % Set the new target to the closet flower of the chosen color/type
            bee(thisBee).target = closest(1, 1);
        end

        % When the user clicks on a bee this function is called and displays the speech bubble next to the bee
        function selectBees()
            % check to see if a bee figure is already displayed
            if co ~= graphImg && ~exist('beeFigure')
                % set co (current object) to gco (get current object command)
                co = gco;
            else
                % If figure is already displayed then co is the same as oldco
                co = oldco;
            end
            % Determine which bee was clicked
            selectedBee = 0;
            for s = 1:size(beesThatAreMoving, 2)
                if isequal(co, bee(s).image)
                    for ss = 1:size(beesThatAreMoving, 2)
                        set(bee(ss).image, 'selected', 'off');
                    end
                    set(bee(s).image, 'selected', 'on', 'SelectionHighlight', 'off');
                    selectedBee = s;
                    oldco = co;
                end
            end
            if size(co, 1) > 0
                if selectedBee == 0 && oldco ~= co
                    for s = 1:size(beesThatAreMoving,2)
                        if isequal(oldco, bee(s).image)
                            for ss = 1:size(beesThatAreMoving,2)
                                set(bee(ss).image, 'selected', 'off');
                            end
                            set(bee(s).image, 'selected', 'on', 'SelectionHighlight', 'off');
                            selectedBee = s;
                        end
                    end
                end
            end
            try
                if gco == graphImg && graphOn
                    graphOn = 1;
                else
                    graphOn = 0;
                end
            catch
                graphOn = 1;
                co = graphImg;
            end
            if co == graphImg && ~graphOn
                showGraph(selectedBee);
                graphOn = 1;
            elseif co == speechL || co == speechR
                set(speechL, 'Visible', 'off');
                set(speechR, 'Visible', 'off');
                set(graphImg, 'Visible', 'off');
                for cR = 1:10
                    set(ratioImg(cR), 'Visible', 'off');
                    set(historyImg(cR), 'Visible', 'off');
                end
                selectedBee = 0;
                oldco = 0;
            end
            if selectedBee
                if bee(selectedBee).pos(1,1) < -170 % close to left side so use right speech bubble
                    set(speechL, 'Visible', 'off');
                    set(speechR, 'XData', [bee(selectedBee).pos(1,1)+19 bee(selectedBee).pos(1,1)+339], 'YData', [bee(selectedBee).pos(2,1)+40 bee(selectedBee).pos(2,1)+200], 'Visible', 'on');
                    drawRatios(selectedBee, 'right');
                    set(graphImg, 'Xdata', [bee(selectedBee).pos(1,1)+300 bee(selectedBee).pos(1,1)+330], 'YData', [bee(selectedBee).pos(2,1)+115 bee(selectedBee).pos(2,1)+145], 'Visible', 'on');
                elseif bee(selectedBee).pos(1,1) > 170 % close to right side so use left speech bubble
                    set(speechR, 'Visible', 'off');
                    set(speechL, 'XData', [bee(selectedBee).pos(1,1)-301 bee(selectedBee).pos(1,1)+19], 'YData', [bee(selectedBee).pos(2,1)+40 bee(selectedBee).pos(2,1)+200], 'Visible', 'on');
                    drawRatios(selectedBee, 'left');
                    set(graphImg, 'Xdata', [bee(selectedBee).pos(1,1)-30 bee(selectedBee).pos(1,1)], 'YData', [bee(selectedBee).pos(2,1)+125 bee(selectedBee).pos(2,1)+155], 'Visible', 'on');
                else
                    if isequal(bee(selectedBee).direction, 'left')
                        set(speechR, 'Visible', 'off');
                        set(speechL, 'XData', [bee(selectedBee).pos(1,1)-301 bee(selectedBee).pos(1,1)+19], 'YData', [bee(selectedBee).pos(2,1)+40 bee(selectedBee).pos(2,1)+200], 'Visible', 'on');
                        drawRatios(selectedBee, 'left');
                        set(graphImg, 'Xdata', [bee(selectedBee).pos(1,1)-30 bee(selectedBee).pos(1,1)], 'YData', [bee(selectedBee).pos(2,1)+125 bee(selectedBee).pos(2,1)+155], 'Visible', 'on');
                    else
                        set(speechL, 'Visible', 'off');
                        set(speechR, 'XData', [bee(selectedBee).pos(1,1)+19 bee(selectedBee).pos(1,1)+339], 'YData', [bee(selectedBee).pos(2,1)+40 bee(selectedBee).pos(2,1)+200], 'Visible', 'on');
                        drawRatios(selectedBee, 'right');
                        set(graphImg, 'Xdata', [bee(selectedBee).pos(1,1)+300 bee(selectedBee).pos(1,1)+330], 'YData', [bee(selectedBee).pos(2,1)+115 bee(selectedBee).pos(2,1)+145], 'Visible', 'on');
                    end
                end
            end
        end

        % Draws the ratio bar and history in the speech bubble of the selected bee
        function drawRatios(selectedBee, dir)
            % Orders the M values from highest to lowest
            allM = [];
            for orderM = 1:10
                allM = [allM; bee(selectedBee).m(orderM) orderM];
            end
            allM = sortrows(allM, 1);
            allM = flipdim(allM, 1);
            for orderM = 1:10
                allM(orderM,3) = allM(orderM,1)/sum(allM(:,1));
            end
            flowerFileNames = ['yellow';'blue  ';'red   ';'lime  ';'green ';'aqua  ';'orange';'plum  ';'purple';'pink  '];
            for drawM = 1:10
                x1 = bee(selectedBee).pos(1,1) + 212*sum(allM(1:drawM-1,3));
                x2 = bee(selectedBee).pos(1,1) + 212*sum(allM(1:drawM,3));
                h1 = bee(selectedBee).pos(1,1) + 30*(drawM-1);
                h2 = bee(selectedBee).pos(1,1) + 30*(drawM);
                if drawM <= size(bee(selectedBee).history, 1)
                    if size(bee(selectedBee).history, 1) ~= oldHist
                        % fColor, fMap, and fAlpha are initialized to prevent a nasty warning while using them in eval
                        fColor = [];
                        fMap = [];
                        fAlpha = [];
                        % handy little eval function condenses 20 lines of code into 1 which loads the correct color flower images
                        eval(['[fColor, fMap, fAlpha] = imread(''' deblank(flowerFileNames(bee(selectedBee).history(end-drawM+1), :)) '.png'', ''png'');']);
                        set(historyImg(drawM), 'CData', fColor, 'AlphaData', fAlpha);
                    end
                    if isequal(dir, 'left')
                        set(historyImg(drawM), 'XData', [h1-295 h2-295], 'YData', [bee(selectedBee).pos(2,1)+80 bee(selectedBee).pos(2,1)+110], 'Visible', 'on');
                    elseif isequal(dir, 'right')
                        set(historyImg(drawM), 'XData', [h1+35 h2+35], 'YData', [bee(selectedBee).pos(2,1)+80 bee(selectedBee).pos(2,1)+110], 'Visible', 'on');
                    end
                end
               
                if isequal(dir, 'left') && allM(drawM, 1) > 0
                    set(ratioImg(allM(drawM, 2)), 'XData', [x1-255 x2-255], 'YData', [bee(selectedBee).pos(2,1)+164 bee(selectedBee).pos(2,1)+179] , 'Visible', 'on');
                elseif isequal(dir, 'right') && allM(drawM, 1) > 0
                    set(ratioImg(allM(drawM, 2)), 'XData', [x1+83 x2+83], 'YData', [bee(selectedBee).pos(2,1)+155 bee(selectedBee).pos(2,1)+171], 'Visible', 'on');
                else
                    set(ratioImg(allM(drawM, 2)), 'Visible', 'off');
                end
            end
            oldHist = size(bee(selectedBee).history, 1);  
        end

        % Displays the graph of thisBee when the graph button is clicked from the bee's speech bubble
        function showGraph(thisBee)
            beeFigure = figure('Visible', 'on', 'Name', ['Graph for Bee #: ' num2str(thisBee)], 'Position', [300 400 400 300]);
            graphData = [];
            sumHistory = zeros(1,10);
            for aloop = 1:size(bee(thisBee).history, 1)
                sumHistory(bee(thisBee).history(aloop)) = sumHistory(bee(thisBee).history(aloop)) + 1;
                graphData = [graphData; aloop sumHistory];
            end
            graphData(:,find(sum(graphData, 1) == 0)) = [];
            colorOrderValues = [1 1 0; 0 0 1; 1 0 0; .5 1 0; .3 .7 0; 0 1 1; 1 .6 0; .5 0 1; .7 .2 1; 1 0 1];
            set(0, 'DefaultAxesColorOrder', colorOrderValues);
            beeAxes = axes('Parent', beeFigure, 'XLim', [1 size(graphData, 1)+.1]);
            plot(beeAxes, graphData(:,1), graphData(:,2:end), 'LineWidth', 1.5);
            set(get(gca, 'XLabel'), 'String', 'Trials');
            set(get(gca, 'YLabel'), 'String', 'Visits');
            hbeebetatxt = uicontrol('Style', 'text', 'parent', beeFigure, 'String', ['Beta for Bee # ' num2str(thisBee) ':'], 'BackgroundColor', [.8 .8 .8], 'Position', [235 279 100 15]);
            hbeebeta = uicontrol('Style', 'edit', 'parent', beeFigure, 'String', round(1000*bee(thisBee).beta)/1000, 'Callback', {@hchangeBeta_Callback}, 'Position', [330 280 50 15]);

            function hchangeBeta_Callback(source, eventdata)
                val = get(hbeebeta, 'String');
                val = str2num(val);
                if ~isequal(val, [])
                    if val > 1
                        warndlg('Value for beta must be between 0 and 1.');
                        val = 1;
                    elseif val < 0
                        warndlg('Value for beta must be between 0 and 1.');
                        val = 0;
                    end
                else
                    warndlg('Value for beta must be a number between 0 and 1.');
                    val = 0.5;
                end
                val = num2str(val);
                set(hbeebeta, 'String', val);
                bee(thisBee).beta = str2num(get(hbeebeta, 'String'));
            end

        end

    end % end of bees function

    % Hides or shows the flower nutrition boxes depending on how many flower types are currently allowed
    function hflowertypes_Callback(source, eventdata)
        set(hflowerdisp, 'String',round(get(hflowertypes, 'value')));
        for turnOn = 3:round(get(hflowertypes, 'value'))+1
            try
                eval(['set(hnutrition' int2str(turnOn) 'txt, ''Visible'', ''on'');']);
                eval(['set(hnutrition' int2str(turnOn) 'disp, ''Visible'', ''on'');']);
            catch
                % non-crash error when hflowertypes = 10.  This catch prevents the error
            end
        end
        for turnOff = round(get(hflowertypes, 'value'))+1:10
            eval(['set(hnutrition' int2str(turnOff) 'txt, ''Visible'', ''off'');']);
            eval(['set(hnutrition' int2str(turnOff) 'disp, ''Visible'', ''off'');']);
        end
    end
    % The remaining functions are called when the sliders are changed to update the associated text field
    function hnobeesdisp_Callback(source, eventdata)
        set(hnobeestypes, 'String', round(get(hnobeesdisp, 'value')));
    end

    function hspeeddisp_Callback(source, eventdata)
        set(hspeedtypes, 'String', round(get(hspeeddisp, 'value')));
    end

    function hnoflowersdisp_Callback(source, eventdata)
        set(hnoflowerstypes, 'String', round(get(hnoflowersdisp, 'value')));
    end

    function hepsilondisp_Callback(source, eventdata)
        set(hepsilontypes, 'String', round(get(hepsilondisp, 'value')*100)/100);
        E = get(hepsilondisp, 'value');
    end

    function hlostdisp_Callback(source, eventdata)
        set(hlosttypes, 'String', round(get(hlostdisp, 'value')));
    end

    function hnutrition_Callback(source, eventdata)
        val = get(source, 'String');
        val = str2num(val);
        if ~isequal(val, [])
            if val > 999
                warndlg('Value must be between 0 and 999.');
                val = 999;
            elseif val < 0
                warndlg('Value must be between 0 and 999.');
                val = 0;
            end
        else
            warndlg('Value must be a number between 0 and 999.');
            val = 1;
        end
        val = num2str(val);
        set(source, 'String', val);
    end
end