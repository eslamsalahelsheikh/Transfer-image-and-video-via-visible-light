
function [ R_binary_vector, G_binary_vector, B_binary_vector ] = RGB_to_Binary( input_image )

R1 = input_image(:,:,1);
G1 = input_image(:,:,2);
B1 = input_image(:,:,3);

R2 = reshape(R1,1,[]);
G2 = reshape(G1,1,[]);
B2 = reshape(B1,1,[]);

R_binary_matrix = de2bi(R2)';
G_binary_matrix = de2bi(G2)';
B_binary_matrix = de2bi(B2)';

R_binary_vector = reshape(R_binary_matrix,1,[]);
G_binary_vector = reshape(G_binary_matrix,1,[]);
B_binary_vector = reshape(B_binary_matrix,1,[]);

end