from graphics import *

################################

### Risk: Final Project Code ###

notificationBar = Text(Point(16,19),'')
cashCardReward = Text(Point(92,92),'')
turnsTaken = Text(Point(9,98),'')
endTurnButton = Rectangle(Point(33,15),Point(42,23))

color_red = color_rgb(220,20,60)
color_blue = color_rgb(100,149,237)
color_green = color_rgb(50,205,50)
color_purple = color_rgb(138,43,226)

playerIDDict = {"Player one":color_red, "Player two":color_blue, "Player three":color_green, "Player four":color_purple}

playerNameLabels = [(Rectangle(Point(1,2),Point(10,8)), "Player one"),
(Rectangle(Point(26,2),Point(35,8)), "Player two"),
(Rectangle(Point(51,2),Point(60,8)), "Player three"),
(Rectangle(Point(76,2),Point(84,8)), "Player four")
]

playerCards = {"Player one": Text(Point(12,5),0), "Player two": Text(Point(37,5),0),
                "Player three": Text(Point(62,5),0), "Player four": Text(Point(86,5),0)}

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

attack1 = Image(Point(86,88),"one.ppm")
attack2 = Image(Point(86,88),"one.ppm")
attack3 = Image(Point(86,88),"one.ppm")
defend1 = Image(Point(86,88),"one.ppm")
defend2 = Image(Point(86,88),"one.ppm")

card_value = Text(Point(70,61.5),"5")

oldInputTuple = ("",False)
def drawBoard():
    # Set up window
    win = GraphWin("BIG RED R!SK", 1200, 700)
    win.setCoords(0,0,100,100) # 100 by 100 grid
    win.setBackground(color_rgb(255,99,71)) # red color


    # Draw continent outlines, labels, and connections
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
    central_value = Text(Point(29,68),"+8")
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
    collegetown_value = Text(Point(48,28),"+3")
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

    # Set up player labels
    playerNameLabels[0][0].setFill(color_red)
    playerNameLabels[0][0].setOutline("white")
    playerNameLabels[0][0].setWidth("4")
    playerNameLabels[0][0].draw(win)
    playerNameLabels[1][0].setFill(color_blue)
    playerNameLabels[1][0].draw(win)
    playerNameLabels[2][0].setFill(color_green)
    playerNameLabels[2][0].draw(win)
    playerNameLabels[3][0].setFill(color_purple)
    playerNameLabels[3][0].draw(win)

    # Draw player number of cards
    for player in playerCards:
    	playerCards[player].draw(win)



    # Set up end turn button
    endTurnButton.setFill(color_rgb(0,0,205))
    endTurn = Text(Point(37.5,19),"Done")
    endTurn.setSize(18)
    endTurn.setStyle("bold")
    endTurn.setTextColor("white")
    endTurnButton.draw(win)
    endTurn.draw(win)

    #cashCardReward.draw(win)
    turnsTaken.draw(win)
    #diceResultLabel.draw(win)

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
    game_name.setTextColor(color_rgb(178,34,34))
    game_name.draw(win)

    dice_box = Rectangle(Point(82,70),Point(98,93))
    dice_box.setOutline("white")
    dice_split = Line(Point(90,70),Point(90,93))
    dice_split.setOutline("white")
    dice_split.draw(win)
    dice_box.draw(win)

    dice_title = Text(Point(90,96.5),"Dice rolls")
    dice_title.setTextColor("white")
    dice_title.setSize(20)
    dice_title.draw(win)

    dice_attack_name = Text(Point(86,93.6),"Attack")
    dice_attack_name.setTextColor("white")
    dice_attack_name.draw(win)
    dice_defend_name = Text(Point(94,93.6),"Defend")
    dice_defend_name.setTextColor("white")
    dice_defend_name.draw(win)

    card = Rectangle(Point(64,57),Point(76,70))
    card.setFill("gold")
    card.draw(win)
    card_title = Text(Point(70,67),"Next Card Rewards")
    card_title.setStyle("bold")
    card_title.setSize(14)
    card_title.draw(win)

    card_value.setSize(30)
    card_value.draw(win)

    #updateDice([4,5],[1],win)

    # label.setPixmap(pixmap)
    # w.resize(pixmap.width(),pixmap.height())


    return win



def clicker(win):
    global _root
    whichSquareList = []
    buttonTuple = ("",False)

    while(len(whichSquareList) < 1):


        try:
            clicked = win.getMouse()
        except:
            win.close()
            return ("Exit",False)


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

    return buttonTuple

