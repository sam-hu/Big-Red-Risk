# graphics.py
"""Simple object oriented graphics library

The library is designed to make it very easy for novice programmers to
experiment with computer graphics in an object oriented fashion. It is
written by John Zelle for use with the book "Python Programming: An
Introduction to Computer Science" (Franklin, Beedle & Associates).

LICENSE: This is open-source software released under the terms of the
GPL (http://www.gnu.org/licenses/gpl.html).

PLATFORMS: The package is a wrapper around Tkinter and should run on
any platform where Tkinter is available.

INSTALLATION: Put this file somewhere where Python can see it.

OVERVIEW: There are two kinds of objects in the library. The GraphWin
class implements a window where drawing can be done and various
GraphicsObjects are provided that can be drawn into a GraphWin. As a
simple example, here is a complete program to draw a circle of radius
10 centered in a 100x100 window:

--------------------------------------------------------------------
from graphics import *

def main():
    win = GraphWin("My Circle", 100, 100)
    c = Circle(Point(50,50), 10)
    c.draw(win)
    win.getMouse() # Pause to view result
    win.close()    # Close window when done

main()
--------------------------------------------------------------------
GraphWin objects support coordinate transformation through the
setCoords method and mouse and keyboard interaction methods.

The library provides the following graphical objects:
    Point
    Line
    Circle
    Oval
    Rectangle
    Polygon
    Text
    Entry (for text-based input)
    Image

Various attributes of graphical objects can be set such as
outline-color, fill-color and line-width. Graphical objects also
support moving and hiding for animation effects.

The library also provides a very simple class for pixel-based image
manipulation, Pixmap. A pixmap can be loaded from a file and displayed
using an Image object. Both getPixel and setPixel methods are provided
for manipulating the image.

DOCUMENTATION: For complete documentation, see Chapter 4 of "Python
Programming: An Introduction to Computer Science" by John Zelle,
published by Franklin, Beedle & Associates.  Also see
http://mcsp.wartburg.edu/zelle/python for a quick reference"""

__version__ = "5.0"

# Version 5 8/26/2016
#     * update at bottom to fix MacOS issue causing askopenfile() to hang
#     * update takes an optional parameter specifying update rate
#     * Entry objects get focus when drawn
#     * __repr_ for all objects
#     * fixed offset problem in window, made canvas borderless

# Version 4.3 4/25/2014
#     * Fixed Image getPixel to work with Python 3.4, TK 8.6 (tuple type handling)
#     * Added interactive keyboard input (getKey and checkKey) to GraphWin
#     * Modified setCoords to cause redraw of current objects, thus
#       changing the view. This supports scrolling around via setCoords.
#
# Version 4.2 5/26/2011
#     * Modified Image to allow multiple undraws like other GraphicsObjects
# Version 4.1 12/29/2009
#     * Merged Pixmap and Image class. Old Pixmap removed, use Image.
# Version 4.0.1 10/08/2009
#     * Modified the autoflush on GraphWin to default to True
#     * Autoflush check on close, setBackground
#     * Fixed getMouse to flush pending clicks at entry
# Version 4.0 08/2009
#     * Reverted to non-threaded version. The advantages (robustness,
#         efficiency, ability to use with other Tk code, etc.) outweigh
#         the disadvantage that interactive use with IDLE is slightly more
#         cumbersome.
#     * Modified to run in either Python 2.x or 3.x (same file).
#     * Added Image.getPixmap()
#     * Added update() -- stand alone function to cause any pending
#           graphics changes to display.
#
# Version 3.4 10/16/07
#     Fixed GraphicsError to avoid "exploded" error messages.
# Version 3.3 8/8/06
#     Added checkMouse method to GraphWin
# Version 3.2.3
#     Fixed error in Polygon init spotted by Andrew Harrington
#     Fixed improper threading in Image constructor
# Version 3.2.2 5/30/05
#     Cleaned up handling of exceptions in Tk thread. The graphics package
#     now raises an exception if attempt is made to communicate with
#     a dead Tk thread.
# Version 3.2.1 5/22/05
#     Added shutdown function for tk thread to eliminate race-condition
#        error "chatter" when main thread terminates
#     Renamed various private globals with _
# Version 3.2 5/4/05
#     Added Pixmap object for simple image manipulation.
# Version 3.1 4/13/05
#     Improved the Tk thread communication so that most Tk calls
#        do not have to wait for synchonization with the Tk thread.
#        (see _tkCall and _tkExec)
# Version 3.0 12/30/04
#     Implemented Tk event loop in separate thread. Should now work
#        interactively with IDLE. Undocumented autoflush feature is
#        no longer necessary. Its default is now False (off). It may
#        be removed in a future version.
#     Better handling of errors regarding operations on windows that
#       have been closed.
#     Addition of an isClosed method to GraphWindow class.

# Version 2.2 8/26/04
#     Fixed cloning bug reported by Joseph Oldham.
#     Now implements deep copy of config info.
# Version 2.1 1/15/04
#     Added autoflush option to GraphWin. When True (default) updates on
#        the window are done after each action. This makes some graphics
#        intensive programs sluggish. Turning off autoflush causes updates
#        to happen during idle periods or when flush is called.
# Version 2.0
#     Updated Documentation
#     Made Polygon accept a list of Points in constructor
#     Made all drawing functions call TK update for easier animations
#          and to make the overall package work better with
#          Python 2.3 and IDLE 1.0 under Windows (still some issues).
#     Removed vestigial turtle graphics.
#     Added ability to configure font for Entry objects (analogous to Text)
#     Added setTextColor for Text as an alias of setFill
#     Changed to class-style exceptions
#     Fixed cloning of Text objects

# Version 1.6
#     Fixed Entry so StringVar uses _root as master, solves weird
#            interaction with shell in Idle
#     Fixed bug in setCoords. X and Y coordinates can increase in
#           "non-intuitive" direction.
#     Tweaked wm_protocol so window is not resizable and kill box closes.

# Version 1.5
#     Fixed bug in Entry. Can now define entry before creating a
#     GraphWin. All GraphWins are now toplevel windows and share
#     a fixed root (called _root).

# Version 1.4
#     Fixed Garbage collection of Tkinter images bug.
#     Added ability to set text atttributes.
#     Added Entry boxes.

import time, os, sys
from itertools import cycle

try:  # import as appropriate for 2.x vs. 3.x
   import tkinter as tk
except:
   import Tkinter as tk


##########################################################################
# Module Exceptions

class GraphicsError(Exception):
    """Generic error class for graphics module exceptions."""
    pass

OBJ_ALREADY_DRAWN = "Object currently drawn"
UNSUPPORTED_METHOD = "Object doesn't support operation"
BAD_OPTION = "Illegal option value"

##########################################################################
# global variables and funtions

_root = tk.Tk()
_root.withdraw()

_update_lasttime = time.time()

def update(rate=None):
    global _update_lasttime
    if rate:
        now = time.time()
        pauseLength = 1/rate-(now-_update_lasttime)
        if pauseLength > 0:
            time.sleep(pauseLength)
            _update_lasttime = now + pauseLength
        else:
            _update_lasttime = now

    _root.update()

