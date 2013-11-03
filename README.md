http://www.eliteraspberries.com/blog/2013/09/cflags-for-numerical-computing-on-the-beaglebone-black.html

CFLAGS="-march=armv7-a -mtune=cortex-a8 -mfloat-abi=hard -mfpu=neon -ffast-math -O3 -pipe -fstack-protector --param=ssp-buffer-size=4"
CXXFLAGS="-march=armv7-a -mtune=cortex-a8 -mfloat-abi=hard -mfpu=neon -O3 -pipe -fstack-protector --param=ssp-buffer-size=4"
