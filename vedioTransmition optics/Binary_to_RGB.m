

function [ output_image ] = Binary_to_RGB( R_binary_vector, G_binary_vector, B_binary_vector, Size1, Size2 )

output_image = zeros(Size1,Size2,3);

R_binary_matrix = reshape(R_binary_vector,8,[]);
G_binary_matrix = reshape(G_binary_vector,8,[]);
B_binary_matrix = reshape(B_binary_vector,8,[]);

R2 = bi2de(R_binary_matrix');
G2 = bi2de(G_binary_matrix');
B2 = bi2de(B_binary_matrix');

R1 = reshape(R2,Size1,Size2);
G1 = reshape(G2,Size1,Size2);
B1 = reshape(B2,Size1,Size2);

output_image(:,:,1) = R1;
output_image(:,:,2) = G1;
output_image(:,:,3) = B1;

output_image = uint8(output_image);
end