############################################################################
# Graphics classes start here

class GraphWin(tk.Canvas):

    """A GraphWin is a toplevel window for displaying graphics."""

    def __init__(self, title="Graphics Window",
                 width=200, height=200, autoflush=True):
        assert type(title) == type(""), "Title must be a string"
        master = tk.Toplevel(_root)
        master.protocol("WM_DELETE_WINDOW", self.close)
        tk.Canvas.__init__(self, master, width=width, height=height,
                           highlightthickness=0, bd=0)
        self.master.title(title)
        self.pack()
        master.resizable(0,0)
        self.foreground = "black"
        self.items = []
        self.mouseX = None
        self.mouseY = None
        self.bind("<Button-1>", self._onClick)
        self.bind_all("<Key>", self._onKey)
        self.height = int(height)
        self.width = int(width)
        self.autoflush = autoflush
        self._mouseCallback = None
        self.trans = None
        self.closed = False
        master.lift()
        self.lastKey = ""
        if autoflush: _root.update()

    def __repr__(self):
        if self.isClosed():
            return "<Closed GraphWin>"
        else:
            return "GraphWin('{}', {}, {})".format(self.master.title(),
                                             self.getWidth(),
                                             self.getHeight())

    def __str__(self):
        return repr(self)

    def __checkOpen(self):
        if self.closed:
            raise GraphicsError("window is closed")

    def _onKey(self, evnt):
        self.lastKey = evnt.keysym


    def setBackground(self, color):
        """Set background color of the window"""
        self.__checkOpen()
        self.config(bg=color)
        self.__autoflush()

    def setCoords(self, x1, y1, x2, y2):
        """Set coordinates of window to run from (x1,y1) in the
        lower-left corner to (x2,y2) in the upper-right corner."""
        self.trans = Transform(self.width, self.height, x1, y1, x2, y2)
        self.redraw()

    def close(self):
        """Close the window"""

        if self.closed: return
        self.closed = True
        self.master.destroy()
        self.__autoflush()


    def isClosed(self):
        return self.closed


    def isOpen(self):
        return not self.closed


    def __autoflush(self):
        if self.autoflush:
            _root.update()


    def plot(self, x, y, color="black"):
        """Set pixel (x,y) to the given color"""
        self.__checkOpen()
        xs,ys = self.toScreen(x,y)
        self.create_line(xs,ys,xs+1,ys, fill=color)
        self.__autoflush()

    def plotPixel(self, x, y, color="black"):
        """Set pixel raw (independent of window coordinates) pixel
        (x,y) to color"""
        self.__checkOpen()
        self.create_line(x,y,x+1,y, fill=color)
        self.__autoflush()

    def flush(self):
        """Update drawing to the window"""
        self.__checkOpen()
        self.update_idletasks()

    def getMouse(self):
        """Wait for mouse click and return Point object representing
        the click"""
        self.update()      # flush any prior clicks
        self.mouseX = None
        self.mouseY = None
        while self.mouseX == None or self.mouseY == None:
            self.update()
            if self.isClosed(): raise GraphicsError("getMouse in closed window")
            time.sleep(.1) # give up thread
        x,y = self.toWorld(self.mouseX, self.mouseY)
        self.mouseX = None
        self.mouseY = None
        return Point(x,y)

    def checkMouse(self):
        """Return last mouse click or None if mouse has
        not been clicked since last call"""
        if self.isClosed():
            raise GraphicsError("checkMouse in closed window")
        self.update()
        if self.mouseX != None and self.mouseY != None:
            x,y = self.toWorld(self.mouseX, self.mouseY)
            self.mouseX = None
            self.mouseY = None
            return Point(x,y)
        else:
            return None

    def getKey(self):
        """Wait for user to press a key and return it as a string."""
        self.lastKey = ""
        while self.lastKey == "":
            self.update()
            if self.isClosed(): raise GraphicsError("getKey in closed window")
            time.sleep(.1) # give up thread

        key = self.lastKey
        self.lastKey = ""
        return key

    def checkKey(self):
        """Return last key pressed or None if no key pressed since last call"""
        if self.isClosed():
            raise GraphicsError("checkKey in closed window")
        self.update()
        key = self.lastKey
        self.lastKey = ""
        return key

    def getHeight(self):
        """Return the height of the window"""
        return self.height

    def getWidth(self):
        """Return the width of the window"""
        return self.width

    def toScreen(self, x, y):
        trans = self.trans
        if trans:
            return self.trans.screen(x,y)
        else:
            return x,y

    def toWorld(self, x, y):
        trans = self.trans
        if trans:
            return self.trans.world(x,y)
        else:
            return x,y

    def setMouseHandler(self, func):
        self._mouseCallback = func

    def _onClick(self, e):
        self.mouseX = e.x
        self.mouseY = e.y
        if self._mouseCallback:
            self._mouseCallback(Point(e.x, e.y))

    def addItem(self, item):
        self.items.append(item)

    def delItem(self, item):
        self.items.remove(item)

    def redraw(self):
        for item in self.items[:]:
            item.undraw()
            item.draw(self)
        self.update()


class Transform:

    """Internal class for 2-D coordinate transformations"""

    def __init__(self, w, h, xlow, ylow, xhigh, yhigh):
        # w, h are width and height of window
        # (xlow,ylow) coordinates of lower-left [raw (0,h-1)]
        # (xhigh,yhigh) coordinates of upper-right [raw (w-1,0)]
        xspan = (xhigh-xlow)
        yspan = (yhigh-ylow)
        self.xbase = xlow
        self.ybase = yhigh
        self.xscale = xspan/float(w-1)
        self.yscale = yspan/float(h-1)

    def screen(self,x,y):
        # Returns x,y in screen (actually window) coordinates
        xs = (x-self.xbase) / self.xscale
        ys = (self.ybase-y) / self.yscale
        return int(xs+0.5),int(ys+0.5)

    def world(self,xs,ys):
        # Returns xs,ys in world coordinates
        x = xs*self.xscale + self.xbase
        y = self.ybase - ys*self.yscale
        return x,y


# Default values for various item configuration options. Only a subset of
#   keys may be present in the configuration dictionary for a given item
DEFAULT_CONFIG = {"fill":"",
      "outline":"black",
      "width":"1",
      "arrow":"none",
      "text":"",
      "justify":"center",
                  "font": ("helvetica", 12, "normal")}

