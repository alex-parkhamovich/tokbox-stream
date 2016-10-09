# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

viewersCount = 0

updateViewersCount = (change)->
  viewersCount += change
  $('#viewers').text(viewersCount)

$(document).on 'ready page:load', ->
  return unless window.gon

  console.log("Init Stream")
  # get session id somehow
  console.log(gon.opentok)


  # Initialize an OpenTok Session object
  session = TB.initSession(gon.opentok.sessionId);

  videoOptions = {width: 640, height: 480}

  if gon.opentok.role == 'publisher'
    # Initialize a Publisher, and place it into the element with id="publisher"
    publisher = TB.initPublisher(gon.opentok.apiKey, 'publisher', videoOptions);


  # Attach event handlers
  session.on
    # This function runs when session.connect() asynchronously completes
    sessionConnected: (event) ->
      # Publish the publisher we initialzed earlier (this will trigger 'streamCreated' on other
      # clients)
      console.log('Session connected')
      if session.capabilities.publish == 1
        console.log('Start publishing')
        session.publish(publisher)
      else
        return


    # This function runs when another client publishes a stream (eg. session.publish())
    streamCreated: (event)->
      # Create a container for a new Subscriber, assign it an id using the streamId, put it inside
      # the element with id="subscribers"
      subContainer = document.createElement('div');
      subContainer.id = 'stream-' + event.stream.streamId;
      document.getElementById('subscribers').appendChild(subContainer);

      # Subscribe to the stream that caused this event, put it inside the container we just made
      console.log('Start subscribing to the video')
      session.subscribe(event.stream, subContainer, videoOptions);

    connectionCreated: (event)->
      updateViewersCount(+1)

    connectionDestroyed: (event)->
      updateViewersCount(-1)


    # Connect to the Session using the 'apiKey' of the application and a 'token' for permission
    session.connect(gon.opentok.apiKey, gon.opentok.token);