def updateDice(attack,defend,win):
    global attack1,attack2,attack3,defend1,defend2

    attack1.undraw()
    attack2.undraw()
    attack3.undraw()
    defend1.undraw()
    defend2.undraw()

    if len(attack)==3:
        # diceLabels["attack1"].setPixmap(dice[attack[0]])
        attack1 = Image(Point(86,88),dice[attack[0]])
        attack1.draw(win)
        attack2 = Image(Point(86,82),dice[attack[1]])
        attack2.draw(win)
        attack3 = Image(Point(86,76),dice[attack[2]])
        attack3.draw(win)

    if len(attack)==2:
        attack1 = Image(Point(86,86),dice[attack[0]])
        attack1.draw(win)
        attack2 = Image(Point(86,78),dice[attack[1]])
        attack2.draw(win)

    if len(attack)==1:
        attack1 = Image(Point(86,86),dice[attack[0]])
        attack1.draw(win)

    if len(defend)==2:
        defend1 = Image(Point(94,86),dice[defend[0]])
        defend1.draw(win)
        defend2 = Image(Point(94,78),dice[defend[1]])
        defend2.draw(win)

    if len(defend)==1:
        defend1 = Image(Point(94,86),dice[defend[0]])
        defend1.draw(win)


def updateNotificationBar(notification):
    # Set notification bar to current click
    if (notification != ""):
        notificationBar.setText(notification)

def updatePlayerLabels(currentPlayersTurn,inputTuple):
    for playerLabelTuple in playerNameLabels:
        if playerLabelTuple[1] == currentPlayersTurn:
            # playerLabelTuple[0].setFill("green")
            playerLabelTuple[0].setOutline("white")
            playerLabelTuple[0].setWidth("4")
        elif playerLabelTuple[1] != currentPlayersTurn and inputTuple[1] == True:
            #playerLabelTuple[0].setFill("gray")
            playerLabelTuple[0].setOutline("black")
            playerLabelTuple[0].setWidth("1")

def updateOutlines(inputTuple):
    global oldInputTuple

    if (oldInputTuple == inputTuple and oldInputTuple[1] == True):
        countriesDict[inputTuple[0]][0].setOutline("black")
        countriesDict[inputTuple[0]][0].setWidth(1)

        countriesDict[inputTuple[0]][0].setOutline("white")
        countriesDict[inputTuple[0]][0].setWidth(2)

    elif (oldInputTuple == inputTuple and oldInputTuple[1] == False):
        endTurnButton.setOutline("black")
        endTurnButton.setWidth(1)

        endTurnButton.setOutline("white")
        endTurnButton.setWidth(4)

    elif (inputTuple[1] == True):
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

def update(win, countryTuple, cardAmounts, cashReward,
turns, diceResults, currentPlayersTurn, notification):


    # Color board according to what players own and add troops to each country
    if (countryTuple != None):
        countriesDict[countryTuple[0]][0].setFill(playerIDDict[countryTuple[1]])
        countriesDict[countryTuple[0]][1].setText(countryTuple[2])

    # Set notification bar to current click
    updateNotificationBar(notification)

    # Display card amounts for each player
    for cardTuple in cardAmounts:
        g = playerCards[cardTuple[0]]
        g.setText(cardTuple[1])

    card_value.setText(str(cashReward))

    #cashCardReward.setText("Cash card reward is " + str(cashReward))
    turnsTaken.setText("Turns taken: " + str(turns) + "\nGame ends at 50 turns")
    #diceResultLabel.setText("Attacker rolled "+str(diceResults[0]) +
    #"\n Defender rolled " + str(diceResults[1]))

def updateAttack(win, inputTuple, occupiedCountries, countryTuple2, cardAmounts, cashReward,
turns, diceResults, currentPlayersTurn, notification):
    global oldInputTuple

    update(win, occupiedCountries, cardAmounts, cashReward,
    turns, diceResults, currentPlayersTurn, notification)

    if (countryTuple2 != None):
        countriesDict[countryTuple2[0]][0].setFill(playerIDDict[countryTuple2[1]])
        countriesDict[countryTuple2[0]][1].setText(countryTuple2[2])

    # Highlight the label of the player whose current turn it is
    updatePlayerLabels(currentPlayersTurn,inputTuple)
    # Highlight the label of the country selected
    updateOutlines(inputTuple)



def updateBoard(win, inputTuple, occupiedCountries, cardAmounts, cashReward,
turns, diceResults, currentPlayersTurn, notification):
    global oldInputTuple

    update(win, occupiedCountries, cardAmounts, cashReward,
    turns, diceResults, currentPlayersTurn, notification)

    # Highlight the label of the player whose current turn it is
    updatePlayerLabels(currentPlayersTurn,inputTuple)
    # Highlight the label of the country selected
    updateOutlines(inputTuple)


def updateBoardNoClick(win, occupiedCountries, cardAmounts, cashReward,
turns, diceResults, currentPlayersTurn, notification):

    update(win, occupiedCountries, cardAmounts, cashReward,
    turns, diceResults, currentPlayersTurn, notification)

    updatePlayerLabels(currentPlayersTurn,("",True))

def endgame(win,player_id):
    # rec = Rectangle(Point(10,10),Point(90,90))
    # rec.setFill("gray")
    # rec.draw(win)

    end = Image(Point(50,50),"end.ppm")
    endtext = Text(Point(50,85), "Congratulations " + player_id + "! You have conquered Cornell!!")
    endtext.setTextColor("#FC0C0C")
    endtext.setSize(32)
    endtext.setStyle("bold")
    end.draw(win)
    endtext.draw(win)

    try:
        clicked = win.getMouse()
    except:
        win.close()
        return ("Exit",False)


### End of Risk: Final Project Code ###
