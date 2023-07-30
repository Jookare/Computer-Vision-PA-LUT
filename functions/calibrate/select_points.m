function p2 = select_points(I)
%SELECT_POINTS Allows the user to select 11 points for calibration
%
%    Inputs:
%        I: Calibration image
%
%    Output:
%        p2: 2d coordinates of the chosen points.
    
    % Make image grayscale
    B = rgb2gray(I);

    % Find corners using Harris corner detection
    corners = detectHarrisFeatures(B);

    % show the image, zoom and plot the strongest corners from Harris.
    f = figure();
    imshow(B); 
    zoom(2.5)
    hold on;
    plot(corners.selectStrongest(700));

    % Use a customized function to choose the points. (Difference to ginput
    % = different colored crosshair)
    p2 = ginput_white(11);

    % close the figure
    close(f)
end
