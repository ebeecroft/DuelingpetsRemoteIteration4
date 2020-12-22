module WarehousesHelper

   private
      def getWarehouseParams(type)
         value = ""
         if(type == "Id")
            value = params[:id]
         elsif(type == "WarehouseId")
            value = params[:warehouse_id]
         elsif(type == "Warehouse")
            value = params.require(:warehouse).permit(:name, :message, :store_open)
         elsif(type == "SlotId")
            value = params[:inventoryslot][:inventoryslot_id]
         elsif(type == "WshelfId")
            value = params[:inventoryslot][:witemshelf_id]
         elsif(type == "Slotindex")
            value = params[:inventoryslot][:slotindex_id]
         elsif(type == "Petindex")            
            value = params[:partner][:petindex_id]
         elsif(type == "WdenId")
            value = params[:partner][:wpetden_id]
         elsif(type == "Partnername")
            value = params[:partner][:name]
         elsif(type == "Partnerdescription")
            value = params[:partner][:description]
         elsif(type == "Partner")
            value = params.require(:partner).permit(:name, :description, :creature_id)
         elsif(type == "Page")
            value = params[:page]
         else
            raise "Invalid type detected!"
         end
         return value
      end

      def checkDen(den)
         #Checks the warehouse den to see if there any creatures available
         noCreatures = false
         slota = ((den.creature1_id.nil? && den.creature2_id.nil?) && (den.creature3_id.nil? && den.creature4_id.nil?))
         slotb = ((den.creature5_id.nil? && den.creature6_id.nil?) && (den.creature7_id.nil? && den.creature8_id.nil?))
         slotc = ((den.creature9_id.nil? && den.creature10_id.nil?) && (den.creature11_id.nil? && den.creature12_id.nil?))
         slotd = ((den.creature13_id.nil? && den.creature14_id.nil?) && (den.creature15_id.nil? && den.creature16_id.nil?))
         if(slota && slotb && slotc && slotd)
            noCreatures = true
         end
         return noCreatures
      end

      def getPet(petIndex, wpetden)
         creatureFound = false
         creature = nil

         #Locates the creature in the warehouse
         petIndex = petIndex.to_i
         if(petIndex == 1)
            creature = Creature.find_by_id(wpetden.creature1_id)
            creatureFound = true
         elsif(petIndex == 2)
            creature = Creature.find_by_id(wpetden.creature2_id)
            creatureFound = true
         elsif(petIndex == 3)
            creature = Creature.find_by_id(wpetden.creature3_id)
            creatureFound = true
         elsif(petIndex == 4)
            creature = Creature.find_by_id(wpetden.creature4_id)
            creatureFound = true
         end

         #Checks additional slots if not found
         if(!creatureFound)
            if(petIndex == 5)
               creature = Creature.find_by_id(wpetden.creature5_id)
               creatureFound = true
            elsif(petIndex == 6)
               creature = Creature.find_by_id(wpetden.creature6_id)
               creatureFound = true
            elsif(petIndex == 7)
               creature = Creature.find_by_id(wpetden.creature7_id)
               creatureFound = true
            elsif(petIndex == 8)
               creature = Creature.find_by_id(wpetden.creature8_id)
               creatureFound = true
            end
         end

         #Checks additional slots if not found
         if(!creatureFound)
            if(petIndex == 9)
               creature = Creature.find_by_id(wpetden.creature9_id)
               creatureFound = true
            elsif(petIndex == 10)
               creature = Creature.find_by_id(wpetden.creature10_id)
               creatureFound = true
            elsif(petIndex == 11)
               creature = Creature.find_by_id(wpetden.creature11_id)
               creatureFound = true
            elsif(petIndex == 12)
               creature = Creature.find_by_id(wpetden.creature12_id)
               creatureFound = true
            end
         end

         #Checks additional slots if not found
         if(!creatureFound)
            if(petIndex == 13)
               creature = Creature.find_by_id(wpetden.creature13_id)
               creatureFound = true
            elsif(petIndex == 14)
               creature = Creature.find_by_id(wpetden.creature14_id)
               creatureFound = true
            elsif(petIndex == 15)
               creature = Creature.find_by_id(wpetden.creature15_id)
               creatureFound = true
            elsif(petIndex == 16)
               creature = Creature.find_by_id(wpetden.creature16_id)
               creatureFound = true
            end
         end

         #Returns the id if the creature exists
         value = -1
         if(creatureFound)
            value = creature.id
         else
            value = creature
         end
         return value
      end

      def getPetStats(petid, type)
         creature = Creature.find_by_id(petid)
         value = ""
         if(type == "Name")
            value = creature.name
            if(creature.retiredpet)
               value = value + " [Retired]"
            end
         elsif(type == "Creator" || type == "User")
            value = creature.user
            if(type == "Creator")
               value = creature.user.vname
            end
         elsif(type == "Image" || type == "Imagecheck")
            value = (creature.image.to_s != "")
            if(type == "Image")
               value = creature.image_url(:thumb)
            end
         elsif(type == "Lives")
            value = creature.lives
            if(creature.unlimitedlives)
               value = value + " [Unl]"
            end
         elsif(type == "Rarity")
            value = creature.rarity
         elsif(type == "Creaturetype")
            value = creature.creaturetype.name
            if(creature.starter)
               value = value + " [Starter]"
            end
         end
         return value
      end

      def getPetcost(petid, petIndex, wpetden, type)
         creature = Creature.find_by_id(petid)
         creatureFound = false
         
         #Determines what to return
         if(type == "Emerald")
            value = creature.emeraldcost
         elsif(type == "Point")
            #Add tax here
            value = creature.cost
         end
         
         #If is not an emerald check the slots
         if(type != "Emerald")
            if(petIndex == 1)
               creatureFound = true
               if(type == "Point")
                  value += wpetden.tax1
               elsif(type == "Quantity")
                  value = wpetden.qty1
               end
            elsif(petIndex == 2)
               creatureFound = true
               if(type == "Point")
                  value += wpetden.tax2
               elsif(type == "Quantity")
                  value = wpetden.qty2
               end
            elsif(petIndex == 3)
               creatureFound = true
               if(type == "Point")
                  value += wpetden.tax3
               elsif(type == "Quantity")
                  value = wpetden.qty3
               end
            elsif(petIndex == 4)
               creatureFound = true
               if(type == "Point")
                  value += wpetden.tax4
               elsif(type == "Quantity")
                  value = wpetden.qty4
               end
            end
         end
         
         #Checks additional slots if not found
         if(type != "Emerald" && !creatureFound)
            if(petIndex == 5)
               creatureFound = true
               if(type == "Point")
                  value += wpetden.tax5
               elsif(type == "Quantity")
                  value = wpetden.qty5
               end
            elsif(petIndex == 6)
               creatureFound = true
               if(type == "Point")
                  value += wpetden.tax6
               elsif(type == "Quantity")
                  value = wpetden.qty6
               end
            elsif(petIndex == 7)
               creatureFound = true
               if(type == "Point")
                  value += wpetden.tax7
               elsif(type == "Quantity")
                  value = wpetden.qty7
               end
            elsif(petIndex == 8)
               creatureFound = true
               if(type == "Point")
                  value += wpetden.tax8
               elsif(type == "Quantity")
                  value = wpetden.qty8
               end
            end
         end
         
         #Checks additional slots if not found
         if(type != "Emerald" && !creatureFound)
            if(petIndex == 9)
               creatureFound = true
               if(type == "Point")
                  value += wpetden.tax9
               elsif(type == "Quantity")
                  value = wpetden.qty9
               end
            elsif(petIndex == 10)
               creatureFound = true
               if(type == "Point")
                  value += wpetden.tax10
               elsif(type == "Quantity")
                  value = wpetden.qty10
               end
            elsif(petIndex == 11)
               creatureFound = true
               if(type == "Point")
                  value += wpetden.tax11
               elsif(type == "Quantity")
                  value = wpetden.qty11
               end
            elsif(petIndex == 12)
               creatureFound = true
               if(type == "Point")
                  value += wpetden.tax12
               elsif(type == "Quantity")
                  value = wpetden.qty12
               end
            end
         end
         
         #Checks additional slots if not found
         if(type != "Emerald" && !creatureFound)
            if(petIndex == 13)
               creatureFound = true
               if(type == "Point")
                  value += wpetden.tax13
               elsif(type == "Quantity")
                  value = wpetden.qty13
               end
            elsif(petIndex == 14)
               creatureFound = true
               if(type == "Point")
                  value += wpetden.tax14
               elsif(type == "Quantity")
                  value = wpetden.qty14
               end
            elsif(petIndex == 15)
               creatureFound = true
               if(type == "Point")
                  value += wpetden.tax15
               elsif(type == "Quantity")
                  value = wpetden.qty15
               end
            elsif(petIndex == 16)
               creatureFound = true
               if(type == "Point")
                  value += wpetden.tax16
               elsif(type == "Quantity")
                  value = wpetden.qty16
               end
            end
         end
         return value
      end

      def getPettypeStats(petid, type)
         creature = Creature.find_by_id(petid)
         value = ""
         if(type == "Physical")
            msg1 = content_tag(:p, "Physical Stats")
            msg2 = content_tag(:p, "Level: #{creature.level}")
            msg3 = content_tag(:p, "HP: #{creature.hp}")
            msg4 = content_tag(:p, "Atk: #{creature.atk} | Def: #{creature.def}")
            msg5 = content_tag(:p, "Agi: #{creature.agility} | Strength: #{creature.strength}")
            value = (msg1 + msg2 + msg3 + msg4 + msg5)
         elsif(type == "Magical")
            msg1 = content_tag(:p, "Magical Stats")
            msg2 = content_tag(:p, "MP: #{creature.mp}")
            msg3 = content_tag(:p, "Matk: #{creature.matk} | Mdef: #{creature.mdef}")
            msg4 = content_tag(:p, "Magi: #{creature.magi} | Mstr: #{creature.mstr}")
            value = (msg1 + msg2 + msg3 + msg4)
         elsif(type == "Stamina")
            msg1 = content_tag(:p, "Stamina Stats")
            msg2 = content_tag(:p, "Fun: #{creature.fun}")
            msg3 = content_tag(:p, "Hunger: #{creature.hunger}")
            msg4 = content_tag(:p, "Thirst: #{creature.thirst}")
            value = (msg1 + msg2 + msg3 + msg4)
         end
         return value
      end
      
      def storePartner(logged_in, creature)
         #Creating the partner entry
         newPartner = logged_in.partners.new(getWarehouseParams("Partner"))
         newPartner.adopted_on = currentTime
         newPartner.updated_on = currentTime
         newPartner.plevel = creature.level
         newPartner.chp = creature.hp
         newPartner.hp = creature.hp
         newPartner.atk = creature.atk
         newPartner.def = creature.def
         newPartner.agility = creature.agility
         newPartner.strength = creature.strength
         newPartner.mlevel = creature.level
         newPartner.cmp = creature.mp
         newPartner.mp = creature.mp
         newPartner.matk = creature.matk
         newPartner.mdef = creature.mdef
         newPartner.magi = creature.magi
         newPartner.mstr = creature.mstr
         newPartner.chunger = creature.hunger
         newPartner.hunger = creature.hunger
         newPartner.cthirst = creature.thirst
         newPartner.thirst = creature.thirst
         newPartner.cfun = creature.fun
         newPartner.fun = creature.fun
         newPartner.lives = creature.lives
         newPartner.creature_id = creature.id
         if(logged_in.partners.count == 0)
            newPartner.activepet = true
         end

         #Adoptcost should be based off the shopcost value
         newPartner.adoptcost = creature.cost
         newPartner.cost = creature.cost
         return newPartner
      end

      def updateDen(petIndex, wpetden)
         petIndex = petIndex.to_i
         creatureFound = false
         
         if(petIndex == 1)
            creatureFound = true
            if(wpetden.qty1 > 1)
               wpetden.qty1 -= 1
            else
               wpetden.qty1 = 0
               wpetden.tax1 = 0
               wpetden.creature1_id = nil
            end
         elsif(petIndex == 2)
            creatureFound = true
            if(wpetden.qty2 > 1)
               wpetden.qty2 -= 1
            else
               wpetden.qty2 = 0
               wpetden.tax2 = 0
               wpetden.creature2_id = nil
            end
         elsif(petIndex == 3)
            creatureFound = true
            if(wpetden.qty3 > 1)
               wpetden.qty3 -= 1
            else
               wpetden.qty3 = 0
               wpetden.tax3 = 0
               wpetden.creature3_id = nil
            end
         elsif(petIndex == 4)
            creatureFound = true
            if(wpetden.qty4 > 1)
               wpetden.qty4 -= 1
            else
               wpetden.qty4 = 0
               wpetden.tax4 = 0
               wpetden.creature4_id = nil
            end
         end
         
         #Check additional dens if not found
         if(!creatureFound)
            if(petIndex == 5)
               creatureFound = true
               if(wpetden.qty5 > 1)
                  wpetden.qty5 -= 1
               else
                  wpetden.qty5 = 0
                  wpetden.tax5 = 0
                  wpetden.creature5_id = nil
               end
            elsif(petIndex == 6)
               creatureFound = true
               if(wpetden.qty6 > 1)
                  wpetden.qty6 -= 1
               else
                  wpetden.qty6 = 0
                  wpetden.tax6 = 0
                  wpetden.creature6_id = nil
               end
            elsif(petIndex == 7)
               creatureFound = true
               if(wpetden.qty7 > 1)
                  wpetden.qty7 -= 1
               else
                  wpetden.qty7 = 0
                  wpetden.tax7 = 0
                  wpetden.creature7_id = nil
               end
            elsif(petIndex == 8)
               creatureFound = true
               if(wpetden.qty8 > 1)
                  wpetden.qty8 -= 1
               else
                  wpetden.qty8 = 0
                  wpetden.tax8 = 0
                  wpetden.creature8_id = nil
               end
            end
         end
         
         #Check additional dens if not found
         if(!creatureFound)
            if(petIndex == 9)
               creatureFound = true
               if(wpetden.qty9 > 1)
                  wpetden.qty9 -= 1
               else
                  wpetden.qty9 = 0
                  wpetden.tax9 = 0
                  wpetden.creature9_id = nil
               end
            elsif(petIndex == 10)
               creatureFound = true
               if(wpetden.qty10 > 1)
                  wpetden.qty10 -= 1
               else
                  wpetden.qty10 = 0
                  wpetden.tax10 = 0
                  wpetden.creature10_id = nil
               end
            elsif(petIndex == 11)
               creatureFound = true
               if(wpetden.qty11 > 1)
                  wpetden.qty11 -= 1
               else
                  wpetden.qty11 = 0
                  wpetden.tax11 = 0
                  wpetden.creature11_id = nil
               end
            elsif(petIndex == 12)
               creatureFound = true
               if(wpetden.qty12 > 1)
                  wpetden.qty12 -= 1
               else
                  wpetden.qty12 = 0
                  wpetden.tax12 = 0
                  wpetden.creature12_id = nil
               end
            end
         end
         
         #Check additional dens if not found
         if(!creatureFound)
            if(petIndex == 13)
               creatureFound = true
               if(wpetden.qty13 > 1)
                  wpetden.qty13 -= 1
               else
                  wpetden.qty13 = 0
                  wpetden.tax13 = 0
                  wpetden.creature13_id = nil
               end
            elsif(petIndex == 14)
               creatureFound = true
               if(wpetden.qty14 > 1)
                  wpetden.qty14 -= 1
               else
                  wpetden.qty14 = 0
                  wpetden.tax14 = 0
                  wpetden.creature14_id = nil
               end
            elsif(petIndex == 15)
               creatureFound = true
               if(wpetden.qty15 > 1)
                  wpetden.qty15 -= 1
               else
                  wpetden.qty15 = 0
                  wpetden.tax15 = 0
                  wpetden.creature15_id = nil
               end
            elsif(petIndex == 16)
               creatureFound = true
               if(wpetden.qty16 > 1)
                  wpetden.qty16 -= 1
               else
                  wpetden.qty16 = 0
                  wpetden.tax16 = 0
                  wpetden.creature16_id = nil
               end
            end
         end
      end

      def checkShelf(shelf)
         #Checks the warehouse shelf to see if there any items available
         noItems = false
         slota = ((shelf.item1_id.nil? && shelf.item2_id.nil?) && (shelf.item3_id.nil? && shelf.item4_id.nil?))
         slotb = ((shelf.item5_id.nil? && shelf.item6_id.nil?) && (shelf.item7_id.nil? && shelf.item8_id.nil?))
         slotc = ((shelf.item9_id.nil? && shelf.item10_id.nil?) && (shelf.item11_id.nil? && shelf.item12_id.nil?))
         slotd = ((shelf.item13_id.nil? && shelf.item14_id.nil?) && (shelf.item15_id.nil? && shelf.item16_id.nil?))
         slote = ((shelf.item17_id.nil? && shelf.item18_id.nil?) && (shelf.item19_id.nil? && shelf.item20_id.nil?))
         slotf = ((shelf.item21_id.nil? && shelf.item22_id.nil?) && (shelf.item23_id.nil? && shelf.item24_id.nil?))
         slotg = ((shelf.item25_id.nil? && shelf.item26_id.nil?) && (shelf.item27_id.nil? && shelf.item28_id.nil?))
         sloth = (shelf.item29_id.nil? && shelf.item30_id.nil?)
         if(slota && slotb && slotc && slotd && slote && slotf && slotg && sloth)
            noItems = true
         end
         return noItems
      end

      def getItemStats(itemid, type)
         item = Item.find_by_id(itemid)
         value = ""
         if(type == "Name")
            value = item.name
            if(item.equipable)
               value = value + " [Equipable]"
            end
            if(item.retireditem)
               value = value + " [Retired]"
            end
         elsif(type == "Creator" || type == "User")
            value = item.user
            if(type == "Creator")
               value = item.user.vname
            end
         elsif(type == "Image" || type == "Imagecheck")
            value = (item.itemart.to_s != "")
            if(type == "Image")
               value = item.itemart_url(:thumb)
            end
         elsif(type == "Durability")
            value = item.durability
         elsif(type == "Rarity")
            value = item.rarity
         elsif(type == "Itemtype")
            value = item.itemtype.name
         end
         return value
      end

      def getItemtypeStats(itemid)
         item = Item.find_by_id(itemid)
         value = ""
         if(item.itemtype.name == "Food")
            msg1 = content_tag(:p, "HP: #{item.hp}")
            msg2 = content_tag(:p, "Hunger: #{item.hunger}")
            msg3 = content_tag(:p, "Fun: #{item.fun}")
            value = (msg1 + msg2 + msg3)
         elsif(item.itemtype.name == "Drink")
            msg1 = content_tag(:p, "HP: #{item.hp}")
            msg2 = content_tag(:p, "Thirst: #{item.thirst}")
            msg3 = content_tag(:p, "Fun: #{item.fun}")
            value = (msg1 + msg2 + msg3)
         elsif(item.itemtype.name == "Weapon")
            msg1 = content_tag(:p, "Atk: #{item.atk}")
            msg2 = content_tag(:p, "Def: #{item.def}")
            msg3 = content_tag(:p, "Agi: #{item.agility}")
            msg4 = content_tag(:p, "Str: #{item.strength}")
            value = (msg1 + msg2 + msg3 + msg4)
         elsif(item.itemtype.name == "Toy")
            msg1 = content_tag(:p, "Fun: #{item.fun}")
            msg2 = content_tag(:p, "Hunger: #{item.hunger}")
            msg3 = content_tag(:p, "Thirst: #{item.thirst}")
            value = (msg1 + msg2 + msg3)
         end
         return value
      end

      def getItem(slotIndex, witemshelf)
         itemFound = false
         item = nil

         #Locates the item in the warehouse
         slotIndex = slotIndex.to_i
         if(slotIndex == 1)
            item = Item.find_by_id(witemshelf.item1_id)
            itemFound = true
         elsif(slotIndex == 2)
            item = Item.find_by_id(witemshelf.item2_id)
            itemFound = true
         elsif(slotIndex == 3)
            item = Item.find_by_id(witemshelf.item3_id)
            itemFound = true
         elsif(slotIndex == 4)
            item = Item.find_by_id(witemshelf.item4_id)
            itemFound = true
         elsif(slotIndex == 5)
            item = Item.find_by_id(witemshelf.item5_id)
            itemFound = true
         end

         #Checks additional slots if not found
         if(!itemFound)
            if(slotIndex == 6)
               item = Item.find_by_id(witemshelf.item6_id)
               itemFound = true
            elsif(slotIndex == 7)
               item = Item.find_by_id(witemshelf.item7_id)
               itemFound = true
            elsif(slotIndex == 8)
               item = Item.find_by_id(witemshelf.item8_id)
               itemFound = true
            elsif(slotIndex == 9)
               item = Item.find_by_id(witemshelf.item9_id)
               itemFound = true
            elsif(slotIndex == 10)
               item = Item.find_by_id(witemshelf.item10_id)
               itemFound = true
            end
         end

         #Checks additional slots if not found
         if(!itemFound)
            if(slotIndex == 11)
               item = Item.find_by_id(witemshelf.item11_id)
               itemFound = true
            elsif(slotIndex == 12)
               item = Item.find_by_id(witemshelf.item12_id)
               itemFound = true
            elsif(slotIndex == 13)
               item = Item.find_by_id(witemshelf.item13_id)
               itemFound = true
            elsif(slotIndex == 14)
               item = Item.find_by_id(witemshelf.item14_id)
               itemFound = true
            elsif(slotIndex == 15)
               item = Item.find_by_id(witemshelf.item15_id)
               itemFound = true
            end
         end

         #Checks additional slots if not found
         if(!itemFound)
            if(slotIndex == 16)
               item = Item.find_by_id(witemshelf.item16_id)
               itemFound = true
            elsif(slotIndex == 17)
               item = Item.find_by_id(witemshelf.item17_id)
               itemFound = true
            elsif(slotIndex == 18)
               item = Item.find_by_id(witemshelf.item18_id)
               itemFound = true
            elsif(slotIndex == 19)
               item = Item.find_by_id(witemshelf.item19_id)
               itemFound = true
            elsif(slotIndex == 20)
               item = Item.find_by_id(witemshelf.item20_id)
               itemFound = true
            end
         end

         #Checks additional slots if not found
         if(!itemFound)
            if(slotIndex == 21)
               item = Item.find_by_id(witemshelf.item21_id)
               itemFound = true
            elsif(slotIndex == 22)
               item = Item.find_by_id(witemshelf.item22_id)
               itemFound = true
            elsif(slotIndex == 23)
               item = Item.find_by_id(witemshelf.item23_id)
               itemFound = true
            elsif(slotIndex == 24)
               item = Item.find_by_id(witemshelf.item24_id)
               itemFound = true
            elsif(slotIndex == 25)
               item = Item.find_by_id(witemshelf.item25_id)
               itemFound = true
            end
         end

         #Checks additional slots if not found
         if(!itemFound)
            if(slotIndex == 26)
               item = Item.find_by_id(witemshelf.item26_id)
               itemFound = true
            elsif(slotIndex == 27)
               item = Item.find_by_id(witemshelf.item27_id)
               itemFound = true
            elsif(slotIndex == 28)
               item = Item.find_by_id(witemshelf.item28_id)
               itemFound = true
            elsif(slotIndex == 29)
               item = Item.find_by_id(witemshelf.item29_id)
               itemFound = true
            elsif(slotIndex == 30)
               item = Item.find_by_id(witemshelf.item30_id)
               itemFound = true
            end
         end

         #Returns the id if the item exists
         value = -1
         if(itemFound)
            value = item.id
         else
            value = item
         end
         return value
      end

      def getItemcost(itemid, slotIndex, witemshelf, type)
         item = Item.find_by_id(itemid)
         itemFound = false
         
         #Determines what to return
         if(type == "Emerald")
            value = item.emeraldcost
         elsif(type == "Point")
            #Add tax here
            value = item.cost
         end
         
         #If is not an emerald check the slots
         if(type != "Emerald")
            if(slotIndex == 1)
               itemFound = true
               if(type == "Point")
                  value += witemshelf.tax1
               elsif(type == "Quantity")
                  value = witemshelf.qty1
               end
            elsif(slotIndex == 2)
               itemFound = true
               if(type == "Point")
                  value += witemshelf.tax2
               elsif(type == "Quantity")
                  value = witemshelf.qty2
               end
            elsif(slotIndex == 3)
               itemFound = true
               if(type == "Point")
                  value += witemshelf.tax3
               elsif(type == "Quantity")
                  value = witemshelf.qty3
               end
            elsif(slotIndex == 4)
               itemFound = true
               if(type == "Point")
                  value += witemshelf.tax4
               elsif(type == "Quantity")
                  value = witemshelf.qty4
               end
            elsif(slotIndex == 5)
               itemFound = true
               if(type == "Point")
                  value += witemshelf.tax5
               elsif(type == "Quantity")
                  value = witemshelf.qty5
               end
            end
         end
         
         #Checks additional slots if not found
         if(type != "Emerald" && !itemFound)
            if(slotIndex == 6)
               itemFound = true
               if(type == "Point")
                  value += witemshelf.tax6
               elsif(type == "Quantity")
                  value = witemshelf.qty6
               end
            elsif(slotIndex == 7)
               itemFound = true
               if(type == "Point")
                  value += witemshelf.tax7
               elsif(type == "Quantity")
                  value = witemshelf.qty7
               end
            elsif(slotIndex == 8)
               itemFound = true
               if(type == "Point")
                  value += witemshelf.tax8
               elsif(type == "Quantity")
                  value = witemshelf.qty8
               end
            elsif(slotIndex == 9)
               itemFound = true
               if(type == "Point")
                  value += witemshelf.tax9
               elsif(type == "Quantity")
                  value = witemshelf.qty9
               end
            elsif(slotIndex == 10)
               itemFound = true
               if(type == "Point")
                  value += witemshelf.tax10
               elsif(type == "Quantity")
                  value = witemshelf.qty10
               end
            end
         end
         
         #Checks additional slots if not found
         if(type != "Emerald" && !itemFound)
            if(slotIndex == 11)
               itemFound = true
               if(type == "Point")
                  value += witemshelf.tax11
               elsif(type == "Quantity")
                  value = witemshelf.qty11
               end
            elsif(slotIndex == 12)
               itemFound = true
               if(type == "Point")
                  value += witemshelf.tax12
               elsif(type == "Quantity")
                  value = witemshelf.qty12
               end
            elsif(slotIndex == 13)
               itemFound = true
               if(type == "Point")
                  value += witemshelf.tax13
               elsif(type == "Quantity")
                  value = witemshelf.qty13
               end
            elsif(slotIndex == 14)
               itemFound = true
               if(type == "Point")
                  value += witemshelf.tax14
               elsif(type == "Quantity")
                  value = witemshelf.qty14
               end
            elsif(slotIndex == 15)
               itemFound = true
               if(type == "Point")
                  value += witemshelf.tax15
               elsif(type == "Quantity")
                  value = witemshelf.qty15
               end
            end
         end
         
         #Checks additional slots if not found
         if(type != "Emerald" && !itemFound)
            if(slotIndex == 16)
               itemFound = true
               if(type == "Point")
                  value += witemshelf.tax16
               elsif(type == "Quantity")
                  value = witemshelf.qty16
               end
            elsif(slotIndex == 17)
               itemFound = true
               if(type == "Point")
                  value += witemshelf.tax17
               elsif(type == "Quantity")
                  value = witemshelf.qty17
               end
            elsif(slotIndex == 18)
               itemFound = true
               if(type == "Point")
                  value += witemshelf.tax18
               elsif(type == "Quantity")
                  value = witemshelf.qty18
               end
            elsif(slotIndex == 19)
               itemFound = true
               if(type == "Point")
                  value += witemshelf.tax19
               elsif(type == "Quantity")
                  value = witemshelf.qty19
               end
            elsif(slotIndex == 20)
               itemFound = true
               if(type == "Point")
                  value += witemshelf.tax20
               elsif(type == "Quantity")
                  value = witemshelf.qty20
               end
            end
         end
         
         #Checks additional slots if not found
         if(type != "Emerald" && !itemFound)
            if(slotIndex == 21)
               itemFound = true
               if(type == "Point")
                  value += witemshelf.tax21
               elsif(type == "Quantity")
                  value = witemshelf.qty21
               end
            elsif(slotIndex == 22)
               itemFound = true
               if(type == "Point")
                  value += witemshelf.tax22
               elsif(type == "Quantity")
                  value = witemshelf.qty22
               end
            elsif(slotIndex == 23)
               itemFound = true
               if(type == "Point")
                  value += witemshelf.tax23
               elsif(type == "Quantity")
                  value = witemshelf.qty23
               end
            elsif(slotIndex == 24)
               itemFound = true
               if(type == "Point")
                  value += witemshelf.tax24
               elsif(type == "Quantity")
                  value = witemshelf.qty24
               end
            elsif(slotIndex == 25)
               itemFound = true
               if(type == "Point")
                  value += witemshelf.tax25
               elsif(type == "Quantity")
                  value = witemshelf.qty25
               end
            end
         end
         
         #Checks additional slots if not found
         if(type != "Emerald" && !itemFound)
            if(slotIndex == 26)
               itemFound = true
               if(type == "Point")
                  value += witemshelf.tax26
               elsif(type == "Quantity")
                  value = witemshelf.qty26
               end
            elsif(slotIndex == 27)
               itemFound = true
               if(type == "Point")
                  value += witemshelf.tax27
               elsif(type == "Quantity")
                  value = witemshelf.qty27
               end
            elsif(slotIndex == 28)
               itemFound = true
               if(type == "Point")
                  value += witemshelf.tax28
               elsif(type == "Quantity")
                  value = witemshelf.qty28
               end
            elsif(slotIndex == 29)
               itemFound = true
               if(type == "Point")
                  value += witemshelf.tax29
               elsif(type == "Quantity")
                  value = witemshelf.qty29
               end
            elsif(slotIndex == 30)
               itemFound = true
               if(type == "Point")
                  value += witemshelf.tax30
               elsif(type == "Quantity")
                  value = witemshelf.qty30
               end
            end
         end
         return value
      end

      #has been replaced by getItemCost
      def findItemcost(slotIndex, witemshelf, type)
         value = 0
         slotIndex = slotIndex.to_i
         if(slotIndex == 1)
            if(type == "Tax")
               value = witemshelf.tax1
            elsif(type == "Emerald")
               item = Item.find_by_id(witemshelf.item1_id)
               value = item.emeraldcost
            elsif(type == "Id")
               item = Item.find_by_id(witemshelf.item1_id)
               value = item.id
            elsif(type == "Durability")
               item = Item.find_by_id(witemshelf.item1_id)
               value = item.durability
            else
               item = Item.find_by_id(witemshelf.item1_id)
               #item.tax
               value = item.cost
            end
         elsif(slotIndex == 2)
            if(type == "Tax")
               value = witemshelf.tax2
            elsif(type == "Emerald")
               item = Item.find_by_id(witemshelf.item2_id)
               value = item.emeraldcost
            elsif(type == "Id")
               item = Item.find_by_id(witemshelf.item2_id)
               value = item.id
            elsif(type == "Durability")
               item = Item.find_by_id(witemshelf.item2_id)
               value = item.durability
            else
               item = Item.find_by_id(witemshelf.item2_id)
               #item.tax
               value = item.cost
            end
         elsif(slotIndex == 3)
            if(type == "Tax")
               value = witemshelf.tax3
            elsif(type == "Emerald")
               item = Item.find_by_id(witemshelf.item3_id)
               value = item.emeraldcost
            elsif(type == "Id")
               item = Item.find_by_id(witemshelf.item3_id)
               value = item.id
            elsif(type == "Durability")
               item = Item.find_by_id(witemshelf.item3_id)
               value = item.durability
            else
               item = Item.find_by_id(witemshelf.item3_id)
               #item.tax
               value = item.cost
            end
         elsif(slotIndex == 4)
            if(type == "Tax")
               value = witemshelf.tax4
            elsif(type == "Emerald")
               item = Item.find_by_id(witemshelf.item4_id)
               value = item.emeraldcost
            elsif(type == "Id")
               item = Item.find_by_id(witemshelf.item4_id)
               value = item.id
            elsif(type == "Durability")
               item = Item.find_by_id(witemshelf.item4_id)
               value = item.durability
            else
               item = Item.find_by_id(witemshelf.item4_id)
               #item.tax
               value = item.cost
            end
         elsif(slotIndex == 5)
            if(type == "Tax")
               value = witemshelf.tax5
            elsif(type == "Emerald")
               item = Item.find_by_id(witemshelf.item5_id)
               value = item.emeraldcost
            elsif(type == "Id")
               item = Item.find_by_id(witemshelf.item5_id)
               value = item.id
            elsif(type == "Durability")
               item = Item.find_by_id(witemshelf.item5_id)
               value = item.durability
            else
               item = Item.find_by_id(witemshelf.item5_id)
               #item.tax
               value = item.cost
            end
         elsif(slotIndex == 6)
            if(type == "Tax")
               value = witemshelf.tax6
            elsif(type == "Emerald")
               item = Item.find_by_id(witemshelf.item6_id)
               value = item.emeraldcost
            elsif(type == "Id")
               item = Item.find_by_id(witemshelf.item6_id)
               value = item.id
            elsif(type == "Durability")
               item = Item.find_by_id(witemshelf.item6_id)
               value = item.durability
            else
               item = Item.find_by_id(witemshelf.item6_id)
               #item.tax
               value = item.cost
            end
         elsif(slotIndex == 7)
            if(type == "Tax")
               value = witemshelf.tax7
            elsif(type == "Emerald")
               item = Item.find_by_id(witemshelf.item7_id)
               value = item.emeraldcost
            elsif(type == "Id")
               item = Item.find_by_id(witemshelf.item7_id)
               value = item.id
            elsif(type == "Durability")
               item = Item.find_by_id(witemshelf.item7_id)
               value = item.durability
            else
               item = Item.find_by_id(witemshelf.item7_id)
               #item.tax
               value = item.cost
            end
         elsif(slotIndex == 8)
            if(type == "Tax")
               value = witemshelf.tax8
            elsif(type == "Emerald")
               item = Item.find_by_id(witemshelf.item8_id)
               value = item.emeraldcost
            elsif(type == "Id")
               item = Item.find_by_id(witemshelf.item8_id)
               value = item.id
            elsif(type == "Durability")
               item = Item.find_by_id(witemshelf.item8_id)
               value = item.durability
            else
               item = Item.find_by_id(witemshelf.item8_id)
               #item.tax
               value = item.cost
            end
         elsif(slotIndex == 9)
            if(type == "Tax")
               value = witemshelf.tax9
            elsif(type == "Emerald")
               item = Item.find_by_id(witemshelf.item9_id)
               value = item.emeraldcost
            elsif(type == "Id")
               item = Item.find_by_id(witemshelf.item9_id)
               value = item.id
            elsif(type == "Durability")
               item = Item.find_by_id(witemshelf.item9_id)
               value = item.durability
            else
               item = Item.find_by_id(witemshelf.item9_id)
               #item.tax
               value = item.cost
            end
         elsif(slotIndex == 10)
            if(type == "Tax")
               value = witemshelf.tax10
            elsif(type == "Emerald")
               item = Item.find_by_id(witemshelf.item10_id)
               value = item.emeraldcost
            elsif(type == "Id")
               item = Item.find_by_id(witemshelf.item10_id)
               value = item.id
            elsif(type == "Durability")
               item = Item.find_by_id(witemshelf.item10_id)
               value = item.durability
            else
               item = Item.find_by_id(witemshelf.item10_id)
               #item.tax
               value = item.cost
            end
         elsif(slotIndex == 11)
            if(type == "Tax")
               value = witemshelf.tax11
            elsif(type == "Emerald")
               item = Item.find_by_id(witemshelf.item11_id)
               value = item.emeraldcost
            elsif(type == "Id")
               item = Item.find_by_id(witemshelf.item11_id)
               value = item.id
            elsif(type == "Durability")
               item = Item.find_by_id(witemshelf.item11_id)
               value = item.durability
            else
               item = Item.find_by_id(witemshelf.item11_id)
               #item.tax
               value = item.cost
            end
         elsif(slotIndex == 12)
            if(type == "Tax")
               value = witemshelf.tax12
            elsif(type == "Emerald")
               item = Item.find_by_id(witemshelf.item12_id)
               value = item.emeraldcost
            elsif(type == "Id")
               item = Item.find_by_id(witemshelf.item12_id)
               value = item.id
            elsif(type == "Durability")
               item = Item.find_by_id(witemshelf.item12_id)
               value = item.durability
            else
               item = Item.find_by_id(witemshelf.item12_id)
               #item.tax
               value = item.cost
            end
         elsif(slotIndex == 13)
            if(type == "Tax")
               value = witemshelf.tax13
            elsif(type == "Emerald")
               item = Item.find_by_id(witemshelf.item13_id)
               value = item.emeraldcost
            elsif(type == "Id")
               item = Item.find_by_id(witemshelf.item13_id)
               value = item.id
            elsif(type == "Durability")
               item = Item.find_by_id(witemshelf.item13_id)
               value = item.durability
            else
               item = Item.find_by_id(witemshelf.item13_id)
               #item.tax
               value = item.cost
            end
         elsif(slotIndex == 14)
            if(type == "Tax")
               value = witemshelf.tax14
            elsif(type == "Emerald")
               item = Item.find_by_id(witemshelf.item14_id)
               value = item.emeraldcost
            elsif(type == "Id")
               item = Item.find_by_id(witemshelf.item14_id)
               value = item.id
            elsif(type == "Durability")
               item = Item.find_by_id(witemshelf.item14_id)
               value = item.durability
            else
               item = Item.find_by_id(witemshelf.item14_id)
               #item.tax
               value = item.cost
            end
         elsif(slotIndex == 15)
            if(type == "Tax")
               value = witemshelf.tax15
            elsif(type == "Emerald")
               item = Item.find_by_id(witemshelf.item15_id)
               value = item.emeraldcost
            elsif(type == "Id")
               item = Item.find_by_id(witemshelf.item15_id)
               value = item.id
            elsif(type == "Durability")
               item = Item.find_by_id(witemshelf.item15_id)
               value = item.durability
            else
               item = Item.find_by_id(witemshelf.item15_id)
               #item.tax
               value = item.cost
            end
         elsif(slotIndex == 16)
            if(type == "Tax")
               value = witemshelf.tax16
            elsif(type == "Emerald")
               item = Item.find_by_id(witemshelf.item16_id)
               value = item.emeraldcost
            elsif(type == "Id")
               item = Item.find_by_id(witemshelf.item16_id)
               value = item.id
            elsif(type == "Durability")
               item = Item.find_by_id(witemshelf.item16_id)
               value = item.durability
            else
               item = Item.find_by_id(witemshelf.item16_id)
               #item.tax
               value = item.cost
            end
         elsif(slotIndex == 17)
            if(type == "Tax")
               value = witemshelf.tax17
            elsif(type == "Emerald")
               item = Item.find_by_id(witemshelf.item17_id)
               value = item.emeraldcost
            elsif(type == "Id")
               item = Item.find_by_id(witemshelf.item17_id)
               value = item.id
            elsif(type == "Durability")
               item = Item.find_by_id(witemshelf.item17_id)
               value = item.durability
            else
               item = Item.find_by_id(witemshelf.item17_id)
               #item.tax
               value = item.cost
            end
         elsif(slotIndex == 18)
            if(type == "Tax")
               value = witemshelf.tax18
            elsif(type == "Emerald")
               item = Item.find_by_id(witemshelf.item18_id)
               value = item.emeraldcost
            elsif(type == "Id")
               item = Item.find_by_id(witemshelf.item18_id)
               value = item.id
            elsif(type == "Durability")
               item = Item.find_by_id(witemshelf.item18_id)
               value = item.durability
            else
               item = Item.find_by_id(witemshelf.item18_id)
               #item.tax
               value = item.cost
            end
         elsif(slotIndex == 19)
            if(type == "Tax")
               value = witemshelf.tax19
            elsif(type == "Emerald")
               item = Item.find_by_id(witemshelf.item19_id)
               value = item.emeraldcost
            elsif(type == "Id")
               item = Item.find_by_id(witemshelf.item19_id)
               value = item.id
            elsif(type == "Durability")
               item = Item.find_by_id(witemshelf.item19_id)
               value = item.durability
            else
               item = Item.find_by_id(witemshelf.item19_id)
               #item.tax
               value = item.cost
            end
         elsif(slotIndex == 20)
            if(type == "Tax")
               value = witemshelf.tax20
            elsif(type == "Emerald")
               item = Item.find_by_id(witemshelf.item20_id)
               value = item.emeraldcost
            elsif(type == "Id")
               item = Item.find_by_id(witemshelf.item20_id)
               value = item.id
            elsif(type == "Durability")
               item = Item.find_by_id(witemshelf.item20_id)
               value = item.durability
            else
               item = Item.find_by_id(witemshelf.item20_id)
               #item.tax
               value = item.cost
            end
         elsif(slotIndex == 21)
            if(type == "Tax")
               value = witemshelf.tax21
            elsif(type == "Emerald")
               item = Item.find_by_id(witemshelf.item21_id)
               value = item.emeraldcost
            elsif(type == "Id")
               item = Item.find_by_id(witemshelf.item21_id)
               value = item.id
            elsif(type == "Durability")
               item = Item.find_by_id(witemshelf.item21_id)
               value = item.durability
            else
               item = Item.find_by_id(witemshelf.item21_id)
               #item.tax
               value = item.cost
            end
         elsif(slotIndex == 22)
            if(type == "Tax")
               value = witemshelf.tax22
            elsif(type == "Emerald")
               item = Item.find_by_id(witemshelf.item22_id)
               value = item.emeraldcost
            elsif(type == "Id")
               item = Item.find_by_id(witemshelf.item22_id)
               value = item.id
            elsif(type == "Durability")
               item = Item.find_by_id(witemshelf.item22_id)
               value = item.durability
            else
               item = Item.find_by_id(witemshelf.item22_id)
               #item.tax
               value = item.cost
            end
         elsif(slotIndex == 23)
            if(type == "Tax")
               value = witemshelf.tax23
            elsif(type == "Emerald")
               item = Item.find_by_id(witemshelf.item23_id)
               value = item.emeraldcost
            elsif(type == "Id")
               item = Item.find_by_id(witemshelf.item23_id)
               value = item.id
            elsif(type == "Durability")
               item = Item.find_by_id(witemshelf.item23_id)
               value = item.durability
            else
               item = Item.find_by_id(witemshelf.item23_id)
               #item.tax
               value = item.cost
            end
         elsif(slotIndex == 24)
            if(type == "Tax")
               value = witemshelf.tax24
            elsif(type == "Emerald")
               item = Item.find_by_id(witemshelf.item24_id)
               value = item.emeraldcost
            elsif(type == "Id")
               item = Item.find_by_id(witemshelf.item24_id)
               value = item.id
            elsif(type == "Durability")
               item = Item.find_by_id(witemshelf.item24_id)
               value = item.durability
            else
               item = Item.find_by_id(witemshelf.item24_id)
               #item.tax
               value = item.cost
            end
         elsif(slotIndex == 25)
            if(type == "Tax")
               value = witemshelf.tax25
            elsif(type == "Emerald")
               item = Item.find_by_id(witemshelf.item25_id)
               value = item.emeraldcost
            elsif(type == "Id")
               item = Item.find_by_id(witemshelf.item25_id)
               value = item.id
            elsif(type == "Durability")
               item = Item.find_by_id(witemshelf.item25_id)
               value = item.durability
            else
               item = Item.find_by_id(witemshelf.item25_id)
               #item.tax
               value = item.cost
            end
         elsif(slotIndex == 26)
            if(type == "Tax")
               value = witemshelf.tax26
            elsif(type == "Emerald")
               item = Item.find_by_id(witemshelf.item26_id)
               value = item.emeraldcost
            elsif(type == "Id")
               item = Item.find_by_id(witemshelf.item26_id)
               value = item.id
            elsif(type == "Durability")
               item = Item.find_by_id(witemshelf.item26_id)
               value = item.durability
            else
               item = Item.find_by_id(witemshelf.item26_id)
               #item.tax
               value = item.cost
            end
         elsif(slotIndex == 27)
            if(type == "Tax")
               value = witemshelf.tax27
            elsif(type == "Emerald")
               item = Item.find_by_id(witemshelf.item27_id)
               value = item.emeraldcost
            elsif(type == "Id")
               item = Item.find_by_id(witemshelf.item27_id)
               value = item.id
            elsif(type == "Durability")
               item = Item.find_by_id(witemshelf.item27_id)
               value = item.durability
            else
               item = Item.find_by_id(witemshelf.item27_id)
               #item.tax
               value = item.cost
            end   
         elsif(slotIndex == 28)
            if(type == "Tax")
               value = witemshelf.tax28
            elsif(type == "Emerald")
               item = Item.find_by_id(witemshelf.item28_id)
               value = item.emeraldcost
            elsif(type == "Id")
               item = Item.find_by_id(witemshelf.item28_id)
               value = item.id
            elsif(type == "Durability")
               item = Item.find_by_id(witemshelf.item28_id)
               value = item.durability
            else
               item = Item.find_by_id(witemshelf.item28_id)
               #item.tax
               value = item.cost
            end
         elsif(slotIndex == 29)
            if(type == "Tax")
               value = witemshelf.tax29
            elsif(type == "Emerald")
               item = Item.find_by_id(witemshelf.item29_id)
               value = item.emeraldcost
            elsif(type == "Id")
               item = Item.find_by_id(witemshelf.item29_id)
               value = item.id
            elsif(type == "Durability")
               item = Item.find_by_id(witemshelf.item29_id)
               value = item.durability
            else
               item = Item.find_by_id(witemshelf.item29_id)
               #item.tax
               value = item.cost
            end
         elsif(slotIndex == 30)
            if(type == "Tax")
               value = witemshelf.tax30
            elsif(type == "Emerald")
               item = Item.find_by_id(witemshelf.item30_id)
               value = item.emeraldcost
            elsif(type == "Id")
               item = Item.find_by_id(witemshelf.item30_id)
               value = item.id
            elsif(type == "Durability")
               item = Item.find_by_id(witemshelf.item30_id)
               value = item.durability
            else
               item = Item.find_by_id(witemshelf.item30_id)
               #item.tax
               value = item.cost
            end
         end
         return value
      end
      
      def storeitem(invslot, witemshelf, slotIndex)
         #Sets up the variables
         itemid = findItemcost(slotIndex, witemshelf, "Id")
         durability = findItemcost(slotIndex, witemshelf, "Durability")
         spacefound = false
         emptyspace = false
         
         #Determines which slot to put the item in
         if(invslot.item1_id && invslot.item1_id == itemid && invslot.startdur1 == durability)
            spacefound = true
            invslot.qty1 += 1
         elsif(invslot.item2_id && invslot.item2_id == itemid && invslot.startdur2 == durability)
            spacefound = true
            invslot.qty2 += 1
         elsif(invslot.item3_id && invslot.item3_id == itemid && invslot.startdur3 == durability)
            spacefound = true
            invslot.qty3 += 1
         elsif(invslot.item4_id && invslot.item4_id == itemid && invslot.startdur4 == durability)
            spacefound = true
            invslot.qty4 += 1
         else
            if(invslot.item1_id.nil?)
               emptyspace = true
               invslot.item1_id = itemid
               invslot.curdur1 = durability
               invslot.startdur1 = durability
               invslot.qty1 = 1
            elsif(invslot.item2_id.nil?)
               emptyspace = true
               invslot.item2_id = itemid
               invslot.curdur2 = durability
               invslot.startdur2 = durability
               invslot.qty2 = 1
            elsif(invslot.item3_id.nil?)
               emptyspace = true
               invslot.item3_id = itemid
               invslot.curdur3 = durability
               invslot.startdur3 = durability
               invslot.qty3 = 1
            elsif(invslot.item4_id.nil?)
               emptyspace = true
               invslot.item4_id = itemid
               invslot.curdur4 = durability
               invslot.startdur4 = durability
               invslot.qty4 = 1
            end
         end

         #Checks the additional itemslots
         if(!spacefound)
            if(invslot.item5_id && invslot.item5_id == itemid && invslot.startdur5 == durability)
               spacefound = true
               invslot.qty5 += 1
            elsif(invslot.item6_id && invslot.item6_id == itemid && invslot.startdur6 == durability)
               spacefound = true
               invslot.qty6 += 1
            elsif(invslot.item7_id && invslot.item7_id == itemid && invslot.startdur7 == durability)
               spacefound = true
               invslot.qty7 += 1
            elsif(invslot.item8_id && invslot.item8_id == itemid && invslot.startdur8 == durability)
               spacefound = true
               invslot.qty8 += 1
            else
               if(!emptyspace)
                  if(invslot.item5_id.nil?)
                     emptyspace = true
                     invslot.item5_id = itemid
                     invslot.curdur5 = durability
                     invslot.startdur5 = durability
                     invslot.qty5 = 1
                  elsif(invslot.item6_id.nil?)
                     emptyspace = true
                     invslot.item6_id = itemid
                     invslot.curdur6 = durability
                     invslot.startdur6 = durability
                     invslot.qty6 = 1
                  elsif(invslot.item7_id.nil?)
                     emptyspace = true
                     invslot.item7_id = itemid
                     invslot.curdur7 = durability
                     invslot.startdur7 = durability
                     invslot.qty7 = 1
                  elsif(invslot.item8_id.nil?)
                     emptyspace = true
                     invslot.item8_id = itemid
                     invslot.curdur8 = durability
                     invslot.startdur8 = durability
                     invslot.qty8 = 1
                  end
               end
            end
         end
         
         #Checks the additional itemslots
         if(!spacefound)
            if(invslot.item9_id && invslot.item9_id == itemid && invslot.startdur9 == durability)
               spacefound = true
               invslot.qty9 += 1
            elsif(invslot.item10_id && invslot.item10_id == itemid && invslot.startdur10 == durability)
               spacefound = true
               invslot.qty10 += 1
            elsif(invslot.item11_id && invslot.item11_id == itemid && invslot.startdur11 == durability)
               spacefound = true
               invslot.qty11 += 1
            elsif(invslot.item12_id && invslot.item12_id == itemid && invslot.startdur12 == durability)
               spacefound = true
               invslot.qty12 += 1
            else
               if(!emptyspace)
                  if(invslot.item9_id.nil?)
                     emptyspace = true
                     invslot.item9_id = itemid
                     invslot.curdur9 = durability
                     invslot.startdur9 = durability
                     invslot.qty9 = 1
                  elsif(invslot.item10_id.nil?)
                     emptyspace = true
                     invslot.item10_id = itemid
                     invslot.curdur10 = durability
                     invslot.startdur10 = durability
                     invslot.qty10 = 1
                  elsif(invslot.item11_id.nil?)
                     emptyspace = true
                     invslot.item11_id = itemid
                     invslot.curdur11 = durability
                     invslot.startdur11 = durability
                     invslot.qty11 = 1
                  elsif(invslot.item12_id.nil?)
                     emptyspace = true
                     invslot.item12_id = itemid
                     invslot.curdur12 = durability
                     invslot.startdur12 = durability
                     invslot.qty12 = 1
                  end
               end
            end
         end
         
         #Checks the additional itemslots
         if(!spacefound)
            if(invslot.item13_id && invslot.item13_id == itemid && invslot.startdur13 == durability)
               spacefound = true
               invslot.qty13 += 1
            elsif(invslot.item14_id && invslot.item14_id == itemid && invslot.startdur14 == durability)
               spacefound = true
               invslot.qty14 += 1
            else
               if(!emptyspace)
                  if(invslot.item13_id.nil?)
                     emptyspace = true
                     invslot.item13_id = itemid
                     invslot.curdur13 = durability
                     invslot.startdur13 = durability
                     invslot.qty13 = 1
                  elsif(invslot.item14_id.nil?)
                     emptyspace = true
                     invslot.item14_id = itemid
                     invslot.curdur14 = durability
                     invslot.startdur14 = durability
                     invslot.qty14 = 1
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
      
      def updateShelf(slotIndex, witemshelf)
         slotIndex = slotIndex.to_i
         if(slotIndex == 1)
            if(witemshelf.qty1 > 1)
               witemshelf.qty1 -= 1
            else
               witemshelf.qty1 = 0
               witemshelf.tax1 = 0
               witemshelf.item1_id = nil
            end
         elsif(slotIndex == 2)
            if(witemshelf.qty2 > 1)
               witemshelf.qty2 -= 1
            else
               witemshelf.qty2 = 0
               witemshelf.tax2 = 0
               witemshelf.item2_id = nil
            end
         elsif(slotIndex == 3)
            if(witemshelf.qty3 > 1)
               witemshelf.qty3 -= 1
            else
               witemshelf.qty3 = 0
               witemshelf.tax3 = 0
               witemshelf.item3_id = nil
            end
         elsif(slotIndex == 4)
            if(witemshelf.qty4 > 1)
               witemshelf.qty4 -= 1
            else
               witemshelf.qty4 = 0
               witemshelf.tax4 = 0
               witemshelf.item4_id = nil
            end
         elsif(slotIndex == 5)
            if(witemshelf.qty5 > 1)
               witemshelf.qty5 -= 1
            else
               witemshelf.qty5 = 0
               witemshelf.tax5 = 0
               witemshelf.item5_id = nil
            end
         elsif(slotIndex == 6)
            if(witemshelf.qty6 > 1)
               witemshelf.qty6 -= 1
            else
               witemshelf.qty6 = 0
               witemshelf.tax6 = 0
               witemshelf.item6_id = nil
            end
         elsif(slotIndex == 7)
            if(witemshelf.qty7 > 1)
               witemshelf.qty7 -= 1
            else
               witemshelf.qty7 = 0
               witemshelf.tax7 = 0
               witemshelf.item7_id = nil
            end
         elsif(slotIndex == 8)
            if(witemshelf.qty8 > 1)
               witemshelf.qty8 -= 1
            else
               witemshelf.qty8 = 0
               witemshelf.tax8 = 0
               witemshelf.item8_id = nil
            end
         elsif(slotIndex == 9)
            if(witemshelf.qty9 > 1)
               witemshelf.qty9 -= 1
            else
               witemshelf.qty9 = 0
               witemshelf.tax9 = 0
               witemshelf.item9_id = nil
            end
         elsif(slotIndex == 10)
            if(witemshelf.qty10 > 1)
               witemshelf.qty10 -= 1
            else
               witemshelf.qty10 = 0
               witemshelf.tax10 = 0
               witemshelf.item10_id = nil
            end
         elsif(slotIndex == 11)
            if(witemshelf.qty11 > 1)
               witemshelf.qty11 -= 1
            else
               witemshelf.qty11 = 0
               witemshelf.tax11 = 0
               witemshelf.item11_id = nil
            end
         elsif(slotIndex == 12)
            if(witemshelf.qty12 > 1)
               witemshelf.qty12 -= 1
            else
               witemshelf.qty12 = 0
               witemshelf.tax12 = 0
               witemshelf.item12_id = nil
            end
         elsif(slotIndex == 13)
            if(witemshelf.qty13 > 1)
               witemshelf.qty13 -= 1
            else
               witemshelf.qty13 = 0
               witemshelf.tax13 = 0
               witemshelf.item13_id = nil
            end
         elsif(slotIndex == 14)
            if(witemshelf.qty14 > 1)
               witemshelf.qty14 -= 1
            else
               witemshelf.qty14 = 0
               witemshelf.tax14 = 0
               witemshelf.item14_id = nil
            end
         elsif(slotIndex == 15)
            if(witemshelf.qty15 > 1)
               witemshelf.qty15 -= 1
            else
               witemshelf.qty15 = 0
               witemshelf.tax15 = 0
               witemshelf.item15_id = nil
            end
         elsif(slotIndex == 16)
            if(witemshelf.qty16 > 1)
               witemshelf.qty16 -= 1
            else
               witemshelf.qty16 = 0
               witemshelf.tax16 = 0
               witemshelf.item16_id = nil
            end
         elsif(slotIndex == 17)
            if(witemshelf.qty17 > 1)
               witemshelf.qty17 -= 1
            else
               witemshelf.qty17 = 0
               witemshelf.tax17 = 0
               witemshelf.item17_id = nil
            end
         elsif(slotIndex == 18)
            if(witemshelf.qty18 > 1)
               witemshelf.qty18 -= 1
            else
               witemshelf.qty18 = 0
               witemshelf.tax18 = 0
               witemshelf.item18_id = nil
            end
         elsif(slotIndex == 19)
            if(witemshelf.qty19 > 1)
               witemshelf.qty19 -= 1
            else
               witemshelf.qty19 = 0
               witemshelf.tax19 = 0
               witemshelf.item19_id = nil
            end
         elsif(slotIndex == 20)
            if(witemshelf.qty20 > 1)
               witemshelf.qty20 -= 1
            else
               witemshelf.qty20 = 0
               witemshelf.tax20 = 0
               witemshelf.item20_id = nil
            end
         elsif(slotIndex == 21)
            if(witemshelf.qty21 > 1)
               witemshelf.qty21 -= 1
            else
               witemshelf.qty21 = 0
               witemshelf.tax21 = 0
               witemshelf.item21_id = nil
            end
         elsif(slotIndex == 22)
            if(witemshelf.qty22 > 1)
               witemshelf.qty22 -= 1
            else
               witemshelf.qty22 = 0
               witemshelf.tax22 = 0
               witemshelf.item22_id = nil
            end
         elsif(slotIndex == 23)
            if(witemshelf.qty23 > 1)
               witemshelf.qty23 -= 1
            else
               witemshelf.qty23 = 0
               witemshelf.tax23 = 0
               witemshelf.item23_id = nil
            end
         elsif(slotIndex == 24)
            if(witemshelf.qty24 > 1)
               witemshelf.qty24 -= 1
            else
               witemshelf.qty24 = 0
               witemshelf.tax24 = 0
               witemshelf.item24_id = nil
            end
         elsif(slotIndex == 25)
            if(witemshelf.qty25 > 1)
               witemshelf.qty25 -= 1
            else
               witemshelf.qty25 = 0
               witemshelf.tax25 = 0
               witemshelf.item25_id = nil
            end
         elsif(slotIndex == 26)
            if(witemshelf.qty26 > 1)
               witemshelf.qty26 -= 1
            else
               witemshelf.qty26 = 0
               witemshelf.tax26 = 0
               witemshelf.item26_id = nil
            end
         elsif(slotIndex == 27)
            if(witemshelf.qty27 > 1)
               witemshelf.qty27 -= 1
            else
               witemshelf.qty27 = 0
               witemshelf.tax27 = 0
               witemshelf.item27_id = nil
            end   
         elsif(slotIndex == 28)
            if(witemshelf.qty28 > 1)
               witemshelf.qty28 -= 1
            else
               witemshelf.qty28 = 0
               witemshelf.tax28 = 0
               witemshelf.item28_id = nil
            end
         elsif(slotIndex == 29)
            if(witemshelf.qty29 > 1)
               witemshelf.qty29 -= 1
            else
               witemshelf.qty29 = 0
               witemshelf.tax29 = 0
               witemshelf.item29_id = nil
            end
         elsif(slotIndex == 30)
            if(witemshelf.qty30 > 1)
               witemshelf.qty30 -= 1
            else
               witemshelf.qty30 = 0
               witemshelf.tax30 = 0
               witemshelf.item30_id = nil
            end
         end
      end
      
      def showCommons(type)
         warehouseFound = Warehouse.find_by_name(getWarehouseParams("Id"))
         logged_in = current_user
         if(warehouseFound && logged_in)
            removeTransactions
            @warehouse = warehouseFound
            pets = warehouseFound.wpetdens.all
            @wpetdens = Kaminari.paginate_array(pets).page(getWarehouseParams("Page")).per(1)
            myslots = logged_in.inventory.inventoryslots.all
            @slots = myslots
            shelves = warehouseFound.witemshelves.all
            @witemshelves = Kaminari.paginate_array(shelves).page(getWarehouseParams("Page")).per(1)
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
            elsif(type == "purchase")
               logged_in = current_user
               warehouseFound = Warehouse.find_by_id(getWarehouseParams("WarehouseId"))
               slotFound = Inventoryslot.find_by_id(getWarehouseParams("SlotId"))
               shelfFound = Witemshelf.find_by_id(getWarehouseParams("WshelfId"))
               slotIndex = getWarehouseParams("Slotindex")
               validPurchase = (!warehouseFound.nil? && !slotFound.nil? && !shelfFound.nil?)
               if(logged_in && validPurchase && (slotFound.inventory_id == logged_in.inventory.id))
                  tax = findItemcost(slotIndex, shelfFound, "Tax")
                  cost = findItemcost(slotIndex, shelfFound, "Points")
                  emeralds = findItemcost(slotIndex, shelfFound, "Emerald")
                  room = storeitem(slotFound, shelfFound, slotIndex)
                  buyable = ((logged_in.pouch.amount - (cost + tax)) >= 0 && (logged_in.pouch.emeraldamount - emeralds) >= 0)
                  if(room && buyable)
                     #Buys item
                     logged_in.pouch.amount -= (cost + tax)
                     logged_in.pouch.emeraldamount -= emeralds
                     @pouch = logged_in.pouch
                     @pouch.save
                     warehouseFound.profit += (cost + tax)
                     @warehouse = warehouseFound
                     @warehouse.save
                     
                     #Does this actually update?
                     updateShelf(slotIndex, shelfFound)
                     @witemshelf = shelfFound
                     @witemshelf.save
                     
                     #How does this store item?
                     @inventoryslot = slotFound
                     @inventoryslot.save
                     
                     #Eventually need to keep track of transactions
                     item = Item.find_by_id(getItem(slotIndex, shelfFound))
                     if(item.user_id != logged_in.id)
                        owner = Pouch.find_by_user_id(item.user_id)
                        points = ((cost + tax) * 0.10).round
                        owner.amount += points
                        @owner = owner
                        @owner.save
                     end
                     flash[:success] = "Item #{item.name} was added to the inventory!"
                     redirect_to user_inventory_path(@inventoryslot.inventory.user, @inventoryslot.inventory)
                  else
                     item = Item.find_by_id(getItem(slotIndex, shelfFound))
                     if(!room)
                        flash[:error] = "No room to store the item #{item.name}!"
                     else
                        flash[:error] = "Insufficient funds to purchase the item #{item.name}!"
                     end
                     redirect_to user_path(logged_in.id)
                  end
               else
                  redirect_to root_path
               end
            elsif(type == "buypet")
               logged_in = current_user
               warehouseFound = Warehouse.find_by_id(getWarehouseParams("WarehouseId"))
               denFound = Wpetden.find_by_id(getWarehouseParams("WdenId"))
               petIndex = getWarehouseParams("Petindex")
               petname = getWarehouseParams("Partnername")
               description = getWarehouseParams("Partnerdescription")
               validPurchase = (warehouseFound && denFound)
               if(logged_in && validPurchase && !petIndex.nil?)
                  cost = getPetcost(getPet(petIndex, denFound), petIndex, denFound, "Point")
                  emeralds = getPetcost(getPet(petIndex, denFound), petIndex, denFound, "Emerald")
                  buyable = ((logged_in.pouch.amount - cost) >= 0 && (logged_in.pouch.emeraldamount - emeralds) >= 0)
                  if(buyable)
                     pet = Creature.find_by_id(getPet(petIndex, denFound))
                     partner = storePartner(logged_in, pet)
                     @partner = partner
                     if(@partner.save)
                        if(logged_in.partners.count > 0)
                           logged_in.pouch.amount -= cost
                           logged_in.pouch.emeraldamount -= emeralds
                           @pouch = logged_in.pouch
                           @pouch.save
                           warehouseFound.profit += cost
                           @warehouse = warehouseFound
                           @warehouse.save
                           #Eventually need to keep track of transactions
                           if(pet.user_id != logged_in.id)
                              owner = Pouch.find_by_user_id(pet.user_id)
                              points = (cost  * 0.10).round
                              owner.amount += points
                              @owner = owner
                              @owner.save
                           end
                        end
                        #Builds the partners equipbag
                        newEquip = Equip.new(params[:equip])
                        newEquip.partner_id = partner.id
                        @equip = newEquip
                        @equip.save

                        #Builds the partners fight
                        newFight = Fight.new(params[:fight])
                        newFight.partner_id = partner.id
                        @fight = newFight
                        @fight.save

                        #Saves the updated warehouse inventory
                        updateDen(petIndex, denFound)
                        @wpetden = denFound
                        @wpetden.save
                        flash[:success] = "Pet #{@partner.name} was added to the party!"
                        redirect_to user_partner_path(partner.user, partner)
                     else
                        flash[:error] = "Partner name or description was empty or spaces were used instead of - as part of the name!"
                        redirect_to warehouse_path(warehouseFound.name)
                     end
                  else
                     pet = Creature.find_by_id(getPet(slotIndex, denFound))
                     flash[:error] = "Insufficient funds to adopt the creature #{pet.name}!"
                     redirect_to user_path(logged_in.id)
                  end
               else
                  redirect_to root_path
               end
            end
         end
      end
end
