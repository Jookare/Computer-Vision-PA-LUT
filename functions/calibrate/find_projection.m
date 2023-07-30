function M = find_projection(p2,p3)
% FIND_PROJECTION find the projection matrix using 2d and 3d coordinates.
%
%    Inputs:
%        p2: 2D coordinates from calibration image
%        p3: Corresponding 3D points from the real scene.
%           
%    Output:
%        M: Projection matrix

    % Calibrate using normalization
    % Construct T
    x_m = mean(p2(1,:));
    y_m = mean(p2(2,:));
    d_m = 1/length(p2)*sum(sqrt( (p2(1,:) - x_m).^2 + (p2(2,:) - y_m).^2) );
    
    % Matrix eq from the lecture notes
    T = [sqrt(2)/d_m    0           -sqrt(2)*x_m/d_m; 
         0              sqrt(2)/d_m -sqrt(2)*y_m/d_m;
         0              0            1];
    
    % Construct U
    X_m = mean(p3(1,:));
    Y_m = mean(p3(2,:));
    Z_m = mean(p3(3,:));
    D_m = 1/length(p3)*sum(sqrt( (p3(1,:) - X_m).^2 + (p3(2,:) - Y_m).^2 + (p3(3,:) - Z_m).^2));
    
    % Matrix eq from the lecture notes
    U = [sqrt(3)/D_m    0           0           -sqrt(3)*X_m/D_m; 
         0              sqrt(3)/D_m 0           -sqrt(3)*Y_m/D_m; 
         0              0           sqrt(3)/D_m -sqrt(3)*Z_m/D_m; 
         0              0           0            1];

    % Create the extended vectors for multiplication
    p2i = [p2; ones(1, length(p2))];
    p3i = [p3; ones(1, length(p3))];

    % Calculate the normalized coordinates
    p2n = T*p2i;
    p3n = U*p3i;

    % Find the normalized projection matrix
    Mn = projection(p2n,p3n);
    
    % Unnormalize the matrix
    M = T\(Mn*U);
end

function M = projection(p2,p3)
    A = [];
    for i = 1:length(p2)
        w1 = [-p2(1,i)*p3(1,i), -p2(1,i)*p3(2,i), -p2(1,i)*p3(3,i), -p2(1,i)];
        w2 = [-p2(2,i)*p3(1,i), -p2(2,i)*p3(2,i), -p2(2,i)*p3(3,i), -p2(2,i)];
        A(end + 1,:) = [p3(1,i), p3(2,i), p3(3,i), 1, 0, 0, 0, 0, w1];
        A(end + 1,:) = [0, 0, 0, 0, p3(1,i), p3(2,i), p3(3,i), 1, w2];
    end
    % Use the singular value decomposition
    [~,~,V] = svd(A);

    % Matlab uses Column major so need to reshape to 4 by 3 and then
    % transpose to get the correct form
    M = reshape(V(:,end), 4,3)';
end
