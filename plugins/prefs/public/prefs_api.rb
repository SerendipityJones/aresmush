module AresMUSH
  module Prefs
    
    def self.build_web_profile_data(char, viewer)      
      rp_prefs = Prefs.build_profile_prefs(char)
      {
        rp_prefs: rp_prefs,
        rp_notes: Website.format_markdown_for_html(char.rp_notes),
        pref_list: Prefs.preferences
      }
    end
    
    def self.save_web_profile_data(char, enactor, args)
      if (!Prefs.can_edit_prefs?(enactor, char))
        return t('dispatcher.not_allowed')
      end
      Global.logger.info args[:rp_prefs]
      char.update(rp_prefs: args[:rp_prefs])
      char.update(rp_notes: Website.format_input_for_mush(args[:rp_notes]))
      nil
    end
    
    def self.build_web_profile_edit_data(char, enactor, is_profile_manager)      
      rp_prefs = Prefs.build_profile_prefs(char)
      {
        rp_prefs: rp_prefs,
        rp_notes: Website.format_input_for_html(char.rp_notes),
        pref_list: Prefs.preferences,
        show_rp_prefs_tab: true
      }
    end
  end
end
