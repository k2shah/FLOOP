
function ccArm(k, l)
    #check if we have enough curvature points
    n=length(k)
    
    #init segments cords
    p=zeros(n+1, 3) #[x, y, θ]
    for i=1:n #each segment, need 6 sets of points 
        p[i+1, 3]=p[i, 3]+l*k[i] #update angle 
        p[i+1, 1]=p[i, 1]+(sin(p[i+1, 3])-sin(p[i,3]))/k[i] #update x 
        p[i+1, 2]=p[i, 2]+(-cos(p[i+1, 3])+cos(p[i,3]))/k[i] #update y
    end
    return p
end

function cantArm(p, l=1, EI=1, res=10)
    n=length(p)
    #init segments cords
    arm=zeros(n*res+1, 3) #[x, y, θ]
    for i=1:n #each segment, 
        #@show i
        c=arm[(i-1)*res+1,:] #base of the segment
        for j=1:res
            inx=(i-1)*res+j
            dx=(1.0*j)/res*l
            arm[inx+1,:]=fwdKin(dx, p[i], l, c)
        
            #arm[i+1, 3]=arm[i, 3]+p[i]*l^3/(6*EI) #update angle 
            #arm[i+1, 1]=arm[i, 1]+cos(arm[i, 3])*l-sin(arm[i, 3])*p[i]*l^4/(8*EI) #update x 
            #arm[i+1, 2]=arm[i, 2]+sin(arm[i, 3])*l+cos(arm[i, 3])*p[i]*l^4/(8*EI) #update y
        end
    end
    return arm

end
function rotate(t)
    return [cos(t) -sin(t); sin(t) cos(t)]    
end

function curv(x, q, l=1, EI=1)
    return q*(3*l^2*x-3*l*x^2+x^3)/(6*EI)
end

function deflec(x, q, l=1, EI=1)
    return q*x^2*(6*l^2-4*l*x+x^2)/(24*EI)
end

function fwdKin(dx, q, l, cord)
    t=curv(dx, q, l)
    w=deflec(dx, q, l)
    c=rotate(t)* [dx;w]+ cord[1:2]
    return vcat(c, cord[3]+t)
end




