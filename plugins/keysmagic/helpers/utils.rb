module AresMUSH
  module KeysMagic
    def self.categories
      Global.read_config("keysmagic", "categories")
    end

    def self.catlist
      catList = []
      categories.each do |cat, data|
        catList << cat
      end
      return catList
    end

    def self.spells
      Global.read_config("keysmagic", "spells")
    end

    def self.icondir
      Global.read_config("keysmagic", "icon directory")
    end

    def self.pix
      Global.read_config("wikipix", "spellpix")
    end

    def self.is_spell?(candidate)
      verdict = false
      KeysMagic.spells.each do |spell, data|
        if spell.casecmp(candidate)==0
          verdict = spell
        end
      end
      return verdict
    end

    def self.is_category?(candidate)
      verdict = false
      if KeysMagic.categories.include?(Array(candidate).join)
        verdict = Array(candidate).join.titlecase
      end
      return verdict
    end

    def self.get_category(spell)
      the_spell = is_spell?(spell)
      return the_spell ? KeysMagic.spells[the_spell]["category"] : false
    end

    def self.category_spells(category)
      spellList = Array.new
      KeysMagic.spells.map do |sname, sdata|
        if sdata['category'].include? category
          spellList << sname
        end
      end
      return spellList
    end

    def self.all_spells_by_category
      allSpells = {}
      KeysMagic.categories.each{ |cat, data| allSpells[cat] = KeysMagic.category_spells(cat) }
      return allSpells
    end

    def self.get_spell_page(id)
      name = KeysMagic.is_spell?(id.gsub(/[_-]/," "))
      spell = KeysMagic.spells[name]
      spell['desc']['full'] = Website.format_markdown_for_html(spell['desc']['full'])
      category = KeysMagic.categories.select { | name, data | spell['category'].include? name.to_s }
      pic = KeysMagic.pix.sample
      {
        name: name,
        spell: spell,
        category: category,
        pic: pic
      }
    end

    def self.spell_info(spell)
      spellList = KeysMagic.spells
      categories = KeysMagic.categories
      this_spell = Hash.new
      # build roll
        if spellList[spell]["noroll"]
          roll = "None"
          this_spell["roll"] = roll
        elsif spellList[spell]["offense"] && spellList[spell]["offense"]["only"]
          roll = "Always Opposed"
          this_spell["roll"] = roll
        else
          roll = ""
          spellList[spell]["category"].each_with_index do |c, i|
            if i > 0
              roll += " & "
              this_spell["anomaly"] = true
            end
            if spellList[spell]["attribute"]
              roll += spellList[spell]["attribute"]
            else
              roll += categories[c]["attribute"]
            end
            roll += " + "
            if spellList[spell]["ability"]
              roll += spellList[spell]["ability"]
            else
              roll += c
            end
          end
          this_spell["roll"] = roll
        end
      #  build offense
        if spellList[spell]["offense"]
          if spellList[spell]["offense"]["attribute"]
            offense = spellList[spell]["offense"]["attribute"]
          end
          offense += " + "
          if spellList[spell]["offense"]["ability"]
            offense += spellList[spell]["offense"]["ability"]
          end
          this_spell["offense"] = offense
        end

      #  build defense
        if spellList[spell]["defense"]
          if spellList[spell]["defense"]["attribute"]
            defense = spellList[spell]["defense"]["attribute"]
          end
          defense += " + "
          if spellList[spell]["defense"]["ability"]
            defense += spellList[spell]["defense"]["ability"]
          end
          this_spell["defense"] = defense
        end

      #  build fs3
        if spellList[spell]["fs3"]
          this_spell["fs3"] = spellList[spell]["fs3"]
        end

        if spellList[spell]["special"]
          this_spell["special"] = spellList[spell]["special"]
        end

        if spellList[spell]["note"]
          this_spell["note"] = spellList[spell]["note"]["content"]
          this_spell["prefix"] = spellList[spell]["note"]["prefix"]
          this_spell["confirm"] = spellList[spell]["note"]["confirm"] ? spellList[spell]["note"]["confirm"] : false
        end

        return this_spell
    end

    def self.char_spells(name)
      char = Character.find_one_by_name(name)
      char_spells = Hash.new { |h, k| h[k] = h.dup.clear }
      return char_spells if !char.spells

      char.spells.each { |cat, spells|
        spells.each { |spell|
          char_spells[cat][spell] = KeysMagic.spell_info(spell)
        }
      }
      return char_spells
    end

    def self.has_spell?(name, spell)
      known = false
      included = false
      charspells = Character.find_one_by_name(name).spells
      char_spells(name).each do |cat, spells|
        if spells.include? spell
          included = true
        end
      end
      if (charspells && included)
        known = true
      end
      return known
    end

    def self.is_a_match?(char, target, spell)
      match = false
      first = Character.find_one_by_name(char)
      second = Character.find_one_by_name(target)
      unless second
        return match
      end
      if has_spell?(target, spell)
        unless second.spellnotes
          return match
        end
        is_set = second.spellnotes[spell]
        content = is_set ? Character.find_one_by_name(is_set).name : "Not a match"
        if (is_set and content == first.name)
          match = true
        end
      end
      return match
    end

    def self.processed_notes(char)
      target = Character.find_one_by_name(char)
      if target.spellnotes.nil?
        target.update(spellnotes: {})
      end
      charnotes = target.spellnotes
      charnotes.each { |spell, note|
        prefix = spell_info(spell)["prefix"]
        if KeysMagic.spell_info(spell)["confirm"]
          charnotes[spell] = is_a_match?(char,note,spell) ? prefix + " " + note : nil
        else
          charnotes[spell] = prefix + " " + note
        end
      }
      return charnotes
    end

    def self.current_cap(char, category)
      spellcap = FS3Skills.find_ability(char, category).rating/2.floor
      ability_name = 'Affinity ' + category
      bonus = FS3Skills.find_ability(char, ability_name)
      bonus = bonus.nil? ? 0 : bonus.rating
      spellcap = spellcap + bonus
      return spellcap
    end

    def self.can_learn?(char, category)
      spellcap = KeysMagic.current_cap(char, category)
      spellsknown = char.spells[category].nil? ? 0 : char.spells[category].length
      if (spellsknown < spellcap)
        true
      end
    end

    def self.spell_demographics
      allChars = Chargen.approved_chars
        .to_h { |c| [c.name, c.spells] }
        .sort

      everybody = {}
      KeysMagic.categories.each do |cat,data|
        everybody[cat] = {}
        KeysMagic.category_spells(cat).each do |spell|
          everybody[cat][spell] = []
        end
      end
      allChars.each do |name, list|
        unless list.nil?
          list.each do |cat, spells|
            spells.each do |spell|
              everybody[cat][spell].to_a << name
              everybody[cat][spell].sort!
            end
          end
        end
      end
      everybody
    end

    def self.create_spell_job(char, spell, category, pronoun, status)
      if (status == "add")
        msg = 'keysmagic.spell_added_job'
        job = 'keysmagic.spell_added_job_title'
      elsif (status == "remove")
        msg = 'keysmagic.spell_removed_job'
        job = 'keysmagic.spell_removed_job_title'
      else
        return error
      end
      message = t(msg, :name => char.name, :spell => spell, :pronoun => pronoun, :category => category)
      category = Jobs.system_category
      status = Jobs.create_job(category, t(job, :name => char.name), message, Game.master.system_character)
      if (status[:job])
        Jobs.close_job(Game.master.system_character, status[:job])
      end
    end

    def self.parse_and_cast(char, spell, defense)
      if (spell.is_integer?)
        dice = (spell.to_i) + 2
        die_result = FS3Skills.roll_dice(dice)
      else
        spell_params = KeysMagic.parse_spell_params(spell, defense)
        if (!spell_params)
          return nil
        end
        die_result = FS3Skills.roll_ability(char, spell_params)
      end
      die_result
    end

    def self.parse_spell_params(str, defense)
      match = /^(?<spell>[^\+\-]+)\s*(?<modifier>[\+\-]\s*\d+)?$/.match(str)
      return nil if !match

      spell = KeysMagic.is_spell?(match[:spell].strip)
      modifier = match[:modifier].nil? ? 0 : match[:modifier].gsub(/\s+/, "").to_i

      #this is where we get what to roll for the spell
      spellinfo = KeysMagic.spells[spell]
      if defense
        ability = spellinfo["defense"]["ability"]
        attribute = spellinfo["defense"]["attribute"]
      else
        if spellinfo["offense"]
          attribute = spellinfo["offense"]["attribute"]
          ability = spellinfo["offense"]["ability"]
        else
          spellinfo["category"].each_with_index do |c, i|
            if spellinfo["category"].length > 1
              return
            end
            if spellinfo["attribute"]
              attribute = spellinfo["attribute"]
            else
              attribute = categories[c]["attribute"]
            end
            if spellinfo["ability"]
              ability = spellinfo["ability"]
            else
              ability = c
            end
          end
        end
      end
      return FS3Skills::RollParams.new(ability, modifier, attribute)
    end

    def self.determine_web_cast_result(request, enactor)

      if !request.args[:pc_spell].blank?
        spell_str = request.args[:pc_spell]
      elsif !request.args[:vs_roll1].blank?
        spell_str = request.args[:vs_roll1]
      elsif !request.args[:pc_target].blank?
        spell_str = request.args[:spell_opposed]
      elsif !request.args[:spell_string].blank?
        spell_str = request.args[:spell_string]
      end
      vs_roll1 = request.args[:vs_roll1] || ""
      vs_roll2 = request.args[:vs_roll2] || ""
      vs_name1 = (request.args[:vs_name1] || "").titlecase
      vs_name2 = (request.args[:vs_name2] || "").titlecase
      pc_name = request.args[:pc_name] || ""
      pc_spell = request.args[:pc_spell] || ""
      pc_target = request.args[:pc_target] || ""
      npc_rating =  request.args[:npc_rating] || ""
      if vs_roll1.is_integer?
        return { error: t('keysmagic.npcs_do_not_know_spells') }
      end
      spell = KeysMagic.is_spell?(spell_str.split(/[+-]/).first.strip)
      modifier_base = "#{spell_str.split(/([+-])/)[1]}"+"#{spell_str.split(/([+-])/)[2]}".delete(" ")
      modifier = modifier_base.nil? ? 0 : modifier_base.to_i
      spell_str = spell + modifier_base

      if !spell
        if vs_roll1
          spell_str = vs_roll1
          return
        end
        return { error: t('keysmagic.no_such_spell') }
      end

      if(!vs_roll2.blank? && !vs_roll2.is_integer?)
        return { error: t('keysmagic.npc_skill_bad_format') }
      end

      # ------------------
      # VS ROLL
      # ------------------
      if (!vs_roll1.blank?||!pc_target.blank?)
        if KeysMagic.spells[spell]['noroll']
          return { error: t('keysmagic.spell_does_not_roll', :spell => spell) }
        elsif (!KeysMagic.spells[spell]["offense"])
          return { error: t('keysmagic.spell_can_only_roll_unopposed', :spell => spell) }
        end
        caster = vs_roll1.blank? ? enactor.name : vs_name1
        result = ClassTargetFinder.find(caster, Character, enactor)
        model1 = result.target

        spell_target = vs_roll1.blank? ? pc_target : vs_name2
        result = ClassTargetFinder.find(spell_target, Character, enactor)
        model2 = result.target
        if (!model2 && !pc_target.blank? && npc_rating.blank?)
          return { error: t('keysmagic.npc_skill_bad_format') }
        end
        spell_target = model2 ? model2.name : (pc_target.blank? ? vs_name2 : pc_target)
        spell_counter = model2 ? spell_str : (npc_rating.blank? ? vs_roll2 : npc_rating)
        unless model1 && KeysMagic.has_spell?(caster,spell)
          if model1
            return { error: t('keysmagic.they_do_not_know_spell', :name => caster, :spell => spell) }
          else
            return { error: t('keysmagic.npcs_do_not_know_spells') }
          end
        end

        die_result1 = KeysMagic.parse_and_cast(model1, spell_str, false)
        die_result2 = KeysMagic.parse_and_cast(model2, spell_counter, true)

        if (!die_result1 || !die_result2)
          return { error: t('keysmagic.unknown_spell_params') }
        end

        successes1 = FS3Skills.get_success_level(die_result1)
        successes2 = FS3Skills.get_success_level(die_result2)

        until successes1 != successes2 do
          die_result1 = KeysMagic.parse_and_cast(model1, spell_str, false)
          die_result2 = KeysMagic.parse_and_cast(model2, spell_counter, true)

          if (!die_result1 || !die_result2)
            return { error: t('keysmagic.unknown_spell_params') }
          end

          successes1 = FS3Skills.get_success_level(die_result1)
          successes2 = FS3Skills.get_success_level(die_result2)

        end

        results = FS3Skills.opposed_result_title(caster, successes1, spell_target, successes2)

        message = t('keysmagic.opposed_cast_result',
           :name1 => !model1 ? t('fs3skills.npc', :name => caster) : model1.name,
           :name2 => !model2 ? t('fs3skills.npc', :name => spell_target) : model2.name,
           :spell => spell_str,
           :dice1 => FS3Skills.print_dice(die_result1),
           :dice2 => FS3Skills.print_dice(die_result2),
           :preposition => "vs",
           :result => results,
           :roller => enactor.name
            )

      # ------------------
      # PC ROLL
      # ------------------

    elsif (spell == "Key Maker")
        caster = pc_name.blank? ? enactor : Character.find_one_by_name(pc_name)
        unless KeysMagic.has_spell?(caster.name,spell)
          if caster.name == enactor.name
            return { error: t('keysmagic.you_do_not_know_spell', :spell => spell) }
          else
            return { error: t('keysmagic.they_do_not_know_spell', :name => char.name, :spell => spell) }
          end
        end
        time_roll = FS3Skills::RollParams.new("Law", modifier, "Wits")
        place_roll = FS3Skills::RollParams.new("Chaos", modifier, "Grit")
        time_result = FS3Skills.roll_ability(caster, time_roll)
        place_result = FS3Skills.roll_ability(caster, place_roll)
        time_level = FS3Skills.get_success_level(time_result)
        time_title = FS3Skills.get_success_title(time_level)
        place_level = FS3Skills.get_success_level(place_result)
        place_title = FS3Skills.get_success_title(place_level)
        message = t('keysmagic.keymaker_cast_result',
          :name => caster.name,
          :spell => spell_str,
          :time_dice => FS3Skills.print_dice(time_result),
          :place_dice => FS3Skills.print_dice(place_result),
          :time_success => time_title,
          :place_success => place_title,
          :roller => enactor.name
        )

      elsif (!pc_name.blank?)
        char = Character.find_one_by_name(pc_name)

        if (!char)
          return { error: t('keysmagic.npcs_do_not_know_spells') }
        end

        unless KeysMagic.has_spell?(char.name,spell)
          if char.name == enactor.name
            return { error: t('keysmagic.you_do_not_know_spell', :spell => spell) }
          else
            return { error: t('keysmagic.they_do_not_know_spell', :name => char.name, :spell => spell) }
          end
        end

        if KeysMagic.spells[spell]['noroll']
          return { error: t('keysmagic.spell_does_not_roll', :spell => spell) }
        elsif (KeysMagic.spells[spell]["offense"] && KeysMagic.spells[spell]["offense"]["only"])
          return { error: t('keysmagic.spell_cannot_roll_unopposed', :spell => spell) }
        end

        roll = KeysMagic.parse_and_cast(char, spell_str, false)
        roll_result = FS3Skills.get_success_level(roll)
        success_title = FS3Skills.get_success_title(roll_result)
        message = t('keysmagic.simple_cast_result',
          :name => char.name ,
          :spell => spell_str,
          :dice => FS3Skills.print_dice(roll),
          :success => success_title,
          :roller => enactor.name
          )

      # ------------------
      # SELF ROLL
      # ------------------

      else
        unless KeysMagic.has_spell?(enactor.name,spell)
          return { error: t('keysmagic.you_do_not_know_spell', :spell => spell) }
        end
        roll = KeysMagic.parse_and_cast(enactor, spell_str, false)
        roll_result = FS3Skills.get_success_level(roll)
        success_title = FS3Skills.get_success_title(roll_result)
        message = t('keysmagic.simple_cast_result',
          :name => enactor.name,
          :spell => spell_str,
          :dice => FS3Skills.print_dice(roll),
          :success => success_title,
          :roller => enactor.name
          )
      end

      return { message: message }
    end

    def self.learnableSpells(char)
      aspects = []
      slots = []
      learnable = Hash.new

      ClassTargetFinder.with_a_character(char.name, Character, char) do |model|
        spells = Hash.new
        KeysMagic.catlist.each_with_index do |cat, i|
          spells[cat] = {}
          if model.spells.nil? || model.spells.empty?
            spells[cat]["known"] = 0
            currentSpells = []
          else
            spells[cat]["known"] = model.spells[cat].nil? ? 0 : model.spells[cat].length
            currentSpells = model.spells[cat].nil? ? [] : model.spells[cat]
          end
          learnable[cat] = KeysMagic.category_spells(cat) - currentSpells
          if KeysMagic.has_spell?(char.name, 'Key Maker')
            learnable[cat] = learnable[cat] - ['Key Maker']
          end
          if FS3Skills.find_ability(model, cat)
            spells[cat]["allowed"] = KeysMagic.current_cap(model, cat)
          else
            spells[cat]["allowed"] = 0
          end
          cat_slots = spells[cat]["allowed"] - spells[cat]["known"]
          if cat_slots > 0
            aspects << cat
            slots << cat_slots
          end
        end
      end

      {
        aspects: aspects,
        slots: slots,
        learnable: learnable
      }
    end

  end
end
