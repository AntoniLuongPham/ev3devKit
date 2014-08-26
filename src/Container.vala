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

/* Container.vala - Base class widgets that contain other widgets*/

using Gee;
using GRX;

namespace EV3devKit {

    /**
     * Specifies the number of children a container can have.
     */
    public enum ContainerType {
        /**
         * Container can only have one child.
         */
        SINGLE,
        /**
         * Container can have more than one child.
         */
        MULTIPLE
    }

    public abstract class Container : EV3devKit.Widget {
        protected LinkedList<Widget> _children;

        /**
         * Gets the first child of the Container.
         *
         * Useful when container_type == ContainerType.SINGLE
         */
        public Widget? child {
            owned get {
                if (_children.size == 0)
                    return null;
                return _children.first ();
            }
        }

        /**
         * Gets a read-only list of children of the Container.
         */
        public Gee.List<Widget> children {
            owned get { return _children.read_only_view; }
        }

        public bool descendant_has_focus {
            get {
                foreach (var item in children) {
                    var focused = item.do_recursive_children ((widget) => {
                        if (widget.has_focus)
                            return widget;
                        return null;
                    });
                    if (focused != null)
                        return true;
                }
                return false;
            }
        }

        public virtual bool draw_children_as_focused {
            get {
                if (parent != null)
                    return parent.draw_children_as_focused;
                return false;
            }
        }

        public ContainerType container_type { get; private set; }

        public signal void child_added (Widget child);
        public signal void child_removed (Widget child);

        protected Container (ContainerType type) {
            container_type = type;
            _children = new LinkedList<Widget> ();
        }

        public override int get_preferred_width () {
            return (child == null ? 0 : child.get_preferred_width ())
                + get_margin_border_padding_width ();
        }

        public override int get_preferred_height () {
            return (child == null ? 0 : child.get_preferred_height ())
                + get_margin_border_padding_height ();
        }

        public override int get_preferred_width_for_height (int height) requires (height > 0) {
            var result = get_margin_border_padding_width ();
            if (child != null)
                result += child.get_preferred_width_for_height (height - result);
            return result;
        }

        public override int get_preferred_height_for_width (int width) requires (width > 0) {
            var result = get_margin_border_padding_height ();
            if (child != null)
                result += child.get_preferred_height_for_width (width - result);
            return result;
        }

        public void add (Widget widget) requires (!(widget is Window)) {
            if (widget.parent != null)
                widget.parent.remove (widget);
            if (container_type == ContainerType.SINGLE) {
                if (_children.size > 0)
                    remove (_children.first ());
                _children.offer_head (widget);
            } else
                _children.add (widget);
            widget.parent = this;
            redraw ();
            child_added (widget);
        }

        public void remove (Widget widget) {
            if (_children.remove (widget)) {
                widget.parent = null;
                redraw ();
                child_removed (widget);
            }
        }

        protected void set_child_bounds (Widget child, int x1, int y1, int x2, int y2) {
            var width = x2 - x1 + 1;
            var height = y2 - y1 + 1;
            // TODO add width_for_height
            if (child.horizontal_align != WidgetAlign.FILL)
                width = int.min (width, child.get_preferred_width ());
            if (child.vertical_align != WidgetAlign.FILL)
                height = int.min (height, child.get_preferred_height_for_width (width));
            switch (child.horizontal_align) {
            case WidgetAlign.START:
                x2 = x1 + width - 1;
                break;
            case WidgetAlign.CENTER:
                x1 += (x2 - x1 - width) / 2;
                x2 = x1 + width - 1;
                break;
            case WidgetAlign.END:
                x1 = x2 - width + 1;
                break;
            }
            switch (child.vertical_align) {
            case WidgetAlign.START:
                y2 = y1 + height - 1;
                break;
            case WidgetAlign.CENTER:
                y1 += (y2 - y1 - height) / 2;
                y2 = y1 + height - 1;
                break;
            case WidgetAlign.END:
                y1 = y2 - height + 1;
                break;
            }
            child.set_bounds (x1, y1, x2, y2);
        }

        protected override void do_layout () {
            foreach (var child in children)
                set_child_bounds (child, content_bounds.x1, content_bounds.y1,
                    content_bounds.x2, content_bounds.y2);
        }

        protected override void draw_content () {
            foreach (var child in children)
                child.draw ();
        }
    }
}
