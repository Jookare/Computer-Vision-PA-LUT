function [K, R, C] = decompose_projection(M)
% FIND_PROJECTION find the projection matrix using 2d and 3d coordinates.
%
%    Inputs:
%        p2: 2D coordinates from calibration image
%        p3: Corresponding 3D points from the real scene.
%           
%    Output:
%        M: Projection matrix

    % Find the projection matrix

    % C eq from slides
    X = det([M(:,2), M(:,3), M(:,4)]);
    Y = -det([M(:,1), M(:,3), M(:,4)]);
    Z = det([M(:,1), M(:,2), M(:,4)]);
    W = -det([M(:,1), M(:,2), M(:,3)]);
    C = [X; Y; Z] / W; % Normalise
    
    % Get KR from M
    KR = M/[eye(3), -C];
    % Get the K and R from the RQ decomposition
    [K, R] = rq(KR);
end

function [R, Q] = rq(KR)
    [Q, R] = qr(transpose(flipud(KR)));
    Q = flipud(transpose(Q));
    R = rot90(transpose(R), 2);
end