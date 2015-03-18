#How configure Raspbian

# Introduction #

DE0-nano program is setup to manage a particular DVI mode. Setup properly the DVI output is mandatory.

# /boot/config.txt #

```

hdmi_ignore_edid=0xa5000080
hdmi_force_hotplug=1

hdmi_group=1
hdmi_mode=8

framebuffer_width=320
framebuffer_heitgh=240

```