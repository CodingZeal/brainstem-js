window.App ?= {}
window.App.Models ?= {}
window.App.Collections ?= {}

window.resultsArray = (key, models) ->
  _(models).map (model) -> { key: key, id: model.get("id") }

window.resultsObject = (models) ->
  results = {}
  for model in models
    results[model.id] = model
  results

window.convertTopLevelKeysToObjects = (data) ->
  for key in _(data).keys()
    continue if key in ["count", "results"]
    if data[key] instanceof Array
      data[key] = _(data[key]).reduce(((memo, item) -> memo[item.id] = item; memo ), {})

window.respondWith = (server, url, options) ->
  if options.resultsFrom?
    data = $.extend {}, options.data, results: resultsArray(options.resultsFrom, options.data[options.resultsFrom])
  else
    data = options.data
  convertTopLevelKeysToObjects data
  server.respondWith options.method || "GET",
                     url, [ options.status || 200,
                           {"Content-Type": options.content_type || "application/json"},
                           JSON.stringify(data) ]

beforeEach ->
  # Disable jQuery animations.
  $.fx.off = true

  # Basic page fixture
  $('#jasmine_content').html("<div id='wrapper'></div><div id='overlays'></div><div id='side-nav'></div><div id='main-view'></div></div>")

  # Setup a new base.
  window.base = {}
  window.base.data = new Brainstem.StorageManager()
  window.base.data.addCollection 'time_entries', App.Collections.TimeEntries
  window.base.data.addCollection 'posts', App.Collections.Posts
  window.base.data.addCollection 'tasks', App.Collections.Tasks
  window.base.data.addCollection 'projects', App.Collections.Projects
  window.base.data.addCollection 'users', App.Collections.Users


  # Define builders
  spec.defineBuilders()

  # Mock out all Ajax requests.
  window.server = sinon.fakeServer.create()
  sinon.log = -> console.log arguments

  # Requests for Backbone.history.getFragment() will always return the contents of spec.fragment.
  Backbone.history ||= new Backbone.History
  spyOn(Backbone.history, 'getFragment').andCallFake -> window.spec.fragment
  window.spec.fragment = "mock/path"

  # Prevent any actual navigation.
  spyOn Backbone.History.prototype, 'start'
  spyOn Backbone.History.prototype, 'navigate'

  # Use Jasmine's mock clock.  You can make time pass with jasmine.Clock.tick(N).
  jasmine.Clock.useMock()

afterEach ->
  window.clearLiveEventBindings()
  window.server.restore()
  $('#jasmine_content').html("")
  jasmine.Clock.reset()

window.clearLiveEventBindings = ->
  events = jQuery.data document, "events"
  for key, value of events
    delete events[key]

window.context = describe
window.xcontext = xdescribe

# Shared Behaviors
window.SharedBehaviors ?= {};

window.registerSharedBehavior = (behaviorName, funct) ->
  if not behaviorName
    throw "Invalid shared behavior name"

  if typeof funct != 'function'
    throw "Invalid shared behavior, it must be a function"

  window.SharedBehaviors[behaviorName] = funct

window.itShouldBehaveLike = (behaviorName, context) ->
  behavior = window.SharedBehaviors[behaviorName];
  context ?= {}

  if not behavior || typeof behavior != 'function'
    throw "Shared behavior #{behaviorName} not found."
  else
    jasmine.getEnv().describe "#{behaviorName} (shared behavior)", -> behavior.call(this, context)
