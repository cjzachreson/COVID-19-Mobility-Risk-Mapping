function [CI_hi, CI_low] = CI_spearmans(rho, n)

if isnan(rho) || (n == 0) || (n <= 3)
    CI_hi = NaN;
    CI_low =NaN;
else
    %rho = 0.8
    
    %n = 20
    
    z = 1/2 * log((1 + rho) / (1 - rho));
    
    % find z values for 95% confidence bounds
    
    %z_hi = z + 1.96 * sqrt( ( (1 + rho^2/2) / (n - 3) ) )
    
    %z_low = z - 1.96 * sqrt( ( (1 + rho^2/2) / (n - 3) ) )
    
    z_hi = z + 1.96 * sqrt( ( 1 / (n - 3) ) );
    
    z_low = z - 1.96 * sqrt( ( 1 / (n - 3) ) );
    
    if isinf(z_hi) || isinf(z_low)
        CI_hi = NaN;
        CI_low = NaN;
    else
        
        CI_hi = (exp(2*z_hi) - 1) / (exp(2*z_hi) + 1);
        
        CI_low = (exp(2*z_low) - 1) / (exp(2*z_low) + 1);
    end
    
end