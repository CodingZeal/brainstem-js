class App.Models.TimeEntry extends Brainstem.Model
  paramRoot: 'time_entry'

  methodUrl: (method) ->
    switch method
      when "delete" then "/api/time_entries"
      when "create" then "/api/time_entries"
      else "/api/time_entries/#{@id}"

  @associations:
    workspace: "workspaces"
    story: "stories"
    user: "users"

class App.Collections.TimeEntries extends Brainstem.Collection
  model: App.Models.TimeEntry
  url: '/api/time_entries'

  @getComparator: (field) ->
    if field == "date_performed"
      return (a, b) -> a.getDatePerformed().getTime() - b.getDatePerformed().getTime()
    else
      super