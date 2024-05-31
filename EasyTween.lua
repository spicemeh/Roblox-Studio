local EasyTween = {}

local EasyTweenFunctions = {}
EasyTweenFunctions.__index = EasyTweenFunctions
local objects = {}

local tweenService = game:GetService("TweenService")



function EasyTween.new(instance: Instance, propertyValue: string)
	if not instance or not propertyValue then
		local unassignedValue = (not instance and "instance" or "") .. 
			(not propertyValue and (not instance and " & " or "") .. "property" or "")
		error(string.format("EasyTween: %s unassigned", unassignedValue))
	end

	if not instance[propertyValue] then
		return
	end

	if objects[instance] then
		return objects[instance]
	end

	objects[instance] = {
		Base = instance,
		Property = propertyValue,
		TweenData = {
			IsTweening = false,
			TweenGoal = nil,
			TweenObject = nil
		},
		TweenCompleteCallback = nil,
		TweenCompleteSignal = Instance.new("BindableEvent")
	}

	setmetatable(objects[instance], {__index = EasyTweenFunctions})
	return objects[instance]
end



function EasyTweenFunctions:Tween(finalGoal : any, duration : number)
	if self.TweenData.IsTweening then
		if self.TweenData.TweenGoal == finalGoal then
			return
		else
			self.TweenData.TweenObject:Cancel()
			self.TweenData.TweenObject = nil
			self.TweenData.TweenGoal = nil
			self.TweenData.IsTweening = false
		end
	end

	local tween = tweenService:Create(self.Base, TweenInfo.new(duration or 1), {[self.Property] = finalGoal})
	self.TweenData.IsTweening = true
	self.TweenData.TweenGoal = finalGoal
	self.TweenData.TweenObject = tween

	tween:Play()
	tween.Completed:Connect(function()
		if self.TweenData.TweenObject == tween then
			self.TweenData.TweenObject = nil
			self.TweenData.TweenGoal = nil
			self.TweenData.IsTweening = false
			if self.TweenCompleteCallback then
				self.TweenCompleteCallback()
			end
		end
	end)	
end

function EasyTweenFunctions:Cancel()
	if self.TweenData.IsTweening then
		self.TweenData.TweenObject:Cancel()
		self.TweenData.TweenObject = nil
		self.TweenData.TweenGoal = nil
		self.TweenData.IsTweening = false
	end
end

function EasyTweenFunctions:Pause()
	if self.TweenData.IsTweening then
		self.TweenData.TweenObject:Pause()
	end
end

function EasyTweenFunctions:Resume()
	if self.TweenData.IsTweening then
		self.TweenData.TweenObject:Play()
	end
end

function EasyTweenFunctions:OnTweenComplete(callback)
	self.TweenCompleteCallback = callback or
		function()

		end
end

return EasyTween
