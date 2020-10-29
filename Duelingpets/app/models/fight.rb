class Fight < ApplicationRecord
   #Fight related
   belongs_to :partner, optional: true
end
