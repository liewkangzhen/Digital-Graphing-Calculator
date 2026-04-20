# EE2026 Digital Design – FPGA Graphing Calculator

This project was completed as part of the **EE2026 Digital Design module at NUS**.

The base requirement was to design an arithmetic calculator supporting basic operations such as addition and subtraction. However, students were also given the option to pursue open-ended designs.

Our team chose a middle ground approach:  
we wanted to build something more advanced than a basic calculator, while still staying grounded in core digital design principles and FPGA constraints.

We decided to implement a **graphing calculator module**, inspired by tools such as Desmos, to explore how mathematical computation and real-time visualization can be realised on hardware.

---

## Motivation

The project was designed to:
- Explore non-trivial FPGA system design beyond arithmetic operations
- Understand trade-offs in **fixed-point precision vs hardware resource usage**
- Leverage **parallelism in FPGA architectures**
- Build an interactive system combining computation, memory, and display

A key design decision was choosing the **fixed-point representation**.  
Due to limited FPGA resources, we had to carefully balance:
- Bit-width of intermediate computations
- Output precision
- Visual accuracy vs hardware cost

Since the tool is primarily visual, we prioritised **intuitive correctness over numerical perfection**, ensuring plotted curves remain accurate to a reasonable decimal precision.

---

## Team

This was a 4-member team project:

- Chia Jia En  
- Ding Dao En  
- Nicholas Lee  
- Liew Kang Zhen (Me)

---

## Implementation Platform

- **HDL Language:** Verilog  
- **FPGA Board:** Xilinx Basys 3  

---

## Project Constraints

This project was completed within approximately **3–4 weeks**, alongside other academic commitments during a peak semester period.

As a result, **system-level planning and module integration strategy** were critical to ensure successful completion.

---

## System Overview

The graphing calculator supports three main function types:

- Polynomial
- Trigonometric
- Exponential

---

## User Features

### Interactive Graphing Interface
- Default **zoom-fit view**
- Mouse-based **panning and dragging**
- Real-time **curve tracing**
- Axis scaling via push buttons
- Live display of **(x, y) coordinates**

### Input System
- OLED-based keypad interface
- Function selection and coefficient entry
- FSM-based editing system with:
  - Cursor movement
  - Digit insertion and deletion
  - Signed input support (+/- toggle)
- Input validation per function type

---

## Core Modules & Technical Design

### CORDIC Trigonometric Computation
- Shift-add based CORDIC algorithm (no multipliers)
- 16-stage pipeline for stable throughput
- Precomputed LUT support for efficiency
- Scaling factor compensation for accuracy

---

### Fixed-Point & Output Representation
- Adaptive fixed-point formatting (integer + fractional display)
- Sign-magnitude normalization for negative values
- Leading-zero suppression for readability
- Real-time coordinate updates during tracing
- Dynamic equation display across function modes

---

### Polynomial Computation
- Linear and quadratic function support
- Signed fixed-point arithmetic implementation

---

### Keypad & UI FSM Design
- OLED-based keypad interface
- FSM-driven input handling system
- Robust coefficient entry system
- Visual feedback:
  - Highlighted selection
  - Blinking cursor
- Menu navigation with plot confirmation and reset options

---

### Exponential LUT System
- Exponential values precomputed using Python
- Stored in configurable LUT (.mem file)
- Depth adjustable based on precision requirements
- Runtime LUT loading into registers

Benefits:
- Reduced hardware complexity
- Improved timing slack
- Faster graph rendering

---

### Function Selection Module
- Clear UI-based function switching
- Red highlight indicator for active selection
- Improved usability and visual clarity

---

## Interactive Graphing Engine

### Coordinate Mapping System
- Pixel coordinates
- World coordinates
- BRAM index mapping
- Cursor tracking system

Ensures consistent alignment between:
- Mouse interaction
- Mathematical function domain
- Memory storage layout

---

### Dynamic Viewport Control
- Mouse-driven panning and dragging
- Multi-axis scaling support
- Quadratic zoom-fit functionality

---

### Curve Rendering Pipeline
- Dual-port BRAM for concurrent read/write
- Span filling for smooth curve rendering
- Shift-register alignment for pipeline delay compensation
- Supports continuous curve output under scaling transformations

---

### Real-Time Tracing System
- FSM-based DRAG / TRACE mode switching
- Cursor constrained to curve during tracing
- Dual-module architecture ensures:
  - Accurate mathematical output
  - Independent rendering consistency

---

### Data Scaling Strategy
- Normalisation of input range: **-191 to 191**
- Function-specific scaling:
  - Trigonometric: 0.26 rad per step
  - Quadratic: 1 unit step
  - Exponential: 0.01 unit step
- Unified **48-bit BRAM storage**
  - Supports mixed Q-formats:
    - Q48.0 (quadratic)
    - Q40.8 (CORDIC)
    - Q32.16 (exponential)

---

## Key Challenges

- Clock domain and timing alignment issues
- Pipeline latency management (CORDIC delay compensation)
- Coordinate system consistency across modules
- BRAM indexing accuracy during dynamic scaling
- Resource constraints due to fixed-point design decisions

---

## Reflection

What stood out most in this project was how quickly a “graphing calculator” becomes a **full system design problem** in hardware.

Small decisions in:
- Bit-width
- Memory architecture
- Timing design

...had cascading effects across the entire system.

---

## Result

A fully functional FPGA-based graphing calculator capable of:
- Real-time function plotting
- Interactive graph manipulation
- Accurate coordinate tracing
- Multi-function mathematical visualization

---

## Acknowledgements

Chia Jia En  
Ding Dao En  
Nicholas Lee  

---

## Takeaway

FPGA design is not just about implementing functionality.  
It is about making everything work together under strict **timing, resource, and architectural constraints**.
