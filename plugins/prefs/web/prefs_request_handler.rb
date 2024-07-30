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
          the_prefs.each do |pref|
            everything[cat][pref] = {}
            3.times.each do |lvl|
              everything[cat][pref][lvl + 1] = chars
                .select { |c| c[:rp_prefs][cat][pref] == (lvl + 1).to_s}
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
      
      def group_prefs
        groups = type.all
           .select { |s| s.character && s.character.is_approved? && s.character.is_active? }
           .group_by { |a| a.name }
           .sort

        everybody = {}
        groups.each do |name, skills|
          everybody[name] = {}
          levels.times.each do |lvl|
            everybody[name][lvl + 1] = skills
               .select { |s| s.rating == lvl + 1}
               .map { |s| s.character.name }
               .sort
          end
        end
        everybody
      end
    end
  end
end