class GraphicsObject:

    """Generic base class for all of the drawable objects"""
    # A subclass of GraphicsObject should override _draw and
    #   and _move methods.

    def __init__(self, options):
        # options is a list of strings indicating which options are
        # legal for this object.

        # When an object is drawn, canvas is set to the GraphWin(canvas)
        #    object where it is drawn and id is the TK identifier of the
        #    drawn shape.
        self.canvas = None
        self.id = None

        # config is the dictionary of configuration options for the widget.
        config = {}
        for option in options:
            config[option] = DEFAULT_CONFIG[option]
        self.config = config

    def setFill(self, color):
        """Set interior color to color"""
        self._reconfig("fill", color)

    def setOutline(self, color):
        """Set outline color to color"""
        self._reconfig("outline", color)

    def setWidth(self, width):
        """Set line weight to width"""
        self._reconfig("width", width)

    def draw(self, graphwin):

        """Draw the object in graphwin, which should be a GraphWin
        object.  A GraphicsObject may only be drawn into one
        window. Raises an error if attempt made to draw an object that
        is already visible."""

        if self.canvas and not self.canvas.isClosed(): raise GraphicsError(OBJ_ALREADY_DRAWN)
        if graphwin.isClosed(): raise GraphicsError("Can't draw to closed window")
        self.canvas = graphwin
        self.id = self._draw(graphwin, self.config)
        graphwin.addItem(self)
        if graphwin.autoflush:
            _root.update()
        return self


    def undraw(self):

        """Undraw the object (i.e. hide it). Returns silently if the
        object is not currently drawn."""

        if not self.canvas: return
        if not self.canvas.isClosed():
            self.canvas.delete(self.id)
            self.canvas.delItem(self)
            if self.canvas.autoflush:
                _root.update()
        self.canvas = None
        self.id = None


    def move(self, dx, dy):

        """move object dx units in x direction and dy units in y
        direction"""

        self._move(dx,dy)
        canvas = self.canvas
        if canvas and not canvas.isClosed():
            trans = canvas.trans
            if trans:
                x = dx/ trans.xscale
                y = -dy / trans.yscale
            else:
                x = dx
                y = dy
            self.canvas.move(self.id, x, y)
            if canvas.autoflush:
                _root.update()

    def _reconfig(self, option, setting):
        # Internal method for changing configuration of the object
        # Raises an error if the option does not exist in the config
        #    dictionary for this object
        if option not in self.config:
            raise GraphicsError(UNSUPPORTED_METHOD)
        options = self.config
        options[option] = setting
        if self.canvas and not self.canvas.isClosed():
            self.canvas.itemconfig(self.id, options)
            if self.canvas.autoflush:
                _root.update()


    def _draw(self, canvas, options):
        """draws appropriate figure on canvas with options provided
        Returns Tk id of item drawn"""
        pass # must override in subclass


    def _move(self, dx, dy):
        """updates internal state of object to move it dx,dy units"""
        pass # must override in subclass


class Point(GraphicsObject):
    def __init__(self, x, y):
        GraphicsObject.__init__(self, ["outline", "fill"])
        self.setFill = self.setOutline
        self.x = float(x)
        self.y = float(y)

    def __repr__(self):
        return "Point({}, {})".format(self.x, self.y)

    def _draw(self, canvas, options):
        x,y = canvas.toScreen(self.x,self.y)
        return canvas.create_rectangle(x,y,x+1,y+1,options)

    def _move(self, dx, dy):
        self.x = self.x + dx
        self.y = self.y + dy

    def clone(self):
        other = Point(self.x,self.y)
        other.config = self.config.copy()
        return other

    def getX(self): return self.x
    def getY(self): return self.y

class _BBox(GraphicsObject):
    # Internal base class for objects represented by bounding box
    # (opposite corners) Line segment is a degenerate case.

    def __init__(self, p1, p2, options=["outline","width","fill"]):
        GraphicsObject.__init__(self, options)
        self.p1 = p1.clone()
        self.p2 = p2.clone()

    def _move(self, dx, dy):
        self.p1.x = self.p1.x + dx
        self.p1.y = self.p1.y + dy
        self.p2.x = self.p2.x + dx
        self.p2.y = self.p2.y  + dy

    def getP1(self): return self.p1.clone()

    def getP2(self): return self.p2.clone()

    def getCenter(self):
        p1 = self.p1
        p2 = self.p2
        return Point((p1.x+p2.x)/2.0, (p1.y+p2.y)/2.0)


class Rectangle(_BBox):

    def __init__(self, p1, p2):
        _BBox.__init__(self, p1, p2)

    def __repr__(self):
        return "Rectangle({}, {})".format(str(self.p1), str(self.p2))

    def _draw(self, canvas, options):
        p1 = self.p1
        p2 = self.p2
        x1,y1 = canvas.toScreen(p1.x,p1.y)
        x2,y2 = canvas.toScreen(p2.x,p2.y)
        return canvas.create_rectangle(x1,y1,x2,y2,options)

    def clone(self):
        other = Rectangle(self.p1, self.p2)
        other.config = self.config.copy()
        return other


class Oval(_BBox):

    def __init__(self, p1, p2):
        _BBox.__init__(self, p1, p2)

    def __repr__(self):
        return "Oval({}, {})".format(str(self.p1), str(self.p2))


    def clone(self):
        other = Oval(self.p1, self.p2)
        other.config = self.config.copy()
        return other

    def _draw(self, canvas, options):
        p1 = self.p1
        p2 = self.p2
        x1,y1 = canvas.toScreen(p1.x,p1.y)
        x2,y2 = canvas.toScreen(p2.x,p2.y)
        return canvas.create_oval(x1,y1,x2,y2,options)

class Circle(Oval):

    def __init__(self, center, radius):
        p1 = Point(center.x-radius, center.y-radius)
        p2 = Point(center.x+radius, center.y+radius)
        Oval.__init__(self, p1, p2)
        self.radius = radius

    def __repr__(self):
        return "Circle({}, {})".format(str(self.getCenter()), str(self.radius))

    def clone(self):
        other = Circle(self.getCenter(), self.radius)
        other.config = self.config.copy()
        return other

    def getRadius(self):
        return self.radius


class Line(_BBox):

    def __init__(self, p1, p2):
        _BBox.__init__(self, p1, p2, ["arrow","fill","width"])
        self.setFill(DEFAULT_CONFIG['outline'])
        self.setOutline = self.setFill

    def __repr__(self):
        return "Line({}, {})".format(str(self.p1), str(self.p2))

    def clone(self):
        other = Line(self.p1, self.p2)
        other.config = self.config.copy()
        return other

    def _draw(self, canvas, options):
        p1 = self.p1
        p2 = self.p2
        x1,y1 = canvas.toScreen(p1.x,p1.y)
        x2,y2 = canvas.toScreen(p2.x,p2.y)
        return canvas.create_line(x1,y1,x2,y2,options)

    def setArrow(self, option):
        if not option in ["first","last","both","none"]:
            raise GraphicsError(BAD_OPTION)
        self._reconfig("arrow", option)


