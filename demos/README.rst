upload-image.sh
---------------

What does it do ?
~~~~~~~~~~~~~~~~~

Loads an image on the SDRAM throught the serial port and displays it using the HDMI.

On ULX3S kit
~~~~~~~~~~~~

What do I need to run it ?
~~~~~~~~~~~~~~~~~~~~~~~~~~

On UN*X
~~~~~~~

.. _upload-image.sh: ./upload-image.sh

.. _Imagemagick: https://imagemagick.org

Imagemagick_ is required to convert *your_image.your_format* to 800x600 RGB8. There is no need to change your image to that format. Imagemagick_ will be called by upload-image.sh_ script and will do it for you.

Download https://github.com/hdl4fpga/hdl4fpga.github.io/raw/master/demos/graphic/ULX3S/bits/demos_graphic-12F200MHz-3000000bps.bit bitstream.

Open a console on demos directory and run

**IMAGE="your_image_path/your_image.your_format" PROG="ujprog your_bit_path/demos_graphic-12F200MHz-3000000bps.bit" TTY="your_serial_device" ./upload-image.sh**


Remember that all the **bold text** should be on the same line

motion.sh
---------

What does it do ?
~~~~~~~~~~~~~~~~~

Loads multiple images on the SDR SDRAM at consecutive addresses and then animates them by changing the video base address. Images are loaded throught the serial port

On ULX3S kit
~~~~~~~~~~~~

What do I need to run it ?
~~~~~~~~~~~~~~~~~~~~~~~~~~

On UN*X
~~~~~~~

.. _motion.sh: ./motion.sh

.. _Imagemagick: https://imagemagick.org

.. _ffmpeg: https://ffmpeg.org/

ffmpeg_ is required to convert *your_motion.your_format* to image frames and Imagemagick_ is required to convert the images frames to 800x600 RGB8.

Download https://github.com/hdl4fpga/hdl4fpga.github.io/raw/master/demos/graphic/ULX3S/bits/demos_graphic-12F200MHz-3000000bps.bit bitstream.

Open a console on demos directory and run:

**MOTION="your_motion_path/your_motion.your_format" LOAD=YES FPS=30 PROG="ujprog your_bit_path/demos_graphic-12F200MHz-3000000bps.bit" TTY="your_serial_device" ./motion.sh**

To run it again without loading, don't set the **LOAD** variable. To select another **FPS** to animate the images, set the **FPS** variable to the desire value.

**MOTION="your_motion_path/your_motion.your_format" FPS=60 TTY="your_serial_device" ./motion.sh**

Remember that all the **bold text** should be on the same line

I'm curious : Where is the project file ?
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. _demos: ../ULX3S/diamond/demos.ldf

Here you can find the demos_ project file.

Enjoy it!
