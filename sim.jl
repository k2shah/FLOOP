#PCC 
function ccArm2(k, res, l)
	
	n=length(k) #get num segemnts 
	k=vec(repmat(k', res )) #set curv for each subsegment 
	p=zeros(n*res+1, 2) #[x, y]
	t=zeros(n*res+1) #[angle]
	#calculate profile 
	for i=1:(n*res)
		t[i+1]=t[i]+k[i]*l
		p[i+1, 1]=p[i, 1]+(sin(t[i+1])-sin(t[i]))/k[i] #update x 
        p[i+1, 2]=p[i, 2]+(-cos(t[i+1])+cos(t[i]))/k[i] #update y
	end
	e=zeros(n+1,2) #get edge values
	for i=1:n+1
		e[i,:]=p[(i-1)*res+1,:]
	end
	println("Generated Arm wth $(n) segments")
	return (p, e, t)
end
function drawArm(p, e, res)
	gcol=["c","b","r", "g", "m"]
	#plot end eff
	plot([p[end,1]],[p[end, 2]], "k*")
	
	#plot profile and edges
	for i=1:nSeg
	    inx=(i-1)*res+1
	    plot(arm[inx:inx+res, 1],arm[inx:inx+res, 2], gcol[i%5+1])
	    plot(e[i, 1], e[i, 2], gcol[i%5+1]*"o")
	end
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

type Obs
	c
	r
end

function drawObs(obs::Obs)
	t=[linspace(0,2*pi,10)]
	p=zeros(length(t),2)
	for i=1:length(t)
		p[i,:]=obs.c+obs.r*[cos(t[i]) sin(t[i])]
	end
	plot(p[:,1], p[:,2], "o")
	return p
end


function obsCollide(obj, obs::Obs, thre=1.1)
	for i=1:size(obj, 1)
		if norm(obj[i, :]-obs.c)<(obs.r*thre)
			println("obstacle collision at $(obj[i,:])")
			plot(obj[i, 1], obj[i, 2], "k*")
			return obj[i,:]
		end
	end
	println("no obstacle collsions founds")
	return 0
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