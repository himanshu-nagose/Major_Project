function [x] = OMP(K, y, A)
    % OMP: Orthogonal Matching Pursuit for sparse signal recovery
    %
    % Inputs:
    %   K - Sparsity level (number of non-zero elements)
    %   y - Measurement vector (m x 1)
    %   A - Measurement matrix (m x n)
    %
    % Output:
    %   x - Reconstructed sparse solution (n x 1)

    % Check if correct number of arguments is provided
    if nargin < 3
        error('OMP requires three input arguments: K, y, and A.');
    end

    % Validate input dimensions
    [m, n] = size(A);
    if length(y) ~= m
        error('The length of vector y must match the number of rows in matrix A.');
    end
    if K > min(m, n)
        error('K cannot exceed the smaller dimension of matrix A.');
    end

    % Initialize variables
    Res = y;                   % Initial residual
    support_set = [];          % Indices of selected atoms
    x = zeros(n, 1);           % Solution vector initialized to zeros

    % Main OMP iteration loop
    for j = 1:K
        % Step 1: Select the atom most correlated with the residual
        [~, idx] = max(abs(A' * Res));

        % Step 2: Update the support set with the selected atom
        support_set = [support_set, idx];

        % Step 3: Solve the least squares problem to update the solution
        A_selected = A(:, support_set);
        x_selected = A_selected \ y;

        % Step 4: Update the residual
        Res = y - A_selected * x_selected;
    end

    % Step 5: Map the solution values to the appropriate indices
    x(support_set) = x_selected;
end
