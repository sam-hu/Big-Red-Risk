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


### Risk: Final Project Code ###

notificationBar = Text(Point(50,15),'')
cashCardReward = Text(Point(92,92),'')
turnsTaken = Text(Point(92,82),'')
diceResultLabel = Text(Point(92,72),'')
endTurnButton = Rectangle(Point(90,10),Point(95,15))

playerNameLabels = [(Rectangle(Point(30,90),Point(40,95)), "Player one"),
(Rectangle(Point(45,90),Point(55,95)), "Player two"),
(Rectangle(Point(60,90),Point(70,95)), "Player three")]

playerCards = {"Player one": Text(Point(41,95),'-'), "Player two": Text(Point(56,95),'-'),
                "Player three": Text(Point(71,95),'-')}

countriesDict = {"Country one":(Rectangle(Point(30,30),Point(40,40)),Text(Point(35,35),'-')),
                "Country two":(Rectangle(Point(60,30),Point(70,40)),Text(Point(65,35),'-')),
                "Country three":(Rectangle(Point(45,60),Point(55,70)),Text(Point(50,65),'-'))}

def drawBoard(playerIDString):
    # Set up window
    win = GraphWin("Risk: Board Game", 1200, 800)
    win.setCoords(0,0,100,100) # 100 by 100 grid
    win.setBackground(color_rgb(255,99,71)) # red color

    playerNameLabels[0][0].setFill("green")
    playerNameLabels[0][0].draw(win)
    playerNameLabels[1][0].setFill("gray")
    playerNameLabels[1][0].draw(win)
    playerNameLabels[2][0].setFill("gray")
    playerNameLabels[2][0].draw(win)

    # Set up the connection between the countries
    line1 = Line(Point(35,40),Point(45,65))
    line1.draw(win)
    line2 = Line(Point(55,65),Point(65,40))
    line2.draw(win)
    line3 = Line(Point(40,35),Point(60,35))
    line3.draw(win)
    
    # Draw the countries
    countriesDict["Country one"][0].setFill("gray")
    countriesDict["Country one"][0].draw(win)
    countriesDict["Country two"][0].setFill("gray")
    countriesDict["Country two"][0].draw(win)
    countriesDict["Country three"][0].setFill("gray")
    countriesDict["Country three"][0].draw(win)

    # Draw the troop numbers of each country
    countriesDict["Country one"][1].draw(win)
    countriesDict["Country two"][1].draw(win)
    countriesDict["Country three"][1].draw(win)

    playerCards["Player one"].draw(win)
    playerCards["Player two"].draw(win)
    playerCards["Player three"].draw(win)


    # Set up end turn button
    endTurnButton.setFill("blue")
    endTurnButton.draw(win)

    notificationBar.draw(win)
    cashCardReward.draw(win)
    turnsTaken.draw(win)
    diceResultLabel.draw(win)


    # label.setPixmap(pixmap)
    # w.resize(pixmap.width(),pixmap.height())


    return win



def clicker(win):
    whichSquareList = []
    buttonTuple = ("",False)

    while(len(whichSquareList) < 1):
        clicked = win.getMouse()
        if (clicked.getX() >= 30 and clicked.getX() <= 40 and
        clicked.getY() >= 30 and clicked.getY() <= 40):
            whichSquareList.append("Country one")
            buttonTuple = ("Country one",True)
        elif (clicked.getX() >= 60 and clicked.getX() <= 70 and
        clicked.getY() >= 30 and clicked.getY() <= 40):
            whichSquareList.append("Country two")
            buttonTuple = ("Country two",True)
        elif (clicked.getX() >= 45 and clicked.getX() <= 55 and
        clicked.getY() >= 60 and clicked.getY() <= 70):
            whichSquareList.append("Country three")
            buttonTuple = ("Country three",True)
        elif (clicked.getX() >= 90 and clicked.getX() <= 95 and
        clicked.getY() >= 10 and clicked.getY() <= 15):
            whichSquareList.append("End turn")
            buttonTuple = ("End turn",False)



    #return ''.join(whichSquareList)
    return buttonTuple


