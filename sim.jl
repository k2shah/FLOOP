#PCC 
function ccQuick(k, l=1)
	k=map(deg2rad, k)
	n=length(k) #get num segemnts 
	p=zeros(n+1, 2) #[x, y]
	t=zeros(n+1) #[angle]
	#calculate profile 
	for i=1:n
		t[i+1]=t[i]+k[i]*l
		if k[i]==0 #handles 0 curvature 
			p[i+1, 1]=p[i, 1]+cos(t[i+1])*l #update x 
	        p[i+1, 2]=p[i, 2]+sin(t[i+1])*l #update y
		else
			p[i+1, 1]=p[i, 1]+(sin(t[i+1])-sin(t[i]))/k[i] #update x 
	        p[i+1, 2]=p[i, 2]+(-cos(t[i+1])+cos(t[i]))/k[i] #update y
	    end
	end
	return p
end

function ccEnd(k, l=1)
	return ccQuick(k, l)[end,:]
end

function ccArm2(k, res=10, l=1)
	l=l/res 
	k=map(deg2rad, k)
	n=length(k) #get num segemnts 
	k=vec(repmat(k', res )) #set curv for each subsegment 
	p=zeros(n*res+1, 2) #[x, y]
	t=zeros(n*res+1) #[angle]
	#calculate profile 
	for i=1:(n*res)
		t[i+1]=t[i]+k[i]*l
		if k[i]==0 #handles 0 curvature 
			p[i+1, 1]=p[i, 1]+cos(t[i+1])*l #update x 
	        p[i+1, 2]=p[i, 2]+sin(t[i+1])*l #update y
		else
			p[i+1, 1]=p[i, 1]+(sin(t[i+1])-sin(t[i]))/k[i] #update x 
	        p[i+1, 2]=p[i, 2]+(-cos(t[i+1])+cos(t[i]))/k[i] #update y
	    end
	end
	e=zeros(n+1,2) #get edge values
	for i=1:n+1
		e[i,:]=p[(i-1)*res+1,:]
	end
	#println("Generated Arm wth $(n) segments")
	return (p, e)
end

function drawArm(arm, edge, res=10)
	gcol=["c","b","r", "g", "m"]
	#plot end eff
	plot([arm[end,1]],[arm[end, 2]], "k*")
	
	#plot profile and edges
	for i=1:nSeg
	    inx=(i-1)*res+1
	    plot(arm[inx:inx+res, 1],arm[inx:inx+res, 2], gcol[i%5+1])
	    plot(edge[i, 1], edge[i, 2], gcol[i%5+1]*"o")
	end
end
function drawArm(state)
	(p,e)=ccArm2(state)
	drawArm(p, e)
end

function selfCollide(p, thre)
	n=size(p,1)
	for i=1:n-1
		for j=i+1:n
			#@show norm(p[i,:]- p[j,:])
			if norm(p[i,:]- p[j,:])<thre
				println("self collsions at: $(i)<->$(j)")
				col=(p[j,:]+p[i,:])/2
				plot(col[1], col[2], "k*")
				return col
			end
		end
	end
	println("no self collsions founds")
	return 0
end 

type Zone
	cent
	radius
end

function drawZone(zone::Zone)
	t=[linspace(0,2*pi,10)]
	p=zeros(length(t),2)
	for i=1:length(t)
		p[i,:]=zone.cent+zone.radius*[cos(t[i]) sin(t[i])]
	end
	plot(p[:,1], p[:,2], "ko")
	return p
end


function obsCollide(arm, zone::Zone, thre=1.1, draw=0)
	for i=1:size(arm, 1)
		if norm(arm[i, :]-zone.cent)<(zone.radius*thre)
			if draw==1
				println("obstacle collision at $(arm[i,:])")
				plot(arm[i, 1], arm[i, 2], "k*")
			end
			return arm[i,:]
		end
	end
	println("no obstacle collsions founds")
	return 0
end

function zoneDist(s, zone::Zone)
    return norm(zone.cent- ccEnd(s))
end


###########broken or unused

function ccSeg(k, res, l)
	t=linspace(0, k*l, res+1) #calcuate angle change
	p=zeros(res+1, 2)
	y=zeros(res+1)
	for i=1:res 
		p[i+1, 1]=p[i, 1]+(sin(t[i+1])-sin(t[i]))/k #update x 
        p[i+1, 2]=p[i, 2]+(-cos(t[i+1])+cos(t[i]))/k #update y
	end
	return (p[:, 1], p[:, 2], t[end])
end

function ccArm(k, res, l=1)
	n=length(k) #number of segments 
    #init segments cords
    x=zeros(n, res+1)
    y=zeros(n, res+1)
    t=zeros(n)
    #conected arm
    
    #calculate segment profile 
    for i=1:n  
        (x[i,:], y[i,:], t[i])=ccSeg(k[i], res, l)
    end
	arm=posArm(x, y, t)

	return (arm, t)
end

##postion arm segments 
function posArm(xSeg, ySeg, t)
	arm=zeros(n*res+1, 2) #[x, y]
	#connect segments 
    arm[1:res+1,:]=hcat(xSeg[1,:]', ySeg[1,:]') #set 1st segment 
    for i=2:n
        idx=(i-1)*res+1
        @show sum(t[1:(i)])
        st=rotate(sum(t[1:(i-1)]))*vcat(xSeg[1,:], ySeg[1,:]) #rotate segment 
        arm[idx:idx+res,:]=st'.+arm[idx,:] #translate segment 
    end

    return arm
end
function rotate(t)
    return [cos(t) -sin(t); sin(t) cos(t)]    
end


#cant
function curv(x, q, l=1, EI=1)
    return atan(q*(3*l^2*x-3*l*x^2+x^3)/(6*EI))
end

function deflec(x, q, l=1, EI=1)
    return q*x^2*(6*l^2-4*l*x+x^2)/(24*EI)
end

function cantSeg(q, res, l=1, EI=1)
    x=linspace(0, l, res+1)
    y=zeros(length(x))
    for i=1:length(x)
        y[i]=deflec(x[i], q)
    end
    t=curv(l, q)
    return (x, y, t)
end



function smash(e)
	n=size(e,1)
	e=e'
	#checks for colisions 
	for i=1:(n-2)
		for j=(i+1):(n-1)
			t=inv(hcat(-(e[:,i+1]-e[:,i]), e[:,j+1]-e[:,j]))*e[:,i]-e[:,j]
			col=vcat(t.<0,t.>1 )
			if norm(col)==0
				println("crash at: ", i, j)
				return e[:,i]+t[1]*(e[:,i+1]-e[:,i])
				
			end
		end	
	end
    return 0
end

println("Import successful: sim.jl")