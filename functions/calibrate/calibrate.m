function res = calibrate(I, ~)
% CALIBRATE Calibrate the camera using images of a scene.
%
%    Inputs:
%        imgs: An array of images to be used for calibration
%        ~: if two arguments is given then plots the calibration points.
%
%    Output:
%        res: A struct that includes projection matrix, a decomposed
%        projection matrix and the target goal positions.
    
    % Checkerboard width (mm)
    checker_w = 45;
    
    % Cube width (mm)
    cube_w = 50;
    
    % Distance from orig to the edge of checkerboard (mm)
    dist = 200;

    % Idea in this is to use the harris corner detection as an aid to help
    % in choosing the corner coordinates.
    % p2 = select_points(I)

    % Manually found points for the demo. (calibration_demo.png)
    p2 =    1.0e+03 *[
    0.9674    0.4154;
    1.0214    0.4100;
    1.0376    0.4448;
    1.3040    0.5348;
    1.3322    0.5774;
    1.3118    0.6194;
    1.2536    0.6272;
    0.8486    0.5810;
    0.8564    0.6776;
    0.7862    0.6848;
    0.8084    0.4730];
    p2 = p2';

    if (nargin == 2)
        % Visualize the chosen points
        imshow(I); hold on
        plot(p2(1,:) , p2(2,:), 'co')
    end

    % Mass centers of the cubes
    b_center = [3*checker_w + cube_w/2, -dist - cube_w/2, cube_w/2];
    r_center = [7*checker_w + cube_w/2, -dist - 5*checker_w + cube_w/2, cube_w/2];
    g_center = [-cube_w/2, -dist - 4*checker_w - cube_w/2, cube_w/2];

    % Corresponding 3D coordinates
    p3 = [b_center(1) - cube_w/2, b_center(2) + cube_w/2, b_center(3) + cube_w/2;
        b_center(1) + cube_w/2, b_center(2) + cube_w/2, b_center(3) + cube_w/2;
        b_center(1) + cube_w/2, b_center(2) - cube_w/2, b_center(3) + cube_w/2;
        r_center(1) + cube_w/2, r_center(2) + cube_w/2, r_center(3) + cube_w/2;
        r_center(1) + cube_w/2, r_center(2) - cube_w/2, r_center(3) + cube_w/2;
        r_center(1) + cube_w/2, r_center(2) - cube_w/2, r_center(3) - cube_w/2;
        r_center(1) - cube_w/2, r_center(2) - cube_w/2, r_center(3) - cube_w/2;
        g_center(1) + cube_w/2, g_center(2) + cube_w/2, g_center(3) + cube_w/2;
        g_center(1) + cube_w/2, g_center(2) - cube_w/2, g_center(3) - cube_w/2;
        g_center(1) - cube_w/2, g_center(2) - cube_w/2, g_center(3) - cube_w/2;
        0, -dist, 0;]';
    
    % Find projection matrix
    M = find_projection(p2, p3);
    
    % Decompose the matrix
    [K, R, C] = decompose_projection(M);
    res.M = M;
    res.K = K;
    res.R = R;
    res.C = C;
    
    [red_goal, green_goal, blue_goal] = goal_location(I);
    res.goals = [red_goal; green_goal; blue_goal];
end