playerIDDict = {"Player one":"red", "Player two":"orange", "Player three":"pink"}
playerIDList = ["Player one", "Player two", "Player three"]
cycledPlayersList = cycle(playerIDList)

def updateBoard(win, inputTuple, occupiedCountries, cardAmounts, cashReward,
turns, diceResults, currentPlayersTurn):

    # Set notification bar to current click
    notificationBar.setText(inputTuple)


    # Highlight the label of the player whose current turn it is
    for playerLabelTuple in playerNameLabels:
        if playerLabelTuple[1] == currentPlayersTurn:
            playerLabelTuple[0].setFill("green")
        elif playerLabelTuple[1] != currentPlayersTurn and inputTuple[1] == True:
            playerLabelTuple[0].setFill("gray")

    # Color board according to what players own and add troops to each country
    for countryTuple in occupiedCountries:
        countriesDict[countryTuple[0]][0].setFill(playerIDDict[countryTuple[1]])
        countriesDict[countryTuple[0]][1].setText(countryTuple[2])

    # Display card amounts for each player
    for cardTuple in cardAmounts:
        playerCards[cardTuple[0]].setText(cardTuple[1])

    # Highlights the country/button most recently clicked
    if (inputTuple[1] == True): # Deals with countries
        # Set all other countries/buttons to black outline
        for key in countriesDict:
            countriesDict[key][0].setOutline("black")
            countriesDict[key][0].setWidth(1)
        endTurnButton.setOutline("black")
        endTurnButton.setWidth(1)
        # Highlight the country selected
        countriesDict[inputTuple[0]][0].setOutline("white")
        countriesDict[inputTuple[0]][0].setWidth(6)
    elif inputTuple[0] == "End turn": # Deals with end turn button
        # Set all other countries/buttons to black outline
        for key in countriesDict:
            countriesDict[key][0].setOutline("black")
            countriesDict[key][0].setWidth(1)
        # Highlight end turn button
        endTurnButton.setOutline("white")
        endTurnButton.setWidth(4)


    cashCardReward.setText("Cash card reward is " + str(cashReward))
    turnsTaken.setText("Turns taken: " + str(turns))
    diceResultLabel.setText("Attacker rolled "+str(diceResults[0]) +
    "\n Defender rolled " + str(diceResults[1]))


### End of Risk: Final Project Code ###



    """Set coordinates of window to run from (x1,y1) in the
    lower-left corner to (x2,y2) in the upper-right corner."""


def test():
    win = GraphWin()
    win.setCoords(0,0,10,10)
    t = Text(Point(5,5), "Centered Text")
    t.draw(win)
    p = Polygon(Point(1,1), Point(5,3), Point(2,7))
    p.draw(win)
    e = Entry(Point(5,6), 10)
    e.draw(win)
    win.getMouse()
    p.setFill("red")
    p.setOutline("blue")
    p.setWidth(2)
    s = ""
    for pt in p.getPoints():
        s = s + "(%0.1f,%0.1f) " % (pt.getX(), pt.getY())
    t.setText(e.getText())
    e.setFill("green")
    e.setText("Spam!")
    e.move(2,0)
    win.getMouse()
    p.move(2,3)
    s = ""
    for pt in p.getPoints():
        s = s + "(%0.1f,%0.1f) " % (pt.getX(), pt.getY())
    t.setText(s)
    win.getMouse()
    p.undraw()
    e.undraw()
    t.setStyle("bold")
    win.getMouse()
    t.setStyle("normal")
    win.getMouse()
    t.setStyle("italic")
    win.getMouse()
    t.setStyle("bold italic")
    win.getMouse()
    t.setSize(14)
    win.getMouse()
    t.setFace("arial")
    t.setSize(20)
    win.getMouse()
    win.close()

#MacOS fix 2
#tk.Toplevel(_root).destroy()

# MacOS fix 1
update()

if __name__ == "__main__":
    test()