class Polygon(GraphicsObject):

    def __init__(self, *points):
        # if points passed as a list, extract it
        if len(points) == 1 and type(points[0]) == type([]):
            points = points[0]
        self.points = list(map(Point.clone, points))
        GraphicsObject.__init__(self, ["outline", "width", "fill"])

    def __repr__(self):
        return "Polygon"+str(tuple(p for p in self.points))

    def clone(self):
        other = Polygon(*self.points)
        other.config = self.config.copy()
        return other

    def getPoints(self):
        return list(map(Point.clone, self.points))

    def _move(self, dx, dy):
        for p in self.points:
            p.move(dx,dy)

    def _draw(self, canvas, options):
        args = [canvas]
        for p in self.points:
            x,y = canvas.toScreen(p.x,p.y)
            args.append(x)
            args.append(y)
        args.append(options)
        return GraphWin.create_polygon(*args)

class Text(GraphicsObject):

    def __init__(self, p, text):
        GraphicsObject.__init__(self, ["justify","fill","text","font"])
        self.setText(text)
        self.anchor = p.clone()
        self.setFill(DEFAULT_CONFIG['outline'])
        self.setOutline = self.setFill

    def __repr__(self):
        return "Text({}, '{}')".format(self.anchor, self.getText())

    def _draw(self, canvas, options):
        p = self.anchor
        x,y = canvas.toScreen(p.x,p.y)
        return canvas.create_text(x,y,options)

    def _move(self, dx, dy):
        self.anchor.move(dx,dy)

    def clone(self):
        other = Text(self.anchor, self.config['text'])
        other.config = self.config.copy()
        return other

    def setText(self,text):
        self._reconfig("text", text)

    def getText(self):
        return self.config["text"]

    def getAnchor(self):
        return self.anchor.clone()

    def setFace(self, face):
        if face in ['helvetica','arial','courier','times roman']:
            f,s,b = self.config['font']
            self._reconfig("font",(face,s,b))
        else:
            raise GraphicsError(BAD_OPTION)

    def setSize(self, size):
        if 5 <= size <= 36:
            f,s,b = self.config['font']
            self._reconfig("font", (f,size,b))
        else:
            raise GraphicsError(BAD_OPTION)

    def setStyle(self, style):
        if style in ['bold','normal','italic', 'bold italic']:
            f,s,b = self.config['font']
            self._reconfig("font", (f,s,style))
        else:
            raise GraphicsError(BAD_OPTION)

    def setTextColor(self, color):
        self.setFill(color)


class Entry(GraphicsObject):

    def __init__(self, p, width):
        GraphicsObject.__init__(self, [])
        self.anchor = p.clone()
        #print self.anchor
        self.width = width
        self.text = tk.StringVar(_root)
        self.text.set("")
        self.fill = "gray"
        self.color = "black"
        self.font = DEFAULT_CONFIG['font']
        self.entry = None

    def __repr__(self):
        return "Entry({}, {})".format(self.anchor, self.width)

    def _draw(self, canvas, options):
        p = self.anchor
        x,y = canvas.toScreen(p.x,p.y)
        frm = tk.Frame(canvas.master)
        self.entry = tk.Entry(frm,
                              width=self.width,
                              textvariable=self.text,
                              bg = self.fill,
                              fg = self.color,
                              font=self.font)
        self.entry.pack()
        #self.setFill(self.fill)
        self.entry.focus_set()
        return canvas.create_window(x,y,window=frm)

    def getText(self):
        return self.text.get()

    def _move(self, dx, dy):
        self.anchor.move(dx,dy)

    def getAnchor(self):
        return self.anchor.clone()

    def clone(self):
        other = Entry(self.anchor, self.width)
        other.config = self.config.copy()
        other.text = tk.StringVar()
        other.text.set(self.text.get())
        other.fill = self.fill
        return other

    def setText(self, t):
        self.text.set(t)


    def setFill(self, color):
        self.fill = color
        if self.entry:
            self.entry.config(bg=color)


    def _setFontComponent(self, which, value):
        font = list(self.font)
        font[which] = value
        self.font = tuple(font)
        if self.entry:
            self.entry.config(font=self.font)


    def setFace(self, face):
        if face in ['helvetica','arial','courier','times roman']:
            self._setFontComponent(0, face)
        else:
            raise GraphicsError(BAD_OPTION)

    def setSize(self, size):
        if 5 <= size <= 36:
            self._setFontComponent(1,size)
        else:
            raise GraphicsError(BAD_OPTION)

    def setStyle(self, style):
        if style in ['bold','normal','italic', 'bold italic']:
            self._setFontComponent(2,style)
        else:
            raise GraphicsError(BAD_OPTION)

    def setTextColor(self, color):
        self.color=color
        if self.entry:
            self.entry.config(fg=color)


class Image(GraphicsObject):

    idCount = 0
    imageCache = {} # tk photoimages go here to avoid GC while drawn

    def __init__(self, p, *pixmap):
        GraphicsObject.__init__(self, [])
        self.anchor = p.clone()
        self.imageId = Image.idCount
        Image.idCount = Image.idCount + 1
        if len(pixmap) == 1: # file name provided
            self.img = tk.PhotoImage(file=pixmap[0], master=_root)
        else: # width and height provided
            width, height = pixmap
            self.img = tk.PhotoImage(master=_root, width=width, height=height)

    def __repr__(self):
        return "Image({}, {}, {})".format(self.anchor, self.getWidth(), self.getHeight())

    def _draw(self, canvas, options):
        p = self.anchor
        x,y = canvas.toScreen(p.x,p.y)
        self.imageCache[self.imageId] = self.img # save a reference
        return canvas.create_image(x,y,image=self.img)

    def _move(self, dx, dy):
        self.anchor.move(dx,dy)

    def undraw(self):
        try:
            del self.imageCache[self.imageId]  # allow gc of tk photoimage
        except KeyError:
            pass
        GraphicsObject.undraw(self)

    def getAnchor(self):
        return self.anchor.clone()

    def clone(self):
        other = Image(Point(0,0), 0, 0)
        other.img = self.img.copy()
        other.anchor = self.anchor.clone()
        other.config = self.config.copy()
        return other

    def getWidth(self):
        """Returns the width of the image in pixels"""
        return self.img.width()

    def getHeight(self):
        """Returns the height of the image in pixels"""
        return self.img.height()

    def getPixel(self, x, y):
        """Returns a list [r,g,b] with the RGB color values for pixel (x,y)
        r,g,b are in range(256)

        """

        value = self.img.get(x,y)
        if type(value) ==  type(0):
            return [value, value, value]
        elif type(value) == type((0,0,0)):
            return list(value)
        else:
            return list(map(int, value.split()))

    def setPixel(self, x, y, color):
        """Sets pixel (x,y) to the given color

        """
        self.img.put("{" + color +"}", (x, y))


    def save(self, filename):
        """Saves the pixmap image to filename.
        The format for the save image is determined from the filname extension.

        """

        path, name = os.path.split(filename)
        ext = name.split(".")[-1]
        self.img.write( filename, format=ext)


def color_rgb(r,g,b):
    """r,g,b are intensities of red, green, and blue in range(256)
    Returns color specifier string for the resulting color"""
    return "#%02x%02x%02x" % (r,g,b)

################################

### Risk: Final Project Code ###

