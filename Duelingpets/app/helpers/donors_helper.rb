module DonorsHelper

   private
      def getDonorParams(type)
         value = ""
         if(type == "Id")
            value = params[:id]
          elsif(type == "DonorId")
            value = params[:donor_id]
         elsif(type == "Donor")
            value = params.require(:donor).permit(:description, :amount)
         elsif(type == "Page")
            value = params[:page]
         else
            raise "Invalid type detected!"
         end
         return value
      end

      def mode(type)
         if(timeExpired)
            logout_user
            redirect_to root_path
         else
            if(type == "index")
               logged_in = current_user
               if(logged_in && logged_in.pouch.privilege == "Admin")
                  removeTransactions
                  allDonors = Donor.order("updated_on desc, created_on desc")
                  @donors = Kaminari.paginate_array(allDonors).page(getDonorParams("Page")).per(10)
               else
                  redirect_to root_path
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
                  donationboxFound = Donationbox.find_by_id(params[:donationbox_id])
                  if((logged_in && donationboxFound) && (logged_in.id != donationboxFound.user.id))
                     if(donationboxFound.box_open)
                        if(type == "new")
                           newDonor = donationboxFound.donors.new
                           @donationbox = donationboxFound
                           @donor = newDonor
                        else
                           newDonor = donationboxFound.donors.new(getDonorParams("Donor"))
                           newDonor.created_on = currentTime
                           newDonor.updated_on = currentTime
                           newDonor.user_id = logged_in.id
                           @donor = newDonor
                           if(@donor.valid?)
                              capacityCheck = (@donor.amount <= @donor.capacity)
                              donationCheck = (logged_in.pouch.amount - @donor.amount >= 0)
                              boxCheck = (donationboxFound.progress + @donor.amount <= donationboxFound.capacity)
                              pointsAvailable = (logged_in.pouch.amount > 0)
                              #May remove description later
                              if((capacityCheck && donationCheck) && (boxCheck && pointsAvailable))
                                 if(@donor.save)
                                    points = donationboxFound.progress + @donor.amount
                                    donationboxFound.progress = points
                                    reachedGoal = (donationboxFound.progress >= donationboxFound.goal && !donationboxFound.hitgoal)
                                    if(reachedGoal)
                                       donationboxFound.hitgoal = true
                                       profit = donationboxFound.progress - donationboxFound.goal
                                       CommunityMailer.donations(@donor, "Goal", profit, 0, points).deliver_now
                                    end
                                    @donationbox = donationboxFound
                                    if(@donationbox.valid?)
                                       flash[:success] = "#{@donor.user.vname}'s donation was successfully added!"
                                       @donationbox.save
                                       logged_in.pouch.amount -= @donor.amount
                                       @pouch = logged_in.pouch
                                       @pouch.save
                                       CommunityMailer.donations(@donor, "Donated", @donor.amount, 0, 0).deliver_now
                                       redirect_to user_path(@donationbox.user)
                                    else
                                       flash[:error] = "This case should never happen!"
                                       @donor.destroy
                                       @donationbox = donationboxFound
                                       render "new"
                                    end
                                 else
                                    @donationbox = donationboxFound
                                    render "new"
                                 end
                              else
                                 redirect_to root_path
                              end
                           else
                              redirect_to root_path
                           end
                        end
                     else
                        flash[:error] = "User's donationbox is not open at this time!"
                        redirect_to user_path(donationboxFound.user)
                     end
                  else
                     message = ""
                     boxValue = @donationbox.progress + @donor.amount
                     if(@donor.amount > @donor.capacity)
                        message = "You exceeded the donor capacity of #{@donor.capacity} points!"
                     elsif(boxValue > @donationbox.capacity)
                        message = "You exceeded the donationbox capacity of #{@donationbox.capacity} points!"
                     else
                        message = "You don't have that amount of points to donate!"
                     end
                     flash[:error] = message
                     redirect_to user_path(@donationbox.user)
                  end
               end
            elsif(type == "mydonors")
               logged_in = current_user
               donationboxFound = Donationbox.find_by_id(params[:donationbox_id])
               if(logged_in && donationboxFound)
                  removeTransactions
                  donors = donationboxFound.donors.order("updated_on desc, created_on desc")
                  @donationbox = donationboxFound
                  @donors = Kaminari.paginate_array(donors).page(getDonorParams("Page")).per(10)
               else
                  redirect_to root_path
               end
            end
         end
      end
end
