class FaqsController < ApplicationController
   include FaqsHelper

   def index
      mode "index"
   end
   
   def new
      mode "new"
   end

   def create
      mode "create"
   end

   def edit
      mode "edit"
   end

   def update
      mode "update"
   end

   def destroy
      mode "destroy"
   end

   def review
      mode "review"
   end

   def approve
      mode "approve"
   end

   def deny
      mode "deny"
   end

   def list
      mode "list"
   end

   def staffanswer
      mode "staffanswer"
   end

   def reply
      mode "reply"
   end

   def replypost
      mode "replypost"
   end
end
