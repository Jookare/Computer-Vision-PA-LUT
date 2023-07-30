function res = move_block(block, img, res)
% MOVE_BLOCK Returns the commands to move the specified blocks to their target position.
%
%    Inputs:
%        blocks: a cell array of string values that determine which blocks you should move 
%                and in which order. For example, if blocks = {"red", "green", "blue"} 
%                that means that you need to first move red block. 
%                Your function should at minimum work for the following values of blocks:
%                blocks = {"red"}, blocks = {"green"}, blocks = {"blue"}.
%        img: an image containing the current arrangement of robot and blocks.
%        calib: calibration results from function calibrate.
%
%    Output:
%        res: robot commands separated by ";". 
%             An example output: "go(20); grab(); turn(90);  go(-10); let_go()"
    
    % check which block
    switch lower(block)
        case "red"
            B = 0;
        case "green"
            B = 1;
        case "blue"
            B = 2;
    end
    temp_points = detect_objects(img);
    points = [res.goals', temp_points];

    M = res.M;
    figure(3)
    P = zeros(3,length(points));

    % define the colors
    c = ["ro", "go", "bo", "rs", "gs", "bs", "cx", "mx"];

    % z-coordinates of the goals, blocks and robot points in real scene
    Z = [0, 0, 0, 25, 25, 25, 75, 75];
    for k = 1:length(points)
        % Load the points
        p2 = [points(:,k); 1];
    
        % create the matrix and solve it with SVD
        A = [M(:,1), M(:,2),  -p2, (Z(k)*M(:,3) + M(:,4))];
        [~, ~, V] = svd(A);
        
        % normalize the result
        theta = V(1:3,end)/V(4,end);
        P(:,k) = [theta(1:2); Z(k)];
    
        % plot the points to same plane
        plot3(theta(1), theta(2), 0, c(k))
        hold on
    end
    xlabel("x")
    ylabel("y")
    zlabel("z")
    
    % visualize the points to the image
    visualize(points, img, c)
    figure(3)
    hold on

    % set the z-coordinate to zero as we are moving on plane only
    P(3,:) = 0;

    % robot_hand length
    robot_h = 12; % cm
    
    % distance to between the goals 15cm used for distance correction
    dist_goal = norm(P(:,1) - P(:,3));
    px_mm = 300/dist_goal/10; % in cm

    % define the colors
    c = ["r", "g", "b"];
    cube = P(:, B + 4);
    goal = P(:, B + 1);
    robot_f = P(:, end - 1);    % Front of the robot (light blue)
    robot_b = P(:, end);        % Back of the robot  (pink)
    
    % vector for robot direction
    v1 = robot_f - robot_b;
    quiver3(robot_f(1), robot_f(2), robot_f(3), v1(1), v1(2), v1(3), c(B + 1))
    
    % vector from robot to cube
    v2 = cube - robot_f;
    quiver3(robot_f(1), robot_f(2), robot_f(3), v2(1), v2(2), v2(3), c(B + 1))
    
    % vector from cube to goal
    v3 = goal - cube;
    quiver3(cube(1), cube(2), cube(3), v3(1), v3(2), v3(3), c(B + 1))
    
    % robot to cube
    % check if we need to turn into positive or negative direction
    C = cross(v1, v2);
    if (sign(C(3)) == 1) % if positive
        angle_r_c = -acos( dot(v1,v2)/(norm(v1)*norm(v2)) ) * 180/pi;
    else  
        angle_r_c = acos( dot(v1,v2)/(norm(v1)*norm(v2)) ) * 180/pi;
    end
    
    % cube to goal
    % check if we need to turn into positive or negative direction
    C = cross(v2, v3);
    if (sign(C(3)) == 1) % if positive
        angle_c_g = -acos( dot(v2,v3)/(norm(v2)*norm(v3)) ) * 180/pi;
    else  
        angle_c_g = acos( dot(v2,v3)/(norm(v2)*norm(v3)) ) * 180/pi;
    end
    
    % distance from robot to cube
    dist_r_c = norm(robot_f - cube) * px_mm;
    
    % distance from cube to goal
    dist_c_g = norm(cube - goal) * px_mm - robot_h;
    
    % print the command
    fprintf("%s CUBE! \n", upper(block));
    fprintf("turn(%0.2f); go(%0.2f); grab(); turn(%0.2f); go(%0.2f); let_go(); go(%d)\n", angle_r_c, dist_r_c, angle_c_g, dist_c_g, -15)
    
    res = sprintf("turn(%0.2f); go(%0.2f); grab(); turn(%0.2f); go(%0.2f); let_go(); go(%d)", angle_r_c, dist_r_c, angle_c_g, dist_c_g, -15);
    
    % calculate position of the robot after the first turn and go
    new_p = robot_f + v2/norm(v2)*norm(robot_f - cube);

    % plot the position
    plot3(new_p(1), new_p(2), new_p(3), 'ko')

    % plot the robots new position after moving the cube
    % new__new_p =  robot_f + v2/norm(v2)*norm(robot_f - cube) + v3/norm(v3)*( norm(cube - goal) - 15/px_mm);
    % new__new_p2 = robot_f + v2/norm(v2)*norm(robot_f - cube) + v3/norm(v3)*( norm(cube - goal) - 15/px_mm - 6/px_mm);
    % P(:, end - 1) = new__new_p;
    % P(:, end) = new__new_p2;
    % plot3(new__new_p(1),  new__new_p(2),  new__new_p(3),  'co')
    % plot3(new__new_p2(1), new__new_p2(2), new__new_p2(3), 'mo')
end



