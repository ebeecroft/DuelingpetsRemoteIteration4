module ColorschemesHelper

   private
      def getColorParams(type)
         value = ""
         if(type == "User")
            value = params[:user_id]
         elsif(type == "ColorId")
            value = params[:color_id]
         elsif(type == "Colorscheme")
            #Remove activate from edit eventually
            value = params.require(:colorscheme).permit(:name, :description, :nightcolor, :backgroundcolor, 
            :headercolor, :subheader1color, :subheader2color, :subheader3color, :textcolor,
            :editbuttoncolor, :editbuttonbackgcolor,
            :destroybuttoncolor, :destroybuttonbackgcolor, :submitbuttoncolor, :submitbuttonbackgcolor,
            :navigationcolor, :navigationlinkcolor, :navigationhovercolor, :navigationhoverbackgcolor,
            :onlinestatuscolor, :profilecolor, :profilehovercolor,
            :profilehoverbackgcolor, :sessioncolor, :navlinkcolor, :navlinkhovercolor,
            :navlinkhoverbackgcolor, :explanationborder, :explanationbackgcolor, :explanheadercolor,
            :explantextcolor, :errorfieldcolor, :errorcolor, :warningcolor, :notificationcolor,
            :successcolor)
         elsif(type == "Page")
            value = params[:page]
         else
            raise "Invalid type detected!"
         end
         return value
      end

      #Is back button necessary?
      def backButton
         somevalue = params[:user_id]
         if(somevalue)
            userFound = User.find_by_vname(params[:user_id])
            if(userFound)
               user_path(userFound)
            else
               raise "Invalid user!"
            end
         else
            root_path
         end
      end

      def displayColorOwner
         value = "Colorscheme List"
         somevalue = params[:user_id]
         if(somevalue)
            userFound = User.find_by_vname(params[:user_id])
            if(userFound)
               value = (userFound.vname + "'s colorschemes")
            else
               raise "I am not found even though: #{somevalue}"
            end
         end
         return value
      end

      def indexCommons
         allColors = Colorscheme.order("created_on desc")
         if(getColorParams("User"))
            userFound = User.find_by_vname(getColorParams("User"))
            if(userFound)
               allColors = userFound.colorschemes.order("created_on desc")
               @user = userFound
            else
               render "webcontrols/crazybat"
            end
         end
         activatedColors = allColors.select{|colorscheme| colorscheme.activated || (current_user && (colorscheme.user_id == current_user.id))}
         @colorschemes = Kaminari.paginate_array(activatedColors).page(getColorParams("Page")).per(10)
      end

      def editCommons(type)
         colorschemeFound = Colorscheme.find_by_id(params[:id])
         if(colorschemeFound)
            logged_in = current_user
            if(logged_in && ((logged_in.id == colorschemeFound.user_id) || logged_in.pouch.privilege == "Admin"))
               @user = User.find_by_vname(colorschemeFound.user.vname)
               if(type == "edit" || type == "update")
                  colorschemeFound.updated_on = currentTime
               end
               @colorscheme = colorschemeFound
               if(type == "update")
                  if(@colorscheme.update_attributes(getColorParams("Colorscheme")))
                     flash[:success] = "#{@colorscheme.name} was successfully updated."
                     if(logged_in.pouch.privilege == "Admin")
                        redirect_to colorschemes_list_path
                     else
                        redirect_to user_colorschemes_path(colorschemeFound.user)
                     end
                  else
                     render "edit"
                  end
               elsif(type == "destroy")
                  if(!colorschemeFound.democolor && colorschemeFound.id != 1)
                     flash[:success] = "#{@colorscheme.name} was successfully removed."
                     allInfos = Userinfo.all
                     infosToChange = allInfos.select{|userinfo| userinfo.colorscheme_id == @colorscheme.id}
                     infosToChange.each do |userinfo|
                        userinfo.colorscheme_id = 1
                        @userinfo = userinfo
                        @userinfo.save
                     end
                     hoard = Dragonhoard.find_by_id(1)
                     colorcost = Fieldcost.find_by_name("Colorschemecleanup")
                     cleanupcost = colorcost.amount

                     pouchFound = Pouch.find_by_user_id(logged_in.id)
                     if(logged_in.pouch.privilege == "Admin" || (cleanupcost <= pouchFound.amount))
                        if(logged_in.pouch.privilege != "Admin")
                           pouchFound.amount -= cleanupcost
                           @pouch = pouchFound
                           @pouch.save
                        end
                        @colorscheme.destroy
                        if(logged_in.pouch.privilege == "Admin")
                           redirect_to colorschemes_list_path
                        else
                           redirect_to user_colorschemes_path(colorschemeFound.user)
                        end
                     else
                        flash[:error] = "You do not have enough points to delete this color!"
                        redirect_to root_path
                     end
                  else
                     flash[:error] = "You can't delete a mandatory color!"
                     redirect_to root_path
                  end
               end
            else
               redirect_to root_path
            end
         else
            render "webcontrols/crazybat"
         end
      end

      def undoCommons
         logged_in = current_user
         if(logged_in)
            logged_in.userinfo.daycolor_id = 1
            logged_in.userinfo.nightcolor_id = 2
            @userinfo = logged_in.userinfo
            @userinfo.save
            flash[:success] = "#{logged_in.vname}'s color was set back to the default!"
            redirect_to user_path(logged_in)
         else
            redirect_to root_path
         end
      end

      def activateCommons
         logged_in = current_user
         colorFound = Colorscheme.find_by_id(getColorParams("ColorId"))
         if(logged_in && colorFound && (logged_in.pouch.privilege == "Admin" || logged_in.id == colorFound.user_id))
            if(colorFound.activated)
               colorFound.activated = false
            else
               colorFound.activated = true
            end
            @colorFound = colorFound
            @colorFound.save
            if(logged_in.pouch.privilege == "Admin")
               redirect_to colorschemes_list_path
            else
               redirect_to colorschemes_path
            end
         else
            redirect_to root_path
         end
      end

      def mode(type)
         if(timeExpired)
            logout_user
            logoutExpiredUsers
            redirect_to root_path
         else
            if(type == "index")
               removeTransactions
               allMode = Maintenancemode.find_by_id(1)
               userMode = Maintenancemode.find_by_id(6)
               if(allMode.maintenance_on || userMode.maintenance_on)
                  if(current_user && current_user.pouch.privilege == "Admin")
                     indexCommons
                  else
                     if(allMode.maintenance_on)
                        render "/start/maintenance"
                     else
                        render "/users/maintenance"
                     end
                  end
               else
                  indexCommons
               end
            elsif(type == "new" || type == "create")
               allMode = Maintenancemode.find_by_id(1)
               userMode = Maintenancemode.find_by_id(6)
               if(allMode.maintenance_on || userMode.maintenance_on)
                  if(allMode.maintenance_on)
                     render "/start/maintenance"
                  else
                     render "/users/maintenance"
                  end
               else
                  logged_in = current_user
                  userFound = User.find_by_vname(params[:user_id])
                  if((logged_in && userFound) && (userFound.id == logged_in.id))
                     newColorscheme = logged_in.colorschemes.new
                     if(type == "create")
                        newColorscheme = logged_in.colorschemes.new(getColorParams("Colorscheme"))
                        newColorscheme.created_on = currentTime
                     end
                     @user = userFound
                     @colorscheme = newColorscheme
                     if(type == "create")
                        if(@colorscheme.save)
                           #Adds points to the users pouch
                           colors = Fieldcost.find_by_name("Colorscheme")
                           pointsForColors = colors.amount
                           pouchFound = Pouch.find_by_user_id(logged_in.id)
                           pouchFound.amount += pointsForColors

                           #Adds the colorscheme points to the economy
                           newTransaction = Economy.new(params[:economy])
                           newTransaction.econtype = "Content"
                           newTransaction.content_type = "Colorscheme"
                           newTransaction.name = "Source"
                           newTransaction.amount = pointsForColors
                           newTransaction.user_id = userFound.id
                           newTransaction.created_on = currentTime
                           @economytransaction = newTransaction
                           @economytransaction.save

                           ContentMailer.content_created(@colorscheme, "Colorscheme", pointsForColors).deliver_later(wait: 5.minutes)
                           @pouch = pouchFound
                           @pouch.save
                           flash[:success] = "#{@colorscheme.name} was successfully created."
                           redirect_to colorschemes_url
                        else
                           render "new"
                        end
                     end
                  else
                     redirect_to root_path
                  end
               end
            elsif(type == "edit" || type == "update" || type == "destroy")
               allMode = Maintenancemode.find_by_id(1)
               userMode = Maintenancemode.find_by_id(6)
               if(allMode.maintenance_on || userMode.maintenance_on)
                  if(current_user && current_user.pouch.privilege == "Admin")
                     editCommons(type)
                  else
                     if(allMode.maintenance_on)
                        render "/start/maintenance"
                     else
                        render "/users/maintenance"
                     end
                  end
               else
                  editCommons(type)
               end
            elsif(type == "list")
               logged_in = current_user
               if(logged_in && logged_in.pouch.privilege == "Admin")
                  removeTransactions
                  allColors = Colorscheme.order("created_on desc")
                  @colorschemes = Kaminari.paginate_array(allColors).page(getColorParams("Page")).per(10)
               else
                  redirect_to root_path
               end
            elsif(type == "undo")
               allMode = Maintenancemode.find_by_id(1)
               userMode = Maintenancemode.find_by_id(6)
               if(allMode.maintenance_on || userMode.maintenance_on)
                  if(current_user && current_user.pouch.privilege == "Admin")
                     undoCommons
                  else
                     if(allMode.maintenance_on)
                        render "/start/maintenance"
                     else
                        render "/users/maintenance"
                     end
                  end
               else
                  undoCommons
               end
            elsif(type == "activatecolor")
               allMode = Maintenancemode.find_by_id(1)
               userMode = Maintenancemode.find_by_id(6)
               if(allMode.maintenance_on || userMode.maintenance_on)
                  if(current_user && current_user.pouch.privilege == "Admin")
                     activateCommons
                  else
                     if(allMode.maintenance_on)
                        render "/start/maintenance"
                     else
                        render "/users/maintenance"
                     end
                  end
               else
                  activateCommons
               end
            end
         end
      end
end
