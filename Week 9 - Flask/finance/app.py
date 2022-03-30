import os

from cs50 import SQL
from flask import Flask, flash, redirect, render_template, request, session
from flask_session import Session
from tempfile import mkdtemp
from werkzeug.security import check_password_hash, generate_password_hash
from datetime import datetime

from helpers import apology, login_required, lookup, usd

# Configure application
app = Flask(__name__)

# Ensure templates are auto-reloaded
app.config["TEMPLATES_AUTO_RELOAD"] = True

# Custom filter
app.jinja_env.filters["usd"] = usd

# Bring in usd function into Jinja
app.jinja_env.globals.update(usd=usd)

# Configure session to use filesystem (instead of signed cookies)
app.config["SESSION_PERMANENT"] = False
app.config["SESSION_TYPE"] = "filesystem"
Session(app)

# Configure CS50 Library to use SQLite database
db = SQL("sqlite:///finance.db")

# Make sure API key is set
if not os.environ.get("API_KEY"):
    raise RuntimeError("API_KEY not set")


@app.after_request
def after_request(response):
    """Ensure responses aren't cached"""
    response.headers["Cache-Control"] = "no-cache, no-store, must-revalidate"
    response.headers["Expires"] = 0
    response.headers["Pragma"] = "no-cache"
    return response


@app.route("/")
@login_required
def index():
    """Show portfolio of stocks"""
    portfolio = db.execute("SELECT * FROM portfolio WHERE userid=?", session["user_id"])
    existingBalance = db.execute(
        "SELECT cash FROM users where id = ?", session["user_id"]
    )

    # Calculate total value of stocks and update with current share price
    totalValue = 0
    for eachStock in portfolio:
        totalValue += eachStock["totalvalue"]
        stockPrice = lookup(eachStock["symbol"])
        db.execute(
            "UPDATE portfolio SET currentprice=? WHERE symbol=? AND userid=?",
            stockPrice["price"],
            eachStock["symbol"],
            session["user_id"],
        )

    return render_template(
        "index.html",
        portfolio=portfolio,
        cashBalance=existingBalance[0]["cash"],
        totalValue=totalValue,
    )


@app.route("/buy", methods=["GET", "POST"])
@login_required
def buy():
    """Buy shares of stock"""
    """ TRANSACTIONS table design strategy:
    - who bought
    - what was bought
    - quantity bought
    - unitprice bought
    - when bought
    CREATE TABLE transactions (id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, userid NUMERIC NOT NULL,
    symbol TEXT NOT NULL, quantity NUMERIC NOT NULL, unitprice NUMERIC NOT NULL, date DATETIME)

    PORTFOLIO table design strategy:
    - stock symbol
    - stock name
    - shares owned
    - current price
    - total value of each stock
    - userid
    CREATE TABLE portfolio (id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, symbol TEXT NOT NULL, name TEXT NOT NULL,
    shares NUMERIC NOT NULL, currentprice NUMERIC NOT NULL, totalvalue NUMERIC NOT NULL, userid NUMERIC NOT NULL)
    """
    if request.method == "POST":

        # Check for stock symbol entered
        symbol = request.form.get("symbol")
        if not symbol:
            return apology("Must provide a symbol", 403)

        # Check for valid # of shares
        shares = request.form.get("shares")
        if not shares or int(shares) <= 0:
            return apology("Must have at least 1 or more shares", 403)

        # If stock and shares provided, get stock details
        quote = lookup(symbol)

        # If lookup is an ivalid stock symbol
        if quote == None:
            return apology("Invalid stock symbol", 403)

        # Check if there is enough cash to buy
        balanceQuery = db.execute(
            "SELECT cash FROM users WHERE id=?", session["user_id"]
        )
        balance = balanceQuery[0]["cash"]
        totalCost = quote["price"] * int(shares)
        if totalCost > balance:
            return apology(
                f"Your balance of ${balance:,.2f} is less than the total cost which is ${totalCost:,.2f}",
                403,
            )

        # SQL to update transactions table to purchase stock
        now = datetime.now()
        dt_string = now.strftime("%d/%m/%Y %H:%M:%S")
        unitPrice = quote["price"]
        quoteSymbol = quote["symbol"]
        db.execute(
            "INSERT INTO transactions (userid, symbol, quantity, unitprice, date) VALUES (?, ?, ?, ?, ?)",
            session["user_id"],
            quoteSymbol,
            int(shares),
            "%.2f" % unitPrice,
            dt_string,
        )

        # Check if symbol is in current portfolio
        portfolioLookup = db.execute(
            "SELECT * FROM portfolio WHERE symbol=? AND userid=?",
            quoteSymbol,
            session["user_id"],
        )
        purchaseTotal = int(shares) * float(unitPrice)
        # If existing stock already owned, add to portfolio
        if len(portfolioLookup) == 1:
            # Get existing values to add to total
            existingShares = db.execute(
                "SELECT shares FROM portfolio WHERE symbol=? AND userid=?",
                quoteSymbol,
                session["user_id"],
            )
            existingTotal = db.execute(
                "SELECT totalvalue FROM portfolio WHERE symbol=? AND userid=?",
                quoteSymbol,
                session["user_id"],
            )
            newShares = int(existingShares[0]["shares"]) + int(shares)
            newTotal = float(existingTotal[0]["totalvalue"]) + float(purchaseTotal)
            # newAverage = float(newTotal / newShares)
            # Update existing stock with new values
            db.execute(
                "UPDATE portfolio SET shares=?, totalvalue=? WHERE symbol=? AND userid=?",
                newShares,
                # "%.2f" % newAverage,
                "%.2f" % newTotal,
                quoteSymbol,
                session["user_id"],
            )
        # If stock doesn't exist, add stock to portfolio
        else:
            db.execute(
                "INSERT INTO portfolio (symbol, name, shares, currentprice, totalvalue, userid) VALUES (?, ?, ?, ?, ?, ?)",
                quoteSymbol,
                quote["name"],
                int(shares),
                "%.2f" % unitPrice,
                "%.2f" % purchaseTotal,
                session["user_id"],
            )

        # Update cash balance
        existingBalance = db.execute(
            "SELECT cash FROM users where id = ?", session["user_id"]
        )
        newBalance = "%.2f" % (float(existingBalance[0]["cash"]) - float(purchaseTotal))
        db.execute(
            "UPDATE users SET cash=? WHERE id = ?",
            newBalance,
            session["user_id"],
        )

    return render_template("buy.html")


