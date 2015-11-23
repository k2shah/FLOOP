
function makeArm(k, l)
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




