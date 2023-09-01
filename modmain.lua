local TheNet = GLOBAL.TheNet
local TheSim = GLOBAL.TheSim
local IsServer = TheNet:GetIsServer() or TheNet:IsDedicated()

local stack_size = GetModConfigData("STACK_SIZE")
local Stack_other_objects = GetModConfigData("STACK_OTHER_OBJECTS")

GLOBAL.TUNING.STACK_SIZE_LARGEITEM = stack_size
GLOBAL.TUNING.STACK_SIZE_MEDITEM = stack_size
GLOBAL.TUNING.STACK_SIZE_SMALLITEM = stack_size
GLOBAL.TUNING.STACK_SIZE_TINYITEM = stack_size


local mod_stackable_replica = GLOBAL.require("components/stackable_replica")
mod_stackable_replica._ctor = function(self, inst)
	self.inst = inst
	self._stacksize = GLOBAL.net_shortint(inst.GUID, "stackable._stacksize", "stacksizedirty")
	self._maxsize = GLOBAL.net_shortint(inst.GUID, "stackable._maxsize")
end


--遍历需要叠加的动物
local function AddAnimalStackables(value)
	if IsServer == false then
		return
	end
	for k,v in ipairs(value) do
		AddPrefabPostInit(v,function(inst)
			if(inst.components.stackable == nil) then
				inst:AddComponent("stackable")
			end
			inst.components.inventoryitem:SetOnDroppedFn(function(inst)
				if(inst.components.perishable ~= nil) then
					inst.components.perishable:StopPerishing()
				end
				if(inst.sg ~= nil) then
					inst.sg:GoToState("stunned")
				end
				if inst.components.stackable then
					while inst.components.stackable:StackSize() > 1 do
						local item = inst.components.stackable:Get()
						if item then
							if item.components.inventoryitem then
								item.components.inventoryitem:OnDropped()
							end
							item.Physics:Teleport(inst.Transform:GetWorldPosition())
						end
					end
				 end
			end)
		end)
	end
end

--遍历需要叠加的物品
local function AddItemStackables(value)
	if IsServer == false then
		return
	end
	for k,v in ipairs(value) do
		AddPrefabPostInit(v,function(inst)
			if  inst.components.sanity ~= nil  then
				return
			end
			if  inst.components.inventoryitem == nil  then
				return
			end
			if(inst.components.stackable == nil) then
				inst:AddComponent("stackable")
			end
		end)
	end
end

if Stack_other_objects then 
	--小兔子
	AddAnimalStackables({"rabbit",})
	--鼹鼠
	AddAnimalStackables({"mole",})
	--鸟类
	AddAnimalStackables({"robin","robin_winter","crow","puffin","canary","canary_poisoned",})
	--鱼类
	--,"oceanfish_medium_1_inv","oceanfish_medium_2_inv","oceanfish_medium_3_inv","oceanfish_medium_4_inv","oceanfish_medium_5_inv","oceanfish_medium_6_inv","oceanfish_medium_7_inv","oceanfish_medium_8_inv","oceanfish_small_1_inv","oceanfish_small_2_inv","oceanfish_small_3_inv","oceanfish_small_4_inv","oceanfish_small_5_inv","oceanfish_small_6_inv","oceanfish_small_7_inv","oceanfish_small_8_inv","oceanfish_small_9_inv","wobster_sheller_land","wobster_moonglass_land"
	local STACKABLE_OBJECTS_BASE = {"pondfish","pondeel"}
	AddAnimalStackables(STACKABLE_OBJECTS_BASE)
	--眼球炮塔
	AddItemStackables({"eyeturret_item"})
	--高脚鸟蛋相关
	AddAnimalStackables({"tallbirdegg_cracked","tallbirdegg"})
	--岩浆虫卵相关
	AddAnimalStackables({"lavae_egg","lavae_egg_cracked","lavae_tooth","lavae_cocoon"})
	--暗影心房
	AddItemStackables({"shadowheart"})
	--犀牛角
	AddItemStackables({"minotaurhorn"})
end

