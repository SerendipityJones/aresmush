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
      Global.logger.info "#{ability_name}"
      bonus = FS3Skills.find_ability(char, ability_name)
      bonus = bonus.nil? ? 0 : bonus.rating
      Global.logger.info "#{bonus}"
      spellcap = spellcap + bonus
      return spellcap
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


  end
end
