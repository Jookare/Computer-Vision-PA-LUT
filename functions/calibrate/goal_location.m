function [red_goal, green_goal, blue_goal] = goal_location(I)
% GOAL_LOCATION Uses thresholding and regionprops to find the target goals.
%
%    Inputs:
%        I: Calibration image
%
%    Output:
%        red_goal:   2d location of the red goal
%        green_goal: 2d location of the green goal
%        blue_goal:  2d location of the blue goal

    % Find the red Goal by thresholding the image
    i0 = (I(:,:,1) > 60);
    i3 = (I(:,:,3) < 50);
    i2 = (I(:,:,2) < 50);
    BW = (i0 + i2 + i3) == 3;
    red_goal = find_goal(BW, I);
    
    img = rgb2hsv(I);
    % Find the Green Goal by thresholding the image
    i0 = (img(:,:,1) < 0.35);
    i1 = (img(:,:,1) > 0.2);
    i2 = (img(:,:,2) < 0.99);
    i3 = (img(:,:,2) > 0.35);
    i4 = (img(:,:,3) > 0.15);
    % i5 = (img(:,:,3) < 1);
    BW = (i0 + i1 + i2 + i3 + i4) == 5;
    green_goal = find_goal(BW, I);

    % Find the Blue Goal by thresholding the image
    img = rgb2hsv(I);
    i0 = (img(:,:,1) < 0.7);
    i1 = (img(:,:,1) > 0.5);
    i2 = (img(:,:,2) < 0.9);
    i3 = (img(:,:,2) > 0.2);
    i4 = (img(:,:,3) > 0.1);
    BW = (i0 + i1 + i2  + i3 + i4) == 5;
    blue_goal = find_goal(BW, I);
end

function res = find_goal(BW, I)
    
    % Find the areas and the centroids of all the regions
    s = regionprops(BW,"area", 'Centroid');
    area = cat(1,s.Area);
    centroids = round(cat(1,s.Centroid));

    % Sort the areas based on index
    [~, ind] = sort(area, 'descend');

    % Save all the centroid colors to a Matrix
    C = zeros(3,length(ind));
    for k = 1:length(ind)
        C(:,k) = reshape(I(centroids(ind(k),2), centroids(ind(k),1), :),  [1,3]);
    end
    
    % Find all the centroids that are "white"
    res = centroids(ind(find(sum(C > 150) == 3,1)),:);
end