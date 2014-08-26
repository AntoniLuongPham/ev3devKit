/*
 * ev3devKit - ev3dev toolkit for LEGO MINDSTORMS EV3
 *
 * Copyright 2014 David Lechner <david@lechnology.com>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
 * MA 02110-1301, USA.
 */

/* main.vala - main function for running demo on desktop */

namespace EV3devKit {
    public static int main (string[] args) {
        DesktopTestApp.init (args);

        var demo_window_1 = new DemoWindow ();
        demo_window_1.quit.connect (DesktopTestApp.quit);
        DesktopTestApp.stock_screen.push_window (demo_window_1);

        var demo_window_2 = new DemoWindow ();
        demo_window_2.quit.connect (DesktopTestApp.quit);
        DesktopTestApp.color_screen.push_window (demo_window_2);

        DesktopTestApp.run ();

        return 0;
    }
}
