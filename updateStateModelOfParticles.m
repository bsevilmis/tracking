function propagatedParticles = updateStateModelOfParticles(particles, stateUpdateNoiseVariances)
% deterministic matrix
A = [1 0 1 0 0 0 0;
     0 1 0 1 0 0 0;
     0 0 1 0 0 0 0;
     0 0 0 1 0 0 0;
     0 0 0 0 1 0 0;
     0 0 0 0 0 1 0
     0 0 0 0 0 0 1];
% update states
propagatedParticles = A*particles + repmat(sqrt(stateUpdateNoiseVariances),1,size(particles,2)) .* randn(size(particles,1),size(particles,2));
end