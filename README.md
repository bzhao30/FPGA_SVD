# FPGA_SVD by Brandon Zhao
## FPGA implementation of singular value decomposition on Basys-3

This is a project for my digital electronics class using the Basys3 FPGA

To use, enter [# #;# #] over PUTTY. Due to resource limitations I have kept it to 2x2 matrices.
the '#' takes integer inputs only from 0-9

It will return SVD[# #;# #] = [# #;# #][# 0;0 #][# #;# #] accurate to one decimal point.

This singular value decomposition uses Hestenes-Jacobi SVD algorithm. 