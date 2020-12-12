module WarehousesHelper

   private
      def getWarehouseParams(type)
         value = ""
         if(type == "Id")
            value = params[:id]
         elsif(type == "Warehouse")
            value = params.require(:warehouse).permit(:name, :message, :store_open)
         elsif(type == "Page")
            value = params[:page]
         else
            raise "Invalid type detected!"
         end
         return value
      end
      
      def showCommons(type)
         warehouseFound = Warehouse.find_by_name(getWarehouseParams("Id"))
         logged_in = current_user
         if(warehouseFound && logged_in)
            removeTransactions
            @warehouse = warehouseFound
         else
            redirect_to root_path
         end
      end

      def mode(type)
         if(timeExpired)
            logout_user
            redirect_to root_path
         else
            logoutExpiredUsers
            if(type == "index")
               removeTransactions
               if(current_user && current_user.pouch.privilege == "Glitchy")
                  allWarehouses = Warehouse.order("updated_on desc, created_on desc")
                  @warehouses = Kaminari.paginate_array(allWarehouses).page(getWarehouseParams("Page")).per(10)
               else
                  redirect_to root_path
               end
            elsif(type == "edit" || type == "update")
               warehouseFound = Warehouse.find_by_name(getWarehouseParams("Id"))
               if(warehouseFound)
                  logged_in = current_user
                  if(logged_in && logged_in.pouch.privilege == "Glitchy")
                     warehouseFound.updated_on = currentTime
                     @warehouse = warehouseFound
                     if(type == "update")
                        if(@warehouse.update_attributes(getWarehouseParams("Warehouse")))
                           flash[:success] = "Warehouse #{@warehouse.name} was successfully updated."
                           redirect_to warehouse_path(@warehouse)
                        else
                           render "edit"
                        end
                     end
                  else
                     redirect_to root_path
                  end
               else
                  redirect_to root_path
               end
            elsif(type == "show")
               allMode = Maintenancemode.find_by_id(1)
               userMode = Maintenancemode.find_by_id(6)
               if(allMode.maintenance_on || userMode.maintenance_on)
                  if(current_user && current_user.pouch.privilege == "Glitchy")
                     showCommons(type)
                  else
                     if(allMode.maintenance_on)
                        render "/start/maintenance"
                     else
                        render "/users/maintenance"
                     end
                  end
               else
                  showCommons(type)
               end
            end
         end
      end
end
