module StartHelper

   private
      def staff
         value = false
         if(((current_user.pouch.privilege == "Keymaster") || (current_user.pouch.privilege == "Reviewer")) || (current_user.pouch.privilege == "Admin"))
            value = true
         end
         return value
      end

      def boxstatus(type)
         status = ""
         if(type == "Donationbox")
            if(current_user.donationbox.box_open)
               status = "Open"
            else
               status = "Closed"
            end
         elsif(type == "Shoutbox")
            if(current_user.shoutbox.box_open)
               status = "Open"
            else
               status = "Closed"
            end
         elsif(type == "PMbox")
            if(current_user.pmbox.box_open)
               status = "Open"
            else
               status = "Closed"
            end
         end
         return status
      end

      def alert(type)
         value = 0
         if(type != "All")
            if(alertMessages(type, "Number") != 0)
               value += 1
            end
         else
            if(alertMessages("Pouch", "Number") != 0)
               value += 1
            end
            if(alertMessages("Emerald", "Number") != 0)
               value += 1
            end
            if(alertMessages("Blog", "Number") != 0)
               value += 1
            end
            if(alertMessages("OC", "Number") != 0)
               value += 1
            end
            if(alertMessages("Dreyore", "Number") != 0)
               value += 1
            end
            if(alertMessages("Jukebox", "Number") != 0)
               value += 1
            end
            if(alertMessages("Book", "Number") != 0)
               value += 1
            end
            if(alertMessages("Channel", "Number") != 0)
               value += 1
            end
            if(alertMessages("Gallery", "Number") != 0)
               value += 1
            end
            if(alertMessages("Shoutbox", "Number") != 0)
               value += 1
            end
            if(alertMessages("PMbox", "Number") != 0)
               value += 1
            end
            if(alertMessages("Donationbox", "Number") != 0)
               value += 1
            end
            if(alertMessages("Partner", "Number") != 0)
               value += 1
            end
            if(alertMessages("Item", "Number") != 0)
               value += 1
            end
         end
         return value
      end

      def alertMessages(type, valueType)
         alert = 0
         capacity = 0
         amount = 0

         #Determines the message to display
         if(type == "Pouch")
            capacity = getUpgrades("Pouch", "Limit", current_user.pouch, 1)
            amount = current_user.pouch.amount
         elsif(type == "Emerald")
            capacity = getUpgrades("Emerald", "Limit", current_user.pouch, 2)
            amount = current_user.pouch.emeraldamount
         elsif(type == "Blog")
            capacity = getUpgrades("Blog", "Limit", current_user.pouch, 3)
            amount = current_user.blogs.count
         elsif(type == "OC")
            capacity = getUpgrades("OC", "Limit", current_user.pouch, 4)
            amount = current_user.ocs.count
         elsif(type == "Dreyore")
            capacity = getUpgrades("Dreyore", "Limit", current_user.pouch, 5)
            amount = current_user.pouch.dreyterriumamount
         elsif(type == "Jukebox")
            capacity = getUpgrades("Jukebox", "Limit", current_user.pouch, 6)
            amount = current_user.jukeboxes.count
         elsif(type == "Book")
            capacity = getUpgrades("Book", "Limit", current_user.pouch, 7)
            amount = current_user.books.count
         elsif(type == "Channel")
            capacity = getUpgrades("Channel", "Limit", current_user.pouch, 8)
            amount = current_user.channels.count
         elsif(type == "Gallery")
            capacity = getUpgrades("Gallery", "Limit", current_user.pouch, 9)
            amount = current_user.galleries.count
            #End of traditional content
         elsif(type == "Shoutbox")
            capacity = current_user.shoutbox.capacity
            allShouts = Shout.all
            shouts = allShouts.select{|shout| shout.shoutbox_id == current_user.shoutbox.id}
            amount = shouts.count
         elsif(type == "PMbox")
            capacity = current_user.pmbox.capacity
            allPMs = Pm.all
            pms = allPMs.select{|pm| pm.pmbox_id == current_user.pmbox.id}
            amount = pms.count
         elsif(type == "Donationbox")
            capacity = current_user.donationbox.capacity
            amount = current_user.donationbox.progress
         elsif(type == "Partner")
            capacity = current_user.inventory.petcapacity
            amount = current_user.partners.count
         elsif(type == "Item")
            capacity = current_user.inventory.capacity
            amount = current_user.inventory.inventoryslots.count
         end

         #Decides on whether to pass back a string or a number
         if(valueType == "Name")
            if(capacity != 0 && capacity - amount >= 0)
               if(amount == capacity)
                  alert = "Full capacity"
               elsif(capacity - amount <= 4 && amount > 0)
                  alert = "Limited capacity"
               elsif((capacity >= 20 && amount > 0) && ((capacity - amount) <= (capacity * 0.25)))
                  alert = "Quarter capacity"
               end
            elsif(capacity == 0)
               alert = "N/A"
            else
               alert = "Overflow, please delete some!"
            end   
         else
            if(capacity != 0 && capacity - amount >= 0)
               if(amount == capacity)
                  alert = 1
               elsif(capacity - amount <= 4 && amount > 0)
                  alert = 2
               elsif((capacity >= 20 && amount > 0) && ((capacity - amount) <= (capacity * 0.25)))
                  alert = 3
               end
            elsif(capacity == 0)
               alert = 0
            else
               alert = -1
            end
         end
         return alert
      end

      def notify(type)
         #Determines the content that will be chosen
         if(type == "Blog")
            allContents = Blog.all
         elsif(type == "OC")
            allContents = Oc.all
         elsif(type == "Item")
            allContents = Item.all
         elsif(type == "Creature")
            allContents = Creature.all
         elsif(type == "Art")
            allContents = Art.all
         elsif(type == "Sound")
            allContents = Sound.all
         elsif(type == "Movie")
            allContents = Movie.all
         elsif(type == "Chapter")
            allContents = Chapter.all
         elsif(type == "Registration")
            allContents = Registration.all
         elsif(type == "Colorscheme")
            allContents = Colorscheme.all
         elsif(type == "Shout")
            allContents = Shout.all
         elsif(type == "PM")
            allContents = Pm.all
         elsif(type == "Partner")
            allContents = Partner.all
         end
      end   

      def getNotifications(type)
         allContents = ""
         if(type != "All")
            allContents = notify(type)
         end

         #Determines which value system to use
         if(type == "Registration")
            contents = allContents
            value = contents.count
         elsif(type == "Colorscheme")
            contents = allContents.select{|content| !content.activated && content.user_id == current_user.id}
            value = contents.count
         elsif(type == "Shout")
            contents = allContents.select{|content| !content.reviewed && content.shoutbox_id == current_user.shoutbox.id}
            value = contents.count
         elsif(type == "PM")
            contents = allContents.select{|content| (content.user_id == current_user.id && content.user1_unread) || (content.pmbox.user_id == current_user.id && content.user2_unread)}
            value = contents.count
         elsif(type == "Partner")
            contents = allContents.select{|content| content.inbattle && content.user_id == current_user.id}
            value = contents.count
         elsif(type == "All")
            noteCount = 0
            if(staff)
               allContents = notify("Blog")
               blogs = allContents.select{|content| !content.reviewed}
               noteCount += blogs.count

               allContents = notify("OC")
               ocs = allContents.select{|content| !content.reviewed}
               noteCount += ocs.count

               allContents = notify("Item")
               items = allContents.select{|content| !content.reviewed}
               noteCount += items.count

               allContents = notify("Creature")
               creatures = allContents.select{|content| !content.reviewed}
               noteCount += creatures.count

               allContents = notify("Art")
               arts = allContents.select{|content| !content.reviewed}
               noteCount += arts.count

               allContents = notify("Sound")
               sounds = allContents.select{|content| !content.reviewed}
               noteCount += sounds.count

               allContents = notify("Movie")
               movies = allContents.select{|content| !content.reviewed}
               noteCount += movies.count

               allContents = notify("Chapter")
               chapters = allContents.select{|content| !content.reviewed}
               noteCount += chapters.count

               allContents = notify("Registration")
               noteCount += allContents.count
            end

            #Counts all the Colorschemes and shout related notifications
            allContents = notify("Colorscheme")
            colors = allContents.select{|content| !content.activated && content.user_id == current_user.id}
            noteCount += colors.count

            allContents = notify("Shout")
            shouts = allContents.select{|content| !content.reviewed && content.shoutbox_id == current_user.shoutbox.id}
            noteCount += shouts.count

            #Counts all the PM and partner related notifications
            allContents = notify("PM")
            pms = allContents.select{|content| (content.user_id == current_user.id && content.user1_unread) || (content.pmbox.user_id == current_user.id && content.user2_unread)}
            noteCount += pms.count

            allContents = notify("Partner")
            partners = allContents.select{|content| content.inbattle && content.user_id == current_user.id}
            noteCount += partners.count
            value = noteCount
         else
            #This is for notifying staff of new content
            contents = allContents.select{|content| !content.reviewed}
            value = contents.count
         end
         return value
      end

      #Might move this to a different helper   
      def getReviewContent(type)
         value = 0
         if(type == "Creature")
            allCreatures = Creature.all
            toReview = allCreatures.select{|content| !content.reviewed}
            value = toReview.count
         elsif(type == "Item")
            allItems = Item.all
            toReview = allItems.select{|content| !content.reviewed}
            value = toReview.count
         elsif(type == "OC")
            allOCs = Oc.all
            toReview = allOCs.select{|content| !content.reviewed}
            value = toReview.count
         elsif(type == "Blog")
            allBlogs = Blog.all
            toReview = allBlogs.select{|content| !content.reviewed}
            value = toReview.count
         elsif(type == "Art")
            #toReview = allCreatures.select{|content| !content.reviewed}
         elsif(type == "Sound")
            allSounds = Sound.all
            toReview = allSounds.select{|content| !content.reviewed}
            value = toReview.count
         elsif(type == "Movie")
            allMovies = Movie.all
            toReview = allMovies.select{|content| !content.reviewed}
            value = toReview.count
         elsif(type == "Chapter")
            allChapters = Chapter.all
            toReview = allChapters.select{|content| !content.reviewed}
            value = toReview.count
         elsif(type == "Shout")
            allShouts = Shout.all
            toReview = allShouts.select{|content| !content.reviewed}
            value = toReview.count
         end
         return value
      end

      def getTimeDifference(type, content)
         value = ""
         if(type == "User")
            value = (currentTime - content.joined_on)
         elsif(type == "Register")
            value = (currentTime - content.registered_on)
         elsif(type != "User")
            value = (currentTime - content.created_on)
         end
         return value
      end

      def getStatsTimeframe(type, timeframe)
         allContents = ""
         firstContent = ""

         if(type == "User")
            allContents = User.all
            if(allContents.count != 0)
               firstContent = User.first.joined_on.year
            end
         elsif(type == "OC")
            allContents = Oc.all
            if(allContents.count != 0)
               firstContent = Oc.first.created_on.year
            end
         elsif(type == "Item")
            allContents = Item.all
            if(allContents.count != 0)
               firstContent = Item.first.created_on.year
            end
         elsif(type == "Creature")
            allContents = Creature.all
            if(allContents.count != 0)
               firstContent = Creature.first.created_on.year
            end
         elsif(type == "PM")
            allContents = Pm.all
            if(allContents.count != 0)
               firstContent = Pm.first.created_on.year
            end
         elsif(type == "PMreply")
            allContents = Pmreply.all
            if(allContents.count != 0)
               firstContent = Pmreply.first.created_on.year
            end
         elsif(type == "Register")
            allContents = Registration.all
            if(allContents.count != 0)
               firstContent = Registration.first.registered_on.year
            end
         elsif(type == "Referral")
            allContents = Referral.all
            if(allContents.count != 0)
               firstContent = Referral.first.created_on.year
            end
         elsif(type == "Friend")
            #allContents = Friend.all
            #if(allContents.count != 0)
               #firstContent = Friend.first.created_on.year
            #end
         elsif(type == "Colorscheme")
            allContents = Colorscheme.all
            if(allContents.count != 0)
               firstContent = Colorscheme.first.created_on.year
            end
         elsif(type == "Gallery")
            allContents = Gallery.all
            if(allContents.count != 0)
               firstContent = Gallery.first.created_on.year
            end
         elsif(type == "Mainfolder")
            allContents = Mainfolder.all
            if(allContents.count != 0)
               firstContent = Mainfolder.first.created_on.year
            end
         elsif(type == "Subfolder")
            allContents = Subfolder.all
            if(allContents.count != 0)
               firstContent = Subfolder.first.created_on.year
            end
         elsif(type == "Art")
            allContents = Art.all
            if(allContents.count != 0)
               firstContent = Art.first.created_on.year
            end
         elsif(type == "Jukebox")
            allContents = Jukebox.all
            if(allContents.count != 0)
               firstContent = Jukebox.first.created_on.year
            end
         elsif(type == "Mainsheet")
            allContents = Mainsheet.all
            if(allContents.count != 0)
               firstContent = Mainsheet.first.created_on.year
            end
         elsif(type == "Subsheet")
            allContents = Subsheet.all
            if(allContents.count != 0)
               firstContent = Subsheet.first.created_on.year
            end
         elsif(type == "Sound")
            allContents = Sound.all
            if(allContents.count != 0)
               firstContent = Sound.first.created_on.year
            end
         elsif(type == "Channel")
            allContents = Channel.all
            if(allContents.count != 0)
               firstContent = Channel.first.created_on.year
            end
         elsif(type == "Mainplaylist")
            allContents = Mainplaylist.all
            if(allContents.count != 0)
               firstContent = Mainplaylist.first.created_on.year
            end
         elsif(type == "Subplaylist")
            allContents = Subplaylist.all
            if(allContents.count != 0)
               firstContent = Subplaylist.first.created_on.year
            end
         elsif(type == "Movie")
            allContents = Movie.all
            if(allContents.count != 0)
               firstContent = Movie.first.created_on.year
            end
         elsif(type == "Bookworld")
            allContents = Bookworld.all
            if(allContents.count != 0)
               firstContent = Bookworld.first.created_on.year
            end
         elsif(type == "Book")
            allContents = Book.all
            if(allContents.count != 0)
               firstContent = Book.first.created_on.year
            end
         elsif(type == "Chapter")
            allContents = Chapter.all
            if(allContents.count != 0)
               firstContent = Chapter.first.created_on.year
            end
         elsif(type == "Blog")
            allContents = Blog.all
            if(allContents.count != 0)
               firstContent = Blog.first.created_on.year
            end
         elsif(type == "Forum")
            #allContents = Forum.all
            #if(allContents.count != 0)
               #firstContent = Forum.first.created_on.year
            #end
         elsif(type == "Container")
            #allContents = Topiccontainer.all
            #if(allContents.count != 0)
               #firstContent = Topiccontainer.first.created_on.year
            #end
         elsif(type == "Maintopic")
            #allContents = Maintopic.all
            #if(allContents.count != 0)
               #firstContent = Maintopic.first.created_on.year
            #end
         elsif(type == "Subtopic")
            #allContents = Subtopic.all
            #if(allContents.count != 0)
               #firstContent = Subtopic.first.created_on.year
            #end
         elsif(type == "Narrative")
            #allContents = Narrative.all
            #if(allContents.count != 0)
               #firstContent = Narrative.first.created_on.year
            #end
         elsif(type == "Reply")
            #allContents = Reply.all
            #if(allContents.count != 0)
               #firstContent = Reply.first.created_on.year
            #end
         elsif(type == "Soundcritique")
            #allContents = Soundcomment.all
            #if(allContents.count != 0)
               #firstContent = Soundcomment.first.created_on.year
            #end
         elsif(type == "Soundcomment")
            #allContents = Soundcomment.all
            #if(allContents.count != 0)
               #firstContent = Soundcomment.first.created_on.year
            #end
         elsif(type == "Artcritique")
            #allContents = Artcomment.all
            #if(allContents.count != 0)
               #firstContent = Artcomment.first.created_on.year
            #end
         elsif(type == "Artcomment")
            #allContents = Artcomment.all
            #if(allContents.count != 0)
               #firstContent = Artcomment.first.created_on.year
            #end
         elsif(type == "Moviecritique")
            #allContents = Moviecomment.all
            #if(allContents.count != 0)
               #firstContent = Moviecomment.first.created_on.year
            #end
         elsif(type == "Moviecomment")
            #allContents = Moviecomment.all
            #if(allContents.count != 0)
               #firstContent = Moviecomment.first.created_on.year
            #end
         elsif(type == "Shout")
            allContents = Shout.all
            if(allContents.count != 0)
               firstContent = Shout.first.created_on.year
            end
         elsif(type == "Favoritesound")
            #allContents = Favoritesound.all
            #if(allContents.count != 0)
               #firstContent = Favoritesound.first.created_on.year
            #end
         elsif(type == "Soundstar")
            #allContents = Soundstar.all
            #if(allContents.count != 0)
               #firstContent = Soundstar.first.created_on.year
            #end
         elsif(type == "Favoriteart")
            #allContents = Favoriteart.all
            #if(allContents.count != 0)
               #firstContent = Favoriteart.first.created_on.year
            #end
         elsif(type == "Artstar")
            #allContents = Artstar.all
            #if(allContents.count != 0)
               #firstContent = Artstar.first.created_on.year
            #end
         elsif(type == "Favoritemovie")
            #allContents = Favoritemovie.all
            #if(allContents.count != 0)
               #firstContent = Favoritemovie.first.created_on.year
            #end
         elsif(type == "Moviestar")
            #allContents = Moviestar.all
            #if(allContents.count != 0)
               #firstContent = Moviestar.first.created_on.year
            #end
         elsif(type == "Blogstar")
            #allContents = Blogstar.all
            #if(allContents.count != 0)
               #firstContent = Blogstar.first.created_on.year
            #end
         elsif(type == "Watcher")
            #allContents = Watch.all
            #if(allContents.count != 0)
               #firstContent = Watch.first.created_on.year
            #end
         elsif(type == "Containersub")
            #allContents = Containersub.all
            #if(allContents.count != 0)
               #firstContent = Containersub.first.created_on.year
            #end
         elsif(type == "Maintopicsub")
            #allContents = Maintopicsub.all
            #if(allContents.count != 0)
               #firstContent = Maintopicsub.first.created_on.year
            #end
         elsif(type == "Subtopicsub")
            #allContents = Subtopicsub.all
            #if(allContents.count != 0)
               #firstContent = Subtopicsub.first.created_on.year
            #end
         elsif(type == "Forummod")
            #allContents = Forummod.all
            #if(allContents.count != 0)
               #firstContent = Forummod.first.created_on.year
            #end
         elsif(type == "Containermod")
            #allContents = Containermod.all
            #if(allContents.count != 0)
               #firstContent = Containermod.first.created_on.year
            #end
         elsif(type == "Maintopicmod")
            #allContents = Maintopicmod.all
            #if(allContents.count != 0)
               #firstContent = Maintopicmod.first.created_on.year
            #end
         elsif(type == "Forummember")
            #allContents = Forummember.all
            #if(allContents.count != 0)
               #firstContent = Forummember.first.created_on.year
            #end
         end

         total = 0
         if(firstContent.to_s != "")
            #Determine if the contents is not bot related
            if(type == "Register")
               nonBot = allContents
            elsif(type != "User")
               nonBot = allContents.select{|content| ((content.user.pouch.privilege != "Bot") && (content.user.pouch.privilege != "Trial")) && ((content.user.pouch.privilege != "Admin") && (content.user.pouch.privilege != "Glitchy"))}
            else
               nonBot = allContents.select{|content| ((content.pouch.privilege != "Bot") && (content.pouch.privilege != "Trial")) && ((content.pouch.privilege != "Admin") && (content.pouch.privilege != "Glitchy"))}
            end

            #Finds all the content created on a specific day
            day = nonBot.select{|content| getTimeDifference(type, content) <= 1.day}
            week = nonBot.select{|content| getTimeDifference(type, content) <= 1.week}
            month = nonBot.select{|content| getTimeDifference(type, content) <= 1.month}
            year = nonBot.select{|content| getTimeDifference(type, content) <= 1.year}
            threeyear = nonBot.select{|content| getTimeDifference(type, content) <= 3.years}
            bacot = nonBot.select{|content| getTimeDifference(type, content) > (firstContent - 1.year)}

            #Sums up the data for the particular timeframe
            dayCount = day.count
            weekCount = week.count - dayCount
            monthCount = month.count - weekCount - dayCount
            yearCount = year.count - monthCount - weekCount - dayCount
            dreiJahreCount = threeyear.count - yearCount - monthCount - weekCount - dayCount
            bacotCount = bacot.count - dreiJahreCount - yearCount - monthCount - weekCount - dayCount

            total = dayCount
            if(timeframe == "Week")
               total = weekCount
            elsif(timeframe == "Month")
               total = monthCount
            elsif(timeframe == "Year")
               total = yearCount
            elsif(timeframe == "Threeyears")
               total = dreiJahreCount
            elsif(timeframe == "BaconOfTomato")
               total = bacotCount
            elsif(timeframe == "All")
               total = nonBot.count
            end
         end
         return total
      end

      def getStatDifference(type, visit)
         value = (currentTime - visit.created_on)
         return value
      end

      def getVisitStats(type, timeframe)
         allVisits = ""
         if(type == "User")
            #allVisits = Uservisit.all
         elsif(type == "Radio")
            #allVisits = Radiovisit.all
         elsif(type == "Sound")
            #allVisits = Soundvisit.all
         elsif(type == "Gallery")
            #allVisits = Galleryvisit.all
         elsif(type == "Art")
            #allVisits = Artvisit.all
         elsif(type == "Channel")
            #allVisits = Channelvisit.all
         elsif(type == "Movie")
            #allVisits = Movievisit.all
         elsif(type == "Blog")
            #allVisits = Blogvisit.all
         elsif(type == "OC")
            #allVisits = Ocvisit.all
         elsif(type == "Item")
            #allVisits = Itemvisit.all
         elsif(type == "Creature")
            #allVisits = Creaturevisit.all
         end

         total = 0
         if(allVisits.to_s != "")
            #Determine if the visits is not bot related
            nonBot = allVisits.select{|visit| ((visit.from_user.pouch.privilege != "Bot") && (visit.from_user.pouch.privilege != "Trial")) && ((visit.from_user.pouch.privilege != "Admin") && (visit.from_user.pouch.privilege != "Glitchy"))}

            #Finds all the visit created on a specific time
            twenty = nonBot.select{|visit| getStatDifference(type, visit) <= 20.minutes}
            fourty = nonBot.select{|visit| getStatDifference(type, visit) <= 40.minutes}
            sixty = nonBot.select{|visit| getStatDifference(type, visit) <= 1.hour}
            twohours = nonBot.select{|visit| getStatDifference(type, visit) <= 2.hours}
            threehours = nonBot.select{|visit| getStatDifference(type, visit) <= 3.hours}

            #Sums up the data for the particular timeframe
            twentyCount = twenty.count
            fourtyCount = fourty.count - twentyCount
            sixtyCount = sixty.count - fourtyCount - twentyCount
            twohoursCount = twohours.count - sixtyCount - fourtyCount - twentyCount
            threehoursCount = threehours.count - twohoursCount - sixtyCount - fourtyCount - twentyCount

            total = twentyCount
            if(timeframe == "Fourty")
               total = fourtyCount
            elsif(timeframe == "Sixty")
               total = sixtyCount
            elsif(timeframe == "Twohours")
               total = twohoursCount
            elsif(timeframe == "Threehours")
               total = threehoursCount
            elsif(timeframe == "All")
               total = nonBot.count
            end
         end
         return total
      end

      def homepageAlerts
         value = ""
         criticalMode = Maintenancemode.find_by_id(2)
         betaMode = Maintenancemode.find_by_id(3)
         grandMode = Maintenancemode.find_by_id(4)
         if(criticalMode.maintenance_on)
            value = "[Chipmunks have ran off with the ram]"
         elsif(betaMode.maintenance_on)
            value = "[Beta]"
         elsif(grandMode.maintenance_on)
            value = "[Grand-Opening]"
         end
         return value
      end

      def gateStatus
         control = Webcontrol.find_by_id(1)
         if(control.gate_open)
            value = "Registration is currently open!"
         else
            value = "Registration is currently closed!"
         end
         return value
      end

      def criticalErrors
         value = 0
         criticalMode = Maintenancemode.find_by_id(2)
         if(criticalMode.maintenance_on)
            value = 1
         end
         return value
      end

      def userprofile(type)
         profile = (link_to("Login", login_path)  + " " + link_to("Register", register_path))
         if(type == "User")
            profile = (link_to(current_user.vname, current_user) + " " + link_to("Logout", logout_path, method: "delete"))
         end
         return profile
      end

      def displayType(type)
         control = Webcontrol.find_by_id(1)
         value = ""

         #Displays a given image to the screen
         if(type == "Favicon")
            value = control.favicon_url(:thumb)
         elsif(type == "Mascot")
            value = control.mascot_url(:thumb)
         elsif(type == "Banner")
            value = control.banner_url(:thumb)
         else
            raise "Invalid type of display was detected!"
         end
         return value
      end

      def mode(type)
         if(timeExpired)
            logout_user
            logoutExpiredUsers
            redirect_to root_path
         else
            if(type == "home" || type == "aboutus" || type == "hubworld")
               #Initially empty
               removeTransactions
               if(type == "aboutus")
                  displayGreeter("Aboutus")
               end
            elsif(type == "contact" || type == "verify" || type == "verify2")
               #Consider adding a greater to contact page
               removeTransactions
               if(type == "verify")
                  color_value = params[:session][:color].downcase
                  if(color_value)
                     results = `public/Resources/Code/verification/verify #{color_value}`
                     validMatch = results

                     #Determines if we are looking at a bot or a human
                     if(!validMatch.empty? && results != "Invalid")
                        params[:session][:create] = color_value
                        render "contact2"
                     else
                        flash[:error] = "Person verification failed. Please try again."
                        redirect_to root_path
                     end
                  else
                     flash[:error] = "Invalid color value"
                     redirect_to root_path
                  end
               elsif(type == "verify2")
                  name_value = params[:session][:name].downcase
                  email_value = params[:session][:email].downcase
                  subject_value = params[:session][:subject]
                  body_value = params[:session][:body]
                  @name = name_value
                  @email = email_value
                  @subject = subject_value
                  @body = body_value
                  if(name_value.empty? || email_value.empty? || subject_value.empty? || body_value.empty?)
                     flash[:error] = "One of the parameters was empty please ensure all are filled in."
                  else
                     flash[:success] = "Your contact info has now been sent."
                     UserMailer.contact(@name, @email, @subject, @body).deliver_now
                  end
                  redirect_to root_path
               end
            elsif(type == "activeusers")
               allMode = Maintenancemode.find_by_id(1)
               if(allMode.maintenance_on)
                  render "/start/maintenance"
               else
                  if(current_user)
                     #Retrieving the active users
                     allUsers = Pouch.order("signed_in_at desc")
                     activeUsers = allUsers.select{|pouch| (pouch.activated && !pouch.signed_out_at) && (pouch.last_visited && (currentTime - pouch.last_visited) < 30.minutes)}
                     @pouches = Kaminari.paginate_array(activeUsers).page(params[:page]).per(50)
                  else
                     redirect_to root_path
                  end
               end
            elsif(type == "admincontrols" || type == "keymastercontrols" || type == "reviewercontrols" || type == "managercontrols")
               logged_in = current_user
               if(logged_in)
                  
               else
                  redirect_to root_path
               end
            elsif(type == "notification" || type == "pagealerts")
               logged_in = current_user
               if(logged_in)

               else
                  redirect_to root_path
               end
            end
         end
      end
end