notificationBar = Text(Point(16,19),'')
cashCardReward = Text(Point(92,92),'') #not done
turnsTaken = Text(Point(9,98),'')
diceResultLabel = Text(Point(92,72),'') #not done
endTurnButton = Rectangle(Point(33,15),Point(42,23))

playerIDDict = {"Player one":"red", "Player two":"orange", "Player three":"brown", "Player four":"purple"}

playerNameLabels = [(Rectangle(Point(1,2),Point(10,8)), "Player one"),
(Rectangle(Point(26,2),Point(35,8)), "Player two"),
(Rectangle(Point(51,2),Point(60,8)), "Player three"),
(Rectangle(Point(76,2),Point(84,8)), "Player four")
]

playerCards = {"Player one": Text(Point(12,5),0), "Player two": Text(Point(38,5),0),
                "Player three": Text(Point(63,5),0), "Player four": Text(Point(87,5),0)}

countriesDict = {"Keeton":(Rectangle(Point(7,32),Point(12,38)),Text(Point(9.5,35),"--")),
                "Bethe":(Rectangle(Point(16,33),Point(23,39)),Text(Point(19.5,36),"--")),
                "Rose":(Rectangle(Point(10,43),Point(17,48)),Text(Point(13.5,45.5),"--")),
                "Becker":(Rectangle(Point(7,50),Point(12,56)),Text(Point(9.5,53),"--")),
                "Cook": (Rectangle(Point(16,52),Point(23,57)),Text(Point(19.5,54.5),"--")),
                "Uris":(Rectangle(Point(32,37),Point(38,43)),Text(Point(35,40),"--")),
                "Olin":(Rectangle(Point(42,37),Point(48,43)),Text(Point(45,40),"--")),
                "Morrill":(Rectangle(Point(32,51),Point(36,58)),Text(Point(34,54.5),"--")),
                "Tjaden":(Rectangle(Point(36,62),Point(42,67)),Text(Point(39,64.5),"--")),
                "Sibley":(Rectangle(Point(49,62),Point(55,67)),Text(Point(52,64.5),"--")),
                "Klarman":(Rectangle(Point(54,47),Point(58,56)),Text(Point(56,51.5),"--")),
                "Goldwin":(Rectangle(Point(48,47),Point(52,56)),Text(Point(50,51.5),"--")),
                "Cascadilla":(Rectangle(Point(51,22),Point(57,28)),Text(Point(54,25),"--")),
                "Schwartz": (Rectangle(Point(63,22),Point(69,28)),Text(Point(66,25),"--")),
                "Sheldon": (Rectangle(Point(57.5,16),Point(62.5,21)),Text(Point(60,18.5),"--")),
                "Gates": (Rectangle(Point(81,27),Point(87,32)) ,Text(Point(84,29.5),"--")),
                "Mann": (Rectangle(Point(88,55),Point(94,62)) ,Text(Point(91,58.5),"--")),
                "Riley": (Rectangle(Point(88,42),Point(94,49)) ,Text(Point(91,45.5),"--")),
                "Dairy Bar": (Rectangle(Point(81,42),Point(86,52)) ,Text(Point(83.5,47),"--")),
                "Townhouses": (Rectangle(Point(42,86),Point(52,92)) ,Text(Point(47,89),"--")),
                "Donlon": (Rectangle(Point(47,76),Point(56,82)) ,Text(Point(51.5,79),"--")),
                "RPCC": (Rectangle(Point(55,83),Point(64,89)) ,Text(Point(59.5,86),"--")),
                "Low Rise": (Rectangle(Point(68,86),Point(76,92)) ,Text(Point(72,89),"--")),
                "Appel": (Rectangle(Point(72,76),Point(79,82)) ,Text(Point(75.5,79),"--"))
                	}

