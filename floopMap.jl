type abstractMap
	range #the numercal value of the subState
	sub #array of max subState index 
	nRange #size of the range 
	nSize #how many total states 
end


function makeMap(range, nSeg)
	n=length(range)
	return abstractMap(range, int64(ones(nSeg)*n), n, n^nSeg)
end

function ind2eval(ind, space::abstractMap) #maps space index to value 
	#function body
	sub=ind2sub(tuple(space.sub...), ind)
	return [space.range[sub[i]]	for i=1:length(sub)]
end

function eval2ind(value, space::abstractMap) #maps space value to index
	sub=[find(space.range .== value[i])[] for i=1:length(value)]
	#return int64(sub)
	return sub2ind(space.sub, int64(sub))
end


function detTrans(stateInd, actionInd, stateMap::abstractMap, actionMap::abstractMap)
	state=ind2eval(stateInd, stateMap)
	action=ind2eval(actionInd, actionMap)

	##purly determinmistic transision 
	state_=state+action

	#check bound 
	sMax=maximum(stateMap.range)
	sMin=minimum(stateMap.range)
	for i=1:length(state_)
		if state_[i]>sMax
			state_[i]=sMax
		elseif state_[i]<sMin
			state_[i]=sMin
		end
	end
	#return new index 
	return eval2ind(state_, stateMap)
end

println("Import successful: floopMap.jl")