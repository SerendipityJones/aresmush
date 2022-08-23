module AresMUSH
  module Custom

    def self.web_dotcount(char)
      max_xp = Global.read_config("fs3skills", "max_xp_hoard")
      max_attrs = Global.read_config("fs3skills", "max_points_on_attrs")/2 + Global.read_config("fs3skills", "attr_dots_beyond_chargen_max") + 12
      max_action = Global.read_config("fs3skills", "max_points_on_action") + Global.read_config("fs3skills", "action_dots_beyond_chargen_max") + 18
      poor_attr = false
      ClassTargetFinder.with_a_character(char, Character, char) do |model|
        spent_attrs = FS3Skills::AbilityPointCounter.points_on_attrs(model)/2 + Global.read_config('fs3skills', 'attributes').length * 2
        spent_action = FS3Skills::AbilityPointCounter.points_on_action(model) + Global.read_config('fs3skills', 'action_skills').length
        model.fs3_attributes.each do |attr|
          if attr.rating == 1
            max_attrs -= 1
            spent_attrs -= 1
            poor_attr = true
          end
        end
        remaining_attrs = max_attrs - spent_attrs
        remaining_action = max_action - spent_action
        if remaining_attrs == 0 && remaining_action == 0
          msg = "Your Attributes and Action/Magic Skills are both at max!"
        elsif remaining_attrs == 0
          msg = "Your Attributes are at max, and you have #{remaining_action} more dot#{remaining_action == 1 ? '' : 's'} to place in Action/Magic Skills."
        else
          msg = "You have #{remaining_attrs} more dot#{remaining_attrs == 1 ? '' : 's'} to place in Attributes and "
          if remaining_action == 0
            msg += "are at max in Action/Magic Skills."
          else
            msg += "#{remaining_action} for Action/Magic Skills."
          end
        end
        if poor_attr
          msg += "<br/>Raising a 'poor' Attribute to 'average' will not subtract from your remaining attribute dots."
        end
        return msg
      end
    end
  end
end
