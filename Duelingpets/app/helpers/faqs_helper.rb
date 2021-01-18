module FaqsHelper

   private
      def getFaqParams(type)
         value = ""
         if(type == "Id")
            value = params[:id]
         elsif(type == "FaqId")
            value = params[:faq_id]
         elsif(type == "User")
            value = params[:user_id]
         elsif(type == "Faq")
            value = params.require(:faq).permit(:goal)
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
               userFaqs = userFound.faqs.order("reviewed_on desc, created_on desc")
               faqsReviewed = userFaqs.select{|faq| faq.reviewed || (current_user && faq.user_id == current_user.id)}
               @user = userFound
            else
               render "webcontrols/missingpage"
            end
         else
            allFaqs = Faq.order("reviewed_on desc, created_on desc")
            faqsReviewed = allFaqs.select{|faq| faq.reviewed || (current_user && faq.user_id == current_user.id)}
         end
         @faqs = Kaminari.paginate_array(faqsReviewed).page(getFaqParams("Page")).per(10)
      end

      def optional
         value = getFaqParams("User")
         return value
      end

      def editCommons(type)
         faqFound = Faq.find_by_id(getFaqParams("Id"))
         if(faqFound)
            logged_in = current_user
            if(logged_in && ((logged_in.id == faqFound.user_id) || logged_in.pouch.privilege == "Admin"))
               faqFound.reviewed = false
               faqFound.updated_on = currentTime
               @faq = faqFound
               @user = User.find_by_vname(faqFound.user.vname)
               if(type == "update")
                  if(@faq.update_attributes(getFaqParams("Faq")))
                     flash[:success] = "Faq #{@faq.goal} was successfully updated."
                     redirect_to user_faqs_path(@faq.user)
                  else
                     render "edit"
                  end
               elsif(type == "destroy")
                  @faq.destroy
                  flash[:success] = "#{@faq.name} was successfully removed."
                  if(logged_in.pouch.privilege == "Admin")
                     redirect_to faqs_list_path
                  else
                     redirect_to user_faqs_path(faqFound.user)
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
               userMode = Maintenancemode.find_by_id(13)
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
               userMode = Maintenancemode.find_by_id(13)
               if(allMode.maintenance_on || userMode.maintenance_on)
                  if(allMode.maintenance_on)
                     render "/start/maintenance"
                  else
                     render "/users/maintenance"
                  end
               else
                  logged_in = current_user
                  userFound = User.find_by_vname(getFaqParams("User"))
                  if(logged_in && userFound)
                     if(logged_in.id == userFound.id)
                        newFaq = logged_in.faqs.new
                        if(type == "create")
                           newFaq = logged_in.faqs.new(getFaqParams("Faq"))
                           newFaq.created_on = currentTime
                           newFaq.updated_on = currentTime
                        end

                        @faq = newFaq
                        @user = userFound

                        if(type == "create")
                           if(@faq.save)
                              flash[:success] = "#{@faq.goal} was successfully created."
                              redirect_to user_faqs_path(@user)
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
            elsif(type == "edit" || type == "update" || type == "destroy")
               if(current_user && current_user.pouch.privilege == "Admin")
                  editCommons(type)
               else
                  allMode = Maintenancemode.find_by_id(1)
                  userMode = Maintenancemode.find_by_id(13)
                  if(allMode.maintenance_on || userMode.maintenance_on)
                     if(allMode.maintenance_on)
                        render "/start/maintenance"
                     else
                        render "/users/maintenance"
                     end
                  else
                     editCommons(type)
                  end
               end
            elsif(type == "list")
               logged_in = current_user
               if(logged_in && (logged_in.pouch.privilege == "Admin" || logged_in.pouch.privilege == "Glitchy"))
                  removeTransactions
                  allFaqs = Faq.order("reviewed_on desc, created_on desc")
                  @faqs = allFaqs.page(getFaqParams("Page")).per(10)
                  puts @faqs
               else
                  redirect_to root_path
               end
            elsif(type == "review")
               logged_in = current_user
               if(logged_in)
                  removeTransactions
                  allFaqs = Faq.order("reviewed_on desc, created_on desc")
                  if(logged_in.pouch.privilege == "Admin" || ((logged_in.pouch.privilege == "Keymaster") || (logged_in.pouch.privilege == "Reviewer")))
                     faqsToReview = allFaqs.select{|faq| !faq.reviewed}
                     @faqs = Kaminari.paginate_array(faqsToReview).page(getFaqParams("Page")).per(10)
                  else
                     redirect_to root_path
                  end
               else
                  redirect_to root_path
               end
            elsif(type == "approve" || type == "deny")
               logged_in = current_user
               if(logged_in)
                  faqFound = Faq.find_by_id(getFaqParams("FaqId"))
                  if(faqFound)
                     pouchFound = Pouch.find_by_user_id(logged_in.id)
                     if((logged_in.pouch.privilege == "Admin") || ((pouchFound.privilege == "Keymaster") || (pouchFound.privilege == "Reviewer")))
                        if(type == "approve")
                           faqFound.reviewed = true
                           faqFound.reviewed_on = currentTime
                           @faq = faqFound
                           @faq.save
                           #ContentMailer.content_approved(@faq, "Faq", pointsForArt).deliver_now
                           value = "#{@faq.user.vname}'s faq #{@faq.goal} was approved."
                        else
                           @faq = faqFound
                           #ContentMailer.content_denied(@art, "Art").deliver_now
                           value = "#{@faq.user.vname}'s faq #{@faq.goal} was denied."
                        end
                        flash[:success] = value
                        redirect_to faqs_review_path
                     else
                        redirect_to root_path
                     end
                  else
                     render "webcontrols/missingpage"
                  end
               else
                  redirect_to root_path
               end
            elsif(type == "staffanswer" || type == "reply" || type == "replypost")
               logged_in = current_user
               if(logged_in && (logged_in.pouch.privilege == "Glitchy" || logged_in.pouch.privilege == "Manager"))
                  faqFound = nil
                  if(type == "staffanswer" || type == "replypost")
                     faqFound = Faq.find_by_id(params[:faq_id])
                     if(type == "staffanswer")
                        redirect_to faqs_reply_path(faqFound.id)
                     end
                  elsif(type == "reply")
                     faqFound = Faq.find_by_id(params[:format])
                  end
                  if(type == "reply" || type == "replypost")
                     if(faqFound)
                        @faq = faqFound
                        if(type == "replypost")
                           reqs = params[:faq][:prereqs]
                           steps = params[:faq][:steps]
                           if(!reqs.nil? && !steps.nil?)
                              @faq.replied_on = currentTime
                              @faq.steps = steps
                              @faq.prereqs = reqs
                              @faq.staff_id = logged_in.id
                              @faq.save
                              flash[:success] = "Faq #{faq.goal} was replied to!"
                              redirect_to faqs_list_path
                           else
                              flash[:error] = "Steps and Reqs can't be nil!"
                              redirect_to root_path
                           end
                        end
                     else
                        flash[:error] = "Faq not found"
                        redirect_to root_path
                     end
                  end
               else
                  redirect_to root_path
               end
            end
         end
      end
end
