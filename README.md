# VGA-Controller

This repository contains the code for a VGA controller capable of drawing lines on a VGA screen. The project focuses on creating datapaths, state machines, and using an embedded VGA core. The top-level diagram consists of the VGA core and the custom circuit responsible for generating the required patterns.

## Tasks Completed

### 1. Fill the Screen

A circuit is implemented to fill the screen with different colors in each column. The colors repeat every 8 columns.

### 2. Bresenham Line Algorithm

A circuit is implemented to draw lines using the Bresenham Line Algorithm. The circuit clears the screen and then proceeds to draw 14 lines, with each line having a different color based on a Gray code sequence.

### 3. Adding a delay and looping the display

The implementation is modified to draw one line at a time with a one-second delay between each line. The lines are erased after being drawn, creating a screen saver-like effect.

### 4. Challenge Task: Right Angle Triangle Drawing Algorithm

The existing implementation is used as the basis for a right angle triangle drawing algorithm. The Bresenham Line Algorithm generates the hypotenuse and the base of the triangle, with the base always being the central horizontal line that bisects the y-axis (vertical). Switches 7 downto 0 are used to specify the length of the base of the triangle from the center of the screen, and Key 0 is used to select this new value for the base dimension of the triangles.

## Getting Started

To use this project, simply clone the repository and open the project files in your preferred hardware description language editor. Follow the synthesis and implementation steps specific to your FPGA development board.

## License
