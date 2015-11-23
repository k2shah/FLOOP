
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
    return 
end

function cantArm(p, l=1, EI=1)
    n=length(p)
    #init segments cords
    arm=zeros(n+1, 3) #[x, y, θ]
    for i=1:n #each segment, need 6 sets of points 
        arm[i+1, 3]=arm[i, 3]+p[i]*l^3/(6*EI) #update angle 
        arm[i+1, 1]=arm[i, 1]-sin(arm[i, 3])*p[i]*l^4/(8*EI) #update x 
        arm[i+1, 2]=arm[i, 2]+cos(arm[i, 3])*p[i]*l^4/(8*EI) #update y
    end
    return arm
end

end





