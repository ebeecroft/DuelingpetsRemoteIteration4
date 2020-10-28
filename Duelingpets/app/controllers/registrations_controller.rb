class RegistrationsController < ApplicationController
   include RegistrationsHelper

   def index
      mode "index"
   end

   def create
      mode "create"
   end

   def register
      mode "register"
   end

   def verify
      mode "verify"
   end

   def approve
      mode "approve"
   end

   def deny
      mode "deny"
   end

   def gate
      mode "gate"
   end
end
