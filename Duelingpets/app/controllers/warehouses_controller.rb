class WarehousesController < ApplicationController
   include WarehousesHelper

   def index
      mode "index"
   end

   def show
      mode "show"
   end

   def edit
      mode "edit"
   end

   def update
      mode "update"
   end

   def purchase
      mode "purchase"
   end

   def buypet
      mode "buypet"
   end
end
