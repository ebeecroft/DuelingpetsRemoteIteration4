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
         elsif(type == "Page")
            value = params[:page]
         else
            raise "Invalid type detected!"
         end
         return value
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
            elsif(type == "donate" || type == "donatepost")
               hoard = Dragonhoard.find_by_id(1)
               logged_in = current_user
               if(hoard && logged_in)
                  if(type == "donatepost")
                     amount = (params[:session][:amount]).to_i
                     if(!amount.nil? && amount > 0)
                        if(logged_in.pouch.amount - amount >= 0)
                           logged_in.pouch.amount -= amount
                           hoard.vacationpoints += amount
                           @pouch = logged_in.pouch
                           @pouch.save
                           @hoard = hoard
                           @hoard.save
                           flash[:success] = "You donated #{amount} points to the central bank!"
                           redirect_to dragonhoards_path
                        else
                           flash[:error]  = "You don't have that many points!"
                           redirect_to root_path
                        end
                     else
                        flash[:error] = "Invalid data detected!"
                        redirect_to root_path
                     end
                  end
               else
                  redirect_to root_path
               end
            elsif(type == "vacationmode" || type == "getvacationpoints" || type == "transfer")
               hoard = Dragonhoard.find_by_id(1)
               logged_in = current_user
               if(hoard && (logged_in && logged_in.pouch.privilege == "Glitchy"))
                  if(type == "vacationmode")
                     if(hoard.denholiday)
                        #Will be removed in iteration 3
                        hoard.denholiday = false
                        flash[:success] = "Glitchy has now returned from his vacation!"
                     else
                        hoard.denholiday = true
                        flash[:success] = "Glitchy is now on vacation!"
                     end
                  else
                     if(!hoard.denholiday)
                        if(type == "getvacationpoints")
                           if(hoard.vacationpoints > 0)
                              tax = (hoard.vacationpoints * 0.20).round
                              points = hoard.vacationpoints - tax
                              hoard.treasury += points
                              hoard.vacationpoints = 0
                              flash[:success] = "#{points} vacationpoints were added to the treasury!"
                           else
                              flash[:error] = "There are no vacationpoints to add!"
                           end
                        else
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
                        end
                     end
                  end
                  @dragonhoard = hoard
                  @dragonhoard.save
                  redirect_to dragonhoards_path
               else
                  redirect_to root_path
               end
            end
         end
      end
end
