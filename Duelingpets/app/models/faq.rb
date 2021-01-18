class Faq < ApplicationRecord
   #Faqs related
   belongs_to :user, :class_name => 'User', :foreign_key => 'user_id', optional: true
   belongs_to :staff, :class_name => 'User', :foreign_key => 'staff_id', optional: true

   #Regex for goal
   VALID_TITLE_REGEX = /\A[a-z][a-z][a-z0-9! -]+\z/i

   #Validates the faq information upon submission
   validates :goal, presence: true, format: {with: VALID_TITLE_REGEX}, uniqueness: { case_sensitive: false}
end
