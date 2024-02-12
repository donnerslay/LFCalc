function matrix = createMatrix(row, col, sName)
    % INPUTMATRIX Function to input elements for a matrix of a predefined size.
    %   matrix = inputMatrix(rows, cols) takes the number of rows (rows) and
    %   columns (cols) as input and returns a matrix of the specified size with
    %   user-inputted elements.
    
    % initial the size
    matrix = zeros(row, col);
    msg = sprintf('creating Matrix %s \n', sName);
    disp(msg); %#ok<*DSPSP>
    
    % looping each elements of matrix
    for i = 1:row
        for j = 1:col
            prompt = sprintf('Enter the element at positon (%d, %d)', i, j);
            matrix(i, j) = input(prompt);
        end            
    end
    
end