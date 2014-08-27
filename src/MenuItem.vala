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

/* MenuItem.vala - Base class for menu items used by Menu widget */

namespace EV3devKit {
    public class MenuItem : Object {
        static int menu_item_count = 0;

        internal ulong notify_has_focus_signal_id;

        public weak Menu menu { get; internal set; }
        public Button button { get; private set; }
        public Object? represented_object { get; private set; }

        public MenuItem (string text, Object? represented_object = null) {
            this.with_button (new Button.with_label (text) {
                border = 0
            });
        }

        public MenuItem.with_button (Button button, Object? represented_object = null) {
            this.button = button;
            button.represented_object = this;
            this.represented_object = represented_object;
            weak_ref (weak_notify);
            menu_item_count++;
            debug ("Created MenuItem: %p", this);
        }

        static void weak_notify (Object obj) {
            var menu_item = obj as MenuItem;
            if (menu_item.notify_has_focus_signal_id != 0)
                SignalHandler.disconnect (menu_item.button, menu_item.notify_has_focus_signal_id);
        }

        ~MenuItem () {
            debug ("Finalized MenuItem: %p", this);
            debug ("MenuItem count %d", --menu_item_count);
        }
    }
}