dice = {1:"one.ppm",2:"two.ppm",3:"three.ppm",4:"four.ppm",5:"five.ppm",6:"six.ppm"}
oldInputTuple = ("",False)
def drawBoard():
    # Set up window
    win = GraphWin("BIG RED R!SK", 1200, 700)
    win.setCoords(0,0,100,100) # 100 by 100 grid
    win.setBackground(color_rgb(255,99,71)) # red color

    playerNameLabels[0][0].setFill("green")
    playerNameLabels[0][0].draw(win)
    playerNameLabels[1][0].setFill("gray")
    playerNameLabels[1][0].draw(win)
    playerNameLabels[2][0].setFill("gray")
    playerNameLabels[2][0].draw(win)
    playerNameLabels[3][0].setFill("gray")
    playerNameLabels[3][0].draw(win)

    #Draw continent outlines, labels, and connections
    west = Rectangle(Point(5,30),Point(25,60))
    west.draw(win)
    west_value = Text(Point(4,58),"+5")
    west_value.setStyle("bold")
    west_value.draw(win)
    west_name = Text(Point(15,60.6), "West Campus")
    west_name.draw(win)
    keeton_name = Text(Point(9.5,38.6),"Keeton")
    keeton_name.draw(win)
    bethe_name = Text(Point(19.5,39.6),"Bethe")
    bethe_name.draw(win)
    rose_name = Text(Point(13.5,48.6),"Rose")
    rose_name.draw(win)
    becker_name = Text(Point(9.5,56.6),"Becker")
    becker_name.draw(win)
    cook_name = Text(Point(19.5,57.6),"Cook")
    cook_name.draw(win)
    keeton_rose = Line(Point(13.5,43),Point(9.5,39))
    keeton_rose.draw(win)
    rose_bethe = Line(Point(17,46),Point(19.5,40))
    rose_bethe.draw(win)
    becker_rose = Line(Point(12,53),Point(13.5,49))
    becker_rose.draw(win)
    cook_becker = Line(Point(16,55.5),Point(12,53))
    cook_becker.draw(win)
    bethe_keeton = Line(Point(16,36),Point(12,35))
    bethe_keeton.draw(win)
    central = Rectangle(Point(30,35),Point(60,70))
    central.draw(win)
    central_value = Text(Point(29,68),"+7")
    central_value.setStyle("bold")
    central_value.draw(win)
    central_name = Text(Point(45,70.6), "Central Campus")
    central_name.draw(win)
    uris_name = Text(Point(35,43.6),"Uris")
    uris_name.draw(win)
    olin_name = Text(Point(45,43.6),"Olin")
    olin_name.draw(win)
    morrill_name = Text(Point(34,58.6),"Morrill")
    morrill_name.draw(win)
    tjaden_name = Text(Point(39,67.6),"Tjaden")
    tjaden_name.draw(win)
    sibley_name = Text(Point(52,67.6),"Sibley")
    sibley_name.draw(win)
    klarman_name = Text(Point(56,56.6),"Klarman")
    klarman_name.draw(win)
    goldwin_name = Text(Point(50,56.6),"Goldwin")
    goldwin_name.draw(win)
    uris_olin = Line(Point(38,40),Point(42,40))
    uris_olin.draw(win)
    uris_morrill = Line(Point(35,44),Point(34,51))
    uris_morrill.draw(win)
    goldwin_klarman = Line(Point(52,51.5),Point(54,51.5))
    goldwin_klarman.draw(win)
    goldwin_olin = Line(Point(50,47),Point(45,44.2))
    goldwin_olin.draw(win)
    morrill_tjaden = Line(Point(34,59),Point(39,62))
    morrill_tjaden.draw(win)
    tjaden_sibley = Line(Point(42,64.5),Point(49,64.5))
    tjaden_sibley.draw(win)
    sibley_klarman = Line(Point(52,62),Point(56,57))
    sibley_klarman.draw(win)
    tjaden_goldwin = Line(Point(39,62),Point(48,51.5))
    tjaden_goldwin.draw(win)
    sibley_uris = Line(Point(52,62),Point(35,44))
    sibley_uris.draw(win)
    collegetown = Rectangle(Point(50,15),Point(70,30))
    collegetown.draw(win)
    collegetown_value = Text(Point(48,28),"+5")
    collegetown_value.setStyle("bold")
    collegetown_value.draw(win)
    collegetown_name = Text(Point(60,30.6), "Collegetown")
    collegetown_name.draw(win)
    casc_name = Text(Point(54,28.6),"Cascadilla")
    casc_name.draw(win)
    schwartz_name = Text(Point(66,28.6),"Schwartz")
    schwartz_name.draw(win)
    sheldon_name = Text(Point(60,21.6),"Sheldon")
    sheldon_name.draw(win)
    sheldon_schwartz = Line(Point(66,22),Point(62.5,18.5))
    sheldon_schwartz.draw(win)
    sheldon_casc = Line(Point(57.5,18.5),Point(54,22))
    sheldon_casc.draw(win)
    casc_schwartz = Line(Point(63,25),Point(57,25))
    casc_schwartz.draw(win)
    agriculture = Rectangle(Point(80,25),Point(95,65))
    agriculture.draw(win)
    agriculture_name = Text(Point(87.5,65.6), "Ag. Quad")
    agriculture_name.draw(win)
    agriculture_value = Text(Point(79,63),"+4")
    agriculture_value.setStyle("bold")
    agriculture_value.draw(win)
    gates_name = Text(Point(84,32.6),"Gates")
    gates_name.draw(win)
    mann_name = Text(Point(91,62.6),"Mann")
    mann_name.draw(win)
    riley_name = Text(Point(91,49.6),"Riley")
    riley_name.draw(win)
    dairy_name = Text(Point(83.5,52.6),"Dairy Bar")
    dairy_name.draw(win)
    mann_riley = Line(Point(91,55),Point(91,50))
    mann_riley.draw(win)
    riley_dairy = Line(Point(88,45.5),Point(86,47))
    riley_dairy.draw(win)
    mann_dairy = Line(Point(88,58.5),Point(83.5,53))
    mann_dairy.draw(win)
    gates_riley = Line(Point(87,29.5),Point(91,42))
    gates_riley.draw(win)
    north = Rectangle(Point(40,75),Point(80,95))
    north.draw(win)
    north_value = Text(Point(39,93),"+6")
    north_value.setStyle("bold")
    north_value.draw(win)
    north_name = Text(Point(60,95.5), "North Campus")
    north_name.draw(win)
    townhouses_name = Text(Point(47,92.6),"Townhouses")
    townhouses_name.draw(win)
    donlon_name = Text(Point(51.5,82.6),"Donlon")
    donlon_name.draw(win)
    rpcc_name = Text(Point(59.5,89.6),"RPCC")
    rpcc_name.draw(win)
    lowrise_name = Text(Point(72,92.6),"Low Rise")
    lowrise_name.draw(win)
    appel_name = Text(Point(75.5,82.6),"Appel")
    appel_name.draw(win)
    townhouses_donlon = Line(Point(47,86),Point(51.5,83))
    townhouses_donlon.draw(win)
    townhouses_rpcc = Line(Point(52,89),Point(55,86))
    townhouses_rpcc.draw(win)
    rpcc_donlon = Line(Point(55,86),Point(51.5,83))
    rpcc_donlon.draw(win)
    rpcc_lowrise = Line(Point(64,86),Point(68,89))
    rpcc_lowrise.draw(win)
    lowrise_appel = Line(Point(72,86),Point(75.5,83))
    lowrise_appel.draw(win)
    donlon_appel = Line(Point(72,79),Point(56,79))
    donlon_appel.draw(win)
    cook_morrill = Line(Point(23,54.5),Point(32,54.5))
    cook_morrill.draw(win)
    bethe_uris = Line(Point(23,36),Point(32,40))
    bethe_uris.draw(win)
    olin_casc = Line(Point(45,37),Point(51,25))
    olin_casc.draw(win)
    schwartz_gates = Line(Point(69,25),Point(81,29.5))
    schwartz_gates.draw(win)
    dairy_klarman = Line(Point(58,51.5),Point(81,47))
    dairy_klarman.draw(win)
    mann_appel = Line(Point(88,58.5),Point(75.5,76))
    mann_appel.draw(win)
    donlon_sibley = Line(Point(51.5,76),Point(52,68))
    donlon_sibley.draw(win)


    # Draw the countries and numbers
    for country in countriesDict:
    	countriesDict[country][0].setFill("gray")
    	countriesDict[country][0].draw(win)
    	countriesDict[country][1].draw(win)

    # Draw player number of cards
    for player in playerCards:
    	playerCards[player].draw(win)



    # Set up end turn button
    endTurnButton.setFill("blue")
    endTurn = Text(Point(37.5,19),"Done")
    endTurn.setSize(18)
    endTurn.setStyle("bold")
    endTurnButton.draw(win)
    endTurn.draw(win)



    cashCardReward.draw(win)
    turnsTaken.draw(win)
    diceResultLabel.draw(win)

    player_one = Text(Point(5,5),"Player 1")
    player_one.setStyle("bold")
    player_one.setSize(18)
    player_one.setTextColor("black")
    player_one.draw(win)

    player_two = Text(Point(30,5),"Player 2")
    player_two.setStyle("bold")
    player_two.setSize(18)
    player_two.setTextColor("black")
    player_two.draw(win)

    player_three = Text(Point(55,5),"Player 3")
    player_three.setStyle("bold")
    player_three.setSize(18)
    player_three.setTextColor("black")
    player_three.draw(win)

    player_four = Text(Point(80,5),"Player 4")
    player_four.setStyle("bold")
    player_four.setSize(18)
    player_four.setTextColor("black")
    player_four.draw(win)

    notification_bar = Rectangle(Point(1,15),Point(31,23))
    notification_bar.setFill("white")
    notification_bar.draw(win)
    notificationBar.draw(win)

    cornell = Image(Point(12,85),"cornell.ppm")
    cornell.draw(win)

    game_name = Text(Point(25,85),"BIG RED R!SK")
    game_name.setSize(30)
    game_name.setStyle("bold")
    game_name.setTextColor("red")
    game_name.draw(win)

    dice_box = Rectangle(Point(82,70),Point(98,93))
    dice_box.setOutline("white")
    dice_split = Line(Point(90,70),Point(90,93))
    dice_split.setOutline("white")
    dice_split.draw(win)
    dice_box.draw(win)

    dice_title = Text(Point(90,96),"Dice roll")
    dice_title.setTextColor("white")
    dice_title.draw(win)

    dice_attack_name = Text(Point(86,93.6),"Attack")
    dice_attack_name.setTextColor("white")
    dice_attack_name.draw(win)
    dice_defend_name = Text(Point(94,93.6),"Defend")
    dice_defend_name.setTextColor("white")
    dice_defend_name.draw(win)

    card = Rectangle(Point(68,58.5),Point(72,67.5))
    card.setFill("orange")
    card.draw(win)
    card_title = Text(Point(70,66),"Card")
    card_title.draw(win)
    card_value = Text(Point(70,62),str(5))
    card_value.draw(win)

    updateDice([4,5],[1],win)

    # label.setPixmap(pixmap)
    # w.resize(pixmap.width(),pixmap.height())


    return win



