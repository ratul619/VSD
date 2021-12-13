# TensorCore Accelerator for Machine Learning

 
 
# Abstract— This project focuses on implementing a Deep Learning hardware accelerator called TensorCore - which is a Vector Processor based on v0.10 of the open source RISCV Vector ISA. It is expected to serve as a proof-point for a Deep Learning research platform to experiment with tensor operators and custom number systems. 
# I.	INTRODUCTION 
In the general case, an array of numbers arranged on a regular grid with a variable number of axes is known as a tensor. The raising markets of AI-based data analytics and deep learning applications, such as software for self-driving cars, have pushed several companies to develop specialized hardware to boost the performance of large dense matrix (tensor) computation [1] . A vector processor is one whose instructions operate on vectors rather than scalar (single data) values. The basic requirements can be:
•	Need to load/store vectors:  vector registers (contain vectors)
•	Need to operate on vectors of different lengths : vector length register (VLEN)
•	Elements of a vector might be stored apart from each other in memory : vector stride register 
Fig 1 shows simplified view of a vector processor with one functional unit for arithmetic operations (VFU

 
			Fig1. 

II.	VECTOR OPERATION : SAXPY AND DAXPY 

DAXPY and SAXPY form the basic vector operations. SAXPY stands for “Single-Precision A·X Plus Y”.  SAXPY is a combination of scalar multiplication and vector addition, and it’s very simple: it takes as input two vectors of 32-bit floats X and Y with N elements each, and a scalar value A. It multiplies each element X[i] by A and adds the result to Y[i]. A simple C implementation looks like this.


void saxpy(int n, float a, float x, float y)
{
  for (int i = 0; i < n; ++i)
      y[i] = a*x[i] + y[i];
}

DAXPY stands for “Double-Precision A·X Plus Y”, and in DAXPY the elements X and Y are 64bit floats. If we take matrix multiplication, it’s a special case of SAXPY or DAXPY with addition not being part of the operation. 

III.	MATMUL OPERATION

Fig3b shows how the multiplication takes place for a 4x4 matrix. 


 

 

Observing if we can process four multiplication and addition in parallel per cycle and pipeline the floating point ALU operations, going row wise or column wise, then we can produce four output matrix elements in parallel, essentially executing four SAXPY or DAXPY with no addition operation. These parallel operations can be managed in the vector lanes described in next section.
IV.	VECTOR PIPELINES AND LANES
Datapath and register files resources can be organized
in vector lanes [2]. Fig2 shows Organization of a four-lane
with each lane storing fourth element of vector register. 
Each lane contains one portion of the vector-register file and one execution pipeline from each vector functional unit. The first lane holds the first element (element 0) for all vector registers, and so the first element in any vector instruction will have its source and destination operands located in the first lane. 
There are three vector functional units shown, an FP add, an FP multiply, and a load-store unit. Each of the vector arithmetic units contains four execution pipelines, one per lane, that act in concert to complete a single vector instruction. 

 

				Fig2
ARA [4]   The vector register files is implemented as  VRF structure (eight 64-bit wide 1RW banks) is replicated at each lane. vector register file is composed of a set of singleported (1RW) banks. The width of each bank is constrained to the datapath width of each lane, i.e., 64 bit. 
V.	VECTOR LANES AND MATMUL OPERATION

Considering we have four vector lanes , we can divide the operation of the 4x4 matmul operation as shown graphically in Fig3. Fig3 shows only the VEU (Vector execution unit) and the task of feeding the vector lies on the VLDU ( Vector load store unit) . The interaction and communication is shown in Fig4 . The VEU , consists of floating point multipliers and adders , which can be implemented in through different precisions , single or double , and also other data types such as bfloat16 , f16 (IEEE half precision floating point).  The selection of these standards are critical , as the performance of the VEU will depend on them [5].  A fused dot product approach can also be adopted that performs single-precision floating-point multiplication and addition operations on two pairs of data in a time that is only 150% the time required for a conventional floating-point multiplication [6] . 


 Fig3

 
				Fig4. 
VI.	 

VII.	RISC-V ISA VECTOR EXTENSION
The RISC-V [3] is an open-source hardware born in 2010 at the University of California, Berkeley as an academic research project. The first proposal of a Vector Extension for RISC-V has seen the light in June 2015 , the latest 1.0 version being in Sept 2021. 

REFERENCES

[1]	I.Goodfellow, Y. Bengio, and A. Courville, Deep learning. MIT press, 2016
[2]	C. Kozyrakis, et al. Hardware/Compiler Codevelopment for an Embedded Media Processor. In Proceedings of the IEEE, Nov. 2001. 
[3]	Risc-v history. (accessed on august 2020). https://riscv.org/ risc-v-history/. 
[4] Ara: A 1 GHz+ Scalable and Energy-Efficient RISC-V Vector Processor with Multi-Precision Floating Point Support in 22 nm FD-SOI

[5] N. Burgess, J. Milanovic, N. Stephens, K. Monachopoulos and D. Mansell, "Bfloat16 Processing for Neural Networks," 2019 IEEE 26th Symposium on Computer Arithmetic (ARITH), 2019, pp. 88-91, doi: 10.1109/ARITH.2019.00022.

[6] H. H. Saleh and E. E. Swartzlander, "A floating-point fused dot-product unit," 2008 IEEE International Conference on Computer Design, 2008, pp. 427-431, doi: 10.1109/ICCD.2008.4751896.  


