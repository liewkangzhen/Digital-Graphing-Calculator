EE2026 Digital Design

This is a final project for a digital design course taken in NUS. The main project theme is to create a Arithmetic calculator with basic addition, subtraction functions. There is also an option to go for open ended projects. Our team went for the middle ground. We wanted to creates something that stands out from a normal arithmetic calculator, but still want to keep the technical difficulty in designing a precise computing tool that has high functionality for students, while being able to exploit FPGA parallelism to create something special and unique. Thus we decided to create a graphing module, something similar to Desmos. There were many reasons as to why this would make a good project. First of all, there are mutliple techinical challenge that are not impossible to overcome, but useful for us to learn the important constructs and concepts in FPGA, and its use cases. For our calculator, we needed to decide on the fixed point math accuracy of our system. Because we have limited resources, we needed to manage what kind of width to we want for our results and intermediate values. This comes down to the user specifications. For our calculator, we decided that we do not need extremely high accuracy, as our tool is mainly for visual purposes, for the user to be able to see the shape intuitively, and to get a result that is accurate to certain decimal points is good enough, when we check the result with a calculator.

This was a team project, with a group of 4 members.
Credits to my teammates:
Chia Jia En
Ding Dao En
Nicholas Lee
Liew Kang Zhen (Me)

The HDL language used in this project is Verilog. The platform used was teh Xilinx Basys 3 FPGA board.

As this was quite a difficult project, considering that we had only around 3-4 weeks to complete along with our other academic commitments during the peak of our academic period, the initial planning phase was extremely important, as it sets the tone for a good project timeline. 

Here is an overview of the key features and innovations of our Graphing Module:

The graphing calculator supports three function types: polynomial, trigonometric, and exponential. To enhance user experience, it includes several user-oriented features. Visually, zoom fit is enabled by default, while users can pan and trace the graph using the mouse and scale both axes via push buttons. In addition, the calculator provides a dedicated display for function input and real-time x- and y-values, enabling clearer and more interactive graph analysis. 

CORDIC Trigonometric Computation
Coefficient & Real Time Cursor Output display
Trigonometric Computation:
Shift-add CORDIC iteration: Removes need for multipliers, improving efficiency
16-stage pipeline: Enables stable, high-throughput computation
Precomputed LUT: Reduces runtime complexity
Scaling factor compensation: Maintains output accuracy after iterative rotations

Coefficient and Output Display:
Adaptive fixed-point formatting: Switches between integer and fractional display
Sign-magnitude normalization: Ensures correct handling of negative values
Leading-zero suppression: Improves readability and reduces clutter
Real-time cursor tracking update: Dynamically updates x and y coordinates during graph tracing
Dynamic equation rendering: Displays corresponding mathematical expressions across multiple curve modes, improving interpretability and user interaction

Polynomial Computation, Keypad User Interface:

Polynomial Computation:
Implemented linear and quadratic function computation using signed fixed-point arithmetic.

Keypad User Interface: 
Implemented an OLED-based keypad UI for coefficient input and function control.
Supports up to 6-digit number entry with signed input using a +/- toggle.
An FSM-based editing system enables cursor movement, digit insertion, and deletion at selected positions for flexible input control.
Prevents invalid inputs by enforcing range constraints for each function mode.
Another FSM to enter coefficients sequentially for different functions.
Provides clear visual feedback through highlighted key selection and blinking cursor.
Users can confirm inputs, trigger graph plotting, and return to the menu, making the interface both robust and user-friendly.

Exponential LUT Computation, MEM File Generation & Function Selection Top Module Design:

Exponential LUT Computation: Direct implementation of exponential computation in HDL incurs significant area and timing overhead. Hence, exponential values are precomputed using Python and stored in a configurable LUT, where the table depth can be tuned according to the required precision.
MEM File Generation: The precomputed LUT is exported as a .mem file and loaded into registers during operation. This approach minimizes runtime computation, reduces design overhead, and improves timing slack, thereby supporting more responsive real-time graph rendering. 

Function Selection Design: Designed with both clarity and aesthetics in mind. A red highlight box is used to indicate the active selection, improving usability and making function toggling more visually distinct. 


Interactive Graphing Engine & Real-Time Coordinate Mapping System:
Interactive Tracing: Employs an FSM to toggle DRAG and TRACING modes. Tracing creates a static "snapshot" with the cursor constrained to the curve; a Dual-Module Path provides real-time, high-accuracy mathematical X/Y values to display modules.
Coordinate Mapping: Translates Pixel, World, BRAM, and Cursor coordinates for precise mouse tracking. Uses dynamic BRAM indexing to maintain mathematical alignment during viewport shifting.
Data Scaling: Normalizes -191 to 191 unit steps into function-specific domains (Trigo: 0.26 rad, Quad: 1, Exp: 0.01) using unified 48-bit BRAM for diverse Q-format storage.
Dynamic Viewport: Supports mouse-driven panning, dragging, and multi-axis scaling, including a quadratic Zoom-fit.
High-Fidelity Rendering: Implements span filling and shift registers to synchronize visual output with hardware latency.