def clicker(win):
    whichSquareList = []
    buttonTuple = ("",False)

    while(len(whichSquareList) < 1):
        clicked = win.getMouse()
        if (clicked.getX() >= 7 and clicked.getX() <= 12 and
        clicked.getY() >= 32 and clicked.getY() <= 38):
            whichSquareList.append("Keeton")
            buttonTuple = ("Keeton",True)
        elif (clicked.getX() >= 16 and clicked.getX() <= 23 and
        clicked.getY() >= 33 and clicked.getY() <= 39):
            whichSquareList.append("Bethe")
            buttonTuple = ("Bethe",True)
        elif (clicked.getX() >= 10 and clicked.getX() <= 17 and
        clicked.getY() >= 43 and clicked.getY() <= 48):
            whichSquareList.append("Rose")
            buttonTuple = ("Rose",True)
        elif (clicked.getX() >= 7 and clicked.getX() <= 12 and
        clicked.getY() >= 50 and clicked.getY() <= 56):
            whichSquareList.append("Becker")
            buttonTuple = ("Becker",True)
        elif (clicked.getX() >= 16 and clicked.getX() <= 23 and
        clicked.getY() >= 52 and clicked.getY() <= 57):
            whichSquareList.append("Cook")
            buttonTuple = ("Cook",True)
        elif (clicked.getX() >= 32 and clicked.getX() <= 38 and
        clicked.getY() >= 37 and clicked.getY() <= 43):
            whichSquareList.append("Uris")
            buttonTuple = ("Uris",True)
        elif (clicked.getX() >= 42 and clicked.getX() <= 48 and
        clicked.getY() >= 37 and clicked.getY() <= 43):
            whichSquareList.append("Olin")
            buttonTuple = ("Olin",True)
        elif (clicked.getX() >= 32 and clicked.getX() <= 36 and
        clicked.getY() >= 51 and clicked.getY() <= 58):
            whichSquareList.append("Morrill")
            buttonTuple = ("Morrill",True)
        elif (clicked.getX() >= 36 and clicked.getX() <= 42 and
        clicked.getY() >= 62 and clicked.getY() <= 67):
            whichSquareList.append("Tjaden")
            buttonTuple = ("Tjaden",True)
        elif (clicked.getX() >= 49 and clicked.getX() <= 55 and
        clicked.getY() >= 62 and clicked.getY() <= 67):
            whichSquareList.append("Sibley")
            buttonTuple = ("Sibley",True)
        elif (clicked.getX() >= 54 and clicked.getX() <= 58 and
        clicked.getY() >= 47 and clicked.getY() <= 56):
            whichSquareList.append("Klarman")
            buttonTuple = ("Klarman",True)
        elif (clicked.getX() >= 48 and clicked.getX() <= 52 and
        clicked.getY() >= 47 and clicked.getY() <= 56):
            whichSquareList.append("Goldwin")
            buttonTuple = ("Goldwin",True)
        elif (clicked.getX() >= 51 and clicked.getX() <= 57 and
        clicked.getY() >= 22 and clicked.getY() <= 28):
            whichSquareList.append("Cascadilla")
            buttonTuple = ("Cascadilla",True)
        elif (clicked.getX() >= 63 and clicked.getX() <= 69 and
        clicked.getY() >= 22 and clicked.getY() <= 28):
            whichSquareList.append("Schwartz")
            buttonTuple = ("Schwartz",True)
        elif (clicked.getX() >= 57.5 and clicked.getX() <= 62.5 and
        clicked.getY() >= 16 and clicked.getY() <= 21):
            whichSquareList.append("Sheldon")
            buttonTuple = ("Sheldon",True)
        elif (clicked.getX() >= 81 and clicked.getX() <= 87 and
        clicked.getY() >= 27 and clicked.getY() <= 32):
            whichSquareList.append("Gates")
            buttonTuple = ("Gates",True)
        elif (clicked.getX() >= 88 and clicked.getX() <= 94 and
        clicked.getY() >= 42 and clicked.getY() <= 49):
            whichSquareList.append("Riley")
            buttonTuple = ("Riley",True)
        elif (clicked.getX() >= 81 and clicked.getX() <= 86 and
        clicked.getY() >= 42 and clicked.getY() <= 52):
            whichSquareList.append("Dairy Bar")
            buttonTuple = ("Dairy Bar",True)
        elif (clicked.getX() >= 88 and clicked.getX() <= 94 and
        clicked.getY() >= 55 and clicked.getY() <= 62):
            whichSquareList.append("Mann")
            buttonTuple = ("Mann",True)
        elif (clicked.getX() >= 42 and clicked.getX() <= 52 and
        clicked.getY() >= 86 and clicked.getY() <= 92):
            whichSquareList.append("Townhouses")
            buttonTuple = ("Townhouses",True)
        elif (clicked.getX() >= 47 and clicked.getX() <= 56 and
        clicked.getY() >= 76 and clicked.getY() <= 82):
            whichSquareList.append("Donlon")
            buttonTuple = ("Donlon",True)
        elif (clicked.getX() >= 55 and clicked.getX() <= 64 and
        clicked.getY() >= 83 and clicked.getY() <= 89):
            whichSquareList.append("RPCC")
            buttonTuple = ("RPCC",True)
        elif (clicked.getX() >= 68 and clicked.getX() <= 76 and
        clicked.getY() >= 86 and clicked.getY() <= 92):
            whichSquareList.append("Low Rise")
            buttonTuple = ("Low Rise",True)
        elif (clicked.getX() >= 72 and clicked.getX() <= 79 and
        clicked.getY() >= 76 and clicked.getY() <= 82):
            whichSquareList.append("Appel")
            buttonTuple = ("Appel",True)
        elif (clicked.getX() >= 33 and clicked.getX() <= 42 and
        clicked.getY() >= 15 and clicked.getY() <= 23):
            whichSquareList.append("End turn")
            buttonTuple = ("End turn",False)





    #return ''.join(whichSquareList)
    return buttonTuple