@app.route("/history")
@login_required
def history():
    """Show history of transactions"""
    # return apology("TODO")
    history = db.execute(
        "SELECT * FROM transactions WHERE userid=?", session["user_id"]
    )
    if len(history) <= 0:
        return apology("There are no transactions to display", 403)
    return render_template("history.html", transactions=history)


@app.route("/login", methods=["GET", "POST"])
def login():
    """Log user in"""

    # Forget any user_id
    session.clear()

    # User reached route via POST (as by submitting a form via POST)
    if request.method == "POST":

        # Ensure username was submitted
        if not request.form.get("username"):
            return apology("must provide username", 403)

        # Ensure password was submitted
        elif not request.form.get("password"):
            return apology("must provide password", 403)

        # Query database for username
        rows = db.execute(
            "SELECT * FROM users WHERE username = ?", request.form.get("username")
        )

        # Ensure username exists and password is correct
        if len(rows) != 1 or not check_password_hash(
            rows[0]["hash"], request.form.get("password")
        ):
            return apology("invalid username and/or password", 403)

        # Remember which user has logged in
        session["user_id"] = rows[0]["id"]

        # Redirect user to home page
        return redirect("/")

    # User reached route via GET (as by clicking a link or via redirect)
    else:
        return render_template("login.html")


@app.route("/logout")
def logout():
    """Log user out"""

    # Forget any user_id
    session.clear()

    # Redirect user to login form
    return redirect("/")


@app.route("/quote", methods=["GET", "POST"])
@login_required
def quote():
    """Get stock quote."""
    if request.method == "POST":

        # If no symbol entered
        symbol = request.form.get("symbol")
        if not symbol:
            return apology("Please provide a stock symbol", 403)

        # Use helper function lookup, returns (name, price, symbol or none)
        lookupSymbol = lookup(symbol)

        # If result is an ivalid stock symbol
        if lookupSymbol == None:
            return apology("Invalid stock symbol", 403)

        # Prepare data for quoted stock, USD format
        else:
            lookupSymbol["price"] = usd(lookupSymbol["price"])
            return render_template("quoted.html", quotedData=lookupSymbol)

    # GET request
    return render_template("quote.html")


