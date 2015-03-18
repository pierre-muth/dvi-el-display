# Introduction #

Planar company makes nice and robust dot-matrix electro-luminescent display.
http://lumineq.com/en/product-tags/diagonal-size-57-2
![http://lumineq.com/sites/default/files/styles/product_image/public/product/fields/field_images/4_7904.jpg](http://lumineq.com/sites/default/files/styles/product_image/public/product/fields/field_images/4_7904.jpg)
The aim of this project is to get the 320.240.36 working with the RaspberryPi.
This display doesn't have a controller, means it need timings signals and pixel data 4 by 4. First working solution was to use a SED1335 compatible controller, such as the RAIO8835. But even using the GPIO of the Rpi, data transfer rate is too low to get video and no half tone.
Second option was to use a FPGA as custom controller. TI makes a DVI to parallel chip, the TFP401 http://www.ti.com/product/tfp401a. Then the DVI output of the raspberry can be directly used. Here the Terasic Development board DE0-Nano made around and Altera Cyclone IV is used as timing generator for the EL display, and process the data coming from the TFP401.

![http://www.terasic.com.tw/attachment/archive/593/image/image_60_thumb.jpg](http://www.terasic.com.tw/attachment/archive/593/image/image_60_thumb.jpg)

<a href='http://www.youtube.com/watch?feature=player_embedded&v=7r3l-sRMSfA' target='_blank'><img src='http://img.youtube.com/vi/7r3l-sRMSfA/0.jpg' width='425' height=344 /></a>

Here the expansion board for the DE0\_nano containing the TFP401A and a 3.3v - 5v level translator.

![http://muth.inc.free.fr/planar/IMG_7346.jpg](http://muth.inc.free.fr/planar/IMG_7346.jpg)

![http://muth.inc.free.fr/planar/IMG_7347.jpg](http://muth.inc.free.fr/planar/IMG_7347.jpg)

And mounted on the DE0\_nano :

![http://muth.inc.free.fr/planar/IMG_7348.jpg](http://muth.inc.free.fr/planar/IMG_7348.jpg)