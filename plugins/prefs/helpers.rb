module AresMUSH
  module Prefs

    def self.preferences
      Global.read_config('prefs', 'preferences') || []
    end
    
    def self.can_edit_prefs?(actor, model)
      return false if !actor
      return true if actor.name == model.name
      actor && actor.has_permission?("manage_prefs")
    end

    def self.build_profile_prefs(char)
      # okay, what we want to build is {categoryname: {one: 1, two: 3, three: 2}, categoryname: {one: 1, two: 3, three: 2}}      
      # check existence of list. If there's no list, create list with all 2s. If there is one, use it.       
      pref_list = {}
      new_prefs = {}
      Prefs.preferences.each do |cat, items|
        temp_prefs = {}
        items.each do |pref|
          if (char.rp_prefs == nil || !char.rp_prefs[cat].key?(pref))
            temp_prefs[pref] = "2"
          else
            temp_prefs[pref] = char.rp_prefs[cat][pref]  
          end
        end  
        new_prefs[cat] = temp_prefs
      end  
      char.update(rp_prefs: new_prefs)
      pref_list = char.rp_prefs 
      return pref_list
    end
    
    def self.uninstall_plugin
      Character.all.each do |c|
        c.update(rp_prefs: nil)
        c.update(rp_notes: nil)
      end
    end

  end
end