@app.route("/register", methods=["GET", "POST"])
def register():
    """Register user"""
    # return apology("TODO")
    if request.method == "POST":

        # Ensure username was submitted
        if not request.form.get("username"):
            return apology("must provide username", 403)

        # Ensure password was submitted
        elif not request.form.get("password"):
            return apology("must provide password", 403)

        # Query database for username
        username = request.form.get("username")
        rows = db.execute("SELECT * FROM users WHERE username = ?", username)

        # Ensure username doesn't already exist
        if len(rows) == 1:
            return apology("username already exists", 403)

        # Ensure password matches
        password = request.form.get("password")
        confirmation = request.form.get("confirmation")
        if password != confirmation:
            return apology("passwords do not match", 403)

        # Insert into users db new registrant
        hashPass = generate_password_hash(password)
        db.execute(
            "INSERT INTO users (username, hash) VALUES (?, ?)",
            username,
            hashPass,
        )

        # Remember which user has logged in
        rowsId = db.execute("SELECT id FROM users WHERE username = ?", username)
        session["user_id"] = rowsId

        # Redirect user to home page
        return redirect("/")

    # User reached route via GET (as by clicking a link or via redirect)
    else:
        return render_template("register.html")


@app.route("/sell", methods=["GET", "POST"])
@login_required
def sell():
    """Sell shares of stock"""
    if request.method == "POST":

        # Check for stock symbol entered
        symbol = request.form.get("symbol")
        if not symbol:
            return apology("Must provide a symbol", 403)

        # Check if stock exists in portfolio
        portfolioLookup = db.execute(
            "SELECT * FROM portfolio WHERE symbol=? AND userid=?",
            symbol.upper(),
            session["user_id"],
        )
        if len(portfolioLookup) != 1:
            return apology(f"You do not own any of the stock: {symbol.upper()}", 403)

        # Check for valid # of shares
        shares = request.form.get("shares")
        if not shares or int(shares) <= 0:
            return apology("Must enter at least 1 or more shares", 403)

        # Check if # shares is <= available shares
        sharesLookup = int(portfolioLookup[0]["shares"])
        if int(shares) > sharesLookup:
            return apology(
                f"You do not own {shares} shares of the stock {symbol.upper()}"
            )

        # Get stock details
        quote = lookup(symbol)

        # SQL to update transactions table when selling stock
        now = datetime.now()
        dt_string = now.strftime("%d/%m/%Y %H:%M:%S")
        unitPrice = quote["price"]
        quoteSymbol = quote["symbol"]
        db.execute(
            "INSERT INTO transactions (userid, symbol, quantity, unitprice, date) VALUES (?, ?, ?, ?, ?)",
            session["user_id"],
            quoteSymbol,
            -abs(int(shares)),
            "%.2f" % unitPrice,
            dt_string,
        )

        # SQL to update portfolio table when selling stock
        # If full surrender of the stock, add sale value to cash total, remove row
        if int(shares) == sharesLookup:
            currentValue = int(shares) * unitPrice
            currentCash = db.execute(
                "SELECT cash FROM users WHERE id=?", session["user_id"]
            )
            updatedCash = currentValue + currentCash[0]["cash"]
            db.execute(
                "UPDATE users SET cash=? WHERE id=?",
                updatedCash,
                session["user_id"],
            )
            db.execute(
                "DELETE FROM portfolio WHERE symbol=? AND userid=?",
                quoteSymbol,
                session["user_id"],
            )

            # If partial surrender of the stock, add sale value to cash total and update portfolio
        else:
            currentValue = int(shares) * unitPrice
            currentCash = db.execute(
                "SELECT * FROM users WHERE id=?", session["user_id"]
            )
            updatedCash = currentValue + currentCash[0]["cash"]
            updatedShares = int(portfolioLookup[0]["shares"]) - int(shares)

            db.execute(
                "UPDATE users SET cash=? WHERE id=?",
                updatedCash,
                session["user_id"],
            )
            db.execute(
                "UPDATE portfolio SET shares=? WHERE symbol=? AND userid=?",
                updatedShares,
                quoteSymbol,
                session["user_id"],
            )

    return render_template("sell.html")


@app.route("/addcash", methods=["POST"])
@login_required
def addcash():
    cash = request.form.get("cash")
    if not cash:
        return apology("Enter cash value greater than 0", 403)

    # Get current cash balance and update the cash balance in the table
    currentCash = db.execute("SELECT cash FROM users WHERE id=?", session["user_id"])
    updatedCash = currentCash[0]["cash"] + float(cash)
    db.execute("UPDATE users SET cash=? WHERE id=?", updatedCash, session["user_id"])

    return redirect("/")
