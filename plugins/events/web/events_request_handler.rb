module AresMUSH
  module Events
    class EventsRequestHandler
      def handle(request)
        enactor = request.enactor

        error = Website.check_login(request, true)
        return error if error

        events = Event.sorted_events.map { |e| {
          id: e.id,
          title: e.title,
          category: e.category,
          organizer: {
            name: e.character.name,
            id: e.character.id,
            icon: Website.icon_for_char(e.character) },
          start_datetime_local: e.start_datetime_local(enactor),
          start_time_standard: e.start_time_standard,
          content_warning: e.content_warning,
          is_signed_up: e.is_signed_up?(enactor),
          tags: e.content_tags
        }}
        theMonth = Date.today.strftime('%m')
        theYear = Date.today.strftime('%Y')
        theSource = "calendar#{theYear}/#{theMonth}.jpg"
        calendar_image = if File.file?("#{AresMUSH.website_uploads_path}/#{theSource}")
          "/game/uploads/#{theSource}"
        else
          false;
        end

        calendar_data = Global.read_config('custom', 'calendar')
        month_name = Date.today.strftime('%B')
        char_name = calendar_data["year#{theYear}"]["month#{theMonth}"]["char"]
        char_full_name = calendar_data["year#{theYear}"]["month#{theMonth}"]["name"]

        {
          events: events,
          calendar_url: "#{AresMUSH::Game.web_portal_url}/events/ical",
          calendar_image: calendar_image,
          month_name: month_name,
          char_name: char_name,
          char_full_name: char_full_name
        }
      end
    end
  end
end
