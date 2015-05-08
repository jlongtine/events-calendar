## Introduction ##

  * Events\_calendar Ruby on Rails plugin contains both client side and the administrator side of an events calendar.
  * It can be used to display events in a particular Google calendar.
  * Users can set their custom events types and a color for that particular type.
  * Also, it can be used to add,delete and update calendars and events for a particular Google account.

## Install ##
  * In your rails application run the following command.
> > -  ruby script/plugin install http://events-calendar.googlecode.com/svn/tags/events-calendar-0.0.2

## Dependency ##
  * Install the "gcal4ruby (0.2.2)" ruby gem.
  * Install the "Calendar Date Select" plugin. Run the following command.
> > -  ruby script/plugin install http://calendardateselect.googlecode.com/svn/tags/calendar_date_select

## Usage ##
Edit the **calendar\_config.yml** which is in the config folder, as following.
  * **CLIENT\_CAL\_ID** - Enter the calendar ID of the calendar which you want to display in the event calendar.
> > (You can find the calendar ID of a particular google calendar by viewing the calendar settings from your google calendar page).
  * **ADMIN\_CALENDAR\_EMAIL\_ADDRESS** - Google Email address the account which you want to manage.

  * **ADMIN\_CALENDAR\_PASSWORD** - Password of the gmail account.

In **events\_types.xml** file you can add custom events types and a colour which you want to dispay the event in the event calendar.
You can set true or false for the "disply\_first\_only" element. IF it is set to true, only the first date will be highlighted
in repeating events.

## Example ##
  * Client Side
> > - http://your_hostname:port/calendar_clients
  * Admin Side
> > - http://your_hostname:port/calendars
> > > Click on the "refresh list" link to get the calendar list of the Google account(first run only).