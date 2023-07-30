function visualize(points, img, c)
% VISUALIZE Plots the points to the given image.
%
%    Inputs:
%        points: 2D points of the interesting image objects
%        img: input image
%           
%    Output:
%        ~
    % Visualize
    figure()
    imshow(img)
    hold on

    % Check if colors given
    switch nargin
        case 2
            for i = 1 : length(points)
                plot(points(1,i), points(2,i), "MarkerSize",15, "LineWidth",3)
            end
        case 3
            for i = 1 : length(points)
                plot(points(1,i), points(2,i), c(i), "MarkerSize",15, "LineWidth",3)
            end
    end
    
end

