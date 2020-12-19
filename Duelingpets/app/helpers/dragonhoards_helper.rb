module DragonhoardsHelper

   private
      def getHoardParams(type)
         value = ""
         if(type == "Id")
            value = params[:id]
         elsif(type == "Hoard")
            value = params.require(:dragonhoard).permit(:name, :message, :dragonimage, :remote_dragonimage_url,
            :dragonimage_cache, :ogg, :remote_ogg_url, :ogg_cache, :mp3, :remote_mp3_url, :mp3_cache,
            :basecost, :baserate)
         elsif(type == "ShelfId")
            value = params[:witemshelf][:witemshelf_id]
         elsif(type == "ItemId")
            value = params[:witemshelf][:item_id]
         elsif(type == "Page")
            value = params[:page]
         else
            raise "Invalid type detected!"
         end
         return value
      end

      def getMarketStats(item, type)
         stats = ""
         if(type == "Food")
            msg1 = content_tag(:p, "HP: #{item.hp}")
            msg2 = content_tag(:p, "Hunger: #{item.hunger}")
            msg3 = content_tag(:p, "Fun: #{item.fun}")
            stats = (msg1 + msg2 + msg3)
         elsif(type == "Drink")
            msg1 = content_tag(:p, "HP: #{item.hp}")
            msg2 = content_tag(:p, "Thirst: #{item.thirst}")
            msg3 = content_tag(:p, "Fun: #{item.fun}")
            stats = (msg1 + msg2 + msg3)
         elsif(type == "Weapon")
            msg1 = content_tag(:p, "Atk: #{item.atk}")
            msg2 = content_tag(:p, "Def: #{item.def}")
            msg3 = content_tag(:p, "Agi: #{item.agility}")
            msg4 = content_tag(:p, "Str: #{item.strength}")
            stats = (msg1 + msg2 + msg3 + msg4)
         elsif(type == "Toy")
            msg1 = content_tag(:p, "Fun: #{item.fun}")
            msg2 = content_tag(:p, "Hunger: #{item.hunger}")
            msg3 = content_tag(:p, "Thirst: #{item.thirst}")
            stats = (msg1 + msg2 + msg3)
         end
         return stats
      end

      def getEmeraldPrice(type)
         price = 0
         if(type == "Buy")
            emeraldcost = Fieldcost.find_by_name("Emeraldpoints")
            emeraldrate = Ratecost.find_by_name("Emeraldrate")
            price = (emeraldcost.amount * emeraldrate.amount).round
         elsif(type == "Create")
            hoard = Dragonhoard.find_by_id(1)
            price = (hoard.basecost * hoard.baserate).round
         else
            flash[:error] = "Invalid selection!"
            redirect_to root_path
         end
         return price
      end
      
      def storeitem(item, shelf)
         #Sets up the variables
         spacefound = false
         emptyspace = false
      
         #Determines which slot to put the item in
         if(shelf.item1_id && shelf.item1_id == item.id)
            spacefound = true
            shelf.qty1 += 1
         elsif(shelf.item2_id && shelf.item2_id == item.id)
            spacefound = true
            shelf.qty2 += 1
         elsif(shelf.item3_id && shelf.item3_id == item.id)
            spacefound = true
            shelf.qty3 += 1
         elsif(shelf.item4_id && shelf.item4_id == item.id)
            spacefound = true
            shelf.qty4 += 1
         elsif(shelf.item5_id && shelf.item5_id == item.id)
            spacefound = true
            shelf.qty5 += 1
         else
            if(shelf.item1_id.nil?)
               emptyspace = true
               shelf.item1_id = item.id
               shelf.qty1 = 1
            elsif(shelf.item2_id.nil?)
               emptyspace = true
               shelf.item2_id = item.id
               shelf.qty2 = 1
            elsif(shelf.item3_id.nil?)
               emptyspace = true
               shelf.item3_id = item.id
               shelf.qty3 = 1
            elsif(shelf.item4_id.nil?)
               emptyspace = true
               shelf.item4_id = item.id
               shelf.qty4 = 1
            elsif(shelf.item5_id.nil?)
               emptyspace = true
               shelf.item5_id = item.id
               shelf.qty5 = 1
            end
         end

         #Checks the additional itemslots
         if(!spacefound)
            if(shelf.item6_id && shelf.item6_id == item.id)
            spacefound = true
            shelf.qty6 += 1
            elsif(shelf.item7_id && shelf.item7_id == item.id)
               spacefound = true
               shelf.qty7 += 1
            elsif(shelf.item8_id && shelf.item8_id == item.id)
               spacefound = true
               shelf.qty8 += 1
            elsif(shelf.item9_id && shelf.item9_id == item.id)
               spacefound = true
               shelf.qty9 += 1
            elsif(shelf.item10_id && shelf.item10_id == item.id)
               spacefound = true
               shelf.qty10 += 1
            else
               if(!emptyspace)
                  if(shelf.item6_id.nil?)
                     emptyspace = true
                     shelf.item6_id = item.id
                     shelf.qty6 = 1
                  elsif(shelf.item7_id.nil?)
                     emptyspace = true
                     shelf.item7_id = item.id
                     shelf.qty7 = 1
                  elsif(shelf.item8_id.nil?)
                     emptyspace = true
                     shelf.item8_id = item.id
                     shelf.qty8 = 1
                  elsif(shelf.item9_id.nil?)
                     emptyspace = true
                     shelf.item9_id = item.id
                     shelf.qty9 = 1
                  elsif(shelf.item10_id.nil?)
                     emptyspace = true
                     shelf.item10_id = item.id
                     shelf.qty10 = 1
                  end
               end
            end
         end

         #Checks the additional itemslots
         if(!spacefound)
            if(shelf.item11_id && shelf.item11_id == item.id)
            spacefound = true
            shelf.qty11 += 1
            elsif(shelf.item12_id && shelf.item12_id == item.id)
               spacefound = true
               shelf.qty12 += 1
            elsif(shelf.item13_id && shelf.item13_id == item.id)
               spacefound = true
               shelf.qty13 += 1
            elsif(shelf.item14_id && shelf.item14_id == item.id)
               spacefound = true
               shelf.qty14 += 1
            elsif(shelf.item15_id && shelf.item15_id == item.id)
               spacefound = true
               shelf.qty15 += 1
            else
               if(!emptyspace)
                  if(shelf.item11_id.nil?)
                     emptyspace = true
                     shelf.item11_id = item.id
                     shelf.qty11 = 1
                  elsif(shelf.item12_id.nil?)
                     emptyspace = true
                     shelf.item12_id = item.id
                     shelf.qty12 = 1
                  elsif(shelf.item13_id.nil?)
                     emptyspace = true
                     shelf.item13_id = item.id
                     shelf.qty13 = 1
                  elsif(shelf.item14_id.nil?)
                     emptyspace = true
                     shelf.item14_id = item.id
                     shelf.qty14 = 1
                  elsif(shelf.item15_id.nil?)
                     emptyspace = true
                     shelf.item15_id = item.id
                     shelf.qty15 = 1
                  end
               end
            end
         end

         #Checks the additional itemslots
         if(!spacefound)
            if(shelf.item16_id && shelf.item16_id == item.id)
            spacefound = true
            shelf.qty16 += 1
            elsif(shelf.item17_id && shelf.item17_id == item.id)
               spacefound = true
               shelf.qty17 += 1
            elsif(shelf.item18_id && shelf.item18_id == item.id)
               spacefound = true
               shelf.qty18 += 1
            elsif(shelf.item19_id && shelf.item19_id == item.id)
               spacefound = true
               shelf.qty19 += 1
            elsif(shelf.item20_id && shelf.item20_id == item.id)
               spacefound = true
               shelf.qty20 += 1
            else
               if(!emptyspace)
                  if(shelf.item16_id.nil?)
                     emptyspace = true
                     shelf.item16_id = item.id
                     shelf.qty16 = 1
                  elsif(shelf.item17_id.nil?)
                     emptyspace = true
                     shelf.item17_id = item.id
                     shelf.qty17 = 1
                  elsif(shelf.item18_id.nil?)
                     emptyspace = true
                     shelf.item18_id = item.id
                     shelf.qty18 = 1
                  elsif(shelf.item19_id.nil?)
                     emptyspace = true
                     shelf.item19_id = item.id
                     shelf.qty19 = 1
                  elsif(shelf.item20_id.nil?)
                     emptyspace = true
                     shelf.item20_id = item.id
                     shelf.qty20 = 1
                  end
               end
            end
         end

         #Checks the additional itemslots
         if(!spacefound)
            if(shelf.item21_id && shelf.item21_id == item.id)
            spacefound = true
            shelf.qty21 += 1
            elsif(shelf.item22_id && shelf.item22_id == item.id)
               spacefound = true
               shelf.qty22 += 1
            elsif(shelf.item23_id && shelf.item23_id == item.id)
               spacefound = true
               shelf.qty23 += 1
            elsif(shelf.item24_id && shelf.item24_id == item.id)
               spacefound = true
               shelf.qty24 += 1
            elsif(shelf.item25_id && shelf.item25_id == item.id)
               spacefound = true
               shelf.qty25 += 1
            else
               if(!emptyspace)
                  if(shelf.item21_id.nil?)
                     emptyspace = true
                     shelf.item21_id = item.id
                     shelf.qty21 = 1
                  elsif(shelf.item22_id.nil?)
                     emptyspace = true
                     shelf.item22_id = item.id
                     shelf.qty22 = 1
                  elsif(shelf.item23_id.nil?)
                     emptyspace = true
                     shelf.item23_id = item.id
                     shelf.qty23 = 1
                  elsif(shelf.item24_id.nil?)
                     emptyspace = true
                     shelf.item24_id = item.id
                     shelf.qty24 = 1
                  elsif(shelf.item25_id.nil?)
                     emptyspace = true
                     shelf.item25_id = item.id
                     shelf.qty25 = 1
                  end
               end
            end
         end

         #Checks the additional itemslots
         if(!spacefound)
            if(shelf.item26_id && shelf.item26_id == item.id)
            spacefound = true
            shelf.qty26 += 1
            elsif(shelf.item27_id && shelf.item27_id == item.id)
               spacefound = true
               shelf.qty27 += 1
            elsif(shelf.item28_id && shelf.item28_id == item.id)
               spacefound = true
               shelf.qty28 += 1
            elsif(shelf.item29_id && shelf.item29_id == item.id)
               spacefound = true
               shelf.qty29 += 1
            elsif(shelf.item30_id && shelf.item30_id == item.id)
               spacefound = true
               shelf.qty30 += 1
            else
               if(!emptyspace)
                  if(shelf.item26_id.nil?)
                     emptyspace = true
                     shelf.item26_id = item.id
                     shelf.qty26 = 1
                  elsif(shelf.item27_id.nil?)
                     emptyspace = true
                     shelf.item27_id = item.id
                     shelf.qty27 = 1
                  elsif(shelf.item28_id.nil?)
                     emptyspace = true
                     shelf.item28_id = item.id
                     shelf.qty28 = 1
                  elsif(shelf.item29_id.nil?)
                     emptyspace = true
                     shelf.item29_id = item.id
                     shelf.qty29 = 1
                  elsif(shelf.item30_id.nil?)
                     emptyspace = true
                     shelf.item30_id = item.id
                     shelf.qty30 = 1
                  end
               end
            end
         end
         
         #Checks to see if there is room for the item
         roomspace = false
         if(spacefound || emptyspace)
            roomspace = true
         end
         return roomspace
      end

      def indexCommons
         hoard = Dragonhoard.find_by_id(1)
         @dragonhoard = hoard
         fieldcosts = hoard.fieldcosts
         @fieldcosts = Kaminari.paginate_array(fieldcosts).page(getHoardParams("Page")).per(10)
         ratecosts = hoard.ratecosts
         @ratecosts = Kaminari.paginate_array(ratecosts).page(getHoardParams("Page")).per(10)
         dreyores = hoard.dreyores
         @dreyores = Kaminari.paginate_array(dreyores).page(getHoardParams("Page")).per(10)
      end

      def mode(type)
         if(timeExpired)
            logout_user
            redirect_to root_path
         else
            logoutExpiredUsers
            if(type == "index")
               removeTransactions
               if(current_user && current_user.pouch.privilege == "Admin")
                  indexCommons
               else
                  allMode = Maintenancemode.find_by_id(1)
                  if(allMode.maintenance_on)
                     if(allMode.maintenance_on)
                        render "/start/maintenance"
                     end
                  else
                     indexCommons
                  end
               end
            elsif(type == "edit" || type == "update")
               hoardFound = Dragonhoard.find_by_id(getHoardParams("Id"))
               if(hoardFound)
                  logged_in = current_user
                  if(logged_in && logged_in.pouch.privilege == "Glitchy")
                     hoardFound.updated_on = currentTime
                     @dragonhoard = hoardFound
                     if(type == "update")
                        if(@dragonhoard.update_attributes(getHoardParams("Hoard")))
                           flash[:success] = "Dragon hoard #{@dragonhoard.name} was successfully updated."
                           redirect_to dragonhoards_path
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
            elsif(type == "withdraw" || type == "convertpoints")
               hoard = Dragonhoard.find_by_id(1)
               if(hoard)
                  logged_in = current_user
                  if(logged_in && logged_in.pouch.privilege == "Glitchy")
                     if(type == "withdraw")
                        if(hoard.profit > 0)
                           #Add points to the treasury
                           hoard.treasury += hoard.profit
                           flash[:success] = "#{hoard.profit} points have been added to the treasury!"
                           hoard.profit = 0
                           @dragonhoard = hoard
                           @dragonhoard.save
                        else
                           flash[:error] = "No points are stored in profit!"
                        end
                     else
                        price = hoard.treasury - hoard.basecost
                        if(price > -1)
                           #Add econ here later
                           fieldcostFound = Fieldcost.find_by_name("Contestinc")
                           hoard.contestpoints += fieldcostFound.amount
                           hoard.treasury = price
                           flash[:success] = "Treasury points converted successfully to contestpoints!"
                           @dragonhoard = hoard
                           @dragonhoard.save
                        else
                           flash[:error] = "Treasury doesn't have enough points for conversion!"
                        end
                     end
                     redirect_to dragonhoards_path
                  else
                     redirect_to root_path
                  end
               else
                  redirect_to root_path
               end
            elsif(type == "createemeralds" || type == "buyemeralds")
               hoard = Dragonhoard.find_by_id(1)
               logged_in = current_user
               if(hoard && logged_in)
                  if(type == "createemeralds")
                     if(logged_in.pouch.privilege == "Glitchy")
                        price = (hoard.basecost * hoard.baserate).round
                        if(hoard.treasury - price > -1)
                           #Add an econ later
                           hoard.emeralds += 1
                           hoard.treasury -= price
                           @dragonhoard = hoard
                           @dragonhoard.save
                           flash[:success] = "A new emerald was added to the dragonhoard!"
                        else
                           flash[:error] = "Treasury doesn't have enough points to create emeralds!"
                        end
                        redirect_to dragonhoards_path
                     else
                        redirect_to root_path
                     end
                  else
                     emeraldcost = Fieldcost.find_by_name("Emeraldpoints")
                     emeraldrate = Ratecost.find_by_name("Emeraldrate")
                     price = (emeraldcost.amount * emeraldrate.amount).round
                     if(hoard.emeralds > 0)
                        if(logged_in.pouch.amount - price > -1)
                           #Add an econ later
                           logged_in.pouch.amount -= price
                           logged_in.pouch.emeraldamount += 1
                           hoard.emeralds -= 1
                           profit = (price * 0.60).round
                           hoard.profit += profit
                           @pouch = logged_in.pouch
                           @pouch.save
                           @dragonhoard = hoard
                           @dragonhoard.save
                           flash[:success] = "#{logged_in.vname} bought an emerald!"
                        else
                           flash[:error] = "#{logged_in.vname} can't afford to purchase an emerald!"
                        end
                     else
                        flash[:error] = "The dragonhoard has no emeralds!"
                     end
                     redirect_to dragonhoards_path
                  end
               else
                  redirect_to root_path
               end
            elsif(type == "transfer") #Eventually may need to have a method to pull warehouse points here
               hoard = Dragonhoard.find_by_id(1)
               logged_in = current_user
               if(hoard && (logged_in && logged_in.pouch.privilege == "Glitchy"))
                  if(hoard.contestpoints > 0)
                     points = hoard.contestpoints
                     logged_in.pouch.amount += points
                     hoard.contestpoints = 0
                     flash[:success] = "#{points} contestpoints were transfered to Glitchy!"
                     @pouch = logged_in.pouch
                     @pouch.save
                  else
                     flash[:error] = "There are no contestpoints to transfer!"
                  end
                  @dragonhoard = hoard
                  @dragonhoard.save
                  redirect_to dragonhoards_path
               else
                  redirect_to root_path
               end
            elsif(type == "itemmarket")
               logged_in = current_user
               if(logged_in && logged_in.pouch.privilege == "Glitchy")
                  allItems = Item.order("reviewed_on desc, created_on desc")
                  itemsReviewed = allItems.select{|item| item.reviewed}
                  allShelves = Witemshelf.all
                  @slots = allShelves
                  @items = Kaminari.paginate_array(itemsReviewed).page(getHoardParams("Page")).per(30)
               else
                  redirect_to root_path
               end
            elsif(type == "buyitem")
               logged_in = current_user
               hoard = Dragonhoard.find_by_id(1)
               shelfFound = Witemshelf.find_by_id(getHoardParams("ShelfId"))
               itemFound = Item.find_by_id(getHoardParams("ItemId"))
               validPurchase = (shelfFound && itemFound)
               if(logged_in && validPurchase && logged_in.pouch.privilege == "Glitchy")
                  buyable = ((hoard.treasury - itemFound.cost >= 0) && (hoard.emeralds - itemFound.emeraldcost >= 0))
                  room = storeitem(itemFound, shelfFound)
                  if(room && buyable)
                     #Buys item
                     hoard.treasury -= itemFound.cost
                     hoard.emeralds -= itemFound.emeraldcost
                     @dragonhoard = hoard
                     @dragonhoard.save
                     @witemshelf = shelfFound
                     @witemshelf.save
                     
                     #Pays the owner of the item
                     owner = Pouch.find_by_user_id(itemFound.user_id)
                     points = (itemFound.cost * 0.40).round
                     owner.amount += points
                     @owner = owner
                     @owner.save
                     flash[:success] = "Item #{itemFound.name} was added to the warehouse!"
                     redirect_to warehouse_path(@witemshelf.warehouse.name)
                  else
                     if(!room)
                        flash[:error] = "No room to store the item #{itemFound.name}!"
                     else
                        flash[:error] = "Insufficient funds to purchase the item #{itemFound.name}!"
                     end
                     redirect_to dragonhoards_path
                  end
               else
                  redirect_to root_path
               end
            end
         end
      end
end
