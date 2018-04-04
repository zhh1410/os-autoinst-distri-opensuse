# SUSE's openQA tests
#
# Copyright © 2018 SUSE LLC
#
# Copying and distribution of this file, with or without modification,
# are permitted in any medium without royalty provided the copyright
# notice and this notice are preserved.  This file is offered as-is,
# without any warranty.

# Summary: steam GUI app startup test
# Maintainer: Oliver Kurz <okurz@suse.de>

use base 'x11test';
use strict;
use testapi;
use utils;

sub run {
    select_console 'x11';
    ensure_installed 'steam';
    x11_start_program('xterm');
    turn_off_gnome_screensaver;
    # start steam in terminal to watch the progress on initial startup, e.g.
    # the update progress
    script_run 'steam', 0;
    assert_and_click 'steam-accept-agreement';
    assert_and_click 'steam-agreement-ok';
    assert_screen([qw(steam-login steam-startup-libgl_error)], 600);
    if (match_has_tag 'steam-startup-libgl_error') {
        # https://github.com/ValveSoftware/steam-for-linux/issues/4768
        # https://wiki.archlinux.org/index.php/Steam/Troubleshooting#Steam_runtime
        # apply workaround from
        # https://askubuntu.com/questions/614422/problem-with-installing-steam-on-ubuntu-15-04
        send_key 'ctrl-c';
        script_run 'clear', 0;
        assert_screen 'xterm';
        assert_script_run
'find $HOME/.steam/root/ubuntu12_32/steam-runtime/*/usr/lib/ \( -name "libstdc++.so.6" -o -name "libgpg-error.so.0" -o -name "libxcb.so.1" -o -name "libgcc_s.so.1" \) -exec mv "{}" "{}.bak" \; -print';
        script_run 'steam', 0;
    }
    assert_screen 'steam-login', 600;
    send_key 'alt-f4';
    script_run 'exit', 0;
}

1;
# vim: set sw=4 et:
