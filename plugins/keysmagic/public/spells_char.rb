module AresMUSH
  class Character
    attribute :spells, :type => DataType::Hash, :default => {}
    attribute :spellnotes, :type => DataType::Hash, :default => {}
  end
end
