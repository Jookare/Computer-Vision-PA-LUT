function res = detect_objects(I)
% DETECT_OBJECT detects the three colored cubes and the robot's dots 
% from the image
%
%    Inputs:
%        I: input image
%           
%    Output:
%        res: 2D coordinates of the red, green, and blue cube as well as
%        2D coordinates of light blue and pink dot from the robot.

    % Find the red cube 
    i0 = (I(:,:,1) > 60);
    i1 = (I(:,:,2) < 50);
    i2 = (I(:,:,3) < 50);
    BW = (i0 + i1 + i2) == 3;
    red_cube = find_cube(BW);

    % Find the green cube and goal
    img = rgb2hsv(I);
    i0 = (img(:,:,1) < 0.35);
    i1 = (img(:,:,1) > 0.2);
    i2 = (img(:,:,2) < 0.9);
    i3 = (img(:,:,2) > 0.30);
    i4 = (img(:,:,3) > 0.2);
    % i5 = (img(:,:,3) < 1);
    BW = (i0 + i1 + i2 + i3 + i4) == 5;
    green_cube = find_cube(BW);  
    
    % Find the blue cube
    i0 = (img(:,:,1) < 0.65);
    i1 = (img(:,:,1) > 0.55);
    i2 = (img(:,:,2) < 0.85);
    i3 = (img(:,:,2) > 0.3);
    i4 = (img(:,:,3) > 0.1);
    BW = (i0 + i1 + i2  + i3 + i4) == 5;
    blue_cube = find_cube(BW);

    % Find the light blue dot from Robot
    i0 = (I(:,:,1) < 80);
    i1 = (I(:,:,1) > 30);
    i2 = (I(:,:,2) > 80);
    i3 = (I(:,:,2) < 155);
    i4 = (I(:,:,3) > 120);
    i5 = (I(:,:,3) < 170);
    BW = (i0 + i1 + i2 + i3 + i4 + i5) == 6;
    l_blue = find_robot_dot(BW);

    % Find the pink dot from Robot
    i0 = (I(:,:,1) < 140); 
    i1 = (I(:,:,1) > 120); 
    i2 = (I(:,:,2) < 70); 
    i4 = (I(:,:,3) < 100); 
    i5 = (I(:,:,3) > 50); 
    BW = (i0 + i1 + i2 + i4 + i5) == 5;
    pink = find_robot_dot(BW); 
   
    res = [red_cube; green_cube; blue_cube; l_blue; pink]';
end

function res = find_cube(BW)
    % Fill the holes in the thresholded BW image
    BW2 = imfill(BW, "holes");
    
    % Find the areas and the centroids of all the regions
    s = regionprops(BW2,'area', 'Centroid');
    area = cat(1,s.Area);
    centroids = cat(1,s.Centroid);
    % Find two largest areas
    i = max(area);

    % Index of the largest area
    first_ind = area == i(1);
    res = centroids(first_ind,:);
end


function res = find_robot_dot(BW)
    
    % Fill the holes in the thresholded BW image
    BW2 = imfill(BW, "holes");
    
    % Find the areas and the centroids of all the regions
    s = regionprops(BW2,'area', 'Centroid', 'Circularity');

    % Cat the area and circularity
    area = cat(1,s.Area);
    circ = cat(1, s.Circularity);
    
    % Round the centroids
    centroids = round(cat(1,s.Centroid));

    % Get tho logicals one for removing the Inf circularities and finding
    % also the areas only larger than 30.
    circ_index = circ ~= Inf;
    area_index = area > 40;
    if (area_index == 0)
        [~, index] = max(area);
    else
        INDEX = area_index & circ_index;
    
        % Find the largest area
        [~, index] = max(circ .* INDEX);
    end
    
    res = centroids(index,:);
end

