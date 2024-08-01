module AresMUSH
  module Prefs
    class PrefsRequestHandler
      def handle(request)
        
        pref_list = Global.read_config('prefs', 'preferences')        
        cat_list = pref_list.keys
        chars = Chargen.approved_chars
          .select { |c| !c.rp_prefs.blank? }
          .sort_by { |c| c.name }
          .map { |c| {
            name: c.name,
            rp_prefs: c.rp_prefs
           }
        }
        everything = {}
        pref_list.each do |cat, the_prefs|
          everything[cat] = {}
          the_prefs.each do |key, desc|
            everything[cat][key] = {}
            3.times.each do |lvl|
              everything[cat][key][lvl + 1] = chars
                .select { |c| c[:rp_prefs][cat][key] == (lvl + 1).to_s}
                .map { |c| c[:name] }
                .sort
            end
          end  
        end
        {
          pref_list: pref_list,
          pref_sort: everything
        }
        
      end
    end
  end
end