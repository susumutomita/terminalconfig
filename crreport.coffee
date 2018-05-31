# Description
#   Post CR status
#
# Configuration:
#   HUBOT_REVIEWBOARD_USERNAME -> user name of review board
#   HUBOT_REVIEWBOARD_PASSWORD -> password of review board
#
# Commands:
#   None
#
# Notes:
#   <optional notes required for the script>
#

cronJob = require('cron').CronJob
request = require("request")

getAgo = (from) ->
  now = new Date
  status = ":sunny:"
  msg = ""

  #console.log JSON.stringify(from)

  ago = now.getTime() - from.getTime()

  if ago > (24 * 60 * 60 * 1000)
    dateago = parseInt(ago / (24 * 60 * 60 * 1000))

    if dateago >= 2
        status = ":cloud:"

    if dateago >= 4
        status = ":fire:"

    if dateago >= 3
        msg = " *#{dateago} days ago* " if dateago?
    else
        msg = " #{dateago} days ago " if dateago?

  else
    hourago = parseInt(ago / (60 * 60 * 1000))
    msg = "#{hourago} hours ago" if hourago?

  return [status, msg]

module.exports = (robot) ->
    new cronJob('0 0 16 * * 1-5', () ->
    #new cronJob('0 0-59 * * * 1-5', () ->    
        timeZone: "America/Los_Angeles"
        
        ROOM = 'lumada-system'
        reviewBoardUrl = '***URL***'
        username = process.env.HUBOT_REVIEWBOARD_USERNAME
        password = process.env.HUBOT_REVIEWBOARD_PASSWORD
        auth = 'Basic ' + new Buffer(username + ':' + password).toString('base64')
        
        param =
            url: 'http://***URL***/api/review-requests/?max-results=200' #URL of rocket chat
            json: true
            headers: {'authorization': auth}
            
        sdets = ["Username1", "Username2"]
        devs  = ["Username1", "Username2"]

        robot.send {room: ROOM}, "*Remaining Code Reviews* [Link](#{reviewBoardUrl})"
        
        request.get param, (error, response, body) ->
            #console.log error
            #console.log response
            #console.log body

            numOfCR = 0

            for review in body.review_requests
                submitter = review.links.submitter.title
                numOfShipIt = review.ship_it_count
                ticketId = review.id
                
                update = getAgo(new Date(review.last_updated))

                if submitter in sdets or submitter in devs
                    numOfCR += 1
                    if numOfShipIt >= 2
                        robot.send {room: ROOM}, ":door: @#{submitter}\tLast Update:#{update[1]} - #{review.summary} - ship it:#{numOfShipIt} - id:#{ticketId}"
                    else 
                        robot.send {room: ROOM}, "#{update[0]} @#{submitter}\tLast Update:#{update[1]} - #{review.summary} - ship it:#{numOfShipIt} - id:#{ticketId}"
            #console.log(numOfCR)

            if numOfCR == 0
                robot.send {room: ROOM}, "All the CRs are over. Good Job! We did it!"
                robot.send {room: ROOM}, ":thumbsup:"
    ).start()
  
