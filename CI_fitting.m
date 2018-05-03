%%
%finding out how well the parameters fit:
%https://www.khanacademy.org/math/multivariable-calculus/applications-of-multivariable-derivatives/quadratic-approximations/a/the-hessian
    %reshape PDF to 34 x 34 x 34 so we dont have index in it explicitly anymore; its now          
    %https://uk.mathworks.com/matlabcentral/answers/296717-how-to-convert-1d-matrix-to-3d-matrix-with-specific-order
        CIs=zeros(24,3)
        clear CI*
        
        subject_list=[ 1     2     3     4     5    6     7     8     9    10    11    12  13 14   15    16    17  18  19 20    21    23    24];
    for i=subject_list;
        
    neg_PDF=PDF_all{1,i}*(-1);
    M=reshape(neg_PDF,[50, 50,50]);
    %in M first dimension there are probability densities for betas, in 2nd
    %dimension are alpha_noRs and in 3rd dimension there are alpha_Rs 
    %https://uk.mathworks.com/help/matlab/ref/gradient.html
    %and https://uk.mathworks.com/matlabcentral/answers/67893-how-do-i-calculate-hessian-matrix-for-an-image
    [gx, gy, gz] = gradient(M);
    [gxx, gxy, gxz] = gradient(gx);
    [gxy, gyy, gyz] = gradient(gy);
    [gxz, gyz, gzz] = gradient(gz);
                    a=round((best_fit_params(i,1)-0.001)/0.02+1);    
                    b=round((best_fit_params(i,2)-0.001)/0.02+1);
                    c=round((best_fit_params(i,3)-0.01)/0.08+1);
                    if a==0;
                        a=1;
                    elseif b==0;
                        b=1;
                    elseif c==0;
                        c=1;
                    end;
    Hessian=[gxx(a,b,c), gxy(a,b,c), gxz(a,b,c); gxy(a,b,c), gyy(a,b,c), gyz(a,b,c); gxz(a,b,c), gyz(a,b,c), gzz(a,b,c)];
    H_inv=inv(Hessian);
    CI_beta=1.96*sqrt(abs(H_inv(1,1,1)));
    CI_alpha_noR=1.96*sqrt(abs(H_inv(2,2,1)));
    CI_alpha_R=1.96*sqrt(abs(H_inv(3,3,1)));
    CI_beta_all(i)=CI_beta;
    CIs(i,:,1)=[CI_alpha_R, CI_alpha_noR, CI_beta];
    end
    
CI_beta_all=CI_beta_all'