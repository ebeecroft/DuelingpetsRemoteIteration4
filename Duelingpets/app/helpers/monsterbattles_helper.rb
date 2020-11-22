module MonsterbattlesHelper

   private
      def getMonsterbattleParams(type)
         value = ""
         if(type == "Id")
            value = params[:id]
         elsif(type == "MonsterbattleId")
            value = params[:monsterbattle_id]
         elsif(type == "User")
            value = params[:user_id]
         elsif(type == "Monsterbattle")
            
         elsif(type == "Page")
            value = params[:page]
         else
            raise "Invalid type detected!"
         end
         return value
      end

      def getBattleCalc(monsterbattle)
         #Sets up variables to check validity of partner and monster
         partnerValid = (!monsterbattle.partner_plevel.nil? && !monsterbattle.partner_chp.nil? && !monsterbattle.partner_hp.nil? && monsterbattle.partner_atk.nil? && !monsterbattle.partner_def.nil? && !monsterbattle.partner_agility.nil? && !monsterbattle.partner_strength.nil? && !monsterbattle.partner_mlevel.nil? && !monsterbattle.partner_cmp.nil? && !monsterbattle.partner_mp.nil? && !monsterbattle.partner_matk.nil? && !monsterbattle.partner_mdef.nil? && !monsterbattle.partner_magi.nil? && !monsterbattle.partner_mstr.nil?)
         monsterValid = (!monsterbattle.monster_plevel.nil? && !monsterbattle.monster_chp.nil? && !monsterbattle.monster_hp.nil? && !monsterbattle.monster_atk.nil? && !monsterbattle.monster_def.nil? && !monsterbattle.monster_agility.nil? && !monsterbattle.monster_mlevel.nil? && !monsterbattle.monster_cmp.nil? && !monsterbattle.monster_mp.nil? && !monsterbattle.monster_matk.nil? && !monsterbattle.monster_mdef.nil? && !monsterbattle.monster_magi.nil?)
         if(partnerValid && monsterValid && !monsterbattle.battleover)
            results = `public/Resources/Code/battlecalc/calc #{monsterbattle.partner_plevel} #{monsterbattle.partner_chp} #{monsterbattle.partner_hp} #{monsterbattle.partner_atk} #{monsterbattle.partner_def} #{monsterbattle.partner_agility} #{monsterbattle.partner_strength} #{monsterbattle.partner_mlevel} #{monsterbattle.partner_cmp} #{monsterbattle.partner_mp} #{monsterbattle.partner_matk} #{monsterbattle.partner_mdef} #{monsterbattle.partner_magi} #{monsterbattle.partner_mstr} #{monsterbattle.monster_plevel} #{monsterbattle.monster_chp} #{monsterbattle.monster_hp} #{monsterbattle.monster_atk} #{monsterbattle.monster_def} #{monsterbattle.monster_agility} #{monsterbattle.monster_mlevel} #{monsterbattle.monster_cmp} #{monsterbattle.monster_mp} #{monsterbattle.monster_matk} #{monsterbattle.monster_mdef} #{monsterbattle.monster_magi}`
            #May change once equips are added
            battleAttributes = results.split(",")
            petDamage, monsterDamage, petHPLeft, monsterHPLeft = battleAttributes.map{|str| str.to_i}
            monsterbattle.partner_chp -= monsterDamage
            monsterbattle.monster_chp -= petDamage
            monsterbattle.round += 1
            if(petHPLeft <= 0 || monsterHPLeft <= 0)
               results2 = `public/Resources/Code/battleresults/calc #{petHPLeft} #{monsterHPLeft}`
               battlestatus = results2
               if(battlestatus != "Loss")
                  results3 = `public/Resources/Code/levelup/calc #{monsterbattle.partner_plevel} #{monsterbattle.partner_exp} #{monsterbattle.monster_exp}`
                  levelups = results3.split(",")
                  exp, levels, tokens = levelups.map{|str| str.to_i}
                  monsterbattle.partner_plevel += levels
                  monsterbattle.partner_pexp += exp
                  monsterbattle.tokens_earned += tokens
                  monsterbattle.exp_earned += exp
                  if(battlestatus == "Win")
                     #Dreyore, and other items
                     results4 = `public/Resources/Code/monloot/calc #{monsterbattle.monster_plevel} #{monsterbattle.monster_loot}`
                     dreyoreGained = results4
                     monsterbattle.dreyore_earned += dreyoreGained
                  end
               else
                  flash[:success] = "Sorry better luck next time"
                  redirect_to root_path
               end
               monsterbattle.battleover = true
               monsterbattle.ended_on = currentTime
            end
            @monsterbattle = monsterbattle
            @monsterbattle.save
            redirect_to fight_monsterbattle_path(@monsterbattle.fight, @monsterbattle)
         else
            if(monsterbattle.battleover)
               flash[:error] = "This battle is already over!"
            end
            redirect_to root_path
         end
      end

      def showCommons(type)
         monsterbattleFound = Monsterbattle.find_by_id(getMonsterbattleParams("Id"))
         if(monsterbattleFound && current_user)
            removeTransactions
            #visitTimer(type, blogFound)
            #cleanupOldVisits
            @monsterbattle = monsterbattleFound
            if(type == "destroy")
               logged_in = current_user
               if(logged_in && ((logged_in.id == monsterbattleFound.partner.user_id) || logged_in.pouch.privilege == "Admin"))
                  if(logged_in.pouch.privilege == "Admin")
                     flash[:success] = "Battle was successfully removed!"
                     monsterbattleFound.fight.partner
                     partnerFound = monsterbattleFound.fight.partner
                     partnerFound.inbattle = false
                     @partner = partnerFound
                     @partner.save
                     @monsterbattle.destroy
                     redirect_to monsterbattles_path
                  else
                     if(monsterbattleFound.battleover)
                        flash[:success] = "Battle was successfully removed!"
                        @monsterbattle.destroy
                        redirect_to partner_fight_path(monsterbattleFound.fight.partner, monsterbattleFound.fight)
                     else
                        flash[:error] = "You can't delete an active battle!"
                        redirect_to root_path
                     end
                  end
               else
                  redirect_to root_path
               end
            end
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
               logged_in = current_user
               if(logged_in && logged_in.pouch.privilege == "Admin")
                  battles = Monsterbattle.order("started_on desc")
                  @monsterbattles = Kaminari.paginate_array(battles).page(getMonsterbattleParams("Page")).per(10)
               else
                  redirect_to root_path
               end
            elsif(type == "create")
               allMode = Maintenancemode.find_by_id(1)
               monsterMode = Maintenancemode.find_by_id(15)
               if(allMode.maintenance_on || monsterMode.maintenance_on)
                  if(allMode.maintenance_on)
                     render "/start/maintenance"
                  else
                     render "/monsters/maintenance"
                  end
               else
                  logged_in = current_user
                  #petchosen = params[:selectedpet][:petowner_id]
                  #userFound = User.find_by_vname(getMonsterParams("User"))
                  partnerFound = Partner.find_by_id(params[:partner_id])
                  monsterFound = Monster.find_by_id(params[:monster_id])
                  if(logged_in && partnerFound && monsterFound && partnerFound.user_id == logged_in.id)
                     #Remember to eventually add some way for damage attributes to not show up on the first round
                     newBattle = partnerFound.fight.monsterbattles.new(getMonsterParams("Monsterbattle"))
                     newBattle.started_on = currentTime
                     
                     #Stores the Partner physical stats
                     newBattle.partner_name = partnerFound.name #Necessary?
                     newBattle.creaturetype_id = partnerFound.creature.creaturetype_id #Necessary?
                     newBattle.partner_plevel = partnerFound.plevel
                     newBattle.partner_pexp = partnerFound.pexp
                     newBattle.partner_chp = partnerFound.chp
                     newBattle.partner_hp = partnerFound.hp
                     newBattle.partner_atk = partnerFound.atk
                     newBattle.parnter_def = partnerFound.def
                     newBattle.partner_agility = partnerFound.agility
                     newBattle.partner_strength = partnerFound.strength

                     #Stores the Partner magical stats                     
                     newBattle.partner_mlevel = partnerFound.mlevel
                     newBattle.partner_mexp = partnerFound.mexp
                     newBattle.partner_cmp = partnerFound.cmp
                     newBattle.partner_mp = partnerFound.mp
                     newBattle.partner_matk = partnerFound.matk
                     newBattle.parnter_mdef = partnerFound.mdef
                     newBattle.partner_magi = partnerFound.magi
                     newBattle.partner_mstr = partnerFound.mstr
                     
                     #Stores the Partner battle traits
                     newBattle.partner_lives = partnerFound.lives
                     newBattle.partner_activepet = partnerFound.activepet
                     newBattle.partner_rarity = partnerFound.rarity
                     partnerFound.inbattle = true
                     
                     #Stores the Monster physical stats
                     newBattle.monster_name = monsterFound.name #Necessary?
                     newBattle.monstertype_id = monsterFound.monstertype_id #Necessary?
                     newBattle.monster_plevel = monsterFound.plevel
                     newBattle.monster_chp = monsterFound.chp
                     newBattle.monster_hp = monsterFound.hp
                     newBattle.monster_atk = monsterFound.atk
                     newBattle.monster_def = monsterFound.def
                     newBattle.monster_agility = monsterFound.agility
                     
                     #Stores the Monster magical stats
                     newBattle.monster_mlevel = monsterFound.mlevel
                     newBattle.monster_cmp = monsterFound.cmp
                     newBattle.monster_mp = monsterFound.mp
                     newBattle.monster_matk = monsterFound.matk
                     newBattle.monster_mdef = monsterFound.mdef
                     newBattle.monster_magi = monsterFound.magi
                     
                     #Stores the Monster battle traits
                     newBattle.monster_loot = monsterFound.loot
                     newBattle.monster_mischief = monsterFound.mischief
                     newBattle.monster_rarity = monsterFound.rarity
                     newBattle.monster_id = monsterFound.id
                     
                     @partner = partnerFound
                     @monsterbattle = newBattle
                     
                     if(@monsterbattle.save)
                        @partner.save
                        flash[:success] = "#{@partner.name} is fighting #{@monsterbattle.monster_name}!"
                        redirect_to fight_monsterbattle_path(@monsterbattle.fight, @monsterbattle)
                     else
                        flash[:error] = "Battle was unable to be saved!"
                        redirect_to root_path
                     end
                  else
                     redirect_to root_path
                  end
               end
            elsif(type == "show" || type == "destroy")
               allMode = Maintenancemode.find_by_id(1)
               monsterMode = Maintenancemode.find_by_id(15)
               if(allMode.maintenance_on || monsterMode.maintenance_on)
                  if(current_user && current_user.pouch.privilege == "Admin")
                     showCommons(type)
                  else
                     if(allMode.maintenance_on)
                        render "/start/maintenance"
                     else
                        render "/monsters/maintenance"
                     end
                  end
               else
                  showCommons(type)
               end
            elsif(type == "battle")
               logged_in = current_user
               battleFound = Monsterbattle.find_by_id(params[:id])
               if(logged_in && battleFound)
                  if(logged_in.id == battleFound.fight.partner.user_id)
                     getBattleCalc(battleFound)
                  else
                     redirect_to root_path
                  end
               else
                  redirect_to root_path
               end
            end
         end
      end
end
