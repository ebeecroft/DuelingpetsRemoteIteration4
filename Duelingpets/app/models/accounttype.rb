class Accounttype < ApplicationRecord
   #Pages that require accounttypes
   has_many :registrations, :foreign_key => "accounttype_id", :dependent => :destroy
   has_many :users, :foreign_key => "accounttype_id", :dependent => :destroy
end
