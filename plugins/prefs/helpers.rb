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
        items.each do |key, desc|
          if (!char.rp_prefs.nil? && char.rp_prefs[cat].key?(key))
            temp_prefs[key] = char.rp_prefs[cat][key]  
          else
            temp_prefs[key] = "2"
          end
        end  
        new_prefs[cat] = temp_prefs
      end  
      char.update(rp_prefs: new_prefs)
      pref_list = char.rp_prefs 
      return pref_list
    end

    def self.sort_prefs
      pref_list = Global.read_config('prefs', 'preferences')        
      cat_list = pref_list.keys
      chars = Chargen.approved_chars
        .select { |c| !c.rp_prefs.blank? }
        .sort_by { |c| c.name }
        .map { |c| {
          name: c.name,
          rp_prefs: c.rp_prefs,
          rp_notes: c.rp_notes
         }
      }
      notes = []
      chars.each do |c|
        if (c[:rp_notes])
          notes << c[:name]
        end
      end
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
        pref_sort: everything,
        pref_notes: notes
      }
    end  

    def self.valid_key(key)
      Prefs.preferences.each do |cat, prefs|
        if (prefs.key?(key))
          return true
        end 
      end 
      return false 
    end        
    
    def self.uninstall_plugin
      Character.all.each do |c|
        c.update(rp_prefs: nil)
        c.update(rp_notes: nil)
      end
    end

  end
end