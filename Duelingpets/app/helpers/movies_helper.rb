module MoviesHelper

   private
      def getMovieParams(type)
         value = ""
         if(type == "Id")
            value = params[:id]
          elsif(type == "MovieId")
            value = params[:movie_id]
         elsif(type == "Subplaylist")
            value = params[:subplaylist_id]
         elsif(type == "Movie")
            value = params.require(:movie).permit(:title, :description, :ogv, :remote_ogv_url, :ogv_cache,
            :mp4, :remote_mp4_url, :mp4_cache, :bookgroup_id)
         elsif(type == "Page")
            value = params[:page]
         else
            raise "Invalid type detected!"
         end
         return value
      end

      def updateChannel(subplaylist)
         subplaylist.updated_on = currentTime
         @subplaylist = subplaylist
         @subplaylist.save
         mainplaylist = Mainplaylist.find_by_id(@subplaylist.mainplaylist_id)
         mainplaylist.updated_on = currentTime
         @mainplaylist = mainplaylist
         @mainplaylist.save
         channel = Channel.find_by_id(@mainplaylist.channel_id)
         channel.updated_on = currentTime
         @channel = channel
         @channel.save
      end

      def editCommons(type)
         movieFound = Movie.find_by_id(getMovieParams("Id"))
         if(movieFound)
            logged_in = current_user
            if(logged_in && ((logged_in.id == movieFound.user_id) || logged_in.pouch.privilege == "Admin"))
               movieFound.updated_on = currentTime
               movieFound.reviewed = false

               #Determines the type of bookgroup the user belongs to
               allGroups = Bookgroup.order("created_on desc")
               allowedGroups = allGroups.select{|bookgroup| bookgroup.id <= getWritingGroup(logged_in, "Id")}
               @group = allowedGroups
               @movie = movieFound
               @subplaylist = Subplaylist.find_by_id(movieFound.subplaylist.id)
               if(type == "update")
                  if(@movie.update_attributes(getMovieParams("Movie")))
                     updateChannel(@subplaylist)
                     flash[:success] = "Movie #{@movie.title} was successfully updated."
                     redirect_to subplaylist_movie_path(@movie.subplaylist, @movie)
                  else
                     render "edit"
                  end
               end
            else
               redirect_to root_path
            end
         else
            render "webcontrols/crazybat"
         end
      end

      def showCommons(type)
         movieFound = Movie.find_by_id(getMovieParams("Id"))
         if(movieFound)
            removeTransactions
            if((current_user && ((movieFound.user_id == current_user.id) || (current_user.pouch.privilege == "Admin"))) || (checkBookgroupStatus(movieFound)))
               #visitTimer(type, blogFound)
               #cleanupOldVisits
               @movie = movieFound
               if(type == "destroy")
                  logged_in = current_user
                  if(logged_in && ((logged_in.id == movieFound.user_id) || logged_in.pouch.privilege == "Admin"))
                     #Eventually consider adding a sink to this
                     @movie.destroy
                     flash[:success] = "#{movieFound.title} was successfully removed."
                     if(logged_in.pouch.privilege == "Admin")
                        redirect_to movies_path
                     else
                        redirect_to mainplaylist_subplaylist_path(movieFound.subplaylist.mainplaylist, movieFound.subplaylist)
                     end
                  else
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

      def mode(type)
         if(timeExpired)
            logout_user
            redirect_to root_path
         else
            if(type == "index")
               logged_in = current_user
               if(logged_in && logged_in.pouch.privilege == "Admin")
                  removeTransactions
                  allMovies = Movie.order("updated_on desc, created_on desc")
                  @movies = Kaminari.paginate_array(allMovies).page(getMovieParams("Page")).per(10)
               else
                  redirect_to root_path
               end
            elsif(type == "new" || type == "create")
               allMode = Maintenancemode.find_by_id(1)
               channelMode = Maintenancemode.find_by_id(13)
               if(allMode.maintenance_on || channelMode.maintenance_on)
                  if(allMode.maintenance_on)
                     render "/start/maintenance"
                  else
                     render "/channels/maintenance"
                  end
               else
                  logged_in = current_user
                  subplaylistFound = Subplaylist.find_by_id(getMovieParams("Subplaylist"))
                  if(logged_in && subplaylistFound)
                     if(logged_in.id == subplaylistFound.user_id || (subplaylistFound.collab_mode &&
                        checkBookgroupStatus(subplaylistFound.mainplaylist.channel)))
                        if(!subplaylistFound.fave_folder)
                           newMovie = subplaylistFound.movies.new
                           if(type == "create")
                              newMovie = subplaylistFound.movies.new(getMovieParams("Movie"))
                              newMovie.created_on = currentTime
                              newMovie.updated_on = currentTime
                              newMovie.user_id = logged_in.id
                           end

                           #Determines the type of bookgroup the user belongs to
                           allGroups = Bookgroup.order("created_on desc")
                           allowedGroups = allGroups.select{|bookgroup| bookgroup.id <= getWritingGroup(logged_in, "Id")}
                           @group = allowedGroups
                           @movie = newMovie
                           @subplaylist = subplaylistFound

                           if(type == "create")
                              if(@movie.save)
                                 updateChannel(@movie.subplaylist)
                                 url = "http://www.duelingpets.net/movies/review"
                                 ContentMailer.content_review(@movie, "Movie", url).deliver_now
                                 flash[:success] = "#{@movie.title} was successfully created."
                                 redirect_to subplaylist_movie_path(@subplaylist, @movie)
                              else
                                 render "new"
                              end
                           end
                        else
                           flash[:error] = "Favorite folders don't support video!"
                           redirect_to root_path
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
                  channelMode = Maintenancemode.find_by_id(13)
                  if(allMode.maintenance_on || channelMode.maintenance_on)
                     if(allMode.maintenance_on)
                        render "/start/maintenance"
                     else
                        render "/channels/maintenance"
                     end
                  else
                     editCommons(type)
                  end
               end
            elsif(type == "show" || type == "destroy")
               allMode = Maintenancemode.find_by_id(1)
               channelMode = Maintenancemode.find_by_id(13)
               if(allMode.maintenance_on || channelMode.maintenance_on)
                  if(current_user && current_user.pouch.privilege == "Admin")
                     showCommons(type)
                  else
                     if(allMode.maintenance_on)
                        render "/start/maintenance"
                     else
                        render "/channels/maintenance"
                     end
                  end
               else
                  showCommons(type)
               end
            elsif(type == "review")
               logged_in = current_user
               if(logged_in)
                  removeTransactions
                  allMovies = Movie.order("reviewed_on desc, created_on desc")
                  if(logged_in.pouch.privilege == "Admin" || ((logged_in.pouch.privilege == "Keymaster") || (logged_in.pouch.privilege == "Reviewer")))
                     moviesToReview = allMovies.select{|movie| !movie.reviewed}
                     @movies = Kaminari.paginate_array(moviesToReview).page(getMovieParams("Page")).per(10)
                  else
                     redirect_to root_path
                  end
               else
                  redirect_to root_path
               end
            elsif(type == "approve" || type == "deny")
               logged_in = current_user
               if(logged_in)
                  movieFound = Movie.find_by_id(getMovieParams("MovieId"))
                  if(movieFound)
                     pouchFound = Pouch.find_by_user_id(logged_in.id)
                     if((logged_in.pouch.privilege == "Admin") || ((pouchFound.privilege == "Keymaster") || (pouchFound.privilege == "Reviewer")))
                        if(type == "approve")
                           movieFound.reviewed = true
                           movieFound.reviewed_on = currentTime
                           updateChannel(movieFound.subplaylist)

                           #Adds the points to the user's pouch
                           moviepoints = Fieldcost.find_by_name("Movie")
                           pointsForMovie = moviepoints.amount
                           @movie = movieFound
                           @movie.save
                           pouch = Pouch.find_by_user_id(@movie.user_id)
                           pouch.amount += pointsForMovie
                           @pouch = pouch
                           @pouch.save

                           #Adds the sound points to the economy
                           newTransaction = Economy.new(params[:economy])
                           newTransaction.econtype = "Content"
                           newTransaction.content_type = "Movie"
                           newTransaction.name = "Source"
                           newTransaction.amount = pointsForMovie
                           newTransaction.user_id = movieFound.user_id
                           newTransaction.created_on = currentTime
                           @economytransaction = newTransaction
                           @economytransaction.save

                           ContentMailer.content_approved(@movie, "Movie", pointsForMovie).deliver_now
                           #allWatches = Watch.all
                           #watchers = allWatches.select{|watch| (((watch.watchtype.name == "Arts" || watch.watchtype.name == "Blogarts") || (watch.watchtype.name == "Artsounds" || watch.watchtype.name == "Artmovies")) || (watch.watchtype.name == "Maincontent" || watch.watchtype.name == "All")) && watch.from_user.id != @art.user_id}
                           #if(watchers.count > 0)
                           #   watchers.each do |watch|
                           #      UserMailer.new_art(@art, watch).deliver
                           #   end
                           #end
                           value = "#{@movie.user.vname}'s movie #{@movie.title} was approved."
                        else
                           @movie = movieFound
                           ContentMailer.content_denied(@movie, "Movie").deliver_now
                           value = "#{@movie.user.vname}'s movie #{@movie.title} was denied."
                        end
                        flash[:success] = value
                        redirect_to movies_review_path
                     else
                        redirect_to root_path
                     end
                  else
                     render "webcontrols/crazybat"
                  end
               else
                  redirect_to root_path
               end
            end
         end
      end
end
