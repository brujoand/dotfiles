# Heavily inspired by https://github.com/imRohan/ubersicht-morning.widget

# Get my todos
command: "source /Users/vsasanb/src/brujoand/dotfiles/bash/gtd.bash && tdy"

refreshFrequency: 10000

#Body Style
style: """

  color: #fff
  font-family: Helvetica Neue, Arial

  .main
   position: relative
   width: 100vw
   height: 100vh
   background: rgba(0, 0, 0, 0.2);

  .container
   position: absolute
   top: 50%
   left: 50%
   transform: translate(-50%, -50%)
   height:800px
   width:1200px
   font-weight: lighter
   font-smoothing: antialiased
   text-align:center
   text-shadow: 0px 0px 30px #000, -2px -2px 1px #000;

  .time
   font-size: 13em
   color:#fff
   font-weight:700
   text-align:center

  .half
   font-size:0.15em
   margin-left: -5%

  .text
   font-size: 4em
   color:#fff
   font-weight:800
   margin-top:-3%

  .hour
   margin-right:2%

  .min
   margin-left:-4%

  .salutation
   margin-right:-2%

  .todo
   font-size: 0.4em
   text-align:left

"""

#Render function
render: -> """
  <div class="main">
  <div class="container">
  <div class="time">
  <span class="hour"></span>:
  <span class="min"></span>
  <span class="half"></span>
  </div>
  <div class="text">
  <span class="salutation"></span>
  <span class="name"></span>
  <pre class="todo"></pre>
  </div>
  </div>
  </div>

"""

  #Update function
update: (output, domEl) ->

  #Time Segmends for the day
  segments = ["morning", "afternoon", "evening", "night"]

  #Grab the name of the current user.
  name = "Anders"
  todo = output

  #Creating a new Date object
  date = new Date()
  hour = date.getHours()
  minutes = date.getMinutes()

  #Quick and dirty fix for single digit minutes
  minutes = "0"+ minutes if minutes < 10

  #timeSegment logic
  timeSegment = segments[0] if 4 < hour <= 11
  timeSegment = segments[1] if 11 < hour <= 17
  timeSegment = segments[2] if 17 < hour <= 24
  timeSegment = segments[3] if  hour <= 4

  #DOM manipulation
  $(domEl).find('.salutation').text("Good #{timeSegment}")
  $(domEl).find('.name').text(" , #{name}.")
  $(domEl).find('.hour').text("#{hour}")
  $(domEl).find('.min').text("#{minutes}")
  $(domEl).find('.todo').text("#{todo}")
