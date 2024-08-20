# FPGA_SVD by Brandon Zhao
### FPGA implementation of singular value decomposition on Basys-3

This is a project for my digital electronics class using the Basys3 FPGA

To use, enter [# #;# #] over PUTTY. Due to resource limitations I have kept it to 2x2 matrices.
the '#' takes integer inputs only from 0-9

It will return SVD[# #;# #] = [# #;# #][# 0;0 #][# #;# #] accurate to one decimal point.

This singular value decomposition uses the One-Sided Jacobi SVD algorithm. 

References:
https://www.cs.utexas.edu/~flame/laff/alaff/chapter11-one-sided-Jacobi-method.html
https://www.cosy.sbg.ac.at/research/tr/2007-02_Oksa_Vajtersic.pdf