def updateDice(attack,defend,win):
	if len(attack)==3:
		attack_one = Image(Point(86,88),dice[attack[0]])
		attack_one.draw(win)
		attack_two = Image(Point(86,82),dice[attack[1]])
		attack_two.draw(win)
		attack_three = Image(Point(86,76),dice[attack[2]])
		attack_three.draw(win)

	if len(attack)==2:
		attack_one = Image(Point(86,86),dice[attack[0]])
		attack_one.draw(win)

		attack_two = Image(Point(86,78),dice[attack[1]])
		attack_two.draw(win)
	if len(attack)==1:
		attack_one = Image(Point(86,86),dice[attack[0]])
		attack_one.draw(win)
	if len(defend)==2:
		defend_one = Image(Point(94,86),dice[defend[0]])
		defend_one.draw(win)
		defend_two = Image(Point(94,78),dice[defend[1]])
		defend_two.draw(win)
	if len(defend)==1:
		defend_one = Image(Point(94,86),dice[defend[0]])
		defend_one.draw(win)



def updateNotificationBar(notification):
    # Set notification bar to current click
    if (notification != ""):
        notificationBar.setText(notification)

def update(win, countryTuple, cardAmounts, cashReward,
turns, diceResults, currentPlayersTurn, notification):
    # Set notification bar to current click
    updateNotificationBar(notification)

    # Color board according to what players own and add troops to each country
    if (countryTuple != None):
        countriesDict[countryTuple[0]][0].setFill(playerIDDict[countryTuple[1]])
        countriesDict[countryTuple[0]][1].setText(countryTuple[2])

    # Display card amounts for each player
    for cardTuple in cardAmounts:
        g = playerCards[cardTuple[0]]
        g.setText(cardTuple[1])


    cashCardReward.setText("Cash card reward is " + str(cashReward))
    turnsTaken.setText("Turns taken: " + str(turns))
    diceResultLabel.setText("Attacker rolled "+str(diceResults[0]) +
    "\n Defender rolled " + str(diceResults[1]))

def updateAttack(win, inputTuple, occupiedCountries, countryTuple2, cardAmounts, cashReward,
turns, diceResults, currentPlayersTurn, notification):
    global oldInputTuple
    update(win, occupiedCountries, cardAmounts, cashReward,
    turns, diceResults, currentPlayersTurn, notification)

    if (countryTuple2 != None):
        countriesDict[countryTuple2[0]][0].setFill(playerIDDict[countryTuple2[1]])
        countriesDict[countryTuple2[0]][1].setText(countryTuple2[2])

    # Highlight the label of the player whose current turn it is
    for playerLabelTuple in playerNameLabels:
        if playerLabelTuple[1] == currentPlayersTurn:
            playerLabelTuple[0].setFill("green")
        elif playerLabelTuple[1] != currentPlayersTurn and inputTuple[1] == True:
            playerLabelTuple[0].setFill("gray")

    #("Country",True)
    #("End turn",False)
    if (inputTuple[1] == True):
        countriesDict[inputTuple[0]][0].setOutline("white")
        countriesDict[inputTuple[0]][0].setWidth(2)

        if (oldInputTuple[1] == False):
            endTurnButton.setOutline("black")
            endTurnButton.setWidth(1)
        else:
            countriesDict[oldInputTuple[0]][0].setOutline("black")
            countriesDict[oldInputTuple[0]][0].setWidth(1)
    elif (inputTuple[1] == False):
        if (oldInputTuple[1] == False):
            endTurnButton.setOutline("white")
            endTurnButton.setWidth(4)
        else:
            countriesDict[oldInputTuple[0]][0].setOutline("black")
            countriesDict[oldInputTuple[0]][0].setWidth(1)

    oldInputTuple = inputTuple



def updateBoard(win, inputTuple, occupiedCountries, cardAmounts, cashReward,
turns, diceResults, currentPlayersTurn, notification):
    global oldInputTuple

    update(win, occupiedCountries, cardAmounts, cashReward,
    turns, diceResults, currentPlayersTurn, notification)
    # updateNotificationBar(notification)

    # Highlight the label of the player whose current turn it is
    for playerLabelTuple in playerNameLabels:
        if playerLabelTuple[1] == currentPlayersTurn:
            playerLabelTuple[0].setFill("green")
        elif playerLabelTuple[1] != currentPlayersTurn and inputTuple[1] == True:
            playerLabelTuple[0].setFill("gray")

    #("Country",True)
    #("End turn",False)
    if (inputTuple[1] == True):
        countriesDict[inputTuple[0]][0].setOutline("white")
        countriesDict[inputTuple[0]][0].setWidth(2)

        if (oldInputTuple[1] == False):
            endTurnButton.setOutline("black")
            endTurnButton.setWidth(1)
        else:
            countriesDict[oldInputTuple[0]][0].setOutline("black")
            countriesDict[oldInputTuple[0]][0].setWidth(1)
    elif (inputTuple[1] == False):
        if (oldInputTuple[1] == False):
            endTurnButton.setOutline("white")
            endTurnButton.setWidth(4)
        else:
            countriesDict[oldInputTuple[0]][0].setOutline("black")
            countriesDict[oldInputTuple[0]][0].setWidth(1)

    oldInputTuple = inputTuple


    # # Highlights the country/button most recently clicked
    # if (inputTuple[1] == True): # Deals with countries
    #     # Set all other countries/buttons to black outline
    #     for key in countriesDict:
    #         countriesDict[key][0].setOutline("black")
    #         countriesDict[key][0].setWidth(1)
    #     endTurnButton.setOutline("black")
    #     endTurnButton.setWidth(1)
    #     # Highlight the country selected
    #     countriesDict[inputTuple[0]][0].setOutline("white")
    #     countriesDict[inputTuple[0]][0].setWidth(2)
    # elif inputTuple[0] == "End turn": # Deals with end turn button
    #     # Set all other countries/buttons to black outline
    #     for key in countriesDict:
    #         countriesDict[key][0].setOutline("black")
    #         countriesDict[key][0].setWidth(1)
    #     # Highlight end turn button
    #     endTurnButton.setOutline("white")
    #     endTurnButton.setWidth(4)


def updateBoardNoClick(win, occupiedCountries, cardAmounts, cashReward,
turns, diceResults, currentPlayersTurn, notification):

    update(win, occupiedCountries, cardAmounts, cashReward,
    turns, diceResults, currentPlayersTurn, notification)

    for playerLabelTuple in playerNameLabels:
        if playerLabelTuple[1] == currentPlayersTurn:
            playerLabelTuple[0].setFill("green")
        elif playerLabelTuple[1] != currentPlayersTurn:
            playerLabelTuple[0].setFill("gray")


### End of Risk: Final Project Code ###



    """Set coordinates of window to run from (x1,y1) in the
    lower-left corner to (x2,y2) in the upper-right corner."""


def test():
    board = drawBoard()
    board.getMouse()


#MacOS fix 2
#tk.Toplevel(_root).destroy()

# MacOS fix 1
#update()

if __name__ == "__main__":
    test()
