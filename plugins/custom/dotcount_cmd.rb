module AresMUSH
   module Custom
    class DotcountCmd
      include CommandHandler

      attr_accessor :name

      def parse_args
        self.name = cmd.args ? titlecase_arg(cmd.args) : enactor_name
      end

      def handle
        max_xp = Global.read_config("fs3skills", "max_xp_hoard")
        max_attrs = Global.read_config("fs3skills", "max_points_on_attrs")/2 + Global.read_config("fs3skills", "attr_dots_beyond_chargen_max") + 12
        max_action = Global.read_config("fs3skills", "max_points_on_action") + Global.read_config("fs3skills", "action_dots_beyond_chargen_max") + 18
        ClassTargetFinder.with_a_character(self.name, client, enactor) do |model|
          current_xp = model.xp
          pad_xp = current_xp < 10 ? '.' : ''
          spent_attrs = FS3Skills::AbilityPointCounter.points_on_attrs(model)/2 + Global.read_config('fs3skills', 'attributes').length * 2
          spent_action = FS3Skills::AbilityPointCounter.points_on_action(model) + Global.read_config('fs3skills', 'action_skills').length
          model.fs3_attributes.each do |attr|
            if attr.rating == 1
               max_attrs -= 1
               spent_attrs -= 1
            end
          end
		  msg = <<-DOTS.chomp
Total dots on #{model.name}'s sheet:

     Attributes...........#{spent_attrs} / #{max_attrs}
     Action Skills........#{spent_action} / #{max_action}
     Current XP...........#{pad_xp}#{current_xp.to_s} / #{max_xp}

Any Attribute at 1 also lowers the Attribute cap by one. However, it will rise again if the Attribute is bought up to 2.
		  DOTS
          template = BorderedDisplayTemplate.new msg
          client.emit template.render
        end
      end
    end
  end
end
