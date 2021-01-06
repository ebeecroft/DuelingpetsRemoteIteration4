module ElementsHelper

   private
      def getElementParams(type)
         value = ""
         if(type == "Id")
            value = params[:id]
         elsif(type == "ElementId")
            value = params[:element_id]
         elsif(type == "User")
            value = params[:user_id]
         elsif(type == "Element")
            value = params.require(:element).permit(:name, :description, :itemart, :remote_itemart_url, :itemart_cache)
         elsif(type == "Page")
            value = params[:page]
         else
            raise "Invalid type detected!"
         end
         return value
      end

      def indexCommons
         if(optional)
            userFound = User.find_by_vname(optional)
            if(userFound)
               userElements = userFound.elements.order("reviewed_on desc, created_on desc")
               elementsReviewed = userElements.select{|element| (current_user && element.user_id == current_user.id) || element.reviewed}
               @user = userFound
            else
               render "webcontrols/missingpage"
            end
         else
            allElements = Element.order("reviewed_on desc, created_on desc")
            elementsReviewed = allElements.select{|element| (current_user && element.user_id == current_user.id) || element.reviewed}
         end
         @elements = Kaminari.paginate_array(elementsReviewed).page(getElementParams("Page")).per(10)
      end

      def optional
         value = getElementParams("User")
         return value
      end

      def editCommons(type)
         elementFound = Element.find_by_name(getElementParams("Id"))
         if(elementFound)
            logged_in = current_user
            if(logged_in && ((logged_in.id == elementFound.user_id) || logged_in.pouch.privilege == "Admin"))
               elementFound.updated_on = currentTime
               elementFound.reviewed = false
               @element = elementFound
               @user = User.find_by_vname(elementFound.user.vname)
               if(type == "update")
                  #Update element stats should only happen if not reviewed
                  if(@element.update_attributes(getElementParams("Element")))
                     flash[:success] = "Element #{@element.name} was successfully updated."
                     redirect_to user_element_path(@element.user, @element)
                  else
                     render "edit"
                  end
               end
            else
               redirect_to root_path
            end
         else
            render "webcontrols/missingpage"
         end
      end

      def showCommons(type)
         elementFound = Element.find_by_name(getElementParams("Id"))
         if(elementFound)
            removeTransactions
            if(elementFound.reviewed || current_user && ((elementFound.user_id == current_user.id) || current_user.pouch.privilege == "Admin"))
               #visitTimer(type, blogFound)
               #cleanupOldVisits
               @element = elementFound
               if(type == "destroy")
                  logged_in = current_user
                  if(logged_in && ((logged_in.id == elementFound.user_id) || logged_in.pouch.privilege == "Admin"))
                     #Eventually consider adding a sink to this
                     @element.destroy
                     flash[:success] = "#{@element.name} was successfully removed."
                     if(logged_in.pouch.privilege == "Admin")
                        redirect_to elements_list_path
                     else
                        redirect_to user_elements_path(elementFound.user)
                     end
                  else
                     redirect_to root_path
                  end
               end
            else
               redirect_to root_path
            end
         else
            render "webcontrols/missingpage"
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
               allMode = Maintenancemode.find_by_id(1)
               elementMode = Maintenancemode.find_by_id(10)
               if(allMode.maintenance_on || elementMode.maintenance_on)
                  if(current_user && current_user.pouch.privilege == "Admin")
                     indexCommons
                  else
                     if(allMode.maintenance_on)
                        render "/start/maintenance"
                     else
                        render "/elements/maintenance"
                     end
                  end
               else
                  indexCommons
               end
            elsif(type == "new" || type == "create")
               allMode = Maintenancemode.find_by_id(1)
               elementMode = Maintenancemode.find_by_id(10)
               if(allMode.maintenance_on || elementMode.maintenance_on)
                  if(allMode.maintenance_on)
                     render "/start/maintenance"
                  else
                     render "/elements/maintenance"
                  end
               else
                  logged_in = current_user
                  userFound = User.find_by_vname(getElementParams("User"))
                  if(logged_in && userFound)
                     if(logged_in.id == userFound.id)
                        newElement = logged_in.elements.new
                        if(type == "create")
                           newElement = logged_in.elements.new(getElementParams("Element"))
                           newElement.created_on = currentTime
                           newElement.updated_on = currentTime
                        end
                        @element = newElement
                        @user = userFound
                        if(type == "create")
                           if(@element.save)
                              #url = "http://www.duelingpets.net/elements/review"
                              #ContentMailer.content_review(@creature, "Creature", url).deliver_now
                              flash[:success] = "#{@element.name} was successfully created."
                              redirect_to user_element_path(@user, @element)
                           else
                              render "new"
                           end
                        end
                     else
                        redirect_to root_path
                     end
                  else
                     redirect_to root_path
                  end
               end
            elsif(type == "edit" || type == "update")
               if(current_user && current_user.pouch.privilege == "Admin")
                  editCommons(type)
               else
                  allMode = Maintenancemode.find_by_id(1)
                  elementMode = Maintenancemode.find_by_id(10)
                  if(allMode.maintenance_on || elementMode.maintenance_on)
                     if(allMode.maintenance_on)
                        render "/start/maintenance"
                     else
                        render "/elements/maintenance"
                     end
                  else
                     editCommons(type)
                  end
               end
            elsif(type == "show" || type == "destroy")
               allMode = Maintenancemode.find_by_id(1)
               elementMode = Maintenancemode.find_by_id(10)
               if(allMode.maintenance_on || elementMode.maintenance_on)
                  if(current_user && current_user.pouch.privilege == "Admin")
                     showCommons(type)
                  else
                     if(allMode.maintenance_on)
                        render "/start/maintenance"
                     else
                        render "/elements/maintenance"
                     end
                  end
               else
                  showCommons(type)
               end
            elsif(type == "list" || type == "review")
               logged_in = current_user
               if(logged_in)
                  removeTransactions
                  allElements = Element.order("reviewed_on desc, created_on desc")
                  if(type == "review")
                     if(logged_in.pouch.privilege == "Admin" || ((logged_in.pouch.privilege == "Keymaster") || (logged_in.pouch.privilege == "Reviewer")))
                        elementsToReview = allElements.select{|element| !element.reviewed}
                        @elements = Kaminari.paginate_array(elementsToReview).page(getElementParams("Page")).per(10)
                     else
                        redirect_to root_path
                     end
                  else
                     if(logged_in.pouch.privilege == "Admin")
                        @elements = allElements.page(getElementParams("Page")).per(10)
                     else
                        redirect_to root_path
                     end
                  end
               else
                  redirect_to root_path
               end
            elsif(type == "approve" || type == "deny")
               logged_in = current_user
               if(logged_in)
                  elementFound = Element.find_by_id(getElementParams("ElementId"))
                  if(elementFound)
                     pouchFound = Pouch.find_by_user_id(logged_in.id)
                     if((logged_in.pouch.privilege == "Admin") || ((pouchFound.privilege == "Keymaster") || (pouchFound.privilege == "Reviewer")))
                        if(type == "approve")
                           #Might revise this section later
                           elementFound.reviewed = true
                           elementFound.reviewed_on = currentTime
                           #basecost = creatureFound.creaturetype.basecost
                           #creaturecost = Fieldcost.find_by_name("Creature")
                           #petcost = (creatureFound.cost * 0.10).round
                           #price = (basecost + creaturecost.amount + petcost)
                           #pouch = Pouch.find_by_user_id(creatureFound.user_id)
                           #Add dreyterrium cost later
                           #if(pouch.amount - price >= 0)
                              @creature = creatureFound
                              @creature.save
                              #pouch.amount -= price
                              #@pouch = pouch
                              #@pouch.save

                              #Adds the creature points to the economy
                              #newTransaction = Economy.new(params[:economy])
                              #newTransaction.econtype = "Content"
                              #newTransaction.content_type = "Creature"
                              #newTransaction.name = "Sink"
                              #newTransaction.amount = price
                              #newTransaction.user_id = creatureFound.user_id
                              #newTransaction.created_on = currentTime
                              #@economytransaction = newTransaction
                              #@economytransaction.save
                              #ContentMailer.content_approved(@element, "Element", price).deliver_now
                              value = "#{@element.user.vname}'s element #{@element.name} was approved."
                           #else
                           #   flash[:error] = "Insufficient funds to create a creature!"
                           #   redirect_to user_path(logged_in.id)
                           #end
                        else
                           @element = elementFound
                           #ContentMailer.content_denied(@element, "Element").deliver_now
                           value = "#{@element.user.vname}'s element #{@element.name} was denied."
                        end
                        flash[:success] = value
                        redirect_to elements_review_path
                     else
                        redirect_to root_path
                     end
                  else
                     render "webcontrols/missingpage"
                  end
               else
                  redirect_to root_path
               end
            end
         end
      end
end
