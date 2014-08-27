<h2>Savings Organizer Documentation</h2>

<h3>Project Description</h3>

The Savings Organizer application is a web-based tool for people who desire to organize their savings account(s) into separate categories for which they are saving (e.g. emergency, travel, etc.); whereby the user can add (or deduct) dollar entries from each category, and track savings for different purposes to meet their saving goals. Application data is stored in a PostgreSQL database for subsequent user sessions.

<h3>Application Development</h3>

The application is developed with the Ruby on Rails framework utilizing an MVC architecture, and includes usage of HTML, CSS, JavaScript, jQuery, PostgreSQL, and RSpec. The application is deployed at https://savings-organizer.herokuapp.com. In addition, an application demo can be viewed at http://www.slideshare.net/gjrslides/savings-organizer.  The following section on application usage gives a brief description of how to use the application and is presented in an order that a new user would find most useful.

<h3>Application Usage</h3>

<h4>User Registration/Sign In</h4>

In order to use the application, the user must initially register to create a new user account via the New User Registration page.  The Registration page can be accessed through the User Sign In page and Register button. Once the user has registered successfully, they can sign into the application via the User Sign In page.

<h4>Welcome Page</h4>

Once successfully signed into the application, a user is redirected to the Users Welcome page. From the Welcome page the user can view a summary of their previously created savings accounts, or navigate to other application pages by using the menu on the left side of application.

<h4>Create Savings Account</h4>

New users need to start out by creating one or more savings accounts (e.g. Primary Savings, Joe's Savings, etc.). New saving accounts can be created by clicking the Create Account menu selection and entering a new savings account name on the Create Savings Account page.

<h4>Create Savings Category</h4>

Once a user has created a savings account, then the user can start creating savings categories within the savings account (e.g. emergency funds, new automobile, travel, etc.) via the Create Savings Category page.  On the Create Savings Category page, the user can specify which savings account to associate with the new savings category, the name of the savings category, and optionally a dollar goal amount and date for the category.

<h4>Add or Deduct Savings Entries</h4>

After the user has created a savings account and categories, then the user can start adding (or deducting) dollar entries from the created categories.  Through the Add Savings Entries and Deduct Savings Entries pages, the user can specify a date and amount for the dollar entries.  Note that the Deduct Savings Entries page shows the current category balance, and the user cannot deduct an amount larger than the current balance.  There are also application validation features that prevent the user from creating a deduction entry that results in a negative balance in the savings history.

<h4>View/Edit User</h4>

The View User page allows a user to view their savings account name and total savings, edit a savings account name, or delete a savings account.

<h4>Manage Account</h4>

The Manage Account page allows the user to update their password, email, or username; or totally delete their user account along with all of their user data.

<h4>View/Edit Account</h4>

The View Account page shows a summary of the different categories that have been created for a given savings account in a tabular format. The user can change savings accounts, or update and delete savings categories.

<h4>View/Edit Category</h4>

The View Category page shows a summary of a savings category, where the user can view all of the addition and deduction entries for the selected category in a tabular and graphical format. The user can hover over plotted chart lines deflection points with their mouse to display data. Note that there are application validation features that prevent the user from updating or deleting an entry that results in a negative balance in the savings history.

<h4>View Entries</h4>

The View Entries page shows a summary of all categories and entries for a given savings account in a tabular and graphical format. The user can hover over plotted chart lines deflection points with their mouse to display data.

<h4>Sign Out</h4>

A user can sign out of the application by clicking the Sign Out selection on left side menu.
